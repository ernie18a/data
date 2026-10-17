# Equilibrium Momentum Shift + Divegence [BigBeluga]

- url: https://www.tradingview.com/script/467SFOco-Equilibrium-Momentum-Shift-Divegence-BigBeluga/
- type: indicator
- pine_id: PUB;bed8df2b25a94129988a5d2d1c8a7e65
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]  
[b]Equilibrium Momentum Shift [BigBeluga][/b] is a range-based momentum oscillator designed to measure how far price has deviated from its current equilibrium.  
Instead of focusing purely on trend direction or overbought/oversold conditions, this indicator evaluates price relative to the midpoint of its recent range and quantifies the strength of the shift away from that balance.

By combining normalized range deviation, smoothing techniques, and nonlinear compression, the indicator provides a clear view of when markets transition from equilibrium into directional momentum, now featuring [b]Normal Divergence[/b] detection to spot potential trend reversals.


[b]🔵 CONCEPT[/b]  
[list]
[*][b]Equilibrium Midpoint[/b] — The midpoint between the highest high and lowest low over the selected range length represents the equilibrium price.
[*][b]Deviation Measurement[/b] — The indicator measures how far the current price has moved away from this midpoint.
[*][b]Range Normalization[/b] — Deviations are normalized relative to the size of the current range, allowing the oscillator to remain consistent across different volatility conditions.
[*][b]Momentum Compression[/b] — A hyperbolic tangent function compresses extreme values, stabilizing the oscillator and preventing runaway signals during large trends.
[*][b]Divergence Identification[/b] — Automatically identifies discrepancies between price action and the oscillator to highlight weakening momentum in established trends.
[/list]


[b]🔵 HOW IT WORKS[/b]
[b]1️⃣ Equilibrium Range Calculation[/b]  
[list]
[*] The indicator calculates the highest high and lowest low over the user-defined range length.
[*] The midpoint between these two levels forms the equilibrium line.
[*] This midline represents the center of balance for recent price activity.
[image]https://www.tradingview.com/x/fyuDLn0e/[/image]
[/list]

[b]2️⃣ Price Deviation Measurement[/b]  
[list]
[*] The distance between the current close and the equilibrium midpoint is calculated.
[*] This deviation is then smoothed using a double EMA structure to reduce noise.
[*] The smoothed value is normalized relative to half of the current range size.
[image]https://www.tradingview.com/x/jh1KiOoj/[/image]
[/list]

[b]3️⃣ Nonlinear Oscillator Transformation[/b]  
[list]
[*] A hyperbolic tangent function compresses normalized deviations into a stable range between -1 and +1.
[*] This transformation prevents extreme outliers and creates a more interpretable oscillator.
[image]https://www.tradingview.com/x/l7QJGtGa/[/image]
[/list]

[b]4️⃣ Momentum Histogram[/b]  
[list]
[*] A signal line is generated using EMA smoothing.
[*] The difference between the oscillator and the signal line forms a histogram.
[*] The histogram behaves similarly to a MACD-style momentum indicator:
    [list]
    [*] Expanding bars indicate strengthening momentum.
    [*] Contracting bars indicate weakening momentum.
    [/list]
[image]https://www.tradingview.com/x/YEclMMVo/[/image]
[/list]

[b]5️⃣ Normal Divergence Logic[/b]
[list]
[*] [b]Bullish Divergence:[/b] Occurs when price makes a [b]Lower Low[/b], but the Equilibrium Oscillator makes a [b]Higher Low[/b]. This suggests that despite the price drop, the selling pressure relative to equilibrium is fading.
[*] [b]Bearish Divergence:[/b] Occurs when price makes a [b]Higher High[/b], but the Equilibrium Oscillator makes a [b]Lower High[/b]. This indicates that the buyers' ability to push price away from the midpoint is losing strength.
[image]https://www.tradingview.com/x/LdmHwh05/[/image]
[/list]


[b]🔵 KEY FEATURES[/b]  
[list]
[*] Equilibrium midpoint plotted directly on the chart.
[*] Range-normalized momentum oscillator.
[*] Hyperbolic tangent compression to stabilize signals.
[*] MACD-style histogram for momentum acceleration detection.
[*] [b]Automatic Normal Divergence[/b] labels to spot exhaustion.
[*] Gradient-colored oscillator line reflecting directional bias.
[*] Dashboard displaying real-time momentum metrics.
[/list]


