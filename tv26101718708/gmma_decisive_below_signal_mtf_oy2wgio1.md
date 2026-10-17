# GMMA Decisive Below Signal MTF

- url: https://www.tradingview.com/script/oy2wGio1-GMMA-Decisive-Below-Signal-MTF/
- type: indicator
- pine_id: PUB;0f56d02531574fdcbaea69a9407969d8
- version: 1.0

## Description

Guppy Multiple Moving Average (GMMA) Decisive Below Signal MTF User Manual

Overview
This manual explains how to use the GMMA Decisive Below Signal MTF TradingView indicator, including its inputs, chart behavior, and signal logic. The script supports separate visibility controls for short and long GMMA groups, separate source settings for those groups, and a selectable timeframe for multi-timeframe GMMA calculations.

What the indicator does
The indicator plots a Guppy Multiple Moving Average structure using 12 EMAs split into two groups: six short-period EMAs and six long-period EMAs. It then displays a one-time bearish signal only when a candle body is completely below the full GMMA stack, with no body contact with any EMA, and only on the first bar where that state begins.


Inputs
| Setting              | Purpose                                          | Notes                                                                                  |
| -------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------- |
| GMMA Timeframe       | Chooses the timeframe used for GMMA calculations | Uses input.timeframe() and feeds that into request.security().tradingview+1            |
| Short GMMA Source    | Source used for the six short EMAs               | Created with input.source().tradingviewyoutube                                         |
| Long GMMA Source     | Source used for the six long EMAs                | Created with input.source().tradingviewyoutube                                         |
| Show Short GMMA      | Shows or hides the short EMA group               | Boolean visibility control through input.bool() and plot(... ? value : na).tradingview |
| Show Long GMMA       | Shows or hides the long EMA group                | Boolean visibility control through input.bool() and plot(... ? value : na).tradingview |
| EMA1 to EMA12 Period | Controls the lengths of the EMAs                 | The default GMMA structure remains 3, 5, 8, 10, 12, 15 and 30, 35, 40, 45, 50, 60.     |


Signal logic
The script calculates the upper edge of the candle body using math.max(open, close). It then calculates the lowest EMA value across all 12 GMMA lines using math.min(...), and the bearish condition becomes true only when the body top is strictly below that level, which prevents body contact with any EMA.

The plotted signal appears only on the first bar where the decisive bearish condition turns true. This behavior comes from feeding plotshape() a boolean series and combining the current condition with its prior-bar state using [1], so repeated signals are suppressed while the condition remains true.

Setup steps
Open TradingView and add a new custom indicator in the Pine Editor.

Paste the script and save it.

Add the indicator to the chart.

Open the indicator settings and choose the GMMA timeframe, short source, long source, and visibility checkboxes.

Review the chart for one-time SELL signals when a candle body decisively moves below the full GMMA stack.

Screen grabs to capture
Add the following screenshots before publishing the manual so users can visually follow the workflow.

Screen grab 1: Pine Editor with the script loaded
Capture the Pine Editor showing the script title, the timeframe input, the short and long source inputs, and the plotshape signal section. This screenshot helps users confirm they pasted the correct script.

Screen grab 2: Indicator settings panel
Capture the Inputs tab showing:

GMMA Timeframe

Short GMMA Source

Long GMMA Source

Show Short GMMA

Show Long GMMA

EMA periods

This screenshot helps users understand how to configure the script inputs.

Screen grab 3: Chart with both GMMA groups visible
Capture a chart where the six short EMAs are visible in green and the six long EMAs are visible in red. This screenshot demonstrates the two-group GMMA structure.

Screen grab 4: Chart showing the first decisive bearish SELL signal
Capture a chart section where the candle body is clearly below the entire GMMA stack and the SELL marker appears above the bar only once. This screenshot documents the exact signal behavior controlled by plotshape() and the first-occurrence condition.

Screen grab 5: Visibility controls in action
Capture one chart with only short GMMA enabled and another with only long GMMA enabled. This screenshot pair documents how the checkboxes affect display without changing the underlying signal logic.

