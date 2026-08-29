<!-- tradingview-pine-id: PUB;155dcb6ec6ff46d3994fbfb59df60d68 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Market Structure - JOHNSON

Source: https://www.tradingview.com/script/0yiArjkK-Smart-Market-Structure-JOHNSON/

## Description

Smart Market Structure (SMC)
A powerful Smart Money Concept based indicator designed to help traders understand market structure, liquidity and institutional price action.

Features:
- Swing High & Swing Low Detection
- Break of Structure (BOS)
- Change of Character (CHoCH)
- Supply & Demand Zones
- Dynamic Support & Resistance
- Major Equilibrium (50% Level)
- Liquidity Sweep Detection
- Order Block Zones
- Fair Value Gap (FVG)
- Premium & Discount Areas
- Buy/Sell Confirmation (future update)

How to Use:
1. Identify Market Direction:
- BOS above previous high indicates bullish structure.
- BOS below previous low indicates bearish structure.
2. Find Entry Areas:
- Buy from Demand Zone or Bullish Order Block.
- Sell from Supply Zone or Bearish Order Block.
3. Entry Confirmation:
- Liquidity Sweep
- CHoCH reversal
- Fair Value Gap reaction

Recommended Timeframes:

Scalping:
- 5 Minute
- 15 Minute

Intraday Trading:
- 30 Minute
- 1 Hour

Swing Trading:
- 4 Hour
- Daily

Best Approach:
Use Higher Timeframe for market direction and Lower Timeframe for accurate entries.

Example:
Daily / 4H = Trend Direction
15M / 5M = Entry Setup

Risk Management:
Always use proper Stop Loss and Risk Management.
This indicator is a trading assistant and does not guarantee profit.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnsonForexTrader

//@version=6
indicator("Smart Market Structure - JOHNSON", overlay=true, max_labels_count=500)

//=====================
// Inputs
//=====================
pivotLen = input.int(5, "Swing Length", minval=2)
showSwings = input.bool(true, "Show Swing Points")
showBOS = input.bool(true, "Show BOS")
showCHoCH = input.bool(true, "Show CHoCH")

//=====================
// Swing Detection
//=====================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph
    if showSwings
        label.new(bar_index-pivotLen, ph, "SH",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white)

if not na(pl)
    lastLow := pl
    if showSwings
        label.new(bar_index-pivotLen, pl, "SL",
             style=label.style_label_up,
             color=color.lime,
             textcolor=color.black)

//=====================
// Trend Detection
//=====================
var int trend = 0

bullBreak = not na(lastHigh) and close > lastHigh
bearBreak = not na(lastLow) and close < lastLow

if bullBreak
    if trend == -1
        if showCHoCH
            label.new(bar_index, high, "CHoCH",
                style=label.style_label_down,
                color=color.orange,
                textcolor=color.white)
    else
        if showBOS
            label.new(bar_index, high, "BOS",
                style=label.style_label_down,
                color=color.green,
                textcolor=color.white)
    trend := 1

if bearBreak
    if trend == 1
        if showCHoCH
            label.new(bar_index, low, "CHoCH",
                style=label.style_label_up,
                color=color.orange,
                textcolor=color.white)
    else
        if showBOS
            label.new(bar_index, low, "BOS",
                style=label.style_label_up,
                color=color.red,
                textcolor=color.white)
    trend := -1
    //==================================================
// PART 2 - Supply & Demand Zones
//==================================================

showZones = input.bool(true, "Show Supply & Demand")
zoneATR = input.float(0.5, "Zone Size (ATR)", step = 0.1)

atr = ta.atr(14)

var box supplyBox = na
var box demandBox = na

// Supply Zone
if not na(ph) and showZones
    if not na(supplyBox)
        box.delete(supplyBox)

    supplyBox := box.new(
         left = bar_index - pivotLen,
         top = ph + atr * zoneATR,
         right = bar_index + 20,
         bottom = ph,
         bgcolor = color.new(color.red, 85),
         border_color = color.red)

// Demand Zone
if not na(pl) and showZones
    if not na(demandBox)
        box.delete(demandBox)

    demandBox := box.new(
         left = bar_index - pivotLen,
         top = pl,
         right = bar_index + 20,
         bottom = pl - atr * zoneATR,
         bgcolor = color.new(color.green, 85),
         border_color = color.lime)

