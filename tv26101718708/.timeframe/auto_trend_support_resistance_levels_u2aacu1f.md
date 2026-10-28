# Auto Trend Support & Resistance Levels

- url: https://www.tradingview.com/script/u2aacu1f-Auto-Trend-Support-Resistance-Levels/
- type: indicator
- pine_id: PUB;ea67ad62735e45adb576843a9a37c262
- version: 1.0

## Description

[b]Trend Following Support & Resistance [MTF][/b]

Trend Following Support & Resistance [MTF] is an advanced multi-timeframe support and resistance indicator designed for traders who want clean, dynamic, and easy-to-follow market structure levels directly on the chart.

Unlike traditional static support and resistance tools, this indicator automatically updates levels based on recent price action and highlights important breakout areas in real time.

The indicator is optimized for:
	•	Trend following traders
	•	Breakout traders
	•	Scalpers
	•	Swing traders
	•	Multi-timeframe analysis

⸻

Features

✅ Automatic Support & Resistance Detection
Automatically tracks important support and resistance levels using recent market structure.

✅ Multi-Timeframe Support (MTF)
Display higher timeframe support and resistance levels directly on lower timeframe charts.
Example:
	•	View 1H S/R on a 5M chart
	•	View 4H S/R on a 15M chart
	•	Use current timeframe or custom timeframe

✅ Dynamic Breakout Highlighting
When price breaks a support or resistance level, the line automatically changes appearance to clearly show breakout zones.

✅ Fully Customizable
	•	Support & resistance colors
	•	Breakout colors
	•	Individual line widths
	•	Transparency
	•	Solid or dotted line styles

✅ Clean Trend Following Visualization
Designed to provide a simple and uncluttered trading experience.

⸻

How To Use

Trend Trading

Use support and resistance levels to trade in the direction of the trend.
	•	Buy near support during uptrends
	•	Sell near resistance during downtrends

Breakout Trading

Highlighted breakout levels can help identify:
	•	Potential trend continuation
	•	Strong momentum entries
	•	Key market structure breaks

Multi-Timeframe Analysis

Use higher timeframe levels on lower timeframe charts for stronger confluence.
Example:
	•	1H levels on 5M chart
	•	Daily levels on 1H chart

⸻

Recommended Settings

Scalping:
	•	Lookback: 10–20
	•	Higher timeframe: 15M or 1H

Intraday:
	•	Lookback: 20–50
	•	Higher timeframe: 1H or 4H

Swing Trading:
	•	Lookback: 50–100
	•	Higher timeframe: 4H or Daily

⸻

Important Notes

This indicator is designed to assist with market structure analysis and should be used together with:
	•	Price action
	•	Volume
	•	Risk management
	•	Trend confirmation tools

No indicator guarantees winning trades.

⸻

If you enjoy this indicator, consider adding it to your favorites and follow for future updates.

## Source Code

````pine
//@version=5
indicator("Auto Trend Support & Resistance Levels", overlay=true)

lookback = input.int(20, "Lookback Period", minval=2)

useCurrentTf = input.bool(true, "Use Current Timeframe")
customTf = input.timeframe("60", "Custom S/R Timeframe")
tf = useCurrentTf ? timeframe.period : customTf

showSupport = input.bool(true, "Show Support")
showResistance = input.bool(true, "Show Resistance")
showBreakout = input.bool(true, "Show Breakout Lines")

supportColor = input.color(color.aqua, "Support Color")
supportWidth = input.int(1, "Support Line Width", minval=1, maxval=5)
supportTransp = input.int(0, "Support Transparency", minval=0, maxval=100)
supportStyle = input.string("Solid", "Support Line Style", options=["Solid", "Dotted"])

resColor = input.color(color.orange, "Resistance Color")
resWidth = input.int(1, "Resistance Line Width", minval=1, maxval=5)
resTransp = input.int(0, "Resistance Transparency", minval=0, maxval=100)
resStyle = input.string("Solid", "Resistance Line Style", options=["Solid", "Dotted"])

breakColor = input.color(color.red, "Breakout Color")
breakWidth = input.int(1, "Breakout Line Width", minval=1, maxval=5)
breakTransp = input.int(0, "Breakout Transparency", minval=0, maxval=100)
breakStyle = input.string("Dotted", "Breakout Line Style", options=["Solid", "Dotted"])

// Higher / selected timeframe S/R
mtfResistance = request.security(syminfo.tickerid, tf, ta.highest(high[1], lookback), barmerge.gaps_off, barmerge.lookahead_off)
mtfSupport = request.security(syminfo.tickerid, tf, ta.lowest(low[1], lookback), barmerge.gaps_off, barmerge.lookahead_off)

// Breakout detection
resBroken = not na(mtfResistance) and close > mtfResistance
supBroken = not na(mtfSupport) and close < mtfSupport

// Store breakout levels
var float resistanceBreakLevel = na
var float supportBreakLevel = na

if resBroken and not resBroken[1]
    resistanceBreakLevel := mtfResistance

if supBroken and not supBroken[1]
    supportBreakLevel := mtfSupport

// Reset breakout level when price returns back inside range
if not resBroken
    resistanceBreakLevel := na

if not supBroken
    supportBreakLevel := na

// Normal S/R
resNormal = showResistance and not resBroken ? mtfResistance : na
supNormal = showSupport and not supBroken ? mtfSupport : na

// Breakout S/R
resBreak = showBreakout and showResistance and resBroken ? resistanceBreakLevel : na
supBreak = showBreakout and showSupport and supBroken ? supportBreakLevel : na

// Normal resistance
plot(resStyle == "Solid" ? resNormal : na, title="Resistance", color=color.new(resColor, resTransp), linewidth=resWidth, style=plot.style_stepline)
plot(resStyle == "Dotted" ? resNormal : na, title="Dotted Resistance", color=color.new(resColor, resTransp), linewidth=resWidth, style=plot.style_circles)

// Normal support
plot(supportStyle == "Solid" ? supNormal : na, title="Support", color=color.new(supportColor, supportTransp), linewidth=supportWidth, style=plot.style_stepline)
plot(supportStyle == "Dotted" ? supNormal : na, title="Dotted Support", color=color.new(supportColor, supportTransp), linewidth=supportWidth, style=plot.style_circles)

// Breakout resistance
plot(breakStyle == "Solid" ? resBreak : na, title="Resistance Breakout", color=color.new(breakColor, breakTransp), linewidth=breakWidth, style=plot.style_stepline)
plot(breakStyle == "Dotted" ? resBreak : na, title="Dotted Resistance Breakout", color=color.new(breakColor, breakTransp), linewidth=breakWidth, style=plot.style_circles)

// Breakout support
plot(breakStyle == "Solid" ? supBreak : na, title="Support Breakout", color=color.new(breakColor, breakTransp), linewidth=breakWidth, style=plot.style_stepline)
plot(breakStyle == "Dotted" ? supBreak : na, title="Dotted Support Breakout", color=color.new(breakColor, breakTransp), linewidth=breakWidth, style=plot.style_circles)
````
