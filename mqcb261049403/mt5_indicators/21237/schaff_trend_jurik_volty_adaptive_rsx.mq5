//------------------------------------------------------------------
#property copyright   "Copyright 2017, mladen"
#property link        "mladenfx@gmail.com"
#property description "Schaff trend Jurik volty adaptive RSX"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Schaff trend Jurik volty adaptive RSX value"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
//
//-----------------
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
// input parameters
input int       FastEma        = 23;       // Fast ema period
input int       SlowEma        = 50;       // Slow ema period
input double    RsiPeriod      = 9;        // Rsx period
input int       AdaptivePeriod = 50;       // Adaptive period
input enPrices  Price          = pr_close; // Price

double  val[],valc[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Schaff trend Jurik volty adaptive RSX ("+(string)FastEma+","+(string)SlowEma+","+(string)RsiPeriod+")");
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
      val[i]  = iRsi(iEma(price,FastEma,i,rates_total,0)-iEma(price,SlowEma,i,rates_total,1),RsiPeriod*iVoltyCoeff(price,AdaptivePeriod,i,rates_total),i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return(i);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _rsxInstances      1
#define _rsxInstancesSize 13
double workRsi[][_rsxInstances*_rsxInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars); int z=instanceNo*_rsxInstancesSize;
//
//---
//
   workRsi[r][z+_price]=price;
   double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
   if(r<period) { for(int k=1; k<13; k++) workRsi[r][k+z]=0; return(50); }
//
//---
//
   double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
   double moa = MathAbs(mom);
   for(int k=0; k<3; k++)
     {
      int kk=k*2;
      workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
      workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
      workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
      workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
  }
//
//---
//  
double wrk[][5];
#define bsmax  0
#define bsmin  1
#define voltya 2
#define vsum   3
#define avolty 4
#define avgLen 65
//
//---
//
double iVoltyCoeff(double price,double length,int r,int bars)
  {
   if(ArrayRange(wrk,0)!=bars) ArrayResize(wrk,bars);
   if(r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return(1); }

//
//---
//
   double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1 = MathMax(len1-2.0,0.5);
   double del1 = (r>0) ? price - wrk[r-1][bsmax] : 0;
   double del2 = (r>0) ? price - wrk[r-1][bsmin] : 0;

   wrk[r][voltya]=0;
   if(MathAbs(del1) > MathAbs(del2)) wrk[r][voltya] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) wrk[r][voltya] = MathAbs(del2);
   wrk[r][vsum]=(r>9) ? wrk[r-1][vsum]+0.1*(wrk[r][voltya]-wrk[r-10][voltya]) : wrk[r][voltya];

   double avg=wrk[r][vsum];  int k=1; for(; k<avgLen && (r-k)>=0; k++) avg+=wrk[r-k][vsum];
   avg/=k;
   wrk[r][avolty]=avg;
   double dVolty=(wrk[r][avolty]>0) ? wrk[r][voltya]/wrk[r][avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;

//
//---
//

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) wrk[r][bsmax] = price; else wrk[r][bsmax] = price - Kv*del1;
   if(del2 < 0) wrk[r][bsmin] = price; else wrk[r][bsmin] = price - Kv*del2;

//
//---
//
   double _temp=(wrk[r][vsum]!=0) ? wrk[r][avolty]/wrk[r][vsum]: 1;
   return(_temp);
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
      double haOpen  = (i>0) ? (workHa[i-1][instanceNo+2]+workHa[i-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
      double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

      if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; }
      else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  }
      workHa[i][instanceNo+2] = haOpen;
      workHa[i][instanceNo+3] = haClose;
      //
      //--------------------
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
