<!-- tradingview-pine-id: PUB;4e63b898904b4f719b9d8afcb46ae2a2 -->
<!-- tradingview-pine-version: 7.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_SD_Research

Source: https://www.tradingview.com/script/vpYBNOS7-XZ-S-D-Research/

## Description

Library  "XZ_SD_Research"
XZ S&D Research v1. Indicator-specific observer and descriptive aggregation library for already-determined XZ Supply & Demand engine events. It stores Research chronology and reproduces baseline lifecycle, interaction/penetration and Swing-authority statistics without deciding zone creation, lifecycle, structural Swing authority, session membership, alerts or chart drawings.

newState()
  Creates one empty persistent S&D Research observer state.

clearState(state)
  Clears all retained Research records.
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

snapshot(state, sourceFilter, nowTime, sampleLimit, statistic)
  Builds one descriptive baseline snapshot. Sampling is the most recent up to sampleLimit observations PER SIDE, matching the current embedded S&D Research behavior.
  Parameters:
    state (ResearchState)
    sourceFilter (simple string)
    nowTime (int)
    sampleLimit (simple int)
    statistic (simple string)

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
  Persistent observer state owned by the importing indicator instance.
  Fields:
    zones (array<ZoneRecord>)

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

//@description XZ S&D Research v9. Memory-bounded observer and presentation backend for already-determined XZ Supply & Demand engine events. v9 turns All Sections into a dual-panel full-width Research dashboard while individual sections remain single-table.
library("XZ_SD_Research", false)
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
    int active = 0
    int fresh_active = 0
    int wick_active = 0
    int partial_active = 0
    int consumed = 0

    int ever_wick_tested = 0
    int ever_partially_consumed = 0
    int direct_path = 0
    int untested_direct = 0
    int tested_direct = 0
    int partial_path = 0

    float untested_direct_time_stat = na
    int untested_direct_time_n = 0
    float tested_direct_time_stat = na
    int tested_direct_time_n = 0
    float partial_path_time_stat = na
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
    float remaining_before_fill_stat = na
    int remaining_before_fill_n = 0

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
// One temporary float array exists per metric call; no second persistent pathway history bank.
// metric_code:
// 0 = Untested Direct confirmation->Consumption hours
// 1 = Tested Direct confirmation->Consumption hours
// 2 = Partial Path confirmation->Consumption hours
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

                        if metric_code <= 2
                            int confirmation_anchor = not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
                            value := _hours_between(confirmation_anchor, zone.consumed_event_time)
                        else if metric_code == 3
                            value := zone.max_wick_pct
                        else
                            value := zone.max_partial_pct

                        if not na(value)
                            array.push(values, value)

    [_selected_stat(values, statistic), array.size(values)]

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
    array<float> remaining_before_fill = array.new_float()
    array<float> swing_partial_depths = array.new_float()
    array<float> nonswing_partial_depths = array.new_float()
    array<float> swing_consumption_hours = array.new_float()
    array<float> nonswing_consumption_hours = array.new_float()

    int size = array.size(state.zones)
    if size > 0
        for offset = 0 to size - 1
            int idx = size - 1 - offset
            ZoneRecord zone = array.get(state.zones, idx)

            if zone.side == side and _source_matches(zone, source_filter)
                if result.sampled_zones < sample_limit
                    result.sampled_zones += 1

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
                        if not na(zone.max_wick_pct)
                            array.push(wick_depths, zone.max_wick_pct)

                    if ever_partial
                        result.ever_partially_consumed += 1
                        array.push(partial_depths, zone.max_partial_pct)
                        if zone.is_swing
                            array.push(swing_partial_depths, zone.max_partial_pct)
                        else
                            array.push(nonswing_partial_depths, zone.max_partial_pct)

                    if zone.consumed
                        result.consumed += 1

                        if not ever_partial
                            result.direct_path += 1

                        if zone.pathway == "Untested Direct"
                            result.untested_direct += 1
                        else if zone.pathway == "Tested Direct"
                            result.tested_direct += 1
                        else if zone.pathway == "Partial Path"
                            result.partial_path += 1

                        float unresolved_before_fill = ever_partial ? 100.0 - zone.max_partial_pct : 100.0
                        array.push(remaining_before_fill, unresolved_before_fill)

                        int terminal_time = not na(zone.consumed_draw_time) ? zone.consumed_draw_time : zone.consumed_event_time
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

                        if zone.consumed
                            result.consumed_swing += 1
                        else
                            result.active_swing += 1

    result.non_swing := result.sampled_zones - result.swing_qualified
    result.consumed_non_swing := result.consumed - result.consumed_swing

    result.active_age_stat := _selected_stat(active_age_hours, statistic)
    result.active_age_n := array.size(active_age_hours)
    result.consume_time_stat := _selected_stat(consumption_hours, statistic)
    result.consume_time_n := array.size(consumption_hours)

    result.max_wick_depth_stat := _selected_stat(wick_depths, statistic)
    result.max_wick_depth_n := array.size(wick_depths)
    result.max_partial_stat := _selected_stat(partial_depths, statistic)
    result.max_partial_n := array.size(partial_depths)
    result.remaining_before_fill_stat := _selected_stat(remaining_before_fill, statistic)
    result.remaining_before_fill_n := array.size(remaining_before_fill)

    result.swing_partial_stat := _selected_stat(swing_partial_depths, statistic)
    result.swing_partial_n := array.size(swing_partial_depths)
    result.nonswing_partial_stat := _selected_stat(nonswing_partial_depths, statistic)
    result.nonswing_partial_n := array.size(nonswing_partial_depths)
    result.swing_consume_time_stat := _selected_stat(swing_consumption_hours, statistic)
    result.swing_consume_time_n := array.size(swing_consumption_hours)
    result.nonswing_consume_time_stat := _selected_stat(nonswing_consumption_hours, statistic)
    result.nonswing_consume_time_n := array.size(nonswing_consumption_hours)

    if include_pathways
        [untested_time, untested_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 0)
        result.untested_direct_time_stat := untested_time
        result.untested_direct_time_n := untested_n

        [tested_time, tested_time_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 1)
        result.tested_direct_time_stat := tested_time
        result.tested_direct_time_n := tested_time_n

        [partial_time, partial_time_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 2)
        result.partial_path_time_stat := partial_time
        result.partial_path_time_n := partial_time_n

        [tested_wick, tested_wick_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 3)
        result.tested_direct_wick_stat := tested_wick
        result.tested_direct_wick_n := tested_wick_n

        [partial_depth, partial_depth_n] = _pathway_stat(state, side, source_filter, sample_limit, statistic, 4)
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
    else
        result := zone.consumed_event_time

    result

