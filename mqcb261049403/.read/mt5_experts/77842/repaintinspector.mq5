//+------------------------------------------------------------------+
//|                                             RepaintInspector.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Measures whether an indicator repaints instead of trusting the claim."
#property description "The buffers of the indicator under test are re-read on already closed"
#property description "bars, and every value that still changes afterwards is counted, timed"
#property description "and written to a CSV file."
#property description "Read only measuring tool - it never calls a trade function."
//--- limits and behaviour constants
#define RI_MAX_BUFFERS     32                  // highest number of buffers that can be watched
#define RI_MAX_SLOTS       200000              // memory guard: bars*buffers may not exceed this
#define RI_MAX_EVENT_LOG   20                  // events printed to the journal one by one
#define RI_MAX_ERROR_LOG   5                   // copy errors printed to the journal
#define RI_SUMMARY_SECONDS 15                  // how often the summary CSV is refreshed
#define RI_RETRY_SECONDS   30                  // pause before a failed handle creation is retried
#define RI_PANEL_FONT      "Consolas"          // monospace font, the panel is a table
#define RI_OBJ_PREFIX      "RepaintInspector"  // first part of every chart object name
//--- width of the report columns, shared by the panel and the journal
#define RI_W_BUF           3                   // column "Buf"
#define RI_W_VERDICT       9                   // column "Verdict"
#define RI_W_COMP          13                  // column "Comparisons"
#define RI_W_EVENT         9                   // columns "Changed", "Appeared", "Vanished"
#define RI_W_SHIFT         9                   // column "MaxShift"
#define RI_W_DELTA         13                  // column "Max |delta|"
//--- a chart object holds a limited amount of text, so a report line that is
//    longer is drawn as several labels side by side
#define RI_MAX_LABEL       62                  // characters one label can show
#define RI_COL_BREAK       1                   // marks where a line may be split
//+------------------------------------------------------------------+
//| Kind of event detected on a bar that was already closed when the |
//| value was published for the first time                           |
//+------------------------------------------------------------------+
enum ENUM_RI_EVENT
  {
   RI_EVENT_NONE=0,     // nothing changed
   RI_EVENT_CHANGED,    // value -> different value
   RI_EVENT_APPEARED,   // empty -> value
   RI_EVENT_VANISHED    // value -> empty
  };
//--- input parameters
input group "Indicator under test"
input string           InpIndicator     = "";                  // Indicator to inspect (iCustom path, no .ex5; example: Examples\ZigZag)
input string           InpParameters    = "";                  // Parameters, comma separated (empty = indicator defaults)
input int              InpBuffers       = 1;                   // Number of buffers to watch (1..32)
input string           InpSymbol        = "";                  // Symbol (empty = chart symbol)
input ENUM_TIMEFRAMES  InpTimeframe     = PERIOD_CURRENT;      // Timeframe
input group "Measurement"
input int              InpBarsWatched   = 300;                 // Closed bars watched (shift 1..N)
input int              InpCheckSeconds  = 1;                   // Minimum seconds between checks, modelled time in the tester (0 = every tick)
input double           InpTolerance     = 0.0;                 // Ignore |change| smaller than this (0 = count every change)
input bool             InpZeroIsEmpty   = true;                // Treat 0.0 as "no value" (arrow/ZigZag style buffers)
input int              InpReloadMinutes = 0;                   // Recreate the indicator handle every N minutes (0 = never)
input int              InpRunMinutes    = 0;                   // Stop measuring after N minutes (0 = run until removed)
input group "Report"
input bool             InpCsv           = true;                // Write every event to MQL5\Files (CSV)
input string           InpCsvName       = "";                  // CSV file name (empty = automatic)
input int              InpCsvMaxRows    = 100000;              // Stop writing after this many rows
input group "Panel"
input bool             InpShowPanel     = true;                // Show the report panel on the chart
input int              InpPanelX        = 12;                  // Panel X distance, pixels at 96 dpi
input int              InpPanelY        = 20;                  // Panel Y distance, pixels at 96 dpi
input int              InpFontSize      = 9;                   // Font size, points (4 or more; the panel scales with the screen dpi)
input ENUM_BASE_CORNER InpCorner        = CORNER_LEFT_UPPER;   // Panel corner
input color            InpBackColor     = C'28,28,28';         // Panel background colour
input color            InpBorderColor   = clrDimGray;          // Panel border colour
input color            InpTextColor     = clrGainsboro;        // Panel text colour
input color            InpStableColor   = clrLimeGreen;        // Header colour when every buffer is stable
input color            InpRepaintColor  = clrTomato;           // Header colour when a buffer repaints
//+------------------------------------------------------------------+
//| Returns the text right aligned in a field of "width" characters. |
//| Text that does not fit is returned unchanged, so that a reported |
//| number can never be cut off by the layout.                       |
//+------------------------------------------------------------------+
string RiPadLeft(const string text,const int width)
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
//| Returns the text left aligned in a field of "width" characters.  |
//| Text that does not fit is returned unchanged, so that a reported |
//| number can never be cut off by the layout.                       |
//+------------------------------------------------------------------+
string RiPadRight(const string text,const int width)
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
//| Groups a counter in thousands with a space, so that a comparison |
//| count of several millions stays readable on the panel.           |
//| The value itself is never rounded.                               |
//+------------------------------------------------------------------+
string RiFormatCount(const long value)
  {
   string digits=IntegerToString(value<0 ? -value : value);
   int    len=StringLen(digits);
   string out="";
   for(int i=0; i<len; i++)
     {
      if(i>0 && ((len-i)%3)==0)
         out+=" ";
      out+=StringSubstr(digits,i,1);
     }
   if(value<0)
      out="-"+out;
   return(out);
  }
//+------------------------------------------------------------------+
//| Timeframe name without the PERIOD_ prefix, so that the report    |
//| shows "M1" and not "PERIOD_M1".                                  |
//|                                                                  |
//+------------------------------------------------------------------+
string RiTimeframeName(const ENUM_TIMEFRAMES timeframe)
  {
   string name=EnumToString(timeframe);
   if(StringSubstr(name,0,7)=="PERIOD_")
      name=StringSubstr(name,7);
   return(name);
  }
//+------------------------------------------------------------------+
//| Formats a number of seconds as hh:mm:ss for the run time line.   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
string RiDuration(const long seconds)
  {
   long value=(seconds>0 ? seconds : 0);
   return(StringFormat("%02d:%02d:%02d",(int)(value/3600),(int)((value%3600)/60),(int)(value%60)));
  }
//+------------------------------------------------------------------+
//| Name of an event as it is written to the journal and the CSV.    |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
string RiEventName(const ENUM_RI_EVENT event_type)
  {
   switch(event_type)
     {
      case RI_EVENT_CHANGED :
         return("CHANGED");
      case RI_EVENT_APPEARED :
         return("APPEARED");
      case RI_EVENT_VANISHED :
         return("VANISHED");
      default :
         break;
     }
   return("NONE");
  }
//+------------------------------------------------------------------+
//| Tells whether a parameter token is a number and whether it has   |
//| to be passed as a double (decimal point or exponent) instead of  |
//| an integer. Accepts forms like -12, 0.5, 1e-3, +2.5E+10.         |
//+------------------------------------------------------------------+
bool RiIsNumeric(const string text,bool &is_real)
  {
   is_real=false;
   int len=StringLen(text);
   if(len<=0)
      return(false);
   int    index=0;
   ushort symbol=StringGetCharacter(text,0);
   if(symbol=='+' || symbol=='-')
      index=1;
   int  mantissa=0,dots=0,exponent=0;
   bool after_e=false;
   for(; index<len; index++)
     {
      symbol=StringGetCharacter(text,index);
      if(symbol>='0' && symbol<='9')
        {
         if(after_e)
            exponent++;
         else
            mantissa++;
         continue;
        }
      if(symbol=='.' && !after_e && dots==0)
        {
         dots++;
         continue;
        }
      if((symbol=='e' || symbol=='E') && !after_e && mantissa>0)
        {
         after_e=true;
         if(index+1<len)
           {
            ushort next=StringGetCharacter(text,index+1);
            if(next=='+' || next=='-')
               index++;
           }
         continue;
        }
      return(false);
     }
   if(mantissa==0)
      return(false);
   if(after_e && exponent==0)
      return(false);
   is_real=(dots>0 || after_e);
   return(true);
  }
