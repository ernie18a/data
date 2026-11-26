# Black Diamond - Liquidity Zones With Alerts V6

- url: https://www.tradingview.com/script/DdQTZscJ-Black-Diamond-Liquidity-Zones-With-Alerts-V6/
- type: indicator
- pine_id: PUB;9a9b4b4b4ae2433b8b0d4eef8dbfc6da
- version: 2.0

## Description

Black Diamond Liquidity Zones With Alerts V6
Indicator Overview

Black Diamond Liquidity Zones V6 is designed to help traders identify areas where liquidity is likely resting within the market. These zones represent locations where stop losses, pending orders, breakout traders and institutional activity are commonly concentrated.

The indicator automatically detects and maps Buy Side and Sell Side liquidity zones using market structure, swing highs, swing lows and volume participation. Each liquidity zone is then classified as Strong, Moderate or Weak, allowing traders to quickly assess the significance of each level.

Unlike traditional support and resistance indicators, Black Diamond Liquidity Zones focuses on where the market is most likely to seek liquidity before making its next move.

The indicator automatically updates active liquidity zones, removes consumed zones and can generate alerts whenever price enters a liquidity area.

Core Features
Automatic Buy Side Liquidity Detection

Identifies liquidity resting above swing highs where:

Stop losses from short traders are likely positioned.
Breakout traders may enter long positions.
Institutions may seek liquidity before reversing.
Automatic Sell Side Liquidity Detection

Identifies liquidity resting below swing lows where:

Stop losses from long traders are likely positioned.
Breakdown traders may enter short positions.
Institutions may seek liquidity before reversing.
Liquidity Strength Classification

Every zone is classified as:

Strong Liquidity

Highest significance liquidity zones.

Typically:

Multiple market reactions
Higher participation
Strong structural importance
Highest probability reaction zones
Moderate Liquidity

Mid-level liquidity concentrations.

Typically:

Average market interaction
Moderate structural importance
Useful intraday targets
Weak Liquidity

Smaller liquidity pools.

Typically:

Limited interaction
Lower significance
Secondary targets
Smart Zone Merging

Nearby liquidity zones are automatically merged into a single larger liquidity pool.

This helps:

Reduce chart clutter
Improve zone quality
Highlight institutional liquidity concentrations
Automatic Liquidity Removal

When liquidity has been consumed:

The zone is automatically deleted.
Only active liquidity remains visible.
Charts remain clean and easy to read.
Built-In Alerts

Generate alerts when:

Price enters Buy Side Liquidity
Price enters Sell Side Liquidity
Price enters Any Liquidity Zone

Perfect for preparing before price reaches important areas.

Understanding Buy Side Liquidity

Buy Side Liquidity exists above previous highs.

Examples include:

Retail stop losses
Short trader exits
Breakout entries
Institutional liquidity targets

Markets frequently move into Buy Side Liquidity before:

Reversing
Continuing trend
Creating liquidity sweeps
Understanding Sell Side Liquidity

Sell Side Liquidity exists below previous lows.

Examples include:

Retail stop losses
Long trader exits
Breakdown entries
Institutional liquidity targets

Markets frequently move into Sell Side Liquidity before:

Reversing
Continuing trend
Creating liquidity sweeps
How To Use The Indicator
Liquidity Sweep Reversal Setup

Step 1

Identify a Strong Liquidity Zone.

Step 2

Wait for price to enter the zone.

Step 3

Watch for:

Rejection candles
Break of structure
Change of character
Fair value gaps

Step 4

Enter once confirmation is present.

Trend Continuation Setup

Step 1

Determine overall market trend.

Step 2

Allow price to sweep opposing liquidity.

Step 3

Wait for structure confirmation.

Step 4

Enter in trend direction.

Profit Targeting

Liquidity zones make excellent profit targets.

For Long Trades:

Target Buy Side Liquidity.

For Short Trades:

Target Sell Side Liquidity.
Best Trading Styles

Black Diamond Liquidity Zones works exceptionally well with:

Smart Money Concepts (SMC)
Liquidity Sweeps
BOS
CHOCH
Mitigation
ICT Concepts
Liquidity Pools
Premium & Discount Arrays
Market Structure Shifts
Price Action Trading
Support & Resistance
Rejection Candles
Trend Trading
Institutional Trading
Order Blocks
Fair Value Gaps
Liquidity Runs
Recommended Timeframes
Scalping

