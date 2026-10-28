//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "RSI of Hull"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "RSI of Hull"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpRsiPeriod  =  14;         // RSI period
input int                inpHullPeriod =  32;         // Hull period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
//--- buffers declarations
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
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI of Hull ("+(string)inpRsiPeriod+","+(string)inpHullPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = iRsi(iHull(getPrice(inpPrice,open,close,high,low,i,rates_total),inpHullPeriod,i,rates_total),inpRsiPeriod,i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 1
double workRsi[][rsiInstances*3];
#define _price  0
#define _prices 3
#define _change 1
#define _changa 2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*3;

//
//
//
//
//

   workRsi[r][z+_price]=price;
   double alpha=1.0/MathMax(period,1);
   if(r<period)
     {
      int k; double sum=0; for(k=0; k<period && (r-k-1)>=0; k++) sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
      workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
      workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
     }
   else
     {
      double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
      workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
      workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
     }
   return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workHull[][2];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHull(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workHull,0)!=bars) ArrayResize(workHull,bars);
   instanceNo*=2; workHull[r][instanceNo]=price;
   if(period<=1) return(price);
//
//---
//
   int HmaPeriod  = (int)MathMax(period,2);
   int HalfPeriod = (int)MathFloor(HmaPeriod/2);
   int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
   double hma,hmw,weight;
   hmw=HalfPeriod; hma=hmw*price;
   for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
     {
      weight = HalfPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]=2.0*hma/hmw;
   hmw=HmaPeriod; hma=hmw*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      weight = HmaPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]-=hma/hmw;
   hmw=HullPeriod; hma=hmw*workHull[r][instanceNo+1];
   for(int k=1; k<HullPeriod && (r-k)>=0; k++)
     {
      weight = HullPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][1+instanceNo];
     }
   return(hma/hmw);
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
