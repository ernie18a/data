//+------------------------------------------------------------------+
//|                                            Disconnect_Alerts.mq5 |
//|                            Copyright 2023, Ryan Lawrence Johnson |
//|                         https://www.mql5.com/en/users/rjo/seller |
//+------------------------------------------------------------------+
#property copyright "© 2023, Ryan Lawrence Johnson"
#property link      "https://www.mql5.com/en/users/rjo/seller"
#property version   "1.00"
#property indicator_chart_window

#include <Trade/TerminalInfo.mqh>
CTerminalInfo terminalInfo;

input int CheckEvery__ms = 100;
input bool PopUpAlerts = true; 
input bool SoundAlerts = false; 
input bool TextAlerts = false; 
input bool EmailAlerts = false; 
input bool ExpertsTab = false;
input bool ChartLabel = true;
input int LabelXdistance = 70;
input int LabelYdistance = 320;

uint connectionTime;
uint disconnectionTime;
uint differenceTime;

int lastChange;
int hourCount;
int minuteCount;
int secondCount;
int millisecondCount;

ulong localTime;
string strLocalTime;

string name;

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, name);
  
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   connectionTime = 0;
   disconnectionTime = 0;
   differenceTime = 0;
   
   lastChange = 0;
   hourCount = 0;
   minuteCount = 0;
   secondCount = 0;
   millisecondCount = 0;
   
   if(ChartLabel == true)
  	{
  	 name = "Chart_Label";
  	
	 ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
	 ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
	 ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	 ObjectSetInteger(0, name, OBJPROP_XDISTANCE, LabelXdistance);
	 ObjectSetInteger(0, name, OBJPROP_YDISTANCE, LabelYdistance);
	 ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
	 ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
	 ObjectSetString(0, name, OBJPROP_FONT, "Arial");
	 ObjectSetString(0,name, OBJPROP_TEXT, "LOADING");
	 	  	 
  	}
   
   EventSetMillisecondTimer(CheckEvery__ms);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   //--- initial connection to server
   if(terminalInfo.IsConnected() == true && lastChange == 0)
    {
     connectionTime = GetTickCount(); //get current connected server time in milliseconds
     localTime = TimeLocal(); //local (client machine) time
     strLocalTime = StringFormat((string)(datetime)localTime,localTime); //convert local time to date, hour, minutes, and seconds
     
     if(PopUpAlerts == true)
      {
       Alert("DA indicator initially connected to server at " + strLocalTime);
      }
     if(SoundAlerts == true)
      {
       PlaySound("connect.wav");
      }
     if(TextAlerts == true)
      {
       SendNotification("DA indicator initially connected to server at " + strLocalTime);
      }
     if(EmailAlerts == true)
      {
       SendMail("Connected", "DA indicator initially connected to server at " + strLocalTime);
      }
     if(ExpertsTab == true)
      {
       Print("DA indicator initially connected to server at " + strLocalTime);
      }
     if(ChartLabel == true)
     	{
		 ObjectSetInteger(0, name, OBJPROP_COLOR, clrLime);
	 	 ObjectSetString(0,name, OBJPROP_TEXT, "SERVER CONNECTED");		 
     	}
     
     lastChange = 1;
    }   

   //--- disconnection from server      
   if(terminalInfo.IsConnected() == false && lastChange != 2 && lastChange != 0)
    {
     disconnectionTime = GetTickCount(); //get current disconnected server time in milliseconds
     localTime = TimeLocal(); //local (client machine) time
     strLocalTime = StringFormat((string)(datetime)localTime,localTime); //convert local time to date, hour, minutes, and seconds     
     
     if(PopUpAlerts == true)
      {
       Alert("MT5 disconnected from server at " + strLocalTime);
      }
      
     if(SoundAlerts == true)
      {
       PlaySound("disconnect.wav");
      }
      
     if(TextAlerts == true)
      {
       SendNotification("MT5 disconnected from server at " + strLocalTime);
      }
      
     if(EmailAlerts == true)
      {
       SendMail("Disconnected", "MT5 disconnected from server at " + strLocalTime);
      }
      
     if(ExpertsTab == true)
      {
       Print("MT5 disconnected at " + strLocalTime);
      }
     if(ChartLabel == true)
     	{
		 ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
	 	 ObjectSetString(0,name, OBJPROP_TEXT, "SERVER DISCONNECTED");		 
     	}      
     
     lastChange = 2;
    }

   //--- reconnection to server
   if(terminalInfo.IsConnected() == true && lastChange != 1 && lastChange != 0)
    {
     connectionTime = GetTickCount(); //get current reconnected server time in milliseconds
     differenceTime = connectionTime - disconnectionTime; //how long MT5 was disconnected from server in milliseconds
     localTime = TimeLocal(); //local (client machine) time
     strLocalTime = StringFormat((string)(datetime)localTime,localTime); //convert local time to date, hour, minutes, and seconds
     
     //calculate hours, minutes, seconds, and milliseconds from raw milliseconds          
     hourCount = (int)MathFloor(differenceTime / 3600000); //rounds down to the nearest integer

     minuteCount = (int)MathFloor((differenceTime - (hourCount * 3600000)) / 60000); //rounds down to the nearest integer

     secondCount = (int)MathFloor((differenceTime - (hourCount * 3600000) - (minuteCount * 60000)) / 1000); //rounds down to the nearest integer
      
     millisecondCount = (int)(differenceTime - (hourCount * 3600000) - (minuteCount * 60000) - (secondCount * 1000));
     
     if(PopUpAlerts == true)
     	{
     	 Alert("MT5 reconnected after " + (string)hourCount + " hrs, " + (string)minuteCount + " min, " +
                  (string)secondCount + " sec, and " + (string)millisecondCount + " milliseconds at " + strLocalTime);
      }
      
     if(SoundAlerts == true)
     	{
     	 PlaySound("connect.wav");
     	}
     	
     if(TextAlerts == true)
     	{
     	 SendNotification("MT5 reconnected after " + (string)hourCount + " hrs, " + (string)minuteCount + " min, " +
                  (string)secondCount + " sec, and " + (string)millisecondCount + " milliseconds at " + strLocalTime);
      }
      
     if(EmailAlerts == true)
     	{
     	 SendMail("Reconnected", "MT5 reconnected after " + (string)hourCount + " hrs, " + (string)minuteCount + " min, " +
                  (string)secondCount + " sec, and " + (string)millisecondCount + " milliseconds at " + strLocalTime);
      }
      
     if(ExpertsTab == true)
     	{
     	 Print("MT5 reconnected after " + (string)hourCount + " hrs, " + (string)minuteCount + " min, " +
                  (string)secondCount + " sec, and " + (string)millisecondCount + " milliseconds at " + strLocalTime);
      }
     if(ChartLabel == true)
     	{
		 ObjectSetInteger(0, name, OBJPROP_COLOR, clrLime);
	 	 ObjectSetString(0,name, OBJPROP_TEXT, "SERVER CONNECTED");		 
     	}     
     
     lastChange = 1;
    }      
  }

//+------------------------------------------------------------------+
