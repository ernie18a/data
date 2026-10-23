//+------------------------------------------------------------------+
//|                                 Custom Moving Average Levels.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Standart Moving Average and two levels"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_DOT
#property indicator_color1  clrGray
#property indicator_label1  "UP"

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_label2  "Middle"

#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_color3  clrGray
#property indicator_label3  "Down"
//--- input parameters
input int            InpMAPeriod=13;         // Period
input int            InpMAShift=0;           // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_SMMA;  // Method
input int            InpLevelUp=100;         // Level Up (in pips)
input int            InpLevelDown=-100;      // Level Down (in pips)
//--- indicator buffers
double               ExtLineBufferUp[];
double               ExtLineBufferMiddle[];
double               ExtLineBufferDown[];
//---
double ExtInpLevelUp=0.0;
double ExtInpLevelDown=0.0;
//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++)
        {
         ExtLineBufferMiddle[i]  = 0.0;
         ExtLineBufferUp[i]      = 0.0;
         ExtLineBufferDown[i]    = 0.0;
        }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];

      firstValue/=InpMAPeriod;

      ExtLineBufferMiddle[limit-1]  = firstValue;
      ExtLineBufferUp[limit-1]      = firstValue + ExtInpLevelUp;
      ExtLineBufferDown[limit-1]    = firstValue + ExtInpLevelDown;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtLineBufferMiddle[i]  = ExtLineBufferMiddle[i-1]+(price[i]-price[i-InpMAPeriod])/InpMAPeriod;
      ExtLineBufferUp[i]      = ExtLineBufferMiddle[i] + ExtInpLevelUp;
      ExtLineBufferDown[i]    = ExtLineBufferMiddle[i] + ExtInpLevelDown;
     }
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+InpMAPeriod);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod+begin;

      ExtLineBufferMiddle[begin] = price[begin];
      ExtLineBufferUp[begin]     = ExtLineBufferMiddle[begin] + ExtInpLevelUp;
      ExtLineBufferDown[begin]   = ExtLineBufferMiddle[begin] + ExtInpLevelDown;
      for(i=begin+1;i<limit;i++)
        {
         ExtLineBufferMiddle[i]  = price[i]*SmoothFactor+ExtLineBufferMiddle[i-1]*(1.0-SmoothFactor);
         ExtLineBufferUp[i]      = ExtLineBufferMiddle[i] + ExtInpLevelUp;
         ExtLineBufferDown[i]    = ExtLineBufferMiddle[i] + ExtInpLevelDown;
        }
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtLineBufferMiddle[i]  = price[i]*SmoothFactor+ExtLineBufferMiddle[i-1]*(1.0-SmoothFactor);
      ExtLineBufferUp[i]      = ExtLineBufferMiddle[i] + ExtInpLevelUp;
      ExtLineBufferDown[i]    = ExtLineBufferMiddle[i] + ExtInpLevelDown;
     }
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
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit;i++)
        {
         ExtLineBufferMiddle[i]  = 0.0;
         ExtLineBufferUp[i]      = 0.0;
         ExtLineBufferDown[i]    = 0.0;
        }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
        {
         int k=i-begin+1;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;

      ExtLineBufferMiddle[limit-1]  = firstValue;
      ExtLineBufferUp[limit-1]      = firstValue + ExtInpLevelUp;
      ExtLineBufferDown[limit-1]    = firstValue + ExtInpLevelDown;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      sum=0;
      for(int j=0;j<InpMAPeriod;j++)
         sum+=(InpMAPeriod-j)*price[i-j];

      ExtLineBufferMiddle[i]  = sum/weightsum;
      ExtLineBufferUp[i]      = ExtLineBufferMiddle[i] + ExtInpLevelUp;
      ExtLineBufferDown[i]    = ExtLineBufferMiddle[i] + ExtInpLevelDown;
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
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++)
        {
         ExtLineBufferMiddle[i]  = 0.0;
         ExtLineBufferUp[i]      = 0.0;
         ExtLineBufferDown[i]    = 0.0;
        }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
         
      firstValue/=InpMAPeriod;
      
      ExtLineBufferMiddle[limit-1]  = firstValue;
      ExtLineBufferUp[limit-1]      = firstValue + ExtInpLevelUp;
      ExtLineBufferDown[limit-1]    = firstValue + ExtInpLevelDown;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtLineBufferMiddle[i]  = (ExtLineBufferMiddle[i-1]*(InpMAPeriod-1)+price[i])/InpMAPeriod;
      ExtLineBufferUp[i]      = ExtLineBufferMiddle[i] + ExtInpLevelUp;
      ExtLineBufferDown[i]    = ExtLineBufferMiddle[i] + ExtInpLevelDown;
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBufferUp,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBufferDown,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpMAPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpMAPeriod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpMAShift);
   PlotIndexSetInteger(1,PLOT_SHIFT,InpMAShift);
   PlotIndexSetInteger(2,PLOT_SHIFT,InpMAShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---
   ExtInpLevelUp=InpLevelUp*Point();
   ExtInpLevelDown=InpLevelDown*Point();
//---- initialization done
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check for bars count
   if(rates_total<InpMAPeriod-1+begin)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      ArrayInitialize(ExtLineBufferUp,0);
      ArrayInitialize(ExtLineBufferMiddle,0);
      ArrayInitialize(ExtLineBufferDown,0);
     }
//--- sets first bar from what index will be draw
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod-1+begin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpMAPeriod-1+begin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpMAPeriod-1+begin);
//--- calculation
   switch(InpMAMethod)
     {
      case MODE_EMA:  CalculateEMA(rates_total,prev_calculated,begin,price);        break;
      case MODE_LWMA: CalculateLWMA(rates_total,prev_calculated,begin,price);       break;
      case MODE_SMMA: CalculateSmoothedMA(rates_total,prev_calculated,begin,price); break;
      case MODE_SMA:  CalculateSimpleMA(rates_total,prev_calculated,begin,price);   break;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
