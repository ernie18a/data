//+------------------------------------------------------------------+
//|                                 Moving Average applied price.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreenYellow
#property indicator_width1  3
//--- input parameters
input int                  Inp_MA_Period=13;                   // Period
input int                  Inp_MA_Shift=0;                     // Shift
input ENUM_MA_METHOD       Inp_MA_Method=MODE_SMMA;            // Method
input ENUM_APPLIED_PRICE   Inp_MA_applied_price=PRICE_WEIGHTED;// Type of price
//--- indicator buffers
double               ExtLineBuffer[];
double               ExtPriceBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtPriceBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_MA_Period);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_MA_Shift);
//--- name for DataWindow
   string short_name="unknown ma";
   switch(Inp_MA_Method)
     {
      case MODE_EMA :  short_name="EMA";  break;
      case MODE_LWMA : short_name="LWMA"; break;
      case MODE_SMA :  short_name="SMA";  break;
      case MODE_SMMA : short_name="SMMA"; break;
     }
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"("+string(Inp_MA_Period)+")");
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- sets first bar from what index will be draw
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_MA_Period-1);
//--- initialization done
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
   if(rates_total<Inp_MA_Period-1)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      ArrayInitialize(ExtLineBuffer,0);
      limit=0;
     }
   for(int i=limit;i<rates_total;i++)
     {
      switch(Inp_MA_applied_price)
        {
         case PRICE_CLOSE:    ExtPriceBuffer[i] = close[i];                            break;
         case PRICE_OPEN:     ExtPriceBuffer[i] = open[i];                             break;
         case PRICE_HIGH:     ExtPriceBuffer[i] = high[i];                             break;
         case PRICE_LOW:      ExtPriceBuffer[i] = low[i];                              break;
         case PRICE_MEDIAN:   ExtPriceBuffer[i] = (high[i]+low[i])/2.0;                break;
         case PRICE_TYPICAL:  ExtPriceBuffer[i] = (high[i]+low[i]+close[i])/3.0;       break;
         case PRICE_WEIGHTED: ExtPriceBuffer[i] = (high[i]+low[i]+close[i]*2.0)/4.0;   break;
        }
     }
//--- calculation
   switch(Inp_MA_Method)
     {
      case MODE_EMA:  CalculateEMA(rates_total,prev_calculated,0,ExtPriceBuffer);        break;
      case MODE_LWMA: CalculateLWMA(rates_total,prev_calculated,0,ExtPriceBuffer);       break;
      case MODE_SMMA: CalculateSmoothedMA(rates_total,prev_calculated,0,ExtPriceBuffer); break;
      case MODE_SMA:  CalculateSimpleMA(rates_total,prev_calculated,0,ExtPriceBuffer);   break;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  //+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=Inp_MA_Period+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=Inp_MA_Period;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-Inp_MA_Period])/Inp_MA_Period;
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+Inp_MA_Period);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=Inp_MA_Period+begin;
      ExtLineBuffer[begin]=price[begin];
      for(i=begin+1;i<limit;i++)
         ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
//|  linear weighted moving average                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int        i,limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      weightsum=0;
      limit=Inp_MA_Period+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
        {
         int k=i-begin+1;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      sum=0;
      for(int j=0;j<Inp_MA_Period;j++) sum+=(Inp_MA_Period-j)*price[i-j];
      ExtLineBuffer[i]=sum/weightsum;
     }
//---
  }
//+------------------------------------------------------------------+
//|  smoothed moving average                                         |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=Inp_MA_Period+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=Inp_MA_Period;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=(ExtLineBuffer[i-1]*(Inp_MA_Period-1)+price[i])/Inp_MA_Period;
//---
  }
//+------------------------------------------------------------------+
