//+------------------------------------------------------------------+
//|                                             SwapMonitorPanel.mq5 |
//|                                  Swap & Rollover Monitor Utility |
//|                        Shows swap rates for all MarketWatch syms |
//+------------------------------------------------------------------+
#property copyright   "Kayode"
#property link        "https://forge.mql5.io"
#property version     "1.00"
#property description "Displays Long/Short swap rates, daily cost, and weekly cost"
#property description "for all symbols in the MarketWatch window."
#property indicator_chart_window
#property indicator_plots 0

//--- Enums (must be declared before inputs)
enum ENUM_SWAP_SORT
  {
   SWPSORT_BY_SYMBOL     = 0,  // Symbol (A-Z)
   SWPSORT_BY_LONG_SWAP  = 1,  // Long Swap (Best First)
   SWPSORT_BY_SHORT_SWAP = 2,  // Short Swap (Best First)
   SWPSORT_BY_DAILY_COST = 3,  // Daily Cost (Best First)
  };

//--- Input Parameters
input string         InpPanelTitle     = "SWAP MONITOR";   // Panel Title
input int            InpLotSize        = 1;                 // Reference Lot Size
input color          InpColorBG        = C'15,20,30';       // Background Color
input color          InpColorHeader    = C'20,28,45';       // Header Color
input color          InpColorRow1      = C'18,24,38';       // Row Color (odd)
input color          InpColorRow2      = C'22,30,48';       // Row Color (even)
input color          InpColorPositive  = C'0,200,120';      // Positive Swap Color
input color          InpColorNegative  = C'220,60,80';      // Negative Swap Color
input color          InpColorNeutral   = C'160,170,190';    // Neutral Text Color
input color          InpColorTitle     = C'255,255,255';    // Title Text Color
input color          InpColorAccent    = C'0,180,255';      // Accent Color
input int            InpPanelX         = 20;                // Panel X Position
input int            InpPanelY         = 40;                // Panel Y Position
input int            InpFontSize       = 10;                // Font Size
input string         InpFont           = "Consolas";        // Font
input bool           InpShowDailyCost  = true;              // Show Daily Cost Column
input bool           InpShowWeeklyCost = true;              // Show Weekly Cost Column
input bool           InpHighlightBest  = true;              // Highlight Best Swaps
input ENUM_SWAP_SORT InpSortMode       = SWPSORT_BY_SYMBOL; // Sort Mode

//--- Constants
#define PREFIX          "SWP_"
#define ROW_HEIGHT      22
#define COL_SYMBOL      0
#define COL_LONG        1
#define COL_SHORT       2
#define COL_DAILY       3
#define COL_WEEKLY      4
#define REFRESH_SECONDS 5

//--- Column widths
int col_widths[];
int col_x[];
int panel_width   = 0;
int panel_height  = 0;
int last_update   = 0;
int total_cols    = 0;
bool is_minimized = false;

//--- Button name constants
#define BTN_CLOSE    PREFIX+"BTN_X"
#define BTN_MINIMIZE PREFIX+"BTN_MIN"

//--- Symbol data structure
struct SymbolSwapData
  {
   string   symbol;
   double   swap_long;
   double   swap_short;
   double   daily_long;
   double   daily_short;
   double   weekly_long;
   double   weekly_short;
   double   contract_size;
   string   currency_profit;
  };

SymbolSwapData swap_data[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Calculate columns
   total_cols = 3; // Symbol, Long, Short always shown
   if(InpShowDailyCost)  total_cols++;
   if(InpShowWeeklyCost) total_cols++;

   ArrayResize(col_widths, total_cols);
   ArrayResize(col_x, total_cols);

   col_widths[COL_SYMBOL] = 105;
   col_widths[COL_LONG]   = 82;
   col_widths[COL_SHORT]  = 82;

   int idx = 3;
   if(InpShowDailyCost)  { col_widths[idx] = 95; idx++; }
   if(InpShowWeeklyCost) { col_widths[idx] = 95; }

   // Build column X positions
   col_x[0] = 8;
   for(int i = 1; i < total_cols; i++)
      col_x[i] = col_x[i-1] + col_widths[i-1];

   // Total panel width
   panel_width = col_x[total_cols-1] + col_widths[total_cols-1] + 8;

   BuildPanel();
   EventSetTimer(REFRESH_SECONDS);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteAllObjects();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer function - refresh data                                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   BuildPanel();
  }

