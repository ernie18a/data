//+------------------------------------------------------------------+
//|                                                         BOSS.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23491 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23491"
#property version   "1.00"
#property strict

#include <BOSS\SFA.mqh>

//--- a series shorter than this many samples cannot host even one
//--- window plus a little context; treated as too short to classify.
#define BOSS_MIN_SERIES 4

//+------------------------------------------------------------------+
//| CBossHistogram - a sparse word-count histogram.                  |
//|                                                                  |
//|  A BOSS representation of a series is just a bag of words: how   |
//|  many times each SFA word appears as the sliding window moves    |
//|  along the series. Most possible words never occur, so the bag   |
//|  is stored sparsely as parallel arrays of word strings and their |
//|  counts rather than a dense vector over the whole vocabulary.    |
//|                                                                  |
//|  Word strings double as human-readable labels, which is what     |
//|  lets us later print the vocabulary of a class - something the   |
//|  elastic-distance classifiers cannot offer.                      |
//+------------------------------------------------------------------+
class CBossHistogram
  {
private:
   string            m_word[];         // distinct words seen
   int               m_count[];        // occurrences of each word
   int               m_size;           // number of distinct words

   int               IndexOf(const string w) const;

public:
                     CBossHistogram(void) { m_size=0; }

   void              Clear(void);
   //--- add one occurrence of word 'w' (new or existing).
   void              Add(const string w);

   int               Size(void)           const { return m_size; }
   string            WordAt(int i)         const { return (i>=0 && i<m_size)?m_word[i]:""; }
   int               CountAt(int i)        const { return (i>=0 && i<m_size)?m_count[i]:0; }
   //--- count of a specific word, or 0 if absent.
   int               CountOf(const string w) const;

   //--- copy this histogram into 'dst'.
   void              CopyTo(CBossHistogram &dst) const;
  };

//+------------------------------------------------------------------+
//| Linear search for a word; small vocabularies make this cheap.    |
//+------------------------------------------------------------------+
int CBossHistogram::IndexOf(const string w) const
  {
   for(int i=0;i<m_size;i++)
      if(m_word[i]==w)
         return i;
   return -1;
  }

//+------------------------------------------------------------------+
//| Reset to an empty histogram.                                     |
//+------------------------------------------------------------------+
void CBossHistogram::Clear(void)
  {
   ArrayResize(m_word,0);
   ArrayResize(m_count,0);
   m_size=0;
  }

//+------------------------------------------------------------------+
//| Add one occurrence of a word.                                    |
//+------------------------------------------------------------------+
void CBossHistogram::Add(const string w)
  {
   int idx=IndexOf(w);
   if(idx>=0)
     {
      m_count[idx]++;
      return;
     }
   ArrayResize(m_word,m_size+1);
   ArrayResize(m_count,m_size+1);
   m_word[m_size]=w;
   m_count[m_size]=1;
   m_size++;
  }

//+------------------------------------------------------------------+
//| Count of a specific word (0 if absent).                          |
//+------------------------------------------------------------------+
int CBossHistogram::CountOf(const string w) const
  {
   int idx=IndexOf(w);
   return (idx>=0)?m_count[idx]:0;
  }

//+------------------------------------------------------------------+
//| Deep-copy this histogram into 'dst'.                             |
//+------------------------------------------------------------------+
void CBossHistogram::CopyTo(CBossHistogram &dst) const
  {
   dst.Clear();
   for(int i=0;i<m_size;i++)
      for(int c=0;c<m_count[i];c++)   // simple, keeps counts exact
         dst.Add(m_word[i]);
  }

