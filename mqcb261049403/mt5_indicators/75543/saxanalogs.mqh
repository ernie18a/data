//+------------------------------------------------------------------+
//|                                                   SAXAnalogs.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23484 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23484"
#property version   "1.00"
#property strict

#include <SAX\SAXTransform.mqh>

//+------------------------------------------------------------------+
//| SAX analog search.                                               |
//|                                                                  |
//|  Question answered: "the current window looks like THIS — when   |
//|  has it looked like this before, and what happened next?"        |
//|                                                                  |
//|  For a query window of length L ending at the current bar we     |
//|  scan history for past windows with a similar shape, then read   |
//|  each match's KNOWN future (the next H bars). The collection of  |
//|  those H-bar forward moves is the empirical forward distribution |
//|  — the actual product of this tool.                              |
//|                                                                  |
//|  Two guards keep it honest:                                      |
//|   * no lookahead — a match's outcome window must end strictly    |
//|     before the query window begins, so nothing from the query's  |
//|     own future can leak into its "precedents".                   |
//|   * ATR-normalized outcomes — forward moves are expressed in     |
//|     multiples of the match-time ATR, so precedents from calm and |
//|     wild regimes are on a comparable footing.                    |
//+------------------------------------------------------------------+

//--- how the search is driven
enum ENUM_SAX_METRIC
  {
//--- two-stage SAX pipeline: prune candidates with the MINDIST lower
//--- bound, then rank the survivors by TRUE Euclidean distance. This
//--- is the canonical SAX search and the one meant for production.
   SAX_METRIC_MINDIST,
//--- brute force: true Euclidean distance over EVERY candidate, no
//--- pruning. Same ranking as the pipeline, used as the correctness
//--- and speed baseline.
   SAX_METRIC_EUCLID
  };

//--- overall verdict on the forward distribution
enum ENUM_ANALOG_VERDICT
  {
   ANALOG_NO_DATA,       // search not run, or history too short
   ANALOG_TOO_FEW,       // fewer analogs than the minimum sample
   ANALOG_NO_EDGE,       // enough analogs but forward move is a coin flip
   ANALOG_BULLISH,       // forward distribution leans up with conviction
   ANALOG_BEARISH        // forward distribution leans down with conviction
  };

//--- one historical precedent and its known outcome
struct SAnalog
  {
   int               bar_index;   // series index where the analog window ENDS
   datetime          end_time;    // time of that ending bar
   double            distance;    // TRUE Euclidean distance to the query (ranking key)
   double            mindist;     // SAX MINDIST lower bound that admitted this match
   double            fwd_atr;     // forward move over H bars, in ATR multiples
   double            fwd_pct;     // forward move over H bars, in percent (raw)
   double            fwd_path[];  // move at each step k=1..H, in ATR multiples (for the fan)
  };

//--- {median, p25, p75} of the analog moves at one forecast step
struct SStepStat
  {
   double            median_atr;
   double            p25_atr;
   double            p75_atr;
  };

//--- summary of the forward distribution built from the analogs
struct SForwardStats
  {
   int               count;          // number of analogs used
   double            median_atr;     // median forward move (ATR multiples)
   double            mean_atr;       // mean forward move (ATR multiples)
   double            p25_atr;        // 25th percentile (ATR multiples)
   double            p75_atr;        // 75th percentile (ATR multiples)
   double            up_rate;        // fraction of analogs with fwd move > 0
   double            dispersion;     // p75-p25 spread (ATR multiples)
   double            median_pct;     // median forward move (percent), for reference
   double            avg_distance;   // mean match distance (quality of the matches)
   ENUM_ANALOG_VERDICT verdict;
  };

