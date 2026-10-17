# ATR Divided by 4

- url: https://www.tradingview.com/script/aZ6jp5xH-ATR-Divided-by-4/
- type: indicator
- pine_id: PUB;f3bc3c344246498d9f92ae9d1ec58870
- version: 1.0

## Description

he Average True Range (ATR) is the gold standard for measuring market volatility. However, for active intraday traders, scalpers, or those looking to fine-tune their risk management, the standard ATR can often feel too wide.

Enter the Fractional ATR (ATR / 4). This indicator calculates the traditional Average True Range and divides it by four, isolating exactly 25% of the asset’s recent average volatility.

Why Divide ATR by 4?
Using a fraction of the ATR allows traders to adapt to market noise on a more granular level. Here is how you can apply the ATR/4 to your trading strategy:

High-Probability Intraday Targets: If an asset typically moves $4 a day (Standard ATR), aiming for a $1 move (ATR/4) represents a highly realistic, high-probability profit target for day traders and scalpers.

Tighter, Volatility-Adjusted Stop Losses: Using a full 1x or 2x ATR for a stop loss can sometimes mean risking too much capital or giving back too much floating profit. Using ATR/4 allows you to trail your stops tightly while still factoring in the asset's current micro-volatility, keeping you out of the standard "market noise."

Grid Trading and Scaling In: If you build positions over time, using an arbitrary static number (like buying every $0.50 down) ignores market conditions. Spacing your limit orders by an ATR/4 distance ensures your grid adapts to expanding or contracting volatility.

How it Works
The math is straightforward and transparent:

It calculates the standard Average True Range based on your chosen period.

It divides that exact value by 4.

It plots the resulting value as an easy-to-read oscillator in a separate pane below your chart.

Features & Settings
Customizable ATR Length: By default, the indicator uses the industry-standard 14-period lookback. You can easily adjust this in the settings menu to fit your specific timeframe or strategy (e.g., a 5-period for hyper-responsive data, or a 21-period for smoother data).

Clean Visuals: Plots cleanly in a lower pane so it does not clutter your main price chart.

Best Timeframes
This indicator is universally applicable but shines particularly well on lower timeframes (1m, 5m, 15m) when trying to capture a fraction of the Higher Timeframe (1H, 4H, Daily) volatility.

Disclaimer: This script is for educational and analytical purposes only. Always backtest your risk management strategies before applying them to live capital.

## Source Code

````pine
//@version=6
indicator('ATR Divided by 4', shorttitle = 'ATR/4', overlay = false)

// 1. Define the input for the ATR length (default is usually 14)
atrLength = input.int(14, title = 'ATR Length', minval = 1)

// 2. Calculate the standard ATR
atrValue = ta.atr(atrLength)

// 3. Divide the ATR value by 4
atrDivided = atrValue / 4

// 4. Plot the result on the chart
plot(atrDivided, color = color.blue, title = 'ATR / 4', linewidth = 2, style = plot.style_line)
````
