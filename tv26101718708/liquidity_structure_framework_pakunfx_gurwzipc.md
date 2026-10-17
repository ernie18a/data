# Liquidity Structure Framework [PakunFX]

- url: https://www.tradingview.com/script/GuRWZiPC-Liquidity-Structure-Framework-PakunFX/
- type: indicator
- pine_id: PUB;e6ca22850fd44f64bb23cf366e8b4f06
- version: 1.0

## Description

[b]Liquidity Sequence Framework [PakunFX][/b]

Liquidity Sequence Framework (LSF) is a market structure analysis indicator designed to visualize the progression of liquidity events, structure shifts, and Fair Value Gaps (FVGs) within a single analytical framework.

Instead of focusing on individual signals, the indicator organizes multiple market events into a sequential process, helping traders observe how price structure develops over time. The script combines swing structure, liquidity sweeps, trend filtering, and Fair Value Gap detection into a unified charting tool.

[b]Features[/b]

[list]
[*]External and Internal Swing Structure detection
[*]Liquidity Sweep identification (SSL / BSL)
[*]Bullish and Bearish Structure Shift detection
[*]Automatic Fair Value Gap (FVG) detection
[*]EMA-based trend filter
[*]Premium / Discount (Equilibrium) filter
[*]Configurable setup conditions
[*]Visual sequence tracking with alerts
[/list]

[b]How it Works[/b]

The indicator monitors market structure using external and internal swing highs and lows. When liquidity is swept beyond a previous swing level, a new sequence begins. The script then tracks whether price confirms a structure shift and subsequently forms a Fair Value Gap within a configurable sequence window.
Trend filtering can be applied using Fast and Slow EMA conditions, while optional Premium / Discount and Fair Value Gap requirements allow users to customize how potential setups are displayed.

[b]Display Elements[/b]

[list]
[*]External Swing High / Low
[*]Internal Swing High / Low
[*]Liquidity Sweep markers (SSL / BSL)
[*]Structure Shift markers
[*]Active Fair Value Gap zones
[*]Fast and Slow EMA
[*]Equilibrium level
[*]Setup markers
[/list]

[b]Alerts[/b]

Alerts are available for:

[list]
[*]Liquidity Sweep
[*]Bullish Structure Shift
[*]Bearish Structure Shift
[*]Bullish Sequence Setup
[*]Bearish Sequence Setup
[/list]

These alerts are intended to notify users when predefined analytical conditions are detected.

[b]Notes[/b]

Liquidity Sequence Framework is designed as a market analysis tool. It visualizes structural relationships between liquidity events and price development but does not generate trading recommendations or predict future market direction.

[b]Disclaimer[/b]

This script is provided for educational and research purposes only.

All calculations are based on historical price data. The displayed structures, Fair Value Gaps, and sequence conditions are intended to support chart analysis and should not be interpreted as guarantees of future market behavior or trading performance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PakunFX

//@version=6
indicator("Liquidity Sequence Framework [PakunFX]", shorttitle="LSF", overlay=true, max_boxes_count=20, max_labels_count=300, max_bars_back=5000)

//====================================================
// INPUTS
//====================================================

externalLength = input.int(8, "External Swing Length", minval=2, maxval=100, group="Structure")
internalLength = input.int(3, "Internal Swing Length", minval=1, maxval=50, group="Structure")
sequenceWindow = input.int(60, "Maximum Sequence Bars", minval=5, maxval=500, group="Structure")

fastLength = input.int(9, "Fast EMA", minval=1, maxval=500, group="Trend Filter")
slowLength = input.int(15, "Slow EMA", minval=2, maxval=500, group="Trend Filter")
atrLength = input.int(14, "ATR Length", minval=1, maxval=500, group="Trend Filter")
emaSeparationATR = input.float(0.03, "Minimum EMA Separation ATR", minval=0.0, maxval=5.0, step=0.01, group="Trend Filter")
requireEMASlope = input.bool(true, "Require EMA Slope", group="Trend Filter")

