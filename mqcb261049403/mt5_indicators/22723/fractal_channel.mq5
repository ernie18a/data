//+------------------------------------------------------------------+
//|                                              Fractal_Channel.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fractal Channel indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpFrames=5;    // Frame
//--- indicator buffers
double         BufferUpper[];
double         BufferLower[];
//--- global variables
int            frames;
int            shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   frames=int(InpFrames<3 ? 3 : InpFrames);
   shift=(frames-1)/2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLower,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal channel ("+(string)frames+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferLower,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shift-3;
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      bool UpFr=true;
      bool DnFr=true;
      for(int j=1;j<=shift;j++)
        {
         if(high[i+shift]<=high[i+shift-j] || high[i+shift]<=high[i+shift+j])
            UpFr=false;
         if(low[i+shift]>=low[i+shift-j] || low[i+shift]>=low[i+shift+j])
            DnFr=false;
        }
      if(UpFr)
        {
         for(int j=0;j<=shift;j++)
            BufferUpper[i+shift-j]=high[i+shift];
        }
      else
         for(int j=0;j<=shift;j++)
            BufferUpper[i+shift-j]=BufferUpper[i+shift+1-j];
      if(DnFr)
        {
         for(int j=0;j<=shift;j++)
            BufferLower[i+shift-j]=low[i+shift];
        }
      else
         for(int j=0;j<=shift;j++)
            BufferLower[i+shift-j]=BufferLower[i+shift+1-j];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
