//+------------------------------------------------------------------+
//|                                               RegimeDetector.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| CRegimeDetector - is the window's spread opening or closing?     |
//|                                                                  |
//|  The core reduces each window to a single range: the distance    |
//|  between the largest and smallest normalised return in it. That  |
//|  number alone says little, because "wide" only means anything    |
//|  against what the instrument has been doing lately. So four      |
//|  readings are taken of it and combined:                          |
//|                                                                  |
//|    - ratios against the rolling min and max range, which place   |
//|      the current spread within its recent envelope.              |
//|    - a z-score, which asks the same question in units of the     |
//|      range's own variability rather than its extremes.           |
//|    - a variation ratio (stdev/mean over the lookback), which is  |
//|      low when the range is not merely small but *steady*.        |
//|    - the slope of a least-squares line through the lookback,     |
//|      giving the direction the spread is travelling.              |
//|                                                                  |
//|  Contraction demands agreement: the envelope test AND either a   |
//|  steady or a flat reading. Expansion is looser, since a range    |
//|  breaking out tends to announce itself on any one measure.       |
//|                                                                  |
//|  The classification is path-dependent. Inside the transition     |
//|  zone with neither slope nor z-score committing, the previous    |
//|  bar's regime carries forward, and an unknown regime resolves    |
//|  to expansion once. That is why the class keeps a value per bar  |
//|  rather than one running field: an indicator recomputing from    |
//|  prev_calculated-1 has to be able to pick the chain back up      |
//|  from the bar before, and a single field would have lost it.     |
//+------------------------------------------------------------------+
class CRegimeDetector
  {
private:
   int               m_window;         // W, so the first usable bar matches the core
   int               m_lookback;       // bars for slope / variation ratio
   int               m_hist_lookback;  // bars for the min/max envelope, 0 = unlimited
   double            m_eps_low;        // R_max below this reads as contraction
   double            m_eps_high;       // R_min above this reads as expansion
   double            m_slope_thresh;
   double            m_var_ratio_low;
   double            m_z_expansion;

   int               m_size;
   ENUM_RMA_REGIME   m_regime[];
//--- prefix accumulators, filled only when the envelope is unlimited.
//--- They hold the state as of bar i rather than a running total, so
//--- recomputing a bar overwrites its slot instead of adding to it.
   double            m_env_min[];
   double            m_env_max[];
   double            m_sum[];
   double            m_sum_sq[];
   int               m_count[];
//--- envelope as of the last bar computed, kept for the caller's HUD
   double            m_min_history;
   double            m_max_history;

   bool              Allocate(const int total);
   void              Accumulate(const double &range[],const int i);
   void              Envelope(const double &range[],const int i,double &lo,double &hi) const;
   double            ZScore(const double &range[],const int i) const;
   double            VariationRatio(const double &range[],const int i) const;
   double            Slope(const double &range[],const int i) const;
   ENUM_RMA_REGIME   Classify(const double r_min_ratio,const double r_max_ratio,
                              const double slope,const double z,const double var_ratio,
                              const ENUM_RMA_REGIME prev) const;

public:
                     CRegimeDetector(void);

   bool              Init(const int window,const int lookback,const int hist_lookback,
                          const double eps_low,const double eps_high,
                          const double slope_thresh,const double var_ratio_low,
                          const double z_expansion);

//--- classify bars [from, total) from the core's range series.
   bool              Calculate(const double &range[],const int total,const int from);

//--- first bar that can carry a regime.
   int               FirstBar(void) const { return m_window+m_lookback; }

   ENUM_RMA_REGIME   Regime(const int i) const { return m_regime[i]; }
   double            MinHistory(void)    const { return m_min_history; }
   double            MaxHistory(void)    const { return m_max_history; }
  };

//+------------------------------------------------------------------+
//| Construct in an unusable state until Init is called.             |
//+------------------------------------------------------------------+
CRegimeDetector::CRegimeDetector(void)
  {
   m_window        =0;
   m_lookback      =0;
   m_hist_lookback =0;
   m_eps_low       =0.0;
   m_eps_high      =0.0;
   m_slope_thresh  =0.0;
   m_var_ratio_low =0.0;
   m_z_expansion   =0.0;
   m_size          =0;
   m_min_history   =DBL_MAX;
   m_max_history   =0.0;
  }

//+------------------------------------------------------------------+
//| Store thresholds and geometry.                                   |
//|  There is no z-score contraction threshold here on purpose. The  |
//|  original computed one and then never referenced it in the       |
//|  cascade, so carrying it forward would only advertise an input   |
//|  that changes nothing.                                           |
//+------------------------------------------------------------------+
bool CRegimeDetector::Init(const int window,const int lookback,const int hist_lookback,
                           const double eps_low,const double eps_high,
                           const double slope_thresh,const double var_ratio_low,
                           const double z_expansion)
  {
   if(window<2 || lookback<2)
     {
      PrintFormat("CRegimeDetector: bad geometry W=%d lookback=%d",window,lookback);
      return false;
     }
   m_window        =window;
   m_lookback      =lookback;
   m_hist_lookback =(hist_lookback<0)?0:hist_lookback;
   m_eps_low       =eps_low;
   m_eps_high      =eps_high;
   m_slope_thresh  =slope_thresh;
   m_var_ratio_low =var_ratio_low;
   m_z_expansion   =z_expansion;
   m_min_history   =DBL_MAX;
   m_max_history   =0.0;
   return true;
  }

