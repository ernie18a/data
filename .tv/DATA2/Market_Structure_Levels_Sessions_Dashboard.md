<!-- tradingview-pine-id: PUB;59d6b46f689a4467aacb23ea98fac084 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Structure Levels + Sessions + Dashboard

Source: https://www.tradingview.com/script/wTb9goUN-Market-Structure-Levels-Pro-Sessions-Live-Dashboard/

## Description

Precision Levels. Clear Structure. Smarter Decisions.

Market Structure Levels Pro is a comprehensive TradingView indicator designed to help traders identify and monitor key price levels across multiple timeframes and trading sessions.

The indicator combines daily, weekly, monthly and session-based market structure levels with a clean, real-time dashboard that displays each level's price and its distance from the current market price in points.

Key Features

Multi-Timeframe Market Structure

Previous Day High and Low
Previous Week High and Low
Current Week High and Low
Current Month High and Low

Session Highs and Lows
Track completed Asia, London and New York sessions. Previous session levels remain visible until the next session of the same type is completed, helping traders monitor important intraday reference points.

Live Market Structure Dashboard
The integrated bottom-right dashboard organizes levels according to their position relative to current price:

Levels above current price
Current market price
Levels below current price

Each enabled level displays its price and real-time distance from the current price in points.

Fully Customizable

Individual visibility controls for each level group
Custom line colours and widths
Configurable session times and time zones
Adjustable session shading and transparency
Optional price labels
Dashboard visibility controls

Designed for Clarity
Market Structure Levels Pro helps reduce chart clutter by bringing important price references into one structured view, allowing traders to assess market positioning, potential reaction areas and price proximity more efficiently.

Important Disclaimer

This indicator is a visual analysis tool and does not provide guaranteed trading signals or profitable results. It should be used alongside independent market analysis, appropriate risk management and a clearly defined trading plan.

---

## Source Code

````pine
//@version=6
indicator("Market Structure Levels + Sessions + Dashboard", overlay=true, max_lines_count=60, max_labels_count=60)

groupDisplay = "Display Settings"
groupColors = "Line Colours"
groupSessions = "Session Settings"
groupSessionColors = "Session Colours"
groupPrevious = "Previous Levels"
groupDash = "Dashboard"

showDayLevels = input.bool(true, "Show Previous Day High/Low", group=groupDisplay)
showWeekLevels = input.bool(true, "Show Current Week High/Low", group=groupDisplay)
showPreviousWeek = input.bool(true, "Show Previous Week High/Low", group=groupPrevious)
showMonthLevels = input.bool(true, "Show Current Month High/Low", group=groupDisplay)
showPrices = input.bool(true, "Show Prices In Labels", group=groupDisplay)
lineWidth = input.int(1, "Line Width", minval=1, maxval=4, group=groupDisplay)

dayColour = input.color(color.blue, "Day Colour", group=groupColors)
weekColour = input.color(color.purple, "Week Colour", group=groupColors)
monthColour = input.color(color.orange, "Month Colour", group=groupColors)
previousWeekColour = input.color(color.fuchsia, "Previous Week Colour", group=groupColors)

showAsiaSession = input.bool(true, "Show Asia Session", group=groupSessions)
showLondonSession = input.bool(true, "Show London Session", group=groupSessions)
showNewYorkSession = input.bool(true, "Show New York Session", group=groupSessions)
showPreviousAsia = input.bool(true, "Show Previous Asia High/Low", group=groupPrevious)
showPreviousLondon = input.bool(true, "Show Previous London High/Low", group=groupPrevious)
showPreviousNewYork = input.bool(true, "Show Previous New York High/Low", group=groupPrevious)

sessionTimezone = input.string("America/New_York", "Session Timezone", options=["America/New_York", "Europe/London", "Europe/Dublin", "Etc/UTC"], group=groupSessions)
asiaSession = input.session("1900-0300", "Asia Session", group=groupSessions)
londonSession = input.session("0300-0830", "London Session", group=groupSessions)
newYorkSession = input.session("0830-1600", "New York Session", group=groupSessions)

asiaColour = input.color(color.blue, "Asia Colour", group=groupSessionColors)
londonColour = input.color(color.purple, "London Colour", group=groupSessionColors)
newYorkColour = input.color(color.orange, "New York Colour", group=groupSessionColors)
sessionTransparency = input.int(90, "Session Transparency", minval=0, maxval=100, group=groupSessionColors)

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashTextSize = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

previousDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
previousDayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
previousWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
previousWeekLow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

newDay = timeframe.change("D")
newWeek = timeframe.change("W")
newMonth = timeframe.change("M")

var int dayStartBar = na
var int weekStartBar = na
var int monthStartBar = na
if newDay or na(dayStartBar)
    dayStartBar := bar_index
if newWeek or na(weekStartBar)
    weekStartBar := bar_index
if newMonth or na(monthStartBar)
    monthStartBar := bar_index

var float currentWeekHigh = na
var float currentWeekLow = na
if newWeek or na(currentWeekHigh)
    currentWeekHigh := high
    currentWeekLow := low
else
    currentWeekHigh := math.max(currentWeekHigh, high)
    currentWeekLow := math.min(currentWeekLow, low)

var float currentMonthHigh = na
var float currentMonthLow = na
if newMonth or na(currentMonthHigh)
    currentMonthHigh := high
    currentMonthLow := low
else
    currentMonthHigh := math.max(currentMonthHigh, high)
    currentMonthLow := math.min(currentMonthLow, low)

getLabelText(string name, float price) => showPrices ? name + "  " + str.tostring(price, format.mintick) : name

f_manageLevel(line ln, label lb, bool enabled, int startBar, float price, string name, color clr, color txtClr) =>
    line resultLine = ln
    label resultLabel = lb
    if enabled and not na(price)
        // TradingView limits xloc.bar_index coordinates to roughly 10,000 bars
        // from the current bar. Clamp the starting point to avoid runtime errors
        // when using lower timeframes or loading a large amount of history.
        int safeStartBar = na(startBar) ? bar_index : math.max(startBar, bar_index - 9999)
        if na(resultLine)
            resultLine := line.new(safeStartBar, price, bar_index + 1, price, xloc=xloc.bar_index, extend=extend.right, color=clr, style=line.style_dashed, width=lineWidth)
        else
            line.set_xy1(resultLine, safeStartBar, price)
            line.set_xy2(resultLine, bar_index + 1, price)
            line.set_color(resultLine, clr)
            line.set_width(resultLine, lineWidth)
        if na(resultLabel)
            resultLabel := label.new(bar_index + 1, price, getLabelText(name, price), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=clr, textcolor=txtClr, size=size.small)
        else
            label.set_xy(resultLabel, bar_index + 1, price)
            label.set_text(resultLabel, getLabelText(name, price))
            label.set_color(resultLabel, clr)
            label.set_textcolor(resultLabel, txtClr)
    else
        if not na(resultLine)
            line.delete(resultLine)
            resultLine := na
        if not na(resultLabel)
            label.delete(resultLabel)
            resultLabel := na
    [resultLine, resultLabel]

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na
var line cwhLine = na
var line cwlLine = na
var label cwhLabel = na
var label cwlLabel = na
var line cmhLine = na
var line cmlLine = na
var label cmhLabel = na
var label cmlLabel = na
var line pwhLine = na
var line pwlLine = na
var label pwhLabel = na
var label pwlLabel = na

[pdhLineNew, pdhLabelNew] = f_manageLevel(pdhLine, pdhLabel, showDayLevels, dayStartBar, previousDayHigh, "PDH", dayColour, color.white)
pdhLine := pdhLineNew
pdhLabel := pdhLabelNew

[pdlLineNew, pdlLabelNew] = f_manageLevel(pdlLine, pdlLabel, showDayLevels, dayStartBar, previousDayLow, "PDL", dayColour, color.white)
pdlLine := pdlLineNew
pdlLabel := pdlLabelNew

[cwhLineNew, cwhLabelNew] = f_manageLevel(cwhLine, cwhLabel, showWeekLevels, weekStartBar, currentWeekHigh, "CWH", weekColour, color.white)
cwhLine := cwhLineNew
cwhLabel := cwhLabelNew

[cwlLineNew, cwlLabelNew] = f_manageLevel(cwlLine, cwlLabel, showWeekLevels, weekStartBar, currentWeekLow, "CWL", weekColour, color.white)
cwlLine := cwlLineNew
cwlLabel := cwlLabelNew

[cmhLineNew, cmhLabelNew] = f_manageLevel(cmhLine, cmhLabel, showMonthLevels, monthStartBar, currentMonthHigh, "CMH", monthColour, color.black)
cmhLine := cmhLineNew
cmhLabel := cmhLabelNew

