//+------------------------------------------------------------------+
//|                        StopATR_auto(barabashkakvn's edition).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_label1  "ATR Max"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_label2  "ATR Min"
//--- input parameters
input int InpAtrPeriod=77;    // ATR period
input double Target=2.5;      // Target
//--- indicator buffers
double    ExtATRBufferMax[];
double    ExtATRBufferMin[];
double    ExtATRBuffer[];
double    ExtTRBuffer[];
//--- global variable
int       ExtPeriodATR;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpAtrPeriod<=0)
     {
      ExtPeriodATR=14;
      printf("Incorrect input parameter InpAtrPeriod = %d. Indicator will use value %d for calculations.",InpAtrPeriod,ExtPeriodATR);
     }
   else
      ExtPeriodATR=InpAtrPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtATRBufferMax,INDICATOR_DATA);
   SetIndexBuffer(1,ExtATRBufferMin,INDICATOR_DATA);
   SetIndexBuffer(2,ExtATRBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtTRBuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpAtrPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpAtrPeriod);
//--- The 0 (empty) value will mot participate in drawing 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- name for DataWindow and indicator subwindow label
   string short_name="ATR("+string(ExtPeriodATR)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name+" Max");
   PlotIndexSetString(1,PLOT_LABEL,short_name+" Min");
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
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
   int i,limit;
//--- check for bars count
   if(rates_total<=ExtPeriodATR)
      return(0); // not enough bars for calculation
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      ExtATRBufferMax[0]=0.0;
      ExtATRBufferMin[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1;i<rates_total && !IsStopped();i++)
         ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1;i<=ExtPeriodATR;i++)
        {
         ExtATRBufferMax[i]=0.0;
         ExtATRBufferMin[i]=0.0;
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=ExtPeriodATR;
      ExtATRBufferMax[ExtPeriodATR]=firstValue;
      ExtATRBufferMin[ExtPeriodATR]=firstValue;
      ExtATRBuffer[ExtPeriodATR]=firstValue;
      limit=ExtPeriodATR+1;
     }
   else
      limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ExtPeriodATR])/ExtPeriodATR;
      ExtATRBufferMax[i]=open[i]+Target*ExtATRBuffer[i];
      ExtATRBufferMin[i]=open[i]-Target*ExtATRBuffer[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
