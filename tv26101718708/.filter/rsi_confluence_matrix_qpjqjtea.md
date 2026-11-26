# RSI Confluence Matrix

- url: https://www.tradingview.com/script/QPJQJtea-RSI-Confluence-Matrix/
- type: indicator
- pine_id: PUB;2b658ae525fc45e6bb0b26d9d164433e
- version: 1.0

## Description

**RSI Confluence Matrix**

A structured, multi-layer confirmation indicator designed to identify high-probability trade setups by combining momentum, exhaustion, and higher timeframe trend alignment.

---

### 🔍 Core Concept

This tool is built around a simple idea:

> **Trades are only valid when momentum shift aligns with broader trend direction.**

Instead of relying on a single signal, the RSI Confluence Matrix stacks three independent conditions:

---

### ⚙️ How It Works

**1. RSI Exhaustion (Setup Phase)**

* Detects when RSI reaches extreme levels:

  * Below 30 (oversold)
  * Above 70 (overbought)
* Requires this condition to occur **twice**, filtering out weak or premature signals.

**2. Momentum Shift (Trigger Phase)**

* Confirms direction using the RSI 50 level:

  * Cross above 50 → bullish shift
  * Cross below 50 → bearish shift

**3. Multi-Timeframe Trend Alignment (Filter Phase)**

* Tracks price position relative to the **EMA 200** across:

  * 4H, 2H, 1H, 45M, 30M, 15M
* Each timeframe is classified as:

  * **Green** → price above EMA 200
  * **Red** → price below EMA 200

A valid trade requires **at least 5 timeframes aligned** in the same direction.

---

### 🟢 Signal Conditions

**BUY Setup**

* RSI crosses below 30 twice
* RSI crosses above 50
* At least 5 timeframes above EMA 200 (Green)

**SELL Setup**

* RSI crosses above 70 twice
* RSI crosses below 50
* At least 5 timeframes below EMA 200 (Red)

---

### 📊 Table Overview

The built-in matrix displays real-time trend alignment:

* Each column represents a timeframe
* Color-coded bias (Green / Red)
* Final column shows dominant direction:

  * Majority Green → Bullish bias
  * Majority Red → Bearish bias
  * Equal → Neutral (No Trade)

---

### 🎯 How to Use

* Focus only on signals that align with the matrix bias
* Avoid trades when the table shows mixed or neutral conditions
* Best used in conjunction with key levels (structure, pivots, liquidity zones)

---

### ⚠️ Notes

* This indicator is designed to **filter noise and reduce low-quality trades**, not to increase trade frequency
* Signals may be less frequent but are intended to offer stronger confirmation
* This tool does not guarantee outcomes; proper risk management is essential

---

### 🤖 Development Note

This indicator includes enhancements developed with the assistance of AI to improve structure, clarity, and efficiency of the underlying logic.

## Source Code

````pine
//@version=6
indicator("RSI Confluence Matrix", overlay=true, max_labels_count=500)

//==================== INPUTS ====================
rsiLen = input.int(14, "RSI Length")
rsiTF  = input.timeframe("", "RSI Timeframe")

showRSI50Color = input.bool(true, "RSI 50 Candle Color")
showRSI30 = input.bool(true, "RSI 30 Labels")
showRSI70 = input.bool(true, "RSI 70 Labels")
showDiv = input.bool(true, "RSI Divergence")

maxLabels = input.int(50, "Max Labels")

// Channel inputs
length1 = input.int(20, "Upper Channel")
length2 = input.int(20, "Lower Channel")

// Bollinger
bbLen = input.int(20, "BB Length")
bbMult = input.float(1.5, "BB Mult")

// EMA TF inputs
ema9_tf  = input.timeframe("", "EMA 9 HTF")
ema21_tf = input.timeframe("", "EMA 21 HTF")
ema50_tf = input.timeframe("", "EMA 50 HTF")

//==================== CHANNEL ====================
upper = ta.highest(high, length1)
lower = ta.lowest(low, length2)
basis = (upper + lower) / 2

