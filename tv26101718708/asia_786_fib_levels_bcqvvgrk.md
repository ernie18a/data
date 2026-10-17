# Asia .786 Fib Levels

- url: https://www.tradingview.com/script/BCqvvGrk-Asia-786-Fib-Levels/
- type: indicator
- pine_id: PUB;00d2432bf7a047058b300dccab73bf3e
- version: 1.0

## Description

Monitors the Asia session (default 20:00–00:00 exchange time) and tracks the high and low throughout
An optional blue box visualises the Asia range while it's forming, then locks closed when the session ends

Fib Placement (on session close)

.786 from High — drawn downward: High - 0.786 × range
.786 from Low — drawn upward: Low + 0.786 × range
Both are dashed lines with labels showing the price level

High Probability Colouring Logic
The indicator calculates the Asia midpoint and checks where price is sitting when the fibs are placed:

Price above the midpoint → more likely to sweep down → .786 from High turns yellow ★
Price below the midpoint → more likely to push up → .786 from Low turns yellow ★

This re-evaluates dynamically each bar as price moves through the session, so the yellow label always reflects current positioning.
Settings to check on first load

Asia Open/Close Hour — defaults to 20:00–00:00. Adjust to match your chart's exchange timezone (e.g. if you're on UTC, Forex Asia is typically 00:00–08:00)
The indicator works best on 15m or lower timeframes where the session detection is granular

## Source Code

````pine
//@version=6
indicator("Asia .786 Fib Levels", overlay=true, max_lines_count=10, max_labels_count=10)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
asia_session  = input.session("2000-0000", "Asia Session", tooltip="Click the clock icon to use TradingView's session time picker.")

col_default   = input.color(color.new(color.white,  20), "Default Fib Colour")
col_high_prob = input.color(color.new(color.yellow,  0), "High Probability Colour")
col_asia_box  = input.color(color.new(color.blue,   80), "Asia Range Fill")

show_asia_box = input.bool(true, "Show Asia Session Box")

// ─────────────────────────────────────────────
// SESSION DETECTION  (uses native time() – respects DST & exchange TZ)
// ─────────────────────────────────────────────
in_asia_session = not na(time(timeframe.period, asia_session))

// ─────────────────────────────────────────────
// ASIA RANGE TRACKING
// ─────────────────────────────────────────────
var float asia_high    = na
var float asia_low     = na
var bool  session_open = false

session_just_opened = in_asia_session and not session_open[1]
session_just_closed = not in_asia_session and session_open[1]

if session_just_opened
    asia_high    := high
    asia_low     := low
    session_open := true

if in_asia_session
    asia_high := math.max(asia_high, high)
    asia_low  := math.min(asia_low,  low)

if session_just_closed
    session_open := false

// ─────────────────────────────────────────────
// FIB CALCULATION  (.786 retracement)
// .786 from High → Low  =  high - 0.786 * range
// .786 from Low  → High =  low  + 0.786 * range
// ─────────────────────────────────────────────
fib_from_high = not na(asia_high) and not na(asia_low) ? asia_high - 0.786 * (asia_high - asia_low) : na
fib_from_low  = not na(asia_high) and not na(asia_low) ? asia_low  + 0.786 * (asia_high - asia_low) : na

// ─────────────────────────────────────────────
// HIGH PROBABILITY LOGIC
// Price above Asia midpoint → more likely to drop  → fib_from_high is yellow
// Price below Asia midpoint → more likely to rally → fib_from_low  is yellow
// ─────────────────────────────────────────────
asia_mid = not na(asia_high) and not na(asia_low) ? (asia_high + asia_low) / 2 : na

high_prob_is_from_high = not na(asia_mid) and close > asia_mid
high_prob_is_from_low  = not na(asia_mid) and close <= asia_mid

// ─────────────────────────────────────────────
// DRAWING
// ─────────────────────────────────────────────
var line  line_fib_high = na
var line  line_fib_low  = na
var label lbl_fib_high  = na
var label lbl_fib_low   = na
var box   asia_box      = na

// Asia session box
if session_just_opened and show_asia_box
    if not na(asia_box)
        box.delete(asia_box)
    asia_box := box.new(bar_index, high, bar_index, low, border_color=color.new(color.blue, 60), bgcolor=col_asia_box, extend=extend.right)

