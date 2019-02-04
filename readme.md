# SQLFlow #

SQLFlow is a flow manager written in SQL.

  - **Error handling and logging**: All errors are caught and logged to a common log table.
  - **Flow configuration**: All parameters are kept in one place.
  - **Automated ollbacks and reruns**: Code for rolling back and re-scheduling flows may be registered with SQLFlow, so SQLFlow can perform common application management tasks.
  - **Seamless integration of SSIS and stored procedures**: Build your flows from both types of components, or add new types.
  - **Dependency management**: SQLFlow will keep track of which previous flows to prevent them from being unintentionally rolled back.
  - **Separation of invocation and execution**: In SQLFlow, a user with limited privileges may start a flow that will then run with elevated privileges.
  - **Notifications via webhook**: SQLFlow will post notifications to Slack if something goes wrong.

## Overview


## Quickstart ##

Start out be defining a new flow type, which specifies which statuses the flow can be in and which actions are allowed when the flow is in each status:

~~~sql
USE SQLFlow;

EXEC flow.NewType @TypeCode='LoadNumbers';

EXEC flow.AddAction 'LoadNumbers.New.Start', 'Running';
EXEC flow.AddAction 'LoadNumbers.Running.Fail', 'Failed';
EXEC flow.AddAction 'LoadNumbers.Running.Complete', 'Completed';
~~~

Actions are transitions between statuses, and the statuses are added by SQLFlow if
they're not already defined - we could also have added them with `flow.AddStatus`.

Our "LoadNumbers" flow type defines four statuses - we'll add more later:

  - `New`: The status that the flow will have when it is created. . In this status, the flow can only be started.
  - `Running`: The status where the flow does its work. In this status, the flow can fail or succeed.
  - `Failed` and `Completed`: The statuses that the flow enters if the work fails or succeeds.

Next, we'll create an instance of the "LoadNumbers" flow type by calling `flow.New`:


~~~sql
DECLARE @FlowID INT
EXEC flow.New 'LoadNumbers', @FlowID OUTPUT
EXEC flow.Do @ID, 'Start';
EXEC flow.Do @ID, 'Complete';
~~~

`flow.New` creates a new instance

Normally, a SQL Agent Job would invoke the 'Start' action to start queued flows one by one, and the procedure that does the work associated with the "Running" status would invoke the 'Complete' action to hand over control to the next part of the flow. Here, we're running both procedures explicitly.

Next, we'll add some actual work to be done by the flow.




















The quickest way to get started developing code against SQLFlow is by
installing a pre-built version of the solution (a dacpac).

To deploy that, you'll need to install the public key used to sign the C#
assemblies included in the solution.

Navigate to `<repo root>\SQLFlow`, then copy `SQLFlowDevelopment.pub` to a
place where it is accessible to the SQL Server that you'll be deploying to.

Log on to SQL Server, go to `master` and import the key:

~~~sql
USE master;

CREATE ASYMMETRIC KEY SQLFlowDevelopment FROM FILE = 'C:\path\to\somewhere\that\SQL\Server\can\access\SQLFlowDevelopment.pub';
CREATE LOGIN SQLFlowDevelopmentLogin FROM ASYMMETRIC KEY SQLFlowDevelopment;
GRANT UNSAFE ASSEMBLY TO SQLFlowDevelopmentLogin;
~~~

(Doing this requires administration privileges on the target machine)

Use cmd or Powershell to navigate to the folder where the dacpac is located, then do

~~~
SqlPackage.exe /a:Publish /tsn:localhost /tdn:SQLFlow /sf:SQLFlow.dacpac
~~~

to deploy it, modifying the parameters `tsn` (target server name) and `tdn`
(target database name) as needed.

Now start a new database project in Visual Studio, add a database reference to
the SQLFlow dacpac and to `master`, and you're ready to go.



## API ##

### Flow Type Setup ###

#### Flow Types ####

A flow type contains at least one status that instances of the flow can be in (e.g. "New", "Running", "Completed", "Rolling back"). Flow types are required to define an initial status that new instances of the flow 

Flow types cannot be deleted, but you can assign the initial status to 

- **AddType**: Add a new flow type.

  - **@TypeCode**: The code identifying the flow. If a flow with the specified flow code already exists, it will be modified.
  - **@ExecutionGroupCode** (optional): The execution group that instances of this type will belong to (The default value is "Ungrouped")
  - **@InitialStatusCode** (optional): The initial status of instances of the type. Defaults to '<@TypeCodeæ>.New'




- **SetExecutionGroup**: Sets the execution group of a flow type.

  - **@TypeCode**: The code identifying the flow, which must exist.

  - **@ExecutionGroupCode**: The execution group that instances of this type will belong to.

      

- **ResetFlowType**: Remove all actions, locks and procedures associated with the flow type.


- - **@TypeCode**: The code identifying the flow type to reset.


#### Locking ####

Locks are attached to statuses to exclude other flows from entering statuses that require the same lock. Locks are hierarchically arranged, with dotted names denoting their place in the hierarchy: Holding lock `Parent` implies holding `Parent.Child`, and holding `Parent.Child` prevents anyone from acquiring `Parent`. Holding `Parent.Sibling` does not prevent anyone from holding `Parent.Child`.

Locks can always be de-escalated: If you hold `Parent`, you can always acquire `Parent.Child`.

- **AddLock**: Add a new lock.

  - **@LockCode**: The code identifying the lock. If a lock with the code already exists, nothing will happen. If the implied parent lock does not exist, it will be created.



#### Status ####

At any point in time, a flow is in a specific status, e.g. new, running, running, failed, cancelled, completed etc.

In SQLFlow, the status 

To enter a status, a flow may need to acquire a lock (see above). If the lock cannot be acquired, flow execution will fail.

A status may define an _action_, which is a stored procedure that must be called when a flow enters the status.

In each status, a number of actions may be taken



- **AddStatus**: Add a new status to a flow type.
  - **@StatusCode**: The code identifying the status. If the status is already defined, the lock, procedure and "initiality" will be updated, if the corresponding parameters are set.
  - **@RequiredLockCode** (optional): The lock required to enter the status.
  - **@ProcedureName** (optional): The procedure to perform when the status is entered.
  - **@IsInitial** (optional): Flag that indicates that the status is the initial status for the parent flow. The default value is 0 (for false).




- **SetStatusLock**: Specify a lock that is required to enter a status.
  - **@StatusCode**: The code identifying the status. The status must exist.
  - **@RequiredLockCode**: The lock required to enter the status (may be NULL). If the lock does not exist, it will be created.



- **SetStatusProcedure**: Specify a procedure to perform when a status is entered.
  - **@StatusCode**: The code identifying the status. The status must exist.
  - **@ProcedureName** (optional): The procedure to perform when the status is entered (may be NULL).



- **DropStatus**: Removes a status from a flow type.

  - **@TypeCode**: The code identifying the flow type.
  - **@StatusCode**: The code identifying the status.



- **AddAction**: Add a new action to a flow type.

  - **@ActionCode**: The code identifying the action.
  - **@ResultingStatusCode**: The status that results from performing the action.

- **DropAction**: Remove an action from a flow type.

  - **@TypeCode**: The code identifying the flow type.
  - **@StatusCode**: The code identifying the status.
  - **@ActionCode**: The code identifying the action to drop.

- 



### Flow Setup ###



- **NewFlow**: Specify a procedure to perform when a status is entered.

  - **@TypeCode**: The code identifying the flow type. The flow must exists.
  - **@StatusCode**: The code identifying the status. The status must exist.














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
