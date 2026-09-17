<!-- tradingview-pine-id: PUB;28d8f6729e2f4af38566c395b2f386f6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Vertex RSI Market Regime

Source: https://www.tradingview.com/script/XasDHFbh-RSI-Market-Regime/

## Description

RSI is one of the most widely used momentum indicators in technical analysis.

But RSI can be interpreted as more than simply an overbought or oversold oscillator.

RSI Market Regime adds a simple momentum-regime layer to the traditional RSI framework. Instead of focusing only on the 30/70 levels, the script helps identify whether momentum is developing within a bullish, bearish, or neutral regime.

What it provides

• Traditional RSI momentum reading
• Smoothed momentum for a clearer regime view
• Bullish and bearish regime thresholds
• Visual market-regime background
• Regime transition markers
• Traditional 30/50/70 reference levels

The idea is simple:

RSI tells you where momentum is.
Regime analysis helps you understand how momentum is behaving.

This is not intended to predict every market move or replace a complete trading system. It is designed as an additional market-structure and momentum perspective that can help traders interpret RSI in a broader context.

Try it on different markets and timeframes and observe how momentum regimes develop before major price movements.

Educational purposes only. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Vertex RSI Market Regime", shorttitle="VRSIRegime", overlay=false)

// Inputs
rsiLength = input.int(14, "RSI Length", minval=2)
smoothLength = input.int(5, "Momentum Smoothing", minval=1)
bullLevel = input.float(55.0, "Bullish Regime", minval=50.0, maxval=70.0)
bearLevel = input.float(45.0, "Bearish Regime", minval=30.0, maxval=50.0)

// RSI
rsi = ta.rsi(close, rsiLength)
momentum = ta.sma(rsi, smoothLength)

// Market regime
bullish = momentum > bullLevel
bearish = momentum < bearLevel
neutral = not bullish and not bearish

// Plot RSI
plot(rsi, "RSI", color=color.blue, linewidth=2)
plot(momentum, "Momentum", color=color.orange, linewidth=2)

// Reference levels
hline(70, "Overbought", color=color.gray, linestyle=hline.style_dashed)
hline(50, "Midline", color=color.gray)
hline(30, "Oversold", color=color.gray, linestyle=hline.style_dashed)

// Regime levels
hline(bullLevel, "Bullish Regime", color=color.green, linestyle=hline.style_dotted)
hline(bearLevel, "Bearish Regime", color=color.red, linestyle=hline.style_dotted)

// Regime background
bgcolor(
     bullish ? color.new(color.green, 90) :
     bearish ? color.new(color.red, 90) :
     color.new(color.gray, 95)
)

// Regime transitions
bullishTransition = bullish and not bullish[1]
bearishTransition = bearish and not bearish[1]

plotshape(
     bullishTransition,
     title="Bullish Regime Shift",
     style=shape.triangleup,
     location=location.bottom,
     color=color.green,
     size=size.tiny,
     text="BULL"
)

plotshape(
     bearishTransition,
     title="Bearish Regime Shift",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny,
     text="BEAR"
)
````
