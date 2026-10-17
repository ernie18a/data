# Simple Long Only Bot

- url: https://www.tradingview.com/script/7YZu94L1-Simple-Long-Only-Bot/
- type: strategy
- pine_id: PUB;b047220bf3e34d35b44301db3e41bdbf
- version: 1.0

## Description

Long-Only Automated Trading Bot (TradingView + Interactive Brokers)

This is a fully automated, long-only stock trading bot designed to execute systematic trend-following strategies without emotional decision-making.

Built using TradingView alerts and connected to Interactive Brokers via a Python webhook server, the bot automatically places trades based on predefined technical conditions.

📊 How It Works

The bot follows a simple, proven market strategy:

Trades only in uptrends
Enters positions when price confirms momentum above key moving averages
Exits when trend strength weakens
Avoids shorting entirely (long-only exposure)
⚙️ Core Strategy Logic
Uses 50 EMA for entry timing
Uses 200 EMA for trend confirmation
Buys only when the market is in a confirmed uptrend
Exits when price loses short-term trend support
🔔 Automation Flow
TradingView generates a signal
Signal is sent via webhook
Python server receives the signal
Interactive Brokers executes the trade automatically
💡 Key Features
Fully automated execution
No manual trading required
Trend-following logic designed for stability
Works on major ETFs like SPY and QQQ
Can be run in paper trading or live mode
⚠️ Risk Note

This system does not guarantee profits. It is a rule-based trading strategy designed to reduce emotional decision-making and follow long-term market trends.

## Source Code

````pine
//@version=5
strategy("Simple Long Only Bot", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// Indicators
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// Conditions
uptrend = close > ema200
buySignal = ta.crossover(close, ema50) and uptrend
sellSignal = ta.crossunder(close, ema50)

// Execute Trades
if (buySignal)
    strategy.entry("LONG", strategy.long)

if (sellSignal)
    strategy.close("LONG")

// Plot
plot(ema50, color=color.blue)
plot(ema200, color=color.red)
````
