//+------------------------------------------------------------------+
//|                                      HistoryIntegrityAuditor.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Audits the bar history the terminal feeds to every indicator, every"
#property description "backtest and every expert: OHLC consistency, bar open times, missing"
#property description "bars measured against the quote sessions of the symbol, empty and"
#property description "flat bars, a rebuild of every bar from M1, and the spread column."
#property description "Read only measuring tool - it never calls a trade function."
//--- limits and behaviour constants
#define HIA_NAME            "HistoryIntegrityAuditor"   // program name used in every journal line
#define HIA_TITLE           "History Integrity Auditor" // title of the journal block and of the panel
#define HIA_FOLDER          "HistoryIntegrityAuditor"   // sub folder of MQL5\Files holding the CSV files
#define HIA_MAX_SYMBOLS     128                         // highest number of symbols one run can audit
#define HIA_MAX_BARS        500000                      // memory guard for the bar buffer of one symbol
#define HIA_MAX_SESSIONS    8                           // quote sessions read per weekday
#define HIA_M1_CHUNK_MIN    50000                       // minutes of M1 data copied in one block for C5
#define HIA_MAX_GAP_SCAN    5000000                     // missing openings classified per symbol
#define HIA_MAX_CSV_ROWS    200000                      // disk guard for the findings file
#define HIA_PANEL_ROWS      24                          // symbol rows the panel shows at most
#define HIA_WARMUP_PULSES   15                          // pulses waited for the history before auditing
#define HIA_PANEL_FONT      "Consolas"                  // monospace font, the panel is a table
#define HIA_MAX_LABEL       62                          // characters one OBJ_LABEL can show
#define HIA_COL_BREAK       1                           // marks where a report line may be split
#define HIA_SEPARATOR       ";"                         // column separator of every CSV file
#define HIA_BARS_HEADER     "time;open;high;low;close;tick_volume;real_volume;spread"
#define HIA_SESS_HEADER     "symbol;weekday;from_seconds;to_seconds"
//--- colours of the panel, not inputs: this tool reports numbers, not a design
#define HIA_BACK_COLOR      C'28,28,28'                 // panel background
#define HIA_BORDER_COLOR    clrDimGray                  // panel border
#define HIA_TEXT_COLOR      clrGainsboro                // panel text
#define HIA_CLEAN_COLOR     clrLimeGreen                // title when no finding was counted
#define HIA_DIRTY_COLOR     clrTomato                   // title when at least one finding was counted
//--- width of the report columns, shared by the panel and the journal
#define HIA_W_SYMBOL        12                          // column Symbol
#define HIA_W_NUM           7                           // every counter column
#define HIA_W_WIDE          8                           // column InSess, the largest counter
//+------------------------------------------------------------------+
//| The six checks of the auditor. The name of the value is written  |
//| to the findings CSV and used for the example lines in the        |
//| journal, so every row can be mapped back to its definition.      |
//+------------------------------------------------------------------+
enum ENUM_HIA_CHECK
  {
   HIA_CHECK_OHLC=0,    // C1 OHLC consistency
   HIA_CHECK_TIME,      // C2 bar open times
   HIA_CHECK_GAP,       // C3 missing bars
   HIA_CHECK_EMPTY,     // C4 empty and flat bars
   HIA_CHECK_M1,        // C5 rebuild from M1
   HIA_CHECK_SPREAD     // C6 spread sanity
  };
#define HIA_CHECK_COUNT     6                           // number of values in ENUM_HIA_CHECK
//+------------------------------------------------------------------+
//| What happened to one symbol of the list. Everything except OK is |
//| reported with one journal line and never stops the run, so a     |
//| mistyped symbol costs one symbol and not the whole audit.        |
//+------------------------------------------------------------------+
enum ENUM_HIA_STATUS
  {
   HIA_STATUS_IDLE=0,   // not audited
   HIA_STATUS_UNKNOWN,  // the terminal does not know this symbol
   HIA_STATUS_NO_DATA,  // the symbol is known but no bar could be copied
   HIA_STATUS_OK        // audited
  };
//--- input parameters
input string           InpSymbols           = "";                // Symbols: empty = chart symbol, * = Market Watch, else a list separated by , or ;
input ENUM_TIMEFRAMES  InpTimeframe         = PERIOD_CURRENT;    // Timeframe to audit (0 = current chart period)
input int              InpBars              = 5000;              // Bars to audit per symbol (closed bars, newest first)
input bool             InpCheckOHLC         = true;              // C1: check OHLC consistency
input bool             InpCheckTimes        = true;              // C2: check bar open times (order, duplicates, grid)
input bool             InpCheckGaps         = true;              // C3: check missing bars against the quote sessions
input bool             InpCheckEmpty        = true;              // C4: count empty (no ticks) and flat bars
input bool             InpCheckM1           = true;              // C5: rebuild each bar from M1 and compare
input double           InpM1TolerancePoints = 0.0;               // C5: ignore deviations up to this many points
input int              InpSpreadMaxPoints   = 0;                 // C6: flag bars with spread above this (0 = off)
input int              InpMaxExamples       = 5;                 // Journal: example findings printed per check
input bool             InpWriteFindingsCsv  = true;              // Write one CSV row per finding
input bool             InpWriteBarsCsv      = false;             // Also dump every audited bar (for an independent recount)
input bool             InpShowPanel         = true;              // Draw the result table on the chart
input ENUM_BASE_CORNER InpPanelCorner       = CORNER_LEFT_UPPER; // Panel corner (0 = left upper)
input int              InpPanelFontSize     = 8;                 // Panel font size
input int              InpPanelX            = 10;                // Panel X offset, px
input int              InpPanelY            = 18;                // Panel Y offset, px
input int              InpRefreshMinutes    = 0;                 // Re-audit every N minutes (0 = audit once)
//+------------------------------------------------------------------+
//| One shared answer to the question what time it is now. The       |
//| tester has no wall clock, so a refresh interval built on         |
//| GetTickCount64 would mean once a modelled day there.             |
//+------------------------------------------------------------------+
datetime HiaNow(void)
  {
   return(TimeCurrent());
  }
//+------------------------------------------------------------------+
//| Returns the text right aligned in a field of width characters.   |
//| Text that does not fit is returned unchanged, so a reported      |
//| number can never be cut off by the layout.                       |
//+------------------------------------------------------------------+
string HiaPadLeft(const string text,const int width)
  {
   int len=StringLen(text);
   if(len>=width)
      return(text);
   string pad="";
   for(int i=len; i<width; i++)
      pad+=" ";
   return(pad+text);
  }
//+------------------------------------------------------------------+
//| Returns the text left aligned in a field of width characters.    |
//| Text that does not fit is returned unchanged, so a reported      |
//| symbol name can never be cut off by the layout.                  |
//+------------------------------------------------------------------+
string HiaPadRight(const string text,const int width)
  {
   int len=StringLen(text);
   if(len>=width)
      return(text);
   string out=text;
   for(int i=len; i<width; i++)
      out+=" ";
   return(out);
  }
//+------------------------------------------------------------------+
//| Replaces every character a file name may not contain. A symbol   |
//| written with a slash or a dot would otherwise produce a path the |
//| terminal refuses to open, and the CSV would be lost silently.    |
//+------------------------------------------------------------------+
string HiaSafeName(const string text)
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
//| Timeframe name without the PERIOD_ prefix, so that the report    |
//| shows M15 and not PERIOD_M15.                                    |
//|                                                                  |
//+------------------------------------------------------------------+
string HiaPeriodName(const ENUM_TIMEFRAMES period)
  {
   string name=EnumToString(period);
   if(StringSubstr(name,0,7)=="PERIOD_")
      name=StringSubstr(name,7);
   return(name);
  }
//+------------------------------------------------------------------+
//| Name of a check for the CSV and for the journal examples. The C  |
//| number is part of the name, so a row can be matched with the     |
//| definition table of the description without guessing.            |
//+------------------------------------------------------------------+
string HiaCheckName(const ENUM_HIA_CHECK check)
  {
   switch(check)
     {
      case HIA_CHECK_OHLC :
         return("C1_OHLC");
      case HIA_CHECK_TIME :
         return("C2_TIME");
      case HIA_CHECK_GAP :
         return("C3_GAP");
      case HIA_CHECK_EMPTY :
         return("C4_EMPTY");
      case HIA_CHECK_M1 :
         return("C5_M1");
      case HIA_CHECK_SPREAD :
         return("C6_SPREAD");
      default :
         break;
     }
   return("UNKNOWN");
  }
//+------------------------------------------------------------------+
//| Name of a symbol status for the journal and the summary CSV.     |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
string HiaStatusName(const ENUM_HIA_STATUS status)
  {
   switch(status)
     {
      case HIA_STATUS_OK :
         return("OK");
      case HIA_STATUS_UNKNOWN :
         return("UNKNOWN_SYMBOL");
      case HIA_STATUS_NO_DATA :
         return("NO_DATA");
      default :
         break;
     }
   return("IDLE");
  }
//+------------------------------------------------------------------+
//| Date and time in the one format every file and every journal     |
//| line of this tool uses. An empty stamp becomes a dash, so no     |
//| reader can mistake the year 1970 for a measured value.           |
//+------------------------------------------------------------------+
string HiaTimeText(const datetime value)
  {
   if(value<=0)
      return("-");
   return(TimeToString(value,TIME_DATE|TIME_SECONDS));
  }
//+------------------------------------------------------------------+
//| A counter as text. Every 64 bit value is converted before it     |
//| reaches a format string, so no %d can ever meet a long.          |
//|                                                                  |
//+------------------------------------------------------------------+
string HiaNum(const long value)
  {
   return(IntegerToString(value));
  }
//+------------------------------------------------------------------+
//| Weekday of a server time stamp, 0 = Sunday. That is the          |
//| numbering of ENUM_DAY_OF_WEEK and of MqlDateTime.day_of_week, so |
//| the session table can be indexed with it directly.               |
//+------------------------------------------------------------------+
int HiaWeekday(const datetime value)
  {
   MqlDateTime parts;
   TimeToStruct(value,parts);
   return(parts.day_of_week);
  }
//+------------------------------------------------------------------+
//| One cell of a CSV row. A check that did not run leaves its cell  |
//| empty, because a zero written for "not measured" is the one lie  |
//| a recount cannot catch: it looks exactly like a clean result.    |
//+------------------------------------------------------------------+
string HiaCell(const bool measured,const string text)
  {
   return(measured ? text : "");
  }
//+------------------------------------------------------------------+
//| One cell of a report a human reads: the panel and the journal.   |
//| A check that was switched off prints a dash, never a number. A   |
//| zero printed for "not measured" reads exactly like a clean       |
//| result, and that is the one wrong number this tool exists to     |
//| make impossible, so its own report may not contain it either. A  |
//| check that ran and found nothing still prints 0.                 |
//+------------------------------------------------------------------+
string HiaText(const bool measured,const string text)
  {
   return(measured ? text : "-");
  }
//+------------------------------------------------------------------+
//| Formats seconds since midnight as hh:mm for the human readable   |
//| column of the sessions CSV.                                      |
//|                                                                  |
//+------------------------------------------------------------------+
string HiaClock(const int seconds)
  {
   int value=(seconds>0 ? seconds : 0);
   return(StringFormat("%02d:%02d",value/3600,(value%3600)/60));
  }
//+------------------------------------------------------------------+
//| Draws the result table on the chart. One report line is split    |
//| into several labels, because the text of an OBJ_LABEL is cut off |
//| at about 62 characters and a cut number is a wrong number.       |
//+------------------------------------------------------------------+
class CHiaPanel
  {
private:
   long              m_chart;             // chart the panel belongs to
   string            m_prefix;            // unique name prefix of every own object
   bool              m_created;           // the background object exists
   int               m_rows;              // report lines the panel currently shows
   int               m_columns;           // label columns the panel currently shows
   int               m_x;                 // x distance in pixels
   int               m_y;                 // y distance in pixels
   int               m_pad;               // inner padding in pixels
   int               m_line_height;       // distance between two lines in pixels
   int               m_char_width;        // width of one character in pixels
   int               m_font_size;         // font size in points
   int               m_width_px;          // measured width of the background in pixels
   int               m_height_px;         // measured height of the background in pixels
   int               m_labels;            // labels the last update needed
   int               m_widest;            // characters of the widest report line
   ENUM_BASE_CORNER  m_corner;            // chart corner the panel is anchored to
   ENUM_ANCHOR_POINT m_anchor;            // anchor of every label

   string            LabelName(const int row,const int column) const
     {               return(m_prefix+"L"+IntegerToString(row)+"_"+IntegerToString(column)); }
   bool              CreateLabel(const int row,const int column);
   int               SplitLine(const string text,string &pieces[]) const;

public:
                     CHiaPanel(void);
                    ~CHiaPanel(void);
   void              Reset(void);
   bool              Create(void);
   void              Destroy(void);
   void              Update(const string &lines[],const color title_color);
   int               WidthPx(void)  const { return(m_width_px);  }
   int               HeightPx(void) const { return(m_height_px); }
   int               Labels(void)   const { return(m_labels);    }
   int               Widest(void)   const { return(m_widest);    }
  };
//+------------------------------------------------------------------+
//| Constructor: nothing is drawn before Create() is called, so an   |
//| instance that is never shown leaves no object behind.            |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaPanel::CHiaPanel(void) : m_chart(0),
   m_prefix(""),
   m_created(false),
   m_rows(0),
   m_columns(0),
   m_x(0),
   m_y(0),
   m_pad(6),
   m_line_height(14),
   m_char_width(7),
   m_font_size(8),
   m_width_px(0),
   m_height_px(0),
   m_labels(0),
   m_widest(0),
   m_corner(CORNER_LEFT_UPPER),
   m_anchor(ANCHOR_LEFT_UPPER)
  {
  }
//+------------------------------------------------------------------+
//| Destructor: the objects are removed by Destroy(), which runs     |
//| from OnDeinit() while the chart still exists.                    |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaPanel::~CHiaPanel(void)
  {
  }
