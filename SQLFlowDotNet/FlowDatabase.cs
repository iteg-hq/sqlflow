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
        private readonly string connectionString;
        private SqlBinary rowVersion = null;

        public FlowDatabase(string connectionString)
        {
            this.connectionString = connectionString;
        }

        private SqlConnection GetConnection()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            return conn;
        }

        private SqlConnection GetConnection(int flowID)
        {
            SqlConnection conn = GetConnection();
            SetSessionContext(conn, "FlowID", flowID);
            SetSessionContext(conn, "StatusCode", GetStatusByFlowID(flowID).StatusCode);
            return conn;
        }


        public Flow NewFlow(FlowType flowType) => NewFlow(flowType.TypeCode);

        public Flow NewFlow(string typeCode)
        {
            int flowID;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("flow.NewFlow", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TypeCode", typeCode);
                    var outParam = new SqlParameter("@FlowID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(outParam);
                    command.ExecuteNonQuery();
                    flowID = (int)outParam.Value;
                }
                return new Flow(this, flowID);
            }
        }

        public FlowType GetFlowTypeByCode(string typeCode)
        {
            return new FlowType(this, typeCode);
        }

        public Status GetStatusByCode(string typeCode, string statusCode)
        {
            return new Status(this, typeCode, statusCode);
        }

        public FlowType GetFlowTypeByFlowID(int flowID)
        {
            string typeCode;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT TypeCode FROM flow.Flow WHERE FlowID = @FlowID", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    typeCode = command.ExecuteScalar().ToString();
                }
                return GetFlowTypeByCode(typeCode);
            }
        }

        public void SetSessionContext(SqlConnection connection, string key, object value)
        {
            using (var command = new SqlCommand("EXEC sp_set_session_context @Key, @Value", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@Key", key);
                command.Parameters.AddWithValue("@Value", value.ToString());
                command.ExecuteNonQuery();
            }
        }

        public void AddLogEntry(int flowID, LogLevel logLevel, string message, object value1 = null, object value2 = null)
        {
            using (SqlConnection connection = GetConnection(flowID))
            {
                using (var command = new SqlCommand("flow.Log", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@LogLevel", logLevel.ToString());
                    command.Parameters.AddWithValue("@EntryText", message);
                    if (value1 != null) command.Parameters.AddWithValue("@Value1", value1.ToString());
                    if (value2 != null) command.Parameters.AddWithValue("@Value2", value2.ToString());
                    command.ExecuteNonQuery();
                }
            }
        }

        public void Do(int flowID, string actionCode)
        {
            using (SqlConnection connection = GetConnection(flowID))
            {
                using (var command = new SqlCommand("flow.Do", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    command.Parameters.AddWithValue("@ActionCode", actionCode);
                    command.ExecuteNonQuery();
                }
            }
        }

        public IEnumerable<LogEntry> GetTail()
        {
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("flow.Tail", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@rv", SqlDbType.Binary));
                    command.Parameters["@rv"].Value = rowVersion;
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            rowVersion = reader.GetSqlBinary(0);
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
                    }
                }
            }
        }

        public Status GetStatusByFlowID(int flowID)
        {
            string statusCode;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT StatusCode FROM internal.Flow WHERE FlowID = @FlowID", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    statusCode = command.ExecuteScalar().ToString();
                }
                return GetStatusByCode(GetFlowTypeByFlowID(flowID).TypeCode, statusCode);
            }
        }

        public Status GetInitialStatusByTypeCode(string typeCode)
        {
            string statusCode;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT InitialStatusCode FROM internal.FlowType WHERE TypeCode= @TypeCode", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@TypeCode", typeCode);
                    statusCode = command.ExecuteScalar().ToString();
                }

                return GetStatusByCode(typeCode, statusCode);
            }
        }

        public string GetExecutionGroupByTypeCode(string typeCode)
        {
            string executionGroup;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT ExecutionGroupCode FROM internal.FlowType WHERE TypeCode= @TypeCode", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@TypeCode", typeCode);
                    executionGroup = command.ExecuteScalar().ToString();
                }
                return executionGroup;
            }
        }

        public IDictionary<string, Status> GetActionsByStatus(string typeCode, string statusCode)
        {
            var result = new Dictionary<string, Status>();
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT ActionCode, ResultingStatusCode FROM internal.FlowAction WHERE TypeCode = @TypeCode AND StatusCode = @StatusCode", connection))
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
                return result;
            }
        }

        public void SetParameterValue(int flowID, string parameterName, object parameterValue)
        {
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("flow.SetParameterValue", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    command.Parameters.AddWithValue("@Name", parameterName);
                    command.Parameters.AddWithValue("@Value", parameterValue.ToString());
                    command.ExecuteNonQuery();
                }
            }
        }

        public string GetParameterValue(int flowID, string parameterName)
        {
            string value = null;
            using (SqlConnection connection = GetConnection())
            {
                using (var command = new SqlCommand("SELECT flow.GetParameterValue(@FlowID, @Name)", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    command.Parameters.AddWithValue("@Name", parameterName);
                    value = command.ExecuteScalar().ToString();
                }
                return value;
            }
        }
    }
}
