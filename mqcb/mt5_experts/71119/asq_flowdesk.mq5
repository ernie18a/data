//+------------------------------------------------------------------+
//|                                              ASQ_FlowDesk.mq5    |
//|                           Copyright 2026, AlgoSphere Quant       |
//|                    https://www.mql5.com/en/users/robin2.0        |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, AlgoSphere Quant"
#property link        "https://www.mql5.com/en/users/robin2.0"
#property version     "1.00"
#property description "FlowDesk — Streamlined execution & position management."
#property description "One-click entries, scaled exits, adaptive trailing,"
#property description "auto-breakeven, and a live analytics dashboard."
#property description "AlgoSphere Quant — Engineered for clarity."

//+------------------------------------------------------------------+
//| Library imports                                                    |
//+------------------------------------------------------------------+
#include <Trade/AccountInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Type definitions                                                   |
//+------------------------------------------------------------------+
enum ENUM_SIZING_METHOD
  {
   SIZING_LOTS       = 0,   // Manual lot size
   SIZING_PCT_EQUITY = 1,   // % of equity at risk
   SIZING_FIXED_CASH = 2    // Fixed cash at risk
  };

enum ENUM_TRAIL_STYLE
  {
   STYLE_DISABLED    = 0,   // Trailing off
   STYLE_DISTANCE    = 1,   // Fixed-distance trail
   STYLE_VOLATILITY  = 2,   // ATR-adaptive trail
   STYLE_STRUCTURE   = 3    // Prior-bar high/low trail
  };

//+------------------------------------------------------------------+
//| User parameters                                                    |
//+------------------------------------------------------------------+
input group              "─────  Position Sizing  ─────"
input ENUM_SIZING_METHOD Sizing_Method     = SIZING_PCT_EQUITY; // Sizing method
input double   Sizing_ManualLots           = 0.01;   // Manual lot size
input double   Sizing_RiskPercent          = 1.0;    // Risk % of equity
input double   Sizing_RiskCash            = 100.0;   // Risk amount ($)

input group              "─────  Exit Levels  ─────"
input int      Exit_StopLoss              = 200;     // Stop-loss distance (pts, 0=none)
input int      Exit_Target1               = 150;     // Target 1 distance (pts, 0=off)
input int      Exit_Target2               = 300;     // Target 2 distance (pts, 0=off)
input int      Exit_Target3               = 500;     // Target 3 distance (pts, 0=off)
input double   Exit_T1_Fraction           = 40.0;    // Target 1 — close % of size
input double   Exit_T2_Fraction           = 30.0;    // Target 2 — close % of size
input double   Exit_T3_Fraction           = 100.0;   // Target 3 — close remainder %

input group              "─────  Trailing  ─────"
input ENUM_TRAIL_STYLE Trail_Style        = STYLE_VOLATILITY; // Trailing method
input int      Trail_Distance             = 150;     // Fixed trail distance (pts)
input int      Trail_MinStep              = 10;      // Minimum SL step (pts)
input int      Trail_ATR_Len              = 14;      // ATR lookback bars
input double   Trail_ATR_Scale            = 1.5;     // ATR multiplier
input bool     AutoBE_Active              = true;    // Auto-breakeven on/off
input int      AutoBE_Trigger             = 100;     // Breakeven trigger (pts in profit)
input int      AutoBE_Cushion             = 5;       // Breakeven cushion above entry (pts)

input group              "─────  Pending Orders  ─────"
input int      Pend_Gap                   = 100;     // Distance from current price (pts)
input int      Pend_SL                    = 200;     // Pending SL (pts)
input int      Pend_TP                    = 400;     // Pending TP (pts)
input datetime Pend_Expiry                = 0;       // Expiry (0=GTC)

input group              "─────  Appearance  ─────"
input int      UI_X                       = 20;      // Panel left offset
input int      UI_Y                       = 30;      // Panel top offset
input int      UI_FontSize                = 9;       // Base font size
input color    UI_Background              = C'245,246,248';   // Panel fill
input color    UI_AccentLong              = C'26,86,219';     // Long / buy accent
input color    UI_AccentShort             = C'229,72,77';     // Short / sell accent
input color    UI_AccentInfo              = C'59,130,246';    // Info / neutral accent
input color    UI_TextPrimary             = C'31,41,55';      // Primary text
input color    UI_TextSecondary           = C'107,114,128';   // Secondary text
input color    UI_Border                  = C'209,213,219';   // Border / separator
input color    UI_CardBg                  = C'255,255,255';   // Card / button base

input group              "─────  System  ─────"
input int      Sys_MagicID                = 240826;  // Unique magic number
input int      Sys_Slippage               = 20;      // Slippage tolerance (pts)
input string   Sys_Tag                    = "FLOW";  // Order comment tag

//+------------------------------------------------------------------+
//| Internal constants                                                 |
//+------------------------------------------------------------------+
#define TAG          "FLOW_"
#define PRODUCT_NAME "ASQ FlowDesk"

//--- widget identifiers
#define W_BUY            TAG "GoLong"
#define W_SELL           TAG "GoShort"
#define W_BLIMIT         TAG "LimitLong"
#define W_SLIMIT         TAG "LimitShort"
#define W_BSTOP          TAG "StopLong"
#define W_SSTOP          TAG "StopShort"
#define W_FLATTEN        TAG "Flatten"
#define W_FLAT_LONG      TAG "FlatLong"
#define W_FLAT_SHORT     TAG "FlatShort"
#define W_CANCEL_PEND    TAG "CancelPend"
#define W_LOCK_ENTRY     TAG "LockEntry"

