//+------------------------------------------------------------------+
//|                                   Extreme_TMA_line_indicator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Extreme TMA Line indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot TMA
#property indicator_label1  "TMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodTMA      =  56;         // TMA period
input uint              InpPeriodATR      =  100;        // ATR period
input double            InpMultiplierATR  =  2.0;        // ATR multiplier
input double            InpThreshold      =  0.5;        // Trend threshold
input ENUM_INPUT_YES_NO InpRedraw         =  INPUT_YES;  // Redraw
//--- indicator buffers
double         BufferTMA[];
double         BufferColors[];
double         BufferTop[];
double         BufferBottom[];
double         BufferATR[];
//--- global variables
double         multiplier;
double         threshold;
int            period_tma;
int            period_atr;
int            period_max;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tma=int(InpPeriodTMA<1 ? 1 : InpPeriodTMA);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   period_max=fmax(period_atr,period_tma);
   multiplier=InpMultiplierATR;
   threshold=InpThreshold;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(4,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Extreme TMA Line ("+(string)period_tma+","+(string)period_atr+","+DoubleToString(multiplier,1)+","+DoubleToString(threshold,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTMA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferTMA,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int tcount=period_tma;
      bool period_last=(i==0 ? true : false);

      while(tcount>0)
        {
         tcount=(!period_last ? 0 : tcount-1);
         double sum=0;
         double sumw=(period_tma+2)*(period_tma+1)/2;
         for(int j=0; j<=period_tma; j++)
           {
            sum+=(period_tma-j+1)*close[i+j];
            if(InpRedraw)
              {
               if(i-j>0)
                 {
                  sum+=(period_tma-j+1)*close[i-j];
                  sumw+=(period_tma-j+1);
                 }
              }
           }
         if(sumw!=0)
           {
            BufferTMA[i]=sum/sumw;
           }
        }
     }

//--- Канал и Цвет
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double slope=(BufferTMA[i]-BufferTMA[i+1])/(0.1*BufferATR[i]);
      double range=BufferATR[i]*multiplier;
      BufferTop[i]=BufferTMA[i]+range;
      BufferBottom[i]=BufferTMA[i]-range;
      
      if(slope>threshold)
         BufferColors[i]=BufferColors[i+1]=0;
      else if(slope<-threshold)
         BufferColors[i]=BufferColors[i+1]=1;
      else
         BufferColors[i]=BufferColors[i+1]=2;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
