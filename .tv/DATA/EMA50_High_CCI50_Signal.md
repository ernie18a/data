<!-- tradingview-pine-id: PUB;aecd9a625a0848edbb017ee21589239e -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA50 High + CCI50 Signal

Source: https://www.tradingview.com/script/znInc1HR-CCI-Bullish-Price-Crossed-Above-EMA-50-High-CCI-50-50/

## Description

EMA50 High + CCI50 Momentum Breakout

This indicator is a trend-following momentum strategy designed to identify high-probability long entry points. It combines a dynamic price channel with a classic momentum oscillator to confirm that the asset is both breaking out of resistance and gaining strong bullish velocity simultaneously.

 🔎 How It Works
The script monitors two independent conditions to confirm a valid market entry, filtering out weak price moves by requiring both price structure and momentum to align.

* Dynamic Resistance (EMA 50 of Highs): Instead of using standard closing prices, this indicator calculates an Exponential Moving Average using the high of each candle. This creates a smoothed, dynamic "ceiling" or resistance line. A close above this line signals a significant structural breakout.
* Momentum Filter (CCI 50): The Commodity Channel Index (CCI) tracks the asset's current price relative to its historical statistical average. By setting the lookback period to 50 and watching for a cross above the +50 level, the script ensures that the price breakout is backed by real institutional buying pressure, rather than low-volume noise.

## 📊 Trigger Conditions
A green "BUY" label plots on the chart exclusively when both of the following conditions occur on the exact same candle:

   1. The candle closing price crosses above the orange EMA (50, High).
   2. The CCI (50) crosses above the +50 momentum line.

## 💡 Trading Tips & Implementation

* Trend Filtration: This indicator excels in trending or expanding markets. In tight, sideways consolidation ranges, it may produce false signals (whipsaws) as the price chops through the moving average.
* Risk Management: The orange EMA line can serve double-duty as a dynamic trailing stop-loss indicator. Traders frequently look to protect capital by placing initial stops below the breakout candle low or trailing it along the EMA curve.
* Customizability: You can easily change the momentum sensitivity by tweaking the CCI Length inside the indicator settings menu without touching the code.

---

## Source Code

````pine
//@version=6
indicator("EMA50 High + CCI50 Signal", overlay=true)

// Inputs
cciLength = input.int(50, title="CCI Length")

// EMA(50) of High
emaHigh50 = ta.ema(high, 50)

// CCI(50) using the input variable
cci50 = ta.cci(close, cciLength)

// Conditions
priceCrossAbove = ta.crossover(close, emaHigh50)
cciCrossAbove50 = ta.crossover(cci50, 50)

// Combined signal
signal = priceCrossAbove and cciCrossAbove50

// Plotting
plot(emaHigh50, color=color.orange, title="EMA 50 High")
plotshape(signal, style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)

alertcondition(signal, title="BUY Signal", message="EMA50 High + CCI50 Buy Signal Triggered")
````