plot(upper, color=color.fuchsia, style=plot.style_circles, linewidth=2, title="Upper Channel")
plot(lower, color=color.fuchsia, style=plot.style_circles, linewidth=2, title="Lower Channel")

//==================== BOLLINGER ====================
bbDev = bbMult * ta.stdev(close, bbLen)
bbUpper = basis + bbDev
bbLower = basis - bbDev

p1 = plot(bbUpper, color=color.blue, title="BB Upper")
p2 = plot(bbLower, color=color.blue, title="BB Lower")
fill(p1, p2, color=color.new(color.blue, 90))

//==================== RSI ====================
float rsi = na
if rsiTF == ""
    rsi := ta.rsi(close, rsiLen)
else
    rsi := request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen))

// RSI 50 coloring
barcolor(showRSI50Color and ta.crossover(rsi, 50) ? color.blue : na)
barcolor(showRSI50Color and ta.crossunder(rsi, 50) ? color.orange : na)

//==================== RSI LEVELS ====================
crossUp30 = ta.crossover(rsi, 30)
crossDown30 = ta.crossunder(rsi, 30)
crossUp70 = ta.crossover(rsi, 70)
crossDown70 = ta.crossunder(rsi, 70)

//==================== LABEL ARRAYS ====================
var label[] rsi30Labels = array.new_label()
var label[] rsi70Labels = array.new_label()
var label[] divLabels   = array.new_label()

f_clean(arr) =>
    if array.size(arr) > maxLabels
        label.delete(array.shift(arr))

// RSI 30
if showRSI30 and crossUp30
    l = label.new(bar_index, low, "30", style=label.style_label_up, size=size.tiny, color=color.green)
    array.push(rsi30Labels, l)
    f_clean(rsi30Labels)

if showRSI30 and crossDown30
    l = label.new(bar_index, high, "30", style=label.style_label_down, size=size.tiny, color=color.red)
    array.push(rsi30Labels, l)
    f_clean(rsi30Labels)

// RSI 70
if showRSI70 and crossUp70
    l = label.new(bar_index, low, "70", style=label.style_label_up, size=size.tiny, color=color.green)
    array.push(rsi70Labels, l)
    f_clean(rsi70Labels)

if showRSI70 and crossDown70
    l = label.new(bar_index, high, "70", style=label.style_label_down, size=size.tiny, color=color.red)
    array.push(rsi70Labels, l)
    f_clean(rsi70Labels)

//==================== DIVERGENCE ====================
left = 5
right = 5

ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

rsi_ph = ta.pivothigh(rsi, left, right)
rsi_pl = ta.pivotlow(rsi, left, right)

bearDiv = not na(ph) and not na(rsi_ph) and high[right] > high[right+left] and rsi[right] < rsi[right+left]
bullDiv = not na(pl) and not na(rsi_pl) and low[right] < low[right+left] and rsi[right] > rsi[right+left]

if showDiv and bearDiv
    l = label.new(bar_index-right, high[right], "Div", style=label.style_label_down, size=size.tiny, color=color.red)
    array.push(divLabels, l)
    f_clean(divLabels)

if showDiv and bullDiv
    l = label.new(bar_index-right, low[right], "Div", style=label.style_label_up, size=size.tiny, color=color.green)
    array.push(divLabels, l)
    f_clean(divLabels)

//==================== PIVOTS ====================
plot(ph, style=plot.style_cross, color=color.red, offset=-right, title="Pivot High")
plot(pl, style=plot.style_cross, color=color.green, offset=-right, title="Pivot Low")

//==================== EMA ====================
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)

float ema9_htf = na
float ema21_htf = na
float ema50_htf = na

if ema9_tf != ""
    ema9_htf := request.security(syminfo.tickerid, ema9_tf, ta.ema(close, 9))
if ema21_tf != ""
    ema21_htf := request.security(syminfo.tickerid, ema21_tf, ta.ema(close, 21))
if ema50_tf != ""
    ema50_htf := request.security(syminfo.tickerid, ema50_tf, ta.ema(close, 50))

