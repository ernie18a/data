# LevelMap - Smart Levels + Pattern Detection

- url: https://www.tradingview.com/script/cIYkcnOe-LevelMap-Smart-Levels-Pattern-Detection/
- type: indicator
- pine_id: PUB;e7f5e6b95bb3492cb2c0ce08041f59fb
- version: 1.0

## Description

All your key price levels in one place. Tracks Asia+EU session ranges, Previous Day H/L, Weekly H/L, and Previous 4H H/L with clean auto-extending lines and collision-free labels. Includes swing structure detection (HH/HL/LH/LL), high-probability trend signals, and strict-filtered reversal patterns including engulfing candles, pin bars, double tops/bottoms, liquidity sweeps, and RSI divergence. Everything is fully customizable — colors, widths, label sizes, and filters — built for serious intraday and swing traders.

## Source Code

````pine
//@version=6
indicator("ES Levels + Patterns", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ═══════════════════════════════════════════════════════════════
// MASTER TOGGLES
// ═══════════════════════════════════════════════════════════════
show_asia_eu_combined = input.bool(true,  "Show Asia+EU Combined Range", group="Levels")
show_pd               = input.bool(true,  "Show PDH / PDL",              group="Levels")
show_weekly           = input.bool(true,  "Show Weekly H/L",             group="Levels")
show_4h               = input.bool(true,  "Show Prev 4H H/L",            group="Levels")
show_ma               = input.bool(true,  "Show EMA / SMA / VWAP",       group="Moving Averages")

show_swing_lbl  = input.bool(true,  "Show Swing Labels (HH/HL/LH/LL)", group="Swing Structure")
show_swing_line = input.bool(false, "Show Swing Connecting Lines",      group="Swing Structure")
show_trend      = input.bool(true,  "Show HP LONG / HP SHORT Signals",  group="Swing Structure")

show_engulf = input.bool(true, "Show Bullish/Bearish Engulfing",  group="Reversal Patterns")
show_pin    = input.bool(true, "Show Pin Bars (Strict Filter)",   group="Reversal Patterns")
show_dbl    = input.bool(true, "Show Double Top / Double Bottom", group="Reversal Patterns")
show_sweep  = input.bool(true, "Show Liquidity Sweeps",           group="Reversal Patterns")
show_div    = input.bool(true, "Show RSI Divergence",             group="Reversal Patterns")

// ═══════════════════════════════════════════════════════════════
// LINE DISPLAY
// ═══════════════════════════════════════════════════════════════
line_extend_back  = input.int(50,  "Lines Extend Back (bars)", minval=10, maxval=500, group="Line Display")
auto_extend_right = input.bool(true, "Auto-Extend Right",       group="Line Display")
level_label_size  = input.string("small", "Level Label Size", options=["tiny","small","normal","large"], group="Line Display")
label_offset      = input.int(5, "Label Horizontal Offset", minval=0, maxval=50, group="Line Display")
collision_factor  = input.float(0.5, "Label Spacing (× ATR)", minval=0.1, maxval=3.0, step=0.1, group="Line Display")

col_4h       = input.color(color.new(#FF9800, 0),      "4H Line Color",      group="4H Style")
width_4h     = input.int(2, "4H Line Width", minval=1, maxval=5,              group="4H Style")
col_pd       = input.color(color.new(color.white, 0),  "PD Line Color",      group="Prev Day Style")
width_pd     = input.int(2, "PD Line Width", minval=1, maxval=5,              group="Prev Day Style")
col_weekly   = input.color(color.new(color.yellow, 0), "Weekly Line Color",  group="Weekly Style")
width_weekly = input.int(2, "Weekly Line Width", minval=1, maxval=5,          group="Weekly Style")
col_asiaeu   = input.color(color.new(color.aqua, 0),   "Asia+EU Color",      group="Asia+EU Style")
width_asiaeu = input.int(2, "Asia+EU Line Width", minval=1, maxval=5,         group="Asia+EU Style")

// ═══════════════════════════════════════════════════════════════
// PIN BAR FILTERS
// ═══════════════════════════════════════════════════════════════
pin_filter_level   = input.bool(true,  "Pin: Require Proximity to Key Level",  group="Pin Bar Filters")
pin_filter_rsi     = input.bool(true,  "Pin: Require RSI Confirmation",        group="Pin Bar Filters")
pin_filter_swing   = input.bool(true,  "Pin: Require Swing Low/High or Sweep", group="Pin Bar Filters")
pin_level_tol_pct  = input.float(0.10, "Pin Level Proximity %", minval=0.01, step=0.01, group="Pin Bar Filters")
pin_rsi_oversold   = input.int(40, "Pin Hammer Max RSI", minval=10, maxval=50, group="Pin Bar Filters")
pin_rsi_overbought = input.int(60, "Pin Shooting Star Min RSI", minval=50, maxval=90, group="Pin Bar Filters")

// ═══════════════════════════════════════════════════════════════
// SESSIONS / SWING / PATTERN PARAMS
// ═══════════════════════════════════════════════════════════════
asia_sess       = input.session("1700-0000", "Asia Session",   group="Sessions")
eu_sess         = input.session("0200-0930", "Europe Session", group="Sessions")
swing_length    = input.int(5, "Swing Pivot Length", minval=2, maxval=20, group="Swing Structure")
pin_ratio       = input.float(2.0, "Pin Bar Wick/Body Ratio", minval=1.0, step=0.1, group="Reversal Patterns")
dbl_tolerance   = input.float(0.15, "Double Top/Bottom Tolerance %", minval=0.01, step=0.01, group="Reversal Patterns")
sweep_lookback  = input.int(20, "Sweep Lookback Bars", minval=5, group="Reversal Patterns")
rsi_length      = input.int(14, "RSI Length", minval=2, group="Reversal Patterns")

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════
col_vwap   = input.color(color.blue,    "VWAP Color",   group="MA Colors")
col_ema50  = input.color(color.orange,  "EMA50 Color",  group="MA Colors")
col_ema100 = input.color(color.green,   "EMA100 Color", group="MA Colors")
col_sma20  = input.color(color.fuchsia, "SMA20 Color",  group="MA Colors")

col_hh   = input.color(color.new(color.green, 0),  "HH Color", group="Swing Colors")
col_hl   = input.color(color.new(color.green, 40), "HL Color", group="Swing Colors")
col_lh   = input.color(color.new(color.red, 40),   "LH Color", group="Swing Colors")
col_ll   = input.color(color.new(color.red, 0),    "LL Color", group="Swing Colors")
col_bull = input.color(color.new(color.green, 0),  "HP Bull Color", group="Swing Colors")
col_bear = input.color(color.new(color.red, 0),    "HP Bear Color", group="Swing Colors")

col_engulf_bull = input.color(color.lime,   "Bull Engulf Color", group="Pattern Colors")
col_engulf_bear = input.color(color.red,    "Bear Engulf Color", group="Pattern Colors")
col_pin_bull    = input.color(color.aqua,   "Pin Bull Color",    group="Pattern Colors")
col_pin_bear    = input.color(color.maroon, "Pin Bear Color",    group="Pattern Colors")
col_dbl_top     = input.color(color.red,    "Double Top Color",  group="Pattern Colors")
col_dbl_bot     = input.color(color.green,  "Double Bot Color",  group="Pattern Colors")
col_sweep_h     = input.color(color.orange, "Sweep High Color",  group="Pattern Colors")
col_sweep_l     = input.color(color.teal,   "Sweep Low Color",   group="Pattern Colors")
col_div_bull    = input.color(color.lime,   "Bull Div Color",    group="Pattern Colors")
col_div_bear    = input.color(color.red,    "Bear Div Color",    group="Pattern Colors")

// ═══════════════════════════════════════════════════════════════
// CONVERSIONS
// ═══════════════════════════════════════════════════════════════
lbl_size = size.small
if level_label_size == "tiny"
    lbl_size := size.tiny
if level_label_size == "normal"
    lbl_size := size.normal
if level_label_size == "large"
    lbl_size := size.large

ext_right = auto_extend_right ? extend.right : extend.none
atr_for_offset = ta.atr(14)
collision_dist = atr_for_offset * collision_factor

// ═══════════════════════════════════════════════════════════════
// SESSION DETECTION — ASIA / EU
// ═══════════════════════════════════════════════════════════════
in_asia = not na(time(timeframe.period, asia_sess, "America/New_York"))
in_eu   = not na(time(timeframe.period, eu_sess,   "America/New_York"))

var float asia_high = na
var float asia_low  = na
var float asiaH     = na
var float asiaL     = na
var float eu_high   = na
var float eu_low    = na
var float euH       = na
var float euL       = na

if in_asia
    asia_high := na(asia_high) ? high : math.max(asia_high, high)
    asia_low  := na(asia_low)  ? low  : math.min(asia_low, low)

if not in_asia and in_asia[1]
    asiaH := asia_high
    asiaL := asia_low
    asia_high := na
    asia_low := na

if in_eu
    eu_high := na(eu_high) ? high : math.max(eu_high, high)
    eu_low  := na(eu_low)  ? low  : math.min(eu_low, low)

if not in_eu and in_eu[1]
    euH := eu_high
    euL := eu_low
    eu_high := na
    eu_low := na

// ═══════════════════════════════════════════════════════════════
// MAs / VWAP
// ═══════════════════════════════════════════════════════════════
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
sma20  = ta.sma(close, 20)

plot(show_ma ? ema50  : na, "EMA50",  color=col_ema50,  linewidth=1)
plot(show_ma ? ema100 : na, "EMA100", color=col_ema100, linewidth=1)
plot(show_ma ? sma20  : na, "SMA20",  color=col_sma20,  linewidth=1)

var float vp  = 0.0
var float vol = 0.0

if timeframe.change("D")
    vp := 0.0
    vol := 0.0

typical_price = (high + low + close) / 3.0
vp += typical_price * volume
vol += volume
vwap = vol != 0 ? vp / vol : na

plot(show_ma ? vwap : na, "VWAP", color=col_vwap, linewidth=1)

// ═══════════════════════════════════════════════════════════════
// 4H — PREVIOUS COMPLETED 4H CANDLE HIGH / LOW
// On the actual 4H chart, this uses the visible candle immediately to the left.
// On lower timeframes, this pulls the previous completed 4H candle.
// ═══════════════════════════════════════════════════════════════
is_4h_chart = timeframe.in_seconds(timeframe.period) == timeframe.in_seconds("240")
[h4H_prev_security, h4L_prev_security] = request.security(syminfo.tickerid, "240", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

locked_4h_h = is_4h_chart ? high[1] : h4H_prev_security
locked_4h_l = is_4h_chart ? low[1]  : h4L_prev_security

var line line_4h_h = na
var line line_4h_l = na

if show_4h and not na(locked_4h_h)
    if na(line_4h_h)
        line_4h_h := line.new(bar_index - line_extend_back, locked_4h_h, bar_index, locked_4h_h, extend=ext_right, color=col_4h, width=width_4h, style=line.style_solid)
    else
        line.set_xy1(line_4h_h, bar_index - line_extend_back, locked_4h_h)
        line.set_xy2(line_4h_h, bar_index, locked_4h_h)
        line.set_extend(line_4h_h, ext_right)
        line.set_color(line_4h_h, col_4h)
        line.set_width(line_4h_h, width_4h)

    if na(line_4h_l)
        line_4h_l := line.new(bar_index - line_extend_back, locked_4h_l, bar_index, locked_4h_l, extend=ext_right, color=col_4h, width=width_4h, style=line.style_solid)
    else
        line.set_xy1(line_4h_l, bar_index - line_extend_back, locked_4h_l)
        line.set_xy2(line_4h_l, bar_index, locked_4h_l)
        line.set_extend(line_4h_l, ext_right)
        line.set_color(line_4h_l, col_4h)
        line.set_width(line_4h_l, width_4h)
else
    if not na(line_4h_h)
        line.delete(line_4h_h)
        line_4h_h := na
    if not na(line_4h_l)
        line.delete(line_4h_l)
        line_4h_l := na

// ═══════════════════════════════════════════════════════════════
// PREV DAY — REFRESHES EACH NEW DAY
// ═══════════════════════════════════════════════════════════════
[pdH_new, pdL_new] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)
new_day = ta.change(time("D")) != 0

var line  line_pdh   = na
var line  line_pdl   = na
var float locked_pdh = na
var float locked_pdl = na
var int   start_pd   = na

if new_day and not na(pdH_new)
    locked_pdh := pdH_new
    locked_pdl := pdL_new
    start_pd   := bar_index

    if not na(line_pdh)
        line.delete(line_pdh)
    if not na(line_pdl)
        line.delete(line_pdl)

    line_pdh := na
    line_pdl := na

if show_pd and not na(locked_pdh)
    if na(line_pdh)
        line_pdh := line.new(start_pd - line_extend_back, locked_pdh, start_pd, locked_pdh, extend=ext_right, color=col_pd, width=width_pd, style=line.style_dashed)
    if na(line_pdl)
        line_pdl := line.new(start_pd - line_extend_back, locked_pdl, start_pd, locked_pdl, extend=ext_right, color=col_pd, width=width_pd, style=line.style_dashed)

// ═══════════════════════════════════════════════════════════════
// WEEKLY HIGH/LOW — CURRENT RUNNING WEEK
// ═══════════════════════════════════════════════════════════════
new_week = ta.change(time("W")) != 0

var float running_wh = na
var float running_wl = na
var float locked_wh  = na
var float locked_wl  = na
var line  line_wh    = na
var line  line_wl    = na
var int   start_w    = na

if new_week
    running_wh := high
    running_wl := low
    start_w := bar_index

    if not na(line_wh)
        line.delete(line_wh)
    if not na(line_wl)
        line.delete(line_wl)

    line_wh := na
    line_wl := na
else
    running_wh := na(running_wh) ? high : math.max(running_wh, high)
    running_wl := na(running_wl) ? low  : math.min(running_wl, low)

locked_wh := running_wh
locked_wl := running_wl

if show_weekly and not na(locked_wh)
    if na(line_wh)
        line_wh := line.new(start_w - line_extend_back, locked_wh, start_w, locked_wh, extend=ext_right, color=col_weekly, width=width_weekly, style=line.style_solid)
    else
        line.set_y1(line_wh, locked_wh)
        line.set_y2(line_wh, locked_wh)

    if na(line_wl)
        line_wl := line.new(start_w - line_extend_back, locked_wl, start_w, locked_wl, extend=ext_right, color=col_weekly, width=width_weekly, style=line.style_solid)
    else
        line.set_y1(line_wl, locked_wl)
        line.set_y2(line_wl, locked_wl)

// ═══════════════════════════════════════════════════════════════
// ASIA + EU COMBINED
// ═══════════════════════════════════════════════════════════════
combined_high = na(asiaH) and na(euH) ? na : na(asiaH) ? euH : na(euH) ? asiaH : math.max(asiaH, euH)
combined_low  = na(asiaL) and na(euL) ? na : na(asiaL) ? euL : na(euL) ? asiaL : math.min(asiaL, euL)

var line line_aeu_h = na
var line line_aeu_l = na

if show_asia_eu_combined and not na(combined_high)
    if na(line_aeu_h)
        line_aeu_h := line.new(bar_index - line_extend_back, combined_high, bar_index, combined_high, extend=ext_right, color=col_asiaeu, width=width_asiaeu, style=line.style_solid)
    if na(line_aeu_l)
        line_aeu_l := line.new(bar_index - line_extend_back, combined_low, bar_index, combined_low, extend=ext_right, color=col_asiaeu, width=width_asiaeu, style=line.style_solid)

    line.set_y1(line_aeu_h, combined_high)
    line.set_y2(line_aeu_h, combined_high)
    line.set_y1(line_aeu_l, combined_low)
    line.set_y2(line_aeu_l, combined_low)

// ═══════════════════════════════════════════════════════════════
// SMART LABELS — LEVELS + MAs
// 4H labels are pinned directly to their line values.
// Other level labels still use collision handling.
// ═══════════════════════════════════════════════════════════════
var label[] all_labels = array.new_label(0)

if barstate.islast
    label_count = array.size(all_labels)
    if label_count > 0
        for i = 0 to label_count - 1
            label.delete(array.get(all_labels, i))
        array.clear(all_labels)

    prices  = array.new_float(0)
    names   = array.new_string(0)
    cols    = array.new_color(0)
    txtcols = array.new_color(0)

    if show_pd and not na(locked_pdh)
        array.push(prices, locked_pdh)
        array.push(names, "PDH " + str.tostring(locked_pdh, "#.##"))
        array.push(cols, color.new(color.gray, 20))
        array.push(txtcols, color.white)

    if show_pd and not na(locked_pdl)
        array.push(prices, locked_pdl)
        array.push(names, "PDL " + str.tostring(locked_pdl, "#.##"))
        array.push(cols, color.new(color.gray, 20))
        array.push(txtcols, color.white)

    if show_weekly and not na(locked_wh)
        array.push(prices, locked_wh)
        array.push(names, "Weekly High " + str.tostring(locked_wh, "#.##"))
        array.push(cols, col_weekly)
        array.push(txtcols, color.black)

    if show_weekly and not na(locked_wl)
        array.push(prices, locked_wl)
        array.push(names, "Weekly Low " + str.tostring(locked_wl, "#.##"))
        array.push(cols, col_weekly)
        array.push(txtcols, color.black)

    if show_asia_eu_combined and not na(combined_high)
        array.push(prices, combined_high)
        array.push(names, "Asia+EU High " + str.tostring(combined_high, "#.##"))
        array.push(cols, col_asiaeu)
        array.push(txtcols, color.black)

    if show_asia_eu_combined and not na(combined_low)
        array.push(prices, combined_low)
        array.push(names, "Asia+EU Low " + str.tostring(combined_low, "#.##"))
        array.push(cols, col_asiaeu)
        array.push(txtcols, color.black)

    n = array.size(prices)

    if n > 0
        for i = 0 to n - 2
            for j = 0 to n - i - 2
                if array.get(prices, j) > array.get(prices, j + 1)
                    temp_price = array.get(prices, j)
                    array.set(prices, j, array.get(prices, j + 1))
                    array.set(prices, j + 1, temp_price)

                    temp_name = array.get(names, j)
                    array.set(names, j, array.get(names, j + 1))
                    array.set(names, j + 1, temp_name)

                    temp_col = array.get(cols, j)
                    array.set(cols, j, array.get(cols, j + 1))
                    array.set(cols, j + 1, temp_col)

                    temp_txtcol = array.get(txtcols, j)
                    array.set(txtcols, j, array.get(txtcols, j + 1))
                    array.set(txtcols, j + 1, temp_txtcol)

        display_y = array.new_float(0)

        for i = 0 to n - 1
            array.push(display_y, array.get(prices, i))

        for i = 1 to n - 1
            prev_y = array.get(display_y, i - 1)
            this_y = array.get(display_y, i)
            if this_y - prev_y < collision_dist
                array.set(display_y, i, prev_y + collision_dist)

        for i = 0 to n - 1
            new_lbl = label.new(bar_index + label_offset, array.get(display_y, i), array.get(names, i), style=label.style_label_left, color=array.get(cols, i), textcolor=array.get(txtcols, i), size=lbl_size)
            array.push(all_labels, new_lbl)

    if show_4h and not na(locked_4h_h)
        array.push(all_labels, label.new(bar_index + label_offset, locked_4h_h, "Prev 4H High " + str.tostring(locked_4h_h, "#.##"), style=label.style_label_left, color=col_4h, textcolor=color.white, size=lbl_size))

    if show_4h and not na(locked_4h_l)
        array.push(all_labels, label.new(bar_index + label_offset, locked_4h_l, "Prev 4H Low " + str.tostring(locked_4h_l, "#.##"), style=label.style_label_left, color=col_4h, textcolor=color.white, size=lbl_size))

    if show_ma
        if not na(vwap)
            array.push(all_labels, label.new(bar_index + label_offset, vwap, "VWAP " + str.tostring(vwap, "#.##"), style=label.style_label_left, color=col_vwap, textcolor=color.white, size=lbl_size))
        if not na(ema50)
            array.push(all_labels, label.new(bar_index + label_offset, ema50, "EMA50 " + str.tostring(ema50, "#.##"), style=label.style_label_left, color=col_ema50, textcolor=color.white, size=lbl_size))
        if not na(ema100)
            array.push(all_labels, label.new(bar_index + label_offset, ema100, "EMA100 " + str.tostring(ema100, "#.##"), style=label.style_label_left, color=col_ema100, textcolor=color.white, size=lbl_size))
        if not na(sma20)
            array.push(all_labels, label.new(bar_index + label_offset, sma20, "SMA20 " + str.tostring(sma20, "#.##"), style=label.style_label_left, color=col_sma20, textcolor=color.white, size=lbl_size))

// ═══════════════════════════════════════════════════════════════
// SWING STRUCTURE
// ═══════════════════════════════════════════════════════════════
swingHigh = ta.pivothigh(high, swing_length, swing_length)
swingLow  = ta.pivotlow(low, swing_length, swing_length)

var float prevSwingHigh1    = na
var float prevSwingHigh2    = na
var int   prevSwingHighBar1 = na
var int   prevSwingHighBar2 = na
var float prevSwingLow1     = na
var float prevSwingLow2     = na
var int   prevSwingLowBar1  = na
var int   prevSwingLowBar2  = na

if not na(swingHigh)
    prevSwingHigh2    := prevSwingHigh1
    prevSwingHighBar2 := prevSwingHighBar1
    prevSwingHigh1    := swingHigh
    prevSwingHighBar1 := bar_index - swing_length

if not na(swingLow)
    prevSwingLow2    := prevSwingLow1
    prevSwingLowBar2 := prevSwingLowBar1
    prevSwingLow1    := swingLow
    prevSwingLowBar1 := bar_index - swing_length

isHH = not na(swingHigh) and not na(prevSwingHigh2) and swingHigh > prevSwingHigh2
isLH = not na(swingHigh) and not na(prevSwingHigh2) and swingHigh < prevSwingHigh2
isHL = not na(swingLow)  and not na(prevSwingLow2)  and swingLow  > prevSwingLow2
isLL = not na(swingLow)  and not na(prevSwingLow2)  and swingLow  < prevSwingLow2

if show_swing_lbl
    if isHH
        label.new(bar_index - swing_length, swingHigh, "HH", style=label.style_label_down, color=col_hh, textcolor=color.white, size=size.small)
    if isLH
        label.new(bar_index - swing_length, swingHigh, "LH", style=label.style_label_down, color=col_lh, textcolor=color.white, size=size.small)
    if isHL
        label.new(bar_index - swing_length, swingLow, "HL", style=label.style_label_up, color=col_hl, textcolor=color.white, size=size.small)
    if isLL
        label.new(bar_index - swing_length, swingLow, "LL", style=label.style_label_up, color=col_ll, textcolor=color.white, size=size.small)

if show_swing_line and not na(swingHigh) and not na(prevSwingHighBar2) and not na(prevSwingHigh2)
    line.new(prevSwingHighBar2, prevSwingHigh2, bar_index - swing_length, swingHigh, color=isHH ? col_hh : col_lh, width=1, style=line.style_solid)

if show_swing_line and not na(swingLow) and not na(prevSwingLowBar2) and not na(prevSwingLow2)
    line.new(prevSwingLowBar2, prevSwingLow2, bar_index - swing_length, swingLow, color=isHL ? col_hl : col_ll, width=1, style=line.style_solid)

// ═══════════════════════════════════════════════════════════════
// ENGULFING
// ═══════════════════════════════════════════════════════════════
body_curr   = math.abs(close - open)
body_prev   = math.abs(close[1] - open[1])
bull_engulf = close > open and close[1] < open[1] and close > open[1] and open < close[1] and body_curr > body_prev
bear_engulf = close < open and close[1] > open[1] and close < open[1] and open > close[1] and body_curr > body_prev

if show_engulf and bull_engulf
    label.new(bar_index, low, "BE", style=label.style_label_up, color=col_engulf_bull, textcolor=color.white, size=size.tiny)

if show_engulf and bear_engulf
    label.new(bar_index, high, "BE", style=label.style_label_down, color=col_engulf_bear, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// ═══════════════════════════════════════════════════════════════
recent_high = ta.highest(high, sweep_lookback)[1]
recent_low  = ta.lowest(low, sweep_lookback)[1]
sweep_high  = high > recent_high and close < recent_high
sweep_low   = low  < recent_low  and close > recent_low

if show_sweep and sweep_high
    label.new(bar_index, high, "Sweep", style=label.style_label_down, color=col_sweep_h, textcolor=color.white, size=size.tiny)

if show_sweep and sweep_low
    label.new(bar_index, low, "Sweep", style=label.style_label_up, color=col_sweep_l, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// RSI
// ═══════════════════════════════════════════════════════════════
rsi_val = ta.rsi(close, rsi_length)

// ═══════════════════════════════════════════════════════════════
// PIN BAR STRICT FILTER
// ═══════════════════════════════════════════════════════════════
pdH = locked_pdh
pdL = locked_pdl
wH  = locked_wh
wL  = locked_wl
h4H = locked_4h_h
h4L = locked_4h_l

candle_range = high - low
body         = math.abs(close - open)
upper_wick   = high - math.max(close, open)
lower_wick   = math.min(close, open) - low

raw_hammer   = candle_range > 0 and lower_wick >= body * pin_ratio and upper_wick <= body and close > open
raw_shooting = candle_range > 0 and upper_wick >= body * pin_ratio and lower_wick <= body and close < open

level_tol_low  = low  * (pin_level_tol_pct / 100.0)
level_tol_high = high * (pin_level_tol_pct / 100.0)

near_level_low  = (not na(pdL) and math.abs(low - pdL) <= level_tol_low) or (not na(asiaL) and math.abs(low - asiaL) <= level_tol_low) or (not na(euL) and math.abs(low - euL) <= level_tol_low) or (not na(h4L) and math.abs(low - h4L) <= level_tol_low) or (not na(wL) and math.abs(low - wL) <= level_tol_low)
near_level_high = (not na(pdH) and math.abs(high - pdH) <= level_tol_high) or (not na(asiaH) and math.abs(high - asiaH) <= level_tol_high) or (not na(euH) and math.abs(high - euH) <= level_tol_high) or (not na(h4H) and math.abs(high - h4H) <= level_tol_high) or (not na(wH) and math.abs(high - wH) <= level_tol_high)

rsi_ok_hammer   = rsi_val < pin_rsi_oversold
rsi_ok_shooting = rsi_val > pin_rsi_overbought

at_swing_low  = not na(swingLow[swing_length])  or sweep_low  or sweep_low[1]  or sweep_low[2]
at_swing_high = not na(swingHigh[swing_length]) or sweep_high or sweep_high[1] or sweep_high[2]

filter_level_h = not pin_filter_level or near_level_low
filter_level_s = not pin_filter_level or near_level_high
filter_rsi_h   = not pin_filter_rsi   or rsi_ok_hammer
filter_rsi_s   = not pin_filter_rsi   or rsi_ok_shooting
filter_swing_h = not pin_filter_swing or at_swing_low
filter_swing_s = not pin_filter_swing or at_swing_high

is_hammer   = raw_hammer   and filter_level_h and filter_rsi_h and filter_swing_h
is_shooting = raw_shooting and filter_level_s and filter_rsi_s and filter_swing_s

if show_pin and is_hammer
    label.new(bar_index, low, "H", style=label.style_label_up, color=col_pin_bull, textcolor=color.white, size=size.tiny)

if show_pin and is_shooting
    label.new(bar_index, high, "SS", style=label.style_label_down, color=col_pin_bear, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// DOUBLE TOP / BOTTOM
// ═══════════════════════════════════════════════════════════════
tol_pct       = dbl_tolerance / 100.0
double_top    = not na(swingHigh) and not na(prevSwingHigh2) and math.abs(swingHigh - prevSwingHigh2) / prevSwingHigh2 < tol_pct
double_bottom = not na(swingLow)  and not na(prevSwingLow2)  and math.abs(swingLow  - prevSwingLow2)  / prevSwingLow2  < tol_pct

if show_dbl and double_top
    label.new(bar_index - swing_length, swingHigh, "2T", style=label.style_label_down, color=col_dbl_top, textcolor=color.white, size=size.small)

if show_dbl and double_bottom
    label.new(bar_index - swing_length, swingLow, "2B", style=label.style_label_up, color=col_dbl_bot, textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// RSI DIVERGENCE
// ═══════════════════════════════════════════════════════════════
bull_div = false
bear_div = false

if not na(swingLow) and not na(prevSwingLow2)
    rsi_now  = rsi_val[swing_length]
    rsi_prev = nz(prevSwingLow2 > 0 ? rsi_val[bar_index - prevSwingLowBar2 + swing_length] : na)
    bull_div := swingLow < prevSwingLow2 and rsi_now > rsi_prev

if not na(swingHigh) and not na(prevSwingHigh2)
    rsi_now2  = rsi_val[swing_length]
    rsi_prev2 = nz(prevSwingHigh2 > 0 ? rsi_val[bar_index - prevSwingHighBar2 + swing_length] : na)
    bear_div  := swingHigh > prevSwingHigh2 and rsi_now2 < rsi_prev2

if show_div and bull_div
    label.new(bar_index - swing_length, swingLow, "Div+", style=label.style_label_up, color=col_div_bull, textcolor=color.white, size=size.small)

if show_div and bear_div
    label.new(bar_index - swing_length, swingHigh, "Div-", style=label.style_label_down, color=col_div_bear, textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// HP TREND SIGNAL
// ═══════════════════════════════════════════════════════════════
ema_bull  = close > ema50 and ema50 > ema100
ema_bear  = close < ema50 and ema50 < ema100
vwap_bull = close > vwap
vwap_bear = close < vwap

var bool structure_bull = false
var bool structure_bear = false

if isHH or isHL
    structure_bull := true
    structure_bear := false

if isLH or isLL
    structure_bear := true
    structure_bull := false

hp_bull = ema_bull and vwap_bull and structure_bull
hp_bear = ema_bear and vwap_bear and structure_bear

bgcolor(show_trend and hp_bull ? color.new(color.green, 92) : na, title="HP Bull BG")
bgcolor(show_trend and hp_bear ? color.new(color.red, 92) : na, title="HP Bear BG")

if show_trend and hp_bull and not na(swingLow) and isHL
    label.new(bar_index - swing_length, swingLow - swingLow * 0.0005, "▲ HP LONG", style=label.style_label_up, color=col_bull, textcolor=color.white, size=size.normal)

if show_trend and hp_bear and not na(swingHigh) and isLH
    label.new(bar_index - swing_length, swingHigh + swingHigh * 0.0005, "▼ HP SHORT", style=label.style_label_down, color=col_bear, textcolor=color.white, size=size.normal)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(hp_bull, "HP LONG", "High-probability LONG setup confirmed")
alertcondition(hp_bear, "HP SHORT", "High-probability SHORT setup confirmed")
alertcondition(bull_engulf, "Bull Engulfing", "Bullish engulfing detected")
alertcondition(bear_engulf, "Bear Engulfing", "Bearish engulfing detected")
alertcondition(is_hammer, "Hammer", "Filtered hammer pin bar detected")
alertcondition(is_shooting, "Shooting Star", "Filtered shooting star detected")
alertcondition(double_top, "Double Top", "Double top forming")
alertcondition(double_bottom, "Double Bottom", "Double bottom forming")
alertcondition(sweep_high, "Sweep High", "Liquidity sweep above recent high")
alertcondition(sweep_low, "Sweep Low", "Liquidity sweep below recent low")
alertcondition(bull_div, "Bull Divergence", "Bullish RSI divergence")
alertcondition(bear_div, "Bear Divergence", "Bearish RSI divergence")
````
