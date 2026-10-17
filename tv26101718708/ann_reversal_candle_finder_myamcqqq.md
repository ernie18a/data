# ANN Reversal Candle Finder

- url: https://www.tradingview.com/script/mYAmcQqq-ANN-Reversal-Candle-Finder/
- type: indicator
- pine_id: PUB;9ea2bc4f03064268a011f269be71077d
- version: 1.0

## Description

Stochastic Reversal Candle Finder
This indicator identifies potential reversal candles using Stochastic %K as a filter. It enters bull mode when %K crosses below 20, then tracks the lowest candle in that zone, finds the nearest prior bearish candle whose high exceeds the low candle's high, and draws a dashed resistance line. A bull reversal signal triggers when price closes above that line. Bear mode works in reverse — triggered when %K crosses above 80, tracking the highest candle, referencing a prior bullish candle's low as support, and signaling when price closes below it. Both modes remain active and continue scanning for new setups until %K crosses to the opposite extreme.

## Source Code

````pine
//@version=5
indicator("Stochastic Reversal Candle Finder", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_stoch = "Stochastic Settings"
k_len    = input.int(9,  "K Length",    minval=1, group=grp_stoch)
k_smooth = input.int(3,  "K Smoothing", minval=1, group=grp_stoch)
d_smooth = input.int(3,  "D Smoothing", minval=1, group=grp_stoch)
ob_level = input.int(80, "Overbought",  minval=50, maxval=99, group=grp_stoch)
os_level = input.int(20, "Oversold",    minval=1,  maxval=50, group=grp_stoch)

grp_sig         = "Signal Settings"
show_bull       = input.bool(true, "Show Bull Reversal",                          group=grp_sig)
show_bear       = input.bool(true, "Show Bear Reversal",                          group=grp_sig)
bull_full_label = input.bool(true, "Bull: Full Label (off = tiny triangle only)", group=grp_sig)
bear_full_label = input.bool(true, "Bear: Full Label (off = tiny triangle only)", group=grp_sig)

grp_line        = "Line Settings"
bull_line_color = input.color(color.new(color.green, 30), "Bull Line Color", group=grp_line)
bear_line_color = input.color(color.new(color.red,   30), "Bear Line Color", group=grp_line)
line_width      = input.int(1, "Line Width", minval=1, maxval=4,             group=grp_line)
line_style_inp  = input.string("Dashed", "Line Style",
                     options=["Dashed","Dotted","Solid"],                    group=grp_line)

grp_alert = "Alert Settings"
alert_bull = input.bool(true, "Alert: Bull Reversal", group=grp_alert)
alert_bear = input.bool(true, "Alert: Bear Reversal", group=grp_alert)

// ─────────────────────────────────────────────
//  LINE STYLE MAPPING
// ─────────────────────────────────────────────
get_line_style() =>
    line_style_inp == "Dotted" ? line.style_dotted :
     line_style_inp == "Solid"  ? line.style_solid  :
     line.style_dashed

// ─────────────────────────────────────────────
//  STOCHASTIC
// ─────────────────────────────────────────────
k_raw = ta.stoch(close, high, low, k_len)
k     = ta.sma(k_raw, k_smooth)
d     = ta.sma(k, d_smooth)

// ─────────────────────────────────────────────
//  STATE VARIABLES
// ─────────────────────────────────────────────
var bool  bull_mode        = false
var float bull_low_price   = na
var int   bull_low_bar     = na
var float bull_ref_level   = na
var line  bull_line        = na
var bool  bull_line_active = false

var bool  bear_mode        = false
var float bear_high_price  = na
var int   bear_high_bar    = na
var float bear_ref_level   = na
var line  bear_line        = na
var bool  bear_line_active = false

// ─────────────────────────────────────────────
//  TRIGGERS & EXITS
// ─────────────────────────────────────────────
bull_trigger = ta.crossunder(k, os_level)
bear_trigger = ta.crossover(k, ob_level)
bull_exit    = ta.crossover(k, ob_level)
bear_exit    = ta.crossunder(k, os_level)

// ─────────────────────────────────────────────
//  HELPER FUNCTIONS
// ─────────────────────────────────────────────
f_find_bull_ref(low_bar_idx, low_bar_high) =>
    result = -1.0
    for i = 1 to math.min(low_bar_idx, 300)
        offset = bar_index - (low_bar_idx - i)
        if offset >= 0
            c_i = close[offset]
            o_i = open[offset]
            h_i = high[offset]
            if c_i < o_i and h_i > low_bar_high
                result := h_i
                break
    result

f_find_bear_ref(high_bar_idx, high_bar_low) =>
    result = -1.0
    for i = 1 to math.min(high_bar_idx, 300)
        offset = bar_index - (high_bar_idx - i)
        if offset >= 0
            c_i = close[offset]
            o_i = open[offset]
            l_i = low[offset]
            if c_i > o_i and l_i < high_bar_low
                result := l_i
                break
    result

// ─────────────────────────────────────────────
//  BULL LOGIC
// ─────────────────────────────────────────────

if bull_exit
    bull_mode        := false
    bull_ref_level   := na
    bull_line_active := false
    bull_low_price   := na
    bull_low_bar     := na
    if not na(bull_line)
        line.delete(bull_line)
        bull_line := na

if bull_trigger
    bull_mode        := true
    bull_low_price   := low
    bull_low_bar     := bar_index
    bull_ref_level   := na
    bull_line_active := false
    if not na(bull_line)
        line.delete(bull_line)
        bull_line := na

if bull_mode and not bull_exit
    if low < bull_low_price
        bull_low_price   := low
        bull_low_bar     := bar_index
        bull_ref_level   := na
        bull_line_active := false
        if not na(bull_line)
            line.delete(bull_line)
            bull_line := na

    if na(bull_ref_level) and not na(bull_low_bar)
        low_bar_high = high[bar_index - bull_low_bar]
        found = f_find_bull_ref(bull_low_bar, low_bar_high)
        if found > 0
            bull_ref_level   := found
            bull_line_active := true
            if not na(bull_line)
                line.delete(bull_line)
            bull_line := line.new(
                 x1    = bull_low_bar,
                 y1    = bull_ref_level,
                 x2    = bar_index,
                 y2    = bull_ref_level,
                 color = bull_line_color,
                 style = get_line_style(),
                 width = line_width)

    if bull_line_active and not na(bull_line)
        line.set_x2(bull_line, bar_index)

bull_signal = bull_mode and bull_line_active and not na(bull_ref_level) and close > bull_ref_level and not bull_exit

if bull_signal
    if show_bull
        if bull_full_label
            // โหมด full: label พร้อมข้อความ small size
            label.new(
                 x         = bar_index,
                 y         = low,
                 text      = "▲ Bull Reversal",
                 style     = label.style_label_up,
                 color     = color.new(color.green, 10),
                 textcolor = color.white,
                 size      = size.small,
                 yloc      = yloc.belowbar)
        else
            // โหมด symbol: สามเหลี่ยมเปล่าๆ ไม่มีกรอบ tiny size
            label.new(
                 x         = bar_index,
                 y         = low,
                 text      = "▲",
                 style     = label.style_none,
                 textcolor = color.green,
                 size      = size.tiny,
                 yloc      = yloc.belowbar)
    if not na(bull_line)
        line.set_x2(bull_line, bar_index)
    bull_low_price   := low
    bull_low_bar     := bar_index
    bull_ref_level   := na
    bull_line_active := false
    bull_line        := na

// ─────────────────────────────────────────────
//  BEAR LOGIC
// ─────────────────────────────────────────────

if bear_exit
    bear_mode        := false
    bear_ref_level   := na
    bear_line_active := false
    bear_high_price  := na
    bear_high_bar    := na
    if not na(bear_line)
        line.delete(bear_line)
        bear_line := na

if bear_trigger
    bear_mode        := true
    bear_high_price  := high
    bear_high_bar    := bar_index
    bear_ref_level   := na
    bear_line_active := false
    if not na(bear_line)
        line.delete(bear_line)
        bear_line := na

if bear_mode and not bear_exit
    if high > bear_high_price
        bear_high_price  := high
        bear_high_bar    := bar_index
        bear_ref_level   := na
        bear_line_active := false
        if not na(bear_line)
            line.delete(bear_line)
            bear_line := na

    if na(bear_ref_level) and not na(bear_high_bar)
        high_bar_low = low[bar_index - bear_high_bar]
        found = f_find_bear_ref(bear_high_bar, high_bar_low)
        if found > 0
            bear_ref_level   := found
            bear_line_active := true
            if not na(bear_line)
                line.delete(bear_line)
            bear_line := line.new(
                 x1    = bear_high_bar,
                 y1    = bear_ref_level,
                 x2    = bar_index,
                 y2    = bear_ref_level,
                 color = bear_line_color,
                 style = get_line_style(),
                 width = line_width)

    if bear_line_active and not na(bear_line)
        line.set_x2(bear_line, bar_index)

bear_signal = bear_mode and bear_line_active and not na(bear_ref_level) and close < bear_ref_level and not bear_exit

if bear_signal
    if show_bear
        if bear_full_label
            // โหมด full: label พร้อมข้อความ small size
            label.new(
                 x         = bar_index,
                 y         = high,
                 text      = "▼ Bear Reversal",
                 style     = label.style_label_down,
                 color     = color.new(color.red, 10),
                 textcolor = color.white,
                 size      = size.small,
                 yloc      = yloc.abovebar)
        else
            // โหมด symbol: สามเหลี่ยมเปล่าๆ ไม่มีกรอบ tiny size
            label.new(
                 x         = bar_index,
                 y         = high,
                 text      = "▼",
                 style     = label.style_none,
                 textcolor = color.red,
                 size      = size.tiny,
                 yloc      = yloc.abovebar)
    if not na(bear_line)
        line.set_x2(bear_line, bar_index)
    bear_high_price  := high
    bear_high_bar    := bar_index
    bear_ref_level   := na
    bear_line_active := false
    bear_line        := na

// ─────────────────────────────────────────────
//  STOCHASTIC (Data Window)
// ─────────────────────────────────────────────
plot(k, "%K", color.new(color.blue,   0), display=display.data_window)
plot(d, "%D", color.new(color.orange, 0), display=display.data_window)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(bull_signal,                "Bull Reversal Only",      "🟢 Bull Reversal – {{ticker}} ปิดเหนือแนวต้าน @ {{close}}")
alertcondition(bear_signal,                "Bear Reversal Only",      "🔴 Bear Reversal – {{ticker}} ปิดต่ำกว่าแนวรับ @ {{close}}")
alertcondition(bull_signal or bear_signal, "Bull or Bear Reversal",   "🔔 Reversal Signal – {{ticker}} @ {{close}}")
````
