//+------------------------------------------------------------------+
//|                                                   AcdDiurnal.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict

#include <ACD\AcdEvents.mqh>

//+------------------------------------------------------------------+
//| CAcdDiurnal - the normal level of something at each time of day. |
//|                                                                  |
//|  Bin averages, optionally per weekday, read by interpolating     |
//|  between bin centers so no false step appears at bin edges.      |
//|  Thin bins borrow from the pooled day, then the nearest bin.     |
//+------------------------------------------------------------------+
class CAcdDiurnal
  {
private:
   int               m_bin_sec;        // bin width in seconds
   int               m_bins;           // bins per day
   int               m_days;           // 7 by weekday, 1 pooled
   int               m_min_count;      // observations a bin needs to stand alone
   double            m_value[];        // m_days * m_bins, the fitted profile
   bool              m_ready;

//--- accumulators, alive between Begin and Finish
   double            m_sum[];
   long              m_cnt[];
   double            m_pool_sum[];
   long              m_pool_cnt[];

   int               DayOf(const long t_msc) const;
   bool              FillRing(double &ring[],const bool &valid[]) const;

public:
                     CAcdDiurnal(void);

//--- bin width and whether each weekday gets its own profile
   bool              Setup(const int bin_minutes,const bool by_weekday);
   void              SetMinCount(const int n) { m_min_count=(n>1 ? n : 1); }

//--- streaming fit: Begin, any number of Add, then Finish
   void              Begin(void);
   void              Add(const long t_msc,const double value);
   bool              Finish(void);

//--- mean waits on events [from, to], each filed under its start time
   bool              FitWaits(const CAcdEvents &ev,const int from,const int to);

//--- rescale so adjusted waits in [from, to] average one; 0 on failure
   double            UnitMeanWaits(const CAcdEvents &ev,const int from,const int to);

//--- the normal level at a moment, interpolated between bin centers
   double            Value(const long t_msc) const;

//--- multiply the whole profile, used to put adjusted values on a unit mean
   void              Scale(const double factor);

//--- copy a fitted profile, so a live state can own one
   void              Assign(const CAcdDiurnal &src);

   bool              Ready(void)      const { return m_ready;   }
   int               Bins(void)       const { return m_bins;    }
   int               Days(void)       const { return m_days;    }
   int               BinSeconds(void) const { return m_bin_sec; }
   double            BinValue(const int day,const int bin) const { return m_value[day*m_bins+bin]; }

//--- largest over smallest bin value: how strong the rhythm is
   double            Spread(void) const;
  };

//+------------------------------------------------------------------+
//| Half-hour bins, one pooled day, fifty observations per bin.      |
//+------------------------------------------------------------------+
CAcdDiurnal::CAcdDiurnal(void)
  {
   m_min_count=50;
   m_ready    =false;
   Setup(30,false);
  }

//+------------------------------------------------------------------+
//| Choose the binning. The width must divide the day exactly.       |
//+------------------------------------------------------------------+
bool CAcdDiurnal::Setup(const int bin_minutes,const bool by_weekday)
  {
   if(bin_minutes<1 || 1440%bin_minutes!=0)
     {
      PrintFormat("CAcdDiurnal: a %d-minute bin does not divide the day",bin_minutes);
      return false;
     }
   m_bin_sec=bin_minutes*60;
   m_bins   =1440/bin_minutes;
   m_days   =(by_weekday ? 7 : 1);
   m_ready  =false;
   ArrayResize(m_value,m_days*m_bins);
   ArrayInitialize(m_value,0.0);
   return true;
  }

//+------------------------------------------------------------------+
//| Weekday from the epoch day count; 1970-01-01 was a Thursday.     |
//+------------------------------------------------------------------+
int CAcdDiurnal::DayOf(const long t_msc) const
  {
   if(m_days==1)
      return 0;
   return (int)((t_msc/86400000+4)%7);
  }

//+------------------------------------------------------------------+
//| Reset the accumulators.                                          |
//+------------------------------------------------------------------+
void CAcdDiurnal::Begin(void)
  {
   ArrayResize(m_sum,m_days*m_bins);
   ArrayResize(m_cnt,m_days*m_bins);
   ArrayResize(m_pool_sum,m_bins);
   ArrayResize(m_pool_cnt,m_bins);
   ArrayInitialize(m_sum,0.0);
   ArrayInitialize(m_cnt,0);
   ArrayInitialize(m_pool_sum,0.0);
   ArrayInitialize(m_pool_cnt,0);
   m_ready=false;
  }

//+------------------------------------------------------------------+
//| File one observation under its bin.                              |
//+------------------------------------------------------------------+
void CAcdDiurnal::Add(const long t_msc,const double value)
  {
   const int bin =(int)((t_msc/1000)%86400)/m_bin_sec;
   const int slot=DayOf(t_msc)*m_bins+bin;
   m_sum[slot]+=value;
   m_cnt[slot]++;
   m_pool_sum[bin]+=value;
   m_pool_cnt[bin]++;
  }

//+------------------------------------------------------------------+
//| Replace invalid bins on one day's ring by the nearest valid bin. |
//+------------------------------------------------------------------+
bool CAcdDiurnal::FillRing(double &ring[],const bool &valid[]) const
  {
   bool any=false;
   for(int b=0;b<m_bins && !any;b++)
      any=valid[b];
   if(!any)
      return false;

   double out[];
   ArrayResize(out,m_bins);
   for(int b=0;b<m_bins;b++)
     {
      if(valid[b])
        {
         out[b]=ring[b];
         continue;
        }
      for(int d=1;d<=m_bins/2;d++)
        {
         const int up=(b+d)%m_bins;
         const int dn=(b-d+m_bins)%m_bins;
         if(valid[dn])
           {
            out[b]=ring[dn];
            break;
           }
         if(valid[up])
           {
            out[b]=ring[up];
            break;
           }
        }
     }
   ArrayCopy(ring,out,0,0,m_bins);
   return true;
  }

