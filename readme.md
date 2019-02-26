# SQLFlow #

SQLFlow is a flow manager written in SQL.

  - **Error handling and logging**: All errors are caught and logged to a common log table.
  - **Flow configuration**: All parameters are kept in one place.
  - **Automated ollbacks and reruns**: Code for rolling back and re-scheduling flows may be registered with SQLFlow, so SQLFlow can perform common application management tasks.
  - **Seamless integration of SSIS and stored procedures**: Build your flows from both types of components, or add new types.
  - **Dependency management**: SQLFlow will keep track of which previous flows to prevent them from being unintentionally rolled back.
  - **Separation of invocation and execution**: In SQLFlow, a user with limited privileges may start a flow that will then run with elevated privileges.
  - **Notifications via webhook**: SQLFlow will post notifications to Slack if something goes wrong.





## Quickstart ##

This tutorial describes installing SQLFlow to a local instance of SQL Server, for development purposes. In a production environment, you'll want to pay more attention to security.

### Installation ###

First, you'll need to install the public key used to sign the SQLCLR assembly deployed by SQLFlow. This cannot be done in Management Studio.

- Grant the SQL Server service user (`NT Service\MSSQLSERVER`) read access to to the `SQLFlowDevelopment.pub` file.

- In Management Studio, start a new query in `master` and import the public key by running:

  ~~~mssql
  CREATE ASYMMETRIC KEY SQLFlowDevelopment FROM FILE = 'C:\path\to\SQLFlowDevelopment.pub';
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
- (The wizard will note that it cannot detect drift, and will ask to run the PostDeployment script.)

Finally, start the log viewer by doubleclicking `SQLFlowTail.exe`. (If you've installed SQLFlow non-locally or to a database,  other than `SQLFlow` you'll need to supply a connection string as a command line argument. For more information on the SQLFlowTail.exe, see [TODO].)

You should see a bunch of messages from the installation. Now, try connecting to the SQLFlow database and doing:

```mssql
EXEC flow.Log 'INFO', 'Hello World!';
```

You should see your message in the log.

### SQLFlow test project ###

Install the SQLFlowTest dacpac the same way as above



## Documentation ##

### API Overview ###

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

### 

### Flow Instances ###

**NewFlow @TypeCode, @FlowID (OUTPUT)**: Create a new flow instance pf type @TypeCode. The flow ID is returned to the caller.

**SetParameterValue @FlowID, @Name, @Value**: Set a parameter value for a flow.

**[Function] GetParameterValue(@FlowID, @Name)**: Get a parameter value for a flow.

#### 

#### Locking ####

Locks are attached to statuses to exclude other flows from entering statuses that require the same lock. Locks are hierarchically arranged, with dotted names denoting their place in the hierarchy: Holding lock `Parent` implies holding `Parent.Child`, and holding `Parent.Child` prevents anyone from acquiring `Parent`. Holding `Parent.Sibling` does not prevent anyone from holding `Parent.Child`.

Locks can always be de-escalated: If you hold `Parent`, you can always release it and acquire `Parent.Child`.

**AddLock @LockCode**: Add a new lock. If a lock with the code already exists, this does nothing. Any implied parent locks will be created.

### 


### Deploying to production ###

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

## Overview ##



SQLFlow 

### Development ###



### Configuration ###



### Operations ###












Executing a single flow is simple:

  - A new flow is created by calling `New`.
  - Parameters for the new flow are set
  - The flow is released and enters the Waiting state
  - The Execute procedure picks up the flow, and flow items are processed by calling the appropriate dispatcher (based on the item type)
  - When no more items are left to process, the flow is completed and enters the Completed state
  - If an error is encountered, the flow enters the Failed state and the error handler is invoked
  - The error handler handles the error, if possible. Handling the error can be as simple as clearing the item queue, invoking the
    rollback scheduler and placing the flow in the Rollback Running state, or it can depend on examining the state of the flow at failure time 
    determine the correct response.
  - If the flow is left in the Failed state, it will block execution of further flows of the 
    same type (and any other flows that depend on the flow) until someone manually places the flow in a Waiting, Completed or Aborted state ()

