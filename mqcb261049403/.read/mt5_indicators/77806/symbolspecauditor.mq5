//+------------------------------------------------------------------+
//|                                            SymbolSpecAuditor.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Shows the contract specification of the chart symbol that matters for position"
#property description "sizing (point value, spread cost, margin, swap, execution rules, sessions) and"
#property description "flags broker traps: non-standard contract size, cent account, stops level and more."
#property indicator_chart_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Panel layout                                                     |
//+------------------------------------------------------------------+
enum ENUM_SSA_LAYOUT
  {
   SSA_LAYOUT_AUTO = 0, // Auto (one column if it fits the chart height)
   SSA_LAYOUT_ONE  = 1, // One column
   SSA_LAYOUT_TWO  = 2  // Two columns
  };

//--- inputs
input group "Panel"
input ENUM_BASE_CORNER InpCorner           = CORNER_LEFT_UPPER; // Panel corner
input int              InpOffsetX          = 10;                // X offset (pixels at 100% screen scaling)
input int              InpOffsetY          = 30;                // Y offset (pixels at 100% screen scaling)
input ENUM_SSA_LAYOUT  InpLayout           = SSA_LAYOUT_AUTO;   // Layout
input string           InpFontName         = "Consolas";        // Font name
input int              InpFontSize         = 9;                 // Font size
input bool             InpShowWarningsOnly = false;             // Show warnings only
input group "Colors"
input color            InpColorText        = clrNONE;           // Text (None = automatic)
input color            InpColorHeading     = clrNONE;           // Headings (None = automatic)
input color            InpColorWarning     = clrNONE;           // Warnings (None = automatic)
input color            InpColorOk          = clrNONE;           // OK / no traps (None = automatic)
input color            InpColorBackground  = clrNONE;           // Background (None = automatic)
input group "Checks"
input double           InpSpreadWarnPctAtr = 15.0;              // Warn if spread exceeds % of ATR(14) (0 = off)
input group "Export"
input bool             InpExportOnStart    = false;             // Export all Market Watch symbols to CSV at start

//--- constants
#define SSA_PREFIX       "SSA_"  // name prefix of every chart object of the panel
#define SSA_NA           DBL_MAX // marks a value that could not be determined
#define SSA_ATR_PERIOD   14
#define SSA_VALUE_CHARS  34      // longest value shown in a panel row
#define SSA_WRAP_CHARS   58      // warnings wrap at the panel width, but not below this many characters
#define SSA_LABEL_MAX    63      // MT5 truncates OBJ_LABEL text beyond this, longer texts use several labels
#define SSA_STATUS_MS    5000
#define SSA_RETRY_MS     60000   // retry a failed conversion-symbol search after this
#define SSA_FLAG_COLLAPSED   1   // bits of the per-chart state variable
#define SSA_FLAG_CHARTCHANGE 2

//+------------------------------------------------------------------+
//| Everything the panel and the CSV show for one symbol             |
//+------------------------------------------------------------------+
struct SSymbolAudit
  {
   string                      symbol;
   string                      description;
   string                      path;
   bool                        custom;
   ENUM_SYMBOL_CALC_MODE       calcMode;
   string                      baseCcy;
   string                      profitCcy;
   string                      marginCcy;
   string                      accountCcy;
   long                        accountLeverage;
   string                      assetClass;       // "forex", "gold", "silver" or "" (other)
   double                      standardContract; // usual contract size of that asset class
   int                         digits;
   double                      point;
   double                      tickSize;
   double                      tickValue;
   double                      tickValueProfit;
   double                      tickValueLoss;
   string                      tickNote;         // why the tick value was not read
   double                      contractSize;
   datetime                    expirationTime;   // 0 = the symbol does not expire
   double                      bid;
   double                      ask;
   double                      refPrice;
   double                      pointValue;       // (a) tick value * point / tick size
   double                      pointValueCheck;  // (b) contract size * point * conversion rate
   string                      checkNote;
   double                      checkDiffPct;
   double                      priceUnitValue;   // money per 1.00 price move
   double                      spreadPoints;
   double                      spreadMoney;
   double                      atrPoints;
   string                      atrNote;
   double                      spreadPctAtr;
   double                      volMin;
   double                      volStep;
   double                      volMax;
   double                      volLimit;
   double                      marginRateBuy;
   double                      marginRateSell;
   double                      marginBuy;
   double                      marginSell;
   string                      marginNote;
   double                      notional;
   string                      notionalCcy;
   double                      leverage;
   ENUM_SYMBOL_SWAP_MODE       swapMode;
   double                      swapLong;
   double                      swapShort;
   string                      swapUnit;
   double                      swapLongMoney;
   double                      swapShortMoney;
   ENUM_DAY_OF_WEEK            swap3Day;
   ENUM_SYMBOL_TRADE_MODE      tradeMode;
   ENUM_SYMBOL_TRADE_EXECUTION execMode;
   int                         fillingFlags;
   int                         orderFlags;
   int                         expirationFlags;
   ENUM_SYMBOL_ORDER_GTC_MODE  gtcMode;
   int                         stopsLevel;
   int                         freezeLevel;
   string                      sessionDay;
   string                      sessions[];
   string                      warnings[];
  };

//+------------------------------------------------------------------+
//| Kind of a panel row                                              |
//+------------------------------------------------------------------+
enum ENUM_SSA_ROW
  {
   SSA_ROW_HEADING,
   SSA_ROW_PAIR
  };

//+------------------------------------------------------------------+
//| One logical panel row: a heading or a key/value pair             |
//+------------------------------------------------------------------+
struct SPanelRow
  {
   int               kind;
   string            key;
   string            value;
   color             clr;
  };

//+------------------------------------------------------------------+
//| One label of the frame being laid out (panel coordinates)        |
//+------------------------------------------------------------------+
struct SPanelLabel
  {
   string            text;
   color             clr;
   int               x;
   int               y;
  };

//+------------------------------------------------------------------+
//| A button as planned by the layout, or as currently drawn         |
//+------------------------------------------------------------------+
struct SPanelButton
  {
   bool              visible;
   string            text;
   int               x;
   int               y;
   int               w;
   int               h;
  };

//--- settings resolved in OnInit
string   g_prefix = "";
bool     g_atRight = false;
bool     g_atBottom = false;
int      g_offX = 0;
int      g_offY = 0;
string   g_fontName = "Consolas";
int      g_fontSize = 9;
double   g_scale = 1.0;
int      g_lineH = 16;
color    g_clrText, g_clrKey, g_clrHeading, g_clrWarning, g_clrOk, g_clrBack, g_clrBorder, g_clrButton, g_clrButtonBorder;
color    g_chartBack = clrNONE;  // chart background the automatic colors were chosen for
int      g_atrHandle = INVALID_HANDLE;
//--- state; OnInit sets every value explicitly. A symbol/timeframe change loads a fresh
//--- instance, so the collapsed state and "this is only a chart change" are carried over
//--- in a temporary terminal global variable (see LoadState/SaveState)
bool     g_collapsed = false;
bool     g_exportPending = false;
ulong    g_initTick = 0;
string   g_statusText = "";
color    g_statusClr = clrNONE;
ulong    g_statusUntil = 0;
int      g_lastChartW = -1;
int      g_lastChartH = -1;
//--- layout state
bool     g_autoDecided = false;
bool     g_autoTwo = false;
int      g_autoChartH = -1;
int      g_layoutCols = -1;
int      g_keyW[2];
int      g_valW[2];
int      g_frameRight = 0;
SPanelLabel  g_frame[];
SPanelButton g_planExport, g_planToggle;
//--- what is currently drawn (lets the renderer touch only what changed)
SPanelLabel  g_shown[];
SPanelButton g_shownExport, g_shownToggle;
bool     g_bgMade = false;
int      g_bgX, g_bgY, g_bgW, g_bgH;
//--- conversion-symbol cache
string   g_pairFrom[], g_pairTo[], g_pairSymbol[];
bool     g_pairInverse[];
ulong    g_pairTime[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- remove panels of this and of earlier instances (for example saved in a template)
   g_prefix = SSA_PREFIX + IntegerToString(ChartID() % 100000) + "_";
   ObjectsDeleteAll(0, SSA_PREFIX);
   ResetRenderState();
   ArrayResize(g_pairFrom, 0);
   ArrayResize(g_pairTo, 0);
   ArrayResize(g_pairSymbol, 0);
   ArrayResize(g_pairInverse, 0);
   ArrayResize(g_pairTime, 0);
//--- appearance; MT5 scales fonts with the screen DPI but not object coordinates,
//--- so every pixel distance goes through Px()
   g_fontName = (StringLen(InpFontName) > 0) ? InpFontName : "Consolas";
   g_fontSize = MathMax(4, MathMin(24, InpFontSize));
   g_scale = MathMax(0.75, MathMin(4.0, TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0));
   ResolveColors();
   TextSetFont(g_fontName, -10 * g_fontSize);
   uint textW = 0, textH = 0;
   TextGetSize("Ag", textW, textH);
   g_lineH = MathMax(Px(7), (int)textH);
   g_atRight = (InpCorner == CORNER_RIGHT_UPPER || InpCorner == CORNER_RIGHT_LOWER);
   g_atBottom = (InpCorner == CORNER_LEFT_LOWER || InpCorner == CORNER_RIGHT_LOWER);
   g_offX = Px(MathMax(0, InpOffsetX));
   g_offY = Px(MathMax(0, InpOffsetY));
//--- state
   g_autoDecided = false;
   g_autoChartH = -1;
   g_layoutCols = -1;
   ArrayInitialize(g_keyW, 0);
   ArrayInitialize(g_valW, 0);
   g_statusText = "";
   g_statusUntil = 0;
   g_lastChartW = -1;
   g_lastChartH = -1;
   g_initTick = GetTickCount64();
//--- a symbol/TF change must not repeat the start-up export or re-open a collapsed panel
   int flags = LoadState();
   g_collapsed = (flags & SSA_FLAG_COLLAPSED) != 0;
   g_exportPending = InpExportOnStart && (flags & SSA_FLAG_CHARTCHANGE) == 0;
   if(g_exportPending)
      WarmHistory();
//--- ATR of the chart symbol; a failed handle only disables the spread/ATR check
   g_atrHandle = iATR(_Symbol, _Period, SSA_ATR_PERIOD);
   if(g_atrHandle == INVALID_HANDLE)
      PrintFormat("SymbolSpecAuditor: iATR handle failed (error %d), spread/ATR check disabled", GetLastError());
   IndicatorSetString(INDICATOR_SHORTNAME, "SymbolSpecAuditor");
   if(!EventSetTimer(1))
     {
      PrintFormat("SymbolSpecAuditor: timer failed (error %d)", GetLastError());
      return(INIT_FAILED);
     }
   Refresh();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_atrHandle != INVALID_HANDLE)
     {
      IndicatorRelease(g_atrHandle);
      g_atrHandle = INVALID_HANDLE;
     }
   ObjectsDeleteAll(0, g_prefix);
   ResetRenderState();
   if(reason == REASON_REMOVE || reason == REASON_CHARTCLOSE || reason == REASON_CLOSE)
      GlobalVariableDel(StateVarName());
   else
      SaveState((g_collapsed ? SSA_FLAG_COLLAPSED : 0) | ((reason == REASON_CHARTCHANGE) ? SSA_FLAG_CHARTCHANGE : 0));
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Name of the per-chart state variable                             |
//+------------------------------------------------------------------+
string StateVarName()
  {
//--- per-chart state that must survive a reload of the indicator; a temporary
//--- global variable, so the terminal drops it when it shuts down
   return("SymbolSpecAuditor_" + IntegerToString(ChartID()));
  }
//+------------------------------------------------------------------+
//| Read the per-chart state flags (0 if none are stored)            |
//+------------------------------------------------------------------+
int LoadState()
  {
   string name = StateVarName();
   if(!GlobalVariableCheck(name))
      return(0);
   return((int)GlobalVariableGet(name));
  }
//+------------------------------------------------------------------+
//| Store the per-chart state flags in a temporary global variable   |
//+------------------------------------------------------------------+
void SaveState(const int flags)
  {
   string name = StateVarName();
   if(!GlobalVariableCheck(name))
      GlobalVariableTemp(name);
   GlobalVariableSet(name, flags);
  }