//+------------------------------------------------------------------+
//| Puts the object back into its starting state. Changing an input  |
//| reinitialises the expert without reloading the program, so this  |
//| object survives with the geometry of the previous run inside it. |
//+------------------------------------------------------------------+
void CHiaPanel::Reset(void)
  {
   m_chart=0;
   m_prefix="";
   m_created=false;
   m_rows=0;
   m_columns=0;
   m_width_px=0;
   m_height_px=0;
   m_labels=0;
   m_widest=0;
  }
//+------------------------------------------------------------------+
//| Builds the object prefix and the background rectangle. The       |
//| prefix carries the chart id and the first free instance index, so|
//| a second copy cannot overwrite the objects of the first one.     |
//+------------------------------------------------------------------+
bool CHiaPanel::Create(void)
  {
   m_chart=ChartID();
//--- stage: find the first instance index that is not used on this chart
   int instance=0;
   for(; instance<16; instance++)
     {
      string probe=HIA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
      if(ObjectFind(m_chart,probe+"bg")<0)
         break;
     }
   if(instance>15)
      instance=15;
   m_prefix=HIA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
//--- stage: geometry, points stay points and pixels follow the screen dpi
   double scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   m_font_size  =(int)MathMin(20,MathMax(4,InpPanelFontSize));
   m_pad        =(int)MathRound(6.0*scale);
   m_line_height=(int)MathRound(m_font_size*1.70*scale);
   m_char_width =(int)MathCeil(m_font_size*0.75*scale);
//--- one measurement is enough for a monospace font and it keeps the
//    columns of the table where they belong on every screen
   uint text_width=0,text_height=0;
   TextSetFont(HIA_PANEL_FONT,-m_font_size*10,FW_NORMAL,0);
   if(TextGetSize("0123456789",text_width,text_height) && text_width>0)
      m_char_width=(int)MathCeil(text_width/10.0);
   m_x     =(int)MathRound(MathMax(0,InpPanelX)*scale);
   m_y     =(int)MathRound(MathMax(0,InpPanelY)*scale);
   m_corner=InpPanelCorner;
   if(m_corner==CORNER_RIGHT_UPPER)
      m_anchor=ANCHOR_RIGHT_UPPER;
   else
      if(m_corner==CORNER_LEFT_LOWER)
         m_anchor=ANCHOR_LEFT_LOWER;
      else
         if(m_corner==CORNER_RIGHT_LOWER)
            m_anchor=ANCHOR_RIGHT_LOWER;
         else
            m_anchor=ANCHOR_LEFT_UPPER;
//--- stage: background rectangle
   string name=m_prefix+"bg";
   ResetLastError();
   if(!ObjectCreate(m_chart,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      PrintFormat("%s: the panel background could not be created, error %d, panel off",
                  HIA_NAME,GetLastError());
      return(false);
     }
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,m_x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y);
   ObjectSetInteger(m_chart,name,OBJPROP_BGCOLOR,HIA_BACK_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,HIA_BORDER_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(m_chart,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,0);
   m_created=true;
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates one text label of the table and gives it the monospace   |
//| font every line shares, so the columns line up.                  |
//|                                                                  |
//+------------------------------------------------------------------+
bool CHiaPanel::CreateLabel(const int row,const int column)
  {
   string name=LabelName(row,column);
   if(ObjectFind(m_chart,name)>=0)
      return(true);
   if(!ObjectCreate(m_chart,name,OBJ_LABEL,0,0,0))
      return(false);
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_ANCHOR,m_anchor);
   ObjectSetString(m_chart,name,OBJPROP_FONT,HIA_PANEL_FONT);
   ObjectSetInteger(m_chart,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,HIA_TEXT_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Deletes every object of this instance. Only names that carry the |
//| own prefix are removed, so another program on the same chart is  |
//| never touched.                                                   |
//+------------------------------------------------------------------+
void CHiaPanel::Destroy(void)
  {
   if(m_prefix=="")
      return;
   ObjectsDeleteAll(m_chart,m_prefix);
   ChartRedraw(m_chart);
   m_created=false;
   m_rows=0;
   m_columns=0;
   m_labels=0;
  }
//+------------------------------------------------------------------+
//| Redraws the table. Every line is measured first, so the width of |
//| the background matches the text and the pixel size of the panel  |
//| can be reported in the journal instead of being guessed.         |
//+------------------------------------------------------------------+
void CHiaPanel::Update(const string &lines[],const color title_color)
  {
   if(!m_created)
      return;
   int count=ArraySize(lines);
   if(count<=0)
      return;
//--- stage: how many label columns are needed and how wide the widest line is
   string pieces[];
   int    columns=0;
   int    widest=0;
   for(int i=0; i<count; i++)
     {
      int parts=SplitLine(lines[i],pieces);
      columns=MathMax(columns,parts);
      for(int c=0; c<parts; c++)
         if(pieces[c]!="")
            widest=MathMax(widest,c*HIA_MAX_LABEL+StringLen(pieces[c]));
     }
//--- stage: remove the labels that are not needed any more
   for(int r=0; r<m_rows; r++)
      for(int c=0; c<m_columns; c++)
         if(r>=count || c>=columns)
            ObjectDelete(m_chart,LabelName(r,c));
//--- stage: text of every piece of every line
   int used=0;
   for(int i=0; i<count; i++)
     {
      int parts=SplitLine(lines[i],pieces);
      int row=(m_anchor==ANCHOR_LEFT_LOWER || m_anchor==ANCHOR_RIGHT_LOWER) ? (count-1-i) : i;
      for(int c=0; c<columns; c++)
        {
         string name=LabelName(i,c);
         string text=(c<parts ? pieces[c] : "");
         //--- an empty label would show the terminal placeholder, so it is removed
         if(text=="")
           {
            ObjectDelete(m_chart,name);
            continue;
           }
         if(!CreateLabel(i,c))
            continue;
         used++;
         int x=m_x+m_pad+c*HIA_MAX_LABEL*m_char_width;
         if(m_anchor==ANCHOR_RIGHT_UPPER || m_anchor==ANCHOR_RIGHT_LOWER)
            x=m_x+m_pad+(widest-c*HIA_MAX_LABEL-StringLen(text))*m_char_width;
         ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y+m_pad+row*m_line_height);
         ObjectSetInteger(m_chart,name,OBJPROP_COLOR,(i==0 ? title_color : HIA_TEXT_COLOR));
         ObjectSetString(m_chart,name,OBJPROP_TEXT,text);
        }
     }
   m_rows=count;
   m_columns=columns;
   m_labels=used;
   m_widest=widest;
//--- stage: background size, measured from the text that was just drawn
   m_width_px =2*m_pad+widest*m_char_width;
   m_height_px=2*m_pad+count*m_line_height;
   string bg=m_prefix+"bg";
   ObjectSetInteger(m_chart,bg,OBJPROP_XSIZE,m_width_px);
   ObjectSetInteger(m_chart,bg,OBJPROP_YSIZE,m_height_px);
   ChartRedraw(m_chart);
  }
//+------------------------------------------------------------------+
//| Cuts one report line into the pieces a single label can show. A  |
//| break character marks the wanted split and anything that is      |
//| still too long simply continues in the next label column.        |
//+------------------------------------------------------------------+
int CHiaPanel::SplitLine(const string text,string &pieces[]) const
  {
   ArrayResize(pieces,0);
   string parts[];
   int    count=StringSplit(text,(ushort)HIA_COL_BREAK,parts);
   if(count<=0)
     {
      count=1;
      ArrayResize(parts,1);
      parts[0]=text;
     }
   for(int i=0; i<count; i++)
     {
      string rest=parts[i];
      while(StringLen(rest)>HIA_MAX_LABEL)
        {
         int index=ArraySize(pieces);
         ArrayResize(pieces,index+1);
         pieces[index]=StringSubstr(rest,0,HIA_MAX_LABEL);
         rest=StringSubstr(rest,HIA_MAX_LABEL);
        }
      int index=ArraySize(pieces);
      ArrayResize(pieces,index+1);
      pieces[index]=rest;
     }
   return(ArraySize(pieces));
  }
//+------------------------------------------------------------------+
//| Writes the result of the audit: the example lines in the journal |
//| and the CSV files. Two files belong to the whole pass and three  |
//| belong to one symbol, because an independent recount has to pair |
//| exactly one bar dump with exactly one row of counters.           |
//+------------------------------------------------------------------+
class CHiaReport
  {
private:
   string            m_prefix;            // file name prefix of one pass: symbol tag, period, chart id
   string            m_symbol_prefix;     // m_prefix plus the safe name of the symbol being audited
   int               m_findings_handle;   // one row per finding, one file per pass
   int               m_overview_handle;   // one row per symbol of the list, one file per pass
   int               m_summary_handle;    // the single counter row of the symbol being audited
   int               m_bars_handle;       // one row per audited bar of the symbol being audited
   int               m_sessions_handle;   // one row per quote session of the symbol being audited
   string            m_findings_name;     // path of the findings file inside the files folder
   string            m_overview_name;     // path of the overview file inside the files folder
   string            m_summary_name;      // path of the counter row of the current symbol
   string            m_bars_name;         // path of the bar dump of the current symbol
   string            m_sessions_name;     // path of the session dump of the current symbol
   string            m_symbol_files;      // the per symbol files of the last symbol, as one text
   long              m_seen;              // findings handed to this object
   long              m_rows;              // findings written to the file
   long              m_dropped;           // findings not written because of the row guard
   long              m_overview_rows;     // rows of the overview file
   long              m_summary_rows;      // counter rows written, one per audited symbol
   long              m_bar_rows;          // rows written into the current bar dump
   long              m_bar_rows_total;    // rows written into every bar dump of this pass
   long              m_session_rows;      // rows written into the current session dump
   long              m_session_rows_total;// rows written into every session dump of this pass
   int               m_summary_files;     // counter files opened in this pass
   int               m_bars_files;        // bar dumps opened in this pass
   int               m_sessions_files;    // session dumps opened in this pass
   int               m_examples[HIA_CHECK_COUNT]; // example lines already printed per check
   bool              m_cap_logged;        // the row guard was reported once

   int               OpenFile(const string name,const string header,const string meta);
   void              DropStale(const string name);

public:
                     CHiaReport(void);
                    ~CHiaReport(void);
   void              Reset(void);
   void              Open(const string prefix);
   void              OpenSymbol(const string symbol,const string meta);
   void              CloseSymbol(void);
   void              Close(void);
   void              Flush(void);
   void              Finding(const string symbol,const string period,const ENUM_HIA_CHECK check,
                             const int bar_index,const datetime bar_time,const string field,
                             const string detail,const string value_text);
   void              Bar(const MqlRates &rate,const int digits);
   void              Session(const string symbol,const int weekday,const int from_seconds,
                             const int to_seconds);
   void              SummaryRow(const string line);
   void              OverviewRow(const string line);
   static string     SummaryHeader(void);
   bool              FindingsOn(void)    const { return(m_findings_handle!=INVALID_HANDLE); }
   bool              OverviewOn(void)    const { return(m_overview_handle!=INVALID_HANDLE); }
   bool              BarsOn(void)        const { return(m_bars_handle!=INVALID_HANDLE);     }
   long              Seen(void)          const { return(m_seen);               }
   long              Rows(void)          const { return(m_rows);               }
   long              Dropped(void)       const { return(m_dropped);            }
   long              OverviewRows(void)  const { return(m_overview_rows);      }
   long              SummaryRows(void)   const { return(m_summary_rows);       }
   long              BarRows(void)       const { return(m_bar_rows_total);     }
   long              SessionRows(void)   const { return(m_session_rows_total); }
   int               SummaryFiles(void)  const { return(m_summary_files);      }
   int               BarsFiles(void)     const { return(m_bars_files);         }
   int               SessionsFiles(void) const { return(m_sessions_files);     }
   string            FindingsName(void)  const { return(m_findings_name); }
   string            OverviewName(void)  const { return(m_overview_name); }
   string            SymbolFiles(void)   const { return(m_symbol_files);  }
  };
//+------------------------------------------------------------------+
//| The header of the counter file, which is the contract between    |
//| this tool and any independent recount. The first 37 columns are  |
//| the measured counters, the rest is there for a human reader.     |
//+------------------------------------------------------------------+
string CHiaReport::SummaryHeader(void)
  {
   string head="symbol;period_seconds;point;digits;spread_max_points;bars_audited;first_time;"
               "last_time;ohlc_high_lt_low;ohlc_open_gt_high;ohlc_open_lt_low;ohlc_close_gt_high;"
               "ohlc_close_lt_low;ohlc_nonpositive;ohlc_violations;time_not_increasing;off_grid;"
               "gap_not_multiple_of_period;gaps;missing_total;missing_in_session;max_gap_slots;"
               "empty_bars;flat_bars;spread_zero;spread_over_max;spread_max_seen;spread_mean;"
               "expected_openings;expected_in_session;grid_coverage_pct;session_coverage_pct;"
               "compared;mismatched;max_dev_points;m1_window_empty;outside_coverage";
   head+=";period;status;first_time_str;last_time_str;span_days;lag_bars;span_openings;identity;"
         "c3_state;gaps_explained;gaps_unexplained;gaps_unclassified;missing_unclassified;"
         "max_gap_slots_after;sessions_found;session_coverage_text;c5_state;m1_first;m1_last;"
         "m1_dev_open;m1_dev_high;m1_dev_low;m1_dev_close;m1_dev_volume;findings_total";
   return(head);
  }
//+------------------------------------------------------------------+
//| Constructor: no file is touched before Open() is called, so an   |
//| instance that is never used leaves nothing behind.               |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaReport::CHiaReport(void) : m_prefix(""),
   m_symbol_prefix(""),
   m_findings_handle(INVALID_HANDLE),
   m_overview_handle(INVALID_HANDLE),
   m_summary_handle(INVALID_HANDLE),
   m_bars_handle(INVALID_HANDLE),
   m_sessions_handle(INVALID_HANDLE),
   m_findings_name(""),
   m_overview_name(""),
   m_summary_name(""),
   m_bars_name(""),
   m_sessions_name(""),
   m_symbol_files(""),
   m_seen(0),
   m_rows(0),
   m_dropped(0),
   m_overview_rows(0),
   m_summary_rows(0),
   m_bar_rows(0),
   m_bar_rows_total(0),
   m_session_rows(0),
   m_session_rows_total(0),
   m_summary_files(0),
   m_bars_files(0),
   m_sessions_files(0),
   m_cap_logged(false)
  {
   ArrayInitialize(m_examples,0);
  }
//+------------------------------------------------------------------+
//| Destructor: the handles are released by Close(), which runs from |
//| OnDeinit() for every deinitialisation reason.                    |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaReport::~CHiaReport(void)
  {
  }
//+------------------------------------------------------------------+
//| Puts every counter and every name back to its starting value.    |
//| Without this a second pass would add its rows to the counters of |
//| the first one and the row identity of the report would fail.     |
//+------------------------------------------------------------------+
void CHiaReport::Reset(void)
  {
   m_prefix="";
   m_symbol_prefix="";
   m_findings_name="";
   m_overview_name="";
   m_summary_name="";
   m_bars_name="";
   m_sessions_name="";
   m_symbol_files="";
   m_seen=0;
   m_rows=0;
   m_dropped=0;
   m_overview_rows=0;
   m_summary_rows=0;
   m_bar_rows=0;
   m_bar_rows_total=0;
   m_session_rows=0;
   m_session_rows_total=0;
   m_summary_files=0;
   m_bars_files=0;
   m_sessions_files=0;
   m_cap_logged=false;
   ArrayInitialize(m_examples,0);
  }
//+------------------------------------------------------------------+
//| Opens one file and writes its comment line and its header. A     |
//| failure is reported with the error code and returns an invalid   |
//| handle, which switches that one file off and leaves the run on.  |
//+------------------------------------------------------------------+
int CHiaReport::OpenFile(const string name,const string header,const string meta)
  {
   ResetLastError();
   int handle=FileOpen(name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",
                  HIA_NAME,name,GetLastError());
      return(INVALID_HANDLE);
     }
//--- the comment line above the header carries what the columns cannot:
//    which tool wrote the file and what it was measuring
   if(meta!="")
      FileWriteString(handle,"# "+meta+"\r\n");
   FileWriteString(handle,header+"\r\n");
   return(handle);
  }
//+------------------------------------------------------------------+
//| Deletes a file of an earlier run of this tool. A bar dump that   |
//| was switched off would otherwise stay next to fresh counters and |
//| an independent recount would compare two different runs.         |
//+------------------------------------------------------------------+
void CHiaReport::DropStale(const string name)
  {
   if(!FileIsExist(name))
      return;
   ResetLastError();
   if(FileDelete(name))
      PrintFormat("%s: the bar dump is off, the file %s of an earlier run was removed so that it "
                  "cannot be paired with the counters of this one",HIA_NAME,name);
   else
      PrintFormat("%s: the bar dump is off but the file %s of an earlier run could not be removed "
                  "(error %d), do not recount against it",HIA_NAME,name,GetLastError());
  }
//+------------------------------------------------------------------+
//| Opens the two files of one pass. The name carries the symbol tag,|
//| the period and the chart id, so two copies of the tool on two    |
//| charts can never write into the same file.                       |
//+------------------------------------------------------------------+
void CHiaReport::Open(const string prefix)
  {
   m_prefix=prefix;
   string stem=HIA_FOLDER+"\\"+prefix;
   string meta=HIA_TITLE+", one row per symbol of the list, prefix "+prefix;
//--- stage: the overview, one row per symbol, is the table a reader looks at
   m_overview_name=stem+"_overview.csv";
   m_overview_handle=OpenFile(m_overview_name,
                              "symbol;period;status;bars_audited;first_time_str;last_time_str;"
                              "span_days;lag_bars;ohlc_violations;time_defects;gaps;missing_total;"
                              "missing_in_session;empty_bars;flat_bars;compared;mismatched;"
                              "max_dev_points;spread_max_seen;spread_mean;grid_coverage_pct;"
                              "session_coverage_pct;identity;findings_total",meta);
   if(m_overview_handle==INVALID_HANDLE)
      m_overview_name="";
//--- stage: one row per finding
   if(InpWriteFindingsCsv)
     {
      m_findings_name=stem+"_findings.csv";
      m_findings_handle=OpenFile(m_findings_name,
                                 "symbol;period;check;bar_index;bar_time;field;detail;value",
                                 HIA_TITLE+", one row per finding, prefix "+prefix);
      if(m_findings_handle==INVALID_HANDLE)
         m_findings_name="";
     }
  }
//+------------------------------------------------------------------+
//| Opens the three files of one symbol. They share one prefix, so a |
//| recount pairs one bar dump with the counter row and the session  |
//| table of the very same symbol and never with another one.        |
//+------------------------------------------------------------------+
void CHiaReport::OpenSymbol(const string symbol,const string meta)
  {
   CloseSymbol();
   m_symbol_prefix=HIA_FOLDER+"\\"+m_prefix+"_"+HiaSafeName(symbol);
//--- stage: the counter row, the product of the tool, always written
   m_summary_name=m_symbol_prefix+"_summary.csv";
   m_summary_handle=OpenFile(m_summary_name,SummaryHeader(),meta);
   if(m_summary_handle==INVALID_HANDLE)
      m_summary_name="";
   else
      m_summary_files++;
//--- stage: the quote sessions. No interface outside the terminal can read
//    them, so check C3 cannot be recounted without this dump
   m_sessions_name=m_symbol_prefix+"_sessions.csv";
   m_sessions_handle=OpenFile(m_sessions_name,HIA_SESS_HEADER,
                              meta+", quote sessions, index = row order inside a weekday");
   if(m_sessions_handle==INVALID_HANDLE)
      m_sessions_name="";
   else
      m_sessions_files++;
//--- stage: the raw material of an independent recount
   m_bars_name=m_symbol_prefix+"_bars.csv";
   if(InpWriteBarsCsv)
     {
      m_bars_handle=OpenFile(m_bars_name,HIA_BARS_HEADER,meta+", the audited bars and nothing else");
      if(m_bars_handle==INVALID_HANDLE)
         m_bars_name="";
      else
         m_bars_files++;
     }
   else
     {
      DropStale(m_bars_name);
      m_bars_name="";
     }
   m_bar_rows=0;
   m_session_rows=0;
   m_symbol_files=(m_summary_name!="" ? m_summary_name : "summary off");
   m_symbol_files+=" + "+(m_sessions_name!="" ? m_sessions_name : "sessions off");
   m_symbol_files+=" + "+(m_bars_name!="" ? m_bars_name : "bars off");
  }
//+------------------------------------------------------------------+
//| Closes the three files of the symbol that was audited last. It   |
//| may be called when nothing is open, so the caller never has to   |
//| remember whether a symbol reached the file stage at all.         |
//+------------------------------------------------------------------+
void CHiaReport::CloseSymbol(void)
  {
   if(m_summary_handle!=INVALID_HANDLE)
     {
      FileClose(m_summary_handle);
      m_summary_handle=INVALID_HANDLE;
     }
   if(m_sessions_handle!=INVALID_HANDLE)
     {
      FileClose(m_sessions_handle);
      m_sessions_handle=INVALID_HANDLE;
     }
   if(m_bars_handle!=INVALID_HANDLE)
     {
      FileClose(m_bars_handle);
      m_bars_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Closes every open file. It runs at the end of a pass and from    |
//| OnDeinit(), and it may be called twice without harm.             |
//|                                                                  |
//+------------------------------------------------------------------+
void CHiaReport::Close(void)
  {
   CloseSymbol();
   if(m_findings_handle!=INVALID_HANDLE)
     {
      FileClose(m_findings_handle);
      m_findings_handle=INVALID_HANDLE;
     }
   if(m_overview_handle!=INVALID_HANDLE)
     {
      FileClose(m_overview_handle);
      m_overview_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Writes the buffers of every open file to disk. It runs after     |
//| every symbol, so the files can be read while a long run is still |
//| working through the rest of the list.                            |
//+------------------------------------------------------------------+
void CHiaReport::Flush(void)
  {
   if(m_findings_handle!=INVALID_HANDLE)
      FileFlush(m_findings_handle);
   if(m_overview_handle!=INVALID_HANDLE)
      FileFlush(m_overview_handle);
   if(m_summary_handle!=INVALID_HANDLE)
      FileFlush(m_summary_handle);
   if(m_bars_handle!=INVALID_HANDLE)
      FileFlush(m_bars_handle);
   if(m_sessions_handle!=INVALID_HANDLE)
      FileFlush(m_sessions_handle);
  }
//+------------------------------------------------------------------+
//| Takes one finding. It is counted in every case, printed as an    |
//| example while the example budget of its check lasts, and written |
//| to the findings file while the row guard allows it.              |
//+------------------------------------------------------------------+
void CHiaReport::Finding(const string symbol,const string period,const ENUM_HIA_CHECK check,
                         const int bar_index,const datetime bar_time,const string field,
                         const string detail,const string value_text)
  {
   m_seen++;
//--- stage: example line in the journal, limited per check and not per symbol
   int slot=(int)check;
   int budget=(int)MathMax(0,InpMaxExamples);
   if(slot>=0 && slot<HIA_CHECK_COUNT && m_examples[slot]<budget)
     {
      m_examples[slot]++;
      PrintFormat("%s: %s example %d of %d: %s %s bar %s %s %s %s",HIA_NAME,HiaCheckName(check),
                  m_examples[slot],budget,symbol,period,HiaTimeText(bar_time),field,detail,value_text);
     }
//--- stage: one row in the findings file
   if(m_findings_handle==INVALID_HANDLE)
      return;
   if(m_rows>=(long)HIA_MAX_CSV_ROWS)
     {
      m_dropped++;
      if(!m_cap_logged)
        {
         m_cap_logged=true;
         PrintFormat("%s: the findings file reached its guard of %d rows, further findings are only counted",
                     HIA_NAME,HIA_MAX_CSV_ROWS);
        }
      return;
     }
   FileWriteString(m_findings_handle,symbol+HIA_SEPARATOR+period+HIA_SEPARATOR+HiaCheckName(check)+
                   HIA_SEPARATOR+IntegerToString(bar_index)+HIA_SEPARATOR+HiaTimeText(bar_time)+
                   HIA_SEPARATOR+field+HIA_SEPARATOR+detail+HIA_SEPARATOR+value_text+"\r\n");
   m_rows++;
  }
//+------------------------------------------------------------------+
//| Writes one audited bar, exactly the eight fields a check reads   |
//| and not one column more. The prices carry the digits of their own|
//| symbol, so a recount can repeat the comparisons it made.         |
//+------------------------------------------------------------------+
void CHiaReport::Bar(const MqlRates &rate,const int digits)
  {
   if(m_bars_handle==INVALID_HANDLE)
      return;
   FileWriteString(m_bars_handle,HiaTimeText(rate.time)+HIA_SEPARATOR+
                   DoubleToString(rate.open,digits)+HIA_SEPARATOR+
                   DoubleToString(rate.high,digits)+HIA_SEPARATOR+
                   DoubleToString(rate.low,digits)+HIA_SEPARATOR+
                   DoubleToString(rate.close,digits)+HIA_SEPARATOR+
                   HiaNum((long)rate.tick_volume)+HIA_SEPARATOR+
                   HiaNum(rate.real_volume)+HIA_SEPARATOR+
                   IntegerToString(rate.spread)+"\r\n");
   m_bar_rows++;
   m_bar_rows_total++;
  }
//+------------------------------------------------------------------+
//| Writes one quote session of one weekday. A symbol without any    |
//| session record produces no row at all, which is exactly the      |
//| unclassified branch of check C3.                                 |
//+------------------------------------------------------------------+
void CHiaReport::Session(const string symbol,const int weekday,const int from_seconds,
                         const int to_seconds)
  {
   if(m_sessions_handle==INVALID_HANDLE)
      return;
   FileWriteString(m_sessions_handle,symbol+HIA_SEPARATOR+IntegerToString(weekday)+HIA_SEPARATOR+
                   IntegerToString(from_seconds)+HIA_SEPARATOR+IntegerToString(to_seconds)+"\r\n");
   m_session_rows++;
   m_session_rows_total++;
  }
//+------------------------------------------------------------------+
//| Writes the one counter row of the symbol that is open. The row   |
//| is built by the audit itself, so this class never has to know    |
//| what a single counter means.                                     |
//+------------------------------------------------------------------+
void CHiaReport::SummaryRow(const string line)
  {
   if(m_summary_handle==INVALID_HANDLE)
      return;
   FileWriteString(m_summary_handle,line+"\r\n");
   m_summary_rows++;
  }
//+------------------------------------------------------------------+
//| Writes one row of the overview file, which holds every symbol of |
//| the list including the ones that could not be audited at all.    |
//|                                                                  |
//+------------------------------------------------------------------+
void CHiaReport::OverviewRow(const string line)
  {
   if(m_overview_handle==INVALID_HANDLE)
      return;
   FileWriteString(m_overview_handle,line+"\r\n");
   m_overview_rows++;
  }
//+------------------------------------------------------------------+
//| Audits the bar history of one symbol and keeps its counters. One |
//| instance measures one symbol, so a run over a symbol list is a   |
//| loop over instances and no counter can leak between symbols.     |
//+------------------------------------------------------------------+
class CHiaSymbolAudit
  {
private:
   string            m_symbol;              // symbol under audit
   ENUM_TIMEFRAMES   m_period;              // period under audit
   string            m_period_name;         // period without the PERIOD_ prefix
   int               m_period_seconds;      // length of one bar in seconds
   double            m_point;               // point size of this symbol, not of the chart
   int               m_digits;              // digits of this symbol
   ENUM_HIA_STATUS   m_status;              // what happened to this symbol
   MqlRates          m_rates[];             // the audited bars, oldest first
   int               m_bars;                // bars actually audited
   datetime          m_first_time;          // open time of the oldest audited bar
   datetime          m_last_time;           // open time of the newest audited bar
   double            m_span_days;           // calendar days between the first and the last bar
   long              m_lag_bars;            // openings between the newest bar and the server time
   long              m_span_openings;       // openings the grid has between those two bars
   long              m_expected_openings;   // bars_audited + missing_total
   long              m_expected_in_session; // bars_audited + missing_in_session
   string            m_identity;            // result of the internal arithmetic check
   double            m_grid_coverage;       // share of the grid slots that carry a bar
   double            m_session_coverage;    // share of the quoted time that carries a bar
   bool              m_session_known;       // the session coverage is defined for this symbol
   //--- C1 OHLC consistency, one counter per violated predicate
   long              m_c1_total;            // findings of C1
   long              m_c1_high_lt_low;      // high < low
   long              m_c1_open_gt_high;     // open > high
   long              m_c1_open_lt_low;      // open < low
   long              m_c1_close_gt_high;    // close > high
   long              m_c1_close_lt_low;     // close < low
   long              m_c1_non_positive;     // one of the four prices is zero or negative
   //--- C2 bar open times
   long              m_c2_total;            // findings of C2
   long              m_c2_not_increasing;   // time[i] <= time[i-1]
   long              m_c2_off_grid;         // time is not a multiple of the period
   //--- C3 missing bars
   string            m_c3_state;            // on, off or why it could not run
   long              m_gaps;                // holes in the series
   long              m_gaps_explained;      // every missing opening is outside the sessions
   long              m_gaps_unexplained;    // at least one missing opening is inside a session
   long              m_gaps_unclassified;   // no session record, or the scan guard stopped it
   long              m_missing_total;       // missing openings
   long              m_missing_in_session;  // missing openings inside a quote session
   long              m_missing_unclassified;// missing openings that could not be classified
   long              m_gap_not_multiple;    // steps that are not a whole number of periods
   bool              m_gaps_measured;       // the gap arithmetic of C3 really ran
   long              m_max_gap_slots;       // largest hole in openings
   datetime          m_max_gap_after;       // bar the largest hole follows
   long              m_scan_used;           // openings classified so far, guarded
   bool              m_scan_truncated;      // the scan guard was reached
   int               m_sessions_found;      // quote sessions the symbol reports
   int               m_sess_from[7*HIA_MAX_SESSIONS]; // session start, seconds of the day
   int               m_sess_to[7*HIA_MAX_SESSIONS];   // session end, seconds of the day
   int               m_sess_count[7];       // sessions per weekday, 0 = Sunday
   //--- C4 empty and flat bars
   long              m_empty_bars;          // tick_volume == 0
   long              m_flat_bars;           // open == high == low == close with ticks
   //--- C5 rebuild from M1
   string            m_c5_state;            // on, off or why it could not run
   datetime          m_m1_first;            // first M1 bar the terminal has
   datetime          m_m1_last;             // last M1 bar the terminal has
   long              m_m1_compared;         // bars compared with their M1 rebuild
   long              m_m1_mismatched;       // bars where the rebuild differs
   long              m_m1_window_empty;     // windows inside the coverage without any M1 bar
   long              m_m1_out_of_coverage;  // bars outside the M1 coverage, not compared
   long              m_m1_dev_open;         // bars where the open differs
   long              m_m1_dev_high;         // bars where the high differs
   long              m_m1_dev_low;          // bars where the low differs
   long              m_m1_dev_close;        // bars where the close differs
   long              m_m1_dev_volume;       // bars where the tick volume differs
   double            m_m1_max_dev;          // largest price deviation in points
   //--- C6 spread sanity
   long              m_spread_zero;         // bars with a spread of zero
   long              m_spread_above;        // bars above the configured limit
   int               m_spread_max;          // largest spread in points
   long              m_spread_sum;          // sum of the spread column
   double            m_spread_mean;         // mean spread in points

   //--- above the daily grid an opening is not a multiple of the period by
   //    definition, so C2 cannot measure off_grid there and must not say 0
   bool              OnGrid(void) const { return(m_period_seconds>0 && m_period_seconds<86400); }

   bool              LoadSessions(void);
   void              DumpSessions(CHiaReport &report) const;
   bool              InSession(const datetime moment) const;
   void              ScanBars(CHiaReport &report);
   void              CheckGaps(CHiaReport &report);
   void              CheckM1(CHiaReport &report);
   void              Finalise(void);

public:
                     CHiaSymbolAudit(void);
                    ~CHiaSymbolAudit(void);
   void              Reset(void);
   void              SetContext(const string symbol,const ENUM_TIMEFRAMES period);
   bool              Audit(CHiaReport &report);
   string            Name(void) const { return(m_symbol); }
   ENUM_HIA_STATUS   Status(void) const { return(m_status); }
   int               Bars(void) const { return(m_bars); }
   long              FindingsTotal(void) const;
   long              C1Findings(void) const { return(m_c1_total); }
   long              C2Findings(void) const { return(m_c2_total); }
   long              C3Findings(void) const { return(m_gaps); }
   long              C4Findings(void) const { return(m_empty_bars+m_flat_bars); }
   long              C5Findings(void) const { return(m_m1_mismatched); }
   long              C6Findings(void) const { return(m_spread_above); }
   long              MissingTotal(void) const { return(m_missing_total); }
   long              MissingInSession(void) const { return(m_missing_in_session); }
   long              ExpectedOpenings(void) const { return(m_expected_openings); }
   long              ExpectedInSession(void) const { return(m_expected_in_session); }
   long              SpanOpenings(void) const { return(m_span_openings); }
   long              LagBars(void) const { return(m_lag_bars); }
   bool              SessionKnown(void) const { return(m_session_known); }
   bool              GapsMeasured(void) const { return(m_gaps_measured); }
   string            Identity(void) const { return(m_identity); }
   string            CoverageText(const double value,const bool known) const;
   string            PanelLine(void) const;
   string            SummaryLine(void) const;
   string            OverviewLine(void) const;
   string            SessionsText(void) const;
   void              PrintDetail(void) const;
   static string     PanelHeader(void);
  };
//+------------------------------------------------------------------+
//| Constructor: every counter starts at zero through Reset(), so    |
//| the long initialiser list exists only once in this file.         |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaSymbolAudit::CHiaSymbolAudit(void)
  {
   Reset();
  }
//+------------------------------------------------------------------+
//| Destructor: the bar buffer is released at the end of Audit(), so |
//| a finished instance holds counters only.                         |
//|                                                                  |
//+------------------------------------------------------------------+
CHiaSymbolAudit::~CHiaSymbolAudit(void)
  {
  }
//+------------------------------------------------------------------+
//| Puts every counter, flag, text and array of this symbol back to  |
//| its starting value. An expert is not reloaded when an input      |
//| changes, so a new pass would carry the old numbers without this. |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::Reset(void)
  {
   m_symbol="";
   m_period=PERIOD_CURRENT;
   m_period_name="";
   m_period_seconds=0;
   m_point=0.0;
   m_digits=0;
   m_status=HIA_STATUS_IDLE;
   ArrayFree(m_rates);
   m_bars=0;
   m_first_time=0;
   m_last_time=0;
   m_span_days=0.0;
   m_lag_bars=0;
   m_span_openings=0;
   m_expected_openings=0;
   m_expected_in_session=0;
   m_identity="off";
   m_grid_coverage=0.0;
   m_session_coverage=0.0;
   m_session_known=false;
   m_c1_total=0;
   m_c1_high_lt_low=0;
   m_c1_open_gt_high=0;
   m_c1_open_lt_low=0;
   m_c1_close_gt_high=0;
   m_c1_close_lt_low=0;
   m_c1_non_positive=0;
   m_c2_total=0;
   m_c2_not_increasing=0;
   m_c2_off_grid=0;
   m_c3_state="off";
   m_gaps=0;
   m_gaps_explained=0;
   m_gaps_unexplained=0;
   m_gaps_unclassified=0;
   m_missing_total=0;
   m_missing_in_session=0;
   m_missing_unclassified=0;
   m_gap_not_multiple=0;
   m_gaps_measured=false;
   m_max_gap_slots=0;
   m_max_gap_after=0;
   m_scan_used=0;
   m_scan_truncated=false;
   m_sessions_found=0;
   ArrayInitialize(m_sess_from,0);
   ArrayInitialize(m_sess_to,0);
   ArrayInitialize(m_sess_count,0);
   m_empty_bars=0;
   m_flat_bars=0;
   m_c5_state="off";
   m_m1_first=0;
   m_m1_last=0;
   m_m1_compared=0;
   m_m1_mismatched=0;
   m_m1_window_empty=0;
   m_m1_out_of_coverage=0;
   m_m1_dev_open=0;
   m_m1_dev_high=0;
   m_m1_dev_low=0;
   m_m1_dev_close=0;
   m_m1_dev_volume=0;
   m_m1_max_dev=0.0;
   m_spread_zero=0;
   m_spread_above=0;
   m_spread_max=0;
   m_spread_sum=0;
   m_spread_mean=0.0;
  }
//+------------------------------------------------------------------+
//| Sets the symbol and the period of the next audit. Reset() runs   |
//| first, so one instance can be reused for a second pass or for a  |
//| different symbol count without carrying anything over.           |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::SetContext(const string symbol,const ENUM_TIMEFRAMES period)
  {
   Reset();
   m_symbol=symbol;
   m_period=period;
   m_period_name=HiaPeriodName(period);
   m_period_seconds=PeriodSeconds(period);
  }
//+------------------------------------------------------------------+
//| Sum of the findings of all six checks. The journal prints this   |
//| number next to the row count of the findings file, so a reader   |
//| can verify that nothing was counted twice or lost.               |
//+------------------------------------------------------------------+
long CHiaSymbolAudit::FindingsTotal(void) const
  {
   return(m_c1_total+m_c2_total+m_gaps+m_empty_bars+m_flat_bars+m_m1_mismatched+m_spread_above);
  }
//+------------------------------------------------------------------+
//| Reads the quote session table of the symbol into the own arrays. |
//| It runs before the bars are copied, so a symbol that delivers no |
//| bar never opens a file; the dump is written by DumpSessions().   |
//+------------------------------------------------------------------+
bool CHiaSymbolAudit::LoadSessions(void)
  {
   m_sessions_found=0;
   for(int day=0; day<7; day++)
     {
      m_sess_count[day]=0;
      for(int index=0; index<HIA_MAX_SESSIONS; index++)
        {
         datetime from=0,to=0;
         if(!SymbolInfoSessionQuote(m_symbol,(ENUM_DAY_OF_WEEK)day,(uint)index,from,to))
            break;
         int slot=day*HIA_MAX_SESSIONS+m_sess_count[day];
         m_sess_from[slot]=(int)from;
         m_sess_to[slot]=(int)to;
         m_sess_count[day]++;
         m_sessions_found++;
        }
     }
   if(m_sessions_found<=0)
      PrintFormat("%s: %s reports no quote session at all, every gap is reported as unclassified",
                  HIA_NAME,m_symbol);
   return(m_sessions_found>0);
  }
//+------------------------------------------------------------------+
//| Writes the session table of this symbol into its own dump. No    |
//| interface outside the terminal can read SymbolInfoSessionQuote,  |
//| so without this file check C3 cannot be recounted at all.        |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::DumpSessions(CHiaReport &report) const
  {
   for(int day=0; day<7; day++)
      for(int index=0; index<m_sess_count[day]; index++)
        {
         int slot=day*HIA_MAX_SESSIONS+index;
         report.Session(m_symbol,day,m_sess_from[slot],m_sess_to[slot]);
        }
  }
//+------------------------------------------------------------------+
//| Tells whether one moment falls inside a quote session of its own |
//| weekday. The three clauses are the whole definition of "inside"  |
//| and they are also the ones the independent recount uses.         |
//+------------------------------------------------------------------+
bool CHiaSymbolAudit::InSession(const datetime moment) const
  {
   int day=HiaWeekday(moment);
   if(day<0 || day>6)
      return(false);
   int seconds=(int)((long)moment%86400);
   for(int index=0; index<m_sess_count[day]; index++)
     {
      int slot=day*HIA_MAX_SESSIONS+index;
      int from=m_sess_from[slot];
      int to=m_sess_to[slot];
      //--- a session is the half open interval [from, to). A record whose end
      //    is not above its start would describe an empty interval, so it is
      //    read as the single second it begins in and never as a whole day
      int upper=(to>from+1 ? to : from+1);
      if(seconds>=from && seconds<upper)
         return(true);
      //--- an end past midnight is reported as more than 86400 seconds; the
      //    part after midnight belongs to the next weekday, which has its own
      //    record, so here only the part before midnight is claimed
      if(to>=86400 && seconds>=from)
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Audits one symbol. Every failure ends in one journal line and a  |
//| status, never in a stopped run, because a symbol list with one   |
//| wrong entry must still deliver the numbers of the others.        |
//+------------------------------------------------------------------+
bool CHiaSymbolAudit::Audit(CHiaReport &report)
  {
//--- stage: does the terminal know this symbol at all
   double point=0.0;
   ResetLastError();
   if(!SymbolInfoDouble(m_symbol,SYMBOL_POINT,point) || point<=0.0)
     {
      m_status=HIA_STATUS_UNKNOWN;
      PrintFormat("%s: %s is not a symbol of this terminal (error %d), it is skipped",
                  HIA_NAME,m_symbol,GetLastError());
      return(false);
     }
   m_point=point;
   m_digits=(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS);
//--- stage: the quote session table, the yardstick of C3. It is only read
//    here; the dump waits until the symbol has really delivered bars
   LoadSessions();
//--- stage: the bars, starting at shift 1 because bar 0 is still forming
   int want=InpBars;
   if(want<2)
      want=2;
   if(want>HIA_MAX_BARS)
      want=HIA_MAX_BARS;
//--- a series the terminal has not built yet makes this request wait while the
//    server is asked for it, which on a long history can take minutes. Asking
//    is what starts the download, so the call stays and is announced instead
   long built=0;
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_SYNCHRONIZED,built) || built==0)
      PrintFormat("%s: %s %s is not synchronised yet, this copy request can take a while",
                  HIA_NAME,m_symbol,m_period_name);
   ResetLastError();
   int got=CopyRates(m_symbol,m_period,1,want,m_rates);
   if(got<=0)
     {
      m_status=HIA_STATUS_NO_DATA;
      bool selected=(bool)SymbolInfoInteger(m_symbol,SYMBOL_SELECT);
      PrintFormat("%s: %s %s delivered no bar (error %d, in Market Watch: %s), it is skipped",
                  HIA_NAME,m_symbol,m_period_name,GetLastError(),(selected ? "yes" : "no"));
      return(false);
     }
   m_bars=got;
   m_first_time=m_rates[0].time;
   m_last_time=m_rates[got-1].time;
   m_span_days=(double)((long)m_last_time-(long)m_first_time)/86400.0;
//--- stage: a series the terminal has not finished building ends in the
//    past. That is not a broker defect, but a reader who is not told
//    about it would read the last audited bar as the end of the history.
   datetime server_now=HiaNow();
   if(m_period_seconds>0 && (long)server_now>(long)m_last_time)
      m_lag_bars=((long)server_now-(long)m_last_time)/(long)m_period_seconds-1;
   if(m_lag_bars<0)
      m_lag_bars=0;
   if(m_lag_bars>0)
      PrintFormat("%s: %s %s ends %s opening(s) before the last known server time %s, the series is behind or the market is closed",
                  HIA_NAME,m_symbol,m_period_name,HiaNum(m_lag_bars),HiaTimeText(server_now));
   if(m_period_seconds>0)
      m_span_openings=((long)m_last_time-(long)m_first_time)/m_period_seconds+1;
//--- stage: the three files of this symbol. They are opened only now, so a
//    symbol that delivered no bar cannot leave a counter row behind that an
//    independent recount would pair with a bar dump of an earlier run
   report.OpenSymbol(m_symbol,HIA_TITLE+", "+m_symbol+" "+m_period_name+", "+HiaNum(m_bars)+
                     " closed bars from "+HiaTimeText(m_first_time)+" to "+HiaTimeText(m_last_time));
   DumpSessions(report);
//--- stage: the checks that read one bar at a time, plus the optional bar dump
   ScanBars(report);
//--- stage: the holes between two neighbouring bars
   CheckGaps(report);
//--- stage: the rebuild of every bar from its M1 bars
   CheckM1(report);
//--- stage: the derived figures
   Finalise();
   m_status=HIA_STATUS_OK;
//--- the bar buffer is released at once: a list of 128 symbols would
//    otherwise hold every buffer until the expert is removed
   ArrayFree(m_rates);
   return(true);
  }
//+------------------------------------------------------------------+
//| Walks the bars once and runs the four checks that need a single  |
//| bar: C1, C2, C4 and the spread statistics of C6. The optional    |
//| bar dump is written in the same walk.                            |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::ScanBars(CHiaReport &report)
  {
   bool on_grid=(m_period_seconds>0 && m_period_seconds<86400);
   for(int i=0; i<m_bars; i++)
     {
      double open=m_rates[i].open;
      double high=m_rates[i].high;
      double low=m_rates[i].low;
      double close=m_rates[i].close;
      //--- C1: one finding per violated predicate, so a bar can produce several
      if(InpCheckOHLC)
        {
         bool v_high_low =(high<low);
         bool v_open_high=(open>high);
         bool v_open_low =(open<low);
         bool v_close_high=(close>high);
         bool v_close_low =(close<low);
         bool v_positive =(open<=0.0 || high<=0.0 || low<=0.0 || close<=0.0);
         if(v_high_low || v_open_high || v_open_low || v_close_high || v_close_low || v_positive)
           {
            string prices="o="+DoubleToString(open,m_digits)+" h="+DoubleToString(high,m_digits)+
                          " l="+DoubleToString(low,m_digits)+" c="+DoubleToString(close,m_digits);
            if(v_high_low)
              {
               m_c1_high_lt_low++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "high_lt_low",prices,"");
              }
            if(v_open_high)
              {
               m_c1_open_gt_high++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "open_gt_high",prices,"");
              }
            if(v_open_low)
              {
               m_c1_open_lt_low++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "open_lt_low",prices,"");
              }
            if(v_close_high)
              {
               m_c1_close_gt_high++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "close_gt_high",prices,"");
              }
            if(v_close_low)
              {
               m_c1_close_lt_low++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "close_lt_low",prices,"");
              }
            if(v_positive)
              {
               m_c1_non_positive++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_OHLC,i,m_rates[i].time,
                              "non_positive",prices,"");
              }
           }
        }
      //--- C2: order of the stamps and the grid of the period
      if(InpCheckTimes)
        {
         if(i>0 && m_rates[i].time<=m_rates[i-1].time)
           {
            m_c2_not_increasing++;
            report.Finding(m_symbol,m_period_name,HIA_CHECK_TIME,i,m_rates[i].time,"not_increasing",
                           "previous="+HiaTimeText(m_rates[i-1].time),"");
           }
         if(on_grid)
           {
            long rest=(long)m_rates[i].time%(long)m_period_seconds;
            if(rest!=0)
              {
               m_c2_off_grid++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_TIME,i,m_rates[i].time,"off_grid",
                              "period_seconds="+HiaNum(m_period_seconds),HiaNum(rest));
              }
           }
        }
      //--- C4: a bar without a tick, and a bar whose four prices are equal
      if(InpCheckEmpty)
        {
         if(m_rates[i].tick_volume==0)
           {
            m_empty_bars++;
            report.Finding(m_symbol,m_period_name,HIA_CHECK_EMPTY,i,m_rates[i].time,"empty",
                           "tick_volume=0","");
           }
         else
            if(open==high && high==low && low==close)
              {
               m_flat_bars++;
               report.Finding(m_symbol,m_period_name,HIA_CHECK_EMPTY,i,m_rates[i].time,"flat",
                              "price="+DoubleToString(open,m_digits)+" tick_volume="+
                              HiaNum((long)m_rates[i].tick_volume),"");
              }
        }
      //--- C6: the spread column of the bar, statistics always, limit on request
      int spread=m_rates[i].spread;
      m_spread_sum+=(long)spread;
      if(spread>m_spread_max)
         m_spread_max=spread;
      if(spread==0)
         m_spread_zero++;
      if(InpSpreadMaxPoints>0 && spread>InpSpreadMaxPoints)
        {
         m_spread_above++;
         report.Finding(m_symbol,m_period_name,HIA_CHECK_SPREAD,i,m_rates[i].time,"spread_above",
                        "limit="+IntegerToString(InpSpreadMaxPoints),IntegerToString(spread));
        }
      //--- the raw bar for an independent recount
      report.Bar(m_rates[i],m_digits);
     }
   m_c1_total=m_c1_high_lt_low+m_c1_open_gt_high+m_c1_open_lt_low+m_c1_close_gt_high+
              m_c1_close_lt_low+m_c1_non_positive;
   m_c2_total=m_c2_not_increasing+m_c2_off_grid;
  }
