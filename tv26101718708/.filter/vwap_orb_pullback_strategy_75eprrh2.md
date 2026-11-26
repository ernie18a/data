# VWAP ORB Pullback Strategy

- url: https://www.tradingview.com/script/75epRRh2-VWAP-ORB-Pullback-Strategy/
- type: strategy
- pine_id: PUB;763d941693444257a2ef20045f82fb7b
- version: 1.0

## Description

This strategy is an Opening Range Breakout pullback system that uses the first X minutes after the market open to define the opening range, then looks for breakout entries that pull back to VWAP for confirmation. It is designed to trade in the direction of momentum after the opening range is established, with ATR-based stop loss and profit target levels.

How it works
It records the opening range high and low during the first part of the session after the U.S. market opens at 9:30 AM New York time.

After the opening range period ends, it waits for price to break above the opening range high for longs or break below the opening range low for shorts.

For a long trade, price must also be above VWAP and the 9 EMA, and the candle must pull back to VWAP before entry.

For a short trade, price must be below VWAP and the 9 EMA, and the candle must retest VWAP from below before entry.

Risk management uses ATR(14) to set the stop loss and take profit automatically.

How to use it
Add the strategy to a chart on TradingView.
Use it on intraday timeframes such as 1-minute, 5-minute, or 15-minute charts.
Focus on liquid, trend-sensitive markets like large-cap stocks, futures, or ETFs.
Watch for the opening range to form after the market open.
After the opening range ends, the strategy will only trigger when breakout and pullback conditions align.

Settings explained
Opening Range Minutes
This controls how long the opening range lasts after the market opens.
Lower values, like 5 or 15, create a tighter opening range.
Higher values create a wider range and fewer signals.

Risk/Reward Ratio
This sets the profit target as a multiple of ATR.
A value of 1.5 means the target is 1.5 times ATR away from entry.
Higher values aim for bigger winners but may reduce win rate.

Use VWAP Filter
This toggles the VWAP condition on or off.
Enabled: trades require price confirmation around VWAP.
Disabled: the strategy still uses the opening range breakout logic, but removes VWAP as an extra filter.

Trading behavior
This strategy is meant to catch early-session momentum while avoiding low-quality breakout entries. The VWAP and EMA filters help confirm trend direction, while the pullback requirement is intended to improve entry quality instead of chasing extended moves. The ATR stop and target make the strategy adaptive to volatility.

Suggested description for TradingView
VWAP ORB Pullback Strategy combines the opening range breakout with VWAP and EMA pullback confirmation. It defines the opening range during the first user-defined minutes after the market open, then looks for price to break that range and retest VWAP before entering. Long trades require price above VWAP and the 9 EMA, while short trades require price below both. Exits are managed with ATR-based stop loss and take profit levels using the selected risk/reward ratio.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TraderTed420

//@version=5
strategy("VWAP ORB Pullback Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === INPUTS ===
or_minutes = input.int(15, "Opening Range Minutes")
risk_reward = input.float(1.5, "Risk/Reward Ratio", step=0.1)
use_vwap = input.bool(true, "Use VWAP Filter")

// === TIME FILTER ===
start_time = timestamp("America/New_York", year, month, dayofmonth, 9, 30)
or_end_time = start_time + (or_minutes * 60 * 1000)

// === OPENING RANGE ===
var float or_high = na
var float or_low = na

if (time >= start_time and time <= or_end_time)
    or_high := na(or_high) ? high : math.max(or_high, high)
    or_low := na(or_low) ? low : math.min(or_low, low)

// Reset daily
if (ta.change(time("D")))
    or_high := na
    or_low := na

plot(or_high, color=color.green, title="OR High")
plot(or_low, color=color.red, title="OR Low")

// === VWAP ===
vwap = ta.vwap(close)
plot(vwap, color=color.orange, title="VWAP")

// === EMA (for pullback confirmation) ===
ema9 = ta.ema(close, 9)

// === CONDITIONS ===

// Long Conditions
breakout_long = close > or_high
pullback_long = close > vwap and close > ema9 and low <= vwap

long_condition = breakout_long and pullback_long and time > or_end_time

// Short Conditions
breakout_short = close < or_low
pullback_short = close < vwap and close < ema9 and high >= vwap

short_condition = breakout_short and pullback_short and time > or_end_time

// === RISK MANAGEMENT ===
atr = ta.atr(14)

// Stop/Target
long_stop = close - atr
long_target = close + (atr * risk_reward)

short_stop = close + atr
short_target = close - (atr * risk_reward)

// === EXECUTION ===
if (long_condition)
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", from_entry="Long", stop=long_stop, limit=long_target)

if (short_condition)
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", from_entry="Short", stop=short_stop, limit=short_target)
````