//+------------------------------------------------------------------+
//| CSAXAnalogFinder - runs the search and summarizes outcomes.      |
//|                                                                  |
//|  Configure it once with the window length, forecast horizon and  |
//|  SAX parameters, then call Find() with a freshly copied history  |
//|  buffer. It owns no chart access — the caller supplies prices    |
//|  and ATR — so the same object works in an indicator, an EA or a  |
//|  test script.                                                    |
//+------------------------------------------------------------------+
class CSAXAnalogFinder
  {
private:
   //--- configuration
   int               m_win_len;      // L: query/analog window length (bars)
   int               m_horizon;      // H: forecast horizon (bars ahead)
   int               m_max_analogs;  // keep at most this many best matches
   int               m_min_analogs;  // below this -> ANALOG_TOO_FEW
   double            m_edge_atr;     // |median| below this -> ANALOG_NO_EDGE
   double            m_min_uprate;   // conviction band around 0.5 for NO_EDGE
   ENUM_SAX_METRIC   m_metric;
   CSAXTransform     m_sax;

   //--- results of the last Find()
   SAnalog           m_analogs[];    // kept matches, ascending by true distance
   int               m_found;
   SForwardStats     m_stats;
   int               m_query_word[]; // SAX word of the last query window
   double            m_query_paa[];  // z-normalized PAA vector of the query

   //--- search bookkeeping (for measuring the MINDIST speedup)
   int               m_scanned;      // candidates examined
   int               m_pruned;       // candidates rejected by MINDIST alone
   int               m_true_calcs;   // full Euclidean distances computed

   //--- helpers
   double            EuclidPAA(const double &raw[],int start,int len);
   void              InsertAnalog(SAnalog &a);
   void              BuildStats(void);
   double            Percentile(double &sorted[],int n,double q) const;
   void              Classify(void);

public:
                     CSAXAnalogFinder(void);

   //--- one-shot configuration. word_len/alphabet are SAX params;
   //--- win_len is the shape window, horizon the bars looked ahead.
   bool              Configure(int win_len,int horizon,int word_len,
                               int alphabet,ENUM_SAX_METRIC metric);

   void              SetMaxAnalogs(int n)       { if(n>0)  m_max_analogs=n; }
   void              SetMinAnalogs(int n)       { if(n>0)  m_min_analogs=n; }
   void              SetEdgeThreshold(double a) { if(a>=0) m_edge_atr=a;    }

   //--- run the search.
   //---  close[]  : chronological closes, oldest at index 0.
   //---  atr[]    : ATR aligned to close[] (same indexing). Used both to
   //---             normalize outcomes and as the scale for fwd_atr.
   //---  n        : number of usable bars in the buffers.
   //---  query_end: series index at which the QUERY window ends (usually
   //---             the last closed bar). Its window is close[query_end-L+1
   //---             .. query_end]; its forward outcome is NOT read.
   //--- Returns false if inputs are too short to search at all.
   bool              Find(const double &close[],const double &atr[],
                          int n,int query_end);

   //--- results
   int               Count(void)               const { return m_found;  }
   SForwardStats     Stats(void)               const { return m_stats;  }
   bool              GetAnalog(int i,SAnalog &out) const;

   //--- distribution of the analogs' move at forecast step 1..H (ATR
   //--- units). Feeds the fan cone. step is 1-based; false if invalid.
   bool              StepStats(int step,SStepStat &out) const;
   string            QueryWord(void)                 { return m_sax.WordToString(m_query_word); }
   string            VerdictText(void)         const;

   //--- search cost, for demonstrating the MINDIST pre-filter's payoff
   int               Scanned(void)             const { return m_scanned;    }
   int               Pruned(void)              const { return m_pruned;     }
   int               TrueCalcs(void)           const { return m_true_calcs; }
  };

//+------------------------------------------------------------------+
//| Construct with conservative defaults.                            |
//+------------------------------------------------------------------+
CSAXAnalogFinder::CSAXAnalogFinder(void)
  {
   m_win_len=48;
   m_horizon=12;
   m_max_analogs=50;
   m_min_analogs=10;
   m_edge_atr=0.25;      // median must clear a quarter-ATR to count as a lean
   m_min_uprate=0.58;    // up_rate must leave [1-0.58, 0.58] to add conviction
   m_metric=SAX_METRIC_MINDIST;
   m_found=0;
   m_stats.count=0;
   m_stats.verdict=ANALOG_NO_DATA;
  }