//+------------------------------------------------------------------+
//| Panel colors: inputs, or a palette that suits the chart          |
//+------------------------------------------------------------------+
void ResolveColors()
  {
//--- "None" inputs take the light or the dark palette depending on the chart background
   g_chartBack = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   bool light = IsLightColor(g_chartBack);
   g_clrText = (InpColorText != clrNONE) ? InpColorText : (light ? C'33,37,41' : C'214,218,225');
   g_clrHeading = (InpColorHeading != clrNONE) ? InpColorHeading : (light ? C'0,86,170' : C'100,180,255');
   g_clrWarning = (InpColorWarning != clrNONE) ? InpColorWarning : (light ? C'190,78,0' : C'255,150,70');
   g_clrOk = (InpColorOk != clrNONE) ? InpColorOk : (light ? C'0,128,60' : C'100,205,130');
   g_clrBack = (InpColorBackground != clrNONE) ? InpColorBackground : (light ? C'248,248,248' : C'24,28,36');
//--- key labels, border and buttons are derived from the text and background colors
   g_clrKey = Blend(g_clrText, g_clrBack, 0.62);
   g_clrBorder = Blend(g_clrText, g_clrBack, 0.25);
   g_clrButton = Blend(g_clrText, g_clrBack, 0.16);
   g_clrButtonBorder = Blend(g_clrText, g_clrBack, 0.40);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer: refresh once per second                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- a pressed button whose click event never arrived is handled here
   if(IsPressed(g_prefix + "Export"))
      DoExport();
   if(IsPressed(g_prefix + "Toggle"))
      DoToggle();
//--- start-up export waits for quotes and bar history of the Market Watch symbols
//--- (or 15 s) so that the file is not full of n/a
   if(g_exportPending &&
      ((SymbolInfoDouble(_Symbol, SYMBOL_BID) > 0.0 && WarmHistory() == 0) || GetTickCount64() - g_initTick > 15000))
     {
      g_exportPending = false;
      DoExport();
     }
   if(g_statusText != "" && GetTickCount64() > g_statusUntil)
      g_statusText = "";
   Refresh();
  }
//+------------------------------------------------------------------+
//| Chart events: buttons and chart resize                           |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == g_prefix + "Export")
        {
         DoExport();
         Refresh();
        }
      else
         if(sparam == g_prefix + "Toggle")
           {
            DoToggle();
            Refresh();
           }
      return;
     }
//--- CHART_CHANGE also fires for scrolling and ticks: re-layout only on a real resize
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
      if(w != g_lastChartW || h != g_lastChartH)
         Refresh();
     }
  }
//+------------------------------------------------------------------+
//| True if the button exists and is in the pressed state            |
//+------------------------------------------------------------------+
bool IsPressed(const string name)
  {
   return(ObjectFind(0, name) >= 0 && ObjectGetInteger(0, name, OBJPROP_STATE) != 0);
  }
//+------------------------------------------------------------------+
//| Collapse / expand button action                                  |
//+------------------------------------------------------------------+
void DoToggle()
  {
   ObjectSetInteger(0, g_prefix + "Toggle", OBJPROP_STATE, false);
   g_collapsed = !g_collapsed;
  }
//+------------------------------------------------------------------+
//| Export button action                                             |
//+------------------------------------------------------------------+
void DoExport()
  {
   ObjectSetInteger(0, g_prefix + "Export", OBJPROP_STATE, false);
   int count = 0;
   string path = "";
   if(ExportCsv(count, path))
     {
      PrintFormat("SymbolSpecAuditor: exported %d symbols to %s", count, path);
      g_statusText = StringFormat("Exported %d symbols", count);
      g_statusClr = g_clrOk;
     }
   else
     {
      g_statusText = "Export failed, see Experts log";
      g_statusClr = g_clrWarning;
     }
   g_statusUntil = GetTickCount64() + SSA_STATUS_MS;
  }
//+------------------------------------------------------------------+
//| Rebuild the panel for the chart symbol                           |
//+------------------------------------------------------------------+
void Refresh()
  {
//--- a new chart background re-picks the automatic colors and redraws every object
   if((color)ChartGetInteger(0, CHART_COLOR_BACKGROUND) != g_chartBack)
     {
      ResolveColors();
      ObjectsDeleteAll(0, g_prefix);
      ResetRenderState();
     }
//--- audit the chart symbol and lay out the panel
   SSymbolAudit audit;
   AuditSymbol(_Symbol, audit, true);
   SPanelRow left[], right[];
   BuildRows(audit, left, right);
   TextSetFont(g_fontName, -10 * g_fontSize);
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   g_lastChartW = chartW;
   g_lastChartH = chartH;
   bool twoCols = ChooseTwoColumns(left, right, audit.warnings, chartH);
   if((twoCols ? 2 : 1) != g_layoutCols)
     {
      //--- column widths only grow (less jitter); start over when the layout changes
      ArrayInitialize(g_keyW, 0);
      ArrayInitialize(g_valW, 0);
      g_layoutCols = twoCols ? 2 : 1;
     }
   int panelW = 0, panelH = 0;
   LayoutPanel(left, right, audit.warnings, twoCols, panelW, panelH);
   if(RenderFrame(panelW, panelH))
      ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Horizontal distance of a panel point from the chart corner       |
//+------------------------------------------------------------------+
int DistX(const int x, const int panelW)
  {
//--- objects are bound to the chosen corner (their top-left point sits at the
//--- distance), so MT5 itself keeps the panel in place when the chart is resized
   return(g_atRight ? g_offX + panelW - x : g_offX + x);
  }
//+------------------------------------------------------------------+
//| Vertical distance of a panel point from the chart corner         |
//+------------------------------------------------------------------+
int DistY(const int y, const int panelH)
  {
   return(g_atBottom ? g_offY + panelH - y : g_offY + y);
  }
//+------------------------------------------------------------------+
//| Decide between the one- and the two-column layout                |
//+------------------------------------------------------------------+
bool ChooseTwoColumns(const SPanelRow &left[], const SPanelRow &right[], const string &warnings[], const int chartH)
  {
//--- auto layout: one column when it fits the chart height; decided again only when
//--- the chart height changes, so a warning that comes and goes cannot flip the layout
   if(InpLayout == SSA_LAYOUT_ONE)
      return(false);
   if(InpLayout == SSA_LAYOUT_TWO)
      return(true);
   if(g_autoDecided && chartH == g_autoChartH)
      return(g_autoTwo);
   if(chartH <= 0)
      return(true);
//--- trial one-column layout; keep the real grow-only widths untouched
   int keyW[2], valW[2];
   ArrayCopy(keyW, g_keyW);
   ArrayCopy(valW, g_valW);
   ArrayInitialize(g_keyW, 0);
   ArrayInitialize(g_valW, 0);
   int w = 0, h = 0;
   LayoutPanel(left, right, warnings, false, w, h);
   ArrayCopy(g_keyW, keyW);
   ArrayCopy(g_valW, valW);
   g_autoTwo = (g_offY + h > chartH);
   g_autoDecided = true;
   g_autoChartH = chartH;
   return(g_autoTwo);
  }
//+------------------------------------------------------------------+
//| Audit one symbol                                                 |
//+------------------------------------------------------------------+
void AuditSymbol(const string sym, SSymbolAudit &audit, const bool useAtrHandle)
  {
//--- useAtrHandle: the chart symbol uses the iATR handle, other symbols
//--- compute the same ATR from CopyRates
   ResetAudit(audit);
   audit.symbol = sym;
   audit.description = SymbolInfoString(sym, SYMBOL_DESCRIPTION);
   audit.path = SymbolInfoString(sym, SYMBOL_PATH);
   audit.custom = (bool)SymbolInfoInteger(sym, SYMBOL_CUSTOM);
   audit.calcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(sym, SYMBOL_TRADE_CALC_MODE);
   audit.baseCcy = SymbolInfoString(sym, SYMBOL_CURRENCY_BASE);
   audit.profitCcy = SymbolInfoString(sym, SYMBOL_CURRENCY_PROFIT);
   audit.marginCcy = SymbolInfoString(sym, SYMBOL_CURRENCY_MARGIN);
   audit.accountCcy = AccountInfoString(ACCOUNT_CURRENCY);
   audit.accountLeverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   audit.digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   audit.point = SymbolInfoDouble(sym, SYMBOL_POINT);
   audit.tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
//--- reading the tick value makes the terminal select the symbol it converts the
//--- profit currency with, so it is only read when that pair is in Market Watch
   if(TickValueReadable(audit))
     {
      audit.tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
      audit.tickValueProfit = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE_PROFIT);
      audit.tickValueLoss = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE_LOSS);
     }
   else
      audit.tickNote = "no quoted " + MajorOf(audit.profitCcy) + "/" + MajorOf(audit.accountCcy) + " symbol in Market Watch";
   audit.contractSize = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
   audit.expirationTime = (datetime)SymbolInfoInteger(sym, SYMBOL_EXPIRATION_TIME);
   ClassifyAsset(audit);
   audit.bid = SymbolInfoDouble(sym, SYMBOL_BID);
   audit.ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double last = SymbolInfoDouble(sym, SYMBOL_LAST);
   if(audit.bid > 0.0)
      audit.refPrice = audit.bid;
   else
      if(last > 0.0)
         audit.refPrice = last;
//--- money per point, two independent ways
   if(audit.tickSize > 0.0 && audit.point > 0.0 && audit.tickValue > 0.0)
      audit.pointValue = audit.tickValue * audit.point / audit.tickSize;
   CalcPointValueCheck(audit);
   if(Has(audit.pointValue) && Has(audit.pointValueCheck))
     {
      double ref = MathMax(MathAbs(audit.pointValue), MathAbs(audit.pointValueCheck));
      if(ref > 0.0)
         audit.checkDiffPct = 100.0 * MathAbs(audit.pointValue - audit.pointValueCheck) / ref;
     }
   double pv = Has(audit.pointValue) ? audit.pointValue : audit.pointValueCheck;
   if(Has(pv) && audit.point > 0.0)
      audit.priceUnitValue = pv / audit.point;
//--- spread
   if(audit.bid > 0.0 && audit.ask > 0.0 && audit.point > 0.0)
     {
      audit.spreadPoints = MathRound((audit.ask - audit.bid) / audit.point);
      if(Has(pv))
         audit.spreadMoney = audit.spreadPoints * pv;
     }
   audit.atrPoints = useAtrHandle ? AtrFromHandle(audit.point, audit.atrNote) : AtrFromRates(sym, audit.point, audit.atrNote);
   if(Has(audit.atrPoints) && audit.atrPoints > 0.0 && Has(audit.spreadPoints))
      audit.spreadPctAtr = 100.0 * audit.spreadPoints / audit.atrPoints;
//--- volume
   audit.volMin = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   audit.volStep = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   audit.volMax = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   audit.volLimit = SymbolInfoDouble(sym, SYMBOL_VOLUME_LIMIT);
//--- money
   CalcMargin(audit);
   CalcNotional(audit);
   CalcSwap(audit);
//--- execution
   audit.tradeMode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(sym, SYMBOL_TRADE_MODE);
   audit.execMode = (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(sym, SYMBOL_TRADE_EXEMODE);
   audit.fillingFlags = (int)SymbolInfoInteger(sym, SYMBOL_FILLING_MODE);
   audit.orderFlags = (int)SymbolInfoInteger(sym, SYMBOL_ORDER_MODE);
   audit.expirationFlags = (int)SymbolInfoInteger(sym, SYMBOL_EXPIRATION_MODE);
   audit.gtcMode = (ENUM_SYMBOL_ORDER_GTC_MODE)SymbolInfoInteger(sym, SYMBOL_ORDER_GTC_MODE);
   audit.stopsLevel = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   audit.freezeLevel = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   TodaySessions(sym, audit.sessionDay, audit.sessions);
   BuildWarnings(audit);
  }
//+------------------------------------------------------------------+
//| Tick value can be read without adding a symbol to Market Watch   |
//+------------------------------------------------------------------+
bool TickValueReadable(const SSymbolAudit &audit)
  {
   string profit = audit.profitCcy, acc = audit.accountCcy;
   if(profit == "" || acc == "" || profit == acc)
      return(true);
//--- cent units convert through their major currency without a symbol
   string profitMajor = (CentMajor(profit) != "") ? CentMajor(profit) : profit;
   string accMajor = (CentMajor(acc) != "") ? CentMajor(acc) : acc;
   if(profitMajor == accMajor)
      return(true);
//--- otherwise a Market Watch symbol must link the two currencies directly
   string sym = "";
   bool inverse = false;
   return(FindPair(profitMajor, accMajor, sym, inverse));
  }
