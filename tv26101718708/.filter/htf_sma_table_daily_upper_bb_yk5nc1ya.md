# HTF SMA Table + Daily Upper BB

- url: https://www.tradingview.com/script/Yk5nC1yA-HTF-SMA-Table-Daily-Upper-BB/
- type: indicator
- pine_id: PUB;d178ee8f23a741c9821558216209472b
- version: 1.0

## Description

This indicator displays a clean Higher Timeframe SMA table along with the Daily Upper Bollinger Band to help traders quickly identify trend direction, key moving-average levels, and possible resistance zones.

The HTF SMA table shows important Simple Moving Averages from higher timeframes, making it easier to compare price position across multiple market views without switching charts. The Daily Upper Bollinger Band adds an extra reference level that can help identify overextension, potential breakout areas, or upper-side resistance.

This tool is useful for traders who want a simple visual dashboard for trend confirmation, multi-timeframe analysis, and daily volatility-based levels.

## Source Code

````pine
//@version=6
indicator("HTF SMA Table + Daily Upper BB", overlay=true)

// Inputs
hourlyLen    = input.int(5, "Hourly SMA Length", minval=1)
dailyLen5    = input.int(5, "Daily SMA 5 Length", minval=1)
dailyLen20   = input.int(20, "Daily SMA 20 Length", minval=1)
dailyLen50   = input.int(50, "Daily SMA 50 Length", minval=1)
dailyLen100  = input.int(100, "Daily SMA 100 Length", minval=1)
dailyLen200  = input.int(200, "Daily SMA 200 Length", minval=1)

// Daily Bollinger Band inputs
bbLen  = input.int(20, "Daily BB Length", minval=1)
bbMult = input.float(2.0, "Daily BB Multiplier", step=0.1)

showDistance = input.bool(true, "Show distance from price?")
showLines    = input.bool(true, "Draw SMA level lines?")
showBBLine   = input.bool(true, "Draw Daily Upper BB line?")

// --------------------
// HTF functions
// --------------------
htfSmaLive(tf, length) =>
    request.security(
         syminfo.tickerid,
         tf,
         ta.sma(close, length),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on
     )

htfUpperBBLive(tf, length, mult) =>
    request.security(
         syminfo.tickerid,
         tf,
         ta.sma(close, length) + mult * ta.stdev(close, length),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on
     )

// --------------------
// HTF SMA values
// --------------------
hSma = htfSmaLive("60", hourlyLen)

dSma5   = htfSmaLive("D", dailyLen5)
dSma20  = htfSmaLive("D", dailyLen20)
dSma50  = htfSmaLive("D", dailyLen50)
dSma100 = htfSmaLive("D", dailyLen100)
dSma200 = htfSmaLive("D", dailyLen200)

// --------------------
// Daily Upper BB
// This stays DAILY even on 5m/10m chart
// --------------------
dailyUpperBB = htfUpperBBLive("D", bbLen, bbMult)

// --------------------
// Draw level lines
// --------------------
plot(showLines ? hSma : na,     title="Hourly SMA",    color=color.aqua,   linewidth=2, style=plot.style_stepline)
plot(showLines ? dSma5 : na,    title="Daily 5 SMA",   color=color.yellow, linewidth=2, style=plot.style_stepline)
plot(showLines ? dSma20 : na,   title="Daily 20 SMA",  color=color.orange, linewidth=2, style=plot.style_stepline)
plot(showLines ? dSma50 : na,   title="Daily 50 SMA",  color=color.blue,   linewidth=2, style=plot.style_stepline)
plot(showLines ? dSma100 : na,  title="Daily 100 SMA", color=color.purple, linewidth=2, style=plot.style_stepline)
plot(showLines ? dSma200 : na,  title="Daily 200 SMA", color=color.red,    linewidth=2, style=plot.style_stepline)

plot(showBBLine ? dailyUpperBB : na, title="Daily Upper BB", color=color.fuchsia, linewidth=2, style=plot.style_stepline)

// --------------------
// Helpers
// --------------------
fmt(v) =>
    na(v) ? "n/a" : str.tostring(v, format.mintick)

distPct(v) =>
    na(v) ? "n/a" : str.tostring((close - v) / v * 100, "#.##") + "%"

upsideRoomPct(v) =>
    na(v) ? "n/a" : str.tostring((v - close) / close * 100, "#.##") + "%"

status(v) =>
    na(v) ? "n/a" : close > v ? "Above" : close < v ? "Below" : "At"