//+------------------------------------------------------------------+
//| Turn the accumulated sums into a complete profile.               |
//+------------------------------------------------------------------+
bool CAcdDiurnal::Finish(void)
  {
   double pooled[];
   bool   pooled_ok[];
   ArrayResize(pooled,m_bins);
   ArrayResize(pooled_ok,m_bins);
   for(int b=0;b<m_bins;b++)
     {
      pooled_ok[b]=(m_pool_cnt[b]>=m_min_count);
      pooled[b]   =(pooled_ok[b] ? m_pool_sum[b]/m_pool_cnt[b] : 0.0);
     }
   if(!FillRing(pooled,pooled_ok))
     {
      Print("CAcdDiurnal: no bin has enough observations to fit a profile");
      return false;
     }

   double ring[];
   bool   ok[];
   ArrayResize(ring,m_bins);
   ArrayResize(ok,m_bins);
   for(int d=0;d<m_days;d++)
     {
      for(int b=0;b<m_bins;b++)
        {
         const int s=d*m_bins+b;
         ok[b]  =(m_cnt[s]>=m_min_count);
         ring[b]=(ok[b] ? m_sum[s]/m_cnt[s] : 0.0);
         //--- a thin weekday bin falls back to the pooled time of day first
         if(!ok[b] && pooled_ok[b])
           {
            ring[b]=pooled[b];
            ok[b]  =true;
           }
        }
      //--- a day with nothing at all, such as Sunday on an index, is pooled
      if(!FillRing(ring,ok))
         ArrayCopy(ring,pooled,0,0,m_bins);
      ArrayCopy(m_value,ring,d*m_bins,0,m_bins);
     }

   ArrayFree(m_sum);
   ArrayFree(m_cnt);
   ArrayFree(m_pool_sum);
   ArrayFree(m_pool_cnt);
   m_ready=true;
   return true;
  }

//+------------------------------------------------------------------+
//| Mean wait per bin over events [from, to], gaps excluded.         |
//+------------------------------------------------------------------+
bool CAcdDiurnal::FitWaits(const CAcdEvents &ev,const int from,const int to)
  {
   const int a=(from<1 ? 1 : from);
   const int b=(to>=ev.Total() ? ev.Total()-1 : to);
   if(b<=a)
      return false;

   Begin();
   for(int i=a;i<=b;i++)
      if(!ev.IsStart(i))
         Add(ev.Time(i-1),ev.Wait(i));
   return Finish();
  }

//+------------------------------------------------------------------+
//| Put adjusted waits on a mean of one, so 1 reads as "normal".     |
//+------------------------------------------------------------------+
double CAcdDiurnal::UnitMeanWaits(const CAcdEvents &ev,const int from,const int to)
  {
   if(!m_ready)
      return 0.0;
   const int a=(from<1 ? 1 : from);
   const int b=(to>=ev.Total() ? ev.Total()-1 : to);

   double sum=0.0;
   long   cnt=0;
   for(int i=a;i<=b;i++)
     {
      if(ev.IsStart(i))
         continue;
      sum+=ev.Wait(i)/Value(ev.Time(i-1));
      cnt++;
     }
   if(cnt<1000 || sum<=0.0)
      return 0.0;
   const double factor=sum/cnt;
   Scale(factor);
   return factor;
  }

//+------------------------------------------------------------------+
//| Interpolate between the bin centers either side of t; the ring   |
//| wraps at midnight within the same weekday.                       |
//+------------------------------------------------------------------+
double CAcdDiurnal::Value(const long t_msc) const
  {
   const double pos =((double)((t_msc/1000)%86400)+(t_msc%1000)/1000.0)/m_bin_sec-0.5;
   const double fl  =MathFloor(pos);
   const double frac=pos-fl;
   int b0=(int)fl;
   if(b0<0)
      b0+=m_bins;
   const int b1  =(b0+1)%m_bins;
   const int base=DayOf(t_msc)*m_bins;
   return (1.0-frac)*m_value[base+b0]+frac*m_value[base+b1];
  }

//+------------------------------------------------------------------+
//| Multiply every bin by a constant.                                |
//+------------------------------------------------------------------+
void CAcdDiurnal::Scale(const double factor)
  {
   const int n=ArraySize(m_value);
   for(int i=0;i<n;i++)
      m_value[i]*=factor;
  }

//+------------------------------------------------------------------+
//| Take over another profile's configuration and values.            |
//+------------------------------------------------------------------+
void CAcdDiurnal::Assign(const CAcdDiurnal &src)
  {
   m_bin_sec  =src.m_bin_sec;
   m_bins     =src.m_bins;
   m_days     =src.m_days;
   m_min_count=src.m_min_count;
   m_ready    =src.m_ready;
   ArrayResize(m_value,ArraySize(src.m_value));
   ArrayCopy(m_value,src.m_value);
  }

//+------------------------------------------------------------------+
//| Ratio of the largest to the smallest positive bin.               |
//+------------------------------------------------------------------+
double CAcdDiurnal::Spread(void) const
  {
   double lo=DBL_MAX,hi=0.0;
   const int n=ArraySize(m_value);
   for(int i=0;i<n;i++)
     {
      if(m_value[i]<=0.0)
         continue;
      lo=MathMin(lo,m_value[i]);
      hi=MathMax(hi,m_value[i]);
     }
   return (lo<DBL_MAX ? hi/lo : 0.0);
  }
//+------------------------------------------------------------------+
