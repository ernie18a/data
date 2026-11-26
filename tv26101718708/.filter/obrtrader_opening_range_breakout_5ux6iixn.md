# OBR_TRADER Opening Range Breakout

- url: https://www.tradingview.com/script/5Ux6iIxN-OBR-TRADER-Opening-Range-Breakout/
- type: indicator
- pine_id: PUB;79fe97fa5df541f4bceddda9fcf9c8a9
- version: 1.0

## Description

OBR_TRADER Opening Range Breakout

A fully customizable multi-session Opening Range Breakout indicator based on the original Katalyst ORB framework, enhanced with webhook-ready alert conditions for automation systems, Railway integrations, MCP trading infrastructure, Discord/Telegram bots, and algorithmic execution pipelines.

FEATURES:
• US RTH Opening Range
• New York Session ORB
• London Session ORB
• Tokyo Session ORB
• Sydney Session ORB

VISUAL FEATURES:
• Custom session colors
• Midpoint line support
• No-trade zone fills
• Adjustable transparency
• Dashed / dotted / solid line styles
• Historical session cleanup controls
• Lower timeframe ORB precision
• Daylight Savings Time correction

ALERT FEATURES:
• ORB Set
• Bar Close
• ORB Long Breakout
• ORB Short Breakout

WEBHOOK READY:
Compatible with TradingView webhook alerts for:
• Railway
• Flask/FastAPI servers
• Discord bots
• Telegram bots
• MCP automation
• AI trading systems
• Option flow automation

HIDDEN DATA EXPORTS:
• ORB High
• ORB Low

EXAMPLE WEBHOOK MESSAGE:
{"ticker":"SPY","event":"orb_set","orb_high":{{plot("ORB High")}},"orb_low":{{plot("ORB Low")}}}

RECOMMENDED SETTINGS:
• Chart timeframe: 5m
• Opening Range Duration: 5m
• Trigger Type: Once Per Bar Close

CREATED BY AND FOR:
Trim Trading

## Source Code

````pine
//@version=6
indicator('OBR_TRADER Opening Range Breakout', overlay=true)

// User input for the opening range duration
rangeOption = input.string('5m', title='Opening Range Duration', options=['30s', '1m', '2m', '5m', '10m', '15m'])

rangeDurationSec = rangeOption == '30s' ? 30 : rangeOption == '1m' ? 60 : rangeOption == '2m' ? 120 : rangeOption == '5m' ? 300 : rangeOption == '10m' ? 600 : 900
validTF = rangeOption == '30s' ? "1" : str.replace(rangeOption, "m", "")

maxSessions = input.int(3, title='Number of Previous Sessions to Display', minval=1, maxval=50)

enableMidpointLine = input.bool(false, title='Enable Midpoint Line')
midpointLineColor = input.color(color.white, title='Midpoint Line Color')
midpointLineTransparency = input.int(50, title='Midpoint Line Transparency', minval=0, maxval=100)

lineTransparency = input.int(0, title='Line Transparency', minval=0, maxval=100)
lineStyleOption = input.string('Dashed', title='Line Style', options=['Solid', 'Dashed', 'Dotted'])
lineStyle = lineStyleOption == 'Solid' ? line.style_solid : lineStyleOption == 'Dashed' ? line.style_dashed : line.style_dotted
labelTransparency = input.int(0, title='Label Transparency', minval=0, maxval=100)

enableNoTradeZone = input.bool(false, title='Enable No Trade Zone')

showRTH = input.bool(true, title='Enable US RTH Session')
rthLineColor = input.color(color.yellow, title='US RTH Line Color')
rthNoTradeColor = input.color(color.red, title='US RTH No Trade Zone Color')

showNewYork = input.bool(false, title='Enable New York Session')
nyLineColor = input.color(color.blue, title='New York Line Color')
nyNoTradeColor = input.color(color.orange, title='New York No Trade Zone Color')