//+------------------------------------------------------------------+
//| Chart event handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      // --- Close button: remove indicator
      if(sparam == BTN_CLOSE)
        {
         ObjectSetInteger(0, BTN_CLOSE, OBJPROP_STATE, false);
         DeleteAllObjects();
         ChartIndicatorDelete(0, 0, "SwapMonitorPanel");
         ChartRedraw();
         return;
        }

      // --- Minimize / Maximize button
      if(sparam == BTN_MINIMIZE)
        {
         ObjectSetInteger(0, BTN_MINIMIZE, OBJPROP_STATE, false);
         is_minimized = !is_minimized;
         RenderPanel();
         ChartRedraw();
         return;
        }

      // --- Any other panel click: refresh data
      if(StringFind(sparam, PREFIX) == 0)
         BuildPanel();
     }
  }

//+------------------------------------------------------------------+
//| Main panel builder                                                |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   CollectSwapData();
   SortData();
   RenderPanel();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Collect swap data from all MarketWatch symbols                    |
//+------------------------------------------------------------------+
void CollectSwapData()
  {
   int sym_count = SymbolsTotal(true); // true = MarketWatch only
   ArrayResize(swap_data, sym_count);
   int valid = 0;

   for(int i = 0; i < sym_count; i++)
     {
      string sym = SymbolName(i, true);
      if(sym == "") continue;

      swap_data[valid].symbol        = sym;
      swap_data[valid].swap_long     = SymbolInfoDouble(sym, SYMBOL_SWAP_LONG);
      swap_data[valid].swap_short    = SymbolInfoDouble(sym, SYMBOL_SWAP_SHORT);
      swap_data[valid].contract_size = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
      swap_data[valid].currency_profit = SymbolInfoString(sym, SYMBOL_CURRENCY_PROFIT);

      // Daily cost = swap_long * lot_size (in profit currency per day)
      double tick_value  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
      double tick_size   = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
      double point       = SymbolInfoDouble(sym, SYMBOL_POINT);

      // Swap in points -> monetary value
      double swap_long_val  = 0;
      double swap_short_val = 0;

      int swap_mode = (int)SymbolInfoInteger(sym, SYMBOL_SWAP_MODE);
      // SYMBOL_SWAP_MODE values: 0=disabled,1=points,2=currency symbol,3=currency deposit,
      //                          4=currency margin,5=interest current,6=interest open,7=reopen current,8=reopen bid

      if(swap_mode == 1) // SWAP_MODE_POINTS
        {
         if(tick_size > 0)
           {
            swap_long_val  = swap_data[valid].swap_long  * (tick_value / tick_size) * point * InpLotSize;
            swap_short_val = swap_data[valid].swap_short * (tick_value / tick_size) * point * InpLotSize;
           }
        }
      else if(swap_mode == 2 || swap_mode == 3 || swap_mode == 4)
        // currency symbol / currency deposit / currency margin
        {
         swap_long_val  = swap_data[valid].swap_long  * InpLotSize;
         swap_short_val = swap_data[valid].swap_short * InpLotSize;
        }
      else if(swap_mode == 5 || swap_mode == 6)
        // interest current price / interest open price
        {
         double price = SymbolInfoDouble(sym, SYMBOL_BID);
         swap_long_val  = (swap_data[valid].swap_long  / 100.0 / 365.0) * price * swap_data[valid].contract_size * InpLotSize;
         swap_short_val = (swap_data[valid].swap_short / 100.0 / 365.0) * price * swap_data[valid].contract_size * InpLotSize;
        }
      else // disabled or reopen modes — use raw value as fallback
        {
         swap_long_val  = swap_data[valid].swap_long  * InpLotSize;
         swap_short_val = swap_data[valid].swap_short * InpLotSize;
        }

      swap_data[valid].daily_long    = swap_long_val;
      swap_data[valid].daily_short   = swap_short_val;
      swap_data[valid].weekly_long   = swap_long_val * 7;
      swap_data[valid].weekly_short  = swap_short_val * 7;

      valid++;
     }

   ArrayResize(swap_data, valid);
  }