plot(ema9, color=color.yellow)
plot(ema21, color=color.orange)
plot(ema50, color=color.red)

plot(ema9_htf, color=color.new(color.yellow, 60))
plot(ema21_htf, color=color.new(color.orange, 60))
plot(ema50_htf, color=color.new(color.red, 60))

//==================== MTF EMA 200 TABLE ====================
emaLen = 200

getTrend(tf) =>
    ema_tf = request.security(syminfo.tickerid, tf, ta.ema(close, emaLen))
    close_tf = request.security(syminfo.tickerid, tf, close)
    close_tf > ema_tf ? 1 : -1

t4h  = getTrend("240")
t2h  = getTrend("120")
t1h  = getTrend("60")
t45m = getTrend("45")
t30m = getTrend("30")
t15m = getTrend("15")

greenCount = (t4h == 1 ? 1 : 0) + (t2h == 1 ? 1 : 0) + (t1h == 1 ? 1 : 0) + (t45m == 1 ? 1 : 0) + (t30m == 1 ? 1 : 0) + (t15m == 1 ? 1 : 0)
redCount   = (t4h == -1 ? 1 : 0) + (t2h == -1 ? 1 : 0) + (t1h == -1 ? 1 : 0) + (t45m == -1 ? 1 : 0) + (t30m == -1 ? 1 : 0) + (t15m == -1 ? 1 : 0)

trendText = greenCount > redCount ? str.tostring(greenCount) + " GREEN" : redCount > greenCount ? str.tostring(redCount) + " RED" : "NOTR"

trendColor = greenCount > redCount ? color.green : redCount > greenCount ? color.red : color.gray

f_cell(val) =>
    val == 1 ? color.new(color.green, 0) : color.new(color.red, 0)

// Create table
var table t = table.new(position.top_right, 7, 2, border_width=1)

// Header row
if barstate.islast
    table.cell(t, 0, 0, "4H")
    table.cell(t, 1, 0, "2H")
    table.cell(t, 2, 0, "1H")
    table.cell(t, 3, 0, "45M")
    table.cell(t, 4, 0, "30M")
    table.cell(t, 5, 0, "15M")
    table.cell(t, 6, 0, "TOTAL")

    // TF values
    table.cell(t, 0, 1, "", bgcolor=f_cell(t4h))
    table.cell(t, 1, 1, "", bgcolor=f_cell(t2h))
    table.cell(t, 2, 1, "", bgcolor=f_cell(t1h))
    table.cell(t, 3, 1, "", bgcolor=f_cell(t45m))
    table.cell(t, 4, 1, "", bgcolor=f_cell(t30m))
    table.cell(t, 5, 1, "", bgcolor=f_cell(t15m))

    // Total
    table.cell(t, 6, 1, trendText, bgcolor=trendColor, text_color=color.white)

//==================== RSI SEQUENCE LOGIC ====================

// Count touches
var int below30_count = 0
var int above70_count = 0

// Reset logic when opposite side triggers
if ta.crossover(rsi, 70)
    below30_count := 0

if ta.crossunder(rsi, 30)
    above70_count := 0

// Count events
if ta.crossunder(rsi, 30)
    below30_count += 1

if ta.crossover(rsi, 70)
    above70_count += 1

//==================== ENTRY CONDITIONS ====================

// MTF filter (from your table)
strongBull = greenCount >= 5
strongBear = redCount >= 5

// Final triggers
longSignal  = below30_count >= 2 and ta.crossover(rsi, 50) and strongBull
shortSignal = above70_count >= 2 and ta.crossunder(rsi, 50) and strongBear

// Reset after trigger to avoid spam
if longSignal
    below30_count := 0

if shortSignal
    above70_count := 0

//==================== SIGNAL LABELS ====================
if longSignal
    label.new(bar_index, low, "BUY", style=label.style_label_up, size=size.small, color=color.green, textcolor=color.white)

if shortSignal
    label.new(bar_index, high, "SELL", style=label.style_label_down, size=size.small, color=color.red, textcolor=color.white)
````