//+------------------------------------------------------------------+
//| Measures the holes of the series and classifies every missing    |
//| opening against the quote sessions of the symbol. The arithmetic |
//| identity of the counters is decided here, where it is defined.   |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::CheckGaps(CHiaReport &report)
  {
   if(!InpCheckGaps)
     {
      m_c3_state="off";
      return;
     }
   if(m_period_seconds<=0)
     {
      m_c3_state="off, the period has no known length";
      return;
     }
//--- a calendar month is not a fixed number of seconds, so the slot
//    arithmetic of C3 would invent holes on monthly bars
   if(m_period==PERIOD_MN1)
     {
      m_c3_state="off, a month is not a fixed number of seconds";
      PrintFormat("%s: C3 is skipped on %s MN1, a month is not a fixed number of seconds",
                  HIA_NAME,m_symbol);
      return;
     }
   m_c3_state=(m_sessions_found>0 ? "on" : "on, no session record");
   m_gaps_measured=true;
   for(int i=1; i<m_bars; i++)
     {
      long delta=(long)m_rates[i].time-(long)m_rates[i-1].time;
      //--- a stamp that does not increase is a C2 finding; no hole can be
      //    measured across it, so it is left out of the slot arithmetic
      if(delta<=0)
         continue;
      //--- a step that is not a whole number of periods cannot be turned into
      //    a slot count without a remainder. It is counted apart, because the
      //    slot arithmetic of that one pair is then rounded and not exact
      if((delta%(long)m_period_seconds)!=0)
         m_gap_not_multiple++;
      long slots=delta/(long)m_period_seconds-1;
      if(slots<=0)
         continue;
      m_gaps++;
      m_missing_total+=slots;
      if(slots>m_max_gap_slots)
        {
         m_max_gap_slots=slots;
         m_max_gap_after=m_rates[i-1].time;
        }
      datetime first_missing=(datetime)((long)m_rates[i-1].time+(long)m_period_seconds);
      long   in_session=0;
      string class_name="";
      if(m_sessions_found<=0 || (m_scan_used+slots)>(long)HIA_MAX_GAP_SCAN)
        {
         if(m_sessions_found>0)
            m_scan_truncated=true;
         m_gaps_unclassified++;
         m_missing_unclassified+=slots;
         class_name="unclassified";
        }
      else
        {
         for(long step=1; step<=slots; step++)
            if(InSession((datetime)((long)m_rates[i-1].time+step*(long)m_period_seconds)))
               in_session++;
         m_scan_used+=slots;
         m_missing_in_session+=in_session;
         if(in_session>0)
           {
            m_gaps_unexplained++;
            class_name="unexplained";
           }
         else
           {
            m_gaps_explained++;
            class_name="explained";
           }
        }
      report.Finding(m_symbol,m_period_name,HIA_CHECK_GAP,i,first_missing,"gap",
                     "class="+class_name+" in_session="+HiaNum(in_session),HiaNum(slots));
     }
   if(m_scan_truncated)
      PrintFormat("%s: %s %s hit the classification guard of %d missing openings, the rest stays unclassified",
                  HIA_NAME,m_symbol,m_period_name,HIA_MAX_GAP_SCAN);
//--- the session coverage is only defined when every missing opening
//    could be classified; otherwise it is reported as a dash
   m_session_known=(m_sessions_found>0 && m_missing_unclassified==0);
//--- internal arithmetic: bars plus holes must be the number of grid
//    openings between the first and the last audited bar. It can only
//    fail when C2 found a stamp off the grid or out of order.
   m_identity=(((long)m_bars+m_missing_total)==m_span_openings ? "OK" : "MISMATCH");
  }
