//+------------------------------------------------------------------+
//|                                                    SMC_Gold.mq5  |
//|                                                      Ali Rajput  |
//|                                                                  |
//| Liquidity-sweep / order-block EA tuned for XAUUSD on M15.        |
//|                                                                  |
//| 1. Track the latest confirmed swing high and swing low.          |
//| 2. A closed bar wicks beyond one of them by a fraction of ATR    |
//|    and closes back on the other side (a stop hunt).              |
//| 3. The sweep bar's body is the order block. Only sweeps that     |
//|    agree with the H1 EMA trend are kept.                         |
//| 4. A later bar closes through the order block within a few bars  |
//|    (confirmation). Enter at market, stop beyond the sweep wick,  |
//|    target a fixed multiple of the stop.                          |
//|                                                                  |
//| Gold-specific fixes over the original SMC scalper:               |
//|  - lots sized with OrderCalcProfit(); SYMBOL_TRADE_TICK_VALUE is |
//|    wrong for XAUUSD on some servers (10x too small)              |
//|  - spread limit sized for gold (60 points, not 25)               |
//|  - no entries while the market is closed or about to close       |
//|  - order sent without stops, stops attached to the real fill,    |
//|    position closed at once if they cannot be attached            |
//|  - the position is identified from the deal, not the symbol      |
//|                                                                  |
//| Past results do not promise future profit. Demo first.           |
//+------------------------------------------------------------------+
#property copyright "Ali Rajput"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Swing / Structure ==="
input int              InpSwingLookback      = 5;           // Bars each side to confirm a swing high/low
input int              InpConfirmBars        = 3;           // Bars allowed for confirmation after a sweep

input group "=== Volatility (ATR) ==="
input int              InpATRPeriod          = 14;          // ATR period
input double           InpMinSweepATR        = 0.15;        // Minimum sweep beyond the swing, ATR multiples
input double           InpSLBufferATR        = 0.10;        // Stop buffer beyond the sweep wick, ATR multiples
input double           InpMinSLATR           = 0.50;        // Skip if the stop is closer than this, ATR multiples
input double           InpMinConfirmATR      = 0.30;        // Confirmation bar range must reach this, ATR multiples

input group "=== Trend filter ==="
input bool             InpUseTrendFilter     = true;        // Trade only with the higher-timeframe trend
input ENUM_TIMEFRAMES  InpTrendTF            = PERIOD_H1;   // Trend timeframe
input int              InpTrendEMA           = 50;          // Trend EMA period

input group "=== Risk and exits ==="
input double           InpRiskPercent        = 1.0;         // Risk per trade, % of balance
input double           InpRewardRatio        = 2.0;         // Target as a multiple of the stop distance
input double           InpBreakEvenAtR       = 0.0;         // Move stop to entry at this many R (0 = off)
input int              InpMaxSpreadPoints    = 60;          // Skip entry above this spread, points
input double           InpMinSLToSpread      = 3.0;         // Stop must be at least this many spreads wide
input int              InpSlippagePoints     = 30;          // Allowed slippage, points
input ulong            InpMagic              = 554001;      // Magic number

input group "=== Optional hours filter (server time) ==="
input bool             InpUseHours           = false;       // Restrict new setups to the window below
input int              InpStartHour          = 7;           // Window start hour
input int              InpEndHour            = 20;          // Window end hour (exclusive)

//+------------------------------------------------------------------+
//| Global objects and state                                         |
//+------------------------------------------------------------------+
CTrade   trade;                                  // trade helper
int      g_atrHandle          = INVALID_HANDLE;  // ATR on the chart timeframe
int      g_emaHandle          = INVALID_HANDLE;  // EMA on the trend timeframe
datetime g_lastBarTime        = 0;               // last bar seen by IsNewBar()

double   g_swingHigh          = 0.0;             // last confirmed swing high
bool     g_swingHighUsed      = true;            // true once swept
double   g_swingLow           = 0.0;             // last confirmed swing low
bool     g_swingLowUsed       = true;            // true once swept

bool     g_pendActive         = false;           // a sweep awaits confirmation
bool     g_pendIsBuy          = false;           // direction of that setup
double   g_obHigh             = 0.0;             // order block top
double   g_obLow              = 0.0;             // order block bottom
double   g_sweepExtreme       = 0.0;             // sweep wick, the stop goes beyond it
int      g_pendBars           = 0;               // bars waited so far

