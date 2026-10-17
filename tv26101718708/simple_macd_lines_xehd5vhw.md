# Simple MACD Lines

- url: https://www.tradingview.com/script/XEhD5vHw/
- type: indicator
- pine_id: PUB;b3c91c651c60403f9e554373a7e6ddf2
- version: 1.0

## Description

█ OVERVIEW

This indicator displays only the MACD line and signal line — no histogram.

It sounds simple, but it solves a specific problem: when you try to set a price alert directly on a standard MACD indicator in TradingView, the histogram can interfere and make it hard to place the alert exactly where you want it.

With this indicator, there is nothing but the two lines, so alerts snap cleanly to the line positions.

█ HOW IT WORKS

• Calculates MACD using standard settings (12, 26, 9) — same math as the built-in MACD
• Plots the MACD line in blue and the signal line in red
• Includes a zero line for reference
• No histogram — cleaner chart, easier alert placement

█ HOW TO SET ALERTS

• Hover your cursor over one of the lines on the chart
• A "+" icon will appear — click it to set an alert at that exact price level
• Works well for zero line crosses, signal line crosses, or any custom level you want to watch

█ SETTINGS

• Fast Length — default 12
• Slow Length — default 26
• Signal Length — default 9
• Source — default close

All settings can be adjusted from the indicator's input panel. Colors can be changed from the Style tab.

█ NOTES

• This is a niche tool — if you just want to view MACD visually, the built-in TradingView MACD works fine
• Best used by traders who rely heavily on TradingView's alert system and want precise line-based alert placement
• Can be added as a separate pane alongside your existing indicators without interfering with them

## Source Code

````pine
//@version=6
indicator("Simple MACD Lines", overlay=false)

fast_length = input(12, "Fast Length")
slow_length = input(26, "Slow Length")
signal_length = input(9, "Signal Length")
src = input.source(close, "Source")

[macd_line, signal_line, _] = ta.macd(src, fast_length, slow_length, signal_length)

plot(macd_line, color=color.blue, title="MACD", linewidth=2)
plot(signal_line, color=color.red, title="Signal", linewidth=2)

hline(0, color=color.gray, linestyle=hline.style_dotted)
````
