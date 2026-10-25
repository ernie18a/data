//+------------------------------------------------------------------+
//|                                                RegimeLabeler.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23491 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23491"
#property version   "1.00"
#property strict

//--- regime a window is assigned to.
enum ENUM_REGIME
  {
   REGIME_TREND,          // persistent directional drift
   REGIME_RANGE,          // mean-reverting oscillation
   REGIME_VOLATILE,       // large erratic moves, no clear direction
   REGIME_UNDEFINED       // not enough data / degenerate window
  };

//+------------------------------------------------------------------+
//| CRegimeLabeler - rule-based ground truth for training.           |
//|                                                                  |
//|  BOSS is a supervised classifier: it needs labelled example      |
//|  windows to learn from. Hand-labelling price history is          |
//|  impractical, so we derive labels mechanically from two classic  |
//|  statistics of the window's log returns:                         |
//|                                                                  |
//|    - lag-1 autocorrelation of returns. Positive autocorrelation  |
//|      means moves tend to continue (trending); near-zero or       |
//|      negative means they tend to reverse (ranging).              |
//|    - return volatility (standard deviation), compared against a  |
//|      rolling reference so "high" is relative to the instrument,  |
//|      not an absolute number.                                     |
//|                                                                  |
//|  Decision order matches the usual regime hierarchy: unusually    |
//|  high volatility dominates and marks the window VOLATILE; among  |
//|  the rest, strong positive autocorrelation marks TREND, and the  |
//|  remainder is RANGE.                                             |
//|                                                                  |
//|  This labeller is deliberately simple and transparent: it is the |
//|  benchmark's source of truth, not the thing under test. BOSS     |
//|  must learn to reproduce these labels from window SHAPE alone,   |
//|  and then hold up under noise where this statistic-based rule    |
//|  starts to wobble.                                               |
//+------------------------------------------------------------------+
class CRegimeLabeler
  {
private:
   double            m_vol_hi_mult;    // volatility above mult*reference -> volatile
   double            m_acf_trend;      // autocorrelation above this -> trend

   double            m_ref_vol;        // rolling reference volatility (set by caller)

   double            LogReturns(const double &price[],int len,double &ret[]) const;
   double            Autocorr1(const double &ret[],int n) const;
   double            StdDev(const double &ret[],int n) const;

public:
                     CRegimeLabeler(void);

   //--- thresholds. Defaults are reasonable starting points; the
   //--- volatility multiplier is relative to the reference vol.
   void              SetVolHighMult(double m) { if(m>0.0) m_vol_hi_mult=m; }
   void              SetTrendACF(double a)    { if(a>-1.0 && a<1.0) m_acf_trend=a; }

   //--- set the reference volatility that "high" is measured against.
   //--- Typically the median/mean window volatility over the sample.
   void              SetReferenceVol(double v) { m_ref_vol=(v>0.0)?v:0.0; }

   //--- label one price window (len closes, oldest first). Needs a
   //--- reference vol to have been set for the VOLATILE test to be
   //--- meaningful; with none set, volatility is judged against the
   //--- window's own returns only (absolute).
   ENUM_REGIME       Label(const double &price[],int len) const;

   //--- volatility (return stdev) of one price window, exposed so the
   //--- caller can build the reference distribution in a first pass.
   double            WindowVolatility(const double &price[],int len) const;

   //--- human-readable regime name.
   static string     RegimeName(ENUM_REGIME r);
  };

//+------------------------------------------------------------------+
//| Construct with default thresholds.                               |
//+------------------------------------------------------------------+
CRegimeLabeler::CRegimeLabeler(void)
  {
   m_vol_hi_mult=1.6;      // 1.6x the reference volatility reads as "volatile"
   m_acf_trend  =0.15;     // lag-1 ACF above 0.15 reads as "trending"
   m_ref_vol    =0.0;
  }

//+------------------------------------------------------------------+
//| Fill ret[0..len-2] with log returns of price[0..len-1].          |
//| Returns the number of returns produced.                          |
//+------------------------------------------------------------------+
double CRegimeLabeler::LogReturns(const double &price[],int len,double &ret[]) const
  {
   int k=0;
   ArrayResize(ret,MathMax(0,len-1));
   for(int i=1;i<len;i++)
     {
      if(price[i-1]>0.0 && price[i]>0.0)
         ret[k++]=MathLog(price[i]/price[i-1]);
     }
   ArrayResize(ret,k);
   return k;
  }

//+------------------------------------------------------------------+
//| Lag-1 autocorrelation of a return series.                        |
//|  corr = sum((r[i]-mean)(r[i-1]-mean)) / sum((r[i]-mean)^2).      |
//+------------------------------------------------------------------+
double CRegimeLabeler::Autocorr1(const double &ret[],int n) const
  {
   if(n<3)
      return 0.0;
   double mean=0.0;
   for(int i=0;i<n;i++)
      mean+=ret[i];
   mean/=n;

   double num=0.0, den=0.0;
   for(int i=0;i<n;i++)
     {
      double d=ret[i]-mean;
      den+=d*d;
      if(i>0)
         num+=d*(ret[i-1]-mean);
     }
   if(den<=0.0)
      return 0.0;
   return num/den;
  }

//+------------------------------------------------------------------+
//| Standard deviation of a return series (population).              |
//+------------------------------------------------------------------+
double CRegimeLabeler::StdDev(const double &ret[],int n) const
  {
   if(n<=0)
      return 0.0;
   double mean=0.0;
   for(int i=0;i<n;i++)
      mean+=ret[i];
   mean/=n;
   double var=0.0;
   for(int i=0;i<n;i++)
     {
      double d=ret[i]-mean;
      var+=d*d;
     }
   var/=n;
   return MathSqrt(var);
  }

//+------------------------------------------------------------------+
//| Volatility (return stdev) of one price window.                   |
//+------------------------------------------------------------------+
double CRegimeLabeler::WindowVolatility(const double &price[],int len) const
  {
   double ret[];
   int n=(int)LogReturns(price,len,ret);
   return StdDev(ret,n);
  }

//+------------------------------------------------------------------+
//| Label one price window as trend / range / volatile.              |
//+------------------------------------------------------------------+
ENUM_REGIME CRegimeLabeler::Label(const double &price[],int len) const
  {
   double ret[];
   int n=(int)LogReturns(price,len,ret);
   if(n<3)
      return REGIME_UNDEFINED;

   double vol=StdDev(ret,n);
   double acf=Autocorr1(ret,n);

//--- volatility first: an unusually wild window is VOLATILE whatever
//--- its autocorrelation says.
   double vol_ref=(m_ref_vol>0.0)?m_ref_vol:vol;
   if(vol>m_vol_hi_mult*vol_ref)
      return REGIME_VOLATILE;

//--- among calmer windows, strong persistence marks a trend.
   if(acf>m_acf_trend)
      return REGIME_TREND;

   return REGIME_RANGE;
  }

//+------------------------------------------------------------------+
//| Human-readable regime name.                                      |
//+------------------------------------------------------------------+
string CRegimeLabeler::RegimeName(ENUM_REGIME r)
  {
   switch(r)
     {
      case REGIME_TREND:
         return "trend";
      case REGIME_RANGE:
         return "range";
      case REGIME_VOLATILE:
         return "volatile";
      case REGIME_UNDEFINED:
         return "undefined";
     }
   return "unknown";
  }
//+------------------------------------------------------------------+
