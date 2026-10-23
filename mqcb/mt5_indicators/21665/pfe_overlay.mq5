//+------------------------------------------------------------------+
//|                                                  PFE_Overlay.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Polarized Fractal Efficiency Overlay indicator"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot PFE
#property indicator_label1  "PFE Overlay"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrTeal
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot TL
#property indicator_label2  "Top dev"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BL
#property indicator_label3  "Bottom dev"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodFastROC  =  1;    // Fast ROC period
input uint              InpPeriodSlowROC  =  9;    // Slow ROC period
input uint              InpPeriodMA       =  5;    // MA period
input int               InpPDS            =  10;   // PDS
input uint              InpPeriodAVG      =  20;   // Avg period
input double            InpDeviation      =  2.0;  // Deviation
input ENUM_INPUT_YES_NO InpShowDev  =  INPUT_YES;  // Show deviations
//--- indicator buffers
double         BufferPFE[];
double         BufferTop[];
double         BufferBottom[];
double         BufferTL[];
double         BufferBL[];
double         BufferMA[];
double         BufferDev[];
double         BufferRAW[];
double         BufferAvgRAW[];
//--- global variables
double         deviation;
int            period_froc;
int            period_sroc;
int            period_ma;
int            period_avg;
int            period_max;
int            pds;
int            handle_ma;
int            handle_dev;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_froc=int(InpPeriodFastROC<1 ? 1 : InpPeriodFastROC);
   period_sroc=int(InpPeriodSlowROC<1 ? 1 : InpPeriodSlowROC);
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_avg=int(InpPeriodAVG<1 ? 1 : InpPeriodAVG);
   period_max=fmax(period_froc,period_sroc);
   deviation=InpDeviation;
   pds=InpPDS;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPFE,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferBL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferAvgRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Polarized Fractal Efficiency Overlay ("+(string)period_froc+","+(string)period_sroc+","+(string)period_ma+","+(string)pds+","+(string)period_avg+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,InpShowDev);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,InpShowDev);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPFE,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferTL,true);
   ArraySetAsSeries(BufferBL,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
//--- create MA and StdDev handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_avg,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_avg,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_avg,0,MODE_SMA,PRICE_CLOSE);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_avg,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferPFE,EMPTY_VALUE);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferTL,0);
      ArrayInitialize(BufferBL,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDev,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTL[i]=BufferMA[i]+deviation*BufferDev[i];
      BufferBL[i]=BufferMA[i]-deviation*BufferDev[i];
      BufferTop[i]=(InpShowDev ? BufferTL[i] : EMPTY_VALUE);
      BufferBottom[i]=(InpShowDev ? BufferBL[i] : EMPTY_VALUE);
      double ROCSlow=(close[i+period_sroc]!=0 ? 100.0*(close[i]/close[i+period_sroc]-1) : 0);
      double ROCFast=(close[i+period_froc]!=0 ? 100.0*(close[i]/close[i+period_froc]-1) : 0);
      double x=sqrt(ROCSlow*ROCSlow+100.0);
      double y=sqrt(ROCFast*ROCFast+1.0)+pds;
      double z=x/(y!=0 ? y : 1);
      BufferRAW[i]=(close[i]>close[i+period_sroc] ? 100.0*z : -100.0*z);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferRAW,BufferAvgRAW)==0)
      return 0;    
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double scale=(BufferTL[i]!=BufferBL[i] ? 200.0/(BufferTL[i]-BufferBL[i]) : 0);
      BufferPFE[i]=(scale!=0 ? BufferBL[i]+(100.0+BufferAvgRAW[i])/scale : EMPTY_VALUE);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
