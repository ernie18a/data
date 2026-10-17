# ORB Indicator

- url: https://www.tradingview.com/script/GvGjl0yA-ORB-Indicator/
- type: indicator
- pine_id: PUB;aca1da8c1af142f6be11ebc92c72bea3
- version: 1.0

## Description

ORB indicator telling you when to enter SL TP and when to LONG or SHORT

## Source Code

````pine
//@version=5
indicator("ORB Indicator", overlay=true, max_boxes_count=200, max_labels_count=200, max_lines_count=200)

//====================================================
// Inputs
//====================================================
groupSetup = "Setup Logic"
sweepLen        = input.int(10, "Liquidity Sweep Lookback", minval=2, group=groupSetup)
bosLen          = input.int(10, "BOS Lookback", minval=2, group=groupSetup)
fvgMaxWaitBars  = input.int(5, "Max Bars After Sweep To Create FVG", minval=1, group=groupSetup)
bosMaxWaitBars  = input.int(10, "Max Bars After FVG For BOS", minval=1, group=groupSetup)
bigCandleATR    = input.float(1.0, "Big Candle Size ATR Multiplier", step=0.1, group=groupSetup)
atrLen          = input.int(14, "ATR Length", minval=1, group=groupSetup)

groupTrade = "Entry / Stop Display"
entryLevelMode  = input.string("Top of FVG", "Entry Level", options=["Top of FVG", "Middle of FVG", "Bottom of FVG"], group=groupTrade)
stopBufferTicks = input.int(2, "Stop Buffer Ticks Outside FVG", minval=0, group=groupTrade)
extendBars      = input.int(30, "Extend Entry/SL Lines", minval=1, maxval=300, group=groupTrade)

groupVisual = "Visuals"
showFVGBox      = input.bool(true, "Show FVG Box", group=groupVisual)
showEntrySL     = input.bool(true, "Show Entry and SL Lines", group=groupVisual)
showLabels      = input.bool(true, "Show Setup Labels", group=groupVisual)
bullFvgColor    = input.color(color.new(color.lime, 82), "Bullish FVG Color", group=groupVisual)
bearFvgColor    = input.color(color.new(color.red, 82), "Bearish FVG Color", group=groupVisual)
entryColor      = input.color(color.new(color.yellow, 0), "Entry Line Color", group=groupVisual)
stopColor       = input.color(color.new(color.red, 0), "Stop Line Color", group=groupVisual)
bosColor        = input.color(color.new(color.aqua, 0), "BOS Label Color", group=groupVisual)

//====================================================
// Base Calculations
//====================================================
atr = ta.atr(atrLen)
tick = syminfo.mintick
stopBuffer = stopBufferTicks * tick

bigBullCandle = close > open and (high - low) >= atr * bigCandleATR
bigBearCandle = close < open and (high - low) >= atr * bigCandleATR

//====================================================
// Liquidity Sweep
// Bullish sweep: takes prior lows, closes back above.
// Bearish sweep: takes prior highs, closes back below.
//====================================================
priorLow  = ta.lowest(low[1], sweepLen)
priorHigh = ta.highest(high[1], sweepLen)

bullSweep = low < priorLow and close > priorLow
bearSweep = high > priorHigh and close < priorHigh

//====================================================
// FVG Detection
// Bullish FVG: low > high[2]
// Bearish FVG: high < low[2]
//====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

bullFvgTop = low
bullFvgBot = high[2]

bearFvgTop = low[2]
bearFvgBot = high

//====================================================
// BOS Detection
// Bullish BOS: big candle closes above prior high.
// Bearish BOS: big candle closes below prior low.
//====================================================
bosHigh = ta.highest(high[1], bosLen)
bosLow  = ta.lowest(low[1], bosLen)

bullBOS = bigBullCandle and close > bosHigh
bearBOS = bigBearCandle and close < bosLow

//====================================================
// State Machine For Bullish Setup
// 1. Liquidity sweep
// 2. Creates FVG
// 3. FVG remains untested before BOS
// 4. Big BOS candle
//====================================================
var int bullState = 0
var int bullSweepBar = na
var int bullFvgBar = na
var float bullZoneTop = na
var float bullZoneBot = na
var bool bullFvgTested = false

if bullSweep
    bullState := 1
    bullSweepBar := bar_index
    bullFvgBar := na
    bullZoneTop := na
    bullZoneBot := na
    bullFvgTested := false

if bullState == 1
    if bar_index - bullSweepBar > fvgMaxWaitBars
        bullState := 0
    else if bullFVG
        bullState := 2
        bullFvgBar := bar_index
        bullZoneTop := bullFvgTop
        bullZoneBot := bullFvgBot
        bullFvgTested := false

