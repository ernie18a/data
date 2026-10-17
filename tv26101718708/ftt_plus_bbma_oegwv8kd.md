# FTT Plus BBMA

- url: https://www.tradingview.com/script/OegWv8KD-FTT-Plus-BBMA/
- type: indicator
- pine_id: PUB;4ad5c1b082754969971d8918e4c6fba8
- version: 1.0

## Description

The FTT Plus BBMA indicator combines Bollinger Bands with a unique 3-candle momentum pattern to identify potential trend reversal signals. It is designed for traders who follow price action and volatility-based strategies.

🔹 How It Works:

Bollinger Bands (20, 2) – Used to identify overbought and oversold conditions. The upper and lower bands act as dynamic support/resistance levels.

FTT Candlestick Pattern – A 3-bar pattern that confirms momentum shifts before a potential breakout.

🔹 Bullish Signal (BUY):
Triggered when the following conditions are met:

Candle-2: Bullish (close > open)

Candle-1: Bearish (close < open)

Current Candle: Bullish (close > open)

Price breaks above the previous high

Price closes above the upper Bollinger Band

🔹 Bearish Signal (SELL):
Triggered when:

Candle-2: Bearish (close < open)

Candle-1: Bullish (close > open)

Current Candle: Bearish (close < open)

Price breaks below the previous low

Price closes below the lower Bollinger Band

🔹 Visual Features:

Candles are highlighted in cyan for bullish signals and yellow for bearish signals.

BUY (triangle up) and SELL (triangle down) labels appear directly on the chart.

Built-in alert conditions for both signals (BUY / SELL).

🔹 Best Used On:

Timeframes: 5min to 1 hour (scalping & intraday)

Markets: Forex, Crypto, Stocks, Indices

🔹 Note:
This indicator works best in trending or high-volatility conditions. Avoid using in choppy or sideways markets without additional filters.

## Source Code

````pine
//@version=5
indicator("FTT Plus BBMA", overlay = true)

// =======================
// INPUT
// =======================
bbLength = input.int(20, title = "BB Length")
bbStd    = input.float(2.0, title = "BB Std Dev")

// =======================
// BOLLINGER BAND
// =======================
basis = ta.sma(close, bbLength)
dev   = bbStd * ta.stdev(close, bbLength)

upper = basis + dev
lower = basis - dev

//plot(upper, color = color.red, title = "Top BB")
//plot(basis, color = color.gray, title = "Mid BB")
//lot(lower, color = color.green, title = "Low BB")

// =======================
// BULLISH SETUP
// =======================
bull1 = close[2] > open[2]
bear2 = close[1] < open[1]
bull3 = close > open

breakHigh  = close > high[1]
breakTopBB = close > upper

fttBull = bull1 and bear2 and bull3 and breakHigh and breakTopBB

// =======================
// BEARISH SETUP
// =======================
bear1 = close[2] < open[2]
bull2 = close[1] > open[1]
bear3 = close < open

breakLow   = close < low[1]
breakLowBB = close < lower

fttBear = bear1 and bull2 and bear3 and breakLow and breakLowBB

// =======================
// WARNAKAN CANDLE
// =======================
barcolor(fttBull ? color.rgb(0, 204, 255) : fttBear ? color.rgb(251, 255, 0) : na)

// =======================
// SIGNAL
// =======================
plotshape(fttBull, title="FTT Bull", style=shape.triangleup, location=location.belowbar, color=color.rgb(0, 247, 255), text="BUY", textcolor=color.white)
plotshape(fttBear, title="FTT Bear", style=shape.triangledown, location=location.abovebar, color=color.rgb(255, 238, 0), text="SELL", textcolor=color.white)

// =======================
// ALERTS
// =======================
alertcondition(fttBull, title="FTT BUY Alert", message="FTT BUY Signal muncul")
alertcondition(fttBear, title="FTT SELL Alert", message="FTT SELL Signal muncul")
````
