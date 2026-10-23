#property copyright "Copyright 2026, IronHawk"
#property link      "https://www.mql5.com"
#property version   "2.04"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

enum IH_SETUP_STATE
{
   IH_DETECTED = 0,
   IH_ARMED,
   IH_ACTIVE,
   IH_TP,
   IH_SL,
   IH_EXPIRED,
   IH_INVALIDATED,
   IH_AMBIGUOUS
};

enum IH_ENTRY_TYPE
{
   IH_LIMIT_ENTRY = 0,
   IH_STOP_ENTRY
};

input group "Core logic"
input int      InpHistoryBars             = 2500;
input int      InpSwingLeft               = 3;
input int      InpSwingRight              = 3;
input int      InpSweepMemoryBars         = 24;
input int      InpFVGSequenceBars         = 3;
input int      InpPendingExpiryBars       = 12;
input int      InpActiveExpiryBars        = 72;
input double   InpBreakBufferATR          = 0.10;
input double   InpMinimumDisplacementATR  = 0.50;
input double   InpContinuationDisplacementATR = 0.60;
input double   InpMomentumBreakDisplacementATR = 0.70;
input double   InpStopBufferATR           = 0.15;
input double   InpMaximumRiskATR          = 3.50;
input double   InpMinimumTargetRoomR      = 1.30;
input double   InpEqualLevelToleranceATR  = 0.10;

input group "Confirmation filters"
input int      InpATRPeriod               = 14;
input int      InpRSIPeriod               = 21;
input int      InpEMAFastPeriod           = 20;
input int      InpEMASlowPeriod           = 50;
input int      InpMACDFast                = 12;
input int      InpMACDSlow                = 26;
input int      InpMACDSignal              = 9;
input double   InpMaximumSpreadRiskPart   = 0.20;
input double   InpLowVolatilityFactor     = 0.70;
input double   InpRangeWidthATR           = 3.00;
input bool     InpAllowFreshOBFallback    = true;

input group "Retail frequency"
input bool     InpEnableDailyRetailFallback = true;
input int      InpMinimumDailySignals     = 2;
input int      InpRetailFirstSignalHour   = 9;
input int      InpRetailSecondSignalHour  = 14;
input double   InpRetailStopATR           = 0.80;
input double   InpRetailTargetR           = 1.50;

input group "Entry and targets"
input double   InpLimitMaximumDistanceATR = 0.75;
input double   InpStopMinimumBodyATR      = 1.00;
input double   InpStopEntryBufferATR      = 0.05;
input bool     InpUseXAUFixedTarget       = false;
input int      InpXAUFixedTargetPoints    = 500;

input group "Display"
input int      InpMaximumDisplayedSetups  = 5;
input color    InpBullishColor            = clrDeepSkyBlue;
input color    InpBearishColor            = clrTomato;
input color    InpTargetColor             = clrLimeGreen;
input color    InpStopColor               = clrCrimson;
input color    InpNeutralColor            = clrSilver;
input bool     InpShowHistoricalSetups    = true;
input bool     InpShowRecentSetupHistory  = true;
input int      InpRecentSetupCount        = 5;

input group "Alerts and audit"
input bool     InpTerminalAlerts          = true;
input bool     InpPushAlerts              = false;
input bool     InpEmailAlerts             = false;
input bool     InpWriteAuditCSV           = false;

struct IH_SWING
{
   bool     valid;
   bool     broken;
   bool     swept;
   int      index;
   datetime time;
   double   price;
   int      pool_count;
};

struct IH_SWEEP
{
   bool     valid;
   bool     used;
   int      direction;
   int      index;
   datetime time;
   double   level;
   double   extreme;
   int      pool_count;
};

struct IH_SETUP
{
   string         id;
   int            direction;
   IH_SETUP_STATE state;
   IH_ENTRY_TYPE  entry_type;
   int            created_index;
   datetime       created_time;
   datetime       updated_time;
   double         zone_low;
   double         zone_high;
   double         entry;
   double         stop;
   double         tp1;
   double         tp2;
   double         atr_at_creation;
   int            score;
   int            ob_points;
   bool           momentum_aligned;
   bool           environment_aligned;
   bool           break_was_choch;
   bool           tp1_hit;
   int            visits;
   bool           was_inside;
   string         regime;
   string         note;
};

struct IH_SNAPSHOT
{
   string         id;
   IH_SETUP_STATE state;
   bool           tp1_hit;
};

string   g_prefix = "IHSMC_";
string   g_product_short = "IHSMC";
int      g_atr_handle = INVALID_HANDLE;
int      g_rsi_handle = INVALID_HANDLE;
int      g_ema_fast_handle = INVALID_HANDLE;
int      g_ema_slow_handle = INVALID_HANDLE;
int      g_macd_handle = INVALID_HANDLE;
datetime g_last_closed_bar = 0;
bool     g_initialized = false;
int      g_bias = 0;
string   g_regime = "UNKNOWN";
string   g_last_reason = "WAITING FOR CLOSED M5 DATA";
IH_SWING g_last_high;
IH_SWING g_last_low;
IH_SWING g_highs[];
IH_SWING g_lows[];
IH_SWEEP g_recent_low_sweep;
IH_SWEEP g_recent_high_sweep;
IH_SETUP g_setups[];
int      g_detected_sweeps = 0;
int      g_structure_breaks = 0;
int      g_setup_attempts = 0;
int      g_setups_created = 0;
int      g_continuation_setups = 0;
int      g_momentum_break_setups = 0;
int      g_sweep_path_attempts = 0;
int      g_continuation_path_attempts = 0;
int      g_momentum_break_attempts = 0;
int      g_reject_no_path = 0;
int      g_reject_displacement = 0;
int      g_reject_zone = 0;
int      g_reject_risk_target = 0;
int      g_reject_other = 0;
int      g_reject_risk = 0;
int      g_reject_spread = 0;
int      g_reject_liquidity = 0;
int      g_reject_final_target = 0;
int      g_retail_fallback_setups = 0;
int      g_daily_key = -1;
int      g_daily_signal_count = 0;
bool     g_retail_slot1_used = false;
bool     g_retail_slot2_used = false;

string StateText(const IH_SETUP_STATE state)
{
   switch(state)
   {
      case IH_DETECTED:    return "DETECTED";
      case IH_ARMED:       return "ARMED";
      case IH_ACTIVE:      return "ACTIVE";
      case IH_TP:          return "TP";
      case IH_SL:          return "SL";
      case IH_EXPIRED:     return "EXPIRED";
      case IH_INVALIDATED: return "INVALIDATED";
      case IH_AMBIGUOUS:   return "AMBIGUOUS";
   }
   return "UNKNOWN";
}

string DirectionText(const int direction)
{
   return (direction > 0 ? "BUY" : "SELL");
}

string EntryTypeText(const IH_ENTRY_TYPE entry_type)
{
   return (entry_type == IH_LIMIT_ENTRY ? "LIMIT" : "STOP");
}

string ShortEntryTypeText(const IH_ENTRY_TYPE entry_type)
{
   return (entry_type == IH_LIMIT_ENTRY ? "LIM" : "STP");
}

string ShortStateText(const IH_SETUP_STATE state)
{
   switch(state)
   {
      case IH_DETECTED:    return "DET";
      case IH_ARMED:       return "ARM";
      case IH_ACTIVE:      return "ACT";
      case IH_TP:          return "TP";
      case IH_SL:          return "SL";
      case IH_EXPIRED:     return "EXP";
      case IH_INVALIDATED: return "INV";
      case IH_AMBIGUOUS:   return "AMB";
   }
   return "UNK";
}

string ShortHistoryTime(const datetime when)
{
   MqlDateTime parts;
   TimeToStruct(when, parts);
   return StringFormat("%02d.%02d %02d:%02d",
                       parts.mon, parts.day, parts.hour, parts.min);
}

string BiasText()
{
   if(g_bias > 0) return "BULLISH";
   if(g_bias < 0) return "BEARISH";
   return "NEUTRAL";
}

