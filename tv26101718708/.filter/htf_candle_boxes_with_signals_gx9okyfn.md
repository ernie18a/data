# HTF Candle Boxes with Signals

- url: https://www.tradingview.com/script/Gx9oKYfn-HTF-Candle-Boxes-with-Signals/
- type: indicator
- pine_id: PUB;ec65affc54104559baddd526005c27d0
- version: 1.0

## Description

HTF Candle Boxes with Signals — See the 4H candle structure and catch the breakout the moment it happens.

© syouske. All rights reserved.

This indicator is an extended version of "HTF Candle Boxes" (also by syouske), combining the original candle box visualization with a built-in breakout signal detector. The HTF candle box rendering code is shared from the base indicator — if you only need the boxes without signals, use the standalone "HTF Candle Boxes" instead.


The Idea — Candlestick Anatomy

Every candlestick tells a story through its anatomy:

- The open marks where the crowd committed at the start of the period.
- The wicks reveal where price was rejected — liquidity was swept and the move failed.
- The body shows where price actually accepted and closed.
- The close is the final vote of the period.

When a 4H candle opens and immediately wicks away from its open (sweeping liquidity), then returns back to the opening area, the market is showing a failed move. That open price becomes a magnet. If price then breaks out of that opening zone with conviction, it signals that the sweep was a trap and the real move is beginning.

This indicator makes that entire sequence visible and alerts you the moment the breakout confirms.


How It Works

1. The 4H candle opens and wicks away from its open — this is the sweep.
2. Price returns to the opening zone (open ± ATR-based buffer).
3. Price breaks out of the zone on a confirmed bar.

- Bull setup: wick swept DOWN first, returned to open, broke UP
- Bear setup: wick swept UP first, returned to open, broke DOWN


HTF Candle Boxes

Each higher timeframe candle is rendered as three live zones that expand in real time:

- Upper wick zone (gray) — where price was rejected from the top
- Body zone (green/red) — the accepted range between open and close
- Lower wick zone (gray) — where price was rejected from the bottom
- Optional outer box wraps the full candle range

The boxes grow bar by bar as the HTF candle develops, so you always see the current structure clearly on any lower timeframe chart.


Opening Zone

A cyan box drawn around the 4H open price, sized using ATR from a selectable timeframe. This is the area price must return to before a breakout signal can fire. Fully adjustable via the "Zone ATR multiplier" and "Zone ATR timeframe" inputs.


Signal Rules

A signal fires only when all of the following are true:

- Phase 1: price swept away from the 4H open by at least "Min Wick Size" ATRs
- Phase 2: price returned into the opening zone
- Breakout: the previous bar closed inside the zone, current bar closes outside it
- Buffer: signal is suppressed during the first N minutes after the 4H candle opens
- Cooldown: minimum time between signals (default 5 minutes)
- Entry Filter (optional): Volume spike or Last Candles trend confirmation


Entry Filter Options

- NA — no additional filter, signal fires on zone breakout alone
- Volume — requires the EMA5/EMA10 volume oscillator to exceed a set threshold
- Last Candles — all N bars before the zone touch must be trending in the signal direction (bearish approach for bull signal, bullish approach for bear signal)


Customization

- HTF timeframe: 1H, 4H, or 1D
- Zone ATR length, multiplier, and timeframe (5m, 15m, 30m, 1H)
- Zone and box colors
- Signal shape: Circle, Triangle, Diamond, Square, Cross, Arrow
- Signal size: Auto, Tiny, Small, Normal, Large, Huge
- Buffer window duration after 4H open
- Signal cooldown period


Recommended Use

- Chart timeframe: 1M, 3M, 5M, or 15M
- Works on any liquid market: forex, crypto, indices, futures
- Best used alongside higher timeframe bias and key S/R levels
- Pair with the standalone "HTF Candle Boxes" indicator for multi-HTF analysis


Alerts

- "4H Shift — Bull" — bull breakout confirmed
- "4H Shift — Bear" — bear breakout confirmed

Set alerts to "Once per bar close" for best accuracy.


Disclaimer

This indicator is a tool for analysis, not financial advice. Past signals do not guarantee future results. Always use proper risk management.

## Source Code

