# Volume Spike Levels

- url: https://www.tradingview.com/script/KMK2bw3W-Volume-Spike-Levels/
- type: indicator
- pine_id: PUB;50bc8414396543e1a2c60b8c011441a3
- version: 4.0

## Description

Volume Spike Levels detects abnormal volume candles, draws their price range as boxes or levels, and confirms whether the volume was resolved upward or downward.
-----------------------------------------------------------------------------------------------------

Volume Spike Levels is a clean volume spike indicator designed for visual price action analysis and intraday scalping.

Unlike a basic volume spike indicator that only places a marker on the candle where abnormal volume appears, this script first detects a volume spike candle and then draws the full price range of that candle as a box or horizontal levels.

The idea is simple:
when unusual volume appears, the range of that candle becomes important. Instead of only marking the volume candle, the indicator watches how price behaves around that range afterward.

If price breaks and confirms above the volume spike range, the indicator can mark it as VOL BUY.
If price breaks and confirms below the volume spike range, the indicator can mark it as VOL SELL.

This makes it easier to see whether the volume was actually absorbed, continued, inverted, or used as a reaction zone.

The indicator has two main marker modes:

Confirmed Direction mode:
The box or levels are drawn when the volume spike appears, but the directional marker appears only later, after price confirms above or below the spike range. Confirmation can be based on Wick, Body, or Close, depending on your settings.

Neutral Fast mode:
The indicator marks the volume spike immediately with a neutral marker. In this mode, the trader visually decides the direction based on price action around the box or levels.

Level display options:
You can display the volume spike range as a box, horizontal high/low levels, both, or turn the levels off and use markers only.

Volume strength:
The script supports weak, medium, and strong volume spike thresholds. These settings should be adjusted for your broker, symbol, and timeframe.

The screenshot shows XAUUSD on the 5-minute chart. The example settings were adjusted for OANDA gold data:
Weak Spike Multiplier: 1.9
Medium Spike Multiplier: 2.2
Strong Spike Multiplier: 3.0

Because volume data can differ between brokers and instruments, you should tune these multipliers so the number of signals on your chart feels useful and not overcrowded.

Alerts:
The indicator includes alerts for neutral volume spikes, bullish confirmed volume spikes, bearish confirmed volume spikes, and strong volume spikes only.

This tool can be useful for scalping, intraday trading, reaction zones, volume absorption, and identifying when volume appears in one area but price later confirms in the opposite direction.

## Source Code

````pine
//@version=6
// Volume Spike Levels [josseliani]
// © 2026 josseliani
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Volume-burst signal logic:
// - every qualifying volume spike is drawn normally;
// - one active burst tracks the most concentrated spike candle;
// - concentration = relative volume / relative candle-body size;
// - weaker concentration does not overwrite the active trigger candle;
// - the burst ends on trigger-candle breakout or after the confirmation timeout.
// LTF POC remains visual-only and does not affect BUY/SELL logic.

indicator("Volume Spike Levels [josseliani]", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=100)

// ==========================

// Inputs

// ==========================

groupVolume = "Volume Spike"

volLength = input.int(20, "Volume Average Length", minval=2, group=groupVolume)

strengthMode = input.string("Graded", "Strength Mode", options=["Fixed", "Graded"], group=groupVolume)

weakMult = input.float(1.5, "Weak Spike Multiplier", step=0.1, minval=0.1, group=groupVolume)

mediumMult = input.float(2.0, "Medium Spike Multiplier", step=0.1, minval=0.1, group=groupVolume)

strongMult = input.float(3.0, "Strong Spike Multiplier", step=0.1, minval=0.1, group=groupVolume)

showVolumeRatio = input.bool(true, "Show Volume Ratio", group=groupVolume, tooltip="Shows each confirmed volume spike as a multiple of its moving-average volume, e.g. 2.7×.")
volumeRatioColor = input.color(color.rgb(95, 140, 210), "Volume Ratio Text Color", group=groupVolume)

