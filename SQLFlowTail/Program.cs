using System;

namespace SQLFlow
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=localhost;Database=SQLFlow;Trusted_Connection=True;";
            if (args.Length > 0){
                connectionString = args[0];
            }
            FlowDatabase db = new FlowDatabase(connectionString);
            while (true)
            {
                foreach (LogEntry logentry in db.GetTail())
                {
                    if (logentry.LogLevel >= LogLevel.INFO)
                    {
                        Console.WriteLine(logentry.Format());
                    }
                }
            }
        }
    }
}
