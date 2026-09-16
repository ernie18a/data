<!-- tradingview-pine-id: PUB;27913bcdb7474931b37215749895aec8 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ZB SMC Tools

Source: https://www.tradingview.com/script/OAWSfFBt-ZB-SMC-Tools/

## Description

ZB SMC Tools combines three price-action concepts into one clean charting indicator: Fair Value Gaps, market structure, and liquidity sweeps.

Features:

• Bullish and bearish Fair Value Gap detection  
• Automatic removal of mitigated FVGs  
• Adjustable FVG size threshold and box extension  
• Bullish and bearish Break of Structure (BOS)  
• Change of Character (CHoCH) identification  
• Confirmed swing-high and swing-low detection  
• Buy-side liquidity (BSL) sweeps above swing highs  
• Sell-side liquidity (SSL) sweeps below swing lows  
• Optional swept-liquidity level lines  
• Adjustable ATR penetration filter to reduce minor signals  
• Optional rejection-candle direction filter  
• Alerts for FVGs, structure breaks, and liquidity sweeps  

Liquidity sweep logic:

A sell-side liquidity sweep occurs when price trades below a confirmed swing low and then closes back above that level.

A buy-side liquidity sweep occurs when price trades above a confirmed swing high and then closes back below that level.

Market-structure and liquidity-sweep signals are confirmed using closed candles. Swing points require subsequent candles for confirmation, helping avoid the use of unconfirmed pivots. Settings can be adjusted to suit different markets, instruments, and timeframes.

This indicator is intended to provide chart context. It does not generate guaranteed trade entries and should be used alongside appropriate confirmation and risk management.

Created and integrated by @ZoogBaira.

Fair Value Gap and Market Structure concepts in this implementation are based on the original open-source LuxAlgo scripts. Original work © LuxAlgo.

Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0).

---

## Source Code

````pine
//ZoogBaira shouts to @tenders0041 and @Samueltoet
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International
// (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// Based on Fair Value Gap [LuxAlgo] and Market Structure CHoCH/BOS (Fractal) [LuxAlgo]
// Original work © LuxAlgo.
// Combined indicator and liquidity sweep integration by @ZoogBaira.

