//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Trend continuation factor (Jurik smoothed)"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Trend continuation factor zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrPowderBlue,clrAntiqueWhite
#property indicator_label2  "Trend continuation factor"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
enum enInverted
  {
   inv_regular, // Display regular value
   inv_inverted // Display inverted value
  };
input int                inpLength      = 30;           // Trend continuation factor period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;  // Price
input double             inpSmooth      = 5;            // Smoothing period
input double             inpSmoothPhase = 0;            // Smoothing phase

//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[],prices[];
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
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend continuation factor (Jurik smoothed)("+(string)inpLength+","+(string)inpSmooth+")");
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
double values[][4];
#define plus_ch  0
#define minus_ch 1
#define plus_cf  2
#define minus_cf 3
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
   if(ArrayRange(values,0)!=rates_total) ArrayResize(values,rates_total);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double roc=(i>0) ? prices[i]-prices[i-1]: 0;
      values[i][plus_ch]  = 0;
      values[i][minus_ch] = 0;
      values[i][plus_cf]  = 0;
      values[i][minus_cf] = 0;
      if(roc>0)
        {
         values[i][plus_ch] = roc;
         values[i][plus_cf] = (i>0) ? values[i][plus_ch]+values[i-1][plus_cf] : values[i][plus_ch];
        }
      if(roc<0)
        {
         values[i][minus_ch] = -roc;
         values[i][minus_cf] = (i>0) ? values[i][minus_ch]+values[i-1][minus_cf] : values[i][minus_ch];
        }
      double levUp = 0;
      double levDn = 0;
      for(int l=0; l<inpLength && (i-l)>=0; l++)
        {
         levUp += values[i-l][plus_ch]-values[i-l][minus_cf];
         levDn += values[i-l][minus_ch]-values[i-l][plus_cf];
        }
      levup[i] = iSmooth[0].CalculateValue(levUp,inpSmooth,inpSmoothPhase,i,rates_total);
      levdn[i] = iSmooth[1].CalculateValue(levDn,inpSmooth,inpSmoothPhase,i,rates_total);
      //
      //---
      //
      val[i]   =  levup[i];
      valc[i]  = (levup[i]>levdn[i]) ? 2 : (levup[i]<levdn[i]) ? 1 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
//| Custom clases                                                    |
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
CJurikSmooth iSmooth[2];
//+------------------------------------------------------------------+
  
//+------------------------------------------------------------------+

