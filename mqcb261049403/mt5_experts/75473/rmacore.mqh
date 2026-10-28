//+------------------------------------------------------------------+
//|                                                      RmaCore.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| CRmaCore - the Relative Moving Average family.                   |
//|                                                                  |
//|  For each bar the class takes the trailing window of W closes    |
//|  and measures where the window sits relative to its own mean:    |
//|                                                                  |
//|    rma_x = sma / x - 1                                           |
//|                                                                  |
//|  evaluated at x = the last close, the first close, the middle    |
//|  close, and the window's min and max. Each is a pure ratio, so   |
//|  the family is scale-free and comparable across instruments.     |
//|                                                                  |
//|  Those five numbers describe position but not rarity: -0.4% is   |
//|  extreme in a quiet window and unremarkable in a wild one. The   |
//|  fractiles fix that by re-expressing the window as normalised    |
//|  returns (close/sma - 1) and ranking the current one among them  |
//|  on a scale anchored at 0 for the window's smallest member and   |
//|  1 for its largest. f_w is what everything downstream actually   |
//|  trades: it is bounded in [0,1], so a threshold like 0.9 means   |
//|  the same thing in every regime and on every symbol.             |
//|                                                                  |
//|  The class owns its own storage rather than writing into         |
//|  indicator buffers directly. SetIndexBuffer can only bind a      |
//|  global-scope array, so a class that wrote through would only    |
//|  ever be usable from an indicator; keeping the arrays internal   |
//|  lets the same code serve a script or an Expert unchanged, at    |
//|  the cost of one copy of the new bars in the caller.             |
//+------------------------------------------------------------------+
class CRmaCore
  {
private:
   int               m_window;         // W - bars per window
   int               m_smoothing;      // EMA period for the alpha means
   double            m_ema_alpha;      // 2/(smoothing+1), cached
   int               m_size;           // allocated series length

//--- per-bar output series, all indexed chronologically
   double            m_sma[];
   double            m_rma_w[];
   double            m_rma_1[];
   double            m_rma_mid[];
   double            m_rma_min[];
   double            m_rma_max[];
   double            m_f_w[];
   double            m_f_min[];
   double            m_f_max[];
   double            m_range[];
   double            m_alpha_lo[];
   double            m_alpha_hi[];
   double            m_alpha_lo_mean[];
   double            m_alpha_hi_mean[];

//--- scratch reused across bars so the per-bar path allocates nothing
   double            m_window_buf[];
   double            m_norm_buf[];

   bool              Allocate(const int total);
   void              ComputeBar(const double &price[],const int i);
   double            Fractile(const double &dist[],const int n,const double value) const;

public:
                     CRmaCore(void);

//--- window length and alpha-mean smoothing. Safe to call again to
//--- reconfigure; the next Calculate must then start from FirstBar.
   bool              Init(const int window,const int smoothing);

//--- fill bars [from, total) from a chronological close array.
//--- 'from' is clamped up to FirstBar, and bars before it stay zero.
//--- The alpha means are recursive, so [from-1] must already hold a
//--- valid value whenever from > FirstBar — which is what an
//--- OnCalculate driven by prev_calculated-1 naturally guarantees.
   bool              Calculate(const double &price[],const int total,const int from);

//--- first index that can carry a value, given the window length.
   int               FirstBar(void) const { return m_window; }
   int               Window(void)   const { return m_window; }
   int               Size(void)     const { return m_size;   }

//--- output accessors. Callers stay inside [FirstBar, total).
   double            Sma(const int i)          const { return m_sma[i];           }
   double            RmaW(const int i)         const { return m_rma_w[i];         }
   double            RmaFirst(const int i)     const { return m_rma_1[i];         }
   double            RmaMid(const int i)       const { return m_rma_mid[i];       }
   double            RmaMin(const int i)       const { return m_rma_min[i];       }
   double            RmaMax(const int i)       const { return m_rma_max[i];       }
   double            Fw(const int i)           const { return m_f_w[i];           }
   double            FMin(const int i)         const { return m_f_min[i];         }
   double            FMax(const int i)         const { return m_f_max[i];         }
   double            Range(const int i)        const { return m_range[i];         }
   double            AlphaLower(const int i)   const { return m_alpha_lo[i];      }
   double            AlphaUpper(const int i)   const { return m_alpha_hi[i];      }
   double            AlphaLowerMean(const int i) const { return m_alpha_lo_mean[i]; }
   double            AlphaUpperMean(const int i) const { return m_alpha_hi_mean[i]; }
  };