To create a new flow type, the following items must be provided:

  - Flow items: Stored procedure and SSIS packages that contain the actual business logic.

  - Constructor: Responsible for setting parameters that are shared between all instances of the flow type.



  - Scheduler: Responsible for queueing up the flow items.

    In case of reruns, the scheduler may be called multiple times
  
    The most straightforward implementation is by calling `AddItem` for each flow item, but
    the scheduler could also be more complicated (by e.g. adding all procedures in a named schema
    whose name starts with "Load...")

    The scheduler may not change any other aspect of the flow.

  - Rollback scheduler: Responsible for queueing up rollback items.


Building blocks:

  - InvokeScheduler: Invokes the procedure responsible for queuing up flow items
  - InvokeRollbackScheduler: Invokes the procedure responsible for queuing up rollback items
  - InvokeErrorHandler: Invokes the procedure responsible for handling errors

  - ClearItems: Mark any remaining items in the queue as processed

Derived from these:

  - ClearItemsAndInvokeRollbackScheduler



  - [Installation](Installation)
  - [A Simple Example](ASimpleExample)

## Installation ##

First, install Flow to the Utility database.

TODO: Mere her

For a fresh install, we have to set up system data:

```sql
EXEC Utility.internals.Setup;
```

The output should be:

```sql
[INFO] Setup done
```

(This is a log message from the flow system. The flow logging facility can be
used by the code that flow is running)

## A Simple Example ##

In this example, we'll implement a simple calendar load that loads the days in
a given period into a table.

First, we create the target table:

```sql
  CREATE TABLE dbo.CalendarDate (
      CalendarDate DATE NOT NULL PRIMARY KEY 
    , FlowID INT NOT NULL
  );
```

Then a stored procedure that loads it with the days in the year 2018:

```sql
CREATE PROCEDURE dbo.LoadCalendarDate @ID INT
AS
BEGIN
  DECLARE @Date DATE = '2018-01-01'
  DECLARE @EndDate DATE = '2019-01-01'

  WHILE @Date < @EndDate
  BEGIN
    INSERT INTO dbo.CalendarDate VALUES (@Date, @ID);
    SET @Date = DATEADD(DAY, 1, @Date);
  END
END
```

We'll call this type of procedure a *flow item*. Flow items contain the
business logic that makes up the flow, and they always have just a single parameter
(`FlowId`) that we'll use later to retrieve flow parameter values and to log
messages.

The Calendar flow only consists of this one item, but flows will normally
consist of many items to be performed in sequence. The flow engine stores flow
items in a queue and executes them in sequence.

(Flows are also queued, but the rules governing the sequence they are run in
are complex.)

Queueing the items is done by a *scheduler*:

```sql
CREATE PROCEDURE dbo.Calendar_ScheduleItems @ID INT
AS
EXEC Utility.flow.AddFlowItem @ID, 'StoredProcedure', 'Sandbox.dbo.LoadCalendarDate'
```

By convention, we'll end the name of the scheduler with `_ScheduleItems`.
Flows can have rollback schedulers and error handlers as well as schedulers.
These will be called by the flow runtime whenever the runtime needs to do
something specific to the type of a specific flow.

The system provides a default rollback scheduler and a default error handler,
so we can register our new named *flow type* with the flow runtime like this:

```sql
EXEC Utility.flow.AddType
    @TypeCode = 'Calendar'
  , @Scheduler = 'Sandbox.dbo.Calendar_ScheduleItems'
;
```

Now, the system knows how to produce instances of the Calendar flow and how to
schedule items and rollback items for those flow instances and also what to do
if the flow fails.

We still need to create and configure flow instances in a *constructor*, using
these three procedures:

  - `flow.New`: Create a new instance of a flow type.
  - `flow.AddParameter`: Add a parameter to a flow instance.
  - `flow.Release`: Tell the flow runtime that the flow instance is ready to run.

A constructor should validate it's input parameters, call the generic
constructor (`flow.New`), and then release the flow.

It can be implemented outside SQL Server (for instance in a web application
that manages inbound data transfers), but it can also be implemented as yet
another stored procedure:

```sql
CREATE PROCEDURE dbo.Calendar
AS
BEGIN
  DECLARE @ID INT;
  EXEC Utility.flow.New 'Calendar', 'System', @ID OUTPUT
  EXEC Utility.flow.Release @ID
END
```

