//+------------------------------------------------------------------+
//|                                                MirrorHedgeEA.mq5 |
//|  Mirrors (hedges) trades opened/pending/modified by another EA   |
//|  on the SAME account / SAME broker. Requires a HEDGING account.  |
//+------------------------------------------------------------------+
#property copyright   "ClassicalTrading | www.mql5.com/en/users/classicaltrading/"
#property link        "https://www.mql5.com/en/users/classicaltrading/"
#property version   "1.00"
#property description "Mirrors trades of another EA (selected by magic number rules)."
#property description "Default: inverse direction (hedge), same lot size, magic 'starts with'."

#include <Trade\Trade.mqh>

//--- enums
enum ENUM_MATCH_MODE
{
   MATCH_STARTS_WITH = 0,   // Magic STARTS WITH pattern (default)
   MATCH_CONTAINS    = 1,   // Magic CONTAINS pattern
   MATCH_EXACT       = 2    // Magic EXACT match
};

enum ENUM_LOT_MODE
{
   LOT_SAME    = 0,         // Same as source trade (default)
   LOT_FIXED   = 1,         // Fixed lot size
   LOT_PERCENT = 2          // % of source trade
};

//--- inputs: which trades to copy
input string          InpMagicPatterns   = "1001";          // Source magic pattern(s), comma separated
input ENUM_MATCH_MODE InpMatchMode       = MATCH_STARTS_WITH; // Magic match rule
input string          InpMagicSuffix     = "321";           // Mirror magic = source magic + this suffix
input string          InpCommentSuffix   = "_mirror";       // Mirror comment = source comment + this suffix

//--- inputs: how to copy
input bool            InpInverse         = true;            // Inverse direction (Buy<->Sell, TP<->SL)
input ENUM_LOT_MODE   InpLotMode         = LOT_SAME;        // Lot size mode
input double          InpFixedLot        = 0.01;            // Fixed lot (if Lot mode = Fixed)
input double          InpLotPercent      = 100.0;           // % of source lot (if Lot mode = Percent)
input bool            InpMirrorPending   = true;            // Mirror pending orders
input bool            InpMirrorSLTP      = true;            // Mirror SL / TP (and their changes)
input bool            InpSyncPartial     = true;            // Mirror partial closes (Same / Percent modes)
input bool            InpMirrorExisting  = true;            // Mirror trades that already exist at EA start
input int             InpDeviation       = 20;              // Max slippage (points)
input int             InpTimerMs         = 100;             // Sync interval (ms)

//--- inputs: strategy tester demo source (has no effect on a live/demo chart)
input bool            InpTesterDemo      = true;            // Tester only: generate demo source trades to mirror
input int             InpDemoHoldBars    = 3;               // Tester only: bars a demo source trade is held

//--- inputs: GUI
input bool            InpShowPanel       = true;            // Show info panel
input int             InpPanelX          = 10;              // Panel X
input int             InpPanelY          = 25;              // Panel Y
input int             InpPanelWidth      = 520;             // Panel width (px)
input int             InpFontSize        = 9;               // Panel font size
input int             InpMaxRows         = 8;               // Max rows per list in panel

//--- globals
CTrade   g_trade;
string   g_pat[];            // parsed magic patterns
ulong    g_done[];           // source keys that have (or had) a mirror -> never re-open
ulong    g_warned[];         // keys already warned about (unsupported)
datetime g_lastMarginMsg = 0;   // throttle for the "not enough margin" log line
datetime g_nextTry = 0;      // throttle after failed trade action
bool     g_busy    = false;
ulong    g_lastPanel = 0;

string   g_lines[];
color    g_cols[];
int      g_n = 0;

#define PFX "MRP_"

//--- tester demo source (only used inside the Strategy Tester so the EA shows trading activity)
CTrade   g_demo;
long     g_demoMagic = 1001;
datetime g_demoBar   = 0;
int      g_demoDir   = -1;

//+------------------------------------------------------------------+
//| Small helpers                                                    |
//+------------------------------------------------------------------+
bool Contains(const ulong &arr[], const ulong v)
{
   for(int i = ArraySize(arr) - 1; i >= 0; i--)
      if(arr[i] == v) return true;
   return false;
}

void Push(ulong &arr[], const ulong v)
{
   int n = ArraySize(arr);
   ArrayResize(arr, n + 1, 64);
   arr[n] = v;
}

bool IsDone(const ulong key)  { return Contains(g_done, key); }
void AddDone(const ulong key) { if(!IsDone(key)) Push(g_done, key); }

//--- link table: mirror ticket -> source ticket, kept in terminal global variables (per account)
string LinkName(const ulong mirrorTicket)
{
   return "MHE_" + (string)AccountInfoInteger(ACCOUNT_LOGIN) + "_" + (string)mirrorTicket;
}