//+------------------------------------------------------------------+
//| Rebuilds every audited bar from its M1 bars and compares it with |
//| the bar of the broker. Only windows that lie completely inside   |
//| the M1 coverage are compared, the others are counted apart.      |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::CheckM1(CHiaReport &report)
  {
   if(!InpCheckM1)
     {
      m_c5_state="off";
      return;
     }
   if(m_period==PERIOD_M1 || m_period_seconds<60)
     {
      m_c5_state="off, the audited period is M1 itself";
      PrintFormat("%s: C5 is skipped on %s %s, there is nothing below this period",
                  HIA_NAME,m_symbol,m_period_name);
      return;
     }
//--- stage: ask for M1 once so the series exists, then read its coverage
   MqlRates probe[];
   ResetLastError();
   int probe_bars=CopyRates(m_symbol,PERIOD_M1,0,2,probe);
   long m1_first=0,m1_last=0;
   if(!SeriesInfoInteger(m_symbol,PERIOD_M1,SERIES_FIRSTDATE,m1_first))
      m1_first=0;
   if(!SeriesInfoInteger(m_symbol,PERIOD_M1,SERIES_LASTBAR_DATE,m1_last))
      m1_last=0;
   if(probe_bars<=0 || m1_first<=0 || m1_last<=m1_first)
     {
      m_c5_state="off, no usable M1 history";
      PrintFormat("%s: %s has no usable M1 history (error %d), C5 is skipped for this symbol",
                  HIA_NAME,m_symbol,GetLastError());
      return;
     }
   m_m1_first=(datetime)m1_first;
   m_m1_last=(datetime)m1_last;
   m_c5_state="on";
//--- stage: the M1 bars are copied in blocks, so a long audit cannot
//    ask the terminal for hundreds of thousands of bars at once
   int per_chunk=HIA_M1_CHUNK_MIN/(m_period_seconds/60);
   if(per_chunk<1)
      per_chunk=1;
   double tolerance=MathMax(0.0,InpM1TolerancePoints);
   for(int base=0; base<m_bars; base+=per_chunk)
     {
      int upto=base+per_chunk;
      if(upto>m_bars)
         upto=m_bars;
      MqlRates m1[];
      datetime from=m_rates[base].time;
      datetime to=(datetime)((long)m_rates[upto-1].time+(long)m_period_seconds-1);
      ResetLastError();
      int m1_bars=CopyRates(m_symbol,PERIOD_M1,from,to,m1);
      if(m1_bars<0)
         m1_bars=0;
      int cursor=0;
      for(int i=base; i<upto; i++)
        {
         datetime open_time=m_rates[i].time;
         datetime end_time=(datetime)((long)open_time+(long)m_period_seconds);
         //--- a window that is not completely covered by M1 data cannot be
         //    compared; counting it as a mismatch would be an invented finding
         //--- the last opening the window could hold is end_time minus one
         //    minute; asking for a bar at end_time itself would drop every
         //    window whose last M1 bar is the newest one the terminal has
         if((long)open_time<m1_first || ((long)end_time-60)>m1_last)
           {
            m_m1_out_of_coverage++;
            continue;
           }
         while(cursor<m1_bars && m1[cursor].time<open_time)
            cursor++;
         double build_open=0.0,build_high=0.0,build_low=0.0,build_close=0.0;
         long   build_volume=0;
         int    used=0;
         int    j=cursor;
         while(j<m1_bars && m1[j].time<end_time)
           {
            if(used==0)
              {
               build_open=m1[j].open;
               build_high=m1[j].high;
               build_low=m1[j].low;
              }
            else
              {
               if(m1[j].high>build_high)
                  build_high=m1[j].high;
               if(m1[j].low<build_low)
                  build_low=m1[j].low;
              }
            build_close=m1[j].close;
            build_volume+=(long)m1[j].tick_volume;
            used++;
            j++;
           }
         cursor=j;
         if(used<=0)
           {
            m_m1_window_empty++;
            continue;
           }
         m_m1_compared++;
         double dev_open =(m_rates[i].open-build_open)/m_point;
         double dev_high =(m_rates[i].high-build_high)/m_point;
         double dev_low  =(m_rates[i].low-build_low)/m_point;
         double dev_close=(m_rates[i].close-build_close)/m_point;
         double worst=MathMax(MathMax(MathAbs(dev_open),MathAbs(dev_high)),
                              MathMax(MathAbs(dev_low),MathAbs(dev_close)));
         if(worst>m_m1_max_dev)
            m_m1_max_dev=worst;
         bool bad_open =(MathAbs(dev_open)>tolerance);
         bool bad_high =(MathAbs(dev_high)>tolerance);
         bool bad_low  =(MathAbs(dev_low)>tolerance);
         bool bad_close=(MathAbs(dev_close)>tolerance);
         bool bad_volume=(build_volume!=(long)m_rates[i].tick_volume);
         if(bad_open)
            m_m1_dev_open++;
         if(bad_high)
            m_m1_dev_high++;
         if(bad_low)
            m_m1_dev_low++;
         if(bad_close)
            m_m1_dev_close++;
         if(bad_volume)
            m_m1_dev_volume++;
         if(bad_open || bad_high || bad_low || bad_close || bad_volume)
           {
            m_m1_mismatched++;
            report.Finding(m_symbol,m_period_name,HIA_CHECK_M1,i,open_time,"rebuild",
                           "m1_bars="+IntegerToString(used)+
                           " dev_o="+DoubleToString(dev_open,1)+
                           " dev_h="+DoubleToString(dev_high,1)+
                           " dev_l="+DoubleToString(dev_low,1)+
                           " dev_c="+DoubleToString(dev_close,1)+
                           " vol_bar="+HiaNum((long)m_rates[i].tick_volume)+
                           " vol_m1="+HiaNum(build_volume),
                           DoubleToString(worst,1));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Turns the raw counters into the figures the report shows. Both   |
//| coverage numbers are kept, because the grid figure is dominated  |
//| by the weekend and would make any clean symbol look broken.      |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::Finalise(void)
  {
   m_expected_openings=(long)m_bars+m_missing_total;
   m_expected_in_session=(long)m_bars+m_missing_in_session;
   m_grid_coverage=(m_expected_openings>0 ? 100.0*m_bars/(double)m_expected_openings : 0.0);
   m_session_coverage=(m_expected_in_session>0 ? 100.0*m_bars/(double)m_expected_in_session : 0.0);
   m_spread_mean=(m_bars>0 ? (double)m_spread_sum/(double)m_bars : 0.0);
  }
//+------------------------------------------------------------------+
//| A coverage figure as text. A figure that is not defined for this |
//| symbol becomes a dash, because printing 100 per cent for a       |
//| symbol without a session record would read as a perfect result.  |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::CoverageText(const double value,const bool known) const
  {
   if(!known)
      return("-");
   return(DoubleToString(value,2));
  }
//+------------------------------------------------------------------+
//| Header of the result table. The break character marks where the  |
//| line may be cut into two labels, so no column is ever lost to    |
//| the length limit of a chart object.                              |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::PanelHeader(void)
  {
   return(HiaPadRight("Symbol",HIA_W_SYMBOL)+HiaPadLeft("Bars",HIA_W_NUM)+
          HiaPadLeft("Grid%",HIA_W_NUM)+HiaPadLeft("Sess%",HIA_W_NUM)+
          CharToString(HIA_COL_BREAK)+
          HiaPadLeft("OHLC",HIA_W_NUM)+HiaPadLeft("Time",HIA_W_NUM)+
          HiaPadLeft("Gaps",HIA_W_NUM)+HiaPadLeft("InSess",HIA_W_WIDE)+
          HiaPadLeft("Empty",HIA_W_NUM)+HiaPadLeft("Flat",HIA_W_NUM)+
          HiaPadLeft("M1bad",HIA_W_NUM)+HiaPadLeft("SprHi",HIA_W_NUM));
  }
//+------------------------------------------------------------------+
//| One row of the result table. A symbol that could not be audited  |
//| shows its status instead of numbers, so an empty row can never   |
//| be read as a clean result.                                       |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::PanelLine(void) const
  {
   if(m_status!=HIA_STATUS_OK)
      return(HiaPadRight(m_symbol,HIA_W_SYMBOL)+HiaPadLeft(HiaStatusName(m_status),3*HIA_W_NUM));
//--- every column belongs to one check. The column of a check that did not
//    run holds a dash in the same field width, so the table cannot shift
//    and "off" can never be read as "measured, nothing found"
   bool c3=m_gaps_measured;
   bool c5=(m_c5_state=="on");
   bool sess=(c3 && m_session_known);
   bool limit=(InpSpreadMaxPoints>0);
   return(HiaPadRight(m_symbol,HIA_W_SYMBOL)+HiaPadLeft(HiaNum(m_bars),HIA_W_NUM)+
          HiaPadLeft(CoverageText(m_grid_coverage,c3),HIA_W_NUM)+
          HiaPadLeft(CoverageText(m_session_coverage,sess),HIA_W_NUM)+
          CharToString(HIA_COL_BREAK)+
          HiaPadLeft(HiaText(InpCheckOHLC,HiaNum(m_c1_total)),HIA_W_NUM)+
          HiaPadLeft(HiaText(InpCheckTimes,HiaNum(m_c2_total)),HIA_W_NUM)+
          HiaPadLeft(HiaText(c3,HiaNum(m_gaps)),HIA_W_NUM)+
          HiaPadLeft(HiaText(sess,HiaNum(m_missing_in_session)),HIA_W_WIDE)+
          HiaPadLeft(HiaText(InpCheckEmpty,HiaNum(m_empty_bars)),HIA_W_NUM)+
          HiaPadLeft(HiaText(InpCheckEmpty,HiaNum(m_flat_bars)),HIA_W_NUM)+
          HiaPadLeft(HiaText(c5,HiaNum(m_m1_mismatched)),HIA_W_NUM)+
          HiaPadLeft(HiaText(limit,HiaNum(m_spread_above)),HIA_W_NUM));
  }
//+------------------------------------------------------------------+
//| The counter row of this symbol, in the column order of           |
//| CHiaReport::SummaryHeader(). The first 37 cells are the contract |
//| a recount compares; a check that did not run leaves its cell     |
//| empty, never a zero.                                             |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::SummaryLine(void) const
  {
   bool c1=InpCheckOHLC;
   bool c2=InpCheckTimes;
   bool c3=m_gaps_measured;
   bool c5=(m_c5_state=="on");
   bool c4=InpCheckEmpty;
   bool limit=(InpSpreadMaxPoints>0);
   bool sess=(c3 && m_session_known);
//--- stage: what the audit was, in the units a recount needs
   string line=m_symbol;
   line+=HIA_SEPARATOR+HiaNum(m_period_seconds);
   line+=HIA_SEPARATOR+DoubleToString(m_point,m_digits);
   line+=HIA_SEPARATOR+IntegerToString(m_digits);
   line+=HIA_SEPARATOR+IntegerToString(InpSpreadMaxPoints);
   line+=HIA_SEPARATOR+HiaNum(m_bars);
//--- the two stamps are seconds since 1970 in server time, so no reader has
//    to guess a date format or a time zone to compare them
   line+=HIA_SEPARATOR+HiaNum((long)m_first_time);
   line+=HIA_SEPARATOR+HiaNum((long)m_last_time);
//--- stage: C1, one counter per violated predicate plus their sum
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_high_lt_low));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_open_gt_high));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_open_lt_low));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_close_gt_high));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_close_lt_low));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_non_positive));
   line+=HIA_SEPARATOR+HiaCell(c1,HiaNum(m_c1_total));