long     g_posId              = 0;               // identifier of our open position
double   g_entryPrice         = 0.0;             // its fill price
double   g_initialRisk        = 0.0;             // entry to initial stop, price units
bool     g_beDone             = false;           // break-even applied or given up

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create the ATR handle.");
      return(INIT_FAILED);
     }
   if(InpUseTrendFilter)
     {
      g_emaHandle = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
      if(g_emaHandle == INVALID_HANDLE)
        {
         Print("Failed to create the trend EMA handle.");
         return(INIT_FAILED);
        }
     }

   //--- pick up a position left open by a restart
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk != 0 && PositionGetString(POSITION_SYMBOL) == _Symbol
         && (ulong)PositionGetInteger(POSITION_MAGIC) == InpMagic)
        {
         g_posId       = PositionGetInteger(POSITION_IDENTIFIER);
         g_entryPrice  = PositionGetDouble(POSITION_PRICE_OPEN);
         g_initialRisk = MathAbs(g_entryPrice - PositionGetDouble(POSITION_SL));
        }
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   if(g_emaHandle != INVALID_HANDLE)
      IndicatorRelease(g_emaHandle);
  }

//+------------------------------------------------------------------+
//| Tester function                                                  |
//| Print the headline numbers into the journal                      |
//+------------------------------------------------------------------+
double OnTester()
  {
   PrintFormat("TESTER STATS | trades %.0f | net profit %.2f | gross profit %.2f | gross loss %.2f"
               " | profit factor %.2f | max equity DD %.2f%% | max balance DD %.2f%% | sharpe %.2f",
               TesterStatistics(STAT_TRADES), TesterStatistics(STAT_PROFIT),
               TesterStatistics(STAT_GROSS_PROFIT), TesterStatistics(STAT_GROSS_LOSS),
               TesterStatistics(STAT_PROFIT_FACTOR), TesterStatistics(STAT_EQUITY_DDREL_PERCENT),
               TesterStatistics(STAT_BALANCE_DDREL_PERCENT), TesterStatistics(STAT_SHARPE_RATIO));
   return(TesterStatistics(STAT_PROFIT_FACTOR));
  }

//+------------------------------------------------------------------+
//| IsNewBar                                                         |
//| True once per bar of the chart timeframe                         |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == g_lastBarTime)
      return(false);
   g_lastBarTime = t;
   return(true);
  }

//+------------------------------------------------------------------+
//| GetATR                                                           |
//| ATR of the last closed bar, 0 if not ready                       |
//+------------------------------------------------------------------+
double GetATR()
  {
   double buf[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, buf) < 1)
      return(0.0);
   return(buf[0]);
  }

//+------------------------------------------------------------------+
//| InHours                                                          |
//| Optional server-time window for new setups                       |
//+------------------------------------------------------------------+
bool InHours()
  {
   if(!InpUseHours)
      return(true);
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(InpStartHour <= InpEndHour)
      return(dt.hour >= InpStartHour && dt.hour < InpEndHour);
   return(dt.hour >= InpStartHour || dt.hour < InpEndHour);
  }

//+------------------------------------------------------------------+
//| MarketOpenForEntry                                               |
//| Trade session open and not ending within 15 minutes              |
//+------------------------------------------------------------------+
bool MarketOpenForEntry()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int      nowSec = dt.hour * 3600 + dt.min * 60 + dt.sec;
   datetime from, to;
   for(uint i = 0; SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)dt.day_of_week, i, from, to); i++)
      if(nowSec >= (int)from && nowSec < (int)to - 900)
         return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| TrendAllows                                                      |
//| Price above the trend EMA allows buys, below allows sells        |
//+------------------------------------------------------------------+
bool TrendAllows(const bool isBuy)
  {
   if(!InpUseTrendFilter)
      return(true);
   double ema[1];
   if(CopyBuffer(g_emaHandle, 0, 0, 1, ema) < 1)
      return(true);                 // no data yet: do not block
   double cl = iClose(_Symbol, InpTrendTF, 0);
   return(isBuy ? cl > ema[0] : cl < ema[0]);
  }

//+------------------------------------------------------------------+
//| ValuePerPoint                                                    |
//| Money value of one point on one lot, asked from the server       |
//+------------------------------------------------------------------+
double ValuePerPoint()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pnl = 0.0;
   if(ask <= 0.0 || !OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, ask, ask + 1000.0 * _Point, pnl))
      return(0.0);
   return(MathAbs(pnl) / 1000.0);
  }

