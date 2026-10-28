# Aurora Ribbon

- url: https://www.tradingview.com/script/nwoG4v8e-Aurora-Ribbon/
- type: indicator
- pine_id: PUB;9255e2acd8c24fc9bab370b685012311
- version: 1.0

## Description

█ Overview

Aurora  Ribbon is an adaptive price envelope centered on a moving average of your choice. It shows how far price has moved from that average while allowing the envelope to respond to volatility, volume, the strength of recent price movement, and candle wick behavior.

You can configure three moving averages independently. One MA controls the ribbon at a time. The other MAs can be displayed as lines for comparison, but they do not create additional clouds.

The upper and lower clouds each contain three layers. Their color becomes more visible toward the outer band, making the edge of the envelope easy to identify without filling the entire space around the MA.

█ How the Ribbon Is Calculated

⚪ 1. Select the center line

Choose MA 1, MA 2, or MA 3 in the Ribbon Band settings. Each MA has its own source, length, and calculation type. The available types are SMA, EMA, RMA, WMA, and VWMA.

The selected MA becomes the center of the envelope. Changing the selected MA changes both the center line and the ribbon around it. The indicator does not switch between MAs automatically.

⚪ 2. Calculate the core width

The width starts with two measurements.

The first is Average True Range, which represents recent price range. The second is the smoothed absolute distance between the selected MA and its source. The Deviation mix setting controls how much each measurement contributes.

A minimum width based on ATR provides a floor when the blended measurement becomes small. The resulting width is smoothed before it is used to draw the bands.

[pine]
deviation = smoothed absolute distance between source and MA

core width = greater of:
ATR minimum width
ATR contribution blended with deviation contribution

final width = smoothed core width
[/pine]

Each MA has its own deviation and width calculation. This means that selecting a different MA can change the shape of the envelope as well as its center.

⚪ 3. Adjust for volume and price movement

The indicator compares current volume with its moving average. Volume above that average can increase band width. When volume data is unavailable, the volume calculation uses a neutral value.

Force measures the absolute change in closing price relative to ATR, then smooths that measurement. It responds to the size of a move in either direction. Volume and force have separate sensitivity settings and maximum scales.

[pine]
relative volume = current volume divided by average volume

force = smoothed absolute close change divided by ATR

band scale = volume scale multiplied by force scale
[/pine]

⚪ 4. Shape the upper and lower edges

The scaled width is expanded outward from the selected MA. Smoothed upper wicks influence the upper edge, while smoothed lower wicks influence the lower edge. These adjustments let the two sides respond separately to recent candle structure.

The Envelope beyond core setting controls the additional distance between the core width and the final band edges.

█ Understanding the Cloud

The cloud begins partway between the selected MA and each outer edge. With the default Ribbon gradient start value of 0.70, the colored area occupies the outer 30 percent of that distance.

Each side of the cloud is divided into three equal spatial layers. The inner layer is soft, the middle layer is more visible, and the outer layer is strongest. The upper and lower sides have separate color settings.

Relative volume also changes cloud transparency through five activity tiers. Higher relative volume makes the layers more visible according to the Heat contrast per level setting. This visual change reflects volume activity; it does not indicate whether volume favors buyers or sellers.

█ How to Read It

⚪ Center line

The selected MA provides a reference for the current price position. Its line uses the upper color when that MA is rising and the lower color when it is falling.

⚪ Band expansion

A widening envelope indicates that one or more width components have increased. These can include ATR, distance from the MA, relative volume, or the force measurement. Expansion describes current conditions rather than predicting the next move.

⚪ Price near an outer edge

When price approaches an edge, it is farther from the selected MA relative to the current envelope calculation. An edge touch alone is not a reversal or breakout signal. Read it alongside price structure and your own confirmation rules.

⚪ Additional MA lines

Enable the other MA lines in Ribbon Band to compare their positions with the selected center line. These toggles display lines only. The chart continues to show a single ribbon.

█ Settings

⚪ Ribbon Band

Select the MA that controls the ribbon. Choose Ribbon + MA, MA lines only, or Ribbon only. The individual MA line switches control which lines appear when MA lines are included in the display mode.

⚪ Moving averages

Set the type, length, and source for each of the three MAs. These settings affect the selected ribbon when that MA is chosen and affect its standalone line when the line is visible.

⚪ Width engine

Adjust the ATR length, deviation smoothing, width smoothing, ATR contribution, deviation contribution, Deviation mix, minimum width, envelope expansion, and wick asymmetry.

