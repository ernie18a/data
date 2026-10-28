//+------------------------------------------------------------------+
//|                                           BrokerClockAuditor.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Reads the server clock from H1 history: each weekly 17:00 New York"
#property description "close gives the UTC offset; DST switches are dated and matched to"
#property description "the US or EU calendar; session opens are projected in server time."
#property description "Read only: it never calls a trade function."
//--- limits and behaviour constants
#define BCA_NAME          "BrokerClockAuditor"      // program name used in every journal line
#define BCA_TITLE         "Broker Clock Auditor"    // title of the journal block and of the panel
#define BCA_FOLDER        "BrokerClockAuditor"      // sub folder of MQL5\Files holding the CSV files
#define BCA_MAX_SYMBOLS   128                       // highest number of symbols one run can audit
#define BCA_RETRIES       20                        // attempts of one bar request in a live chart
#define BCA_RETRY_MS      500                       // pause between two attempts, milliseconds
#define BCA_PANEL_ROWS    24                        // symbol rows the panel shows at most
#define BCA_PANEL_CHANGES 4                         // projection change rows the panel shows at most
#define BCA_PRINT_ROWS    10                        // projection rows the journal shows at most
#define BCA_WARMUP_PULSES 15                        // pulses waited for the history before auditing
#define BCA_PANEL_FONT    "Consolas"                // monospace font, the panel is a table
#define BCA_MAX_LABEL     62                        // characters one OBJ_LABEL can show
#define BCA_COLS          7                         // columns of the result table
#define BCA_SEP           ";"                       // column separator of every CSV file
#define BCA_MARKETS       4                         // London, New York, Tokyo, Sydney
//--- time units in seconds
#define BCA_HOUR          3600                      // one hour
#define BCA_DAY           86400                     // one day
#define BCA_WEEK          604800                    // one week
//--- daylight saving time rules
#define BCA_RULE_NONE     0                         // no DST
#define BCA_RULE_US       1                         // 2nd Sunday March 07:00 UTC - 1st Sunday November 06:00 UTC
#define BCA_RULE_EU       2                         // last Sunday March 01:00 UTC - last Sunday October 01:00 UTC
#define BCA_RULE_AU       3                         // Saturday 16:00 UTC before the 1st Sunday of October - of April
//--- calendar of one switch and regime of one symbol
#define BCA_CAL_US        0                         // a US instant of the right direction is inside
#define BCA_CAL_EU        1                         // an EU instant of the right direction is inside
#define BCA_CAL_BOTH      2                         // both, the data is too sparse to tell
#define BCA_CAL_OTHER     3                         // neither, wrong direction or not one hour
#define BCA_REGIME_FIXED  0                         // no switch
#define BCA_REGIME_US     1                         // every switch is US
#define BCA_REGIME_EU     2                         // every switch is EU
#define BCA_REGIME_MIXED  3                         // anything else
//--- colours of the panel, black on white so that a screenshot is readable
#define BCA_BACK_COLOR    clrWhite                  // panel background
#define BCA_BORDER_COLOR  clrBlack                  // panel border
#define BCA_TEXT_COLOR    clrBlack                  // panel text
//+------------------------------------------------------------------+
//| What happened to one symbol; all but OK is one journal line      |
//+------------------------------------------------------------------+
enum ENUM_BCA_STATUS
  {
   BCA_STATUS_IDLE=0,  // not audited
   BCA_STATUS_UNKNOWN, // the terminal does not know this symbol
   BCA_STATUS_NO_BARS, // the symbol has no H1 bar
   BCA_STATUS_NO_READ, // the H1 bars of the window could not be read
   BCA_STATUS_OK       // audited
  };
//--- input parameters
input string           InpSymbols        = "";                // Symbols: empty = chart symbol, * = Market Watch, else CSV list
input int              InpWeeks          = 60;                // Weeks of H1 history to read (60 covers both DST seasons)
input int              InpMinGapHours    = 20;                // A pause in quotes this long is a market close (weekend/holiday)
input int              InpProjectWeeks   = 8;                 // Weeks of session opens to project in server time
input string           InpLondonOpen     = "08:00";           // London open, London local time
input string           InpNewYorkOpen    = "08:00";           // New York open, New York local time
input string           InpTokyoOpen      = "09:00";           // Tokyo open, Tokyo local time
input string           InpSydneyOpen     = "07:00";           // Sydney open, Sydney local time
input int              InpMaxExamples    = 5;                 // Journal: irregular anchors printed per symbol
input bool             InpWriteCsv       = true;              // Write anchors, switches, summary, projection and verdict CSV files
input bool             InpShowPanel      = true;              // Draw the result table on the chart
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel corner
input int              InpPanelFontSize  = 8;                 // Panel font size
input int              InpPanelX         = 10;                // Panel X offset, px
input int              InpPanelY         = 18;                // Panel Y offset, px
input int              InpRefreshMinutes = 0;                 // Re-audit every N minutes (0 = audit once)
//--- the inputs as they are used, after the out of range values were clamped
int ExtWeeks=60;                                   // weeks of the window
int ExtMinGapHours=20;                             // shortest market close in hours
int ExtProjectWeeks=8;                             // weeks of the projection
int ExtMaxExamples=5;                              // irregular anchors printed per symbol
int ExtRefreshMinutes=0;                           // minutes between two passes, 0 = once
int ExtOpens[BCA_MARKETS]= {480,480,540,420};      // local open of every market, minutes of the day
//--- names written into the CSV files and the journal
string ExtCalNames[4]= {"US","EU","US+EU","other"};
string ExtRegimeNames[4]= {"fixed","US","EU","mixed"};
string ExtStatusNames[5]= {"IDLE","UNKNOWN","NO_BARS","NO_READ","OK"};
string ExtMarketNames[BCA_MARKETS]= {"London","New York","Tokyo","Sydney"};
string ExtMarketKeys[BCA_MARKETS]= {"london","new_york","tokyo","sydney"};
//+------------------------------------------------------------------+
//| Now: server time, the one clock the tester also has              |
//+------------------------------------------------------------------+
datetime BcaNow(void)
  {
   return(TimeCurrent());
  }
//+------------------------------------------------------------------+
//| Seconds for the refresh interval: TimeCurrent() stops without    |
//| ticks (weekend, no connection), so live charts use the PC uptime |
//+------------------------------------------------------------------+
long BcaRefreshClock(void)
  {
   if(MQLInfoInteger(MQL_TESTER)!=0)
      return((long)TimeCurrent());
   return((long)(GetTickCount64()/1000));
  }
//+------------------------------------------------------------------+
//| Text padded to a width, right aligned for numbers, never cut     |
//+------------------------------------------------------------------+
string BcaPad(const string text,const int width,const bool right)
  {
   string out=text;
   while(StringLen(out)<width)
      out=(right ? " "+out : out+" ");
   return(out);
  }
//+------------------------------------------------------------------+
//| A symbol name made safe for a file name, e.g. US30.cash          |
//+------------------------------------------------------------------+
string BcaSafeName(const string text)
  {
   string allowed="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";
   string out="";
   int    len=StringLen(text);
   for(int i=0; i<len; i++)
     {
      string piece=ShortToString(StringGetCharacter(text,i));
      out+=(StringFind(allowed,piece)>=0 ? piece : "_");
     }
   return(out);
  }
//+------------------------------------------------------------------+
//| A CSV cell: empty when not measured, a zero would look clean     |
//+------------------------------------------------------------------+
string BcaCell(const bool measured,const string text)
  {
   return(measured ? text : "");
  }
//+------------------------------------------------------------------+
//| Minute of the day as HH:MM                                       |
//+------------------------------------------------------------------+
string BcaClock(const int minute)
  {
   return(StringFormat("%02d:%02d",minute/60,minute%60));
  }
//+------------------------------------------------------------------+
//| An offset in minutes as +H:MM, e.g. +3:00 or -1:00               |
//+------------------------------------------------------------------+
string BcaOffset(const int minutes)
  {
   int size=(minutes<0 ? -minutes : minutes);
   return(StringFormat("%s%d:%02d",(minutes<0 ? "-" : "+"),size/60,size%60));
  }
//+------------------------------------------------------------------+
//| Time as yyyy.mm.dd HH:MM, or the date alone                      |
//+------------------------------------------------------------------+
string BcaTime(const long moment,const bool minutes=true)
  {
   return(TimeToString((datetime)moment,(minutes ? TIME_DATE|TIME_MINUTES : TIME_DATE)));
  }
//+------------------------------------------------------------------+
//| Three letter name of a weekday, Sunday = 0                       |
//+------------------------------------------------------------------+
string BcaDayName(const int weekday)
  {
   return(StringSubstr("SunMonTueWedThuFriSat",weekday*3,3));
  }
//+------------------------------------------------------------------+
//| Appends one line to a list of lines                              |
//+------------------------------------------------------------------+
void BcaAdd(string &lines[],const string text)
  {
   int count=ArraySize(lines);
   ArrayResize(lines,count+1,32);
   lines[count]=text;
  }
//+------------------------------------------------------------------+
//| Width of every table column, shared by the panel and the journal |
//+------------------------------------------------------------------+
void BcaColumnWidths(const string &cells[][BCA_COLS],const int rows,int &widths[])
  {
   for(int c=0; c<BCA_COLS; c++)
     {
      widths[c]=0;
      for(int r=0; r<rows; r++)
         widths[c]=MathMax(widths[c],StringLen(cells[r][c]));
     }
  }
//+------------------------------------------------------------------+
//| One table row as one journal line, numbers right aligned         |
//+------------------------------------------------------------------+
string BcaRowText(const string &cells[][BCA_COLS],const int row,const int &widths[])
  {
   string out="";
   for(int c=0; c<BCA_COLS; c++)
      out+=(c>0 ? "  " : "")+BcaPad(cells[row][c],widths[c],c>0);
   return(out);
  }