//+------------------------------------------------------------------+
//| Configure window/horizon and the underlying SAX transform.       |
//+------------------------------------------------------------------+
bool CSAXAnalogFinder::Configure(int win_len,int horizon,int word_len,
                                 int alphabet,ENUM_SAX_METRIC metric)
  {
   if(win_len<word_len || horizon<1)
      return false;
   if(!m_sax.Configure(word_len,alphabet))
      return false;
   m_win_len=win_len;
   m_horizon=horizon;
   m_metric=metric;
   return true;
  }

//+------------------------------------------------------------------+
//| TRUE distance between the query and a candidate window at        |
//| close[start..start+L-1]: the L2 distance of their z-normalized   |
//| PAA vectors, scaled by sqrt(L/w) so it lives on the same axis as |
//| MINDIST (and so MINDIST genuinely lower-bounds it). Uses the     |
//| cached query vector m_query_paa. Flat candidates return -1.      |
//+------------------------------------------------------------------+
double CSAXAnalogFinder::EuclidPAA(const double &raw[],int start,int len)
  {
   double win[];
   ArrayResize(win,len);
   for(int i=0;i<len;i++)
      win[i]=raw[start+i];

   double zn[];
   if(!m_sax.ZNormalize(win,len,zn))
      return -1.0;
   double paa[];
   if(!m_sax.PAA(zn,len,paa))
      return -1.0;

   int w=m_sax.WordLength();
   double s=0.0;
   for(int j=0;j<w;j++)
     {
      double d=m_query_paa[j]-paa[j];
      s+=d*d;
     }
   return MathSqrt((double)len/(double)w)*MathSqrt(s);
  }

//+------------------------------------------------------------------+
//| Insert an analog into m_analogs[] keeping it sorted ascending by |
//| TRUE distance and capped at m_max_analogs. A worse match than    |
//| the current worst (when full) is dropped.                        |
//+------------------------------------------------------------------+
void CSAXAnalogFinder::InsertAnalog(SAnalog &a)
  {
   if(m_found>=m_max_analogs && a.distance>=m_analogs[m_found-1].distance)
      return;                       // full and not better than the worst

   if(m_found<m_max_analogs)
     {
      ArrayResize(m_analogs,m_found+1);
      m_found++;
     }

//--- shift larger-distance entries right, drop off the tail
   int i=m_found-1;
   while(i>0 && m_analogs[i-1].distance>a.distance)
     {
      m_analogs[i]=m_analogs[i-1];
      i--;
     }
   m_analogs[i]=a;
  }