aboveColor   = color.rgb(0, 80, 40)
belowColor   = color.rgb(120, 20, 20)
neutralColor = color.rgb(45, 45, 45)
headerColor  = color.rgb(20, 35, 70)
bbColor      = color.rgb(100, 30, 120)
textColor    = color.white

rowColor(v) =>
    na(v) ? neutralColor : close > v ? aboveColor : belowColor

// --------------------
// Table
// --------------------
var table t = table.new(position.top_right, 4, 8, border_width=1, frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Level",  text_color=textColor, bgcolor=headerColor)
    table.cell(t, 1, 0, "Value",  text_color=textColor, bgcolor=headerColor)
    table.cell(t, 2, 0, "Price",  text_color=textColor, bgcolor=headerColor)
    table.cell(t, 3, 0, showDistance ? "Dist %" : "Live", text_color=textColor, bgcolor=headerColor)

    table.cell(t, 0, 1, "Hourly " + str.tostring(hourlyLen) + " SMA", text_color=textColor, bgcolor=rowColor(hSma))
    table.cell(t, 1, 1, fmt(hSma), text_color=textColor, bgcolor=rowColor(hSma))
    table.cell(t, 2, 1, status(hSma), text_color=textColor, bgcolor=rowColor(hSma))
    table.cell(t, 3, 1, showDistance ? distPct(hSma) : "Live", text_color=textColor, bgcolor=rowColor(hSma))

    table.cell(t, 0, 2, "Daily 5 SMA", text_color=textColor, bgcolor=rowColor(dSma5))
    table.cell(t, 1, 2, fmt(dSma5), text_color=textColor, bgcolor=rowColor(dSma5))
    table.cell(t, 2, 2, status(dSma5), text_color=textColor, bgcolor=rowColor(dSma5))
    table.cell(t, 3, 2, showDistance ? distPct(dSma5) : "Live", text_color=textColor, bgcolor=rowColor(dSma5))

    table.cell(t, 0, 3, "Daily 20 SMA", text_color=textColor, bgcolor=rowColor(dSma20))
    table.cell(t, 1, 3, fmt(dSma20), text_color=textColor, bgcolor=rowColor(dSma20))
    table.cell(t, 2, 3, status(dSma20), text_color=textColor, bgcolor=rowColor(dSma20))
    table.cell(t, 3, 3, showDistance ? distPct(dSma20) : "Live", text_color=textColor, bgcolor=rowColor(dSma20))

    table.cell(t, 0, 4, "Daily 50 SMA", text_color=textColor, bgcolor=rowColor(dSma50))
    table.cell(t, 1, 4, fmt(dSma50), text_color=textColor, bgcolor=rowColor(dSma50))
    table.cell(t, 2, 4, status(dSma50), text_color=textColor, bgcolor=rowColor(dSma50))
    table.cell(t, 3, 4, showDistance ? distPct(dSma50) : "Live", text_color=textColor, bgcolor=rowColor(dSma50))

    table.cell(t, 0, 5, "Daily 100 SMA", text_color=textColor, bgcolor=rowColor(dSma100))
    table.cell(t, 1, 5, fmt(dSma100), text_color=textColor, bgcolor=rowColor(dSma100))
    table.cell(t, 2, 5, status(dSma100), text_color=textColor, bgcolor=rowColor(dSma100))
    table.cell(t, 3, 5, showDistance ? distPct(dSma100) : "Live", text_color=textColor, bgcolor=rowColor(dSma100))

    table.cell(t, 0, 6, "Daily 200 SMA", text_color=textColor, bgcolor=rowColor(dSma200))
    table.cell(t, 1, 6, fmt(dSma200), text_color=textColor, bgcolor=rowColor(dSma200))
    table.cell(t, 2, 6, status(dSma200), text_color=textColor, bgcolor=rowColor(dSma200))
    table.cell(t, 3, 6, showDistance ? distPct(dSma200) : "Live", text_color=textColor, bgcolor=rowColor(dSma200))

    table.cell(t, 0, 7, "Daily Upper BB " + str.tostring(bbLen), text_color=textColor, bgcolor=bbColor)
    table.cell(t, 1, 7, fmt(dailyUpperBB), text_color=textColor, bgcolor=bbColor)
    table.cell(t, 2, 7, status(dailyUpperBB), text_color=textColor, bgcolor=bbColor)
    table.cell(t, 3, 7, showDistance ? upsideRoomPct(dailyUpperBB) : "Live", text_color=textColor, bgcolor=bbColor)
````
