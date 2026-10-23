//+------------------------------------------------------------------+
//|                                                         FGDI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fractal Graph Dimension Indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot B1
#property indicator_label1  "FGDI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrBlue,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot B2
#property indicator_label2  "+Deviation"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrBlue,clrRed,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot B3
#property indicator_label3  "- Deviation"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrBlue,clrRed,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriod         =  30;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpThreshold      =  1.5;           // Threshold
//--- indicator buffers
double         BufferB1[];
double         BufferColorsB1[];
double         BufferB2[];
double         BufferColorsB2[];
double         BufferB3[];
double         BufferColorsB3[];
double         BufferMA[];
//--- global variables
double         threshold;
double         log2;
double         log_period;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   threshold=InpThreshold;
   log2=log(2.0);
   log_period=log(2.0*(period-1.0));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferB1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsB1,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferB2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsB2,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferB3,INDICATOR_DATA);
   SetIndexBuffer(5,BufferColorsB3,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal Graph Dimension ("+(string)period+","+DoubleToString(threshold,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Threshold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferColorsB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferColorsB2,true);
   ArraySetAsSeries(BufferB3,true);
   ArraySetAsSeries(BufferColorsB3,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferB1,EMPTY_VALUE);
      ArrayInitialize(BufferB2,EMPTY_VALUE);
      ArrayInitialize(BufferB3,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferMA,i,period);
      int bh=ArrayMaximum(BufferMA,i,period);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double min=BufferMA[bl];
      double max=BufferMA[bh];

      double priordiff=0;
      double len=0;
      double diff=0;
      double delta=0;
      double variance=0;
      double fdi=0;
      double mean=0;
      if(min!=max)
        {
         for(int j=i+period-1; j>=i; j--)
           {
            diff=(BufferMA[j]-min)/(max-min);
            if(j!=i+period-1)
               len+=sqrt(pow(diff-priordiff,2.0)+1.0/pow(period,2.0));
            priordiff=diff;
           }
        }

      double sum=0;
      if(len>0)
        {
         fdi=1.0+(log(len)+log2)/log_period;
         mean=len/(period-1.0);

         if(max!=min)
           {
            for(int j=i+period-1;j>=i;j--)
              {
               diff=(BufferMA[j]-min)/(max-min);
               if(j!=i+period-1)
                 {
                  delta=sqrt(pow(diff-priordiff,2)+1.0/pow(period,2.0));
                  sum+=pow(delta-len/(period-1.0),2.0);
                 }
               priordiff=diff;
              }
           }
         variance=sum/(pow(len,2.0)*log_period*log_period);
        }
      else
        {
         fdi=0;
         variance=0;
        }
      
      double stddev=sqrt(variance);

      BufferB1[i]=fdi;
      BufferB2[i]=fdi+stddev;
      BufferB3[i]=fdi-stddev;

      BufferColorsB1[i]=(BufferB1[i]>threshold ? 0 : BufferB1[i]<threshold ? 1 : 2);
      BufferColorsB2[i]=(BufferB2[i]>threshold ? 0 : BufferB2[i]<threshold ? 1 : 2);
      BufferColorsB3[i]=(BufferB3[i]>threshold ? 0 : BufferB3[i]<threshold ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
