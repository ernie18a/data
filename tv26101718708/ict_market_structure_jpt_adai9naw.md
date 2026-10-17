# ICT Market Structure [JPT] 

- url: https://www.tradingview.com/script/adaI9naW-ICT-Market-Structure-JPT/
- type: indicator
- pine_id: PUB;a253d65bf3b2484081044a3507afb656
- version: 2.0

## Description

[b]ICT Market Structure [JPT][/b]  is an educational market structure indicator that automatically identifies Higher Highs, Higher Lows, Lower Highs, Lower Lows, Break of Structure (BOS), and Change of Character (CHOCH) using confirmed swing points. The indicator also highlights potential Demand and Supply Order Blocks to help traders analyze structural continuation and potential market reversals.

The indicator is designed to help traders visualize market structure and identify important price reaction zones. It does not predict future price movement or guarantee profitable trades.

🔷 FEATURES

Automatic market structure detection
Higher High (HH) and Higher Low (HL) identification
Lower High (LH) and Lower Low (LL) identification
Bullish and bearish Break of Structure (BOS)
Bullish and bearish Change of Character (CHOCH)
Automatic Demand Order Block detection
Automatic Supply Order Block detection
Confirmed swing-based structure
Optional Order Block retest analysis
Automatic broken/invalidated zone removal
Customizable swing and Order Block settings
Clean chart layout with minimal clutter

🔷 HOW IT WORKS

Detects confirmed swing highs and swing lows.
Classifies market structure into HH, HL, LH, and LL.
Monitors important swing levels for structural breaks.
Identifies potential BOS events when price breaks established structure.
Identifies potential CHOCH events when market structure shifts.
Searches for relevant bullish and bearish candles around structural breaks to create potential Order Blocks.
Displays Demand and Supply zones directly on the chart for market structure analysis.

🔷 HOW TO USE

Start by observing the current HH / HL / LH / LL structure.
Use BOS to identify potential continuation of the existing market structure.
Use CHOCH to monitor potential changes in market direction.
Watch how price reacts when returning to a Demand or Supply Order Block.
Use Order Blocks as areas of interest rather than automatic entry signals.
Combine the structure information with your own confirmation methods and risk management rules.

🔷 MARKET STRUCTURE GUIDE

Bullish Structure:
HH → HL → BOS → continuation

Bearish Structure:
LH → LL → BOS → continuation

Potential Structural Shift:
Existing Structure → CHOCH → New Direction → New BOS

🔷 NOTES

