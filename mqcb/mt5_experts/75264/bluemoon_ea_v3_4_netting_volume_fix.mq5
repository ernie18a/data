
//+------------------------------------------------------------------+
//| BlueMoon EA v3.4 Netting + Volume Limit Fix                      |
//| Envelope + Grid + Basket Management with Diagnostic Dashboard    |
//| Designed for MT5 hedging accounts                                |
//+------------------------------------------------------------------+
#property strict
#property version   "3.40"
#property description "BlueMoon EA - adaptive envelope/grid basket manager"

#include <Trade/Trade.mqh>
CTrade trade;

//--------------------------- Identity -------------------------------
input string InpEAName = "BlueMoon EA";
input ulong  InpMagicNumber = 31072026;

//--------------------------- Core V3 logic ---------------------------
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M5;
input int    InpMAPeriod = 14;
input ENUM_MA_METHOD InpMAMethod = MODE_EMA;
input double InpEnvelopeDeviationPercent = 0.10;
input double InpInitialLot = 0.01;
input double InpLotIncrement = 0.01;
input double InpMaxLot = 0.10;
input int    InpGridDistancePips = 17;
input int    InpSingleTradeTPPips = 10;
input double InpBasketProfitTargetMoney = 1.00;
input int    InpMaxPositionsPerDirection = 10;
input bool   InpTradeOnlyOnNewBar = true;
input bool   InpUseClosedBarSignal = true;
input bool   InpAllowBuy = true;
input bool   InpAllowSell = true;

//--------------------------- Startup signal recovery ----------------
// On first live tick only, optionally recover a very recent closed-bar signal.
input bool   InpAllowRecentSignalOnStartup = true;
input int    InpMaxSignalAgeBars = 2;
input double InpRecentSignalMaxDistancePips = 3.0;

//--------------------------- Execution filters -----------------------
input double InpMaxSpreadPips = 2.50;
input int    InpSlippagePoints = 20;

//--------------------------- Drawdown protection ---------------------
// ACTIVE by default, as requested.
input bool   InpEnableTotalDrawdownProtection = true;
input double InpMaxTotalDrawdownPercent = 51.0;
input bool   InpUsePeakEquityForDrawdown = true;
input bool   InpCloseAllAccountPositionsOnDD = false;
input bool   InpLockTradingAfterDD = true;

//--------------------------- Dashboard -------------------------------
input bool   InpShowDashboard = true;
input int    InpDashboardX = 12;
input int    InpDashboardY = 22;
input int    InpDashboardWidth = 420;
input int    InpDashboardFontSize = 9;

//--------------------------- Globals --------------------------------
int maHandle = INVALID_HANDLE;
datetime lastSignalBar = 0;
double peakEquity = 0.0;
bool drawdownLock = false;
string currentStatus = "INITIALISING";
string blockingReason = "";
string lastAction = "None";
string lastCloseReason = "No BlueMoon trade closed yet";
datetime lastTickTime = 0;
bool startupSignalChecked = false;

string PREFIX = "BM34_";

// Netting/volume-limit protection
bool isNettingAccount = false;
datetime lastBuyAttemptTime = 0;
datetime lastSellAttemptTime = 0;
double lastBuyAttemptPrice = 0.0;
double lastSellAttemptPrice = 0.0;

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
double PipSize()
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return (digits == 3 || digits == 5) ? point * 10.0 : point;
}

double CurrentSpreadPips()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return 0.0;
   return (tick.ask - tick.bid) / PipSize();
}

double NormalizeVolume(double volume)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   volume = MathMax(minLot, MathMin(maxLot, volume));
   if(step > 0.0)
      volume = MathFloor(volume / step + 1e-8) * step;

   int volDigits = 2;
   if(step == 0.1) volDigits = 1;
   else if(step == 0.001) volDigits = 3;

   return NormalizeDouble(volume, volDigits);
}

bool IsOurPositionByIndex(int index)
{
   ulong ticket = PositionGetTicket(index);
   if(ticket == 0) return false;
   if(!PositionSelectByTicket(ticket)) return false;
   return ((ulong)PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
           PositionGetString(POSITION_SYMBOL) == _Symbol);
}

int CountPositions(ENUM_POSITION_TYPE type)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         count++;
   }
   return count;
}

double TotalLots(ENUM_POSITION_TYPE type)
{
   double lots = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         lots += PositionGetDouble(POSITION_VOLUME);
   }
   return lots;
}