void SetLink(const ulong mirrorTicket, const ulong srcKey)
{
   GlobalVariableSet(LinkName(mirrorTicket), (double)srcKey);
}

ulong GetLink(const ulong mirrorTicket)
{
   string n = LinkName(mirrorTicket);
   if(!GlobalVariableCheck(n)) return 0;
   return (ulong)GlobalVariableGet(n);
}

bool EndsWith(const string s, const string x)
{
   int ls = StringLen(s), lx = StringLen(x);
   return (lx > 0 && ls >= lx && StringSubstr(s, ls - lx) == x);
}

bool MagicHasSuffix(const long magic)
{
   return EndsWith(IntegerToString(magic), InpMagicSuffix);
}

//--- mirror magic = source magic digits + suffix (808 -> 808321)
bool BuildMirrorMagic(const long srcMagic, long &out)
{
   if(srcMagic < 0) return false;
   string s = IntegerToString(srcMagic) + InpMagicSuffix;
   if(StringLen(s) > 18) return false;      // would overflow the magic range
   out = StringToInteger(s);
   return true;
}

//--- mirror comment = source comment + suffix (kept within the 31 char limit, suffix always preserved)
string BuildMirrorComment(const string orig)
{
   int room = 31 - StringLen(InpCommentSuffix);
   string o = orig;
   if(room < 0) room = 0;
   if(StringLen(o) > room) o = StringSubstr(o, 0, room);
   return o + InpCommentSuffix;
}

//--- link of the currently SELECTED position / order (0 = not one of our linked mirrors)
ulong PosLink()
{
   if(!MagicHasSuffix(PositionGetInteger(POSITION_MAGIC))) return 0;
   return GetLink((ulong)PositionGetInteger(POSITION_IDENTIFIER));
}

ulong OrdLink()
{
   if(!MagicHasSuffix(OrderGetInteger(ORDER_MAGIC))) return 0;
   return GetLink((ulong)OrderGetInteger(ORDER_TICKET));
}

//--- selected position/order looks like one of our mirrors (linked, or magic+comment suffix pattern)
bool PosIsMirror()
{
   long mg = PositionGetInteger(POSITION_MAGIC);
   if(!MagicHasSuffix(mg)) return false;
   return PosLink() != 0 || EndsWith(PositionGetString(POSITION_COMMENT), InpCommentSuffix);
}

bool OrdIsMirror()
{
   long mg = OrderGetInteger(ORDER_MAGIC);
   if(!MagicHasSuffix(mg)) return false;
   return OrdLink() != 0 || EndsWith(OrderGetString(ORDER_COMMENT), InpCommentSuffix);
}

bool MatchMagic(const long magic)
{
   string s = IntegerToString(magic);
   for(int i = 0; i < ArraySize(g_pat); i++)
   {
      string p = g_pat[i];
      if(p == "") continue;
      switch(InpMatchMode)
      {
         case MATCH_EXACT:       if(s == p) return true;                 break;
         case MATCH_CONTAINS:    if(StringFind(s, p) >= 0) return true;  break;
         default:                if(StringFind(s, p) == 0) return true;  break;
      }
   }
   return false;
}

//--- clock that also advances correctly inside the Strategy Tester
datetime NowT()
{
   return MQLInfoInteger(MQL_TESTER) ? TimeCurrent() : TimeLocal();
}

