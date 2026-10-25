//+------------------------------------------------------------------+
//|                                          Mage Moving Average-RMA |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mage"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Slow Speed Line
#property indicator_label1  "RMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int InpPeriod   =12;   //RMA Period

//--- indicator buffers
double    buffer_m[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer_m,INDICATOR_DATA);
//--- set Digits
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---name
   IndicatorSetString(INDICATOR_SHORTNAME,"Mage_RMA"+string(InpPeriod));
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriod);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double& price[])
  {
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriod,price,buffer_m);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculation Buffer                                               |
//+------------------------------------------------------------------+
int ExponentialMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,const int period,const double& price[],double& buffer[])
  {
//--- check period
   if(period<=1 || period>(rates_total-begin))
      return(0);
//--- save and clear 'as_series' flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);

   ArraySetAsSeries(price,false);
   ArraySetAsSeries(buffer,false);
//--- calculate start position
   int    start_position;
   double smooth_factor=1.0/period;

   if(prev_calculated==0)  // first calculation or number of bars was changed
     {
      //--- set empty value for first bars
      for(int i=0; i<begin; i++)
         buffer[i]=0.0;
      //--- calculate first visible value
      start_position=period+begin;
      buffer[begin] =price[begin];

      for(int i=begin+1; i<start_position; i++)
         buffer[i]=price[i]*smooth_factor+buffer[i-1]*(1.0-smooth_factor);
     }
   else
      start_position=prev_calculated-1;
//--- main loop
   for(int i=start_position; i<rates_total; i++)
      buffer[i]=price[i]*smooth_factor+buffer[i-1]*(1.0-smooth_factor);
//--- restore as_series flags
   ArraySetAsSeries(price,as_series_price);
   ArraySetAsSeries(buffer,as_series_buffer);
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
