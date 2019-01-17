CREATE TABLE internals.Flow (
    FlowID INT IDENTITY(1,1) NOT NULL
  , [Name] NVARCHAR(100) NULL
  , ExecutionGroupCode NVARCHAR(20) NOT NULL CONSTRAINT DF_Flow_ExecutionGroupCode DEFAULT ('Ungrouped')
  , TypeCode NVARCHAR(200) NOT NULL
  , StatusCode NVARCHAR(200) NULL
  , SessionID SMALLINT NULL DEFAULT(@@SPID)
  , CreatedAt DATETIME2(7) NOT NULL DEFAULT(SYSDATETIME())
  , ExecutedAt DATETIME2(7) NULL
  , CreateByLogin NVARCHAR(128) NULL DEFAULT(SUSER_NAME())
  , CONSTRAINT PK_Flow PRIMARY KEY (FlowID)
  , CONSTRAINT FK_Flow_FlowType FOREIGN KEY (TypeCode) REFERENCES internals.FlowType (TypeCode)
  , CONSTRAINT FK_Flow_FlowStatus FOREIGN KEY (StatusCode) REFERENCES internals.FlowStatus (StatusCode)
)
