//+------------------------------------------------------------------+
//|                                            PriorBarBreakOdds.mq5 |
//|                                                     Bruno Myrrha |
//+------------------------------------------------------------------+
//| Purpose:      Counts, over the chart history, how often a bar    |
//|               that follows a bullish or a bearish bar trades     |
//|               above the prior high and below the prior low, at   |
//|               up to five steps of distance. On the bar in        |
//|               progress it draws each level with a bar as long as |
//|               its odds, and a panel scores the favored side over |
//|               the whole history and over a recent window.        |
//| Failure mode: The odds of every level are recomputed on every    |
//|               bar from its reach count, so a level that has not  |
//|               been reached for a while loses odds instead of     |
//|               keeping an old value. The bar in progress is       |
//|               recalculated on every tick from the confirmed      |
//|               tally.                                             |
//| Dependencies: none (chart objects and indicator buffers)         |
//| Part of:      PriorBarBreakOdds indicator                        |
//+------------------------------------------------------------------+

#property copyright "Bruno Nunes Myrrha Ribeiro"
#property link      "https://www.mql5.com/en/users/bruno_myrrha"
#property version   "1.04"
#property description "Odds that the bar in progress takes out the prior high or low, measured"
#property description "on the chart history after bullish and after bearish bars, at stepped levels."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Odds of a higher high"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Odds of a lower low"

//+------------------------------------------------------------------+
//| Option lists                                                     |
//+------------------------------------------------------------------+
enum ENUM_PBO_SPACING
  {
   PBO_SPACING_ATR=0,               // multiple of the average range
   PBO_SPACING_PERCENT=1            // percent of price
  };

//+------------------------------------------------------------------+
//| Inputs: levels                                                   |
//+------------------------------------------------------------------+
input group "Levels"
input ENUM_PBO_SPACING InpSpacing  = PBO_SPACING_ATR; // level distance measured as
input double           InpStepAtr  = 0.5;             // level distance, x average range
input double           InpStepPct  = 1.0;             // level distance, % of price
input int              InpLevels   = 5;               // levels on each side, 1 to 5
input bool             InpHideZero = true;            // hide levels never reached

//+------------------------------------------------------------------+
//| Inputs: look and alerts                                          |
//+------------------------------------------------------------------+
input group "Look"
input bool   InpPanel     = true;            // hit rate panel
input int    InpRecent    = 200;             // recent window of the panel, bars (0 = off)
input color  InpUpColor   = C'0,137,204';    // levels above the prior high
input color  InpDownColor = C'230,112,30';   // levels below the prior low
input group "Alerts"
input bool   InpAlert     = false;           // alert at each new bar

//+------------------------------------------------------------------+
//| Engine constants                                                 |
//+------------------------------------------------------------------+
#define MAX_LEVELS   5              // levels on each side of the prior bar
#define AFTER_UP_HI  0              // column: after a bullish bar, high reached
#define AFTER_UP_LO  1              // column: after a bullish bar, low reached
#define AFTER_DN_HI  2              // column: after a bearish bar, high reached
#define AFTER_DN_LO  3              // column: after a bearish bar, low reached
#define COLUMNS      4              // columns of the tally
#define SPACE_ATR    0              // level distance from the average range
#define SPACE_PCT    1              // level distance from the close
#define RANGE_BARS   14             // closed bars in the average range
#define NOT_SCORED   -1             // outcome of a bar that was not scored

//+------------------------------------------------------------------+
//| Settings the engine runs with                                    |
//+------------------------------------------------------------------+
struct OddsRules
  {
   int               spacing;       // SPACE_ATR or SPACE_PCT
   double            stepAtr;       // level distance, multiple of the average range
   double            stepPct;       // level distance, percent of the close
   int               levels;        // levels on each side
   bool              hideZero;      // skip levels with zero odds
  };

//+------------------------------------------------------------------+
//| One level pair as it is drawn                                    |
//+------------------------------------------------------------------+
struct OddsLevel
  {
   bool              shown;         // drawn on the chart
   double            upPrice;       // price above the prior high
   double            downPrice;     // price below the prior low
   double            upOdds;        // percent of bars that reached upPrice
   double            downOdds;      // percent of bars that reached downPrice
  };

