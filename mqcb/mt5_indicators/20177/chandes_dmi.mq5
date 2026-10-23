//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Chande's Dynamic Momentum Index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "DMI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int                inpDmiPeriod     = 14;           // Dynamic Momentum Index period
input int                inpDmiLowerLimit =  3;           // Dynamic Momentum Index lower limit
input int                inpDmiUpperLimit = 30;           // Dynamic Momentum Index upper limit
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE; // Price
input int                inpDevPeriod     =  5;           // Standard deviation period
input int                inpMaDevPeriod   = 10;           // Standard deviation smoothing period
input enMaTypes          inpMaDevMode     = ma_sma;       // Standard deviation smoothing metyhod
//--- buffers and global variables declarations
double dmi[],dmic[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dmi,INDICATOR_DATA);
   SetIndexBuffer(1,dmic,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Chande's DMI ("+(string)inpDmiPeriod+")");
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
double values[][4];
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(ArrayRange(values,0)!=rates_total) ArrayResize(values,rates_total);

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double avg=prices[i];
      int n=1; for(; n<inpDevPeriod && (i-n)>=0; n++) avg+=prices[i-n]; avg/=n;
      double dev=MathPow(prices[i]-avg,2);
      for(n=1; n<inpDevPeriod && (i-n)>=0; n++) dev+=(prices[i-n]-avg)*(prices[i-n]-avg); dev=MathSqrt(dev/n);
      double devma = iCustomMa(inpMaDevMode,dev,inpMaDevPeriod,i,rates_total,0);
      double _vi   = (devma!=0) ? dev/devma : 0;
      int    _td   = (_vi!=0) ?(int)MathMin(MathMax(MathRound(inpDmiPeriod/_vi),inpDmiLowerLimit),inpDmiUpperLimit) : inpDmiPeriod;
      dmi[i]  = iRsi(prices[i],_td,i,rates_total);
      dmic[i] = (i>0) ?(dmi[i]>dmi[i-1]) ? 1 :(dmi[i]<dmi[i-1]) ? 2 : dmic[i-1]: 0;
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 1
double workRsi[][rsiInstances*3];
#define _price  0
#define _change 1
#define _changa 2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);  int z=instanceNo*3;
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

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//
//
//
//
double workSma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workEma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workSmma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workLwma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
