# D1 ATR Sessions Pro TZ (<= H1)

- url: https://www.tradingview.com/script/VCJzpWk5-d1-atr-sessions-pro-tz-h1/
- type: indicator
- pine_id: PUB;1c7c61ca524b440b917890ec91c1a624
- version: 2.0

## Description

D1 ATR Sessions Pro combines daily ATR levels, trading sessions and custom candle logic in one tool.

The indicator is designed for intraday work on H1 and lower timeframes.

Main features:

• Daily ATR range from D1
• D1 Open line
• Upper and lower ATR borders
• Session background limited only inside the D1 ATR zone
• Additional coloring outside ATR when price breaks the daily range
• Manual session time setup
• Separate Session Timezone setting independent from chart timezone
• Asia, London, New York and Sydney sessions
• Session overlap priority
• Custom 3-color candle logic

Custom candle logic:

• Green candles show bullish pressure
• Red candles show bearish pressure
• White candles show neutral state, uncertainty or local consolidation
• Several white candles in a row can form a temporary flat zone
• Exit from the white zone can signal a return of directional movement

Default session times for UTC+5:

• Asia: 05:00 - 14:00
• London: 12:00 - 20:30
• New York: 18:30 - 01:00
• Sydney: 02:00 - 11:00

Important:

Session calculation uses the Session Timezone parameter inside the indicator settings.

This allows the sessions to remain stable even if the user changes the chart timezone in TradingView.

Recommended use:

• Intraday trading
• Scalping
• Session-based trading
• ATR range trading
• Identifying flat and trend phases
• Tracking daily expansion outside ATR borders
• Identifying active market periods

Best used on:

• BTCUSDT
• Forex pairs
• Gold
• NASDAQ
• US indices
• High volatility instruments

Video guide and future updates:
https://www.youtube.com/@AssekeTradeLab

A full video tutorial about setup, session time configuration and candle logic will be published later on the channel.

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AssekeTradeLab

//@version=5
indicator("D1 ATR Sessions Pro TZ (<= H1)", overlay=true)

//==================================================
// TIMEFRAME LOGIC
//==================================================
isSessionTf = timeframe.in_seconds() <= timeframe.in_seconds("60")

//==================================================
// ATR SETTINGS
//==================================================
atrLen         = input.int(14, "D1 ATR Length", minval=1)
showMidline    = input.bool(true, "Показывать D1 Open")
usePrevDayAtr  = input.bool(true, "Использовать ATR предыдущего дня")
usePrevDayOpen = input.bool(false, "Использовать Open предыдущего дня")

showAtrFill    = input.bool(true, "Показывать заливку ATR диапазона")
atrFillColor   = input.color(color.new(color.blue, 92), "ATR Range Fill Color")
midlineColor   = input.color(color.yellow, "D1 Open Color")
upperLineColor = input.color(color.lime, "Upper ATR Line Color")
lowerLineColor = input.color(color.red, "Lower ATR Line Color")

//==================================================
// SESSION TIMEZONE
//==================================================
sessionTzInput = input.string("UTC+5", "Session Timezone", options=["UTC-12", "UTC-11", "UTC-10", "UTC-9", "UTC-8", "UTC-7","UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1","UTC+0","UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+6","UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12"])