//+------------------------------------------------------------------+
//| What the chart shows for one bar                                 |
//+------------------------------------------------------------------+
struct OddsPicture
  {
   OddsLevel         level[MAX_LEVELS]; // level pairs, nearest first
   double            gap;           // distance between two levels
   bool              afterUp;       // the prior bar closed above its open
   bool              anyShown;      // at least one level is drawn
   double            higher;        // odds of a higher high, first level
   double            lower;         // odds of a lower low, first level
   bool              bullish;       // the higher high is the favored side
  };

//+------------------------------------------------------------------+
//| Average true range of the closed bars before bar i               |
//+------------------------------------------------------------------+
double AverageRange(const double &high[],const double &low[],const double &close[],const int i)
  {
   int    from=MathMax(0,i-RANGE_BARS);
   double sum=0.0;
   int    n=0;
   for(int j=from; j<i; j++)
     {
      double tr=(j==0) ? high[0]-low[0] :
                MathMax(high[j],close[j-1])-MathMin(low[j],close[j-1]);
      sum+=tr;
      n++;
     }
   return(n>0 ? sum/n : 0.0);
  }

//+------------------------------------------------------------------+
//| Distance between two levels on bar i                             |
//+------------------------------------------------------------------+
double LevelGap(const OddsRules &r,const double &high[],const double &low[],
                const double &close[],const int i)
  {
   if(r.spacing==SPACE_ATR)
      return(r.stepAtr*AverageRange(high,low,close,i));
   return(close[i]*(r.stepPct/100.0));
  }

//+------------------------------------------------------------------+
//| Running counts of reached levels and of the favored-side score   |
//+------------------------------------------------------------------+
class COddsTally
  {
public:
   int               reached[MAX_LEVELS][COLUMNS]; // times each level was reached
   int               afterUp;       // bars that followed a bullish bar
   int               afterDown;     // bars that followed a bearish bar
   int               hits;          // the favored side was reached
   int               misses;        // the favored side was not reached
   //--- empties the tally
   void              Clear(void);
   //--- takes a full copy of another tally
   void              CopyFrom(const COddsTally &src);
   //--- current percent of a level and column, two decimals
   double            Odds(const int lvl,const int col) const;
   //--- applies bar i, which needs bar i-1; true when the favored side was reached
   bool              Step(const double &open[],const double &high[],const double &low[],
                          const double &close[],const int i,const double gap);
  };

//+------------------------------------------------------------------+
//| Resets every count to zero                                       |
//+------------------------------------------------------------------+
void COddsTally::Clear(void)
  {
   for(int k=0; k<MAX_LEVELS; k++)
      for(int c=0; c<COLUMNS; c++)
         reached[k][c]=0;
   afterUp=0;
   afterDown=0;
   hits=0;
   misses=0;
  }

//+------------------------------------------------------------------+
//| Copies every count of another tally                              |
//+------------------------------------------------------------------+
void COddsTally::CopyFrom(const COddsTally &src)
  {
   for(int k=0; k<MAX_LEVELS; k++)
      for(int c=0; c<COLUMNS; c++)
         reached[k][c]=src.reached[k][c];
   afterUp=src.afterUp;
   afterDown=src.afterDown;
   hits=src.hits;
   misses=src.misses;
  }

//+------------------------------------------------------------------+
//| Reach count over the bars of the same prior color, in percent    |
//+------------------------------------------------------------------+
double COddsTally::Odds(const int lvl,const int col) const
  {
   int base=(col==AFTER_UP_HI || col==AFTER_UP_LO) ? afterUp : afterDown;
   if(base<=0)
      return(0.0);
   double share=((double)reached[lvl][col]/base)*100.0;
   return(MathRound(share*100.0)/100.0);
  }

