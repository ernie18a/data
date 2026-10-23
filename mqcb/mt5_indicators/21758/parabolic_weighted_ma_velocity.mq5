//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Parabolic weighted MA velocity"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Parabolic weighted MA velocity"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input int                inpPeriod = 27;           // Period
input double             inpPower  = 1;            // Power
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Parabolic weighted MA velocity ("+(string)inpPeriod+","+(string)inpPower+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      val[i] = iVelocity(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpPower,i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _velInstances 1
double _velWork[][_velInstances];
double iVelocity(double price, double period, double power, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_velWork,0)!=bars) ArrayResize(_velWork,bars);
   _velWork[i][instanceNo] = price;
   
   
   double suma = 0.0, sumwa=0;
   double sumb = 0.0, sumwb=0;

      for(int k=0; k<period && (i-k)>=0; k++)
      {
         double weight = MathPow((period-k),power);
            suma  += _velWork[i-k][instanceNo] * weight;
            sumb  += _velWork[i-k][instanceNo] * weight * weight;
            sumwa += weight;
            sumwb += weight*weight;
      }
   return(sumb/sumwb-suma/sumwa);
}

//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+