//+------------------------------------------------------------------+
//| Runtime state                                                      |
//+------------------------------------------------------------------+
CTrade         m_executor;
CPositionInfo  m_posSnap;
CAccountInfo   m_acctSnap;
CSymbolInfo    m_symSnap;
COrderInfo     m_ordSnap;

int            m_volHandle;           // ATR indicator handle
double         m_volData[];           // ATR buffer

//--- scaled-exit tracking
struct ScaledExit
  {
   ulong          posID;
   double         entryLots;
   double         entryRate;
   ENUM_POSITION_TYPE side;
   bool           t1Done;
   bool           t2Done;
   bool           t3Done;
  };
ScaledExit     m_exits[];

//--- deferred position matching (avoids Sleep in UI thread)
struct PendingMatch
  {
   double         rate;
   double         lots;
   ENUM_POSITION_TYPE side;
   datetime       stamp;
  };
PendingMatch   m_pendMatches[];

//--- state persistence tag: "LVL012" means t1=false, t2=true, t3=false
#define LVL_MARKER  "LVL"

//+------------------------------------------------------------------+
//| Helpers — fresh server prices (no CSymbolInfo cache)               |
//+------------------------------------------------------------------+
double FreshAsk()    { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
double FreshBid()    { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double FreshPoint()  { return SymbolInfoDouble(_Symbol, SYMBOL_POINT); }
int    FreshDigits() { return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); }

//+------------------------------------------------------------------+
//| Initialization                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symSnap.Name(_Symbol);
   m_symSnap.Refresh();

   m_executor.SetExpertMagicNumber(Sys_MagicID);
   m_executor.SetDeviationInPoints(Sys_Slippage);
   m_executor.SetAsyncMode(false);

   m_volHandle = iATR(_Symbol, PERIOD_CURRENT, Trail_ATR_Len);
   if(m_volHandle == INVALID_HANDLE)
      PrintFormat("[%s] ATR handle creation failed", PRODUCT_NAME);

   ArraySetAsSeries(m_volData, true);

   BuildInterface();
   RecoverOpenPositions();

   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   PrintFormat("[%s] ready on %s", PRODUCT_NAME, _Symbol);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Cleanup                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, TAG);
   if(m_volHandle != INVALID_HANDLE)
      IndicatorRelease(m_volHandle);
  }

//+------------------------------------------------------------------+
//| Per-tick logic                                                     |
//+------------------------------------------------------------------+
void OnTick()
  {
   double ask = FreshAsk();
   double bid = FreshBid();
   if(ask <= 0 || bid <= 0) return;   // prices unavailable — skip silently

   MatchDeferredEntries();

   if(Trail_Style != STYLE_DISABLED)
      RunTrailing();

   if(AutoBE_Active)
      RunBreakeven();

   RunScaledExits();
   RefreshDashboard();
  }

