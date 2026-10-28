# Premarket OTT Trigger

- url: https://www.tradingview.com/script/8rHuXYDa-Premarket-OTT-Trigger/
- type: indicator
- pine_id: PUB;7784299e6bbe49f586a62848a9ed0740
- version: 1.0

## Description

Premarket OTT Trigger

Premarket OTT Trigger is a multi-timeframe indicator designed to identify important premarket price zones using a 15-period OTT and then use those zones for structured break-and-retest setups after the market opens.

The concept is simple:

Higher timeframe = Find the setup
Lower timeframe = Find the entry

During premarket, the indicator looks for the most recent candle that crosses or touches the OTT. That candle is automatically boxed from its high to low, with a 50% midline, and the box extends to the right throughout the trading session.

If another qualifying premarket candle appears later, the older box is removed and the newest candle becomes the active zone.

Why Look for an OTT Cross?

A symbol with a premarket candle crossing or interacting with the OTT may be showing increased price activity and the potential for meaningful movement during the session.

This does not guarantee a move, but it can help identify symbols worth adding to a watchlist.

The resulting box creates a clearly defined trading area with three important levels:

Box High
50% Midline
Box Low

Instead of entering randomly, traders can use these levels to wait for price to show direction.

Break & Retest Method

A simple approach is to use the 30-minute timeframe to identify the box and the 5-minute timeframe for entries.

Bullish Setup

Wait for price to break above the box high.

Do not chase the initial breakout.

Allow price to pull back and retest the top of the box.

If the old resistance level holds as support and the 5-minute chart shows bullish confirmation, this can provide a potential long setup.

Break Above → Retest → Hold → Long

Bearish Setup

Wait for price to break below the box low.

Allow price to retest the broken level from underneath.

If the old support level acts as resistance and the 5-minute chart shows bearish confirmation, this can provide a potential short setup.

Break Below → Retest → Reject → Short

If price remains inside the box, the idea is simply to wait for direction.

AAPL Example

In the AAPL example shown, the 30-minute timeframe was used to establish the premarket OTT box, while the 5-minute chart was used for trade execution.

The higher timeframe provided the important premarket structure, while the lower timeframe provided a more precise view for the breakout, retest, and entry.

This is the core idea behind the indicator:

OTT Interaction → Potential Movement → Defined Zone → Break → Retest → Entry

Features
Selectable indicator timeframe
15-period OTT
Adjustable OTT percentage
Adjustable premarket session
Wick Touch, Body Cross, or Close Cross detection
Automatic most-recent premarket box
Automatic daily reset
Box High, Low, and 50% Midline
Dynamic box colors
Solid, Dashed, or Dotted box borders
Customizable midline style
Optional candle-close confirmation
Box extends through the trading session
Important

The OTT cross is not intended to predict direction by itself.

Its purpose is to help identify symbols that may be showing meaningful premarket activity and create a defined trading zone where entries, invalidation, and risk can be planned more clearly.

The trader still waits for price to confirm direction through the break and retest.

30M for structure.
5M for execution.
Let price confirm the trade.

This indicator is intended as a structure and confirmation tool and should be combined with proper risk management, position sizing, and your own trading plan.

For educational purposes only. Not financial advice.
[i]
Credits: This indicator incorporates the Optimized Trend Tracker (OTT) concept originally developed by Anıl Özekşi. Credit is also given to Kıvanç Özbilgiç for bringing OTT implementations to the TradingView/Pine community. This script extends the concept into a multi-timeframe premarket zone and break-and-retest framework.[/i]

## Source Code

````pine
//@version=6
indicator("Premarket OTT Trigger", overlay = true, max_boxes_count = 10, max_lines_count = 10)

//====================================================
// TIMEFRAME SETTINGS
//====================================================

indicatorTimeframe = input.timeframe(
     "5",
     "Indicator Timeframe",
     group = "Timeframe Settings",
     tooltip = "Timeframe used for the OTT and premarket crossing candle."
     )

//====================================================
// OTT SETTINGS
//====================================================

