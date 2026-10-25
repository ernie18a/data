//+------------------------------------------------------------------+
//|                                 RiskPositionSizeCalculator.mq5   |
//|                                                                  |
//| Position size calculator driven by a fixed percentage risk.      |
//| Calculation and display only - it never sends or modifies orders.|
//+------------------------------------------------------------------+
#property copyright "Radoslaw Karol Lubas"
#property link      "https://www.mql5.com/en/users/zanczo"
#property version   "1.00"

#property description "Calculates position size from a risk percentage and a stop loss level."
#property description "Drag the Entry and Stop lines - lot size, risk, margin and target are"
#property description "recalculated instantly."
#property description ""
#property description "This tool never sends, modifies or closes any order."

//--- object names, all sharing one prefix so cleanup is a single call
#define OBJ_PREFIX  "RPSC_"
#define NAME_ENTRY  "RPSC_entry"
#define NAME_STOP   "RPSC_stop"
#define NAME_TAKE   "RPSC_take"
#define NAME_ROW    "RPSC_row_"
#define NAME_BG     "RPSC_bg"
#define NAME_BTN    "RPSC_btn"
#define PANEL_ROWS  12
#define LABEL_WIDTH 16

//+------------------------------------------------------------------+
//| Enumerations exposed as inputs                                   |
//+------------------------------------------------------------------+
enum RiskBase
  {
   RISK_BALANCE = 0,       // Account balance
   RISK_EQUITY  = 1,       // Account equity
   RISK_FREE    = 2        // Free margin
  };

enum EntryMode
  {
   ENTRY_MARKET = 0,       // Market price (follows Bid/Ask)
   ENTRY_LINE   = 1        // Entry line (drag it yourself)
  };

