# Ergodicity Overlay

- url: https://www.tradingview.com/script/POTtoDft/
- type: indicator
- pine_id: PUB;e8bdcf1e5197414d917e7aa418f983aa
- version: 1.0

## Description

# Ergodicity Overlay 
 
## What is Ergodicity?
 
In probability theory, a process is called **ergodic** when its time average converges to its ensemble average. In plain terms: if you observe a single asset long enough, the average return you measure should match the long-run statistical mean of the process.
 
When this condition breaks down — when the two averages diverge — the asset is behaving **non-ergodically**. This matters enormously in finance: standard tools like Sharpe ratio, expected value, and mean-reversion strategies all implicitly assume ergodicity. When that assumption fails, those tools can give dangerously misleading signals.

## How This Indicator Works
 
The indicator compares two different estimates of the mean log-return:
 
- **Spatial mean (expanding)** — the cumulative average of all log-returns from the beginning of history. This is the best available estimate of the process's long-run mean.
- **Temporal mean (rolling)** — the simple moving average of log-returns over a fixed window (default: 252 days). This captures the recent drift of the asset.
At every bar, it computes the divergence:
 
```
diff = temporal_mean − spatial_mean
```
 
This signal is then compared against a **dynamic threshold**:
 
```
threshold = k × σ_expanding(diff)
```
 
where `σ_expanding(diff)` is the expanding standard deviation of the diff series itself, computed using Welford's numerically stable algorithm.
 
When `|diff| > threshold`, the asset is classified as **non-ergodic**: its recent drift has statistically departed from its long-run mean in a way that cannot be attributed to normal fluctuation.

## Visualization
 
All signals are plotted **directly on the price chart** (overlay mode):
 
| Element | Description |
|---|---|
| 🔴 **Red bars** | Every candle in a non-ergodic regime is highlighted in red |
| 🔴 **Dots above candles** | Small circles above each non-ergodic bar |
| 🏷️ **Regime labels** | `▼ NON-ERGODIC` when entering, `▲ ERGODIC` when exiting |
| 📋 **Info table** | Live display of regime status, threshold, σ(diff), % non-ergodic days, current diff in bps |


🧭 Practical Use Cases
1. Regime Detection
- Identify when market assumptions break

2. Strategy Switching
- Mean-reversion → use in ergodic regime
- Trend-following → use in non-ergodic regime

3. Risk Management
- Non-ergodic periods = higher model risk

4. Market Diagnostics
- Compare assets by % non-ergodic time

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vittorio_pavesi

// ═══════════════════════════════════════════════════════════════════════════
// ERGODICITY OVERLAY 
//
// ═══════════════════════════════════════════════════════════════════════════
//@version=6
indicator(
     title         = "Ergodicity Overlay",
     shorttitle    = "Ergodicity",
     overlay       = true,
     max_labels_count = 500,
     max_bars_back    = 5000)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
var string G1 = "⚙️ Parameters"
window      = input.int  (252, "Rolling window (days)",  minval=20, maxval=1000, group=G1)
k_sigma     = input.float(2.0, "Multiplier k (×σ_diff)",
                               minval=0.5, step=0.25,
                               tooltip="thresh = k · σ_expanding(diff)\n"
                                     + "k=2.0 → ≈95° percentile |diff|\n"
                                     + "k=1.96 → test formale 95% CI",
                               group=G1)
warmup_mult = input.int  (2,   "Warm-up (× window)",
                               minval=1, maxval=10,
                               tooltip="Excludes first N×window bars from count. Waits for σ(diff) to converge.Default=2 → 504 bars (≈2 years daily)",
                               group=G1)

