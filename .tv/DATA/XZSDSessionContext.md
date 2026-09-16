<!-- tradingview-pine-id: PUB;ed77eed1de29439e85d00b2d3212966b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_SD_Session_Context

Source: https://www.tradingview.com/script/ZSbwbHSw-XZ-SD-Session-Context/

## Description

Library  "XZ_SD_Session_Context"
XZ S&D Session Context v1. Display-only S&D support library for bounded recurring session High-Low frames. It owns S&D session window storage, Horizon clipping, occurrence retention, frame rendering and live session text while delegating canonical clocks/masks to XZ Session Authority.

newState()
  Creates one persistent S&D Session Context runtime state.

customSpec(open_hhmm, close_hhmm, weekdays_only)
  Builds the Custom session specification used by the chart/lower-TF membership sample request.
  Parameters:
    open_hhmm (simple string)
    close_hhmm (simple string)
    weekdays_only (simple bool)

processDirect(state, enabled, standard, show_sydney, show_tokyo, show_london, show_new_york, custom_timezone, exchange_timezone, horizon, horizon_timezone, sample_time, sample_close_time, sample_high, sample_low, native_market_bar, custom_bar)
  Processes one direct chart-context sample. Repeated realtime calls are allowed so the live session High/Low can expand intrabar.
  Parameters:
    state (State)
    enabled (bool)
    standard (simple string)
    show_sydney (bool)
    show_tokyo (bool)
    show_london (bool)
    show_new_york (bool)
    custom_timezone (simple string)
    exchange_timezone (simple string)
    horizon (simple string)
    horizon_timezone (simple string)
    sample_time (int)
    sample_close_time (int)
    sample_high (float)
    sample_low (float)
    native_market_bar (bool)
    custom_bar (bool)

processLower(state, enabled, standard, show_sydney, show_tokyo, show_london, show_new_york, custom_timezone, exchange_timezone, horizon, horizon_timezone, sample_time, sample_close_time, sample_high, sample_low, native_market_bar, custom_bar)
  Processes one reconstructed lower-timeframe sample. Duplicate/previous sample timestamps are ignored internally.
  Parameters:
    state (State)
    enabled (bool)
    standard (simple string)
    show_sydney (bool)
    show_tokyo (bool)
    show_london (bool)
    show_new_york (bool)
    custom_timezone (simple string)
    exchange_timezone (simple string)
    horizon (simple string)
    horizon_timezone (simple string)
    sample_time (int)
    sample_close_time (int)
    sample_high (float)
    sample_low (float)
    native_market_bar (bool)
    custom_bar (bool)

render(state, enabled, standard, show_sydney, show_tokyo, show_london, show_new_york, history_occurrences, show_codes, frame_transparency, single_color, sydney_color, tokyo_color, london_color, new_york_color, horizon, horizon_timezone, reference_time)
  Renders bounded Session Context frames. This display layer never feeds S&D authority.
  Parameters:
    state (State)
    enabled (bool)
    standard (simple string)
    show_sydney (bool)
    show_tokyo (bool)
    show_london (bool)
    show_new_york (bool)
    history_occurrences (int)
    show_codes (bool)
    frame_transparency (int)
    single_color (color)
    sydney_color (color)
    tokyo_color (color)
    london_color (color)
    new_york_color (color)
    horizon (simple string)
    horizon_timezone (simple string)
    reference_time (int)

displayCount(state)
  Number of currently rendered Session Context boxes.
  Parameters:
    state (State)

liveText(state, enabled, standard)
  Live active-session text for Status.
  Parameters:
    state (State)
    enabled (bool)
    standard (simple string)

Window
  Fields:
    session_index (series int)
    occurrence_key (series int)
    open_time (series int)
    scheduled_close_time (series int)
    last_sample_time (series int)
    high (series float)
    low (series float)

State
  Fields:
    active (array<Window>)
    completed (array<Window>)
    displayed (array<box>)
    parent_cutoff (series int)
    active_mask (series int)
    last_processed_lower_time (series int)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ S&D Session Context v1. Display-only S&D support library for bounded recurring session High-Low frames. It owns S&D session window storage, Horizon clipping, occurrence retention, frame rendering and live session text while delegating canonical clocks/masks to XZ Session Authority.
library("XZ_SD_Session_Context", false)

import Steel-Sovereign/XZ_Session_Authority/1 as xzsess
import Steel-Sovereign/XZ_SD_Memory_Governor/2 as xzmem

