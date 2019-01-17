CREATE TABLE internals.FlowRelationship (
    FlowID INT NOT NULL
  , RelatedFlowID INT NOT NULL
  , RelationshipTypeCode NVARCHAR(50) NOT NULL
  , IsLocking BIT NOT NULL
  , CONSTRAINT PK_FlowRelationship PRIMARY KEY (FlowID, RelatedFlowID)
  , CONSTRAINT FK_FlowRelationship_FlowID FOREIGN KEY (FlowID) REFERENCES internals.Flow (FlowID)
  , CONSTRAINT FK_FlowRelationship_RelatedFlowID FOREIGN KEY (RelatedFlowID) REFERENCES internals.Flow (FlowID)
)
