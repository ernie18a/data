# GFG ORB Asia London New York by Agaam

- url: https://www.tradingview.com/script/tKd0Aowp-GFG-ORB-Asia-London-New-York-by-Agaam/
- type: indicator
- pine_id: PUB;522a7fb18a584bedb1f9b84cb3da0e43
- version: 1.0

## Description

GFG ORB Asia London New York by Agaam

GFG ORB Asia London New York by Agaam is a multi-session Opening Range Breakout indicator designed to help traders mark the opening range for the Asia, London, and New York trading sessions.

The indicator draws separate ORB zones for each session and displays the session ORB high, ORB low, and optional midpoint. It is built to keep the chart clean by using boxes and lines only, without buy/sell labels or price labels covering candles.

What This Indicator Shows:

• Asia ORB
The script tracks the Asia opening range using the selected Asia ORB time window. It draws the Asia ORB box, Asia high line, Asia low line, and optional midpoint.

• London ORB
The script tracks the London opening range using the selected London ORB time window. It draws the London ORB box, London high line, London low line, and optional midpoint.

• New York ORB
The script tracks the New York opening range using the selected New York ORB time window. It draws the New York ORB box, New York high line, New York low line, and optional midpoint.

• ORB Box
Each session can display a highlighted box around its opening range.

• ORB High and Low Lines
Each session can display horizontal high and low levels based on the session opening range.

• Optional Mid Line
The midpoint between the ORB high and ORB low can be turned on in the settings.

• Breakout Tracking
The script internally tracks when price breaks above or below each session’s ORB high or low. Breakout confirmation can be set to Close or Wick.

• Clean Chart Design
The indicator does not display buy/sell labels, price labels, or text labels on the chart. This helps keep candles and price action easier to read.

Default Session Settings:

Asia:
ORB Window: 8:00 PM – 8:30 PM New York time
Trading Window: 8:00 PM – 12:00 AM New York time

London:
ORB Window: 3:00 AM – 3:30 AM New York time
Trading Window: 3:00 AM – 6:00 AM New York time

New York:
ORB Window: 9:30 AM – 10:00 AM New York time
Trading Window: 9:30 AM – 4:00 PM New York time

All session times can be adjusted in the indicator settings.

How It Works:

During each selected ORB window, the script records the highest high and lowest low. Once the ORB window is complete, those levels become the opening range reference for that session.

The ORB high and ORB low are then shown during the related trading window. If the optional midpoint is enabled, the script also plots the middle of the range.

The indicator can track breakouts above the ORB high or below the ORB low using either candle close confirmation or wick confirmation, depending on the selected setting.

How to Use:

1. Add the indicator to your chart.
2. Select the session timezone you want to use.
3. Turn Asia, London, or New York sessions on or off depending on your trading plan.
4. Adjust the ORB window for each session if needed.
5. Adjust the trading window for each session if needed.
6. Use the ORB high and ORB low as important session reference levels.
7. Watch how price reacts near the ORB high, ORB low, and optional midpoint.
8. Combine the ORB levels with your own market structure, trend, volume, VWAP, support and resistance, supply and demand, or other confirmation tools.
9. Avoid treating an ORB break as an automatic trade entry. The levels are reference areas, not guaranteed signals.

Suggested Use Cases:

• Marking Asia, London, and New York opening ranges
• Watching session high and low breakout areas
• Comparing price behavior across major sessions
• Studying liquidity around session opens
• Identifying possible breakout, rejection, or retest areas
• Keeping a cleaner ORB chart without labels covering candles

Settings Overview:

• Show Asia ORB
Turns the Asia ORB on or off.

• Show London ORB
Turns the London ORB on or off.

• Show New York ORB
Turns the New York ORB on or off.

• ORB Session
Controls the time window used to calculate the opening range.

• Trading Session
Controls how long the ORB box and lines continue to display for that session.

