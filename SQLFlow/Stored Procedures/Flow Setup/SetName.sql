CREATE PROCEDURE flow.SetName
    @FlowID INT
  , @NamePart1 NVARCHAR(100) = NULL
  , @NamePart2 NVARCHAR(100) = NULL
  , @NamePart3 NVARCHAR(100) = NULL
  , @NamePart4 NVARCHAR(100) = NULL
  , @NamePart5 NVARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  
  UPDATE internals.Flow
  SET [Name] = COALESCE(@NamePart1, '')
             + COALESCE(@NamePart2, '')
             + COALESCE(@NamePart3, '')
             + COALESCE(@NamePart4, '')
             + COALESCE(@NamePart5, '')
  WHERE FlowID = @FlowID
  ;
END
