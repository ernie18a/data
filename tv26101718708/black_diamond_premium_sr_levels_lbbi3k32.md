# Black Diamond - Premium S+R Levels

- url: https://www.tradingview.com/script/LBBI3K32-Black-Diamond-Premium-S-R-Levels/
- type: indicator
- pine_id: PUB;9384041fe26940d7b772e0cb512b832a
- version: 1.0

## Description

BTM – Premium Support & Resistance Retest Levels V6
Overview

BTM – Premium Support & Resistance Retest Levels V6 is a smart market structure indicator designed to automatically identify, track and score key support and resistance levels based on real swing highs and swing lows.

Unlike traditional support and resistance indicators that simply plot every pivot, this indicator intelligently groups market reactions and assigns a strength rating to each level based on how often price has respected that area.

The goal is to help traders quickly identify the strongest reaction zones on the chart while filtering out weaker and less relevant levels.

The indicator automatically:

✔ Detects Swing High Resistance Levels
✔ Detects Swing Low Support Levels
✔ Scores Level Strength
✔ Tracks Multiple Retests
✔ Identifies Broken Levels
✔ Optionally Keeps Historical Broken Levels Visible
✔ Provides Alert Conditions When Levels Are Touched
✔ Filters Levels By Strength Category

How The Indicator Works

The indicator scans the market for confirmed swing highs and swing lows using your chosen swing settings.

Resistance Levels

A resistance level is created when a confirmed swing high forms.

These levels appear in Red.

Support Levels

A support level is created when a confirmed swing low forms.

These levels appear in Blue.

Level Strength System

Each level receives a strength rating based on the number of market reactions that occur around that price area.

Weak

1 Market Reaction

Example:

R Weak (1)
S Weak (1)

These are fresh levels that have only been respected once.

Moderate

2 Market Reactions

Example:

R Moderate (2)
S Moderate (2)

These levels have been tested multiple times and generally carry more significance.

Strong

3-4 Market Reactions

Example:

R Strong (3)
S Strong (4)

Strong levels often attract institutional attention and can produce larger reactions.

Elite

5+ Market Reactions

Example:

R Elite (5)
S Elite (6)

Elite levels represent major areas where price has repeatedly respected the same zone.

These are often key decision points in the market.

Understanding The Labels
Example
R Moderate (2)

Means:

R = Resistance
Moderate = Strength Rating
(2) = Number of recorded reactions
Example
S Strong (3)

Means:

S = Support
Strong = Strength Rating
(3) = Number of recorded reactions
Using The Indicator
Trading Resistance

Look for:

Price approaching a resistance level.
Rejection candles.
Bearish market structure.
Additional confirmation from your strategy.

Potential opportunities may occur when price rejects resistance and begins moving lower.

Trading Support

Look for:

Price approaching support.
Bullish rejection candles.
Bullish market structure.
Additional confirmation from your strategy.

Potential opportunities may occur when price rejects support and begins moving higher.

Best Practice

Do NOT enter trades solely because price touches a support or resistance level.

Support and resistance should be used as an area of interest rather than an automatic entry signal.

Always combine with:

✔ Market Structure
✔ Liquidity Analysis
✔ Fair Value Gaps
✔ Trend Direction
✔ Higher Timeframe Bias
✔ Confirmation Candles

Recommended Timeframes

The indicator works on all timeframes but performs particularly well on:

Scalping
1 Minute
3 Minute
5 Minute
Intraday Trading
15 Minute
30 Minute
1 Hour
Swing Trading
4 Hour
Daily

Higher timeframes generally produce stronger and more reliable levels.

Alert System

The indicator includes built-in alert conditions.

Available Alerts:

Support Touch

Triggers when price touches an active support level.

Resistance Touch

Triggers when price touches an active resistance level.

Any Level Touch

Triggers when price touches any active support or resistance level.

These alerts can be used for monitoring key areas without needing to constantly watch charts.

Settings Guide
Swing Left Bars / Swing Right Bars

Controls how sensitive swing detection is.

Lower values:

More levels
Faster detection
More noise

Higher values:

Fewer levels
Stronger levels
Cleaner charts

Recommended:

Scalping: 3-5
Intraday: 5-8
Swing Trading: 8-15
Strength Count Zone ATR

Controls how close reactions must be before being grouped together.

Lower values:

More precise levels
Less grouping

Higher values:

More grouping
Stronger level scores

Recommended:

Forex: 0.05
Gold: 0.10
Indices: 0.15
Move Away ATR

Defines how far price must move away from a level before a new reaction can be counted.

Recommended:

0.50 ATR
Ideal Pairings

This indicator works exceptionally well alongside:

