<!-- tradingview-pine-id: PUB;79b44917761b4e85a642f4f5d63d8e2c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Open Basis 

Source: https://www.tradingview.com/script/GD8c6TQz-Open-Basis/

## Description

This indicator tracks and evaluates institutional market direction by analyzing the relative price hierarchy of **three key session open times** (configured in Central Time):

### 1. The Three Session Anchors

* **5:00 PM CT (Globex Open):** Marks the start of the new global trading day and resets the cycle. Plotted as a pink/magenta line.
* **11:00 PM CT (MNO / Midnight ET):** Captures the structural shift into the late-night session. Plotted as a white line.
* **8:30 AM CT (New York Cash Open):** The primary cash session open (9:30 AM ET). Plotted as a yellow line.

---

### 2. The Scoring & Trend Logic

At the exact moment the **8:30 AM CT** open prints, the indicator compares the three prices to determine market bias:

* **Bulls Strong (`Score = +2`):** Triggered when prices step cleanly upward across the sessions ($5\text{pm} < 11\text{pm} < 8:30\text{am}$). This indicates strong, structured upward momentum.
* **Bears Strong (`Score = -2`):** Triggered when prices step cleanly downward across the sessions ($5\text{pm} > 11\text{pm} > 8:30\text{am}$). This indicates sustained downward pressure.
* **Mixed / No Edge (`Score = 0`):** Triggered when the levels overlap or do not form a clean sequential hierarchy, signaling a choppy or rotational environment.

---

### 3. Chart Visuals

* **Right-Margin Labels:** Small text tags sit at the far right edge of your chart next to each respective line (`5:00pm CT`, `11:00pm CT`, `8:30am CT`) so you can instantly identify them without tracing across the screen.
* **NY Open Event Label:** At 8:30 AM CT, a detailed text box prints on the chart displaying the final bias (`Bulls Strong`, `Bears Strong`, or `Mixed`) along with the exact fractional price of each open.
* **Alerts:** Built-in alert conditions trigger automatically at the NY Open to notify you whether market structure is trending or mixed.

---

## Source Code

````pine
//@version=6
indicator("Open Basis ", overlay=true, max_labels_count=500)

// ---------- Inputs ----------
tz        = input.string("America/Chicago", "Timezone (Lee’s Summit = America/Chicago)")
ltf       = input.timeframe("1", "Lower TF for exact opens (recommended: 1)")
showLines = input.bool(true, "Plot 5pm / 11pm / 8:30am open levels")
showLabel = input.bool(true, "Show label at 8:30am CT (NY Open)")
showBG    = input.bool(false, "Background tint after NY Open")

// Anchor times in YOUR CT
// 5:00pm CT = Globex open
// 11:00pm CT = “MNO” (midnight ET)
// 8:30am CT = NY cash open (9:30am ET)
G_H = 17, G_M = 0
M_H = 23, M_M = 0
N_H = 8 , N_M = 30

// ---------- Persistent state ----------
var float globexOpen = na
var float mnoOpen    = na
var float nyOpen     = na
var int   score      = na          // +2 bulls strong, -2 bears strong, else mixed
var bool  nyEvent    = false       // true on the bar that CONTAINS 8:30am CT (works on any TF)

// ---------- Pull lower-TF intrabar data so opens are exact on any chart TF ----------
arr_t = request.security_lower_tf(syminfo.tickerid, ltf, time)
arr_o = request.security_lower_tf(syminfo.tickerid, ltf, open)

nyEvent := false

