# L-TPI Correlation Assets

- url: https://www.tradingview.com/script/VBBe4IOv-L-TPI-Correlation-Assets/
- type: indicator
- pine_id: PUB;8682a375ba2d4fbcbef9ad3babcb2ba0
- version: 1.0

## Description

# L-TPI Correlation Assets

A composite trend-probability indicator that scores the current asset's directional bias and **scales that score by its rolling correlation to Bitcoin (INDEX:BTCUSD)**. The result is a single weighted signal that strengthens when the asset is moving with BTC and fades toward neutral when the relationship breaks down.

---

## Concept

Most trend indicators tell you *what* an asset is doing. This one asks a second question: *how much does that signal matter right now, given the asset's relationship to the broader crypto market?*

The script does this in three stages:

1. **Trend Probability Index (TPI)** — a 4-filter composite that produces a normalized trend score in the range `[-1, +1]`.
2. **Multi-Period Correlation Weight** — a weighted average of the asset's price correlation to BTC across five lookback windows.
3. **Final Weighted Score** — the TPI multiplied by the correlation weight, with a configurable neutral zone around zero.

---

## 1. Trend Probability Index (TPI)

Four independent filters each cast a vote of `+1` (bullish) or `-1` (bearish):

| Filter | Logic | Bullish When |
|---|---|---|
| **f1 — ROC** | Rate of Change over *N* bars | ROC > 1 |
| **f2 — RSI** | Relative Strength Index | RSI > 50 |
| **f3 — EMA Cross** | Fast EMA vs. Slow EMA | Fast > Slow |
| **f4 — SMA** | Price vs. long SMA | Close > SMA |

- **Raw Trend Score** = `f1 + f2 + f3 + f4` → integer in `[-4, +4]`
- **Avg Trend Score** = `Raw / 4` → normalized to `[-1, +1]`

The Avg Trend Score is the TPI value passed forward.

---

## 2. Correlation Weight (vs. INDEX:BTCUSD)

The script computes the **Pearson correlation coefficient** between the chart asset's close and BTC's close across **five user-defined lookback windows** (default 30, 60, 90, 180, 365 bars). Each window has its own user weight (default 1, 2, 3, 4, 5 — favoring longer horizons).

For each window:

- Validity is checked: a window must have at least *Min valid obs ratio* (default 80%) of aligned, non-`na` bars.
- Invalid windows are excluded from the weighted average.

The final weight is a clamped weighted mean:

```
weight = clamp( Σ(corr_i × user_weight_i) / Σ(user_weight_i),  -1,  +1 )
```

BTC is fetched via `ticker.modify` so dividend/session adjustments on the chart propagate to the comparison series.

---

## 3. Final Weighted Score

```
final_weighted_score = avg_trend_score × weight
```

- **Range:** `[-1, +1]`
- **Strong bullish:** TPI is bullish *and* asset moves with BTC → score pushes toward +1
- **Strong bearish:** TPI is bearish *and* asset moves with BTC → score pushes toward −1
- **Neutral / decoupled:** TPI is mixed *or* correlation is weak → score collapses toward 0

A configurable **neutral zone** (default `±0.02`) flags conditions where the signal is too weak to act on.

---

## Visual Output

- **Final Weighted Score** — bold line; green above 0, red below, yellow in the neutral zone.
- **Correlation Weight** — stepline showing the current BTC-correlation multiplier.
- **Raw / Avg Trend Score** — the underlying TPI before correlation weighting.
- **Per-window correlations** — optional plots for the 30/60/90/180/365-bar `r` values.
- **Neutral zone** — optional background tint, threshold lines, and diamond marker.
- **Underlying filters** — ROC, RSI, EMAs, SMA can each be plotted individually.

### Tables

- **Signal Table** — every filter's state, raw/avg trend, correlation weight, final score, and overall bull/bear/neutral state.
- **Correlation Diagnostic Table** — per-window `r`, user weight, validity status, and resolved comparison symbol.
- **Final Score Table** — large display of the final weighted score for clean screenshots / streaming.

All tables have configurable positions.

---

## Inputs Overview