showLondon = input.bool(false, title='Enable London Session')
londonLineColor = input.color(color.green, title='London Line Color')
londonNoTradeColor = input.color(color.purple, title='London No Trade Zone Color')

showTokyo = input.bool(false, title='Enable Tokyo Session')
tokyoLineColor = input.color(color.aqua, title='Tokyo Line Color')
tokyoNoTradeColor = input.color(color.gray, title='Tokyo No Trade Zone Color')

showSydney = input.bool(false, title='Enable Sydney Session')
sydneyLineColor = input.color(color.fuchsia, title='Sydney Line Color')
sydneyNoTradeColor = input.color(color.teal, title='Sydney No Trade Zone Color')

isDSTActive() =>
    yearStart = year(timenow)
    dstStart = timestamp(yearStart, 3, 14 - dayofweek(timestamp(yearStart, 3, 14)), 2, 0, 0)
    dstEnd = timestamp(yearStart, 11, 7 - dayofweek(timestamp(yearStart, 11, 7)), 2, 0, 0)
    time >= dstStart and time < dstEnd

plotSessionRange(sessionName, sessionStartHour, sessionStartMin, durationSec, lineColor, noTradeColor, isEnabled, isDST=false) =>
    if isEnabled
        var float rangeHigh = na
        var float rangeLow = na
        var line[] upperLines = array.new_line(0)
        var line[] lowerLines = array.new_line(0)
        var line[] midpointLines = array.new_line(0)
        var linefill[] fillZones = array.new_linefill(0)
        var label seshlabel = na

        adjustedStartHour = isDST ? sessionStartHour - 1 : sessionStartHour
        sessionStartTime = timestamp('UTC', year, month, dayofmonth, adjustedStartHour, sessionStartMin, 0)
        sessionEndTime = sessionStartTime + durationSec * 1000

        lowerTFHigh = request.security(syminfo.tickerid, validTF, high, lookahead=barmerge.lookahead_on)
        lowerTFLow = request.security(syminfo.tickerid, validTF, low, lookahead=barmerge.lookahead_on)

        isSessionStart = time[1] < sessionStartTime and time >= sessionStartTime
        if isSessionStart
            rangeHigh := na
            rangeLow := na

        isSessionActive = time >= sessionStartTime and time < sessionEndTime
        if isSessionActive
            rangeHigh := na(rangeHigh) ? lowerTFHigh : math.max(rangeHigh, lowerTFHigh)
            rangeLow := na(rangeLow) ? lowerTFLow : math.min(rangeLow, lowerTFLow)

        isSessionEnd = time[1] < sessionEndTime and time >= sessionEndTime
        if isSessionEnd
            upperLine = line.new(bar_index, rangeHigh, bar_index + 1, rangeHigh, color=color.new(lineColor, lineTransparency), width=2, style=lineStyle, extend=extend.right)
            lowerLine = line.new(bar_index, rangeLow, bar_index + 1, rangeLow, color=color.new(lineColor, lineTransparency), width=2, style=lineStyle, extend=extend.right)
            array.push(upperLines, upperLine)
            array.push(lowerLines, lowerLine)
            seshlabel := label.new(bar_index, rangeHigh, sessionName + ' ' + rangeOption + ' OR: ' + str.tostring(rangeHigh) + " - " + str.tostring(rangeLow), color=color.new(lineColor, labelTransparency), textcolor=color.white)

            if enableNoTradeZone
                fillZone = linefill.new(upperLine, lowerLine, color=color.new(noTradeColor, 90))
                array.push(fillZones, fillZone)

            if enableMidpointLine
                midpoint = (rangeHigh + rangeLow) / 2
                midpointLine = line.new(bar_index, midpoint, bar_index + 1, midpoint, color=color.new(midpointLineColor, midpointLineTransparency), width=1, style=line.style_dotted, extend=extend.right)
                array.push(midpointLines, midpointLine)

            if array.size(upperLines) > maxSessions
                line.delete(array.shift(upperLines))
                line.delete(array.shift(lowerLines))
                if enableNoTradeZone
                    linefill.delete(array.shift(fillZones))
                if enableMidpointLine
                    line.delete(array.shift(midpointLines))

