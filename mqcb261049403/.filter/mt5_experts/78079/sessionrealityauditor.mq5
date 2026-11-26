//+------------------------------------------------------------------+
//|                                        SessionRealityAuditor.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Audits the broker's quote and trade session tables against the M1"
#property description "history: minute by minute, when does a symbol really quote over the"
#property description "last weeks? Dead declared minutes, bars outside the table, trade"
#property description "against quote table, one-off outages and the effective table."
#property description "Read only measuring tool - it never calls a trade function."
//--- limits and behaviour constants
#define SRA_NAME          "SessionRealityAuditor"   // program name used in every journal line
#define SRA_TITLE         "Session Reality Auditor" // title of the journal block and of the panel
#define SRA_FOLDER        "SessionRealityAuditor"   // sub folder of MQL5\Files holding the CSV files
#define SRA_MAX_SYMBOLS   128                       // highest number of symbols one run can audit
#define SRA_MAX_DAYS      400                       // longest audit window in days
#define SRA_MAX_SESSIONS  16                        // session records read per weekday and table
#define SRA_DAY           1440                      // minutes of one day
#define SRA_CELLS         10080                     // cells of the weekly map, 7 x 1440
#define SRA_RETRIES       20                        // attempts of one bar request in a live chart
#define SRA_RETRY_MS      500                       // pause between two attempts, milliseconds
#define SRA_PANEL_ROWS    24                        // symbol rows the panel shows at most
#define SRA_WARMUP_PULSES 15                        // pulses waited for the history before auditing
#define SRA_PANEL_FONT    "Consolas"                // monospace font, the panel is a table
#define SRA_MAX_LABEL     62                        // characters one OBJ_LABEL can show
#define SRA_COLS          10                        // columns of the result table
#define SRA_SEP           ";"                       // column separator of every CSV file
//--- flags of one cell of the weekly map
#define SRA_Q             1                         // declared by the quote session table
#define SRA_T             2                         // declared by the trade session table
#define SRA_LIVE          4                         // E: bars on at least InpLivePct % of the dates
#define SRA_DEAD          8                         // C1: declared, bars on at most InpDeadPct %
#define SRA_OUT           16                        // C2: not declared, at least one bar
#define SRA_TNQ           32                        // C3: trade session without a quote session
#define SRA_QNT           64                        // C3: quote session without a trade session
//--- colours of the panel, black on white so that a screenshot is readable
#define SRA_BACK_COLOR    clrWhite                  // panel background
#define SRA_BORDER_COLOR  clrBlack                  // panel border
#define SRA_TEXT_COLOR    clrBlack                  // panel text
//+------------------------------------------------------------------+
//| The kinds of finding, named as in the check column of the CSV    |
//+------------------------------------------------------------------+
enum ENUM_SRA_CHECK
  {
   SRA_CHECK_DEAD=0,         // C1 dead declared window
   SRA_CHECK_OUTSIDE,        // C2 bars outside the quote table
   SRA_CHECK_TRADE_NO_QUOTE, // C3 trade session without a quote session
   SRA_CHECK_QUOTE_NO_TRADE, // C3 quote session without a trade session
   SRA_CHECK_OUTAGE          // C4 one-off outage
  };
//+------------------------------------------------------------------+
//| What happened to one symbol; all but OK is one journal line      |
//+------------------------------------------------------------------+
enum ENUM_SRA_STATUS
  {
   SRA_STATUS_IDLE=0,  // not audited
   SRA_STATUS_UNKNOWN, // the terminal does not know this symbol
   SRA_STATUS_NO_BARS, // the symbol has no M1 bar
   SRA_STATUS_NO_READ, // the M1 bars of the window could not be read
   SRA_STATUS_EMPTY,   // the window holds no whole day or no bar
   SRA_STATUS_OK       // audited
  };
//--- input parameters
input string           InpSymbols        = "";                // Symbols: empty = chart symbol, * = Market Watch, else CSV list
input int              InpDays           = 28;                // Whole server days of M1 history to audit (ending before today)
input int              InpLivePct        = 50;                // A minute is real when bars exist on at least this % of its weekdays
input int              InpDeadPct        = 25;                // A declared minute is dead when bars exist on at most this % of them
input int              InpOutageMinutes  = 5;                 // Report one-off gaps in normally live declared minutes from this length
input bool             InpCheckTrade     = true;              // Compare the trade session table with the quote session table
input int              InpMaxExamples    = 5;                 // Journal: outages printed per symbol
input bool             InpWriteCsv       = true;              // Write summary, sessions, map, effective and findings CSV files
input bool             InpShowPanel      = true;              // Draw the result table on the chart
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel corner
input int              InpPanelFontSize  = 8;                 // Panel font size
input int              InpPanelX         = 10;                // Panel X offset, px
input int              InpPanelY         = 18;                // Panel Y offset, px
input int              InpRefreshMinutes = 0;                 // Re-audit every N minutes (0 = audit once)
//--- the inputs as they are used, after the out of range values were clamped
int ExtDays=28;                                    // whole days of the audit window
int ExtLivePct=50;                                 // live threshold in percent
int ExtDeadPct=25;                                 // dead threshold in percent
int ExtOutageMinutes=5;                            // shortest outage in minutes
int ExtMaxExamples=5;                              // outages printed per symbol
//--- names of the checks as written into the check column of the CSV,
//    in the order of ENUM_SRA_CHECK, and the names of the symbol states
string ExtCheckNames[5]= {"dead","outside","trade_no_quote","quote_no_trade","outage"};
string ExtStatusNames[6]= {"IDLE","UNKNOWN","NO_BARS","NO_READ","EMPTY","OK"};
//+------------------------------------------------------------------+
//| Now: server time, the one clock the tester also has              |
//+------------------------------------------------------------------+
datetime SraNow(void)
  {
   return(TimeCurrent());
  }
//+------------------------------------------------------------------+
//| Text padded to a width, right aligned for numbers, never cut     |
//+------------------------------------------------------------------+
string SraPad(const string text,const int width,const bool right)
  {
   string out=text;
   while(StringLen(out)<width)
      out=(right ? " "+out : out+" ");
   return(out);
  }
//+------------------------------------------------------------------+
//| A symbol name made safe for a file name, e.g. US30.cash          |
//+------------------------------------------------------------------+
string SraSafeName(const string text)
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
//| A 64 bit counter as text, so no format string meets a long       |
//+------------------------------------------------------------------+
string SraNum(const long value)
  {
   return(IntegerToString(value));
  }
//+------------------------------------------------------------------+
//| A CSV cell: empty when not measured, a zero would look clean     |
//+------------------------------------------------------------------+
string SraCell(const bool measured,const string text)
  {
   return(measured ? text : "");
  }
//+------------------------------------------------------------------+
//| A figure for humans: a dash when not measured, never a number    |
//+------------------------------------------------------------------+
string SraText(const bool measured,const string text)
  {
   return(measured ? text : "-");
  }
//+------------------------------------------------------------------+
//| Minute of the day as HH:MM, 1440 prints as the exclusive 24:00   |
//+------------------------------------------------------------------+
string SraClock(const int minute)
  {
   return(StringFormat("%02d:%02d",minute/60,minute%60));
  }
//+------------------------------------------------------------------+
//| Server time as yyyy.mm.dd HH:MM                                  |
//+------------------------------------------------------------------+
string SraDate(const long moment)
  {
   return(TimeToString((datetime)moment,TIME_DATE|TIME_MINUTES));
  }
//+------------------------------------------------------------------+
//| Weekday of a server time, Sunday = 0: ((t / 86400) + 4) % 7      |
//+------------------------------------------------------------------+
int SraWeekday(const long moment)
  {
   return((int)((moment/86400+4)%7));
  }
//+------------------------------------------------------------------+
//| Three letter name of a weekday, Sunday = 0                       |
//+------------------------------------------------------------------+
string SraDayName(const int weekday)
  {
   return(StringSubstr("SunMonTueWedThuFriSat",weekday*3,3));
  }
//+------------------------------------------------------------------+
//| Minutes per week as hours with two decimals                      |
//+------------------------------------------------------------------+
string SraHours(const long minutes)
  {
   return(DoubleToString(minutes/60.0,2));
  }
