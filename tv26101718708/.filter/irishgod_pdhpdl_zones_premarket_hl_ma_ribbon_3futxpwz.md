# IrishGOD PDH/PDL Zones + Pre-Market H/L + MA Ribbon

- url: https://www.tradingview.com/script/3FuTXPWZ-IrishGOD-PDH-PDL-Zones-Pre-Market-H-L-MA-Ribbon/
- type: indicator
- pine_id: PUB;ae124365ae6844bc8a96615e50c0dc5f
- version: 4.0

## Description

PDH/PDL Zones + Pre-Market H/L + MA Ribbon

A comprehensive overlay indicator for TradingView (Pine Script v5) that combines three institutional-grade tools on a single chart: historical previous-day high/low zones drawn from full candle wicks, intraday pre-market extremes, and a fully configurable multi-timeframe moving average ribbon. Designed for intraday traders who need clean, actionable levels without switching between charts or timeframes.

Pine Script v5
Overlay
Intraday
Multi-Timeframe
Alerts Included
1
Previous Day High / Low Zones

Automatically identifies the highest and lowest candle of each prior session and draws a shaded zone that spans the full wick of that candle — from the wick tip (the session extreme) down to the candle body edge (max or min of open/close). This provides a realistically sized supply or demand zone rather than a single horizontal line, accurately representing the price range where the reversal originated. Zones are stored across up to 50 prior trading days and drawn efficiently on the last bar to avoid unnecessary repainting.

Lookback

Up to 50 previous days retained and displayed simultaneously

Zone geometry

Wick tip → candle body edge; minimum 4-tick thickness for doji candles

Extension

Most recent zone optionally extends to the right edge of the chart

Labels

PDH / PDL price labels on the latest zone; four size options

Color picker
Border width 0–4px
Adjustable opacity
Toggle on/off
2
Pre-Market High / Low

Tracks the highest high and lowest low recorded during the configurable pre-market window (default 4:00–9:30 AM Eastern Time) and draws horizontal lines at those levels the moment the regular session opens. These levels are widely watched by professional traders as the first potential support and resistance areas of the day, and are particularly relevant on gap-up or gap-down open days. All time calculations are anchored to America/New_York to handle daylight saving time correctly.

Session window

Fully configurable start hour, end hour, and end minute (24h ET)

Line style

Solid, dashed, or dotted; line width 1–4px

Extension

Lines optionally extend rightward through the rest of the session

Labels

"PM High" / "PM Low" labels with exact price values

Requires a TradingView subscription that includes extended-hours data. Levels reset each new trading day.

3
Multi-Timeframe MA Ribbon

A ribbon of up to 8 independent moving averages rendered directly on the price chart. Each MA is fully self-contained: it has its own toggle, length, color, and — critically — its own timeframe selector. This allows a single ribbon to simultaneously display a short-term trend on the current chart timeframe alongside higher-timeframe MAs (e.g. a daily 21 EMA or a weekly 50 SMA) without opening additional chart panes. When an alternate timeframe is active, the value label automatically appends a [TF] tag for instant visual identification.

MA types available

SMA
EMA
WMA
VWMA
HMA
DEMA
TEMA
RMA
LSMA
Ribbon count

8 MAs; MAs 1–5 enabled by default (lengths 8, 13, 21, 34, 55)

Per-MA timeframe

Each MA resolves on its own timeframe via request.security(); blank = current chart

Fill

Gradient color fill between consecutive MA lines; adjustable opacity

Value labels

Live price labels pinned to the right edge; show [TF] tag for HTF MAs

Source

Configurable price source: close, open, high, low, hl2, hlc3, ohlc4, etc.

Line width

Global line width control (1–4px) applied to all active MAs

lookahead=barmerge.lookahead_off is enforced on all request.security() calls to prevent higher-timeframe data leakage into historical bars.

4
Alerts

Five built-in alert conditions, configurable from TradingView's alert dialog:

Price enters the most recent PDH zone (within 0.1%)
Price enters the most recent PDL zone (within 0.1%)
Price enters either PDH or PDL zone
MA1 crosses above MA2 — bullish signal
MA1 crosses below MA2 — bearish signal
5
Technical notes

Compatibility

Intraday charts (1m – 4h). Requires extended-hours data for pre-market feature.

Object limits

max_boxes_count 500 · max_lines_count 500 · max_labels_count 200

Rendering

