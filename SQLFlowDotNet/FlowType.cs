﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{
    public class FlowType
    {
        private readonly FlowDatabase flowDatabase;

        public string TypeCode;
        public string ExecutionGroupCode { get => flowDatabase.GetExecutionGroupByTypeCode(TypeCode); }
        public Status InitialStatus { get => flowDatabase.GetInitialStatusByTypeCode(TypeCode); }

        internal FlowType(FlowDatabase flowDatabase, string typeCode)
        {
            this.flowDatabase = flowDatabase;
            TypeCode = typeCode;
        }

    }
}