sessionTz =
     sessionTzInput == "UTC-12" ? "Etc/GMT+12" :
     sessionTzInput == "UTC-11" ? "Etc/GMT+11" :
     sessionTzInput == "UTC-10" ? "Etc/GMT+10" :
     sessionTzInput == "UTC-9"  ? "Etc/GMT+9"  :
     sessionTzInput == "UTC-8"  ? "Etc/GMT+8"  :
     sessionTzInput == "UTC-7"  ? "Etc/GMT+7"  :
     sessionTzInput == "UTC-6"  ? "Etc/GMT+6"  :
     sessionTzInput == "UTC-5"  ? "Etc/GMT+5"  :
     sessionTzInput == "UTC-4"  ? "Etc/GMT+4"  :
     sessionTzInput == "UTC-3"  ? "Etc/GMT+3"  :
     sessionTzInput == "UTC-2"  ? "Etc/GMT+2"  :
     sessionTzInput == "UTC-1"  ? "Etc/GMT+1"  :
     sessionTzInput == "UTC+0"  ? "Etc/GMT"    :
     sessionTzInput == "UTC+1"  ? "Etc/GMT-1"  :
     sessionTzInput == "UTC+2"  ? "Etc/GMT-2"  :
     sessionTzInput == "UTC+3"  ? "Etc/GMT-3"  :
     sessionTzInput == "UTC+4"  ? "Etc/GMT-4"  :
     sessionTzInput == "UTC+5"  ? "Etc/GMT-5"  :
     sessionTzInput == "UTC+6"  ? "Etc/GMT-6"  :
     sessionTzInput == "UTC+7"  ? "Etc/GMT-7"  :
     sessionTzInput == "UTC+8"  ? "Etc/GMT-8"  :
     sessionTzInput == "UTC+9"  ? "Etc/GMT-9"  :
     sessionTzInput == "UTC+10" ? "Etc/GMT-10" :
     sessionTzInput == "UTC+11" ? "Etc/GMT-11" :
     sessionTzInput == "UTC+12" ? "Etc/GMT-12" :
     "Etc/GMT-5"

//==================================================
// SESSION VISIBILITY
//==================================================
showAsia    = input.bool(true, "Показывать Asia")
showLondon  = input.bool(true, "Показывать London")
showNewYork = input.bool(true, "Показывать New York")
showSydney  = input.bool(true, "Показывать Sydney")

//==================================================
// MANUAL SESSION TIMES
// Время задаётся пользователем в выбранной Session Timezone
//==================================================
asiaSession    = input.session("0500-1400", "Asia Session")
londonSession  = input.session("1200-2030", "London Session")
newYorkSession = input.session("1830-0100", "New York Session")
sydneySession  = input.session("0200-1100", "Sydney Session")

//==================================================
// COLORS
//==================================================
asiaColor    = input.color(color.new(color.yellow, 85), "Asia Color")
londonColor  = input.color(color.new(color.blue, 85), "London Color")
newYorkColor = input.color(color.new(color.red, 85), "New York Color")
sydneyColor  = input.color(color.new(color.purple, 85), "Sydney Color")

outsideMode   = input.string("Separate Colors", "Outside ATR Fill Mode", options=["Separate Colors", "Use Session Color"])
aboveAtrColor = input.color(color.new(color.fuchsia, 80), "Above ATR Color")
belowAtrColor = input.color(color.new(color.aqua, 80), "Below ATR Color")

//==================================================
// CUSTOM 3-COLOR CANDLES
//  1 = white
//  0 = green
// -1 = red
//==================================================
useCustomCandleColors = input.bool(true, "Custom Candle Colors")

whiteColor = input.color(color.white, "White Candle")
greenColor = input.color(color.lime, "Green Candle")
redColor   = input.color(color.red, "Red Candle")

var int prevState = na
var float whiteZoneHigh = na
var float whiteZoneLow  = na

isWhiteFromRed    = not na(prevState) and prevState == -1 and close > open[1]
isWhiteFromGreen  = not na(prevState) and prevState == 0 and close < open[1]
isWhiteInsideWhite = not na(prevState) and prevState == 1 and close <= whiteZoneHigh and close >= whiteZoneLow

isWhite = isWhiteFromRed or isWhiteFromGreen or isWhiteInsideWhite

currentState =
     na(prevState) ? (close >= open ? 0 : -1) :
     isWhite ? 1 :
     prevState == 1 ? (close > whiteZoneHigh ? 0 : close < whiteZoneLow ? -1 : 1) :
     prevState == 0 ? 0 :
     -1

candleColor =
     currentState == 1 ? whiteColor :
     currentState == 0 ? greenColor :
     redColor

barcolor(useCustomCandleColors ? candleColor : na)

if currentState == 1 and prevState != 1
    whiteZoneHigh := math.max(open, close)
    whiteZoneLow  := math.min(open, close)
