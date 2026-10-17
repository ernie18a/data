# Swing Failure Pattern [ SFP ] - FloAlgo

- url: https://www.tradingview.com/script/aQULneuD-Swing-Failure-Pattern-SFP-FloAlgo/
- type: indicator
- pine_id: PUB;d3102b4bda65445cb03a6318e1304c10
- version: 1.0

## Description

This indicator detects Swing Failure Patterns (SFP) — a Smart Money Concepts technique that identifies liquidity sweeps followed by a Change in State of Delivery (CISD), signaling potential price reversals.

[b]How It Works[/b]
The script operates in three stages:
[list]
[*]Liquidity Sweep Detection — Identifies when price briefly breaks above a pivot high or below a pivot low, sweeping resting liquidity beyond those levels.
[*]CISD Confirmation — Validates the sweep by detecting a Change in State of Delivery: a candle close that reverses back through a key open level, confirming institutional rejection.
[*]Signal Trigger — A bullish or bearish SFP signal is confirmed only when both the sweep and CISD occur within the defined patience window, reducing false positives significantly.
[/list]


Exit System — 5-Layer Logic
Rather than relying on a fixed take profit, this script uses a dynamic multi-layer exit system designed to protect capital and lock in gains:
[list]
[*]Initial Stop Loss — Set at the high/low of the signal candle for immediate invalidation
[*]Trailing Stop — Tracks extreme price movement and trails by ATR × multiplier, activating after a minimum number of bars to avoid premature exits
[*]Reversal Candle — Exits on an opposing engulfing candle once the trade is in motion
[*]Timeout — Hard exit after a maximum number of bars
[*]Trend Flip — Exits if CISD confirms a full trend reversal against the position
[/list]

[b]Visual Elements[/b]
[list]
[*]Dashed lines marking swept pivot levels
[*]Solid CISD level lines from origin to signal bar
[*]Dotted stop loss projection lines
[*]Dynamic trailing stop plotted as a step line
[*]Bar coloring active while a signal is live
[*]▲ / ▼ signal labels on the chart
[/list]

[b]Key Settings[/b]
ParameterDescriptionPivot Detection LengthSensitivity of pivot high/low detectionMax Pivot EdgeMaximum bar distance for a valid sweepPatienceMax bars between sweep and CISD for signal confirmationTrend Noise FilterTolerance ratio to filter weak CISD movesTrailing Stop MultiplierATR multiplier controlling trailing stop tightnessMin Bars Before TrailingGrace period before trailing stop activates.

## Source Code

````pine
// © FloAlgo

//@version=6
indicator("SFP", "Flo Algo - Swing Failure Pattern", overlay = true)

// ━━━ Inputs ━━━
len         = input.int(12, "Pivot Detection Length", group = "Calculations")
len_        = input.int(50, "Max Pivot Point Edge", group = "Calculations")
patience    = input.int(7, "Patience", group = "Calculations")
tolerence   = input.float(0.7, "Trend Noise Filter", group = "Calculations")

