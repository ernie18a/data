//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "ADXm smoothed"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "DI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "ADXm"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width2  2
//--- input parameters
input int    inpAdxmPeriod      = 14; // ADXm period
input int    inpAdxmSmooth      =  5; // Smoothing period
input double inpAdxmSmoothPhase =  0; // Smoothing phase
//--- buffers declarations
double adxm[],adxmc[],di[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,di,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,adxm,INDICATOR_DATA);
   SetIndexBuffer(2,adxmc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"ADXm smoothed ("+(string)inpAdxmPeriod+","+(string)inpAdxmSmooth+")");
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
      double _di;
      adxm[i]  = iSmooth(iAdxm(close[i],high[i],low[i],inpAdxmPeriod,_di,i,rates_total),inpAdxmSmooth,inpAdxmSmoothPhase,i,rates_total);
      di[i]    = _di;
      adxmc[i] = (i>0) ?(adxm[i]>adxm[i-1]) ? 1 :(adxm[i]<adxm[i-1]) ? 2 : adxmc[i-1]: 0;
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _adxmInstances     1
#define _adxmInstancesSize 8
double  _adxmWork[][_adxmInstances*_adxmInstancesSize];
#define _adxmSdh   0
#define _adxmSdl   1
#define _adxmSdx   2
#define _adxmClose 3
#define _adxmHigh  4
#define _adxmLow   5
#define _adxmDi    6
#define _adxmAdx   7
//
//---
//
double iAdxm(double _close,double _high,double _low,double _period,double &_di,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(_adxmWork,0)!=bars) ArrayResize(_adxmWork,bars); instanceNo*=_adxmInstancesSize; #ifdef __MQL4__ i=bars-i-1; #endif

   _adxmWork[i][instanceNo+_adxmClose]=_close;
   _adxmWork[i][instanceNo+_adxmHigh] =_high;
   _adxmWork[i][instanceNo+_adxmLow]  =_low;

//
//---
//

   double hc = _adxmWork[i][instanceNo+_adxmHigh];
   double lc = _adxmWork[i][instanceNo+_adxmLow ];
   double cp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmClose] : _adxmWork[i][instanceNo+_adxmClose];
   double hp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmHigh ] : _adxmWork[i][instanceNo+_adxmHigh ];
   double lp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmLow  ] : _adxmWork[i][instanceNo+_adxmLow  ];
   double dh = MathMax(hc-hp,0);
   double dl = MathMax(lp-lc,0);

   if(dh==dl) {dh=0; dl=0;} else if(dh<dl) dh=0; else if(dl<dh) dl=0;

   double tr    = MathMax(hc,cp)-MathMin(lc,cp);
   double dhk   = (tr!=0) ? 100.0*dh/tr : 0;
   double dlk   = (tr!=0) ? 100.0*dl/tr : 0;
   double alpha = 2.0/(_period+1.0);

   _adxmWork[i][instanceNo+_adxmSdh] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdh] + alpha*(dhk-_adxmWork[i-1][instanceNo+_adxmSdh]) : dhk;
   _adxmWork[i][instanceNo+_adxmSdl] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdl] + alpha*(dlk-_adxmWork[i-1][instanceNo+_adxmSdl]) : dlk;
   _adxmWork[i][instanceNo+_adxmDi]  = _adxmWork[i][instanceNo+_adxmSdh] - _adxmWork[i][instanceNo+_adxmSdl];

   double div  = MathAbs(_adxmWork[i][instanceNo+_adxmSdh] + _adxmWork[i][instanceNo+_adxmSdl]);
   double temp = (div!=0.0) ? 100*_adxmWork[i][instanceNo+_adxmDi]/div : 0;

   _adxmWork[i][instanceNo+_adxmAdx]=(i>0) ? _adxmWork[i-1][instanceNo+_adxmAdx]+alpha*(temp-_adxmWork[i-1][instanceNo+_adxmAdx]) : 0;
   _di=_adxmWork[i][instanceNo+_adxmDi];
   return(_adxmWork[i][instanceNo+_adxmAdx]);
  }
//
//---
//
double m_wrk[][10];
int    m_size=0;
//
//---
//
double iSmooth(double price,double length,double phase,int r,int bars)
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
//+------------------------------------------------------------------+
