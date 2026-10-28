//+------------------------------------------------------------------+
//|                                          Test_ADXW_OnArrayRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label1"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrBlue
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "Label1"
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_color3  clrYellow
#property indicator_width3  1
//--- input parameters
input int            MAPeriod = 14;
input ENUM_MA_METHOD MAMethod = MODE_SMMA;
//--- indicator buffers
double         ADXW_Buffer[];
double         PDI_Buffer[];
double         NDI_Buffer[];
//--- class with the ADXW indicator calculation methods
#include <IncOnRingBuffer\CADXWOnRingBuffer.mqh>
CADXWOnRingBuffer adxw;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialize the ADXW indicator class instance:
   if(!adxw.Init(MAPeriod,MAMethod)) return(INIT_FAILED);
//--- indicator setting
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- indicator buffers mapping
   SetIndexBuffer(0,ADXW_Buffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,adxw.NameADXW());
   SetIndexBuffer(1,PDI_Buffer,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,adxw.NamePDI());
   SetIndexBuffer(2,NDI_Buffer,INDICATOR_DATA);
   PlotIndexSetString(2,PLOT_LABEL,adxw.NameNDI());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//--- indicator calculation, based on the price timeseries
   adxw.MainOnArray(rates_total,prev_calculated,high,low,close);
//--- first calculation:
   int start=0;
   if(prev_calculated==0)
     {
      start=rates_total-adxw.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(ADXW_Buffer,EMPTY_VALUE);
      ArrayInitialize(PDI_Buffer,EMPTY_VALUE);
      ArrayInitialize(NDI_Buffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=prev_calculated-1;    
//--- use the data from the "adxw" ring buffer,
//    copy data to the indicator buffers:
   for(int i=start;i<rates_total;i++)
     {
      ADXW_Buffer[i]=adxw[rates_total-1-i];       // average directional movement index
      PDI_Buffer[i]=adxw.pdi[rates_total-1-i];   // positive directional index
      NDI_Buffer[i]=adxw.ndi[rates_total-1-i];   // negative directional index
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+