enum TradeSide
  {
   SIDE_AUTO = 0,          // Auto (stop below entry = buy)
   SIDE_BUY  = 1,          // Buy
   SIDE_SELL = 2           // Sell
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Risk"
input double    InpRiskPercent = 1.0;                  // Risk per trade (% of base)
input RiskBase  InpRiskBase    = RISK_BALANCE;         // Risk base
input double    InpRewardRatio = 2.0;                  // Reward:risk for target (0 = hide)

input group "Levels"
input EntryMode InpEntryMode   = ENTRY_MARKET;         // Entry source
input TradeSide InpDirection   = SIDE_AUTO;            // Trade direction

input group "Appearance"
input color            InpEntryColor  = clrDodgerBlue; // Entry line colour
input color            InpStopColor   = clrTomato;     // Stop line colour
input color            InpTakeColor   = clrMediumSeaGreen; // Target line colour
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel corner
input int              InpFontSize    = 9;             // Panel font size
input color            InpTextColor   = clrGainsboro;  // Panel text colour
input bool             InpShowBackground = true;       // Info background ON at start
input color            InpBgColor     = C'28,28,36';   // Info background colour
input int              InpPanelWidth  = 140;           // Info background MIN width (px, auto-fits content)

//--- runtime state of the info background, flipped by the on-chart button
bool g_show_bg = true;

//+------------------------------------------------------------------+
//| One calculation pass                                             |
//+------------------------------------------------------------------+
struct CalcResult
  {
   bool              valid;
   string            message;
   ENUM_ORDER_TYPE   side;
   double            entry;
   double            stop;
   double            take;
   double            distance_points;
   double            risk_money;
   double            lot;
   double            margin;
   double            free_after;
   double            reward_money;

                     CalcResult()
     {
      valid           = false;
      message         = "";
      side            = ORDER_TYPE_BUY;
      entry           = 0.0;
      stop            = 0.0;
      take            = 0.0;
      distance_points = 0.0;
      risk_money      = 0.0;
      lot             = 0.0;
      margin          = 0.0;
      free_after      = 0.0;
      reward_money    = 0.0;
     }
  };

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRiskPercent <= 0.0 || InpRiskPercent > 100.0)
     {
      Print("Risk per trade must be greater than 0 and not greater than 100.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRewardRatio < 0.0)
     {
      Print("Reward:risk cannot be negative.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpFontSize < 6 || InpFontSize > 24)
     {
      Print("Panel font size must be between 6 and 24.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(!BuildLevels())
      return(INIT_FAILED);
   g_show_bg = InpShowBackground;
   BuildBackground();   //--- created before the rows so it stays behind them
   BuildPanel();
   ApplyBgVisibility();
   Refresh();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Objects survive re-initialisation so dragged levels are kept     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS || reason == REASON_RECOMPILE)
      return;
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   Refresh();
  }

//+------------------------------------------------------------------+
//| Button toggles the info background; dragging a level recalculates |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == NAME_BTN)
     {
      g_show_bg = !g_show_bg;
      ApplyBgVisibility();
      return;
     }
   if(id == CHARTEVENT_OBJECT_DRAG && StringFind(sparam, OBJ_PREFIX) == 0)
      Refresh();
  }

//+------------------------------------------------------------------+
//| Creates the entry and stop lines on first load                   |
//+------------------------------------------------------------------+
bool BuildLevels()
  {
   const double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(bid <= 0.0 || point <= 0.0)
     {
      Print("Symbol quotes are not available yet.");
      return(false);
     }
//--- half a percent of price keeps the default stop sane on any instrument
   const double gap = NormalizePrice(MathMax(bid * 0.005, point * 10.0));
   if(!EnsureLine(NAME_ENTRY, bid, InpEntryColor, InpEntryMode == ENTRY_LINE, "Entry"))
      return(false);
   if(!EnsureLine(NAME_STOP, NormalizePrice(bid - gap), InpStopColor, true, "Stop loss - drag me"))
      return(false);
   if(!EnsureLine(NAME_TAKE, NormalizePrice(bid + gap), InpTakeColor, false, "Target"))
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Creates a horizontal line, or only refreshes its style if it     |
//| already exists (input change must not reset a dragged level)     |
//+------------------------------------------------------------------+
bool EnsureLine(const string name, const double price, const color line_color,
                const bool draggable, const string description)
  {
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
        {
         Print("Cannot create object ", name, ", error ", GetLastError());
         return(false);
        }
     }
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, draggable ? STYLE_SOLID : STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, draggable);
//--- pre-select the draggable line so it can be grabbed without a click first
   ObjectSetInteger(0, name, OBJPROP_SELECTED, draggable);
//--- keep lines in the object list (HIDDEN) but show a label next to them
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetString(0, name, OBJPROP_TEXT, description);
   return(true);
  }

//+------------------------------------------------------------------+
//| Creates the fixed set of panel rows                              |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   const bool lower  = (InpPanelCorner == CORNER_LEFT_LOWER || InpPanelCorner == CORNER_RIGHT_LOWER);
   const bool right  = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
   const int  anchor = right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER;
   const int  step   = InpFontSize + 7;
   for(int i = 0; i < PANEL_ROWS; i++)
     {
      const string name = NAME_ROW + IntegerToString(i);
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      //--- rows grow away from the anchored corner
      const int slot = lower ? (PANEL_ROWS - 1 - i) : i;
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 12);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 18 + slot * step);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
      //--- hidden until Refresh() fills it: an empty OBJPROP_TEXT is rejected
      //--- by the terminal, which would leave the default "Label" caption
      ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
     }
  }

