<!-- tradingview-pine-id: PUB;8dffdb64dd424cc1866f6b53f7b2b771 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Hurst Exponent Regime [RC Tools]

Source: https://www.tradingview.com/script/rRaGrzof-Hurst-Exponent-Regime-RC-Tools/

## Description

RC Tools — Hurst Exponent Regime
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Most regime tools ask "is price trending right now." This one asks a more fundamental question: does this market's statistical character currently reward trend-following or mean-reversion? It applies the Hurst Exponent — a statistic originally developed to study Nile river flood records — via rescaled-range analysis, to classify the market into one of three long-memory regimes.

█ WHAT IT DOES

Estimates the Hurst Exponent (H) over a rolling window and classifies each confirmed bar as Trending (persistent), Mean-Reverting (anti-persistent), or Random Walk (no memory). Colours the chart background accordingly, plots both the smoothed and raw H line in a dedicated pane against static threshold lines and the 0.5 "true random walk" reference, and shows a table with the current state, how long price has been in it, and historical base rates (average forward return and win rate) for each state.

█ THE THEORY BEHIND IT

H.E. Hurst developed this statistic in the 1950s while studying how to size reservoirs for the Nile, where flood years tended to cluster rather than arrive randomly — a property he needed to measure and design around. The same statistic applies to any time series: it measures whether large values tend to be followed by more large values of the same sign (persistence, H > 0.5), whether they tend to reverse (anti-persistence, H < 0.5), or whether the series has no memory at all (H = 0.5, a true random walk).

Applied to price, this is a genuinely different question from "is this asset trending." A trend-following indicator can flag a trend within a market whose underlying character is actually mean-reverting — in which case that trend is more likely to be a temporary deviation that reverses. Knowing which regime you're in tells you which family of tools (trend-following vs. mean-reversion) is statistically better suited to current conditions, independent of what any single trend or oscillator reading says right now.

█ HOW IT IS CALCULATED

1. Take log returns over the window.
2. Build the cumulative deviation-from-mean series within the window, in chronological order, and take its range (maximum minus minimum) — this is R.
3. Compute S, the window's standard deviation of returns.
4. Apply Hurst's classic empirical relation: R/S is approximately equal to (window length / 2) raised to the power H. Rearranging gives H = ln(R/S) / ln(window length / 2).
5. Optionally smooth H (the raw rescaled-range estimate is noisy bar-to-bar by construction).
6. Classify: H above the Trending threshold (default 0.55) → Trending. H below the Mean-Reverting threshold (default 0.45) → Mean-Reverting. Otherwise → Random Walk.

Classification occurs ONLY on confirmed bar close — the plotted H, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

Note: this is a single-scale rescaled-range estimate using Hurst's classic empirical formula, not a full multi-scale regression across many window sizes. It is a practical, computationally efficient approximation, not a research-grade estimator — treat it as a useful compass, not a precise measurement.

█ SETTINGS & CONFIGURATION

• Source (default close)
• Window Length (default 100) — longer windows give a more stable estimate but react slower to a genuine regime change
• Trending / Mean-Reverting Thresholds (default 0.55 / 0.45) — the H values beyond which a regime is declared; the gap between them is the "Random Walk" zone
• Smoothing Length and Type (default 5-period EMA) — reduces the raw estimate's bar-to-bar noise
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Table visibility, position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the statistics pane

█ HOW TO USE IT

Use it to decide which family of tools to trust right now, not as a standalone entry signal. Example: if you run a mean-reversion system, check whether it has historically performed better when this tool reads Mean-Reverting than when it reads Trending; a trend-following system should show the opposite pattern. Check the base-rate table's sample count before treating any single state as meaningfully predictive.

Works on any asset and timeframe with sufficient history for the Window Length. Best used on daily and above, where regime persistence is greatest and the R/S window has enough independent observations to be meaningful.

█ LIMITATIONS

• This is a SINGLE-SCALE rescaled-range estimate, not a full multi-scale regression across many window sizes — a practical approximation, not a research-grade estimator.
• H describes the market's statistical character over the window — it does NOT identify direction. A "Trending" reading means persistence is likely, not which way.
• The R/S statistic assumes no major structural breaks within the window; a sudden regime shift partway through the window can distort the estimate until it fully rolls off.
• Shorter windows react faster but produce noisier, less reliable H estimates; longer windows are more stable but slower to reflect a genuine regime change.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted, especially for the less common states.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any regime state does not indicate future results. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Hurst Exponent Regime [RC Tools]", shorttitle="RCT Hurst", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Hurst Exponent — Hurst, 1951. A public-domain statistic from hydrology
// (originally developed to study Nile river flood records) that measures
// long-range dependence in a time series via rescaled-range (R/S) analysis.
// Independent implementation, built from the classic empirical formula.
//
// H ≈ 0.5  → the series behaves like a random walk (no memory)
// H > 0.5  → persistent / trending behaviour (a move tends to be followed by
//            more of the same)
// H < 0.5  → anti-persistent / mean-reverting behaviour (a move tends to be
//            followed by a reversal)
//
// This is a genuinely different question from "is price trending right now"
// — it asks whether the MARKET'S STATISTICAL CHARACTER over the window is
// trend-following or mean-reverting by nature, which is useful context for
// deciding which family of tools (trend-following vs. mean-reversion) is
// likely to suit current conditions.
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src        = input.source(close, "Source", group="Hurst Exponent")
window     = input.int(40, "Window Length", minval=20, maxval=500, step=10, group="Hurst Exponent",
     tooltip="Rescaled-range (R/S) window. Longer windows give a more stable estimate but react slower to genuine regime changes.")