// ──── Exit Logic ────
max_bars        = input.int(30, "Max Coloring Bars", minval = 2, maxval = 100, group = "Exit Logic")
atr_len         = input.int(14, "ATR Length", group = "Exit Logic")
trail_mult      = input.float(1.5, "Trailing Stop ATR Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, tooltip = "Trailing stop = extreme price ± ATR × multiplier. Semakin kecil = semakin cepat exit.", group = "Exit Logic")
use_reversal    = input.bool(true, "Exit on Reversal Candle", tooltip = "Exit jika muncul candle engulfing berlawanan arah setelah harga sudah bergerak in-profit", group = "Exit Logic")
min_profit_bars = input.int(2, "Min Bars Before Trailing Active", minval = 1, maxval = 10, tooltip = "Trailing stop baru aktif setelah N bar dari sinyal (hindari exit prematur)", group = "Exit Logic")

bullCol  = input.color(#00ffbb, title = "Bullish Colour", group = "Appearance")
bearCol  = input.color(#ff1100, title = "Bearish Colour", group = "Appearance")
show_sl  = input.bool(true, "Show Stop Levels", group = "Appearance")

// ━━━ ATR ━━━
atr_val = ta.atr(atr_len)

// ━━━ Pivot Calculation ━━━
pivh = ta.pivothigh(len, len)
pivl = ta.pivotlow(len, len)

// ━━━ Arrays ━━━
var pivhs       = array.new_float()
var pivls       = array.new_float()
var temp_bull   = array.new_float()
var temp_bear   = array.new_float()

// ━━━ State ━━━
var int   bar_sweep_bull = 0
var int   bar_sweep_bear = 0
var float cisd_level     = na
var int   cisd_idx       = na

bullsfp = false
bearsfp = false

// ━━━ Array Population ━━━
if not na(pivh)
    pivhs.unshift(pivh)
    pivhs.unshift(bar_index)
if not na(pivl)
    pivls.unshift(pivl)
    pivls.unshift(bar_index)

while pivhs.size() > 100
    pivhs.pop()
    pivhs.pop()
while pivls.size() > 100
    pivls.pop()
    pivls.pop()
while temp_bull.size() > 3
    temp_bull.pop()
while temp_bear.size() > 3
    temp_bear.pop()

// ━━━ Sweep Detection (Bearish) ━━━
if pivhs.size() > 1
    lvl = 0.0
    var to_rm = array.new_int()
    to_rm.clear()
    for i = pivhs.size() - 1 to 1 by 2
        if i < pivhs.size()
            pp = pivhs.get(i)
            pi = pivhs.get(i - 1)
            if high > pp
                if bar_index - pi < len_
                    if pp > lvl
                        lvl := pp
                    temp_bear.unshift(bar_index)
                    temp_bear.unshift(pp)
                    temp_bear.unshift(pi)
                to_rm.push(i)
    if to_rm.size() > 0
        to_rm.sort(order.descending)
        for j = 0 to to_rm.size() - 1
            ri = to_rm.get(j)
            if ri < pivhs.size() and ri - 1 >= 0
                pivhs.remove(ri)
                pivhs.remove(ri - 1)
    if lvl != 0.0
        bar_sweep_bear := bar_index

// ━━━ Sweep Detection (Bullish) ━━━
if pivls.size() > 1
    lvl = 0.0
    var to_rm2 = array.new_int()
    to_rm2.clear()
    for i = pivls.size() - 1 to 1 by 2
        if i < pivls.size()
            pp = pivls.get(i)
            pi = pivls.get(i - 1)
            if low < pp
                if bar_index - pi < len_
                    if pp < lvl or lvl == 0
                        lvl := pp
                    temp_bull.unshift(bar_index)
                    temp_bull.unshift(pp)
                    temp_bull.unshift(pi)
                to_rm2.push(i)
    if to_rm2.size() > 0
        to_rm2.sort(order.descending)
        for j = 0 to to_rm2.size() - 1
            ri = to_rm2.get(j)
            if ri < pivls.size() and ri - 1 >= 0
                pivls.remove(ri)
                pivls.remove(ri - 1)
    if lvl != 0.0
        bar_sweep_bull := bar_index

// ━━━ CISD Logic ━━━
var bear_potential = array.new_float()
var bull_potential = array.new_float()

if close[1] < open[1] and close > open
    bear_potential.unshift(bar_index)
    bear_potential.unshift(open)
if close[1] > open[1] and close < open
    bull_potential.unshift(bar_index)
    bull_potential.unshift(open)

while bear_potential.size() > 20
    bear_potential.pop()
    bear_potential.pop()
while bull_potential.size() > 20
    bull_potential.pop()
    bull_potential.pop()

cisd = 0
max_lb = math.min(bar_index, 500)

if bear_potential.size() > 0
    inloop = true
    while inloop and bear_potential.size() > 0
        p_idx = bear_potential.get(1)
        p_val = bear_potential.first()
        if close < p_val
            highest = 0.0
            len_check = bar_index - int(p_idx)
            if len_check >= 0 and len_check < max_lb
                for i = 0 to len_check
                    if close[i] > highest
                        highest := close[i]
                running = true
                init = len_check + 1
                top = 0.0
                while running and init < max_lb
                    if close[init] < open[init]
                        top := open[init]
                        init += 1
                    else
                        running := false
                denom = top - p_val
                if denom != 0 and (highest - p_val) / denom > tolerence
                    cisd_level := p_val
                    cisd_idx := int(p_idx)
                    bear_potential.clear()
                    cisd := 1
                    inloop := false
                else
                    bear_potential.shift()
                    bear_potential.shift()
            else
                bear_potential.shift()
                bear_potential.shift()
        else
            inloop := false

if bull_potential.size() > 0
    inloop = true
    while inloop and bull_potential.size() > 0
        p_idx = bull_potential.get(1)
        p_val = bull_potential.first()
        if close > p_val
            lowest = close
            len_check = bar_index - int(p_idx)
            if len_check >= 0 and len_check < max_lb
                for i = 0 to len_check
                    if close[i] < lowest
                        lowest := close[i]
                running = true
                init = len_check + 1
                bottom = 0.0
                while running and init < max_lb
                    if close[init] > open[init]
                        bottom := open[init]
                        init += 1
                    else
                        running := false
                denom = p_val - bottom
                if denom != 0 and (p_val - lowest) / denom > tolerence
                    cisd_level := p_val
                    cisd_idx := int(p_idx)
                    bull_potential.clear()
                    cisd := 2
                    inloop := false
                else
                    bull_potential.shift()
                    bull_potential.shift()
            else
                bull_potential.shift()
                bull_potential.shift()
        else
            inloop := false

// ━━━ Signal Generation ━━━
var trend = 0
trend := cisd == 1 ? -1 : cisd == 2 ? 1 : trend

if ta.crossover(trend, 0) and (bar_index - bar_sweep_bull < patience)
    bullsfp := true
if ta.crossunder(trend, 0) and (bar_index - bar_sweep_bear < patience)
    bearsfp := true

// ━━━ Bar Coloring — Trailing Stop + Reversal Detection ━━━
var int   color_state     = 0
var int   color_start_bar = 0
var float initial_sl      = na
var float extreme_price   = na
var float trail_stop      = na

bull_engulf = close > open and close > open[1] and open < close[1] and (close - open) > (open[1] - close[1]) * 0.5
bear_engulf = close < open and close < open[1] and open > close[1] and (open - close) > (close[1] - open[1]) * 0.5

if color_state == 1
    if high > extreme_price or na(extreme_price)
        extreme_price := high
        trail_stop    := extreme_price - atr_val * trail_mult

if color_state == -1
    if low < extreme_price or na(extreme_price)
        extreme_price := low
        trail_stop    := extreme_price + atr_val * trail_mult

if color_state != 0
    bars_since  = bar_index - color_start_bar
    should_exit = false

    if color_state == 1 and not na(initial_sl) and close < initial_sl
        should_exit := true
    if color_state == -1 and not na(initial_sl) and close > initial_sl
        should_exit := true

    if bars_since >= min_profit_bars and not na(trail_stop)
        if color_state == 1 and close < trail_stop
            should_exit := true
        if color_state == -1 and close > trail_stop
            should_exit := true

    if use_reversal and bars_since >= min_profit_bars
        if color_state == 1 and bear_engulf
            should_exit := true
        if color_state == -1 and bull_engulf
            should_exit := true

    if bars_since >= max_bars
        should_exit := true

    if color_state == 1 and trend == -1
        should_exit := true
    if color_state == -1 and trend == 1
        should_exit := true

    if should_exit
        color_state   := 0
        initial_sl    := na
        extreme_price := na
        trail_stop    := na

if bullsfp
    color_state     := 1
    color_start_bar := bar_index
    initial_sl      := low
    extreme_price   := high
    trail_stop      := high - atr_val * trail_mult

if bearsfp
    color_state     := -1
    color_start_bar := bar_index
    initial_sl      := high
    extreme_price   := low
    trail_stop      := low + atr_val * trail_mult

// ━━━ Drawing ━━━
if bullsfp
    if temp_bull.size() >= 3
        lx = int(temp_bull.get(0))
        ly = temp_bull.get(1)
        ls = lx - len
        le = int(temp_bull.get(2))
        line.new(ls, ly, le, ly, color = bullCol, width = 1, style = line.style_dashed)
        label.new(int((ls + le) / 2), ly, text = "$", color = color.new(bullCol, 100), textcolor = bullCol, style = label.style_label_up)
    if not na(cisd_idx)
        line.new(cisd_idx, cisd_level, bar_index, cisd_level, color = bullCol, width = 1, style = line.style_solid)
    if show_sl
        line.new(bar_index, low, bar_index + max_bars, low, color = color.new(bearCol, 40), width = 1, style = line.style_dotted)
        label.new(bar_index + 1, low, text = "SL", color = color.new(bearCol, 80), textcolor = bearCol, style = label.style_label_down, size = size.tiny)

if bearsfp
    if temp_bear.size() >= 3
        lx = int(temp_bear.get(0))
        ly = temp_bear.get(1)
        ls = lx - len
        le = int(temp_bear.get(2))
        line.new(ls, ly, le, ly, color = bearCol, width = 1, style = line.style_dashed)
        label.new(int((ls + le) / 2), ly, text = "$", color = color.new(bearCol, 100), textcolor = bearCol, style = label.style_label_down)
    if not na(cisd_idx)
        line.new(cisd_idx, cisd_level, bar_index, cisd_level, color = bearCol, width = 1, style = line.style_solid)
    if show_sl
        line.new(bar_index, high, bar_index + max_bars, high, color = color.new(bullCol, 40), width = 1, style = line.style_dotted)
        label.new(bar_index + 1, high, text = "SL", color = color.new(bullCol, 80), textcolor = bullCol, style = label.style_label_up, size = size.tiny)

// ━━━ Dynamic Trailing Stop Visualization ━━━
plot(color_state == 1 and not na(trail_stop) ? trail_stop : na, "Bull Trail", color.new(bullCol, 60), 1, plot.style_stepline_diamond)
plot(color_state == -1 and not na(trail_stop) ? trail_stop : na, "Bear Trail", color.new(bearCol, 60), 1, plot.style_stepline_diamond)

// ━━━ Bar Color & Signals ━━━
barcolor(color_state == 1 ? bullCol : color_state == -1 ? bearCol : na)
plotshape(bullsfp ? low : na, "Bullish Signal", shape.labelup, location.absolute, bullCol, size = size.small, text = "▲", textcolor = chart.fg_color)
plotshape(bearsfp ? high : na, "Bearish Signal", shape.labeldown, location.absolute, bearCol, size = size.small, text = "▼", textcolor = chart.fg_color)

// ━━━ Alerts ━━━
alertcondition(bullsfp, title = "Bullish SFP", message = "Bullish Swing Failure Pattern Detected")
alertcondition(bearsfp, title = "Bearish SFP", message = "Bearish Swing Failure Pattern Detected")
alertcondition(color_state[1] != 0 and color_state == 0, title = "Coloring Exit", message = "Bar coloring ended — check position")
````
