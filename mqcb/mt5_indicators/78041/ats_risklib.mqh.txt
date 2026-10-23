//+------------------------------------------------------------------+
//|                                                ATS_RiskLib.mqh   |
//|                                          Andy Trading Solutions  |
//+------------------------------------------------------------------+
//| ATS Risk Library: position sizing and account protection for     |
//| MetaTrader 5 Expert Advisors and trade managers.                 |
//|                                                                  |
//|  CAtsSizer          lot size from the stop distance (fixed lot,  |
//|                     % of balance, % of equity or a money amount).|
//|                     It never rounds a lot UP: if the broker      |
//|                     minimum lot would risk more than allowed,    |
//|                     the trade is skipped and the reason given.   |
//|  CAtsDayGuard       daily loss limit, daily profit target and    |
//|                     max trades per day. The state survives a     |
//|                     terminal restart (GlobalVariables).          |
//|  CAtsDrawdownGuard  maximum total loss, static or trailing       |
//|                     (equity or balance high-water mark).         |
//|  CAtsExposure       number of open positions and total money     |
//|                     at risk to the stop losses.                  |
//|  CAtsFilters        spread limit, trading session, Friday cutoff.|
//|                                                                  |
//| Nothing here sends an order. The library only measures and says  |
//| yes or no; what to do about a "no" is up to your EA.             |
//|                                                                  |
//| Typical use inside an EA:                                        |
//|   if(guard.CanOpen(why) && dd.CanOpen(why) && flt.Ok(why))       |
//|     { double lots = sizer.Lots(slDistance, ORDER_TYPE_BUY, ask); |
//|       if(lots > 0.0) { ... send the order ... } }                |
//+------------------------------------------------------------------+
#property copyright "Andy Trading Solutions"
#property link      "https://www.mql5.com/en/users/andyxi"
#property version   "1.00"

#ifndef ATS_RISKLIB_MQH
#define ATS_RISKLIB_MQH

#define ATSRL_VERSION "1.00"

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_ATS_LOT_MODE
  {
   ATS_LOT_FIXED        = 0, // Fixed lot
   ATS_LOT_RISK_BALANCE = 1, // Risk % of balance
   ATS_LOT_RISK_EQUITY  = 2, // Risk % of equity
   ATS_LOT_RISK_MONEY   = 3  // Fixed money risk (account currency)
  };

enum ENUM_ATS_SKIP
  {
   ATS_OK              = 0,  // No problem
   ATS_SKIP_BAD_INPUT  = 1,  // Stop distance, risk or tick value is not usable
   ATS_SKIP_BELOW_MIN  = 2,  // Allowed risk is smaller than the broker minimum lot
   ATS_SKIP_MARGIN     = 3   // Not enough free margin
  };

enum ENUM_ATS_DD_MODE
  {
   ATS_DD_STATIC         = 0, // Static: limit measured from the initial balance
   ATS_DD_TRAIL_EQUITY   = 1, // Trailing: from the highest equity reached
   ATS_DD_TRAIL_BALANCE  = 2  // Trailing: from the highest balance reached
  };

enum ENUM_ATS_LEVEL
  {
   ATS_LEVEL_OK     = 0, // Inside the limit
   ATS_LEVEL_WARN   = 1, // Warning level reached
   ATS_LEVEL_LOCKED = 2  // Limit reached
  };

//+------------------------------------------------------------------+
//| Pure helpers (no terminal data: easy to test with fixed numbers) |
//+------------------------------------------------------------------+

//--- Text for a skip code.
string AtsSkipText(const ENUM_ATS_SKIP code)
  {
   switch(code)
     {
      case ATS_OK:             return "ok";
      case ATS_SKIP_BAD_INPUT: return "invalid stop distance, risk or tick value";
      case ATS_SKIP_BELOW_MIN: return "allowed risk is below the broker minimum lot: trade skipped to respect the risk limit";
      case ATS_SKIP_MARGIN:    return "not enough free margin";
     }
   return "unknown";
  }

