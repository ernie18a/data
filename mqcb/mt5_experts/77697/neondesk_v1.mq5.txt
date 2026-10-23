//+------------------------------------------------------------------+
//| NeonDesk -- Manual Trading Panel                                   |
//| (source file: NeonDesk_v1.mq5)                                    |
//| NEW, STANDALONE EA -- does NOT touch any other file.               |
//| Manual trading panel: drag it onto any chart you want to trade    |
//| yourself. Shows OHLC + colour-coded price, 1M/30M/4H/1D           |
//| direction, editable SL/TP shown as ACTUAL PRICE LEVELS (matching  |
//| the chart's own price format -- not an abstract pip count), an   |
//| ATR-based suggested SL/TP (just a hint), an open-position         |
//| summary, a configurable TRAILING STOP, a live candle open/close   |
//| countdown, and BUY/SELL/CLOSE-ALL buttons.                        |
//| Behaves like a Windows window: drag the top bar to move it, drag  |
//| the bottom-right corner grip to make it bigger/smaller. The       |
//| trading body fades to InpFadedOpacityPct when the mouse is not    |
//| over the panel.                                                   |
//|                                                                    |
//| SL/TP/Trail are edited by CLICKING the box on the panel and       |
//| typing -- there is no native MT5 edit box anywhere on this panel. |
//| MT5's native edit boxes (OBJ_EDIT) turned out to be unreliable    |
//| here (they kept losing mouse focus to nearby objects no matter    |
//| how they were isolated), so input is captured directly via        |
//| CHARTEVENT_KEYDOWN instead -- the same "go fully manual instead   |
//| of trusting native object behaviour" fix that made the drag bar   |
//| and resize grip reliable earlier in this project.                 |
//+------------------------------------------------------------------+
#property copyright "NeonDesk"
#property version   "1.19"
#property description "NeonDesk -- draggable manual trading panel with multi-timeframe bias."
#property strict

#include <Canvas\Canvas.mqh>
#include <Trade\Trade.mqh>

//--- Inputs (grouped into clearly labelled sections in the EA's Inputs tab)
input group "===== Trading ====="
input double InpLotSize          = 0.01;     // Lot size used for every BUY/SELL click
input double InpSlPips           = 20.0;     // Starting Stop-Loss distance in PIPS (shown/editable on the panel as an actual price)
input double InpTpPips           = 40.0;     // Starting Take-Profit distance in PIPS (shown/editable on the panel as an actual price)
input long   InpMagic            = 900001;   // Unique ID tag for this panel's own trades (keeps Close-All / Trailing Stop from ever touching other EAs' trades)

input group "===== Panel Position, Size & Fade ====="
input int    InpPanelX           = 12;       // Starting distance from the LEFT edge of the chart, in pixels (or just drag the panel)
input int    InpPanelY           = 24;       // Starting distance from the TOP edge of the chart, in pixels (or just drag the panel)
input int    InpPanelW           = 250;      // Starting WIDTH in pixels (or just drag the bottom-right corner grip to resize)
input int    InpPanelH           = 610;      // Starting HEIGHT in pixels (or just drag the bottom-right corner grip to resize)
input int    InpHandleHeight     = 34;       // Height of the drag bar at the very top of the panel, in pixels
input int    InpFadedOpacityPct  = 40;       // Opacity in % (0=invisible, 100=solid) the panel fades to when your mouse is NOT over it

input group "===== Suggested SL/TP -- ATR hint, DISPLAY ONLY ====="
input double InpAtrSlMult        = 1.5;      // Suggested SL shown = current ATR(14) x this number. Display only -- never changes your own SL box
input double InpAtrTpMult        = 3.0;      // Suggested TP shown = current ATR(14) x this number. Display only -- never changes your own TP box

input group "===== Trailing Stop ====="
input double InpTrailPips        = 15.0;     // Starting trailing distance in PIPS (change any time in the Trail box on the panel itself)
input bool   InpTrailEnabledAtStart = false; // true = trailing stop is already switched ON when the EA starts (toggle any time with the TRAIL button)

input group "===== Candle Countdown Timer ====="
input ENUM_TIMEFRAMES InpCountdownTF = PERIOD_CURRENT; // Timeframe the countdown timer tracks: pick any timeframe from M1 to D1 (or leave on "Current Period" to follow the chart's own timeframe)

//--- Limits so the content never overlaps
#define MIN_PANEL_W 230
#define MIN_PANEL_H 610
#define GRIP_SIZE   22

//--- Close (X) button (a real OBJ_BUTTON, always visible, in the drag bar)
#define CLOSEX_W 26
#define CLOSEX_MARGIN 4

//--- Colours -- one neon-on-black theme used consistently everywhere so the
//    drag bar and the canvas body read as ONE unified panel.
#define CLR_BG      C'8,10,16'      // near-black body
#define CLR_BORDER  C'0,225,255'    // neon cyan outline, used on every section for a seamless look
#define CLR_HANDLE  C'14,17,26'     // drag bar -- same dark family as the body
#define CLR_TEXT    C'225,232,240'
#define CLR_MUTED   C'120,150,170'
#define CLR_UP      C'57,255,140'   // neon green
#define CLR_DOWN    C'255,55,110'   // neon pink-red
#define CLR_FLAT    C'150,160,170'
#define CLR_BUY     C'0,224,150'    // neon green button
#define CLR_SELL    C'255,45,110'   // neon magenta-red button
#define CLR_CLOSE   C'255,176,0'    // neon amber button
#define CLR_GRIP    C'0,225,255'    // neon cyan -- matches the border colour
#define CLR_HINT    C'255,214,0'    // neon yellow -- also used as the "editing" highlight border
#define CLR_BTNTXT  C'6,10,14'      // dark text reads cleanly on the bright neon buttons
#define CLR_BOXBG   C'20,25,36'     // input-box fill, a shade lighter than the body

CCanvas   g_canvas;
CTrade    g_trade;
string    g_panelName;
string    g_handleName;
string    g_handleLabelName;
string    g_closeXName;
string    g_resizeName;
string    g_slLineName;
string    g_tpLineName;
int       g_handleH      = 34;
int       g_panelW       = 250;
int       g_panelH       = 610;
uchar     g_alpha        = 255;
bool      g_hover        = true;
double    g_prevPrice    = 0.0;
int       g_atrHandle    = INVALID_HANDLE;
bool      g_trailEnabled = false;

//--- Current SL/TP/Trail values. Stored as pip DISTANCES internally (so the
//    BUY/SELL logic and the ATR hint keep working exactly as before), but
//    shown to you and edited by you as an ACTUAL PRICE for SL/TP (matching
//    the chart's own price format), and as plain pips for the trailing
//    distance. Click a box on the panel, type, press Enter to confirm.
double    g_curSlPips    = 20.0;
double    g_curTpPips    = 40.0;
double    g_curTrailPips = 15.0;

//--- Which box (if any) is currently being typed into, and what has been
//    typed so far. 0=none, 1=SL price, 2=TP price, 3=Trail pips.
int       g_editField  = 0;
string    g_editBuffer = "";

//--- Drag/resize is tracked MANUALLY via CHARTEVENT_MOUSE_MOVE's button
//    state (not the native CHARTEVENT_OBJECT_DRAG -- native drag for
//    corner-anchored GUI objects is unreliable in MT5).
bool      g_prevLeftDown   = false;
bool      g_draggingHandle = false;
bool      g_resizing       = false;
int       g_dragStartMouseX = 0, g_dragStartMouseY = 0;
int       g_dragStartPanelX = 0, g_dragStartPanelY = 0;
int       g_resizeStartW    = 0, g_resizeStartH    = 0;

//+------------------------------------------------------------------+
double PipSize()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- 3-digit (JPY pairs) and 5-digit (most FX majors) quotes use a
   //    "fractional pip" as their smallest visible digit, so the real
   //    pip is 10x the point. 2-digit quotes (XAUUSD/XAGUSD, many
   //    indices) work the same way -- 1 point there is a tiny fraction
   //    of the instrument's normal move, so 1 pip = 10 points there too.
   //    Everything else (4-digit FX, whole-number instruments) already
   //    has the point itself as a sensible pip.
   return (digits == 2 || digits == 3 || digits == 5) ? point * 10.0 : point;
}

//+------------------------------------------------------------------+
//| The broker's own minimum stop distance for this symbol, expressed |
//| in this panel's pip units. A trailing-stop (or SL/TP) distance    |
//| tighter than this either gets rejected outright or, worse, gets   |
//| accepted and then taken out almost immediately by ordinary price  |
//| noise -- this is the floor ApplyTrailingStop() and the Trail box  |
//| enforce so that can never happen silently.                        |
//+------------------------------------------------------------------+
double MinTrailPips()
{
   int    stopsLevelPts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point         = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double pip           = PipSize();
   if(pip <= 0) return 0;
   return (MathMax(stopsLevelPts, 1) * point) / pip;
}

