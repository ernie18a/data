<!-- tradingview-pine-id: PUB;50c18dda935244c2b9a3ef09aa4e42ae -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SLTP Levels

Source: https://www.tradingview.com/script/7kb9JTsO-SLTP-Levels/

## Description

SLTP Levels - HTF & Session Liquidity Levels

SLTP Levels is a clean multi-timeframe reference-level indicator designed to highlight important price areas commonly monitored for liquidity, reactions, breakouts and potential targets.

It does not generate BUY or SELL signals. Its purpose is to provide a clean map of important market levels without cluttering the chart.

HIGHER TIMEFRAME LEVELS

PDH / PDL - Previous Day High / Low
Previous trading day's extremes. Common short-term liquidity and reaction areas.

PWH / PWL - Previous Week High / Low
Previous week's extremes and important higher-timeframe liquidity references.

PMH / PML - Previous Month High / Low
Previous month's extremes for broader market context.

MON H / MON L - Monday High / Low
Monday's range, often useful as a reference during the rest of the trading week.

FRI H / FRI L - Friday High / Low
Previous Friday's range, useful for observing price behaviour during the following week.

4H H / 4H L - Previous 4H High / Low
Extremes of the previous completed 4-hour candle.

1H H / 1H L - Previous 1H High / Low
Extremes of the previous completed hourly candle. Disabled by default to keep the chart clean.

SESSION LEVELS

AS H / AS L - Asia Session High / Low
LDN H / LDN L - London Session High / Low
NY H / NY L - New York Session High / Low

Session highs and lows can provide useful liquidity references as the next major trading session develops.

HOW TO USE IT

SLTP Levels should be used as a market map, not as an automatic entry system.

Around these levels, traders may watch for:

- Liquidity sweeps
- Rejection or acceptance
- Breakout and retest
- Market structure changes
- Multiple levels clustering in the same area
- Previous highs and lows acting as potential targets

When several levels are located in approximately the same price area, this creates technical confluence worth monitoring.

A level does not guarantee a reversal. Price may reject it, sweep it, consolidate around it or trade directly through it.

CLEAN CHART DESIGN

Every level group can be individually enabled or hidden.

Users can customize:

- Level visibility
- Colors
- Transparency
- Line width
- Label size
- 1H and 4H levels
- Session levels
- Label positioning

Labels are intentionally positioned to the right of current price to reduce interference with candles, drawings and other indicators.

The default Label Offset is 20 bars.

When another indicator occupies the same area, such as SLTP Pulse or another trade-management overlay, open:

Settings > General > Label Offset

and increase the value.

For best visibility, leave some empty space on the right side of the TradingView chart.

Nearby labels are automatically staggered while the actual horizontal levels remain at their exact prices.

IMPORTANT

SLTP Levels is a market-context tool, not a trading system. It does not predict future price movement and does not constitute financial advice.

Always use your own analysis, confirmation and risk management.

SLTP Levels
See the levels. Read the reaction. Trade your plan.

---

## Source Code

````pine
//@version=6
indicator(
     "SLTP Levels",
     shorttitle="SLTP Levels",
     overlay=true,
     max_lines_count=100,
     max_labels_count=100)

//=============================================================================
// SLTP LEVELS v1.0
// Multi-Timeframe & Session Reference Levels
//=============================================================================

//-----------------------------------------------------------------------------
// GENERAL
//-----------------------------------------------------------------------------
groupGeneral = "⚙ General"

lineWidth = input.int(
     1, "Line Width",
     minval=1, maxval=4,
     group=groupGeneral,
     display=display.none)

labelSizeInput = input.string(
     "Tiny", "Label Size",
     options=["Tiny", "Small", "Normal"],
     group=groupGeneral,
     display=display.none)

showLabels = input.bool(
     true, "Show Labels",
     group=groupGeneral,
     display=display.none)