//--- Turns a negative zero (-0.0) into 0.0, so that "%.0f" never prints "-0".
double AtsClean(const double value)
  {
   return (MathAbs(value) < 1e-12) ? 0.0 : value;
  }

//--- Number with thousands separators and 2 decimals, for panels: 1234567.891 -> "1,234,567.89".
string AtsMoneyText(const double value)
  {
   string s = DoubleToString(MathAbs(AtsClean(value)), 2);
   int dot = StringFind(s, ".");
   string intPart = StringSubstr(s, 0, dot);
   string frac    = StringSubstr(s, dot);
   string out = "";
   int n = StringLen(intPart);
   for(int i = 0; i < n; i++)
     {
      out += StringSubstr(intPart, i, 1);
      int left = n - 1 - i;
      if(left > 0 && left % 3 == 0)
         out += ",";
     }
   bool negative = (value < 0.0 && MathRound(MathAbs(value) * 100.0) > 0.0);   // a value that rounds to 0.00 gets no sign
   return (negative ? "-" : "") + out + frac;
  }

//--- Floors a volume to the volume step. It never rounds up.
double AtsFloorToStep(const double volume, const double step)
  {
   if(step <= 0.0)
      return volume;
   double floored = MathFloor(volume / step + 1e-9) * step;
   int digits = (int)MathMax(0.0, MathCeil(-MathLog10(step) - 1e-9));
   return NormalizeDouble(floored, MathMin(digits, 8));
  }

//--- Lot size from a money risk and the loss of 1.0 lot at the stop.
//--- Returns ATS_OK and the lot, or the reason why no lot is allowed.
ENUM_ATS_SKIP AtsLotsFromRisk(const double riskMoney, const double lossPerLot,
                              const double volMin, const double volMax, const double volStep,
                              const double maxLot, double &lots)
  {
   lots = 0.0;
   if(riskMoney <= 0.0 || lossPerLot <= 0.0)
      return ATS_SKIP_BAD_INPUT;
   double lot = AtsFloorToStep(riskMoney / lossPerLot, volStep);
   if(maxLot > 0.0 && lot > maxLot)
      lot = AtsFloorToStep(maxLot, volStep);
   if(volMax > 0.0 && lot > volMax)
      lot = AtsFloorToStep(volMax, volStep);
   if(lot <= 0.0 || lot < volMin - 1e-12)
      return ATS_SKIP_BELOW_MIN;
   lots = lot;
   return ATS_OK;
  }

//--- Start of the "trading day" that contains time t.
//--- dayStartHour is the server hour at which a new day begins (0 = server midnight).
datetime AtsDayStart(const datetime t, const int dayStartHour)
  {
   long offset = (long)dayStartHour * 3600;
   long secs   = (long)t - offset;
   return (datetime)(secs - ((secs % 86400) + 86400) % 86400 + offset);
  }

//--- True if minute-of-day m is inside [from, to). Windows that cross midnight are supported.
bool AtsInWindow(const int m, const int fromMin, const int toMin)
  {
   if(fromMin == toMin)
      return true;                       // empty window means "always"
   if(fromMin < toMin)
      return (m >= fromMin && m < toMin);
   return (m >= fromMin || m < toMin);   // crosses midnight
  }