//+------------------------------------------------------------------+
//| Grow the regime series, marking new bars unknown.                |
//+------------------------------------------------------------------+
bool CRegimeDetector::Allocate(const int total)
  {
   if(total<=m_size)
      return true;
   if(ArrayResize(m_regime,total,1024)<0)
      return false;
   for(int i=m_size;i<total;i++)
      m_regime[i]=RMA_REGIME_UNKNOWN;

   if(m_hist_lookback==0)
     {
      if(ArrayResize(m_env_min,total,1024)<0 ||
         ArrayResize(m_env_max,total,1024)<0 ||
         ArrayResize(m_sum,total,1024)<0 ||
         ArrayResize(m_sum_sq,total,1024)<0 ||
         ArrayResize(m_count,total,1024)<0)
         return false;
     }

   m_size=total;
   return true;
  }

//+------------------------------------------------------------------+
//| Fold bar i into the unlimited-envelope prefix arrays.            |
//|  Each slot is written as "the bar before, plus this bar", which  |
//|  is what makes a partial recompute land on the same numbers a    |
//|  full pass would. A running accumulator could not: replaying a   |
//|  bar would count it twice, and the forming bar gets replayed on  |
//|  every tick.                                                     |
//+------------------------------------------------------------------+
void CRegimeDetector::Accumulate(const double &range[],const int i)
  {
   int    first=FirstBar();
   double v=range[i];

   double prev_min=(i>first)?m_env_min[i-1]:DBL_MAX;
   double prev_max=(i>first)?m_env_max[i-1]:0.0;
   double prev_sum=(i>first)?m_sum[i-1]:0.0;
   double prev_sq =(i>first)?m_sum_sq[i-1]:0.0;
   int    prev_n  =(i>first)?m_count[i-1]:0;

   if(v>0.0 && v<prev_min)
      prev_min=v;
   if(v>prev_max)
      prev_max=v;
   if(v>0.0)
     {
      prev_sum+=v;
      prev_sq +=v*v;
      prev_n++;
     }

   m_env_min[i]=prev_min;
   m_env_max[i]=prev_max;
   m_sum[i]    =prev_sum;
   m_sum_sq[i] =prev_sq;
   m_count[i]  =prev_n;
  }

//+------------------------------------------------------------------+
//| Smallest and largest range seen inside the envelope window.      |
//|  Only strictly positive ranges count towards the minimum: a      |
//|  zero range means an unwritten or degenerate bar, and letting    |
//|  it win would peg the ratio at infinity.                         |
//+------------------------------------------------------------------+
void CRegimeDetector::Envelope(const double &range[],const int i,double &lo,double &hi) const
  {
   if(m_hist_lookback==0)
     {
      lo=m_env_min[i];
      hi=m_env_max[i];
      return;
     }

   int first=FirstBar();
   int start=i-m_hist_lookback+1;
   if(start<first)
      start=first;

   lo=DBL_MAX;
   hi=0.0;
   for(int k=start;k<=i;k++)
     {
      if(range[k]<lo && range[k]>0.0)
         lo=range[k];
      if(range[k]>hi)
         hi=range[k];
     }
  }

//+------------------------------------------------------------------+
//| Current range in standard deviations of its recent history.      |
//+------------------------------------------------------------------+
double CRegimeDetector::ZScore(const double &range[],const int i) const
  {
   int    first=FirstBar();
   int    start=first;
   double sum=0.0,sum_sq=0.0;
   int    count=0;

   if(m_hist_lookback==0)
     {
      sum   =m_sum[i];
      sum_sq=m_sum_sq[i];
      count =m_count[i];
     }
   else
     {
      start=i-m_hist_lookback+1;
      if(start<first)
         start=first;

      for(int k=start;k<=i;k++)
        {
         if(range[k]>0.0)
           {
            sum+=range[k];
            sum_sq+=range[k]*range[k];
            count++;
           }
        }
     }

   if(i-start<2 || count<2)
      return 0.0;

   double mean=sum/count;
   double variance=(sum_sq/count)-(mean*mean);
   if(variance<=0.0)
      return 0.0;

   return (range[i]-mean)/MathSqrt(variance);
  }

//+------------------------------------------------------------------+
//| Coefficient of variation of the range over the lookback.         |
//|  Low means the spread is not just narrow but holding still,      |
//|  which is what separates a genuine contraction from a quiet      |
//|  patch inside an otherwise lively stretch.                       |
//+------------------------------------------------------------------+
double CRegimeDetector::VariationRatio(const double &range[],const int i) const
  {
   if(i<m_lookback)
      return 1.0;

   double sum=0.0,sum_sq=0.0;
   for(int j=0;j<m_lookback;j++)
     {
      int idx=i-m_lookback+1+j;
      sum+=range[idx];
      sum_sq+=range[idx]*range[idx];
     }

   double mean=sum/m_lookback;
   if(mean<1e-10)
      return 0.0;

   double variance=(sum_sq/m_lookback)-(mean*mean);
   if(variance<=0.0)
      return 0.0;

   return MathSqrt(variance)/mean;
  }

