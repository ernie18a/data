# Prav_trend

- url: https://www.tradingview.com/script/EFHvzCSN-Prav-trend/
- type: indicator
- pine_id: PUB;950ff55c9209433b9234fbaf1d9428bd
- version: 6.0

## Description

Shows buy signal when 1 hr is bullish price above vwap and 9/21 crossover in 9 ema

## Source Code

````pine
//@version=6
indicator("Prav_trend", overlay=true)

// ─────────────────────────────────────
// EMA
// ─────────────────────────────────────
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

plot(ema9, color=color.blue, title="EMA 9", linewidth=1)
plot(ema21, color=color.green, title="EMA 21", linewidth=2)

// ─────────────────────────────────────
// 5M ONLY
// ─────────────────────────────────────
is5MChart = timeframe.period == "5"

// ─────────────────────────────────────
// VWAP
// ─────────────────────────────────────
vwapValue = ta.vwap(hlc3)

plot(
     is5MChart ? vwapValue : na,
     color=color.orange,
     title="VWAP",
     linewidth=1)

// ─────────────────────────────────────
// CUSTOM NY SESSION FILTER
// ─────────────────────────────────────
useNYSession =
     input.bool(
          true,
          "Use NY Session Filter")

sessionInput =
     input.session(
          "0830-1400",
          "New York Session")

// ─────────────────────────────────────
// SESSION LOGIC
// ─────────────────────────────────────
inSession =
     not na(
          time(
               timeframe.period,
               sessionInput,
               "America/New_York"))

allowSignals =
     useNYSession
     ? inSession
     : true

// ─────────────────────────────────────
// MULTI TIMEFRAME TREND FUNCTION
// ─────────────────────────────────────
getTrend(tf) =>

    e9 =
         request.security(
              syminfo.tickerid,
              tf,
              ta.ema(close, 9))

    e21 =
         request.security(
              syminfo.tickerid,
              tf,
              ta.ema(close, 21))

    e9 > e21 ? 1 : -1

// ─────────────────────────────────────
// TREND VALUES
// 1H Candle Direction
// 1H Candle Closed Direction
oneHBullClose = request.security(
     syminfo.tickerid,
     "60",
     barstate.isconfirmed and close > open)

oneHBearClose = request.security(
     syminfo.tickerid,
     "60",
     barstate.isconfirmed and close < open)
// ─────────────────────────────────────
trendD  = getTrend("D")
trend4H = getTrend("240")
trend1H = getTrend("60")
trend5M = getTrend("5")
ema21_4H =
     request.security(
          syminfo.tickerid,
          "240",
          ta.ema(close, 21))

// ─────────────────────────────────────
// BUY TREND LOGIC
// Daily + 4H Bullish
// ─────────────────────────────────────
trendBull =
     trend4H == 1 and
     (
          trendD == 1 or
          trend1H == 1
     )

// ─────────────────────────────────────
// SELL TREND LOGIC
// 4H must be bearish and
// either Daily or 1H bearish
// ─────────────────────────────────────
trendBear =
     trend4H == -1 and
     (
          trendD == -1 or
          trend1H == -1
     )

// ─────────────────────────────────────
// VWAP FILTER
// ─────────────────────────────────────
vwapBull = close > vwapValue
vwapBear = close < vwapValue
// 4H EMA21 TOUCH LOGIC
// ─────────────────────────────────────
touch4Hema21 =
     low <= ema21_4H and
     high >= ema21_4H

bullTouch4Hema21 =
     trendBull and
     touch4Hema21

bearTouch4Hema21 =
     trendBear and
     touch4Hema21

// ─────────────────────────────────────
// FIRST ENTRY SIGNALS
// ─────────────────────────────────────
firstBuy =
     allowSignals and
     trendBull and
     vwapBull and
     ta.crossover(ema9, ema21)

firstSell =
     allowSignals and
     trendBear and
     vwapBear and
     ta.crossunder(ema9, ema21)

// ─────────────────────────────────────
// TREND CYCLE STATE
// ─────────────────────────────────────
var bool longCycleActive = false
var bool shortCycleActive = false

if firstBuy
    longCycleActive := true
    shortCycleActive := false

if firstSell
    shortCycleActive := true
    longCycleActive := false

if ta.crossunder(ema9, ema21)
    longCycleActive := false

if ta.crossover(ema9, ema21)
    shortCycleActive := false

// ─────────────────────────────────────
// CONTINUATION ENTRY LOGIC
// ─────────────────────────────────────
buyContinuation =
     allowSignals and
     longCycleActive and
     vwapBull and
     low <= ema21 and
     close > ema21 and
     close > open

sellContinuation =
     allowSignals and
     shortCycleActive and
     vwapBear and
     high >= ema21 and
     close < ema21 and
     close < open

// ─────────────────────────────────────
// SIGNAL PLOTS
// ─────────────────────────────────────
plotshape(
     is5MChart and firstBuy,
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY",
     size=size.small)

plotshape(
     is5MChart and firstSell,
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     size=size.small)

plotshape(
     is5MChart and buyContinuation,
     location=location.belowbar,
     style=shape.circle,
     color=color.lime,
     size=size.tiny,
     text="")

plotshape(
     is5MChart and sellContinuation,
     location=location.abovebar,
     style=shape.circle,
     color=color.red,
     size=size.tiny,
     text="")

// ─────────────────────────────────────
// ALERTS
// ─────────────────────────────────────
alertcondition(
     firstBuy,
     title="BUY Signal",
     message="Daily + 4H bullish BUY")

alertcondition(
     firstSell,
     title="SELL Signal",
     message="4H + 1H bearish SELL")
alertcondition(
     oneHBullClose,
     title="1H Bullish Candle Closed",
     message="1H candle has CLOSED bullish.")

alertcondition(
     oneHBearClose,
     title="1H Bearish Candle Closed",
     message="1H candle has CLOSED bearish.")


// ─────────────────────────────────────
// TREND TABLE
// ─────────────────────────────────────
var table t =
     table.new(position.top_right, 2, 4, border_width=1)

showRow(row, label, trend) =>

    table.cell(t, 0, row, label)

    table.cell(
         t,
         1,
         row,
         trend == 1 ? "Bullish" : "Bearish",
         text_color =
              trend == 1
              ? color.green
              : color.red)

showRow(0, "Daily", trendD)
showRow(1, "4H", trend4H)
showRow(2, "1H", trend1H)
showRow(3, "5M", trend5M)
````
