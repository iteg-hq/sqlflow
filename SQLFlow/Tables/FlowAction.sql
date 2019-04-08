CREATE TABLE flow_internals.FlowAction (
    TypeCode NVARCHAR(100) NOT NULL
  , StatusCode NVARCHAR(100) NOT NULL
  , ActionCode NVARCHAR(100) NOT NULL
  , ResultingStatusCode  NVARCHAR(100) NOT NULL

  , CONSTRAINT PK_Action PRIMARY KEY (TypeCode, StatusCode, ActionCode)
  , CONSTRAINT FK_FlowAction_FlowStatusCode FOREIGN KEY (TypeCode, StatusCode) REFERENCES flow_internals.FlowStatus (TypeCode, StatusCode)
  , CONSTRAINT FK_FlowAction_ResultingFlowStatusCode FOREIGN KEY (TypeCode, ResultingStatusCode) REFERENCES flow_internals.FlowStatus (TypeCode, StatusCode)
  )
;