[b]🔵 DASHBOARD METRICS[/b]  
[list]
[*][b]Shift[/b] — Current oscillator value showing how far price has moved from equilibrium.
[image]https://www.tradingview.com/x/8CofMCVo/[/image]
[*][b]State[/b] — Market regime derived from oscillator thresholds:
    [list]
    [*] Bullish
    [*] Bearish
    [*] Neutral
    [/list]
[image]https://www.tradingview.com/x/YPO80IXi/[/image]
[*][b]Range Position[/b] — Location of price inside the current range expressed as a percentage.
[image]https://www.tradingview.com/x/woYA5sNk/[/image]
[*][b]Pressure[/b] — Magnitude of momentum deviation from equilibrium.
[image]https://www.tradingview.com/x/HFlMwqEh/[/image]
[/list]


[b]🔵 HOW TO USE[/b]  
[list]
[*] Use the equilibrium midline as a dynamic balance reference.
[*] When the oscillator moves above zero, bullish momentum dominates.
[*] When the oscillator moves below zero, bearish momentum dominates.
[*] [b]Trading Divergences:[/b] Watch for divergence labels when price is at historical range extremes. A bullish divergence near the "Lowest Low" of the range suggests a high-probability mean-reversion trade back toward equilibrium.
[*] Histogram expansions highlight momentum acceleration.
[*] Histogram contraction can signal potential momentum exhaustion.
[/list]


[b]🔵 INTERPRETING MOMENTUM SHIFTS[/b]  
[list]
[*] Oscillator near zero → Market is balanced around equilibrium.
[*] Oscillator above 0.2 → Bullish momentum phase.
[*] Oscillator below -0.2 → Bearish momentum phase.
[*] [b]Divergence Label + Oscillator Flatline[/b] → High probability of a trend reversal or deep pullback.
[*] Rapid oscillator expansion → Strong directional pressure.
[*] Oscillator flattening → Momentum compression or consolidation.
[/list]


[b]🔵 CONCLUSION[/b]  
[b]Equilibrium Momentum Shift [BigBeluga][/b] offers a structured way to analyze how price behaves relative to its recent balance point.

By measuring normalized deviations from equilibrium and visualizing momentum shifts with a smoothed oscillator, histogram, and [b]integrated divergence analysis[/b], the indicator helps traders identify when markets transition from balance into directional movement.

This makes it especially useful for spotting early momentum expansions, trend continuation signals, and potential exhaustion points where price is likely to snap back to its equilibrium midpoint.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Equilibrium Momentum Shift + Divegence [BigBeluga]", shorttitle="EMS + Divegence Lines [BigBeluga]", overlay=false)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

length = input.int(50, "Range Length")
oscSmoothLen = input.int(9, "Oscillator Smoothing", minval = 1)

bullColor = input.color(color.rgb(0, 172, 154), "Bullish Momentum Color")
bearColor = input.color(color.rgb(253, 34, 34), "Bearish Momentum Color")

// Divergence Inputs
showDiv     = input.bool(true, "Show Divergences", group="Divergence Settings")
showLines   = input.bool(true, "Show Divergence Lines", group="Divergence Settings")
divLookback = input.int(5, "Pivot Lookback", group="Divergence Settings")
bullDivCol  = input.color(color.rgb(0, 172, 154), "Bullish Div Color", group="Divergence Settings")
bearDivCol  = input.color(color.rgb(253, 34, 34), "Bearish Div Color", group="Divergence Settings")

// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

rangeHigh = ta.highest(length)
rangeLow  = ta.lowest(length)

midline = math.avg(rangeHigh, rangeLow)
diff = close - midline

ema1 = ta.ema(diff, 10)
ema2 = ta.ema(ema1, 10)
smooth = 2 * ema1 - ema2

rangeSize = rangeHigh - rangeLow
normDiff = rangeSize != 0 ? smooth / (rangeSize / 2) : 0

tanh(x) =>
    ex  = math.exp(x)
    enx = math.exp(-x)
    (ex - enx) / (ex + enx)

osc = tanh(normDiff)
oscSmooth = ta.ema(osc, oscSmoothLen)

