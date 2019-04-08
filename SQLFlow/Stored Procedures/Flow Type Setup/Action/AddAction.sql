CREATE PROCEDURE flow.AddAction
    @TypeCode NVARCHAR(200)
  , @StatusCode NVARCHAR(200)
  , @ActionCode NVARCHAR(200)
  , @ResultingStatusCode NVARCHAR(200)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'AddAction [:1:], [:2:]', @ActionCode, @ResultingStatusCode;

-- If no changes are needed, return
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowAction AS a
    WHERE TypeCode = @TypeCode
      AND StatusCode = @StatusCode
      AND ActionCode = @ActionCode
      AND ResultingStatusCode = @ResultingStatusCode
  )
  RETURN

-- Forward definition of resulting status
EXEC flow.AddStatus @TypeCode, @StatusCode;
EXEC flow.AddStatus @TypeCode, @ResultingStatusCode;

-- If the action exists and the Resulting Status Code is different, update it
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowAction AS a
    WHERE TypeCode = @TypeCode
      AND StatusCode = @StatusCode
      AND ActionCode = @ActionCode
  )
BEGIN
  UPDATE flow_internals.FlowAction
  SET ResultingStatusCode = @ResultingStatusCode
  WHERE TypeCode = @TypeCode
    AND StatusCode = @StatusCode
    AND ActionCode = @ActionCode
  ;

  EXEC flow.Log 'INFO', 'Updated resulting status on [:1:] (:2:)', @ActionCode, @ResultingStatusCode;
  RETURN;
END

-- If the action does not exist, add it
INSERT INTO flow_internals.FlowAction (
    TypeCode
  , StatusCode
  , ActionCode
  , ResultingStatusCode
  )
SELECT
    @TypeCode
  , @StatusCode
  , @ActionCode
  , @ResultingStatusCode
;

EXEC flow.Log 'INFO', 'Added new action [:1:.:2:.:3:] (-> [:4:])', @TypeCode, @StatusCode, @ActionCode, @ResultingStatusCode;
