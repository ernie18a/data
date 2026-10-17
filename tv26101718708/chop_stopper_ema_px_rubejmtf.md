# Chop Stopper EMA Px

- url: https://www.tradingview.com/script/rUBEJmTF-Chop-Stopper-EMA-Px/
- type: indicator
- pine_id: PUB;d3192a8b1966450cbc2a6cdfcf3da32d
- version: 1.0

## Description

[b]CHOP STOPPER EMA[/b]

Chop Stopper EMA is a trend-bias filter built on an Exponential Moving Average. Most EMA tools flip the moment price crosses the line, which causes constant false signals in sideways markets. This script only flips its trend state after price has closed on the same side of the EMA for a set number of consecutive bars.

The result is a long/short bias that holds through noise and changes only when a move has shown real follow-through.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━
1. The script counts consecutive closes above the EMA and consecutive closes below it.
2. When closes above the EMA reach the Confirmation Bars (N), the state locks to LONG.
3. When closes below the EMA reach N, the state locks to SHORT.
4. Between flips, the state stays unchanged. A single close on the wrong side does not reverse it.
5. While a run is forming but has not yet reached N, the script enters a neutral "building" phase. This is the early warning that a flip may be coming, but it is not yet confirmed.

Every decision uses closed-bar values only, so signals do not repaint once a bar closes.

━━━━━━━━━━━━━━━━━━━━
WHAT YOU SEE ON THE CHART
━━━━━━━━━━━━━━━━━━━━
- EMA line: green in a confirmed long state, red in a confirmed short state, black (neutral) while a new run is building.

[image]https://www.tradingview.com/x/1ONErp2q/[/image]

- Candle tint: candles take the same colors, including neutral during the building phase.

[image]https://www.tradingview.com/x/bAxdcU5H/[/image]

- Triangle markers: appear once, on the bar where the trend state actually flips.
- Background zone: a faint tint showing the current confirmed state.

━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━
- EMA Length: period of the EMA (default 34).
- Confirmation Bars (N): consecutive closes on one side needed to confirm a flip (default 5). Higher = fewer, slower flips. Lower = faster, but more noise.
- Neutral Trigger Bars (n): consecutive closes needed before the neutral/building color appears (default 1). Should be lower than N to have a visible effect.
- Colors: bullish, bearish, and neutral/building colors are all customizable.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━
Two alert conditions are included: "flipped LONG" and "flipped SHORT". They trigger when a flip is confirmed.

━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━
- Because confirmation requires N closes, flips are intentionally delayed. That delay is the trade-off for filtering chop.
- This indicator is a tool for reading trend context, not a complete trading system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator('Chop Stopper EMA', shorttitle = 'Chop Free EMA', overlay = true)

// ── Inputs ──
emaPeriod = input.int(34, title = 'EMA Length', minval = 1, group = 'Settings')
lockBars = input.int(5, title = 'Confirmation Bars (N)', minval = 1, maxval = 100, group = 'Settings', tooltip = 'Consecutive closes on the same side of the EMA required to CONFIRM a trend flip.')
buildBars = input.int(1, title = 'Neutral Trigger Bars (n)', minval = 1, maxval = 100, group = 'Settings', tooltip = 'Consecutive closes on the same side needed to show the neutral/building color before full confirmation. Must be less than Confirmation Bars (N) to have any visible effect.')

upColor = input.color(color.lime, title = 'Bullish Color', group = 'Colors')
downColor = input.color(color.red, title = 'Bearish Color', group = 'Colors')
buildColor = input.color(color.black, title = 'Neutral/Building Color', group = 'Colors')

// ── Core calculation ──
emaLine = ta.ema(close, emaPeriod)

closeAbove = close > emaLine
closeBelow = close < emaLine

// Consecutive-close run counters (nz() guards against na on the first bar)
var int runAbove = 0
var int runBelow = 0
runAbove := closeAbove ? nz(runAbove[1]) + 1 : 0
runBelow := closeBelow ? nz(runBelow[1]) + 1 : 0

// ── Confirmation and persistent trend state ──
longLocked = runAbove >= lockBars
shortLocked = runBelow >= lockBars

var int trendState = 0 // 1 = long, -1 = short, 0 = undefined
if longLocked
    trendState := 1
    trendState
else if shortLocked
    trendState := -1
    trendState

flipLong = trendState == 1 and trendState[1] != 1
flipShort = trendState == -1 and trendState[1] != -1

// ── Building (neutral) phase: partial run that hasn't hit lockBars yet ──
// Clamp so the window is never empty if buildBars >= lockBars.
buildBarsEff = math.min(buildBars, lockBars - 1)

// The > 0 checks stop an idle side (run = 0) from counting as "building"
// when lockBars = 1 forces buildBarsEff to 0.
isBuilding = runAbove > 0 and runAbove >= buildBarsEff and runAbove < lockBars or runBelow > 0 and runBelow >= buildBarsEff and runBelow < lockBars

// ── Visuals ──
lineColor = isBuilding ? buildColor : trendState == 1 ? upColor : trendState == -1 ? downColor : buildColor
plot(emaLine, title = 'EMA', color = lineColor, linewidth = 2)

plotshape(flipLong, title = 'Trend -> LONG', style = shape.triangleup, location = location.belowbar, color = color.new(upColor, 0), size = size.small)
plotshape(flipShort, title = 'Trend -> SHORT', style = shape.triangledown, location = location.abovebar, color = color.new(downColor, 0), size = size.small)

candleColor = isBuilding ? color.new(buildColor, 70) : trendState == 1 ? color.new(upColor, 70) : trendState == -1 ? color.new(downColor, 70) : na
barcolor(candleColor, title = 'Candle Tint')

bgcolor(trendState == 1 ? color.new(upColor, 92) : trendState == -1 ? color.new(downColor, 92) : na, title = 'Trend Zone')

// ── Alerts ──
alertcondition(flipLong, title = 'Chop Stopper: flipped LONG', message = 'Chop Stopper EMA flipped LONG')
alertcondition(flipShort, title = 'Chop Stopper: flipped SHORT', message = 'Chop Stopper EMA flipped SHORT')
````
