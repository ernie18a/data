//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands  stops - EMA deviation version"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
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

enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
  };
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
input int       MaPeriod        = 20;       // Bollinger bands period
input enMaTypes MaMethod        = ma_sma;   // Moving average method
input enPrices  Price           = pr_close; // Price
input int       DeviationPeriod = 20;       // Deviations period
input double    Deviation       = 1;        // Deviation
input double    Risk            = 1;        // Risk

double bba[],bbc[],bblu[],bbld[],amax[],amin[],bmax[],bmin[],trend[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,bmax,INDICATOR_DATA);
   SetIndexBuffer(1,bmin,INDICATOR_DATA);
   SetIndexBuffer(2,bblu,INDICATOR_DATA);
   SetIndexBuffer(3,bbld,INDICATOR_DATA);
   SetIndexBuffer(4,bba,INDICATOR_DATA);  PlotIndexSetInteger(4,PLOT_ARROW,159);
   SetIndexBuffer(5,bbc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,amax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,amin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,trend,INDICATOR_CALCULATIONS);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price = getPrice(Price,open,close,high,low,i,rates_total,0);
      double dev   = iEmaDeviation(price,DeviationPeriod,i,rates_total);
      double ma    = iCustomMa(MaMethod,price,MaPeriod,i,rates_total,0);
      amax[i]  = ma+dev*Deviation;
      amin[i]  = ma-dev*Deviation;
      bmax[i]  = amax[i]+0.5*(Risk-1)*(amax[i]-amin[i]);
      bmin[i]= amin[i]-0.5*(Risk-1)*(amax[i]-amin[i]);
      trend[i] =(i>0) ?(price>amax[i-1]) ? 1 :(price<amin[i-1]) ? -1 : trend[i-1] : 0;
      if(i>0)
        {
         if(trend[i]==-1 && amax[i]>amax[i-1]) amax[i] = amax[i-1];
         if(trend[i]== 1 && amin[i]<amin[i-1]) amin[i] = amin[i-1];
         if(trend[i]==-1 && bmax[i]>bmax[i-1]) bmax[i] = bmax[i-1];
         if(trend[i]== 1 && bmin[i]<bmin[i-1]) bmin[i] = bmin[i-1];
        }
      bblu[i]=EMPTY_VALUE; bbld[i]=EMPTY_VALUE;
      if(trend[i] ==  1) { bblu[i] = bmin[i]; bbc[i] = 1; }
      if(trend[i] == -1) { bbld[i] = bmax[i]; bbc[i] = 2; }
      bba[i]=(i>0) ?(trend[i]!=trend[i-1]) ?(trend[i]==1) ? bblu[i]: bbld[i]: EMPTY_VALUE :  EMPTY_VALUE;
     }
   return(i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _edevInstances 1
#define _edevInstancesSize 2
double workEmaDeviation[][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEmaDeviation,0)!=bars) ArrayResize(workEmaDeviation,bars); instanceNo*=_edevInstancesSize;

   workEmaDeviation[i][instanceNo+_ema0] = price;
   workEmaDeviation[i][instanceNo+_ema1] = price;
   if(i>0 && period>1)
     {
      double alpha=2.0/(1.0+period);
      workEmaDeviation[i][instanceNo+_ema0] = workEmaDeviation[i-1][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[i-1][instanceNo+_ema0]);
      workEmaDeviation[i][instanceNo+_ema1] = workEmaDeviation[i-1][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[i-1][instanceNo+_ema1]);
     }
   return(MathSqrt(period*(workEmaDeviation[i][instanceNo+_ema1]-workEmaDeviation[i][instanceNo+_ema0]*workEmaDeviation[i][instanceNo+_ema0])/MathMax(period-1,1)));
  }
//
//---
///
#define _maInstances 2
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
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
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
//
//---
//
#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
//
//---
//
double getPrice(int tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars,int instanceNo=0)
  {
   if(tprice>=pr_haclose)
     {
      if(ArrayRange(workHa,0)!=_bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;

      //
      //---
      //

      double haOpen;
      if(i>0)
         haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
      else   haOpen  = (open[i]+close[i])/2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
      double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

      if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; }
      else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  }
      workHa[i][instanceNo+2] = haOpen;
      workHa[i][instanceNo+3] = haClose;

      //
      //---
      //

      switch(tprice)
        {
         case pr_haclose:     return(haClose);
         case pr_haopen:      return(haOpen);
         case pr_hahigh:      return(haHigh);
         case pr_halow:       return(haLow);
         case pr_hamedian:    return((haHigh+haLow)/2.0);
         case pr_hamedianb:   return((haOpen+haClose)/2.0);
         case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
         case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
         case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
         case pr_hatbiased:
            if(haClose>haOpen)
            return((haHigh+haClose)/2.0);
            else  return((haLow+haClose)/2.0);
         case pr_hatbiased2:
            if(haClose>haOpen)  return(haHigh);
            if(haClose<haOpen)  return(haLow);
            return(haClose);
        }
     }

//
//---
//

   switch(tprice)
     {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:
         if(close[i]>open[i])
         return((high[i]+close[i])/2.0);
         else  return((low[i]+close[i])/2.0);
      case pr_tbiased2:
         if(close[i]>open[i]) return(high[i]);
         if(close[i]<open[i]) return(low[i]);
         return(close[i]);
     }
   return(0);
  }
//+------------------------------------------------------------------+
