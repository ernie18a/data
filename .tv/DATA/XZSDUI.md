<!-- tradingview-pine-id: PUB;d8c1796453e2487e8efbc794e8eca0b9 -->
<!-- tradingview-pine-version: 8.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_SD_UI

Source: https://www.tradingview.com/script/RP9J3AGU-XZ-SD-UI/

## Description

Library  "XZ_SD_UI"
XZ S&D UI v1. Presentation-only support library for XZ Supply & Demand Status, Quick Read and Glossary. It receives already-decided operational strings/state from the protected indicator and never creates, qualifies, partially consumes or consumes S&D zones.

renderStatus(show_status_table, status_table_mode, table_position, table_text_size, table_bg_color, table_text_color, table_accent_color, status_show_lines, status_line_color, resolved_table_supply_color, resolved_table_demand_color, primary_status, secondary_status, secondary_tf_enabled, show_secondary_tf, secondary_tf_is_higher, secondary_tf_label_input, zone_horizon, zone_display_scope, horizon_start_text, show_session_context, session_context_text_input, session_standard)
  Renders/removes the operational Status table from already-decided source snapshots.
  Parameters:
    show_status_table (bool)
    status_table_mode (simple string)
    table_position (simple string)
    table_text_size (simple string)
    table_bg_color (color)
    table_text_color (color)
    table_accent_color (color)
    status_show_lines (bool)
    status_line_color (color)
    resolved_table_supply_color (color)
    resolved_table_demand_color (color)
    primary_status (StatusSource)
    secondary_status (StatusSource)
    secondary_tf_enabled (bool)
    show_secondary_tf (bool)
    secondary_tf_is_higher (bool)
    secondary_tf_label_input (simple string)
    zone_horizon (simple string)
    zone_display_scope (simple string)
    horizon_start_text (simple string)
    show_session_context (bool)
    session_context_text_input (simple string)
    session_standard (simple string)

renderQuickRead(show_quick_read, quick_read_position, quick_read_text_size, quick_read_bg_color, quick_read_text_color, quick_read_show_lines, quick_read_line_color)
  Renders/removes the XZ S&D Quick Read onboarding table.
  Parameters:
    show_quick_read (bool)
    quick_read_position (simple string)
    quick_read_text_size (simple string)
    quick_read_bg_color (color)
    quick_read_text_color (color)
    quick_read_show_lines (bool)
    quick_read_line_color (color)

renderGlossary(show_glossary, glossary_position, glossary_text_size)
  Renders/removes the XZ S&D chart glossary.
  Parameters:
    show_glossary (bool)
    glossary_position (simple string)
    glossary_text_size (simple string)

StatusSource
  Fields:
    section_label (series string)
    tf_label (series string)
    lifecycle_authority (series string)
    supply_zones (series string)
    demand_zones (series string)
    supply_immediate (series string)
    demand_immediate (series string)
    supply_state (series string)
    demand_state (series string)
    supply_interaction (series string)
    demand_interaction (series string)
    supply_distance (series string)
    demand_distance (series string)
    supply_swing_layer (series string)
    demand_swing_layer (series string)
    supply_swing_state (series string)
    demand_swing_state (series string)
    supply_immediate_authority (series string)
    demand_immediate_authority (series string)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ S&D UI v8. Full language-authority audit. v7 makes zone timing exact at source-close authority, distinguishes consumed-history display role from active hierarchy, and tightens onboarding/Status terminology without changing S&D decisions.
library("XZ_SD_UI", false)

//==============================================================================
// OWNERSHIP CONTRACT
//==============================================================================
// OWNED HERE
// - Status table lifecycle, Expanded/Collapsed rendering and Status tooltips.
// - Quick Read table lifecycle/content.
// - Glossary table lifecycle/content.
// - Zone drawing, zone-hover presentation and tooltip formatting.
// - Display-candidate ranking / presentation priority.
//
// NOT OWNED HERE
// - S&D formation or rejected-territory geometry.
// - Pivot / Trend / MSB / BOS / CHoCH / Swing decisions.
// - Primary or Secondary lifecycle authority.
// - Research calculations/storage.
// - Session clocks/runtime.
// - Alerts.
//
// The protected indicator supplies already-decided StatusSource values.
//==============================================================================

const color UI_GOLD = #B8860B
const color UI_GRAPHITE = #1E222D
const color UI_GRID = #373A46

export type StatusSource
    string section_label
    string tf_label
    string lifecycle_authority
    string supply_zones
    string demand_zones
    string supply_immediate
    string demand_immediate
    string supply_state
    string demand_state
    string supply_interaction
    string demand_interaction
    string supply_distance
    string demand_distance
    string supply_swing_layer
    string demand_swing_layer
    string supply_swing_state
    string demand_swing_state
    string supply_immediate_authority
    string demand_immediate_authority


export type ZoneView
    string side
    bool secondary
    bool filled
    bool immediate
    bool swing
    string swing_family
    string state
    string interaction
    int birth_time
    int confirmation_time
    int origin_event_time
    int confirmation_event_time
    int zone_id
    string pivot_class
    string source_context
    string source_timeframe
    float original_lower
    float original_upper
    float current_lower
    float current_upper
    bool consumed
    int consumed_time
    int consumed_event_time
    string consumption_pathway
    float partial_pct
    float wick_pct
    bool wick_tested
    int wick_test_event_count
    int partial_event_count

export type DisplayState
    array<box> boxes
    array<label> tooltip_labels


export type Candidate
    string zone_type
    int array_idx
    int birth_time

export type CandidatePool
    array<Candidate> items
    array<float> scores

_tf_label(string tf) =>
    string result = tf
    float numeric_minutes = str.tonumber(tf)
    if not na(numeric_minutes)
        int total_minutes = int(numeric_minutes)
        result := total_minutes > 0 and total_minutes % 60 == 0 ? str.tostring(int(total_minutes / 60)) + "H" : str.tostring(total_minutes) + "m"
    else
        result := tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf
    result

_zone_percent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.0") + "%"

