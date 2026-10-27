# Adaptive Multi-Timeframe RSI Divergence

- url: https://www.tradingview.com/script/Nz0tSEg3-Adaptive-Multi-Timeframe-RSI-Divergence/
- type: indicator
- pine_id: PUB;c3522b8857e8455ca14e278e48e19b43
- version: 3.0

## Description

📈 Adaptive Multi-Timeframe RSI Divergence
Brief Description

A multi-timeframe RSI oscillator that combines weighted higher-timeframe momentum, adaptive trend confirmation, divergence detection, and configurable Flip alerts into a unified momentum analysis framework.

📖 Overview

Adaptive Multi-Timeframe RSI Divergence expands the traditional RSI by introducing a Composite RSI calculated from multiple higher timeframes.

Instead of evaluating momentum from a single timeframe, the indicator compares local RSI behavior with broader market momentum while integrating trend confirmation, divergence detection, and adaptive visualization into one oscillator.

The objective is to reduce noise while providing a more reliable interpretation of momentum shifts.

⭐ Key Features
🔹 Composite Multi-Timeframe RSI

• Combines RSI values from three configurable higher timeframes.

• Uses customizable weighting for each timeframe.

• Smooths the result with an EMA to reduce noise.

🔹 Adaptive Trend Detection

Trend changes require multiple confirmation conditions:

✅ RSI crossover

✅ Minimum RSI distance

✅ RSI slope confirmation

✅ Confirmation bars

✅ Deadband filtering

This helps avoid false flips during ranging markets.

🔹 Flip Detection Engine

The Flip Engine confirms bullish and bearish momentum transitions only after all validation rules have been satisfied.

Flip labels and alerts are generated after confirmation rather than immediately at crossover.

🔹 RSI Divergence Detection

Supports:

• Regular Bullish

• Hidden Bullish

• Regular Bearish

• Hidden Bearish

using configurable pivot detection and lookback filtering.

🔹 Dynamic RSI Zones

Highlights active overbought and oversold regions only when RSI enters those zones, improving readability without permanently coloring the oscillator.

🔹 Trend Ribbon

🟢 Green = Confirmed Bullish Momentum

🔴 Red = Confirmed Bearish Momentum

🟣 Purple = Momentum Transition

🔔 Alerts

Includes alert conditions for:

• Bullish Flip

• Bearish Flip

Alerts trigger only after confirmation.

⚙️ Inputs

The script allows customization of:

• RSI Settings

• Composite RSI Timeframes

• Timeframe Weights

• Flip Detection

• Confirmation Rules

• Divergence Settings

📊 How to Interpret

🟢 Bullish Flip

Momentum has shifted toward bullish conditions after confirmation.

🔴 Bearish Flip

Momentum has shifted toward bearish conditions after confirmation.

📈 Composite RSI

Represents weighted higher-timeframe momentum.

📍 Divergences

Highlight potential exhaustion or continuation depending on the divergence type.

🎯 Best Applications

• Swing Trading

• Trend Confirmation

• Momentum Analysis

• Multi-Timeframe Analysis

• Divergence Confirmation

⚠️ Limitations

Like all momentum indicators, this script should be used as a decision-support tool rather than a standalone trading system.

Divergences and momentum shifts may persist before price reacts. Additional confirmation from price action or risk management techniques is recommended.

💡 Originality

Unlike a traditional RSI indicator, this script introduces several original concepts:

✔ Weighted Composite RSI using multiple higher timeframes.

✔ Adaptive trend confirmation using RSI distance, slope, persistence filters, and deadband logic.

✔ Configurable Flip Detection Engine.

✔ Trend-state ribbon.

✔ Integrated divergence detection.

✔ Built-in alert system.

Rather than simply combining existing indicators, the objective is to create a unified momentum framework that filters market noise while providing a broader view of momentum across multiple time horizons.

## Source Code

````pine
//@version=6
indicator(title="Adaptive Multi-Timeframe RSI Divergence", format=format.price, max_labels_count=500, max_boxes_count=500)

