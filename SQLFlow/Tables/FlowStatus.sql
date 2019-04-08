CREATE TABLE flow_internals.FlowStatus (
    TypeCode NVARCHAR(100) NOT NULL
  , StatusCode NVARCHAR(100) NOT NULL
  , RequiredLockCode NVARCHAR(100) NULL
  , ProcedureName NVARCHAR(500) NULL
  , Autocomplete BIT NOT NULL DEFAULT 0
  , CONSTRAINT PK_FlowStatus PRIMARY KEY (TypeCode, StatusCode)
  , CONSTRAINT FK_FlowStatus_FlowType FOREIGN KEY (TypeCode) REFERENCES flow_internals.FlowType (TypeCode)
  , CONSTRAINT FK_FlowStatus_Lock FOREIGN KEY (RequiredLockCode) REFERENCES flow_internals.Lock (LockCode)
  )
;
