CREATE TABLE flow_internals.Flow (
    FlowID INT IDENTITY(1,1) NOT NULL
  , ExecutionGroupCode NVARCHAR(100) NOT NULL CONSTRAINT DF_Flow_ExecutionGroupCode DEFAULT ('Ungrouped')
  , TypeCode NVARCHAR(100) NOT NULL
  , StatusCode NVARCHAR(100) NULL
  , CreatedAt DATETIME2(7) NOT NULL CONSTRAINT DF_Flow_CreatedAt DEFAULT(SYSDATETIME())
  , ExecutedAt DATETIME2(7) NULL
  , CreatedByLogin NVARCHAR(128) NULL CONSTRAINT DF_Flow_CreatedByLogin DEFAULT(SUSER_NAME())
  , CONSTRAINT PK_Flow PRIMARY KEY (FlowID)
  , CONSTRAINT FK_Flow_FlowType FOREIGN KEY (TypeCode) REFERENCES flow_internals.FlowType (TypeCode)
  , CONSTRAINT FK_Flow_FlowStatus FOREIGN KEY (TypeCode, StatusCode) REFERENCES flow_internals.FlowStatus (TypeCode, StatusCode)
)