// === Inputs ===
len = input.int(title="RSI Period", minval=1, defval=9)
src = input.source(title="RSI Source", defval=high)
lbR = input.int(title="Divergence Pivot Lookback Right", minval=1, defval=5)
lbL = input.int(title="Divergence Pivot Lookback Left", minval=1, defval=5)
rangeUpper = input.int(title="Max of Lookback Range", defval=60)
rangeLower = input.int(title="Min of Lookback Range", defval=5)
plotBull = input.bool(title="Plot Bullish", defval=false)
plotHiddenBull = input.bool(title="Plot Hidden Bullish", defval=false)
plotBear = input.bool(title="Plot Bearish", defval=false)
plotHiddenBear = input.bool(title="Plot Hidden Bearish", defval=false)

// === Market Structure Banners ===
showStructureBanners = input.bool(true, "Show HH / HL / LH / LL Banners")
structureLbR = input.int(1, "Minor Structure Pivot Right", minval=1)
structureLbL = input.int(1, "Minor Structure Pivot Left", minval=1)
bannerSwingSize = input.float(0.0, "Minimum Minor RSI Swing", minval=0.0, step=0.1)
bannerSpacing = input.int(1, "Minimum Bars Between Same-Type Banners", minval=1)

// === Composite RSI Settings ===
showComposite = input.bool(true, title="Show Composite RSI Line")
tf1 = input.timeframe("240", "Composite RSI TF1")
tf2 = input.timeframe("D", "Composite RSI TF2")
tf3 = input.timeframe("W", "Composite RSI TF3")
w1 = input.float(2.0, title="Weight for TF1")
w2 = input.float(3.0, title="Weight for TF2")
w3 = input.float(3.0, title="Weight for TF3")

// === Flip Detection Settings ===
flipDistanceThreshold = input.float(7.0, title="Minimum RSI-Composite Distance for Flip")
rsiSlopeThreshold = input.float(0.4, title="Minimum RSI Slope to Confirm Flip")

// === Tint Strictness ===
tintBand = input.float(0.7, title="Tint Deadband (RSI points)", step=0.1)

// === Fast Tint Confirmation ===
tintSlopeMin = input.float(0.25, title="Min RSI Slope to Switch Tint", step=0.05)

// === Tint Persistency ===
tintConfirmBars = input.int(2, title="Tint Confirmation Bars", minval=1, maxval=10)

// === Flip Banner Confirmation ===
flipConfirmBars = input.int(2, title="Flip Banner Confirmation Bars", minval=1, maxval=10)

// === Colors ===
bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

