# Breakout with text box Tubbsie

- url: https://www.tradingview.com/script/2we6K4Gp-Breakout-with-text-box-Tubbsie/
- type: indicator
- pine_id: PUB;eaa0bfe108e8436e8149a932bfc79bf6
- version: 1.0

## Description

### 0DTE Breakout Framework (SPY / QQQ) – EMA Pullbacks + Bias Box

Built specifically for **SPY & QQQ 0DTE options traders**, this indicator focuses on one objective:

> **Catch clean trend continuation moves while avoiding chop and emotional trades.**

It combines EMA structure, precise pullbacks, and real-time market context into a simple, rules-based execution framework.

---

### 🔥 What This Is Designed For

* 0DTE scalps and intraday momentum trades
* EMA pullback entries (9 / 13 / 48 structure)
* Staying aligned with **real directional bias**
* Avoiding **low-quality chop conditions (where accounts get destroyed)**

---

### ⚡ Core Edge

Most traders lose on 0DTE because they:

* Trade inside ranges
* Chase extended moves
* Ignore key levels
* Fight the trend

This script directly solves those problems.

---

### 📊 Entry Signals (Clean, Rule-Based)

**Green = A+ Setup (Take These)**

* Strong trend alignment (9 > 13 > 200 for calls / inverse for puts)
* Tight pullback into the 9 EMA
* Designed for high-probability continuation moves

**Orange = A Setup**

* Same structure, slightly looser pullback
* Still valid, but less precise

**Blue = 48 EMA Continuation**

* Price reacting at the 48 EMA within trend
* Ideal for secondary entries or add-ons

All signals are:

* Filtered to **regular US market hours (9:30–16:00 EST)**
* Distance-based (prevents chasing)

---

### 🧠 The Real Weapon: Dynamic Bias Box

This is what separates the script from typical EMA indicators.

A live decision panel tells you exactly how to behave:

**Directional Bias**

* ✅ *“Calls Only above PMH”*
* 🔻 *“Puts Only below PML”*
* ⚠️ *“No trades – wait for EMA alignment”*

**Chop Zone Detection (Account Saver)**

* Warns when price is stuck inside premarket range
* → This is where most 0DTE losses happen

**Key Level Warnings**

* Alerts when EMAs are near:

  * 200 EMA (major reaction zone)
  * Previous Day High/Low
  * Premarket High/Low

➡️ You’re not just getting entries — you’re getting **context before you click buy**.

---

### 🎯 How to Use (Simple Rules)

* Only take **Green/Orange signals in direction of bias**
* Prioritise trades **outside the Chop Zone**
* Be cautious when warnings are active
* Avoid trading when EMAs are not cleanly stacked

---

### ⚙️ Fully Customisable

* Toggle signal types on/off
* Adjust pullback distance thresholds
* Customise EMA colours
* Modify all bias/warning text
* Move and style the status box

---

### 💡 Trading Philosophy

This tool is built for disciplined 0DTE traders:

> **You don’t need more trades — you need better conditions.**

It helps you:

* Stay patient
* Trade with structure
* Avoid emotional entries
* Focus only on high-quality setups

---

## Source Code

````pine
//@version=5
indicator("Breakout with text box Tubbsie", overlay=true)

// ═══════════════════════════════════════════════════════════
// 0. USER INPUTS
// ═══════════════════════════════════════════════════════════
grpEMA     = "EMA Settings"
grpSignals = "Signal Display & Thresholds"
grpBox     = "Status Box Settings"
grpLevels  = "Key Level Proximity Alerts"

// --- EMA Colours ---
p_e9   = input.color(color.gray,   "9 EMA Color",   inline="ema_9",   group=grpEMA)
p_e13  = input.color(color.yellow, "13 EMA Color",  inline="ema_13",  group=grpEMA)
p_e48  = input.color(color.blue,   "48 EMA Color",  inline="ema_48",  group=grpEMA)
p_e200 = input.color(color.red,    "200 EMA Color", inline="ema_200", group=grpEMA)

// --- Signal Controls ---
showOrange = input.bool(true, "Show Orange (9 EMA)",      group=grpSignals, inline="O_S")
showGreen  = input.bool(true, "Show Green (9 EMA)",       group=grpSignals, inline="G_S")
showBlue   = input.bool(true, "Show Blue (48 EMA Check)", group=grpSignals, inline="B_S")

