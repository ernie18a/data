//+------------------------------------------------------------------+
//|                                                    BOSSRegime.mq5|
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23491 |
//+------------------------------------------------------------------+
#property copyright   "MMQ — Muhammad Minhas Qamar"
#property link        "https://www.mql5.com/en/articles/23491"
#property description "A regime-context indicator driven by a BOSS ensemble."
#property version     "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_minimum -0.5
#property indicator_maximum  2.5

//--- one colour-histogram plot; colour index selects the regime hue.
#property indicator_label1  "Regime"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDodgerBlue,clrLimeGreen,clrTomato
#property indicator_width1  3

#include <BOSS\BOSS.mqh>
#include <BOSS\RegimeLabeler.mqh>

//--- training / classification geometry
input int    Segment      = 120;    // bars per classified segment
input int    WordLen      = 2;      // SFA coefficients kept
input int    Alphabet     = 4;      // SFA letters per coefficient slot
input int    TrainBars    = 20000;  // history bars used to train the ensemble
//--- labeler thresholds (balance the training classes)
input double TrendACF     = 0.05;   // lag-1 autocorrelation above this -> TREND
input double VolHighMult  = 1.3;    // volatility above mult*reference -> VOLATILE
input bool   ShowLabel    = true;   // draw a text label of the current regime

//--- plot buffers: value 0/1/2 = regime code, colour index picks hue.
double   RegimeBuffer[];
double   ColorBuffer[];

//--- the trained model and the labeler, built once in OnInit.
CBossEnsemble  g_ensemble;
CRegimeLabeler g_labeler;
bool           g_ready=false;
bool           g_warned=false;   // the thin-history message was printed
int            g_tried=0;        // bar count at the last failed attempt

//--- forward declarations (functions reference each other out of order).
void        SliceSeries(const double &src[],int start,int len,double &out[]);
void        DrawRegimeLabel(ENUM_REGIME r);

//--- colour index per regime, matching indicator_color1 order:
//--- 0 = range (blue), 1 = trend (green), 2 = volatile (red).
int RegimeColorIndex(ENUM_REGIME r)
  {
   switch(r)
     {
      case REGIME_RANGE:
         return 0;
      case REGIME_TREND:
         return 1;
      case REGIME_VOLATILE:
         return 2;
     }
   return 0;
  }

