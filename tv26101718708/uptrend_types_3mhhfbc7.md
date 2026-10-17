# Uptrend Types

- url: https://www.tradingview.com/script/3MHhfBc7-Uptrend-Types/
- type: indicator
- pine_id: PUB;274d8a16688642488d6b1d7fba1ef3aa
- version: 1.0

## Description

Uptrend Types
Uptrend Types is a visual trend-classification indicator designed to help traders read the quality and structure of an uptrend. Instead of treating every bullish move the same way, the indicator separates bullish conditions into three practical uptrend types:
1.	Sharp Uptrend
2.	Steady Uptrend
3.	Weak / Overlapping Uptrend
If the chart does not meet the bullish conditions, the indicator classifies the market as Down / Flat.
This script is an indicator, not a strategy. It does not place trades, does not calculate backtest results, and does not provide automatic buy or sell signals. Its purpose is to help users visually understand the current trend condition and choose the appropriate chart-reading tool for that condition.
Core idea
Many uptrends do not behave the same way.
A fast momentum move often requires attention to prior-high breakout levels.
A healthy rising trend often respects higher lows and a rising trendline.
A weak or overlapping uptrend often needs a more cautious approach using demand zones instead of chasing price.
Uptrend Types attempts to classify these different environments and display a clean visual guide on the chart.
How the indicator works
The script uses several components together:
1.	EMA trend context
The indicator uses a Fast EMA and a Base EMA to understand whether price is trading in a bullish environment. It also checks whether the Fast EMA is above the Base EMA.
2.	EMA slope normalized by ATR
The script calculates the slope of the Base EMA over a selected lookback period. That slope is then normalized by ATR, so the slope reading is relative to recent volatility.
This helps separate weak upward movement from stronger upward momentum.
3.	RSI strength
RSI is used as a momentum filter, especially for identifying sharp uptrends. A stronger RSI reading supports the Sharp Uptrend classification.
4.	Choppiness reading
The script calculates a choppiness value to determine whether price action is clean or overlapping. Higher choppiness suggests a weaker, more overlapping trend environment.
5.	Swing structure
The indicator detects swing highs and swing lows using pivot logic. It then checks for higher highs and higher lows to help identify bullish structure.
Because pivots require confirmation, swing-based elements appear only after the selected number of bars has passed. This is normal behavior for pivot-based indicators.
Trend classifications
1.	Sharp Uptrend
A Sharp Uptrend is detected when the market shows strong bullish context, price is above the moving averages, EMA slope is strong relative to ATR, RSI is above the selected threshold, and choppiness remains below the selected limit.
Visual tool used:
Prior-high breakout levels.
When the market is classified as a Sharp Uptrend, the indicator can draw recent prior-high levels. These levels help users focus on breakout areas and potential extension zones.
The purpose of this mode is to visually highlight that price may be moving with strong momentum. It does not mean the user should automatically enter a trade. The label reminds users not to chase late extensions.
https://www.tradingview.com/x/i3YfJTW7/


2.	Steady Uptrend
A Steady Uptrend is detected when the market shows cleaner bullish structure, including higher highs and higher lows, with a positive EMA slope and acceptable choppiness.
Visual tool used:
Rising trendline.
When this trend type is active, the indicator can draw a rising trendline from recent higher lows. This helps traders observe whether price is respecting the trend structure.
This mode is intended for healthy uptrends where pullbacks toward the trendline may be more relevant than chasing breakouts.

https://www.tradingview.com/x/OOjimmk5/

3.	Weak / Overlapping Uptrend
A Weak Uptrend is detected when the market still has some bullish context, but the move is less clean. This can happen when choppiness is high, the slope is mild, price action is overlapping, or structure is not as strong as in a Steady or Sharp Uptrend.
Visual tool used:
Demand zones.
When this mode is active, the indicator can draw demand zones based on recent swing lows. These zones are intended to show areas where price previously reacted from lower levels.
This mode is more cautious. It suggests that the market is not in a strong clean trend and that users should avoid chasing price. The visual focus shifts to demand-zone reactions.

https://www.tradingview.com/x/d4egai7O/

