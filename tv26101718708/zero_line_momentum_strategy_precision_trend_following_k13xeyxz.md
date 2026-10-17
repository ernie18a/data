# Zero Line Momentum Strategy: Precision Trend Following

- url: https://www.tradingview.com/script/k13xEYxZ-zero-line-momentum-strategy-precision-trend-following/
- type: strategy
- pine_id: PUB;9800a33b39e04d028014cb4e4abb5e39
- version: 1.0

## Description

The Zero Line Momentum Strategy is built on the philosophy that trend continuation is best captured by momentum oscillators filtered by long-term trend structures. By combining the 200-period EMA with a refined Wave Trend oscillator, we filter out market noise and focus on high-probability entries.

The strategy utilizes a two-step confirmation process:

Trend Filter: We use a 200 EMA to define the macro trend.

Momentum Trigger: We use a refined Wave Trend calculation (based on EMA of price deviations) to identify entries when momentum crosses the zero line.

🟢 Long: Price > 200 EMA AND Wave Trend crosses above 0.

🔴 Short: Price < 200 EMA AND Wave Trend crosses below 0.

Discipline is key. This strategy is pre-configured with:

Position Sizing: Fixed at 10% of equity per trade to manage drawdown.

Execution: Orders process at bar close to avoid signal repaint.

Note: Always consider adding your own ATR-based Stop Loss for better exit management.

Crypto: Use lower sensitivity (increase Length) to avoid noise.

Forex: Optimize the avg input to match the pair's volatility.

Timeframes: Best results found on 1H to 4H charts.

I am committed to making this strategy the best tool for our community. Your feedback is invaluable! Please share your backtest results in the comments below. Do you have ideas for adding a custom Take Profit or trailing stop? Let’s improve this together.

Disclaimer:This script is for educational purposes only. Trading involves significant risk of loss. Always backtest strategies thoroughly and use proper risk management before risking real capital. Past performance is not indicative of future results

## Source Code

````pine
//@version=5
strategy("Zero Line Momentum Strategy", overlay=true)

ema200 = ta.ema(close, 200)
plot(ema200)

length = 9
avg = 12

esa = ta.ema(close, length)
d = ta.ema(math.abs(close - esa), length)
ci = (close - esa) / (0.015 * d)
wt1 = ta.ema(ci, avg)

longCondition = (close > ema200 and ta.crossover(wt1, 0))
shortCondition = (close < ema200 and ta.crossunder(wt1, 0))

if longCondition
    strategy.entry("Long", strategy.long)

if shortCondition
    strategy.entry("Short", strategy.short)
````