Structure is based on confirmed swing points.
Historical structure may appear only after the required swing confirmation period.
Order Blocks are analytical zones and should not be considered guaranteed reversal areas.
BOS and CHOCH are designed to help visualize structural changes, not predict future price movement.
The indicator is intended as an educational and analytical tool.
No indicator can guarantee successful trades, and this script should not be used as the sole basis for investment or trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("ICT Market Structure [JPT] ", shorttitle="ICT-MS [JPT]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 • SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStructure = "01 • Market Structure"

pivotLen = input.int(5, "Swing Length", minval=2, maxval=30, group=groupStructure)
showSwings = input.bool(true, "Show HH / HL / LH / LL", group=groupStructure)
showBOS = input.bool(true, "Show BOS", group=groupStructure)
showCHOCH = input.bool(true, "Show CHOCH", group=groupStructure)

groupOB = "02 • Order Block Engine"

showOB = input.bool(true, "Show Order Blocks", group=groupOB)
obLookback = input.int(10, "OB Search Bars", minval=2, maxval=30, group=groupOB)
obExtend = input.int(40, "OB Extension", minval=5, maxval=200, group=groupOB)
maxZones = input.int(10, "Maximum Active Zones", minval=1, maxval=30, group=groupOB)
deleteBroken = input.bool(true, "Delete Broken Zones", group=groupOB)

groupConfirm = "03 • Signal Confirmation"

useRetest = input.bool(true, "Require OB Retest", group=groupConfirm)
useEMA = input.bool(true, "Use EMA 50 / 200 Filter", group=groupConfirm)
useDisplacement = input.bool(true, "Use Displacement Filter", group=groupConfirm)
atrLength = input.int(14, "ATR Length", minval=1, group=groupConfirm)
minBodyATR = input.float(0.50, "Minimum Candle Body / ATR", minval=0.10, step=0.05, group=groupConfirm)

groupRisk = "04 • Trade Levels"

showTradeLevels = input.bool(true, "Show Entry / SL / TP", group=groupRisk)
slBufferATR = input.float(0.20, "SL ATR Buffer", minval=0.0, step=0.05, group=groupRisk)
rr1 = input.float(1.0, "TP1 Risk Reward", minval=0.25, step=0.25, group=groupRisk)
rr2 = input.float(2.0, "TP2 Risk Reward", minval=0.50, step=0.25, group=groupRisk)
rr3 = input.float(3.0, "TP3 Risk Reward", minval=0.75, step=0.25, group=groupRisk)

groupVisual = "05 • Visual"

bullOBColor = input.color(color.new(color.green, 82), "Bullish Demand", group=groupVisual)
bearOBColor = input.color(color.new(color.red, 82), "Bearish Supply", group=groupVisual)
bullBorder = input.color(color.green, "Bullish Border", group=groupVisual)
bearBorder = input.color(color.red, "Bearish Border", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 • EMA TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

plot(ema50, "EMA 50", color=color.new(color.green, 15), linewidth=2)
plot(ema200, "EMA 200", color=color.new(color.red, 15), linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 • ATR / DISPLACEMENT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(atrLength)

body = math.abs(close - open)

bullDisplacement =
     close > open and
     body >= atr * minBodyATR

bearDisplacement =
     close < open and
     body >= atr * minBodyATR


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 • CONFIRMED SWING ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float previousSwingHigh = na
var int lastSwingHighBar = na

var float lastSwingLow = na
var float previousSwingLow = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    previousSwingHigh := lastSwingHigh
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotLen

if not na(pivotLow)
    previousSwingLow := lastSwingLow
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotLen


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 • MARKET STRUCTURE CLASSIFICATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

newHigh = not na(pivotHigh)
newLow = not na(pivotLow)

isHH = newHigh and not na(previousSwingHigh) and pivotHigh > previousSwingHigh
isLH = newHigh and not na(previousSwingHigh) and pivotHigh < previousSwingHigh

isHL = newLow and not na(previousSwingLow) and pivotLow > previousSwingLow
isLL = newLow and not na(previousSwingLow) and pivotLow < previousSwingLow

if showSwings and isHH
    label.new(
         bar_index - pivotLen,
         pivotHigh,
         "HH",
         style=label.style_label_down,
         color=color.new(color.green, 20),
         textcolor=color.white,
         size=size.tiny)

if showSwings and isLH
    label.new(
         bar_index - pivotLen,
         pivotHigh,
         "LH",
         style=label.style_label_down,
         color=color.new(color.orange, 20),
         textcolor=color.white,
         size=size.tiny)

if showSwings and isHL
    label.new(
         bar_index - pivotLen,
         pivotLow,
         "HL",
         style=label.style_label_up,
         color=color.new(color.green, 20),
         textcolor=color.white,
         size=size.tiny)

if showSwings and isLL
    label.new(
         bar_index - pivotLen,
         pivotLow,
         "LL",
         style=label.style_label_up,
         color=color.new(color.red, 20),
         textcolor=color.white,
         size=size.tiny)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 • STRUCTURE BREAK ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int marketBias = 0

bullBreak =
     not na(lastSwingHigh) and
     close > lastSwingHigh and
     close[1] <= lastSwingHigh

bearBreak =
     not na(lastSwingLow) and
     close < lastSwingLow and
     close[1] >= lastSwingLow

bullCHOCH = bullBreak and marketBias == -1
bearCHOCH = bearBreak and marketBias == 1

bullBOS = bullBreak and marketBias != -1
bearBOS = bearBreak and marketBias != 1

if bullBreak
    marketBias := 1

if bearBreak
    marketBias := -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07 • BOS VISUALIZATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bullBOS and showBOS
    line.new(
         lastSwingHighBar,
         lastSwingHigh,
         bar_index,
         lastSwingHigh,
         color=color.green,
         width=2)

    label.new(
         bar_index,
         lastSwingHigh,
         "BOS ↑",
         style=label.style_label_up,
         color=color.new(color.green, 10),
         textcolor=color.white,
         size=size.small)

if bearBOS and showBOS
    line.new(
         lastSwingLowBar,
         lastSwingLow,
         bar_index,
         lastSwingLow,
         color=color.red,
         width=2)

    label.new(
         bar_index,
         lastSwingLow,
         "BOS ↓",
         style=label.style_label_down,
         color=color.new(color.red, 10),
         textcolor=color.white,
         size=size.small)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 08 • CHOCH VISUALIZATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bullCHOCH and showCHOCH
    line.new(
         lastSwingHighBar,
         lastSwingHigh,
         bar_index,
         lastSwingHigh,
         color=color.aqua,
         width=3)

    label.new(
         bar_index,
         lastSwingHigh,
         "CHOCH ↑",
         style=label.style_label_up,
         color=color.aqua,
         textcolor=color.black,
         size=size.normal)

if bearCHOCH and showCHOCH
    line.new(
         lastSwingLowBar,
         lastSwingLow,
         bar_index,
         lastSwingLow,
         color=color.orange,
         width=3)

    label.new(
         bar_index,
         lastSwingLow,
         "CHOCH ↓",
         style=label.style_label_down,
         color=color.orange,
         textcolor=color.black,
         size=size.normal)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09 • ORDER BLOCK ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box[] bullZones = array.new_box()
var box[] bearZones = array.new_box()

var float currentBullTop = na
var float currentBullBottom = na

var float currentBearTop = na
var float currentBearBottom = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10 • FIND LAST BEARISH CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_findBearish(_lookback) =>
    int result = na

    for i = 1 to _lookback
        if close[i] < open[i]
            result := i
            break

    result


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11 • FIND LAST BULLISH CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_findBullish(_lookback) =>
    int result = na

    for i = 1 to _lookback
        if close[i] > open[i]
            result := i
            break

    result


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12 • BULLISH DEMAND ORDER BLOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bullBreak and showOB

    bearishCandle = f_findBearish(obLookback)

    if not na(bearishCandle)

        top = high[bearishCandle]
        bottom = low[bearishCandle]

        currentBullTop := top
        currentBullBottom := bottom

        newZone = box.new(
             left=bar_index - bearishCandle,
             top=top,
             right=bar_index + obExtend,
             bottom=bottom,
             bgcolor=bullOBColor,
             border_color=bullBorder,
             text="DEMAND OB",
             text_color=color.green,
             text_size=size.small,
             text_halign=text.align_right)

        array.push(bullZones, newZone)

        if array.size(bullZones) > maxZones
            oldZone = array.shift(bullZones)
            box.delete(oldZone)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13 • BEARISH SUPPLY ORDER BLOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bearBreak and showOB

    bullishCandle = f_findBullish(obLookback)

    if not na(bullishCandle)

        top = high[bullishCandle]
        bottom = low[bullishCandle]

        currentBearTop := top
        currentBearBottom := bottom

        newZone = box.new(
             left=bar_index - bullishCandle,
             top=top,
             right=bar_index + obExtend,
             bottom=bottom,
             bgcolor=bearOBColor,
             border_color=bearBorder,
             text="SUPPLY OB",
             text_color=color.red,
             text_size=size.small,
             text_halign=text.align_right)

        array.push(bearZones, newZone)

        if array.size(bearZones) > maxZones
            oldZone = array.shift(bearZones)
            box.delete(oldZone)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 14 • BULLISH ZONE MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if array.size(bullZones) > 0

    for i = array.size(bullZones) - 1 to 0

        zone = array.get(bullZones, i)

        top = box.get_top(zone)
        bottom = box.get_bottom(zone)

        box.set_right(zone, bar_index + obExtend)

        broken = close < bottom

        if broken and deleteBroken
            box.delete(zone)
            array.remove(bullZones, i)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15 • BEARISH ZONE MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if array.size(bearZones) > 0

    for i = array.size(bearZones) - 1 to 0

        zone = array.get(bearZones, i)

        top = box.get_top(zone)
        bottom = box.get_bottom(zone)

        box.set_right(zone, bar_index + obExtend)

        broken = close > top

        if broken and deleteBroken
            box.delete(zone)
            array.remove(bearZones, i)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 16 • ORDER BLOCK RETEST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullRetest =
     not na(currentBullTop) and
     not na(currentBullBottom) and
     low <= currentBullTop and
     high >= currentBullBottom and
     close >= currentBullBottom

bearRetest =
     not na(currentBearTop) and
     not na(currentBearBottom) and
     high >= currentBearBottom and
     low <= currentBearTop and
     close <= currentBearTop


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 17 • CANDLE CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullConfirm =
     close > open and
     close > high[1]

bearConfirm =
     close < open and
     close < low[1]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 18 • FINAL BUY / SELL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buySetup =
     marketBias == 1 and
     (not useEMA or bullTrend) and
     (not useDisplacement or bullDisplacement) and
     (not useRetest or bullRetest) and
     bullConfirm and
     barstate.isconfirmed

sellSetup =
     marketBias == -1 and
     (not useEMA or bearTrend) and
     (not useDisplacement or bearDisplacement) and
     (not useRetest or bearRetest) and
     bearConfirm and
     barstate.isconfirmed


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 19 • SIGNAL LOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastBuyBar = na
var int lastSellBar = na

newBuy =
     buySetup and
     lastBuyBar != bar_index

newSell =
     sellSetup and
     lastSellBar != bar_index

if newBuy
    lastBuyBar := bar_index

if newSell
    lastSellBar := bar_index


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 • TRADE LEVEL VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float entry = na
var float stop = na
var float target1 = na
var float target2 = na
var float target3 = na

var line entryLine = na
var line stopLine = na
var line target1Line = na
var line target2Line = na
var line target3Line = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 21 • BUY TRADE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newBuy

    entry := close

    baseStop = not na(currentBullBottom) ? currentBullBottom : low

    stop := baseStop - atr * slBufferATR

    risk = entry - stop

    if risk > syminfo.mintick

        target1 := entry + risk * rr1
        target2 := entry + risk * rr2
        target3 := entry + risk * rr3


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 22 • SELL TRADE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newSell

    entry := close

    baseStop = not na(currentBearTop) ? currentBearTop : high

    stop := baseStop + atr * slBufferATR

    risk = stop - entry

    if risk > syminfo.mintick

        target1 := entry - risk * rr1
        target2 := entry - risk * rr2
        target3 := entry - risk * rr3


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 23 • DRAW BUY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showTradeLevels and newBuy and not na(target3)

    if not na(entryLine)
        line.delete(entryLine)

    if not na(stopLine)
        line.delete(stopLine)

    if not na(target1Line)
        line.delete(target1Line)

    if not na(target2Line)
        line.delete(target2Line)

    if not na(target3Line)
        line.delete(target3Line)

    entryLine := line.new(
         bar_index,
         entry,
         bar_index + 25,
         entry,
         color=color.blue,
         width=2)

    stopLine := line.new(
         bar_index,
         stop,
         bar_index + 25,
         stop,
         color=color.red,
         width=2)

    target1Line := line.new(
         bar_index,
         target1,
         bar_index + 25,
         target1,
         color=color.green,
         width=1)

    target2Line := line.new(
         bar_index,
         target2,
         bar_index + 25,
         target2,
         color=color.green,
         width=1)

    target3Line := line.new(
         bar_index,
         target3,
         bar_index + 25,
         target3,
         color=color.green,
         width=2)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 24 • DRAW SELL LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showTradeLevels and newSell and not na(target3)

    if not na(entryLine)
        line.delete(entryLine)

    if not na(stopLine)
        line.delete(stopLine)

    if not na(target1Line)
        line.delete(target1Line)

    if not na(target2Line)
        line.delete(target2Line)

    if not na(target3Line)
        line.delete(target3Line)

    entryLine := line.new(
         bar_index,
         entry,
         bar_index + 25,
         entry,
         color=color.blue,
         width=2)

    stopLine := line.new(
         bar_index,
         stop,
         bar_index + 25,
         stop,
         color=color.red,
         width=2)

    target1Line := line.new(
         bar_index,
         target1,
         bar_index + 25,
         target1,
         color=color.green,
         width=1)

    target2Line := line.new(
         bar_index,
         target2,
         bar_index + 25,
         target2,
         color=color.green,
         width=1)

    target3Line := line.new(
         bar_index,
         target3,
         bar_index + 25,
         target3,
         color=color.green,
         width=2)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 25 • BUY / SELL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     newBuy,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     text="BUY",
     size=size.small)

plotshape(
     newSell,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     text="SELL",
     size=size.small)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 26 • ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     bullBOS,
     title="Bullish BOS",
     message="Smart BOS CHOCH OB: Bullish BOS confirmed.")

alertcondition(
     bearBOS,
     title="Bearish BOS",
     message="Smart BOS CHOCH OB: Bearish BOS confirmed.")

alertcondition(
     bullCHOCH,
     title="Bullish CHOCH",
     message="Smart BOS CHOCH OB: Bullish CHOCH confirmed.")

alertcondition(
     bearCHOCH,
     title="Bearish CHOCH",
     message="Smart BOS CHOCH OB: Bearish CHOCH confirmed.")

alertcondition(
     newBuy,
     title="BUY Confirmation",
     message="Smart BOS CHOCH OB: BUY confirmation.")

alertcondition(
     newSell,
     title="SELL Confirmation",
     message="Smart BOS CHOCH OB: SELL confirmation.")
````
