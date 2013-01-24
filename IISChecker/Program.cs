// Server Status Checker
//
// Copyright © Hackafortani, 2013
// Developed by Ilyas Kolasinac Osmanogullari || http://www.ilyax.com
// http://www.hackafortanfoni.com || http://www.alafortanfoni.com
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using Microsoft.Win32;


namespace IISChecker
{
    class Program
    {

        public static string server { get; set; }
        public static string database { get; set; }
        public static string username { get; set; }
        public static string password { get; set; }
        static ConsoleSpinner sp = new ConsoleSpinner();
        static Thread th;

        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("");
                Console.WriteLine("--------------------- HackaFortanFoni Server Status Checker ----------------------");

                Console.WriteLine("********* --- .NET Framework Version --- **************************************");
                CheckFrameworkVersion();
                Console.WriteLine("********* --- .NET Framework Version End /--- *********************************");

                Console.WriteLine("");
                Console.WriteLine("********* --- IIS Version --- **************************************");
                Console.WriteLine(GetIISVersion());
                Console.WriteLine("********* --- .IIS Version End /--- *********************************");

                Console.WriteLine("");
                Console.WriteLine("********* --- SQL Server --- **************************************");
                Console.WriteLine("Do you want to check SQL SERVER Y/N");
                string sqlCheck = Console.ReadLine().ToUpper();
                if (sqlCheck == "Y")
                {
                    Console.Write("Server = ");
                    server = Console.ReadLine();
                    Console.Write("Database = ");
                    database = Console.ReadLine();
                    Console.Write("UserName = ");
                    username = Console.ReadLine();
                    Console.Write("Password = ");
                    password = Console.ReadLine();
                    CheckSQLServer();
                }
                Console.WriteLine("********* --- SQL Server End /--- *********************************");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            Console.ReadLine();
        }

        /// <summary>
        /// .NET Framework
        /// </summary>
        public static void CheckFrameworkVersion()
        {
            using (RegistryKey ndpKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32).OpenSubKey(@"SOFTWARE\Microsoft\NET Framework Setup\NDP\"))
            {
                foreach (string versionKeyName in ndpKey.GetSubKeyNames())
                {
                    if (versionKeyName.StartsWith("v"))
                    {

                        RegistryKey versionKey = ndpKey.OpenSubKey(versionKeyName);
                        string name = (string)versionKey.GetValue("Version", "");
                        string sp = versionKey.GetValue("SP", "").ToString();
                        string install = versionKey.GetValue("Install", "").ToString();
                        if (install == "") //no install info, ust be later
                            Console.WriteLine(versionKeyName + "  " + name);
                        else
                        {
                            if (sp != "" && install == "1")
                            {
                                Console.WriteLine(versionKeyName + "  " + name + "  SP" + sp);
                            }

                        }
                        if (name != "")
                        {
                            continue;
                        }
                        foreach (string subKeyName in versionKey.GetSubKeyNames())
                        {
                            RegistryKey subKey = versionKey.OpenSubKey(subKeyName);
                            name = (string)subKey.GetValue("Version", "");
                            if (name != "")
                                sp = subKey.GetValue("SP", "").ToString();
                            install = subKey.GetValue("Install", "").ToString();
                            if (install == "") //no install info, ust be later
                                Console.WriteLine(versionKeyName + "  " + name);
                            else
                            {
                                if (sp != "" && install == "1")
                                {
                                    Console.WriteLine("  " + subKeyName + "  " + name + "  SP" + sp);
                                }
                                else if (install == "1")
                                {
                                    Console.WriteLine("  " + subKeyName + "  " + name);
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
        public static Version GetIISVersion()
        {
            using (RegistryKey componentsKey =
            Registry.LocalMachine.OpenSubKey(@"Software\Microsoft\InetStp", false))
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

        /// <summary>
        /// SQL Server
        /// </summary>
        public static void CheckSQLServer()
        {
            try
            {
                string connectionString = string.Format("Server={0};Database={1};User Id={2};Password={3};", server, database, username, password);

                using (SqlConnection conn =
                       new SqlConnection(connectionString))
                {
                    SqlCommand cmd = conn.CreateCommand();
                    cmd.CommandText = "SELECT * FROM INFORMATION_SCHEMA.TABLES";

                    th = new Thread(new ThreadStart(loading));
                    th.Start();

                    conn.Open();

                    th.Abort();
                    Console.WriteLine("");

                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        Console.WriteLine(dr.GetString(2));
                    }
                }
            }
            catch (Exception ex)
            {
                th.Abort();
                Console.WriteLine(ex.ToString());
            }
        }

        /// <summary>
        /// Loading Animation
        /// </summary>
        private static void loading()
        {
            while (true)
            {
                sp.Turn();
            }
        }

    }//class end

    class ConsoleSpinner
    {
        int counter;
        public void ConsoleSpiner()
        {
            counter = 0;
        }
        public void Turn()
        {
            counter++;
            switch (counter % 4)
            {
                case 0: Console.Write("/"); break;
                case 1: Console.Write("-"); break;
                case 2: Console.Write("\\"); break;
                case 3: Console.Write("|"); break;
            }
            Console.SetCursorPosition(Console.CursorLeft - 1, Console.CursorTop);
            System.Threading.Thread.Sleep(100);
        }
    }
}