_session_pct(int count, int total) =>
    total <= 0 ? "N/A" : str.tostring(100.0 * count / total, "#.0") + "%"

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
                     " · n=" + str.tostring(event_count)
            else
                result :=
                     "SYD " + _session_pct(market_sydney, event_count) +
                     " · TYO " + _session_pct(market_tokyo, event_count) +
                     " · LDN " + _session_pct(market_london, event_count) +
                     " · NY " + _session_pct(market_new_york, event_count) +
                     " · OVL " + _session_pct(overlap_count, event_count) +
                     " · OFF " + _session_pct(off_count, event_count) +
                     " · n=" + str.tostring(event_count)

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
                 " · n=" + str.tostring(pair_count)

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
    (na(value) ? "N/A" : str.tostring(value, "#.##") + suffix) + " · n=" + str.tostring(sample_n)

_ui_chronology_n(float hours_value, float bars_value, int sample_n) =>
    (na(hours_value) or na(bars_value) ? "N/A" : str.tostring(hours_value, "#.##") + "h · " + str.tostring(bars_value, "#.##") + " bars") + " · n=" + str.tostring(sample_n)

_ui_mix3(string a_label, int a, string b_label, int b, string c_label, int c, int total) =>
    total > 0 ? a_label + " " + str.tostring(100.0 * a / total, "#.#") + "% · " + b_label + " " + str.tostring(100.0 * b / total, "#.#") + "% · " + c_label + " " + str.tostring(100.0 * c / total, "#.#") + "% · n=" + str.tostring(total) : "N/A · n=0"

_ui_mix2(string a_label, int a, string b_label, int b, int total) =>
    total > 0 ? a_label + " " + str.tostring(100.0 * a / total, "#.#") + "% · " + b_label + " " + str.tostring(100.0 * b / total, "#.#") + "% · n=" + str.tostring(total) : "N/A · n=0"

_ui_share_n(int part, int total) =>
    (total > 0 ? str.tostring(100.0 * part / total, "#.0") + "%" : "N/A") + " · n=" + str.tostring(total)