//+------------------------------------------------------------------+
//| Chart interaction                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lp, const double &dp, const string &sp)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(StringFind(sp, TAG) != 0) return;

   ObjectSetInteger(0, sp, OBJPROP_STATE, false);
   ChartRedraw(0);

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      PrintFormat("[%s] Algo Trading disabled — enable it in the toolbar.", PRODUCT_NAME);
      return;
     }

   if(sp == W_BUY)           SendMarket(ORDER_TYPE_BUY);
   else if(sp == W_SELL)     SendMarket(ORDER_TYPE_SELL);
   else if(sp == W_BLIMIT)   SendPending(ORDER_TYPE_BUY_LIMIT);
   else if(sp == W_SLIMIT)   SendPending(ORDER_TYPE_SELL_LIMIT);
   else if(sp == W_BSTOP)    SendPending(ORDER_TYPE_BUY_STOP);
   else if(sp == W_SSTOP)    SendPending(ORDER_TYPE_SELL_STOP);
   else if(sp == W_FLATTEN)  FlattenAll();
   else if(sp == W_FLAT_LONG)  FlattenSide(POSITION_TYPE_BUY);
   else if(sp == W_FLAT_SHORT) FlattenSide(POSITION_TYPE_SELL);
   else if(sp == W_CANCEL_PEND) CancelPendings();
   else if(sp == W_LOCK_ENTRY)  LockEntryAll();

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                  === EXECUTION ENGINE ===                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Market order with auto-sizing and scaled-exit setup                |
//+------------------------------------------------------------------+
void SendMarket(const ENUM_ORDER_TYPE kind)
  {
   double pt   = FreshPoint();
   double ask  = FreshAsk();
   double bid  = FreshBid();
   int    dgt  = FreshDigits();

   if(ask <= 0 || bid <= 0 || pt <= 0)
     {
      PrintFormat("[%s] Prices unavailable — order aborted.", PRODUCT_NAME);
      return;
     }

   double rate = (kind == ORDER_TYPE_BUY) ? ask : bid;

   //--- broker distance constraints
   int minGap = BrokerMinGap();

   //--- stop loss
   int slPts = Exit_StopLoss;
   double sl = 0;
   if(slPts > 0)
     {
      if(slPts < minGap) slPts = minGap + 5;
      sl = (kind == ORDER_TYPE_BUY)
           ? NormalizeDouble(rate - slPts * pt, dgt)
           : NormalizeDouble(rate + slPts * pt, dgt);
     }

   //--- take profit at widest target
   int tpPts = WidestTarget();
   double tp = 0;
   if(tpPts > 0)
     {
      if(tpPts < minGap) tpPts = minGap + 5;
      tp = (kind == ORDER_TYPE_BUY)
           ? NormalizeDouble(rate + tpPts * pt, dgt)
           : NormalizeDouble(rate - tpPts * pt, dgt);
     }

   //--- position sizing
   double lots = ComputeLots(slPts);

   //--- comment with level state
   string side = (kind == ORDER_TYPE_BUY) ? "L" : "S";
   string note = StringFormat("%s_%s|LVL000", Sys_Tag, side);

   bool ok = (kind == ORDER_TYPE_BUY)
             ? m_executor.Buy(lots, _Symbol, ask, sl, tp, note)
             : m_executor.Sell(lots, _Symbol, bid, sl, tp, note);

   if(ok && m_executor.ResultDeal() > 0)
     {
      ENUM_POSITION_TYPE dir = (kind == ORDER_TYPE_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      int n = ArraySize(m_pendMatches);
      ArrayResize(m_pendMatches, n + 1);
      m_pendMatches[n].rate  = rate;
      m_pendMatches[n].lots  = lots;
      m_pendMatches[n].side  = dir;
      m_pendMatches[n].stamp = TimeCurrent();

      PrintFormat("[%s] %s %.2f @ %.5f  SL %.5f  TP %.5f",
                  PRODUCT_NAME, EnumToString(kind), lots, rate, sl, tp);
     }
   else
      PrintFormat("[%s] Order rejected — err %d: %s",
                  PRODUCT_NAME, GetLastError(), m_executor.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
//| Pending order placement                                            |
//+------------------------------------------------------------------+
void SendPending(const ENUM_ORDER_TYPE kind)
  {
   double pt   = FreshPoint();
   double ask  = FreshAsk();
   double bid  = FreshBid();
   int    dgt  = FreshDigits();

   if(ask <= 0 || bid <= 0 || pt <= 0)
     {
      PrintFormat("[%s] Prices unavailable — pending aborted.", PRODUCT_NAME);
      return;
     }

   int minGap  = BrokerMinGap();
   int offset  = Pend_Gap;  if(offset < minGap) offset = minGap + 5;
   int slPts   = Pend_SL;   if(slPts > 0 && slPts < minGap) slPts = minGap + 5;
   int tpPts   = Pend_TP;   if(tpPts > 0 && tpPts < minGap) tpPts = minGap + 5;

   double price = 0, sl = 0, tp = 0;

   switch(kind)
     {
      case ORDER_TYPE_BUY_LIMIT:
         price = NormalizeDouble(ask - offset * pt, dgt);
         sl = (slPts > 0) ? NormalizeDouble(price - slPts * pt, dgt) : 0;
         tp = (tpPts > 0) ? NormalizeDouble(price + tpPts * pt, dgt) : 0;
         break;

      case ORDER_TYPE_SELL_LIMIT:
         price = NormalizeDouble(bid + offset * pt, dgt);
         sl = (slPts > 0) ? NormalizeDouble(price + slPts * pt, dgt) : 0;
         tp = (tpPts > 0) ? NormalizeDouble(price - tpPts * pt, dgt) : 0;
         break;

      case ORDER_TYPE_BUY_STOP:
         price = NormalizeDouble(ask + offset * pt, dgt);
         sl = (slPts > 0) ? NormalizeDouble(price - slPts * pt, dgt) : 0;
         tp = (tpPts > 0) ? NormalizeDouble(price + tpPts * pt, dgt) : 0;
         break;

      case ORDER_TYPE_SELL_STOP:
        {
         price = NormalizeDouble(bid - offset * pt, dgt);
         double floor = MathMax(minGap * pt, 20 * pt);
         if(price < floor)
            price = NormalizeDouble(bid * 0.999, dgt);
         sl = (slPts > 0) ? NormalizeDouble(price + slPts * pt, dgt) : 0;
         tp = (tpPts > 0) ? NormalizeDouble(price - tpPts * pt, dgt) : 0;
         if(tp < 0) tp = 0;
         break;
        }
     }

   if(price <= 0) { PrintFormat("[%s] Invalid pending price.", PRODUCT_NAME); return; }
   if(sl < 0) sl = 0;
   if(tp < 0) tp = 0;

   double lots = ComputeLots(slPts);
   string note = StringFormat("%s_P", Sys_Tag);

   if(m_executor.OrderOpen(_Symbol, kind, lots, 0, price, sl, tp, ORDER_TIME_GTC, Pend_Expiry, note))
      PrintFormat("[%s] Pending %s %.2f @ %.5f", PRODUCT_NAME, EnumToString(kind), lots, price);
   else
      PrintFormat("[%s] Pending rejected — err %d: %s",
                  PRODUCT_NAME, GetLastError(), m_executor.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
//|                  === SCALED EXIT SYSTEM ===                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Register a position for scaled exits                               |
//+------------------------------------------------------------------+
void RegisterExit(const ulong ticket)
  {
   for(int j = 0; j < ArraySize(m_exits); j++)
      if(m_exits[j].posID == ticket) return;

   if(!PositionSelectByTicket(ticket)) return;

   int n = ArraySize(m_exits);
   ArrayResize(m_exits, n + 1);
   m_exits[n].posID      = ticket;
   m_exits[n].entryLots  = PositionGetDouble(POSITION_VOLUME);
   m_exits[n].entryRate  = PositionGetDouble(POSITION_PRICE_OPEN);
   m_exits[n].side       = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   m_exits[n].t1Done     = false;
   m_exits[n].t2Done     = false;
   m_exits[n].t3Done     = false;

   PrintFormat("[%s] Tracking #%I64u  lots=%.2f  entry=%.5f",
               PRODUCT_NAME, ticket, m_exits[n].entryLots, m_exits[n].entryRate);
  }

//+------------------------------------------------------------------+
//| Match deferred entries to real positions                            |
//+------------------------------------------------------------------+
void MatchDeferredEntries()
  {
   if(ArraySize(m_pendMatches) == 0) return;

   for(int d = ArraySize(m_pendMatches) - 1; d >= 0; d--)
     {
      if(TimeCurrent() - m_pendMatches[d].stamp > 30)
        { DropPendMatch(d); continue; }

      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!m_posSnap.SelectByIndex(i)) continue;
         if(m_posSnap.Symbol() != _Symbol) continue;
         if(m_posSnap.Magic()  != Sys_MagicID) continue;
         if(m_posSnap.PositionType() != m_pendMatches[d].side) continue;

         ulong tk = m_posSnap.Ticket();
         bool tracked = false;
         for(int j = 0; j < ArraySize(m_exits); j++)
            if(m_exits[j].posID == tk) { tracked = true; break; }
         if(tracked) continue;

         RegisterExit(tk);
         DropPendMatch(d);
         break;
        }
     }
  }

void DropPendMatch(const int idx)
  {
   int total = ArraySize(m_pendMatches);
   for(int i = idx; i < total - 1; i++)
      m_pendMatches[i] = m_pendMatches[i + 1];
   ArrayResize(m_pendMatches, total - 1);
  }

//+------------------------------------------------------------------+
//| Encode / decode level state in comment: "LVL110"                   |
//+------------------------------------------------------------------+
string EncodeLevels(bool a, bool b, bool c)
  { return StringFormat("LVL%d%d%d", a?1:0, b?1:0, c?1:0); }

bool DecodeLevels(const string txt, bool &a, bool &b, bool &c)
  {
   int p = StringFind(txt, "|LVL");
   if(p < 0) return false;
   string seg = StringSubstr(txt, p + 1, 6);
   if(StringLen(seg) < 6) return false;
   a = (StringGetCharacter(seg, 3) == '1');
   b = (StringGetCharacter(seg, 4) == '1');
   c = (StringGetCharacter(seg, 5) == '1');
   return true;
  }

//+------------------------------------------------------------------+
//| Recover positions on restart                                       |
//+------------------------------------------------------------------+
void RecoverOpenPositions()
  {
   ArrayResize(m_exits, 0);

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol) continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;

      int n = ArraySize(m_exits);
      ArrayResize(m_exits, n + 1);
      m_exits[n].posID     = m_posSnap.Ticket();
      m_exits[n].entryRate = m_posSnap.PriceOpen();
      m_exits[n].side      = m_posSnap.PositionType();

      string cmt = m_posSnap.Comment();
      bool a = false, b = false, c = false;
      if(DecodeLevels(cmt, a, b, c))
        {
         m_exits[n].t1Done = a;
         m_exits[n].t2Done = b;
         m_exits[n].t3Done = c;
         double curVol  = m_posSnap.Volume();
         double closed  = 0;
         if(a) closed += Exit_T1_Fraction;
         if(b) closed += Exit_T2_Fraction;
         double remain = 100.0 - closed;
         m_exits[n].entryLots = (remain > 0) ? curVol / (remain / 100.0) : curVol;

         PrintFormat("[%s] Restored #%I64u  T1=%d T2=%d T3=%d  origLots=%.2f",
                     PRODUCT_NAME, m_posSnap.Ticket(), a, b, c, m_exits[n].entryLots);
        }
      else
        {
         m_exits[n].entryLots = m_posSnap.Volume();
         m_exits[n].t1Done = false;
         m_exits[n].t2Done = false;
         m_exits[n].t3Done = false;
        }
     }
  }

//+------------------------------------------------------------------+
//| Run scaled partial exits                                           |
//+------------------------------------------------------------------+
void RunScaledExits()
  {
   double pt = FreshPoint();
   if(pt <= 0) return;

   for(int i = ArraySize(m_exits) - 1; i >= 0; i--)
     {
      if(i >= ArraySize(m_exits)) continue;

      ulong tk = m_exits[i].posID;
      if(!PositionSelectByTicket(tk))
        { DropExit(i); continue; }

      double now   = PositionGetDouble(POSITION_PRICE_CURRENT);
      double entry = m_exits[i].entryRate;
      double orig  = m_exits[i].entryLots;
      double live  = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE dir = m_exits[i].side;

      double gain = (dir == POSITION_TYPE_BUY)
                    ? (now - entry) / pt
                    : (entry - now) / pt;

      //--- target 1
      if(!m_exits[i].t1Done && Exit_Target1 > 0 && gain >= Exit_Target1)
        {
         double clip = AdjustLot(orig * Exit_T1_Fraction / 100.0);
         if(clip >= m_symSnap.LotsMin() && clip <= live)
           {
            if(m_executor.PositionClosePartial(tk, clip, Sys_Slippage))
              {
               m_exits[i].t1Done = true;
               PrintFormat("[%s] T1 reached — closed %.2f on #%I64u", PRODUCT_NAME, clip, tk);
              }
           }
         else
            m_exits[i].t1Done = true;
        }

      //--- target 2
      if(!m_exits[i].t2Done && m_exits[i].t1Done && Exit_Target2 > 0 && gain >= Exit_Target2)
        {
         if(PositionSelectByTicket(tk))
            live = PositionGetDouble(POSITION_VOLUME);
         double clip = AdjustLot(orig * Exit_T2_Fraction / 100.0);
         if(clip >= m_symSnap.LotsMin() && clip <= live)
           {
            if(m_executor.PositionClosePartial(tk, clip, Sys_Slippage))
              {
               m_exits[i].t2Done = true;
               PrintFormat("[%s] T2 reached — closed %.2f on #%I64u", PRODUCT_NAME, clip, tk);
              }
           }
         else
            m_exits[i].t2Done = true;
        }

      //--- target 3: close remainder
      if(!m_exits[i].t3Done && m_exits[i].t2Done && Exit_Target3 > 0 && gain >= Exit_Target3)
        {
         if(m_executor.PositionClose(tk, Sys_Slippage))
           {
            m_exits[i].t3Done = true;
            PrintFormat("[%s] T3 reached — fully closed #%I64u", PRODUCT_NAME, tk);
            DropExit(i);
           }
        }
     }
  }

void DropExit(const int idx)
  {
   int total = ArraySize(m_exits);
   for(int i = idx; i < total - 1; i++)
      m_exits[i] = m_exits[i + 1];
   ArrayResize(m_exits, total - 1);
  }

//+------------------------------------------------------------------+
//|                  === TRAILING ENGINE ===                           |
//+------------------------------------------------------------------+
void RunTrailing()
  {
   double pt = FreshPoint();
   if(pt <= 0) return;

   double vol = 0;
   if(Trail_Style == STYLE_VOLATILITY && m_volHandle != INVALID_HANDLE)
     {
      if(CopyBuffer(m_volHandle, 0, 0, 1, m_volData) > 0)
         vol = m_volData[0];
     }

   int stopsLvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = MathMax(stopsLvl, 1) * pt;
   int dgt = FreshDigits();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;

      double curSL = m_posSnap.StopLoss();
      double curTP = m_posSnap.TakeProfit();
      double open  = m_posSnap.PriceOpen();
      ulong  tk    = m_posSnap.Ticket();

      double ref = (m_posSnap.PositionType() == POSITION_TYPE_BUY) ? FreshBid() : FreshAsk();
      if(ref <= 0) continue;

      double span = 0;
      switch(Trail_Style)
        {
         case STYLE_DISTANCE:  span = Trail_Distance * pt;            break;
         case STYLE_VOLATILITY: span = vol * Trail_ATR_Scale;          break;
         case STYLE_STRUCTURE:  span = StructureSpan(m_posSnap.PositionType()); break;
         default: continue;
        }
      if(span <= 0) continue;

      double proposed = 0;

      if(m_posSnap.PositionType() == POSITION_TYPE_BUY)
        {
         proposed = NormalizeDouble(ref - span, dgt);
         if(curSL > 0 && proposed <= curSL) continue;
         if(proposed <= open) continue;
         if(curSL > 0 && (proposed - curSL) < Trail_MinStep * pt) continue;
         if((ref - proposed) < minDist)
            proposed = NormalizeDouble(ref - minDist, dgt);
        }
      else
        {
         proposed = NormalizeDouble(ref + span, dgt);
         if(curSL > 0 && proposed >= curSL) continue;
         if(proposed >= open) continue;
         if(curSL > 0 && (curSL - proposed) < Trail_MinStep * pt) continue;
         if((proposed - ref) < minDist)
            proposed = NormalizeDouble(ref + minDist, dgt);
        }

      if(m_executor.PositionModify(tk, proposed, curTP))
         PrintFormat("[%s] Trail SL → %.5f on #%I64u", PRODUCT_NAME, proposed, tk);
     }
  }