//+------------------------------------------------------------------+
//| Set every field of an audit to "unknown"                         |
//+------------------------------------------------------------------+
void ResetAudit(SSymbolAudit &audit)
  {
   audit.symbol = "";
   audit.description = "";
   audit.path = "";
   audit.custom = false;
   audit.calcMode = SYMBOL_CALC_MODE_FOREX;
   audit.baseCcy = "";
   audit.profitCcy = "";
   audit.marginCcy = "";
   audit.accountCcy = "";
   audit.accountLeverage = 0;
   audit.assetClass = "";
   audit.standardContract = 0.0;
   audit.digits = 0;
   audit.point = 0.0;
   audit.tickSize = 0.0;
   audit.tickValue = 0.0;
   audit.tickValueProfit = 0.0;
   audit.tickValueLoss = 0.0;
   audit.tickNote = "";
   audit.contractSize = 0.0;
   audit.expirationTime = 0;
   audit.bid = 0.0;
   audit.ask = 0.0;
   audit.refPrice = SSA_NA;
   audit.pointValue = SSA_NA;
   audit.pointValueCheck = SSA_NA;
   audit.checkNote = "";
   audit.checkDiffPct = SSA_NA;
   audit.priceUnitValue = SSA_NA;
   audit.spreadPoints = SSA_NA;
   audit.spreadMoney = SSA_NA;
   audit.atrPoints = SSA_NA;
   audit.atrNote = "";
   audit.spreadPctAtr = SSA_NA;
   audit.volMin = 0.0;
   audit.volStep = 0.0;
   audit.volMax = 0.0;
   audit.volLimit = 0.0;
   audit.marginRateBuy = SSA_NA;
   audit.marginRateSell = SSA_NA;
   audit.marginBuy = SSA_NA;
   audit.marginSell = SSA_NA;
   audit.marginNote = "";
   audit.notional = SSA_NA;
   audit.notionalCcy = "";
   audit.leverage = SSA_NA;
   audit.swapMode = SYMBOL_SWAP_MODE_DISABLED;
   audit.swapLong = 0.0;
   audit.swapShort = 0.0;
   audit.swapUnit = "";
   audit.swapLongMoney = SSA_NA;
   audit.swapShortMoney = SSA_NA;
   audit.swap3Day = WEDNESDAY;
   audit.tradeMode = SYMBOL_TRADE_MODE_FULL;
   audit.execMode = SYMBOL_TRADE_EXECUTION_MARKET;
   audit.fillingFlags = 0;
   audit.orderFlags = 0;
   audit.expirationFlags = 0;
   audit.gtcMode = SYMBOL_ORDERS_GTC;
   audit.stopsLevel = 0;
   audit.freezeLevel = 0;
   audit.sessionDay = "";
   ArrayResize(audit.sessions, 0);
   ArrayResize(audit.warnings, 0);
  }
//+------------------------------------------------------------------+
//| Asset class and its usual contract size (forex, gold, silver)    |
//+------------------------------------------------------------------+
void ClassifyAsset(SSymbolAudit &audit)
  {
   string upper = audit.symbol;
   StringToUpper(upper);
   audit.assetClass = "";
   audit.standardContract = 0.0;
//--- metals are recognised by the base currency or the symbol name
   if(audit.baseCcy == "XAU" || StringFind(upper, "XAU") >= 0)
     {
      audit.assetClass = "gold";
      audit.standardContract = 100.0;
      return;
     }
   if(audit.baseCcy == "XAG" || StringFind(upper, "XAG") >= 0)
     {
      audit.assetClass = "silver";
      audit.standardContract = 5000.0;
      return;
     }
//--- forex: a forex calc mode and two fiat currencies (BTCUSD and the like are not forex)
   if((audit.calcMode == SYMBOL_CALC_MODE_FOREX || audit.calcMode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE) &&
      IsFiat(audit.baseCcy) && IsFiat(audit.profitCcy))
     {
      audit.assetClass = "forex";
      audit.standardContract = 100000.0;
     }
  }
//+------------------------------------------------------------------+
//| Point value from the contract size (cross-check of tick value)   |
//+------------------------------------------------------------------+
void CalcPointValueCheck(SSymbolAudit &audit)
  {
//--- indicators may not call OrderCalcProfit (error 4014), so this applies the
//--- documented profit formula of the calc mode: (close - open) * contract size,
//--- converted into the account currency
   switch(audit.calcMode)
     {
      case SYMBOL_CALC_MODE_FOREX:
      case SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE:
      case SYMBOL_CALC_MODE_CFD:
      case SYMBOL_CALC_MODE_CFDINDEX:
      case SYMBOL_CALC_MODE_CFDLEVERAGE:
      case SYMBOL_CALC_MODE_EXCH_STOCKS:
      case SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX:
        {
         if(audit.contractSize <= 0.0 || audit.point <= 0.0)
           {
            audit.checkNote = "no contract size";
            return;
           }
         double rate = RateToAccount(audit.profitCcy, 0);
         if(!Has(rate))
           {
            audit.checkNote = "no " + audit.profitCcy + "->" + audit.accountCcy + " rate";
            return;
           }
         audit.pointValueCheck = audit.contractSize * audit.point * rate;
         return;
        }
      default:
         //--- futures and bonds define profit through the tick value itself
         audit.checkNote = "tick value is the spec here";
     }
  }
//+------------------------------------------------------------------+
//| Margin for 1.00 lot in the account currency                      |
//+------------------------------------------------------------------+
void CalcMargin(SSymbolAudit &audit)
  {
//--- OrderCalcMargin is not available to indicators either, so the documented
//--- margin formulas are used: a non-zero SYMBOL_MARGIN_INITIAL replaces the formula,
//--- the result is multiplied by the initial margin rate and converted from the
//--- margin currency at ask for buys and at bid for sells
   if(audit.bid <= 0.0 || audit.ask <= 0.0)
     {
      audit.marginNote = "no quotes";
      return;
     }
   double initBuy = 0.0, maintBuy = 0.0, initSell = 0.0, maintSell = 0.0;
   if(!SymbolInfoMarginRate(audit.symbol, ORDER_TYPE_BUY, initBuy, maintBuy) ||
      !SymbolInfoMarginRate(audit.symbol, ORDER_TYPE_SELL, initSell, maintSell))
     {
      audit.marginNote = "no margin rate";
      return;
     }
   audit.marginRateBuy = initBuy;
   audit.marginRateSell = initSell;
   if(initBuy <= 0.0 && initSell <= 0.0)
     {
      audit.marginNote = "margin rate is 0";
      return;
     }
//--- margin in the margin currency, by calc mode
   double lev = (double)audit.accountLeverage;
   double fixedMargin = SymbolInfoDouble(audit.symbol, SYMBOL_MARGIN_INITIAL);
   double cs = audit.contractSize;
   double baseBuy = SSA_NA, baseSell = SSA_NA;
   string ccy = (audit.marginCcy != "") ? audit.marginCcy : audit.baseCcy;
   switch(audit.calcMode)
     {
      case SYMBOL_CALC_MODE_FOREX:
         if(lev > 0.0)
            baseBuy = baseSell = ((fixedMargin > 0.0) ? fixedMargin : cs) / lev;
         break;
      case SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE:
         baseBuy = baseSell = (fixedMargin > 0.0) ? fixedMargin : cs;
         break;
      case SYMBOL_CALC_MODE_CFD:
         baseBuy = (fixedMargin > 0.0) ? fixedMargin : cs * audit.ask;
         baseSell = (fixedMargin > 0.0) ? fixedMargin : cs * audit.bid;
         break;
      case SYMBOL_CALC_MODE_CFDLEVERAGE:
         if(lev > 0.0)
           {
            baseBuy = ((fixedMargin > 0.0) ? fixedMargin : cs * audit.ask) / lev;
            baseSell = ((fixedMargin > 0.0) ? fixedMargin : cs * audit.bid) / lev;
           }
         break;
      case SYMBOL_CALC_MODE_CFDINDEX:
         //--- the formula uses the tick price in the profit currency; MQL5 reports the tick
         //--- value in the account currency, so only the unambiguous case is modelled
         if(fixedMargin > 0.0)
            baseBuy = baseSell = fixedMargin;
         else
            if(audit.tickSize > 0.0 && audit.profitCcy == audit.accountCcy && ccy == audit.accountCcy)
              {
               baseBuy = cs * audit.ask * audit.tickValue / audit.tickSize;
               baseSell = cs * audit.bid * audit.tickValue / audit.tickSize;
              }
         break;
      case SYMBOL_CALC_MODE_EXCH_STOCKS:
      case SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX:
        {
         double last = SymbolInfoDouble(audit.symbol, SYMBOL_LAST);
         baseBuy = (fixedMargin > 0.0) ? fixedMargin : cs * ((last > 0.0) ? last : audit.ask);
         baseSell = (fixedMargin > 0.0) ? fixedMargin : cs * ((last > 0.0) ? last : audit.bid);
         break;
        }
      case SYMBOL_CALC_MODE_FUTURES:
      case SYMBOL_CALC_MODE_EXCH_FUTURES:
      case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS:
         if(fixedMargin > 0.0)
            baseBuy = baseSell = fixedMargin;
         break;
      default:
         break;
     }
   if(!Has(baseBuy) || !Has(baseSell))
     {
      bool usesLeverage = (audit.calcMode == SYMBOL_CALC_MODE_FOREX || audit.calcMode == SYMBOL_CALC_MODE_CFDLEVERAGE);
      audit.marginNote = (usesLeverage && lev <= 0.0) ? "account leverage is 0" : "not modelled for " + CalcModeText(audit.calcMode);
      return;
     }
//--- conversion into the account currency
   double convBuy = RateToAccount(ccy, 1), convSell = RateToAccount(ccy, -1);
   if(!Has(convBuy) || !Has(convSell))
     {
      audit.marginNote = "no " + ccy + "->" + audit.accountCcy + " rate";
      return;
     }
//--- a side with a zero margin rate is shown as n/a, not as a free position
   if(initBuy > 0.0)
      audit.marginBuy = baseBuy * initBuy * convBuy;
   else
      audit.marginNote = "buy margin rate is 0";
   if(initSell > 0.0)
      audit.marginSell = baseSell * initSell * convSell;
   else
      audit.marginNote = "sell margin rate is 0";
  }
//+------------------------------------------------------------------+
//| Notional value of 1.00 lot and effective leverage                |
//+------------------------------------------------------------------+
void CalcNotional(SSymbolAudit &audit)
  {
   if(!Has(audit.refPrice))
      return;
   switch(audit.calcMode)
     {
      case SYMBOL_CALC_MODE_FUTURES:
      case SYMBOL_CALC_MODE_EXCH_FUTURES:
      case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS:
         //--- futures: the tick value already is money per tick in the account currency
         if(audit.tickSize > 0.0 && audit.tickValue > 0.0)
           {
            audit.notional = audit.refPrice / audit.tickSize * audit.tickValue;
            audit.notionalCcy = audit.accountCcy;
           }
         break;
      case SYMBOL_CALC_MODE_EXCH_BONDS:
      case SYMBOL_CALC_MODE_EXCH_BONDS_MOEX:
      case SYMBOL_CALC_MODE_SERV_COLLATERAL:
         break;
      default:
        {
         if(audit.contractSize <= 0.0)
            break;
         double rate = RateToAccount(audit.profitCcy, 0);
         if(Has(rate))
           {
            audit.notional = audit.contractSize * audit.refPrice * rate;
            audit.notionalCcy = audit.accountCcy;
           }
         else
           {
            //--- no conversion path: show it in the profit currency, leverage stays n/a
            audit.notional = audit.contractSize * audit.refPrice;
            audit.notionalCcy = audit.profitCcy;
           }
        }
     }
//--- effective leverage = notional / margin (buy side, or sell side if buy is n/a)
   double margin = Has(audit.marginBuy) ? audit.marginBuy : audit.marginSell;
   if(Has(audit.notional) && audit.notionalCcy == audit.accountCcy && Has(margin) && margin > 0.0)
      audit.leverage = audit.notional / margin;
  }
//+------------------------------------------------------------------+
//| Swap per 1.00 lot per night in the account currency              |
//+------------------------------------------------------------------+
void CalcSwap(SSymbolAudit &audit)
  {
   audit.swapMode = (ENUM_SYMBOL_SWAP_MODE)SymbolInfoInteger(audit.symbol, SYMBOL_SWAP_MODE);
   audit.swapLong = SymbolInfoDouble(audit.symbol, SYMBOL_SWAP_LONG);
   audit.swapShort = SymbolInfoDouble(audit.symbol, SYMBOL_SWAP_SHORT);
   audit.swap3Day = (ENUM_DAY_OF_WEEK)SymbolInfoInteger(audit.symbol, SYMBOL_SWAP_ROLLOVER3DAYS);
   double perUnit = SSA_NA;
   switch(audit.swapMode)
     {
      case SYMBOL_SWAP_MODE_DISABLED:
         audit.swapUnit = "";
         perUnit = 0.0;
         break;
      case SYMBOL_SWAP_MODE_POINTS:
         audit.swapUnit = "pts";
         perUnit = Has(audit.pointValue) ? audit.pointValue : audit.pointValueCheck;
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
         audit.swapUnit = audit.baseCcy;
         perUnit = RateToAccount(audit.baseCcy, 0);
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
         audit.swapUnit = audit.marginCcy;
         perUnit = RateToAccount(audit.marginCcy, 0);
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         audit.swapUnit = audit.accountCcy;
         perUnit = 1.0;
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_PROFIT:
         audit.swapUnit = audit.profitCcy;
         perUnit = RateToAccount(audit.profitCcy, 0);
         break;
      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
         //--- annual interest on the position value, 360-day bank year
         audit.swapUnit = "% p.a.";
         if(Has(audit.notional) && audit.notionalCcy == audit.accountCcy)
            perUnit = audit.notional / 100.0 / 360.0;
         break;
      default:
         //--- reopen modes shift the reopen price; no fixed money amount
         audit.swapUnit = "pts (reopen)";
         break;
     }
   if(Has(perUnit))
     {
      audit.swapLongMoney = audit.swapLong * perUnit;
      audit.swapShortMoney = audit.swapShort * perUnit;
     }
  }