if bullState == 2
    if bar_index > bullFvgBar and low <= bullZoneTop
        bullFvgTested := true

    if bar_index - bullFvgBar > bosMaxWaitBars
        bullState := 0

// Bullish valid setup requires:
// - FVG created after sweep
// - price did NOT retrace into the FVG before BOS
// - big bullish BOS candle
bullSetup = bullState == 2 and not bullFvgTested and bullBOS

//====================================================
// State Machine For Bearish Setup
//====================================================
var int bearState = 0
var int bearSweepBar = na
var int bearFvgBar = na
var float bearZoneTop = na
var float bearZoneBot = na
var bool bearFvgTested = false

if bearSweep
    bearState := 1
    bearSweepBar := bar_index
    bearFvgBar := na
    bearZoneTop := na
    bearZoneBot := na
    bearFvgTested := false

if bearState == 1
    if bar_index - bearSweepBar > fvgMaxWaitBars
        bearState := 0
    else if bearFVG
        bearState := 2
        bearFvgBar := bar_index
        bearZoneTop := bearFvgTop
        bearZoneBot := bearFvgBot
        bearFvgTested := false

if bearState == 2
    if bar_index > bearFvgBar and high >= bearZoneBot
        bearFvgTested := true

    if bar_index - bearFvgBar > bosMaxWaitBars
        bearState := 0

bearSetup = bearState == 2 and not bearFvgTested and bearBOS

//====================================================
// Entry / Stop Level Helpers
//====================================================
f_entryPrice(_top, _bot, _isBull) =>
    entryLevelMode == "Middle of FVG" ? (_top + _bot) / 2.0 :
     entryLevelMode == "Bottom of FVG" ? _bot :
     _top

bullEntry = f_entryPrice(bullZoneTop, bullZoneBot, true)
bullStop  = bullZoneBot - stopBuffer

bearEntry = f_entryPrice(bearZoneTop, bearZoneBot, false)
bearStop  = bearZoneTop + stopBuffer

//====================================================
// Draw Bullish Setup
//====================================================
if bullSetup
    if showFVGBox
        box.new(
             left=bullFvgBar - 2,
             top=bullZoneTop,
             right=bar_index + extendBars,
             bottom=bullZoneBot,
             xloc=xloc.bar_index,
             bgcolor=bullFvgColor,
             border_color=color.new(color.lime, 10))

    if showEntrySL
        line.new(
             x1=bar_index,
             y1=bullEntry,
             x2=bar_index + extendBars,
             y2=bullEntry,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=entryColor,
             width=2)

        line.new(
             x1=bar_index,
             y1=bullStop,
             x2=bar_index + extendBars,
             y2=bullStop,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=stopColor,
             width=2)

    if showLabels
        label.new(
             bar_index,
             low,
             "BUY OB\nSweep + FVG + Untested + BOS\nEntry: FVG\nSL: Below FVG",
             style=label.style_label_up,
             color=color.new(color.lime, 0),
             textcolor=color.white,
             size=size.small)

        label.new(
             bar_index,
             high,
             "BOS",
             style=label.style_label_down,
             color=bosColor,
             textcolor=color.white,
             size=size.tiny)

    bullState := 0

//====================================================
// Draw Bearish Setup
//====================================================
if bearSetup
    if showFVGBox
        box.new(
             left=bearFvgBar - 2,
             top=bearZoneTop,
             right=bar_index + extendBars,
             bottom=bearZoneBot,
             xloc=xloc.bar_index,
             bgcolor=bearFvgColor,
             border_color=color.new(color.red, 10))

    if showEntrySL
        line.new(
             x1=bar_index,
             y1=bearEntry,
             x2=bar_index + extendBars,
             y2=bearEntry,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=entryColor,
             width=2)

        line.new(
             x1=bar_index,
             y1=bearStop,
             x2=bar_index + extendBars,
             y2=bearStop,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=stopColor,
             width=2)

    if showLabels
        label.new(
             bar_index,
             high,
             "SELL OB\nSweep + FVG + Untested + BOS\nEntry: FVG\nSL: Above FVG",
             style=label.style_label_down,
             color=color.new(color.red, 0),
             textcolor=color.white,
             size=size.small)

        label.new(
             bar_index,
             low,
             "BOS",
             style=label.style_label_up,
             color=bosColor,
             textcolor=color.white,
             size=size.tiny)

    bearState := 0

//====================================================
// Alerts
//====================================================
alertcondition(bullSetup, "Bullish OB Setup", "Bullish OB setup: Sweep + FVG + Untested + BOS")
alertcondition(bearSetup, "Bearish OB Setup", "Bearish OB setup: Sweep + FVG + Untested + BOS")
````
