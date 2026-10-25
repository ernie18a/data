//+------------------------------------------------------------------+
//|                                                     MaDevOsc.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Deviation from MA oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MDO
#property indicator_label1  "MaDevOsc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrRed,clrBlue,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpFrame          =  3;             // Frames
//--- indicator buffers
double         BufferMDO[];
double         BufferColors[];
double         BufferMA[];
double         BufferPrice[];
//--- global variables
int            period;
int            shift;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   shift=(int)float((InpFrame-1.0)/2.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMDO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MaDevOsc ("+(string)period+","+(string)InpFrame+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMDO,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(shift,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2*shift-2;
      ArrayInitialize(BufferMDO,0);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferPrice,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferPrice);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMDO[i]=BufferPrice[i]-BufferMA[i];
      bool min=true;
      bool max=true;
      for(int j=1; j<=shift; j++)
        {
         if(BufferMDO[i+shift+1]>=BufferMDO[i+j+shift+1] || BufferMDO[i+shift+1]>=BufferMDO[i-j+shift+1])
            min=false;
         if(BufferMDO[i+shift+1]<=BufferMDO[i+j+shift+1] || BufferMDO[i+shift+1]<=BufferMDO[i-j+shift+1])
            max=false;
        }
      BufferColors[i+shift+1]=(min && BufferMDO[i+shift+1]<0 ? 1 : max && BufferMDO[i+shift+1]>0 ? 0 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