4.	Down / Flat
If the conditions for a bullish regime are not present, the indicator classifies the market as Down / Flat.
In this state, the indicator does not try to force an uptrend interpretation. The chart label displays that there is no clean bullish setup and that the user should wait.

https://www.tradingview.com/x/2e5q0cu8/

Important: this is not a short signal. It only means the current conditions do not qualify as one of the bullish uptrend types defined by the script.
Visual tools
The indicator includes several visual tools that can be enabled or disabled:
Prior-high breakout levels
Used mainly for Sharp Uptrend conditions.
Rising trendline
Used mainly for Steady Uptrend conditions.
Demand zones
Used mainly for Weak / Overlapping Uptrend conditions.
Attention label
A chart label that summarizes the current trend type and the visual method that fits the current environment.
Summary table
A fixed table showing the current classification, visual tool, structure reading, slope, choppiness, RSI, and rule.
Optional description panel
A simple fixed panel that summarizes the current trend condition.
Optional EMA display
Users can choose to display the Fast EMA and Base EMA.
Optional candle coloring
Candles can be colored by current trend type.
Optional background tint
A soft background tint can be used to quickly identify the current classification.
Summary table fields
Trend Type
Shows the current classification: Sharp Uptrend, Steady Uptrend, Weak / Overlap, or Down / Flat.
Visual Tool
Shows the recommended visual reading method for the current trend type:
Prior-high breakout, trendline pullback, demand zones, or wait.
Structure
Shows whether the market has HH + HL, only higher lows, only higher highs, broken structure, or no clean structure.
Slope ATR/bar
Shows the normalized EMA slope. This is the Base EMA slope divided by ATR, making the slope relative to volatility.
Choppiness
Shows whether price action is clean or overlapping.
RSI
Shows the current RSI value used in the classification process.
Rule
Shows a simple practical reminder based on the current trend type.
Settings explained
Core Engine
Fast EMA Length
Controls the shorter EMA used for trend context.
Base EMA Length
Controls the main EMA used for slope and trend direction.
ATR Length
Controls the ATR calculation used to normalize slope and zone height.
RSI Length
Controls the RSI calculation used for momentum strength.
Choppiness Length
Controls the choppiness calculation window.
EMA Slope Lookback
Controls how many bars are used to measure the Base EMA slope.
Swing Strength
Controls pivot sensitivity. Higher values create fewer, stronger swing points. Lower values create more swing points but may increase noise.
Classification
Minimum Up Slope ATR/bar
Minimum normalized slope needed to support a weak bullish context.
Steady Uptrend Slope ATR/bar
Minimum normalized slope used for Steady Uptrend classification.
Sharp Uptrend Slope ATR/bar
Minimum normalized slope used for Sharp Uptrend classification.
Sharp RSI Threshold
RSI level required to support Sharp Uptrend classification.
Weak / Overlapping Choppiness
Choppiness level used to identify weaker or more overlapping conditions.
Max Choppiness For Sharp
Maximum choppiness allowed for Sharp Uptrend classification.
Visual Display
Show Fast EMA
Displays the Fast EMA.
Show Base EMA
Displays the Base EMA.
Color Candles By Trend Type
Colors candles according to the current trend classification.
Soft Background Tint
Adds a light background color based on the current classification.
Show Summary Table
Shows or hides the main table.
Chart Attention Label
Controls where the main chart label appears or turns it off.
Attention Label Right Offset Bars
Moves the right-side label farther from or closer to the current candle.
Attention Label Vertical ATR Offset
Controls vertical spacing of the attention label.
Attention Label Size
Controls the label size.
Show Extra Fixed Description Panel
Shows an optional fixed panel with a short trend explanation.
Show HL Labels On Trendline
Shows higher-low labels on the rising trendline.
Show Prior High Text Labels
Shows text labels on prior-high breakout levels.
Infographic Tools
Draw Only Current Trend Type
When enabled, the indicator only draws the visual tool that matches the current trend type. This keeps the chart clean.
Sharp: Prior High Levels
Enables prior-high breakout levels for Sharp Uptrend conditions.
Steady: Rising Trendline
Enables the rising trendline for Steady Uptrend conditions.
Weak: Demand Zones
Enables demand zones for Weak / Overlapping Uptrend conditions.
Sharp: Max Prior High Levels
Controls the maximum number of prior-high levels shown.
Weak: Max Demand Zones
Controls the maximum number of demand zones shown.
Demand Zone Height ATR
Controls demand-zone height using ATR.
Demand Zone Projection Bars
Controls how far demand zones extend to the right.
Visual Lookback Bars
Limits how far back the indicator draws visual objects.
Colors
Sharp Uptrend Color
Color used for Sharp Uptrend visuals.
Steady Uptrend Color
Color used for Steady Uptrend visuals.
Weak Uptrend Color
Color used for Weak / Overlapping Uptrend visuals.
Down / Flat Color
Color used when no clean bullish regime is detected.
Demand Zone Fill / Border / Text Colors
Controls demand-zone appearance.
Table Background / Text Colors
Controls summary table appearance.
Demand Zone Text
Show Demand Zone Text
Shows or hides text inside demand zones.
Demand Zone Text
Custom text shown inside demand zones.
Demand Zone Text Size
Controls text size inside demand zones.
Demand Zone Text Alignment
Controls horizontal and vertical text alignment.
How to use the indicator
A practical workflow:
1.	Check the table for the current trend type.
2.	Read the visual tool suggested by the indicator.
3.	If the trend is Sharp Uptrend, focus on prior-high breakout levels and avoid chasing late moves.
4.	If the trend is Steady Uptrend, watch the rising trendline and higher-low structure.
5.	If the trend is Weak / Overlapping, focus on demand-zone reactions and avoid chasing price.
6.	If the trend is Down / Flat, wait for cleaner bullish structure before treating the chart as an uptrend.
This indicator is designed to support visual trend reading. It should be combined with the user’s own market structure analysis, risk management, and trading plan.
Alerts
The script includes alerts for:
Sharp Uptrend Started
Steady Uptrend Started
Weak Uptrend Started
Uptrend Ended
These alerts only notify the user that the classification has changed. They are not trade execution signals.
Limitations
This indicator does not predict future price movement.
It does not generate buy or sell signals.
It does not provide backtesting results.
Pivot-based swing points confirm after the selected pivot length, so swing labels and trendline points appear with a natural delay.
Demand zones are based on recent swing lows and ATR height. They are visual support areas, not guaranteed reversal zones.
Prior-high levels are visual breakout reference levels, not guaranteed breakout entries.
The trend type can change as new candles form and market conditions change.
Different assets and timeframes may require different settings.
Recommended use
Uptrend Types is best used as a visual trend-reading assistant for traders who want to quickly distinguish between strong momentum uptrends, cleaner steady uptrends, weaker overlapping uptrends, and non-bullish conditions.
It is intended for educational and analytical use only. It should not be used as a standalone trading system or as financial advice.
Originality and purpose
The purpose of this script is to combine several trend-reading concepts into one clean visual framework:
EMA-based trend context
ATR-normalized slope
RSI momentum strength
Choppiness / overlap detection
Higher-high and higher-low structure
Prior-high breakout levels
Rising trendline visualization
Demand-zone visualization
Summary table and attention labels
The script does not simply mark price as bullish or bearish. It attempts to classify the type of uptrend and display the most relevant visual tool for that environment.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

