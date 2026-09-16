<!-- tradingview-pine-id: PUB;b922910a1ad84ad2bca8abd49efe5253 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Projected High/Low [Market Breakers]

Source: https://www.tradingview.com/script/4MwsdV1u-Projected-High-Low-Market-Breakers/

## Description

Market Breakers — Projected High/Low

An intraday range-projection tool that anticipates where the day's high and low are likely to form. It sizes the expected daily range using a set of classic envelope formulas, measures where price establishes itself early in the RTH session, then projects target levels outward from those early extremes.

Credit
The envelope and range-projection math at the core of this script is adapted from formulas taught by George Angell in his older instructional videos. Full credit for the underlying concepts goes to his original work — this indicator simply ports that math into Pine Script and wraps it in session handling, a validity filter, and visualization. This is an open-source release so anyone can read, learn from, and build on the approach.

The Idea
Angell's method estimates a market's anticipated range for the session from recent price behavior, rather than reacting to price after it moves. This indicator takes that estimate and answers a practical question: if the market is going to travel its expected range, and it has already carved out these early highs and lows, where does that put the day's likely extremes?

So instead of drawing a static range, it anchors the projection to real, current-session structure.

How It Works
1. Anticipated Range — the envelope engine
At the start of each trading day the script builds two envelopes from the prior session's price action:

Sell Envelope — the average of four values: the session high, a trend-reaction pivot (2 × HLC3 − Low), a "buying high" push (High + 3-bar avg of High − prior High), and an anticipated rally (Low + 3-bar avg of High − prior Low).
Buy Envelope — the mirror: the session low, a trend-reaction pivot (2 × HLC3 − High), an anticipated decline, and an anticipated buy-under level.

The distance between the two envelopes is the Anticipated Range — the day's expected travel.

2. Early-session extremes
After the RTH open (default 09:30 exchange time), the script records the high and low of an early period (default: first 60 minutes). These become the anchors for the projection.

3. Projection
Once the early period completes:
Projected High = Early High + Anticipated Range
Projected Low = Early Low − Anticipated Range
Both levels plot as lines with labels, and the space between them is lightly shaded.
Validity filter
Projections only print if the early-period range is at least 20% of the Anticipated Range. A dead, rangeless open won't produce meaningful anchors, so the tool stays quiet rather than projecting off noise.

Session & Timezone Handling
The trading day rolls over at 18:00 (6 PM) exchange time to match the CME futures session, and the reference timezone is fully selectable (defaults to America/New_York). All session logic — day tracking, RTH open, early period — respects the chosen timezone.

Keltner Context Filter
An EMA basis with ATR-based bands provides a quick directional read. It's used as a bias readout (Bull / Bear in the summary table), not as a hard entry signal — context, not a trigger.

Features
Timezone-aware session and day tracking (18:00 futures rollover)
Prior-day envelope calculation for the Anticipated Range
Early-period high/low capture with a range-validity gate
Projected High / Low lines, labels, and shaded projection zone
Optional Keltner channels + Bull/Bear bias
On-chart summary table (range, early H/L, projections, TF, status)
Independent size and color controls for every label type
Alert fired when projections are set for the day
Settings Overview
Session Timing — exchange timezone, RTH session window, early-period length
Keltner Filter — length, multiplier, show/hide
Label Sizes — per-label size (projected high, projected low, range, session open)
Label Settings — offsets, price-on-label toggle, which labels to show
Label Colors — full color control per label
Visuals — line colors, envelope plot, Keltner color
Table — position and text size

How to Use
1.)Add it to an intraday chart of an index future — NQ / MNQ / ES / MES are the natural fit — on 
    a timeframe where the early period spans several bars (e.g. 1–15 min).
2.)Confirm the timezone matches your session; the default is New York.
3.)Let the early period complete. If the open had enough range, the projected high and low 
    print and the table shows ✅ Active.
4.)Treat the projected levels as anticipated areas of interest — potential targets, exhaustion 
    zones, or places to watch for reaction — not guaranteed turning points.
