//+------------------------------------------------------------------+
//|                              RiskBasedPositionSizeCalculator.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property description "Draggable Entry/Stop/Take-Profit lines with a live on-chart panel that "
#property description "calculates the correct position size for a chosen account risk, so lot "
#property description "size is never guessed or hand-calculated again."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- risk basis selector
enum ENUM_RISK_MODE
  {
   RISK_PERCENT_BALANCE = 0,   // % of Account Balance
   RISK_PERCENT_EQUITY  = 1,   // % of Account Equity
   RISK_FIXED_MONEY     = 2    // Fixed Money Amount
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Risk Settings ==="
input ENUM_RISK_MODE InpRiskMode      = RISK_PERCENT_BALANCE; // Risk Basis
input double          InpRiskPercent  = 1.0;                  // Risk (% — used when basis is Balance/Equity)
input double          InpRiskMoney    = 100.0;                // Risk (Money — used when basis is Fixed Money)

input group "=== Trade Lines ==="
input int    InpDefaultStopPoints = 200;    // Default Stop Distance on First Load (points)
input bool   InpShowTakeProfitLine = true;  // Show a Draggable Take-Profit Line
input double InpDefaultRewardMultiple = 2.0; // Default Reward Multiple for Initial TP Placement

input group "=== Line Colors ==="
input color  InpEntryLineColor = clrDodgerBlue; // Entry Line Color
input color  InpStopLineColor  = clrRed;        // Stop Loss Line Color
input color  InpTPLineColor    = clrLime;       // Take Profit Line Color

input group "=== Panel Settings ==="
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel Corner
input int    InpPanelXDistance  = 12;    // Panel X Distance (pixels)
input int    InpPanelYDistance  = 18;    // Panel Y Distance (pixels)
input int    InpPanelFontSize   = 9;     // Panel Font Size
input color  InpPanelTextColor  = clrWhite;    // Panel Text Color
input color  InpPanelBgColor    = C'20,20,20'; // Panel Background Color

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string g_Prefix        = "RiskCalc_";
string g_EntryLineName;
string g_StopLineName;
string g_TPLineName;
string g_PanelBgName;

//--- one dedicated label object per text row, so every line gets its own
//--- vertical position instead of relying on embedded "\n" inside a single
//--- label (which does not reliably render as multiple lines in MT5)
#define PANEL_MAX_LINES 8
string g_LineNames[PANEL_MAX_LINES];
int    g_TotalLines = 0;   // 6 lines without a TP line, 8 lines with one

//--- layout constants, derived once from the font size so spacing always
//--- scales sensibly regardless of the chosen InpPanelFontSize
int g_LineHeight   = 0;    // vertical pixel step between two consecutive lines
int g_PanelPadTop  = 6;    // inner padding above the first line
int g_PanelPadSide = 8;    // inner padding to the left/right of the text

//--- cache of the last-seen line prices, used to avoid recalculating on every
//--- single tick when nothing has actually changed
double g_LastEntry = 0.0;
double g_LastStop  = 0.0;
double g_LastTP    = 0.0;
bool   g_ObjectsReady = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRiskPercent <= 0.0 && InpRiskMode != RISK_FIXED_MONEY)
     {
      Alert("RiskBasedPositionSizeCalculator: Risk Percent must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskMoney <= 0.0 && InpRiskMode == RISK_FIXED_MONEY)
     {
      Alert("RiskBasedPositionSizeCalculator: Risk Money must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_EntryLineName = g_Prefix + "EntryLine";
   g_StopLineName  = g_Prefix + "StopLine";
   g_TPLineName    = g_Prefix + "TPLine";
   g_PanelBgName   = g_Prefix + "PanelBG";

   for(int i = 0; i < PANEL_MAX_LINES; i++)
      g_LineNames[i] = g_Prefix + "Line" + IntegerToString(i);

//--- 6 fixed rows (title, direction, entry, stop, risk, size) plus 2 more
//--- (TP, reward) when the take-profit line is enabled
   g_TotalLines = InpShowTakeProfitLine ? 8 : 6;

//--- a little vertical breathing room scales with the chosen font size,
//--- so lines never overlap even if the user picks a larger font
   g_LineHeight = InpPanelFontSize + 8;

   IndicatorSetString(INDICATOR_SHORTNAME, "Risk-Based Position Size Calculator");

   CreateInitialObjects();
   g_ObjectsReady = true;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove every chart object this indicator has created, identified by its unique prefix
   ObjectsDeleteAll(0, g_Prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                             |
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
   if(rates_total < 1)
      return(0);

   if(prev_calculated == 0)
     {
      //--- first run: make sure objects exist (handles a rare re-init without OnInit re-running
      //--- the object creation, e.g. after ObjectsDeleteAll from another script) and force a
      //--- full panel refresh
      if(!g_ObjectsReady)
        {
         CreateInitialObjects();
         g_ObjectsReady = true;
        }
      RecalculateAndUpdatePanel();
      return(rates_total);
     }

//--- cheap check: only the three line prices are read, no bar history is
//--- rescanned, so this costs nothing extra on a normal tick
   double curEntry = ObjectGetDouble(0, g_EntryLineName, OBJPROP_PRICE);
   double curStop  = ObjectGetDouble(0, g_StopLineName, OBJPROP_PRICE);
   double curTP    = InpShowTakeProfitLine ? ObjectGetDouble(0, g_TPLineName, OBJPROP_PRICE) : 0.0;

   if(curEntry != g_LastEntry || curStop != g_LastStop || curTP != g_LastTP)
      RecalculateAndUpdatePanel();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Chart event handler — gives instant feedback while a line is     |
//| being dragged, instead of waiting for the next tick              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_ENDEDIT)
     {
      if(sparam == g_EntryLineName || sparam == g_StopLineName || sparam == g_TPLineName)
        {
         RecalculateAndUpdatePanel();
         ChartRedraw(0);
        }
     }
  }

//+------------------------------------------------------------------+
//| Creates the draggable trade lines and the info panel, using      |
//| sensible starting positions relative to the current price        |
//+------------------------------------------------------------------+
void CreateInitialObjects()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double entryPrice = ask;
   double stopPrice  = ask - InpDefaultStopPoints * _Point;
   double tpPrice    = ask + InpDefaultStopPoints * InpDefaultRewardMultiple * _Point;

   CreateOrKeepHLine(g_EntryLineName, entryPrice, InpEntryLineColor, "Entry");
   CreateOrKeepHLine(g_StopLineName, stopPrice, InpStopLineColor, "Stop Loss");

   if(InpShowTakeProfitLine)
      CreateOrKeepHLine(g_TPLineName, tpPrice, InpTPLineColor, "Take Profit");

   CreatePanel();
  }

//+------------------------------------------------------------------+
//| Creates a draggable horizontal price line, or leaves it alone if |
//| it already exists (e.g. indicator inputs were changed, not the   |
//| chart itself — the user's manual placement should be preserved)  |
//+------------------------------------------------------------------+
void CreateOrKeepHLine(const string name, const double price, const color clr, const string tooltip)
  {
   if(ObjectFind(0, name) >= 0)
      return;

   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip + " — drag to adjust");
  }

//+------------------------------------------------------------------+
//| Creates the background rectangle and one label object per text   |
//| row. Each row gets its own fixed Y-offset below the panel top,   |
//| so the layout is always vertical, one item per line.             |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   if(ObjectFind(0, g_PanelBgName) < 0)
     {
      ObjectCreate(0, g_PanelBgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_XDISTANCE, InpPanelXDistance - g_PanelPadSide);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_YDISTANCE, InpPanelYDistance - g_PanelPadTop);
      //--- placeholder size; RecalculateAndUpdatePanel() resizes this to fit
      //--- the actual text the very first time it runs, and on every refresh
      //--- after that, so the panel never clips or overflows
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_XSIZE, 220);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_YSIZE, g_TotalLines * g_LineHeight + g_PanelPadTop * 2);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BGCOLOR, InpPanelBgColor);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BACK, false);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_HIDDEN, true);
     }