//+------------------------------------------------------------------+
//| Applies one bar: counts the prior bar color, the levels this bar |
//| reached, then scores the favored side of the first level         |
//+------------------------------------------------------------------+
bool COddsTally::Step(const double &open[],const double &high[],const double &low[],
                      const double &close[],const int i,const double gap)
  {
   bool up=(close[i-1]>open[i-1]);
   bool down=(close[i-1]<open[i-1]);
   if(up)
      afterUp++;
   if(down)
      afterDown++;
   for(int k=0; k<MAX_LEVELS; k++)
     {
      double reach=gap*k;
      bool above=(high[i]>=high[i-1]+reach);
      bool below=(low[i]<=low[i-1]-reach);
      if(up && above)
         reached[k][AFTER_UP_HI]++;
      if(up && below)
         reached[k][AFTER_UP_LO]++;
      if(down && above)
         reached[k][AFTER_DN_HI]++;
      if(down && below)
         reached[k][AFTER_DN_LO]++;
     }
//--- a doji is scored with the columns of a bearish bar
   int  colHi=(up ? AFTER_UP_HI : AFTER_DN_HI);
   int  colLo=(up ? AFTER_UP_LO : AFTER_DN_LO);
   bool highSide=(Odds(0,colHi)>=Odds(0,colLo));
   bool hit=highSide ? (high[i]>=high[i-1]) : (low[i]<=low[i-1]);
   if(hit)
      hits++;
   else
      misses++;
   return(hit);
  }

//+------------------------------------------------------------------+
//| Hits and misses of the scored bars in a window ending at last    |
//+------------------------------------------------------------------+
void RecentScore(const int &outcome[],const int last,const int window,int &hits,int &misses)
  {
   hits=0;
   misses=0;
   for(int t=MathMax(1,last-window+1); t<=last; t++)
     {
      if(outcome[t]==NOT_SCORED)
         continue;
      if(outcome[t]>0)
         hits++;
      else
         misses++;
     }
  }

//+------------------------------------------------------------------+
//| Builds what the chart shows for bar i from a tally               |
//+------------------------------------------------------------------+
void BuildPicture(const COddsTally &tally,const OddsRules &r,const double &open[],
                  const double &high[],const double &low[],const double &close[],
                  const int i,OddsPicture &pic)
  {
   pic.afterUp=(close[i-1]>open[i-1]);
   int colHi=(pic.afterUp ? AFTER_UP_HI : AFTER_DN_HI);
   int colLo=(pic.afterUp ? AFTER_UP_LO : AFTER_DN_LO);
   pic.gap=LevelGap(r,high,low,close,i);
   pic.anyShown=false;
   for(int k=0; k<MAX_LEVELS; k++)
     {
      double oddsHi=tally.Odds(k,colHi);
      double oddsLo=tally.Odds(k,colLo);
      pic.level[k].shown=(k<r.levels && (!r.hideZero || MathMin(oddsHi,oddsLo)>0));
      pic.level[k].upPrice=high[i-1]+pic.gap*k;
      pic.level[k].downPrice=low[i-1]-pic.gap*k;
      pic.level[k].upOdds=oddsHi;
      pic.level[k].downOdds=oddsLo;
      if(pic.level[k].shown)
         pic.anyShown=true;
     }
   pic.higher=tally.Odds(0,colHi);
   pic.lower=tally.Odds(0,colLo);
   pic.bullish=(pic.higher>=pic.lower);
  }

//+------------------------------------------------------------------+
//| Drawing constants                                                |
//+------------------------------------------------------------------+
#define TAG          "PBO_"         // prefix of every chart object
#define LINE_WIDTH   2              // width of the level lines
#define TEXT_SIZE    9              // font size of the odds and the panel
#define BAR_SPAN     10             // bars of length of a 100% odds bar
#define BAR_HEIGHT   0.55           // odds bar height, share of a level step
#define TRACK_SHADE  12             // empty part of an odds bar, percent
#define FILL_SHADE   55             // filled part of an odds bar, percent
#define PANEL_X      12             // panel distance from the right edge, px
#define PANEL_Y      28             // panel distance from the top edge, px
#define PANEL_PAD    8              // panel inner margin, px
#define PANEL_FONT   "Consolas"     // fixed-width font of the panel table

