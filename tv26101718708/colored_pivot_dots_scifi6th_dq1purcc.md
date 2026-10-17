# Colored Pivot Dots - Scifi6th

- url: https://www.tradingview.com/script/Dq1pURCc-Colored-Pivot-Dots-Scifi6th/
- type: indicator
- pine_id: PUB;cf39b72146aa421d9d894456d8bb20b5
- version: 1.0

## Description

# Colored Pivot Dots

## Overview

**Colored Pivot Dots** is a clean, minimalist swing structure indicator that marks pivot highs and pivot lows directly on the price chart using colored dots. Instead of cluttering the chart with lines or labels, it uses a single dot placed precisely at each swing point — color-coded to instantly reveal whether price structure is strengthening or weakening.

The indicator uses an **alternating zigzag logic**: it always enforces a strict HIGH → LOW → HIGH sequence. If two consecutive pivot highs are detected without a pivot low in between, only the more significant one is kept. This eliminates noise and ensures every dot on the chart is meaningful.

---

## How It Works

### Pivot Detection
Pivot highs and lows are detected using a configurable **Pivot Length** parameter. A pivot high is a candle whose high is higher than the `n` candles on both sides; a pivot low is the inverse. The default value is **1**, which captures every local swing and is well-suited for supply & demand zone analysis.

### Color Logic
Each dot is colored based on a comparison with the **previous pivot of the same type**:

| Dot | Condition | Default Color |
|-----|-----------|---------------|
| Pivot High | Higher High (HH) — high > previous pivot high | 🟢 Green |
| Pivot High | Lower High (LH) — high < previous pivot high | 🔴 Red |
| Pivot Low | Higher Low (HL) — low > previous pivot low | 🟢 Green |
| Pivot Low | Lower Low (LL) — low < previous pivot low | 🔴 Red |

At a glance: **green dots signal a strengthening structure** (HH + HL), **red dots signal a weakening structure** (LH + LL). Mixed colors highlight transitional or corrective phases.

---

## Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| Pivot Length | 1 | Number of bars on each side required to confirm a pivot |
| Dot Offset | 0.0015 | Vertical distance between the candle tip and the dot |
| Higher High color | Green | Color for pivot highs above the previous pivot high |
| Lower High color | Red | Color for pivot highs below the previous pivot high |
| Higher Low color | Green | Color for pivot lows above the previous pivot low |
| Lower Low color | Red | Color for pivot lows below the previous pivot low |
| Higher High shape | ● | Marker shape for Higher Highs |
| Lower High shape | ● | Marker shape for Lower Highs |
| Higher Low shape | ● | Marker shape for Higher Lows |
| Lower Low shape | ● | Marker shape for Lower Lows |
| Size | Large | Dot size (tiny / small / normal / large / huge) |

All colors and shapes are fully customizable independently for each of the four pivot types, allowing you to build a visual language that fits your trading style.

---

## Use Cases

- **Trend identification** — a sequence of green dots (HH + HL) confirms an uptrend; red dots (LH + LL) confirm a downtrend
- **Supply & demand analysis** — quickly spot where price made a significant high or low and whether structure was broken
- **Confluence marking** — combine with zone-based indicators to validate entries at key structural levels
- **Multi-timeframe context** — works on any timeframe; use higher Pivot Length values on lower timeframes to filter noise

---

## Notes

- The indicator uses `label.new()` for rendering, which ensures dots are placed precisely on the pivot candle regardless of the pivot length setting
- Maximum of 500 labels are displayed (TradingView platform limit)
- The **Dot Offset** parameter uses price units — adjust it based on the instrument and timeframe you are trading (e.g. a larger offset may be needed on higher-priced instruments or volatile pairs)
- Works on all instruments and timeframes

## Source Code

````pine

//@version=6
indicator("Colored Pivot Dots - Scifi6th", overlay=true, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
pivotLen        = input.int(1,             "Pivot Length",          minval=1)
dotOffset       = input.float(0.0015,      "Dot Offset",            minval=0.0, step=0.0001, tooltip="Distance between the candle tip and the dot")

colorHH         = input.color(color.green, "Higher High color",     group="Colors")
colorLH         = input.color(color.red,   "Lower High color",      group="Colors")
colorHL         = input.color(color.green, "Higher Low color",      group="Colors")
colorLL         = input.color(color.red,   "Lower Low color",       group="Colors")

shapeHH         = input.string("●",        "Higher High shape",     group="Shapes", options=["●", "▲", "▼", "■", "◆", "✦", "+", "x"])
shapeLH         = input.string("●",        "Lower High shape",      group="Shapes", options=["●", "▲", "▼", "■", "◆", "✦", "+", "x"])
shapeHL         = input.string("●",        "Higher Low shape",      group="Shapes", options=["●", "▲", "▼", "■", "◆", "✦", "+", "x"])
shapeLL         = input.string("●",        "Lower Low shape",       group="Shapes", options=["●", "▲", "▼", "■", "◆", "✦", "+", "x"])

dotSize         = input.string("large",    "Size",                  options=["tiny", "small", "normal", "large", "huge"])

// ─── SIZE CONVERSION ──────────────────────────────────────────────────────────
f_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.large

sz = f_size(dotSize)

// ─── PIVOT DETECTION ──────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow (low,  pivotLen, pivotLen)

// ─── ALTERNATING ZIGZAG LOGIC ─────────────────────────────────────────────────
var int   lastType    = 0
var float lastPHval   = na
var float lastPLval   = na
var float lastPivotPH = na
var float lastPivotPL = na
var label lastPHlabel = na
var label lastPLlabel = na

f_drawPH(barIdx, val, prevVal) =>
    color  c = (not na(prevVal)) ? (val >= prevVal ? colorHH : colorLH) : colorLH
    string s = (not na(prevVal)) ? (val >= prevVal ? shapeHH : shapeLH) : shapeLH
    label.new(x=barIdx, y=val + dotOffset, text=s, style=label.style_none,
              textcolor=c, size=sz, yloc=yloc.price)

f_drawPL(barIdx, val, prevVal) =>
    color  c = (not na(prevVal)) ? (val > prevVal ? colorHL : colorLL) : colorLL
    string s = (not na(prevVal)) ? (val > prevVal ? shapeHL : shapeLL) : shapeLL
    label.new(x=barIdx, y=val - dotOffset, text=s, style=label.style_none,
              textcolor=c, size=sz, yloc=yloc.price)

if not na(ph)
    phBar = bar_index - pivotLen
    if lastType != 1
        lastPHlabel := f_drawPH(phBar, ph, lastPivotPH)
        lastPivotPH := ph
        lastType    := 1
        lastPHval   := ph
    else
        if ph > lastPHval
            label.delete(lastPHlabel)
            lastPHlabel := f_drawPH(phBar, ph, lastPivotPH)
            lastPivotPH := ph
            lastPHval   := ph

if not na(pl)
    plBar = bar_index - pivotLen
    if lastType != -1
        lastPLlabel := f_drawPL(plBar, pl, lastPivotPL)
        lastPivotPL := pl
        lastType    := -1
        lastPLval   := pl
    else
        if pl < lastPLval
            label.delete(lastPLlabel)
            lastPLlabel := f_drawPL(plBar, pl, lastPivotPL)
            lastPivotPL := pl
            lastPLval   := pl
````
