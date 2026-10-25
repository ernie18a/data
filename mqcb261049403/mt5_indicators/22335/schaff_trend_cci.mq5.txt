//------------------------------------------------------------------
#property copyright   "Copyright 2018, mladen"
#property link        "mladenfx@gmail.com"
#property description "Schaff trend CCI"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Schaff trend CCI value"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrGreen,clrCrimson
#property indicator_width1  2
//
//---
//
input double             CciPeriod = 50;          // CCI period
input int                FastEma   = 23;          // Fast ema period
input int                SlowEma   = 50;          // Slow ema period
input ENUM_APPLIED_PRICE Price     = PRICE_CLOSE; // Price

double  val[],valc[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Schaff trend CCI ("+(string)FastEma+","+(string)SlowEma+","+(string)CciPeriod+")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
//
//---
//
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price=getPrice(Price,open,close,high,low,i,rates_total);
      val[i]  = iCci(iEma(price,FastEma,i,rates_total,0)-iEma(price,SlowEma,i,rates_total,1),CciPeriod,i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return(i);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _cciInstances 1
double workCci[][_cciInstances];
#define _price  0
//
//---
//
double iCci(double price,double period,int i,int bars,int instanceNo=0)
{
   if(ArrayRange(workCci,0)!=bars) ArrayResize(workCci,bars);
   //
   //---
   //
   
   workCci[i][instanceNo+_price]=price;
         double avg = 0; for(int k=0; k<period && (i-k)>=0; k++) avg +=         workCci[i-k][instanceNo];      avg /= (double)period;
         double dev = 0; for(int k=0; k<period && (i-k)>=0; k++) dev += MathAbs(workCci[i-k][instanceNo]-avg); dev /= (double)period;
         double cci = (dev!=0) ? (price-avg)/(0.015*dev) : 0;
   return(cci);
  }
//
//---
//
double workEma[][2];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
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
