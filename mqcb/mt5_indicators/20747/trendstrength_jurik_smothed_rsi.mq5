//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TrendStrength Jurik smoothed (rsi)"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "rsi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "trend up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "trend down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2
//--- input parameters
input double             inpPeriod      = 32;          // Period
input double             inpStrength    = 4.236;       // Strength
input double             inpSmooth      = 32;          // Smoothing period
input double             inpSmoothPhase = 0;           // Smoothing hase
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price

//--- indicator buffers
double rsi[],valu[],vald[],smin[],smax[],trend[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rsi,INDICATOR_DATA);
   SetIndexBuffer(1,valu,INDICATOR_DATA);
   SetIndexBuffer(2,vald,INDICATOR_DATA);
   SetIndexBuffer(3,smin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,smax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,trend,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendStrength (Jurik smoothed rsi) ("+(string)inpPeriod+","+(string)inpStrength+","+(string)inpSmooth+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      rsi[i]   = iSmooth[0].CalculateValue(iRsi(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total),inpSmooth,inpSmoothPhase,i,rates_total);
      valu[i]  = EMPTY_VALUE;
      vald[i]  = EMPTY_VALUE;
      trend[i] = 0;
      if(i>0)
        {
         double hrsi = rsi[i];
         double lrsi = rsi[i];
         if(rsi[i] > rsi[i-1]) { hrsi = rsi[i];   lrsi = rsi[i-1]; }
         if(rsi[i] < rsi[i-1]) { hrsi = rsi[i-1]; lrsi = rsi[i];   }

         double delta=hrsi-lrsi;
         smin[i]   = rsi[i] - inpStrength*delta;
         smax[i]   = rsi[i] + inpStrength*delta;
         trend[i]  = trend[i-1];
         if(rsi[i]>smax[i-1]) trend[i]= 1;
         if(rsi[i]<smin[i-1]) trend[i]=-1;
         if(trend[i]>0) { if(smin[i]<smin[i-1]) smin[i]=smin[i-1]; valu[i]=smin[i]; }
         if(trend[i]<0) { if(smax[i]>smax[i-1]) smax[i]=smax[i-1]; vald[i]=smax[i]; }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 1
#define rsiInstancesSize 3
double workRsi[][rsiInstances*rsiInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*rsiInstancesSize;

//
//---
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
//+------------------------------------------------------------------+
//| Custom classes                                                   |
//+------------------------------------------------------------------+
class CJurikSmooth
  {
private:
   int               m_size;
   double            m_wrk[][10];

   //
   //---
   //

public :

                     CJurikSmooth(void) : m_size(0) { return; }
                    ~CJurikSmooth(void)             { return; }

   double CalculateValue(double price,double length,double phase,int r,int bars)
     {
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

      if(m_size!=bars) ArrayResize(m_wrk,bars); if(ArrayRange(m_wrk,0)!=bars) return(price); m_size=bars;
      if(r==0 || length<=1) { int k=0; for(; k<7; k++) m_wrk[r][k]=price; for(; k<10; k++) m_wrk[r][k]=0; return(price); }

      //
      //---
      //

      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - m_wrk[r-1][bsmax];
      double del2   = price - m_wrk[r-1][bsmin];
      int    forBar = MathMin(r,10);

      m_wrk[r][volty]=0;
      if(MathAbs(del1) > MathAbs(del2)) m_wrk[r][volty] = MathAbs(del1);
      if(MathAbs(del1) < MathAbs(del2)) m_wrk[r][volty] = MathAbs(del2);
      m_wrk[r][vsum]=m_wrk[r-1][vsum]+(m_wrk[r][volty]-m_wrk[r-forBar][volty])*0.1;

      //
      //---
      //

      m_wrk[r][avolty]=m_wrk[r-1][avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(m_wrk[r][vsum]-m_wrk[r-1][avolty]);
      double dVolty=(m_wrk[r][avolty]>0) ? m_wrk[r][volty]/m_wrk[r][avolty]: 0;
      if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
      if(dVolty < 1)                      dVolty = 1.0;

      //
      //---
      //

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

      if(del1 > 0) m_wrk[r][bsmax] = price; else m_wrk[r][bsmax] = price - Kv*del1;
      if(del2 < 0) m_wrk[r][bsmin] = price; else m_wrk[r][bsmin] = price - Kv*del2;

      //
      //---
      //

      double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

      m_wrk[r][0] = price + alpha*(m_wrk[r-1][0]-price);
      m_wrk[r][1] = (price - m_wrk[r][0])*(1-beta) + beta*m_wrk[r-1][1];
      m_wrk[r][2] = (m_wrk[r][0] + corr*m_wrk[r][1]);
      m_wrk[r][3] = (m_wrk[r][2] - m_wrk[r-1][4])*MathPow((1-alpha),2) + MathPow(alpha,2)*m_wrk[r-1][3];
      m_wrk[r][4] = (m_wrk[r-1][4] + m_wrk[r][3]);

      //
      //---
      //

      return(m_wrk[r][4]);

#undef bsmax
#undef bsmin
#undef volty
#undef vsum
#undef avolty
     }
  };
CJurikSmooth iSmooth[2];

//+------------------------------------------------------------------+
