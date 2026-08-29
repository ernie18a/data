<!-- tradingview-pine-id: PUB;cb1d022d06d14deabb64b7b4f2ca77eb -->
<!-- tradingviewscripts-format: 1 -->
# Volume Ignition Oscillator

Source: https://www.tradingview.com/script/XcH6UaF6-Volume-Ignition-Oscillator/

## Description

Volume Ignition Oscillator (VIO)

Volume Ignition Oscillator flags potential exhaustion points after a sharp price move by combining three conditions: a recent large price swing, price sitting at a range extreme, and volume running hot relative to its recent average. When all three line up, the oscillator "ignites" — hence the name.

How it works
Big Move Detection — the script measures the price change over a lookback window (default 5 bars) against a multiple of ATR (default 2x, 14-period ATR). A move that clears this threshold opens a "watch window" of N bars (default 8) during which the indicator is active — up-moves open a top watch, down-moves open a bottom watch.
Range Position — price's position within the recent high/low range (default 20 bars) is calculated as a 0–1 value. The oscillator only engages when price is in the top zone (default ≥75%) during a top watch, or the bottom zone (default ≤25%) during a bottom watch.
Volume Surge — current volume is compared to its moving average (default 20-period SMA). The excess volume above that average scales the signal — the more volume expands beyond normal, the stronger the reading.

These three factors combine into a raw oscillator value, which is then EMA-smoothed. A slower EMA of the oscillator acts as a signal line.

Reading the indicator
Columns above zero (shaded toward red) = potential topping pressure: a big up-move, price near the highs, and volume ignition.
Columns below zero (shaded toward teal/green) = potential bottoming pressure: a big down-move, price near the lows, and volume ignition.
Column brightness/gradient scales with the strength of the current reading relative to the last 100 bars.
Background shading shows when a watch window is active and fades out as the window expires.
Triangle markers print when the oscillator crosses the signal threshold (default ±0.15): a down-triangle at the top signals possible short/exhaustion, an up-triangle at the bottom signals possible long/exhaustion.
Info panel (top-right, optional) shows the live oscillator value, volume ratio, range position %, and current watch zone.
Suggested use

VIO is designed as a mean-reversion / exhaustion tool, not a trend-following signal. It's best used to:

Spot potential climax moves after an extended impulsive swing on rising volume
Time partial profit-taking or tightened stops on existing trend positions
Screen for reversal candidates that can then be confirmed with price action, support/resistance, or another momentum tool

It is not intended as a standalone entry system — combine it with your own risk management and confirmation criteria. Like any exhaustion/reversal tool, it can trigger repeatedly during strong sustained trends, so treat signals as alerts to watch price action rather than automatic trade triggers.

Inputs
Big Move Detection — lookback bars, ATR length, move threshold (x ATR), post-move watch window length
Volume — volume moving average length
Range Position — range lookback, top/bottom zone thresholds
Signal — oscillator smoothing length, signal trigger level
Appearance — top/bottom colors, toggle for the info panel
Alerts

Two alert conditions are built in:

VIO Short Signal — fires on a top exhaustion cross
VIO Long Signal — fires on a bottom exhaustion cross

---

## Source Code

````pine
//@version=6
indicator("Volume Ignition Oscillator", shorttitle="VIO", overlay=false)

// Inputs
grpMove = "Big Move Detection"
bigMoveLen = input.int(5, title="Move Lookback bars", minval=1, group=grpMove)
atrLen = input.int(14, title="ATR Length", minval=1, group=grpMove)
bigMoveMult = input.float(2.0, title="Move Threshold x ATR", minval=0.1, step=0.1, group=grpMove)
postMoveBars = input.int(8, title="Post Move Watch Window bars", minval=1, group=grpMove)

grpVol = "Volume"
volLen = input.int(20, title="Volume MA Length", minval=1, group=grpVol)

grpRange = "Range Position"
rangeLen = input.int(20, title="Range Lookback bars", minval=2, group=grpRange)
topZone = input.float(0.75, title="Top Zone Threshold", minval=0.5, maxval=0.95, step=0.05, group=grpRange)
bottomZone = input.float(0.25, title="Bottom Zone Threshold", minval=0.05, maxval=0.5, step=0.05, group=grpRange)

grpSig = "Signal"
smoothLen = input.int(3, title="Oscillator Smoothing", minval=1, group=grpSig)
signalThresh = input.float(0.15, title="Signal Trigger Level", minval=0.01, step=0.01, group=grpSig)