| Group | Key Inputs |
|---|---|
| Global | Timeframe |
| Neutral Zone | Low / High thresholds |
| ROC, RSI, EMA, SMA | Lengths for each filter |
| Correlation Weight | 5 × (period, weight), min valid obs ratio |
| Plot Toggles | Per-component visibility |
| Tables | Show/hide and positioning |

---

## How to Read It

- **Score > 0, rising, green:** trend filters and BTC correlation both supportive.
- **Score < 0, falling, red:** trend filters and BTC correlation both negative.
- **Score in yellow zone:** either filters are split, or the asset has decoupled from BTC — treat as no-trade.
- **Correlation weight near 0:** asset is currently uncorrelated with BTC; the trend signal is being intentionally muted.

---

## Notes & Limitations

- Comparison is hardcoded to `INDEX:BTCUSD`. Most useful on crypto and crypto-adjacent assets.
- Correlation is computed on **raw closes**, not returns. This produces smoother, more persistent `r` values that emphasize co-movement of price levels rather than short-term return co-movement.
- The TPI uses a fixed equal-weight blend of ROC, RSI, EMA cross, and SMA. It's a deliberately simple base; the correlation weighting is where the differentiation comes from.
- Designed for higher timeframes (default 1D). Works on lower TFs but the long correlation windows (e.g. 365 bars) become short in calendar time.

---

*Not financial advice. Always backtest and validate on your own instruments and timeframe before using any indicator for live decisions.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yanikroestiqoo00

//@version=6
indicator("L-TPI Correlation Assets")



// ════════════════════════════════════════════════════════════════
//  FINAL WEIGHTED SCORE  +  NEUTRAL ZONE INPUTS
// ════════════════════════════════════════════════════════════════
grp_neut          = "Neutral Zone"
neutral_low       = input.float(-0.02, "Neutral Zone Low",  step=0.01, group=grp_neut)
neutral_high      = input.float( 0.02, "Neutral Zone High", step=0.01, group=grp_neut)
tf         = input.timeframe("1D",  "Timeframe", group = "Global Settings")


// filter 1 roc
rocl1en = input.int(14, "ROC Len", group = "Rate of change")
roc1 = ta.roc(close, rocl1en)
roc1_signal = roc1 > 1 ? 1 : -1
Roc1bull = roc1_signal == 1 ? true : false
Roc1bear = roc1_signal == -1 ? true : false
f1 = roc1_signal

// filter 2 Rsi
rsi1len = input.int(14, "RSI Length", group = "Relative strength index")
rsi1 = ta.rsi(close, rsi1len)
rsi1_signal = rsi1 > 50 ? 1 : -1
rsi1bull = rsi1_signal == 1 ? true : false
rsi1bear = rsi1_signal == -1 ? true : false
f2 = rsi1_signal
rsicol = rsi1bull ? color.blue : color.purple

// filter 3 ema cross
firstmalen  = input.int(10, "Small ma lenght", group = "EMA Crossover")
secondmalen = input.int(20, "Big ma lenght",   group = "EMA Crossover")
ema1 = (ta.ema(close, firstmalen))
ema2 =(ta.ema(close, secondmalen))
cross_signal = ema1 > ema2 ? 1 : -1
crossbull = cross_signal == 1 ? true : false
crossbear = cross_signal == -1 ? true : false
f3 = cross_signal
ema_crosscol = crossbull ? color.green : color.red

// filter 4 Sma price
sma1len = input.int(200, "SMA lenght", group = "SMA - Price")
sma1 = ta.sma(close, sma1len)
sma1_signal = close > sma1 ? 1 : -1
sma1bull = sma1_signal == 1 ? true : false
sma1bear = sma1_signal == -1 ? true : false
f4 = sma1_signal 

raw_trend_score = (f1 + f2 + f3 + f4)
avg_trend_score = (f1 + f2 + f3 + f4) / 4




// ── Plot toggles ────────────────────────────────────────────────
grp_plt      = "Plot Toggles"
sig_plot	 = "Signal Plots"
showNeutralMarker = input.bool(true,  "Show Neutral Marker",            group=grp_plt)
showNeutralBg     = input.bool(true,  "Tint Background in Zone",        group=grp_plt)
showNeutralLines  = input.bool(true,  "Show Neutral Threshold Lines",   group=grp_plt)
showRoc1     = input.bool(false, "Plot ROC",               				group = grp_plt)
showRsi1     = input.bool(false, "Plot RSI",                			group = grp_plt)
showEmas     = input.bool(false, "Plot EMA^s",           			group = grp_plt)
showSma1     = input.bool(false, "Plot SMA",                			group = grp_plt)

