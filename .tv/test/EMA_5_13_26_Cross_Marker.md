<!-- tradingview-pine-id: PUB;a7db57ba657440ffb0fdad9e4d1ebab8 -->
<!-- tradingviewscripts-format: 1 -->
# EMA 5 / 13 / 26 Cross Marker

Source: https://www.tradingview.com/script/zkVsPWaO-Moving-Average-Crossover-Marker/

## Description

Excited to share my first Trading View Pine Script with the community!

I’ve built a Beginner‑Friendly Moving Average Crossover Indicator that helps traders spot trend changes with clear buy/sell signals and real‑time alerts.

📊 Example: The chart below shows Shipping Corporation of India (SCI) on the 1‑hour timeframe. Notice how the moving average crossovers align with the bullish reversal — this is exactly what the script is designed to highlight.

✨ Features:

Customizable fast & slow MA lengths

Automatic crossover alerts

Works across stocks, indices, and crypto

This is just the start — I’ll be publishing more scripts focused on NSE stocks, BankNifty strategies, and risk management tools in the coming weeks.

💬 Feedback is welcome — I’d love to hear how it works for your trading style!

#TradingView #PineScript #NSE #BankNifty #AlgoTrading #TechnicalAnalysis

---

## Source Code

````pine
//@version=6
indicator("EMA 5 / 13 / 26 Cross Marker", overlay=true)

// EMA lengths
len1 = input.int(5,  "EMA Fast")
len2 = input.int(13, "EMA Medium")
len3 = input.int(26, "EMA Slow")

// Calculate EMAs
ema5  = ta.ema(close, len1)
ema13 = ta.ema(close, len2)
ema26 = ta.ema(close, len3)

// Plot EMAs
plot(ema5,  color=color.green,  title="EMA 5",  linewidth=2)
plot(ema13, color=color.orange, title="EMA 13", linewidth=2)
plot(ema26, color=color.red,    title="EMA 26", linewidth=2)

// Cross conditions
cross_5_13_up   = ta.crossover(ema5, ema13)


cross_5_26_up   = ta.crossover(ema5, ema26)


// Plot signals on chart
plotshape(cross_5_13_up,   title="5>13", style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.small, text="5>13")

plotshape(cross_5_26_up,   title="5>26", style=shape.circle,       location=location.belowbar, color=color.blue, size=size.small, text="5>26")
````