// Original visual sessions
plotSessionRange('US RTH', 14, 30, rangeDurationSec, rthLineColor, rthNoTradeColor, showRTH, isDST=isDSTActive())
plotSessionRange('New York', 13, 30, rangeDurationSec, nyLineColor, nyNoTradeColor, showNewYork, isDST=isDSTActive())
plotSessionRange('London', 8, 0, rangeDurationSec, londonLineColor, londonNoTradeColor, showLondon)
plotSessionRange('Tokyo', 23, 0, rangeDurationSec, tokyoLineColor, tokyoNoTradeColor, showTokyo)
plotSessionRange('Sydney', 21, 0, rangeDurationSec, sydneyLineColor, sydneyNoTradeColor, showSydney)

// Alert layer for US RTH
var float orbHighAlert = na
var float orbLowAlert = na
var bool orbSetLocked = false
var int lastAlertDay = na

alertAdjustedStartHour = isDSTActive() ? 13 : 14
alertSessionStart = timestamp('UTC', year, month, dayofmonth, alertAdjustedStartHour, 30, 0)
alertSessionEnd = alertSessionStart + rangeDurationSec * 1000
alertMarketEnd = alertSessionStart + 390 * 60 * 1000

alertDayKey = year * 10000 + month * 100 + dayofmonth

if na(lastAlertDay) or alertDayKey != lastAlertDay
    orbHighAlert := na
    orbLowAlert := na
    orbSetLocked := false
    lastAlertDay := alertDayKey

alertLowerTFHigh = request.security(syminfo.tickerid, validTF, high, lookahead=barmerge.lookahead_on)
alertLowerTFLow = request.security(syminfo.tickerid, validTF, low, lookahead=barmerge.lookahead_on)

inAlertSession = showRTH and time >= alertSessionStart and time < alertSessionEnd
afterAlertSession = showRTH and time >= alertSessionEnd and time < alertMarketEnd

if inAlertSession
    orbHighAlert := na(orbHighAlert) ? alertLowerTFHigh : math.max(orbHighAlert, alertLowerTFHigh)
    orbLowAlert := na(orbLowAlert) ? alertLowerTFLow : math.min(orbLowAlert, alertLowerTFLow)

orbSetEvent = showRTH and inAlertSession and time_close >= alertSessionEnd and barstate.isconfirmed and not orbSetLocked

if orbSetEvent
    orbSetLocked := true

barCloseEvent = orbSetLocked and afterAlertSession and barstate.isconfirmed
longBreakout = orbSetLocked and afterAlertSession and ta.crossover(close, orbHighAlert) and barstate.isconfirmed
shortBreakout = orbSetLocked and afterAlertSession and ta.crossunder(close, orbLowAlert) and barstate.isconfirmed

plot(orbHighAlert, title='ORB High', display=display.none)
plot(orbLowAlert, title='ORB Low', display=display.none)

alertcondition(orbSetEvent, title='ORB Set', message='{"ticker":"{{ticker}}","event":"orb_set","orb_high":{{plot("ORB High")}},"orb_low":{{plot("ORB Low")}}}')
alertcondition(barCloseEvent, title='Bar Close', message='{"ticker":"{{ticker}}","event":"bar_close","close":{{close}}}')
alertcondition(longBreakout, title='ORB Long Breakout', message='{"ticker":"{{ticker}}","event":"orb_long_breakout","close":{{close}},"orb_high":{{plot("ORB High")}},"orb_low":{{plot("ORB Low")}}}')
alertcondition(shortBreakout, title='ORB Short Breakout', message='{"ticker":"{{ticker}}","event":"orb_short_breakout","close":{{close}},"orb_high":{{plot("ORB High")}},"orb_low":{{plot("ORB Low")}}}')
````