groupPoc = "Visual LTF POC"
showLtfPoc = input.bool(true, "Show LTF POC", group=groupPoc, tooltip="Displays an estimated Point of Control inside qualifying volume-spike candles using lower-timeframe OHLCV data. Visual only: it does not affect BUY/SELL logic.")
pocRangeMode = input.string("Auto (ATR)", "POC Range Filter", options=["Auto (ATR)", "Manual Price Range"], group=groupPoc)
pocMinAtr = input.float(2.0, "Min Range, ATR Multiplier", minval=0.5, step=0.5, group=groupPoc, tooltip="Used in Auto (ATR) mode. Lower values show POC on more spike candles.")
pocMinRangePrice = input.float(10.0, "Min Range, Manual Price", minval=0.0, step=0.0001, group=groupPoc, tooltip="Used in Manual Price Range mode. Example: 10.0 on XAUUSD or 0.0010 on EURUSD.")
pocTfMode = input.string("Auto", "POC Lower Timeframe", options=["Auto", "Custom"], group=groupPoc)
customPocTf = input.timeframe("1", "Custom Lower Timeframe", group=groupPoc)
pocColor = input.color(color.rgb(70, 140, 255), "POC Color", group=groupPoc)
pocWidth = input.int(2, "POC Width", minval=1, maxval=4, group=groupPoc)
pocLengthMode = input.string("Same as Box / Lines", "POC Length Mode", options=["Same as Box / Lines", "Custom"], group=groupPoc)
pocLengthBars = input.int(20, "POC Length, Bars", minval=1, maxval=500, group=groupPoc, tooltip="Used only when POC Length Mode is Custom.")

groupMarkers = "Markers"

markerMode = input.string("Confirmed Direction", "Marker Mode", options=["Neutral Fast", "Confirmed Direction"], group=groupMarkers, tooltip="Confirmed Direction waits for price to confirm above or below the spike range. Neutral Fast marks the volume spike immediately without assigning direction.")

neutralColor = input.color(color.orange, "Neutral Marker Color", group=groupMarkers)

bullColor = input.color(color.lime, "Bullish Marker Color", group=groupMarkers)

bearColor = input.color(color.red, "Bearish Marker Color", group=groupMarkers)

weakOpacity = input.int(30, "Weak Marker Opacity", minval=0, maxval=100, step=5, group=groupMarkers)

mediumOpacity = input.int(65, "Medium Marker Opacity", minval=0, maxval=100, step=5, group=groupMarkers)

strongOpacity = input.int(100, "Strong Marker Opacity", minval=0, maxval=100, step=5, group=groupMarkers)

showSignalLabels = input.bool(false, "Show VOL BUY / VOL SELL Text", group=groupMarkers)

groupConfirm = "Direction Confirmation"

confirmBars = input.int(8, "Confirmation Window, Bars", minval=1, maxval=200, group=groupConfirm, tooltip="Number of bars after a volume spike during which the indicator waits for directional confirmation.")

confirmMode = input.string("Body", "Direction Confirmation Mode", options=["Wick", "Body", "Close"], group=groupConfirm, tooltip="Defines how price must break the spike range to confirm direction: Wick, candle Body, or Close.")

groupLevels = "Spike Levels"

levelDisplayMode = input.string("Box", "Level Display Mode", options=["Off", "Box", "Horizontal Lines", "Both"], group=groupLevels)

levelsToKeep = input.int(3, "Number of Recent Spikes to Keep", minval=1, maxval=20, group=groupLevels)

levelLengthBars = input.int(20, "Box / Line Length, Bars", minval=1, maxval=500, group=groupLevels)

extendLinesRight = input.bool(true, "Extend Horizontal Lines Right", group=groupLevels)

boxColor = input.color(color.new(color.orange, 88), "Box Color", group=groupLevels)

highLineColor = input.color(color.new(color.red, 20), "High Level Color", group=groupLevels)

lowLineColor = input.color(color.new(color.orange, 20), "Low Level Color", group=groupLevels)

// ==========================

// Helpers

// ==========================

applyOpacity(baseColor, opacity) =>

    baseOpacity = 100 - color.t(baseColor)

    finalOpacity = baseOpacity * opacity / 100

    color.new(baseColor, 100 - finalOpacity)

autoPocTf() =>
    float chartSeconds = timeframe.in_seconds()
    string result = "60"
    if chartSeconds <= 10
        result := "1S"
    else if chartSeconds <= 15
        result := "5S"
    else if chartSeconds <= 30
        result := "15S"
    else if chartSeconds < 60
        result := "15S"
    else if chartSeconds <= 15 * 60
        result := "1"
    else if chartSeconds <= 30 * 60
        result := "5"
    else if chartSeconds <= 60 * 60
        result := "10"
    else if chartSeconds <= 120 * 60
        result := "15"
    else if chartSeconds <= 240 * 60
        result := "30"
    else
        result := "60"
    result

