//+------------------------------------------------------------------+
//|                                                    Super_SAR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Super SAR indicator"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   4
//--- plot ArrUP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ArrDN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ArrNL
#property indicator_label3  "Neutral"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ArrSAR
#property indicator_label4  "SAR"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes 
   INPUT_NO    =  0  // No
  };
//--- input parameters
input double            InpStepSAR     =  0.02;       // SAR step
input double            InpMaxSAR      =  0.2;        // SAR max
input int               InpPeriod      =  8;          // ATR Period
input double            InpMultiplier  =  1.5;        // Multiplier
input ENUM_INPUT_YES_NO InpSwing       =  INPUT_NO;   // Swing
input ENUM_INPUT_YES_NO InpShowSAR     =  INPUT_YES;  // Show SAR
//--- indicator buffers
double         BufferArrUP[];
double         BufferArrDN[];
double         BufferArrNL[];
double         BufferSAR[];
double         BufferATR[];
double         BufferTrUP[];
double         BufferTrDN[];
double         BufferUP[];
double         BufferDN[];
double         BufferTR[];
//--- global variables
double         step;
double         max;
double         multiplier;
bool           flagSAR;
bool           flagST;
int            period;
int            flag;
int            handle_sar;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   step=(InpStepSAR<0.0001 ? 0.0001 : InpStepSAR);
   max=(InpMaxSAR<0.0001 ? 0.0001 : InpMaxSAR);
   multiplier=InpMultiplier;
   flag=0;
   flagSAR=flagST=false;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArrUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArrDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferArrNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSAR,INDICATOR_DATA);
   SetIndexBuffer(4,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferTrUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferTrDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferTR,INDICATOR_CALCULATIONS);
//--- setting buffer plot parameters
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,(InpShowSAR ? DRAW_ARROW : DRAW_NONE));
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Super SAR ("+DoubleToString(step,4)+","+DoubleToString(max,4)+","+(string)period+","+DoubleToString(multiplier,4)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArrUP,true);
   ArraySetAsSeries(BufferArrDN,true);
   ArraySetAsSeries(BufferArrNL,true);
   ArraySetAsSeries(BufferSAR,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferTrUP,true);
   ArraySetAsSeries(BufferTrDN,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTR,true);
//--- create MA's handles
   ResetLastError();
   handle_sar=iSAR(NULL,PERIOD_CURRENT,step,max);
   if(handle_sar==INVALID_HANDLE)
     {
      Print("The iSAR(",DoubleToString(step,4),","+DoubleToString(max,4),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr=iATR(NULL,PERIOD_CURRENT,period);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferArrUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrDN,EMPTY_VALUE);
      ArrayInitialize(BufferArrNL,EMPTY_VALUE);
      ArrayInitialize(BufferSAR,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferTrUP,0);
      ArrayInitialize(BufferTrDN,0);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferTR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sar,0,0,count,BufferSAR);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ATR=BufferATR[i];
      double Median=(high[i]+low[i])/2.0;

      BufferUP[i]=Median+ATR*multiplier;
      BufferDN[i]=Median-ATR*multiplier;
      BufferTR[i]=(close[i]>BufferUP[i+1] ? 1 : close[i]<BufferDN[i+1] ? -1 : BufferTR[i+1]);
      
      bool flagl=(BufferTR[i]<0 && BufferTR[i+1]>0 ? true : false);
      bool flagh=(BufferTR[i]>0 && BufferTR[i+1]<0 ? true : false);

      if(BufferTR[i]>0 && BufferDN[i]<BufferDN[i+1])
         BufferDN[i]=BufferDN[i+1];
      if(BufferTR[i]<0 && BufferUP[i]>BufferUP[i+1])
         BufferUP[i]=BufferUP[i+1];
      if(flagl)
         BufferUP[i]=Median+ATR*multiplier;
      if(flagh)
         BufferDN[i]=Median-ATR*multiplier;
      if(BufferTR[i]==1)
        {
         BufferTrUP[i]=BufferDN[i];
         BufferTrDN[i]=0;
        }
      else
        {
         BufferTrDN[i]=BufferUP[i];
         BufferTrUP[i]=0;
        }
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferArrDN[i]=BufferArrNL[i]=BufferArrUP[i]=EMPTY_VALUE;
      double SAR0=BufferSAR[i];
      double SAR1=BufferSAR[i+1];

      if(InpSwing)
        {
         flagSAR=(SAR0<close[i] && SAR1>close[i+1] ? true : SAR0>close[i] && SAR1<close[i+1] ? false : flagSAR);
         flagST=(BufferTrUP[i]>0 ? true : BufferTrDN[i]>0 ? false : flagST);
         if(flagSAR && flagST && flag!=1)
           {
            BufferArrUP[i]=open[i];
            flag=1;
           }
         if(!flagSAR && !flagST && flag!=-1)
           {
            BufferArrDN[i]=open[i];
            flag=-1;
           }
        }
      else
        {
         if(SAR0<close[i] && SAR1>close[i+1] && BufferTrUP[i]>0)
            BufferArrUP[i]=open[i];
         else
           {
            if(SAR0>close[i] && SAR1<close[i+1] && BufferTrDN[i]>0)
               BufferArrDN[i]=open[i];
            else
              {
               if(SAR0<close[i] && SAR1>close[i+1])
                  BufferArrNL[i]=high[i];
               else
                 {
                  if(SAR0>close[i] && SAR1<close[i+1])
                     BufferArrNL[i]=low[i];
                 }
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
