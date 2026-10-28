# Metis Fully Vested Entry Engine v1

- url: https://www.tradingview.com/script/014kqYiX-Metis-Fully-Vested-Entry-Engine-v1/
- type: indicator
- pine_id: PUB;f221e67ede6a44c987496af39e0bcfae
- version: 1.0

## Description

Metis Fully Vested Entry Engine v1 is a rules-based add-on indicator designed for investors who have already built a full position and want to deploy new capital only during high-quality, trend-aligned pullbacks.

Unlike traditional entry indicators, this tool is not intended for initiating positions during deep drawdowns. Instead, it focuses on identifying constructive consolidation within established uptrends — allowing users to reinforce winning positions without chasing extended price action.

The engine evaluates multiple layers of confluence, including:
	•	Strong trend structure (price above rising 50MA and 200MA)
	•	Controlled RSI pullbacks (momentum reset without breakdown)
	•	Price positioning near the 50-day moving average
	•	Optional higher-timeframe (weekly) momentum confirmation
	•	Relative volume validation

Signals are generated only on the first qualifying bar to avoid repetition and reduce noise, providing clear, actionable “Add Mode” opportunities.

This indicator is best used alongside a structured capital deployment system (such as a ladder-based entry framework), where initial positions are built during compression and additional capital is deployed selectively during trend continuation.

## Source Code

````pine
//@version=6
indicator("Métis Fully Vested Entry Engine v1", overlay=true)

// =========================
// Inputs
// =========================
rsiLen = input.int(14, "Daily RSI Length")
rsiMin = input.float(40.0, "Daily RSI Min")
rsiMax = input.float(50.0, "Daily RSI Max")

weeklyRsiLen = input.int(14, "Weekly RSI Length")
useWeeklyFilter = input.bool(true, "Use Weekly RSI Filter")
weeklyRsiMin = input.float(50.0, "Weekly RSI Min")

ma50Len = input.int(50, "Fast MA")
ma200Len = input.int(200, "Trend MA")

minPctFrom50 = input.float(-2.0, "Min % From 50MA")
maxPctFrom50 = input.float(3.0, "Max % From 50MA")

relVolLen = input.int(20, "Relative Volume Length")
relVolMin = input.float(0.8, "Min Relative Volume")

requireCloseAbove50 = input.bool(true, "Require Close Above 50MA")
showBackground = input.bool(true, "Show Background Highlight")
showContextLabel = input.bool(false, "Show Context Label")

// =========================
// Calculations
// =========================
r = ta.rsi(close, rsiLen)
weeklyR = request.security(syminfo.tickerid, "W", ta.rsi(close, weeklyRsiLen))

ma50 = ta.sma(close, ma50Len)
ma200 = ta.sma(close, ma200Len)

avgVol = ta.sma(volume, relVolLen)
relVol = avgVol != 0 ? volume / avgVol : na

pctFrom50 = ma50 != 0 ? ((close / ma50) - 1.0) * 100.0 : na

// =========================
// Trend / Add Logic
// =========================
trendOk = close > ma200 and ma50 > ma200 and ma200 > ma200[10] and ma50 > ma50[10]
rsiOk = r >= rsiMin and r <= rsiMax
weeklyOk = useWeeklyFilter ? weeklyR >= weeklyRsiMin : true
priceLocationOk = pctFrom50 >= minPctFrom50 and pctFrom50 <= maxPctFrom50
closeVs50Ok = requireCloseAbove50 ? close > ma50 : true
volOk = relVol >= relVolMin

setup = trendOk and rsiOk and weeklyOk and priceLocationOk and closeVs50Ok and volOk
newSetup = setup and not setup[1]

// =========================
// Plots
// Show in status line, hide from price scale
// =========================
plot(ma50, "50MA", color=color.orange, linewidth=2, display=display.all - display.price_scale)
plot(ma200, "200MA", color=color.blue, linewidth=2, display=display.all - display.price_scale)

// =========================
// Background highlight
// =========================
bgcolor(showBackground and setup ? color.new(color.green, 86) : na)

// =========================
// First-bar marker only
// Hidden from legend/status line
// =========================
plotshape(newSetup, title="Add Setup", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, display=display.none)

// =========================
// Label only on first setup bar
// =========================
if newSetup
    label.new(
         bar_index,
         low,
         syminfo.ticker + "\nADD MODE READY",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

// =========================
// Optional last-bar context label
// =========================
var label contextLabel = na

if barstate.islast and showContextLabel
    label.delete(contextLabel)
    contextLabel := label.new(
         bar_index,
         high,
         "ADD MODE\nRSI: " + str.tostring(r, "#.0") +
         "\nW-RSI: " + str.tostring(weeklyR, "#.0") +
         "\n% from 50MA: " + str.tostring(pctFrom50, "#.1"),
         style=label.style_label_down,
         color=color.new(color.blue, 75),
         textcolor=color.white,
         size=size.small)

// =========================
// Alerts
// =========================
alertcondition(newSetup, title="Métis Fully Vested Entry Engine v1 - Add Mode Alert", message="Métis Fully Vested Entry Engine v1: {{ticker}} has a valid add-on pullback setup.")
````
