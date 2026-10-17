# Stochastic Full Weighted 14-6-14 PRIMUS

- url: https://www.tradingview.com/script/aDxdMVC9-Stochastic-Full-Weighted-14-6-14-PRIMUS/
- type: indicator
- pine_id: PUB;476e841af3554d4ab5ea563056bf8d7a
- version: 1.0

## Description

Stochastic Full Weighted 14-6-14
This indicator is a Full Weighted Stochastic Oscillator configured with 14-6-14 settings.
The Full K line, shown in blue, is calculated by smoothing the 14-period Fast Stochastic using a 14-period Weighted Moving Average (WMA). The Full D line, shown in orange, is a 6-period WMA of the Full K line.
Settings:
- Stochastic period: 14
- Full K smoothing: 14-period WMA
- Full D smoothing: 6-period WMA
- Overbought level: 70
- Oversold level: 30
Interpretation:
- A bullish crossover occurs when Full K crosses above Full D and may indicate increasing upward momentum.
- A bearish crossover occurs when Full K crosses below Full D and may indicate increasing downward momentum.
- Bullish crossovers below 30 may help identify potential upward reversals.
- Bearish crossovers above 70 may help identify potential downward reversals.
- Signals should be confirmed using price action, volume, and the overall market trend.
This indicator does not execute trades automatically and is intended for educational and analytical purposes only. It is not financial advice. Always test the indicator thoroughly before using it with real capital.

## Source Code

````pine
//@version=6
indicator("Stochastic Full Weighted 14-6-14", overlay=false)

kPeriod = 14
dPeriod = 6
slowingPeriod = 14

lowestLow = ta.lowest(low, kPeriod)
highestHigh = ta.highest(high, kPeriod)
fastK = highestHigh != lowestLow ? 100 * (close - lowestLow) / (highestHigh - lowestLow) : 0

fullK = ta.wma(fastK, slowingPeriod)
fullD = ta.wma(fullK, dPeriod)

plot(fullK, "Full K", color=color.blue, linewidth=2)
plot(fullD, "Full D", color=color.orange, linewidth=2)
hline(70, "Sobrecompra", color=color.red)
hline(30, "Sobreventa", color=color.green)
````