greenStrong = color.new(color.green, 0)
redStrong = color.new(color.red, 0)
blueStrong = color.new(color.blue, 0)
grayComp = color.new(color.gray, 80)
purpleStrong = color.new(#7802ff, 80)

// Structure colors
hhColor = color.rgb(0, 180, 9)
hlColor = color.rgb(135, 255, 141)
lhColor = color.rgb(255, 200, 0)
llColor = color.rgb(255, 17, 0)
brightGreenSeason = color.new(color.rgb(0, 230, 118), 68)
strongRedSeason = color.new(color.rgb(255, 23, 68), 68)

// === RSI Calculation ===
osc = ta.rsi(src, len)

// === Composite RSI ===
rsi1 = request.security(syminfo.tickerid, tf1, ta.rsi(src, len))
rsi2 = request.security(syminfo.tickerid, tf2, ta.rsi(src, len))
rsi3 = request.security(syminfo.tickerid, tf3, ta.rsi(src, len))
compositeRSI_raw = (w1 * rsi1 + w2 * rsi2 + w3 * rsi3) / (w1 + w2 + w3)
compositeRSI = ta.ema(compositeRSI_raw, 3)

// === RSI Color Tint on Crossover Only ===
crossUp = ta.crossover(osc, compositeRSI)
crossDown = ta.crossunder(osc, compositeRSI)
rsiColor = crossUp ? greenStrong : crossDown ? redStrong : blueStrong
plot(osc, title="RSI", linewidth=2, color=rsiColor)
plot(showComposite ? compositeRSI : na, title="Composite RSI", color=grayComp, linewidth=2)

// === Flip Detection Logic ===
rsiSlope = osc - osc[1]
flipUp = crossUp and math.abs(osc - compositeRSI) >= flipDistanceThreshold and rsiSlope >= rsiSlopeThreshold
flipDown = crossDown and math.abs(osc - compositeRSI) >= flipDistanceThreshold and rsiSlope <= -rsiSlopeThreshold

// === Trend Tint Tracking ===
var string lastTint = na
var int lastCrossBar = na

wantGreen = osc > compositeRSI + tintBand
wantRed = osc < compositeRSI - tintBand

greenOk = wantGreen and rsiSlope >= tintSlopeMin
redOk = wantRed and rsiSlope <= -tintSlopeMin

greenConfirmed = true
redConfirmed = true
for i = 0 to tintConfirmBars - 1
    greenConfirmed := greenConfirmed and greenOk[i]
    redConfirmed := redConfirmed and redOk[i]

if greenConfirmed and lastTint != "green"
    lastTint := "green"
    lastCrossBar := bar_index
else if redConfirmed and lastTint != "red"
    lastTint := "red"
    lastCrossBar := bar_index

// === Flip Feature: FIRST BAR of Tint Change ===
flipUpEvent = lastTint == "green" and lastTint[1] == "red"
flipDownEvent = lastTint == "red" and lastTint[1] == "green"

bullFlipBanner = flipUpEvent
bearFlipBanner = flipDownEvent
flipWarning = bullFlipBanner or bearFlipBanner

// === Ribbon Between 30-70 Only ===
baseLow = plot(30, title="Ribbon Bottom", color=color.new(color.white, 100))
baseHigh = plot(70, title="Ribbon Top", color=color.new(color.white, 100))

fillColor = flipWarning ? purpleStrong : lastTint == "green" ? color.new(color.green, 85) : lastTint == "red" ? color.new(color.red, 85) : na
fill(baseHigh, baseLow, color=fillColor, title="Trend Ribbon")

// === Flip Warning Labels ===
if bullFlipBanner
    label.new(
         bar_index,
         30,
         "Flip Up",
         style=label.style_label_up,
         color=color.new(#ab2ac2, 40),
         textcolor=color.white,
         size=size.small)

if bearFlipBanner
    label.new(
         bar_index,
         70,
         "Flip Down",
         style=label.style_label_down,
         color=color.new(#ab2ac2, 40),
         textcolor=color.white,
         size=size.small)

// === RSI Zones ===
hline(50, title="Middle Line", color=#787B86, linestyle=hline.style_dotted)
hline(70, title="Overbought", color=#787B86, linestyle=hline.style_dotted)
hline(30, title="Oversold", color=#787B86, linestyle=hline.style_dotted)

// === Dynamic Fill Zones ===
greenZone = osc >= 70 ? osc : na
redZone = osc <= 30 ? osc : na
plotGreen = plot(greenZone, title="Dynamic Overbought", color=color.new(color.green, 100))
plotRed = plot(redZone, title="Dynamic Oversold", color=color.new(color.red, 100))
plot30 = plot(30, title="30 Fill", color=color.new(color.white, 100))
plot70 = plot(70, title="70 Fill", color=color.new(color.white, 100))
fill(plotGreen, plot70, color=color.new(color.green, 80))
fill(plotRed, plot30, color=color.new(color.red, 80))

// =============================================================================
// Minor RSI Market Structure: HH / HL / LH / LL
// =============================================================================

// The structure detector defaults to 1/1 pivots so nearly every genuine RSI
// turn is classified internally. The visible labels are reduced to the
// dominant, trend-aligned structure of each tint season.
minorHighPivot = ta.pivothigh(osc, structureLbL, structureLbR)
minorLowPivot = ta.pivotlow(osc, structureLbL, structureLbR)
minorHighFound = not na(minorHighPivot)
minorLowFound = not na(minorLowPivot)

prevMinorHigh = ta.valuewhen(minorHighFound, minorHighPivot, 1)
prevMinorLow = ta.valuewhen(minorLowFound, minorLowPivot, 1)

minorHighSwingOk = minorHighFound and not na(prevMinorHigh) and math.abs(minorHighPivot - prevMinorHigh) >= bannerSwingSize
minorLowSwingOk = minorLowFound and not na(prevMinorLow) and math.abs(minorLowPivot - prevMinorLow) >= bannerSwingSize

var int lastMinorHighBar = na
var int lastMinorLowBar = na

minorHighBar = bar_index - structureLbR
minorLowBar = bar_index - structureLbR

allowMinorHigh = na(lastMinorHighBar) or minorHighBar - lastMinorHighBar >= bannerSpacing
allowMinorLow = na(lastMinorLowBar) or minorLowBar - lastMinorLowBar >= bannerSpacing

minorHighEvent = minorHighSwingOk and allowMinorHigh
minorLowEvent = minorLowSwingOk and allowMinorLow

hhEvent = minorHighEvent and minorHighPivot > prevMinorHigh
lhEvent = minorHighEvent and minorHighPivot <= prevMinorHigh
hlEvent = minorLowEvent and minorLowPivot >= prevMinorLow
llEvent = minorLowEvent and minorLowPivot < prevMinorLow

if minorHighEvent
    lastMinorHighBar := minorHighBar

if minorLowEvent
    lastMinorLowBar := minorLowBar

// A pivot is assigned to the tint that was active on its actual pivot bar.
pivotTint = lastTint[structureLbR]
tintSeasonChanged = flipUpEvent or flipDownEvent

var label seasonHHLabel = na
var label seasonHLLabel = na
var label seasonLHLabel = na
var label seasonLLLabel = na
var float seasonHHValue = na
var float seasonLLValue = na

bool hhSeasonEvent = false
bool hlSeasonEvent = false
bool lhSeasonEvent = false
bool llSeasonEvent = false

// Green season: keep only its highest HH and latest protected HL.
if hhEvent and pivotTint == "green" and (na(seasonHHValue) or minorHighPivot > seasonHHValue)
    hhSeasonEvent := true
    seasonHHValue := minorHighPivot
    if showStructureBanners
        if not na(seasonHHLabel)
            label.delete(seasonHHLabel)
        seasonHHLabel := label.new(
             minorHighBar,
             minorHighPivot,
             "HH",
             style=label.style_label_down,
             textcolor=color.white,
             color=hhColor,
             size=size.tiny)

if hlEvent and pivotTint == "green"
    hlSeasonEvent := true
    if showStructureBanners
        if not na(seasonHLLabel)
            label.delete(seasonHLLabel)
        seasonHLLabel := label.new(
             minorLowBar,
             minorLowPivot,
             "HL",
             style=label.style_label_up,
             textcolor=color.black,
             color=hlColor,
             size=size.tiny)

// Red season: keep only its lowest LL and latest protected LH.
if llEvent and pivotTint == "red" and (na(seasonLLValue) or minorLowPivot < seasonLLValue)
    llSeasonEvent := true
    seasonLLValue := minorLowPivot
    if showStructureBanners
        if not na(seasonLLLabel)
            label.delete(seasonLLLabel)
        seasonLLLabel := label.new(
             minorLowBar,
             minorLowPivot,
             "LL",
             style=label.style_label_up,
             textcolor=color.white,
             color=llColor,
             size=size.tiny)

if lhEvent and pivotTint == "red"
    lhSeasonEvent := true
    if showStructureBanners
        if not na(seasonLHLabel)
            label.delete(seasonLHLabel)
        seasonLHLabel := label.new(
             minorHighBar,
             minorHighPivot,
             "LH",
             style=label.style_label_down,
             textcolor=color.black,
             color=lhColor,
             size=size.tiny)

// A pivot detected on the tint-flip bar belongs to the previous bar's season.
// Reset references only after processing it. Previous seasons' final labels
// remain on the chart, while the new season starts with empty slots.
if tintSeasonChanged
    seasonHHLabel := na
    seasonHLLabel := na
    seasonLHLabel := na
    seasonLLLabel := na
    seasonHHValue := na
    seasonLLValue := na

// =============================================================================
// Adaptive Season Strength Background
//
// The regular green/red ribbon remains the normal-strength base layer.
// A stronger box overlays the advancing portion of each tint season:
//
// Green: after Flip Up through the latest dominant HH.
// Red:   after Flip Down through the latest dominant LL.
//
// When a newer HH/LL appears, the active box expands retroactively to that
// pivot. At the opposite flip, the completed season box is frozen.
// =============================================================================

greenSeasonStart =
     lastTint == "green" and
     (na(lastTint[1]) or lastTint[1] != "green")

redSeasonStart =
     lastTint == "red" and
     (na(lastTint[1]) or lastTint[1] != "red")

var box activeStrongSeasonBox = na
var string activeStrongSeasonTint = na
var int activeStrongSeasonStartTime = na
var int activeStrongSeasonExtremeTime = na
var float activeStrongSeasonExtremeValue = na

minorHighTime = time[structureLbR]
minorLowTime = time[structureLbR]
minorHighCloseTime = time_close[structureLbR]
minorLowCloseTime = time_close[structureLbR]
currentBarCloseTime = na(time_close) ? time : time_close
currentBarHalfMs = int((currentBarCloseTime - time) / 2)
minorHighHalfMs = int((minorHighCloseTime - minorHighTime) / 2)
minorLowHalfMs = int((minorLowCloseTime - minorLowTime) / 2)
currentBarLeftEdgeTime = time - currentBarHalfMs
currentBarRightEdgeTime = time + currentBarHalfMs
minorHighRightEdgeTime = minorHighTime + minorHighHalfMs
minorLowRightEdgeTime = minorLowTime + minorLowHalfMs

// First let a pivot confirmed on the flip bar update the season it actually
// belongs to. The season-label events already use the tint of the pivot bar.
if activeStrongSeasonTint == "green" and hhSeasonEvent and minorHighRightEdgeTime >= activeStrongSeasonStartTime
    activeStrongSeasonExtremeTime := minorHighRightEdgeTime
    activeStrongSeasonExtremeValue := minorHighPivot
    if not na(activeStrongSeasonBox)
        box.set_right(activeStrongSeasonBox, activeStrongSeasonExtremeTime)

if activeStrongSeasonTint == "red" and llSeasonEvent and minorLowRightEdgeTime >= activeStrongSeasonStartTime
    activeStrongSeasonExtremeTime := minorLowRightEdgeTime
    activeStrongSeasonExtremeValue := minorLowPivot
    if not na(activeStrongSeasonBox)
        box.set_right(activeStrongSeasonBox, activeStrongSeasonExtremeTime)

// Freeze the prior box by dropping its active reference, then initialize the
// new season. Explicit purple flip bars are excluded from the strong box.
if greenSeasonStart
    activeStrongSeasonBox := na
    activeStrongSeasonTint := "green"
    activeStrongSeasonStartTime := flipUpEvent ? currentBarRightEdgeTime : currentBarLeftEdgeTime
    activeStrongSeasonExtremeTime := na
    activeStrongSeasonExtremeValue := na

if redSeasonStart
    activeStrongSeasonBox := na
    activeStrongSeasonTint := "red"
    activeStrongSeasonStartTime := flipDownEvent ? currentBarRightEdgeTime : currentBarLeftEdgeTime
    activeStrongSeasonExtremeTime := na
    activeStrongSeasonExtremeValue := na

// After the first confirmed seasonal HH/LL, extend the strong background the
// instant RSI moves beyond that value, including on the live bar. The future
// pivot is label confirmation only, not the background trigger. If the live
// bar retreats before closing, this provisional background can repaint back.
developingHH =
     activeStrongSeasonTint == "green" and
     lastTint == "green" and
     not na(activeStrongSeasonExtremeValue) and
     osc > activeStrongSeasonExtremeValue

developingLL =
     activeStrongSeasonTint == "red" and
     lastTint == "red" and
     not na(activeStrongSeasonExtremeValue) and
     osc < activeStrongSeasonExtremeValue

if developingHH
    activeStrongSeasonExtremeValue := osc
    activeStrongSeasonExtremeTime := currentBarRightEdgeTime

if developingLL
    activeStrongSeasonExtremeValue := osc
    activeStrongSeasonExtremeTime := currentBarRightEdgeTime

// Create and maintain the single active overlay. Before the first dominant
// extreme it grows with every bar. Afterward it ends at the latest HH/LL until
// a stronger seasonal extreme extends it again.
activeSeasonReady =
     not na(activeStrongSeasonStartTime) and
     time >= activeStrongSeasonStartTime and
     lastTint == activeStrongSeasonTint

if activeSeasonReady
    activeStrongColor =
         activeStrongSeasonTint == "green" ?
         brightGreenSeason :
         strongRedSeason

    activeStrongRight =
         na(activeStrongSeasonExtremeTime) ?
         currentBarRightEdgeTime :
         activeStrongSeasonExtremeTime

    if na(activeStrongSeasonBox)
        activeStrongSeasonBox := box.new(
             left=activeStrongSeasonStartTime,
             top=70.0,
             right=activeStrongRight,
             bottom=30.0,
             xloc=xloc.bar_time,
             border_color=color.new(color.white, 100),
             bgcolor=activeStrongColor)
    else
        box.set_right(activeStrongSeasonBox, activeStrongRight)
        box.set_bgcolor(activeStrongSeasonBox, activeStrongColor)

// === Divergence Helper ===
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

plFound = not na(ta.pivotlow(osc, lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1)
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
priceRsiBullishDiv = oscHL and priceLL and plFound
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1)
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1)

// === Divergence Plotting ===
// Regular Bullish
inRangePl = _inRange(plFound[1])
bullCond = plotBull and priceLL and oscHL and plFound
plot(plFound ? osc[lbR] : na, offset=-lbR, linewidth=2, color=bullCond ? bullColor : noneColor)
plotshape(
     bullCond ? osc[lbR] : na,
     offset=-lbR,
     text=" Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor)

// Hidden Bullish
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound
plot(plFound ? osc[lbR] : na, offset=-lbR, linewidth=2, color=hiddenBullCond ? hiddenBullColor : noneColor)
plotshape(
     hiddenBullCond ? osc[lbR] : na,
     offset=-lbR,
     text=" H Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor)

// Regular Bearish
inRangePh = _inRange(phFound[1])
bearCond = plotBear and priceHH and oscLH and phFound
plot(phFound ? osc[lbR] : na, offset=-lbR, linewidth=2, color=bearCond ? bearColor : noneColor)
plotshape(
     bearCond ? osc[lbR] : na,
     offset=-lbR,
     text=" Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor)

// Hidden Bearish
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound
plot(phFound ? osc[lbR] : na, offset=-lbR, linewidth=2, color=hiddenBearCond ? hiddenBearColor : noneColor)
plotshape(
     hiddenBearCond ? osc[lbR] : na,
     offset=-lbR,
     text=" H Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor)

// =============================================================================
// ALERT CONDITIONS
// =============================================================================

alertcondition(
     bullFlipBanner,
     title="Flip Up Banner",
     message="Flip Up banner triggered on {{ticker}} - {{interval}}")

alertcondition(
     bearFlipBanner,
     title="Flip Down Banner",
     message="Flip Down banner triggered on {{ticker}} - {{interval}}")

alertcondition(
     hhSeasonEvent,
     title="RSI Season Higher High",
     message="RSI season Higher High (HH) detected on {{ticker}} - {{interval}}")

alertcondition(
     hlSeasonEvent,
     title="RSI Season Higher Low",
     message="RSI season Higher Low (HL) detected on {{ticker}} - {{interval}}")

alertcondition(
     lhSeasonEvent,
     title="RSI Season Lower High",
     message="RSI season Lower High (LH) detected on {{ticker}} - {{interval}}")

alertcondition(
     llSeasonEvent,
     title="RSI Season Lower Low",
     message="RSI season Lower Low (LL) detected on {{ticker}} - {{interval}}")

// May God bless all your investments and trades!
// Proverbs 13:22: "The wealth of the sinner is laid up for the righteous."
````
