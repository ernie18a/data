# Volumetric Trend Ribbon Pro [ChartPrime]

- url: https://www.tradingview.com/script/sXyMhOCc-Volumetric-Trend-Ribbon-Pro-ChartPrime/
- type: indicator
- pine_id: PUB;dc1e4b0e471e4c128ff0fc8456640720
- version: 1.0

## Description

[b]🔶 OVERVIEW[/b]  
[b]Volumetric Trend Ribbon Pro [ChartPrime][/b] is a professional-grade trend-following overlay that synchronizes price action with volume-weighted volatility. Unlike standard moving averages that only track price, this indicator uses a Volume-Weighted Standard Deviation (VWSD) engine to create a dynamic "ribbon" that expands during high-conviction moves and contracts during market indecision.

The tool is designed to provide a comprehensive workspace for trend traders, featuring automated breakout targets, institutional volume spike detection, and a real-time analytics dashboard.

• Volume-Weighted Moving Average (VWMA) Core  
• [b]NEW:[/b] Adaptive Transparency (Volume-to-Average Ratio)  
• [b]NEW:[/b] Dynamic Breakout Targets (Volatility-Adjusted)  
• Institutional Volume Spike Highlighting (Orange Candles)  
• Floating "Trend & Longevity" Labels  
• Integrated Status Dashboard (Trend Age & Vol Intensity)  
• Customizable Themed Candle Plotting  


[b]🔶 CORE CONCEPT — VOLUMETRIC ADAPTABILITY[/b]  
Standard ribbons often suffer from "lag" or "noise" during low-volume consolidation. VTR Pro solves this by integrating volume into every calculation:
• [b]VWSD Expansion:[/b] The ribbon’s width is determined by volume-weighted volatility. When "Smart Money" enters the market, the ribbon widens, providing a clear visual of trend strength.
• [b]Adaptive Transparency:[/b] The indicator’s visibility reacts to current volume. High-volume moves appear bold and opaque, while low-volume "chop" fades into the background, signaling a lack of institutional interest.
• [b]Volume Spikes:[/b] Regardless of the current trend, the script identifies abnormal volume surges (1.5x average) and highlights the candles in [b]Orange[/b], marking potential exhaustion or ignition points.


