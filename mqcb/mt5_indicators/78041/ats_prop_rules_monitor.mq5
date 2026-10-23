//+------------------------------------------------------------------+
//|                                      ATS_Prop_Rules_Monitor.mq5  |
//|                                          Andy Trading Solutions  |
//+------------------------------------------------------------------+
//| Prop firm challenge scoreboard. One panel, five rules, and how   |
//| much room is left on each of them:                               |
//|                                                                  |
//|  1. DAILY LOSS      used share and money left today              |
//|  2. MAX LOSS        static or trailing, money left               |
//|  3. PROFIT TARGET   progress and money still needed              |
//|  4. TRADING DAYS    days with a closed trade, and days to go     |
//|  5. BEST DAY        largest day as a share of the total profit   |
//|                     (the "consistency" rule of some firms)       |
//|                                                                  |
//| Below the rules, "ONE MORE TRADE" tells you the largest lot size |
//| that still keeps a stop-out inside the room left today and in    |
//| the max-loss room, for the stop you choose.                      |
//|                                                                  |
//| It only READS the account: it never opens, changes or closes a   |
//| trade. It is a scoreboard, not a guard.                          |
//|                                                                  |
//| The presets hold typical industry values. Firms change their     |
//| rules, so ALWAYS check the rules of your own challenge and use   |
//| the Custom preset to enter them.                                 |
//|                                                                  |
//| Built on the ATS Risk Library (ATS_RiskLib.mqh, same folder).    |
//+------------------------------------------------------------------+
#property copyright   "Andy Trading Solutions"
#property link        "https://www.mql5.com/en/users/andyxi"
#property version     "1.00"
#property description "Prop firm challenge scoreboard: daily loss, max loss, profit target, trading days and best-day rule, with the room left on each. Read-only."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <Canvas\Canvas.mqh>
#include "ATS_RiskLib.mqh"

enum ENUM_PRM_PRESET
  {
   PRM_CUSTOM  = 0, // Custom (use the values below)
   PRM_2STEP_1 = 1, // 2-step, phase 1: target 10%, daily 5%, max 10%
   PRM_2STEP_2 = 2, // 2-step, phase 2: target 5%, daily 5%, max 10%
   PRM_1STEP   = 3, // 1-step style: target 10%, daily 3%, trailing 6%, best day 50%
   PRM_FUNDED  = 4  // Funded: no target, daily 5%, max 10%
  };

//--- inputs: rules
input ENUM_PRM_PRESET   InpPreset        = PRM_2STEP_1;   // Rules preset
input double            InpInitialBal    = 0.0;           // Initial balance (0 = detect from the deposit)
input datetime          InpStart         = D'2026.01.01 00:00'; // Challenge start date (server time)
input double            InpTargetPct     = 10.0;          // Custom: profit target, % of initial balance (0 = none)
input double            InpDailyPct      = 5.0;           // Custom: daily loss limit, % of day-start balance (0 = none)
input double            InpMaxPct        = 10.0;          // Custom: maximum loss, % (0 = none)
input ENUM_ATS_DD_MODE  InpMaxMode       = ATS_DD_STATIC; // Custom: maximum loss type
input int               InpMinDays       = 4;             // Custom: minimum trading days (0 = none)
input double            InpBestDayPct    = 0.0;           // Custom: best day must stay below this % of the total profit (0 = off)
input int               InpDayStartHour  = 0;             // Server hour at which a new trading day starts
input bool              InpFloating      = true;          // Count open profit/loss in the daily limit
//--- inputs: example and look
input int               InpStopPoints    = 300;           // "One more trade": stop distance in points
input double            InpRoomShare     = 50.0;          // "One more trade": use this % of the room left
input double            InpWarn          = 70.0;          // Warning when this % of a loss limit is used
input int               InpX             = 12;            // Panel position X (pixels)
input int               InpY             = 28;            // Panel position Y (pixels)

#define PRM_PREFIX "ATSPRM_"

CCanvas            g_cv;
CAtsDayGuard       g_day;
CAtsDrawdownGuard  g_dd;

//--- active rules (preset or custom)
double  g_target, g_daily, g_max, g_bestDay;
int     g_minDays;
ENUM_ATS_DD_MODE g_maxMode;
string  g_presetName;