labelOffset = input.int(
     20, "Label Offset (bars)",
     minval=1, maxval=100,
     tooltip="Moves SLTP Levels labels to the right. Increase this value when using other indicators such as SLTP Pulse.",
     group=groupGeneral,
     display=display.none)

staggerLabels = input.bool(
     true, "Separate Nearby Labels",
     tooltip="Moves nearby labels horizontally so they remain readable.",
     group=groupGeneral,
     display=display.none)

nearDistanceATR = input.float(
     0.05, "Nearby Distance (ATR)",
     minval=0.01, maxval=0.50, step=0.01,
     group=groupGeneral,
     display=display.none)

f_size() =>
    labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Small" ? size.small : size.normal

//-----------------------------------------------------------------------------
// PREVIOUS DAY
//-----------------------------------------------------------------------------
groupDay = "Previous Day"

showDay = input.bool(
     true, "PDH / PDL",
     group=groupDay,
     display=display.none)

dayColor = input.color(
     color.rgb(235, 70, 85), "Color",
     group=groupDay,
     display=display.none)

dayTransparency = input.int(
     5, "Transparency",
     minval=0, maxval=100,
     group=groupDay,
     display=display.none)

//-----------------------------------------------------------------------------
// PREVIOUS WEEK
//-----------------------------------------------------------------------------
groupWeek = "Previous Week"

showWeek = input.bool(
     true, "PWH / PWL",
     group=groupWeek,
     display=display.none)

weekColor = input.color(
     color.rgb(180, 70, 245), "Color",
     group=groupWeek,
     display=display.none)

weekTransparency = input.int(
     10, "Transparency",
     minval=0, maxval=100,
     group=groupWeek,
     display=display.none)

//-----------------------------------------------------------------------------
// PREVIOUS MONTH
//-----------------------------------------------------------------------------
groupMonth = "Previous Month"

showMonth = input.bool(
     true, "PMH / PML",
     group=groupMonth,
     display=display.none)

monthColor = input.color(
     color.rgb(60, 125, 245), "Color",
     group=groupMonth,
     display=display.none)

monthTransparency = input.int(
     15, "Transparency",
     minval=0, maxval=100,
     group=groupMonth,
     display=display.none)

//-----------------------------------------------------------------------------
// MONDAY LEVELS
//-----------------------------------------------------------------------------
groupMonday = "Monday Levels"

showMonday = input.bool(
     true, "Monday High / Low",
     tooltip="High and Low of the most recently completed Monday.",
     group=groupMonday,
     display=display.none)

mondayColor = input.color(
     color.rgb(255, 185, 45), "Color",
     group=groupMonday,
     display=display.none)

mondayTransparency = input.int(
     10, "Transparency",
     minval=0, maxval=100,
     group=groupMonday,
     display=display.none)

//-----------------------------------------------------------------------------
// FRIDAY LEVELS
//-----------------------------------------------------------------------------
groupFriday = "Friday Levels"

showFriday = input.bool(
     true, "Friday High / Low",
     tooltip="High and Low of the most recently completed Friday.",
     group=groupFriday,
     display=display.none)

fridayColor = input.color(
     color.rgb(255, 115, 45), "Color",
     group=groupFriday,
     display=display.none)

fridayTransparency = input.int(
     10, "Transparency",
     minval=0, maxval=100,
     group=groupFriday,
     display=display.none)

//-----------------------------------------------------------------------------
// PREVIOUS 4H
//-----------------------------------------------------------------------------
group4H = "Previous 4H"

show4H = input.bool(
     true, "4H High / Low",
     group=group4H,
     display=display.none)

h4Color = input.color(
     color.rgb(235, 205, 45), "Color",
     group=group4H,
     display=display.none)

h4Transparency = input.int(
     20, "Transparency",
     minval=0, maxval=100,
     group=group4H,
     display=display.none)

//-----------------------------------------------------------------------------
// PREVIOUS 1H
//-----------------------------------------------------------------------------
group1H = "Previous 1H"