ottLength = input.int(
     15,
     "OTT Period",
     minval = 1,
     group = "OTT Settings"
     )

ottPercent = input.float(
     1.4,
     "OTT Percent",
     minval = 0.1,
     step = 0.1,
     group = "OTT Settings"
     )

ottSource = input.source(
     close,
     "OTT Source",
     group = "OTT Settings"
     )

showOTT = input.bool(
     true,
     "Show OTT",
     group = "OTT Settings"
     )

//====================================================
// PREMARKET SETTINGS
//====================================================

premarketSession = input.session(
     "0400-0930",
     "Premarket Session",
     group = "Premarket"
     )

sessionTimeZone = input.string(
     "America/New_York",
     "Session Time Zone",
     group = "Premarket"
     )

//====================================================
// CROSSING SETTINGS
//====================================================

crossType = input.string(
     "Wick Touch",
     "What Counts As Crossing OTT?",
     options = [
         "Wick Touch",
         "Body Cross",
         "Close Cross"
     ],
     group = "Crossing Logic"
     )

waitForClose = input.bool(
     false,
     "Wait For Candle To Close",
     group = "Crossing Logic"
     )

//====================================================
// BOX SETTINGS
//====================================================

dynamicBoxColor = input.bool(
     true,
     "Dynamic Box Color",
     group = "Box Settings"
     )

aboveColor = input.color(
     color.green,
     "Price Above Box",
     group = "Box Settings"
     )

belowColor = input.color(
     color.red,
     "Price Below Box",
     group = "Box Settings"
     )

insideColor = input.color(
     color.orange,
     "Price Inside Box",
     group = "Box Settings"
     )

fixedColor = input.color(
     color.yellow,
     "Fixed Box Color",
     group = "Box Settings"
     )

boxTransparency = input.int(
     88,
     "Box Fill Transparency",
     minval = 0,
     maxval = 100,
     group = "Box Settings"
     )

borderWidth = input.int(
     2,
     "Box Border Width",
     minval = 1,
     maxval = 5,
     group = "Box Settings"
     )

boxBorderStyleInput = input.string(
     "Solid",
     "Box Border Line Style",
     options = [
         "Solid",
         "Dashed",
         "Dotted"
     ],
     group = "Box Settings"
     )

//====================================================
// MIDLINE SETTINGS
//====================================================

showMidline = input.bool(
     true,
     "Show Box Midline",
     group = "Midline Settings"
     )

midlineStyleInput = input.string(
     "Dashed",
     "Midline Style",
     options = [
         "Solid",
         "Dashed",
         "Dotted"
     ],
     group = "Midline Settings"
     )

midlineWidth = input.int(
     1,
     "Midline Width",
     minval = 1,
     maxval = 5,
     group = "Midline Settings"
     )

midlineUsesBoxColor = input.bool(
     true,
     "Midline Uses Dynamic Box Color",
     group = "Midline Settings"
     )

customMidlineColor = input.color(
     color.white,
     "Custom Midline Color",
     group = "Midline Settings"
     )

//====================================================
// LINE STYLE CONVERSION
//====================================================

f_lineStyle(string selectedStyle) =>

    selectedStyle == "Dashed" ?
         line.style_dashed :
     selectedStyle == "Dotted" ?
         line.style_dotted :
         line.style_solid

boxBorderStyle = f_lineStyle(boxBorderStyleInput)

midlineStyle = f_lineStyle(midlineStyleInput)

//====================================================
// VAR / VIDYA CALCULATION
//====================================================

f_var(float src, int length) =>

    float alpha = 2.0 / (length + 1.0)

    float cmoValue =
         math.abs(ta.cmo(src, 9)) / 100.0

    var float varMA = na

    varMA :=
         na(varMA[1]) ?
         src :
         alpha * cmoValue * src +
         (1.0 - alpha * cmoValue) * varMA[1]

    varMA

//====================================================
// OTT CALCULATION
//====================================================

