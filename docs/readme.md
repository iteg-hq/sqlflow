# SQLFlow - a flow manager for SQL Server #



SQLFlow hosts your "business" code by letting you associate it with a flow *status*: The procedure that loads your data attached to the "Running" status, the one that notifies an operator to the "Failed" status, the one that rolls the load back to the "Rollback Running" status, and so on. When a new status is entered, the associated code is run.

*Actions* define transitions between statuses and thus provide an abstract way of invoking your code: SQL Agent jobs can be set up to perform "Start" actions on any type of flow as they reach the head of the queue. Human operators can perform "Rollback" actions without having to know how the rollback works. SQLFlow itself can perform "Fail" actions to take appropriate action when something fails.

In addition, SQLFlow provides a framework for storing parameter values needed by flows, a single procedure for logging and a simple locking system that lets flows block one another while running or until failed flows are handled.

## Features

- **Logging**: SQLFlow provides a single SP for logging.
- **Locking**: A simple locking mechanism lets you specify that only one flow can be running at a time, or that failed flows should block new flows from running.
- **Error handling**: All errors are caught (and logged) and error handling code can be registered in SQLFlow and run automatically.
- **Flow configuration in one place**: All configuration info and parameters are kept in one place.
- **Automated rollbacks and reruns**: Code for application management tasks (like rolling back failed flows) can be registered with SQLFlow and performed automatically or by using a common interface.
- **Separation of invocation and execution**: In SQLFlow, a user or application with limited privileges may start a flow that will then run with elevated privileges.
- **Seamless integration of SSIS packages and stored procedures**: Flows from both types of components, or add new types.
- **Notifications via webhook**: SQLFlow makes it easy to notify operators via webhooks.

## Example

~~~mssql
> EXEC SQLFlowTest.flow_test.Test -- Add a new flow to the work queue.

[29][INFO] Created new FlowID: 29
[29][INFO] Entered status [Test:TestFlow.New]

> EXEC SQLFlow.flow.Main 'System' -- Worker process picks up the flow from the queue

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

> EXEC SQLFlow.flow.Do 29, 'Rollback' -- Roll back completed flow

[29][ERROR] Invalid action: [Rollback]
Msg 51000, Level 16, State 1, Procedure SQLFlow.flow.Do, Line 28 [Batch Start Line 29]
Invalid action

~~~

SQLFlow consists of the following components:

- [SQLFlow](/SQLFlow/Documentation/readme.md): The flow manager itself, including a SQL interface.
- [SQLFlow.NET](/SQLFlow.NET/Documentation/readme.md): A .NET wrapper for the SQLFlow interface.
- [SQLFlowTail](/SQLFlowTail/Documentation/readme.md): A command line application that displays log messages from SQLFlow
- [SQLFlowTest](/SQLFlowTest/Documentation/readme.md): A sample database project using SQLFlow.


# SQLFlow #

## Quickstart ##

This tutorial describes installing SQLFlow to a local instance of SQL Server, for development purposes. In a production environment, you'll want to pay more attention to security.

### Installation ###