//+------------------------------------------------------------------+
//| Least-squares slope of the range over the lookback.              |
//+------------------------------------------------------------------+
double CRegimeDetector::Slope(const double &range[],const int i) const
  {
   if(i<m_lookback)
      return 0.0;

   double sum_x=0.0,sum_y=0.0,sum_xy=0.0,sum_xx=0.0;
   int    n=m_lookback;
   for(int j=0;j<n;j++)
     {
      double x=(double)j;
      double y=range[i-n+1+j];
      sum_x+=x;
      sum_y+=y;
      sum_xy+=x*y;
      sum_xx+=x*x;
     }

   double denominator=n*sum_xx-sum_x*sum_x;
   if(MathAbs(denominator)<1e-10)
      return 0.0;

   return (n*sum_xy-sum_x*sum_y)/denominator;
  }

//+------------------------------------------------------------------+
//| The cascade itself, written as guard clauses.                    |
//|  The order is the meaning: contraction is tested first because   |
//|  it is the strictest, then expansion, then the ambiguous middle  |
//|  where the previous bar gets a vote. Falling off the end leaves  |
//|  the regime where it was, which is the intended behaviour for a  |
//|  bar that is neither extreme nor in transition.                  |
//+------------------------------------------------------------------+
ENUM_RMA_REGIME CRegimeDetector::Classify(const double r_min_ratio,const double r_max_ratio,
                                          const double slope,const double z,const double var_ratio,
                                          const ENUM_RMA_REGIME prev) const
  {
//--- contraction needs the envelope test AND corroboration from
//--- either steadiness or flatness. One reading alone is noise.
   bool contraction_extremum=(r_min_ratio<1.5 && r_max_ratio<m_eps_low);
   bool contraction_steady  =(var_ratio<m_var_ratio_low);
   bool contraction_flat    =(MathAbs(slope)<m_slope_thresh);
   if(contraction_extremum && (contraction_steady || contraction_flat))
      return RMA_REGIME_CONTRACTION;

//--- expansion is deliberately easier to reach: a range breaking out
//--- of its envelope is enough on its own, and so is a strong z-score
//--- once the spread is already twice its recent floor.
   bool expansion_extremum=(r_max_ratio>0.7 && r_min_ratio>m_eps_high);
   bool expansion_zscore  =(z>m_z_expansion);
   if(expansion_extremum || (expansion_zscore && r_min_ratio>2.0))
      return RMA_REGIME_EXPANSION;

//--- the middle band: wide enough to matter, not wide enough to call.
   bool in_transition=(r_max_ratio>m_eps_low && r_max_ratio<1.0 &&
                       r_min_ratio>1.0 && r_min_ratio<m_eps_high);
   if(in_transition)
     {
      if(slope<-m_slope_thresh || z<0.0)
         return RMA_REGIME_TO_CONTRACTION;
      if(slope>m_slope_thresh || z>0.0)
         return RMA_REGIME_TO_EXPANSION;
      return prev;
     }

//--- nothing has fired yet and nothing ever has: start in expansion
//--- so the EA is not held out of the market waiting for a first call.
   if(prev==RMA_REGIME_UNKNOWN)
      return RMA_REGIME_EXPANSION;

   return prev;
  }

//+------------------------------------------------------------------+
//| Classify bars [from, total) from the core's range series.        |
//+------------------------------------------------------------------+
bool CRegimeDetector::Calculate(const double &range[],const int total,const int from)
  {
   if(m_window<2)
     {
      Print("CRegimeDetector: Calculate before Init");
      return false;
     }
   if(total<=FirstBar())
      return false;
   if(!Allocate(total))
      return false;

   int first=FirstBar();
   int start=(from<first)?first:from;

   for(int i=start;i<total;i++)
     {
      if(m_hist_lookback==0)
         Accumulate(range,i);

      //--- pick the chain back up from the bar before, which is what
      //--- makes a partial recompute give the same answer as a full one.
      ENUM_RMA_REGIME prev=(i>first)?m_regime[i-1]:RMA_REGIME_UNKNOWN;

      double lo=0.0,hi=0.0;
      Envelope(range,i,lo,hi);
      m_min_history=lo;
      m_max_history=hi;

      if(lo<=0.0 || lo==DBL_MAX || hi<=0.0)
        {
         m_regime[i]=RMA_REGIME_UNKNOWN;
         continue;
        }

      double current=range[i];
      m_regime[i]=Classify(current/lo,current/hi,
                           Slope(range,i),ZScore(range,i),VariationRatio(range,i),
                           prev);
     }

   return true;
  }
//+------------------------------------------------------------------+
