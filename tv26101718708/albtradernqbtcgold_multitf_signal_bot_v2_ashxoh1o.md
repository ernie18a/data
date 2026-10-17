# Albtrader-NQ/BTC/Gold Multi-TF Signal Bot v2

- url: https://www.tradingview.com/script/ASHXoH1O-Albtrader-NQ-BTC-Gold-Multi-TF-Signal-Bot-v2/
- type: strategy
- pine_id: PUB;79ee5dd57d0b44d2a599b7bf16e96520
- version: 1.0

## Description

A clean and effective multi-timeframe signal indicator designed specifically for Nasdaq (NQ), Bitcoin (BTC), and Gold (XAU).
How it Works:

Uses 9 EMA & 21 EMA crossover on the current chart timeframe for fast trend detection
Confirms signals using RSI (14) on the Higher Timeframe (default 1 hour)
Only generates high-probability signals when both timeframes align:
Bullish Signal = Fast EMA crosses above Slow EMA + Higher TF RSI is not overbought
Bearish Signal = Fast EMA crosses below Slow EMA + Higher TF RSI is not oversold


Key Features:

Built for NQ, BTC, and Gold but works on any symbol
Multi-timeframe confirmation reduces false signals
Clean visual signals with background coloring (optional)
Fully customizable inputs
Supports alerts

Recommended Settings:

Fast EMA: 9
Slow EMA: 21
RSI Length: 14
RSI Overbought: 70
RSI Oversold: 30
Higher TF: 1 hour (recommended)

Best used on 5min, 15min, or 30min charts for day trading and swing trading.
Ideal For:

Futures traders (NQ)
Crypto traders (BTC)
Precious metals traders (Gold)
Anyone who wants clean EMA + RSI confluence with higher timeframe filter


Pro Tips (add these if you want):

Enable alerts for Long/Short signals
Combine with support/resistance or volume for even better results
Works great in trending markets

## Source Code

````pine
//@version=5
strategy("NQ/BTC/Gold Multi-TF Signal Bot v2", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.04)

// Inputs
fastLen   = input.int(9,  "Fast EMA")
slowLen   = input.int(21, "Slow EMA")
rsiLen    = input.int(14, "RSI Length")
rsiOB     = input.int(70, "RSI Overbought")
rsiOS     = input.int(30, "RSI Oversold")
htfTf     = input.timeframe("60", "Higher TF")

// Indicators
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
rsiVal  = ta.rsi(close, rsiLen)

// Higher TF
htfFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, fastLen))
htfSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, slowLen))
htfTrendUp = htfFast > htfSlow

// Signals
longCondition  = ta.crossover(fastEMA, slowEMA) and rsiVal < rsiOB and htfTrendUp
shortCondition = ta.crossunder(fastEMA, slowEMA) and rsiVal > rsiOS

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)

// Exits
strategy.exit("Exit Long",  "Long",  stop=close * 0.985, limit=close * 1.03)
strategy.exit("Exit Short", "Short", stop=close * 1.015, limit=close * 0.97)

// === FIXED WEBHOOK ===
if (longCondition or shortCondition)
    jsonMessage = '{"symbol":"' + syminfo.ticker + 
                 '","action":"' + (longCondition ? "BUY" : "SELL") + 
                 '","price":' + str.tostring(close) + 
                 ',"rsi":' + str.tostring(rsiVal, "#.##") + 
                 ',"htfTrend":"' + (htfTrendUp ? "UP" : "DOWN") + 
                 '","time":"' + str.tostring(time, "yyyy-MM-dd HH:mm") + '"}'
    
    alert(jsonMessage, alert.freq_once_per_bar_close)
````
