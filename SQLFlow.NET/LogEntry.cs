using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{
    public enum LogLevel
    {
        TRACE = 10,
        DEBUG = 20,
        INFO = 30,
        WARN = 40,
        ERROR = 50
    }


    public struct LogEntry
    {
        public string Message;
        public string ServerName;
        public string UserName;
        public string Status;
        public DateTime Timestamp;
        public LogLevel LogLevel;
        public Flow Flow;

        public string Format()
        {
            if (Flow == null)
            {
                return $"[{Timestamp}][{UserName}@{ServerName}][{Status}][{LogLevel}] {Message}";
            }
            else
            {
                return $"[{Timestamp}][{UserName}@{ServerName}][{Flow.FlowID}][{Status}][{LogLevel}] {Message}";
            }
        }
    }
}
