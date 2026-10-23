//+------------------------------------------------------------------+
//|                                                          SFA.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23491 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23491"
#property version   "1.00"
#property strict

#include <BOSS\FourierTransform.mqh>

//--- alphabet limits. Words are meant to be short and readable, so
//--- the alphabet is kept small: 2..10 letters, the same practical
//--- range used across the symbolic-representation literature.
#define SFA_MIN_ALPHABET 2
#define SFA_MAX_ALPHABET 10

//--- word-length (number of retained coefficients) limits. Each
//--- coefficient contributes one letter, and the DFT of a length-w
//--- window can supply at most floor(w/2) non-DC coefficients.
#define SFA_MIN_WORDLEN  1
#define SFA_MAX_WORDLEN  16

//--- a window whose standard deviation falls below this is treated
//--- as flat: z-normalization would divide by ~0, so no meaningful
//--- shape exists and the window is rejected.
#define SFA_FLAT_EPS     1.0e-12

//--- status of a single encode attempt.
enum ENUM_SFA_STATUS
  {
   SFA_OK,               // word produced and usable
   SFA_NOT_FITTED,       // MCB breakpoints not learned yet
   SFA_BAD_PARAMS,       // word length / alphabet out of range, or len too small
   SFA_FLAT_WINDOW       // stdev ~ 0: window is flat, no meaningful shape
  };

//--- shared z-normalization used by both CMCB and CSFA (defined
//--- below at file scope). Declared here so CMCB::Fit can call it.
bool ZNorm(const double &src[],int len,double &dst[]);

//+------------------------------------------------------------------+
//| CMCB - Multiple Coefficient Binning.                             |
//|                                                                  |
//|  This is the one piece that separates SFA from the older SAX.    |
//|  SAX assumes every value is drawn from a standard normal and     |
//|  cuts the alphabet at fixed Gaussian quantiles. SFA makes no     |
//|  such assumption: it LEARNS the cut points from data, and it     |
//|  learns a SEPARATE set of cuts for each Fourier coefficient,     |
//|  because a low-frequency coefficient and a high-frequency one    |
//|  have very different spreads.                                    |
//|                                                                  |
//|  Fit() takes a pile of training windows, transforms each to its  |
//|  first 'l' coefficients (l = word length x nothing extra; each   |
//|  coefficient is one real and one imaginary value, so there are   |
//|  2l real series to bin). For every one of those 2l positions it  |
//|  collects the value across all windows, sorts them, and places   |
//|  alpha-1 breakpoints at equal-count (equi-depth) quantiles so    |
//|  that each of the 'alpha' letters is used about equally often.   |
//|                                                                  |
//|  The result is a breakpoint table m_break[pos][b], pos in        |
//|  0..2l-1, b in 0..alpha-2. Symbolizing a value is then a simple  |
//|  lookup: count how many breakpoints it exceeds.                  |
//+------------------------------------------------------------------+
class CMCB
  {
private:
   int               m_dims;           // number of real series binned = 2 * word length
   int               m_alphabet;       // letters per position
   bool              m_fitted;         // Fit() succeeded
   //--- breakpoints: m_dims rows, (alphabet-1) columns, ascending.
   //--- flattened row-major: m_break[pos*(alphabet-1) + b].
   double            m_break[];

   double            Quantile(double &sorted[],int n,double q) const;

public:
                     CMCB(void);

   //--- learn breakpoints from 'count' training windows. 'windows'
   //--- is a flat array of count*win_len doubles (window 0 first,
   //--- oldest sample first within each window). 'word_len' is the
   //--- number of non-DC coefficients kept; 'alphabet' the letters
   //--- per position. Windows are z-normalized here before the DFT,
   //--- exactly as they will be at encode time. Returns false on bad
   //--- parameters or if no usable (non-flat) window is supplied.
   bool              Fit(const double &windows[],int count,int win_len,
                         int word_len,int alphabet);

   bool              IsFitted(void)   const { return m_fitted; }
   int               Dimensions(void) const { return m_dims; }
   int               Alphabet(void)   const { return m_alphabet; }

   //--- symbol code 0..alphabet-1 for 'value' at coefficient slot
   //--- 'pos' (0..m_dims-1): the count of learned breakpoints it
   //--- exceeds. Returns 0 if not fitted or pos out of range.
   int               SymbolOf(double value,int pos) const;

   //--- read a single learned breakpoint (pos,b) for inspection or
   //--- teaching. Returns 0.0 if out of range.
   double            Breakpoint(int pos,int b) const;
  };

