# Bollinger Band Flow Heatmap | julzALGO

- url: https://www.tradingview.com/script/EbQDxgsb-Bollinger-Band-Flow-Heatmap-julzALGO/
- type: indicator
- pine_id: PUB;7edbc50e4d5442608438ed7b68c104d5
- version: 1.0

## Description

📘 The Bollinger Band Flow Heatmap is a market pressure visualization indicator that maps SmartFlow activity inside a dynamic Bollinger Band channel. Instead of treating the Bollinger Bands as simple upper and lower boundaries, the indicator divides the entire channel into 30 adaptive pressure layers and measures how buying and selling pressure accumulates within each layer.
Powered by the julzALGO SmartFlow Engine, the indicator combines raw volume with OHLC candle structure to map where market participation is concentrated. The result is a dynamic pressure map that helps traders identify potential support, resistance, pressure imbalance, and high-interest price zones.

🟠 FEATURES

◉ 30-Layer Pressure Engine

https://www.tradingview.com/x/vGITs1Zg/

The Bollinger Band channel is automatically divided into 30 adaptive pressure layers. Every scanned bar contributes SmartFlow pressure into the appropriate layer, creating a detailed profile of where buying and selling activity has accumulated over time.

◉ julzALGO SmartFlow Engine

https://www.tradingview.com/x/jEZ6YRH3/

The SmartFlow Engine calculates market pressure using multiple components, including:

* Raw volume
* Candle body direction
* Close position within the candle range
* Upper and lower wick structure
* Volume Z-Score weighting
* Flow acceleration
* SmartFlow pressure boosting

◉ Pressure Labels

https://www.tradingview.com/x/EAODiiTT/

Each visible pressure layer can display a P:% value representing its relative pressure strength.
The strongest pressure layer is automatically identified as the POC (Point of Control).

◉ Dynamic Bollinger Channel Guide Lines

https://www.tradingview.com/x/DDp52mdj/

The indicator can display the Upper Band, Middle Basis, and Lower Band as adaptive channel guide lines.
These guides provide the framework for the 30-layer pressure engine, helping visualize where SmartFlow pressure accumulates inside the Bollinger Band channel.

The channel guides can also be used to:
• Visualize the current volatility envelope.
• Identify potential dynamic support and resistance.
• Provide context for pressure accumulation relative to the upper, middle, and lower Bollinger Bands.
• Improve interpretation of pressure layers during trending and ranging market conditions.
The guide lines automatically update with the selected Band Length, Band Source, and Band Deviation, ensuring the pressure map always reflects the current Bollinger Band channel.

◉ Pressure Dashboard

https://www.tradingview.com/x/RKrBSJLl/

The dashboard summarizes pressure distribution across the Bollinger channel:
•  BULL PRESSURE — Total pressure accumulated below the current price.
•  BEAR PRESSURE — Total pressure accumulated above the current price.
•  PRESSURE IMB — Percentage imbalance between bull and bear pressure.

🟠 HOW IT WORKS

The indicator first builds a Bollinger Band channel using the selected source, band length, and deviation multiplier.
The space between the upper and lower Bollinger Bands is divided into 30 adaptive pressure layers.
For every scanned candle, the julzALGO SmartFlow Engine calculates SmartFlow pressure using raw volume together with OHLC candle structure.
Depending on the selected allocation mode, the calculated SmartFlow pressure is either projected into the nearest pressure layer or distributed across every layer touched by the candle.
As additional bars are processed, pressure accumulates throughout the channel, allowing the strongest participation zones to become increasingly visible.

🟠 HOW TO READ THE INDICATOR

https://www.tradingview.com/x/vef6ffAS/

• Strong pressure below price may represent an area of accumulated buying pressure that can act as potential support or demand.
• Strong pressure above price may represent an area of accumulated selling pressure that can act as potential resistance or supply.
• The POC (Point of Control) identifies the pressure layer with the highest accumulated SmartFlow pressure within the current scan.
• Pressure Imbalance quickly indicates whether bull or bear pressure is currently dominant across the channel.
• The Bollinger Channel Guide Lines provide the adaptive framework for the pressure layers and help visualize pressure relative to the upper band, basis, and lower band.

This indicator is designed to complement price action, market structure, trend analysis, and risk management rather than generate automatic buy or sell signals.