//+------------------------------------------------------------------+
//| Direction is read off the PREVIOUS, COMPLETED candle on each      |
//| timeframe (bar index 1: its own open vs its own close) instead of |
//| comparing live price to the still-forming current candle (bar 0). |
//| Far less noisy -- a fresh M1 bar that is only seconds old can no  |
//| longer flip the reading back and forth. The "last" parameter is   |
//| kept (other callers still pass it) but no longer used for this.   |
//+------------------------------------------------------------------+
color TFColor(ENUM_TIMEFRAMES tf, double last)
{
   double o = iOpen(_Symbol, tf, 1);
   double c = iClose(_Symbol, tf, 1);
   if(o <= 0 || c <= 0) return CLR_FLAT;
   if(c > o) return CLR_UP;
   if(c < o) return CLR_DOWN;
   return CLR_FLAT;
}
string TFArrow(ENUM_TIMEFRAMES tf, double last)
{
   double o = iOpen(_Symbol, tf, 1);
   double c = iClose(_Symbol, tf, 1);
   if(o <= 0 || c <= 0) return "--";
   if(c > o) return "UP";     // green -- upward
   if(c < o) return "DOWN";   // red -- downward
   return "--";
}

//+------------------------------------------------------------------+
//| true when 3 or 4 of the 1M/30M/4H/1D timeframes closed their last |
//| COMPLETED candle below that candle's own open -- the same "SELL   |
//| side" framing DrawPanel uses for its BUY/SELL/MIXED suggestion    |
//| and its SL/TP preview lines. Shared here so a box's price and the |
//| confirmed edit use the exact same direction logic as the chart.   |
//+------------------------------------------------------------------+
bool CurrentSellSide(double last)
{
   int ups = 0, downs = 0;
   ENUM_TIMEFRAMES tfs[4] = { PERIOD_M1, PERIOD_M30, PERIOD_H4, PERIOD_D1 };
   for(int i = 0; i < 4; i++)
   {
      color c = TFColor(tfs[i], last);
      if(c == CLR_UP) ups++;
      else if(c == CLR_DOWN) downs++;
   }
   return (downs >= 3);
}

//+------------------------------------------------------------------+
//| Computes the SL/TP as ACTUAL PRICES from the stored pip distances, |
//| following the current suggestion's direction -- this is exactly   |
//| what the dashed SL/TP lines on the chart show, and exactly what   |
//| the SL/TP boxes on the panel display, so they always agree.       |
//+------------------------------------------------------------------+
void ComputeSlTpPrices(double &slPriceOut, double &tpPriceOut, double &lastOut, bool &sellSideOut)
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   lastOut = (bid > 0) ? bid : ask;
   double pip = PipSize();
   sellSideOut = CurrentSellSide(lastOut);
   slPriceOut  = sellSideOut ? lastOut + g_curSlPips * pip : lastOut - g_curSlPips * pip;
   tpPriceOut  = sellSideOut ? lastOut - g_curTpPips * pip : lastOut + g_curTpPips * pip;
}

//+------------------------------------------------------------------+
//| Which timeframe the candle countdown timer should track. Chosen   |
//| yourself in the Inputs tab (M1...D1) -- or leave InpCountdownTF   |
//| on "Current Period" to always follow whatever timeframe the       |
//| chart itself is on.                                               |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CountdownTimeframe()
{
   return (InpCountdownTF == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : InpCountdownTF;
}

//+------------------------------------------------------------------+
//| Readable short name for a timeframe (e.g. "H1"), for the candle   |
//| countdown timer's title.                                          |
//+------------------------------------------------------------------+
string PeriodLabel(ENUM_TIMEFRAMES tf)
{
   string s = EnumToString(tf);
   StringReplace(s, "PERIOD_", "");
   return s;
}

//+------------------------------------------------------------------+
//| ATR(14)-based SUGGESTION -- just a hint, never changes your own   |
//| SL/TP boxes. You always choose your own SL/TP.                    |
//+------------------------------------------------------------------+
bool GetSuggestedSlTpPips(double &slPipsOut, double &tpPipsOut)
{
   if(g_atrHandle == INVALID_HANDLE) return false;
   double buf[];
   if(CopyBuffer(g_atrHandle, 0, 0, 1, buf) <= 0) return false;
   double atr = buf[0];
   double pip = PipSize();
   if(atr <= 0 || pip <= 0) return false;
   double atrPips = atr / pip;
   slPipsOut = NormalizeDouble(atrPips * InpAtrSlMult, 1);
   tpPipsOut = NormalizeDouble(atrPips * InpAtrTpMult, 1);
   return true;
}

//+------------------------------------------------------------------+
//| Counts open positions + combined P&L opened BY THIS PANEL itself  |
//| (own magic number, current symbol only).                          |
//+------------------------------------------------------------------+
void GetOwnPositions(int &countOut, double &plOut)
{
   countOut = 0;
   plOut = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      countOut++;
      plOut += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
}

//+------------------------------------------------------------------+
//| Same idea as GetOwnPositions(), but returns total volume instead   |
//| of P&L -- used to warn before stacking another trade on top of an  |
//| existing one on this same chart/symbol.                            |
//+------------------------------------------------------------------+
void GetOwnPositionsVolume(int &countOut, double &volOut)
{
   countOut = 0;
   volOut = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      countOut++;
      volOut += PositionGetDouble(POSITION_VOLUME);
   }
}

//+------------------------------------------------------------------+
//| When THIS panel has exactly ONE open position on this symbol, the |
//| YOUR SL / YOUR TP boxes stop being a "next order" preset and       |
//| become a direct, live view/edit of that ONE REAL position's own    |
//| stop levels -- so there is only ever one real Stop-Loss, never a   |
//| second "shadow" one sitting only in the panel's own memory that    |
//| never actually reaches the broker. Returns false (and leaves the   |
//| boxes as the next-order preset) when there is no position yet, or  |
//| when more than one is open on this symbol (ambiguous which one the |
//| box should control).                                               |
//+------------------------------------------------------------------+
bool GetOwnSinglePosition(ulong &ticketOut, double &slOut, double &tpOut, long &typeOut)
{
   int    count = 0;
   ulong  foundTicket = 0;
   double foundSl = 0.0, foundTp = 0.0;
   long   foundType = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      count++;
      foundTicket = ticket;
      foundSl     = PositionGetDouble(POSITION_SL);
      foundTp     = PositionGetDouble(POSITION_TP);
      foundType   = PositionGetInteger(POSITION_TYPE);
   }
   if(count != 1) return false;
   ticketOut = foundTicket;
   slOut     = foundSl;
   tpOut     = foundTp;
   typeOut   = foundType;
   return true;
}

//+------------------------------------------------------------------+
//| A short, broker-account-specific note about what stacking another  |
//| trade actually does under this account's margin/netting mode.      |
//+------------------------------------------------------------------+
string BrokerModeNote()
{
   long mode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode == ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
      return "Note: this account is in NETTING mode -- a same-direction trade may be merged into your existing position rather than opened separately, and an opposite-direction trade may reduce or close it instead of hedging.";
   if(mode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      return "Note: this account is in HEDGING mode -- this will open as a SEPARATE additional position, stacking your total exposure and margin usage on this symbol.";
   return "Note: check your broker's rules for this account type before stacking positions on the same symbol.";
}

//+------------------------------------------------------------------+
//| Configurable TRAILING STOP -- YOU choose the distance (pips) in   |
//| the Trail box on the panel, and switch it ON/OFF with the button  |
//| next to it. Only touches this panel's OWN positions (own magic,   |
//| current symbol), and never moves the SL backwards -- only forward |
//| with price in your favour, like a normal trailing stop.           |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
   if(!g_trailEnabled) return;
   if(g_curTrailPips <= 0) return;

   double pip = PipSize();
   double trailDist = g_curTrailPips * pip;
   double minStep = pip * 0.5;   // don't reposition on every microscopic price wiggle

   //--- never send the broker a trailing SL tighter than its own minimum
   //    stop distance -- last line of defence even if a stale/typed pip
   //    value slipped through smaller than that.
   int    stopsLevelPts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point         = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double minDist       = MathMax(stopsLevelPts, 1) * point;
   if(trailDist < minDist) trailDist = minDist;

   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      double curSl = PositionGetDouble(POSITION_SL);
      double tp    = PositionGetDouble(POSITION_TP);

      if(type == POSITION_TYPE_BUY)
      {
         double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double newSl = bid - trailDist;
         if(newSl < bid && (curSl <= 0 || newSl > curSl + minStep))
            g_trade.PositionModify(ticket, newSl, tp);
      }
      else if(type == POSITION_TYPE_SELL)
      {
         double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double newSl = ask + trailDist;
         if(newSl > ask && (curSl <= 0 || newSl < curSl - minStep))
            g_trade.PositionModify(ticket, newSl, tp);
      }
   }
}

//+------------------------------------------------------------------+
//| Button positions are derived from g_panelW/g_panelH (not fixed    |
//| #defines) so resizing scales the layout correctly. Top elements   |
//| are anchored from the top; the 3 buttons are anchored from the    |
//| BOTTOM, so a bigger panel just gets more open space in the        |
//| middle, never any overlap.                                        |
//+------------------------------------------------------------------+
void GetButtonRects(int &buyX1,int &buyY1,int &buyX2,int &buyY2,
                     int &sellX1,int &sellY1,int &sellX2,int &sellY2,
                     int &closeX1,int &closeY1,int &closeX2,int &closeY2)
{
   closeY2 = g_panelH - 10;
   closeY1 = closeY2 - 28;
   sellY2  = closeY1 - 6;
   sellY1  = sellY2 - 34;
   buyY1   = sellY1;
   buyY2   = sellY2;

   buyX1   = 10;
   buyX2   = g_panelW / 2 - 6;
   sellX1  = g_panelW / 2 + 6;
   sellX2  = g_panelW - 10;
   closeX1 = 10;
   closeX2 = g_panelW - 10;
}