//--- Money lost by 1.0 lot of a symbol when price moves `distance` (price units) against it.
double AtsLossPerLot(const string symbolName, const double distance)
  {
   double tickSize  = SymbolInfoDouble(symbolName, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbolName, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(symbolName, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0.0 || tickValue <= 0.0 || distance <= 0.0)
      return 0.0;
   return distance / tickSize * tickValue;
  }

//+------------------------------------------------------------------+
//| CAtsSizer: lot size from the stop distance                       |
//+------------------------------------------------------------------+
class CAtsSizer
  {
private:
   string            m_symbol;
   ENUM_ATS_LOT_MODE m_mode;
   double            m_fixedLot;
   double            m_riskValue;    // percent or money, depending on the mode
   double            m_maxLot;       // 0 = no cap
   double            m_marginShare;  // share of free margin one trade may use (0.05 .. 1)
   ENUM_ATS_SKIP     m_lastSkip;

public:
                     CAtsSizer(void) : m_symbol(""), m_mode(ATS_LOT_FIXED), m_fixedLot(0.01), m_riskValue(1.0),
                                       m_maxLot(0.0), m_marginShare(0.9), m_lastSkip(ATS_OK) {}

   //--- riskValue: percent for the two risk modes, money for ATS_LOT_RISK_MONEY.
   void              Init(const string symbolName, const ENUM_ATS_LOT_MODE mode, const double fixedLot,
                          const double riskValue, const double maxLot = 0.0, const double marginShare = 0.9)
     {
      m_symbol      = symbolName;
      m_mode        = mode;
      m_fixedLot    = fixedLot;
      m_riskValue   = riskValue;
      m_maxLot      = maxLot;
      m_marginShare = MathMax(0.05, MathMin(1.0, marginShare));
      m_lastSkip    = ATS_OK;
     }

   ENUM_ATS_SKIP     LastSkip(void)   const { return m_lastSkip; }
   string            LastReason(void) const { return AtsSkipText(m_lastSkip); }

   //--- Money you lose with `lots` if the stop (distance in price units) is hit.
   double            RiskMoney(const double lots, const double slDistance) const
     {
      return lots * AtsLossPerLot(m_symbol, slDistance);
     }

   //--- Lot size for the stop distance. Returns 0.0 when the trade must be skipped.
   //--- orderType and price are only used for the free-margin check.
   double            Lots(const double slDistance, const ENUM_ORDER_TYPE orderType, const double price)
     {
      m_lastSkip = ATS_OK;
      double vmin  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double vmax  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      double vstep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
      double lots  = 0.0;

      if(m_mode == ATS_LOT_FIXED)
        {
         lots = AtsFloorToStep(m_fixedLot, vstep);
         if(m_maxLot > 0.0 && lots > m_maxLot)
            lots = AtsFloorToStep(m_maxLot, vstep);
         if(vmax > 0.0 && lots > vmax)
            lots = AtsFloorToStep(vmax, vstep);
         if(lots <= 0.0 || lots < vmin - 1e-12)
           {
            m_lastSkip = ATS_SKIP_BELOW_MIN;
            return 0.0;
           }
        }
      else
        {
         double riskMoney = m_riskValue;
         if(m_mode == ATS_LOT_RISK_BALANCE)
            riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * m_riskValue / 100.0;
         else if(m_mode == ATS_LOT_RISK_EQUITY)
            riskMoney = AccountInfoDouble(ACCOUNT_EQUITY) * m_riskValue / 100.0;
         m_lastSkip = AtsLotsFromRisk(riskMoney, AtsLossPerLot(m_symbol, slDistance), vmin, vmax, vstep, m_maxLot, lots);
         if(m_lastSkip != ATS_OK)
            return 0.0;
        }

      double margin = 0.0;
      if(OrderCalcMargin(orderType, m_symbol, lots, price, margin))
        {
         double usable = AccountInfoDouble(ACCOUNT_MARGIN_FREE) * m_marginShare;
         if(margin > usable)
           {
            m_lastSkip = ATS_SKIP_MARGIN;
            return 0.0;
           }
        }
      return lots;
     }
  };

//+------------------------------------------------------------------+
//| CAtsDayGuard: daily loss limit, profit target, trades per day    |
//+------------------------------------------------------------------+
class CAtsDayGuard
  {
private:
   string            m_symbol;         // "" = every symbol
   long              m_magic;          // -1 = every magic number
   bool              m_includeFloating;
   int               m_dayStartHour;   // server hour at which a new day begins
   double            m_maxLossPct;     // % of the day-start balance, 0 = off
   double            m_maxLossMoney;   // money, 0 = off
   double            m_profitTargetPct;// % of the day-start balance, 0 = off
   int               m_maxTrades;      // 0 = off
   double            m_warnShare;      // 0..1 share of the loss limit that raises the warning

   datetime          m_dayStart;
   double            m_dayStartBalance;
   double            m_closedPL;
   double            m_floatingPL;
   int               m_tradesToday;
   bool              m_locked;
   string            m_lockReason;
   string            m_gv;
   bool              m_dirty;
   datetime          m_lastScan;

   bool              Match(const string sym, const long magic) const
     {
      return ((m_symbol == "" || sym == m_symbol) && (m_magic < 0 || magic == m_magic));
     }

   static double     DealResult(const ulong deal)
     {
      return HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_SWAP)
           + HistoryDealGetDouble(deal, DEAL_COMMISSION) + HistoryDealGetDouble(deal, DEAL_FEE);
     }

   //--- Result of every trade closed since the day began, on the whole account.
   double            AccountClosedToday(void) const
     {
      double total = 0.0;
      if(!HistorySelect(m_dayStart, TimeCurrent() + 60))
         return 0.0;
      for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
        {
         ulong deal = HistoryDealGetTicket(i);
         if(deal == 0)
            continue;
         ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal, DEAL_TYPE);
         if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
            total += DealResult(deal);
        }
      return total;
     }

   void              ScanHistory(void)
     {
      m_closedPL    = 0.0;
      m_tradesToday = 0;
      if(!HistorySelect(m_dayStart, TimeCurrent() + 60))
         return;
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
        {
         ulong deal = HistoryDealGetTicket(i);
         if(deal == 0)
            continue;
         ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal, DEAL_TYPE);
         if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
            continue;
         if(!Match(HistoryDealGetString(deal, DEAL_SYMBOL), HistoryDealGetInteger(deal, DEAL_MAGIC)))
            continue;
         m_closedPL += DealResult(deal);
         if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) == DEAL_ENTRY_IN)
            m_tradesToday++;
        }
     }

   void              ScanFloating(void)
     {
      m_floatingPL = 0.0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(!Match(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
            continue;
         m_floatingPL += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
        }
     }

   void              StartDay(const datetime dayStart)
     {
      m_dayStart = dayStart;
      string gvDay  = m_gv + "day";
      string gvBal  = m_gv + "bal";
      string gvLock = m_gv + "lock";
      if(GlobalVariableCheck(gvDay) && (datetime)GlobalVariableGet(gvDay) == dayStart && GlobalVariableCheck(gvBal))
         m_dayStartBalance = GlobalVariableGet(gvBal);
      else
        {
         // Started in the middle of a day: rebuild the day-start balance from today's closed deals.
         m_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE) - AccountClosedToday();
         GlobalVariableSet(gvDay, (double)dayStart);
         GlobalVariableSet(gvBal, m_dayStartBalance);
        }
      m_locked     = (GlobalVariableCheck(gvLock) && (datetime)GlobalVariableGet(gvLock) == dayStart);
      m_lockReason = m_locked ? "daily limit already reached today" : "";
     }

   double            LossLimitMoney(void) const
     {
      double limit = 0.0;
      if(m_maxLossPct > 0.0 && m_dayStartBalance > 0.0)
         limit = m_dayStartBalance * m_maxLossPct / 100.0;
      if(m_maxLossMoney > 0.0 && (limit <= 0.0 || m_maxLossMoney < limit))
         limit = m_maxLossMoney;
      return limit;
     }

   void              Evaluate(void)
     {
      if(m_locked)
         return;
      double pl = DayPL();
      string reason = "";
      double lossLimit = LossLimitMoney();
      if(lossLimit > 0.0 && pl <= -lossLimit)
         reason = StringFormat("daily loss limit reached (%.2f of %.2f)", -pl, lossLimit);
      else if(m_profitTargetPct > 0.0 && m_dayStartBalance > 0.0 && pl >= m_dayStartBalance * m_profitTargetPct / 100.0)
         reason = StringFormat("daily profit target reached (%.2f)", pl);
      if(reason == "")
         return;
      m_locked     = true;
      m_lockReason = reason;
      GlobalVariableSet(m_gv + "lock", (double)m_dayStart);
     }