//+------------------------------------------------------------------+
//| ATR(14) of the last closed bar from the iATR handle, in points   |
//+------------------------------------------------------------------+
double AtrFromHandle(const double point, string &note)
  {
   note = "";
   if(g_atrHandle == INVALID_HANDLE || point <= 0.0)
     {
      note = "unavailable";
      return(SSA_NA);
     }
   if(BarsCalculated(g_atrHandle) < SSA_ATR_PERIOD + 2)
     {
      note = "loading";
      return(SSA_NA);
     }
   double buf[];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, buf) != 1 || buf[0] == EMPTY_VALUE || buf[0] <= 0.0)
     {
      note = "loading";
      return(SSA_NA);
     }
   return(buf[0] / point);
  }
//+------------------------------------------------------------------+
//| ATR(14) of the last closed bar from the bar history, in points   |
//+------------------------------------------------------------------+
double AtrFromRates(const string sym, const double point, string &note)
  {
//--- same value as iATR(14) (simple average of the true range), for symbols
//--- that have no indicator handle
   note = "";
   if(point <= 0.0)
     {
      note = "unavailable";
      return(SSA_NA);
     }
   MqlRates rates[];
   int need = SSA_ATR_PERIOD + 1;
//--- oldest first: rates[0] only supplies the previous close
   if(CopyRates(sym, _Period, 1, need, rates) < need)
     {
      note = "history loading, export again";
      return(SSA_NA);
     }
   double sum = 0.0;
   for(int i = 1; i < need; i++)
      sum += MathMax(rates[i].high, rates[i - 1].close) - MathMin(rates[i].low, rates[i - 1].close);
   if(sum <= 0.0)
     {
      note = "no range";
      return(SSA_NA);
     }
   return(sum / SSA_ATR_PERIOD / point);
  }
//+------------------------------------------------------------------+
//| Request the bars the ATR needs on every Market Watch symbol      |
//+------------------------------------------------------------------+
int WarmHistory()
  {
//--- indicators never wait for data: the first request only starts the history
//--- load. Returns the number of symbols that are not ready yet
   int missing = 0, total = SymbolsTotal(true), need = SSA_ATR_PERIOD + 1;
   MqlRates rates[];
   for(int i = 0; i < total; i++)
     {
      string sym = SymbolName(i, true);
      if(sym != "" && CopyRates(sym, _Period, 1, need, rates) < need)
         missing++;
     }
   return(missing);
  }
//+------------------------------------------------------------------+
//| Today's trade sessions (server time)                             |
//+------------------------------------------------------------------+
void TodaySessions(const string sym, string &dayName, string &list[])
  {
   ArrayResize(list, 0);
   MqlDateTime now;
   TimeToStruct(TimeTradeServer(), now);
   ENUM_DAY_OF_WEEK day = (ENUM_DAY_OF_WEEK)now.day_of_week;
   dayName = DayName(day);
   datetime from = 0, to = 0;
   for(uint i = 0; i < 32; i++)
     {
      if(!SymbolInfoSessionTrade(sym, day, i, from, to))
         break;
      int n = ArraySize(list);
      ArrayResize(list, n + 1);
      list[n] = HhMm(from) + "-" + HhMm(to);
     }
  }
//+------------------------------------------------------------------+
//| Traps, most serious first                                        |
//+------------------------------------------------------------------+
void BuildWarnings(SSymbolAudit &audit)
  {
//--- contract size against the usual size of its asset class
   double standard = audit.standardContract;
   if(standard > 0.0 && audit.contractSize > 0.0 && MathAbs(audit.contractSize - standard) > standard * 1e-9)
     {
      double factor = MathMax(audit.contractSize, standard) / MathMin(audit.contractSize, standard);
      AddWarning(audit, StringFormat("Contract size %s (%s usually %s): a lot-size formula that assumes the standard contract is off by x%s.",
                                     Trim0(audit.contractSize, 8), audit.assetClass, Trim0(standard, 0), Trim0(factor, 2)));
     }
//--- tick value (not checked when it was not read)
   if(audit.tickSize <= 0.0)
      AddWarning(audit, "Tick size is 0: lot formulas that divide by it fail.");
   else
      if(audit.tickNote == "" && audit.tickValue <= 0.0)
         AddWarning(audit, "Tick value is 0: lot formulas that use it return 0 or divide by zero.");
      else
         if(Has(audit.checkDiffPct) && audit.checkDiffPct > 1.0)
            AddWarning(audit, StringFormat("Point value %s %s from tick value but %s from contract size (%.1f%% apart): tick-value lot sizing will be off.",
                                           Money(audit.pointValue), audit.accountCcy, Money(audit.pointValueCheck), audit.checkDiffPct));
//--- cent account
   if(IsCentCurrency(audit.accountCcy))
      AddWarning(audit, StringFormat("Account currency %s is a cent unit: balance, tick value and margin are in cents (100x the dollar figure).",
                                     audit.accountCcy));
//--- trade mode
   switch(audit.tradeMode)
     {
      case SYMBOL_TRADE_MODE_DISABLED:
         AddWarning(audit, "Trading is disabled for this symbol: every order is rejected.");
         break;
      case SYMBOL_TRADE_MODE_LONGONLY:
         AddWarning(audit, "Trade mode is long only: sell orders are rejected.");
         break;
      case SYMBOL_TRADE_MODE_SHORTONLY:
         AddWarning(audit, "Trade mode is short only: buy orders are rejected.");
         break;
      case SYMBOL_TRADE_MODE_CLOSEONLY:
         AddWarning(audit, "Trade mode is close only: new positions cannot be opened.");
         break;
      default:
         break;
     }
//--- futures and other expiring contracts
   if(audit.expirationTime > 0)
      AddWarning(audit, StringFormat("Expiring contract: the symbol expires on %s (server time); close or roll positions before then.",
                                     TimeToString(audit.expirationTime, TIME_DATE | TIME_MINUTES)));
//--- quotes and price grid
   if(audit.bid <= 0.0 || audit.ask <= 0.0)
      AddWarning(audit, "No current bid/ask: spread, margin and point value checks are not possible.");
   if(audit.tickSize > 0.0 && audit.point > 0.0 && MathAbs(audit.tickSize - audit.point) > audit.point * 1e-6)
      AddWarning(audit, StringFormat("Tick size %s differs from point %s: order prices off the tick grid are rejected.",
                                     Trim0(audit.tickSize, 8), Trim0(audit.point, 8)));
//--- distances
   int d = MathMax(0, MathMin(8, audit.digits));
   if(audit.stopsLevel > 0)
      AddWarning(audit, StringFormat("Stops level %d pts (%s): SL, TP and pending orders closer than this to the price are rejected.",
                                     audit.stopsLevel, DoubleToString(audit.stopsLevel * audit.point, d)));
   if(audit.freezeLevel > 0)
      AddWarning(audit, StringFormat("Freeze level %d pts (%s): orders, SL and TP this close to the price cannot be modified or deleted.",
                                     audit.freezeLevel, DoubleToString(audit.freezeLevel * audit.point, d)));
//--- order lifetime (GTC mode)
   if(audit.gtcMode == SYMBOL_ORDERS_DAILY)
      AddWarning(audit, "Orders are daily (GTC mode): SL/TP and pending orders are deleted at the end of the trading day.");
   if(audit.gtcMode == SYMBOL_ORDERS_DAILY_EXCLUDING_STOPS)
      AddWarning(audit, "Orders are daily excluding stops (GTC mode): pending orders are deleted at the end of the trading day, SL/TP are kept.");
//--- volume; 0.01 is the usual minimum and step of forex and CFD symbols only
   if(IsForexOrCfd(audit.calcMode) && audit.volMin > 0.01 + 1e-9)
      AddWarning(audit, StringFormat("Minimum volume %s lots (usually 0.01 for forex/CFD): small risk-based lot sizes cannot be opened.",
                                     Trim0(audit.volMin, 8)));
   if(IsForexOrCfd(audit.calcMode) && audit.volStep > 0.01 + 1e-9)
      AddWarning(audit, StringFormat("Volume step %s lots (usually 0.01 for forex/CFD): lots must be rounded to this step, which shifts the risk per trade.",
                                     Trim0(audit.volStep, 8)));
//--- spread against volatility
   if(InpSpreadWarnPctAtr > 0.0 && Has(audit.spreadPctAtr) && audit.spreadPctAtr > InpSpreadWarnPctAtr)
      AddWarning(audit, StringFormat("Spread %s pts is %.1f%% of ATR(14) %s (%s pts): stops and targets sized in ATR lose a large share to the spread.",
                                     Trim0(audit.spreadPoints, 0), audit.spreadPctAtr, TfName(), Trim0(MathRound(audit.atrPoints), 0)));
//--- swap calendar
   if(IsOddTripleSwap(audit))
      AddWarning(audit, StringFormat("Triple swap is charged on %s (forex and metals usually Wednesday): holding over that night costs three days of swap.",
                                     DayName(audit.swap3Day)));
  }
//+------------------------------------------------------------------+
//| Triple swap on an unusual day for forex or a metal               |
//+------------------------------------------------------------------+
bool IsOddTripleSwap(const SSymbolAudit &audit)
  {
//--- irrelevant when there is no swap at all; indices and crypto often roll the
//--- triple swap on Friday, so only forex and metals are checked
   if(audit.swapMode == SYMBOL_SWAP_MODE_DISABLED || (audit.swapLong == 0.0 && audit.swapShort == 0.0))
      return(false);
   if(audit.assetClass == "" || !IsWeekday(audit.swap3Day) || audit.swap3Day == WEDNESDAY)
      return(false);
//--- spot settles T+2, so the Wednesday rollover carries the weekend; USD against
//--- CAD, TRY, RUB or PHP settles T+1, and some brokers roll these on Thursday
   return(!(audit.swap3Day == THURSDAY && IsTPlusOnePair(audit)));
  }
//+------------------------------------------------------------------+
//| USD against a currency with next-day (T+1) spot settlement       |
//+------------------------------------------------------------------+
bool IsTPlusOnePair(const SSymbolAudit &audit)
  {
   if(audit.assetClass != "forex")
      return(false);
   string other = (audit.baseCcy == "USD") ? audit.profitCcy : ((audit.profitCcy == "USD") ? audit.baseCcy : "");
   return(other != "" && StringFind(" CAD TRY RUB PHP ", " " + other + " ") >= 0);
  }
//+------------------------------------------------------------------+
//| True for Sunday..Saturday (brokers may store other values)       |
//+------------------------------------------------------------------+
bool IsWeekday(const ENUM_DAY_OF_WEEK day)
  {
   return(day >= SUNDAY && day <= SATURDAY);
  }
//+------------------------------------------------------------------+
//| Triple-swap day as text                                          |
//+------------------------------------------------------------------+
string TripleSwapDayText(const ENUM_DAY_OF_WEEK day)
  {
   if(IsWeekday(day))
      return(DayName(day));
   return("not set (" + IntegerToString((int)day) + ")");
  }
//+------------------------------------------------------------------+
//| Forex and CFD calc modes (OTC symbols with a 0.01 lot grid)      |
//+------------------------------------------------------------------+
bool IsForexOrCfd(const ENUM_SYMBOL_CALC_MODE mode)
  {
   return(mode == SYMBOL_CALC_MODE_FOREX || mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE || mode == SYMBOL_CALC_MODE_CFD ||
          mode == SYMBOL_CALC_MODE_CFDINDEX || mode == SYMBOL_CALC_MODE_CFDLEVERAGE);
  }
//+------------------------------------------------------------------+
//| Append a warning line to the audit                               |
//+------------------------------------------------------------------+
void AddWarning(SSymbolAudit &audit, const string text)
  {
   int n = ArraySize(audit.warnings);
   ArrayResize(audit.warnings, n + 1);
   audit.warnings[n] = text;
  }