// --- Signal Thresholds ---
thresh_OG = input.float(0.0005, "Orange % (e.g., 0.0005 = 0.05%)", group=grpSignals)
thresh_G  = input.float(0.0004, "Green % (e.g., 0.0004 = 0.04%)",  group=grpSignals)
thresh_B  = input.float(0.0003, "Blue % (e.g., 0.0003 = 0.03%)",   group=grpSignals)

// --- Status Box Settings ---
boxFontSize    = input.string("20", "Font Size",
  options      = ["8","10","12","14","16","18","20","24","28","32","36","40"],
  group        = grpBox)
callsText      = input.string("Calls Only above PMH", "'Calls Only above PMH' Text",  group=grpBox)
putsText       = input.string("Puts Only below PML",  "'Puts Only below PML' Text",   group=grpBox)
czText         = input.string("Danger - No trading in CZ. IBKR off!", "'CZ' Warning Text", group=grpBox)
callsColor     = input.color(color.green,   "Calls Text Color",   group=grpBox)
putsColor      = input.color(color.red,     "Puts Text Color",    group=grpBox)
warnColor      = input.color(color.orange,  "Warning Text Color", group=grpBox)
czColor        = input.color(color.yellow,  "CZ Warning Color",   group=grpBox)
boxBgColor     = input.color(color.new(color.black, 20), "Box Background Color", group=grpBox)
boxBorderColor = input.color(color.gray,    "Box Border Color",   group=grpBox)
boxPosition    = input.string("Bottom Center", "Box Position",
  options      = ["Top Left","Top Center","Top Right",
                  "Middle Left","Middle Center","Middle Right",
                  "Bottom Left","Bottom Center","Bottom Right"],
  group        = grpBox)
crossThresh    = input.float(0.08, "EMA/200 Cross Proximity %",
  group   = grpBox, minval=0.01, maxval=1.0, step=0.01,
  tooltip = "Alert when 13 or 48 EMA is within this % of the 200 EMA")

// --- Key Level Proximity Alerts ---
thresh13_PDH = input.float(0.08, "13 EMA near Prev Day High/Low %",
  group=grpLevels, minval=0.01, maxval=2.0, step=0.01)
thresh48_PDH = input.float(0.08, "48 EMA near Prev Day High/Low %",
  group=grpLevels, minval=0.01, maxval=2.0, step=0.01)
thresh13_PMH = input.float(0.08, "13 EMA near Premarket High/Low %",
  group=grpLevels, minval=0.01, maxval=2.0, step=0.01)
thresh48_PMH = input.float(0.08, "48 EMA near Premarket High/Low %",
  group=grpLevels, minval=0.01, maxval=2.0, step=0.01)


// ═══════════════════════════════════════════════════════════
// 1. CALCULATE EMAs
// ═══════════════════════════════════════════════════════════
e9   = ta.ema(close, 9)
e13  = ta.ema(close, 13)
e48  = ta.ema(close, 48)
e200 = ta.ema(close, 200)


// ═══════════════════════════════════════════════════════════
// 2. PLOT EMAs
// ═══════════════════════════════════════════════════════════
plot(e9,   "9 EMA",   p_e9,   2)
plot(e13,  "13 EMA",  p_e13,  2)
plot(e48,  "48 EMA",  p_e48,  2)
plot(e200, "200 EMA", p_e200, 2)


// ═══════════════════════════════════════════════════════════
// 3. 13/48 CROSSOVER LABELS
// ═══════════════════════════════════════════════════════════
xUp = ta.crossover(e13, e48)
xDn = ta.crossunder(e13, e48)

if xUp or xDn
    label.new(bar_index, high, "X",
      color     = xUp ? color.green : color.red,
      textcolor = color.black,
      style     = xUp ? label.style_label_down : label.style_label_up,
      size      = size.large,
      yloc      = xUp ? yloc.abovebar : yloc.belowbar)


// ═══════════════════════════════════════════════════════════
// 4. 13/200 CROSS SHAPE
// ═══════════════════════════════════════════════════════════
plotshape(ta.cross(e13, e200), "13x200", shape.cross, location.belowbar, color.green, size=size.small)


