# SQB PRO Dashboard [India]

- url: https://www.tradingview.com/script/ZWK2cCA4-SQB-PRO-Dashboard-India/
- type: indicator
- pine_id: PUB;626f37ba1f9c40889db4cb6ea5266d21
- version: 1.0

## Description

This script is essentially a Trend Following + Relative Strength + Breakout Detection Dashboard inspired by Minervini, CANSLIM, and momentum investing principles.

## Source Code

````pine
//@version=5
indicator("SQB PRO Dashboard [India]", overlay=true)

// =====================================================
// INPUTS
// =====================================================
benchmark = input.symbol("NSE:NIFTY", "Benchmark")

showEMA      = input.bool(true, "Show EMA")
showSignals  = input.bool(true, "Show Signals")
showTable    = input.bool(true, "Show Dashboard")

// =====================================================
// MOVING AVERAGES
// =====================================================
ema20  = ta.ema(close, 20)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

plot(showEMA ? ema20 : na, color=color.green, linewidth=2, title="20 EMA")
plot(showEMA ? sma50 : na, color=color.orange, linewidth=2, title="50 SMA")
plot(showEMA ? sma200 : na, color=color.red, linewidth=2, title="200 SMA")

// =====================================================
// STAGE 2 DETECTION
// =====================================================
stage2 =
 close > ema20 and
 ema20 > sma50 and
 sma50 > sma200

trendText = stage2 ? "STAGE 2" : "WEAK"

// =====================================================
// RELATIVE STRENGTH
// =====================================================
benchClose = request.security(benchmark, timeframe.period, close)

stockPerf = close / close[55]
benchPerf = benchClose / benchClose[55]

rsScore = ((stockPerf / benchPerf) - 1) * 100

rsText =
 rsScore > 10 ? "STRONG" :
 rsScore > 0 ? "GOOD" : "WEAK"

// =====================================================
// RVOL
// =====================================================
avgVol = ta.sma(volume, 20)
rvol = volume / avgVol

// =====================================================
// ADR
// =====================================================
adr = ta.sma((high - low) / low * 100, 20)

// =====================================================
// NR7 + INSIDE BAR
// =====================================================
rangeToday = high - low

nr7 = rangeToday == ta.lowest(rangeToday, 7)

insideBar =
 high < high[1] and
 low > low[1]

// =====================================================
// BREAKOUT
// =====================================================
breakout =
 close > ta.highest(high, 20)[1] and
 rvol > 1.5

// =====================================================
// ATR STOPLOSS
// =====================================================
atr = ta.atr(14)
atrSL = close - atr * 2

plot(atrSL, color=color.red, title="ATR Stoploss")

// =====================================================
// QUALITY SCORE
// =====================================================
score = 0

score += stage2 ? 25 : 0
score += rsScore > 10 ? 25 : rsScore > 0 ? 15 : 0
score += rvol > 1.5 ? 20 : 0
score += breakout ? 20 : 0
score += nr7 or insideBar ? 10 : 0

grade =
 score >= 85 ? "A+" :
 score >= 70 ? "A" :
 score >= 55 ? "B" : "AVOID"

// =====================================================
// BUY SIGNAL
// =====================================================
buySignal =
 breakout and
 stage2 and
 rsScore > 0

plotshape(showSignals and buySignal, style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
// =====================================================
// DASHBOARD
// =====================================================
var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast and showTable

    table.cell(dash, 0, 0, "Metric", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "Value", bgcolor=color.black, text_color=color.white)

    table.cell(dash, 0, 1, "Trend")
    table.cell(dash, 1, 1, trendText, text_color = stage2 ? color.lime : color.red)

    table.cell(dash, 0, 2, "RS")
    table.cell(dash, 1, 2, rsText + " (" + str.tostring(math.round(rsScore)) + ")")

    table.cell(dash, 0, 3, "RVOL")
    table.cell(dash, 1, 3, str.tostring(rvol, "#.##") + "x")

    table.cell(dash, 0, 4, "ADR")
    table.cell(dash, 1, 4, str.tostring(adr, "#.##") + "%")

    table.cell(dash, 0, 7, "Score")
    table.cell(dash, 1, 7, str.tostring(score) + "/100")

    table.cell(dash, 0, 2, "RS")
    table.cell(dash,1,2,rsText + " (" + str.tostring(math.round(rsScore)) + ")")

    table.cell(dash, 0, 3, "RVOL")
    table.cell(dash, 1, 3, str.tostring(rvol, "#.##") + "x")

    table.cell(dash, 0, 4, "ADR")
    table.cell(dash, 1, 4, str.tostring(adr, "#.##") + "%")

// =====================================================
// ALERTS
// =====================================================
alertcondition(buySignal, title="BUY SIGNAL", message="SQB BUY setup detected")
````