calcLtfPoc(array<float> intrabarHighs, array<float> intrabarLows, array<float> intrabarVolumes, float rangeLow, float rangeHigh) =>
    int rows = 24
    float poc = na
    int n = math.min(array.size(intrabarHighs), math.min(array.size(intrabarLows), array.size(intrabarVolumes)))
    float fullRange = rangeHigh - rangeLow
    if n > 0 and fullRange > 0
        float rowSize = fullRange / rows
        array<float> bins = array.new_float(rows, 0.0)
        for i = 0 to n - 1
            float h = array.get(intrabarHighs, i)
            float l = array.get(intrabarLows, i)
            float v = array.get(intrabarVolumes, i)
            if not na(h) and not na(l) and not na(v) and v > 0
                float clippedHigh = math.min(h, rangeHigh)
                float clippedLow = math.max(l, rangeLow)
                float span = clippedHigh - clippedLow
                if span <= 0
                    float pricePoint = math.max(rangeLow, math.min(rangeHigh, (h + l) * 0.5))
                    int idx = int(math.floor((pricePoint - rangeLow) / rowSize))
                    idx := math.max(0, math.min(rows - 1, idx))
                    array.set(bins, idx, array.get(bins, idx) + v)
                else
                    int firstRow = int(math.floor((clippedLow - rangeLow) / rowSize))
                    int lastRow = int(math.floor((clippedHigh - rangeLow) / rowSize))
                    firstRow := math.max(0, math.min(rows - 1, firstRow))
                    lastRow := math.max(0, math.min(rows - 1, lastRow))
                    if firstRow <= lastRow
                        for row = firstRow to lastRow
                            float rowBottom = rangeLow + row * rowSize
                            float rowTop = rowBottom + rowSize
                            float overlap = math.max(0.0, math.min(clippedHigh, rowTop) - math.max(clippedLow, rowBottom))
                            if overlap > 0
                                float allocatedVolume = v * overlap / span
                                array.set(bins, row, array.get(bins, row) + allocatedVolume)
        float maxVol = -1.0
        int pocRow = 0
        for row = 0 to rows - 1
            float rowVol = array.get(bins, row)
            if rowVol > maxVol
                maxVol := rowVol
                pocRow := row
        if maxVol >= 0
            poc := rangeLow + (pocRow + 0.5) * rowSize
    poc

// ==========================

// Core calculations

// ==========================

volAvg = ta.sma(volume, volLength)

atrValue = ta.atr(14)

volTextColor = color.rgb(70, 140, 255)

volTextOffsetAtr = 1.7

isFixed = strengthMode == "Fixed"

isGraded = strengthMode == "Graded"

fixedSpike = isFixed and volume >= volAvg * weakMult

strongSpike = isGraded and volume >= volAvg * strongMult

mediumSpike = isGraded and not strongSpike and volume >= volAvg * mediumMult

weakSpike = isGraded and not mediumSpike and not strongSpike and volume >= volAvg * weakMult

volSpike = fixedSpike or weakSpike or mediumSpike or strongSpike

strongVolumeEvent = volume >= volAvg * strongMult

currentStrength = strongSpike ? 3 : mediumSpike ? 2 : volSpike ? 1 : 0

volRatio = not na(volAvg) and volAvg > 0 ? volume / volAvg : na

// Concentration score: high relative volume packed into a small candle body ranks higher.
// The 0.25 floor prevents doji-like bodies from producing an infinite/unstable score.
bodySize = math.abs(close - open)
avgBodySize = ta.sma(bodySize, volLength)
relativeBodySize = not na(avgBodySize) and avgBodySize > 0 ? bodySize / avgBodySize : na
float BODY_SIZE_FLOOR = 0.25
volumeConcentration = not na(volRatio) and not na(relativeBodySize) ? volRatio / math.max(relativeBodySize, BODY_SIZE_FLOOR) : na

string selectedPocTf = pocTfMode == "Auto" ? autoPocTf() : customPocTf
[ltfHighs, ltfLows, ltfVolumes] = request.security_lower_tf(syminfo.tickerid, selectedPocTf, [high, low, volume], ignore_invalid_timeframe=true)

