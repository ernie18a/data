<!-- tradingview-pine-id: PUB;047244bfe4ac49ddb7c350947c968275 -->
<!-- tradingview-pine-version: 6.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_SD_Research_Dashboard

Source: https://www.tradingview.com/script/ybs20Klm-XZ-SD-Research-Dashboard/

## Description

Library  "XZ_SD_Research_Dashboard"
XZ S&D Research Dashboard v1. Memory-bounded observer and presentation backend for already-determined XZ Supply & Demand engine events. v9 turns All Sections into a dual-panel full-width Research dashboard while individual sections remain single-table.

newState(retentionPerBucket)
  Creates one empty persistent S&D Research observer state with bounded retention per side/source bucket.
  Parameters:
    retentionPerBucket (simple int): Maximum newest records retained for each Supply/Demand x Primary/Secondary bucket.
  Returns: Empty memory-bounded ResearchState.

clearState(state)
  Clears all retained Research records and cumulative loaded-zone counts.
  Parameters:
    state (ResearchState)

recordCount(state)
  Number of Research zone records currently retained.
  Parameters:
    state (ResearchState)

observeEvent(state, event)
  Observes one already-decided protected-engine event. It never derives or re-decides S&D authority.
  Parameters:
    state (ResearchState)
    event (ResearchEvent)

snapshot(state, sourceFilter, nowTime, sampleLimit, statistic, includeChronology, includePathways)
  Builds one bounded snapshot. Baseline metrics always calculate. Event Chronology calculates only when includeChronology is true, using one metric-at-a-time scratch buffers to minimize peak runtime memory.
  Parameters:
    state (ResearchState)
    sourceFilter (simple string)
    nowTime (int)
    sampleLimit (simple int)
    statistic (simple string)
    includeChronology (bool)
    includePathways (bool)

renderLab(state, showLab, source, section, statistic, tablePosition, textSizeName, bgColor, textColor, accentColor, showLines, lineColor, supplyColor, demandColor, primaryTimeframe, secondaryTimeframe, secondaryEnabled, secondaryConfigured, secondaryIsHigher, nowTime, sampleLimit, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone)
  Renders or removes the complete XZ S&D Research Lab using already-observed bounded ResearchState facts. Presentation only; this function cannot decide S&D lifecycle or structure.
  Parameters:
    state (ResearchState)
    showLab (bool)
    source (simple string)
    section (simple string)
    statistic (simple string)
    tablePosition (simple string)
    textSizeName (simple string)
    bgColor (color)
    textColor (color)
    accentColor (color)
    showLines (bool)
    lineColor (color)
    supplyColor (color)
    demandColor (color)
    primaryTimeframe (simple string)
    secondaryTimeframe (simple string)
    secondaryEnabled (bool)
    secondaryConfigured (bool)
    secondaryIsHigher (bool)
    nowTime (int)
    sampleLimit (simple int)
    sessionStandard (simple string)
    sessionShowSydney (simple bool)
    sessionShowTokyo (simple bool)
    sessionShowLondon (simple bool)
    sessionShowNewYork (simple bool)
    sessionCustomOpen (simple string)
    sessionCustomClose (simple string)
    sessionCustomTimezone (simple string)
    sessionCustomWeekdaysOnly (simple bool)
    symbolTimezone (simple string)

renderAdaptiveLab(state, showLab, source, section, statistic, tablePosition, textSizeName, bgColor, textColor, accentColor, showLines, lineColor, supplyColor, demandColor, primaryTimeframe, secondaryTimeframe, secondaryEnabled, secondaryConfigured, secondaryIsHigher, nowTime, sampleLimit, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone)
  Keeps individual Research sections as one table, but automatically turns All Sections into two coordinated bottom-corner dashboard panels.
  Parameters:
    state (ResearchState)
    showLab (bool)
    source (simple string)
    section (simple string)
    statistic (simple string)
    tablePosition (simple string)
    textSizeName (simple string)
    bgColor (color)
    textColor (color)
    accentColor (color)
    showLines (bool)
    lineColor (color)
    supplyColor (color)
    demandColor (color)
    primaryTimeframe (simple string)
    secondaryTimeframe (simple string)
    secondaryEnabled (bool)
    secondaryConfigured (bool)
    secondaryIsHigher (bool)
    nowTime (int)
    sampleLimit (simple int)
    sessionStandard (simple string)
    sessionShowSydney (simple bool)
    sessionShowTokyo (simple bool)
    sessionShowLondon (simple bool)
    sessionShowNewYork (simple bool)
    sessionCustomOpen (simple string)
    sessionCustomClose (simple string)
    sessionCustomTimezone (simple string)
    sessionCustomWeekdaysOnly (simple bool)
    symbolTimezone (simple string)

ResearchEvent
  One canonical already-decided S&D event transported from the protected engine.
  Fields:
    event_type (series string)
    zone_id (series int)
    side (series string)
    source_context (series string)
    source_timeframe (series string)
    birth_time (series int)
    confirmation_time (series int)
    event_draw_time (series int)
    event_time (series int)
    source_bar (series int)
    origin_event_time (series int)
    confirmation_event_time (series int)
    origin_source_bar (series int)
    confirmation_source_bar (series int)
    outer_boundary (series float)
    original_inner_boundary (series float)
    previous_inner_boundary (series float)
    current_inner_boundary (series float)
    event_price (series float)
    penetration_pct (series float)
    event_sequence (series int)
    pivot_class (series string)
    swing_family (series string)
    lifecycle_state (series string)
    pathway (series string)

ZoneRecord
  Factual Research record for one engine-owned zone. Exported because it is stored inside ResearchState.
  Fields:
    zone_id (series int)
    side (series string)
    source_context (series string)
    source_timeframe (series string)
    birth_time (series int)
    confirmation_time (series int)
    origin_event_time (series int)
    confirmation_event_time (series int)
    origin_source_bar (series int)
    confirmation_source_bar (series int)
    outer_boundary (series float)
    original_inner_boundary (series float)
    current_inner_boundary (series float)
    pivot_class (series string)
    wick_test_count (series int)
    max_wick_pct (series float)
    first_wick_time (series int)
    first_wick_source_bar (series int)
    last_wick_time (series int)
    last_wick_source_bar (series int)
    partial_count (series int)
    max_partial_pct (series float)
    first_partial_time (series int)
    first_partial_source_bar (series int)
    deepest_partial_time (series int)
    deepest_partial_source_bar (series int)
    is_swing (series bool)
    swing_family (series string)
    swing_confirmation_time (series int)
    swing_confirmation_source_bar (series int)
    lifecycle_state_at_swing (series string)
    partial_pct_at_swing (series float)
    wick_tested_at_swing (series bool)
    consumed (series bool)
    consumed_draw_time (series int)
    consumed_event_time (series int)
    consumed_source_bar (series int)
    terminal_close (series float)
    pathway (series string)

ResearchState
  Persistent memory-bounded observer state owned by the importing indicator instance.
  Fields:
    zones (array<ZoneRecord>): Retained newest records only. Old records outside the configured per-side/source Research window are pruned.
    retention_per_bucket (series int): Maximum retained records for each side/source bucket.
    primary_supply_created (series int): Cumulative Primary Supply zones observed since script start.
    primary_demand_created (series int): Cumulative Primary Demand zones observed since script start.
    secondary_supply_created (series int): Cumulative Secondary Supply zones observed since script start.
    secondary_demand_created (series int): Cumulative Secondary Demand zones observed since script start.

SideSnapshot
  One side of a baseline Research snapshot.
  Fields:
    loaded_zones (series int)
    sampled_zones (series int)
    active (series int)
    fresh_active (series int)
    wick_active (series int)
    partial_active (series int)
    consumed (series int)
    ever_wick_tested (series int)
    ever_partially_consumed (series int)
    direct_path (series int)
    untested_direct (series int)
    tested_direct (series int)
    partial_path (series int)
    untested_direct_time_stat (series float)
    untested_direct_time_n (series int)
    tested_direct_time_stat (series float)
    tested_direct_time_n (series int)
    partial_path_time_stat (series float)
    partial_path_time_n (series int)
    tested_direct_wick_stat (series float)
    tested_direct_wick_n (series int)
    partial_path_depth_stat (series float)
    partial_path_depth_n (series int)
    swing_qualified (series int)
    active_swing (series int)
    consumed_swing (series int)
    non_swing (series int)
    consumed_non_swing (series int)
    active_age_stat (series float)
    active_age_n (series int)
    consume_time_stat (series float)
    consume_time_n (series int)
    max_wick_depth_stat (series float)
    max_wick_depth_n (series int)
    max_partial_stat (series float)
    max_partial_n (series int)
    remaining_before_fill_stat (series float)
    remaining_before_fill_n (series int)
    swing_partial_stat (series float)
    swing_partial_n (series int)
    nonswing_partial_stat (series float)
    nonswing_partial_n (series int)
    swing_consume_time_stat (series float)
    swing_consume_time_n (series int)
    nonswing_consume_time_stat (series float)
    nonswing_consume_time_n (series int)
    pivot_h (series int)
    pivot_hh (series int)
    pivot_lh (series int)
    pivot_l (series int)
    pivot_hl (series int)
    pivot_ll (series int)
    trend_swing (series int)
    chop_swing (series int)
    swing_fresh_at_promotion (series int)
    swing_wick_at_promotion (series int)
    swing_partial_at_promotion (series int)
    origin_confirm_hours_stat (series float)
    origin_confirm_bars_stat (series float)
    origin_confirm_n (series int)
    confirm_wick_hours_stat (series float)
    confirm_wick_bars_stat (series float)
    confirm_wick_n (series int)
    confirm_partial_hours_stat (series float)
    confirm_partial_bars_stat (series float)
    confirm_partial_n (series int)
    confirm_swing_hours_stat (series float)
    confirm_swing_bars_stat (series float)
    confirm_swing_n (series int)
    confirm_consume_hours_stat (series float)
    confirm_consume_bars_stat (series float)
    confirm_consume_n (series int)

Snapshot
  Supply and Demand snapshot for one source filter.
  Fields:
    source_filter (series string)
    statistic (series string)
    supply (SideSnapshot)
    demand (SideSnapshot)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ S&D Research Dashboard v6. Full language/statistical-authority audit: user-facing terminology cleanup, explicit LOW N guidance, corrected Swing-cohort interpretation, complete promotion-state accounting and clearer P/S cohort labels.
library("XZ_SD_Research_Dashboard", false)
import Steel-Sovereign/XZ_Session_Authority/1 as xzsess

//==============================================================================
// XZ S&D RESEARCH — OWNERSHIP CONTRACT
//==============================================================================
// OWNED HERE
// - Memory-bounded Research records built from already-decided S&D engine events.
// - Old records outside the configured newest-per-side/source window are pruned immediately.
// - Cumulative loaded-zone counts are preserved separately so pruning does not change baseline Loaded Zones.
// - Bounded most-recent-per-side sampling at snapshot time.
// - Descriptive counts, means/medians and current baseline Research aggregates.
// - Storage of provenance/chronology needed for later Research modules.
//
// NOT OWNED HERE
// - Supply/Demand zone formation.
// - Rejection geometry.
// - Fresh / Wick Tested / Partial / Consumed decisions.
// - Testing / Breach Pending live interaction decisions.
// - XZ Market Structure, MSB, BOS, CHoCH or Swing qualification.
// - Primary/Secondary lifecycle authority.
// - Session clocks / schedules themselves; canonical clocks remain owned by XZ Session Authority.
// - Alert decisions.
// - Supply/Demand chart-zone drawings.
//
// RESEARCH SESSION ATTRIBUTION OWNED HERE
// - Research-only attribution of stored event timestamps to the selected canonical Session Standard.
// - Same-session / cross-session descriptive transitions between already-recorded lifecycle events.
// - Session classification never creates, qualifies, tests, consumes or otherwise changes an S&D zone.
//
// PRESENTATION OWNED HERE
// - Research table lifecycle, sizing, section layout, formatting and Research tooltips.
// - Research presentation consumes stored observer facts only; it cannot create or mutate S&D authority.
//
// The protected S&D engine says WHAT happened and WHEN.
// This library only remembers and summarizes those facts.
// v3 never needs to retain an unlimited duplicate copy of the indicator's historical zone universe.
// Event Chronology is calculated from the same bounded ZoneRecords already required by baseline Research.
//==============================================================================

//==============================================================================
// EXPORTED TYPES
//==============================================================================