//+------------------------------------------------------------------+
//| CBossTransform - turn a series into a bag of SFA words.          |
//|                                                                  |
//|  Holds one configured, fitted CSFA and slides its window across  |
//|  a series one bar at a time, encoding each window to a word and  |
//|  dropping the words into a histogram. Two BOSS-specific details  |
//|  matter here:                                                    |
//|                                                                  |
//|    - Numerosity reduction: if the window barely moves, the same  |
//|      word repeats on consecutive steps. Counting every repeat    |
//|      would let a long quiet stretch dominate the bag. So a run   |
//|      of identical consecutive words is counted only ONCE. The    |
//|      bag then measures how many DISTINCT pattern occurrences a   |
//|      series contains, not how long each lingers.                 |
//|                                                                  |
//|    - Flat windows are skipped (SFA rejects them); they simply    |
//|      contribute no word.                                         |
//+------------------------------------------------------------------+
class CBossTransform
  {
private:
   CSFA              m_sfa;
   int               m_window;         // sliding window length

public:
                     CBossTransform(void) { m_window=0; }

   //--- configure and fit the underlying SFA in one call. 'windows'
   //--- is the flat training set (count windows of win_len samples).
   //--- Returns false if configuration or fitting fails.
   bool              Build(int word_len,int alphabet,
                           const double &windows[],int count,int win_len);

   bool              IsReady(void)     const { return m_sfa.IsReady(); }
   int               WindowLength(void)const { return m_window; }
   const CSFA        *Sfa(void)         const { return GetPointer(m_sfa); }

   //--- slide across series[0..len-1] (oldest first) and fill 'hist'
   //--- with the numerosity-reduced bag of words. Returns the number
   //--- of words added, or -1 if not ready / series too short.
   int               Transform(const double &series[],int len,
                               CBossHistogram &hist) const;
  };

//+------------------------------------------------------------------+
//| Configure and fit the underlying SFA transform.                  |
//+------------------------------------------------------------------+
bool CBossTransform::Build(int word_len,int alphabet,
                           const double &windows[],int count,int win_len)
  {
   if(!m_sfa.Configure(word_len,alphabet))
      return false;
   if(!m_sfa.Fit(windows,count,win_len))
      return false;
   m_window=win_len;
   return true;
  }

//+------------------------------------------------------------------+
//| Slide the window and build the numerosity-reduced word bag.      |
//+------------------------------------------------------------------+
int CBossTransform::Transform(const double &series[],int len,
                              CBossHistogram &hist) const
  {
   hist.Clear();
   if(!IsReady() || len<m_window || m_window<2)
      return -1;

   double win[];
   ArrayResize(win,m_window);
   int    word[];
   string prev="";                        // last word added (for run collapse)
   int    added=0;
   int    last=len-m_window;

   for(int start=0;start<=last;start++)
     {
      for(int i=0;i<m_window;i++)
         win[i]=series[start+i];

      if(m_sfa.Encode(win,m_window,word)!=SFA_OK)
        {
         prev="";                          // break the run across a flat gap
         continue;
        }

      string w=m_sfa.WordToString(word);
      if(w==prev)
         continue;                         // numerosity reduction: skip repeat

      hist.Add(w);
      prev=w;
      added++;
     }
   return added;
  }

//+------------------------------------------------------------------+
//| CBossClassifier - 1-NN over word bags with the BOSS distance.    |
//|                                                                  |
//|  Training stores one histogram per labelled example series. To   |
//|  classify a query series we transform it to its own histogram    |
//|  and return the label of the nearest training histogram under    |
//|  the BOSS distance.                                              |
//|                                                                  |
//|  The BOSS distance is deliberately NOT symmetric. Between a      |
//|  query bag q and a sample bag s it is                            |
//|      D(q,s) = sum over words w with q[w] > 0 of (q[w]-s[w])^2    |
//|  i.e. an ordinary squared-Euclidean distance, but summed ONLY    |
//|  over words that actually occur in the query. Words that appear  |
//|  only in the sample are ignored. The intuition: a match is       |
//|  judged by whether the sample reproduces the patterns the query  |
//|  contains, not penalised for extra patterns the query never had. |
//|  This asymmetry is a core reason BOSS beats plain Euclidean on   |
//|  noisy series, so it is implemented exactly, not "symmetrised".  |
//+------------------------------------------------------------------+
class CBossClassifier
  {
private:
   CBossTransform    m_transform;
   //--- training set: parallel arrays of histogram and its label.
   CBossHistogram    m_train[];
   string            m_label[];
   int               m_ntrain;

public:
                     CBossClassifier(void) { m_ntrain=0; }

   //--- configure/fit the SFA+bag pipeline from training windows,
   //--- exactly as CBossTransform::Build. Call once before Add().
   bool              Build(int word_len,int alphabet,
                           const double &windows[],int count,int win_len);

   bool              IsReady(void)  const { return m_transform.IsReady(); }
   int               TrainCount(void)const { return m_ntrain; }

   //--- add one labelled training series. It is transformed to a bag
   //--- immediately and stored. Returns false if not ready / empty.
   bool              AddExample(const double &series[],int len,const string label);

   //--- non-symmetric BOSS distance from query bag q to sample bag s.
   static double     BossDistance(const CBossHistogram &q,const CBossHistogram &s);

   //--- classify a query series: label of the nearest training bag.
   //--- 'best_dist' receives that distance. Returns "" if unable.
   string            Classify(const double &series[],int len,double &best_dist) const;

   //--- expose the transform for vocabulary inspection / teaching.
   const CBossTransform *Transform(void) const { return GetPointer(m_transform); }

   //--- read back the i-th stored training pair.
   string            LabelAt(int i)  const { return (i>=0 && i<m_ntrain)?m_label[i]:""; }

   //--- classify a query bag by 1-NN, optionally ignoring one stored
   //--- training index (used by leave-one-out). 'skip' = -1 skips
   //--- nothing. Returns the winning label, or "" if none.
   string            ClassifyBag(const CBossHistogram &q,int skip) const;

   //--- leave-one-out accuracy over the stored training bags: for
   //--- each bag, classify it against all the OTHERS and check the
   //--- label. This is the score the ensemble ranks members by.
   double            LooAccuracy(void) const;
  };

