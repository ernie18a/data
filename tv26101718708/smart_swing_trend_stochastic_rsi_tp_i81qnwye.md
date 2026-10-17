# Smart Swing Trend Stochastic RSI - TP

- url: https://www.tradingview.com/script/i81QNWYE-Smart-Swing-Trend-Stochastic-RSI-TP/
- type: indicator
- pine_id: PUB;70994426e7d34ee8abd672eb257a3ee3
- version: 1.0

## Description

Absolutely friend. Here is a **TradingView rule-abiding publication description** you can use.

---

## Smart Swing Trend Stochastic RSI

**Smart Swing Trend Stochastic RSI** is a trend-aware Stochastic RSI indicator designed to help traders interpret momentum extremes with better market context.

Traditional Stochastic RSI often treats readings above 80 as “overbought” and readings below 20 as “oversold.” However, in strong trends, these extreme zones can remain extended for a long time. This script adds swing-trend context so the 80/20 zones are interpreted differently depending on whether the market is in a swing uptrend or swing downtrend.

The goal is to help traders avoid automatically fading strong momentum and instead separate trend strength from potential turning points.

---

## Core Concept

This indicator combines:

1. **Stochastic RSI**
2. **Swing-based trend direction**
3. **Trend-aware shaded zones**
4. **Simple table interpretation**
5. **Momentum turn and warning signals**

The script does not treat every overbought or oversold reading as a reversal. Instead, it asks:

> Is this Stoch RSI extreme showing trend power, or is it starting to become a possible pullback/bounce warning?

---

## How the Trend Logic Works

The trend logic is based on swing direction, adapted from the swing logic concept used in Zeiierman’s Dynamic Swing Anchored VWAP.

The script identifies recent swing highs and swing lows using the selected **Swing Period**.

In simple terms:

* **Swing Uptrend** means the current swing structure favors the upside.
* **Swing Downtrend** means the current swing structure favors the downside.
* **Swing Neutral** can appear when the optional neutral mode is enabled after a recent direction change.

This allows the Stochastic RSI to be interpreted based on the current swing environment instead of using a fixed moving average trend filter.

---

## Signal Meanings

### Bullish Turn

A **Bullish Turn** appears when the swing trend is up and Stochastic RSI recently reached the lower zone, then starts turning upward.

This can suggest that short-term momentum may be turning back up after a pullback.

Simple meaning:

> Momentum may be turning up in a swing uptrend.

---

### Bearish Turn

A **Bearish Turn** appears when the swing trend is down and Stochastic RSI recently reached the upper zone, then starts turning downward.

This can suggest that short-term momentum may be turning back down after a bounce.

Simple meaning:

> Momentum may be turning down in a swing downtrend.

---

### Pullback Warning

A **Pullback Warning** appears when the market is in a swing uptrend, Stochastic RSI is in the upper zone, and momentum starts rolling over while price is extended.

This does not automatically mean the trend is over. It is a caution signal.

Simple meaning:

> Price may be stretched in an uptrend. Be careful chasing late.

---

### Bounce Warning

A **Bounce Warning** appears when the market is in a swing downtrend, Stochastic RSI is in the lower zone, and momentum starts turning upward while price is extended.

This does not automatically mean a new uptrend has started. It is a caution signal for shorts.

Simple meaning:

> Price may be stretched in a downtrend. Be careful shorting late.

---

## Shaded Zone Interpretation

The shaded areas are trend-aware:

* **Gray upper zone**: Stoch RSI is above 80, but in an uptrend this can still represent bullish power.
* **Red upper zone**: Momentum may be rolling over and pullback risk may be increasing.
* **Gray lower zone**: Stoch RSI is below 20, but in a downtrend this can still represent bearish power.
* **Green lower zone**: Momentum may be turning up and bounce potential may be increasing.

This helps avoid the common mistake of assuming:

* Above 80 always means sell.
* Below 20 always means buy.

In strong trends, extremes can remain extended.

---

## Read Table

The table provides a simplified summary of the current condition:

* **Trend**: Current swing trend direction.
* **Zone**: Current Stoch RSI zone interpretation.
* **Signal**: Recent valid signal, if one is active.
* **Interpretation**: Simple plain-English read of the current condition.

The signal can be held for a selected number of bars using the **Hold Signal For Bars** setting.

---

## Key Settings

### RSI Length / Stochastic Length

Controls the sensitivity of the Stochastic RSI calculation.