threshUp   = input.float(0.58, "Trending Threshold (H >)", minval=0.5, maxval=1.0, step=0.01, group="Hurst Exponent",
     tooltip="H above this is classified as persistent/trending.")
threshDown = input.float(0.48, "Mean-Reverting Threshold (H <)", minval=0.0, maxval=0.5, step=0.01, group="Hurst Exponent",
     tooltip="H below this is classified as anti-persistent/mean-reverting.")
smoothLen  = input.int(3, "Smoothing Length", minval=1, maxval=50, step=1, group="Hurst Exponent",
     tooltip="MA smoothing applied to the raw H estimate. 1 = no smoothing. The raw R/S-derived H is noisy bar-to-bar.")
smoothType = input.string("EMA", "Smoothing Type", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group="Hurst Exponent",
     tooltip="Moving-average family used to smooth H prior to the threshold check.")

int    fwdBars   = input.int(20, "Forward Return Window (bars)", minval=1, group="Tables")
bool   showTable = input.bool(true, "Show Base-Rate Table", group="Tables")
string tablePos  = input.string("Top Right", "Base-Rate Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colTrend       = input.color(color.new(color.blue,   60), "Trending", group="Colours")
color colMeanRevert  = input.color(color.new(color.orange, 60), "Mean-Reverting", group="Colours")
color colRandom      = input.color(color.new(color.gray,   70), "Random Walk", group="Colours")
bool  paintPaneChart = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")

// ─────────────────────────────────────────────────────────────────────────────
// HURST EXPONENT via RESCALED-RANGE (R/S) ANALYSIS
// ─────────────────────────────────────────────────────────────────────────────
// 1. Take log returns over the window.
// 2. Build the cumulative deviation-from-mean series within the window, in
//    chronological order, and take its range (max - min) = R.
// 3. S = the window's standard deviation of returns.
// 4. R/S ≈ (window/2)^H  (Hurst's classic empirical relation)
//    =>  H = ln(R/S) / ln(window/2)
f_ma(float srcMa, int len, string kind) =>
    switch kind
        "SMA" => ta.sma(srcMa, len)
        "EMA" => ta.ema(srcMa, len)
        "WMA" => ta.wma(srcMa, len)
        "RMA" => ta.rma(srcMa, len)
        "HMA" => ta.hma(srcMa, len)
        => ta.ema(srcMa, len)

logRet  = math.log(src / src[1])
meanRet = ta.sma(logRet, window)
sDev    = ta.stdev(logRet, window)

runSum = 0.0
maxY   = -1e10
minY   = 1e10
for t = window - 1 to 0
    runSum += (logRet[t] - meanRet)
    maxY := math.max(maxY, runSum)
    minY := math.min(minY, runSum)

rRange = maxY - minY
ready  = bar_index >= window and not na(sDev) and sDev > 0.0 and rRange > 0.0

hRaw    = ready ? math.log(rRange / sDev) / math.log(window / 2.0) : na
hSmooth = ready ? (smoothLen > 1 ? f_ma(hRaw, smoothLen, smoothType) : hRaw) : na

// State codes: 0 = Mean-Reverting, 1 = Random Walk, 2 = Trending
var int liveSig = 1
if ready and hSmooth > threshUp
    liveSig := 2
else if ready and hSmooth < threshDown
    liveSig := 0
else if ready
    liveSig := 1

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
var float dispH        = na
var int   currentState = na
if barstate.isconfirmed
    dispH        := hSmooth
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) => s == 2 ? "Trending" : s == 0 ? "Mean-Reverting" : s == 1 ? "Random Walk" : "Warming up…"
stateColor(s) => s == 2 ? colTrend : s == 0 ? colMeanRevert : s == 1 ? colRandom : na


// ─────────────────────────────────────────────────────────────────────────────
// STATE STREAK
// ─────────────────────────────────────────────────────────────────────────────
var int lastState = na
var int streak     = 0
if barstate.isconfirmed
    if currentState == lastState
        streak := streak + 1
    else
        streak := 1
        lastState := currentState


