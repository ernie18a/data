//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rainbow oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Rainbow oscillator up band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_label2  "Rainbow oscillator down band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_label3  "Rainbow oscillator"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrDarkGray,clrSandyBrown,clrDodgerBlue
#property indicator_width3  2
//--- input parameters
input int                inpPeriod    = 5;            // Period
input int                inpRwmaDepth = 10;           // RWMA depth (maximal 50)
input ENUM_APPLIED_PRICE inpPrice     = PRICE_MEDIAN; // Price
//--- indicator buffers
double val[],valc[],valup[],valdn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valup,INDICATOR_DATA);
   SetIndexBuffer(1,valdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Rainbow oscillator ("+(string)inpPeriod+","+(string)inpRwmaDepth+")");
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
#define MAX_depth 50
double pBuffer[][MAX_depth];
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(ArrayRange(pBuffer,0)!=rates_total) ArrayResize(pBuffer,rates_total);
   double _weight = (inpPeriod+1)*inpPeriod*0.5;
   int    _depth  = MathMax(MathMin(inpRwmaDepth,50),1);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double price = getPrice(inpPrice,open,close,high,low,i,rates_total);;
      double mina  = price;
      double maxa  = price;
      double minp  = price;
      double maxp  = price;
      double sum   = 0;
      for(int k=0,j; k<_depth; k++)
        {
         pBuffer[i][k]=price;
         if(i>inpPeriod)
           {
            for(j=0,price=0; j<inpPeriod; j++) price+=(inpPeriod-j)*pBuffer[i-j][k];
            price/=_weight;
           }
         sum  += price;
         mina  = MathMin(mina,price);
         maxa  = MathMax(maxa,price);
         minp  = (i>=k) ? MathMin(minp,pBuffer[i-k][0]) : 0;
         maxp  = (i>=k) ? MathMax(maxp,pBuffer[i-k][0]) : 0;
        }

      double rma=sum/_depth;

      //
      //---
      //

      double rangea = maxa-mina;
      double rangep = maxp-minp;
      if(rangep!=0)
        {
         valup[i] =  100.0*rangea/rangep;
         valdn[i] = -100.0*rangea/rangep;
         val[i]   =  100*(pBuffer[i][0]-rma)/rangep;
         valc[i]  = (val[i]>0) ? 2 : (val[i]<0) ? 1 : 0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
