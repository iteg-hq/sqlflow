CREATE TABLE flow_internals.FlowType (
    TypeCode NVARCHAR(200) NOT NULL
  , ExecutionGroupCode NVARCHAR(50) NOT NULL CONSTRAINT DF_FlowType_ExecutionGroupCode DEFAULT('Ungrouped')
  , InitialStatusCode NVARCHAR(200) NULL
  , CONSTRAINT PK_FlowType PRIMARY KEY (TypeCode)
  , CONSTRAINT FK_FlowType_FlowStatusCode FOREIGN KEY (InitialStatusCode) REFERENCES flow_internals.FlowStatus (StatusCode)
)
