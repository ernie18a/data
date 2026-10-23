// RiskCalc.mqh
// Account-level calculation helpers for Daily Risk Monitor Lite.
// This module contains:
// - daily range detection,
// - realized P/L calculation from history deals,
// - floating P/L calculation from open positions,
// - drawdown and risk-status evaluation.

#ifndef __DAILY_RISK_MONITOR_LITE_RISKCALC_MQH__
#define __DAILY_RISK_MONITOR_LITE_RISKCALC_MQH__

// Three-state output used by the panel to display the current risk condition.
enum DRMLRiskStatus
  {
   DRML_STATUS_SAFE = 0,    // Normal state below the warning threshold.
   DRML_STATUS_WARNING = 1, // Risk usage has reached the warning threshold.
   DRML_STATUS_DANGER = 2   // Risk usage has reached the danger threshold.
  };

// Calculation inputs collected from indicator parameters.
struct DRMLCalcConfig
  {
   double daily_loss_limit_money; // Daily loss limit in account currency.
   bool   include_commission;     // Include commission in Daily Realized.
   bool   include_swap;           // Include swap in Daily Realized and Floating.
   bool   use_broker_day;         // Use broker/server day 00:00 as reset point.
   int    manual_day_start_hour;  // Manual reset hour when broker day mode is off.
  };

// Current daily statistics window.
struct DRMLDayRange
  {
   datetime start_time;
   datetime end_time;
  };

// Full calculated snapshot that the panel renders on each refresh.
struct DRMLRiskSnapshot
  {
   double         daily_realized;  // Closed-result total inside the current daily range.
   double         floating_pl;     // Current open-position floating result.
   double         daily_total;     // Daily Realized + Floating.
   double         drawdown_pct;    // Current drawdown based on balance and equity.
   double         risk_usage_pct;  // Loss usage against daily loss limit.
   bool           has_drawdown;    // False when balance is invalid and drawdown is N/A.
   bool           has_risk_limit;  // False when daily loss limit is invalid or disabled.
   DRMLRiskStatus status;          // SAFE / WARNING / DANGER.
   string         status_text;     // Human-readable status text for the panel.
   datetime       day_start;       // Calculated start of the active daily range.
   datetime       day_end;         // Calculated end of the active daily range.
  };

// Resets the snapshot so every refresh starts from a clean baseline.
void DRMLResetSnapshot(DRMLRiskSnapshot &snapshot)
  {
   snapshot.daily_realized = 0.0;
   snapshot.floating_pl = 0.0;
   snapshot.daily_total = 0.0;
   snapshot.drawdown_pct = 0.0;
   snapshot.risk_usage_pct = 0.0;
   snapshot.has_drawdown = false;
   snapshot.has_risk_limit = false;
   snapshot.status = DRML_STATUS_SAFE;
   snapshot.status_text = "SAFE";
   snapshot.day_start = 0;
   snapshot.day_end = 0;
  }

// Returns the best available server-side reference time.
// Preference order:
// 1) trade server time,
// 2) terminal current time,
// 3) local machine time.
datetime DRMLGetReferenceTime()
  {
   datetime now = TimeTradeServer();
   if(now <= 0)
      now = TimeCurrent();
   if(now <= 0)
      now = TimeLocal();

   return now;
  }

// Keeps the manual day-start hour inside the supported 0..23 range.
int DRMLNormalizeManualDayStartHour(const int hour)
  {
   if(hour < 0)
      return 0;
   if(hour > 23)
      return 23;

   return hour;
  }

// Builds a day anchor timestamp from a base time and a target hour.
// Minutes and seconds are forced to 00:00.
bool DRMLBuildDayAnchor(const datetime base_time,const int hour,datetime &day_anchor)
  {
   MqlDateTime parts;
   if(!TimeToStruct(base_time,parts))
      return false;

   parts.hour = hour;
   parts.min = 0;
   parts.sec = 0;
   day_anchor = StructToTime(parts);

   return (day_anchor > 0);
  }

