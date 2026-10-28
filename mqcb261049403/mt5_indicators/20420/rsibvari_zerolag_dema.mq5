//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Rsi(var) zerolag DEMA"
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
input int                inpPeriod   = 50;          // RSI period
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi(var) zerolag DEMA ("+(string)inpPeriod+")");
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
      double _avgBulls = iZlDema(_bulls,inpPeriod,i,rates_total,0);
      double _avgBears = iZlDema(_bears,inpPeriod,i,rates_total,1);

      val[i] = (_avgBulls!=0) ? MathMax(MathMin(100.0/(1+_avgBears/_avgBulls),100),0) : 0;
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workZlDema[][8];
#define _zdema11 0
#define _zdema21 1
#define _zdema12 2
#define _zdema22 3
//
//---
//
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
