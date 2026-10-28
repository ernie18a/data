//+------------------------------------------------------------------+
//|                                           Wide_Narrow_Spread.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wide/Narrow Spread bar indicator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot WS
#property indicator_label1  "Wide bar"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot NS
#property indicator_label2  "Narrow bar"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bar
#property indicator_label3  "Open;High;Low;Close"
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrBlue,clrRed,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//--- input parameters
input uint              InpPeriod         =  4;          // Range
input ENUM_INPUT_YES_NO InpShowWideBar    =  INPUT_YES;  // Show wide spread bar
input ENUM_INPUT_YES_NO InpShowNarrowBar  =  INPUT_YES;  // Show narrow spread bar
//--- indicator buffers
double         BufferWS[];
double         BufferNS[];
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
double         BufferColors[];
double         BufferHL[];
//--- global variables
double         point;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   point=Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferNS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(3,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(4,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(5,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(6,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,BufferHL,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,32);
   PlotIndexSetInteger(1,PLOT_ARROW,32);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Wide/Narrow Spread bar("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWS,true);
   ArraySetAsSeries(BufferNS,true);
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferHL,true);
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
//--- Проверка количества доступных баров
   if(rates_total<period || point==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferWS,EMPTY_VALUE);
      ArrayInitialize(BufferNS,EMPTY_VALUE);
      ArrayInitialize(BufferOpen,EMPTY_VALUE);
      ArrayInitialize(BufferHigh,EMPTY_VALUE);
      ArrayInitialize(BufferLow,EMPTY_VALUE);
      ArrayInitialize(BufferClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferHL,0);
     }

//--- Расчёт индикатора
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferOpen[i]=BufferHigh[i]=BufferLow[i]=BufferClose[i]=EMPTY_VALUE;
      BufferColors[i]=2;
      BufferHL[i]=high[i]-low[i];
      int min_idx=ArrayMinimum(BufferHL,i,period);
      int max_idx=ArrayMaximum(BufferHL,i,period);
      if(min_idx==WRONG_VALUE || max_idx==WRONG_VALUE)
         continue;
      double min=BufferHL[min_idx];
      double max=BufferHL[max_idx];

      if(InpShowWideBar)
        {
         if(max==BufferHL[i])
           {
            BufferWS[i]=max/point;
            BufferOpen[i]=open[i];
            BufferHigh[i]=high[i];
            BufferLow[i]=low[i];
            BufferClose[i]=close[i];
            BufferColors[i]=0;
           }
         else
            BufferWS[i]=EMPTY_VALUE;
        }

      if(InpShowNarrowBar)
        {
         if(min==BufferHL[i])
           {
            BufferNS[i]=min/point;
            BufferOpen[i]=open[i];
            BufferHigh[i]=high[i];
            BufferLow[i]=low[i];
            BufferClose[i]=close[i];
            BufferColors[i]=1;
           }
         else
            BufferNS[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