//+------------------------------------------------------------------+
//| Construct an unfitted binner.                                    |
//+------------------------------------------------------------------+
CMCB::CMCB(void)
  {
   m_dims=0;
   m_alphabet=0;
   m_fitted=false;
  }

//+------------------------------------------------------------------+
//| Linear-interpolated quantile of an ascending sorted array.       |
//+------------------------------------------------------------------+
double CMCB::Quantile(double &sorted[],int n,double q) const
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
//| Learn equi-depth breakpoints for every coefficient slot.         |
//|                                                                  |
//|  For each of the 2*word_len real/imag slots we gather that       |
//|  slot's value from every non-flat training window, sort the      |
//|  collection, and cut it into 'alphabet' equal-count bins. The    |
//|  b-th breakpoint sits at quantile (b+1)/alphabet, so bin 0 holds |
//|  the lowest values, bin alphabet-1 the highest, each with about  |
//|  the same number of training points.                             |
//+------------------------------------------------------------------+
bool CMCB::Fit(const double &windows[],int count,int win_len,
               int word_len,int alphabet)
  {
   m_fitted=false;
   if(count<=0 || win_len<2)
      return false;
   if(word_len<SFA_MIN_WORDLEN || word_len>SFA_MAX_WORDLEN)
      return false;
   if(alphabet<SFA_MIN_ALPHABET || alphabet>SFA_MAX_ALPHABET)
      return false;
   if(word_len>CDFT::MaxCoefficients(win_len))
      return false;

   m_dims=word_len*DFT_REALS_PER_COEFF;
   m_alphabet=alphabet;

//--- transform every training window and stack the coefficient
//--- slots column by column. 'col' holds slot 'pos' across windows.
   double coeffs[];       // reused per window: 2*word_len reals
   double norm[];         // reused per window: z-normalized samples
   double raw[];          // reused per window: raw samples
   ArrayResize(raw,win_len);

   double collected[];    // all values of the current slot, all windows
   ArrayResize(m_break,m_dims*(alphabet-1));

   int usable=0;          // count of non-flat windows actually gathered

//--- first pass builds a compact per-slot matrix. To avoid a second
//--- transform pass we transform once and store all slots, then bin
//--- slot by slot.
   double all[];          // usable*m_dims coefficients, row = window
   ArrayResize(all,count*m_dims);

   for(int wi=0;wi<count;wi++)
     {
      for(int i=0;i<win_len;i++)
         raw[i]=windows[wi*win_len+i];

      if(!ZNorm(raw,win_len,norm))
         continue;                        // skip flat window

      if(!CDFT::LowCoefficients(norm,win_len,word_len,coeffs))
         continue;

      for(int p=0;p<m_dims;p++)
         all[usable*m_dims+p]=coeffs[p];
      usable++;
     }

   if(usable<=0)
      return false;

//--- bin each slot independently.
   ArrayResize(collected,usable);
   for(int p=0;p<m_dims;p++)
     {
      for(int wi=0;wi<usable;wi++)
         collected[wi]=all[wi*m_dims+p];
      ArraySort(collected);

      for(int b=0;b<alphabet-1;b++)
        {
         double q=(double)(b+1)/(double)alphabet;
         m_break[p*(alphabet-1)+b]=Quantile(collected,usable,q);
        }
     }

   m_fitted=true;
   return true;
  }

