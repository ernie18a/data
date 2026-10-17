# SuperTrade ST1 Strategy

- url: https://www.tradingview.com/script/AyY3vB17-SuperTrade-ST1-Strategy/
- type: strategy
- pine_id: PUB;8eedd8f3cdcc46dba0cc10743005a563
- version: 1.0

## Description

[b]Overview[/b]

The SuperTrade ST1 Strategy is a long-only trend-following strategy that combines a Supertrend indicator with a 200-period EMA filter to isolate high-probability bullish trade setups. It is designed to operate in trending markets, using volatility-based exits with a strict 1:4 Risk-to-Reward (R:R) ratio, meaning that each trade targets a profit 4× the size of its predefined risk.

This strategy is ideal for traders looking to align with medium- to long-term trends, while maintaining disciplined risk control and minimal trade frequency.

[b]How It Works[/b]

This strategy leverages three key components:

[b]Supertrend Indicator[/b]

[list=1]
[*]A trend-following indicator based on Average True Range (ATR).
[*]Identifies bullish/bearish trend direction by plotting a trailing stop line that moves with price volatility.
[/list]

[b]200-period Exponential Moving Average (EMA) Filter[/b]

[list]
[*]Trades are only taken when the price is above the EMA, ensuring participation only during confirmed uptrends.
[*]Helps filter out counter-trend entries during market pullbacks or ranges.
[/list]

[b]ATR-Based Stop Loss and Take Profit[/b]

[list]
[*]Each trade uses the ATR to calculate volatility-adjusted exit levels.
[*]Stop Loss: 1× ATR below entry.
[*]Take Profit: 4× ATR above entry (1:4 R:R).
[*]This asymmetry ensures that even with a lower win rate, the strategy can remain profitable.
[/list]

[b]Entry Conditions[/b]

A long trade is triggered when:

[list]
[*]Supertrend flips from bearish to bullish (trend reversal).
[*]Price closes above the Supertrend line.
[*]Price is above the 200 EMA (bullish market bias).
[/list]

[b]Exit Logic[/b]

Once a long position is entered:

[list]
[*]Stop loss is set 1 ATR below entry.
[*]Take profit is set 4 ATR above entry.
[*]The strategy automatically exits the position on either target.
[/list]

Backtest Settings

This strategy is configured for realistic backtesting, including:

[list]
[*]$10,000 account size
[*]2% equity risk per trade
[*]0.1% commission
[*]1 tick slippage
[/list]

These settings aim to simulate real-world conditions and avoid overly optimistic results.

[b]How to Use[/b]

[list]
[*]Apply the script to any timeframe, though higher timeframes (1H, 4H, Daily) often yield more reliable signals.
[*]Works best in clearly trending markets (especially in crypto, stocks, indices).
[*]Can be paired with alerts for live trading or analysis.
[/list]

[b]Important Notes[/b]

[list]
[*]This version is long-only by design. No short positions are executed.
[*]Ideal for swing traders or position traders seeking asymmetric returns.
[*]Users can modify the ATR period, Supertrend factor, or EMA filter length based on asset behavior.
[/list]

## Source Code

````pine
//@version=6
strategy("SuperTrade ST1 Strategy", overlay=true,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=2,         
     initial_capital=10000,       
     currency=currency.USD,
     commission_type=strategy.commission.percent,
     commission_value=0.1,        
     slippage=1)

// === INPUTS ===
atrPeriod   = input.int(10, "ATR Period", minval=1)
factor      = input.float(3.0, "Supertrend Factor", minval=0.01, step=0.01)
emaPeriod   = input.int(200, "EMA Filter Period", minval=1)

// === RISK:REWARD SETTINGS FOR LONG ===
atrSL      = 1.0
atrTP_Long = 4.0

// === CALCULATIONS ===
[supertrend, direction] = ta.supertrend(factor, atrPeriod)
atr = ta.atr(atrPeriod)
ema = ta.ema(close, emaPeriod)

// === ENTRY CONDITION (LONG ONLY) ===
longCondition = direction[1] > direction and close > supertrend and close > ema

// === LONG ENTRY ===
if (longCondition)
    strategy.entry("Long", strategy.long)

// === LONG EXIT ===
longStop   = close - atrSL * atr
longProfit = close + atrTP_Long * atr

if (strategy.position_size > 0)
    strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longProfit)

// === VISUALS ===
plotshape(longCondition, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plot(supertrend, title="Supertrend", color=direction < 0 ? color.red : color.green, style=plot.style_linebr)
plot(ema, title="EMA Filter", color=color.orange)
bgcolor(direction < 0 ? color.new(color.red, 90) : color.new(color.green, 90))
````