else if currentState == 1 and prevState == 1
    whiteZoneHigh := whiteZoneHigh
    whiteZoneLow  := whiteZoneLow
else
    whiteZoneHigh := na
    whiteZoneLow  := na

prevState := currentState

//==================================================
// SESSION CHECKS
// Сессии считаются строго в выбранной Session Timezone
//==================================================
inAsia    = isSessionTf and showAsia and not na(time(timeframe.period, asiaSession, sessionTz))
inLondon  = isSessionTf and showLondon and not na(time(timeframe.period, londonSession, sessionTz))
inNewYork = isSessionTf and showNewYork and not na(time(timeframe.period, newYorkSession, sessionTz))
inSydney  = isSessionTf and showSydney and not na(time(timeframe.period, sydneySession, sessionTz))

// Priority on overlap: New York > London > Asia > Sydney
sessionColor =
     inNewYork ? newYorkColor :
     inLondon  ? londonColor  :
     inAsia    ? asiaColor    :
     inSydney  ? sydneyColor  :
     na

//==================================================
// D1 DATA
//==================================================
dOpenCurrent = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_off)
dOpenPrev    = request.security(syminfo.tickerid, "D", open[1], barmerge.gaps_off, barmerge.lookahead_off)

dAtrCurrent  = request.security(syminfo.tickerid, "D", ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)
dAtrPrev     = request.security(syminfo.tickerid, "D", ta.atr(atrLen)[1], barmerge.gaps_off, barmerge.lookahead_off)

dOpen = usePrevDayOpen ? dOpenPrev : dOpenCurrent
dAtr  = usePrevDayAtr ? dAtrPrev : dAtrCurrent

upperBand = dOpen + dAtr
lowerBand = dOpen - dAtr

//==================================================
// MAIN PLOTS
//==================================================
midPlot   = plot(isSessionTf and showMidline ? dOpen : na, title="D1 Open", color=midlineColor, linewidth=2)
upperPlot = plot(isSessionTf ? upperBand : na, title="D1 ATR Upper", color=upperLineColor, linewidth=2)
lowerPlot = plot(isSessionTf ? lowerBand : na, title="D1 ATR Lower", color=lowerLineColor, linewidth=2)

fill(upperPlot, lowerPlot, color=isSessionTf and showAtrFill ? atrFillColor : na, title="ATR Range Fill")

//==================================================
// SESSION FILL ONLY INSIDE ATR
//==================================================
sessionUpperPlot = plot(isSessionTf and not na(sessionColor) ? upperBand : na, title="Session Upper Border", display=display.none)
sessionLowerPlot = plot(isSessionTf and not na(sessionColor) ? lowerBand : na, title="Session Lower Border", display=display.none)

fill(sessionUpperPlot, sessionLowerPlot, color=sessionColor, title="Session Fill Inside ATR")

//==================================================
// OUTSIDE ATR COLORS
//==================================================
outsideAboveColor = outsideMode == "Use Session Color" ? sessionColor : aboveAtrColor
outsideBelowColor = outsideMode == "Use Session Color" ? sessionColor : belowAtrColor

//==================================================
// EXTRA FILL ABOVE UPPER ATR
//==================================================
priceAboveAtr    = isSessionTf and close > upperBand ? close : na
priceAbovePlot   = plot(priceAboveAtr, title="Price Above ATR", display=display.none)
upperAtrEdgePlot = plot(isSessionTf and close > upperBand ? upperBand : na, title="Upper ATR Edge", display=display.none)

fill(priceAbovePlot, upperAtrEdgePlot, color=outsideAboveColor, title="Above ATR Fill")

//==================================================
// EXTRA FILL BELOW LOWER ATR
//==================================================
priceBelowAtr    = isSessionTf and close < lowerBand ? close : na
priceBelowPlot   = plot(priceBelowAtr, title="Price Below ATR", display=display.none)
lowerAtrEdgePlot = plot(isSessionTf and close < lowerBand ? lowerBand : na, title="Lower ATR Edge", display=display.none)

fill(lowerAtrEdgePlot, priceBelowPlot, color=outsideBelowColor, title="Below ATR Fill")
````
