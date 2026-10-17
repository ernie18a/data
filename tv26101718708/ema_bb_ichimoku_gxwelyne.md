# EMA & BB & Ichimoku

- url: https://www.tradingview.com/script/gXWElYNE/
- type: indicator
- pine_id: PUB;d547be07b1844b99ab7da53d6fe04fe3
- version: 1.0

## Description

Key Features:

Long-Term Trend Channel: A 100-period EMA High/Low channel that defines the "value area" and primary trend direction.

Dual-Layer Bollinger Clouds: Two sets of Bollinger Bands (20 and 30 length) create a visual "volatility cloud," highlighting squeeze zones and potential breakouts.

Faded Ichimoku Kumo: A subtle, 25% opacity Ichimoku Cloud helps identify macro trend support and resistance without cluttering the chart.

Smart RSI Integration: * Visual "Point" markers on the chart for Overbought (70+) and Oversold (30-) conditions.

A dynamic, real-time RSI label that moves with price and changes color based on momentum intensity.

## Source Code

````pine
//@version=5
indicator("EMA & BB & Ichimoku", overlay=true)

// ==========================================
// 1. INPUTS
// ==========================================

// EMA Settings
grp_ema      = "EMA 100 Channel Settings"
ema_len      = input.int(100, "EMA Length", group=grp_ema)
color_high   = input.color(color.yellow, "EMA High Color", group=grp_ema)
color_low    = input.color(color.orange, "EMA Low Color", group=grp_ema)

// Bollinger Bands Settings
grp_bb       = "Bollinger Bands"
bb_len20     = input.int(20, "Inner BB Length", group=grp_bb)
bb_len30     = input.int(30, "Outer BB Length", group=grp_bb)
bb_mult      = input.float(2.0, "StdDev Multiplier", step=0.1, group=grp_bb)
color_basis  = input.color(color.white, "Basis Color", group=grp_bb)
color_bb30   = input.color(color.red, "Outer Band Color", group=grp_bb)
color_bbCloud = input.color(color.new(color.blue, 75), "BB Cloud Color", group=grp_bb)

// Ichimoku Cloud Settings
grp_ichi     = "Ichimoku Cloud"
tenkanLen    = input.int(9, "Tenkan Sen", group=grp_ichi)
kijunLen     = input.int(26, "Kijun Sen", group=grp_ichi)
senkouLen    = input.int(52, "Senkou Span B", group=grp_ichi)
displacement = input.int(26, "Offset", group=grp_ichi)
color_ichiUp = input.color(color.new(color.green, 75), "Bullish Cloud", group=grp_ichi)
color_ichiDn = input.color(color.new(color.red, 75), "Bearish Cloud", group=grp_ichi)

// RSI Settings
grp_rsi      = "RSI Settings"
rsi_len      = input.int(14, "RSI Length", group=grp_rsi)
rsi_ob       = input.int(70, "Overbought Level", group=grp_rsi)
rsi_os       = input.int(30, "Oversold Level", group=grp_rsi)
show_label   = input.bool(true, "Show Live RSI Label", group=grp_rsi)

// ==========================================
// 2. CALCULATIONS & PLOTTING
// ==========================================

// --- EMA Channel ---
plot(ta.ema(high, ema_len), title="EMA High", color=color_high, linewidth=2)
plot(ta.ema(low, ema_len), title="EMA Low", color=color_low, linewidth=2)

// --- Ichimoku Cloud ---
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))
spanA = math.avg(donchian(tenkanLen), donchian(kijunLen))
spanB = donchian(senkouLen)

p1 = plot(spanA, offset=displacement, color=color.new(color_ichiUp, 90), title="Span A", display=display.none)
p2 = plot(spanB, offset=displacement, color=color.new(color_ichiDn, 90), title="Span B", display=display.none)
fill(p1, p2, color = spanA > spanB ? color_ichiUp : color_ichiDn, title="Ichimoku Cloud")

// --- Bollinger Bands ---
basis20 = ta.sma(close, bb_len20)
upper30 = basis20 + bb_mult * ta.stdev(close, bb_len30)
lower30 = basis20 - bb_mult * ta.stdev(close, bb_len30)
upper20 = basis20 + bb_mult * ta.stdev(close, bb_len20)
lower20 = basis20 - bb_mult * ta.stdev(close, bb_len20)

// Hata Giderildi: 'plot.' yerine doğrudan stil ismi kullanıldı
plot(basis20, color=color_basis, style=plot.style_circles, linewidth=1, title="BB Basis")
p_u30 = plot(upper30, color=color_bb30, style=plot.style_circles, linewidth=1, title="BB Upper 30")
p_l30 = plot(lower30, color=color_bb30, style=plot.style_circles, linewidth=1, title="BB Lower 30")

// Cloud Filling
p_u20 = plot(upper20, display=display.none)
p_l20 = plot(lower20, display=display.none)
fill(p_u20, p_u30, color=color_bbCloud, title="BB Upper Cloud")
fill(p_l20, p_l30, color=color_bbCloud, title="BB Lower Cloud")

// --- RSI ---
rsiVal = ta.rsi(close, rsi_len)
plotshape(rsiVal >= rsi_ob, style=shape.circle, location=location.abovebar, color=color.white, size=size.tiny)
plotshape(rsiVal <= rsi_os, style=shape.circle, location=location.belowbar, color=color.white, size=size.tiny)

// --- Live RSI Label ---
if show_label
    var label rsiLabel = label.new(x=na, y=na, text="", color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.set_xy(rsiLabel, bar_index + 1, close)
    label.set_text(rsiLabel, "RSI: " + str.tostring(math.round(rsiVal, 2)))
    label.set_textcolor(rsiLabel, rsiVal >= rsi_ob ? color.red : rsiVal <= rsi_os ? color.green : color.white)
````