• Break Confirmation
Close mode requires candle close beyond the ORB level.
Wick mode reacts when the candle wick breaks the ORB level.

• Allow Both Long And Short In Same Session
When enabled, the script can internally track both upside and downside breaks in the same session.

• Show ORB Box
Turns the highlighted ORB box on or off.

• Show ORB High / Low Lines
Turns the ORB high and low lines on or off.

• Show Mid Line
Turns the optional midpoint line on or off.

Important Notes:

The opening range updates while the ORB window is still forming. Once the ORB window ends, the ORB high and ORB low become fixed for that session.

ORB levels are visual reference levels. Price may break an ORB level and continue, reverse, retest, or consolidate.

This indicator does not predict future price direction and does not guarantee profitable trades.

This indicator is not a standalone trading system. It should be used with additional analysis, confirmation, and proper risk management.

Disclaimer:

This script is for educational and informational purposes only. It is not financial advice, investment advice, or a guaranteed signal system. Trading involves risk. Always use your own analysis, confirmation, and risk management before making any trading decision.

## Source Code

````pine
//@version=6
indicator("GFG ORB Asia London New York by Agaam", overlay=true, max_lines_count=300, max_boxes_count=150, max_labels_count=50)

//====================================================
// INPUTS
//====================================================
groupSession = "Sessions Timezone"
nyTz = input.string("America/New_York", "Session Timezone", group=groupSession)

//-------------------------
// Asia
//-------------------------
groupAsia = "Asia Session"
showAsia = input.bool(true, "Show Asia ORB", group=groupAsia)
asiaOrbSession = input.session("2000-2030", "Asia ORB Session", group=groupAsia)
asiaTradeSession = input.session("2000-0000", "Asia Trading Session", group=groupAsia)
asiaBoxColor = input.color(color.new(color.blue, 86), "Asia Box Color", group=groupAsia)
asiaHighColor = input.color(color.rgb(70, 150, 255), "Asia High Color", group=groupAsia)
asiaLowColor = input.color(color.rgb(0, 220, 255), "Asia Low Color", group=groupAsia)
asiaMidColor = input.color(color.gray, "Asia Mid Color", group=groupAsia)

//-------------------------
// London
//-------------------------
groupLondon = "London Session"
showLondon = input.bool(true, "Show London ORB", group=groupLondon)
londonOrbSession = input.session("0300-0330", "London ORB Session", group=groupLondon)
londonTradeSession = input.session("0300-0600", "London Trading Session", group=groupLondon)
londonBoxColor = input.color(color.new(color.purple, 86), "London Box Color", group=groupLondon)
londonHighColor = input.color(color.fuchsia, "London High Color", group=groupLondon)
londonLowColor = input.color(color.purple, "London Low Color", group=groupLondon)
londonMidColor = input.color(color.gray, "London Mid Color", group=groupLondon)

//-------------------------
// New York
//-------------------------
groupNY = "New York Session"
showNY = input.bool(true, "Show New York ORB", group=groupNY)
nyOrbSession = input.session("0930-1000", "New York ORB Session", group=groupNY)
nyTradeSession = input.session("0930-1600", "New York Trading Session", group=groupNY)
nyBoxColor = input.color(color.new(color.orange, 85), "New York Box Color", group=groupNY)
nyHighColor = input.color(color.orange, "New York High Color", group=groupNY)
nyLowColor = input.color(color.aqua, "New York Low Color", group=groupNY)
nyMidColor = input.color(color.gray, "New York Mid Color", group=groupNY)

//-------------------------
// Breakout Logic
//-------------------------
groupBreak = "Breakout Logic"
breakMode = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=groupBreak)
allowBoth = input.bool(false, "Allow Both Long And Short In Same Session", group=groupBreak)

//-------------------------
// Style
//-------------------------
groupStyle = "Style"
showBox = input.bool(true, "Show ORB Box", group=groupStyle)
showLines = input.bool(true, "Show ORB High / Low Lines", group=groupStyle)
showMid = input.bool(false, "Show Mid Line", group=groupStyle)

lineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupStyle)
midLineWidth = input.int(1, "Mid Line Width", minval=1, maxval=5, group=groupStyle)
midLineStyleInput = input.string("Solid", "Mid Line Style", options=["Solid", "Dotted", "Dashed"], group=groupStyle)

groupExtras = "Extras"
maxDays = input.int(20, "Max Days Objects", minval=1, maxval=50, group=groupExtras)

//====================================================
// STYLE HELPERS
//====================================================
midLineStyle = midLineStyleInput == "Dotted" ? line.style_dotted : midLineStyleInput == "Dashed" ? line.style_dashed : line.style_solid

//====================================================
// STORAGE ARRAYS
//====================================================
var box[] allBoxes = array.new_box()
var line[] allLines = array.new_line()

f_trim_objects() =>
    while array.size(allBoxes) > maxDays * 3
        oldBox = array.shift(allBoxes)
        box.delete(oldBox)

    while array.size(allLines) > maxDays * 9
        oldLine = array.shift(allLines)
        line.delete(oldLine)

//====================================================
// BREAKOUT SOURCE
//====================================================
bullSource = breakMode == "Close" ? close : high
bearSource = breakMode == "Close" ? close : low

//====================================================
// ASIA SESSION STATE
//====================================================
asiaInORB = showAsia and not na(time(timeframe.period, asiaOrbSession, nyTz))
asiaInTrade = showAsia and not na(time(timeframe.period, asiaTradeSession, nyTz))
prevAsiaInORB = bar_index > 0 ? asiaInORB[1] : false
asiaOrbStart = asiaInORB and not prevAsiaInORB
asiaOrbEnd = not asiaInORB and prevAsiaInORB

var float asiaHigh = na
var float asiaLow = na
var int asiaStartBar = na
var bool asiaReady = false
var bool asiaLongTriggered = false
var bool asiaShortTriggered = false
var box asiaBox = na
var line asiaHighLine = na
var line asiaLowLine = na
var line asiaMidLine = na

//====================================================
// ASIA BUILD
//====================================================
if asiaOrbStart
    asiaHigh := high
    asiaLow := low
    asiaStartBar := bar_index
    asiaReady := false
    asiaLongTriggered := false
    asiaShortTriggered := false

    if showBox
        asiaBox := box.new(left=bar_index, top=asiaHigh, right=bar_index, bottom=asiaLow, xloc=xloc.bar_index, bgcolor=asiaBoxColor, border_color=color.new(color.black, 100))
        array.push(allBoxes, asiaBox)

    if showLines
        asiaHighLine := line.new(x1=bar_index, y1=asiaHigh, x2=bar_index, y2=asiaHigh, xloc=xloc.bar_index, color=asiaHighColor, width=lineWidth)
        asiaLowLine := line.new(x1=bar_index, y1=asiaLow, x2=bar_index, y2=asiaLow, xloc=xloc.bar_index, color=asiaLowColor, width=lineWidth)
        array.push(allLines, asiaHighLine)
        array.push(allLines, asiaLowLine)

    if showMid
        asiaMid = (asiaHigh + asiaLow) / 2.0
        asiaMidLine := line.new(x1=bar_index, y1=asiaMid, x2=bar_index, y2=asiaMid, xloc=xloc.bar_index, color=asiaMidColor, width=midLineWidth)
        line.set_style(asiaMidLine, midLineStyle)
        array.push(allLines, asiaMidLine)

    f_trim_objects()

