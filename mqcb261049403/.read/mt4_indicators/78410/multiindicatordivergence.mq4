//+------------------------------------------------------------------+

//|                                     MultiIndicatorDivergence.mq4 |

//|                           Bruno Myrrha & Claude AI (mt4 version) |

//+------------------------------------------------------------------+

//| Purpose:      Finds regular and hidden divergences between price |

//|               and ten oscillators at the latest price pivots,    |

//|               draws a line on the price chart for each one and   |

//|               labels the signal bar with a colored box listing   |

//|               the oscillators that agree and their count.        |

//| Failure mode: Every oscillator is calculated here, so the values |

//|               do not depend on the terminal's built-in versions. |

//|               Volume-based oscillators use tick volume. With the |

//|               default confirmation only closed bars are scanned  |

//|               and the past never changes; a newer signal before  |

//|               the next pivot replaces the previous one.          |

//| Dependencies: none (chart objects and resources only)            |

//| Part of:      MultiIndicatorDivergence indicator                 |

//+------------------------------------------------------------------+



#property copyright "Bruno Nunes Myrrha Ribeiro"

#property link      "https://www.mql5.com/en/users/bruno_myrrha"

#property version   "1.00"

#property description "Regular and hidden divergences between price and ten oscillators: MACD,"

#property description "MACD histogram, RSI, Stochastic, CCI, Momentum, OBV, VWMACD, CMF and MFI."

#property description "Lines on price and a colored box with the oscillators that agree."

#property strict

#property indicator_chart_window

#property indicator_buffers 2

#property indicator_label1  "SMA 50"

#property indicator_color1  C'46,160,110'

#property indicator_label2  "SMA 200"

#property indicator_color2  C'190,70,70'



//+------------------------------------------------------------------+

//| Option lists                                                     |

//+------------------------------------------------------------------+

enum ENUM_PIVOT_SOURCE              // price used for pivots and lines

  {

   PIVOT_CLOSE,                     // close

   PIVOT_WICKS                      // high and low

  };

enum ENUM_DIV_KINDS                 // divergences searched

  {

   KINDS_REGULAR,                   // regular

   KINDS_HIDDEN,                    // hidden

   KINDS_BOTH                       // regular and hidden

  };

enum ENUM_NAME_STYLE                // oscillator names in the box

  {

   NAMES_FULL,                      // full names

   NAMES_LETTER,                    // first letter

   NAMES_NONE                       // no names

  };

enum ENUM_ALERT_KIND                // divergences that raise an alert

  {

   ALERT_OFF,                       // off

   ALERT_REGULAR,                   // regular

   ALERT_HIDDEN,                    // hidden

   ALERT_ANY                        // regular or hidden

  };



//+------------------------------------------------------------------+

//| Inputs: pivots                                                   |

//+------------------------------------------------------------------+

input string SepPivots = "------------";  // ---- Pivots ----

input int               InpSpan   = 5;                // pivot period, bars on each side

input ENUM_PIVOT_SOURCE InpSource = PIVOT_CLOSE;      // pivot source



//+------------------------------------------------------------------+

//| Inputs: divergence search                                        |

//+------------------------------------------------------------------+

input string SepDivergence = "------------";  // ---- Divergence ----

input ENUM_DIV_KINDS InpKinds     = KINDS_REGULAR;    // divergence type

input int            InpMinCount  = 1;                // minimum divergences on a bar

input int            InpMaxPivots = 10;               // pivots checked back

input int            InpMaxReach  = 100;              // bars checked back

input bool           InpConfirm   = true;             // wait for the next bar to confirm

input bool           InpLastOnly  = false;            // keep only the latest divergence

input int            InpHistory   = 2000;             // bars scanned on load



//+------------------------------------------------------------------+

//| Inputs: display                                                  |

//+------------------------------------------------------------------+

input string SepDisplay = "------------";  // ---- Display ----

input ENUM_NAME_STYLE InpNames      = NAMES_FULL;     // oscillator names

input bool            InpShowCount  = true;           // show the divergence count

input bool            InpLines      = true;           // draw divergence lines

input bool            InpPivotMarks = false;          // mark pivot points

input bool            InpAverages   = false;          // show SMA 50 and 200



//+------------------------------------------------------------------+

//| Inputs: oscillators                                              |

//+------------------------------------------------------------------+

input string SepOscillators = "------------";  // ---- Oscillators ----

input bool InpUseMacd   = true;                       // MACD

input bool InpUseHist   = true;                       // MACD histogram

input bool InpUseRsi    = true;                       // RSI

input bool InpUseStoch  = true;                       // Stochastic

input bool InpUseCci    = true;                       // CCI

input bool InpUseMom    = true;                       // Momentum

input bool InpUseObv    = true;                       // OBV

input bool InpUseVwmacd = true;                       // VWMACD

input bool InpUseCmf    = true;                       // Chaikin Money Flow

input bool InpUseMfi    = true;                       // Money Flow Index



//+------------------------------------------------------------------+

//| Inputs: colors                                                   |

//+------------------------------------------------------------------+

input string SepColors = "------------";  // ---- Colors ----

input color InpBullRegular = C'236,178,46';           // bullish regular

input color InpBearRegular = C'44,74,150';            // bearish regular

input color InpBullHidden  = C'72,180,104';           // bullish hidden

input color InpBearHidden  = C'206,64,72';            // bearish hidden

input color InpBullInk     = C'28,28,32';             // bullish box text

input color InpBearInk     = C'250,250,250';          // bearish box text



//+------------------------------------------------------------------+

//| Inputs: alerts                                                   |

//+------------------------------------------------------------------+

input string SepAlerts = "------------";  // ---- Alerts ----

input ENUM_ALERT_KIND InpAlertBull = ALERT_OFF;       // bullish divergence alert

input ENUM_ALERT_KIND InpAlertBear = ALERT_OFF;       // bearish divergence alert

input bool            InpPush      = false;           // also send a push notification



//+------------------------------------------------------------------+

//| Engine constants                                                 |

//+------------------------------------------------------------------+

#define OSCILLATORS  10            // oscillators scanned

#define KINDS        4             // divergence kinds per oscillator

#define PIVOT_SLOTS  20            // pivots remembered on each side

#define MIN_REACH    5             // a pivot must be farther than this

#define NO_VALUE     DBL_MAX       // a value that does not exist yet

#define BULL_REGULAR 0             // kind: bullish regular

#define BEAR_REGULAR 1             // kind: bearish regular

#define BULL_HIDDEN  2             // kind: bullish hidden

#define BEAR_HIDDEN  3             // kind: bearish hidden



//+------------------------------------------------------------------+

//| Settings the engine works with, resolved from the inputs         |

//+------------------------------------------------------------------+

struct ScanRules

  {

   int               span;                  // pivot period

   bool              wicks;                 // pivots and anchors on high/low

   bool              regular;               // search regular divergences

   bool              hidden;                // search hidden divergences

   int               maxPivots;             // pivots checked back

   int               maxReach;              // bars checked back

   bool              liveBar;               // end point is the bar itself

   int               minCount;              // divergences needed on a bar

   bool              lastOnly;              // keep only the newest signal

   bool              marks;                 // remember pivot marks

   ENUM_NAME_STYLE   names;                 // oscillator names in the box

   bool              showCount;             // count at the end of the box

   bool              enabled[OSCILLATORS];  // oscillators switched on

   color             tint[KINDS];           // line and box color per kind

   color             bullInk;               // text color of bullish boxes

   color             bearInk;               // text color of bearish boxes

  };



