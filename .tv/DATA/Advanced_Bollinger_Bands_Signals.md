<!-- tradingview-pine-id: PUB;05c07660672d4ff7b760e1596ae5bacc -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Bollinger Bands Signals

Source: https://www.tradingview.com/script/ctSp4aci-Advanced-Bollinger-Bands-Signals/

## Description

Advanced Bollinger Bands Signals
Advanced Bollinger Bands Signals is a trend-following indicator designed to provide high-quality trading signals by combining Bollinger Bands with trend, momentum, and volatility filters. Instead of relying solely on Bollinger Band touches, this indicator helps reduce false signals by confirming entries with a 200 EMA trend filter and RSI momentum.
Features
Bollinger Bands (20, 2) for volatility analysis
200 EMA trend filter
RSI confirmation to improve signal quality
Buy and Sell signal arrows
ATR-based Stop Loss and Take Profit levels
Built-in TradingView alert conditions
Non-repainting signals based on confirmed candle closes
How It Works
Buy Signal
Price crosses back above the lower Bollinger Band.
Price is above the 200 EMA.
RSI confirms bullish momentum.
Sell Signal
Price crosses back below the upper Bollinger Band.
Price is below the 200 EMA.
RSI confirms bearish momentum.
Best Timeframes
This indicator can be used on multiple timeframes, including:
15 Minutes
1 Hour
4 Hours
Daily
It works well on Forex, Stocks, Indices, and Cryptocurrencies.
Risk Management
The indicator plots ATR-based Stop Loss and Take Profit levels to help traders manage risk consistently. Always use proper position sizing and avoid risking more than you can afford to lose.
Alerts
TradingView alerts are included for both Buy and Sell signals, allowing you to receive notifications whenever a new signal appears.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Advanced Bollinger Bands Signals", overlay=true, max_labels_count=500)

//====================
// Inputs
//====================
bbLength = input.int(20, "BB Length", minval=1)
bbStdDev = input.float(2.0, "BB StdDev", step=0.1)

emaLength = input.int(200, "Trend EMA Length")
rsiLength = input.int(14, "RSI Length")

atrLength = input.int(14, "ATR Length")
atrSL = input.float(1.5, "Stop Loss ATR Multiplier")
atrTP = input.float(2.5, "Take Profit ATR Multiplier")

showSLTP = input.bool(true, "Show SL/TP")

//====================
// Indicators
//====================
basis = ta.sma(close, bbLength)
dev = bbStdDev * ta.stdev(close, bbLength)

upper = basis + dev
lower = basis - dev

ema200 = ta.ema(close, emaLength)
rsi = ta.rsi(close, rsiLength)
atr = ta.atr(atrLength)

//====================
// Trend Filter
//====================
upTrend = close > ema200
downTrend = close < ema200

//====================
// Buy & Sell Conditions
//====================
buySignal =
     ta.crossover(close, lower) and
     upTrend and
     rsi > 30

sellSignal =
     ta.crossunder(close, upper) and
     downTrend and
     rsi < 70

//====================
// Plot Bollinger Bands
//====================
u = plot(upper, color=color.red, linewidth=2, title="Upper Band")
m = plot(basis, color=color.orange, linewidth=2, title="Middle Band")
l = plot(lower, color=color.green, linewidth=2, title="Lower Band")

fill(u, l, color=color.new(color.blue, 90))

// EMA
plot(ema200, color=color.yellow, linewidth=2, title="EMA 200")

//====================
// Buy / Sell Arrows
//====================
plotshape(buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL")

//====================
// ATR Stop Loss & Take Profit
//====================
var line slLine = na
var line tpLine = na

if buySignal and showSLTP
    line.delete(slLine)
    line.delete(tpLine)

    sl = close - atr * atrSL
    tp = close + atr * atrTP

    slLine := line.new(bar_index, sl, bar_index + 20, sl,
         color=color.red, width=2)

    tpLine := line.new(bar_index, tp, bar_index + 20, tp,
         color=color.green, width=2)

if sellSignal and showSLTP
    line.delete(slLine)
    line.delete(tpLine)

    sl = close + atr * atrSL
    tp = close - atr * atrTP

    slLine := line.new(bar_index, sl, bar_index + 20, sl,
         color=color.red, width=2)

    tpLine := line.new(bar_index, tp, bar_index + 20, tp,
         color=color.green, width=2)

//====================
// Alerts
//====================
alertcondition(buySignal,
     title="Buy Alert",
     message="Advanced BB Buy Signal")

alertcondition(sellSignal,
     title="Sell Alert",
     message="Advanced BB Sell Signal")
````
