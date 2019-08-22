CREATE FUNCTION internal.GetParent (@Name NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
  IF @Name NOT LIKE '%.%' RETURN NULL
  RETURN LEFT(@Name, LEN(@Name) - CHARINDEX('.', REVERSE(@Name)));
END
;