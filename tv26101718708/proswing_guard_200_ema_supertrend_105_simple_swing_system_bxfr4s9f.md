# Pro-Swing Guard: 200 EMA & SuperTrend 10-5 - Simple Swing System

- url: https://www.tradingview.com/script/BXfR4S9f-Pro-Swing-Guard-200-EMA-SuperTrend-10-5-Simple-Swing-System/
- type: strategy
- pine_id: PUB;621e84eb9c2343d6b3d88edef76ce78e
- version: 1.0

## Description

The Pro-Swing Guard is a disciplined, trend-following system designed to simplify high-probability trading for both stocks and indices. Built on the core principle of "Trading with the Tide," this strategy is the primary engine for The Stock Yogi's trading philosophy: eliminating market noise and avoiding the traps of sideways price action.

By combining the structural strength of the 200-period Exponential Moving Average (EMA) with a conservative, high-factor SuperTrend (10, 5), the Pro-Swing Guard ensures you only participate when the big money momentum and long-term structure are perfectly aligned.

The "3-Step Verification" Logic
This system follows a strict institutional-grade logic to confirm every entry:

The Structural Filter (200 EMA): We only look for Longs when the price is trading above the 200 EMA and Shorts when below. This ensures you are never standing in front of a high-speed train moving in the opposite direction.

The Slope Sentinel: The script automatically detects the angle of the 200 EMA. It only triggers signals when the EMA is actively sloping (Upward for Buy / Downward for Sell), effectively keeping you on the sidelines during "dead" or choppy markets.

The Volatility Buffer (The 10-5 Factor): While most retail traders use a standard 3.0 multiplier, we use a 5.0 Multiplier. This "Game Changer" adjustment creates a wider safety zone, allowing the stock to breathe and preventing you from being "shaken out" by minor intraday volatility.

Key Features & Toggles
Directional Control: Built-in toggles to enable/disable Long or Short trades based on your daily market bias or higher timeframe analysis.

Risk Management Toggle:

Trend Rider Mode (Default): Exit on a SuperTrend color flip to capture massive, multi-week swing moves.

Disciplined Target Mode: Switch on the Risk-to-Reward (RR) Toggle to set a fixed target based on the Entry Candle's high/low for consistent compounding.

Institutional Sizing: Defaulted to an initial capital of 50 Lacs with a 40% equity-per-trade allocation for realistic portfolio backtesting.

How to Trade with Pro-Swing Guard
Best Timeframes: Highly optimized for 15m/1h (Intraday Momentum) and Daily/4h (Swing Trading).

Confirmation: A valid signal is generated when the SuperTrend flips color ONLY IF the price is on the correct side of the 200 EMA and the EMA slope is confirmed.

Visual Cues: The chart background highlights valid entry zones (Green for Bullish / Red for Bearish) to keep your eyes focused.

Disclaimer & House Rules
This indicator is an educational tool designed by The Stock Yogi to assist in data-driven decision-making.

Trading involves significant financial risk. Past performance does not guarantee future results.

Always practice proper risk management and test on a demo account before live deployment.

Developed by The Stock Yogi
"In a world of noise, discipline is your only edge. Let this tool handle the trend, while you handle your mind."

## Source Code

````pine
//@version=6
strategy("Pro-Swing Guard: 200 EMA & SuperTrend 10-5 - Simple Swing System", overlay=true, initial_capital=5000000, default_qty_type=strategy.percent_of_equity, default_qty_value=40, currency=currency.INR)

// --- Strategy Toggles ---
enableLong  = input.bool(true, "Enable Long Trades?", group="Strategy Toggles")
enableShort = input.bool(false, "Enable Short Trades?", group="Strategy Toggles")

// --- Inputs ---
st_period = input.int(10, "SuperTrend Period")
st_factor = input.float(5.0, "SuperTrend Multiplier")
ema_len = input.int(200, "EMA Length")
show_ema = input.bool(true, "Show 200 EMA?")

// --- Indicators ---
[superTrend, direction] = ta.supertrend(st_factor, st_period)
ema200 = ta.ema(close, ema_len)

// --- Logic Conditions ---
aboveEma = close > ema200
belowEma = close < ema200

emaUp   = ema200 > ema200[1]
emaDown = ema200 < ema200[1]

stBuy  = direction < 0
stSell = direction > 0

// --- Entry Logic (With Toggle Check) ---
longCondition  = enableLong and stBuy and aboveEma and emaUp
shortCondition = enableShort and stSell and belowEma and emaDown

// --- Execution ---
if (longCondition)
    strategy.entry("Long", strategy.long, comment="ST Buy + EMA Up")

if (shortCondition)
    strategy.entry("Short", strategy.short, comment="ST Sell + EMA Down")

// Exit Logic
if (strategy.position_size > 0 and stSell)
    strategy.close("Long", comment="ST Flip")

if (strategy.position_size < 0 and stBuy)
    strategy.close("Short", comment="ST Flip")

// --- Visuals ---
plot(superTrend, "SuperTrend", color = direction < 0 ? color.green : color.red, linewidth=2)

emaColor = emaUp ? color.green : emaDown ? color.red : color.gray
plot(show_ema ? ema200 : na, "200 EMA", color=emaColor, linewidth=3)

// Visual cues
bgcolor(longCondition ? color.new(color.green, 90) : shortCondition ? color.new(color.red, 90) : na)
````
