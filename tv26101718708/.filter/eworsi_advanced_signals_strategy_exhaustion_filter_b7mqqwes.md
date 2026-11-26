# EWO,RSI advanced Signals Strategy - Exhaustion Filter

- url: https://www.tradingview.com/script/B7MQqWes-EWO-RSI-advanced-Signals-Strategy-Exhaustion-Filter/
- type: strategy
- pine_id: PUB;0fed071b69f742cab6345d74feae8b3b
- version: 4.0

## Description

## EWO, RSI, MFI  - Advanced Exhaustion Filter
## Overview
 Strategy - Advanced Exhaustion Filter is a comprehensive momentum and mean-reversion trading strategy designed for Pine Script v6. It combines multi-indicator momentum tracking with structural price filters to protect traders from "falling knives" during market capitulation and distribution phases.

By blending the Elliott Wave Oscillator (EWO), Relative Strength Index (RSI), Money Flow Index (MFI), and volume-weighted confirmations, this strategy ensures you only enter a trade when genuine momentum returns to the market.
------------------------------
## How It Works## 
1. Core Momentum Engine

The strategy relies on three distinct layers of confirmation before generating a trade:

* Elliott Wave Oscillator (EWO): Measures the displacement of price to determine the dominant market wave. Entries require the EWO to be ticking upward from below zero.
* Relative Strength Index (RSI): Filters structural momentum. A long entry triggers when RSI crosses above the critical 40 line, proving a shift out of bearish territory.
* Money Flow Index (MFI): Adds volume-weighted momentum to ensure asset accumulation is actually taking place rather than a low-liquidity squeeze.

 2. The Exhaustion & Structural Filter (Anti-Falling Knife)
Standard momentum strategies often fail during deep market sell-offs because indicators flash "buy" on minor relief bounces while price continues to plummet. This script solves that problem using two proprietary rules:

* The Breakout/Breakdown Barrier: The script dynamically tracks the highest high and lowest low of the last N bars (lookback_len). Even if indicators say buy, the strategy will wait until price physically breaks above this local structural barrier.

* Capitulation Memory Flag: If the market enters a state of extreme panic (RSI drops below rsi_oversold), the strategy flags an "Exhaustion Zone". In this zone, the strategy prepares for an explosive trend reset, overriding standard barriers once momentum reverses.

3. Volumetric Confirmation
Signals are filtered through a volume moving average (Volume MA). Entries and exits are only permitted if market volume is at least 80% of its recent average, keeping you out of choppy, illiquid trading sessions.
------------------------------
## Strategy Parameters

* EWO Fast / Slow (Default: 5, 34): The short and long-term moving averages used to calculate the Elliott Wave Oscillator waves.
* RSI Length (Default: 14): The lookback window for trend and exhaustion momentum.
* MFI Length (Default: 14): The lookback window for volume-weighted money flow tracking.
* Breakout Lookback Bars (Default: 10): The number of historical bars used to calculate local structural highs and lows to prevent premature entries.
* Exhaustion RSI Level (Default: 30): The extreme oversold threshold that triggers capitulation logic.

------------------------------
## Best Practices & Asset Classes

* Timeframes: Optimised for 15-minute, 1-hour, and 4-hour charts where structural highs and lows carry significant weight.
* Markets: Highly effective on trending assets with periodic high-volatility liquidations, such as Crypto (BTC, ETH), major Forex pairs, and Tech Stocks.

------------------------------
## ⚠️ Disclaimer
Financial Risk Warning: Financial trading involves substantial risk of loss and is not suitable for every investor. The information, strategies, and script provided here are strictly for educational, informational, and research purposes.

No Advice: This script is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past performance as demonstrated by historical backtesting is never a guarantee of future results.

User Responsibility: Markets change rapidly, and default settings may not fit all assets or market conditions. You are fully responsible for your own trading decisions. Always thoroughly backtest, forward-test on a demo account, and apply your own strict risk management protocols before risking real capital.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pridarasx

//@version=6
//Version 9.4-UI and snapshot chart update(2026-06-24)
strategy("EWO,RSI advanced Signals Strategy - Exhaustion Filter[Pridarasx]", overlay=true, initial_capital=10000, currency=currency.USD)

// --- Inputs ---
ewo_fast   = input.int(5, title="EWO Fast")
ewo_slow   = input.int(34, title="EWO Slow")
rsi_len    = input.int(14, title="RSI Length")
mfi_len    = input.int(14, title="MFI Length")
vol_ma_len = input.int(20, title="Volume MA Length")

// --- Exhaustion & Filter Inputs ---
lookback_len = input.int(10, title="Breakout Lookback Bars", tooltip="Requires price to break the highest high of this many bars before buying to avoid falling knives.")
rsi_oversold = input.int(30, title="Exhaustion RSI Level", tooltip="The deep oversold level that triggers a potential trend reset zone.")

// --- Alert Inputs ---
alert_pre_buy  = input.bool(true, title="Alert: Pre-Buy Signal", group="Alert Settings")
alert_buy      = input.bool(true, title="Alert: BUY NOW Signal", group="Alert Settings")
alert_pre_sell = input.bool(true, title="Alert: Pre-Sell Signal", group="Alert Settings")
alert_sell     = input.bool(true, title="Alert: SELL NOW Signal", group="Alert Settings")
alert_entry    = input.bool(true, title="Alert: Strategy Entry", group="Alert Settings")
alert_exit     = input.bool(true, title="Alert: Strategy Exit", group="Alert Settings")