//+------------------------------------------------------------------+
//| Structure-based trail (prior-bar range)                            |
//+------------------------------------------------------------------+
double StructureSpan(const ENUM_POSITION_TYPE dir)
  {
   double hi[], lo[];
   ArraySetAsSeries(hi, true);
   ArraySetAsSeries(lo, true);
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, 1, hi) < 1) return 0;
   if(CopyLow (_Symbol, PERIOD_CURRENT, 1, 1, lo) < 1) return 0;

   double ref = (dir == POSITION_TYPE_BUY) ? FreshBid() : FreshAsk();
   double d = (dir == POSITION_TYPE_BUY) ? (ref - lo[0]) : (hi[0] - ref);
   return MathMax(d, 0);
  }

//+------------------------------------------------------------------+
//|                  === BREAKEVEN ENGINE ===                          |
//+------------------------------------------------------------------+
void RunBreakeven()
  {
   double pt = FreshPoint();
   int dgt   = FreshDigits();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;

      double open  = m_posSnap.PriceOpen();
      double curSL = m_posSnap.StopLoss();
      double curTP = m_posSnap.TakeProfit();
      ulong  tk    = m_posSnap.Ticket();

      if(m_posSnap.PositionType() == POSITION_TYPE_BUY)
        {
         double profit = (FreshBid() - open) / pt;
         double beSL   = NormalizeDouble(open + AutoBE_Cushion * pt, dgt);
         if(profit >= AutoBE_Trigger && (curSL < beSL || curSL == 0))
            if(m_executor.PositionModify(tk, beSL, curTP))
               PrintFormat("[%s] BE locked at %.5f on #%I64u", PRODUCT_NAME, beSL, tk);
        }
      else
        {
         double profit = (open - FreshAsk()) / pt;
         double beSL   = NormalizeDouble(open - AutoBE_Cushion * pt, dgt);
         if(profit >= AutoBE_Trigger && (curSL > beSL || curSL == 0))
            if(m_executor.PositionModify(tk, beSL, curTP))
               PrintFormat("[%s] BE locked at %.5f on #%I64u", PRODUCT_NAME, beSL, tk);
        }
     }
  }