//+------------------------------------------------------------------+
//| Backdrop rectangle behind the panel plus its on/off button       |
//+------------------------------------------------------------------+
void BuildBackground()
  {
   const int step = InpFontSize + 7;
   const int h    = 20 + PANEL_ROWS * step;
   PlaceBox(NAME_BG, OBJ_RECTANGLE_LABEL, 4, 6, InpPanelWidth, h);
   ObjectSetInteger(0, NAME_BG, OBJPROP_BGCOLOR, InpBgColor);
   ObjectSetInteger(0, NAME_BG, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, NAME_BG, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, NAME_BG, OBJPROP_BACK, false);
   ObjectSetInteger(0, NAME_BG, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, NAME_BG, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, NAME_BG, OBJPROP_ZORDER, 0);
   PlaceBox(NAME_BTN, OBJ_BUTTON, 4, h + 12, 110, 22);
   ObjectSetString(0, NAME_BTN, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, NAME_BTN, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_BGCOLOR, InpBgColor);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_BORDER_COLOR, InpTextColor);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, NAME_BTN, OBJPROP_ZORDER, 2);
  }

//+------------------------------------------------------------------+
//| Positions a corner-anchored box. These objects anchor by their   |
//| top-left and extend right/down, so right/lower corners add w/h.   |
//+------------------------------------------------------------------+
void PlaceBox(const string name, const ENUM_OBJECT type,
              const int off_x, const int off_y, const int w, const int h)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, type, 0, 0, 0);
   const bool lower = (InpPanelCorner == CORNER_LEFT_LOWER || InpPanelCorner == CORNER_RIGHT_LOWER);
   const bool right = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, right ? off_x + w : off_x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, lower ? off_y + h : off_y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
  }