Lower values react faster.
Higher values are smoother but slower.

### Swing Period

Controls how large or small the swing structure should be.

Lower values react faster but can create more noise.
Higher values focus on larger swing moves.

### Price Extension ATR Multiplier

Used to help identify when price may be stretched away from its swing anchor.

### Shaded Zone Transparency

Allows users to adjust the brightness/opacity of the gray, red, and green shaded areas.

### Table Text Size

Allows users to adjust the size of the table text.

---

## How to Use

This indicator is best used as a momentum and timing tool, not as a standalone trading system.

A possible bullish interpretation:

> Swing trend is up, Stoch RSI pulled into the lower zone, then a Bullish Turn appears.

A possible bearish interpretation:

> Swing trend is down, Stoch RSI bounced into the upper zone, then a Bearish Turn appears.

A caution example:

> In an uptrend, Stoch RSI above 80 may remain bullish power. A Pullback Warning only appears when momentum starts rolling over and price is extended.

---

## Important Notes

This indicator is for educational and analytical purposes only.

It does not guarantee future price movement and should not be used as financial advice. Traders should combine it with price structure, volume, support/resistance, risk management, and broader market context.

When the **Confirm Signals On Closed Bar** option is enabled, signals are designed to confirm only after the candle closes. Live candles can still change before closing.

---

## Attribution

Swing-direction trend logic is adapted from the concept used in **Dynamic Swing Anchored VWAP by Zeiierman**.

Original work licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International:

