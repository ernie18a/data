//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Rsi(var) zerolag MA"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
#property indicator_minimum -1
#property indicator_maximum 101
#property indicator_level1  50
//--- input parameters
input int                inpPeriod   = 32;          // RSI period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price 

//--- buffers and global variables declarations
double val[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi(var) zerolag MA ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);

      double _price1 = prices[i];
      double _price2 = (i>0) ? prices[i-1] : prices[i];

      double _bulls = 0.5*(MathAbs(_price1-_price2)+(_price1-_price2));
      double _bears = 0.5*(MathAbs(_price1-_price2)-(_price1-_price2));
      double _avgBulls = iZeroLag(_bulls,inpPeriod,i,rates_total,0);
      double _avgBears = iZeroLag(_bears,inpPeriod,i,rates_total,1);

      val[i] = (_avgBulls!=0) ? MathMax(MathMin(100.0/(1+_avgBears/_avgBulls),100),0) : 0;
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workZl[][4];
#define _zprice 0
#define _zlema  1
//
//---
//
double iZeroLag(double price,double length,int r,int bars,int instanceNo=0)
  {
   if(length<=1) return(price);
   if(ArrayRange(workZl,0)!=bars) ArrayResize(workZl,bars); instanceNo*=2; workZl[r][_zprice+instanceNo]=price;
   double median = 0;
   double alpha  = 2.0/(1.0+length);
   int    per    = (int)((length-1.0)/2.0);
   if(r<(per+1))
      workZl[r][_zlema+instanceNo]=price;
   else
     {
      if((int)length%2==0)
         median = (workZl[r-per][_zprice+instanceNo]+workZl[r-per-1][_zprice+instanceNo])/2.0;
      else  median =  workZl[r-per][_zprice+instanceNo];
      workZl[r][_zlema+instanceNo]=workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-median-workZl[r-1][_zlema+instanceNo]);
     }
   return(workZl[r][_zlema+instanceNo]);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