// ==========================

// Storage

// ==========================

var int lastCreatedSpikeBar = na

// One active volume-burst event. Its trigger candle is the most concentrated
// qualifying spike found since the burst started.
var float activeSpikeHigh = na
var float activeSpikeLow = na
var int activeSpikeBar = na
var int activeSpikeStrength = na
var float activeSpikeConcentration = na
var int activeEventLastSpikeBar = na
var bool activeSpike = false
var bool activeSpikeTriggered = false

var box[] spikeBoxes = array.new_box()
var line[] spikeHighLines = array.new_line()
var line[] spikeLowLines = array.new_line()
var label[] signalLabels = array.new_label()
var label[] ratioLabels = array.new_label()
var line[] pocLines = array.new_line()

// ==========================

// Visual level creation
// Every qualifying spike keeps its own box/lines. This is independent from
// which spike candle is currently selected as the signal trigger.

// ==========================

levelEvent = volSpike

if levelEvent and (na(lastCreatedSpikeBar) or bar_index != lastCreatedSpikeBar)
    lastCreatedSpikeBar := bar_index

    if levelDisplayMode == "Box" or levelDisplayMode == "Both"
        newBox = box.new(left=bar_index, top=high, right=bar_index + levelLengthBars, bottom=low, bgcolor=boxColor, border_color=boxColor)
        array.push(spikeBoxes, newBox)

    if levelDisplayMode == "Horizontal Lines" or levelDisplayMode == "Both"
        newHighLine = line.new(x1=bar_index, y1=high, x2=bar_index + levelLengthBars, y2=high, extend=extendLinesRight ? extend.right : extend.none, color=highLineColor, width=1, style=line.style_solid)
        newLowLine = line.new(x1=bar_index, y1=low, x2=bar_index + levelLengthBars, y2=low, extend=extendLinesRight ? extend.right : extend.none, color=lowLineColor, width=1, style=line.style_solid)
        array.push(spikeHighLines, newHighLine)
        array.push(spikeLowLines, newLowLine)

    while array.size(spikeBoxes) > levelsToKeep
        oldBox = array.shift(spikeBoxes)
        box.delete(oldBox)

    while array.size(spikeHighLines) > levelsToKeep
        oldHighLine = array.shift(spikeHighLines)
        line.delete(oldHighLine)

    while array.size(spikeLowLines) > levelsToKeep
        oldLowLine = array.shift(spikeLowLines)
        line.delete(oldLowLine)

// Preserve the original visual behavior while the current spike candle is forming.
if not na(lastCreatedSpikeBar) and bar_index == lastCreatedSpikeBar and not barstate.isconfirmed
    if array.size(spikeBoxes) > 0
        lastBox = array.get(spikeBoxes, array.size(spikeBoxes) - 1)
        box.set_top(lastBox, high)
        box.set_bottom(lastBox, low)

    if array.size(spikeHighLines) > 0
        lastHighLine = array.get(spikeHighLines, array.size(spikeHighLines) - 1)
        line.set_y1(lastHighLine, high)
        line.set_y2(lastHighLine, high)

    if array.size(spikeLowLines) > 0
        lastLowLine = array.get(spikeLowLines, array.size(spikeLowLines) - 1)
        line.set_y1(lastLowLine, low)
        line.set_y2(lastLowLine, low)

// ==========================

// Volume ratio labels + visual-only LTF POC

// ==========================

if showVolumeRatio and volSpike and barstate.isconfirmed and not na(volRatio)
    ratioLabel = label.new(bar_index, high, str.tostring(volRatio, "#.0") + "×", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_none, textcolor=volumeRatioColor, size=size.tiny)
    array.push(ratioLabels, ratioLabel)

while array.size(ratioLabels) > 150
    oldRatioLabel = array.shift(ratioLabels)
    label.delete(oldRatioLabel)

if showLtfPoc and volSpike and barstate.isconfirmed
    float spikeRange = high - low
    float minPocRange = pocRangeMode == "Auto (ATR)" ? atrValue * pocMinAtr : pocMinRangePrice
    if spikeRange >= minPocRange
        float spikePoc = calcLtfPoc(ltfHighs, ltfLows, ltfVolumes, low, high)
        if not na(spikePoc)
            int effectivePocLength = pocLengthMode == "Same as Box / Lines" ? levelLengthBars : pocLengthBars
            pocLine = line.new(x1=bar_index, y1=spikePoc, x2=bar_index + effectivePocLength, y2=spikePoc, extend=extend.none, color=pocColor, width=pocWidth, style=line.style_dotted)
            array.push(pocLines, pocLine)

