//+------------------------------------------------------------------+
//|                                                        iMax3.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "iMAX3 - Fast Trend Detector"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot HPX0
#property indicator_label1  "HPX0"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot HPX1
#property indicator_label2  "HPX1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot HP0
#property indicator_label3  "HP0"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrPeru
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot HP1
#property indicator_label4  "HP1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrPlum
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot IMAX0
#property indicator_label5  "IMAX0"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot IMAX1
#property indicator_label6  "IMAX1"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input double            InpStepHP   =  0.0;        // Step
input ENUM_INPUT_YES_NO InpAutoStep =  INPUT_YES;  // Auto step mode
input ENUM_INPUT_YES_NO InpModeIMAX =  INPUT_YES;  // Use iMAX mode
input ENUM_INPUT_YES_NO InpModeHP   =  INPUT_YES;  // Use HP mode
input ENUM_INPUT_YES_NO InpModeHPX  =  INPUT_YES;  // Use HPX mode
//--- indicator buffers
double         BufferHPX0[];
double         BufferHPX1[];
double         BufferHP0[];
double         BufferHP1[];
double         BufferIMAX0[];
double         BufferIMAX1[];
//--- global variables
double         step;
int            digits;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   step=(!InpAutoStep ? fabs(InpStepHP) : GetStep());
   digits=Digits();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHPX0,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHPX1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHP0,INDICATOR_DATA);
   SetIndexBuffer(3,BufferHP1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferIMAX0,INDICATOR_DATA);
   SetIndexBuffer(5,BufferIMAX1,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"iMAX3 ("+DoubleToString(step,5)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpModeHPX);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,InpModeHPX);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpModeHP);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpModeHP);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,InpModeIMAX);
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,InpModeIMAX);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHPX0,true);
   ArraySetAsSeries(BufferHPX1,true);
   ArraySetAsSeries(BufferHP0,true);
   ArraySetAsSeries(BufferHP1,true);
   ArraySetAsSeries(BufferIMAX0,true);
   ArraySetAsSeries(BufferIMAX1,true);
//---
   ChartRedraw();
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-4;
      ArrayInitialize(BufferHPX0,EMPTY_VALUE);
      ArrayInitialize(BufferHPX1,EMPTY_VALUE);
      ArrayInitialize(BufferHP0,EMPTY_VALUE);
      ArrayInitialize(BufferHP1,EMPTY_VALUE);
      ArrayInitialize(BufferIMAX0,EMPTY_VALUE);
      ArrayInitialize(BufferIMAX1,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHPX1[i]=NormalizeDouble(0.13785*(high[i]+low[i]-(high[i+1]+low[i+1])/2.0)+0.0007*(high[i+1]+low[i+1]-(high[i+2]+low[i+2])/2.0)+0.13785*(high[i+2]+low[i+2]-(high[i+3]+low[i+3])/2.0)+1.2103*BufferHPX0[i+1]-0.4867*BufferHPX0[i+2],digits);
      BufferHPX0[i]=(close[i]>BufferHPX1[i] ? BufferHPX1[i]+step : BufferHPX1[i]-step);
      BufferIMAX0[i]=NormalizeDouble(0.13785*(high[i]+low[i]-(high[i+1]+low[i+1])/2.0)+0.0007*(high[i+1]+low[i+1]-(high[i+2]+low[i+2])/2.0)+0.13785*(high[i+2]+low[i+2]-(high[i+3]+low[i+3])/2.0)+1.2103*BufferIMAX0[i+1]-0.4867*BufferIMAX0[i+2],digits);
      BufferHP1[i]=BufferIMAX0[i];
      BufferIMAX1[i]=BufferIMAX0[i+1];
      BufferHP0[i]=(close[i]>BufferIMAX0[i] ? BufferIMAX0[i]+step : BufferIMAX0[i]-step);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStep(void)
  {
   return
     (
      Period()<PERIOD_M5   ?  0.0001   :
      Period()<PERIOD_M15  ?  0.00015  :
      Period()<PERIOD_M30  ?  0.0003   :
      Period()<PERIOD_H1   ?  0.0005   :
      Period()<PERIOD_H4   ?  0.00075  :
      Period()<PERIOD_D1   ?  0.0015   :
      Period()<PERIOD_W1   ?  0.003    :
      Period()<PERIOD_MN1  ?  0.005    : 
                              0.01
     );
  }  
//+------------------------------------------------------------------+
