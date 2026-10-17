# Liquidity Sweep Detector [Proozac]

- url: https://www.tradingview.com/script/NeyBE7oU-Liquidity-Sweep-Detector-Proozac/
- type: indicator
- pine_id: PUB;8fd2d080049d4c759dfcbeea9d9e7ea7
- version: 1.0

## Description

# Liquidity Sweep Detector

**Pine Script v6 — Overlay Indicator**

---

## What It Does

Detects two related concepts from institutional liquidity theory:

1. **Equal Highs / Equal Lows (EQH / EQL)** — price levels where the market reached the same high or low on two separate occasions. These levels concentrate retail stop orders (buy stops above EQH, sell stops below EQL) and act as magnets for institutional order flow.

2. **Liquidity Sweep** — when price breaks through an EQH or EQL with a wick but *closes back on the opposite side*. This is the signal that institutions triggered the stops, absorbed that liquidity, and are now positioned in the opposite direction — the classic "stop hunt" or "liquidity grab."

---

## Detection Logic

### Equal Highs / Equal Lows

```
EQH: two pivot highs within a configurable % tolerance of each other
EQL: two pivot lows  within a configurable % tolerance of each other
```

The indicator finds swing highs and lows via `ta.pivothigh` / `ta.pivotlow`. For each new pivot it compares against the 5 most recent ones. If the relative difference is within the `Equal Level Tolerance %` threshold, a dashed line is drawn between the two points and labelled `EQH` or `EQL`.

### Bullish Sweep (long signal)

```
wick_low < EQL  AND  close > EQL  AND  open > EQL
```

The wick pierces below an equal low but the candle body closes above it. Price swept the sell stops and snapped back — potential bullish reversal.

### Bearish Sweep (short signal)

```
wick_high > EQH  AND  close < EQH  AND  open < EQH
```

The wick pierces above an equal high but the candle body closes below it. Price swept the buy stops and snapped back — potential bearish reversal.

---

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| **Swing Length (Pivot)** | 10 | Bars required on each side to confirm a swing. Higher = fewer but more reliable pivots |
| **Equal Level Tolerance %** | 0.1 | Percentage margin for two pivots to be considered "equal". Increase for volatile assets |
| **Max Lookback for Equal Levels** | 50 | How far back to search for matching pivot levels |
| **Equal Highs Line Color** | Red | Color for EQH lines |
| **Equal Lows Line Color** | Green | Color for EQL lines |
| **Bearish Sweep Color** | Bright Red | Color for bearish sweep signal and candle |
| **Bullish Sweep Color** | Bright Green | Color for bullish sweep signal and candle |
| **Show Equal Level Lines** | true | Toggle EQH/EQL lines on/off |
| **Show Sweep Signals** | true | Toggle triangle signals on/off |
| **Show Sweep Labels** | true | Toggle "BULL SWEEP" / "BEAR SWEEP" labels on/off |

---

## Visual Signals

| Element | Description |
|---------|-------------|
| Red dashed line + "EQH" label | Liquidity pool at highs |
| Green dashed line + "EQL" label | Liquidity pool at lows |
| Green triangle below bar + label | Bullish sweep detected (potential long entry) |
| Red triangle above bar + label | Bearish sweep detected (potential short entry) |
| Candle color change | The sweep candle is highlighted in the signal color |

---

## How to Use

**Basic setup:**
1. Add to any chart (works best on 15m, 1H, 4H timeframes).
2. Look for confluence: a sweep on an EQL that also sits on a demand zone or Order Block produces the highest-conviction signals.
3. Enter on the candle after the sweep, stop below the sweep candle's wick low (bullish) or above the wick high (bearish).

**Setting up alerts:**
Three `alertcondition` entries are built in and ready to use:
- `Bullish Liquidity Sweep`
- `Bearish Liquidity Sweep`
- `Any Liquidity Sweep`

In TradingView: Alerts → Condition → select the indicator → choose the desired alert type.

---

## Configuration Tips

| Asset type | Recommended tolerance |
|---|---|
| Forex majors | 0.05 – 0.1 % |
| Crypto (BTC/ETH) | 0.2 – 0.5 % |
| Futures / indices | 0.05 – 0.15 % |

- A higher `Swing Length` (15–20) produces fewer, more confirmed signals. A lower value (5–7) is more reactive but generates more false positives.
- EQH/EQL lines do not extend into the future — they naturally disappear once swept, which is exactly the point of interest.

---

## Conceptual Background

Based on the **ICT (Inner Circle Trader)** and **Smart Money Concepts** framework: large operators need liquidity to fill their positions. Equal highs and equal lows are the zones where retail stop orders accumulate. The institutional player pushes price into those levels, harvests the liquidity, then reverses — that reversal move is the entry opportunity.

This is different from a breakout strategy. A sweep signal is *not* a breakout confirmation — it is a **failed breakout** that indicates smart money is positioned against the breakout direction.

## Source Code

````pine
//@version=6
// Liquidity Sweep Detector — Equal Highs/Lows + Stop Hunt Signals
indicator("Liquidity Sweep Detector", shorttitle="Liq. Sweep", overlay=true, max_lines_count=500, max_labels_count=300)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Detection"
swing_len   = input.int(10,   "Swing Length (Pivot)", group=g1, minval=3, maxval=50)
eq_thresh   = input.float(0.1, "Equal Level Tolerance %", group=g1, minval=0.01, maxval=2.0, step=0.01)
lookback    = input.int(50,   "Max Lookback for Equal Levels", group=g1, minval=10, maxval=200)