//+------------------------------------------------------------------+
//| Replaces the characters that are not allowed in a file name, so  |
//| that symbols like "XAUUSD.m" or "US500/USD" still produce a      |
//| usable automatic CSV name.                                       |
//+------------------------------------------------------------------+
string RiSafeName(const string text)
  {
   string out="";
   int    len=StringLen(text);
   for(int i=0; i<len; i++)
     {
      ushort symbol=StringGetCharacter(text,i);
      bool   good=((symbol>='0' && symbol<='9') || (symbol>='A' && symbol<='Z') ||
                   (symbol>='a' && symbol<='z') || symbol=='.' || symbol=='-' || symbol=='_');
      out+=(good ? ShortToString(symbol) : "_");
     }
   return(out);
  }
//+------------------------------------------------------------------+
//| Panel of the repaint inspector: one background rectangle and one |
//| label per report line, drawn with a monospace font so that the   |
//| columns line up. It only draws, it never measures anything.      |
//+------------------------------------------------------------------+
class CRepaintPanel
  {
private:
   long              m_chart;             // chart the panel belongs to
   string            m_prefix;            // unique name prefix of every own object
   bool              m_created;           // background object exists
   int               m_rows;              // report lines the panel currently shows
   int               m_columns;           // label columns the panel currently shows
   int               m_x;                 // x distance in pixels
   int               m_y;                 // y distance in pixels
   int               m_pad;               // inner padding in pixels
   int               m_line_height;       // distance between two lines in pixels
   int               m_char_width;        // width of one character in pixels
   int               m_font_size;         // font size in points
   ENUM_BASE_CORNER  m_corner;            // chart corner the panel is anchored to
   ENUM_ANCHOR_POINT m_anchor;            // anchor of every label

   string            LabelName(const int row,const int column) const
     {               return(m_prefix+"L"+IntegerToString(row)+"_"+IntegerToString(column)); }
   bool              CreateLabel(const int row,const int column);
   int               SplitLine(const string text,string &pieces[]) const;

public:
                     CRepaintPanel(void);
                    ~CRepaintPanel(void);
   bool              Create(void);
   void              Destroy(void);
   void              Update(const string &lines[],const color header_color);
  };
//+------------------------------------------------------------------+
//| Constructor: the panel is not drawn before Create() is called.   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
CRepaintPanel::CRepaintPanel(void) : m_chart(0),
   m_prefix(""),
   m_created(false),
   m_rows(0),
   m_columns(0),
   m_x(0),
   m_y(0),
   m_pad(6),
   m_line_height(14),
   m_char_width(7),
   m_font_size(9),
   m_corner(CORNER_LEFT_UPPER),
   m_anchor(ANCHOR_LEFT_UPPER)
  {
  }
//+------------------------------------------------------------------+
//| Destructor: objects are removed by Destroy(), which is called    |
//| from OnDeinit() while the chart still exists.                    |
//|                                                                  |
//+------------------------------------------------------------------+
CRepaintPanel::~CRepaintPanel(void)
  {
  }
//+------------------------------------------------------------------+
//| Builds the object prefix and the background rectangle. The       |
//| prefix contains the chart id and the first free instance index,  |
//| so a new copy cannot overwrite objects an earlier one left.      |
//+------------------------------------------------------------------+
bool CRepaintPanel::Create(void)
  {
   m_chart=ChartID();
//--- find the first instance index that is not used on this chart
   int instance=0;
   for(; instance<16; instance++)
     {
      string probe=RI_OBJ_PREFIX+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
      if(ObjectFind(m_chart,probe+"bg")<0)
         break;
     }
   if(instance>15)
      instance=15;
   m_prefix=RI_OBJ_PREFIX+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
//--- geometry: points stay points, pixels follow the screen dpi
   double scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   m_font_size  =MathMax(4,InpFontSize);
   m_pad        =(int)MathRound(6.0*scale);
   m_line_height=(int)MathRound(m_font_size*1.70*scale);
   m_char_width =(int)MathCeil(m_font_size*0.75*scale);
//--- one measurement is enough for a monospace font, and it keeps the
//    columns of the report where they belong on every screen
   uint text_width=0,text_height=0;
   TextSetFont(RI_PANEL_FONT,-m_font_size*10,FW_NORMAL,0);
   if(TextGetSize("0123456789",text_width,text_height) && text_width>0)
      m_char_width=(int)MathCeil(text_width/10.0);
   m_x          =(int)MathRound(MathMax(0,InpPanelX)*scale);
   m_y          =(int)MathRound(MathMax(0,InpPanelY)*scale);
   m_corner     =InpCorner;
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
//--- background
   string name=m_prefix+"bg";
   if(!ObjectCreate(m_chart,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      PrintFormat("RepaintInspector: cannot create the panel background, error %d",GetLastError());
      return(false);
     }
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,m_x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y);
   ObjectSetInteger(m_chart,name,OBJPROP_BGCOLOR,InpBackColor);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,InpBorderColor);
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
//| Creates one text label of the report table and gives it the      |
//| monospace font shared by every line.                             |
//|                                                                  |
//+------------------------------------------------------------------+
bool CRepaintPanel::CreateLabel(const int row,const int column)
  {
   string name=LabelName(row,column);
   if(ObjectFind(m_chart,name)>=0)
      return(true);
   if(!ObjectCreate(m_chart,name,OBJ_LABEL,0,0,0))
      return(false);
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_ANCHOR,m_anchor);
   ObjectSetString(m_chart,name,OBJPROP_FONT,RI_PANEL_FONT);
   ObjectSetInteger(m_chart,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,InpTextColor);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Deletes every object of this instance. Only objects that carry   |
//| the own prefix are removed, so other programs on the same chart  |
//| are never touched.                                               |
//+------------------------------------------------------------------+
void CRepaintPanel::Destroy(void)
  {
   if(m_prefix=="")
      return;
   ObjectsDeleteAll(m_chart,m_prefix);
   ChartRedraw(m_chart);
   m_created=false;
   m_rows=0;
   m_columns=0;
  }
//+------------------------------------------------------------------+
//| Redraws the report. Every line is padded to the same length so   |
//| that the table also stays aligned in the right hand corners,     |
//| where the labels are anchored on their right edge.               |
//+------------------------------------------------------------------+
void CRepaintPanel::Update(const string &lines[],const color header_color)
  {
   if(!m_created)
      return;
   int count=ArraySize(lines);
   if(count<=0)
      return;
//--- how many label columns are needed and how wide the widest line is
   string pieces[];
   int    columns=0;
   int    widest=0;
   for(int i=0; i<count; i++)
     {
      int parts=SplitLine(lines[i],pieces);
      columns=MathMax(columns,parts);
      for(int c=0; c<parts; c++)
        {
         if(pieces[c]!="")
            widest=MathMax(widest,c*RI_MAX_LABEL+StringLen(pieces[c]));
        }
     }
//--- remove the labels that are not needed any more
   for(int r=0; r<m_rows; r++)
      for(int c=0; c<m_columns; c++)
         if(r>=count || c>=columns)
            ObjectDelete(m_chart,LabelName(r,c));
//--- text
   for(int i=0; i<count; i++)
     {
      int parts=SplitLine(lines[i],pieces);
      int row=(m_anchor==ANCHOR_LEFT_LOWER || m_anchor==ANCHOR_RIGHT_LOWER) ? (count-1-i) : i;
      for(int c=0; c<columns; c++)
        {
         string name=LabelName(i,c);
         string text=(c<parts ? pieces[c] : "");
         //--- a label without text shows the terminal placeholder, so it is removed
         if(text=="")
           {
            ObjectDelete(m_chart,name);
            continue;
           }
         if(!CreateLabel(i,c))
            continue;
         int    x=m_x+m_pad+c*RI_MAX_LABEL*m_char_width;
         if(m_anchor==ANCHOR_RIGHT_UPPER || m_anchor==ANCHOR_RIGHT_LOWER)
            x=m_x+m_pad+(widest-c*RI_MAX_LABEL-StringLen(text))*m_char_width;
         ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y+m_pad+row*m_line_height);
         ObjectSetInteger(m_chart,name,OBJPROP_COLOR,(i==0 ? header_color : InpTextColor));
         ObjectSetString(m_chart,name,OBJPROP_TEXT,text);
        }
     }
   m_rows=count;
   m_columns=columns;
//--- background size
   string bg=m_prefix+"bg";
   ObjectSetInteger(m_chart,bg,OBJPROP_XSIZE,2*m_pad+widest*m_char_width);
   ObjectSetInteger(m_chart,bg,OBJPROP_YSIZE,2*m_pad+count*m_line_height);
   ChartRedraw(m_chart);
  }