//+------------------------------------------------------------------+
//| Manual breakeven on all profitable positions                       |
//+------------------------------------------------------------------+
void LockEntryAll()
  {
   double pt = FreshPoint();
   int dgt   = FreshDigits();
   int cnt   = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;

      double open  = m_posSnap.PriceOpen();
      double curTP = m_posSnap.TakeProfit();
      ulong  tk    = m_posSnap.Ticket();

      double beSL = (m_posSnap.PositionType() == POSITION_TYPE_BUY)
                    ? NormalizeDouble(open + AutoBE_Cushion * pt, dgt)
                    : NormalizeDouble(open - AutoBE_Cushion * pt, dgt);

      bool inGreen = (m_posSnap.PositionType() == POSITION_TYPE_BUY)
                     ? FreshBid() > beSL
                     : FreshAsk() < beSL;

      if(inGreen && m_executor.PositionModify(tk, beSL, curTP))
         cnt++;
     }
   PrintFormat("[%s] Entry locked on %d positions", PRODUCT_NAME, cnt);
  }

//+------------------------------------------------------------------+
//|                  === FLATTEN / CANCEL ===                          |
//+------------------------------------------------------------------+
void FlattenAll()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;
      m_executor.PositionClose(m_posSnap.Ticket(), Sys_Slippage);
     }
  }

