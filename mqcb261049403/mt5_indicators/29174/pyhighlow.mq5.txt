//+------------------------------------------------------------------+
//|                                                    PYHighLow.mq5 |
//|                                              I Made Purnama Yasa |
//|                                                                - |
//+------------------------------------------------------------------+
#property copyright "I Made Purnama Yasa"
#property link      "-"
#property version   "1.00"

//---- separate window
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//---- plot HighLow
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int InpShift=5; // Shift
//--- indicator buffers
double ExtHighLowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0,ExtHighLowBuffer,INDICATOR_DATA);
   //--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   //--- set maximum and minimum for subwindow 
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   //--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"PYHighLow("+(string)InpShift+")");
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(
   const int rates_total,
   const int prev_calculated,
   const datetime &time[],
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
{
   double highsum=0;
   double lowsum=0;
   //--- summary highlow
   for(int i=0;i<rates_total&&!IsStopped();i++){
      highsum+=high[i];
      lowsum+=low[i];
   }
   //--- highlow
   double highlowsum=((highsum-lowsum)/rates_total)*InpShift;
   for(int i=0;i<rates_total&&!IsStopped();i++){
      double highlow=high[i]-low[i];
      if(highlowsum>highlow){
         ExtHighLowBuffer[i]=100-(((highlowsum-highlow)/highlowsum)*100);
      }else if(highlowsum<highlow){
         ExtHighLowBuffer[i]=100-(((highlow-highlowsum)/highlowsum)*100);
      }else{
         ExtHighLowBuffer[i]=0;
      }
   }
   //--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   //---
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent
(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam
)
{
   //---
}
//+------------------------------------------------------------------+
