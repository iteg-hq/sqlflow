CREATE TABLE internal.Lock (
    LockCode NVARCHAR(100) NOT NULL
  , ParentLockCode NVARCHAR(100) NULL
  , HeldByFlowID INT NULL
  , LockDepth INT NOT NULL
  , CONSTRAINT PK_Lock PRIMARY KEY (LockCode)
  , CONSTRAINT FK_Lock_ParentLockCode FOREIGN KEY (ParentLockCode) REFERENCES internal.Lock (LockCode)
  , CONSTRAINT FK_Lock_FlowID FOREIGN KEY (HeldByFlowID) REFERENCES internal.Flow (FlowID)
  )
;