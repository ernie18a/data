# Bullish HA candle with K/D cross

- url: https://www.tradingview.com/script/tvoYgTBP-Bullish-HA-candle-with-K-D-cross/
- type: indicator
- pine_id: PUB;9d1c4730720345b29ac01e9547533b55
- version: 1.0

## Description

Alerts when a bullish heikin ashi candle with little to no wick appears, at the same time D crosses up K on the stochastic RSI. Best used on smaller timeframes, I personally use it on the 3 min and use higher timeframes to confirm the direction. 

Best used with ext hours ON.

Best used on very liquid instruments like SPY.

Not suitable for swinging. Daytrading/scalps only.

Great for catching those opening moves when volatility is greatest.

## Source Code

````pine
//@version=6
indicator('Bullish HA candle with K/D cross', overlay = true, max_bars_back = 5000)

// === INPUTS ===
rsiLength = input.int(14, 'RSI Length', minval = 1, group = 'Stochastic RSI')
stochKLen = input.int(14, 'Stoch RSI %K Length', minval = 1, group = 'Stochastic RSI')
smoothK = input.int(3, '%K Smoothing', minval = 1, group = 'Stochastic RSI')
dLength = input.int(3, '%D Smoothing', minval = 1, group = 'Stochastic RSI')

strictWick = input.bool(true, 'Require No/Very Small Lower Wick', group = 'Heikin Ashi')
wickTol = input.float(0.0, 'Lower Wick Tolerance (price units)', minval = 0, step = 0.0001, group = 'Heikin Ashi', tooltip = '0 = exact no lower wick. Increase slightly for \'very close\'.')

// === HEIKIN ASHI (Accurate) ===
haTicker = ticker.heikinashi(syminfo.tickerid)
[haOpen, haHigh, haLow, haClose] = request.security(haTicker, timeframe.period, [open, high, low, close])

// === STOCHASTIC RSI ===
rsiSrc = ta.rsi(close, rsiLength)
k_raw = ta.stoch(rsiSrc, rsiSrc, rsiSrc, stochKLen)
k = ta.sma(k_raw, smoothK)
d = ta.sma(k, dLength)

stochRSICrossUp = ta.crossover(k, d)

// === STRONG BULLISH HA ===
isBullishHA = haClose > haOpen
lowerWickSize = haOpen - haLow
noLowerWick = lowerWickSize <= wickTol
strongBullishHA = isBullishHA and (not strictWick or noLowerWick)

// === FINAL SIGNAL ===
signal = stochRSICrossUp and strongBullishHA

// === PLOTS ===
plotshape(signal, title = 'Strong Buy Signal', location = location.belowbar, color = color.new(color.green, 0), style = shape.triangleup, size = size.normal)

bgcolor(signal ? color.new(color.green, 90) : na, title = 'Signal Highlight')

// === ALERT ===
alertcondition(signal, title = 'Strong Bullish HA + Stoch RSI Cross', message = '✅ Strong Bullish HA + Stochastic RSI K crossed above D')
````