//+------------------------------------------------------------------+
//| Run the analog search (two-stage where MINDIST is selected).     |
//|                                                                  |
//|  Both metrics rank the kept analogs by TRUE distance; they differ|
//|  only in how much work they do to get there:                     |
//|                                                                  |
//|   SAX_METRIC_MINDIST — for each candidate, first compute the     |
//|      cheap MINDIST lower bound. Once the result buffer is full,  |
//|      any candidate whose MINDIST already meets or exceeds the    |
//|      worst kept true distance CANNOT be a top-k match (MINDIST   |
//|      <= true distance), so it is pruned without the costly full  |
//|      distance calc. Survivors get their true distance and compete|
//|                                                                  |
//|   SAX_METRIC_EUCLID  — compute the true distance for every       |
//|      candidate. No pruning; the correctness/speed baseline.      |
//|                                                                  |
//|  No-lookahead guard: a candidate ending at cEnd has its outcome  |
//|  read from close[cEnd+1..cEnd+H], which must finish before the   |
//|  query window starts -> cEnd + H < qStart.                       |
//+------------------------------------------------------------------+
bool CSAXAnalogFinder::Find(const double &close[],const double &atr[],
                            int n,int query_end)
  {
   m_found=0;
   ArrayResize(m_analogs,0);
   m_stats.count=0;
   m_stats.verdict=ANALOG_NO_DATA;
   m_scanned=0;
   m_pruned=0;
   m_true_calcs=0;

   int L=m_win_len;
   int H=m_horizon;
   if(query_end<L-1 || query_end>=n)
      return false;

//--- query window: close[qStart..query_end]
   int qStart=query_end-L+1;
   double qraw[];
   ArrayResize(qraw,L);
   for(int i=0;i<L;i++)
      qraw[i]=close[qStart+i];

//--- encode the query word once (needed for MINDIST) ...
   if(m_sax.Encode(qraw,L,m_query_word)!=SAX_OK)
      return false;
//--- ... and cache its z-normalized PAA vector (needed for true distance)
   double qz[];
   if(!m_sax.ZNormalize(qraw,L,qz) || !m_sax.PAA(qz,L,m_query_paa))
      return false;                // query too flat to compare

//--- latest candidate end that keeps the outcome window in the past
   int lastEnd=qStart-H-1;
   if(lastEnd<L-1)
      return false;                // not enough history for any analog

   for(int cEnd=L-1;cEnd<=lastEnd;cEnd++)
     {
      m_scanned++;
      int cStart=cEnd-L+1;

      //--- copy the candidate window once (both stages read it)
      double craw[];
      ArrayResize(craw,L);
      for(int i=0;i<L;i++)
         craw[i]=close[cStart+i];

      double md=0.0;               // MINDIST lower bound (0 if unused)

      //--- stage 1: MINDIST pre-filter (only for the MINDIST metric)
      if(m_metric==SAX_METRIC_MINDIST)
        {
         int cword[];
         if(m_sax.Encode(craw,L,cword)!=SAX_OK)
            continue;              // flat candidate
         md=m_sax.MinDist(m_query_word,cword,L);
         if(md<0.0)
            continue;
         //--- sound prune: buffer full and lower bound already too big
         if(m_found>=m_max_analogs && md>=m_analogs[m_found-1].distance)
           {
            m_pruned++;
            continue;
           }
        }

      //--- stage 2: true distance on the survivors
      double dist=EuclidPAA(craw,0,L);
      if(dist<0.0)
         continue;                 // flat candidate
      m_true_calcs++;

      //--- forward outcome over H bars, normalized by ATR at the match
      int    fEnd=cEnd+H;
      double base=close[cEnd];
      double scale=atr[cEnd];
      if(base<=0.0 || scale<=0.0)
         continue;
      double move=close[fEnd]-base;

      SAnalog a;
      a.bar_index=cEnd;
      a.end_time =0;               // filled by the caller if it wants times
      a.distance =dist;
      a.mindist  =md;
      a.fwd_atr  =move/scale;
      a.fwd_pct  =100.0*move/base;
      //--- full forward path (each step in ATR units) for the fan cone
      ArrayResize(a.fwd_path,H);
      for(int k=1;k<=H;k++)
         a.fwd_path[k-1]=(close[cEnd+k]-base)/scale;
      InsertAnalog(a);
     }

   BuildStats();
   return (m_found>0);
  }

//+------------------------------------------------------------------+
//| Linear-interpolated percentile of an ascending sorted array.     |
//+------------------------------------------------------------------+
double CSAXAnalogFinder::Percentile(double &sorted[],int n,double q) const
  {
   if(n<=0)
      return 0.0;
   if(n==1)
      return sorted[0];
   double pos=q*(n-1);
   int lo=(int)MathFloor(pos);
   int hi=lo+1;
   if(hi>=n)
      return sorted[n-1];
   double frac=pos-lo;
   return sorted[lo]+frac*(sorted[hi]-sorted[lo]);
  }

