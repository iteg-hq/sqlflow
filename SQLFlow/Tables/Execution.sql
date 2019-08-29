CREATE TABLE flow_internals.Execution (
    ExecutionID INT NOT NULL IDENTITY(1,1)
  , ParentExecutionID INT NULL
  , FlowID INT NULL CONSTRAINT DF_Execution_FlowID DEFAULT (CAST(SESSION_CONTEXT(N'FlowID') AS INT))
  , ExecutableName NVARCHAR(500) NOT NULL
  , ExecutionStartedAt DATETIME2(3) NOT NULL
  , ExecutionEndedAt DATETIME2(3) NULL
  , CONSTRAINT PK_Execution PRIMARY KEY (ExecutionID)
  , CONSTRAINT FK_Execution_Parent FOREIGN KEY (ParentExecutionID) REFERENCES flow_internals.Execution (ExecutionID)
  , CONSTRAINT FK_Execution_FlowID FOREIGN KEY (FlowID) REFERENCES flow_internals.Flow (FlowID)
  )
;