//+------------------------------------------------------------------+

//| The latest pivots of one side, newest first                      |

//+------------------------------------------------------------------+

struct PivotStack

  {

   int               bar[PIVOT_SLOTS];      // bar index of the pivot

   double            level[PIVOT_SLOTS];    // pivot price

   int               count;                 // slots in use

  };



//+------------------------------------------------------------------+

//| A divergence line on the price chart                             |

//+------------------------------------------------------------------+

struct DivLine

  {

   long              id;                    // unique id, names the object

   int               kind;                  // BULL_REGULAR .. BEAR_HIDDEN

   datetime          from;                  // pivot bar

   double            fromPrice;             // price at the pivot

   datetime          to;                    // end bar

   double            toPrice;               // price at the end

  };



//+------------------------------------------------------------------+

//| A box listing the oscillators that diverge on a bar              |

//+------------------------------------------------------------------+

struct DivBox

  {

   long              id;                    // unique id, names the object

   bool              bear;                  // above the bar, pointing down

   datetime          at;                    // signal bar

   double            price;                 // price the box points to

   string            text;                  // lines separated by \n

   color             fill;                  // background

   color             ink;                   // text color

  };



//+------------------------------------------------------------------+

//| A pivot mark, H above a top or L below a bottom                  |

//+------------------------------------------------------------------+

struct PivotMark

  {

   long              id;                    // unique id, names the object

   bool              top;                   // pivot high

   datetime          at;                    // pivot bar

   double            price;                 // high or low of that bar

  };



//+------------------------------------------------------------------+

//| Everything the drawings are built from                           |

//+------------------------------------------------------------------+

class CDivergenceBook

  {

public:

   PivotStack        highs;

   PivotStack        lows;

   DivLine           bullLines[];

   DivLine           bearLines[];

   DivBox            bullBoxes[];

   DivBox            bearBoxes[];

   PivotMark         marks[];

   int               bullFresh;             // bullish lines since the last low

   int               bearFresh;             // bearish lines since the last high

   long              nextId;

   //--- empties every list

   void              Clear(void);

   //--- takes a full copy of another book

   void              CopyFrom(const CDivergenceBook &src);

  };



//+------------------------------------------------------------------+

//| Resets a book to empty                                           |

//+------------------------------------------------------------------+

void CDivergenceBook::Clear(void)

  {

   highs.count=0;

   lows.count=0;

   ArrayResize(bullLines,0);

   ArrayResize(bearLines,0);

   ArrayResize(bullBoxes,0);

   ArrayResize(bearBoxes,0);

   ArrayResize(marks,0);

   bullFresh=0;

   bearFresh=0;

   nextId=1;

  }



//+------------------------------------------------------------------+

//| Copies one list of lines into another                            |

//+------------------------------------------------------------------+

void CopyLines(DivLine &dst[],const DivLine &src[])

  {

   int n=ArraySize(src);

   ArrayResize(dst,n);

   for(int k=0; k<n; k++)

      dst[k]=src[k];

  }



//+------------------------------------------------------------------+

//| Copies one list of boxes into another                            |

//+------------------------------------------------------------------+

void CopyBoxes(DivBox &dst[],const DivBox &src[])

  {

   int n=ArraySize(src);

   ArrayResize(dst,n);

   for(int k=0; k<n; k++)

      dst[k]=src[k];

  }



//+------------------------------------------------------------------+

//| Copies every list and counter of another book                    |

//+------------------------------------------------------------------+

void CDivergenceBook::CopyFrom(const CDivergenceBook &src)

  {

   highs=src.highs;

   lows=src.lows;

   CopyLines(bullLines,src.bullLines);

   CopyLines(bearLines,src.bearLines);

   CopyBoxes(bullBoxes,src.bullBoxes);

   CopyBoxes(bearBoxes,src.bearBoxes);

   int n=ArraySize(src.marks);

   ArrayResize(marks,n);

   for(int k=0; k<n; k++)

      marks[k]=src.marks[k];

   bullFresh=src.bullFresh;

   bearFresh=src.bearFresh;

   nextId=src.nextId;

  }



//+------------------------------------------------------------------+

//| Average of n values ending at bar i; none if one is missing      |

//+------------------------------------------------------------------+

double MeanAt(const double &v[],const int i,const int n,const int first)

  {

   if(i-n+1<first)

      return(NO_VALUE);

   double sum=0;

   for(int k=i-n+1; k<=i; k++)

     {

      if(v[k]==NO_VALUE)

         return(NO_VALUE);

      sum+=v[k];

     }

   return(sum/n);

  }



//+------------------------------------------------------------------+

//| Exponential average seeded with a simple average of n values     |

//+------------------------------------------------------------------+

double EmaAt(const double &src[],const double &dst[],const int i,const int n,const int first)

  {

   if(src[i]==NO_VALUE)

      return(NO_VALUE);

   if(i>first && dst[i-1]!=NO_VALUE)

     {

      double alpha=2.0/(n+1);

      return(alpha*src[i]+(1-alpha)*dst[i-1]);

     }

   return(MeanAt(src,i,n,first));

  }



//+------------------------------------------------------------------+

//| MACD line, signal (exponential) and histogram at bar i           |

//+------------------------------------------------------------------+

void MacdAt(const double &close[],double &fast[],double &slow[],double &line[],

            double &signal[],double &hist[],const int i,const int first)

  {

   fast[i]=EmaAt(close,fast,i,12,first);

   slow[i]=EmaAt(close,slow,i,26,first);

   line[i]=(fast[i]==NO_VALUE || slow[i]==NO_VALUE) ? NO_VALUE : fast[i]-slow[i];

   signal[i]=EmaAt(line,signal,i,9,first);

   hist[i]=(signal[i]==NO_VALUE) ? NO_VALUE : line[i]-signal[i];

  }



//+------------------------------------------------------------------+

//| RSI 14 with Wilder smoothing of gains and losses                 |

//+------------------------------------------------------------------+

void RsiAt(const double &close[],double &gain[],double &loss[],double &rsi[],

           const int i,const int first)

  {

   const int n=14;

   gain[i]=NO_VALUE;

   loss[i]=NO_VALUE;

   rsi[i]=NO_VALUE;

   if(i-1<first)

      return;

   double up=MathMax(close[i]-close[i-1],0.0);

   double down=MathMax(close[i-1]-close[i],0.0);

   if(gain[i-1]!=NO_VALUE)

     {

      gain[i]=(up+(n-1)*gain[i-1])/n;

      loss[i]=(down+(n-1)*loss[i-1])/n;

     }

   else

     {

      if(i-n<first)

         return;

      double sumUp=0,sumDown=0;

      for(int k=i-n+1; k<=i; k++)

        {

         sumUp+=MathMax(close[k]-close[k-1],0.0);

         sumDown+=MathMax(close[k-1]-close[k],0.0);

        }

      gain[i]=sumUp/n;

      loss[i]=sumDown/n;

     }

   if(loss[i]==0)

      rsi[i]=(gain[i]>0) ? 100 : NO_VALUE;

   else

      rsi[i]=100-100/(1+gain[i]/loss[i]);

  }



//+------------------------------------------------------------------+

//| Stochastic %K 14 and its 3-bar average                           |

//+------------------------------------------------------------------+