minimumFVGATR = input.float(0.10, "Minimum FVG Size ATR", minval=0.0, maxval=10.0, step=0.05, group="Fair Value Gap")
fvgExtension = input.int(30, "FVG Extension Bars", minval=1, maxval=500, group="Fair Value Gap")
deleteInvalidFVG = input.bool(true, "Delete Invalid FVG", group="Fair Value Gap")

useEMAFilter = input.bool(true, "Require EMA Filter", group="Setup Conditions")
useEquilibrium = input.bool(true, "Require Premium Discount", group="Setup Conditions")
requireCloseInsideFVG = input.bool(true, "Require Close Inside FVG", group="Setup Conditions")

showEMA = input.bool(true, "Show EMA", group="Display")
showExternalLevels = input.bool(true, "Show External Swing Levels", group="Display")
showInternalLevels = input.bool(false, "Show Internal Swing Levels", group="Display")
showSweeps = input.bool(true, "Show Liquidity Sweeps", group="Display")
showShift = input.bool(true, "Show Structure Shift", group="Display")
showFVG = input.bool(true, "Show Active FVG", group="Display")
showEquilibrium = input.bool(true, "Show Equilibrium", group="Display")
showSetup = input.bool(true, "Show Setup Markers", group="Display")

//====================================================
// BASE CALCULATIONS
//====================================================

atrValue = ta.atr(atrLength)
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
emaDistance = math.abs(fastEMA - slowEMA)

bullSlopeOK = not requireEMASlope or fastEMA > fastEMA[1]
bearSlopeOK = not requireEMASlope or fastEMA < fastEMA[1]

bullEMAFilter = fastEMA > slowEMA and close > slowEMA and emaDistance >= atrValue * emaSeparationATR and bullSlopeOK
bearEMAFilter = fastEMA < slowEMA and close < slowEMA and emaDistance >= atrValue * emaSeparationATR and bearSlopeOK

plot(showEMA ? fastEMA : na, title="Fast EMA", color=color.yellow, linewidth=2)
plot(showEMA ? slowEMA : na, title="Slow EMA", color=color.white, linewidth=2)

//====================================================
// PIVOTS
//====================================================

externalHighPivot = ta.pivothigh(high, externalLength, externalLength)
externalLowPivot = ta.pivotlow(low, externalLength, externalLength)
internalHighPivot = ta.pivothigh(high, internalLength, internalLength)
internalLowPivot = ta.pivotlow(low, internalLength, internalLength)

//====================================================
// PERSISTENT STRUCTURE VARIABLES
//====================================================

var float lastExtHigh = na
var float lastExtLow = na
var int lastExtHighBar = na
var int lastExtLowBar = na

var float lastIntHigh = na
var float lastIntLow = na
var int lastIntHighBar = na
var int lastIntLowBar = na

if not na(externalHighPivot)
    lastExtHigh := externalHighPivot
    lastExtHighBar := bar_index - externalLength

if not na(externalLowPivot)
    lastExtLow := externalLowPivot
    lastExtLowBar := bar_index - externalLength

if not na(internalHighPivot)
    lastIntHigh := internalHighPivot
    lastIntHighBar := bar_index - internalLength

if not na(internalLowPivot)
    lastIntLow := internalLowPivot
    lastIntLowBar := bar_index - internalLength

plot(showExternalLevels ? lastExtHigh : na, title="External Swing High", color=color.new(color.red, 65), linewidth=1, style=plot.style_stepline)
plot(showExternalLevels ? lastExtLow : na, title="External Swing Low", color=color.new(color.green, 65), linewidth=1, style=plot.style_stepline)
plot(showInternalLevels ? lastIntHigh : na, title="Internal Swing High", color=color.new(color.orange, 75), linewidth=1, style=plot.style_stepline)
plot(showInternalLevels ? lastIntLow : na, title="Internal Swing Low", color=color.new(color.aqua, 75), linewidth=1, style=plot.style_stepline)