// MACD-style histogram
hist = osc - oscSmooth
histColor = hist >= 0 ? (hist > hist[1] ? color.new(bullColor, 30) : color.new(bullColor, 60)) : (hist < hist[1] ? color.new(bearColor, 30) : color.new(bearColor, 60))
oscColor = color.from_gradient(osc, -0.2, 0.2, bearColor, bullColor)

// Dashboard calculations
rangePos = rangeSize != 0 ? (close - rangeLow) / rangeSize : 0
pressure = math.abs(osc)
state = osc > 0.2 ? "Bullish" : osc < -0.2 ? "Bearish" : "Neutral"
stateCol = osc > 0.2 ? bullColor : osc < -0.2 ? bearColor : color.gray

// --- Divergence Logic with Lines ---
var float top_osc = na
var float bot_osc = na
var float top_prc = na
var float bot_prc = na
var int top_idx = na
var int bot_idx = na

ph = ta.pivothigh(osc, divLookback, divLookback)
pl = ta.pivotlow(osc, divLookback, divLookback)

// Regular Bullish
bullDiv = false
if not na(pl)
    if pl > bot_osc and low[divLookback] < bot_prc
        bullDiv := true
        if showLines
            line.new(bot_idx, bot_osc, bar_index - divLookback, pl, color=bullDivCol, width=2)

    bot_osc := pl
    bot_prc := low[divLookback]
    bot_idx := bar_index - divLookback

// Regular Bearish
bearDiv = false
if not na(ph)
    if ph < top_osc and high[divLookback] > top_prc
        bearDiv := true
        if showLines
            line.new(top_idx, top_osc, bar_index - divLookback, ph, color=bearDivCol, width=2)

    top_osc := ph
    top_prc := high[divLookback]
    top_idx := bar_index - divLookback

// }


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

plot(midline, title = "Equilibrium Midline", force_overlay = true, color = chart.fg_color)
plot(oscSmooth, title = "Oscillator Signal", color = color.gray, linewidth = 1)
plot(hist, title="Momentum Histogram", style=plot.style_columns, color=histColor)
oscPlot = plot(osc, title = "Momentum Line", color = oscColor)
midPlot = plot(0, title = "Zero Line", display = display.none, editable = false)

fill(oscPlot, midPlot, 0.8, 0.2, bullColor, color.new(color.black, 100))
fill(oscPlot, midPlot, -0.2, -0.8, color.new(color.black, 100), bearColor)
hline(0, "Zero Line")

// Labels
plotshape(showDiv and bullDiv ? osc[divLookback] : na, "Bullish Divergence", shape.labelup, location.absolute, bullDivCol, -divLookback, "BULL", color.white, size=size.tiny)
plotshape(showDiv and bearDiv ? osc[divLookback] : na, "Bearish Divergence", shape.labeldown, location.absolute, bearDivCol, -divLookback, "BEAR", color.white, size=size.tiny)

// Dashboard and Labels
var table dash = table.new(position.bottom_right, 2, 4, border_width = 1, force_overlay = true)
if barstate.islast
    table.cell(dash, 0, 0, "Shift", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dash, 1, 0, (osc > 0 ? "+" : "") + str.tostring(osc, "#.##"), text_color = osc > 0 ? bullColor : bearColor, text_halign = text.align_center)
    table.cell(dash, 0, 1, "State", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dash, 1, 1, state, text_color = stateCol, text_halign = text.align_center)
    table.cell(dash, 0, 2, "Range Pos", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(rangePos * 100, "#") + "%", text_color = chart.fg_color, text_halign = text.align_center)
    table.cell(dash, 0, 3, "Pressure", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dash, 1, 3, (osc > 0 ? "+" : "-") + str.tostring(pressure * 100, "#") + "%", text_color = osc > 0 ? bullColor : bearColor, text_halign = text.align_center)

    label.delete(label.new(bar_index, midline, "◀ Equilibrium: " + str.tostring(midline), color = color.new(color.black, 100), textcolor = chart.fg_color, force_overlay = true, style = label.style_label_left)[1])
    label.delete(label.new(bar_index, osc, "◀ " + str.tostring(osc, "#.##"), color = color.new(color.black, 100), textcolor = chart.fg_color, force_overlay = false, style = label.style_label_left)[1])
// }
````
