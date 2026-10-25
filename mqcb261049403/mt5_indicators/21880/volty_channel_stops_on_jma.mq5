//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Volty channel stops on JMA"
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
input int                AtrPeriod = 10;          // ATR period
input double             Kv        = 4;           // ATR multiplier
input int                MaPeriod  = 10;          // Smoothing period
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
      double ma    = iSmooth(price,MaPeriod,0,i,rates_total,0);
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
//
//---
//
#define _smoothInstances     1
#define _smoothInstancesSize 10
double m_wrk[][_smoothInstances*_smoothInstancesSize];
int    m_size=0;
//
//---
//
double iSmooth(double price,double length,double phase,int r,int bars,int instanceNo=0)
  {
   #define bsmax  5
   #define bsmin  6
   #define volty  7
   #define vsum   8
   #define avolty 9

   if(ArrayRange(m_wrk,0)!=bars) ArrayResize(m_wrk,bars); if(ArrayRange(m_wrk,0)!=bars) return(price); instanceNo*=_smoothInstancesSize;
   if(r==0 || length<=1) { int k=0; for(; k<7; k++) m_wrk[r][instanceNo+k]=price; for(; k<10; k++) m_wrk[r][instanceNo+k]=0; return(price); }

//
//---
//

   double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1   = MathMax(len1-2.0,0.5);
   double del1   = price - m_wrk[r-1][instanceNo+bsmax];
   double del2   = price - m_wrk[r-1][instanceNo+bsmin];
   int    forBar = MathMin(r,10);

   m_wrk[r][instanceNo+volty]=0;
   if(MathAbs(del1) > MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del2);
   m_wrk[r][instanceNo+vsum]=m_wrk[r-1][instanceNo+vsum]+(m_wrk[r][instanceNo+volty]-m_wrk[r-forBar][instanceNo+volty])*0.1;

//
//---
//

   m_wrk[r][instanceNo+avolty]=m_wrk[r-1][instanceNo+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(m_wrk[r][instanceNo+vsum]-m_wrk[r-1][instanceNo+avolty]);
   double dVolty=(m_wrk[r][instanceNo+avolty]>0) ? m_wrk[r][instanceNo+volty]/m_wrk[r][instanceNo+avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;

//
//---
//

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double tKv  = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) m_wrk[r][instanceNo+bsmax] = price; else m_wrk[r][instanceNo+bsmax] = price - tKv*del1;
   if(del2 < 0) m_wrk[r][instanceNo+bsmin] = price; else m_wrk[r][instanceNo+bsmin] = price - tKv*del2;

//
//---
//

   double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
   double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
   double alpha = MathPow(beta,pow2);

   m_wrk[r][instanceNo+0] = price + alpha*(m_wrk[r-1][instanceNo+0]-price);
   m_wrk[r][instanceNo+1] = (price - m_wrk[r][instanceNo+0])*(1-beta) + beta*m_wrk[r-1][instanceNo+1];
   m_wrk[r][instanceNo+2] = (m_wrk[r][instanceNo+0] + corr*m_wrk[r][instanceNo+1]);
   m_wrk[r][instanceNo+3] = (m_wrk[r][instanceNo+2] - m_wrk[r-1][instanceNo+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*m_wrk[r-1][instanceNo+3];
   m_wrk[r][instanceNo+4] = (m_wrk[r-1][instanceNo+4] + m_wrk[r][instanceNo+3]);

//
//---
//

   return(m_wrk[r][instanceNo+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
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