//--- measurements
double  g_initial     = 0.0;
double  g_closedTotal = 0.0;     // net result of all closed trades since the start
int     g_daysTraded  = 0;
double  g_bestDayPL   = 0.0;
datetime g_lastScan   = 0;
double  g_fs          = 1.0;     // font scale correction
double  g_sc          = 1.0;     // pixel scale (DPI / 96, never below 1)
int     g_w = 0, g_h = 0;

//+------------------------------------------------------------------+
//| Colours                                                          |
//+------------------------------------------------------------------+
#define C_BG       C'244,248,253'
#define C_CARD     C'255,255,255'
#define C_HEAD     C'22,64,122'
#define C_INK      C'33,43,64'
#define C_MUTED    C'112,124,146'
#define C_TRACK    C'226,232,242'
#define C_GREEN    C'46,173,107'
#define C_AMBER    C'242,169,0'
#define C_RED      C'229,72,77'
#define C_BLUE     C'46,125,222'

//+------------------------------------------------------------------+
//| Applies the preset to the rule variables.                        |
//+------------------------------------------------------------------+
void ApplyPreset(void)
  {
   g_target = InpTargetPct; g_daily = InpDailyPct; g_max = InpMaxPct;
   g_maxMode = InpMaxMode;  g_minDays = InpMinDays; g_bestDay = InpBestDayPct;
   g_presetName = "Custom";
   switch(InpPreset)
     {
      case PRM_2STEP_1: g_target = 10; g_daily = 5; g_max = 10; g_maxMode = ATS_DD_STATIC;       g_minDays = 4; g_bestDay = 0;  g_presetName = "2-step phase 1"; break;
      case PRM_2STEP_2: g_target = 5;  g_daily = 5; g_max = 10; g_maxMode = ATS_DD_STATIC;       g_minDays = 4; g_bestDay = 0;  g_presetName = "2-step phase 2"; break;
      case PRM_1STEP:   g_target = 10; g_daily = 3; g_max = 6;  g_maxMode = ATS_DD_TRAIL_EQUITY; g_minDays = 3; g_bestDay = 50; g_presetName = "1-step style";   break;
      case PRM_FUNDED:  g_target = 0;  g_daily = 5; g_max = 10; g_maxMode = ATS_DD_STATIC;       g_minDays = 0; g_bestDay = 0;  g_presetName = "funded";         break;
      default: break;
     }
  }

//+------------------------------------------------------------------+
//| Reads the closed deals since the challenge start.                |
//+------------------------------------------------------------------+
void ScanChallenge(void)
  {
   g_closedTotal = 0.0;
   g_daysTraded  = 0;
   g_bestDayPL   = 0.0;
   double deposits = 0.0;
   if(!HistorySelect(InpStart, TimeCurrent() + 60))
      return;

   int total = HistoryDealsTotal();
   datetime days[];  double dayPL[];  bool dayClosed[];
   ArrayResize(days, 0);
   for(int i = 0; i < total; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal, DEAL_TYPE);
      double res = HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_SWAP)
                 + HistoryDealGetDouble(deal, DEAL_COMMISSION) + HistoryDealGetDouble(deal, DEAL_FEE);
      if(type == DEAL_TYPE_BALANCE)
        {
         deposits += HistoryDealGetDouble(deal, DEAL_PROFIT);
         continue;
        }
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      g_closedTotal += res;
      datetime d = AtsDayStart((datetime)HistoryDealGetInteger(deal, DEAL_TIME), InpDayStartHour);
      int idx = -1;
      for(int k = ArraySize(days) - 1; k >= 0; k--)
         if(days[k] == d) { idx = k; break; }
      if(idx < 0)
        {
         idx = ArraySize(days);
         ArrayResize(days, idx + 1);
         ArrayResize(dayPL, idx + 1);
         ArrayResize(dayClosed, idx + 1);
         days[idx] = d; dayPL[idx] = 0.0; dayClosed[idx] = false;
        }
      dayPL[idx] += res;
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY);
      if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT)
         dayClosed[idx] = true;
     }
   for(int k = 0; k < ArraySize(days); k++)
     {
      if(dayClosed[k])
         g_daysTraded++;
      if(dayPL[k] > g_bestDayPL)
         g_bestDayPL = dayPL[k];
     }
   if(InpInitialBal > 0.0)
      g_initial = InpInitialBal;
   else if(deposits > 0.0)
      g_initial = deposits;
   else
      g_initial = AccountInfoDouble(ACCOUNT_BALANCE) - g_closedTotal;
  }