string PriceText(const double value)
{
   return DoubleToString(value, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
}

void ResetSwing(IH_SWING &swing)
{
   swing.valid = false;
   swing.broken = false;
   swing.swept = false;
   swing.index = -1;
   swing.time = 0;
   swing.price = 0.0;
   swing.pool_count = 0;
}

void ResetSweep(IH_SWEEP &sweep)
{
   sweep.valid = false;
   sweep.used = false;
   sweep.direction = 0;
   sweep.index = -1;
   sweep.time = 0;
   sweep.level = 0.0;
   sweep.extreme = 0.0;
   sweep.pool_count = 0;
}

void ResetRuntime()
{
   g_bias = 0;
   g_regime = "UNKNOWN";
   g_last_reason = "WAITING FOR LIQUIDITY SWEEP";
   ResetSwing(g_last_high);
   ResetSwing(g_last_low);
   ResetSweep(g_recent_low_sweep);
   ResetSweep(g_recent_high_sweep);
   ArrayResize(g_highs, 0);
   ArrayResize(g_lows, 0);
   ArrayResize(g_setups, 0);
   g_detected_sweeps = 0;
   g_structure_breaks = 0;
   g_setup_attempts = 0;
   g_setups_created = 0;
   g_continuation_setups = 0;
   g_momentum_break_setups = 0;
   g_sweep_path_attempts = 0;
   g_continuation_path_attempts = 0;
   g_momentum_break_attempts = 0;
   g_reject_no_path = 0;
   g_reject_displacement = 0;
   g_reject_zone = 0;
   g_reject_risk_target = 0;
   g_reject_other = 0;
   g_reject_risk = 0;
   g_reject_spread = 0;
   g_reject_liquidity = 0;
   g_reject_final_target = 0;
   g_retail_fallback_setups = 0;
   g_daily_key = -1;
   g_daily_signal_count = 0;
   g_retail_slot1_used = false;
   g_retail_slot2_used = false;
}

bool ValidNumber(const double value)
{
   return MathIsValidNumber(value) && value != EMPTY_VALUE;
}

bool IsSwingHigh(const MqlRates &rates[], const int index)
{
   for(int j = 1; j <= InpSwingLeft; ++j)
      if(rates[index].high <= rates[index - j].high)
         return false;
   for(int j = 1; j <= InpSwingRight; ++j)
      if(rates[index].high < rates[index + j].high)
         return false;
   return true;
}

bool IsSwingLow(const MqlRates &rates[], const int index)
{
   for(int j = 1; j <= InpSwingLeft; ++j)
      if(rates[index].low >= rates[index - j].low)
         return false;
   for(int j = 1; j <= InpSwingRight; ++j)
      if(rates[index].low > rates[index + j].low)
         return false;
   return true;
}

void AddConfirmedHigh(const MqlRates &rates[], const double &atr[], const int index)
{
   IH_SWING swing;
   swing.valid = true;
   swing.broken = false;
   swing.swept = false;
   swing.index = index;
   swing.time = rates[index].time;
   swing.price = rates[index].high;
   swing.pool_count = 1;
   if(g_last_high.valid && ValidNumber(atr[index]))
   {
      double tolerance = InpEqualLevelToleranceATR * atr[index];
      if(MathAbs(swing.price - g_last_high.price) <= tolerance)
         swing.pool_count = g_last_high.pool_count + 1;
   }
   int size = ArraySize(g_highs);
   ArrayResize(g_highs, size + 1);
   g_highs[size] = swing;
   g_last_high = swing;
}

void AddConfirmedLow(const MqlRates &rates[], const double &atr[], const int index)
{
   IH_SWING swing;
   swing.valid = true;
   swing.broken = false;
   swing.swept = false;
   swing.index = index;
   swing.time = rates[index].time;
   swing.price = rates[index].low;
   swing.pool_count = 1;
   if(g_last_low.valid && ValidNumber(atr[index]))
   {
      double tolerance = InpEqualLevelToleranceATR * atr[index];
      if(MathAbs(swing.price - g_last_low.price) <= tolerance)
         swing.pool_count = g_last_low.pool_count + 1;
   }
   int size = ArraySize(g_lows);
   ArrayResize(g_lows, size + 1);
   g_lows[size] = swing;
   g_last_low = swing;
}

void MarkLastHighBroken()
{
   g_last_high.broken = true;
   int size = ArraySize(g_highs);
   if(size > 0 && g_highs[size - 1].index == g_last_high.index)
      g_highs[size - 1].broken = true;
}

void MarkLastLowBroken()
{
   g_last_low.broken = true;
   int size = ArraySize(g_lows);
   if(size > 0 && g_lows[size - 1].index == g_last_low.index)
      g_lows[size - 1].broken = true;
}

void MarkLastHighSwept()
{
   g_last_high.swept = true;
   int size = ArraySize(g_highs);
   if(size > 0 && g_highs[size - 1].index == g_last_high.index)
      g_highs[size - 1].swept = true;
}

void MarkLastLowSwept()
{
   g_last_low.swept = true;
   int size = ArraySize(g_lows);
   if(size > 0 && g_lows[size - 1].index == g_last_low.index)
      g_lows[size - 1].swept = true;
}

double AverageATR(const double &atr[], const int index, const int period)
{
   int start = MathMax(0, index - period + 1);
   double sum = 0.0;
   int count = 0;
   for(int i = start; i <= index; ++i)
   {
      if(ValidNumber(atr[i]) && atr[i] > 0.0)
      {
         sum += atr[i];
         ++count;
      }
   }
   return (count > 0 ? sum / count : 0.0);
}

string DetermineRegime(const MqlRates &rates[], const double &atr[],
                       const double &ema_fast[], const double &ema_slow[],
                       const double &macd_main[], const double &macd_signal[],
                       const int index)
{
   double current_atr = atr[index];
   double average_atr = AverageATR(atr, index, 50);
   if(!ValidNumber(current_atr) || current_atr <= 0.0)
      return "UNKNOWN";
   if(average_atr > 0.0 && current_atr < average_atr * InpLowVolatilityFactor)
      return "LOW VOLATILITY";

   int start = MathMax(0, index - 19);
   double highest = rates[start].high;
   double lowest = rates[start].low;
   for(int i = start + 1; i <= index; ++i)
   {
      highest = MathMax(highest, rates[i].high);
      lowest = MathMin(lowest, rates[i].low);
   }
   double width_atr = (highest - lowest) / current_atr;
   double ema_separation = MathAbs(ema_fast[index] - ema_slow[index]) / current_atr;
   if(width_atr < InpRangeWidthATR && ema_separation < 0.25)
      return "RANGING";

   bool bullish_alignment = ema_fast[index] > ema_slow[index] &&
                            macd_main[index] > macd_signal[index];
   bool bearish_alignment = ema_fast[index] < ema_slow[index] &&
                            macd_main[index] < macd_signal[index];
   if((g_bias > 0 && bullish_alignment) || (g_bias < 0 && bearish_alignment))
      return "TRENDING";
   return "REVERSAL";
}

bool FindOrderBlock(const MqlRates &rates[], const int direction,
                    const int sweep_index, const int break_index,
                    double &zone_low, double &zone_high, int &visits)
{
   int start = MathMax(sweep_index, break_index - 12);
   int ob_index = -1;
   for(int i = break_index - 1; i >= start; --i)
   {
      bool opposing = (direction > 0 ? rates[i].close < rates[i].open
                                     : rates[i].close > rates[i].open);
      if(opposing)
      {
         ob_index = i;
         break;
      }
   }
   if(ob_index < 0)
      return false;

   zone_low = rates[ob_index].low;
   zone_high = rates[ob_index].high;
   visits = 0;
   bool was_inside = false;
   for(int i = ob_index + 1; i < break_index; ++i)
   {
      bool inside = rates[i].low <= zone_high && rates[i].high >= zone_low;
      if(inside && !was_inside)
         ++visits;
      was_inside = inside;
      if((direction > 0 && rates[i].close < zone_low) ||
         (direction < 0 && rates[i].close > zone_high))
         return false;
   }
   return visits < 2;
}

double NearestOpposingLiquidity(const int direction, const double entry)
{
   double result = 0.0;
   if(direction > 0)
   {
      for(int i = 0; i < ArraySize(g_highs); ++i)
      {
         if(g_highs[i].broken || g_highs[i].swept || g_highs[i].price <= entry)
            continue;
         if(result == 0.0 || g_highs[i].price < result)
            result = g_highs[i].price;
      }
   }
   else
   {
      for(int i = 0; i < ArraySize(g_lows); ++i)
      {
         if(g_lows[i].broken || g_lows[i].swept || g_lows[i].price >= entry)
            continue;
         if(result == 0.0 || g_lows[i].price > result)
            result = g_lows[i].price;
      }
   }
   return result;
}

int EffectiveScore(const IH_SETUP &setup, const int current_index)
{
   int age = MathMax(0, current_index - setup.created_index);
   int decay = (age > 3 ? (age - 3) * 2 : 0);
   if(setup.visits >= 2)
      decay += (setup.visits - 1) * 5;
   int score = setup.score - decay;
   return MathMax(0, score);
}

void SetState(IH_SETUP &setup, const IH_SETUP_STATE state,
              const datetime when, const string note)
{
   setup.state = state;
   setup.updated_time = when;
   setup.note = note;
}

void UpdateSetups(const MqlRates &rates[], const int index,
                  const int break_direction, const bool break_was_choch)
{
   for(int n = 0; n < ArraySize(g_setups); ++n)
   {
      if(index <= g_setups[n].created_index)
         continue;

      int age = index - g_setups[n].created_index;
      bool terminal = g_setups[n].state == IH_TP || g_setups[n].state == IH_SL ||
                      g_setups[n].state == IH_EXPIRED ||
                      g_setups[n].state == IH_INVALIDATED ||
                      g_setups[n].state == IH_AMBIGUOUS;
      if(terminal)
         continue;

      if(g_setups[n].state == IH_ARMED || g_setups[n].state == IH_DETECTED)
      {
         bool stop_invalid = (g_setups[n].direction > 0
                              ? rates[index].close <= g_setups[n].stop
                              : rates[index].close >= g_setups[n].stop);
         bool opposite_choch = break_was_choch &&
                               break_direction == -g_setups[n].direction;
         if(stop_invalid || opposite_choch)
         {
            SetState(g_setups[n], IH_INVALIDATED, rates[index].time,
                     stop_invalid ? "STOP INVALIDATED BEFORE ENTRY"
                                  : "OPPOSITE CHOCH BEFORE ENTRY");
            continue;
         }
         if(age > InpPendingExpiryBars)
         {
            SetState(g_setups[n], IH_EXPIRED, rates[index].time,
                     "ENTRY WINDOW EXPIRED");
            continue;
         }

         bool inside = rates[index].low <= g_setups[n].zone_high &&
                       rates[index].high >= g_setups[n].zone_low;
         if(inside && !g_setups[n].was_inside)
            ++g_setups[n].visits;
         g_setups[n].was_inside = inside;

         bool zone_traversed = (g_setups[n].direction > 0
                                ? rates[index].close < g_setups[n].zone_low
                                : rates[index].close > g_setups[n].zone_high);
         if(zone_traversed && g_setups[n].entry_type == IH_STOP_ENTRY)
         {
            SetState(g_setups[n], IH_INVALIDATED, rates[index].time,
                     "ENTRY ZONE FULLY TRAVERSED");
            continue;
         }

         bool triggered = false;
         if(g_setups[n].entry_type == IH_LIMIT_ENTRY)
            triggered = rates[index].low <= g_setups[n].entry &&
                        rates[index].high >= g_setups[n].entry;
         else if(g_setups[n].direction > 0)
            triggered = rates[index].high >= g_setups[n].entry;
         else
            triggered = rates[index].low <= g_setups[n].entry;

         if(triggered)
            SetState(g_setups[n], IH_ACTIVE, rates[index].time, "ENTRY TRIGGERED");
      }

      if(g_setups[n].state == IH_ACTIVE)
      {
         bool sl_hit = (g_setups[n].direction > 0
                        ? rates[index].low <= g_setups[n].stop
                        : rates[index].high >= g_setups[n].stop);
         bool tp2_hit = (g_setups[n].direction > 0
                         ? rates[index].high >= g_setups[n].tp2
                         : rates[index].low <= g_setups[n].tp2);
         bool tp1_hit = (g_setups[n].direction > 0
                         ? rates[index].high >= g_setups[n].tp1
                         : rates[index].low <= g_setups[n].tp1);

         if(sl_hit && tp2_hit)
         {
            SetState(g_setups[n], IH_AMBIGUOUS, rates[index].time,
                     "TP AND SL TOUCHED IN SAME BAR");
            continue;
         }
         if(sl_hit)
         {
            SetState(g_setups[n], IH_SL, rates[index].time, "STOP LOSS TOUCHED");
            continue;
         }
         if(tp2_hit)
         {
            g_setups[n].tp1_hit = true;
            SetState(g_setups[n], IH_TP, rates[index].time, "TP2 TOUCHED");
            continue;
         }
         if(tp1_hit)
         {
            g_setups[n].tp1_hit = true;
            g_setups[n].note = "TP1 TOUCHED - BREAK EVEN SUGGESTED";
            g_setups[n].updated_time = rates[index].time;
         }
         if(age > InpActiveExpiryBars)
            SetState(g_setups[n], IH_EXPIRED, rates[index].time,
                     "ACTIVE SETUP TIMEOUT");
      }
   }
}

bool IsXAUUSD()
{
   string symbol = _Symbol;
   StringToUpper(symbol);
   return StringFind(symbol, "XAU") >= 0 || StringFind(symbol, "GOLD") >= 0;
}

bool FindFreshFVGInBreakSequence(const MqlRates &rates[], const int direction,
                                 const int sweep_index, const int break_index,
                                 double &fvg_low, double &fvg_high,
                                 int &fvg_index)
{
   int earliest = MathMax(2, MathMax(sweep_index,
                                    break_index - InpFVGSequenceBars));
   for(int candidate = break_index; candidate >= earliest; --candidate)
   {
      double candidate_low = 0.0;
      double candidate_high = 0.0;
      bool gap = false;
      if(direction > 0 && rates[candidate].low > rates[candidate - 2].high)
      {
         candidate_low = rates[candidate - 2].high;
         candidate_high = rates[candidate].low;
         gap = true;
      }
      else if(direction < 0 && rates[candidate].high < rates[candidate - 2].low)
      {
         candidate_low = rates[candidate].high;
         candidate_high = rates[candidate - 2].low;
         gap = true;
      }
      if(!gap || candidate_high <= candidate_low)
         continue;

      bool fully_mitigated = false;
      for(int i = candidate + 1; i <= break_index; ++i)
      {
         if((direction > 0 && rates[i].low <= candidate_low) ||
            (direction < 0 && rates[i].high >= candidate_high))
         {
            fully_mitigated = true;
            break;
         }
      }
      if(fully_mitigated)
         continue;

      fvg_low = candidate_low;
      fvg_high = candidate_high;
      fvg_index = candidate;
      return true;
   }
   return false;
}

void CreateSetup(const MqlRates &rates[], const double &atr[], const double &rsi[],
                 const double &macd_main[], const double &macd_signal[],
                 const int index, const int direction, const bool break_was_choch,
                 IH_SWEEP &sweep)
{
   ++g_setup_attempts;
   double current_atr = atr[index];
   if(!ValidNumber(current_atr) || current_atr <= 0.0)
   {
      ++g_reject_other;
      g_last_reason = "ATR NOT READY";
      return;
   }
   bool has_usable_sweep = !sweep.used && sweep.valid &&
                           index - sweep.index <= InpSweepMemoryBars;
   bool continuation = !has_usable_sweep && !break_was_choch &&
                       g_regime == "TRENDING";
   bool momentum_break = !has_usable_sweep && !continuation &&
                         g_regime == "REVERSAL";
   if(!has_usable_sweep && !continuation && !momentum_break)
   {
      ++g_reject_no_path;
      g_last_reason = "NO QUALIFIED SWEEP, TREND OR MOMENTUM PATH";
      return;
   }
   if(has_usable_sweep)
      ++g_sweep_path_attempts;
   else if(continuation)
      ++g_continuation_path_attempts;
   else
      ++g_momentum_break_attempts;

   double risk_anchor = 0.0;
   int structure_origin_index = -1;
   if(has_usable_sweep)
   {
      risk_anchor = sweep.extreme;
      structure_origin_index = sweep.index;
   }
   else if(direction > 0 && g_last_low.valid)
   {
      risk_anchor = g_last_low.price;
      structure_origin_index = g_last_low.index;
   }
   else if(direction < 0 && g_last_high.valid)
   {
      risk_anchor = g_last_high.price;
      structure_origin_index = g_last_high.index;
   }
   else
   {
      ++g_reject_other;
      g_last_reason = "NO STRUCTURAL STOP ANCHOR";
      return;
   }

   double body = MathAbs(rates[index].close - rates[index].open);
   double body_atr = body / current_atr;
   bool directional_body = (direction > 0 ? rates[index].close > rates[index].open
                                           : rates[index].close < rates[index].open);
   double required_displacement = InpMinimumDisplacementATR;
   if(continuation)
      required_displacement = MathMax(InpMinimumDisplacementATR,
                                      InpContinuationDisplacementATR);
   else if(momentum_break)
      required_displacement = MathMax(InpMinimumDisplacementATR,
                                      InpMomentumBreakDisplacementATR);
   if(!directional_body || body_atr < required_displacement)
   {
      ++g_reject_displacement;
      if(continuation)
         g_last_reason = "CONTINUATION DISPLACEMENT TOO WEAK";
      else if(momentum_break)
         g_last_reason = "MOMENTUM BREAK DISPLACEMENT TOO WEAK";
      else
         g_last_reason = "INSUFFICIENT DISPLACEMENT";
      return;
   }

   double fvg_low = 0.0;
   double fvg_high = 0.0;
   int fvg_index = -1;
   bool has_fvg = FindFreshFVGInBreakSequence(rates, direction,
                                               structure_origin_index,
                                               index, fvg_low, fvg_high,
                                               fvg_index);
   if(g_regime == "LOW VOLATILITY")
   {
      ++g_reject_other;
      g_last_reason = "LOW VOLATILITY";
      return;
   }
   if(g_regime == "RANGING")
   {
      ++g_reject_other;
      g_last_reason = "MARKET IN CONSOLIDATION";
      return;
   }

   double ob_low = 0.0;
   double ob_high = 0.0;
   int ob_visits = 0;
   bool has_ob = FindOrderBlock(rates, direction, structure_origin_index, index,
                                ob_low, ob_high, ob_visits);
   if(!has_fvg && (!InpAllowFreshOBFallback || !has_ob))
   {
      ++g_reject_zone;
      g_last_reason = "NO FRESH FVG OR ORDER BLOCK ZONE";
      return;
   }
   bool ob_overlap = false;
   double zone_low = (has_fvg ? fvg_low : ob_low);
   double zone_high = (has_fvg ? fvg_high : ob_high);
   if(has_fvg && has_ob)
   {
      double overlap_low = MathMax(fvg_low, ob_low);
      double overlap_high = MathMin(fvg_high, ob_high);
      if(overlap_high > overlap_low)
      {
         zone_low = overlap_low;
         zone_high = overlap_high;
         ob_overlap = true;
      }
   }

   double zone_mid = (zone_low + zone_high) * 0.5;
   bool momentum_aligned = (direction > 0
                            ? rsi[index] > 50.0 && macd_main[index] > macd_signal[index]
                            : rsi[index] < 50.0 && macd_main[index] < macd_signal[index]);
   if((continuation || momentum_break) && !momentum_aligned)
   {
      ++g_reject_other;
      g_last_reason = "BREAK MOMENTUM NOT ALIGNED";
      return;
   }
   double zone_distance_atr = MathAbs(rates[index].close - zone_mid) / current_atr;
   IH_ENTRY_TYPE entry_type = IH_LIMIT_ENTRY;
   double entry = zone_mid;
   if(zone_distance_atr > InpLimitMaximumDistanceATR)
   {
      if(body_atr >= InpStopMinimumBodyATR && momentum_aligned)
      {
         entry_type = IH_STOP_ENTRY;
         double entry_buffer = InpStopEntryBufferATR * current_atr;
         entry = (direction > 0 ? rates[index].high + entry_buffer
                                : rates[index].low - entry_buffer);
      }
      else
      {
         ++g_reject_other;
         g_last_reason = "ENTRY ZONE TOO FAR WITHOUT CONTINUATION";
         return;
      }
   }

   double stop_anchor = (has_usable_sweep
                         ? risk_anchor
                         : (direction > 0 ? zone_low : zone_high));
   double stop = (direction > 0 ? stop_anchor - InpStopBufferATR * current_atr
                                : stop_anchor + InpStopBufferATR * current_atr);
   double risk = MathAbs(entry - stop);
   if(risk <= _Point || risk / current_atr > InpMaximumRiskATR)
   {
      ++g_reject_risk_target;
      ++g_reject_risk;
      g_last_reason = "RISK ABOVE MAXIMUM ATR LIMIT";
      return;
   }

   double spread_price = (double)rates[index].spread * _Point;
   if(spread_price > risk * InpMaximumSpreadRiskPart)
   {
      ++g_reject_risk_target;
      ++g_reject_spread;
      g_last_reason = "SPREAD TOO LARGE FOR SETUP RISK";
      return;
   }

   double tp1 = (direction > 0 ? entry + risk : entry - risk);
   double natural_tp2 = (direction > 0 ? entry + 2.0 * risk : entry - 2.0 * risk);
   double liquidity = NearestOpposingLiquidity(direction, entry);
   if(liquidity != 0.0)
   {
      double room_r = MathAbs(liquidity - entry) / risk;
      if(room_r < InpMinimumTargetRoomR)
      {
         ++g_reject_risk_target;
         ++g_reject_liquidity;
         g_last_reason = "OPPOSING LIQUIDITY TOO CLOSE";
         return;
      }
      if(direction > 0)
         natural_tp2 = MathMin(natural_tp2, liquidity);
      else
         natural_tp2 = MathMax(natural_tp2, liquidity);
   }
   if(InpUseXAUFixedTarget && IsXAUUSD() && InpXAUFixedTargetPoints > 0)
   {
      double fixed_target = (direction > 0
                             ? entry + InpXAUFixedTargetPoints * _Point
                             : entry - InpXAUFixedTargetPoints * _Point);
      if(direction > 0)
         natural_tp2 = MathMin(natural_tp2, fixed_target);
      else
         natural_tp2 = MathMax(natural_tp2, fixed_target);
   }
   if(MathAbs(natural_tp2 - entry) / risk < InpMinimumTargetRoomR)
   {
      ++g_reject_risk_target;
      ++g_reject_final_target;
      g_last_reason = "FINAL TARGET ROOM BELOW MINIMUM R";
      return;
   }

   double impulse_mid = (risk_anchor + (direction > 0 ? rates[index].high
                                                     : rates[index].low)) * 0.5;
   bool premium_discount = (direction > 0 ? zone_mid <= impulse_mid
                                          : zone_mid >= impulse_mid);
   int ob_points = (ob_overlap ? (ob_visits == 0 ? 10 : 5) : 0);
   int score = 20 + 15 + (has_fvg ? 15 : 0) + ob_points;
   score += (has_usable_sweep ? 20 : (continuation ? 15 : 10));
   if(momentum_aligned)
      score += 10;
   bool environment_aligned = g_regime != "LOW VOLATILITY" &&
                              g_regime != "RANGING" &&
                              spread_price <= risk * InpMaximumSpreadRiskPart;
   if(environment_aligned)
      score += 10;
   score = MathMin(100, score);
   if(score < 70)
   {
      ++g_reject_other;
      g_last_reason = "QUALITY SCORE BELOW 70";
      return;
   }

   IH_SETUP setup;
   setup.id = StringFormat("%s_M5_%s_%I64d", _Symbol, DirectionText(direction),
                           (long)rates[index].time);
   setup.direction = direction;
   setup.state = IH_ARMED;
   setup.entry_type = entry_type;
   setup.created_index = index;
   setup.created_time = rates[index].time;
   setup.updated_time = rates[index].time;
   setup.zone_low = zone_low;
   setup.zone_high = zone_high;
   setup.entry = entry;
   setup.stop = stop;
   setup.tp1 = tp1;
   setup.tp2 = natural_tp2;
   setup.atr_at_creation = current_atr;
   setup.score = score;
   setup.ob_points = ob_points;
   setup.momentum_aligned = momentum_aligned;
   setup.environment_aligned = environment_aligned;
   setup.break_was_choch = break_was_choch;
   setup.tp1_hit = false;
   setup.visits = 0;
   setup.was_inside = false;
   setup.regime = g_regime;
   string zone_note = "ORDER BLOCK FALLBACK";
   if(has_fvg)
      zone_note = (fvg_index == index
                   ? "FVG ON BREAK"
                   : "FVG " + IntegerToString(index - fvg_index) +
                     " BAR(S) BEFORE BREAK");
   if(has_fvg && ob_overlap)
      zone_note += " + OB OVERLAP";
   string setup_path = (has_usable_sweep
                        ? (sweep.pool_count >= 2 ? "LIQUIDITY POOL"
                                                 : "SWING SWEEP")
                        : (continuation ? "TREND CONTINUATION"
                                        : "MOMENTUM REVERSAL"));
   string stop_note = (has_usable_sweep ? "SWEEP STOP" : "ZONE STOP");
   setup.note = StringFormat("%s | %s | %s | %s | %s",
                             break_was_choch ? "CHoCH" : "BOS",
                             premium_discount ? "PREMIUM/DISCOUNT ALIGNED"
                                              : "MOMENTUM ENTRY",
                             setup_path,
                             zone_note,
                             stop_note);
   int size = ArraySize(g_setups);
   ArrayResize(g_setups, size + 1);
   g_setups[size] = setup;
   if(has_usable_sweep)
      sweep.used = true;
   else if(continuation)
      ++g_continuation_setups;
   else
      ++g_momentum_break_setups;
   ++g_setups_created;
   ++g_daily_signal_count;
   g_last_reason = StringFormat("%s %s ARMED - SCORE %d",
                                DirectionText(direction), EntryTypeText(entry_type), score);
}

int DateKeyAndHour(const datetime when, int &hour)
{
   MqlDateTime parts;
   TimeToStruct(when, parts);
   hour = parts.hour;
   return parts.year * 10000 + parts.mon * 100 + parts.day;
}

void UpdateDailySignalState(const datetime when)
{
   int hour = 0;
   int key = DateKeyAndHour(when, hour);
   if(key == g_daily_key)
      return;
   g_daily_key = key;
   g_daily_signal_count = 0;
   g_retail_slot1_used = false;
   g_retail_slot2_used = false;
}

bool CreateRetailFallbackSetup(const MqlRates &rates[], const double &atr[],
                               const double &rsi[], const double &ema_fast[],
                               const double &ema_slow[], const double &macd_main[],
                               const double &macd_signal[], const int index,
                               const int slot)
{
   double current_atr = atr[index];
   if(!ValidNumber(current_atr) || current_atr <= 0.0)
      return false;

   int votes = 0;
   votes += (ema_fast[index] >= ema_slow[index] ? 1 : -1);
   votes += (macd_main[index] >= macd_signal[index] ? 1 : -1);
   votes += (rsi[index] >= 50.0 ? 1 : -1);
   int direction = (votes > 0 ? 1 : -1);
   int aligned = (3 + (int)MathAbs(votes)) / 2;

   double entry_buffer = InpStopEntryBufferATR * current_atr;
   double entry = (direction > 0 ? rates[index].high + entry_buffer
                                 : rates[index].low - entry_buffer);
   double zone_low = (direction > 0 ? rates[index].close - 0.15 * current_atr
                                    : entry);
   double zone_high = (direction > 0 ? entry
                                     : rates[index].close + 0.15 * current_atr);
   double risk = InpRetailStopATR * current_atr;
   if(risk <= _Point)
      return false;

   double spread_price = (double)rates[index].spread * _Point;
   if(spread_price > risk * InpMaximumSpreadRiskPart)
      return false;

   double stop = (direction > 0 ? entry - risk : entry + risk);
   double tp1 = (direction > 0 ? entry + risk : entry - risk);
   double tp2 = (direction > 0 ? entry + InpRetailTargetR * risk
                               : entry - InpRetailTargetR * risk);
   int score = 55 + aligned * 5;
   if(g_regime == "TRENDING" || g_regime == "REVERSAL")
      score += 5;
   score = MathMin(80, score);

   IH_SETUP setup;
   setup.id = StringFormat("%s_M5_RETAIL_%d_%I64d", _Symbol, slot,
                           (long)rates[index].time);
   setup.direction = direction;
   setup.state = IH_ARMED;
   setup.entry_type = IH_STOP_ENTRY;
   setup.created_index = index;
   setup.created_time = rates[index].time;
   setup.updated_time = rates[index].time;
   setup.zone_low = MathMin(zone_low, zone_high);
   setup.zone_high = MathMax(zone_low, zone_high);
   setup.entry = entry;
   setup.stop = stop;
   setup.tp1 = tp1;
   setup.tp2 = tp2;
   setup.atr_at_creation = current_atr;
   setup.score = score;
   setup.ob_points = 0;
   setup.momentum_aligned = true;
   setup.environment_aligned = (g_regime == "TRENDING" || g_regime == "REVERSAL");
   setup.break_was_choch = false;
   setup.tp1_hit = false;
   setup.visits = 0;
   setup.was_inside = false;
   setup.regime = g_regime;
   setup.note = StringFormat("RETAIL DAILY SLOT %d | %d/3 MOMENTUM | ATR STOP",
                             slot, aligned);

   int size = ArraySize(g_setups);
   ArrayResize(g_setups, size + 1);
   g_setups[size] = setup;
   ++g_setups_created;
   ++g_retail_fallback_setups;
   ++g_daily_signal_count;
   g_last_reason = StringFormat("RETAIL SLOT %d %s STOP ARMED - SCORE %d",
                                slot, DirectionText(direction), score);
   return true;
}

void EnsureRetailDailyFrequency(const MqlRates &rates[], const double &atr[],
                                const double &rsi[], const double &ema_fast[],
                                const double &ema_slow[], const double &macd_main[],
                                const double &macd_signal[], const int index)
{
   if(!InpEnableDailyRetailFallback || InpMinimumDailySignals <= 0)
      return;

   int hour = 0;
   DateKeyAndHour(rates[index].time, hour);
   if(g_daily_signal_count < 1 && !g_retail_slot1_used &&
      hour >= InpRetailFirstSignalHour)
   {
      if(CreateRetailFallbackSetup(rates, atr, rsi, ema_fast, ema_slow,
                                   macd_main, macd_signal, index, 1))
         g_retail_slot1_used = true;
      return;
   }

   if(InpMinimumDailySignals >= 2 && g_daily_signal_count < 2 &&
      !g_retail_slot2_used && hour >= InpRetailSecondSignalHour)
   {
      if(CreateRetailFallbackSetup(rates, atr, rsi, ema_fast, ema_slow,
                                   macd_main, macd_signal, index, 2))
         g_retail_slot2_used = true;
   }
}

void ProcessBar(const MqlRates &rates[], const double &atr[], const double &rsi[],
                const double &ema_fast[], const double &ema_slow[],
                const double &macd_main[], const double &macd_signal[],
                const int index)
{
   UpdateDailySignalState(rates[index].time);
   int candidate = index - InpSwingRight;
   if(candidate >= InpSwingLeft && candidate + InpSwingRight < ArraySize(rates))
   {
      if(IsSwingHigh(rates, candidate))
         AddConfirmedHigh(rates, atr, candidate);
      if(IsSwingLow(rates, candidate))
         AddConfirmedLow(rates, atr, candidate);
   }

   if(g_recent_low_sweep.valid && !g_recent_low_sweep.used &&
      index - g_recent_low_sweep.index <= InpSweepMemoryBars &&
      rates[index].low < g_recent_low_sweep.extreme &&
      rates[index].close > g_recent_low_sweep.level)
      g_recent_low_sweep.extreme = rates[index].low;
   if(g_recent_high_sweep.valid && !g_recent_high_sweep.used &&
      index - g_recent_high_sweep.index <= InpSweepMemoryBars &&
      rates[index].high > g_recent_high_sweep.extreme &&
      rates[index].close < g_recent_high_sweep.level)
      g_recent_high_sweep.extreme = rates[index].high;

   if(g_last_low.valid && !g_last_low.swept && !g_last_low.broken &&
      rates[index].low < g_last_low.price && rates[index].close > g_last_low.price)
   {
      g_recent_low_sweep.valid = true;
      g_recent_low_sweep.used = false;
      g_recent_low_sweep.direction = 1;
      g_recent_low_sweep.index = index;
      g_recent_low_sweep.time = rates[index].time;
      g_recent_low_sweep.level = g_last_low.price;
      g_recent_low_sweep.extreme = rates[index].low;
      g_recent_low_sweep.pool_count = g_last_low.pool_count;
      MarkLastLowSwept();
      ++g_detected_sweeps;
      g_last_reason = "LOW SWEEP CONFIRMED - WAITING FOR BULLISH BREAK";
   }
   if(g_last_high.valid && !g_last_high.swept && !g_last_high.broken &&
      rates[index].high > g_last_high.price && rates[index].close < g_last_high.price)
   {
      g_recent_high_sweep.valid = true;
      g_recent_high_sweep.used = false;
      g_recent_high_sweep.direction = -1;
      g_recent_high_sweep.index = index;
      g_recent_high_sweep.time = rates[index].time;
      g_recent_high_sweep.level = g_last_high.price;
      g_recent_high_sweep.extreme = rates[index].high;
      g_recent_high_sweep.pool_count = g_last_high.pool_count;
      MarkLastHighSwept();
      ++g_detected_sweeps;
      g_last_reason = "HIGH SWEEP CONFIRMED - WAITING FOR BEARISH BREAK";
   }

   int break_direction = 0;
   bool break_was_choch = false;
   if(ValidNumber(atr[index]) && atr[index] > 0.0)
   {
      if(g_last_high.valid && !g_last_high.broken &&
         rates[index].close > g_last_high.price + InpBreakBufferATR * atr[index])
      {
         break_direction = 1;
         break_was_choch = g_bias < 0;
         MarkLastHighBroken();
         g_bias = 1;
      }
      else if(g_last_low.valid && !g_last_low.broken &&
              rates[index].close < g_last_low.price - InpBreakBufferATR * atr[index])
      {
         break_direction = -1;
         break_was_choch = g_bias > 0;
         MarkLastLowBroken();
         g_bias = -1;
      }
   }

   if(break_direction != 0)
      ++g_structure_breaks;

   g_regime = DetermineRegime(rates, atr, ema_fast, ema_slow,
                              macd_main, macd_signal, index);
   UpdateSetups(rates, index, break_direction, break_was_choch);

   if(break_direction > 0)
      CreateSetup(rates, atr, rsi, macd_main, macd_signal, index, 1,
                  break_was_choch, g_recent_low_sweep);
   else if(break_direction < 0)
      CreateSetup(rates, atr, rsi, macd_main, macd_signal, index, -1,
                  break_was_choch, g_recent_high_sweep);

   EnsureRetailDailyFrequency(rates, atr, rsi, ema_fast, ema_slow,
                              macd_main, macd_signal, index);
}

bool LoadSeries(MqlRates &rates[], double &atr[], double &rsi[],
                double &ema_fast[], double &ema_slow[],
                double &macd_main[], double &macd_signal[])
{
   int available = Bars(_Symbol, PERIOD_M5);
   int requested = MathMin(available, MathMax(300, InpHistoryBars));
   if(requested < 100)
      return false;

   ArraySetAsSeries(rates, false);
   int copied = CopyRates(_Symbol, PERIOD_M5, 0, requested, rates);
   if(copied < 100)
      return false;

   ArrayResize(atr, copied);
   ArrayResize(rsi, copied);
   ArrayResize(ema_fast, copied);
   ArrayResize(ema_slow, copied);
   ArrayResize(macd_main, copied);
   ArrayResize(macd_signal, copied);
   ArraySetAsSeries(atr, false);
   ArraySetAsSeries(rsi, false);
   ArraySetAsSeries(ema_fast, false);
   ArraySetAsSeries(ema_slow, false);
   ArraySetAsSeries(macd_main, false);
   ArraySetAsSeries(macd_signal, false);

   if(CopyBuffer(g_atr_handle, 0, 0, copied, atr) != copied) return false;
   if(CopyBuffer(g_rsi_handle, 0, 0, copied, rsi) != copied) return false;
   if(CopyBuffer(g_ema_fast_handle, 0, 0, copied, ema_fast) != copied) return false;
   if(CopyBuffer(g_ema_slow_handle, 0, 0, copied, ema_slow) != copied) return false;
   if(CopyBuffer(g_macd_handle, 0, 0, copied, macd_main) != copied) return false;
   if(CopyBuffer(g_macd_handle, 1, 0, copied, macd_signal) != copied) return false;
   return true;
}

void Rebuild(const MqlRates &rates[], const double &atr[], const double &rsi[],
             const double &ema_fast[], const double &ema_slow[],
             const double &macd_main[], const double &macd_signal[])
{
   ResetRuntime();
   int last_closed = ArraySize(rates) - 2;
   int start = MathMax(60, InpSwingLeft + InpSwingRight + 2);
   for(int i = start; i <= last_closed; ++i)
      ProcessBar(rates, atr, rsi, ema_fast, ema_slow, macd_main, macd_signal, i);
}

color StateColor(const IH_SETUP &setup)
{
   if(setup.state == IH_TP) return InpTargetColor;
   if(setup.state == IH_SL) return InpStopColor;
   if(setup.state == IH_AMBIGUOUS) return clrOrange;
   if(setup.state == IH_EXPIRED || setup.state == IH_INVALIDATED) return clrDimGray;
   if(setup.state == IH_ACTIVE) return clrDodgerBlue;
   return (setup.direction > 0 ? InpBullishColor : InpBearishColor);
}

bool IsCompletedState(const IH_SETUP_STATE state)
{
   return (state == IH_TP || state == IH_SL || state == IH_EXPIRED ||
           state == IH_INVALIDATED || state == IH_AMBIGUOUS);
}

int DisplayedScore(const IH_SETUP &setup, const int current_index)
{
   if(IsCompletedState(setup.state))
      return setup.score;
   return EffectiveScore(setup, current_index);
}

void CreateSegment(const string name, const datetime time1, const datetime time2,
                   const double price, const color line_color,
                   const ENUM_LINE_STYLE style, const int width)
{
   if(!ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price))
      return;
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void RenderSetup(const IH_SETUP &setup, const int ordinal, const int current_index,
                 const datetime last_time)
{
   string base = g_prefix + IntegerToString(ordinal) + "_";
   datetime end_time = setup.updated_time;
   if(setup.state == IH_ARMED || setup.state == IH_DETECTED)
      end_time = last_time + (datetime)(PeriodSeconds(PERIOD_M5) * InpPendingExpiryBars);
   else if(setup.state == IH_ACTIVE)
      end_time = last_time + (datetime)(PeriodSeconds(PERIOD_M5) * InpActiveExpiryBars);
   if(end_time <= setup.created_time)
      end_time = setup.created_time + (datetime)PeriodSeconds(PERIOD_M5);

   color setup_color = StateColor(setup);
   string rectangle = base + "ZONE";
   if(ObjectCreate(0, rectangle, OBJ_RECTANGLE, 0, setup.created_time, setup.zone_high,
                   end_time, setup.zone_low))
   {
      ObjectSetInteger(0, rectangle, OBJPROP_COLOR, setup_color);
      ObjectSetInteger(0, rectangle, OBJPROP_FILL, true);
      ObjectSetInteger(0, rectangle, OBJPROP_BACK, true);
      ObjectSetInteger(0, rectangle, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, rectangle, OBJPROP_HIDDEN, true);
   }

   CreateSegment(base + "ENTRY", setup.created_time, end_time, setup.entry,
                 setup_color, STYLE_SOLID, 2);
   CreateSegment(base + "SL", setup.created_time, end_time, setup.stop,
                 InpStopColor, STYLE_DASH, 1);
   CreateSegment(base + "TP1", setup.created_time, end_time, setup.tp1,
                 InpTargetColor, STYLE_DOT, 1);
   CreateSegment(base + "TP2", setup.created_time, end_time, setup.tp2,
                 InpTargetColor, STYLE_DASH, 1);

   string label = base + "LABEL";
   if(ObjectCreate(0, label, OBJ_TEXT, 0, setup.created_time, setup.zone_high))
   {
      string text = StringFormat("%s %s | %s | %d",
                                 DirectionText(setup.direction),
                                 EntryTypeText(setup.entry_type),
                                 StateText(setup.state),
                                 DisplayedScore(setup, current_index));
      ObjectSetString(0, label, OBJPROP_TEXT, text);
      ObjectSetInteger(0, label, OBJPROP_COLOR, setup_color);
      ObjectSetInteger(0, label, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, label, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, label, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, label, OBJPROP_HIDDEN, true);
   }
}

int LatestRelevantSetup()
{
   for(int i = ArraySize(g_setups) - 1; i >= 0; --i)
      if(g_setups[i].state == IH_ACTIVE || g_setups[i].state == IH_ARMED)
         return i;
   return -1;
}

void SplitDashboardText(const string text, const int maximum_characters,
                        string &first_line, string &second_line)
{
   first_line = text;
   second_line = "";
   int length = StringLen(text);
   if(length <= maximum_characters)
      return;

   int split_at = maximum_characters;
   while(split_at > maximum_characters / 2 && StringSubstr(text, split_at, 1) != " ")
      --split_at;
   if(split_at <= maximum_characters / 2)
      split_at = maximum_characters;

   first_line = StringSubstr(text, 0, split_at);
   int second_start = split_at;
   if(StringSubstr(text, split_at, 1) == " ")
      ++second_start;
   second_line = StringSubstr(text, second_start);
   if(StringLen(second_line) > maximum_characters)
      second_line = StringSubstr(second_line, 0, maximum_characters - 3) + "...";
}

void AddDashboardLine(const int row, const string text, const color text_color,
                      const int font_size)
{
   string name = g_prefix + "DASH_" + IntegerToString(row);
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 22);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 30 + row * 17);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void AddHistoryDashboardLine(const int row, const int setup_index,
                             const string text, const color text_color)
{
   string name = g_prefix + "HISTORY_" + IntegerToString(setup_index);
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 22);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 30 + row * 17);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "Click to locate this setup on the chart");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 10);
}

