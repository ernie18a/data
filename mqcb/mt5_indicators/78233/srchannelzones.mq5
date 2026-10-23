//+------------------------------------------------------------------+
//|                                               SRChannelZones.mq5 |
//|                                                     Bruno Myrrha |
//+------------------------------------------------------------------+
//| Purpose:      Builds support and resistance channels from the    |
//|                  latest price pivots. Each pivot opens a channel |
//|                   that absorbs the other pivots fitting inside a |
//|                  width limit; a channel scores 20 per pivot plus |
//|                    one per bar whose high or low touched it. The |
//|                 strongest channels that do not overlap are drawn |
//|                 across the chart, colored by where the price is. |
//| Failure mode: Channels are rebuilt only when a new pivot is      |
//|                 confirmed, so they stay fixed between pivots. On |
//|                the bar in progress a pivot and a break can still |
//|                 change until the bar closes; alerts wait for it. |
//| Dependencies: none (chart objects only)                          |
//| Part of:      SRChannelZones indicator                           |
//+------------------------------------------------------------------+

#property copyright "Bruno Nunes Myrrha Ribeiro"
#property link      "https://www.mql5.com/en/users/bruno_myrrha"
#property version   "1.02"
#property description "Support and resistance channels built from price pivots and ranked by"
#property description "strength: pivots inside the channel plus bars that touched it. Colored"
#property description "by price position, with optional pivot marks, break arrows and averages."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_label1  "Average 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  C'52,101,164'
#property indicator_label2  "Average 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  C'214,128,40'
#property indicator_label3  "Resistance break"
#property indicator_type3   DRAW_ARROW
#property indicator_label4  "Support break"
#property indicator_type4   DRAW_ARROW

//+------------------------------------------------------------------+
//| Option lists                                                     |
//+------------------------------------------------------------------+
enum ENUM_PIVOT_PRICE                  // price the pivots are taken from
  {
   PIVOT_WICKS,                        // high and low
   PIVOT_BODY                          // candle body (open and close)
  };
enum ENUM_AVERAGE_KIND                 // moving average drawn
  {
   AVERAGE_OFF,                        // off
   AVERAGE_SIMPLE,                     // simple
   AVERAGE_EXPONENTIAL                 // exponential
  };
enum ENUM_ALERT_MODE                   // how a channel break is reported
  {
   ALERT_OFF,                          // off
   ALERT_POPUP,                        // pop-up
   ALERT_PUSH                          // pop-up and push notification
  };

//+------------------------------------------------------------------+
//| Inputs: pivots                                                   |
//+------------------------------------------------------------------+
input group "Pivots"
input int              InpSpan       = 10;              // pivot period, bars on each side
input ENUM_PIVOT_PRICE InpPivotPrice = PIVOT_WICKS;     // pivot price

//+------------------------------------------------------------------+
//| Inputs: channels                                                 |
//+------------------------------------------------------------------+
input group "Channels"
input int InpWidthPct  = 5;                             // widest channel, % of the 300-bar range
input int InpMinPivots = 1;                             // pivots a channel needs
input int InpMaxZones  = 6;                             // channels shown
input int InpLookback  = 290;                           // bars a pivot stays in use

//+------------------------------------------------------------------+
//| Inputs: colors                                                   |
//+------------------------------------------------------------------+
input group "Colors"
input color InpResistance = C'226,92,74';               // resistance (price below)
input color InpSupport    = C'38,166,154';              // support (price above)
input color InpInside     = C'134,128,170';             // price inside the channel

//+------------------------------------------------------------------+
//| Inputs: marks                                                    |
//+------------------------------------------------------------------+
input group "Marks"
input bool InpPivotMarks = false;                       // mark pivot points
input bool InpBreakMarks = false;                       // mark channel breaks

//+------------------------------------------------------------------+
//| Inputs: averages                                                 |
//+------------------------------------------------------------------+
input group "Averages"
input ENUM_AVERAGE_KIND InpAvgOne    = AVERAGE_OFF;     // average 1
input int               InpAvgOneLen = 50;              // average 1 period
input ENUM_AVERAGE_KIND InpAvgTwo    = AVERAGE_OFF;     // average 2
input int               InpAvgTwoLen = 200;             // average 2 period