// Extend Zones
if not na(supplyBox)
    box.set_right(supplyBox, bar_index + 20)

if not na(demandBox)
    box.set_right(demandBox, bar_index + 20)
    //==================================================
// PART 3 - Dynamic Support / Resistance + EQ
//==================================================

showSR = input.bool(true, "Show Support & Resistance")
showEQ = input.bool(true, "Show Major EQ")

var line resLine = na
var line supLine = na
var line eqLine = na

// Resistance
if not na(ph) and showSR
    if not na(resLine)
        line.delete(resLine)

    resLine := line.new(
         x1=bar_index-pivotLen,
         y1=ph,
         x2=bar_index+30,
         y2=ph,
         extend=extend.right,
         color=color.red,
         width=2)

// Support
if not na(pl) and showSR
    if not na(supLine)
        line.delete(supLine)

    supLine := line.new(
         x1=bar_index-pivotLen,
         y1=pl,
         x2=bar_index+30,
         y2=pl,
         extend=extend.right,
         color=color.lime,
         width=2)

// Major EQ (50%)
if not na(lastHigh) and not na(lastLow) and showEQ
    eq = (lastHigh + lastLow) / 2

    if not na(eqLine)
        line.delete(eqLine)

    eqLine := line.new(
         x1=bar_index-30,
         y1=eq,
         x2=bar_index+30,
         y2=eq,
         extend=extend.right,
         color=color.aqua,
         style=line.style_dashed,
         width=2)

    label.new(
         bar_index,
         eq,
         "Major EQ (50%)",
         style=label.style_none,
         textcolor=color.aqua)
         //==================================================
// PART 4 - Liquidity + Order Block + FVG
//==================================================

showLiquidity = input.bool(true, "Show Liquidity Sweep")
showOB = input.bool(true, "Show Order Blocks")
showFVG = input.bool(true, "Show Fair Value Gap")
showPD = input.bool(true, "Show Premium/Discount")

//-------------------------
// Liquidity Sweep
//-------------------------

liqLen = input.int(20, "Liquidity Lookback")

liqHigh = ta.highest(high, liqLen)
liqLow  = ta.lowest(low, liqLen)

bullSweep = low < liqLow[1] and close > liqLow[1]
bearSweep = high > liqHigh[1] and close < liqHigh[1]

if showLiquidity and bullSweep
    label.new(
     bar_index,
     low,
     "Liquidity Sweep\nBUY",
     style=label.style_label_up,
     color=color.green,
     textcolor=color.white)

if showLiquidity and bearSweep
    label.new(
     bar_index,
     high,
     "Liquidity Sweep\nSELL",
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white)


//-------------------------
// Order Block
//-------------------------

var box bullOB = na
var box bearOB = na

if showOB and bullSweep
    if not na(bullOB)
        box.delete(bullOB)

    bullOB := box.new(
     left=bar_index-1,
     top=high[1],
     right=bar_index+30,
     bottom=low[1],
     bgcolor=color.new(color.green,85),
     border_color=color.green)


if showOB and bearSweep
    if not na(bearOB)
        box.delete(bearOB)

    bearOB := box.new(
     left=bar_index-1,
     top=high[1],
     right=bar_index+30,
     bottom=low[1],
     bgcolor=color.new(color.red,85),
     border_color=color.red)


//-------------------------
// Fair Value Gap (FVG)
//-------------------------

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(
     left=bar_index-2,
     top=low,
     right=bar_index+20,
     bottom=high[2],
     bgcolor=color.new(color.green,90),
     border_color=color.green)

if showFVG and bearFVG
    box.new(
     left=bar_index-2,
     top=low[2],
     right=bar_index+20,
     bottom=high,
     bgcolor=color.new(color.red,90),
     border_color=color.red)


//-------------------------
// Premium / Discount Zone
//-------------------------

if showPD and not na(lastHigh) and not na(lastLow)

    mid = (lastHigh + lastLow)/2

    line.new(
     bar_index-20,
     mid,
     bar_index+20,
     mid,
     color=color.yellow,
     style=line.style_dashed)

    label.new(
     bar_index,
     mid,
     "EQ",
     style=label.style_none,
     textcolor=color.yellow)
````