//--- plot height per regime so all three sit on distinct rows:
//--- range=0, trend=1, volatile=2.
double RegimeLevel(ENUM_REGIME r)
  {
   switch(r)
     {
      case REGIME_RANGE:
         return 0.0;
      case REGIME_TREND:
         return 1.0;
      case REGIME_VOLATILE:
         return 2.0;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+
//| Map a class-name string back to its regime enum.                 |
//+------------------------------------------------------------------+
ENUM_REGIME RegimeFromName(const string name)
  {
   if(name=="trend")
      return REGIME_TREND;
   if(name=="volatile")
      return REGIME_VOLATILE;
   return REGIME_RANGE;
  }

//+------------------------------------------------------------------+
//| Train the BOSS ensemble on recent labelled history.              |
//|  Cuts the last TrainBars closed bars of 'src' (oldest first, the |
//|  forming bar excluded by 'closed') into non-overlapping segments,|
//|  labels each by the statistical rule, and trains the ensemble to |
//|  reproduce those labels. Returns false if history/data is thin.  |
//+------------------------------------------------------------------+
bool TrainEnsemble(const double &src[],int closed)
  {
   int got=MathMin(TrainBars,closed);
   if(got<4*Segment)
     {
      if(!g_warned)
         PrintFormat("BOSSRegime: only %d bars, need >= %d; "
                     "waiting for more history",got,4*Segment);
      g_warned=true;
      return false;
     }
   double close[];
   SliceSeries(src,closed-got,got,close);

//--- reference volatility for the labeler = mean segment volatility.
   g_labeler.SetTrendACF(TrendACF);
   g_labeler.SetVolHighMult(VolHighMult);

   int nseg=got/Segment;
   double segbuf[];
   double volsum=0.0;
   for(int s=0;s<nseg;s++)
     {
      SliceSeries(close,s*Segment,Segment,segbuf);
      volsum+=g_labeler.WindowVolatility(segbuf,Segment);
     }
   g_labeler.SetReferenceVol((nseg>0)?volsum/nseg:0.0);

//--- cut and label segments.
   double segs[];
   ArrayResize(segs,nseg*Segment);
   int    labels[];
   ArrayResize(labels,nseg);
   int kept=0, cnt[4]= {0,0,0,0};
   for(int s=0;s<nseg;s++)
     {
      SliceSeries(close,s*Segment,Segment,segbuf);
      ENUM_REGIME r=g_labeler.Label(segbuf,Segment);
      if(r==REGIME_UNDEFINED)
         continue;
      for(int i=0;i<Segment;i++)
         segs[kept*Segment+i]=segbuf[i];
      labels[kept]=(int)r;
      cnt[(int)r]++;
      kept++;
     }
   ArrayResize(segs,kept*Segment);
   ArrayResize(labels,kept);
   if(kept<8)
     {
      Print("BOSSRegime: too few labelled segments to train");
      return false;
     }

//--- candidate window sizes and class names for the ensemble.
   int candWins[]= {12,18,24,32,48,64};
   string classNames[3];
   classNames[REGIME_TREND]   =CRegimeLabeler::RegimeName(REGIME_TREND);
   classNames[REGIME_RANGE]   =CRegimeLabeler::RegimeName(REGIME_RANGE);
   classNames[REGIME_VOLATILE]=CRegimeLabeler::RegimeName(REGIME_VOLATILE);

   if(!g_ensemble.Train(segs,labels,kept,Segment,WordLen,Alphabet,
                        candWins,ArraySize(candWins),classNames))
     {
      Print("BOSSRegime: ensemble training failed");
      return false;
     }

   string keptStr="";
   for(int i=0;i<g_ensemble.MemberCount();i++)
      keptStr+=StringFormat("w%d ",g_ensemble.MemberWindow(i));
   PrintFormat("BOSSRegime trained: %d segs (tr=%d rg=%d vo=%d), members: %s",
               kept,cnt[REGIME_TREND],cnt[REGIME_RANGE],cnt[REGIME_VOLATILE],keptStr);
   return true;
  }

//+------------------------------------------------------------------+
//| Copy a length-'len' slice out of a plain (non-series) array.     |
//+------------------------------------------------------------------+
void SliceSeries(const double &src[],int start,int len,double &out[])
  {
   ArrayResize(out,len);
   for(int i=0;i<len;i++)
      out[i]=src[start+i];
  }

//+------------------------------------------------------------------+
//| Indicator init: bind buffers only.                               |
//|  Training waits for OnCalculate, where the full bar history is   |
//|  guaranteed to be loaded. On a fresh chart or in the tester the  |
//|  history may still be short at init, and the lane simply stays   |
//|  empty until enough bars exist.                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,RegimeBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"BOSS Regime");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   g_ready=false;
   g_warned=false;
   g_tried=0;
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Classify the segment ending at bar 'rpos' (series index into the |
//| non-series close array). Writes the regime code + colour into    |
//| the plot buffers at 'buf_index'. Returns the regime.             |
//+------------------------------------------------------------------+
ENUM_REGIME ClassifyBarSegment(const double &close[],int end_excl,int buf_index)
  {
//--- need Segment closes ending just before end_excl (chronological).
   if(end_excl<Segment)
     {
      RegimeBuffer[buf_index]=EMPTY_VALUE;
      ColorBuffer[buf_index]=0;
      return REGIME_UNDEFINED;
     }
   double seg[];
   SliceSeries(close,end_excl-Segment,Segment,seg);

   string name=g_ensemble.Classify(seg,Segment);
   if(name=="")
     {
      RegimeBuffer[buf_index]=EMPTY_VALUE;
      ColorBuffer[buf_index]=0;
      return REGIME_UNDEFINED;
     }
   ENUM_REGIME r=RegimeFromName(name);
   RegimeBuffer[buf_index]=RegimeLevel(r);
   ColorBuffer[buf_index]=RegimeColorIndex(r);
   return r;
  }

//+------------------------------------------------------------------+
//| Indicator calculation: tag each bar by its trailing segment's    |
//| regime. Only recomputes new bars for efficiency.                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- train on the closed bars once enough of them exist. A failed
//--- attempt is retried after another Segment of bars has arrived,
//--- or when the terminal reloads the history.
   bool fresh=false;
   if(!g_ready)
     {
      if(prev_calculated==0 || rates_total-g_tried>=Segment)
        {
         g_ready=TrainEnsemble(close,rates_total-1);
         g_tried=rates_total;
        }
      if(!g_ready)
        {
         for(int i=(prev_calculated>0)?prev_calculated-1:0;i<rates_total;i++)
           {
            RegimeBuffer[i]=EMPTY_VALUE;
            ColorBuffer[i]=0;
           }
         return rates_total;
        }
      fresh=true;
     }

//--- OnCalculate delivers close[] in chronological order (index 0 =
//--- oldest), which is exactly what segment slicing expects. Index i
//--- is the bar whose trailing Segment closes end at i; bars with no
//--- full segment behind them are left empty.
   int start=(prev_calculated>0 && !fresh)?prev_calculated-1:0;

   ENUM_REGIME lastReg=REGIME_UNDEFINED;
   for(int i=start;i<rates_total;i++)
      lastReg=ClassifyBarSegment(close,i,i);

//--- optional on-chart text label of the most recent regime.
   if(ShowLabel && lastReg!=REGIME_UNDEFINED)
      DrawRegimeLabel(lastReg);

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Draw / update a text label naming the current regime.            |
//+------------------------------------------------------------------+
void DrawRegimeLabel(ENUM_REGIME r)
  {
   string name="BOSSRegimeLabel";
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,12);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,20);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,11);
     }
   color col=clrDodgerBlue;
   if(r==REGIME_TREND)
      col=clrLimeGreen;
   if(r==REGIME_VOLATILE)
      col=clrTomato;
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetString(0,name,OBJPROP_TEXT,
                   "Regime: "+CRegimeLabeler::RegimeName(r));
  }

//+------------------------------------------------------------------+
//| Clean up the text label on removal.                              |
//|  ObjectDelete only removes the object from the list; the chart   |
//|  keeps showing the last-rendered label until it is redrawn, so   |
//|  we force a redraw here to actually clear it.                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"BOSSRegimeLabel");
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
