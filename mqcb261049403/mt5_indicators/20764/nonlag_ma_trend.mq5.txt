//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "nonlag trend"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "nonlag trend"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//
//--- input parameters
//
input int                inpPeriod = 10;          // Look back period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//
//--- buffers and global variables declarations
//
double valu[],vald[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,vald,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"nonlag trend ("+(string)inpPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]  = iNonLagMa(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      valu[i]    = high[i];
      vald[i]    = low[i];
      valc[i]    = (i>0) ? (prices[i] > prices[i-1]) ? 1 : (prices[i] < prices[i-1]) ? 2 :  valc[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _length  0
#define _len     1
#define _weight  2
//
//---
//
double  nlmvalues[][3];
double  nlmprices[][1];
double  nlmalphas[][1];
//
//---
//
double iNonLagMa(double price,double length,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(nlmprices,0)!=bars) ArrayResize(nlmprices,bars);
   if(ArrayRange(nlmvalues,0)<instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
   nlmprices[r][instanceNo]=price;
   if(length<5 || r<3) return(nlmprices[r][instanceNo]);
//
//---
//
   if(nlmvalues[instanceNo][_length]!=length)
     {
      double Cycle = 4.0;
      double Coeff = 3.0*M_PI;
      int    Phase = (int)(length-1);

      nlmvalues[instanceNo][_length] =       length;
      nlmvalues[instanceNo][_len   ] = (int)(length*4) + Phase;
      nlmvalues[instanceNo][_weight] = 0;

      if(ArrayRange(nlmalphas,0)<(int)nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,(int)nlmvalues[instanceNo][_len]);
      for(int k=0; k<(int)nlmvalues[instanceNo][_len]; k++)
        {
         double t;
         if(k<=Phase-1)
               t = 1.0 * k/(Phase-1);
         else  t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0);
         double beta=MathCos(M_PI*t);
         double g=1.0/(Coeff*t+1); if(t<=0.5) g=1;

         nlmalphas[k][instanceNo]        = g * beta;
         nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
        }
     }
//
//---
//
   if(nlmvalues[instanceNo][_weight]>0)
     {
      double sum=0;
      for(int k=0; k<(int)nlmvalues[instanceNo][_len] && (r-k)>=0; k++) sum+=nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
      return( sum / nlmvalues[instanceNo][_weight]);
     }
   else return(0);
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
