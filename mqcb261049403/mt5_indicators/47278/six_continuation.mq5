//+------------------------------------------------------------------+
//|                                                 Six Soldiers.mq5 |
//|                                      Rajesh Nait, Copyright 2023 |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Rajesh Nait, Copyright 2023"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot Bullish Marubozu
#property indicator_label1  "+SS"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSnow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bearish Marubozu
#property indicator_label2  "-SS"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrSnow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

enum mode {
   Two, // Two Candle Breaks
   Three // Three Candle Breaks

};
input mode SelectMode = Two; // Search Mode
//--- input parameters
input group             "Swing Low"
input uchar               InpSSBullishCode              = 233;         // SSBullish: code for style DRAW_ARROW (font Wingdings)
input int                 InpSSBullishShift             = 10;          // SSBullish: vertical shift of arrows in pixels
input group             "Swing High"
input uchar               InpSSBearishCode              = 234;         // SSBearish: code for style DRAW_ARROW (font Wingdings)
input int                 InpSSBearishShift             =10;           // SSBearish: vertical shift of arrows in pixels
//--- indicator buffers
double   SSBullishBuffer[];
double   SSBearishBuffer[];
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   min_rates_total=6;
//--- indicator buffers mapping
   SetIndexBuffer(0,SSBullishBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SSBearishBuffer,INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   //PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   // PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

   PlotIndexSetInteger(0,PLOT_ARROW,InpSSBullishCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpSSBearishCode);

   ArraySetAsSeries(SSBullishBuffer,true);
   ArraySetAsSeries(SSBearishBuffer,true);

//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,InpSSBullishShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-InpSSBearishShift);
//--- set as an empty value 0.0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
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
                const int &spread[]) {
//---
   if(rates_total<min_rates_total)
      return(0);

   int limit;

   if(prev_calculated>rates_total || prev_calculated<=0) {
      limit=rates_total-min_rates_total;
   } else {
      limit=rates_total-prev_calculated;
   }
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---

   for(int i=limit; i>=0 && !IsStopped(); i--) {
      SSBullishBuffer[i]=0.0;
      SSBearishBuffer[i]=0.0;

      SSBearishBuffer[0]=0.0;
      if( open[i+5]>close[i+5] && open[i+4]>close[i+4] && open[i+3]>close[i+3] &&  open[i+2]>close[i+2] && open[i+1]>close[i+1] && open[i]>close[i])
         SSBearishBuffer[i]=high[i];

      SSBullishBuffer[0]=0.0;
      if( open[i+5]<close[i+5] && open[i+4]<close[i+4] && open[i+3]<close[i+3] &&  open[i+2]<close[i+2] && open[i+1]<close[i+1] && open[i]<close[i])
         SSBullishBuffer[i]=low[i];

   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