//@type One canonical already-decided S&D event transported from the protected engine.
export type ResearchEvent
    string event_type = ""
    int zone_id = na
    string side = ""
    string source_context = ""
    string source_timeframe = ""
    int birth_time = na
    int confirmation_time = na
    int event_draw_time = na
    int event_time = na
    int source_bar = na
    int origin_event_time = na
    int confirmation_event_time = na
    int origin_source_bar = na
    int confirmation_source_bar = na
    float outer_boundary = na
    float original_inner_boundary = na
    float previous_inner_boundary = na
    float current_inner_boundary = na
    float event_price = na
    float penetration_pct = na
    int event_sequence = 0
    string pivot_class = ""
    string swing_family = ""
    string lifecycle_state = ""
    string pathway = ""

//@type Factual Research record for one engine-owned zone. Exported because it is stored inside ResearchState.
export type ZoneRecord
    int zone_id = na
    string side = ""
    string source_context = ""
    string source_timeframe = ""
    int birth_time = na
    int confirmation_time = na
    int origin_event_time = na
    int confirmation_event_time = na
    int origin_source_bar = na
    int confirmation_source_bar = na
    float outer_boundary = na
    float original_inner_boundary = na
    float current_inner_boundary = na
    string pivot_class = ""

    int wick_test_count = 0
    float max_wick_pct = na
    int first_wick_time = na
    int first_wick_source_bar = na
    int last_wick_time = na
    int last_wick_source_bar = na

    int partial_count = 0
    float max_partial_pct = na
    int first_partial_time = na
    int first_partial_source_bar = na
    int deepest_partial_time = na
    int deepest_partial_source_bar = na

    bool is_swing = false
    string swing_family = ""
    int swing_confirmation_time = na
    int swing_confirmation_source_bar = na
    string lifecycle_state_at_swing = ""
    float partial_pct_at_swing = na
    bool wick_tested_at_swing = false

    bool consumed = false
    int consumed_draw_time = na
    int consumed_event_time = na
    int consumed_source_bar = na
    float terminal_close = na
    string pathway = ""
    // Descriptive cross-timeframe relationship facts maintained by Research only.
    // Geometry uses immutable original boundaries and requires concurrent confirmed lifetimes.
    bool ps_same_direction_overlap = false
    bool ps_nested_in_other = false
    bool ps_contains_other = false
    bool ps_partial_same_overlap = false
    bool ps_opposing_conflict = false
    float ps_max_same_coverage_pct = na

//@type Persistent memory-bounded observer state owned by the importing indicator instance.
//@field zones Retained newest records only. Old records outside the configured per-side/source Research window are pruned.
//@field retention_per_bucket Maximum retained records for each side/source bucket.
//@field primary_supply_created Cumulative Primary Supply zones observed since script start.
//@field primary_demand_created Cumulative Primary Demand zones observed since script start.
//@field secondary_supply_created Cumulative Secondary Supply zones observed since script start.
//@field secondary_demand_created Cumulative Secondary Demand zones observed since script start.
export type ResearchState
    array<ZoneRecord> zones
    int retention_per_bucket = 500
    int primary_supply_created = 0
    int primary_demand_created = 0
    int secondary_supply_created = 0
    int secondary_demand_created = 0

//@type One side of a baseline Research snapshot.
export type SideSnapshot
    int loaded_zones = 0
    int sampled_zones = 0
    float sample_span_hours = na
    int sample_span_n = 0
    int active = 0
    int fresh_active = 0
    int wick_active = 0
    int partial_active = 0
    int consumed = 0

    int ever_wick_tested = 0
    int ever_partially_consumed = 0

    float wick_test_count_stat = na
    int wick_test_count_n = 0
    float partial_event_count_stat = na
    int partial_event_count_n = 0

    int untested_direct = 0
    int tested_direct = 0
    int partial_path = 0

    float untested_direct_time_stat = na
    float untested_direct_bars_stat = na
    int untested_direct_time_n = 0
    float tested_direct_time_stat = na
    float tested_direct_bars_stat = na
    int tested_direct_time_n = 0
    float partial_path_time_stat = na
    float partial_path_bars_stat = na
    int partial_path_time_n = 0
    float tested_direct_wick_stat = na
    int tested_direct_wick_n = 0
    float partial_path_depth_stat = na
    int partial_path_depth_n = 0

    int swing_qualified = 0
    int active_swing = 0
    int consumed_swing = 0
    int non_swing = 0
    int consumed_non_swing = 0

    float active_age_stat = na
    int active_age_n = 0
    float consume_time_stat = na
    int consume_time_n = 0

    float max_wick_depth_stat = na
    int max_wick_depth_n = 0
    float max_partial_stat = na
    int max_partial_n = 0

    float swing_partial_stat = na
    int swing_partial_n = 0
    float nonswing_partial_stat = na
    int nonswing_partial_n = 0
    float swing_consume_time_stat = na
    int swing_consume_time_n = 0
    float nonswing_consume_time_stat = na
    int nonswing_consume_time_n = 0

    // STRUCTURAL PROVENANCE
    int pivot_h = 0
    int pivot_hh = 0
    int pivot_lh = 0
    int pivot_l = 0
    int pivot_hl = 0
    int pivot_ll = 0

    int trend_swing = 0
    int chop_swing = 0

    int swing_fresh_at_promotion = 0
    int swing_wick_at_promotion = 0
    int swing_partial_at_promotion = 0
    int swing_consumed_at_promotion = 0

    // EVENT CHRONOLOGY
    // Each pair reports raw elapsed hours and source-bar distance over the same qualifying zones.
    float origin_confirm_hours_stat = na
    float origin_confirm_bars_stat = na
    int origin_confirm_n = 0

    float confirm_wick_hours_stat = na
    float confirm_wick_bars_stat = na
    int confirm_wick_n = 0

    float confirm_partial_hours_stat = na
    float confirm_partial_bars_stat = na
    int confirm_partial_n = 0

    float confirm_swing_hours_stat = na
    float confirm_swing_bars_stat = na
    int confirm_swing_n = 0

    float confirm_consume_hours_stat = na
    float confirm_consume_bars_stat = na
    int confirm_consume_n = 0

//@type Supply and Demand snapshot for one source filter.
export type Snapshot
    string source_filter
    string statistic
    SideSnapshot supply
    SideSnapshot demand

export type ConfluenceSnapshot
    int sampled = 0
    int same_overlap = 0
    int nested_in_other = 0
    int contains_other = 0
    int partial_same_overlap = 0
    int opposing_conflict = 0
    int standalone = 0

    int same_consumed = 0
    int same_wick_tested = 0
    int same_partial = 0
    int same_swing = 0
    int conflict_consumed = 0
    int standalone_consumed = 0

    float max_coverage_stat = na
    int max_coverage_n = 0

//==============================================================================
// PRIVATE HELPERS
//==============================================================================

_find_zone_index(ResearchState state, int zone_id) =>
    int result = -1
    int size = array.size(state.zones)
    if size > 0
        for offset = 0 to size - 1
            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)
            if zone.zone_id == zone_id
                result := idx
                break
    result

_source_matches(ZoneRecord zone, string source_filter) =>
    source_filter == "All" or zone.source_context == source_filter

_bucket_matches(ZoneRecord zone, string side, string source_context) =>
    zone.side == side and zone.source_context == source_context

_increment_loaded_count(ResearchState state, string side, string source_context) =>
    if source_context == "Primary"
        if side == "Supply"
            state.primary_supply_created += 1
        else if side == "Demand"
            state.primary_demand_created += 1
    else if source_context == "Secondary"
        if side == "Supply"
            state.secondary_supply_created += 1
        else if side == "Demand"
            state.secondary_demand_created += 1
    true

_loaded_count(ResearchState state, string side, string source_filter) =>
    int result = 0
    if source_filter == "Primary" or source_filter == "All"
        result += side == "Supply" ? state.primary_supply_created : state.primary_demand_created
    if source_filter == "Secondary" or source_filter == "All"
        result += side == "Supply" ? state.secondary_supply_created : state.secondary_demand_created
    result

_prune_bucket(ResearchState state, string side, string source_context) =>
    int bucket_count = 0
    int size = array.size(state.zones)

    if size > 0
        for i = 0 to size - 1
            ZoneRecord zone = array.get(state.zones, i)
            if _bucket_matches(zone, side, source_context)
                bucket_count += 1

    while bucket_count > state.retention_per_bucket
        int remove_index = -1
        int current_size = array.size(state.zones)

        if current_size > 0
            for i = 0 to current_size - 1
                ZoneRecord zone = array.get(state.zones, i)
                if _bucket_matches(zone, side, source_context)
                    remove_index := i
                    break

        if remove_index >= 0
            array.remove(state.zones, remove_index)
            bucket_count -= 1
        else
            break

    true

_safe_max(float current_value, float candidate) =>
    na(candidate) ? current_value : na(current_value) ? candidate : math.max(current_value, candidate)

_mean(array<float> values) =>
    float result = na
    int n = array.size(values)
    if n > 0
        float total = 0.0
        for i = 0 to n - 1
            total += array.get(values, i)
        result := total / n
    result

_median(array<float> values) =>
    float result = na
    int n = array.size(values)
    if n > 0
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        int mid = int(math.floor(n / 2.0))
        result := n % 2 == 1 ? array.get(sorted, mid) : (array.get(sorted, mid - 1) + array.get(sorted, mid)) / 2.0
    result

_selected_stat(array<float> values, string statistic) =>
    statistic == "Mean" ? _mean(values) : _median(values)

_hours_between(int start_time, int end_time) =>
    not na(start_time) and not na(end_time) and end_time >= start_time ? (end_time - start_time) / 3600000.0 : na

_bars_between(int start_bar, int end_bar) =>
    not na(start_bar) and not na(end_bar) and end_bar >= start_bar ? float(end_bar - start_bar) : na

// Event Chronology scratch calculator.
// Only two arrays exist for one metric call: hours + source bars.
// The function returns scalars, so the scratch buffers do not accumulate across metrics.
_chronology_stat(
     ResearchState state,
     string side,
     string source_filter,
     int sample_limit,
     string statistic,
     int metric_code
 ) =>
    array<float> hour_values = array.new_float()
    array<float> bar_values = array.new_float()

    int sampled = 0
    int size = array.size(state.zones)

    if size > 0
        for offset = 0 to size - 1
            if sampled >= sample_limit
                break

            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)

            if zone.side == side and _source_matches(zone, source_filter)
                sampled += 1

                int confirmation_anchor_time = not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
                int origin_anchor_time = not na(zone.origin_event_time) ? zone.origin_event_time : zone.birth_time

                float h = na
                float b = na

                if metric_code == 0
                    h := _hours_between(origin_anchor_time, confirmation_anchor_time)
                    b := _bars_between(zone.origin_source_bar, zone.confirmation_source_bar)
                else if metric_code == 1
                    h := _hours_between(confirmation_anchor_time, zone.first_wick_time)
                    b := _bars_between(zone.confirmation_source_bar, zone.first_wick_source_bar)
                else if metric_code == 2
                    h := _hours_between(confirmation_anchor_time, zone.first_partial_time)
                    b := _bars_between(zone.confirmation_source_bar, zone.first_partial_source_bar)
                else if metric_code == 3
                    h := _hours_between(confirmation_anchor_time, zone.swing_confirmation_time)
                    b := _bars_between(zone.confirmation_source_bar, zone.swing_confirmation_source_bar)
                else
                    h := _hours_between(confirmation_anchor_time, zone.consumed_event_time)
                    b := _bars_between(zone.confirmation_source_bar, zone.consumed_source_bar)

                if not na(h) and not na(b)
                    array.push(hour_values, h)
                    array.push(bar_values, b)

    float hour_stat = _selected_stat(hour_values, statistic)
    float bar_stat = _selected_stat(bar_values, statistic)
    int n = math.min(array.size(hour_values), array.size(bar_values))

    [hour_stat, bar_stat, n]

// Consumption Pathways scratch calculator.
// Temporary arrays only; no second persistent pathway history bank.
// metric_code:
// 0 = Untested Direct confirmation->Consumption timing
// 1 = Tested Direct confirmation->Consumption timing
// 2 = Partial Path confirmation->Consumption timing
// 3 = Tested Direct maximum prior wick depth
// 4 = Partial Path deepest prior accepted Partial depth
_pathway_stat(
     ResearchState state,
     string side,
     string source_filter,
     int sample_limit,
     string statistic,
     int metric_code
 ) =>
    array<float> values = array.new_float()
    array<float> bar_values = array.new_float()
    int sampled = 0
    int size = array.size(state.zones)

    if size > 0
        for offset = 0 to size - 1
            if sampled >= sample_limit
                break

            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)

            if zone.side == side and _source_matches(zone, source_filter)
                sampled += 1

                if zone.consumed
                    string required_path =
                         metric_code == 0 ? "Untested Direct" :
                         metric_code == 1 or metric_code == 3 ? "Tested Direct" :
                         "Partial Path"

                    if zone.pathway == required_path
                        float value = na
                        float bars_value = na

                        if metric_code <= 2
                            int confirmation_anchor = not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
                            value := _hours_between(confirmation_anchor, zone.consumed_event_time)
                            bars_value := _bars_between(zone.confirmation_source_bar, zone.consumed_source_bar)
                        else if metric_code == 3
                            value := zone.max_wick_pct
                        else
                            value := zone.max_partial_pct

                        if not na(value)
                            array.push(values, value)
                            if metric_code <= 2 and not na(bars_value)
                                array.push(bar_values, bars_value)

    float value_stat = _selected_stat(values, statistic)
    float bar_stat = metric_code <= 2 ? _selected_stat(bar_values, statistic) : na
    int n = metric_code <= 2 ? math.min(array.size(values), array.size(bar_values)) : array.size(values)
    [value_stat, bar_stat, n]

