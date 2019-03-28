namespace SQLFlow
{
    public class Action
    {
        private readonly FlowDatabase FlowDatabase;
        public string ActionCode;
        public Status Status;
        public Status ResultingStatus;
        public string ActionProcedure;

        public Action(FlowDatabase flowDatabase, Status status, string actionCode)
        {
            FlowDatabase = flowDatabase;
            Status = status;
            ActionCode = actionCode;
        }
    }
}
