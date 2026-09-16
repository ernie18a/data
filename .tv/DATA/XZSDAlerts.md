<!-- tradingview-pine-id: PUB;54a6853574294794a051c8cbd81a7417 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_SD_Alerts

Source: https://www.tradingview.com/script/9MCdylu0-XZ-SD-Alerts/

## Description

Library  "XZ_SD_Alerts"
XZ S&D Alerts v1. Notification-only support library for already-committed XZ Supply & Demand engine events. It owns alert filtering, Horizon admission, message formatting, aggregation and alert() dispatch. It never creates or reinterprets S&D lifecycle events.

route(base_message, event, enabled, source_scope, zone_scope, supply_events, demand_events, zone_confirmed, wick_test, partial_consumption, swing_promoted, zone_consumed, zone_horizon, horizon_timezone, reference_time, ticker)
  Appends one already-committed engine event to an aggregated alert message when all notification filters admit it.
  Parameters:
    base_message (string)
    event (AlertEvent)
    enabled (bool)
    source_scope (string)
    zone_scope (string)
    supply_events (bool)
    demand_events (bool)
    zone_confirmed (bool)
    wick_test (bool)
    partial_consumption (bool)
    swing_promoted (bool)
    zone_consumed (bool)
    zone_horizon (string)
    horizon_timezone (string)
    reference_time (int)
    ticker (string)

dispatch(message)
  Dispatches one aggregated message. Empty messages do nothing.
  Parameters:
    message (string)

AlertEvent
  Fields:
    event_type (series string)
    side (series string)
    source_context (series string)
    source_timeframe (series string)
    confirmation_time (series int)
    outer_boundary (series float)
    original_inner_boundary (series float)
    event_price (series float)
    penetration_pct (series float)
    event_sequence (series int)
    pivot_class (series string)
    swing_family (series string)
    lifecycle_state (series string)
    pathway (series string)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ S&D Alerts v2. Notification-only support library for committed XZ Supply & Demand engine events. v2 adds Zone Identity and self-describing event fields to aggregated messages while preserving filtering, Horizon admission and once-per-bar-close dispatch.
library("XZ_SD_Alerts", false)

//==============================================================================
// OWNERSHIP CONTRACT
//==============================================================================
// OWNED HERE
// - Source / side / event-family notification filters.
// - Current Zone Horizon notification admission.
// - Event title/range/percentage/timeframe formatting.
// - Aggregated alert message construction.
// - alert() dispatch using once-per-bar-close.
//
// NOT OWNED HERE
// - Supply/Demand formation.
// - Pivot / Trend / MSB / Swing authority.
// - Testing / Breach Pending.
// - Wick Test / Partial / Swing Promotion / Consumption decisions.
// - Research storage.
// - Session Context.
//==============================================================================

export type AlertEvent
    string event_type
    int zone_id
    string side
    string source_context
    string source_timeframe
    int confirmation_event_time
    float outer_boundary
    float original_inner_boundary
    float event_price
    float penetration_pct
    int event_sequence
    string pivot_class
    string swing_family
    string lifecycle_state
    string pathway

_horizon_start(int reference_time, string horizon, string timezone_name) =>
    int result = na

    if horizon != "All History"
        int local_year = year(reference_time, timezone_name)
        int local_month = month(reference_time, timezone_name)
        int local_day = dayofmonth(reference_time, timezone_name)

        if horizon == "Daily Boundary Onwards"
            result := timestamp(timezone_name, local_year, local_month, local_day, 0, 0, 0)
        else if horizon == "Weekly Boundary Onwards"
            int local_dow = dayofweek(reference_time, timezone_name)
            int days_since_monday = local_dow == dayofweek.sunday ? 6 : local_dow - dayofweek.monday
            result := timestamp(timezone_name, local_year, local_month, local_day - days_since_monday, 0, 0, 0)
        else if horizon == "Monthly Boundary Onwards"
            result := timestamp(timezone_name, local_year, local_month, 1, 0, 0, 0)
        else if horizon == "Yearly Boundary Onwards"
            result := timestamp(timezone_name, local_year, 1, 1, 0, 0, 0)

    result

_source_allowed(AlertEvent event, string source_scope) =>
    source_scope == "Primary + Secondary" or event.source_context == source_scope

_direction_allowed(AlertEvent event, bool supply_events, bool demand_events) =>
    event.side == "Supply" ? supply_events : demand_events

