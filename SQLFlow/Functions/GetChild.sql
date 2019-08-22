CREATE FUNCTION internal.GetChild (@Name NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
  IF @Name NOT LIKE '%.%' RETURN NULL
  RETURN RIGHT(@Name, CHARINDEX('.', REVERSE(@Name))-1);
END
;