//+------------------------------------------------------------------+
//| Panel rows of the left and the right column                      |
//+------------------------------------------------------------------+
void BuildRows(const SSymbolAudit &audit, SPanelRow &left[], SPanelRow &right[])
  {
   ArrayResize(left, 0);
   ArrayResize(right, 0);
   string acc = " " + audit.accountCcy;
//--- identity
   AddHeading(left, "IDENTITY");
   AddPair(left, "Symbol", audit.symbol + (audit.custom ? " (custom)" : ""));
   AddPair(left, "Description", Fit(audit.description));
   AddPair(left, "Path", FitLeft(audit.path));
   AddPair(left, "Calc mode", CalcModeText(audit.calcMode));
   AddPair(left, "Currencies", "base " + NaText(audit.baseCcy) + ", profit " + NaText(audit.profitCcy) + ", margin " + NaText(audit.marginCcy));
   string account = audit.accountCcy + ", 1:" + IntegerToString(audit.accountLeverage);
   string marginMode = MarginModeText();
   if(marginMode != "")
      account += ", " + marginMode;
   AddPair(left, "Account", account);
//--- price and contract
   AddHeading(left, "PRICE & CONTRACT");
   AddPair(left, "Digits/point", IntegerToString(audit.digits) + " / " + Trim0(audit.point, 8));
   AddPair(left, "Tick size", Trim0(audit.tickSize, 8));
   string tick = Trim0(audit.tickValue, 8) + acc;
   if(MathAbs(audit.tickValueLoss - audit.tickValueProfit) > 1e-10)
      tick += " (loss " + Trim0(audit.tickValueLoss, 8) + ")";
   if(audit.tickNote != "")
      AddPair(left, "Tick value", "n/a (" + audit.tickNote + ")", g_clrKey);
   else
      AddPair(left, "Tick value", tick, (audit.tickValue > 0.0) ? clrNONE : g_clrWarning);
   bool fxUnit = (audit.calcMode == SYMBOL_CALC_MODE_FOREX || audit.calcMode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE) && audit.baseCcy != "";
   AddPair(left, "Contract", Trim0(audit.contractSize, 8) + " " + (fxUnit ? audit.baseCcy : ((audit.contractSize == 1.0) ? "unit" : "units")) + " per lot");
   if(audit.expirationTime > 0)
      AddPair(left, "Expires", TimeToString(audit.expirationTime, TIME_DATE | TIME_MINUTES) + " (server)", g_clrWarning);
//--- money per move
   AddHeading(left, "MONEY PER 1.00 LOT");
   if(Has(audit.pointValue))
      AddPair(left, "1 point", Money(audit.pointValue) + acc);
   else
      if(audit.tickNote != "")
         AddPair(left, "1 point", "n/a (tick value not read)", g_clrKey);
      else
         AddPair(left, "1 point", "n/a (tick value/size is 0)", g_clrWarning);
   if(Has(audit.pointValueCheck))
     {
      bool match = !Has(audit.checkDiffPct) || audit.checkDiffPct <= 1.0;
      string verdict = !Has(audit.checkDiffPct) ? "" : (match ? ", match" : StringFormat(", %.1f%% off", audit.checkDiffPct));
      AddPair(left, "Check", Money(audit.pointValueCheck) + acc + " by contract" + verdict, match ? g_clrOk : g_clrWarning);
     }
   else
      AddPair(left, "Check", "n/a (" + audit.checkNote + ")", g_clrKey);
   AddPair(left, "1.00 move", Money(audit.priceUnitValue) + (Has(audit.priceUnitValue) ? acc : ""));
   if(Has(audit.spreadPoints))
      AddPair(left, "Spread", Trim0(audit.spreadPoints, 0) + " pts" + (Has(audit.spreadMoney) ? " = " + Money(audit.spreadMoney) + acc : ""));
   else
      AddPair(left, "Spread", "n/a (no quotes)");
   string atrKey = "ATR(14) " + TfName();
   if(Has(audit.atrPoints))
     {
      string atr = Trim0(MathRound(audit.atrPoints), 0) + " pts";
      if(Has(audit.spreadPctAtr))
         atr += StringFormat(", spread %.1f%%", audit.spreadPctAtr);
      bool high = InpSpreadWarnPctAtr > 0.0 && Has(audit.spreadPctAtr) && audit.spreadPctAtr > InpSpreadWarnPctAtr;
      AddPair(left, atrKey, atr, high ? g_clrWarning : clrNONE);
     }
   else
      AddPair(left, atrKey, "n/a (" + audit.atrNote + ")", g_clrKey);
//--- volume
   AddHeading(left, "VOLUME (LOTS)");
   bool coarse = IsForexOrCfd(audit.calcMode) && (audit.volMin > 0.01 + 1e-9 || audit.volStep > 0.01 + 1e-9);
   AddPair(left, "Min / step", Trim0(audit.volMin, 8) + " / " + Trim0(audit.volStep, 8), coarse ? g_clrWarning : clrNONE);
   AddPair(left, "Max / limit", Trim0(audit.volMax, 8) + " / " + ((audit.volLimit > 0.0) ? Trim0(audit.volLimit, 8) : "none"));
//--- margin; one side can be n/a when only its margin rate is 0
   AddHeading(right, "MARGIN (1.00 LOT)");
   if(Has(audit.marginBuy) || Has(audit.marginSell))
      AddPair(right, "Buy / sell", Money(audit.marginBuy) + " / " + Money(audit.marginSell) + acc);
   else
      AddPair(right, "Buy / sell", "n/a (" + audit.marginNote + ")", g_clrKey);
   if(Has(audit.marginRateBuy))
      AddPair(right, "Margin rate", Trim0(audit.marginRateBuy, 4) + " / " + Trim0(audit.marginRateSell, 4));
   else
      AddPair(right, "Margin rate", "n/a", g_clrKey);
   if(Has(audit.notional))
      AddPair(right, "Notional", Money(audit.notional) + " " + audit.notionalCcy + ((audit.notionalCcy != audit.accountCcy) ? " (not converted)" : ""));
   else
      AddPair(right, "Notional", "n/a", g_clrKey);
   string accountLeverage = "account 1:" + IntegerToString(audit.accountLeverage);
   if(Has(audit.leverage))
      AddPair(right, "Leverage", "1:" + LeverageText(audit.leverage) + " (" + accountLeverage + ")");
   else
      AddPair(right, "Leverage", "n/a (" + accountLeverage + ")", g_clrKey);
//--- swap
   AddHeading(right, "SWAP (1.00 LOT)");
   AddPair(right, "Mode", SwapModeText(audit.swapMode));
   if(audit.swapMode != SYMBOL_SWAP_MODE_DISABLED)
     {
      AddPair(right, "Long / short", Trim0(audit.swapLong, 4) + " / " + Trim0(audit.swapShort, 4) + " " + audit.swapUnit);
      if(Has(audit.swapLongMoney))
         AddPair(right, "Per night", Money(audit.swapLongMoney) + " / " + Money(audit.swapShortMoney) + acc);
      else
         AddPair(right, "Per night", "n/a", g_clrKey);
      AddPair(right, "Triple swap", TripleSwapDayText(audit.swap3Day), IsOddTripleSwap(audit) ? g_clrWarning : clrNONE);
     }
//--- execution
   int d = MathMax(0, MathMin(8, audit.digits));
   AddHeading(right, "EXECUTION");
   AddPair(right, "Trade mode", TradeModeText(audit.tradeMode), (audit.tradeMode == SYMBOL_TRADE_MODE_FULL) ? clrNONE : g_clrWarning);
   AddPair(right, "Execution", ExecModeText(audit.execMode));
   AddPair(right, "Filling", FillingText(audit.fillingFlags, audit.execMode));
   AddPair(right, "Orders", OrderModesText(audit.orderFlags));
   AddPair(right, "Expiration", ExpirationText(audit.expirationFlags));
   AddPair(right, "GTC mode", GtcModeText(audit.gtcMode), (audit.gtcMode == SYMBOL_ORDERS_GTC) ? clrNONE : g_clrWarning);
   AddPair(right, "Stops level", IntegerToString(audit.stopsLevel) + " pts (" + DoubleToString(audit.stopsLevel * audit.point, d) + ")",
           (audit.stopsLevel > 0) ? g_clrWarning : clrNONE);
   AddPair(right, "Freeze level", IntegerToString(audit.freezeLevel) + " pts (" + DoubleToString(audit.freezeLevel * audit.point, d) + ")",
           (audit.freezeLevel > 0) ? g_clrWarning : clrNONE);
//--- sessions, two per row
   string day = audit.sessionDay;
   StringToUpper(day);
   AddHeading(right, "SESSIONS " + day + " (SERVER TIME)");
   int count = ArraySize(audit.sessions);
   if(count == 0)
      AddPair(right, "Trade", "closed today");
   for(int i = 0; i < count; i += 2)
     {
      string text = audit.sessions[i];
      if(i + 1 < count)
         text += ", " + audit.sessions[i + 1];
      AddPair(right, (i == 0) ? "Trade" : "", text);
     }
  }
//+------------------------------------------------------------------+
//| Append a heading row                                             |
//+------------------------------------------------------------------+
void AddHeading(SPanelRow &rows[], const string text)
  {
   int n = ArraySize(rows);
   ArrayResize(rows, n + 1);
   rows[n].kind = SSA_ROW_HEADING;
   rows[n].key = text;
   rows[n].value = "";
   rows[n].clr = g_clrHeading;
  }
//+------------------------------------------------------------------+
//| Append a key/value row (clrNONE = normal text color)             |
//+------------------------------------------------------------------+
void AddPair(SPanelRow &rows[], const string key, const string value, const color clr = clrNONE)
  {
   int n = ArraySize(rows);
   ArrayResize(rows, n + 1);
   rows[n].kind = SSA_ROW_PAIR;
   rows[n].key = key;
   rows[n].value = value;
   rows[n].clr = (clr == clrNONE) ? g_clrText : clr;
  }
//+------------------------------------------------------------------+
//| Layout: fills g_frame and the button plans, panel coordinates    |
//+------------------------------------------------------------------+
void LayoutPanel(const SPanelRow &left[], const SPanelRow &right[], const string &warnings[], const bool twoCols, int &panelW, int &panelH)
  {
   ArrayResize(g_frame, 0);
   g_frameRight = 0;
   int pad = Px(8), colGap = Px(16), sectionGap = g_lineH / 3;
   string title = "Symbol Spec Auditor  " + _Symbol;
   AddItem(title, g_clrHeading, pad, pad);
   int toggleSize = g_lineH;
   int titleRight = g_frameRight + Px(12) + toggleSize;
   int y = pad + g_lineH + Px(4);
   int contentW = 0;
   g_planExport.visible = false;
   if(!g_collapsed)
     {
      if(!InpShowWarningsOnly)
        {
         int bottom = y;
         if(twoCols)
           {
            int bottom1 = y, bottom2 = y;
            int w1 = PlaceColumn(left, 0, pad, y, bottom1);
            int w2 = PlaceColumn(right, 1, pad + w1 + colGap, y, bottom2);
            bottom = MathMax(bottom1, bottom2);
            contentW = w1 + colGap + w2;
           }
         else
           {
            SPanelRow all[];
            int n1 = ArraySize(left), n2 = ArraySize(right);
            ArrayResize(all, n1 + n2);
            for(int i = 0; i < n1; i++)
               all[i] = left[i];
            for(int i = 0; i < n2; i++)
               all[n1 + i] = right[i];
            contentW = PlaceColumn(all, 0, pad, y, bottom);
           }
         y = bottom + sectionGap;
        }
      //--- warnings, wrapped to the panel width (at least a readable line length)
      int wrapW = MathMax(contentW, TextW(StringRepeat("n", SSA_WRAP_CHARS)));
      int count = ArraySize(warnings);
      if(count == 0)
        {
         AddItem("No traps detected", g_clrOk, pad, y);
         y += g_lineH;
        }
      else
        {
         AddItem("WARNINGS (" + IntegerToString(count) + ")", g_clrWarning, pad, y);
         y += g_lineH;
         for(int i = 0; i < count; i++)
           {
            string lines[];
            int n = WrapText(warnings[i], wrapW - TextW("! "), lines);
            for(int j = 0; j < n; j++)
              {
               AddItem(((j == 0) ? "! " : "  ") + lines[j], g_clrWarning, pad, y);
               y += g_lineH;
              }
           }
        }
      //--- footer: export button and its status message
      y += Px(6);
      g_planExport.visible = true;
      g_planExport.text = "Export CSV";
      g_planExport.x = pad;
      g_planExport.y = y;
      g_planExport.w = TextW(g_planExport.text) + Px(20);
      g_planExport.h = g_lineH + Px(4);
      g_frameRight = MathMax(g_frameRight, g_planExport.x + g_planExport.w);
      if(g_statusText != "")
         AddItem(g_statusText, g_statusClr, pad + g_planExport.w + Px(10), y + Px(2));
      y += g_planExport.h;
     }
   panelW = MathMax(MathMax(g_frameRight, pad + contentW), titleRight) + pad;
   panelH = y + (g_collapsed ? Px(2) : pad);
//--- collapse/expand button at the right end of the title row
   g_planToggle.visible = true;
   g_planToggle.text = g_collapsed ? "+" : "-";
   g_planToggle.w = toggleSize;
   g_planToggle.h = toggleSize;
   g_planToggle.x = panelW - pad - toggleSize;
   g_planToggle.y = pad;
  }
