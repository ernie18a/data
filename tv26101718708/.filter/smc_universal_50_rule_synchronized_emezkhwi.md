# SMC Universal + 50% Rule [SYNCHRONIZED]

- url: https://www.tradingview.com/script/eMeZkHwi-SMC-Universal-50-Rule-SYNCHRONIZED/
- type: indicator
- pine_id: PUB;44508bfb59c74ffeaf8443f605335c96
- version: 1.0

## Description

Here's everything you need for the TradingView publication:

---

## **Title**
`SMC Universal + 50% Rule [Weekly Anchored]`

---

## **Short Description** *(shown in search results — keep under 150 chars)*
Smart Money levels anchored to Weekly pivots: ITH, ITL, and the 50% Equilibrium zone — with A+ momentum confirmation signals.

---

## **Full Description**

---

### SMC Universal + 50% Rule — Weekly Anchored

This indicator applies **Smart Money Concepts (SMC)** structure to any chart by anchoring pivot detection to a higher timeframe (default: Weekly). It identifies the most recent **Intermediate Term High (ITH)** and **Intermediate Term Low (ITL)**, then plots the **50% Equilibrium (EQ)** — the price level that separates buyers from sellers within that swing.

---

#### How It Works

**1. Higher-Timeframe Pivot Anchoring**
Pivots are calculated natively on the Weekly timeframe (configurable), not on the chart's current resolution. This ensures the ITH and ITL reflect meaningful swing structure — not noise — regardless of whether you're viewing a 5-minute or daily chart.

**2. ITH — Intermediate Term High**
The most recent confirmed Weekly pivot high. Acts as a structural resistance and the upper boundary of the current swing range.

**3. ITL — Intermediate Term Low**
The most recent confirmed Weekly pivot low. Acts as structural support and the lower boundary of the swing range.

**4. EQ — 50% Equilibrium**
The exact midpoint between ITH and ITL. In Smart Money theory, this is the *fair value* zone — where institutions re-enter in the direction of the prevailing trend. Price often reverses sharply at EQ or consolidates before continuing.

**5. A+ Momentum Entry Signals**
Overlaid on the structure are volume-confirmed EMA crossover signals:
- 🔺 **Long Signal** — price crosses above the 9 EMA with volume > 2× the 20-period average
- 🔻 **Short Signal** — price crosses below the 9 EMA with volume > 2× the 20-period average

These filter out low-conviction moves and highlight only breakouts with institutional participation.

---

#### How to Use It

- **Trend Context**: If price is above EQ, bias is bullish. Below EQ, bias is bearish.
- **Entries near EQ**: Look for momentum signals (triangles) firing at or near the EQ level — that's your highest-probability SMC entry.
- **ITH / ITL as targets**: Use ITH as the bull target, ITL as the bear target.
- **Multi-timeframe alignment**: Switch the anchor to Daily or Monthly for different swing contexts.

---

#### Settings

| Parameter | Default | Description |
|---|---|---|
| Anchor Timeframe | Weekly | Timeframe used to detect ITH/ITL pivots |
| Pivot Left Strength | 3 | Bars to the left of the pivot required |
| Pivot Right Strength | 3 | Bars to the right of the pivot required |
| ITH Color | Red | Color of the ITH line and label |
| ITL Color | Teal | Color of the ITL line and label |
| EQ Color | Yellow | Color of the 50% midline |

---

#### Notes
- All lines extend right with labels so they're always visible at the current bar — no hunting for levels buried on the left.
- The `lookahead_on` setting on the security call is intentional — it anchors the *confirmed* pivot to the current chart bar for clean visual alignment.
- Works on all markets: equities, indices (Nifty, BankNifty), forex, crypto.

---

**Tags to add when publishing:**
`smart-money`, `smc`, `pivot`, `50-percent-rule`, `equilibrium`, `multi-timeframe`, `weekly`, `ith`, `itl`, `structure`, `momentum`, `volume`, `nifty`, `swing-trading`

## Source Code

