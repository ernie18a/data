# Stochastic RSI Divergence 

- url: https://www.tradingview.com/script/rXjMwWe6-Stochastic-RSI-Divergence/
- type: indicator
- pine_id: PUB;be86494bb1ca414aa1c0bfb60cb47a3c
- version: 1.0

## Description

**Stochastic RSI Divergence Indicator — Momentum Reversal & Continuation Tool**

This indicator combines the power of **Stochastic RSI** with advanced **divergence detection**, helping traders identify both early reversals and trend continuation opportunities with precision.

By analysing the relationship between price action and momentum shifts on the **Stoch RSI K line**, this tool highlights key areas where market direction is likely to change or strengthen.

---

### 🔍 Key Features

• **Stochastic RSI Engine**

* Built using RSI-based stochastic calculation
* Smooth K & D lines for clearer signals
* Dynamic overbought (80) and oversold (20) zones

• **Full Divergence Suite**
Detects all major divergence types:

* Regular Bullish (reversal up)
* Regular Bearish (reversal down)
* Hidden Bullish (trend continuation up)
* Hidden Bearish (trend continuation down)

• **Precision Pivot Detection**
Uses configurable pivot lookback to identify meaningful highs and lows while filtering noise.

• **Customisable Sensitivity**

* Adjustable RSI length
* Adjustable stochastic length
* Flexible pivot ranges for fine-tuning signals

• **Clean Visual Output**

* Clearly plotted divergence points
* Label-based signal marking (Bull / Bear / Hidden)
* Smooth oscillator display with visual zones

---

### 📊 How to Use

**Regular Bullish Divergence**

* Price makes a lower low
* Stoch RSI makes a higher low
→ Potential upside reversal

**Regular Bearish Divergence**

* Price makes a higher high
* Stoch RSI makes a lower high
→ Potential downside reversal

**Hidden Divergences (Continuation)**

* Bullish: Higher low in price, lower low in momentum
* Bearish: Lower high in price, higher high in momentum

---

### ⚠️ Best Practice

For higher probability setups, combine with:

* Market structure (break of structure / trend direction)
* Support & resistance zones
* Higher timeframe bias

Divergence is a leading signal, but should not be used in isolation.

---

### 🚀 Ideal For

* Crypto & Forex traders
* Scalping, intraday, and swing trading
* Momentum-based strategies
* Reversal and continuation setups

---

**Trade with confirmation. Let momentum reveal what price is about to do.**

## Source Code

````pine
//@version=6
indicator(title="Stochastic RSI Divergence Indicator", shorttitle="Stoch RSI Div", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// Stochastic RSI Inputs
smoothK = input.int(3, "K", minval=1)
smoothD = input.int(3, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)
src = input(close, title="RSI Source")

// Divergence Inputs
lbR = input.int(title="Pivot Lookback Right", defval=1, display = display.data_window)
lbL = input.int(title="Pivot Lookback Left", defval=1, display = display.data_window)
rangeUpper = input(title="Max of Lookback Range", defval=60, display = display.data_window)
rangeLower = input(title="Min of Lookback Range", defval=1, display = display.data_window)
plotBull = input(title="Plot Regular Bullish", defval=true, display = display.data_window)
plotHiddenBull = input(title="Plot Hidden Bullish", defval=false, display = display.data_window)
plotBear = input(title="Plot Regular Bearish", defval=true, display = display.data_window)
plotHiddenBear = input(title="Plot Hidden Bearish", defval=false, display = display.data_window)

// Colors for Divergences
bearColor = #963232b3
bullColor = #329664b3
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

// Calculate Stochastic RSI
rsi1 = ta.rsi(src, lengthRSI)
k = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK) // K line of Stoch RSI
d = ta.sma(k, smoothD) // D line of Stoch RSI