//+------------------------------------------------------------------+
//| Positions of the SL/TP price boxes and the Trail box + ON/OFF     |
//| button, all drawn ON THE CANVAS (no native MT5 objects at all --  |
//| see the note at the top of this file for why). Single source of  |
//| truth used by both DrawPanel (to draw them) and OnChartEvent (to  |
//| hit-test clicks on them), so they can never drift apart.          |
//+------------------------------------------------------------------+
void GetInputRects(int &slX1,int &slY1,int &slX2,int &slY2,
                    int &tpX1,int &tpY1,int &tpX2,int &tpY2,
                    int &trX1,int &trY1,int &trX2,int &trY2,
                    int &ttX1,int &ttY1,int &ttX2,int &ttY2)
{
   slY1 = 176; slY2 = 202;
   tpY1 = 176; tpY2 = 202;
   slX1 = 10;               slX2 = g_panelW / 2 - 6;
   tpX1 = g_panelW / 2 + 6; tpX2 = g_panelW - 10;

   trY1 = 240; trY2 = 266;
   ttY1 = 240; ttY2 = 266;
   trX1 = 10;  trX2 = 100;
   ttX1 = 110; ttX2 = g_panelW - 10;
}

//+------------------------------------------------------------------+
int GetHandleX() { return (int)ObjectGetInteger(0, g_handleName, OBJPROP_XDISTANCE); }
int GetHandleY() { return (int)ObjectGetInteger(0, g_handleName, OBJPROP_YDISTANCE); }

//+------------------------------------------------------------------+
//| PERSISTENCE -- if you accidentally remove NeonDesk from the chart |
//| (the X button, "Remove", dragging a different EA on top of it,    |
//| etc.), re-attaching it should NOT lose your SL/TP preset, trailing |
//| stop setting/on-off, or where you dragged/resized the panel to.    |
//| Stored as terminal-wide GLOBAL VARIABLES (survive both removing    |
//| the EA and a full MetaTrader restart -- MT5 keeps them on disk for |
//| 4 weeks since last use), keyed by symbol + magic number so a       |
//| second NeonDesk on a different chart/magic never clashes with      |
//| this one's saved settings.                                        |
//+------------------------------------------------------------------+
string GVName(string suffix)
{
   return "NeonDesk_" + _Symbol + "_" + IntegerToString(InpMagic) + "_" + suffix;
}

void SaveSettings()
{
   GlobalVariableSet(GVName("SlPips"),    g_curSlPips);
   GlobalVariableSet(GVName("TpPips"),    g_curTpPips);
   GlobalVariableSet(GVName("TrailPips"), g_curTrailPips);
   GlobalVariableSet(GVName("TrailOn"),   g_trailEnabled ? 1.0 : 0.0);
   GlobalVariableSet(GVName("PanelX"),    (double)GetHandleX());
   GlobalVariableSet(GVName("PanelY"),    (double)GetHandleY());
   GlobalVariableSet(GVName("PanelW"),    (double)g_panelW);
   GlobalVariableSet(GVName("PanelH"),    (double)g_panelH);
}

//--- Reads back whatever was last saved, if anything, into the SL/TP/trail
//    globals -- called from OnInit() BEFORE those are set from the input
//    parameters, so a saved value wins and a first-ever attach (nothing
//    saved yet) just keeps using your input defaults.
void LoadSavedTradingSettings()
{
   if(GlobalVariableCheck(GVName("SlPips")))    g_curSlPips    = GlobalVariableGet(GVName("SlPips"));
   if(GlobalVariableCheck(GVName("TpPips")))    g_curTpPips    = GlobalVariableGet(GVName("TpPips"));
   if(GlobalVariableCheck(GVName("TrailPips"))) g_curTrailPips = GlobalVariableGet(GVName("TrailPips"));
   if(GlobalVariableCheck(GVName("TrailOn")))   g_trailEnabled = (GlobalVariableGet(GVName("TrailOn")) > 0.5);
}

//--- Same idea for the panel's position/size, but these have to override
//    the input-parameter DEFAULTS passed into ObjectCreate/CreateBitmapLabel
//    at panel-creation time in OnInit(), so this is read into plain local
//    variables there instead of the (read-only) input parameters themselves.
void LoadSavedPanelRect(int &xOut, int &yOut, int &wOut, int &hOut)
{
   if(GlobalVariableCheck(GVName("PanelX"))) xOut = (int)GlobalVariableGet(GVName("PanelX"));
   if(GlobalVariableCheck(GVName("PanelY"))) yOut = (int)GlobalVariableGet(GVName("PanelY"));
   if(GlobalVariableCheck(GVName("PanelW"))) wOut = (int)GlobalVariableGet(GVName("PanelW"));
   if(GlobalVariableCheck(GVName("PanelH"))) hOut = (int)GlobalVariableGet(GVName("PanelH"));
}

//+------------------------------------------------------------------+
//| The drag bar (top) is the "official" position. Everything else    |
//| always follows from it: canvas body, X button, corner grip.       |
//+------------------------------------------------------------------+
void SyncPositions()
{
   int hx = GetHandleX();
   int hy = GetHandleY();
   int bodyY = hy + g_handleH;

   ObjectSetInteger(0, g_handleName, OBJPROP_XSIZE, g_panelW - CLOSEX_W - CLOSEX_MARGIN - 2);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_XDISTANCE, hx + 8);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_YDISTANCE, hy + g_handleH / 2 - 6);

   ObjectSetInteger(0, g_closeXName, OBJPROP_XDISTANCE, hx + g_panelW - CLOSEX_W - CLOSEX_MARGIN);
   ObjectSetInteger(0, g_closeXName, OBJPROP_YDISTANCE, hy + CLOSEX_MARGIN);

   ObjectSetInteger(0, g_panelName, OBJPROP_XDISTANCE, hx);
   ObjectSetInteger(0, g_panelName, OBJPROP_YDISTANCE, bodyY);

   ObjectSetInteger(0, g_resizeName, OBJPROP_XDISTANCE, hx + g_panelW - GRIP_SIZE);
   ObjectSetInteger(0, g_resizeName, OBJPROP_YDISTANCE, bodyY + g_panelH - GRIP_SIZE);
}

//+------------------------------------------------------------------+
//| Draws one clickable input box on the canvas: a filled rectangle   |
//| with a neon border (bright yellow while it's the one being typed  |
//| into, cyan otherwise) and centred text. A trailing "_" is shown   |
//| while editing as a simple cursor.                                 |
//+------------------------------------------------------------------+
void DrawInputBox(int x1, int y1, int x2, int y2, string text, bool editing)
{
   g_canvas.FillRectangle(x1, y1, x2, y2, ColorToARGB(CLR_BOXBG, g_alpha));
   g_canvas.Rectangle(x1, y1, x2, y2, ColorToARGB(editing ? CLR_HINT : CLR_BORDER, g_alpha));
   string shown = editing ? (text + "_") : text;
   g_canvas.FontSet("Arial", -110, FW_BOLD);
   g_canvas.TextOut((x1 + x2) / 2, (y1 + y2) / 2, shown, ColorToARGB(CLR_TEXT, g_alpha), TA_CENTER | TA_VCENTER);
}

