# MRK BUY SELL

- url: https://www.tradingview.com/script/98exVeHO-MRK-BUY-SELL/
- type: indicator
- pine_id: PUB;e668c0f2f6dc4e98a08dd0985ea2b5e1
- version: 1.0

## Description

## CANDLE BODY STRENGTH BUY SELL

**Candle Body Strength Buy Sell** is a price-action-based indicator designed to measure the strength of each candle by comparing its **real body size with its total High-to-Low range**.

### How It Works

The indicator calculates:

**Body Strength % = |Close − Open| ÷ (High − Low) × 100**

A higher percentage means the candle has a larger body relative to its total range, indicating stronger directional price movement with smaller combined wicks.

### BUY Signal 🟢

A **BUY** label appears when:

- The candle is bullish: **Close > Open**
- Candle Body Strength is **70% or higher**
- The candle has fully closed

### SELL Signal 🔴

A **SELL** label appears when:

- The candle is bearish: **Close < Open**
- Candle Body Strength is **70% or higher**
- The candle has fully closed

The minimum strength level is customizable, so traders can change the default **70% threshold** according to their analysis.

### Live Body Strength

The indicator also displays the **current candle's Body Strength %**, making it easy to see how strong the developing candle is.

### Important

Body strength alone does not determine market direction or guarantee continuation. For better context, it can be combined with **market structure, support/resistance, CPR, Fibonacci, RSI, EMA, volume, or other confirmation methods**.

**Disclaimer:** This indicator is created for educational and analytical purposes only. It does not constitute investment advice or a recommendation to buy or sell any security. Trading involves risk. Always perform your own analysis and use appropriate risk management.

## Source Code

````pine
//@version=6
indicator("MRK BUY SELL", shorttitle="MRK BUY SELL", overlay=true, max_labels_count=500)

//====================================================
// SETTINGS
//====================================================

minStrength = input.float(70.0, "Minimum Body Strength %", step=1.0)

//====================================================
// BODY STRENGTH
//====================================================

candleRange = high - low
body = math.abs(close - open)

bodyStrength = candleRange > 0 ? (body / candleRange) * 100 : 0.0

//====================================================
// BUY / SELL CONDITIONS
//====================================================

buySignal = close > open and bodyStrength >= minStrength
sellSignal = close < open and bodyStrength >= minStrength

//====================================================
// BUY SIGNAL
//====================================================

if buySignal and barstate.isconfirmed
    label.new(
         bar_index,
         low,
         "BUY\n" + str.tostring(bodyStrength, "#.##") + "%",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal
    )

//====================================================
// SELL SIGNAL
//====================================================

if sellSignal and barstate.isconfirmed
    label.new(
         bar_index,
         high,
         "SELL\n" + str.tostring(bodyStrength, "#.##") + "%",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal
    )

//====================================================
// CURRENT CANDLE BODY STRENGTH
//====================================================

var label lbl = na

if barstate.islast
    label.delete(lbl)

    txt = "BODY STRENGTH = " + str.tostring(bodyStrength, "#.##") + "%"

    lbl := label.new(
         bar_index,
         high,
         txt,
         style=label.style_label_down,
         color=close >= open ? color.green : color.red,
         textcolor=color.white,
         size=size.normal
    )
````
