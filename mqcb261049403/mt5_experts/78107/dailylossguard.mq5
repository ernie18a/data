//+------------------------------------------------------------------+
//| DailyLossGuard.mq5                                               |
//| Risk-first daily loss guard EA — kouaAlgo                        |
//|                                                                  |
//| Monitors the account's daily P/L. When the configured daily loss |
//| limit is breached it closes all positions (optional) and raises  |
//| alerts, staying in BREACHED state until the next trading day.    |
//|                                                                  |
//| Honest limitation: an EA cannot force other EAs to stop trading. |
//| Use this guard alongside manual discipline, or run it on the same |
//| account that hosts your bots so its alerts reach you instantly.   |
//+------------------------------------------------------------------+
#property copyright "kouaAlgo"
#property link      "https://www.mql5.com/en/users/kouaAlgo"
#property version   "1.01"
#property description "Hard daily-loss guard: closes everything and alerts when the daily loss limit is breached."
#property description "v1.01: self-healing top-center panel - survives timeframe changes and chart resizes."

#include <Trade\Trade.mqh>

//--- inputs
input double InpMaxDailyLossPct   = 2.0;    // Max daily loss (% of day-start balance)
input double InpMaxDailyLossMoney = 0.0;    // Max daily loss (account currency, 0 = disabled)
input bool   InpCloseAllOnBreach  = true;   // Close all positions on breach
input long   InpMagicNumber       = -1;     // Magic number filter (-1 = all positions)
input int    InpSlippagePoints    = 20;     // Max slippage (points)
input bool   InpShowPanel         = true;   // Show status panel
input bool   InpCenterTop         = true;   // Center panel at top (pro look, clear of Buy/Sell buttons)

//--- constants
#define OBJ_PREFIX "DLG_"
#define PANEL_W 250
#define PANEL_H 92

//--- state
CTrade   g_trade;
datetime g_dayStart        = 0;      // D1 bar time of the current trading day
double   g_dayStartBalance = 0.0;   // balance at first tick of the day
bool     g_breached        = false;
bool     g_panelBuilt      = false;
long     g_chartW          = 0;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   g_trade.SetAsyncMode(false);
   NewDay(iTime(_Symbol, PERIOD_D1, 0));
   if(InpShowPanel)
      BuildPanel();
   Print("DailyLossGuard initialized. Day start balance = ", DoubleToString(g_dayStartBalance, 2));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, OBJ_PREFIX);
   g_panelBuilt = false;
   Comment("");
  }

//+------------------------------------------------------------------+
//| New trading day: reset baseline and breach state                 |
//+------------------------------------------------------------------+
void NewDay(const datetime dayStart)
  {
   g_dayStart        = dayStart;
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_breached        = false;
  }

//+------------------------------------------------------------------+
//| Close every open position (optionally filtered by magic)         |
//+------------------------------------------------------------------+
int CloseAllPositions()
  {
   int closed = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(!PositionSelectByTicket(ticket))
         continue;
      if(InpMagicNumber >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if(g_trade.PositionClose(ticket))
         closed++;
      else
         Print("DailyLossGuard: failed to close #", ticket, " err=", GetLastError());
     }
   return(closed);
  }

//+------------------------------------------------------------------+
//| Current floating profit of (filtered) open positions             |
//+------------------------------------------------------------------+
double CurrentFloating()
  {
   double floating = 0.0;
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(!PositionSelectByTicket(ticket))
         continue;
      if(InpMagicNumber >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return(floating);
  }

//+------------------------------------------------------------------+
//| Main tick handler                                                |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(today != g_dayStart)
      NewDay(today);
   if(InpShowPanel)
      EnsurePanel();

   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double floating = CurrentFloating();
// Daily P/L approximated as (balance + floating) - day-start balance.
// Note: floating open at the day boundary is folded into the baseline;
// for a pure realized-P/L guard, run this on an account without
// positions held overnight.
   double pnl     = (balance + floating) - g_dayStartBalance;
   double lossPct = (g_dayStartBalance > 0.0) ? (-pnl / g_dayStartBalance * 100.0) : 0.0;

   bool breach = false;
   if(InpMaxDailyLossPct   > 0.0 && lossPct >= InpMaxDailyLossPct)
      breach = true;
   if(InpMaxDailyLossMoney > 0.0 && -pnl     >= InpMaxDailyLossMoney)
      breach = true;

   if(breach && !g_breached)
      OnBreach(pnl, lossPct);
   if(InpShowPanel)
      UpdatePanel(pnl, lossPct);
  }