Notes and cautions
input.source() supports source selection such as open, high, low, close, and composite price series, but source behavior in multi-timeframe workflows should be tested carefully because the script also uses request.security() to pull values from another timeframe.

TradingView documentation notes that requesting lower-timeframe data from a higher-timeframe chart is generally not recommended, so users should prefer equal or higher GMMA timeframes for more stable behavior.

Recommended upload package
For a clean user manual upload, include:

This markdown manual as the main document.

Five PNG screenshots named in sequence, for example 01-pine-editor.png through 05-signal-example.png.

The Pine Script file saved separately as plain text for quick reuse.

## Source Code

````pine
//@version=6
indicator("GMMA Decisive Below Signal MTF", overlay = true)

// Timeframe input
gmmaTf = input.timeframe("", "GMMA Timeframe")

// Source inputs
shortSource = input.source(close, "Short GMMA Source")
longSource  = input.source(close, "Long GMMA Source")

// Show/Hide checkboxes
showShortGMMA = input.bool(true, "Show Short GMMA")
showLongGMMA  = input.bool(true, "Show Long GMMA")

// Inputs
period1  = input.int(3,  "EMA1 Period")
period2  = input.int(5,  "EMA2 Period")
period3  = input.int(8,  "EMA3 Period")
period4  = input.int(10, "EMA4 Period")
period5  = input.int(12, "EMA5 Period")
period6  = input.int(15, "EMA6 Period")
period7  = input.int(30, "EMA7 Period")
period8  = input.int(35, "EMA8 Period")
period9  = input.int(40, "EMA9 Period")
period10 = input.int(45, "EMA10 Period")
period11 = input.int(50, "EMA11 Period")
period12 = input.int(60, "EMA12 Period")

tf = gmmaTf == "" ? timeframe.period : gmmaTf

// EMA calculations from selected timeframe
ema1  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period1))
ema2  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period2))
ema3  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period3))
ema4  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period4))
ema5  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period5))
ema6  = request.security(syminfo.tickerid, tf, ta.ema(shortSource, period6))

ema7  = request.security(syminfo.tickerid, tf, ta.ema(longSource, period7))
ema8  = request.security(syminfo.tickerid, tf, ta.ema(longSource, period8))
ema9  = request.security(syminfo.tickerid, tf, ta.ema(longSource, period9))
ema10 = request.security(syminfo.tickerid, tf, ta.ema(longSource, period10))
ema11 = request.security(syminfo.tickerid, tf, ta.ema(longSource, period11))
ema12 = request.security(syminfo.tickerid, tf, ta.ema(longSource, period12))

// Plot short GMMA only if checkbox is checked
plot(showShortGMMA ? ema1 : na, color = color.green, title = "short1")
plot(showShortGMMA ? ema2 : na, color = color.green, title = "short2")
plot(showShortGMMA ? ema3 : na, color = color.green, title = "short3")
plot(showShortGMMA ? ema4 : na, color = color.green, title = "short4")
plot(showShortGMMA ? ema5 : na, color = color.green, title = "short5")
plot(showShortGMMA ? ema6 : na, color = color.green, title = "short6")

// Plot long GMMA only if checkbox is checked
plot(showLongGMMA ? ema7 : na, color = color.red, title = "long1")
plot(showLongGMMA ? ema8 : na, color = color.red, title = "long2")
plot(showLongGMMA ? ema9 : na, color = color.red, title = "long3")
plot(showLongGMMA ? ema10 : na, color = color.red, title = "long4")
plot(showLongGMMA ? ema11 : na, color = color.red, title = "long5")
plot(showLongGMMA ? ema12 : na, color = color.red, title = "long6")

// Candle body top
bodyTop = math.max(open, close)

// Lowest EMA in full GMMA stack
lowestGMMA = math.min(ema1, ema2, ema3, ema4, ema5, ema6, ema7, ema8, ema9, ema10, ema11, ema12)

// Decisive bearish condition: body fully below all GMMA lines
decisiveBelow = bodyTop < lowestGMMA

// First occurrence only
firstDecisiveBelow = decisiveBelow and not decisiveBelow[1]

// Signal
plotshape(firstDecisiveBelow, title = "First Decisive Below GMMA", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, text = "SELL")
````
