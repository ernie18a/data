//+------------------------------------------------------------------+
//|                                                       StoDiv.mq5 |
//|                                     Copyright © 2005-2006, RickD |
//|                                               http://e2e-fx.net/ |
//+------------------------------------------------------------------+
//---- copyright
#property copyright "Copyright © 2005-2006, RickD"
//---- site
#property link      "http://e2e-fx.net/"
//---- indicator version
#property version   "1.01"
//---- plot in a separate window
#property indicator_chart_window 
//---- number of buffers used (2)
#property indicator_buffers 2
//---- number of plots used (2)
#property indicator_plots   2
//+----------------------------------------------+
//|  constants                                   |
//+----------------------------------------------+
#define RESET 0 // used for recalculation reset in OnCalculate
//+----------------------------------------------+
//|  Indicator plot settings (bearish)           |
//+----------------------------------------------+
//---- drawing type - as arrow (char)
#property indicator_type1   DRAW_ARROW
//---- indicator color - DeepPink
#property indicator_color1  DeepPink
//---- indicator width - 4
#property indicator_width1  4
//---- indicator label
#property indicator_label1  "StoDiv Sell"
//+----------------------------------------------+
//|  Indicator plot settings (bullish)           |
//+----------------------------------------------+
//---- drawing type - as arrow (char)
#property indicator_type2   DRAW_ARROW
//---- indicator color - Teal
#property indicator_color2  Teal
//---- indicator width - 4
#property indicator_width2  4
//---- indicator label
#property indicator_label2 "StoDiv Buy"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint DxPeriod=30;   // Bars, used to search fractals
input int  dy=20;         // Threshold level in points
input uint KPeriod=5;
input uint DPeriod=3;
input uint Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
//+----------------------------------------------+
//---- declaration of arrays, used as indicator buffers
double SellBuffer[];
double BuyBuffer[];

double DY,ratio;
//---- declaration of variables, used for indicator handles
int Fra_Handle,Sto_Handle,ATR_Handle;
//---- variable, used for indexes
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- initialization of global variables
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,DxPeriod+KPeriod+DPeriod+Slowing)+5);
   DY=dy*_Point;
   ratio=3.0/8.0;

//---- get handle of iFractals indicator
   Fra_Handle=iFractals(NULL,0);
   if(Fra_Handle==INVALID_HANDLE) {Print(" Error in creation of iFractals indicator"); return(1);}

//---- get handle of iStochastic indicator
   Sto_Handle=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(Sto_Handle==INVALID_HANDLE) {Print(" Error in creation of iStochastic indicator"); return(1);}

//---- get handle of iATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE) {Print(" Error in creation of iATR indicator"); return(1);}

//---- set SellBuffer[] as indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- set label
   PlotIndexSetString(0,PLOT_LABEL,"StoDiv Sell");
//---- set char code (234)
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- set indexing as time series
   ArraySetAsSeries(SellBuffer,true);

//---- set BuyBuffer[] as indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- set label
   PlotIndexSetString(1,PLOT_LABEL,"StoDiv Buy");
//---- set char code
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- set indexing as time series
   ArraySetAsSeries(BuyBuffer,true);

//---- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- set indicator short name
   string short_name="StoDivSig";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- 
   return(0);
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
//---- checking of bars calculated
   if(BarsCalculated(Sto_Handle)<rates_total
      || BarsCalculated(Fra_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables
   int to_copy,limit,bar2,j2,total;
   double Sto[],UpFrac[],DnFrac[],ATR[];

//---- calculation of starting bar indexes
   if(prev_calculated>rates_total || prev_calculated<=0)// checking of first call
      limit=rates_total-min_rates_total-5; // starting index for all bars
   else limit=rates_total-prev_calculated; // starting index for new bars

//---- copy new data to arrays
   to_copy=limit+1;
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy+=int(5+DxPeriod);
   if(CopyBuffer(Sto_Handle,0,0,to_copy,Sto)<=0) return(RESET);
   if(CopyBuffer(Fra_Handle,0,0,to_copy,UpFrac)<=0) return(RESET);
   if(CopyBuffer(Fra_Handle,1,0,to_copy,DnFrac)<=0) return(RESET);

//---- set indexing as time series
   ArraySetAsSeries(Sto,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(UpFrac,true);
   ArraySetAsSeries(DnFrac,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of Sell indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar2=bar+2;
      SellBuffer[bar]=0.0;
      if(UpFrac[bar2]==EMPTY_VALUE) continue;
      total=int(bar+DxPeriod);

      for(int j=bar+1; j<total; j++)
        {
         j2=j+2;
         if(UpFrac[j2]==EMPTY_VALUE) continue;
         if(UpFrac[bar2]>UpFrac[j2]+DY)
            if(Sto[bar2]<Sto[j2])
              {
               SellBuffer[bar]=high[bar]+ATR[bar]*ratio;
               break;
              }
        }
     }

//---- calculation of Buy indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar2=bar+2;
      BuyBuffer[bar]=0.0;
      if(DnFrac[bar2]==EMPTY_VALUE) continue;
      total=int(bar+DxPeriod);

      for(int j=bar+1; j<total; j++)
        {
         j2=j+2;
         if(DnFrac[j2]==EMPTY_VALUE) continue;
         if(DnFrac[bar2]<DnFrac[j2]-DY)
            if(Sto[bar2]>Sto[j2])
              {
               BuyBuffer[bar]=low[bar]-ATR[bar]*ratio;
               break;
              }
        }
     }

//---- check and fix contradictory signals
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
      if(SellBuffer[bar] && BuyBuffer[bar])
        {
         BuyBuffer[bar]=0.0;
         SellBuffer[bar]=0.0;
        }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