//+------------------------------------------------------------------+
//| Construct in an unusable state until Init is called.             |
//+------------------------------------------------------------------+
CRmaCore::CRmaCore(void)
  {
   m_window   =0;
   m_smoothing=0;
   m_ema_alpha=0.0;
   m_size     =0;
  }

//+------------------------------------------------------------------+
//| Set window length and alpha-mean smoothing.                      |
//+------------------------------------------------------------------+
bool CRmaCore::Init(const int window,const int smoothing)
  {
   if(window<2 || smoothing<1)
     {
      PrintFormat("CRmaCore: bad parameters W=%d smoothing=%d",window,smoothing);
      return false;
     }
   m_window   =window;
   m_smoothing=smoothing;
   m_ema_alpha=2.0/(smoothing+1.0);

   ArrayResize(m_window_buf,window);
   ArrayResize(m_norm_buf,window);
   return true;
  }

//+------------------------------------------------------------------+
//| Grow every output series to hold 'total' bars.                   |
//|  Resizing to the same length is a no-op, so this is cheap to     |
//|  call on every pass. The reserve argument keeps the terminal     |
//|  from reallocating once per new bar as history extends.          |
//+------------------------------------------------------------------+
bool CRmaCore::Allocate(const int total)
  {
   if(total<=m_size)
      return true;

   const int reserve=1024;
   if(ArrayResize(m_sma,total,reserve)<0)
      return false;
   ArrayResize(m_rma_w,total,reserve);
   ArrayResize(m_rma_1,total,reserve);
   ArrayResize(m_rma_mid,total,reserve);
   ArrayResize(m_rma_min,total,reserve);
   ArrayResize(m_rma_max,total,reserve);
   ArrayResize(m_f_w,total,reserve);
   ArrayResize(m_f_min,total,reserve);
   ArrayResize(m_f_max,total,reserve);
   ArrayResize(m_range,total,reserve);
   ArrayResize(m_alpha_lo,total,reserve);
   ArrayResize(m_alpha_hi,total,reserve);
   ArrayResize(m_alpha_lo_mean,total,reserve);
   ArrayResize(m_alpha_hi_mean,total,reserve);

//--- bars below FirstBar are never written, so they must start clean
//--- rather than carrying whatever the allocator handed back.
   for(int i=m_size;i<total;i++)
     {
      m_sma[i]=0.0;
      m_rma_w[i]=0.0;
      m_rma_1[i]=0.0;
      m_rma_mid[i]=0.0;
      m_rma_min[i]=0.0;
      m_rma_max[i]=0.0;
      m_f_w[i]=0.0;
      m_f_min[i]=0.0;
      m_f_max[i]=0.0;
      m_range[i]=0.0;
      m_alpha_lo[i]=0.0;
      m_alpha_hi[i]=0.0;
      m_alpha_lo_mean[i]=0.0;
      m_alpha_hi_mean[i]=0.0;
     }

   m_size=total;
   return true;
  }

//+------------------------------------------------------------------+
//| Where 'value' ranks inside 'dist': the share of the window that  |
//| is at or below it. This is compute_fractile verbatim from the    |
//| paper's Appendix 14.1.1.2,                                       |
//|     f_i = (1/|W_i|) * sum_j I( W_ij <= v_i ),                    |
//|  the plain empirical CDF. Fidelity to the paper is the spine of  |
//|  the port, so the listing wins over any inferred convention.     |
//|                                                                  |
//|  9.3 claims f_w reaches 0 at the window minimum, but this ECDF   |
//|  floors at 1/n there (the minimum is <= only itself); f_max      |
//|  still hits 1. That 1/n gap is the paper's own prose-vs-appendix |
//|  inconsistency, left as the appendix has it rather than patched. |
//|                                                                  |
//|  Linear rather than sorted-and-bisected: the caller already      |
//|  walks the window once per bar, so a second pass beats a sort.   |
//+------------------------------------------------------------------+
double CRmaCore::Fractile(const double &dist[],const int n,const double value) const
  {
   if(n<=1)
      return 0.5;

   int at_or_below=0;
   for(int i=0;i<n;i++)
     {
      if(dist[i]<=value)
         at_or_below++;
     }

   return (double)at_or_below/(double)n;
  }

