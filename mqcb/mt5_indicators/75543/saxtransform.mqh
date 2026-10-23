//+------------------------------------------------------------------+
//|                                                 SAXTransform.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23484 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23484"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Symbolic Aggregate approXimation (SAX) — core transform.         |
//|                                                                  |
//|  A raw window of prices is turned into a short string of letters |
//|  in three steps:                                                 |
//|    1. z-normalize the window          (shape, not price level)   |
//|    2. PAA: average it into 'w' cells  (dimensionality reduction) |
//|    3. map each cell to a letter using equal-probability          |
//|       breakpoints of the standard normal   (discretization)      |
//|                                                                  |
//|  Letters are stored as int codes 0..a-1 (0 = lowest band). The   |
//|  MINDIST routine returns a distance between two words that       |
//|  provably lower-bounds the true Euclidean distance of the        |
//|  z-normalized series — this is what makes SAX search sound.      |
//+------------------------------------------------------------------+

//--- status of a single encode attempt
enum ENUM_SAX_STATUS
  {
   SAX_OK,               // word produced and usable
   SAX_BAD_PARAMS,       // w/a out of range, or len < w
   SAX_FLAT_WINDOW       // stdev ~ 0: window is flat, no meaningful shape
  };

//--- limits kept deliberately small; SAX words are meant to be short
#define SAX_MIN_ALPHABET 2
#define SAX_MAX_ALPHABET 10
#define SAX_FLAT_EPS     1.0e-12   // stdev below this -> treat window as flat

//+------------------------------------------------------------------+
//| CSAXTransform - encodes windows and compares words.              |
//|                                                                  |
//|  One instance is configured once (word length w, alphabet size   |
//|  a) and then reused to encode many windows. The Gaussian         |
//|  breakpoints for the chosen alphabet are built once at Configure |
//|  time and cached.                                                |
//+------------------------------------------------------------------+
class CSAXTransform
  {
private:
   //--- configuration
   int               m_w;              // word length (number of PAA cells / letters)
   int               m_a;              // alphabet size (number of symbols)
   bool              m_ready;          // Configure() succeeded

   //--- cached breakpoints: a-1 cut points that split N(0,1) into
   //--- 'a' equal-probability bands. m_beta[i] is the i-th cut.
   double            m_beta[];

   //--- helpers
   void              BuildBreakpoints(void);
   double            NormInv(double p) const;

public:
                     CSAXTransform(void);

   //--- set word length and alphabet; rebuilds breakpoints. Returns
   //--- false if parameters are out of the supported range.
   bool              Configure(int word_len,int alphabet);

   bool              IsReady(void)   const { return m_ready; }
   int               WordLength(void)const { return m_w; }
   int               Alphabet(void)  const { return m_a; }

   //--- z-normalize src[0..len-1] into dst[]. Returns false on a flat
   //--- window (stdev ~ 0), leaving dst untouched.
   bool              ZNormalize(const double &src[],int len,double &dst[]) const;

   //--- PAA: average 'src' (length len) into 'w' cells -> paa[0..w-1].
   //--- Handles len not divisible by w via fractional cell boundaries.
   bool              PAA(const double &src[],int len,double &paa[]) const;

   //--- full encode: raw window -> integer symbol codes word[0..w-1].
   //--- 'raw' holds len prices in chronological order (oldest first).
   ENUM_SAX_STATUS   Encode(const double &raw[],int len,int &word[]) const;

   //--- map a single z-normalized value to its symbol code 0..a-1.
   int               SymbolOf(double zval) const;

   //--- MINDIST between two words of equal length. Lower-bounds the
   //--- Euclidean distance of the underlying z-normalized series when
   //--- scaled by sqrt(n/w) (see Lin & Keogh, 2003). 'orig_len' is n,
   //--- the length of the original window before PAA.
   double            MinDist(const int &wordA[],const int &wordB[],int orig_len) const;

   //--- distance between two symbol codes under the current alphabet:
   //--- 0 for adjacent/equal bands, otherwise the gap between the
   //--- outer breakpoints they straddle. This is the cell table used
   //--- by MINDIST; exposed for inspection/teaching.
   double            CellDist(int c1,int c2) const;

   //--- render a word as a lowercase letter string ("cbaabdcc") for
   //--- logging and on-chart display.
   string            WordToString(const int &word[]) const;
  };

//+------------------------------------------------------------------+
//| Construct an unconfigured transform.                             |
//+------------------------------------------------------------------+
CSAXTransform::CSAXTransform(void)
  {
   m_w=0;
   m_a=0;
   m_ready=false;
  }

