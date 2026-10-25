//+------------------------------------------------------------------+
//|                                         TickIntegrityAuditor.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Audits the ticks underneath the bars, the data that the tester mode"
#property description "'Every tick based on real ticks' replays: quotes, time stamps, one"
#property description "tick price reversals, silences measured against the quote sessions"
#property description "and the high and low of the ticks against the M1 bars."
#property description "Read only measuring tool - it never calls a trade function."
//--- limits and behaviour constants
#define TIA_NAME          "TickIntegrityAuditor"   // program name used in every journal line
#define TIA_TITLE         "Tick Integrity Auditor" // title of the journal block and of the panel
#define TIA_FOLDER        "TickIntegrityAuditor"   // sub folder of MQL5\Files holding the CSV files
#define TIA_MAX_SYMBOLS   128                      // highest number of symbols one run can audit
#define TIA_MAX_DAYS      365                      // longest audit window in days
#define TIA_MAX_SESSIONS  8                        // quote sessions read per weekday
#define TIA_HIST_SIZE     100000                   // spread histogram cells, wider spreads go to a list
#define TIA_RETRIES       20                       // attempts of one tick request in a live chart
#define TIA_RETRY_MS      500                      // pause between two attempts, milliseconds
#define TIA_MAX_CSV_ROWS  1000000                  // disk guard for the findings file of one pass
#define TIA_PANEL_ROWS    24                       // symbol rows the panel shows at most
#define TIA_WARMUP_PULSES 15                       // pulses waited for the history before auditing
#define TIA_PANEL_FONT    "Consolas"               // monospace font, the panel is a table
#define TIA_MAX_LABEL     62                       // characters one OBJ_LABEL can show
#define TIA_COLS          12                       // columns of the result table
#define TIA_SEP           ";"                      // column separator of every CSV file
//--- colours of the panel, black on white so that a screenshot is readable
#define TIA_BACK_COLOR    clrWhite                 // panel background
#define TIA_BORDER_COLOR  clrBlack                 // panel border
#define TIA_TEXT_COLOR    clrBlack                 // panel text
//+------------------------------------------------------------------+
//| The kinds of finding. The name of each value is the check column |
//| of the findings CSV, so a row maps back to its definition.       |
//+------------------------------------------------------------------+
enum ENUM_TIA_CHECK
  {
   TIA_NONPOSITIVE=0,   // K1 bid or ask not above zero
   TIA_CROSSED,         // K1 ask below bid
   TIA_BACKWARDS,       // K2 time goes back
   TIA_REPEATS,         // K2 same millisecond, bid and ask
   TIA_TIME_FIELD,      // K2 time differs from time_msc/1000
   TIA_REVERSAL,        // K3 one tick reversal
   TIA_SILENCE,         // K4 unexplained silence
   TIA_M1_NO_TICKS,     // K5 M1 bar without ticks
   TIA_TICKS_NO_M1,     // K5 ticks without an M1 bar
   TIA_HIGH,            // K5 high of the bar differs
   TIA_LOW              // K5 low of the bar differs
  };
#define TIA_CHECK_COUNT   11                       // number of values in ENUM_TIA_CHECK
//+------------------------------------------------------------------+
//| What happened to one symbol of the list. Everything except OK is |
//| one journal line and never stops the run of the other symbols.   |
//+------------------------------------------------------------------+
enum ENUM_TIA_STATUS
  {
   TIA_STATUS_IDLE=0,   // not audited
   TIA_STATUS_UNKNOWN,  // the terminal does not know this symbol
   TIA_STATUS_NO_TICK,  // the symbol has no last tick
   TIA_STATUS_NO_READ,  // the ticks could not be read
   TIA_STATUS_EMPTY,    // the window holds no tick
   TIA_STATUS_OK        // audited
  };
//--- input parameters
input string           InpSymbols            = "";                // Symbols: empty = chart symbol, * = Market Watch, else CSV list
input int              InpDays               = 3;                 // Days of tick history to audit (ending at the last tick)
input bool             InpCheckQuotes        = true;              // K1: nonpositive / crossed / locked quotes
input bool             InpCheckTimes         = true;              // K2: backwards, repeated and inconsistent timestamps
input bool             InpCheckReversals     = true;              // K3: one-tick price reversals (spikes)
input double           InpReversalMult       = 10.0;              // K3: flag reversals of at least this many median spreads
input double           InpReversalReturnFrac = 0.25;              // K3: max distance back to the start, as a share of the move
input bool             InpCheckSilences      = true;              // K4: gaps between ticks against the quote sessions
input int              InpSilenceSeconds     = 60;                // K4: a silence is a gap longer than this, seconds
input bool             InpCheckBars          = true;              // K5: compare tick high/low with the M1 bars
input int              InpBarTolPoints       = 0;                 // K5: ignore high/low deviations up to this many points
input int              InpChunkMinutes       = 360;               // Ticks are read in chunks of this many minutes
input int              InpMaxExamples        = 5;                 // Journal: example findings printed per check
input bool             InpWriteCsv           = true;              // Write summary, sessions, hours and findings CSV files
input bool             InpShowPanel          = true;              // Draw the result table on the chart
input ENUM_BASE_CORNER InpPanelCorner        = CORNER_LEFT_UPPER; // Panel corner
input int              InpPanelFontSize      = 8;                 // Panel font size
input int              InpPanelX             = 10;                // Panel X offset, px
input int              InpPanelY             = 18;                // Panel Y offset, px
input int              InpRefreshMinutes     = 0;                 // Re-audit every N minutes (0 = audit once)
//--- the inputs as they are used, after the out of range values were clamped
int ExtDays=3;                                     // days of the audit window
int ExtChunkMinutes=360;                           // minutes of one tick request
int ExtSilenceSeconds=60;                          // silence threshold in seconds
int ExtBarTolPoints=0;                             // high/low tolerance in points
//+------------------------------------------------------------------+
//| One shared answer to the question what time it is now. The       |
//| tester has no wall clock, so the refresh must use server time.   |
//+------------------------------------------------------------------+
datetime TiaNow(void)
  {
   return(TimeCurrent());
  }
//+------------------------------------------------------------------+
//| Text aligned in a field of width characters, right aligned for   |
//| numbers. Text that does not fit is kept whole, never cut off.    |
//+------------------------------------------------------------------+
string TiaPad(const string text,const int width,const bool right)
  {
   string out=text;
   while(StringLen(out)<width)
      out=(right ? " "+out : out+" ");
   return(out);
  }
//+------------------------------------------------------------------+
//| Replaces every character a file name may not contain, so that a  |
//| symbol such as US30.cash still gets its own CSV file.            |
//+------------------------------------------------------------------+
string TiaSafeName(const string text)
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
//| A counter as text. Every 64 bit value is converted here, so no   |
//| format string can ever meet a long.                              |
//+------------------------------------------------------------------+
string TiaNum(const long value)
  {
   return(IntegerToString(value));
  }
//+------------------------------------------------------------------+
//| A setting as the shortest decimal text, 10.0 becomes 10 and 0.25 |
//| stays 0.25, so the CSV carries the value that was really used.   |
//+------------------------------------------------------------------+
string TiaDecimal(const double value)
  {
   string text=DoubleToString(value,8);
   int    len=StringLen(text);
   while(len>0 && StringGetCharacter(text,len-1)=='0')
      len--;
   if(len>0 && StringGetCharacter(text,len-1)=='.')
      len--;
   return(StringSubstr(text,0,len));
  }
//+------------------------------------------------------------------+
//| Milliseconds as seconds with three decimals. The value is kept   |
//| in whole milliseconds, so the text is exact and never rounded.   |
//+------------------------------------------------------------------+
string TiaSeconds(const long milliseconds)
  {
   return(DoubleToString(milliseconds/1000.0,3));
  }
//+------------------------------------------------------------------+
//| A millisecond time stamp as server date and time. An empty stamp |
//| becomes a dash, so 1970 can never pass for a measured value.     |
//+------------------------------------------------------------------+
string TiaMscText(const long msc)
  {
   if(msc<=0)
      return("-");
   return(TimeToString((datetime)(msc/1000),TIME_DATE|TIME_SECONDS)+"."+
          StringFormat("%03d",(int)(msc%1000)));
  }
//+------------------------------------------------------------------+
//| One CSV cell. A check that did not run leaves its cell empty: a  |
//| zero written for "not measured" looks exactly like a clean value.|
//+------------------------------------------------------------------+
string TiaCell(const bool measured,const string text)
  {
   return(measured ? text : "");
  }
//+------------------------------------------------------------------+
//| One figure a human reads on the panel or in the journal. A check |
//| that was switched off prints a dash, never a number.             |
//+------------------------------------------------------------------+
string TiaText(const bool measured,const string text)
  {
   return(measured ? text : "-");
  }
//+------------------------------------------------------------------+
//| A price difference in whole points, the unit of every threshold  |
//| of this tool: pts(x) = (long)MathRound(x / SYMBOL_POINT).        |
//+------------------------------------------------------------------+
long TiaPoints(const double value,const double point)
  {
   return((long)MathRound(value/point));
  }
//+------------------------------------------------------------------+
//| Absolute value of a whole number, kept in 64 bits.               |
//+------------------------------------------------------------------+
long TiaAbs(const long value)
  {
   return(value<0 ? -value : value);
  }
//--- names of the checks as written into the check column of the CSV,
//    in the order of ENUM_TIA_CHECK, and the names of the symbol states
string ExtCheckNames[TIA_CHECK_COUNT]= {"nonpositive","crossed","backwards","repeats","time_field",
                                        "reversal","silence","m1_no_ticks","ticks_no_m1","high","low"
                                       };
string ExtStatusNames[6]= {"IDLE","UNKNOWN_SYMBOL","NO_LAST_TICK","READ_FAILED","NO_TICKS","OK"};
//+------------------------------------------------------------------+
//| Width of every table column: the longest cell of the column. The |
//| panel and the journal share it, so both show the same table.     |
//+------------------------------------------------------------------+
void TiaColumnWidths(const string &cells[][TIA_COLS],const int rows,int &widths[])
  {
   for(int c=0; c<TIA_COLS; c++)
     {
      widths[c]=0;
      for(int r=0; r<rows; r++)
         widths[c]=MathMax(widths[c],StringLen(cells[r][c]));
     }
  }
//+------------------------------------------------------------------+
//| One table row as a single text line, the way the journal shows   |
//| it: the first column left aligned, the numbers right aligned.    |
//+------------------------------------------------------------------+
string TiaRowText(const string &cells[][TIA_COLS],const int row,const int &widths[])
  {
   string out="";
   for(int c=0; c<TIA_COLS; c++)
     {
      if(c>0)
         out+="  ";
      out+=TiaPad(cells[row][c],widths[c],c>0);
     }
   return(out);
  }