Timeframes:

1 Minute
3 Minute
5 Minute

Recommended Swing Length:

3–5
Intraday Trading

Timeframes:

15 Minute
30 Minute
1 Hour

Recommended Swing Length:

5–8
Swing Trading

Timeframes:

4 Hour
Daily

Recommended Swing Length:

8–15

## Source Code

````pine
//@version=6
indicator("Black Diamond - Liquidity Zones With Alerts", overlay=true, max_boxes_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BLACK DIAMOND - LIQUIDITY ZONES WITH ALERTS V6
// Buy Side / Sell Side Liquidity Zones
// Strong / Moderate / Weak Classification
// Alerts when price enters liquidity zones
// Zones delete when liquidity is taken
// Zones do NOT extend into future space
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
leftBars     = input.int(5, "Swing Left Bars", minval=1)
rightBars    = input.int(5, "Swing Right Bars", minval=1)
atrLength    = input.int(14, "ATR Length", minval=1)
zoneSizeATR  = input.float(0.25, "Zone Size ATR Multiplier", minval=0.01, step=0.05)
mergeATR     = input.float(0.35, "Merge Nearby Zones ATR", minval=0.01, step=0.05)
volLength    = input.int(20, "Volume Average Length", minval=1)

strongTouches   = input.int(4, "Strong Liquidity Touches", minval=2)
moderateTouches = input.int(2, "Moderate Liquidity Touches", minval=1)

showStrong   = input.bool(true, "Show Strong Liquidity")
showModerate = input.bool(true, "Show Moderate Liquidity")
showWeak     = input.bool(true, "Show Weak Liquidity")

deleteTaken  = input.bool(true, "Delete Zone When Liquidity Is Taken")
showText     = input.bool(true, "Show Text Inside Zones")
enableAlerts = input.bool(true, "Enable Liquidity Zone Alerts")

textSizeOpt  = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal", "Large"])

buyTextCol   = input.color(color.white, "Buy Side Text Colour")
sellTextCol  = input.color(color.white, "Sell Side Text Colour")

buyStrongCol   = input.color(color.red, "Buy Side Strong Liquidity")
buyModerateCol = input.color(color.orange, "Buy Side Moderate Liquidity")
buyWeakCol     = input.color(color.new(color.red, 70), "Buy Side Weak Liquidity")

sellStrongCol   = input.color(color.lime, "Sell Side Strong Liquidity")
sellModerateCol = input.color(color.teal, "Sell Side Moderate Liquidity")
sellWeakCol     = input.color(color.new(color.green, 70), "Sell Side Weak Liquidity")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr    = ta.atr(atrLength)
volAvg = ta.sma(volume, volLength)

pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

// IMPORTANT:
// This stops boxes at the current bar only.
// No future projection.
rightEdge = bar_index

textSize = textSizeOpt == "Tiny" ? size.tiny : textSizeOpt == "Small" ? size.small : textSizeOpt == "Normal" ? size.normal : size.large

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] buyBoxes = array.new_box()
var float[] buyTop = array.new_float()
var float[] buyBottom = array.new_float()
var int[] buyTouches = array.new_int()

var box[] sellBoxes = array.new_box()
var float[] sellTop = array.new_float()
var float[] sellBottom = array.new_float()
var int[] sellTouches = array.new_int()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyZoneHit  = false
sellZoneHit = false
anyZoneHit  = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_grade(touches) =>
    touches >= strongTouches ? "STRONG" : touches >= moderateTouches ? "MODERATE" : "WEAK"

f_shouldShow(grade) =>
    grade == "STRONG" ? showStrong : grade == "MODERATE" ? showModerate : showWeak

f_buyColor(grade) =>
    grade == "STRONG" ? buyStrongCol : grade == "MODERATE" ? buyModerateCol : buyWeakCol

f_sellColor(grade) =>
    grade == "STRONG" ? sellStrongCol : grade == "MODERATE" ? sellModerateCol : sellWeakCol

f_bg(col) =>
    color.new(col, 82)

f_text(side, grade) =>
    showText ? side + "\n" + grade : ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADD / MERGE BUY SIDE LIQUIDITY
