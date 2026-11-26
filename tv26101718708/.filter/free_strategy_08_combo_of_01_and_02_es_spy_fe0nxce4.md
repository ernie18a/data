# Free Strategy #08 (Combo of #01 and #02) (ES / SPY)

- url: https://www.tradingview.com/script/fE0NXCe4-Free-Strategy-08-Combo-of-01-and-02-ES-SPY/
- type: strategy
- pine_id: PUB;gSx942GdzMlC2wbMN78OwQTZFokPdPs8
- version: 1.0

## Description

This strategy was designed to be traded on daily data on the ES and SPY—the strategy was originally developed for NinjaTrader, which displays daily ES data based on RTH hours instead of 24 hours (1440 minute) like TradingView does, so we are presenting the results on the SPY until we figure out how to overcome this hurdle.

The strategy combines the two ideas from [url=https://www.tradingview.com/script/f9hAzGNu-Free-Strategy-01-ES-SPY/]strategy #01[/url] and [url=https://www.tradingview.com/script/FljlnEsP-Free-Strategy-02-ES-SPY/]strategy #02[/url].  

Strategy #08
[list]
[*]Quantity 100
[*]Slippage: 2 ticks
[*]Commission: 4.95 per order
[*]Net Profit: 26,044.60
[*]Max Drawdown: 3,947.60
[/list]
Buy and Hold (Custom)
[list]
[*]Quantity 100
[*]Slippage: 2 ticks
[*]Commission: 4.95 per order
[*]Entry Long: 1993-02-01 @ 43.99
[*]Exit Long: 2017-07-28 @ 246.34
[*]Net Profit: 20,225.10
[*]Max Drawdown: 9,042.00
[/list]

## Source Code

````pine
//@version=3
strategy("Free Strategy #08 (Combo of #01 and #02) (ES / SPY)", overlay=true)

// Inputs
Quantity = input(1, minval=1, title="Quantity")
SmaPeriod01 = input(3, minval=1, title="SMA Period 01")
SmaPeriod02 = input(8, minval=1, title="SMA Period 02")
SmaPeriod03 = input(10, minval=1, title="SMA Period 03")
EmaPeriod01 = input(5, minval=1, title="EMA Period 01")
EmaPeriod02 = input(3, minval=1, title="EMA Period 02")
MaxProfitCloses = input(5, minval=1, title="Max Profit Close")
MaxBars = input(10, minval=1, title="Max Total Bars")

// Misc Variables
src = close
BarsSinceEntry = 0
MaxProfitCount = 0
Sma01 = sma(close, SmaPeriod01)
Sma02 = sma(close, SmaPeriod02)
Sma03 = sma(close, SmaPeriod03)
Ema01 = ema(close, EmaPeriod01)
Ema02 = ema(close, EmaPeriod02)
OHLC = (open + high + low + close) / 4.0

// Conditions
Cond00 = strategy.position_size == 0
Cond01 = close < Sma03
Cond02 = close <= Sma01
Cond03 = close[1] > Sma01[1]
Cond04 = open > Ema01
Cond05 = Sma02 < Sma02[1]
Entry01 = Cond00 and Cond01 and Cond02 and Cond03 and Cond04 and Cond05

Cond06 = close < Ema02
Cond07 = open > OHLC
Cond08 = volume <= volume[1]
Cond09 = (close < min(open[1], close[1]) or close > max(open[1], close[1]))
Entry02 = Cond00 and Cond06 and Cond07 and Cond08 and Cond09

// Update Exit Variables
BarsSinceEntry := Cond00 ? 0 : nz(BarsSinceEntry[1]) + 1
MaxProfitCount := Cond00 ? 0 : (close > strategy.position_avg_price and BarsSinceEntry > 1) ? nz(MaxProfitCount[1]) + 1 : nz(MaxProfitCount[1])

// Entries
strategy.entry(id="L1", long=true, qty=Quantity, when=(Entry01 or Entry02))
 
// Exits
strategy.close("L1", (BarsSinceEntry - 1 >= MaxBars or MaxProfitCount >= MaxProfitCloses))
````