// ─────────────────────────────────────────────────────────────────────────────
// HISTORICAL BASE RATES
// Forward N-bar return, attributed back to whichever state was active N bars
// ago — same approach as the Regime Classifier's and Mann-Kendall's base-rate
// tables. Three states this time (Mean-Reverting / Random Walk / Trending).
// ─────────────────────────────────────────────────────────────────────────────
var float[] sumRet = array.new_float(3, 0.0)
var int[]   cnt    = array.new_int(3, 0)
var int[]   winCnt = array.new_int(3, 0)

if barstate.isconfirmed and bar_index >= fwdBars and not na(currentState[fwdBars])
    int idxState = currentState[fwdBars]
    float fwdRet = close / close[fwdBars] - 1
    array.set(sumRet, idxState, array.get(sumRet, idxState) + fwdRet)
    array.set(cnt,    idxState, array.get(cnt, idxState) + 1)
    if fwdRet > 0
        array.set(winCnt, idxState, array.get(winCnt, idxState) + 1)

avgRet(idx) =>
    int nCnt = array.get(cnt, idx)
    nCnt > 0 ? array.get(sumRet, idx) / nCnt * 100 : na

winRate(idx) =>
    int nCnt = array.get(cnt, idx)
    nCnt > 0 ? array.get(winCnt, idx) / nCnt * 100 : na


// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(hSmooth, "Hurst Exponent (smoothed)", color=ready ? stateColor(currentState) : color.gray, style=plot.style_line, linewidth=2)
plot(hRaw, "Hurst Exponent (raw)", color=color.new(color.gray, 60), linewidth=1)
hline(threshUp,   "Trending Threshold",       color=color.new(colTrend, 0),      linestyle=hline.style_solid)
hline(threshDown, "Mean-Reverting Threshold", color=color.new(colMeanRevert, 0), linestyle=hline.style_solid)
hline(0.5, "Random Walk (0.5)", color=color.new(color.gray, 40), linestyle=hline.style_dashed)

bgcolor(paintPaneChart and ready ? stateColor(currentState) : na, title="Regime Background (pane)")
bgcolor(paintMainChart and ready ? stateColor(currentState) : na, force_overlay=true, title="Regime Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// STATS TABLE
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"      ? position.top_left :
     p == "Top Middle"    ? position.top_center :
     p == "Bottom Right"  ? position.bottom_right :
     p == "Bottom Middle" ? position.bottom_center :
     p == "Bottom Left"   ? position.bottom_left : position.top_right

if showTable and barstate.islast
    var table t = table.new(getPosition(tablePos), 3, 5,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(t, 0, 0, "Hurst Exponent Regime", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, ready ? stateName(currentState) : "Warming up…", text_color=ready ? stateColor(currentState) : color.gray, text_size=size.small)
    table.cell(t, 2, 0, ready ? str.tostring(streak) + " bars" : "", text_color=color.gray, text_size=size.small)

    table.cell(t, 0, 1, "State", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, "Avg Fwd " + str.tostring(fwdBars) + "-bar %", text_color=color.gray, text_size=size.small)
    table.cell(t, 2, 1, "Win Rate %", text_color=color.gray, text_size=size.small)

    table.cell(t, 0, 2, "Trending", text_color=colTrend, text_size=size.small)
    table.cell(t, 1, 2, na(avgRet(2)) ? "—" : str.tostring(avgRet(2), "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 2, na(winRate(2)) ? "—" : str.tostring(winRate(2), "#.#"), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 3, "Mean-Reverting", text_color=colMeanRevert, text_size=size.small)
    table.cell(t, 1, 3, na(avgRet(0)) ? "—" : str.tostring(avgRet(0), "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 3, na(winRate(0)) ? "—" : str.tostring(winRate(0), "#.#"), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 4, "Random Walk", text_color=colRandom, text_size=size.small)
    table.cell(t, 1, 4, na(avgRet(1)) ? "—" : str.tostring(avgRet(1), "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 4, na(winRate(1)) ? "—" : str.tostring(winRate(1), "#.#"), text_color=color.white, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - This is a SINGLE-SCALE rescaled-range estimate using Hurst's classic
//   empirical formula, not a full multi-scale regression across many window
//   sizes. It is a practical approximation, not a research-grade estimator.
// - H describes the market's statistical character over the window — it does
//   NOT identify direction. A "Trending" reading means persistence is likely,
//   not which way.
// - The R/S statistic assumes no major structural breaks within the window;
//   a sudden regime shift partway through the window can distort the estimate
//   until it fully rolls off.
// - Shorter windows react faster but produce noisier, less reliable H
//   estimates; longer windows are more stable but slower to reflect a
//   genuine regime change.
// - Historical base-rate stats need a meaningful sample count (check N)
//   before being trusted, especially for the less common states.
// - This script does NOT repaint. All classification updates on confirmed
//   bar close only.
// ─────────────────────────────────────────────────────────────────────────────
````