_build_side_snapshot(
     ResearchState state,
     string side,
     string source_filter,
     int now_time,
     int sample_limit,
     string statistic,
     bool include_chronology,
     bool include_pathways
 ) =>
    SideSnapshot result = SideSnapshot.new()
    result.loaded_zones := _loaded_count(state, side, source_filter)

    array<float> active_age_hours = array.new_float()
    array<float> consumption_hours = array.new_float()
    array<float> wick_depths = array.new_float()
    array<float> partial_depths = array.new_float()
    array<float> wick_test_counts = array.new_float()
    array<float> partial_event_counts = array.new_float()
    array<float> swing_partial_depths = array.new_float()
    array<float> nonswing_partial_depths = array.new_float()
    array<float> swing_consumption_hours = array.new_float()
    array<float> nonswing_consumption_hours = array.new_float()

    int sample_oldest_confirmation = na
    int sample_newest_confirmation = na

    int size = array.size(state.zones)
    if size > 0
        for offset = 0 to size - 1
            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)

            if zone.side == side and _source_matches(zone, source_filter)
                if result.sampled_zones < sample_limit
                    result.sampled_zones += 1

                    int sample_confirmation = not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
                    if not na(sample_confirmation)
                        sample_oldest_confirmation := na(sample_oldest_confirmation) ? sample_confirmation : math.min(sample_oldest_confirmation, sample_confirmation)
                        sample_newest_confirmation := na(sample_newest_confirmation) ? sample_confirmation : math.max(sample_newest_confirmation, sample_confirmation)

                    switch zone.pivot_class
                        "H" => result.pivot_h += 1
                        "HH" => result.pivot_hh += 1
                        "LH" => result.pivot_lh += 1
                        "L" => result.pivot_l += 1
                        "HL" => result.pivot_hl += 1
                        "LL" => result.pivot_ll += 1

                    bool ever_wick = zone.wick_test_count > 0
                    bool ever_partial = zone.partial_count > 0 and not na(zone.max_partial_pct) and zone.max_partial_pct > 0.0

                    if ever_wick
                        result.ever_wick_tested += 1
                        array.push(wick_test_counts, float(zone.wick_test_count))
                        if not na(zone.max_wick_pct)
                            array.push(wick_depths, zone.max_wick_pct)

                    if ever_partial
                        result.ever_partially_consumed += 1
                        array.push(partial_event_counts, float(zone.partial_count))
                        array.push(partial_depths, zone.max_partial_pct)
                        if zone.is_swing
                            array.push(swing_partial_depths, zone.max_partial_pct)
                        else
                            array.push(nonswing_partial_depths, zone.max_partial_pct)

                    if zone.consumed
                        result.consumed += 1

                        if zone.pathway == "Untested Direct"
                            result.untested_direct += 1
                        else if zone.pathway == "Tested Direct"
                            result.tested_direct += 1
                        else if zone.pathway == "Partial Path"
                            result.partial_path += 1

                        // Terminal Consumption authority belongs to the source close.
                        // draw time is retained only as a fallback for legacy/drawing chronology.
                        int terminal_time = not na(zone.consumed_event_time) ? zone.consumed_event_time : zone.consumed_draw_time
                        float consumed_hours = _hours_between(zone.birth_time, terminal_time)
                        if not na(consumed_hours)
                            array.push(consumption_hours, consumed_hours)
                            if zone.is_swing
                                array.push(swing_consumption_hours, consumed_hours)
                            else
                                array.push(nonswing_consumption_hours, consumed_hours)
                    else
                        result.active += 1
                        float age_hours = _hours_between(zone.birth_time, now_time)
                        if not na(age_hours)
                            array.push(active_age_hours, age_hours)

                        if ever_partial
                            result.partial_active += 1
                        else if ever_wick
                            result.wick_active += 1
                        else
                            result.fresh_active += 1

                    if zone.is_swing
                        result.swing_qualified += 1

                        if zone.swing_family == "Trend"
                            result.trend_swing += 1
                        else if zone.swing_family == "Chop"
                            result.chop_swing += 1

                        if zone.lifecycle_state_at_swing == "Fresh"
                            result.swing_fresh_at_promotion += 1
                        else if zone.lifecycle_state_at_swing == "Wick Tested"
                            result.swing_wick_at_promotion += 1
                        else if zone.lifecycle_state_at_swing == "Partially Consumed"
                            result.swing_partial_at_promotion += 1
                        else if zone.lifecycle_state_at_swing == "Consumed"
                            result.swing_consumed_at_promotion += 1

                        if zone.consumed
                            result.consumed_swing += 1
                        else
                            result.active_swing += 1

    result.non_swing := result.sampled_zones - result.swing_qualified
    result.consumed_non_swing := result.consumed - result.consumed_swing

    result.sample_span_hours := not na(sample_oldest_confirmation) and not na(sample_newest_confirmation) ? _hours_between(sample_oldest_confirmation, sample_newest_confirmation) : na
    result.sample_span_n := result.sampled_zones

    result.active_age_stat := _selected_stat(active_age_hours, statistic)
    result.active_age_n := array.size(active_age_hours)
    result.consume_time_stat := _selected_stat(consumption_hours, statistic)
    result.consume_time_n := array.size(consumption_hours)

    result.wick_test_count_stat := _selected_stat(wick_test_counts, statistic)
    result.wick_test_count_n := array.size(wick_test_counts)
    result.partial_event_count_stat := _selected_stat(partial_event_counts, statistic)
    result.partial_event_count_n := array.size(partial_event_counts)

    result.max_wick_depth_stat := _selected_stat(wick_depths, statistic)
    result.max_wick_depth_n := array.size(wick_depths)
    result.max_partial_stat := _selected_stat(partial_depths, statistic)
    result.max_partial_n := array.size(partial_depths)

    result.swing_partial_stat := _selected_stat(swing_partial_depths, statistic)
    result.swing_partial_n := array.size(swing_partial_depths)
    result.nonswing_partial_stat := _selected_stat(nonswing_partial_depths, statistic)
    result.nonswing_partial_n := array.size(nonswing_partial_depths)
    result.swing_consume_time_stat := _selected_stat(swing_consumption_hours, statistic)
    result.swing_consume_time_n := array.size(swing_consumption_hours)
    result.nonswing_consume_time_stat := _selected_stat(nonswing_consumption_hours, statistic)
    result.nonswing_consume_time_n := array.size(nonswing_consumption_hours)

    if include_pathways
        [untested_time, untested_bars, untested_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 0)
        result.untested_direct_time_stat := untested_time
        result.untested_direct_bars_stat := untested_bars
        result.untested_direct_time_n := untested_n

        [tested_time, tested_bars, tested_time_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 1)
        result.tested_direct_time_stat := tested_time
        result.tested_direct_bars_stat := tested_bars
        result.tested_direct_time_n := tested_time_n

        [partial_time, partial_bars, partial_time_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 2)
        result.partial_path_time_stat := partial_time
        result.partial_path_bars_stat := partial_bars
        result.partial_path_time_n := partial_time_n

        [tested_wick, tested_wick_bars, tested_wick_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 3)
        result.tested_direct_wick_stat := tested_wick
        result.tested_direct_wick_n := tested_wick_n

        [partial_depth, partial_depth_bars, partial_depth_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 4)
        result.partial_path_depth_stat := partial_depth
        result.partial_path_depth_n := partial_depth_n

    if include_chronology
        [origin_confirm_h, origin_confirm_b, origin_confirm_count] = _chronology_stat(state, side, source_filter, sample_limit, statistic, 0)
        result.origin_confirm_hours_stat := origin_confirm_h
        result.origin_confirm_bars_stat := origin_confirm_b
        result.origin_confirm_n := origin_confirm_count

        [confirm_wick_h, confirm_wick_b, confirm_wick_count] = _chronology_stat(state, side, source_filter, sample_limit, statistic, 1)
        result.confirm_wick_hours_stat := confirm_wick_h
        result.confirm_wick_bars_stat := confirm_wick_b
        result.confirm_wick_n := confirm_wick_count

        [confirm_partial_h, confirm_partial_b, confirm_partial_count] = _chronology_stat(state, side, source_filter, sample_limit, statistic, 2)
        result.confirm_partial_hours_stat := confirm_partial_h
        result.confirm_partial_bars_stat := confirm_partial_b
        result.confirm_partial_n := confirm_partial_count

        [confirm_swing_h, confirm_swing_b, confirm_swing_count] = _chronology_stat(state, side, source_filter, sample_limit, statistic, 3)
        result.confirm_swing_hours_stat := confirm_swing_h
        result.confirm_swing_bars_stat := confirm_swing_b
        result.confirm_swing_n := confirm_swing_count

        [confirm_consume_h, confirm_consume_b, confirm_consume_count] = _chronology_stat(state, side, source_filter, sample_limit, statistic, 4)
        result.confirm_consume_hours_stat := confirm_consume_h
        result.confirm_consume_bars_stat := confirm_consume_b
        result.confirm_consume_n := confirm_consume_count

    result


//==============================================================================
// SESSION BEHAVIOUR RESEARCH
// Canonical clock authority comes from XZ_Session_Authority.
// These helpers classify already-stored event timestamps only.
//==============================================================================

_session_selected(int session_index, bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york) =>
    session_index == 0 ? show_sydney :
     session_index == 1 ? show_tokyo :
     session_index == 2 ? show_london :
     show_new_york

_session_hhmm_minutes(string hhmm) =>
    float raw = str.tonumber(hhmm)
    int result = 0

    if not na(raw)
        int packed = int(raw)
        int hour_part = int(math.floor(packed / 100))
        int minute_part = packed % 100
        result := math.max(0, math.min(23, hour_part)) * 60 + math.max(0, math.min(59, minute_part))

    result

_session_custom_occurrence_contains(
     int timestamp_value,
     int open_time,
     int close_time,
     bool weekdays_only,
     string timezone_name
 ) =>
    bool valid_day = not weekdays_only or xzsess.isLocalWeekday(open_time, timezone_name)
    valid_day and timestamp_value >= open_time and timestamp_value <= close_time

_session_custom_contains(
     int timestamp_value,
     string open_hhmm,
     string close_hhmm,
     string timezone_name,
     bool weekdays_only
 ) =>
    bool result = false

    if not na(timestamp_value)
        int open_minutes = _session_hhmm_minutes(open_hhmm)
        int close_minutes = _session_hhmm_minutes(close_hhmm)

        int local_year = year(timestamp_value, timezone_name)
        int local_month = month(timestamp_value, timezone_name)
        int local_day = dayofmonth(timestamp_value, timezone_name)

        int open_hour = int(math.floor(open_minutes / 60))
        int open_minute = open_minutes % 60
        int close_hour = int(math.floor(close_minutes / 60))
        int close_minute = close_minutes % 60

        bool overnight = close_minutes <= open_minutes

        int open_today = timestamp(timezone_name, local_year, local_month, local_day, open_hour, open_minute, 0)
        int close_today = timestamp(
             timezone_name,
             local_year,
             local_month,
             local_day + (overnight ? 1 : 0),
             close_hour,
             close_minute,
             0
         )

        result := _session_custom_occurrence_contains(
             timestamp_value, open_today, close_today, weekdays_only, timezone_name
         )

        if overnight and not result
            int open_previous = timestamp(timezone_name, local_year, local_month, local_day - 1, open_hour, open_minute, 0)
            int close_previous = timestamp(timezone_name, local_year, local_month, local_day, close_hour, close_minute, 0)
            result := _session_custom_occurrence_contains(
                 timestamp_value, open_previous, close_previous, weekdays_only, timezone_name
             )

    result