while array.size(pocLines) > levelsToKeep
    oldPocLine = array.shift(pocLines)
    line.delete(oldPocLine)

// ==========================

// Direction confirmation for the selected concentrated spike

// ==========================

bodyLow = math.min(open, close)
bodyHigh = math.max(open, close)

bullWickBreak = activeSpike and high > activeSpikeHigh
bearWickBreak = activeSpike and low < activeSpikeLow
bullBodyBreak = activeSpike and bodyHigh > activeSpikeHigh
bearBodyBreak = activeSpike and bodyLow < activeSpikeLow
bullCloseBreak = activeSpike and close > activeSpikeHigh
bearCloseBreak = activeSpike and close < activeSpikeLow

bullBreak = confirmMode == "Wick" ? bullWickBreak : confirmMode == "Body" ? bullBodyBreak : bullCloseBreak
bearBreak = confirmMode == "Wick" ? bearWickBreak : confirmMode == "Body" ? bearBodyBreak : bearCloseBreak

// Wick can confirm live; Body and Close only on a completed bar.
confirmationReady = confirmMode == "Wick" or barstate.isconfirmed

// Timeout is measured from the MOST RECENT qualifying spike in the burst, not
// from the original trigger candle. New spikes therefore keep a live burst alive.
eventExpired = activeSpike and not na(activeEventLastSpikeBar) and bar_index - activeEventLastSpikeBar > confirmBars
if eventExpired and barstate.isconfirmed
    activeSpike := false
    activeSpikeTriggered := false
    activeSpikeConcentration := na
    activeEventLastSpikeBar := na

directionalMarker = markerMode == "Confirmed Direction" and confirmationReady and activeSpike and not activeSpikeTriggered and bar_index > activeSpikeBar
bullMarker = directionalMarker and bullBreak
bearMarker = directionalMarker and bearBreak

burstEndedThisBar = bullMarker or bearMarker

if burstEndedThisBar
    activeSpikeTriggered := true
    activeSpike := false
    activeSpikeConcentration := na
    activeEventLastSpikeBar := na

// ==========================

// Volume-burst candidate selection
// Process only CLOSED spike candles so Replay speed cannot change which candle
// wins. A spike bar that itself confirmed the previous burst is not reused as
// the first candle of a new burst.

// ==========================

confirmedSpike = volSpike and barstate.isconfirmed

if confirmedSpike and not burstEndedThisBar and not na(volumeConcentration)
    if not activeSpike
        activeSpikeHigh := high
        activeSpikeLow := low
        activeSpikeBar := bar_index
        activeSpikeStrength := currentStrength
        activeSpikeConcentration := volumeConcentration
        activeEventLastSpikeBar := bar_index
        activeSpike := true
        activeSpikeTriggered := false
    else
        // Every qualifying spike extends the current burst lifetime.
        activeEventLastSpikeBar := bar_index

        // Replace the trigger candle only when volume is more concentrated
        // relative to its body size. Example: 6× volume in a tiny body can beat
        // 11× volume in a very large body.
        if na(activeSpikeConcentration) or volumeConcentration > activeSpikeConcentration
            activeSpikeHigh := high
            activeSpikeLow := low
            activeSpikeBar := bar_index
            activeSpikeStrength := currentStrength
            activeSpikeConcentration := volumeConcentration

// Marker colors

// ==========================

neutralWeakColor = applyOpacity(neutralColor, weakOpacity)

neutralMediumColor = applyOpacity(neutralColor, mediumOpacity)

neutralStrongColor = applyOpacity(neutralColor, strongOpacity)

bullWeakColor = applyOpacity(bullColor, weakOpacity)

bullMediumColor = applyOpacity(bullColor, mediumOpacity)

bullStrongColor = applyOpacity(bullColor, strongOpacity)

bearWeakColor = applyOpacity(bearColor, weakOpacity)

bearMediumColor = applyOpacity(bearColor, mediumOpacity)

bearStrongColor = applyOpacity(bearColor, strongOpacity)

// ==========================

// Neutral Fast markers on volume spike candle