_family_allowed(
     AlertEvent event,
     bool zone_confirmed,
     bool wick_test,
     bool partial_consumption,
     bool swing_promoted,
     bool zone_consumed
 ) =>
    switch event.event_type
        "ZONE_CREATED" => zone_confirmed
        "WICK_TEST" => wick_test
        "PARTIAL_CONSUMPTION" => partial_consumption
        "SWING_PROMOTED" => swing_promoted
        "ZONE_CONSUMED" => zone_consumed
        => false

_zone_scope_allowed(
     AlertEvent event,
     string zone_scope,
     string zone_horizon,
     string horizon_timezone,
     int reference_time
 ) =>
    bool result = zone_scope == "All Engine Zones"

    if not result
        if zone_horizon == "All History"
            result := true
        else
            int cutoff = _horizon_start(reference_time, zone_horizon, horizon_timezone)
            result := not na(cutoff) and not na(event.confirmation_event_time) and event.confirmation_event_time >= cutoff

    result

_event_title(AlertEvent event) =>
    switch event.event_type
        "ZONE_CREATED" => "Zone Confirmed"
        "WICK_TEST" => "Wick Test"
        "PARTIAL_CONSUMPTION" => "Partial Consumption"
        "SWING_PROMOTED" => "Swing Authority Gained"
        "ZONE_CONSUMED" => "Zone Consumed"
        => event.event_type

_tf_label(string tf) =>
    string result = tf
    float numeric_minutes = str.tonumber(tf)

    if not na(numeric_minutes)
        int total_minutes = int(numeric_minutes)
        result := total_minutes > 0 and total_minutes % 60 == 0 ? str.tostring(int(total_minutes / 60)) + "H" : str.tostring(total_minutes) + "m"
    else
        result := tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

    result

_range(AlertEvent event) =>
    float lower = math.min(event.outer_boundary, event.original_inner_boundary)
    float upper = math.max(event.outer_boundary, event.original_inner_boundary)
    str.tostring(lower, format.mintick) + " - " + str.tostring(upper, format.mintick)

_percent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.0") + "%"

_format(AlertEvent event, string ticker) =>
    string tf_label = _tf_label(event.source_timeframe)
    string header = "XZ S&D · " + ticker + " · " + event.source_context + " " + tf_label + " · " + event.side + " · " + _event_title(event)
    string detail = "Zone #" + str.tostring(event.zone_id) + " · " + _range(event)

    if event.event_type == "ZONE_CREATED"
        detail += " · Pivot " + event.pivot_class

    else if event.event_type == "WICK_TEST"
        detail += " · Test #" + str.tostring(event.event_sequence)
        detail += " · Wick Depth " + _percent(event.penetration_pct)

    else if event.event_type == "PARTIAL_CONSUMPTION"
        detail += " · Partial #" + str.tostring(event.event_sequence)
        detail += " · Accepted " + _percent(event.penetration_pct)
        detail += " · Close " + str.tostring(event.event_price, format.mintick)

    else if event.event_type == "SWING_PROMOTED"
        detail += " · " + event.swing_family + " Swing"
        detail += " · State " + event.lifecycle_state
        if event.lifecycle_state == "Partially Consumed" and not na(event.penetration_pct) and event.penetration_pct > 0.0
            detail += " " + _percent(event.penetration_pct)

    else if event.event_type == "ZONE_CONSUMED"
        detail += " · Pathway " + event.pathway
        if str.length(event.swing_family) > 0
            detail += " · " + event.swing_family + " Swing"
        detail += " · Close " + str.tostring(event.event_price, format.mintick)

    header + "\n" + detail

//@function Appends one already-committed engine event to an aggregated alert message when all notification filters admit it.
export route(
     string base_message,
     AlertEvent event,
     bool enabled,
     string source_scope,
     string zone_scope,
     bool supply_events,
     bool demand_events,
     bool zone_confirmed,
     bool wick_test,
     bool partial_consumption,
     bool swing_promoted,
     bool zone_consumed,
     string zone_horizon,
     string horizon_timezone,
     int reference_time,
     string ticker
 ) =>
    string result = base_message

    if enabled
        bool allowed =
             _source_allowed(event, source_scope) and
             _direction_allowed(event, supply_events, demand_events) and
             _family_allowed(event, zone_confirmed, wick_test, partial_consumption, swing_promoted, zone_consumed) and
             _zone_scope_allowed(event, zone_scope, zone_horizon, horizon_timezone, reference_time)

        if allowed
            string block = _format(event, ticker)
            result := str.length(result) == 0 ? block : result + "\n\n" + block

    result

//@function Dispatches one aggregated message. Empty messages do nothing.
export dispatch(string message) =>
    if str.length(message) > 0
        alert(message, alert.freq_once_per_bar_close)
    true
````