// ============================================================
//  Uptrend Types
//  Visual classifier inspired by the educational infographic:
//
//  1) Sharp Uptrend  -> prior-high breakout levels
//  2) Steady Uptrend -> clean rising trendline
//  3) Weak Uptrend   -> demand zones / overlapping pullbacks
//
//  Important:
//  - This is a visual trend-reading helper.
//  - It is not a buy/sell signal generator.
//  - Pivots confirm late by nature.
//  - Default display is clean: no historical signal clutter.
// ============================================================

//@version=6
indicator("Uptrend Types", shorttitle="UTypes", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=300)

// ============================================================
// [1] Core Inputs
// ============================================================
grpCore = "1. Core Engine"

emaFastLen = input.int(21, "Fast EMA Length", minval=2, group=grpCore)
emaBaseLen = input.int(50, "Base EMA Length", minval=2, group=grpCore)
atrLen     = input.int(14, "ATR Length", minval=1, group=grpCore)
rsiLen     = input.int(14, "RSI Length", minval=2, group=grpCore)
chopLen    = input.int(14, "Choppiness Length", minval=2, group=grpCore)
slopeLen   = input.int(10, "EMA Slope Lookback", minval=1, group=grpCore)
pivotLen   = input.int(5, "Swing Strength", minval=1, maxval=20, group=grpCore)

