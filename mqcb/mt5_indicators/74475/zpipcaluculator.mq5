//+------------------------------------------------------------------+
//|                                FoxWave_PipValueCalculator.mq5    |
//|                       Copyright Fox Wave - foxwavetrading.top    |
//|     Live Pip Value, Lot Sizing & Open Position P/L Calculator    |
//+------------------------------------------------------------------+
#property copyright "Fox Wave | foxwavetrading.top"
#property link      "https://foxwavetrading.top"
#property version   "1.01"
#property description "FoxWave Pip Value Calculator - shows live pip value, risk-based lot sizing, your custom volume risk analysis, and live P/L for open positions."
#property indicator_chart_window
#property indicator_plots 0

//======================================================================
//  INPUTS
//======================================================================
input group "PANEL"
input int     PanelX            = 15;    // Panel X offset
input int     PanelY            = 25;    // Panel Y offset
input int     RefreshSeconds    = 1;     // Refresh interval (seconds)

input group "RISK CALCULATOR"
input double  RiskPercent       = 1.0;   // Risk % of account balance per trade
input double  StopLossPips      = 20.0;  // Stop loss distance (pips) used for lot sizing

input group "YOUR VOLUME"
input double  MyVolume          = 0.10;  // Your custom lot size to analyze

input group "COLORS"
input color   ClrPanelBg        = C'10,12,20';     // Outer panel background
input color   ClrHeaderBg       = C'16,20,38';     // Header bar background
input color   ClrAccent         = C'255,140,0';    // Fox Wave accent (orange)
input color   ClrSymbol         = C'235,240,250';  // Symbol name text
input color   ClrValue          = C'255,255,255';  // Main value text
input color   ClrLabel          = C'110,120,145';  // Small caption labels
input color   ClrLotSize        = C'120,170,255';  // Calculated lot size
input color   ClrProfit         = C'90,220,160';   // Positive P/L / low risk
input color   ClrLoss           = C'255,90,90';    // Negative P/L / high risk
input color   ClrNeutral        = C'150,160,180';  // Zero / no position
input color   ClrWarning        = C'255,180,0';    // Medium risk warning
input color   ClrTime           = C'80,92,118';    // Timestamp
input color   ClrBorder         = C'45,55,85';     // Borders
input color   ClrFooter         = C'70,80,105';    // Footer brand text

//======================================================================
//  CONSTANTS
//======================================================================
#define PANEL_W     240
#define PANEL_H     355
#define FONT_MAIN   "Consolas"
#define PFX         "FWPVC_"

//======================================================================
//  GLOBALS
//======================================================================
string   g_sym;
double   g_pipValue     = 0;   // value of 1 pip per 1.0 lot, in account currency
double   g_pipSize      = 0;
double   g_calcLotSize  = 0;   // suggested lot size based on risk inputs

// MyVolume analysis
double   g_myPipValue   = 0;   // pip value for MyVolume lots
double   g_myRiskPct    = 0;   // actual risk % for MyVolume + SL
double   g_myRiskAmt    = 0;   // actual risk in account currency

// Open position
double   g_posVolume    = 0;
double   g_posProfit    = 0;
double   g_posPipsGain  = 0;
bool     g_hasPosition  = false;
datetime g_lastUpdate   = 0;

//======================================================================
int OnInit()
  {
   g_sym = _Symbol;
   DrawPanel();
   UpdatePipValue();
   UpdatePositionInfo();
   RefreshPanel();
   EventSetTimer(MathMax(1, RefreshSeconds));
   return INIT_SUCCEEDED;
  }

//======================================================================
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }

//======================================================================
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  { return rates_total; }

//======================================================================
void OnTimer()
  {
   UpdatePipValue();
   UpdatePositionInfo();
   RefreshPanel();
  }

//======================================================================
//  PIP SIZE / PIP VALUE CALCULATION
//======================================================================
double CalcPipSize()
  {
   int digits = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(g_sym, SYMBOL_POINT);
   if(digits == 3 || digits == 5) return point * 10;
   return point;
  }