//+------------------------------------------------------------------+
//| Breach handler                                                   |
//+------------------------------------------------------------------+
void OnBreach(const double pnl, const double lossPct)
  {
   g_breached = true;
   int closed = 0;
   if(InpCloseAllOnBreach)
      closed = CloseAllPositions();

   string msg = StringFormat("DailyLossGuard BREACH: daily P/L %s (%s%%). Closed %d position(s).",
                             DoubleToString(pnl, 2), DoubleToString(-lossPct, 2), closed);
   Alert(msg);
   Print(msg);
   SendNotification(msg); // delivered if MetaTrader push notifications are configured
  }

//+------------------------------------------------------------------+
//| Position the panel: top-center (pro) or legacy top-left          |
//+------------------------------------------------------------------+
void PositionPanel()
  {
   int x = 10, y = 20;
   if(InpCenterTop)
     {
      long w = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      if(w > 0)
         g_chartW = w;
      if(g_chartW <= 0)
         g_chartW = 1280;
      x = (int)((g_chartW - PANEL_W) / 2);
      if(x < 0)
         x = 0;
     }
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_YDISTANCE, y);

   string names[4] = {OBJ_PREFIX + "t", OBJ_PREFIX + "pnl", OBJ_PREFIX + "lim", OBJ_PREFIX + "st"};
   for(int i = 0; i < 4; i++)
     {
      ObjectSetInteger(0, names[i], OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, names[i], OBJPROP_XDISTANCE, x + 10);
      ObjectSetInteger(0, names[i], OBJPROP_YDISTANCE, y + 6 + i * 16);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Self-healing: rebuild the panel if its objects vanished, and     |
//| re-center it whenever the chart is resized. Called every tick.   |
//+------------------------------------------------------------------+
void EnsurePanel()
  {
   if(ObjectFind(0, OBJ_PREFIX + "bg") < 0)
     {
      g_panelBuilt = false;
      ObjectsDeleteAll(0, OBJ_PREFIX);
      BuildPanel();
      return;
     }
   if(InpCenterTop)
     {
      long w = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      if(w > 0 && w != g_chartW)
         PositionPanel();
     }
  }

//+------------------------------------------------------------------+
//| Status panel (chart objects)                                     |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   if(g_panelBuilt)
      return;
   string bg = OBJ_PREFIX + "bg";
   if(!ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return;
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, PANEL_W);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, PANEL_H);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'20,20,28');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrDimGray);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);

   string names[4] = {OBJ_PREFIX + "t", OBJ_PREFIX + "pnl", OBJ_PREFIX + "lim", OBJ_PREFIX + "st"};
   for(int i = 0; i < 4; i++)
     {
      ObjectCreate(0, names[i], OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, names[i], OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, names[i], OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, names[i], OBJPROP_COLOR, clrWhiteSmoke);
      ObjectSetInteger(0, names[i], OBJPROP_SELECTABLE, false);
     }
   ObjectSetString(0, OBJ_PREFIX + "t", OBJPROP_TEXT, "DailyLossGuard — kouaAlgo");
   g_panelBuilt = true;
   PositionPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePanel(const double pnl, const double lossPct)
  {
   if(!g_panelBuilt)
      return;
   color  pnlColor = (pnl >= 0.0) ? clrMediumSeaGreen : clrTomato;
   string stText   = g_breached ? "STATUS: BREACHED" : "STATUS: ARMED";
   color  stColor  = g_breached ? clrTomato : clrMediumSeaGreen;

   ObjectSetString(0, OBJ_PREFIX + "pnl", OBJPROP_TEXT,
                   "Daily P/L: " + DoubleToString(pnl, 2) + "  (" + DoubleToString(-lossPct, 2) + "%)");
   ObjectSetInteger(0, OBJ_PREFIX + "pnl", OBJPROP_COLOR, pnlColor);

   ObjectSetString(0, OBJ_PREFIX + "lim", OBJPROP_TEXT,
                   StringFormat("Limit: %.2f%% / %.2f", InpMaxDailyLossPct, InpMaxDailyLossMoney));

   ObjectSetString(0, OBJ_PREFIX + "st", OBJPROP_TEXT, stText);
   ObjectSetInteger(0, OBJ_PREFIX + "st", OBJPROP_COLOR, stColor);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
