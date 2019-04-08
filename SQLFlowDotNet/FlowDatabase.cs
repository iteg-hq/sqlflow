using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{
    public class FlowDatabase
    {
        public readonly string ConnectionString;

        private SqlBinary rv = null;
        public int Interval;

        public FlowDatabase() : this("Server=localhost;Database=SQLFlow;Trusted_Connection=True;") { }

        public FlowDatabase(string connectionString)
        {
            this.ConnectionString = connectionString;
            Interval = 1000;
        }

        protected SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        // SQLFlow stuff

        public Flow GetFlowByID(int flowID)
        {
            return new Flow(this, flowID);
        }

        public Flow NewFlow(string typeCode)
        {
            FlowType flowType = GetFlowTypeByCode(typeCode);
            return NewFlow(GetFlowTypeByCode(typeCode));
        }

        public Flow NewFlow(FlowType flowType)
        {
            int flowID;
            var connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.NewFlow", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@TypeCode", flowType.TypeCode);
                var outParam = new SqlParameter("@FlowID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                command.Parameters.Add(outParam);
                command.ExecuteNonQuery();
                flowID = (int)outParam.Value;
            }

            Flow flow = new Flow(this, flowID);
            connection.Close();
            return flow;
        }

        public FlowType GetFlowTypeByCode(string typeCode)
        {
            return new FlowType(this, typeCode);
        }

        public Status GetStatusByCode(string typeCode, string statusCode)
        {
            return new Status(this, GetFlowTypeByCode(typeCode), statusCode);
        }

        public FlowType GetFlowTypeByFlowID(int flowID)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            string typeCode;
            using (var command = new SqlCommand("SELECT TypeCode FROM flow.Flow WHERE FlowID = @FlowID", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@FlowID", flowID);
                typeCode = command.ExecuteScalar().ToString();
            }
            connection.Close();
            return GetFlowTypeByCode(typeCode);
        }


        public void AddLogEntry(LogLevel logLevel, string message, object Value1 = null, object Value2 = null)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.Log", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@LogLevel", logLevel.ToString());
                command.Parameters.AddWithValue("@EntryText", message);
                if (Value1 != null) command.Parameters.AddWithValue("@Value1", Value1.ToString());
                if (Value2 != null) command.Parameters.AddWithValue("@Value2", Value2.ToString());
                command.ExecuteNonQuery();
            }
            connection.Close();
        }

        public void Do(int flowID, string actionCode)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.Do", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@FlowID", flowID);
                command.Parameters.AddWithValue("@ActionCode", actionCode);
                command.ExecuteNonQuery();
            }
            connection.Close();
        }

        public IEnumerable<LogEntry> GetTail()
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.Tail", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@rv", SqlDbType.Binary));
                command.Parameters["@rv"].Value = rv;
                SqlDataReader reader = command.ExecuteReader();
                while (reader.Read())
                {
                    rv = reader.GetSqlBinary(0);
                    yield return new LogEntry
                    {
                        LogLevel = (LogLevel)reader.GetByte(2),
                        Timestamp = reader.GetDateTime(3),
                        Message = reader.GetString(4),
                        Flow = reader.IsDBNull(6) ? null : new Flow(this, reader.GetInt32(6)),
                        Status = reader.GetString(7),
                        UserName = reader.GetString(8),
                        ServerName = reader.GetString(9)
                    };
                }
                reader.Close();
                System.Threading.Thread.Sleep(Interval);
            }
            connection.Close();
        }

        public Status GetStatusByFlowID(int flowID)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            string statusCode;
            using (var command = new SqlCommand("SELECT StatusCode FROM flow_internals.Flow WHERE FlowID = @FlowID", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@FlowID", flowID);
                statusCode = command.ExecuteScalar().ToString();
            }
            connection.Close();
            return GetStatusByCode(GetFlowTypeByFlowID(flowID).TypeCode, statusCode);
        }

        public Status GetInitialStatusByTypeCode(string typeCode)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            string statusCode;
            using (var command = new SqlCommand("SELECT InitialStatusCode FROM flow_internals.FlowType WHERE TypeCode= @TypeCode", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@TypeCode", typeCode);
                statusCode = command.ExecuteScalar().ToString();
            }
            connection.Close();
            return GetStatusByCode(typeCode, statusCode);
        }

        public string GetExecutionGroupByTypeCode(string typeCode)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            string executionGroup;
            using (var command = new SqlCommand("SELECT ExecutionGroupCode FROM flow_internals.FlowType WHERE TypeCode= @TypeCode", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@TypeCode", typeCode);
                executionGroup = command.ExecuteScalar().ToString();
            }
            connection.Close();
            return executionGroup;
        }

        public IDictionary<string, Status> GetActionsByStatus(string typeCode, string statusCode)
        {
            SqlConnection connection = GetConnection();
            connection.Open();
            var result = new Dictionary<string, Status>();
            using (var command = new SqlCommand("SELECT ActionCode, ResultingStatusCode FROM flow_internals.FlowAction WHERE TypeCode = @TypeCode AND StatusCode = @StatusCode", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@TypeCode", typeCode);
                command.Parameters.AddWithValue("@StatusCode", statusCode);
                SqlDataReader reader = command.ExecuteReader();
                while (reader.Read())
                {
                    string actionCode = reader.GetString(0);
                    string resultingStatusCode = reader.GetString(1);
                    result[actionCode] = GetStatusByCode(typeCode, resultingStatusCode);
                }
            }
            connection.Close();
            return result;
        }


        public void SetParameterValue(int flowID, string parameterName, object parameterValue)
        {
            var connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.SetParameterValue", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@FlowID", flowID);
                command.Parameters.AddWithValue("@Name", parameterName);
                command.Parameters.AddWithValue("@Value", parameterValue.ToString());
                command.ExecuteNonQuery();
            }
            connection.Close();
        }

        public string GetParameterValue(int flowID, string parameterName)
        {
            var connection = GetConnection();
            connection.Open();
            string value = null;
            using (var command = new SqlCommand("SELECT flow.GetParameterValue(@FlowID, @Name)", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@FlowID", flowID);
                command.Parameters.AddWithValue("@Name", parameterName);
                value = command.ExecuteScalar().ToString();
            }
            connection.Close();
            return value;
        }

    }
}