void FlattenSide(const ENUM_POSITION_TYPE dir)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;
      if(m_posSnap.PositionType() != dir) continue;
      m_executor.PositionClose(m_posSnap.Ticket(), Sys_Slippage);
     }
  }

void CancelPendings()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!m_ordSnap.SelectByIndex(i)) continue;
      if(m_ordSnap.Symbol() != _Symbol)  continue;
      if(m_ordSnap.Magic()  != Sys_MagicID) continue;
      m_executor.OrderDelete(m_ordSnap.Ticket());
     }
  }

//+------------------------------------------------------------------+
//|                  === SIZING MATH ===                               |
//+------------------------------------------------------------------+
double ComputeLots(const int slPts)
  {
   if(Sizing_Method == SIZING_LOTS)
      return AdjustLot(Sizing_ManualLots);

   double equity   = m_acctSnap.Equity();
   double cashRisk = (Sizing_Method == SIZING_PCT_EQUITY)
                     ? equity * Sizing_RiskPercent / 100.0
                     : Sizing_RiskCash;

   int sl = (slPts > 0) ? slPts : 100;

   double tvp = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tsz = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pt  = FreshPoint();

   if(tvp <= 0 || tsz <= 0 || pt <= 0)
      return AdjustLot(Sizing_ManualLots);

   double perPoint = tvp * (pt / tsz);
   return AdjustLot(cashRisk / (sl * perPoint));
  }

double AdjustLot(double raw)
  {
   double lo   = m_symSnap.LotsMin();
   double hi   = m_symSnap.LotsMax();
   double step = m_symSnap.LotsStep();
   if(step <= 0) step = 0.01;

   raw = MathFloor(raw / step) * step;
   raw = MathMax(raw, lo);
   raw = MathMin(raw, hi);
   return NormalizeDouble(raw, (int)MathCeil(-MathLog10(step)));
  }

int WidestTarget()
  {
   int w = 0;
   if(Exit_Target1 > w) w = Exit_Target1;
   if(Exit_Target2 > w) w = Exit_Target2;
   if(Exit_Target3 > w) w = Exit_Target3;
   return w;
  }

int BrokerMinGap()
  {
   int stops  = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   int g = MathMax(stops, freeze);
   return (g < 1) ? 1 : g;
  }

//+------------------------------------------------------------------+
//|                  === USER INTERFACE ===                            |
//+------------------------------------------------------------------+