// Plot Stochastic RSI lines and bands
plot(k, "K", color=#329664b3,linewidth=2)
plot(d, "D", color=#963232b3, linewidth=2)
h0 = hline(80, "Upper Band", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
h1 = hline(20, "Lower Band", color=#787B86)
fill(h0, h1, color=color.rgb(33, 150, 243, 90), title="Background")

// Function to check if a bar is within the lookback range for divergence
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

// Detect pivots on the Stochastic RSI K line
plFound = na(ta.pivotlow(k, lbL, lbR)) ? false : true // Pivot Low on K line
phFound = na(ta.pivothigh(k, lbL, lbR)) ? false : true // Pivot High on K line

//------------------------------------------------------------------------------
// Regular Bullish Divergence
// Stoch RSI K: Higher Low (oscHL)
// Price: Lower Low (priceLL)
inRangePl = _inRange(plFound[1]) // Check if the previous pivot low is within range
oscHL = k[lbR] > ta.valuewhen(plFound, k[lbR], 1) and inRangePl
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

// Plotting for Regular Bullish Divergence
plot(
     plFound ? k[lbR] : na,
     offset=-lbR,
     title="Regular Bullish Line",
     linewidth=2,
     color=(bullCond ? bullColor : noneColor),
     display = display.pane,
     editable = plotBull
     )

plotshape(
     bullCond ? k[lbR] : na,
     offset=-lbR,
     title="Regular Bullish Label",
     text=" Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor,
     editable = plotBull
     )

//------------------------------------------------------------------------------
// Hidden Bullish Divergence
// Stoch RSI K: Lower Low (oscLL)
// Price: Higher Low (priceHL)
oscLL = k[lbR] < ta.valuewhen(plFound, k[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

// Plotting for Hidden Bullish Divergence
plot(
     plFound ? k[lbR] : na,
     offset=-lbR,
     title="Hidden Bullish Line",
     linewidth=2,
     color=(hiddenBullCond ? hiddenBullColor : noneColor),
     display = display.pane,
     editable = plotHiddenBull
     )

plotshape(
     hiddenBullCond ? k[lbR] : na,
     offset=-lbR,
     title="Hidden Bullish Label",
     text=" H Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor,
     editable = plotHiddenBull
     )

//------------------------------------------------------------------------------
// Regular Bearish Divergence
// Stoch RSI K: Lower High (oscLH)
// Price: Higher High (priceHH)
inRangePh = _inRange(phFound[1]) // Check if the previous pivot high is within range
oscLH = k[lbR] < ta.valuewhen(phFound, k[lbR], 1) and inRangePh
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

// Plotting for Regular Bearish Divergence
plot(
     phFound ? k[lbR] : na,
     offset=-lbR,
     title="Regular Bearish Line",
     linewidth=2,
     color=(bearCond ? bearColor : noneColor),
     display = display.pane,
     editable = plotBear
     )

plotshape(
     bearCond ? k[lbR] : na,
     offset=-lbR,
     title="Regular Bearish Label",
     text=" Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor,
     editable = plotBear
     )

//------------------------------------------------------------------------------
// Hidden Bearish Divergence
// Stoch RSI K: Higher High (oscHH)
// Price: Lower High (priceLH)
oscHH = k[lbR] > ta.valuewhen(phFound, k[lbR], 1) and inRangePh
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

// Plotting for Hidden Bearish Divergence
plot(
     phFound ? k[lbR] : na,
     offset=-lbR,
     title="Hidden Bearish Line",
     linewidth=2,
     color=(hiddenBearCond ? hiddenBearColor : noneColor),
     display = display.pane,
     editable = plotHiddenBear
     )

plotshape(
     hiddenBearCond ? k[lbR] : na,
     offset=-lbR,
     title="Hidden Bearish Label",
     text=" H Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor,
     editable = plotHiddenBear
     )

// Alert Conditions
alertcondition(bullCondAlert, title='Stoch RSI Regular Bullish Divergence', message="Found a new Regular Bullish Divergence on Stoch RSI, `Pivot Lookback Right` number of bars to the left of the current bar")
alertcondition(hiddenBullCondAlert, title='Stoch RSI Hidden Bullish Divergence', message='Found a new Hidden Bullish Divergence on Stoch RSI, `Pivot Lookback Right` number of bars to the left of the current bar')
alertcondition(bearCondAlert, title='Stoch RSI Regular Bearish Divergence', message='Found a new Regular Bearish Divergence on Stoch RSI, `Pivot Lookback Right` number of bars to the left of the current bar')
alertcondition(hiddenBearCondAlert, title='Stoch RSI Hidden Bearish Divergence', message='Found a new Hidden Bearish Divergence on Stoch RSI, `Pivot Lookback Right` number of bars to the left of the current bar')
````