//+------------------------------------------------------------------+
//| Cuts one report line into the pieces that single labels can show.|
//| A break character marks the wanted split, and anything that is   |
//| still too long simply continues in the next column.              |
//+------------------------------------------------------------------+
int CRepaintPanel::SplitLine(const string text,string &pieces[]) const
  {
   ArrayResize(pieces,0);
   string parts[];
   int    count=StringSplit(text,(ushort)RI_COL_BREAK,parts);
   if(count<=0)
     {
      count=1;
      ArrayResize(parts,1);
      parts[0]=text;
     }
   for(int i=0; i<count; i++)
     {
      string rest=parts[i];
      while(StringLen(rest)>RI_MAX_LABEL)
        {
         int index=ArraySize(pieces);
         ArrayResize(pieces,index+1);
         pieces[index]=StringSubstr(rest,0,RI_MAX_LABEL);
         rest=StringSubstr(rest,RI_MAX_LABEL);
        }
      int index=ArraySize(pieces);
      ArrayResize(pieces,index+1);
      pieces[index]=rest;
     }
   return(ArraySize(pieces));
  }
//+------------------------------------------------------------------+
//| The measuring engine. It keeps, for every watched closed bar and |
//| every watched buffer, the first published value and the value of |
//| the previous check, and counts every difference it ever sees.    |
//+------------------------------------------------------------------+
class CRepaintInspector
  {
private:
   //--- configuration
   string            m_indicator;         // path of the indicator under test
   string            m_title;             // indicator and parameters, for the report
   string            m_symbol;            // symbol the indicator is created on
   ENUM_TIMEFRAMES   m_timeframe;         // timeframe the indicator is created on
   int               m_digits;            // digits of the symbol, used to print deltas
   int               m_buffers;           // number of watched buffers
   int               m_bars_requested;    // number of closed bars asked for
   int               m_bars;              // number of closed bars really watched
   int               m_check_seconds;     // throttle between two checks
   double            m_tolerance;         // value changes not bigger than this are ignored
   bool              m_zero_is_empty;     // 0.0 counts as "no value"
   int               m_reload_minutes;    // period of the handle reload, 0 = never
   int               m_run_minutes;       // measuring time limit, 0 = unlimited
   //--- indicator
   int               m_handle;            // handle of the indicator under test
   MqlParam          m_params[];          // parameters used to create the handle
   bool              m_idle;              // no indicator name given: nothing is measured
   ulong             m_next_create_tick;  // earliest retry after a failed handle creation
   int               m_create_failures;   // consecutive failures, keeps the journal quiet
   //--- snapshot store, index = slot*m_buffers+buffer, slot 0 = shift 1
   datetime          m_time[];            // open time of every watched bar
   uchar             m_bar_seen[];        // 1 if the bar was already read once
   double            m_first[];           // first value ever published for the slot
   double            m_last[];            // value of the previous check
   uchar             m_touched[];         // 1 if the slot already produced an event
   double            m_snapshot[];        // values read by the current check
   bool              m_store_filled;      // the store holds a snapshot
   bool              m_allocated;         // the arrays are sized
   //--- per buffer counters
   long              m_comparisons[];     // (bar,buffer) comparisons really performed
   long              m_changed[];         // value -> different value
   long              m_appeared[];        // empty -> value
   long              m_vanished[];        // value -> empty
   long              m_bars_touched[];    // distinct bars with at least one event
   long              m_changed_reload[];  // changes on the first check after a reload
   long              m_appeared_reload[]; // appearances on the first check after a reload
   long              m_vanished_reload[]; // disappearances on the first check after a reload
   int               m_max_shift[];       // biggest shift an event was ever seen at
   datetime          m_max_shift_time[];  // bar of the biggest shift
   ENUM_RI_EVENT     m_max_shift_event[]; // event kind of the biggest shift
   double            m_max_delta[];       // biggest |value - first value|
   datetime          m_max_delta_time[];  // bar of the biggest drift
   uchar             m_has_delta[];       // 1 if a drift was ever measurable
   datetime          m_first_event[];     // detection time of the first event
   datetime          m_last_event[];      // detection time of the last event
   //--- run counters
   long              m_checks;            // checks completed
   long              m_skipped;           // checks skipped because the data was not usable
   long              m_resyncs;           // snapshot stores dropped after a history change
   long              m_reloads;           // handle reloads performed
   long              m_events;            // events of every kind, all buffers
   long              m_csv_rows;          // rows written to the event CSV
   //--- state
   datetime          m_start_time;        // server time of the start
   bool              m_tester;            // the tool runs in the strategy tester
   ulong             m_start_tick;        // clock reading at the start, used for the run time
   ulong             m_last_check_tick;   // clock reading of the last check
   ulong             m_next_reload_tick;  // clock reading of the next handle reload
   ulong             m_last_summary_tick; // clock reading of the last summary refresh
   bool              m_after_reload;      // the next completed check is the first after a reload
   bool              m_finished;          // measuring stopped by the time limit
   bool              m_summary_done;      // the closing summary was printed
   int               m_errors_logged;     // copy errors already printed
   bool              m_limit_logged;      // the CSV row limit was already reported
   bool              m_flood_logged;      // the "no more single events" note was printed
   //--- csv
   bool              m_csv_enabled;       // event CSV requested
   int               m_csv_handle;        // handle of the event CSV
   string            m_csv_name;          // name of the event CSV
   string            m_summary_name;      // name of the summary CSV
   bool              m_ready;             // Init() finished, so the report arrays exist

   void              Reset(void);
   bool              ParseParameters(void);
   bool              CreateHandle(void);
   void              Allocate(void);
   void              ClearStore(const datetime &times[]);
   bool              Realign(const datetime &times[]);
   void              RegisterEvent(const int buffer,const int shift,const datetime bar_time,
                                   const datetime detect_time,const double old_value,
                                   const double new_value,const double first_value,
                                   const ENUM_RI_EVENT event_type);
   void              ReloadHandle(void);
   void              OpenCsv(void);
   void              WriteCsvRow(const datetime detect_time,const datetime bar_time,const int shift,
                                 const int buffer,const ENUM_RI_EVENT event_type,const double old_value,
                                 const double new_value,const double first_value);
   void              WriteSummaryCsv(void);
   void              PrintStartBlock(void);
   void              Finish(void);
   string            ValueText(const double value) const;
   string            DeltaText(const double value) const;
   string            TableHeader(void) const;
   string            TableRow(const int buffer) const;
   string            Verdict(const int buffer) const;

public:
                     CRepaintInspector(void);
                    ~CRepaintInspector(void);
   bool              Init(void);
   void              Deinit(void);
   void              Poll(void);
   bool              IsEmptyValue(const double value) const;
   ulong             Clock(void) const;
   void              BuildLines(string &lines[],color &header_color) const;
   void              PrintSummary(void);
  };
//+------------------------------------------------------------------+
//| Constructor: every counter starts at zero and no handle, file or |
//| memory is claimed before Init() runs.                            |
//|                                                                  |
//+------------------------------------------------------------------+
CRepaintInspector::CRepaintInspector(void) : m_indicator(""),
   m_title(""),
   m_symbol(""),
   m_timeframe(PERIOD_CURRENT),
   m_digits(2),
   m_buffers(1),
   m_bars_requested(0),
   m_bars(0),
   m_check_seconds(0),
   m_tolerance(0.0),
   m_zero_is_empty(true),
   m_reload_minutes(0),
   m_run_minutes(0),
   m_handle(INVALID_HANDLE),
   m_idle(false),
   m_next_create_tick(0),
   m_create_failures(0),
   m_store_filled(false),
   m_allocated(false),
   m_checks(0),
   m_skipped(0),
   m_resyncs(0),
   m_reloads(0),
   m_events(0),
   m_csv_rows(0),
   m_start_time(0),
   m_tester(false),
   m_start_tick(0),
   m_last_check_tick(0),
   m_next_reload_tick(0),
   m_last_summary_tick(0),
   m_after_reload(false),
   m_finished(false),
   m_summary_done(false),
   m_errors_logged(0),
   m_limit_logged(false),
   m_flood_logged(false),
   m_csv_enabled(false),
   m_csv_handle(INVALID_HANDLE),
   m_csv_name(""),
   m_summary_name(""),
   m_ready(false)
  {
  }
//+------------------------------------------------------------------+
//| Puts every counter and flag of a run back to its starting value. |
//| Changing an input reinitialises the expert without reloading the |
//| program, so this object survives with the previous run still in  |
//| it: without this the corrected run would carry the old skipped   |
//| count, never print a closing summary (m_summary_done), keep the  |
//| old store size (m_allocated) and index it with the new buffer    |
//| count. The handle and the files are released by Deinit() first.  |
//+------------------------------------------------------------------+
void CRepaintInspector::Reset(void)
  {
   m_store_filled=false;
   m_allocated=false;
   m_bars=0;
   m_checks=0;
   m_skipped=0;
   m_resyncs=0;
   m_reloads=0;
   m_events=0;
   m_csv_rows=0;
   m_after_reload=false;
   m_finished=false;
   m_summary_done=false;
   m_errors_logged=0;
   m_limit_logged=false;
   m_flood_logged=false;
   m_csv_enabled=false;
   m_csv_name="";
   m_summary_name="";
   m_create_failures=0;
   m_next_create_tick=0;
   m_ready=false;
  }
