//+------------------------------------------------------------------+
//|                                                           GB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Gaussian Bands indicator"
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   9
//--- plot Central
#property indicator_label1  "Center line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top1
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Top2
#property indicator_label3  "Upper Top"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLightPink
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom1
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLightGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Bottom2
#property indicator_label5  "Lower Bottom"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLightGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot FTopUpper
#property indicator_label6  "Cloud Upper"
#property indicator_type6   DRAW_FILLING
#property indicator_color6  clrCornsilk,clrCornsilk
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot FBottomLower
#property indicator_label7  "Cloud Lower"
#property indicator_type7   DRAW_FILLING
#property indicator_color7  clrLemonChiffon,clrLemonChiffon
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- input parameters
input uint                 InpPeriod         =  12;            // Period
input uint                 InpDeviation      =  12;            // Deviation period
input double               InpMultiplier1    =  2.0;           // First multiplier
input double               InpMultiplier2    =  4.0;           // Second multiplier
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferCentral[];
double         BufferTop1[];
double         BufferTop2[];
double         BufferBottom1[];
double         BufferBottom2[];
double         BufferCloudUpper1[];
double         BufferCloudUpper2[];
double         BufferCloudLower1[];
double         BufferCloudLower2[];
double         BufferMA[];
double         BufferRAW1[];
double         BufferRAW2[];
//--- global variables
int            period_ct;
int            period_dev;
int            handle_ma;
double         ac;
double         ad;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ct=int(InpPeriod<2 ? 2 : InpPeriod);
   period_dev=int(InpDeviation<1 ? 1 : InpDeviation);
   ac=Alpha(period_ct);
   ad=Alpha(period_dev);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCentral,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTop2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBottom2,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCloudUpper1,INDICATOR_DATA);
   SetIndexBuffer(6,BufferCloudUpper2,INDICATOR_DATA);
   SetIndexBuffer(7,BufferCloudLower1,INDICATOR_DATA);
   SetIndexBuffer(8,BufferCloudLower2,INDICATOR_DATA);
   SetIndexBuffer(9,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferRAW1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferRAW2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Gaussian Bands ("+(string)period_ct+","+(string)period_dev+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(6,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCentral,true);
   ArraySetAsSeries(BufferTop1,true);
   ArraySetAsSeries(BufferTop2,true);
   ArraySetAsSeries(BufferBottom1,true);
   ArraySetAsSeries(BufferBottom2,true);
   ArraySetAsSeries(BufferCloudUpper1,true);
   ArraySetAsSeries(BufferCloudUpper2,true);
   ArraySetAsSeries(BufferCloudLower1,true);
   ArraySetAsSeries(BufferCloudLower2,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferRAW1,true);
   ArraySetAsSeries(BufferRAW2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      ArrayInitialize(BufferCentral,0);
      ArrayInitialize(BufferTop1,EMPTY_VALUE);
      ArrayInitialize(BufferTop2,EMPTY_VALUE);
      ArrayInitialize(BufferBottom1,EMPTY_VALUE);
      ArrayInitialize(BufferBottom2,EMPTY_VALUE);
      ArrayInitialize(BufferCloudUpper1,0);
      ArrayInitialize(BufferCloudUpper2,0);
      ArrayInitialize(BufferCloudLower1,0);
      ArrayInitialize(BufferCloudLower2,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferRAW1,0);
      ArrayInitialize(BufferRAW2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCentral[i]=Smooth(BufferMA,ac,i,BufferCentral);
      BufferRAW1[i]=fabs(BufferMA[i]-BufferCentral[i]);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW2[i]=Smooth(BufferRAW1,ad,i,BufferRAW2);
      BufferTop1[i]=BufferCentral[i]+BufferRAW2[i]*InpMultiplier1;
      BufferTop2[i]=BufferCentral[i]+BufferRAW2[i]*InpMultiplier2;
      BufferBottom1[i]=BufferCentral[i]-BufferRAW2[i]*InpMultiplier1;
      BufferBottom2[i]=BufferCentral[i]-BufferRAW2[i]*InpMultiplier2;
      //--- cloud upper
      BufferCloudUpper1[i]=BufferTop2[i];
      BufferCloudUpper2[i]=BufferTop1[i];
      //--- cloud lower
      BufferCloudLower1[i]=BufferBottom1[i];
      BufferCloudLower2[i]=BufferBottom2[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Alpha(const int period)
  {
   double w=2.0*M_PI/period;
   double b=(1.0-cos(w))/(pow(1.414,2.0/3.0)-1.0);
   return(-b+sqrt(b*b+2.0*b));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Smooth(double &src[],double alpha,int index,double &res[])
  {
   return(pow(alpha,4.0)*src[index]+4.0*(1.0-alpha)*res[index+1]-6.0*pow(1.0-alpha,2.0)*res[index+2]+4.0*pow(1.0-alpha,3.0)*res[index+3]-pow(1.0-alpha,4.0)*res[index+4]);
  }
//+------------------------------------------------------------------+