//+------------------------------------------------------------------+
//| Inputs: alerts                                                   |
//+------------------------------------------------------------------+
input group "Alerts"
input ENUM_ALERT_MODE InpAlerts = ALERT_OFF;            // channel break alert

//+------------------------------------------------------------------+
//| Engine constants                                                 |
//+------------------------------------------------------------------+
#define ZONE_SLOTS    10           // channels kept after each pivot
#define RANGE_BARS    300          // bars that set the width limit
#define PIVOT_WEIGHT  20           // score of each pivot in a channel
#define FLAG_TOP      1            // a top was confirmed on the bar
#define FLAG_BOTTOM   2            // a bottom was confirmed on the bar
#define FLAG_UP_BREAK 4            // the close left a channel upwards
#define FLAG_DN_BREAK 8            // the close left a channel downwards

//+------------------------------------------------------------------+
//| Settings the engine works with, resolved from the inputs         |
//+------------------------------------------------------------------+
struct ZoneRules
  {
   int               span;         // bars on each side of a pivot
   bool              body;         // pivots on the candle body
   double            widthPct;     // widest channel, % of the range
   int               minPivots;    // pivots a channel needs
   int               lookback;     // bars a pivot stays in use
   int               shown;        // channels drawn and checked
   bool              marks;        // keep pivot marks
  };

//+------------------------------------------------------------------+
//| A pivot mark, H above a top or L below a bottom                  |
//+------------------------------------------------------------------+
struct PivotMark
  {
   int               bar;          // bar of the pivot
   bool              top;          // top or bottom
  };

//+------------------------------------------------------------------+
//| Everything the drawings are built from                           |
//+------------------------------------------------------------------+
class CZoneBook
  {
public:
   double            m_level[];          // pivot prices, oldest first
   int               m_seen[];           // bar each pivot was confirmed on
   double            m_top[ZONE_SLOTS];  // channel tops, strongest first
   double            m_bottom[ZONE_SLOTS];// channel bottoms
   double            m_score[ZONE_SLOTS];// channel scores
   int               m_zones;            // channels found
   int               m_rebuilt;          // bar of the last rebuild
   PivotMark         m_marks[];          // pivot marks, oldest first
   //--- empties the book
   void              Clear(void);
   //--- takes every list and value of another book
   void              CopyFrom(const CZoneBook &src);
  };

//+------------------------------------------------------------------+
//| Resets a book to empty                                           |
//+------------------------------------------------------------------+
void CZoneBook::Clear(void)
  {
   ArrayResize(m_level,0,64);
   ArrayResize(m_seen,0,64);
   ArrayResize(m_marks,0,256);
   ArrayInitialize(m_top,0.0);
   ArrayInitialize(m_bottom,0.0);
   ArrayInitialize(m_score,0.0);
   m_zones=0;
   m_rebuilt=-1;
  }

//+------------------------------------------------------------------+
//| Copies every list and value of another book                      |
//+------------------------------------------------------------------+
void CZoneBook::CopyFrom(const CZoneBook &src)
  {
   ArrayResize(m_level,0,64);
   ArrayResize(m_seen,0,64);
   ArrayResize(m_marks,0,256);
   ArrayCopy(m_level,src.m_level);
   ArrayCopy(m_seen,src.m_seen);
   int count=ArraySize(src.m_marks);
   ArrayResize(m_marks,count,256);
   for(int k=0; k<count; k++)
      m_marks[k]=src.m_marks[k];
   ArrayCopy(m_top,src.m_top);
   ArrayCopy(m_bottom,src.m_bottom);
   ArrayCopy(m_score,src.m_score);
   m_zones=src.m_zones;
   m_rebuilt=src.m_rebuilt;
  }

