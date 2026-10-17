# 5M Displacement Pullback Indicator

- url: https://www.tradingview.com/script/zaAX2IK3-5M-Displacement-Pullback-Indicator/
- type: indicator
- pine_id: PUB;c698cefc52c941b0a7d7187b3b2ce5c1
- version: 1.0

## Description

5M Displacement Pullback Indicator,
Using 5M timeframe, wait for a strong displacement candle. When that happens you will wait for pullback into 50% of the displacement and enter. Stop goes under the displacement and shoot for 2:1 R:1

## Source Code

````pine
//@version=6
indicator("5M Displacement Pullback Indicator", overlay=true)

// === INPUTS ===
body_mult = input.float(1.5, title="Displacement Body Multiplier")
show_zones = input.bool(true, title="Show 50% Zones")
show_labels = input.bool(true, title="Show Labels")

bull_col = color.new(color.green, 0)
bear_col = color.new(color.red, 0)

// === DISPLACEMENT DETECTION ===
body_size = math.abs(close - open)
avg_body = ta.sma(body_size, 20)

is_bull_disp = close > open and body_size > avg_body * body_mult
is_bear_disp = close < open and body_size > avg_body * body_mult

// === 50% LEVELS ===
bull_50 = is_bull_disp ? open + (close - open) * 0.5 : na
bear_50 = is_bear_disp ? open - (open - close) * 0.5 : na

// === STORE MOST RECENT LEVELS ===
var float last_bull_50 = na
var float last_bear_50 = na

if is_bull_disp
    last_bull_50 := bull_50

if is_bear_disp
    last_bear_50 := bear_50

// === PLOT LEVELS ===
plot(show_zones ? last_bull_50 : na, color=bull_col, linewidth=2, style=plot.style_linebr)
plot(show_zones ? last_bear_50 : na, color=bear_col, linewidth=2, style=plot.style_linebr)

// === PULLBACK CONDITIONS ===
bull_pullback = low <= last_bull_50 and close > last_bull_50
bear_pullback = high >= last_bear_50 and close < last_bear_50

// === SIGNALS ===
plotshape(is_bull_disp, title="Bull Displacement", style=shape.triangleup, location=location.belowbar, color=bull_col, size=size.small)

plotshape(is_bear_disp, title="Bear Displacement", style=shape.triangledown, location=location.abovebar, color=bear_col, size=size.small)

plotshape(bull_pullback, title="Bull Pullback Entry", style=shape.circle, location=location.belowbar, color=color.lime, size=size.small)

plotshape(bear_pullback, title="Bear Pullback Entry", style=shape.circle, location=location.abovebar, color=color.red, size=size.small)

// === LABELS ===
if show_labels and bull_pullback
    label.new(bar_index, low, "LONG", style=label.style_label_up, color=bull_col, textcolor=color.white)

if show_labels and bear_pullback
    label.new(bar_index, high, "SHORT", style=label.style_label_down, color=bear_col, textcolor=color.white)

// === ALERTS ===
alertcondition(bull_pullback, "Bullish Pullback", "Bullish displacement pullback detected")

alertcondition(bear_pullback, "Bearish Pullback", "Bearish displacement pullback detected")
````
