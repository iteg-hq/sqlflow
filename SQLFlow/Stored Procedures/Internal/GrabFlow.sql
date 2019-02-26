CREATE PROCEDURE flow_internals.GrabFlow @FlowID INT
AS
EXEC sp_set_session_context N'FlowID', @FlowID;
;
