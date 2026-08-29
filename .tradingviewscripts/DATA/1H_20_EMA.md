<!-- tradingview-pine-id: PUB;e38ed52b92a94174b941302d1b085a99 -->
<!-- tradingviewscripts-format: 1 -->
# 1H 20 EMA

Source: https://www.tradingview.com/script/ebon7tSH-1H-20-EMA/

## Description

1H 20 EMA — Fixed Hourly Exponential Moving Average

The 1H 20 EMA indicator plots the 20-period Exponential Moving Average calculated specifically from 1-hour candle closing prices, regardless of the timeframe currently selected on the chart.

This is useful for traders who use the hourly 20 EMA as a key trend and momentum reference but prefer to execute trades on lower timeframes such as the 1-minute, 5-minute, 10-minute, or 15-minute chart.

Unlike a standard 20 EMA, which automatically recalculates based on the active chart timeframe, this indicator remains anchored to the 1-hour timeframe. For example, when viewing a 5-minute chart, a standard 20 EMA represents the exponential moving average of the previous 20 five-minute candles. This indicator instead continues to display the EMA calculated from 20 hourly candles.

Because more weight is given to recent price data, the 20 EMA can help traders visualize short-to-intermediate-term momentum and the direction of the prevailing hourly trend. It may also serve as a dynamic area of support or resistance when viewed alongside intraday price action.

Key Features

Calculates the 20 EMA using 1-hour price data
Uses candle closing prices as the calculation source
Remains anchored to the 1-hour timeframe when viewing lower-timeframe charts
Provides hourly trend context without requiring traders to switch between chart timeframes
Useful for intraday and multi-timeframe technical analysis
Clean and simple overlay designed to minimize chart clutter

The 1H 20 EMA can be used alongside other technical tools such as VWAP, volume, support and resistance levels, daily moving averages, and price action to provide additional market context.

This indicator is intended as a technical analysis tool and should not be considered a standalone trading signal or financial advice.

---

## Source Code

````pine
//@version=6
indicator("1H 20 EMA", overlay=true)

hourly20EMA = request.security(
     syminfo.tickerid,
     "60",
     ta.ema(close, 20)
)

plot(hourly20EMA, title="1H 20 EMA", linewidth=2)
````
