//+------------------------------------------------------------------+
//|                         FX Fish 2MA(barabashkakvn's edition).mq5 |
//|                                     Copyright © 2005, Kiko Segui |
//|                                               webtecnic@terra.es |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Kiko Segui"
#property link      "webtecnic@terra.es"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#include <MovingAverages.mqh>
//--- input parameters 
input int CalculatePeriod=10;
input ENUM_APPLIED_PRICE CalculatePrice=PRICE_MEDIAN;
input int MA1period=9;
ENUM_MA_METHOD TypeMA1=MODE_SMA;
input int MA2period=45;
ENUM_MA_METHOD TypeMA2=MODE_LWMA;
//--- plot Color_Histogram 
#property indicator_type1   DRAW_COLOR_HISTOGRAM 
#property indicator_color1  clrOrange,clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Line
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Line
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
double Color_HistogramBuffer[];
double Color_HistogramColors[];
double MA1buffer[];
double MA2buffer[];
//---
double Value=0.0,Value1=0.0,Fish=0.0,Fish1=0.0;
static int weightsum_ma2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Value=0.0;Value1=0.0;Fish=0.0;Fish1=0.0;
   weightsum_ma2=0;
//--- indicator buffers mapping
   SetIndexBuffer(0,Color_HistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Color_HistogramColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,MA1buffer,INDICATOR_DATA);
   SetIndexBuffer(3,MA2buffer,INDICATOR_DATA);
//--- name for DataWindow and indicator subwindow label 
   PlotIndexSetString(0,PLOT_LABEL,"Fish");
   PlotIndexSetString(1,PLOT_LABEL,"Fish Aver("+IntegerToString(MA1period)+")");
   PlotIndexSetString(2,PLOT_LABEL,"Fish Aver Aver("+IntegerToString(MA2period)+")");
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
//--- calculate the indicator values 
   int limit=0;
//--- if already calculated during the previous starts of OnCalculate 
   if(prev_calculated>0)
      limit=prev_calculated-1; // set the beginning of the calculation with the last but one bar 
//--- fill in the indicator buffer with values 
   double _price;
   double MinL=0;
   double MaxH=0;
   double Threshold=1.2;
//---
   for(int i=limit;i<rates_total;i++)
     {
      int start=(i-CalculatePeriod<0)?0:i-CalculatePeriod;
      int index_max=ArrayMaximum(high,start,CalculatePeriod);
      int index_min=ArrayMinimum(low,start,CalculatePeriod);
      MaxH=high[ArrayMaximum(high,start,CalculatePeriod)];
      MinL=low[ArrayMinimum(low,start,CalculatePeriod)];
      //---
      switch(CalculatePrice)
        {
         case PRICE_CLOSE:    _price=close[i];                                break;
         case PRICE_OPEN:     _price=open[i];                                 break;
         case PRICE_HIGH:     _price=high[i];                                 break;
         case PRICE_LOW:      _price=low[i];                                  break;
         case PRICE_MEDIAN:   _price=(high[i]+low[i])/2.0;                    break;
         case PRICE_TYPICAL:  _price=(high[i]+low[i]+close[i])/3.0;           break;
         default:             _price=(high[i]+low[i]+close[i]+open[i])/4.0;   break;
        }
      Value=(MaxH-MinL!=0.0)?0.33*2*((_price-MinL)/(MaxH-MinL)-0.5)+0.67*Value1:0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      Fish=0.5*MathLog((1.0+Value)/(1.0-Value))+0.5*Fish1;
      //--- a value 
      Color_HistogramBuffer[i]=Fish; //sin(i*2.*M_PI/30);
      Color_HistogramColors[i]=(Color_HistogramBuffer[i]<0.0)?0:1;
      //---
      Value1=Value;
      Fish1=Fish;
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,MA1period,Color_HistogramBuffer,MA1buffer);
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,MA2period,MA1buffer,MA2buffer,weightsum_ma2);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