//+------------------------------------------------------------------+
//| Place one column of rows, return its width                       |
//+------------------------------------------------------------------+
int PlaceColumn(const SPanelRow &rows[], const int col, const int x0, const int y0, int &bottom)
  {
   int keyGap = Px(10), sectionGap = g_lineH / 3;
   int n = ArraySize(rows), headW = 0, keyW = 0, valW = 0;
   for(int i = 0; i < n; i++)
     {
      if(rows[i].kind == SSA_ROW_HEADING)
         headW = MathMax(headW, TextW(rows[i].key));
      else
        {
         keyW = MathMax(keyW, TextW(rows[i].key));
         valW = MathMax(valW, TextW(rows[i].value));
        }
     }
   g_keyW[col] = MathMax(g_keyW[col], keyW);
   g_valW[col] = MathMax(g_valW[col], valW);
   int y = y0;
   for(int i = 0; i < n; i++)
     {
      if(rows[i].kind == SSA_ROW_HEADING)
        {
         if(i > 0)
            y += sectionGap;
         AddItem(rows[i].key, rows[i].clr, x0, y);
        }
      else
        {
         AddItem(rows[i].key, g_clrKey, x0, y);
         AddItem(rows[i].value, rows[i].clr, x0 + g_keyW[col] + keyGap, y);
        }
      y += g_lineH;
     }
   bottom = y;
   return(MathMax(g_keyW[col] + keyGap + g_valW[col], headW));
  }
//+------------------------------------------------------------------+
//| Append a text to the frame as one or more labels                 |
//+------------------------------------------------------------------+
void AddItem(const string text, const color clr, const int x, const int y)
  {
//--- an OBJ_LABEL shows at most SSA_LABEL_MAX characters, so a longer text is
//--- split into pieces that are placed side by side
   if(text == "")
      return;
   string rest = text;
   int left = x;
   while(rest != "")
     {
      int len = StringLen(rest);
      string piece = (len > SSA_LABEL_MAX) ? StringSubstr(rest, 0, SSA_LABEL_MAX) : rest;
      rest = (len > SSA_LABEL_MAX) ? StringSubstr(rest, SSA_LABEL_MAX) : "";
      int n = ArraySize(g_frame);
      ArrayResize(g_frame, n + 1);
      g_frame[n].text = piece;
      g_frame[n].clr = clr;
      g_frame[n].x = left;
      g_frame[n].y = y;
      left += TextW(piece);
     }
   g_frameRight = MathMax(g_frameRight, left);
  }
//+------------------------------------------------------------------+
//| Greedy word wrap by pixel width                                  |
//+------------------------------------------------------------------+
int WrapText(const string text, const int maxW, string &lines[])
  {
   ArrayResize(lines, 0);
   string words[];
   int n = StringSplit(text, ' ', words);
   string line = "";
   for(int i = 0; i < n; i++)
     {
      if(words[i] == "")
         continue;
      string candidate = (line == "") ? words[i] : line + " " + words[i];
      if(line != "" && TextW(candidate) > maxW)
        {
         PushLine(lines, line);
         line = words[i];
        }
      else
         line = candidate;
     }
   if(line != "")
      PushLine(lines, line);
   return(ArraySize(lines));
  }
//+------------------------------------------------------------------+
//| Append a line to a string array                                  |
//+------------------------------------------------------------------+
void PushLine(string &lines[], const string line)
  {
   int n = ArraySize(lines);
   ArrayResize(lines, n + 1);
   lines[n] = line;
  }
//+------------------------------------------------------------------+
//| Draw the laid-out frame with chart objects                       |
//+------------------------------------------------------------------+
bool RenderFrame(const int w, const int h)
  {
//--- creates, updates and deletes chart objects, touching only the properties
//--- that changed; returns true if anything was changed
   bool changed = false;
   string bg = g_prefix + "BG";
//--- first frame, or our objects were deleted from outside: start clean so the
//--- background is created first and therefore drawn below the labels
   if(!g_bgMade || ObjectFind(0, bg) < 0)
     {
      ObjectsDeleteAll(0, g_prefix);
      ResetRenderState();
      if(!ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0))
         return(false);
      SetCommonProps(bg, 0);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, g_clrBack);
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, g_clrBorder);
      ObjectSetInteger(0, bg, OBJPROP_WIDTH, 1);
      g_bgMade = true;
      changed = true;
     }
   int bx = DistX(0, w), by = DistY(0, h);
   if(bx != g_bgX)
     {
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, bx);
      g_bgX = bx;
      changed = true;
     }
   if(by != g_bgY)
     {
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, by);
      g_bgY = by;
      changed = true;
     }
   if(w != g_bgW)
     {
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, w);
      g_bgW = w;
      changed = true;
     }
   if(h != g_bgH)
     {
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, h);
      g_bgH = h;
      changed = true;
     }
//--- labels
   int n = ArraySize(g_frame), old = ArraySize(g_shown);
   for(int i = n; i < old; i++)
      ObjectDelete(0, LabelName(i));
   if(n != old)
     {
      ArrayResize(g_shown, n);
      changed = true;
     }
   for(int i = old; i < n; i++)
     {
      string name = LabelName(i);
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      SetCommonProps(name, 1);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, g_fontName);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, g_fontSize);
      //--- impossible values force every property to be written once
      g_shown[i].text = "\n";
      g_shown[i].clr = clrNONE;
      g_shown[i].x = INT_MIN;
      g_shown[i].y = INT_MIN;
     }
   for(int i = 0; i < n; i++)
     {
      string name = LabelName(i);
      int x = DistX(g_frame[i].x, w), y = DistY(g_frame[i].y, h);
      if(g_shown[i].text != g_frame[i].text)
        {
         ObjectSetString(0, name, OBJPROP_TEXT, g_frame[i].text);
         g_shown[i].text = g_frame[i].text;
         changed = true;
        }
      if(g_shown[i].clr != g_frame[i].clr)
        {
         ObjectSetInteger(0, name, OBJPROP_COLOR, g_frame[i].clr);
         g_shown[i].clr = g_frame[i].clr;
         changed = true;
        }
      if(g_shown[i].x != x)
        {
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
         g_shown[i].x = x;
         changed = true;
        }
      if(g_shown[i].y != y)
        {
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
         g_shown[i].y = y;
         changed = true;
        }
     }
   if(RenderButton(g_prefix + "Export", g_planExport, g_shownExport, w, h, "Write the specs of all Market Watch symbols to MQL5\\Files"))
      changed = true;
   if(RenderButton(g_prefix + "Toggle", g_planToggle, g_shownToggle, w, h, "Collapse / expand the panel"))
      changed = true;
   return(changed);
  }
//+------------------------------------------------------------------+
//| Create or update one button; true if anything changed            |
//+------------------------------------------------------------------+
bool RenderButton(const string name, const SPanelButton &plan, SPanelButton &shown, const int panelW, const int panelH, const string tooltip)
  {
   if(!plan.visible)
     {
      if(!shown.visible)
         return(false);
      ObjectDelete(0, name);
      shown.visible = false;
      return(true);
     }
   bool changed = false;
   if(!shown.visible || ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
      SetCommonProps(name, 10);
      ObjectSetString(0, name, OBJPROP_FONT, g_fontName);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, g_fontSize);
      ObjectSetInteger(0, name, OBJPROP_COLOR, g_clrText);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, g_clrButton);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, g_clrButtonBorder);
      ObjectSetInteger(0, name, OBJPROP_STATE, false);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
      shown.visible = true;
      shown.text = "\n";
      shown.x = INT_MIN;
      shown.y = INT_MIN;
      shown.w = INT_MIN;
      shown.h = INT_MIN;
      changed = true;
     }
   if(shown.text != plan.text)
     {
      ObjectSetString(0, name, OBJPROP_TEXT, plan.text);
      shown.text = plan.text;
      changed = true;
     }
   int x = DistX(plan.x, panelW), y = DistY(plan.y, panelH);
   if(shown.x != x)
     {
      shown.x = x;
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, shown.x);
      changed = true;
     }
   if(shown.y != y)
     {
      shown.y = y;
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, shown.y);
      changed = true;
     }
   if(shown.w != plan.w)
     {
      shown.w = plan.w;
      ObjectSetInteger(0, name, OBJPROP_XSIZE, shown.w);
      changed = true;
     }
   if(shown.h != plan.h)
     {
      shown.h = plan.h;
      ObjectSetInteger(0, name, OBJPROP_YSIZE, shown.h);
      changed = true;
     }
   return(changed);
  }
//+------------------------------------------------------------------+
//| Properties shared by every object of the panel                   |
//+------------------------------------------------------------------+
void SetCommonProps(const string name, const int zorder)
  {
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
  }
//+------------------------------------------------------------------+
//| Chart object name of a label                                     |
//+------------------------------------------------------------------+
string LabelName(const int index)
  {
   return(g_prefix + "L" + IntegerToString(index));
  }
//+------------------------------------------------------------------+
//| Forget what is drawn, so the next frame redraws everything       |
//+------------------------------------------------------------------+
void ResetRenderState()
  {
   ArrayResize(g_shown, 0);
   g_bgMade = false;
   g_bgX = INT_MIN;
   g_bgY = INT_MIN;
   g_bgW = INT_MIN;
   g_bgH = INT_MIN;
   g_shownExport.visible = false;
   g_shownToggle.visible = false;
  }
//+------------------------------------------------------------------+
//| CSV export of every Market Watch symbol                          |
//+------------------------------------------------------------------+
bool ExportCsv(int &count, string &fullPath)
  {
   count = 0;
   MqlDateTime t;
   TimeToStruct(TimeLocal(), t);
   string fileName = StringFormat("SymbolSpecAudit_%s_%04d%02d%02d_%02d%02d.csv",
                                  SafeFileName(AccountInfoString(ACCOUNT_SERVER)), t.year, t.mon, t.day, t.hour, t.min);
   ResetLastError();
   int h = FileOpen(fileName, FILE_WRITE | FILE_TXT | FILE_ANSI, 0, CP_UTF8);
   if(h == INVALID_HANDLE)
     {
      PrintFormat("SymbolSpecAuditor: cannot create %s (error %d)", fileName, GetLastError());
      return(false);
     }
//--- UTF-8 byte order mark so that spreadsheet programs detect the encoding
   FileWriteString(h, ShortToString(0xFEFF));
   FileWriteString(h, CsvHeader() + "\r\n");
   int total = SymbolsTotal(true);
   for(int i = 0; i < total; i++)
     {
      string sym = SymbolName(i, true);
      if(sym == "")
         continue;
      SSymbolAudit audit;
      AuditSymbol(sym, audit, sym == _Symbol);
      FileWriteString(h, CsvRow(audit) + "\r\n");
      count++;
     }
   FileClose(h);
   fullPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + fileName;
   return(true);
  }
//+------------------------------------------------------------------+
//| CSV header line                                                  |
//+------------------------------------------------------------------+
string CsvHeader()
  {
   string acc = AccountInfoString(ACCOUNT_CURRENCY);
   string cols[] =
     {
      "Symbol", "Description", "Path", "Custom", "CalcMode", "BaseCurrency", "ProfitCurrency", "MarginCurrency",
      "AccountCurrency", "Digits", "Point", "TickSize", "TickValue", "TickValueProfit", "TickValueLoss", "ContractSize",
      "Bid", "Ask", "PointValue_TickValue", "PointValue_Contract", "PointValueDiffPct", "SpreadPoints", "SpreadPerLot",
      "ATR14Points", "SpreadPctATR", "VolumeMin", "VolumeStep", "VolumeMax", "VolumeLimit", "MarginRateBuy",
      "MarginRateSell", "MarginBuy1Lot", "MarginSell1Lot", "Notional1Lot", "NotionalCurrency", "EffectiveLeverage",
      "SwapMode", "SwapLong", "SwapShort", "SwapUnit", "SwapLongPerLot", "SwapShortPerLot", "TripleSwapDay",
      "TradeMode", "ExecutionMode", "Filling", "OrderTypes", "Expiration", "OrderGtcMode", "ContractExpiration",
      "StopsLevelPoints", "FreezeLevelPoints", "SessionsToday", "Notes", "Warnings"
     };
//--- money columns carry the account currency, the ATR column the chart timeframe
   string out = "";
   int n = ArraySize(cols);
   for(int i = 0; i < n; i++)
     {
      string c = cols[i];
      if(c == "PointValue_TickValue" || c == "PointValue_Contract" || c == "SpreadPerLot" || c == "MarginBuy1Lot" ||
         c == "MarginSell1Lot" || c == "SwapLongPerLot" || c == "SwapShortPerLot")
         c += "_" + acc;
      if(c == "ATR14Points")
         c += "_" + TfName();
      out += ((i > 0) ? "," : "") + CsvText(c);
     }
   return(out);
  }
