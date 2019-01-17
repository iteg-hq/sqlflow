CREATE PROCEDURE flow.AddAction
    @ActionCode NVARCHAR(200)
  , @ResultingStatusCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @StatusCode NVARCHAR(200) = internals.GetParent(@ActionCode);
DECLARE @ActionName NVARCHAR(200) = internals.GetChild(@ActionCode)
DECLARE @FullResultingStatusCode NVARCHAR(200) = internals.GetParent(@StatusCode) +'.'+ @ResultingStatusCode;

-- Forward definition of resulting status
IF @FullResultingStatusCode NOT IN (
    SELECT StatusCode 
    FROM internals.FlowStatus
  )
  BEGIN
    EXEC flow.AddStatus @FullResultingStatusCode;
  END

-- If the action is new,
IF EXISTS (
    SELECT 1
    FROM internals.FlowAction AS a
    WHERE StatusCode = @StatusCode
      AND ActionCode = @ActionName
  )
BEGIN
  UPDATE internals.FlowAction
  SET ResultingStatusCode = @FullResultingStatusCode
  WHERE ActionCode = @ActionName
  ;

  EXEC flow.Log 'INFO', 'Updated resulting status on :1: (:2:)', @ActionCode, @ResultingStatusCode;
  RETURN;
END



INSERT INTO internals.FlowAction (
    StatusCode
  , ActionCode
  , ResultingStatusCode
  )
SELECT
    @StatusCode
  , @ActionName
  , @FullResultingStatusCode
;

EXEC flow.Log 'INFO', 'Added new action [:1:] (-> [:2:])', @ActionCode, @ResultingStatusCode;