void Fail(const string what)
{
   PrintFormat("MirrorHedgeEA: %s failed - retcode %d (%s)", what,
               (int)g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
   g_nextTry = NowT() + 2;
}

//--- SL/TP mapping (inverse: source TP becomes mirror SL and vice versa; same price levels)
void MapSLTP(const double sl, const double tp, double &dsl, double &dtp)
{
   if(!InpMirrorSLTP) { dsl = 0; dtp = 0; return; }
   if(InpInverse)     { dsl = tp; dtp = sl; }
   else               { dsl = sl; dtp = tp; }
}

//--- pending order type mapping. Inverse keeps the SAME price level:
//    BuyLimit -> SellStop, BuyStop -> SellLimit, etc. Returns -1 if unsupported.
int MapOrderType(const ENUM_ORDER_TYPE t)
{
   if(!InpInverse) return (int)t;
   switch(t)
   {
      case ORDER_TYPE_BUY_LIMIT:  return ORDER_TYPE_SELL_STOP;
      case ORDER_TYPE_BUY_STOP:   return ORDER_TYPE_SELL_LIMIT;
      case ORDER_TYPE_SELL_LIMIT: return ORDER_TYPE_BUY_STOP;
      case ORDER_TYPE_SELL_STOP:  return ORDER_TYPE_BUY_LIMIT;
   }
   return -1; // stop-limit orders have no exact inverse
}

double CalcVolume(const string sym, const double srcVol)
{
   double v;
   switch(InpLotMode)
   {
      case LOT_FIXED:   v = InpFixedLot;                       break;
      case LOT_PERCENT: v = srcVol * InpLotPercent / 100.0;    break;
      default:          v = srcVol;                            break;
   }
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(step > 0) v = MathRound(v / step) * step;
   v = MathMax(mn, MathMin(mx, v));
   return NormalizeDouble(v, 8);
}

bool Differs(const string sym, const double a, const double b)
{
   double pt = SymbolInfoDouble(sym, SYMBOL_POINT);
   return MathAbs(a - b) > pt * 0.5;
}

//+------------------------------------------------------------------+
//| Collectors / lookups                                             |
//+------------------------------------------------------------------+
//--- true while the symbol is inside a trading session (avoids "Market closed" rejects)
bool MarketOpen(const string sym)
{
   if(SymbolInfoInteger(sym, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED) return false;

   datetime from, to;
   bool anyData = false;
   for(int d = 0; d < 7 && !anyData; d++)
      if(SymbolInfoSessionTrade(sym, (ENUM_DAY_OF_WEEK)d, 0, from, to)) anyData = true;
   if(!anyData) return true;                          // no session info from the server -> do not block

   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   ulong now = (ulong)(dt.hour * 3600 + dt.min * 60 + dt.sec);
   for(uint i = 0; i < 16; i++)
   {
      if(!SymbolInfoSessionTrade(sym, (ENUM_DAY_OF_WEEK)dt.day_of_week, i, from, to)) break;
      if(now >= (ulong)from && now < (ulong)to) return true;
   }
   return false;
}

//--- free margin covers a new position of this size (avoids "No money" rejects)
bool HasMargin(const string sym, const bool buy, const double vol)
{
   double price = buy ? SymbolInfoDouble(sym, SYMBOL_ASK) : SymbolInfoDouble(sym, SYMBOL_BID);
   double need  = 0;
   if(!OrderCalcMargin(buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, sym, vol, price, need)) return false;
   return need < AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

//--- selected position: SL/TP within the freeze level of the price -> broker refuses modify/close
bool PosFrozen()
{
   string sym = PositionGetString(POSITION_SYMBOL);
   long fl = SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   if(fl <= 0) return false;
   double lim = fl * SymbolInfoDouble(sym, SYMBOL_POINT);
   double px  = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? SymbolInfoDouble(sym, SYMBOL_BID)
                                                                       : SymbolInfoDouble(sym, SYMBOL_ASK);
   double sl = PositionGetDouble(POSITION_SL);
   double tp = PositionGetDouble(POSITION_TP);
   return ((sl > 0 && MathAbs(px - sl) <= lim) || (tp > 0 && MathAbs(px - tp) <= lim));
}

//--- selected pending order: price within the freeze level of the market -> broker refuses modify/delete
bool OrdFrozen()
{
   string sym = OrderGetString(ORDER_SYMBOL);
   long fl = SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   if(fl <= 0) return false;
   double lim = fl * SymbolInfoDouble(sym, SYMBOL_POINT);
   ENUM_ORDER_TYPE t = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   bool buySide = (t == ORDER_TYPE_BUY_LIMIT || t == ORDER_TYPE_BUY_STOP || t == ORDER_TYPE_BUY_STOP_LIMIT);
   double px = buySide ? SymbolInfoDouble(sym, SYMBOL_ASK) : SymbolInfoDouble(sym, SYMBOL_BID);
   return MathAbs(px - OrderGetDouble(ORDER_PRICE_OPEN)) <= lim;
}

void CollectSourcePositions(ulong &out[])
{
   ArrayResize(out, 0);
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(!MatchMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      if(PosIsMirror()) continue;                       // never copy our own mirrors
      Push(out, t);
   }
}

void CollectSourceOrders(ulong &out[])
{
   ArrayResize(out, 0);
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong t = OrderGetTicket(i);
      if(t == 0) continue;
      ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(ot < ORDER_TYPE_BUY_LIMIT || ot > ORDER_TYPE_SELL_STOP_LIMIT) continue;
      if(!MatchMagic(OrderGetInteger(ORDER_MAGIC))) continue;
      if(OrdIsMirror()) continue;
      Push(out, t);
   }
}

void CollectMirrorPositions(ulong &out[])
{
   ArrayResize(out, 0);
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PosLink() != 0) Push(out, t);
   }
}

