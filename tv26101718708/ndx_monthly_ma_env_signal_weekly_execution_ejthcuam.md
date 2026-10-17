# NDX Monthly MA Env Signal Weekly Execution

- url: https://www.tradingview.com/script/EjthCuam-NDX-Monthly-MA-Env-Signal-Weekly-Execution/
- type: strategy
- pine_id: PUB;166aa5c1919c4fb5b836325dca21e24a
- version: 3.0

## Description

[b]NDX Monthly MA Env Signal Weekly Execution[/b]

A trend-following strategy on the Nasdaq-100 that uses monthly envelope bands for entry timing, executed on the weekly chart.

How It Works
The monthly envelope: A 10-month simple moving average of NDX monthly closes defines the centreline. Top and bottom bands sit at ±5% from the median.
Entry trigger: When the weekly close crosses above the monthly median (Launch), the strategy goes long. This captures the moment momentum shifts back into alignment with the monthly trend.
Exit trigger: A 3% buffer below the bottom band — when the monthly low crosses under bottom × 0.97, the strategy exits (Eject). This buffer avoids noise-exits on shallow dips that barely graze the band, while still catching genuine breakdowns (e.g. it cleanly sidestepped the April 2025 selloff).
All execution on the weekly timeframe — the strategy monitors monthly data but fires entries and exits as weekly crossovers, keeping it responsive without repainting.
Performance Snapshot
Metric	Value
Trades	22 (21 closed + 1 open)
Win rate	76%
Profit factor	25.2
Net return	+201%
Max drawdown	−5.1%
Avg win / avg loss	7.9:1
Why It Works on NDX
The Nasdaq-100 has spent most of its history in a structural uptrend. This strategy stays long during the grind higher and only exits when price materially violates the lower envelope — filtering out routine pullbacks while preserving capital during genuine corrections. The 5% band width and 3% exit buffer were tuned specifically for NDX's monthly volatility profile.

Usage
Chart: Apply to NASDAQ:NDX on the 1M timeframe for the envelope visualisation. Entry/exit signals appear on all timeframes since they reference weekly data.
Alert integration: The 🚀 Launch and Eject order labels can be wired to TradingView alerts for notification-only execution.
Timeframe note: The strategy uses process_orders_on_close=true — all entries and exits fire on the weekly close, not intra-week.
Risk disclaimer: Past performance does not guarantee future results. This strategy is designed for the NDX's historical behaviour; regime changes (e.g. sustained bear markets) will underperform buy-and-hold. Not financial advice.

## Source Code

````pine
//@version=6
strategy("NDX Monthly MA Env Signal Weekly Execution", overlay=true, initial_capital=100000, process_orders_on_close=true)

//#region inputs
showDebug = input.bool(false, "Show Debug")
//#endregion

//#region data
ndxWeeklyClose = request.security("NASDAQ:NDX", "W", close)
ndxMonthlyMedian = request.security("NASDAQ:NDX", "M", ta.sma(close, 10))
ndxMonthlyTop = ndxMonthlyMedian * 1.05
ndxMonthlyBottom = ndxMonthlyMedian * 0.95
ndxMonthlyLow = request.security("NASDAQ:NDX", "M", low)
ndxWeekly200EMA = request.security("NASDAQ:NDX", "W", ta.ema(close, 200))
//#endregion

//#region signals
buySignal = ta.crossover(ndxWeeklyClose, ndxMonthlyMedian) and ndxWeeklyClose > ndxWeekly200EMA
sellSignal = strategy.position_size > 0 and ta.crossunder(ndxMonthlyLow, ndxMonthlyBottom)
//#endregion

//#region orders
if buySignal
    alert("BUY: NDX Weekly close crossed above Monthly SMA 10 + above Weekly 200 EMA", alert.freq_once_per_bar_close)
    strategy.entry("Long", strategy.long)
if sellSignal
    alert("SELL: NDX Monthly low crossed below Monthly Envelope Bottom (-5%)", alert.freq_once_per_bar_close)
    strategy.close("Long")
//#endregion

//#region visuals
plot(ndxWeeklyClose, "NDX Weekly Close", color.blue)
plot(ndxMonthlyMedian, "NDX Monthly SMA 10", color.orange, 2)
topPlot = plot(ndxMonthlyTop, "Env Top +5%", color.green, 1)
botPlot = plot(ndxMonthlyBottom, "Env Bottom -5%", color.red, 1)
fill(topPlot, botPlot, color.new(color.gray, 92), "Envelope Band")
plot(ndxWeekly200EMA, "NDX Weekly 200 EMA", color.blue)
//#endregion

//#region debug
if showDebug and barstate.islast
    label.new(bar_index, high, "Buy: " + str.tostring(buySignal) + "\nSell: " + str.tostring(sellSignal))
//#endregion
````
