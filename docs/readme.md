# SQLFlow - a flow manager for SQL Server #

SQLFlow provides a way to organise and execute the stored procedures (and SSIS packages) that make up SQL-based solutions not driven by a front-end. It does using *flows*: a flow has a *status* (e.g. New, Running, Failed) and can move to different statuses using *actions* (e.g. Start, Fail, Complete). 

The procedure that loads your data attached to the "Running" status, the one that notifies an operator to the "Failed" status, the one that rolls the load back to the "Rollback Running" status, and so on. When a new status is entered, the associated code is run.

Actions define transitions between statuses and provide an abstract way of invoking your code: SQL Agent jobs perform "Start" actions on any type of startable flow as they reach the head of the queue. Human operators perform "Rollback" actions without having to know how the rollback works. SQLFlow performs "Fail" actions to take appropriate action when something fails.

In addition, SQLFlow provides a framework for storing parameter values needed by flows, a single procedure for logging and a simple locking system that lets flows block one another while running or until a failed flow is handled.

## Features

- **Error handling, rollbacks and reruns**: All errors are caught (and logged) and error handling code can be registered in SQLFlow. Code for application management tasks (like rolling back failed flows) can be registered with SQLFlow and performed automatically or by using a common interface.
- **Logging**: SQLFlow provides a single stored procedure for logging.
- **Locking**: A simple locking mechanism lets you specify that only one flow of a certain type can be running at a time, or that failed flows should block new flows from running.
- **Flow configuration in one place**: All configuration info and parameters are kept in one place.
- **Separation of invocation and execution**: A user or application with limited privileges can request and configure a flow that will then run with elevated privileges.

## Example

~~~mssql
> EXEC SQLFlow.flow_test.Test -- Add a new flow to the work queue.

[29][INFO] Created new FlowID: 29
[29][INFO] Entered status [Test:TestFlow.New]

> EXEC SQLFlow.flow.Main 'Test' -- Worker process picks up the flow from the queue

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

> EXEC SQLFlow.flow.Do 29, 'Rollback' -- Attempt to roll back completed flow

[29][ERROR] Invalid action: [Rollback]
Msg 51000, Level 16, State 1, Procedure SQLFlow.flow.Do, Line 28 [Batch Start Line 29]
Invalid action

~~~

SQLFlow consists of the following components:

