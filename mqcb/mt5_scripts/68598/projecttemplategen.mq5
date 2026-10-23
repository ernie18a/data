//+------------------------------------------------------------------+
//|                                           ProjectTemplateGen.mq5 |
//|                                Copyright 2025, Clemence Benjamin |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin"
#property link      "https://forge.mql5.io"
#property strict
#property description "Generates EA project template in MQL5//Files"
#property script_show_inputs
#property version "2.01"

//--- Inputs
input string ProjectName       = "Type your project name";//Project Name
input string AuthorName        = "Type your name eg. Clemence Benjamin"; // Author Name
input bool   CreateIncludeFile = true;// Generate a header file

//+------------------------------------------------------------------+
//| Script entry                                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("=== MQL5 Project Template Generator Started ===");
   Print("Project Name: ", ProjectName);
   Print("Author: ", AuthorName);

//--- ALLOWED sandbox path
   string projectPath = "Files\\" + ProjectName + "\\";

   Print("Target path (sandbox-safe): ", projectPath);

//--- Create project folder
   if(!FolderCreate(projectPath))
     {
      Print("ERROR: Cannot create project folder. Error: ", GetLastError());
      return;
     }

//--- Create EA file
   if(!CreateMainEA(projectPath + ProjectName + ".mq5"))
      return;

//--- Create include file
   if(CreateIncludeFile)
      CreateInclude(projectPath + ProjectName + ".mqh");

//--- Create manifest
   CreateManifest(projectPath + "README.txt");

   Print("SUCCESS: Project created in MQL5\\Files\\", ProjectName);
   Print("ACTION REQUIRED: Move folder to MQL5\\Experts\\ manually");
   Print("Folder path: ", TerminalInfoString(TERMINAL_DATA_PATH) + "\\" + projectPath);
  }

//+------------------------------------------------------------------+
//| Create main EA                                                   |
//+------------------------------------------------------------------+
bool CreateMainEA(const string filePath)
  {
   int h = FileOpen(filePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      Print("ERROR: Cannot create main EA file. Error: ", GetLastError());
      return false;
     }

   FileWrite(h,"//+------------------------------------------------------------------+");
   FileWrite(h,"//| " + ProjectName + ".mq5");
   FileWrite(h,"//| Author: " + AuthorName);
   FileWrite(h,"//+------------------------------------------------------------------+");
   FileWrite(h,"#property strict");
   FileWrite(h,"");
   FileWrite(h,"int OnInit()");
   FileWrite(h,"{");
   FileWrite(h,"   return INIT_SUCCEEDED;");
   FileWrite(h,"}");
   FileWrite(h,"");
   FileWrite(h,"void OnTick()");
   FileWrite(h,"{");
   FileWrite(h,"}");
   FileClose(h);
   return true;
  }

//+------------------------------------------------------------------+
//| Create include file                                              |
//+------------------------------------------------------------------+
void CreateInclude(const string filePath)
  {
   int h = FileOpen(filePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return;

   FileWrite(h,"#ifndef __" + ProjectName + "_MQH__");
   FileWrite(h,"#define __" + ProjectName + "_MQH__");
   FileWrite(h,"class C" + ProjectName + " {};");
   FileWrite(h,"#endif");
   FileClose(h);
  }

//+------------------------------------------------------------------+
//| Create manifest                                                  |
//+------------------------------------------------------------------+
void CreateManifest(const string filePath)
  {
   int h = FileOpen(filePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return;

   FileWrite(h,"PROJECT TEMPLATE");
   FileWrite(h,"Name: " + ProjectName);
   FileWrite(h,"Author: " + AuthorName);
   FileWrite(h,"");
   FileWrite(h,"NOTE:");
   FileWrite(h,"Move this folder to MQL5\\Experts\\ to compile.");
   FileClose(h);
  }
//+------------------------------------------------------------------+
