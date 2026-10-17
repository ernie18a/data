# MACD Divergences HIST&LINE  

- url: https://www.tradingview.com/script/lCmeVP3p-MACD-Divergences-HIST-LINE/
- type: indicator
- pine_id: PUB;fce8e286b5334219a4f556119142912c
- version: 1.0

## Description

**MACD Divergences HIST & LINE — Advanced Momentum Divergence Tool**

This indicator is designed to identify high-probability divergence setups using both the **MACD line** and **Histogram**, giving traders early signals and confirmation within one tool.

Built for precision and clarity, it detects **regular bullish and bearish divergences** by comparing price action with momentum shifts, helping traders spot potential reversals before they fully develop.

---

### 🔍 Key Features

• **Dual Divergence Engine**
Detects divergence on both:

* MACD Line (confirmation signals)
* Histogram (early momentum shifts)

• **Smart Pivot Detection**
Uses adaptive pivot logic to identify meaningful highs and lows while filtering out noise.

• **Zero-Line Filter (Optional)**
Improves signal quality by only allowing:

* Bullish setups below zero
* Bearish setups above zero

• **Customizable MACD Settings**

* Adjustable fast/slow lengths
* Selectable MA types (EMA or SMA)
* Fully configurable signal smoothing

• **Visual Clarity**

* Color-coded histogram momentum
* Clearly labeled bullish and bearish divergence zones
* Easy-to-read structure for fast decision making

---

### 📊 How to Use

**Bullish Divergence**

* Price forms a lower low
* MACD / Histogram forms a higher low
→ Indicates potential upside reversal

**Bearish Divergence**

* Price forms a higher high
* MACD / Histogram forms a lower high
→ Indicates potential downside reversal

For best results, combine with:

* Market structure (break of structure / trend shifts)
* Key support & resistance levels
* Volume confirmation

---

### ⚠️ Notes

This tool is designed to **assist decision-making**, not replace it.
Divergence is most effective when used within a broader trading strategy and proper risk management.

---

### 🚀 Ideal For

* Crypto traders
* Forex traders
* Intraday and swing trading
* Momentum and reversal strategies

---

**Stay disciplined. Trade with structure. Let momentum confirm your edge.**

## Source Code

````pine
//@version=6
indicator(title = 'MACD Divergences HIST&LINE  ', timeframe = '')
// Getting inputs

fast_length = input(title = 'Fast Length', defval = 12)
slow_length = input(title = 'Slow Length', defval = 26)
src = input(title = 'Source', defval = close)
signal_length = input.int(title = 'Signal Smoothing', minval = 1, maxval = 50, defval = 9)
sma_source = input.string(title = 'Oscillator MA Type', defval = 'EMA', options = ['SMA', 'EMA'])
sma_signal = input.string(title = 'Signal Line MA Type', defval = 'EMA', options = ['SMA', 'EMA'])
// Plot colors
col_macd = input.color(#46e715, 'MACD Line', group = 'Color Settings', inline = 'MACD')
col_signal = input.color(#ff0101, 'Signal Line', group = 'Color Settings', inline = 'Signal')
col_grow_above = input.color(#46e715, 'Above Grow', group = 'Histogram', inline = 'Above')
col_fall_above = input.color(#c7f8ce, 'Fall', group = 'Histogram', inline = 'Above')
col_grow_below = input.color(color.rgb(253, 193, 199), 'Below Grow', group = 'Histogram', inline = 'Below')
col_fall_below = input.color(#ff0101, 'Fall', group = 'Histogram', inline = 'Below')
// Calculating
fast_ma = sma_source == 'SMA' ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source == 'SMA' ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal == 'SMA' ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)
hist = macd - signal
plot(hist, title = 'Histogram', style = plot.style_columns, color = hist >= 0 ? hist[1] < hist ? col_grow_above : col_fall_above : hist[1] < hist ? col_grow_below : col_fall_below)
plot(macd, title = 'MACD', color = col_macd)
plot(signal, title = 'Signal', color = col_signal)


donttouchzero = input(title = 'Don\'t touch the zero line?', defval = true)

lbR = input(title = 'Pivot Lookback Right', defval = 5)
lbL = input(title = 'Pivot Lookback Left', defval = 5)
rangeUpper = input(title = 'Max of Lookback Range', defval = 60)
rangeLower = input(title = 'Min of Lookback Range', defval = 5)
plotBull = input(title = 'Plot Bullish', defval = true)
plotHiddenBull = false
plotBear = input(title = 'Plot Bearish', defval = true)
plotHiddenBear = false
bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

// --- Divergence for MACD Line (Original Logic) ---
osc = macd

plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

//------------------------------------------------------------------------------
// Regular Bullish (MACD)
// Osc: Higher Low
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1]) and osc[lbR] < 0
// Price: Lower Low
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
priceHHZero = ta.highest(osc, lbL + lbR + 5)
blowzero = donttouchzero ? priceHHZero < 0 : true
bullCond = plotBull and priceLL and oscHL and plFound and blowzero

plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish MACD', linewidth = 2, color = bullCond ? bullColor : noneColor)

plotshape(bullCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish MACD Label', text = ' Bull MACD ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0))

//------------------------------------------------------------------------------
// Hidden Bullish (MACD) - (Currently not plotted based on your 'plotHiddenBull' input)
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound

plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bullish MACD', linewidth = 2, color = hiddenBullCond ? hiddenBullColor : noneColor)

plotshape(hiddenBullCond ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bullish MACD Label', text = ' H Bull MACD ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0))

//------------------------------------------------------------------------------
// Regular Bearish (MACD)
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1]) and osc[lbR] > 0
priceLLZero = ta.lowest(osc, lbL + lbR + 5)
bearzero = donttouchzero ? priceLLZero > 0 : true
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond = plotBear and priceHH and oscLH and phFound and bearzero

plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish MACD', linewidth = 2, color = bearCond ? bearColor : noneColor)

plotshape(bearCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish MACD Label', text = ' Bear MACD ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0))

//------------------------------------------------------------------------------
// Hidden Bearish (MACD) - (Currently not plotted based on your 'plotHiddenBear' input)
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound

plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bearish MACD', linewidth = 2, color = hiddenBearCond ? hiddenBearColor : noneColor)

plotshape(hiddenBearCond ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bearish MACD Label', text = ' H Bear MACD ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0))

// --- Divergence for Histogram ---
// Create new pivot detection for histogram
histPlFound = na(ta.pivotlow(hist, lbL, lbR)) ? false : true
histPhFound = na(ta.pivothigh(hist, lbL, lbR)) ? false : true

//------------------------------------------------------------------------------
// Regular Bullish (Histogram)
// Hist: Higher Low
histOscHL = hist[lbR] > ta.valuewhen(histPlFound, hist[lbR], 1) and _inRange(histPlFound[1]) and hist[lbR] < 0
// Price: Lower Low
// Use the same priceLL as before since price divergence is always on the main chart
histPriceLL = low[lbR] < ta.valuewhen(histPlFound, low[lbR], 1)
histPriceHHZero = ta.highest(hist, lbL + lbR + 5)
histBlowZero = donttouchzero ? histPriceHHZero < 0 : true
histBullCond = plotBull and histPriceLL and histOscHL and histPlFound and histBlowZero

plot(histPlFound ? hist[lbR] : na, offset = -lbR, title = 'Regular Bullish Hist', linewidth = 2, color = histBullCond ? bullColor : noneColor)

plotshape(histBullCond ? hist[lbR] : na, offset = -lbR, title = 'Regular Bullish Hist Label', text = ' Bull Hist ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0))

//------------------------------------------------------------------------------
// Hidden Bullish (Histogram) - (Currently not plotted based on your 'plotHiddenBull' input)
// Hist: Lower Low
histOscLL = hist[lbR] < ta.valuewhen(histPlFound, hist[lbR], 1) and _inRange(histPlFound[1])
// Price: Higher Low
histPriceHL = low[lbR] > ta.valuewhen(histPlFound, low[lbR], 1)
histHiddenBullCond = plotHiddenBull and histPriceHL and histOscLL and histPlFound

plot(histPlFound ? hist[lbR] : na, offset = -lbR, title = 'Hidden Bullish Hist', linewidth = 2, color = histHiddenBullCond ? hiddenBullColor : noneColor)

plotshape(histHiddenBullCond ? hist[lbR] : na, offset = -lbR, title = 'Hidden Bullish Hist Label', text = ' H Bull Hist ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0))


//------------------------------------------------------------------------------
// Regular Bearish (Histogram)
// Hist: Lower High
histOscLH = hist[lbR] < ta.valuewhen(histPhFound, hist[lbR], 1) and _inRange(histPhFound[1]) and hist[lbR] > 0
// Price: Higher High
histPriceHH = high[lbR] > ta.valuewhen(histPhFound, high[lbR], 1)
histPriceLLZero = ta.lowest(hist, lbL + lbR + 5)
histBearZero = donttouchzero ? histPriceLLZero > 0 : true
histBearCond = plotBear and histPriceHH and histOscLH and histPhFound and histBearZero

plot(histPhFound ? hist[lbR] : na, offset = -lbR, title = 'Regular Bearish Hist', linewidth = 2, color = histBearCond ? bearColor : noneColor)

plotshape(histBearCond ? hist[lbR] : na, offset = -lbR, title = 'Regular Bearish Hist Label', text = ' Bear Hist ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0))

//------------------------------------------------------------------------------
// Hidden Bearish (Histogram) - Corrected variable name
// Hist: Higher High
histOscHH = hist[lbR] > ta.valuewhen(histPhFound, hist[lbR], 1) and _inRange(histPhFound[1])
// Price: Lower High
histPriceLH = high[lbR] < ta.valuewhen(histPhFound, high[lbR], 1)
histHiddenBearCond = plotHiddenBear and histPriceLH and histOscHH and histPhFound

plot(histPhFound ? hist[lbR] : na, offset = -lbR, title = 'Hidden Bearish Hist', linewidth = 2, color = histHiddenBearCond ? hiddenBearColor : noneColor)

plotshape(histHiddenBearCond ? hist[lbR] : na, offset = -lbR, title = 'Hidden Bearish Hist Label', text = ' H Bear Hist ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0))


// Alert Conditions
alertcondition(bullCond, title = 'Bull MACD', message = 'Regular Bull Div MACD {{ticker}} XXmin')
alertcondition(bearCond, title = 'Bear MACD', message = 'Regular Bear Div MACD {{ticker}} XXmin')
alertcondition(hiddenBullCond, title = 'H Bull MACD', message = 'Hidden Bull Div MACD {{ticker}} XXmin')
alertcondition(hiddenBearCond, title = 'H Bear MACD', message = 'Hidden Bear Div MACD {{ticker}} XXmin')

alertcondition(histBullCond, title = 'Bull Hist', message = 'Regular Bull Div Histogram {{ticker}} XXmin')
alertcondition(histBearCond, title = 'Bear Hist', message = 'Regular Bear Div Histogram {{ticker}} XXmin')
alertcondition(histHiddenBullCond, title = 'H Bull Hist', message = 'Hidden Bull Div Histogram {{ticker}} XXmin')
alertcondition(histHiddenBearCond, title = 'H Bear Hist', message = 'Hidden Bear Div Histogram {{ticker}} XXmin')
````