// ═══════════════════════════════════════════════════════════
// 5. SESSION FLAGS
// ═══════════════════════════════════════════════════════════
inSession   = not na(time(timeframe.period, "0930-1600", "America/New_York"))
inPremarket = not na(time(timeframe.period, "0401-0929", "America/New_York"))


// ═══════════════════════════════════════════════════════════
// 6. SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════
dist9       = math.abs(close - e9) / e9
bearAligned = e9 < e13 and e13 < e200
bullAligned = e9 > e13 and e13 > e200
signalP     = inSession and bearAligned and close > open
signalC     = inSession and bullAligned and close < open

dist48    = math.abs(close - e48) / e48
dist48_OK = dist48 <= thresh_B


// ═══════════════════════════════════════════════════════════
// 7. PLOT SIGNALS
// ═══════════════════════════════════════════════════════════
plotchar(series=showOrange and signalP and dist9 <= thresh_OG,
  title="Orange P", char='P', location=location.belowbar, color=color.orange, size=size.tiny)
plotchar(series=showOrange and signalC and dist9 <= thresh_OG,
  title="Orange C", char='C', location=location.abovebar, color=color.orange, size=size.tiny)

plotchar(series=showGreen and signalP and dist9 <= thresh_G,
  title="Green P", char='P', location=location.belowbar, color=color.green, size=size.tiny)
plotchar(series=showGreen and signalC and dist9 <= thresh_G,
  title="Green C", char='C', location=location.abovebar, color=color.green, size=size.tiny)

blueP_condition = inSession and dist48_OK and e13 < e48 and close > open and e48 < e200
plotchar(series=showBlue and blueP_condition,
  title="Blue P", char='P', location=location.belowbar, color=color.blue, size=size.tiny)

blueC_condition = inSession and dist48_OK and e13 > e48 and close < open and e48 > e200
plotchar(series=showBlue and blueC_condition,
  title="Blue C", char='C', location=location.abovebar, color=color.blue, size=size.tiny)


// ═══════════════════════════════════════════════════════════
// 8. PRIOR DAY HIGH / LOW
// ═══════════════════════════════════════════════════════════
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)


// ═══════════════════════════════════════════════════════════
// 9. PREMARKET HIGH / LOW  (04:01–09:29 America/New_York)
// ═══════════════════════════════════════════════════════════
var float pmHigh      = na
var float pmLow       = na
var float pmHighLatch = na
var float pmLowLatch  = na
var int   lastDayNum  = na

currentDayNum = na(time) ? na : dayofmonth(time)

if not na(currentDayNum)
    if na(lastDayNum) or currentDayNum != lastDayNum
        pmHigh      := na
        pmLow       := na
        pmHighLatch := na
        pmLowLatch  := na
        lastDayNum  := currentDayNum

if inPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow,  low)

if inSession
    pmHighLatch := na(pmHigh) ? pmHighLatch : pmHigh
    pmLowLatch  := na(pmLow)  ? pmLowLatch  : pmLow


// ═══════════════════════════════════════════════════════════
// 10. HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════
f_textSize(s) =>
    switch s
        "8"  => size.tiny
        "10" => size.tiny
        "12" => size.small
        "14" => size.small
        "16" => size.normal
        "18" => size.normal
        "20" => size.large
        "24" => size.large
        "28" => size.huge
        "32" => size.huge
        "36" => size.huge
        "40" => size.huge
        =>      size.large

