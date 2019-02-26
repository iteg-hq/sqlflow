CREATE PROCEDURE flow.AddAction
    @ActionCode NVARCHAR(200)
  , @ResultingStatusCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'AddAction [:1:], [:2:]', @ActionCode, @ResultingStatusCode;

DECLARE @StatusCode NVARCHAR(200) = flow_internals.GetParent(@ActionCode);
DECLARE @ActionName NVARCHAR(200) = flow_internals.GetChild(@ActionCode)
DECLARE @FullResultingStatusCode NVARCHAR(200) = flow_internals.GetParent(@StatusCode) +'.'+ @ResultingStatusCode;

-- If no changes are needed, return
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowAction AS a
    WHERE StatusCode = @StatusCode
      AND ActionCode = @ActionName
      AND ResultingStatusCode = @FullResultingStatusCode
  )
  RETURN

-- Forward definition of resulting status
EXEC flow.AddStatus @StatusCode;
EXEC flow.AddStatus @FullResultingStatusCode;

-- If the action exists and the Resulting Status Code is different, update it
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowAction AS a
    WHERE StatusCode = @StatusCode
      AND ActionCode = @ActionName
  )
BEGIN
  UPDATE flow_internals.FlowAction
  SET ResultingStatusCode = @FullResultingStatusCode
  WHERE StatusCode = @StatusCode
    AND ActionCode = @ActionName
  ;

  EXEC flow.Log 'INFO', 'Updated resulting status on [:1:] (:2:)', @ActionCode, @ResultingStatusCode;
  RETURN;
END

-- If the action does not exist, add it
INSERT INTO flow_internals.FlowAction (
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
