CREATE TABLE flow_internals.FlowAction (
    StatusCode NVARCHAR(200) NOT NULL
  , ActionCode NVARCHAR(200) NOT NULL
  , ResultingStatusCode  NVARCHAR(200) NOT NULL

  , CONSTRAINT PK_Action PRIMARY KEY (StatusCode, ActionCode)
  , CONSTRAINT FK_FlowAction_FlowStatusCode FOREIGN KEY (StatusCode) REFERENCES flow_internals.FlowStatus (StatusCode)
  , CONSTRAINT FK_FlowAction_ResultingFlowStatusCode FOREIGN KEY (ResultingStatusCode) REFERENCES flow_internals.FlowStatus (StatusCode)
  )
;