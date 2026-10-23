//+------------------------------------------------------------------+
//|                                            Stochastic Custom.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Stochastic Custom"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
//--- input parameters
input int      Inp_STO_KPeriod= 5;     // K period
input int      Inp_STO_DPeriod= 3;     // D period
input int      Inp_STO_Slowing= 3;     // Slowing
input int      Inp_STO_Level1 = 25.0;  // Value Level #1
input double   Inp_STO_Level2 = 75.0;  // Value Level #2
//--- indicator buffers
double    ExtMainBuffer[];
double    ExtSignalBuffer[];
double    ExtHighesBuffer[];
double    ExtLowesBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtHighesBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtLowesBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_STO_Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_STO_Level2);
//--- set maximum and minimum for subwindow 
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"Stoch("+
                      (string)Inp_STO_KPeriod+","+
                      (string)Inp_STO_DPeriod+","+
                      (string)Inp_STO_Slowing+")");
   PlotIndexSetString(0,PLOT_LABEL,"Main");
   PlotIndexSetString(1,PLOT_LABEL,"Signal");
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_STO_KPeriod+Inp_STO_Slowing-2);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_STO_KPeriod+Inp_STO_DPeriod);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
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
   int i,k,start;
//--- check for bars count
   if(rates_total<=Inp_STO_KPeriod+Inp_STO_DPeriod+Inp_STO_Slowing)
      return(0);
//---
   start=Inp_STO_KPeriod-1;
   if(start+1<prev_calculated) start=prev_calculated-2;
   else
     {
      for(i=0;i<start;i++)
        {
         ExtLowesBuffer[i]=0.0;
         ExtHighesBuffer[i]=0.0;
        }
     }
//--- calculate HighesBuffer[] and ExtHighesBuffer[]
   for(i=start;i<rates_total && !IsStopped();i++)
     {
      double dmin=1000000.0;
      double dmax=-1000000.0;
      for(k=i-Inp_STO_KPeriod+1;k<=i;k++)
        {
         if(dmin>low[k])  dmin=low[k];
         if(dmax<high[k]) dmax=high[k];
        }
      ExtLowesBuffer[i]=dmin;
      ExtHighesBuffer[i]=dmax;
     }
//--- %K
   start=Inp_STO_KPeriod-1+Inp_STO_Slowing-1;
   if(start+1<prev_calculated) start=prev_calculated-2;
   else
     {
      for(i=0;i<start;i++) ExtMainBuffer[i]=0.0;
     }
//--- main cycle
   for(i=start;i<rates_total && !IsStopped();i++)
     {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i-Inp_STO_Slowing+1);k<=i;k++)
        {
         sumlow +=(close[k]-ExtLowesBuffer[k]);
         sumhigh+=(ExtHighesBuffer[k]-ExtLowesBuffer[k]);
        }
      if(sumhigh==0.0) ExtMainBuffer[i]=100.0;
      else             ExtMainBuffer[i]=sumlow/sumhigh*100;
     }
//--- signal
   start=Inp_STO_DPeriod-1;
   if(start+1<prev_calculated) start=prev_calculated-2;
   else
     {
      for(i=0;i<start;i++) ExtSignalBuffer[i]=0.0;
     }
   for(i=start;i<rates_total && !IsStopped();i++)
     {
      double sum=0.0;
      for(k=0;k<Inp_STO_DPeriod;k++) sum+=ExtMainBuffer[i-k];
      ExtSignalBuffer[i]=sum/Inp_STO_DPeriod;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
