# AYAAN

- url: https://www.tradingview.com/script/G5eWJ4YX-AYAAN/
- type: indicator
- pine_id: PUB;11dd11d201954b5daf49e901b05ee161
- version: 1.0

## Description

perfect entry and exit with stoploss eny time frame

## Source Code

````pine
//@version=5
indicator("AYAAN Dashboard", overlay=true)

//====================================================
// FUNCTION
//====================================================

f_getTrend() =>

    sma20 = ta.sma(close, 20)
    sma50 = ta.sma(close, 50)

    bullish = sma20 > sma50 and sma20 > sma20[1]
    bearish = sma20 < sma50 and sma20 < sma20[1]

    bullish ? "BULLISH" : bearish ? "BEARISH" : "SIDEWAYS"

f_getCPR() =>

    pivot = (high[1] + low[1] + close[1]) / 3
    bc = (high[1] + low[1]) / 2
    tc = (pivot - bc) + pivot

    width = tc > bc ? (tc - bc) : (bc - tc)

    avgWidth = ta.sma(width, 10)

    narrow = width < avgWidth * 0.8

    narrow ? "NARROW" : "WIDE"

f_getBuy() =>

    sma20 = ta.sma(close, 20)
    sma50 = ta.sma(close, 50)

    pivot = (high[1] + low[1] + close[1]) / 3
    bc = (high[1] + low[1]) / 2
    tc = (pivot - bc) + pivot

    prevPivot = (high[2] + low[2] + close[2]) / 3

    width = tc > bc ? (tc - bc) : (bc - tc)

    avgWidth = ta.sma(width, 10)

    narrow = width < avgWidth * 0.8

    bullish = sma20 > sma50 and sma20 > sma20[1]

    ascending = pivot > prevPivot and tc > bc

    signal = ascending and narrow and bullish

    signal ? str.tostring(tc) : "-"

f_getSell() =>

    sma20 = ta.sma(close, 20)
    sma50 = ta.sma(close, 50)

    pivot = (high[1] + low[1] + close[1]) / 3
    bc = (high[1] + low[1]) / 2
    tc = (pivot - bc) + pivot

    prevPivot = (high[2] + low[2] + close[2]) / 3

    width = tc > bc ? (tc - bc) : (bc - tc)

    avgWidth = ta.sma(width, 10)

    narrow = width < avgWidth * 0.8

    bearish = sma20 < sma50 and sma20 < sma20[1]

    descending = pivot < prevPivot and tc < bc

    signal = descending and narrow and bearish

    signal ? str.tostring(bc) : "-"

f_getSL() =>

    sma20 = ta.sma(close, 20)

    pivot = (high[1] + low[1] + close[1]) / 3
    prevPivot = (high[2] + low[2] + close[2]) / 3

    buySL = sma20 * 0.995
    sellSL = sma20 * 1.005

    bullish = pivot > prevPivot

    bullish ? str.tostring(buySL) : str.tostring(sellSL)

f_getTarget() =>

    sma20 = ta.sma(close, 20)

    pivot = (high[1] + low[1] + close[1]) / 3
    bc = (high[1] + low[1]) / 2
    tc = (pivot - bc) + pivot

    prevPivot = (high[2] + low[2] + close[2]) / 3

    buySL = sma20 * 0.995
    sellSL = sma20 * 1.005

    buyRisk = tc - buySL
    sellRisk = sellSL - bc

    buyTarget = tc + (buyRisk * 2)
    sellTarget = bc - (sellRisk * 2)

    bullish = pivot > prevPivot

    bullish ? str.tostring(buyTarget) : str.tostring(sellTarget)

//====================================================
// CURRENT CHART
//====================================================

sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

plot(sma20, color=color.green, linewidth=2)
plot(sma50, color=color.orange, linewidth=2)
plot(sma200, color=color.red, linewidth=3)

//====================================================
// CPR LINES
//====================================================

pivot = (high[1] + low[1] + close[1]) / 3
bc = (high[1] + low[1]) / 2
tc = (pivot - bc) + pivot

plot(pivot, color=color.blue)
plot(tc, color=color.purple)
plot(bc, color=color.purple)

//====================================================
// CURRENT SIGNALS
//====================================================

prevPivot = (high[2] + low[2] + close[2]) / 3

width = tc > bc ? (tc - bc) : (bc - tc)

avgWidth = ta.sma(width, 10)

narrow = width < avgWidth * 0.8

bullish = sma20 > sma50 and sma20 > sma20[1]
bearish = sma20 < sma50 and sma20 < sma20[1]

ascending = pivot > prevPivot and tc > bc
descending = pivot < prevPivot and tc < bc

buySignal = ascending and narrow and bullish
sellSignal = descending and narrow and bearish

