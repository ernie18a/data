<!-- tradingview-pine-id: PUB;ed77eed1de29439e85d00b2d3212966b -->
<!-- tradingview-pine-version: 2.0 -->
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

//@description XZ S&D Session Context v2. Display-only support library for bounded recurring session High-Low frames. Owns session-window storage, Horizon clipping, occurrence retention, frame rendering and live session text while delegating canonical clocks/masks to XZ Session Authority. v2 updates the authority dependency to /3 and adds generic active/latest-completed window accessors.
library("XZ_SD_Session_Context", false)

import Steel-Sovereign/XZ_Session_Authority/3 as xzsess

//==============================================================================
// LIMITS
//==============================================================================

const int SESSION_COUNT = 4
const int MAX_COMPLETED_WINDOWS = 160
const int MAX_DISPLAYED_WINDOWS = 160

//==============================================================================
// PUBLIC TYPES
//==============================================================================

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

//@function Builds the Custom session specification used by chart/lower-TF membership samples.
export customSpec(simple string open_hhmm, simple string close_hhmm, simple bool weekdays_only) =>
    xzsess.customSpec(open_hhmm, close_hhmm, weekdays_only)

//==============================================================================
// GENERIC SELECTION / HORIZON HELPERS
//==============================================================================

_selected(
     simple string standard, int session_index,
     bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york
 ) =>
    if standard == "Symbol Native" or standard == "Custom"
        session_index == 0
    else
        xzsess.marketSelected(session_index, show_sydney, show_tokyo, show_london, show_new_york)

_horizonStart(simple string horizon, simple string horizon_timezone, int reference_time) =>
    int result = na
    if horizon != "All History" and not na(reference_time)
        int local_year = year(reference_time, horizon_timezone)
        int local_month = month(reference_time, horizon_timezone)
        int local_day = dayofmonth(reference_time, horizon_timezone)

        if horizon == "Daily Boundary Onwards"
            result := timestamp(horizon_timezone, local_year, local_month, local_day, 0, 0, 0)
        else if horizon == "Weekly Boundary Onwards"
            int local_dow = dayofweek(reference_time, horizon_timezone)
            int days_since_monday = local_dow == dayofweek.sunday ? 6 : local_dow - dayofweek.monday
            result := timestamp(horizon_timezone, local_year, local_month, local_day - days_since_monday, 0, 0, 0)
        else if horizon == "Monthly Boundary Onwards"
            result := timestamp(horizon_timezone, local_year, local_month, 1, 0, 0, 0)
        else if horizon == "Yearly Boundary Onwards"
            result := timestamp(horizon_timezone, local_year, 1, 1, 0, 0, 0)
    result

_clearDisplayed(State state) =>
    int count = array.size(state.displayed)
    if count > 0
        for i = count - 1 to 0
            box id = array.get(state.displayed, i)
            if not na(id)
                box.delete(id)
        array.clear(state.displayed)
    true

_clearArchive(State state) =>
    array.clear(state.completed)
    for session_index = 0 to SESSION_COUNT - 1
        array.set(state.active, session_index, na)
    state.active_mask := 0
    true

_syncHorizon(State state, simple string horizon, simple string horizon_timezone, int reference_time) =>
    int cutoff = horizon == "All History" ? na : _horizonStart(horizon, horizon_timezone, reference_time)
    bool changed = false

    if horizon == "All History"
        changed := not na(state.parent_cutoff)
    else
        changed := not na(cutoff) and (na(state.parent_cutoff) or cutoff != state.parent_cutoff)

    if changed
        _clearArchive(state)
        state.last_processed_lower_time := na

    state.parent_cutoff := cutoff
    true

_trimCompleted(State state) =>
    while array.size(state.completed) > MAX_COMPLETED_WINDOWS
        array.shift(state.completed)
    true

_finalize(State state, int session_index) =>
    Window w = array.get(state.active, session_index)
    if not na(w)
        array.push(state.completed, w)
        _trimCompleted(state)
        array.set(state.active, session_index, na)
    true

_updateWindow(
     State state, int session_index, int occurrence_key,
     int effective_open, int scheduled_close, int sample_close_time,
     float sample_high, float sample_low
 ) =>
    Window w = array.get(state.active, session_index)

    if not na(w) and (
         w.occurrence_key != occurrence_key or
         w.open_time != effective_open or
         sample_close_time > w.scheduled_close_time + 60000
     )
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