// Returns the number of logical grid entries. On hedging accounts each
// position is one level. On netting accounts MT5 merges all entries into one
// position, so levels are reconstructed from the accumulated volume sequence.
int CountGridLevels(ENUM_POSITION_TYPE type)
{
   if(!isNettingAccount)
      return CountPositions(type);

   double total = TotalLots(type);
   if(total <= 0.0) return 0;

   double accumulated = 0.0;
   for(int level = 0; level < InpMaxPositionsPerDirection; ++level)
   {
      double levelLot = NormalizeVolume(MathMin(InpMaxLot,
                                  InpInitialLot + level * InpLotIncrement));
      accumulated += levelLot;
      double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double tolerance = MathMax(step * 0.51, 1e-8);
      if(total <= accumulated + tolerance)
         return level + 1;
   }
   return InpMaxPositionsPerDirection;
}

// Current symbol exposure used for the broker's SYMBOL_VOLUME_LIMIT rule.
double CurrentSymbolDirectionalVolume(ENUM_ORDER_TYPE orderType)
{
   double volume = 0.0;
   ENUM_POSITION_TYPE wanted = (orderType == ORDER_TYPE_BUY ?
                                POSITION_TYPE_BUY : POSITION_TYPE_SELL);

   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == wanted)
         volume += PositionGetDouble(POSITION_VOLUME);
   }

   for(int i = OrdersTotal() - 1; i >= 0; --i)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0 || !OrderSelect(ticket)) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      ENUM_ORDER_TYPE t = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      bool sameDirection = (orderType == ORDER_TYPE_BUY &&
                            (t == ORDER_TYPE_BUY_LIMIT || t == ORDER_TYPE_BUY_STOP ||
                             t == ORDER_TYPE_BUY_STOP_LIMIT)) ||
                           (orderType == ORDER_TYPE_SELL &&
                            (t == ORDER_TYPE_SELL_LIMIT || t == ORDER_TYPE_SELL_STOP ||
                             t == ORDER_TYPE_SELL_STOP_LIMIT));
      if(sameDirection)
         volume += OrderGetDouble(ORDER_VOLUME_CURRENT);
   }
   return volume;
}

// Last entry deal price is required on netting accounts because POSITION_PRICE_OPEN
// is an average price and changes whenever another grid order is merged.
double LastEntryDealPrice(ENUM_POSITION_TYPE type)
{
   if(!HistorySelect(0, TimeCurrent())) return 0.0;
   ENUM_DEAL_TYPE wanted = (type == POSITION_TYPE_BUY ? DEAL_TYPE_BUY : DEAL_TYPE_SELL);

   for(int i = HistoryDealsTotal() - 1; i >= 0; --i)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0) continue;
      if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol) continue;
      if((ENUM_DEAL_TYPE)HistoryDealGetInteger(deal, DEAL_TYPE) != wanted) continue;
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY);
      if(entry == DEAL_ENTRY_IN || entry == DEAL_ENTRY_INOUT)
         return HistoryDealGetDouble(deal, DEAL_PRICE);
   }
   return 0.0;
}

double BasketNet(ENUM_POSITION_TYPE type)
{
   double net = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type) continue;
      net += PositionGetDouble(POSITION_PROFIT);
      net += PositionGetDouble(POSITION_SWAP);
   }
   return net;
}

double BasketSwap(ENUM_POSITION_TYPE type)
{
   double value = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         value += PositionGetDouble(POSITION_SWAP);
   }
   return value;
}

double WeightedAverageEntry(ENUM_POSITION_TYPE type)
{
   double weighted = 0.0, lots = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type) continue;
      double v = PositionGetDouble(POSITION_VOLUME);
      weighted += PositionGetDouble(POSITION_PRICE_OPEN) * v;
      lots += v;
   }
   return (lots > 0.0 ? weighted / lots : 0.0);
}

double NewestEntry(ENUM_POSITION_TYPE type)
{
   datetime newestTime = 0;
   double newestPrice = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type) continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t >= newestTime)
      {
         newestTime = t;
         newestPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      }
   }
   return newestPrice;
}

double OldestEntry(ENUM_POSITION_TYPE type)
{
   datetime oldestTime = D'2099.12.31';
   double oldestPrice = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      if(!IsOurPositionByIndex(i)) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type) continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t <= oldestTime)
      {
         oldestTime = t;
         oldestPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      }
   }
   return oldestPrice;
}

double NextLot(ENUM_POSITION_TYPE type)
{
   int count = CountGridLevels(type);
   return NormalizeVolume(MathMin(InpMaxLot, InpInitialLot + count * InpLotIncrement));
}

bool IsNewSignalBar()
{
   datetime bar = iTime(_Symbol, InpSignalTimeframe, 0);
   if(bar == 0) return false;
   if(bar != lastSignalBar)
   {
      lastSignalBar = bar;
      return true;
   }
   return false;
}

bool GetEnvelope(double &center, double &upper, double &lower)
{
   double ma[1];
   if(CopyBuffer(maHandle, 0, 0, 1, ma) != 1) return false;
   center = ma[0];
   double deviation = InpEnvelopeDeviationPercent / 100.0;
   upper = center * (1.0 + deviation);
   lower = center * (1.0 - deviation);
   return true;
}