//+------------------------------------------------------------------+
//| Sort data based on selected mode                                  |
//+------------------------------------------------------------------+
void SortData()
  {
   int n = ArraySize(swap_data);
   if(n < 2) return;

   // Bubble sort (sufficient for typical MarketWatch size)
   for(int i = 0; i < n - 1; i++)
     {
      for(int j = 0; j < n - 1 - i; j++)
        {
         bool swap_needed = false;
         switch((int)InpSortMode)
           {
            case SWPSORT_BY_SYMBOL:
               swap_needed = (swap_data[j].symbol > swap_data[j+1].symbol);
               break;
            case SWPSORT_BY_LONG_SWAP:
               swap_needed = (swap_data[j].swap_long < swap_data[j+1].swap_long);
               break;
            case SWPSORT_BY_SHORT_SWAP:
               swap_needed = (swap_data[j].swap_short < swap_data[j+1].swap_short);
               break;
            case SWPSORT_BY_DAILY_COST:
               swap_needed = (swap_data[j].daily_long < swap_data[j+1].daily_long);
               break;
           }
         if(swap_needed)
           {
            SymbolSwapData tmp = swap_data[j];
            swap_data[j]       = swap_data[j+1];
            swap_data[j+1]     = tmp;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Render the full panel                                             |
//+------------------------------------------------------------------+
void RenderPanel()
  {
   int n        = ArraySize(swap_data);
   int title_h  = 34;
   int header_h = 24;
   int footer_h = 22;
   int btn_size = 22;   // width & height of each title-bar button
   int btn_gap  = 2;    // gap between buttons and panel edge

   // When minimized show only the title bar
   if(is_minimized)
      panel_height = title_h;
   else
      panel_height = title_h + header_h + (n * ROW_HEIGHT) + footer_h + 6;

   // --- Background ---
   CreateRect(PREFIX+"BG", InpPanelX, InpPanelY, panel_width, panel_height, InpColorBG, 210);

   // --- Title Bar background ---
   CreateRect(PREFIX+"TITLE_BG", InpPanelX, InpPanelY, panel_width, title_h, InpColorAccent, 255);

   // --- Title label (leave room for 2 buttons on the right) ---
   int label_right_margin = (btn_size * 2) + (btn_gap * 3) + 4;
   CreateLabel(PREFIX+"TITLE",
               InpPanelX + (panel_width - label_right_margin) / 2,
               InpPanelY + 5,
               InpPanelTitle + "  [" + (string)n + " sym | " + (string)InpLotSize + "L]",
               InpColorTitle, InpFontSize+1, ANCHOR_UPPER, true);

   // --- Minimize button [ _ ] ---
   int min_x = InpPanelX + panel_width - (btn_size * 2) - (btn_gap * 2) - 2;
   int min_y = InpPanelY + (title_h - btn_size) / 2;
   CreateButton(BTN_MINIMIZE, min_x, min_y, btn_size, btn_size,
                is_minimized ? "+" : "_",
                C'30,30,60', C'200,220,255');

   // --- Close button [ X ] ---
   int cls_x = InpPanelX + panel_width - btn_size - btn_gap - 2;
   int cls_y = min_y;
   CreateButton(BTN_CLOSE, cls_x, cls_y, btn_size, btn_size,
                "X", C'140,30,30', C'255,180,180');

   // --- Stop here if minimized ---
   if(is_minimized)
     {
      // Hide body objects that may still exist from previous render
      DeleteBodyObjects();
      return;
     }

   // --- Header Row ---
   int hy = InpPanelY + title_h;
   CreateRect(PREFIX+"HDR_BG", InpPanelX, hy, panel_width, header_h, InpColorHeader, 255);

   string headers[];
   ArrayResize(headers, total_cols);
   headers[COL_SYMBOL] = "SYMBOL";
   headers[COL_LONG]   = "LONG SWP";
   headers[COL_SHORT]  = "SHORT SWP";
   int hidx = 3;
   if(InpShowDailyCost)  { headers[hidx] = "DAILY(" + (string)InpLotSize + "L)"; hidx++; }
   if(InpShowWeeklyCost) { headers[hidx] = "WEEKLY(" + (string)InpLotSize + "L)"; }

   for(int c = 0; c < total_cols; c++)
     {
      CreateLabel(PREFIX+"H_"+IntegerToString(c),
                  InpPanelX + col_x[c] + col_widths[c]/2,
                  hy + 3,
                  headers[c],
                  InpColorAccent, InpFontSize, ANCHOR_UPPER, true);
     }

   // --- Data Rows ---
   double best_long = -DBL_MAX, best_short = -DBL_MAX;
   if(InpHighlightBest)
     {
      for(int i = 0; i < n; i++)
        {
         if(swap_data[i].swap_long  > best_long)  best_long  = swap_data[i].swap_long;
         if(swap_data[i].swap_short > best_short) best_short = swap_data[i].swap_short;
        }
     }

   for(int i = 0; i < n; i++)
     {
      int ry = InpPanelY + title_h + header_h + (i * ROW_HEIGHT);
      color row_bg = (i % 2 == 0) ? InpColorRow1 : InpColorRow2;
      CreateRect(PREFIX+"ROW_"+IntegerToString(i), InpPanelX, ry, panel_width, ROW_HEIGHT, row_bg, 200);

      bool is_best_long  = InpHighlightBest && (swap_data[i].swap_long  == best_long  && best_long  > 0);
      bool is_best_short = InpHighlightBest && (swap_data[i].swap_short == best_short && best_short > 0);

      color sym_col = (is_best_long || is_best_short) ? InpColorAccent : InpColorNeutral;
      CreateLabel(PREFIX+"R"+IntegerToString(i)+"_SYM",
                  InpPanelX + col_x[COL_SYMBOL] + 4, ry + 3,
                  swap_data[i].symbol, sym_col, InpFontSize, ANCHOR_UPPER, false);

      color lc = SwapColor(swap_data[i].swap_long);
      CreateLabel(PREFIX+"R"+IntegerToString(i)+"_LNG",
                  InpPanelX + col_x[COL_LONG] + col_widths[COL_LONG] - 4, ry + 3,
                  DoubleToString(swap_data[i].swap_long, 1), lc, InpFontSize, ANCHOR_UPPER, false, true);

      color sc = SwapColor(swap_data[i].swap_short);
      CreateLabel(PREFIX+"R"+IntegerToString(i)+"_SHT",
                  InpPanelX + col_x[COL_SHORT] + col_widths[COL_SHORT] - 4, ry + 3,
                  DoubleToString(swap_data[i].swap_short, 1), sc, InpFontSize, ANCHOR_UPPER, false, true);

      int cidx = 3;
      if(InpShowDailyCost)
        {
         string dstr = FormatMoney(swap_data[i].daily_long) + "/" + FormatMoney(swap_data[i].daily_short);
         CreateLabel(PREFIX+"R"+IntegerToString(i)+"_DAY",
                     InpPanelX + col_x[cidx] + col_widths[cidx] - 4, ry + 3,
                     dstr, InpColorNeutral, InpFontSize, ANCHOR_UPPER, false, true);
         cidx++;
        }

      if(InpShowWeeklyCost)
        {
         string wstr = FormatMoney(swap_data[i].weekly_long) + "/" + FormatMoney(swap_data[i].weekly_short);
         CreateLabel(PREFIX+"R"+IntegerToString(i)+"_WK",
                     InpPanelX + col_x[cidx] + col_widths[cidx] - 4, ry + 3,
                     wstr, InpColorNeutral, InpFontSize, ANCHOR_UPPER, false, true);
        }
     }

   // --- Footer ---
   int fy = InpPanelY + title_h + header_h + (n * ROW_HEIGHT) + 2;
   CreateRect(PREFIX+"FOOTER_BG", InpPanelX, fy, panel_width, footer_h, InpColorHeader, 220);
   string ts = "Updated: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   CreateLabel(PREFIX+"FOOTER", InpPanelX + panel_width/2, fy + 3,
               ts, C'80,100,130', InpFontSize, ANCHOR_UPPER, true);
  }

//+------------------------------------------------------------------+
//| Get color based on swap value                                     |
//+------------------------------------------------------------------+
color SwapColor(double val)
  {
   if(val > 0)  return InpColorPositive;
   if(val < 0)  return InpColorNegative;
   return InpColorNeutral;
  }

//+------------------------------------------------------------------+
//| Format monetary value compactly                                   |
//+------------------------------------------------------------------+
string FormatMoney(double val)
  {
   if(MathAbs(val) >= 1000)
      return DoubleToString(val / 1000.0, 1) + "k";
   return DoubleToString(val, 2);
  }

//+------------------------------------------------------------------+
//| Create rectangle object                                           |
//+------------------------------------------------------------------+
void CreateRect(string name, int x, int y, int w, int h, color clr, int alpha)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,       w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,       h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR,       clr);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
  }

//+------------------------------------------------------------------+
//| Create label object                                               |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr,
                 int fontsize, ENUM_ANCHOR_POINT anchor, bool centered,
                 bool right_align = false)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_COLOR,       clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,    fontsize);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetString(0,  name, OBJPROP_FONT,        InpFont);
   ObjectSetString(0,  name, OBJPROP_TEXT,        text);

   if(right_align)
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
   else if(centered)
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
   else
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
  }

