//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Log sigmoidal normalized Jurik smooth"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Normalized Jurik smooth"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrCrimson
#property indicator_width1  2
//--- input parameters
input int                inpPeriod              = 20;          // Jurik smooth period
input double             inpPhase               = 0;           // Phase
input ENUM_APPLIED_PRICE inpPrice               = PRICE_CLOSE; // Price
input int                inpNormalizeLength     = 30;          // Normalization length
input bool               inpNormalizeHyperbolic = true;        // Hyperbolic normalization?
//--- buffers and global variables declarations
double val[],valc[],values[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,values,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Log sigmoidal normalized Jurik smooth ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      values[i] = iSmooth[0].CalculateValue(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpPhase,i,rates_total);
         
      //
      //---
      //
               
      double mean      = iSma(values[i],inpNormalizeLength,i,rates_total);
      double deviation = iDeviation(values[i],inpNormalizeLength,i,rates_total);
      double zeroMean  = 0;
         if (deviation != 0) zeroMean = (values[i]-mean)/deviation;
            val[i] = (inpNormalizeHyperbolic) ? (1.0-MathExp(-zeroMean))/(1.0+MathExp(-zeroMean)) : 1.0/(1.0+MathExp(-zeroMean));
            valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSma[][1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
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
//
//---
//
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
CJurikSmooth iSmooth[1];
 
//+------------------------------------------------------------------+
