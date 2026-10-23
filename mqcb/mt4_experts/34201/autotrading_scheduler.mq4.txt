#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-expert-advisors/AutoTrading-Scheduler/"
#property version   "1.00"
string    Version = "1.00";
#property strict

#property description "Creates a weekly schedule when AutoTrading is enabled."
#property description "Disables AutoTrading during all other times."
#property description "Can also close all trades before disabling AutoTrading.\r\n"
#property description "WARNING: There is no guarantee that the expert advisor will work as intended. Use at your own risk."

#include "AutoTrading Scheduler.mqh";

input int Slippage = 2; // Slippage
input bool PanelOnTopOfChart = true; // PanelOnTopOfChart: Draw chart as background?

CScheduler Panel;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+ 
int OnInit()
{
   if (!Panel.LoadSettingsFromDisk())
   {
      sets.TimeType = Local;
	   sets.ClosePos = true;
	   sets.TurnedOn = false;
	   sets.Monday = "";
	   sets.Tuesday = "";
	   sets.Wednesday = "";
	   sets.Thursday = "";
	   sets.Friday = "";
	   sets.Saturday = "";
	   sets.Sunday = "";
   }  
	
   EventSetTimer(1);
   if (!Panel.Create(0, "AutoTrading Scheduler (ver. " + Version + ")", 0, 20, 20)) return(-1);
   Panel.Run();
   Panel.IniFileLoad();

   // Brings panel on top of other objects without actual maximization of the panel.
   Panel.HideShowMaximize(false);

	Panel.RefreshPanelControls();
   Panel.RefreshValues();

	ChartSetInteger(0, CHART_FOREGROUND, !PanelOnTopOfChart);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
{
   EventKillTimer();
   if ((reason == REASON_REMOVE) || (reason == REASON_CHARTCLOSE) || (reason == REASON_PROGRAM))
   {
		Panel.DeleteSettingsFile();
		Print("Trying to delete ini file.");
		if (!FileIsExist(Panel.IniFileName() + ".dat")) Print("File doesn't exist.");
		else if (!FileDelete(Panel.IniFileName() + ".dat")) Print("Failed to delete file: " + Panel.IniFileName() + ".dat. Error: " + IntegerToString(GetLastError()));
      else Print("Deleted ini file successfully.");
   }  
   else
   {
		Panel.SaveSettingsOnDisk();
		Panel.IniFileSave();
   } 
   Panel.Destroy();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Remember the panel's location to have the same location for minimized and maximized states.
   if ((id == CHARTEVENT_CUSTOM + ON_DRAG_END) && (lparam == -1))
   {
      Panel.remember_top = Panel.Top();
      Panel.remember_left = Panel.Left();
   }

	// Call Panel's event handler only if it is not a CHARTEVENT_CHART_CHANGE - workaround for minimization bug on chart switch.
   if (id != CHARTEVENT_CHART_CHANGE) Panel.OnEvent(id, lparam, dparam, sparam);

   if (Panel.Top() < 0) Panel.Move(Panel.Left(), 0);
}

void OnTick()
{
   Panel.RefreshValues();
   Panel.CheckTimer();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
   Panel.RefreshValues();
   Panel.CheckTimer();
   ChartRedraw();
}