- [SQLFlow](#sqlflow): The flow manager itself, including a SQL interface.
- SQLFlow.NET: A .NET wrapper for the SQLFlow interface.
- SQLFlowTail: A command line application that displays log messages from SQLFlow


# SQLFlow #

## Installation

### Download

First, download the following installation files from https://github.com/iteg-hq/sqlflow/releases/latest:

- SQLFlow.dacpac
- master.dacpac
- SQLFlowTail.exe
- SQLFlowDotNet.dll

Place the files in the same folder.

### Install

SQLFlow can be now be installed like this:

- Right-click "Databases" and select "Deploy Data-tier Application..."
- Browse to `SQLFlow.dacpac` and click "Open" and "Next"

The wizard will warn that it cannot detect drift, and will also ask to run the PostDeployment script.

*Note: You can automate installation and upgrades of SQLFlow using Microsoft's [SqlPackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage) tool.*

### Hello World!

Start `SQLFlowTail.exe`. This should show you a console window with some messages from the installation.

Now, try connecting to the SQLFlow database in Management Studio and running:

```mssql
EXEC flow.Log 'INFO', 'Hello World!';
```

This message should appear in the log.

### Upgrading

To upgrade SQLFlow, download the files as above, then:

- Right-click the new database, select "Tasks" and "Upgrade Data-tier Application..."
- Browse to `SQLFlow.dacpac` and click "Open" and "Next"

## API ##

The procedures and functions in the `flow` schema make up the API.

### Flow Type ###

All setup calls are idempotent, and can be called as part of a deployment.

#### AddType

Adds a new flow type, optionally setting the Execution Group Code and the Initial Status Code.

If the flow does not exists, and no ExecutionGroupCode is provided, the flow will be added to the 'Ungrouped' execution group.

If the flow does not exists, and no InitialStatusCode is provided, the initial status 'New' will be used. This status will be created if it does not exist.

*Parameters:*

- TypeCode: Code identifying the flow type.
- ExecutionGroupCode: Passed to SetExecutionGroup if non-NULL and non-blank.
- InitialStatusCode: Passed to SetInitialStatus.

#### SetExecutionGroup

Sets the execution group of a flow type, which applies to all instances of the flow. The execution group partitions the work queue into sub-queues.

*Parameters:*

- TypeCode: Code identifying the flow type.
- ExecutionGroupCode: Identifies the execution group that instances of the flow type should belong to. If this is blank or NULL, no changed are made.

#### SetInitialStatus

Sets the initial status of a flow type. If the InitialStatusCode argument is blank or NULL, the initial status 'New' will be used (and created, if necessary).

*Parameters:*

- TypeCode: Code identifying the flow type.
- InitialStatusCode: Sets the initial status of a flow type. If NULL or blank, defaults to 'New'

### Status

At any point in time, a flow is in a specific status, e.g. New, Running, Failed, Cancelled, Completed etc.

#### AddStatus

Adds a new status to a flow, optionally assigning a required lock and/or a procedure to be run when entering the status.

*Parameters:*

- TypeCode: Code identifying the flow type.
- StatusCode: Code identifying the status.
- RequiredLockCode (optional): Passed to SetStatusLock if provided.
- ProcedureName (optional): Passed to SetStatusProcedure if provided.

#### SetStatusLock

Specify a lock that is required to enter a status.

*Parameters:*

- TypeCode: Code identifying the flow type.
- StatusCode: Code identifying the status.
- RequiredLockCode: The lock code of the required lock.

####  SetStatusProcedure

Specify a stored procedure to be run when flows of a certain type enter a specific status.

*Parameters:*

- TypeCode: Code identifying the flow type.
- StatusCode: Code identifying the status.
- ProcedureName: The fully qualified name of the procedure.

### Locking

Locks are attached to statuses to exclude other flows from entering statuses that require the same lock. Locks are hierarchically arranged, with dotted names denoting their place in the hierarchy: Holding lock `Parent` implies holding `Parent.Child`, and holding `Parent.Child` prevents anyone from acquiring `Parent`. Holding `Parent.Sibling` does not prevent anyone from holding `Parent.Child`, but does prevent anyone from acquiring `Parent`.

Locks can always be de-escalated: If you hold `Parent`, you can always release it and acquire `Parent.Child`.

#### AddLock

Add a new lock. If a lock with the code already exists, this does nothing. Any implied but non-existent parent locks will be created.

*Parameters:*

- LockCode: The dotted name of the lock.

Note: Called by AddStatus or SetStatusLock

### Actions

#### AddAction

Add a new action to a flow type. An action is a transition between two flow statuses and is identified by a code.

*Parameters:*

- TypeCode: Code identifying the flow type.
- StatusCode: Code identifying the status.
- ActionCode: Code identifying the action.
- ResultingStatusCode: Code identifying the resulting status.

#### DropAction 

Remove an action from a flow type. 

*Parameters:*

- TypeCode: Code identifying the flow type.
- StatusCode: Code identifying the status.
- ActionCode: Code identifying the action.

#### DropActions 

Remove all actions from the flow type.

*Parameters:*

- TypeCode: Code identifying the flow type.

### Flow Instances ###

#### **NewFlow **

Create a new flow instance.

*Parameters:*

- TypeCode: Code identifying the type of the flow.
- FlowID OUTPUT: The ID of the newly created flow.

#### SetParameterValue 

Set a parameter value for a flow.

*Parameters:*

- FlowID: The ID of the flow.
- Name: The name of the parameter.
- Value: The parameter value. Will be converted to a string before being stored.

#### GetParameterValue()

Set a parameter value for a flow.

*Parameters:*

- FlowID: The ID of the flow.
- Name: The name of the parameter.

### Operations

#### Help

Display information about a flow.

*Parameters:*

- FlowID: The ID of the flow.

#### Main

Empty a sub-queue (or keep until the next flow in the queue is locked).,

Worker procedure, meant to be executed by e.g. a SQL Agent job at regular intervals.

*Parameters:*

- ExecutionGroupCode: Code identifying the sub-queue (defaults to 'Ungrouped')
- ActionCodeActionCode: Code identifying the action to perform (defaults to 'Start')

(Calls `ExecuteNext` until it returns 1.)

#### ExecuteNext

Find the next flow from a sub-queue that:

1.  is not locked and
2. can perform the requested action

and execute it. Return 0 if a flow was executed, 1 if the queue was empty.

*Parameters:*

- ExecutionGroupCode: Code identifying the sub-queue (defaults to 'Ungrouped')
- ActionCode: Code identifying the action to perform (defaults to 'Start')

(Finds the flow, then delegates to `Do`)

#### Do

Perform an action on a flow.

*Parameters:*

- FlowID: The ID of the flow.
- ActionCode: Code indentifying the action to perform.

Fails if the action is not defined for the current status of the flow.