void StochAt(const double &high[],const double &low[],const double &close[],double &raw[],

             double &smooth[],const int i,const int first)

  {

   raw[i]=NO_VALUE;

   if(i-13>=first)

     {

      double top=high[i],bottom=low[i];

      for(int k=i-13; k<i; k++)

        {

         top=MathMax(top,high[k]);

         bottom=MathMin(bottom,low[k]);

        }

      if(top>bottom)

         raw[i]=100*(close[i]-bottom)/(top-bottom);

     }

   smooth[i]=MeanAt(raw,i,3,first);

  }



//+------------------------------------------------------------------+

//| CCI 10 on the close                                              |

//+------------------------------------------------------------------+

double CciAt(const double &close[],const int i,const int first)

  {

   double mean=MeanAt(close,i,10,first);

   if(mean==NO_VALUE)

      return(NO_VALUE);

   double dev=0;

   for(int k=i-9; k<=i; k++)

      dev+=MathAbs(close[k]-mean);

   dev/=10;

   return(dev>0 ? (close[i]-mean)/(0.015*dev) : NO_VALUE);

  }



//+------------------------------------------------------------------+

//| Momentum 10 as a price difference                                |

//+------------------------------------------------------------------+

double MomentumAt(const double &close[],const int i,const int first)

  {

   return(i-10>=first ? close[i]-close[i-10] : NO_VALUE);

  }



//+------------------------------------------------------------------+

//| On-balance volume, counted from the first calculated bar         |

//+------------------------------------------------------------------+

double ObvAt(const double &close[],const long &volume[],const double &obv[],const int i,

             const int first)

  {

   if(i<=first || obv[i-1]==NO_VALUE)

      return(0);

   double move=close[i]-close[i-1];

   double sign=(move>0) ? 1 : (move<0 ? -1 : 0);

   return(obv[i-1]+sign*(double)volume[i]);

  }



//+------------------------------------------------------------------+

//| Volume-weighted average of the close over n bars                 |

//+------------------------------------------------------------------+

double VwmaAt(const double &close[],const long &volume[],const int i,const int n,

              const int first)

  {

   if(i-n+1<first)

      return(NO_VALUE);

   double weighted=0,total=0;

   for(int k=i-n+1; k<=i; k++)

     {

      weighted+=close[k]*(double)volume[k];

      total+=(double)volume[k];

     }

   return(total>0 ? weighted/total : NO_VALUE);

  }



//+------------------------------------------------------------------+

//| VWMACD: 12-bar minus 26-bar volume-weighted average              |

//+------------------------------------------------------------------+

double VwmacdAt(const double &close[],const long &volume[],const int i,const int first)

  {

   double fast=VwmaAt(close,volume,i,12,first);

   double slow=VwmaAt(close,volume,i,26,first);

   return((fast==NO_VALUE || slow==NO_VALUE) ? NO_VALUE : fast-slow);

  }



//+------------------------------------------------------------------+

//| Chaikin Money Flow 21; a bar with no range voids the window      |

//+------------------------------------------------------------------+

double CmfAt(const double &high[],const double &low[],const double &close[],

             const long &volume[],const int i,const int first)

  {

   const int n=21;

   if(i-n+1<first)

      return(NO_VALUE);

   double flow=0,total=0;

   for(int k=i-n+1; k<=i; k++)

     {

      double range=high[k]-low[k];

      if(range<=0)

         return(NO_VALUE);

      flow+=((close[k]-low[k])-(high[k]-close[k]))/range*(double)volume[k];

      total+=(double)volume[k];

     }

   return(total>0 ? flow/total : NO_VALUE);

  }



//+------------------------------------------------------------------+

//| Money Flow Index 14 on the close                                 |

//+------------------------------------------------------------------+

double MfiAt(const double &close[],const long &volume[],const int i,const int first)

  {

   const int n=14;

   if(i-n<first)

      return(NO_VALUE);

   double rising=0,falling=0;

   for(int k=i-n+1; k<=i; k++)

     {

      double move=close[k]-close[k-1];

      if(move>0)

         rising+=(double)volume[k]*close[k];

      if(move<0)

         falling+=(double)volume[k]*close[k];

     }

   if(falling==0)

      return(rising>0 ? 100 : NO_VALUE);

   return(100-100/(1+rising/falling));

  }



//+------------------------------------------------------------------+

//| True when both values exist and b lies beyond a in direction dir |

//+------------------------------------------------------------------+

bool Beyond(const double b,const double a,const int dir)

  {

   if(b==NO_VALUE || a==NO_VALUE)

      return(false);

   return(dir>0 ? b>a : b<a);

  }



//+------------------------------------------------------------------+

//| True when bar c is a top (dir +1) or a bottom (dir -1) with span |

//| bars on each side; an equal value is allowed only on the right   |

//+------------------------------------------------------------------+

bool IsTurn(const double &v[],const int c,const int span,const int dir)

  {

   for(int k=1; k<=span; k++)

     {

      if(dir*(v[c]-v[c-k])<=0)

         return(false);

      if(dir*(v[c]-v[c+k])<0)

         return(false);

     }

   return(true);

  }



//+------------------------------------------------------------------+

//| Puts a pivot on top of a stack, dropping the oldest when full    |

//+------------------------------------------------------------------+

void PushPivot(PivotStack &stack,const int bar,const double level)

  {

   for(int k=MathMin(stack.count,PIVOT_SLOTS-1); k>0; k--)

     {

      stack.bar[k]=stack.bar[k-1];

      stack.level[k]=stack.level[k-1];

     }

   stack.bar[0]=bar;

   stack.level[0]=level;

   stack.count=MathMin(stack.count+1,PIVOT_SLOTS);

  }



//+------------------------------------------------------------------+

//| Adds a pivot mark to the book                                    |

//+------------------------------------------------------------------+

void AddMark(CDivergenceBook &book,const bool top,const datetime at,const double price)

  {

   int n=ArraySize(book.marks);

   ArrayResize(book.marks,n+1,256);

   book.marks[n].id=book.nextId++;

   book.marks[n].top=top;

   book.marks[n].at=at;

   book.marks[n].price=price;

  }



//+------------------------------------------------------------------+

//| Records the pivot confirmed at bar (it sits span bars earlier)   |

//+------------------------------------------------------------------+

void TrackPivots(CDivergenceBook &book,const ScanRules &rules,const int bar,

                 const datetime &time[],const double &high[],const double &low[],

                 const double &close[],bool &newTop,bool &newBottom)

  {

   newTop=false;

   newBottom=false;

   int c=bar-rules.span;

   if(c-rules.span<0)

      return;

   newTop=rules.wicks ? IsTurn(high,c,rules.span,1) : IsTurn(close,c,rules.span,1);

   newBottom=rules.wicks ? IsTurn(low,c,rules.span,-1) : IsTurn(close,c,rules.span,-1);

   if(newTop)

     {

      PushPivot(book.highs,c,rules.wicks ? high[c] : close[c]);

      if(rules.marks)

         AddMark(book,true,time[c],high[c]);

     }

   if(newBottom)

     {

      PushPivot(book.lows,c,rules.wicks ? low[c] : close[c]);

      if(rules.marks)

         AddMark(book,false,time[c],low[c]);

     }

  }



//+------------------------------------------------------------------+

//| True when no bar between the two points crosses the straight     |

//| line joining them, in the oscillator or in the close             |

//+------------------------------------------------------------------+

