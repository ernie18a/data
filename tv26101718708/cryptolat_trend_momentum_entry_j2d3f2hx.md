# CryptoLat Trend + Momentum Entry

- url: https://www.tradingview.com/script/J2D3F2hx-CryptoLat-Trend-Momentum-Entry/
- type: indicator
- pine_id: PUB;64816a0c8ab34bfca1b4f07a9268b8fa
- version: 1.0

## Description

This indicator combines trend-following and momentum confirmation into a simplified entry model.

It uses a dual moving average structure (fast and slow EMA) to define directional bias, and a momentum filter (RSI) to validate entry conditions and reduce noise.

How it works:

- Trend is defined using the relationship between the fast EMA and slow EMA.
- Long conditions require:
  - Uptrend confirmation (fast EMA above slow EMA)
  - Price trading above the fast EMA
  - RSI strength above a defined threshold

- Short conditions require:
  - Downtrend confirmation (fast EMA below slow EMA)
  - Price trading below the fast EMA
  - RSI weakness below a defined threshold

This layered approach aims to:
- Avoid counter-trend entries
- Filter weak signals
- Provide cleaner momentum-based entries aligned with trend direction

The background coloring provides an additional visual context of the prevailing trend environment.

This tool is designed for traders looking for a structured and simplified way to combine trend and momentum without overcomplicating their charts.

## Source Code

````pine
//@version=5
indicator("CryptoLat Trend + Momentum Entry", overlay=true)

// === INPUTS ===
emaFastLen = input.int(50, "EMA Fast")
emaSlowLen = input.int(200, "EMA Slow")
rsiLen = input.int(14, "RSI Length")

// === CÁLCULOS ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsi = ta.rsi(close, rsiLen)

// === CONDICIONES ===
bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

buySignal = bullTrend and close > emaFast and rsi > 55
sellSignal = bearTrend and close < emaFast and rsi < 45

// === PLOTS ===
plot(emaFast, color=color.green, linewidth=2, title="EMA 50")
plot(emaSlow, color=color.red, linewidth=2, title="EMA 200")

// === SEÑALES ===
plotshape(buySignal, title="BUY", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === FONDO OPCIONAL ===
bgcolor(bullTrend ? color.new(color.green, 92) : bearTrend ? color.new(color.red, 92) : na)
````