//+------------------------------------------------------------------+
//| CSV line of one symbol, in the column order of CsvHeader()       |
//+------------------------------------------------------------------+
string CsvRow(const SSymbolAudit &audit)
  {
//--- notes explain the values that are missing
   string notes = "";
   if(audit.tickNote != "")
      notes += "tick value: " + audit.tickNote;
   if(audit.checkNote != "")
      notes += ((notes != "") ? "; " : "") + "point value check: " + audit.checkNote;
   if(audit.marginNote != "")
      notes += ((notes != "") ? "; " : "") + "margin: " + audit.marginNote;
   if(audit.atrNote != "")
      notes += ((notes != "") ? "; " : "") + "ATR: " + audit.atrNote;
   if(Has(audit.notional) && audit.notionalCcy != audit.accountCcy)
      notes += ((notes != "") ? "; " : "") + "notional not converted";
//--- list fields
   string sessions = "";
   int ns = ArraySize(audit.sessions);
   for(int i = 0; i < ns; i++)
      sessions += ((i > 0) ? " " : "") + audit.sessions[i];
   string warnings = "";
   int nw = ArraySize(audit.warnings);
   for(int i = 0; i < nw; i++)
      warnings += ((i > 0) ? " | " : "") + audit.warnings[i];
//--- the row
   string r = CsvText(audit.symbol);
   r += "," + CsvText(audit.description);
   r += "," + CsvText(audit.path);
   r += "," + (audit.custom ? "yes" : "no");
   r += "," + CsvText(CalcModeText(audit.calcMode));
   r += "," + CsvText(audit.baseCcy);
   r += "," + CsvText(audit.profitCcy);
   r += "," + CsvText(audit.marginCcy);
   r += "," + CsvText(audit.accountCcy);
   r += "," + IntegerToString(audit.digits);
   r += "," + CsvNum(audit.point);
   r += "," + CsvNum(audit.tickSize);
   bool tickRead = (audit.tickNote == "");
   r += "," + (tickRead ? CsvNum(audit.tickValue) : "");
   r += "," + (tickRead ? CsvNum(audit.tickValueProfit) : "");
   r += "," + (tickRead ? CsvNum(audit.tickValueLoss) : "");
   r += "," + CsvNum(audit.contractSize);
   r += "," + CsvNum(audit.bid);
   r += "," + CsvNum(audit.ask);
   r += "," + CsvNum(audit.pointValue);
   r += "," + CsvNum(audit.pointValueCheck);
   r += "," + CsvNum(audit.checkDiffPct, 3);
   r += "," + CsvNum(audit.spreadPoints, 0);
   r += "," + CsvNum(audit.spreadMoney);
   r += "," + CsvNum(audit.atrPoints, 1);
   r += "," + CsvNum(audit.spreadPctAtr, 2);
   r += "," + CsvNum(audit.volMin);
   r += "," + CsvNum(audit.volStep);
   r += "," + CsvNum(audit.volMax);
   r += "," + CsvNum(audit.volLimit);
   r += "," + CsvNum(audit.marginRateBuy);
   r += "," + CsvNum(audit.marginRateSell);
   r += "," + CsvNum(audit.marginBuy, 4);
   r += "," + CsvNum(audit.marginSell, 4);
   r += "," + CsvNum(audit.notional, 2);
   r += "," + CsvText(audit.notionalCcy);
   r += "," + CsvNum(audit.leverage, 2);
   r += "," + CsvText(SwapModeText(audit.swapMode));
   r += "," + CsvNum(audit.swapLong);
   r += "," + CsvNum(audit.swapShort);
   r += "," + CsvText(audit.swapUnit);
   r += "," + CsvNum(audit.swapLongMoney, 4);
   r += "," + CsvNum(audit.swapShortMoney, 4);
   r += "," + CsvText(TripleSwapDayText(audit.swap3Day));
   r += "," + CsvText(TradeModeText(audit.tradeMode));
   r += "," + CsvText(ExecModeText(audit.execMode));
   r += "," + CsvText(FillingText(audit.fillingFlags, audit.execMode));
   r += "," + CsvText(OrderModesText(audit.orderFlags));
   r += "," + CsvText(ExpirationText(audit.expirationFlags));
   r += "," + CsvText(GtcModeText(audit.gtcMode));
   r += "," + ((audit.expirationTime > 0) ? TimeToString(audit.expirationTime, TIME_DATE | TIME_MINUTES) : "");
   r += "," + IntegerToString(audit.stopsLevel);
   r += "," + IntegerToString(audit.freezeLevel);
   r += "," + CsvText((ns > 0) ? sessions : "closed today");
   r += "," + CsvText(notes);
   r += "," + CsvText(warnings);
   return(r);
  }
//+------------------------------------------------------------------+
//| RFC 4180 quoting: only when the field needs it                   |
//+------------------------------------------------------------------+
string CsvText(const string s)
  {
   if(StringFind(s, ",") < 0 && StringFind(s, "\"") < 0 && StringFind(s, "\n") < 0 && StringFind(s, "\r") < 0)
      return(s);
   string q = s;
   StringReplace(q, "\"", "\"\"");
   return("\"" + q + "\"");
  }
//+------------------------------------------------------------------+
//| Number for the CSV: empty cell when not available                |
//+------------------------------------------------------------------+
string CsvNum(const double v, const int digits = 8)
  {
   if(!Has(v))
      return("");
   return(Trim0(v, digits));
  }
//+------------------------------------------------------------------+
//| Server name reduced to characters that are safe in a file name   |
//+------------------------------------------------------------------+
string SafeFileName(const string s)
  {
   string out = "";
   int n = StringLen(s);
   for(int i = 0; i < n; i++)
     {
      ushort c = StringGetCharacter(s, i);
      bool ok = (c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '-' || c == '.' || c == '_';
      out += ok ? ShortToString(c) : "_";
     }
   return((out != "") ? out : "server");
  }
//+------------------------------------------------------------------+
//| Conversion rate of a currency into the account currency          |
//+------------------------------------------------------------------+
double RateToAccount(const string ccy, const int side)
  {
//--- side: +1 buy (ask), -1 sell (bid), 0 mid. Returns SSA_NA when no Market
//--- Watch symbol with live quotes links the two currencies
   string acc = AccountInfoString(ACCOUNT_CURRENCY);
   if(ccy == acc)
      return(1.0);
   if(ccy == "" || acc == "")
      return(SSA_NA);
   double rate = CrossRate(ccy, acc, side);
   if(Has(rate))
      return(rate);
//--- cent units (USC, EUC, ...) have no quotes of their own: 1 unit of the major
//--- currency is 100 cent units, so convert through the major currency
   string ccyMajor = CentMajor(ccy), accMajor = CentMajor(acc);
   if(ccyMajor == "" && accMajor == "")
      return(SSA_NA);
   string from = (ccyMajor != "") ? ccyMajor : ccy;
   string to = (accMajor != "") ? accMajor : acc;
   rate = (from == to) ? 1.0 : CrossRate(from, to, side);
   if(!Has(rate))
      return(SSA_NA);
   if(accMajor != "")
      rate *= 100.0;
   if(ccyMajor != "")
      rate /= 100.0;
   return(rate);
  }
//+------------------------------------------------------------------+
//| Rate through a direct symbol, or through two legs via USD        |
//+------------------------------------------------------------------+
double CrossRate(const string from, const string to, const int side)
  {
   double rate = DirectRate(from, to, side);
   if(Has(rate))
      return(rate);
//--- two legs through USD, the usual cross currency
   if(from == "USD" || to == "USD")
      return(SSA_NA);
   double r1 = DirectRate(from, "USD", side), r2 = DirectRate("USD", to, side);
   if(Has(r1) && Has(r2))
      return(r1 * r2);
   return(SSA_NA);
  }
//+------------------------------------------------------------------+
//| Rate from one symbol that links the two currencies               |
//+------------------------------------------------------------------+
double DirectRate(const string from, const string to, const int side)
  {
   string sym = "";
   bool inverse = false;
   if(!FindPair(from, to, sym, inverse))
      return(SSA_NA);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID), ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0)
      return(SSA_NA);
   if(!inverse)
      return((side > 0) ? ask : ((side < 0) ? bid : (bid + ask) / 2.0));
   return(1.0 / ((side > 0) ? bid : ((side < 0) ? ask : (bid + ask) / 2.0)));
  }
//+------------------------------------------------------------------+
//| Market Watch symbol whose currencies are from/to (or to/from)    |
//+------------------------------------------------------------------+
bool FindPair(const string from, const string to, string &sym, bool &inverse)
  {
//--- searches Market Watch only: symbols outside it have no live quotes and are
//--- never touched. Prefers forex calc modes. Results are cached; a symbol that
//--- left Market Watch or lost its quotes is searched again at once, a failed
//--- search is retried after SSA_RETRY_MS
   ulong now = GetTickCount64();
   int n = ArraySize(g_pairFrom), slot = -1;
   for(int i = 0; i < n; i++)
     {
      if(g_pairFrom[i] != from || g_pairTo[i] != to)
         continue;
      bool quoted = (g_pairSymbol[i] != "" && SymbolInfoInteger(g_pairSymbol[i], SYMBOL_SELECT) != 0 &&
                     SymbolInfoDouble(g_pairSymbol[i], SYMBOL_BID) > 0.0);
      if(quoted || (g_pairSymbol[i] == "" && now - g_pairTime[i] < SSA_RETRY_MS))
        {
         sym = g_pairSymbol[i];
         inverse = g_pairInverse[i];
         return(sym != "");
        }
      slot = i;
      break;
     }
//--- search the Market Watch symbols
   string best = "";
   bool bestInverse = false;
   int bestScore = -1;
   int total = SymbolsTotal(true);
   for(int i = 0; i < total; i++)
     {
      string name = SymbolName(i, true);
      string base = SymbolInfoString(name, SYMBOL_CURRENCY_BASE);
      string profit = SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT);
      bool direct = (base == from && profit == to), reverse = (base == to && profit == from);
      if(!direct && !reverse)
         continue;
      if(SymbolInfoDouble(name, SYMBOL_BID) <= 0.0 || SymbolInfoDouble(name, SYMBOL_ASK) <= 0.0)
         continue;
      ENUM_SYMBOL_CALC_MODE mode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(name, SYMBOL_TRADE_CALC_MODE);
      int score = (mode == SYMBOL_CALC_MODE_FOREX || mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE) ? 1 : 0;
      if(score > bestScore)
        {
         bestScore = score;
         best = name;
         bestInverse = reverse;
        }
     }
//--- remember the result (also a failed search)
   if(slot < 0)
     {
      slot = n;
      ArrayResize(g_pairFrom, n + 1);
      ArrayResize(g_pairTo, n + 1);
      ArrayResize(g_pairSymbol, n + 1);
      ArrayResize(g_pairInverse, n + 1);
      ArrayResize(g_pairTime, n + 1);
     }
   g_pairFrom[slot] = from;
   g_pairTo[slot] = to;
   g_pairSymbol[slot] = best;
   g_pairInverse[slot] = bestInverse;
   g_pairTime[slot] = now;
   sym = best;
   inverse = bestInverse;
   return(best != "");
  }
//+------------------------------------------------------------------+
//| True for a fiat currency code                                    |
//+------------------------------------------------------------------+
bool IsFiat(const string ccy)
  {
   if(StringLen(ccy) != 3)
      return(false);
   string list = " USD EUR GBP JPY CHF AUD NZD CAD SEK NOK DKK PLN HUF CZK TRY ZAR MXN SGD HKD CNH CNY RUB ILS THB INR KRW TWD"
                 " BRL CLP COP IDR MYR PHP SAR AED KWD QAR BHD OMR KES NGN EGP ARS PEN UAH KZT RON BGN ISK VND PKR ";
   return(CentMajor(ccy) != "" || StringFind(list, " " + ccy + " ") >= 0);
  }
//+------------------------------------------------------------------+
//| Major currency of a cent unit, the code itself otherwise         |
//+------------------------------------------------------------------+
string MajorOf(const string ccy)
  {
   return((CentMajor(ccy) != "") ? CentMajor(ccy) : ccy);
  }
//+------------------------------------------------------------------+
//| Major currency of a cent unit (USC -> USD), "" for other codes   |
//+------------------------------------------------------------------+
string CentMajor(const string ccy)
  {
   string code = ccy;
   StringToUpper(code);
   string cents[] = {"USC", "EUC", "GBC", "AUC", "CAC", "CHC", "NZC", "JPC"};
   string majors[] = {"USD", "EUR", "GBP", "AUD", "CAD", "CHF", "NZD", "JPY"};
   int n = ArraySize(cents);
   for(int i = 0; i < n; i++)
      if(code == cents[i])
         return(majors[i]);
   return("");
  }
//+------------------------------------------------------------------+
//| True for a cent account currency (USC, EUC and similar)          |
//+------------------------------------------------------------------+
bool IsCentCurrency(const string ccy)
  {
   return(CentMajor(ccy) != "");
  }