5.)Use the Keltner bias for directional context when deciding which side of the projection to 
    lean on.

Notes
Built and tuned around index-futures session timing; it runs on any market, but the 18:00 rollover and RTH window assume a futures-style session.
Projections are estimates derived from prior-session behavior. Markets don't owe you their range — use these as a framework, not a promise.
Open-source: the full logic is in the code. Read it, adapt it, and make it your own.

This tool is for educational and informational purposes only and is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Projected High/Low [Market Breakers]", overlay=true, max_labels_count=500)



// ============================================================================
// INPUTS
// ============================================================================

// Session Settings
exchange_timezone = input.string("America/New_York", "Exchange Timezone", 
     options=["America/New_York", "America/Chicago", "America/Los_Angeles", 
              "America/Phoenix", "America/Denver", "Europe/London", 
              "Europe/Paris", "Europe/Berlin", "Asia/Tokyo", 
              "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Singapore",
              "Australia/Sydney", "GMT-12", "GMT-11", "GMT-10", 
              "GMT-9", "GMT-8", "GMT-7", "GMT-6", "GMT-5",
              "GMT-4", "GMT-3", "GMT-2", "GMT-1", "GMT",
              "GMT+1", "GMT+2", "GMT+3", "GMT+4", "GMT+5",
              "GMT+6", "GMT+7", "GMT+8", "GMT+9", "GMT+10",
              "GMT+11", "GMT+12"], 
     group="SESSION TIMING")

rth_session = input.session("0930-1600", "RTH Session (Exchange Time)", group="SESSION TIMING")
early_period_mins = input.int(60, "Early Period Minutes", minval=15, group="SESSION TIMING")

// Keltner Channel Settings
kc_length = input.int(20, "KC Length", minval=1, group="KELTNER FILTER")
kc_mult = input.float(2.0, "KC Multiplier", step=0.1, group="KELTNER FILTER")
show_kc = input.bool(false, "Show Keltner Channels", group="KELTNER FILTER")

// Label Sizes (individual controls for each label type)
proj_high_size_input = input.string("Normal", "Projected High Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"], group="LABEL SIZES")
proj_low_size_input = input.string("Normal", "Projected Low Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"], group="LABEL SIZES")
range_size_input = input.string("Normal", "Range Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"], group="LABEL SIZES")
session_open_size_input = input.string("Normal", "Session Open Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"], group="LABEL SIZES")

// Label Customization
projection_label_offset = input.float(0.5, "Projection Label Offset %", 
     minval=0.1, maxval=5.0, step=0.1, 
     tooltip="Distance of labels from projected lines as % of daily range", 
     group="LABEL SETTINGS")
signal_label_offset = input.float(0.3, "Session Open Label Offset %", 
     minval=0.1, maxval=3.0, step=0.1,
     tooltip="Distance of session open label from candles as % of daily range",
     group="LABEL SETTINGS")
show_price_on_labels = input.bool(true, "Show Price on Projection Labels", group="LABEL SETTINGS")
show_range_label = input.bool(false, "Show Range Label", group="LABEL SETTINGS")
show_session_open_label = input.bool(true, "Show Session Open Label", group="LABEL SETTINGS")

// Label Colors
projected_high_label_color = input.color(color.green, "Projected High Label Color", group="LABEL COLORS")
projected_low_label_color = input.color(color.red, "Projected Low Label Color", group="LABEL COLORS")
range_label_color = input.color(color.orange, "Range Label Color", group="LABEL COLORS")
session_open_label_color = input.color(color.blue, "Session Open Label Color", group="LABEL COLORS")