//==============================================================================
// OWNERSHIP CONTRACT
//==============================================================================
// OWNED HERE
// - S&D Session Context active/completed window storage.
// - Zone-Horizon-aware clipping/reset of session display history.
// - Historical occurrence limiting.
// - Session frame box creation/deletion.
// - Live active-session mask/text.
// - Methodology-neutral processing of supplied OHLC/session-membership samples.
//
// NOT OWNED HERE
// - Supply/Demand formation, geometry or lifecycle.
// - Pivot/Trend/structure/Swing authority.
// - Wick Test/Partial/Consumption decisions.
// - Research event semantics or Alerts.
// - Zone Horizon admission for S&D zones themselves.
//
// XZ Session Authority remains the canonical suite-wide clock/timezone/mask authority.
//==============================================================================

const int SESSION_COUNT = 4

export type Window
    int session_index
    int occurrence_key
    int open_time
    int scheduled_close_time
    int last_sample_time
    float high
    float low

export type State
    array<Window> active
    array<Window> completed
    array<box> displayed
    int parent_cutoff
    int active_mask
    int last_processed_lower_time

_horizon_start(int reference_time, simple string horizon, simple string timezone_name) =>
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

_selected(simple string standard, int session_index, bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york) =>
    if standard == "Symbol Native" or standard == "Custom"
        session_index == 0
    else
        session_index == 0 ? show_sydney :
         session_index == 1 ? show_tokyo :
         session_index == 2 ? show_london :
         show_new_york

_frame_color(
     simple string standard,
     int session_index,
     color single_color,
     color sydney_color,
     color tokyo_color,
     color london_color,
     color new_york_color
 ) =>
    if standard == "Symbol Native" or standard == "Custom"
        single_color
    else
        session_index == 0 ? sydney_color :
         session_index == 1 ? tokyo_color :
         session_index == 2 ? london_color :
         new_york_color

_clear_displayed(State state) =>
    if array.size(state.displayed) > 0
        for i = array.size(state.displayed) - 1 to 0
            box.delete(array.get(state.displayed, i))
        array.clear(state.displayed)
    true

_clear_archive(State state) =>
    array.clear(state.completed)
    for session_index = 0 to SESSION_COUNT - 1
        array.set(state.active, session_index, na)
    true

_trim_completed(State state) =>
    int recycle_count = xzmem.recycleCount(
         array.size(state.completed),
         xzmem.sessionHistoryTarget(),
         xzmem.sessionHistorySoft(),
         xzmem.sessionHistoryHard()
     )
    while recycle_count > 0
        array.shift(state.completed)
        recycle_count -= 1
    true

_finalize(State state, int session_index) =>
    Window w = array.get(state.active, session_index)
    if not na(w)
        array.push(state.completed, w)
        _trim_completed(state)
        array.set(state.active, session_index, na)
    true

_sync_parent_horizon(State state, simple string horizon, simple string horizon_timezone, int reference_time) =>
    int cutoff = horizon == "All History" ? na : _horizon_start(reference_time, horizon, horizon_timezone)

    if horizon == "All History"
        if not na(state.parent_cutoff)
            _clear_archive(state)
            state.parent_cutoff := na
            state.last_processed_lower_time := na
    else if not na(cutoff) and (na(state.parent_cutoff) or cutoff != state.parent_cutoff)
        _clear_archive(state)
        state.parent_cutoff := cutoff
        state.last_processed_lower_time := na

    cutoff

_update(
     State state,
     int session_index,
     int occurrence_key,
     int effective_open,
     int scheduled_close,
     int sample_close_time,
     float sample_high,
     float sample_low
 ) =>
    Window w = array.get(state.active, session_index)

    if not na(w) and (w.occurrence_key != occurrence_key or w.open_time != effective_open or sample_close_time > w.scheduled_close_time + 60000)
        _finalize(state, session_index)
        w := na

    if na(w)
        w := Window.new(
             session_index,
             occurrence_key,
             effective_open,
             scheduled_close,
             sample_close_time,
             sample_high,
             sample_low
         )
    else
        w.high := math.max(w.high, sample_high)
        w.low := math.min(w.low, sample_low)
        w.last_sample_time := math.max(w.last_sample_time, sample_close_time)
        w.scheduled_close_time := math.max(w.scheduled_close_time, scheduled_close)

    array.set(state.active, session_index, w)
    true

