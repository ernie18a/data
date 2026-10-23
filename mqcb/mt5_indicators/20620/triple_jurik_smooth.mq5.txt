//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Smooth high"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Smooth close"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
#property indicator_label3  "Smooth low"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//--- input parameters
input double inpSmoothPeriod=27;  // Smooth period
input double inpSmoothPhase=0;    // Smooth phase
//--- indicator buffers
double valu[],valuc[],valc[],valcc[],vald[],valdc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,valuc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,valc,INDICATOR_DATA);
   SetIndexBuffer(3,valcc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,vald,INDICATOR_DATA);
   SetIndexBuffer(5,valdc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Triple Jurik smooth ("+(string)inpSmoothPeriod+")");
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
      valu[i] = iSmooth[0].CalculateValue(high[i] ,inpSmoothPeriod,inpSmoothPhase,i,rates_total);
      valc[i] = iSmooth[1].CalculateValue(close[i],inpSmoothPeriod,inpSmoothPhase,i,rates_total);
      vald[i] = iSmooth[2].CalculateValue(low[i]  ,inpSmoothPeriod,inpSmoothPhase,i,rates_total);
      valuc[i] = (i>0) ? (valu[i]>valu[i-1]) ? 2 : (valu[i]<valu[i-1]) ? 1 : valuc[i-1] : 0;
      valcc[i] = (i>0) ? (valc[i]>valc[i-1]) ? 2 : (valc[i]<valc[i-1]) ? 1 : valcc[i-1] : 0;
      valdc[i] = (i>0) ? (vald[i]>vald[i-1]) ? 2 : (vald[i]<vald[i-1]) ? 1 : valdc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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

      if (m_size!=bars) ArrayResize(m_wrk,bars); if (ArrayRange(m_wrk,0)!=bars) return(price); m_size=bars;
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
CJurikSmooth iSmooth[3];
//+------------------------------------------------------------------+