if asiaInORB
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

    if showBox and not na(asiaBox)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_right(asiaBox, bar_index)

    if showLines and not na(asiaHighLine)
        line.set_xy1(asiaHighLine, asiaStartBar, asiaHigh)
        line.set_xy2(asiaHighLine, bar_index, asiaHigh)
        line.set_color(asiaHighLine, asiaHighColor)
        line.set_width(asiaHighLine, lineWidth)

    if showLines and not na(asiaLowLine)
        line.set_xy1(asiaLowLine, asiaStartBar, asiaLow)
        line.set_xy2(asiaLowLine, bar_index, asiaLow)
        line.set_color(asiaLowLine, asiaLowColor)
        line.set_width(asiaLowLine, lineWidth)

    if showMid and not na(asiaMidLine)
        asiaMid = (asiaHigh + asiaLow) / 2.0
        line.set_xy1(asiaMidLine, asiaStartBar, asiaMid)
        line.set_xy2(asiaMidLine, bar_index, asiaMid)
        line.set_color(asiaMidLine, asiaMidColor)
        line.set_width(asiaMidLine, midLineWidth)
        line.set_style(asiaMidLine, midLineStyle)

if asiaOrbEnd
    asiaReady := true

if asiaReady and asiaInTrade
    if showBox and not na(asiaBox)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_right(asiaBox, bar_index)

    if showLines and not na(asiaHighLine)
        line.set_xy2(asiaHighLine, bar_index, asiaHigh)
        line.set_color(asiaHighLine, asiaHighColor)
        line.set_width(asiaHighLine, lineWidth)

    if showLines and not na(asiaLowLine)
        line.set_xy2(asiaLowLine, bar_index, asiaLow)
        line.set_color(asiaLowLine, asiaLowColor)
        line.set_width(asiaLowLine, lineWidth)

    if showMid and not na(asiaMidLine)
        asiaMid = (asiaHigh + asiaLow) / 2.0
        line.set_xy2(asiaMidLine, bar_index, asiaMid)
        line.set_color(asiaMidLine, asiaMidColor)
        line.set_width(asiaMidLine, midLineWidth)
        line.set_style(asiaMidLine, midLineStyle)

//====================================================
// ASIA BREAKOUT TRACKING - NO LABELS
//====================================================
asiaLongSignal = asiaReady and asiaInTrade and not na(asiaHigh) and bullSource > asiaHigh and not asiaLongTriggered and (allowBoth or not asiaShortTriggered)
asiaShortSignal = asiaReady and asiaInTrade and not na(asiaLow) and bearSource < asiaLow and not asiaShortTriggered and (allowBoth or not asiaLongTriggered)

if asiaLongSignal
    asiaLongTriggered := true

if asiaShortSignal
    asiaShortTriggered := true

//====================================================
// LONDON SESSION STATE
//====================================================
londonInORB = showLondon and not na(time(timeframe.period, londonOrbSession, nyTz))
londonInTrade = showLondon and not na(time(timeframe.period, londonTradeSession, nyTz))
prevLondonInORB = bar_index > 0 ? londonInORB[1] : false
londonOrbStart = londonInORB and not prevLondonInORB
londonOrbEnd = not londonInORB and prevLondonInORB

var float londonHigh = na
var float londonLow = na
var int londonStartBar = na
var bool londonReady = false
var bool londonLongTriggered = false
var bool londonShortTriggered = false
var box londonBox = na
var line londonHighLine = na
var line londonLowLine = na
var line londonMidLine = na

//====================================================
// LONDON BUILD
//====================================================
if londonOrbStart
    londonHigh := high
    londonLow := low
    londonStartBar := bar_index
    londonReady := false
    londonLongTriggered := false
    londonShortTriggered := false

    if showBox
        londonBox := box.new(left=bar_index, top=londonHigh, right=bar_index, bottom=londonLow, xloc=xloc.bar_index, bgcolor=londonBoxColor, border_color=color.new(color.black, 100))
        array.push(allBoxes, londonBox)

    if showLines
        londonHighLine := line.new(x1=bar_index, y1=londonHigh, x2=bar_index, y2=londonHigh, xloc=xloc.bar_index, color=londonHighColor, width=lineWidth)
        londonLowLine := line.new(x1=bar_index, y1=londonLow, x2=bar_index, y2=londonLow, xloc=xloc.bar_index, color=londonLowColor, width=lineWidth)
        array.push(allLines, londonHighLine)
        array.push(allLines, londonLowLine)

    if showMid
        londonMid = (londonHigh + londonLow) / 2.0
        londonMidLine := line.new(x1=bar_index, y1=londonMid, x2=bar_index, y2=londonMid, xloc=xloc.bar_index, color=londonMidColor, width=midLineWidth)
        line.set_style(londonMidLine, midLineStyle)
        array.push(allLines, londonMidLine)

    f_trim_objects()

