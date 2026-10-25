//+------------------------------------------------------------------+
//|                                                     isNewBar.mq5 |
//|                                          Copyright Privalov S.V. |
//|                             https://www.mql5.com/en/users/prival |
//+------------------------------------------------------------------+
#property copyright "Privalov S.V."
#property link      "https://www.mql5.com/en/users/prival"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // rates total
                 const int prev_calculated,  // rates calculated after the previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[])        // Spread
  {
//---
   if(rates_total<0) return(0);   // do not calculate anything
   if(prev_calculated==0) {       // first call (reserved)
   }
   //*******************************************************************
   // this code will be executed at every new tick
      if(isNewBar(PERIOD_M1 )) Print("New bar at M1 ",  TimeCurrent());
      if(isNewBar(PERIOD_M5 )) Print("New bar at M5 ",  TimeCurrent());
      if(isNewBar(PERIOD_M15)) Print("New bar at M15",  TimeCurrent());
   //*******************************************************************   
return(rates_total);
  }

//+------------------------------------------------------------------+
//| Returns true if a new bar has appeared, overwise return false    |
//+------------------------------------------------------------------+
bool isNewBar(ENUM_TIMEFRAMES timeFrame)
  {
//----
   static datetime old_Times[21];// an array for old time values
   bool res=false;               // variable for the result
   int  i=0;                     // index of old_Times[] array
   datetime new_Time[1];         // time of a new bar

   switch(timeFrame)
     {
      case PERIOD_M1:  i= 0; break;
      case PERIOD_M2:  i= 1; break;
      case PERIOD_M3:  i= 2; break;
      case PERIOD_M4:  i= 3; break;
      case PERIOD_M5:  i= 4; break;
      case PERIOD_M6:  i= 5; break;
      case PERIOD_M10: i= 6; break;
      case PERIOD_M12: i= 7; break;
      case PERIOD_M15: i= 8; break;
      case PERIOD_M20: i= 9; break;
      case PERIOD_M30: i=10; break;
      case PERIOD_H1:  i=11; break;
      case PERIOD_H2:  i=12; break;
      case PERIOD_H3:  i=13; break;
      case PERIOD_H4:  i=14; break;
      case PERIOD_H6:  i=15; break;
      case PERIOD_H8:  i=16; break;
      case PERIOD_H12: i=17; break;
      case PERIOD_D1:  i=18; break;
      case PERIOD_W1:  i=19; break;
      case PERIOD_MN1: i=20; break;
     }
   // copying the last bar time to the element new_Time[0]
   int copied=CopyTime(_Symbol,timeFrame,0,1,new_Time);
   
   if(copied>0) // ok, the data has been copied successfully
      {
      if(old_Times[i]!=new_Time[0])       // if old time isn't equal to new bar time
         {
         if(old_Times[i]!=0) res=true;    // if it isn't a first call, the new bar has appeared
         old_Times[i]=new_Time[0];        // saving bar time
         }
      }
//----
   return(res);
  }