public:
                     CAtsDayGuard(void) : m_symbol(""), m_magic(-1), m_includeFloating(true), m_dayStartHour(0),
                                          m_maxLossPct(0.0), m_maxLossMoney(0.0), m_profitTargetPct(0.0), m_maxTrades(0),
                                          m_warnShare(0.7), m_dayStart(0), m_dayStartBalance(0.0), m_closedPL(0.0),
                                          m_floatingPL(0.0), m_tradesToday(0), m_locked(false), m_lockReason(""),
                                          m_gv(""), m_dirty(true), m_lastScan(0) {}

   //--- tag: any short text that identifies this guard (it names the saved state).
   //--- symbolName "" and magic -1 mean the whole account. A limit set to 0 is off.
   void              Init(const string tag, const string symbolName, const long magic, const bool includeFloating,
                          const int dayStartHour, const double maxLossPct, const double maxLossMoney,
                          const double profitTargetPct, const int maxTrades, const double warnShare = 0.7)
     {
      m_symbol          = symbolName;
      m_magic           = magic;
      m_includeFloating = includeFloating;
      m_dayStartHour    = MathMax(0, MathMin(23, dayStartHour));
      m_maxLossPct      = maxLossPct;
      m_maxLossMoney    = maxLossMoney;
      m_profitTargetPct = profitTargetPct;
      m_maxTrades       = maxTrades;
      m_warnShare       = MathMax(0.1, MathMin(0.99, warnShare));
      m_gv              = StringFormat("ATSRL_D_%I64d_%s_", (long)AccountInfoInteger(ACCOUNT_LOGIN), tag);
      if(StringLen(m_gv) > 50)
         m_gv = StringSubstr(m_gv, 0, 50);
      m_dayStart = 0;
      m_dirty    = true;
      Update();
     }

   //--- Call from OnTradeTransaction so the next Update() rescans the history.
   void              MarkDirty(void) { m_dirty = true; }

   //--- Call on every tick or from a timer. Floating P/L is read every call, the history every 10 s or when marked dirty.
   void              Update(void)
     {
      datetime now      = TimeCurrent();
      datetime dayStart = AtsDayStart(now, m_dayStartHour);
      if(dayStart != m_dayStart)
        {
         StartDay(dayStart);
         m_dirty = true;
        }
      if(m_dirty || now - m_lastScan >= 10)
        {
         ScanHistory();
         m_lastScan = now;
         m_dirty    = false;
        }
      ScanFloating();
      Evaluate();
     }

   //--- Yes or no for a new trade, with the reason when the answer is no.
   bool              CanOpen(string &reason) const
     {
      if(m_locked)
        {
         reason = m_lockReason;
         return false;
        }
      if(m_maxTrades > 0 && m_tradesToday >= m_maxTrades)
        {
         reason = StringFormat("max %d trades per day reached", m_maxTrades);
         return false;
        }
      reason = "";
      return true;
     }

   bool              Locked(void)          const { return m_locked; }
   string            LockReason(void)      const { return m_lockReason; }
   double            DayPL(void)           const { return m_closedPL + (m_includeFloating ? m_floatingPL : 0.0); }
   double            ClosedPL(void)        const { return m_closedPL; }
   double            FloatingPL(void)      const { return m_floatingPL; }
   int               TradesToday(void)     const { return m_tradesToday; }
   double            DayStartBalance(void) const { return m_dayStartBalance; }
   datetime          DayStart(void)        const { return m_dayStart; }

   //--- Loss limit of the day in money (0 = no loss limit).
   double            LossLimit(void) const { return LossLimitMoney(); }

   //--- Money still available before the daily loss limit (0 when locked, -1 when there is no limit).
   double            Remaining(void) const
     {
      double limit = LossLimitMoney();
      if(limit <= 0.0)
         return -1.0;
      if(m_locked)
         return 0.0;
      return MathMax(0.0, limit + DayPL());
     }

   //--- Share of the daily loss limit already used, 0..1 (0 when there is no limit).
   double            Used(void) const
     {
      double limit = LossLimitMoney();
      if(limit <= 0.0)
         return 0.0;
      if(m_locked)
         return 1.0;
      return AtsClean(MathMax(0.0, MathMin(1.0, -DayPL() / limit)));
     }

   //--- Deletes the saved state of this guard (day start balance and lock). Use it when the guard is removed for good.
   void              Forget(void)
     {
      GlobalVariableDel(m_gv + "day");
      GlobalVariableDel(m_gv + "bal");
      GlobalVariableDel(m_gv + "lock");
     }

   ENUM_ATS_LEVEL    Level(void) const
     {
      if(m_locked)
         return ATS_LEVEL_LOCKED;
      return (Used() >= m_warnShare) ? ATS_LEVEL_WARN : ATS_LEVEL_OK;
     }
  };

