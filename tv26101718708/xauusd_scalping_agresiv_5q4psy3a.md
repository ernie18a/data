# XAUUSD Scalping AGRESIV

- url: https://www.tradingview.com/script/5q4PsY3a-XAUUSD-Scalping-AGRESIV/
- type: strategy
- pine_id: PUB;c7e6c214534e4e8eab5d87bb64011b75
- version: 1.0

## Description

XAUUSD Scalping Strategy V2 – Aggressive

This strategy is designed for high-frequency scalping on XAUUSD (Gold), focusing on capturing short intraday price movements with multiple entries per session. It is optimized for lower timeframes such as 1-minute (M1) and 3-minute (M3), where volatility and execution speed are key.

The core of the strategy is based on fast trend detection and momentum confirmation. It uses two exponential moving averages (EMA 5 and EMA 13) to identify rapid trend shifts, combined with a short-period RSI (7) to confirm directional strength. This allows the strategy to react quickly to market changes and generate frequent trading signals.

To adapt to the dynamic nature of gold, all risk management levels are calculated using the Average True Range (ATR). Take Profit and Stop Loss levels are automatically set as multiples of ATR, ensuring they adjust to current market volatility. In addition, a trailing stop mechanism is included to lock in profits during strong moves while still allowing trades to run.

A built-in volatility filter prevents trades during low-activity periods by requiring a minimum ATR threshold. This helps reduce false signals and avoids trading in ranging or inactive market conditions.

Key Features:

High-frequency scalping with multiple trades per day
Fast EMA crossover system (5 & 13)
RSI momentum confirmation (7 period)
ATR-based dynamic Take Profit and Stop Loss
Trailing stop for profit protection
Volatility filter to avoid low-movement markets

Recommended Usage:

Asset: XAUUSD (Gold)
Timeframes: M1 or M3
Best sessions: London and New York
Requires low spread and fast execution for optimal performance

Important Notice:
This is an aggressive strategy that can generate a large number of trades and may experience significant drawdowns. Proper risk management, broker conditions (spread/commission), and thorough backtesting are essential before using it in live trading.

This script is intended for educational and research purposes only and should not be considered financial advice.

## Source Code

````pine
//@version=5
strategy("XAUUSD Scalping V2 AGRESIV", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === INPUTURI ===
emaFastLen = input.int(5, "EMA Rapid")
emaSlowLen = input.int(13, "EMA Lent")
rsiLen = input.int(7, "RSI Rapid")
atrLen = input.int(14, "ATR Length")

tpATR = input.float(1.2, "Take Profit (ATR multiplu)")
slATR = input.float(0.8, "Stop Loss (ATR multiplu)")
trailATR = input.float(0.5, "Trailing Stop (ATR multiplu)")

minVolatility = input.float(0.5, "Filtru volatilitate (ATR minim)")

// === CALCULE ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

// === FILTRU VOLATILITATE ===
volatilityOK = atr > minVolatility

// === CONDITII BUY ===
longCondition = ta.crossover(emaFast, emaSlow) and rsi > 55 and volatilityOK

// === CONDITII SELL ===
shortCondition = ta.crossunder(emaFast, emaSlow) and rsi < 45 and volatilityOK

// === BUY ===
if (longCondition)
    entryPrice = close
    takeProfit = entryPrice + atr * tpATR
    stopLoss = entryPrice - atr * slATR
    
    strategy.entry("BUY", strategy.long)
    strategy.exit("TP/SL BUY", from_entry="BUY", limit=takeProfit, stop=stopLoss, trail_points=atr * trailATR / syminfo.mintick)

// === SELL ===
if (shortCondition)
    entryPrice = close
    takeProfit = entryPrice - atr * tpATR
    stopLoss = entryPrice + atr * slATR
    
    strategy.entry("SELL", strategy.short)
    strategy.exit("TP/SL SELL", from_entry="SELL", limit=takeProfit, stop=stopLoss, trail_points=atr * trailATR / syminfo.mintick)

// === AFISARE ===
plot(emaFast, color=color.green)
plot(emaSlow, color=color.red)

plotshape(longCondition, location=location.belowbar, color=color.lime, style=shape.labelup, text="BUY")
plotshape(shortCondition, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")
````