// Returns:
// -1 = selected standard cannot be reconstructed from timestamp alone (Symbol Native)
//  0 = outside selected sessions
// >0 = canonical session mask
_session_mask_at(
     int timestamp_value,
     string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     string custom_open,
     string custom_close,
     string custom_timezone,
     bool custom_weekdays_only,
     string symbol_timezone
 ) =>
    int mask = 0

    if na(timestamp_value)
        mask := 0

    else if standard == "Symbol Native"
        // TradingView regular-market membership is a feed/bar fact (session.ismarket).
        // It is intentionally not guessed from a stored timestamp.
        mask := -1

    else if standard == "Custom"
        mask := _session_custom_contains(
             timestamp_value,
             custom_open,
             custom_close,
             custom_timezone,
             custom_weekdays_only
         ) ? 1 : 0

    else
        int session_count = xzsess.sessionCount()

        for session_index = 0 to session_count - 1
            if _session_selected(session_index, show_sydney, show_tokyo, show_london, show_new_york)
                int segment_count = xzsess.segmentCount(standard, session_index)
                bool inside_session = false

                for segment_index = 0 to segment_count - 1
                    [session_open, session_close, valid_day, occurrence_key] = xzsess.segmentBounds(
                         standard,
                         session_index,
                         segment_index,
                         timestamp_value,
                         custom_timezone,
                         symbol_timezone
                     )

                    if valid_day and timestamp_value >= session_open and timestamp_value <= session_close
                        inside_session := true

                if inside_session
                    mask := xzsess.maskAdd(mask, session_index)

    mask

_session_stage_time(ZoneRecord zone, int stage_code) =>
    int result = na

    if stage_code == 0
        result := not na(zone.origin_event_time) ? zone.origin_event_time : zone.birth_time
    else if stage_code == 1
        result := not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
    else if stage_code == 2
        result := zone.first_wick_time
    else if stage_code == 3
        result := zone.first_partial_time
    else if stage_code == 4
        result := zone.consumed_event_time
    else if stage_code == 5
        result := zone.swing_confirmation_time

    result

_session_pct(int count, int total) =>
    total <= 0 ? "N/A" : str.tostring(100.0 * count / total, "#.0") + "%"

_ui_n_suffix(int sample_n) =>
    " · n=" + str.tostring(sample_n) + (sample_n > 0 and sample_n < 10 ? " · LOW N" : "")

_session_mix_text(
     ResearchState state,
     string side,
     string source_filter,
     int sample_limit,
     int stage_code,
     string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     string custom_open,
     string custom_close,
     string custom_timezone,
     bool custom_weekdays_only,
     string symbol_timezone
 ) =>
    string result = "N/A"

    if standard == "Symbol Native"
        result := "N/A · Native"
    else
        int market_sydney = 0
        int market_tokyo = 0
        int market_london = 0
        int market_new_york = 0
        int overlap_count = 0
        int off_count = 0
        int event_count = 0
        int sampled = 0
        int size = array.size(state.zones)

        if size > 0
            for offset = 0 to size - 1
                if sampled >= sample_limit
                    break

                int idx = size - 1 - offset
                ZoneRecord zone = array.get(state.zones, idx)

                if zone.side == side and _source_matches(zone, source_filter)
                    sampled += 1
                    int event_time = _session_stage_time(zone, stage_code)

                    if not na(event_time)
                        int mask = _session_mask_at(
                             event_time,
                             standard,
                             show_sydney,
                             show_tokyo,
                             show_london,
                             show_new_york,
                             custom_open,
                             custom_close,
                             custom_timezone,
                             custom_weekdays_only,
                             symbol_timezone
                         )

                        if mask >= 0
                            event_count += 1

                            if mask == 0
                                off_count += 1
                            else if standard == "Custom"
                                // One configured Custom session.
                                market_sydney += 1
                            else
                                if xzsess.maskHas(mask, 0)
                                    market_sydney += 1
                                if xzsess.maskHas(mask, 1)
                                    market_tokyo += 1
                                if xzsess.maskHas(mask, 2)
                                    market_london += 1
                                if xzsess.maskHas(mask, 3)
                                    market_new_york += 1
                                if xzsess.maskIsOverlap(mask)
                                    overlap_count += 1

        if event_count > 0
            if standard == "Custom"
                result :=
                     "CUS " + _session_pct(market_sydney, event_count) +
                     " · OFF " + _session_pct(off_count, event_count) +
                     _ui_n_suffix(event_count)
            else
                result :=
                     "SYD " + _session_pct(market_sydney, event_count) +
                     " · TYO " + _session_pct(market_tokyo, event_count) +
                     " · LDN " + _session_pct(market_london, event_count) +
                     "\nNY " + _session_pct(market_new_york, event_count) +
                     " · OVL " + _session_pct(overlap_count, event_count) +
                     " · OFF " + _session_pct(off_count, event_count) +
                     _ui_n_suffix(event_count)

    result

_session_transition_text(
     ResearchState state,
     string side,
     string source_filter,
     int sample_limit,
     int from_stage,
     int to_stage,
     string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     string custom_open,
     string custom_close,
     string custom_timezone,
     bool custom_weekdays_only,
     string symbol_timezone
 ) =>
    string result = "N/A"

    if standard == "Symbol Native"
        result := "N/A · Native"
    else
        int same_count = 0
        int cross_count = 0
        int off_count = 0
        int pair_count = 0
        int sampled = 0
        int size = array.size(state.zones)

        if size > 0
            for offset = 0 to size - 1
                if sampled >= sample_limit
                    break

                int idx = size - 1 - offset
                ZoneRecord zone = array.get(state.zones, idx)

                if zone.side == side and _source_matches(zone, source_filter)
                    sampled += 1

                    int from_time = _session_stage_time(zone, from_stage)
                    int to_time = _session_stage_time(zone, to_stage)

                    if not na(from_time) and not na(to_time)
                        int from_mask = _session_mask_at(
                             from_time,
                             standard,
                             show_sydney,
                             show_tokyo,
                             show_london,
                             show_new_york,
                             custom_open,
                             custom_close,
                             custom_timezone,
                             custom_weekdays_only,
                             symbol_timezone
                         )
                        int to_mask = _session_mask_at(
                             to_time,
                             standard,
                             show_sydney,
                             show_tokyo,
                             show_london,
                             show_new_york,
                             custom_open,
                             custom_close,
                             custom_timezone,
                             custom_weekdays_only,
                             symbol_timezone
                         )

                        if from_mask >= 0 and to_mask >= 0
                            pair_count += 1

                            if from_mask == 0 or to_mask == 0
                                off_count += 1
                            else
                                bool same_session = standard == "Custom" ? true : xzsess.maskIntersection(from_mask, to_mask) != 0

                                if same_session
                                    same_count += 1
                                else
                                    cross_count += 1

        if pair_count > 0
            result :=
                 "Same " + _session_pct(same_count, pair_count) +
                 " · Cross " + _session_pct(cross_count, pair_count) +
                 " · Off " + _session_pct(off_count, pair_count) +
                 _ui_n_suffix(pair_count)

    result

//==============================================================================
// PRIVATE RESEARCH UI HELPERS
// Presentation only. No protected S&D methodology is calculated here.
//==============================================================================

_ui_position(string position_name) =>
    switch position_name
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.bottom_left

_ui_text_size(string size_name) =>
    switch size_name
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.normal

_ui_timeframe_label(string tf) =>
    string result = tf
    float numeric_minutes = str.tonumber(tf)
    if not na(numeric_minutes)
        int total_minutes = int(numeric_minutes)
        result := total_minutes > 0 and total_minutes % 60 == 0 ? str.tostring(int(total_minutes / 60)) + "H" : str.tostring(total_minutes) + "m"
    else
        result := tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf
    result

_ui_number_n(float value, string suffix, int sample_n) =>
    (na(value) ? "N/A" : str.tostring(value, "#.##") + suffix) + _ui_n_suffix(sample_n)

_ui_chronology_n(float hours_value, float bars_value, int sample_n) =>
    (na(hours_value) or na(bars_value) ? "N/A" : str.tostring(hours_value, "#.##") + "h · " + str.tostring(bars_value, "#.##") + " bars") + _ui_n_suffix(sample_n)

_ui_mix3(string a_label, int a, string b_label, int b, string c_label, int c, int total) =>
    total > 0 ? a_label + " " + str.tostring(100.0 * a / total, "#.#") + "% · " + b_label + " " + str.tostring(100.0 * b / total, "#.#") + "% · " + c_label + " " + str.tostring(100.0 * c / total, "#.#") + "%" + _ui_n_suffix(total) : "N/A · n=0"

_ui_mix4(string a_label, int a, string b_label, int b, string c_label, int c, string d_label, int d, int total) =>
    total > 0 ? a_label + " " + str.tostring(100.0 * a / total, "#.#") + "% · " + b_label + " " + str.tostring(100.0 * b / total, "#.#") + "%\n" + c_label + " " + str.tostring(100.0 * c / total, "#.#") + "% · " + d_label + " " + str.tostring(100.0 * d / total, "#.#") + "%" + _ui_n_suffix(total) : "N/A · n=0"

_ui_mix2(string a_label, int a, string b_label, int b, int total) =>
    total > 0 ? a_label + " " + str.tostring(100.0 * a / total, "#.#") + "% · " + b_label + " " + str.tostring(100.0 * b / total, "#.#") + "%" + _ui_n_suffix(total) : "N/A · n=0"

_ui_share_n(int part, int total) =>
    (total > 0 ? str.tostring(100.0 * part / total, "#.0") + "%" : "N/A") + _ui_n_suffix(total)