//@version=6
indicator("ZB SMC Tools", "ZB SMC Tools", overlay = true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

//------------------------------------------------------------------------------
// Fair Value Gaps
//------------------------------------------------------------------------------
fvgGroup = "Fair Value Gaps"
showFvg = input.bool(true, "Show FVGs", group = fvgGroup)
fvgThreshold = input.float(0.0, "Minimum gap %", minval = 0, step = 0.1, group = fvgGroup) / 100
fvgExtend = input.int(20, "Extend boxes (bars)", minval = 0, group = fvgGroup)
removeMitigated = input.bool(true, "Remove mitigated FVGs", group = fvgGroup)
bullFvgColor = input.color(color.new(#089981, 70), "Bullish FVG", group = fvgGroup)
bearFvgColor = input.color(color.new(#f23645, 70), "Bearish FVG", group = fvgGroup)

var array<float> fvgTops = array.new_float()
var array<float> fvgBottoms = array.new_float()
var array<bool> fvgBullish = array.new_bool()
var array<box> fvgBoxes = array.new_box()

bullFvg = bar_index >= 2 and low > high[2] and close[1] > high[2] and
     (low - high[2]) / high[2] > fvgThreshold
bearFvg = bar_index >= 2 and high < low[2] and close[1] < low[2] and
     (low[2] - high) / high > fvgThreshold

if showFvg and bullFvg
    array.unshift(fvgTops, low)
    array.unshift(fvgBottoms, high[2])
    array.unshift(fvgBullish, true)
    array.unshift(fvgBoxes, box.new(bar_index - 2, low, bar_index + fvgExtend, high[2],
         border_color = color.new(bullFvgColor, 100), bgcolor = bullFvgColor))

if showFvg and bearFvg
    array.unshift(fvgTops, low[2])
    array.unshift(fvgBottoms, high)
    array.unshift(fvgBullish, false)
    array.unshift(fvgBoxes, box.new(bar_index - 2, low[2], bar_index + fvgExtend, high,
         border_color = color.new(bearFvgColor, 100), bgcolor = bearFvgColor))

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        top = array.get(fvgTops, i)
        bottom = array.get(fvgBottoms, i)
        isBull = array.get(fvgBullish, i)
        mitigated = isBull ? close < bottom : close > top
        if mitigated and removeMitigated
            box.delete(array.remove(fvgBoxes, i))
            array.remove(fvgTops, i)
            array.remove(fvgBottoms, i)
            array.remove(fvgBullish, i)

// Keep arrays safely below TradingView's drawing limit.
if array.size(fvgBoxes) > 450
    box.delete(array.pop(fvgBoxes))
    array.pop(fvgTops)
    array.pop(fvgBottoms)
    array.pop(fvgBullish)

//------------------------------------------------------------------------------
// Confirmed fractal swings shared by market structure and liquidity sweeps
//------------------------------------------------------------------------------
structureGroup = "Market Structure"
structureLength = input.int(5, "Fractal length", minval = 3, group = structureGroup,
     tooltip = "Odd values are recommended. Larger values find more significant swings.")
showBullStructure = input.bool(true, "Bullish BOS / CHoCH", group = structureGroup)
showBearStructure = input.bool(true, "Bearish BOS / CHoCH", group = structureGroup)
bullStructureColor = input.color(#089981, "Bullish colour", group = structureGroup)
bearStructureColor = input.color(#f23645, "Bearish colour", group = structureGroup)

pivotBars = int(structureLength / 2)
confirmedHigh = ta.pivothigh(high, pivotBars, pivotBars)
confirmedLow = ta.pivotlow(low, pivotBars, pivotBars)

var float activeHigh = na
var int activeHighBar = na
var bool highBroken = false
var bool highSwept = false

var float activeLow = na
var int activeLowBar = na
var bool lowBroken = false
var bool lowSwept = false

if not na(confirmedHigh)
    activeHigh := confirmedHigh
    activeHighBar := bar_index - pivotBars
    highBroken := false
    highSwept := false

if not na(confirmedLow)
    activeLow := confirmedLow
    activeLowBar := bar_index - pivotBars
    lowBroken := false
    lowSwept := false

var int marketBias = 0

bullStructureBreak = barstate.isconfirmed and not na(activeHigh) and not highBroken and
     close > activeHigh and close[1] <= activeHigh
bearStructureBreak = barstate.isconfirmed and not na(activeLow) and not lowBroken and
     close < activeLow and close[1] >= activeLow

if bullStructureBreak
    if showBullStructure
        line.new(activeHighBar, activeHigh, bar_index, activeHigh, color = bullStructureColor)
        label.new(int(math.avg(activeHighBar, bar_index)), activeHigh,
             marketBias == -1 ? "CHoCH" : "BOS", color = color.new(color.white, 100),
             textcolor = bullStructureColor, style = label.style_label_down, size = size.tiny)
    highBroken := true
    marketBias := 1

if bearStructureBreak
    if showBearStructure
        line.new(activeLowBar, activeLow, bar_index, activeLow, color = bearStructureColor)
        label.new(int(math.avg(activeLowBar, bar_index)), activeLow,
             marketBias == 1 ? "CHoCH" : "BOS", color = color.new(color.white, 100),
             textcolor = bearStructureColor, style = label.style_label_up, size = size.tiny)
    lowBroken := true
    marketBias := -1

//------------------------------------------------------------------------------
// Liquidity sweeps
// A bearish sweep wicks above a confirmed swing high and closes back below it.
// A bullish sweep wicks below a confirmed swing low and closes back above it.
//------------------------------------------------------------------------------
sweepGroup = "Liquidity Sweeps"
showSweeps = input.bool(true, "Show liquidity sweeps", group = sweepGroup)
showSweepLines = input.bool(true, "Draw swept level", group = sweepGroup)
oneSweepPerLevel = input.bool(true, "Only first sweep per swing", group = sweepGroup)
requireCandleDirection = input.bool(false, "Require rejection candle direction", group = sweepGroup,
     tooltip = "Bullish sweeps require a bullish candle; bearish sweeps require a bearish candle.")
minWickAtr = input.float(0.0, "Minimum penetration (ATR)", minval = 0, step = 0.05, group = sweepGroup,
     tooltip = "0 accepts any wick through the level. Raise this to filter very small sweeps.")
atrLength = input.int(14, "ATR length", minval = 1, group = sweepGroup)
bullSweepColor = input.color(#00bcd4, "Bullish sweep colour", group = sweepGroup)
bearSweepColor = input.color(#ff9800, "Bearish sweep colour", group = sweepGroup)

atr = ta.atr(atrLength)
enoughLowPenetration = not na(activeLow) and activeLow - low >= atr * minWickAtr
enoughHighPenetration = not na(activeHigh) and high - activeHigh >= atr * minWickAtr

bullishSweep = barstate.isconfirmed and showSweeps and not na(activeLow) and not lowBroken and
     low < activeLow and close > activeLow and enoughLowPenetration and
     (not requireCandleDirection or close > open) and (not oneSweepPerLevel or not lowSwept)

bearishSweep = barstate.isconfirmed and showSweeps and not na(activeHigh) and not highBroken and
     high > activeHigh and close < activeHigh and enoughHighPenetration and
     (not requireCandleDirection or close < open) and (not oneSweepPerLevel or not highSwept)

if bullishSweep
    label.new(bar_index, low, "SSL Sweep\n▲", color = color.new(bullSweepColor, 80),
         textcolor = bullSweepColor, style = label.style_label_up, size = size.small,
         tooltip = "Sell-side liquidity swept: price traded below a confirmed swing low and closed back above it.")
    if showSweepLines
        line.new(activeLowBar, activeLow, bar_index, activeLow, color = bullSweepColor,
             style = line.style_dashed)
    lowSwept := true

if bearishSweep
    label.new(bar_index, high, "BSL Sweep\n▼", color = color.new(bearSweepColor, 80),
         textcolor = bearSweepColor, style = label.style_label_down, size = size.small,
         tooltip = "Buy-side liquidity swept: price traded above a confirmed swing high and closed back below it.")
    if showSweepLines
        line.new(activeHighBar, activeHigh, bar_index, activeHigh, color = bearSweepColor,
             style = line.style_dashed)
    highSwept := true

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(bullFvg, "Bullish FVG", "Bullish fair value gap detected on {{ticker}} {{interval}}")
alertcondition(bearFvg, "Bearish FVG", "Bearish fair value gap detected on {{ticker}} {{interval}}")
alertcondition(bullStructureBreak, "Bullish BOS / CHoCH", "Bullish structure break on {{ticker}} {{interval}}")
alertcondition(bearStructureBreak, "Bearish BOS / CHoCH", "Bearish structure break on {{ticker}} {{interval}}")
alertcondition(bullishSweep, "Bullish Liquidity Sweep", "Sell-side liquidity sweep on {{ticker}} {{interval}}")
alertcondition(bearishSweep, "Bearish Liquidity Sweep", "Buy-side liquidity sweep on {{ticker}} {{interval}}")
````
