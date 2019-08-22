CREATE TABLE internal.FlowType (
    TypeCode NVARCHAR(100) NOT NULL
  , ExecutionGroupCode NVARCHAR(100) NOT NULL CONSTRAINT DF_FlowType_ExecutionGroupCode DEFAULT('Ungrouped')
  , InitialStatusCode NVARCHAR(100) NULL
  , CONSTRAINT PK_FlowType PRIMARY KEY (TypeCode)
  , CONSTRAINT FK_FlowType_FlowStatusCode FOREIGN KEY (TypeCode, InitialStatusCode) REFERENCES internal.FlowStatus (TypeCode, StatusCode)
)
