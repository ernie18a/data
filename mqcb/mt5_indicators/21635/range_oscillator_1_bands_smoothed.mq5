//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Range oscillator with bands (smoothed version)"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Band up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Average range oscillator"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Band down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Range oscillator"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width4  2
//--- input parameters
input int     inpRngPeriod       = 40;  // Range oscillator period
input int     inpBandsPeriod     = 20;  // Bands period 
input double  inpBandsDeviations = 2.0; // Bands deviation
input int     inpSmtPeriod       = 14;  // Smoothing period
//--- buffers declarations
double val[],valc[],bandu[],bandm[],bandd[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,bandu,INDICATOR_DATA);
   SetIndexBuffer(1,bandm,INDICATOR_DATA);
   SetIndexBuffer(2,bandd,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Range oscillator + bands (smoothed)("+(string)inpRngPeriod+","+(string)inpBandsPeriod+","+(string)inpSmtPeriod+")");
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
      int    _start = MathMax(i-inpRngPeriod+1,0);
      double _max   = high[ArrayMaximum(high,_start,inpRngPeriod)];
      double _min   = low [ArrayMinimum(low ,_start,inpRngPeriod)];
      double _med   = (high[i]+low[i])/2;
      val[i]   = iSmooth((_max!=_min) ? 100*(_med-_min)/(_max-_min) : 0,inpSmtPeriod,0,i,rates_total,0);;
      bandm[i] = iSma(val[i],inpBandsPeriod,i,rates_total);
      double _dev=iDeviation(val[i],inpBandsPeriod,i,rates_total);
      bandu[i] = bandm[i]+inpBandsDeviations*_dev;
      bandd[i] = bandm[i]-inpBandsDeviations*_dev;
      valc[i]=(val[i]>bandu[i]) ? 1 :(val[i]<bandd[i]) ? 2 : 0;
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
//
//---
//  
double workSma[][1];
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
double workDev[];
//
//---
//
double iDeviation(double value,int length,int i,int bars,bool isSample=false)
  {
   if(ArraySize(workDev)!=bars) ArrayResize(workDev,bars);  workDev[i]=value;
   double sumx=0,sumxx=0; for(int k=0; k<length && (i-k)>=0; sumx+=workDev[i-k],sumxx+=workDev[i-k]*workDev[i-k],k++) {}
   return(MathSqrt((sumxx-sumx*sumx/length)/MathMax(length-isSample,1)));
  }
//+------------------------------------------------------------------+
