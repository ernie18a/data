//+------------------------------------------------------------------+
//|                                                   Cutler_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Cutler RSI indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot CRSI
#property indicator_label1  "CRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferCRSI[];
double         BufferMA[];
double         BufferPos[];
double         BufferNeg[];
double         BufferPosAvg[];
double         BufferNegAvg[];
//--- global variables
double         overbought;
double         oversold;
int            period_ind;
int            weight_sum;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNeg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferPosAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferNegAvg,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Cutler RSI ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCRSI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPos,true);
   ArraySetAsSeries(BufferNeg,true);
   ArraySetAsSeries(BufferPosAvg,true);
   ArraySetAsSeries(BufferNegAvg,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCRSI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferPos,0);
      ArrayInitialize(BufferNeg,0);
      ArrayInitialize(BufferPosAvg,0);
      ArrayInitialize(BufferNegAvg,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=BufferMA[i]-BufferMA[i+1];
      if(diff>0)
        {
         BufferPos[i]=diff;
         BufferNeg[i]=0;
        }
      else
        {
         BufferPos[i]=0;
         BufferNeg[i]=-diff;
        }
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferPos,BufferPosAvg);               
        ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferNeg,BufferNegAvg);               
        break;
      case MODE_SMMA :  
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferPos,BufferPosAvg);                  
        SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferNeg,BufferNegAvg);                  
        break;
      case MODE_LWMA :  
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferPos,BufferPosAvg,weight_sum); 
        LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferNeg,BufferNegAvg,weight_sum); 
        break;
      //---MODE_SMA
      default        :  
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferPos,BufferPosAvg);                    
        SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferNeg,BufferNegAvg);                    
        break;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double N=BufferNegAvg[i];
      BufferCRSI[i]=(N!=0 ? 100.0-(100.0/(1.0+BufferPosAvg[i]/N)) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
