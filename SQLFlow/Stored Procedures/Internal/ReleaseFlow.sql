CREATE PROCEDURE internals.ReleaseFlow
AS
EXEC sp_set_session_context N'FlowID', NULL;
;