⚙️ DEFAULT SETTINGS

Recommended starting values:

* Band Length: 200
* Pressure Scan Bars: 265
* Band Deviation: 3.0
* Pressure Allocation Source: Pressure Projection
* Strongest Pressure Layers: 10
* Pressure Style: Medium

Reduce the scan bars for faster-moving markets, or increase them for more historical context.
Increase the band deviation to widen the adaptive channel.
Increase the number of visible pressure layers to reveal additional areas of accumulated market participation.

⚠️ Disclaimer

This indicator is provided for educational and informational purposes only. It is designed to visualize SmartFlow pressure within a Bollinger Band channel and does not predict future price movements or guarantee trading outcomes.
SmartFlow pressure is derived from raw volume and OHLC candle structure. It is not exchange-provided bid/ask footprint data, Level II market depth, or institutional order flow.
Pressure layers, POC levels, and pressure imbalances should be interpreted as areas of interest, not definitive buy or sell signals. Always confirm trading decisions using your own price action, market structure, trend analysis, and risk management.
Trading and investing involve substantial financial risk. Past performance does not guarantee future results. You are solely responsible for your own trading decisions and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("Bollinger Band Flow Heatmap | julzALGO", shorttitle="BBFlow", overlay=true, max_lines_count=50, max_labels_count=500, max_boxes_count=50, max_bars_back=5000, calc_bars_count=1500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupChannel = "Bollinger Band Heatmap"
showHeatmap = input.bool(true, "Show BB Heatmap", group=groupChannel, tooltip="Displays SmartFlow pressure inside a 30-layer Bollinger Band channel.")
bbLength = input.int(200, "Band Length", minval=20, maxval=1000, group=groupChannel, tooltip="Bars used to calculate the Bollinger Band basis and deviation.")
scanBarsInput = input.int(265, "Pressure Scan Bars", minval=20, maxval=1000, group=groupChannel, tooltip="Bars scanned for SmartFlow pressure allocation.")
bbSource = input.source(hlc3, "Band Source", group=groupChannel, tooltip="Price source used for the Bollinger Band basis.")
bandMult = input.float(3.0, "Band Deviation", minval=0.1, step=0.1, group=groupChannel, tooltip="Standard-deviation multiplier used to create the upper and lower band.")
heatSourceMode = input.string("Pressure Projection", "Pressure Allocation Source", options=["Pressure Projection", "Candle Range Touch", "Close", "HLC3", "HL2"], group=groupChannel, tooltip="Pressure Projection sends every bar to the nearest Bollinger layer. Candle Range Touch only spreads flow across layers crossed by the candle range.")
topSliceCount = input.int(10, "Strongest Pressure Layers", minval=1, maxval=30, group=groupChannel, tooltip="The engine still uses 30 layers, but only this many strongest pressure layers are displayed.")
clearCurrentSlice = input.bool(true, "Clear Current Price Layer", group=groupChannel, tooltip="Clears the layer touching current price so candles stay readable.")
zoneStyle = input.string("Medium", "Pressure Style", options=["Sharp", "Medium", "Soft"], group=groupChannel, tooltip="Controls how strong or soft the pressure opacity appears.")
upperHeatCol = input.color(color.red, "Upper Pressure Color", group=groupChannel, tooltip="Color for pressure above the current price.")
lowerHeatCol = input.color(color.rgb(42, 185, 124), "Lower Pressure Color", group=groupChannel, tooltip="Color for pressure below the current price.")

groupSmartFlow = "SmartFlow Engine"
volLen = input.int(200, "Volume Mean Length", minval=20, maxval=600, group=groupSmartFlow, tooltip="Mean raw volume length used by the SmartFlow pressure engine.")
volStd = input.int(200, "Volume StdDev Length", minval=20, maxval=600, group=groupSmartFlow, tooltip="StdDev raw volume length used to detect abnormal participation.")

groupDisplay = "Display"
showChannelLines = input.bool(true, "Show Channel Lines", group=groupDisplay, tooltip="Shows the upper, middle, and lower Bollinger guides.")
showPressureLabels = input.bool(true, "Show Current-Bar Pressure", group=groupDisplay, tooltip="Shows P:% labels at the current bar for visible pressure layers.")
pressureLabelOffset = input.int(0, "Pressure Label Offset", minval=0, maxval=50, group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay, tooltip="Shows bull/bear pressure totals from the 30 Bollinger layers.")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

fmtVol(float value) =>
    float absValue = math.abs(value)
    absValue >= 1000000 ? str.tostring(absValue / 1000000, "#.##") + "M" :
     absValue >= 1000 ? str.tostring(absValue / 1000, "#.#") + "K" :
     str.tostring(absValue, "#")

fmtSignedPct(float value) =>
    (value > 0 ? "+" : value < 0 ? "-" : "") + str.tostring(math.abs(value), "#.0") + "%"

clearLabels(label[] items) =>
    while array.size(items) > 0
        label.delete(array.pop(items))
    0

clearLines(line[] items) =>
    while array.size(items) > 0
        line.delete(array.pop(items))
    0

//------------------------------------------------------------------------------
// julzALGO SmartFlow Engine
//------------------------------------------------------------------------------
float rawVol = nz(volume, 0.0)
float tr = ta.tr(true)
float priceRange = math.max(tr, syminfo.mintick)

float body = close - open
float bodySize = math.abs(body)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float totalCandle = bodySize + upperWick + lowerWick
totalCandle := totalCandle == 0 ? syminfo.mintick : totalCandle

float bodyRatio = body / priceRange
float wickBuy = lowerWick / totalCandle
float wickSell = upperWick / totalCandle
float closePos = (close - low) / priceRange

float buyStrength =
     closePos * 0.6 +
     wickBuy * 0.25 +
     (bodyRatio > 0 ? bodyRatio * 0.35 : 0)

float sellStrength =
     (1 - closePos) * 0.6 +
     wickSell * 0.25 +
     (bodyRatio < 0 ? -bodyRatio * 0.35 : 0)

float buyVol = rawVol * buyStrength
float sellVol = rawVol * sellStrength
float totalVol = buyVol + sellVol
buyVol := totalVol > 0 ? rawVol * (buyVol / totalVol) : 0
sellVol := totalVol > 0 ? rawVol * (sellVol / totalVol) : 0

float deltaVol = buyVol - sellVol
float meanVol = ta.sma(rawVol, volLen)
float stdVol = ta.stdev(rawVol, volStd)
float zVol = stdVol > 0 ? (rawVol - meanVol) / stdVol : 0
zVol := clamp(zVol, -4.0, 4.0)

float weightedDelta = deltaVol * (1 + zVol * 0.6)
float flowAccel = weightedDelta - nz(weightedDelta[1])
float flowNorm = ta.sma(math.abs(weightedDelta), 10) + 1e-6
float flowPower = weightedDelta / flowNorm
float flowBoost = math.pow(math.min(math.abs(flowPower), 5.0), 1.4)
float flowAgreement = math.sign(weightedDelta) == math.sign(deltaVol) ? 1.2 : 0.7
float accelWeight = math.sign(flowAccel) == math.sign(weightedDelta) ? 1.0 : 0.5

float smartFlow =
     weightedDelta * (1 + flowBoost) * flowAgreement +
     deltaVol * 0.6 +
     flowAccel * 0.4 * accelWeight

//------------------------------------------------------------------------------
// Bollinger Band Channel
//------------------------------------------------------------------------------
int sliceCount = 30
int scanBars = math.min(scanBarsInput, bar_index + 1)

float bandBasisRaw = ta.sma(bbSource, bbLength)
float bandBasis = nz(bandBasisRaw, bbSource)
float bandDev = nz(ta.stdev(bbSource, bbLength), math.max(high - low, syminfo.mintick)) * bandMult
float channelTopRaw = bandBasis + bandDev
float channelBotRaw = bandBasis - bandDev

float channelRangeRaw = channelTopRaw - channelBotRaw
float channelTop = channelRangeRaw <= syminfo.mintick ? bandBasis + syminfo.mintick * 5.0 : channelTopRaw
float channelBot = channelRangeRaw <= syminfo.mintick ? bandBasis - syminfo.mintick * 5.0 : channelBotRaw
float channelRange = math.max(channelTop - channelBot, syminfo.mintick * sliceCount)
float sliceStep = channelRange / sliceCount

bbLevel(int idx) =>
    channelBot + sliceStep * idx

sliceIndex(float price, float bottom, float stepValue) =>
    int idx = int(math.floor((price - bottom) / stepValue))
    idx := int(math.max(0, math.min(sliceCount - 1, idx)))
    idx

//------------------------------------------------------------------------------
// Pressure Allocation
//------------------------------------------------------------------------------
float[] sliceHeat = array.new<float>(sliceCount, 0.0)

addSliceHeat(int idx, float flowValue) =>
    if idx >= 0 and idx < sliceCount
        array.set(sliceHeat, idx, array.get(sliceHeat, idx) + flowValue)

        if idx > 0
            array.set(sliceHeat, idx - 1, array.get(sliceHeat, idx - 1) + flowValue * 0.18)

        if idx < sliceCount - 1
            array.set(sliceHeat, idx + 1, array.get(sliceHeat, idx + 1) + flowValue * 0.18)
    0

for k = 0 to scanBars - 1
    float flowAtBar = nz(smartFlow[k], 0.0)
    float topK = nz(channelTop[k], channelTop)
    float botK = nz(channelBot[k], channelBot)
    float stepK = math.max((topK - botK) / sliceCount, syminfo.mintick)

    if heatSourceMode == "Candle Range Touch"
        int firstSlice = sliceIndex(low[k], botK, stepK)
        int lastSlice = sliceIndex(high[k], botK, stepK)
        int touched = int(math.max(1, lastSlice - firstSlice + 1))
        float flowPiece = flowAtBar / touched

        for row = firstSlice to lastSlice
            addSliceHeat(row, flowPiece)
    else
        float priceAtBar =
             heatSourceMode == "Pressure Projection" ? hlc3[k] :
             heatSourceMode == "HLC3" ? hlc3[k] :
             heatSourceMode == "HL2" ? hl2[k] :
             close[k]
        addSliceHeat(sliceIndex(priceAtBar, botK, stepK), flowAtBar)

sliceAbs(int idx) =>
    idx >= 0 and idx < sliceCount ? math.abs(array.get(sliceHeat, idx)) : 0.0

float strongestSliceHeat = 0.0
int strongestSliceIndex = -1
for i = 0 to sliceCount - 1
    float strength = sliceAbs(i)
    if strength > strongestSliceHeat
        strongestSliceHeat := strength
        strongestSliceIndex := i

sliceTouchesCurrent(int idx) =>
    float rowLow = bbLevel(idx)
    float rowHigh = bbLevel(idx + 1)
    (open >= rowLow and open <= rowHigh) or
     (close >= rowLow and close <= rowHigh) or
     (hl2 >= rowLow and hl2 <= rowHigh) or
     (hlc3 >= rowLow and hlc3 <= rowHigh)

sliceRank(int idx) =>
    int rank = 100000
    if idx >= 0 and idx < sliceCount and not (clearCurrentSlice and sliceTouchesCurrent(idx))
        float currentStrength = sliceAbs(idx)
        if currentStrength > 0.0
            rank := 1
            for i = 0 to sliceCount - 1
                bool cleared = clearCurrentSlice and sliceTouchesCurrent(i)
                if not cleared and sliceAbs(i) > currentStrength
                    rank += 1
    rank

visibleSlice(int idx) =>
    sliceRank(idx) <= topSliceCount

slicePressurePct(int idx) =>
    strongestSliceHeat > 0.0 ? clamp(sliceAbs(idx) / strongestSliceHeat * 100.0, 0.0, 100.0) : 0.0

heatColor(int idx) =>
    color result = na
    if showHeatmap and idx >= 0 and idx < sliceCount and strongestSliceHeat > 0.0
        float rowMid = (bbLevel(idx) + bbLevel(idx + 1)) * 0.5
        float heatRatio = slicePressurePct(idx) / 100.0
        int weakTransp = zoneStyle == "Sharp" ? 88 : zoneStyle == "Medium" ? 92 : 95
        int strongTransp = zoneStyle == "Sharp" ? 34 : zoneStyle == "Medium" ? 46 : 58
        int zoneTransp = int(math.round(weakTransp - heatRatio * (weakTransp - strongTransp)))
        color baseColor = rowMid >= close ? upperHeatCol : lowerHeatCol
        bool cleared = clearCurrentSlice and sliceTouchesCurrent(idx)
        result := cleared or not visibleSlice(idx) or heatRatio <= 0.0 ? na : color.new(baseColor, zoneTransp)
    result

//------------------------------------------------------------------------------
// 30-Layer Pressure Renderer
//------------------------------------------------------------------------------
float l00 = bbLevel(0)
float l01 = bbLevel(1)
float l02 = bbLevel(2)
float l03 = bbLevel(3)
float l04 = bbLevel(4)
float l05 = bbLevel(5)
float l06 = bbLevel(6)
float l07 = bbLevel(7)
float l08 = bbLevel(8)
float l09 = bbLevel(9)
float l10 = bbLevel(10)
float l11 = bbLevel(11)
float l12 = bbLevel(12)
float l13 = bbLevel(13)
float l14 = bbLevel(14)
float l15 = bbLevel(15)
float l16 = bbLevel(16)
float l17 = bbLevel(17)
float l18 = bbLevel(18)
float l19 = bbLevel(19)
float l20 = bbLevel(20)
float l21 = bbLevel(21)
float l22 = bbLevel(22)
float l23 = bbLevel(23)
float l24 = bbLevel(24)
float l25 = bbLevel(25)
float l26 = bbLevel(26)
float l27 = bbLevel(27)
float l28 = bbLevel(28)
float l29 = bbLevel(29)
float l30 = bbLevel(30)

pL00 = plot(showHeatmap ? l00 : na, "BB Layer 00", color=na, editable=false, display=display.none)
pL01 = plot(showHeatmap ? l01 : na, "BB Layer 01", color=na, editable=false, display=display.none)
pL02 = plot(showHeatmap ? l02 : na, "BB Layer 02", color=na, editable=false, display=display.none)
pL03 = plot(showHeatmap ? l03 : na, "BB Layer 03", color=na, editable=false, display=display.none)
pL04 = plot(showHeatmap ? l04 : na, "BB Layer 04", color=na, editable=false, display=display.none)
pL05 = plot(showHeatmap ? l05 : na, "BB Layer 05", color=na, editable=false, display=display.none)
pL06 = plot(showHeatmap ? l06 : na, "BB Layer 06", color=na, editable=false, display=display.none)
pL07 = plot(showHeatmap ? l07 : na, "BB Layer 07", color=na, editable=false, display=display.none)
pL08 = plot(showHeatmap ? l08 : na, "BB Layer 08", color=na, editable=false, display=display.none)
pL09 = plot(showHeatmap ? l09 : na, "BB Layer 09", color=na, editable=false, display=display.none)
pL10 = plot(showHeatmap ? l10 : na, "BB Layer 10", color=na, editable=false, display=display.none)
pL11 = plot(showHeatmap ? l11 : na, "BB Layer 11", color=na, editable=false, display=display.none)
pL12 = plot(showHeatmap ? l12 : na, "BB Layer 12", color=na, editable=false, display=display.none)
pL13 = plot(showHeatmap ? l13 : na, "BB Layer 13", color=na, editable=false, display=display.none)
pL14 = plot(showHeatmap ? l14 : na, "BB Layer 14", color=na, editable=false, display=display.none)
pL15 = plot(showHeatmap ? l15 : na, "BB Layer 15", color=na, editable=false, display=display.none)
pL16 = plot(showHeatmap ? l16 : na, "BB Layer 16", color=na, editable=false, display=display.none)
pL17 = plot(showHeatmap ? l17 : na, "BB Layer 17", color=na, editable=false, display=display.none)
pL18 = plot(showHeatmap ? l18 : na, "BB Layer 18", color=na, editable=false, display=display.none)
pL19 = plot(showHeatmap ? l19 : na, "BB Layer 19", color=na, editable=false, display=display.none)
pL20 = plot(showHeatmap ? l20 : na, "BB Layer 20", color=na, editable=false, display=display.none)
pL21 = plot(showHeatmap ? l21 : na, "BB Layer 21", color=na, editable=false, display=display.none)
pL22 = plot(showHeatmap ? l22 : na, "BB Layer 22", color=na, editable=false, display=display.none)
pL23 = plot(showHeatmap ? l23 : na, "BB Layer 23", color=na, editable=false, display=display.none)
pL24 = plot(showHeatmap ? l24 : na, "BB Layer 24", color=na, editable=false, display=display.none)
pL25 = plot(showHeatmap ? l25 : na, "BB Layer 25", color=na, editable=false, display=display.none)
pL26 = plot(showHeatmap ? l26 : na, "BB Layer 26", color=na, editable=false, display=display.none)
pL27 = plot(showHeatmap ? l27 : na, "BB Layer 27", color=na, editable=false, display=display.none)
pL28 = plot(showHeatmap ? l28 : na, "BB Layer 28", color=na, editable=false, display=display.none)
pL29 = plot(showHeatmap ? l29 : na, "BB Layer 29", color=na, editable=false, display=display.none)
pL30 = plot(showHeatmap ? l30 : na, "BB Layer 30", color=na, editable=false, display=display.none)

fill(pL00, pL01, color=heatColor(0), title="BB Pressure 01")
fill(pL01, pL02, color=heatColor(1), title="BB Pressure 02")
fill(pL02, pL03, color=heatColor(2), title="BB Pressure 03")
fill(pL03, pL04, color=heatColor(3), title="BB Pressure 04")
fill(pL04, pL05, color=heatColor(4), title="BB Pressure 05")
fill(pL05, pL06, color=heatColor(5), title="BB Pressure 06")
fill(pL06, pL07, color=heatColor(6), title="BB Pressure 07")
fill(pL07, pL08, color=heatColor(7), title="BB Pressure 08")
fill(pL08, pL09, color=heatColor(8), title="BB Pressure 09")
fill(pL09, pL10, color=heatColor(9), title="BB Pressure 10")
fill(pL10, pL11, color=heatColor(10), title="BB Pressure 11")
fill(pL11, pL12, color=heatColor(11), title="BB Pressure 12")
fill(pL12, pL13, color=heatColor(12), title="BB Pressure 13")
fill(pL13, pL14, color=heatColor(13), title="BB Pressure 14")
fill(pL14, pL15, color=heatColor(14), title="BB Pressure 15")
fill(pL15, pL16, color=heatColor(15), title="BB Pressure 16")
fill(pL16, pL17, color=heatColor(16), title="BB Pressure 17")
fill(pL17, pL18, color=heatColor(17), title="BB Pressure 18")
fill(pL18, pL19, color=heatColor(18), title="BB Pressure 19")
fill(pL19, pL20, color=heatColor(19), title="BB Pressure 20")
fill(pL20, pL21, color=heatColor(20), title="BB Pressure 21")
fill(pL21, pL22, color=heatColor(21), title="BB Pressure 22")
fill(pL22, pL23, color=heatColor(22), title="BB Pressure 23")
fill(pL23, pL24, color=heatColor(23), title="BB Pressure 24")
fill(pL24, pL25, color=heatColor(24), title="BB Pressure 25")
fill(pL25, pL26, color=heatColor(25), title="BB Pressure 26")
fill(pL26, pL27, color=heatColor(26), title="BB Pressure 27")
fill(pL27, pL28, color=heatColor(27), title="BB Pressure 28")
fill(pL28, pL29, color=heatColor(28), title="BB Pressure 29")
fill(pL29, pL30, color=heatColor(29), title="BB Pressure 30")

//------------------------------------------------------------------------------
// Current Labels And Dashboard
//------------------------------------------------------------------------------
var label[] pressureLabels = array.new_label()
var line[] channelGuideLines = array.new_line()

if barstate.islast
    clearLabels(pressureLabels)
    clearLines(channelGuideLines)

    if showChannelLines
        int guideBack = math.min(scanBarsInput, bar_index)
        int guideLeft = bar_index - guideBack

        line upperGuide = line.new(
             guideLeft,
             nz(channelTop[guideBack], channelTop),
             bar_index,
             channelTop,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(upperHeatCol, 35),
             width=1
        )
        line midGuide = line.new(
             guideLeft,
             nz(bandBasis[guideBack], bandBasis),
             bar_index,
             bandBasis,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(chart.fg_color, 35),
             width=1
        )
        line lowerGuide = line.new(
             guideLeft,
             nz(channelBot[guideBack], channelBot),
             bar_index,
             channelBot,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(lowerHeatCol, 35),
             width=1
        )
        array.push(channelGuideLines, upperGuide)
        array.push(channelGuideLines, midGuide)
        array.push(channelGuideLines, lowerGuide)

    if showPressureLabels and showHeatmap
        int labelX = bar_index + pressureLabelOffset
        for i = 0 to sliceCount - 1
            if visibleSlice(i) and slicePressurePct(i) > 0.0
                float rowMid = (bbLevel(i) + bbLevel(i + 1)) * 0.5
                color txtCol = rowMid >= close ? upperHeatCol : lowerHeatCol
                string marker = i == strongestSliceIndex ? "POC " : ""
                label lb = label.new(
                     labelX,
                     rowMid,
                     marker + "P:" + str.tostring(slicePressurePct(i), "#.0") + "%",
                     xloc=xloc.bar_index,
                     style=label.style_label_left,
                     color=color.new(chart.bg_color, 100),
                     textcolor=txtCol,
                     size=size.tiny,
                     textalign=text.align_left
                )
                array.push(pressureLabels, lb)

float lowerPressure = 0.0
float upperPressure = 0.0
for i = 0 to sliceCount - 1
    float rowMid = (bbLevel(i) + bbLevel(i + 1)) * 0.5
    float pressure = sliceAbs(i)
    if rowMid < close
        lowerPressure += pressure
    else
        upperPressure += pressure

float totalPressure = lowerPressure + upperPressure
float lowerPct = totalPressure > 0 ? lowerPressure / totalPressure * 100.0 : 50.0
float upperPct = 100.0 - lowerPct
float pressureImb = totalPressure > 0 ? (lowerPressure - upperPressure) / totalPressure * 100.0 : 0.0

var table heatDash = table.new(position.top_right, 3, 4, frame_color=color.new(color.gray, 35), frame_width=1, border_color=color.new(color.gray, 45), border_width=1)

if barstate.islast
    if showDashboard
        color titleBg = color.rgb(0, 0, 0)
        color nameBg = color.rgb(12, 12, 12)
        color valueBg = color.rgb(28, 28, 28)
        color dimTxt = color.new(chart.fg_color, 20)
        bool lowerLead = pressureImb > 0
        bool upperLead = pressureImb < 0
        color imbCol = lowerLead ? lowerHeatCol : upperLead ? upperHeatCol : chart.fg_color
        string sideText = lowerLead ? "BULL" : upperLead ? "BEAR" : "BAL"

        table.clear(heatDash, 0, 0, 2, 3)
        table.cell(heatDash, 0, 0, "BB Flow Pressure", text_color=color.white, bgcolor=titleBg, text_size=size.small, text_halign=text.align_center)
        table.cell(heatDash, 1, 0, "30 layers", text_color=color.white, bgcolor=titleBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 2, 0, str.tostring(scanBarsInput) + " bars", text_color=color.white, bgcolor=titleBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 0, 1, "BULL PRESSURE", text_color=dimTxt, bgcolor=nameBg, text_size=size.tiny)
        table.cell(heatDash, 1, 1, str.tostring(lowerPct, "#.0") + "%", text_color=color.white, bgcolor=color.new(lowerHeatCol, 82), text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 2, 1, fmtVol(lowerPressure), text_color=color.white, bgcolor=valueBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 0, 2, "BEAR PRESSURE", text_color=dimTxt, bgcolor=nameBg, text_size=size.tiny)
        table.cell(heatDash, 1, 2, str.tostring(upperPct, "#.0") + "%", text_color=color.white, bgcolor=color.new(upperHeatCol, 82), text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 2, 2, fmtVol(upperPressure), text_color=color.white, bgcolor=valueBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 0, 3, "PRESSURE IMB", text_color=dimTxt, bgcolor=nameBg, text_size=size.tiny)
        table.cell(heatDash, 1, 3, fmtSignedPct(pressureImb), text_color=color.white, bgcolor=color.new(imbCol, 82), text_size=size.tiny, text_halign=text.align_center)
        table.cell(heatDash, 2, 3, sideText, text_color=imbCol, bgcolor=valueBg, text_size=size.tiny, text_halign=text.align_center)
    else
        table.clear(heatDash, 0, 0, 2, 3)

if barstate.isfirst
    var table sign = table.new(position.bottom_right, 1, 1, bgcolor=color.new(#363a45, 100))
    table.cell(sign, 0, 0, "@julzALGO", text_color=color.gray, text_halign=text.align_center, text_size=size.normal)
````