_process_fixed(
     State state,
     simple string standard,
     int session_index,
     simple string custom_timezone,
     simple string exchange_timezone,
     simple string horizon,
     simple string horizon_timezone,
     int sample_time,
     int sample_close_time,
     float sample_high,
     float sample_low
 ) =>
    bool inside_any = false
    Window active = array.get(state.active, session_index)

    if not na(active) and sample_time >= active.scheduled_close_time
        _finalize(state, session_index)

    int segment_count = xzsess.segmentCount(standard, session_index)

    for segment_index = 0 to segment_count - 1
        [candidate_open, candidate_close, valid_day, occurrence_key] = xzsess.segmentBounds(
             standard,
             session_index,
             segment_index,
             sample_time,
             custom_timezone,
             exchange_timezone
         )

        bool inside_segment = valid_day and sample_time < candidate_close and sample_close_time > candidate_open

        if inside_segment
            inside_any := true
            int parent_cutoff = horizon == "All History" ? na : _horizon_start(sample_close_time, horizon, horizon_timezone)
            int effective_open = na(parent_cutoff) ? candidate_open : math.max(candidate_open, parent_cutoff)

            if na(parent_cutoff) or candidate_close > parent_cutoff
                _update(
                     state,
                     session_index,
                     occurrence_key,
                     effective_open,
                     candidate_close,
                     math.min(sample_close_time, candidate_close),
                     sample_high,
                     sample_low
                 )

    inside_any

_process_membership(
     State state,
     simple string horizon,
     simple string horizon_timezone,
     int sample_time,
     int sample_close_time,
     float sample_high,
     float sample_low,
     bool in_session,
     simple string occurrence_timezone
 ) =>
    bool active_now = in_session
    Window w = array.get(state.active, 0)
    int parent_cutoff = horizon == "All History" ? na : _horizon_start(sample_close_time, horizon, horizon_timezone)
    bool effective_in_session = in_session and (na(parent_cutoff) or sample_close_time > parent_cutoff)

    if effective_in_session
        int effective_open = na(w) ? sample_time : w.open_time
        if not na(parent_cutoff)
            effective_open := math.max(effective_open, parent_cutoff)

        int occurrence_key = xzsess.occurrenceKey(effective_open, occurrence_timezone)
        _update(
             state,
             0,
             occurrence_key,
             effective_open,
             sample_close_time,
             sample_close_time,
             sample_high,
             sample_low
         )
    else if not na(w)
        _finalize(state, 0)

    active_now

_process_sample(
     State state,
     simple string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     simple string custom_timezone,
     simple string exchange_timezone,
     simple string horizon,
     simple string horizon_timezone,
     int sample_time,
     int sample_close_time,
     float sample_high,
     float sample_low,
     bool native_market_bar,
     bool custom_bar
 ) =>
    _sync_parent_horizon(state, horizon, horizon_timezone, sample_close_time)

    int active_mask = 0

    if xzsess.usesMarketList(standard)
        for session_index = 0 to SESSION_COUNT - 1
            if _selected(standard, session_index, show_sydney, show_tokyo, show_london, show_new_york) and _process_fixed(
                 state, standard, session_index, custom_timezone, exchange_timezone, horizon, horizon_timezone,
                 sample_time, sample_close_time, sample_high, sample_low
             )
                active_mask := xzsess.maskAdd(active_mask, session_index)
    else
        bool configured_membership = standard == "Symbol Native" ? native_market_bar : custom_bar
        simple string occurrence_timezone = standard == "Symbol Native" ? exchange_timezone : custom_timezone

        if _process_membership(
             state, horizon, horizon_timezone,
             sample_time, sample_close_time, sample_high, sample_low,
             configured_membership, occurrence_timezone
         )
            active_mask := 1

    state.active_mask := active_mask
    true

_draw_one(
     State state,
     Window w,
     simple string standard,
     bool show_codes,
     int frame_transparency,
     color single_color,
     color sydney_color,
     color tokyo_color,
     color london_color,
     color new_york_color,
     simple string horizon,
     simple string horizon_timezone,
     int reference_time
 ) =>
    if array.size(state.displayed) < xzmem.sessionDisplayHard()
        int current_cutoff = horizon == "All History" ? na : _horizon_start(reference_time, horizon, horizon_timezone)
        int left_time = na(current_cutoff) ? w.open_time : math.max(w.open_time, current_cutoff)
        int right_time = math.min(w.last_sample_time, w.scheduled_close_time)

        if right_time > left_time
            color frame_color = _frame_color(
                 standard, w.session_index,
                 single_color, sydney_color, tokyo_color, london_color, new_york_color
             )
            string code = show_codes ? xzsess.sessionCode(standard, w.session_index) : ""

            box bx = box.new(
                 left = left_time,
                 top = w.high,
                 right = right_time,
                 bottom = w.low,
                 xloc = xloc.bar_time,
                 border_color = color.new(frame_color, 55),
                 border_width = 1,
                 bgcolor = color.new(frame_color, frame_transparency),
                 text = code,
                 text_color = color.new(frame_color, 15),
                 text_size = size.tiny,
                 text_halign = text.align_left,
                 text_valign = text.align_top
             )

            array.push(state.displayed, bx)
    true

//@function Creates one persistent S&D Session Context runtime state.
export newState() =>
    State.new(
         array.new<Window>(SESSION_COUNT),
         array.new<Window>(),
         array.new<box>(),
         na,
         0,
         na
     )

