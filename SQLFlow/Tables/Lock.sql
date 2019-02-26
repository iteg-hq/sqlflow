CREATE TABLE flow_internals.Lock (
    LockCode NVARCHAR(200) NOT NULL
  , ParentLockCode NVARCHAR(200) NULL
  , HeldByFlowID INT NULL
  , LockDepth INT NOT NULL
  , CONSTRAINT PK_Lock PRIMARY KEY (LockCode)
  , CONSTRAINT FK_Lock_ParentLockCode FOREIGN KEY (ParentLockCode) REFERENCES flow_internals.Lock (LockCode)
  , CONSTRAINT FK_Lock_FlowID FOREIGN KEY (HeldByFlowID) REFERENCES flow_internals.Flow (FlowID)
  )
;