//+------------------------------------------------------------------+
//| Configure word length and alphabet and cache the breakpoints.    |
//+------------------------------------------------------------------+
bool CSAXTransform::Configure(int word_len,int alphabet)
  {
   m_ready=false;
   if(word_len<1)
      return false;
   if(alphabet<SAX_MIN_ALPHABET || alphabet>SAX_MAX_ALPHABET)
      return false;

   m_w=word_len;
   m_a=alphabet;
   BuildBreakpoints();
   m_ready=true;
   return true;
  }

//+------------------------------------------------------------------+
//| Inverse standard-normal CDF (probit) via Acklam's rational       |
//| approximation. Accurate to ~1e-9 over p in (0,1), which is far   |
//| more than the breakpoints need. Returns the z with P(Z<z)=p.     |
//+------------------------------------------------------------------+
double CSAXTransform::NormInv(double p) const
  {
//--- coefficients for Acklam's algorithm
   static const double a1=-3.969683028665376e+01;
   static const double a2= 2.209460984245205e+02;
   static const double a3=-2.759285104469687e+02;
   static const double a4= 1.383577518672690e+02;
   static const double a5=-3.066479806614716e+01;
   static const double a6= 2.506628277459239e+00;

   static const double b1=-5.447609879822406e+01;
   static const double b2= 1.615858368580409e+02;
   static const double b3=-1.556989798598866e+02;
   static const double b4= 6.680131188771972e+01;
   static const double b5=-1.328068155288572e+01;

   static const double c1=-7.784894002430293e-03;
   static const double c2=-3.223964580411365e-01;
   static const double c3=-2.400758277161838e+00;
   static const double c4=-2.549732539343734e+00;
   static const double c5= 4.374664141464968e+00;
   static const double c6= 2.938163982698783e+00;

   static const double d1= 7.784695709041462e-03;
   static const double d2= 3.224671290700398e-01;
   static const double d3= 2.445134137142996e+00;
   static const double d4= 3.754408661907416e+00;

   const double plow =0.02425;
   const double phigh=1.0-plow;

   if(p<=0.0)
      return -DBL_MAX;
   if(p>=1.0)
      return  DBL_MAX;

   double q,r;
   if(p<plow)
     {
      //--- lower tail
      q=MathSqrt(-2.0*MathLog(p));
      return (((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) /
             ((((d1*q+d2)*q+d3)*q+d4)*q+1.0);
     }
   if(p>phigh)
     {
      //--- upper tail
      q=MathSqrt(-2.0*MathLog(1.0-p));
      return -(((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) /
             ((((d1*q+d2)*q+d3)*q+d4)*q+1.0);
     }
//--- central region
   q=p-0.5;
   r=q*q;
   return (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r+a6)*q /
          (((((b1*r+b2)*r+b3)*r+b4)*r+b5)*r+1.0);
  }

//+------------------------------------------------------------------+
//| Build the a-1 breakpoints that split N(0,1) into 'a' bands of    |
//| equal probability 1/a. m_beta[i] = probit((i+1)/a).              |
//+------------------------------------------------------------------+
void CSAXTransform::BuildBreakpoints(void)
  {
   ArrayResize(m_beta,m_a-1);
   for(int i=0;i<m_a-1;i++)
     {
      double p=(double)(i+1)/(double)m_a;
      m_beta[i]=NormInv(p);
     }
  }

//+------------------------------------------------------------------+
//| z-normalize: dst = (src - mean) / stdev. Population stdev used.  |
//| (divide by N), matching the SAX literature. Flat window->false.  |
//+------------------------------------------------------------------+
bool CSAXTransform::ZNormalize(const double &src[],int len,double &dst[]) const
  {
   if(len<1)
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
   var/=len;                       // population variance
   double sd=MathSqrt(var);
   if(sd<SAX_FLAT_EPS)
      return false;                // flat window: no shape to encode

   ArrayResize(dst,len);
   for(int i=0;i<len;i++)
      dst[i]=(src[i]-mean)/sd;
   return true;
  }

//+------------------------------------------------------------------+
//| PAA: reduce 'src' (length len) to 'w' cell averages.             |
//|  When len is a multiple of w each cell is a clean block. When it |
//|  is not, we accumulate with fractional weights so every cell     |
//|  covers exactly len/w points — the standard general-case PAA.    |
//+------------------------------------------------------------------+
bool CSAXTransform::PAA(const double &src[],int len,double &paa[]) const
  {
   if(len<m_w || m_w<1)
      return false;
   ArrayResize(paa,m_w);

   if(len%m_w==0)
     {
      //--- clean blocks: plain averaging
      int blk=len/m_w;
      for(int j=0;j<m_w;j++)
        {
         double s=0.0;
         int base=j*blk;
         for(int k=0;k<blk;k++)
            s+=src[base+k];
         paa[j]=s/blk;
        }
      return true;
     }

//--- general case: each output cell spans len/w input points, but the
//--- span boundaries fall between samples, so points are split by the
//--- fraction of the cell they belong to.
   double cell=(double)len/(double)m_w;
   for(int j=0;j<m_w;j++)
     {
      double lo=j*cell;            // cell start in fractional index units
      double hi=(j+1)*cell;        // cell end
      double s=0.0;
      int    ilo=(int)MathFloor(lo);
      int    ihi=(int)MathCeil(hi)-1;
      for(int i=ilo;i<=ihi && i<len;i++)
        {
         double left =MathMax((double)i,lo);
         double right=MathMin((double)(i+1),hi);
         double wgt  =right-left;  // overlap of sample i with this cell
         if(wgt>0.0)
            s+=src[i]*wgt;
        }
      paa[j]=s/cell;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Map a z-normalized value to its symbol code in 0..a-1.           |
//|  Band 0 is (-inf, beta0), band a-1 is [beta_{a-2}, +inf).        |
//+------------------------------------------------------------------+
int CSAXTransform::SymbolOf(double zval) const
  {
   int c=0;
   while(c<m_a-1 && zval>=m_beta[c])
      c++;
   return c;
  }

//+------------------------------------------------------------------+
//| Full encode: raw window -> integer symbol codes.                 |
//|  raw[0..len-1] is oldest-first. The window is z-normalized, PAA  |
//|  reduced, then each cell mapped to a symbol.                     |
//+------------------------------------------------------------------+
ENUM_SAX_STATUS CSAXTransform::Encode(const double &raw[],int len,int &word[]) const
  {
   if(!m_ready || len<m_w)
      return SAX_BAD_PARAMS;

   double zn[];
   if(!ZNormalize(raw,len,zn))
      return SAX_FLAT_WINDOW;

   double paa[];
   if(!PAA(zn,len,paa))
      return SAX_BAD_PARAMS;

   ArrayResize(word,m_w);
   for(int j=0;j<m_w;j++)
      word[j]=SymbolOf(paa[j]);
   return SAX_OK;
  }

//+------------------------------------------------------------------+
//| Distance between two symbol codes (the MINDIST cell table).      |
//|  Adjacent or equal cells contribute 0; otherwise the distance is |
//|  the gap between the breakpoints that separate them:             |
//|     cell(r,c) = 0                       if |r-c| <= 1            |
//|              = beta[max-1] - beta[min]   otherwise               |
//+------------------------------------------------------------------+
double CSAXTransform::CellDist(int c1,int c2) const
  {
   int hi=(c1>c2)?c1:c2;
   int lo=(c1<c2)?c1:c2;
   if(hi-lo<=1)
      return 0.0;
   return m_beta[hi-1]-m_beta[lo];
  }

//+------------------------------------------------------------------+
//| MINDIST between two SAX words of equal length.                   |
//|  MINDIST = sqrt(n/w) * sqrt( sum_j cell(wordA[j],wordB[j])^2 )   |
//|  where n = orig_len. This provably lower-bounds the Euclidean    |
//|  distance of the two z-normalized series, so a MINDIST above a   |
//|  cutoff guarantees the true distance is above it too — the basis |
//|  for sound pruning in analog search. Returns -1 on mismatch.     |
//+------------------------------------------------------------------+
double CSAXTransform::MinDist(const int &wordA[],const int &wordB[],int orig_len) const
  {
   int n1=ArraySize(wordA);
   int n2=ArraySize(wordB);
   if(n1!=n2 || n1!=m_w || orig_len<m_w)
      return -1.0;

   double sum=0.0;
   for(int j=0;j<m_w;j++)
     {
      double d=CellDist(wordA[j],wordB[j]);
      sum+=d*d;
     }
   return MathSqrt((double)orig_len/(double)m_w)*MathSqrt(sum);
  }

//+------------------------------------------------------------------+
//| Render a word as lowercase letters: code 0 -> 'a', 1 -> 'b', ... |
//+------------------------------------------------------------------+
string CSAXTransform::WordToString(const int &word[]) const
  {
   int n=ArraySize(word);
   string s="";
   for(int j=0;j<n;j++)
      s+=CharToString((uchar)('a'+word[j]));
   return s;
  }
//+------------------------------------------------------------------+
