CREATE FUNCTION flow.ReadFile(@Path NVARCHAR(MAX), @Encoding NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS EXTERNAL NAME SQLFlow.StoredProcedures.ReadFile
;