show1H = input.bool(
     false, "1H High / Low",
     group=group1H,
     display=display.none)

h1Color = input.color(
     color.rgb(175, 175, 175), "Color",
     group=group1H,
     display=display.none)

h1Transparency = input.int(
     30, "Transparency",
     minval=0, maxval=100,
     group=group1H,
     display=display.none)

//-----------------------------------------------------------------------------
// SESSIONS
//-----------------------------------------------------------------------------
groupSessions = "Sessions"

showAsia = input.bool(
     true, "Asia High / Low",
     group=groupSessions,
     display=display.none)

showLondon = input.bool(
     true, "London High / Low",
     group=groupSessions,
     display=display.none)

showNY = input.bool(
     true, "New York High / Low",
     group=groupSessions,
     display=display.none)

asiaSession = input.session(
     "0000-0800", "Asia Session (UTC)",
     group=groupSessions,
     display=display.none)

londonSession = input.session(
     "0700-1600", "London Session (UTC)",
     group=groupSessions,
     display=display.none)

nySession = input.session(
     "1300-2200", "New York Session (UTC)",
     group=groupSessions,
     display=display.none)

asiaColor = input.color(
     color.rgb(155, 95, 240), "Asia Color",
     group=groupSessions,
     display=display.none)

londonColor = input.color(
     color.rgb(40, 150, 245), "London Color",
     group=groupSessions,
     display=display.none)

nyColor = input.color(
     color.rgb(30, 195, 140), "New York Color",
     group=groupSessions,
     display=display.none)

sessionTransparency = input.int(
     20, "Session Transparency",
     minval=0, maxval=100,
     group=groupSessions,
     display=display.none)

//=============================================================================
// CONFIRMED HIGHER-TIMEFRAME LEVELS
//=============================================================================