//+------------------------------------------------------------------+
//| Confirms whatever is currently being typed (SL/TP price, or Trail |
//| pips) and stores it, then leaves edit mode. Called on Enter, and  |
//| on any click elsewhere (clicking away confirms, like a normal     |
//| form field). Typing something invalid/blank just cancels quietly |
//| and keeps the previous value.                                     |
//+------------------------------------------------------------------+
void ConfirmEdit()
{
   if(g_editField == 0) return;

   double typed = StringToDouble(g_editBuffer);
   if(typed > 0)
   {
      if(g_editField == 1 || g_editField == 2)
      {
         //--- If this panel has exactly ONE real open position on this
         //    symbol, typing here edits THAT position's real, broker-side
         //    Stop-Loss/Take-Profit directly -- not a preset for some
         //    future order. This is what makes sure there is only ever
         //    ONE real stop: never a second "shadow" value that only ever
         //    lived in this panel's own memory and never reached the
         //    broker (which is exactly what could happen before: the real
         //    position kept its original SL, while this box quietly kept
         //    showing and "accepting" a completely different number).
         ulong  ownTicket; double ownSl, ownTp; long ownType;
         if(GetOwnSinglePosition(ownTicket, ownSl, ownTp, ownType))
         {
            bool   isBuy   = (ownType == POSITION_TYPE_BUY);
            double bid     = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask     = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double refPx   = isBuy ? bid : ask;   // same side the broker itself checks a position's stops against
            double newSl   = (g_editField == 1) ? typed : ownSl;
            double newTp   = (g_editField == 2) ? typed : ownTp;
            string errMsg;
            if(ValidateOrderStops(isBuy, refPx, newSl, newTp, errMsg))
            {
               if(g_trade.PositionModify(ownTicket, newSl, newTp))
               {
                  int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
                  string note = "";
                  //--- A manual Stop-Loss edit while TRAIL is ON would just get
                  //    overwritten again within a second by ApplyTrailingStop()
                  //    recalculating its own distance from the current price --
                  //    which is exactly the "it resets the stop-loss itself"
                  //    problem this fixes. Typing a new SL by hand is a clear,
                  //    deliberate override, so it switches TRAIL off instead of
                  //    silently losing the fight against the trailing logic.
                  if(g_editField == 1 && g_trailEnabled)
                  {
                     g_trailEnabled = false;
                     SaveSettings();
                     note = "\n\nTRAILING STOP was ON and has been switched OFF, so it doesn't move this Stop-Loss again on its own. Turn it back on any time on the panel.";
                  }
                  MessageBox(StringFormat("%s updated to %s on your open position.%s",
                             (g_editField == 1) ? "Stop-Loss" : "Take-Profit",
                             DoubleToString(typed, digits), note),
                             "NeonDesk", MB_OK | MB_ICONINFORMATION);
               }
               else
               {
                  MessageBox(StringFormat("Failed to update %s: %s (retcode %d)",
                             (g_editField == 1) ? "Stop-Loss" : "Take-Profit",
                             g_trade.ResultRetcodeDescription(), g_trade.ResultRetcode()),
                             "NeonDesk -- Update Failed", MB_OK | MB_ICONERROR);
               }
            }
            else
            {
               MessageBox(errMsg, "NeonDesk -- Invalid Level", MB_OK | MB_ICONWARNING);
            }
         }
         else
         {
            //--- No single open position to edit -- this box is just a
            //    PRESET for your NEXT BUY/SELL order (stored as a pip
            //    distance from the current price, same as before).
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double last = (bid > 0) ? bid : ask;
            double pip = PipSize();
            bool sellSide = CurrentSellSide(last);
            double dist;
            if(g_editField == 1) dist = sellSide ? (typed - last) : (last - typed);   // SL
            else                 dist = sellSide ? (last - typed) : (typed - last);   // TP
            dist = MathAbs(dist);
            if(pip > 0) dist /= pip;
            if(dist > 0)
            {
               if(g_editField == 1) g_curSlPips = dist;
               else                 g_curTpPips = dist;
               SaveSettings();
            }
         }
      }
      else if(g_editField == 3)
      {
         g_curTrailPips = typed;
         if(g_trailEnabled)
         {
            double floorPips = MinTrailPips();
            if(g_curTrailPips < floorPips)
            {
               double oldPips = g_curTrailPips;
               g_curTrailPips = floorPips;
               MessageBox(StringFormat(
                  "Your Trail distance of %s pips is tighter than %s's own minimum stop distance. "
                  "It has been raised to %s pips so the trailing stop can't be taken out almost instantly by normal price movement.",
                  DoubleToString(oldPips, 1), _Symbol, DoubleToString(floorPips, 1)),
                  "NeonDesk -- Trail Distance Raised", MB_OK | MB_ICONWARNING);
            }
         }
         SaveSettings();
      }
   }

   g_editField = 0;
   g_editBuffer = "";
}