//+------------------------------------------------------------------+
//| DST rules of the US, the EU and Sydney, and 17:00 New York; all  |
//| instants are epoch seconds, a date is the epoch second of 00:00  |
//+------------------------------------------------------------------+
class CBcaCalendar
  {
public:
   static long       Day(const int year,const int month,const int day);
   static int        Year(const long moment);
   static int        Weekday(const long moment) { return((int)((moment/BCA_DAY+4)%7)); }
   static long       NthSunday(const int year,const int month,const int nth);
   static long       LastSunday(const int year,const int month);
   static long       Switch(const int rule,const bool start,const int year);
   static bool       Dst(const int rule,const long moment);
   static bool       Inside(const int rule,const bool start,const long low,const long high,const bool low_closed);
   static long       NyClose(const long day);
   static long       NearestNyClose(const long close);
   static int        Zone(const int market,int &rule);
   static long       LocalToUtc(const long day,const int minutes,const int market);
  };
//+------------------------------------------------------------------+
//| 00:00 of a calendar date                                         |
//+------------------------------------------------------------------+
long CBcaCalendar::Day(const int year,const int month,const int day)
  {
   MqlDateTime parts;
   ZeroMemory(parts);
   parts.year=year;
   parts.mon=month;
   parts.day=day;
   return((long)StructToTime(parts));
  }
//+------------------------------------------------------------------+
//| Calendar year of an instant                                      |
//+------------------------------------------------------------------+
int CBcaCalendar::Year(const long moment)
  {
   MqlDateTime parts;
   TimeToStruct((datetime)moment,parts);
   return(parts.year);
  }
//+------------------------------------------------------------------+
//| 00:00 of the nth Sunday of a month                               |
//+------------------------------------------------------------------+
long CBcaCalendar::NthSunday(const int year,const int month,const int nth)
  {
   long first=Day(year,month,1);
   long sunday=first+(long)((7-Weekday(first))%7)*BCA_DAY;
   return(sunday+(long)(nth-1)*7*BCA_DAY);
  }
//+------------------------------------------------------------------+
//| 00:00 of the last Sunday of a month                              |
//+------------------------------------------------------------------+
long CBcaCalendar::LastSunday(const int year,const int month)
  {
   long last=(month==12 ? Day(year+1,1,1) : Day(year,month+1,1))-BCA_DAY;
   return(last-(long)Weekday(last)*BCA_DAY);
  }