//+------------------------------------------------------------------+
//| Build the underlying transform.                                  |
//+------------------------------------------------------------------+
bool CBossClassifier::Build(int word_len,int alphabet,
                            const double &windows[],int count,int win_len)
  {
   m_ntrain=0;
   ArrayResize(m_train,0);
   ArrayResize(m_label,0);
   return m_transform.Build(word_len,alphabet,windows,count,win_len);
  }

//+------------------------------------------------------------------+
//| Transform one labelled series and store it as a training bag.    |
//+------------------------------------------------------------------+
bool CBossClassifier::AddExample(const double &series[],int len,const string label)
  {
   if(!IsReady() || len<BOSS_MIN_SERIES)
      return false;

   CBossHistogram h;
   if(m_transform.Transform(series,len,h)<0)
      return false;

   ArrayResize(m_train,m_ntrain+1);
   ArrayResize(m_label,m_ntrain+1);
   h.CopyTo(m_train[m_ntrain]);
   m_label[m_ntrain]=label;
   m_ntrain++;
   return true;
  }

//+------------------------------------------------------------------+
//| Non-symmetric BOSS distance from query q to sample s.            |
//|  Sum of squared count differences over words present in q only.  |
//+------------------------------------------------------------------+
double CBossClassifier::BossDistance(const CBossHistogram &q,const CBossHistogram &s)
  {
   double d=0.0;
   int n=q.Size();
   for(int i=0;i<n;i++)
     {
      string w=q.WordAt(i);
      double diff=(double)q.CountAt(i)-(double)s.CountOf(w);
      d+=diff*diff;
     }
   return d;
  }

//+------------------------------------------------------------------+
//| Classify a query series by 1-NN under the BOSS distance.         |
//+------------------------------------------------------------------+
string CBossClassifier::Classify(const double &series[],int len,double &best_dist) const
  {
   best_dist=DBL_MAX;
   if(!IsReady() || m_ntrain<=0 || len<BOSS_MIN_SERIES)
      return "";

   CBossHistogram q;
   if(m_transform.Transform(series,len,q)<0)
      return "";

   string best=ClassifyBag(q,-1);
//--- recover the winning distance for the caller (cheap re-scan)
   for(int i=0;i<m_ntrain;i++)
      if(m_label[i]==best)
        {
         double d=BossDistance(q,m_train[i]);
         if(d<best_dist)
            best_dist=d;
        }
   return best;
  }

//+------------------------------------------------------------------+
//| 1-NN over the stored bags, optionally skipping index 'skip'.     |
//+------------------------------------------------------------------+
string CBossClassifier::ClassifyBag(const CBossHistogram &q,int skip) const
  {
   double best=DBL_MAX;
   string lab="";
   for(int i=0;i<m_ntrain;i++)
     {
      if(i==skip)
         continue;
      double d=BossDistance(q,m_train[i]);
      if(d<best)
        {
         best=d;
         lab=m_label[i];
        }
     }
   return lab;
  }