//+------------------------------------------------------------------+
//| CAtsDrawdownGuard: maximum total loss, static or trailing        |
//+------------------------------------------------------------------+
class CAtsDrawdownGuard
  {
private:
   ENUM_ATS_DD_MODE  m_mode;
   double            m_maxPct;        // % of the reference value
   double            m_initial;       // initial balance
   double            m_peak;          // high-water mark (trailing modes)
   bool              m_lockAtInitial; // trailing floor never rises above the initial balance
   double            m_warnShare;
   bool              m_locked;
   string            m_gv;

   double            Current(void) const
     {
      return (m_mode == ATS_DD_TRAIL_BALANCE) ? AccountInfoDouble(ACCOUNT_BALANCE) : AccountInfoDouble(ACCOUNT_EQUITY);
     }

public:
                     CAtsDrawdownGuard(void) : m_mode(ATS_DD_STATIC), m_maxPct(10.0), m_initial(0.0), m_peak(0.0),
                                               m_lockAtInitial(true), m_warnShare(0.7), m_locked(false), m_gv("") {}

   //--- initialBalance <= 0: the balance found the first time the guard runs is saved and used.
   //--- lockAtInitial (trailing modes): once the account has grown enough, the floor stops at the initial balance.
   void              Init(const string tag, const ENUM_ATS_DD_MODE mode, const double maxPct,
                          const double initialBalance, const bool lockAtInitial, const double warnShare = 0.7)
     {
      m_mode          = mode;
      m_maxPct        = maxPct;
      m_lockAtInitial = lockAtInitial;
      m_warnShare     = MathMax(0.1, MathMin(0.99, warnShare));
      m_gv            = StringFormat("ATSRL_X_%I64d_%s_", (long)AccountInfoInteger(ACCOUNT_LOGIN), tag);
      if(StringLen(m_gv) > 50)
         m_gv = StringSubstr(m_gv, 0, 50);

      if(initialBalance > 0.0)
         m_initial = initialBalance;
      else if(GlobalVariableCheck(m_gv + "init"))
         m_initial = GlobalVariableGet(m_gv + "init");
      else
         m_initial = AccountInfoDouble(ACCOUNT_BALANCE);
      GlobalVariableSet(m_gv + "init", m_initial);

      m_peak   = GlobalVariableCheck(m_gv + "peak") ? GlobalVariableGet(m_gv + "peak") : MathMax(m_initial, Current());
      m_locked = GlobalVariableCheck(m_gv + "lock") && GlobalVariableGet(m_gv + "lock") > 0.0;
      Update();
     }

   //--- Call on every tick or from a timer.
   void              Update(void)
     {
      double now = Current();
      if(m_mode != ATS_DD_STATIC && now > m_peak)
        {
         m_peak = now;
         GlobalVariableSet(m_gv + "peak", m_peak);
        }
      if(!m_locked && now <= Floor())
        {
         m_locked = true;
         GlobalVariableSet(m_gv + "lock", 1.0);
        }
     }

   //--- Account value below which the guard locks.
   double            Floor(void) const
     {
      double floorStatic = m_initial * (1.0 - m_maxPct / 100.0);
      if(m_mode == ATS_DD_STATIC)
         return floorStatic;
      double floorTrail = m_peak * (1.0 - m_maxPct / 100.0);
      if(m_lockAtInitial && floorTrail > m_initial)
         floorTrail = m_initial;
      return floorTrail;
     }

   bool              Locked(void)    const { return m_locked; }
   double            Initial(void)   const { return m_initial; }
   double            Peak(void)      const { return m_peak; }

   //--- Money between the account and the floor (0 when locked).
   double            Remaining(void) const { return m_locked ? 0.0 : MathMax(0.0, Current() - Floor()); }

   //--- Share of the allowed drawdown already used, 0..1.
   double            Used(void) const
     {
      if(m_locked)
         return 1.0;
      double ref   = (m_mode == ATS_DD_STATIC) ? m_initial : m_peak;
      double room  = ref - Floor();
      if(room <= 0.0)
         return 0.0;
      return AtsClean(MathMax(0.0, MathMin(1.0, (ref - Current()) / room)));
     }

   //--- Deletes the saved state of this guard (initial balance, high-water mark and lock). Use it when the guard is removed for good.
   void              Forget(void)
     {
      GlobalVariableDel(m_gv + "init");
      GlobalVariableDel(m_gv + "peak");
      GlobalVariableDel(m_gv + "lock");
     }

   ENUM_ATS_LEVEL    Level(void) const
     {
      if(m_locked)
         return ATS_LEVEL_LOCKED;
      return (Used() >= m_warnShare) ? ATS_LEVEL_WARN : ATS_LEVEL_OK;
     }

   bool              CanOpen(string &reason) const
     {
      if(m_locked)
        {
         reason = StringFormat("maximum drawdown reached (floor %.2f)", Floor());
         return false;
        }
      reason = "";
      return true;
     }

   //--- Removes the saved lock and high-water mark (use only when the account is reset).
   void              Reset(void)
     {
      GlobalVariableDel(m_gv + "lock");
      GlobalVariableDel(m_gv + "peak");
      m_locked = false;
      m_peak   = MathMax(m_initial, Current());
     }
  };

