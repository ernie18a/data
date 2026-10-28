//+------------------------------------------------------------------+
//|                                                 MinMax2years.mq5 |
//|                                   Copyright 2013, Alain Verleyen |
//|                       https://www.mql5.com/en/users/angevoyageur |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Alain Verleyen"
#property link      "https://www.mql5.com/en/users/angevoyageur"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
//--- input parameters
input datetime MinMaxFrom=0;     // 0 = 2 years, otherwise enter your past date
//--- globals
datetime fromDate;
double   pastmin=DBL_MAX;
double   pastmax=-DBL_MIN;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- input parameter checking
   if(MinMaxFrom==0)
      fromDate=TimeCurrent()-2*365*24*3600;    // Approximately 2 years, can be modified for more accuracy
   else if(MinMaxFrom<TimeCurrent())
      fromDate=MinMaxFrom;
   else
      return(INIT_PARAMETERS_INCORRECT);
//---
   if(!ObjectCreate(0,"MaxHLine",OBJ_HLINE,0,0,0) || 
      !ObjectCreate(0,"MinHLine",OBJ_HLINE,0,0,0))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,0,OBJ_HLINE);
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
   int limit=(prev_calculated==0) ? 0 : prev_calculated-1;
//---
   for(int i=limit;i<rates_total;i++)
     {
      if(time[i]>=fromDate)
        {
         if(high[i]>pastmax)
            pastmax=high[i];
         if(low[i]<pastmin)
            pastmin=low[i];
        }
     }
    ObjectMove(0,"MaxHLine",0,TimeCurrent(),pastmax);
    ObjectMove(0,"MinHLine",0,TimeCurrent(),pastmin);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
