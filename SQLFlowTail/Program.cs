using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.Data.SqlTypes;

namespace SQLFlow
{
    class Program
    {
        static void Main(string[] args)
        {
            FlowDatabase db = new FlowDatabase("Server=localhost;Database=SQLFlow;Trusted_Connection=True;");
            while (true)
            {
                foreach (LogEntry logentry in db.GetTail())
                {
                    Console.WriteLine(logentry.Format());
                }
            }
        }
    }
}