//====================================================
// LIQUIDITY SWEEPS
//====================================================

bullSweepRaw = not na(lastExtLow) and not na(lastExtLowBar) and bar_index > lastExtLowBar and low < lastExtLow and close > lastExtLow
bearSweepRaw = not na(lastExtHigh) and not na(lastExtHighBar) and bar_index > lastExtHighBar and high > lastExtHigh and close < lastExtHigh

var int usedBullLevelBar = na
var int usedBearLevelBar = na

newBullSweep = bullSweepRaw and (na(usedBullLevelBar) or usedBullLevelBar != lastExtLowBar)
newBearSweep = bearSweepRaw and (na(usedBearLevelBar) or usedBearLevelBar != lastExtHighBar)

if newBullSweep 
    usedBullLevelBar := lastExtLowBar

if newBearSweep
    usedBearLevelBar := lastExtHighBar

plotshape(showSweeps and newBullSweep, title="Sell Side Liquidity Sweep", style=shape.xcross, location=location.belowbar, color=color.aqua, size=size.tiny, text="SSL", textcolor=color.aqua)
plotshape(showSweeps and newBearSweep, title="Buy Side Liquidity Sweep", style=shape.xcross, location=location.abovebar, color=color.orange, size=size.tiny, text="BSL", textcolor=color.orange)

//====================================================
// SEQUENCE VARIABLES
//====================================================

// State 0 = Waiting
// State 1 = Sweep detected
// State 2 = Structure shift detected
// State 3 = FVG detected

var int bullState = 0
var int bearState = 0

var int bullSweepBar = na
var int bearSweepBar = na
var int bullShiftBar = na
var int bearShiftBar = na
var int bullFVGBar = na
var int bearFVGBar = na

var float bullRangeLow = na
var float bullRangeHigh = na
var float bearRangeLow = na
var float bearRangeHigh = na

var float bullShiftLevel = na
var float bearShiftLevel = na

var float bullFVGTop = na
var float bullFVGBottom = na
var float bearFVGTop = na
var float bearFVGBottom = na

var box bullBox = na
var box bearBox = na

//====================================================
// START NEW SEQUENCES
//====================================================

if newBullSweep
    bullState := 1
    bullSweepBar := bar_index
    bullShiftBar := na
    bullFVGBar := na
    bullRangeLow := low
    bullRangeHigh := high
    bullShiftLevel := lastIntHigh
    bullFVGTop := na
    bullFVGBottom := na
    if not na(bullBox)
        box.delete(bullBox)
        bullBox := na

if newBearSweep
    bearState := 1
    bearSweepBar := bar_index
    bearShiftBar := na
    bearFVGBar := na
    bearRangeHigh := high
    bearRangeLow := low
    bearShiftLevel := lastIntLow
    bearFVGTop := na
    bearFVGBottom := na
    if not na(bearBox)
        box.delete(bearBox)
        bearBox := na

//====================================================
// UPDATE ACTIVE RANGES
//====================================================

if bullState == 1 or bullState == 2
    bullRangeHigh := math.max(nz(bullRangeHigh, high), high)
    bullRangeLow := math.min(nz(bullRangeLow, low), low)

if bearState == 1 or bearState == 2
    bearRangeHigh := math.max(nz(bearRangeHigh, high), high)
    bearRangeLow := math.min(nz(bearRangeLow, low), low)

//====================================================
// STRUCTURE SHIFT
//====================================================

bullStructureShift = bullState == 1 and not na(bullSweepBar) and not na(bullShiftLevel) and bar_index > bullSweepBar and close > bullShiftLevel
bearStructureShift = bearState == 1 and not na(bearSweepBar) and not na(bearShiftLevel) and bar_index > bearSweepBar and close < bearShiftLevel