// Uses broker/server midnight as the active daily range.
bool DRMLGetBrokerDayRange(DRMLDayRange &range)
  {
   datetime now = DRMLGetReferenceTime();
   datetime day_start = 0;
   if(now <= 0 || !DRMLBuildDayAnchor(now,0,day_start))
      return false;

   range.start_time = day_start;
   range.end_time = day_start + 86400;
   return true;
  }

// Uses a manual server-time reset hour as the active daily range.
// If the current time is before the requested reset hour, the start point is
// moved back by one calendar day.
bool DRMLGetManualDayRange(const int requested_hour,DRMLDayRange &range)
  {
   datetime now = DRMLGetReferenceTime();
   datetime day_start = 0;
   const int start_hour = DRMLNormalizeManualDayStartHour(requested_hour);
   if(now <= 0 || !DRMLBuildDayAnchor(now,start_hour,day_start))
      return false;

   // Manual day start still follows the broker/server clock. The difference
   // from broker day is only the rollover hour, not the timezone source.
   if(now < day_start)
      day_start -= 86400;

   range.start_time = day_start;
   range.end_time = day_start + 86400;
   return true;
  }

// Public helper that decides which daily range rule should be used.
bool DRMLGetTodayRange(const DRMLCalcConfig &config,DRMLDayRange &range)
  {
   if(config.use_broker_day)
      return DRMLGetBrokerDayRange(range);

   return DRMLGetManualDayRange(config.manual_day_start_hour,range);
  }

// Only exit-side deals contribute to Daily Realized.
bool DRMLIsExitDeal(const long entry_type)
  {
   return (entry_type == DEAL_ENTRY_OUT || entry_type == DEAL_ENTRY_OUT_BY);
  }

// Sums closed-deal result inside the active daily range.
// Base value is DEAL_PROFIT.
// Optional additions:
// - DEAL_COMMISSION when commission inclusion is enabled
// - DEAL_SWAP when swap inclusion is enabled
double DRMLCalculateDailyRealized(const DRMLDayRange &range,
                                  const bool include_commission,
                                  const bool include_swap)
  {
   double realized = 0.0;
   datetime history_end = DRMLGetReferenceTime();
   if(history_end <= 0 || history_end > range.end_time)
      history_end = range.end_time;

   if(history_end < range.start_time)
      history_end = range.start_time;

   if(!HistorySelect(range.start_time,history_end))
      return 0.0;

   const int deals_total = HistoryDealsTotal();
   for(int i = 0; i < deals_total; ++i)
     {
      const ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;

      // The Lite version only counts exit deals inside today's window so the
      // result stays easy to explain against terminal history records.
      const datetime deal_time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(deal_time < range.start_time || deal_time >= range.end_time)
         continue;

      const long entry_type = HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(!DRMLIsExitDeal(entry_type))
         continue;

      realized += HistoryDealGetDouble(ticket,DEAL_PROFIT);

      if(include_commission)
         realized += HistoryDealGetDouble(ticket,DEAL_COMMISSION);

      if(include_swap)
         realized += HistoryDealGetDouble(ticket,DEAL_SWAP);
     }

   return realized;
  }

// Sums current floating result for every open position in the account.
// Base value is POSITION_PROFIT.
// Optional addition:
// - POSITION_SWAP when swap inclusion is enabled
//
// Commission is not added here because open-position commission is not exposed
// the same way as closed-deal commission in the MT5 history model.
double DRMLCalculateFloating(const bool include_swap)
  {
   double floating_total = 0.0;
   const int positions_total = PositionsTotal();

   for(int i = 0; i < positions_total; ++i)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;

      floating_total += PositionGetDouble(POSITION_PROFIT);

      // Open-position commission is not exposed the same way as deal commission,
      // so the Lite version only adds swap when the user enables it.
      if(include_swap)
         floating_total += PositionGetDouble(POSITION_SWAP);
     }

   return floating_total;
  }