f_position(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.bottom_center

f_near(ema, level, pct) =>
    not na(ema) and not na(level) and level != 0.0 and (math.abs(ema - level) / level) <= (pct / 100.0)


// ═══════════════════════════════════════════════════════════
// 11. BUILD WARNING LINES
// ═══════════════════════════════════════════════════════════

// CZ detection — price inside premarket range during session
bool inCZ = inSession and not na(pmHighLatch) and not na(pmLowLatch) and close >= pmLowLatch and close <= pmHighLatch

// 200 EMA proximity
pctThresh200 = crossThresh / 100.0
near13_200   = not na(e200) and (math.abs(e13 - e200) / e200) <= pctThresh200
near48_200   = not na(e200) and (math.abs(e48 - e200) / e200) <= pctThresh200

w200  = near13_200 and near48_200 ? "⚠ 13 & 48 EMA near 200 EMA" : near13_200 ? "⚠ 13 EMA near 200 EMA" : near48_200 ? "⚠ 48 EMA near 200 EMA" : ""

// Prior Day High / Low
n13_pdh = f_near(e13, pdHigh, thresh13_PDH)
n13_pdl = f_near(e13, pdLow,  thresh13_PDH)
n48_pdh = f_near(e48, pdHigh, thresh48_PDH)
n48_pdl = f_near(e48, pdLow,  thresh48_PDH)

wPD13 = n13_pdh and n13_pdl ? "⚠ 13 EMA near Prev Day H & L" : n13_pdh ? "⚠ 13 EMA near Prev Day High" : n13_pdl ? "⚠ 13 EMA near Prev Day Low" : ""
wPD48 = n48_pdh and n48_pdl ? "⚠ 48 EMA near Prev Day H & L" : n48_pdh ? "⚠ 48 EMA near Prev Day High" : n48_pdl ? "⚠ 48 EMA near Prev Day Low" : ""

// Premarket High / Low
n13_pmh = f_near(e13, pmHighLatch, thresh13_PMH)
n13_pml = f_near(e13, pmLowLatch,  thresh13_PMH)
n48_pmh = f_near(e48, pmHighLatch, thresh48_PMH)
n48_pml = f_near(e48, pmLowLatch,  thresh48_PMH)

wPM13 = n13_pmh and n13_pml ? "⚠ 13 EMA near PM High & Low" : n13_pmh ? "⚠ 13 EMA near PM High" : n13_pml ? "⚠ 13 EMA near PM Low" : ""
wPM48 = n48_pmh and n48_pml ? "⚠ 48 EMA near PM High & Low" : n48_pmh ? "⚠ 48 EMA near PM High" : n48_pml ? "⚠ 48 EMA near PM Low" : ""

bool ema13_between = (e13 > e48 and e13 < e200) or (e13 < e48 and e13 > e200)
biasText  = ema13_between ? "No trades. Wait for EMAs to stack" : e13 > e48 ? callsText : putsText
biasColor = ema13_between ? warnColor : e13 > e48 ? callsColor : putsColor
txtSize   = f_textSize(boxFontSize)


// ═══════════════════════════════════════════════════════════
// 12. STATUS BOX TABLE — only renders populated rows
// ═══════════════════════════════════════════════════════════
var table statusBox = table.new(
  position     = position.bottom_center,
  columns      = 1,
  rows         = 7,
  bgcolor      = boxBgColor,
  border_color = boxBorderColor,
  border_width = 1,
  frame_color  = boxBorderColor,
  frame_width  = 1)

if barstate.islast or barstate.isrealtime
    table.set_position(statusBox, f_position(boxPosition))

    // Build arrays of only non-empty lines and their matching colours
    activeLines  = array.new_string()
    activeColors = array.new_color()
    activeSizes  = array.new_string()

    // CZ warning — only added when price is inside the CZ
    if inCZ
        array.push(activeLines,  czText)
        array.push(activeColors, czColor)
        array.push(activeSizes,  "bias")

    // Bias line — always shown
    array.push(activeLines,  biasText)
    array.push(activeColors, biasColor)
    array.push(activeSizes,  "bias")

    // Warning lines — only added when non-empty
    warnLines = array.from(w200, wPD13, wPD48, wPM13, wPM48)
    for i = 0 to 4
        w = array.get(warnLines, i)
        if w != ""
            array.push(activeLines,  w)
            array.push(activeColors, warnColor)
            array.push(activeSizes,  "warn")

    // Write populated rows; blank out any stale rows from prior bars
    for r = 0 to 6
        if r < array.size(activeLines)
            isBiasRow = array.get(activeSizes, r) == "bias"
            table.cell(statusBox, 0, r,
              text       = array.get(activeLines,  r),
              text_color = array.get(activeColors, r),
              text_size  = isBiasRow ? txtSize : size.normal,
              bgcolor    = color.new(color.black, 100))
        else
            table.cell(statusBox, 0, r,
              text    = "",
              bgcolor = color.new(color.black, 100))
````