````pine
//@version=6
indicator("SMC Universal + 50% Rule [SYNCHRONIZED]", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── 1. INPUTS ──────────────────────────────────────────────────────────────
grp_mtf     = "Timeframe Anchoring"
tf_anchor   = input.timeframe("W", "Anchor Timeframe (Weekly Recommended)", group=grp_mtf)

grp_struct  = "50% Rule Structure"
leftBars    = input.int(3,        "Pivot Left Strength", group=grp_struct)
rightBars   = input.int(3,        "Pivot Right Strength", group=grp_struct)
ithColor    = input.color(color.red,    "ITH Color", group=grp_struct)
itlColor    = input.color(color.teal,   "ITL Color", group=grp_struct)
eqColor     = input.color(color.yellow, "EQ50 Color", group=grp_struct)

// ─── 2. CALCULATE PIVOTS ON ANCHOR TIMEFRAME ────────────────────────────────
// We calculate the pivots inside the security call to ensure the logic 
// (3 bars left/right) is applied to the Weekly bars, not the Daily ones.
[mtfITH, mtfITL] = request.security(syminfo.tickerid, tf_anchor, [ta.pivothigh(high, leftBars, rightBars), ta.pivotlow(low, leftBars, rightBars)], lookahead=barmerge.lookahead_on)

// ─── 3. PERMANENT MEMORY ────────────────────────────────────────────────────
var float lastITH = na
var float lastITL = na

if not na(mtfITH)
    lastITH := mtfITH
if not na(mtfITL)
    lastITL := mtfITL

// ─── 4. DRAWING OBJECTS (ITH / ITL / EQ) ────────────────────────────────────
var line ithLine = line.new(na, na, na, na, color=ithColor, width=2)
var line itlLine = line.new(na, na, na, na, color=itlColor, width=2)
var line eqLine  = line.new(na, na, na, na, color=eqColor,  width=2, style=line.style_dotted)

// Larger labels with price details
var label ithLabel = label.new(na, na, "", color=ithColor, textcolor=color.white, style=label.style_label_left, size=size.normal)
var label itlLabel = label.new(na, na, "", color=itlColor, textcolor=color.white, style=label.style_label_left, size=size.normal)
var label eqLabel  = label.new(na, na, "", color=eqColor,  textcolor=color.black, style=label.style_label_left, size=size.normal)

// ─── 5. SYNCHRONIZE VISUALS ─────────────────────────────────────────────────
if barstate.islast
    // Update ITH
    if not na(lastITH)
        line.set_xy1(ithLine, bar_index[500], lastITH)
        line.set_xy2(ithLine, bar_index + 12,  lastITH)
        label.set_xy(ithLabel, bar_index + 13, lastITH)
        label.set_text(ithLabel, "ITH: " + str.tostring(lastITH, "#.##"))

    // Update ITL
    if not na(lastITL)
        line.set_xy1(itlLine, bar_index[500], lastITL)
        line.set_xy2(itlLine, bar_index + 12,  lastITL)
        label.set_xy(itlLabel, bar_index + 13, lastITL)
        label.set_text(itlLabel, "ITL: " + str.tostring(lastITL, "#.##"))

    // Update EQ
    if not na(lastITH) and not na(lastITL)
        eqVal = (lastITH + lastITL) / 2
        line.set_xy1(eqLine, bar_index[500], eqVal)
        line.set_xy2(eqLine, bar_index + 12,  eqVal)
        label.set_xy(eqLabel, bar_index + 13, eqVal)
        label.set_text(eqLabel, "EQ: " + str.tostring(eqVal, "#.##"))

// ─── 6. MOMENTUM SIGNALS (A+) ────────────────────────────────────────────────
ema_f = ta.ema(close, 9)
v_ma = ta.sma(volume, 20)
long_signal  = ta.crossover(close, ema_f) and volume > v_ma * 2.0
short_signal = ta.crossunder(close, ema_f) and volume > v_ma * 2.0

plotshape(long_signal,  location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(short_signal, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)
````