if londonInORB
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

    if showBox and not na(londonBox)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox, bar_index)

    if showLines and not na(londonHighLine)
        line.set_xy1(londonHighLine, londonStartBar, londonHigh)
        line.set_xy2(londonHighLine, bar_index, londonHigh)
        line.set_color(londonHighLine, londonHighColor)
        line.set_width(londonHighLine, lineWidth)

    if showLines and not na(londonLowLine)
        line.set_xy1(londonLowLine, londonStartBar, londonLow)
        line.set_xy2(londonLowLine, bar_index, londonLow)
        line.set_color(londonLowLine, londonLowColor)
        line.set_width(londonLowLine, lineWidth)

    if showMid and not na(londonMidLine)
        londonMid = (londonHigh + londonLow) / 2.0
        line.set_xy1(londonMidLine, londonStartBar, londonMid)
        line.set_xy2(londonMidLine, bar_index, londonMid)
        line.set_color(londonMidLine, londonMidColor)
        line.set_width(londonMidLine, midLineWidth)
        line.set_style(londonMidLine, midLineStyle)

if londonOrbEnd
    londonReady := true

if londonReady and londonInTrade
    if showBox and not na(londonBox)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox, bar_index)

    if showLines and not na(londonHighLine)
        line.set_xy2(londonHighLine, bar_index, londonHigh)
        line.set_color(londonHighLine, londonHighColor)
        line.set_width(londonHighLine, lineWidth)

    if showLines and not na(londonLowLine)
        line.set_xy2(londonLowLine, bar_index, londonLow)
        line.set_color(londonLowLine, londonLowColor)
        line.set_width(londonLowLine, lineWidth)

    if showMid and not na(londonMidLine)
        londonMid = (londonHigh + londonLow) / 2.0
        line.set_xy2(londonMidLine, bar_index, londonMid)
        line.set_color(londonMidLine, londonMidColor)
        line.set_width(londonMidLine, midLineWidth)
        line.set_style(londonMidLine, midLineStyle)

//====================================================
// LONDON BREAKOUT TRACKING - NO LABELS
//====================================================
londonLongSignal = londonReady and londonInTrade and not na(londonHigh) and bullSource > londonHigh and not londonLongTriggered and (allowBoth or not londonShortTriggered)
londonShortSignal = londonReady and londonInTrade and not na(londonLow) and bearSource < londonLow and not londonShortTriggered and (allowBoth or not londonLongTriggered)

if londonLongSignal
    londonLongTriggered := true

if londonShortSignal
    londonShortTriggered := true

//====================================================
// NEW YORK SESSION STATE
//====================================================
nyInORB = showNY and not na(time(timeframe.period, nyOrbSession, nyTz))
nyInTrade = showNY and not na(time(timeframe.period, nyTradeSession, nyTz))
prevNyInORB = bar_index > 0 ? nyInORB[1] : false
nyOrbStart = nyInORB and not prevNyInORB
nyOrbEnd = not nyInORB and prevNyInORB

var float nyHigh = na
var float nyLow = na
var int nyStartBar = na
var bool nyReady = false
var bool nyLongTriggered = false
var bool nyShortTriggered = false
var box nyBox = na
var line nyHighLine = na
var line nyLowLine = na
var line nyMidLine = na