bool GetEnvelopeAtShift(int shift, double &center, double &upper, double &lower)
{
   if(shift < 0) return false;

   double ma[1];
   if(CopyBuffer(maHandle, 0, shift, 1, ma) != 1) return false;

   center = ma[0];
   double deviation = InpEnvelopeDeviationPercent / 100.0;
   upper = center * (1.0 + deviation);
   lower = center * (1.0 - deviation);
   return true;
}

double CurrentDrawdownPercent()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double base = AccountInfoDouble(ACCOUNT_BALANCE);

   if(InpUsePeakEquityForDrawdown)
   {
      if(equity > peakEquity) peakEquity = equity;
      base = MathMax(base, peakEquity);
   }

   if(base <= 0.0) return 0.0;
   return MathMax(0.0, (base - equity) / base * 100.0);
}

void DeletePendingOrders(bool allAccountOrders)
{
   for(int i = OrdersTotal() - 1; i >= 0; --i)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0 || !OrderSelect(ticket)) continue;
      if(!allAccountOrders)
      {
         if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagicNumber) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      }
      trade.OrderDelete(ticket);
   }
}

void ClosePositions(bool allAccountPositions, string reason)
{
   lastCloseReason = reason;
   lastAction = reason;

   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;

      if(!allAccountPositions)
      {
         if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      }

      trade.PositionClose(ticket, InpSlippagePoints);
   }
   DeletePendingOrders(allAccountPositions);
}

void ClosePositionsByType(ENUM_POSITION_TYPE type, string reason)
{
   lastCloseReason = reason;
   lastAction = reason;

   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type) continue;

      if(!trade.PositionClose(ticket, InpSlippagePoints))
         Print("BlueMoon close failed for ticket ", ticket, ": ",
               trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
   }
}

bool CheckDrawdownProtection()
{
   double dd = CurrentDrawdownPercent();
   if(!InpEnableTotalDrawdownProtection) return false;
   if(dd < InpMaxTotalDrawdownPercent) return false;

   currentStatus = "DRAWDOWN PROTECTION TRIGGERED";
   blockingReason = StringFormat("Total drawdown %.2f%% reached %.2f%% limit",
                                 dd, InpMaxTotalDrawdownPercent);

   ClosePositions(InpCloseAllAccountPositionsOnDD,
                  StringFormat("TOTAL DRAWDOWN STOP %.2f%%", dd));

   if(InpLockTradingAfterDD)
      drawdownLock = true;

   return true;
}

bool CanOpenPosition(ENUM_ORDER_TYPE orderType, double volume, string &reason)
{
   reason = "";

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      reason = "Terminal is not connected";
      return false;
   }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   {
      reason = "Automated trading is not allowed";
      return false;
   }

   long tradeMode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   if(tradeMode == SYMBOL_TRADE_MODE_DISABLED || tradeMode == SYMBOL_TRADE_MODE_CLOSEONLY)
   {
      reason = "Symbol is not open for new trades";
      return false;
   }
   if(orderType == ORDER_TYPE_BUY && tradeMode == SYMBOL_TRADE_MODE_SHORTONLY)
   {
      reason = "Symbol allows sell orders only";
      return false;
   }
   if(orderType == ORDER_TYPE_SELL && tradeMode == SYMBOL_TRADE_MODE_LONGONLY)
   {
      reason = "Symbol allows buy orders only";
      return false;
   }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.ask <= 0.0 || tick.bid <= 0.0)
   {
      reason = "Valid market prices are unavailable";
      return false;
   }

   volume = NormalizeVolume(volume);

   double symbolVolumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
   if(symbolVolumeLimit > 0.0)
   {
      double used = CurrentSymbolDirectionalVolume(orderType);
      double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double tolerance = MathMax(step * 0.1, 1e-8);
      if(used + volume > symbolVolumeLimit + tolerance)
      {
         reason = StringFormat("Broker volume limit reached: used %.2f + requested %.2f > %.2f",
                               used, volume, symbolVolumeLimit);
         return false;
      }
   }

   double price = (orderType == ORDER_TYPE_BUY ? tick.ask : tick.bid);
   double margin = 0.0;
   if(!OrderCalcMargin(orderType, _Symbol, volume, price, margin))
   {
      reason = StringFormat("Margin calculation failed: %d", GetLastError());
      return false;
   }
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < margin)
   {
      reason = StringFormat("Insufficient free margin: need %.2f", margin);
      return false;
   }
   return true;
}