//+------------------------------------------------------------------+
//| Appends one line to a list of journal lines                      |
//+------------------------------------------------------------------+
void SraAdd(string &lines[],const string text)
  {
   int count=ArraySize(lines);
   ArrayResize(lines,count+1,32);
   lines[count]=text;
  }
//+------------------------------------------------------------------+
//| Width of every table column, shared by the panel and the journal |
//+------------------------------------------------------------------+
void SraColumnWidths(const string &cells[][SRA_COLS],const int rows,int &widths[])
  {
   for(int c=0; c<SRA_COLS; c++)
     {
      widths[c]=0;
      for(int r=0; r<rows; r++)
         widths[c]=MathMax(widths[c],StringLen(cells[r][c]));
     }
  }
//+------------------------------------------------------------------+
//| One table row as one journal line, numbers right aligned         |
//+------------------------------------------------------------------+
string SraRowText(const string &cells[][SRA_COLS],const int row,const int &widths[])
  {
   string out="";
   for(int c=0; c<SRA_COLS; c++)
      out+=(c>0 ? "  " : "")+SraPad(cells[row][c],widths[c],c>0);
   return(out);
  }
//+------------------------------------------------------------------+
//| The result table on the chart, one OBJ_LABEL per column cell     |
//+------------------------------------------------------------------+
class CSraPanel
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

public:
                     CSraPanel(void) { Reset(); }
   void              Reset(void);
   bool              Create(void);
   void              Destroy(void);
   void              Update(const string &top[],const string &cells[][SRA_COLS],const int table_rows,
                            const string &bottom[]);
   int               WidthPx(void)  const { return(m_width_px);  }
   int               HeightPx(void) const { return(m_height_px); }
   int               Labels(void)   const { return(m_labels);    }
   int               Widest(void)   const { return(m_widest);    }
  };
//+------------------------------------------------------------------+
//| Back to the start: a changed input keeps the old object alive    |
//+------------------------------------------------------------------+
void CSraPanel::Reset(void)
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
bool CSraPanel::Create(void)
  {
   m_chart=ChartID();
//--- stage: the first instance index that is not used on this chart
   int instance=0;
   for(; instance<15; instance++)
      if(ObjectFind(m_chart,SRA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_bg")<0)
         break;
   m_prefix=SRA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
//--- stage: geometry, points stay points and pixels follow the screen dpi
   double scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   m_font_size  =(int)MathMin(20,MathMax(4,InpPanelFontSize));
   m_pad        =(int)MathRound(6.0*scale);
   m_line_height=(int)MathRound(m_font_size*1.70*scale);
   m_char_width =(int)MathCeil(m_font_size*0.75*scale);
   uint text_width=0,text_height=0;
   TextSetFont(SRA_PANEL_FONT,-m_font_size*10,FW_NORMAL,0);
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
      PrintFormat("%s: the panel background could not be created, error %d, panel off",SRA_NAME,GetLastError());
      return(false);
     }
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,m_x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y);
   ObjectSetInteger(m_chart,name,OBJPROP_BGCOLOR,SRA_BACK_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,SRA_BORDER_COLOR);
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
void CSraPanel::Destroy(void)
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
void CSraPanel::Place(const int row,const int column,const int start,const string text)
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
   ObjectSetString(m_chart,name,OBJPROP_FONT,SRA_PANEL_FONT);
   ObjectSetInteger(m_chart,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,SRA_TEXT_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,1);
   ObjectSetString(m_chart,name,OBJPROP_TEXT,text);
   m_labels++;
  }