if bullStructureShift
    bullState := 2
    bullShiftBar := bar_index
    bullRangeHigh := math.max(nz(bullRangeHigh, high), high)

if bearStructureShift
    bearState := 2
    bearShiftBar := bar_index
    bearRangeLow := math.min(nz(bearRangeLow, low), low)

plotshape(showShift and bullStructureShift, title="Bullish Structure Shift", style=shape.labelup, location=location.belowbar, color=color.blue, text="SHIFT", textcolor=color.white, size=size.tiny)
plotshape(showShift and bearStructureShift, title="Bearish Structure Shift", style=shape.labeldown, location=location.abovebar, color=color.purple, text="SHIFT", textcolor=color.white, size=size.tiny)

//====================================================
// FAIR VALUE GAP
//====================================================

bullFVGDetected = low > high[2] and low - high[2] >= atrValue * minimumFVGATR
bearFVGDetected = high < low[2] and low[2] - high >= atrValue * minimumFVGATR

newBullFVG = bullState == 2 and not na(bullShiftBar) and bar_index > bullShiftBar and bullFVGDetected
newBearFVG = bearState == 2 and not na(bearShiftBar) and bar_index > bearShiftBar and bearFVGDetected

if newBullFVG
    bullState := 3
    bullFVGBar := bar_index
    bullFVGTop := low
    bullFVGBottom := high[2]
    bullRangeHigh := math.max(nz(bullRangeHigh, high), high)
if not na(bullBox)
    box.delete(bullBox)
    bullBox := na
if showFVG
    bullBox := box.new(left=bar_index - 2, top=bullFVGTop, right=bar_index + fvgExtension, bottom=bullFVGBottom, border_color=color.new(color.lime, 20), border_width=1, bgcolor=color.new(color.lime, 85))

if newBearFVG
    bearState := 3
    bearFVGBar := bar_index
    bearFVGTop := low[2]
    bearFVGBottom := high
    bearRangeLow := math.min(nz(bearRangeLow, low), low)
if not na(bearBox)
    box.delete(bearBox)
    bearBox := na
if showFVG
    bearBox := box.new(left=bar_index - 2, top=bearFVGTop, right=bar_index + fvgExtension, bottom=bearFVGBottom, border_color=color.new(color.red, 20), border_width=1, bgcolor=color.new(color.red, 85))

if bullState == 3 and not na(bullBox)
    box.set_right(bullBox, bar_index + fvgExtension)

if bearState == 3 and not na(bearBox)
    box.set_right(bearBox, bar_index + fvgExtension)

//====================================================
// EQUILIBRIUM
//====================================================

bullEQ = not na(bullRangeHigh) and not na(bullRangeLow) ? (bullRangeHigh + bullRangeLow) / 2.0 : na
bearEQ = not na(bearRangeHigh) and not na(bearRangeLow) ? (bearRangeHigh + bearRangeLow) / 2.0 : na

plot(showEquilibrium and bullState > 0 ? bullEQ : na, title="Bullish Equilibrium", color=color.new(color.aqua, 10), linewidth=1, style=plot.style_linebr)
plot(showEquilibrium and bearState > 0 ? bearEQ : na, title="Bearish Equilibrium", color=color.new(color.orange, 10), linewidth=1, style=plot.style_linebr)

//====================================================
// FVG RETRACEMENT
//====================================================

bullTouchesFVG = bullState == 3 and not na(bullFVGBar) and not na(bullFVGTop) and not na(bullFVGBottom) and bar_index > bullFVGBar and low <= bullFVGTop and high >= bullFVGBottom
bearTouchesFVG = bearState == 3 and not na(bearFVGBar) and not na(bearFVGTop) and not na(bearFVGBottom) and bar_index > bearFVGBar and high >= bearFVGBottom and low <= bearFVGTop

