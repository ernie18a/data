<!-- tradingview-pine-id: PUB;af8efe2c8024483795470cfd2e9d3031 -->
<!-- tradingviewscripts-format: 1 -->
# PropKorea Momentum Slope

Source: https://www.tradingview.com/script/9244qTPE-PropKorea-Momentum-Slope/

## Description

The PropKorea Momentum Slope is a specialized trend-following indicator designed to capture the exact moment when market momentum accelerates. Rather than simply plotting price direction, this script measures the 'Rate of Change' (acceleration) of moving averages to help you identify powerful trends and filter out flat, choppy markets.

How It Works:
This indicator calculates the momentum of two distinct Moving Averages:

UD1 (Aqua Line): Short-term Momentum. It measures the rate of change of the 13 EMA, which is then smoothed by a 5 EMA for noise reduction.

UD2 (Fuchsia Line): Long-term Momentum. It measures the rate of change of the 34 EMA, smoothed by a 13 EMA.

How to Read the Signals:

🟢 Green Background (Bullish Momentum): Occurs when UD1 crosses above UD2. This indicates that short-term upside momentum is overpowering long-term momentum. It is an ideal environment to look for long entries or hold current long positions.

🔴 Red Background (Bearish Momentum): Occurs when UD1 falls below UD2. Short-term momentum is slowing down or reversing downward. This serves as a warning to manage risk on long positions or a signal to look for short setups.

Trading Philosophy:
Perfect entries require patience. This indicator is built for traders who love riding strong, unstoppable trends and prefer to stay on the sidelines during quiet, range-bound periods. It is highly effective for highly volatile instruments like Index Futures (Nasdaq 100, US30, etc.) where momentum breakouts are explosive.

Note: Because this indicator utilizes double-smoothing to eliminate fake signals, it acts as a momentum confirmation tool rather than a top/bottom picker. Wait for the setup, trust the momentum, and enjoy the trend.

---

## Source Code

````pine
//@version=6
indicator(title='PropKorea Momentum Slope', shorttitle='PK Momentum', overlay=false)

a = ta.ema((ta.ema(close, 13) - ta.ema(close[1], 13)) / ta.ema(close[1], 13) * 100000, 5)
b = ta.ema((ta.ema(close, 34) - ta.ema(close[1], 34)) / ta.ema(close[1], 34) * 100000, 13)

plot(a, color=color.new(color.aqua, 0), title='UD1')
plot(b, color=color.new(color.fuchsia, 0), title='UD2')

bgcolor(a >= b ? color.new(color.green, 80) : color.new(color.red, 80))
````