// Drawdown is based on current balance and equity.
// Returns N/A through has_drawdown=false when balance is invalid.
// Positive equity-over-balance states are forced to 0%.
double DRMLCalculateDrawdownPct(bool &has_drawdown)
  {
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   if(balance <= 0.0)
     {
      has_drawdown = false;
      return 0.0;
     }

   has_drawdown = true;
   if(equity >= balance)
      return 0.0;

   const double drawdown = (balance - equity) / balance * 100.0;
   return MathMax(drawdown,0.0);
  }

// Risk Usage % is only meaningful when:
// - daily loss limit is valid (> 0)
// - Daily Total is negative
double DRMLCalculateRiskUsagePct(const double daily_total,
                                 const double daily_loss_limit_money,
                                 bool &has_risk_limit)
  {
   has_risk_limit = (daily_loss_limit_money > 0.0);
   if(!has_risk_limit || daily_total >= 0.0)
      return 0.0;

   return MathAbs(daily_total) / daily_loss_limit_money * 100.0;
  }

// Converts enum status to panel-friendly text.
string DRMLRiskStatusLabel(const DRMLRiskStatus status)
  {
   switch(status)
     {
      case DRML_STATUS_WARNING:
         return "WARNING";
      case DRML_STATUS_DANGER:
         return "DANGER";
      default:
         return "SAFE";
     }
  }

// Maps the calculated risk usage into SAFE / WARNING / DANGER.
// Thresholds are fixed for v1:
// - WARNING at 50%
// - DANGER at 80%
DRMLRiskStatus DRMLResolveRiskStatus(const double daily_total,
                                     const double risk_usage_pct,
                                     const bool has_risk_limit)
  {
   if(!has_risk_limit)
      return (daily_total < 0.0 ? DRML_STATUS_WARNING : DRML_STATUS_SAFE);

   // Only negative Daily Total consumes the daily loss limit.
   if(risk_usage_pct >= 80.0)
      return DRML_STATUS_DANGER;

   if(risk_usage_pct >= 50.0)
      return DRML_STATUS_WARNING;

   return DRML_STATUS_SAFE;
  }

// Builds the final status string shown in the panel.
string DRMLBuildStatusText(const DRMLRiskStatus status,
                           const double risk_usage_pct,
                           const bool has_risk_limit)
  {
   const string label = DRMLRiskStatusLabel(status);
   if(!has_risk_limit)
      return label + " (Limit N/A)";

   return StringFormat("%s (%.0f%%)",label,risk_usage_pct);
  }

// Main calculation entry point used by the indicator.
// Produces one self-contained snapshot for the panel.
bool DRMLCalculateSnapshot(const DRMLCalcConfig &config,DRMLRiskSnapshot &snapshot)
  {
   DRMLResetSnapshot(snapshot);

   DRMLDayRange range;
   const bool has_range = DRMLGetTodayRange(config,range);
   if(has_range)
     {
      snapshot.day_start = range.start_time;
      snapshot.day_end = range.end_time;
      snapshot.daily_realized = DRMLCalculateDailyRealized(range,
                                                           config.include_commission,
                                                           config.include_swap);
     }

   snapshot.floating_pl = DRMLCalculateFloating(config.include_swap);
   snapshot.daily_total = snapshot.daily_realized + snapshot.floating_pl;
   snapshot.drawdown_pct = DRMLCalculateDrawdownPct(snapshot.has_drawdown);
   snapshot.risk_usage_pct = DRMLCalculateRiskUsagePct(snapshot.daily_total,
                                                       config.daily_loss_limit_money,
                                                       snapshot.has_risk_limit);
   snapshot.status = DRMLResolveRiskStatus(snapshot.daily_total,
                                           snapshot.risk_usage_pct,
                                           snapshot.has_risk_limit);
   snapshot.status_text = DRMLBuildStatusText(snapshot.status,
                                              snapshot.risk_usage_pct,
                                              snapshot.has_risk_limit);

   return has_range;
  }

#endif
