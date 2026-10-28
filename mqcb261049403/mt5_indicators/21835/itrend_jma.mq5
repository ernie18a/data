//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "iTrendd JMA"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5
#property indicator_label1  "iTrend up"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrLimeGreen
#property indicator_label2  "iTrend down"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrDeepPink,clrDeepPink
#property indicator_label3  "iTrend line up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  2
#property indicator_label4  "iTrend line down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_width4  2
#property indicator_label5  "iTrend"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrDarkGray,clrLime,clrHotPink
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

input int                ItPeriod          = 20;             // iTrend period
input ENUM_APPLIED_PRICE ItPrice           = PRICE_CLOSE;    // Price
input int                LevelBars         = 300;            // Look back period for levels
input double             LevelFactor       = 0.283;          // Levels factor

double itrend[],itrendc[],lup[],ldn[],fillu[],filluz[],filld[],filldz[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filluz,INDICATOR_DATA);
   SetIndexBuffer(2,filld,INDICATOR_DATA);
   SetIndexBuffer(3,filldz,INDICATOR_DATA);
   SetIndexBuffer(4,lup,INDICATOR_DATA);
   SetIndexBuffer(5,ldn,INDICATOR_DATA);
   SetIndexBuffer(6,itrend,INDICATOR_DATA);
   SetIndexBuffer(7,itrendc,INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"iTrend JMA ("+(string)ItPeriod+")");
   return(0);
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double ma = getPrice(ItPrice,open,close,high,low,i,rates_total);
      double mv = iSmooth(ma,ItPeriod,0,i,rates_total,0);
      fillu[i] = (ma - mv);                lup[i] = fillu[i]; filluz[i] = 0;
      filld[i] = (-(low[i]+high[i]-2*mv)); ldn[i] = filld[i]; filldz[i] = 0;

      double hi=MathMax(fillu[i],filld[i]);
      for(int k=1; k<LevelBars && (i-k)>=0; k++) hi=MathMax(hi,MathMax(fillu[i-k],filld[i-k]));
      itrend[i]  = hi*LevelFactor;
      itrendc[i] = (fillu[i]>itrend[i]) ? 1 : (filld[i]>itrend[i]) ? 2 : (i>0) ? itrendc[i-1] : 0;
     }
   return(rates_total);
  }

#define _smoothInstances     1
#define _smoothInstancesSize 10
double m_wrk[][_smoothInstances*_smoothInstancesSize];
int    m_size=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmooth(double price,double length,double phase,int r,int bars,int instanceNo=0)
  {
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

   if(ArrayRange(m_wrk,0)!=bars) ArrayResize(m_wrk,bars); if(ArrayRange(m_wrk,0)!=bars) return(price); instanceNo*=_smoothInstancesSize;
   if(r==0 || length<=1) { int k=0; for(; k<7; k++) m_wrk[r][instanceNo+k]=price; for(; k<10; k++) m_wrk[r][instanceNo+k]=0; return(price); }

   double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1   = MathMax(len1-2.0,0.5);
   double del1   = price - m_wrk[r-1][instanceNo+bsmax];
   double del2   = price - m_wrk[r-1][instanceNo+bsmin];
   int    forBar = MathMin(r,10);

   m_wrk[r][instanceNo+volty]=0;
   if(MathAbs(del1) > MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del2);
   m_wrk[r][instanceNo+vsum]=m_wrk[r-1][instanceNo+vsum]+(m_wrk[r][instanceNo+volty]-m_wrk[r-forBar][instanceNo+volty])*0.1;

   m_wrk[r][instanceNo+avolty]=m_wrk[r-1][instanceNo+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(m_wrk[r][instanceNo+vsum]-m_wrk[r-1][instanceNo+avolty]);
   double dVolty=(m_wrk[r][instanceNo+avolty]>0) ? m_wrk[r][instanceNo+volty]/m_wrk[r][instanceNo+avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;


   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) m_wrk[r][instanceNo+bsmax] = price; else m_wrk[r][instanceNo+bsmax] = price - Kv*del1;
   if(del2 < 0) m_wrk[r][instanceNo+bsmin] = price; else m_wrk[r][instanceNo+bsmin] = price - Kv*del2;


   double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
   double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
   double alpha = MathPow(beta,pow2);

   m_wrk[r][instanceNo+0] = price + alpha*(m_wrk[r-1][instanceNo+0]-price);
   m_wrk[r][instanceNo+1] = (price - m_wrk[r][instanceNo+0])*(1-beta) + beta*m_wrk[r-1][instanceNo+1];
   m_wrk[r][instanceNo+2] = (m_wrk[r][instanceNo+0] + corr*m_wrk[r][instanceNo+1]);
   m_wrk[r][instanceNo+3] = (m_wrk[r][instanceNo+2] - m_wrk[r-1][instanceNo+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*m_wrk[r-1][instanceNo+3];
   m_wrk[r][instanceNo+4] = (m_wrk[r-1][instanceNo+4] + m_wrk[r][instanceNo+3]);


   return(m_wrk[r][instanceNo+4]);

#undef bsmax
#undef bsmin
#undef volty
#undef vsum
#undef avolty
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