//+------------------------------------------------------------------+
//| First bar the engine can step: it needs the 300-bar range, the   |
//| lookback and both sides of a pivot                               |
//+------------------------------------------------------------------+
int FirstBar(const ZoneRules &rules)
  {
   return(MathMax(RANGE_BARS-1,MathMax(rules.lookback,2*rules.span)));
  }

//+------------------------------------------------------------------+
//| Price a pivot is measured on: the wick, or the body edge         |
//+------------------------------------------------------------------+
double TurnPrice(const double &open[],const double &high[],const double &low[],
                 const double &close[],const int i,const int dir,const bool body)
  {
   if(body)
      return(dir>0 ? MathMax(open[i],close[i]) : MathMin(open[i],close[i]));
   return(dir>0 ? high[i] : low[i]);
  }

//+------------------------------------------------------------------+
//| True when bar c is a top (dir +1) or a bottom (dir -1) with span |
//| bars on each side; an equal value is allowed only on the right   |
//+------------------------------------------------------------------+
bool IsTurn(const double &open[],const double &high[],const double &low[],
            const double &close[],const int c,const int span,const int dir,const bool body)
  {
   double peak=TurnPrice(open,high,low,close,c,dir,body);
   for(int k=1; k<=span; k++)
     {
      if(dir*(peak-TurnPrice(open,high,low,close,c-k,dir,body))<=0)
         return(false);
      if(dir*(peak-TurnPrice(open,high,low,close,c+k,dir,body))<0)
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Stores a pivot and forgets the ones older than the lookback      |
//+------------------------------------------------------------------+
void AddPivot(CZoneBook &book,const int bar,const double level,const int lookback)
  {
   int count=ArraySize(book.m_level);
   ArrayResize(book.m_level,count+1,64);
   ArrayResize(book.m_seen,count+1,64);
   book.m_level[count]=level;
   book.m_seen[count]=bar;
   int stale=0;
   while(stale<=count && bar-book.m_seen[stale]>lookback)
      stale++;
   if(stale>0)
     {
      ArrayRemove(book.m_level,0,stale);
      ArrayRemove(book.m_seen,0,stale);
     }
  }

//+------------------------------------------------------------------+
//| Grows a channel from one pivot: walking from the newest pivot to |
//| the oldest, each one that keeps the channel within the limit is  |
//| taken in; returns the number of pivots taken                     |
//+------------------------------------------------------------------+
int GrowChannel(const CZoneBook &book,const int seed,const double limit,
                double &upper,double &lower)
  {
   upper=book.m_level[seed];
   lower=upper;
   int members=0;
   for(int k=ArraySize(book.m_level)-1; k>=0; k--)
     {
      double level=book.m_level[k];
      double reach=(level<=upper) ? upper-level : level-lower;
      if(reach>limit)
         continue;
      if(level<=upper)
         lower=MathMin(lower,level);
      else
         upper=MathMax(upper,level);
      members++;
     }
   return(members);
  }

//+------------------------------------------------------------------+
//| Bars from bar-depth to bar whose high or low lies in the channel |
//+------------------------------------------------------------------+
int CountTouches(const double &high[],const double &low[],const int bar,const int depth,
                 const double upper,const double lower)
  {
   int hits=0;
   for(int i=bar-depth; i<=bar; i++)
      if((high[i]<=upper && high[i]>=lower) || (low[i]<=upper && low[i]>=lower))
         hits++;
   return(hits);
  }

//+------------------------------------------------------------------+
//| Rebuilds the channel list on bar: one candidate per pivot, then  |
//| the best scores are taken in turn, each one removing candidates  |
//| that have an edge inside it                                      |
//+------------------------------------------------------------------+
void RebuildZones(CZoneBook &book,const ZoneRules &rules,const double &high[],
                  const double &low[],const int bar)
  {
   int    count=ArraySize(book.m_level);
   int    oldest=bar-RANGE_BARS+1;
   double rangeHigh=high[ArrayMaximum(high,oldest,RANGE_BARS)];
   double rangeLow=low[ArrayMinimum(low,oldest,RANGE_BARS)];
   double limit=(rangeHigh-rangeLow)*rules.widthPct/100.0;
   double upper[],lower[],score[];
   ArrayResize(upper,count);
   ArrayResize(lower,count);
   ArrayResize(score,count);
//--- candidate c is built from the c-th newest pivot
   for(int c=0; c<count; c++)
     {
      int members=GrowChannel(book,count-1-c,limit,upper[c],lower[c]);
      score[c]=members*PIVOT_WEIGHT+CountTouches(high,low,bar,rules.lookback,upper[c],lower[c]);
     }
   double need=rules.minPivots*PIVOT_WEIGHT;
   book.m_zones=0;
   ArrayInitialize(book.m_top,0.0);
   ArrayInitialize(book.m_bottom,0.0);
   ArrayInitialize(book.m_score,0.0);
   while(book.m_zones<ZONE_SLOTS)
     {
      int    best=-1;
      double bestScore=-1.0;
      for(int c=0; c<count; c++)
         if(score[c]>bestScore && score[c]>=need)
           {
            best=c;
            bestScore=score[c];
           }
      if(best<0)
         break;
      double top=upper[best];
      double bottom=lower[best];
      book.m_top[book.m_zones]=top;
      book.m_bottom[book.m_zones]=bottom;
      book.m_score[book.m_zones]=bestScore;
      book.m_zones++;
      for(int c=0; c<count; c++)
         if((upper[c]<=top && upper[c]>=bottom) || (lower[c]<=top && lower[c]>=bottom))
            score[c]=-1.0;
     }
   book.m_rebuilt=bar;
  }

//+------------------------------------------------------------------+
//| Break flags of bar: none while the close sits inside a channel   |
//| shown; otherwise a close crossing a top or a bottom              |
//+------------------------------------------------------------------+
int BreakFlags(const CZoneBook &book,const ZoneRules &rules,const double &close[],
               const int bar)
  {
   int used=MathMin(book.m_zones,rules.shown);
   for(int k=0; k<used; k++)
      if(close[bar]<=book.m_top[k] && close[bar]>=book.m_bottom[k])
         return(0);
   int flags=0;
   for(int k=0; k<used; k++)
     {
      if(close[bar-1]<=book.m_top[k] && close[bar]>book.m_top[k])
         flags|=FLAG_UP_BREAK;
      if(close[bar-1]>=book.m_bottom[k] && close[bar]<book.m_bottom[k])
         flags|=FLAG_DN_BREAK;
     }
   return(flags);
  }

//+------------------------------------------------------------------+
//| Adds a pivot mark to the book                                    |
//+------------------------------------------------------------------+
void AddMark(CZoneBook &book,const int bar,const bool top)
  {
   int count=ArraySize(book.m_marks);
   ArrayResize(book.m_marks,count+1,256);
   book.m_marks[count].bar=bar;
   book.m_marks[count].top=top;
  }

//+------------------------------------------------------------------+
//| Applies one bar to a book; returns its FLAG_ bits                |
//+------------------------------------------------------------------+
int StepBar(CZoneBook &book,const ZoneRules &rules,const int bar,const double &open[],
            const double &high[],const double &low[],const double &close[])
  {
   int  center=bar-rules.span;
   bool top=IsTurn(open,high,low,close,center,rules.span,1,rules.body);
   bool bottom=IsTurn(open,high,low,close,center,rules.span,-1,rules.body);
   int  flags=(top ? FLAG_TOP : 0)|(bottom ? FLAG_BOTTOM : 0);
   if(rules.marks)
     {
      if(top)
         AddMark(book,center,true);
      if(bottom)
         AddMark(book,center,false);
     }
//--- a top wins when one bar is both
   if(top || bottom)
     {
      double level=TurnPrice(open,high,low,close,center,top ? 1 : -1,rules.body);
      AddPivot(book,bar,level,rules.lookback);
      RebuildZones(book,rules,high,low,bar);
     }
   return(flags|BreakFlags(book,rules,close,bar));
  }

//+------------------------------------------------------------------+
//| Drawing constants                                                |
//+------------------------------------------------------------------+
#define TAG          "SRZ_"        // prefix of every object
#define ZONE_OPACITY 0.25          // channel color over the background
#define ZONE_REACH   500           // bars a channel runs past the last
#define SCAN_BARS    5000          // closed bars scanned on load
#define MARK_FONT    "Arial"       // pivot mark font
#define MARK_POINTS  8             // pivot mark size
#define ARROW_UP     233           // Wingdings up arrow
#define ARROW_DOWN   234           // Wingdings down arrow
#define ARROW_GAP    12            // arrow distance from the bar, px

//+------------------------------------------------------------------+
//| Global state                                                     |
//+------------------------------------------------------------------+
ZoneRules g_rules;                 // settings resolved from inputs
CZoneBook g_done;                  // book of the closed bars
CZoneBook g_view;                  // closed bars plus the open one
int       g_doneBar=-1;            // last closed bar in g_done
datetime  g_doneTime=0;            // its open time
int       g_exactFrom=0;           // first bar with a complete book
datetime  g_alerted=0;             // bar of the last alert
int       g_markCount=-1;          // marks drawn on the last render
long      g_markLast=-1;           // id of the newest mark drawn
double    g_avgOne[];              // average 1
double    g_avgTwo[];              // average 2
double    g_upBreak[];             // resistance break arrows
double    g_downBreak[];           // support break arrows

//+------------------------------------------------------------------+
//| A color mixed with the chart background, as if see-through       |
//+------------------------------------------------------------------+
color Tint(const color ink,const double opacity)
  {
   color  paper=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   int    mix[3];
   for(int k=0; k<3; k++)
     {
      int fore=(int)((ink>>(8*k))&0xFF);
      int back=(int)((paper>>(8*k))&0xFF);
      mix[k]=(int)MathRound(back+(fore-back)*opacity);
     }
   return((color)(mix[0]|(mix[1]<<8)|(mix[2]<<16)));
  }

//+------------------------------------------------------------------+
//| Simple or exponential average of the close, bars from..total-1   |
//+------------------------------------------------------------------+
void UpdateAverage(double &line[],const ENUM_AVERAGE_KIND kind,const int length,
                   const double &close[],const int from,const int total)
  {
   if(kind==AVERAGE_OFF)
      return;
   bool   exponential=(kind==AVERAGE_EXPONENTIAL);
   double alpha=2.0/(length+1);
   for(int i=MathMax(from,0); i<total; i++)
     {
      if(i<length-1)
        {
         line[i]=EMPTY_VALUE;
         continue;
        }
      if(exponential && i>=length && line[i-1]!=EMPTY_VALUE)
        {
         line[i]=alpha*close[i]+(1.0-alpha)*line[i-1];
         continue;
        }
      double sum=0.0;
      for(int k=i-length+1; k<=i; k++)
         sum+=close[k];
      line[i]=sum/length;
     }
  }

//+------------------------------------------------------------------+
//| Writes the break arrows of a bar                                 |
//+------------------------------------------------------------------+
void PlaceBreaks(const int bar,const int flags,const double &high[],const double &low[])
  {
   bool show=(InpBreakMarks && bar>=g_exactFrom);
   g_upBreak[bar]=(show && (flags&FLAG_UP_BREAK)!=0) ? low[bar] : EMPTY_VALUE;
   g_downBreak[bar]=(show && (flags&FLAG_DN_BREAK)!=0) ? high[bar] : EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Alerts once per closed bar when a channel breaks                 |
//+------------------------------------------------------------------+
void Notify(const int flags,const datetime bar)
  {
   if(InpAlerts==ALERT_OFF || (flags&(FLAG_UP_BREAK|FLAG_DN_BREAK))==0 || g_alerted==bar)
      return;
   g_alerted=bar;
   string what=((flags&FLAG_UP_BREAK)!=0) ? "resistance broken" : "support broken";
   if((flags&FLAG_UP_BREAK)!=0 && (flags&FLAG_DN_BREAK)!=0)
      what="resistance and support broken";
   string text=StringFormat("%s %s: %s",_Symbol,
                            StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),what);
   Alert(text);
   if(InpAlerts==ALERT_PUSH)
      SendNotification(text);
  }

//+------------------------------------------------------------------+
//| Creates or updates one channel band across the whole chart       |
//+------------------------------------------------------------------+
void PutZone(const int slot,const double top,const double bottom,const datetime from,
             const datetime to,const color ink)
  {
   string name=TAG+"Z"+IntegerToString(slot);
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,from,top,to,bottom);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,from);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,top);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,to);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,bottom);
   ObjectSetInteger(0,name,OBJPROP_COLOR,ink);
