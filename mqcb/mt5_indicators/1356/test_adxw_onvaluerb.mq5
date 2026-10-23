//+------------------------------------------------------------------+
//|                                          Test_ADXW_OnValueRB.mq5 |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Konstantin Gruzdev"
#property link      "https://www.mql5.com/ru/users/lizar"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrBlue
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "Label3"
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_color3  clrYellow
#property indicator_width3  1
//--- plot Label4
#property indicator_label4  "Label4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMagenta
#property indicator_width4  1
//--- plot Label5
#property indicator_label5  "Label5"
#property indicator_type5   DRAW_LINE
#property indicator_style5  STYLE_DOT
#property indicator_color5  clrDodgerBlue
#property indicator_width5  1
//--- plot Label6
#property indicator_label6  "Label6"
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_DOT
#property indicator_color6  clrLime
#property indicator_width6  1

//--- input parameters
input int            MAPeriod = 14;
input ENUM_MA_METHOD MAMethod = MODE_SMMA;
//--- indicator buffers
double         ADXW_Buffer[];
double         PDI_Buffer[];
double         NDI_Buffer[];
double         ADXW_RingBuffer[];
double         PDI_RingBuffer[];
double         NDI_RingBuffer[];
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
   SetIndexBuffer(3,ADXW_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(3,PLOT_LABEL,"RB"+adxw.NameADXW());
   SetIndexBuffer(4,PDI_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(4,PLOT_LABEL,"RB"+adxw.NamePDI());
   SetIndexBuffer(5,NDI_RingBuffer,INDICATOR_DATA);
   PlotIndexSetString(5,PLOT_LABEL,"RB"+adxw.NameNDI());
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
//--- first calculation:
   int start=0, begin=0, start1=0;
   if(prev_calculated==0)
     {
      start1=rates_total-adxw.Size()+1;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
      ArrayInitialize(ADXW_Buffer,EMPTY_VALUE);
      ArrayInitialize(PDI_Buffer,EMPTY_VALUE);
      ArrayInitialize(NDI_Buffer,EMPTY_VALUE);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start1);
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,start1);
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,start1);
      ArrayInitialize(ADXW_RingBuffer,EMPTY_VALUE);
      ArrayInitialize(PDI_RingBuffer,EMPTY_VALUE);
      ArrayInitialize(NDI_RingBuffer,EMPTY_VALUE);
     }
//--- number of bars was changed:
   else start=start1=prev_calculated-1;     
//--- calculate and draw the indicator:     
   for(int i=start;i<rates_total;i++)
     {
      // average directional movement index Wilder
      ADXW_Buffer[i]=adxw.MainOnValue(rates_total,prev_calculated,begin,high[i],low[i],close[i],i);
      // positive directional index
      PDI_Buffer[i]=adxw.pdi.Last();
      // negative directional index
      NDI_Buffer[i]=adxw.ndi.Last();
     }
//--- use the data from the "adxw" ring buffer,
//    copy data to the indicator buffers:
   for(int i=start1;i<rates_total;i++)
     {
      ADXW_RingBuffer[i] = adxw[rates_total-1-i];      // average directional movement index Wilder
      PDI_RingBuffer[i]  = adxw.pdi[rates_total-1-i];  // positive directional index
      NDI_RingBuffer[i]  = adxw.ndi[rates_total-1-i];  // negative directional index
     }
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
//+------------------------------------------------------------------+