# FWBS - Breakouts

- url: https://www.tradingview.com/script/fQDBCxrk-FWBS-Breakouts/
- type: indicator
- pine_id: PUB;a7f7ac1490f44eb38284da617fdcb854
- version: 1.0

## Description

Screens for breakouts on weekly charts with a tight 6-12 week prior consolidation pattern.

## Source Code

````pine
//@version=6
indicator("Financial Wisdom Breakout Strategy", overlay=true, max_boxes_count=50, max_lines_count=100, max_labels_count=50)

// ── Inputs ─────────────────────────────────────────────────────────────────
min_consolidation_bars = input.int(6, "Min Consolidation Weeks", minval=4)
max_stop_pct           = input.float(20.0, "Max Stop Loss %", minval=5, maxval=30)
volume_spike_pct       = input.float(30.0, "Min Volume Spike %", minval=10)
breakout_min_pct       = input.float(5.0, "Min Breakout %", minval=1)
breakout_max_pct       = input.float(20.0, "Max Breakout %", minval=5)
natr_max               = input.float(8.0, "Max NATR (entry filter only)", minval=1)
consolidation_range    = input.float(15.0, "Consolidation Range %", minval=5, maxval=30)

// ── Core Indicators ────────────────────────────────────────────────────────
ma20              = ta.sma(close, 20)
[macd, signal, _] = ta.macd(close, 12, 26, 9)
atr               = ta.atr(14)
natr              = (atr / close) * 100

// ── Resistance: most frequently touched high in top 30% of range ──────────
f_resistance(lookback, range_pct) =>
    con_high = close
    con_low  = close
    for i = 1 to lookback
        if math.abs(close[i] - close) / close * 100 < range_pct
            con_high := math.max(con_high, high[i])
            con_low  := math.min(con_low,  low[i])

    range_size  = con_high - con_low
    bucket_size = range_size / 10

    best_level = con_high
    best_count = 0

    for b = 7 to 9
        level_low  = con_low + b * bucket_size
        level_high = level_low + bucket_size
        count = 0
        for i = 1 to lookback
            if math.abs(close[i] - close) / close * 100 < range_pct
                if high[i] >= level_low and high[i] <= level_high
                    count += 1
        if count > best_count
            best_count := count
            best_level := (level_low + level_high) / 2

    best_level

// ── Support: most frequently touched low in bottom 30% of range ──────────
f_support(lookback, range_pct) =>
    con_high = close
    con_low  = close
    for i = 1 to lookback
        if math.abs(close[i] - close) / close * 100 < range_pct
            con_high := math.max(con_high, high[i])
            con_low  := math.min(con_low,  low[i])

    range_size  = con_high - con_low
    bucket_size = range_size / 10

    best_level = con_low
    best_count = 0

    for b = 0 to 2
        level_low  = con_low + b * bucket_size
        level_high = level_low + bucket_size
        count = 0
        for i = 1 to lookback
            if math.abs(close[i] - close) / close * 100 < range_pct
                if low[i] >= level_low and low[i] <= level_high
                    count += 1
        if count > best_count
            best_count := count
            best_level := (level_low + level_high) / 2

    best_level

resistance          = f_resistance(min_consolidation_bars, consolidation_range)
support             = f_support(min_consolidation_bars,    consolidation_range)
box_range           = resistance - support
upper_third_bottom  = resistance - (box_range / 3)
middle_third_bottom = resistance - (2 * box_range / 3)
stop_level          = middle_third_bottom
stop_pct            = (close - stop_level) / close * 100

// ── Consolidation States ───────────────────────────────────────────────────
is_ranging = close >= support * 0.98 and
     close <= resistance * 1.02 and
     box_range / close * 100 < 20

loose_consolidation  = is_ranging and not (close > ma20 and macd > signal)
strict_consolidation = is_ranging and close > ma20 and macd > signal

// ── Entry Conditions ───────────────────────────────────────────────────────
breakout         = close > resistance and close[1] <= resistance
upper_wick       = high - close
candle_range     = high - low
wick_ok          = candle_range > 0 ? (upper_wick / candle_range) < 0.5 : false
volume_spike     = volume > volume[1] * (1 + volume_spike_pct / 100)
ten_week_high    = close == ta.highest(close, 10)
breakout_size    = (close - close[1]) / close[1] * 100
breakout_size_ok = breakout_size >= breakout_min_pct and breakout_size <= breakout_max_pct
natr_ok          = natr < natr_max
stop_ok          = stop_pct <= max_stop_pct

base_breakout = breakout and wick_ok and volume_spike and
     ten_week_high and breakout_size_ok and stop_ok

loose_entry_signal  = base_breakout and not (close > ma20 and macd > signal and natr_ok)
strict_entry_signal = base_breakout and close > ma20 and macd > signal and natr_ok

// ── Exit ───────────────────────────────────────────────────────────────────
macd_cross_down = ta.crossunder(macd, signal) and close > ma20

// ── Current consolidation box (latest bar only) ───────────────────────────
var box  current_box         = na
var line current_upper_line  = na
var line current_middle_line = na
var line current_stop_line   = na