//+------------------------------------------------------------------+
//| Symbol code for a value at coefficient slot 'pos'.               |
//|  Counts how many of that slot's ascending breakpoints the value  |
//|  is at or above; the count is the letter 0..alphabet-1.          |
//+------------------------------------------------------------------+
int CMCB::SymbolOf(double value,int pos) const
  {
   if(!m_fitted || pos<0 || pos>=m_dims)
      return 0;
   int nb=m_alphabet-1;
   int code=0;
   for(int b=0;b<nb;b++)
     {
      if(value>=m_break[pos*nb+b])
         code++;
      else
         break;                            // breakpoints ascend: stop early
     }
   return code;
  }

//+------------------------------------------------------------------+
//| Read one learned breakpoint, for inspection/teaching.            |
//+------------------------------------------------------------------+
double CMCB::Breakpoint(int pos,int b) const
  {
   if(!m_fitted || pos<0 || pos>=m_dims || b<0 || b>=m_alphabet-1)
      return 0.0;
   return m_break[pos*(m_alphabet-1)+b];
  }

//+------------------------------------------------------------------+
//| Free helper: z-normalize src[0..len-1] into dst[].               |
//|  Returns false on a flat window (stdev below SFA_FLAT_EPS),      |
//|  leaving dst[] resized but unfilled. Defined at file scope so    |
//|  both CMCB and CSFA share one z-norm and cannot drift apart.     |
//+------------------------------------------------------------------+
bool ZNorm(const double &src[],int len,double &dst[])
  {
   if(len<=0)
      return false;
   double mean=0.0;
   for(int i=0;i<len;i++)
      mean+=src[i];
   mean/=len;

   double var=0.0;
   for(int i=0;i<len;i++)
     {
      double d=src[i]-mean;
      var+=d*d;
     }
   var/=len;                               // population variance
   double sd=MathSqrt(var);
   if(sd<SFA_FLAT_EPS)
      return false;

   ArrayResize(dst,len);
   for(int i=0;i<len;i++)
      dst[i]=(src[i]-mean)/sd;
   return true;
  }

//+------------------------------------------------------------------+
//| CSFA - Symbolic Fourier Approximation transform.                 |
//|                                                                  |
//|  Turns a single raw window into a short word of integer letters. |
//|  The pipeline for one window is:                                 |
//|    1. z-normalize        -> compare shape, not price level       |
//|    2. real DFT, keep the first 'word_len' non-DC coefficients    |
//|                          -> low-pass filter that drops noise     |
//|    3. bin each coefficient's real and imaginary part via the     |
//|       fitted MCB table   -> one letter per part                  |
//|  giving a word of 2*word_len letters. Steps 1-2 live in CDFT and |
//|  ZNorm; CSFA owns the MCB table and the letter-per-slot mapping. |
//|                                                                  |
//|  Configure() sets the shape (word length, alphabet) and Fit()    |
//|  learns the breakpoints from training windows. After that the    |
//|  same instance encodes any number of windows cheaply.            |
//+------------------------------------------------------------------+
class CSFA
  {
private:
   int               m_word_len;       // non-DC coefficients kept
   int               m_alphabet;       // letters per slot
   int               m_win_len;        // window length locked at Fit time
   bool              m_ready;          // Configure() succeeded
   CMCB              m_mcb;            // learned breakpoints

public:
                     CSFA(void);

   //--- set word length and alphabet. Returns false if out of range.
   //--- Must be called before Fit().
   bool              Configure(int word_len,int alphabet);

   //--- learn MCB breakpoints from 'count' training windows, each of
   //--- 'win_len' samples, laid out flat (window 0 first, oldest
   //--- sample first). Returns false if not configured, parameters
   //--- clash with win_len, or no non-flat window exists.
   bool              Fit(const double &windows[],int count,int win_len);

   bool              IsReady(void)    const { return m_ready && m_mcb.IsFitted(); }
   int               WordLength(void) const { return m_word_len; }
   int               Alphabet(void)   const { return m_alphabet; }
   int               WindowLength(void)const { return m_win_len; }

   //--- number of letters in an emitted word (= 2 * word length).
   int               SymbolCount(void)const { return m_word_len*DFT_REALS_PER_COEFF; }

   //--- encode one raw window (win_len samples, oldest first) into
   //--- integer letters word[0..2*word_len-1]. Returns SFA_OK, or a
   //--- status describing why no word was produced.
   ENUM_SFA_STATUS   Encode(const double &raw[],int len,int &word[]) const;

   //--- render a letter word as a lowercase string ("cbadba") for
   //--- logging and on-chart display.
   string            WordToString(const int &word[]) const;

   //--- expose the binner for breakpoint inspection / teaching.
   const CMCB        *Binner(void)     const { return GetPointer(m_mcb); }
  };

