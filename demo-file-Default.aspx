<%--
// Server Status Checker
// Copyright © Hackafortani, 2013
// Developed by Ilyas Kolasinac Osmanogullari || http://www.ilyax.com
// http://www.hackafortanfoni.com || http://www.alafortanfoni.com--%>
<%@ Page Language="C#" AutoEventWireup="true" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            CheckFrameworkVersion();
            ltIIS.Text = "<p>" + GetIISVersion() + "</p>";
        }
    }

    protected void btnCheckSQL_Click(object sender, EventArgs e)
    {
        try
        {
            string connectionString = string.Format("Server={0};Database={1};User Id={2};Password={3};", txtServer.Text.Trim(),
                txtDatabase.Text.Trim(), txtUserName.Text.Trim(), txtPassword.Text.Trim());

            using (System.Data.SqlClient.SqlConnection conn =
                   new System.Data.SqlClient.SqlConnection(connectionString))
            {
                System.Data.SqlClient.SqlCommand cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT * FROM INFORMATION_SCHEMA.TABLES";

                conn.Open();

                System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    ltSQLStatus.Text += "<p> - " + dr.GetString(2) + "</p>";
                }
            }
        }
        catch (Exception ex)
        {
            ltSQLStatus.Text = ex.ToString();
        }
    }

    /// <summary>
    /// .NET Framework
    /// </summary>
    public void CheckFrameworkVersion()
    {
        using (Microsoft.Win32.RegistryKey ndpKey = Microsoft.Win32.RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.LocalMachine,
            Microsoft.Win32.RegistryView.Registry32).OpenSubKey(@"SOFTWARE\Microsoft\NET Framework Setup\NDP\"))
        {
            foreach (string versionKeyName in ndpKey.GetSubKeyNames())
            {
                if (versionKeyName.StartsWith("v"))
                {

                    Microsoft.Win32.RegistryKey versionKey = ndpKey.OpenSubKey(versionKeyName);
                    string name = (string)versionKey.GetValue("Version", "");
                    string sp = versionKey.GetValue("SP", "").ToString();
                    string install = versionKey.GetValue("Install", "").ToString();
                    if (install == "") //no install info, ust be later
                        ltFramework.Text += " <p> " + versionKeyName + "  " + name + "</p>";
                    else
                    {
                        if (sp != "" && install == "1")
                        {
                            ltFramework.Text += " <p>" + versionKeyName + "  " + name + "  SP" + sp + "</p>";
                        }

                    }
                    if (name != "")
                    {
                        continue;
                    }
                    foreach (string subKeyName in versionKey.GetSubKeyNames())
                    {
                        Microsoft.Win32.RegistryKey subKey = versionKey.OpenSubKey(subKeyName);
                        name = (string)subKey.GetValue("Version", "");
                        if (name != "")
                            sp = subKey.GetValue("SP", "").ToString();
                        install = subKey.GetValue("Install", "").ToString();
                        if (install == "") //no install info, ust be later
                            ltFramework.Text += " <p> " + versionKeyName + "  " + name + "</p>";
                        else
                        {
                            if (sp != "" && install == "1")
                            {
                                ltFramework.Text += " <p> " + "  " + subKeyName + "  " + name + "  SP" + sp;
                            }
                            else if (install == "1")
                            {
                                ltFramework.Text += " <p> &nbsp;&nbsp;&nbsp;" + "  " + subKeyName + "  " + name;
                            }
                        }
                    }
                }
            }
        }
    }

    /// <summary>
    /// IIS
    /// </summary>
    /// <returns></returns>
    public Version GetIISVersion()
    {
        using (Microsoft.Win32.RegistryKey componentsKey =
        Microsoft.Win32.Registry.LocalMachine.OpenSubKey(@"Software\Microsoft\InetStp", false))
        {
            if (componentsKey != null)
            {
                int majorVersion = (int)componentsKey.GetValue("MajorVersion", -1);
                int minorVersion = (int)componentsKey.GetValue("MinorVersion", -1);
                if (majorVersion != -1 && minorVersion != -1)
                {
                    return new Version(majorVersion, minorVersion);
                }
            }
            return new Version(0, 0);
        }
    }
</script>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hackafortanfoni Server Status Checker</title>
    <style type="text/css">
        html {
            background-color: #e2e2e2;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #fff;
            border-top: solid 10px #000;
            color: #333;
            font-size: .85em;
            font-family: "Segoe UI", Verdana, Helvetica, Sans-Serif;
            margin: 0;
            padding: 0;
        }

        a {
            color: #333;
            outline: none;
            padding-left: 3px;
            padding-right: 3px;
            text-decoration: underline;
        }

            a:link, a:visited,
            a:active, a:hover {
                color: #333;
            }

            a:hover {
                background-color: #c7d1d6;
            }

        header, footer, hgroup,
        nav, section {
            display: block;
        }

        mark {
            background-color: #a6dbed;
            padding-left: 5px;
            padding-right: 5px;
        }

        .float-left {
            float: left;
        }

        .float-right {
            float: right;
        }

        .clear-fix:after {
            content: ".";
            clear: both;
            display: block;
            height: 0;
            visibility: hidden;
        }

        h1, h2, h3,
        h4, h5, h6 {
            color: #000;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        h1 {
            font-size: 2em;
        }

        h2 {
            font-size: 1.75em;
        }

        h3 {
            font-size: 1.2em;
        }

        h4 {
            font-size: 1.1em;
        }

        h5, h6 {
            font-size: 1em;
        }

            h5 a:link, h5 a:visited, h5 a:active {
                padding: 0;
                text-decoration: none;
            }

        /* main layout
----------------------------------------------------------*/
        .content-wrapper {
            margin: 0 auto;
            max-width: 960px;
        }

        #body {
            background-color: #efeeef;
            clear: both;
            padding-bottom: 35px;
        }

        .main-content {
            background: url("../Images/accent.png") no-repeat;
            padding-left: 10px;
            padding-top: 30px;
        }

        .featured + .main-content {
            background: url("../Images/heroAccent.png") no-repeat;
        }

        header .content-wrapper {
            padding-top: 20px;
        }

        footer {
            clear: both;
            background-color: #e2e2e2;
            font-size: .8em;
            height: 100px;
        }


        /* site title
----------------------------------------------------------*/
        .site-title {
            color: #c8c8c8;
            font-family: Rockwell, Consolas, "Courier New", Courier, monospace;
            font-size: 2.3em;
            margin: 0;
        }

            .site-title a, .site-title a:hover, .site-title a:active {
                background: none;
                color: #c8c8c8;
                outline: none;
                text-decoration: none;
            }

        /* forms */
        fieldset {
            border: none;
            margin: 0;
            padding: 0;
        }

            fieldset legend {
                display: none;
            }

            fieldset ol {
                padding: 0;
                list-style: none;
            }

                fieldset ol li {
                    padding-bottom: 5px;
                }

        label {
            display: block;
            font-size: 1.2em;
            font-weight: 600;
        }

            label.checkbox {
                display: inline;
            }

        input, textarea {
            border: 1px solid #e2e2e2;
            background: #fff;
            color: #333;
            font-size: 1.2em;
            margin: 5px 0 6px 0;
            padding: 5px;
            width: 300px;
        }

        textarea {
            font-family: inherit;
            width: 500px;
        }

            input:focus, textarea:focus {
                border: 1px solid #7ac0da;
            }

        input[type="checkbox"] {
            background: transparent;
            border: inherit;
            width: auto;
        }

        input[type="submit"],
        input[type="button"],
        button {
            background-color: #d3dce0;
            border: 1px solid #787878;
            cursor: pointer;
            font-size: 1.2em;
            font-weight: 600;
            padding: 7px;
            margin-right: 8px;
            width: auto;
        }

        td input[type="submit"],
        td input[type="button"],
        td button {
            font-size: 1em;
            padding: 4px;
            margin-right: 4px;
        }

        #socialLoginForm {
            float: left;
            margin-left: 40px;
            width: 40%;
        }

        #loginForm {
            border-right: 2px solid #C8C8C8;
            float: left;
            width: 55%;
        }
    </style>

