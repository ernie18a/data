# HTF Candle Boxes

- url: https://www.tradingview.com/script/t7MrxGHX-HTF-Candle-Boxes/
- type: indicator
- pine_id: PUB;65709820bb26423ca2f88311506eb4f6
- version: 2.0

## Description

HTF Candle Boxes — Wick / Body / Wick + Liquidity Window

Renders each higher-timeframe candle (1H, 4H, or 1D) as three horizontal zones drawn over the lower-timeframe bars that compose it. Lets you see HTF structure without leaving your scalp/intraday chart.

What it draws

Upper wick zone — from HTF high down to the body top.
Body zone — tinted green (bullish) or red (bearish) based on HTF open vs close.
Lower wick zone — from body bottom down to HTF low.
Body midpoint — a dotted line at the exact 50% of the HTF body. Useful as an MSS / mean-reversion reference because price respects it more often than mid-of-candle.
Outer wrapper — a subtle gray border around the full HTF high-low range.
Liquidity window lines — two vertical lines per HTF candle bracketing the high-liquidity zones around each HTF rollover:
One 15 minutes after the HTF candle opens (near-open liquidity edge)
One 15 minutes before the HTF candle closes (near-close liquidity edge)
Both lines are confined inside the HTF box (no infinite extension cluttering the chart) and grow vertically with the candle as it forms. They only render on M1 / M3 / M15 / M30 charts — above M30 the 15-min bracket is finer than a bar, so it's hidden.

Why it's useful

HTF candles cleanly show institutional context without scrolling between timeframes.
The body midpoint becomes a real-time pullback / continuation level intraday.
The liquidity bracket marks the 15-min window straddling each HTF rollover, when most desk-driven flow concentrates around the candle close/open — a high-probability place for sweeps, reclaims, and reversal entries.
Inputs

HTF timeframe — 1H, 4H, or 1D.
Fill colors — upper wick, lower wick, bull body, bear body (defaults: gray wicks at 90% transparency, green/red body at 70%).
Show borders + Border color.
Show body midpoint + color, style (solid / dashed / dotted), width.
Wrap HTF candle in outer box + outer border color.
Show liquidity window lines + minutes ± boundary (default 15), color, style.
Implementation note

HTF o/h/l/c are aggregated directly from the LTF bars inside each HTF window — not pulled via request.security. That avoids the one-bar lag where request.security(..., lookahead_off) returns the prior confirmed HTF candle, which would otherwise leave LTF wicks poking outside the box. The boxes here always wrap every LTF bar they contain, on both historical and live data.

Published under MIT-style permissive use — feel free to fork and adapt.

## Source Code

````pine
//@version=5
// HTF Candle Boxes
// Renders each HTF (default 4H) candle as three horizontal zones drawn over
// the LTF bars that compose it:
//   - upper wick box: HTF high  -> max(open, close)
//   - body box:       max(o, c) -> min(o, c)        (bull/bear tinted)
//   - lower wick box: min(o, c) -> HTF low
//
// The boxes expand to the right as each new LTF bar prints inside the same
// HTF candle, and lock in place when the HTF candle closes.