bool OpenPosition(ENUM_ORDER_TYPE orderType, double volume, string comment)
{
   volume = NormalizeVolume(volume);

   MqlTick attemptTick;
   if(!SymbolInfoTick(_Symbol, attemptTick)) return false;
   datetime now = TimeCurrent();
   double attemptPrice = (orderType == ORDER_TYPE_BUY ? attemptTick.ask : attemptTick.bid);
   datetime previousTime = (orderType == ORDER_TYPE_BUY ? lastBuyAttemptTime : lastSellAttemptTime);
   double previousPrice = (orderType == ORDER_TYPE_BUY ? lastBuyAttemptPrice : lastSellAttemptPrice);
   double minMove = MathMax(SymbolInfoDouble(_Symbol, SYMBOL_POINT), PipSize() * 0.1);

   // Do not hammer the trade server repeatedly at the same price and second.
   if(previousTime == now && MathAbs(attemptPrice - previousPrice) < minMove)
   {
      currentStatus = "DUPLICATE ORDER SUPPRESSED";
      blockingReason = "An identical order attempt was already made on this tick/second";
      return false;
   }

   if(orderType == ORDER_TYPE_BUY)
   {
      lastBuyAttemptTime = now;
      lastBuyAttemptPrice = attemptPrice;
   }
   else
   {
      lastSellAttemptTime = now;
      lastSellAttemptPrice = attemptPrice;
   }

   string validationReason;
   if(!CanOpenPosition(orderType, volume, validationReason))
   {
      currentStatus = "ORDER BLOCKED";
      blockingReason = validationReason;
      lastAction = validationReason;
      return false;
   }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);

   bool ok = false;
   if(orderType == ORDER_TYPE_BUY)
      ok = trade.Buy(volume, _Symbol, 0.0, 0.0, 0.0, comment);
   else if(orderType == ORDER_TYPE_SELL)
      ok = trade.Sell(volume, _Symbol, 0.0, 0.0, 0.0, comment);

   if(ok)
   {
      lastAction = StringFormat("Opened %s %.2f lot",
                  orderType == ORDER_TYPE_BUY ? "BUY" : "SELL", volume);
   }
   else
   {
      lastAction = StringFormat("Order failed: %d %s",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
   }
   return ok;
}

void ManageSingleTradeTP(ENUM_POSITION_TYPE type)
{
   // A netting position can contain several merged grid entries.
   if(CountGridLevels(type) != 1) return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return;

   double entry = WeightedAverageEntry(type);
   double pips = 0.0;

   if(type == POSITION_TYPE_BUY)
      pips = (tick.bid - entry) / PipSize();
   else
      pips = (entry - tick.ask) / PipSize();

   if(pips >= InpSingleTradeTPPips)
   {
      ClosePositionsByType(type, "SINGLE TRADE TAKE PROFIT");
      currentStatus = "SINGLE TRADE TP CLOSED";
   }
}

void ManageBasketProfit(ENUM_POSITION_TYPE type)
{
   int count = CountGridLevels(type);
   if(count < 2) return;

   double net = BasketNet(type);
   if(net >= InpBasketProfitTargetMoney)
   {
      ClosePositionsByType(type, "BASKET PROFIT TARGET");
      currentStatus = "BASKET TARGET CLOSED";
   }
}

void ManageGrid(ENUM_POSITION_TYPE type)
{
   int count = CountGridLevels(type);
   if(count <= 0 || count >= InpMaxPositionsPerDirection) return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return;

   double newest = (isNettingAccount ? LastEntryDealPrice(type) : NewestEntry(type));
   if(newest <= 0.0) newest = WeightedAverageEntry(type);
   if(newest <= 0.0) return;

   double distancePips = 0.0;
   if(type == POSITION_TYPE_BUY)
      distancePips = (newest - tick.ask) / PipSize();
   else
      distancePips = (tick.bid - newest) / PipSize();

   if(distancePips >= InpGridDistancePips)
   {
      double lot = NextLot(type);
      bool opened = false;
      if(type == POSITION_TYPE_BUY)
         opened = OpenPosition(ORDER_TYPE_BUY, lot, "BlueMoon Grid BUY");
      else
         opened = OpenPosition(ORDER_TYPE_SELL, lot, "BlueMoon Grid SELL");

      if(opened)
         currentStatus = StringFormat("GRID LEVEL %d ADDED", count + 1);
   }
}

