//+------------------------------------------------------------------+
//|                                                          DBB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Distance from Bollinger Band indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bottom
#property indicator_label2  "Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_CALC_MODE
  {
   MODE_PRC,   // Percentage
   MODE_PT     // Price points
  };
//--- input parameters
input uint                 InpPeriod         =  20;            // BB Period
input double               InpDeviation      =  2.0;           // BB Deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_CALC_MODE       InpMode           =  MODE_PRC;      // Display mode
//--- indicator buffers
double         BufferTop[];
double         BufferBottom[];
double         BufferMA[];
double         BufferBandsUP[];
double         BufferBandsDN[];
//--- global variables
double         deviation;
int            period;
int            handle_ma;
int            handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=(InpDeviation==0 ? 0.01 : InpDeviation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferBandsUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferBandsDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Distance from BB ("+(string)period+","+DoubleToString(deviation,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferBandsUP,true);
   ArraySetAsSeries(BufferBandsDN,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_bb=iBands(NULL,PERIOD_CURRENT,period,0,deviation,InpAppliedPrice);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("The iBands(",(string)period,",",DoubleToString(deviation,2),") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferBandsUP,0);
      ArrayInitialize(BufferBandsDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferBandsUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferBandsDN);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double TL=BufferBandsUP[i];
      double BL=BufferBandsDN[i];

      if(InpMode==MODE_PRC)
        {
         if(TL!=BL)
           {
            BufferTop[i]=100.0*(TL-BufferMA[i])/(TL-BL);
            BufferBottom[i]=100.0*(BufferMA[i]-BL)/(TL-BL);
           }
        }
      else
        {
         BufferTop[i]=(TL-BufferMA[i])/Point();
         BufferBottom[i]=(BufferMA[i]-BL)/Point();
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