//+------------------------------------------------------------------+
//| LotForRisk                                                       |
//| Volume that loses InpRiskPercent of balance over slDist          |
//+------------------------------------------------------------------+
double LotForRisk(const double slDist)
  {
   double vpp  = ValuePerPoint();
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(vpp <= 0.0 || step <= 0.0 || slDist <= 0.0)
      return(0.0);

   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
   double lot  = MathFloor(risk / (slDist / _Point * vpp) / step) * step;
   lot = MathMin(lot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
   if(lot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      return(0.0);
   return(NormalizeDouble(lot, 2));
  }

//+------------------------------------------------------------------+
//| FindTicket                                                       |
//| Ticket of our open position, 0 if it is gone                     |
//+------------------------------------------------------------------+
ulong FindTicket()
  {
   if(g_posId == 0)
      return(0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk != 0 && PositionGetInteger(POSITION_IDENTIFIER) == g_posId)
         return(tk);
     }
   return(0);
  }

//+------------------------------------------------------------------+
//| UpdateSwingPoints                                                |
//| Confirm the latest swing high/low from closed bars only          |
//+------------------------------------------------------------------+
void UpdateSwingPoints()
  {
   int    need = InpSwingLookback * 2 + 5;
   double highs[], lows[];
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   if(CopyHigh(_Symbol, _Period, 0, need, highs) < need || CopyLow(_Symbol, _Period, 0, need, lows) < need)
      return;

   //--- the pivot must be the extreme of the bars on each side
   int  pivot  = InpSwingLookback + 1;
   bool isHigh = true, isLow = true;
   for(int k = 1; k <= InpSwingLookback; k++)
     {
      if(highs[pivot - k] > highs[pivot] || highs[pivot + k] > highs[pivot])
         isHigh = false;
      if(lows[pivot - k] < lows[pivot] || lows[pivot + k] < lows[pivot])
         isLow = false;
     }
   if(isHigh)
     {
      g_swingHigh     = highs[pivot];
      g_swingHighUsed = false;
     }
   if(isLow)
     {
      g_swingLow     = lows[pivot];
      g_swingLowUsed = false;
     }
  }

//+------------------------------------------------------------------+
//| CheckForSweep                                                    |
//| Last closed bar swept a swing and closed back: open a setup      |
//+------------------------------------------------------------------+
void CheckForSweep()
  {
   if(!InHours())
      return;
   double atr = GetATR();
   if(atr <= 0.0)
      return;

   double hi1 = iHigh(_Symbol, _Period, 1);
   double lo1 = iLow(_Symbol, _Period, 1);
   double op1 = iOpen(_Symbol, _Period, 1);
   double cl1 = iClose(_Symbol, _Period, 1);

   //--- buy-side liquidity taken above the swing high: short setup
   if(!g_swingHighUsed && g_swingHigh > 0.0 && hi1 > g_swingHigh + InpMinSweepATR * atr && cl1 < g_swingHigh)
     {
      g_swingHighUsed = true;
      if(TrendAllows(false))
        {
         g_pendActive   = true;
         g_pendIsBuy    = false;
         g_obHigh       = MathMax(op1, cl1);
         g_obLow        = MathMin(op1, cl1);
         g_sweepExtreme = hi1;
         g_pendBars     = 0;
        }
      return;
     }

   //--- sell-side liquidity taken below the swing low: long setup
   if(!g_swingLowUsed && g_swingLow > 0.0 && lo1 < g_swingLow - InpMinSweepATR * atr && cl1 > g_swingLow)
     {
      g_swingLowUsed = true;
      if(TrendAllows(true))
        {
         g_pendActive   = true;
         g_pendIsBuy    = true;
         g_obHigh       = MathMax(op1, cl1);
         g_obLow        = MathMin(op1, cl1);
         g_sweepExtreme = lo1;
         g_pendBars     = 0;
        }
     }
  }

//+------------------------------------------------------------------+
//| CheckConfirmation                                                |
//| A close through the order block confirms the setup               |
//+------------------------------------------------------------------+
void CheckConfirmation()
  {
   g_pendBars++;
   if(g_pendBars > InpConfirmBars)
     {
      g_pendActive = false;
      return;
     }

   double cl1 = iClose(_Symbol, _Period, 1);
   if(g_pendIsBuy ? cl1 <= g_obHigh : cl1 >= g_obLow)
      return;

   //--- one attempt per setup, whatever happens next
   g_pendActive = false;

   double atr = GetATR();
   if(atr <= 0.0)
      return;
   if(iHigh(_Symbol, _Period, 1) - iLow(_Symbol, _Period, 1) < InpMinConfirmATR * atr)
      return;                       // weak, low-momentum break
   OpenTrade(g_pendIsBuy, atr);
  }

//+------------------------------------------------------------------+
//| OpenTrade                                                        |
//| Size, send without stops, then attach them to the real fill      |
//+------------------------------------------------------------------+
void OpenTrade(const bool isBuy, const double atr)
  {
   if(!MarketOpenForEntry())
      return;

   double spreadPts = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spreadPts > InpMaxSpreadPoints)
     {
      PrintFormat("Setup skipped: spread %.0f points exceeds %d.", spreadPts, InpMaxSpreadPoints);
      return;
     }

   //--- planned levels from the current quote
   double price  = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl     = isBuy ? g_sweepExtreme - InpSLBufferATR * atr : g_sweepExtreme + InpSLBufferATR * atr;
   double slDist = isBuy ? price - sl : sl - price;
   if(slDist < InpMinSLATR * atr || slDist < spreadPts * _Point * InpMinSLToSpread)
      return;

   double lot = LotForRisk(slDist);
   if(lot <= 0.0)
      return;
   double margin = 0.0;
   if(OrderCalcMargin(isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, lot, price, margin)
      && margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
     {
      PrintFormat("Setup skipped: %.2f lots needs %.2f margin.", lot, margin);
      return;
     }

   bool sent = isBuy ? trade.Buy(lot, _Symbol, 0.0, 0.0, 0.0, "SMC-Gold")
                     : trade.Sell(lot, _Symbol, 0.0, 0.0, 0.0, "SMC-Gold");
   if(!sent || trade.ResultDeal() == 0)
     {
      PrintFormat("Order failed: %u %s", trade.ResultRetcode(), trade.ResultRetcodeDescription());
      return;
     }

   //--- find the position this deal created
   g_posId = 0;
   if(HistoryDealSelect(trade.ResultDeal()))
      g_posId = HistoryDealGetInteger(trade.ResultDeal(), DEAL_POSITION_ID);
   ulong tk = FindTicket();
   if(tk == 0 || !PositionSelectByTicket(tk))
      return;

   //--- stops from the real fill: the stop keeps its level, the target
   //--- keeps its R multiple, both outside the broker's minimum gap
   double fill   = PositionGetDouble(POSITION_PRICE_OPEN);
   double minGap = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 5) * _Point;
   double risk   = MathMax(isBuy ? fill - sl : sl - fill, minGap);
   double realSL = NormalizeDouble(isBuy ? fill - risk : fill + risk, _Digits);
   double realTP = NormalizeDouble(isBuy ? fill + InpRewardRatio * risk : fill - InpRewardRatio * risk, _Digits);

   if(!trade.PositionModify(tk, realSL, realTP))
     {
      //--- never leave a position without a stop
      Print("Stop attach failed, closing the position: ", trade.ResultRetcodeDescription());
      trade.PositionClose(tk);
      g_posId = 0;
      return;
     }

   g_entryPrice  = fill;
   g_initialRisk = risk;
   g_beDone      = false;
   PrintFormat("Entered %s at %.2f, SL %.2f, TP %.2f, lot %.2f",
               isBuy ? "BUY" : "SELL", fill, realSL, realTP, lot);
  }