//+------------------------------------------------------------------+
void DrawPanel()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double last = (bid > 0) ? bid : ask;
   double pip = PipSize();
   color priceClr = CLR_FLAT;
   if(g_prevPrice > 0)
   {
      if(last > g_prevPrice) priceClr = CLR_UP;
      else if(last < g_prevPrice) priceClr = CLR_DOWN;
      else priceClr = CLR_FLAT;
   }

   double o = iOpen(_Symbol, PERIOD_CURRENT, 0);
   double h = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double l = iLow(_Symbol, PERIOD_CURRENT, 0);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   g_canvas.Erase(ColorToARGB(clrNONE, 0));

   //--- background + border
   g_canvas.FillRectangle(0, 0, g_panelW - 1, g_panelH - 1, ColorToARGB(CLR_BG, g_alpha));
   g_canvas.Rectangle(0, 0, g_panelW - 1, g_panelH - 1, ColorToARGB(CLR_BORDER, g_alpha));

   //--- big price
   g_canvas.FontSet("Arial", -260, FW_BOLD);
   g_canvas.TextOut(g_panelW / 2, 10, DoubleToString(last, digits), ColorToARGB(priceClr, g_alpha), TA_CENTER | TA_TOP);

   //--- OHLC
   g_canvas.FontSet("Arial", -110, FW_NORMAL);
   string ohlcLine1 = StringFormat("O: %s   H: %s", DoubleToString(o, digits), DoubleToString(h, digits));
   string ohlcLine2 = StringFormat("L: %s   C: %s", DoubleToString(l, digits), DoubleToString(last, digits));
   g_canvas.TextOut(10, 48, ohlcLine1, ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   g_canvas.TextOut(10, 64, ohlcLine2, ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);

   //--- 1M / 30M / 4H / 1D direction
   int tfY = 92;
   int colW = g_panelW / 4;
   ENUM_TIMEFRAMES tfs[4]   = { PERIOD_M1, PERIOD_M30, PERIOD_H4, PERIOD_D1 };
   string           tfLbl[4] = { "1M", "30M", "4H", "1D" };
   int ups = 0, downs = 0;
   g_canvas.FontSet("Arial", -100, FW_BOLD);
   for(int i = 0; i < 4; i++)
   {
      int cx = colW * i + colW / 2;
      color c = TFColor(tfs[i], last);
      string arrow = TFArrow(tfs[i], last);
      if(c == CLR_UP) ups++;
      else if(c == CLR_DOWN) downs++;
      g_canvas.TextOut(cx, tfY, tfLbl[i], ColorToARGB(CLR_MUTED, g_alpha), TA_CENTER | TA_TOP);
      g_canvas.TextOut(cx, tfY + 16, arrow, ColorToARGB(c, g_alpha), TA_CENTER | TA_TOP);
   }

   //--- suggestion: is BUY or SELL ideal right now, based on how many of
   //    the 4 timeframes agree (3 or 4 out of 4 the same direction = clear).
   string suggestion = "MIXED";
   color  suggestionClr = CLR_FLAT;
   if(ups >= 3) { suggestion = "BUY"; suggestionClr = CLR_UP; }
   else if(downs >= 3) { suggestion = "SELL"; suggestionClr = CLR_DOWN; }
   g_canvas.FontSet("Arial", -100, FW_NORMAL);
   g_canvas.TextOut(10, 136, "SUGGESTION:", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   g_canvas.FontSet("Arial", -140, FW_BOLD);
   g_canvas.TextOut(120, 132, suggestion, ColorToARGB(suggestionClr, g_alpha), TA_LEFT | TA_TOP);

   //--- YOUR SL / TP -- shown and edited as an ACTUAL PRICE (matching the
   //    chart's own price format), not an abstract pip count. Click a box,
   //    type the price you want, press Enter. The same price is drawn as a
   //    dashed line on the chart itself, so the box and the chart always
   //    show the same number.
   double slPrice, tpPrice, lastForSlTp; bool sellSide;
   ComputeSlTpPrices(slPrice, tpPrice, lastForSlTp, sellSide);

   //--- If this panel has exactly ONE real open position on this symbol,
   //    the boxes below show and edit THAT position's actual SL/TP instead
   //    of a hypothetical "next order" preview -- otherwise the box could
   //    show one number while your real, broker-side stop sits at a
   //    completely different price, which is exactly the "two stop-losses"
   //    confusion this is here to prevent.
   ulong  ownTicket; double ownSl, ownTp; long ownType;
   bool   haveOwnPos = GetOwnSinglePosition(ownTicket, ownSl, ownTp, ownType);
   bool   slIsPos = false, tpIsPos = false;
   if(haveOwnPos)
   {
      if(ownSl > 0) { slPrice = ownSl; slIsPos = true; }
      if(ownTp > 0) { tpPrice = ownTp; tpIsPos = true; }
   }

   int slX1, slY1, slX2, slY2, tpX1, tpY1, tpX2, tpY2, trX1, trY1, trX2, trY2, ttX1, ttY1, ttX2, ttY2;
   GetInputRects(slX1, slY1, slX2, slY2, tpX1, tpY1, tpX2, tpY2, trX1, trY1, trX2, trY2, ttX1, ttY1, ttX2, ttY2);

   g_canvas.FontSet("Arial", -90, FW_NORMAL);
   g_canvas.TextOut(slX1, 158, slIsPos ? "YOUR SL (open pos)" : "YOUR SL (price)", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   g_canvas.TextOut(tpX1, 158, tpIsPos ? "YOUR TP (open pos)" : "YOUR TP (price)", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);

   string slText = (g_editField == 1) ? g_editBuffer : ((haveOwnPos && !slIsPos) ? "(none)" : DoubleToString(slPrice, digits));
   string tpText = (g_editField == 2) ? g_editBuffer : ((haveOwnPos && !tpIsPos) ? "(none)" : DoubleToString(tpPrice, digits));
   DrawInputBox(slX1, slY1, slX2, slY2, slText, g_editField == 1);
   DrawInputBox(tpX1, tpY1, tpX2, tpY2, tpText, g_editField == 2);

   g_canvas.FontSet("Arial", -80, FW_NORMAL);
   g_canvas.TextOut(slX1, 206, "click a box, type the price, Enter", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);

   //--- estimated SL/TP: real dashed lines ON THE CHART itself, using the
   //    exact same price the boxes above show. If this is a real open
   //    position with NO real Stop-Loss/Take-Profit set, don't draw a
   //    preview line either -- a dashed "SL" line with no real stop behind
   //    it would be exactly the same false-confidence problem this fix is
   //    for.
   if(!haveOwnPos || slIsPos)
      UpdatePriceLine(g_slLineName, slPrice, CLR_DOWN, "NeonDesk SL  " + DoubleToString(slPrice, digits));
   else if(ObjectFind(0, g_slLineName) >= 0)
      ObjectDelete(0, g_slLineName);

   if(!haveOwnPos || tpIsPos)
      UpdatePriceLine(g_tpLineName, tpPrice, CLR_UP, "NeonDesk TP  " + DoubleToString(tpPrice, digits));
   else if(ObjectFind(0, g_tpLineName) >= 0)
      ObjectDelete(0, g_tpLineName);

   //--- TRAILING STOP -- distance in pips (a relative distance, so this one
   //    stays in pips rather than a price) + an ON/OFF button next to it.
   g_canvas.FontSet("Arial", -90, FW_NORMAL);
   g_canvas.TextOut(trX1, 222, "TRAILING STOP (pips)", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);

   string trailText = (g_editField == 3) ? g_editBuffer : DoubleToString(g_curTrailPips, 1);
   DrawInputBox(trX1, trY1, trX2, trY2, trailText, g_editField == 3);

   g_canvas.FillRectangle(ttX1, ttY1, ttX2, ttY2, ColorToARGB(g_trailEnabled ? CLR_BUY : CLR_BOXBG, g_alpha));
   g_canvas.Rectangle(ttX1, ttY1, ttX2, ttY2, ColorToARGB(CLR_BORDER, g_alpha));
   g_canvas.FontSet("Arial", -100, FW_BOLD);
   g_canvas.TextOut((ttX1 + ttX2) / 2, (ttY1 + ttY2) / 2, g_trailEnabled ? "TRAIL: ON" : "TRAIL: OFF",
                     ColorToARGB(g_trailEnabled ? CLR_BTNTXT : CLR_TEXT, g_alpha), TA_CENTER | TA_VCENTER);

   //--- MARKET INFO: fill the open space with useful, live information --
   //    spread, ATR(14) volatility, a SUGGESTED SL/TP (just a hint -- your
   //    own SL/TP boxes above remain entirely your own choice), an open
   //    position summary for positions THIS panel itself opened, and a
   //    live candle open/close countdown.
   int infoY = 288;
   g_canvas.FontSet("Arial", -100, FW_BOLD);
   g_canvas.TextOut(10, infoY, "MARKET INFO", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   g_canvas.FontSet("Arial", -100, FW_NORMAL);

   double spreadPips = (pip > 0) ? (ask - bid) / pip : 0.0;
   g_canvas.TextOut(10, infoY + 20, StringFormat("Spread: %.1f pips", spreadPips), ColorToARGB(CLR_TEXT, g_alpha), TA_LEFT | TA_TOP);

   double sugSl, sugTp;
   if(GetSuggestedSlTpPips(sugSl, sugTp))
   {
      g_canvas.TextOut(10, infoY + 38, StringFormat("ATR(14) volatility: %.1f pips", sugSl / InpAtrSlMult), ColorToARGB(CLR_TEXT, g_alpha), TA_LEFT | TA_TOP);
      g_canvas.FontSet("Arial", -110, FW_BOLD);
      g_canvas.TextOut(10, infoY + 58, StringFormat("Suggested: SL ~%.1f / TP ~%.1f pips", sugSl, sugTp), ColorToARGB(CLR_HINT, g_alpha), TA_LEFT | TA_TOP);
      g_canvas.FontSet("Arial", -90, FW_NORMAL);
      g_canvas.TextOut(10, infoY + 76, "(just a hint -- your own SL/TP above still applies)", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   }
   else
   {
      g_canvas.TextOut(10, infoY + 38, "ATR not available yet...", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   }

   int posCount; double posPl;
   GetOwnPositions(posCount, posPl);
   g_canvas.FontSet("Arial", -100, FW_NORMAL);
   color plClr = (posPl > 0) ? CLR_UP : (posPl < 0 ? CLR_DOWN : CLR_MUTED);
   int posY = infoY + 98;
   g_canvas.TextOut(10, posY, StringFormat("Open (this panel): %d position(s)", posCount), ColorToARGB(CLR_TEXT, g_alpha), TA_LEFT | TA_TOP);
   posY += 18;
   if(posCount > 0)
   {
      g_canvas.TextOut(10, posY, StringFormat("P&L: %.2f", posPl), ColorToARGB(plClr, g_alpha), TA_LEFT | TA_TOP);
      posY += 18;
   }
   posY += 6;

   //--- Live candle open/close countdown, for the timeframe YOU chose in
   //    InpCountdownTF (Inputs tab) -- independent of the chart's own period.
   ENUM_TIMEFRAMES countdownTf = CountdownTimeframe();
   datetime barOpen   = iTime(_Symbol, countdownTf, 0);
   int      periodSec = PeriodSeconds(countdownTf);
   datetime barClose  = barOpen + periodSec;
   long     remain    = (long)(barClose - TimeCurrent());
   if(remain < 0) remain = 0;
   int rh = (int)(remain / 3600);
   int rm = (int)((remain % 3600) / 60);
   int rs = (int)(remain % 60);
   g_canvas.FontSet("Arial", -100, FW_BOLD);
   g_canvas.TextOut(10, posY, "CANDLE TIME (" + PeriodLabel(countdownTf) + ")", ColorToARGB(CLR_MUTED, g_alpha), TA_LEFT | TA_TOP);
   posY += 20;
   g_canvas.FontSet("Arial", -100, FW_NORMAL);
   g_canvas.TextOut(10, posY, "Opened: " + TimeToString(barOpen, TIME_MINUTES | TIME_SECONDS), ColorToARGB(CLR_TEXT, g_alpha), TA_LEFT | TA_TOP);
   posY += 18;
   g_canvas.FontSet("Arial", -110, FW_BOLD);
   g_canvas.TextOut(10, posY, StringFormat("Closes in: %02d:%02d:%02d", rh, rm, rs), ColorToARGB(CLR_HINT, g_alpha), TA_LEFT | TA_TOP);
   posY += 22;

   //--- buttons (bottom-anchored positions, scale with g_panelW/H)
   int buyX1, buyY1, buyX2, buyY2, sellX1, sellY1, sellX2, sellY2, closeX1, closeY1, closeX2, closeY2;
   GetButtonRects(buyX1, buyY1, buyX2, buyY2, sellX1, sellY1, sellX2, sellY2, closeX1, closeY1, closeX2, closeY2);

   //--- Standing risk notice, always visible just above the buttons: BUY,
   //    SELL and CLOSE ALL execute real trades with real funds, and the
   //    SL/TP you set (and the suggestion/hint shown above) are your own
   //    responsibility, not a guarantee. The full disclaimer is shown once,
   //    and must be accepted, when the panel is first attached (OnInit).
   g_canvas.FontSet("Arial", -80, FW_NORMAL);
   g_canvas.TextOut(g_panelW / 2, buyY1 - 16, "Real funds. You choose your SL/TP -- trade at your own risk.",
                     ColorToARGB(CLR_MUTED, g_alpha), TA_CENTER | TA_TOP);

   g_canvas.FillRectangle(buyX1, buyY1, buyX2, buyY2, ColorToARGB(CLR_BUY, g_alpha));
   g_canvas.FillRectangle(sellX1, sellY1, sellX2, sellY2, ColorToARGB(CLR_SELL, g_alpha));
   g_canvas.FillRectangle(closeX1, closeY1, closeX2, closeY2, ColorToARGB(CLR_CLOSE, g_alpha));

   g_canvas.FontSet("Arial", -130, FW_BOLD);
   g_canvas.TextOut((buyX1 + buyX2) / 2, (buyY1 + buyY2) / 2, "BUY", ColorToARGB(CLR_BTNTXT, g_alpha), TA_CENTER | TA_VCENTER);
   g_canvas.TextOut((sellX1 + sellX2) / 2, (sellY1 + sellY2) / 2, "SELL", ColorToARGB(CLR_BTNTXT, g_alpha), TA_CENTER | TA_VCENTER);
   g_canvas.FontSet("Arial", -110, FW_BOLD);
   g_canvas.TextOut((closeX1 + closeX2) / 2, (closeY1 + closeY2) / 2, "CLOSE ALL (this panel)", ColorToARGB(CLR_BTNTXT, g_alpha), TA_CENTER | TA_VCENTER);

   g_canvas.Update();
   g_prevPrice = last;
}

//+------------------------------------------------------------------+
//| Creates/updates a horizontal dashed price line ON THE CHART itself.|
//+------------------------------------------------------------------+
void UpdatePriceLine(string name, double price, color clr, string text)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, text);
}

//+------------------------------------------------------------------+
//  Works out the actual entry/SL/TP prices a BUY or SELL button press
//  would use right now, from the user's own pip-distance settings.
//+------------------------------------------------------------------+
void ComputeOrderSlTp(bool isBuy, double &entryOut, double &slOut, double &tpOut)
{
   double pip = PipSize();
   if(isBuy)
   {
      entryOut = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      slOut    = (g_curSlPips > 0) ? entryOut - g_curSlPips * pip : 0.0;
      tpOut    = (g_curTpPips > 0) ? entryOut + g_curTpPips * pip : 0.0;
   }
   else
   {
      entryOut = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      slOut    = (g_curSlPips > 0) ? entryOut + g_curSlPips * pip : 0.0;
      tpOut    = (g_curTpPips > 0) ? entryOut - g_curTpPips * pip : 0.0;
   }
}

//+------------------------------------------------------------------+
//  Refuses an order whose SL/TP is on the wrong side of the entry
//  price (which would lock in an instant loss, or is simply not a
//  valid stop for that direction), or closer to entry than this
//  broker/symbol's own minimum stop distance allows.
//+------------------------------------------------------------------+
bool ValidateOrderStops(bool isBuy, double entry, double sl, double tp, string &errMsg)
{
   int    stopsLevelPts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point         = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double minDist       = MathMax(stopsLevelPts, 1) * point;
   int    digits        = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(isBuy)
   {
      if(sl > 0 && sl >= entry)
      {
         errMsg = "Your Stop-Loss is set at or above the entry price for a BUY. That would lock in a loss the moment you enter -- move your SL below the entry price first.";
         return false;
      }
      if(tp > 0 && tp <= entry)
      {
         errMsg = "Your Take-Profit is set at or below the entry price for a BUY. That is the wrong side of the trade -- move your TP above the entry price first.";
         return false;
      }
      if(sl > 0 && (entry - sl) < minDist)
      {
         errMsg = StringFormat("Your Stop-Loss is closer to the entry price than this broker allows for %s (minimum stop distance: %d points / %s). Move it further away.",
                                _Symbol, stopsLevelPts, DoubleToString(minDist, digits));
         return false;
      }
      if(tp > 0 && (tp - entry) < minDist)
      {
         errMsg = StringFormat("Your Take-Profit is closer to the entry price than this broker allows for %s (minimum stop distance: %d points / %s). Move it further away.",
                                _Symbol, stopsLevelPts, DoubleToString(minDist, digits));
         return false;
      }
   }
   else
   {
      if(sl > 0 && sl <= entry)
      {
         errMsg = "Your Stop-Loss is set at or below the entry price for a SELL. That would lock in a loss the moment you enter -- move your SL above the entry price first.";
         return false;
      }
      if(tp > 0 && tp >= entry)
      {
         errMsg = "Your Take-Profit is set at or above the entry price for a SELL. That is the wrong side of the trade -- move your TP below the entry price first.";
         return false;
      }
      if(sl > 0 && (sl - entry) < minDist)
      {
         errMsg = StringFormat("Your Stop-Loss is closer to the entry price than this broker allows for %s (minimum stop distance: %d points / %s). Move it further away.",
                                _Symbol, stopsLevelPts, DoubleToString(minDist, digits));
         return false;
      }
      if(tp > 0 && (entry - tp) < minDist)
      {
         errMsg = StringFormat("Your Take-Profit is closer to the entry price than this broker allows for %s (minimum stop distance: %d points / %s). Move it further away.",
                                _Symbol, stopsLevelPts, DoubleToString(minDist, digits));
         return false;
      }
   }
   return true;
}

bool DoBuy(double entry, double sl, double tp)
{
   g_trade.SetExpertMagicNumber(InpMagic);
   return g_trade.Buy(InpLotSize, _Symbol, entry, sl, tp, "NeonDesk");
}

bool DoSell(double entry, double sl, double tp)
{
   g_trade.SetExpertMagicNumber(InpMagic);
   return g_trade.Sell(InpLotSize, _Symbol, entry, sl, tp, "NeonDesk");
}

//--- Closes every position belonging to THIS panel (own magic, own symbol)
//    and reports back exactly what happened -- how many closed, how many
//    FAILED, and the total volume closed -- so a failed close (e.g. "no
//    connection") is never silent, and the caller can show the user a
//    proper success/failure message instead of just hoping it worked.
void DoCloseAll(int &closedCount, int &failCount, double &closedVol)
{
   closedCount = 0;
   failCount   = 0;
   closedVol   = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      double vol = PositionGetDouble(POSITION_VOLUME);
      if(g_trade.PositionClose(ticket))
      {
         closedCount++;
         closedVol += vol;
      }
      else
      {
         failCount++;
      }
   }
}

//+------------------------------------------------------------------+
int OnInit()
{
   //--- Risk disclaimer -- shown once, must be accepted, before the panel
   //    becomes active. Cancelling stops the EA from loading at all.
   //    Skipped in the Strategy Tester: MessageBox() does not wait for a
   //    real click there (it returns immediately), which would otherwise
   //    always look like "Cancel" and stop the EA from ever loading during
   //    a backtest -- no real account or real funds are involved there.
   if(!MQLInfoInteger(MQL_TESTER))
   {
      int ack = MessageBox(
         "NeonDesk is a manual trading tool: every BUY, SELL and CLOSE ALL action you take on this panel places or closes a REAL trade using REAL funds in this account.\n\n"
         "You are solely responsible for choosing your own Stop-Loss and Take-Profit levels. The suggested SL/TP, the multi-timeframe bias and any other indication shown on this panel are informational only -- they are not financial advice and do not guarantee any outcome.\n\n"
         "By clicking OK you confirm you understand this and accept full responsibility for your own trading decisions. NeonDesk and its author accept no liability for any trade, loss, or decision made using this tool.\n\n"
         "Click Cancel if you do not wish to load this panel.",
         "NeonDesk -- Risk Disclaimer", MB_OKCANCEL | MB_ICONWARNING | MB_DEFBUTTON2);
      if(ack != IDOK)
      {
         Print("NeonDesk: risk disclaimer was not accepted -- the panel will not load.");
         return(INIT_FAILED);
      }
      PrintFormat("NeonDesk: risk disclaimer accepted for %s at %s.", _Symbol, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   }

   g_panelName       = "NeonDesk_BG_"     + IntegerToString(ChartID());
   g_handleName      = "NeonDesk_Handle_" + IntegerToString(ChartID());
   g_handleLabelName = "NeonDesk_HTxt_"   + IntegerToString(ChartID());
   g_closeXName      = "NeonDesk_CloseX_" + IntegerToString(ChartID());
   g_resizeName      = "NeonDesk_Resize_" + IntegerToString(ChartID());
   g_slLineName      = "NeonDesk_SLLine_" + IntegerToString(ChartID());
   g_tpLineName      = "NeonDesk_TPLine_" + IntegerToString(ChartID());
   g_handleH    = MathMax(18, InpHandleHeight);
   g_panelW     = MathMax(MIN_PANEL_W, InpPanelW);
   g_panelH     = MathMax(MIN_PANEL_H, InpPanelH);

   //--- Start from your saved settings if this symbol/magic ever ran
   //    before (e.g. you accidentally removed the panel and are now
   //    re-attaching it) -- otherwise these all just keep the plain
   //    input-parameter defaults, exactly as before.
   int startX = InpPanelX, startY = InpPanelY;
   LoadSavedPanelRect(startX, startY, g_panelW, g_panelH);

   g_curSlPips    = InpSlPips;
   g_curTpPips    = InpTpPips;
   g_curTrailPips = InpTrailPips;
   g_trailEnabled = InpTrailEnabledAtStart;
   LoadSavedTradingSettings();
   g_editField    = 0;
   g_editBuffer   = "";

   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);

   //--- 1) Drag bar: a REAL OBJ_RECTANGLE_LABEL. Dragging is tracked
   //    MANUALLY in OnChartEvent (see the comment there).
   if(!ObjectCreate(0, g_handleName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      PrintFormat("NeonDesk: could not create drag bar (error=%d).", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, g_handleName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_handleName, OBJPROP_XDISTANCE, startX);
   ObjectSetInteger(0, g_handleName, OBJPROP_YDISTANCE, startY);
   ObjectSetInteger(0, g_handleName, OBJPROP_XSIZE, g_panelW - CLOSEX_W - CLOSEX_MARGIN - 2);
   ObjectSetInteger(0, g_handleName, OBJPROP_YSIZE, g_handleH);
   ObjectSetInteger(0, g_handleName, OBJPROP_BGCOLOR, CLR_HANDLE);
   ObjectSetInteger(0, g_handleName, OBJPROP_COLOR, CLR_BORDER);
   ObjectSetInteger(0, g_handleName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, g_handleName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_handleName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, g_handleName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_handleName, OBJPROP_ZORDER, 10);

   if(!ObjectCreate(0, g_handleLabelName, OBJ_LABEL, 0, 0, 0))
   {
      PrintFormat("NeonDesk: could not create drag bar title (error=%d).", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, g_handleLabelName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_COLOR, CLR_TEXT);
   ObjectSetString(0, g_handleLabelName, OBJPROP_TEXT, "||||  NeonDesk -- " + _Symbol);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_handleLabelName, OBJPROP_ZORDER, 11);

   //--- 2) X: just closes the panel (removes the EA), never touches any trade.
   if(!ObjectCreate(0, g_closeXName, OBJ_BUTTON, 0, 0, 0))
   {
      PrintFormat("NeonDesk: could not create X button (error=%d).", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, g_closeXName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_closeXName, OBJPROP_XSIZE, CLOSEX_W);
   ObjectSetInteger(0, g_closeXName, OBJPROP_YSIZE, g_handleH - 2 * CLOSEX_MARGIN);
   ObjectSetInteger(0, g_closeXName, OBJPROP_BGCOLOR, CLR_SELL);
   ObjectSetInteger(0, g_closeXName, OBJPROP_COLOR, clrWhite);
   ObjectSetString(0, g_closeXName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, g_closeXName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_closeXName, OBJPROP_TEXT, "X");
   ObjectSetInteger(0, g_closeXName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_closeXName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, g_closeXName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_closeXName, OBJPROP_ZORDER, 20);

   //--- 3) The trading body itself (price/OHLC/SL/TP/Trail/info/buttons) --
   //    everything below the drag bar is drawn on THIS ONE canvas, so there
   //    is no separate "strip" to visually split from it any more, and no
   //    native edit box for anything to steal focus from.
   if(!g_canvas.CreateBitmapLabel(g_panelName, startX, startY + g_handleH, g_panelW, g_panelH, COLOR_FORMAT_ARGB_NORMALIZE))
   {
      PrintFormat("NeonDesk: could not create panel canvas (error=%d).", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, g_panelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_panelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, g_panelName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_ZORDER, 0);

   //--- 4) Resize grip, bottom-right.
   if(!ObjectCreate(0, g_resizeName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      PrintFormat("NeonDesk: could not create resize grip (error=%d).", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, g_resizeName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_resizeName, OBJPROP_XSIZE, GRIP_SIZE);
   ObjectSetInteger(0, g_resizeName, OBJPROP_YSIZE, GRIP_SIZE);
   ObjectSetInteger(0, g_resizeName, OBJPROP_BGCOLOR, CLR_GRIP);
   ObjectSetInteger(0, g_resizeName, OBJPROP_COLOR, CLR_BG);
   ObjectSetInteger(0, g_resizeName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, g_resizeName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_resizeName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, g_resizeName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_resizeName, OBJPROP_ZORDER, 30);

   //--- 5) Estimated SL/TP lines on the chart itself (see UpdatePriceLine/DrawPanel)
   ObjectCreate(0, g_slLineName, OBJ_HLINE, 0, 0, SymbolInfoDouble(_Symbol, SYMBOL_BID));
   ObjectCreate(0, g_tpLineName, OBJ_HLINE, 0, 0, SymbolInfoDouble(_Symbol, SYMBOL_BID));

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   g_trade.SetExpertMagicNumber(InpMagic);

   //--- 1-second timer so the candle countdown updates live even on a
   //    quiet symbol with no incoming ticks.
   EventSetTimer(1);

   g_alpha = 255;
   g_hover = true;
   g_prevPrice = 0.0;
   SyncPositions();
   DrawPanel();
   ChartRedraw();

   PrintFormat("NeonDesk READY version=1.19 chart=%s lot=%.2f sl=%.1fpips tp=%.1fpips magic=%d fadedOpacity=%d%% size=%dx%d countdownTF=%s.",
      _Symbol, InpLotSize, InpSlPips, InpTpPips, InpMagic, InpFadedOpacityPct, g_panelW, g_panelH, PeriodLabel(CountdownTimeframe()));
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Save first, before any object is deleted -- this runs for EVERY
   //    removal reason (the X button, "Remove", a chart/profile/template
   //    change, even MetaTrader shutting down), so an accidental removal
   //    never wipes out your SL/TP preset, trailing stop, or where you had
   //    the panel positioned/sized.
   SaveSettings();

   EventKillTimer();
   ObjectDelete(0, g_panelName);
   ObjectDelete(0, g_handleName);
   ObjectDelete(0, g_handleLabelName);
   ObjectDelete(0, g_closeXName);
   ObjectDelete(0, g_resizeName);
   ObjectDelete(0, g_slLineName);
   ObjectDelete(0, g_tpLineName);
   g_canvas.Destroy();
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
}

//+------------------------------------------------------------------+
void OnTick()
{
   ApplyTrailingStop();
   DrawPanel();
}

//+------------------------------------------------------------------+
//| Keeps the candle countdown ticking every second even when the     |
//| symbol is quiet and no new price tick has arrived.                |
//+------------------------------------------------------------------+
void OnTimer()
{
   DrawPanel();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   //--- X clicked? (a real OBJECT_CLICK event, always reliable)
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == g_closeXName)
   {
      ExpertRemove();   // just closes the panel -- never touches any open trade
      return;
   }

   //--- Keyboard input for whichever box (SL/TP price, or Trail pips) is
   //    currently being edited. There is no native edit box anywhere on
   //    this panel -- typing is captured directly here instead, which
   //    sidesteps the focus problems native OBJ_EDIT kept running into.
   if(id == CHARTEVENT_KEYDOWN)
   {
      if(g_editField == 0) return;
      int key = (int)lparam;

      if(key == 8)          // Backspace
      {
         int len = StringLen(g_editBuffer);
         if(len > 0) g_editBuffer = StringSubstr(g_editBuffer, 0, len - 1);
      }
      else if(key == 13)    // Enter -- confirm
      {
         ConfirmEdit();
      }
      else if(key == 27)    // Escape -- cancel, keep the old value
      {
         g_editField = 0;
         g_editBuffer = "";
      }
      else if((key >= 48 && key <= 57) || (key >= 96 && key <= 105))   // digits, main row or numpad
      {
         if(StringLen(g_editBuffer) < 12)
         {
            int d = (key >= 96) ? (key - 96) : (key - 48);
            g_editBuffer += IntegerToString(d);
         }
      }
      else if(key == 190 || key == 110)   // '.' main row or numpad decimal point
      {
         if(StringFind(g_editBuffer, ".") < 0) g_editBuffer += ".";
      }
      DrawPanel();
      ChartRedraw();
      return;
   }

   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      bool leftDown = ((int)StringToInteger(sparam) & 1) == 1;

      //--- a fresh mouse press (not already held) -- decide whether it
      //    started on the drag bar or the resize corner.
      if(leftDown && !g_prevLeftDown && !g_draggingHandle && !g_resizing)
      {
         int hx = GetHandleX();
         int hy = GetHandleY();
         int handleW = (int)ObjectGetInteger(0, g_handleName, OBJPROP_XSIZE);
         int gx = (int)ObjectGetInteger(0, g_resizeName, OBJPROP_XDISTANCE);
         int gy = (int)ObjectGetInteger(0, g_resizeName, OBJPROP_YDISTANCE);

         if(x >= gx - 6 && x <= gx + GRIP_SIZE + 6 && y >= gy - 6 && y <= gy + GRIP_SIZE + 6)
         {
            g_resizing        = true;
            g_dragStartMouseX = x;
            g_dragStartMouseY = y;
            g_resizeStartW    = g_panelW;
            g_resizeStartH    = g_panelH;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);   // keep the chart still while resizing
         }
         else if(x >= hx && x <= hx + handleW && y >= hy && y <= hy + g_handleH)
         {
            g_draggingHandle  = true;
            g_dragStartMouseX = x;
            g_dragStartMouseY = y;
            g_dragStartPanelX = hx;
            g_dragStartPanelY = hy;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);   // keep the chart still while dragging
         }
      }

      if(leftDown && g_draggingHandle)
      {
         int newX = g_dragStartPanelX + (x - g_dragStartMouseX);
         int newY = g_dragStartPanelY + (y - g_dragStartMouseY);
         ObjectSetInteger(0, g_handleName, OBJPROP_XDISTANCE, newX);
         ObjectSetInteger(0, g_handleName, OBJPROP_YDISTANCE, newY);
         SyncPositions();
         ChartRedraw();
      }
      else if(leftDown && g_resizing)
      {
         int newW = MathMax(MIN_PANEL_W, g_resizeStartW + (x - g_dragStartMouseX));
         int newH = MathMax(MIN_PANEL_H, g_resizeStartH + (y - g_dragStartMouseY));
         if(newW != g_panelW || newH != g_panelH)
         {
            g_panelW = newW;
            g_panelH = newH;
            g_canvas.Resize(g_panelW, g_panelH);
            SyncPositions();
            DrawPanel();
         }
      }
      else if(!g_draggingHandle && !g_resizing)
      {
         //--- normal hover-fade (the whole tool, not just the canvas) --
         //    stays at full opacity while a box is being edited, so you can
         //    always see what you're typing even if the mouse drifts off.
         int hx = GetHandleX();
         int hy = GetHandleY();
         int px = (int)ObjectGetInteger(0, g_panelName, OBJPROP_XDISTANCE);
         int py = (int)ObjectGetInteger(0, g_panelName, OBJPROP_YDISTANCE);
         bool inside = (x >= hx && x <= hx + g_panelW && y >= hy && y <= py + g_panelH);
         if(g_editField != 0)
         {
            if(g_alpha != 255) { g_alpha = 255; DrawPanel(); }
            g_hover = true;
         }
         else if(inside != g_hover)
         {
            g_hover = inside;
            uchar fadedAlpha = (uchar)MathMax(0, MathMin(255, (int)MathRound(255.0 * InpFadedOpacityPct / 100.0)));
            g_alpha = inside ? 255 : fadedAlpha;
            DrawPanel();
         }
      }

      if(!leftDown)
      {
         if(g_draggingHandle || g_resizing)
         {
            ChartSetInteger(0, CHART_MOUSE_SCROLL, true);   // give normal chart panning back
            SaveSettings();   // remember the new position/size in case of an accidental removal
         }
         g_draggingHandle = false;
         g_resizing       = false;
      }
      g_prevLeftDown = leftDown;
      return;
   }

   if(id == CHARTEVENT_CLICK)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      int px = (int)ObjectGetInteger(0, g_panelName, OBJPROP_XDISTANCE);
      int py = (int)ObjectGetInteger(0, g_panelName, OBJPROP_YDISTANCE);
      int lx = x - px;
      int ly = y - py;
      bool insideCanvas = (lx >= 0 && lx <= g_panelW && ly >= 0 && ly <= g_panelH);

      //--- Clicking ANYWHERE confirms whatever box was being edited (like
      //    clicking away from a normal form field commits it). Whatever the
      //    click does next (open a different box, click BUY, or nothing)
      //    happens afterwards, using the just-confirmed value.
      if(g_editField != 0) ConfirmEdit();

      if(!insideCanvas) return;

      int slX1, slY1, slX2, slY2, tpX1, tpY1, tpX2, tpY2, trX1, trY1, trX2, trY2, ttX1, ttY1, ttX2, ttY2;
      GetInputRects(slX1, slY1, slX2, slY2, tpX1, tpY1, tpX2, tpY2, trX1, trY1, trX2, trY2, ttX1, ttY1, ttX2, ttY2);

      int buyX1, buyY1, buyX2, buyY2, sellX1, sellY1, sellX2, sellY2, closeX1, closeY1, closeX2, closeY2;
      GetButtonRects(buyX1, buyY1, buyX2, buyY2, sellX1, sellY1, sellX2, sellY2, closeX1, closeY1, closeX2, closeY2);

      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

      if(lx >= slX1 && lx <= slX2 && ly >= slY1 && ly <= slY2)
      {
         double slPrice, tpPrice, lastP; bool sellSide;
         ComputeSlTpPrices(slPrice, tpPrice, lastP, sellSide);
         g_editField = 1;
         g_editBuffer = DoubleToString(slPrice, digits);
      }
      else if(lx >= tpX1 && lx <= tpX2 && ly >= tpY1 && ly <= tpY2)
      {
         double slPrice, tpPrice, lastP; bool sellSide;
         ComputeSlTpPrices(slPrice, tpPrice, lastP, sellSide);
         g_editField = 2;
         g_editBuffer = DoubleToString(tpPrice, digits);
      }
      else if(lx >= trX1 && lx <= trX2 && ly >= trY1 && ly <= trY2)
      {
         g_editField = 3;
         g_editBuffer = DoubleToString(g_curTrailPips, 1);
      }
      else if(lx >= ttX1 && lx <= ttX2 && ly >= ttY1 && ly <= ttY2)
      {
         g_trailEnabled = !g_trailEnabled;
         if(g_trailEnabled)
         {
            double floorPips = MinTrailPips();
            if(g_curTrailPips < floorPips)
            {
               double oldPips = g_curTrailPips;
               g_curTrailPips = floorPips;
               MessageBox(StringFormat(
                  "Your Trail distance of %s pips is tighter than %s's own minimum stop distance. "
                  "It has been raised to %s pips so the trailing stop can't be taken out almost instantly by normal price movement.",
                  DoubleToString(oldPips, 1), _Symbol, DoubleToString(floorPips, 1)),
                  "NeonDesk -- Trail Distance Raised", MB_OK | MB_ICONWARNING);
            }
         }
         SaveSettings();
      }
      else if(lx >= buyX1 && lx <= buyX2 && ly >= buyY1 && ly <= buyY2)
      {
         double entry, sl, tp;
         ComputeOrderSlTp(true, entry, sl, tp);
         string errMsg;
         if(!ValidateOrderStops(true, entry, sl, tp, errMsg))
         {
            MessageBox(errMsg, "NeonDesk -- Stop Levels Rejected", MB_OK | MB_ICONERROR);
         }
         else
         {
            bool proceed = true;
            int existingCount; double existingVol;
            GetOwnPositionsVolume(existingCount, existingVol);
            if(existingCount > 0)
            {
               string warn = StringFormat(
                  "This panel already has %d open trade(s) on %s, totalling %.2f lot(s).\n\nOpening another BUY of %.2f lot(s) will bring your total exposure on this symbol to %.2f lot(s) and use additional margin.\n\n%s\n\nAre you sure you want to open another trade on the same chart?",
                  existingCount, _Symbol, existingVol, InpLotSize, existingVol + InpLotSize, BrokerModeNote());
               if(MessageBox(warn, "NeonDesk -- Existing Position Warning", MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2) != IDYES)
                  proceed = false;
            }
            if(proceed)
            {
               string q = StringFormat(
                  "Place a BUY order?\n\nSymbol:  %s\nLot size:  %.2f\nEntry (ask):  %s\nStop-Loss:  %s\nTake-Profit:  %s\n\nThis will use REAL funds in this account. You are responsible for these levels.",
                  _Symbol, InpLotSize, DoubleToString(entry, digits),
                  (sl > 0) ? DoubleToString(sl, digits) : "(none)",
                  (tp > 0) ? DoubleToString(tp, digits) : "(none)");
               if(MessageBox(q, "NeonDesk -- Confirm BUY", MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) == IDYES)
               {
                  if(DoBuy(entry, sl, tp))
                     MessageBox("BUY order placed successfully.", "NeonDesk", MB_OK | MB_ICONINFORMATION);
                  else
                     MessageBox(StringFormat("BUY order failed: %s (retcode %d)", g_trade.ResultRetcodeDescription(), g_trade.ResultRetcode()),
                                "NeonDesk -- Order Failed", MB_OK | MB_ICONERROR);
               }
            }
         }
      }
      else if(lx >= sellX1 && lx <= sellX2 && ly >= sellY1 && ly <= sellY2)
      {
         double entry, sl, tp;
         ComputeOrderSlTp(false, entry, sl, tp);
         string errMsg;
         if(!ValidateOrderStops(false, entry, sl, tp, errMsg))
         {
            MessageBox(errMsg, "NeonDesk -- Stop Levels Rejected", MB_OK | MB_ICONERROR);
         }
         else
         {
            bool proceed = true;
            int existingCount; double existingVol;
            GetOwnPositionsVolume(existingCount, existingVol);
            if(existingCount > 0)
            {
               string warn = StringFormat(
                  "This panel already has %d open trade(s) on %s, totalling %.2f lot(s).\n\nOpening another SELL of %.2f lot(s) will bring your total exposure on this symbol to %.2f lot(s) and use additional margin.\n\n%s\n\nAre you sure you want to open another trade on the same chart?",
                  existingCount, _Symbol, existingVol, InpLotSize, existingVol + InpLotSize, BrokerModeNote());
               if(MessageBox(warn, "NeonDesk -- Existing Position Warning", MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2) != IDYES)
                  proceed = false;
            }
            if(proceed)
            {
               string q = StringFormat(
                  "Place a SELL order?\n\nSymbol:  %s\nLot size:  %.2f\nEntry (bid):  %s\nStop-Loss:  %s\nTake-Profit:  %s\n\nThis will use REAL funds in this account. You are responsible for these levels.",
                  _Symbol, InpLotSize, DoubleToString(entry, digits),
                  (sl > 0) ? DoubleToString(sl, digits) : "(none)",
                  (tp > 0) ? DoubleToString(tp, digits) : "(none)");
               if(MessageBox(q, "NeonDesk -- Confirm SELL", MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) == IDYES)
               {
                  if(DoSell(entry, sl, tp))
                     MessageBox("SELL order placed successfully.", "NeonDesk", MB_OK | MB_ICONINFORMATION);
                  else
                     MessageBox(StringFormat("SELL order failed: %s (retcode %d)", g_trade.ResultRetcodeDescription(), g_trade.ResultRetcode()),
                                "NeonDesk -- Order Failed", MB_OK | MB_ICONERROR);
               }
            }
         }
      }
      else if(lx >= closeX1 && lx <= closeX2 && ly >= closeY1 && ly <= closeY2)
      {
         int ownCount; double ownVol;
         GetOwnPositionsVolume(ownCount, ownVol);
         if(ownCount == 0)
         {
            MessageBox(StringFormat("There are no open trades from this panel on %s to close.", _Symbol),
                       "NeonDesk -- Close All", MB_OK | MB_ICONINFORMATION);
         }
         else
         {
            string q = StringFormat(
               "Close ALL %d open trade(s) from this panel on %s, totalling %.2f lot(s)?\n\nThis will use REAL funds in this account.",
               ownCount, _Symbol, ownVol);
            if(MessageBox(q, "NeonDesk -- Confirm CLOSE ALL", MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2) == IDYES)
            {
               int closedCount, failCount; double closedVol;
               DoCloseAll(closedCount, failCount, closedVol);
               if(failCount == 0)
                  MessageBox(StringFormat("Closed %d trade(s), %.2f lot(s), successfully.", closedCount, closedVol),
                             "NeonDesk", MB_OK | MB_ICONINFORMATION);
               else
                  MessageBox(StringFormat(
                     "Closed %d trade(s) (%.2f lot(s)). %d trade(s) FAILED to close -- check your Trade tab.\n\nLast error: %s (retcode %d)",
                     closedCount, closedVol, failCount, g_trade.ResultRetcodeDescription(), g_trade.ResultRetcode()),
                     "NeonDesk -- Close All -- Partial Failure", MB_OK | MB_ICONERROR);
            }
         }
      }

      DrawPanel();
      ChartRedraw();
      return;
   }
}
//+------------------------------------------------------------------+