⚪ Volume and force

Set the volume average length and the sensitivity and maximum scale for volume. Set the smoothing, sensitivity, and maximum scale for force.

⚪ Ribbon gradient

Control where the cloud begins, its transparency, how strongly volume changes its appearance, and the colors of the upper and lower sides.

Aurora Volume Force Ribbon is a visual tool for studying the relationship between price, a chosen moving average, and changing market activity. It does not generate entries, exits, or alerts.

## Source Code

````pine
//@version=6
indicator("Aurora Ribbon", shorttitle = "Aurora Ribbon", overlay = true)
// One selected MA carries the ribbon. Other MA lines can be shown independently.
string singleChoice = input.string("MA 1", "Ribbon MA", options = ["MA 1", "MA 2", "MA 3"], group = "Ribbon Band")
string displayMode = input.string("Ribbon + MA", "Display", options = ["Ribbon + MA", "MA lines only", "Ribbon only"], group = "Ribbon Band")
bool showMA1 = input.bool(true, "Show MA 1 line", group = "Ribbon Band")
bool showMA2 = input.bool(true, "Show MA 2 line", group = "Ribbon Band")
bool showMA3 = input.bool(true, "Show MA 3 line", group = "Ribbon Band")

// Each MA has its own length, source, and width model.
string type1 = input.string("EMA", "MA 1 type", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = "Moving averages")
int length1 = input.int(34, "MA 1 length", minval = 1, group = "Moving averages")
source1 = input.source(close, "MA 1 source", group = "Moving averages")
string type2 = input.string("EMA", "MA 2 type", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = "Moving averages")
int length2 = input.int(55, "MA 2 length", minval = 1, group = "Moving averages")
source2 = input.source(close, "MA 2 source", group = "Moving averages")
string type3 = input.string("EMA", "MA 3 type", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = "Moving averages")
int length3 = input.int(89, "MA 3 length", minval = 1, group = "Moving averages")
source3 = input.source(close, "MA 3 source", group = "Moving averages")
// A blend of ATR and smoothed distance from price to each MA sets its core width.
int atrLength = input.int(14, "ATR length", minval = 1, group = "Width engine")
int deviationSmooth = input.int(12, "MA deviation smoothing", minval = 1, group = "Width engine")
int edgeSmooth = input.int(5, "Width smoothing", minval = 1, group = "Width engine")
float atrMultiplier = input.float(1.0, "ATR contribution", minval = 0.0, step = 0.05, group = "Width engine")
float deviationMultiplier = input.float(1.0, "MA deviation contribution", minval = 0.0, step = 0.05, group = "Width engine")
float deviationMix = input.float(0.50, "Deviation mix", minval = 0.0, maxval = 1.0, step = 0.05, group = "Width engine", tooltip = "0 uses ATR; 1 uses smoothed price-to-MA deviation, subject to the ATR floor.")
float minWidthATR = input.float(0.35, "Minimum width (ATR)", minval = 0.05, step = 0.05, group = "Width engine")
float envelopeExpansion = input.float(0.55, "Envelope beyond core", minval = 0.05, maxval = 2.0, step = 0.05, group = "Width engine")
float wickAsymmetry = input.float(0.10, "Wick asymmetry", minval = 0.0, maxval = 0.5, step = 0.05, group = "Width engine")
int volumeLength = input.int(20, "Volume average length", minval = 1, group = "Volume and force")
float volumeSensitivity = input.float(0.40, "Volume width sensitivity", minval = 0.0, maxval = 2.0, step = 0.05, group = "Volume and force")
float maxVolumeScale = input.float(1.80, "Maximum volume width scale", minval = 1.0, maxval = 4.0, step = 0.05, group = "Volume and force")
int forceLength = input.int(13, "Force smoothing", minval = 1, group = "Volume and force")
float forceSensitivity = input.float(0.30, "Force width sensitivity", minval = 0.0, maxval = 2.0, step = 0.05, group = "Volume and force")
float maxForceScale = input.float(1.50, "Maximum force width scale", minval = 1.0, maxval = 4.0, step = 0.05, group = "Volume and force")
// Color the outer 30% of the space from each MA to its envelope edge.
float gradientStart = input.float(0.70, "Ribbon gradient start", minval = 0.50, maxval = 0.95, step = 0.01, group = "Ribbon gradient", tooltip = "0.70 starts the gradient 70% of the way from each MA to its band, coloring the outer 30%.")
int stripeTransparency = input.int(50, "Gradient transparency", minval = 0, maxval = 100, group = "Ribbon gradient")
int volumeHeatContrast = input.int(12, "Heat contrast per level", minval = 0, maxval = 25, group = "Ribbon gradient", tooltip = "Five volume tiers use relative volume: below 0.75, 0.75-1, 1-1.5, 1.5-2.25, and 2.25 or higher. Each step changes transparency by this amount.")
color upperColor = input.color(color.rgb(0, 210, 185), "Upper ribbon color", group = "Ribbon gradient")
color lowerColor = input.color(color.rgb(245, 55, 90), "Lower ribbon color", group = "Ribbon gradient")