OddsRules   g_rules;                // engine settings
COddsTally  g_done;                 // tally after the last closed bar
COddsTally  g_view;                 // tally including the bar in progress
OddsPicture g_pic;                  // picture of the last render
int         g_outcome[];            // favored-side outcome per bar
int         g_doneBar=-1;           // last closed bar applied
int         g_last=0;               // bar in progress
datetime    g_doneTime=0;           // time of that bar
datetime    g_from=0;               // left end of the level segments
datetime    g_to=0;                 // right end of the level segments
datetime    g_alerted=0;            // bar of the last alert
string      g_drawn[];              // objects drawn on the last render
//--- indicator buffers
double      g_higher[];             // odds of a higher high per bar
double      g_lower[];              // odds of a lower low per bar

//+------------------------------------------------------------------+
//| Blends a color over another (opacity in percent)                 |
//+------------------------------------------------------------------+
color Blend(const color top,const color under,const double opacity)
  {
   double a=MathMax(0,MathMin(100,opacity))/100.0;
   int    r=(int)MathRound((top&0xFF)*a+(under&0xFF)*(1-a));
   int    g=(int)MathRound(((top>>8)&0xFF)*a+((under>>8)&0xFF)*(1-a));
   int    b=(int)MathRound(((top>>16)&0xFF)*a+((under>>16)&0xFF)*(1-a));
   return((color)(r|(g<<8)|(b<<16)));
  }

//+------------------------------------------------------------------+
//| Chart background color                                           |
//+------------------------------------------------------------------+
color Back(void)
  {
   return((color)ChartGetInteger(0,CHART_COLOR_BACKGROUND));
  }

//+------------------------------------------------------------------+
//| Chart foreground color                                           |
//+------------------------------------------------------------------+
color Fore(void)
  {
   return((color)ChartGetInteger(0,CHART_COLOR_FOREGROUND));
  }

//+------------------------------------------------------------------+
//| Percent with two decimals, as "62.05%"                           |
//+------------------------------------------------------------------+
string Percent(const double value)
  {
   return(DoubleToString(value,2)+"%");
  }

//+------------------------------------------------------------------+
//| Records an object name as drawn on this render                   |
//+------------------------------------------------------------------+
void Keep(const string name)
  {
   int n=ArraySize(g_drawn);
   ArrayResize(g_drawn,n+1,64);
   g_drawn[n]=name;
  }

//+------------------------------------------------------------------+
//| Creates or moves a filled rectangle in the background            |
//+------------------------------------------------------------------+
void PutBox(const string name,const datetime t1,const double p1,const datetime t2,
            const double p2,const color tint)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
      ObjectSetInteger(0,name,OBJPROP_FILL,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,p1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a horizontal line segment                       |
//+------------------------------------------------------------------+
void PutLevel(const string name,const datetime t1,const datetime t2,const double price,
              const color tint)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,LINE_WIDTH);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a text tied to a time and a price               |
//+------------------------------------------------------------------+
void PutText(const string name,const datetime t,const double price,const string text,
             const color tint)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,t,price);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,TEXT_SIZE);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Draws one odds bar: a track and a part as long as the odds       |
//+------------------------------------------------------------------+
void PutOddsBar(const string name,const datetime start,const double price,const double odds,
                const double half,const color tint)
  {
   int      span=PeriodSeconds(_Period);
   datetime full=start+BAR_SPAN*span;
   datetime part=(datetime)((long)start+(long)MathRound(BAR_SPAN*span*MathMin(odds,100.0)/100.0));
   color    back=Back();
   if(half>0)
     {
      PutBox(name+"Track",start,price+half,full,price-half,Blend(tint,back,TRACK_SHADE));
      if(part>start)
         PutBox(name+"Fill",start,price+half,part,price-half,Blend(tint,back,FILL_SHADE));
     }
   PutText(name+"Odds",full+span/2,price,Percent(odds),tint);
  }

//+------------------------------------------------------------------+
//| Creates or moves a text pinned to the top right corner           |
//+------------------------------------------------------------------+
void PutCaption(const string name,const int x,const int y,const string text,
                const color tint,const string tip)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,PANEL_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,TEXT_SIZE);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tip);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| One table row of the panel: label, hits, misses and hit rate     |
//+------------------------------------------------------------------+
string PanelRow(const string label,const int hits,const int misses)
  {
   int    scored=hits+misses;
   string rate=(scored>0 ? Percent(MathRound((double)hits/scored*100.0*100.0)/100.0) : "-");
   return(StringFormat("%-9s%6d%8d%10s",label,hits,misses,rate));
  }

