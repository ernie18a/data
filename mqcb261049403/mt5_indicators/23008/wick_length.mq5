//+------------------------------------------------------------------+
//|                                                  Wick_Length.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wick length indicator."
#property description "The indicator shows the candles lengths."
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot WL1
#property indicator_label1  "Upper wick"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot WL2
#property indicator_label2  "Lower wick"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_MODE
  {
   MODE_SEP,      // Separated
   MODE_SEP_OPP,  // Separated Opposite Only
   MODE_CML,      // Cumulative
   MODE_DIFF      // Difference
  };
//--- input parameters
input ENUM_MODE   InpMethod   =  MODE_SEP;   // Method
//--- indicator buffers
double         BufferWLup[];
double         BufferWLdn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWLup,INDICATOR_DATA);
   SetIndexBuffer(1,BufferWLdn,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wick length ("+MethodToString()+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting plot buffer parameters
   if(InpMethod==MODE_SEP)
     {
      PlotIndexSetString(0,PLOT_LABEL,"Upper wick");
      PlotIndexSetString(1,PLOT_LABEL,"Lower wick");
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
     }
   else if(InpMethod==MODE_SEP_OPP)
     {
      PlotIndexSetString(0,PLOT_LABEL,"Upper wick");
      PlotIndexSetString(1,PLOT_LABEL,"Lower wick");
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
     }
   else if(InpMethod==MODE_CML)
     {
      PlotIndexSetString(0,PLOT_LABEL,"Wick cumulative");
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
     }
   //--- MODE_DIFF
   else
     {
      PlotIndexSetString(0,PLOT_LABEL,"Wick difference");
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWLup,true);
   ArraySetAsSeries(BufferWLdn,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferWLup,EMPTY_VALUE);
      ArrayInitialize(BufferWLdn,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Up=(high[i]-fmax(open[i],close[i]))/Point();
      double Down=-(fmin(open[i],close[i])-low[i])/Point();

      if(InpMethod==MODE_SEP_OPP)
        {
         if(close[i]>open[i])
            Up=0;
         else
            Down=0;
        }
      if(InpMethod==MODE_SEP || InpMethod==MODE_SEP_OPP)
        {
         BufferWLup[i]=Up;
         BufferWLdn[i]=Down;
        }
      else
        {
         BufferWLdn[i]=EMPTY_VALUE;
         if(InpMethod==MODE_DIFF)
            BufferWLup[i]=Up-fabs(Down);
         else
            BufferWLup[i]=Up+fabs(Down);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MethodToString()
  {
   return(InpMethod==MODE_SEP ? "Separated" : InpMethod==MODE_SEP_OPP ? "Separated Opposite Only" : InpMethod==MODE_CML ? "Cumulative" : "Difference");
  }  
//+------------------------------------------------------------------+