//+------------------------------------------------------------------+
//| Calculation mode as text                                         |
//+------------------------------------------------------------------+
string CalcModeText(const ENUM_SYMBOL_CALC_MODE mode)
  {
   switch(mode)
     {
      case SYMBOL_CALC_MODE_FOREX:
         return("Forex");
      case SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE:
         return("Forex no leverage");
      case SYMBOL_CALC_MODE_FUTURES:
         return("Futures");
      case SYMBOL_CALC_MODE_CFD:
         return("CFD");
      case SYMBOL_CALC_MODE_CFDINDEX:
         return("CFD index");
      case SYMBOL_CALC_MODE_CFDLEVERAGE:
         return("CFD leverage");
      case SYMBOL_CALC_MODE_EXCH_STOCKS:
         return("Exchange stocks");
      case SYMBOL_CALC_MODE_EXCH_FUTURES:
         return("Exchange futures");
      case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS:
         return("FORTS futures");
      case SYMBOL_CALC_MODE_EXCH_BONDS:
         return("Exchange bonds");
      case SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX:
         return("MOEX stocks");
      case SYMBOL_CALC_MODE_EXCH_BONDS_MOEX:
         return("MOEX bonds");
      case SYMBOL_CALC_MODE_SERV_COLLATERAL:
         return("Collateral");
     }
   return(EnumToString(mode));
  }
//+------------------------------------------------------------------+
//| Swap mode as text                                                |
//+------------------------------------------------------------------+
string SwapModeText(const ENUM_SYMBOL_SWAP_MODE mode)
  {
   switch(mode)
     {
      case SYMBOL_SWAP_MODE_DISABLED:
         return("disabled");
      case SYMBOL_SWAP_MODE_POINTS:
         return("points");
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
         return("money, base currency");
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
         return("money, margin currency");
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         return("money, deposit currency");
      case SYMBOL_SWAP_MODE_CURRENCY_PROFIT:
         return("money, profit currency");
      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
         return("interest, current price");
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
         return("interest, open price");
      case SYMBOL_SWAP_MODE_REOPEN_CURRENT:
         return("reopen at close price");
      case SYMBOL_SWAP_MODE_REOPEN_BID:
         return("reopen at bid");
     }
   return(EnumToString(mode));
  }
//+------------------------------------------------------------------+
//| Trade mode as text                                               |
//+------------------------------------------------------------------+
string TradeModeText(const ENUM_SYMBOL_TRADE_MODE mode)
  {
   switch(mode)
     {
      case SYMBOL_TRADE_MODE_DISABLED:
         return("disabled");
      case SYMBOL_TRADE_MODE_LONGONLY:
         return("long only");
      case SYMBOL_TRADE_MODE_SHORTONLY:
         return("short only");
      case SYMBOL_TRADE_MODE_CLOSEONLY:
         return("close only");
      case SYMBOL_TRADE_MODE_FULL:
         return("full");
     }
   return(EnumToString(mode));
  }
//+------------------------------------------------------------------+
//| Execution mode as text                                           |
//+------------------------------------------------------------------+
string ExecModeText(const ENUM_SYMBOL_TRADE_EXECUTION mode)
  {
   switch(mode)
     {
      case SYMBOL_TRADE_EXECUTION_REQUEST:
         return("request");
      case SYMBOL_TRADE_EXECUTION_INSTANT:
         return("instant");
      case SYMBOL_TRADE_EXECUTION_MARKET:
         return("market");
      case SYMBOL_TRADE_EXECUTION_EXCHANGE:
         return("exchange");
     }
   return(EnumToString(mode));
  }
//+------------------------------------------------------------------+
//| Allowed filling policies as text                                 |
//+------------------------------------------------------------------+
string FillingText(const int flags, const ENUM_SYMBOL_TRADE_EXECUTION exec)
  {
//--- Return is allowed in every execution mode except Market execution
//--- (MQL5 documentation of ORDER_FILLING_RETURN)
   string s = "";
   if((flags & SYMBOL_FILLING_FOK) != 0)
      s += "FOK ";
   if((flags & SYMBOL_FILLING_IOC) != 0)
      s += "IOC ";
   if((flags & SYMBOL_FILLING_BOC) != 0)
      s += "BOC ";
   if(exec != SYMBOL_TRADE_EXECUTION_MARKET)
      s += "Return ";
   StringTrimRight(s);
   return((s != "") ? s : "none");
  }
//+------------------------------------------------------------------+
//| Allowed order types as text                                      |
//+------------------------------------------------------------------+
string OrderModesText(const int flags)
  {
   string s = "";
   if((flags & SYMBOL_ORDER_MARKET) != 0)
      s += "Mkt ";
   if((flags & SYMBOL_ORDER_LIMIT) != 0)
      s += "Lim ";
   if((flags & SYMBOL_ORDER_STOP) != 0)
      s += "Stop ";
   if((flags & SYMBOL_ORDER_STOP_LIMIT) != 0)
      s += "StpLim ";
   if((flags & SYMBOL_ORDER_SL) != 0)
      s += "SL ";
   if((flags & SYMBOL_ORDER_TP) != 0)
      s += "TP ";
   if((flags & SYMBOL_ORDER_CLOSEBY) != 0)
      s += "CloseBy ";
   StringTrimRight(s);
   return((s != "") ? s : "none");
  }
//+------------------------------------------------------------------+
//| Allowed expiration modes of pending orders as text               |
//+------------------------------------------------------------------+
string ExpirationText(const int flags)
  {
   string s = "";
   if((flags & SYMBOL_EXPIRATION_GTC) != 0)
      s += "GTC ";
   if((flags & SYMBOL_EXPIRATION_DAY) != 0)
      s += "Day ";
   if((flags & SYMBOL_EXPIRATION_SPECIFIED) != 0)
      s += "Time ";
   if((flags & SYMBOL_EXPIRATION_SPECIFIED_DAY) != 0)
      s += "Date ";
   StringTrimRight(s);
   return((s != "") ? s : "none");
  }
//+------------------------------------------------------------------+
//| Lifetime of pending orders and SL/TP (GTC mode) as text          |
//+------------------------------------------------------------------+
string GtcModeText(const ENUM_SYMBOL_ORDER_GTC_MODE mode)
  {
   switch(mode)
     {
      case SYMBOL_ORDERS_GTC:
         return("good till cancelled");
      case SYMBOL_ORDERS_DAILY:
         return("daily: SL/TP and pendings expire");
      case SYMBOL_ORDERS_DAILY_EXCLUDING_STOPS:
         return("daily: pendings expire, SL/TP kept");
     }
   return(EnumToString(mode));
  }
//+------------------------------------------------------------------+
//| Account margin mode as text ("" if unknown)                      |
//+------------------------------------------------------------------+
string MarginModeText()
  {
   switch((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE))
     {
      case ACCOUNT_MARGIN_MODE_RETAIL_NETTING:
         return("netting");
      case ACCOUNT_MARGIN_MODE_EXCHANGE:
         return("exchange");
      case ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:
         return("hedging");
     }
   return("");
  }
//+------------------------------------------------------------------+
//| Day of the week as text                                          |
//+------------------------------------------------------------------+
string DayName(const ENUM_DAY_OF_WEEK day)
  {
   switch(day)
     {
      case SUNDAY:
         return("Sunday");
      case MONDAY:
         return("Monday");
      case TUESDAY:
         return("Tuesday");
      case WEDNESDAY:
         return("Wednesday");
      case THURSDAY:
         return("Thursday");
      case FRIDAY:
         return("Friday");
      case SATURDAY:
         return("Saturday");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| Chart timeframe as text (H1, M15, ...)                           |
//+------------------------------------------------------------------+
string TfName()
  {
   string s = EnumToString((ENUM_TIMEFRAMES)_Period);
   StringReplace(s, "PERIOD_", "");
   return(s);
  }
//+------------------------------------------------------------------+
//| Seconds from midnight as HH:MM (24:00 is a valid session end)    |
//+------------------------------------------------------------------+
string HhMm(const datetime secondsOfDay)
  {
   int minutes = (int)((long)secondsOfDay / 60);
   return(StringFormat("%02d:%02d", minutes / 60, minutes % 60));
  }
//+------------------------------------------------------------------+
//| Leverage ratio as text                                           |
//+------------------------------------------------------------------+
string LeverageText(const double lev)
  {
   if(lev >= 10.0)
      return(DoubleToString(MathRound(lev), 0));
   return(Trim0(lev, 1));
  }
//+------------------------------------------------------------------+
//| Money: 2 decimals, more for tiny amounts, thousands separators   |
//+------------------------------------------------------------------+
string Money(const double v)
  {
   if(!Has(v))
      return("n/a");
   double av = MathAbs(v);
   int d = 2;
   if(av > 0.0 && av < 0.1)
      d = MathMin(8, 2 + (int)MathCeil(-MathLog10(av)));
   return(GroupThousands(DoubleToString(v, d)));
  }
//+------------------------------------------------------------------+
//| Insert thousands separators into a number string                 |
//+------------------------------------------------------------------+
string GroupThousands(const string num)
  {
   int dot = StringFind(num, ".");
   string whole = (dot >= 0) ? StringSubstr(num, 0, dot) : num;
   string frac = (dot >= 0) ? StringSubstr(num, dot) : "";
   string sign = "";
   if(StringSubstr(whole, 0, 1) == "-")
     {
      sign = "-";
      whole = StringSubstr(whole, 1);
     }
   string out = "";
   int len = StringLen(whole);
   for(int i = 0; i < len; i++)
     {
      if(i > 0 && (len - i) % 3 == 0)
         out += ",";
      out += StringSubstr(whole, i, 1);
     }
   return(sign + out + frac);
  }
//+------------------------------------------------------------------+
//| Number without trailing zeros                                    |
//+------------------------------------------------------------------+
string Trim0(const double v, const int digits)
  {
   if(!Has(v))
      return("n/a");
   string s = DoubleToString(v, digits);
   if(StringFind(s, ".") >= 0)
     {
      int n = StringLen(s);
      while(n > 0 && StringGetCharacter(s, n - 1) == '0')
         n--;
      if(n > 0 && StringGetCharacter(s, n - 1) == '.')
         n--;
      s = StringSubstr(s, 0, n);
     }
   if(s == "-0")
      s = "0";
   return(s);
  }
//+------------------------------------------------------------------+
//| Cut a long text to the value width of a panel row                |
//+------------------------------------------------------------------+
string Fit(const string s)
  {
   if(StringLen(s) <= SSA_VALUE_CHARS)
      return((s != "") ? s : "-");
   return(StringSubstr(s, 0, SSA_VALUE_CHARS - 3) + "...");
  }
//+------------------------------------------------------------------+
//| Keeps the end of a long path, which names the symbol             |
//+------------------------------------------------------------------+
string FitLeft(const string s)
  {
   int n = StringLen(s);
   if(n <= SSA_VALUE_CHARS)
      return((s != "") ? s : "-");
   return("..." + StringSubstr(s, n - (SSA_VALUE_CHARS - 3)));
  }
//+------------------------------------------------------------------+
//| Text or "-" when it is empty                                     |
//+------------------------------------------------------------------+
string NaText(const string s)
  {
   return((s != "") ? s : "-");
  }
//+------------------------------------------------------------------+
//| A string repeated count times                                    |
//+------------------------------------------------------------------+
string StringRepeat(const string s, const int count)
  {
   string out = "";
   for(int i = 0; i < count; i++)
      out += s;
   return(out);
  }
//+------------------------------------------------------------------+
//| True if the value is known (not SSA_NA)                          |
//+------------------------------------------------------------------+
bool Has(const double v)
  {
   return(v != SSA_NA);
  }
//+------------------------------------------------------------------+
//| Pixels at 100% screen scaling to screen pixels                   |
//+------------------------------------------------------------------+
int Px(const double px)
  {
   return((int)MathRound(px * g_scale));
  }
//+------------------------------------------------------------------+
//| Width in pixels of a text in the panel font (set by TextSetFont) |
//+------------------------------------------------------------------+
int TextW(const string s)
  {
   uint w = 0, h = 0;
   TextGetSize(s, w, h);
   return((int)w);
  }
//+------------------------------------------------------------------+
//| Mix two colors; weight is the share of the first color           |
//+------------------------------------------------------------------+
color Blend(const color fg, const color bg, const double weight)
  {
   int fore = (int)fg, back = (int)bg;
   int red = (int)MathRound((fore & 0xFF) * weight + (back & 0xFF) * (1.0 - weight));
   int green = (int)MathRound(((fore >> 8) & 0xFF) * weight + ((back >> 8) & 0xFF) * (1.0 - weight));
   int blue = (int)MathRound(((fore >> 16) & 0xFF) * weight + ((back >> 16) & 0xFF) * (1.0 - weight));
   return((color)(red | (green << 8) | (blue << 16)));
  }
//+------------------------------------------------------------------+
//| True for a light color (perceived brightness above one half)     |
//+------------------------------------------------------------------+
bool IsLightColor(const color clr)
  {
   int c = (int)clr;
   double brightness = 0.299 * (c & 0xFF) + 0.587 * ((c >> 8) & 0xFF) + 0.114 * ((c >> 16) & 0xFF);
   return(brightness > 127.5);
  }
//+------------------------------------------------------------------+
