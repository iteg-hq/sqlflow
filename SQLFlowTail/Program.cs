using System;
using System.Threading;

namespace SQLFlow
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=localhost;Database=SQLFlow;Trusted_Connection=True;";
            if (args.Length > 0)
            {
                connectionString = args[0];
            }
            int pollingInterval = 1000;

            FlowDatabase flowDatabase = new FlowDatabase(connectionString);

            bool go = true;

            Console.CancelKeyPress += delegate(object sender, ConsoleCancelEventArgs eargs)
            {
                go = false;
                eargs.Cancel = true;
            };


            while (go)
            {
                foreach (LogEntry logentry in flowDatabase.GetTail())
                {
                    if (logentry.LogLevel >= LogLevel.TRACE)
                    {
                        Console.WriteLine(logentry.Format());
                    }
                }
                Thread.Sleep(pollingInterval);
            }
        }
    }
}
