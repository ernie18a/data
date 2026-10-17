# Canuck Trading Trader Strategy

- url: https://www.tradingview.com/script/OKsWbKwY-Canuck-Trading-Trader-Strategy/
- type: strategy
- pine_id: PUB;0b63cbf3b924418fa2bdf438cf6d5cfc
- version: 3.0

## Description

Canuck Trading Trader Strategy

Overview

The Canuck Trading Trader Strategy is a high-performance, trend-following trading system designed for NASDAQ:TSLA on a 15-minute timeframe. Optimized for precision and profitability, this strategy leverages short-term price trends to capture consistent gains while maintaining robust risk management. Ideal for traders seeking an automated, data-driven approach to trading Tesla’s volatile market, it delivers strong returns with controlled drawdowns.

Key Features

Trend-Based Entries: Identifies short-term trends using a 2-candle lookback period and a minimum trend strength of 0.2%, ensuring responsive trade signals.
Risk Management: Includes a configurable 3.0% stop-loss to cap losses and a 2.0% take-profit to lock in gains, balancing risk and reward.
High Precision: Utilizes bar magnification for accurate backtesting, reflecting realistic trade execution with 1-tick slippage and 0.1 commission.
Clean Interface: No on-chart indicators, providing a distraction-free trading experience focused on performance.
Flexible Sizing: Allocates 10% of equity per trade with support for up to 2 simultaneous positions (pyramiding).
Performance Highlights
Backtested from March 1, 2024, to June 20, 2025, on NASDAQ:TSLA (15-minute timeframe) with $1,000,000 initial capital:

Net Profit: $2,279,888.08 (227.99%)
Win Rate: 52.94% (3,039 winning trades out of 5,741)
Profit Factor: 3.495
Max Drawdown: 2.20%
Average Winning Trade: $1,050.91 (0.55%)
Average Losing Trade: $338.20 (0.18%)
Sharpe Ratio: 2.468
Note: Past performance is not indicative of future results. Always validate with your own backtesting and forward testing.

Usage Instructions

Setup:
Apply the strategy to a NASDAQ:TSLA 15-minute chart.
Ensure your TradingView account supports bar magnification for accurate results.
Configuration:
Lookback Candles: Default is 2 (recommended).
Min Trend Strength: Set to 0.2% for optimal trade frequency.
Stop Loss: Default 3.0% to cap losses.
Take Profit: Default 2.0% to secure gains.
Order Size: 10% of equity per trade.
Pyramiding: Allows up to 2 orders.
Commission: Set to 0.1.
Slippage: Set to 1 tick.
Enable "Recalculate After Order is Filled" and "Recalculate on Every Tick" in backtest settings.
Backtesting:
Run backtests over March 1, 2024, to June 20, 2025, to verify performance.
Adjust stop-loss (e.g., 2.5%) or take-profit (e.g., 1–3%) to suit your risk tolerance.
Live Trading:
Use with a compatible broker or TradingView alerts for automated execution.
Monitor execution for slippage or latency, especially given the high trade frequency (5,741 trades).
Validate in a demo account before deploying with real capital.

Risk Disclosure

Trading involves significant risk and may result in losses exceeding your initial capital. The Canuck Trading Trader Strategy is provided for educational and informational purposes only. Users are responsible for their own trading decisions and should conduct thorough testing before using in live markets. The strategy’s high trade frequency requires reliable execution infrastructure to minimize slippage and latency.

## Source Code

````pine
// @version=6
strategy("Canuck Trading Trader Strategy", overlay=true, margin_long=100, margin_short=100, calc_on_every_tick=true, calc_on_order_fills=true, process_orders_on_close=false, use_bar_magnifier=true)

// User inputs
lookback = input.int(2, "Lookback Candles", minval=1, maxval=10)
min_trend_pct = input.float(0.5, "Min Trend Strength (%)", minval=0.0, maxval=5.0, step=0.1)
stop_loss_pct = input.float(3.0, "Stop Loss (%)", minval=0.0, maxval=10.0, step=0.1)
take_profit_pct = input.float(5.0, "Take Profit (%)", minval=0.0, maxval=10.0, step=0.1)
trade_type = input.string("Long and Short", "Trade Type", options=["Long Only", "Short Only", "Long and Short"])

// Position state variables
var float entry_price = na
var int candles_held = 0
var string position_type = "none"
var int trend_direction = 0
var bool traded_this_bar = false
var int cooldown = 0

// ATR-based dynamic trend strength
atr = ta.atr(14)
dynamic_trend_pct = atr / close * 100 * 0.5

// Trend detection function
trend_detected() =>
    uptrend = true
    downtrend = true
    trend_strength = math.abs((close - close[lookback]) / close[lookback] * 100)
    for i = 0 to lookback - 1
        if i == 0
            if close <= close[1]
                uptrend := false
            if close >= close[1]
                downtrend := false
        else
            if close[i] <= close[i + 1]
                uptrend := false
            if close[i] >= close[i + 1]
                downtrend := false
    if uptrend and trend_strength >= math.max(min_trend_pct, dynamic_trend_pct)
        1
    else if downtrend and trend_strength >= math.max(min_trend_pct, dynamic_trend_pct)
        -1
    else
        0

// Detect trend
current_trend = trend_detected()

// Signal variables
var bool buy_signal = false
var bool sell_signal = false
var bool exit_long = false
var bool exit_short = false

// Reset traded_this_bar and manage cooldown
if barstate.isconfirmed
    traded_this_bar := false
    if cooldown > 0
        cooldown := cooldown - 1

// Position logic
if current_trend != 0 and position_type == "none" and not traded_this_bar and cooldown == 0
    if current_trend == 1 and (trade_type == "Long Only" or trade_type == "Long and Short")
        buy_signal := true
        sell_signal := false
        position_type := "long"
        entry_price := close
        candles_held := 1
        trend_direction := 1
        strategy.entry("Long", strategy.long)
        strategy.exit("Long Exit", "Long", stop=entry_price * (1 - stop_loss_pct / 100), limit=entry_price * (1 + take_profit_pct / 100))
        traded_this_bar := true
    else if current_trend == -1 and (trade_type == "Short Only" or trade_type == "Long and Short")
        sell_signal := true
        buy_signal := false
        position_type := "short"
        entry_price := close
        candles_held := 1
        trend_direction := -1
        strategy.entry("Short", strategy.short)
        strategy.exit("Short Exit", "Short", stop=entry_price * (1 + stop_loss_pct / 100), limit=entry_price * (1 - take_profit_pct / 100))
        traded_this_bar := true
else if position_type == "long"
    if close > close[1]
        candles_held := candles_held + 1
    else if close < close[1]
        exit_long := true
        position_type := "none"
        candles_held := 0
        entry_price := na
        trend_direction := 0
        strategy.close("Long")
        traded_this_bar := true
        cooldown := 1
    else
        candles_held := candles_held + 1
else if position_type == "short"
    if close < close[1]
        candles_held := candles_held + 1
    else if close > close[1]
        exit_short := true
        position_type := "none"
        candles_held := 0
        entry_price := na
        trend_direction := 0
        strategy.close("Short")
        traded_this_bar := true
        cooldown := 1
    else
        candles_held := candles_held + 1
````