bullCloseCondition = not requireCloseInsideFVG or close >= bullFVGBottom
bearCloseCondition = not requireCloseInsideFVG or close <= bearFVGTop

bullEQCondition = not useEquilibrium or (not na(bullEQ) and close <= bullEQ)
bearEQCondition = not useEquilibrium or (not na(bearEQ) and close >= bearEQ)

bullTrendCondition = not useEMAFilter or bullEMAFilter
bearTrendCondition = not useEMAFilter or bearEMAFilter

//====================================================
// FINAL SETUPS
//====================================================

bullSetup = bullTouchesFVG and bullCloseCondition and bullEQCondition and bullTrendCondition
bearSetup = bearTouchesFVG and bearCloseCondition and bearEQCondition and bearTrendCondition

plotshape(showSetup and bullSetup, title="Bullish Sequence Setup", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="SETUP", textcolor=color.white)
plotshape(showSetup and bearSetup, title="Bearish Sequence Setup", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SETUP", textcolor=color.white)

if bullSetup
    bullState := 0
if not na(bullBox)
    box.set_right(bullBox, bar_index)
    box.set_bgcolor(bullBox, color.new(color.lime, 92))
    bullBox := na

if bearSetup
    bearState := 0
if not na(bearBox)
    box.set_right(bearBox, bar_index)
    box.set_bgcolor(bearBox, color.new(color.red, 92))
    bearBox := na

//====================================================
// INVALIDATION AND EXPIRATION
//====================================================

bullInvalidated = bullState > 0 and not na(bullRangeLow) and close < bullRangeLow
bearInvalidated = bearState > 0 and not na(bearRangeHigh) and close > bearRangeHigh

bullExpired = bullState > 0 and not na(bullSweepBar) and bar_index - bullSweepBar > sequenceWindow
bearExpired = bearState > 0 and not na(bearSweepBar) and bar_index - bearSweepBar > sequenceWindow

if bullInvalidated or bullExpired
    bullState := 0
    bullSweepBar := na
    bullShiftBar := na
    bullFVGBar := na
    bullRangeLow := na
    bullRangeHigh := na
    bullShiftLevel := na
    bullFVGTop := na
    bullFVGBottom := na
    if not na(bullBox)
        if deleteInvalidFVG
            box.delete(bullBox)
        else
            box.set_right(bullBox, bar_index)
            box.set_bgcolor(bullBox, color.new(color.gray, 92))
        bullBox := na

if bearInvalidated or bearExpired
    bearState := 0
    bearSweepBar := na
    bearShiftBar := na
    bearFVGBar := na
    bearRangeLow := na
    bearRangeHigh := na
    bearShiftLevel := na
    bearFVGTop := na
    bearFVGBottom := na
    if not na(bearBox)
        if deleteInvalidFVG
            box.delete(bearBox)
        else
            box.set_right(bearBox, bar_index)
            box.set_bgcolor(bearBox, color.new(color.gray, 92))
        bearBox := na

//====================================================
// ALERTS
//====================================================

alertcondition(newBullSweep, title="Sell Side Liquidity Sweep", message="Sell-side liquidity sweep detected on {{ticker}} {{interval}}.")
alertcondition(newBearSweep, title="Buy Side Liquidity Sweep", message="Buy-side liquidity sweep detected on {{ticker}} {{interval}}.")
alertcondition(bullStructureShift, title="Bullish Structure Shift", message="Bullish structure shift detected on {{ticker}} {{interval}}.")
alertcondition(bearStructureShift, title="Bearish Structure Shift", message="Bearish structure shift detected on {{ticker}} {{interval}}.")
alertcondition(bullSetup, title="Bullish Sequence Setup", message="Bullish liquidity sequence setup detected on {{ticker}} {{interval}}.")
alertcondition(bearSetup, title="Bearish Sequence Setup", message="Bearish liquidity sequence setup detected on {{ticker}} {{interval}}.")
````
