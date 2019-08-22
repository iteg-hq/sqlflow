CREATE PROCEDURE test.RunAll
AS
DECLARE @RC BIT;
DECLARE @TestSP SYSNAME
DECLARE @Passed INT = 0;
DECLARE @Failed INT = 0;

DECLARE test_cursor
CURSOR FOR
SELECT s.name + '.' + p.name
FROM sys.procedures AS p
INNER JOIN sys.schemas AS s
  ON s.schema_id = p.schema_id
WHERE s.name = 'test'
  AND p.name != 'RunAll'
ORDER BY 1
;

OPEN test_cursor

FETCH NEXT FROM test_cursor INTO @TestSP
WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC [$(SQLFlow)].flow.Log 'INFO', 'Running test: :1:', @TestSP;
  EXEC @RC = @TestSP;
  IF @RC = 0
  BEGIN
    EXEC [$(SQLFlow)].flow.Log 'ERROR', 'Test failed: :1:', @TestSP;
    SET @Failed = @Failed + 1;
  END
  ELSE IF @RC = 1
  BEGIN
    EXEC [$(SQLFlow)].flow.Log 'INFO', 'Test passed: :1:', @TestSP
    SET @Passed = @Passed + 1;
  END
  FETCH NEXT FROM test_cursor INTO @TestSP;
END
CLOSE test_cursor
DEALLOCATE test_cursor

PRINT 'Passed: ' + CAST(@Passed AS NVARCHAR(10));
PRINT 'Failed: ' + CAST(@Failed AS NVARCHAR(10));
