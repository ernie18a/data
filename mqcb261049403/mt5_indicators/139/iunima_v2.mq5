//+------------------------------------------------------------------+
//|                                                       iUniMA.mq5 |
//|                                        MetaQuotes Software Corp. |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+
/*
   The Universal Moving Average,
   it allows to select any type of moving average, included in the MetaTrader 5 client terminal.
  
   Simple,
   Exponential,
   Smoothed,
   Linear Weighted,
   AMA (Adaptive Moving Average),
   DEMA (Double Exponential Moving Average),
   FRAMA (Fractal Adaptive Moving Average),
   TEMA (Triple Exponential Moving Average),
   VIDYA (Variable Index DYnamic Average).  
  
   Main parameters:
  
   MAMethod - MA type,
   MAPeriod - period,
   MAPrice - applied price.
  
   Additional parameters:
  
   AMAFast - period of fast EMA for AMA,
   AMASlow - period of slow EMA for AMA,
   CMOPeriod - period of CMO for VIDYA.

   The name of MA, its period, applied price and other parameters are shown in the popup help.
*/

#property copyright "Integer"
#property link      "http://dmffx.com"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters

enum MAMethods
  {
   Simple=MODE_SMA,
   Exponential=MODE_EMA,
   Smoothed=MODE_SMMA,
   LinearWeighted=MODE_LWMA,
   AMA=IND_AMA,
   DEMA=IND_DEMA,
   FRAMA=IND_FRAMA,
   TEMA=IND_TEMA,
   VIDYA=IND_VIDYA
  };

input MAMethods            MAMethod   =   Simple;
input int                  MAPeriod   =   14;
input ENUM_APPLIED_PRICE   MAPrice    =   PRICE_CLOSE;
input int                  AMAFast    =   2;
input int                  AMASlow    =   30;
input int                  CMOPeriod  =   9;

int Handle;

//--- indicator buffers
double         MABuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MABuffer,INDICATOR_DATA);

   switch(MAMethod)
     {
      case Simple:
         Handle=iMA(NULL,PERIOD_CURRENT,MAPeriod,0,MODE_SMA,MAPrice);
         break;
      case Exponential:
         Handle=iMA(NULL,PERIOD_CURRENT,MAPeriod,0,MODE_EMA,MAPrice);
         break;
      case Smoothed:
         Handle=iMA(NULL,PERIOD_CURRENT,MAPeriod,0,MODE_SMMA,MAPrice);
         break;
      case LinearWeighted:
         Handle=iMA(NULL,PERIOD_CURRENT,MAPeriod,0,MODE_LWMA,MAPrice);
         break;
      case AMA:
         Handle=iAMA(NULL,PERIOD_CURRENT,MAPeriod,AMAFast,AMASlow,0,MAPrice);
         break;
      case DEMA:
         Handle=iDEMA(NULL,PERIOD_CURRENT,MAPeriod,0,MAPrice);
         break;
      case FRAMA:
         Handle=iFrAMA(NULL,PERIOD_CURRENT,MAPeriod,0,MAPrice);
         break;
      case TEMA:
         Handle=iTEMA(NULL,PERIOD_CURRENT,MAPeriod,0,MAPrice);
         break;
      case VIDYA:
         Handle=iVIDyA(NULL,PERIOD_CURRENT,CMOPeriod,MAPeriod,0,MAPrice);
         break;
     }

   string Label;

   switch(MAMethod)
     {
      case Simple:
         Label="SMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case Exponential:
         Label="EMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case Smoothed:
         Label="SMMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case LinearWeighted:
         Label="LWMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case AMA:
         Label="AMA("+ITS(MAPeriod)+","+ITS(AMAFast)+","+ITS(AMASlow)+","+fNamePriceShort(MAPrice)+")";
         break;
      case DEMA:
         Label="DEMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case FRAMA:
         Label="FRAM("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case TEMA:
         Label="TEMA("+ITS(MAPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
      case VIDYA:
         Label="VIDYA("+ITS(MAPeriod)+","+ITS(CMOPeriod)+","+fNamePriceShort(MAPrice)+")";
         break;
     }

   PlotIndexSetString(0,PLOT_LABEL,Label);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| fNamePriceShort                                                  |
//+------------------------------------------------------------------+
string fNamePriceShort(ENUM_APPLIED_PRICE aPrice)
  {
   switch(aPrice)
     {
      case PRICE_CLOSE:
         return("C");
      case PRICE_HIGH:
         return("H");
      case PRICE_LOW:
         return("L");
      case PRICE_MEDIAN:
         return("M");
      case PRICE_OPEN:
         return("O");
      case PRICE_TYPICAL:
         return("T");
      case PRICE_WEIGHTED:
         return("W");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| ITS                                                              |
//+------------------------------------------------------------------+
string ITS(int aValue)
  {
   return(IntegerToString(aValue));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[])
  {
   static bool error=true;
   int start;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=0;
      error=false;
     }
   else
     {
      start=prev_calculated-1;
     }
   if(CopyBuffer(Handle,0,0,rates_total-start,MABuffer)==-1)
     {
      error=true;
      return(rates_total);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
