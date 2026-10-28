//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Zero lag DEMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
input double             inpPeriod = 27;           // Period
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag DEMA ("+(string)inpPeriod+")");
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
      val[i]=iZlDema(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workZlDema[][4];
#define _zdema11 0
#define _zdema21 1
#define _zdema12 2
#define _zdema22 3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iZlDema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workZlDema,0)!=bars) ArrayResize(workZlDema,bars); instanceNo*=4;
   workZlDema[r][_zdema11+instanceNo] = price;
   workZlDema[r][_zdema21+instanceNo] = price;
   workZlDema[r][_zdema12+instanceNo] = price;
   workZlDema[r][_zdema22+instanceNo] = price;
   double alpha=2.0/(1.0+period);
   if(r>0)
     {
      workZlDema[r][_zdema11+instanceNo] = workZlDema[r-1][_zdema11+instanceNo]+alpha*(price                             -workZlDema[r-1][_zdema11+instanceNo]);
      workZlDema[r][_zdema21+instanceNo] = workZlDema[r-1][_zdema21+instanceNo]+alpha*(workZlDema[r][_zdema11+instanceNo]-workZlDema[r-1][_zdema21+instanceNo]);
      double dema1=2.0*workZlDema[r][_zdema11+instanceNo]-workZlDema[r][_zdema21+instanceNo];

      workZlDema[r][_zdema12+instanceNo] = workZlDema[r-1][_zdema12+instanceNo]+alpha*(dema1                             -workZlDema[r-1][_zdema12+instanceNo]);
      workZlDema[r][_zdema22+instanceNo] = workZlDema[r-1][_zdema22+instanceNo]+alpha*(workZlDema[r][_zdema12+instanceNo]-workZlDema[r-1][_zdema22+instanceNo]);
      double dema2=2.0*workZlDema[r][_zdema12+instanceNo]-workZlDema[r][_zdema22+instanceNo];
      return(2.0*dema1-dema2);
     }
   return(price);
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