//--- stage: C2 and the slot arithmetic of C3
   line+=HIA_SEPARATOR+HiaCell(c2,HiaNum(m_c2_not_increasing));
   line+=HIA_SEPARATOR+HiaCell(c2,HiaNum(m_c2_off_grid));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gap_not_multiple));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gaps));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_missing_total));
   line+=HIA_SEPARATOR+HiaCell(sess,HiaNum(m_missing_in_session));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_max_gap_slots));
//--- stage: C4 and C6
   line+=HIA_SEPARATOR+HiaCell(c4,HiaNum(m_empty_bars));
   line+=HIA_SEPARATOR+HiaCell(c4,HiaNum(m_flat_bars));
   line+=HIA_SEPARATOR+HiaNum(m_spread_zero);
   line+=HIA_SEPARATOR+HiaCell(limit,HiaNum(m_spread_above));
   line+=HIA_SEPARATOR+IntegerToString(m_spread_max);
   line+=HIA_SEPARATOR+DoubleToString(m_spread_mean,4);
//--- stage: the two coverage figures. The grid one counts every slot of the
//    period, weekends included, so on its own it says almost nothing; the
//    session one is the share of the time the broker itself says it quotes
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_expected_openings));
   line+=HIA_SEPARATOR+HiaCell(sess,HiaNum(m_expected_in_session));
   line+=HIA_SEPARATOR+HiaCell(c3,DoubleToString(m_grid_coverage,4));
   line+=HIA_SEPARATOR+HiaCell(sess,DoubleToString(m_session_coverage,4));
