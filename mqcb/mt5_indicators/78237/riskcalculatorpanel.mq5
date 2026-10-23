//+------------------------------------------------------------------+
//|                                          RiskCalculatorPanel.mq5 |
//|  Position size calculator with draggable Stop Loss and Take      |
//|  Profit lines. Drag the SL line, type your risk %, read the lot. |
//|  The indicator never trades.                                     |
//+------------------------------------------------------------------+
#property copyright   "Shanawaz M."
#property version     "1.00"
#property description "Risk-based position size calculator. Drag the SL/TP lines on the chart and the panel shows the lot size for your risk, the money at risk, reward:risk and required margin. Never places trades."
#property indicator_chart_window
#property indicator_plots 0

//--- base used for the risk percentage
enum ENUM_RISK_BASE
  {
   RISK_BASE_BALANCE,     // Balance
   RISK_BASE_EQUITY,      // Equity
   RISK_BASE_FREE_MARGIN  // Free margin
  };

//--- input parameters
input double         InpRiskPercent   = 1.0;               // Risk per trade, %
input ENUM_RISK_BASE InpRiskBase      = RISK_BASE_BALANCE; // Risk calculated from
input double         InpFixedRisk     = 0.0;               // Fixed risk in account currency (>0 overrides %)
input int            InpSLPoints      = 200;               // Initial SL distance, points
input int            InpTPPoints      = 400;               // Initial TP distance, points (0 = no TP line)
input int            InpPanelX        = 15;                // Panel X offset, pixels
input int            InpPanelY        = 30;                // Panel Y offset, pixels
input int            InpFontSize      = 9;                 // Font size
input color          InpPanelColor    = clrWhiteSmoke;     // Panel background
input color          InpTextColor     = clrBlack;          // Panel text
input color          InpSLColor       = clrRed;            // SL line color
input color          InpTPColor       = clrSeaGreen;       // TP line color

//--- object names
#define PREFIX     "RCP_"
#define NAME_BG     PREFIX "bg"
#define NAME_SL     PREFIX "sl"
#define NAME_TP     PREFIX "tp"
#define NAME_EDIT   PREFIX "risk_edit"
#define ROWS       9

double g_risk_percent;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRiskPercent <= 0 && InpFixedRisk <= 0)
     {
      Print("Set a positive risk % or a fixed risk amount");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_risk_percent = InpRiskPercent;

   MqlTick tick;
   double  price = SymbolInfoTick(_Symbol, tick) ? tick.bid : SymbolInfoDouble(_Symbol, SYMBOL_BID);

//--- create lines only if they are not on the chart yet (keeps user position on timeframe change)
   if(ObjectFind(0, NAME_SL) < 0)
      CreateLine(NAME_SL, price - InpSLPoints * _Point, InpSLColor, "Stop Loss - drag me");
   if(InpTPPoints > 0 && ObjectFind(0, NAME_TP) < 0)
      CreateLine(NAME_TP, price + InpTPPoints * _Point, InpTPColor, "Take Profit - drag me");

   CreatePanel();
   UpdatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- keep the lines when only the timeframe or inputs change
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
     {
      ObjectsDeleteAll(0, PREFIX + "row");
      ObjectDelete(0, NAME_BG);
      ObjectDelete(0, NAME_EDIT);
     }
   else
      ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   UpdatePanel();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Chart events: line dragged or risk % edited                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_DRAG && (sparam == NAME_SL || sparam == NAME_TP))
      UpdatePanel();

   if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == NAME_EDIT)
     {
      double value = StringToDouble(ObjectGetString(0, NAME_EDIT, OBJPROP_TEXT));
      if(value > 0 && value <= 100)
         g_risk_percent = value;
      ObjectSetString(0, NAME_EDIT, OBJPROP_TEXT, DoubleToString(g_risk_percent, 2));
      UpdatePanel();
     }
  }

//+------------------------------------------------------------------+
//| Create a draggable horizontal line                               |
//+------------------------------------------------------------------+
void CreateLine(const string name, const double price, const color clr, const string tooltip)
  {
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
  }

//+------------------------------------------------------------------+
//| Create the panel background, risk edit box and text rows         |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   int row_h  = InpFontSize * 2 + 2;
   int width  = InpFontSize * 30;
   int height = (ROWS + 1) * row_h + 12;

   ObjectCreate(0, NAME_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, NAME_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, NAME_BG, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, NAME_BG, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, NAME_BG, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, NAME_BG, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, NAME_BG, OBJPROP_BGCOLOR, InpPanelColor);
   ObjectSetInteger(0, NAME_BG, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, NAME_BG, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, NAME_BG, OBJPROP_SELECTABLE, false);

//--- first row: editable risk percentage
   CreateLabel(PREFIX + "row_hdr", "Risk %:", InpPanelX + 8, InpPanelY + 6);
   ObjectCreate(0, NAME_EDIT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_XDISTANCE, InpPanelX + InpFontSize * 9);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_YDISTANCE, InpPanelY + 4);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_XSIZE, InpFontSize * 7);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_YSIZE, row_h);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, NAME_EDIT, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, NAME_EDIT, OBJPROP_TEXT, DoubleToString(g_risk_percent, 2));
   ObjectSetString(0, NAME_EDIT, OBJPROP_TOOLTIP, "Type a new risk % and press Enter");

   for(int i = 0; i < ROWS; i++)
      CreateLabel(PREFIX + "row" + (string)i, "", InpPanelX + 8, InpPanelY + 8 + (i + 1) * row_h);
  }

//+------------------------------------------------------------------+
//| Create one text label                                            |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const string text, const int x, const int y)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, name, OBJPROP_TEXT, text == "" ? " " : text);
  }