//+------------------------------------------------------------------+
//| UTC instant where DST starts (start=true) or ends in a year      |
//+------------------------------------------------------------------+
long CBcaCalendar::Switch(const int rule,const bool start,const int year)
  {
   switch(rule)
     {
      case BCA_RULE_US:
         return(start ? NthSunday(year,3,2)+7*BCA_HOUR : NthSunday(year,11,1)+6*BCA_HOUR);
      case BCA_RULE_EU:
         return(start ? LastSunday(year,3)+BCA_HOUR : LastSunday(year,10)+BCA_HOUR);
      case BCA_RULE_AU:
         //--- the Saturday 16:00 UTC before the first Sunday of October, of April
         return(start ? NthSunday(year,10,1)-BCA_DAY+16*BCA_HOUR : NthSunday(year,4,1)-BCA_DAY+16*BCA_HOUR);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Is DST of a rule on at a UTC instant                             |
//+------------------------------------------------------------------+
bool CBcaCalendar::Dst(const int rule,const long moment)
  {
   if(rule==BCA_RULE_NONE)
      return(false);
   int  year=Year(moment);
   long on=Switch(rule,true,year);
   long off=Switch(rule,false,year);
//--- the southern summer spans the turn of the year
   if(rule==BCA_RULE_AU)
      return(moment>=on || moment<off);
   return(moment>=on && moment<off);
  }
//+------------------------------------------------------------------+
//| Does a start or end instant of a rule lie in (low, high]         |
//+------------------------------------------------------------------+
bool CBcaCalendar::Inside(const int rule,const bool start,const long low,const long high,const bool low_closed)
  {
   for(int year=Year(low); year<=Year(high); year++)
     {
      long moment=Switch(rule,start,year);
      if((moment>low || (low_closed && moment==low)) && moment<=high)
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| 17:00 New York on a calendar date, as a UTC instant              |
//+------------------------------------------------------------------+
long CBcaCalendar::NyClose(const long day)
  {
//--- 17:00 EDT = 21:00 UTC, 17:00 EST = 22:00 UTC
   long moment=day+21*BCA_HOUR;
   if(!Dst(BCA_RULE_US,moment))
      moment+=BCA_HOUR;
   return(moment);
  }
//+------------------------------------------------------------------+
//| U: the 17:00 New York nearest to a close, dates -2 .. +2         |
//+------------------------------------------------------------------+
long CBcaCalendar::NearestNyClose(const long close)
  {
   long day=close-close%BCA_DAY;
   long best=0;
   for(int k=-2; k<=2; k++)
     {
      long moment=NyClose(day+(long)k*BCA_DAY);
      if(k==-2 || MathAbs(close-moment)<MathAbs(close-best))
         best=moment;
     }
   return(best);
  }
//+------------------------------------------------------------------+
//| Standard offset in minutes and DST rule of a market: London 0,   |
//| New York -5 h US, Tokyo +9 h none, Sydney +10 h AU               |
//+------------------------------------------------------------------+
int CBcaCalendar::Zone(const int market,int &rule)
  {
   rule=(market==0 ? BCA_RULE_EU : (market==1 ? BCA_RULE_US : (market==3 ? BCA_RULE_AU : BCA_RULE_NONE)));
   return(market==1 ? -300 : (market==2 ? 540 : (market==3 ? 600 : 0)));
  }
//+------------------------------------------------------------------+
//| UTC instant of a local time of a market on a calendar date; DST  |
//| is the local offset evaluated at that instant                    |
//+------------------------------------------------------------------+
long CBcaCalendar::LocalToUtc(const long day,const int minutes,const int market)
  {
   int  rule=BCA_RULE_NONE;
   long standard=day+(long)minutes*60-(long)Zone(market,rule)*60;
   if(rule!=BCA_RULE_NONE && Dst(rule,standard-BCA_HOUR))
      return(standard-BCA_HOUR);
   return(standard);
  }
//+------------------------------------------------------------------+
//| The result table on the chart, one OBJ_LABEL per column cell     |
//+------------------------------------------------------------------+
class CBcaPanel
  {
private:
   long              m_chart;             // chart the panel belongs to
   string            m_prefix;            // unique name prefix of every own object
   bool              m_created;           // the background object exists
   int               m_x;                 // x distance in pixels
   int               m_y;                 // y distance in pixels
   int               m_pad;               // inner padding in pixels
   int               m_line_height;       // distance between two lines in pixels
   int               m_char_width;        // width of one character in pixels
   int               m_font_size;         // font size in points
   int               m_width_px;          // measured width of the background in pixels
   int               m_height_px;         // measured height of the background in pixels
   int               m_labels;            // labels the last update drew
   int               m_widest;            // characters of the widest line
   int               m_rows;              // lines the last update drew
   ENUM_BASE_CORNER  m_corner;            // chart corner the panel is anchored to
   ENUM_ANCHOR_POINT m_anchor;            // anchor of every label

   void              Place(const int row,const int column,const int start,const string text);
   void              Free(const int row,const string text);

public:
                     CBcaPanel(void) { Reset(); }
   void              Reset(void);
   bool              Create(void);
   void              Destroy(void);
   void              Update(const string &top[],const string &cells[][BCA_COLS],const int table_rows,
                            const string &bottom[]);
   int               WidthPx(void)  const { return(m_width_px);  }
   int               HeightPx(void) const { return(m_height_px); }
   int               Labels(void)   const { return(m_labels);    }
   int               Widest(void)   const { return(m_widest);    }
  };
//+------------------------------------------------------------------+
//| Back to the start: a changed input keeps the old object alive    |
//+------------------------------------------------------------------+
void CBcaPanel::Reset(void)
  {
   m_chart=0;
   m_prefix="";
   m_created=false;
   m_x=0;
   m_y=0;
   m_pad=6;
   m_line_height=14;
   m_char_width=7;
   m_font_size=8;
   m_corner=CORNER_LEFT_UPPER;
   m_anchor=ANCHOR_LEFT_UPPER;
   m_width_px=0;
   m_height_px=0;
   m_labels=0;
   m_widest=0;
   m_rows=0;
  }
//+------------------------------------------------------------------+
//| Prefix with chart id and free instance, geometry, background     |
//+------------------------------------------------------------------+
bool CBcaPanel::Create(void)
  {
   m_chart=ChartID();
//--- stage: the first instance index that is not used on this chart
   int instance=0;
   for(; instance<15; instance++)
      if(ObjectFind(m_chart,BCA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_bg")<0)
         break;
   m_prefix=BCA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
//--- stage: geometry, points stay points and pixels follow the screen dpi
   double scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   m_font_size  =(int)MathMin(20,MathMax(4,InpPanelFontSize));
   m_pad        =(int)MathRound(6.0*scale);
   m_line_height=(int)MathRound(m_font_size*1.70*scale);
   m_char_width =(int)MathCeil(m_font_size*0.75*scale);
   uint text_width=0,text_height=0;
   TextSetFont(BCA_PANEL_FONT,-m_font_size*10,FW_NORMAL,0);
   if(TextGetSize("0123456789",text_width,text_height) && text_width>0)
      m_char_width=(int)MathCeil(text_width/10.0);
   m_x=(int)MathRound(MathMax(0,InpPanelX)*scale);
   m_y=(int)MathRound(MathMax(0,InpPanelY)*scale);
   m_corner=InpPanelCorner;
   m_anchor=ANCHOR_LEFT_UPPER;
   if(m_corner==CORNER_RIGHT_UPPER)
      m_anchor=ANCHOR_RIGHT_UPPER;
   if(m_corner==CORNER_LEFT_LOWER)
      m_anchor=ANCHOR_LEFT_LOWER;
   if(m_corner==CORNER_RIGHT_LOWER)
      m_anchor=ANCHOR_RIGHT_LOWER;
//--- stage: background rectangle
   string name=m_prefix+"bg";
   ResetLastError();
   if(!ObjectCreate(m_chart,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      PrintFormat("%s: the panel background could not be created, error %d, panel off",BCA_NAME,GetLastError());
      return(false);
     }
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,m_x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y);
   ObjectSetInteger(m_chart,name,OBJPROP_BGCOLOR,BCA_BACK_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,BCA_BORDER_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(m_chart,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,0);
   m_created=true;
   return(true);
  }
//+------------------------------------------------------------------+
//| Deletes the objects of this instance and nothing else            |
//+------------------------------------------------------------------+
void CBcaPanel::Destroy(void)
  {
   if(m_prefix=="")
      return;
   ObjectsDeleteAll(m_chart,m_prefix);
   ChartRedraw(m_chart);
   m_created=false;
   m_labels=0;
  }
//+------------------------------------------------------------------+
//| Draws one label at a column in characters, blanks are skipped    |
//+------------------------------------------------------------------+
void CBcaPanel::Place(const int row,const int column,const int start,const string text)
  {
   string trimmed=text;
   StringTrimLeft(trimmed);
   if(trimmed=="")
      return;
   string name=m_prefix+"L"+IntegerToString(row)+"_"+IntegerToString(column);
   if(!ObjectCreate(m_chart,name,OBJ_LABEL,0,0,0))
      return;
   int x=m_x+m_pad+start*m_char_width;
   if(m_anchor==ANCHOR_RIGHT_UPPER || m_anchor==ANCHOR_RIGHT_LOWER)
      x=m_x+m_pad+(m_widest-start-StringLen(text))*m_char_width;
   int y=m_y+m_pad+row*m_line_height;
   if(m_anchor==ANCHOR_LEFT_LOWER || m_anchor==ANCHOR_RIGHT_LOWER)
      y=m_y+m_pad+(m_rows-1-row)*m_line_height;
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_ANCHOR,m_anchor);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(m_chart,name,OBJPROP_FONT,BCA_PANEL_FONT);
   ObjectSetInteger(m_chart,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,BCA_TEXT_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,1);
   ObjectSetString(m_chart,name,OBJPROP_TEXT,text);
   m_labels++;
  }
//+------------------------------------------------------------------+
//| A free line cut into label sized pieces                          |
//+------------------------------------------------------------------+
void CBcaPanel::Free(const int row,const string text)
  {
   for(int piece=0; piece*BCA_MAX_LABEL<StringLen(text); piece++)
      Place(row,piece,piece*BCA_MAX_LABEL,StringSubstr(text,piece*BCA_MAX_LABEL,BCA_MAX_LABEL));
  }
//+------------------------------------------------------------------+
//| Redraws the free lines and the table, sizes the background       |
//+------------------------------------------------------------------+
void CBcaPanel::Update(const string &top[],const string &cells[][BCA_COLS],const int table_rows,
                       const string &bottom[])
  {
   if(!m_created)
      return;
//--- stage: where every table column starts, in characters
   int widths[BCA_COLS];
   int starts[BCA_COLS];
   BcaColumnWidths(cells,table_rows,widths);
   int table_width=0;
   for(int c=0; c<BCA_COLS; c++)
     {
      starts[c]=table_width;
      table_width+=widths[c]+(c<BCA_COLS-1 ? 2 : 0);
     }
//--- stage: the widest line decides the size of the background
   int top_count=ArraySize(top);
   int bottom_count=ArraySize(bottom);
   m_widest=table_width;
   for(int i=0; i<top_count; i++)
      m_widest=MathMax(m_widest,StringLen(top[i]));
   for(int i=0; i<bottom_count; i++)
      m_widest=MathMax(m_widest,StringLen(bottom[i]));
   m_rows=top_count+table_rows+bottom_count;
   m_labels=0;
   ObjectsDeleteAll(m_chart,m_prefix+"L");
//--- stage: the labels row by row
   int row=0;
   for(int i=0; i<top_count; i++,row++)
      Free(row,top[i]);
   for(int r=0; r<table_rows; r++,row++)
      for(int c=0; c<BCA_COLS; c++)
         Place(row,c,starts[c],BcaPad(cells[r][c],widths[c],c>0));
   for(int i=0; i<bottom_count; i++,row++)
      Free(row,bottom[i]);
//--- stage: background size, measured from the text that was just drawn
   m_width_px =2*m_pad+m_widest*m_char_width;
   m_height_px=2*m_pad+m_rows*m_line_height;
   ObjectSetInteger(m_chart,m_prefix+"bg",OBJPROP_XSIZE,m_width_px);
   ObjectSetInteger(m_chart,m_prefix+"bg",OBJPROP_YSIZE,m_height_px);
   ChartRedraw(m_chart);
  }
//+------------------------------------------------------------------+
//| Output of one pass: the journal lines and the CSV files          |
//+------------------------------------------------------------------+
class CBcaReport
  {
private:
   string            m_prefix;            // file name prefix of one pass
   int               m_files;             // files written in this pass

public:
                     CBcaReport(void) { Reset(); }
   void              Reset(void) { m_prefix=""; m_files=0; }
   void              Open(const string prefix);
   bool              WriteTable(const string tail,const string header,const string &rows[],const int count);
   void              Journal(const string &lines[]) const;
   int               Files(void) const { return(m_files); }
  };
//+------------------------------------------------------------------+
//| Starts a pass: removes the files of an earlier pass, same prefix |
//+------------------------------------------------------------------+
void CBcaReport::Open(const string prefix)
  {
   m_prefix=prefix;
   m_files=0;
   if(!InpWriteCsv)
      return;
   string names[];
   string found="";
   int    count=0;
   long   search=FileFindFirst(BCA_FOLDER+"\\"+m_prefix+"_*",found);
   if(search!=INVALID_HANDLE)
     {
      do
        {
         ArrayResize(names,count+1,16);
         names[count++]=found;
        }
      while(FileFindNext(search,found));
      FileFindClose(search);
     }
   int removed=0;
   for(int i=0; i<count; i++)
      if(FileDelete(BCA_FOLDER+"\\"+names[i]))
         removed++;
   if(count>0)
      PrintFormat("%s: %d of %d file(s) of an earlier pass with the prefix %s were removed",BCA_NAME,removed,count,
                  m_prefix);
  }
//+------------------------------------------------------------------+
//| Writes one file <prefix>_<tail>.csv; a failure costs this file   |
//+------------------------------------------------------------------+
bool CBcaReport::WriteTable(const string tail,const string header,const string &rows[],const int count)
  {
   if(!InpWriteCsv)
      return(false);
   string name=BCA_FOLDER+"\\"+m_prefix+"_"+tail+".csv";
   ResetLastError();
   int handle=FileOpen(name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",BCA_NAME,name,GetLastError());
      return(false);
     }
   FileWriteString(handle,header+"\r\n");
   for(int i=0; i<count; i++)
      FileWriteString(handle,rows[i]+"\r\n");
   FileClose(handle);
   m_files++;
   return(true);
  }
//+------------------------------------------------------------------+
//| Prints a block of journal lines, line by line                    |
//+------------------------------------------------------------------+
void CBcaReport::Journal(const string &lines[]) const
  {
   for(int i=0; i<ArraySize(lines); i++)
      Print(lines[i]);
  }
//+------------------------------------------------------------------+
//| One symbol: market closes of the H1 window, offsets, switches    |
//+------------------------------------------------------------------+
class CBcaSymbolAudit
  {
private:
   string            m_symbol;            // symbol under audit
   ENUM_BCA_STATUS   m_status;            // what happened to this symbol
   long              m_t0;                // window start, inclusive
   long              m_last;              // open time of the newest H1 bar, window end, inclusive
   int               m_retries;           // repeated bar requests
   int               m_read_error;        // error of the request that failed
   long              m_bars;              // distinct H1 bars inside the window
   int               m_sundays;           // server Sunday dates with a bar
   int               m_saturdays;         // server Saturday dates with a bar
   //--- anchors in time order
   int               m_anchors;           // market closes found
   long              m_close[];           // open time of the last bar before the gap + 1 hour
   long              m_utc[];             // U: the nearest 17:00 New York, true UTC
   int               m_offset[];          // close - U in minutes
   long              m_reopen[];          // open time of the first bar after the gap
   uchar             m_weekend[];         // 1 = a server Saturday 12:00 lies in the gap
   uchar             m_irregular[];       // 1 = differs from last regular and next
   int               m_weekend_count;     // weekend anchors
   int               m_irregular_count;   // irregular anchors
   //--- the regular sequence
   int               m_offset_now;        // offset of the last regular anchor, minutes
   long              m_first_utc;         // U of the first regular anchor
   long              m_last_utc;          // U of the last regular anchor
   int               m_seen[];            // distinct regular offsets, ascending
   int               m_sw_before[];       // anchor index of the regular anchor before a switch
   int               m_sw_after[];        // anchor index of the regular anchor after it
   int               m_sw_cal[];          // BCA_CAL_US ... BCA_CAL_OTHER
   int               m_switches;          // switches
   int               m_us;                // switches of calendar US
   int               m_eu;                // switches of calendar EU
   int               m_regime;            // BCA_REGIME_FIXED ... BCA_REGIME_MIXED
   int               m_dst_tested;        // 1 = a US and an EU instant lie in the regular span

   int               Fetch(const bool newest,datetime &times[]);
   void              AddAnchor(const long before,const long after);
   void              Analyse(void);
   int               Calendar(const int before,const int after) const;
   string            SeenText(const bool human) const;

public:
                     CBcaSymbolAudit(void) { Reset(); }
   void              Reset(void);
   void              SetSymbol(const string symbol) { Reset(); m_symbol=symbol; }
   bool              Audit(void);
   void              WriteFiles(CBcaReport &report,string &summary[]) const;
   void              JournalLines(string &lines[]) const;
   void              Cells(string &cells[][BCA_COLS],const int row) const;
   static void       HeaderCells(string &cells[][BCA_COLS],const int row);
   string            Name(void)           const { return(m_symbol);     }
   bool              Audited(void)        const { return(m_status==BCA_STATUS_OK); }
   bool              Reported(void)       const { return(m_status==BCA_STATUS_OK && m_anchors>=2); }
   int               OffsetNow(void)      const { return(m_offset_now); }
   int               Regime(void)         const { return(m_regime);     }
   int               DstTested(void)      const { return(m_dst_tested); }
   long              LastRegularUtc(void) const { return(m_last_utc);   }
  };
//+------------------------------------------------------------------+
//| Everything back to the start, a re-init keeps the globals (C24)  |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::Reset(void)
  {
   m_symbol="";
   m_status=BCA_STATUS_IDLE;
   m_t0=0;
   m_last=0;
   m_retries=0;
   m_read_error=0;
   m_bars=0;
   m_sundays=0;
   m_saturdays=0;
   m_anchors=0;
   ArrayFree(m_close);
   ArrayFree(m_utc);
   ArrayFree(m_offset);
   ArrayFree(m_reopen);
   ArrayFree(m_weekend);
   ArrayFree(m_irregular);
   m_weekend_count=0;
   m_irregular_count=0;
   m_offset_now=0;
   m_first_utc=0;
   m_last_utc=0;
   ArrayFree(m_seen);
   ArrayFree(m_sw_before);
   ArrayFree(m_sw_after);
   ArrayFree(m_sw_cal);
   m_switches=0;
   m_us=0;
   m_eu=0;
   m_regime=BCA_REGIME_FIXED;
   m_dst_tested=0;
  }
//+------------------------------------------------------------------+
//| H1 open times: the newest bar or [T0, last]; -1 on failure       |
//+------------------------------------------------------------------+
int CBcaSymbolAudit::Fetch(const bool newest,datetime &times[])
  {
//--- a live chart retries 20 times with a pause of 500 ms, the tester tries once
   int attempts=(MQLInfoInteger(MQL_TESTER)!=0 ? 1 : BCA_RETRIES);
   int got=-1;
   int error=0;
   for(int attempt=1; attempt<=attempts; attempt++)
     {
      ResetLastError();
      if(newest)
         got=CopyTime(m_symbol,PERIOD_H1,0,1,times);
      else
         got=CopyTime(m_symbol,PERIOD_H1,(datetime)m_t0,(datetime)m_last,times);
      error=GetLastError();
      //--- 4401 = not found yet, 4403 = the synchronisation timed out and
      //    the answer may be partial; both are worth one more attempt
      if(got>=0 && error!=ERR_HISTORY_NOT_FOUND && error!=ERR_HISTORY_TIMEOUT)
         break;
      if(attempt<attempts)
        {
         m_retries++;
         Sleep(BCA_RETRY_MS);
        }
     }
   if(got<0 || error==ERR_HISTORY_NOT_FOUND || error==ERR_HISTORY_TIMEOUT)
     {
      m_read_error=error;
      return(-1);
     }
   return(got);
  }
//+------------------------------------------------------------------+
//| One market close: close, U, offset, kind of the gap              |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::AddAnchor(const long before,const long after)
  {
   long close=before+BCA_HOUR;
   long utc=CBcaCalendar::NearestNyClose(close);
//--- weekend when some server Saturday 12:00 lies in [close, reopen)
   long noon=close-close%BCA_DAY+BCA_DAY/2;
   if(noon<close)
      noon+=BCA_DAY;
   while(CBcaCalendar::Weekday(noon)!=6)
      noon+=BCA_DAY;
   int n=m_anchors;
   ArrayResize(m_close,n+1,64);
   ArrayResize(m_utc,n+1,64);
   ArrayResize(m_offset,n+1,64);
   ArrayResize(m_reopen,n+1,64);
   ArrayResize(m_weekend,n+1,64);
   ArrayResize(m_irregular,n+1,64);
   m_close[n]=close;
   m_utc[n]=utc;
   m_offset[n]=(int)((close-utc)/60);
   m_reopen[n]=after;
   m_weekend[n]=(uchar)(noon<after ? 1 : 0);
   m_irregular[n]=0;
   m_weekend_count+=m_weekend[n];
   m_anchors++;
  }
//+------------------------------------------------------------------+
//| Calendar of a switch between two regular anchors                 |
//+------------------------------------------------------------------+
int CBcaSymbolAudit::Calendar(const int before,const int after) const
  {
   int from=m_offset[before];
   int to=m_offset[after];
   if(to-from!=60 && from-to!=60)
      return(BCA_CAL_OTHER);
//--- up = a DST start (spring), down = a DST end (autumn); interval (U before, U after]
   bool up=(to>from);
   bool us=CBcaCalendar::Inside(BCA_RULE_US,up,m_utc[before],m_utc[after],false);
   bool eu=CBcaCalendar::Inside(BCA_RULE_EU,up,m_utc[before],m_utc[after],false);
   if(us && eu)
      return(BCA_CAL_BOTH);
   if(us)
      return(BCA_CAL_US);
   return(eu ? BCA_CAL_EU : BCA_CAL_OTHER);
  }
//+------------------------------------------------------------------+
//| Irregular anchors, the regular sequence, switches and regime     |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::Analyse(void)
  {
//--- stage: irregular = differs from the last regular offset and from the next anchor
   bool have_last=false;
   int  last_regular=0;
   for(int i=0; i<m_anchors; i++)
     {
      if(have_last && i+1<m_anchors && m_offset[i]!=last_regular && m_offset[i]!=m_offset[i+1])
        {
         m_irregular[i]=1;
         m_irregular_count++;
         continue;
        }
      have_last=true;
      last_regular=m_offset[i];
     }
//--- stage: the regular sequence, its distinct offsets and its switches
   int prev=-1;
   for(int i=0; i<m_anchors; i++)
     {
      if(m_irregular[i]!=0)
         continue;
      if(prev<0)
         m_first_utc=m_utc[i];
      bool known=false;
      for(int k=0; k<ArraySize(m_seen) && !known; k++)
         known=(m_seen[k]==m_offset[i]);
      if(!known)
        {
         int size=ArraySize(m_seen);
         ArrayResize(m_seen,size+1,8);
         m_seen[size]=m_offset[i];
        }
      if(prev>=0 && m_offset[prev]!=m_offset[i])
        {
         ArrayResize(m_sw_before,m_switches+1,16);
         ArrayResize(m_sw_after,m_switches+1,16);
         ArrayResize(m_sw_cal,m_switches+1,16);
         m_sw_before[m_switches]=prev;
         m_sw_after[m_switches]=i;
         m_sw_cal[m_switches]=Calendar(prev,i);
         m_us+=(m_sw_cal[m_switches]==BCA_CAL_US ? 1 : 0);
         m_eu+=(m_sw_cal[m_switches]==BCA_CAL_EU ? 1 : 0);
         m_switches++;
        }
      prev=i;
     }
   if(prev<0)
      return;
   m_offset_now=m_offset[prev];
   m_last_utc=m_utc[prev];
   ArraySort(m_seen);
//--- stage: regime and whether the regular span holds a US and an EU instant
   m_regime=BCA_REGIME_FIXED;
   if(m_switches>0)
      m_regime=(m_us==m_switches ? BCA_REGIME_US : (m_eu==m_switches ? BCA_REGIME_EU : BCA_REGIME_MIXED));
   bool us=(CBcaCalendar::Inside(BCA_RULE_US,true,m_first_utc,m_last_utc,true) ||
            CBcaCalendar::Inside(BCA_RULE_US,false,m_first_utc,m_last_utc,true));
   bool eu=(CBcaCalendar::Inside(BCA_RULE_EU,true,m_first_utc,m_last_utc,true) ||
            CBcaCalendar::Inside(BCA_RULE_EU,false,m_first_utc,m_last_utc,true));
   m_dst_tested=(us && eu ? 1 : 0);
  }
//+------------------------------------------------------------------+
//| Audits the symbol; a failure is one journal line and a status    |
//+------------------------------------------------------------------+
bool CBcaSymbolAudit::Audit(void)
  {
//--- stage: does the terminal know this symbol at all (SymbolExist selects nothing)
   bool custom=false;
   ResetLastError();
   if(!SymbolExist(m_symbol,custom))
     {
      m_status=BCA_STATUS_UNKNOWN;
      PrintFormat("%s: %s is not a symbol of this terminal, it is skipped",BCA_NAME,m_symbol);
      return(false);
     }
//--- stage: the newest H1 bar closes the window, SERIES_FIRSTDATE may shorten it
   datetime times[];
   if(Fetch(true,times)<=0)
     {
      m_status=BCA_STATUS_NO_BARS;
      PrintFormat("%s: %s has no H1 bar (error %d), it is skipped",BCA_NAME,m_symbol,m_read_error);
      return(false);
     }
   m_last=(long)times[0];
   m_t0=m_last-(long)ExtWeeks*BCA_WEEK;
   long first=0;
   if(SeriesInfoInteger(m_symbol,PERIOD_H1,SERIES_FIRSTDATE,first) && first>m_t0)
     {
      m_t0=first;
      PrintFormat("%s: %s H1 history starts %s, window shortened to %s weeks",BCA_NAME,m_symbol,BcaTime(first),
                  DoubleToString((m_last-m_t0)/(double)BCA_WEEK,1));
     }
//--- stage: the bars of the window, ascending, once each
   int got=Fetch(false,times);
   if(got<0)
     {
      m_status=BCA_STATUS_NO_READ;
      PrintFormat("%s: %s H1 bars %s to %s could not be read (error %d), the symbol is skipped",BCA_NAME,m_symbol,
                  BcaTime(m_t0),BcaTime(m_last),m_read_error);
      return(false);
     }
   long bars[];
   int  count=0;
   ArrayResize(bars,MathMax(got,1));
   for(int i=0; i<got; i++)
      if((long)times[i]>=m_t0 && (long)times[i]<=m_last)
         bars[count++]=(long)times[i];
   ArrayResize(bars,count);
   ArraySort(bars);
   int kept=0;
   for(int i=0; i<count; i++)
      if(kept==0 || bars[i]!=bars[kept-1])
         bars[kept++]=bars[i];
   m_bars=kept;
//--- stage: server Sunday and Saturday dates with a bar
   long day_seen=-1;
   for(int i=0; i<kept; i++)
     {
      long day=bars[i]/BCA_DAY;
      if(day==day_seen)
         continue;
      day_seen=day;
      int weekday=(int)((day+4)%7);
      m_sundays+=(weekday==0 ? 1 : 0);
      m_saturdays+=(weekday==6 ? 1 : 0);
     }
//--- stage: every gap of InpMinGapHours or more is a market close
   long gap=(long)ExtMinGapHours*BCA_HOUR;
   for(int i=1; i<kept; i++)
      if(bars[i]-bars[i-1]>=gap)
         AddAnchor(bars[i-1],bars[i]);
   Analyse();
   m_status=BCA_STATUS_OK;
   return(true);
  }
//+------------------------------------------------------------------+
//| Distinct regular offsets: minutes joined by | or +H:MM by blanks |
//+------------------------------------------------------------------+
string CBcaSymbolAudit::SeenText(const bool human) const
  {
   string out="";
   for(int k=0; k<ArraySize(m_seen); k++)
      out+=(k>0 ? (human ? " " : "|") : "")+(human ? BcaOffset(m_seen[k]) : IntegerToString(m_seen[k]));
   return(out);
  }
//+------------------------------------------------------------------+
//| Adds the summary row, writes the anchors and the switches file   |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::WriteFiles(CBcaReport &report,string &summary[]) const
  {
   bool   on=Reported();
   string rows[];
   ArrayResize(rows,MathMax(m_anchors,1));
//--- stage: the summary, the contract columns first in their fixed order
   string line=m_symbol+BCA_SEP+IntegerToString(m_t0)+BCA_SEP+IntegerToString(m_last)+BCA_SEP+
               IntegerToString(m_bars)+BCA_SEP+IntegerToString(m_anchors);
   line+=BCA_SEP+BcaCell(on,IntegerToString(m_weekend_count))+BCA_SEP+BcaCell(on,IntegerToString(m_anchors-m_weekend_count))+
         BCA_SEP+BcaCell(on,IntegerToString(m_irregular_count))+BCA_SEP+BcaCell(on,IntegerToString(m_offset_now))+
         BCA_SEP+BcaCell(on,SeenText(false))+BCA_SEP+BcaCell(on,IntegerToString(m_switches))+
         BCA_SEP+BcaCell(on,IntegerToString(m_us))+BCA_SEP+BcaCell(on,IntegerToString(m_eu))+
         BCA_SEP+BcaCell(on,IntegerToString(m_switches-m_us-m_eu))+BCA_SEP+BcaCell(on,ExtRegimeNames[m_regime])+
         BCA_SEP+BcaCell(on,IntegerToString(m_dst_tested))+BCA_SEP+BcaCell(on,IntegerToString(m_sundays))+
         BCA_SEP+BcaCell(on,IntegerToString(m_saturdays));
//--- stage: the columns a human reads, after the contract
   line+=BCA_SEP+BcaTime(m_t0)+BCA_SEP+BcaTime(m_last)+BCA_SEP+IntegerToString(m_retries);
   BcaAdd(summary,line);
//--- stage: one row per anchor, irregular ones included
   for(int i=0; i<m_anchors; i++)
      rows[i]=m_symbol+BCA_SEP+BcaTime(m_close[i])+BCA_SEP+BcaTime(m_utc[i])+BCA_SEP+IntegerToString(m_offset[i])+
              BCA_SEP+(m_weekend[i]!=0 ? "weekend" : "holiday")+BCA_SEP+DoubleToString((m_reopen[i]-m_close[i])/3600.0,2)+
              BCA_SEP+BcaTime(m_reopen[i])+BCA_SEP+(m_irregular[i]!=0 ? "irregular" : "regular");
   report.WriteTable(BcaSafeName(m_symbol)+"_anchors","symbol;close;close_utc;offset_minutes;kind;gap_hours;reopen;status",
                     rows,m_anchors);
//--- stage: one row per switch of the regular sequence
   for(int k=0; k<m_switches; k++)
      rows[k]=m_symbol+BCA_SEP+BcaTime(m_close[m_sw_before[k]])+BCA_SEP+BcaTime(m_close[m_sw_after[k]])+
              BCA_SEP+IntegerToString(m_offset[m_sw_before[k]])+BCA_SEP+IntegerToString(m_offset[m_sw_after[k]])+
              BCA_SEP+ExtCalNames[m_sw_cal[k]];
   report.WriteTable(BcaSafeName(m_symbol)+"_switches","symbol;before_close;after_close;from_minutes;to_minutes;calendar",
                     rows,m_switches);
  }
//+------------------------------------------------------------------+
//| Journal: one line per symbol and its first irregular anchors     |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::JournalLines(string &lines[]) const
  {
   ArrayResize(lines,0,16);
   if(!Audited())
      return;
   if(!Reported())
     {
      BcaAdd(lines,StringFormat("%s  %d anchor(s) | no market close found (24/7 symbol?), nothing derived | %s H1 bars from %s",
                                m_symbol,m_anchors,IntegerToString(m_bars),BcaTime(m_t0)));
      return;
     }
   string switches=IntegerToString(m_switches)+(m_switches==1 ? " switch" : " switches");
   for(int k=0; k<m_switches; k++)
      switches+=(k==0 ? ": " : ", ")+BcaTime(m_close[m_sw_after[k]],false)+" "+ExtCalNames[m_sw_cal[k]]+" "+
                StringFormat("%+d",m_offset[m_sw_after[k]]-m_offset[m_sw_before[k]]);
   BcaAdd(lines,StringFormat("%s  %d anchors (%d weekend, %d holiday) | now UTC%s | seen %s | %s | regime %s, dst_tested %d | irregular %d | Sunday bars %d days | %s H1 bars from %s",
                             m_symbol,m_anchors,m_weekend_count,m_anchors-m_weekend_count,BcaOffset(m_offset_now),
                             SeenText(true),switches,ExtRegimeNames[m_regime],m_dst_tested,m_irregular_count,m_sundays,
                             IntegerToString(m_bars),BcaTime(m_t0)));
//--- stage: the first irregular anchors with both raw neighbours
   int shown=0;
   for(int i=1; i<m_anchors-1 && shown<ExtMaxExamples; i++)
     {
      if(m_irregular[i]==0)
         continue;
      shown++;
      BcaAdd(lines,StringFormat("%s  irregular anchor %d of %d: close %s offset %s, before %s %s, after %s %s",m_symbol,
                                shown,m_irregular_count,BcaTime(m_close[i]),BcaOffset(m_offset[i]),BcaTime(m_close[i-1]),
                                BcaOffset(m_offset[i-1]),BcaTime(m_close[i+1]),BcaOffset(m_offset[i+1])));
     }
  }
//+------------------------------------------------------------------+
//| Header row of the result table, shared by panel and journal      |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::HeaderCells(string &cells[][BCA_COLS],const int row)
  {
   cells[row][0]="Symbol";
   cells[row][1]="Anchors";
   cells[row][2]="Now";
   cells[row][3]="Calendar";
   cells[row][4]="Switches";
   cells[row][5]="Irregular";
   cells[row][6]="Sun days";
  }
//+------------------------------------------------------------------+
//| One table row; a skipped symbol shows its status, not numbers    |
//+------------------------------------------------------------------+
void CBcaSymbolAudit::Cells(string &cells[][BCA_COLS],const int row) const
  {
   for(int c=0; c<BCA_COLS; c++)
      cells[row][c]="-";
   cells[row][0]=m_symbol;
   if(!Audited())
     {
      cells[row][1]=ExtStatusNames[(int)m_status];
      return;
     }
   cells[row][1]=IntegerToString(m_anchors);
   if(!Reported())
     {
      cells[row][3]="no close";
      return;
     }
   cells[row][2]="UTC"+BcaOffset(m_offset_now);
   cells[row][3]=ExtRegimeNames[m_regime]+(m_regime!=BCA_REGIME_FIXED ? "" : (m_dst_tested!=0 ? ", tested" : ", untested"));
   cells[row][4]=IntegerToString(m_switches);
   cells[row][5]=IntegerToString(m_irregular_count);
   cells[row][6]=IntegerToString(m_sundays);
  }
//+------------------------------------------------------------------+
//| Overall verdict, live cross-check and session open projection    |
//+------------------------------------------------------------------+
class CBcaVerdict
  {
private:
   bool              m_valid;             // at least one symbol is reported
   int               m_offset;            // most common offset_now, minutes
   int               m_regime;            // most common regime
   int               m_symbols;           // reported symbols
   int               m_agree;             // reported symbols with the verdict offset and regime
   int               m_tested;            // dst_tested of the reference symbol
   int               m_base;              // offset outside DST, minutes, for a US or EU regime
   bool              m_live_on;           // the live clock was read
   int               m_live;              // server - GMT, minutes
   string            m_live_text;         // the live line of the panel
   string            m_lines[];           // journal: verdict, disagreements, live, projection
   string            m_rows[];            // projection CSV rows
   int               m_count;             // projection rows
   string            m_panel[];           // panel: opens of the first date, then change rows

public:
                     CBcaVerdict(void) { Reset(); }
   void              Reset(void);
   void              Build(CBcaSymbolAudit &audits[],const int count);
   void              Live(void);
   void              Project(const long now);
   int               ServerOffset(const long moment) const;
   void              Write(CBcaReport &report) const;
   string            Title(void) const;
   void              Journal(CBcaReport &report) const { report.Journal(m_lines); }
   string            LiveText(void) const { return(m_live_text); }
   void              PanelLines(string &lines[]) const;
  };
//+------------------------------------------------------------------+
//| Everything back to the start                                     |
//+------------------------------------------------------------------+
void CBcaVerdict::Reset(void)
  {
   m_valid=false;
   m_offset=0;
   m_regime=BCA_REGIME_FIXED;
   m_symbols=0;
   m_agree=0;
   m_tested=0;
   m_base=0;
   m_live_on=false;
   m_live=0;
   m_live_text="";
   ArrayFree(m_lines);
   ArrayFree(m_rows);
   m_count=0;
   ArrayFree(m_panel);
  }
//+------------------------------------------------------------------+
//| Most common offset_now and regime, ties go to the first symbol   |
//+------------------------------------------------------------------+
void CBcaVerdict::Build(CBcaSymbolAudit &audits[],const int count)
  {
   int best_offset=0,best_regime=0;
   for(int i=0; i<count; i++)
     {
      if(!audits[i].Reported())
         continue;
      m_symbols++;
      int same_offset=0,same_regime=0;
      for(int j=0; j<count; j++)
        {
         if(!audits[j].Reported())
            continue;
         same_offset+=(audits[j].OffsetNow()==audits[i].OffsetNow() ? 1 : 0);
         same_regime+=(audits[j].Regime()==audits[i].Regime() ? 1 : 0);
        }
      //--- strictly more wins, so the value seen first in input order keeps a tie
      if(same_offset>best_offset)
        {
         best_offset=same_offset;
         m_offset=audits[i].OffsetNow();
        }
      if(same_regime>best_regime)
        {
         best_regime=same_regime;
         m_regime=audits[i].Regime();
        }
     }
   if(m_symbols==0)
     {
      BcaAdd(m_lines,"verdict: no symbol has 2 market closes in its window, no verdict and no projection");
      return;
     }
   m_valid=true;
//--- stage: agreement; the reference symbol fixes the DST state of the offset
   int reference=-1;
   for(int i=0; i<count; i++)
     {
      if(!audits[i].Reported() || audits[i].OffsetNow()!=m_offset)
         continue;
      bool same=(audits[i].Regime()==m_regime);
      m_agree+=(same ? 1 : 0);
      if(reference<0 || (same && audits[reference].Regime()!=m_regime))
         reference=i;
     }
   m_tested=audits[reference].DstTested();
   m_base=m_offset;
   if(m_regime==BCA_REGIME_US && CBcaCalendar::Dst(BCA_RULE_US,audits[reference].LastRegularUtc()))
      m_base-=60;
   if(m_regime==BCA_REGIME_EU && CBcaCalendar::Dst(BCA_RULE_EU,audits[reference].LastRegularUtc()))
      m_base-=60;
   BcaAdd(m_lines,StringFormat("verdict: server clock UTC%s now, regime %s, dst_tested %d (%s), %d of %d reported symbol(s) agree",
                               BcaOffset(m_offset),ExtRegimeNames[m_regime],m_tested,audits[reference].Name(),m_agree,
                               m_symbols));
   for(int i=0; i<count; i++)
     {
      if(audits[i].Audited() && !audits[i].Reported())
         BcaAdd(m_lines,"verdict: "+audits[i].Name()+" is left out, fewer than 2 market closes");
      if(audits[i].Reported() && (audits[i].OffsetNow()!=m_offset || audits[i].Regime()!=m_regime))
         BcaAdd(m_lines,StringFormat("verdict: %s disagrees: UTC%s now, regime %s",audits[i].Name(),
                                     BcaOffset(audits[i].OffsetNow()),ExtRegimeNames[audits[i].Regime()]));
     }
  }
//+------------------------------------------------------------------+
//| Live cross-check: TimeTradeServer() - TimeGMT() against history  |
//+------------------------------------------------------------------+
void CBcaVerdict::Live(void)
  {
   if(MQLInfoInteger(MQL_TESTER)!=0)
     {
      m_live_text="Live clock: not available in the Strategy Tester";
      BcaAdd(m_lines,"live clock: not available in the Strategy Tester");
      return;
     }
//--- without a connection TimeTradeServer() has nothing to follow
   if(TerminalInfoInteger(TERMINAL_CONNECTED)==0)
     {
      m_live_text="Live clock: terminal not connected, not checked";
      BcaAdd(m_lines,"live clock: the terminal is not connected to the trade server, TimeTradeServer() is not reliable - not checked");
      return;
     }
   m_live_on=true;
   m_live=(int)MathRound(((long)TimeTradeServer()-(long)TimeGMT())/60.0);
   string head="server - GMT = "+BcaOffset(m_live);
   if(!m_valid)
     {
      m_live_text="Live clock: "+head+" (no history verdict)";
      BcaAdd(m_lines,"live clock: "+head+" (history has no verdict)");
      return;
     }
   int diff=(m_live>m_offset ? m_live-m_offset : m_offset-m_live);
   m_live_text="Live clock: "+head+" (history "+BcaOffset(m_offset)+") "+
               (diff==0 ? "OK" : "DIFFERS by "+IntegerToString(diff)+" min");
   BcaAdd(m_lines,"live clock: "+head+" (history says "+BcaOffset(m_offset)+") "+
          (diff==0 ? "OK" : "DIFFERS by "+IntegerToString(diff)+
           " min - TimeGMT() comes from this PC's clock and time zone, check them"));
  }
//+------------------------------------------------------------------+
//| Server offset at a UTC instant under the verdict, minutes        |
//+------------------------------------------------------------------+
int CBcaVerdict::ServerOffset(const long moment) const
  {
   if(m_regime==BCA_REGIME_US)
      return(m_base+(CBcaCalendar::Dst(BCA_RULE_US,moment) ? 60 : 0));
   if(m_regime==BCA_REGIME_EU)
      return(m_base+(CBcaCalendar::Dst(BCA_RULE_EU,moment) ? 60 : 0));
   return(m_offset);
  }
//+------------------------------------------------------------------+
//| Session opens in server time, Monday to Friday, change rows only |
//+------------------------------------------------------------------+
void CBcaVerdict::Project(const long now)
  {
   if(!m_valid)
      return;
   long start=now-now%BCA_DAY;
   int  days=ExtProjectWeeks*7;
   int  prev[BCA_MARKETS];
   bool have=false;
   ArrayInitialize(prev,0);
   BcaAdd(m_lines,StringFormat("projection: %d week(s) from %s, server offset %s%s",ExtProjectWeeks,BcaTime(start,false),
                               (m_regime==BCA_REGIME_US || m_regime==BCA_REGIME_EU ? ExtRegimeNames[m_regime]+" DST, "+
                                BcaOffset(m_base)+" / "+BcaOffset(m_base+60) : "UTC"+BcaOffset(m_offset)),
                               (m_regime==BCA_REGIME_MIXED ? " assumed (regime mixed)" : "")));
   for(int d=0; d<days; d++)
     {
      long day=start+(long)d*BCA_DAY;
      int  weekday=CBcaCalendar::Weekday(day);
      if(weekday<1 || weekday>5)
         continue;
      int    minute[BCA_MARKETS];
      string cell[BCA_MARKETS];
      string changed="",text="";
      for(int m=0; m<BCA_MARKETS; m++)
        {
         long utc=CBcaCalendar::LocalToUtc(day,ExtOpens[m],m);
         long server=utc+(long)ServerOffset(utc)*60;
         minute[m]=(int)((server%BCA_DAY)/60);
         cell[m]=(server-server%BCA_DAY!=day ? BcaDayName(CBcaCalendar::Weekday(server))+" " : "")+BcaClock(minute[m]);
         text+="  "+ExtMarketNames[m]+" "+cell[m];
         if(have && minute[m]!=prev[m])
           {
            changed+=(changed=="" ? "" : "|")+ExtMarketKeys[m];
            //--- the panel keeps the 2 lines of the opens and 4 change rows, one market each
            if(ArraySize(m_panel)<2+BCA_PANEL_CHANGES)
               BcaAdd(m_panel,BcaTime(day,false)+" "+BcaDayName(weekday)+"  "+ExtMarketNames[m]+" "+cell[m]+" (was "+
                      BcaClock(prev[m])+")");
           }
         prev[m]=minute[m];
        }
      if(!have)
        {
         changed="first";
         BcaAdd(m_panel,"Session opens in server time from "+BcaTime(day,false)+" "+BcaDayName(weekday)+":");
         BcaAdd(m_panel,StringSubstr(text,2));
        }
      have=true;
      if(changed=="")
         continue;
      int offset=ServerOffset(day+BCA_DAY/2);
      ArrayResize(m_rows,m_count+1,16);
      m_rows[m_count]=BcaTime(day,false)+BCA_SEP+BcaDayName(weekday)+BCA_SEP+IntegerToString(offset)+BCA_SEP+cell[0]+
                      BCA_SEP+cell[1]+BCA_SEP+cell[2]+BCA_SEP+cell[3]+BCA_SEP+changed;
      if(m_count<BCA_PRINT_ROWS)
         BcaAdd(m_lines,StringFormat("projection %s %s  offset %s%s  (%s)",BcaTime(day,false),BcaDayName(weekday),
                                     BcaOffset(offset),text,changed));
      m_count++;
     }
   if(m_count>BCA_PRINT_ROWS)
      BcaAdd(m_lines,StringFormat("projection: %d more row(s) in the projection file",m_count-BCA_PRINT_ROWS));
  }
//+------------------------------------------------------------------+
//| Writes the verdict row and the projection file                   |
//+------------------------------------------------------------------+
void CBcaVerdict::Write(CBcaReport &report) const
  {
   string row[1];
   row[0]=BcaCell(m_valid,IntegerToString(m_offset))+BCA_SEP+BcaCell(m_valid,ExtRegimeNames[m_regime])+BCA_SEP+
          IntegerToString(m_symbols)+BCA_SEP+IntegerToString(m_agree)+BCA_SEP+BcaCell(m_live_on,IntegerToString(m_live));
   report.WriteTable("verdict","offset_now;regime;symbols;agree;live_minutes",row,1);
   if(m_valid)
      report.WriteTable("projection","date;weekday;server_offset_minutes;london;new_york;tokyo;sydney;changed",m_rows,
                        m_count);
  }
//+------------------------------------------------------------------+
//| Title line of the panel                                          |
//+------------------------------------------------------------------+
string CBcaVerdict::Title(void) const
  {
   if(!m_valid)
      return("Server clock: no verdict, no symbol with 2 market closes");
   string share=IntegerToString(m_agree)+"/"+IntegerToString(m_symbols)+" symbols";
   if(m_regime==BCA_REGIME_FIXED)
      return("Server clock: fixed UTC"+BcaOffset(m_offset)+", no DST ("+(m_tested!=0 ? "tested" : "not tested")+
             ", "+share+")");
   if(m_regime==BCA_REGIME_MIXED)
      return("Server clock: UTC"+BcaOffset(m_offset)+" now, mixed switches, assumed fixed ("+share+")");
   return("Server clock: UTC"+BcaOffset(m_offset)+", "+ExtRegimeNames[m_regime]+" DST calendar ("+share+")");
  }
//+------------------------------------------------------------------+
//| Appends the opens of the first date and the change rows          |
//+------------------------------------------------------------------+
void CBcaVerdict::PanelLines(string &lines[]) const
  {
   for(int i=0; i<ArraySize(m_panel); i++)
      BcaAdd(lines,m_panel[i]);
  }
//--- global objects and counters of the expert
CBcaReport        ExtReport;                       // journal lines and the CSV files
CBcaPanel         ExtPanel;                        // the table on the chart
CBcaVerdict       ExtVerdict;                      // verdict, live clock and projection of the last pass
CBcaSymbolAudit   ExtAudits[BCA_MAX_SYMBOLS];      // one audit per symbol of the list
string            ExtSymbols[BCA_MAX_SYMBOLS];     // the resolved symbol list
int               ExtCount=0;                      // symbols in the list
string            ExtPrefix="";                    // file name prefix of this instance
bool              ExtReady=false;                  // Init() reached its end
bool              ExtPanelOn=false;                // the panel objects exist
bool              ExtFirstDone=false;              // the first pass has run
int               ExtPulses=0;                     // pulses counted while waiting for the history
int               ExtPass=0;                       // passes finished
datetime          ExtLastPass=0;                   // server time the last pass started
long              ExtLastPassClock=0;              // refresh clock (seconds) when the last pass started
ulong             ExtWallUs=0;                     // duration of the last pass, microseconds
int               ExtReported=0;                   // symbols with 2 or more anchors
int               ExtNoClose=0;                    // symbols audited with fewer than 2 anchors
int               ExtFailed=0;                     // symbols skipped
//+------------------------------------------------------------------+
//| The whole expert back to its starting state (pitfall C24)        |
//+------------------------------------------------------------------+
void BcaReset(void)
  {
   ExtReport.Reset();
   ExtPanel.Reset();
   ExtVerdict.Reset();
   for(int i=0; i<BCA_MAX_SYMBOLS; i++)
     {
      ExtAudits[i].Reset();
      ExtSymbols[i]="";
     }
   ExtCount=0;
   ExtPrefix="";
   ExtReady=false;
   ExtPanelOn=false;
   ExtFirstDone=false;
   ExtPulses=0;
   ExtPass=0;
   ExtLastPass=0;
   ExtLastPassClock=0;
   ExtWallUs=0;
   ExtReported=0;
   ExtNoClose=0;
   ExtFailed=0;
   ExtWeeks=60;
   ExtMinGapHours=20;
   ExtProjectWeeks=8;
   ExtMaxExamples=5;
   ExtRefreshMinutes=0;
  }
//+------------------------------------------------------------------+
//| Adds a symbol once; a duplicate would count twice in the verdict |
//+------------------------------------------------------------------+
void BcaAddSymbol(const string name)
  {
   if(name=="")
      return;
   for(int i=0; i<ExtCount; i++)
      if(ExtSymbols[i]==name)
         return;
   if(ExtCount>=BCA_MAX_SYMBOLS)
     {
      PrintFormat("%s: the list is full at %d symbols, %s is not audited",BCA_NAME,BCA_MAX_SYMBOLS,name);
      return;
     }
   ExtSymbols[ExtCount++]=name;
  }
//+------------------------------------------------------------------+
//| Resolves the symbol input; the Market Watch is never changed     |
//+------------------------------------------------------------------+
void BcaBuildSymbolList(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
     {
      int total=SymbolsTotal(true);
      for(int i=0; i<total; i++)
         BcaAddSymbol(SymbolName(i,true));
     }
   else
     {
      //--- a list may be separated by commas or by semicolons
      StringReplace(text,";",",");
      string parts[];
      int    count=StringSplit(text,(ushort)',',parts);
      for(int i=0; i<count; i++)
        {
         StringTrimLeft(parts[i]);
         StringTrimRight(parts[i]);
         BcaAddSymbol(parts[i]);
        }
     }
   if(ExtCount<=0)
      BcaAddSymbol(Symbol());
  }
//+------------------------------------------------------------------+
//| Tag of the symbol selection for the file names                   |
//+------------------------------------------------------------------+
string BcaSymbolsTag(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
      return("MarketWatch");
   if(ExtCount==1)
      return(BcaSafeName(ExtSymbols[0]));
   return(BcaSafeName(ExtSymbols[0])+"_plus"+IntegerToString(ExtCount-1));
  }
//+------------------------------------------------------------------+
//| Clamps one integer input and says so in the journal              |
//+------------------------------------------------------------------+
int BcaClamp(const string name,const int value,const int low,const int high)
  {
   int used=MathMin(high,MathMax(low,value));
   if(used!=value)
      PrintFormat("%s: %s %d is outside %d..%d, %d is used",BCA_NAME,name,value,low,high,used);
   return(used);
  }
//+------------------------------------------------------------------+
//| Parses HH:MM into minutes of the day; a bad text keeps a default |
//+------------------------------------------------------------------+
int BcaParseOpen(const string name,const string value,const int fallback)
  {
   string text=value;
   StringTrimLeft(text);
   StringTrimRight(text);
   string parts[];
   bool   good=(StringSplit(text,(ushort)':',parts)==2 && StringLen(parts[0])>=1 && StringLen(parts[0])<=2 &&
                StringLen(parts[1])==2);
   for(int p=0; p<2 && good; p++)
      for(int i=0; i<StringLen(parts[p]) && good; i++)
         good=(StringGetCharacter(parts[p],i)>='0' && StringGetCharacter(parts[p],i)<='9');
   if(good)
     {
      int hour=(int)StringToInteger(parts[0]);
      int minute=(int)StringToInteger(parts[1]);
      if(hour<=23 && minute<=59)
         return(hour*60+minute);
     }
   PrintFormat("%s: %s \"%s\" is not a valid HH:MM time, %s is used",BCA_NAME,name,value,BcaClock(fallback));
   return(fallback);
  }
//+------------------------------------------------------------------+
//| Prints the settings of the run once, after the clamping          |
//+------------------------------------------------------------------+
void BcaPrintStartBlock(void)
  {
   Print("=== "+BCA_TITLE+" ==========================================");
   PrintFormat("symbols        : %d (%s)",ExtCount,(InpSymbols=="" ? "chart symbol" :
               (InpSymbols=="*" ? "Market Watch" : "list")));
   PrintFormat("window         : %d weeks of H1 bars up to the newest bar; a gap of %d h or more is a market close",
               ExtWeeks,ExtMinGapHours);
   Print("anchor         : the FX week closes at 17:00 New York; offset = server close - that instant in UTC");
   PrintFormat("projection     : %d week(s); local opens London %s, New York %s, Tokyo %s, Sydney %s",ExtProjectWeeks,
               BcaClock(ExtOpens[0]),BcaClock(ExtOpens[1]),BcaClock(ExtOpens[2]),BcaClock(ExtOpens[3]));
   PrintFormat("refresh        : %s",(ExtRefreshMinutes>0 ? IntegerToString(ExtRefreshMinutes)+
                                      " minutes of server time" : "once"));
   PrintFormat("files          : %s",(InpWriteCsv ? BCA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "off"));
   for(int i=0; i<ExtCount; i++)
      PrintFormat("symbol %d of %d  : %s",i+1,ExtCount,ExtSymbols[i]);
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Fills the result table: the header and at most rows symbols      |
//+------------------------------------------------------------------+
int BcaBuildCells(string &cells[][BCA_COLS],const int rows)
  {
   int shown=MathMin(rows,ExtCount);
   ArrayResize(cells,shown+1);
   CBcaSymbolAudit::HeaderCells(cells,0);
   for(int i=0; i<shown; i++)
      ExtAudits[i].Cells(cells,i+1);
   return(shown+1);
  }
//+------------------------------------------------------------------+
//| Prints the result table of one pass, the files and the panel     |
//+------------------------------------------------------------------+
void BcaPrintSummary(void)
  {
   Print("=== "+BCA_TITLE+" - result of pass "+IntegerToString(ExtPass)+" ========");
   string cells[][BCA_COLS];
   int    rows=BcaBuildCells(cells,ExtCount);
   int    widths[BCA_COLS];
   BcaColumnWidths(cells,rows,widths);
   for(int r=0; r<rows; r++)
      Print(BcaRowText(cells,r,widths));
   PrintFormat("symbols        : %d reported, %d without market close, %d skipped",ExtReported,ExtNoClose,ExtFailed);
   PrintFormat("files          : %d written, pattern %s\\%s_*.csv",ExtReport.Files(),BCA_FOLDER,ExtPrefix);
   PrintFormat("wall time      : %s ms",DoubleToString(ExtWallUs/1000.0,1));
   if(ExtPanelOn)
      PrintFormat("panel          : %d x %d pixels, %d labels, widest line %d characters",ExtPanel.WidthPx(),
                  ExtPanel.HeightPx(),ExtPanel.Labels(),ExtPanel.Widest());
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Redraws the panel with the numbers of the last pass              |
//+------------------------------------------------------------------+
void BcaUpdatePanel(void)
  {
   if(!ExtPanelOn)
      return;
   string top[3];
   string bottom[];
   string cells[][BCA_COLS];
   top[0]=BCA_TITLE+"   "+(ExtLastPass>0 ? TimeToString(ExtLastPass,TIME_DATE|TIME_MINUTES) : "-")+"   "+
          IntegerToString(ExtWeeks)+" weeks of H1, close = gap >= "+IntegerToString(ExtMinGapHours)+" h"+
          (ExtFirstDone ? "" : "   waiting for the history");
   top[1]=(ExtFirstDone ? ExtVerdict.Title() : "Server clock: -");
   top[2]=(ExtFirstDone ? ExtVerdict.LiveText() : "Live clock: -");
   int rows=BcaBuildCells(cells,(ExtFirstDone ? BCA_PANEL_ROWS : 0));
//--- stage: the opens, the change rows, the rest of the list and the files
   if(ExtFirstDone)
      ExtVerdict.PanelLines(bottom);
   if(ExtFirstDone && ExtCount>BCA_PANEL_ROWS)
      BcaAdd(bottom,"... and "+IntegerToString(ExtCount-BCA_PANEL_ROWS)+" more symbols in the journal and the CSV");
   BcaAdd(bottom,(InpWriteCsv ? BCA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "CSV off"));
   ExtPanel.Update(top,cells,rows,bottom);
  }
//+------------------------------------------------------------------+
//| Before the first series request: names listed symbols that are   |
//| not in the Market Watch (a first download may make MT5 add them) |
//+------------------------------------------------------------------+
void BcaMarketWatchNotes(void)
  {
   for(int i=0; i<ExtCount; i++)
     {
      bool custom=false;
      if(!SymbolExist(ExtSymbols[i],custom))
         continue;
      if(SymbolInfoInteger(ExtSymbols[i],SYMBOL_SELECT)==0)
         PrintFormat("%s: %s is not in the Market Watch; if its H1 history has to be downloaded, the terminal"
                     " adds it there (MT5 behaviour, this tool never selects a symbol)",BCA_NAME,ExtSymbols[i]);
     }
  }
//+------------------------------------------------------------------+
//| Tells whether the H1 series of every known symbol is built       |
//+------------------------------------------------------------------+
bool BcaHistoryReady(void)
  {
   for(int i=0; i<ExtCount; i++)
     {
      bool custom=false;
      long built=0;
      if(!SymbolExist(ExtSymbols[i],custom))
         continue;
      if(!SeriesInfoInteger(ExtSymbols[i],PERIOD_H1,SERIES_SYNCHRONIZED,built) || built==0)
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| One pass over the symbol list; a failure costs one symbol        |
//+------------------------------------------------------------------+
void BcaRunPass(void)
  {
   ExtPass++;
   ExtLastPass=BcaNow();
   ExtLastPassClock=BcaRefreshClock();
   ulong started=GetMicrosecondCount();
   ExtReported=0;
   ExtNoClose=0;
   ExtFailed=0;
   ExtReport.Open(ExtPrefix);
   ExtVerdict.Reset();
   PrintFormat("%s: pass %d starts on %d symbol(s), server time %s",BCA_NAME,ExtPass,ExtCount,
               TimeToString(ExtLastPass,TIME_DATE|TIME_SECONDS));
   string summary[];
   for(int i=0; i<ExtCount; i++)
     {
      ExtAudits[i].SetSymbol(ExtSymbols[i]);
      if(!ExtAudits[i].Audit())
        {
         ExtFailed++;
         continue;
        }
      string lines[];
      ExtAudits[i].WriteFiles(ExtReport,summary);
      ExtAudits[i].JournalLines(lines);
      ExtReport.Journal(lines);
      if(ExtAudits[i].Reported())
         ExtReported++;
      else
         ExtNoClose++;
     }
   ExtReport.WriteTable("summary","symbol;from;to;h1_bars;anchors;weekend_anchors;holiday_anchors;irregular;offset_now;"
                        "offsets_seen;switches;us_switches;eu_switches;other_switches;regime;dst_tested;sunday_days;"
                        "saturday_days;from_time;to_time;read_retries",summary,ArraySize(summary));
//--- stage: verdict, live clock and projection
   ExtVerdict.Build(ExtAudits,ExtCount);
   ExtVerdict.Live();
   ExtVerdict.Project((long)BcaNow());
   ExtVerdict.Write(ExtReport);
   ExtVerdict.Journal(ExtReport);
   ExtWallUs=GetMicrosecondCount()-started;
//--- stage: the panel first, so the summary reports its real size
   BcaUpdatePanel();
   BcaPrintSummary();
  }
//+------------------------------------------------------------------+
//| Reads the inputs, resolves the symbols and prepares the panel    |
//+------------------------------------------------------------------+
void BcaInit(void)
  {
//--- stage: a previous run can still be in these objects, see BcaReset()
   BcaReset();
   ExtWeeks=BcaClamp("InpWeeks",InpWeeks,2,520);
   ExtMinGapHours=BcaClamp("InpMinGapHours",InpMinGapHours,6,60);
   ExtProjectWeeks=BcaClamp("InpProjectWeeks",InpProjectWeeks,1,52);
   ExtMaxExamples=BcaClamp("InpMaxExamples",InpMaxExamples,0,1000);
   ExtRefreshMinutes=BcaClamp("InpRefreshMinutes",InpRefreshMinutes,0,10080);
   ExtOpens[0]=BcaParseOpen("InpLondonOpen",InpLondonOpen,480);
   ExtOpens[1]=BcaParseOpen("InpNewYorkOpen",InpNewYorkOpen,480);
   ExtOpens[2]=BcaParseOpen("InpTokyoOpen",InpTokyoOpen,540);
   ExtOpens[3]=BcaParseOpen("InpSydneyOpen",InpSydneyOpen,420);
   BcaBuildSymbolList();
   ExtPrefix=BcaSymbolsTag()+"_"+IntegerToString(ExtWeeks)+"w_"+IntegerToString(ChartID());
//--- stage: the panel; the tester without visual mode has no chart
   if(InpShowPanel)
     {
      if(MQLInfoInteger(MQL_TESTER)!=0 && MQLInfoInteger(MQL_VISUAL_MODE)==0)
         PrintFormat("%s: the panel stays off, the tester runs without visual mode",BCA_NAME);
      else
         ExtPanelOn=ExtPanel.Create();
     }
   BcaPrintStartBlock();
//--- the flag is set last: OnDeinit() also runs after a failed start
   ExtReady=true;
   BcaUpdatePanel();
  }
//+------------------------------------------------------------------+
//| One pulse of OnTick/OnTimer; the first pass waits for history    |
//+------------------------------------------------------------------+
void BcaPulse(void)
  {
   if(!ExtReady)
      return;
   if(!ExtFirstDone)
     {
      ExtPulses++;
      if(ExtPulses==1)
         BcaMarketWatchNotes();
      if(!BcaHistoryReady() && ExtPulses<BCA_WARMUP_PULSES)
         return;
      ExtFirstDone=true;
      BcaRunPass();
      if(ExtRefreshMinutes<=0)
        {
         EventKillTimer();
         PrintFormat("%s: the audit is finished, the timer is stopped (InpRefreshMinutes = 0)",BCA_NAME);
        }
      return;
     }
   if(ExtRefreshMinutes>0 && BcaRefreshClock()-ExtLastPassClock>=(long)ExtRefreshMinutes*60)
      BcaRunPass();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   BcaInit();
//--- the timer drives the audit when no tick arrives, e.g. on a weekend
   EventSetTimer(1);
//--- no reachable state of this tool is fatal
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(ExtReady)
      PrintFormat("%s: %d pass(es) finished",BCA_NAME,ExtPass);
   ExtPanel.Destroy();
   PrintFormat("%s: stopped, deinitialisation reason %d",BCA_NAME,reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   BcaPulse();
  }
//+------------------------------------------------------------------+
//| Timer function: drives the first pass and the optional re-audit  |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   BcaPulse();
  }
//+------------------------------------------------------------------+