bool ClearPath(const double &osc[],const double &close[],const int bar,const int from,

               const int reach,const int dir)

  {

   double stepOsc=(osc[bar-from]-osc[bar-reach])/(reach-from);

   double stepPx=(close[bar-from]-close[bar-reach])/(reach-from);

   double lineOsc=osc[bar-from]-stepOsc;

   double linePx=close[bar-from]-stepPx;

   for(int k=from+1; k<reach; k++)

     {

      if(Beyond(lineOsc,osc[bar-k],dir) || Beyond(linePx,close[bar-k],dir))

         return(false);

      lineOsc-=stepOsc;

      linePx-=stepPx;

     }

   return(true);

  }



//+------------------------------------------------------------------+

//| Distance in bars to the pivot that forms a divergence, 0 if none |

//| dir +1 looks at bottoms (bullish), -1 at tops (bearish)          |

//+------------------------------------------------------------------+

int SeekPivot(const double &osc[],const double &close[],const double &probe[],

              const int bar,const PivotStack &stack,const ScanRules &rules,

              const int dir,const bool hidden)

  {

   if(!rules.liveBar && !Beyond(osc[bar],osc[bar-1],dir) && !Beyond(close[bar],close[bar-1],dir))

      return(0);

   int from=rules.liveBar ? 0 : 1;

   int end=bar-from;

   int depth=MathMin(rules.maxPivots,stack.count);

   for(int n=0; n<depth; n++)

     {

      int reach=bar-stack.bar[n];

      if(reach>rules.maxReach)

         break;

      if(reach<=MIN_REACH)

         continue;

      int  pivot=stack.bar[n];

      bool shape;

      if(hidden)

         shape=Beyond(osc[pivot],osc[end],dir) && Beyond(probe[end],stack.level[n],dir);

      else

         shape=Beyond(osc[end],osc[pivot],dir) && Beyond(stack.level[n],probe[end],dir);

      if(shape && ClearPath(osc,close,bar,from,reach,dir))

         return(reach);

     }

   return(0);

  }



//+------------------------------------------------------------------+

//| Fills the four kinds of one oscillator with the given probes     |

//+------------------------------------------------------------------+

void ScanSides(const double &osc[],const double &close[],const double &lowProbe[],

               const double &highProbe[],const int bar,const CDivergenceBook &book,

               const ScanRules &rules,int &found[],const int base)

  {

   if(rules.regular)

     {

      found[base+BULL_REGULAR]=SeekPivot(osc,close,lowProbe,bar,book.lows,rules,1,false);

      found[base+BEAR_REGULAR]=SeekPivot(osc,close,highProbe,bar,book.highs,rules,-1,false);

     }

   if(rules.hidden)

     {

      found[base+BULL_HIDDEN]=SeekPivot(osc,close,lowProbe,bar,book.lows,rules,1,true);

      found[base+BEAR_HIDDEN]=SeekPivot(osc,close,highProbe,bar,book.highs,rules,-1,true);

     }

  }



//+------------------------------------------------------------------+

//| Scans one oscillator; found[slot*KINDS+kind] gets the distance   |

//+------------------------------------------------------------------+

void ScanOscillator(const double &osc[],const double &high[],const double &low[],

                    const double &close[],const int bar,const CDivergenceBook &book,

                    const ScanRules &rules,int &found[],const int slot)

  {

   int base=slot*KINDS;

   for(int k=0; k<KINDS; k++)

      found[base+k]=0;

   if(!rules.enabled[slot])

      return;

   if(rules.wicks)

      ScanSides(osc,close,low,high,bar,book,rules,found,base);

   else

      ScanSides(osc,close,close,close,bar,book,rules,found,base);

  }



//+------------------------------------------------------------------+

//| Name of an oscillator in the chosen style                        |

//+------------------------------------------------------------------+

string OscName(const int slot,const ENUM_NAME_STYLE style)

  {

   string full[OSCILLATORS]= {"MACD","Hist","RSI","Stoch","CCI",

                              "MOM","OBV","VWMACD","CMF","MFI"

                             };

   string letter[OSCILLATORS]= {"M","H","R","S","C","M","O","V","C","M"};

   if(style==NAMES_FULL)

      return(full[slot]);

   if(style==NAMES_LETTER)

      return(letter[slot]);

   return("");

  }



//+------------------------------------------------------------------+

//| True when a distance is already in the list, otherwise adds it   |

//+------------------------------------------------------------------+

bool Listed(int &seen[],const int reach)

  {

   int n=ArraySize(seen);

   for(int k=0; k<n; k++)

      if(seen[k]==reach)

         return(true);

   ArrayResize(seen,n+1);

   seen[n]=reach;

   return(false);

  }



//+------------------------------------------------------------------+

//| Removes the lines added since the last pivot and the last box    |

//+------------------------------------------------------------------+

void DropRecent(DivLine &lines[],DivBox &boxes[],const int count)

  {

   int n=ArraySize(lines);

   if(count<=0 || n<count)

      return;

   ArrayResize(lines,n-count);

   int b=ArraySize(boxes);

   if(b>0)

      ArrayResize(boxes,b-1);

  }



//+------------------------------------------------------------------+

//| Adds a line to one side; the first line of a bar first clears    |

//| the provisional lines of that side (or all of them, last only)   |

//+------------------------------------------------------------------+

void AddLine(DivLine &lines[],DivBox &boxes[],int &fresh,bool &touched,const bool lastOnly,

             const DivLine &line)

  {

   if(!touched)

     {

      touched=true;

      if(lastOnly)

         ArrayResize(lines,0);

      else

         if(fresh>0)

           {

            DropRecent(lines,boxes,fresh);

            fresh=0;

           }

     }

   int n=ArraySize(lines);

   ArrayResize(lines,n+1,64);

   lines[n]=line;

   fresh++;

  }



//+------------------------------------------------------------------+

//| Adds a box to one side                                           |

//+------------------------------------------------------------------+

void AddBox(DivBox &boxes[],const bool lastOnly,const DivBox &box)

  {

   if(lastOnly)

      ArrayResize(boxes,0);

   int n=ArraySize(boxes);

   ArrayResize(boxes,n+1,64);

   boxes[n]=box;

  }



//+------------------------------------------------------------------+

//| Price a line ends at: the close, or the low/high with wicks      |

//+------------------------------------------------------------------+

double AnchorPrice(const ScanRules &rules,const bool bear,const int i,const double &high[],

                   const double &low[],const double &close[])

  {

   if(!rules.wicks)

      return(close[i]);

   return(bear ? high[i] : low[i]);

  }



//+------------------------------------------------------------------+

//| Turns the distances found on a bar into lines and boxes; returns |

//| a bit mask of the kinds present (bit = kind)                     |

//+------------------------------------------------------------------+

