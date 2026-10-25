//+-------------------------------------------------------------------+
//|                                            wd.Multi_SubWindow.mq5 |
//|                 Copyright © 2023, Karya Prima Rajasa Mediavestama |
//|                                  Programmed by widhie75@yahoo.com |
//+-------------------------------------------------------------------+
#property copyright   "Copyright © 2023, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/users/widhie75"
#property version     "2.23"
#property description "An empty sub-window provides space for information, labels, simple notes, and works simultaneously with other 'wd.Multi/Range' EAs or indicators."

#property indicator_separate_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
