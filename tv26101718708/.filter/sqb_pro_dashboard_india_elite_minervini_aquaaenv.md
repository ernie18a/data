# SQB PRO Dashboard [India] - Elite Minervini

- url: https://www.tradingview.com/script/aQuAAENv-SQB-PRO-Dashboard-India-Elite-Minervini/
- type: indicator
- pine_id: PUB;534179a4af254c899c7a15fea944a1d3
- version: 1.0

## Description

Here’s the complete TradingView Pine Script v5 with:

* ✅ True Minervini Stage 2 Trend Template
* ✅ 50 / 150 / 200 SMA alignment
* ✅ Rising 200 SMA
* ✅ 52-week high/low filters
* ✅ 1-Year Relative Strength vs NIFTY
* ✅ RS Rating
* ✅ RVOL
* ✅ Liquidity Filter (₹10 Cr+ average traded value)
* ✅ NR7
* ✅ Inside Bar
* ✅ Breakout Detection
* ✅ ATR Stop Loss
* ✅ Institutional Accumulation Detection
* ✅ Quality Score
* ✅ Elite Buy Signal
* ✅ Dashboard

## Source Code

````pine
//@version=5
indicator("SQB PRO Dashboard [India] - Elite Minervini", overlay=true)

// =====================================================
// INPUTS
// =====================================================

benchmark = input.symbol("NSE:NIFTY", "Benchmark")

showEMA      = input.bool(true, "Show Moving Averages")
showSignals  = input.bool(true, "Show Buy Signals")
showTable    = input.bool(true, "Show Dashboard")

// =====================================================
// MOVING AVERAGES
// =====================================================

ema20  = ta.ema(close, 20)
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

plot(showEMA ? ema20 : na, title="20 EMA", color=color.green, linewidth=2)
plot(showEMA ? sma50 : na, title="50 SMA", color=color.orange, linewidth=2)
plot(showEMA ? sma150 : na, title="150 SMA", color=color.blue, linewidth=2)
plot(showEMA ? sma200 : na, title="200 SMA", color=color.red, linewidth=2)

// =====================================================
// MINERVINI STAGE 2
// =====================================================

week52Low  = ta.lowest(low, 252)
week52High = ta.highest(high, 252)

sma200Rising = sma200 > sma200[20]

stage2 =
     close > sma150 and
     close > sma200 and
     sma150 > sma200 and
     sma200Rising and
     sma50 > sma150 and
     sma50 > sma200 and
     close > sma50 and
     close >= week52Low * 1.30 and
     close >= week52High * 0.75

trendText = stage2 ? "STAGE 2" : "WEAK"

// =====================================================
// RELATIVE STRENGTH (1 YEAR)
// =====================================================

benchClose = request.security(benchmark, timeframe.period, close)

stockPerf = close / close[252]
benchPerf = benchClose / benchClose[252]

rsScore = ((stockPerf / benchPerf) - 1) * 100

rsRating =
     rsScore > 50 ? 99 :
     rsScore > 40 ? 95 :
     rsScore > 30 ? 90 :
     rsScore > 20 ? 80 :
     rsScore > 10 ? 70 :
     rsScore > 0 ? 60 : 40

rsText =
     rsRating >= 90 ? "LEADER" :
     rsRating >= 80 ? "STRONG" :
     rsRating >= 70 ? "GOOD" :
     "WEAK"

// =====================================================
// RVOL
// =====================================================

avgVol = ta.sma(volume, 20)
rvol = volume / avgVol

// =====================================================
// LIQUIDITY FILTER
// =====================================================

avgTurnover = ta.sma(volume * close, 20)
liquidStock = avgTurnover > 100000000

// =====================================================
// ADR
// =====================================================

adr = ta.sma((high - low) / low * 100, 20)

// =====================================================
// NR7
// =====================================================

rangeToday = high - low
nr7 = rangeToday == ta.lowest(rangeToday, 7)

// =====================================================
// INSIDE BAR
// =====================================================

insideBar =
     high < high[1] and
     low > low[1]

// =====================================================
// INSTITUTIONAL ACCUMULATION
// =====================================================

accumulation =
     close > open and
     volume > avgVol * 1.5

// =====================================================
// BREAKOUT
// =====================================================

breakout =
     close > ta.highest(high, 20)[1] and
     rvol > 1.5 and
     liquidStock

// =====================================================
// ATR STOPLOSS
// =====================================================

atr = ta.atr(14)
atrSL = close - atr * 2

plot(atrSL, title="ATR Stoploss", color=color.red)

// =====================================================
// QUALITY SCORE
// =====================================================

score = 0

score += stage2 ? 35 : 0

score += rsRating >= 90 ? 25 :
         rsRating >= 80 ? 20 :
         rsRating >= 70 ? 15 : 0

score += liquidStock ? 10 : 0

score += rvol > 2 ? 10 :
         rvol > 1.5 ? 5 : 0

score += breakout ? 15 : 0

score += accumulation ? 5 : 0

score += (nr7 or insideBar) ? 5 : 0

grade =
     score >= 90 ? "ELITE" :
     score >= 80 ? "A+" :
     score >= 70 ? "A" :
     score >= 60 ? "B" :
     "AVOID"

// =====================================================
// BUY SIGNAL
// =====================================================

buySignal =
     stage2 and
     breakout and
     rsRating >= 80 and
     liquidStock

plotshape(
     showSignals and buySignal,
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small)

// =====================================================
// DASHBOARD
// =====================================================

var table dash = table.new(position.top_right, 2, 10, border_width=1)

if barstate.islast and showTable

    table.cell(dash, 0, 0, "Metric", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "Value", bgcolor=color.black, text_color=color.white)

    table.cell(dash, 0, 1, "Trend")
    table.cell(dash, 1, 1, trendText,
         text_color = stage2 ? color.lime : color.red)

    table.cell(dash, 0, 2, "RS Rating")
    table.cell(dash, 1, 2, str.tostring(rsRating))

    table.cell(dash, 0, 3, "RVOL")
    table.cell(dash, 1, 3, str.tostring(rvol, "#.##") + "x")

    table.cell(dash, 0, 4, "ADR")
    table.cell(dash, 1, 4, str.tostring(adr, "#.##") + "%")

    table.cell(dash, 0, 5, "Liquidity")
    table.cell(dash, 1, 5, liquidStock ? "PASS" : "FAIL")

    table.cell(dash, 0, 6, "Near 52W High")
    table.cell(dash, 1, 6,
         str.tostring(math.round((close / week52High) * 100)) + "%")

    table.cell(dash, 0, 7, "Score")
    table.cell(dash, 1, 7,
         str.tostring(score) + "/100")

    table.cell(dash, 0, 8, "Grade")
    table.cell(dash, 1, 8, grade)

    table.cell(dash, 0, 9, "Setup")
    table.cell(dash, 1, 9,
         buySignal ? "BUY" :
         breakout ? "BREAKOUT" :
         "WAIT")

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     buySignal,
     title="BUY SIGNAL",
     message="SQB Elite Minervini Buy Setup Detected")
````