_processFixed(
     State state, simple string standard, int session_index,
     simple string custom_timezone, simple string exchange_timezone,
     simple string horizon, simple string horizon_timezone,
     int sample_time, int sample_close_time, float sample_high, float sample_low
 ) =>
    bool inside_any = false
    Window active = array.get(state.active, session_index)

    if not na(active) and sample_time >= active.scheduled_close_time
        _finalize(state, session_index)

    int segment_count = xzsess.segmentCount(standard, session_index)
    for segment_index = 0 to segment_count - 1
        [candidate_open, candidate_close, valid_day, occurrence_key] =
             xzsess.segmentBounds(
                  standard, session_index, segment_index, sample_time,
                  custom_timezone, exchange_timezone
              )

        bool inside_segment =
             valid_day and
             sample_time < candidate_close and
             sample_close_time > candidate_open

        if inside_segment
            inside_any := true
            int parent_cutoff = horizon == "All History" ? na : _horizonStart(horizon, horizon_timezone, sample_close_time)
            int effective_open = na(parent_cutoff) ? candidate_open : math.max(candidate_open, parent_cutoff)

            if na(parent_cutoff) or candidate_close > parent_cutoff
                _updateWindow(
                     state, session_index, occurrence_key,
                     effective_open, candidate_close,
                     math.min(sample_close_time, candidate_close),
                     sample_high, sample_low
                 )

    inside_any

_processMembership(
     State state, bool in_session, string occurrence_timezone,
     simple string horizon, simple string horizon_timezone,
     int sample_time, int sample_close_time, float sample_high, float sample_low
 ) =>
    bool active_now = in_session
    Window w = array.get(state.active, 0)
    int parent_cutoff = horizon == "All History" ? na : _horizonStart(horizon, horizon_timezone, sample_close_time)
    bool effective_in_session = in_session and (na(parent_cutoff) or sample_close_time > parent_cutoff)

    if effective_in_session
        int effective_open = na(w) ? sample_time : w.open_time
        if not na(parent_cutoff)
            effective_open := math.max(effective_open, parent_cutoff)

        int occurrence_key = xzsess.occurrenceKey(effective_open, occurrence_timezone)
        _updateWindow(
             state, 0, occurrence_key,
             effective_open, sample_close_time, sample_close_time,
             sample_high, sample_low
         )
    else if not na(w)
        _finalize(state, 0)

    active_now

_processAll(
     State state, simple string standard,
     bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york,
     simple string custom_timezone, simple string exchange_timezone,
     simple string horizon, simple string horizon_timezone,
     int sample_time, int sample_close_time, float sample_high, float sample_low,
     bool native_market_bar, bool custom_bar
 ) =>
    int active_mask = 0

    if xzsess.usesMarketList(standard)
        for session_index = 0 to SESSION_COUNT - 1
            if _selected(standard, session_index, show_sydney, show_tokyo, show_london, show_new_york)
                if _processFixed(
                     state, standard, session_index,
                     custom_timezone, exchange_timezone,
                     horizon, horizon_timezone,
                     sample_time, sample_close_time, sample_high, sample_low
                 )
                    active_mask := xzsess.maskAdd(active_mask, session_index)
    else
        bool configured_membership = standard == "Symbol Native" ? native_market_bar : custom_bar
        string occurrence_timezone = standard == "Symbol Native" ? exchange_timezone : custom_timezone
        if _processMembership(
             state, configured_membership, occurrence_timezone,
             horizon, horizon_timezone,
             sample_time, sample_close_time, sample_high, sample_low
         )
            active_mask := 1

    state.active_mask := active_mask
    true

//==============================================================================
// SAMPLE PROCESSING
//==============================================================================

//@function Processes one direct chart-context sample. Repeated realtime calls are allowed so the live session High/Low can expand intrabar.
export processDirect(
     State state, bool enabled, simple string standard,
     bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york,
     simple string custom_timezone, simple string exchange_timezone,
     simple string horizon, simple string horizon_timezone,
     int sample_time, int sample_close_time, float sample_high, float sample_low,
     bool native_market_bar, bool custom_bar
 ) =>
    if enabled
        _syncHorizon(state, horizon, horizon_timezone, sample_close_time)
        _processAll(
             state, standard,
             show_sydney, show_tokyo, show_london, show_new_york,
             custom_timezone, exchange_timezone,
             horizon, horizon_timezone,
             sample_time, sample_close_time, sample_high, sample_low,
             native_market_bar, custom_bar
         )
    else
        state.active_mask := 0
    true

//@function Processes one reconstructed lower-timeframe sample. Duplicate/previous sample timestamps are ignored internally.
export processLower(
     State state, bool enabled, simple string standard,
     bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york,
     simple string custom_timezone, simple string exchange_timezone,
     simple string horizon, simple string horizon_timezone,
     int sample_time, int sample_close_time, float sample_high, float sample_low,
     bool native_market_bar, bool custom_bar
 ) =>
    if enabled
        _syncHorizon(state, horizon, horizon_timezone, sample_close_time)
        if na(state.last_processed_lower_time) or sample_time > state.last_processed_lower_time
            _processAll(
                 state, standard,
                 show_sydney, show_tokyo, show_london, show_new_york,
                 custom_timezone, exchange_timezone,
                 horizon, horizon_timezone,
                 sample_time, sample_close_time, sample_high, sample_low,
                 native_market_bar, custom_bar
             )
            state.last_processed_lower_time := sample_time
    else
        state.active_mask := 0
    true

//==============================================================================
// RETAINED-WINDOW ACCESS
//==============================================================================

