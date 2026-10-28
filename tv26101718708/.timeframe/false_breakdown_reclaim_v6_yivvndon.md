# False Breakdown Reclaim v6

- url: https://www.tradingview.com/script/yivVNdon/
- type: indicator
- pine_id: PUB;696420efe2b140b0bae2bd55f48fb006
- version: 2.0

## Description

[b]Overview[/b]

False Breakdown Reclaim v6 is an intraday indicator built to detect a false break below a support level followed by a bullish reclaim. It is designed for liquid US stocks and focuses on identifying potential bear traps or Wyckoff-style springs after a failed downside break.

[b]How it works
[/b]
The script defines a support level, watches for a downside sweep below that level, and then checks whether price reclaims the level within a limited number of bars. When that reclaim is confirmed, the script plots a long signal and can trigger an alert.

[b]Support options
[/b]
The indicator can use:

Previous day low as the primary support reference.

A confirmed pivot low as an alternative structural support.

This allows the script to work with both objective daily levels and local price structure.

[b]Main features
[/b]
False breakdown detection below support.

Bullish reclaim confirmation above support.

Optional volume filter to reduce weak recoveries.

Configurable maximum number of bars allowed between the sweep and the reclaim.

Visual markers for the sweep and the reclaim.

Alert conditions for support sweep and bullish reclaim.

[b]Suggested use
[/b]
This indicator is best suited for intraday trading on liquid US stocks, especially on M5 and M15 charts. A higher timeframe such as H1 can be used as a context filter to avoid trading directly into a clean higher-timeframe downtrend.

[b]Important note
[/b]
This script is a decision-support tool, not a complete trading system. It should be used with proper risk management, market context, and independent validation before any live execution.

## Source Code

````pine
//@version=6
indicator("False Breakdown Reclaim on MTF VWAP v6", overlay = true)

// ===== Inputs
vwapTf = input.timeframe("60", "VWAP timeframe")
breakBufferPct = input.float(0.10, "Break buffer (%)", minval = 0.0, step = 0.01)
reclaimBufferPct = input.float(0.02, "Reclaim buffer (%)", minval = 0.0, step = 0.01)

maxBarsAfterBreak = input.int(5, "Max bars after break", minval = 1)
oneSignalPerDay = input.bool(true, "One signal per day")

useVolFilter = input.bool(true, "Volume filter")
volLen = input.int(20, "Volume MA length", minval = 1)
volMult = input.float(1.2, "Volume multiple", minval = 0.1, step = 0.1)

showVWAP = input.bool(true, "Show VWAP support")
showBreakMark = input.bool(true, "Show sweep")
showReclaimMark = input.bool(true, "Show reclaim")
showLevels = input.bool(true, "Show break/reclaim levels")

// ===== Safety check
if timeframe.in_seconds(vwapTf) < timeframe.in_seconds(timeframe.period)
    runtime.error("El VWAP timeframe debe ser igual o superior al timeframe del gráfico.")

// ===== Daily reset
isNewDay = ta.change(dayofmonth(time)) != 0
var bool signaledToday = false

if isNewDay
    signaledToday := false

// ===== MTF VWAP support
vwapSupport = request.security(syminfo.tickerid, vwapTf, ta.vwap(hlc3), lookahead = barmerge.lookahead_off)

// ===== Buffers
breakBuffer = not na(vwapSupport) ? vwapSupport * breakBufferPct / 100.0 : na
reclaimBuffer = not na(vwapSupport) ? vwapSupport * reclaimBufferPct / 100.0 : na

breakLevel = not na(vwapSupport) ? vwapSupport - breakBuffer : na
reclaimLevel = not na(vwapSupport) ? vwapSupport + reclaimBuffer : na

// ===== Break and reclaim state
var bool breakArmed = false
var int breakBarIndex = na
var float sweepLow = na

falseBreak = not na(breakLevel) and low < breakLevel

if falseBreak and not breakArmed
    breakArmed := true
    breakBarIndex := bar_index
    sweepLow := low

if breakArmed
    sweepLow := math.min(sweepLow, low)

// ===== Filters
barsSinceBreak = breakArmed and not na(breakBarIndex) ? (bar_index - breakBarIndex) : na
withinWindow = breakArmed and not na(barsSinceBreak) and barsSinceBreak <= maxBarsAfterBreak

volBase = ta.sma(volume, volLen)
volOk = not useVolFilter or volume > volBase * volMult

// ===== Reclaim condition
reclaim = withinWindow and not na(reclaimLevel) and close > reclaimLevel and volOk and (not oneSignalPerDay or not signaledToday)

// ===== Trigger and reset
if reclaim
    signaledToday := true
    breakArmed := false
    breakBarIndex := na
    sweepLow := na

if breakArmed and not withinWindow
    breakArmed := false
    breakBarIndex := na
    sweepLow := na

// ===== Visuals
plot(showVWAP ? vwapSupport : na, "MTF VWAP", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLevels ? breakLevel : na, "Break Level", color = color.new(color.red, 60), linewidth = 1, style = plot.style_linebr)
plot(showLevels ? reclaimLevel : na, "Reclaim Level", color = color.new(color.green, 60), linewidth = 1, style = plot.style_linebr)

plotshape(showBreakMark and falseBreak, title = "VWAP Sweep", style = shape.circle, location = location.belowbar, color = color.red, size = size.tiny, text = "Sweep")
plotshape(showReclaimMark and reclaim, title = "VWAP Reclaim", style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.small, text = "Reclaim")

bgcolor(breakArmed ? color.new(color.red, 92) : na)

// ===== Alerts
alertcondition(falseBreak, title = "VWAP Sweep", message = "VWAP sweep on {{ticker}} | TF {{interval}} | Close {{close}}")
alertcondition(reclaim, title = "VWAP Reclaim Long", message = "Bullish VWAP reclaim on {{ticker}} | TF {{interval}} | Close {{close}}")
````
