//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "LSMA trend"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "LSMA trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
//
//---
//
input int                inpLsmaPeriod   = 35;          // Period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price
input double             inpAcceleration = 1.05;        // Acceleration factor
//--- indicator buffers
double val[],valc[],lsma[],trend[],step[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,lsma,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,step,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"LSMA trend ("+(string)inpLsmaPeriod+","+(string)inpAcceleration+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      lsma[i]  = iLinr(getPrice(inpPrice,open,close,high,low,i,rates_total),inpLsmaPeriod,i,rates_total);
      trend[i] = (i>0) ? (lsma[i]>lsma[i-1]) ? 1 : (lsma[i]<lsma[i-1]) ? -1 : trend[i-1] : 0;
      step[i]  = (i>0) ? (trend[i]!=trend[i-1]) ? 0.01 : step[i-1]*inpAcceleration : 0.01;
      val[i]   = (i>0) ? (val[i-1]+trend[i]*step[i]) : 0;
      valc[i]  = (trend[i]==1) ? 1 : (trend[i]==-1) ? 2 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workLinr[][1];
//
//---
//
double iLinr(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
      if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
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