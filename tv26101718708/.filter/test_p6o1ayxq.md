# Test

- url: https://www.tradingview.com/script/p6O1aYxQ-Test/
- type: indicator
- pine_id: PUB;c8b71525329e4d24a82d0201cc93ecf5
- version: 1.0

## Description

i am trying to test the stragtergy for option trading for nifty and bank nifty .FOr intraday traders can buy and sell the Index with this indicator easily with better money management and risk reward .

## Source Code

````pine
//@version=6
indicator("Test")

x = request.security("NSE:NIFTY50", "D", close)

//@version=6
// indicator("Nifty Option Premium Analyzer Dashboard", overlay=true, max_labels_count=500)

//=========================
// INPUTS
//=========================
emaFastLen = input.int(20, "EMA Fast")
emaSlowLen = input.int(50, "EMA Slow")

stAtr = input.int(10, "Supertrend ATR")
stFactor = input.float(3.0, "Supertrend Factor")

volLen = input.int(20, "Volume Average")
atrLen = input.int(14, "ATR Length")

showDashboard = input.bool(true)
showSignals = input.bool(true)

//=========================
// TREND
//=========================
ema20 = ta.ema(close, emaFastLen)
ema50 = ta.ema(close, emaSlowLen)

plot(ema20, color=color.green, linewidth=2)
plot(ema50, color=color.red, linewidth=2)

//=========================
// VWAP
//=========================
vwapValue = ta.vwap(close)
plot(vwapValue, color=color.yellow, linewidth=2)

//=========================
// SUPERTREND
//=========================
[st, dir] = ta.supertrend(stFactor, stAtr)

plot(st, color=dir < 0 ? color.red : color.lime, linewidth=2)

//=========================
// RELATIVE VOLUME
//=========================
avgVol = ta.sma(volume, volLen)
rvol = volume / avgVol

//=========================
// ATR EXPANSION
//=========================
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, 20)

atrExpansion = atr > atrAvg

//=========================
// MULTI TF TREND
//=========================
htf5  = request.security(syminfo.tickerid, "5", close)
htf15 = request.security(syminfo.tickerid, "15", close)
htf60 = request.security(syminfo.tickerid, "60", close)

trend5  = htf5 > request.security(syminfo.tickerid, "5", ta.ema(close,20))
trend15 = htf15 > request.security(syminfo.tickerid, "15", ta.ema(close,20))
trend60 = htf60 > request.security(syminfo.tickerid, "60", ta.ema(close,20))

bullMTF = trend5 and trend15 and trend60
bearMTF = not trend5 and not trend15 and not trend60

//=========================
// BUY SELL LOGIC
//=========================
longSignal =
     close > ema20 and
     ema20 > ema50 and
     close > vwapValue and
     dir > 0 and
     rvol > 1.2 and
     atrExpansion and
     bullMTF

shortSignal =
     close < ema20 and
     ema20 < ema50 and
     close < vwapValue and
     dir < 0 and
     rvol > 1.2 and
     atrExpansion and
     bearMTF

//=========================
// PLOTS
//=========================
plotshape(showSignals and longSignal,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY")

plotshape(showSignals and shortSignal,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL")

//=========================
// ALERTS
//=========================
alertcondition(longSignal,
     title="BUY ALERT",
     message="Nifty CE Buy Setup")

alertcondition(shortSignal,
     title="SELL ALERT",
     message="Nifty PE Buy Setup")

//=========================
// TRADE STATISTICS
//=========================
var int totalTrades = 0
var int wins = 0

entryLong = longSignal
entryShort = shortSignal

targetPct = 1.0

longWin =
     entryLong[1] and
     high >= close[1] * (1 + targetPct/100)

shortWin =
     entryShort[1] and
     low <= close[1] * (1 - targetPct/100)

if entryLong or entryShort
    totalTrades += 1

if longWin or shortWin
    wins += 1

winRate =
     totalTrades > 0 ?
     wins * 100 / totalTrades :
     0

//=========================
// MARKET SENTIMENT
//=========================
sentiment =
     bullMTF and close > vwapValue ? "BULLISH" :
     bearMTF and close < vwapValue ? "BEARISH" :
     "NEUTRAL"

//=========================
// DASHBOARD
//=========================
var table dash = table.new(
     position.top_right,
     2,
     10,
     bgcolor=color.black)

if barstate.islast and showDashboard

    table.cell(dash,0,0,"Metric",text_color=color.white)
    table.cell(dash,1,0,"Value",text_color=color.white)

    table.cell(dash,0,1,"Trend")
    table.cell(dash,1,1,
         ema20 > ema50 ? "UP" : "DOWN",
         text_color=ema20 > ema50 ? color.lime : color.red)

    table.cell(dash,0,2,"VWAP")
    table.cell(dash,1,2,
         close > vwapValue ? "ABOVE" : "BELOW")

    table.cell(dash,0,3,"RVOL")
    table.cell(dash,1,3,
         str.tostring(rvol, "#.##"))

    table.cell(dash,0,4,"ATR")
    table.cell(dash,1,4,
         atrExpansion ? "EXPANDING" : "NORMAL")

    table.cell(dash,0,5,"5m Trend")
    table.cell(dash,1,5,
         trend5 ? "UP" : "DOWN")

    table.cell(dash,0,6,"15m Trend")
    table.cell(dash,1,6,
         trend15 ? "UP" : "DOWN")

    table.cell(dash,0,7,"1H Trend")
    table.cell(dash,1,7,
         trend60 ? "UP" : "DOWN")

    table.cell(dash,0,8,"Win Rate")
    table.cell(dash,1,8,
         str.tostring(winRate, "#.##") + "%")

    table.cell(dash,0,9,"Sentiment")
    table.cell(dash,1,9,
         sentiment,
         text_color=
         sentiment == "BULLISH" ? color.lime :
         sentiment == "BEARISH" ? color.red :
         color.orange)

//=========================
// BAR COLOR
//=========================
barcolor(
     longSignal ? color.lime :
     shortSignal ? color.red :
     na)
````