//+------------------------------------------------------------------+
//| Destructor: the handle and the files are released by Deinit(),   |
//| which is called from OnDeinit().                                 |
//|                                                                  |
//+------------------------------------------------------------------+
CRepaintInspector::~CRepaintInspector(void)
  {
  }
//+------------------------------------------------------------------+
//| Reads the inputs, parses the parameter text, opens the CSV files |
//| and creates the indicator under test. An indicator that is not   |
//| there is reported and retried, not treated as a fatal error: the |
//| tool stays attached so the path can be corrected in the inputs.  |
//+------------------------------------------------------------------+
bool CRepaintInspector::Init(void)
  {
//--- stage: a previous run can still be in this object, see Reset()
   Reset();
//--- stage: indicator name; empty means "nothing selected yet", not an error
   m_indicator=InpIndicator;
   StringTrimLeft(m_indicator);
   StringTrimRight(m_indicator);
   m_idle=(m_indicator=="");
   if(m_idle)
      Print("RepaintInspector: no indicator selected. Set \"Indicator to inspect\" to a path "
            "relative to MQL5\\Indicators without the extension, for example Examples\\ZigZag. "
            "Nothing is measured until then.");
//--- stage: symbol and timeframe
   m_symbol=(InpSymbol=="" ? _Symbol : InpSymbol);
   if(!SymbolSelect(m_symbol,true))
     {
      PrintFormat("RepaintInspector: symbol '%s' is not available, error %d",m_symbol,GetLastError());
      return(false);
     }
   m_timeframe=(InpTimeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : InpTimeframe);
   m_digits=(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS);
//--- stage: measurement settings, with the memory guard of the store
   m_buffers=InpBuffers;
   if(m_buffers<1)
      m_buffers=1;
   if(m_buffers>RI_MAX_BUFFERS)
     {
      PrintFormat("RepaintInspector: %d buffers requested, clamped to %d",InpBuffers,RI_MAX_BUFFERS);
      m_buffers=RI_MAX_BUFFERS;
     }
   m_bars_requested=InpBarsWatched;
   if(m_bars_requested<1)
      m_bars_requested=1;
   if(m_bars_requested>RI_MAX_SLOTS/m_buffers)
     {
      PrintFormat("RepaintInspector: %d bars x %d buffers exceeds the limit of %d slots, bars clamped to %d",
                  m_bars_requested,m_buffers,RI_MAX_SLOTS,RI_MAX_SLOTS/m_buffers);
      m_bars_requested=RI_MAX_SLOTS/m_buffers;
     }
   m_check_seconds=MathMax(0,InpCheckSeconds);
   m_tolerance=MathAbs(InpTolerance);
   m_zero_is_empty=InpZeroIsEmpty;
   m_reload_minutes=MathMax(0,InpReloadMinutes);
   m_run_minutes=MathMax(0,InpRunMinutes);
//--- stage: per buffer counters
   ArrayResize(m_comparisons,m_buffers);
   ArrayResize(m_changed,m_buffers);
   ArrayResize(m_appeared,m_buffers);
   ArrayResize(m_vanished,m_buffers);
   ArrayResize(m_bars_touched,m_buffers);
   ArrayResize(m_changed_reload,m_buffers);
   ArrayResize(m_appeared_reload,m_buffers);
   ArrayResize(m_vanished_reload,m_buffers);
   ArrayResize(m_max_shift,m_buffers);
   ArrayResize(m_max_shift_time,m_buffers);
   ArrayResize(m_max_shift_event,m_buffers);
   ArrayResize(m_max_delta,m_buffers);
   ArrayResize(m_max_delta_time,m_buffers);
   ArrayResize(m_has_delta,m_buffers);
   ArrayResize(m_first_event,m_buffers);
   ArrayResize(m_last_event,m_buffers);
   for(int i=0; i<m_buffers; i++)
     {
      m_comparisons[i]=0;
      m_changed[i]=0;
      m_appeared[i]=0;
      m_vanished[i]=0;
      m_bars_touched[i]=0;
      m_changed_reload[i]=0;
      m_appeared_reload[i]=0;
      m_vanished_reload[i]=0;
      m_max_shift[i]=0;
      m_max_shift_time[i]=0;
      m_max_shift_event[i]=RI_EVENT_NONE;
      m_max_delta[i]=0.0;
      m_max_delta_time[i]=0;
      m_has_delta[i]=0;
      m_first_event[i]=0;
      m_last_event[i]=0;
     }
//--- stage: parameters of the indicator under test
   if(!ParseParameters())
      return(false);
   string shown=InpParameters;
   StringTrimLeft(shown);
   StringTrimRight(shown);
   if(m_idle)
      m_title="no indicator selected - fill in \"Indicator to inspect\"";
   else
      m_title=m_indicator+" ("+(shown=="" ? "defaults" : shown)+")";
//--- stage: time keeping
   m_start_time=TimeCurrent();
   m_tester=(bool)MQLInfoInteger(MQL_TESTER);
   m_start_tick=Clock();
   m_last_check_tick=0;
   m_last_summary_tick=m_start_tick;
   m_next_reload_tick=m_start_tick+(ulong)m_reload_minutes*60000;
//--- stage: files and handle
//--- no indicator selected: no event file either, an empty CSV per attach helps nobody
   if(!m_idle)
      OpenCsv();
//--- A handle that cannot be created is reported and retried, not fatal: on a live chart the
//--- tool stays attached so the path can be corrected in the inputs. The Strategy Tester is
//--- stricter and unloads the expert on any failed IndicatorCreate(), wherever it is called
//--- from (measured: "OnInit critical error" here, "OnTester critical error" from the first
//--- check), so in the tester the indicator under test has to exist before the run starts.
   if(!m_idle && !CreateHandle())
      PrintFormat("RepaintInspector: on a live chart the tool stays attached and retries every "
                  "%d seconds, so the path can be corrected without removing it.",RI_RETRY_SECONDS);
   PrintStartBlock();
   m_ready=true;
   return(true);
  }
