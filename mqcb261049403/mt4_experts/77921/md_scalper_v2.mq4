//+------------------------------------------------------------------+
//|                                                MD Scalper v2.0   |
//|  Pending-stop scalper on a 3-period MA channel (High/Low MA)     |
//|  Modes: Reversal (original) / Trend (with direction) / Both      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2027 MD"
#property link      "https://forexlife.gumroad.com/"
#property version   "2.00"
#property strict
#property description "MD Scalper  Reversal / Trend / Both modes, broker-safe order handling"

#define SPREAD_SAMPLES 30

enum ENUM_TRADE_MODE
{
   TM_REVERSAL = 0,   // Reversal (original: order behind price)
   TM_TREND    = 1,   // Trend (order in direction of price)
   TM_BOTH     = 2    // Both (straddle, one cancels the other)
};

enum ENUM_LOT_MODE
{
   LM_FIXED    = 0,   // Fixed lots
   LM_RISK_PCT = 1,   // % of balance risked at StopLoss
   LM_LEVERAGE = 2    // Original: Balance x Leverage x Risk% / ContractSize
};

//--- Strategy
input string __s1 = "---------- Strategy ----------";          // ----
input ENUM_TRADE_MODE TradeMode = TM_TREND;                    // Trade mode
input int    MAPeriod           = 3;                           // MA period
input ENUM_MA_METHOD MAMethod   = MODE_SMMA;                   // MA method (Smoothed)
input int    Filter             = 15;                          // Min current-bar range (points)
input bool   KeepLastDirection  = false;                       // Keep last breakout direction while price is inside MA channel

//--- Orders
input string __s2 = "---------- Orders ----------";            // ----
input int    Limit              = 2;                           // Pending order offset from price (points)
input int    StopLoss           = 10;                          // Initial stop loss (points), 0 = none
input int    TakeProfit         = 0;                           // Take profit (points), 0 = none
input int    Distance           = 2;                           // Trailing distance (points), <0 = no trailing
input int    TrailStart         = 0;                           // Start trailing after this profit (points)
input int    TrailStep          = 1;                           // Min SL improvement per modify (points)
input int    PendingStep        = 1;                           // Min pending-order move per modify (points)

//--- Broker / latency safety
input string __s3 = "---------- Broker / Latency ----------";  // ----
input bool   AutoStopLevel      = true;                        // Auto-respect broker stop level
input int    StopLevelBuffer    = 1;                           // Extra points above stop level
input int    ExtraLatencyPoints = 0;                           // Extra points added to offset & trail (latency cushion)
input int    MinModifyMs        = 150;                         // Min ms between order modifications
input int    OrderRetries       = 2;                           // Retries on requote/busy errors
input int    RetryDelayMs       = 50;                          // Delay between retries (ms)
input int    FailBackoffMs      = 1000;                        // Pause new entries after failed send (ms)
input int    Slippage           = 3;                           // Slippage (points)
input int    PendingMaxAgeSec   = 30;                          // Delete pending older than (sec), 0 = off
input int    PendingExpirySec   = 0;                           // Server-side expiry (sec), 0 = off
input int    MaxLatencyMs       = 0;                           // Block entries if avg latency above (ms), 0 = off

//--- Spread
input string __s4 = "---------- Spread ----------";            // ----
input double MaxSpreadPlusCommission = 15;                     // Max spread + commission (points), 0 = off
input double CommissionPoints   = -1;                          // Commission in points (-1 = auto from history)

//--- Money management
input string __s5 = "---------- Money Management ----------";  // ----
input ENUM_LOT_MODE LotMode     = LM_FIXED;                    // Lot mode
input double FixedLots          = 0.01;                        // Fixed lots
input double RiskPercent        = 1.0;                         // Risk % (for risk / leverage modes)
input double MinLots            = 0.01;                        // Min lots
input double MaxLots            = 100000.0;                    // Max lots

//--- Protection
input string __s6 = "---------- Protection ----------";        // ----
input int    MaxTradesPerDay    = 0;                           // Max trades per day, 0 = off
input double DailyLossPercent   = 0;                           // Stop trading after daily loss % of balance, 0 = off
input int    CooldownSeconds    = 0;                           // Pause after a trade closes (sec)
input int    FridayCutoffHour   = 0;                           // No entries on Friday from this hour (server), 0 = off

