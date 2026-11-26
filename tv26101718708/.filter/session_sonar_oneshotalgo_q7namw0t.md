# Session Sonar [OneShotAlgo]

- url: https://www.tradingview.com/script/Q7nAMw0T-Session-Sonar-OneShotAlgo/
- type: indicator
- pine_id: PUB;a7c4e0396098493ca1206b075732f928
- version: 1.0

## Description

🟠 Overview

Session Sonar projects forward-looking volatility envelopes from each major trading session open, helping you visualize how far price could realistically travel from that session anchor over time.

Each session begins with a set of concentric rings expanding forward in time. Inner rings represent shorter horizons such as 1H, 2H, and 4H, while the outermost ring represents the expected envelope by session close.

The rings are based on current hourly volatility, not chart-timeframe volatility, so they keep consistent meaning whether you are viewing a 5-minute chart or a 1-hour chart. Ring size expands with time using a square-root scaling model, which produces more realistic envelopes than linear expansion.

🟠 How to read it
[list]
[*]Price reaching outer rings quickly suggests the session is moving faster than typical volatility.
[*]Price remaining inside inner rings suggests a more compressed session environment.
[*]The glow line traces price movement from session open to the current bar, giving a quick visual read on session development.
[/list]
This tool is not directional. It does not predict whether price will move up or down. It is a visual context tool designed to help calibrate expectations around distance, pace, and session development.

🟠 Sessions
[list]
[*]Asia
[*]London
[*]New York
[*]Daily
[/list]
Each session has its own color and configurable UTC timing. Asia, London, and New York are enabled by default for a clean intraday view.

🟠 Implementation notes
[list]
[*]Uses hourly ATR for consistent envelope sizing across chart timeframes
[*]Small rings auto-hide when they would render poorly on the current timeframe
[*]Previous session anchors fade gradually so you can still see how earlier envelopes played out
[*]Works across forex, indices, commodities, crypto, and other liquid markets
[/list]
🟠 Suggested timeframes

Best suited to intraday charts, especially 1m to 1H. On higher timeframes, session boundaries become less meaningful and some shorter-horizon rings may not render.

🟠 This script does not
[list]
[*]generate entry or exit signals
[*]predict direction
[*]guarantee that price will remain inside any ring
[/list]
Outlier moves happen, especially around news or in strong trend conditions. Session Sonar is a visual decision-support tool, not a trading system.

🟠 Customization

Ring horizons, envelope scale, fade duration, smoothness, minimum horizon-to-timeframe ratio, session colors, and all major visual elements can be adjusted in settings.

## Source Code

````pine
// Session Sonar — Forward-projecting volatility rings anchored to trading session opens
// Free Open-Source TradingView Script
//
// Each ring shows the expected price reach at a given time horizon from session open,
// based on current hourly volatility. Ring radius scales with the square root of time:
// a 4-hour expected move is ~2x a 1-hour move, not 4x. This produces envelopes that
// expand gracefully and remain statistically grounded.
//
// The outermost ring represents the expected envelope at session close.
// Price reaching outer rings quickly indicates the session is moving faster than
// typical volatility. Price remaining within inner rings indicates a compression
// environment.

//@version=6
indicator("Session Sonar [OneShotAlgo]",
     overlay             = true,
     max_polylines_count = 100,
     max_lines_count     = 100,
     max_labels_count    = 100)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Sessions ──────────────────────────────────────────────────────────────────
show_asia   = input.bool(true, "Show Asia Session Sonar",     group = "Sessions")
show_london = input.bool(true,  "Show London Session Sonar",   group = "Sessions")
show_ny     = input.bool(true,  "Show New York Session Sonar", group = "Sessions")
show_daily  = input.bool(false, "Show Daily Session Sonar",    group = "Sessions")

// ── Session Times ─────────────────────────────────────────────────────────────
asia_open_str    = input.string("00:00", "Asia Session Open (UTC)",     group = "Session Times")
london_open_str  = input.string("08:00", "London Session Open (UTC)",   group = "Session Times")
ny_open_str      = input.string("13:00", "New York Session Open (UTC)", group = "Session Times")
daily_open_str   = input.string("00:00", "Daily Session Open (UTC)",    group = "Session Times")
asia_close_str   = input.string("08:00", "Asia Session Close (UTC)",    group = "Session Times")
london_close_str = input.string("13:00", "London Session Close (UTC)",  group = "Session Times")
ny_close_str     = input.string("21:00", "New York Session Close (UTC)",group = "Session Times")

