# Adaptive Trend Flow

- url: https://www.tradingview.com/script/DMb8Xqfz-Adaptive-Trend-Flow/
- type: indicator
- pine_id: PUB;4084bb66f95a44a78a21c2b0bdbbdf88
- version: 1.0

## Description

[b]Adaptive Trend Flow[/b] is a trend-following indicator designed to simplify market structure and identify potential trend transitions using adaptive moving averages and crossover confirmation.

How It Works

* **Fast Adaptive Line (Blue):** Tracks short-term momentum and reacts quickly to price changes.
* **Slow Adaptive Line (Orange):** Represents the dominant trend direction and filters market noise.
* **Buy Signals:** Generated when the fast line crosses above the slow line, indicating potential bullish momentum.
* **Sell Signals:** Generated when the fast line crosses below the slow line, indicating potential bearish momentum.
* **Trend Zones:** Background coloring helps visualize bullish and bearish market phases for easier trend recognition.

### What the Chart Shows

On the attached BNBUSDT 2H chart:

✅ Early bullish crossover captured the strong upward expansion.

✅ Bearish crossover signaled the beginning of the major downtrend and kept traders aligned with market direction.

✅ Later bullish crossover identified the recovery phase before the next trend continuation.

✅ Recent price action shows the fast and slow lines converging again, suggesting a potential transition zone where traders should watch for confirmation.

### Best Use Cases

* Trend-following strategies
* Swing trading
* Position trading
* Higher timeframe confirmation
* Filtering false breakouts

### Recommended Settings

* Fast Length: 20
* Slow Length: 50
* Signal Smoothing: 10
* Adaptive Factor: 14
* Source: Close

### Risk Management

No indicator predicts the market with perfect accuracy. Always combine signals with:

* Support and resistance
* Market structure
* Volume analysis
* Proper risk management

### Key Features

✔ Adaptive trend detection
✔ Buy/Sell crossover signals
✔ Dynamic trend visualization
✔ Reduced market noise
✔ Works across crypto, forex, indices, and stocks

**Adaptive Trend Flow helps traders stay with the prevailing trend while highlighting potential reversal points through adaptive crossover logic.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Adaptive Trend Flow", overlay=true)

//━━━━━━━━━━ INPUTS ━━━━━━━━━━
fastLen = input.int(20, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
atrLen  = input.int(14, "ATR Length")
rsiLen  = input.int(14, "RSI Length")
atrMult = input.float(0.5, "ATR Filter")

//━━━━━━━━━━ CALCULATIONS ━━━━━━━━━━
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

atr = ta.atr(atrLen)
rsi = ta.rsi(close, rsiLen)

// Adaptive Trend
trendUp = fastEMA > slowEMA and close > fastEMA + atr * atrMult
trendDn = fastEMA < slowEMA and close < fastEMA - atr * atrMult

// Momentum
bullMomentum = rsi > 55
bearMomentum = rsi < 45

// Buy / Sell
buy = trendUp and bullMomentum and ta.crossover(close, fastEMA)
sell = trendDn and bearMomentum and ta.crossunder(close, fastEMA)

//━━━━━━━━━━ PLOTS ━━━━━━━━━━
plot(fastEMA, color=color.aqua, linewidth=2, title="Fast EMA")
plot(slowEMA, color=color.orange, linewidth=2, title="Slow EMA")

bgcolor(trendUp ? color.new(color.green,90) :
       trendDn ? color.new(color.red,90) : na)

plotshape(buy,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY")

plotshape(sell,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL")

alertcondition(buy,
     title="Buy Alert",
     message="Adaptive Trend Flow BUY")

alertcondition(sell,
     title="Sell Alert",
     message="Adaptive Trend Flow SELL")
````
