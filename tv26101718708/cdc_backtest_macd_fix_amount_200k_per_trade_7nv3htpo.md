# CDC BACKTEST (MACD) FIX AMOUNT $200k per trade 

- url: https://www.tradingview.com/script/7nv3hTpO-CDC-BACKTEST-MACD-FIX-AMOUNT-200k-per-trade/
- type: strategy
- pine_id: PUB;47420601c9964b3cbb43935c428e2252
- version: 2.0

## Description

This strategy implements an Exponential Moving Average (EMA) Crossover System designed for backtesting and performance evaluation. EMA 12,26 (MACD)
The trading logic is based on the crossover between two EMAs — a short-term EMA (12) and a long-term EMA (26) — which serves as a momentum-based signal for trend identification.

Buy Condition:
A long (buy) position is entered when the 12-period EMA crosses above the 26-period EMA, indicating a potential upward trend or bullish momentum.

Sell Condition:
A position is closed, or a short (sell) position is opened, when the 12-period EMA crosses below the 26-period EMA, signaling a potential downward trend or bearish momentum.

Position Sizing:
Each trade with a fixed position size of 200,000 USD (default), while the starting account balance is set at 400,000 (USD).
Both the fixed trade amount and the initial balance are user-adjustable parameters, allowing flexibility for different risk preferences and portfolio sizes.

## Source Code

````pine
//@version=5
strategy(" CDC Backtest (MACD) Fix Amount ",
  overlay=true,
  initial_capital=400000,        // เงินเริ่มต้น 400,000 USD
  currency=currency.USD,
  default_qty_type=strategy.cash, // ใช้มูลค่าเงินต่อไม้
  default_qty_value=200000,       // ลงเงิน $200,000 ต่อไม้
  pyramiding=1,                   // เปิดได้สูงสุด 1 ไม้
  commission_type=strategy.commission.percent,
  commission_value=0.1)           // ค่าคอมมิชชั่น 0.1%

// === INPUTS ===
emaFastLength = input.int(12, "EMA Fast (12)")
emaSlowLength = input.int(26, "EMA Slow (26)")
startDate = input.time(timestamp("1970-01-01"), "Start Date")  // ค่า default = 1970-01-01

// === INDICATORS ===
emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)

// === SIGNALS ===
buySignal  = ta.crossover(emaFast, emaSlow)
sellSignal = ta.crossunder(emaFast, emaSlow)

// === BACKTEST DATE FILTER ===
inTradePeriod = time >= startDate

// === STRATEGY LOGIC ===
if (inTradePeriod)
    if (buySignal and strategy.position_size == 0)
        strategy.entry("Long", strategy.long)
    if (sellSignal and strategy.position_size > 0)
        strategy.close("Long")

// === PLOTS ===
plot(emaFast, title="EMA 12", color=color.new(color.green, 0))
plot(emaSlow, title="EMA 26", color=color.new(color.red, 0))

plotshape(buySignal and inTradePeriod, title="Buy", location=location.belowbar, style=shape.triangleup, color=color.new(color.green, 0), size=size.small)
plotshape(sellSignal and inTradePeriod, title="Sell", location=location.abovebar, style=shape.triangledown, color=color.new(color.red, 0), size=size.small)
````