void UpdatePipValue()
  {
   if(!SymbolSelect(g_sym, true)) return;

   g_pipSize = CalcPipSize();
   double tickValue = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_SIZE);

   if(tickSize <= 0) { g_pipValue = 0; return; }

   // Value of one pip per 1.0 lot in account currency
   g_pipValue = (g_pipSize / tickSize) * tickValue;

   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercent / 100.0);

   // Suggested lot size from Risk % + SL
   if(g_pipValue > 0 && StopLossPips > 0)
     {
      double rawLots = riskAmount / (StopLossPips * g_pipValue);
      g_calcLotSize  = NormalizeLots(rawLots);
     }
   else
      g_calcLotSize = 0;

   // MyVolume analysis
   if(g_pipValue > 0 && MyVolume > 0)
     {
      g_myPipValue = g_pipValue * MyVolume;
      g_myRiskAmt  = StopLossPips * g_myPipValue;
      g_myRiskPct  = (balance > 0) ? (g_myRiskAmt / balance) * 100.0 : 0;
     }
   else
     {
      g_myPipValue = 0;
      g_myRiskAmt  = 0;
      g_myRiskPct  = 0;
     }
  }

double NormalizeLots(double lots)
  {
   double minLot  = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_STEP);

   if(lotStep <= 0) lotStep = 0.01;

   double normalized = MathFloor(lots / lotStep) * lotStep;
   if(normalized < minLot) normalized = minLot;
   if(maxLot > 0 && normalized > maxLot) normalized = maxLot;
   return normalized;
  }

//======================================================================
//  OPEN POSITION INFO (current chart symbol)
//======================================================================
void UpdatePositionInfo()
  {
   g_hasPosition = false;
   g_posVolume   = 0;
   g_posProfit   = 0;
   g_posPipsGain = 0;

   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      string posSym = PositionGetSymbol(i);
      if(posSym != g_sym) continue;
      if(!PositionSelect(posSym)) continue;

      g_hasPosition = true;
      g_posVolume  += PositionGetDouble(POSITION_VOLUME);
      g_posProfit  += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double curPrice  = PositionGetDouble(POSITION_PRICE_CURRENT);
      long   posType   = PositionGetInteger(POSITION_TYPE);

      double diff = (posType == POSITION_TYPE_BUY) ? (curPrice - openPrice) : (openPrice - curPrice);
      if(g_pipSize > 0) g_posPipsGain += diff / g_pipSize;
     }

   g_lastUpdate = TimeCurrent();
  }