//+------------------------------------------------------------------+
//| Compute every series for bar i from the trailing W closes.       |
//+------------------------------------------------------------------+
void CRmaCore::ComputeBar(const double &price[],const int i)
  {
   const int W=m_window;
   const int base=i-W+1;

//--- lift the window out once; every statistic below reads it again.
   double sum=0.0;
   for(int j=0;j<W;j++)
     {
      double p=price[base+j];
      m_window_buf[j]=p;
      sum+=p;
     }

   double sma=sum/W;
   m_sma[i]=sma;

//--- a non-positive mean means the ratios below are meaningless, and
//--- for any real price series it cannot happen. Leave the bar zero.
   if(sma<=0.0)
      return;

   double first_elem=m_window_buf[0];
   double last_elem =m_window_buf[W-1];
   double mid_elem  =m_window_buf[W/2];

   double min_elem=m_window_buf[0];
   double max_elem=m_window_buf[0];
   for(int j=1;j<W;j++)
     {
      if(m_window_buf[j]<min_elem)
         min_elem=m_window_buf[j];
      if(m_window_buf[j]>max_elem)
         max_elem=m_window_buf[j];
     }

//--- the RMA family: where the mean sits relative to each landmark.
   if(last_elem>0.0)
      m_rma_w[i]=(sma/last_elem)-1.0;
   if(first_elem>0.0)
      m_rma_1[i]=(sma/first_elem)-1.0;
   if(mid_elem>0.0)
      m_rma_mid[i]=(sma/mid_elem)-1.0;
   if(min_elem>0.0)
      m_rma_min[i]=(sma/min_elem)-1.0;
   if(max_elem>0.0)
      m_rma_max[i]=(sma/max_elem)-1.0;

//--- re-express the window as returns about its own mean, then rank
//--- the current, minimum and maximum members within that spread.
   double norm_min=0.0;
   double norm_max=0.0;
   for(int j=0;j<W;j++)
     {
      double nr=(m_window_buf[j]/sma)-1.0;
      m_norm_buf[j]=nr;
      if(j==0 || nr<norm_min)
         norm_min=nr;
      if(j==0 || nr>norm_max)
         norm_max=nr;
     }

   m_f_w[i]  =Fractile(m_norm_buf,W,(last_elem/sma)-1.0);
   m_f_min[i]=Fractile(m_norm_buf,W,(min_elem/sma)-1.0);
   m_f_max[i]=Fractile(m_norm_buf,W,(max_elem/sma)-1.0);

   m_range[i]=norm_max-norm_min;

//--- alpha bounds: the quantile level w occupies, and its complement.
   m_alpha_lo[i]=m_f_w[i];
   m_alpha_hi[i]=1.0-m_f_w[i];

   if(i==m_window)
     {
      m_alpha_lo_mean[i]=m_alpha_lo[i];
      m_alpha_hi_mean[i]=m_alpha_hi[i];
     }
   else
     {
      m_alpha_lo_mean[i]=m_ema_alpha*m_alpha_lo[i]+(1.0-m_ema_alpha)*m_alpha_lo_mean[i-1];
      m_alpha_hi_mean[i]=m_ema_alpha*m_alpha_hi[i]+(1.0-m_ema_alpha)*m_alpha_hi_mean[i-1];
     }
  }

//+------------------------------------------------------------------+
//| Fill bars [from, total) from a chronological close array.        |
//+------------------------------------------------------------------+
bool CRmaCore::Calculate(const double &price[],const int total,const int from)
  {
   if(m_window<2)
     {
      Print("CRmaCore: Calculate before Init");
      return false;
     }
   if(total<=m_window)
      return false;
   if(ArraySize(price)<total)
     {
      PrintFormat("CRmaCore: price array holds %d, need %d",ArraySize(price),total);
      return false;
     }
   if(!Allocate(total))
     {
      Print("CRmaCore: allocation failed");
      return false;
     }

   int start=(from<m_window)?m_window:from;
   for(int i=start;i<total;i++)
      ComputeBar(price,i);

   return true;
  }
//+------------------------------------------------------------------+