````pine
//@version=5
// © syouske
// HTF Candle Boxes with Signals
// Extended version of "HTF Candle Boxes" — adds a 4H TF Shifting breakout signal detector.
// HTF candle box rendering is shared from the base indicator (HTF Candle Boxes by syouske).
//
// HTF Candle Boxes: renders each HTF candle as three zones (upper wick, body, lower wick)
// that expand in real-time over LTF bars.
//
// 4H TF Shifting signal logic:
//   1. 4H candle opens and wicks away from its open (sweep)
//   2. Price returns to the opening zone (open ± ATR)
//   3. Price breaks out of the zone with optional volume confirmation
//   Bull: wicked DOWN first → returned to open → broke UP
//   Bear: wicked UP first   → returned to open → broke DOWN

indicator("HTF Candle Boxes with Signals", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS: HTF Candle Boxes ────────────────────────────────────────────────
g_htf              = "HTF Candle Boxes"
htf_choice         = input.string("4H", "HTF timeframe", options = ["1H", "4H", "1D"], group = g_htf)
htf_tf             = htf_choice == "1D" ? "D" : htf_choice == "1H" ? "60" : "240"
show_htf_boxes     = input.bool(true,  "Show HTF Candle Boxes",       group = g_htf)
upper_wick_color   = input.color(color.new(color.gray,  90), "Upper wick fill",   group = g_htf)
body_bull_color    = input.color(color.new(color.green, 70), "Bullish body fill", group = g_htf)
body_bear_color    = input.color(color.new(color.red,   70), "Bearish body fill", group = g_htf)
lower_wick_color   = input.color(color.new(color.gray,  90), "Lower wick fill",   group = g_htf)
show_borders       = input.bool(true,  "Show borders",                group = g_htf)
border_color_in    = input.color(color.new(color.gray,  90), "Border color",      group = g_htf)
show_dash_line     = input.bool(true,  "Show dash line",              group = g_htf)
dash_line_color    = input.color(color.new(color.gray, 20), "Dash line color",    group = g_htf)
show_outer_box     = input.bool(true,  "Wrap HTF candle in outer box",group = g_htf)
outer_border_col   = input.color(color.new(color.gray,  90), "Outer box border",  group = g_htf)

// ─── INPUTS: Opening Zone ────────────────────────────────────────────────────
g_zone             = "Opening Zone"
show_zone          = input.bool(true,  "Show opening zone box",       group = g_zone)
zone_atr_len       = input.int(14,    "Zone ATR length",  minval = 1, maxval = 200, group = g_zone)
zone_atr_mult      = input.float(0.3, "Zone ATR multiplier", minval = 0.1, maxval = 2.0, step = 0.1, group = g_zone)
zone_atr_tf        = input.string("15m", "Zone ATR timeframe", options = ["5m", "15m", "30m", "1H"], group = g_zone)
zone_fill_color    = input.color(color.new(#00bcd4,   88), "Zone fill color",   group = g_zone)
zone_border_color  = input.color(color.new(#00bcd4,   50), "Zone border color", group = g_zone)

// ─── INPUTS: 4H TF Shifting Signals ─────────────────────────────────────────
g_sig              = "4H TF Shifting Signals"
wick_min_mult      = input.float(0.5,  "Min Wick Size (ATR mult)",        minval = 0.1, maxval = 5.0, step = 0.1, group = g_sig, tooltip = "Wick must extend this many ATRs from the 4H open to qualify as a sweep.")
buf_mins           = input.int(30,     "Buffer After 4H Open (min)",      minval = 1, maxval = 180, group = g_sig, tooltip = "Suppress signals during the first N minutes after the 4H candle opens.")
entry_filter       = input.string("NA", "Entry Filter",                   options = ["NA", "Volume", "Last Candles"], group = g_sig, tooltip = "NA: no filter. Volume: require volume spike. Last Candles: all N bars before zone touch must trend in signal direction.")
vol_thresh         = input.float(10.0, "Volume Oscillator Threshold (%)", minval = 0.0, step = 1.0, group = g_sig, tooltip = "Used when Entry Filter = Volume. EMA5/EMA10 oscillator must exceed this %.")
trend_len          = input.int(3,      "Last Candles Count",               minval = 1, maxval = 20,  group = g_sig, tooltip = "Used when Entry Filter = Last Candles. How many LTF bars before zone touch must all be same direction.")
cooldown_mins      = input.int(5,      "Signal Cooldown (min)",            minval = 1, maxval = 60, group = g_sig, tooltip = "Minimum minutes between signals.")
bull_css           = input.color(#26a69a, "Bull Signal Color",             group = g_sig)
bear_css           = input.color(#ef5350, "Bear Signal Color",             group = g_sig)
sig_shape          = input.string("Circle",  "Signal Shape", options = ["Circle", "Triangle", "Diamond", "Square", "Cross", "Arrow Up/Down"], group = g_sig)
sig_size           = input.string("Auto",    "Signal Size",  options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = g_sig)
show_buffer        = input.bool(false, "Show Buffer Window",               group = g_sig)
buffer_css         = input.color(color.new(color.blue, 88), "Buffer Highlight", group = g_sig)

// ─── HTF CANDLE TRACKING ─────────────────────────────────────────────────────
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

// ─── ATR & ZONE ──────────────────────────────────────────────────────────────
_atr_tf = zone_atr_tf == "15m" ? "15" : zone_atr_tf == "30m" ? "30" : zone_atr_tf == "1H" ? "60" : "5"
atr_val = request.security(syminfo.tickerid, _atr_tf, ta.atr(zone_atr_len))

var float htf_zone_top = na
var float htf_zone_bot = na
var float htf_atr_snap = na

if new_htf
    htf_atr_snap  := atr_val
    htf_zone_top  := open + atr_val * zone_atr_mult
    htf_zone_bot  := open - atr_val * zone_atr_mult

// ─── HTF CANDLE BOXES ────────────────────────────────────────────────────────
var int  start_bar  = bar_index
var box  upper_box  = na
var box  body_box   = na
var box  lower_box  = na
var box  outer_box  = na
var line dash_ln    = na
var box  zone_box   = na

if new_htf
    start_bar := bar_index

body_top   = math.max(htf_o, htf_c)
body_bot   = math.min(htf_o, htf_c)
body_mid_y = (body_top + body_bot) / 2
body_color = htf_c >= htf_o ? body_bull_color : body_bear_color
brd        = show_borders ? border_color_in : color.new(color.gray, 100)
outer_brd  = show_outer_box ? outer_border_col : color.new(color.gray, 100)

if show_htf_boxes and new_htf
    upper_box := box.new(start_bar, htf_h,    bar_index, body_top, bgcolor = upper_wick_color, border_color = brd)
    body_box  := box.new(start_bar, body_top, bar_index, body_bot, bgcolor = body_color,       border_color = brd)
    lower_box := box.new(start_bar, body_bot, bar_index, htf_l,    bgcolor = lower_wick_color, border_color = brd)
    outer_box := box.new(start_bar, htf_h,    bar_index, htf_l,    bgcolor = color.new(color.white, 100), border_color = outer_brd)
    if show_dash_line
        dash_ln := line.new(start_bar, body_mid_y, bar_index, body_mid_y,
             color = dash_line_color, style = line.style_dotted, width = 1)
    if show_zone
        zone_box := box.new(start_bar, htf_zone_top, bar_index, htf_zone_bot,
             bgcolor = zone_fill_color, border_color = zone_border_color, border_width = 1)

if show_htf_boxes and not new_htf
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
        line.set_x2(dash_ln,  bar_index)
        line.set_y1(dash_ln,  body_mid_y)
        line.set_y2(dash_ln,  body_mid_y)
    if show_zone and not na(zone_box)
        box.set_right(zone_box, bar_index)

// ─── 4H TF SHIFTING STATE MACHINE ────────────────────────────────────────────
var int   phase           = 0
var float wick_high       = na
var float wick_low        = na
var bool  bull_setup      = false
var bool  bear_setup      = false
var bool  approach_bull   = false
var bool  approach_bear   = false
if new_htf
    phase         := 1
    wick_high     := open
    wick_low      := open
    bull_setup    := false
    bear_setup    := false
    approach_bull := false
    approach_bear := false

if phase == 1
    wick_high := math.max(wick_high, high)
    wick_low  := math.min(wick_low,  low)

swept_low  = not na(htf_o) and not na(htf_atr_snap) and (htf_o - wick_low)  >= htf_atr_snap * wick_min_mult
swept_high = not na(htf_o) and not na(htf_atr_snap) and (wick_high - htf_o) >= htf_atr_snap * wick_min_mult

in_open_zone = not na(htf_zone_top) and close >= htf_zone_bot and close <= htf_zone_top

if phase == 1 and in_open_zone and (swept_low or swept_high)
    phase := 2
    if swept_low
        bull_setup := true
    if swept_high
        bear_setup := true
    // snapshot LTF trend at zone-touch bar
    all_bull = true
    all_bear = true
    for i = 1 to trend_len
        if close[i] <= open[i]
            all_bull := false
        if close[i] >= open[i]
            all_bear := false
    approach_bull := all_bull
    approach_bear := all_bear

// ─── BUFFER WINDOW ───────────────────────────────────────────────────────────
htf_dur_ms = htf_choice == "1H" ? 60 * 60 * 1000 : htf_choice == "4H" ? 4 * 60 * 60 * 1000 : 24 * 60 * 60 * 1000
buf_ms     = buf_mins * 60 * 1000
in_buffer  = not na(htf_open_time) and time < htf_open_time + buf_ms

// ─── VOLUME OSCILLATOR ───────────────────────────────────────────────────────
vol_osc = 100 * (ta.ema(volume, 5) - ta.ema(volume, 10)) / ta.ema(volume, 10)
vol_ok  = entry_filter != "Volume" or vol_osc >= vol_thresh

trend_ok_bull = entry_filter != "Last Candles" or approach_bear
trend_ok_bear = entry_filter != "Last Candles" or approach_bull

was_in_zone = not na(htf_zone_top) and close[1] >= htf_zone_bot and close[1] <= htf_zone_top

if phase == 2
    wick_high := math.max(wick_high, high)
    wick_low  := math.min(wick_low,  low)

var int last_signal_time = 0
cooldown_ms    = cooldown_mins * 60 * 1000
cooldown_ok    = (time - last_signal_time) >= cooldown_ms

bull_signal = phase == 2 and bull_setup and was_in_zone and close > htf_zone_top and vol_ok and trend_ok_bull and cooldown_ok and not in_buffer and barstate.isconfirmed
bear_signal = phase == 2 and bear_setup and was_in_zone and close < htf_zone_bot and vol_ok and trend_ok_bear and cooldown_ok and not in_buffer and barstate.isconfirmed

if bull_signal or bear_signal
    last_signal_time := time

// ─── SIGNAL SHAPES ───────────────────────────────────────────────────────────
// Use label.new so style and size can be chosen at runtime without const constraints.
if bull_signal
    _sty = sig_shape == "Triangle"      ? label.style_triangleup  :
         sig_shape == "Diamond"       ? label.style_diamond      :
         sig_shape == "Square"        ? label.style_square       :
         sig_shape == "Cross"         ? label.style_xcross       :
         sig_shape == "Arrow Up/Down" ? label.style_arrowup      :
         label.style_circle
    _sz  = sig_size == "Auto"   ? size.auto   :
         sig_size == "Small"  ? size.small  :
         sig_size == "Normal" ? size.normal :
         sig_size == "Large"  ? size.large  :
         sig_size == "Huge"   ? size.huge   : size.tiny
    label.new(bar_index, low, yloc = yloc.belowbar,
         style = _sty, size = _sz, color = bull_css, text = "")

if bear_signal
    _sty = sig_shape == "Triangle"      ? label.style_triangledown :
         sig_shape == "Diamond"       ? label.style_diamond       :
         sig_shape == "Square"        ? label.style_square        :
         sig_shape == "Cross"         ? label.style_xcross        :
         sig_shape == "Arrow Up/Down" ? label.style_arrowdown     :
         label.style_circle
    _sz  = sig_size == "Auto"   ? size.auto   :
         sig_size == "Small"  ? size.small  :
         sig_size == "Normal" ? size.normal :
         sig_size == "Large"  ? size.large  :
         sig_size == "Huge"   ? size.huge   : size.tiny
    label.new(bar_index, high, yloc = yloc.abovebar,
         style = _sty, size = _sz, color = bear_css, text = "")

bgcolor(show_buffer and in_buffer ? buffer_css : na, title = "Buffer Window")

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(bull_signal, "4H Shift — Bull", "HTF Candle Boxes with Signals: Bull breakout confirmed")
alertcondition(bear_signal, "4H Shift — Bear", "HTF Candle Boxes with Signals: Bear breakout confirmed")
````