void RenderDashboard(const int current_index)
{
   string panel = g_prefix + "PANEL";
   int latest = LatestRelevantSetup();
   int row = 0;

   if(ObjectCreate(0, panel, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, panel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, panel, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, panel, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, panel, OBJPROP_XSIZE, 430);
      ObjectSetInteger(0, panel, OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(0, panel, OBJPROP_BORDER_COLOR, clrSlateGray);
      ObjectSetInteger(0, panel, OBJPROP_BACK, false);
      ObjectSetInteger(0, panel, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, panel, OBJPROP_HIDDEN, true);
   }

   AddDashboardLine(row++, g_product_short + " V2.0 RC2", clrDeepSkyBlue, 10);
   AddDashboardLine(row++, _Symbol + " M5 | CLOSED BAR | NON-REPAINT", clrWhite, 8);
   AddDashboardLine(row++, "Profile: RETAIL 2 SIGNALS/DAY", clrGold, 8);
   AddDashboardLine(row++, "Regime: " + g_regime + " | Bias: " + BiasText(),
                    InpNeutralColor, 8);
   AddDashboardLine(row++,
                    StringFormat("Scan: SW %d | BR %d | TRY %d | OK %d | C %d | M %d",
                                 g_detected_sweeps, g_structure_breaks,
                                 g_setup_attempts, g_setups_created,
                                 g_continuation_setups,
                                 g_momentum_break_setups),
                    InpNeutralColor, 8);
   AddDashboardLine(row++,
                    StringFormat("Daily: %d/%d | Retail fallback: %d",
                                 g_daily_signal_count, InpMinimumDailySignals,
                                 g_retail_fallback_setups),
                    InpNeutralColor, 8);
   AddDashboardLine(row++,
                    StringFormat("Paths: SWP %d | CONT %d | MOM %d | NONE %d",
                                 g_sweep_path_attempts,
                                 g_continuation_path_attempts,
                                 g_momentum_break_attempts,
                                 g_reject_no_path),
                    InpNeutralColor, 8);
   AddDashboardLine(row++,
                    StringFormat("Reject: DISP %d | ZONE %d | R/T %d | OTHER %d",
                                 g_reject_displacement, g_reject_zone,
                                 g_reject_risk_target, g_reject_other),
                    InpNeutralColor, 8);
   AddDashboardLine(row++,
                    StringFormat("R/T: RISK %d | SPR %d | LIQ %d | TP %d",
                                 g_reject_risk, g_reject_spread,
                                 g_reject_liquidity, g_reject_final_target),
                    InpNeutralColor, 8);

   string status_first;
   string status_second;
   SplitDashboardText("Status: " + g_last_reason, 52, status_first, status_second);
   AddDashboardLine(row++, status_first, clrWhite, 8);
   if(status_second != "")
      AddDashboardLine(row++, "        " + status_second, clrWhite, 8);

   if(latest >= 0)
   {
      IH_SETUP setup = g_setups[latest];
      color setup_color = StateColor(setup);
      AddDashboardLine(row++,
                       StringFormat("Setup: %s %s | %s | Score %d",
                                    DirectionText(setup.direction),
                                    EntryTypeText(setup.entry_type),
                                    StateText(setup.state),
                                    DisplayedScore(setup, current_index)),
                       setup_color, 8);
      AddDashboardLine(row++, "Entry: " + PriceText(setup.entry) +
                              " | SL: " + PriceText(setup.stop), clrWhite, 8);
      AddDashboardLine(row++, "TP1: " + PriceText(setup.tp1) +
                              " | TP2: " + PriceText(setup.tp2), clrWhite, 8);
      bool retail_setup = StringFind(setup.note, "RETAIL DAILY SLOT") == 0;
      if(retail_setup)
         AddDashboardLine(row++,
                          StringFormat("Retail score: %d | Scheduled fallback",
                                       setup.score),
                          InpNeutralColor, 8);
      else
         AddDashboardLine(row++,
                          StringFormat("Score: 70 + OB %d + MOM %d + ENV %d",
                                       setup.ob_points,
                                       setup.momentum_aligned ? 10 : 0,
                                       setup.environment_aligned ? 10 : 0),
                          InpNeutralColor, 8);

      string note_first;
      string note_second;
      SplitDashboardText("Note: " + setup.note, 52, note_first, note_second);
      AddDashboardLine(row++, note_first, InpNeutralColor, 8);
      if(note_second != "")
         AddDashboardLine(row++, "      " + note_second, InpNeutralColor, 8);
   }
   else
   {
      string empty_text = (ArraySize(g_setups) == 0
                           ? "Setup: NONE VALIDATED IN SCANNED HISTORY"
                           : "Setup: NONE CURRENTLY ARMED OR ACTIVE");
      AddDashboardLine(row++, empty_text, clrGold, 8);
   }

   if(InpShowRecentSetupHistory)
   {
      int requested = MathMin(5, MathMax(1, InpRecentSetupCount));
      int shown = 0;
      AddDashboardLine(row++, "RECENT SETUPS - CLICK TO LOCATE (LAST " +
                       IntegerToString(requested) + ")",
                       clrDeepSkyBlue, 8);
      for(int i = ArraySize(g_setups) - 1; i >= 0 && shown < requested; --i)
      {
         if(!IsCompletedState(g_setups[i].state))
            continue;
         IH_SETUP historical = g_setups[i];
         string history_text = StringFormat("%d. %s | %s %s | %s | %d",
                                            shown + 1,
                                            ShortHistoryTime(historical.created_time),
                                            DirectionText(historical.direction),
                                            ShortEntryTypeText(historical.entry_type),
                                            ShortStateText(historical.state),
                                            DisplayedScore(historical, current_index));
         AddHistoryDashboardLine(row++, i, history_text, StateColor(historical));
         ++shown;
      }
      if(shown == 0)
         AddDashboardLine(row++, "No completed setup in the scanned history.",
                          InpNeutralColor, 8);
   }

   ObjectSetInteger(0, panel, OBJPROP_YSIZE, 22 + row * 17);
}

void RenderAll(const MqlRates &rates[])
{
   ObjectsDeleteAll(0, g_prefix);
   int total = ArraySize(g_setups);
   int first = (InpShowHistoricalSetups ? MathMax(0, total - InpMaximumDisplayedSetups)
                                        : MathMax(0, total - 1));
   int current_index = ArraySize(rates) - 2;
   datetime last_time = rates[current_index].time;
   int ordinal = 0;
   for(int i = first; i < total; ++i)
      RenderSetup(g_setups[i], ordinal++, current_index, last_time);
   RenderDashboard(current_index);
   ChartRedraw();
}

void CaptureSnapshots(IH_SNAPSHOT &snapshots[])
{
   int total = ArraySize(g_setups);
   ArrayResize(snapshots, total);
   for(int i = 0; i < total; ++i)
   {
      snapshots[i].id = g_setups[i].id;
      snapshots[i].state = g_setups[i].state;
      snapshots[i].tp1_hit = g_setups[i].tp1_hit;
   }
}

int FindSnapshot(const IH_SNAPSHOT &snapshots[], const string id)
{
   for(int i = 0; i < ArraySize(snapshots); ++i)
      if(snapshots[i].id == id)
         return i;
   return -1;
}

void NotifyUser(const string message)
{
   string full = "IHSMC | " + _Symbol + " M5 | " + message;
   if(InpTerminalAlerts) Alert(full);
   if(InpPushAlerts) SendNotification(full);
   if(InpEmailAlerts) SendMail("IHSMC Alert", full);
}

void WriteAudit(const IH_SETUP &setup, const string event_name)
{
   if(!InpWriteAuditCSV)
      return;
   string filename = "IHSMC_Audit_" + _Symbol + "_M5.csv";
   int handle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI |
                         FILE_COMMON | FILE_SHARE_READ, ',');
   if(handle == INVALID_HANDLE)
      return;
   if(FileSize(handle) == 0)
      FileWrite(handle, "setup_id", "event", "event_time", "direction", "entry_type",
                "entry", "stop", "tp1", "tp2", "score", "regime", "note");
   FileSeek(handle, 0, SEEK_END);
   FileWrite(handle, setup.id, event_name,
             TimeToString(setup.updated_time, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
             DirectionText(setup.direction), EntryTypeText(setup.entry_type),
             PriceText(setup.entry), PriceText(setup.stop), PriceText(setup.tp1),
             PriceText(setup.tp2), setup.score, setup.regime, setup.note);
   FileClose(handle);
}

void EmitTransitions(const IH_SNAPSHOT &snapshots[], const datetime newest_closed)
{
   for(int i = 0; i < ArraySize(g_setups); ++i)
   {
      int old = FindSnapshot(snapshots, g_setups[i].id);
      if(old < 0)
      {
         if(g_setups[i].created_time == newest_closed)
         {
            string event_name = StateText(g_setups[i].state);
            NotifyUser(g_setups[i].id + " | " + event_name);
            WriteAudit(g_setups[i], event_name);
         }
         continue;
      }
      if(snapshots[old].state != g_setups[i].state)
      {
         string event_name = StateText(g_setups[i].state);
         NotifyUser(g_setups[i].id + " | " + event_name);
         WriteAudit(g_setups[i], event_name);
      }
      else if(!snapshots[old].tp1_hit && g_setups[i].tp1_hit)
      {
         NotifyUser(g_setups[i].id + " | TP1");
         WriteAudit(g_setups[i], "TP1");
      }
   }
}

int OnInit()
{
   if(_Period != PERIOD_M5)
      Print("IHSMC V2.0 RC2 uses internal M5 data. M5 is recommended for the intended chart display.");
   g_atr_handle = iATR(_Symbol, PERIOD_M5, InpATRPeriod);
   g_rsi_handle = iRSI(_Symbol, PERIOD_M5, InpRSIPeriod, PRICE_CLOSE);
   g_ema_fast_handle = iMA(_Symbol, PERIOD_M5, InpEMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_handle = iMA(_Symbol, PERIOD_M5, InpEMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_macd_handle = iMACD(_Symbol, PERIOD_M5, InpMACDFast, InpMACDSlow,
                         InpMACDSignal, PRICE_CLOSE);
   if(g_atr_handle == INVALID_HANDLE || g_rsi_handle == INVALID_HANDLE ||
      g_ema_fast_handle == INVALID_HANDLE || g_ema_slow_handle == INVALID_HANDLE ||
      g_macd_handle == INVALID_HANDLE)
      return INIT_FAILED;

   IndicatorSetString(INDICATOR_SHORTNAME, "IHSMC V2.0 RC2 [M5 engine]");
   ResetRuntime();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
   if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   if(g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
   if(g_ema_fast_handle != INVALID_HANDLE) IndicatorRelease(g_ema_fast_handle);
   if(g_ema_slow_handle != INVALID_HANDLE) IndicatorRelease(g_ema_slow_handle);
   if(g_macd_handle != INVALID_HANDLE) IndicatorRelease(g_macd_handle);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
{
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   string history_prefix = g_prefix + "HISTORY_";
   if(StringFind(sparam, history_prefix) != 0)
      return;

   int setup_index = (int)StringToInteger(StringSubstr(sparam,
                                      StringLen(history_prefix)));
   if(setup_index < 0 || setup_index >= ArraySize(g_setups))
      return;

   int bar_shift = iBarShift(_Symbol, PERIOD_M5,
                             g_setups[setup_index].created_time, false);
   if(bar_shift < 0)
      return;

   long visible_bars = ChartGetInteger(0, CHART_VISIBLE_BARS, 0);
   int centered_shift = MathMax(0, bar_shift - (int)(visible_bars / 2));
   ChartSetInteger(0, CHART_AUTOSCROLL, false);
   ChartNavigate(0, CHART_END, -centered_shift);

   string focus = g_prefix + "FOCUS_SIGNAL";
   ObjectDelete(0, focus);
   if(ObjectCreate(0, focus, OBJ_VLINE, 0,
                   g_setups[setup_index].created_time, 0.0))
   {
      ObjectSetInteger(0, focus, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, focus, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, focus, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, focus, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, focus, OBJPROP_HIDDEN, true);
      ObjectSetString(0, focus, OBJPROP_TOOLTIP,
                      "Selected setup: " + g_setups[setup_index].id);
   }
   ChartRedraw();
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   MqlRates rates[];
   double atr[], rsi[], ema_fast[], ema_slow[], macd_main[], macd_signal[];
   if(!LoadSeries(rates, atr, rsi, ema_fast, ema_slow, macd_main, macd_signal))
      return prev_calculated;

   int last_closed = ArraySize(rates) - 2;
   if(last_closed < 60)
      return prev_calculated;
   datetime newest_closed = rates[last_closed].time;
   if(g_initialized && newest_closed == g_last_closed_bar)
      return rates_total;

   IH_SNAPSHOT snapshots[];
   if(g_initialized)
      CaptureSnapshots(snapshots);
   Rebuild(rates, atr, rsi, ema_fast, ema_slow, macd_main, macd_signal);
   RenderAll(rates);
   if(g_initialized)
      EmitTransitions(snapshots, newest_closed);
   g_last_closed_bar = newest_closed;
   g_initialized = true;
   return rates_total;
}