//+------------------------------------------------------------------+
//| Create a clickable button object                                  |
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int w, int h,
                  string text, color bg, color fg)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,       w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,       h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,     bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR,       fg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR,fg);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,    9);
   ObjectSetString(0,  name, OBJPROP_FONT,        "Arial Bold");
   ObjectSetString(0,  name, OBJPROP_TEXT,        text);
   ObjectSetInteger(0, name, OBJPROP_STATE,       false);
  }

//+------------------------------------------------------------------+
//| Delete only body objects (rows, header, footer) — keep titlebar  |
//+------------------------------------------------------------------+
void DeleteBodyObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX+"ROW_")    == 0) { ObjectDelete(0, name); continue; }
      if(StringFind(name, PREFIX+"R")       == 0) { ObjectDelete(0, name); continue; }
      if(StringFind(name, PREFIX+"H_")      == 0) { ObjectDelete(0, name); continue; }
      if(StringFind(name, PREFIX+"HDR_BG")  == 0) { ObjectDelete(0, name); continue; }
      if(StringFind(name, PREFIX+"FOOTER")  == 0) { ObjectDelete(0, name); continue; }
     }
  }

//+------------------------------------------------------------------+
//| Delete all panel objects                                          |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX) == 0)  // <-- FIX: stray '3' removed
         ObjectDelete(0, name);
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+