indicator("HTF Candle Boxes", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ---------- inputs ----------
htf_choice        = input.string("4H", "HTF timeframe", options = ["1H", "4H", "1D"])
htf_tf            = htf_choice == "1D" ? "D" : htf_choice == "1H" ? "60" : "240"
upper_wick_color  = input.color(color.new(color.gray,  90), "Upper wick fill")
body_bull_color   = input.color(color.new(color.green, 70), "Bullish body fill")
body_bear_color   = input.color(color.new(color.red,   70), "Bearish body fill")
lower_wick_color  = input.color(color.new(color.gray,  90), "Lower wick fill")
show_borders      = input.bool(true, "Show borders")
border_color_in   = input.color(color.new(color.gray,  90), "Border color")
show_dash_line    = input.bool(true, "Show dash line")
dash_line_pos     = input.string("Midpoint", "Dash line position", options = ["Midpoint", "Opening point"])
dash_line_color   = input.color(color.new(color.gray, 0),  "Dash line color")
dash_line_style   = input.string("dotted", "Dash line style", options = ["solid", "dashed", "dotted"])
dash_line_width   = input.int(3, "Dash line width", minval = 1, maxval = 5)
show_outer_box    = input.bool(true, "Wrap HTF candle in outer box")
outer_border_col  = input.color(color.new(color.gray,  90), "Outer box border")
show_liq_lines    = input.bool(false, "Show liquidity window lines")
liq_minutes       = input.int(15, "Liquidity window (minutes ± boundary)", minval = 1)
liq_line_color    = input.color(color.new(color.yellow, 50), "Liquidity line color")
liq_line_style    = input.string("dotted", "Liquidity line style", options = ["solid", "dashed", "dotted"])
show_reversal     = input.bool(false, "Show reversal signals")

// ---------- HTF data (aggregated from LTF bars — no request.security lag) ----------
// request.security(..., lookahead_off) returns the PRIOR (confirmed) HTF candle's
// values on historical bars, so the box ends up sized to the wrong candle and LTF
// wicks poke outside. Building the o/h/l/c from the LTF bars inside the HTF window
// keeps the box flush with every LTF wick it contains.
htf_open_time = time(htf_tf)
new_htf       = not na(htf_open_time) and htf_open_time != nz(htf_open_time[1], htf_open_time)

var float htf_o = na
var float htf_h = na
var float htf_l = na
var float htf_c = na

if new_htf
    htf_o := open
    htf_h := high
    htf_l := low
    htf_c := close
else
    htf_h := math.max(nz(htf_h, high), high)
    htf_l := math.min(nz(htf_l, low),  low)
    htf_c := close

// ---------- state ----------
var int  start_bar = bar_index
var box  upper_box = na
var box  body_box  = na
var box  lower_box = na
var box  outer_box = na
var line dash_ln   = na

if new_htf
    start_bar := bar_index

body_top   = math.max(htf_o, htf_c)
body_bot   = math.min(htf_o, htf_c)
body_mid_y = (body_top + body_bot) / 2
body_color = htf_c >= htf_o ? body_bull_color : body_bear_color
brd        = show_borders ? border_color_in : color.new(color.gray, 100)
dl_style   = dash_line_style == "solid" ? line.style_solid : dash_line_style == "dotted" ? line.style_dotted : line.style_dashed
dl_y       = dash_line_pos == "Opening point" ? htf_o : body_mid_y

outer_brd = show_outer_box ? outer_border_col : color.new(color.gray, 100)

if new_htf
    upper_box := box.new(start_bar, htf_h,    bar_index, body_top, bgcolor = upper_wick_color, border_color = brd)
    body_box  := box.new(start_bar, body_top, bar_index, body_bot, bgcolor = body_color,       border_color = brd)
    lower_box := box.new(start_bar, body_bot, bar_index, htf_l,    bgcolor = lower_wick_color, border_color = brd)
    outer_box := box.new(start_bar, htf_h,    bar_index, htf_l,    bgcolor = color.new(color.white, 100), border_color = outer_brd)
    if show_dash_line
        dash_ln := line.new(start_bar, dl_y, bar_index, dl_y, color = dash_line_color, style = dl_style, width = dash_line_width)
else
    if not na(upper_box)
        box.set_right(upper_box,  bar_index)
        box.set_top(upper_box,    htf_h)
        box.set_bottom(upper_box, body_top)
    if not na(body_box)
        box.set_right(body_box,   bar_index)
        box.set_top(body_box,     body_top)
        box.set_bottom(body_box,  body_bot)
        box.set_bgcolor(body_box, body_color)
    if not na(lower_box)
        box.set_right(lower_box,  bar_index)
        box.set_top(lower_box,    body_bot)
        box.set_bottom(lower_box, htf_l)
    if not na(outer_box)
        box.set_right(outer_box,  bar_index)
        box.set_top(outer_box,    htf_h)
        box.set_bottom(outer_box, htf_l)
        box.set_border_color(outer_box, outer_brd)
    if show_dash_line and not na(dash_ln)
        line.set_x2(dash_ln, bar_index)
        line.set_y1(dash_ln, dl_y)
        line.set_y2(dash_ln, dl_y)

// ---------- Per-HTF liquidity window lines (drawn inside each HTF box) ----------
// Each HTF candle gets two vertical lines, both bounded vertically by that
// candle's high/low (so they sit inside the wick boxes, not extending past):
//   - `liq_minutes` after its open      → near-open liquidity edge
//   - `liq_minutes` before its close    → near-close liquidity edge
// Together they bracket the high-liquidity zones straddling each HTF boundary.
// On the in-progress HTF candle the lines are created at rollover and their
// y-extent is refreshed every LTF bar so they grow with the candle.
liq_style       = liq_line_style == "solid" ? line.style_solid : liq_line_style == "dotted" ? line.style_dotted : line.style_dashed
htf_duration_ms = htf_choice == "1H" ? 60 * 60 * 1000 : htf_choice == "4H" ? 4 * 60 * 60 * 1000 : 24 * 60 * 60 * 1000
liq_ms          = liq_minutes * 60 * 1000

// Liquidity lines only render on M1 / M3 / M5 / M15 / M30 charts — above M30
// the 15-min bracket loses resolution against bar size, so hide it.
chart_tf_secs   = timeframe.in_seconds()
liq_tf_allowed  = chart_tf_secs == 60 or chart_tf_secs == 180 or chart_tf_secs == 300 or chart_tf_secs == 900 or chart_tf_secs == 1800

var line start_liq_line = na
var line end_liq_line   = na

if show_liq_lines and liq_tf_allowed
    if new_htf
        start_x         = htf_open_time + liq_ms
        end_x           = htf_open_time + htf_duration_ms - liq_ms
        start_liq_line := line.new(start_x, htf_l, start_x, htf_h, xloc = xloc.bar_time, color = liq_line_color, width = 1, style = liq_style)
        end_liq_line   := line.new(end_x,   htf_l, end_x,   htf_h, xloc = xloc.bar_time, color = liq_line_color, width = 1, style = liq_style)
    else
        if not na(start_liq_line)
            line.set_y1(start_liq_line, htf_l)
            line.set_y2(start_liq_line, htf_h)
        if not na(end_liq_line)
            line.set_y1(end_liq_line, htf_l)
            line.set_y2(end_liq_line, htf_h)

// ---------- Reversal alert ----------
// A = HTF candle two ago, B = previous closed HTF, C = in-progress HTF.
// Trigger: A and B are consecutively same direction (trend established),
// then C wicks across B's midpoint AND through to B's opposite-side H/L —
// a deep sweep of B that fails the prior trend. Bull-trend sweep (A+B bull,
// C wicks down past B mid to B low) → bearish reversal signal. Bear-trend
// sweep (A+B bear, C wicks up past B mid to B high) → bullish reversal
// signal. Once-per-C resolution.
var float a_o            = na
var float a_c            = na
var float b_o            = na
var float b_h            = na
var float b_l            = na
var float b_c            = na
var bool  c_crossed_mid  = false
var bool  c_alerted      = false

if new_htf
    // Shift A ← B ← just-closed HTF.
    a_o := b_o
    a_c := b_c
    b_o := htf_o[1]
    b_h := htf_h[1]
    b_l := htf_l[1]
    b_c := htf_c[1]
    c_crossed_mid := false
    c_alerted     := false

ab_bull = not na(a_o) and not na(a_c) and not na(b_o) and not na(b_c) and a_c > a_o and b_c > b_o
ab_bear = not na(a_o) and not na(a_c) and not na(b_o) and not na(b_c) and a_c < a_o and b_c < b_o

b_top = na(b_o) or na(b_c) ? na : math.max(b_o, b_c)
b_bot = na(b_o) or na(b_c) ? na : math.min(b_o, b_c)
b_mid = na(b_top) ? na : (b_top + b_bot) / 2

if not na(b_mid)
    if ab_bull and low  <= b_mid
        c_crossed_mid := true
    if ab_bear and high >= b_mid
        c_crossed_mid := true

abc_bull = show_reversal and ab_bull and c_crossed_mid and not na(b_l) and low  <= b_l and not c_alerted
abc_bear = show_reversal and ab_bear and c_crossed_mid and not na(b_h) and high >= b_h and not c_alerted

if abc_bull or abc_bear
    c_alerted := true

// Arrow direction = SIGNAL direction (reversal of prior trend).
// abc_bull setup (A+B bull, deep down-wick) → bearish reversal → ▼ above bar
// abc_bear setup (A+B bear, deep up-wick)   → bullish reversal → ▲ below bar
plotshape(abc_bull, title = "Reversal (bear)", style = shape.triangledown, location = location.abovebar, color = color.red,  size = size.small)
plotshape(abc_bear, title = "Reversal (bull)", style = shape.triangleup,   location = location.belowbar, color = color.lime, size = size.small)

alertcondition(abc_bull or abc_bear, title = "Reversal", message = "Reversal: prior two HTF candles same direction, current candle deeply swept the last one (across midpoint + reached opposite H/L)")
````
