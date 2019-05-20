CREATE PROCEDURE flow.ExecuteSSISPackage
    @FlowID INT
  , @SSISPackageName NVARCHAR(500)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @ExecutionID BIGINT;
  DECLARE @ReferenceID BIGINT;
  DECLARE @ErrorCode INT = 0;
  DECLARE @Status INT;
  DECLARE @StatusDescription NVARCHAR(100);
  DECLARE @ServerName NVARCHAR(128);
  DECLARE @FolderName NVARCHAR(128);
  DECLARE @ProjectName NVARCHAR(128);
  DECLARE @PackageName NVARCHAR(128);
  DECLARE @EnvironmentName NVARCHAR(255);

  SELECT
      @FolderName = f.name
    , @ProjectName = p.name
    , @PackageName = pkg.name
  FROM SSISDB.[catalog].packages AS pkg
  INNER JOIN SSISDB.[catalog].projects AS p 
      ON p.project_id = pkg.project_id
  INNER JOIN SSISDB.[catalog].folders AS f
      ON  f.folder_id = p.folder_id
  WHERE '/SSISDB/' + f.name +'/'+ p.name +'/'+ pkg.name = @SSISPackageName

  IF @PackageName IS NULL
  BEGIN
    EXEC flow.Log 'ERROR', 'SSIS Package not found: :1:', @SSISPackageName;
    RETURN 1;
  END

  SET @EnvironmentName = flow.GetParameterValue(@FlowID, 'SSISEnvironmentName');

  -- Get an environment reference
  SELECT @ReferenceID = er.reference_id
  FROM SSISDB.catalog.environment_references AS er
  INNER JOIN SSISDB.catalog.projects AS p
    ON p.project_id = er.project_id
  INNER JOIN SSISDB.catalog.folders AS f
    ON f.folder_id = p.folder_id
  WHERE er.reference_type = 'A'
    AND '/SSISDB/' + f.name +'/'+ er.environment_name = @EnvironmentName

  IF @ReferenceID IS NULL
  BEGIN
    EXEC flow.Log 'ERROR', 'SSIS environment not found: :1:', @EnvironmentName;
    THROW 51000, 'SSIS environment not found', 1;
  END

  EXEC flow.Log 'TRACE', 'Creating Execution'

  EXEC SSISDB.[catalog].create_execution
      @package_name = @PackageName
    , @project_name = @ProjectName
    , @folder_name = @FolderName
    , @use32bitruntime = 1
    , @reference_id = @ReferenceID
    , @execution_id = @ExecutionID OUTPUT
    ;

  EXEC flow.Log 'TRACE', 'SSIS Execution ID = :1:, setting parameters.', @ExecutionID

  -- Wait for the SSIS package to finish running
  EXEC SSISDB.[catalog].set_execution_parameter_value
      @ExecutionID
    , @object_type = 50
    , @parameter_name = N'SYNCHRONIZED'
    , @parameter_value = 1
  ;

  EXEC flow.Log 'TRACE', 'SSIS Execution set to run as synchronized', @ExecutionID

  -- Set FlowID
  EXEC SSISDB.[catalog].set_execution_parameter_value
      @ExecutionID
    , @object_type = 30
    , @parameter_name = N'FlowID'
    , @parameter_value = @FlowID
  ;
  EXEC flow.Log 'TRACE', 'FlowID set to :1:', @FlowID;
   
  -- The actual execution
  EXEC SSISDB.[catalog].start_execution @ExecutionID;

  -- Retrieve the status
  SELECT
      @Status = [status]
    , @StatusDescription = 
        CASE [status]
          WHEN 1 THEN 'Created'
          WHEN 2 THEN 'Running'
          WHEN 3 THEN 'Canceled'
          WHEN 4 THEN 'Failed'
          WHEN 5 THEN 'Pending'
          WHEN 6 THEN 'Ended unexpectedly'
          WHEN 7 THEN 'Succeeded'
          WHEN 8 THEN 'Stopping'
          WHEN 9 THEN 'Completed'
        END
  FROM SSISDB.[catalog].executions
  WHERE execution_id = @ExecutionID
  ;

  EXEC flow.Log 'DEBUG', 'Execution ended, status = ":1:"', @StatusDescription;

  IF @Status IN (4, 6)
  BEGIN
    EXEC flow.Log 'WARN', 'Package failed, see SSIS log for details (execution id :1:)', @ExecutionID;
    THROW 51000, 'SSIS Package failed', 1;
  END

  EXEC flow.Log 'DEBUG', 'Execution successful.'

  EXEC flow.Log 'TRACE', 'Leaving setup.Run_ExecuteSSISPackage'
END