//--- create exactly g_TotalLines label rows, each pinned to its own Y
//--- position (InpPanelYDistance + row * g_LineHeight), all left-aligned
//--- at the same X so the whole block reads as a clean vertical list
   for(int i = 0; i < g_TotalLines; i++)
     {
      string lineName = g_LineNames[i];
      int rowY = InpPanelYDistance + i * g_LineHeight;

      if(ObjectFind(0, lineName) < 0)
         ObjectCreate(0, lineName, OBJ_LABEL, 0, 0, 0);

      ObjectSetInteger(0, lineName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, lineName, OBJPROP_XDISTANCE, InpPanelXDistance);
      ObjectSetInteger(0, lineName, OBJPROP_YDISTANCE, rowY);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpPanelTextColor);
      ObjectSetInteger(0, lineName, OBJPROP_FONTSIZE, InpPanelFontSize);
      ObjectSetString(0, lineName, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
      ObjectSetString(0, lineName, OBJPROP_TEXT, "");
     }
  }

//+------------------------------------------------------------------+
//| Rough monospace-font width estimate, in pixels, for a given       |
//| string at the panel's font size — avoids depending on platform-   |
//| specific text-measurement APIs while still scaling sensibly with  |
//| both font size and the actual number of characters in each line   |
//+------------------------------------------------------------------+
int EstimateTextWidthPx(const string text)
  {
   return (int)MathRound(StringLen(text) * (InpPanelFontSize * 0.62));
  }