_zone_range(float lower, float upper) =>
    str.tostring(lower, format.mintick) + " - " + str.tostring(upper, format.mintick)

_zone_timezone_label(string timezone_name) =>
    // Display-only cleanup. Keep the raw TradingView timezone identifier for
    // str.format_time() calculations, but do not expose "Etc/UTC" / "Etc/GMT"
    // namespace text in chart-facing hover copy.
    timezone_name == "Etc/UTC" or timezone_name == "Etc/GMT" ? "UTC" : timezone_name

_zone_timestamp(int value, string timezone_name) =>
    string timezone_label = _zone_timezone_label(timezone_name)
    na(value) ? "N/A" : str.format_time(value, "yyyy-MM-dd HH:mm", timezone_name) + " " + timezone_label

_zone_age(int start_time, int end_time) =>
    float hours = na(start_time) or na(end_time) ? na : (end_time - start_time) / 3600000.0
    na(hours) ? "N/A" : hours < 24.0 ? str.tostring(hours, "#.##") + "h" : str.tostring(hours / 24.0, "#.##") + "d"

_zone_tooltip(ZoneView zone, string timezone_name) =>
    float remaining = na(zone.partial_pct) ? na : 100.0 - zone.partial_pct
    string structural_authority = zone.swing ? (str.length(zone.swing_family) > 0 ? zone.swing_family + " Swing" : "Swing") : "Pivot"
    string display_role = zone.filled ? "Consumed History" : zone.immediate ? "Immediate" : zone.swing ? "Swing Layer" : "Map"
    int origin_close_time = not na(zone.origin_event_time) ? zone.origin_event_time : zone.birth_time
    int confirmed_close_time = not na(zone.confirmation_event_time) ? zone.confirmation_event_time : zone.confirmation_time
    string state_line = zone.state

    if zone.state == "Partially Consumed"
        state_line += " · " + _zone_percent(zone.partial_pct)
    else if zone.state == "Wick Tested"
        state_line += " · max wick " + _zone_percent(zone.wick_pct)

    string core =
         "XZ S&D · " + zone.side + "\n" +
         "State: " + state_line + "\n" +
         "Current Interaction: " + zone.interaction + "\n" +
         "Structural Authority: " + structural_authority + "\n" +
         "Display Role: " + display_role + "\n" +
         "Origin Bar: " + _zone_timestamp(zone.birth_time, timezone_name) + "\n" +
         "Origin Close: " + _zone_timestamp(origin_close_time, timezone_name) + "\n" +
         "Confirmation Close: " + _zone_timestamp(confirmed_close_time, timezone_name) + "\n" +
         "Zone Identity: #" + str.tostring(zone.zone_id) + " · Pivot " + zone.pivot_class + " · " + zone.source_context + " " + _tf_label(zone.source_timeframe) + "\n" +
         "Original Zone: " + _zone_range(zone.original_lower, zone.original_upper) + "\n" +
         (zone.consumed ? "Final Live Zone: " : "Remaining Zone: ") + _zone_range(zone.current_lower, zone.current_upper)

    if zone.consumed
        core += "\nMax Partial Before Consumption: " + _zone_percent(zone.partial_pct)
        core += "\nRemaining Before Consumption: " + _zone_percent(remaining)
        if zone.wick_tested
            core += "\nMax Wick Test Before Consumption: " + _zone_percent(zone.wick_pct)
        core += "\nConsumption Confirmed: " + _zone_timestamp(zone.consumed_event_time, timezone_name)
        core += "\nPathway: " + zone.consumption_pathway
        core += "\nAge to Consumption: " + _zone_age(zone.birth_time, zone.consumed_event_time)
    else
        core += "\nRemaining: " + _zone_percent(remaining)
        if zone.wick_tested
            core += "\nMax Wick Test: " + _zone_percent(zone.wick_pct)

    if zone.swing
        core += "\nSwing Family: " + zone.swing_family
    if zone.wick_test_event_count > 0
        core += "\nWick Test Events: " + str.tostring(zone.wick_test_event_count)
    if zone.partial_event_count > 0
        core += "\nPartial Events: " + str.tostring(zone.partial_event_count)

    string result = core
    if zone.secondary
        string tf_label = _tf_label(zone.source_timeframe)
        result := "XZ S&D · Secondary " + tf_label + " · " + zone.side + "\n" +
             "Lifecycle Authority: confirmed " + tf_label + " source closes\n" +
             "Current Interaction: live chart price only\n\n" + core
    result

_position(string name) =>
    switch name
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.top_right

_text_size(string name) =>
    switch name
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.normal

_collapsed_metric(string interaction, string distance_text) =>
    interaction == "Breach Pending" ? "BREACH" : interaction == "Testing" ? "TEST" : distance_text

_status_tips(table target, int row, string supply_tip, string demand_tip) =>
    table.cell_set_tooltip(target, 1, row, supply_tip)
    table.cell_set_tooltip(target, 2, row, demand_tip)
    true