//+------------------------------------------------------------------+
//| Text helpers                                                     |
//+------------------------------------------------------------------+
string Money(const double v)
  {
   return AtsMoneyText(v);
  }

color LevelColor(const ENUM_ATS_LEVEL level)
  {
   if(level == ATS_LEVEL_LOCKED) return C_RED;
   if(level == ATS_LEVEL_WARN)   return C_AMBER;
   return C_GREEN;
  }

//+------------------------------------------------------------------+
//| Canvas drawing helpers (all sizes are design pixels x g_sc)      |
//+------------------------------------------------------------------+
int S(const double v) { return (int)MathRound(v * g_sc); }

void Box(const int x1, const int y1, const int x2, const int y2, const color c)
  {
   g_cv.FillRectangle(S(x1), S(y1), S(x2) - 1, S(y2) - 1, ColorToARGB(c, 255));
  }

void Text(const int x, const int y, const string s, const color c, const int px, const bool bold = false, const uint align = TA_LEFT | TA_TOP)
  {
   g_cv.FontSet("Segoe UI", (int)MathRound(S(px) * g_fs), bold ? FW_BOLD : FW_NORMAL);
   g_cv.TextOut(S(x), S(y), s, ColorToARGB(c, 255), align);
  }

//--- Horizontal gauge: track, filled part, optional tick (fraction 0..1).
void Gauge(const int x, const int y, const int w, const int h, const double fill, const color c, const double tick = -1.0)
  {
   Box(x, y, x + w, y + h, C_TRACK);
   int fw = (int)MathRound(w * MathMax(0.0, MathMin(1.0, fill)));
   if(fw > 0)
      Box(x, y, x + fw, y + h, c);
   if(tick >= 0.0 && tick <= 1.0)
      Box(x + (int)MathRound(w * tick) - 1, y - 3, x + (int)MathRound(w * tick) + 1, y + h + 3, C_INK);
  }

//--- One rule row. Returns the y of the next row.
int Row(const int y, const string title, const string valueRight, const string subLeft,
        const string subRight, const double fill, const color c, const double tick = -1.0)
  {
   const int X = 16, W = 348;
   Box(X - 6, y, X + W + 6, y + 60, C_CARD);
   Box(X - 6, y, X - 2, y + 60, c);                       // level stripe
   Text(X + 4, y + 6,  title, C_INK, 12, true);
   Text(X + W, y + 6,  valueRight, c == C_BLUE ? C_INK : c, 12, true, TA_RIGHT | TA_TOP);
   Gauge(X + 4, y + 28, W - 4, 9, fill, c, tick);
   Text(X + 4, y + 41, subLeft, C_MUTED, 11);
   Text(X + W, y + 41, subRight, C_MUTED, 11, false, TA_RIGHT | TA_TOP);
   return y + 66;
  }