// ── Ring Configuration ────────────────────────────────────────────────────────
atr_length = input.int(14, "ATR Length", minval = 1,
     group   = "Ring Configuration",
     tooltip = "Period for the hourly ATR calculation that sizes the rings.")
scaling_multiplier = input.float(1.0, "Envelope Scale",
     step = 0.1, minval = 0.3, maxval = 3.0,
     group   = "Ring Configuration",
     tooltip = "Multiplier to widen or tighten all envelopes uniformly.")
ring_segments = input.int(36, "Ring Smoothness (segments per half-circle)",
     minval = 16, maxval = 60,
     group   = "Ring Configuration",
     tooltip = "Line segments per half-circle. Higher values produce smoother rings.")
min_horizon_tf_ratio = input.float(4.0, "Minimum Horizon vs Chart Timeframe",
     step = 0.5, minval = 1.0, maxval = 10.0,
     group   = "Ring Configuration",
     tooltip = "Rings are skipped if their time horizon is smaller than this multiple of the chart's timeframe. Keeps small rings from appearing as jagged rectangles on higher timeframes.")
asia_horizons_str = input.string("1,2,4,8", "Asia Ring Hours (comma-separated)",
     group   = "Ring Configuration",
     tooltip = "Time horizons in hours for Asia session rings.")
london_horizons_str = input.string("1,2,3,5", "London Ring Hours",
     group   = "Ring Configuration",
     tooltip = "Time horizons in hours for London session rings.")
ny_horizons_str = input.string("1,2,4,8", "New York Ring Hours",
     group   = "Ring Configuration",
     tooltip = "Time horizons in hours for New York session rings.")
daily_horizons_str = input.string("1,4,8,24", "Daily Ring Hours",
     group   = "Ring Configuration",
     tooltip = "Time horizons in hours for Daily session rings.")

// ── Fade & Lifecycle ──────────────────────────────────────────────────────────
fade_hours = input.float(48.0, "Fade Duration (hours after session close)",
     step = 1.0, minval = 1.0, maxval = 168.0,
     group   = "Fade & Lifecycle",
     tooltip = "How long, in hours of market time, rings take to fade after the session ends. Expressed in hours so behavior stays consistent across chart timeframes. Default of 48h lets the longest default horizon (24H Daily ring) play out fully before fading.")
max_sessions_per_type = input.int(2, "Max Active Anchors Per Session Type",
     minval = 1, maxval = 3,
     group   = "Fade & Lifecycle",
     tooltip = "Maximum number of visible anchors per session (current + previous).")

// ── Visual Style ──────────────────────────────────────────────────────────────
show_glow_line = input.bool(true, "Show Anchor-to-Price Line",
     group   = "Visual Style",
     tooltip = "The glow line traces price movement from session open \u2014 steeper lines indicate faster directional development.")
show_price_echo = input.bool(true, "Show Current Price Marker",
     group   = "Visual Style",
     tooltip = "A small marker at the current price within the active envelope.")
show_ring_labels = input.bool(true, "Show Ring Time Labels",
     group   = "Visual Style",
     tooltip = "Labels at the top of each ring showing the time horizon.")
show_anchor_marker = input.bool(true, "Show Session Anchor Point",
     group   = "Visual Style",
     tooltip = "A dot at the session open price and time.")

