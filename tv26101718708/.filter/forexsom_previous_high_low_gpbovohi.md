# FOREXSOM Previous High Low

- url: https://www.tradingview.com/script/gpBOVohi-FOREXSOM-Previous-High-Low/
- type: indicator
- pine_id: PUB;7d0e5b92a5dd4212a4cf759cf842bdb1
- version: 1.0

## Description

FOREXSOM Previous High Low automatically plots the Previous Week High PWH, Previous Week Low PWL, Previous Day High PDH, and Previous Day Low PDL using the exact candle wick highs and lows from higher timeframes

The indicator is designed for traders who use price action, Smart Money Concepts SMC, ICT concepts, liquidity analysis, and market structure in their trading

These levels are commonly used by traders to identify liquidity zones, support and resistance, stop hunts, breakout areas, and potential reversal points during the trading session

The script keeps the chart clean while providing important higher timeframe reference levels that many traders use for intraday and swing trading decisions

Features

Plots exact Previous Week High and Low

Plots exact Previous Day High and Low

Uses precise wick highs and lows

Customizable colors and line styles

Adjustable line thickness

Lightweight and clean chart design

Works across all timeframes

Useful for Forex, Crypto, Indices, Commodities, and Futures markets

This indicator can be useful for traders analyzing GBPUSD, EURUSD, XAUUSD Gold, NASDAQ, US30, and other highly traded markets

## Source Code

````pine
//@version=5
indicator("FOREXSOM Previous High Low", overlay=true, max_lines_count=50)

// SETTINGS
showPrevWeek = input.bool(true, "Show Previous Week High/Low")
showPrevDay  = input.bool(true, "Show Previous Day High/Low")

weekHighColor = input.color(color.red, "Previous Week High Color")
weekLowColor  = input.color(color.green, "Previous Week Low Color")
dayHighColor  = input.color(color.orange, "Previous Day High Color")
dayLowColor   = input.color(color.aqua, "Previous Day Low Color")

weekWidth = input.int(2, "Weekly Line Width", minval=1, maxval=5)
dayWidth  = input.int(1, "Daily Line Width", minval=1, maxval=5)

lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// PREVIOUS WEEK
prevWeekHigh = request.security(syminfo.tickerid, "W", high[1])
prevWeekLow  = request.security(syminfo.tickerid, "W", low[1])
prevWeekTime = request.security(syminfo.tickerid, "W", time[1])

// PREVIOUS DAY
prevDayHigh = request.security(syminfo.tickerid, "D", high[1])
prevDayLow  = request.security(syminfo.tickerid, "D", low[1])
prevDayTime = request.security(syminfo.tickerid, "D", time[1])

// LINES
var line pwh = na
var line pwl = na
var line pdh = na
var line pdl = na

if barstate.islast
    line.delete(pwh)
    line.delete(pwl)
    line.delete(pdh)
    line.delete(pdl)

    if showPrevWeek
        pwh := line.new(prevWeekTime, prevWeekHigh, time, prevWeekHigh,
         xloc=xloc.bar_time,
         extend=extend.right,
         color=weekHighColor,
         width=weekWidth,
         style=lineStyle)

        pwl := line.new(prevWeekTime, prevWeekLow, time, prevWeekLow,
         xloc=xloc.bar_time,
         extend=extend.right,
         color=weekLowColor,
         width=weekWidth,
         style=lineStyle)

    if showPrevDay
        pdh := line.new(prevDayTime, prevDayHigh, time, prevDayHigh,
         xloc=xloc.bar_time,
         extend=extend.right,
         color=dayHighColor,
         width=dayWidth,
         style=lineStyle)

        pdl := line.new(prevDayTime, prevDayLow, time, prevDayLow,
         xloc=xloc.bar_time,
         extend=extend.right,
         color=dayLowColor,
         width=dayWidth,
         style=lineStyle)
````