int RecordBar(CDivergenceBook &book,const ScanRules &rules,const int bar,int &found[],

              const bool newTop,const bool newBottom,const datetime &time[],

              const double &high[],const double &low[],const double &close[])

  {

   int total=0;

   for(int k=0; k<OSCILLATORS*KINDS; k++)

      if(found[k]>0)

         total++;

   if(total<rules.minCount)

      ArrayInitialize(found,0);

   if(newBottom)

      book.bullFresh=0;

   if(newTop)

      book.bearFresh=0;

//--- one line per distinct distance, boxes collect every oscillator

   int    seen[];

   string topText="",bottomText="";

   int    topCount=0,bottomCount=0,mask=0;

   color  topFill=clrWhite,bottomFill=clrWhite;

   bool   bullTouched=false,bearTouched=false;

   int    from=rules.liveBar ? 0 : 1;

   for(int s=0; s<OSCILLATORS; s++)

     {

      int last=-1;

      for(int k=0; k<KINDS; k++)

        {

         int reach=found[s*KINDS+k];

         if(reach<=0)

            continue;

         last=k;

         mask|=(1<<k);

         bool bear=(k%2==1);

         if(bear)

           {

            topCount++;

            topFill=rules.tint[k];

           }

         else

           {

            bottomCount++;

            bottomFill=rules.tint[k];

           }

         if(Listed(seen,reach))

            continue;

         DivLine line;

         line.id=book.nextId++;

         line.kind=k;

         line.from=time[bar-reach];

         line.fromPrice=AnchorPrice(rules,bear,bar-reach,high,low,close);

         line.to=time[bar-from];

         line.toPrice=AnchorPrice(rules,bear,bar-from,high,low,close);

         if(bear)

            AddLine(book.bearLines,book.bearBoxes,book.bearFresh,bearTouched,rules.lastOnly,line);

         else

            AddLine(book.bullLines,book.bullBoxes,book.bullFresh,bullTouched,rules.lastOnly,line);

        }

      if(last<0 || rules.names==NAMES_NONE)

         continue;

      if(last%2==1)

         topText+=OscName(s,rules.names)+"\n";

      else

         bottomText+=OscName(s,rules.names)+"\n";

     }

//--- the boxes, above the bar for bearish and below for bullish

   if(rules.names==NAMES_NONE && !rules.showCount)

      return(mask);

   if(rules.showCount && topCount>0)

      topText+=IntegerToString(topCount);

   if(rules.showCount && bottomCount>0)

      bottomText+=IntegerToString(bottomCount);

   DivBox box;

   box.at=time[bar];

   if(topText!="")

     {

      box.id=book.nextId++;

      box.bear=true;

      box.price=MathMax(high[bar],high[bar-1]);

      box.text=topText;

      box.fill=topFill;

      box.ink=rules.bearInk;

      AddBox(book.bearBoxes,rules.lastOnly,box);

     }

   if(bottomText!="")

     {

      box.id=book.nextId++;

      box.bear=false;

      box.price=MathMin(low[bar],low[bar-1]);

      box.text=bottomText;

      box.fill=bottomFill;

      box.ink=rules.bullInk;

      AddBox(book.bullBoxes,rules.lastOnly,box);

     }

   return(mask);

  }



//+------------------------------------------------------------------+

//| Drawing constants                                                |

//+------------------------------------------------------------------+

#define TAG          "MID_"         // prefix of every chart object

#define WARMUP       400            // extra bars calculated before the scan

#define BOX_FONT     "Arial"        // box text font

#define BOX_POINTS   8              // box text size, points

#define BOX_PAD_X    5              // horizontal padding, pixels

#define BOX_PAD_Y    3              // vertical padding, pixels

#define BOX_TIP      5              // height of the pointer, pixels

#define MARK_TOP     C'206,64,72'   // color of the H pivot mark

#define MARK_BOTTOM  C'72,180,104'  // color of the L pivot mark



//+------------------------------------------------------------------+

//| A chart object drawn on the last render                          |

//+------------------------------------------------------------------+

struct DrawnObject

  {

   long              id;                    // id of the book entry

   string            name;                  // object name

  };



//+------------------------------------------------------------------+

//| A box picture already turned into a resource                     |

//+------------------------------------------------------------------+

struct BoxPicture

  {

   string            key;                   // text, colors and direction

   string            resource;              // resource name

   uint              width;                 // pixels

   uint              height;                // pixels

  };



double        g_avg50[];                    // plot: SMA 50

double        g_avg200[];                   // plot: SMA 200

double        g_emaFast[];                  // MACD fast average

double        g_emaSlow[];                  // MACD slow average

double        g_macd[];                     // oscillator 0: MACD line

double        g_signal[];                   // MACD signal line

double        g_hist[];                     // oscillator 1: MACD histogram

double        g_gain[];                     // RSI average gain

double        g_loss[];                     // RSI average loss

double        g_rsi[];                      // oscillator 2: RSI

double        g_rawK[];                     // Stochastic %K before smoothing

double        g_stoch[];                    // oscillator 3: Stochastic

double        g_cci[];                      // oscillator 4: CCI

double        g_mom[];                      // oscillator 5: Momentum

double        g_obv[];                      // oscillator 6: OBV

double        g_vwmacd[];                   // oscillator 7: VWMACD

double        g_cmf[];                      // oscillator 8: CMF

double        g_mfi[];                      // oscillator 9: MFI

ScanRules       g_rules;                    // engine settings

CDivergenceBook g_done;                     // book after the last closed bar

CDivergenceBook g_view;                     // book including the bar in progress

int           g_doneBar=-1;                 // last closed bar applied

datetime      g_doneTime=0;                 // time of that bar

int           g_calcFrom=0;                 // first bar with oscillator values

DrawnObject   g_drawn[];                    // objects of the last render

BoxPicture    g_pictures[];                 // box resources created

string        g_resTag="";                  // unique prefix of this instance's resources

datetime      g_bullAlerted=0;              // bar of the last bullish alert

datetime      g_bearAlerted=0;              // bar of the last bearish alert



//+------------------------------------------------------------------+

//| Oscillator values of bars from..to                               |

//+------------------------------------------------------------------+

void UpdateOscillators(const int from,const int to,const double &high[],const double &low[],

                       const double &close[],const long &volume[])

  {

   for(int i=from; i<=to; i++)

     {

      MacdAt(close,g_emaFast,g_emaSlow,g_macd,g_signal,g_hist,i,g_calcFrom);

      RsiAt(close,g_gain,g_loss,g_rsi,i,g_calcFrom);

      StochAt(high,low,close,g_rawK,g_stoch,i,g_calcFrom);

      g_cci[i]=CciAt(close,i,g_calcFrom);

      g_mom[i]=MomentumAt(close,i,g_calcFrom);

      g_obv[i]=ObvAt(close,volume,g_obv,i,g_calcFrom);

      g_vwmacd[i]=VwmacdAt(close,volume,i,g_calcFrom);

      g_cmf[i]=CmfAt(high,low,close,volume,i,g_calcFrom);

      g_mfi[i]=MfiAt(close,volume,i,g_calcFrom);

     }

  }



//+------------------------------------------------------------------+

//| Simple averages 50 and 200 of bars from..to                      |

//+------------------------------------------------------------------+

void UpdateAverages(const int from,const int to,const double &close[])

  {

   if(!InpAverages)

      return;

   double sum50=0,sum200=0;

   for(int i=from; i<=to; i++)

     {

      //--- a running sum on a long pass, a direct sum on a single bar

      if(i==from)

        {

         sum50=0;

         sum200=0;

         for(int k=MathMax(0,i-49); k<=i; k++)

            sum50+=close[k];

         for(int k=MathMax(0,i-199); k<=i; k++)

            sum200+=close[k];

        }

      else

        {

         sum50+=close[i]-(i-50>=0 ? close[i-50] : 0);

         sum200+=close[i]-(i-200>=0 ? close[i-200] : 0);

        }

      g_avg50[i]=(i>=49) ? sum50/50 : EMPTY_VALUE;

      g_avg200[i]=(i>=199) ? sum200/200 : EMPTY_VALUE;

     }

  }



