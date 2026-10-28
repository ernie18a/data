//+------------------------------------------------------------------+
//|                                          Valid_Swing_HighLow.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Valid Swing HighLow indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Fractal Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Fractal Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_DRAW_BAR
  {
   BAR_SIGNAL,    // Signal bar
   BAR_FRACTAL    // Fractal bar
  };
//--- input parameters
input ENUM_DRAW_BAR  InpDrawBar  =  BAR_SIGNAL;    // Bar of drawing
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferLast[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLast,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Valid Swing HighLow");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferLast,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<5) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferLast,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int curr=i+2;
      int bar=(InpDrawBar==BAR_SIGNAL ? i : curr);
      BufferLast[curr]=0;
      BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
      if(high[curr]>high[curr-1] && high[curr]>high[curr-2] && high[curr]>high[curr+1] && high[curr]>high[curr+2])
        {
         BufferUP[bar]=(InpDrawBar==BAR_SIGNAL ? open[i] : high[bar]);
         BufferLast[curr]=1;
         Previous(rates_total,i,1,high,low);
        }
      if(low[curr]<low[curr-1] && low[curr]<low[curr-2] && low[curr]<low[curr+1] && low[curr]<low[curr+2])
        {
         BufferDN[bar]=(InpDrawBar==BAR_SIGNAL ? open[i] : low[bar]);
         BufferLast[curr]=-1;
         Previous(rates_total,i,-1,high,low);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Previous(const int rates_total,const int index,int flag,const double &high[],const double &low[])
  {
   int limit=rates_total-2;

   for(int i=index+1; i<=limit; i++)
     {
      if(BufferLast[i]==flag)
        {
         if(flag==1 && high[i]<high[index])
           {
            BufferLast[i]=0;
            break;
           }
         else if(flag==-1 && low[i]>low[index])
           {
            BufferLast[i]=0;
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
