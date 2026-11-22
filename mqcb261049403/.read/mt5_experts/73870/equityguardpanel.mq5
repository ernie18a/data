//+------------------------------------------------------------------+
//|                                             EquityGuardPanel.mq5 |
//|                                Equity Guard - Panic Panel  v1.20 |
//|                                                                  |
//|   Daily loss-limit guardian with a modern draggable canvas panel |
//|  and manual panic buttons. Works on any broker, any account      |
//|  size, any account currency. No DLLs required.                   |
//|                                                                  |
//|  - Captures a reference value (balance or equity) every day      |
//|    at a configurable reset time (server time)                    |
//|  - Daily loss limit configurable in percent or money             |
//|  - When the lock trigger is hit: closes all positions and        |
//|    pending orders, then (optionally) keeps the account flat      |
//|    until the next daily reset                                    |
//|  - Manual CLOSE ALL and LOCK/UNLOCK buttons with click-to-       |
//|    confirm protection against accidental clicks                  |
//|  - Drag the panel by its header; position is remembered          |
//|  - State persists across terminal restarts (GlobalVariables)     |
//+------------------------------------------------------------------+
#property copyright   "KairosLab"
#property link        "https://forge.mql5.io"
#property version     "1.20"
#property description "Daily loss-limit guardian with a modern visual panel and panic buttons."
#property description "Captures balance/equity at a configurable daily reset time, monitors"
#property description "equity in real time and flattens the account when your loss trigger"
#property description "is hit. Optional flat-enforcement until next reset. No DLLs."

#include <Canvas\Canvas.mqh>

//--- enums for inputs
enum ENUM_LIMIT_MODE
  {
   LIMIT_PERCENT = 0,   // Percent of day-start value
   LIMIT_MONEY   = 1    // Fixed amount (account currency)
  };

enum ENUM_BASE_MODE
  {
   BASE_BALANCE = 0,    // Balance at reset time
   BASE_EQUITY  = 1     // Equity at reset time
  };

//--- inputs
input group "=== Protection ==="
input ENUM_LIMIT_MODE InpLimitMode    = LIMIT_PERCENT; // Daily loss limit mode
input double          InpLimitPercent = 5.0;           // Daily loss limit (% of day-start)
input double          InpLimitMoney   = 500.0;         // Daily loss limit (money)
input double          InpTriggerPct   = 80.0;          // Lock trigger (% of daily limit)
input ENUM_BASE_MODE  InpBaseMode     = BASE_BALANCE;  // Day-start reference
input bool            InpEnforceFlat  = true;          // Keep account flat while locked

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "=== Daily reset (server time) ==="
input int             InpResetHour    = 0;             // Reset hour (0-23)
input int             InpResetMinute  = 0;             // Reset minute (0-59)

input group "=== Execution ==="
input int             InpSlippagePts  = 30;            // Max deviation (points)

input group "=== Alerts ==="
input bool            InpAlertPopup   = true;          // Pop-up alert on lock / reset
input bool            InpAlertPush    = false;         // Push notification on lock / reset
input bool            InpAlertSound   = true;          // Sound on lock

input group "=== Panel ==="
input int             InpPanelX       = 16;            // Initial X (drag panel by header)
input int             InpPanelY       = 16;            // Initial Y (drag panel by header)
input int             InpFontSize     = 11;            // Base font size

//--- object name prefix
#define PFX "EGP_"

//--- confirm window for manual buttons (seconds)
#define ARM_WINDOW 5

//--- protection state
double   g_base       = 0.0;       // day-start reference value
datetime g_baseTime   = 0;         // reset timestamp the base belongs to
bool     g_locked     = false;     // protection lock active
string   g_ccy        = "";        // account currency
string   g_gvBase     = "";        // GlobalVariable keys (per account)
string   g_gvTime     = "";
string   g_gvLock     = "";
string   g_gvPosX     = "";
string   g_gvPosY     = "";
datetime g_armClose   = 0;         // arm timestamps for click-to-confirm
datetime g_armLock    = 0;
datetime g_lastEnfLog = 0;         // throttle enforcement log messages
datetime g_lockedAt   = 0;         // when the lock was engaged
bool     g_rearmWait  = false;     // after manual unlock: wait for loss to recover

//--- UI state
CCanvas  g_canvas;
int      g_W = 380;                // panel width
int      g_H = 380;                // panel height (computed in OnInit)
int      g_px = 16, g_py = 16;     // current panel position
bool     g_minimized = false;
int      g_hover  = 0;             // 0 none, 1 close, 2 lock, 3 minimize, 4 mini-pill, 5 header
bool     g_mdown  = false;
bool     g_drag = false, g_dragPending = false;
int      g_downX = 0, g_downY = 0, g_panDownX = 0, g_panDownY = 0;

struct UiRect { int x; int y; int w; int h; };
UiRect   g_rcClose, g_rcLock, g_rcMini, g_rcPill;

