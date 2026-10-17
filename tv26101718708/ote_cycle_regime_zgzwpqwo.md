# OTE Cycle Regime

- url: https://www.tradingview.com/script/ZgZwPQwO-OTE-Cycle-Regime/
- type: indicator
- pine_id: PUB;9f88b1fc6d4749b8a1f57a8b5700881b
- version: 1.0

## Description

[b]Rest in Peace Veryfid. 
[/b]---

[b]Cycle Regime (Ehlers Dominant Cycle)
[/b]
[i]Measures the market's dominant cycle length and flags whether it's compressing or expanding.
[/i]
---


[b]**What it does**
[/b]
Cycle Regime plots a single, clean estimate of the market's current **dominant cycle period** — how many bars one full up-down rhythm is currently taking — and classifies it against its own recent baseline into three states:

- 🟢 **Compression** — the cycle is shorter than usual; price is coiling / oscillating tightly.
- 🔴 **Expansion** — the cycle is longer than usual; swings are stretching out (often a trend maturing).
- ⚪ **Neutral** — the cycle is near its typical length; no strong reading.

The current state is shown as a colored line, an optional background tint during compression, and a status label reading e.g. `COMPRESSION · 23b (base 49)`.
[b]
**The math**[/b]

Under the hood this is John Ehlers' **homodyne (in-phase / quadrature) dominant-cycle measurement**. Price is detrended and smoothed, a quadrature (90°-shifted) copy is built via a Hilbert-transform approximation, and the per-bar phase advance between the two is converted into a cycle period ( period = 2π / phase-rate ), then median-filtered and smoothed for stability.

It is a distillation of the open-source **"Tesla Coil"** indicator: I kept only the single robust cycle estimator and replaced the original's fixed reference level with a self-scaling baseline (the rolling median of the period), so the regime adapts to any symbol or timeframe without manual tuning.

[b]**How to read it**
[/b]
- Watch the **color**, not just the level. A rising line into red = the market is trending/stretching. A falling line into green = it's compressing/coiling.
- The **baseline** (gray line) is the median cycle length over the lookback window — the line's own "normal." Regime is always relative to that, so a "compression" on a fast asset and a slow one mean the same thing structurally.
- It describes **rhythm and volatility state, not direction.** It never tells you up or down — pair it with your own structure, trend, or entry method.

[b]**Settings**
[/b]
- **Source** — price input (default close).
- **Baseline window** — bars used for the median baseline (default 40).
- **Expansion / Compression thresholds** — how far above/below baseline triggers each state (default 1.10× / 0.90×).
- **Colors, baseline visibility, background highlight** — all optional.

Alerts fire when the cycle enters compression or expansion.

**How I use it**

I treat cycle state as a **context filter**, not a signal. It's most useful applied on your higher timeframe to judge *when* your setups are worth taking versus when the market is in a state you'd rather avoid — a modifier on decisions your own method already made, not a standalone buy/sell.

[b]**Credits**
[/b]
Built on Ehlers' instantaneous-frequency / homodyne cycle work and distilled from the open-source "Tesla Coil" indicator by **veryfid** (with contributions by DasanC and KryptoBeau). Published open-source under MPL-2.0.

**Disclaimer**

For research and education only. This is not financial advice and makes no claim about future performance. Cycle measurements are inherently lagging and smoothed — always confirm with your own analysis and risk management.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// OTE Cycle Regime — the useful kernel of the "Tesla Coil" (veryfid/DasanC/Ehlers),
// stripped to a single dominant-cycle line + regime classifier. Mirrors
// src/cycle.js in the Kraken OTE Finder scanner, so the chart matches the score.
//
// COMPRESSION (tight/coiling cycles) is the edge for OTE retracement entries —
// price coiling in the POI backtested +0.38 avgR vs expansion -0.32 (180d, 9 pairs).
// Apply on your HTF (H4 for the default H4->M15 scan) to match the scanner's regime.

//@version=6
indicator('OTE Cycle Regime', 'Cycle Regime', overlay = false)

