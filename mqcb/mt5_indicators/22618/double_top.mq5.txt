//+------------------------------------------------------------------+
//|                                                   Double_Top.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Double top indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot TopDbl
#property indicator_label1  "Double Top"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BottomDbl
#property indicator_label3  "Double Bottom"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpMinHeight   =  10;   // Minumum Height/Depth
input uint     InpMaxDist     =  20;   // Maximum distance between the twin tops/bottoms
input uint     InpMinBars     =  3;    // Maximum number of bars after the top/bottom
//--- indicator buffers
double         BufferTop[];
double         BufferTopDBL[];
double         BufferBottom[];
double         BufferBottomDBL[];
//--- global variables
double         min_height;
int            min_hgt;
int            min_bars;
int            max_dist;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   min_hgt=int(InpMinHeight<1 ? 1 : InpMinHeight);
   min_height=min_hgt*Point();
   min_bars=int(InpMinBars<1 ? 1 : InpMinBars);
   max_dist=int(InpMaxDist<1 ? 1 : InpMaxDist);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTopDBL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottomDBL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,82);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,82);
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Double top (Min height: "+(string)min_hgt+", max distance: "+(string)max_dist+", min bars: "+(string)min_bars+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferTopDBL,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferBottomDBL,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(min_bars,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-min_bars-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferTopDBL,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferBottomDBL,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBottom[i]=BufferBottomDBL[i]=BufferTop[i]=BufferTopDBL[i]=EMPTY_VALUE;
      BufferTop[i+min_bars]=(IsTop(rates_total,i+min_bars,high,low) ? high[i+min_bars] : EMPTY_VALUE);
      BufferBottom[i+min_bars]=(IsBottom(rates_total,i+min_bars,high,low) ? low[i+min_bars] : EMPTY_VALUE);
      
      if(BufferTop[i+min_bars]==high[i+min_bars])
        {
         if(FindPrevTop(rates_total,i+min_bars,high))
            BufferTopDBL[i+min_bars]=high[i+min_bars];
         else
            BufferTopDBL[i+min_bars]=EMPTY_VALUE;
        }

      if(BufferBottom[i+min_bars]==low[i+min_bars])
        {
         if(FindPrevBottom(rates_total,i+min_bars,low))
            BufferBottomDBL[i+min_bars]=low[i+min_bars];
         else
            BufferBottomDBL[i+min_bars]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTop(const int rates_total,const int index,const double &high[],const double &low[])
  {
   bool fl=true;
   for(int i=1; i<=min_bars; i++)
      if(high[index-i]>=high[index]) fl=false;
   if(fl)
     {
      int i=index+1;
      while(i<rates_total)
        {
         if(high[i]>=high[index]) return false;
         if(high[index]-low[i]>=min_height) return true;
         i++;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBottom(const int rates_total,const int index,const double &high[],const double &low[])
  {
   bool fl=true;
   for(int i=1; i<=min_bars; i++)
      if(low[index-i]<=low[index]) fl=false;
   if(fl)
     {
      int i=index+1;
      while(i<rates_total)
        {
         if(low[i]<=low[index]) return false;
         if(high[i]-low[index]>=min_height) return true;
         i++;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindPrevTop(const int rates_total,const int index,const double &high[])
  {
   int i=index+1;
   while(i<rates_total && i<=index+max_dist)
     {
      if(BufferTop[i]==high[i]) return true;
      i++;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindPrevBottom(const int rates_total,const int index,const double &low[])
  {
   int i=index+1;
   while(i<rates_total && i<=index+max_dist)
     {
      if(BufferBottom[i]==low[i]) return true;
      i++;
     }
   return false;
  }
//+------------------------------------------------------------------+

