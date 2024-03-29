CREATE TABLE flow_internals.FlowParameter (
    FlowID INT NOT NULL
  , ParameterName NVARCHAR(50) NOT NULL
  , ParameterValue NVARCHAR(MAX) NOT NULL
  , CONSTRAINT PK_FlowParameter PRIMARY KEY (FlowID, ParameterName)
  , CONSTRAINT FK_FlowParameter_FlowID FOREIGN KEY (FlowID) REFERENCES flow_internals.Flow (FlowID)
)