//+------------------------------------------------------------------+
//| Leave-one-out training accuracy.                                 |
//|  Each stored bag is classified against all the others; the       |
//|  fraction whose predicted label matches the stored one is the    |
//|  member's LOO accuracy. The ensemble keeps only members whose    |
//|  LOO accuracy is close to the best (Schaefer's 92% rule).        |
//+------------------------------------------------------------------+
double CBossClassifier::LooAccuracy(void) const
  {
   if(m_ntrain<2)
      return 0.0;
   int correct=0;
   for(int i=0;i<m_ntrain;i++)
     {
      string pred=ClassifyBag(m_train[i],i);   // skip self
      if(pred==m_label[i])
         correct++;
     }
   return (double)correct/(double)m_ntrain;
  }

//--- maximum ensemble members (one per candidate window size).
#define BOSS_MAX_MEMBERS 16

//--- fraction of the best member's LOO accuracy a member must reach
//--- to be kept in the ensemble (Schaefer 2015 uses 0.92).
#define BOSS_ENSEMBLE_KEEP 0.92

//+------------------------------------------------------------------+
//| CBossEnsemble - the competitive form of BOSS.                    |
//|                                                                  |
//|  A single BOSS classifier commits to one sliding-window length,  |
//|  and the best length is data-dependent and not known in advance. |
//|  The ensemble sidesteps that: it trains one BOSS member at each  |
//|  of several window sizes, measures each member's leave-one-out   |
//|  training accuracy, keeps only the members that come within a    |
//|  fixed fraction (92%) of the best member, and classifies a query |
//|  by MAJORITY VOTE among the survivors.                           |
//|                                                                  |
//|  This is the version the literature reports as accurate; a lone  |
//|  BOSS is knowingly weaker. Training is heavier (several members) |
//|  but each member is still just SFA words plus histogram lookups  |
//|  so classification stays fast relative to elastic matching.      |
//|                                                                  |
//|  Each member owns its MCB breakpoints and labelled bags. Because |
//|  different members use different window sizes, the ensemble is   |
//|  handed the RAW labelled segments and builds every member's own  |
//|  window pool and bags internally.                                |
//+------------------------------------------------------------------+
class CBossEnsemble
  {
private:
   CBossClassifier   m_member[];       // one classifier per kept window size
   int               m_win[];          // that member's window size
   double            m_acc[];          // that member's LOO training accuracy
   int               m_count;          // number of kept members

   //--- flat store of the raw labelled training segments, so each
   //--- member can build its own window pool at its own window size.
   double            m_seg[];          // m_nseg segments of m_seglen
   int               m_lab[];          // integer label per segment
   int               m_nseg;
   int               m_seglen;
   int               m_word_len;
   int               m_alphabet;
   string            m_class_names[];  // integer label -> class name string

   //--- map an integer label to its class name (empty if out of range).
   string            ClassName(int code) const
     { return (code>=0 && code<ArraySize(m_class_names))?m_class_names[code]:""; }

   bool              FitMember(int win_len,CBossClassifier &clf) const;

public:
                     CBossEnsemble(void) { m_count=0; m_nseg=0; }

   //--- train the ensemble. 'segs' holds nseg segments of seglen
   //--- samples (flat, oldest first). 'labels' is one integer label
   //--- per segment. 'wins[]' lists the candidate window sizes to
   //--- try. Members within 92% of the best LOO accuracy are kept.
   //--- Returns false if nothing could be trained.
   bool              Train(const double &segs[],const int &labels[],
                           int nseg,int seglen,
                           int word_len,int alphabet,
                           const int &wins[],int nwin,
                           const string &class_names[]);

   int               MemberCount(void) const { return m_count; }
   int               MemberWindow(int i)const { return (i>=0 && i<m_count)?m_win[i]:0; }
   double            MemberAcc(int i)   const { return (i>=0 && i<m_count)?m_acc[i]:0.0; }

   //--- classify a query segment by majority vote of the kept
   //--- members. Returns the winning label string, or "" if none.
   string            Classify(const double &series[],int len) const;
  };