// ============================================================
// [2] Classification Inputs
// ============================================================
grpClass = "2. Classification"

minUpSlope   = input.float(0.005, "Minimum Up Slope ATR/bar", step=0.005, group=grpClass)
steadySlope  = input.float(0.030, "Steady Uptrend Slope ATR/bar", step=0.005, group=grpClass)
sharpSlope   = input.float(0.075, "Sharp Uptrend Slope ATR/bar", step=0.005, group=grpClass)
strongRsi    = input.float(58.0, "Sharp RSI Threshold", step=1.0, group=grpClass)
weakChop     = input.float(55.0, "Weak / Overlapping Choppiness", step=1.0, group=grpClass)
sharpMaxChop = input.float(52.0, "Max Choppiness For Sharp", step=1.0, group=grpClass)

// ============================================================
// [3] Visual Display
// ============================================================
grpVisual = "3. Visual Display"

showFastEma    = input.bool(false, "Show Fast EMA", group=grpVisual)
showBaseEma    = input.bool(false, "Show Base EMA", group=grpVisual)
colorBars      = input.bool(false, "Color Candles By Trend Type", group=grpVisual)
showBackground = input.bool(false, "Soft Background Tint", group=grpVisual)

showTable      = input.bool(true, "Show Summary Table", group=grpVisual)

// Quick chart label: ON by default because it gives a fast visual reminder.
mainLabelPlacement = input.string("Right Side", "Chart Attention Label", options=["Right Side", "Above Price", "Off"], group=grpVisual)
mainLabelBarsRight = input.int(18, "Attention Label Right Offset Bars", minval=1, maxval=150, group=grpVisual)
mainLabelAtrOffset = input.float(1.40, "Attention Label Vertical ATR Offset", minval=0.10, step=0.10, group=grpVisual)
mainLabelSizeInput = input.string("Small", "Attention Label Size", options=["Tiny", "Small", "Normal"], group=grpVisual)

showDescPanel  = input.bool(false, "Show Extra Fixed Description Panel", group=grpVisual)
descPanelPosInput = input.string("Middle Right", "Extra Description Panel Position", options=["Top Left", "Top Center", "Top Right", "Middle Right", "Bottom Right", "Bottom Center", "Bottom Left"], group=grpVisual)

showSwingLabels = input.bool(true, "Show HL Labels On Trendline", group=grpVisual)
showLevelLabels = input.bool(true, "Show Prior High Text Labels", group=grpVisual)

// ============================================================
// [4] Infographic Tools
// ============================================================
grpTools = "4. Infographic Tools"

drawOnlyCurrentType = input.bool(true, "Draw Only Current Trend Type", group=grpTools)

showSharpTool  = input.bool(true, "Sharp: Prior High Levels", group=grpTools)
showSteadyTool = input.bool(true, "Steady: Rising Trendline", group=grpTools)
showWeakTool   = input.bool(true, "Weak: Demand Zones", group=grpTools)

maxHighLevels  = input.int(3, "Sharp: Max Prior High Levels", minval=1, maxval=6, group=grpTools)
maxDemandZones = input.int(3, "Weak: Max Demand Zones", minval=1, maxval=6, group=grpTools)

zoneAtrHeight  = input.float(0.35, "Demand Zone Height ATR", step=0.05, minval=0.05, group=grpTools)
zoneProjection = input.int(100, "Demand Zone Projection Bars", minval=10, maxval=300, group=grpTools)
visualLookback = input.int(350, "Visual Lookback Bars", minval=50, maxval=2000, group=grpTools)

// ============================================================
// [5] Colors
// ============================================================
grpColors = "5. Colors"