//--- stage: C5
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_compared));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_mismatched));
   line+=HIA_SEPARATOR+HiaCell(c5,DoubleToString(m_m1_max_dev,4));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_window_empty));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_out_of_coverage));
//--- stage: the columns a human reads. A recount ignores a name it does not
//    know, so the readable copies of the stamps live here and not above
   line+=HIA_SEPARATOR+m_period_name;
   line+=HIA_SEPARATOR+HiaStatusName(m_status);
   line+=HIA_SEPARATOR+HiaTimeText(m_first_time);
   line+=HIA_SEPARATOR+HiaTimeText(m_last_time);
   line+=HIA_SEPARATOR+DoubleToString(m_span_days,3);
   line+=HIA_SEPARATOR+HiaNum(m_lag_bars);
   line+=HIA_SEPARATOR+HiaNum(m_span_openings);
   line+=HIA_SEPARATOR+m_identity;
   line+=HIA_SEPARATOR+m_c3_state;
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gaps_explained));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gaps_unexplained));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gaps_unclassified));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_missing_unclassified));
   line+=HIA_SEPARATOR+HiaTimeText(m_max_gap_after);
   line+=HIA_SEPARATOR+IntegerToString(m_sessions_found);
   line+=HIA_SEPARATOR+CoverageText(m_session_coverage,sess);
   line+=HIA_SEPARATOR+m_c5_state;
   line+=HIA_SEPARATOR+HiaTimeText(m_m1_first);
   line+=HIA_SEPARATOR+HiaTimeText(m_m1_last);
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_dev_open));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_dev_high));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_dev_low));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_dev_close));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_dev_volume));
   line+=HIA_SEPARATOR+HiaNum(FindingsTotal());
   return(line);
  }
//+------------------------------------------------------------------+
//| One row of the overview file, which holds every symbol of the    |
//| list. A symbol that could not be audited keeps its status and    |
//| leaves every number empty, so an empty row cannot read as clean. |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::OverviewLine(void) const
  {
   string line=m_symbol+HIA_SEPARATOR+m_period_name+HIA_SEPARATOR+HiaStatusName(m_status);
   if(m_status!=HIA_STATUS_OK)
     {
      for(int i=0; i<21; i++)
         line+=HIA_SEPARATOR;
      return(line);
     }
   bool c3=m_gaps_measured;
   bool c5=(m_c5_state=="on");
   bool sess=(c3 && m_session_known);
   line+=HIA_SEPARATOR+HiaNum(m_bars);
   line+=HIA_SEPARATOR+HiaTimeText(m_first_time);
   line+=HIA_SEPARATOR+HiaTimeText(m_last_time);
   line+=HIA_SEPARATOR+DoubleToString(m_span_days,3);
   line+=HIA_SEPARATOR+HiaNum(m_lag_bars);
   line+=HIA_SEPARATOR+HiaCell(InpCheckOHLC,HiaNum(m_c1_total));
   line+=HIA_SEPARATOR+HiaCell(InpCheckTimes,HiaNum(m_c2_total));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_gaps));
   line+=HIA_SEPARATOR+HiaCell(c3,HiaNum(m_missing_total));
   line+=HIA_SEPARATOR+HiaCell(sess,HiaNum(m_missing_in_session));
   line+=HIA_SEPARATOR+HiaCell(InpCheckEmpty,HiaNum(m_empty_bars));
   line+=HIA_SEPARATOR+HiaCell(InpCheckEmpty,HiaNum(m_flat_bars));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_compared));
   line+=HIA_SEPARATOR+HiaCell(c5,HiaNum(m_m1_mismatched));
   line+=HIA_SEPARATOR+HiaCell(c5,DoubleToString(m_m1_max_dev,4));
   line+=HIA_SEPARATOR+IntegerToString(m_spread_max);
   line+=HIA_SEPARATOR+DoubleToString(m_spread_mean,4);
   line+=HIA_SEPARATOR+HiaCell(c3,DoubleToString(m_grid_coverage,4));
   line+=HIA_SEPARATOR+CoverageText(m_session_coverage,sess);
   line+=HIA_SEPARATOR+m_identity;
   line+=HIA_SEPARATOR+HiaNum(FindingsTotal());
   return(line);
  }
//+------------------------------------------------------------------+
//| The quote session table of this symbol as one readable line. An  |
//| end of 24:00 or later is printed as it is read, because a        |
//| session running past midnight is exactly what it means.          |
//+------------------------------------------------------------------+
string CHiaSymbolAudit::SessionsText(void) const
  {
   string names="Sun Mon Tue Wed Thu Fri Sat";
   string out="";
   for(int day=0; day<7; day++)
     {
      if(m_sess_count[day]<=0)
         continue;
      if(out!="")
         out+=" | ";
      out+=StringSubstr(names,day*4,3)+" ";
      for(int index=0; index<m_sess_count[day]; index++)
        {
         int slot=day*HIA_MAX_SESSIONS+index;
         if(index>0)
            out+=", ";
         out+=HiaClock(m_sess_from[slot])+"-"+HiaClock(m_sess_to[slot]);
        }
     }
   if(out=="")
      out="none reported by the broker";
   return(out);
  }