void CollectMirrorOrders(ulong &out[])
{
   ArrayResize(out, 0);
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong t = OrderGetTicket(i);
      if(t == 0) continue;
      if(OrdLink() != 0) Push(out, t);
   }
}

ulong FindMirrorPos(const ulong key)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PosLink() == key) return t;
   }
   return 0;
}

ulong FindMirrorOrder(const ulong key)
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong t = OrderGetTicket(i);
      if(t == 0) continue;
      if(OrdLink() == key) return t;
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Sync one source POSITION                                         |
//+------------------------------------------------------------------+
void SyncPosition(const ulong key)
{
   if(!PositionSelectByTicket(key)) return;
   string sym = PositionGetString(POSITION_SYMBOL);
   ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double vol = PositionGetDouble(POSITION_VOLUME);
   double sl  = PositionGetDouble(POSITION_SL);
   double tp  = PositionGetDouble(POSITION_TP);
   long   smagic   = PositionGetInteger(POSITION_MAGIC);
   string scomment = PositionGetString(POSITION_COMMENT);
   int    dg  = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double dsl, dtp;
   MapSLTP(sl, tp, dsl, dtp);
   dsl = NormalizeDouble(dsl, dg);
   dtp = NormalizeDouble(dtp, dg);

   if(!MarketOpen(sym)) return;                   // wait for the session instead of sending doomed requests

   ulong mt = FindMirrorPos(key);

   //--- no mirror yet -> open one at market
   if(mt == 0)
   {
      if(IsDone(key)) return;                       // mirror existed before and was closed (SL/TP/manual)

      long mmagic;
      if(!BuildMirrorMagic(smagic, mmagic))
      {
         if(!Contains(g_warned, key))
         {
            Push(g_warned, key);
            PrintFormat("MirrorHedgeEA: cannot build mirror magic from %I64d - #%I64u skipped", smagic, key);
         }
         return;
      }

      ulong mo = FindMirrorOrder(key);              // mirror pending still waiting though source already filled
      if(mo != 0)
      {
         if(!g_trade.OrderDelete(mo)) { Fail("OrderDelete (stale mirror pending)"); return; }
      }
      SymbolSelect(sym, true);
      g_trade.SetTypeFillingBySymbol(sym);
      g_trade.SetExpertMagicNumber((ulong)mmagic);
      string cmt = BuildMirrorComment(scomment);
      double v = CalcVolume(sym, vol);
      bool buy = (ptype == POSITION_TYPE_BUY);
      if(InpInverse) buy = !buy;
      if(!InpInverse && !HasMargin(sym, buy, v))
      {
         if(NowT() - g_lastMarginMsg >= 60)
         {
            g_lastMarginMsg = NowT();
            PrintFormat("MirrorHedgeEA: not enough free margin to mirror #%I64u - waiting", key);
         }
         return;
      }

      bool ok = buy ? g_trade.Buy(v, sym, 0, dsl, dtp, cmt)
                    : g_trade.Sell(v, sym, 0, dsl, dtp, cmt);
      if(!ok && (dsl != 0 || dtp != 0))            // stops too close? open naked, modify loop retries
         ok = buy ? g_trade.Buy(v, sym, 0, 0, 0, cmt)
                  : g_trade.Sell(v, sym, 0, 0, 0, cmt);
      if(ok)
      {
         ulong pid = 0;
         ulong dl = g_trade.ResultDeal();
         if(dl > 0 && HistoryDealSelect(dl)) pid = (ulong)HistoryDealGetInteger(dl, DEAL_POSITION_ID);
         if(pid == 0) pid = g_trade.ResultOrder();
         SetLink(pid, key);
         AddDone(key);
         PrintFormat("MirrorHedgeEA: mirrored #%I64u %s %.2f -> #%I64u magic %I64d", key, sym, v, pid, mmagic);
      }
      else Fail("open mirror position");
      return;
   }

   //--- mirror exists
   AddDone(key);
   if(!PositionSelectByTicket(mt)) return;
   double msl = PositionGetDouble(POSITION_SL);
   double mtp = PositionGetDouble(POSITION_TP);
   double mvol = PositionGetDouble(POSITION_VOLUME);

   // SL / TP changes
   if(InpMirrorSLTP && (Differs(sym, msl, dsl) || Differs(sym, mtp, dtp)))
   {
      if(!PosFrozen() && !g_trade.PositionModify(mt, dsl, dtp)) Fail("PositionModify");
   }

   // partial close of source -> partial close of mirror
   if(InpSyncPartial && InpLotMode != LOT_FIXED)
   {
      double want = CalcVolume(sym, vol);
      double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
      double diff = mvol - want;
      if(diff >= step * 0.999 && want >= SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN))
      {
         g_trade.SetTypeFillingBySymbol(sym);
         if(!PosFrozen() && !g_trade.PositionClosePartial(mt, NormalizeDouble(diff, 8))) Fail("PositionClosePartial");
      }
   }
}