//--- a one-pivot channel has no height: its outline keeps it visible
   ObjectSetInteger(0,name,OBJPROP_FILL,top>bottom);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,
                   StringFormat("%s - %s",DoubleToString(bottom,_Digits),
                                DoubleToString(top,_Digits)));
  }

//+------------------------------------------------------------------+
//| Creates a pivot mark, H above a top or L below a bottom          |
//+------------------------------------------------------------------+
void PutMark(const PivotMark &mark,const datetime &time[],const double &high[],
             const double &low[])
  {
   string name=TAG+"P"+IntegerToString(mark.bar)+(mark.top ? "H" : "L");
   if(ObjectFind(0,name)>=0)
      return;
   ObjectCreate(0,name,OBJ_TEXT,0,time[mark.bar],mark.top ? high[mark.bar] : low[mark.bar]);
   ObjectSetString(0,name,OBJPROP_TEXT,mark.top ? "H" : "L");
   ObjectSetString(0,name,OBJPROP_FONT,MARK_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,MARK_POINTS);
   ObjectSetInteger(0,name,OBJPROP_COLOR,mark.top ? InpResistance : InpSupport);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,mark.top ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Draws a book: the channels, colored by the last close, and the   |
//| pivot marks; deletes what the book no longer holds               |
//+------------------------------------------------------------------+
void Render(const CZoneBook &book,const datetime &time[],const double &high[],
            const double &low[],const int last,const double price)
  {
   int      used=MathMin(book.m_zones,g_rules.shown);
   datetime to=time[last]+(datetime)ZONE_REACH*PeriodSeconds();
   for(int k=0; k<used; k++)
     {
      double top=book.m_top[k];
      double bottom=book.m_bottom[k];
      color  ink=(top>price && bottom>price) ? InpResistance :
                 (top<price && bottom<price) ? InpSupport : InpInside;
      PutZone(k,top,bottom,time[0],to,Tint(ink,ZONE_OPACITY));
     }
   for(int k=used; k<ZONE_SLOTS; k++)
      ObjectDelete(0,TAG+"Z"+IntegerToString(k));
//--- marks change only when a pivot is added or the open bar drops one
   int  count=ArraySize(book.m_marks);
   long newest=(count>0) ? 2*(long)book.m_marks[count-1].bar+(book.m_marks[count-1].top ? 1 : 0) : -1;
   if(count!=g_markCount || newest!=g_markLast)
     {
      ObjectsDeleteAll(0,TAG+"P");
      for(int k=0; k<count; k++)
         PutMark(book.m_marks[k],time,high,low);
      g_markCount=count;
      g_markLast=newest;
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Deletes every object of the indicator                            |
//+------------------------------------------------------------------+
void Wipe(void)
  {
   ObjectsDeleteAll(0,TAG);
   g_markCount=-1;
   g_markLast=-1;
  }

//+------------------------------------------------------------------+
//| Indicator initialization: checks the inputs, binds the buffers   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpSpan<4 || InpSpan>30 || InpWidthPct<1 || InpWidthPct>8 || InpMinPivots<1 ||
      InpMaxZones<1 || InpMaxZones>ZONE_SLOTS || InpLookback<100 || InpLookback>400 ||
      InpAvgOneLen<1 || InpAvgTwoLen<1)
     {
      Print("Out of range: pivot period 4-30, width 1-8, pivots 1 or more, channels 1-10, ",
            "lookback 100-400, average periods 1 or more");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_rules.span=InpSpan;
   g_rules.body=(InpPivotPrice==PIVOT_BODY);
   g_rules.widthPct=InpWidthPct;
   g_rules.minPivots=InpMinPivots;
   g_rules.lookback=InpLookback;
   g_rules.shown=InpMaxZones;
   g_rules.marks=InpPivotMarks;
//--- averages, then the break arrows
   SetIndexBuffer(0,g_avgOne,INDICATOR_DATA);
   SetIndexBuffer(1,g_avgTwo,INDICATOR_DATA);
   SetIndexBuffer(2,g_upBreak,INDICATOR_DATA);
   SetIndexBuffer(3,g_downBreak,INDICATOR_DATA);
   for(int p=0; p<4; p++)
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,StringFormat("%s %d",InpAvgOne==AVERAGE_EXPONENTIAL ? "EMA" : "SMA",InpAvgOneLen));
   PlotIndexSetString(1,PLOT_LABEL,StringFormat("%s %d",InpAvgTwo==AVERAGE_EXPONENTIAL ? "EMA" : "SMA",InpAvgTwoLen));
   if(InpAvgOne==AVERAGE_OFF)
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   if(InpAvgTwo==AVERAGE_OFF)
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(2,PLOT_ARROW,ARROW_UP);
   PlotIndexSetInteger(3,PLOT_ARROW,ARROW_DOWN);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,ARROW_GAP);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-ARROW_GAP);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpSupport);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,InpResistance);
   IndicatorSetString(INDICATOR_SHORTNAME,"S/R Channel Zones");
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
//| Indicator iteration: closed bars go into the confirmed book, the |
//| open bar is applied to a copy that is then drawn                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   int first=FirstBar(g_rules);
   if(rates_total<first+2)
      return(0);
   bool restart=(prev_calculated==0 || g_doneBar<0 || g_doneBar>rates_total-2 ||
                 time[g_doneBar]!=g_doneTime);
   int  avgFrom=prev_calculated-1;