//+------------------------------------------------------------------+
//| Prints the detail of one symbol that does not fit on the chart.  |
//| The block is built so that it can be pasted into an article      |
//| without editing a single number.                                 |
//+------------------------------------------------------------------+
void CHiaSymbolAudit::PrintDetail(void) const
  {
   if(m_status!=HIA_STATUS_OK)
     {
      PrintFormat("%s %s: %s, no number was measured",m_symbol,m_period_name,HiaStatusName(m_status));
      return;
     }
   PrintFormat("%s %s: %s bars from %s to %s, %s days, %d sessions, point %s, %s opening(s) behind the server time",
               m_symbol,m_period_name,HiaNum(m_bars),HiaTimeText(m_first_time),
               HiaTimeText(m_last_time),DoubleToString(m_span_days,2),m_sessions_found,
               DoubleToString(m_point,m_digits),HiaNum(m_lag_bars));
   PrintFormat("%s %s: quote sessions %s",m_symbol,m_period_name,SessionsText());
//--- the same rule as the panel: a quantity of a check that did not run is
//    printed as a dash, so this block can be pasted into a report without
//    a caveat and every number in it was really measured
   bool c3=m_gaps_measured;
   bool c5=(m_c5_state=="on");
   bool sess=(c3 && m_session_known);
   bool limit=(InpSpreadMaxPoints>0);
   bool grid=(m_period_seconds>0);
   PrintFormat("%s %s: grid openings %s = bars %s + missing %s, identity %s, grid coverage %s%%, session coverage %s%%",
               m_symbol,m_period_name,HiaText(grid,HiaNum(m_span_openings)),HiaNum(m_bars),
               HiaText(c3,HiaNum(m_missing_total)),
               m_identity,CoverageText(m_grid_coverage,c3),
               CoverageText(m_session_coverage,sess));
   PrintFormat("%s %s: C1 %s, total %s (high<low %s, open>high %s, open<low %s, close>high %s, close<low %s, non positive %s)",
               m_symbol,m_period_name,(InpCheckOHLC ? "on" : "off"),
               HiaText(InpCheckOHLC,HiaNum(m_c1_total)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_high_lt_low)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_open_gt_high)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_open_lt_low)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_close_gt_high)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_close_lt_low)),
               HiaText(InpCheckOHLC,HiaNum(m_c1_non_positive)));
   PrintFormat("%s %s: C2 %s, total %s (not increasing %s, off grid %s), steps that are not a whole number of periods %s",
               m_symbol,m_period_name,(InpCheckTimes ? "on" : "off"),
               HiaText(InpCheckTimes,HiaNum(m_c2_total)),
               HiaText(InpCheckTimes,HiaNum(m_c2_not_increasing)),
               HiaText(InpCheckTimes && OnGrid(),HiaNum(m_c2_off_grid)),
               HiaText(c3,HiaNum(m_gap_not_multiple)));
   PrintFormat("%s %s: C3 %s, gaps %s (explained %s, unexplained %s, unclassified %s), missing %s, in session %s, unclassified %s, largest gap %s slots after %s",
               m_symbol,m_period_name,m_c3_state,HiaText(c3,HiaNum(m_gaps)),
               HiaText(c3,HiaNum(m_gaps_explained)),HiaText(c3,HiaNum(m_gaps_unexplained)),
               HiaText(c3,HiaNum(m_gaps_unclassified)),HiaText(c3,HiaNum(m_missing_total)),
               HiaText(sess,HiaNum(m_missing_in_session)),
               HiaText(c3,HiaNum(m_missing_unclassified)),HiaText(c3,HiaNum(m_max_gap_slots)),
               HiaTimeText(m_max_gap_after));
   PrintFormat("%s %s: C4 %s, empty %s, flat %s",m_symbol,m_period_name,
               (InpCheckEmpty ? "on" : "off"),HiaText(InpCheckEmpty,HiaNum(m_empty_bars)),
               HiaText(InpCheckEmpty,HiaNum(m_flat_bars)));
   PrintFormat("%s %s: C5 %s, M1 coverage %s to %s, compared %s, mismatched %s, window empty %s, out of coverage %s, max deviation %s points",
               m_symbol,m_period_name,m_c5_state,HiaTimeText(m_m1_first),HiaTimeText(m_m1_last),
               HiaText(c5,HiaNum(m_m1_compared)),HiaText(c5,HiaNum(m_m1_mismatched)),
               HiaText(c5,HiaNum(m_m1_window_empty)),HiaText(c5,HiaNum(m_m1_out_of_coverage)),
               HiaText(c5,DoubleToString(m_m1_max_dev,4)));
   if(m_m1_mismatched>0)
      PrintFormat("%s %s: C5 deviating fields: open %s, high %s, low %s, close %s, tick volume %s",
                  m_symbol,m_period_name,HiaNum(m_m1_dev_open),HiaNum(m_m1_dev_high),
                  HiaNum(m_m1_dev_low),HiaNum(m_m1_dev_close),HiaNum(m_m1_dev_volume));
   PrintFormat("%s %s: C6 limit %s, spread zero %s, above limit %s, max %d points, mean %s points",
               m_symbol,m_period_name,
               (limit ? IntegerToString(InpSpreadMaxPoints)+" points" : "off"),
               HiaNum(m_spread_zero),HiaText(limit,HiaNum(m_spread_above)),m_spread_max,
               DoubleToString(m_spread_mean,4));
   PrintFormat("%s %s: findings of this symbol %s",m_symbol,m_period_name,HiaNum(FindingsTotal()));
  }
//--- global objects and counters of the expert
CHiaReport        ExtReport;                     // journal examples and the CSV files
CHiaPanel         ExtPanel;                      // the table on the chart
CHiaSymbolAudit   ExtAudits[HIA_MAX_SYMBOLS];    // one audit per symbol of the list
string            ExtSymbols[HIA_MAX_SYMBOLS];   // the resolved symbol list
int               ExtCount=0;                    // symbols in the list
ENUM_TIMEFRAMES   ExtPeriod=PERIOD_CURRENT;      // the resolved period
string            ExtPeriodName="";              // the period as text
string            ExtPrefix="";                  // file name prefix of this instance
bool              ExtReady=false;                // Init() reached its end
bool              ExtPanelOn=false;              // the panel objects exist
bool              ExtFirstDone=false;            // the first pass has run
int               ExtPulses=0;                   // pulses counted while waiting for the history
int               ExtPass=0;                     // passes finished
datetime          ExtLastPass=0;                 // server time the last pass started
long              ExtBars=0;                     // bars audited in the last pass
long              ExtMissing=0;                  // missing openings of the last pass
long              ExtMissingSession=0;           // missing openings inside a session
long              ExtExpected=0;                 // bars + missing of the last pass
long              ExtSpanOpenings=0;             // grid openings of the audited spans
long              ExtFindings=0;                 // findings of the last pass
long              ExtC1=0;                       // C1 findings of the last pass
long              ExtC2=0;                       // C2 findings of the last pass
long              ExtC3=0;                       // C3 findings of the last pass
long              ExtC4=0;                       // C4 findings of the last pass
long              ExtC5=0;                       // C5 findings of the last pass
long              ExtC6=0;                       // C6 findings of the last pass
int               ExtOk=0;                       // symbols audited
int               ExtFailed=0;                   // symbols skipped
int               ExtIdentityOk=0;               // symbols whose counters add up
int               ExtIdentityBad=0;              // symbols whose counters do not add up
int               ExtSessionUnknown=0;           // symbols without a usable session record
int               ExtLagged=0;                   // symbols whose series ends before the server time
//+------------------------------------------------------------------+
//| Tells whether the terminal has finished building the series of   |
//| every known symbol of the list. Asking for the data is what      |
//| starts the download, so this call also triggers it.              |
//+------------------------------------------------------------------+
bool HiaHistoryReady(void)
  {
   bool ready=true;
   for(int i=0; i<ExtCount; i++)
     {
      //--- a symbol the terminal does not know can never become ready and
      //    must not hold up the audit of the others
      double point=0.0;
      if(!SymbolInfoDouble(ExtSymbols[i],SYMBOL_POINT,point) || point<=0.0)
         continue;
      long bars=0;
      long built=0;
      SeriesInfoInteger(ExtSymbols[i],ExtPeriod,SERIES_BARS_COUNT,bars);
      if(!SeriesInfoInteger(ExtSymbols[i],ExtPeriod,SERIES_SYNCHRONIZED,built) || built==0 || bars<2)
         ready=false;
     }
   return(ready);
  }
//+------------------------------------------------------------------+
//| Puts the whole expert back into its starting state. An expert is |
//| not reloaded when an input changes, so every global, every object|
//| and every counter has to be cleared here by hand (pitfall C24).  |
//+------------------------------------------------------------------+
void HiaReset(void)
  {
   ExtReport.Close();
   ExtReport.Reset();
   ExtPanel.Reset();
   for(int i=0; i<HIA_MAX_SYMBOLS; i++)
     {
      ExtAudits[i].Reset();
      ExtSymbols[i]="";
     }
   ExtCount=0;
   ExtPeriod=PERIOD_CURRENT;
   ExtPeriodName="";
   ExtPrefix="";
   ExtReady=false;
   ExtPanelOn=false;
   ExtFirstDone=false;
   ExtPulses=0;
   ExtPass=0;
   ExtLastPass=0;
   ExtBars=0;
   ExtMissing=0;
   ExtMissingSession=0;
   ExtExpected=0;
   ExtSpanOpenings=0;
   ExtFindings=0;
   ExtC1=0;
   ExtC2=0;
   ExtC3=0;
   ExtC4=0;
   ExtC5=0;
   ExtC6=0;
   ExtOk=0;
   ExtFailed=0;
   ExtIdentityOk=0;
   ExtIdentityBad=0;
   ExtSessionUnknown=0;
   ExtLagged=0;
  }
//+------------------------------------------------------------------+
//| Adds one symbol to the list if there is room and if it is not in |
//| the list yet. A duplicate would be audited twice and would show  |
//| up twice in every total.                                         |
//+------------------------------------------------------------------+
void HiaAddSymbol(const string name)
  {
   if(name=="")
      return;
   for(int i=0; i<ExtCount; i++)
      if(ExtSymbols[i]==name)
         return;
   if(ExtCount>=HIA_MAX_SYMBOLS)
     {
      if(ExtCount==HIA_MAX_SYMBOLS)
         PrintFormat("%s: the list is full at %d symbols, %s and the rest are not audited",
                     HIA_NAME,HIA_MAX_SYMBOLS,name);
      return;
     }
   ExtSymbols[ExtCount]=name;
   ExtCount++;
  }
//+------------------------------------------------------------------+
//| Resolves the symbol input into the list that is audited. The     |
//| Market Watch is only read, never changed: adding a symbol to it  |
//| would be a side effect of a measuring tool.                      |
//+------------------------------------------------------------------+
void HiaBuildSymbolList(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
//--- stage: the chart symbol
   if(text=="")
     {
      HiaAddSymbol(Symbol());
      return;
     }
//--- stage: everything the Market Watch shows
   if(text=="*")
     {
      int total=SymbolsTotal(true);
      for(int i=0; i<total; i++)
         HiaAddSymbol(SymbolName(i,true));
      if(ExtCount<=0)
        {
         PrintFormat("%s: the Market Watch is empty, the chart symbol is audited instead",HIA_NAME);
         HiaAddSymbol(Symbol());
        }
      return;
     }
//--- stage: a list of names. Both separators are accepted, because a
//    semicolon is what a terminal of a comma decimal locale offers and
//    because a comma cannot be typed in every parameter dialog
   StringReplace(text,";",",");
   string parts[];
   int    count=StringSplit(text,(ushort)',',parts);
   for(int i=0; i<count; i++)
     {
      string name=parts[i];
      StringTrimLeft(name);
      StringTrimRight(name);
      HiaAddSymbol(name);
     }
   if(ExtCount<=0)
     {
      PrintFormat("%s: the symbol list held no name, the chart symbol is audited instead",HIA_NAME);
      HiaAddSymbol(Symbol());
     }
  }
//+------------------------------------------------------------------+
//| Short tag of the symbol selection for the file names. Together   |
//| with the period and the chart id it keeps two instances of the   |
//| tool from writing into the same file.                            |
//+------------------------------------------------------------------+
string HiaSymbolsTag(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
      return("MarketWatch");
   if(ExtCount<=0)
      return("none");
   if(ExtCount==1)
      return(HiaSafeName(ExtSymbols[0]));
   return(HiaSafeName(ExtSymbols[0])+"_plus"+IntegerToString(ExtCount-1));
  }
