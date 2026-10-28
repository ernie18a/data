//+------------------------------------------------------------------+
//|                                                 StartProcess.mq4 |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Starts an external program of your choosing. You'll need to allow dll imports for this to work."
#property version   "1.00"
#property strict
#property script_show_inputs

#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
//+------------------------------------------------------------------+
//| Display options for the process window.                          |
//+------------------------------------------------------------------+
enum WindowDisplayStartMode
  {
   SW_SHOWNORMAL=1,//Default size, set focus.
   SW_MAXIMIZE=3,//Maximize, set focus.
   SW_SHOWNOACTIVATE=4,//Default size, do not set focus.
   SW_SHOWMINNOACTIVE=7,//Minimize, do not set focus.
  };
//+------------------------------------------------------------------+
//|Start a process by calling the ShellExecute "Open" action.        |
//+------------------------------------------------------------------+
void StartProcess(string executableName,string commandlineParameters,string workingDirectory,WindowDisplayStartMode displayMode)
  {
   int r= ShellExecuteW(0,"Open",executableName,commandlineParameters,workingDirectory,displayMode);
   if(r>=0 && r<32)
     {
      PrintFormat(StringFormat("Could not execute \"%s\", some error occurred.",executableName));
     }
  }
//--- input parameters
input string   ExecutableName="PowerShell"; //Executable name
input string   CommandlineParameters="-Command write-host \"Press any key to continue...\";[void][System.Console]::ReadKey($true);"; //Commandline parameters
input string   WorkingDirectory=""; //Working directory
input WindowDisplayStartMode     DisplayMode=SW_SHOWNORMAL; //Window display mode
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   StartProcess(ExecutableName,CommandlineParameters,WorkingDirectory,DisplayMode);
  }
//+------------------------------------------------------------------+