pdh = request.security(
     syminfo.tickerid, "D", high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

pdl = request.security(
     syminfo.tickerid, "D", low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

pwh = request.security(
     syminfo.tickerid, "W", high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

pwl = request.security(
     syminfo.tickerid, "W", low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

pmh = request.security(
     syminfo.tickerid, "M", high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

pml = request.security(
     syminfo.tickerid, "M", low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

h4h = request.security(
     syminfo.tickerid, "240", high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

h4l = request.security(
     syminfo.tickerid, "240", low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

h1h = request.security(
     syminfo.tickerid, "60", high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

h1l = request.security(
     syminfo.tickerid, "60", low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

//=============================================================================
// LAST COMPLETED MONDAY / FRIDAY
//=============================================================================

monHigh = request.security(
     syminfo.tickerid,
     "D",
     ta.valuewhen(dayofweek == dayofweek.monday, high, 1),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

monLow = request.security(
     syminfo.tickerid,
     "D",
     ta.valuewhen(dayofweek == dayofweek.monday, low, 1),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

friHigh = request.security(
     syminfo.tickerid,
     "D",
     ta.valuewhen(dayofweek == dayofweek.friday, high, 1),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

friLow = request.security(
     syminfo.tickerid,
     "D",
     ta.valuewhen(dayofweek == dayofweek.friday, low, 1),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

//=============================================================================
// SESSION ENGINE
//=============================================================================

f_sessionLevels(sess) =>
    inSession = not na(time(timeframe.period, sess, "UTC"))

    var float runningHigh = na
    var float runningLow = na
    var float completedHigh = na
    var float completedLow = na

    sessionStart = inSession and not inSession[1]
    sessionEnd = not inSession and inSession[1]

    if sessionStart
        runningHigh := high
        runningLow := low

    if inSession
        runningHigh := math.max(nz(runningHigh, high), high)
        runningLow := math.min(nz(runningLow, low), low)

    if sessionEnd
        completedHigh := runningHigh
        completedLow := runningLow

    [completedHigh, completedLow]

[asiaHigh, asiaLow] = f_sessionLevels(asiaSession)
[londonHigh, londonLow] = f_sessionLevels(londonSession)
[nyHigh, nyLow] = f_sessionLevels(nySession)

//=============================================================================
// LEVEL ARRAYS
//=============================================================================

var prices = array.new_float()
var texts = array.new_string()
var colors = array.new_color()

array.clear(prices)
array.clear(texts)
array.clear(colors)

f_add(enabled, price, txt, clr, transparency) =>
    if enabled and not na(price)
        array.push(prices, price)
        array.push(texts, txt)
        array.push(colors, color.new(clr, transparency))

f_add(showDay, pdh, "PDH", dayColor, dayTransparency)
f_add(showDay, pdl, "PDL", dayColor, dayTransparency)

f_add(showWeek, pwh, "PWH", weekColor, weekTransparency)
f_add(showWeek, pwl, "PWL", weekColor, weekTransparency)

f_add(showMonth, pmh, "PMH", monthColor, monthTransparency)
f_add(showMonth, pml, "PML", monthColor, monthTransparency)

f_add(showMonday, monHigh, "MON H", mondayColor, mondayTransparency)
f_add(showMonday, monLow, "MON L", mondayColor, mondayTransparency)

f_add(showFriday, friHigh, "FRI H", fridayColor, fridayTransparency)
f_add(showFriday, friLow, "FRI L", fridayColor, fridayTransparency)

f_add(show4H, h4h, "4H H", h4Color, h4Transparency)
f_add(show4H, h4l, "4H L", h4Color, h4Transparency)

f_add(show1H, h1h, "1H H", h1Color, h1Transparency)
f_add(show1H, h1l, "1H L", h1Color, h1Transparency)

f_add(showAsia, asiaHigh, "AS H", asiaColor, sessionTransparency)
f_add(showAsia, asiaLow, "AS L", asiaColor, sessionTransparency)

f_add(showLondon, londonHigh, "LDN H", londonColor, sessionTransparency)
f_add(showLondon, londonLow, "LDN L", londonColor, sessionTransparency)

f_add(showNY, nyHigh, "NY H", nyColor, sessionTransparency)
f_add(showNY, nyLow, "NY L", nyColor, sessionTransparency)

//=============================================================================
// DRAWING ENGINE
//=============================================================================

var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()

f_clearDrawings() =>
    if array.size(activeLines) > 0
        for i = 0 to array.size(activeLines) - 1
            line.delete(array.get(activeLines, i))

    if array.size(activeLabels) > 0
        for i = 0 to array.size(activeLabels) - 1
            label.delete(array.get(activeLabels, i))

    array.clear(activeLines)
    array.clear(activeLabels)

//=============================================================================
// DRAW LEVELS
//=============================================================================

if barstate.islast
    f_clearDrawings()

    atrValue = ta.atr(14)
    nearbyThreshold = atrValue * nearDistanceATR

    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1

            levelPrice = array.get(prices, i)
            levelText = array.get(texts, i)
            levelColor = array.get(colors, i)

            // Keep the actual level at its exact price.
            ln = line.new(
                 x1=bar_index - 1,
                 y1=levelPrice,
                 x2=bar_index + labelOffset,
                 y2=levelPrice,
                 xloc=xloc.bar_index,
                 extend=extend.left,
                 color=levelColor,
                 width=lineWidth)

            array.push(activeLines, ln)

            // Nearby labels are horizontally staggered.
            // The price level itself is never moved.
            labelShift = 0

            if staggerLabels and i > 0
                for j = 0 to i - 1
                    previousPrice = array.get(prices, j)

                    if math.abs(levelPrice - previousPrice) <= nearbyThreshold
                        labelShift += 4

            if showLabels
                lb = label.new(
                     x=bar_index + labelOffset + labelShift,
                     y=levelPrice,
                     text=levelText,
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_left,
                     color=levelColor,
                     textcolor=color.white,
                     size=f_size())

                array.push(activeLabels, lb)
````
