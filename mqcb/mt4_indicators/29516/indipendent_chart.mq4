//+------------------------------------------------------------------+
//|                                            Indipendent Chart.mq4 |
//|                                  Copyright © All rights reserved |
//|                                            https://LossForex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © All rights reserved"
#property link      "https://LossForex.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//---
extern bool Indipendent_TimeFrame = true;       // Indipendent TimeFrame
int period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//--- Detect Current Timeframe
   if(Period() == 1){period = OBJ_PERIOD_M1;}
   else if(Period() == 5){period = OBJ_PERIOD_M5;}
   else if(Period() == 15){period = OBJ_PERIOD_M15;}
   else if(Period() == 30){period = OBJ_PERIOD_M30;}
   else if(Period() == 60){period = OBJ_PERIOD_H1;}
   else if(Period() == 240){period = OBJ_PERIOD_H4;}
   else if(Period() == 1440){period = OBJ_PERIOD_D1;}
   else if(Period() == 10080){period = OBJ_PERIOD_W1;}
   else {period = OBJ_PERIOD_MN1;}
   
//--- Display / Hide Object
   Indipendent();
   EventSetTimer(1);
//---
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
   Indipendent();
//---
  }
//+------------------------------------------------------------------+
void Indipendent()
{
   for(int i=0;i<ObjectsTotal();i++)
     {
      string ToolTop = ObjectGetString(0, ObjectName(i), OBJPROP_TOOLTIP);
      if(ToolTop == "")
        {
         ObjectSetString(0, ObjectName(i), OBJPROP_TOOLTIP, Symbol()+(string)period);
        }
      else
        {
         string getsymbol = StringSubstr(ToolTop, 0, StringLen(Symbol()));
         string getperiod = StringSubstr(ToolTop, StringLen(Symbol()), 0);
         if(getsymbol == Symbol() && (!Indipendent_TimeFrame || getperiod == (string)period))
           {
            ObjectSetInteger(0, ObjectName(i), OBJPROP_TIMEFRAMES, period);
           }
         else
           {
            ObjectSetInteger(0, ObjectName(i), OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
           }
        }
     }
}
//---