//--- theme
#define CLR_BG_TOP    C'27,30,42'
#define CLR_BG_BOT    C'15,17,25'
#define CLR_CARD_TOP  C'34,38,53'
#define CLR_CARD_BOT  C'27,31,43'
#define CLR_TXT_DIM   C'126,133,160'
#define CLR_TXT_MAIN  C'235,238,248'
#define CLR_TRACK     C'55,61,82'
#define CLR_BTN       C'56,62,86'
#define CLR_GOOD      C'0,200,118'
#define CLR_WARN      C'240,186,0'
#define CLR_DANGER    C'255,118,34'
#define CLR_LOCKED    C'236,64,64'
#define CLR_LOSS      C'238,98,98'
#define CLR_BLUE      C'98,160,255'
#define ALPHA_PANEL   (uchar)245

//+------------------------------------------------------------------+
//| Most recent daily reset moment (server time)                     |
//+------------------------------------------------------------------+
datetime LastReset(datetime now)
  {
   MqlDateTime t;
   TimeToStruct(now, t);
   t.hour = InpResetHour;
   t.min  = InpResetMinute;
   t.sec  = 0;
   datetime r = StructToTime(t);
   if(r > now)
      r -= 86400;
   return r;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime NextReset(datetime now)
  {
   return LastReset(now) + 86400;
  }

//+------------------------------------------------------------------+
//| Persistence                                                      |
//+------------------------------------------------------------------+
void SaveState()
  {
   GlobalVariableSet(g_gvBase, g_base);
   GlobalVariableSet(g_gvTime, (double)g_baseTime);
   GlobalVariableSet(g_gvLock, g_locked ? 1.0 : 0.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadState()
  {
   if(GlobalVariableCheck(g_gvBase) && GlobalVariableCheck(g_gvTime))
     {
      g_base     = GlobalVariableGet(g_gvBase);
      g_baseTime = (datetime)GlobalVariableGet(g_gvTime);
     }
   if(GlobalVariableCheck(g_gvLock))
      g_locked = (GlobalVariableGet(g_gvLock) == 1.0);
  }

//+------------------------------------------------------------------+
//| Capture / refresh the day-start reference                        |
//+------------------------------------------------------------------+
void UpdateBase(datetime now)
  {
   if((long)now < 1577836800)        // no valid server time yet (terminal not connected)
      return;

   datetime lastReset = LastReset(now);
   if(g_baseTime == lastReset && g_base > 0.0)
      return;                                   // base for this period already set

   double v = (InpBaseMode == BASE_BALANCE)
              ? AccountInfoDouble(ACCOUNT_BALANCE)
              : AccountInfoDouble(ACCOUNT_EQUITY);
   if(v <= 0.0)
      return;                                   // retry on next timer event

   bool newPeriod = (g_baseTime != 0 && g_baseTime != lastReset);

   g_base     = v;
   g_baseTime = lastReset;

// new period: release the lock automatically
   if(newPeriod && g_locked)
     {
      g_locked = false;
      Notify(StringFormat("Equity Guard: new day - protection RESET. Day-start: %.2f %s",
                          g_base, g_ccy), false);
     }

   SaveState();
   PrintFormat("Equity Guard: day-start captured: %.2f %s (reset %s server time)",
               g_base, g_ccy, TimeToString(lastReset, TIME_DATE | TIME_MINUTES));
  }

//+------------------------------------------------------------------+
//| Current limit values in money                                    |
//+------------------------------------------------------------------+
double DailyLimitMoney()
  {
   if(InpLimitMode == LIMIT_MONEY)
      return InpLimitMoney;
   return g_base * InpLimitPercent / 100.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LockTriggerMoney()
  {
   return DailyLimitMoney() * InpTriggerPct / 100.0;
  }

//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void Notify(string msg, bool critical)
  {
   Print(msg);
   if(InpAlertPopup)
      Alert(msg);
   if(InpAlertPush)
      SendNotification(msg);
   if(critical && InpAlertSound)
      PlaySound("alert.wav");
  }

//+------------------------------------------------------------------+
//| Pick a filling mode supported by the symbol                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFilling(string sym)
  {
   long fm = SymbolInfoInteger(sym, SYMBOL_FILLING_MODE);
   if((fm & SYMBOL_FILLING_IOC) != 0)
      return ORDER_FILLING_IOC;
   if((fm & SYMBOL_FILLING_FOK) != 0)
      return ORDER_FILLING_FOK;
   return ORDER_FILLING_RETURN;
  }

//+------------------------------------------------------------------+
//| Close all positions and delete all pending orders               |
//+------------------------------------------------------------------+
void CloseAll(string reason, bool verbose = true)
  {
   if(verbose)
      Print("Equity Guard: closing everything - ", reason);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      string sym  = PositionGetString(POSITION_SYMBOL);
      double vol  = PositionGetDouble(POSITION_VOLUME);
      long   type = PositionGetInteger(POSITION_TYPE);

      MqlTradeRequest req = {};
      MqlTradeResult  res = {};
      req.action       = TRADE_ACTION_DEAL;
      req.position     = ticket;
      req.symbol       = sym;
      req.volume       = vol;
      req.type         = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      req.price        = (type == POSITION_TYPE_BUY)
                         ? SymbolInfoDouble(sym, SYMBOL_BID)
                         : SymbolInfoDouble(sym, SYMBOL_ASK);
      req.deviation    = InpSlippagePts;
      req.comment      = "EG_CLOSE";
      req.type_filling = GetFilling(sym);

      if(!OrderSend(req, res))
         PrintFormat("Equity Guard: ERROR closing #%I64u (%s) retcode:%d",
                     ticket, sym, res.retcode);
      else
         if(verbose)
            PrintFormat("Equity Guard: closed #%I64u %s vol:%.2f retcode:%d",
                        ticket, sym, vol, res.retcode);
     }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      // only true pending orders can be removed (skip in-flight market orders)
      ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(ot != ORDER_TYPE_BUY_LIMIT && ot != ORDER_TYPE_SELL_LIMIT &&
         ot != ORDER_TYPE_BUY_STOP  && ot != ORDER_TYPE_SELL_STOP  &&
         ot != ORDER_TYPE_BUY_STOP_LIMIT && ot != ORDER_TYPE_SELL_STOP_LIMIT)
         continue;
      MqlTradeRequest req = {};
      MqlTradeResult  res = {};
      req.action = TRADE_ACTION_REMOVE;
      req.order  = ticket;
      if(!OrderSend(req, res))
         PrintFormat("Equity Guard: ERROR deleting order #%I64u retcode:%d",
                     ticket, res.retcode);
      else
         if(verbose)
            PrintFormat("Equity Guard: pending order deleted #%I64u", ticket);
     }
  }

//+------------------------------------------------------------------+
//| Engage the protection lock                                       |
//+------------------------------------------------------------------+
void EngageLock(string reason)
  {
   g_locked    = true;
   g_lockedAt  = TimeTradeServer();
   g_rearmWait = false;
   SaveState();
   CloseAll(reason);
   string enf = InpEnforceFlat
                ? "Account will be kept FLAT until the next daily reset."
                : "Flat-enforcement is OFF: other EAs may still open trades.";
   Notify(StringFormat("EQUITY GUARD LOCKED - %s. All positions closed. %s",
                       reason, enf), true);
  }

//+------------------------------------------------------------------+
//| Release the lock (manual unlock)                                 |
//+------------------------------------------------------------------+
void ReleaseLock()
  {
   g_locked    = false;
   g_rearmWait = true;   // don't re-fire instantly while the loss is still over the trigger
   SaveState();
   Notify("Equity Guard: lock manually RELEASED. Auto-trigger re-arms once the daily loss recovers below 90% of the trigger.", false);
  }

//+------------------------------------------------------------------+
//| Automatic trigger check                                          |
//+------------------------------------------------------------------+
void CheckTrigger()
  {
   if(g_locked || g_base <= 0.0)
      return;

   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd = MathMax(0.0, g_base - eq);

   if(g_rearmWait)
     {
      if(dd < LockTriggerMoney() * 0.9)
        {
         g_rearmWait = false;
         Print("Equity Guard: auto-trigger re-armed");
        }
      return;
     }

   if(dd >= LockTriggerMoney())
      EngageLock(StringFormat("daily loss %.2f %s reached trigger %.2f %s (equity %.2f, day-start %.2f)",
                              dd, g_ccy, LockTriggerMoney(), g_ccy, eq, g_base));
  }

//+------------------------------------------------------------------+
//| Flat enforcement while locked                                    |
//+------------------------------------------------------------------+
void EnforceFlat(datetime now)
  {
   if(!g_locked)
      return;
// with enforcement OFF we still retry failed panic closes for 120 s after the lock
   if(!InpEnforceFlat && (g_lockedAt == 0 || now - g_lockedAt > 120))
      return;
   if(PositionsTotal() == 0 && OrdersTotal() == 0)
      return;

   bool verbose = (now - g_lastEnfLog >= 30);   // avoid log flooding
   if(verbose)
      g_lastEnfLog = now;
   CloseAll("flat enforcement while locked", verbose);
  }

//+------------------------------------------------------------------+
//| ----------------------- CANVAS UI LAYER ----------------------- |
//+------------------------------------------------------------------+

//--- color helpers (MQL5 color layout is 0x00BBGGRR)
uchar RedOf(color c)   { return (uchar)(c        & 0xFF); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uchar GreenOf(color c) { return (uchar)((c >> 8)  & 0xFF); }
uchar BlueOf(color c)  { return (uchar)((c >> 16) & 0xFF); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color Mix(color a, color b, double t)
  {
   if(t < 0.0)
      t = 0.0;
   if(t > 1.0)
      t = 1.0;
   uchar r = (uchar)(RedOf(a)   + (RedOf(b)   - RedOf(a))   * t);
   uchar g = (uchar)(GreenOf(a) + (GreenOf(b) - GreenOf(a)) * t);
   uchar bl= (uchar)(BlueOf(a)  + (BlueOf(b)  - BlueOf(a))  * t);
   return (color)((bl << 16) | (g << 8) | r);
  }

color Lighten(color c, double t) { return Mix(c, clrWhite, t); }

uint C2A(color c, uchar a = 255) { return ColorToARGB(c, a); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetFont(int px, bool bold = false)
  {
   g_canvas.FontSet("Segoe UI", -px * 10, bold ? FW_SEMIBOLD : FW_NORMAL);
  }

//+------------------------------------------------------------------+
//| Filled rounded rectangle (optionally with vertical gradient)     |
//+------------------------------------------------------------------+
void RRect(int x, int y, int w, int h, int r, color top, color bottom, uchar alpha)
  {
   if(r > h / 2)
      r = h / 2;
   if(r > w / 2)
      r = w / 2;
   for(int i = 0; i < h; i++)
     {
      double t = (h > 1) ? (double)i / (h - 1) : 0.0;
      uint   c = C2A(Mix(top, bottom, t), alpha);
      int inset = 0;
      if(i < r)
        {
         int d = r - i;
         inset = r - (int)MathRound(MathSqrt((double)(r * r - d * d)));
        }
      else
         if(i >= h - r)
           {
            int d = i - (h - 1 - r);
            if(d > 0)
               inset = r - (int)MathRound(MathSqrt(MathMax(0.0, (double)(r * r - d * d))));
           }
      g_canvas.FillRectangle(x + inset, y + i, x + w - 1 - inset, y + i, c);
     }
  }

//+------------------------------------------------------------------+
//| Donut gauge                                                      |
//+------------------------------------------------------------------+
void Donut(int cx, int cy, int radius, int thick, double frac, color fill)
  {
   int dot = thick / 2;
// background ring (bright enough to be visible on dark bg)
   for(double a = 0.0; a < 360.0; a += 1.5)
     {
      double rad = a * M_PI / 180.0;
      int px = cx + (int)MathRound(MathCos(rad) * radius);
      int py = cy + (int)MathRound(MathSin(rad) * radius);
      g_canvas.FillCircle(px, py, dot, C2A(CLR_TRACK));
     }
// progress arc: starts at 12 o'clock, clockwise; always visibly seeded
   if(frac < 0.0)
      frac = 0.0;
   if(frac > 1.0)
      frac = 1.0;
   double sweep = frac * 360.0;
   if(frac > 0.0 && sweep < 14.0)
      sweep = 14.0;   // minimum visible arc
   for(double a = 0.0; a <= sweep; a += 1.0)
     {
      double rad = (a - 90.0) * M_PI / 180.0;
      int px = cx + (int)MathRound(MathCos(rad) * radius);
      int py = cy + (int)MathRound(MathSin(rad) * radius);
      g_canvas.FillCircle(px, py, dot, C2A(fill));
     }
  }

//+------------------------------------------------------------------+
//| Money formatting                                                 |
//+------------------------------------------------------------------+
string Money(double v)
  {
   return StringFormat("%.2f %s", v, g_ccy);
  }

//+------------------------------------------------------------------+
//| Hit test helpers                                                 |
//+------------------------------------------------------------------+
bool InRect(int mx, int my, UiRect &rc)
  {
   return (mx >= rc.x && mx <= rc.x + rc.w && my >= rc.y && my <= rc.y + rc.h);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HitTest(int mx, int my)
  {
   mx -= g_px;
   my -= g_py;
   if(g_minimized)
     {
      if(InRect(mx, my, g_rcPill))
         return 4;
      return 0;
     }
   if(InRect(mx, my, g_rcClose))
      return 1;
   if(InRect(mx, my, g_rcLock))
      return 2;
   if(InRect(mx, my, g_rcMini))
      return 3;
   if(mx >= 0 && mx < g_W && my >= 0 && my < 46)
      return 5;   // header drag zone
   return 0;
  }

//+------------------------------------------------------------------+
//| Move the panel (drag)                                            |
//+------------------------------------------------------------------+
void MovePanel(int nx, int ny)
  {
   int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   if(nx < 0)
      nx = 0;
   if(ny < 0)
      ny = 0;
   if(cw > 80 && nx > cw - 80)
      nx = cw - 80;
   if(ch > 40 && ny > ch - 40)
      ny = ch - 40;
   g_px = nx;
   g_py = ny;
   ObjectSetInteger(0, PFX + "CANVAS", OBJPROP_XDISTANCE, g_px);
   ObjectSetInteger(0, PFX + "CANVAS", OBJPROP_YDISTANCE, g_py);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EndDrag()
  {
   if(g_drag)
     {
      GlobalVariableSet(g_gvPosX, g_px);
      GlobalVariableSet(g_gvPosY, g_py);
     }
   if(g_drag || g_dragPending)
      ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   g_drag        = false;
   g_dragPending = false;
  }

//+------------------------------------------------------------------+
//| Draw a canvas button                                             |
//+------------------------------------------------------------------+
void DrawButton(UiRect &rc, string txt, color bg, bool hovered, int fontPx)
  {
   color c = hovered ? Lighten(bg, 0.13) : bg;
   RRect(rc.x, rc.y, rc.w, rc.h, 8, Lighten(c, 0.07), c, 255);
   SetFont(fontPx, true);
   g_canvas.TextOut(rc.x + rc.w / 2, rc.y + rc.h / 2, txt, C2A(clrWhite), TA_CENTER | TA_VCENTER);
  }

//+------------------------------------------------------------------+
//| Draw the panel                                                   |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   datetime now    = TimeTradeServer();
   double   equity = AccountInfoDouble(ACCOUNT_EQUITY);
   bool     hasBase = (g_base > 0.0);

   double dayPL   = hasBase ? (equity - g_base) : 0.0;
   double dd      = MathMax(0.0, -dayPL);
   double limit   = hasBase ? DailyLimitMoney()  : 0.0;
   double trig    = hasBase ? LockTriggerMoney() : 0.0;
   double usedPct = (hasBase && limit > 0.0) ? (dd / limit * 100.0) : 0.0;
   double room    = hasBase ? MathMax(0.0, trig - dd) : 0.0;

   datetime nxt = NextReset(now);
   int secs = (int)(nxt - now);
   if(secs < 0)
      secs = 0;
   int hh = secs / 3600, mm = (secs % 3600) / 60, ss = secs % 60;

// status & accent color
   string status;
   color  accent;
   if(g_locked)
     {
      status = "LOCKED";
      accent = CLR_LOCKED;
     }
   else
      if(usedPct < 50.0)
        {
         status = "ACTIVE";
         accent = CLR_GOOD;
        }
      else
         if(usedPct < 75.0)
           {
            status = "CAUTION";
            accent = CLR_WARN;
           }
         else
           {
            status = "DANGER";
            accent = CLR_DANGER;
           }

// expire confirm-arm windows
   if(g_armClose > 0 && now - g_armClose > ARM_WINDOW)
      g_armClose = 0;
   if(g_armLock  > 0 && now - g_armLock  > ARM_WINDOW)
      g_armLock  = 0;

   int fs  = InpFontSize;
   int pad = 16;
   int cardX = 12, cardW = g_W - 24, inner = 14;
   int lh = fs + 10;

   g_canvas.Erase(0);   // fully transparent

//================ MINIMIZED PILL ================
   if(g_minimized)
     {
      int pw = 252, ph = 36;
      g_rcPill.x = 0;
      g_rcPill.y = 0;
      g_rcPill.w = pw;
      g_rcPill.h = ph;
      RRect(4, 5, pw, ph, ph / 2, C'0,0,0', C'0,0,0', 70);              // shadow
      RRect(0, 0, pw, ph, ph / 2, CLR_BG_TOP, CLR_BG_BOT, ALPHA_PANEL);
      g_canvas.FillCircle(20, ph / 2, 5, C2A(accent));
      SetFont(fs + 1, true);
      g_canvas.TextOut(34, ph / 2, "EQUITY GUARD", C2A(CLR_TXT_MAIN), TA_LEFT | TA_VCENTER);
      SetFont(fs, true);
      string mtxt = hasBase ? StringFormat("%.0f%%", usedPct) : "--";
      if(g_hover == 4)
         mtxt = "open";
      g_canvas.TextOut(pw - 18, ph / 2, mtxt, C2A(accent), TA_RIGHT | TA_VCENTER);
      g_canvas.Update();
      return;
     }

//================ FULL PANEL ================
   RRect(6, 8, g_W, g_H, 14, C'0,0,0', C'0,0,0', 70);                  // drop shadow
   RRect(0, 0, g_W, g_H, 12, CLR_BG_TOP, CLR_BG_BOT, ALPHA_PANEL);     // body
   RRect(0, 0, g_W, 5, 2, accent, accent, 255);                        // accent edge

//--- header (drag zone)
   int cy = 17;
   g_canvas.FillCircle(pad + 6, cy + 9, 8, C2A(accent, 60));           // halo
   g_canvas.FillCircle(pad + 6, cy + 9, 4, C2A(accent));               // status dot
   SetFont(fs + 3, true);
   g_canvas.TextOut(pad + 22, cy, "EQUITY GUARD", C2A(CLR_TXT_MAIN), TA_LEFT | TA_TOP);

// minimize chip
   g_rcMini.x = g_W - pad - 22;
   g_rcMini.y = cy - 2;
   g_rcMini.w = 22;
   g_rcMini.h = 22;
   RRect(g_rcMini.x, g_rcMini.y, g_rcMini.w, g_rcMini.h, 6,
         g_hover == 3 ? Lighten(CLR_BTN, 0.15) : CLR_BTN,
         g_hover == 3 ? Lighten(CLR_BTN, 0.15) : CLR_BTN, 255);
   SetFont(fs + 1, true);
   g_canvas.TextOut(g_rcMini.x + g_rcMini.w / 2, g_rcMini.y + g_rcMini.h / 2 - 1, "-",
                    C2A(CLR_TXT_MAIN), TA_CENTER | TA_VCENTER);

// status pill
   SetFont(fs - 2, true);
   int pillW = 76, pillH = 20;
   int pillX = g_rcMini.x - 10 - pillW;
   RRect(pillX, cy - 1, pillW, pillH, pillH / 2, accent, accent, 255);
   g_canvas.TextOut(pillX + pillW / 2, cy - 1 + pillH / 2, status, C2A(C'10,12,16'), TA_CENTER | TA_VCENTER);

//--- CARD 1: gauge + equity block
   int c1y = 48, c1h = 112;
   RRect(cardX, c1y, cardW, c1h, 10, CLR_CARD_TOP, CLR_CARD_BOT, 255);

   int gcx = cardX + 58, gcy = c1y + c1h / 2, rad = 40, thick = 13;
   Donut(gcx, gcy, rad, thick, hasBase ? usedPct / 100.0 : 0.0, accent);
   SetFont(fs + 7, true);
   g_canvas.TextOut(gcx, gcy - 4, hasBase ? StringFormat("%.0f%%", usedPct) : "--",
                    C2A(CLR_TXT_MAIN), TA_CENTER | TA_VCENTER);
   SetFont(fs - 3, false);
   g_canvas.TextOut(gcx, gcy + 15, "of limit", C2A(CLR_TXT_DIM), TA_CENTER | TA_VCENTER);

   int rx = cardX + 124;
   SetFont(fs - 2, false);
   g_canvas.TextOut(rx, c1y + 12, "EQUITY NOW", C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   SetFont(fs + 5, true);
   g_canvas.TextOut(rx, c1y + 26, Money(equity), C2A(CLR_TXT_MAIN), TA_LEFT | TA_TOP);

   SetFont(fs - 2, false);
   g_canvas.TextOut(rx, c1y + 54, "DAY P/L", C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   SetFont(fs + 2, true);
   color plClr = (dayPL >= 0.0) ? CLR_GOOD : CLR_LOSS;
   string plTxt = hasBase
                  ? StringFormat("%s%s  (%s%.2f%%)",
                                 (dayPL >= 0 ? "+" : ""), Money(dayPL),
                                 (dayPL >= 0 ? "+" : ""), (g_base > 0 ? dayPL / g_base * 100.0 : 0.0))
                  : "-";
   g_canvas.TextOut(rx, c1y + 68, plTxt, C2A(hasBase ? plClr : CLR_TXT_DIM), TA_LEFT | TA_TOP);

   SetFont(fs - 2, false);
   string baseLbl = (InpBaseMode == BASE_BALANCE) ? "day start (balance)  " : "day start (equity)  ";
   g_canvas.TextOut(rx, c1y + 92, baseLbl + (hasBase ? Money(g_base) : "capturing..."),
                    C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);

//--- CARD 2: limits + progress bar
   int c2y = c1y + c1h + 10;
   int c2h = inner + 3 * lh + 10 + 12 + inner;
   RRect(cardX, c2y, cardW, c2h, 10, CLR_CARD_TOP, CLR_CARD_BOT, 255);

   int rowX  = cardX + inner;
   int rowXR = cardX + cardW - inner;
   cy = c2y + inner - 2;

   SetFont(fs, false);
   g_canvas.TextOut(rowX, cy, "Daily loss limit", C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   string limTxt = !hasBase ? "-" :
                   (InpLimitMode == LIMIT_PERCENT
                    ? StringFormat("%s  (%.1f%%)", Money(limit), InpLimitPercent)
                    : Money(limit));
   g_canvas.TextOut(rowXR, cy, limTxt, C2A(CLR_LOSS), TA_RIGHT | TA_TOP);
   cy += lh;

   g_canvas.TextOut(rowX, cy, "Lock trigger", C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   g_canvas.TextOut(rowXR, cy,
                    hasBase ? StringFormat("%s  (%.0f%% of limit)", Money(trig), InpTriggerPct) : "-",
                    C2A(CLR_WARN), TA_RIGHT | TA_TOP);
   cy += lh;

   color roomClr = (room < trig * 0.20) ? CLR_LOCKED
                   : (room < trig * 0.50) ? CLR_WARN : CLR_GOOD;
   g_canvas.TextOut(rowX, cy, "Room before lock", C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   SetFont(fs, true);
   g_canvas.TextOut(rowXR, cy, hasBase ? Money(room) : "-",
                    C2A(hasBase ? roomClr : CLR_TXT_DIM), TA_RIGHT | TA_TOP);
   cy += lh + 10;

// progress bar
   int bx = rowX, bw = cardW - inner * 2, bh = 12;
   RRect(bx, cy, bw, bh, bh / 2, CLR_TRACK, CLR_TRACK, 255);
   if(hasBase && limit > 0.0)
     {
      int fillW = (int)MathMin(usedPct / 100.0 * bw, (double)bw);
      if(fillW < bh && dd > 0.0)
         fillW = bh;
      if(fillW > 0)
        {
         for(int i = 0; i < fillW; i++)
           {
            double t = (double)i / MathMax(1, bw - 1);
            color  c = Mix(CLR_GOOD, (t > 0.75 ? CLR_LOCKED : (t > 0.5 ? CLR_DANGER : CLR_WARN)), t);
            int inset = 0;
            int r2 = bh / 2;
            if(i < r2)
               inset = r2 - (int)MathRound(MathSqrt(MathMax(0.0, (double)(r2 * r2 - (r2 - i) * (r2 - i)))));
            if(i > fillW - 1 - r2)
              {
               int d = i - (fillW - 1 - r2);
               inset = r2 - (int)MathRound(MathSqrt(MathMax(0.0, (double)(r2 * r2 - d * d))));
              }
            g_canvas.FillRectangle(bx + i, cy + inset, bx + i, cy + bh - 1 - inset, C2A(c));
           }
        }
      // trigger marker
      int mX = bx + (int)(MathMin(InpTriggerPct, 100.0) / 100.0 * bw);
      g_canvas.FillTriangle(mX - 5, cy - 8, mX + 5, cy - 8, mX, cy - 2, C2A(C'255,215,0'));
     }

//--- reset row
   cy = c2y + c2h + 10;
   SetFont(fs - 1, false);
   g_canvas.TextOut(pad, cy, StringFormat("Next reset %02d:%02d server", InpResetHour, InpResetMinute),
                    C2A(CLR_TXT_DIM), TA_LEFT | TA_TOP);
   SetFont(fs - 1, true);
   g_canvas.TextOut(g_W - pad, cy, StringFormat("in %02d:%02d:%02d", hh, mm, ss),
                    C2A(CLR_BLUE), TA_RIGHT | TA_TOP);
   cy += lh + 4;

//--- buttons
   int btnH = 36;
   int btnW = (g_W - pad * 2 - 10) / 2;
   g_rcClose.x = pad;
   g_rcClose.y = cy;
   g_rcClose.w = btnW;
   g_rcClose.h = btnH;
   g_rcLock.x  = pad + btnW + 10;
   g_rcLock.y  = cy;
   g_rcLock.w  = btnW;
   g_rcLock.h  = btnH;

   string tClose = (g_armClose > 0) ? "CONFIRM ?" : "CLOSE ALL";
   color  cClose = (g_armClose > 0) ? CLR_LOCKED : CLR_BTN;
   DrawButton(g_rcClose, tClose, cClose, g_hover == 1, fs);

   string tLock;
   color  cLock;
   if(g_locked)
     {
      tLock = (g_armLock > 0) ? "CONFIRM ?" : "UNLOCK";
      cLock = (g_armLock > 0) ? CLR_WARN : CLR_BTN;
     }
   else
     {
      tLock = (g_armLock > 0) ? "CONFIRM ?" : "LOCK NOW";
      cLock = (g_armLock > 0) ? CLR_LOCKED : CLR_BTN;
     }
   DrawButton(g_rcLock, tLock, cLock, g_hover == 2, fs);
   cy += btnH + 9;

//--- footer
   SetFont(fs - 3, false);
   g_canvas.TextOut(pad, cy, "Equity Guard 1.2 - drag header to move", C2A(C'80,86,110'), TA_LEFT | TA_TOP);

   g_canvas.Update();
  }

//+------------------------------------------------------------------+
//| Handle a click on a UI element                                   |
//+------------------------------------------------------------------+
void HandleClick(int element)
  {
   datetime now = TimeTradeServer();

   switch(element)
     {
      case 1:  // CLOSE ALL
         if(g_armClose == 0)
            g_armClose = now;                    // first click: arm
         else
           {
            g_armClose = 0;                      // second click: fire
            CloseAll("manual CLOSE ALL button");
            Notify("Equity Guard: manual CLOSE ALL executed.", false);
           }
         break;

      case 2:  // LOCK / UNLOCK
         if(g_armLock == 0)
            g_armLock = now;                     // first click: arm
         else
           {
            g_armLock = 0;                       // second click: fire
            if(g_locked)
               ReleaseLock();
            else
               EngageLock("manual LOCK button");
           }
         break;

      case 3:  // minimize
         g_minimized = true;
         g_hover = 0;
         break;

      case 4:  // restore
         g_minimized = false;
         g_hover = 0;
         break;
     }
  }

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpResetHour < 0 || InpResetHour > 23 || InpResetMinute < 0 || InpResetMinute > 59)
     {
      Print("Equity Guard: invalid reset time");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpTriggerPct <= 0.0 || InpTriggerPct > 100.0)
     {
      Print("Equity Guard: lock trigger must be between 1 and 100 (% of daily limit)");
      return INIT_PARAMETERS_INCORRECT;
     }
   if((InpLimitMode == LIMIT_PERCENT && InpLimitPercent <= 0.0) ||
      (InpLimitMode == LIMIT_MONEY   && InpLimitMoney   <= 0.0))
     {
      Print("Equity Guard: daily loss limit must be greater than zero");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_ccy = AccountInfoString(ACCOUNT_CURRENCY);

   string acc = IntegerToString((long)AccountInfoInteger(ACCOUNT_LOGIN));
   g_gvBase = PFX + acc + "_BASE";
   g_gvTime = PFX + acc + "_TIME";
   g_gvLock = PFX + acc + "_LOCK";
   g_gvPosX = PFX + acc + "_PX";
   g_gvPosY = PFX + acc + "_PY";

   LoadState();

// panel position: remembered across restarts
   g_px = GlobalVariableCheck(g_gvPosX) ? (int)GlobalVariableGet(g_gvPosX) : InpPanelX;
   g_py = GlobalVariableCheck(g_gvPosY) ? (int)GlobalVariableGet(g_gvPosY) : InpPanelY;
   if(g_px < 0)
      g_px = 0;
   if(g_py < 0)
      g_py = 0;

   datetime now = TimeTradeServer();
   if(g_baseTime != LastReset(now))
     {
      // stored base belongs to an older period: a daily reset has passed
      if(g_locked)
        {
         g_locked = false;       // release stale lock from a previous day
         Print("Equity Guard: lock from a previous period released on restart");
        }
      g_base     = 0.0;
      g_baseTime = 0;
     }
   else
      if(g_base > 0.0)
         PrintFormat("Equity Guard: state restored - day-start %.2f %s, lock %s",
                     g_base, g_ccy, g_locked ? "ACTIVE" : "off");

// canvas: height depends on font size
   int fs = InpFontSize;
   int lh = fs + 10;
   int c2h = 14 + 3 * lh + 10 + 12 + 14;
   g_H = 48 + 112 + 10 + c2h + 10 + lh + 4 + 36 + 9 + lh + 10;
   if(!g_canvas.CreateBitmapLabel(0, 0, PFX + "CANVAS", g_px, g_py, g_W + 10, g_H + 10,
                                  COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("Equity Guard: failed to create canvas");
      return INIT_FAILED;
     }
   ObjectSetInteger(0, PFX + "CANVAS", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, PFX + "CANVAS", OBJPROP_HIDDEN, true);

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   UpdateBase(now);
   EventSetTimer(1);
   DrawPanel();

   PrintFormat("Equity Guard 1.2 started | limit: %s | trigger: %.0f%% of limit | reset %02d:%02d server | enforcement: %s",
               (InpLimitMode == LIMIT_PERCENT)
               ? StringFormat("%.1f%% of day-start", InpLimitPercent)
               : StringFormat("%.2f %s", InpLimitMoney, g_ccy),
               InpTriggerPct, InpResetHour, InpResetMinute,
               InpEnforceFlat ? "ON" : "OFF");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   g_canvas.Destroy();
  }

//+------------------------------------------------------------------+
//| OnTimer - every second                                           |
//+------------------------------------------------------------------+
void OnTimer()
  {
   datetime now = TimeTradeServer();
   UpdateBase(now);
   CheckTrigger();
   EnforceFlat(now);
   if(!g_drag)            // don't fight the user while dragging
      DrawPanel();
  }

//+------------------------------------------------------------------+
//| OnTick - extra reactivity for the trigger                        |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckTrigger();
  }

//+------------------------------------------------------------------+
//| OnTrade - re-check on every trade event                          |
//+------------------------------------------------------------------+
void OnTrade()
  {
   CheckTrigger();
   EnforceFlat(TimeTradeServer());
  }

//+------------------------------------------------------------------+
//| OnChartEvent - mouse-driven canvas UI with dragging              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_MOUSE_MOVE)
      return;

   int  mx    = (int)lparam;
   int  my    = (int)dparam;
   int  flags = (int)StringToInteger(sparam);
   bool down  = ((flags & 1) == 1);
   bool downEdge = (down && !g_mdown);
   g_mdown = down;

//--- active drag / pending drag
   if(g_drag || g_dragPending)
     {
      if(down)
        {
         int dx = mx - g_downX, dy = my - g_downY;
         if(g_dragPending && (MathAbs(dx) > 3 || MathAbs(dy) > 3))
           {
            g_drag        = true;
            g_dragPending = false;
           }
         if(g_drag)
            MovePanel(g_panDownX + dx, g_panDownY + dy);
        }
      else
        {
         // released: a pending drag that never moved is a click (restore from pill)
         if(g_dragPending && g_minimized)
           {
            HandleClick(4);
            DrawPanel();
           }
         EndDrag();
        }
      return;
     }

   int hov = HitTest(mx, my);

   if(downEdge)
     {
      // drag starts from the header or from the minimized pill
      if(hov == 5 || (g_minimized && hov == 4))
        {
         g_dragPending = true;
         g_downX = mx;
         g_downY = my;
         g_panDownX = g_px;
         g_panDownY = g_py;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         return;
        }
      if(hov > 0)
        {
         HandleClick(hov);
         DrawPanel();
         return;
        }
     }

   if(hov != g_hover)
     {
      g_hover = hov;
      DrawPanel();
     }
  }
//+------------------------------------------------------------------+
