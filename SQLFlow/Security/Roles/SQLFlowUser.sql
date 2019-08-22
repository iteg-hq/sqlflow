CREATE ROLE SQLFlowUser;

GO

GRANT CONNECT TO SQLFlowUser;

GO

-- Every client application that uses SQLFLow will have an associated
-- user that has permission to execute the packages of that application.
-- This user will call Main in order to execute the packages. From 
-- there, Log would be available through ownership chaining, so 
-- until flow items need to be dispatched, EXECUTE on Main would give us 
-- sufficient permissions through ownership chaining.
-- However, the (Execute{StoredProcedure|SSISPackage} etc.) SP's call
-- stored procedures and other packages in ways that break the ownership
-- chain, so when packages come back to SQLFlow and call e.g. Log,
-- they lack permissions.

GRANT EXECUTE TO SQLFlowUser;

GO

GRANT SELECT TO SQLFlowUser;
