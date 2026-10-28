//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI squeeze"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "CCI Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrYellowGreen,clrOrange,clrOrangeRed
#property indicator_width1  2
#property indicator_label2  "CCI"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrYellowGreen,clrOrange,clrOrangeRed
#property indicator_width2  2
//
//---
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//
//---
//
input int                inpCciPeriod       = 32;            // CCI period
input ENUM_APPLIED_PRICE inpCciPrice        = PRICE_TYPICAL; // CCI price
input int                inpMaPeriod        = 200;           // Average period
input enMaTypes          inpMaMethod        = ma_ema;        // Average method
input ENUM_APPLIED_PRICE inpMaPrice         = PRICE_TYPICAL; // Average price
                                                             //
//---
//
double  val[],valc[],valh[],valhc[],prices[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,valh,INDICATOR_DATA);
   SetIndexBuffer(1,valhc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI squeeze ("+(string)inpCciPeriod+","+(string)inpMaPeriod+")");
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i] = getPrice(inpCciPrice,open,close,high,low,i,rates_total);
      double avg = 0; for(int k=0; k<inpCciPeriod && (i-k)>=0; k++) avg +=         prices[i-k];      avg /= inpCciPeriod;
      double dev = 0; for(int k=0; k<inpCciPeriod && (i-k)>=0; k++) dev += MathAbs(prices[i-k]-avg); dev /= inpCciPeriod;
      double prc = getPrice(inpMaPrice,open,close,high,low,i,rates_total);
      double ma    = iCustomMa(inpMaMethod,prc,inpMaPeriod,i,rates_total);
         val[i] = (dev!=0) ? (prices[i]-avg)/(0.015*dev) : 0;
         if (val[i]>0)
         {
            if (prc>ma) valc[i] = 0;
            if (prc<ma) valc[i] = 1;
         }
         if (val[i]<0)
         {
            if (prc>ma) valc[i] = 2;
            if (prc<ma) valc[i] = 3;
         }
         valh[i] = val[i];
         valhc[i] = valc[i];
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars); int k;

   workSma[r][instanceNo+0]=price;
   double avg=price; for(k=1; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo+0];
   return(avg/k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
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
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<=1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight = period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
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
