import os
import pyodbc
import time

import click

loglevels = {
    "TRACE": 10,
    "DEBUG": 20,
    "INFO": 30,
    "WARN": 40,
    "ERROR": 50,
}

log_template = "[{servername}][{timestamp}][{level}] {message}"

rv_query = "SELECT MIN(rv) FROM ( SELECT TOP {initial_tail} rv FROM flow.LogEntry ORDER BY rv DESC ) AS t"


@click.group()
@click.option("-S", "--server", default=lambda: os.environ.get("COMPUTERNAME", "."))
@click.option("-d", "--database", default="SQLFlow")
@click.option("-U", "--username", default="")
@click.option("-P", "--password", default="")
@click.pass_context
def sqlflow(ctx, server, database, username, password):
    click.echo("Connecting...")

    connection_info = dict()
    connection_info["Driver"] = "{SQL Server}"
    connection_info["Server"] = server
    connection_info["Database"] = database
    if username:
        connection_info["Uid"] = username
        connection_info["Pwd"] = password
    else:
        connection_info["Trusted_Connection"] = "True"
    connection_string = ";".join("=".join(item) for item in connection_info.items())
    click.echo(connection_string)
    ctx.obj = dict()
    ctx.obj["server"] = server
    ctx.obj["database"] = database
    ctx.obj["connection"] = pyodbc.connect(connection_string, autocommit=True)
    click.echo("Connected")


@sqlflow.command()
@click.option("-p", "--polling-interval", default=1)
@click.option("-i", "--initial-tail", default=20)
@click.option("-l", "--loglevel", type=click.Choice(sorted(loglevels.keys(), key=loglevels.get)), default="INFO")
@click.pass_context
def tail(ctx, loglevel, polling_interval, initial_tail):
    cursor = ctx.obj["connection"].cursor()
    cursor.execute("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED")
    dbts = None
    if initial_tail:
        click.echo("(Showing last {initial_tail} log messages)".format(initial_tail=initial_tail))
        dbts = cursor.execute(rv_query.format(initial_tail=int(initial_tail))).fetchval()
    if not dbts:
        dbts = cursor.execute("SELECT @@DBTS").fetchval()
    limit = loglevels[loglevel]
    while True:
        cursor.execute(
            "SELECT [rv], [LogLevelCode], [LogLevelID], [EntryTimestamp], [FormattedEntryText], [ServerProcessID], [FlowID], [StatusCode], [UserName], [ServerName] "
            "FROM flow.LogEntry "
            "WHERE rv > ? "
            "ORDER BY rv;", dbts)
        for dbts, level, level_number, timestamp, message, spid, flow_id, status_code, username, servername in cursor:
            if level_number < limit:
                continue
            click.echo(log_template.format(servername=servername, timestamp=timestamp, level=level, message=message))
        time.sleep(polling_interval)


if __name__ == '__main__':
    sqlflow()