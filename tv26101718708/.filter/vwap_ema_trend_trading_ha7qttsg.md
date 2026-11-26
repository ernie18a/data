# VWAP & EMA Trend Trading

- url: https://www.tradingview.com/script/Ha7qtTSG-VWAP-EMA-Trend-Trading/
- type: indicator
- pine_id: PUB;b77b8112845943dfb7f51ab0afd4453b
- version: 1.0

## Description

VWAP & EMA Trend Trading is a simple and clean trend-following indicator designed to help traders identify higher probability long and short opportunities using two powerful tools: VWAP and the 21 EMA.

The indicator detects bullish conditions when price is above both VWAP and EMA 21, and bearish conditions when price is below both. Buy and Sell signals appear when price crosses the EMA while maintaining trend confirmation with VWAP.

This tool works especially well for:
• Scalping
• Intraday trading
• Futures trading
• Trend continuation setups
• Pullback entries

Best used during trending market conditions and combined with:
• Support & Resistance
• Trendlines
• Volume confirmation
• Market structure
• Price action analysis

Features:
✔ VWAP trend confirmation
✔ EMA 21 momentum filter
✔ Buy & Sell signals
✔ Clean chart visualization
✔ Alert conditions included

This indicator is designed to help reduce emotional trading and improve trend clarity during fast-moving markets.

Suggested use:
• Look for longs above VWAP and EMA 21
• Look for shorts below VWAP and EMA 21
• Wait for pullbacks and confirmations instead of chasing candles

If you find this indicator useful, please consider:
👍 Leaving a Like
⭐ Adding to Favorites
📢 Sharing with fellow traders and friends

Your support is greatly appreciated and helps motivate future trading tools and improvements for the trading community.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © humblehustle

//@version=5
indicator("VWAP & EMA Trend Trading", overlay=true)

// Define indicators
vwap = ta.vwap(close)
ema21 = ta.ema(close, 21)
plot(vwap, title="VWAP", color=color.orange, linewidth=2)
plot(ema21, title="EMA 21", color=color.blue, linewidth=2)

// Identify trend direction
isBullishTrend = close > vwap and close > ema21
isBearishTrend = close < vwap and close < ema21

// Entry conditions
longEntry = isBullishTrend and ta.crossover(close, ema21)
shortEntry = isBearishTrend and ta.crossunder(close, ema21)

// Plot buy and sell signals
plotshape(longEntry, location=location.belowbar, color=color.green, style=shape.labelup, title="Buy Signal", text="BUY")
plotshape(shortEntry, location=location.abovebar, color=color.red, style=shape.labeldown, title="Sell Signal", text="SELL")

// Alert conditions
alertcondition(longEntry, title="Long Entry", message="Long entry signal above VWAP and EMA 21 detected!")
alertcondition(shortEntry, title="Short Entry", message="Short entry signal below VWAP and EMA 21 detected!")
````