//+------------------------------------------------------------------+
//| Set the text of one panel row                                    |
//+------------------------------------------------------------------+
void SetRow(const int row, const string text, const color clr = clrNONE)
  {
   string name = PREFIX + "row" + (string)row;
//--- an empty OBJ_LABEL shows the word "Label", so use a space instead
   ObjectSetString(0, name, OBJPROP_TEXT, text == "" ? " " : text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr == clrNONE ? InpTextColor : clr);
  }

//+------------------------------------------------------------------+
//| Money the user wants to risk                                     |
//+------------------------------------------------------------------+
double RiskMoney()
  {
   if(InpFixedRisk > 0)
      return(InpFixedRisk);
   double base = AccountInfoDouble(ACCOUNT_BALANCE);
   if(InpRiskBase == RISK_BASE_EQUITY)
      base = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpRiskBase == RISK_BASE_FREE_MARGIN)
      base = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   return(base * g_risk_percent / 100.0);
  }

//+------------------------------------------------------------------+
//| Round a volume down to the symbol's volume step                  |
//+------------------------------------------------------------------+
double NormalizeLots(const double lots)
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0)
      return(0);
   int digits = (int)MathMax(0, MathCeil(-MathLog10(step)));
   return(NormalizeDouble(MathFloor(lots / step + 1e-9) * step, digits));
  }

//+------------------------------------------------------------------+
//| Money value of a price move for 1.0 lot, in account currency.    |
//| Uses tick value, which works inside indicators and for cross     |
//| currency symbols (the terminal converts tick value for us).      |
//+------------------------------------------------------------------+
double MoneyPerLot(const double distance, const bool is_loss)
  {
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(_Symbol, is_loss ? SYMBOL_TRADE_TICK_VALUE_LOSS : SYMBOL_TRADE_TICK_VALUE_PROFIT);
   if(tick_value <= 0)
      tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tick_size <= 0 || tick_value <= 0)
      return(0);
   return(distance / tick_size * tick_value);
  }

//+------------------------------------------------------------------+
//| Recalculate everything and refresh the panel                     |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(ObjectFind(0, NAME_SL) < 0)
     {
      SetRow(0, "SL line was deleted.");
      SetRow(1, "Re-attach the indicator.");
      for(int i = 2; i < ROWS; i++)
         SetRow(i, "");
      ChartRedraw();
      return;
     }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.bid <= 0)
      return;

   double sl     = ObjectGetDouble(0, NAME_SL, OBJPROP_PRICE);
   bool   is_buy = (sl < tick.bid);
   double entry  = is_buy ? tick.ask : tick.bid;
   double sl_dist = MathAbs(entry - sl);
   string ccy    = AccountInfoString(ACCOUNT_CURRENCY);

//--- loss of 1.0 lot from entry to SL in account currency
   ENUM_ORDER_TYPE type = is_buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double loss_1lot = MoneyPerLot(sl_dist, true);
   if(sl_dist <= 0 || loss_1lot <= 0)
     {
      SetRow(0, "Move the SL line away from price.");
      for(int i = 1; i < ROWS; i++)
         SetRow(i, "");
      ChartRedraw();
      return;
     }

   double risk_money = RiskMoney();
   double raw_lots   = risk_money / loss_1lot;
   double min_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lots       = MathMin(NormalizeLots(raw_lots), max_lot);
   bool   below_min  = (lots < min_lot);
   if(below_min)
      lots = min_lot;
   double actual_risk = lots * loss_1lot;

   double margin    = 0;
   bool   margin_ok = OrderCalcMargin(type, _Symbol, lots, entry, margin) && margin > 0;

   int sl_points = (int)MathRound(sl_dist / _Point);
   int stops_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);

   SetRow(0, StringFormat("Direction : %s from %s", is_buy ? "BUY" : "SELL", DoubleToString(entry, _Digits)));
   SetRow(1, StringFormat("Stop loss : %d points", sl_points), sl_points < stops_lvl ? clrRed : clrNONE);
   SetRow(2, StringFormat("Risk      : %.2f %s", risk_money, ccy));
   SetRow(3, StringFormat("LOT SIZE  : %s", DoubleToString(lots, (int)MathMax(0, MathCeil(-MathLog10(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)))))));
   SetRow(4, StringFormat("Real risk : %.2f %s", actual_risk, ccy), below_min ? clrRed : clrNONE);

//--- take profit row and reward:risk
   if(ObjectFind(0, NAME_TP) >= 0)
     {
      double tp     = ObjectGetDouble(0, NAME_TP, OBJPROP_PRICE);
      bool   valid  = (is_buy ? tp > entry : tp < entry);
      double profit = valid ? MoneyPerLot(MathAbs(tp - entry), false) * lots : 0;
      if(valid && actual_risk > 0)
        {
         SetRow(5, StringFormat("Reward    : %.2f %s", profit, ccy));
         SetRow(6, StringFormat("R:R       : 1 : %.2f", profit / actual_risk));
        }
      else
        {
         SetRow(5, "Reward    : TP on wrong side");
         SetRow(6, "R:R       : -");
        }
     }
   else
     {
      SetRow(5, "Reward    : no TP line");
      SetRow(6, "");
     }

//--- OrderCalcMargin is not available in indicators, so show free margin when it fails
   if(margin_ok)
      SetRow(7, StringFormat("Margin    : %.2f %s", margin, ccy),
             margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE) ? clrRed : clrNONE);
   else
      SetRow(7, StringFormat("Free marg.: %.2f %s", AccountInfoDouble(ACCOUNT_MARGIN_FREE), ccy));
   SetRow(8, below_min ? "Below min lot: risk is higher!" :
          (sl_points < stops_lvl ? "SL is inside broker stop level" : ""),
          clrRed);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