[cmlLineNew, cmlLabelNew] = f_manageLevel(cmlLine, cmlLabel, showMonthLevels, monthStartBar, currentMonthLow, "CML", monthColour, color.black)
cmlLine := cmlLineNew
cmlLabel := cmlLabelNew

[pwhLineNew, pwhLabelNew] = f_manageLevel(pwhLine, pwhLabel, showPreviousWeek, weekStartBar, previousWeekHigh, "PWH", previousWeekColour, color.white)
pwhLine := pwhLineNew
pwhLabel := pwhLabelNew

[pwlLineNew, pwlLabelNew] = f_manageLevel(pwlLine, pwlLabel, showPreviousWeek, weekStartBar, previousWeekLow, "PWL", previousWeekColour, color.white)
pwlLine := pwlLineNew
pwlLabel := pwlLabelNew

inAsia = not na(time(timeframe.period, asiaSession, sessionTimezone))
inLondon = not na(time(timeframe.period, londonSession, sessionTimezone))
inNewYork = not na(time(timeframe.period, newYorkSession, sessionTimezone))

var float asiaHigh = na
var float asiaLow = na
var float previousAsiaHigh = na
var float previousAsiaLow = na
var float londonHigh = na
var float londonLow = na
var float previousLondonHigh = na
var float previousLondonLow = na
var float newYorkHigh = na
var float newYorkLow = na
var float previousNewYorkHigh = na
var float previousNewYorkLow = na

asiaStart = inAsia and not inAsia[1]
asiaEnd = not inAsia and inAsia[1]
londonStart = inLondon and not inLondon[1]
londonEnd = not inLondon and inLondon[1]
newYorkStart = inNewYork and not inNewYork[1]
newYorkEnd = not inNewYork and inNewYork[1]

if asiaStart
    asiaHigh := high
    asiaLow := low
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)
if asiaEnd
    previousAsiaHigh := asiaHigh
    previousAsiaLow := asiaLow

if londonStart
    londonHigh := high
    londonLow := low
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)
if londonEnd
    previousLondonHigh := londonHigh
    previousLondonLow := londonLow

if newYorkStart
    newYorkHigh := high
    newYorkLow := low
else if inNewYork
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow := math.min(newYorkLow, low)
if newYorkEnd
    previousNewYorkHigh := newYorkHigh
    previousNewYorkLow := newYorkLow

var line pahLine = na
var line palLine = na
var label pahLabel = na
var label palLabel = na
var line plhLine = na
var line pllLine = na
var label plhLabel = na
var label pllLabel = na
var line pnhLine = na
var line pnlLine = na
var label pnhLabel = na
var label pnlLabel = na

[pahLineNew, pahLabelNew] = f_manageLevel(pahLine, pahLabel, showPreviousAsia, bar_index, previousAsiaHigh, "PAH", asiaColour, color.white)
pahLine := pahLineNew
pahLabel := pahLabelNew

[palLineNew, palLabelNew] = f_manageLevel(palLine, palLabel, showPreviousAsia, bar_index, previousAsiaLow, "PAL", asiaColour, color.white)
palLine := palLineNew
palLabel := palLabelNew

[plhLineNew, plhLabelNew] = f_manageLevel(plhLine, plhLabel, showPreviousLondon, bar_index, previousLondonHigh, "PLH", londonColour, color.white)
plhLine := plhLineNew
plhLabel := plhLabelNew

[pllLineNew, pllLabelNew] = f_manageLevel(pllLine, pllLabel, showPreviousLondon, bar_index, previousLondonLow, "PLL", londonColour, color.white)
pllLine := pllLineNew
pllLabel := pllLabelNew

[pnhLineNew, pnhLabelNew] = f_manageLevel(pnhLine, pnhLabel, showPreviousNewYork, bar_index, previousNewYorkHigh, "PNYH", newYorkColour, color.white)
pnhLine := pnhLineNew
pnhLabel := pnhLabelNew

[pnlLineNew, pnlLabelNew] = f_manageLevel(pnlLine, pnlLabel, showPreviousNewYork, bar_index, previousNewYorkLow, "PNYL", newYorkColour, color.white)
pnlLine := pnlLineNew
pnlLabel := pnlLabelNew

bgcolor(showAsiaSession and inAsia ? color.new(asiaColour, sessionTransparency) : na, title="Asia Session")
bgcolor(showLondonSession and inLondon ? color.new(londonColour, sessionTransparency) : na, title="London Session")
bgcolor(showNewYorkSession and inNewYork ? color.new(newYorkColour, sessionTransparency) : na, title="New York Session")