//@function Returns the active retained window for a session index, or na when none is active.
export activeWindow(State state, int session_index) =>
    Window result = na
    int count = array.size(state.active)
    if count > 0
        for i = 0 to count - 1
            Window candidate = array.get(state.active, i)
            if not na(candidate) and candidate.session_index == session_index
                result := candidate
                break
    result

//@function Returns the latest completed window for a session index. When before_close_time is supplied, only windows closing strictly before that timestamp qualify.
export latestCompleted(State state, int session_index, int before_close_time) =>
    Window result = na
    int latest_close = na
    int count = array.size(state.completed)

    if count > 0
        for i = 0 to count - 1
            Window candidate = array.get(state.completed, i)
            bool eligible =
                 not na(candidate) and
                 candidate.session_index == session_index and
                 (na(before_close_time) or candidate.scheduled_close_time < before_close_time)

            if eligible and (na(latest_close) or candidate.scheduled_close_time > latest_close)
                result := candidate
                latest_close := candidate.scheduled_close_time

    result

//==============================================================================
// RENDERING
//==============================================================================

_sessionColor(
     simple string standard, int session_index,
     color single_color, color sydney_color, color tokyo_color,
     color london_color, color new_york_color
 ) =>
    if standard == "Symbol Native" or standard == "Custom"
        single_color
    else
        session_index == 0 ? sydney_color :
         session_index == 1 ? tokyo_color :
         session_index == 2 ? london_color :
         new_york_color

_drawOne(
     State state, Window w,
     bool show_codes, int frame_transparency,
     simple string standard,
     color single_color, color sydney_color, color tokyo_color,
     color london_color, color new_york_color,
     simple string horizon, simple string horizon_timezone,
     int reference_time
 ) =>
    if array.size(state.displayed) < MAX_DISPLAYED_WINDOWS
        int cutoff = horizon == "All History" ? na : _horizonStart(horizon, horizon_timezone, reference_time)
        int left_time = na(cutoff) ? w.open_time : math.max(w.open_time, cutoff)
        int right_time = math.min(w.last_sample_time, w.scheduled_close_time)

        if right_time > left_time
            color frame_color = _sessionColor(
                 standard, w.session_index,
                 single_color, sydney_color, tokyo_color,
                 london_color, new_york_color
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

//@function Renders bounded Session Context frames. This display layer never feeds S&D authority.
export render(
     State state, bool enabled, simple string standard,
     bool show_sydney, bool show_tokyo, bool show_london, bool show_new_york,
     int history_occurrences, bool show_codes, int frame_transparency,
     color single_color, color sydney_color, color tokyo_color,
     color london_color, color new_york_color,
     simple string horizon, simple string horizon_timezone, int reference_time
 ) =>
    _clearDisplayed(state)

    if enabled
        for session_index = 0 to SESSION_COUNT - 1
            if _selected(standard, session_index, show_sydney, show_tokyo, show_london, show_new_york)
                Window w = activeWindow(state, session_index)
                if not na(w)
                    _drawOne(
                         state, w, show_codes, frame_transparency, standard,
                         single_color, sydney_color, tokyo_color, london_color, new_york_color,
                         horizon, horizon_timezone, reference_time
                     )

        bool use_occurrence_limit =
             horizon == "All History" or
             horizon == "Yearly Boundary Onwards"

        array<int> occurrence_counts = array.new_int(SESSION_COUNT, 0)
        array<int> last_occurrence_keys = array.new_int(SESSION_COUNT, na)

        int completed_count = array.size(state.completed)
        if completed_count > 0
            for offset = 0 to completed_count - 1
                int idx = completed_count - 1 - offset
                Window w = array.get(state.completed, idx)

                if not na(w) and _selected(standard, w.session_index, show_sydney, show_tokyo, show_london, show_new_york)
                    bool include_window = true

                    if use_occurrence_limit
                        int last_key = array.get(last_occurrence_keys, w.session_index)
                        bool same_occurrence = not na(last_key) and last_key == w.occurrence_key
                        int occurrence_count = array.get(occurrence_counts, w.session_index)

                        include_window := same_occurrence or occurrence_count < history_occurrences

                        if include_window and not same_occurrence
                            array.set(last_occurrence_keys, w.session_index, w.occurrence_key)
                            array.set(occurrence_counts, w.session_index, occurrence_count + 1)

                    if include_window
                        _drawOne(
                             state, w, show_codes, frame_transparency, standard,
                             single_color, sydney_color, tokyo_color, london_color, new_york_color,
                             horizon, horizon_timezone, reference_time
                         )

                if array.size(state.displayed) >= MAX_DISPLAYED_WINDOWS
                    break

    true

//@function Number of currently rendered Session Context boxes.
export displayCount(State state) =>
    array.size(state.displayed)

//@function Live active-session text for Status.
export liveText(State state, bool enabled, simple string standard) =>
    not enabled ? "Sessions Off" :
     state.active_mask == 0 ? "No Active Session" :
     xzsess.maskCode(standard, state.active_mask)
````
