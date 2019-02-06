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
                        UserName = reader.GetString(8),
                        ServerName = reader.GetString(9)
                        // int spid = reader.GetInt32(5);
                    };
                }
                reader.Close();
                System.Threading.Thread.Sleep(Interval);
            }
            connection.Close();
        }

        public Status GetStatusByFlowID(int FlowID)
        {
            return null;
        }


        public void SetParameterValue(int flowID, string parameterName, object parameterValue)
        {
            string value = "";
            var connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("flow.SetParameterValue", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@FlowID", flowID);
                command.Parameters.AddWithValue("@Name", parameterName);
                command.Parameters.AddWithValue("@Value", value);
                command.ExecuteNonQuery();
            }
            connection.Close();
        }

        public string GetParameterValue(int flowID, string parameterName)
        {
            string value = "";
            var connection = GetConnection();
            connection.Open();
            using (var command = new SqlCommand("SELECT flow.GetParameterValue(@FlowID, @Name)", connection))
            {
                command.CommandType = CommandType.Text;
                command.Parameters.AddWithValue("@FlowID", flowID);
                command.Parameters.AddWithValue("@Name", parameterName);
                var reader = command.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    value = reader.GetString(0);
                }
                else
                {
                    value = null;
                }
                reader.Close();
            }
            connection.Close();
            return value;
        }

    }
}