//+------------------------------------------------------------------+
//| Prints the settings of the run. Every number the tool works with |
//| is printed once, including the values it had to clamp, so a      |
//| reader never has to guess what was measured.                     |
//+------------------------------------------------------------------+
void HiaPrintStartBlock(void)
  {
   Print("=== "+HIA_TITLE+" ============================================");
   PrintFormat("symbols        : %d (%s)",ExtCount,(InpSymbols=="" ? "chart symbol" :
               (InpSymbols=="*" ? "Market Watch" : "list")));
   PrintFormat("period         : %s   bars per symbol: %d (closed bars, newest first)",
               ExtPeriodName,InpBars);
   PrintFormat("checks         : C1 %s  C2 %s  C3 %s  C4 %s  C5 %s  C6 limit %d points",
               (InpCheckOHLC ? "on" : "off"),(InpCheckTimes ? "on" : "off"),
               (InpCheckGaps ? "on" : "off"),(InpCheckEmpty ? "on" : "off"),
               (InpCheckM1 ? "on" : "off"),InpSpreadMaxPoints);
   PrintFormat("C5 tolerance   : %s points   journal examples per check: %d",
               DoubleToString(InpM1TolerancePoints,2),InpMaxExamples);
   PrintFormat("refresh        : %s",(InpRefreshMinutes>0 ?
                                      IntegerToString(InpRefreshMinutes)+" minutes of server time" : "once"));
   PrintFormat("file prefix    : %s\\%s_*.csv",HIA_FOLDER,ExtPrefix);
   if(InpBars<2 || InpBars>HIA_MAX_BARS)
      PrintFormat("%s: InpBars %d is outside 2..%d and was clamped for the audit",
                  HIA_NAME,InpBars,HIA_MAX_BARS);
   for(int i=0; i<ExtCount; i++)
      PrintFormat("symbol %d of %d  : %s",i+1,ExtCount,ExtSymbols[i]);
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Prints the result block of one pass: the table, the detail of    |
//| every symbol and the two arithmetic checks the tool runs on its  |
//| own counters.                                                    |
//+------------------------------------------------------------------+
void HiaPrintSummary(void)
  {
   Print("=== "+HIA_TITLE+" - result of pass "+IntegerToString(ExtPass)+" ========");
   string header=CHiaSymbolAudit::PanelHeader();
   StringReplace(header,CharToString(HIA_COL_BREAK),"");
   Print(header);
   for(int i=0; i<ExtCount; i++)
     {
      string row=ExtAudits[i].PanelLine();
      StringReplace(row,CharToString(HIA_COL_BREAK),"");
      Print(row);
     }
   for(int i=0; i<ExtCount; i++)
      ExtAudits[i].PrintDetail();
   PrintFormat("symbols        : %d audited, %d skipped",ExtOk,ExtFailed);
//--- the aggregate obeys the same rule: if C3 ran on no symbol at all there
//    is no missing-opening figure to report and a 0 would be a wrong number
   bool any_gaps=false;
   bool any_sess=false;
   for(int i=0; i<ExtCount; i++)
     {
      if(ExtAudits[i].Status()!=HIA_STATUS_OK || !ExtAudits[i].GapsMeasured())
         continue;
      any_gaps=true;
      if(ExtAudits[i].SessionKnown())
         any_sess=true;
     }
   PrintFormat("totals         : bars %s, missing %s, in session %s, findings %s",
               HiaNum(ExtBars),HiaText(any_gaps,HiaNum(ExtMissing)),
               HiaText(any_sess,HiaNum(ExtMissingSession)),HiaNum(ExtFindings));
//--- arithmetic check 1: the slot arithmetic of the audited spans
   bool sum_ok=((ExtBars+ExtMissing)==ExtExpected);
   bool span_ok=(ExtExpected==ExtSpanOpenings);
   PrintFormat("audit 1        : bars %s + missing %s = %s, expected_openings %s -> %s",
               HiaNum(ExtBars),HiaNum(ExtMissing),HiaNum(ExtBars+ExtMissing),HiaNum(ExtExpected),
               (sum_ok ? "OK" : "MISMATCH"));
   PrintFormat("audit 1        : expected_openings %s, grid openings in the audited spans %s -> %s (%d symbols OK, %d not)",
               HiaNum(ExtExpected),HiaNum(ExtSpanOpenings),(span_ok ? "OK" : "MISMATCH"),
               ExtIdentityOk,ExtIdentityBad);
   if(!span_ok)
      Print("audit 1        : a mismatch here means C2 found a stamp off the grid or out of order");
//--- arithmetic check 2: every finding reaches the report exactly once
   long by_check=ExtC1+ExtC2+ExtC3+ExtC4+ExtC5+ExtC6;
   PrintFormat("audit 2        : C1 %s + C2 %s + C3 %s + C4 %s + C5 %s + C6 %s = %s, findings total %s -> %s",
               HiaNum(ExtC1),HiaNum(ExtC2),HiaNum(ExtC3),HiaNum(ExtC4),HiaNum(ExtC5),HiaNum(ExtC6),
               HiaNum(by_check),HiaNum(ExtFindings),(by_check==ExtFindings ? "OK" : "MISMATCH"));
   PrintFormat("audit 2        : findings handed to the report %s, rows in the findings file %s, dropped by the guard %s -> %s",
               HiaNum(ExtReport.Seen()),HiaNum(ExtReport.Rows()),HiaNum(ExtReport.Dropped()),
               ((ExtReport.Seen()==ExtFindings) &&
                (!ExtReport.FindingsOn() || ExtReport.Seen()==ExtReport.Rows()+ExtReport.Dropped())
                ? "OK" : "MISMATCH"));
   if(ExtSessionUnknown>0)
      PrintFormat("note           : %d symbol(s) have no usable session record, their session coverage is undefined",
                  ExtSessionUnknown);
   if(ExtLagged>0)
      PrintFormat("note           : %d symbol(s) end before the last known server time, see the lag_bars column",
                  ExtLagged);
//--- the files of this pass. One bar dump belongs to exactly one counter
//    row of exactly one symbol, which is what makes a recount possible
   PrintFormat("file overview  : %s (%s rows)",(ExtReport.OverviewOn() ? ExtReport.OverviewName() : "off"),
               HiaNum(ExtReport.OverviewRows()));
   PrintFormat("file findings  : %s (%s rows)",(ExtReport.FindingsOn() ? ExtReport.FindingsName() : "off"),
               HiaNum(ExtReport.Rows()));
   PrintFormat("files summary  : %d file(s), %s row(s); sessions %d file(s), %s row(s); bars %d file(s), %s row(s)",
               ExtReport.SummaryFiles(),HiaNum(ExtReport.SummaryRows()),ExtReport.SessionsFiles(),
               HiaNum(ExtReport.SessionRows()),ExtReport.BarsFiles(),HiaNum(ExtReport.BarRows()));
   PrintFormat("file pattern   : %s\\%s_<symbol>_{summary,sessions,bars}.csv",HIA_FOLDER,ExtPrefix);
   if(ExtPanelOn)
      PrintFormat("panel          : %d x %d pixels, %d labels, widest line %d characters",
                  ExtPanel.WidthPx(),ExtPanel.HeightPx(),ExtPanel.Labels(),ExtPanel.Widest());
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Builds the lines of the panel and picks the colour of its title. |
//| Only the first rows fit on a chart, the journal and the CSV hold |
//| every symbol of the list.                                        |
//+------------------------------------------------------------------+
void HiaBuildLines(string &lines[],color &title_color)
  {
   int shown=(ExtCount<HIA_PANEL_ROWS ? ExtCount : HIA_PANEL_ROWS);
   int count=5+shown+(ExtCount>shown ? 1 : 0);
   ArrayResize(lines,count);
   int row=0;
   lines[row++]=HIA_TITLE+"   pass "+IntegerToString(ExtPass)+
                (ExtFirstDone ? "" : "   waiting for the history");
   lines[row++]=ExtPeriodName+"   symbols "+IntegerToString(ExtCount)+"   bars/symbol "+
                IntegerToString(InpBars)+"   "+HiaTimeText(ExtLastPass);
   lines[row++]="findings "+HiaNum(ExtFindings)+"   csv rows "+HiaNum(ExtReport.Rows())+
                "   identity OK "+IntegerToString(ExtIdentityOk)+"/"+IntegerToString(ExtOk)+
                "   skipped "+IntegerToString(ExtFailed);
   lines[row++]=CHiaSymbolAudit::PanelHeader();
   for(int i=0; i<shown; i++)
      lines[row++]=ExtAudits[i].PanelLine();
   if(ExtCount>shown)
      lines[row++]="... and "+IntegerToString(ExtCount-shown)+
                   " more symbols, see the journal and the CSV";
   lines[row]=(ExtReport.OverviewOn() ? HIA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "CSV off");
   title_color=(ExtFindings>0 ? HIA_DIRTY_COLOR : HIA_CLEAN_COLOR);
  }
//+------------------------------------------------------------------+
//| Redraws the panel with the numbers of the last pass.             |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
void HiaUpdatePanel(void)
  {
   if(!ExtPanelOn)
      return;
   string lines[];
   color  title_color=HIA_TEXT_COLOR;
   HiaBuildLines(lines,title_color);
   ExtPanel.Update(lines,title_color);
  }
//+------------------------------------------------------------------+
//| Runs one pass over the whole symbol list. The files are rewritten|
//| from scratch, so they always hold exactly one pass and the row   |
//| identity of the summary stays checkable.                         |
//+------------------------------------------------------------------+
void HiaRunPass(void)
  {
   ExtPass++;
   ExtLastPass=HiaNow();
//--- stage: the totals of the previous pass must not be added to this one
   ExtBars=0;
   ExtMissing=0;
   ExtMissingSession=0;
   ExtExpected=0;
   ExtSpanOpenings=0;
   ExtFindings=0;
   ExtC1=0;
   ExtC2=0;
   ExtC3=0;
   ExtC4=0;
   ExtC5=0;
   ExtC6=0;
   ExtOk=0;
   ExtFailed=0;
   ExtIdentityOk=0;
   ExtIdentityBad=0;
   ExtSessionUnknown=0;
   ExtLagged=0;
   ExtReport.Close();
   ExtReport.Reset();
   ExtReport.Open(ExtPrefix);
   PrintFormat("%s: pass %d starts on %d symbol(s), %s, server time %s",
               HIA_NAME,ExtPass,ExtCount,ExtPeriodName,HiaTimeText(ExtLastPass));
//--- stage: one symbol after the other, a failure costs one symbol
   for(int i=0; i<ExtCount; i++)
     {
      ExtAudits[i].SetContext(ExtSymbols[i],ExtPeriod);
      bool audited=ExtAudits[i].Audit(ExtReport);
      //--- the counter row goes into the file of its own symbol, the overview
      //    row into the file of the whole pass, and only then are the three
      //    per symbol files closed again
      if(audited)
         ExtReport.SummaryRow(ExtAudits[i].SummaryLine());
      ExtReport.OverviewRow(ExtAudits[i].OverviewLine());
      ExtReport.Flush();
      ExtReport.CloseSymbol();
      if(!audited)
        {
         ExtFailed++;
         continue;
        }
      ExtOk++;
      ExtBars+=(long)ExtAudits[i].Bars();
      ExtMissing+=ExtAudits[i].MissingTotal();
      ExtMissingSession+=ExtAudits[i].MissingInSession();
      ExtExpected+=ExtAudits[i].ExpectedOpenings();
      ExtSpanOpenings+=ExtAudits[i].SpanOpenings();
      ExtFindings+=ExtAudits[i].FindingsTotal();
      ExtC1+=ExtAudits[i].C1Findings();
      ExtC2+=ExtAudits[i].C2Findings();
      ExtC3+=ExtAudits[i].C3Findings();
      ExtC4+=ExtAudits[i].C4Findings();
      ExtC5+=ExtAudits[i].C5Findings();
      ExtC6+=ExtAudits[i].C6Findings();
      if(ExtAudits[i].Identity()=="OK")
         ExtIdentityOk++;
      else
         if(ExtAudits[i].Identity()=="MISMATCH")
            ExtIdentityBad++;
      if(!ExtAudits[i].SessionKnown())
         ExtSessionUnknown++;
      if(ExtAudits[i].LagBars()>0)
         ExtLagged++;
     }
//--- stage: the panel is redrawn before the result block, so the pixel
//    size the block reports is the size of the table that is really on
//    the chart and not the one of the previous redraw
   HiaUpdatePanel();
   HiaPrintSummary();
   ExtReport.Close();
  }
//+------------------------------------------------------------------+
//| Reads the inputs, resolves the symbol list and prepares the      |
//| panel. Nothing in here can fail in a way that stops the expert:  |
//| a problem costs one symbol, one file or the panel, never the run.|
//+------------------------------------------------------------------+
void HiaInit(void)
  {
//--- stage: a previous run can still be in these objects, see HiaReset()
   HiaReset();
//--- stage: period and symbol list
   ExtPeriod=(InpTimeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)Period() : InpTimeframe);
   ExtPeriodName=HiaPeriodName(ExtPeriod);
   HiaBuildSymbolList();
   for(int i=0; i<ExtCount; i++)
      ExtAudits[i].SetContext(ExtSymbols[i],ExtPeriod);
   ExtPrefix=HiaSymbolsTag()+"_"+ExtPeriodName+"_"+IntegerToString(ChartID());
//--- stage: the panel. Without visual mode the tester has no chart to
//    draw on, so the panel stays off and the journal says why.
   if(InpShowPanel)
     {
      if(MQLInfoInteger(MQL_TESTER)!=0 && MQLInfoInteger(MQL_VISUAL_MODE)==0)
         PrintFormat("%s: the panel stays off, the tester runs without visual mode",HIA_NAME);
      else
         ExtPanelOn=ExtPanel.Create();
     }
   HiaPrintStartBlock();
//--- the flag is set last: OnDeinit() runs even after a failed start and
//    must not report a run that never happened
   ExtReady=true;
   HiaUpdatePanel();
  }
//+------------------------------------------------------------------+
//| One pulse of the expert, shared by OnTick() and OnTimer(). The   |
//| first pass waits for the history instead of reporting an empty   |
//| series, which a fresh terminal or a tester start would produce.  |
//+------------------------------------------------------------------+
void HiaPulse(void)
  {
   if(!ExtReady)
      return;
   if(!ExtFirstDone)
     {
      ExtPulses++;
      //--- the series of a symbol only exists after the terminal has built
      //    it, and HiaHistoryReady() skips the names the terminal does not
      //    know, so an unknown symbol cannot hold the whole audit back
      bool ready=(ExtCount>0 && HiaHistoryReady());
      if(!ready && ExtPulses<HIA_WARMUP_PULSES)
        {
         HiaUpdatePanel();
         return;
        }
      ExtFirstDone=true;
      HiaRunPass();
      if(InpRefreshMinutes<=0)
        {
         EventKillTimer();
         PrintFormat("%s: the audit is finished, the timer is stopped (InpRefreshMinutes = 0)",HIA_NAME);
        }
      return;
     }
   if(InpRefreshMinutes>0 && ((long)HiaNow()-(long)ExtLastPass)>=(long)InpRefreshMinutes*60)
      HiaRunPass();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   HiaInit();
//--- the timer keeps the tool alive when no tick arrives, for example
//    over a weekend, and it drives the optional re-audit
   EventSetTimer(1);
//--- no reachable state of this tool is fatal: a measuring tool that
//    refuses to start tells the user nothing at all
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
//--- OnDeinit() also runs after a failed start, where the counters were
//    never filled; only the closing report is skipped then, the files
//    and the objects are released in every case
   if(ExtReady)
      PrintFormat("%s: %d pass(es) finished, %s bars audited, %s findings counted",
                  HIA_NAME,ExtPass,HiaNum(ExtBars),HiaNum(ExtFindings));
   ExtReport.Close();
   ExtPanel.Destroy();
   PrintFormat("%s: stopped, deinitialisation reason %d",HIA_NAME,reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   HiaPulse();
  }
//+------------------------------------------------------------------+
//| Timer function: drives the first pass when no tick arrives and   |
//| the optional re-audit afterwards.                                |
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   HiaPulse();
  }
//+------------------------------------------------------------------+
