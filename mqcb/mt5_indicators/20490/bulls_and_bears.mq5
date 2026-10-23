//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Bulls and bears"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "Bulls zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLightGreen
#property indicator_label2  "Bears zone"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrLightGreen,clrWheat
#property indicator_label3  "Bulls value"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_width3  2
#property indicator_label4  "Bears line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_width4  2
//--- input parameters
input int                inpBullBearPeriod=14;         // Bulls and bears period
//--- buffers declarations
double bullsh[],bullsz[],bullsl[],bearsh[],bearsl[],bearsz[];
//--- indicator handles
int _bullsHandle,_bearsHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,bullsh,INDICATOR_DATA);
   SetIndexBuffer(1,bullsz,INDICATOR_DATA);
   SetIndexBuffer(2,bearsh,INDICATOR_DATA);
   SetIndexBuffer(3,bearsz,INDICATOR_DATA);
   SetIndexBuffer(4,bullsl,INDICATOR_DATA);
   SetIndexBuffer(5,bearsl,INDICATOR_DATA);
//--- indicator short name assignment
   _bullsHandle=iBullsPower(_Symbol,0,inpBullBearPeriod); if(_bullsHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _bearsHandle=iBearsPower(_Symbol,0,inpBullBearPeriod); if(_bullsHandle==INVALID_HANDLE) { IndicatorRelease(_bullsHandle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"Bulls and bears ("+(string)inpBullBearPeriod+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(BarsCalculated(_bullsHandle)<rates_total) return(prev_calculated);
   if(BarsCalculated(_bullsHandle)<rates_total) return(prev_calculated);
   double _bullVal[1],_bearVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _bullCopied=CopyBuffer(_bullsHandle,0,time[i],1,_bullVal);
      int _bearCopied=CopyBuffer(_bearsHandle,0,time[i],1,_bearVal);
      bullsl[i] = (_bullCopied==1) ? _bullVal[0] : EMPTY_VALUE;
      bearsl[i] = (_bearCopied==1) ? _bearVal[0] : EMPTY_VALUE;
      bullsh[i] = MathMax(bullsl[i],0); bullsz[i] = 0;
      bearsh[i] = MathMin(bearsl[i],0); bearsz[i] = 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