//+------------------------------------------------------------------+
//| Sync one source PENDING ORDER                                    |
//+------------------------------------------------------------------+
void SyncOrder(const ulong key)
{
   if(!InpMirrorPending) return;
   if(!OrderSelect(key)) return;
   ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   string sym   = OrderGetString(ORDER_SYMBOL);
   double vol   = OrderGetDouble(ORDER_VOLUME_CURRENT);
   double price = OrderGetDouble(ORDER_PRICE_OPEN);
   double sl    = OrderGetDouble(ORDER_SL);
   double tp    = OrderGetDouble(ORDER_TP);
   double lim   = OrderGetDouble(ORDER_PRICE_STOPLIMIT);
   long   smagic   = OrderGetInteger(ORDER_MAGIC);
   string scomment = OrderGetString(ORDER_COMMENT);
   ENUM_ORDER_TYPE_TIME tt = (ENUM_ORDER_TYPE_TIME)OrderGetInteger(ORDER_TYPE_TIME);
   datetime ex  = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
   int dg = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

   if(!MarketOpen(sym)) return;

   int mtype = MapOrderType(ot);
   if(mtype < 0)
   {
      if(!Contains(g_warned, key))
      {
         Push(g_warned, key);
         PrintFormat("MirrorHedgeEA: pending #%I64u (%s) has no inverse equivalent - skipped", key, EnumToString(ot));
      }
      return;
   }

   double dsl, dtp;
   MapSLTP(sl, tp, dsl, dtp);
   dsl = NormalizeDouble(dsl, dg);
   dtp = NormalizeDouble(dtp, dg);
   price = NormalizeDouble(price, dg);

   ulong mo = FindMirrorOrder(key);
   if(mo == 0)
   {
      if(IsDone(key) || FindMirrorPos(key) != 0) return;
      long mmagic;
      if(!BuildMirrorMagic(smagic, mmagic))
      {
         if(!Contains(g_warned, key))
         {
            Push(g_warned, key);
            PrintFormat("MirrorHedgeEA: cannot build mirror magic from %I64d - #%I64u skipped", smagic, key);
         }
         return;
      }
      SymbolSelect(sym, true);
      g_trade.SetTypeFillingBySymbol(sym);
      g_trade.SetExpertMagicNumber((ulong)mmagic);
      double v = CalcVolume(sym, vol);
      double limit = InpInverse ? 0.0 : NormalizeDouble(lim, dg);
      if(g_trade.OrderOpen(sym, (ENUM_ORDER_TYPE)mtype, v, limit, price, dsl, dtp, tt, ex, BuildMirrorComment(scomment)))
         SetLink(g_trade.ResultOrder(), key);
      else
         Fail("OrderOpen (mirror pending)");
      return;
   }

   //--- mirror pending exists: keep price / SL / TP / expiration in sync
   if(!OrderSelect(mo)) return;
   double mprice = OrderGetDouble(ORDER_PRICE_OPEN);
   double msl    = OrderGetDouble(ORDER_SL);
   double mtp    = OrderGetDouble(ORDER_TP);
   datetime mex  = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
   if(Differs(sym, mprice, price) ||
      (InpMirrorSLTP && (Differs(sym, msl, dsl) || Differs(sym, mtp, dtp))) ||
      mex != ex)
   {
      double keepSL = InpMirrorSLTP ? dsl : msl;
      double keepTP = InpMirrorSLTP ? dtp : mtp;
      if(!OrdFrozen() && !g_trade.OrderModify(mo, price, keepSL, keepTP, tt, ex, InpInverse ? 0.0 : NormalizeDouble(lim, dg)))
         Fail("OrderModify");
   }
}