g2 = "Colors"
eqh_col     = input.color(color.new(#ef5350, 0), "Equal Highs Line", group=g2)
eql_col     = input.color(color.new(#26a69a, 0), "Equal Lows Line", group=g2)
sweep_h_col = input.color(#FF5252, "Bearish Sweep (High Sweep)", group=g2)
sweep_l_col = input.color(#69F0AE, "Bullish Sweep (Low Sweep)", group=g2)

g3 = "Display"
show_eq     = input.bool(true, "Show Equal Level Lines", group=g3)
show_sweep  = input.bool(true, "Show Sweep Signals", group=g3)
show_labels = input.bool(true, "Show Sweep Labels", group=g3)

// ── Pivot Detection ───────────────────────────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

var float[] ph_vals = array.new_float()
var int[]   ph_bars = array.new_int()
var float[] pl_vals = array.new_float()
var int[]   pl_bars = array.new_int()

if not na(ph)
    array.unshift(ph_vals, ph)
    array.unshift(ph_bars, bar_index - swing_len)
    if array.size(ph_vals) > lookback
        array.pop(ph_vals)
        array.pop(ph_bars)

if not na(pl)
    array.unshift(pl_vals, pl)
    array.unshift(pl_bars, bar_index - swing_len)
    if array.size(pl_vals) > lookback
        array.pop(pl_vals)
        array.pop(pl_bars)

// ── Equal Highs / Equal Lows ──────────────────────────────────────────────────
tol = eq_thresh / 100.0

if show_eq and not na(ph) and array.size(ph_vals) >= 2
    current_ph  = array.get(ph_vals, 0)
    current_bar = array.get(ph_bars, 0)
    for i = 1 to math.min(array.size(ph_vals) - 1, 5)
        prev_ph  = array.get(ph_vals, i)
        prev_bar = array.get(ph_bars, i)
        if math.abs(current_ph - prev_ph) / prev_ph <= tol
            line.new(prev_bar, prev_ph, current_bar, current_ph, color=eqh_col, style=line.style_dashed, width=1)
            label.new(current_bar, current_ph, "EQH", style=label.style_label_down, size=size.tiny, color=color.new(eqh_col, 40), textcolor=color.white)
            break

if show_eq and not na(pl) and array.size(pl_vals) >= 2
    current_pl  = array.get(pl_vals, 0)
    current_bar = array.get(pl_bars, 0)
    for i = 1 to math.min(array.size(pl_vals) - 1, 5)
        prev_pl  = array.get(pl_vals, i)
        prev_bar = array.get(pl_bars, i)
        if math.abs(current_pl - prev_pl) / prev_pl <= tol
            line.new(prev_bar, prev_pl, current_bar, current_pl, color=eql_col, style=line.style_dashed, width=1)
            label.new(current_bar, current_pl, "EQL", style=label.style_label_up, size=size.tiny, color=color.new(eql_col, 40), textcolor=color.white)
            break

// ── Sweep Detection ───────────────────────────────────────────────────────────
var bool bull_sweep = false
var bool bear_sweep = false

bull_sweep := false
bear_sweep := false

if show_sweep and array.size(pl_vals) >= 2
    for i = 0 to math.min(array.size(pl_vals) - 1, lookback - 1)
        liq_low = array.get(pl_vals, i)
        if low < liq_low and close > liq_low and open > liq_low
            bull_sweep := true
            break

if show_sweep and array.size(ph_vals) >= 2
    for i = 0 to math.min(array.size(ph_vals) - 1, lookback - 1)
        liq_high = array.get(ph_vals, i)
        if high > liq_high and close < liq_high and open < liq_high
            bear_sweep := true
            break

// ── Plot Signals ──────────────────────────────────────────────────────────────
plotshape(bull_sweep, "Bull Sweep", shape.triangleup,   location.belowbar, sweep_l_col, size=size.normal)
plotshape(bear_sweep, "Bear Sweep", shape.triangledown, location.abovebar, sweep_h_col, size=size.normal)

if show_labels and bull_sweep
    label.new(bar_index, low, "BULL\nSWEEP", style=label.style_label_up, color=color.new(sweep_l_col, 30), textcolor=color.black, size=size.small)

if show_labels and bear_sweep
    label.new(bar_index, high, "BEAR\nSWEEP", style=label.style_label_down, color=color.new(sweep_h_col, 30), textcolor=color.white, size=size.small)

barcolor(bull_sweep ? sweep_l_col : bear_sweep ? sweep_h_col : na, title="Sweep Candle Color")

alertcondition(bull_sweep, "Bullish Liquidity Sweep", "{{ticker}} — Bullish liquidity sweep detected on {{interval}}")
alertcondition(bear_sweep, "Bearish Liquidity Sweep", "{{ticker}} — Bearish liquidity sweep detected on {{interval}}")
alertcondition(bull_sweep or bear_sweep, "Any Liquidity Sweep", "{{ticker}} — Liquidity sweep detected on {{interval}}")
````