//+------------------------------------------------------------------+
//| Applies the current background state to the rectangle and button |
//| Toggled by transparency, not by OBJPROP_TIMEFRAMES: hiding/showing|
//| via timeframes re-draws the object last, so on re-enable it would |
//| jump in front of the text (draw order follows creation, not       |
//| OBJPROP_ZORDER, which only governs click priority).               |
//+------------------------------------------------------------------+
void ApplyBgVisibility()
  {
   ObjectSetInteger(0, NAME_BG, OBJPROP_BGCOLOR, g_show_bg ? InpBgColor : clrNONE);
   ObjectSetInteger(0, NAME_BG, OBJPROP_COLOR,   g_show_bg ? InpTextColor : clrNONE);
   ObjectSetString(0, NAME_BTN, OBJPROP_TEXT, g_show_bg ? "Info BG: ON" : "Info BG: OFF");
   ObjectSetInteger(0, NAME_BTN, OBJPROP_STATE, false);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Full recalculation and repaint                                   |
//+------------------------------------------------------------------+
void Refresh()
  {
   CalcResult r;
   if(ReadLevels(r) && ComputeSize(r) && ComputeTarget(r))
      r.valid = true;
   string rows[PANEL_ROWS];
   BuildRows(r, rows);
   for(int i = 0; i < PANEL_ROWS; i++)
     {
      const string name = NAME_ROW + IntegerToString(i);
      //--- hide empty rows instead of writing "" (rejected -> stale "Label")
      if(StringLen(rows[i]) == 0)
         ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      else
        {
         ObjectSetString(0, name, OBJPROP_TEXT, rows[i]);
         ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
        }
     }
   ResizeBackground(rows);
   ObjectSetInteger(0, NAME_TAKE, OBJPROP_TIMEFRAMES,
                    (r.valid && InpRewardRatio > 0.0) ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
   if(r.valid && InpRewardRatio > 0.0)
      ObjectSetDouble(0, NAME_TAKE, OBJPROP_PRICE, r.take);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Fits the backdrop width to the widest visible row (input is a    |
//| minimum). Row pixel width is measured, not estimated.            |
//+------------------------------------------------------------------+
void ResizeBackground(const string &rows[])
  {
   TextSetFont("Consolas", -InpFontSize * 10);
   uint tw = 0, th = 0, maxw = 0;
   for(int i = 0; i < PANEL_ROWS; i++)
     {
      if(StringLen(rows[i]) == 0)
         continue;
      if(TextGetSize(rows[i], tw, th) && tw > maxw)
         maxw = tw;
     }
//--- rows sit at x=12; +20 keeps a margin on both sides of the text
   int width = (int)maxw + 28;
   if(width < InpPanelWidth)
      width = InpPanelWidth;
   const int step = InpFontSize + 7;
   const int h    = 20 + PANEL_ROWS * step;
   PlaceBox(NAME_BG, OBJ_RECTANGLE_LABEL, 4, 6, width, h);
  }

//+------------------------------------------------------------------+
//| Resolves direction and both price levels                         |
//+------------------------------------------------------------------+
bool ReadLevels(CalcResult &r)
  {
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0)
     {
      r.message = "Waiting for quotes";
      return(false);
     }
   r.stop = ObjectGetDouble(0, NAME_STOP, OBJPROP_PRICE);
   const double reference = (InpEntryMode == ENTRY_MARKET)
                            ? bid
                            : ObjectGetDouble(0, NAME_ENTRY, OBJPROP_PRICE);
   if(InpDirection == SIDE_BUY)
      r.side = ORDER_TYPE_BUY;
   else
      if(InpDirection == SIDE_SELL)
         r.side = ORDER_TYPE_SELL;
      else
         r.side = (r.stop < reference) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   r.entry = (InpEntryMode == ENTRY_MARKET)
             ? ((r.side == ORDER_TYPE_BUY) ? ask : bid)
             : reference;
   if(InpEntryMode == ENTRY_MARKET)
      ObjectSetDouble(0, NAME_ENTRY, OBJPROP_PRICE, r.entry);
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   r.distance_points = (point > 0.0) ? MathAbs(r.entry - r.stop) / point : 0.0;
   return(true);
  }

//+------------------------------------------------------------------+
//| Risk money -> lot size -> margin                                 |
//+------------------------------------------------------------------+
bool ComputeSize(CalcResult &r)
  {
   r.risk_money = RiskBaseValue() * InpRiskPercent / 100.0;
   if(r.risk_money <= 0.0)
     {
      r.message = "Risk base is zero";
      return(false);
     }
//--- the server prices the stop for one lot in account currency, which
//--- keeps cross rates, metals and CFDs correct without manual tick math
   double loss_per_lot = 0.0;
   if(!OrderCalcProfit(r.side, _Symbol, 1.0, r.entry, r.stop, loss_per_lot))
     {
      r.message = "OrderCalcProfit failed, error " + IntegerToString(GetLastError());
      return(false);
     }
   loss_per_lot = -loss_per_lot;
   if(loss_per_lot <= 0.0)
     {
      r.message = "Stop loss is on the wrong side of the entry";
      return(false);
     }
   const double step = VolumeStep();
   const double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
//--- always round down: rounding up would exceed the declared risk
   r.lot = NormalizeDouble(MathFloor(r.risk_money / loss_per_lot / step) * step, VolumeDigits(step));
   if(r.lot < vmin)
     {
      r.message = "Below broker minimum " + DoubleToString(vmin, VolumeDigits(step)) +
                  " lots - risk " + DoubleToString(vmin * loss_per_lot, 2) + " " + Currency();
      return(false);
     }
   if(r.lot > vmax)
      r.lot = vmax;
   r.risk_money = r.lot * loss_per_lot;
   if(!OrderCalcMargin(r.side, _Symbol, r.lot, r.entry, r.margin))
     {
      r.message = "OrderCalcMargin failed, error " + IntegerToString(GetLastError());
      return(false);
     }
   r.free_after = AccountInfoDouble(ACCOUNT_MARGIN_FREE) - r.margin;
   return(true);
  }

//+------------------------------------------------------------------+
//| Target level for the requested reward:risk                       |
//+------------------------------------------------------------------+
bool ComputeTarget(CalcResult &r)
  {
   if(InpRewardRatio <= 0.0)
      return(true);
   const double distance = MathAbs(r.entry - r.stop) * InpRewardRatio;
   r.take = NormalizePrice((r.side == ORDER_TYPE_BUY) ? r.entry + distance : r.entry - distance);
   if(!OrderCalcProfit(r.side, _Symbol, r.lot, r.entry, r.take, r.reward_money))
      r.reward_money = 0.0;
   return(true);
  }

//+------------------------------------------------------------------+
//| Panel content                                                    |
//+------------------------------------------------------------------+
void BuildRows(const CalcResult &r, string &rows[])
  {
   for(int i = 0; i < PANEL_ROWS; i++)
      rows[i] = "";
   rows[0] = "Risk Position Size Calculator";
   rows[1] = Row("Symbol", _Symbol + "  (" + Currency() + " account)");
   rows[2] = Row("Account", "bal " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) +
                 " / eq " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + " " + Currency());
   if(!r.valid)
     {
      rows[3] = Row("Status", r.message);
      return;
     }
   const int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   rows[3] = Row("Direction", (r.side == ORDER_TYPE_BUY) ? "BUY" : "SELL");
   rows[4] = Row("Entry", DoubleToString(r.entry, digits));
   rows[5] = Row("Stop loss", DoubleToString(r.stop, digits) +
                 "  (" + DoubleToString(r.distance_points, 0) + " pts)");
   rows[6] = Row("Risk", DoubleToString(InpRiskPercent, 2) + "%  = " +
                 DoubleToString(r.risk_money, 2) + " " + Currency());
   rows[7] = Row("Position size", DoubleToString(r.lot, VolumeDigits(VolumeStep())) + " lots");
   rows[8] = Row("Margin needed", DoubleToString(r.margin, 2) + " " + Currency());
   rows[9] = Row("Free margin", DoubleToString(r.free_after, 2) + " " + Currency() + " left");
   if(InpRewardRatio > 0.0)
     {
      rows[10] = Row("Target " + DoubleToString(InpRewardRatio, 1) + "R", DoubleToString(r.take, digits));
      rows[11] = Row("Target profit", DoubleToString(r.reward_money, 2) + " " + Currency());
     }
  }

//+------------------------------------------------------------------+
//| Pads the label so the value column lines up in a monospace font  |
//+------------------------------------------------------------------+
string Row(const string label, const string value)
  {
   string padded = label + ":";
   while(StringLen(padded) < LABEL_WIDTH)
      padded += " ";
   return(padded + value);
  }

//+------------------------------------------------------------------+
//| Selected risk base, with a fallback for credit-funded accounts   |
//| where balance reads 0 and the funds sit in equity/credit         |
//+------------------------------------------------------------------+
double RiskBaseValue()
  {
   double selected;
   if(InpRiskBase == RISK_EQUITY)
      selected = AccountInfoDouble(ACCOUNT_EQUITY);
   else
      if(InpRiskBase == RISK_FREE)
         selected = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      else
         selected = AccountInfoDouble(ACCOUNT_BALANCE);
   if(selected > 0.0)
      return(selected);
//--- some demo and prop accounts show balance 0 with the money in credit
   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > 0.0)
      return(equity);
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance > 0.0)
      return(balance);
   return(AccountInfoDouble(ACCOUNT_MARGIN_FREE));
  }

//+------------------------------------------------------------------+
double VolumeStep()
  {
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0.0)
      return(step);
   const double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   return((vmin > 0.0) ? vmin : 0.01);
  }

//+------------------------------------------------------------------+
//| Decimal places implied by the volume step                        |
//+------------------------------------------------------------------+
int VolumeDigits(const double step)
  {
   double scaled = step;
   for(int d = 0; d < 8; d++)
     {
      if(MathAbs(scaled - MathRound(scaled)) < 1e-9)
         return(d);
      scaled *= 10.0;
     }
   return(8);
  }

//+------------------------------------------------------------------+
double NormalizePrice(const double price)
  {
   return(NormalizeDouble(price, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)));
  }

//+------------------------------------------------------------------+
string Currency()
  {
   return(AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