_status_source_section(
     table target,
     int section_row,
     StatusSource source,
     string text_size,
     color bg_color,
     color text_color,
     color accent_color,
     color supply_color,
     color demand_color
 ) =>
    table.cell(target, 0, section_row, source.section_label, text_color = accent_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell_set_tooltip(target, 0, section_row, source.lifecycle_authority)

    int row = section_row + 1

    table.cell(target, 0, row, "Zones", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_zones, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_zones, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Supply Zones: " + source.supply_zones + "\nActive = unresolved zones admitted by Zone Horizon. Shown = boxes actually rendered after Display Scope and the shared box budget.",
         source.section_label + " Demand Zones: " + source.demand_zones + "\nActive = unresolved zones admitted by Zone Horizon. Shown = boxes actually rendered after Display Scope and the shared box budget.")

    row += 1
    table.cell(target, 0, row, "Immediate", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_immediate, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_immediate, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Immediate Supply: " + source.supply_immediate + "\nNearest active Supply zone by price proximity inside Zone Horizon.\nStructural Authority: " + source.supply_immediate_authority + "\n" + source.lifecycle_authority,
         source.section_label + " Immediate Demand: " + source.demand_immediate + "\nNearest active Demand zone by price proximity inside Zone Horizon.\nStructural Authority: " + source.demand_immediate_authority + "\n" + source.lifecycle_authority)

    row += 1
    table.cell(target, 0, row, "State", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_state, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_state, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Immediate Supply State: " + source.supply_state + "\nFresh = no committed post-confirmation Wick Test or Partial Consumption. Wick Tested = completed wick exploration without accepted contraction. Partial = an authoritative source close advanced the live inner boundary. Live Testing/Breach Pending can coexist with the last committed State.\n" + source.lifecycle_authority,
         source.section_label + " Immediate Demand State: " + source.demand_state + "\nFresh = no committed post-confirmation Wick Test or Partial Consumption. Wick Tested = completed wick exploration without accepted contraction. Partial = an authoritative source close advanced the live inner boundary. Live Testing/Breach Pending can coexist with the last committed State.\n" + source.lifecycle_authority)

    row += 1
    table.cell(target, 0, row, "Interaction", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_interaction, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_interaction, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Supply Interaction: " + source.supply_interaction + "\nOutside Zone = current candle has not tested the zone. Testing = the candle has traded into original rejected territory without current live price remaining through the immutable outer boundary. Breach Pending = live price is currently above the Supply outer boundary, but Consumption is unconfirmed until the authoritative source close. State remains the last committed lifecycle.",
         source.section_label + " Demand Interaction: " + source.demand_interaction + "\nOutside Zone = current candle has not tested the zone. Testing = the candle has traded into original rejected territory without current live price remaining through the immutable outer boundary. Breach Pending = live price is currently below the Demand outer boundary, but Consumption is unconfirmed until the authoritative source close. State remains the last committed lifecycle.")

    row += 1
    table.cell(target, 0, row, "Distance", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_distance, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_distance, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Immediate Supply Distance: " + source.supply_distance + "\nPercentage distance from current chart close to the nearest live Supply edge. Interaction should be read first: TEST/BREACH in Collapsed Status intentionally overrides the distance because live zone interaction is the more important operational fact.",
         source.section_label + " Immediate Demand Distance: " + source.demand_distance + "\nPercentage distance from current chart close to the nearest live Demand edge. Interaction should be read first: TEST/BREACH in Collapsed Status intentionally overrides the distance because live zone interaction is the more important operational fact.")

    row += 1
    table.cell(target, 0, row, "Swing Layer", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_swing_layer, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_swing_layer, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Supply Swing Layer: " + source.supply_swing_layer + "\nNext distinct active Supply zone whose origin gained canonical XZ Swing authority. If Immediate itself is Swing and no distinct next layer exists, that is stated explicitly.",
         source.section_label + " Demand Swing Layer: " + source.demand_swing_layer + "\nNext distinct active Demand zone whose origin gained canonical XZ Swing authority. If Immediate itself is Swing and no distinct next layer exists, that is stated explicitly.")

    row += 1
    table.cell(target, 0, row, "Swing State", text_color = text_color, text_size = text_size, text_halign = text.align_left, bgcolor = bg_color)
    table.cell(target, 1, row, source.supply_swing_state, text_color = supply_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    table.cell(target, 2, row, source.demand_swing_state, text_color = demand_color, text_size = text_size, text_halign = text.align_right, bgcolor = bg_color)
    _status_tips(target, row,
         source.section_label + " Supply Swing State: " + source.supply_swing_state + "\nTrend/Chop identifies canonical Swing family; the remaining text is current zone lifecycle state.",
         source.section_label + " Demand Swing State: " + source.demand_swing_state + "\nTrend/Chop identifies canonical Swing family; the remaining text is current zone lifecycle state.")

    true

_glossary_entry(table target, int key_col, int term_col, int row, string key_text, string full_term, string tip, string text_size) =>
    table.cell(target, key_col, row, key_text, text_color = UI_GOLD, text_size = text_size, text_halign = text.align_left, bgcolor = UI_GRAPHITE)
    table.cell(target, term_col, row, full_term, text_color = color.white, text_size = text_size, text_halign = text.align_left, bgcolor = UI_GRAPHITE)
    table.cell_set_tooltip(target, key_col, row, tip)
    true




//==============================================================================
// EXPORTED DISPLAY CANDIDATE POLICY / RANKING
// Presentation-only: caller supplies already-decided Immediate/Swing/Horizon facts.
//==============================================================================

//@function Creates reusable candidate/ranking storage for last-bar display preparation.
export newCandidatePool() =>
    CandidatePool.new(array.new<Candidate>(), array.new_float())

//@function Clears one reusable display candidate pool.
export clearCandidates(CandidatePool pool) =>
    array.clear(pool.items)
    array.clear(pool.scores)
    true

//@function Applies the user-selected Display Scope to already-decided hierarchy flags.
export scopeAllows(string display_scope, bool is_immediate, bool is_swing) =>
    display_scope == "Full Map" ? true :
     display_scope == "Immediate + Swing" ? (is_immediate or is_swing) :
     display_scope == "Immediate Only" ? is_immediate :
     display_scope == "Swing Map" ? is_swing :
     false

//@function Adds one already-admitted display candidate and assigns presentation priority.
// Immediate > Swing > ordinary active > filled history; newer wins inside equal priority.
export addCandidate(
     CandidatePool pool,
     string zone_type,
     int array_idx,
     int birth_time,
     bool is_immediate,
     bool is_swing,
     bool is_filled
 ) =>
    int priority = is_filled ? 0 : is_immediate ? 3 : is_swing ? 2 : 1
    array.push(pool.items, Candidate.new(zone_type, array_idx, birth_time))
    array.push(pool.scores, float(priority) * 1e15 + float(birth_time))
    true

//@function Returns candidate indexes ordered by presentation priority/newness.
export rankedIndices(CandidatePool pool) =>
    array.sort_indices(pool.scores, order.descending)

//@function Returns one stored candidate by pool index.
export getCandidate(CandidatePool pool, int candidate_index) =>
    array.get(pool.items, candidate_index)

//@function Returns how many ranked candidates may render after the caller supplies remaining box budget.
export budgetedCount(array<int> ranked_indices, int available_boxes) =>
    math.min(array.size(ranked_indices), math.max(0, available_boxes))

//==============================================================================
// EXPORTED GENERIC DISPLAY FORMATTERS
//==============================================================================

//@function Compact mintick-formatted price range.
export formatRange(float lower, float upper) =>
    str.tostring(lower, format.mintick) + " - " + str.tostring(upper, format.mintick)

//@function Percentage display string.
export formatPercent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.0") + "%"

//@function TradingView timeframe string -> compact XZ display label.
export formatTimeframe(string tf) =>
    _tf_label(tf)

//@function Signed Status distance as a percentage of supplied reference price.
export formatDistance(float distance_value, float reference_price, bool is_supply) =>
    string result = "N/A"
    if not na(distance_value)
        if distance_value == 0.0
            result := "0.00%"
        else if reference_price != 0.0
            float pct = 100.0 * distance_value / math.abs(reference_price)
            result := (is_supply ? "+" : "-") + str.tostring(pct, "#.##") + "%"
    result

//@function Presentation state string; Partial receives its already-calculated depth.
export statusState(string lifecycle_state, float partial_pct) =>
    lifecycle_state == "Partially Consumed" ? "Partial " + formatPercent(partial_pct) : lifecycle_state

//@function Presentation-only structural authority label.
export authority(bool is_swing, string swing_family) =>
    is_swing ? (str.length(swing_family) > 0 ? swing_family + " Swing" : "Swing") : "Pivot"

//@function Presentation-only Swing family + lifecycle state.
export swingState(string swing_family, string status_state) =>
    string family = str.length(swing_family) > 0 ? swing_family : "Swing"
    family + " · " + status_state

//@function Creates persistent zone-display object storage owned by the UI library.
export newDisplayState() =>
    DisplayState.new(array.new<box>(), array.new<label>())

//@function Deletes all currently rendered S&D zone boxes and hover markers.
export clearZoneDisplay(DisplayState state) =>
    if array.size(state.boxes) > 0
        for i = array.size(state.boxes) - 1 to 0
            box.delete(array.get(state.boxes, i))
        array.clear(state.boxes)

    if array.size(state.tooltip_labels) > 0
        for i = array.size(state.tooltip_labels) - 1 to 0
            label.delete(array.get(state.tooltip_labels, i))
        array.clear(state.tooltip_labels)
    true

//@function Draws one already-selected S&D zone. The protected indicator decides selection, lifecycle and structural authority before this call.
export drawZone(
     DisplayState state,
     ZoneView zone,
     int active_right_time,
     bool extend_active,
     bool show_tooltip,
     color primary_supply_color,
     color primary_demand_color,
     color filled_supply_color,
     color filled_demand_color,
     color supply_marker_color,
     color demand_marker_color,
     int secondary_zone_transparency,
     int secondary_border_transparency,
     string timezone_name
 ) =>
    bool supply = zone.side == "Supply"
    color marker_color = supply ? supply_marker_color : demand_marker_color
    color bg_color = na
    color border_color = na
    string border_style = line.style_solid
    string box_extend = extend.none
    int right_time = zone.filled ? zone.consumed_time : active_right_time

    if zone.secondary
        if zone.filled
            bg_color := color.new(marker_color, 97)
            border_color := color.new(marker_color, 85)
            border_style := line.style_dashed
        else
            int fill_alpha = zone.immediate ? math.max(75, secondary_zone_transparency - 8) : zone.swing ? math.max(75, secondary_zone_transparency - 4) : secondary_zone_transparency
            bg_color := color.new(marker_color, fill_alpha)
            border_color := color.new(marker_color, secondary_border_transparency)
            border_style := line.style_dashed
            box_extend := extend_active ? extend.right : extend.none
    else
        if zone.filled
            bg_color := supply ? filled_supply_color : filled_demand_color
        else
            color base_color = supply ? primary_supply_color : primary_demand_color
            bg_color := zone.immediate ? color.new(base_color, 72) : zone.swing ? color.new(base_color, 80) : base_color
            box_extend := extend_active ? extend.right : extend.none

    box bx = box.new(
         left = zone.birth_time,
         top = zone.current_upper,
         right = right_time,
         bottom = zone.current_lower,
         border_color = border_color,
         border_width = 1,
         border_style = border_style,
         extend = box_extend,
         xloc = xloc.bar_time,
         bgcolor = bg_color
     )
    array.push(state.boxes, bx)

    if show_tooltip
        label marker = label.new(
             zone.birth_time,
             (zone.current_upper + zone.current_lower) / 2.0,
             "ⓘ",
             xloc = xloc.bar_time,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = color.new(marker_color, 20),
             size = size.tiny,
             tooltip = _zone_tooltip(zone, timezone_name)
         )
        array.push(state.tooltip_labels, marker)

    true

//@function Number of zone boxes currently rendered by this state.
export zoneBoxCount(DisplayState state) =>
    array.size(state.boxes)

//@function Renders/removes the operational Status table from already-decided source snapshots.
export renderStatus(
     bool show_status_table,
     simple string status_table_mode,
     simple string table_position,
     simple string table_text_size,
     color table_bg_color,
     color table_text_color,
     color table_accent_color,
     bool status_show_lines,
     color status_line_color,
     color resolved_table_supply_color,
     color resolved_table_demand_color,
     StatusSource primary_status,
     StatusSource secondary_status,
     bool secondary_tf_enabled,
     bool show_secondary_tf,
     bool secondary_tf_is_higher,
     string secondary_tf_label_input,
     simple string zone_horizon,
     simple string zone_display_scope,
     string horizon_start_text,
     bool show_session_context,
     string session_context_text_input,
     simple string session_standard
 ) =>
    var table status_table = na
    var int status_rows_live = na
    var int status_columns_live = na
    var string status_position_live = ""

    if show_status_table
        bool status_secondary_valid = secondary_tf_enabled
        bool status_secondary_invalid = show_secondary_tf and not secondary_tf_is_higher

        int desired_status_columns = status_table_mode == "Collapsed" ? 5 : 3
        int desired_status_rows = status_table_mode == "Collapsed" ? 1 : status_secondary_valid ? 19 : status_secondary_invalid ? 12 : 11

        if na(status_table) or status_rows_live != desired_status_rows or status_columns_live != desired_status_columns or status_position_live != table_position
            if not na(status_table)
                table.delete(status_table)

            status_table := table.new(
                 _position(table_position),
                 desired_status_columns,
                 desired_status_rows,
                 bgcolor = table_bg_color,
                 border_color = status_line_color,
                 border_width = status_show_lines ? 1 : 0,
                 frame_color = status_line_color,
                 frame_width = status_show_lines ? 1 : 0
             )

            if status_table_mode == "Expanded"
                table.merge_cells(status_table, 0, 0, 1, 0)
                table.merge_cells(status_table, 1, 1, 2, 1)
                table.merge_cells(status_table, 0, 3, 2, 3)
                if status_secondary_valid or status_secondary_invalid
                    table.merge_cells(status_table, 0, 11, 2, 11)

            status_rows_live := desired_status_rows
            status_columns_live := desired_status_columns
            status_position_live := table_position

        txt_size = _text_size(table_text_size)

        string primary_tf_label = primary_status.tf_label
        string secondary_tf_label = secondary_tf_label_input

        if status_table_mode == "Collapsed"
            string primary_supply_metric = _collapsed_metric(primary_status.supply_interaction, primary_status.supply_distance)
            string primary_demand_metric = _collapsed_metric(primary_status.demand_interaction, primary_status.demand_distance)

            string collapsed_supply = "P " + primary_tf_label + " " + primary_status.supply_immediate + " · " + primary_supply_metric
            string collapsed_demand = "P " + primary_tf_label + " " + primary_status.demand_immediate + " · " + primary_demand_metric

            if status_secondary_valid
                string secondary_supply_metric = _collapsed_metric(secondary_status.supply_interaction, secondary_status.supply_distance)
                string secondary_demand_metric = _collapsed_metric(secondary_status.demand_interaction, secondary_status.demand_distance)
                collapsed_supply += "\nS " + secondary_status.tf_label + " " + secondary_status.supply_immediate + " · " + secondary_supply_metric
                collapsed_demand += "\nS " + secondary_status.tf_label + " " + secondary_status.demand_immediate + " · " + secondary_demand_metric
            else if status_secondary_invalid
                collapsed_supply += "\nS invalid TF"
                collapsed_demand += "\nS invalid TF"

            table.cell(status_table, 0, 0, "XZ S&D", text_color = table_accent_color, text_size = txt_size, text_halign = text.align_left, bgcolor = table_bg_color)
            table.cell(status_table, 1, 0, "S", text_color = table_text_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell(status_table, 2, 0, collapsed_supply, text_color = resolved_table_supply_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell(status_table, 3, 0, "D", text_color = table_text_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell(status_table, 4, 0, collapsed_demand, text_color = resolved_table_demand_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)

            table.cell_set_tooltip(status_table, 0, 0, "Collapsed source-parity live map. P = Primary chart timeframe. S = Secondary source when enabled. Each line shows Immediate range plus distance while outside. TEST replaces distance while the current candle is testing original rejected territory. BREACH replaces it when live price is currently through the immutable outer boundary but source-close consumption confirmation is still pending. Directional colours remain semantic Supply/Demand colours unless table accents are synced to Unified Color.")

            string collapsed_supply_tip = "Primary " + primary_tf_label + " Supply\nImmediate: " + primary_status.supply_immediate + "\nState: " + primary_status.supply_state + "\nInteraction: " + primary_status.supply_interaction + "\nDistance: " + primary_status.supply_distance
            string collapsed_demand_tip = "Primary " + primary_tf_label + " Demand\nImmediate: " + primary_status.demand_immediate + "\nState: " + primary_status.demand_state + "\nInteraction: " + primary_status.demand_interaction + "\nDistance: " + primary_status.demand_distance

            if status_secondary_valid
                collapsed_supply_tip += "\n\nSecondary " + secondary_status.tf_label + " Supply\nImmediate: " + secondary_status.supply_immediate + "\nState: " + secondary_status.supply_state + "\nInteraction: " + secondary_status.supply_interaction + "\nDistance: " + secondary_status.supply_distance + "\n" + secondary_status.lifecycle_authority
                collapsed_demand_tip += "\n\nSecondary " + secondary_status.tf_label + " Demand\nImmediate: " + secondary_status.demand_immediate + "\nState: " + secondary_status.demand_state + "\nInteraction: " + secondary_status.demand_interaction + "\nDistance: " + secondary_status.demand_distance + "\n" + secondary_status.lifecycle_authority
            else if status_secondary_invalid
                collapsed_supply_tip += "\n\nSecondary invalid: selected Secondary timeframe must be strictly higher than chart timeframe."
                collapsed_demand_tip += "\n\nSecondary invalid: selected Secondary timeframe must be strictly higher than chart timeframe."

            table.cell_set_tooltip(status_table, 2, 0, collapsed_supply_tip)
            table.cell_set_tooltip(status_table, 4, 0, collapsed_demand_tip)

        else
            string session_context_text = session_context_text_input
            string secondary_context_text = not show_secondary_tf ? "Secondary Off" : status_secondary_valid ? "Secondary " + secondary_tf_label : "Secondary TF must be > chart"
            string context_text = zone_horizon + " · " + zone_display_scope + (show_session_context ? " · " + session_context_text : "") + (show_secondary_tf ? " · " + secondary_context_text : "")

            table.cell(status_table, 0, 0, "XZ S&D - STATUS", text_color = table_accent_color, text_size = txt_size, text_halign = text.align_left, bgcolor = table_bg_color)
            table.cell(status_table, 2, 0, "LIVE MAP", text_color = table_text_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell_set_tooltip(status_table, 0, 0, "Current operational XZ S&D environment. Status is deliberately live and glanceable; population statistics, event chronology and historical comparisons belong in Research.")

            table.cell(status_table, 0, 1, "Context", text_color = table_text_color, text_size = txt_size, text_halign = text.align_left, bgcolor = table_bg_color)
            table.cell(status_table, 1, 1, context_text, text_color = table_text_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)

            string context_tip = "Zone Horizon: " + zone_horizon +
                 "\nResolved Horizon Start: " + horizon_start_text +
                 "\nDisplay Scope: " + zone_display_scope +
                 "\nPrimary Source: " + primary_tf_label +
                 "\nPrimary Lifecycle Authority: confirmed chart-timeframe closes." +
                 "\nSession Context: " + session_context_text +
                 "\nSession Standard: " + session_standard

            if status_secondary_valid
                context_tip += "\nSecondary Source: " + secondary_tf_label +
                     "\nSecondary Lifecycle Authority: confirmed " + secondary_tf_label + " source closes." +
                     "\nSecondary Interaction/Distance: live chart price only."
            else if status_secondary_invalid
                context_tip += "\nSecondary: INVALID — selected timeframe must be strictly higher than chart timeframe."
            else
                context_tip += "\nSecondary: Off"

            context_tip += "\nHorizon and Session Context are presentation/observation layers only. Primary and Secondary lifecycles remain independent."

            table.cell_set_tooltip(status_table, 1, 1, context_tip)

            table.cell(status_table, 0, 2, "Metric", text_color = table_text_color, text_size = txt_size, text_halign = text.align_left, bgcolor = table_bg_color)
            table.cell(status_table, 1, 2, "Supply", text_color = resolved_table_supply_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell(status_table, 2, 2, "Demand", text_color = resolved_table_demand_color, text_size = txt_size, text_halign = text.align_right, bgcolor = table_bg_color)
            table.cell_set_tooltip(status_table, 0, 2, "Each enabled source receives the same operational Supply/Demand rows. Status does not mix the independent Primary and Secondary populations.")

            _status_source_section(status_table, 3, primary_status, txt_size, table_bg_color, table_text_color, table_accent_color, resolved_table_supply_color, resolved_table_demand_color)

            if status_secondary_valid
                _status_source_section(status_table, 11, secondary_status, txt_size, table_bg_color, table_text_color, table_accent_color, resolved_table_supply_color, resolved_table_demand_color)
            else if status_secondary_invalid
                table.cell(status_table, 0, 11, "SECONDARY · INVALID — " + secondary_tf_label + " must be > " + primary_tf_label, text_color = table_accent_color, text_size = txt_size, text_halign = text.align_left, bgcolor = table_bg_color)
                table.cell_set_tooltip(status_table, 0, 11, "Secondary S&D is inactive because its selected source timeframe must be strictly higher than the chart timeframe. This validation protects source-candle reconstruction and lifecycle authority.")

    else
        if not na(status_table)
            table.delete(status_table)
            status_table := na
            status_rows_live := na
            status_columns_live := na
            status_position_live := ""

    true


//@function Renders/removes the XZ S&D Quick Read onboarding table.
export renderQuickRead(
     bool show_quick_read,
     simple string quick_read_position,
     simple string quick_read_text_size,
     color quick_read_bg_color,
     color quick_read_text_color,
     bool quick_read_show_lines,
     color quick_read_line_color
 ) =>
    var table quick_read_table = na
    var string quick_read_position_live = ""

    if show_quick_read
        if na(quick_read_table) or quick_read_position_live != quick_read_position
            if not na(quick_read_table)
                table.delete(quick_read_table)
            quick_read_table := table.new(
                 _position(quick_read_position),
                 1,
                 2,
                 bgcolor = quick_read_bg_color,
                 border_color = quick_read_line_color,
                 border_width = quick_read_show_lines ? 1 : 0,
                 frame_color = quick_read_line_color,
                 frame_width = quick_read_show_lines ? 1 : 0
             )
            quick_read_position_live := quick_read_position

        quick_read_size = _text_size(quick_read_text_size)

        string quick_read_title = "XZ S&D - QUICK READ"
        string quick_read_body =
             "CORE INTERPRETATION\n" +
             "XZ S&D reads the close/wick relationship at confirmed directional turning points.\n" +
             "The pivot close is the accepted print used as the zone anchor. Wicks record price\n" +
             "exploration beyond that print; failure to retain the excursion through the turn is\n" +
             "treated by XZ as rejected territory. Supply/Demand are XZ classifications of that\n" +
             "rejection geometry, not a claim that OHLC candles reveal resting order-book liquidity.\n\n" +
             "ZONE ORIGIN\n" +
             "A non-EQ bullish-to-bearish close-direction change confirms the prior non-EQ close\n" +
             "as a High pivot and creates Supply. A bearish-to-bullish change confirms a Low pivot\n" +
             "and creates Demand. The reversal close confirms the turning point; the zone itself\n" +
             "is anchored back to the originating pivot bar.\n\n" +
             "ZONE GEOMETRY\n" +
             "Inner boundary = pivot close / accepted print. Supply outer boundary = furthest High\n" +
             "across the pivot and transition candles. Demand outer boundary = furthest Low across\n" +
             "that same two-candle turning pair. The zone therefore maps rejected exploration beyond\n" +
             "the accepted pivot print.\n\n" +
             "INTERACTION / LIFECYCLE\n" +
             "A developing candle that trades into rejected territory is Testing the zone. If live price\n" +
             "moves through the immutable outer boundary before source-close confirmation, Interaction becomes\n" +
             "Breach Pending — not Consumed. State always remains the last committed lifecycle. If the source\n" +
             "candle closes back outside the accepted inner boundary, the completed result is Wick Tested. If\n" +
             "it closes deeper inside, that candle was a test AND creates Partial Consumption. A strict\n" +
             "confirmed source close beyond the immutable outer boundary Consumes the zone.\n\n" +
             "HIERARCHY / SWING AUTHORITY\n" +
             "Immediate = nearest active Supply or Demand. Swing is structural authority, not simply\n" +
             "second-nearest distance: a zone gains Swing authority only when its originating pivot is\n" +
             "later confirmed as the structural Swing of a completed XZ leg. Immediate + Swing shows\n" +
             "the nearest tactical zone plus the next distinct active Swing-qualified layer per side.\n\n" +
             "DISPLAY / RESEARCH\n" +
             "Zone visibility, display scope, styling, Consumed History, Status and Research are observers\n" +
             "of the S&D engine. Unified Color can optionally sync directional accents in Status/Research,\n" +
             "but display choices never create, partially consume, consume or qualify a zone.\n\n" +
             "ZONE HORIZON\n" +
             "Daily/Weekly/Monthly/Yearly are calendar boundaries in the selected timezone, not\n" +
             "exchange/session opens. Eligibility uses the authoritative zone confirmation close; an admitted\n" +
             "zone still draws from its true earlier pivot origin. Horizon never restarts XZ S&D state.\n\n" +
             "SESSION CONTEXT\n" +
             "Optional session High-Low frames use the shared XZ Session Authority for Sydney, Tokyo,\n" +
             "London, New York, Exchange Cash Hours, Symbol Native or Custom clocks. Zone Horizon is\n" +
             "the parent display scope. Sessions observe the map only and never create or consume zones.\n\n" +
             "SECONDARY TIMEFRAME S&D\n" +
             "Optional Secondary S&D runs the same rejection and canonical Swing methodology on a higher\n" +
             "source timeframe. Primary and Secondary zones never merge. Lower chart-timeframe price can\n" +
             "show Testing or Breach Pending against a Secondary zone, but only confirmed Secondary source closes can\n" +
             "partially consume or permanently consume that Secondary zone. Dashed borders identify it."

        table.cell(quick_read_table, 0, 0, quick_read_title, text_color = UI_GOLD, text_size = quick_read_size, text_halign = text.align_left, bgcolor = quick_read_bg_color)
        table.cell_set_tooltip(quick_read_table, 0, 0, "Onboarding aid. Quick Read is designed to help you understand XZ S&D on first use and does not need to remain visible. Turn it off anytime with 'Show XZ S&D Quick Read' near the top of the indicator settings. Disabling Quick Read affects display only; it never changes zone identification, lifecycle, structural qualification, alerts, Research or drawings.")
        table.cell(quick_read_table, 0, 1, quick_read_body, text_color = quick_read_text_color, text_size = quick_read_size, text_halign = text.align_left, bgcolor = quick_read_bg_color)
    else
        if not na(quick_read_table)
            table.delete(quick_read_table)
            quick_read_table := na
            quick_read_position_live := ""

    true


//@function Renders/removes the XZ S&D chart glossary.
export renderGlossary(
     bool show_glossary,
     simple string glossary_position,
     simple string glossary_text_size
 ) =>
    var table glossary_table = na
    var string glossary_position_live = ""

    if show_glossary
        if na(glossary_table) or glossary_position_live != glossary_position
            if not na(glossary_table)
                table.delete(glossary_table)
            glossary_table := table.new(
                 _position(glossary_position),
                 4,
                 14,
                 bgcolor = UI_GRAPHITE,
                 frame_color = UI_GRID,
                 frame_width = 1,
                 border_color = UI_GRID,
                 border_width = 1
             )
            glossary_position_live := glossary_position
            table.merge_cells(glossary_table, 0, 0, 3, 0)

        glossary_size = _text_size(glossary_text_size)
        table.cell(glossary_table, 0, 0, "XZ S&D — CHART GLOSSARY · HOVER GOLD TERMS FOR XZ DEFINITIONS", text_color = UI_GOLD, text_size = glossary_size, text_halign = text.align_left, bgcolor = UI_GRAPHITE)
        table.cell_set_tooltip(glossary_table, 0, 0, "Onboarding and reference aid. The Glossary provides canonical XZ Supply & Demand terminology while you learn or reference the indicator and does not need to remain visible. Turn it off anytime with 'Show XZ S&D Glossary' near the top of the indicator settings. Disabling the Glossary affects display only; it never changes zone identification, lifecycle, structural qualification, alerts, Research or drawings.")

        _glossary_entry(glossary_table, 0, 1, 1, "Supply", "Rejected High-Side Territory", "XZ Supply is the rejected high-side price territory attached to a confirmed bullish-to-bearish turning point. The zone spans from the pivot close accepted print to the furthest High wick across the pivot/transition pair. It is an OHLC rejection classification, not proof of visible resting sell orders.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 1, "Demand", "Rejected Low-Side Territory", "XZ Demand is the rejected low-side price territory attached to a confirmed bearish-to-bullish turning point. The zone spans from the pivot close accepted print to the furthest Low wick across the pivot/transition pair. It is an OHLC rejection classification, not proof of visible resting buy orders.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 2, "Accepted Print", "Pivot Close Anchor", "The confirmed pivot close used as the original inner boundary of an XZ S&D zone. XZ treats this close as the accepted print associated with the turning point, while wick excursion beyond it is treated as explored territory that was not retained through the confirmed directional transition.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 2, "Rejected Exploration", "Wick-Side Territory", "Price traded beyond the pivot close into the wick-side territory but the excursion was not retained through the confirmed turn. XZ maps that explored-and-rejected high-side territory as Supply and low-side territory as Demand. A wick records the excursion; the completed turning relationship supplies the rejection context.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 3, "Inner Boundary", "Live Close-Side Edge", "The close-side edge of an active zone. At creation it is exactly the pivot close / accepted print. If later closes penetrate the zone without consuming it, this boundary moves permanently deeper to the deepest qualifying close reached so far.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 3, "Outer Boundary", "Rejected Wick-Side Edge", "The immutable wick-side edge established from the furthest same-side extreme across the pivot and transition candles: highest High for Supply, lowest Low for Demand. A strict close beyond this boundary consumes the active zone, but later price action never rewrites where the original rejection occurred.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 4, "Pivot Pair", "Pivot / Transition Pair", "The two-candle turning pair used by XZ S&D. The prior non-EQ close becomes the pivot origin when the next non-EQ close reverses direction. Both candles contribute their same-side wick extreme to the zone outer-boundary calculation.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 4, "Zone Origin", "Pivot-Origin Bar", "The historical pivot bar to which the zone is anchored. The zone becomes objectively known only when the opposite-direction close confirms the turn, but its chart geometry begins at the originating pivot bar.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 5, "Fresh", "Untested Active Zone", "An active zone with no completed post-confirmation source-candle interaction recorded in its original territory. A developing candle can be Testing or even Breach Pending while the committed zone state remains Fresh until source-close authority settles the interaction.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 5, "Partial Consumption", "Close-Accepted Zone Share", "The percentage of original zone width that has been accepted by the deepest qualifying close without a strict close beyond the outer boundary. Partial Consumption contracts the live inner edge permanently while the original zone geometry remains preserved for provenance.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 6, "Active", "Unconsumed Zone", "A confirmed Supply or Demand zone that has not yet received a strict close beyond its outer boundary. An Active zone can be Fresh, Wick Tested or Partially Consumed.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 6, "Consumed", "Closed-Through Zone", "A zone permanently resolved when price closes strictly beyond its outer boundary: above Supply or below Demand. Consumption is committed at that authoritative source close and removes the zone from the active map; the historical box terminates at the consuming source candle while its original wick-defined outer price boundary remains unchanged.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 7, "Wick Test", "Completed Test Event", "A post-confirmation source candle trades into original rejected territory. If its close returns outside the accepted inner boundary, the zone remains Wick Tested only. If that same candle closes deeper inside, the test coexists with Partial Consumption. XZ records wick-test depth independently from close acceptance.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 7, "Close Penetration", "Lifecycle Authority", "A confirmed source close inside the zone beyond its current inner boundary partially consumes the zone and contracts live geometry to that accepted close. The candle also tested the zone on the way in. A strict confirmed source close beyond the outer boundary consumes it completely.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 8, "Immediate S/D", "Nearest Active Zone", "The nearest active Supply or Demand zone to current price inside the current Zone Horizon. Immediate is a tactical proximity classification only; it does not itself grant structural Swing authority.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 8, "Swing S/D", "Swing-Qualified Zone", "An active Supply or Demand zone whose originating pivot has later gained confirmed XZ Swing authority. In Immediate + Swing mode, XZ seeks the next distinct Swing-qualified layer beyond Immediate so the same zone is not duplicated in both roles.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 9, "Swing Authority", "Later Structural Qualification", "A zone is created from its turning-point pivot first. It gains Swing authority only later if that originating pivot is confirmed as the structural Swing of a completed XZ leg. Swing authority is structural provenance and does not reactivate a Consumed zone. A large wick, age or distance from price does not by itself create Swing authority.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 9, "TEST", "Live Zone Interaction", "Collapsed Status notation shown while the current chart candle has traded into original rejected territory but live price is not currently through the immutable outer boundary. TEST is a live interaction state; the authoritative source close still decides the completed Wick Tested / Partial / Consumed lifecycle outcome.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 10, "Zone Horizon", "Confirmation-Time Filter", "The display/report window applied to the authoritative zone confirmation close. Daily, Weekly, Monthly and Yearly are calendar boundaries in the selected Horizon Timezone, not exchange/session opens. Once admitted, the zone still draws from its true earlier pivot origin. Horizon never restarts the S&D engine or rewrites lifecycle state.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 10, "Consumed History", "Consumed-Zone History", "Optional historical display of consumed zones from their pivot origin to their actual consumption close. Turning Consumed History off suppresses those boxes only; it does not delete engine history or Research observations.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 11, "Full Map", "All Active Zones", "Zone Display Scope that draws every active Supply and Demand zone admitted by the current Zone Horizon, subject only to the indicator's physical drawing budget. It changes presentation, not analytical state.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 11, "Swing Map", "All Active Swing Zones", "Zone Display Scope that draws all active Swing-qualified Supply and Demand zones admitted by the current Zone Horizon. It does not change which zones possess Swing authority.", glossary_size)

        _glossary_entry(glossary_table, 0, 1, 12, "Session Context", "Recurring Auction Context", "Optional session High-Low context supplied by the shared XZ Session Authority. Zone Horizon is its parent presentation scope. Session Context never creates, partially consumes, consumes or Swing-qualifies an S&D zone.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 12, "Secondary S&D", "Independent Higher-TF Map", "An optional independently calculated higher-timeframe S&D population. It uses the same XZ rejection geometry and canonical Swing methodology, but its lifecycle authority belongs to confirmed Secondary source-timeframe candles. Primary and Secondary zones never merge.", glossary_size)
        _glossary_entry(glossary_table, 0, 1, 13, "Breach Pending", "Unconfirmed Outer-Boundary Break", "Live price is currently through the immutable outer boundary of an active zone: above Supply or below Demand. This is an interaction state, not committed Consumption. If the authoritative source close remains through the outer boundary the zone becomes Consumed; if price recovers before that close, Breach Pending disappears and the candle remains a Test.", glossary_size)
        _glossary_entry(glossary_table, 2, 3, 13, "Consumption Paths", "Untested / Tested / Partial", "Untested Direct = terminal consumption with no prior Wick Test or Partial event. Tested Direct = one or more prior Wick Tests but no prior Partial event. Partial Path = one or more prior accepted Partial events before terminal consumption. These classify pre-consumption history; the terminal consuming candle is not retroactively counted as a prior test.", glossary_size)
    else
        if not na(glossary_table)
            table.delete(glossary_table)
            glossary_table := na


//==============================================================================

    true
````
