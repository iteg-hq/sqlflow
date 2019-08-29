CREATE PROCEDURE flow.LEAVE
    @EntryText NVARCHAR(4000)
  , @Value1 NVARCHAR(4000) = NULL
  , @Value2 NVARCHAR(4000) = NULL
  , @Value3 NVARCHAR(4000) = NULL
  , @Value4 NVARCHAR(4000) = NULL
  , @Value5 NVARCHAR(4000) = NULL
AS
EXEC flow.Log 'LEAVE', @EntryText, @Value1, @Value2, @Value3, @Value4, @Value5