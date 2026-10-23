//+------------------------------------------------------------------+
//|                                                   Bands_Fill.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bands Fill indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot Top
#property indicator_label1  "Upper BB"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bottom
#property indicator_label2  "Lower BB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Cloud
#property indicator_label3  "Cloud"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  clrPowderBlue,clrBisque
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod      =  20;   // Period
input double   InpDeviation   =  2.0;  // Deviation
//--- indicator buffers
double         BufferUpper[];
double         BufferLower[];
double         BufferCloud1[];
double         BufferCloud2[];
double         BufferBase[];
double         BufferTrigger[];
//--- global variables
double         deviation;
int            period;
int            handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCloud1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCloud2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBase,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferTrigger,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Bands Fill ("+(string)period+","+DoubleToString(deviation,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferCloud1,true);
   ArraySetAsSeries(BufferCloud2,true);
   ArraySetAsSeries(BufferBase,true);
   ArraySetAsSeries(BufferTrigger,true);
//--- create BB handle
   ResetLastError();
   handle_bb=iBands(NULL,PERIOD_CURRENT,period,0,deviation,PRICE_CLOSE);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferCloud1,0);
      ArrayInitialize(BufferCloud2,0);
      ArrayInitialize(BufferBase,0);
      ArrayInitialize(BufferTrigger,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferUpper);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferLower);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,BASE_LINE,0,count,BufferBase);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTrigger[i]=BufferTrigger[i+1];
      if(BufferTrigger[i]==1 && close[i]<BufferBase[i])
         BufferTrigger[i]=0;
      if(BufferTrigger[i]==-1 && close[i]>BufferBase[i])
         BufferTrigger[i]=0;
      if(close[i]>=BufferUpper[i])
         BufferTrigger[i]=1;
      if(close[i]<=BufferLower[i])
         BufferTrigger[i]=-1;
      
      if(BufferTrigger[i]==1)
        {
         BufferCloud1[i]=BufferUpper[i];
         BufferCloud2[i]=BufferLower[i];
        }
      else if(BufferTrigger[i]==-1)
        {
         BufferCloud1[i]=BufferLower[i];
         BufferCloud2[i]=BufferUpper[i];
        }
      else
        {
         BufferCloud1[i]=0;
         BufferCloud2[i]=0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