//+------------------------------------------------------------------+
//| ManagePosition                                                   |
//| Forget a closed position, optional break-even on ticks           |
//+------------------------------------------------------------------+
void ManagePosition()
  {
   if(g_posId == 0)
      return;
   ulong tk = FindTicket();
   if(tk == 0 || !PositionSelectByTicket(tk))
     {
      g_posId = 0;                  // closed by stop or target
      return;
     }
   if(InpBreakEvenAtR <= 0.0 || g_beDone || g_initialRisk <= 0.0 || !MarketOpenForEntry())
      return;

   bool   isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double run   = isBuy ? bid - g_entryPrice : g_entryPrice - ask;
   if(run < InpBreakEvenAtR * g_initialRisk)
      return;

   double newSL  = NormalizeDouble(isBuy ? g_entryPrice + 0.1 * g_initialRisk
                                         : g_entryPrice - 0.1 * g_initialRisk, _Digits);
   double minGap = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 5) * _Point;
   if(isBuy ? (bid - newSL < minGap) : (newSL - ask < minGap))
      return;
   trade.PositionModify(tk, newSL, PositionGetDouble(POSITION_TP));
   g_beDone = true;                 // one attempt only, no retry storm
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- position management on every tick
   ManagePosition();
   if(!IsNewBar())
      return;

   //--- setup logic once per closed bar, only while flat
   if(g_posId != 0)
      return;
   UpdateSwingPoints();
   if(g_pendActive)
      CheckConfirmation();
   else
      CheckForSweep();
  }
//+------------------------------------------------------------------+
