# SANTOSH SMART MTF BREAKOUT BOT

- url: https://www.tradingview.com/script/nDopN20j-SANTOSH-SMART-MTF-BREAKOUT-BOT/
- type: indicator
- pine_id: PUB;1bdde5b0592f45b498620ab894255b4e
- version: 1.0

## Description

Universal Crypto MTF Dashboard ek advanced multi-timeframe trend indicator hai jo scalping, intraday aur swing trading ke liye design kiya gaya hai.
Ye indicator EMA, RSI aur trend confirmation ka combination use karta hai jisse trader ko clear BUY / SELL direction mil sake.

## Source Code

````pine
//@version=5
indicator("SMART MTF BREAKOUT BOT", overlay=true)

// =======================
// INPUTS
// =======================
emaFastLen   = input.int(9,  "Fast EMA")
emaSlowLen   = input.int(21, "Slow EMA")
rsiLen       = input.int(14, "RSI Length")
volLen       = input.int(20, "Volume SMA")
atrLen       = input.int(14, "ATR Length")

// =======================
// EMA + RSI FUNCTION
// =======================
getTrend(tf) =>
    fastEMA = request.security(syminfo.tickerid, tf, ta.ema(close, emaFastLen))
    slowEMA = request.security(syminfo.tickerid, tf, ta.ema(close, emaSlowLen))
    rsiVal  = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen))

    trend = fastEMA > slowEMA and rsiVal > 55 ? 1 :
         fastEMA < slowEMA and rsiVal < 45 ? -1 : 0

    trend

// =======================
// MULTI TF TREND
// =======================
tf4h  = getTrend("240")
tf1h  = getTrend("60")
tf15m = getTrend("15")

// =======================
// BREAKOUT LEVELS
// =======================
prevHigh = request.security(syminfo.tickerid, "15", high[1])
prevLow  = request.security(syminfo.tickerid, "15", low[1])

bullBreakout = close > prevHigh
bearBreakout = close < prevLow

// =======================
// VOLUME FILTER
// =======================
volMA = ta.sma(volume, volLen)
highVolume = volume > volMA

// =======================
// ATR FILTER
// =======================
atrVal = ta.atr(atrLen)
sideways = atrVal < ta.sma(atrVal, 20)

// =======================
// FINAL CONDITIONS
// =======================
longCondition =
     tf4h == 1 and
     tf1h == 1 and
     tf15m == 1 and
     bullBreakout and
     highVolume and
     not sideways

shortCondition =
     tf4h == -1 and
     tf1h == -1 and
     tf15m == -1 and
     bearBreakout and
     highVolume and
     not sideways

// =======================
// ENTRY STATUS
// =======================
entryStatus =
     longCondition  ? "STRONG BUY" :
     shortCondition ? "STRONG SELL" :
     tf4h == 1 and tf1h == 1 ? "WAIT FOR BUY" :
     tf4h == -1 and tf1h == -1 ? "WAIT FOR SELL" :
     "NO TRADE"

// =======================
// SL / TP
// =======================
longSL = close - atrVal
longTP = close + (atrVal * 2)

shortSL = close + atrVal
shortTP = close - (atrVal * 2)

// =======================
// PLOTS
// =======================
ema9  = ta.ema(close, emaFastLen)
ema21 = ta.ema(close, emaSlowLen)

plot(ema9,  color=color.blue,   linewidth=2, title="EMA 9")
plot(ema21, color=color.orange, linewidth=2, title="EMA 21")

plotshape(longCondition,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.large,
     title="BUY")

plotshape(shortCondition,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.large,
     title="SELL")

// =======================
// SL / TP LINES
// =======================
plot(longCondition ? longSL : na,
     color=color.red,
     style=plot.style_linebr,
     linewidth=2,
     title="LONG SL")

plot(longCondition ? longTP : na,
     color=color.green,
     style=plot.style_linebr,
     linewidth=2,
     title="LONG TP")

plot(shortCondition ? shortSL : na,
     color=color.red,
     style=plot.style_linebr,
     linewidth=2,
     title="SHORT SL")

plot(shortCondition ? shortTP : na,
     color=color.green,
     style=plot.style_linebr,
     linewidth=2,
     title="SHORT TP")

// =======================
// DASHBOARD
// =======================
var table dash = table.new(position.top_right, 2, 8,
     bgcolor=color.new(color.black, 10),
     border_width=1)

if barstate.islast

    // HEADER
    table.cell(dash, 0, 0, "TIMEFRAME", text_color=color.white)
    table.cell(dash, 1, 0, "STATUS", text_color=color.white)

    // 4H
    table.cell(dash, 0, 1, "4H")
    table.cell(dash, 1, 1,
         tf4h == 1 ? "BULLISH" :
         tf4h == -1 ? "BEARISH" : "NEUTRAL",
         bgcolor =
         tf4h == 1 ? color.green :
         tf4h == -1 ? color.red : color.gray)

    // 1H
    table.cell(dash, 0, 2, "1H")
    table.cell(dash, 1, 2,
         tf1h == 1 ? "BULLISH" :
         tf1h == -1 ? "BEARISH" : "NEUTRAL",
         bgcolor =
         tf1h == 1 ? color.green :
         tf1h == -1 ? color.red : color.gray)

    // 15M
    table.cell(dash, 0, 3, "15M")
    table.cell(dash, 1, 3,
         tf15m == 1 ? "BULLISH" :
         tf15m == -1 ? "BEARISH" : "NEUTRAL",
         bgcolor =
         tf15m == 1 ? color.green :
         tf15m == -1 ? color.red : color.gray)

    // VOLUME
    table.cell(dash, 0, 4, "VOLUME")
    table.cell(dash, 1, 4,
         highVolume ? "HIGH" : "LOW",
         bgcolor = highVolume ? color.green : color.red)

    // MARKET
    table.cell(dash, 0, 5, "MARKET")
    table.cell(dash, 1, 5,
         sideways ? "SIDEWAYS" : "TRENDING",
         bgcolor = sideways ? color.orange : color.green)

    // ENTRY
    table.cell(dash, 0, 6, "ENTRY")
    table.cell(dash, 1, 6,
         entryStatus,
         bgcolor =
         longCondition ? color.green :
         shortCondition ? color.red :
         color.gray)

    // RR
    table.cell(dash, 0, 7, "RR")
    table.cell(dash, 1, 7, "1 : 2")

// =======================
// ALERTS
// =======================
alertcondition(
     longCondition and not longCondition[1],
     title="STRONG BUY",
     message="Strong BUY Signal - MTF Breakout Confirmed")

alertcondition(
     shortCondition and not shortCondition[1],
     title="STRONG SELL",
     message="Strong SELL Signal - MTF Breakdown Confirmed")
````