//+------------------------------------------------------------------+
//| Reads the current line prices, computes the position size for    |
//| the configured risk, and refreshes the panel text                |
//+------------------------------------------------------------------+
void RecalculateAndUpdatePanel()
  {
   double entryPrice = ObjectGetDouble(0, g_EntryLineName, OBJPROP_PRICE);
   double stopPrice  = ObjectGetDouble(0, g_StopLineName, OBJPROP_PRICE);
   double tpPrice    = InpShowTakeProfitLine ? ObjectGetDouble(0, g_TPLineName, OBJPROP_PRICE) : 0.0;

   g_LastEntry = entryPrice;
   g_LastStop  = stopPrice;
   g_LastTP    = tpPrice;

   double stopDistance = MathAbs(entryPrice - stopPrice);
   long   stopPoints   = (_Point > 0) ? (long)MathRound(stopDistance / _Point) : 0;
   string direction    = (entryPrice >= stopPrice) ? "BUY" : "SELL";

//--- resolve the risk amount in account currency from the selected basis
   double riskMoney = 0.0;
   switch(InpRiskMode)
     {
      case RISK_PERCENT_BALANCE:
         riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
         break;
      case RISK_PERCENT_EQUITY:
         riskMoney = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPercent / 100.0;
         break;
      case RISK_FIXED_MONEY:
         riskMoney = InpRiskMoney;
         break;
     }

//--- convert the stop distance into a monetary value per 1.0 lot, using the
//--- symbol's own tick value/size so this is correct for FX, metals, indices, etc.
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double lots = 0.0;

   if(tickSize > 0.0 && stopDistance > 0.0)
     {
      double valuePerPriceUnitPerLot = tickValue / tickSize;
      double lossPerLot = stopDistance * valuePerPriceUnitPerLot;
      if(lossPerLot > 0.0)
         lots = riskMoney / lossPerLot;
     }

//--- normalize the raw lot value to the symbol's allowed volume step/min/max
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(volStep > 0.0)
      lots = MathFloor(lots / volStep) * volStep;
   lots = MathMax(volMin, MathMin(volMax, lots));

   string currency = AccountInfoString(ACCOUNT_CURRENCY);

//--- build each row as its own array entry — one item per line, in the
//--- exact order they should appear top to bottom in the panel
   string lines[PANEL_MAX_LINES];
   lines[0] = "RISK-BASED POSITION SIZE";
   lines[1] = "Direction: " + direction;
   lines[2] = "Entry: " + DoubleToString(entryPrice, _Digits);
   lines[3] = "Stop: " + DoubleToString(stopPrice, _Digits) + " (" + IntegerToString(stopPoints) + " pts)";
   lines[4] = "Risk: " + DoubleToString(riskMoney, 2) + " " + currency;
   lines[5] = "Size: " + DoubleToString(lots, 2) + " lots";

   if(InpShowTakeProfitLine)
     {
      double rewardDistance = MathAbs(tpPrice - entryPrice);
      long   rewardPoints   = (_Point > 0) ? (long)MathRound(rewardDistance / _Point) : 0;
      double rewardMoney    = (stopDistance > 0.0) ? riskMoney * (rewardDistance / stopDistance) : 0.0;
      double rr = (stopDistance > 0.0) ? rewardDistance / stopDistance : 0.0;

      lines[6] = "TP: " + DoubleToString(tpPrice, _Digits) + " (" + IntegerToString(rewardPoints) + " pts)";
      lines[7] = "Reward: " + DoubleToString(rewardMoney, 2) + " " + currency + "  R:R 1:" + DoubleToString(rr, 2);
     }

//--- push each line into its own label object, and track the widest line
//--- so the background can be resized to fit everything with no clipping
   int maxWidthPx = 0;

   for(int i = 0; i < g_TotalLines; i++)
     {
      ObjectSetString(0, g_LineNames[i], OBJPROP_TEXT, lines[i]);
      int w = EstimateTextWidthPx(lines[i]);
      if(w > maxWidthPx)
         maxWidthPx = w;
     }

//--- resize the panel background to comfortably fit the longest current
//--- line and every row, with a small margin on all sides. This runs on
//--- every refresh, so the panel adapts automatically to any symbol,
//--- digit count, price magnitude, currency code or chart font size.
   int panelWidth  = MathMax(150, maxWidthPx + g_PanelPadSide * 2);
   int panelHeight = g_TotalLines * g_LineHeight + g_PanelPadTop * 2;

   ObjectSetInteger(0, g_PanelBgName, OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, g_PanelBgName, OBJPROP_YSIZE, panelHeight);

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
