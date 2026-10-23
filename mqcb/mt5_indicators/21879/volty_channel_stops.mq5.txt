//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Volty channel stops"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGainsboro
#property indicator_style1  STYLE_DOT
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGainsboro
#property indicator_style2  STYLE_DOT
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_width3  3
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_width4  3
#property indicator_type5   DRAW_COLOR_ARROW
#property indicator_color5  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_width5  2
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
input int                AtrPeriod = 10;          // ATR period
input double             Kv        = 4;           // ATR multiplier
input int                MaPeriod  = 10;          // Smoothing period
input enMaTypes          MaMethod  = ma_sma;      // Smoothing method
input ENUM_APPLIED_PRICE Price     = PRICE_CLOSE; // Price
input double             Risk      = 1;           // Money risk

double bba[],bbc[],bblu[],bbld[],amax[],amin[],bmax[],bmin[],trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,bmax ,INDICATOR_DATA);
   SetIndexBuffer(1,bmin ,INDICATOR_DATA);
   SetIndexBuffer(2,bblu ,INDICATOR_DATA);
   SetIndexBuffer(3,bbld ,INDICATOR_DATA); 
   SetIndexBuffer(4,bba  ,INDICATOR_DATA);  PlotIndexSetInteger(4,PLOT_ARROW,159);
   SetIndexBuffer(5,bbc  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,amax ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,amin ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,trend,INDICATOR_CALCULATIONS);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
{

   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price = getPrice(Price,open,close,high,low,i,rates_total);
      double ma    = iCustomMa(MaMethod,price,MaPeriod,i,rates_total,0);
      double atr   = 0; 
         for (int k=0; k<AtrPeriod && (i-k-1)>=0; k++) 
            atr += MathMax(high[i-k],close[i-k-1])- MathMin(low[i-k],close[i-k-1]);
            atr /= AtrPeriod;
               amax[i]  = ma+atr*Kv;
               amin[i]  = ma-atr*Kv;
   	         bmax[i]  = amax[i]+0.5*(Risk-1)*(amax[i]-amin[i]);
	  	         bmin[i]  = amin[i]-0.5*(Risk-1)*(amax[i]-amin[i]);
               trend[i] = (i>0) ? (price>amax[i-1]) ? 1 : (price<amin[i-1]) ? -1 : trend[i-1] : 0;
                       if (i>0)
                       {
                           if (trend[i]==-1 && amax[i]>amax[i-1]) amax[i] = amax[i-1];
                           if (trend[i]== 1 && amin[i]<amin[i-1]) amin[i] = amin[i-1];
                           if (trend[i]==-1 && bmax[i]>bmax[i-1]) bmax[i] = bmax[i-1];
                           if (trend[i]== 1 && bmin[i]<bmin[i-1]) bmin[i] = bmin[i-1];
                       }                  
               bblu[i] = EMPTY_VALUE; bbld[i] = EMPTY_VALUE;
                  if (trend[i] ==  1) { bblu[i] = bmin[i]; bbc[i] = 1; }
                  if (trend[i] == -1) { bbld[i] = bmax[i]; bbc[i] = 2; }
               bba[i] = (i>0) ? (trend[i]!=trend[i-1]) ? (trend[i]== 1) ? bblu[i] : bbld[i] : EMPTY_VALUE :  EMPTY_VALUE;
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
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
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k=1;

   workSma[r][instanceNo+0] = price;
   double avg = price; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
   return(avg);
}
//
//---
//
double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}
//
//---
//
double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}
//
//---
//
double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<1) return(price);
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