[b]🔶 DYNAMIC BREAKOUT TARGETS[/b]  
The indicator features an automated target projection system that appears when price breaks out of the ribbon with high momentum.
[list]
[*] [b]Volatility-Based:[/b] Targets are not fixed percentages; they are calculated based on the current width of the ribbon (the market's recent volatility).
[*] [b]Adjustable Multiplier:[/b] Traders can fine-tune the "Target Distance" input to match their specific strategy (Scalping vs. Swing Trading).
[*] [b]Auto-Hide Logic:[/b] Target lines automatically clear once the trend weakens or the level is mitigated, keeping the chart clean and focused.
[/list]


[b]🔶 TREND DASHBOARD & FLOATING LABELS[/b]  
To provide institutional-level data at a glance, VTR Pro includes two intelligent UI elements:
[list]
[*] [b]Floating Trend Label:[/b] Plotted directly at the end of the middle trend line, this label tracks the current "Longevity" of the move (number of bars in trend), allowing you to identify over-extended trends.
[*] [b]Status Dashboard:[/b] A top-right table that monitors:
- [b]Trend Status:[/b] (Bullish / Bearish / Neutral)
- [b]Trend Age:[/b] The exact duration of the current cycle.
- [b]Vol Intensity:[/b] A real-time multiplier showing how much volume is flowing relative to the 40-bar average.
[/list]


[b]🔶 HOW TO USE[/b]  
[list]
[*] [b]Trend Confirmation:[/b] Enter long when the ribbon turns Green and price holds above the upper edge. Confirm with a "Strong" momentum signal.
[*] [b]Spotting Exhaustion:[/b] Watch the [b]Trend Age[/b] on the dashboard. If a trend has lasted 50+ bars without a contraction, look for [b]Orange Volume Spikes[/b] as potential signs of blow-off tops or bottoms.
[*] [b]Managing Targets:[/b] Use the projected Target Lines as logical take-profit levels or areas to move your stop-loss to break-even.
[*] [b]Avoiding Chop:[/b] When the ribbon turns Blue (Neutral) and the transparency fades, the market is in equilibrium. This is a "No-Trade Zone" for trend followers.
[/list]


[b]🔶 CONCLUSION[/b]  
[b]Volumetric Trend Ribbon Pro [ChartPrime][/b] transforms the traditional ribbon into a data-rich environment. By prioritizing volume intensity and providing automated targets, it removes the guesswork from trend-following and helps traders stay on the right side of institutional flow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=6
indicator("Volumetric Trend Ribbon Pro [ChartPrime]", "VTR Pro [ChartPrime]", overlay = true)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

groupTrend = "Trend Settings"
lengthInput = input.int(30, "Lookback Length", minval = 1, group = groupTrend, tooltip = "The number of bars used to calculate the core trend and volume-weighted volatility. Higher values result in a smoother, slower-reacting ribbon.")
srcInput    = input.source(close, "Source", group = groupTrend, tooltip = "The price source used for all calculations. Typically 'close' is used for trend following.")
smoothInput = input.int(5, "Smoothing", minval = 1, group = groupTrend, tooltip = "Applies an EMA smoothing to the base trend line to filter out minor price fluctuations.")

groupVisual = "Visual Settings"
multInput      = input.float(2.0, "Ribbon Width Multiplier", minval = 0.1, step = 0.1, group = groupVisual, tooltip = "Controls the expansion of the ribbon based on volume-weighted standard deviation. Higher values create a wider ribbon.")
bullColorInput = input.color(#089981, "Bullish Color", group = groupVisual, inline = "color", tooltip = "The color used for the ribbon and labels during a bullish trend.")
bearColorInput = input.color(#f23645, "Bearish Color", group = groupVisual, inline = "color", tooltip = "The color used for the ribbon and labels during a bearish trend.")
neutColorInput = input.color(#5b9cf6, "Neutral Color", group = groupVisual, inline = "color", tooltip = "The color used when the market is in a neutral or consolidation phase.")
showBarColor   = input.bool(true, "Enable Bar Coloring", group = groupVisual, tooltip = "When enabled, candles are colored based on the current trend or volume spikes.")
useCustomCandles = input.bool(false, "Plot Custom Candles", group = groupVisual, tooltip = "Plots themed candles directly on the chart. For the best look, hide the default chart candles in your chart settings (Right click chart -> Settings -> Symbol -> Uncheck 'Body', 'Borders', 'Wick').")

groupExtra = "Extra Features"
showDashboard   = input.bool(true, "Show Trend Dashboard", group = groupExtra, tooltip = "Displays a table in the top-right corner with trend status, age, and volume intensity.")
showTargets     = input.bool(true, "Show Breakout Targets", group = groupExtra, tooltip = "Plots a target level when a strong momentum breakout occurs.")
targetMultInput = input.float(1.5, "Target Distance Multiplier", minval = 0.1, step = 0.1, group = groupExtra, tooltip = "Controls the distance of the breakout target. It is multiplied by the current width of the ribbon.")

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

// Volume-Weighted Moving Average (Base Trend)
baseTrend = ta.vwma(srcInput, lengthInput)
smoothedBase = ta.ema(baseTrend, smoothInput)

// Volume-Weighted Standard Deviation (VWSD)
vwsd = math.sqrt(ta.vwma(math.pow(srcInput - smoothedBase, 2), lengthInput))

// Ribbon Boundaries
upper = smoothedBase + (vwsd * multInput)
lower = smoothedBase - (vwsd * multInput)

// Trend & Volume Logic
volRatio     = volume / ta.sma(volume, lengthInput * 2)
isVolSpike   = volRatio > 1.5
isUpTrend    = smoothedBase > smoothedBase[1] and close > smoothedBase
isDnTrend    = smoothedBase < smoothedBase[1] and close < smoothedBase

// Conviction state for coloring
int trendState = isUpTrend ? 1 : isDnTrend ? -1 : 0
color ribbonColor = trendState == 1 ? bullColorInput : trendState == -1 ? bearColorInput : color.new(chart.bg_color, 100)

// Trend Age Calculation
var int trendAge = 0
trendAge := (trendState == trendState[1] and trendState != 0) ? trendAge + 1 : 0

// Dynamic Transparency
int dynamicTransp = math.min(95, math.max(50, int(90 - (volRatio * 20))))

// --- Breakout Logic & Targets ---
bool bullCross = ta.crossover(close, upper) and isUpTrend
bool bearCross = ta.crossunder(close, lower) and isDnTrend

// Calculate Target levels on breakout (Dynamic based on input multiplier)
var float targetPrice = na
float ribbonWidth = upper - lower
if bullCross
    targetPrice := upper + ribbonWidth * targetMultInput
else if bearCross
    targetPrice := lower - ribbonWidth * targetMultInput
else if (trendState == 1 and high > targetPrice) or (trendState == -1 and low < targetPrice) or trendState == 0
    targetPrice := na

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{

// Plotting the lines
pUpper = plot(upper, "Upper Ribbon", ribbonColor)
pBase  = plot(smoothedBase, "Base Trend", color.new(ribbonColor, dynamicTransp), linewidth = 2)
pLower = plot(lower, "Lower Ribbon", ribbonColor)

// Applying the gradient fill
fill(pBase, pUpper, upper, smoothedBase, color.new(ribbonColor, dynamicTransp), color.new(ribbonColor, 100), "Upper Fill")
fill(pBase, pLower, smoothedBase, lower, color.new(ribbonColor, 100), color.new(ribbonColor, dynamicTransp), "Lower Fill")

// Final Candle Logic
color mainCandleColor = isVolSpike ? color.orange : (trendState == 0 ? neutColorInput : ribbonColor)

// Standard Bar Coloring (if Custom Candles are disabled)
barcolor(showBarColor and not useCustomCandles ? color.new(mainCandleColor, 30) : na)

// Custom Candle Plotting
plotcandle(useCustomCandles ? open : na, useCustomCandles ? high : na, useCustomCandles ? low : na, useCustomCandles ? close : na, "Custom Candles", color = color.new(mainCandleColor, 20), wickcolor = mainCandleColor, bordercolor = mainCandleColor)

// Targets
plot(showTargets and not (targetPrice != targetPrice[1]) ? targetPrice : na, "Breakout Target", ribbonColor, 2, plot.style_linebr)

// Momentum Signals
plotshape(bullCross, "Bullish Momentum", shape.triangleup, location.belowbar, color.new(bullColorInput, 0), size = size.tiny, text = "Strong", textcolor = chart.fg_color)
plotshape(bearCross, "Bearish Momentum", shape.triangledown, location.abovebar, color.new(bearColorInput, 0), size = size.tiny, text = "Strong", textcolor = chart.fg_color)

// --- Floating Trend Label ---
var label trendLabel = label.new(na, na, "", xloc.bar_index, yloc.price, #00000000, label.style_label_left, chart.fg_color, size.small)
if barstate.islast
    string dirStr = trendState == 1 ? "Bullish" : trendState == -1 ? "Bearish" : "Neutral"
    label.set_xy(trendLabel, bar_index + 2, smoothedBase)
    label.set_text(trendLabel, "Trend: " + dirStr + "\nLongevity: " + str.tostring(trendAge) + " bars")
    label.set_textcolor(trendLabel, trendState == 0 ? neutColorInput : ribbonColor)

// --- Dashboard Table ---
var table trendTable = table.new(position.top_right, 2, 3, bgcolor = chart.bg_color, border_color = chart.fg_color, border_width = 1)
if showDashboard and barstate.islast
    string statusText = trendState == 1 ? "BULLISH" : trendState == -1 ? "BEARISH" : "NEUTRAL"
    color  statusColor = trendState == 1 ? bullColorInput : trendState == -1 ? bearColorInput : neutColorInput
    
    table.cell(trendTable, 0, 0, "Trend Status", text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 0, statusText, text_color = statusColor, text_size = size.small)
    
    table.cell(trendTable, 0, 1, "Trend Age", text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 1, str.tostring(trendAge) + " Bars", text_color = chart.fg_color, text_size = size.small)
    
    table.cell(trendTable, 0, 2, "Volume Intensity", text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 2, str.tostring(math.round(volRatio, 2)) + "x", text_color = volRatio > 1.2 ? bullColorInput : chart.fg_color, text_size = size.small)

// --------------------------------------------------------------------------------------------------------------------}
````