//+------------------------------------------------------------------+
//| Draws the result table on the chart, one label per table cell,   |
//| because an OBJ_LABEL cuts its text at about 62 characters.       |
//+------------------------------------------------------------------+
class CTiaPanel
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
                     CTiaPanel(void) { Reset(); }
   void              Reset(void);
   bool              Create(void);
   void              Destroy(void);
   void              Update(const string &top[],const string &cells[][TIA_COLS],
                            const int table_rows,const string &bottom[]);
   int               WidthPx(void)  const { return(m_width_px);  }
   int               HeightPx(void) const { return(m_height_px); }
   int               Labels(void)   const { return(m_labels);    }
   int               Widest(void)   const { return(m_widest);    }
  };
//+------------------------------------------------------------------+
//| Back to the starting state. A changed input reinitialises the    |
//| expert without reloading it, so the old geometry is still here.  |
//+------------------------------------------------------------------+
void CTiaPanel::Reset(void)
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
//| Builds the object prefix and the background. The prefix carries  |
//| the chart id and the first free instance index of this chart.    |
//+------------------------------------------------------------------+
bool CTiaPanel::Create(void)
  {
   m_chart=ChartID();
//--- stage: the first instance index that is not used on this chart
   int instance=0;
   for(; instance<15; instance++)
      if(ObjectFind(m_chart,TIA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_bg")<0)
         break;
   m_prefix=TIA_NAME+"_"+IntegerToString(m_chart)+"_"+IntegerToString(instance)+"_";
//--- stage: geometry, points stay points and pixels follow the screen dpi
   double scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   m_font_size  =(int)MathMin(20,MathMax(4,InpPanelFontSize));
   m_pad        =(int)MathRound(6.0*scale);
   m_line_height=(int)MathRound(m_font_size*1.70*scale);
   m_char_width =(int)MathCeil(m_font_size*0.75*scale);
   uint text_width=0,text_height=0;
   TextSetFont(TIA_PANEL_FONT,-m_font_size*10,FW_NORMAL,0);
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
      PrintFormat("%s: the panel background could not be created, error %d, panel off",
                  TIA_NAME,GetLastError());
      return(false);
     }
   ObjectSetInteger(m_chart,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(m_chart,name,OBJPROP_XDISTANCE,m_x);
   ObjectSetInteger(m_chart,name,OBJPROP_YDISTANCE,m_y);
   ObjectSetInteger(m_chart,name,OBJPROP_BGCOLOR,TIA_BACK_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,TIA_BORDER_COLOR);
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
//| Deletes every object of this instance and nothing else: only the |
//| names that carry the own prefix are removed.                     |
//+------------------------------------------------------------------+
void CTiaPanel::Destroy(void)
  {
   if(m_prefix=="")
      return;
   ObjectsDeleteAll(m_chart,m_prefix);
   ChartRedraw(m_chart);
   m_created=false;
   m_labels=0;
  }
//+------------------------------------------------------------------+
//| Draws one label. Start is the column in characters; a text with  |
//| nothing but blanks is not drawn, it would show a placeholder.    |
//+------------------------------------------------------------------+
void CTiaPanel::Place(const int row,const int column,const int start,const string text)
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
   ObjectSetString(m_chart,name,OBJPROP_FONT,TIA_PANEL_FONT);
   ObjectSetInteger(m_chart,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(m_chart,name,OBJPROP_COLOR,TIA_TEXT_COLOR);
   ObjectSetInteger(m_chart,name,OBJPROP_BACK,false);
   ObjectSetInteger(m_chart,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(m_chart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(m_chart,name,OBJPROP_ZORDER,1);
   ObjectSetString(m_chart,name,OBJPROP_TEXT,text);
   m_labels++;
  }
//+------------------------------------------------------------------+
//| Redraws the panel: free text lines above and below the table,    |
//| each cut into label sized pieces, and one label per table cell.  |
//+------------------------------------------------------------------+
void CTiaPanel::Update(const string &top[],const string &cells[][TIA_COLS],
                       const int table_rows,const string &bottom[])
  {
   if(!m_created)
      return;
//--- stage: where every table column starts, in characters
   int widths[TIA_COLS];
   int starts[TIA_COLS];
   TiaColumnWidths(cells,table_rows,widths);
   int table_width=0;
   for(int c=0; c<TIA_COLS; c++)
     {
      starts[c]=table_width;
      table_width+=widths[c]+(c<TIA_COLS-1 ? 2 : 0);
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
//--- stage: the labels, row by row
   int row=0;
   for(int i=0; i<top_count; i++,row++)
      for(int piece=0; piece*TIA_MAX_LABEL<StringLen(top[i]); piece++)
         Place(row,piece,piece*TIA_MAX_LABEL,StringSubstr(top[i],piece*TIA_MAX_LABEL,TIA_MAX_LABEL));
   for(int r=0; r<table_rows; r++,row++)
      for(int c=0; c<TIA_COLS; c++)
         Place(row,c,starts[c],TiaPad(cells[r][c],widths[c],c>0));
   for(int i=0; i<bottom_count; i++,row++)
      for(int piece=0; piece*TIA_MAX_LABEL<StringLen(bottom[i]); piece++)
         Place(row,piece,piece*TIA_MAX_LABEL,StringSubstr(bottom[i],piece*TIA_MAX_LABEL,TIA_MAX_LABEL));
//--- stage: background size, measured from the text that was just drawn
   m_width_px =2*m_pad+m_widest*m_char_width;
   m_height_px=2*m_pad+m_rows*m_line_height;
   ObjectSetInteger(m_chart,m_prefix+"bg",OBJPROP_XSIZE,m_width_px);
   ObjectSetInteger(m_chart,m_prefix+"bg",OBJPROP_YSIZE,m_height_px);
   ChartRedraw(m_chart);
  }
//+------------------------------------------------------------------+
//| Writes the results: example lines in the journal, one findings   |
//| file per pass and the summary, sessions and hours file of every  |
//| audited symbol. A file that cannot be opened stays off alone.    |
//+------------------------------------------------------------------+
class CTiaReport
  {
private:
   string            m_prefix;            // file name prefix of one pass
   int               m_findings_handle;   // one row per finding, one file per pass
   string            m_findings_name;     // path of the findings file
   string            m_pending[];         // rows of the symbol being audited
   int               m_pending_count;     // rows waiting in m_pending
   long              m_seen;              // findings handed to this object
   long              m_rows;              // findings rows written to the file
   long              m_dropped;           // findings not written because of the row guard
   int               m_files;             // per symbol files written in this pass
   int               m_examples[TIA_CHECK_COUNT]; // example lines printed per check

   void              DropEarlierFiles(void);

public:
                     CTiaReport(void) : m_findings_handle(INVALID_HANDLE) { Reset(); }
   void              Reset(void);
   void              Open(const string prefix);
   void              Close(void);
   void              Finding(const string symbol,const ENUM_TIA_CHECK check,const long time_msc,
                             const string value1,const string value2,const string detail);
   long              Commit(void);
   void              Discard(void);
   bool              WriteTable(const string symbol,const string kind,const string header,
                                const string &rows[],const int count);
   bool              FindingsOn(void)   const { return(m_findings_handle!=INVALID_HANDLE); }
   long              Seen(void)         const { return(m_seen);          }
   long              Rows(void)         const { return(m_rows);          }
   long              Dropped(void)      const { return(m_dropped);       }
   int               Files(void)        const { return(m_files);         }
   string            FindingsName(void) const { return(m_findings_name); }
  };
//+------------------------------------------------------------------+
//| Every counter and name back to its starting value, otherwise a   |
//| second pass would add its rows to the counters of the first one. |
//+------------------------------------------------------------------+
void CTiaReport::Reset(void)
  {
   m_prefix="";
   m_findings_name="";
   ArrayFree(m_pending);
   m_pending_count=0;
   m_seen=0;
   m_rows=0;
   m_dropped=0;
   m_files=0;
   ArrayInitialize(m_examples,0);
  }
//+------------------------------------------------------------------+
//| Removes the files an earlier pass wrote under the same prefix,   |
//| so the folder always holds one coherent pass and never a summary |
//| of a symbol whose findings rows belong to another pass.          |
//+------------------------------------------------------------------+
void CTiaReport::DropEarlierFiles(void)
  {
   string names[];
   string found="";
   int    count=0;
   long   search=FileFindFirst(TIA_FOLDER+"\\"+m_prefix+"_*",found);
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
      if(FileDelete(TIA_FOLDER+"\\"+names[i]))
         removed++;
   if(count>0)
      PrintFormat("%s: %d of %d file(s) of an earlier pass with the prefix %s were removed",
                  TIA_NAME,removed,count,m_prefix);
  }
//+------------------------------------------------------------------+
//| Opens the findings file of one pass. The prefix carries the      |
//| chart id, so two copies of the tool never share a file.          |
//+------------------------------------------------------------------+
void CTiaReport::Open(const string prefix)
  {
   m_prefix=prefix;
   if(!InpWriteCsv)
      return;
   DropEarlierFiles();
   m_findings_name=TIA_FOLDER+"\\"+prefix+"_findings.csv";
   ResetLastError();
   m_findings_handle=FileOpen(m_findings_name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(m_findings_handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",
                  TIA_NAME,m_findings_name,GetLastError());
      m_findings_name="";
      return;
     }
   FileWriteString(m_findings_handle,"symbol;check;time_msc;time;value1;value2;detail\r\n");
  }
//+------------------------------------------------------------------+
//| Closes the findings file. It may be called twice without harm.   |
//+------------------------------------------------------------------+
void CTiaReport::Close(void)
  {
   if(m_findings_handle!=INVALID_HANDLE)
     {
      FileClose(m_findings_handle);
      m_findings_handle=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Takes one finding: it is counted, printed while the example      |
//| budget of its check lasts and kept until the symbol is complete. |
//+------------------------------------------------------------------+
void CTiaReport::Finding(const string symbol,const ENUM_TIA_CHECK check,const long time_msc,
                         const string value1,const string value2,const string detail)
  {
   m_seen++;
//--- stage: example line in the journal, limited per check
   int slot=(int)check;
   if(slot>=0 && slot<TIA_CHECK_COUNT && m_examples[slot]<InpMaxExamples)
     {
      m_examples[slot]++;
      PrintFormat("%s: %s example %d of %d: %s %s value1 %s value2 %s, %s",TIA_NAME,
                  ExtCheckNames[(int)check],m_examples[slot],InpMaxExamples,symbol,
                  TiaMscText(time_msc),value1,value2,detail);
     }
//--- stage: the row waits until the symbol is complete, so a symbol that
//    fails halfway can never leave rows in the file
   if(m_findings_handle==INVALID_HANDLE)
      return;
   if(m_rows+m_pending_count>=TIA_MAX_CSV_ROWS)
     {
      if(m_dropped==0)
         PrintFormat("%s: the findings file reached its guard of %d rows, further findings are only counted",
                     TIA_NAME,TIA_MAX_CSV_ROWS);
      m_dropped++;
      return;
     }
   if(m_pending_count>=ArraySize(m_pending))
      ArrayResize(m_pending,m_pending_count+1,4096);
   m_pending[m_pending_count++]=symbol+TIA_SEP+ExtCheckNames[(int)check]+TIA_SEP+TiaNum(time_msc)+TIA_SEP+
                                TiaMscText(time_msc)+TIA_SEP+value1+TIA_SEP+value2+TIA_SEP+detail;
  }
//+------------------------------------------------------------------+
//| Writes the rows of the symbol that just completed and returns    |
//| how many rows it wrote.                                          |
//+------------------------------------------------------------------+
long CTiaReport::Commit(void)
  {
   long written=0;
   if(m_findings_handle!=INVALID_HANDLE)
     {
      for(int i=0; i<m_pending_count; i++)
        {
         FileWriteString(m_findings_handle,m_pending[i]+"\r\n");
         written++;
        }
      FileFlush(m_findings_handle);
     }
   m_rows+=written;
   Discard();
   return(written);
  }
//+------------------------------------------------------------------+
//| Forgets the rows of a symbol that could not be completed.        |
//+------------------------------------------------------------------+
void CTiaReport::Discard(void)
  {
   m_pending_count=0;
   ArrayResize(m_pending,0,4096);
  }
//+------------------------------------------------------------------+
//| Writes one per symbol file in one go: a header and its rows. A   |
//| failure costs this one file and is reported with its error code. |
//+------------------------------------------------------------------+
bool CTiaReport::WriteTable(const string symbol,const string kind,const string header,
                            const string &rows[],const int count)
  {
   if(!InpWriteCsv)
      return(false);
   string name=TIA_FOLDER+"\\"+m_prefix+"_"+TiaSafeName(symbol)+"_"+kind+".csv";
   ResetLastError();
   int handle=FileOpen(name,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("%s: file %s could not be opened, error %d, this file stays off",
                  TIA_NAME,name,GetLastError());
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
//| Audits the ticks of one symbol over [T0, T1). The ticks are read |
//| chunk by chunk and the previous tick is carried across chunks,   |
//| so the chunk size can never change a single counter.             |
//+------------------------------------------------------------------+
class CTiaSymbolAudit
  {
private:
   string            m_symbol;            // symbol under audit
   ENUM_TIA_STATUS   m_status;            // what happened to this symbol
   int               m_digits;            // digits of this symbol
   double            m_point;             // point of this symbol, not of the chart
   bool              m_mode_last;         // chart price is the last price, not the bid
   long              m_t0;                // window start, milliseconds, inclusive
   long              m_t1;                // window end, milliseconds, exclusive
   int               m_minutes;           // minutes of the window
   //--- quote sessions, 0 = Sunday
   int               m_sessions_found;    // sessions the symbol reports
   int               m_sess_from[7*TIA_MAX_SESSIONS]; // session start, seconds of the day
   int               m_sess_to[7*TIA_MAX_SESSIONS];   // session end, seconds of the day
   int               m_sess_count[7];     // sessions per weekday
   //--- reading
   MqlTick           m_ticks[];           // the one chunk held in memory
   long              m_chunks;            // tick requests made in the second pass
   long              m_retries;           // repeated tick requests
   long              m_outside;           // delivered ticks outside the requested chunk
   int               m_read_error;        // error of the request that failed
   long              m_pass1_ticks;       // ticks seen by the spread pass
   //--- the previous tick, carried across chunks
   bool              m_have_prev;         // a previous tick exists in the window
   long              m_prev_msc;          // its time in milliseconds
   double            m_prev_bid;          // its bid
   double            m_prev_ask;          // its ask
   double            m_prev_price;        // its chart price
   //--- every check
   long              m_ticks_total;       // ticks in the window
   long              m_ticks_change;      // price changing ticks
   long              m_findings;          // findings handed to the report
   long              m_rows_written;      // findings rows the file received
   //--- K1 quotes
   long              m_nonpositive;       // bid or ask not above zero
   long              m_crossed;           // ask below bid
   long              m_locked;            // ask equal to bid, a count only
   //--- K2 time stamps
   long              m_backwards;         // time goes back
   long              m_repeats;           // same millisecond, bid and ask
   long              m_time_field;        // time differs from time_msc/1000
   //--- K3 reversals
   int               m_hist[];            // spread histogram, one cell per point
   long              m_over[];            // spreads beyond the histogram
   int               m_over_count;        // values in m_over
   long              m_spread_n;          // quotes in the spread median
   long              m_median_raw;        // lower median of the spread, before the floor of 1
   long              m_s;                 // S, the median spread used, at least 1
   long              m_rev_total;         // reversals of any size
   long              m_rev_ge2;           // reversals of at least 2 S
   long              m_rev_ge5;           // reversals of at least 5 S
   long              m_rev_ge10;          // reversals of at least 10 S
   long              m_rev_ge20;          // reversals of at least 20 S
   long              m_rev_flagged;       // reversals of at least InpReversalMult S
   long              m_rev_max;           // largest reversal size in points
   int               m_seq_count;         // price changing ticks in the sequence, up to 2
   double            m_seq_p0;            // price two changes back
   double            m_seq_p1;            // price one change back
   long              m_seq_t1;            // time of m_seq_p1
   //--- K4 silences
   long              m_sil_total;         // gaps above the threshold
   long              m_sil_explained;     // at least one sample outside the sessions
   long              m_sil_unexplained;   // every sample inside a session
   long              m_sil_unclassified;  // the symbol has no session record
   long              m_sil_unexpl_ms;     // length of the unexplained silences
   long              m_sil_max_ms;        // longest unexplained silence
   long              m_sil_max_start;     // time of the tick before it
   //--- K5 ticks against M1 bars
   string            m_k5_state;          // on, off or why it could not run
   MqlRates          m_rates[];           // M1 bars of the window
   double            m_min_high[];        // highest chart price per minute
   double            m_min_low[];         // lowest chart price per minute
   uchar             m_min_has[];         // the minute has a tick with a price above zero
   int               m_min_bar[];         // index of the M1 bar of the minute, -1 = none
   long              m_m1_bars;           // M1 bars inside the window
   long              m_tick_minutes;      // minutes with a tick with a price above zero
   long              m_compared;          // minutes with ticks and a bar
   long              m_m1_no_ticks;       // bars without ticks
   long              m_ticks_no_m1;       // ticks without a bar
   long              m_high_mismatch;     // high deviates more than the tolerance
   long              m_low_mismatch;      // low deviates more than the tolerance
   long              m_bar_max_dev;       // largest high or low deviation in points
   //--- server hour profile
   long              m_h_ticks[24];       // ticks per hour
   long              m_h_sil[24];         // unexplained silences per hour of the start
   long              m_h_sil_ms[24];      // their length per hour of the start
   long              m_h_rev[24];         // flagged reversals per hour of p1

   bool              K5On(void) const { return(m_k5_state=="on"); }
   void              LoadSessions(void);
   bool              InSession(const long moment) const;
   int               ReadChunk(const long from,const long to);
   bool              Walk(const int pass,CTiaReport &report);
   void              SpreadTick(const MqlTick &tick);
   void              Median(void);
   void              CheckTick(const MqlTick &tick,CTiaReport &report);
   void              Reversal(const double price,const long time_msc,CTiaReport &report);
   void              Silence(const long start,const long finish,CTiaReport &report);
   void              LoadBars(void);
   void              CompareBars(CTiaReport &report);
   void              Found(CTiaReport &report,const ENUM_TIA_CHECK check,const long time_msc,
                           const string value1,const string value2,const string detail);
   string            Price(const double value) const { return(DoubleToString(value,m_digits)); }
   string            SessionsText(void) const;

public:
                     CTiaSymbolAudit(void) { Reset(); }
   void              Reset(void);
   void              SetSymbol(const string symbol);
   bool              Prepare(void);
   bool              Audit(CTiaReport &report);
   void              SetRowsWritten(const long rows) { m_rows_written=rows; }
   void              WriteFiles(CTiaReport &report) const;
   void              PrintDetail(void) const;
   void              Cells(string &cells[][TIA_COLS],const int row) const;
   static void       HeaderCells(string &cells[][TIA_COLS],const int row);
   string            Name(void)          const { return(m_symbol);      }
   ENUM_TIA_STATUS   Status(void)        const { return(m_status);      }
   long              TicksTotal(void)    const { return(m_ticks_total); }
   long              Findings(void)      const { return(m_findings);    }
   long              FindingsSum(void)   const;
  };
//+------------------------------------------------------------------+
//| Every counter, flag, text and buffer back to its starting value. |
//| An expert is not reloaded when an input changes, so a new pass   |
//| would carry the old numbers without this (pitfall C24).          |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Reset(void)
  {
   m_symbol="";
   m_status=TIA_STATUS_IDLE;
   m_digits=0;
   m_point=0.0;
   m_mode_last=false;
   m_t0=0;
   m_t1=0;
   m_minutes=0;
   m_sessions_found=0;
   ArrayInitialize(m_sess_from,0);
   ArrayInitialize(m_sess_to,0);
   ArrayInitialize(m_sess_count,0);
   ArrayFree(m_ticks);
   m_chunks=0;
   m_retries=0;
   m_outside=0;
   m_read_error=0;
   m_pass1_ticks=0;
   m_have_prev=false;
   m_prev_msc=0;
   m_prev_bid=0.0;
   m_prev_ask=0.0;
   m_prev_price=0.0;
   m_ticks_total=0;
   m_ticks_change=0;
   m_findings=0;
   m_rows_written=0;
   m_nonpositive=0;
   m_crossed=0;
   m_locked=0;
   m_backwards=0;
   m_repeats=0;
   m_time_field=0;
   ArrayFree(m_hist);
   ArrayFree(m_over);
   m_over_count=0;
   m_spread_n=0;
   m_median_raw=0;
   m_s=1;
   m_rev_total=0;
   m_rev_ge2=0;
   m_rev_ge5=0;
   m_rev_ge10=0;
   m_rev_ge20=0;
   m_rev_flagged=0;
   m_rev_max=0;
   m_seq_count=0;
   m_seq_p0=0.0;
   m_seq_p1=0.0;
   m_seq_t1=0;
   m_sil_total=0;
   m_sil_explained=0;
   m_sil_unexplained=0;
   m_sil_unclassified=0;
   m_sil_unexpl_ms=0;
   m_sil_max_ms=0;
   m_sil_max_start=0;
   m_k5_state="off";
   ArrayFree(m_rates);
   ArrayFree(m_min_high);
   ArrayFree(m_min_low);
   ArrayFree(m_min_has);
   ArrayFree(m_min_bar);
   m_m1_bars=0;
   m_tick_minutes=0;
   m_compared=0;
   m_m1_no_ticks=0;
   m_ticks_no_m1=0;
   m_high_mismatch=0;
   m_low_mismatch=0;
   m_bar_max_dev=0;
   ArrayInitialize(m_h_ticks,0);
   ArrayInitialize(m_h_sil,0);
   ArrayInitialize(m_h_sil_ms,0);
   ArrayInitialize(m_h_rev,0);
  }
//+------------------------------------------------------------------+
//| Clears the object and names the symbol of the next audit.        |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::SetSymbol(const string symbol)
  {
   Reset();
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//| The identity of the findings: the sum of the eleven counters     |
//| that each produce one row. A check that did not run adds zero.   |
//+------------------------------------------------------------------+
long CTiaSymbolAudit::FindingsSum(void) const
  {
   return(m_nonpositive+m_crossed+m_backwards+m_repeats+m_time_field+m_rev_flagged+
          m_sil_unexplained+m_m1_no_ticks+m_ticks_no_m1+m_high_mismatch+m_low_mismatch);
  }
//+------------------------------------------------------------------+
//| Fixes the window of this symbol: T1 is the time of the last tick |
//| floored to the minute and T0 lies InpDays before it. It runs for |
//| every symbol at the start of a pass, so a pass is one snapshot.  |
//+------------------------------------------------------------------+
bool CTiaSymbolAudit::Prepare(void)
  {
//--- stage: does the terminal know this symbol at all
   double point=0.0;
   ResetLastError();
   if(!SymbolInfoDouble(m_symbol,SYMBOL_POINT,point) || point<=0.0)
     {
      m_status=TIA_STATUS_UNKNOWN;
      PrintFormat("%s: %s is not a symbol of this terminal (error %d), it is skipped",
                  TIA_NAME,m_symbol,GetLastError());
      return(false);
     }
   m_point=point;
   m_digits=(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS);
   m_mode_last=(SymbolInfoInteger(m_symbol,SYMBOL_CHART_MODE)==SYMBOL_CHART_MODE_LAST);
//--- stage: the window ends at the last real tick, not at the wall clock,
//    so it also works on a weekend
   MqlTick last;
   ResetLastError();
   if(!SymbolInfoTick(m_symbol,last) || last.time_msc<=0)
     {
      m_status=TIA_STATUS_NO_TICK;
      PrintFormat("%s: %s has no last tick (error %d), it is skipped",TIA_NAME,m_symbol,GetLastError());
      return(false);
     }
   m_t1=(last.time_msc/60000)*60000;
   m_t0=m_t1-(long)ExtDays*86400000;
   m_minutes=ExtDays*1440;
   return(true);
  }
//+------------------------------------------------------------------+
//| Reads the quote session table into the own arrays. Python cannot |
//| read SymbolInfoSessionQuote, so the table is also dumped to CSV. |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::LoadSessions(void)
  {
   m_sessions_found=0;
   for(int day=0; day<7; day++)
     {
      m_sess_count[day]=0;
      for(int index=0; index<TIA_MAX_SESSIONS; index++)
        {
         datetime from=0,to=0;
         if(!SymbolInfoSessionQuote(m_symbol,(ENUM_DAY_OF_WEEK)day,(uint)index,from,to))
            break;
         int slot=day*TIA_MAX_SESSIONS+m_sess_count[day];
         m_sess_from[slot]=(int)from;
         m_sess_to[slot]=(int)to;
         m_sess_count[day]++;
         m_sessions_found++;
        }
     }
  }
//+------------------------------------------------------------------+
//| The session predicate, character for character the one of the    |
//| independent verifier: secs = t % 86400 and for every session of  |
//| the weekday: from <= secs < max(to, from+1) OR (to >= 86400 AND  |
//| secs >= from).                                                   |
//+------------------------------------------------------------------+
bool CTiaSymbolAudit::InSession(const long moment) const
  {
   int day=(int)((moment/86400+4)%7);
   int secs=(int)(moment%86400);
   for(int index=0; index<m_sess_count[day]; index++)
     {
      int slot=day*TIA_MAX_SESSIONS+index;
      int from=m_sess_from[slot];
      int to=m_sess_to[slot];
      if(secs>=from && secs<MathMax(to,from+1))
         return(true);
      if(to>=86400 && secs>=from)
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Reads the ticks of [from, to], to inclusive, into the chunk      |
//| buffer. A live chart retries -1 and the not-ready errors; the    |
//| tester tries once. Ticks outside the chunk are dropped, so no    |
//| tick can ever be counted in two chunks.                          |
//+------------------------------------------------------------------+
int CTiaSymbolAudit::ReadChunk(const long from,const long to)
  {
   int attempts=(MQLInfoInteger(MQL_TESTER)!=0 ? 1 : TIA_RETRIES);
   int got=-1;
   int error=0;
   for(int attempt=1; attempt<=attempts; attempt++)
     {
      ResetLastError();
      got=CopyTicksRange(m_symbol,m_ticks,COPY_TICKS_ALL,(ulong)from,(ulong)to);
      error=GetLastError();
      //--- 4401 = not found yet, 4403 = the synchronisation timed out and
      //    the answer may be partial; both are worth one more attempt
      if(got>=0 && error!=ERR_HISTORY_NOT_FOUND && error!=ERR_HISTORY_TIMEOUT)
         break;
      if(attempt<attempts)
        {
         m_retries++;
         Sleep(TIA_RETRY_MS);
        }
     }
   if(got<0 || error==ERR_HISTORY_NOT_FOUND || error==ERR_HISTORY_TIMEOUT)
     {
      m_read_error=error;
      return(-1);
     }
//--- stage: keep only the ticks of the chunk itself
   int kept=0;
   for(int i=0; i<got; i++)
     {
      if(m_ticks[i].time_msc<from || m_ticks[i].time_msc>to)
        {
         m_outside++;
         continue;
        }
      if(kept!=i)
         m_ticks[kept]=m_ticks[i];
      kept++;
     }
   return(kept);
  }
//+------------------------------------------------------------------+
//| One walk over the window, chunk after chunk. Pass 1 builds the   |
//| spread histogram, pass 2 runs the checks.                        |
//+------------------------------------------------------------------+
bool CTiaSymbolAudit::Walk(const int pass,CTiaReport &report)
  {
   long chunk_ms=(long)ExtChunkMinutes*60000;
   for(long from=m_t0; from<m_t1; from+=chunk_ms)
     {
      long to=(from+chunk_ms<m_t1 ? from+chunk_ms : m_t1)-1;
      int  got=ReadChunk(from,to);
      if(got<0)
        {
         m_status=TIA_STATUS_NO_READ;
         PrintFormat("%s: %s ticks %s to %s could not be read (error %d), the symbol is skipped",
                     TIA_NAME,m_symbol,TiaMscText(from),TiaMscText(to),m_read_error);
         return(false);
        }
      if(pass==2)
         m_chunks++;
      for(int i=0; i<got; i++)
        {
         if(pass==1)
            SpreadTick(m_ticks[i]);
         else
            CheckTick(m_ticks[i],report);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Pass 1: one quote into the spread histogram. Only quotes with    |
//| bid > 0, ask > 0 and ask >= bid enter the median.                |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::SpreadTick(const MqlTick &tick)
  {
   m_pass1_ticks++;
   if(tick.bid<=0.0 || tick.ask<=0.0 || tick.ask<tick.bid)
      return;
   long spread=TiaPoints(tick.ask-tick.bid,m_point);
   m_spread_n++;
   if(spread<TIA_HIST_SIZE)
     {
      m_hist[(int)spread]++;
      return;
     }
   if(m_over_count>=ArraySize(m_over))
      ArrayResize(m_over,m_over_count+1,1024);
   m_over[m_over_count++]=spread;
  }
//+------------------------------------------------------------------+
//| The lower median of the spread: the sorted element at index      |
//| (n-1)/2, read from the histogram. S is at least one point.       |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Median(void)
  {
   m_median_raw=0;
   if(m_spread_n>0)
     {
      long target=(m_spread_n-1)/2;
      long seen=0;
      bool found=false;
      for(int value=0; value<TIA_HIST_SIZE && !found; value++)
        {
         seen+=m_hist[value];
         if(seen>target)
           {
            m_median_raw=value;
            found=true;
           }
        }
      if(!found && m_over_count>0)
        {
         ArrayResize(m_over,m_over_count);
         ArraySort(m_over);
         m_median_raw=m_over[(int)(target-seen)];
        }
     }
   m_s=(m_median_raw<1 ? 1 : m_median_raw);
  }
//+------------------------------------------------------------------+
//| Hands one finding to the report and counts it. The count is the  |
//| left side of the identity, the check counters are the right one. |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Found(CTiaReport &report,const ENUM_TIA_CHECK check,const long time_msc,
                            const string value1,const string value2,const string detail)
  {
   m_findings++;
   report.Finding(m_symbol,check,time_msc,value1,value2,detail);
  }
//+------------------------------------------------------------------+
//| Pass 2: every check of one tick. The previous tick state is a    |
//| member, so the first tick of a chunk still sees the last tick of |
//| the chunk before it.                                             |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::CheckTick(const MqlTick &tick,CTiaReport &report)
  {
   m_ticks_total++;
   long seconds=tick.time_msc/1000;
   m_h_ticks[(int)((seconds%86400)/3600)]++;
   double price=(m_mode_last ? tick.last : tick.bid);
//--- K1: quotes
   if(InpCheckQuotes)
     {
      if(tick.bid<=0.0 || tick.ask<=0.0)
        {
         m_nonpositive++;
         Found(report,TIA_NONPOSITIVE,tick.time_msc,Price(tick.bid),Price(tick.ask),
               "bid or ask is not above zero");
        }
      else
        {
         if(tick.ask<tick.bid)
           {
            m_crossed++;
            Found(report,TIA_CROSSED,tick.time_msc,Price(tick.bid),Price(tick.ask),
                  "ask below bid by "+TiaNum(TiaPoints(tick.bid-tick.ask,m_point))+" points");
           }
         else
            if(tick.ask==tick.bid)
               m_locked++;
        }
     }
//--- K2: time stamps
   if(InpCheckTimes)
     {
      if(m_have_prev && tick.time_msc<m_prev_msc)
        {
         m_backwards++;
         Found(report,TIA_BACKWARDS,tick.time_msc,TiaNum(tick.time_msc),TiaNum(m_prev_msc),
               "time goes back by "+TiaNum(m_prev_msc-tick.time_msc)+" ms");
        }
      if(m_have_prev && tick.time_msc==m_prev_msc && tick.bid==m_prev_bid && tick.ask==m_prev_ask)
        {
         m_repeats++;
         Found(report,TIA_REPEATS,tick.time_msc,Price(tick.bid),Price(tick.ask),
               "same millisecond bid and ask as the previous tick");
        }
      if((long)tick.time!=seconds)
        {
         m_time_field++;
         Found(report,TIA_TIME_FIELD,tick.time_msc,TiaNum((long)tick.time),TiaNum(seconds),
               "time differs from time_msc/1000");
        }
     }
//--- K4: silences, only between ticks whose time does not go back
   if(InpCheckSilences && m_have_prev && tick.time_msc>=m_prev_msc &&
      tick.time_msc-m_prev_msc>(long)ExtSilenceSeconds*1000)
      Silence(m_prev_msc,tick.time_msc,report);
//--- K3: the sequence of price changing ticks
   if(!m_have_prev || price!=m_prev_price)
     {
      m_ticks_change++;
      if(InpCheckReversals)
         Reversal(price,tick.time_msc,report);
     }
//--- K5: high and low of every tick with a price above zero, per minute
   if(K5On() && price>0.0)
     {
      int minute=(int)(tick.time_msc/60000-m_t0/60000);
      if(minute>=0 && minute<m_minutes)
        {
         if(m_min_has[minute]==0)
           {
            m_min_has[minute]=1;
            m_min_high[minute]=price;
            m_min_low[minute]=price;
           }
         else
           {
            if(price>m_min_high[minute])
               m_min_high[minute]=price;
            if(price<m_min_low[minute])
               m_min_low[minute]=price;
           }
        }
     }
//--- the previous tick of the next one, also across a chunk border
   m_have_prev=true;
   m_prev_msc=tick.time_msc;
   m_prev_bid=tick.bid;
   m_prev_ask=tick.ask;
   m_prev_price=price;
  }
//+------------------------------------------------------------------+
//| K3 on the sequence p0, p1, p2 of price changing ticks: a         |
//| reversal when d1 and d2 have opposite signs and the price comes  |
//| back to within InpReversalReturnFrac x size of p0.               |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Reversal(const double price,const long time_msc,CTiaReport &report)
  {
   if(m_seq_count>=2)
     {
      long d1=TiaPoints(m_seq_p1-m_seq_p0,m_point);
      long d2=TiaPoints(price-m_seq_p1,m_point);
      if((d1>0 && d2<0) || (d1<0 && d2>0))
        {
         long size=MathMin(TiaAbs(d1),TiaAbs(d2));
         long back=TiaAbs(TiaPoints(price-m_seq_p0,m_point));
         if((double)back<=InpReversalReturnFrac*(double)size)
           {
            m_rev_total++;
            if(size>m_rev_max)
               m_rev_max=size;
            if(size>=2*m_s)
               m_rev_ge2++;
            if(size>=5*m_s)
               m_rev_ge5++;
            if(size>=10*m_s)
               m_rev_ge10++;
            if(size>=20*m_s)
               m_rev_ge20++;
            if((double)size>=InpReversalMult*(double)m_s)
              {
               m_rev_flagged++;
               m_h_rev[(int)((m_seq_t1/1000%86400)/3600)]++;
               Found(report,TIA_REVERSAL,m_seq_t1,TiaNum(size),TiaNum(back),
                     "p0 "+Price(m_seq_p0)+" p1 "+Price(m_seq_p1)+" p2 "+Price(price)+
                     " d1 "+TiaNum(d1)+" d2 "+TiaNum(d2)+" S "+TiaNum(m_s));
              }
           }
        }
     }
//--- slide the window of three prices by one
   m_seq_p0=m_seq_p1;
   m_seq_p1=price;
   m_seq_t1=time_msc;
   if(m_seq_count<2)
      m_seq_count++;
  }
//+------------------------------------------------------------------+
//| K4: classifies one gap. The samples are p, p+60, ... below c and |
//| c itself, in seconds; one sample outside every quote session of  |
//| its weekday explains the gap. No session record: unclassified.   |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Silence(const long start,const long finish,CTiaReport &report)
  {
   m_sil_total++;
   if(m_sessions_found<=0)
     {
      m_sil_unclassified++;
      return;
     }
   long p=start/1000;
   long c=finish/1000;
   bool explained=!InSession(c);
   for(long t=p; t<c && !explained; t+=60)
      if(!InSession(t))
         explained=true;
   if(explained)
     {
      m_sil_explained++;
      return;
     }
   long gap=finish-start;
   int  hour=(int)((p%86400)/3600);
   m_sil_unexplained++;
   m_sil_unexpl_ms+=gap;
   m_h_sil[hour]++;
   m_h_sil_ms[hour]+=gap;
   if(gap>m_sil_max_ms)
     {
      m_sil_max_ms=gap;
      m_sil_max_start=start;
     }
   Found(report,TIA_SILENCE,start,TiaSeconds(gap),TiaNum(finish),
         "no tick inside the quote sessions until "+TiaMscText(finish));
  }
//+------------------------------------------------------------------+
//| K5: copies the M1 bars of the window and maps every bar to its   |
//| minute. A failure switches K5 off for this symbol with a reason. |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::LoadBars(void)
  {
   if(!InpCheckBars)
     {
      m_k5_state="off";
      return;
     }
   int attempts=(MQLInfoInteger(MQL_TESTER)!=0 ? 1 : TIA_RETRIES);
   int got=-1;
   int error=0;
   for(int attempt=1; attempt<=attempts && got<0; attempt++)
     {
      ResetLastError();
      got=CopyRates(m_symbol,PERIOD_M1,(datetime)(m_t0/1000),(datetime)(m_t1/1000-1),m_rates);
      error=GetLastError();
      if(got<0 && attempt<attempts)
         Sleep(TIA_RETRY_MS);
     }
   if(got<0)
     {
      m_k5_state="off, no M1 bars (error "+IntegerToString(error)+")";
      PrintFormat("%s: %s delivered no M1 bar (error %d), K5 is skipped for this symbol",
                  TIA_NAME,m_symbol,error);
      return;
     }
   ArrayResize(m_min_high,m_minutes);
   ArrayResize(m_min_low,m_minutes);
   ArrayResize(m_min_has,m_minutes);
   ArrayResize(m_min_bar,m_minutes);
   ArrayInitialize(m_min_high,0.0);
   ArrayInitialize(m_min_low,0.0);
   ArrayInitialize(m_min_has,0);
   ArrayInitialize(m_min_bar,-1);
   long first=m_t0/1000;
   long last=m_t1/1000;
   for(int i=0; i<got; i++)
     {
      long open=(long)m_rates[i].time;
      if(open<first || open>=last)
         continue;
      m_m1_bars++;
      m_min_bar[(int)((open-first)/60)]=i;
     }
   m_k5_state="on";
  }
//+------------------------------------------------------------------+
//| K5: walks the minutes in time order and compares the tick high   |
//| and low with the M1 bar of the same minute.                      |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::CompareBars(CTiaReport &report)
  {
   if(!K5On())
      return;
   for(int minute=0; minute<m_minutes; minute++)
     {
      long stamp=m_t0+(long)minute*60000;
      bool ticks=(m_min_has[minute]!=0);
      int  bar=m_min_bar[minute];
      if(ticks)
         m_tick_minutes++;
      if(bar>=0 && !ticks)
        {
         m_m1_no_ticks++;
         Found(report,TIA_M1_NO_TICKS,stamp,Price(m_rates[bar].high),Price(m_rates[bar].low),
               "M1 bar without a tick, the tester will invent ticks here");
         continue;
        }
      if(bar<0 && ticks)
        {
         m_ticks_no_m1++;
         Found(report,TIA_TICKS_NO_M1,stamp,Price(m_min_high[minute]),Price(m_min_low[minute]),
               "ticks without an M1 bar");
         continue;
        }
      if(bar<0)
         continue;
      m_compared++;
      long dev_high=TiaAbs(TiaPoints(m_rates[bar].high-m_min_high[minute],m_point));
      long dev_low =TiaAbs(TiaPoints(m_rates[bar].low-m_min_low[minute],m_point));
      m_bar_max_dev=MathMax(m_bar_max_dev,MathMax(dev_high,dev_low));
      if(dev_high>ExtBarTolPoints)
        {
         m_high_mismatch++;
         Found(report,TIA_HIGH,stamp,Price(m_rates[bar].high),Price(m_min_high[minute]),
               "bar high and tick high differ by "+TiaNum(dev_high)+" points");
        }
      if(dev_low>ExtBarTolPoints)
        {
         m_low_mismatch++;
         Found(report,TIA_LOW,stamp,Price(m_rates[bar].low),Price(m_min_low[minute]),
               "bar low and tick low differ by "+TiaNum(dev_low)+" points");
        }
     }
  }
//+------------------------------------------------------------------+
//| Audits the symbol. Every failure is one journal line and a       |
//| status; the findings of a failed symbol are discarded by the     |
//| caller, so no file can hold half an audit.                       |
//+------------------------------------------------------------------+
bool CTiaSymbolAudit::Audit(CTiaReport &report)
  {
   if(m_status!=TIA_STATUS_IDLE)
      return(false);
   LoadSessions();
   LoadBars();
//--- stage: pass 1, the median spread S that sizes the reversals
   if(InpCheckReversals)
     {
      ArrayResize(m_hist,TIA_HIST_SIZE);
      ArrayInitialize(m_hist,0);
      bool read=Walk(1,report);
      Median();
      ArrayFree(m_hist);
      ArrayFree(m_over);
      if(!read)
        {
         ArrayFree(m_ticks);
         return(false);
        }
     }
//--- stage: pass 2, every check
   bool read=Walk(2,report);
   ArrayFree(m_ticks);
   if(!read)
      return(false);
   if(m_ticks_total==0)
     {
      m_status=TIA_STATUS_EMPTY;
      PrintFormat("%s: %s has no tick between %s and %s, the symbol is skipped",
                  TIA_NAME,m_symbol,TiaMscText(m_t0),TiaMscText(m_t1));
      return(false);
     }
//--- the window lies in the past, so both passes must have seen the same
//    ticks; anything else means the history changed under the audit
   if(InpCheckReversals && m_pass1_ticks!=m_ticks_total)
     {
      m_status=TIA_STATUS_NO_READ;
      PrintFormat("%s: %s delivered %s ticks in pass 1 and %s in pass 2, the history is still loading, the symbol is skipped",
                  TIA_NAME,m_symbol,TiaNum(m_pass1_ticks),TiaNum(m_ticks_total));
      return(false);
     }
//--- stage: K5 after the last tick, minute by minute
   CompareBars(report);
   ArrayFree(m_rates);
   ArrayFree(m_min_high);
   ArrayFree(m_min_low);
   ArrayFree(m_min_has);
   ArrayFree(m_min_bar);
   m_status=TIA_STATUS_OK;
   return(true);
  }
//+------------------------------------------------------------------+
//| Writes the three per symbol files: the summary row, the quote    |
//| sessions and the server hour profile.                            |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::WriteFiles(CTiaReport &report) const
  {
   bool k1=InpCheckQuotes;
   bool k2=InpCheckTimes;
   bool k3=InpCheckReversals;
   bool k4=InpCheckSilences;
   bool k5=K5On();
   bool max_known=(m_sil_unexplained>0);
   string rows[];
   ArrayResize(rows,24);
//--- stage: the summary, the contract columns first in their fixed order
   string line=m_symbol+TIA_SEP+IntegerToString(m_digits)+TIA_SEP+DoubleToString(m_point,m_digits)+
               TIA_SEP+(m_mode_last ? "last" : "bid")+TIA_SEP+TiaNum(m_t0)+TIA_SEP+TiaNum(m_t1)+
               TIA_SEP+TiaNum(m_ticks_total)+TIA_SEP+TiaNum(m_ticks_change);
   line+=TIA_SEP+TiaCell(k1,TiaNum(m_nonpositive))+TIA_SEP+TiaCell(k1,TiaNum(m_crossed))+
         TIA_SEP+TiaCell(k1,TiaNum(m_locked));
   line+=TIA_SEP+TiaCell(k2,TiaNum(m_backwards))+TIA_SEP+TiaCell(k2,TiaNum(m_repeats))+
         TIA_SEP+TiaCell(k2,TiaNum(m_time_field));
   line+=TIA_SEP+TiaCell(k3,TiaNum(m_s))+TIA_SEP+TiaCell(k3,TiaNum(m_rev_ge2))+
         TIA_SEP+TiaCell(k3,TiaNum(m_rev_ge5))+TIA_SEP+TiaCell(k3,TiaNum(m_rev_ge10))+
         TIA_SEP+TiaCell(k3,TiaNum(m_rev_ge20))+TIA_SEP+TiaCell(k3,TiaNum(m_rev_flagged))+
         TIA_SEP+TiaCell(k3,TiaNum(m_rev_max))+TIA_SEP+TiaCell(k3,TiaDecimal(InpReversalMult))+
         TIA_SEP+TiaCell(k3,TiaDecimal(InpReversalReturnFrac));
   line+=TIA_SEP+TiaCell(k4,TiaNum(m_sil_total))+TIA_SEP+TiaCell(k4,TiaNum(m_sil_explained))+
         TIA_SEP+TiaCell(k4,TiaNum(m_sil_unexplained))+TIA_SEP+TiaCell(k4,TiaNum(m_sil_unclassified))+
         TIA_SEP+TiaCell(k4,TiaSeconds(m_sil_unexpl_ms))+TIA_SEP+TiaCell(k4,TiaSeconds(m_sil_max_ms))+
         TIA_SEP+TiaCell(k4 && max_known,TiaNum(m_sil_max_start))+
         TIA_SEP+TiaCell(k4,IntegerToString(ExtSilenceSeconds));
   line+=TIA_SEP+TiaCell(k5,TiaNum(m_m1_bars))+TIA_SEP+TiaCell(k5,TiaNum(m_tick_minutes))+
         TIA_SEP+TiaCell(k5,TiaNum(m_compared))+TIA_SEP+TiaCell(k5,TiaNum(m_m1_no_ticks))+
         TIA_SEP+TiaCell(k5,TiaNum(m_ticks_no_m1))+TIA_SEP+TiaCell(k5,TiaNum(m_high_mismatch))+
         TIA_SEP+TiaCell(k5,TiaNum(m_low_mismatch))+TIA_SEP+TiaCell(k5,TiaNum(m_bar_max_dev))+
         TIA_SEP+TiaCell(k5,IntegerToString(ExtBarTolPoints));
   line+=TIA_SEP+TiaNum(m_findings);
//--- stage: the columns a human reads, after the contract
   line+=TIA_SEP+TiaMscText(m_t0)+TIA_SEP+TiaMscText(m_t1)+
         TIA_SEP+TiaCell(k3 && m_spread_n>0,TiaNum(m_median_raw))+TIA_SEP+TiaCell(k3,TiaNum(m_spread_n))+
         TIA_SEP+TiaCell(k3,TiaNum(m_rev_total))+TIA_SEP+IntegerToString(ExtChunkMinutes)+
         TIA_SEP+TiaNum(m_chunks)+TIA_SEP+TiaNum(m_retries)+TIA_SEP+TiaNum(m_outside)+
         TIA_SEP+IntegerToString(m_sessions_found)+TIA_SEP+m_k5_state+TIA_SEP+TiaNum(FindingsSum())+
         TIA_SEP+(m_findings==FindingsSum() ? "OK" : "MISMATCH");
   rows[0]=line;
   report.WriteTable(m_symbol,"summary",
                     "symbol;digits;point;chart_mode;from_msc;to_msc;ticks_total;ticks_price_change;"
                     "nonpositive;crossed;locked;backwards;repeats;time_field_mismatch;median_spread_points;"
                     "rev_ge2;rev_ge5;rev_ge10;rev_ge20;rev_flagged;rev_max_points;reversal_mult;return_frac;"
                     "silences_total;silences_explained;silences_unexplained;silences_unclassified;"
                     "silence_unexplained_seconds;silence_max_unexplained_seconds;"
                     "silence_max_unexplained_start_msc;silence_seconds;m1_bars;tick_minutes;"
                     "minutes_compared;m1_without_ticks;ticks_without_m1;high_mismatch;low_mismatch;"
                     "bar_max_dev_points;bar_tol_points;findings_rows;from_time;to_time;"
                     "median_spread_raw;spread_quotes;reversals_total;chunk_minutes;chunks_read;"
                     "read_retries;ticks_outside_chunk;sessions_found;k5_state;findings_sum;identity",
                     rows,1);
//--- stage: every quote session, the yardstick of K4
   int count=0;
   for(int day=0; day<7; day++)
      for(int index=0; index<m_sess_count[day]; index++)
        {
         int slot=day*TIA_MAX_SESSIONS+index;
         if(count>=ArraySize(rows))
            ArrayResize(rows,count+8);
         rows[count++]=m_symbol+TIA_SEP+IntegerToString(day)+TIA_SEP+
                       IntegerToString(m_sess_from[slot])+TIA_SEP+IntegerToString(m_sess_to[slot]);
        }
   report.WriteTable(m_symbol,"sessions","symbol;weekday;from_seconds;to_seconds",rows,count);
//--- stage: the server hour profile, 24 rows
   for(int hour=0; hour<24; hour++)
      rows[hour]=IntegerToString(hour)+TIA_SEP+TiaNum(m_h_ticks[hour])+
                 TIA_SEP+TiaCell(k4,TiaNum(m_h_sil[hour]))+TIA_SEP+TiaCell(k4,TiaSeconds(m_h_sil_ms[hour]))+
                 TIA_SEP+TiaCell(k3,TiaNum(m_h_rev[hour]));
   report.WriteTable(m_symbol,"hours","hour;ticks;silences_unexplained;silence_unexplained_seconds;rev_flagged",
                     rows,24);
  }
//+------------------------------------------------------------------+
//| The quote session table as one readable line.                    |
//+------------------------------------------------------------------+
string CTiaSymbolAudit::SessionsText(void) const
  {
   string names="Sun Mon Tue Wed Thu Fri Sat";
   string out="";
   for(int day=0; day<7; day++)
     {
      if(m_sess_count[day]<=0)
         continue;
      out+=(out=="" ? "" : " | ")+StringSubstr(names,day*4,3)+" ";
      for(int index=0; index<m_sess_count[day]; index++)
        {
         int slot=day*TIA_MAX_SESSIONS+index;
         out+=(index>0 ? ", " : "")+
              StringFormat("%02d:%02d-%02d:%02d",m_sess_from[slot]/3600,(m_sess_from[slot]%3600)/60,
                           m_sess_to[slot]/3600,(m_sess_to[slot]%3600)/60);
        }
     }
   return(out=="" ? "none reported by the broker" : out);
  }
//+------------------------------------------------------------------+
//| The journal block of one symbol. A figure of a check that did    |
//| not run is a dash; the identity line prints both of its sides.   |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::PrintDetail(void) const
  {
//--- a skipped symbol already has its one journal line with the reason
   if(m_status!=TIA_STATUS_OK)
      return;
   bool k1=InpCheckQuotes;
   bool k2=InpCheckTimes;
   bool k3=InpCheckReversals;
   bool k4=InpCheckSilences;
   bool k5=K5On();
   PrintFormat("%s: window %s to %s (%d days ending at the last tick), chart price %s, point %s",
               m_symbol,TiaMscText(m_t0),TiaMscText(m_t1),ExtDays,(m_mode_last ? "last" : "bid"),
               DoubleToString(m_point,m_digits));
   PrintFormat("%s: ticks %s, price changing %s, %s chunks of %d min, %s retries, %s outside their chunk",
               m_symbol,TiaNum(m_ticks_total),TiaNum(m_ticks_change),TiaNum(m_chunks),ExtChunkMinutes,
               TiaNum(m_retries),TiaNum(m_outside));
   PrintFormat("%s: K1 %s, nonpositive %s, crossed %s, locked %s (a count, not a finding)",m_symbol,
               (k1 ? "on" : "off"),TiaText(k1,TiaNum(m_nonpositive)),TiaText(k1,TiaNum(m_crossed)),
               TiaText(k1,TiaNum(m_locked)));
   PrintFormat("%s: K2 %s, backwards %s, repeats %s, time field mismatch %s",m_symbol,
               (k2 ? "on" : "off"),TiaText(k2,TiaNum(m_backwards)),TiaText(k2,TiaNum(m_repeats)),
               TiaText(k2,TiaNum(m_time_field)));
   PrintFormat("%s: K3 %s, S %s points (lower median %s of %s quotes), reversals %s: >=2S %s, >=5S %s, >=10S %s, >=20S %s, flagged >=%sS %s, largest %s points",
               m_symbol,(k3 ? "on" : "off"),TiaText(k3,TiaNum(m_s)),
               TiaText(k3 && m_spread_n>0,TiaNum(m_median_raw)),TiaText(k3,TiaNum(m_spread_n)),
               TiaText(k3,TiaNum(m_rev_total)),TiaText(k3,TiaNum(m_rev_ge2)),TiaText(k3,TiaNum(m_rev_ge5)),
               TiaText(k3,TiaNum(m_rev_ge10)),TiaText(k3,TiaNum(m_rev_ge20)),TiaDecimal(InpReversalMult),
               TiaText(k3,TiaNum(m_rev_flagged)),TiaText(k3,TiaNum(m_rev_max)));
   PrintFormat("%s: K4 %s, silences over %d s %s: explained %s, unexplained %s, unclassified %s; unexplained %s s, longest %s s from %s",
               m_symbol,(k4 ? "on" : "off"),ExtSilenceSeconds,TiaText(k4,TiaNum(m_sil_total)),
               TiaText(k4,TiaNum(m_sil_explained)),TiaText(k4,TiaNum(m_sil_unexplained)),
               TiaText(k4,TiaNum(m_sil_unclassified)),TiaText(k4,TiaSeconds(m_sil_unexpl_ms)),
               TiaText(k4,TiaSeconds(m_sil_max_ms)),TiaMscText(m_sil_max_start));
   PrintFormat("%s: K5 %s, M1 bars %s, tick minutes %s, compared %s, M1 without ticks %s, ticks without M1 %s, high %s, low %s, largest deviation %s points, tolerance %s",
               m_symbol,m_k5_state,TiaText(k5,TiaNum(m_m1_bars)),TiaText(k5,TiaNum(m_tick_minutes)),
               TiaText(k5,TiaNum(m_compared)),TiaText(k5,TiaNum(m_m1_no_ticks)),
               TiaText(k5,TiaNum(m_ticks_no_m1)),TiaText(k5,TiaNum(m_high_mismatch)),
               TiaText(k5,TiaNum(m_low_mismatch)),TiaText(k5,TiaNum(m_bar_max_dev)),
               TiaText(k5,IntegerToString(ExtBarTolPoints)));
   PrintFormat("%s: quote sessions %s",m_symbol,SessionsText());
   PrintFormat("%s: identity findings_rows %s == nonpositive %s + crossed %s + backwards %s + repeats %s + time_field_mismatch %s + rev_flagged %s + silences_unexplained %s + m1_without_ticks %s + ticks_without_m1 %s + high_mismatch %s + low_mismatch %s = %s -> %s",
               m_symbol,TiaNum(m_findings),TiaText(k1,TiaNum(m_nonpositive)),TiaText(k1,TiaNum(m_crossed)),
               TiaText(k2,TiaNum(m_backwards)),TiaText(k2,TiaNum(m_repeats)),TiaText(k2,TiaNum(m_time_field)),
               TiaText(k3,TiaNum(m_rev_flagged)),TiaText(k4,TiaNum(m_sil_unexplained)),
               TiaText(k5,TiaNum(m_m1_no_ticks)),TiaText(k5,TiaNum(m_ticks_no_m1)),
               TiaText(k5,TiaNum(m_high_mismatch)),TiaText(k5,TiaNum(m_low_mismatch)),
               TiaNum(FindingsSum()),(m_findings==FindingsSum() ? "OK" : "MISMATCH"));
   PrintFormat("%s: rows of this symbol in the findings file %s, findings_rows %s -> %s",m_symbol,
               TiaText(InpWriteCsv,TiaNum(m_rows_written)),TiaNum(m_findings),
               (!InpWriteCsv ? "file off" : (m_rows_written==m_findings ? "OK" : "MISMATCH")));
  }
//+------------------------------------------------------------------+
//| Header row of the result table, shared by panel and journal.     |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::HeaderCells(string &cells[][TIA_COLS],const int row)
  {
   cells[row][0]="Symbol";
   cells[row][1]="Ticks";
   cells[row][2]="Crossed";
   cells[row][3]="Backw";
   cells[row][4]="Repeat";
   cells[row][5]="S pts";
   cells[row][6]="Rev"+ShortToString(0x2265)+"10S";
   cells[row][7]="Silence unexpl.";
   cells[row][8]="Max sil s";
   cells[row][9]="M1 no ticks";
   cells[row][10]="Ticks no M1";
   cells[row][11]="H/L mism.";
  }
//+------------------------------------------------------------------+
//| One row of the result table. A symbol that was not audited shows |
//| its status instead of numbers, a check that was off a dash.      |
//+------------------------------------------------------------------+
void CTiaSymbolAudit::Cells(string &cells[][TIA_COLS],const int row) const
  {
   for(int c=0; c<TIA_COLS; c++)
      cells[row][c]="";
   cells[row][0]=m_symbol;
   if(m_status!=TIA_STATUS_OK)
     {
      cells[row][1]=ExtStatusNames[(int)m_status];
      return;
     }
   bool k5=K5On();
   cells[row][1]=TiaNum(m_ticks_total);
   cells[row][2]=TiaText(InpCheckQuotes,TiaNum(m_crossed));
   cells[row][3]=TiaText(InpCheckTimes,TiaNum(m_backwards));
   cells[row][4]=TiaText(InpCheckTimes,TiaNum(m_repeats));
   cells[row][5]=TiaText(InpCheckReversals,TiaNum(m_s));
   cells[row][6]=TiaText(InpCheckReversals,TiaNum(m_rev_ge10));
   cells[row][7]=TiaText(InpCheckSilences,TiaNum(m_sil_unexplained));
   cells[row][8]=TiaText(InpCheckSilences,TiaSeconds(m_sil_max_ms));
   cells[row][9]=TiaText(k5,TiaNum(m_m1_no_ticks));
   cells[row][10]=TiaText(k5,TiaNum(m_ticks_no_m1));
   cells[row][11]=TiaText(k5,TiaNum(m_high_mismatch)+"/"+TiaNum(m_low_mismatch));
  }
//--- global objects and counters of the expert
CTiaReport        ExtReport;                       // journal examples and the CSV files
CTiaPanel         ExtPanel;                        // the table on the chart
CTiaSymbolAudit   ExtAudits[TIA_MAX_SYMBOLS];      // one audit per symbol of the list
string            ExtSymbols[TIA_MAX_SYMBOLS];     // the resolved symbol list
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
long              ExtTicks=0;                      // ticks audited in the last pass
long              ExtFindings=0;                   // findings of the last pass
long              ExtFindingsSum=0;                // sum of the finding counters of the last pass
//+------------------------------------------------------------------+
//| The whole expert back to its starting state. An expert is not    |
//| reloaded when an input changes, so every global, object and      |
//| counter is cleared here by hand (pitfall C24).                   |
//+------------------------------------------------------------------+
void TiaReset(void)
  {
   ExtReport.Close();
   ExtReport.Reset();
   ExtPanel.Reset();
   for(int i=0; i<TIA_MAX_SYMBOLS; i++)
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
   ExtTicks=0;
   ExtFindings=0;
   ExtFindingsSum=0;
   ExtDays=3;
   ExtChunkMinutes=360;
   ExtSilenceSeconds=60;
   ExtBarTolPoints=0;
  }
//+------------------------------------------------------------------+
//| Adds one symbol to the list unless it is there already or the    |
//| list is full; a duplicate would be counted twice in every total. |
//+------------------------------------------------------------------+
void TiaAddSymbol(const string name)
  {
   if(name=="")
      return;
   for(int i=0; i<ExtCount; i++)
      if(ExtSymbols[i]==name)
         return;
   if(ExtCount>=TIA_MAX_SYMBOLS)
     {
      PrintFormat("%s: the list is full at %d symbols, %s is not audited",TIA_NAME,TIA_MAX_SYMBOLS,name);
      return;
     }
   ExtSymbols[ExtCount++]=name;
  }
//+------------------------------------------------------------------+
//| Resolves the symbol input. The Market Watch is only read, never  |
//| changed: adding a symbol would be a side effect of a measurement.|
//+------------------------------------------------------------------+
void TiaBuildSymbolList(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
     {
      int total=SymbolsTotal(true);
      for(int i=0; i<total; i++)
         TiaAddSymbol(SymbolName(i,true));
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
         TiaAddSymbol(parts[i]);
        }
     }
   if(ExtCount<=0)
      TiaAddSymbol(Symbol());
  }
//+------------------------------------------------------------------+
//| Short tag of the symbol selection for the file names; with the   |
//| days and the chart id it keeps two instances apart.              |
//+------------------------------------------------------------------+
string TiaSymbolsTag(void)
  {
   string text=InpSymbols;
   StringTrimLeft(text);
   StringTrimRight(text);
   if(text=="*")
      return("MarketWatch");
   if(ExtCount==1)
      return(TiaSafeName(ExtSymbols[0]));
   return(TiaSafeName(ExtSymbols[0])+"_plus"+IntegerToString(ExtCount-1));
  }
//+------------------------------------------------------------------+
//| Clamps one integer input and says so in the journal, so a reader |
//| never has to guess which value was really used.                  |
//+------------------------------------------------------------------+
int TiaClamp(const string name,const int value,const int low,const int high)
  {
   int used=MathMin(high,MathMax(low,value));
   if(used!=value)
      PrintFormat("%s: %s %d is outside %d..%d, %d is used",TIA_NAME,name,value,low,high,used);
   return(used);
  }
//+------------------------------------------------------------------+
//| Prints the settings of the run once, after the clamping.         |
//+------------------------------------------------------------------+
void TiaPrintStartBlock(void)
  {
   Print("=== "+TIA_TITLE+" ===========================================");
   PrintFormat("symbols        : %d (%s)",ExtCount,(InpSymbols=="" ? "chart symbol" :
               (InpSymbols=="*" ? "Market Watch" : "list")));
   PrintFormat("window         : %d day(s) ending at the last tick of each symbol, chunks of %d minutes",
               ExtDays,ExtChunkMinutes);
   PrintFormat("checks         : K1 %s  K2 %s  K3 %s (x%s S, return %s)  K4 %s (%d s)  K5 %s (tolerance %d points)",
               (InpCheckQuotes ? "on" : "off"),(InpCheckTimes ? "on" : "off"),
               (InpCheckReversals ? "on" : "off"),TiaDecimal(InpReversalMult),
               TiaDecimal(InpReversalReturnFrac),(InpCheckSilences ? "on" : "off"),ExtSilenceSeconds,
               (InpCheckBars ? "on" : "off"),ExtBarTolPoints);
   PrintFormat("refresh        : %s",(InpRefreshMinutes>0 ?
                                      IntegerToString(InpRefreshMinutes)+" minutes of server time" : "once"));
   PrintFormat("files          : %s",(InpWriteCsv ? TIA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "off"));
   for(int i=0; i<ExtCount; i++)
      PrintFormat("symbol %d of %d  : %s",i+1,ExtCount,ExtSymbols[i]);
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Fills the result table: one header row and one row per symbol,   |
//| at most rows symbols.                                            |
//+------------------------------------------------------------------+
int TiaBuildCells(string &cells[][TIA_COLS],const int rows)
  {
   int shown=MathMin(rows,ExtCount);
   ArrayResize(cells,shown+1);
   CTiaSymbolAudit::HeaderCells(cells,0);
   for(int i=0; i<shown; i++)
      ExtAudits[i].Cells(cells,i+1);
   return(shown+1);
  }
//+------------------------------------------------------------------+
//| Prints the result table of one pass and the run identities.      |
//+------------------------------------------------------------------+
void TiaPrintSummary(void)
  {
   Print("=== "+TIA_TITLE+" - result of pass "+IntegerToString(ExtPass)+" ========");
   string cells[][TIA_COLS];
   int    rows=TiaBuildCells(cells,ExtCount);
   int    widths[TIA_COLS];
   TiaColumnWidths(cells,rows,widths);
   for(int r=0; r<rows; r++)
      Print(TiaRowText(cells,r,widths));
   PrintFormat("symbols        : %d audited, %d skipped, identity OK %d of %d",ExtOk,ExtFailed,
               ExtIdentityOk,ExtOk);
   PrintFormat("totals         : ticks %s, findings %s, sum of the finding counters %s -> %s",
               TiaNum(ExtTicks),TiaNum(ExtFindings),TiaNum(ExtFindingsSum),
               (ExtFindings==ExtFindingsSum ? "OK" : "MISMATCH"));
   PrintFormat("findings file  : %s, findings handed %s, rows written %s, dropped by the guard %s -> %s",
               (ExtReport.FindingsOn() ? ExtReport.FindingsName() : "off"),TiaNum(ExtReport.Seen()),
               TiaNum(ExtReport.Rows()),TiaNum(ExtReport.Dropped()),
               (!ExtReport.FindingsOn() ? "file off" :
                (ExtReport.Rows()+ExtReport.Dropped()==ExtFindings ? "OK" : "MISMATCH")));
   PrintFormat("symbol files   : %d written, pattern %s\\%s_<symbol>_{summary,sessions,hours}.csv",
               ExtReport.Files(),TIA_FOLDER,ExtPrefix);
   PrintFormat("wall time      : %s ms",TiaNum((long)ExtWallMs));
   if(ExtPanelOn)
      PrintFormat("panel          : %d x %d pixels, %d labels, widest line %d characters",
                  ExtPanel.WidthPx(),ExtPanel.HeightPx(),ExtPanel.Labels(),ExtPanel.Widest());
   Print("===================================================================");
  }
//+------------------------------------------------------------------+
//| Redraws the panel with the numbers of the last pass.             |
//+------------------------------------------------------------------+
void TiaUpdatePanel(void)
  {
   if(!ExtPanelOn)
      return;
   string top[3];
   string bottom[];
   string cells[][TIA_COLS];
   top[0]=TIA_TITLE+"   pass "+IntegerToString(ExtPass)+(ExtFirstDone ? "" : "   waiting for the history");
   top[1]=IntegerToString(ExtDays)+" day(s) ending at the last tick   chunk "+IntegerToString(ExtChunkMinutes)+
          " min   "+(ExtLastPass>0 ? TimeToString(ExtLastPass,TIME_DATE|TIME_SECONDS) : "-");
   top[2]="findings "+TiaNum(ExtFindings)+"   csv rows "+TiaText(InpWriteCsv,TiaNum(ExtReport.Rows()))+
          "   identity OK "+IntegerToString(ExtIdentityOk)+"/"+IntegerToString(ExtOk)+
          "   skipped "+IntegerToString(ExtFailed);
   int rows=TiaBuildCells(cells,(ExtFirstDone ? TIA_PANEL_ROWS : 0));
   int lines=(ExtCount>TIA_PANEL_ROWS && ExtFirstDone ? 2 : 1);
   ArrayResize(bottom,lines);
   bottom[0]=(InpWriteCsv ? TIA_FOLDER+"\\"+ExtPrefix+"_*.csv" : "CSV off");
   if(lines>1)
      bottom[1]="... and "+IntegerToString(ExtCount-TIA_PANEL_ROWS)+" more symbols in the journal and the CSV";
   ExtPanel.Update(top,cells,rows,bottom);
  }
//+------------------------------------------------------------------+
//| Tells whether every known symbol has a last tick and, for K5, an |
//| M1 series the terminal has finished building.                    |
//+------------------------------------------------------------------+
bool TiaHistoryReady(void)
  {
   for(int i=0; i<ExtCount; i++)
     {
      double point=0.0;
      if(!SymbolInfoDouble(ExtSymbols[i],SYMBOL_POINT,point) || point<=0.0)
         continue;
      MqlTick last;
      if(!SymbolInfoTick(ExtSymbols[i],last) || last.time_msc<=0)
         return(false);
      long built=0;
      if(InpCheckBars && (!SeriesInfoInteger(ExtSymbols[i],PERIOD_M1,SERIES_SYNCHRONIZED,built) || built==0))
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Runs one pass over the whole symbol list. Every window is fixed  |
//| first, then the symbols are audited one after the other.         |
//+------------------------------------------------------------------+
void TiaRunPass(void)
  {
   ExtPass++;
   ExtLastPass=TiaNow();
   ulong started=GetTickCount64();
   ExtOk=0;
   ExtFailed=0;
   ExtIdentityOk=0;
   ExtTicks=0;
   ExtFindings=0;
   ExtFindingsSum=0;
   ExtReport.Close();
   ExtReport.Reset();
   ExtReport.Open(ExtPrefix);
   PrintFormat("%s: pass %d starts on %d symbol(s), server time %s",TIA_NAME,ExtPass,ExtCount,
               TimeToString(ExtLastPass,TIME_DATE|TIME_SECONDS));
//--- stage: every window is fixed before the first tick is read
   for(int i=0; i<ExtCount; i++)
     {
      ExtAudits[i].SetSymbol(ExtSymbols[i]);
      ExtAudits[i].Prepare();
     }
//--- stage: one symbol after the other, a failure costs one symbol
   for(int i=0; i<ExtCount; i++)
     {
      if(!ExtAudits[i].Audit(ExtReport))
        {
         ExtReport.Discard();
         ExtFailed++;
         continue;
        }
      ExtAudits[i].SetRowsWritten(ExtReport.Commit());
      ExtAudits[i].WriteFiles(ExtReport);
      ExtAudits[i].PrintDetail();
      ExtOk++;
      ExtTicks+=ExtAudits[i].TicksTotal();
      ExtFindings+=ExtAudits[i].Findings();
      ExtFindingsSum+=ExtAudits[i].FindingsSum();
      if(ExtAudits[i].Findings()==ExtAudits[i].FindingsSum())
         ExtIdentityOk++;
     }
   ExtWallMs=GetTickCount64()-started;
//--- stage: the panel first, so the summary reports its real size
   TiaUpdatePanel();
   TiaPrintSummary();
   ExtReport.Close();
  }
//+------------------------------------------------------------------+
//| Reads the inputs, resolves the symbol list and prepares the      |
//| panel. Nothing in here can stop the expert.                      |
//+------------------------------------------------------------------+
void TiaInit(void)
  {
//--- stage: a previous run can still be in these objects, see TiaReset()
   TiaReset();
   ExtDays=TiaClamp("InpDays",InpDays,1,TIA_MAX_DAYS);
   ExtChunkMinutes=TiaClamp("InpChunkMinutes",InpChunkMinutes,1,ExtDays*1440);
   ExtSilenceSeconds=TiaClamp("InpSilenceSeconds",InpSilenceSeconds,1,7*86400);
   ExtBarTolPoints=TiaClamp("InpBarTolPoints",InpBarTolPoints,0,1000000000);
   TiaBuildSymbolList();
   ExtPrefix=TiaSymbolsTag()+"_"+IntegerToString(ExtDays)+"d_"+IntegerToString(ChartID());
//--- stage: the panel; the tester without visual mode has no chart
   if(InpShowPanel)
     {
      if(MQLInfoInteger(MQL_TESTER)!=0 && MQLInfoInteger(MQL_VISUAL_MODE)==0)
         PrintFormat("%s: the panel stays off, the tester runs without visual mode",TIA_NAME);
      else
         ExtPanelOn=ExtPanel.Create();
     }
   TiaPrintStartBlock();
//--- the flag is set last: OnDeinit() also runs after a failed start
   ExtReady=true;
   TiaUpdatePanel();
  }
//+------------------------------------------------------------------+
//| One pulse, shared by OnTick() and OnTimer(). The first pass      |
//| waits a few pulses for the history of a freshly started terminal.|
//+------------------------------------------------------------------+
void TiaPulse(void)
  {
   if(!ExtReady)
      return;
   if(!ExtFirstDone)
     {
      ExtPulses++;
      if(!TiaHistoryReady() && ExtPulses<TIA_WARMUP_PULSES)
         return;
      ExtFirstDone=true;
      TiaRunPass();
      if(InpRefreshMinutes<=0)
        {
         EventKillTimer();
         PrintFormat("%s: the audit is finished, the timer is stopped (InpRefreshMinutes = 0)",TIA_NAME);
        }
      return;
     }
   if(InpRefreshMinutes>0 && (long)TiaNow()-(long)ExtLastPass>=(long)InpRefreshMinutes*60)
      TiaRunPass();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   TiaInit();
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
      PrintFormat("%s: %d pass(es) finished, %s ticks audited, %s findings counted",
                  TIA_NAME,ExtPass,TiaNum(ExtTicks),TiaNum(ExtFindings));
   ExtReport.Close();
   ExtPanel.Destroy();
   PrintFormat("%s: stopped, deinitialisation reason %d",TIA_NAME,reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   TiaPulse();
  }
//+------------------------------------------------------------------+
//| Timer function: drives the first pass and the optional re-audit. |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   TiaPulse();
  }
//+------------------------------------------------------------------+