//+------------------------------------------------------------------+

//| Applies one bar to a book; returns the kinds found               |

//+------------------------------------------------------------------+

int StepBar(CDivergenceBook &book,const int bar,const datetime &time[],const double &high[],

            const double &low[],const double &close[])

  {

   bool newTop,newBottom;

   TrackPivots(book,g_rules,bar,time,high,low,close,newTop,newBottom);

   int found[OSCILLATORS*KINDS];

   ScanOscillator(g_macd,high,low,close,bar,book,g_rules,found,0);

   ScanOscillator(g_hist,high,low,close,bar,book,g_rules,found,1);

   ScanOscillator(g_rsi,high,low,close,bar,book,g_rules,found,2);

   ScanOscillator(g_stoch,high,low,close,bar,book,g_rules,found,3);

   ScanOscillator(g_cci,high,low,close,bar,book,g_rules,found,4);

   ScanOscillator(g_mom,high,low,close,bar,book,g_rules,found,5);

   ScanOscillator(g_obv,high,low,close,bar,book,g_rules,found,6);

   ScanOscillator(g_vwmacd,high,low,close,bar,book,g_rules,found,7);

   ScanOscillator(g_cmf,high,low,close,bar,book,g_rules,found,8);

   ScanOscillator(g_mfi,high,low,close,bar,book,g_rules,found,9);

   return(RecordBar(book,g_rules,bar,found,newTop,newBottom,time,high,low,close));

  }



//+------------------------------------------------------------------+

//| Words for an alert of one side, empty when it does not apply     |

//+------------------------------------------------------------------+

string AlertWords(const ENUM_ALERT_KIND mode,const bool regular,const bool hidden)

  {

   bool useRegular=regular && (mode==ALERT_REGULAR || mode==ALERT_ANY);

   bool useHidden=hidden && (mode==ALERT_HIDDEN || mode==ALERT_ANY);

   if(useRegular && useHidden)

      return("regular and hidden");

   if(useRegular)

      return("regular");

   if(useHidden)

      return("hidden");

   return("");

  }



//+------------------------------------------------------------------+

//| Name of a timeframe, M1 .. MN1                                   |

//+------------------------------------------------------------------+

string TfName(const int period)

  {

   switch(period)

     {

      case PERIOD_M1:

         return("M1");

      case PERIOD_M5:

         return("M5");

      case PERIOD_M15:

         return("M15");

      case PERIOD_M30:

         return("M30");

      case PERIOD_H1:

         return("H1");

      case PERIOD_H4:

         return("H4");

      case PERIOD_D1:

         return("D1");

      case PERIOD_W1:

         return("W1");

      case PERIOD_MN1:

         return("MN1");

     }

   return(IntegerToString(period));

  }



//+------------------------------------------------------------------+

//| Sends one message as an alert and, if chosen, a push             |

//+------------------------------------------------------------------+

void SendMessage(const string side,const string words)

  {

   string text=StringFormat("%s %s: %s %s divergence",_Symbol,TfName(_Period),side,words);

   Alert(text);

   if(InpPush)

      SendNotification(text);

  }



//+------------------------------------------------------------------+

//| Alerts once per bar and side for the kinds chosen in the inputs  |

//+------------------------------------------------------------------+

void Notify(const int mask,const datetime bar)

  {

   string bull=AlertWords(InpAlertBull,(mask&(1<<BULL_REGULAR))!=0,(mask&(1<<BULL_HIDDEN))!=0);

   string bear=AlertWords(InpAlertBear,(mask&(1<<BEAR_REGULAR))!=0,(mask&(1<<BEAR_HIDDEN))!=0);

   if(bull!="" && g_bullAlerted!=bar)

     {

      g_bullAlerted=bar;

      SendMessage("bullish",bull);

     }

   if(bear!="" && g_bearAlerted!=bar)

     {

      g_bearAlerted=bar;

      SendMessage("bearish",bear);

     }

  }



//+------------------------------------------------------------------+

//| Records an object as drawn on this render                        |

//+------------------------------------------------------------------+

void Keep(DrawnObject &list[],const long id,const string name)

  {

   int n=ArraySize(list);

   ArrayResize(list,n+1,256);

   list[n].id=id;

   list[n].name=name;

  }



//+------------------------------------------------------------------+

//| Paints the box body, its pointer and the text into a picture     |

//+------------------------------------------------------------------+

void PaintBox(uint &pixels[],const uint width,const uint height,const string &rows[],

              const uint rowHeight,const uint fill,const uint ink,const bool pointDown)

  {

   ArrayResize(pixels,width*height);

   ArrayInitialize(pixels,0);

   uint body=height-(uint)BOX_TIP;

   uint top=pointDown ? 0 : (uint)BOX_TIP;

   for(uint y=0; y<body; y++)

      for(uint x=0; x<width; x++)

        {

         //--- cut one pixel off each corner

         bool edgeX=(x==0 || x==width-1);

         bool edgeY=(y==0 || y==body-1);

         if(!(edgeX && edgeY))

            pixels[(top+y)*width+x]=fill;

        }

   uint mid=width/2;

   for(uint r=0; r<BOX_TIP; r++)

     {

      uint half=pointDown ? (uint)BOX_TIP-1-r : r;

      uint y=pointDown ? body+r : r;

      for(uint x=mid-half; x<=mid+half; x++)

         pixels[y*width+x]=fill;

     }

   for(int k=0; k<ArraySize(rows); k++)

      TextOut(rows[k],(int)mid,(int)(top+BOX_PAD_Y+k*rowHeight),TA_CENTER|TA_TOP,pixels,width,

              height,ink,COLOR_FORMAT_ARGB_NORMALIZE);

  }



//+------------------------------------------------------------------+

//| Resource of a box picture, made once per text, color and side    |

//+------------------------------------------------------------------+

string BoxResource(const DivBox &box,uint &width,uint &height)

  {

   string key=box.text+"|"+IntegerToString(box.fill)+"|"+IntegerToString(box.ink)+

              (box.bear ? "|d" : "|u");

   int count=ArraySize(g_pictures);

   for(int k=0; k<count; k++)

      if(g_pictures[k].key==key)

        {

         width=g_pictures[k].width;

         height=g_pictures[k].height;

         return(g_pictures[k].resource);

        }

//--- measure the rows, ignoring a trailing empty one

   string rows[];

   int n=StringSplit(box.text,'\n',rows);

   if(n>0 && rows[n-1]=="")

      ArrayResize(rows,--n);

   TextSetFont(BOX_FONT,-BOX_POINTS*10);

   uint widest=0,rowHeight=0;

   for(int k=0; k<n; k++)

     {

      uint w,h;

      TextGetSize(rows[k],w,h);

      widest=MathMax(widest,w);

      rowHeight=MathMax(rowHeight,h);

     }

   width=widest+2*BOX_PAD_X;

   if(width%2==0)

      width++;

   height=n*rowHeight+2*BOX_PAD_Y+BOX_TIP;

   uint pixels[];

   PaintBox(pixels,width,height,rows,rowHeight,ColorToARGB(box.fill,255),

            ColorToARGB(box.ink,255),box.bear);

   string name=g_resTag+"box"+IntegerToString(count);

   if(!ResourceCreate(name,pixels,width,height,0,0,width,COLOR_FORMAT_ARGB_NORMALIZE))

      PrintFormat("box picture not created, error %d",GetLastError());

   ArrayResize(g_pictures,count+1,32);

   g_pictures[count].key=key;

   g_pictures[count].resource=name;

   g_pictures[count].width=width;

   g_pictures[count].height=height;

   return(name);

  }



