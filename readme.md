# SQLFlow - a flow manager written in SQL #

SQLFlow is a framework for automatically and safely executing your SQL Server stored procedures (and SSIS packages) 

SQLFlow hosts your business code by letting you associate it with a flow *status*: The procedure that loads your data attached to the "Running" status, the one that notifies an operator to the "Failed" status, the one that rolls the load back to the "Rollback Running" status, and so on. When a new status is entered, the associated code is run.

*Actions* define transitions between statuses and thus provide an abstract way of invoking your code: SQL Agent jobs can be set up to perform "Start" actions on any type of flow as they reach the head of the queue. Human operators can perform "Rollback" actions without having to know how the rollback works. SQLFlow itself can perform "Fail" actions to take appropriate action when something fails.

In addition, SQLFlow provides a framework for storing parameter values needed by flows, a single procedure for logging and a simple locking system that lets flows block one another while running or until failed flows are handled.

- **Logging**: SQLFlow provides a single SP for logging.
- **Locking**: A simple locking mechanism lets you specify that only one flow can be running at a time, or that failed flows should block new flows from running.
- **Error handling**: All errors are caught (and logged) and error handling code can be registered in SQLFlow and run automatically.
- **Flow configuration in one place**: All configuration info and parameters are kept in one place.
- **Automated rollbacks and reruns**: Code for application management tasks (like rolling back failed flows) can be registered with SQLFlow and performed automatically or by using a common interface.
- **Separation of invocation and execution**: In SQLFlow, a user or application with limited privileges may start a flow that will then run with elevated privileges.
- **Seamless integration of SSIS packages and stored procedures**: Flows from both types of components, or add new types.
- **Notifications via webhook**: SQLFlow makes it easy to notify operators via webhooks.

~~~mssql
> EXEC flow_test.Test -- Add a new flow to the work queue

[29][INFO] Created new FlowID: 29
[29][INFO] Entered status [Test:TestFlow.New]

> EXEC SQLFlow.flow.Main 'System' -- Worker process picks up the next flow from the queue

[29][INFO] Entered status [Test:TestFlow.Running]
[29][INFO] Doing stuff
[29][ERROR] Divide by zero error encountered.
[29][INFO] Entered status [Test:TestFlow.Failed]
[29][INFO] Flow execution done. Final status: [Test:TestFlow.Failed].

> EXEC SQLFlow.flow.Do 29, 'Rollback' -- Operator rolls back failed run

[29][INFO] Entered status [Test:TestFlow.RollbackRunning]
[29][INFO] Rolling stuff back
[29][INFO] Entered status [Test:TestFlow.RollbackCompleted]

> EXEC SQLFlow.flow.Do 29, 'Restart' -- And reruns manually

[29][INFO] Entered status [Test:TestFlow.Running]
[29][INFO] Doing stuff
[29][INFO] Entered status [Test:TestFlow.Complete]
~~~

SQLFlow consists of the following components:

- [SQLFlow](/SQLFLow/Documentation/readme.md): The flow manager itself, including a SQL interface.
- [SQLFlow.NET](/SQLFlow.NET/Documentation/readme.md): A .NET wrapper for the SQLFlow interface.
- [SQLFlowTail](/SQLFlowTail/Documentation/readme.md): A command line application that displays log messages from SQLFlow
- [SQLFlowTest](/SQLFlowTest/Documentation/readme.md): A sample database project using SQLFlow.

