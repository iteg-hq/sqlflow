CREATE TABLE internals.FlowStatus (
    TypeCode NVARCHAR(200) NOT NULL
  , StatusCode NVARCHAR(200) NOT NULL
  , RequiredLockCode NVARCHAR(200) NULL
  , ProcedureName NVARCHAR(500) NULL
  , CONSTRAINT PK_FlowStatus PRIMARY KEY (StatusCode)
  , CONSTRAINT FK_FlowStatus_FlowType FOREIGN KEY (TypeCode) REFERENCES internals.FlowType (TypeCode)
  , CONSTRAINT FK_FlowStatus_Lock FOREIGN KEY (RequiredLockCode) REFERENCES internals.Lock (LockCode)
  )
;