//+------------------------------------------------------------------+

//| Creates a divergence line, or moves it when it may have changed  |

//+------------------------------------------------------------------+

void PutLine(DrawnObject &list[],const DivLine &line,const bool mutableEntry)

  {

   string name=TAG+"L"+IntegerToString(line.id);

   bool   fresh=(ObjectFind(0,name)<0);

   if(fresh)

     {

      ObjectCreate(0,name,OBJ_TREND,0,line.from,line.fromPrice,line.to,line.toPrice);

      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);

      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);

      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

     }

   if(fresh || mutableEntry)

     {

      bool regular=(line.kind==BULL_REGULAR || line.kind==BEAR_REGULAR);

      ObjectSetInteger(0,name,OBJPROP_TIME,0,line.from);

      ObjectSetDouble(0,name,OBJPROP_PRICE,0,line.fromPrice);

      ObjectSetInteger(0,name,OBJPROP_TIME,1,line.to);

      ObjectSetDouble(0,name,OBJPROP_PRICE,1,line.toPrice);

      ObjectSetInteger(0,name,OBJPROP_COLOR,g_rules.tint[line.kind]);

      ObjectSetInteger(0,name,OBJPROP_STYLE,regular ? STYLE_SOLID : STYLE_DASH);

      ObjectSetInteger(0,name,OBJPROP_WIDTH,regular ? 2 : 1);

     }

   Keep(list,line.id,name);

  }



//+------------------------------------------------------------------+

//| Creates a box anchored to its bar and price, or refreshes it     |

//+------------------------------------------------------------------+

void PutBox(DrawnObject &list[],const DivBox &box,const bool mutableEntry)

  {

   string name=TAG+"B"+IntegerToString(box.id);

   bool   fresh=(ObjectFind(0,name)<0);

   if(fresh)

     {

      ObjectCreate(0,name,OBJ_BITMAP,0,box.at,box.price);

      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);

      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

      ObjectSetInteger(0,name,OBJPROP_BACK,false);

     }

   if(fresh || mutableEntry)

     {

      uint   width,height;

      string picture=BoxResource(box,width,height);

      string tip=box.text;

      StringReplace(tip,"\n"," ");

      ObjectSetInteger(0,name,OBJPROP_TIME,0,box.at);

      ObjectSetDouble(0,name,OBJPROP_PRICE,0,box.price);

      ObjectSetString(0,name,OBJPROP_BMPFILE,picture);

      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);

      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

      ObjectSetInteger(0,name,OBJPROP_ANCHOR,box.bear ? ANCHOR_LOWER : ANCHOR_UPPER);

      ObjectSetString(0,name,OBJPROP_TOOLTIP,(box.bear ? "Bearish: " : "Bullish: ")+tip);

     }

   Keep(list,box.id,name);

  }



//+------------------------------------------------------------------+

//| Creates a pivot mark, H above a top or L below a bottom          |

//+------------------------------------------------------------------+

void PutMark(DrawnObject &list[],const PivotMark &mark)

  {

   string name=TAG+"P"+IntegerToString(mark.id);

   if(ObjectFind(0,name)<0)

     {

      ObjectCreate(0,name,OBJ_TEXT,0,mark.at,mark.price);

      ObjectSetString(0,name,OBJPROP_TEXT,mark.top ? "H" : "L");

      ObjectSetString(0,name,OBJPROP_FONT,BOX_FONT);

      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,BOX_POINTS);

      ObjectSetInteger(0,name,OBJPROP_COLOR,mark.top ? MARK_TOP : MARK_BOTTOM);

      ObjectSetInteger(0,name,OBJPROP_ANCHOR,mark.top ? ANCHOR_LOWER : ANCHOR_UPPER);

      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);

      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

     }

   Keep(list,mark.id,name);

  }



//+------------------------------------------------------------------+

//| True when a sorted list of ids holds the given id                |

//+------------------------------------------------------------------+

bool IdPresent(const long &ids[],const int count,const long id)

  {

   int lo=0,hi=count-1;

   while(lo<=hi)

     {

      int mid=(lo+hi)/2;

      if(ids[mid]==id)

         return(true);

      if(ids[mid]<id)

         lo=mid+1;

      else

         hi=mid-1;

     }

   return(false);

  }



//+------------------------------------------------------------------+

//| Sizes the calculation arrays (plain arrays, not indicator buffers)|

//+------------------------------------------------------------------+

void ResizeCalc(const int total)

  {

   ArrayResize(g_emaFast,total,1024);

   ArrayResize(g_emaSlow,total,1024);

   ArrayResize(g_macd,total,1024);

   ArrayResize(g_signal,total,1024);

   ArrayResize(g_hist,total,1024);

   ArrayResize(g_gain,total,1024);

   ArrayResize(g_loss,total,1024);

   ArrayResize(g_rsi,total,1024);

   ArrayResize(g_rawK,total,1024);

   ArrayResize(g_stoch,total,1024);

   ArrayResize(g_cci,total,1024);

   ArrayResize(g_mom,total,1024);

   ArrayResize(g_obv,total,1024);

   ArrayResize(g_vwmacd,total,1024);

   ArrayResize(g_cmf,total,1024);

   ArrayResize(g_mfi,total,1024);

  }



//+------------------------------------------------------------------+

//| Redraws a book; entries from fixedBelow on may have changed      |

//+------------------------------------------------------------------+

void Render(const CDivergenceBook &book,const long fixedBelow)

  {

   DrawnObject now[];

   if(InpLines)

     {

      for(int k=0; k<ArraySize(book.bullLines); k++)

         PutLine(now,book.bullLines[k],book.bullLines[k].id>=fixedBelow);

      for(int k=0; k<ArraySize(book.bearLines); k++)

         PutLine(now,book.bearLines[k],book.bearLines[k].id>=fixedBelow);

     }

   for(int k=0; k<ArraySize(book.bullBoxes); k++)

      PutBox(now,book.bullBoxes[k],book.bullBoxes[k].id>=fixedBelow);

   for(int k=0; k<ArraySize(book.bearBoxes); k++)

      PutBox(now,book.bearBoxes[k],book.bearBoxes[k].id>=fixedBelow);

   if(InpPivotMarks)

      for(int k=0; k<ArraySize(book.marks); k++)

         PutMark(now,book.marks[k]);

//--- delete what the book no longer holds

   int  count=ArraySize(now);

   long ids[];

   ArrayResize(ids,count);

   for(int k=0; k<count; k++)

      ids[k]=now[k].id;

   if(count>1)

      ArraySort(ids);

   for(int k=0; k<ArraySize(g_drawn); k++)

      if(!IdPresent(ids,count,g_drawn[k].id))

         ObjectDelete(0,g_drawn[k].name);

   ArrayResize(g_drawn,count);

   for(int k=0; k<count; k++)

      g_drawn[k]=now[k];

   ChartRedraw(0);

  }



//+------------------------------------------------------------------+

//| Deletes every object and picture of the indicator                |

//+------------------------------------------------------------------+

