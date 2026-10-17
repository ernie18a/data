# EMA 50/100 + Candle Trend | Albert Setups

- url: https://www.tradingview.com/script/vBXZahs7-EMA-50-100-Candle-Trend-Albert-Setups/
- type: indicator
- pine_id: PUB;467ad8776bb74f3aac35b8cefc1a6496
- version: 1.0

## Description

# EMA 50/100 + Candle Trend | Albert Setups 📊

**Trade with the Trend. Identify Momentum. Spot Buy & Sell Signals.**

The EMA 50/100 + Candle Trend indicator is designed to help traders identify market direction and potential trading opportunities through two exponential moving averages (EMAs).

### 🔹 Key Features

* **EMA 50 (Green Line):** Tracks shorter-term price momentum.
* **EMA 100 (Orange Line):** Helps identify the broader trend direction.
* **BUY Signal 🟢:** Appears when EMA 50 crosses above EMA 100 on a confirmed candle close.
* **SELL Signal 🔴:** Appears when EMA 50 crosses below EMA 100 on a confirmed candle close.
* **Trend-Based Candlestick Colors:** Green candles indicate a bullish EMA trend bias, while red candles indicate a bearish EMA trend bias.
* **Clean Chart Design:** Simple visuals make trend direction and crossover signals easier to understand.

### 🔹 How to Use

**Bullish Setup:** When EMA 50 crosses above EMA 100, the indicator generates a BUY signal, suggesting potential bullish momentum.

**Bearish Setup:** When EMA 50 crosses below EMA 100, the indicator generates a SELL signal, suggesting potential bearish momentum.

**Trend Confirmation:** Traders can use price action, support and resistance, and higher-timeframe analysis to confirm signals before entering a trade.

### 🔹 Suitable Markets

* Forex
* Gold (XAUUSD)
* Cryptocurrency
* Indices

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlbertSetups


 //@version=6
indicator("EMA 50/100 + Candle Trend | Albert Setups", overlay=true, max_labels_count=500)

// ───── SETTINGS ─────
fastLength = input.int(50, "Fast EMA")
slowLength = input.int(100, "Slow EMA")
showSignals = input.bool(true, "Show BUY / SELL")
colorCandles = input.bool(true, "Color Candles by Trend")
showBackground = input.bool(false, "Show Trend Background")

// ───── EMA CALCULATIONS ─────
ema50 = ta.ema(close, fastLength)
ema100 = ta.ema(close, slowLength)

bullTrend = ema50 > ema100
bearTrend = ema50 < ema100

// ───── EMA PLOTS ─────
plot(ema50, "EMA 50", color=color.lime, linewidth=2)
plot(ema100, "EMA 100", color=color.orange, linewidth=2)

// ───── CANDLE COLORS ─────
candleColor = bullTrend ? color.lime : bearTrend ? color.red : color.gray
barcolor(colorCandles ? candleColor : na)

bgcolor(showBackground ? (bullTrend ? color.new(color.green, 90) : bearTrend ? color.new(color.red, 90) : na) : na)

// ───── BUY / SELL SIGNALS ─────
buySignal = ta.crossover(ema50, ema100) and barstate.isconfirmed
sellSignal = ta.crossunder(ema50, ema100) and barstate.isconfirmed

plotshape(showSignals and buySignal, title="BUY Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal)
plotshape(showSignals and sellSignal, title="SELL Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

// ───── ALERTS ─────
alertcondition(buySignal, title="EMA BUY", message="EMA 50 crossed above EMA 100 on {{ticker}} at {{close}}")
alertcondition(sellSignal, title="EMA SELL", message="EMA 50 crossed below EMA 100 on {{ticker}} at {{close}}")
````
