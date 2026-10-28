//+------------------------------------------------------------------+
//|                             Impulse(barabashkakvn's edition).mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property version   "1.000"
#property indicator_separate_window 
#property indicator_buffers 1
#property indicator_plots   1 
//--- Line properties are set using the compiler directives 
#property indicator_label1  "Line"      // Name of a plot for the Data Window 
#property indicator_type1   DRAW_LINE   // Type of plotting is line 
#property indicator_color1  clrGray     // Line color 
#property indicator_style1  STYLE_SOLID // Line style 
#property indicator_width1  1           // Line Width 
//--- input parameter 
input int            InpPeriod   = 14;          // Averaging period  
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;    // Method
//--- An indicator buffer for the plot 
double         DayBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DayBuffer,INDICATOR_DATA);
//--- set accuracy 
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- sets first bar from what index will be draw
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriod-1);
   //--- name for DataWindow
   string short_name="unknown ma";
   switch(InpMAMethod)
     {
      case MODE_EMA :  short_name="EMA";  break;
      case MODE_LWMA : short_name="LWMA"; break;
      case MODE_SMA :  short_name="SMA";  break;
      case MODE_SMMA : short_name="SMMA"; break;
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"Impuls "+short_name+"("+string(InpPeriod)+")");
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
//--- check for bars count
   if(rates_total<InpPeriod-1)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
      ArrayInitialize(DayBuffer,0.0);
//--- calculation
   switch(InpMAMethod)
     {
      case MODE_EMA:  CalculateEMA(rates_total,prev_calculated,close,open);        break; 
      case MODE_LWMA: CalculateLWMA(rates_total,prev_calculated,close,open);       break;
      case MODE_SMMA: CalculateSmoothedMA(rates_total,prev_calculated,close,open); break;
      case MODE_SMA:  CalculateSimpleMA(rates_total,prev_calculated,close,open);   break;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,const double &open[],const double &close[])
  {
   int   limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=InpPeriod;
      //--- set empty value for first limit bars
      for(int i=0;i<limit-1;i++)
         DayBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(int i=0;i<limit;i++)
         firstValue+=(open[i]-close[i])/Point();
      firstValue/=InpPeriod;
      DayBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(int i=limit;i<rates_total && !IsStopped();i++)
      DayBuffer[i]=DayBuffer[i-1]+((open[i]-close[i])/Point()-(open[i-InpPeriod]-close[i-InpPeriod])/Point())/InpPeriod;
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,const double &open[],const double &close[])
  {
   int    limit;
   double SmoothFactor=2.0/(1.0+InpPeriod);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpPeriod;
      DayBuffer[0]=(open[0]-close[0])/Point();
      for(int i=1;i<limit;i++)
         DayBuffer[i]=(open[i]-close[i])/Point()*SmoothFactor+DayBuffer[i-1]*(1.0-SmoothFactor);
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(int i=limit;i<rates_total && !IsStopped();i++)
      DayBuffer[i]=(open[i]-close[i])/Point()*SmoothFactor+DayBuffer[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
//|  linear weighted moving average                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,const double &open[],const double &close[])
  {
   int        limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      weightsum=0;
      limit=InpPeriod;
      //--- set empty value for first limit bars
      for(int i=0;i<limit;i++)
         DayBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(int i=0;i<limit;i++)
        {
         int k=i+1;
         weightsum+=k;
         firstValue+=k*(open[i]-close[i])/Point();
        }
      firstValue/=(double)weightsum;
      DayBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(int i=limit;i<rates_total && !IsStopped();i++)
     {
      sum=0;
      for(int j=0;j<InpPeriod;j++)
         sum+=(InpPeriod-j)*(open[i-j]-close[i-j])/Point();
      DayBuffer[i]=sum/weightsum;
     }
//---
  }
//+------------------------------------------------------------------+
//|  smoothed moving average                                         |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,const double &open[],const double &close[])
  {
   int   limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpPeriod;
      //--- set empty value for first limit bars
      for(int i=0;i<limit-1;i++)
         DayBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(int i=0;i<limit;i++)
         firstValue+=(open[i]-close[i])/Point();
      firstValue/=InpPeriod;
      DayBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(int i=limit;i<rates_total && !IsStopped();i++)
      DayBuffer[i]=(DayBuffer[i-1]*(InpPeriod-1)+(open[i]-close[i])/Point())/InpPeriod;
//---
  }
//+------------------------------------------------------------------+