plotshape(
     buySignal,
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY")

plotshape(
     sellSignal,
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL")

//====================================================
// MULTI TIMEFRAME
//====================================================

// 5 MIN

m5Trend = request.security(syminfo.tickerid, "5", f_getTrend())
m5CPR = request.security(syminfo.tickerid, "5", f_getCPR())
m5Buy = request.security(syminfo.tickerid, "5", f_getBuy())
m5Sell = request.security(syminfo.tickerid, "5", f_getSell())
m5SL = request.security(syminfo.tickerid, "5", f_getSL())
m5Target = request.security(syminfo.tickerid, "5", f_getTarget())

// 15 MIN

m15Trend = request.security(syminfo.tickerid, "15", f_getTrend())
m15CPR = request.security(syminfo.tickerid, "15", f_getCPR())
m15Buy = request.security(syminfo.tickerid, "15", f_getBuy())
m15Sell = request.security(syminfo.tickerid, "15", f_getSell())
m15SL = request.security(syminfo.tickerid, "15", f_getSL())
m15Target = request.security(syminfo.tickerid, "15", f_getTarget())

// 1 HOUR

hTrend = request.security(syminfo.tickerid, "60", f_getTrend())
hCPR = request.security(syminfo.tickerid, "60", f_getCPR())
hBuy = request.security(syminfo.tickerid, "60", f_getBuy())
hSell = request.security(syminfo.tickerid, "60", f_getSell())
hSL = request.security(syminfo.tickerid, "60", f_getSL())
hTarget = request.security(syminfo.tickerid, "60", f_getTarget())

// DAILY

dTrend = request.security(syminfo.tickerid, "D", f_getTrend())
dCPR = request.security(syminfo.tickerid, "D", f_getCPR())
dBuy = request.security(syminfo.tickerid, "D", f_getBuy())
dSell = request.security(syminfo.tickerid, "D", f_getSell())
dSL = request.security(syminfo.tickerid, "D", f_getSL())
dTarget = request.security(syminfo.tickerid, "D", f_getTarget())

// WEEKLY

wTrend = request.security(syminfo.tickerid, "W", f_getTrend())
wCPR = request.security(syminfo.tickerid, "W", f_getCPR())
wBuy = request.security(syminfo.tickerid, "W", f_getBuy())
wSell = request.security(syminfo.tickerid, "W", f_getSell())
wSL = request.security(syminfo.tickerid, "W", f_getSL())
wTarget = request.security(syminfo.tickerid, "W", f_getTarget())

//====================================================
// TABLE
//====================================================

var table dashboard = table.new(position.top_right, 7, 6, border_width=1)

if barstate.islast

    table.cell(dashboard, 0, 0, "TF", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 1, 0, "TREND", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 2, 0, "CPR", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 3, 0, "BUY", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 4, 0, "SELL", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 5, 0, "SL", bgcolor=color.blue, text_color=color.white)
    table.cell(dashboard, 6, 0, "TARGET", bgcolor=color.blue, text_color=color.white)

    // 5M

    table.cell(dashboard, 0, 1, "5M")
    table.cell(dashboard, 1, 1, m5Trend)
    table.cell(dashboard, 2, 1, m5CPR)
    table.cell(dashboard, 3, 1, m5Buy)
    table.cell(dashboard, 4, 1, m5Sell)
    table.cell(dashboard, 5, 1, m5SL)
    table.cell(dashboard, 6, 1, m5Target)

    // 15M

    table.cell(dashboard, 0, 2, "15M")
    table.cell(dashboard, 1, 2, m15Trend)
    table.cell(dashboard, 2, 2, m15CPR)
    table.cell(dashboard, 3, 2, m15Buy)
    table.cell(dashboard, 4, 2, m15Sell)
    table.cell(dashboard, 5, 2, m15SL)
    table.cell(dashboard, 6, 2, m15Target)

    // 1H

    table.cell(dashboard, 0, 3, "1H")
    table.cell(dashboard, 1, 3, hTrend)
    table.cell(dashboard, 2, 3, hCPR)
    table.cell(dashboard, 3, 3, hBuy)
    table.cell(dashboard, 4, 3, hSell)
    table.cell(dashboard, 5, 3, hSL)
    table.cell(dashboard, 6, 3, hTarget)

    // DAILY

    table.cell(dashboard, 0, 4, "1D")
    table.cell(dashboard, 1, 4, dTrend)
    table.cell(dashboard, 2, 4, dCPR)
    table.cell(dashboard, 3, 4, dBuy)
    table.cell(dashboard, 4, 4, dSell)
    table.cell(dashboard, 5, 4, dSL)
    table.cell(dashboard, 6, 4, dTarget)

    // WEEKLY

    table.cell(dashboard, 0, 5, "1W")
    table.cell(dashboard, 1, 5, wTrend)
    table.cell(dashboard, 2, 5, wCPR)
    table.cell(dashboard, 3, 5, wBuy)
    table.cell(dashboard, 4, 5, wSell)
    table.cell(dashboard, 5, 5, wSL)
    table.cell(dashboard, 6, 5, wTarget)

//====================================================
// ALERTS
//====================================================

alertcondition(buySignal, title="BUY ALERT", message="BUY SIGNAL")
alertcondition(sellSignal, title="SELL ALERT", message="SELL SIGNAL")
````