ma(float source, int length, string kind) =>
    float smaValue = ta.sma(source, length)
    float emaValue = ta.ema(source, length)
    float rmaValue = ta.rma(source, length)
    float wmaValue = ta.wma(source, length)
    float vwmaValue = ta.vwma(source, length)
    switch kind
        "SMA" => smaValue
        "EMA" => emaValue
        "RMA" => rmaValue
        "WMA" => wmaValue
        "VWMA" => vwmaValue

float ma1 = ma(source1, length1, type1)
float ma2 = ma(source2, length2, type2)
float ma3 = ma(source3, length3, type3)
float atr = ta.atr(atrLength)
float safeATR = na(atr) ? syminfo.mintick : math.max(atr, syminfo.mintick)
// Separate adaptive deviations for each MA. MAs are never merged.
float dev1 = ta.ema(math.abs(source1 - ma1), deviationSmooth)
float dev2 = ta.ema(math.abs(source2 - ma2), deviationSmooth)
float dev3 = ta.ema(math.abs(source3 - ma3), deviationSmooth)
float rawWidth1 = math.max(atr * minWidthATR, (1.0 - deviationMix) * atrMultiplier * atr + deviationMix * deviationMultiplier * dev1)
float rawWidth2 = math.max(atr * minWidthATR, (1.0 - deviationMix) * atrMultiplier * atr + deviationMix * deviationMultiplier * dev2)
float rawWidth3 = math.max(atr * minWidthATR, (1.0 - deviationMix) * atrMultiplier * atr + deviationMix * deviationMultiplier * dev3)
float width1 = ta.ema(rawWidth1, edgeSmooth)
float width2 = ta.ema(rawWidth2, edgeSmooth)
float width3 = ta.ema(rawWidth3, edgeSmooth)
// Volume affects width once. Force measures price movement without volume weighting.
float avgVolume = ta.sma(volume, volumeLength)
float relativeVolume = na(volume) or na(avgVolume) or avgVolume <= 0.0 ? 1.0 : volume / avgVolume
float volumeScale = math.min(maxVolumeScale, 1.0 + volumeSensitivity * math.max(relativeVolume - 1.0, 0.0))
float normalizedMove = na(close[1]) ? 0.0 : math.abs(close - close[1]) / safeATR
float force = ta.ema(normalizedMove, forceLength)
float forceScale = math.min(maxForceScale, 1.0 + forceSensitivity * force)
float upperWick = ta.rma(math.max(0.0, high - math.max(open, close)), atrLength)
float lowerWick = ta.rma(math.max(0.0, math.min(open, close) - low), atrLength)
float upperAsym = math.min(1.30, 1.0 + wickAsymmetry * upperWick / safeATR)
float lowerAsym = math.min(1.30, 1.0 + wickAsymmetry * lowerWick / safeATR)
float factor = volumeScale * forceScale
float outerFactor = 1.0 + envelopeExpansion
float envUpper1 = ma1 + width1 * factor * outerFactor * upperAsym
float envLower1 = ma1 - width1 * factor * outerFactor * lowerAsym
float envUpper2 = ma2 + width2 * factor * outerFactor * upperAsym
float envLower2 = ma2 - width2 * factor * outerFactor * lowerAsym
float envUpper3 = ma3 + width3 * factor * outerFactor * upperAsym
float envLower3 = ma3 - width3 * factor * outerFactor * lowerAsym
// The selected MA alone determines the ribbon and its envelope.
int selectedMA = singleChoice == "MA 1" ? 1 : singleChoice == "MA 2" ? 2 : 3

