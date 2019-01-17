using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{


    public class FlowParameters
    {
        private readonly SqlConnection conn;

        private readonly int flowID;

        internal FlowParameters(SqlConnection connection, int flowID)
        {
            this.conn = connection;
            this.flowID = flowID;
        }

        public string this[string parameterName]
        {
            get
            {
                string value = "";
                using (var command = new SqlCommand("SELECT flow.GetParameterValue(@FlowID, @Name)", conn))
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
                return value;
            }
            set
            {
                using (var command = new SqlCommand("flow.SetParameterValue", conn))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@FlowID", flowID);
                    command.Parameters.AddWithValue("@Name", parameterName);
                    command.Parameters.AddWithValue("@Value", value);
                    command.ExecuteNonQuery();
                }
            }
        }
    }
}
