# Edward Smart Dynamic Channel Breakout

- url: https://www.tradingview.com/script/0nCBDmLj-Edward-Smart-Dynamic-Channel-Breakout/
- type: indicator
- pine_id: PUB;bb01f05b047149c18006a9f82e83fcb7
- version: 1.0

## Description

[b]Edward Smart Dynamic Channel Breakout[/b] is a trend-following indicator designed to identify market direction, breakout opportunities, and potential entry zones using adaptive price channels and trend confirmation.

The indicator automatically adjusts to changing market conditions, helping traders stay aligned with the dominant trend while filtering out unnecessary market noise.

[b]Key Features[/b]
• Dynamic Trend Channels
• Automatic Buy & Sell Signals
• Trend Direction Filter
• Adaptive Support & Resistance Zones
• Market Structure Visualization
• Clean Chart Layout
• Alert Conditions Included

[b]How It Works[/b]
The indicator builds dynamic price channels based on recent market behavior. When price confirms a breakout and aligns with the prevailing trend, buy or sell signals are generated. The adaptive channel helps traders identify trend continuation opportunities while avoiding low-probability setups.

[b]Best Used For[/b]
• Forex Markets
• Gold (XAUUSD)
• Indices
• Commodities
• Cryptocurrency Markets

[b]Note[/b]
This indicator is designed for educational and analytical purposes only. Always combine technical analysis with proper risk management and independent market research before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Edward Smart Dynamic Channel Breakout", overlay=true)

// ===== INPUTS =====
length = input.int(20, "Channel Length", minval=5)
emaLength = input.int(100, "Trend EMA")
atrLength = input.int(14, "ATR Length")
atrFilter = input.float(0.3, "ATR Filter")

// ===== CHANNEL =====
upper = ta.highest(high, length)
lower = ta.lowest(low, length)
middle = (upper + lower) / 2

// ===== FILTERS =====
ema = ta.ema(close, emaLength)
atr = ta.atr(atrLength)

// ===== BREAKOUTS =====
bullBreakout = close > upper[1] and close > ema and (close - upper[1]) > atr * atrFilter
bearBreakout = close < lower[1] and close < ema and (lower[1] - close) > atr * atrFilter

// ===== RETEST =====
bullRetest = low <= upper and close > upper
bearRetest = high >= lower and close < lower

// ===== PLOTS =====
u = plot(upper, "Upper Channel", color=color.red, linewidth=2)
l = plot(lower, "Lower Channel", color=color.green, linewidth=2)
plot(middle, "Middle Channel", color=color.orange)

fill(u, l, color.new(color.blue, 90))

plot(ema, "EMA", color=color.yellow, linewidth=2)

// ===== SIGNALS =====
plotshape(bullBreakout,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     title="BUY",
     text="BUY")

plotshape(bearBreakout,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     title="SELL",
     text="SELL")

plotshape(bullRetest,
     style=shape.circle,
     location=location.belowbar,
     color=color.green,
     size=size.tiny,
     title="Bull Retest")

plotshape(bearRetest,
     style=shape.circle,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     title="Bear Retest")

// ===== ALERTS =====
alertcondition(bullBreakout, "Bullish Breakout", "Bullish Channel Breakout")
alertcondition(bearBreakout, "Bearish Breakout", "Bearish Channel Breakout")
````