//+------------------------------------------------------------------+
//| Construct an unconfigured transform.                             |
//+------------------------------------------------------------------+
CSFA::CSFA(void)
  {
   m_word_len=0;
   m_alphabet=0;
   m_win_len=0;
   m_ready=false;
  }

//+------------------------------------------------------------------+
//| Configure word length and alphabet.                              |
//+------------------------------------------------------------------+
bool CSFA::Configure(int word_len,int alphabet)
  {
   m_ready=false;
   if(word_len<SFA_MIN_WORDLEN || word_len>SFA_MAX_WORDLEN)
      return false;
   if(alphabet<SFA_MIN_ALPHABET || alphabet>SFA_MAX_ALPHABET)
      return false;
   m_word_len=word_len;
   m_alphabet=alphabet;
   m_ready=true;
   return true;
  }

//+------------------------------------------------------------------+
//| Learn breakpoints, delegating to the MCB binner.                 |
//+------------------------------------------------------------------+
bool CSFA::Fit(const double &windows[],int count,int win_len)
  {
   if(!m_ready)
      return false;
   if(win_len<2 || m_word_len>CDFT::MaxCoefficients(win_len))
      return false;
   if(!m_mcb.Fit(windows,count,win_len,m_word_len,m_alphabet))
      return false;
   m_win_len=win_len;
   return true;
  }

//+------------------------------------------------------------------+
//| Encode one raw window into a word of integer letters.            |
//+------------------------------------------------------------------+
ENUM_SFA_STATUS CSFA::Encode(const double &raw[],int len,int &word[]) const
  {
   if(!m_ready)
      return SFA_BAD_PARAMS;
   if(!m_mcb.IsFitted())
      return SFA_NOT_FITTED;
   if(len<2 || m_word_len>CDFT::MaxCoefficients(len))
      return SFA_BAD_PARAMS;

   double norm[];
   if(!ZNorm(raw,len,norm))
      return SFA_FLAT_WINDOW;

   double coeffs[];
   if(!CDFT::LowCoefficients(norm,len,m_word_len,coeffs))
      return SFA_BAD_PARAMS;

   int nsym=SymbolCount();
   ArrayResize(word,nsym);
   for(int p=0;p<nsym;p++)
      word[p]=m_mcb.SymbolOf(coeffs[p],p);
   return SFA_OK;
  }

//+------------------------------------------------------------------+
//| Render a letter word as a lowercase string.                      |
//|  Letters beyond 'z' (alphabet>26, not reachable here) would wrap;|
//|  the alphabet cap of 10 keeps every letter in a..j.              |
//+------------------------------------------------------------------+
string CSFA::WordToString(const int &word[]) const
  {
   string s="";
   int n=ArraySize(word);
   for(int i=0;i<n;i++)
     {
      int code=word[i];
      if(code<0)
         code=0;
      s+=CharToString((uchar)('a'+code));
     }
   return s;
  }
//+------------------------------------------------------------------+