//+------------------------------------------------------------------+
//| Draws the whole panel.                                           |
//+------------------------------------------------------------------+
void DrawPanel(void)
  {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   g_cv.Erase(ColorToARGB(C_BG, 255));

   //--- evaluate the rules
   ENUM_ATS_LEVEL lvDay = g_day.Level(), lvDd = (g_max > 0.0) ? g_dd.Level() : ATS_LEVEL_OK;
   double targetMoney = g_initial * g_target / 100.0;
   double profit      = bal - g_initial;
   bool   targetOk    = (g_target <= 0.0) || (profit >= targetMoney - 1e-9);
   bool   daysOk      = (g_minDays <= 0) || (g_daysTraded >= g_minDays);
   double bestShare   = (profit > 0.0) ? g_bestDayPL / profit * 100.0 : 0.0;
   bool   bestBreach  = (g_bestDay > 0.0 && profit > 0.0 && bestShare > g_bestDay);
   bool   bestWarn    = (g_bestDay > 0.0 && profit > 0.0 && bestShare > g_bestDay * 0.8);

   bool breach = (lvDay == ATS_LEVEL_LOCKED) || (lvDd == ATS_LEVEL_LOCKED);
   bool warn   = (lvDay == ATS_LEVEL_WARN) || (lvDd == ATS_LEVEL_WARN) || bestWarn;
   string badge = breach ? "LIMIT BREACHED" : (targetOk && daysOk && g_target > 0.0 && !bestBreach ? "TARGET MET" : (warn ? "WARNING" : "ALL CLEAR"));
   color  badgeC = breach ? C_RED : (warn ? C_AMBER : C_GREEN);

   //--- header + service line
   Box(0, 0, 380, 58, C_HEAD);
   Text(16, 8, "ATS PROP RULES MONITOR", C'255,255,255', 15, true);
   Text(16, 33, "v" + ATSRL_VERSION + "  |  " + g_presetName + "  |  " + cur + "  |  balance " + Money(bal), C'176,196,228', 11);
   Box(266, 10, 366, 30, badgeC);
   Text(316, 12, badge, C'255,255,255', 11, true, TA_CENTER | TA_TOP);

   int y = 66;
   //--- 1 daily loss
   if(g_daily > 0.0)
     {
      double used = g_day.Used();
      y = Row(y, "DAILY LOSS", StringFormat("%.0f%% used", used * 100.0),
              "limit " + Money(g_day.LossLimit()) + "  (" + DoubleToString(g_daily, 1) + "%)",
              "room " + Money(g_day.Remaining()), used, LevelColor(lvDay));
     }
   else
      y = Row(y, "DAILY LOSS", "off", "no daily limit set", "", 0.0, C_BLUE);

   //--- 2 max loss
   if(g_max > 0.0)
     {
      string kind = (g_maxMode == ATS_DD_STATIC) ? "static" : (g_maxMode == ATS_DD_TRAIL_EQUITY ? "trailing equity" : "trailing balance");
      y = Row(y, "MAX LOSS", StringFormat("%.0f%% used", g_dd.Used() * 100.0),
              DoubleToString(g_max, 1) + "% " + kind + ", floor " + Money(g_dd.Floor()),
              "room " + Money(g_dd.Remaining()), g_dd.Used(), LevelColor(lvDd));
     }
   else
      y = Row(y, "MAX LOSS", "off", "no maximum loss set", "", 0.0, C_BLUE);

   //--- 3 profit target
   if(g_target > 0.0)
     {
      double prog = (targetMoney > 0.0) ? MathMax(0.0, profit) / targetMoney : 0.0;
      y = Row(y, "PROFIT TARGET", StringFormat("%.0f%%", MathMin(prog, 9.99) * 100.0),
              "target " + Money(targetMoney) + "  (" + DoubleToString(g_target, 1) + "%)",
              targetOk ? "reached" : "needs " + Money(targetMoney - profit), prog, targetOk ? C_GREEN : C_BLUE);
     }
   else
      y = Row(y, "PROFIT TARGET", "none", "no profit target set", "", 0.0, C_BLUE);

   //--- 4 trading days
   if(g_minDays > 0)
     {
      y = Row(y, "TRADING DAYS", StringFormat("%d of %d", g_daysTraded, g_minDays),
              "days with a closed trade", daysOk ? "done" : IntegerToString(g_minDays - g_daysTraded) + " to go",
              (double)g_daysTraded / g_minDays, daysOk ? C_GREEN : C_BLUE);
     }
   else
      y = Row(y, "TRADING DAYS", "none", "no minimum days set", "", 0.0, C_BLUE);

   //--- 5 best day
   if(g_bestDay > 0.0)
     {
      color c = bestBreach ? C_RED : (bestWarn ? C_AMBER : C_GREEN);
      string val = (profit > 0.0) ? StringFormat("%.0f%%", bestShare) : "n/a";
      y = Row(y, "BEST DAY", val, "best day " + Money(g_bestDayPL) + ", limit " + DoubleToString(g_bestDay, 0) + "% of profit",
              profit > 0.0 ? (bestBreach ? "over the limit" : "inside") : "no profit yet",
              (profit > 0.0) ? bestShare / 100.0 : 0.0, (profit > 0.0) ? c : C_BLUE, g_bestDay / 100.0);
     }
   else
      y = Row(y, "BEST DAY", "off", "no best-day rule set", "", 0.0, C_BLUE);

   //--- one more trade
   double room = 1e18;
   if(g_daily > 0.0)
      room = MathMin(room, g_day.Remaining());
   if(g_max > 0.0)
      room = MathMin(room, g_dd.Remaining());
   Box(10, y, 370, y + 74, C_CARD);
   Box(10, y, 14, y + 74, C_BLUE);
   Text(20, y + 6, "ONE MORE TRADE", C_INK, 12, true);
   Text(364, y + 6, _Symbol + ", stop " + IntegerToString(InpStopPoints) + " pts", C_MUTED, 11, false, TA_RIGHT | TA_TOP);
   string line1, line2;
   if(room >= 1e17)
     {
      line1 = "no loss limit is set";
      line2 = "";
     }
   else
     {
      double allowed = room * InpRoomShare / 100.0;
      double dist    = InpStopPoints * _Point;
      double lots    = 0.0;
      ENUM_ATS_SKIP r = ATS_SKIP_BAD_INPUT;
      if(allowed > 0.0)
         r = AtsLotsFromRisk(allowed, AtsLossPerLot(_Symbol, dist), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
                             SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), 0.0, lots);
      if(r == ATS_OK)
        {
         line1 = StringFormat("max %.2f lots", lots);
         line2 = "a stop-out costs " + Money(lots * AtsLossPerLot(_Symbol, dist)) + ", you keep " + DoubleToString(100.0 - InpRoomShare, 0) + "% of the room";
        }
      else
        {
         line1 = "no room for this stop";
         line2 = (allowed <= 0.0) ? "the limit is already reached" : "the minimum lot would risk more than " + Money(allowed);
        }
     }
   Text(20, y + 28, line1, room >= 1e17 ? C_MUTED : C_INK, 15, true);
   Text(20, y + 52, line2, C_MUTED, 11);
   g_cv.Update(true);
  }

