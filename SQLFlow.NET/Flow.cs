using System.Data;
using System.Data.SqlClient;

namespace SQLFlow
{
    public enum LogLevel { TRACE, DEBUG, INFO, WARN, ERROR }

    public class Flow
    {
        private readonly SqlConnection conn;

        public readonly int ID;

        public FlowParameters Parameters;

        public Status Status
        {
            get
            {
                throw new System.NotImplementedException();
            }
        }

        public Flow(SqlConnection connection, int id)
        {
            conn = connection;
            ID = id;
            Parameters = new FlowParameters(conn, id);
        }

        public static Flow Create(SqlConnection connection, string typeCode)
        {
            int flowID;
            using (var command = new SqlCommand("flow.NewFlow", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@TypeCode", typeCode);
                var outParam = new SqlParameter("@FlowID", SqlDbType.Int);
                outParam.Direction = ParameterDirection.Output;
                command.Parameters.Add(outParam);
                command.ExecuteNonQuery();
                flowID = (int)outParam.Value;
            }

            Flow flow = new Flow(connection, flowID);
            return flow;
        }

        public void Do(string actionCode)
        {
            using (var command = new SqlCommand("flow.Do", conn))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@FlowID", ID);
                command.Parameters.AddWithValue("@ActionCode", actionCode);
                command.ExecuteNonQuery();
            }
        }

        public void Log(LogLevel logLevel, string message, object Value1 = null, object Value2 = null)
        {
            using (var command = new SqlCommand("flow.Log", conn))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@FlowID", ID);
                command.Parameters.AddWithValue("@LogLevel", logLevel.ToString());
                command.Parameters.AddWithValue("@EntryText", message);
                if (Value1 != null) command.Parameters.AddWithValue("@Value1", Value1.ToString());
                if (Value2 != null) command.Parameters.AddWithValue("@Value2", Value2.ToString());
                command.ExecuteNonQuery();
            }
        }
    }
}