//+------------------------------------------------------------------+
//| Build one member at a given window size from the stored segments.|
//|  Harvests every sliding window inside every training segment for |
//|  the MCB pool, then adds each segment as one labelled bag.       |
//+------------------------------------------------------------------+
bool CBossEnsemble::FitMember(int win_len,CBossClassifier &clf) const
  {
   if(win_len<2 || win_len>m_seglen)
      return false;

//--- MCB pool: all sliding windows across all training segments.
   int perSeg=m_seglen-win_len+1;
   int poolN=m_nseg*perSeg;
   if(poolN<=0)
      return false;
   double pool[];
   ArrayResize(pool,poolN*win_len);
   int pk=0;
   for(int s=0;s<m_nseg;s++)
      for(int start=0;start<=m_seglen-win_len;start++)
        {
         for(int j=0;j<win_len;j++)
            pool[pk*win_len+j]=m_seg[s*m_seglen+start+j];
         pk++;
        }

   if(!clf.Build(m_word_len,m_alphabet,pool,poolN,win_len))
      return false;

//--- add each training segment as one labelled bag.
   double ex[];
   ArrayResize(ex,m_seglen);
   for(int s=0;s<m_nseg;s++)
     {
      for(int j=0;j<m_seglen;j++)
         ex[j]=m_seg[s*m_seglen+j];
      clf.AddExample(ex,m_seglen,ClassName(m_lab[s]));
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Train the ensemble over the candidate window sizes.              |
//+------------------------------------------------------------------+
bool CBossEnsemble::Train(const double &segs[],const int &labels[],
                          int nseg,int seglen,
                          int word_len,int alphabet,
                          const int &wins[],int nwin,
                          const string &class_names[])
  {
   m_count=0;
   if(nseg<2 || seglen<4 || nwin<1)
      return false;

//--- store the raw segments and configuration.
   m_nseg=nseg;
   m_seglen=seglen;
   m_word_len=word_len;
   m_alphabet=alphabet;
   ArrayResize(m_seg,nseg*seglen);
   ArrayResize(m_lab,nseg);
   for(int i=0;i<nseg*seglen;i++)
      m_seg[i]=segs[i];
   for(int i=0;i<nseg;i++)
      m_lab[i]=labels[i];
   ArrayCopy(m_class_names,class_names);

//--- fit a candidate member at each window size and score it.
   CBossClassifier cand[];
   int    cwin[];
   double cacc[];
   ArrayResize(cand,nwin);
   ArrayResize(cwin,nwin);
   ArrayResize(cacc,nwin);
   int ncand=0;
   double best=0.0;

   for(int w=0;w<nwin && ncand<BOSS_MAX_MEMBERS;w++)
     {
      int win_len=wins[w];
      if(word_len>win_len/2)               // need >= word_len non-DC coeffs
         continue;
      if(!FitMember(win_len,cand[ncand]))
         continue;
      double acc=cand[ncand].LooAccuracy();
      cwin[ncand]=win_len;
      cacc[ncand]=acc;
      if(acc>best)
         best=acc;
      ncand++;
     }
   if(ncand<=0)
      return false;

//--- keep members within 92% of the best LOO accuracy.
   double cut=best*BOSS_ENSEMBLE_KEEP;
   ArrayResize(m_member,ncand);
   ArrayResize(m_win,ncand);
   ArrayResize(m_acc,ncand);
   for(int i=0;i<ncand;i++)
      if(cacc[i]>=cut)
        {
         m_win[m_count]=cwin[i];
         m_acc[m_count]=cacc[i];
         //--- rebuild the kept member into the persistent slot.
         FitMember(cwin[i],m_member[m_count]);
         m_count++;
        }
   return (m_count>0);
  }

//+------------------------------------------------------------------+
//| Classify a query segment by majority vote of the kept members.   |
//|  Ties are broken by the earliest-listed label reaching the top   |
//|  count, which is deterministic given the member order.           |
//+------------------------------------------------------------------+
string CBossEnsemble::Classify(const double &series[],int len) const
  {
   if(m_count<=0)
      return "";

//--- tally votes as (label,count) pairs.
   string vlab[];
   int vcnt[];
   int nv=0;
   ArrayResize(vlab,m_count);
   ArrayResize(vcnt,m_count);

   for(int i=0;i<m_count;i++)
     {
      double bd;
      string lab=m_member[i].Classify(series,len,bd);
      if(lab=="")
         continue;
      int found=-1;
      for(int v=0;v<nv;v++)
         if(vlab[v]==lab)
           {
            found=v;
            break;
           }
      if(found<0)
        {
         vlab[nv]=lab;
         vcnt[nv]=1;
         nv++;
        }
      else
         vcnt[found]++;
     }

   string best="";
   int bestc=-1;
   for(int v=0;v<nv;v++)
      if(vcnt[v]>bestc)
        {
         bestc=vcnt[v];
         best=vlab[v];
        }
   return best;
  }
//+------------------------------------------------------------------+