Again, since the Calendar flow has no parameters, this constructor is minimal
-- we'll extend it in the next section, but first we'll try calling it:

```sql
EXEC Sandbox.dbo.Calendar;
EXEC Utility.internals.Main 'System';
```

Normally, `Utility.internals.Main` would be running every few seconds in
the background (as a SQL Server Agent Job). We're calling it manually for now.

The system replies that the `LoadCalendarDate` procedure was executed
successfully. In [the section on logging](logging), we'll add some logging
to the procedure itself.

First, we'll add some parameters to the Calendar flow.


## Parameters ##

Suppose we'd like to specify, when creating an instance of the Calendar flow,
which period should be loaded to the CalendarDate table. In this section,
we'll do this by using *flow parameters* to hold the bounds of the period.

Flow parameters are set by the flow constructor to tell the rest of the flow
about values that specific to this instance of the flow (e.g. the path of the
file that the flow will load).

These values are attached to the flow instance using the `flow.AddParameter`
procedure. The flow items can then retrieve the parameter values at run time
using the `flow.GetParameterValue()` function.

First, we'll add the parameters to the constructor along with some validation:

```sql
ALTER PROCEDURE dbo.Calendar
    @StartDate DATE
  , @EndDate DATE
AS
BEGIN
  DECLARE @ID INT;

  IF @EndDate < @StartDate
    THROW 51000, 'EndDate must be later than or equal to StartDate', 1;

  EXEC Utility.flow.Add 'Calendar', 'System', @ID OUTPUT

  EXEC Utility.flow.AddParameter @ID, 'StartDate', @StartDate
  EXEC Utility.flow.AddParameter @ID, 'EndDate', @EndDate

  EXEC Utility.flow.Release @ID
END
```

Next, we'll use the parameters in the flow item:

```sql
ALTER PROCEDURE dbo.LoadCalendarDate @ID INT
AS
BEGIN
  DECLARE @Date DATE = Utility.flow.GetParameterValue(@ID, 'StartDate');
  DECLARE @EndDate DATE = Utility.flow.GetParameterValue(@ID, 'EndDate');

  WHILE @Date < @EndDate
  BEGIN
    INSERT INTO dbo.CalendarDate VALUES ( @Date, @ID );
    SET @Date = DATEADD(DAY, 1, @Date);
  END
END
```

Now, we can try loading dates for 2019:

```sql
EXEC Sandbox.dbo.Calendar '2019-01-01', '2020-01-01';
EXEC Utility.internals.Main 'System';
```


## Logging ##

The logging output from the executions above tells us what items are being run
and why, but the items themselves do not add any entries to the log.

Logging should be a central component of any unmonitored database flow execution engine

Flow items may add entries to the log by calling the `flow.Log` procedure.

Add informative
messages to the calendar loader like this:

```sql
ALTER PROCEDURE dbo.LoadCalendarDate @ID INT
AS
BEGIN
  EXEC Utility.flow.Log 'INFO', 'Loading calendar table';

  DECLARE @Date DATE = Utility.flow.GetParameterValue(@ID, 'StartDate');
  DECLARE @EndDate DATE = Utility.flow.GetParameterValue(@ID, 'EndDate');
  DECLARE @RowsAdded INT = 0;

  WHILE @Date < @EndDate
  BEGIN
    INSERT INTO dbo.CalendarDate VALUES ( @Date, @ID );
    SET @Date = DATEADD(DAY, 1, @Date);
    SET @RowsAdded = @RowsAdded + 1;
  END
  
  EXEC Utility.flow.Log 'INFO', 'Done. :1: rows loaded', @RowsAdded;
END
```

We're logging to INFO here, but the system comes with the following five log
levels:

  - TRACE
  - DEBUG
  - INFO
  - WARN
  - ERROR

More can be added using `internals.AddLogLevel`, but this should be done
sparingly.

We've also added a row counter, whose final value is inserted in the log
message by means of a placeholder (`:1:`).

Running the job again:

```sql
EXEC Sandbox.dbo.Calendar '2020-01-01', '2021-01-01';
EXEC Utility.internals.Main 'System';
```


shows that the logging appears alongside the logging from the framework.

## Error handling ##

In this section, we'll try to make the flow fail (by provoking a primary key
violation) and then responding to the error.