bool EvaluateRecentStartupSignal()
{
   // This function must run only once after attachment/restart.
   if(startupSignalChecked) return false;
   startupSignalChecked = true;

   if(!InpAllowRecentSignalOnStartup || InpMaxSignalAgeBars <= 0)
      return false;

   if(drawdownLock) return false;

   // Never create a catch-up entry while an existing basket is present.
   if(CountPositions(POSITION_TYPE_BUY) > 0 ||
      CountPositions(POSITION_TYPE_SELL) > 0)
      return false;

   double spread = CurrentSpreadPips();
   if(spread > InpMaxSpreadPips)
   {
      currentStatus = "RECENT SIGNAL BLOCKED";
      blockingReason = StringFormat("Startup spread %.2f > %.2f pips",
                                    spread, InpMaxSpreadPips);
      return false;
   }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return false;

   double tolerance = MathMax(0.0, InpRecentSignalMaxDistancePips) * PipSize();
   int barsToCheck = MathMax(1, InpMaxSignalAgeBars);

   // Scan newest closed bar first. A signal must still be active or nearby now.
   for(int shift = 1; shift <= barsToCheck; ++shift)
   {
      double center, upper, lower;
      if(!GetEnvelopeAtShift(shift, center, upper, lower))
         continue;

      double barLow = iLow(_Symbol, InpSignalTimeframe, shift);
      double barHigh = iHigh(_Symbol, InpSignalTimeframe, shift);
      datetime barTime = iTime(_Symbol, InpSignalTimeframe, shift);
      if(barLow <= 0.0 || barHigh <= 0.0 || barTime == 0)
         continue;

      bool recentBuySignal = (barLow <= lower);
      bool buyStillValid = (tick.ask <= lower + tolerance);
      if(InpAllowBuy && recentBuySignal && buyStillValid)
      {
         currentStatus = "RECENT BUY SIGNAL RECOVERED";
         blockingReason = StringFormat("Signal %d closed bar(s) ago; current price remains within %.1f pips",
                                       shift, InpRecentSignalMaxDistancePips);
         return OpenPosition(ORDER_TYPE_BUY, InpInitialLot,
                             "BlueMoon Startup Recent BUY");
      }

      bool recentSellSignal = (barHigh >= upper);
      bool sellStillValid = (tick.bid >= upper - tolerance);
      if(InpAllowSell && recentSellSignal && sellStillValid)
      {
         currentStatus = "RECENT SELL SIGNAL RECOVERED";
         blockingReason = StringFormat("Signal %d closed bar(s) ago; current price remains within %.1f pips",
                                       shift, InpRecentSignalMaxDistancePips);
         return OpenPosition(ORDER_TYPE_SELL, InpInitialLot,
                             "BlueMoon Startup Recent SELL");
      }
   }

   currentStatus = "WAITING FOR SIGNAL";
   blockingReason = StringFormat("No valid signal in last %d closed bar(s); waiting for fresh setup",
                                 barsToCheck);
   return false;
}

void EvaluateEntries(bool newBar)
{
   if(drawdownLock)
   {
      currentStatus = "TRADING LOCKED";
      blockingReason = "Drawdown protection lock requires EA restart or input change";
      return;
   }

   if(InpTradeOnlyOnNewBar && !newBar)
   {
      currentStatus = "WAITING FOR NEW M5 BAR";
      blockingReason = "Current candle already evaluated";
      return;
   }

   double spread = CurrentSpreadPips();
   if(spread > InpMaxSpreadPips)
   {
      currentStatus = "SPREAD TOO HIGH";
      blockingReason = StringFormat("Spread %.2f > maximum %.2f pips", spread, InpMaxSpreadPips);
      return;
   }

   int buys = CountPositions(POSITION_TYPE_BUY);
   int sells = CountPositions(POSITION_TYPE_SELL);

   if(InpUseClosedBarSignal)
   {
      double center1, upper1, lower1;
      if(!GetEnvelopeAtShift(1, center1, upper1, lower1))
      {
         currentStatus = "INDICATOR DATA UNAVAILABLE";
         blockingReason = "Unable to read completed-bar EMA data";
         return;
      }

      double low1 = iLow(_Symbol, InpSignalTimeframe, 1);
      double high1 = iHigh(_Symbol, InpSignalTimeframe, 1);
      double open1 = iOpen(_Symbol, InpSignalTimeframe, 1);
      double close1 = iClose(_Symbol, InpSignalTimeframe, 1);
      if(low1 <= 0.0 || high1 <= 0.0)
      {
         currentStatus = "BAR DATA UNAVAILABLE";
         blockingReason = "Completed M5 candle is not ready";
         return;
      }

      bool buySignal = (low1 <= lower1);
      bool sellSignal = (high1 >= upper1);

      if(buySignal && sellSignal)
      {
         double buyExcursion = (lower1 - low1) / PipSize();
         double sellExcursion = (high1 - upper1) / PipSize();
         if(MathAbs(buyExcursion - sellExcursion) < 0.1)
         {
            buySignal = (close1 >= open1);
            sellSignal = !buySignal;
         }
         else if(buyExcursion > sellExcursion)
            sellSignal = false;
         else
            buySignal = false;
      }

      if(InpAllowBuy && buys == 0 && buySignal)
      {
         currentStatus = "CLOSED-BAR BUY SIGNAL";
         blockingReason = "Previous M5 candle crossed the lower envelope";
         OpenPosition(ORDER_TYPE_BUY, InpInitialLot, "BlueMoon Closed-Bar BUY");
         return;
      }
      if(InpAllowSell && sells == 0 && sellSignal)
      {
         currentStatus = "CLOSED-BAR SELL SIGNAL";
         blockingReason = "Previous M5 candle crossed the upper envelope";
         OpenPosition(ORDER_TYPE_SELL, InpInitialLot, "BlueMoon Closed-Bar SELL");
         return;
      }

      double buyGap = MathMax(0.0, (low1 - lower1) / PipSize());
      double sellGap = MathMax(0.0, (upper1 - high1) / PipSize());
      currentStatus = "WAITING FOR ENVELOPE SIGNAL";
      blockingReason = StringFormat("Previous M5 gap: BUY %.1f pips | SELL %.1f pips", buyGap, sellGap);
      return;
   }

   double center, upper, lower;
   if(!GetEnvelope(center, upper, lower))
   {
      currentStatus = "INDICATOR DATA UNAVAILABLE";
      blockingReason = "Unable to read EMA buffer";
      return;
   }
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return;

   if(InpAllowBuy && buys == 0 && tick.ask <= lower)
   {
      OpenPosition(ORDER_TYPE_BUY, InpInitialLot, "BlueMoon Initial BUY");
      return;
   }
   if(InpAllowSell && sells == 0 && tick.bid >= upper)
   {
      OpenPosition(ORDER_TYPE_SELL, InpInitialLot, "BlueMoon Initial SELL");
      return;
   }

   currentStatus = "WAITING FOR ENVELOPE SIGNAL";
   blockingReason = "Current price remains inside the EMA envelope";
}