//====================================================
// NEW YORK BUILD
//====================================================
if nyOrbStart
    nyHigh := high
    nyLow := low
    nyStartBar := bar_index
    nyReady := false
    nyLongTriggered := false
    nyShortTriggered := false

    if showBox
        nyBox := box.new(left=bar_index, top=nyHigh, right=bar_index, bottom=nyLow, xloc=xloc.bar_index, bgcolor=nyBoxColor, border_color=color.new(color.black, 100))
        array.push(allBoxes, nyBox)

    if showLines
        nyHighLine := line.new(x1=bar_index, y1=nyHigh, x2=bar_index, y2=nyHigh, xloc=xloc.bar_index, color=nyHighColor, width=lineWidth)
        nyLowLine := line.new(x1=bar_index, y1=nyLow, x2=bar_index, y2=nyLow, xloc=xloc.bar_index, color=nyLowColor, width=lineWidth)
        array.push(allLines, nyHighLine)
        array.push(allLines, nyLowLine)

    if showMid
        nyMid = (nyHigh + nyLow) / 2.0
        nyMidLine := line.new(x1=bar_index, y1=nyMid, x2=bar_index, y2=nyMid, xloc=xloc.bar_index, color=nyMidColor, width=midLineWidth)
        line.set_style(nyMidLine, midLineStyle)
        array.push(allLines, nyMidLine)

    f_trim_objects()

if nyInORB
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow := na(nyLow) ? low : math.min(nyLow, low)

    if showBox and not na(nyBox)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox, bar_index)

    if showLines and not na(nyHighLine)
        line.set_xy1(nyHighLine, nyStartBar, nyHigh)
        line.set_xy2(nyHighLine, bar_index, nyHigh)
        line.set_color(nyHighLine, nyHighColor)
        line.set_width(nyHighLine, lineWidth)

    if showLines and not na(nyLowLine)
        line.set_xy1(nyLowLine, nyStartBar, nyLow)
        line.set_xy2(nyLowLine, bar_index, nyLow)
        line.set_color(nyLowLine, nyLowColor)
        line.set_width(nyLowLine, lineWidth)

    if showMid and not na(nyMidLine)
        nyMid = (nyHigh + nyLow) / 2.0
        line.set_xy1(nyMidLine, nyStartBar, nyMid)
        line.set_xy2(nyMidLine, bar_index, nyMid)
        line.set_color(nyMidLine, nyMidColor)
        line.set_width(nyMidLine, midLineWidth)
        line.set_style(nyMidLine, midLineStyle)

if nyOrbEnd
    nyReady := true

if nyReady and nyInTrade
    if showBox and not na(nyBox)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox, bar_index)

    if showLines and not na(nyHighLine)
        line.set_xy2(nyHighLine, bar_index, nyHigh)
        line.set_color(nyHighLine, nyHighColor)
        line.set_width(nyHighLine, lineWidth)

    if showLines and not na(nyLowLine)
        line.set_xy2(nyLowLine, bar_index, nyLow)
        line.set_color(nyLowLine, nyLowColor)
        line.set_width(nyLowLine, lineWidth)

    if showMid and not na(nyMidLine)
        nyMid = (nyHigh + nyLow) / 2.0
        line.set_xy2(nyMidLine, bar_index, nyMid)
        line.set_color(nyMidLine, nyMidColor)
        line.set_width(nyMidLine, midLineWidth)
        line.set_style(nyMidLine, midLineStyle)

//====================================================
// NEW YORK BREAKOUT TRACKING - NO LABELS
//====================================================
nyLongSignal = nyReady and nyInTrade and not na(nyHigh) and bullSource > nyHigh and not nyLongTriggered and (allowBoth or not nyShortTriggered)
nyShortSignal = nyReady and nyInTrade and not na(nyLow) and bearSource < nyLow and not nyShortTriggered and (allowBoth or not nyLongTriggered)

if nyLongSignal
    nyLongTriggered := true

if nyShortSignal
    nyShortTriggered := true
````