We'll do this in three ways:

  - By fixing the error and resuming execution
  - By manually requesting a rollback of the flow
  - By changing the flow type to automatically schedule the rollback flow in case of errors


### Resuming ###

First, we provoke an error:

```sql
EXEC Sandbox.dbo.Calendar '2017-01-01', '2108-01-01';
EXEC Utility.internals.Main 'System';
```

The system responds:

```sql
[ERROR] Violation of PRIMARY KEY constraint 'PK__Calendar__<...>'. Cannot insert duplicate key in object 'dbo.CalendarDate'. The duplicate key value is (2018-01-01).
```

Note that we do not need to catch the error and log it, this is done for us.

The log also tells us that the flow entered the "Failed" state and that the
error handler `internals.ErrorHandler` was invoked. This is the default
error handler, and all it does is warn us that no error handling will take
place, leaving the flow in the "Failed" state. This gives us an opportunity
to examine the database as it looked when the error occurred and figure out
exactly what went wrong.

In this case, it's an obvious typo in the constructor invocation that we can easily fix:

```sql
EXEC Utility.flow.AddParameter 4, 'EndDate', '2018-01-01'
DELETE dbo.CalendarDate WHERE FlowID = 4;
```

(Note that we're passing a specific FlowID here - when we're doing)

Then we tell the system that we're ready to resume running:

```sql
EXEC Utility.operations.ResumeFlow 4;
EXEC Utility.internals.Main 'System';
```

The execution manager restarts the flow at the failed item (which is also the
first item).


### Rolling back ###

The error above was easily fixable, but sometimes this will not be the case,
and we'll need to roll back the flow. SQLFlow can store the rollback code for
us, so that we can roll back all flows supporting rollback

```sql
CREATE PROCEDURE dbo.RollbackCalendarDate @ID INT
AS
BEGIN
  EXEC Utility.flow.Log 'INFO', 'Rolling back calendar table';
  
  DELETE dbo.CalendarDate WHERE FlowID = @ID;

  EXEC Utility.flow.Log 'INFO', 'Done. :1: rows deleted', @@ROWCOUNT;
END
```

We'll call this kind of procedure a *rollback item*. (Note that we use the
FlowID to figure out which rows were inserted by the flow that we're rolling
back. This is another use of the FlowID: It can be used as a
transaction time dimension.)

Since the rollback item is part of a flow, we need a *rollback scheduler* for
that flow:

```sql
CREATE PROCEDURE dbo.Calendar_ScheduleRollback @ID INT
AS
EXEC Utility.flow.AddFlowItem @ID, 'StoredProcedure', 'Sandbox.dbo.RollbackCalendarDate'
```

The rollback flow only consists of a single item here, but it would normally
be more complex.

Finally, we need to register the rollback scheduler as part of the Calendar
flow type:

```sql
EXEC Utility.flow.AddType
    @TypeCode = 'Calendar'
  , @RollbackScheduler = 'Sandbox.dbo.Calendar_ScheduleRollback'
;
```

We use `AddType` for this, it will leave the rest of the flow unchanged.

So, with the rollback item in place, we're ready to make the flow fail again:

```sql
EXEC Sandbox.dbo.Calendar '2017-01-01', '9999-12-31';
EXEC Utility.internals.Main 'System';
```

Next, we schedule the rollback items and tell the flow engine that the flow
instance is ready to be rolled back:

```sql
EXEC operations.RollbackFlow 5
```

The flow instance changes state to "Waiting for rollback" and is ready to be
picked up by the main flow execution procedure:

```sql
EXEC Utility.internals.Main 'System';
```

The rollback flow is run and the final state is "Rollback completed".

Sometimes, a flow just fails during the normal course of business: it may be
vulnerable to temporary inconsistencies in user data input or rely on a
resource that is sometimes not available. In that case, you probably want flow
to roll back as soon as the error is encountered, and then try later.

To do this, we can attach the "Immediate rollback" error handler to the type:

```sql
EXEC Utility.flow.AddType
    @TypeCode = 'Calendar'
  , @ErrorHandler = 'Sandbox.dbo.ErrorHandler_ImmediateRollback'
;
```



```sql
EXEC Sandbox.dbo.Calendar '2017-01-01', '9999-12-31';
EXEC Utility.internals.Main 'System';
```