//--- first run or history changed: start again from a bounded window
   if(restart)
     {
      Wipe();
      g_done.Clear();
      int feedFrom=MathMax(first,rates_total-1-SCAN_BARS);
      g_exactFrom=feedFrom+g_rules.lookback+2*g_rules.span;
      ArrayFill(g_upBreak,0,rates_total,EMPTY_VALUE);
      ArrayFill(g_downBreak,0,rates_total,EMPTY_VALUE);
      ArrayFill(g_avgOne,0,rates_total,EMPTY_VALUE);
      ArrayFill(g_avgTwo,0,rates_total,EMPTY_VALUE);
      g_doneBar=feedFrom-1;
      avgFrom=0;
     }
   UpdateAverage(g_avgOne,InpAvgOne,InpAvgOneLen,close,avgFrom,rates_total);
   UpdateAverage(g_avgTwo,InpAvgTwo,InpAvgTwoLen,close,avgFrom,rates_total);
//--- closed bars go into the confirmed book
   bool live=(prev_calculated>0);
   for(int i=g_doneBar+1; i<=rates_total-2; i++)
     {
      int flags=StepBar(g_done,g_rules,i,open,high,low,close);
      PlaceBreaks(i,flags,high,low);
      if(live && i==rates_total-2 && i>=g_exactFrom)
         Notify(flags,time[i]);
     }
   g_doneBar=rates_total-2;
   g_doneTime=time[g_doneBar];
//--- the bar in progress is applied to a copy, never to the confirmed book
   int last=rates_total-1;
   g_view.CopyFrom(g_done);
   PlaceBreaks(last,StepBar(g_view,g_rules,last,open,high,low,close),high,low);
   Render(g_view,time,high,low,last,close[last]);
   return(rates_total);
  }
//+------------------------------------------------------------------+