// Walk through the lower-TF bars inside the current bar and capture anchor opens.
if array.size(arr_t) > 0
    for i = 0 to array.size(arr_t) - 1
        t = array.get(arr_t, i)
        o = array.get(arr_o, i)

        hr = hour(t, tz)
        mn = minute(t, tz)

        // 5:00pm CT (Globex) resets the "cycle"
        if (hr == G_H and mn == G_M)
            globexOpen := o
            mnoOpen    := na
            nyOpen     := na
            score      := na

        // 11:00pm CT (MNO)
        if (hr == M_H and mn == M_M)
            mnoOpen := o

        // 8:30am CT (NY cash open) + score
        if (hr == N_H and mn == N_M)
            nyOpen := o
            if not na(globexOpen) and not na(mnoOpen) and not na(nyOpen)
                s1 = mnoOpen > globexOpen ? 1 : -1
                s2 = nyOpen  > mnoOpen    ? 1 : -1
                score := s1 + s2
            nyEvent := true

// ---------- Interpret score ----------
bullStrong = (score == 2)
bearStrong = (score == -2)
mixed      = (score == 0 or na(score))

// ---------- Plot levels ----------
plot(showLines ? globexOpen : na, "5:00pm CT (Globex Open)", color=#E91E63, style=plot.style_linebr, linewidth=2)
plot(showLines ? mnoOpen    : na, "11:00pm CT (MNO)",        color=color.white, style=plot.style_linebr, linewidth=2)
plot(showLines ? nyOpen     : na, "8:30am CT (NY Open)",     color=color.yellow, style=plot.style_linebr, linewidth=2)

// ---------- Right-Side Small Labels ----------
// Initialize with real coordinates (0) to prevent render failure, then push 3 bars into the future margin
var label lblGlobex = label.new(bar_index, 0, "5:00pm open", color=color.new(color.white, 100), textcolor=#E91E63, style=label.style_label_left, size=size.small)
var label lblMNO    = label.new(bar_index, 0, "midnight open", color=color.new(color.white, 100), textcolor=color.white, style=label.style_label_left, size=size.small)
var label lblNY     = label.new(bar_index, 0, "NY Open", color=color.new(color.white, 100), textcolor=color.yellow, style=label.style_label_left, size=size.small)

if barstate.islast and showLines
    if not na(globexOpen)
        label.set_xy(lblGlobex, bar_index + 3, globexOpen)
    if not na(mnoOpen)
        label.set_xy(lblMNO, bar_index + 3, mnoOpen)
    if not na(nyOpen)
        label.set_xy(lblNY, bar_index + 3, nyOpen)

// ---------- Label at NY Open ----------
if showLabel and nyEvent and not na(globexOpen) and not na(mnoOpen) and not na(nyOpen)
    txt = 
         bullStrong ? "NY OPEN: BULLS STRONG\n(5pm < 11pm < 8:30)" :
         bearStrong ? "NY OPEN: BEARS STRONG\n(5pm > 11pm > 8:30)" :
                      "NY OPEN: MIXED / NO EDGE\n(hierarchy not clean)"
    
    txt += "\n5pm: " + str.tostring(globexOpen, format.mintick)
    txt += "\n11pm: " + str.tostring(mnoOpen, format.mintick)
    txt += "\n8:30: " + str.tostring(nyOpen, format.mintick)

    label.new(bar_index, nyOpen, txt, style=label.style_label_down, textalign=text.align_left)

// ---------- Optional background after NY Open (until next 5pm reset) ----------
var int regime = 0  // 1 bull, -1 bear, 0 neutral
if nyEvent
    regime := bullStrong ? 1 : bearStrong ? -1 : 0

if not na(globexOpen) and array.size(arr_t) > 0
    if na(score) and na(mnoOpen) and na(nyOpen)
        regime := 0

bgcolor(showBG ? (regime == 1 ? color.new(color.green, 90) : regime == -1 ? color.new(color.red, 90) : na) : na)

// ---------- Alerts ----------
alertcondition(nyEvent and bullStrong, "NY Open — Bulls Strong", "Nash 3-Open: Bulls strong at NY Open (CT).")
alertcondition(nyEvent and bearStrong, "NY Open — Bears Strong", "Nash 3-Open: Bears strong at NY Open (CT).")
alertcondition(nyEvent and mixed,      "NY Open — Mixed",       "Nash 3-Open: Mixed / no clean hierarchy at NY Open (CT).")
````
