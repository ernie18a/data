//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend direction and force - JMA smoothed"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "No trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Trend direction and force"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int       trendPeriod  = 20;      // Trend period
input int       smoothPeriod = 3;       // Smoothing period
input double    TriggerUp    =  0.05;   // Trigger up level
input double    TriggerDown  = -0.05;   // Trigger down level
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend direction and force JMA smoothed ("+(string)trendPeriod+","+(string)smoothPeriod+")");
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
double workTrend[][3];
#define _MMA   0
#define _SMMA  1
#define _TDF   2
//
//---
//
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
   if(ArrayRange(workTrend,0)!=rates_total) ArrayResize(workTrend,rates_total);
   double _alpha=2.0/(1+trendPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         workTrend[i][_MMA]  = (i>0) ? workTrend[i-1][_MMA]+_alpha*(close[i]-workTrend[i-1][_MMA]) : close[i];
         workTrend[i][_SMMA] = (i>0) ? workTrend[i-1][_SMMA]+_alpha*(workTrend[i][_MMA]-workTrend[i-1][_SMMA]) : workTrend[i][_MMA];
            double impetmma  = (i>0) ? workTrend[i][_MMA]  - workTrend[i-1][_MMA]  : 0;
            double impetsmma = (i>0) ? workTrend[i][_SMMA] - workTrend[i-1][_SMMA] : 0;
            double divma     = MathAbs(workTrend[i][_MMA]-workTrend[i][_SMMA])/_Point;
            double averimpet = (impetmma+impetsmma)/(2*_Point);
         workTrend[i][_TDF]  = divma*MathPow(averimpet,3);

         //
         //---
         //
               
         double absValue = 0;  for (int k=0; k<trendPeriod*3 && (i-k)>=0; k++)  absValue = MathMax(absValue,MathAbs(workTrend[i-k][_TDF]));
         val[i] = iSmooth((absValue > 0) ? workTrend[i][_TDF]/absValue : 0,smoothPeriod,0,i,rates_total);
         levup[i] = TriggerUp;
         levdn[i] = TriggerDown;
         valc[i]  = (val[i] > levup[i]) ? 2 : (val[i] < levdn[i]) ? 1 : 0;
     }
   return (i);
  }
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
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

   return(m_wrk[r][instanceNo+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
  }    
//+------------------------------------------------------------------+