if in_asia_session and show_asia_box and not na(asia_box)
    box.set_top(asia_box,    asia_high)
    box.set_bottom(asia_box, asia_low)
    box.set_right(asia_box,  bar_index)

if session_just_closed and show_asia_box and not na(asia_box)
    box.set_extend(asia_box, extend.none)
    box.set_right(asia_box, bar_index)

// Fib lines & labels (live after Asia closes)
draw_fibs = not in_asia_session and not na(fib_from_high) and not na(fib_from_low)

if draw_fibs
    col_high = high_prob_is_from_high ? col_high_prob : col_default
    col_low  = high_prob_is_from_low  ? col_high_prob : col_default

    // ── Fib from High ──
    if na(line_fib_high)
        line_fib_high := line.new(bar_index, fib_from_high, bar_index + 1, fib_from_high, color=col_high, width=2, style=line.style_dashed, extend=extend.right)
    else
        line.set_y1(line_fib_high, fib_from_high)
        line.set_y2(line_fib_high, fib_from_high)
        line.set_color(line_fib_high, col_high)

    // ── Fib from Low ──
    if na(line_fib_low)
        line_fib_low := line.new(bar_index, fib_from_low, bar_index + 1, fib_from_low, color=col_low, width=2, style=line.style_dashed, extend=extend.right)
    else
        line.set_y1(line_fib_low, fib_from_low)
        line.set_y2(line_fib_low, fib_from_low)
        line.set_color(line_fib_low, col_low)

    // ── Labels ──
    hp_tag_high = high_prob_is_from_high ? "  ★ HIGH PROB" : ""
    hp_tag_low  = high_prob_is_from_low  ? "  ★ HIGH PROB" : ""

    if na(lbl_fib_high)
        lbl_fib_high := label.new(bar_index, fib_from_high, text=".786 ↓ (from High) " + str.tostring(math.round(fib_from_high, 5)) + hp_tag_high, color=col_high, textcolor=color.black, style=label.style_label_right, size=size.small)
    else
        label.set_x(lbl_fib_high,    bar_index)
        label.set_y(lbl_fib_high,    fib_from_high)
        label.set_text(lbl_fib_high, ".786 ↓ (from High) " + str.tostring(math.round(fib_from_high, 5)) + hp_tag_high)
        label.set_color(lbl_fib_high, col_high)

    if na(lbl_fib_low)
        lbl_fib_low := label.new(bar_index, fib_from_low, text=".786 ↑ (from Low) " + str.tostring(math.round(fib_from_low, 5)) + hp_tag_low, color=col_low, textcolor=color.black, style=label.style_label_right, size=size.small)
    else
        label.set_x(lbl_fib_low,    bar_index)
        label.set_y(lbl_fib_low,    fib_from_low)
        label.set_text(lbl_fib_low, ".786 ↑ (from Low) " + str.tostring(math.round(fib_from_low, 5)) + hp_tag_low)
        label.set_color(lbl_fib_low, col_low)

// Clean up when Asia session reopens
if session_just_opened
    if not na(line_fib_high)
        line.delete(line_fib_high)
        line_fib_high := na
    if not na(line_fib_low)
        line.delete(line_fib_low)
        line_fib_low := na
    if not na(lbl_fib_high)
        label.delete(lbl_fib_high)
        lbl_fib_high := na
    if not na(lbl_fib_low)
        label.delete(lbl_fib_low)
        lbl_fib_low := na

// ─────────────────────────────────────────────
// DATA WINDOW PLOTS
// ─────────────────────────────────────────────
plot(draw_fibs ? fib_from_high : na, ".786 from High", color=color.new(color.white, 60), display=display.data_window)
plot(draw_fibs ? fib_from_low  : na, ".786 from Low",  color=color.new(color.white, 60), display=display.data_window)
plot(draw_fibs ? asia_high     : na, "Asia High",      color=color.new(color.blue,  60), display=display.data_window)
plot(draw_fibs ? asia_low      : na, "Asia Low",       color=color.new(color.blue,  60), display=display.data_window)
````