grpColor = "Appearance"
bearColor = input.color(#ef5350, title="Top / Short Color", group=grpColor)
bullColor = input.color(#26a69a, title="Bottom / Long Color", group=grpColor)
showTable = input.bool(true, title="Show Info Panel", group=grpColor)

// Big move detection
atrVal = ta.atr(atrLen)
priceMove = close - close[bigMoveLen]
bigMoveUp = priceMove > bigMoveMult * atrVal
bigMoveDown = priceMove < -bigMoveMult * atrVal

var int barsSinceUp = 9999
var int barsSinceDown = 9999

if bigMoveUp
    barsSinceUp := 0
else
    barsSinceUp := barsSinceUp + 1

if bigMoveDown
    barsSinceDown := 0
else
    barsSinceDown := barsSinceDown + 1

gateTop = barsSinceUp <= postMoveBars
gateBottom = barsSinceDown <= postMoveBars

// Range position
hh = ta.highest(high, rangeLen)
ll = ta.lowest(low, rangeLen)
rangeSize = hh - ll

posInRange = 0.5
if rangeSize != 0
    posInRange := (close - ll) / rangeSize

inTop = posInRange >= topZone
inBottom = posInRange <= bottomZone

// Volume surge
volSMA = ta.sma(volume, volLen)
volRatio = 1.0
if volSMA != 0
    volRatio := volume / volSMA

volExcess = math.max(volRatio - 1.0, 0.0)

// Oscillator value
oscTopRaw = 0.0
if gateTop and inTop
    oscTopRaw := volExcess * posInRange

oscBottomRaw = 0.0
if gateBottom and inBottom
    oscBottomRaw := -volExcess * (1 - posInRange)

oscRaw = oscTopRaw + oscBottomRaw
osc = ta.ema(oscRaw, smoothLen)
signalLine = ta.ema(osc, smoothLen * 2)

// Gradient bar color based on strength
magnitude = math.abs(osc)
maxMag = ta.highest(magnitude, 100)

maxMagSafe = 1.0
if maxMag != 0
    maxMagSafe := maxMag

barColor = color.new(color.gray, 60)
if osc > 0
    barColor := color.from_gradient(magnitude, 0, maxMagSafe, color.new(bearColor, 75), bearColor)
if osc < 0
    barColor := color.from_gradient(magnitude, 0, maxMagSafe, color.new(bullColor, 75), bullColor)

// Watch window background, fades out across the window
bgColor = color(na)
if gateTop
    bgColor := color.from_gradient(barsSinceUp, 0, postMoveBars, color.new(bearColor, 80), color.new(bearColor, 96))
if gateBottom
    bgColor := color.from_gradient(barsSinceDown, 0, postMoveBars, color.new(bullColor, 80), color.new(bullColor, 96))

// Zone label text, computed flat at top level
zoneText = "-"
if gateTop
    zoneText := "Top Watch"
if gateBottom
    zoneText := "Bottom Watch"

// Plotting
zeroLine = hline(0, title="Zero", color=color.new(color.gray, 40), linestyle=hline.style_solid)
topLine = hline(signalThresh, title="Top Signal Level", color=color.new(bearColor, 50), linestyle=hline.style_dotted)
botLine = hline(-signalThresh, title="Bottom Signal Level", color=color.new(bullColor, 50), linestyle=hline.style_dotted)

fill(topLine, zeroLine, color=color.new(bearColor, 95), title="Top Zone Fill")
fill(zeroLine, botLine, color=color.new(bullColor, 95), title="Bottom Zone Fill")

plot(osc, title="VIO", style=plot.style_columns, color=barColor)
plot(signalLine, title="Signal", style=plot.style_line, color=color.new(color.gray, 25), linewidth=1)

topSignal = ta.crossover(osc, signalThresh)
bottomSignal = ta.crossunder(osc, -signalThresh)

plotshape(topSignal, title="Short Signal", style=shape.triangledown, location=location.top, color=bearColor, size=size.small)
plotshape(bottomSignal, title="Long Signal", style=shape.triangleup, location=location.bottom, color=bullColor, size=size.small)

bgcolor(bgColor, title="Watch Window")

// Info table, top level flat block only
var table infoTable = table.new(position.top_right, 2, 4, border_width=1)

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "VIO", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 0, str.tostring(osc, "#.###"), text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 0, 1, "Vol Ratio", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(infoTable, 1, 1, str.tostring(volRatio, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(infoTable, 0, 2, "Range Pos", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(infoTable, 1, 2, str.tostring(posInRange * 100, "#") + "%", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(infoTable, 0, 3, "Zone", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(infoTable, 1, 3, zoneText, text_color=color.white, bgcolor=color.new(color.gray, 60))

// Alerts
alertcondition(topSignal, title="VIO Short Signal", message="Volume Ignition Oscillator possible top exhaustion, consider short")
alertcondition(bottomSignal, title="VIO Long Signal", message="Volume Ignition Oscillator possible bottom exhaustion, consider long")
````