//======================================================================
//  DRAW PANEL (built once)
//======================================================================
void DrawPanel()
  {
   // Outer panel
   Rect(PFX+"BG",       PanelX, PanelY, PANEL_W, PANEL_H, ClrPanelBg, ClrBorder);

   // Header
   Rect(PFX+"HDR",      PanelX, PanelY, PANEL_W, 30, ClrHeaderBg, ClrHeaderBg);
   Rect(PFX+"HDRLINE",  PanelX, PanelY+30, PANEL_W, 2, ClrAccent, ClrAccent);
   Label(PFX+"TITLE",   PanelX+10, PanelY+6,  "FOX WAVE",             FONT_MAIN, 11, ClrAccent);
   Label(PFX+"SUB",     PanelX+10, PanelY+19, "PIP VALUE CALCULATOR",  FONT_MAIN,  7, ClrLabel);

   // Symbol
   Label(PFX+"SYM",     PanelX+10, PanelY+40, g_sym, FONT_MAIN, 13, ClrSymbol);

   Rect(PFX+"DIV1",     PanelX+10, PanelY+62, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // ── BLOCK 1: PIP VALUE (1.00 lot) ──────────────────────────────
   Label(PFX+"PV_LBL",  PanelX+10, PanelY+70,  "PIP VALUE (1.00 LOT)", FONT_MAIN,  7, ClrLabel);
   Label(PFX+"PV_VAL",  PanelX+10, PanelY+82,  "---",                   FONT_MAIN, 16, ClrValue);

   Rect(PFX+"DIV2",     PanelX+10, PanelY+108, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // ── BLOCK 2: SUGGESTED LOT (Risk % calculator) ─────────────────
   Label(PFX+"RISK_LBL",PanelX+10, PanelY+115, "SUGGESTED LOT SIZE",   FONT_MAIN,  7, ClrLabel);
   Label(PFX+"RISK_VAL",PanelX+10, PanelY+127, "---",                   FONT_MAIN, 16, ClrLotSize);
   Label(PFX+"RISK_SUB",PanelX+10, PanelY+147, "",                      FONT_MAIN,  7, ClrLabel);

   Rect(PFX+"DIV3",     PanelX+10, PanelY+162, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // ── BLOCK 3: YOUR VOLUME analysis ──────────────────────────────
   Label(PFX+"MY_LBL",  PanelX+10, PanelY+169, "YOUR VOLUME",           FONT_MAIN,  7, ClrLabel);
   Label(PFX+"MY_VOL",  PanelX+10, PanelY+181, "---",                   FONT_MAIN, 12, ClrValue);
   Label(PFX+"MY_PV",   PanelX+10, PanelY+197, "",                      FONT_MAIN,  8, ClrLabel);
   Label(PFX+"MY_RPCT", PanelX+10, PanelY+210, "",                      FONT_MAIN, 12, ClrNeutral);
   Label(PFX+"MY_RAMT", PanelX+10, PanelY+225, "",                      FONT_MAIN,  8, ClrLabel);

   Rect(PFX+"DIV4",     PanelX+10, PanelY+242, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // ── BLOCK 4: OPEN POSITION ─────────────────────────────────────
   Label(PFX+"POS_LBL", PanelX+10, PanelY+249, "OPEN POSITION",         FONT_MAIN,  7, ClrLabel);
   Label(PFX+"POS_VOL", PanelX+10, PanelY+261, "No open position",       FONT_MAIN,  9, ClrNeutral);
   Label(PFX+"POS_PIPS",PanelX+10, PanelY+275, "",                      FONT_MAIN,  9, ClrNeutral);
   Label(PFX+"POS_PL",  PanelX+10, PanelY+289, "",                      FONT_MAIN, 13, ClrNeutral);

   // Footer
   Rect(PFX+"FOOTLINE", PanelX, PanelY+PANEL_H-18, PANEL_W, 1, ClrBorder, ClrBorder);
   Label(PFX+"FOOT",    PanelX+10, PanelY+PANEL_H-13, "foxwavetrading.top", FONT_MAIN, 7, ClrFooter);

   ChartRedraw();
  }

//======================================================================
//  REFRESH VALUES
//======================================================================

// Returns risk colour: green < target, orange < 1.5×, red >= 1.5×
color RiskColor(double actualPct, double targetPct)
  {
   if(targetPct <= 0) return ClrNeutral;
   double ratio = actualPct / targetPct;
   if(ratio <= 1.0)  return ClrProfit;   // at or below target – green
   if(ratio < 1.5)   return ClrWarning;  // up to 50 % over – orange
   return ClrLoss;                        // more than 50 % over – red
  }

void RefreshPanel()
  {
   string acctCurrency = AccountInfoString(ACCOUNT_CURRENCY);

   // ── Block 1: Pip value ─────────────────────────────────────────
   string pvTxt = (g_pipValue > 0)
                  ? DoubleToString(g_pipValue, 2) + " " + acctCurrency
                  : "---";
   ObjectSetString(0, PFX+"PV_VAL", OBJPROP_TEXT, pvTxt);

   // ── Block 2: Suggested lot ─────────────────────────────────────
   string riskTxt = (g_calcLotSize > 0)
                    ? DoubleToString(g_calcLotSize, 2) + " lots"
                    : "---";
   ObjectSetString(0, PFX+"RISK_VAL", OBJPROP_TEXT, riskTxt);

   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercent / 100.0);
   string riskSub    = DoubleToString(RiskPercent, 1) + "% risk = " +
                       DoubleToString(riskAmount, 2) + " " + acctCurrency +
                       "  |  SL " + DoubleToString(StopLossPips, 0) + "p";
   ObjectSetString(0, PFX+"RISK_SUB", OBJPROP_TEXT, riskSub);

   // ── Block 3: Your Volume ───────────────────────────────────────
   if(g_myPipValue > 0)
     {
      // Header row: volume + pip value for that volume
      ObjectSetString(0,  PFX+"MY_VOL", OBJPROP_TEXT,
                      DoubleToString(MyVolume, 2) + " lots");
      ObjectSetInteger(0, PFX+"MY_VOL", OBJPROP_COLOR, ClrValue);

      ObjectSetString(0,  PFX+"MY_PV", OBJPROP_TEXT,
                      "Pip value: " + DoubleToString(g_myPipValue, 2) + " " + acctCurrency);

      // Actual risk %
      color rClr = RiskColor(g_myRiskPct, RiskPercent);
      ObjectSetString(0,  PFX+"MY_RPCT", OBJPROP_TEXT,
                      "Actual risk: " + DoubleToString(g_myRiskPct, 2) + "%");
      ObjectSetInteger(0, PFX+"MY_RPCT", OBJPROP_COLOR, rClr);

      // Actual risk in money
      ObjectSetString(0,  PFX+"MY_RAMT", OBJPROP_TEXT,
                      "Risk amount: " + DoubleToString(g_myRiskAmt, 2) + " " + acctCurrency +
                      "  |  SL " + DoubleToString(StopLossPips, 0) + "p");
      ObjectSetInteger(0, PFX+"MY_RAMT", OBJPROP_COLOR, rClr);
     }
   else
     {
      ObjectSetString(0,  PFX+"MY_VOL",  OBJPROP_TEXT, "---");
      ObjectSetInteger(0, PFX+"MY_VOL",  OBJPROP_COLOR, ClrNeutral);
      ObjectSetString(0,  PFX+"MY_PV",   OBJPROP_TEXT, "");
      ObjectSetString(0,  PFX+"MY_RPCT", OBJPROP_TEXT, "");
      ObjectSetString(0,  PFX+"MY_RAMT", OBJPROP_TEXT, "");
     }

   // ── Block 4: Open position ─────────────────────────────────────
   if(g_hasPosition)
     {
      ObjectSetString(0,  PFX+"POS_VOL", OBJPROP_TEXT,
                      DoubleToString(g_posVolume, 2) + " lots open on " + g_sym);
      ObjectSetInteger(0, PFX+"POS_VOL", OBJPROP_COLOR, ClrSymbol);

      string pipsTxt = (g_posPipsGain >= 0 ? "+" : "") +
                       DoubleToString(g_posPipsGain, 1) + " pips";
      ObjectSetString(0,  PFX+"POS_PIPS", OBJPROP_TEXT, pipsTxt);
      ObjectSetInteger(0, PFX+"POS_PIPS", OBJPROP_COLOR,
                       g_posPipsGain >= 0 ? ClrProfit : ClrLoss);

      string plTxt = (g_posProfit >= 0 ? "+" : "") +
                     DoubleToString(g_posProfit, 2) + " " + acctCurrency;
      ObjectSetString(0,  PFX+"POS_PL", OBJPROP_TEXT, plTxt);
      ObjectSetInteger(0, PFX+"POS_PL", OBJPROP_COLOR,
                       g_posProfit >= 0 ? ClrProfit : ClrLoss);
     }
   else
     {
      ObjectSetString(0,  PFX+"POS_VOL",  OBJPROP_TEXT, "No open position");
      ObjectSetInteger(0, PFX+"POS_VOL",  OBJPROP_COLOR, ClrNeutral);
      ObjectSetString(0,  PFX+"POS_PIPS", OBJPROP_TEXT, "-");
      ObjectSetInteger(0, PFX+"POS_PIPS", OBJPROP_COLOR, ClrNeutral);
      ObjectSetString(0,  PFX+"POS_PL",   OBJPROP_TEXT, "-");
      ObjectSetInteger(0, PFX+"POS_PL",   OBJPROP_COLOR, ClrNeutral);
     }

   ChartRedraw();
  }

//======================================================================
//  HELPERS
//======================================================================
void Rect(string name,int x,int y,int w,int h,color bg,color border)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,      w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,      h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,    bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,      border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,       true);
  }

void Label(string name,int x,int y,string txt,string font,int sz,color clr)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name,OBJPROP_TEXT,      txt);
   ObjectSetString(0, name,OBJPROP_FONT,      font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,  sz);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     clr);
   ObjectSetInteger(0,name,OBJPROP_CORNER,    CORNER_LEFT_UPPER);
  }
//+------------------------------------------------------------------+