//+------------------------------------------------------------------+
//| Releases the handle, prints the closing summary and closes the   |
//| files. Called from OnDeinit() for every deinitialisation reason. |
//|                                                                  |
//+------------------------------------------------------------------+
void CRepaintInspector::Deinit(void)
  {
//--- Init() can return false before the per-buffer arrays exist, for example on a symbol the
//--- terminal does not have. MQL5 then still calls OnDeinit(REASON_INITFAILED), and a report
//--- built from zero-length arrays is an "array out of range" on top of the real message.
//--- Only the report is skipped; the files and the handle are still released below.
   if(m_ready)
     {
      PrintSummary();
      WriteSummaryCsv();
     }
   if(m_csv_handle!=INVALID_HANDLE)
     {
      FileClose(m_csv_handle);
      m_csv_handle=INVALID_HANDLE;
     }
   if(m_handle!=INVALID_HANDLE)
     {
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Splits the parameter text on commas and types every token by its |
//| content. The result is logged once by PrintStartBlock(), so a    |
//| list that does not match the indicator inputs stays visible.     |
//+------------------------------------------------------------------+
bool CRepaintInspector::ParseParameters(void)
  {
   ArrayResize(m_params,1);
   m_params[0].type=TYPE_STRING;
   m_params[0].string_value=m_indicator;
   m_params[0].integer_value=0;
   m_params[0].double_value=0.0;
   string body=InpParameters;
   StringTrimLeft(body);
   StringTrimRight(body);
   if(body=="")
      return(true);
   string tokens[];
   int    count=StringSplit(body,',',tokens);
   if(count<=0)
     {
      Print("RepaintInspector: the parameter text could not be split, it is ignored");
      return(true);
     }
   for(int i=0; i<count; i++)
     {
      string token=tokens[i];
      StringTrimLeft(token);
      StringTrimRight(token);
      int index=ArraySize(m_params);
      ArrayResize(m_params,index+1);
      m_params[index].type=TYPE_STRING;
      m_params[index].integer_value=0;
      m_params[index].double_value=0.0;
      m_params[index].string_value="";
      int len=StringLen(token);
      //--- quoted text is always a string
      if(len>=2 && StringGetCharacter(token,0)=='"' && StringGetCharacter(token,len-1)=='"')
        {
         m_params[index].string_value=StringSubstr(token,1,len-2);
         continue;
        }
      string lower=token;
      StringToLower(lower);
      if(lower=="true" || lower=="false")
        {
         m_params[index].type=TYPE_BOOL;
         m_params[index].integer_value=(lower=="true" ? 1 : 0);
         continue;
        }
      bool is_real=false;
      if(RiIsNumeric(token,is_real))
        {
         if(is_real)
           {
            m_params[index].type=TYPE_DOUBLE;
            m_params[index].double_value=StringToDouble(token);
           }
         else
           {
            m_params[index].type=TYPE_INT;
            m_params[index].integer_value=StringToInteger(token);
           }
         continue;
        }
      m_params[index].string_value=token;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the indicator under test from the parsed parameter list. |
//| A fixed arity iCustom() call cannot be used here, because the    |
//| number of parameters is only known at run time.                  |
//+------------------------------------------------------------------+
bool CRepaintInspector::CreateHandle(void)
  {
   if(m_idle)
      return(false);
   ResetLastError();
   m_handle=IndicatorCreate(m_symbol,m_timeframe,IND_CUSTOM,ArraySize(m_params),m_params);
   if(m_handle==INVALID_HANDLE)
     {
      //--- one line per failure would flood the journal at one check per second,
      //--- and every attempt also makes the terminal log its own "cannot load" error
      if(m_create_failures==0)
         PrintFormat("RepaintInspector: indicator '%s' could not be created with %d parameter(s), error %d",
                     m_indicator,ArraySize(m_params)-1,GetLastError());
      m_create_failures++;
      m_next_create_tick=Clock()+(ulong)RI_RETRY_SECONDS*1000;
      return(false);
     }
   if(m_create_failures>0)
     {
      PrintFormat("RepaintInspector: indicator '%s' is available now, measuring starts (%d failed attempt(s))",
                  m_indicator,m_create_failures);
      m_create_failures=0;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Sizes the snapshot store once the real number of watched bars is |
//| known. All arrays are flat, index = slot*buffers+buffer, so the  |
//| memory stays one block even for 5000 bars and 32 buffers.        |
//+------------------------------------------------------------------+
void CRepaintInspector::Allocate(void)
  {
   int slots=m_bars*m_buffers;
   ArrayResize(m_time,m_bars);
   ArrayResize(m_bar_seen,m_bars);
   ArrayResize(m_first,slots);
   ArrayResize(m_last,slots);
   ArrayResize(m_touched,slots);
   ArrayResize(m_snapshot,slots);
   for(int i=0; i<m_bars; i++)
     {
      m_time[i]=0;
      m_bar_seen[i]=0;
     }
   for(int i=0; i<slots; i++)
     {
      m_first[i]=0.0;
      m_last[i]=0.0;
      m_touched[i]=0;
     }
   m_store_filled=false;
   m_allocated=true;
  }
//+------------------------------------------------------------------+
//| Drops the whole store and adopts the bar times of the current    |
//| snapshot. Nothing is compared on the check that does this, so a  |
//| history refill can never be reported as a repaint.               |
//+------------------------------------------------------------------+
void CRepaintInspector::ClearStore(const datetime &times[])
  {
   for(int i=0; i<m_bars; i++)
     {
      m_time[i]=times[i];
      m_bar_seen[i]=0;
     }
   int slots=m_bars*m_buffers;
   for(int i=0; i<slots; i++)
      m_touched[i]=0;
   m_store_filled=true;
  }
//+------------------------------------------------------------------+
//| Moves the store so that every stored value stays attached to its |
//| own bar open time. Returns false when the stored history is not  |
//| a suffix of the new one, which forces a resynchronisation.       |
//+------------------------------------------------------------------+
bool CRepaintInspector::Realign(const datetime &times[])
  {
//--- how many new bars appeared since the last check
   int shift=-1;
   for(int i=0; i<m_bars; i++)
     {
      if(times[i]==m_time[0])
        {
         shift=i;
         break;
        }
     }
   if(shift<0)
      return(false);
//--- the overlapping part must be exactly the same history
   for(int i=shift; i<m_bars; i++)
     {
      if(m_time[i-shift]!=times[i])
         return(false);
     }
   if(shift==0)
      return(true);
//--- move every stored slot "shift" places towards the past
   for(int i=m_bars-1; i>=shift; i--)
     {
      m_bar_seen[i]=m_bar_seen[i-shift];
      for(int b=0; b<m_buffers; b++)
        {
         int to=i*m_buffers+b;
         int from=(i-shift)*m_buffers+b;
         m_first[to]=m_first[from];
         m_last[to]=m_last[from];
         m_touched[to]=m_touched[from];
        }
     }
//--- the new slots were never read
   for(int i=0; i<shift; i++)
     {
      m_bar_seen[i]=0;
      for(int b=0; b<m_buffers; b++)
         m_touched[i*m_buffers+b]=0;
     }
   for(int i=0; i<m_bars; i++)
      m_time[i]=times[i];
   return(true);
  }
//+------------------------------------------------------------------+
//| A value is empty when the indicator publishes EMPTY_VALUE, an    |
//| invalid number, or - for arrow style buffers - a plain 0.0.      |
//|                                                                  |
//+------------------------------------------------------------------+
bool CRepaintInspector::IsEmptyValue(const double value) const
  {
   if(!MathIsValidNumber(value))
      return(true);
   if(value>=EMPTY_VALUE)
      return(true);
   if(m_zero_is_empty && value==0.0)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| The one clock of the tool. Every timer - the check throttle, the |
//| handle reload and the run limit - reads it, so they can never    |
//| drift apart. The strategy tester replays modelled time far       |
//| faster than the wall clock, so there the modelled time is used;  |
//| live the monotonic tick counter is used, because the server time |
//| stands still when no tick arrives.                               |
//+------------------------------------------------------------------+
ulong CRepaintInspector::Clock(void) const
  {
   if(m_tester)
      return((ulong)TimeCurrent()*1000);
   return(GetTickCount64());
  }
//+------------------------------------------------------------------+
//| One measuring cycle: throttle, read the indicator, realign the   |
//| store and compare every watched slot. Called from OnTick() and   |
//| from OnTimer(), so the tool also works on a quiet market.        |
//+------------------------------------------------------------------+
void CRepaintInspector::Poll(void)
  {
   if(m_finished || m_idle)
      return;
//--- stage: time limit of the whole run
   ulong now=Clock();
//--- the modelled time can still be unknown while OnInit() runs
   if(m_start_tick==0)
     {
      m_start_tick=now;
      m_last_summary_tick=now;
      m_next_reload_tick=now+(ulong)m_reload_minutes*60000;
     }
   if(m_run_minutes>0 && (now-m_start_tick)>=(ulong)m_run_minutes*60000)
     {
      Finish();
      return;
     }
//--- stage: scheduled handle reload
   if(m_reload_minutes>0 && now>=m_next_reload_tick)
      ReloadHandle();
//--- stage: throttle
   if(m_check_seconds>0 && m_last_check_tick>0 && (now-m_last_check_tick)<(ulong)m_check_seconds*1000)
      return;
   m_last_check_tick=now;
//--- stage: the handle must exist
   if(m_handle==INVALID_HANDLE)
     {
      if(now<m_next_create_tick || !CreateHandle())
        {
         m_skipped++;
         return;
        }
     }
//--- stage: enough history for the store
   int available=Bars(m_symbol,m_timeframe)-1;
   if(available<1)
     {
      m_skipped++;
      return;
     }
   if(!m_allocated)
     {
      m_bars=MathMin(m_bars_requested,available);
      if(m_bars<1)
        {
         m_skipped++;
         return;
        }
      Allocate();
      if(m_bars<m_bars_requested)
         PrintFormat("RepaintInspector: only %d closed bars are available, %d were requested",
                     m_bars,m_bars_requested);
     }
   if(available<m_bars)
     {
      m_skipped++;
      return;
     }
//--- stage: the indicator must be calculated over the whole window
   int calculated=BarsCalculated(m_handle);
   if(calculated<m_bars+1)
     {
      m_skipped++;
      if(m_errors_logged<RI_MAX_ERROR_LOG)
        {
         m_errors_logged++;
         PrintFormat("RepaintInspector: indicator not ready, BarsCalculated=%d, needed=%d, error %d",
                     calculated,m_bars+1,GetLastError());
        }
      return;
     }
//--- stage: read the bar times and the buffers of one and the same moment
   datetime times[];
   ArraySetAsSeries(times,true);
   ResetLastError();
   if(CopyTime(m_symbol,m_timeframe,1,m_bars,times)!=m_bars)
     {
      m_skipped++;
      return;
     }
   double values[];
   ArraySetAsSeries(values,true);
   for(int b=0; b<m_buffers; b++)
     {
      ResetLastError();
      int copied=CopyBuffer(m_handle,b,1,m_bars,values);
      if(copied!=m_bars)
        {
         m_skipped++;
         if(m_errors_logged<RI_MAX_ERROR_LOG)
           {
            m_errors_logged++;
            PrintFormat("RepaintInspector: CopyBuffer(buffer %d) returned %d instead of %d, error %d",
                        b,copied,m_bars,GetLastError());
           }
         return;
        }
      for(int i=0; i<m_bars; i++)
         m_snapshot[i*m_buffers+b]=values[i];
     }
//--- stage: discard the check if the series moved while it was read
   datetime recheck[];
   ArraySetAsSeries(recheck,true);
   if(CopyTime(m_symbol,m_timeframe,1,1,recheck)!=1 || recheck[0]!=times[0])
     {
      m_skipped++;
      return;
     }
//--- stage: keep every stored value attached to its own bar
   if(!m_store_filled)
      ClearStore(times);
   else
      if(!Realign(times))
        {
         m_resyncs++;
         PrintFormat("RepaintInspector: history changed (newest stored bar %s is gone), store reset, resync %s",
                     TimeToString(m_time[0],TIME_DATE|TIME_MINUTES),IntegerToString(m_resyncs));
         ClearStore(times);
        }
//--- stage: compare
   datetime detect=TimeCurrent();
   for(int i=0; i<m_bars; i++)
     {
      bool seen=(m_bar_seen[i]!=0);
      for(int b=0; b<m_buffers; b++)
        {
         int    slot=i*m_buffers+b;
         double current=m_snapshot[slot];
         if(!seen)
           {
            m_first[slot]=current;
            m_last[slot]=current;
            continue;
           }
         m_comparisons[b]++;
         double previous=m_last[slot];
         bool   previous_empty=IsEmptyValue(previous);
         bool   current_empty=IsEmptyValue(current);
         ENUM_RI_EVENT event_type=RI_EVENT_NONE;
         if(previous_empty && !current_empty)
            event_type=RI_EVENT_APPEARED;
         else
            if(!previous_empty && current_empty)
               event_type=RI_EVENT_VANISHED;
            else
               if(!previous_empty && !current_empty && MathAbs(current-previous)>m_tolerance)
                  event_type=RI_EVENT_CHANGED;
         m_last[slot]=current;
         if(event_type!=RI_EVENT_NONE)
            RegisterEvent(b,i+1,m_time[i],detect,previous,current,m_first[slot],event_type);
        }
      if(!seen)
         m_bar_seen[i]=1;
     }
   m_checks++;
   if(m_checks==1)
      PrintFormat("RepaintInspector: first snapshot taken, shift 1 = %s, shift %d = %s, %d buffer(s)",
                  TimeToString(times[0],TIME_DATE|TIME_MINUTES),m_bars,
                  TimeToString(times[m_bars-1],TIME_DATE|TIME_MINUTES),m_buffers);
   m_after_reload=false;
//--- stage: keep the summary file up to date while the tool runs
   if(m_csv_enabled && (now-m_last_summary_tick)>=(ulong)RI_SUMMARY_SECONDS*1000)
     {
      m_last_summary_tick=now;
      WriteSummaryCsv();
     }
  }
//+------------------------------------------------------------------+
//| Books one event: counters, biggest shift, biggest drift, journal |
//| line and CSV row. Every counter of the report is written here    |
//| and nowhere else, so the numbers cannot drift apart.             |
//+------------------------------------------------------------------+
void CRepaintInspector::RegisterEvent(const int buffer,const int shift,const datetime bar_time,
                                      const datetime detect_time,const double old_value,
                                      const double new_value,const double first_value,
                                      const ENUM_RI_EVENT event_type)
  {
   switch(event_type)
     {
      case RI_EVENT_CHANGED :
         m_changed[buffer]++;
         if(m_after_reload)
            m_changed_reload[buffer]++;
         break;
      case RI_EVENT_APPEARED :
         m_appeared[buffer]++;
         if(m_after_reload)
            m_appeared_reload[buffer]++;
         break;
      case RI_EVENT_VANISHED :
         m_vanished[buffer]++;
         if(m_after_reload)
            m_vanished_reload[buffer]++;
         break;
      default :
         return;
     }
//--- distinct bars
   int slot=(shift-1)*m_buffers+buffer;
   if(m_touched[slot]==0)
     {
      m_touched[slot]=1;
      m_bars_touched[buffer]++;
     }
//--- the headline number: how far back a value can still move
   if(shift>m_max_shift[buffer])
     {
      m_max_shift[buffer]=shift;
      m_max_shift_time[buffer]=bar_time;
      m_max_shift_event[buffer]=event_type;
     }
//--- drift away from the value that was published first
   if(!IsEmptyValue(first_value) && !IsEmptyValue(new_value))
     {
      double drift=MathAbs(new_value-first_value);
      if(m_has_delta[buffer]==0 || drift>m_max_delta[buffer])
        {
         m_has_delta[buffer]=1;
         m_max_delta[buffer]=drift;
         m_max_delta_time[buffer]=bar_time;
        }
     }
   if(m_first_event[buffer]==0)
      m_first_event[buffer]=detect_time;
   m_last_event[buffer]=detect_time;
   m_events++;
//--- journal, but only the first events, the rest is counted
   if(m_events<=RI_MAX_EVENT_LOG)
      PrintFormat("RepaintInspector: %s buffer %d shift %d bar %s   %s -> %s",
                  RiEventName(event_type),buffer,shift,TimeToString(bar_time,TIME_DATE|TIME_MINUTES),
                  ValueText(old_value),ValueText(new_value));
   else
      if(!m_flood_logged)
        {
         m_flood_logged=true;
         PrintFormat("RepaintInspector: more than %d events, further events are only counted (see the CSV)",
                     RI_MAX_EVENT_LOG);
        }
   WriteCsvRow(detect_time,bar_time,shift,buffer,event_type,old_value,new_value,first_value);
  }
//+------------------------------------------------------------------+
//| Releases the handle and creates it again with the same           |
//| parameters. The store is deliberately kept: an indicator that    |
//| publishes a different history after a reload must be caught.     |
//+------------------------------------------------------------------+
void CRepaintInspector::ReloadHandle(void)
  {
   m_next_reload_tick=Clock()+(ulong)m_reload_minutes*60000;
//--- nothing to reload while the indicator has never been created: counting those attempts as
//--- handle reloads, and logging one failure per period, would report work that never happened.
//--- Poll() keeps retrying the creation itself, under its own backoff.
   if(m_handle==INVALID_HANDLE)
      return;
   IndicatorRelease(m_handle);
   m_handle=INVALID_HANDLE;
   m_reloads++;
   m_after_reload=true;
   if(CreateHandle())
      PrintFormat("RepaintInspector: handle reload %s done, the snapshots are kept",IntegerToString(m_reloads));
   else
      PrintFormat("RepaintInspector: handle reload %s failed, it is retried in %d seconds",
                  IntegerToString(m_reloads),RI_RETRY_SECONDS);
  }
//+------------------------------------------------------------------+
//| Builds the file names and opens the event CSV with its header    |
//| row. Every row is flushed at once, so the measurement survives   |
//| a terminal that is killed while the tool runs.                   |
//+------------------------------------------------------------------+
void CRepaintInspector::OpenCsv(void)
  {
   m_csv_enabled=InpCsv;
   if(!m_csv_enabled)
      return;
   string name=InpCsvName;
   StringTrimLeft(name);
   StringTrimRight(name);
   bool automatic=(name=="");
   if(automatic)
     {
      MqlDateTime stamp;
      TimeToStruct(m_start_time,stamp);
      name=StringFormat("RepaintInspector_%s_%s_%04d%02d%02d_%02d%02d.csv",RiSafeName(m_symbol),
                        RiTimeframeName(m_timeframe),stamp.year,stamp.mon,stamp.day,stamp.hour,stamp.min);
     }
   m_csv_name=RiSafeName(name);
   ResetLastError();
   m_csv_handle=FileOpen(m_csv_name,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ,';');
//--- the file is shared for reading, so the rows can be watched while the tool runs;
//    two copies started in the same minute must not fight for the same file
   if(m_csv_handle==INVALID_HANDLE && automatic)
     {
      string stem=m_csv_name;
      int    tail=StringFind(stem,".csv");
      if(tail>=0 && tail==StringLen(stem)-4)
         stem=StringSubstr(stem,0,tail);
      for(int copy=2; copy<=99 && m_csv_handle==INVALID_HANDLE; copy++)
        {
         m_csv_name=stem+"_"+IntegerToString(copy)+".csv";
         ResetLastError();
         m_csv_handle=FileOpen(m_csv_name,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ,';');
        }
     }
   if(m_csv_handle==INVALID_HANDLE)
     {
      PrintFormat("RepaintInspector: CSV file '%s' could not be opened, error %d",m_csv_name,GetLastError());
      m_csv_enabled=false;
      return;
     }
//--- the summary goes into its own file, so no log has to be parsed
   string base=m_csv_name;
   int    dot=StringFind(base,".csv");
   if(dot>=0 && dot==StringLen(base)-4)
      base=StringSubstr(base,0,dot);
   m_summary_name=base+"_summary.csv";
   FileWrite(m_csv_handle,"detect_time","bar_time","shift_at_detect","buffer","event",
             "old_value","new_value","delta","drift_from_first","after_reload");
   FileFlush(m_csv_handle);
  }
//+------------------------------------------------------------------+
//| Writes one event row and flushes it. Empty values are written as |
//| EMPTY and undefined differences are left blank, so no reader can |
//| mistake a missing number for a zero.                             |
//+------------------------------------------------------------------+
void CRepaintInspector::WriteCsvRow(const datetime detect_time,const datetime bar_time,const int shift,
                                    const int buffer,const ENUM_RI_EVENT event_type,const double old_value,
                                    const double new_value,const double first_value)
  {
   if(!m_csv_enabled || m_csv_handle==INVALID_HANDLE)
      return;
   if(m_csv_rows>=(long)InpCsvMaxRows)
     {
      if(!m_limit_logged)
        {
         m_limit_logged=true;
         PrintFormat("RepaintInspector: CSV row limit of %d reached, further events are only counted",
                     InpCsvMaxRows);
        }
      return;
     }
   string delta="";
   if(!IsEmptyValue(old_value) && !IsEmptyValue(new_value))
      delta=DoubleToString(new_value-old_value,8);
   string drift="";
   if(!IsEmptyValue(first_value) && !IsEmptyValue(new_value))
      drift=DoubleToString(new_value-first_value,8);
   FileWrite(m_csv_handle,
             TimeToString(detect_time,TIME_DATE|TIME_SECONDS),
             TimeToString(bar_time,TIME_DATE|TIME_SECONDS),
             IntegerToString(shift),
             IntegerToString(buffer),
             RiEventName(event_type),
             ValueText(old_value),
             ValueText(new_value),
             delta,
             drift,
             (m_after_reload ? "1" : "0"));
   FileFlush(m_csv_handle);
   m_csv_rows++;
  }
//+------------------------------------------------------------------+
//| Rewrites the summary CSV, one row per watched buffer plus the    |
//| counters of the run. The file is refreshed while the tool runs,  |
//| so the numbers can be read without stopping the measurement.     |
//+------------------------------------------------------------------+
void CRepaintInspector::WriteSummaryCsv(void)
  {
   if(!m_csv_enabled || m_summary_name=="")
      return;
   int file=FileOpen(m_summary_name,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ,';');
   if(file==INVALID_HANDLE)
     {
      PrintFormat("RepaintInspector: summary file '%s' could not be written, error %d",
                  m_summary_name,GetLastError());
      return;
     }
   FileWrite(file,"buffer","verdict","comparisons","changed","appeared","vanished","bars_touched",
             "max_shift","max_shift_bar_time","max_shift_event","max_abs_delta","max_delta_bar_time",
             "first_event_time","last_event_time","changed_after_reload","appeared_after_reload",
             "vanished_after_reload","checks","skipped_checks","resyncs","handle_reloads",
             "run_seconds","event_rows","indicator","parameters","symbol","timeframe","bars_watched");
   long run_seconds=(long)((Clock()-m_start_tick)/1000);
   for(int b=0; b<m_buffers; b++)
     {
      FileWrite(file,
                IntegerToString(b),
                Verdict(b),
                IntegerToString(m_comparisons[b]),
                IntegerToString(m_changed[b]),
                IntegerToString(m_appeared[b]),
                IntegerToString(m_vanished[b]),
                IntegerToString(m_bars_touched[b]),
                (m_max_shift[b]>0 ? IntegerToString(m_max_shift[b]) : ""),
                (m_max_shift[b]>0 ? TimeToString(m_max_shift_time[b],TIME_DATE|TIME_SECONDS) : ""),
                (m_max_shift[b]>0 ? RiEventName(m_max_shift_event[b]) : ""),
                (m_has_delta[b]!=0 ? DoubleToString(m_max_delta[b],8) : ""),
                (m_has_delta[b]!=0 ? TimeToString(m_max_delta_time[b],TIME_DATE|TIME_SECONDS) : ""),
                (m_first_event[b]>0 ? TimeToString(m_first_event[b],TIME_DATE|TIME_SECONDS) : ""),
                (m_last_event[b]>0 ? TimeToString(m_last_event[b],TIME_DATE|TIME_SECONDS) : ""),
                IntegerToString(m_changed_reload[b]),
                IntegerToString(m_appeared_reload[b]),
                IntegerToString(m_vanished_reload[b]),
                IntegerToString(m_checks),
                IntegerToString(m_skipped),
                IntegerToString(m_resyncs),
                IntegerToString(m_reloads),
                IntegerToString(run_seconds),
                IntegerToString(m_csv_rows),
                m_indicator,
                InpParameters,
                m_symbol,
                RiTimeframeName(m_timeframe),
                IntegerToString(m_bars));
     }
   FileClose(file);
  }
//+------------------------------------------------------------------+
//| Prints the settings of the run, including every parsed parameter |
//| with its type, so that a list that does not match the indicator  |
//| inputs can be spotted in the journal.                            |
//+------------------------------------------------------------------+
void CRepaintInspector::PrintStartBlock(void)
  {
   Print("=== Repaint Inspector =============================================");
   PrintFormat("indicator      : %s",(m_idle ? "none selected, nothing is measured" : m_indicator));
   PrintFormat("symbol / tf    : %s %s",m_symbol,RiTimeframeName(m_timeframe));
   PrintFormat("watched        : %d buffer(s), closed bars shift 1..%d",m_buffers,m_bars_requested);
   PrintFormat("check interval : %d s   tolerance %s   zero is empty %s",
               m_check_seconds,DoubleToString(m_tolerance,8),(m_zero_is_empty ? "yes" : "no"));
   PrintFormat("handle reload  : %s      run limit %s",
               (m_reload_minutes>0 ? IntegerToString(m_reload_minutes)+" min" : "never"),
               (m_run_minutes>0 ? IntegerToString(m_run_minutes)+" min" : "none"));
   int count=ArraySize(m_params)-1;
   if(count<=0)
      Print("parameters     : none, the indicator defaults are used");
   for(int i=1; i<=count; i++)
     {
      switch(m_params[i].type)
        {
         case TYPE_BOOL :
            PrintFormat("parameter %d: bool %s",i,(m_params[i].integer_value!=0 ? "true" : "false"));
            break;
         case TYPE_INT :
            PrintFormat("parameter %d: int %s",i,IntegerToString(m_params[i].integer_value));
            break;
         case TYPE_DOUBLE :
            PrintFormat("parameter %d: double %s",i,DoubleToString(m_params[i].double_value,8));
            break;
         default :
            PrintFormat("parameter %d: string %s",i,m_params[i].string_value);
            break;
        }
     }
   if(m_csv_enabled)
     {
      PrintFormat("csv            : %s",m_csv_name);
      PrintFormat("summary csv    : %s",m_summary_name);
     }
   else
      Print("csv            : "+(m_idle ? "off, no indicator selected" : "off"));
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Stops the measurement after the requested number of minutes. The |
//| panel keeps the final numbers on the chart and the summary files |
//| are written, but nothing is measured any more.                   |
//+------------------------------------------------------------------+
void CRepaintInspector::Finish(void)
  {
   if(m_finished)
      return;
   m_finished=true;
   PrintFormat("RepaintInspector: measuring stopped after %d minute(s) as configured",m_run_minutes);
   PrintSummary();
   WriteSummaryCsv();
   if(m_csv_handle!=INVALID_HANDLE)
     {
      FileClose(m_csv_handle);
      m_csv_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Text of a single buffer value for the journal and the CSV.       |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
string CRepaintInspector::ValueText(const double value) const
  {
   if(IsEmptyValue(value))
      return("EMPTY");
   return(DoubleToString(value,8));
  }
//+------------------------------------------------------------------+
//| Text of a drift for the panel. The panel shows the digits of the |
//| symbol plus two, the summary CSV keeps the full precision.       |
//|                                                                  |
//+------------------------------------------------------------------+
string CRepaintInspector::DeltaText(const double value) const
  {
   return(DoubleToString(value,MathMin(8,m_digits+2)));
  }
//+------------------------------------------------------------------+
//| Verdict of one buffer. A verdict is never given without the      |
//| number of comparisons that produced it.                          |
//|                                                                  |
//+------------------------------------------------------------------+
string CRepaintInspector::Verdict(const int buffer) const
  {
   if(m_comparisons[buffer]<=0)
      return("NO DATA");
   if(m_changed[buffer]+m_appeared[buffer]+m_vanished[buffer]==0)
      return("STABLE");
   return("REPAINTS");
  }
//+------------------------------------------------------------------+
//| Header of the report table, used by the panel and by the journal |
//| summary, so that both really show the same columns.              |
//|                                                                  |
//+------------------------------------------------------------------+
string CRepaintInspector::TableHeader(void) const
  {
   return(RiPadLeft("Buf",RI_W_BUF)+"  "+RiPadRight("Verdict",RI_W_VERDICT)+"  "+
          RiPadLeft("Comparisons",RI_W_COMP)+"  "+RiPadLeft("Changed",RI_W_EVENT)+"  "+
          RiPadLeft("Appeared",RI_W_EVENT)+"  "+RiPadLeft("Vanished",RI_W_EVENT)+
          CharToString(RI_COL_BREAK)+"  "+
          RiPadLeft("MaxShift",RI_W_SHIFT)+"  "+RiPadLeft("Max |delta|",RI_W_DELTA));
  }
//+------------------------------------------------------------------+
//| One report row. A dash means "not applicable": the buffer has    |
//| not produced a single event yet, so there is no shift and no     |
//| drift to report.                                                 |
//+------------------------------------------------------------------+
string CRepaintInspector::TableRow(const int buffer) const
  {
   string shift=(m_max_shift[buffer]>0 ? IntegerToString(m_max_shift[buffer]) : "-");
   string delta=(m_has_delta[buffer]!=0 ? DeltaText(m_max_delta[buffer]) : "-");
   return(RiPadLeft(IntegerToString(buffer),RI_W_BUF)+"  "+RiPadRight(Verdict(buffer),RI_W_VERDICT)+"  "+
          RiPadLeft(RiFormatCount(m_comparisons[buffer]),RI_W_COMP)+"  "+
          RiPadLeft(RiFormatCount(m_changed[buffer]),RI_W_EVENT)+"  "+
          RiPadLeft(RiFormatCount(m_appeared[buffer]),RI_W_EVENT)+"  "+
          RiPadLeft(RiFormatCount(m_vanished[buffer]),RI_W_EVENT)+
          CharToString(RI_COL_BREAK)+"  "+
          RiPadLeft(shift,RI_W_SHIFT)+"  "+RiPadLeft(delta,RI_W_DELTA));
  }
//+------------------------------------------------------------------+
//| Builds the text of the whole report. The same lines are drawn on |
//| the panel and printed into the journal summary, so the published |
//| screenshot and the published log can never disagree.             |
//+------------------------------------------------------------------+
void CRepaintInspector::BuildLines(string &lines[],color &header_color) const
  {
   int count=5+m_buffers;
   ArrayResize(lines,count);
   long run_seconds=(long)((Clock()-m_start_tick)/1000);
   lines[0]="Repaint Inspector   "+m_title;
   if(!m_idle && m_handle==INVALID_HANDLE)
      lines[0]=lines[0]+"   [not loaded, retrying]";
   lines[1]=StringFormat("%s %s   %d closed bars watched%s   running %s%s",
                         m_symbol,RiTimeframeName(m_timeframe),
                         (m_allocated ? m_bars : m_bars_requested),CharToString(RI_COL_BREAK),
                         RiDuration(run_seconds),(m_finished ? "   [stopped]" : ""));
   lines[2]="checks "+RiFormatCount(m_checks)+"   skipped "+RiFormatCount(m_skipped)+
            "   resyncs "+RiFormatCount(m_resyncs)+"   handle reloads "+RiFormatCount(m_reloads);
   lines[3]=TableHeader();
   for(int b=0; b<m_buffers; b++)
      lines[4+b]=TableRow(b);
   if(m_csv_enabled)
      lines[count-1]="CSV: "+m_csv_name+" ("+RiFormatCount(m_csv_rows)+" rows)";
   else
      lines[count-1]="CSV: off";
//--- colour of the header line
   bool repaints=false;
   bool stable=false;
   for(int b=0; b<m_buffers; b++)
     {
      string verdict=Verdict(b);
      if(verdict=="REPAINTS")
         repaints=true;
      if(verdict=="STABLE")
         stable=true;
     }
   if(repaints)
      header_color=InpRepaintColor;
   else
      header_color=(stable ? InpStableColor : InpTextColor);
  }
//+------------------------------------------------------------------+
//| Prints the closing summary. It repeats the panel table line by   |
//| line and adds the details that do not fit on the chart, so the   |
//| block can be pasted into an article without editing.             |
//+------------------------------------------------------------------+
void CRepaintInspector::PrintSummary(void)
  {
   if(m_summary_done)
      return;
   m_summary_done=true;
   string lines[];
   color  header=InpTextColor;
   BuildLines(lines,header);
   Print("=== Repaint Inspector summary =====================================");
   for(int i=0; i<ArraySize(lines); i++)
     {
      string line=lines[i];
      StringReplace(line,CharToString(RI_COL_BREAK),"");
      Print(line);
     }
   PrintFormat("started %s server time, %s checks, %s skipped, %s resyncs, %s handle reloads",
               TimeToString(m_start_time,TIME_DATE|TIME_SECONDS),IntegerToString(m_checks),
               IntegerToString(m_skipped),IntegerToString(m_resyncs),IntegerToString(m_reloads));
   long total=0;
   for(int b=0; b<m_buffers; b++)
      total+=m_changed[b]+m_appeared[b]+m_vanished[b];
   PrintFormat("events total %s, CSV rows %s",IntegerToString(total),IntegerToString(m_csv_rows));
   for(int b=0; b<m_buffers; b++)
     {
      PrintFormat("buffer %d: %s, comparisons %s, changed %s, appeared %s, vanished %s, bars touched %s",
                  b,Verdict(b),IntegerToString(m_comparisons[b]),IntegerToString(m_changed[b]),
                  IntegerToString(m_appeared[b]),IntegerToString(m_vanished[b]),
                  IntegerToString(m_bars_touched[b]));
      if(m_max_shift[b]>0)
         PrintFormat("buffer %d: max shift %d (%s on bar %s)",b,m_max_shift[b],
                     RiEventName(m_max_shift_event[b]),TimeToString(m_max_shift_time[b],TIME_DATE|TIME_MINUTES));
      else
         PrintFormat("buffer %d: max shift none",b);
      if(m_has_delta[b]!=0)
         PrintFormat("buffer %d: max |delta| %s (bar %s)",b,DoubleToString(m_max_delta[b],8),
                     TimeToString(m_max_delta_time[b],TIME_DATE|TIME_MINUTES));
      else
         PrintFormat("buffer %d: max |delta| none",b);
      if(m_first_event[b]>0)
         PrintFormat("buffer %d: first event %s, last event %s",b,
                     TimeToString(m_first_event[b],TIME_DATE|TIME_SECONDS),
                     TimeToString(m_last_event[b],TIME_DATE|TIME_SECONDS));
      if(m_reloads>0)
         PrintFormat("buffer %d: after reload changed %s, appeared %s, vanished %s",b,
                     IntegerToString(m_changed_reload[b]),IntegerToString(m_appeared_reload[b]),
                     IntegerToString(m_vanished_reload[b]));
     }
   Print("===================================================================");
  }
//--- global objects of the expert
CRepaintInspector ExtInspector;
CRepaintPanel     ExtPanel;
bool              ExtPanelOn=false;
//+------------------------------------------------------------------+
//| Redraws the panel with the current numbers of the inspector.     |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
void RiUpdatePanel(void)
  {
   if(!ExtPanelOn)
      return;
   string lines[];
   color  header=InpTextColor;
   ExtInspector.BuildLines(lines,header);
   ExtPanel.Update(lines,header);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(!ExtInspector.Init())
      return(INIT_FAILED);
   if(InpShowPanel)
      ExtPanelOn=ExtPanel.Create();
   EventSetTimer(1);
   RiUpdatePanel();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ExtInspector.Deinit();
   ExtPanel.Destroy();
   PrintFormat("RepaintInspector: stopped, deinitialisation reason %d",reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   ExtInspector.Poll();
  }
//+------------------------------------------------------------------+
//| Timer function: keeps the tool measuring and the panel alive     |
//| when no tick arrives, for example over a weekend.                |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   ExtInspector.Poll();
   RiUpdatePanel();
  }
//+------------------------------------------------------------------+