//+------------------------------------------------------------------+
//| Dashboard                                                        |
//+------------------------------------------------------------------+
void CreateOrUpdateLabel(string name, string text, int x, int y,
                         int fontSize, color clr, string font = "Consolas")
{
   string obj = PREFIX + name;
   if(ObjectFind(0, obj) < 0)
   {
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
   }

   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetString(0, obj, OBJPROP_FONT, font);
   ObjectSetString(0, obj, OBJPROP_TEXT, text);
}

void CreatePanel()
{
   string obj = PREFIX + "PANEL";
   if(ObjectFind(0, obj) < 0)
   {
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   }

   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, InpDashboardX);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, InpDashboardY);
   ObjectSetInteger(0, obj, OBJPROP_XSIZE, InpDashboardWidth);
   ObjectSetInteger(0, obj, OBJPROP_YSIZE, 500);
   ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'20,24,34');
   ObjectSetInteger(0, obj, OBJPROP_BORDER_COLOR, C'70,90,130');
   ObjectSetInteger(0, obj, OBJPROP_BACK, false);
}

string PositionSummary(ENUM_POSITION_TYPE type)
{
   int count = CountPositions(type);
   double lots = TotalLots(type);
   double net = BasketNet(type);
   double swp = BasketSwap(type);
   double avg = WeightedAverageEntry(type);

   return StringFormat("%s: %d pos | %.2f lots | Net %.2f | Swap %.2f | Avg %.*f",
      type == POSITION_TYPE_BUY ? "BUY " : "SELL",
      count, lots, net, swp, _Digits, avg);
}

string LastClosedTradeText()
{
   datetime from = TimeCurrent() - 90 * 86400;
   if(!HistorySelect(from, TimeCurrent()))
      return "No history available";

   ulong newestDeal = 0;
   datetime newestTime = 0;

   for(int i = HistoryDealsTotal() - 1; i >= 0; --i)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0) continue;
      if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;

      datetime t = (datetime)HistoryDealGetInteger(deal, DEAL_TIME);
      if(t >= newestTime)
      {
         newestTime = t;
         newestDeal = deal;
      }
   }

   if(newestDeal == 0)
      return "No BlueMoon trade closed yet";

   double profit = HistoryDealGetDouble(newestDeal, DEAL_PROFIT);
   double swap = HistoryDealGetDouble(newestDeal, DEAL_SWAP);
   double commission = HistoryDealGetDouble(newestDeal, DEAL_COMMISSION);
   double net = profit + swap + commission;
   long type = HistoryDealGetInteger(newestDeal, DEAL_TYPE);
   double volume = HistoryDealGetDouble(newestDeal, DEAL_VOLUME);

   return StringFormat("%s %.2f | Gross %.2f | Swap %.2f | Comm %.2f | Net %.2f",
      type == DEAL_TYPE_BUY ? "BUY close" : "SELL close",
      volume, profit, swap, commission, net);
}