f_ott(float src, int length, float percent) =>

    float mavg =
         f_var(src, length)

    float offsetAmount =
         mavg * percent * 0.01

    float longStopRaw =
         mavg - offsetAmount

    float shortStopRaw =
         mavg + offsetAmount

    var float longStop = na
    var float shortStop = na
    var int direction = 1

    float previousLongStop =
         nz(longStop[1], longStopRaw)

    float previousShortStop =
         nz(shortStop[1], shortStopRaw)

    longStop :=
         mavg > previousLongStop ?
         math.max(longStopRaw, previousLongStop) :
         longStopRaw

    shortStop :=
         mavg < previousShortStop ?
         math.min(shortStopRaw, previousShortStop) :
         shortStopRaw

    direction :=
         nz(direction[1], 1)

    direction :=
         direction == -1 and mavg > previousShortStop ?
         1 :
         direction == 1 and mavg < previousLongStop ?
         -1 :
         direction

    float trailingStop =
         direction == 1 ?
         longStop :
         shortStop

    float ott =
         mavg > trailingStop ?
         trailingStop * (200.0 + percent) / 200.0 :
         trailingStop * (200.0 - percent) / 200.0

    ott

//====================================================
// SELECTED TIMEFRAME DATA
//====================================================

f_tfData() =>

    float ott =
         f_ott(
             ottSource,
             ottLength,
             ottPercent
         )

    string fullPremarket =
         premarketSession + ":23456"

    bool inPM =
         not na(
             time(
                 timeframe.period,
                 fullPremarket,
                 sessionTimeZone
             )
         )

    bool wickTouch =
         low <= ott and
         high >= ott

    bool bodyCross =
         math.min(open, close) <= ott and
         math.max(open, close) >= ott

    bool closeCross =
         ta.cross(close, ott)

    bool crossed =
         crossType == "Wick Touch" ?
         wickTouch :
         crossType == "Body Cross" ?
         bodyCross :
         closeCross

    int dateKey =
         year(time, sessionTimeZone) * 10000 +
         month(time, sessionTimeZone) * 100 +
         dayofmonth(time, sessionTimeZone)

    [
         time,
         time_close,
         open,
         high,
         low,
         close,
         ott,
         inPM,
         crossed,
         dateKey
     ]

//====================================================
// REQUEST SELECTED TIMEFRAME
//====================================================