// ==========================

neutralMarker = markerMode == "Neutral Fast" and volSpike

plotshape(neutralMarker and currentStrength == 1, title="Neutral Weak Volume Spike", location=location.belowbar, color=neutralWeakColor, style=shape.circle, size=size.tiny)

plotshape(neutralMarker and currentStrength == 2, title="Neutral Medium Volume Spike", location=location.belowbar, color=neutralMediumColor, style=shape.circle, size=size.small)

plotshape(neutralMarker and currentStrength == 3, title="Neutral Strong Volume Spike", location=location.belowbar, color=neutralStrongColor, style=shape.circle, size=size.normal)

// ==========================

// Confirmed Direction markers after spike range breakout

// ==========================

plotshape(bullMarker and activeSpikeStrength == 1, title="Bullish Weak Volume Spike", location=location.belowbar, color=bullWeakColor, style=shape.circle, size=size.tiny)

plotshape(bullMarker and activeSpikeStrength == 2, title="Bullish Medium Volume Spike", location=location.belowbar, color=bullMediumColor, style=shape.circle, size=size.small)

plotshape(bullMarker and activeSpikeStrength == 3, title="Bullish Strong Volume Spike", location=location.belowbar, color=bullStrongColor, style=shape.circle, size=size.normal)

plotshape(bearMarker and activeSpikeStrength == 1, title="Bearish Weak Volume Spike", location=location.abovebar, color=bearWeakColor, style=shape.circle, size=size.tiny)

plotshape(bearMarker and activeSpikeStrength == 2, title="Bearish Medium Volume Spike", location=location.abovebar, color=bearMediumColor, style=shape.circle, size=size.small)

plotshape(bearMarker and activeSpikeStrength == 3, title="Bearish Strong Volume Spike", location=location.abovebar, color=bearStrongColor, style=shape.circle, size=size.normal)

// ==========================

// Optional VOL text labels

// ==========================

if showSignalLabels and bullMarker

    buyLabel = label.new(bar_index, low - atrValue * volTextOffsetAtr, "VOL BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=volTextColor, size=size.normal)

    array.push(signalLabels, buyLabel)

if showSignalLabels and bearMarker

    sellLabel = label.new(bar_index, high + atrValue * volTextOffsetAtr, "VOL SELL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=volTextColor, size=size.normal)

    array.push(signalLabels, sellLabel)

while array.size(signalLabels) > 100

    oldSignalLabel = array.shift(signalLabels)

    label.delete(oldSignalLabel)

// ==========================

// Signal outputs

// ==========================

spikeOutput = volSpike ? 1 : 0

neutralSpikeOutput = neutralMarker ? 1 : 0

bullSpikeOutput = bullMarker ? 1 : 0

bearSpikeOutput = bearMarker ? 1 : 0

weakSpikeOutput = currentStrength == 1 ? 1 : 0

mediumSpikeOutput = currentStrength == 2 ? 1 : 0

strongSpikeOutput = currentStrength == 3 ? 1 : 0

plot(spikeOutput, title="spikeOutput", display=display.none)

plot(neutralSpikeOutput, title="neutralSpikeOutput", display=display.none)

plot(bullSpikeOutput, title="bullSpikeOutput", display=display.none)

plot(bearSpikeOutput, title="bearSpikeOutput", display=display.none)

plot(weakSpikeOutput, title="weakSpikeOutput", display=display.none)

plot(mediumSpikeOutput, title="mediumSpikeOutput", display=display.none)

plot(strongSpikeOutput, title="strongSpikeOutput", display=display.none)

// ==========================

// Alerts

// ==========================

neutralAlert = markerMode == "Neutral Fast" and volSpike

bullAlert = bullMarker

bearAlert = bearMarker

strongAlert = strongVolumeEvent

alertcondition(neutralAlert, title="Neutral Volume Spike", message="Neutral volume spike on {{ticker}} at {{close}}")

alertcondition(bullAlert, title="Bullish Volume Spike", message="Bullish volume spike confirmed after spike range breakout on {{ticker}} at {{close}}")

alertcondition(bearAlert, title="Bearish Volume Spike", message="Bearish volume spike confirmed after spike range breakout on {{ticker}} at {{close}}")

alertcondition(strongAlert, title="Only Strong Volume Spike", message="Strong volume spike on {{ticker}} at {{close}}")
````