</head>
<body>
    <form id="Form1" runat="server">
        <header>
            <div class="content-wrapper">
                <div class="float-left">
                    <p class="site-title">Server Status Checker</p>
                </div>
                <div class="float-right">
                </div>
            </div>
        </header>
        <div id="body">
            <section class="content-wrapper main-content clear-fix">
                <hgroup class="title">
                    <h1>.NET Framework version list</h1>
                </hgroup>
                <asp:Literal ID="ltFramework" runat="server"></asp:Literal>
                <hgroup class="title">
                    <h1>IIS version </h1>
                </hgroup>
                <asp:Literal ID="ltIIS" runat="server"></asp:Literal>
                <hgroup class="title">
                    <h1>SQL Server</h1>
                </hgroup>
                <section id="loginForm">
                    <fieldset>
                        <legend>Log in Form</legend>
                        <ol>
                            <li>
                                <label for="">Server</label>
                                <asp:TextBox runat="server" ID="txtServer" />
                            </li>
                            <li>
                                <label for="">Database</label>
                                <asp:TextBox runat="server" ID="txtDatabase" />
                            </li>
                            <li>
                                <label for="">User Name</label>
                                <asp:TextBox runat="server" ID="txtUserName" />
                            </li>
                            <li>
                                <label for="">Password</label>
                                <asp:TextBox runat="server" ID="txtPassword" />
                            </li>
                        </ol>
                        <asp:Button ID="btnCheckSQL" runat="server" Text="Check SQL" OnClick="btnCheckSQL_Click" />
                    </fieldset>
                </section>
                <section id="socialLoginForm">
                    <h2>SQL Status Log</h2>
                    <asp:Literal ID="ltSQLStatus" runat="server"></asp:Literal>
                </section>
            </section>

        </div>
        <footer>
            <div class="content-wrapper">
                <div class="float-left">
                    <p>&copy; <%: DateTime.Now.Year %> - HackaFortanFoni Server Status Checker</p>
                </div>
            </div>
        </footer>
    </form>
</body>

</html>
