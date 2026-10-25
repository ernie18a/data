//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Stochastic of Hull average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Stochastic of Hull average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrDeepPink
#property indicator_width1  2
//--- input parameters
input int                inpStoPeriod  =  32;         // Stochastic period
input int                inpStoSlowing =   3;         // Stochastic slowing
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic of Hull ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)inpHullPeriod+")");
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
      double _price=iHull(getPrice(inpPrice,open,close,high,low,i,rates_total),inpHullPeriod,i,rates_total);
      val[i]  = iStoch(_price,_price,_price,inpStoPeriod,inpStoSlowing,rates_total,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSto[][5];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iStoch(double priceR,double priceH,double priceL,int period,int slowing,int bars,int i,int instanceNo=0)
  {
   if(ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); instanceNo*=5;
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
   for(int k=1; k<period && (i-k)>=0; k++)
     {
      workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
      workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
     }
   double sumlow  = 0.0;
   double sumhigh = 0.0;
   for(int k=0; k<slowing && (i-k)>=0; k++)
     {
      sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
      sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
     }
   if(sumhigh!=0.0)
      return(100.0*sumlow/sumhigh);
   else  return(0);
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
