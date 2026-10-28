//+------------------------------------------------------------------+
//|                                               AdverseMonitor.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| CAdverseMonitor - which way is the fractile actually walking?    |
//|                                                                  |
//|  Two series, both cheap, both about direction rather than level. |
//|                                                                  |
//|  d_med_w is f_w re-centred on the median, so its sign says which |
//|  side of the window's middle the latest return sits on. D_k is   |
//|  the share of the last L bar-to-bar changes in d_med_w that were |
//|  upward, ignoring the flat ones. Near 1 the fractile has been    |
//|  climbing without pause, near 0 it has been sliding, and 0.5 is  |
//|  the coin-flip that a directionless stretch produces.            |
//|                                                                  |
//|  The pair is what makes the exit rule readable: a long that is   |
//|  below the median (d_med_w < 0) while the fractile keeps making  |
//|  lower steps (D_k low) is not waiting for a bounce, it is in a   |
//|  move going the other way.                                       |
//|                                                                  |
//|  Both series are indexed by bar rather than pushed into a        |
//|  circular buffer from the trading loop, and that is what keeps   |
//|  them honest: every bar is present, so D_k never measures a step |
//|  between two bars that were not adjacent, and nothing carries    |
//|  across a restart that is not recomputed from the chart.         |
//+------------------------------------------------------------------+
class CAdverseMonitor
  {
private:
   int               m_lookback;       // L, bars of change history behind D_k
   int               m_first;          // first bar the caller can supply f_w for
   int               m_size;
   double            m_d_med_w[];
   double            m_dk[];

   bool              Allocate(const int total);

public:
                     CAdverseMonitor(void);

   bool              Init(const int lookback,const int first_bar);

//--- fill bars [from, total) from a fractile series indexed by bar.
   bool              Calculate(const double &f_w[],const int total,const int from);

//--- first bar carrying d_med_w, and the first carrying a real D_k.
   int               FirstBar(void)   const { return m_first; }
   int               FirstDk(void)    const { return m_first+m_lookback; }

   double            DMedW(const int i) const { return m_d_med_w[i]; }
   double            Dk(const int i)    const { return m_dk[i];      }
  };

//+------------------------------------------------------------------+
//| Construct in an unusable state until Init is called.             |
//+------------------------------------------------------------------+
CAdverseMonitor::CAdverseMonitor(void)
  {
   m_lookback =0;
   m_first    =0;
   m_size     =0;
  }

//+------------------------------------------------------------------+
//| Store the lookback and where the fractile series begins.         |
//+------------------------------------------------------------------+
bool CAdverseMonitor::Init(const int lookback,const int first_bar)
  {
   if(lookback<2 || first_bar<1)
     {
      PrintFormat("CAdverseMonitor: bad geometry L=%d first=%d",lookback,first_bar);
      return false;
     }
   m_lookback =lookback;
   m_first    =first_bar;
   return true;
  }

//+------------------------------------------------------------------+
//| Grow both series, seeding new bars neutral.                      |
//+------------------------------------------------------------------+
bool CAdverseMonitor::Allocate(const int total)
  {
   if(total<=m_size)
      return true;
   if(ArrayResize(m_d_med_w,total,1024)<0 || ArrayResize(m_dk,total,1024)<0)
      return false;
   for(int i=m_size;i<total;i++)
     {
      m_d_med_w[i]=0.0;
      m_dk[i]     =0.5;
     }
   m_size=total;
   return true;
  }

//+------------------------------------------------------------------+
//| Fill bars [from, total) from a fractile series indexed by bar.   |
//|  d_med_w has to run one lookback ahead of D_k, so the loop is    |
//|  split: the recentring pass starts at the first fractile bar,    |
//|  and the counting pass only starts once L changes exist behind   |
//|  it. Before that D_k stays at 0.5, which reads as "no opinion"   |
//|  everywhere it is compared against a threshold.                  |
//+------------------------------------------------------------------+
bool CAdverseMonitor::Calculate(const double &f_w[],const int total,const int from)
  {
   if(m_lookback<2)
     {
      Print("CAdverseMonitor: Calculate before Init");
      return false;
     }
   if(total<=m_first)
      return false;
   if(!Allocate(total))
      return false;

   int d_start=(from<m_first)?m_first:from;
   for(int i=d_start;i<total;i++)
      m_d_med_w[i]=f_w[i]-0.5;

   int first_dk=FirstDk();
   int k_start=(from<first_dk)?first_dk:from;
   for(int i=k_start;i<total;i++)
     {
      int increases=0;
      int decreases=0;
      for(int j=0;j<m_lookback;j++)
        {
         double diff=m_d_med_w[i-j]-m_d_med_w[i-j-1];
         if(diff>0.0)
            increases++;
         if(diff<0.0)
            decreases++;
        }

      int changes=increases+decreases;
      m_dk[i]=(changes>0)?(double)increases/(double)changes:0.5;
     }

   return true;
  }
//+------------------------------------------------------------------+
