# High Activity Penny Stock Strategy V6

- url: https://www.tradingview.com/script/NfihxKxr-High-Activity-Penny-Stock-Strategy-V6/
- type: strategy
- pine_id: PUB;6bce814fe5964533baa88dbde4b199b2
- version: 1.0

## Description

High Activity Penny Stock Strategy V6

Overview

High Activity Penny Stock Strategy V6 is a momentum-based strategy designed for traders looking for increased trade frequency in volatile markets.

The system combines Supertrend direction changes, volume expansion, trend filtering, and built-in risk management to capture momentum moves while avoiding weaker setups.

Key Features

✅ Supertrend Momentum Engine

- Uses ATR-based Supertrend signals to detect trend reversals.
- Adjustable sensitivity and aggression settings allow tuning for different stocks and timeframes.

✅ High Activity Volume Filter

- Confirms entries only when volume is above average.
- Helps identify stronger participation and avoid low-liquidity moves.

✅ Trend Direction Filter

- Uses a 50 SMA trend filter.
- Long trades favor bullish conditions.
- Short trades favor bearish conditions.

✅ Built-in Risk Management

- Automatic Take Profit and Stop Loss.
- Adjustable percentage targets.
- Optional trend-flip exits to protect gains.

✅ Designed for Active Markets
Best suited for:

- Penny stocks
- Small-cap stocks
- High volatility instruments
- Momentum trading environments

Buy Conditions

A BUY signal occurs when:

- Supertrend flips bullish
- Volume confirms increased activity
- Price is above the trend filter (if enabled)

Sell Conditions

A SELL signal occurs when:

- Supertrend flips bearish
- Volume confirms activity
- Price is below the trend filter (if enabled)

Suggested Usage

- Test on liquid penny stocks with strong volume.
- Adjust ATR sensitivity depending on volatility.
- Always review backtest results before live trading.

Risk Disclaimer

This strategy is provided for educational and research purposes only. Penny stocks can have high volatility and liquidity risks. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
strategy("High Activity Penny Stock Strategy V6", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1)

// --- Settings ---
// Core Strategy Settings (Tuned for more trades)
int stAtrPeriod      = input.int(10, "Sensitivity (ATR Period)", minval=1, group="Core Settings")
float stMultiplier   = input.float(2.0, "Aggression (Multiplier)", minval=0.1, group="Core Settings")

// Volume Filter (Loosened to 1.2x to allow more trades)
float volThreshold   = input.float(1.2, "Volume Multiplier", minval=0.1, group="Filters")
bool useVolFilter    = input.bool(true, "Enable Volume Filter", group="Filters")

// Trend Filter (Using 50 SMA instead of 200 for more activity)
int smaLength        = input.int(50, "Trend Filter (SMA)", minval=1, group="Filters")
bool useSmaFilter    = input.bool(true, "Enable Trend Filter", group="Filters")

// Risk Management
float tpPercent      = input.float(10.0, "Take Profit (%)", group="Risk")
float slPercent      = input.float(5.0, "Stop Loss (%)", group="Risk")
bool exitOnFlip      = input.bool(true, "Exit on Trend Flip", group="Risk")

// --- Calculations ---
[stValue, stDirection] = ta.supertrend(stMultiplier, stAtrPeriod)
float avgVolume = ta.sma(volume, 20)
float smaValue = ta.sma(close, smaLength)

// Conditions
bool volOK = not useVolFilter or (volume > (avgVolume * volThreshold))
bool trendOK_Buy = not useSmaFilter or (close > smaValue)
bool trendOK_Sell = not useSmaFilter or (close < smaValue)

// --- Signal Logic ---
bool buySignal  = (stDirection < 0) and (stDirection[1] >= 0) and volOK and trendOK_Buy
bool sellSignal = (stDirection > 0) and (stDirection[1] <= 0) and volOK and trendOK_Sell

// --- Strategy Execution ---
// Entry
if buySignal
    strategy.entry("Long", strategy.long, comment="BUY")

if sellSignal
    strategy.entry("Short", strategy.short, comment="SELL")

// Exit Logic
// 1. Exit on Take Profit or Stop Loss
strategy.exit("Exit Long", "Long", limit=strategy.position_avg_price * (1 + tpPercent/100), stop=strategy.position_avg_price * (1 - slPercent/100), comment="TP/SL")
strategy.exit("Exit Short", "Short", limit=strategy.position_avg_price * (1 - tpPercent/100), stop=strategy.position_avg_price * (1 + slPercent/100), comment="TP/SL")

// 2. Exit on Trend Flip (Optional but recommended for Penny Stocks)
if exitOnFlip
    if strategy.position_size > 0 and stDirection > 0
        strategy.close("Long", comment="Flip Exit")
    if strategy.position_size < 0 and stDirection < 0
        strategy.close("Short", comment="Flip Exit")

// --- Visuals ---
plot(useSmaFilter ? smaValue : na, color=color.new(color.blue, 50), title="Trend Filter")
plotshape(buySignal, title="Buy", text="BUY", location=location.belowbar, color=color.green, style=shape.labelup, textcolor=color.white, size=size.small)
plotshape(sellSignal, title="Sell", text="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, textcolor=color.white, size=size.small)
````
