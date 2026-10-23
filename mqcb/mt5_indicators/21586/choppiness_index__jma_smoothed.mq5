//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Choppiness index - JMA smoothed"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Choppiness index"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//
//---
//
input int    inpChoPeriod    = 14;  // Choppiness index period
input int    inpSmoothPeriod = 14;  // Smooth period
input double inpSmoothPhase  = 0;   // Smooth phase

double csi[],csic[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,csi,INDICATOR_DATA); 
   SetIndexBuffer(1,csic,INDICATOR_COLOR_INDEX); 
   IndicatorSetString(INDICATOR_SHORTNAME,"Jma smoothed Choppiness index ("+string(inpChoPeriod)+","+string(inpSmoothPeriod)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   double _log = MathLog(inpChoPeriod)/100.00;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double atrSum =    0.00;
      double maxHig = high[i];
      double minLow =  low[i];
               
         for (int k = 0; k<inpChoPeriod && (i-k-1)>=0; k++)
         {
            atrSum += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]);
            maxHig  = MathMax(maxHig,MathMax(high[i-k],close[i-k-1]));
            minLow  = MathMin(minLow,MathMin( low[i-k],close[i-k-1]));
         }
         double _val = (maxHig!=minLow) ? atrSum/(maxHig-minLow) : 0;
         double _csi = (_val!=0) ? MathLog(_val)/_log : 0;
         csi[i] = iSmooth(_csi,inpSmoothPeriod,inpSmoothPhase,i,rates_total,0);   
         csic[i] = (i>0) ? (csi[i]>csi[i-1]) ? 0 : (csi[i]<csi[i-1]) ? 1 : csic[i-1] : 0;
   }      
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smoothInstances     1
#define _smoothInstancesSize 10
double m_wrk[][_smoothInstances*_smoothInstancesSize];
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
   if(r==0 || length<=1) 
      { int k=0; 
         for(;  k<7; k++) m_wrk[r][instanceNo+k]=price; 
         for(; k<10; k++) m_wrk[r][instanceNo+k]=0; 
         return(price); 
      }
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
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) m_wrk[r][instanceNo+bsmax] = price; else m_wrk[r][instanceNo+bsmax] = price - Kv*del1;
   if(del2 < 0) m_wrk[r][instanceNo+bsmin] = price; else m_wrk[r][instanceNo+bsmin] = price - Kv*del2;

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

   if (r==bars-1)
   {
   }    
   return(m_wrk[r][instanceNo+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
  }  