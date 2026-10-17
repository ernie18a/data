# EMA 9/20 Yellow Signal with Price

- url: https://www.tradingview.com/script/wRwGJHMg-EMA-9-20-Yellow-Signal-with-Price/
- type: indicator
- pine_id: PUB;18f8ded69edf4c8fa277df23b2182981
- version: 1.0

## Description

Strategy Overview: EMA 9/20 Crossover with Dynamic Price Labels
Description
This indicator is designed for traders who utilize Exponential Moving Averages (EMA) to identify short-term momentum shifts and trend reversals. It specifically tracks the relationship between the 9-period EMA (fast) and the 20-period EMA (slow).

The script eliminates the need for manual price checking by automatically printing the exact execution price directly onto the chart the moment a crossover occurs.

Key Features
Automatic Trend Detection: Identifies "Golden Crosses" (Bullish) and "Death Crosses" (Bearish) instantly.

High-Visibility Labels: Uses bright yellow labels with black text for maximum readability against any chart theme (Dark or Light).

Dynamic Price Printing: Every signal includes the exact close price of the candle where the crossover was confirmed.

Clean UI: Labels are strategically placed above (for Sell) and below (for Buy) the candles to prevent overlapping with price action.

Best Practices for TradingView Users
Timeframes: While effective on all timeframes, it excels on the 5m, 15m, and 1H charts for capturing intraday swings.

Confirmation: Use this indicator in conjunction with volume or support/resistance levels to avoid "whipsaws" during sideways/flat markets.

Alerts: You can easily set alerts on this script by clicking the three dots on the indicator name in your legend and selecting "Add Alert."

Technical Details
Script Version: Pine Script v5

Indicator Type: Overlay (Plots directly on the price chart)

Calculation: Uses the ta.ema and ta.crossover built-in functions for precision and low-latency processing.

## Source Code

````pine
//@version=5
indicator("EMA 9/20 Yellow Signal with Price", overlay=true)

// 1. Calculate EMAs
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)

// 2. Plot EMAs
plot(ema9, title="EMA 9", color=color.blue, linewidth=2)
plot(ema20, title="EMA 20", color=color.orange, linewidth=2)

// 3. Crossover Logic
longCross  = ta.crossover(ema9, ema20)
shortCross = ta.crossunder(ema9, ema20)

// 4. Function to create labels (Fixes the 'series string' error)
if longCross
    label.new(bar_index, low, text="BUY\n" + str.tostring(close, "#.##"), 
         color=color.yellow, 
         textcolor=color.black, 
         style=label.style_label_up, 
         yloc=yloc.belowbar)

if shortCross
    label.new(bar_index, high, text="SELL\n" + str.tostring(close, "#.##"), 
         color=color.yellow, 
         textcolor=color.black, 
         style=label.style_label_down, 
         yloc=yloc.abovebar)

// 5. Price tag specifically at the bottom for both
if (longCross or shortCross)
    label.new(bar_index, low, text=str.tostring(close, "#.##"),
         color=color.yellow,
         textcolor=color.black,
         style=label.style_label_up,
         yloc=yloc.belowbar,
         size=size.small)
````
