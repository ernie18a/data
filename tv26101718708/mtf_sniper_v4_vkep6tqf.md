# MTF Sniper v4

- url: https://www.tradingview.com/script/VKEP6TQF-MTF-Sniper-v4/
- type: indicator
- pine_id: PUB;6f79ac466c7b42d6811a8dadcb925b29
- version: 3.0

## Description

MTF Sniper is a precision entry indicator that combines trendline structure, EMA momentum, Price action and ADX trend strength into a single, easy-to-read signal.
No more second-guessing. No more watching multiple indicators separately. MTF Sniper does the heavy lifting — it analyzes the market structure in real time and fires a BUY or SELL label only when everything lines up perfectly.
Designed for intraday traders, MTF Sniper works best on lower timeframes and comes with a built-in session filter to keep you out of low-liquidity hours. Fully customizable trendline styles, colors, and alert settings included.
What you see on the chart:

🟢 BUY label — high-probability long entry
🔴 SELL label — high-probability short entry
Major and Minor trendlines drawn automatically

Built for XAUUSD at Forex.COM Chart.

## Source Code

````pine
//@version=5
indicator("EMA 9 & EMA 21", overlay=true)

// Calculate EMAs
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

// Plot EMAs
plot(ema9, title="EMA 9", color=color.blue, linewidth=2)
plot(ema21, title="EMA 21", color=color.orange, linewidth=2)
````
