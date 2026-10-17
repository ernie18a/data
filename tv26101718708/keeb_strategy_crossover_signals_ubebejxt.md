# KEEB Strategy - Crossover Signals

- url: https://www.tradingview.com/script/uBeBeJxT-KEEB-Strategy-Crossover-Signals/
- type: indicator
- pine_id: PUB;0ea09fbd200e49a28d4db5e9dedb6d28
- version: 1.0

## Description

KEEB Strategy - EMA 20 & MA 200 Crossover Indicator
Overview
The KEEB Strategy is a momentum and trend-following trading system designed to capture high-probability continuation moves and trend reversals. It uses institutional moving averages to filter out market noise and trigger highly precise entry signals, making it exceptionally effective for fast-paced charts like the 1-minute, 5-minute, or 15-minute timeframes.
How It Works
The strategy relies on a primary directional filter and a strict mechanical trigger:
The Institutional Filter (MA 200): A 200-period Simple Moving Average (SMA) acts as the baseline for the macro trend.
The Execution Trigger (EMA 20): A 20-period Exponential Moving Average (EMA) tracks the immediate structural momentum.
The Visual Guide (EMA 9): A 9-period EMA is plotted to give the trader a clear view of short-term micro-momentum and potential trailing stop levels.
Entry Signals
The script automatically calculates crossovers and prints clean, actionable labels directly on your chart:
KEEB LONG (Buy Signal): Triggered the exact moment the EMA 20 crosses above the MA 200. This signals a powerful shift into a bullish regime.
KEEB SHORT (Sell Signal): Triggered the exact moment the EMA 20 crosses below the MA 200. This signals an aggressive breakdown into a bearish regime.
Key Features
Zero Lag Execution: Signals trigger precisely on the crossover candle, capturing the exact moment institutional volume pushes the market past the macro average.
Clean Visual Interface: Plots explicit green triangles (KEEB LONG) below the bars and red triangles (KEEB SHORT) above the bars.
Fully Automated Alerts: Includes pre-configured native TradingView alert conditions (alertcondition) so you can receive instant push notifications or webhooks on your phone or PC the second a crossover occurs.

## Source Code

````pine
//@version=5
indicator("KEEB Strategy - Crossover Signals", overlay=true)

// 1. Moving Averages Configuration
ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
sma200 = ta.sma(close, 200)

// Plot lines on the chart
plot(ema9, color=color.blue, title="EMA 9", linewidth=1)
plot(ema20, color=color.orange, title="EMA 20", linewidth=1)
plot(sma200, color=color.white, title="MA 200", linewidth=2)

// 2. KEEB Strategy Conditions
// Long Condition: Both EMA 9 and EMA 20 must be above MA 200, and at least one just crossed over
longCondition = (ema9 > sma200) and (ema20 > sma200) and (ta.crossover(ema9, sma200) or ta.crossover(ema20, sma200))

// Short Condition: Both EMA 9 and EMA 20 must be below MA 200, and at least one just crossed under
shortCondition = (ema9 < sma200) and (ema20 < sma200) and (ta.crossunder(ema9, sma200) or ta.crossunder(ema20, sma200))

// 3. Plot Signal Shapes on Chart
plotshape(series=longCondition, title="KEEB Long Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="KEEB LONG")
plotshape(series=shortCondition, title="KEEB Short Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="KEEB SHORT")

// 4. Alert Conditions for TradingView
alertcondition(longCondition, title="KEEB Long Alert", message="KEEB Strategy: Bullish Crossover on 1m Chart!")
alertcondition(shortCondition, title="KEEB Short Alert", message="KEEB Strategy: Bearish Crossover on 1m Chart!")
````