sharpColor  = input.color(color.rgb(229, 57, 53), "Sharp Uptrend Color", group=grpColors)
steadyColor = input.color(color.rgb(46, 125, 50), "Steady Uptrend Color", group=grpColors)
weakColor   = input.color(color.rgb(239, 108, 0), "Weak Uptrend Color", group=grpColors)
flatColor   = input.color(color.rgb(120, 120, 120), "Down / Flat Color", group=grpColors)

zoneFillColor     = input.color(color.rgb(255, 193, 7), "Demand Zone Fill Color", group=grpColors)
zoneBorderColor   = input.color(color.rgb(239, 108, 0), "Demand Zone Border Color", group=grpColors)
zoneTextColor     = input.color(color.black, "Demand Zone Text Color", group=grpColors)
zoneTransparency  = input.int(78, "Demand Zone Fill Transparency", minval=0, maxval=100, group=grpColors)

tableBgColor   = input.color(color.rgb(18, 26, 38), "Table Background Color", group=grpColors)
tableTextColor = input.color(color.white, "Table Text Color", group=grpColors)

// ============================================================
// [6] Demand Zone Text
// ============================================================
grpZoneText = "6. Demand Zone Text"

showZoneText       = input.bool(true, "Show Demand Zone Text", group=grpZoneText)
zoneTextInput      = input.string("Demand Zone", "Demand Zone Text", group=grpZoneText)
zoneTextSizeInput  = input.string("Small", "Demand Zone Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpZoneText)
zoneTextHalign     = input.string("Center", "Demand Zone Text Horizontal Align", options=["Left", "Center", "Right"], group=grpZoneText)
zoneTextValign     = input.string("Center", "Demand Zone Text Vertical Align", options=["Top", "Center", "Bottom"], group=grpZoneText)

// ============================================================
// Core Calculations
// ============================================================
emaFast = ta.ema(close, emaFastLen)
emaBase = ta.ema(close, emaBaseLen)
atr     = ta.atr(atrLen)
rsi     = ta.rsi(close, rsiLen)

emaSlopePerBar = (emaBase - emaBase[slopeLen]) / slopeLen
slopeNorm      = atr > 0 ? emaSlopePerBar / atr : 0.0

trSum = math.max(math.sum(ta.tr(true), chopLen), syminfo.mintick)
rng   = math.max(ta.highest(high, chopLen) - ta.lowest(low, chopLen), syminfo.mintick)
chop  = 100.0 * math.log10(trSum / rng) / math.log10(chopLen)

// ============================================================
// Swing Detection
// ============================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float[] highVals = array.new<float>()
var int[]   highXs   = array.new<int>()

var float[] lowVals  = array.new<float>()
var int[]   lowXs    = array.new<int>()
var float[] lowAtrs  = array.new<float>()

maxStoredSwings = 40

if not na(ph)
    array.push(highVals, ph)
    array.push(highXs, bar_index - pivotLen)

    if array.size(highVals) > maxStoredSwings
        array.shift(highVals)
        array.shift(highXs)

if not na(pl)
    array.push(lowVals, pl)
    array.push(lowXs, bar_index - pivotLen)
    array.push(lowAtrs, atr[pivotLen])

    if array.size(lowVals) > maxStoredSwings
        array.shift(lowVals)
        array.shift(lowXs)
        array.shift(lowAtrs)

// ============================================================
// Structure Reading
// ============================================================
highCount = array.size(highVals)
lowCount  = array.size(lowVals)

lastHigh = highCount >= 1 ? array.get(highVals, highCount - 1) : na
prevHigh = highCount >= 2 ? array.get(highVals, highCount - 2) : na

lastLow  = lowCount >= 1 ? array.get(lowVals, lowCount - 1) : na
prevLow  = lowCount >= 2 ? array.get(lowVals, lowCount - 2) : na

lastLowX = lowCount >= 1 ? array.get(lowXs, lowCount - 1) : na
prevLowX = lowCount >= 2 ? array.get(lowXs, lowCount - 2) : na

higherHigh = not na(lastHigh) and not na(prevHigh) and lastHigh > prevHigh
higherLow  = not na(lastLow) and not na(prevLow) and lastLow > prevLow

structureUp = higherHigh and higherLow
structureBroken = not na(lastLow) and close < lastLow

aboveFast = close > emaFast
aboveBase = close > emaBase
fastAboveBase = emaFast > emaBase

upContext = structureUp or aboveBase or fastAboveBase
mildUpContext = structureUp or close > nz(prevLow, close)

// ============================================================
// Trend Type Classification
// 0 = Down / Flat
// 1 = Sharp Uptrend
// 2 = Steady Uptrend
// 3 = Weak / Overlapping Uptrend
// ============================================================
sharpCond = upContext and not structureBroken and aboveFast and slopeNorm >= sharpSlope and rsi >= strongRsi and chop <= sharpMaxChop

steadyCond = upContext and not structureBroken and structureUp and slopeNorm >= steadySlope and chop < weakChop

weakCond = mildUpContext and not structureBroken and (
     structureUp or
     chop >= weakChop or
     slopeNorm >= minUpSlope or
     close > emaBase
)

int trendType = 0

if sharpCond
    trendType := 1
else if steadyCond
    trendType := 2
else if weakCond
    trendType := 3
else
    trendType := 0

trendColor = trendType == 1 ? sharpColor : trendType == 2 ? steadyColor : trendType == 3 ? weakColor : flatColor

// ============================================================
// Optional EMA / Bar Coloring
// ============================================================
plot(showFastEma ? emaFast : na, "Fast EMA", color=color.new(trendColor, 0), linewidth=2)
plot(showBaseEma ? emaBase : na, "Base EMA", color=color.new(trendColor, 45), linewidth=2)

barcolor(colorBars ? color.new(trendColor, 15) : na)
bgcolor(showBackground ? color.new(trendColor, 90) : na)

// ============================================================
// Object Management
// ============================================================
var line[]  visualLines  = array.new<line>()
var box[]   visualBoxes  = array.new<box>()
var label[] visualLabels = array.new<label>()

clearLines(line[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

clearBoxes(box[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
        array.clear(arr)

clearLabels(label[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

inVisualWindow(int x) =>
    bar_index - x <= visualLookback

// ============================================================
// Tool Permissions
// ============================================================
allowSharp  = showSharpTool and (not drawOnlyCurrentType or trendType == 1)
allowSteady = showSteadyTool and (not drawOnlyCurrentType or trendType == 2)
allowWeak   = showWeakTool and (not drawOnlyCurrentType or trendType == 3)

// ============================================================
// Live Trendline From Last Two Higher Lows
// ============================================================
float tlValue = na
float tlFutureValue = na
bool validTrendline = false

if lowCount >= 2 and not na(lastLowX) and not na(prevLowX) and lastLowX > prevLowX and lastLow > prevLow
    tlSlope = (lastLow - prevLow) / (lastLowX - prevLowX)
    tlValue := lastLow + tlSlope * (bar_index - lastLowX)
    tlFutureValue := tlValue + tlSlope * 60
    validTrendline := true

// ============================================================
// Helper: Sizes and Alignment
// ============================================================
labelSize = mainLabelSizeInput == "Tiny" ? size.tiny : mainLabelSizeInput == "Normal" ? size.normal : size.small

zoneTextSize = zoneTextSizeInput == "Tiny" ? size.tiny :
     zoneTextSizeInput == "Normal" ? size.normal :
     zoneTextSizeInput == "Large" ? size.large :
     size.small

zoneTextH = zoneTextHalign == "Left" ? text.align_left :
     zoneTextHalign == "Right" ? text.align_right :
     text.align_center

zoneTextV = zoneTextValign == "Top" ? text.align_top :
     zoneTextValign == "Bottom" ? text.align_bottom :
     text.align_center

// ============================================================
// Text Values
// ============================================================
typeText = trendType == 1 ? "SHARP UP" : trendType == 2 ? "STEADY UP" : trendType == 3 ? "WEAK / OVERLAP" : "DOWN / FLAT"

actionText = trendType == 1 ? "Prior-high breakout" :
     trendType == 2 ? "Trendline pullback" :
     trendType == 3 ? "Demand zones only" :
     "Stay out / wait"

structureText = structureBroken ? "Broken" :
     structureUp ? "HH + HL" :
     higherLow ? "HL only" :
     higherHigh ? "HH only" :
     "Not clean"

ruleText = trendType == 1 ? "Do not chase late extension." :
     trendType == 2 ? "Respect the rising trendline." :
     trendType == 3 ? "Wait for demand-zone reaction." :
     "No clean bullish regime."

descText = trendType == 1 ? "1. SHARP UPTREND\nFast momentum\nTool: prior-high breakout" :
     trendType == 2 ? "2. STEADY UPTREND\nHealthy higher lows\nTool: rising trendline" :
     trendType == 3 ? "3. WEAK / OVERLAP\nUse demand zones\nAvoid chasing" :
     "DOWN / FLAT\nNo clean bullish setup\nWait"

// ============================================================
// Helper: Attention Label Coordinates
// ============================================================
recentHigh = ta.highest(high, 40)
recentLow  = ta.lowest(low, 40)

mainLabelX = mainLabelPlacement == "Right Side" ? bar_index + mainLabelBarsRight : bar_index

mainLabelY() =>
    if mainLabelPlacement == "Right Side"
        trendType == 0 ? close + atr * mainLabelAtrOffset :
             trendType == 3 ? close + atr * mainLabelAtrOffset :
             recentHigh + atr * mainLabelAtrOffset
    else
        recentHigh + atr * mainLabelAtrOffset

mainLabelStyle = mainLabelPlacement == "Right Side" ? label.style_label_left : label.style_label_down

// ============================================================
// Draw Clean Infographic-Style Objects
// ============================================================
if barstate.islast
    clearLines(visualLines)
    clearBoxes(visualBoxes)
    clearLabels(visualLabels)

    // ========================================================
    // 1) SHARP UPTREND: Prior-high breakout levels
    // ========================================================
    if allowSharp and highCount > 0
        drawnHighs = 0

        for n = 0 to highCount - 1
            idx = highCount - 1 - n
            hVal = array.get(highVals, idx)
            hX   = array.get(highXs, idx)

            if drawnHighs < maxHighLevels and inVisualWindow(hX)
                ln = line.new(hX, hVal, bar_index + 30, hVal, color=color.new(sharpColor, 0), width=2, style=line.style_dashed)
                array.push(visualLines, ln)

                if showLevelLabels
                    lb = label.new(bar_index + 32, hVal, "Prior High\nBreakout Zone", style=label.style_label_left, color=sharpColor, textcolor=color.white, size=size.tiny)
                    array.push(visualLabels, lb)

                drawnHighs += 1

        if mainLabelPlacement != "Off"
            mainLabel = label.new(mainLabelX, mainLabelY(), descText, style=mainLabelStyle, color=sharpColor, textcolor=color.white, size=labelSize)
            array.push(visualLabels, mainLabel)

    // ========================================================
    // 2) STEADY UPTREND: Rising trendline
    // ========================================================
    if allowSteady and validTrendline and inVisualWindow(prevLowX)
        tl = line.new(prevLowX, prevLow, bar_index + 60, tlFutureValue, color=color.new(steadyColor, 0), width=3)
        array.push(visualLines, tl)

        if showSwingLabels
            lb1 = label.new(prevLowX, prevLow, "HL", style=label.style_label_up, color=steadyColor, textcolor=color.white, size=size.tiny)
            lb2 = label.new(lastLowX, lastLow, "HL", style=label.style_label_up, color=steadyColor, textcolor=color.white, size=size.tiny)

            array.push(visualLabels, lb1)
            array.push(visualLabels, lb2)

        if mainLabelPlacement != "Off"
            steadyY = mainLabelPlacement == "Right Side" ? close + atr * mainLabelAtrOffset : recentHigh + atr * mainLabelAtrOffset
            mainLabel = label.new(mainLabelX, steadyY, descText, style=mainLabelStyle, color=steadyColor, textcolor=color.white, size=labelSize)
            array.push(visualLabels, mainLabel)

    // ========================================================
    // 3) WEAK / OVERLAPPING UPTREND: Demand zones
    // ========================================================
    if allowWeak and lowCount > 0
        drawnZones = 0

        for n = 0 to lowCount - 1
            idx = lowCount - 1 - n
            lVal = array.get(lowVals, idx)
            lX   = array.get(lowXs, idx)
            lAtr = array.get(lowAtrs, idx)

            if drawnZones < maxDemandZones and inVisualWindow(lX)
                zTop = lVal + lAtr * zoneAtrHeight
                zBot = lVal

                bx = box.new(
                     left=lX,
                     top=zTop,
                     right=bar_index + zoneProjection,
                     bottom=zBot,
                     border_color=zoneBorderColor,
                     border_width=1,
                     bgcolor=color.new(zoneFillColor, zoneTransparency),
                     text=showZoneText ? zoneTextInput : "",
                     text_color=zoneTextColor,
                     text_size=zoneTextSize,
                     text_halign=zoneTextH,
                     text_valign=zoneTextV
                )

                array.push(visualBoxes, bx)
                drawnZones += 1

        if mainLabelPlacement != "Off"
            mainLabel = label.new(mainLabelX, mainLabelY(), descText, style=mainLabelStyle, color=weakColor, textcolor=color.white, size=labelSize)
            array.push(visualLabels, mainLabel)

    // ========================================================
    // DOWN / FLAT
    // ========================================================
    if trendType == 0
        if mainLabelPlacement != "Off"
            mainLabel = label.new(mainLabelX, mainLabelY(), descText, style=mainLabelStyle, color=flatColor, textcolor=color.white, size=labelSize)
            array.push(visualLabels, mainLabel)

// ============================================================
// Summary Table
// ============================================================
var table tbl = table.new(position.top_right, 2, 7, frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

if showTable and barstate.islast
    table.cell(tbl, 0, 0, "Trend Type", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 0, typeText, text_color=color.white, bgcolor=trendColor, text_size=size.small)

    table.cell(tbl, 0, 1, "Visual Tool", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 1, actionText, text_color=color.white, bgcolor=color.new(trendColor, 15), text_size=size.small)

    table.cell(tbl, 0, 2, "Structure", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 2, structureText, text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)

    table.cell(tbl, 0, 3, "Slope ATR/bar", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(slopeNorm, "#.###"), text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)

    table.cell(tbl, 0, 4, "Choppiness", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(chop, "#.#"), text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)

    table.cell(tbl, 0, 5, "RSI", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(rsi, "#.#"), text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)

    table.cell(tbl, 0, 6, "Rule", text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)
    table.cell(tbl, 1, 6, ruleText, text_color=tableTextColor, bgcolor=tableBgColor, text_size=size.small)

// ============================================================
// Optional Extra Fixed Description Panel
// ============================================================
descPanelPos =
     descPanelPosInput == "Top Left" ? position.top_left :
     descPanelPosInput == "Top Center" ? position.top_center :
     descPanelPosInput == "Top Right" ? position.top_right :
     descPanelPosInput == "Middle Right" ? position.middle_right :
     descPanelPosInput == "Bottom Center" ? position.bottom_center :
     descPanelPosInput == "Bottom Left" ? position.bottom_left :
     position.bottom_right

var table descTbl = table.new(descPanelPos, 1, 1, frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

if showDescPanel and barstate.islast
    table.cell(descTbl, 0, 0, descText, text_color=color.white, bgcolor=color.new(trendColor, 0), text_size=size.small)

// ============================================================
// Alerts
// ============================================================
alertcondition(trendType == 1 and trendType[1] != 1, "Sharp Uptrend Started", "Sharp uptrend started: focus on prior-high breakout levels.")
alertcondition(trendType == 2 and trendType[1] != 2, "Steady Uptrend Started", "Steady uptrend started: focus on rising trendline pullbacks.")
alertcondition(trendType == 3 and trendType[1] != 3, "Weak Uptrend Started", "Weak / overlapping uptrend started: focus on demand zones.")
alertcondition(trendType == 0 and trendType[1] != 0, "Uptrend Ended", "No clean bullish regime: wait.")
````