//+------------------------------------------------------------------+
//| Redraws the free lines and the table, sizes the background       |
//+------------------------------------------------------------------+
void CSraPanel::Update(const string &top[],const string &cells[][SRA_COLS],const int table_rows,
                       const string &bottom[])
  {
   if(!m_created)
      return;
//--- stage: where every table column starts, in characters
   int widths[SRA_COLS];
   int starts[SRA_COLS];
   SraColumnWidths(cells,table_rows,widths);
   int table_width=0;
   for(int c=0; c<SRA_COLS; c++)
     {
      starts[c]=table_width;
      table_width+=widths[c]+(c<SRA_COLS-1 ? 2 : 0);
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
//--- stage: the labels row by row, free lines cut into label sized pieces
   int row=0;
   for(int i=0; i<top_count; i++,row++)
      for(int piece=0; piece*SRA_MAX_LABEL<StringLen(top[i]); piece++)
         Place(row,piece,piece*SRA_MAX_LABEL,StringSubstr(top[i],piece*SRA_MAX_LABEL,SRA_MAX_LABEL));
   for(int r=0; r<table_rows; r++,row++)
      for(int c=0; c<SRA_COLS; c++)
         Place(row,c,starts[c],SraPad(cells[r][c],widths[c],c>0));
   for(int i=0; i<bottom_count; i++,row++)
      for(int piece=0; piece*SRA_MAX_LABEL<StringLen(bottom[i]); piece++)
         Place(row,piece,piece*SRA_MAX_LABEL,StringSubstr(bottom[i],piece*SRA_MAX_LABEL,SRA_MAX_LABEL));
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
class CSraReport
  {
private:
   string            m_prefix;            // file name prefix of one pass
   int               m_findings_handle;   // one row per finding, one file per pass
   string            m_findings_name;     // path of the findings file
   long              m_rows;              // findings rows written to the file
   int               m_files;             // per symbol files written in this pass

   void              DropEarlierFiles(void);

public:
                     CSraReport(void) : m_findings_handle(INVALID_HANDLE) { Reset(); }
   void              Reset(void);
   void              Open(const string prefix);
   void              Close(void);
   long              WriteFindings(const string &rows[],const int count);
   bool              WriteTable(const string symbol,const string kind,const string header,const string &rows[],
                                const int count);
   void              Journal(const string &lines[]) const;
   bool              FindingsOn(void)   const { return(m_findings_handle!=INVALID_HANDLE); }
   long              Rows(void)         const { return(m_rows);          }
   int               Files(void)        const { return(m_files);         }
   string            FindingsName(void) const { return(m_findings_name); }
  };
//+------------------------------------------------------------------+
//| Every counter and name back to its starting value                |
//+------------------------------------------------------------------+
void CSraReport::Reset(void)
  {
   m_prefix="";
   m_findings_name="";
   m_rows=0;
   m_files=0;
  }
//+------------------------------------------------------------------+
//| Removes the files an earlier pass wrote under the same prefix    |
//+------------------------------------------------------------------+
void CSraReport::DropEarlierFiles(void)
  {
   string names[];
   string found="";
   int    count=0;
   long   search=FileFindFirst(SRA_FOLDER+"\\"+m_prefix+"_*",found);
   if(search!=INVALID_HANDLE)
     {
      do
        {
         ArrayResize(names,count+1);
         names[count++]=found;
        }
      while(FileFindNext(search,found));
      FileFindClose(search);
     }
   int removed=0;
   for(int i=0; i<count; i++)
      if(FileDelete(SRA_FOLDER+"\\"+names[i]))
         removed++;
   if(count>0)
      PrintFormat("%s: %d of %d file(s) of an earlier pass with the prefix %s were removed",SRA_NAME,removed,count,
                  m_prefix);
  }
//+------------------------------------------------------------------+
//| Opens the findings file of one pass, its prefix has the chart id |
//+------------------------------------------------------------------+
void CSraReport::Open(const string prefix)
  {
   m_prefix=prefix;
   if(!InpWriteCsv)
      return;
   DropEarlierFiles();
   m_findings_name=SRA_FOLDER+"\\"+prefix+"_findings.csv";
   ResetLastError();
   m_findings_handle=FileOpen(m_findings_name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(m_findings_handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",SRA_NAME,m_findings_name,
                  GetLastError());
      m_findings_name="";
      return;
     }
   FileWriteString(m_findings_handle,"symbol;check;weekday;start;end;minutes;value;detail\r\n");
  }
//+------------------------------------------------------------------+
//| Closes the findings file, it may be called twice without harm    |
//+------------------------------------------------------------------+
void CSraReport::Close(void)
  {
   if(m_findings_handle!=INVALID_HANDLE)
     {
      FileClose(m_findings_handle);
      m_findings_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Writes the findings rows of one symbol, returns the rows written |
//+------------------------------------------------------------------+
long CSraReport::WriteFindings(const string &rows[],const int count)
  {
   if(m_findings_handle==INVALID_HANDLE)
      return(0);
   long written=0;
   for(int i=0; i<count; i++)
      if(FileWriteString(m_findings_handle,rows[i]+"\r\n")>0)
         written++;
   FileFlush(m_findings_handle);
   m_rows+=written;
   return(written);
  }
//+------------------------------------------------------------------+
//| Writes one per symbol file; a failure costs this file alone      |
//+------------------------------------------------------------------+
bool CSraReport::WriteTable(const string symbol,const string kind,const string header,const string &rows[],
                            const int count)
  {
   if(!InpWriteCsv)
      return(false);
   string name=SRA_FOLDER+"\\"+m_prefix+"_"+SraSafeName(symbol)+"_"+kind+".csv";
   ResetLastError();
   int handle=FileOpen(name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",SRA_NAME,name,GetLastError());
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
//| Prints the journal block of one symbol, line by line             |
//+------------------------------------------------------------------+
void CSraReport::Journal(const string &lines[]) const
  {
   int count=ArraySize(lines);
   for(int i=0; i<count; i++)
      Print(lines[i]);
  }
//+------------------------------------------------------------------+
//| One symbol: the M1 bars of [D0, D1) against both session tables  |
//+------------------------------------------------------------------+
class CSraSymbolAudit
  {
private:
   string            m_symbol;            // symbol under audit
   ENUM_SRA_STATUS   m_status;            // what happened to this symbol
   long              m_last;              // open time of the newest M1 bar
   long              m_d0;                // window start, inclusive, a day boundary
   long              m_d1;                // window end, exclusive, the day of the newest bar
   int               m_days;              // whole days of the window
   int               m_days_wd[7];        // calendar dates per weekday, 0 = Sunday
   long              m_bars;              // distinct M1 bars inside the window
   int               m_retries;           // repeated bar requests
   int               m_read_error;        // error of the request that failed
   //--- session tables, kind 0 = quote, 1 = trade
   int               m_sess_from[2][7*SRA_MAX_SESSIONS]; // session start, seconds of the day
   int               m_sess_to[2][7*SRA_MAX_SESSIONS];   // session end, seconds of the day
   int               m_sess_count[2][7];  // sessions per table and weekday
   int               m_sess_total[2];     // session records per table
   //--- the weekly map, cell = weekday x 1440 + minute of the day
   int               m_hits[SRA_CELLS];   // dates of the weekday with a bar at the minute
   uchar             m_cell[SRA_CELLS];   // SRA_Q ... SRA_QNT flags of the cell
   uchar             m_has[];             // one per minute of the window, 1 = a bar exists
   //--- counters of the checks
   long              m_decl_quote;        // cells declared by the quote table
   long              m_decl_trade;        // cells declared by the trade table
   long              m_effective;         // E: live cells
   long              m_dead_min;          // C1: dead cells
   long              m_dead_win;          // C1: dead windows
   long              m_out_min;           // C2: undeclared cells with bars
   long              m_out_bars;          // C2: bars in those cells
   long              m_out_win;           // C2: windows
   long              m_tnq_min;           // C3: trade without quote cells
   long              m_tnq_win;           // C3: trade without quote windows
   long              m_qnt_min;           // C3: quote without trade cells
   long              m_qnt_win;           // C3: quote without trade windows
   long              m_outages;           // C4: outages
   long              m_outage_min;        // C4: minutes of all outages
   long              m_outage_max;        // C4: longest outage in minutes
   long              m_outage_max_start;  // C4: first minute of the longest outage, 0 = none
   long              m_outage_start[];    // first minute of every outage
   long              m_outage_len[];      // length of every outage in minutes
   int               m_worst_wd;          // weekday of the longest dead window, -1 = none
   int               m_worst_from;        // its first minute
   int               m_worst_to;          // its end minute, exclusive
   //--- findings
   string            m_rows[];            // findings rows of this symbol
   long              m_findings;          // findings_rows, one per row produced
   long              m_rows_written;      // rows the findings file received

   bool              QuoteOn(void) const { return(m_sess_total[0]>0); }
   bool              TradeOn(void) const { return(m_sess_total[1]>0); }
   bool              C3On(void)    const { return(InpCheckTrade && QuoteOn() && TradeOn()); }
   string            C3State(void) const;
   int               Fetch(const bool newest,datetime &times[]);
   void              LoadTable(const int kind);
   bool              InTable(const int kind,const int weekday,const int secs) const;
   void              Classify(void);
   int               Runs(const int flag,const int weekday,int &from[],int &to[]) const;
   void              RunHits(const int weekday,const int from,const int to,int &most,long &sum) const;
   string            RunsText(const int flag,const int weekday) const;
   void              MapFindings(const int flag,const ENUM_SRA_CHECK check);
   void              Outages(void);
   void              Found(const ENUM_SRA_CHECK check,const int weekday,const string start,const string end,
                           const long minutes,const string value,const string detail);

public:
                     CSraSymbolAudit(void) { Reset(); }
   void              Reset(void);
   void              SetSymbol(const string symbol) { Reset(); m_symbol=symbol; }
   bool              Audit(void);
   void              Commit(CSraReport &report) { m_rows_written=report.WriteFindings(m_rows,(int)m_findings); }
   void              WriteFiles(CSraReport &report) const;
   void              JournalLines(string &lines[]) const;
   void              Cells(string &cells[][SRA_COLS],const int row) const;
   static void       HeaderCells(string &cells[][SRA_COLS],const int row);
   long              Findings(void)    const { return(m_findings); }
   long              FindingsSum(void) const { return(m_dead_win+m_out_win+m_tnq_win+m_qnt_win+m_outages); }
  };
//+------------------------------------------------------------------+
//| Everything back to the start, a re-init keeps the globals (C24)  |
//+------------------------------------------------------------------+
void CSraSymbolAudit::Reset(void)
  {
   m_symbol="";
   m_status=SRA_STATUS_IDLE;
   m_last=0;
   m_d0=0;
   m_d1=0;
   m_days=0;
   ArrayInitialize(m_days_wd,0);
   m_bars=0;
   m_retries=0;
   m_read_error=0;
   ArrayInitialize(m_sess_from,0);
   ArrayInitialize(m_sess_to,0);
   ArrayInitialize(m_sess_count,0);
   ArrayInitialize(m_sess_total,0);
   ArrayInitialize(m_hits,0);
   ArrayInitialize(m_cell,0);
   ArrayFree(m_has);
   m_decl_quote=0;
   m_decl_trade=0;
   m_effective=0;
   m_dead_min=0;
   m_dead_win=0;
   m_out_min=0;
   m_out_bars=0;
   m_out_win=0;
   m_tnq_min=0;
   m_tnq_win=0;
   m_qnt_min=0;
   m_qnt_win=0;
   m_outages=0;
   m_outage_min=0;
   m_outage_max=0;
   m_outage_max_start=0;
   ArrayFree(m_outage_start);
   ArrayFree(m_outage_len);
   m_worst_wd=-1;
   m_worst_from=0;
   m_worst_to=0;
   ArrayFree(m_rows);
   m_findings=0;
   m_rows_written=0;
  }
//+------------------------------------------------------------------+
//| State of C3: on, off by the input, or the table that is missing  |
//+------------------------------------------------------------------+
string CSraSymbolAudit::C3State(void) const
  {
   if(!InpCheckTrade)
      return("off");
   if(!QuoteOn())
      return("no quote table");
   return(TradeOn() ? "on" : "no trade table");
  }
//+------------------------------------------------------------------+
//| M1 open times: the newest bar or [D0, D1-1]; -1 on failure       |
//+------------------------------------------------------------------+
int CSraSymbolAudit::Fetch(const bool newest,datetime &times[])
  {
//--- a live chart retries 20 times with a pause of 500 ms, the tester tries once
   int attempts=(MQLInfoInteger(MQL_TESTER)!=0 ? 1 : SRA_RETRIES);
   int got=-1;
   int error=0;
   for(int attempt=1; attempt<=attempts; attempt++)
     {
      ResetLastError();
      if(newest)
         got=CopyTime(m_symbol,PERIOD_M1,0,1,times);
      else
         got=CopyTime(m_symbol,PERIOD_M1,(datetime)m_d0,(datetime)(m_d1-1),times);
      error=GetLastError();
      //--- 4401 = not found yet, 4403 = the synchronisation timed out and
      //    the answer may be partial; both are worth one more attempt
      if(got>=0 && error!=ERR_HISTORY_NOT_FOUND && error!=ERR_HISTORY_TIMEOUT)
         break;
      if(attempt<attempts)
        {
         m_retries++;
         Sleep(SRA_RETRY_MS);
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
//| Reads one session table record by record, 0 = quote, 1 = trade   |
//+------------------------------------------------------------------+
void CSraSymbolAudit::LoadTable(const int kind)
  {
   m_sess_total[kind]=0;
   for(int day=0; day<7; day++)
     {
      m_sess_count[kind][day]=0;
      for(int index=0; index<SRA_MAX_SESSIONS; index++)
        {
         datetime from=0,to=0;
         bool     found=(kind==0 ? SymbolInfoSessionQuote(m_symbol,(ENUM_DAY_OF_WEEK)day,(uint)index,from,to) :
                         SymbolInfoSessionTrade(m_symbol,(ENUM_DAY_OF_WEEK)day,(uint)index,from,to));
         if(!found)
            break;
         int slot=day*SRA_MAX_SESSIONS+m_sess_count[kind][day];
         m_sess_from[kind][slot]=(int)from;
         m_sess_to[kind][slot]=(int)to;
         m_sess_count[kind][day]++;
         m_sess_total[kind]++;
        }
     }
  }
//+------------------------------------------------------------------+
//| The session predicate, shared with 78008 and with the verifier   |
//+------------------------------------------------------------------+
bool CSraSymbolAudit::InTable(const int kind,const int weekday,const int secs) const
  {
//--- for some session: from <= secs < max(to, from+1) OR (to >= 86400 AND secs >= from)
   for(int index=0; index<m_sess_count[kind][weekday]; index++)
     {
      int slot=weekday*SRA_MAX_SESSIONS+index;
      int from=m_sess_from[kind][slot];
      int to=m_sess_to[kind][slot];
      if((secs>=from && secs<MathMax(to,from+1)) || (to>=86400 && secs>=from))
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Flags and counts every cell: Q, T and C3, then E, C1 and C2      |
//+------------------------------------------------------------------+
void CSraSymbolAudit::Classify(void)
  {
   bool quote=QuoteOn();
   bool trade=TradeOn();
   bool c3=C3On();
   for(int cell=0; cell<SRA_CELLS; cell++)
     {
      int  day=cell/SRA_DAY;
      int  secs=(cell%SRA_DAY)*60;
      long dates=m_days_wd[day];
      long hits=m_hits[cell];
      int  flags=0;
      //--- a minute is declared when the predicate holds at its first second
      if(quote && InTable(0,day,secs))
         flags|=SRA_Q;
      if(trade && InTable(1,day,secs))
         flags|=SRA_T;
      //--- C3 over all 10 080 cells, whether the weekday is in the window or not
      if(c3 && flags==SRA_T)
         flags|=SRA_TNQ;
      if(c3 && flags==SRA_Q)
         flags|=SRA_QNT;
      //--- E, C1 and C2 need the quote table and a weekday with dates
      if(quote && dates>0)
        {
         if(hits*100>=(long)ExtLivePct*dates)
            flags|=SRA_LIVE;
         if((flags&SRA_Q)!=0 && hits*100<=(long)ExtDeadPct*dates)
            flags|=SRA_DEAD;
         if((flags&SRA_Q)==0 && hits>=1)
           {
            flags|=SRA_OUT;
            m_out_bars+=hits;
           }
        }
      m_cell[cell]=(uchar)flags;
      m_decl_quote+=((flags&SRA_Q)!=0 ? 1 : 0);
      m_decl_trade+=((flags&SRA_T)!=0 ? 1 : 0);
      m_tnq_min+=((flags&SRA_TNQ)!=0 ? 1 : 0);
      m_qnt_min+=((flags&SRA_QNT)!=0 ? 1 : 0);
      m_effective+=((flags&SRA_LIVE)!=0 ? 1 : 0);
      m_dead_min+=((flags&SRA_DEAD)!=0 ? 1 : 0);
      m_out_min+=((flags&SRA_OUT)!=0 ? 1 : 0);
     }
  }
//+------------------------------------------------------------------+
//| Maximal runs of a flag inside one weekday, cut at midnight       |
//+------------------------------------------------------------------+
int CSraSymbolAudit::Runs(const int flag,const int weekday,int &from[],int &to[]) const
  {
   int count=0;
   int start=-1;
   for(int minute=0; minute<=SRA_DAY; minute++)
     {
      bool on=(minute<SRA_DAY && (m_cell[weekday*SRA_DAY+minute]&flag)!=0);
      if(on && start<0)
         start=minute;
      if(!on && start>=0)
        {
         ArrayResize(from,count+1,64);
         ArrayResize(to,count+1,64);
         from[count]=start;
         to[count]=minute;
         count++;
         start=-1;
        }
     }
   return(count);
  }
//+------------------------------------------------------------------+
//| Largest and summed dates with a bar over the minutes of one run  |
//+------------------------------------------------------------------+
void CSraSymbolAudit::RunHits(const int weekday,const int from,const int to,int &most,long &sum) const
  {
   most=0;
   sum=0;
   for(int minute=from; minute<to; minute++)
     {
      most=MathMax(most,m_hits[weekday*SRA_DAY+minute]);
      sum+=m_hits[weekday*SRA_DAY+minute];
     }
  }
//+------------------------------------------------------------------+
//| Runs of one flag as journal text, with dead and outside values   |
//+------------------------------------------------------------------+
string CSraSymbolAudit::RunsText(const int flag,const int weekday) const
  {
   int    from[],to[];
   int    count=Runs(flag,weekday,from,to);
   string out="";
   for(int i=0; i<count; i++)
     {
      int  most=0;
      long sum=0;
      RunHits(weekday,from[i],to[i],most,sum);
      out+=(i>0 ? " " : "")+SraClock(from[i])+"-"+SraClock(to[i]);
      if(flag==SRA_DEAD)
         out+=" ("+IntegerToString(most)+"/"+IntegerToString(m_days_wd[weekday])+")";
      if(flag==SRA_OUT)
         out+=" ("+SraNum(sum)+" bars)";
     }
   return(count>0 ? out : "none");
  }
//+------------------------------------------------------------------+
//| Adds one findings row and counts it, the identity's left side    |
//+------------------------------------------------------------------+
void CSraSymbolAudit::Found(const ENUM_SRA_CHECK check,const int weekday,const string start,const string end,
                            const long minutes,const string value,const string detail)
  {
   int count=(int)m_findings;
   ArrayResize(m_rows,count+1,256);
   m_rows[count]=m_symbol+SRA_SEP+ExtCheckNames[(int)check]+SRA_SEP+SraDayName(weekday)+SRA_SEP+start+
                 SRA_SEP+end+SRA_SEP+SraNum(minutes)+SRA_SEP+value+SRA_SEP+detail;
   m_findings++;
  }
//+------------------------------------------------------------------+
//| C1, C2, C3: one finding per run, Sunday first, minute order      |
//+------------------------------------------------------------------+
void CSraSymbolAudit::MapFindings(const int flag,const ENUM_SRA_CHECK check)
  {
   for(int day=0; day<7; day++)
     {
      int from[],to[];
      int count=Runs(flag,day,from,to);
      for(int i=0; i<count; i++)
        {
         int    most=0;
         long   sum=0;
         string dates=IntegerToString(m_days_wd[day])+" "+SraDayName(day)+" dates";
         string value="";
         string detail="";
         RunHits(day,from[i],to[i],most,sum);
         switch(check)
           {
            case SRA_CHECK_DEAD:
               m_dead_win++;
               value=IntegerToString(most)+"/"+IntegerToString(m_days_wd[day]);
               detail="declared quote minutes with bars on at most "+IntegerToString(ExtDeadPct)+"% of the "+dates;
               //--- the longest dead window is the panel's worst one, the first of equals wins
               if(to[i]-from[i]>m_worst_to-m_worst_from)
                 {
                  m_worst_wd=day;
                  m_worst_from=from[i];
                  m_worst_to=to[i];
                 }
               break;
            case SRA_CHECK_OUTSIDE:
               m_out_win++;
               value=SraNum(sum);
               detail="bars outside the quote table, over the "+dates;
               break;
            case SRA_CHECK_TRADE_NO_QUOTE:
               m_tnq_win++;
               detail="trade session open, no quote session: orders accepted while no price is expected";
               break;
            default:
               m_qnt_win++;
               detail="quote session open, no trade session: prices shown, orders rejected";
               break;
           }
         Found(check,day,SraClock(from[i]),SraClock(to[i]),to[i]-from[i],value,detail);
        }
     }
  }
//+------------------------------------------------------------------+
//| C4: runs in time of declared, not dead minutes without a bar     |
//+------------------------------------------------------------------+
void CSraSymbolAudit::Outages(void)
  {
//--- the timeline D0, D0+60, ... D1-60; a run may cross midnight, a dead or
//    undeclared minute or a bar ends it, the end of the window too
   int  total=m_days*SRA_DAY;
   int  run=0;
   long start=0;
   for(int i=0; i<=total; i++)
     {
      long moment=m_d0+(long)i*60;
      if(i<total)
        {
         int flags=m_cell[SraWeekday(moment)*SRA_DAY+(int)((moment%86400)/60)];
         if((flags&SRA_Q)!=0 && (flags&SRA_DEAD)==0 && m_has[i]==0)
           {
            if(run==0)
               start=moment;
            run++;
            continue;
           }
        }
      if(run>=ExtOutageMinutes)
        {
         int count=(int)m_outages;
         ArrayResize(m_outage_start,count+1,64);
         ArrayResize(m_outage_len,count+1,64);
         m_outage_start[count]=start;
         m_outage_len[count]=run;
         m_outages++;
         m_outage_min+=run;
         if(run>m_outage_max)
           {
            m_outage_max=run;
            m_outage_max_start=start;
           }
         Found(SRA_CHECK_OUTAGE,SraWeekday(start),SraDate(start),SraDate(moment),run,IntegerToString(run),
               "no bar in "+IntegerToString(run)+" declared, normally live minutes from "+
               SraDayName(SraWeekday(start))+" "+SraDate(start));
        }
      run=0;
     }
  }
//+------------------------------------------------------------------+
//| Audits the symbol; a failure is one journal line and a status    |
//+------------------------------------------------------------------+
bool CSraSymbolAudit::Audit(void)
  {
//--- stage: does the terminal know this symbol at all
   double point=0.0;
   ResetLastError();
   if(!SymbolInfoDouble(m_symbol,SYMBOL_POINT,point) || point<=0.0)
     {
      m_status=SRA_STATUS_UNKNOWN;
      PrintFormat("%s: %s is not a symbol of this terminal (error %d), it is skipped",SRA_NAME,m_symbol,
                  GetLastError());
      return(false);
     }
//--- stage: the newest M1 bar fixes the window, its partial day is left out
   datetime times[];
   if(Fetch(true,times)<=0)
     {
      m_status=SRA_STATUS_NO_BARS;
      PrintFormat("%s: %s has no M1 bar (error %d), it is skipped",SRA_NAME,m_symbol,m_read_error);
      return(false);
     }
   m_last=(long)times[0];
   m_d1=m_last-m_last%86400;
   m_d0=m_d1-(long)ExtDays*86400;
   long first=0;
   if(SeriesInfoInteger(m_symbol,PERIOD_M1,SERIES_FIRSTDATE,first) && first>m_d0)
     {
      m_d0=(first+86399)/86400*86400;
      if(m_d0<m_d1)
         PrintFormat("%s: %s M1 history starts %s, window shortened to %d days",SRA_NAME,m_symbol,SraDate(first),
                     (int)((m_d1-m_d0)/86400));
     }
   if(m_d0>=m_d1)
     {
      m_status=SRA_STATUS_EMPTY;
      PrintFormat("%s: %s has no whole day of M1 history before %s, it is skipped",SRA_NAME,m_symbol,SraDate(m_d1));
      return(false);
     }
//--- stage: the bars of the window, kept once per minute
   int got=Fetch(false,times);
   if(got<0)
     {
      m_status=SRA_STATUS_NO_READ;
      PrintFormat("%s: %s M1 bars %s to %s could not be read (error %d), the symbol is skipped",SRA_NAME,m_symbol,
                  SraDate(m_d0),SraDate(m_d1),m_read_error);
      return(false);
     }
   m_days=(int)((m_d1-m_d0)/86400);
   for(int day=0; day<m_days; day++)
      m_days_wd[SraWeekday(m_d0+(long)day*86400)]++;
   ArrayResize(m_has,m_days*SRA_DAY);
   ArrayInitialize(m_has,0);
   for(int i=0; i<got; i++)
     {
      long moment=(long)times[i];
      if(moment<m_d0 || moment>=m_d1 || m_has[(int)((moment-m_d0)/60)]!=0)
         continue;
      m_has[(int)((moment-m_d0)/60)]=1;
      m_bars++;
      m_hits[SraWeekday(moment)*SRA_DAY+(int)((moment%86400)/60)]++;
     }
   if(m_bars==0)
     {
      m_status=SRA_STATUS_EMPTY;
      ArrayFree(m_has);
      PrintFormat("%s: %s has no M1 bar between %s and %s, it is skipped",SRA_NAME,m_symbol,SraDate(m_d0),
                  SraDate(m_d1));
      return(false);
     }
//--- stage: the declared tables and the weekly map
   LoadTable(0);
   LoadTable(1);
   if(!QuoteOn())
      PrintFormat("%s: %s reports no quote session, C1, C2, C4 and the effective table are not measured",SRA_NAME,
                  m_symbol);
   if(InpCheckTrade && !TradeOn())
      PrintFormat("%s: %s reports no trade session, C3 is not measured",SRA_NAME,m_symbol);
   Classify();
//--- stage: the findings, check after check
   if(QuoteOn())
     {
      MapFindings(SRA_DEAD,SRA_CHECK_DEAD);
      MapFindings(SRA_OUT,SRA_CHECK_OUTSIDE);
     }
   if(C3On())
     {
      MapFindings(SRA_TNQ,SRA_CHECK_TRADE_NO_QUOTE);
      MapFindings(SRA_QNT,SRA_CHECK_QUOTE_NO_TRADE);
     }
   if(QuoteOn())
      Outages();
   ArrayFree(m_has);
   m_status=SRA_STATUS_OK;
   return(true);
  }
//+------------------------------------------------------------------+
//| Writes the summary, sessions, map and effective file of a symbol |
//+------------------------------------------------------------------+
void CSraSymbolAudit::WriteFiles(CSraReport &report) const
  {
   bool   quote=QuoteOn();
   bool   trade=TradeOn();
   bool   c3=C3On();
   string rows[];
   ArrayResize(rows,SRA_CELLS);
//--- stage: the summary, the contract columns first in their fixed order
   string by_day="";
   for(int day=0; day<7; day++)
      by_day+=(day>0 ? "|" : "")+IntegerToString(m_days_wd[day]);
   string line=m_symbol+SRA_SEP+SraNum(m_d0)+SRA_SEP+SraNum(m_d1)+SRA_SEP+IntegerToString(m_days)+SRA_SEP+by_day+
               SRA_SEP+SraNum(m_bars)+SRA_SEP+IntegerToString(m_sess_total[0])+SRA_SEP+IntegerToString(m_sess_total[1])+
               SRA_SEP+IntegerToString(ExtLivePct)+SRA_SEP+IntegerToString(ExtDeadPct)+
               SRA_SEP+IntegerToString(ExtOutageMinutes);
   line+=SRA_SEP+SraCell(quote,SraNum(m_decl_quote))+SRA_SEP+SraCell(trade,SraNum(m_decl_trade))+
         SRA_SEP+SraCell(quote,SraNum(m_effective))+SRA_SEP+SraCell(quote,SraNum(m_dead_min))+
         SRA_SEP+SraCell(quote,SraNum(m_dead_win))+SRA_SEP+SraCell(quote,SraNum(m_out_min))+
         SRA_SEP+SraCell(quote,SraNum(m_out_bars))+SRA_SEP+SraCell(quote,SraNum(m_out_win));
   line+=SRA_SEP+SraCell(c3,SraNum(m_tnq_min))+SRA_SEP+SraCell(c3,SraNum(m_tnq_win))+
         SRA_SEP+SraCell(c3,SraNum(m_qnt_min))+SRA_SEP+SraCell(c3,SraNum(m_qnt_win));
   line+=SRA_SEP+SraCell(quote,SraNum(m_outages))+SRA_SEP+SraCell(quote,SraNum(m_outage_min))+
         SRA_SEP+SraCell(quote,SraNum(m_outage_max))+SRA_SEP+SraCell(quote,SraNum(m_outage_max_start))+
         SRA_SEP+SraNum(m_findings);
//--- stage: the columns a human reads, after the contract
   line+=SRA_SEP+SraDate(m_d0)+SRA_SEP+SraDate(m_d1)+SRA_SEP+SraDate(m_last)+SRA_SEP+IntegerToString(m_retries)+
         SRA_SEP+(quote ? "available" : "unavailable")+SRA_SEP+(trade ? "available" : "unavailable")+
         SRA_SEP+C3State()+SRA_SEP+SraNum(FindingsSum())+SRA_SEP+(m_findings==FindingsSum() ? "OK" : "MISMATCH");
   rows[0]=line;
   report.WriteTable(m_symbol,"summary","symbol;from;to;days;days_by_weekday;bars;quote_sessions;trade_sessions;"
                     "live_pct;dead_pct;outage_min_minutes;declared_quote_minutes;declared_trade_minutes;"
                     "effective_minutes;dead_minutes;dead_windows;outside_minutes;outside_bars;outside_windows;"
                     "trade_no_quote_minutes;trade_no_quote_windows;quote_no_trade_minutes;quote_no_trade_windows;"
                     "outages;outage_minutes;outage_max_minutes;outage_max_start;findings_rows;from_time;to_time;"
                     "newest_bar;read_retries;quote_table;trade_table;c3_state;findings_sum;identity",rows,1);
//--- stage: every session record of both tables
   int count=0;
   for(int kind=0; kind<2; kind++)
      for(int day=0; day<7; day++)
         for(int index=0; index<m_sess_count[kind][day]; index++)
            rows[count++]=m_symbol+SRA_SEP+(kind==0 ? "quote" : "trade")+SRA_SEP+IntegerToString(day)+
                          SRA_SEP+IntegerToString(m_sess_from[kind][day*SRA_MAX_SESSIONS+index])+
                          SRA_SEP+IntegerToString(m_sess_to[kind][day*SRA_MAX_SESSIONS+index]);
   report.WriteTable(m_symbol,"sessions","symbol;kind;weekday;from_seconds;to_seconds",rows,count);
//--- stage: the weekly map, 10 080 rows; a table that is missing leaves its column empty
   for(int cell=0; cell<SRA_CELLS; cell++)
      rows[cell]=IntegerToString(cell/SRA_DAY)+SRA_SEP+IntegerToString(cell%SRA_DAY)+
                 SRA_SEP+SraCell(quote,((m_cell[cell]&SRA_Q)!=0 ? "1" : "0"))+
                 SRA_SEP+SraCell(trade,((m_cell[cell]&SRA_T)!=0 ? "1" : "0"))+
                 SRA_SEP+IntegerToString(m_hits[cell])+SRA_SEP+IntegerToString(m_days_wd[cell/SRA_DAY]);
   report.WriteTable(m_symbol,"map","weekday;minute;quote;trade;hits;days",rows,SRA_CELLS);
//--- stage: the effective table, only when it was measured
   if(!quote)
      return;
   count=0;
   for(int day=0; day<7; day++)
     {
      int from[],to[];
      int runs=Runs(SRA_LIVE,day,from,to);
      for(int i=0; i<runs; i++)
         rows[count++]=IntegerToString(day)+SRA_SEP+IntegerToString(from[i])+SRA_SEP+IntegerToString(to[i])+
                       SRA_SEP+SraClock(from[i])+SRA_SEP+SraClock(to[i]);
     }
   report.WriteTable(m_symbol,"effective","weekday;from_minute;to_minute;from;to",rows,count);
  }
//+------------------------------------------------------------------+
//| Journal block: window, weekdays, totals, outages and identity    |
//+------------------------------------------------------------------+
void CSraSymbolAudit::JournalLines(string &lines[]) const
  {
   ArrayResize(lines,0,32);
   if(m_status!=SRA_STATUS_OK)
      return;
   bool   quote=QuoteOn();
   bool   c3=C3On();
   string by_day="";
   for(int day=0; day<7; day++)
      by_day+=(day>0 ? " " : "")+SraDayName(day)+" "+IntegerToString(m_days_wd[day]);
   SraAdd(lines,StringFormat("%s: window %s to %s, %d whole days (%s), newest M1 bar %s, %s bars, %d retries",
                             m_symbol,SraDate(m_d0),SraDate(m_d1),m_days,by_day,SraDate(m_last),SraNum(m_bars),
                             m_retries));
   SraAdd(lines,StringFormat("%s: quote table %d records, trade table %d records; live >= %d%%, dead <= %d%%, outage >= %d min",
                             m_symbol,m_sess_total[0],m_sess_total[1],ExtLivePct,ExtDeadPct,ExtOutageMinutes));
//--- stage: one line per weekday with a declared, live or C3 cell; a dash when not measured
   for(int day=0; day<7; day++)
     {
      bool any=false;
      for(int minute=0; minute<SRA_DAY && !any; minute++)
         any=((m_cell[day*SRA_DAY+minute]&(SRA_Q|SRA_LIVE|SRA_TNQ|SRA_QNT))!=0);
      if(!any)
         continue;
      bool   measured=(quote && m_days_wd[day]>0);
      string text=m_symbol+" "+SraDayName(day)+"  table "+RunsText(SRA_Q,day)+
                  " | real "+SraText(measured,RunsText(SRA_LIVE,day))+" | dead "+SraText(measured,RunsText(SRA_DEAD,day))+
                  " | outside "+SraText(measured,RunsText(SRA_OUT,day));
      if(c3 && RunsText(SRA_TNQ,day)!="none")
         text+=" | trade only "+RunsText(SRA_TNQ,day);
      if(c3 && RunsText(SRA_QNT,day)!="none")
         text+=" | quote only "+RunsText(SRA_QNT,day);
      SraAdd(lines,text);
     }
//--- stage: the totals of every check and the first outages
   SraAdd(lines,StringFormat("%s: declared quote %s h/wk, trade %s h/wk, real %s h/wk; dead %s min in %s windows; outside %s min, %s bars in %s windows",
                             m_symbol,SraText(quote,SraHours(m_decl_quote)),SraText(TradeOn(),SraHours(m_decl_trade)),
                             SraText(quote,SraHours(m_effective)),SraText(quote,SraNum(m_dead_min)),
                             SraText(quote,SraNum(m_dead_win)),SraText(quote,SraNum(m_out_min)),
                             SraText(quote,SraNum(m_out_bars)),SraText(quote,SraNum(m_out_win))));
   SraAdd(lines,StringFormat("%s: C3 %s, trade without quote %s min in %s windows, quote without trade %s min in %s windows",
                             m_symbol,C3State(),SraText(c3,SraNum(m_tnq_min)),SraText(c3,SraNum(m_tnq_win)),
                             SraText(c3,SraNum(m_qnt_min)),SraText(c3,SraNum(m_qnt_win))));
   SraAdd(lines,StringFormat("%s: outages of %d min or more %s, %s min, longest %s min from %s",m_symbol,
                             ExtOutageMinutes,SraText(quote,SraNum(m_outages)),SraText(quote,SraNum(m_outage_min)),
                             SraText(quote,SraNum(m_outage_max)),(m_outages>0 ? SraDayName(SraWeekday(m_outage_max_start))+
                                   " "+SraDate(m_outage_max_start) : "-")));
   for(int i=0; i<m_outages && i<ExtMaxExamples; i++)
      SraAdd(lines,StringFormat("%s: outage %d of %s: %s %s to %s, %s minutes",m_symbol,i+1,SraNum(m_outages),
                                SraDayName(SraWeekday(m_outage_start[i])),SraDate(m_outage_start[i]),
                                SraDate(m_outage_start[i]+m_outage_len[i]*60),SraNum(m_outage_len[i])));
//--- stage: the identity, both sides as numbers
   SraAdd(lines,StringFormat("%s: identity findings_rows %s == dead_windows %s + outside_windows %s + trade_no_quote_windows %s + quote_no_trade_windows %s + outages %s = %s -> %s",
                             m_symbol,SraNum(m_findings),SraText(quote,SraNum(m_dead_win)),SraText(quote,SraNum(m_out_win)),
                             SraText(c3,SraNum(m_tnq_win)),SraText(c3,SraNum(m_qnt_win)),SraText(quote,SraNum(m_outages)),
                             SraNum(FindingsSum()),(m_findings==FindingsSum() ? "OK" : "MISMATCH")));
   SraAdd(lines,StringFormat("%s: rows of this symbol in the findings file %s, findings_rows %s -> %s",m_symbol,
                             SraText(InpWriteCsv,SraNum(m_rows_written)),SraNum(m_findings),
                             (!InpWriteCsv ? "file off" : (m_rows_written==m_findings ? "OK" : "MISMATCH"))));
  }
//+------------------------------------------------------------------+
//| Header row of the result table, shared by panel and journal      |
//+------------------------------------------------------------------+
void CSraSymbolAudit::HeaderCells(string &cells[][SRA_COLS],const int row)
  {
   cells[row][0]="Symbol";
   cells[row][1]="Days";
   cells[row][2]="Table h/wk";
   cells[row][3]="Real h/wk";
   cells[row][4]="Dead min/wk";
   cells[row][5]="Outside min";
   cells[row][6]="Trade"+ShortToString(0x2260)+"Quote min";
   cells[row][7]="Outages";
   cells[row][8]="Longest";
   cells[row][9]="Worst dead window";
  }
//+------------------------------------------------------------------+
//| One table row; a skipped symbol shows its status, not numbers    |
//+------------------------------------------------------------------+
void CSraSymbolAudit::Cells(string &cells[][SRA_COLS],const int row) const
  {
   for(int c=0; c<SRA_COLS; c++)
      cells[row][c]="";
   cells[row][0]=m_symbol;
   if(m_status!=SRA_STATUS_OK)
     {
      cells[row][1]=ExtStatusNames[(int)m_status];
      return;
     }
   bool quote=QuoteOn();
   cells[row][1]=IntegerToString(m_days);
   cells[row][2]=SraText(quote,SraHours(m_decl_quote));
   cells[row][3]=SraText(quote,SraHours(m_effective));
   cells[row][4]=SraText(quote,SraNum(m_dead_min));
   cells[row][5]=SraText(quote,SraNum(m_out_min));
   cells[row][6]=SraText(C3On(),SraNum(m_tnq_min+m_qnt_min));
   cells[row][7]=SraText(quote,SraNum(m_outages));
   cells[row][8]=SraText(quote,SraNum(m_outage_max)+" min");
   cells[row][9]=SraText(quote,(m_worst_wd<0 ? "none" :
                                SraDayName(m_worst_wd)+" "+SraClock(m_worst_from)+"-"+SraClock(m_worst_to)));
  }
//--- global objects and counters of the expert
CSraReport        ExtReport;                       // journal lines and the CSV files
CSraPanel         ExtPanel;                        // the table on the chart
CSraSymbolAudit   ExtAudits[SRA_MAX_SYMBOLS];      // one audit per symbol of the list
string            ExtSymbols[SRA_MAX_SYMBOLS];     // the resolved symbol list
int               ExtCount=0;                      // symbols in the list
string            ExtPrefix="";                    // file name prefix of this instance
bool              ExtReady=false;                  // Init() reached its end
bool              ExtPanelOn=false;                // the panel objects exist
bool              ExtFirstDone=false;              // the first pass has run
int               ExtPulses=0;                     // pulses counted while waiting for the history
int               ExtPass=0;                       // passes finished
datetime          ExtLastPass=0;                   // server time the last pass started
ulong             ExtWallMs=0;                     // duration of the last pass, milliseconds
int               ExtOk=0;                         // symbols audited
int               ExtFailed=0;                     // symbols skipped
int               ExtIdentityOk=0;                 // symbols whose findings add up
long              ExtFindings=0;                   // findings of the last pass
long              ExtFindingsSum=0;                // sum of the finding counters of the last pass
//+------------------------------------------------------------------+
//| The whole expert back to its starting state (pitfall C24)        |
//+------------------------------------------------------------------+
void SraReset(void)
  {
   ExtReport.Close();
   ExtReport.Reset();
   ExtPanel.Reset();
   for(int i=0; i<SRA_MAX_SYMBOLS; i++)
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
   ExtWallMs=0;
   ExtOk=0;
   ExtFailed=0;
   ExtIdentityOk=0;
   ExtFindings=0;
   ExtFindingsSum=0;
   ExtDays=28;
   ExtLivePct=50;
   ExtDeadPct=25;
   ExtOutageMinutes=5;
   ExtMaxExamples=5;
  }
//+------------------------------------------------------------------+
//| Adds a symbol once; a duplicate would count twice in the totals  |
//+------------------------------------------------------------------+
void SraAddSymbol(const string name)
  {
   if(name=="")
      return;
   for(int i=0; i<ExtCount; i++)
      if(ExtSymbols[i]==name)
         return;
   if(ExtCount>=SRA_MAX_SYMBOLS)
     {
      PrintFormat("%s: the list is full at %d symbols, %s is not audited",SRA_NAME,SRA_MAX_SYMBOLS,name);
      return;
     }
   ExtSymbols[ExtCount++]=name;
  }
//+------------------------------------------------------------------+
//| Resolves the symbol input; the Market Watch is never changed     |
//+------------------------------------------------------------------+
void SraBuildSymbolList(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
     {
      int total=SymbolsTotal(true);
      for(int i=0; i<total; i++)
         SraAddSymbol(SymbolName(i,true));
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
         SraAddSymbol(parts[i]);
        }
     }
   if(ExtCount<=0)
      SraAddSymbol(Symbol());
  }
//+------------------------------------------------------------------+
//| Tag of the symbol selection for the file names                   |
//+------------------------------------------------------------------+
string SraSymbolsTag(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
      return("MarketWatch");
   if(ExtCount==1)
      return(SraSafeName(ExtSymbols[0]));
   return(SraSafeName(ExtSymbols[0])+"_plus"+IntegerToString(ExtCount-1));
  }
//+------------------------------------------------------------------+
//| Clamps one integer input and says so in the journal              |
//+------------------------------------------------------------------+
int SraClamp(const string name,const int value,const int low,const int high)
  {
   int used=MathMin(high,MathMax(low,value));
   if(used!=value)
      PrintFormat("%s: %s %d is outside %d..%d, %d is used",SRA_NAME,name,value,low,high,used);
   return(used);
  }
//+------------------------------------------------------------------+
//| Prints the settings of the run once, after the clamping          |
//+------------------------------------------------------------------+
void SraPrintStartBlock(void)
  {
   Print("=== "+SRA_TITLE+" ==========================================");
   PrintFormat("symbols        : %d (%s)",ExtCount,(InpSymbols=="" ? "chart symbol" :
               (InpSymbols=="*" ? "Market Watch" : "list")));
   PrintFormat("window         : %d whole server day(s) of M1 bars before the day of the newest bar",ExtDays);
   PrintFormat("thresholds     : live >= %d%%, dead <= %d%% of the dates of a weekday, outage >= %d min",ExtLivePct,
               ExtDeadPct,ExtOutageMinutes);
   PrintFormat("checks         : C1 dead, C2 outside, C3 trade vs quote %s, C4 outages, E effective table",
               (InpCheckTrade ? "on" : "off"));
   PrintFormat("refresh        : %s",(InpRefreshMinutes>0 ? IntegerToString(InpRefreshMinutes)+" minutes of server time" :
                                      "once"));
   PrintFormat("files          : %s",(InpWriteCsv ? SRA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "off"));
   for(int i=0; i<ExtCount; i++)
      PrintFormat("symbol %d of %d  : %s",i+1,ExtCount,ExtSymbols[i]);
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Fills the result table: the header and at most rows symbols      |
//+------------------------------------------------------------------+
int SraBuildCells(string &cells[][SRA_COLS],const int rows)
  {
   int shown=MathMin(rows,ExtCount);
   ArrayResize(cells,shown+1);
   CSraSymbolAudit::HeaderCells(cells,0);
   for(int i=0; i<shown; i++)
      ExtAudits[i].Cells(cells,i+1);
   return(shown+1);
  }
//+------------------------------------------------------------------+
//| Prints the result table of one pass and the run identities       |
//+------------------------------------------------------------------+
void SraPrintSummary(void)
  {
   Print("=== "+SRA_TITLE+" - result of pass "+IntegerToString(ExtPass)+" ========");
   string cells[][SRA_COLS];
   int    rows=SraBuildCells(cells,ExtCount);
   int    widths[SRA_COLS];
   SraColumnWidths(cells,rows,widths);
   for(int r=0; r<rows; r++)
      Print(SraRowText(cells,r,widths));
   PrintFormat("symbols        : %d audited, %d skipped, identity OK %d of %d",ExtOk,ExtFailed,ExtIdentityOk,ExtOk);
   PrintFormat("totals         : findings %s, sum of the finding counters %s -> %s",SraNum(ExtFindings),
               SraNum(ExtFindingsSum),(ExtFindings==ExtFindingsSum ? "OK" : "MISMATCH"));
   PrintFormat("findings file  : %s, rows written %s -> %s",(ExtReport.FindingsOn() ? ExtReport.FindingsName() : "off"),
               SraNum(ExtReport.Rows()),(!ExtReport.FindingsOn() ? "file off" :
                                         (ExtReport.Rows()==ExtFindings ? "OK" : "MISMATCH")));
   PrintFormat("symbol files   : %d written, pattern %s\\%s_<symbol>_{summary,sessions,map,effective}.csv",
               ExtReport.Files(),SRA_FOLDER,ExtPrefix);
   PrintFormat("wall time      : %s ms",SraNum((long)ExtWallMs));
   if(ExtPanelOn)
      PrintFormat("panel          : %d x %d pixels, %d labels, widest line %d characters",ExtPanel.WidthPx(),
                  ExtPanel.HeightPx(),ExtPanel.Labels(),ExtPanel.Widest());
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Redraws the panel with the numbers of the last pass              |
//+------------------------------------------------------------------+
void SraUpdatePanel(void)
  {
   if(!ExtPanelOn)
      return;
   string top[3];
   string bottom[];
   string cells[][SRA_COLS];
   top[0]=SRA_TITLE+"   pass "+IntegerToString(ExtPass)+"   "+
          (ExtLastPass>0 ? TimeToString(ExtLastPass,TIME_DATE|TIME_SECONDS) : "-")+
          (ExtFirstDone ? "" : "   waiting for the history");
   top[1]=IntegerToString(ExtDays)+" whole day(s) of M1 bars before the newest bar's day   live >= "+
          IntegerToString(ExtLivePct)+"%   dead <= "+IntegerToString(ExtDeadPct)+"%   outage >= "+
          IntegerToString(ExtOutageMinutes)+" min";
   top[2]="findings "+SraNum(ExtFindings)+"   csv rows "+SraText(InpWriteCsv,SraNum(ExtReport.Rows()))+
          "   identity OK "+IntegerToString(ExtIdentityOk)+"/"+IntegerToString(ExtOk)+"   skipped "+
          IntegerToString(ExtFailed);
   int rows=SraBuildCells(cells,(ExtFirstDone ? SRA_PANEL_ROWS : 0));
   int lines=(ExtCount>SRA_PANEL_ROWS && ExtFirstDone ? 2 : 1);
   ArrayResize(bottom,lines);
   bottom[0]=(InpWriteCsv ? SRA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "CSV off");
   if(lines>1)
      bottom[1]="... and "+IntegerToString(ExtCount-SRA_PANEL_ROWS)+" more symbols in the journal and the CSV";
   ExtPanel.Update(top,cells,rows,bottom);
  }
//+------------------------------------------------------------------+
//| Tells whether the M1 series of every known symbol is built       |
//+------------------------------------------------------------------+
bool SraHistoryReady(void)
  {
   for(int i=0; i<ExtCount; i++)
     {
      double point=0.0;
      long   built=0;
      if(!SymbolInfoDouble(ExtSymbols[i],SYMBOL_POINT,point) || point<=0.0)
         continue;
      if(!SeriesInfoInteger(ExtSymbols[i],PERIOD_M1,SERIES_SYNCHRONIZED,built) || built==0)
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| One pass over the symbol list; a failure costs one symbol        |
//+------------------------------------------------------------------+
void SraRunPass(void)
  {
   ExtPass++;
   ExtLastPass=SraNow();
   ulong started=GetTickCount64();
   ExtOk=0;
   ExtFailed=0;
   ExtIdentityOk=0;
   ExtFindings=0;
   ExtFindingsSum=0;
   ExtReport.Close();
   ExtReport.Reset();
   ExtReport.Open(ExtPrefix);
   PrintFormat("%s: pass %d starts on %d symbol(s), server time %s",SRA_NAME,ExtPass,ExtCount,
               TimeToString(ExtLastPass,TIME_DATE|TIME_SECONDS));
   for(int i=0; i<ExtCount; i++)
     {
      ExtAudits[i].SetSymbol(ExtSymbols[i]);
      if(!ExtAudits[i].Audit())
        {
         ExtFailed++;
         continue;
        }
      string lines[];
      ExtAudits[i].Commit(ExtReport);
      ExtAudits[i].WriteFiles(ExtReport);
      ExtAudits[i].JournalLines(lines);
      ExtReport.Journal(lines);
      ExtOk++;
      ExtFindings+=ExtAudits[i].Findings();
      ExtFindingsSum+=ExtAudits[i].FindingsSum();
      if(ExtAudits[i].Findings()==ExtAudits[i].FindingsSum())
         ExtIdentityOk++;
     }
   ExtWallMs=GetTickCount64()-started;
//--- stage: the panel first, so the summary reports its real size
   SraUpdatePanel();
   SraPrintSummary();
   ExtReport.Close();
  }
//+------------------------------------------------------------------+
//| Reads the inputs, resolves the symbols and prepares the panel    |
//+------------------------------------------------------------------+
void SraInit(void)
  {
//--- stage: a previous run can still be in these objects, see SraReset()
   SraReset();
   ExtDays=SraClamp("InpDays",InpDays,1,SRA_MAX_DAYS);
   ExtLivePct=SraClamp("InpLivePct",InpLivePct,0,100);
   ExtDeadPct=SraClamp("InpDeadPct",InpDeadPct,0,100);
   ExtOutageMinutes=SraClamp("InpOutageMinutes",InpOutageMinutes,1,SRA_MAX_DAYS*SRA_DAY);
   ExtMaxExamples=SraClamp("InpMaxExamples",InpMaxExamples,0,1000);
   SraBuildSymbolList();
   ExtPrefix=SraSymbolsTag()+"_"+IntegerToString(ExtDays)+"d_"+IntegerToString(ChartID());
//--- stage: the panel; the tester without visual mode has no chart
   if(InpShowPanel)
     {
      if(MQLInfoInteger(MQL_TESTER)!=0 && MQLInfoInteger(MQL_VISUAL_MODE)==0)
         PrintFormat("%s: the panel stays off, the tester runs without visual mode",SRA_NAME);
      else
         ExtPanelOn=ExtPanel.Create();
     }
   SraPrintStartBlock();
//--- the flag is set last: OnDeinit() also runs after a failed start
   ExtReady=true;
   SraUpdatePanel();
  }
//+------------------------------------------------------------------+
//| One pulse of OnTick/OnTimer; the first pass waits for history    |
//+------------------------------------------------------------------+
void SraPulse(void)
  {
   if(!ExtReady)
      return;
   if(!ExtFirstDone)
     {
      ExtPulses++;
      if(!SraHistoryReady() && ExtPulses<SRA_WARMUP_PULSES)
         return;
      ExtFirstDone=true;
      SraRunPass();
      if(InpRefreshMinutes<=0)
        {
         EventKillTimer();
         PrintFormat("%s: the audit is finished, the timer is stopped (InpRefreshMinutes = 0)",SRA_NAME);
        }
      return;
     }
   if(InpRefreshMinutes>0 && (long)SraNow()-(long)ExtLastPass>=(long)InpRefreshMinutes*60)
      SraRunPass();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SraInit();
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
      PrintFormat("%s: %d pass(es) finished, %s findings counted",SRA_NAME,ExtPass,SraNum(ExtFindings));
   ExtReport.Close();
   ExtPanel.Destroy();
   PrintFormat("%s: stopped, deinitialisation reason %d",SRA_NAME,reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   SraPulse();
  }
//+------------------------------------------------------------------+
//| Timer function: drives the first pass and the optional re-audit  |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   SraPulse();
  }
//+------------------------------------------------------------------+