// Visual Settings
show_envelope_calc = input.bool(true, "Show Envelope Calculations", group="VISUALS")
projected_high_line_color = input.color(color.green, "Projected High Line Color", group="VISUALS")
projected_low_line_color = input.color(color.red, "Projected Low Line Color", group="VISUALS")
kc_color = input.color(#2962FF, "Keltner Color", group="VISUALS")

show_labels = input.bool(true, "Show Labels", group="VISUALS")
show_table = input.bool(true, "Show Summary Table", group="TABLE SETTINGS")
table_position = input.string("Top Right", "Table Position", 
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="TABLE SETTINGS")
table_size_input = input.string("Normal", "Table Text Size",
     options=["Tiny", "Small", "Normal", "Large"], group="TABLE SETTINGS")

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

getLabelSize(sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal :
     sz == "Large" ? size.large :
     size.huge

getTableSize(sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal :
     size.large

// Resolve sizes once
proj_high_sz    = getLabelSize(proj_high_size_input)
proj_low_sz     = getLabelSize(proj_low_size_input)
range_sz        = getLabelSize(range_size_input)
session_open_sz = getLabelSize(session_open_size_input)

// ============================================================================
// KELTNER CHANNEL
// ============================================================================

kc_ma = ta.ema(close, kc_length)
kc_range = ta.atr(10)
kc_upper = kc_ma + kc_range * kc_mult
kc_lower = kc_ma - kc_range * kc_mult

kc_bullish = close > kc_ma
kc_bearish = close < kc_ma

// ============================================================================
// DAY TRACKING WITH TIMEZONE (18:00 start)
// ============================================================================

// Session detection (keep this for early period tracking)
in_session = not na(time(timeframe.period, rth_session, exchange_timezone))
session_start = in_session and not in_session[1]

// Get current time in the selected timezone
t = time(timeframe.period, session.extended, exchange_timezone)

// Extract hour in the exchange timezone
current_hour = hour(t, exchange_timezone)
current_day = dayofmonth(t, exchange_timezone)

// Track previous values
var int prev_day = na
var int prev_hour = na

// New day starts at 18:00 (6 PM)
is_new_day = false
if na(prev_day)
    is_new_day := true
else if current_day != prev_day
    // Calendar day changed
    if current_hour >= 18 or prev_hour < 18
        is_new_day := true
else if current_hour >= 18 and prev_hour < 18
    // Same calendar day but crossed 18:00
    is_new_day := true

// Update tracking
prev_day := current_day
prev_hour := current_hour

// ============================================================================
// ENVELOPE CALCULATIONS
// ============================================================================

calcEnvelopeComponents() =>
    hlc3_val = (high + low + close) / 3
    
    // SELL ENVELOPE
    trend_reaction_sell = (hlc3_val * 2) - low
    rally = high - low[1]
    avg_rally = ta.sma(rally, 3)
    anticipated_rally = low + avg_rally
    buy_high = high - high[1]
    avg_buy_high = ta.sma(buy_high, 3)
    buying_high_num = high + avg_buy_high
    sell_envelope = (high + trend_reaction_sell + buying_high_num + anticipated_rally) / 4
    
    // BUY ENVELOPE
    trend_reaction_buy = (hlc3_val * 2) - high
    decline = high[1] - low
    avg_decline = ta.sma(decline, 3)
    anticipated_decline = high - avg_decline
    buy_under = low - low[1]
    avg_buy_under = ta.sma(buy_under, 3)
    anticipated_buy_under = low - avg_buy_under
    buy_envelope = (low + trend_reaction_buy + anticipated_decline + anticipated_buy_under) / 4
    
    // RANGE
    anticipated_range = sell_envelope - buy_envelope
    
    [sell_envelope, buy_envelope, anticipated_range]

[sell_env, buy_env, calc_range] = calcEnvelopeComponents()

// Store daily range
var float today_range = na
var float stored_sell_env = na
var float stored_buy_env = na

if is_new_day
    today_range := calc_range[1]
    stored_sell_env := sell_env[1]
    stored_buy_env := buy_env[1]

if na(today_range)
    today_range := calc_range

// ============================================================================
// EARLY HIGH/LOW TRACKING
// ============================================================================

var float early_high = na
var float early_low = na
var int early_period_bar_count = 0
var bool early_period_active = false
var bool early_period_complete = false
var bool valid_morning = false
var float min_range_threshold = 0.0
var float early_span = 0.0

tf_minutes = timeframe.in_seconds(timeframe.period) / 60
bars_in_early_period = math.ceil(early_period_mins / tf_minutes)

if is_new_day
    early_high := na
    early_low := na
    early_period_bar_count := 0
    early_period_active := false
    early_period_complete := false

if session_start
    early_period_active := true
    early_period_bar_count := 0
    early_high := high
    early_low := low

if early_period_active and not early_period_complete
    early_period_bar_count += 1
    
    early_high := math.max(nz(early_high, high), high)
    early_low := math.min(nz(early_low, low), low)
    early_span := early_high - early_low
    min_range_threshold := today_range * 0.20
    valid_morning := early_span >= min_range_threshold
    
    if early_period_bar_count >= bars_in_early_period
        early_period_complete := true
        early_period_active := false

// ============================================================================
// PROJECTED TARGETS
// ============================================================================

var float projected_high = na
var float projected_low = na
var bool projections_printed = false

if early_period_complete and valid_morning and not na(early_high) and not na(early_low) and not na(today_range)
    if na(projected_high) or na(projected_low)
        projected_high := early_high + today_range
        projected_low := early_low - today_range
        projections_printed := false

if is_new_day
    projected_high := na
    projected_low := na
    projections_printed := false

// ============================================================================
// PLOTTING
// ============================================================================

// Keltner Channels
kc_u = plot(show_kc ? kc_upper : na, "KC Upper", color.new(color.blue, 0), 1, plot.style_line)
kc_m = plot(show_kc ? kc_ma : na, "KC Basis", color.new(color.blue, 0), 1)
kc_l = plot(show_kc ? kc_lower : na, "KC Lower", color.new(color.blue, 0), 1, plot.style_line)
fill(kc_u, kc_l, color=color.new(kc_color, 97))

// Envelope calculations
plot(show_envelope_calc ? stored_sell_env : na, "Sell Envelope", color.new(color.red, 80), 1, plot.style_circles)
plot(show_envelope_calc ? stored_buy_env : na, "Buy Envelope", color.new(color.green, 80), 1, plot.style_circles)

// Early High/Low
plot(not na(early_high) and early_period_complete ? early_high : na, 
     "Early High", color.new(color.blue, 50), 2, plot.style_linebr)
plot(not na(early_low) and early_period_complete ? early_low : na, 
     "Early Low", color.new(color.blue, 50), 2, plot.style_linebr)

// PROJECTED TARGETS
plot(not na(projected_high) ? projected_high : na, 
     "PROJECTED HIGH", projected_high_line_color, 3, plot.style_linebr)
plot(not na(projected_low) ? projected_low : na, 
     "PROJECTED LOW", projected_low_line_color, 3, plot.style_linebr)

p_h = plot(not na(projected_high) ? projected_high : na, display=display.none)
p_l = plot(not na(projected_low) ? projected_low : na, display=display.none)
fill(p_h, p_l, color=color.new(color.gray, 92))

// ============================================================================
// LABELS
// ============================================================================

// Calculate label offsets
label_offset_distance = today_range * (projection_label_offset / 100)
signal_offset_distance = today_range * (signal_label_offset / 100)

// Session open marker
if show_labels and show_session_open_label and session_start
    label.new(bar_index, high + signal_offset_distance, "🔔 SESSION OPEN", 
         style=label.style_label_down, color=color.new(session_open_label_color, 0), 
         textcolor=color.white, size=session_open_sz)

// PROJECTION LABELS
if show_labels and early_period_complete and not projections_printed
    high_text = show_price_on_labels ? 
         "🎯 PROJECTED HIGH\n" + str.tostring(projected_high, format.mintick) :
         "🎯 PROJECTED HIGH"
    
    label.new(bar_index, projected_high + label_offset_distance, 
         high_text, 
         style=label.style_label_down, 
         color=color.new(projected_high_label_color, 0),
         textcolor=color.white, 
         size=proj_high_sz)
    
    low_text = show_price_on_labels ?
         "🎯 PROJECTED LOW\n" + str.tostring(projected_low, format.mintick) :
         "🎯 PROJECTED LOW"
    
    label.new(bar_index, projected_low - label_offset_distance, 
         low_text, 
         style=label.style_label_up, 
         color=color.new(projected_low_label_color, 0),
         textcolor=color.white, 
         size=proj_low_sz)
    
    // Range label - now with toggle
    if show_range_label
        label.new(bar_index, (projected_high + projected_low) / 2,
             "📏 Range: " + str.tostring(today_range, format.mintick),
             style=label.style_label_left,
             color=color.new(range_label_color, 0),
             textcolor=color.white,
             size=range_sz)
    
    projections_printed := true

// Backgrounds
bgcolor(is_new_day ? color.new(color.blue, 95) : na)
bgcolor(session_start ? color.new(color.yellow, 95) : na)
bgcolor(early_period_active ? color.new(color.orange, 97) : na)

// ============================================================================
// TABLE
// ============================================================================

if show_table and barstate.islast
    table_pos = table_position == "Top Right" ? position.top_right :
         table_position == "Top Left" ? position.top_left :
         table_position == "Bottom Right" ? position.bottom_right :
         position.bottom_left
    
    tbl_sz = getTableSize(table_size_input)
    
    var table summary = table.new(table_pos, 2, 10, 
         bgcolor=color.new(color.black, 20),
         frame_color=color.white, frame_width=2)
    
    table.cell(summary, 0, 0, "📈 Market Breakers - Projected H/L", 
         text_color=color.white, text_size=tbl_sz, 
         bgcolor=color.new(color.blue, 40))
    table.cell(summary, 1, 0, "", bgcolor=color.new(color.blue, 40))
    
    table.cell(summary, 0, 1, "🌐 Timezone", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    table.cell(summary, 1, 1, exchange_timezone, text_color=color.yellow, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    
    table.cell(summary, 0, 2, "📏 Range", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    table.cell(summary, 1, 2, str.tostring(today_range, format.mintick), 
         text_color=color.orange, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    
    table.cell(summary, 0, 3, "🔵 Early H", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    table.cell(summary, 1, 3, not na(early_high) ? str.tostring(early_high, format.mintick) : "---", 
         text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    
    table.cell(summary, 0, 4, "🔵 Early L", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    table.cell(summary, 1, 4, not na(early_low) ? str.tostring(early_low, format.mintick) : "---", 
         text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    
    table.cell(summary, 0, 5, "🎯 Proj H", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    table.cell(summary, 1, 5, not na(projected_high) ? str.tostring(projected_high, format.mintick) : "---", 
         text_color=color.lime, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    
    table.cell(summary, 0, 6, "🎯 Proj L", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    table.cell(summary, 1, 6, not na(projected_low) ? str.tostring(projected_low, format.mintick) : "---", 
         text_color=color.red, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    
    table.cell(summary, 0, 7, "TF", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    table.cell(summary, 1, 7, timeframe.period, text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    
    table.cell(summary, 0, 8, "KC", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    table.cell(summary, 1, 8, kc_bullish ? "⬆ Bull" : "⬇ Bear", 
         text_color=kc_bullish ? color.lime : color.red, text_size=tbl_sz, bgcolor=color.new(color.black, 40))
    
    status_text = early_period_active ? "⏳ Tracking..." :
                  not early_period_complete ? "⏳ Waiting..." :
                  not na(projected_high) ? "✅ Active" : "⏳ Waiting..."
    
    table.cell(summary, 0, 9, "Status", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(color.black, 60))
    table.cell(summary, 1, 9, status_text, 
         text_color=not na(projected_high) ? color.lime : color.orange, 
         text_size=tbl_sz, bgcolor=color.new(color.black, 60))

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(early_period_complete and not projections_printed, "Projections Set", "Daily projections calculated")
````