Black Diamond Liquidity Zones
Black Diamond Fair Value Gaps
Black Diamond Institutional Levels
Market Structure Analysis
Liquidity Sweeps
Volume Confirmation

Using multiple confluences dramatically improves trade quality.

Risk Disclaimer

This indicator is an educational and analytical tool only.

It does not provide financial advice and should not be considered a buy or sell signal.

Trading and investing involve significant risk and can result in the loss of capital.

Past performance does not guarantee future results.

Always perform your own analysis and use appropriate risk management before entering any trade.

## Source Code

````pine
//@version=6
indicator("Black Diamond - Premium S+R Levels", overlay=true, max_lines_count=300, max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
leftBars  = input.int(5, "Swing Left Bars", minval=1)
rightBars = input.int(5, "Swing Right Bars", minval=1)

maxLevels = input.int(80, "Maximum Levels", minval=20, maxval=300)
lineWidth = input.int(3, "Line Width", minval=1, maxval=5)

showSupport = input.bool(true, "Show Support")
showResistance = input.bool(true, "Show Resistance")

breakByClose = input.bool(true, "Break Level By Candle Close")
keepBrokenLevels = input.bool(true, "Keep Broken Levels On Chart")

atrLength = input.int(14, "ATR Length")
strengthZoneATR = input.float(0.05, "Strength Count Zone ATR", step=0.05)
touchRangeATR = input.float(0.15, "Live Touch Range ATR", step=0.05)
moveAwayATR = input.float(0.50, "Move Away Before New Touch ATR", step=0.05)

showStrengthLabels = input.bool(true, "Show Strength Labels")
showTouchCount = input.bool(true, "Show Touch Count In Label")

showWeakLevels = input.bool(true, "Show Weak Levels")
showModerateLevels = input.bool(true, "Show Moderate Levels")
showStrongLevels = input.bool(true, "Show Strong Levels")
showEliteLevels = input.bool(true, "Show Elite Levels")

enableAlerts = input.bool(true, "Enable Touch Alerts")

supportColour = input.color(color.rgb(40, 90, 255), "Support Colour")
resistanceColour = input.color(color.rgb(255, 0, 40), "Resistance Colour")
brokenColour = input.color(color.new(color.gray, 75), "Broken Level Colour")
hiddenColour = color.new(color.white, 100)
labelTextColour = input.color(color.white, "Label Text Colour")

//━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLength)

pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

swingBar = bar_index - rightBars

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()
var float[] levelPrices = array.new_float()
var int[] levelTypes = array.new_int()
var bool[] levelActive = array.new_bool()
var int[] levelTouches = array.new_int()
var int[] levelLastTouchBar = array.new_int()
var bool[] levelReadyForRetouch = array.new_bool()

//━━━━━━━━━━━━━━━━━━━
// ALERT FLAGS
//━━━━━━━━━━━━━━━━━━━
var bool supportTouchAlert = false
var bool resistanceTouchAlert = false
var bool anyTouchAlert = false

supportTouchAlert := false
resistanceTouchAlert := false
anyTouchAlert := false

//━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━
getStrengthText(touches) =>
    touches >= 5 ? "Elite" : touches >= 3 ? "Strong" : touches >= 2 ? "Moderate" : "Weak"

shouldShowByStrength(touches) =>
    strength = getStrengthText(touches)
    strength == "Weak" ? showWeakLevels :
     strength == "Moderate" ? showModerateLevels :
     strength == "Strong" ? showStrongLevels :
     showEliteLevels

getLevelColour(levelType) =>
    levelType == 1 ? supportColour : resistanceColour

buildLabelText(levelType, touches) =>
    side = levelType == 1 ? "S" : "R"
    strength = getStrengthText(touches)
    showTouchCount ? side + " " + strength + " (" + str.tostring(touches) + ")" : side + " " + strength

deleteOldestLevel() =>
    oldLine = array.shift(levelLines)
    line.delete(oldLine)

    oldLabel = array.shift(levelLabels)
    label.delete(oldLabel)

    array.shift(levelPrices)
    array.shift(levelTypes)
    array.shift(levelActive)
    array.shift(levelTouches)
    array.shift(levelLastTouchBar)
    array.shift(levelReadyForRetouch)

countNearbyTouches(price, levelType) =>
    count = 1
    arrSize = array.size(levelPrices)

    if arrSize > 0
        for i = 0 to arrSize - 1
            oldPrice = array.get(levelPrices, i)
            oldType = array.get(levelTypes, i)

            if oldType == levelType and math.abs(price - oldPrice) <= atr * strengthZoneATR
                count += 1

    count

isBroken(price, levelType) =>
    levelType == 1 ? (breakByClose ? close < price : low < price) : (breakByClose ? close > price : high > price)

isLiveTouch(price) =>
    high >= price and low <= price or math.abs(close - price) <= atr * touchRangeATR

hasMovedAway(price, levelType) =>
    levelType == 1 ? close > price + atr * moveAwayATR : close < price - atr * moveAwayATR

addSwingLevel(price, bar, levelType) =>
    touches = countNearbyTouches(price, levelType)
    levelColour = getLevelColour(levelType)

    newLine = line.new(
         x1 = bar,
         y1 = price,
         x2 = bar_index,
         y2 = price,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = levelColour,
         width = lineWidth)

    newLabel = label.new(
         x = bar_index,
         y = price,
         text = buildLabelText(levelType, touches),
         xloc = xloc.bar_index,
         style = label.style_label_left,
         size = size.tiny,
         textcolor = labelTextColour,
         color = levelColour)

    array.push(levelLines, newLine)
    array.push(levelLabels, newLabel)
    array.push(levelPrices, price)
    array.push(levelTypes, levelType)
    array.push(levelActive, true)
    array.push(levelTouches, touches)
    array.push(levelLastTouchBar, bar)
    array.push(levelReadyForRetouch, false)

    if array.size(levelLines) > maxLevels
        deleteOldestLevel()

//━━━━━━━━━━━━━━━━━━━
// ADD EXACT SWING LEVELS
//━━━━━━━━━━━━━━━━━━━
if not na(pivotLow) and showSupport
    addSwingLevel(pivotLow, swingBar, 1)

if not na(pivotHigh) and showResistance
    addSwingLevel(pivotHigh, swingBar, -1)

//━━━━━━━━━━━━━━━━━━━
// UPDATE ACTIVE LEVELS
//━━━━━━━━━━━━━━━━━━━
levelCount = array.size(levelLines)

if levelCount > 0
    for i = 0 to levelCount - 1
        ln = array.get(levelLines, i)
        lbl = array.get(levelLabels, i)

        price = array.get(levelPrices, i)
        levelType = array.get(levelTypes, i)
        active = array.get(levelActive, i)
        touches = array.get(levelTouches, i)
        lastTouchBar = array.get(levelLastTouchBar, i)
        readyForRetouch = array.get(levelReadyForRetouch, i)

        levelColour = getLevelColour(levelType)
        strengthVisible = shouldShowByStrength(touches)

        if active
            line.set_x2(ln, bar_index)
            line.set_y1(ln, price)
            line.set_y2(ln, price)

            if hasMovedAway(price, levelType)
                array.set(levelReadyForRetouch, i, true)
                readyForRetouch := true

            touching = isLiveTouch(price)
            newLiveTouch = touching and readyForRetouch and lastTouchBar != bar_index

            if newLiveTouch
                touches += 1
                array.set(levelTouches, i, touches)
                array.set(levelLastTouchBar, i, bar_index)
                array.set(levelReadyForRetouch, i, false)

                if enableAlerts
                    anyTouchAlert := true
                    if levelType == 1
                        supportTouchAlert := true
                    else
                        resistanceTouchAlert := true

            broken = isBroken(price, levelType)

            if broken
                array.set(levelActive, i, false)

                if keepBrokenLevels
                    line.set_color(ln, brokenColour)
                    label.set_text(lbl, "")
                    label.set_color(lbl, brokenColour)
                    label.set_textcolor(lbl, hiddenColour)
                else
                    line.set_color(ln, hiddenColour)
                    label.set_text(lbl, "")
                    label.set_color(lbl, hiddenColour)
                    label.set_textcolor(lbl, hiddenColour)
            else
                line.set_color(ln, strengthVisible ? levelColour : hiddenColour)
                line.set_width(ln, lineWidth)

                label.set_x(lbl, bar_index)
                label.set_y(lbl, price)
                label.set_text(lbl, showStrengthLabels and strengthVisible ? buildLabelText(levelType, touches) : "")
                label.set_color(lbl, strengthVisible ? levelColour : hiddenColour)
                label.set_textcolor(lbl, showStrengthLabels and strengthVisible ? labelTextColour : hiddenColour)

        else
            line.set_x2(ln, line.get_x2(ln))
            label.set_text(lbl, "")
            label.set_color(lbl, brokenColour)
            label.set_textcolor(lbl, hiddenColour)

//━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━
alertcondition(anyTouchAlert, title="BTM S&R Touch", message="BTM Support or Resistance level touched on {{ticker}} {{interval}}")
alertcondition(supportTouchAlert, title="BTM Support Touch", message="BTM Support level touched on {{ticker}} {{interval}}")
alertcondition(resistanceTouchAlert, title="BTM Resistance Touch", message="BTM Resistance level touched on {{ticker}} {{interval}}")
````