// --- Calculations ---
// 1. EWO (Elliott Wave Oscillator)
ewo = ta.sma(hl2, ewo_fast) - ta.sma(hl2, ewo_slow)

// 2. RSI
rsi = ta.rsi(close, rsi_len)

// 3. MFI
mfi = ta.mfi(hlc3, mfi_len)

// 4. Volume Confirmation
vol_ma = ta.sma(volume, vol_ma_len)
vol_ok = volume > vol_ma * 0.8

// --- Advanced Exhaustion Filter Logic ---
// Track if the market recently entered a deep oversold capitulation state
var bool oversold_zone = false
if rsi < rsi_oversold
    oversold_zone := true

// Dynamically track the highest high of the last N bars to act as a structural confirmation barrier
breakout_barrier = ta.highest(high, lookback_len)[1]
price_breaking_out = close > breakout_barrier

// --- Signal Logic ---

// PRE-BUY: RSI is low and EWO starts turning up
pre_buy = rsi < 40 and ewo > ewo[1] and ewo < 0

// BUY: Core logic + price must break the local lookback high to confirm momentum isn't a fake bounce
raw_buy = ta.crossover(rsi, 40) and mfi > 30 and ewo > ewo[1] and vol_ok and (price_breaking_out or oversold_zone)

// PRE-SELL: RSI is high and EWO starts turning down
pre_sell = rsi > 60 and ewo < ewo[1] and ewo > 0

// SELL: Core logic
raw_sell = ta.crossunder(rsi, 60) and mfi < 70 and ewo < ewo[1] and vol_ok

// --- Reset Zone states upon entry ---
if raw_buy
    oversold_zone := false

// --- Signal Frequency Control (One primary signal per leg) ---
var int last_signal = 0 // 1 = Buy, -1 = Sell

buy_signal  = false
sell_signal = false

if raw_buy and last_signal != 1
    buy_signal := true
    last_signal := 1

if raw_sell and last_signal != -1
    sell_signal := true
    last_signal := -1

// --- Strategy Execution with Alert Messages ---
if buy_signal
    strategy.entry("Long", strategy.long, alert_message="EWO/RSI Strategy: BUY NOW - Long Entry Triggered. Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | EWO: " + str.tostring(ewo, "#.###"))

if sell_signal
    strategy.entry("Short", strategy.short, alert_message="EWO/RSI Strategy: SELL NOW - Short Entry Triggered. Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | EWO: " + str.tostring(ewo, "#.###"))

// --- Alert Function Calls ---
// Pre-Buy Alert
if pre_buy and alert_pre_buy
    alert("EWO/RSI Strategy: PRE-BUY Signal Detected. Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | EWO turning up from negative.", alert.freq_once_per_bar_close)

// Buy Alert
if buy_signal and alert_buy
    alert("EWO/RSI Strategy: BUY NOW Signal Confirmed! Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | MFI: " + str.tostring(mfi, "#.#") + " | Volume OK: " + str.tostring(vol_ok), alert.freq_once_per_bar_close)

// Pre-Sell Alert
if pre_sell and alert_pre_sell
    alert("EWO/RSI Strategy: PRE-SELL Signal Detected. Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | EWO turning down from positive.", alert.freq_once_per_bar_close)

// Sell Alert
if sell_signal and alert_sell
    alert("EWO/RSI Strategy: SELL NOW Signal Confirmed! Price: " + str.tostring(close) + " | RSI: " + str.tostring(rsi, "#.#") + " | MFI: " + str.tostring(mfi, "#.#") + " | Volume OK: " + str.tostring(vol_ok), alert.freq_once_per_bar_close)

// Strategy Entry/Exit Alerts (for position changes)
if strategy.position_size > strategy.position_size[1] and alert_entry
    alert("EWO/RSI Strategy: POSITION ENTERED. Direction: " + (strategy.position_size > 0 ? "LONG" : "SHORT") + " | Size: " + str.tostring(math.abs(strategy.position_size)) + " | Price: " + str.tostring(close), alert.freq_once_per_bar_close)

if strategy.position_size < strategy.position_size[1] and strategy.position_size[1] != 0 and alert_exit
    alert("EWO/RSI Strategy: POSITION EXITED/REVERSED. Price: " + str.tostring(close) + " | P&L: " + str.tostring(strategy.closedtrades.profit(strategy.closedtrades - 1), "#.##"), alert.freq_once_per_bar_close)

// --- Visual Plots ---
// Plot the breakout barrier line dynamically so you can watch price clear it live
plot(price_breaking_out ? na : breakout_barrier, title="Breakout Barrier", color=color.purple, style=plot.style_linebr)

// Buy Signals (Bottom of Bar)
plotshape(pre_buy, title="Pre-Buy", style=shape.triangleup, location=location.belowbar, color=color.blue, size=size.small, text="Pre-Buy")
plotshape(buy_signal, title="BUY NOW", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal, text="BUY")

// Sell Signals (Top of Bar)
plotshape(pre_sell, title="Pre-Sell", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small, text="Pre-Sell")
plotshape(sell_signal, title="SELL NOW", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal, text="SELL")
````