if barstate.islast
    box.delete(current_box)
    line.delete(current_upper_line)
    line.delete(current_middle_line)
    line.delete(current_stop_line)

    if strict_consolidation
        current_box := box.new(
             left=bar_index - min_consolidation_bars, top=resistance,
             right=bar_index + 2, bottom=support,
             border_color=color.new(color.orange, 0), border_width=2,
             bgcolor=color.new(color.orange, 88))
        current_upper_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=upper_third_bottom,
             x2=bar_index + 2, y2=upper_third_bottom,
             color=color.new(color.orange, 40), width=1, style=line.style_dotted)
        current_middle_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=middle_third_bottom,
             x2=bar_index + 2, y2=middle_third_bottom,
             color=color.new(color.orange, 40), width=1, style=line.style_dotted)
        current_stop_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=stop_level,
             x2=bar_index + 2, y2=stop_level,
             color=color.red, width=1, style=line.style_dashed)

    else if loose_consolidation
        current_box := box.new(
             left=bar_index - min_consolidation_bars, top=resistance,
             right=bar_index + 2, bottom=support,
             border_color=color.new(color.gray, 30), border_width=1,
             bgcolor=color.new(color.gray, 88))
        current_upper_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=upper_third_bottom,
             x2=bar_index + 2, y2=upper_third_bottom,
             color=color.new(color.gray, 50), width=1, style=line.style_dotted)
        current_middle_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=middle_third_bottom,
             x2=bar_index + 2, y2=middle_third_bottom,
             color=color.new(color.gray, 50), width=1, style=line.style_dotted)
        current_stop_line := line.new(
             x1=bar_index - min_consolidation_bars, y1=stop_level,
             x2=bar_index + 2, y2=stop_level,
             color=color.new(color.red, 40), width=1, style=line.style_dashed)

// ── Historic entry signals ─────────────────────────────────────────────────
if strict_entry_signal
    risk   = close - stop_level
    target = close + (risk * 2)
    box.new(
         left=bar_index - min_consolidation_bars, top=resistance,
         right=bar_index, bottom=support,
         border_color=color.new(color.green, 0), border_width=2,
         bgcolor=color.new(color.green, 88))
    line.new(x1=bar_index - min_consolidation_bars, y1=upper_third_bottom,
         x2=bar_index, y2=upper_third_bottom,
         color=color.new(color.gray, 30), width=1, style=line.style_dotted)
    line.new(x1=bar_index - min_consolidation_bars, y1=middle_third_bottom,
         x2=bar_index, y2=middle_third_bottom,
         color=color.new(color.gray, 30), width=1, style=line.style_dotted)
    line.new(x1=bar_index, y1=stop_level, x2=bar_index + 10, y2=stop_level,
         color=color.red, width=2, style=line.style_dashed)
    line.new(x1=bar_index, y1=target, x2=bar_index + 10, y2=target,
         color=color.green, width=2, style=line.style_dashed)
    label.new(bar_index, low,
         text="BUY ✓\nStop: " + str.tostring(math.round(stop_level, 2)) +
              " (" + str.tostring(math.round(stop_pct, 1)) + "%)\n" +
              "Target: " + str.tostring(math.round(target, 2)),
         color=color.green, textcolor=color.white,
         style=label.style_label_up, size=size.small)

if loose_entry_signal
    risk   = close - stop_level
    target = close + (risk * 2)
    box.new(
         left=bar_index - min_consolidation_bars, top=resistance,
         right=bar_index, bottom=support,
         border_color=color.new(color.teal, 0), border_width=1,
         bgcolor=color.new(color.teal, 88))
    line.new(x1=bar_index - min_consolidation_bars, y1=upper_third_bottom,
         x2=bar_index, y2=upper_third_bottom,
         color=color.new(color.gray, 50), width=1, style=line.style_dotted)
    line.new(x1=bar_index - min_consolidation_bars, y1=middle_third_bottom,
         x2=bar_index, y2=middle_third_bottom,
         color=color.new(color.gray, 50), width=1, style=line.style_dotted)
    line.new(x1=bar_index, y1=stop_level, x2=bar_index + 10, y2=stop_level,
         color=color.new(color.red, 30), width=1, style=line.style_dashed)
    line.new(x1=bar_index, y1=target, x2=bar_index + 10, y2=target,
         color=color.new(color.teal, 0), width=1, style=line.style_dashed)
    label.new(bar_index, low,
         text="BUY ~\nStop: " + str.tostring(math.round(stop_level, 2)) +
              " (" + str.tostring(math.round(stop_pct, 1)) + "%)\n" +
              "Target: " + str.tostring(math.round(target, 2)),
         color=color.teal, textcolor=color.white,
         style=label.style_label_up, size=size.small)

// ── Raise stop ────────────────────────────────────────────────────────────
if macd_cross_down
    label.new(bar_index, high,
         text="RAISE STOP\nto: " + str.tostring(math.round(low, 2)),
         color=color.orange, textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ── Plots ──────────────────────────────────────────────────────────────────
plot(ma20, "20W MA", color=color.blue, linewidth=2)
plot(strict_entry_signal ? stop_level : na, "Stop Level", color=color.red, display=display.none)

// ── Signal Markers ─────────────────────────────────────────────────────────
plotshape(strict_entry_signal, "Strict Entry", style=shape.triangleup,
     location=location.belowbar, color=color.green, size=size.normal)
plotshape(loose_entry_signal,  "Loose Entry",  style=shape.triangleup,
     location=location.belowbar, color=color.teal, size=size.small)
plotshape(macd_cross_down,     "Raise Stop",   style=shape.diamond,
     location=location.abovebar, color=color.orange, size=size.small)
plot(strict_entry_signal ? 1 : 0, "Strict Signal", display=display.none)
plot(loose_entry_signal ? 1 : 0, "Loose Signal", display=display.none)
// ── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(strict_entry_signal, "Strict Breakout Entry", "{{ticker}} strict breakout entry")
alertcondition(loose_entry_signal,  "Loose Breakout Entry",  "{{ticker}} loose breakout entry")
alertcondition(macd_cross_down,     "Raise Stop",            "{{ticker}} MACD cross down — raise stop")
````