//--- Time filter (server time)
input string __s7 = "---------- Time Filter ----------";       // ----
input int    StartHour          = 0;
input int    StartMinute        = 0;
input int    EndHour            = 23;
input int    EndMinute          = 59;

//--- Identity
input string __s8 = "---------- ID ----------";                // ----
input int    MagicNumber        = 2027;
input string TradeComment       = "Md Scalper";

//--- globals
double   g_spreadHist[SPREAD_SAMPLES];
int      g_spreadCount   = 0;
int      g_spreadIdx     = 0;
double   g_commission    = 0.0;
bool     g_commKnown     = false;
datetime g_lastCommScan  = 0;
double   g_latency       = 0.0;
uint     g_lastModPend   = 0;
uint     g_lastModPos    = 0;
uint     g_lastFailMs    = 0;
bool     g_hasFail       = false;
bool     g_expiryOK      = true;
int      g_lastDir       = 0;
datetime g_lastCloseTime = 0;
datetime g_lastStatTime  = 0;
double   g_dayPL         = 0.0;
int      g_dayTrades     = 0;
double   g_maxSpread     = 0.0;
string   g_lastLogKey    = "";
uint     g_lastLogMs     = 0;
uint     g_lastCommentMs = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   if(MAPeriod < 1)
   {
      Alert("MD Scalper: MAPeriod must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
   }
   ArrayInitialize(g_spreadHist, 0.0);
   g_spreadCount = 0;
   g_spreadIdx   = 0;
   g_maxSpread   = NormalizeDouble(MaxSpreadPlusCommission * Point, Digits + 1);
   g_commKnown   = false;
   g_lastCommScan = 0;
   g_latency     = 0.0;
   g_hasFail     = false;
   g_expiryOK    = true;
   g_lastDir     = 0;

   Print("MD Scalper v2 started on ", Symbol(), " Digits=", Digits, " Point=", DoubleToString(Point, Digits),
         " StopLevel=", DoubleToString(MarketInfo(Symbol(), MODE_STOPLEVEL), 0),
         " FreezeLevel=", DoubleToString(MarketInfo(Symbol(), MODE_FREEZELEVEL), 0),
         " Mode=", EnumToString(TradeMode));
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
}
//+------------------------------------------------------------------+
//| helpers                                                          |
//+------------------------------------------------------------------+
string ErrText(int e)
{
   switch(e)
   {
      case 0:   return("no error");
      case 1:   return("no error, result unknown");
      case 2:   return("common error");
      case 3:   return("invalid trade parameters");
      case 4:   return("trade server busy");
      case 6:   return("no connection with trade server");
      case 8:   return("too frequent requests");
      case 64:  return("account disabled");
      case 65:  return("invalid account");
      case 128: return("trade timeout");
      case 129: return("invalid price");
      case 130: return("invalid stops");
      case 131: return("invalid trade volume");
      case 132: return("market is closed");
      case 133: return("trade is disabled");
      case 134: return("not enough money");
      case 135: return("price changed");
      case 136: return("off quotes");
      case 137: return("broker is busy");
      case 138: return("requote");
      case 139: return("order is locked");
      case 141: return("too many requests");
      case 145: return("modification denied, too close to market (freeze level)");
      case 146: return("trade context is busy");
      case 147: return("expiration denied by broker");
      case 148: return("too many open/pending orders");
      case 149: return("hedging prohibited");
      case 150: return("prohibited by FIFO rule");
   }
   return("error " + IntegerToString(e));
}
//+------------------------------------------------------------------+
bool Retryable(int e)
{
   return(e == 4 || e == 6 || e == 8 || e == 128 || e == 129 || e == 135 ||
          e == 136 || e == 137 || e == 138 || e == 141 || e == 146);
}
//+------------------------------------------------------------------+
bool Due(uint last, int ms)
{
   if(IsTesting()) return(true);
   return((int)(GetTickCount() - last) >= ms);
}
//+------------------------------------------------------------------+
void RateLog(string key, string msg)
{
   uint now = GetTickCount();
   if(key == g_lastLogKey && (int)(now - g_lastLogMs) < 2000) return;
   g_lastLogKey = key;
   g_lastLogMs  = now;
   Print(msg);
}
//+------------------------------------------------------------------+
void LogErr(string what, int err)
{
   RateLog(what + IntegerToString(err),
           what + " failed, error " + IntegerToString(err) + " (" + ErrText(err) + ")" +
           " Bid=" + DoubleToString(Bid, Digits) + " Ask=" + DoubleToString(Ask, Digits) +
           " StopLevel=" + DoubleToString(MarketInfo(Symbol(), MODE_STOPLEVEL), 0));
}
//+------------------------------------------------------------------+
void UpdateLatency(int ms)
{
   if(ms < 0) ms = 0;
   if(g_latency <= 0.0) g_latency = ms;
   else g_latency = 0.8 * g_latency + 0.2 * ms;
}
//+------------------------------------------------------------------+
double StopLevelDist()
{
   return(MarketInfo(Symbol(), MODE_STOPLEVEL) * Point);
}
//+------------------------------------------------------------------+
double FreezeDist()
{
   return(MarketInfo(Symbol(), MODE_FREEZELEVEL) * Point);
}
//+------------------------------------------------------------------+
double PadDist()
{
   if(!AutoStopLevel) return(0.0);
   return(StopLevelDist() + StopLevelBuffer * Point);
}
//+------------------------------------------------------------------+
void UpdateSpread()
{
   g_spreadHist[g_spreadIdx] = Ask - Bid;
   g_spreadIdx = (g_spreadIdx + 1) % SPREAD_SAMPLES;
   if(g_spreadCount < SPREAD_SAMPLES) g_spreadCount++;
}
//+------------------------------------------------------------------+
double AvgSpread()
{
   if(g_spreadCount <= 0) return(Ask - Bid);
   double sum = 0.0;
   for(int i = 0; i < g_spreadCount; i++) sum += g_spreadHist[i];
   return(sum / g_spreadCount);
}
//+------------------------------------------------------------------+
void DetectCommission()
{
   if(CommissionPoints >= 0.0)
   {
      g_commission = CommissionPoints * Point;
      g_commKnown  = true;
      return;
   }
   if(g_commKnown) return;
   datetime now = TimeCurrent();
   if(g_lastCommScan != 0 && now - g_lastCommScan < 30) return;
   g_lastCommScan = now;

   int total = OrdersHistoryTotal();
   for(int i = total - 1; i >= 0 && i >= total - 500; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderType() > OP_SELL) continue;
      if(OrderProfit() == 0.0 || OrderClosePrice() == OrderOpenPrice()) continue;
      double perUnit = MathAbs(OrderProfit() / (OrderClosePrice() - OrderOpenPrice()));
      if(perUnit <= 0.0) continue;
      g_commission = -OrderCommission() / perUnit;
      if(g_commission < 0.0) g_commission = 0.0;
      g_commKnown = true;
      break;
   }
}
//+------------------------------------------------------------------+
bool InTradingWindow()
{
   datetime t = TimeCurrent();
   int m = TimeHour(t) * 60 + TimeMinute(t);
   int s = StartHour * 60 + StartMinute;
   int e = EndHour * 60 + EndMinute;
   bool ok;
   if(s == e)      ok = true;
   else if(s < e)  ok = (m >= s && m < e);
   else            ok = (m >= s || m < e);
   if(!ok) return(false);
   if(FridayCutoffHour > 0 && TimeDayOfWeek(t) == 5 && TimeHour(t) >= FridayCutoffHour) return(false);
   return(true);
}
//+------------------------------------------------------------------+
void RefreshDayStats(bool force)
{
   datetime now = TimeCurrent();
   if(!force && now == g_lastStatTime) return;
   g_lastStatTime = now;

   datetime dayStart = iTime(Symbol(), PERIOD_D1, 0);
   if(dayStart <= 0) dayStart = now - (now % 86400);

   double pl = 0.0;
   int    n  = 0;
   int    older = 0;
   datetime lastClose = g_lastCloseTime;

   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;
      if(OrderType() > OP_SELL) continue;
      if(OrderCloseTime() < dayStart)
      {
         older++;
         if(older > 50) break;
         continue;
      }
      pl += OrderProfit() + OrderSwap() + OrderCommission();
      n++;
      if(OrderCloseTime() > lastClose) lastClose = OrderCloseTime();
   }
   g_dayPL         = pl;
   g_dayTrades     = n;
   g_lastCloseTime = lastClose;
}
//+------------------------------------------------------------------+
bool DailyLimitHit()
{
   if(DailyLossPercent <= 0.0) return(false);
   double startBal = AccountBalance() - g_dayPL;
   return(g_dayPL <= -startBal * DailyLossPercent / 100.0);
}
//+------------------------------------------------------------------+
//| Signal: +1 price above MA(High), -1 price below MA(Low)          |
//+------------------------------------------------------------------+
int GetSignal()
{
   double hi = iHigh(NULL, 0, 0);
   double lo = iLow(NULL, 0, 0);
   if(NormalizeDouble(hi - lo, Digits) <= NormalizeDouble(Filter * Point, Digits)) return(0);

   double maLow  = iMA(NULL, 0, MAPeriod, 0, MAMethod, PRICE_LOW,  0);
   double maHigh = iMA(NULL, 0, MAPeriod, 0, MAMethod, PRICE_HIGH, 0);

   if(Bid < maLow)        g_lastDir = -1;
   else if(Bid > maHigh)  g_lastDir = 1;
   else if(!KeepLastDirection) return(0);

   return(g_lastDir);
}
//+------------------------------------------------------------------+
//| Is a pending type wanted for this signal in the current mode?    |
//+------------------------------------------------------------------+
bool Wanted(int type, int sig)
{
   int trendType = (sig > 0) ? OP_BUYSTOP  : OP_SELLSTOP;
   int revType   = (sig > 0) ? OP_SELLSTOP : OP_BUYSTOP;
   if(TradeMode == TM_TREND)    return(type == trendType);
   if(TradeMode == TM_REVERSAL) return(type == revType);
   return(true);
}
//+------------------------------------------------------------------+
void CountOrders(int &positions, int &pendings)
{
   positions = 0;
   pendings  = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;
      int t = OrderType();
      if(t <= OP_SELL) positions++;
      else if(t == OP_BUYSTOP || t == OP_SELLSTOP) pendings++;
   }
}
//+------------------------------------------------------------------+
bool HasPendingType(int type)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;
      if(OrderType() == type) return(true);
   }
   return(false);
}
//+------------------------------------------------------------------+
//| Lots                                                             |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
{
   double step = MarketInfo(Symbol(), MODE_LOTSTEP);
   double lo   = MathMax(MinLots, MarketInfo(Symbol(), MODE_MINLOT));
   double hi   = MathMin(MaxLots, MarketInfo(Symbol(), MODE_MAXLOT));
   if(step <= 0.0) step = 0.01;
   lots = MathFloor(lots / step + 0.0000001) * step;
   if(lots < lo) lots = lo;
   if(lots > hi) lots = hi;
   int d = 0;
   double s = step;
   while(d < 8 && MathAbs(s - MathRound(s)) > 0.0000001)
   {
      s *= 10.0;
      d++;
   }
   return(NormalizeDouble(lots, d));
}
//+------------------------------------------------------------------+
double MarginSafeLots(int cmd, double lots)
{
   int cmdCheck = (cmd == OP_BUYSTOP || cmd == OP_BUY) ? OP_BUY : OP_SELL;
   double minLot = MathMax(MinLots, MarketInfo(Symbol(), MODE_MINLOT));
   for(int i = 0; i < 12; i++)
   {
      ResetLastError();
      double fm = AccountFreeMarginCheck(Symbol(), cmdCheck, lots);
      int err = GetLastError();
      if(fm > 0.0 && err != 134) return(lots);
      if(lots <= minLot) return(0.0);
      lots = NormalizeLots(lots * 0.5);
   }
   return(0.0);
}
//+------------------------------------------------------------------+
double CalcLots(int cmd, double slDist)
{
   double lots = FixedLots;
   if(LotMode == LM_RISK_PCT)
   {
      double tv = MarketInfo(Symbol(), MODE_TICKVALUE);
      double ts = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(tv > 0.0 && ts > 0.0 && slDist > 0.0)
      {
         double lossPerLot = ((slDist + (Ask - Bid)) / ts) * tv;
         if(lossPerLot > 0.0) lots = AccountBalance() * RiskPercent / 100.0 / lossPerLot;
      }
   }
   else if(LotMode == LM_LEVERAGE)
   {
      double cs = MarketInfo(Symbol(), MODE_LOTSIZE);
      if(cs > 0.0) lots = AccountBalance() * AccountLeverage() * RiskPercent / 100.0 / cs;
   }
   lots = NormalizeLots(lots);
   return(MarginSafeLots(cmd, lots));
}
//+------------------------------------------------------------------+
//| Place one pending stop order                                     |
//+------------------------------------------------------------------+
int PlacePending(int type)
{
   for(int attempt = 0; attempt <= OrderRetries; attempt++)
   {
      if(IsStopped()) return(-1);
      if(IsTradeContextBusy())
      {
         Sleep(RetryDelayMs);
         continue;
      }
      RefreshRates();

      double pad  = PadDist();
      double off  = MathMax(Limit * Point, pad) + ExtraLatencyPoints * Point;
      double slD  = MathMax(StopLoss * Point, pad);
      double tpD  = MathMax(TakeProfit * Point, pad);
      double price, sl = 0.0, tp = 0.0;

      if(type == OP_BUYSTOP)
      {
         price = NormalizeDouble(Ask + off, Digits);
         if(StopLoss   > 0) sl = NormalizeDouble(price - slD, Digits);
         if(TakeProfit > 0) tp = NormalizeDouble(price + tpD, Digits);
      }
      else
      {
         price = NormalizeDouble(Bid - off, Digits);
         if(StopLoss   > 0) sl = NormalizeDouble(price + slD, Digits);
         if(TakeProfit > 0) tp = NormalizeDouble(price - tpD, Digits);
      }

      double lots = CalcLots(type, slD);
      if(lots <= 0.0)
      {
         RateLog("lots0", "MD Scalper: lot size is 0 (not enough free margin), entry skipped");
         return(-1);
      }

      datetime expiry = 0;
      if(PendingExpirySec > 0 && g_expiryOK) expiry = TimeCurrent() + PendingExpirySec;

      uint t0 = GetTickCount();
      int ticket = OrderSend(Symbol(), type, lots, price, Slippage, sl, tp, TradeComment,
                             MagicNumber, expiry, (type == OP_BUYSTOP) ? clrLime : clrOrange);
      UpdateLatency((int)(GetTickCount() - t0));
      if(ticket > 0) return(ticket);

      int err = GetLastError();
      LogErr((type == OP_BUYSTOP) ? "BUYSTOP send" : "SELLSTOP send", err);
      if(err == 147 && expiry != 0)
      {
         g_expiryOK = false;
         continue;
      }
      if(!Retryable(err)) break;
      Sleep(RetryDelayMs);
   }
   g_hasFail   = true;
   g_lastFailMs = GetTickCount();
   return(-1);
}
//+------------------------------------------------------------------+
void TryEntries(int sig)
{
   int types[2];
   int n = 0;
   if(TradeMode == TM_TREND || TradeMode == TM_BOTH)
   {
      types[n] = (sig > 0) ? OP_BUYSTOP : OP_SELLSTOP;
      n++;
   }
   if(TradeMode == TM_REVERSAL || TradeMode == TM_BOTH)
   {
      types[n] = (sig > 0) ? OP_SELLSTOP : OP_BUYSTOP;
      n++;
   }
   for(int i = 0; i < n; i++)
   {
      if(HasPendingType(types[i])) continue;
      PlacePending(types[i]);
   }
}
//+------------------------------------------------------------------+
void DeleteOrder(int ticket, string why)
{
   if(!OrderDelete(ticket))
   {
      int err = GetLastError();
      LogErr("Delete (" + why + ")", err);
   }
}
//+------------------------------------------------------------------+
void DeleteAllPendings()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;
      int t = OrderType();
      if(t == OP_BUYSTOP || t == OP_SELLSTOP) DeleteOrder(OrderTicket(), "entry blocked");
   }
}
//+------------------------------------------------------------------+
//| Trailing stop of an open position (same method as original)      |
//+------------------------------------------------------------------+
void TrailPosition(int type)
{
   if(Distance < 0) return;
   if(!Due(g_lastModPos, MinModifyMs)) return;

   double frz   = FreezeDist();
   double dist  = MathMax(Distance * Point, PadDist()) + ExtraLatencyPoints * Point;
   double step  = MathMax(1, TrailStep) * Point;
   double curSL = NormalizeDouble(OrderStopLoss(), Digits);
   double tpNow = OrderTakeProfit();
   double openP = OrderOpenPrice();
   double newSL;

   if(type == OP_BUY)
   {
      if(Bid - openP < TrailStart * Point) return;
      newSL = NormalizeDouble(Bid - dist, Digits);
      if(!(curSL == 0.0 || newSL - curSL >= step - Point * 0.1)) return;
      if(frz > 0.0)
      {
         if(curSL != 0.0 && MathAbs(Bid - curSL) <= frz) return;
         if(tpNow != 0.0 && MathAbs(tpNow - Bid) <= frz) return;
      }
   }
   else
   {
      if(openP - Ask < TrailStart * Point) return;
      newSL = NormalizeDouble(Ask + dist, Digits);
      if(!(curSL == 0.0 || curSL - newSL >= step - Point * 0.1)) return;
      if(frz > 0.0)
      {
         if(curSL != 0.0 && MathAbs(Ask - curSL) <= frz) return;
         if(tpNow != 0.0 && MathAbs(tpNow - Ask) <= frz) return;
      }
   }

   uint t0 = GetTickCount();
   bool ok = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0,
                         (type == OP_BUY) ? clrLime : clrOrange);
   UpdateLatency((int)(GetTickCount() - t0));
   g_lastModPos = GetTickCount();
   if(!ok)
   {
      int err = GetLastError();
      if(err != 1) LogErr((type == OP_BUY) ? "BUY trail" : "SELL trail", err);
   }
}
//+------------------------------------------------------------------+
//| Manage pending stop: cleanup + trail toward price                |
//+------------------------------------------------------------------+
void ManagePending(int type, int sig, bool hasPosition)
{
   int ticket = OrderTicket();

   if(hasPosition)
   {
      DeleteOrder(ticket, "position open");
      return;
   }
   if(PendingMaxAgeSec > 0 && TimeCurrent() - OrderOpenTime() >= PendingMaxAgeSec)
   {
      DeleteOrder(ticket, "max age");
      return;
   }
   if(sig != 0 && !Wanted(type, sig))
   {
      DeleteOrder(ticket, "signal flipped");
      return;
   }
   if(!Due(g_lastModPend, MinModifyMs)) return;

   double frz   = FreezeDist();
   double pad   = PadDist();
   double off   = MathMax(Limit * Point, pad) + ExtraLatencyPoints * Point;
   double slD   = MathMax(StopLoss * Point, pad);
   double tpD   = MathMax(TakeProfit * Point, pad);
   double pstep = MathMax(1, PendingStep) * Point;
   double curOpen = NormalizeDouble(OrderOpenPrice(), Digits);
   double newPrice, newSL = 0.0, newTP = 0.0;

   if(type == OP_BUYSTOP)
   {
      newPrice = NormalizeDouble(Ask + off, Digits);
      if(curOpen - newPrice < pstep - Point * 0.1) return;     // buy stop only follows price down
      if(frz > 0.0 && MathAbs(curOpen - Ask) <= frz) return;
      if(StopLoss   > 0) newSL = NormalizeDouble(newPrice - slD, Digits);
      if(TakeProfit > 0) newTP = NormalizeDouble(newPrice + tpD, Digits);
   }
   else
   {
      newPrice = NormalizeDouble(Bid - off, Digits);
      if(newPrice - curOpen < pstep - Point * 0.1) return;     // sell stop only follows price up
      if(frz > 0.0 && MathAbs(Bid - curOpen) <= frz) return;
      if(StopLoss   > 0) newSL = NormalizeDouble(newPrice + slD, Digits);
      if(TakeProfit > 0) newTP = NormalizeDouble(newPrice - tpD, Digits);
   }

   uint t0 = GetTickCount();
   bool ok = OrderModify(ticket, newPrice, newSL, newTP, OrderExpiration(),
                         (type == OP_BUYSTOP) ? clrLime : clrOrange);
   UpdateLatency((int)(GetTickCount() - t0));
   g_lastModPend = GetTickCount();
   if(!ok)
   {
      int err = GetLastError();
      if(err != 1) LogErr((type == OP_BUYSTOP) ? "BUYSTOP modify" : "SELLSTOP modify", err);
   }
}
//+------------------------------------------------------------------+
void ManageOrders(int sig, bool hasPosition)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;
      int type = OrderType();
      if(type == OP_BUY || type == OP_SELL)              TrailPosition(type);
      else if(type == OP_BUYSTOP || type == OP_SELLSTOP) ManagePending(type, sig, hasPosition);
   }
}
//+------------------------------------------------------------------+
//| Reason why NEW entries are not allowed ("" = allowed)            |
//+------------------------------------------------------------------+
string EntryBlockReason(int positions)
{
   if(!IsExpertEnabled() || !IsTradeAllowed())          return("trading not allowed");
   if(MarketInfo(Symbol(), MODE_TRADEALLOWED) == 0.0)   return("market closed");
   if(!InTradingWindow())                               return("outside time window");
   if(g_maxSpread > 0.0)
   {
      if(AvgSpread() + g_commission > g_maxSpread)      return("avg spread too high");
      if((Ask - Bid) + g_commission > g_maxSpread)      return("spread spike");
   }
   if(DailyLimitHit())                                  return("daily loss limit");
   if(MaxTradesPerDay > 0 && g_dayTrades + positions >= MaxTradesPerDay) return("max trades per day");
   if(CooldownSeconds > 0 && g_lastCloseTime > 0 && TimeCurrent() - g_lastCloseTime < CooldownSeconds) return("cooldown");
   if(MaxLatencyMs > 0 && g_latency > MaxLatencyMs)     return("latency too high");
   if(g_hasFail && !Due(g_lastFailMs, FailBackoffMs))   return("backoff after failed order");
   return("");
}
//+------------------------------------------------------------------+
void ShowStatus(int sig, int pos, int pend, string block)
{
   if(IsOptimization()) return;
   uint now = GetTickCount();
   if((int)(now - g_lastCommentMs) < 500) return;
   g_lastCommentMs = now;

   string modeTxt = "Trend";
   if(TradeMode == TM_REVERSAL) modeTxt = "Reversal";
   if(TradeMode == TM_BOTH)     modeTxt = "Both";
   string sigTxt = "none";
   if(sig > 0) sigTxt = "UP";
   if(sig < 0) sigTxt = "DOWN";

   string s = "MD Scalper v2.0   Mode: " + modeTxt + "\n";
   s += "Signal: " + sigTxt + "   Positions: " + IntegerToString(pos) + "   Pending: " + IntegerToString(pend) + "\n";
   s += "Spread: " + DoubleToString((Ask - Bid) / Point, 1) + "  Avg: " + DoubleToString(AvgSpread() / Point, 1) +
        "  Comm: " + DoubleToString(g_commission / Point, 1) + "  Max: " + DoubleToString(MaxSpreadPlusCommission, 1) + " pts\n";
   s += "StopLevel: " + DoubleToString(MarketInfo(Symbol(), MODE_STOPLEVEL), 0) +
        "  Freeze: " + DoubleToString(MarketInfo(Symbol(), MODE_FREEZELEVEL), 0) +
        "  Latency avg: " + DoubleToString(g_latency, 0) + " ms\n";
   s += "Today: " + IntegerToString(g_dayTrades) + " trades, P/L " + DoubleToString(g_dayPL, 2) + "\n";
   s += "Status: " + ((block == "") ? "ready" : block);
   Comment(s);
}
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateSpread();
   DetectCommission();
   RefreshDayStats(false);

   int sig = GetSignal();
   int pos = 0, pend = 0;
   CountOrders(pos, pend);

   static int prevPos = 0;
   if(prevPos > 0 && pos == 0)
   {
      g_lastCloseTime = TimeCurrent();
      RefreshDayStats(true);
   }
   prevPos = pos;

   // pendings are removed when the session / spread / daily limit say "no exposure"
   bool keepPendings = InTradingWindow() && !DailyLimitHit();
   if(keepPendings && g_maxSpread > 0.0 && AvgSpread() + g_commission > g_maxSpread) keepPendings = false;

   if(pend > 0 && !keepPendings && pos == 0) DeleteAllPendings();

   if(pos > 0 || pend > 0) ManageOrders(sig, pos > 0);

   CountOrders(pos, pend);

   string block = EntryBlockReason(pos);
   if(pos == 0 && block == "" && sig != 0) TryEntries(sig);

   ShowStatus(sig, pos, pend, block);
}
//+------------------------------------------------------------------+
