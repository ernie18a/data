//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Smoothed Kijun-sen"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Kijun-sen"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int       inpPeriod   = 26;     // Kijun
input int       inpMaPeriod = 5;      // Smoothing period
input enMaTypes inpMaMethod = ma_sma; // Smoothing method

//--- buffers and global variables declarations
double val[],valc[],pricesh[],pricesl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,pricesh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,pricesl,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed Kijun-sen("+(string)inpPeriod+")");
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
      pricesh[i] = iCustomMa(inpMaMethod,high[i],inpMaPeriod,i,rates_total,0);
      pricesl[i] = iCustomMa(inpMaMethod,low[i] ,inpMaPeriod,i,rates_total,1);
      int _start = MathMax(i-inpPeriod+1,0);
      if  (i<inpPeriod) continue;
      double khi = pricesh[ArrayMaximum(pricesh,_start,inpPeriod)];
      double klo = pricesl[ArrayMinimum(pricesl,_start,inpPeriod)];
      val[i] = ((khi+klo)!=0) ? (khi+klo)/2 : 0;
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 0 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 2
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
