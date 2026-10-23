//+------------------------------------------------------------------+
//|                       KDJ Indicator(barabashkakvn's edition).mq5 |
//|                                                        senlin ge |
//+------------------------------------------------------------------+
#property copyright "senlin ge 20080219"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- Histogram properties are set using the compiler directives 
#property indicator_label1  "KDC"               // Name of a plot for the Data Window 
#property indicator_type1   DRAW_HISTOGRAM      // Type of plotting is line 
#property indicator_color1  clrMediumSlateBlue  // Line color 
#property indicator_style1  STYLE_SOLID         // Line style 
#property indicator_width1  3                   // Line Width 
//--- An indicator buffer for the plot 
double         KDCBuffer[];
double         RSVBuffer[];
double         KBuffer[];
double         DBuffer[];
//--- input parameters
input int      M1=3;
input int      M2=6;
input int      KdjPeriod=30;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(M2>=KdjPeriod)
     {
      Print("The parameter \"M2\" can not be greater than or equal to \"KdjPeriod\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(M1>=M2)
     {
      Print("The parameter \"M1\" can not be greater than or equal to \"M2\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(M1<=0 || M2<=0 || KdjPeriod<=0)
     {
      Print("The parameter can not be less than or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,KDCBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,RSVBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,KBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,DBuffer,INDICATOR_CALCULATIONS);
//--- name for indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"KDJ("+string(M1)+","+string(M2)+","+string(KdjPeriod)+")");
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
//--- by default  "time [rates_total-1]"  is the most right bar on the chart,
//--- and         "0"                     is the leftmost bar on the chart
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit;i<rates_total;i++)
     {
      if(i<KdjPeriod)
        {
         RSVBuffer[i]=50.0;
         KBuffer[i]=50.0;
         DBuffer[i]=50.0;
         KDCBuffer[i]=50.0;
        }
      else
        {
         double MaxHigh=high[ArrayMaximum(high,i-KdjPeriod,KdjPeriod)];
         double MinLow=low[ArrayMinimum(low,i-KdjPeriod,KdjPeriod)]; // Low[iLowest(NULL,0,MODE_LOW,KdjPeriod,i)];
         if(MaxHigh-MinLow!=0.0)
            RSVBuffer[i]=(close[i]-MinLow)/(MaxHigh-MinLow)*100.0;
         else
            RSVBuffer[i]=1.0;
         //--- get K value
         double sumK=0.0;
         for(int j=i-M1;j<i;j++)
            sumK+=RSVBuffer[j];   //i=10; KdjPeriod=3 -> от 7 до 10
         KBuffer[i]=sumK/M1;
         //--- get D value
         double sumD=0.0;
         for(int j=i-M2;j<i;j++)
            sumD+=KBuffer[j];   //i=10; KdjPeriod=3 -> от 7 до 10
         DBuffer[i]=sumD/M2;
         //--- get KDC value
         KDCBuffer[i]=KBuffer[i]-DBuffer[i];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