//+------------------------------------------------------------------+
//| Tester-only demo source: opens simple trades with the source     |
//| magic so the mirror logic has something to copy when the EA is   |
//| run alone in the Strategy Tester. Never runs outside the tester. |
//+------------------------------------------------------------------+
void DemoSource()
{
   if(!InpTesterDemo || !MQLInfoInteger(MQL_TESTER)) return;

   datetime bar = iTime(_Symbol, _Period, 0);
   if(bar == 0 || bar == g_demoBar) return;             // act once per new bar
   if(!MarketOpen(_Symbol)) return;
   g_demoBar = bar;

   //--- close demo trades held long enough, count the rest
   int open = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != g_demoMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PosIsMirror()) continue;
      long held = (long)((bar - (datetime)PositionGetInteger(POSITION_TIME)) / PeriodSeconds());
      bool closed = false;
      if(held >= InpDemoHoldBars && !PosFrozen()) closed = g_demo.PositionClose(t);
      if(!closed) open++;
   }
   if(open > 0) return;

   //--- open a new demo trade (alternating direction) with SL and TP
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0 || bid <= 0) return;
   double stopsLvl = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double freezeLvl = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double dist = MathMax(ask * 0.004, (MathMax(stopsLvl, freezeLvl) + 10) * _Point * 2);
   double vol  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   if(!HasMargin(_Symbol, g_demoDir < 0, vol)) return;   // next demo trade is a Buy while g_demoDir is -1
   g_demoDir = -g_demoDir;
   g_demo.SetExpertMagicNumber((ulong)g_demoMagic);
   g_demo.SetTypeFillingBySymbol(_Symbol);
   if(g_demoDir > 0)
      g_demo.Buy(vol, _Symbol, 0, NormalizeDouble(ask - dist, _Digits), NormalizeDouble(ask + dist, _Digits), "demo");
   else
      g_demo.Sell(vol, _Symbol, 0, NormalizeDouble(bid + dist, _Digits), NormalizeDouble(bid - dist, _Digits), "demo");
}