[https://creativecommons.org/licenses/by-nc-sa/4.0/](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Source Code

````pine
// This script uses Stochastic RSI logic with swing-direction trend context
// Swing-direction trend logic adapted from Zeiierman's Dynamic Swing Anchored VWAP concept
// Original Zeiierman work licensed under CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator("Smart Swing Trend Stochastic RSI - TP", overlay=false, max_labels_count=500)

// === INPUTS ===
src = input.source(close, "Source", group="Stochastic RSI Settings")
rsiLen = input.int(10, "RSI Length", minval=1, group="Stochastic RSI Settings")
stochLen = input.int(10, "Stochastic Length", minval=1, group="Stochastic RSI Settings")
smoothK = input.int(3, "%K Smoothing", minval=1, group="Stochastic RSI Settings")
smoothD = input.int(3, "%D Smoothing", minval=1, group="Stochastic RSI Settings")

overbought = input.float(80.0, "Overbought Level", minval=50, maxval=100, group="Levels")
oversold = input.float(20.0, "Oversold Level", minval=0, maxval=50, group="Levels")
midline = input.float(50.0, "Midline", minval=0, maxval=100, group="Levels")

swingPeriod = input.int(50, "Swing Period", minval=2, group="Swing Trend Logic")
useNeutralMode = input.bool(false, "Use Neutral Mode When Direction Changes Recently", group="Swing Trend Logic")
neutralBars = input.int(3, "Neutral Bars After Swing Direction Change", minval=0, group="Swing Trend Logic")

atrLen = input.int(14, "ATR Length", minval=1, group="Smart Zone Logic")
extensionAtr = input.float(1.5, "Price Extension ATR Multiplier", minval=0.1, step=0.1, group="Smart Zone Logic")
turnLookback = input.int(5, "Turn Lookback Bars", minval=1, group="Smart Zone Logic")
requireExtensionForWarning = input.bool(true, "Require Price Extension For Pullback/Bounce Warning", group="Smart Zone Logic")
confirmOnClose = input.bool(true, "Confirm Signals On Closed Bar", group="Smart Zone Logic")

signalHoldBars = input.int(2, "Hold Signal For Bars", minval=1, group="Signal Display")

showSmartZones = input.bool(true, "Show Smart Shaded Zones", group="Display")
showSignals = input.bool(false, "Show Signal Labels", group="Display")
showTable = input.bool(true, "Show Read Table", group="Display")
showBarColors = input.bool(false, "Color Price Bars By Read", group="Display")
tablePosition = input.string("Bottom Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display")
tableSizeInput = input.string("Tiny", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")

kColor = input.color(color.rgb(0, 188, 212), "%K Line Color", group="Colors")
dColor = input.color(color.rgb(255, 152, 0), "%D Line Color", group="Colors")
grayZoneColor = input.color(color.rgb(120, 123, 134), "Power / Not Yet Reversal Zone", group="Colors")
bullColor = input.color(color.rgb(0, 230, 118), "True Oversold / Bullish Color", group="Colors")
bearColor = input.color(color.rgb(255, 48, 69), "True Overbought / Bearish Color", group="Colors")
neutralColor = input.color(color.rgb(120, 123, 134), "Neutral Color", group="Colors")
textColor = input.color(color.white, "Table Text Color", group="Colors")
tableBg = input.color(color.rgb(42, 46, 57), "Table Background", group="Colors")

grayZoneTransparency = input.int(82, "Gray Zone Transparency", minval=0, maxval=100, group="Shaded Zone Opacity")
redZoneTransparency = input.int(40, "Red Zone Transparency", minval=0, maxval=100, group="Shaded Zone Opacity")
greenZoneTransparency = input.int(40, "Green Zone Transparency", minval=0, maxval=100, group="Shaded Zone Opacity")

// === TABLE POSITION FUNCTION ===
f_table_pos(_pos) =>
    result = position.bottom_right
    if _pos == "Top Left"
        result := position.top_left
    if _pos == "Top Right"
        result := position.top_right
    if _pos == "Bottom Left"
        result := position.bottom_left
    if _pos == "Bottom Right"
        result := position.bottom_right
    result

// === TABLE SIZE FUNCTION ===
f_table_size(_size) =>
    result = size.normal
    if _size == "Tiny"
        result := size.tiny
    if _size == "Small"
        result := size.small
    if _size == "Normal"
        result := size.normal
    if _size == "Large"
        result := size.large
    if _size == "Huge"
        result := size.huge
    result

tableTextSize = f_table_size(tableSizeInput)

// === STOCHASTIC RSI CALCULATION ===
rsiValue = ta.rsi(src, rsiLen)
rsiLowest = ta.lowest(rsiValue, stochLen)
rsiHighest = ta.highest(rsiValue, stochLen)
rsiRange = rsiHighest - rsiLowest

float stochRaw = 0.0
if rsiRange != 0
    stochRaw := 100 * (rsiValue - rsiLowest) / rsiRange

k = ta.sma(stochRaw, smoothK)
d = ta.sma(k, smoothD)

// === SWING TREND LOGIC ===
b = bar_index

var float ph = na
var float pl = na
var int phL = bar_index
var int plL = bar_index

isNewSwingHigh = ta.highestbars(high, swingPeriod) == 0
isNewSwingLow = ta.lowestbars(low, swingPeriod) == 0

ph := isNewSwingHigh ? high : ph
pl := isNewSwingLow ? low : pl
phL := isNewSwingHigh ? b : phL
plL := isNewSwingLow ? b : plL

swingDir = phL > plL ? 1 : -1
swingDirChanged = swingDir != swingDir[1]
barsSinceSwingChange = ta.barssince(swingDirChanged)

neutralAfterChange = useNeutralMode and barsSinceSwingChange >= 0 and barsSinceSwingChange <= neutralBars

upTrend = swingDir == 1 and not neutralAfterChange
downTrend = swingDir == -1 and not neutralAfterChange
sidewaysTrend = neutralAfterChange

// === PRICE EXTENSION LOGIC ===
atrValue = ta.atr(atrLen)

float swingAnchor = close
if upTrend
    swingAnchor := pl
if downTrend
    swingAnchor := ph

priceExtendedUp = upTrend and not na(swingAnchor) and close > swingAnchor + atrValue * extensionAtr
priceExtendedDown = downTrend and not na(swingAnchor) and close < swingAnchor - atrValue * extensionAtr

extensionOkUp = true
extensionOkDown = true

if requireExtensionForWarning
    extensionOkUp := priceExtendedUp
    extensionOkDown := priceExtendedDown

// === MOMENTUM TURN LOGIC ===
confirmedBar = true
if confirmOnClose
    confirmedBar := barstate.isconfirmed

upperZone = k >= overbought
lowerZone = k <= oversold

kRollingOver = k < k[1] and k < d
kTurningUp = k > k[1] and k > d

wasOversoldRecently = ta.lowest(k, turnLookback) <= oversold
wasOverboughtRecently = ta.highest(k, turnLookback) >= overbought

// === SMART ZONE LOGIC ===
pullbackWarning = false
bounceWarning = false
bearishTurnArea = false
bullishTurnArea = false

if upTrend and upperZone and kRollingOver and extensionOkUp
    pullbackWarning := true

if downTrend and lowerZone and kTurningUp and extensionOkDown
    bounceWarning := true

if downTrend and upperZone and kRollingOver
    bearishTurnArea := true

if upTrend and lowerZone and kTurningUp
    bullishTurnArea := true

if sidewaysTrend and upperZone and kRollingOver
    pullbackWarning := true

if sidewaysTrend and lowerZone and kTurningUp
    bounceWarning := true

upperRedZone = pullbackWarning or bearishTurnArea
lowerGreenZone = bounceWarning or bullishTurnArea

upperGrayPower = upperZone and not upperRedZone
lowerGrayPower = lowerZone and not lowerGreenZone

// === MAIN SIGNALS ===
kCrossUp = ta.crossover(k, d)
kCrossDown = ta.crossunder(k, d)

bullTurnSignal = confirmedBar and upTrend and wasOversoldRecently and kCrossUp
bearTurnSignal = confirmedBar and downTrend and wasOverboughtRecently and kCrossDown

pullbackWarningSignal = confirmedBar and upTrend and pullbackWarning
bounceWarningSignal = confirmedBar and downTrend and bounceWarning

// === HOLD SIGNAL STATE ===
barsSinceBullTurn = ta.barssince(bullTurnSignal)
barsSinceBearTurn = ta.barssince(bearTurnSignal)
barsSincePullbackWarning = ta.barssince(pullbackWarningSignal)
barsSinceBounceWarning = ta.barssince(bounceWarningSignal)

bullTurnActive = not na(barsSinceBullTurn) and barsSinceBullTurn < signalHoldBars and upTrend
bearTurnActive = not na(barsSinceBearTurn) and barsSinceBearTurn < signalHoldBars and downTrend
pullbackWarningActive = not na(barsSincePullbackWarning) and barsSincePullbackWarning < signalHoldBars and upTrend
bounceWarningActive = not na(barsSinceBounceWarning) and barsSinceBounceWarning < signalHoldBars and downTrend

// === PLOTS ===
plot(k, "%K - Fast Stoch RSI", color=kColor, linewidth=2)
plot(d, "%D - Signal Line", color=dColor, linewidth=2)

hline(overbought, "Overbought", color=color.new(bearColor, 30))
hline(oversold, "Oversold", color=color.new(bullColor, 30))
hline(midline, "Midline", color=color.new(neutralColor, 50))

upperBase = plot(overbought, "Upper Fill Base", display=display.none)
upperFill = plot(upperZone ? k : na, "Upper Smart Zone", display=display.none)

lowerBase = plot(oversold, "Lower Fill Base", display=display.none)
lowerFill = plot(lowerZone ? k : na, "Lower Smart Zone", display=display.none)

color upperFillColor = color.new(grayZoneColor, grayZoneTransparency)
if upperRedZone
    upperFillColor := color.new(bearColor, redZoneTransparency)

color lowerFillColor = color.new(grayZoneColor, grayZoneTransparency)
if lowerGreenZone
    lowerFillColor := color.new(bullColor, greenZoneTransparency)

if not showSmartZones
    upperFillColor := na
    lowerFillColor := na

fill(upperBase, upperFill, color=upperFillColor)
fill(lowerBase, lowerFill, color=lowerFillColor)

// === SIGNAL LABELS ===
plotshape(showSignals and bullTurnSignal, title="Bullish Turn", text="Bull\nTurn", style=shape.labelup, location=location.bottom, color=bullColor, textcolor=color.black, size=size.tiny)
plotshape(showSignals and bearTurnSignal, title="Bearish Turn", text="Bear\nTurn", style=shape.labeldown, location=location.top, color=bearColor, textcolor=color.white, size=size.tiny)

plotshape(showSignals and pullbackWarningSignal, title="Pullback Warning", text="Pullback\nWarning", style=shape.labeldown, location=location.top, color=bearColor, textcolor=color.white, size=size.tiny)
plotshape(showSignals and bounceWarningSignal, title="Bounce Warning", text="Bounce\nWarning", style=shape.labelup, location=location.bottom, color=bullColor, textcolor=color.black, size=size.tiny)

// === BAR COLORING ===
color barColorValue = na

if showBarColors and bullTurnActive
    barColorValue := color.new(bullColor, 65)

if showBarColors and bearTurnActive
    barColorValue := color.new(bearColor, 65)

if showBarColors and pullbackWarningActive
    barColorValue := color.new(bearColor, 75)

if showBarColors and bounceWarningActive
    barColorValue := color.new(bullColor, 75)

barcolor(barColorValue)

// === READ TABLE LOGIC ===
trendText = "Swing Neutral"
trendColor = neutralColor

if upTrend
    trendText := "Swing Uptrend"
    trendColor := bullColor

if downTrend
    trendText := "Swing Downtrend"
    trendColor := bearColor

zoneText = "Neutral"
zoneColor = neutralColor

if upperGrayPower and upTrend
    zoneText := "Bull Power Zone"
    zoneColor := grayZoneColor

if upperGrayPower and downTrend
    zoneText := "Bounce Still Active"
    zoneColor := grayZoneColor

if lowerGrayPower and downTrend
    zoneText := "Bear Power Zone"
    zoneColor := grayZoneColor

if lowerGrayPower and upTrend
    zoneText := "Pullback Still Active"
    zoneColor := grayZoneColor

if pullbackWarning and upTrend
    zoneText := "Pullback Warning"
    zoneColor := bearColor

if bearishTurnArea and downTrend
    zoneText := "Bearish Turn Area"
    zoneColor := bearColor

if bullishTurnArea and upTrend
    zoneText := "Bullish Turn Area"
    zoneColor := bullColor

if bounceWarning and downTrend
    zoneText := "Bounce Warning"
    zoneColor := bullColor

signalText = "No Clean Signal"
signalColor = neutralColor

if bullTurnActive
    signalText := "Bullish Turn"
    signalColor := bullColor

if bearTurnActive
    signalText := "Bearish Turn"
    signalColor := bearColor

if pullbackWarningActive and not bullTurnActive and not bearTurnActive
    signalText := "Pullback Warning"
    signalColor := bearColor

if bounceWarningActive and not bullTurnActive and not bearTurnActive
    signalText := "Bounce Warning"
    signalColor := bullColor

readText = "Wait"
readColor = neutralColor

if upTrend and upperGrayPower
    readText := "Do Not Fade Strength Yet"
    readColor := grayZoneColor

if downTrend and lowerGrayPower
    readText := "Do Not Buy Weakness Yet"
    readColor := grayZoneColor

if bullTurnActive
    readText := "Momentum Turning Up"
    readColor := bullColor

if bearTurnActive
    readText := "Momentum Turning Down"
    readColor := bearColor

if pullbackWarningActive and upTrend
    readText := "Price May Pull Back"
    readColor := bearColor

if bounceWarningActive and downTrend
    readText := "Price May Bounce"
    readColor := bullColor

if sidewaysTrend
    readText := "Swing Direction Transition"
    readColor := neutralColor

// === TABLE ===
var table readTable = table.new(f_table_pos(tablePosition), 2, 5, border_width=1)

if barstate.islast and showTable
    table.cell(readTable, 0, 0, "Smart Swing Stoch RSI", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)
    table.cell(readTable, 1, 0, "Read", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)

    table.cell(readTable, 0, 1, "Trend", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)
    table.cell(readTable, 1, 1, trendText, bgcolor=color.new(trendColor, 20), text_color=textColor, text_size=tableTextSize)

    table.cell(readTable, 0, 2, "Zone", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)
    table.cell(readTable, 1, 2, zoneText, bgcolor=color.new(zoneColor, 20), text_color=textColor, text_size=tableTextSize)

    table.cell(readTable, 0, 3, "Signal", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)
    table.cell(readTable, 1, 3, signalText, bgcolor=color.new(signalColor, 20), text_color=textColor, text_size=tableTextSize)

    table.cell(readTable, 0, 4, "Interpretation", bgcolor=tableBg, text_color=textColor, text_size=tableTextSize)
    table.cell(readTable, 1, 4, readText, bgcolor=color.new(readColor, 20), text_color=textColor, text_size=tableTextSize)

// === ALERTS ===
alertcondition(bullTurnSignal, title="Bullish Stoch RSI Turn", message="Bullish Stoch RSI turn detected on {{ticker}}")
alertcondition(bearTurnSignal, title="Bearish Stoch RSI Turn", message="Bearish Stoch RSI turn detected on {{ticker}}")
alertcondition(pullbackWarningSignal, title="Pullback Warning", message="Pullback warning detected on {{ticker}}")
alertcondition(bounceWarningSignal, title="Bounce Warning", message="Bounce warning detected on {{ticker}}")
````
