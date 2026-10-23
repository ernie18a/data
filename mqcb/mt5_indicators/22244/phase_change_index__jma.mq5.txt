//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Phase change index - JMA smoothed"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Phase change trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Phase change index"
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
enum enSmoothType
{
   smt_pre,  // Smooth prices only
   smt_val,  // Smooth phase change index only
   smt_all   // Smooth both price and phase change index
};
input int                inpLength     = 30;           // Phase change index period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price
input double             inpSmooth     = 5;            // Smoothing period
input enSmoothType       inpSmoothType = smt_val;      // Smoothing type
input double             inpLevelHigh  = 80;           // Level high
input double             inpLevelLow   = 20;           // Level low
input enInverted         inpInverted   = inv_inverted; // Display type
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[],prices[],state[];
string _smtModes[] = {"price","value","price and value"};
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
   SetIndexBuffer(5,state,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpLevelHigh);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpLevelLow);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase change index "+_smtModes[inpSmoothType]+" smoothed ("+(string)inpLength+")");
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
   double _smoothP = (inpSmoothType==smt_val) ? 0 : inpSmooth;
   double _smoothV = (inpSmoothType==smt_pre) ? 0 : inpSmooth;
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i] = iSmooth(getPrice(inpPrice,open,close,high,low,i,rates_total),_smoothP,0,i,rates_total,0);
      //
      //---
      //
      double momentum = (i>=inpLength) ? prices[i]-prices[i-inpLength] : 0;
      double sumUpDi  = 0;
      double sumDnDi  = 0;
      for(int j=1; j<inpLength && (i-j)>=0 && (i-inpLength)>=0; j++)
      {
         double gradient  = prices[i-inpLength]+momentum*(inpLength-j)/(inpLength);
         double deviation = prices[i-j]-gradient;
            if (deviation > 0)
                  sumUpDi += deviation;
            else  sumDnDi -= deviation;
      }                    
      val[i]   = iSmooth(((sumUpDi+sumDnDi)!=0 ? 100.0*sumUpDi/(sumUpDi+sumDnDi) : 0),_smoothV,0,i,rates_total,1); if (inpInverted==inv_inverted) val[i] = 100-val[i];
      levdn[i] = 50;
      levup[i] = (val[i]>inpLevelHigh) ? 100: (val[i]<inpLevelLow) ? 0 : 50;
      valc[i]  = (val[i]>inpLevelHigh) ? 2 : (val[i]<inpLevelLow) ? 1 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smoothInstances     2
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
