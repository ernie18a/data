# Trend Clarity with RSI Momentum

- url: https://www.tradingview.com/script/jq38phPw-Trend-Clarity-with-RSI-Momentum/
- type: indicator
- pine_id: PUB;cd71fa32a5744babafbb5b76bf3e64c2
- version: 1.0

## Description

This indication can help to inditify clear trend using several moving average crossovers and trend strength.

## Source Code

````pine
//@version=6
indicator("RSI + EMA Trend Highlighter", overlay=true, max_labels_count=500)

// === INPUTS ===
rsiLength   = input.int(14, "RSI Length")
rsiMaLength = input.int(14, "RSI MA Length")

emaFastLen  = input.int(18, "EMA Fast")
emaSlowLen  = input.int(27, "EMA Slow")
emaTrendLen = input.int(90, "EMA Trend")

// === EMA CALCULATIONS ===
ema18 = ta.ema(close, emaFastLen)
ema27 = ta.ema(close, emaSlowLen)
ema90 = ta.ema(close, emaTrendLen)

// === RSI CALCULATIONS ===
rsiValue = ta.rsi(close, rsiLength)
rsiMA    = ta.sma(rsiValue, rsiMaLength)

// === BULLISH CONDITIONS ===
bullEMA = ema18 > ema27 and ema18 > ema90 and ema27 > ema90
bullRSI = rsiValue > rsiMA and rsiValue > 50 and rsiMA > 50

bullTrend = bullEMA and bullRSI

// === BEARISH CONDITIONS ===
bearEMA = ema18 < ema27 and ema18 < ema90 and ema27 < ema90
bearRSI = rsiValue < rsiMA and rsiValue < 50 and rsiMA < 50

bearTrend = bearEMA and bearRSI

// === TREND START DETECTION ===
bullStart = bullTrend and not bullTrend[1]
bearStart = bearTrend and not bearTrend[1]

// === BACKGROUND HIGHLIGHT ===
bgcolor(bullTrend ? color.new(color.green, 90) : na)
bgcolor(bearTrend ? color.new(color.red, 90) : na)

// === BUY LABEL ===
if bullStart
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

// === SELL LABEL ===
if bearStart
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

// === OPTIONAL EMA PLOTS ===
plot(ema18, color=color.lime, title="EMA 18", linewidth=2)
plot(ema27, color=color.orange, title="EMA 27", linewidth=2)
plot(ema90, color=color.blue, title="EMA 90", linewidth=2)

// === ALERTS ===
alertcondition(bullStart, title="BUY Signal", message="Bullish trend started")
alertcondition(bearStart, title="SELL Signal", message="Bearish trend started")
````