void UpdateDashboard()
{
   if(!InpShowDashboard || MQLInfoInteger(MQL_TESTER)) return;

   CreatePanel();

   double center = 0.0, upper = 0.0, lower = 0.0;
   GetEnvelope(center, upper, lower);

   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);

   double spread = CurrentSpreadPips();
   double dd = CurrentDrawdownPercent();
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   int y = InpDashboardY + 12;
   int x = InpDashboardX + 12;
   int step = 18;

   color statusColor = clrLime;
   if(StringFind(currentStatus, "HIGH") >= 0 ||
      StringFind(currentStatus, "TRIGGERED") >= 0 ||
      StringFind(currentStatus, "LOCKED") >= 0)
      statusColor = clrTomato;
   else if(StringFind(currentStatus, "WAITING") >= 0)
      statusColor = clrGold;

   CreateOrUpdateLabel("TITLE", InpEAName + " v3.4  |  Netting-Safe Basket Manager",
                       x, y, InpDashboardFontSize + 2, clrDeepSkyBlue);
   y += 25;

   CreateOrUpdateLabel("STATUS", "STATUS: " + currentStatus,
                       x, y, InpDashboardFontSize + 1, statusColor);
   y += step;

   CreateOrUpdateLabel("REASON", "Reason: " + blockingReason,
                       x, y, InpDashboardFontSize, clrSilver);
   y += step;

   CreateOrUpdateLabel("MARKET_HEAD", "MARKET / SIGNAL",
                       x, y, InpDashboardFontSize, clrDeepSkyBlue);
   y += step;

   CreateOrUpdateLabel("MARKET",
      StringFormat("%s %s | Bid %.*f | Ask %.*f | Spread %.2f / %.2f pips",
      _Symbol, EnumToString(InpSignalTimeframe), _Digits, tick.bid,
      _Digits, tick.ask, spread, InpMaxSpreadPips),
      x, y, InpDashboardFontSize, spread <= InpMaxSpreadPips ? clrWhite : clrTomato);
   y += step;

   CreateOrUpdateLabel("INDICATORS",
      StringFormat("EMA(%d) %.*f | Upper %.*f | Lower %.*f | Dev %.3f%%",
      InpMAPeriod, _Digits, center, _Digits, upper, _Digits, lower,
      InpEnvelopeDeviationPercent),
      x, y, InpDashboardFontSize, clrWhite);
   y += step;

   bool buyCondition = (tick.ask <= lower);
   bool sellCondition = (tick.bid >= upper);

   CreateOrUpdateLabel("CONDS",
      StringFormat("BUY: %s | SELL: %s | New-bar: %s | Startup scan: %s/%d bars",
      buyCondition ? "YES" : "NO",
      sellCondition ? "YES" : "NO",
      InpTradeOnlyOnNewBar ? "ON" : "OFF",
      InpAllowRecentSignalOnStartup ? "ON" : "OFF",
      InpMaxSignalAgeBars),
      x, y, InpDashboardFontSize, clrWhite);
   y += step + 4;

   CreateOrUpdateLabel("BASKET_HEAD", "BASKETS / NEXT ACTION",
                       x, y, InpDashboardFontSize, clrDeepSkyBlue);
   y += step;

   CreateOrUpdateLabel("BUY_SUM", PositionSummary(POSITION_TYPE_BUY),
                       x, y, InpDashboardFontSize, clrWhite);
   y += step;

   CreateOrUpdateLabel("SELL_SUM", PositionSummary(POSITION_TYPE_SELL),
                       x, y, InpDashboardFontSize, clrWhite);
   y += step;

   int buys = CountGridLevels(POSITION_TYPE_BUY);
   int sells = CountGridLevels(POSITION_TYPE_SELL);

   string nextAction = "Wait for envelope signal";
   if(buys > 0)
      nextAction = StringFormat("BUY grid #%d at %.1f pips adverse; next lot %.2f",
                    buys + 1, (double)InpGridDistancePips, NextLot(POSITION_TYPE_BUY));
   if(sells > 0)
      nextAction = StringFormat("SELL grid #%d at %.1f pips adverse; next lot %.2f",
                    sells + 1, (double)InpGridDistancePips, NextLot(POSITION_TYPE_SELL));

   CreateOrUpdateLabel("NEXT", "Next: " + nextAction,
                       x, y, InpDashboardFontSize, clrGold);
   y += step;

   CreateOrUpdateLabel("LAST_ACTION", "Last action: " + lastAction,
                       x, y, InpDashboardFontSize, clrSilver);
   y += step + 4;

   CreateOrUpdateLabel("RISK_HEAD", "ACCOUNT / RISK",
                       x, y, InpDashboardFontSize, clrDeepSkyBlue);
   y += step;

   CreateOrUpdateLabel("ACCOUNT",
      StringFormat("Balance %.2f | Equity %.2f | Margin level %.1f%%",
      balance, equity, marginLevel),
      x, y, InpDashboardFontSize, clrWhite);
   y += step;

   CreateOrUpdateLabel("DD",
      StringFormat("Total drawdown %.2f%% / %.2f%% | Protection %s | Lock %s",
      dd, InpMaxTotalDrawdownPercent,
      InpEnableTotalDrawdownProtection ? "ACTIVE" : "OFF",
      drawdownLock ? "ENGAGED" : "READY"),
      x, y, InpDashboardFontSize,
      dd >= InpMaxTotalDrawdownPercent * 0.85 ? clrTomato :
      dd >= InpMaxTotalDrawdownPercent * 0.60 ? clrGold : clrLime);
   y += step;

   int filled = (int)MathRound(MathMin(10.0, dd / InpMaxTotalDrawdownPercent * 10.0));
   string meter = "";
   for(int i = 0; i < 10; ++i)
      meter += (i < filled ? "|" : ".");

   CreateOrUpdateLabel("METER", "Risk meter [" + meter + "]",
                       x, y, InpDashboardFontSize, clrWhite);
   y += step + 4;

   CreateOrUpdateLabel("LAST_HEAD", "LAST CLOSED TRADE",
                       x, y, InpDashboardFontSize, clrDeepSkyBlue);
   y += step;

   CreateOrUpdateLabel("LAST_TRADE", LastClosedTradeText(),
                       x, y, InpDashboardFontSize, clrWhite);
   y += step;

   CreateOrUpdateLabel("LAST_REASON", "Close reason: " + lastCloseReason,
                       x, y, InpDashboardFontSize, clrSilver);
   y += step;

   CreateOrUpdateLabel("HEALTH",
      StringFormat("AutoTrading %s | Connection %s | Last tick %s",
      TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ? "ON" : "OFF",
      TerminalInfoInteger(TERMINAL_CONNECTED) ? "OK" : "DOWN",
      TimeToString(lastTickTime, TIME_SECONDS)),
      x, y, InpDashboardFontSize, clrWhite);

   ChartRedraw();
}