//+------------------------------------------------------------------+
//| CAtsExposure: open positions and money at risk                   |
//+------------------------------------------------------------------+
class CAtsExposure
  {
private:
   string            m_symbol;      // "" = every symbol
   long              m_magic;       // -1 = every magic number
   int               m_maxPositions;// 0 = off
   double            m_maxRiskPct;  // % of equity, 0 = off
   int               m_count;
   int               m_unprotected;
   double            m_riskMoney;

public:
                     CAtsExposure(void) : m_symbol(""), m_magic(-1), m_maxPositions(0), m_maxRiskPct(0.0),
                                          m_count(0), m_unprotected(0), m_riskMoney(0.0) {}

   void              Init(const string symbolName, const long magic, const int maxPositions, const double maxRiskPct)
     {
      m_symbol       = symbolName;
      m_magic        = magic;
      m_maxPositions = maxPositions;
      m_maxRiskPct   = maxRiskPct;
      Update();
     }

   //--- Recounts the open positions and the money they risk down to their stop loss.
   void              Update(void)
     {
      m_count       = 0;
      m_unprotected = 0;
      m_riskMoney   = 0.0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         string sym = PositionGetString(POSITION_SYMBOL);
         if((m_symbol != "" && sym != m_symbol) || (m_magic >= 0 && PositionGetInteger(POSITION_MAGIC) != m_magic))
            continue;
         m_count++;
         double sl = PositionGetDouble(POSITION_SL);
         if(sl <= 0.0)
           {
            m_unprotected++;
            continue;
           }
         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         bool   isBuy = ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
         double dist = isBuy ? open - sl : sl - open;
         if(dist > 0.0)      // a stop beyond break-even carries no initial risk
            m_riskMoney += PositionGetDouble(POSITION_VOLUME) * AtsLossPerLot(sym, dist);
        }
     }

   int               Count(void)       const { return m_count; }
   int               Unprotected(void) const { return m_unprotected; }
   double            RiskMoney(void)   const { return m_riskMoney; }
   double            RiskPct(void) const
     {
      double eq = AccountInfoDouble(ACCOUNT_EQUITY);
      return (eq > 0.0) ? m_riskMoney / eq * 100.0 : 0.0;
     }

   //--- Can one more trade that risks `extraRiskMoney` be added?
   bool              CanAdd(const double extraRiskMoney, string &reason) const
     {
      if(m_maxPositions > 0 && m_count >= m_maxPositions)
        {
         reason = StringFormat("max %d open positions reached", m_maxPositions);
         return false;
        }
      if(m_maxRiskPct > 0.0)
        {
         double eq = AccountInfoDouble(ACCOUNT_EQUITY);
         if(eq > 0.0 && (m_riskMoney + extraRiskMoney) / eq * 100.0 > m_maxRiskPct)
           {
            reason = StringFormat("total open risk would exceed %.2f%% of equity", m_maxRiskPct);
            return false;
           }
        }
      reason = "";
      return true;
     }
  };