//+------------------------------------------------------------------+
//| Indicator start                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ApplyPreset();

   // DPI scale and font correction (see the notes in the description)
   int dpi = (int)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   g_sc = MathMax(1.0, dpi / 96.0);
   CCanvas probe;
   g_fs = 1.0;
   if(probe.CreateBitmapLabel("ATSPRM_probe", 0, 0, 40, 40, COLOR_FORMAT_ARGB_NORMALIZE))
     {
      probe.FontSet("Segoe UI", 100);
      int tw = 0, th = 0;
      probe.TextSize("Hg", tw, th);
      if(th > 0)
         g_fs = 133.0 / th;
      probe.Destroy();
     }

   g_w = S(380);
   g_h = S(66 + 66 * 5 + 82);
   if(!g_cv.CreateBitmapLabel(0, 0, PRM_PREFIX + "panel", S(InpX), S(InpY), g_w, g_h, COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("ATS_Prop_Rules_Monitor: cannot create the panel, error ", GetLastError());
      return INIT_FAILED;
     }
   ObjectSetInteger(0, PRM_PREFIX + "panel", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, PRM_PREFIX + "panel", OBJPROP_BACK, false);

   double warn = MathMax(10.0, MathMin(99.0, InpWarn)) / 100.0;
   g_day.Init("prm" + IntegerToString((int)MathAbs((long)InpPreset)), "", -1, InpFloating, InpDayStartHour,
              g_daily, 0.0, 0.0, 0, warn);
   ScanChallenge();
   if(g_max > 0.0)
      g_dd.Init("prm" + IntegerToString((int)InpPreset), g_maxMode, g_max, g_initial, true, warn);
   g_lastScan = TimeCurrent();
   EventSetTimer(1);
   DrawPanel();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(reason == REASON_REMOVE)       // removed by the user: do not leave saved limits behind
     {
      g_day.Forget();
      if(g_max > 0.0)
         g_dd.Forget();
     }
   g_cv.Destroy();
   ObjectsDeleteAll(0, PRM_PREFIX);
  }

//+------------------------------------------------------------------+
//| Once a second: update the measurements and redraw.               |
//+------------------------------------------------------------------+
void OnTimer()
  {
   g_day.Update();
   if(g_max > 0.0)
      g_dd.Update();
   if(TimeCurrent() - g_lastScan >= 5)
     {
      ScanChallenge();
      g_lastScan = TimeCurrent();
     }
   DrawPanel();
  }

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   return rates_total;
  }
//+------------------------------------------------------------------+
