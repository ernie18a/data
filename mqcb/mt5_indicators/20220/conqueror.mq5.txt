//+------------------------------------------------------------------+
//|                                                    Conqueror.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot HIST
#property indicator_label1  "HIST"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrLightGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP
#property indicator_label2  "To long pos"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot DN
#property indicator_label3  "To short pos"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot NO
#property indicator_label4  "Stop trade"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLightGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- input parameters
input uint     InpPeriodMA       =  10;   // Period
input uint     InpPeriodRange1   =  10;   // Range 1 period
input uint     InpPeriodRange2   =  40;   // Range 2 period
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNO[];
double         BufferHIST[];
double         BufferColors[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            period_rng1;
int            period_rng2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_rng1=int(InpPeriodRange1<1 ? 1 : InpPeriodRange1);
   period_rng2=int(InpPeriodRange2<1 ? 1 : InpPeriodRange2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHIST,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(4,BufferNO,INDICATOR_DATA);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Conqueror("+(string)period_ma+","+(string)period_rng1+","+(string)period_rng2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNO,true);
   ArraySetAsSeries(BufferHIST,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handle MA
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=fmax(period_ma,fmax(period_rng1,period_rng2));
   if(rates_total<max) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNO,EMPTY_VALUE);
      ArrayInitialize(BufferHIST,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP[i]=BufferDN[i]=BufferNO[i]=EMPTY_VALUE;
      double MA0=BufferMA[i];
      double MA1=BufferMA[i+period_rng1];
      BufferHIST[i]=BufferMA[i];
      if(close[i]>MA0 && MA0>MA1 && close[i]>close[i+period_rng2])
         BufferColors[i]=0;
      else if(close[i]<MA0 && MA0<MA1 && close[i]<close[i+period_rng2])
         BufferColors[i]=1;
      else
         BufferColors[i]=2;

      if(BufferColors[i]==0 && BufferColors[i+1]!=0)
         BufferUP[i]=BufferHIST[i];
      if(BufferColors[i]==1 && BufferColors[i+1]!=1)
         BufferDN[i]=BufferHIST[i];
      if(BufferColors[i]==2 && BufferColors[i+1]!=2)
         BufferNO[i]=BufferHIST[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
