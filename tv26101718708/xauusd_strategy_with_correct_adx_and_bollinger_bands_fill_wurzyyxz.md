# XAU/USD Strategy with Correct ADX and Bollinger Bands Fill

- url: https://www.tradingview.com/script/WUrZyYxZ-XAU-USD-Strategy-with-Correct-ADX-and-Bollinger-Bands-Fill/
- type: strategy
- pine_id: PUB;4670e8405eff40a494a02030002f73b3
- version: 1.0

## Description

1. *Indicators Used*:
   - *Exponential Moving Averages (EMAs)*: Two EMAs (20-period and 50-period) are used to identify the trend direction and potential entry points based on crossovers.
   - *Relative Strength Index (RSI)*: A momentum oscillator that measures the speed and change of price movements. It identifies overbought and oversold conditions.
   - *Bollinger Bands*: These consist of a middle line (simple moving average) and two outer bands (standard deviations away from the middle). They help to identify price volatility and potential reversal points.
   - *Average Directional Index (ADX)*: This indicator quantifies trend strength. It's derived from the Directional Movement Index (DMI) and helps confirm the presence of a strong trend.
   - *Average True Range (ATR)*: Used to calculate position size based on volatility, ensuring that trades align with the trader's risk tolerance.

2. *Entry Conditions*:
   - *Long Entry*: 
     - The 20 EMA crosses above the 50 EMA (indicating a potential bullish trend).
     - The RSI is below the oversold level (30), suggesting the asset may be undervalued.
     - The price is below the lower Bollinger Band, indicating potential price reversal.
     - The ADX is above a specified threshold (25), confirming that there is sufficient trend strength.
   
   - *Short Entry*:
     - The 20 EMA crosses below the 50 EMA (indicating a potential bearish trend).
     - The RSI is above the overbought level (70), suggesting the asset may be overvalued.
     - The price is above the upper Bollinger Band, indicating potential price reversal.
     - The ADX is above the specified threshold (25), confirming trend strength.

3. *Position Sizing*:
   - The script calculates the position size dynamically based on the trader's risk per trade (expressed as a percentage of the total capital) and the ATR. This ensures that the trader does not risk more than the specified percentage on any single trade, adjusting the position size according to market volatility.

4. *Exit Conditions*:
   - The strategy uses a trailing stop-loss mechanism to secure profits as the price moves in the trader's favor. The trailing stop is set at a percentage (1.5% by default) below the highest price reached since entry for long positions and above the lowest price for short positions.
   - Additionally, if the RSI crosses back above the overbought level while in a long position or below the oversold level while in a short position, the position is closed to prevent losses.

5. *Alerts*:
   - Alerts are set to notify the trader when a buy or sell condition is met based on the strategy's rules. This allows for timely execution of trades.

### Summary
This strategy aims to capture significant price movements in the XAU/USD market by combining trend-following (EMAs, ADX) and momentum indicators (RSI, Bollinger Bands). The dynamic position sizing based on ATR helps manage risk effectively. By implementing trailing stops and alert mechanisms, the strategy enhances the trader's ability to act quickly on opportunities while mitigating potential losses.

## Source Code

````pine
//@version=5
strategy("Profit-Optimized XAU/USD Strategy with Correct ADX and Bollinger Bands Fill", overlay=true, margin_long=100, margin_short=100)

// Input Parameters
shortEmaLength = input.int(20, title="Short EMA Length", minval=1)
longEmaLength = input.int(50, title="Long EMA Length", minval=1)
rsiLength = input.int(14, title="RSI Length")
rsiOverbought = input.int(70, title="RSI Overbought Level", minval=50)
rsiOversold = input.int(30, title="RSI Oversold Level", minval=0)
bbLength = input.int(20, title="Bollinger Bands Length")
bbMultiplier = input.float(2.0, title="Bollinger Bands Multiplier")
adxLength = input.int(14, title="ADX Length")
adxSmoothing = input.int(14, title="ADX Smoothing Length")
adxThreshold = input.int(25, title="ADX Threshold for Trend Strength", minval=10)
atrLength = input.int(14, title="ATR Length")
riskPerTrade = input.float(1.0, title="Risk Per Trade (%)")

// EMA Calculations
shortEma = ta.ema(close, shortEmaLength)
longEma = ta.ema(close, longEmaLength)

// RSI Calculation
rsi = ta.rsi(close, rsiLength)

// Bollinger Bands Calculation
basis = ta.sma(close, bbLength)
dev = bbMultiplier * ta.stdev(close, bbLength)
upperBand = basis + dev
lowerBand = basis - dev

// ADX Calculation: Extracting components from ta.dmi
[diPlus, diMinus, adx] = ta.dmi(adxLength, adxSmoothing)

// ATR Calculation (Average True Range)
atr = ta.atr(atrLength)

// Plotting EMA
plot(shortEma, color=color.blue, title="20 EMA")
plot(longEma, color=color.red, title="50 EMA")

// Plotting Bollinger Bands as plot() objects
upperBandPlot = plot(upperBand, "Upper Band", color=color.green)
lowerBandPlot = plot(lowerBand, "Lower Band", color=color.green)

// Use fill() to fill between upperBandPlot and lowerBandPlot
fill(upperBandPlot, lowerBandPlot, color=color.new(color.green, 90), title="Bollinger Bands Fill")

// Plotting RSI
rsiColor = rsi > rsiOverbought ? color.red : rsi < rsiOversold ? color.green : color.white
hline(rsiOverbought, "Overbought Level", color=color.red)
hline(rsiOversold, "Oversold Level", color=color.green)
plot(rsi, color=rsiColor, linewidth=2, title="RSI")

// Dynamic Position Sizing based on ATR and Risk
capital = strategy.equity
positionSize = (capital * (riskPerTrade / 100)) / (atr * syminfo.mintick)

// Long Entry Condition: EMA Crossover, RSI oversold, Price below lower BB, ADX confirms trend strength
longCondition = ta.crossover(shortEma, longEma) and rsi < rsiOversold and close < lowerBand and adx > adxThreshold

// Short Entry Condition: EMA Crossunder, RSI overbought, Price above upper BB, ADX confirms trend strength
shortCondition = ta.crossunder(shortEma, longEma) and rsi > rsiOverbought and close > upperBand and adx > adxThreshold

// Trailing Stop-Loss for Long and Short Positions
trailStopPerc = input.float(1.5, title="Trailing Stop (%)")
trailOffset = trailStopPerc / 100

// Execute Long Trade
if (longCondition)
    strategy.entry("Long", strategy.long, qty=positionSize)
    strategy.exit("Trail Stop", "Long", trail_offset=trailOffset, limit=close * (1 + 0.02)) // Partial take-profit 2% higher

// Execute Short Trade
if (shortCondition)
    strategy.entry("Short", strategy.short, qty=positionSize)
    strategy.exit("Trail Stop", "Short", trail_offset=trailOffset, limit=close * (1 - 0.02)) // Partial take-profit 2% lower

// Exit if opposite signals appear (optional early exits)
if (rsi > rsiOverbought and strategy.position_size > 0)
    strategy.close("Long", comment="RSI Exit")
if (rsi < rsiOversold and strategy.position_size < 0)
    strategy.close("Short", comment="RSI Exit")

// Alerts for Entries and Exits
if (longCondition)
    alert("Buy Signal: EMA Crossover, RSI Oversold, Price Below Lower BB, ADX strong", alert.freq_once_per_bar)

if (shortCondition)
    alert("Sell Signal: EMA Crossunder, RSI Overbought, Price Above Upper BB, ADX strong", alert.freq_once_per_bar)
````