// Buy side liquidity forms above swing highs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_addBuyZone(price, pivotBar, strength) =>
    zoneHalf = atr * zoneSizeATR
    top = price + zoneHalf
    bottom = price - zoneHalf
    mergeDist = atr * mergeATR
    merged = false

    if array.size(buyBoxes) > 0
        for i = 0 to array.size(buyBoxes) - 1
            oldTop = array.get(buyTop, i)
            oldBottom = array.get(buyBottom, i)
            oldMid = (oldTop + oldBottom) / 2.0

            if math.abs(price - oldMid) <= mergeDist
                newTouches = array.get(buyTouches, i) + strength
                newTop = math.max(oldTop, top)
                newBottom = math.min(oldBottom, bottom)

                array.set(buyTouches, i, newTouches)
                array.set(buyTop, i, newTop)
                array.set(buyBottom, i, newBottom)

                b = array.get(buyBoxes, i)
                box.set_top(b, newTop)
                box.set_bottom(b, newBottom)
                box.set_right(b, rightEdge)
                box.set_extend(b, extend.none)

                merged := true

    if not merged
        grade = f_grade(strength)
        col = f_buyColor(grade)
        visible = f_shouldShow(grade)

        b = box.new(
             left=pivotBar,
             top=top,
             right=rightEdge,
             bottom=bottom,
             xloc=xloc.bar_index,
             bgcolor=visible ? f_bg(col) : color.new(col, 100),
             border_color=visible ? col : color.new(col, 100),
             border_width=2,
             extend=extend.none,
             text=visible ? f_text("Buy Side Liquidity", grade) : "",
             text_color=visible ? buyTextCol : color.new(buyTextCol, 100),
             text_size=textSize,
             text_halign=text.align_right,
             text_valign=text.align_center)

        array.push(buyBoxes, b)
        array.push(buyTop, top)
        array.push(buyBottom, bottom)
        array.push(buyTouches, strength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADD / MERGE SELL SIDE LIQUIDITY
// Sell side liquidity forms below swing lows
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_addSellZone(price, pivotBar, strength) =>
    zoneHalf = atr * zoneSizeATR
    top = price + zoneHalf
    bottom = price - zoneHalf
    mergeDist = atr * mergeATR
    merged = false

    if array.size(sellBoxes) > 0
        for i = 0 to array.size(sellBoxes) - 1
            oldTop = array.get(sellTop, i)
            oldBottom = array.get(sellBottom, i)
            oldMid = (oldTop + oldBottom) / 2.0

            if math.abs(price - oldMid) <= mergeDist
                newTouches = array.get(sellTouches, i) + strength
                newTop = math.max(oldTop, top)
                newBottom = math.min(oldBottom, bottom)

                array.set(sellTouches, i, newTouches)
                array.set(sellTop, i, newTop)
                array.set(sellBottom, i, newBottom)

                b = array.get(sellBoxes, i)
                box.set_top(b, newTop)
                box.set_bottom(b, newBottom)
                box.set_right(b, rightEdge)
                box.set_extend(b, extend.none)

                merged := true

    if not merged
        grade = f_grade(strength)
        col = f_sellColor(grade)
        visible = f_shouldShow(grade)

        b = box.new(
             left=pivotBar,
             top=top,
             right=rightEdge,
             bottom=bottom,
             xloc=xloc.bar_index,
             bgcolor=visible ? f_bg(col) : color.new(col, 100),
             border_color=visible ? col : color.new(col, 100),
             border_width=2,
             extend=extend.none,
             text=visible ? f_text("Sell Side Liquidity", grade) : "",
             text_color=visible ? sellTextCol : color.new(sellTextCol, 100),
             text_size=textSize,
             text_halign=text.align_right,
             text_valign=text.align_center)

        array.push(sellBoxes, b)
        array.push(sellTop, top)
        array.push(sellBottom, bottom)
        array.push(sellTouches, strength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE BUY SIDE ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_updateBuyZones() =>
    if array.size(buyBoxes) > 0
        for i = 0 to array.size(buyBoxes) - 1
            touches = array.get(buyTouches, i)
            grade = f_grade(touches)
            col = f_buyColor(grade)
            visible = f_shouldShow(grade)

            b = array.get(buyBoxes, i)

            box.set_right(b, rightEdge)
            box.set_extend(b, extend.none)
            box.set_bgcolor(b, visible ? f_bg(col) : color.new(col, 100))
            box.set_border_color(b, visible ? col : color.new(col, 100))
            box.set_text(b, visible ? f_text("Buy Side Liquidity", grade) : "")
            box.set_text_color(b, visible ? buyTextCol : color.new(buyTextCol, 100))
            box.set_text_size(b, textSize)
            box.set_text_halign(b, text.align_right)
            box.set_text_valign(b, text.align_center)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE SELL SIDE ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_updateSellZones() =>
    if array.size(sellBoxes) > 0
        for i = 0 to array.size(sellBoxes) - 1
            touches = array.get(sellTouches, i)
            grade = f_grade(touches)
            col = f_sellColor(grade)
            visible = f_shouldShow(grade)

            b = array.get(sellBoxes, i)

            box.set_right(b, rightEdge)
            box.set_extend(b, extend.none)
            box.set_bgcolor(b, visible ? f_bg(col) : color.new(col, 100))
            box.set_border_color(b, visible ? col : color.new(col, 100))
            box.set_text(b, visible ? f_text("Sell Side Liquidity", grade) : "")
            box.set_text_color(b, visible ? sellTextCol : color.new(sellTextCol, 100))
            box.set_text_size(b, textSize)
            box.set_text_halign(b, text.align_right)
            box.set_text_valign(b, text.align_center)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotVolHigh = volume[rightBars]
pivotVolLow  = volume[rightBars]
avgVolPivot  = volAvg[rightBars]

highStrength = pivotVolHigh > avgVolPivot * 1.5 ? 2 : 1
lowStrength  = pivotVolLow > avgVolPivot * 1.5 ? 2 : 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(pivotHigh)
    f_addBuyZone(pivotHigh, bar_index - rightBars, highStrength)

if not na(pivotLow)
    f_addSellZone(pivotLow, bar_index - rightBars, lowStrength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CHECKS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if enableAlerts and array.size(buyBoxes) > 0
    for i = 0 to array.size(buyBoxes) - 1
        zoneTop = array.get(buyTop, i)
        zoneBottom = array.get(buyBottom, i)

        if high >= zoneBottom and low <= zoneTop
            buyZoneHit := true

if enableAlerts and array.size(sellBoxes) > 0
    for i = 0 to array.size(sellBoxes) - 1
        zoneTop = array.get(sellTop, i)
        zoneBottom = array.get(sellBottom, i)

        if high >= zoneBottom and low <= zoneTop
            sellZoneHit := true

anyZoneHit := buyZoneHit or sellZoneHit

alertcondition(buyZoneHit, title="Buy Side Liquidity Zone Hit", message="Price has hit a Buy Side Liquidity Zone on {{ticker}} {{interval}}")
alertcondition(sellZoneHit, title="Sell Side Liquidity Zone Hit", message="Price has hit a Sell Side Liquidity Zone on {{ticker}} {{interval}}")
alertcondition(anyZoneHit, title="Any Liquidity Zone Hit", message="Price has hit a Liquidity Zone on {{ticker}} {{interval}}")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE TAKEN BUY SIDE LIQUIDITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if deleteTaken and array.size(buyBoxes) > 0
    for i = array.size(buyBoxes) - 1 to 0
        zoneBottom = array.get(buyBottom, i)

        if high >= zoneBottom
            box.delete(array.get(buyBoxes, i))

            array.remove(buyBoxes, i)
            array.remove(buyTop, i)
            array.remove(buyBottom, i)
            array.remove(buyTouches, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE TAKEN SELL SIDE LIQUIDITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if deleteTaken and array.size(sellBoxes) > 0
    for i = array.size(sellBoxes) - 1 to 0
        zoneTop = array.get(sellTop, i)

        if low <= zoneTop
            box.delete(array.get(sellBoxes, i))

            array.remove(sellBoxes, i)
            array.remove(sellTop, i)
            array.remove(sellBottom, i)
            array.remove(sellTouches, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL UPDATE OF ACTIVE ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_updateBuyZones()
f_updateSellZones()
````