// ---------- Inputs ----------
src = input.source(close, 'Source')
lookback = input.int(40, 'Baseline window (bars)', minval = 5)
expandMult = input.float(1.10, 'Expansion threshold x', step = 0.01)
compressMult = input.float(0.90, 'Compression threshold x', step = 0.01)
showBaseline = input.bool(true, 'Show baseline')
bgOn = input.bool(true, 'Highlight compression on background')

g_col = 'Colors'
colComp = input.color(color.teal, 'Compression (edge)', group = g_col)
colExp = input.color(color.red, 'Expansion', group = g_col)
colNeu = input.color(color.gray, 'Neutral', group = g_col)

// ---------- Ehlers homodyne dominant-cycle (matches src/cycle.js) ----------
alpha = 0.1
Cycle = 0.0
Q1 = 0.0
I1 = 0.0
DeltaPhase = 0.0
DC = 0.0
InstPeriod = 0.0
Period = 0.0

Smooth = (src + 2 * src[1] + 2 * src[2] + src[3]) / 6
c1 = (1 - 0.5 * alpha) * (1 - 0.5 * alpha)
c3 = (1 - alpha) * (1 - alpha)
Cycle := c1 * (Smooth - 2 * Smooth[1] + Smooth[2]) + 2 * (1 - alpha) * nz(Cycle[1]) - c3 * nz(Cycle[2])
if bar_index < 7
    Cycle := (src - 2 * src[1] + src[2]) / 4
    Cycle

Q1 := (0.0962 * Cycle + 0.5769 * Cycle[2] - 0.5769 * Cycle[4] - 0.0962 * Cycle[6]) * (0.5 + 0.08 * nz(InstPeriod[1]))
I1 := Cycle[3]
if Q1 != 0 and Q1[1] != 0
    DeltaPhase := (I1 / Q1 - I1[1] / Q1[1]) / (1 + I1 * I1[1] / (Q1 * Q1[1]))
    DeltaPhase
if DeltaPhase < 0.1
    DeltaPhase := 0.1
    DeltaPhase
if DeltaPhase > 1.1
    DeltaPhase := 1.1
    DeltaPhase

MedianDelta = ta.percentile_nearest_rank(DeltaPhase, 5, 50)
DC := MedianDelta == 0 ? 15.0 : 6.28318 / MedianDelta + 0.5
InstPeriod := 0.33 * DC + 0.67 * nz(InstPeriod[1])
Period := 0.15 * InstPeriod + 0.85 * nz(Period[1])
periodBars = math.round(Period)

// ---------- Regime vs rolling-median baseline ----------
baseline = ta.percentile_nearest_rank(periodBars, lookback, 50)
isComp = baseline > 0 and periodBars <= baseline * compressMult
isExp = baseline > 0 and periodBars >= baseline * expandMult
regimeCol = isComp ? colComp : isExp ? colExp : colNeu
regimeTxt = isComp ? 'COMPRESSION' : isExp ? 'EXPANSION' : 'NEUTRAL'

// ---------- Plots ----------
plot(periodBars, 'Cycle period', color = regimeCol, linewidth = 2)
plot(showBaseline ? baseline : na, 'Baseline', color = color.new(color.gray, 40))
bgcolor(bgOn and isComp ? color.new(colComp, 88) : na, title = 'Compression zone')

// ---------- Status table ----------
var table t = table.new(position.top_right, 1, 2, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, regimeTxt, text_color = color.white, bgcolor = color.new(regimeCol, 20), text_size = size.small)
    table.cell(t, 0, 1, str.tostring(periodBars) + 'b  (base ' + str.tostring(baseline) + ')', text_color = color.white, bgcolor = color.new(color.gray, 60), text_size = size.small)

// ---------- Alerts ----------
alertcondition(isComp and not isComp[1], 'Entered compression', 'OTE Cycle Regime: entered COMPRESSION (coiling — the edge)')
alertcondition(isExp and not isExp[1], 'Entered expansion', 'OTE Cycle Regime: entered EXPANSION')
````
