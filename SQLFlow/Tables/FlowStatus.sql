CREATE TABLE internal.FlowStatus (
    TypeCode NVARCHAR(100) NOT NULL
  , StatusCode NVARCHAR(100) NOT NULL
  , RequiredLockCode NVARCHAR(100) NULL
  , ProcedureName NVARCHAR(500) NULL
  , Autocomplete BIT NOT NULL CONSTRAINT DF_FlowStatus_Autocomplete DEFAULT 0
  , CONSTRAINT PK_FlowStatus PRIMARY KEY (TypeCode, StatusCode)
  , CONSTRAINT FK_FlowStatus_FlowType FOREIGN KEY (TypeCode) REFERENCES internal.FlowType (TypeCode)
  , CONSTRAINT FK_FlowStatus_Lock FOREIGN KEY (RequiredLockCode) REFERENCES internal.Lock (LockCode)
  )
;