void RemoveDashboard()
{
   ObjectsDeleteAll(0, PREFIX);
}

//+------------------------------------------------------------------+
//| Events                                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);

   maHandle = iMA(_Symbol, InpSignalTimeframe, InpMAPeriod, 0, InpMAMethod, PRICE_CLOSE);
   if(maHandle == INVALID_HANDLE)
   {
      Print("BlueMoon: failed to create MA handle. Error ", GetLastError());
      return INIT_FAILED;
   }

   isNettingAccount = ((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) !=
                       ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   peakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   lastSignalBar = iTime(_Symbol, InpSignalTimeframe, 0);
   currentStatus = "WAITING FOR SIGNAL";
   blockingReason = InpAllowRecentSignalOnStartup ?
                    "EA started; checking recent closed-bar signals" :
                    "EA started; awaiting next valid setup";
   if(!MQLInfoInteger(MQL_TESTER)) EventSetTimer(1);
   UpdateDashboard();

   Print(InpEAName, " v3.4 initialised on ", _Symbol,
         ". Total drawdown protection ACTIVE at ",
         DoubleToString(InpMaxTotalDrawdownPercent, 2), "%. Account mode: ",
         isNettingAccount ? "NETTING/EXCHANGE" : "HEDGING", ".");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(!MQLInfoInteger(MQL_TESTER)) EventKillTimer();
   if(maHandle != INVALID_HANDLE)
      IndicatorRelease(maHandle);
   RemoveDashboard();
}

void OnTimer()
{
   UpdateDashboard();
}

void OnTick()
{
   lastTickTime = TimeCurrent();

   if(CheckDrawdownProtection())
   {
      UpdateDashboard();
      return;
   }

   // Manage open baskets continuously.
   ManageSingleTradeTP(POSITION_TYPE_BUY);
   ManageSingleTradeTP(POSITION_TYPE_SELL);
   ManageBasketProfit(POSITION_TYPE_BUY);
   ManageBasketProfit(POSITION_TYPE_SELL);
   ManageGrid(POSITION_TYPE_BUY);
   ManageGrid(POSITION_TYPE_SELL);

   // One-time recovery of a very recent signal after chart attachment/restart.
   if(!startupSignalChecked)
   {
      if(EvaluateRecentStartupSignal())
         return;
   }

   bool newBar = IsNewSignalBar();
   EvaluateEntries(newBar);
   // Dashboard is refreshed by OnTimer() to reduce Wine/macOS CPU usage.
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD || trans.deal == 0)
      return;

   if(!HistoryDealSelect(trans.deal))
      return;

   if((ulong)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagicNumber)
      return;

   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol)
      return;

   ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   if(entry == DEAL_ENTRY_OUT)
   {
      // The EA records its intended close reason before closing.
      // Manual/broker closures are identifiable when no matching internal reason exists.
      if(lastCloseReason == "" || lastCloseReason == "No BlueMoon trade closed yet")
         lastCloseReason = "MANUAL OR BROKER-SIDE CLOSURE";
   }
}
//+------------------------------------------------------------------+
