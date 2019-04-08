public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string ReadFile(string path, string encoding)
    {
        return System.IO.File.ReadAllText(path, System.Text.Encoding.GetEncoding(encoding));
    }
}