f_dist(float level) =>
    na(level) ? "—" : str.tostring(level - close, format.mintick)

f_row(table t, int row, string name, float level) =>
    textSize = dashTextSize == "Tiny" ? size.tiny : dashTextSize == "Normal" ? size.normal : size.small
    distanceText = na(level) ? "—" : str.tostring(level - close, format.mintick)
    distanceColour = na(level) ? color.gray : level > close ? color.lime : level < close ? color.red : color.yellow
    table.cell(t, 0, row, name, text_color=color.white, text_size=textSize)
    table.cell(t, 1, row, na(level) ? "—" : str.tostring(level, format.mintick), text_color=color.white, text_size=textSize)
    table.cell(t, 2, row, distanceText, text_color=distanceColour, text_size=textSize)

var table dash = table.new(position.bottom_right, 3, 20, border_width=1)

if barstate.islast
    table.clear(dash, 0, 0, 2, 19)

    if showDashboard
        sz = dashTextSize == "Tiny" ? size.tiny : dashTextSize == "Normal" ? size.normal : size.small
        table.cell(dash, 0, 0, "LEVEL", text_color=color.white, text_size=sz, bgcolor=color.gray)
        table.cell(dash, 1, 0, "PRICE", text_color=color.white, text_size=sz, bgcolor=color.gray)
        table.cell(dash, 2, 0, "DISTANCE", text_color=color.white, text_size=sz, bgcolor=color.gray)

        names = array.new_string()
        vals = array.new_float()

        // Add only levels whose chart visibility setting is enabled.
        if showDayLevels
            array.push(names, "PDH")
            array.push(vals, previousDayHigh)
            array.push(names, "PDL")
            array.push(vals, previousDayLow)

        if showPreviousWeek
            array.push(names, "PWH")
            array.push(vals, previousWeekHigh)
            array.push(names, "PWL")
            array.push(vals, previousWeekLow)

        if showWeekLevels
            array.push(names, "CWH")
            array.push(vals, currentWeekHigh)
            array.push(names, "CWL")
            array.push(vals, currentWeekLow)

        if showMonthLevels
            array.push(names, "CMH")
            array.push(vals, currentMonthHigh)
            array.push(names, "CML")
            array.push(vals, currentMonthLow)

        if showPreviousAsia
            array.push(names, "PAH")
            array.push(vals, previousAsiaHigh)
            array.push(names, "PAL")
            array.push(vals, previousAsiaLow)

        if showPreviousLondon
            array.push(names, "PLH")
            array.push(vals, previousLondonHigh)
            array.push(names, "PLL")
            array.push(vals, previousLondonLow)

        if showPreviousNewYork
            array.push(names, "PNYH")
            array.push(vals, previousNewYorkHigh)
            array.push(names, "PNYL")
            array.push(vals, previousNewYorkLow)

        aboveNames = array.new_string()
        aboveVals = array.new_float()
        belowNames = array.new_string()
        belowVals = array.new_float()

        for i = 0 to array.size(names) - 1
            levelName = array.get(names, i)
            levelValue = array.get(vals, i)

            if not na(levelValue)
                if levelValue > close
                    array.push(aboveNames, levelName)
                    array.push(aboveVals, levelValue)
                else if levelValue < close
                    array.push(belowNames, levelName)
                    array.push(belowVals, levelValue)

        row = 1

        // Levels above current price.
        if array.size(aboveNames) > 0
            for i = 0 to array.size(aboveNames) - 1
                f_row(dash, row, array.get(aboveNames, i), array.get(aboveVals, i))
                row += 1

        // Current price separator in the middle of the level groups.
        table.cell(dash, 0, row, "CURRENT", text_color=color.black, text_size=sz, bgcolor=color.yellow)
        table.cell(dash, 1, row, str.tostring(close, format.mintick), text_color=color.black, text_size=sz, bgcolor=color.yellow)
        table.cell(dash, 2, row, "0.00", text_color=color.black, text_size=sz, bgcolor=color.yellow)
        row += 1

        // Levels below current price.
        if array.size(belowNames) > 0
            for i = 0 to array.size(belowNames) - 1
                f_row(dash, row, array.get(belowNames, i), array.get(belowVals, i))
                row += 1
    else
        table.clear(dash, 0, 0, 2, 19)
````