_ui_section(table target, int row, string title, string tip, color accent_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, title, text_color = accent_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
    true

_ui_data_row(table target, int row, string metric, string supply_value, string demand_value, string tip, color text_color, color supply_color, color demand_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, metric, text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, supply_value, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, demand_value, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
    table.cell_set_tooltip(target, 1, row, tip)
    table.cell_set_tooltip(target, 2, row, tip)
    true

_ui_compare_row(table target, int row, string metric, string primary_supply, string primary_demand, string secondary_supply, string secondary_demand, string tip, color text_color, color supply_color, color demand_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, metric, text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, primary_supply, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, primary_demand, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 3, row, secondary_supply, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 4, row, secondary_demand, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
    table.cell_set_tooltip(target, 1, row, tip)
    table.cell_set_tooltip(target, 2, row, tip)
    table.cell_set_tooltip(target, 3, row, tip)
    table.cell_set_tooltip(target, 4, row, tip)
    true

_ui_available(bool available, string value) =>
    available ? value : "N/A"

_ui_source_row(
     table target,
     int row,
     string metric,
     string primary_supply,
     string primary_demand,
     string secondary_supply,
     string secondary_demand,
     bool compare_mode,
     bool secondary_mode,
     bool secondary_available,
     string tip,
     color text_color,
     color supply_color,
     color demand_color,
     color bg_color,
     string text_size
 ) =>
    if compare_mode
        _ui_compare_row(target, row, metric, primary_supply, primary_demand, _ui_available(secondary_available, secondary_supply), _ui_available(secondary_available, secondary_demand), tip, text_color, supply_color, demand_color, bg_color, text_size)
    else if secondary_mode
        _ui_data_row(target, row, metric, _ui_available(secondary_available, secondary_supply), _ui_available(secondary_available, secondary_demand), tip, text_color, supply_color, demand_color, bg_color, text_size)
    else
        _ui_data_row(target, row, metric, primary_supply, primary_demand, tip, text_color, supply_color, demand_color, bg_color, text_size)
    true

//==============================================================================
// EXPORTED STATE API
//==============================================================================

//@function Creates one empty persistent S&D Research observer state with bounded retention per side/source bucket.
//@param retentionPerBucket Maximum newest records retained for each Supply/Demand x Primary/Secondary bucket.
//@returns Empty memory-bounded ResearchState.
export newState(simple int retentionPerBucket) =>
    ResearchState.new(array.new<ZoneRecord>(), math.max(retentionPerBucket, 1), 0, 0, 0, 0)

//@function Clears all retained Research records and cumulative loaded-zone counts.
export clearState(ResearchState state) =>
    array.clear(state.zones)
    state.primary_supply_created := 0
    state.primary_demand_created := 0
    state.secondary_supply_created := 0
    state.secondary_demand_created := 0
    true

//@function Number of Research zone records currently retained.
export recordCount(ResearchState state) =>
    array.size(state.zones)

//==============================================================================
// PRIMARY / SECONDARY CONFLUENCE RESEARCH
// Descriptive only. No relationship here changes S&D lifecycle or structural authority.
//==============================================================================

_ps_lower(ZoneRecord zone) =>
    math.min(zone.outer_boundary, zone.original_inner_boundary)

_ps_upper(ZoneRecord zone) =>
    math.max(zone.outer_boundary, zone.original_inner_boundary)

_ps_width(ZoneRecord zone) =>
    math.max(0.0, _ps_upper(zone) - _ps_lower(zone))

_ps_confirmation_time(ZoneRecord zone) =>
    not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time

_ps_alive_at(ZoneRecord zone, int timestamp_value) =>
    int confirmed = _ps_confirmation_time(zone)
    bool confirmed_by_then = not na(confirmed) and confirmed <= timestamp_value
    bool not_terminal_before = na(zone.consumed_event_time) or zone.consumed_event_time >= timestamp_value
    confirmed_by_then and not_terminal_before

_ps_overlap_width(ZoneRecord a, ZoneRecord b) =>
    float lower = math.max(_ps_lower(a), _ps_lower(b))
    float upper = math.min(_ps_upper(a), _ps_upper(b))
    math.max(0.0, upper - lower)

// When a new Research zone is confirmed, compare it with retained opposite-source zones
// that are still alive at the new confirmation. Flags are written onto both records.
_update_ps_confluence_for_new_zone(ResearchState state, int new_index) =>
    int size = array.size(state.zones)

    if new_index >= 0 and new_index < size
        ZoneRecord newer = array.get(state.zones, new_index)
        int new_confirm = _ps_confirmation_time(newer)

        if not na(new_confirm)
            for idx = 0 to size - 1
                if idx != new_index
                    ZoneRecord other = array.get(state.zones, idx)

                    if other.source_context != newer.source_context and _ps_alive_at(other, new_confirm)
                        float newer_width = _ps_width(newer)
                        float other_width = _ps_width(other)
                        float overlap = _ps_overlap_width(newer, other)

                        if overlap > 0.0 and newer_width > 0.0 and other_width > 0.0
                            if newer.side == other.side
                                newer.ps_same_direction_overlap := true
                                other.ps_same_direction_overlap := true

                                float newer_coverage = 100.0 * overlap / newer_width
                                float other_coverage = 100.0 * overlap / other_width
                                newer.ps_max_same_coverage_pct := _safe_max(newer.ps_max_same_coverage_pct, newer_coverage)
                                other.ps_max_same_coverage_pct := _safe_max(other.ps_max_same_coverage_pct, other_coverage)

                                bool newer_inside_other = _ps_lower(newer) >= _ps_lower(other) and _ps_upper(newer) <= _ps_upper(other)
                                bool other_inside_newer = _ps_lower(other) >= _ps_lower(newer) and _ps_upper(other) <= _ps_upper(newer)

                                if newer_inside_other
                                    newer.ps_nested_in_other := true
                                    other.ps_contains_other := true

                                if other_inside_newer
                                    other.ps_nested_in_other := true
                                    newer.ps_contains_other := true

                                if not newer_inside_other and not other_inside_newer
                                    newer.ps_partial_same_overlap := true
                                    other.ps_partial_same_overlap := true

                            else
                                newer.ps_opposing_conflict := true
                                other.ps_opposing_conflict := true

                            array.set(state.zones, idx, other)

            array.set(state.zones, new_index, newer)

    true

_build_confluence_snapshot(
     ResearchState state,
     string side,
     string source_context,
     int sample_limit,
     string statistic
 ) =>
    ConfluenceSnapshot result = ConfluenceSnapshot.new()
    array<float> coverage_values = array.new_float()

    int sampled = 0
    int size = array.size(state.zones)

    if size > 0
        for offset = 0 to size - 1
            if sampled >= sample_limit
                break

            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)

            if zone.side == side and zone.source_context == source_context
                sampled += 1
                result.sampled += 1

                bool same = zone.ps_same_direction_overlap
                bool conflict = zone.ps_opposing_conflict
                bool standalone = not same and not conflict

                if same
                    result.same_overlap += 1

                    if zone.ps_nested_in_other
                        result.nested_in_other += 1
                    if zone.ps_contains_other
                        result.contains_other += 1
                    if zone.ps_partial_same_overlap
                        result.partial_same_overlap += 1

                    if not na(zone.ps_max_same_coverage_pct)
                        array.push(coverage_values, zone.ps_max_same_coverage_pct)

                    if zone.consumed
                        result.same_consumed += 1
                    if zone.wick_test_count > 0
                        result.same_wick_tested += 1
                    if zone.partial_count > 0
                        result.same_partial += 1
                    if zone.is_swing
                        result.same_swing += 1

                if conflict
                    result.opposing_conflict += 1
                    if zone.consumed
                        result.conflict_consumed += 1

                if standalone
                    result.standalone += 1
                    if zone.consumed
                        result.standalone_consumed += 1

    result.max_coverage_stat := _selected_stat(coverage_values, statistic)
    result.max_coverage_n := array.size(coverage_values)
    result

_ps_available(bool secondary_available, string value) =>
    secondary_available ? value : "N/A · Secondary OFF"

//==============================================================================
// EXPORTED EVENT OBSERVER
//==============================================================================

//@function Observes one already-decided protected-engine event. It never derives or re-decides S&D authority.
export observeEvent(ResearchState state, ResearchEvent event) =>
    bool changed = false

    if event.event_type == "ZONE_CREATED"
        int existing_index = _find_zone_index(state, event.zone_id)
        if existing_index < 0
            ZoneRecord zone = ZoneRecord.new()
            zone.zone_id := event.zone_id
            zone.side := event.side
            zone.source_context := event.source_context
            zone.source_timeframe := event.source_timeframe
            zone.birth_time := event.birth_time
            zone.confirmation_time := event.confirmation_time
            zone.origin_event_time := event.origin_event_time
            zone.confirmation_event_time := event.confirmation_event_time
            zone.origin_source_bar := event.origin_source_bar
            zone.confirmation_source_bar := event.confirmation_source_bar
            zone.outer_boundary := event.outer_boundary
            zone.original_inner_boundary := event.original_inner_boundary
            zone.current_inner_boundary := event.current_inner_boundary
            zone.pivot_class := event.pivot_class

            _increment_loaded_count(state, event.side, event.source_context)
            array.push(state.zones, zone)

            int new_zone_index = array.size(state.zones) - 1
            _update_ps_confluence_for_new_zone(state, new_zone_index)

            _prune_bucket(state, event.side, event.source_context)
            changed := true

    else
        int idx = _find_zone_index(state, event.zone_id)
        if idx >= 0
            ZoneRecord zone = array.get(state.zones, idx)

            if event.side != ""
                zone.side := event.side
            if event.source_context != ""
                zone.source_context := event.source_context
            if event.source_timeframe != ""
                zone.source_timeframe := event.source_timeframe
            if not na(event.birth_time)
                zone.birth_time := event.birth_time
            if not na(event.confirmation_time)
                zone.confirmation_time := event.confirmation_time
            if not na(event.outer_boundary)
                zone.outer_boundary := event.outer_boundary
            if not na(event.original_inner_boundary)
                zone.original_inner_boundary := event.original_inner_boundary
            if not na(event.current_inner_boundary)
                zone.current_inner_boundary := event.current_inner_boundary
            if event.pivot_class != ""
                zone.pivot_class := event.pivot_class

            if event.event_type == "WICK_TEST"
                zone.wick_test_count := math.max(zone.wick_test_count, event.event_sequence)
                zone.max_wick_pct := _safe_max(zone.max_wick_pct, event.penetration_pct)

                if na(zone.first_wick_time)
                    zone.first_wick_time := event.event_time
                    zone.first_wick_source_bar := event.source_bar

                zone.last_wick_time := event.event_time
                zone.last_wick_source_bar := event.source_bar
                changed := true

            else if event.event_type == "PARTIAL_CONSUMPTION"
                zone.partial_count := math.max(zone.partial_count, event.event_sequence)
                zone.max_partial_pct := _safe_max(zone.max_partial_pct, event.penetration_pct)

                if na(zone.first_partial_time)
                    zone.first_partial_time := event.event_time
                    zone.first_partial_source_bar := event.source_bar

                zone.deepest_partial_time := event.event_time
                zone.deepest_partial_source_bar := event.source_bar
                changed := true

            else if event.event_type == "SWING_PROMOTED"
                zone.is_swing := true
                zone.swing_family := event.swing_family
                zone.swing_confirmation_time := event.event_time
                zone.swing_confirmation_source_bar := event.source_bar
                zone.lifecycle_state_at_swing := event.lifecycle_state
                zone.partial_pct_at_swing := event.penetration_pct
                zone.wick_tested_at_swing := zone.wick_test_count > 0
                changed := true

            else if event.event_type == "ZONE_CONSUMED"
                zone.consumed := true
                zone.consumed_draw_time := event.event_draw_time
                zone.consumed_event_time := event.event_time
                zone.consumed_source_bar := event.source_bar
                zone.terminal_close := event.event_price
                zone.pathway := event.pathway
                changed := true

            if changed
                array.set(state.zones, idx, zone)

    changed

//==============================================================================
// EXPORTED BASELINE + EVENT CHRONOLOGY SNAPSHOT
//==============================================================================

//@function Builds one bounded snapshot. Baseline metrics always calculate. Event Chronology calculates only when includeChronology is true, using one metric-at-a-time scratch buffers to minimize peak runtime memory.
export snapshot(
     ResearchState state,
     simple string sourceFilter,
     int nowTime,
     simple int sampleLimit,
     simple string statistic,
     bool includeChronology,
     bool includePathways
 ) =>
    SideSnapshot supply = _build_side_snapshot(state, "Supply", sourceFilter, nowTime, sampleLimit, statistic, includeChronology, includePathways)
    SideSnapshot demand = _build_side_snapshot(state, "Demand", sourceFilter, nowTime, sampleLimit, statistic, includeChronology, includePathways)
    Snapshot.new(sourceFilter, statistic, supply, demand)

//==============================================================================
// EXPORTED RESEARCH TABLE RENDERER
//==============================================================================

//@function Renders or removes the complete XZ S&D Research Lab using already-observed bounded ResearchState facts. Presentation only; this function cannot decide S&D lifecycle or structure.
//==============================================================================
// PRIVATE ACTIVE RESEARCH RENDERER
// Split from renderLab to keep Pine local conditional scopes below CE10205 limits.
//==============================================================================

_renderLabActive(
     table target,
     ResearchState state,
     simple string source,
     simple string section,
     simple string statistic,
     simple string textSizeName,
     color bgColor,
     color textColor,
     color accentColor,
     color supplyColor,
     color demandColor,
     simple string primaryTimeframe,
     simple string secondaryTimeframe,
     bool secondaryEnabled,
     bool secondaryConfigured,
     bool secondaryIsHigher,
     int nowTime,
     simple int sampleLimit,
     simple string sessionStandard,
     simple bool sessionShowSydney,
     simple bool sessionShowTokyo,
     simple bool sessionShowLondon,
     simple bool sessionShowNewYork,
     simple string sessionCustomOpen,
     simple string sessionCustomClose,
     simple string sessionCustomTimezone,
     simple bool sessionCustomWeekdaysOnly,
     simple string symbolTimezone
 ) =>
    bool confluence_mode = section == "P/S Confluence"
    bool research_compare_mode = source == "Compare" or confluence_mode
    bool research_secondary_mode = source == "Secondary" and not confluence_mode
    int research_sample_limit_live = sampleLimit
    bool research_needs_secondary = research_secondary_mode or research_compare_mode
    bool research_secondary_available = secondaryEnabled
    bool research_secondary_invalid = research_needs_secondary and secondaryConfigured and not secondaryIsHigher
    bool research_secondary_off = research_needs_secondary and not secondaryConfigured

    bool show_lifecycle_research = section == "Zone Lifecycle"
    bool show_interaction_research = section == "Interaction & Penetration"
    bool show_swing_research = section == "Swing Authority"
    bool show_chronology_research = section == "Event Chronology"
    bool show_pathways_research = section == "Consumption Pathways"
    bool show_session_research = section == "Session Attribution" or section == "Session Behaviour"
    bool show_provenance_research = section == "Structural Provenance"
    bool show_confluence_research = section == "P/S Confluence"

    research_size = _ui_text_size(textSizeName)

    string primary_research_tf = _ui_timeframe_label(primaryTimeframe)
    string secondary_research_tf = _ui_timeframe_label(secondaryTimeframe)

    Snapshot primary_snapshot = snapshot(
         state, "Primary", nowTime, research_sample_limit_live, statistic, show_chronology_research, show_pathways_research
     )
    Snapshot secondary_snapshot = snapshot(
         state, "Secondary", nowTime, research_sample_limit_live, statistic, show_chronology_research, show_pathways_research
     )

    SideSnapshot ps = primary_snapshot.supply
    SideSnapshot pd = primary_snapshot.demand
    SideSnapshot ss = secondary_snapshot.supply
    SideSnapshot sd = secondary_snapshot.demand

    ConfluenceSnapshot cps = ConfluenceSnapshot.new()
    ConfluenceSnapshot cpd = ConfluenceSnapshot.new()
    ConfluenceSnapshot css = ConfluenceSnapshot.new()
    ConfluenceSnapshot csd = ConfluenceSnapshot.new()

    if show_confluence_research and research_secondary_available
        cps := _build_confluence_snapshot(state, "Supply", "Primary", research_sample_limit_live, statistic)
        cpd := _build_confluence_snapshot(state, "Demand", "Primary", research_sample_limit_live, statistic)
        css := _build_confluence_snapshot(state, "Supply", "Secondary", research_sample_limit_live, statistic)
        csd := _build_confluence_snapshot(state, "Demand", "Secondary", research_sample_limit_live, statistic)

    string secondary_status = research_secondary_available ? "" : research_secondary_invalid ? " · INVALID TF" : research_secondary_off ? " · OFF" : " · N/A"
    string research_title =
         confluence_mode ? "XZ S&D - RESEARCH · P/S CONFLUENCE · P " + primary_research_tf + " / S " + secondary_research_tf + secondary_status :
         research_compare_mode ? "XZ S&D - RESEARCH · COMPARE · P " + primary_research_tf + " / S " + secondary_research_tf + secondary_status :
         research_secondary_mode ? "XZ S&D - RESEARCH · SECONDARY " + secondary_research_tf + secondary_status :
         "XZ S&D - RESEARCH · PRIMARY " + primary_research_tf

    table.cell(target, 0, 0, research_title, text_color = accentColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
    table.cell_set_tooltip(
         target, 0, 0,
         "Research observes committed S&D events and never re-decides zone authority. Primary uses chart-timeframe zones, Secondary uses the configured higher-timeframe engine, and Compare keeps all four side/source populations separate. Detailed sample cap per side/source: " + str.tostring(research_sample_limit_live) + ". LOW N marks a qualifying cohort with n below 10; the value is still shown but should be interpreted cautiously. One selected section is rendered at a time for readability. Research describes loaded observed history; it does not establish causation or predictive performance."
     )

    if research_compare_mode
        table.cell(target, 0, 1, "Metric", text_color = textColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
        table.cell(target, 1, 1, "P Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
        table.cell(target, 2, 1, "P Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
        table.cell(target, 3, 1, "S Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
        table.cell(target, 4, 1, "S Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
    else
        table.cell(target, 0, 1, "Metric", text_color = textColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
        table.cell(target, 1, 1, "Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
        table.cell(target, 2, 1, "Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)

    int research_row = 2

    // One metric declaration per row. Mode selection is handled by _ui_source_row().
    if show_lifecycle_research
        _ui_section(target, research_row, "ZONE LIFECYCLE", "Lifecycle distribution, age and consumption timing.", accentColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Total Observed",
             str.tostring(ps.loaded_zones), str.tostring(pd.loaded_zones), str.tostring(ss.loaded_zones), str.tostring(sd.loaded_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Cumulative zones created by the selected engine population over loaded chart history. This count is not capped by the Research sample; it shows the larger population from which the newest bounded sample is drawn.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Research Sample",
             str.tostring(ps.sampled_zones), str.tostring(pd.sampled_zones), str.tostring(ss.sampled_zones), str.tostring(sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Newest bounded Research sample per side/source. Current cap: " + str.tostring(research_sample_limit_live) + ".", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Sample Span",
             _ui_number_n(ps.sample_span_hours, "h", ps.sample_span_n), _ui_number_n(pd.sample_span_hours, "h", pd.sample_span_n),
             _ui_number_n(ss.sample_span_hours, "h", ss.sample_span_n), _ui_number_n(sd.sample_span_hours, "h", sd.sample_span_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Elapsed time from the oldest to newest zone confirmation represented inside the current bounded Research Sample. Compare this row before interpreting P/S statistics side-by-side: equal sample counts do not imply equal calendar coverage.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Active",
             str.tostring(ps.active), str.tostring(pd.active), str.tostring(ss.active), str.tostring(sd.active),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Sampled zones whose immutable outer boundary has not yet been authoritatively closed through. Active includes Fresh, Wick Tested and Partially Consumed states.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Fresh Active",
             str.tostring(ps.fresh_active), str.tostring(pd.fresh_active), str.tostring(ss.fresh_active), str.tostring(sd.fresh_active),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Active with no committed Wick Test or Partial Consumption.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Wick Tested Active",
             str.tostring(ps.wick_active), str.tostring(pd.wick_active), str.tostring(ss.wick_active), str.tostring(sd.wick_active),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Active with Wick Test history and no Partial Consumption.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Partial Active",
             str.tostring(ps.partial_active), str.tostring(pd.partial_active), str.tostring(ss.partial_active), str.tostring(sd.partial_active),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Active with accepted Partial Consumption history.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Consumed",
             str.tostring(ps.consumed), str.tostring(pd.consumed), str.tostring(ss.consumed), str.tostring(sd.consumed),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Sampled zones that reached terminal Consumption on an authoritative source close.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Consumed Share",
             _ui_share_n(ps.consumed, ps.sampled_zones), _ui_share_n(pd.consumed, pd.sampled_zones),
             _ui_share_n(ss.consumed, ss.sampled_zones), _ui_share_n(sd.consumed, sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Observed-to-date share of the bounded sample that has reached terminal Consumption within loaded history: an authoritative source close through the immutable outer boundary. Active zones remain unresolved, so this is not an eventual Consumption probability, trade win rate or predictive score.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Active Age",
             _ui_number_n(ps.active_age_stat, "h", ps.active_age_n), _ui_number_n(pd.active_age_stat, "h", pd.active_age_n),
             _ui_number_n(ss.active_age_stat, "h", ss.active_age_n), _ui_number_n(sd.active_age_stat, "h", sd.active_age_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Birth-to-current hours for unresolved zones.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Time to Consume",
             _ui_number_n(ps.consume_time_stat, "h", ps.consume_time_n), _ui_number_n(pd.consume_time_stat, "h", pd.consume_time_n),
             _ui_number_n(ss.consume_time_stat, "h", ss.consume_time_n), _ui_number_n(sd.consume_time_stat, "h", sd.consume_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " elapsed hours from the pivot-origin bar to the authoritative source close that committed terminal Consumption. This includes the pre-confirmation formation interval; Event Chronology and pathway timing use confirmation as their post-creation anchor.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_interaction_research
        _ui_section(target, research_row, "INTERACTION & PENETRATION", "Committed Wick Test and accepted-close penetration.", accentColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Ever Wick Tested",
             str.tostring(ps.ever_wick_tested), str.tostring(pd.ever_wick_tested), str.tostring(ss.ever_wick_tested), str.tostring(sd.ever_wick_tested),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Zones with committed Wick Test history.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Wick Test Share",
             _ui_share_n(ps.ever_wick_tested, ps.sampled_zones), _ui_share_n(pd.ever_wick_tested, pd.sampled_zones),
             _ui_share_n(ss.ever_wick_tested, ss.sampled_zones), _ui_share_n(sd.ever_wick_tested, sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Share of sampled zones that experienced at least one committed Wick Test. A test records exploration into rejected territory and does not require accepted close penetration.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Wick Tests / Tested Zone",
             _ui_number_n(ps.wick_test_count_stat, "", ps.wick_test_count_n), _ui_number_n(pd.wick_test_count_stat, "", pd.wick_test_count_n),
             _ui_number_n(ss.wick_test_count_stat, "", ss.wick_test_count_n), _ui_number_n(sd.wick_test_count_stat, "", sd.wick_test_count_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " number of committed Wick Test events per zone, calculated only across zones with at least one Wick Test. The observation unit is one zone's total committed Wick Test count.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Max Wick Depth",
             _ui_number_n(ps.max_wick_depth_stat, "%", ps.max_wick_depth_n), _ui_number_n(pd.max_wick_depth_stat, "%", pd.max_wick_depth_n),
             _ui_number_n(ss.max_wick_depth_stat, "%", ss.max_wick_depth_n), _ui_number_n(sd.max_wick_depth_stat, "%", sd.max_wick_depth_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " across each Wick Tested zone's deepest committed Wick Test penetration as a percentage of original immutable width. The observation unit is one zone's maximum Wick Test depth, not individual Wick Test events. 100% means wick exploration reached the immutable outer boundary; it does not mean Consumption, which remains authoritative only on a qualifying source close.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Ever Partially Consumed",
             str.tostring(ps.ever_partially_consumed), str.tostring(pd.ever_partially_consumed), str.tostring(ss.ever_partially_consumed), str.tostring(sd.ever_partially_consumed),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Zones with accepted Partial history.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Partial Consumption Share",
             _ui_share_n(ps.ever_partially_consumed, ps.sampled_zones), _ui_share_n(pd.ever_partially_consumed, pd.sampled_zones),
             _ui_share_n(ss.ever_partially_consumed, ss.sampled_zones), _ui_share_n(sd.ever_partially_consumed, sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Share of sampled zones that accepted at least one source close deeper inside the original rejected territory, contracting the live inner boundary without closing through the immutable outer boundary.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Partial Events / Partial Zone",
             _ui_number_n(ps.partial_event_count_stat, "", ps.partial_event_count_n), _ui_number_n(pd.partial_event_count_stat, "", pd.partial_event_count_n),
             _ui_number_n(ss.partial_event_count_stat, "", ss.partial_event_count_n), _ui_number_n(sd.partial_event_count_stat, "", sd.partial_event_count_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " number of committed Partial Consumption events per zone, calculated only across zones with at least one accepted Partial. The observation unit is one zone's total committed Partial-event count.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Max Partial",
             _ui_number_n(ps.max_partial_stat, "%", ps.max_partial_n), _ui_number_n(pd.max_partial_stat, "%", pd.max_partial_n),
             _ui_number_n(ss.max_partial_stat, "%", ss.max_partial_n), _ui_number_n(sd.max_partial_stat, "%", sd.max_partial_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " across each Partially Consumed zone's deepest accepted Partial penetration as a percentage of original immutable width. The observation unit is one zone's deepest accepted Partial, not individual Partial events.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_swing_research
        _ui_section(target, research_row, "SWING AUTHORITY", "Later structural Swing qualification.", accentColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Swing Qualified",
             str.tostring(ps.swing_qualified), str.tostring(pd.swing_qualified), str.tostring(ss.swing_qualified), str.tostring(sd.swing_qualified),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Zones later gaining XZ Swing authority.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Observed Swing Share",
             _ui_share_n(ps.swing_qualified, ps.sampled_zones), _ui_share_n(pd.swing_qualified, pd.sampled_zones),
             _ui_share_n(ss.swing_qualified, ss.sampled_zones), _ui_share_n(sd.swing_qualified, sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Observed-to-date share of sampled zones whose origin has been promoted by canonical XZ Market Structure into Swing authority within loaded history. Swing authority is structural provenance and is independent of whether the S&D zone is still active; a currently non-Swing origin may promote later. This is not an eventual promotion probability or a stronger-zone assumption at birth.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Active Swing",
             str.tostring(ps.active_swing), str.tostring(pd.active_swing), str.tostring(ss.active_swing), str.tostring(sd.active_swing),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Unresolved Swing-qualified zones.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Consumed Swing",
             str.tostring(ps.consumed_swing), str.tostring(pd.consumed_swing), str.tostring(ss.consumed_swing), str.tostring(sd.consumed_swing),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Consumed Swing-qualified zones.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "Swing Authority · Consumed Share",
             _ui_share_n(ps.consumed_swing, ps.swing_qualified), _ui_share_n(pd.consumed_swing, pd.swing_qualified),
             _ui_share_n(ss.consumed_swing, ss.swing_qualified), _ui_share_n(sd.consumed_swing, sd.swing_qualified),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Observed-to-date Consumption share within Swing-qualified zones. Swing qualification is assigned later from structural evolution and can occur while a zone is active or after its S&D lifecycle has resolved. Differences versus no-Swing zones are therefore observational and timing/selection dependent; they do not show that Swing promotion caused greater persistence.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, "No Swing Authority · Consumed Share",
             _ui_share_n(ps.consumed_non_swing, ps.non_swing), _ui_share_n(pd.consumed_non_swing, pd.non_swing),
             _ui_share_n(ss.consumed_non_swing, ss.non_swing), _ui_share_n(sd.consumed_non_swing, sd.non_swing),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Observed-to-date Consumption share within zones that have not gained Swing authority in loaded history. Its denominator is intentionally separate from the Swing cohort. Structural promotion is a later event and may still occur for a currently non-Swing origin, including after S&D resolution, so comparison with Swing zones is descriptive and timing/selection dependent rather than causal.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Max Partial · Swing",
             _ui_number_n(ps.swing_partial_stat, "%", ps.swing_partial_n), _ui_number_n(pd.swing_partial_stat, "%", pd.swing_partial_n),
             _ui_number_n(ss.swing_partial_stat, "%", ss.swing_partial_n), _ui_number_n(sd.swing_partial_stat, "%", sd.swing_partial_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " across each qualifying Swing zone's deepest accepted Partial penetration. The observation unit is one zone's maximum accepted Partial depth.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Max Partial · No Swing Authority",
             _ui_number_n(ps.nonswing_partial_stat, "%", ps.nonswing_partial_n), _ui_number_n(pd.nonswing_partial_stat, "%", pd.nonswing_partial_n),
             _ui_number_n(ss.nonswing_partial_stat, "%", ss.nonswing_partial_n), _ui_number_n(sd.nonswing_partial_stat, "%", sd.nonswing_partial_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " across each qualifying zone with no Swing authority's deepest accepted Partial penetration. A currently non-Swing origin may still gain Swing authority later; S&D lifecycle resolution does not itself prevent later structural provenance.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Time to Consume · Swing",
             _ui_number_n(ps.swing_consume_time_stat, "h", ps.swing_consume_time_n), _ui_number_n(pd.swing_consume_time_stat, "h", pd.swing_consume_time_n),
             _ui_number_n(ss.swing_consume_time_stat, "h", ss.swing_consume_time_n), _ui_number_n(sd.swing_consume_time_stat, "h", sd.swing_consume_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, statistic + " birth-to-authoritative-Consumption-close hours for consumed Swing-qualified zones. Swing qualification is assigned later from structural evolution and may occur before or after S&D resolution, so comparison with no-Swing zones is observational and timing/selection dependent.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1
        _ui_source_row(target, research_row, statistic + " Time to Consume · No Swing Authority",
             _ui_number_n(ps.nonswing_consume_time_stat, "h", ps.nonswing_consume_time_n), _ui_number_n(pd.nonswing_consume_time_stat, "h", pd.nonswing_consume_time_n),
             _ui_number_n(ss.nonswing_consume_time_stat, "h", ss.nonswing_consume_time_n), _ui_number_n(sd.nonswing_consume_time_stat, "h", sd.nonswing_consume_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Birth-to-authoritative-Consumption-close hours among consumed zones that have not gained Swing authority in loaded history. Structural promotion is a later classification that may still occur after S&D resolution, so compare with the Swing cohort as an observed association only.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_chronology_research
        _ui_section(target, research_row, "EVENT CHRONOLOGY · " + statistic, "Timing between canonical zone events using the selected " + statistic + ". Hours show real elapsed time; source bars show distance in the timeframe that actually owns the zone. Each zone contributes an integer source-bar duration, but the displayed Median/Mean across a cohort can be fractional (for example 2.5 bars).", accentColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Origin → Confirmation",
             _ui_chronology_n(ps.origin_confirm_hours_stat, ps.origin_confirm_bars_stat, ps.origin_confirm_n), _ui_chronology_n(pd.origin_confirm_hours_stat, pd.origin_confirm_bars_stat, pd.origin_confirm_n),
             _ui_chronology_n(ss.origin_confirm_hours_stat, ss.origin_confirm_bars_stat, ss.origin_confirm_n), _ui_chronology_n(sd.origin_confirm_hours_stat, sd.origin_confirm_bars_stat, sd.origin_confirm_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "How long the rejected turning point took to become a confirmed XZ S&D zone. Source bars count candles on the zone's own authority timeframe between origin and confirmation.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → First Wick Test",
             _ui_chronology_n(ps.confirm_wick_hours_stat, ps.confirm_wick_bars_stat, ps.confirm_wick_n), _ui_chronology_n(pd.confirm_wick_hours_stat, pd.confirm_wick_bars_stat, pd.confirm_wick_n),
             _ui_chronology_n(ss.confirm_wick_hours_stat, ss.confirm_wick_bars_stat, ss.confirm_wick_n), _ui_chronology_n(sd.confirm_wick_hours_stat, sd.confirm_wick_bars_stat, sd.confirm_wick_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones that were ever Wick Tested, how quickly price first returned into the original rejected territory after confirmation. Smaller source-bar values mean the zone was challenged sooner relative to its own timeframe.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → First Partial",
             _ui_chronology_n(ps.confirm_partial_hours_stat, ps.confirm_partial_bars_stat, ps.confirm_partial_n), _ui_chronology_n(pd.confirm_partial_hours_stat, pd.confirm_partial_bars_stat, pd.confirm_partial_n),
             _ui_chronology_n(ss.confirm_partial_hours_stat, ss.confirm_partial_bars_stat, ss.confirm_partial_n), _ui_chronology_n(sd.confirm_partial_hours_stat, sd.confirm_partial_bars_stat, sd.confirm_partial_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones that ever accepted a close deeper into rejected territory, time from confirmation to the first accepted Partial. This isolates the first committed contraction of the live inner boundary rather than a wick-only test.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → Swing Promotion",
             _ui_chronology_n(ps.confirm_swing_hours_stat, ps.confirm_swing_bars_stat, ps.confirm_swing_n), _ui_chronology_n(pd.confirm_swing_hours_stat, pd.confirm_swing_bars_stat, pd.confirm_swing_n),
             _ui_chronology_n(ss.confirm_swing_hours_stat, ss.confirm_swing_bars_stat, ss.confirm_swing_n), _ui_chronology_n(sd.confirm_swing_hours_stat, sd.confirm_swing_bars_stat, sd.confirm_swing_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones later promoted to canonical XZ Swing authority, time from S&D confirmation to that structural promotion. This measures how long a local rejected turning point typically takes to become structurally authoritative.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → Consumption",
             _ui_chronology_n(ps.confirm_consume_hours_stat, ps.confirm_consume_bars_stat, ps.confirm_consume_n), _ui_chronology_n(pd.confirm_consume_hours_stat, pd.confirm_consume_bars_stat, pd.confirm_consume_n),
             _ui_chronology_n(ss.confirm_consume_hours_stat, ss.confirm_consume_bars_stat, ss.confirm_consume_n), _ui_chronology_n(sd.confirm_consume_hours_stat, sd.confirm_consume_bars_stat, sd.confirm_consume_n),
             research_compare_mode, research_secondary_mode, research_secondary_available, "Among terminally Consumed zones, time from confirmed zone creation to the authoritative source close through the immutable outer boundary. This excludes the pre-confirmation formation interval.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_pathways_research
        _ui_section(
             target,
             research_row,
             "CONSUMPTION PATHWAYS",
             "Terminal pathway classification uses events that occurred before the consuming candle. Untested Direct = no prior Wick Test and no prior Partial. Tested Direct = one or more prior Wick Tests and no prior Partial. Partial Path = one or more prior accepted Partial events. The terminal consuming candle itself is not retroactively counted as a prior Test.",
             accentColor, bgColor, research_size
         )
        research_row += 1

        _ui_source_row(target, research_row, "Path Mix",
             _ui_mix3("Untested", ps.untested_direct, "Tested", ps.tested_direct, "Partial", ps.partial_path, ps.consumed),
             _ui_mix3("Untested", pd.untested_direct, "Tested", pd.tested_direct, "Partial", pd.partial_path, pd.consumed),
             _ui_mix3("Untested", ss.untested_direct, "Tested", ss.tested_direct, "Partial", ss.partial_path, ss.consumed),
             _ui_mix3("Untested", sd.untested_direct, "Tested", sd.tested_direct, "Partial", sd.partial_path, sd.consumed),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Share of consumed sampled zones ending through each canonical Consumption Pathway.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Time · Untested Direct",
             _ui_chronology_n(ps.untested_direct_time_stat, ps.untested_direct_bars_stat, ps.untested_direct_time_n), _ui_chronology_n(pd.untested_direct_time_stat, pd.untested_direct_bars_stat, pd.untested_direct_time_n),
             _ui_chronology_n(ss.untested_direct_time_stat, ss.untested_direct_bars_stat, ss.untested_direct_time_n), _ui_chronology_n(sd.untested_direct_time_stat, sd.untested_direct_bars_stat, sd.untested_direct_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " confirmation-to-Consumption elapsed hours and native source bars for Untested Direct zones. Hours and bars are summarized independently across the same qualifying cohort. Unlike Zone Lifecycle Time to Consume, which starts at the pivot-origin bar, pathway timing starts at objective zone confirmation.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Time · Tested Direct",
             _ui_chronology_n(ps.tested_direct_time_stat, ps.tested_direct_bars_stat, ps.tested_direct_time_n), _ui_chronology_n(pd.tested_direct_time_stat, pd.tested_direct_bars_stat, pd.tested_direct_time_n),
             _ui_chronology_n(ss.tested_direct_time_stat, ss.tested_direct_bars_stat, ss.tested_direct_time_n), _ui_chronology_n(sd.tested_direct_time_stat, sd.tested_direct_bars_stat, sd.tested_direct_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " confirmation-to-Consumption elapsed hours and native source bars for Tested Direct zones. Hours and bars are summarized independently across the same qualifying cohort. Unlike Zone Lifecycle Time to Consume, which starts at the pivot-origin bar, pathway timing starts at objective zone confirmation.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Time · Partial Path",
             _ui_chronology_n(ps.partial_path_time_stat, ps.partial_path_bars_stat, ps.partial_path_time_n), _ui_chronology_n(pd.partial_path_time_stat, pd.partial_path_bars_stat, pd.partial_path_time_n),
             _ui_chronology_n(ss.partial_path_time_stat, ss.partial_path_bars_stat, ss.partial_path_time_n), _ui_chronology_n(sd.partial_path_time_stat, sd.partial_path_bars_stat, sd.partial_path_time_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " confirmation-to-Consumption elapsed hours and native source bars for Partial Path zones. Hours and bars are summarized independently across the same qualifying cohort. Unlike Zone Lifecycle Time to Consume, which starts at the pivot-origin bar, pathway timing starts at objective zone confirmation.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Max Wick · Tested Direct",
             _ui_number_n(ps.tested_direct_wick_stat, "%", ps.tested_direct_wick_n), _ui_number_n(pd.tested_direct_wick_stat, "%", pd.tested_direct_wick_n),
             _ui_number_n(ss.tested_direct_wick_stat, "%", ss.tested_direct_wick_n), _ui_number_n(sd.tested_direct_wick_stat, "%", sd.tested_direct_wick_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " across each Tested Direct zone's deepest prior Wick Test penetration before terminal Consumption. The observation unit is one zone's maximum prior Wick Test depth. 100% means the prior wick reached the immutable outer boundary; it still was not Consumption because terminal authority requires a qualifying source close.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Max Partial · Partial Path",
             _ui_number_n(ps.partial_path_depth_stat, "%", ps.partial_path_depth_n), _ui_number_n(pd.partial_path_depth_stat, "%", pd.partial_path_depth_n),
             _ui_number_n(ss.partial_path_depth_stat, "%", ss.partial_path_depth_n), _ui_number_n(sd.partial_path_depth_stat, "%", sd.partial_path_depth_n),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " across each terminal Partial Path zone's deepest prior accepted Partial penetration before Consumption. The observation unit is one zone's deepest prior accepted Partial.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_session_research
        string session_mix_tip =
             "Event-time attribution under the selected Session Standard. SYD/TYO/LDN/NY percentages are non-exclusive membership shares and can sum above 100% when windows overlap. OVL = event occurred while more than one selected session was active. OFF = outside all selected Research session windows; on 24/7 instruments it does not mean the market was closed. Session Attribution is observational only."

        string session_transition_tip =
             "Same = the two events share at least one selected session membership. Cross = both events occurred inside selected sessions but share no common session. Off = one or both events occurred outside all selected Research session windows; this does not mean a 24/7 market was closed. For Custom there is one configured session, so two in-session events are Same. Symbol Native is N/A because TradingView regular-market membership cannot be reconstructed reliably from a stored timestamp alone."

        _ui_section(
             target,
             research_row,
             "SESSION ATTRIBUTION",
             "Session attribution for already-recorded lifecycle and Swing-authority events under the selected canonical Session Standard. Market memberships can overlap, so event percentages are not expected to sum to 100%. Transition rows classify shared-session, cross-session, or outside-selected-window movement. This is descriptive attribution, not causal evidence. Session Context frames do not need to be visible.",
             accentColor, bgColor, research_size
         )
        research_row += 1

        _ui_source_row(target, research_row, "Origin Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "First Wick Test Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "First Partial Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Swing Promotion Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Event-time attribution of canonical SWING_PROMOTED events under the selected Session Standard. This reports where later structural authority was gained; it does not imply that the session caused the promotion.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Consumption Session",
             _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Origin → Confirmation",
             _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → First Test",
             _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → First Partial",
             _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → Swing Promotion",
             _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 5, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Session transition from S&D confirmation to canonical Swing promotion. Same/Cross/Off describes session membership only and does not infer causation.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Confirmation → Consumption",
             _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_provenance_research
        _ui_section(target, research_row, "STRUCTURAL PROVENANCE", "Structural origin and later Swing-promotion context. Birth Pivot uses all sampled zones; Swing Family and Promotion State use Swing-qualified zones only.", accentColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Birth Pivot Mix",
             _ui_mix3("H", ps.pivot_h, "HH", ps.pivot_hh, "LH", ps.pivot_lh, ps.sampled_zones),
             _ui_mix3("L", pd.pivot_l, "LL", pd.pivot_ll, "HL", pd.pivot_hl, pd.sampled_zones),
             _ui_mix3("H", ss.pivot_h, "HH", ss.pivot_hh, "LH", ss.pivot_lh, ss.sampled_zones),
             _ui_mix3("L", sd.pivot_l, "LL", sd.pivot_ll, "HL", sd.pivot_hl, sd.sampled_zones),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Distribution of the canonical birth pivot class. H/L are baseline pivots; HH/LL and LH/HL are relational labels versus the previous same-type pivot.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Swing Family Mix",
             _ui_mix2("Trend", ps.trend_swing, "Chop", ps.chop_swing, ps.swing_qualified),
             _ui_mix2("Trend", pd.trend_swing, "Chop", pd.chop_swing, pd.swing_qualified),
             _ui_mix2("Trend", ss.trend_swing, "Chop", ss.chop_swing, ss.swing_qualified),
             _ui_mix2("Trend", sd.trend_swing, "Chop", sd.chop_swing, sd.swing_qualified),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Among Swing-qualified zones only, shows whether canonical Swing authority was gained in Trend or Chop.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "State at Swing Promotion",
             _ui_mix4("Fresh", ps.swing_fresh_at_promotion, "Wick Tested", ps.swing_wick_at_promotion, "Partial", ps.swing_partial_at_promotion, "Consumed", ps.swing_consumed_at_promotion, ps.swing_qualified),
             _ui_mix4("Fresh", pd.swing_fresh_at_promotion, "Wick Tested", pd.swing_wick_at_promotion, "Partial", pd.swing_partial_at_promotion, "Consumed", pd.swing_consumed_at_promotion, pd.swing_qualified),
             _ui_mix4("Fresh", ss.swing_fresh_at_promotion, "Wick Tested", ss.swing_wick_at_promotion, "Partial", ss.swing_partial_at_promotion, "Consumed", ss.swing_consumed_at_promotion, ss.swing_qualified),
             _ui_mix4("Fresh", sd.swing_fresh_at_promotion, "Wick Tested", sd.swing_wick_at_promotion, "Partial", sd.swing_partial_at_promotion, "Consumed", sd.swing_consumed_at_promotion, sd.swing_qualified),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Lifecycle snapshot at the exact canonical Swing-promotion event: Fresh, Wick Tested, Partially Consumed or already Consumed. Swing authority is structural provenance, so a resolved S&D zone can still gain later Swing authority without being reactivated. Later lifecycle events do not rewrite this provenance snapshot.", textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    if show_confluence_research
        string relation_tip =
             "P/S Confluence is descriptive Research only and always uses both Primary and Secondary populations. Relationships use original immutable zone geometry and require overlapping confirmed lifetimes. Relationship direction matters: Primary nested in Secondary and Secondary containing Primary are different observations and are not expected to be symmetric. Same-direction overlap means Supply↔Supply or Demand↔Demand; Opposing Conflict means Supply↔Demand. Flags are non-exclusive. Broader or longer-lived zones have more opportunity to acquire overlaps. All relationships are bounded by retained Research history; a pruned counterpart cannot be rediscovered."

        _ui_section(
             target, research_row, "PRIMARY / SECONDARY CONFLUENCE",
             relation_tip, accentColor, bgColor, research_size
         )
        research_row += 1

        _ui_source_row(target, research_row, "Ever Same-Direction Overlap",
             _ps_available(research_secondary_available, _ui_share_n(cps.same_overlap, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.same_overlap, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.same_overlap, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.same_overlap, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Observed share of sampled zones that ever overlapped at least one concurrent opposite-timeframe zone on the same side during their retained lifetime: Supply↔Supply or Demand↔Demand. Broader or longer-lived zones have more opportunity to acquire overlaps.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Nested in Other TF",
             _ps_available(research_secondary_available, _ui_share_n(cps.nested_in_other, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.nested_in_other, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.nested_in_other, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.nested_in_other, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Target zone was fully contained inside at least one concurrent same-direction zone from the other timeframe.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Contains Other TF",
             _ps_available(research_secondary_available, _ui_share_n(cps.contains_other, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.contains_other, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.contains_other, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.contains_other, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Target zone fully contained at least one concurrent same-direction zone from the other timeframe.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Partial Same-Dir Overlap",
             _ps_available(research_secondary_available, _ui_share_n(cps.partial_same_overlap, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.partial_same_overlap, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.partial_same_overlap, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.partial_same_overlap, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Same-direction price overlap occurred without either zone fully containing the other.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, statistic + " Max Same-Dir Coverage",
             _ps_available(research_secondary_available, _ui_number_n(cps.max_coverage_stat, "%", cps.max_coverage_n)),
             _ps_available(research_secondary_available, _ui_number_n(cpd.max_coverage_stat, "%", cpd.max_coverage_n)),
             _ps_available(research_secondary_available, _ui_number_n(css.max_coverage_stat, "%", css.max_coverage_n)),
             _ps_available(research_secondary_available, _ui_number_n(csd.max_coverage_stat, "%", csd.max_coverage_n)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             statistic + " across each confluent target zone's maximum original-width coverage by any concurrent same-direction opposite-timeframe zone. The observation unit is one target zone's maximum coverage, not individual overlap pairs.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Ever Opposing Conflict",
             _ps_available(research_secondary_available, _ui_share_n(cps.opposing_conflict, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.opposing_conflict, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.opposing_conflict, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.opposing_conflict, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Observed share that ever overlapped at least one concurrent opposite-side zone from the other timeframe during its retained lifetime: Primary Supply↔Secondary Demand or Primary Demand↔Secondary Supply. Wider or longer-lived zones naturally have more exposure opportunity, so this is not intrinsic weakness.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Standalone Share",
             _ps_available(research_secondary_available, _ui_share_n(cps.standalone, cps.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.standalone, cpd.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(css.standalone, css.sampled)),
             _ps_available(research_secondary_available, _ui_share_n(csd.standalone, csd.sampled)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "No concurrent Primary/Secondary price overlap of either same direction or opposing direction was observed inside the retained bounded Research window.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Consumed Share · Same-Dir",
             _ps_available(research_secondary_available, _ui_share_n(cps.same_consumed, cps.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.same_consumed, cpd.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(css.same_consumed, css.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(csd.same_consumed, csd.same_overlap)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Observed-to-date terminal Consumption share within zones that had concurrent same-direction P/S overlap inside the retained Research window. Active members remain unresolved. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Consumed Share · Standalone",
             _ps_available(research_secondary_available, _ui_share_n(cps.standalone_consumed, cps.standalone)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.standalone_consumed, cpd.standalone)),
             _ps_available(research_secondary_available, _ui_share_n(css.standalone_consumed, css.standalone)),
             _ps_available(research_secondary_available, _ui_share_n(csd.standalone_consumed, csd.standalone)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Observed-to-date terminal Consumption share within zones classified Standalone inside the retained Research window. Active members remain unresolved. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Consumed Share · Conflict",
             _ps_available(research_secondary_available, _ui_share_n(cps.conflict_consumed, cps.opposing_conflict)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.conflict_consumed, cpd.opposing_conflict)),
             _ps_available(research_secondary_available, _ui_share_n(css.conflict_consumed, css.opposing_conflict)),
             _ps_available(research_secondary_available, _ui_share_n(csd.conflict_consumed, csd.opposing_conflict)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Observed-to-date terminal Consumption share within zones that overlapped a concurrent opposite-side zone from the other timeframe inside the retained Research window. Active members remain unresolved. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Wick Test Share · Same-Dir",
             _ps_available(research_secondary_available, _ui_share_n(cps.same_wick_tested, cps.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.same_wick_tested, cpd.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(css.same_wick_tested, css.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(csd.same_wick_tested, csd.same_overlap)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Within zones that ever acquired same-direction P/S overlap during retained history, observed share that recorded at least one committed Wick Test. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Partial Share · Same-Dir",
             _ps_available(research_secondary_available, _ui_share_n(cps.same_partial, cps.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.same_partial, cpd.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(css.same_partial, css.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(csd.same_partial, csd.same_overlap)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Within zones that ever acquired same-direction P/S overlap during retained history, observed share that recorded at least one accepted Partial Consumption event. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

        _ui_source_row(target, research_row, "Swing Share · Same-Dir",
             _ps_available(research_secondary_available, _ui_share_n(cps.same_swing, cps.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(cpd.same_swing, cpd.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(css.same_swing, css.same_overlap)),
             _ps_available(research_secondary_available, _ui_share_n(csd.same_swing, csd.same_overlap)),
             research_compare_mode, research_secondary_mode, research_secondary_available,
             "Within zones that ever acquired same-direction P/S overlap during retained history, observed share that gained canonical XZ Swing authority. Confluence itself does not grant Swing authority. Relationship cohorts are based on overlap observed at any point during the retained zone lifetime. Longer-lived zones have more opportunity to acquire a relationship, so outcome differences are exposure-duration biased and descriptive only; they do not establish that confluence caused the later outcome.",
             textColor, supplyColor, demandColor, bgColor, research_size)
        research_row += 1

    true

export renderLab(
     ResearchState state,
     bool showLab,
     simple string source,
     simple string section,
     simple string statistic,
     simple string tablePosition,
     simple string textSizeName,
     color bgColor,
     color textColor,
     color accentColor,
     bool showLines,
     color lineColor,
     color supplyColor,
     color demandColor,
     simple string primaryTimeframe,
     simple string secondaryTimeframe,
     bool secondaryEnabled,
     bool secondaryConfigured,
     bool secondaryIsHigher,
     int nowTime,
     simple int sampleLimit,
     simple string sessionStandard,
     simple bool sessionShowSydney,
     simple bool sessionShowTokyo,
     simple bool sessionShowLondon,
     simple bool sessionShowNewYork,
     simple string sessionCustomOpen,
     simple string sessionCustomClose,
     simple string sessionCustomTimezone,
     simple bool sessionCustomWeekdaysOnly,
     simple string symbolTimezone
 ) =>
    var table research_table = na
    var int research_rows_live = na
    var int research_columns_live = na
    var string research_position_live = ""

    if showLab
        bool confluence_mode = section == "P/S Confluence"
        bool research_compare_mode = source == "Compare" or confluence_mode

        int section_rows =
             section == "Zone Lifecycle" ? 12 :
             section == "Interaction & Penetration" ? 9 :
             section == "Swing Authority" ? 11 :
             section == "Event Chronology" ? 6 :
             section == "Consumption Pathways" ? 7 :
             (section == "Session Attribution" or section == "Session Behaviour") ? 12 :
             section == "Structural Provenance" ? 4 :
             section == "P/S Confluence" ? 14 : 0

        int desired_research_rows = 2 + section_rows
        int desired_research_columns = research_compare_mode ? 5 : 3

        if na(research_table) or research_rows_live != desired_research_rows or research_columns_live != desired_research_columns or research_position_live != tablePosition
            if not na(research_table)
                table.delete(research_table)

            research_table := table.new(
                 _ui_position(tablePosition),
                 desired_research_columns,
                 desired_research_rows,
                 bgcolor = bgColor,
                 border_color = lineColor,
                 border_width = showLines ? 1 : 0,
                 frame_color = lineColor,
                 frame_width = showLines ? 1 : 0
             )

            table.merge_cells(research_table, 0, 0, desired_research_columns - 1, 0)
            if section_rows > 0
                table.merge_cells(research_table, 0, 2, desired_research_columns - 1, 2)

            research_rows_live := desired_research_rows
            research_columns_live := desired_research_columns
            research_position_live := tablePosition

        _renderLabActive(
             research_table, state, source, section, statistic, textSizeName,
             bgColor, textColor, accentColor, supplyColor, demandColor,
             primaryTimeframe, secondaryTimeframe,
             secondaryEnabled, secondaryConfigured, secondaryIsHigher,
             nowTime, sampleLimit,
             sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork,
             sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone
         )
    else
        if not na(research_table)
            table.delete(research_table)
            research_table := na
            research_rows_live := na
            research_columns_live := na
            research_position_live := ""

    true
````