// Three cloud layers on each side grow stronger toward the outer edge.
// Five volume tiers change their opacity together.
int heatLevel = relativeVolume < 0.75 ? 0 : relativeVolume < 1.0 ? 1 : relativeVolume < 1.5 ? 2 : relativeVolume < 2.25 ? 3 : 4
float baseAlpha = stripeTransparency + (2 - heatLevel) * volumeHeatContrast
int softAlpha = int(math.max(0.0, math.min(100.0, baseAlpha + 30.0)))
int middleAlpha = int(math.max(0.0, math.min(100.0, baseAlpha + 10.0)))
int edgeAlpha = int(math.max(0.0, math.min(100.0, baseAlpha - 10.0)))

// One selected ribbon, with independently switchable MA lines.
float selectedCenter = selectedMA == 1 ? ma1 : selectedMA == 2 ? ma2 : ma3
float selectedUpper = selectedMA == 1 ? envUpper1 : selectedMA == 2 ? envUpper2 : envUpper3
float selectedLower = selectedMA == 1 ? envLower1 : selectedMA == 2 ? envLower2 : envLower3
float firstRatio = gradientStart + (1.0 - gradientStart) / 3.0
float secondRatio = gradientStart + 2.0 * (1.0 - gradientStart) / 3.0
float startUpper = selectedCenter + (selectedUpper - selectedCenter) * gradientStart
float startLower = selectedCenter + (selectedLower - selectedCenter) * gradientStart
float firstUpper = selectedCenter + (selectedUpper - selectedCenter) * firstRatio
float firstLower = selectedCenter + (selectedLower - selectedCenter) * firstRatio
float secondUpper = selectedCenter + (selectedUpper - selectedCenter) * secondRatio
float secondLower = selectedCenter + (selectedLower - selectedCenter) * secondRatio

bool drawMAs = displayMode != "Ribbon only"
bool drawRibbon = displayMode != "MA lines only"
// Display the selected MA by default; toggles add only lines for other MAs.
bool drawMA1 = drawMAs and (selectedMA == 1 or showMA1)
bool drawMA2 = drawMAs and (selectedMA == 2 or showMA2)
bool drawMA3 = drawMAs and (selectedMA == 3 or showMA3)
plot(drawMA1 ? ma1 : na, "MA 1", color = ma1 >= ma1[1] ? upperColor : lowerColor, linewidth = 2, style = plot.style_linebr)
plot(drawMA2 ? ma2 : na, "MA 2", color = ma2 >= ma2[1] ? upperColor : lowerColor, linewidth = 2, style = plot.style_linebr)
plot(drawMA3 ? ma3 : na, "MA 3", color = ma3 >= ma3[1] ? upperColor : lowerColor, linewidth = 2, style = plot.style_linebr)
pUpper = plot(drawRibbon ? selectedUpper : na, "Selected upper edge", color = color.new(upperColor, 40), style = plot.style_linebr)
pLower = plot(drawRibbon ? selectedLower : na, "Selected lower edge", color = color.new(lowerColor, 40), style = plot.style_linebr)
pStartUpper = plot(drawRibbon ? startUpper : na, "Upper fade start", display = display.none)
pStartLower = plot(drawRibbon ? startLower : na, "Lower fade start", display = display.none)
pFirstUpper = plot(drawRibbon ? firstUpper : na, "Upper fade first", display = display.none)
pFirstLower = plot(drawRibbon ? firstLower : na, "Lower fade first", display = display.none)
pSecondUpper = plot(drawRibbon ? secondUpper : na, "Upper fade second", display = display.none)
pSecondLower = plot(drawRibbon ? secondLower : na, "Lower fade second", display = display.none)
fill(pStartUpper, pFirstUpper, color = color.new(upperColor, softAlpha), title = "Upper soft layer", fillgaps = false)
fill(pStartLower, pFirstLower, color = color.new(lowerColor, softAlpha), title = "Lower soft layer", fillgaps = false)
fill(pFirstUpper, pSecondUpper, color = color.new(upperColor, middleAlpha), title = "Upper middle layer", fillgaps = false)
fill(pFirstLower, pSecondLower, color = color.new(lowerColor, middleAlpha), title = "Lower middle layer", fillgaps = false)
fill(pSecondUpper, pUpper, color = color.new(upperColor, edgeAlpha), title = "Upper strong layer", fillgaps = false)
fill(pSecondLower, pLower, color = color.new(lowerColor, edgeAlpha), title = "Lower strong layer", fillgaps = false)
````
