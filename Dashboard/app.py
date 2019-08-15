import binascii
import pyodbc
from flask import Flask, request, render_template
app = Flask(__name__)


def execute(query, *args):
    conn = pyodbc.connect("Driver={SQL Server Native Client 11.0};Server=localhost;Database=SQLFlow;Trusted_Connection=yes;")
    cursor = conn.cursor()
    cursor.execute(query, args)
    cols = [col[0] for col in cursor.description]
    rows = [dict(zip(cols, row)) for row in cursor.fetchall()]    
    cursor.close()
    conn.close()
    return rows

@app.route('/tail')
def tail_page():
    return render_template("tail.html")

@app.route('/api/tail')
def tail_api():
    rv = request.args.get("timestamp", default=None)
    loglevel = request.args.get("level", default="INFO")

    conn = pyodbc.connect("Driver={SQL Server Native Client 11.0};Server=localhost;Database=SQLFlow;Trusted_Connection=yes;")
    cursor = conn.cursor()
    cursor.execute("DECLARE @rv BINARY(8) = CONVERT(BINARY(8), ?, 2); EXEC flow.Tail @rv;", rv)
    cols = [col[0] for col in cursor.description]
    entries = [dict(zip(cols, row)) for row in cursor.fetchall()]
    for entry in entries:
        entry["rv"] = binascii.hexlify(entry["rv"]).decode("ascii")
        entry["EntryTimestamp"] = entry["EntryTimestamp"].isoformat()
    cursor.close()
    conn.close()
    return {"entries": entries}

@app.route('/flow')
def flow():

    flows=execute("SELECT TOP 100 FlowID, ExecutionGroupCode, TypeCode, StatusCode FROM flow.Flow ORDER BY FlowID DESC;")
    flow_index = dict()
    for flow in flows:
        flow_index[flow["FlowID"]] = flow
        flow["Actions"] = list()
        flow["Parameters"] = list()

    for action in execute("""
            SELECT FlowID, ActionCode, ResultingStatusCode
            FROM flow.FlowAction
            WHERE FlowID IN ( SELECT TOP 100 FlowID FROM flow.Flow ORDER BY FlowID DESC )
            ORDER BY FlowID, ActionCode
            """):
        flow = flow_index[action["FlowID"]]
        flow["Actions"].append(action)

    for parameter in execute("""
            SELECT FlowID, ParameterName, ParameterValue
            FROM flow_internals.FlowParameter
            WHERE FlowID IN ( SELECT TOP 100 FlowID FROM flow.Flow ORDER BY FlowID DESC )
            """):
        flow = flow_index[parameter["FlowID"]]
        flow["Parameters"].append(parameter)


    return render_template("flow.html", flows=flows)