[tfTime,tfTimeClose,tfOpen, tfHigh, tfLow, tfClose, tfOTT, tfInPremarket, tfCrossedOTT, tfDateKey] = request.security(
     syminfo.tickerid,
     indicatorTimeframe,
     f_tfData(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
     )

//====================================================
// CANDLE CONFIRMATION
//====================================================

bool tfCandleClosed =
     timenow >= tfTimeClose

bool candleAllowed =
     not waitForClose or
     tfCandleClosed

bool validPremarketCross =
     tfInPremarket and
     tfCrossedOTT and
     candleAllowed

//====================================================
// NEW DAY
//====================================================

bool newTradingDay =
     not na(tfDateKey[1]) and
     tfDateKey != tfDateKey[1]

//====================================================
// PLOT OTT
//====================================================

color ottColor =
     tfOTT > tfOTT[1] ?
     color.green :
     tfOTT < tfOTT[1] ?
     color.red :
     color.gray

plot(
     showOTT ? tfOTT : na,
     title = "Selected Timeframe OTT",
     color = ottColor,
     linewidth = 2
     )

//====================================================
// ACTIVE OBJECTS
//====================================================

var box activeBox = na

var line activeMidline = na

var int activeBoxTime = na

var float activeBoxHigh = na

var float activeBoxLow = na

var float activeBoxMiddle = na

bool newBoxCreated = false

//====================================================
// REMOVE PREVIOUS DAY
//====================================================

if newTradingDay

    if not na(activeBox)
        box.delete(activeBox)

    if not na(activeMidline)
        line.delete(activeMidline)

    activeBox := na

    activeMidline := na

    activeBoxTime := na

    activeBoxHigh := na

    activeBoxLow := na

    activeBoxMiddle := na

//====================================================
// CREATE / REPLACE MOST RECENT PREMARKET BOX
//====================================================

if validPremarketCross

    // New selected-timeframe candle
    if na(activeBoxTime) or tfTime != activeBoxTime

        // Delete old box
        if not na(activeBox)
            box.delete(activeBox)

        // Delete old midline
        if not na(activeMidline)
            line.delete(activeMidline)

        activeBoxTime := tfTime

        activeBoxHigh := tfHigh

        activeBoxLow := tfLow

        activeBoxMiddle :=
             (activeBoxHigh + activeBoxLow) / 2.0

        color startingColor =
             dynamicBoxColor ?
             insideColor :
             fixedColor

        //================================================
        // CREATE BOX
        //================================================

        activeBox := box.new(
             left = tfTime,
             top = activeBoxHigh,
             right = tfTimeClose,
             bottom = activeBoxLow,
             xloc = xloc.bar_time,
             extend = extend.right,
             border_color = startingColor,
             border_width = borderWidth,
             border_style = boxBorderStyle,
             bgcolor = color.new(
                 startingColor,
                 boxTransparency
             )
             )

        //================================================
        // CREATE MIDLINE
        //================================================

        if showMidline

            color startingMidlineColor =
                 midlineUsesBoxColor ?
                 startingColor :
                 customMidlineColor

            activeMidline := line.new(
                 x1 = tfTime,
                 y1 = activeBoxMiddle,
                 x2 = tfTimeClose,
                 y2 = activeBoxMiddle,
                 xloc = xloc.bar_time,
                 extend = extend.right,
                 color = startingMidlineColor,
                 style = midlineStyle,
                 width = midlineWidth
                 )

        newBoxCreated := true

    //====================================================
    // ACTIVE CANDLE STILL FORMING
    //====================================================

    else

        activeBoxHigh := tfHigh

        activeBoxLow := tfLow

        activeBoxMiddle :=
             (activeBoxHigh + activeBoxLow) / 2.0

        // Update box
        box.set_top(
             activeBox,
             activeBoxHigh
             )

        box.set_bottom(
             activeBox,
             activeBoxLow
             )

        box.set_right(
             activeBox,
             tfTimeClose
             )

        // Update midline
        if showMidline and not na(activeMidline)

            line.set_y1(
                 activeMidline,
                 activeBoxMiddle
                 )

            line.set_y2(
                 activeMidline,
                 activeBoxMiddle
                 )

            line.set_x2(
                 activeMidline,
                 tfTimeClose
                 )

//====================================================
// HANDLE MIDLINE TOGGLE
//====================================================

if not showMidline and not na(activeMidline)

    line.delete(activeMidline)

    activeMidline := na

//====================================================
// DYNAMIC BOX COLOR
//====================================================

if not na(activeBox)

    color currentBoxColor =
         fixedColor

    if dynamicBoxColor

        if close > activeBoxHigh

            currentBoxColor :=
                 aboveColor

        else if close < activeBoxLow

            currentBoxColor :=
                 belowColor

        else

            currentBoxColor :=
                 insideColor

    // Box color
    box.set_border_color(
         activeBox,
         currentBoxColor
         )

    box.set_bgcolor(
         activeBox,
         color.new(
             currentBoxColor,
             boxTransparency
         )
         )

    // Box border style
    box.set_border_style(
         activeBox,
         boxBorderStyle
         )

    //====================================================
    // MIDLINE COLOR / STYLE
    //====================================================

    if not na(activeMidline)

        color currentMidlineColor =
             midlineUsesBoxColor ?
             currentBoxColor :
             customMidlineColor

        line.set_color(
             activeMidline,
             currentMidlineColor
             )

        line.set_style(
             activeMidline,
             midlineStyle
             )

        line.set_width(
             activeMidline,
             midlineWidth
             )

//====================================================
// ALERT
//====================================================

alertcondition(
     newBoxCreated,
     title = "New Premarket OTT Crossing Candle",
     message = "A new premarket candle crossed the selected-timeframe OTT and became the active box."
     )
````