//@function Builds the Custom session specification used by the chart/lower-TF membership sample request.
export customSpec(simple string open_hhmm, simple string close_hhmm, simple bool weekdays_only) =>
    xzsess.customSpec(open_hhmm, close_hhmm, weekdays_only)

//@function Processes one direct chart-context sample. Repeated realtime calls are allowed so the live session High/Low can expand intrabar.
export processDirect(
     State state,
     bool enabled,
     simple string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     simple string custom_timezone,
     simple string exchange_timezone,
     simple string horizon,
     simple string horizon_timezone,
     int sample_time,
     int sample_close_time,
     float sample_high,
     float sample_low,
     bool native_market_bar,
     bool custom_bar
 ) =>
    if enabled
        _process_sample(
             state, standard,
             show_sydney, show_tokyo, show_london, show_new_york,
             custom_timezone, exchange_timezone, horizon, horizon_timezone,
             sample_time, sample_close_time, sample_high, sample_low,
             native_market_bar, custom_bar
         )
    else
        state.active_mask := 0
    true

//@function Processes one reconstructed lower-timeframe sample. Duplicate/previous sample timestamps are ignored internally.
export processLower(
     State state,
     bool enabled,
     simple string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     simple string custom_timezone,
     simple string exchange_timezone,
     simple string horizon,
     simple string horizon_timezone,
     int sample_time,
     int sample_close_time,
     float sample_high,
     float sample_low,
     bool native_market_bar,
     bool custom_bar
 ) =>
    if enabled and (na(state.last_processed_lower_time) or sample_time > state.last_processed_lower_time)
        _process_sample(
             state, standard,
             show_sydney, show_tokyo, show_london, show_new_york,
             custom_timezone, exchange_timezone, horizon, horizon_timezone,
             sample_time, sample_close_time, sample_high, sample_low,
             native_market_bar, custom_bar
         )
        state.last_processed_lower_time := sample_time
    else if not enabled
        state.active_mask := 0
    true

//@function Renders bounded Session Context frames. This display layer never feeds S&D authority.
export render(
     State state,
     bool enabled,
     simple string standard,
     bool show_sydney,
     bool show_tokyo,
     bool show_london,
     bool show_new_york,
     int history_occurrences,
     bool show_codes,
     int frame_transparency,
     color single_color,
     color sydney_color,
     color tokyo_color,
     color london_color,
     color new_york_color,
     simple string horizon,
     simple string horizon_timezone,
     int reference_time
 ) =>
    _clear_displayed(state)

    if enabled
        for session_index = 0 to SESSION_COUNT - 1
            if _selected(standard, session_index, show_sydney, show_tokyo, show_london, show_new_york)
                Window w = array.get(state.active, session_index)
                if not na(w)
                    _draw_one(
                         state, w, standard, show_codes, frame_transparency,
                         single_color, sydney_color, tokyo_color, london_color, new_york_color,
                         horizon, horizon_timezone, reference_time
                     )

        bool use_occurrence_limit = horizon == "All History" or horizon == "Yearly Boundary Onwards"
        array<int> occurrence_counts = array.new_int(SESSION_COUNT, 0)
        array<int> last_occurrence_keys = array.new_int(SESSION_COUNT, na)

        if array.size(state.completed) > 0
            for offset = 0 to array.size(state.completed) - 1
                int idx = array.size(state.completed) - 1 - offset
                Window w = array.get(state.completed, idx)

                if _selected(standard, w.session_index, show_sydney, show_tokyo, show_london, show_new_york)
                    bool include_window = true

                    if use_occurrence_limit
                        int last_key = array.get(last_occurrence_keys, w.session_index)
                        bool same_occurrence = not na(last_key) and last_key == w.occurrence_key
                        int count = array.get(occurrence_counts, w.session_index)

                        include_window := same_occurrence or count < history_occurrences

                        if include_window and not same_occurrence
                            array.set(last_occurrence_keys, w.session_index, w.occurrence_key)
                            array.set(occurrence_counts, w.session_index, count + 1)

                    if include_window
                        _draw_one(
                             state, w, standard, show_codes, frame_transparency,
                             single_color, sydney_color, tokyo_color, london_color, new_york_color,
                             horizon, horizon_timezone, reference_time
                         )

                if array.size(state.displayed) >= xzmem.sessionDisplayHard()
                    break

    true

//@function Number of currently rendered Session Context boxes.
export displayCount(State state) =>
    array.size(state.displayed)

//@function Live active-session text for Status.
export liveText(State state, bool enabled, simple string standard) =>
    not enabled ? "Sessions Off" : state.active_mask == 0 ? "No Active Session" : xzsess.maskCode(standard, state.active_mask)
````