//+------------------------------------------------------------------+
//| Summarize the kept analogs into the forward distribution stats.  |
//+------------------------------------------------------------------+
void CSAXAnalogFinder::BuildStats(void)
  {
   m_stats.count=m_found;
   if(m_found<=0)
     {
      m_stats.verdict=ANALOG_NO_DATA;
      return;
     }

//--- gather the forward moves and match distances
   double atrArr[],pctArr[];
   ArrayResize(atrArr,m_found);
   ArrayResize(pctArr,m_found);
   double sumAtr=0.0,sumDist=0.0;
   int    up=0;
   for(int i=0;i<m_found;i++)
     {
      atrArr[i]=m_analogs[i].fwd_atr;
      pctArr[i]=m_analogs[i].fwd_pct;
      sumAtr+=m_analogs[i].fwd_atr;
      sumDist+=m_analogs[i].distance;
      if(m_analogs[i].fwd_atr>0.0)
         up++;
     }

   ArraySort(atrArr);
   ArraySort(pctArr);

   m_stats.count      =m_found;
   m_stats.mean_atr   =sumAtr/m_found;
   m_stats.median_atr =Percentile(atrArr,m_found,0.50);
   m_stats.p25_atr    =Percentile(atrArr,m_found,0.25);
   m_stats.p75_atr    =Percentile(atrArr,m_found,0.75);
   m_stats.dispersion =m_stats.p75_atr-m_stats.p25_atr;
   m_stats.up_rate    =(double)up/(double)m_found;
   m_stats.median_pct =Percentile(pctArr,m_found,0.50);
   m_stats.avg_distance=sumDist/m_found;

   Classify();
  }

//+------------------------------------------------------------------+
//| Turn the stats into a verdict.                                   |
//|  Order matters: too-few analogs is decided first, then the       |
//|  no-edge (coin-flip) case, and only a sample that clears BOTH    |
//|  the median-move and up-rate conviction bands earns a direction. |
//+------------------------------------------------------------------+
void CSAXAnalogFinder::Classify(void)
  {
   if(m_found<m_min_analogs)
     {
      m_stats.verdict=ANALOG_TOO_FEW;
      return;
     }

   double med=m_stats.median_atr;
   double up =m_stats.up_rate;

//--- coin flip: median move too small OR direction not decisive enough
   bool weakMove =(MathAbs(med)<m_edge_atr);
   bool weakDir  =(up<m_min_uprate && up>1.0-m_min_uprate);
   if(weakMove || weakDir)
     {
      m_stats.verdict=ANALOG_NO_EDGE;
      return;
     }

   m_stats.verdict=(med>0.0)?ANALOG_BULLISH:ANALOG_BEARISH;
  }

//+------------------------------------------------------------------+
//| Copy out the i-th analog (0 = closest match). false if invalid.  |
//+------------------------------------------------------------------+
bool CSAXAnalogFinder::GetAnalog(int i,SAnalog &out) const
  {
   if(i<0 || i>=m_found)
      return false;
   out=m_analogs[i];
   return true;
  }

//+------------------------------------------------------------------+
//| Median / p25 / p75 of the analogs' move at forecast step 'step'  |
//| (1..H), in ATR units. This is the per-step slice the fan cone    |
//| draws: gather every analog's fwd_path[step-1], sort, take the    |
//| three percentiles.                                               |
//+------------------------------------------------------------------+
bool CSAXAnalogFinder::StepStats(int step,SStepStat &out) const
  {
   if(m_found<=0 || step<1 || step>m_horizon)
      return false;

   double v[];
   ArrayResize(v,m_found);
   for(int i=0;i<m_found;i++)
      v[i]=m_analogs[i].fwd_path[step-1];
   ArraySort(v);

   out.median_atr=Percentile(v,m_found,0.50);
   out.p25_atr   =Percentile(v,m_found,0.25);
   out.p75_atr   =Percentile(v,m_found,0.75);
   return true;
  }

//+------------------------------------------------------------------+
//| Human-readable verdict for logs and the on-chart panel.          |
//+------------------------------------------------------------------+
string CSAXAnalogFinder::VerdictText(void) const
  {
   switch(m_stats.verdict)
     {
      case ANALOG_NO_DATA:
         return "no data";
      case ANALOG_TOO_FEW:
         return StringFormat("too few analogs (%d/%d)",
                             m_found,m_min_analogs);
      case ANALOG_NO_EDGE:
         return "no edge (coin flip)";
      case ANALOG_BULLISH:
         return "bullish lean";
      case ANALOG_BEARISH:
         return "bearish lean";
     }
   return "unknown";
  }
//+------------------------------------------------------------------+
