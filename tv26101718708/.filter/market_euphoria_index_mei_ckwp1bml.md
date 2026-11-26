# Market Euphoria Index - MEI

- url: https://www.tradingview.com/script/cKwp1bmL-Market-Euphoria-Index-MEI/
- type: indicator
- pine_id: PUB;f822182951b24d9eb18b8287bea7fd6e
- version: 1.0

## Description

1. The Three Core Factors
The script measures market sentiment by evaluating three different "factors" of price action and assigning a score from 0 to 100 for both Euphoria and Panic.

RSI Factor (Momentum Extremes): It checks if the traditional RSI is overextended.

If RSI is above 70, it scales the value into an Euphoria Score. For example, an RSI of 85 will have a higher Euphoria score than an RSI of 75.

If RSI is below 30, it scales into a Panic Score.

VWAP Stretch Factor (Overextension): It measures how far the current price has stretched away from the Volume Weighted Average Price (VWAP), normalized by the Average True Range (ATR).

If the price shoots up higher than the VWAP by a multiple of the ATR (default is 2.0x), it triggers a maximum 100 Euphoria Score (indicating the asset is heavily overvalued relative to its average volume-weighted baseline).

If it crashes below the VWAP by the same distance, it triggers a 100 Panic Score.
Price Momentum / K's Factor (Candlestick Sentiment): This looks purely at the candlesticks over the last 14 periods (by default).

It counts how many candles closed higher than they opened (Bullish candles) and converts that ratio into an Euphoria Score.

It does the inverse for Bearish candles to create a Panic Score.

2. The Composite Blend
Once the script has the three Euphoria scores and three Panic scores, it averages them:

pinescript - 
euphoriaScore = (rsiEuphoria + vwapEuphoria + momEuphoria) / 3
panicScore = (rsiPanic + vwapPanic + momPanic) / 3
Finally, it subtracts the panicScore from the euphoriaScore to get the final mei value.

3. Interpretation & Visuals
The indicator plots as a histogram with dynamic colors and static threshold lines:

> +50 (Red): Extreme Euphoria. The market is firing on all cylinders (RSI overbought, stretched far above VWAP, heavily bullish candles). High risk of a blow-off top reversal.

> +20 (Orange): Standard Euphoria/Strong Uptrend.
Between -20 and +20 (Gray): Neutral market.

< -20 (Teal): Standard Panic/Strong Downtrend.

< -50 (Green): Extreme Panic. The market is oversold, stretched far below VWAP, and showing heavy bearish momentum. High probability of a capitulation bottom bounce.

The script also includes built-in alert conditions (Extreme Euphoria Alert and Extreme Panic Alert) so you can automate notifications when the market reaches these psychological extremes!

## Source Code

````pine
//@version=6
indicator("Market Euphoria Index - MEI", shorttitle="GM_MEI", format=format.price, precision=2)

// --- Inputs ---
length = input.int(14, "Lookback Length")
rsiLength = input.int(14, "RSI Length")
vwapMult = input.float(2.0, "VWAP Stretch Multiplier")

// --- Factors ---
// 1. RSI Factor
rsiVal = ta.rsi(close, rsiLength)
rsiEuphoria = rsiVal > 70 ? (rsiVal - 70) / 30 * 100 : 0
rsiPanic = rsiVal < 30 ? (30 - rsiVal) / 30 * 100 : 0

// 2. VWAP Stretch Factor
vwapVal = ta.vwap(hlc3)
atrVal = ta.atr(length)
dist = close - vwapVal
vwapEuphoria = dist > (vwapMult * atrVal) ? 100 : 0
vwapPanic = dist < -(vwapMult * atrVal) ? 100 : 0

// 3. Price Momentum (K's Factor proxy)
bullCount = math.sum(close > open ? 1 : 0, length)
bearCount = math.sum(close < open ? 1 : 0, length)
momEuphoria = (bullCount / length) * 100
momPanic = (bearCount / length) * 100

// --- Composite MEI ---
// Blend the three factors
euphoriaScore = (rsiEuphoria + vwapEuphoria + momEuphoria) / 3
panicScore = (rsiPanic + vwapPanic + momPanic) / 3

mei = euphoriaScore - panicScore

// --- Plotting ---
color meiColor = mei > 50 ? color.new(color.red, 20) : mei > 20 ? color.new(color.orange, 40) : mei < -50 ? color.new(color.green, 20) : mei < -20 ? color.new(color.teal, 40) : color.new(color.gray, 60)

plot(mei, "MEI", color=meiColor, style=plot.style_histogram, linewidth=3)
hline(50, "Extreme Euphoria", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(20, "Euphoria", color=color.new(color.orange, 50), linestyle=hline.style_dotted)
hline(0, "Neutral", color=color.new(color.gray, 50))
hline(-20, "Panic", color=color.new(color.teal, 50), linestyle=hline.style_dotted)
hline(-50, "Extreme Panic", color=color.new(color.green, 50), linestyle=hline.style_dashed)

// Alerts
alertcondition(mei > 50, title="Extreme Euphoria Alert", message="Market Euphoria Index > 50! Potential Blow-off top.")
alertcondition(mei < -50, title="Extreme Panic Alert", message="Market Euphoria Index < -50! Potential Capitulation bottom.")
````