_ui_section(table target, int row, string title, string tip, color accent_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, title, text_color = accent_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
    true

_ui_data_row(table target, int row, string metric, string supply_value, string demand_value, string tip, color text_color, color supply_color, color demand_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, metric, text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, supply_value, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, demand_value, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
    true

_ui_compare_row(table target, int row, string metric, string primary_supply, string primary_demand, string secondary_supply, string secondary_demand, string tip, color text_color, color supply_color, color demand_color, color bg_color, string text_size) =>
    table.cell(target, 0, row, metric, text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, primary_supply, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, primary_demand, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 3, row, secondary_supply, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 4, row, secondary_demand, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, row, tip)
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
        bool research_compare_mode = source == "Compare"
        bool research_secondary_mode = source == "Secondary"
        int research_sample_limit_live = sampleLimit
        bool research_needs_secondary = research_secondary_mode or research_compare_mode
        bool research_secondary_available = secondaryEnabled
        bool research_secondary_invalid = research_needs_secondary and secondaryConfigured and not secondaryIsHigher
        bool research_secondary_off = research_needs_secondary and not secondaryConfigured

        bool dashboard_left = section == "Dashboard Left"
        bool dashboard_right = section == "Dashboard Right"

        // Full dashboard split:
        // LEFT  = lifecycle / interaction / chronology / pathways
        // RIGHT = swing / session behaviour / structural provenance
        bool show_lifecycle_research = section == "Zone Lifecycle" or section == "All Sections" or dashboard_left
        bool show_interaction_research = section == "Interaction & Penetration" or section == "All Sections" or dashboard_left
        bool show_swing_research = section == "Swing Authority" or section == "All Sections" or dashboard_right
        bool show_chronology_research = section == "Event Chronology" or section == "All Sections" or dashboard_left
        bool show_pathways_research = section == "Consumption Pathways" or section == "All Sections" or dashboard_left
        bool show_session_research = section == "Session Behaviour" or section == "All Sections" or dashboard_right
        bool show_provenance_research = section == "Structural Provenance" or section == "All Sections" or dashboard_right

        int lifecycle_rows = show_lifecycle_research ? 11 : 0
        int interaction_rows = show_interaction_research ? 10 : 0
        int swing_rows = show_swing_research ? 11 : 0
        int chronology_rows = show_chronology_research ? 6 : 0
        int pathways_rows = show_pathways_research ? 7 : 0
        int session_rows = show_session_research ? 9 : 0
        int provenance_rows = show_provenance_research ? 4 : 0
        int desired_research_rows = 2 + lifecycle_rows + interaction_rows + swing_rows + chronology_rows + pathways_rows + session_rows + provenance_rows
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

            int merge_row = 2
            if show_lifecycle_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 11
            if show_interaction_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 10
            if show_swing_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 11
            if show_chronology_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 6
            if show_pathways_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 7
            if show_session_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)
                merge_row += 9
            if show_provenance_research
                table.merge_cells(research_table, 0, merge_row, desired_research_columns - 1, merge_row)

            research_rows_live := desired_research_rows
            research_columns_live := desired_research_columns
            research_position_live := tablePosition

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

        string secondary_status = research_secondary_available ? "" : research_secondary_invalid ? " · INVALID TF" : research_secondary_off ? " · OFF" : " · N/A"
        string research_title =
             research_compare_mode ? "XZ S&D - RESEARCH · COMPARE · P " + primary_research_tf + " / S " + secondary_research_tf + secondary_status :
             research_secondary_mode ? "XZ S&D - RESEARCH · SECONDARY " + secondary_research_tf + secondary_status :
             "XZ S&D - RESEARCH · PRIMARY " + primary_research_tf

        if dashboard_left
            research_title += " · DASHBOARD 1/2"
        else if dashboard_right
            research_title += " · DASHBOARD 2/2"

        table.cell(research_table, 0, 0, research_title, text_color = accentColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
        table.cell_set_tooltip(
             research_table, 0, 0,
             "Research observes committed S&D events; it never re-decides zone authority. Primary uses chart-timeframe zones, Secondary uses the configured higher-timeframe engine, and Compare keeps all four side/source populations separate. Sample cap per side/source: " + str.tostring(research_sample_limit_live) + ". Memory Governor v2 bounds retained detail. XZ_SD_Research/9 owns Research storage, statistics and this presentation layer. All Sections automatically uses two coordinated dashboard tables: lifecycle/event research on the left and structural/context research on the right. Individual sections remain single-table. The protected indicator supplies already-decided events and display settings only."
         )

        if research_compare_mode
            table.cell(research_table, 0, 1, "Metric", text_color = textColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
            table.cell(research_table, 1, 1, "P Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
            table.cell(research_table, 2, 1, "P Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
            table.cell(research_table, 3, 1, "S Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
            table.cell(research_table, 4, 1, "S Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
        else
            table.cell(research_table, 0, 1, "Metric", text_color = textColor, text_size = research_size, text_halign = text.align_left, bgcolor = bgColor)
            table.cell(research_table, 1, 1, "Supply", text_color = supplyColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)
            table.cell(research_table, 2, 1, "Demand", text_color = demandColor, text_size = research_size, text_halign = text.align_right, bgcolor = bgColor)

        int research_row = 2

        // One metric declaration per row. Mode selection is handled by _ui_source_row().
        if show_lifecycle_research
            _ui_section(research_table, research_row, "ZONE LIFECYCLE", "Lifecycle distribution, age and consumption timing.", accentColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Loaded Zones",
                 str.tostring(ps.loaded_zones), str.tostring(pd.loaded_zones), str.tostring(ss.loaded_zones), str.tostring(sd.loaded_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Cumulative zones created by the selected engine population over loaded chart history. This count is not capped by the Research sample; it shows the larger population from which the newest bounded sample is drawn.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Sampled Zones",
                 str.tostring(ps.sampled_zones), str.tostring(pd.sampled_zones), str.tostring(ss.sampled_zones), str.tostring(sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Newest bounded Research sample per side/source. Current cap: " + str.tostring(research_sample_limit_live) + ".", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Active",
                 str.tostring(ps.active), str.tostring(pd.active), str.tostring(ss.active), str.tostring(sd.active),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Sampled zones whose immutable outer boundary has not yet been authoritatively closed through. Active includes Fresh, Wick-Tested and Partial states.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Fresh Active",
                 str.tostring(ps.fresh_active), str.tostring(pd.fresh_active), str.tostring(ss.fresh_active), str.tostring(sd.fresh_active),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Active with no committed Test or Partial.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Wick-Tested Active",
                 str.tostring(ps.wick_active), str.tostring(pd.wick_active), str.tostring(ss.wick_active), str.tostring(sd.wick_active),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Active with Wick Test history and no Partial.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Partial Active",
                 str.tostring(ps.partial_active), str.tostring(pd.partial_active), str.tostring(ss.partial_active), str.tostring(sd.partial_active),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Active with accepted Partial history.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Consumed",
                 str.tostring(ps.consumed), str.tostring(pd.consumed), str.tostring(ss.consumed), str.tostring(sd.consumed),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Source-close Consumed zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Consumed Share",
                 _ui_share_n(ps.consumed, ps.sampled_zones), _ui_share_n(pd.consumed, pd.sampled_zones),
                 _ui_share_n(ss.consumed, ss.sampled_zones), _ui_share_n(sd.consumed, sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Share of the bounded sample that reached terminal Consumption: an authoritative source close through the immutable outer boundary. This is lifecycle frequency, not trade win rate or predictive probability.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Active Age",
                 _ui_number_n(ps.active_age_stat, "h", ps.active_age_n), _ui_number_n(pd.active_age_stat, "h", pd.active_age_n),
                 _ui_number_n(ss.active_age_stat, "h", ss.active_age_n), _ui_number_n(sd.active_age_stat, "h", sd.active_age_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Birth-to-current hours for unresolved zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Time to Consume",
                 _ui_number_n(ps.consume_time_stat, "h", ps.consume_time_n), _ui_number_n(pd.consume_time_stat, "h", pd.consume_time_n),
                 _ui_number_n(ss.consume_time_stat, "h", ss.consume_time_n), _ui_number_n(sd.consume_time_stat, "h", sd.consume_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Birth-to-Consumption hours.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_interaction_research
            _ui_section(research_table, research_row, "INTERACTION / PENETRATION", "Committed Test and accepted-close penetration.", accentColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Ever Wick Tested",
                 str.tostring(ps.ever_wick_tested), str.tostring(pd.ever_wick_tested), str.tostring(ss.ever_wick_tested), str.tostring(sd.ever_wick_tested),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Zones with committed Wick Test history.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Wick-Test Share",
                 _ui_share_n(ps.ever_wick_tested, ps.sampled_zones), _ui_share_n(pd.ever_wick_tested, pd.sampled_zones),
                 _ui_share_n(ss.ever_wick_tested, ss.sampled_zones), _ui_share_n(sd.ever_wick_tested, sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Share of sampled zones that experienced at least one committed Wick Test. A test records exploration into rejected territory and does not require accepted close penetration.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Max Wick Depth",
                 _ui_number_n(ps.max_wick_depth_stat, "%", ps.max_wick_depth_n), _ui_number_n(pd.max_wick_depth_stat, "%", pd.max_wick_depth_n),
                 _ui_number_n(ss.max_wick_depth_stat, "%", ss.max_wick_depth_n), _ui_number_n(sd.max_wick_depth_stat, "%", sd.max_wick_depth_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Maximum Wick Test penetration of original width.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Ever Partially Consumed",
                 str.tostring(ps.ever_partially_consumed), str.tostring(pd.ever_partially_consumed), str.tostring(ss.ever_partially_consumed), str.tostring(sd.ever_partially_consumed),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Zones with accepted Partial history.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Partial-Consumption Share",
                 _ui_share_n(ps.ever_partially_consumed, ps.sampled_zones), _ui_share_n(pd.ever_partially_consumed, pd.sampled_zones),
                 _ui_share_n(ss.ever_partially_consumed, ss.sampled_zones), _ui_share_n(sd.ever_partially_consumed, sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Share of sampled zones that accepted at least one source close deeper inside the original rejected territory, contracting the live inner boundary without closing through the immutable outer boundary.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Max Partial",
                 _ui_number_n(ps.max_partial_stat, "%", ps.max_partial_n), _ui_number_n(pd.max_partial_stat, "%", pd.max_partial_n),
                 _ui_number_n(ss.max_partial_stat, "%", ss.max_partial_n), _ui_number_n(sd.max_partial_stat, "%", sd.max_partial_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Deepest accepted Partial penetration.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Direct Path",
                 str.tostring(ps.direct_path), str.tostring(pd.direct_path), str.tostring(ss.direct_path), str.tostring(sd.direct_path),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Consumed without prior Partial.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Direct / Consumed",
                 _ui_share_n(ps.direct_path, ps.consumed), _ui_share_n(pd.direct_path, pd.consumed),
                 _ui_share_n(ss.direct_path, ss.consumed), _ui_share_n(sd.direct_path, sd.consumed),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Of terminally Consumed zones, the share that reached Consumption without any prior accepted Partial. Direct can still be Untested Direct or Tested Direct depending on prior Wick Test history.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Remaining Before Fill",
                 _ui_number_n(ps.remaining_before_fill_stat, "%", ps.remaining_before_fill_n), _ui_number_n(pd.remaining_before_fill_stat, "%", pd.remaining_before_fill_n),
                 _ui_number_n(ss.remaining_before_fill_stat, "%", ss.remaining_before_fill_n), _ui_number_n(sd.remaining_before_fill_stat, "%", sd.remaining_before_fill_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Original width unresolved before terminal Consumption.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_swing_research
            _ui_section(research_table, research_row, "SWING AUTHORITY", "Later structural Swing qualification.", accentColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Swing Qualified",
                 str.tostring(ps.swing_qualified), str.tostring(pd.swing_qualified), str.tostring(ss.swing_qualified), str.tostring(sd.swing_qualified),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Zones later gaining XZ Swing authority.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Swing Share",
                 _ui_share_n(ps.swing_qualified, ps.sampled_zones), _ui_share_n(pd.swing_qualified, pd.sampled_zones),
                 _ui_share_n(ss.swing_qualified, ss.sampled_zones), _ui_share_n(sd.swing_qualified, sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Share of sampled zones whose origin was later promoted by canonical XZ Market Structure into Swing authority. This is a later structural classification, not a stronger-zone assumption at birth.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Active Swing",
                 str.tostring(ps.active_swing), str.tostring(pd.active_swing), str.tostring(ss.active_swing), str.tostring(sd.active_swing),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Unresolved Swing-qualified zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Consumed Swing",
                 str.tostring(ps.consumed_swing), str.tostring(pd.consumed_swing), str.tostring(ss.consumed_swing), str.tostring(sd.consumed_swing),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Consumed Swing-qualified zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Swing Consumed Share",
                 _ui_share_n(ps.consumed_swing, ps.swing_qualified), _ui_share_n(pd.consumed_swing, pd.swing_qualified),
                 _ui_share_n(ss.consumed_swing, ss.swing_qualified), _ui_share_n(sd.consumed_swing, sd.swing_qualified),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Within Swing-qualified zones only, the share that eventually became terminally Consumed. Compare with Non-Swing Consumed Share to inspect whether later structural authority changes persistence.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, "Non-Swing Consumed Share",
                 _ui_share_n(ps.consumed_non_swing, ps.non_swing), _ui_share_n(pd.consumed_non_swing, pd.non_swing),
                 _ui_share_n(ss.consumed_non_swing, ss.non_swing), _ui_share_n(sd.consumed_non_swing, sd.non_swing),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Within zones that never gained Swing authority, the share that eventually became terminally Consumed. Its denominator is intentionally separate from the Swing cohort.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Partial - Swing",
                 _ui_number_n(ps.swing_partial_stat, "%", ps.swing_partial_n), _ui_number_n(pd.swing_partial_stat, "%", pd.swing_partial_n),
                 _ui_number_n(ss.swing_partial_stat, "%", ss.swing_partial_n), _ui_number_n(sd.swing_partial_stat, "%", sd.swing_partial_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Partial depth in Swing-qualified zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Partial - Non-Swing",
                 _ui_number_n(ps.nonswing_partial_stat, "%", ps.nonswing_partial_n), _ui_number_n(pd.nonswing_partial_stat, "%", pd.nonswing_partial_n),
                 _ui_number_n(ss.nonswing_partial_stat, "%", ss.nonswing_partial_n), _ui_number_n(sd.nonswing_partial_stat, "%", sd.nonswing_partial_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Partial depth in non-Swing zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Consume Time - Swing",
                 _ui_number_n(ps.swing_consume_time_stat, "h", ps.swing_consume_time_n), _ui_number_n(pd.swing_consume_time_stat, "h", pd.swing_consume_time_n),
                 _ui_number_n(ss.swing_consume_time_stat, "h", ss.swing_consume_time_n), _ui_number_n(sd.swing_consume_time_stat, "h", sd.swing_consume_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Birth-to-Consumption hours for Swing zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
            _ui_source_row(research_table, research_row, statistic + " Consume Time - Non-Swing",
                 _ui_number_n(ps.nonswing_consume_time_stat, "h", ps.nonswing_consume_time_n), _ui_number_n(pd.nonswing_consume_time_stat, "h", pd.nonswing_consume_time_n),
                 _ui_number_n(ss.nonswing_consume_time_stat, "h", ss.nonswing_consume_time_n), _ui_number_n(sd.nonswing_consume_time_stat, "h", sd.nonswing_consume_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Among non-Swing zones that eventually consumed, this is how long they survived from origin to terminal source close. Compare against the Swing row to see whether later structural authority is associated with different persistence.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_chronology_research
            _ui_section(research_table, research_row, "EVENT CHRONOLOGY", "Timing between canonical zone events. Hours show real elapsed time; source bars show distance in the timeframe that actually owns the zone, making Primary/Secondary comparison meaningful.", accentColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Origin → Confirmation",
                 _ui_chronology_n(ps.origin_confirm_hours_stat, ps.origin_confirm_bars_stat, ps.origin_confirm_n), _ui_chronology_n(pd.origin_confirm_hours_stat, pd.origin_confirm_bars_stat, pd.origin_confirm_n),
                 _ui_chronology_n(ss.origin_confirm_hours_stat, ss.origin_confirm_bars_stat, ss.origin_confirm_n), _ui_chronology_n(sd.origin_confirm_hours_stat, sd.origin_confirm_bars_stat, sd.origin_confirm_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "How long the rejected turning point took to become a confirmed XZ S&D zone. Source bars count candles on the zone's own authority timeframe between origin and confirmation.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → First Wick Test",
                 _ui_chronology_n(ps.confirm_wick_hours_stat, ps.confirm_wick_bars_stat, ps.confirm_wick_n), _ui_chronology_n(pd.confirm_wick_hours_stat, pd.confirm_wick_bars_stat, pd.confirm_wick_n),
                 _ui_chronology_n(ss.confirm_wick_hours_stat, ss.confirm_wick_bars_stat, ss.confirm_wick_n), _ui_chronology_n(sd.confirm_wick_hours_stat, sd.confirm_wick_bars_stat, sd.confirm_wick_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones that were ever Wick Tested, how quickly price first returned into the original rejected territory after confirmation. Smaller source-bar values mean the zone was challenged sooner relative to its own timeframe.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → First Partial",
                 _ui_chronology_n(ps.confirm_partial_hours_stat, ps.confirm_partial_bars_stat, ps.confirm_partial_n), _ui_chronology_n(pd.confirm_partial_hours_stat, pd.confirm_partial_bars_stat, pd.confirm_partial_n),
                 _ui_chronology_n(ss.confirm_partial_hours_stat, ss.confirm_partial_bars_stat, ss.confirm_partial_n), _ui_chronology_n(sd.confirm_partial_hours_stat, sd.confirm_partial_bars_stat, sd.confirm_partial_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones that ever accepted a close deeper into rejected territory, time from confirmation to the first accepted Partial. This isolates the first committed contraction of the live inner boundary rather than a wick-only test.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → Swing Promotion",
                 _ui_chronology_n(ps.confirm_swing_hours_stat, ps.confirm_swing_bars_stat, ps.confirm_swing_n), _ui_chronology_n(pd.confirm_swing_hours_stat, pd.confirm_swing_bars_stat, pd.confirm_swing_n),
                 _ui_chronology_n(ss.confirm_swing_hours_stat, ss.confirm_swing_bars_stat, ss.confirm_swing_n), _ui_chronology_n(sd.confirm_swing_hours_stat, sd.confirm_swing_bars_stat, sd.confirm_swing_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Among zones later promoted to canonical XZ Swing authority, time from S&D confirmation to that structural promotion. This measures how long a local rejected turning point typically takes to become structurally authoritative.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → Consumption",
                 _ui_chronology_n(ps.confirm_consume_hours_stat, ps.confirm_consume_bars_stat, ps.confirm_consume_n), _ui_chronology_n(pd.confirm_consume_hours_stat, pd.confirm_consume_bars_stat, pd.confirm_consume_n),
                 _ui_chronology_n(ss.confirm_consume_hours_stat, ss.confirm_consume_bars_stat, ss.confirm_consume_n), _ui_chronology_n(sd.confirm_consume_hours_stat, sd.confirm_consume_bars_stat, sd.confirm_consume_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available, "Among terminally Consumed zones, time from confirmed zone creation to the authoritative source close through the immutable outer boundary. This excludes the pre-confirmation formation interval.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_pathways_research
            _ui_section(
                 research_table,
                 research_row,
                 "CONSUMPTION PATHWAYS",
                 "Terminal pathway classification uses events that occurred before the consuming candle. Untested Direct = no prior Wick Test and no prior Partial. Tested Direct = one or more prior Wick Tests and no prior Partial. Partial Path = one or more prior accepted Partial events. The terminal consuming candle itself is not retroactively counted as a prior Test.",
                 accentColor, bgColor, research_size
             )
            research_row += 1

            _ui_source_row(research_table, research_row, "Path Mix",
                 _ui_mix3("Untested", ps.untested_direct, "Tested", ps.tested_direct, "Partial", ps.partial_path, ps.consumed),
                 _ui_mix3("Untested", pd.untested_direct, "Tested", pd.tested_direct, "Partial", pd.partial_path, pd.consumed),
                 _ui_mix3("Untested", ss.untested_direct, "Tested", ss.tested_direct, "Partial", ss.partial_path, ss.consumed),
                 _ui_mix3("Untested", sd.untested_direct, "Tested", sd.tested_direct, "Partial", sd.partial_path, sd.consumed),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 "Share of consumed sampled zones ending through each canonical Consumption Pathway.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Untested Direct → Fill",
                 _ui_number_n(ps.untested_direct_time_stat, "h", ps.untested_direct_time_n), _ui_number_n(pd.untested_direct_time_stat, "h", pd.untested_direct_time_n),
                 _ui_number_n(ss.untested_direct_time_stat, "h", ss.untested_direct_time_n), _ui_number_n(sd.untested_direct_time_stat, "h", sd.untested_direct_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 statistic + " confirmation-to-Consumption hours for Untested Direct zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Tested Direct → Fill",
                 _ui_number_n(ps.tested_direct_time_stat, "h", ps.tested_direct_time_n), _ui_number_n(pd.tested_direct_time_stat, "h", pd.tested_direct_time_n),
                 _ui_number_n(ss.tested_direct_time_stat, "h", ss.tested_direct_time_n), _ui_number_n(sd.tested_direct_time_stat, "h", sd.tested_direct_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 statistic + " confirmation-to-Consumption hours for Tested Direct zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Partial Path → Fill",
                 _ui_number_n(ps.partial_path_time_stat, "h", ps.partial_path_time_n), _ui_number_n(pd.partial_path_time_stat, "h", pd.partial_path_time_n),
                 _ui_number_n(ss.partial_path_time_stat, "h", ss.partial_path_time_n), _ui_number_n(sd.partial_path_time_stat, "h", sd.partial_path_time_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 statistic + " confirmation-to-Consumption hours for Partial Path zones.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Tested Direct Wick Depth",
                 _ui_number_n(ps.tested_direct_wick_stat, "%", ps.tested_direct_wick_n), _ui_number_n(pd.tested_direct_wick_stat, "%", pd.tested_direct_wick_n),
                 _ui_number_n(ss.tested_direct_wick_stat, "%", ss.tested_direct_wick_n), _ui_number_n(sd.tested_direct_wick_stat, "%", sd.tested_direct_wick_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 statistic + " maximum prior Wick Test depth among Tested Direct zones before terminal Consumption.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Partial Path Depth",
                 _ui_number_n(ps.partial_path_depth_stat, "%", ps.partial_path_depth_n), _ui_number_n(pd.partial_path_depth_stat, "%", pd.partial_path_depth_n),
                 _ui_number_n(ss.partial_path_depth_stat, "%", ss.partial_path_depth_n), _ui_number_n(sd.partial_path_depth_stat, "%", sd.partial_path_depth_n),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 statistic + " deepest prior accepted Partial penetration among zones that ultimately consumed through the Partial Path.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_session_research
            string session_mix_tip =
                 "Event-time attribution under the selected Session Standard. Market-list percentages are membership shares: an event can belong to more than one market during overlaps, so SYD/TYO/LDN/NY shares can sum above 100%. OVL is the share occurring in an overlap of selected sessions. OFF means outside all selected sessions. Session Behaviour is observational only."

            string session_transition_tip =
                 "Same = both lifecycle events share at least one selected canonical session. Cross = both are inside selected sessions but share no session. Off = either event occurred outside all selected sessions. For Custom there is one configured session, so two in-session events are Same. Symbol Native is shown as N/A because TradingView regular-market bar membership cannot be reconstructed reliably from a stored timestamp alone."

            _ui_section(
                 research_table,
                 research_row,
                 "SESSION BEHAVIOUR",
                 "Where already-recorded lifecycle events occurred under the selected canonical Session Standard, plus whether lifecycle transitions remained inside a shared session or crossed between sessions. This does not require Session Context frames to be visible.",
                 accentColor, bgColor, research_size
             )
            research_row += 1

            _ui_source_row(research_table, research_row, "Origin Session",
                 _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 0, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation Session",
                 _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "First Wick Test Session",
                 _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "First Partial Session",
                 _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 3, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Consumption Session",
                 _session_mix_text(state, "Supply", "Primary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Primary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Supply", "Secondary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_mix_text(state, "Demand", "Secondary", research_sample_limit_live, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_mix_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Origin → Confirmation",
                 _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 0, 1, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → First Test",
                 _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 2, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Confirmation → Consumption",
                 _session_transition_text(state, "Supply", "Primary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Primary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Supply", "Secondary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 _session_transition_text(state, "Demand", "Secondary", research_sample_limit_live, 1, 4, sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork, sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly, symbolTimezone),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 session_transition_tip, textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

        if show_provenance_research
            _ui_section(research_table, research_row, "STRUCTURAL PROVENANCE", "Structural origin and later Swing-promotion context. Birth Pivot uses all sampled zones; Swing Family and Promotion State use Swing-qualified zones only.", accentColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Birth Pivot Mix",
                 _ui_mix3("H", ps.pivot_h, "HH", ps.pivot_hh, "LH", ps.pivot_lh, ps.sampled_zones),
                 _ui_mix3("L", pd.pivot_l, "LL", pd.pivot_ll, "HL", pd.pivot_hl, pd.sampled_zones),
                 _ui_mix3("H", ss.pivot_h, "HH", ss.pivot_hh, "LH", ss.pivot_lh, ss.sampled_zones),
                 _ui_mix3("L", sd.pivot_l, "LL", sd.pivot_ll, "HL", sd.pivot_hl, sd.sampled_zones),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 "Distribution of the canonical birth pivot class. H/L are baseline pivots; HH/LL and LH/HL are relational labels versus the previous same-type pivot.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "Swing Family Mix",
                 _ui_mix2("Trend", ps.trend_swing, "Chop", ps.chop_swing, ps.swing_qualified),
                 _ui_mix2("Trend", pd.trend_swing, "Chop", pd.chop_swing, pd.swing_qualified),
                 _ui_mix2("Trend", ss.trend_swing, "Chop", ss.chop_swing, ss.swing_qualified),
                 _ui_mix2("Trend", sd.trend_swing, "Chop", sd.chop_swing, sd.swing_qualified),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 "Among Swing-qualified zones only, shows whether canonical Swing authority was gained in Trend or Chop.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1

            _ui_source_row(research_table, research_row, "State at Swing Promotion",
                 _ui_mix3("Fresh", ps.swing_fresh_at_promotion, "Wick", ps.swing_wick_at_promotion, "Partial", ps.swing_partial_at_promotion, ps.swing_qualified),
                 _ui_mix3("Fresh", pd.swing_fresh_at_promotion, "Wick", pd.swing_wick_at_promotion, "Partial", pd.swing_partial_at_promotion, pd.swing_qualified),
                 _ui_mix3("Fresh", ss.swing_fresh_at_promotion, "Wick", ss.swing_wick_at_promotion, "Partial", ss.swing_partial_at_promotion, ss.swing_qualified),
                 _ui_mix3("Fresh", sd.swing_fresh_at_promotion, "Wick", sd.swing_wick_at_promotion, "Partial", sd.swing_partial_at_promotion, sd.swing_qualified),
                 research_compare_mode, research_secondary_mode, research_secondary_available,
                 "Lifecycle state at the exact Swing-promotion event: untouched Fresh, Wick Tested without accepted contraction, or already Partially Consumed.", textColor, supplyColor, demandColor, bgColor, research_size)
            research_row += 1
    else
        if not na(research_table)
            table.delete(research_table)
            research_table := na
            research_rows_live := na
            research_columns_live := na
            research_position_live := ""

    true
//==============================================================================
// EXPORTED ADAPTIVE RESEARCH RENDERER
//==============================================================================

//@function Keeps individual Research sections as one table, but automatically turns All Sections into two coordinated bottom-corner dashboard panels.
export renderAdaptiveLab(
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
    bool dashboard_mode = showLab and section == "All Sections"
    bool single_mode = showLab and not dashboard_mode

    // Written call #1 owns the ordinary user-position table and deletes it in dashboard mode.
    renderLab(
         state, single_mode, source, section, statistic, tablePosition, textSizeName,
         bgColor, textColor, accentColor, showLines, lineColor, supplyColor, demandColor,
         primaryTimeframe, secondaryTimeframe, secondaryEnabled, secondaryConfigured,
         secondaryIsHigher, nowTime, sampleLimit,
         sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork,
         sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly,
         symbolTimezone
     )

    // Written call #2 owns dashboard left: Lifecycle / Interaction / Chronology / Pathways.
    renderLab(
         state, dashboard_mode, source, "Dashboard Left", statistic, "bottom_left", textSizeName,
         bgColor, textColor, accentColor, showLines, lineColor, supplyColor, demandColor,
         primaryTimeframe, secondaryTimeframe, secondaryEnabled, secondaryConfigured,
         secondaryIsHigher, nowTime, sampleLimit,
         sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork,
         sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly,
         symbolTimezone
     )

    // Written call #3 owns dashboard right: Swing / Session Behaviour / Structural Provenance.
    renderLab(
         state, dashboard_mode, source, "Dashboard Right", statistic, "bottom_right", textSizeName,
         bgColor, textColor, accentColor, showLines, lineColor, supplyColor, demandColor,
         primaryTimeframe, secondaryTimeframe, secondaryEnabled, secondaryConfigured,
         secondaryIsHigher, nowTime, sampleLimit,
         sessionStandard, sessionShowSydney, sessionShowTokyo, sessionShowLondon, sessionShowNewYork,
         sessionCustomOpen, sessionCustomClose, sessionCustomTimezone, sessionCustomWeekdaysOnly,
         symbolTimezone
     )

    true
````