First, fetch the ()[https://github.com/grit-solutions/sqlflow/releases/latest]

First, you'll need to install the public key used to sign the SQLCLR assembly deployed by SQLFlow. This cannot be done in Management Studio.

- Grant the SQL Server service user (`NT Service\MSSQLSERVER`) read access to to the `SQLFlowDevelopment.pub` file.

- In Management Studio, start a new query in `master` and import the public key by running:

  ~~~mssql
  CREATE ASYMMETRIC KEY SQLFlowDevelopment FROM FILE = 'C:\path\to\SQLFlowDevelopment.dll';
  ~~~

- Create a new login for the key: "Security" > Right-click "Logins" and select "New Login..."
- Provide a name for the login (e.g. `SQLFlowKey`).
- Select "Mapped to assymmetric key", select "SQLFlowDevelopment"
- Go to the "Securables" page, click "Search", select the server, click OK
- Check "Grant" under "Unsafe Assembly".

Next, install SQLFlow:

- Right-click "Databases" and select "New Database..."
- Name the new database `SQLFlow`.
- Right-click the new database, select "Tasks" and "Upgrade Data-tier Application..."
- Browse to `SQLFlow.dacpac`
- (The wizard will warn that it cannot detect drift, and will ask to run the PostDeployment script.)

Finally, start the log viewer by doubleclicking `SQLFlowTail.exe`. (If you've installed SQLFlow non-locally or to a database,  other than `SQLFlow` you'll need to supply a connection string as a command line argument. For more information on the SQLFlowTail.exe, see [TODO].)

You should see some messages from the installation. Now, try connecting to the SQLFlow database and doing:

```mssql
EXEC flow.Log 'INFO', 'Hello World!';
```

This message should appear in the log.

## API ##

- *Flow Type*
  - `AddType` @TypeCode, [@ExecutionGroupCode], [@InitialStatusCode]
  - `SetExecutionGroup` @TypeCode, [@ExecutionGroupCode]
  - `SetInitialStatus` @TypeCode, [@InitialStatusCode]
- *Status*
  - `AddStatus` @StatusCode, [@RequiredLockCode], [@ProcedureName]
  - `SetStatusLock` @StatusCode, @RequiredLockCode
  - `SetStatusProcedure` @StatusCode, [@ProcedureName]
- *Actions*
  - `AddAction` @ActionCode, @ResultingStatusCode
  - `DropAction` @ActionCode
  - `DropActions` @TypeCode
- *Locking*
  - `AddLock` @LockCode
- *Flow Instances*
  - `NewFlow` @TypeCode, @FlowID (OUTPUT)
  - `Do` @FlowID, @ActionCode

### Flow Type Setup ###

All setup calls are idempotent, and can be called as part of a deployment.

#### Flow Types ####

A flow type contains at least one status that instances of the flow can be in
(e.g. "New", "Running", "Completed", "Rolling back"). Flow types are required
to define an initial status that new instances of the flow

**AddType @TypeCode, [@ExecutionGroupCode], [@InitialStatusCode]**: Adds a new flow type named @TypeCode. If @ExecutionGroupCode and @InitialStatusCode are provided, they will be passed to SetExecutionGroup and SetInitialStatus, respectively. If not, execution group will be left unchanged.

If the flow does not exists, and no @ExecutionGroupCode is provided, the flow will be added to the 'Ungrouped' execution group.

If the flow does not exists, and no @InitialStatusCode is provided, an initial status '<@TypeCode>.New' will be used. This status will be provided if it does not exist.

**SetExecutionGroup @TypeCode, [@ExecutionGroupCode]**: Sets the execution group of a flow type. If @ExecutionGroupCode is blank or NULL, no changed are made. Execution groups are mandatory and cannot be dropped.

**SetInitialStatus @TypeCode, [@InitialStatusCode]**: Sets the initial status of a flow type. If @InitialStatusCode is blank or NULL, the initial status '<@TypeCode>.New' will be used (and created, if necessary).

#### Status

At any point in time, a flow is in a specific status, e.g. new, running, running, failed, cancelled, completed etc.

**AddStatus @StatusCode, [@RequiredLockCode], [@ProcedureName]**: Add a new status to a flow type, optionally assigning a required lock and/or a procedure to be run when entering the status.

The status code must be prefixed with a valid flow type code. If @RequiredLockCode and/or @ProcedureName are provided, they are passed to SetStatusLock and SetStatusProcedure.

**SetStatusLock @StatusCode, @RequiredLockCode**: Specify a lock that is required to enter a status.

**SetStatusProcedure @StatusCode, [@ProcedureName]**: Specify a procedure to perform when a status is entered.

#### Actions

**AddAction @ActionCode, @ResultingStatusCode**: Add a new action to a flow type. @ActionCode is of the form `Flow.Status.Action`

**DropAction @ActionCode**: Remove an action from a flow type. @ActionCode is of the form `Flow.Status.Action.

**DropActions @TypeCode** : Remove all actions from the flow type with code @TypeCode.

### Flow Instances ###

**NewFlow @TypeCode, @FlowID (OUTPUT)**: Create a new flow instance pf type @TypeCode. The flow ID is returned to the caller.

**SetParameterValue @FlowID, @Name, @Value**: Set a parameter value for a flow.

**[Function] GetParameterValue(@FlowID, @Name)**: Get a parameter value for a flow.

#### Locking ####

Locks are attached to statuses to exclude other flows from entering statuses that require the same lock. Locks are hierarchically arranged, with dotted names denoting their place in the hierarchy: Holding lock `Parent` implies holding `Parent.Child`, and holding `Parent.Child` prevents anyone from acquiring `Parent`. Holding `Parent.Sibling` does not prevent anyone from holding `Parent.Child`.

Locks can always be de-escalated: If you hold `Parent`, you can always release it and acquire `Parent.Child`.

**AddLock @LockCode**: Add a new lock. If a lock with the code already exists, this does nothing. Any implied parent locks will be created.


## Deploying to production ##

If you want to deploy to production, you'll need to sign the assembly using a
key private to you. The `SQLFlowDevelopment.pub`.

Check out the solution, use the Developer Command Prompt to navigate to
`<repo>\SQLFlow`, then do:

~~~
sn -k SQLFlow.snk
~~~

to create a key pair. (`SQLFlow.snk` is the name of the file containing the
key pair used to sign the assemblies. It is not included in the repo.)

There is no reason to store the private part of the key pair on SQL Server
(where it will have to be encrypted with a master key), so extract the public
key:

~~~
sn -p SQLFlow.snk SQLFlow.pub
~~~

before proceeding as above. Note that possession of the key pair in the .snk
file is necessary (but not sufficient) to install unsafe assemblies on the
SQL, so don't distribute it.

At this point, install the public key by following in the steps in the
previous section.

You should now be able to publish to you server directly from Visual Studio
and to package dacpacs for deployment in production environments (where you
will need, again, to install the public key)