//+------------------------------------------------------------------+
//| Main sync                                                        |
//+------------------------------------------------------------------+
void SyncAll()
{
   if(g_busy) return;
   if(!MQLInfoInteger(MQL_TESTER) && !TerminalInfoInteger(TERMINAL_CONNECTED)) return;   // never act on an empty/unsynced trade list
   if(NowT() < g_nextTry) return;
   g_busy = true;

   ulong sp[], so[];
   CollectSourcePositions(sp);
   CollectSourceOrders(so);

   for(int i = 0; i < ArraySize(sp); i++) SyncPosition(sp[i]);
   for(int i = 0; i < ArraySize(so); i++) SyncOrder(so[i]);

   //--- close / delete mirrors whose source is gone
   ulong mp[];
   CollectMirrorPositions(mp);
   for(int i = 0; i < ArraySize(mp); i++)
   {
      if(!PositionSelectByTicket(mp[i])) continue;
      ulong key = PosLink();
      if(key == 0 || Contains(sp, key)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(!MarketOpen(sym) || PosFrozen()) continue;   // retry later
      g_trade.SetTypeFillingBySymbol(sym);
      if(!g_trade.PositionClose(mp[i])) Fail("PositionClose (mirror)");
      else PrintFormat("MirrorHedgeEA: closed mirror #%I64u (source #%I64u gone)", mp[i], key);
   }

   ulong mo[];
   CollectMirrorOrders(mo);
   for(int i = 0; i < ArraySize(mo); i++)
   {
      if(!OrderSelect(mo[i])) continue;
      ulong key = OrdLink();
      if(key == 0 || Contains(so, key) || Contains(sp, key)) continue;
      if(!MarketOpen(OrderGetString(ORDER_SYMBOL)) || OrdFrozen()) continue;
      if(!g_trade.OrderDelete(mo[i])) Fail("OrderDelete (mirror pending)");
   }

   g_busy = false;
}

//+------------------------------------------------------------------+
//| GUI                                                              |
//+------------------------------------------------------------------+
void PLine(const string t, const color c = clrWhite)
{
   ArrayResize(g_lines, g_n + 1);
   ArrayResize(g_cols,  g_n + 1);
   g_lines[g_n] = t;
   g_cols[g_n]  = c;
   g_n++;
}

string MatchText()
{
   switch(InpMatchMode)
   {
      case MATCH_EXACT:    return "EXACT";
      case MATCH_CONTAINS: return "CONTAINS";
   }
   return "STARTS WITH";
}

string LotText()
{
   switch(InpLotMode)
   {
      case LOT_FIXED:   return "FIXED " + DoubleToString(InpFixedLot, 2) + " lots";
      case LOT_PERCENT: return DoubleToString(InpLotPercent, 1) + "% of source";
   }
   return "SAME AS SOURCE";
}

string TypeShort(const long t, const bool isPos)
{
   if(isPos) return (t == POSITION_TYPE_BUY) ? "BUY " : "SELL";
   return StringSubstr(EnumToString((ENUM_ORDER_TYPE)t), 11);
}

void DrawPanel()
{
   if(!InpShowPanel) return;
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return;
   g_n = 0;

   string pats = "";
   for(int i = 0; i < ArraySize(g_pat); i++) pats += (i > 0 ? ", " : "") + g_pat[i];

   PLine("MIRROR / HEDGE EA   " + (InpInverse ? "[INVERSE]" : "[SAME DIRECTION]"), clrGold);
   PLine("Rule  : magic " + MatchText() + "  [" + pats + "]");
   PLine("Lots  : " + LotText());
   PLine("Mirror: magic +" + InpMagicSuffix + ", comment +" + InpCommentSuffix + " | SL/TP " + (InpMirrorSLTP ? "on" : "off") +
         " | Pending " + (InpMirrorPending ? "on" : "off"), clrSilver);

   ulong sp[], so[];
   CollectSourcePositions(sp);
   CollectSourceOrders(so);

   //--- distinct source magics being copied
   long mg[]; int cp[], co[];
   for(int i = 0; i < ArraySize(sp); i++)
   {
      if(!PositionSelectByTicket(sp[i])) continue;
      long m = PositionGetInteger(POSITION_MAGIC);
      int k = -1;
      for(int j = 0; j < ArraySize(mg); j++) if(mg[j] == m) { k = j; break; }
      if(k < 0) { k = ArraySize(mg); ArrayResize(mg, k + 1); ArrayResize(cp, k + 1); ArrayResize(co, k + 1); mg[k] = m; cp[k] = 0; co[k] = 0; }
      cp[k]++;
   }
   for(int i = 0; i < ArraySize(so); i++)
   {
      if(!OrderSelect(so[i])) continue;
      long m = OrderGetInteger(ORDER_MAGIC);
      int k = -1;
      for(int j = 0; j < ArraySize(mg); j++) if(mg[j] == m) { k = j; break; }
      if(k < 0) { k = ArraySize(mg); ArrayResize(mg, k + 1); ArrayResize(cp, k + 1); ArrayResize(co, k + 1); mg[k] = m; cp[k] = 0; co[k] = 0; }
      co[k]++;
   }

   PLine("");
   PLine("Copying magics (" + (string)ArraySize(mg) + "):", clrDeepSkyBlue);
   if(ArraySize(mg) == 0) PLine("  none active", clrGray);
   for(int j = 0; j < ArraySize(mg) && j < InpMaxRows; j++)
   {
      long mm = 0;
      string mms = BuildMirrorMagic(mg[j], mm) ? (string)mm : "n/a";
      PLine(StringFormat("  %-10I64d -> %-12s open %d  pending %d", mg[j], mms, cp[j], co[j]));
   }
   if(ArraySize(mg) > InpMaxRows) PLine("  ... +" + (string)(ArraySize(mg) - InpMaxRows) + " more", clrGray);

   //--- open positions: source -> mirror
   double srcPnl = 0, mirPnl = 0;
   PLine("");
   PLine("Open positions (source -> mirror):", clrDeepSkyBlue);
   if(ArraySize(sp) == 0) PLine("  none", clrGray);
   for(int i = 0; i < ArraySize(sp); i++)
   {
      if(!PositionSelectByTicket(sp[i])) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      long   ty  = PositionGetInteger(POSITION_TYPE);
      double vol = PositionGetDouble(POSITION_VOLUME);
      srcPnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      ulong mt = FindMirrorPos(sp[i]);
      string line; color c;
      if(mt != 0 && PositionSelectByTicket(mt))
      {
         double mv = PositionGetDouble(POSITION_VOLUME);
         double mp = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         line = StringFormat("  #%I64u %-8s %s %.2f -> #%I64u %s %.2f %+.2f", sp[i], sym, TypeShort(ty, true), vol,
                             mt, TypeShort(PositionGetInteger(POSITION_TYPE), true), mv, mp);
         c = clrLime;
      }
      else
      {
         line = StringFormat("  #%I64u %-8s %s %.2f -> waiting", sp[i], sym, TypeShort(ty, true), vol);
         c = clrOrange;
      }
      if(i < InpMaxRows) PLine(line, c);
   }
   if(ArraySize(sp) > InpMaxRows) PLine("  ... +" + (string)(ArraySize(sp) - InpMaxRows) + " more", clrGray);

   //--- pending orders: source -> mirror
   PLine("");
   PLine("Pending orders (source -> mirror):", clrDeepSkyBlue);
   if(ArraySize(so) == 0) PLine("  none", clrGray);
   for(int i = 0; i < ArraySize(so); i++)
   {
      if(!OrderSelect(so[i])) continue;
      string sym = OrderGetString(ORDER_SYMBOL);
      long   ty  = OrderGetInteger(ORDER_TYPE);
      double vol = OrderGetDouble(ORDER_VOLUME_CURRENT);
      double pr  = OrderGetDouble(ORDER_PRICE_OPEN);
      ulong mo = FindMirrorOrder(so[i]);
      string line; color c;
      if(mo != 0 && OrderSelect(mo))
      {
         line = StringFormat("  #%I64u %-8s %s %.2f @%s -> #%I64u %s", so[i], sym, TypeShort(ty, false), vol,
                             DoubleToString(pr, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)),
                             mo, TypeShort(OrderGetInteger(ORDER_TYPE), false));
         c = clrLime;
      }
      else
      {
         line = StringFormat("  #%I64u %-8s %s %.2f @%s -> %s", so[i], sym, TypeShort(ty, false), vol,
                             DoubleToString(pr, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)),
                             InpMirrorPending ? "waiting" : "off");
         c = InpMirrorPending ? clrOrange : clrGray;
      }
      if(i < InpMaxRows) PLine(line, c);
   }
   if(ArraySize(so) > InpMaxRows) PLine("  ... +" + (string)(ArraySize(so) - InpMaxRows) + " more", clrGray);

   //--- totals
   ulong mp[];
   CollectMirrorPositions(mp);
   for(int i = 0; i < ArraySize(mp); i++)
      if(PositionSelectByTicket(mp[i])) mirPnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   PLine("");
   PLine(StringFormat("P/L  source %+.2f | mirror %+.2f | net %+.2f", srcPnl, mirPnl, srcPnl + mirPnl), clrWhite);

   //--- render
   int lh = InpFontSize + 6;
   int h  = g_n * lh + 12;
   string bg = PFX + "BG";
   if(ObjectFind(0, bg) < 0) ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, InpPanelWidth);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'18,22,30');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrDimGray);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);

   for(int i = 0; i < g_n; i++)
   {
      string nm = PFX + "L" + (string)i;
      if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, InpPanelX + 8);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, InpPanelY + 6 + i * lh);
      ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, g_cols[i]);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetString(0, nm, OBJPROP_TEXT, g_lines[i] == "" ? " " : g_lines[i]);
   }
   // remove leftover label rows from a previously longer panel
   for(int i = g_n; ObjectFind(0, PFX + "L" + (string)i) >= 0; i++)
      ObjectDelete(0, PFX + "L" + (string)i);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Init / Deinit / Events                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Alert("MirrorHedgeEA requires a HEDGING account (netting would merge mirror and source positions).");
      return INIT_FAILED;
   }

   if(InpMagicSuffix == "" || InpCommentSuffix == "")
   {
      Alert("MirrorHedgeEA: magic suffix and comment suffix must not be empty.");
      return INIT_PARAMETERS_INCORRECT;
   }

   //--- parse patterns
   string parts[];
   int n = StringSplit(InpMagicPatterns, ',', parts);
   ArrayResize(g_pat, 0);
   for(int i = 0; i < n; i++)
   {
      string p = parts[i];
      StringTrimLeft(p);
      StringTrimRight(p);
      if(p == "") continue;
      int k = ArraySize(g_pat);
      ArrayResize(g_pat, k + 1);
      g_pat[k] = p;
   }
   if(ArraySize(g_pat) == 0)
   {
      Alert("MirrorHedgeEA: no magic pattern given - nothing to mirror.");
      return INIT_PARAMETERS_INCORRECT;
   }

   g_trade.SetDeviationInPoints(InpDeviation);
   g_trade.SetAsyncMode(false);

   //--- tester demo source uses the first numeric pattern as its magic (falls back to 1001)
   long dm = StringToInteger(g_pat[0]);
   g_demoMagic = (dm > 0) ? dm : 1001;
   g_demo.SetDeviationInPoints(InpDeviation);

   //--- rebuild "already mirrored" memory from history so closed mirrors are never re-opened after a restart
   ArrayResize(g_done, 0);
   if(HistorySelect(0, TimeCurrent() + 86400))
   {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
      {
         ulong d = HistoryDealGetTicket(i);
         if(d == 0) continue;
         if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
         if(!MagicHasSuffix(HistoryDealGetInteger(d, DEAL_MAGIC))) continue;
         ulong k = GetLink((ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID));
         if(k != 0) AddDone(k);
      }
   }

   //--- optionally ignore whatever already exists at start
   if(!InpMirrorExisting)
   {
      ulong sp[], so[];
      CollectSourcePositions(sp);
      CollectSourceOrders(so);
      for(int i = 0; i < ArraySize(sp); i++) AddDone(sp[i]);
      for(int i = 0; i < ArraySize(so); i++) AddDone(so[i]);
   }

   EventSetMillisecondTimer(MathMax(50, InpTimerMs));
   DrawPanel();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
}

void OnTimer()
{
   SyncAll();
   ulong now = GetTickCount64();
   if(now - g_lastPanel >= 1000)
   {
      g_lastPanel = now;
      DrawPanel();
   }
}

void OnTick()
{
   DemoSource();
   SyncAll();
}
//+------------------------------------------------------------------+