PDH/PDL boxes drawn only on barstate.islast to eliminate per-tick redraw overhead

DST handling

All session time logic uses America/New_York timezone natively

## Source Code

````pine
//@version=5
indicator(title="PDH/PDL Zones + Pre-Market H/L + MA Ribbon", 
     shorttitle="PDH/PDL + PM + MA", 
     overlay=true, 
     max_boxes_count=500, 
     max_lines_count=500,
     max_labels_count=200,
     max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════════════
// GROUP: Previous Day High/Low Zone Settings
// ══════════════════════════════════════════════════════════════════════════════
grp_pdhl = "── Previous Day High / Low Zones ──"

show_pdhl         = input.bool(true,  "Show PDH/PDL Zones",           group=grp_pdhl)
pdhl_lookback     = input.int(50,     "Lookback Days",                 group=grp_pdhl, minval=1, maxval=50, tooltip="Number of previous days to display zones for (max 50)")
pdh_color         = input.color(color.new(#26a69a, 75), "High Zone Color",  group=grp_pdhl)
pdl_color         = input.color(color.new(#ef5350, 75), "Low Zone Color",   group=grp_pdhl)
pdhl_border_width = input.int(1,     "Zone Border Width",             group=grp_pdhl, minval=0, maxval=4)
extend_zones      = input.bool(true,  "Extend Latest Zone to Right",  group=grp_pdhl, tooltip="Extends the most recent day's zones to the right edge")
show_pdhl_labels  = input.bool(true,  "Show Zone Labels",             group=grp_pdhl)
label_size_pdhl   = input.string("small", "Label Size",               group=grp_pdhl, options=["tiny","small","normal","large"])

// ══════════════════════════════════════════════════════════════════════════════
// GROUP: Pre-Market High/Low Settings
// ══════════════════════════════════════════════════════════════════════════════
grp_pm = "── Pre-Market High / Low ──"

show_pm           = input.bool(true,  "Show Pre-Market H/L",          group=grp_pm)
pm_high_color     = input.color(color.new(#00bcd4, 60), "Pre-Market High Color", group=grp_pm)
pm_low_color      = input.color(color.new(#ff9800, 60), "Pre-Market Low Color",  group=grp_pm)
pm_line_style     = input.string("dashed", "Line Style",              group=grp_pm, options=["solid","dashed","dotted"])
pm_line_width     = input.int(1,      "Line Width",                   group=grp_pm, minval=1, maxval=4)
extend_pm         = input.bool(true,  "Extend PM Lines to Right",     group=grp_pm)
show_pm_labels    = input.bool(true,  "Show PM Labels",               group=grp_pm)
pm_start_hour     = input.int(4,      "Pre-Market Start Hour (24h)",  group=grp_pm, minval=0, maxval=23, tooltip="Hour when pre-market begins (Eastern Time). Default: 4 AM ET")
pm_end_hour       = input.int(9,      "Pre-Market End Hour (24h)",    group=grp_pm, minval=0, maxval=23, tooltip="Hour when regular session begins (Eastern Time). Default: 9 AM ET")
pm_end_min        = input.int(30,     "Pre-Market End Minute",        group=grp_pm, minval=0, maxval=59)

// ══════════════════════════════════════════════════════════════════════════════
// GROUP: MA Ribbon Settings
// ══════════════════════════════════════════════════════════════════════════════
grp_ma = "── MA Ribbon ──"

show_ma_ribbon    = input.bool(true,  "Show MA Ribbon",               group=grp_ma)
ma_source         = input.source(close, "Source",                     group=grp_ma)
ma_type           = input.string("EMA", "MA Type",                    group=grp_ma, options=["SMA","EMA","WMA","VWMA","HMA","DEMA","TEMA","RMA","LSMA"])

// MA 1  — toggle | length | color | timeframe (blank = current chart)
show_ma1          = input.bool(true,   "MA 1",  group=grp_ma, inline="ma1")
ma1_len           = input.int(8,       "",       group=grp_ma, inline="ma1", minval=1)
ma1_color         = input.color(#ff6b6b, "",     group=grp_ma, inline="ma1")
ma1_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma1", tooltip="Leave blank to use the current chart timeframe")

// MA 2
show_ma2          = input.bool(true,   "MA 2",  group=grp_ma, inline="ma2")
ma2_len           = input.int(13,      "",       group=grp_ma, inline="ma2", minval=1)
ma2_color         = input.color(#ffa94d, "",     group=grp_ma, inline="ma2")
ma2_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma2", tooltip="Leave blank to use the current chart timeframe")

// MA 3
show_ma3          = input.bool(true,   "MA 3",  group=grp_ma, inline="ma3")
ma3_len           = input.int(21,      "",       group=grp_ma, inline="ma3", minval=1)
ma3_color         = input.color(#ffe066, "",     group=grp_ma, inline="ma3")
ma3_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma3", tooltip="Leave blank to use the current chart timeframe")

// MA 4
show_ma4          = input.bool(true,   "MA 4",  group=grp_ma, inline="ma4")
ma4_len           = input.int(34,      "",       group=grp_ma, inline="ma4", minval=1)
ma4_color         = input.color(#69db7c, "",     group=grp_ma, inline="ma4")
ma4_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma4", tooltip="Leave blank to use the current chart timeframe")

// MA 5
show_ma5          = input.bool(true,   "MA 5",  group=grp_ma, inline="ma5")
ma5_len           = input.int(55,      "",       group=grp_ma, inline="ma5", minval=1)
ma5_color         = input.color(#4dabf7, "",     group=grp_ma, inline="ma5")
ma5_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma5", tooltip="Leave blank to use the current chart timeframe")

// MA 6
show_ma6          = input.bool(false,  "MA 6",  group=grp_ma, inline="ma6")
ma6_len           = input.int(89,      "",       group=grp_ma, inline="ma6", minval=1)
ma6_color         = input.color(#9775fa, "",     group=grp_ma, inline="ma6")
ma6_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma6", tooltip="Leave blank to use the current chart timeframe")

// MA 7
show_ma7          = input.bool(false,  "MA 7",  group=grp_ma, inline="ma7")
ma7_len           = input.int(144,     "",       group=grp_ma, inline="ma7", minval=1)
ma7_color         = input.color(#f783ac, "",     group=grp_ma, inline="ma7")
ma7_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma7", tooltip="Leave blank to use the current chart timeframe")

// MA 8
show_ma8          = input.bool(false,  "MA 8",  group=grp_ma, inline="ma8")
ma8_len           = input.int(200,     "",       group=grp_ma, inline="ma8", minval=1)
ma8_color         = input.color(#ffffff, "",     group=grp_ma, inline="ma8")
ma8_tf            = input.timeframe("", "TF",    group=grp_ma, inline="ma8", tooltip="Leave blank to use the current chart timeframe")

ma_line_width     = input.int(1,      "Line Width",                   group=grp_ma, minval=1, maxval=4)
fill_ribbon       = input.bool(true,  "Fill Between MAs",             group=grp_ma, tooltip="Fills color between consecutive MA lines")
fill_opacity      = input.int(90,     "Fill Opacity (0=solid, 100=transparent)", group=grp_ma, minval=0, maxval=100)
show_ma_labels    = input.bool(true,  "Show MA Value Labels",         group=grp_ma)

// ══════════════════════════════════════════════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Universal MA calculator
calcMA(src, len, maType) =>
    switch maType
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        "HMA"  => ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        "DEMA" =>
            e = ta.ema(src, len)
            2 * e - ta.ema(e, len)
        "TEMA" =>
            e1 = ta.ema(src, len)
            e2 = ta.ema(e1, len)
            e3 = ta.ema(e2, len)
            3 * e1 - 3 * e2 + e3
        "LSMA" => ta.linreg(src, len, 0)
        => ta.ema(src, len)

// Line style helper
lineStyleHelper(s) =>
    switch s
        "dashed" => line.style_dashed
        "dotted"  => line.style_dotted
        => line.style_solid

// Label size helper
labelSizeHelper(s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        "large"  => size.large
        => size.small

// ══════════════════════════════════════════════════════════════════════════════
// PREVIOUS DAY HIGH / LOW ZONES
// ══════════════════════════════════════════════════════════════════════════════
// Architecture:
//   - Scan every intraday bar to track the SPECIFIC CANDLE that set the session
//     high and the session low within the NY regular session (9:30–16:00 ET).
//   - Store only timestamps (never bar_index) so xloc.bar_time boxes work and
//     no deep historical buffer is needed.
//   - Zone top/bottom = the full wick of that candle:
//       PDH zone: top = candle high (wick tip), bottom = max(open,close) of that candle
//       PDL zone: top = min(open,close) of that candle, bottom = candle low (wick tip)
//   - On session close, snapshot the extreme-candle data into arrays.
//   - Draw (with delete-first) on every barstate.islast update.

// ── NY regular session detection ─────────────────────────────────────────────
ny_session_str = "0930-1600:23456"
in_ny_session  = timeframe.isintraday and not na(time(timeframe.period, ny_session_str, "America/New_York"))
is_new_day     = timeframe.isintraday and session.isfirstbar

// Detect the LAST bar of the NY session: in_ny_session was true but is now false.
// This fires on the first bar AFTER the session closes — a clean, unambiguous signal
// that doesn't race with any accumulator reset.
var bool prev_in_ny  = false
is_ny_close = not in_ny_session and prev_in_ny   // just left the session
is_ny_open  = in_ny_session and not prev_in_ny   // just entered the session
prev_in_ny := in_ny_session

// ── Intraday accumulators ─────────────────────────────────────────────────────
// Tracks the specific candle that set the session HIGH and LOW.
// Reset ONLY when the session opens; snapshot ONLY when the session closes.
// These two events are on different bars — no race condition possible.
var float ses_high       = na
var float ses_high_body  = na
var float ses_low        = na
var float ses_low_body   = na
var int   ses_start_time = na
var int   ses_end_time   = na

// Reset on the first bar of the NY session
if is_ny_open
    ses_high       := na
    ses_low        := na
    ses_high_body  := na
    ses_low_body   := na
    ses_start_time := time
    ses_end_time   := time

// Update on every bar INSIDE the session
if in_ny_session
    ses_end_time := time
    if na(ses_high) or high > ses_high
        ses_high      := high
        ses_high_body := math.max(open, close)
    if na(ses_low) or low < ses_low
        ses_low      := low
        ses_low_body := math.min(open, close)

// ── Completed-day storage arrays ─────────────────────────────────────────────
var int[]   arr_t_start   = array.new_int(0)
var int[]   arr_t_end     = array.new_int(0)
var float[] arr_high_wick = array.new_float(0)
var float[] arr_high_body = array.new_float(0)
var float[] arr_low_wick  = array.new_float(0)
var float[] arr_low_body  = array.new_float(0)

// Box/label handles — cleared before each redraw to prevent stacking
var box[]   arr_boxes_h = array.new_box(0)
var box[]   arr_boxes_l = array.new_box(0)
var label[] arr_labels  = array.new_label(0)

// Snapshot on the first bar AFTER the session closes.
// At this point in_ny_session just became false, so the accumulators hold the
// fully completed session values — no reset has happened yet.
if is_ny_close and not na(ses_high) and not na(ses_low)
    array.push(arr_t_start,   ses_start_time)
    array.push(arr_t_end,     ses_end_time)
    array.push(arr_high_wick, ses_high)
    array.push(arr_high_body, ses_high_body)
    array.push(arr_low_wick,  ses_low)
    array.push(arr_low_body,  ses_low_body)

    if array.size(arr_t_start) > pdhl_lookback
        array.shift(arr_t_start)
        array.shift(arr_t_end)
        array.shift(arr_high_wick)
        array.shift(arr_high_body)
        array.shift(arr_low_wick)
        array.shift(arr_low_body)

// ── Helper: draw one PDH+PDL zone pair (must be at global scope) ─────────────
drawZonePair(t_left, t_right, dhw, dhb, dlw, dlb, isLatest) =>
    min_tick    = syminfo.mintick * 4
    high_top    = dhw
    high_bottom = dhb > dhw - min_tick ? dhw - min_tick : dhb
    low_top     = dlb < dlw + min_tick ? dlw + min_tick : dlb
    low_bottom  = dlw

    bh = box.new(left=t_left, top=high_top, right=t_right, bottom=high_bottom,
         border_color=color.new(pdh_color, 40), border_width=pdhl_border_width,
         bgcolor=pdh_color, xloc=xloc.bar_time)
    array.push(arr_boxes_h, bh)

    bl = box.new(left=t_left, top=low_top, right=t_right, bottom=low_bottom,
         border_color=color.new(pdl_color, 40), border_width=pdhl_border_width,
         bgcolor=pdl_color, xloc=xloc.bar_time)
    array.push(arr_boxes_l, bl)

    if show_pdhl_labels and isLatest
        lh = label.new(x=t_right, y=dhw, text="PDH " + str.tostring(dhw, format.mintick),
             color=color.new(pdh_color, 20), textcolor=color.white,
             style=label.style_label_left, size=labelSizeHelper(label_size_pdhl),
             xloc=xloc.bar_time)
        ll = label.new(x=t_right, y=dlw, text="PDL " + str.tostring(dlw, format.mintick),
             color=color.new(pdl_color, 20), textcolor=color.white,
             style=label.style_label_left, size=labelSizeHelper(label_size_pdhl),
             xloc=xloc.bar_time)
        array.push(arr_labels, lh)
        array.push(arr_labels, ll)

// ── Draw zones on every barstate.islast (delete first to prevent stacking) ───
if barstate.islast and show_pdhl and timeframe.isintraday
    for b in arr_boxes_h
        box.delete(b)
    for b in arr_boxes_l
        box.delete(b)
    for l in arr_labels
        label.delete(l)
    array.clear(arr_boxes_h)
    array.clear(arr_boxes_l)
    array.clear(arr_labels)

    bar_ms = timeframe.multiplier * 60 * 1000

    // Draw all completed prior sessions.
    // The LAST entry in the array = the most recent completed session = true PDH/PDL.
    // It gets isLatest=true so it receives the label and right-extension.
    // All older sessions are drawn over their own historical time range only.
    n = array.size(arr_t_start)
    if n > 0
        for i = 0 to n - 1
            t_s      = array.get(arr_t_start,   i)
            t_e      = array.get(arr_t_end,     i)
            dhw      = array.get(arr_high_wick, i)
            dhb      = array.get(arr_high_body, i)
            dlw      = array.get(arr_low_wick,  i)
            dlb      = array.get(arr_low_body,  i)
            isLatest = i == n - 1
            // Most recent completed session: extend to the current bar's timestamp
            // so the zone always reaches the right edge of the visible chart.
            // Adding bar_ms pushes it one bar further to ensure the box edge
            // isn't clipped at exactly the last bar.
            // All older sessions span only their own trading day.
            t_right  = isLatest and extend_zones ? time + bar_ms : t_e
            drawZonePair(t_s, t_right, dhw, dhb, dlw, dlb, isLatest)

// ══════════════════════════════════════════════════════════════════════════════
// PRE-MARKET HIGH / LOW
// ══════════════════════════════════════════════════════════════════════════════

// Detect pre-market bars
t_hour   = hour(time, "America/New_York")
t_minute = minute(time, "America/New_York")

is_premarket = timeframe.isintraday and 
     ((t_hour > pm_start_hour or (t_hour == pm_start_hour and t_minute >= 0)) and 
     (t_hour < pm_end_hour or (t_hour == pm_end_hour and t_minute < pm_end_min)))

is_regular_open = timeframe.isintraday and 
     t_hour == pm_end_hour and t_minute == pm_end_min

// Use timestamps throughout so no bar_index lookback is needed
var float pm_high       = na
var float pm_low        = na
var int   pm_t_start    = na   // timestamp of first pre-market bar
var line  pm_high_line  = na
var line  pm_low_line   = na
var label pm_high_lbl   = na
var label pm_low_lbl    = na

// Reset pre-market tracking each new regular session open
if is_new_day
    pm_high    := na
    pm_low     := na
    pm_t_start := na

// Accumulate pre-market data — store time, not bar_index
if is_premarket and show_pm
    if na(pm_t_start)
        pm_t_start := time
    pm_high := na(pm_high) ? high : math.max(pm_high, high)
    pm_low  := na(pm_low)  ? low  : math.min(pm_low, low)

// Draw pre-market lines when regular session opens
if is_regular_open and show_pm and not na(pm_high)
    if not na(pm_high_line)
        line.delete(pm_high_line)
    if not na(pm_low_line)
        line.delete(pm_low_line)
    if not na(pm_high_lbl)
        label.delete(pm_high_lbl)
    if not na(pm_low_lbl)
        label.delete(pm_low_lbl)

    lStyle = lineStyleHelper(pm_line_style)
    ext    = extend_pm ? extend.right : extend.none

    pm_high_line := line.new(x1=pm_t_start, y1=pm_high, x2=time, y2=pm_high,
         color=pm_high_color, width=pm_line_width, style=lStyle, extend=ext,
         xloc=xloc.bar_time)
    pm_low_line  := line.new(x1=pm_t_start, y1=pm_low,  x2=time, y2=pm_low,
         color=pm_low_color,  width=pm_line_width, style=lStyle, extend=ext,
         xloc=xloc.bar_time)

    if show_pm_labels
        pm_high_lbl := label.new(x=time, y=pm_high, text="PM High " + str.tostring(pm_high, format.mintick),
             color=color.new(pm_high_color, 20), textcolor=color.white,
             style=label.style_label_left, size=size.small, xloc=xloc.bar_time)
        pm_low_lbl  := label.new(x=time, y=pm_low,  text="PM Low " + str.tostring(pm_low, format.mintick),
             color=color.new(pm_low_color,  20), textcolor=color.white,
             style=label.style_label_left, size=size.small, xloc=xloc.bar_time)

// ══════════════════════════════════════════════════════════════════════════════
// MA RIBBON
// ══════════════════════════════════════════════════════════════════════════════

// Per-MA timeframe source resolution.
// request.security() is always called (PineScript requires it at global scope);
// the show flag gates whether the value is used downstream.
// When the timeframe input is blank ("") we pass timeframe.period so the
// request resolves on the current chart — identical to a plain calcMA() call.
tf1 = ma1_tf == "" ? timeframe.period : ma1_tf
tf2 = ma2_tf == "" ? timeframe.period : ma2_tf
tf3 = ma3_tf == "" ? timeframe.period : ma3_tf
tf4 = ma4_tf == "" ? timeframe.period : ma4_tf
tf5 = ma5_tf == "" ? timeframe.period : ma5_tf
tf6 = ma6_tf == "" ? timeframe.period : ma6_tf
tf7 = ma7_tf == "" ? timeframe.period : ma7_tf
tf8 = ma8_tf == "" ? timeframe.period : ma8_tf

// Fetch source on each MA's chosen timeframe, then compute the MA.
// lookahead=barmerge.lookahead_off prevents future-leak on higher TFs.
ma1_val = show_ma1 ? request.security(syminfo.tickerid, tf1, calcMA(ma_source, ma1_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma2_val = show_ma2 ? request.security(syminfo.tickerid, tf2, calcMA(ma_source, ma2_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma3_val = show_ma3 ? request.security(syminfo.tickerid, tf3, calcMA(ma_source, ma3_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma4_val = show_ma4 ? request.security(syminfo.tickerid, tf4, calcMA(ma_source, ma4_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma5_val = show_ma5 ? request.security(syminfo.tickerid, tf5, calcMA(ma_source, ma5_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma6_val = show_ma6 ? request.security(syminfo.tickerid, tf6, calcMA(ma_source, ma6_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma7_val = show_ma7 ? request.security(syminfo.tickerid, tf7, calcMA(ma_source, ma7_len, ma_type), lookahead=barmerge.lookahead_off) : na
ma8_val = show_ma8 ? request.security(syminfo.tickerid, tf8, calcMA(ma_source, ma8_len, ma_type), lookahead=barmerge.lookahead_off) : na

// Plot MAs
p1 = plot(show_ma_ribbon and show_ma1 ? ma1_val : na, "MA1", color=ma1_color, linewidth=ma_line_width)
p2 = plot(show_ma_ribbon and show_ma2 ? ma2_val : na, "MA2", color=ma2_color, linewidth=ma_line_width)
p3 = plot(show_ma_ribbon and show_ma3 ? ma3_val : na, "MA3", color=ma3_color, linewidth=ma_line_width)
p4 = plot(show_ma_ribbon and show_ma4 ? ma4_val : na, "MA4", color=ma4_color, linewidth=ma_line_width)
p5 = plot(show_ma_ribbon and show_ma5 ? ma5_val : na, "MA5", color=ma5_color, linewidth=ma_line_width)
p6 = plot(show_ma_ribbon and show_ma6 ? ma6_val : na, "MA6", color=ma6_color, linewidth=ma_line_width)
p7 = plot(show_ma_ribbon and show_ma7 ? ma7_val : na, "MA7", color=ma7_color, linewidth=ma_line_width)
p8 = plot(show_ma_ribbon and show_ma8 ? ma8_val : na, "MA8", color=ma8_color, linewidth=ma_line_width)

// Fill between consecutive active MAs
// fill() must be at global scope in PineScript — use na color to hide when disabled
fill_col(c1, c2, opac) =>
    (fill_ribbon and show_ma_ribbon) ? color.new(color.from_gradient(50, 0, 100, c1, c2), opac) : color.new(color.black, 100)

fill(p1, p2, color=fill_col(ma1_color, ma2_color, fill_opacity))
fill(p2, p3, color=fill_col(ma2_color, ma3_color, fill_opacity))
fill(p3, p4, color=fill_col(ma3_color, ma4_color, fill_opacity))
fill(p4, p5, color=fill_col(ma4_color, ma5_color, fill_opacity))
fill(p5, p6, color=fill_col(ma5_color, ma6_color, fill_opacity))
fill(p6, p7, color=fill_col(ma6_color, ma7_color, fill_opacity))
fill(p7, p8, color=fill_col(ma7_color, ma8_color, fill_opacity))

// MA Value Labels (on last bar)
// Helper: build label text — appends [TF] when an alternate timeframe is active
maLabel(maType, len, tf, val) =>
    tfTag = tf != timeframe.period ? " [" + tf + "]" : ""
    maType + str.tostring(len) + tfTag + ": " + str.tostring(val, format.mintick)

if show_ma_ribbon and show_ma_labels and barstate.islast
    if show_ma1 and not na(ma1_val)
        label.new(bar_index + 1, ma1_val, maLabel(ma_type, ma1_len, tf1, ma1_val),
             color=color.new(ma1_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma2 and not na(ma2_val)
        label.new(bar_index + 1, ma2_val, maLabel(ma_type, ma2_len, tf2, ma2_val),
             color=color.new(ma2_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma3 and not na(ma3_val)
        label.new(bar_index + 1, ma3_val, maLabel(ma_type, ma3_len, tf3, ma3_val),
             color=color.new(ma3_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma4 and not na(ma4_val)
        label.new(bar_index + 1, ma4_val, maLabel(ma_type, ma4_len, tf4, ma4_val),
             color=color.new(ma4_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma5 and not na(ma5_val)
        label.new(bar_index + 1, ma5_val, maLabel(ma_type, ma5_len, tf5, ma5_val),
             color=color.new(ma5_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma6 and not na(ma6_val)
        label.new(bar_index + 1, ma6_val, maLabel(ma_type, ma6_len, tf6, ma6_val),
             color=color.new(ma6_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma7 and not na(ma7_val)
        label.new(bar_index + 1, ma7_val, maLabel(ma_type, ma7_len, tf7, ma7_val),
             color=color.new(ma7_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if show_ma8 and not na(ma8_val)
        label.new(bar_index + 1, ma8_val, maLabel(ma_type, ma8_len, tf8, ma8_val),
             color=color.new(ma8_color, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

// Alert when price touches PDH zone (most recent)
// Use ternary guards so array.get() is never called when the array is empty (bar 0)
_pdh_size  = array.size(arr_high_wick)
_pdl_size  = array.size(arr_low_wick)
_last_pdh  = _pdh_size > 0 ? array.get(arr_high_wick, _pdh_size - 1) : na
_last_pdl  = _pdl_size > 0 ? array.get(arr_low_wick,  _pdl_size - 1) : na

pdh_touch  = show_pdhl and not na(_last_pdh) and math.abs(close - _last_pdh) / close < 0.001
pdl_touch  = show_pdhl and not na(_last_pdl) and math.abs(close - _last_pdl) / close < 0.001

alertcondition(pdh_touch, "Price at PDH Zone", "Price is touching the Previous Day High zone!")
alertcondition(pdl_touch, "Price at PDL Zone", "Price is touching the Previous Day Low zone!")
alertcondition(pdh_touch or pdl_touch, "Price at PDH or PDL Zone", "Price is touching a Previous Day H/L zone!")

// MA Cross alerts — ta.crossover/crossunder must be evaluated globally on every bar,
// not inside a conditional, to maintain consistent historical state.
_cross_up   = ta.crossover(ma1_val,  ma2_val)
_cross_down = ta.crossunder(ma1_val, ma2_val)
ma_bullish_cross = show_ma1 and show_ma2 and _cross_up
ma_bearish_cross = show_ma1 and show_ma2 and _cross_down
alertcondition(ma_bullish_cross, "MA Bullish Cross", "MA1 crossed above MA2 — Bullish signal")
alertcondition(ma_bearish_cross, "MA Bearish Cross", "MA1 crossed below MA2 — Bearish signal")
````