//+------------------------------------------------------------------+
//| CAtsFilters: spread, session, Friday cutoff                      |
//+------------------------------------------------------------------+
class CAtsFilters
  {
private:
   string            m_symbol;
   int               m_maxSpreadPoints;  // 0 = off
   bool              m_useSession;
   int               m_fromMin;          // minutes from server midnight
   int               m_toMin;
   int               m_fridayCutoffHour; // -1 = off

public:
                     CAtsFilters(void) : m_symbol(""), m_maxSpreadPoints(0), m_useSession(false), m_fromMin(0),
                                         m_toMin(0), m_fridayCutoffHour(-1) {}

   //--- Session times are SERVER time. A window that crosses midnight (22:00-06:00) works.
   void              Init(const string symbolName, const int maxSpreadPoints, const bool useSession,
                          const int fromHour, const int fromMinute, const int toHour, const int toMinute,
                          const int fridayCutoffHour = -1)
     {
      m_symbol           = symbolName;
      m_maxSpreadPoints  = maxSpreadPoints;
      m_useSession       = useSession;
      m_fromMin          = MathMax(0, MathMin(23, fromHour)) * 60 + MathMax(0, MathMin(59, fromMinute));
      m_toMin            = MathMax(0, MathMin(23, toHour)) * 60 + MathMax(0, MathMin(59, toMinute));
      m_fridayCutoffHour = fridayCutoffHour;
     }

   bool              SpreadOk(string &reason) const
     {
      if(m_maxSpreadPoints <= 0)
        {
         reason = "";
         return true;
        }
      long spread = SymbolInfoInteger(m_symbol, SYMBOL_SPREAD);
      if(spread > m_maxSpreadPoints)
        {
         reason = StringFormat("spread %d points is above the limit of %d", (int)spread, m_maxSpreadPoints);
         return false;
        }
      reason = "";
      return true;
     }

   bool              SessionOk(string &reason) const
     {
      MqlDateTime t;
      TimeToStruct(TimeCurrent(), t);
      if(m_fridayCutoffHour >= 0 && t.day_of_week == 5 && t.hour >= m_fridayCutoffHour)
        {
         reason = StringFormat("Friday cutoff after %02d:00 server time", m_fridayCutoffHour);
         return false;
        }
      if(m_useSession && !AtsInWindow(t.hour * 60 + t.min, m_fromMin, m_toMin))
        {
         reason = StringFormat("outside the trading session %02d:%02d-%02d:%02d server time",
                               m_fromMin / 60, m_fromMin % 60, m_toMin / 60, m_toMin % 60);
         return false;
        }
      reason = "";
      return true;
     }

   //--- All filters at once.
   bool              Ok(string &reason) const
     {
      return (SpreadOk(reason) && SessionOk(reason));
     }
  };

#endif
//+------------------------------------------------------------------+