void Wipe(void)

  {

   ObjectsDeleteAll(0,TAG);

   ArrayResize(g_drawn,0);

   for(int k=0; k<ArraySize(g_pictures); k++)

      ResourceFree(g_pictures[k].resource);

   ArrayResize(g_pictures,0);

  }



//+------------------------------------------------------------------+

//| Indicator initialization: checks the inputs, binds the buffers   |

//+------------------------------------------------------------------+

int OnInit(void)

  {

//--- resource names are shared by every copy of the program: make them unique per chart and run

   g_resTag="::"+TAG+IntegerToString(ChartID())+"_"+IntegerToString(GetTickCount())+"_";

   if(InpSpan<1 || InpSpan>50 || InpMinCount<1 || InpMinCount>OSCILLATORS ||

      InpMaxPivots<1 || InpMaxPivots>PIVOT_SLOTS || InpMaxReach<30 || InpMaxReach>200 ||

      InpHistory<100)

     {

      Print("Out of range: pivot period 1-50, minimum 1-10, pivots 1-20, bars back 30-200, ",

            "history 100 or more");

      return(INIT_PARAMETERS_INCORRECT);

     }

   g_rules.span=InpSpan;

   g_rules.wicks=(InpSource==PIVOT_WICKS);

   g_rules.regular=(InpKinds!=KINDS_HIDDEN);

   g_rules.hidden=(InpKinds!=KINDS_REGULAR);

   g_rules.maxPivots=InpMaxPivots;

   g_rules.maxReach=InpMaxReach;

   g_rules.liveBar=!InpConfirm;

   g_rules.minCount=InpMinCount;

   g_rules.lastOnly=InpLastOnly;

   g_rules.marks=InpPivotMarks;

   g_rules.names=InpNames;

   g_rules.showCount=InpShowCount;

   g_rules.enabled[0]=InpUseMacd;

   g_rules.enabled[1]=InpUseHist;

   g_rules.enabled[2]=InpUseRsi;

   g_rules.enabled[3]=InpUseStoch;

   g_rules.enabled[4]=InpUseCci;

   g_rules.enabled[5]=InpUseMom;

   g_rules.enabled[6]=InpUseObv;

   g_rules.enabled[7]=InpUseVwmacd;

   g_rules.enabled[8]=InpUseCmf;

   g_rules.enabled[9]=InpUseMfi;

   g_rules.tint[BULL_REGULAR]=InpBullRegular;

   g_rules.tint[BEAR_REGULAR]=InpBearRegular;

   g_rules.tint[BULL_HIDDEN]=InpBullHidden;

   g_rules.tint[BEAR_HIDDEN]=InpBearHidden;

   g_rules.bullInk=InpBullInk;

   g_rules.bearInk=InpBearInk;

//--- two plot buffers; the calculation arrays are plain global arrays

   SetIndexBuffer(0,g_avg50);

   SetIndexBuffer(1,g_avg200);

   ArraySetAsSeries(g_avg50,false);

   ArraySetAsSeries(g_avg200,false);

   SetIndexLabel(0,"SMA 50");

   SetIndexLabel(1,"SMA 200");

   for(int p=0; p<2; p++)

     {

      SetIndexEmptyValue(p,EMPTY_VALUE);

      SetIndexStyle(p,InpAverages ? DRAW_LINE : DRAW_NONE);

     }

   IndicatorShortName("Multi-Indicator Divergence");

   g_doneBar=-1;

   g_done.Clear();

   Wipe();

   return(INIT_SUCCEEDED);

  }



//+------------------------------------------------------------------+

//| Indicator deinitialization: removes the drawings                 |

//+------------------------------------------------------------------+

void OnDeinit(const int reason)

  {

   Wipe();

   ChartRedraw(0);

  }



//+------------------------------------------------------------------+

//| Indicator iteration: scans closed bars, previews the open one    |

//| only when confirmation is off                                    |

//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],

                const double &open[],const double &high[],const double &low[],

                const double &close[],const long &tick_volume[],const long &volume[],

                const int &spread[])

  {

   int firstScan=2*InpSpan+1;

   if(rates_total<firstScan+2)

      return(0);

//--- the engine counts bars from the oldest (index 0) to the newest

   ArraySetAsSeries(time,false);

   ArraySetAsSeries(high,false);

   ArraySetAsSeries(low,false);

   ArraySetAsSeries(close,false);

   ArraySetAsSeries(tick_volume,false);

   ResizeCalc(rates_total);

   bool restart=(prev_calculated==0 || g_doneBar<0 || g_doneBar>rates_total-2 ||

                 time[g_doneBar]!=g_doneTime);

   int  calcStart=prev_calculated-1;

//--- first run or history changed: start again from a bounded window

   if(restart)

     {

      Wipe();

      g_done.Clear();

      int scanFrom=MathMax(firstScan,rates_total-1-InpHistory);

      g_calcFrom=MathMax(0,scanFrom-InpMaxReach-WARMUP);

      ArrayFill(g_emaFast,0,rates_total,NO_VALUE);

      ArrayFill(g_emaSlow,0,rates_total,NO_VALUE);

      ArrayFill(g_macd,0,rates_total,NO_VALUE);

      ArrayFill(g_signal,0,rates_total,NO_VALUE);

      ArrayFill(g_hist,0,rates_total,NO_VALUE);

      ArrayFill(g_gain,0,rates_total,NO_VALUE);

      ArrayFill(g_loss,0,rates_total,NO_VALUE);

      ArrayFill(g_rsi,0,rates_total,NO_VALUE);

      ArrayFill(g_rawK,0,rates_total,NO_VALUE);

      ArrayFill(g_stoch,0,rates_total,NO_VALUE);

      ArrayFill(g_cci,0,rates_total,NO_VALUE);

      ArrayFill(g_mom,0,rates_total,NO_VALUE);

      ArrayFill(g_obv,0,rates_total,NO_VALUE);

      ArrayFill(g_vwmacd,0,rates_total,NO_VALUE);

      ArrayFill(g_cmf,0,rates_total,NO_VALUE);

      ArrayFill(g_mfi,0,rates_total,NO_VALUE);

      ArrayFill(g_avg50,0,rates_total,EMPTY_VALUE);

      ArrayFill(g_avg200,0,rates_total,EMPTY_VALUE);

      g_doneBar=scanFrom-1;

      calcStart=g_calcFrom;

      UpdateAverages(0,rates_total-1,close);

     }

   else

      UpdateAverages(calcStart,rates_total-1,close);

   UpdateOscillators(calcStart,rates_total-1,high,low,close,tick_volume);

//--- closed bars go into the confirmed book

   bool live=(prev_calculated>0);

   bool changed=restart;

   for(int i=g_doneBar+1; i<=rates_total-2; i++)

     {

      int mask=StepBar(g_done,i,time,high,low,close);

      if(live && i==rates_total-2 && !g_rules.liveBar)

         Notify(mask,time[i]);

      changed=true;

     }

   g_doneBar=rates_total-2;

   g_doneTime=time[g_doneBar];

//--- the bar in progress is applied to a copy, never to the confirmed book

   if(g_rules.liveBar)

     {

      g_view.CopyFrom(g_done);

      int mask=StepBar(g_view,rates_total-1,time,high,low,close);

      if(live)

         Notify(mask,time[rates_total-1]);

      Render(g_view,g_done.nextId);

     }

   else

      if(changed)

         Render(g_done,LONG_MAX);

   return(rates_total);

  }

//+------------------------------------------------------------------+