void BuildInterface()
  {
   int x = UI_X;
   int y = UI_Y;
   int pw = 280;           // panel width
   int bh = 28;            // button height
   int hw = (pw - 12) / 2; // half-width button
   int sp = 6;             // spacing
   int lh = 18;            // line height

   //--- panel background
   DrawCard(TAG "BG", x - 8, y - 8, pw + 16, 10, UI_Background, UI_Border);

   //--- header
   DrawText(TAG "Header", x, y, "FlowDesk", UI_AccentInfo, UI_FontSize + 3, "Segoe UI Semibold");
   y += lh + 8;
   DrawText(TAG "Sub", x, y, _Symbol + "  ·  " + PeriodName(), UI_TextSecondary, UI_FontSize, "Segoe UI");
   y += lh + 4;
   DrawLine(TAG "Div0", x, y, pw, UI_Border);
   y += 8;

   //--- sizing info
   DrawText(TAG "SizeInfo", x, y, "Size: ...", UI_AccentInfo, UI_FontSize, "Segoe UI");
   y += lh;
   DrawText(TAG "RiskLine", x, y, "Risk: ...", UI_TextSecondary, UI_FontSize, "Segoe UI");
   y += lh + 6;

   //--- execution buttons
   DrawBtn(W_BUY,  x, y, hw, bh, "LONG",  UI_AccentLong, clrWhite);
   DrawBtn(W_SELL, x + hw + sp + 6, y, hw, bh, "SHORT", UI_AccentShort, clrWhite);
   y += bh + sp + 4;

   DrawLine(TAG "Div1", x, y, pw, UI_Border);
   y += 8;

   //--- pending section
   DrawText(TAG "PendHdr", x, y, "Pending Orders", UI_TextPrimary, UI_FontSize, "Segoe UI Semibold");
   y += lh + 4;

   DrawBtn(W_BLIMIT, x, y, hw, bh, "BUY LIMIT",  C'22,101,52', C'220,252,231');
   DrawBtn(W_SLIMIT, x + hw + sp + 6, y, hw, bh, "SELL LIMIT", C'153,27,27', C'254,226,226');
   y += bh + sp;

   DrawBtn(W_BSTOP, x, y, hw, bh, "BUY STOP",  C'21,94,117', C'207,250,254');
   DrawBtn(W_SSTOP, x + hw + sp + 6, y, hw, bh, "SELL STOP", C'120,53,15', C'254,243,199');
   y += bh + sp + 4;

   DrawLine(TAG "Div2", x, y, pw, UI_Border);
   y += 8;

   //--- management section
   DrawText(TAG "MgmtHdr", x, y, "Manage", UI_TextPrimary, UI_FontSize, "Segoe UI Semibold");
   y += lh + 4;

   DrawBtn(W_FLATTEN, x, y, pw, bh, "FLATTEN ALL", C'185,28,28', clrWhite);
   y += bh + sp;

   DrawBtn(W_FLAT_LONG,  x, y, hw, bh, "Close Long",  UI_CardBg, UI_AccentLong);
   DrawBtn(W_FLAT_SHORT, x + hw + sp + 6, y, hw, bh, "Close Short", UI_CardBg, UI_AccentShort);
   y += bh + sp;

   DrawBtn(W_CANCEL_PEND, x, y, hw, bh, "Cancel Pend", UI_CardBg, UI_TextSecondary);
   DrawBtn(W_LOCK_ENTRY,  x + hw + sp + 6, y, hw, bh, "Lock Entry", UI_CardBg, UI_AccentInfo);
   y += bh + sp + 4;

   DrawLine(TAG "Div3", x, y, pw, UI_Border);
   y += 8;

   //--- live analytics section
   DrawText(TAG "StatHdr", x, y, "Analytics", UI_TextPrimary, UI_FontSize, "Segoe UI Semibold");
   y += lh + 4;

   DrawText(TAG "dSpread",  x, y, "Spread: —",     UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh;
   DrawText(TAG "dPos",     x, y, "Positions: —",   UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh;
   DrawText(TAG "dExpo",    x, y, "Exposure: —",    UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh;
   DrawText(TAG "dPnL",     x, y, "P&L: —",         UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh;
   DrawText(TAG "dTargets", x, y, "Targets: —",     UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh;
   DrawText(TAG "dTrail",   x, y, "Trail: —",       UI_TextSecondary, UI_FontSize, "Segoe UI"); y += lh + 6;

   //--- footer
   DrawText(TAG "Footer", x, y, "AlgoSphere Quant", UI_Border, UI_FontSize - 1, "Segoe UI");

   //--- resize background
   ObjectSetInteger(0, TAG "BG", OBJPROP_YSIZE, y - UI_Y + lh + 16);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Refresh dashboard labels                                           |
//+------------------------------------------------------------------+
void RefreshDashboard()
  {
   double pt = FreshPoint();

   //--- sizing info
   double lots = ComputeLots(Exit_StopLoss);
   string modeStr = "";
   switch(Sizing_Method)
     {
      case SIZING_LOTS:       modeStr = "Manual"; break;
      case SIZING_PCT_EQUITY: modeStr = StringFormat("%.1f%%", Sizing_RiskPercent); break;
      case SIZING_FIXED_CASH: modeStr = StringFormat("$%.0f", Sizing_RiskCash); break;
     }
   SetText(TAG "SizeInfo",
           StringFormat("Size: %.2f  (%s · SL %d pts)", lots, modeStr, Exit_StopLoss),
           UI_AccentInfo);

   //--- risk in cash
   double cashRisk = 0;
   if(Sizing_Method == SIZING_PCT_EQUITY)
      cashRisk = m_acctSnap.Equity() * Sizing_RiskPercent / 100.0;
   else if(Sizing_Method == SIZING_FIXED_CASH)
      cashRisk = Sizing_RiskCash;
   else
     {
      double tvp = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tsz = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if(tsz > 0 && pt > 0)
         cashRisk = Sizing_ManualLots * Exit_StopLoss * (tvp * pt / tsz);
     }
   SetText(TAG "RiskLine", StringFormat("Risk: $%.2f per trade", cashRisk), UI_TextSecondary);

   //--- spread
   int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   color spClr = (spread < 20) ? UI_AccentLong : (spread < 40) ? C'217,119,6' : UI_AccentShort;
   SetText(TAG "dSpread",
           StringFormat("Spread: %d pts  (%.1f pip)", spread, spread / 10.0), spClr);

   //--- positions
   int nLong = 0, nShort = 0;
   double lotsL = 0, lotsS = 0, pnl = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(!m_posSnap.SelectByIndex(i)) continue;
      if(m_posSnap.Symbol() != _Symbol)  continue;
      if(m_posSnap.Magic()  != Sys_MagicID) continue;

      double p = m_posSnap.Profit() + m_posSnap.Swap() + m_posSnap.Commission();
      pnl += p;

      if(m_posSnap.PositionType() == POSITION_TYPE_BUY)
        { nLong++;  lotsL += m_posSnap.Volume(); }
      else
        { nShort++; lotsS += m_posSnap.Volume(); }
     }

   SetText(TAG "dPos",  StringFormat("Positions: %d L  |  %d S", nLong, nShort), UI_TextSecondary);
   SetText(TAG "dExpo", StringFormat("Exposure: %.2f L  |  %.2f S", lotsL, lotsS), UI_TextSecondary);

   color pClr = (pnl >= 0) ? UI_AccentLong : UI_AccentShort;
   SetText(TAG "dPnL", StringFormat("P&L: %s%.2f", (pnl >= 0) ? "+" : "", pnl), pClr);

   //--- target tracker
   int tracked = ArraySize(m_exits);
   int t1n = 0, t2n = 0;
   for(int i = 0; i < tracked; i++)
     {
      if(m_exits[i].t1Done) t1n++;
      if(m_exits[i].t2Done) t2n++;
     }
   SetText(TAG "dTargets",
           StringFormat("Targets: %d tracked  ·  T1:%d  T2:%d", tracked, t1n, t2n),
           UI_AccentInfo);

   //--- trailing info
   string tInfo = "Off";
   switch(Trail_Style)
     {
      case STYLE_DISTANCE: tInfo = StringFormat("Fixed %d pts", Trail_Distance); break;
      case STYLE_VOLATILITY:
        {
         double atr = 0;
         if(m_volHandle != INVALID_HANDLE && CopyBuffer(m_volHandle, 0, 0, 1, m_volData) > 0)
            atr = m_volData[0];
         tInfo = StringFormat("ATR(%.0f) ×%.1f", (pt > 0) ? atr / pt : 0, Trail_ATR_Scale);
         break;
        }
      case STYLE_STRUCTURE: tInfo = "Structure"; break;
     }
   SetText(TAG "dTrail",
           StringFormat("Trail: %s  ·  BE: %s",
                        tInfo,
                        AutoBE_Active ? StringFormat("%d pts", AutoBE_Trigger) : "Off"),
           UI_TextSecondary);
  }

//+------------------------------------------------------------------+
//| Timeframe display name                                             |
//+------------------------------------------------------------------+
string PeriodName()
  {
   switch(_Period)
     {
      case PERIOD_M1:  return "M1";   case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";  case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";   case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";   case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN";
      default: return StringFormat("M%d", PeriodSeconds() / 60);
     }
  }

//+------------------------------------------------------------------+
//|                  === WIDGET PRIMITIVES ===                         |
//+------------------------------------------------------------------+
void DrawBtn(const string id, int x, int y, int w, int h,
             const string label, color bg, color fg)
  {
   ObjectCreate(0, id, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, id, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, id, OBJPROP_YSIZE, h);
   ObjectSetString (0, id, OBJPROP_TEXT, label);
   ObjectSetString (0, id, OBJPROP_FONT, "Segoe UI Semibold");
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, UI_FontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, id, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, id, OBJPROP_BORDER_COLOR, bg);
   ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, id, OBJPROP_STATE, false);
  }

void DrawText(const string id, int x, int y,
              const string txt, color clr, int sz, string font = "Segoe UI")
  {
   ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
   ObjectSetString (0, id, OBJPROP_TEXT, txt);
   ObjectSetString (0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, sz);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);
  }

void SetText(const string id, const string txt, color clr)
  {
   ObjectSetString (0, id, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
  }

void DrawCard(const string id, int x, int y, int w, int h,
              color bg, color border)
  {
   ObjectCreate(0, id, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, id, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, id, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, id, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, id, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, id, OBJPROP_BORDER_COLOR, border);
   ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, id, OBJPROP_BACK, false);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);
  }

void DrawLine(const string id, int x, int y, int w, color clr)
  {
   DrawCard(id, x, y, w, 1, clr, clr);
  }

//+------------------------------------------------------------------+