// ── Colors ────────────────────────────────────────────────────────────────────
asia_color   = input.color(#00E5FF, "Asia Color",     group = "Colors")
london_color = input.color(#FFAB00, "London Color",   group = "Colors")
ny_color     = input.color(#FF1493, "New York Color", group = "Colors")
daily_color  = input.color(#7C4DFF, "Daily Color",    group = "Colors")

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

// Session type identifiers (matching spec: 0=Asia, 1=London, 2=NY, 3=Daily).
var int SESS_ASIA   = 0
var int SESS_LONDON = 1
var int SESS_NY     = 2
var int SESS_DAILY  = 3

var int MS_PER_HOUR = 3600000

// Opacity values for the three nested ring layers that create the glow effect.
// In Pine Script, a higher value means MORE transparent (counterintuitive).
var int layer_opacity_inner  = 55  // brightest inner highlight
var int layer_opacity_middle = 70  // primary ring
var int layer_opacity_outer  = 85  // faint outer halo

// Radius multipliers for the three nested layers.
var float layer_radius_inner  = 0.98
var float layer_radius_middle = 1.00
var float layer_radius_outer  = 1.02

// Polyline budget safeguard threshold (out of max 100).
var int POLYLINE_BUDGET_LIMIT = 90

// ═══════════════════════════════════════════════════════════════════════════════
// USER-DEFINED TYPE — SessionAnchor
// ═══════════════════════════════════════════════════════════════════════════════
//
// SessionAnchor holds the state AND all drawing objects for a single session
// anchor. Drawing objects are owned per-anchor so they can be cleanly deleted
// when the anchor expires, without affecting other anchors.

type SessionAnchor
    int             session_type        // 0=Asia, 1=London, 2=NY, 3=Daily
    int             anchor_time         // bar time (ms) of session open
    int             anchor_bar_index    // bar_index of session open
    float           anchor_price        // open price at session start
    bool            is_active           // currently in session
    bool            is_fading           // session ended, fading out
    int             fade_progress_bars  // how many bars into fade
    array<polyline> ring_polylines      // all polylines for this anchor's rings
    line            glow_line           // anchor-to-price line (na when not active)
    label           anchor_marker       // dot at session open
    array<label>    ring_labels         // time-horizon labels for each ring

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Parses "HH:MM" into minutes since midnight (UTC).
to_minutes(hhmm) =>
    h = str.tonumber(str.substring(hhmm, 0, 2))
    m = str.tonumber(str.substring(hhmm, 3, 5))
    int(nz(h) * 60 + nz(m))

// Converts "HH:MM" to "HHMM" for Pine session-string format.
format_session_time(t) =>
    str.replace_all(t, ":", "")

// Parses a comma-separated string of numbers into a float array.
// Example: "1,2,4,8" -> [1.0, 2.0, 4.0, 8.0]
parse_horizons(horizon_str) =>
    result = array.new<float>()
    parts  = str.split(horizon_str, ",")
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            val = str.tonumber(str.trim(array.get(parts, i)))
            if not na(val) and val > 0
                array.push(result, val)
    result

// ═══════════════════════════════════════════════════════════════════════════════
// CACHED HORIZONS (parsed once, reused each bar)
// ═══════════════════════════════════════════════════════════════════════════════

var array<float> horizons_asia   = parse_horizons(asia_horizons_str)
var array<float> horizons_london = parse_horizons(london_horizons_str)
var array<float> horizons_ny     = parse_horizons(ny_horizons_str)
var array<float> horizons_daily  = parse_horizons(daily_horizons_str)

get_horizons(stype) =>
    switch stype
        SESS_ASIA   => horizons_asia
        SESS_LONDON => horizons_london
        SESS_NY     => horizons_ny
        SESS_DAILY  => horizons_daily
        => array.new<float>()

get_session_color(stype) =>
    switch stype
        SESS_ASIA   => asia_color
        SESS_LONDON => london_color
        SESS_NY     => ny_color
        SESS_DAILY  => daily_color
        => color.gray

get_session_name(stype) =>
    switch stype
        SESS_ASIA   => "Asia"
        SESS_LONDON => "London"
        SESS_NY     => "New York"
        SESS_DAILY  => "Daily"
        => "Session"

// Stacking priority for anchor dots when multiple sessions share the same
// open time (e.g. Asia + Daily both at 00:00 UTC). Lower index = closer to
// the true anchor price; higher index = offset further away visually.
// Order: Daily (broadest context) on top, then Asia, London, NY.
get_session_stack_index(stype) =>
    switch stype
        SESS_DAILY  => 0   // top
        SESS_ASIA   => 1
        SESS_LONDON => 2
        SESS_NY     => 3
        => 0

// ═══════════════════════════════════════════════════════════════════════════════
// ATR CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════

// Hourly ATR ensures ring radii have consistent meaning regardless of the chart
// timeframe. A trader on a 5m chart and a trader on a 1H chart see the same
// absolute ring sizes for the same session.
hourly_atr = request.security(syminfo.tickerid, "60", ta.atr(atr_length))

// ═══════════════════════════════════════════════════════════════════════════════
// TIMEFRAME VALIDATION
// ═══════════════════════════════════════════════════════════════════════════════

tf_seconds    = timeframe.in_seconds()
is_valid_tf   = tf_seconds >= 60       // 1m minimum
is_daily_plus = tf_seconds >= 86400    // daily chart or higher

// Convert fade_hours (user input, time-based) into bars based on the current
// chart timeframe. This keeps fade-out wall-clock duration consistent whether
// the user is on 1m, 15m, 1H, etc.
//
// Internal safety cap: on very low timeframes with high fade_hours, the raw
// bar count can grow very large (e.g. 168 hours on 1m = 10080 bars). The
// polyline budget safeguard already trims oldest fading anchors if needed,
// but we apply a conservative 5000-bar internal ceiling as belt-and-braces.
FADE_BARS_CEILING = 5000
fade_bars_raw       = int(fade_hours * 3600.0 / math.max(float(tf_seconds), 1.0))
fade_bars_effective = math.max(1, math.min(fade_bars_raw, FADE_BARS_CEILING))

// Friendly message on unsupported sub-minute timeframes.
var label tf_warning_label = na
if not is_valid_tf and barstate.islast
    if not na(tf_warning_label)
        label.delete(tf_warning_label)
    tf_warning_label := label.new(bar_index, close,
         "Session Sonar works on 1m\u20134H timeframes",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_center,
         color     = color.new(color.red, 80),
         textcolor = color.white,
         size      = size.normal)

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

asia_sess   = format_session_time(asia_open_str) + "-" + format_session_time(asia_close_str)
london_sess = format_session_time(london_open_str) + "-" + format_session_time(london_close_str)
ny_sess     = format_session_time(ny_open_str) + "-" + format_session_time(ny_close_str)

in_asia   = not na(time(timeframe.period, asia_sess,   "UTC"))
in_london = not na(time(timeframe.period, london_sess, "UTC"))
in_ny     = not na(time(timeframe.period, ny_sess,     "UTC"))

in_asia_prev   = not na(time(timeframe.period, asia_sess,   "UTC")[1])
in_london_prev = not na(time(timeframe.period, london_sess, "UTC")[1])
in_ny_prev     = not na(time(timeframe.period, ny_sess,     "UTC")[1])

asia_just_opened   = in_asia   and not in_asia_prev
london_just_opened = in_london and not in_london_prev
ny_just_opened     = in_ny     and not in_ny_prev

asia_just_closed   = not in_asia   and in_asia_prev
london_just_closed = not in_london and in_london_prev
ny_just_closed     = not in_ny     and in_ny_prev

// Daily session: detect crossing of the configured UTC open time.
daily_open_minutes  = to_minutes(daily_open_str)
current_utc_minutes = hour(time, "UTC") * 60 + minute(time, "UTC")
prev_utc_minutes    = bar_index > 0
     ? hour(time[1], "UTC") * 60 + minute(time[1], "UTC")
     : -1

daily_just_opened = false
if tf_seconds < 86400
    if daily_open_minutes == 0
        daily_just_opened := bar_index > 0
             ? dayofweek(time, "UTC") != dayofweek(time[1], "UTC")
             : false
    else
        daily_just_opened := current_utc_minutes >= daily_open_minutes
             and prev_utc_minutes < daily_open_minutes

// Weekend filter: do not create anchors on Saturday or Sunday for markets
// that do not trade weekends (forex, stocks, futures). Crypto and other
// continuous markets are exempted so weekend anchors fire normally.
wd = dayofweek(time, "UTC")
is_weekend_day = wd == dayofweek.saturday or wd == dayofweek.sunday

// 24/7 markets (primarily crypto) do not observe a weekend gap. We detect
// this via syminfo.type — "crypto" is the only continuously-traded type
// TradingView exposes. For all other instrument types we apply the
// weekend filter as before.
is_continuous_market = syminfo.type == "crypto"
is_weekend = is_weekend_day and not is_continuous_market

// ═══════════════════════════════════════════════════════════════════════════════
// ANCHOR STORAGE — one array per session type, per spec
// ═══════════════════════════════════════════════════════════════════════════════

var array<SessionAnchor> anchors_asia   = array.new<SessionAnchor>()
var array<SessionAnchor> anchors_london = array.new<SessionAnchor>()
var array<SessionAnchor> anchors_ny     = array.new<SessionAnchor>()
var array<SessionAnchor> anchors_daily  = array.new<SessionAnchor>()

// ═══════════════════════════════════════════════════════════════════════════════
// DRAWING HELPERS — each returns a drawing object (owned by an anchor)
// ═══════════════════════════════════════════════════════════════════════════════

// Calculates the ring radius (price distance) for a given time horizon.
//
//   ring_radius = hourly_ATR * sqrt(T_hours) * scaling_multiplier
//
// The sqrt(T) term is the core of the volatility projection model. In
// diffusion-based models of price movement, expected displacement scales
// with the square root of time -- a 4-hour expected move is approximately
// 2x a 1-hour move, not 4x. This produces rings that feel tight at first
// and expand more gracefully at longer horizons.
calc_ring_radius(h_atr, T_hours, scale) =>
    h_atr * math.sqrt(T_hours) * scale

// Creates a single polyline layer of a ring and returns it.
//
// The ring is a forward-projecting oval anchored at (a_time, a_price).
// It extends forward in time to T_hours and spans +/- layer_r in price.
//
// Parameterisation (theta sweeps 0 -> 2*pi around the full ellipse):
//   time_offset  = (T / 2) * (1 + cos(theta))  -- ranges from 0 (anchor) to T (far)
//   price_offset = layer_r * sin(theta)         -- ranges from -r to +r
//
// segments_per_half is the user-configured segment count PER HALF-CIRCLE
// (per spec). For a full closed ellipse we need top + bottom halves, so
// the total point count around the loop is 2 * segments_per_half.
create_ring_layer(a_time, a_price, T_hours, layer_r, col, segments_per_half) =>
    total_segments = segments_per_half * 2
    points = array.new<chart.point>()
    for i = 0 to total_segments - 1
        theta        = 2.0 * math.pi * float(i) / float(total_segments)
        t_offset_hrs = T_hours / 2.0 * (1.0 + math.cos(theta))
        p_offset     = layer_r * math.sin(theta)
        pt_time      = a_time + int(t_offset_hrs * MS_PER_HOUR)
        pt_price     = a_price + p_offset
        array.push(points, chart.point.from_time(pt_time, pt_price))
    polyline.new(points, closed = true, xloc = xloc.bar_time,
         line_color = col, line_width = 1)

// Creates a time-horizon label at the top of a ring.
//
// Uses a filled label style (session-color background + white text) so the
// label is legible on both light and dark chart backgrounds. The background
// opacity is high enough to stay subtle but low enough to read against any
// chart theme.
create_ring_label(a_time, a_price, T_hours, ring_radius, base_color, fade_add) =>
    // Background opacity: starts at 75 (subtle but visible), fades with the rest.
    bg_op   = math.min(75 + fade_add, 100)
    // Text opacity: starts at 20 (essentially full white), fades with the rest.
    text_op = math.min(20 + fade_add, 100)
    lbl_time  = a_time + int(T_hours / 2.0 * MS_PER_HOUR)
    lbl_price = a_price + ring_radius * layer_radius_outer
    h_text = T_hours == math.floor(T_hours)
         ? str.tostring(int(T_hours)) + "H"
         : str.tostring(T_hours, "#.#") + "H"
    label.new(x = lbl_time, y = lbl_price, text = h_text,
         xloc      = xloc.bar_time,
         style     = label.style_label_down,
         color     = color.new(base_color, bg_op),
         textcolor = color.new(color.white, text_op),
         size      = size.tiny)

// Creates the anchor marker (filled dot at session open).
//
// When multiple session anchors share the same open time (e.g. Asia + Daily
// both at 00:00 UTC), their dots would stack on top of each other. To keep
// both visible, we offset this dot vertically based on how many OTHER
// anchors share the same open time and have higher stacking priority.
// The rings themselves anchor at the TRUE open price — only the dot shifts.
//
// When no other session opens at this time, `overlap_rank` is 0 and the
// dot sits at the true price (no visual change).
create_anchor_marker(a_time, a_price, base_color, stype, h_atr, overlap_rank) =>
    sname = get_session_name(stype)
    tip   = sname + " Open: " +
         str.format_time(a_time, "yyyy-MM-dd HH:mm", "UTC") + " UTC"
    offset_per    = h_atr * 0.15
    dot_price_adj = a_price + offset_per * float(overlap_rank)
    label.new(x = a_time, y = dot_price_adj, text = "",
         xloc    = xloc.bar_time,
         style   = label.style_circle,
         color   = base_color,
         size    = size.small,
         tooltip = tip)

// Creates the glow line from anchor to current price.
create_glow_line(a_time, a_price, base_color) =>
    line.new(x1 = a_time, y1 = a_price, x2 = time, y2 = close,
         xloc  = xloc.bar_time,
         color = color.new(base_color, 75),
         width = 1,
         style = line.style_solid)

// ═══════════════════════════════════════════════════════════════════════════════
// PER-ANCHOR DRAWING LIFECYCLE
// ═══════════════════════════════════════════════════════════════════════════════

// Deletes all drawing objects belonging to the given anchor and clears its
// internal drawing arrays. The anchor itself is not removed from its parent
// session-array -- that is the caller's responsibility.
clear_anchor_drawings(SessionAnchor anc) =>
    if array.size(anc.ring_polylines) > 0
        for i = 0 to array.size(anc.ring_polylines) - 1
            polyline.delete(array.get(anc.ring_polylines, i))
        array.clear(anc.ring_polylines)
    if array.size(anc.ring_labels) > 0
        for i = 0 to array.size(anc.ring_labels) - 1
            label.delete(array.get(anc.ring_labels, i))
        array.clear(anc.ring_labels)
    if not na(anc.glow_line)
        line.delete(anc.glow_line)
        anc.glow_line := na
    if not na(anc.anchor_marker)
        label.delete(anc.anchor_marker)
        anc.anchor_marker := na

// Redraws all drawing objects for a single anchor based on its current state.
// Returns true if a price echo was drawn for this anchor (so the caller can
// suppress further price echoes -- only one echo per chart, for most recent
// active session).
redraw_anchor(SessionAnchor anc, bool echo_already_drawn) =>
    clear_anchor_drawings(anc)

    result_echo_done = echo_already_drawn

    if anc.is_active or anc.is_fading
        base_color = get_session_color(anc.session_type)
        horizons   = get_horizons(anc.session_type)

        // Fade-related opacity addition.
        // Active state: fade_add = 0 (full brightness).
        // Fading state: fade_add increases linearly so all layers reach
        // full transparency (100) by the end of the fade period.
        fade_add = 0
        if anc.is_fading and fade_bars_effective > 0
            fade_frac = math.min(
                 float(anc.fade_progress_bars) / float(fade_bars_effective), 1.0)
            fade_add := int(fade_frac * float(100 - layer_opacity_inner))

        // Draw rings: 3 polyline layers + 1 label per horizon.
        //
        // Rings whose time horizon is smaller than `min_horizon_tf_ratio` times
        // the chart timeframe are skipped. At those sizes each ring segment
        // spans only one or two bars, causing the ring to render as jagged
        // rectangles rather than a smooth curve. Suppressing them keeps the
        // visual clean on higher timeframes (e.g. 1H ring on a 30m chart).
        if array.size(horizons) > 0
            for h = 0 to array.size(horizons) - 1
                T_hours      = array.get(horizons, h)
                ring_seconds = T_hours * 3600.0
                ring_renders = ring_seconds >= float(tf_seconds) * min_horizon_tf_ratio

                if ring_renders
                    ring_radius = calc_ring_radius(hourly_atr, T_hours, scaling_multiplier)

                    // Inner highlight layer (brightest)
                    inner_op = math.min(layer_opacity_inner + fade_add, 100)
                    pl_inner = create_ring_layer(anc.anchor_time, anc.anchor_price,
                         T_hours, ring_radius * layer_radius_inner,
                         color.new(base_color, inner_op), ring_segments)
                    array.push(anc.ring_polylines, pl_inner)

                    // Primary ring layer (middle brightness)
                    middle_op = math.min(layer_opacity_middle + fade_add, 100)
                    pl_middle = create_ring_layer(anc.anchor_time, anc.anchor_price,
                         T_hours, ring_radius * layer_radius_middle,
                         color.new(base_color, middle_op), ring_segments)
                    array.push(anc.ring_polylines, pl_middle)

                    // Outer halo layer (faintest)
                    outer_op = math.min(layer_opacity_outer + fade_add, 100)
                    pl_outer = create_ring_layer(anc.anchor_time, anc.anchor_price,
                         T_hours, ring_radius * layer_radius_outer,
                         color.new(base_color, outer_op), ring_segments)
                    array.push(anc.ring_polylines, pl_outer)

                    // Ring time-horizon label
                    if show_ring_labels
                        lbl = create_ring_label(anc.anchor_time, anc.anchor_price,
                             T_hours, ring_radius, base_color, fade_add)
                        array.push(anc.ring_labels, lbl)

        // Anchor marker (filled dot at session open).
        //
        // Overlap detection: count how many OTHER sessions have an anchor at
        // the exact same anchor_time AND have a higher stacking priority
        // (lower stack_index). This is the rank at which this dot should sit
        // in the vertical stack. A session with no overlaps gets rank 0 and
        // sits at its true anchor price.
        if show_anchor_marker
            my_stack_idx = get_session_stack_index(anc.session_type)
            overlap_rank = 0

            // Count higher-priority anchors coinciding with this one.
            // Check all four session arrays.
            if array.size(anchors_daily) > 0
                for oi = 0 to array.size(anchors_daily) - 1
                    other = array.get(anchors_daily, oi)
                    if other.anchor_time == anc.anchor_time and
                         (other.is_active or other.is_fading) and
                         get_session_stack_index(other.session_type) < my_stack_idx
                        overlap_rank += 1
            if array.size(anchors_asia) > 0
                for oi = 0 to array.size(anchors_asia) - 1
                    other = array.get(anchors_asia, oi)
                    if other.anchor_time == anc.anchor_time and
                         (other.is_active or other.is_fading) and
                         get_session_stack_index(other.session_type) < my_stack_idx
                        overlap_rank += 1
            if array.size(anchors_london) > 0
                for oi = 0 to array.size(anchors_london) - 1
                    other = array.get(anchors_london, oi)
                    if other.anchor_time == anc.anchor_time and
                         (other.is_active or other.is_fading) and
                         get_session_stack_index(other.session_type) < my_stack_idx
                        overlap_rank += 1
            if array.size(anchors_ny) > 0
                for oi = 0 to array.size(anchors_ny) - 1
                    other = array.get(anchors_ny, oi)
                    if other.anchor_time == anc.anchor_time and
                         (other.is_active or other.is_fading) and
                         get_session_stack_index(other.session_type) < my_stack_idx
                        overlap_rank += 1

            anc.anchor_marker := create_anchor_marker(anc.anchor_time,
                 anc.anchor_price, base_color, anc.session_type,
                 hourly_atr, overlap_rank)

        // Glow line: only while the session is Active. Deleted immediately
        // when the session ends (does not participate in the fade).
        if anc.is_active and show_glow_line
            anc.glow_line := create_glow_line(anc.anchor_time,
                 anc.anchor_price, base_color)

        // Price echo: only for the most recently active anchor on the chart.
        if anc.is_active and not result_echo_done and show_price_echo
            // Drawn as a transient label; owned by the price_echo_label global.
            // See MAIN DRAWING LOGIC section below.
            result_echo_done := true

    result_echo_done

// ═══════════════════════════════════════════════════════════════════════════════
// ANCHOR STATE TRANSITIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Creates a new anchor for the given session type. Transitions any previously
// active anchor to the fading state, and enforces the max-anchors-per-type
// limit by removing the oldest entry when full (including its drawings).
create_anchor(stype, arr) =>
    // Any currently active anchor becomes fading.
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            a = array.get(arr, i)
            if a.is_active
                a.is_active          := false
                a.is_fading          := true
                a.fade_progress_bars := 0
    // Enforce max anchors: delete drawings of the oldest, then remove it.
    while array.size(arr) >= max_sessions_per_type
        oldest = array.shift(arr)
        clear_anchor_drawings(oldest)
    // Create the new anchor at the current bar's open.
    new_anchor = SessionAnchor.new(
         session_type       = stype,
         anchor_time        = time,
         anchor_bar_index   = bar_index,
         anchor_price       = open,
         is_active          = true,
         is_fading          = false,
         fade_progress_bars = 0,
         ring_polylines     = array.new<polyline>(),
         glow_line          = na,
         anchor_marker      = na,
         ring_labels        = array.new<label>())
    array.push(arr, new_anchor)

// Advances fade counters and removes (with cleanup) anchors that have fully
// faded.
update_fading(arr) =>
    i = array.size(arr) - 1
    while i >= 0
        a = array.get(arr, i)
        if a.is_fading
            a.fade_progress_bars += 1
            if a.fade_progress_bars >= fade_bars_effective
                clear_anchor_drawings(a)
                array.remove(arr, i)
        i -= 1

// Marks all active anchors in the array as fading (used on session close).
mark_session_closed(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            a = array.get(arr, i)
            if a.is_active
                a.is_active          := false
                a.is_fading          := true
                a.fade_progress_bars := 0

// ── Process session events on each confirmed bar ──────────────────────────────
if is_valid_tf and barstate.isconfirmed
    update_fading(anchors_asia)
    update_fading(anchors_london)
    update_fading(anchors_ny)
    update_fading(anchors_daily)

    if asia_just_closed
        mark_session_closed(anchors_asia)
    if london_just_closed
        mark_session_closed(anchors_london)
    if ny_just_closed
        mark_session_closed(anchors_ny)
    // Daily has no explicit close -- it fades when the next daily open arrives,
    // handled inside create_anchor() which transitions active -> fading.

    if not is_weekend
        if is_daily_plus
            // On daily+ timeframes, only Daily anchors are meaningful.
            if show_daily and daily_just_opened
                create_anchor(SESS_DAILY, anchors_daily)
        else
            if show_asia and asia_just_opened
                create_anchor(SESS_ASIA, anchors_asia)
            if show_london and london_just_opened
                create_anchor(SESS_LONDON, anchors_london)
            if show_ny and ny_just_opened
                create_anchor(SESS_NY, anchors_ny)
            if show_daily and daily_just_opened
                create_anchor(SESS_DAILY, anchors_daily)

// ═══════════════════════════════════════════════════════════════════════════════
// POLYLINE BUDGET SAFEGUARD
// ═══════════════════════════════════════════════════════════════════════════════

// Counts the projected polyline count for one anchor array.
count_polylines_for(arr) =>
    total = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            anc = array.get(arr, i)
            if anc.is_active or anc.is_fading
                horizons = get_horizons(anc.session_type)
                total += array.size(horizons) * 3   // 3 layers per ring
    total

// Removes the oldest fading anchor from the array (with drawing cleanup).
// Returns true if one was removed.
trim_oldest_fading(arr) =>
    removed = false
    j = 0
    while j < array.size(arr) and not removed
        a = array.get(arr, j)
        if a.is_fading
            clear_anchor_drawings(a)
            array.remove(arr, j)
            removed := true
        j += 1
    removed

// Trims the oldest fading anchors until the projected polyline count is
// within the safety threshold. Prevents hitting Pine's hard 100-polyline
// limit, which would cause visual glitches.
trim_to_budget() =>
    total = count_polylines_for(anchors_asia)
         + count_polylines_for(anchors_london)
         + count_polylines_for(anchors_ny)
         + count_polylines_for(anchors_daily)
    safety_loops = 0
    while total > POLYLINE_BUDGET_LIMIT and safety_loops < 12
        did_trim = trim_oldest_fading(anchors_asia)
        if not did_trim
            did_trim := trim_oldest_fading(anchors_london)
        if not did_trim
            did_trim := trim_oldest_fading(anchors_ny)
        if not did_trim
            did_trim := trim_oldest_fading(anchors_daily)
        if not did_trim
            break   // nothing left to trim
        total := count_polylines_for(anchors_asia)
             + count_polylines_for(anchors_london)
             + count_polylines_for(anchors_ny)
             + count_polylines_for(anchors_daily)
        safety_loops += 1

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DRAWING LOGIC — runs on the last bar
// ═══════════════════════════════════════════════════════════════════════════════

// The price echo is a single global label (only one can exist on the chart at
// a time -- it shows the current price "ping" for the most recently active
// session).
var label price_echo_label = na

// Helper: redraws every anchor in one session array, updating echo_done flag.
redraw_all_in(arr, bool echo_done) =>
    result_echo_done = echo_done
    if array.size(arr) > 0
        // Iterate from newest to oldest so the most recent active anchor
        // gets priority for the price echo.
        i = array.size(arr) - 1
        while i >= 0
            anc = array.get(arr, i)
            result_echo_done := redraw_anchor(anc, result_echo_done)
            i -= 1
    result_echo_done

if barstate.islast and is_valid_tf and not na(hourly_atr) and hourly_atr > 0
    // Stay within the polyline budget before drawing.
    trim_to_budget()

    // Redraw every anchor (each owns its own drawing objects).
    echo_drawn = false
    echo_drawn := redraw_all_in(anchors_london, echo_drawn)
    echo_drawn := redraw_all_in(anchors_ny,     echo_drawn)
    echo_drawn := redraw_all_in(anchors_asia,   echo_drawn)
    echo_drawn := redraw_all_in(anchors_daily,  echo_drawn)

    // Delete previous price echo and draw a new one if an active anchor exists.
    if not na(price_echo_label)
        label.delete(price_echo_label)
        price_echo_label := na

    if echo_drawn and show_price_echo
        // Find the most recent active anchor to get its color for the echo.
        echo_color = color.gray
        found = false
        // Check in priority order: London, NY, Asia, Daily.
        if not found and array.size(anchors_london) > 0
            for i = array.size(anchors_london) - 1 to 0
                a = array.get(anchors_london, i)
                if a.is_active
                    echo_color := get_session_color(a.session_type)
                    found := true
                    break
        if not found and array.size(anchors_ny) > 0
            for i = array.size(anchors_ny) - 1 to 0
                a = array.get(anchors_ny, i)
                if a.is_active
                    echo_color := get_session_color(a.session_type)
                    found := true
                    break
        if not found and array.size(anchors_asia) > 0
            for i = array.size(anchors_asia) - 1 to 0
                a = array.get(anchors_asia, i)
                if a.is_active
                    echo_color := get_session_color(a.session_type)
                    found := true
                    break
        if not found and array.size(anchors_daily) > 0
            for i = array.size(anchors_daily) - 1 to 0
                a = array.get(anchors_daily, i)
                if a.is_active
                    echo_color := get_session_color(a.session_type)
                    found := true
                    break

        if found
            price_echo_label := label.new(x = time, y = close, text = "",
                 xloc    = xloc.bar_time,
                 style   = label.style_circle,
                 color   = color.new(echo_color, 40),
                 size    = size.tiny,
                 tooltip = "Current price position within the envelope")

// ═══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````