//+------------------------------------------------------------------+
//| Draws the hit rate table in the top right corner                 |
//+------------------------------------------------------------------+
void DrawPanel(const COddsTally &tally)
  {
   string row[3],tip[3];
   color  tint[3];
   int    rows=2;
   row[0]=StringFormat("%-9s%6s%8s%10s","","Hits","Misses","Hit rate");
   row[1]=PanelRow("All bars",tally.hits,tally.misses);
   tip[0]="Favored side of the prior bar: reached (hits) or not (misses)";
   tip[1]="Every scored bar of the chart history";
   tint[0]=Blend(Fore(),Back(),60);
   tint[1]=Fore();
   if(InpRecent>0)
     {
      int h,m;
      RecentScore(g_outcome,g_last,InpRecent,h,m);
      row[2]=PanelRow("Last "+IntegerToString(InpRecent),h,m);
      tip[2]="Scored bars among the last "+IntegerToString(InpRecent)+" bars, the bar in progress included";
      tint[2]=Fore();
      rows=3;
     }
//--- size the box to the widest row
   TextSetFont(PANEL_FONT,-TEXT_SIZE*10);
   int wide=0,tall=0;
   for(int k=0; k<rows; k++)
     {
      uint w,ht;
      TextGetSize(row[k],w,ht);
      wide=MathMax(wide,(int)w);
      tall=MathMax(tall,(int)ht);
     }
   int line=tall+4;
   int boxW=wide+2*PANEL_PAD;
   int boxH=rows*line+2*PANEL_PAD;
   string box=TAG+"panel";
   if(ObjectFind(0,box)<0)
     {
      ObjectCreate(0,box,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,box,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,box,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,box,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,box,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,box,OBJPROP_XDISTANCE,PANEL_X+boxW);
   ObjectSetInteger(0,box,OBJPROP_YDISTANCE,PANEL_Y);
   ObjectSetInteger(0,box,OBJPROP_XSIZE,boxW);
   ObjectSetInteger(0,box,OBJPROP_YSIZE,boxH);
   ObjectSetInteger(0,box,OBJPROP_BGCOLOR,Back());
   ObjectSetInteger(0,box,OBJPROP_COLOR,Blend(Fore(),Back(),35));
   ObjectSetInteger(0,box,OBJPROP_WIDTH,1);
   Keep(box);
   for(int k=0; k<rows; k++)
      PutCaption(TAG+"row"+IntegerToString(k),PANEL_X+PANEL_PAD,PANEL_Y+PANEL_PAD+k*line,
                 row[k],tint[k],tip[k]);
  }

//+------------------------------------------------------------------+
//| Redraws levels, odds bars and panel; removes stale objects       |
//+------------------------------------------------------------------+
void Render(void)
  {
   string before[];
   ArrayCopy(before,g_drawn);
   ArrayResize(g_drawn,0,64);
   if(g_to>0)
     {
      datetime start=g_to+PeriodSeconds(_Period);
      double   half=g_pic.gap*BAR_HEIGHT/2.0;
      for(int k=0; k<MAX_LEVELS; k++)
        {
         if(!g_pic.level[k].shown)
            continue;
         string n=IntegerToString(k);
         PutLevel(TAG+"up"+n,g_from,g_to,g_pic.level[k].upPrice,InpUpColor);
         PutLevel(TAG+"dn"+n,g_from,g_to,g_pic.level[k].downPrice,InpDownColor);
         PutOddsBar(TAG+"upBar"+n,start,g_pic.level[k].upPrice,g_pic.level[k].upOdds,half,InpUpColor);
         PutOddsBar(TAG+"dnBar"+n,start,g_pic.level[k].downPrice,g_pic.level[k].downOdds,half,InpDownColor);
        }
      if(InpPanel)
         DrawPanel(g_view);
     }
   for(int k=0; k<ArraySize(before); k++)
     {
      bool still=false;
      for(int j=0; j<ArraySize(g_drawn) && !still; j++)
         still=(g_drawn[j]==before[k]);
      if(!still)
         ObjectDelete(0,before[k]);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Deletes every object of the indicator                            |
//+------------------------------------------------------------------+
void Wipe(void)
  {
   ObjectsDeleteAll(0,TAG);
   ArrayResize(g_drawn,0);
  }

//+------------------------------------------------------------------+
//| Writes the first-level odds of bar i to the buffers              |
//+------------------------------------------------------------------+
void WriteBar(const COddsTally &tally,const double &open[],const double &close[],const int i)
  {
   bool up=(close[i-1]>open[i-1]);
   g_higher[i]=tally.Odds(0,up ? AFTER_UP_HI : AFTER_DN_HI);
   g_lower[i]=tally.Odds(0,up ? AFTER_UP_LO : AFTER_DN_LO);
  }

//+------------------------------------------------------------------+
//| Sends one alert when a new bar opens                             |
//+------------------------------------------------------------------+
void Announce(const datetime bar,const double priorHigh,const double priorLow)
  {
   if(bar<=g_alerted)
      return;
   g_alerted=bar;
   if(!InpAlert || !g_pic.anyShown)
      return;
   Alert(_Symbol+" "+StringSubstr(EnumToString(_Period),7)+" | prior high "+
         DoubleToString(priorHigh,_Digits)+", prior low "+DoubleToString(priorLow,_Digits)+" | "+
         (g_pic.bullish ? "bullish bias" : "bearish bias")+" | higher high "+Percent(g_pic.higher)+
         ", lower low "+Percent(g_pic.lower));
  }

//+------------------------------------------------------------------+
//| Indicator initialization: settings and buffers                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpStepAtr<0 || InpStepPct<0 || InpLevels<1 || InpLevels>MAX_LEVELS || InpRecent<0)
     {
      Print("the level distances and the recent window must be 0 or more, and the levels 1 to 5");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_rules.spacing=(InpSpacing==PBO_SPACING_ATR ? SPACE_ATR : SPACE_PCT);
   g_rules.stepAtr=InpStepAtr;
   g_rules.stepPct=InpStepPct;
   g_rules.levels=InpLevels;
   g_rules.hideZero=InpHideZero;
   SetIndexBuffer(0,g_higher,INDICATOR_DATA);
   SetIndexBuffer(1,g_lower,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   g_doneBar=-1;
   g_to=0;
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
//| Chart events: bars and panel follow the chart colors             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      Render();
  }

//+------------------------------------------------------------------+
//| Indicator iteration: confirms closed bars, previews the open one |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   if(rates_total<3)
      return(0);
   ArrayResize(g_outcome,rates_total,1024);
//--- history changed or first run: count again from the second bar
   if(prev_calculated==0 || g_doneBar<0 || g_doneBar>rates_total-2 || time[g_doneBar]!=g_doneTime)
     {
      Wipe();
      g_done.Clear();
      ArrayInitialize(g_higher,EMPTY_VALUE);
      ArrayInitialize(g_lower,EMPTY_VALUE);
      ArrayInitialize(g_outcome,NOT_SCORED);
      g_doneBar=0;
      g_alerted=time[rates_total-1];
     }
   for(int i=g_doneBar+1; i<=rates_total-2; i++)
     {
      double gap=LevelGap(g_rules,high,low,close,i);
      g_outcome[i]=(g_done.Step(open,high,low,close,i,gap) ? 1 : 0);
      WriteBar(g_done,open,close,i);
     }
   g_doneBar=rates_total-2;
   g_doneTime=time[g_doneBar];
//--- the bar in progress is applied to a copy, never to the confirmed tally
   int last=rates_total-1;
   g_last=last;
   g_view.CopyFrom(g_done);
   double gap=LevelGap(g_rules,high,low,close,last);
   g_outcome[last]=(g_view.Step(open,high,low,close,last,gap) ? 1 : 0);
   WriteBar(g_view,open,close,last);
   BuildPicture(g_view,g_rules,open,high,low,close,last,g_pic);
   g_from=time[last-1];
   g_to=time[last];
   Render();
   Announce(time[last],high[last-1],low[last-1]);
   return(rates_total);
  }
//+------------------------------------------------------------------+