showRawTrend = input.bool(true,  "Plot Raw Trend Score",    			group = sig_plot)
showAvgTrend = input.bool(true,  "Plot Avg Trend Score",    			group = sig_plot)
showWeight   = input.bool(true,  "Plot Correlation Weight", 			group = sig_plot)
showFinal    = input.bool(true,  "Plot FINAL Weighted Score",			group = sig_plot)
showWindows  = input.bool(false, "Plot individual window correlations", group = sig_plot)
showTable    = input.bool(true,  "Show Signal Table",       			group = sig_plot)
corr_showTable    = input.bool(true,  "Show Signal corrolation Table",  group = sig_plot)
showFinalTable = input.bool(true, "Show Large Final Score Table", group=sig_plot)
final_tbl_pos = input.string("Top Center", "Final Table Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group=sig_plot)



plot(showRoc1   ? roc1 : na, color=color.aqua,   title="ROC")
plot(showRsi1   ? rsi1 : na, color=rsicol, title="RSI")
plot(showEmas   ? ema1 : na, color=ema_crosscol,  title="EMA Fast")
plot(showEmas   ? ema2 : na, color=ema_crosscol,   title="EMA Slow")
plot(showSma1   ? sma1 : na, color= (sma1bull ? color.green : color.red), title="SMA", linewidth = 3)

plot(showRawTrend ? raw_trend_score    : na, color=color.white,   title="Raw Trend Score")
plot(showAvgTrend ? avg_trend_score    : na, color=color.silver,  title="Avg Trend Score")

// ════════════════════════════════════════════════════════════════
//  CORRELATION WEIGHT  (Asset vs compare_symbol, multi-Period, weighted)
// ════════════════════════════════════════════════════════════════
grp_corr        = "Correlation Weight"
w1              = input.int(30,   "Period 1 (bars)",  minval=3,            group=grp_corr)
weight_w1       = input.float(1.0, "Period 1 weight", minval=0, step=0.5,  group=grp_corr)

w2              = input.int(60,   "Period 2 (bars)",  minval=3,            group=grp_corr)
weight_w2       = input.float(2.0, "Period 2 weight", minval=0, step=0.5,  group=grp_corr)

w3              = input.int(90,   "Period 3 (bars)",  minval=3,            group=grp_corr)
weight_w3       = input.float(3.0, "Period 3 weight", minval=0, step=0.5,  group=grp_corr)

w4              = input.int(180,  "Period 4 (bars)",  minval=3,            group=grp_corr)
weight_w4       = input.float(4.0, "Period 4 weight", minval=0, step=0.5,  group=grp_corr)

w5              = input.int(365,  "Period 5 (bars)",  minval=3,            group=grp_corr)
weight_w5       = input.float(5.0, "Period 5 weight", minval=0, step=0.5,  group=grp_corr)
use_winsor      = input.bool(true, "Winsorize returns at 1st / 99th pct",  group=grp_corr)
winsor_lookback = input.int(365,  "Winsor lookback (bars)", minval=30,     group=grp_corr)
min_valid_ratio = input.float(0.8, "Min valid obs ratio per Period", minval=0.1, maxval=1.0, step=0.05, group=grp_corr)

// Hardcoded to always compare against the BTC index (adjusted for chart settings)
btc_symbol   = "INDEX:BTCUSD"
adjustedBtc  = ticker.modify(btc_symbol)
btc_close    = request.security(adjustedBtc, tf, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
btc_resolved = not na(btc_close)

// Defined Asset as the current chart's close price
Asset = close

aligned_flag = (not na(Asset) and not na(btc_close)) ? 1.0 : 0.0
count_30  = math.sum(aligned_flag, w1)
count_60  = math.sum(aligned_flag, w2)
count_90  = math.sum(aligned_flag, w3)
count_180 = math.sum(aligned_flag, w4)
count_365 = math.sum(aligned_flag, w5)

corr_30  = ta.correlation(Asset, btc_close, w1)
corr_60  = ta.correlation(Asset, btc_close, w2)
corr_90  = ta.correlation(Asset, btc_close, w3)
corr_180 = ta.correlation(Asset, btc_close, w4)
corr_365 = ta.correlation(Asset, btc_close, w5)

valid_30  = count_30  >= math.ceil(w1 * min_valid_ratio) and not na(corr_30)
valid_60  = count_60  >= math.ceil(w2 * min_valid_ratio) and not na(corr_60)
valid_90  = count_90  >= math.ceil(w3 * min_valid_ratio) and not na(corr_90)
valid_180 = count_180 >= math.ceil(w4 * min_valid_ratio) and not na(corr_180)
valid_365 = count_365 >= math.ceil(w5 * min_valid_ratio) and not na(corr_365)

// Weighted mean: Σ(corr × user_weight) / Σ(user_weight) over valid windows
float sum_r = 0.0
float tot_w = 0.0
int   cnt_v = 0
if valid_30
    sum_r := sum_r + corr_30  * weight_w1
    tot_w := tot_w + weight_w1
    cnt_v := cnt_v + 1
if valid_60
    sum_r := sum_r + corr_60  * weight_w2
    tot_w := tot_w + weight_w2
    cnt_v := cnt_v + 1
if valid_90
    sum_r := sum_r + corr_90  * weight_w3
    tot_w := tot_w + weight_w3
    cnt_v := cnt_v + 1
if valid_180
    sum_r := sum_r + corr_180 * weight_w4
    tot_w := tot_w + weight_w4
    cnt_v := cnt_v + 1
if valid_365
    sum_r := sum_r + corr_365 * weight_w5
    tot_w := tot_w + weight_w5
    cnt_v := cnt_v + 1

weight = tot_w > 0 ? math.max(-1.0, math.min(1.0, sum_r / tot_w)) : na

// ════════════════════════════════════════════════════════════════
//  FINAL WEIGHTED SCORE  +  NEUTRAL ZONE
// ════════════════════════════════════════════════════════════════

final_tpi_score      = avg_trend_score
final_weighted_score = final_tpi_score * nz(weight, 0)

in_neutral = final_weighted_score >= neutral_low and final_weighted_score <= neutral_high

c_pos = color.new(color.green, 0)
c_neg = color.new(color.red,   0)
c_na  = color.new(color.gray,  40)

w_color = na(weight) ? c_na : (weight >= 0 ? color.new(color.green, 30) : color.new(color.red, 30))
plot(showWeight ? weight : na, "Correlation Weight", color=w_color, linewidth=2, style=plot.style_stepline)

f_color = in_neutral ? color.new(color.yellow, 0) : (final_weighted_score >= 0 ? c_pos : c_neg)
plot(showFinal ? final_weighted_score : na, "FINAL Weighted Score", color=f_color, linewidth=5)

plotshape(showNeutralMarker and showFinal and in_neutral ? final_weighted_score : na, "Neutral Marker", style=shape.diamond, location=location.absolute, color=color.yellow, size=size.tiny)

hline(showNeutralLines ? neutral_high : na, "Neutral Hi", color=color.new(color.yellow, 60), linestyle=hline.style_dotted)
hline(showNeutralLines ? neutral_low  : na, "Neutral Lo", color=color.new(color.yellow, 60), linestyle=hline.style_dotted)
bgcolor(showNeutralBg and in_neutral ? color.new(color.yellow, 90) : na, title="Neutral Zone Bg")

plot(showWindows ? corr_30  : na, "30  r", color=color.new(color.aqua,    50), linewidth=1)
plot(showWindows ? corr_60  : na, "60  r", color=color.new(color.blue,    50), linewidth=1)
plot(showWindows ? corr_90  : na, "90  r", color=color.new(color.teal,    50), linewidth=1)
plot(showWindows ? corr_180 : na, "180 r", color=color.new(color.orange,  50), linewidth=1)
plot(showWindows ? corr_365 : na, "365 r", color=color.new(color.purple,  50), linewidth=1)

// ── Signal table Inputs ────────────────────────────────────────────────

corr_tbl_pos = input.string("Top Right", "Correlation Table Position",
                 options=["Top Left","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Right"],
                 group=grp_corr)
f_pos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        => position.bottom_right

// ── Signal table ────────────────────────────────────────────────
var table sigTbl = table.new(position.bottom_right, 2, 11, border_width=1, border_color=color.gray, bgcolor=color.new(color.black, 70))

f_sigClr(s) => s == 1 ? color.new(color.green, 20) : color.new(color.red, 20)
f_sigStr(s) => s == 1 ? "BULL" : "BEAR"
f_num(x)    => na(x) ? "n/a" : str.tostring(x, "#.####")
f_valClr(x) => na(x) ? color.gray : (x >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0))

if barstate.islast and showTable
    table.cell(sigTbl, 0, 0, "Signal", text_color=color.white, bgcolor=color.new(color.gray, 40), text_halign=text.align_center)
    table.cell(sigTbl, 1, 0, "Value",  text_color=color.white, bgcolor=color.new(color.gray, 40), text_halign=text.align_center)
    table.cell(sigTbl, 0, 1, "ROC (f1)",        text_color=color.white)
    table.cell(sigTbl, 1, 1, f_sigStr(f1),      text_color=color.white, bgcolor=f_sigClr(f1), text_halign=text.align_center)
    table.cell(sigTbl, 0, 2, "RSI (f2)",        text_color=color.white)
    table.cell(sigTbl, 1, 2, f_sigStr(f2),      text_color=color.white, bgcolor=f_sigClr(f2), text_halign=text.align_center)
    table.cell(sigTbl, 0, 3, "EMA Cross (f3)",  text_color=color.white)
    table.cell(sigTbl, 1, 3, f_sigStr(f3),      text_color=color.white, bgcolor=f_sigClr(f3), text_halign=text.align_center)
    table.cell(sigTbl, 0, 4, "SMA (f4)",        text_color=color.white)
    table.cell(sigTbl, 1, 4, f_sigStr(f4),      text_color=color.white, bgcolor=f_sigClr(f4), text_halign=text.align_center)
    table.cell(sigTbl, 0, 5, "Raw Trend",       text_color=color.yellow)
    table.cell(sigTbl, 1, 5, str.tostring(raw_trend_score),               text_color=color.white, text_halign=text.align_center)
    table.cell(sigTbl, 0, 6, "Avg Trend",       text_color=color.yellow)
    table.cell(sigTbl, 1, 6, str.tostring(avg_trend_score, "#.##"),       text_color=color.white, text_halign=text.align_center)
    table.cell(sigTbl, 0, 7, "Corr Weight (" + str.tostring(cnt_v) + "/5)", text_color=color.aqua)
    table.cell(sigTbl, 1, 7, f_num(weight),                               text_color=f_valClr(weight), text_halign=text.align_center)
    table.cell(sigTbl, 0, 8, "TPI Score",       text_color=color.yellow)
    table.cell(sigTbl, 1, 8, str.tostring(final_tpi_score, "#.##"),       text_color=color.white, text_halign=text.align_center)
    table.cell(sigTbl, 0, 9, "FINAL Weighted",  text_color=color.orange,  bgcolor=color.new(color.gray, 50))
    table.cell(sigTbl, 1, 9, f_num(final_weighted_score),                 text_color=in_neutral ? color.yellow : f_valClr(final_weighted_score), bgcolor=color.new(color.gray, 50), text_halign=text.align_center)
    table.cell(sigTbl, 0, 10, "State",          text_color=color.white)
    table.cell(sigTbl, 1, 10, in_neutral ? "NEUTRAL" : (final_weighted_score >= 0 ? "BULL" : "BEAR"), text_color=color.white, bgcolor=in_neutral ? color.new(color.yellow, 30) : (final_weighted_score >= 0 ? color.new(color.green, 30) : color.new(color.red, 30)), text_halign=text.align_center)


// ── Correlation diagnostic table ────────────────────────────────
var table corrTbl = table.new(f_pos(corr_tbl_pos), 3, 8, bgcolor=color.new(color.black, 70), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

f_fmt(x) => na(x) ? "n/a" : str.tostring(x, "0.0000")
c_ok(b)  => b ? color.new(color.lime, 0) : color.new(color.red, 0)
s_ok(b)  => b ? "OK" : "X"

if barstate.islast and corr_showTable
    table.cell(corrTbl, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
    table.cell(corrTbl, 1, 0, "Value",  text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
    table.cell(corrTbl, 2, 0, "Valid",  text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)

    table.cell(corrTbl, 0, 1, "Symbol", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 1, btc_resolved ? "INDEX:BTCUSD" : "UNRESOLVED", text_color=btc_resolved ? color.white : color.red, text_size=size.small)
    table.cell(corrTbl, 2, 1, s_ok(btc_resolved), text_color=c_ok(btc_resolved), text_size=size.small)

    table.cell(corrTbl, 0, 2, "Weight", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 2, f_fmt(weight), text_color=f_valClr(weight), text_size=size.small)
    table.cell(corrTbl, 2, 2, str.tostring(cnt_v) + "/5", text_color=color.white, text_size=size.small)

    table.cell(corrTbl, 0, 3, str.tostring(w1) + "b (w=" + str.tostring(weight_w1, "#.#") + ")", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 3, f_fmt(corr_30),  text_color=f_valClr(corr_30),  text_size=size.small)
    table.cell(corrTbl, 2, 3, s_ok(valid_30),  text_color=c_ok(valid_30),     text_size=size.small)

    table.cell(corrTbl, 0, 4, str.tostring(w2) + "b (w=" + str.tostring(weight_w2, "#.#") + ")", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 4, f_fmt(corr_60),  text_color=f_valClr(corr_60),  text_size=size.small)
    table.cell(corrTbl, 2, 4, s_ok(valid_60),  text_color=c_ok(valid_60),     text_size=size.small)

    table.cell(corrTbl, 0, 5, str.tostring(w3) + "b (w=" + str.tostring(weight_w3, "#.#") + ")", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 5, f_fmt(corr_90),  text_color=f_valClr(corr_90),  text_size=size.small)
    table.cell(corrTbl, 2, 5, s_ok(valid_90),  text_color=c_ok(valid_90),     text_size=size.small)

    table.cell(corrTbl, 0, 6, str.tostring(w4) + "b (w=" + str.tostring(weight_w4, "#.#") + ")", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 6, f_fmt(corr_180), text_color=f_valClr(corr_180), text_size=size.small)
    table.cell(corrTbl, 2, 6, s_ok(valid_180), text_color=c_ok(valid_180),    text_size=size.small)

    table.cell(corrTbl, 0, 7, str.tostring(w5) + "b (w=" + str.tostring(weight_w5, "#.#") + ")", text_color=color.white, text_size=size.small)
    table.cell(corrTbl, 1, 7, f_fmt(corr_365), text_color=f_valClr(corr_365), text_size=size.small)
    table.cell(corrTbl, 2, 7, s_ok(valid_365), text_color=c_ok(valid_365),    text_size=size.small)

// ── Final Score Table (Large Display) ────────────────────────────────



f_pos_ext(p) =>
    switch p
        "Top Left"        => position.top_left
        "Top Center"      => position.top_center
        "Top Right"       => position.top_right
        "Middle Left"     => position.middle_left
        "Middle Center"   => position.middle_center
        "Middle Right"    => position.middle_right
        "Bottom Left"     => position.bottom_left
        "Bottom Center"   => position.bottom_center
        => position.bottom_right

var table finalTbl = table.new(f_pos_ext(final_tbl_pos), 1, 2, border_width=2, border_color=color.gray, bgcolor=color.new(color.black, 70))

if barstate.islast and showFinalTable
    table.cell(finalTbl, 0, 0, "FINAL SCORE", text_color=color.white, bgcolor=color.new(color.gray, 40), text_halign=text.align_center, text_size=size.large)
    table.cell(finalTbl, 0, 1,
         f_num(final_weighted_score),
         text_color=in_neutral ? color.yellow : f_valClr(final_weighted_score),
         bgcolor=color.new(color.gray, 50),
         text_halign=text.align_center,
         text_size=size.huge)
````