var string G2 = "🎨 Visualization"
show_barclr = input.bool(true,  "Color bars (non-ergodic = red)",  group=G2)
show_dots   = input.bool(true,  "Dots above candles (non-ergodic)",  group=G2)
show_labels = input.bool(true,  "Regime change labels",              group=G2)
show_bg     = input.bool(false, "Semi-transparent background",          group=G2)
dot_offset  = input.int (3,     "Dot distance from high (%)", minval=1, maxval=20, group=G2)
col_nonerg  = input.color(#FF3B3B, "Non-ergodic color", group=G2)
col_erg     = input.color(#00C853, "Ergodic color",     group=G2)

// ─── LOG RETURN ──────────────────────────────────────────────────────────────
log_ret = math.log(close / close[1])

// ─── MEDIA SPAZIALE (expanding mean) ─────────────────────────────────────────
var float lr_sum = 0.0
var int   lr_n   = 0
if not na(log_ret)
    lr_sum += log_ret
    lr_n   += 1
spatial_mean = lr_n > 0 ? lr_sum / lr_n : na

// ─── MEDIA TEMPORALE (rolling SMA) ───────────────────────────────────────────
temporal_mean = ta.sma(log_ret, window)

// ─── DIFF ────────────────────────────────────────────────────────────────────
diff = not na(temporal_mean) and not na(spatial_mean)
       ? temporal_mean - spatial_mean : na

// ─── EXPANDING STD OF DIFF (Welford — numerically stable) ──────────────────
var float d_m  = 0.0   // media running
var float d_M2 = 0.0   // somma scarti quadratici
var int   d_n  = 0

if not na(diff)
    d_n   += 1
    float delta  = diff - d_m
    d_m   += delta / d_n
    float delta2 = diff - d_m
    d_M2  += delta * delta2

// Population std (like numpy .std(ddof=0))
sigma_diff = d_n > 1 ? math.sqrt(d_M2 / d_n) : na

// ─── SOGLIA DINAMICA ─────────────────────────────────────────────────────────
thresh_dyn = not na(sigma_diff) ? k_sigma * sigma_diff : na

// ─── WARM-UP: threshold valid only after min_obs diff observations ───────────
min_obs     = window * warmup_mult        // default: 504 bar
warmed_up   = d_n >= min_obs             // bool: std stable enough

// ─── CLASSIFICAZIONE ─────────────────────────────────────────────────────────
// Classify all bars (for visualization)
is_non_erg     = warmed_up and not na(diff) and not na(thresh_dyn)
                 and math.abs(diff) > thresh_dyn

// Contatori: solo da warm-up in poi (per % corretta)
var int cnt_non_erg = 0
var int cnt_total   = 0
if warmed_up and not na(diff) and not na(thresh_dyn)
    cnt_total += 1
    if is_non_erg
        cnt_non_erg += 1
pct_non_erg = cnt_total > 0 ? cnt_non_erg / cnt_total * 100 : 0.0

// ─── CAMBIO REGIME ───────────────────────────────────────────────────────────
entered_non_erg = is_non_erg  and not is_non_erg[1]
exited_non_erg  = not is_non_erg and is_non_erg[1]

// ─── COLORAZIONE BARRE ───────────────────────────────────────────────────────
barcolor(show_barclr ? (is_non_erg ? col_nonerg : na) : na)

// ─── DOT SOPRA LE CANDELE ────────────────────────────────────────────────────
plotshape(
     show_dots and is_non_erg ? high * (1 + dot_offset / 100) : na,
     title="Non-ergodic event", style=shape.circle,
     location=location.absolute, color=col_nonerg, size=size.tiny)

// ─── BACKGROUND ──────────────────────────────────────────────────────────────
bgcolor(show_bg and is_non_erg ? color.new(col_nonerg, 90) : na)

// ─── LABEL CAMBIO REGIME ─────────────────────────────────────────────────────
if show_labels
    if entered_non_erg
        label.new(bar_index, high * 1.01,
             text="▼ NON\nERGODIC", color=color.new(col_nonerg, 20),
             textcolor=color.white, style=label.style_label_down, size=size.small)
    if exited_non_erg
        label.new(bar_index, low * 0.99,
             text="▲ ERGODIC", color=color.new(col_erg, 20),
             textcolor=color.white, style=label.style_label_up, size=size.small)

// ─── TABELLA STATO ────────────────────────────────────────────────────────────
var table tbl = table.new(
     position=position.top_right, columns=2, rows=8,
     bgcolor=color.new(#363a45, 23),
     border_color=color.new(color.gray, 60), border_width=1,
     frame_color=color.new(color.gray, 40),  frame_width=1)

if barstate.islast
    stato_str  = is_non_erg ? "NON-ERGODIC" : "ERGODIC"
    stato_col  = is_non_erg ? col_nonerg       : col_erg
    wu_str     = warmed_up  ? "✓ done (" + str.tostring(d_n) + ")" : "⏳ " + str.tostring(d_n) + "/" + str.tostring(min_obs)
    wu_col     = warmed_up  ? color.lime : color.orange

    table.cell(tbl, 0, 0, syminfo.tickerid,
               text_color=color.yellow, text_size=size.small,
               bgcolor=color.new(color.navy, 35), text_halign=text.align_left)
    table.cell(tbl, 1, 0, stato_str,
               text_color=stato_col, text_size=size.small,
               bgcolor=color.new(color.navy, 35), text_halign=text.align_right)

    table.cell(tbl, 0, 1, "Window", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(window) + " d",
               text_color=color.white, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "k (×σ_diff)", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(k_sigma, "#.##"),
               text_color=color.white, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "σ(diff) expanding", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 3,
               not na(sigma_diff)
               ? str.tostring(math.round(sigma_diff * 10000, 2)) + " bps" : "N/A",
               text_color=color.aqua, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 4, "Threshold (k·σ_diff)", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 4,
               not na(thresh_dyn)
               ? "±" + str.tostring(math.round(thresh_dyn * 10000, 2)) + " bps" : "N/A",
               text_color=color.orange, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 5, "Non-erg. days", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5,
               str.tostring(math.round(pct_non_erg, 1)) + "% (" + str.tostring(cnt_non_erg) + ")",
               text_color=color.orange, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 6, "Current diff.", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 6,
               not na(diff)
               ? str.tostring(math.round(diff * 10000, 2)) + " bps" : "N/A",
               text_color=is_non_erg ? col_nonerg : color.white,
               text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 7, "Warm-up", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 7, wu_str, text_color=wu_col, text_size=size.small, text_halign=text.align_right)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(entered_non_erg, title="→ NON-ERGODIC", message="{{ticker}} — NON-ERGODIC")
alertcondition(exited_non_erg,  title="→ ERGODIC",     message="{{ticker}} — ERGODIC")
alertcondition(is_non_erg,      title="NON-ERGODIC active", message="{{ticker}} — ongoing")
````
