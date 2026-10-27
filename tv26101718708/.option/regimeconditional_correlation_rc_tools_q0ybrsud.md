# Regime-Conditional Correlation [RC Tools]

- url: https://www.tradingview.com/script/Q0ybRsUD-Regime-Conditional-Correlation-RC-Tools/
- type: indicator
- pine_id: PUB;9951a3cc77284961a8935a6cae5b4c10
- version: 2.0

## Description

RC Tools — Regime-Conditional Correlation
─────────────────────────────────────────────────────────────

█ OVERVIEW

Plain rolling correlation between two assets is well-covered ground. The angle here: correlation is not a constant — it changes with the market regime. This tool computes rolling correlation against a second symbol of your choice and buckets it by the same regime framework as the Regime Classifier, so you can see whether a correlation you're relying on actually holds up across market conditions, or only shows up in one of them.

█ WHAT IT DOES

Plots rolling correlation (Pearson, default 20-bar window) between the current chart's symbol and a compare symbol you choose. Colours the background by the current market regime (Trending — Expansion/Exhaustion, Ranging — Quiet/Volatile), using the identical directionality × volatility-percentile logic as the Regime Classifier. A table shows the current regime and correlation, plus the average correlation, its standard deviation, and the sample count for each of the four regimes historically.

█ THE THEORY BEHIND IT

A single "the correlation is 0.8" number hides a lot. Two assets can be tightly linked during calm trending markets and decouple completely during volatile chop — or vice versa. Regime-conditioning the correlation surfaces that structure instead of averaging it away. This matters directly for anything relying on a stable cross-asset relationship: hedges, pairs, or diversification assumptions that quietly break exactly when you need them most (in the volatile regime).

█ HOW IT IS CALCULATED

CORRELATION: standard Pearson correlation between the current symbol's close and the compare symbol's close (fetched via request.security on the same timeframe), over a rolling window (default 20 bars).

REGIME: identical to the Regime Classifier — Efficiency Ratio for directionality, percentile-ranked realised volatility for volatility state, crossed to give four states. Regime is measured on the CURRENT chart's own price action, not the compare symbol. See the Regime Classifier's description for the full methodology.

The correlation reading and the regime are both "as of now" — contemporaneous — so unlike the Regime Classifier's forward-return table, no forward-looking attribution is needed here: each confirmed bar's correlation is added directly to the running average for whichever regime was active on that same bar.

█ SETTINGS & CONFIGURATION

• Compare Symbol (default BTCUSD) — the second asset to correlate against
• Correlation Length (default 20 bars)
• Regime settings mirror the Regime Classifier exactly (Efficiency Ratio lookback, directionality threshold, realised vol lookback, percentile window, volatility percentile threshold) — keep these in sync if you run both indicators together
• Paint Main Chart Background — off by default; enable on only one of the two indicators if running both, to avoid overlapping backgrounds

█ HOW TO USE IT

Check whether a correlation you're relying on is regime-dependent before trusting it. Example: if a hedge shows strong negative correlation in Ranging — Quiet but the average correlation flips or weakens in Ranging — Volatile, that hedge may not protect you exactly when volatility spikes. Always check the sample count (N) per regime before drawing conclusions — a regime with few historical bars hasn't been tested enough to trust its average.

█ LIMITATIONS

• Correlation is measured over a short rolling window and is noisy by nature — it will swing even when the underlying relationship is stable.
• The compare symbol is fetched via request.security on the same timeframe; illiquid symbols, different exchange sessions, or timezone misalignment can introduce lag or missing values.
• Regime classification carries the same caveats as the Regime Classifier: it is backward-looking by construction, unstable near threshold boundaries, and needs substantial history to be reliable.
• Per-regime correlation statistics accumulate only from where the chart's loaded history begins — early sample counts are small and not yet statistically meaningful.
• This script does NOT repaint. All classification and correlation display values update on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past correlation between any two assets does not indicate future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Regime-Conditional Correlation [RC Tools]", shorttitle="RCT Regime Corr", overlay=false, precision=2)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Plain rolling correlation between two assets is well covered ground. The
// angle here: correlation is not a constant — it changes with the market
// regime. This tool computes rolling correlation against a second symbol AND
// buckets it by the same regime framework as the RC Tools Regime Classifier
// (directionality × volatility state), so you can see whether a correlation
// you're relying on actually holds up across conditions, or only in one of
// them.
//
// Regime + correlation display update ONLY on confirmed bar close, so
// nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────



// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// ── Correlation ────────────────────────────────────────────────────────────────
string compareSymbol = input.symbol("BTCUSD", "Compare Symbol", group="Correlation",
     tooltip="The current chart's symbol is correlated against this one.")
int    corrLen        = input.int(20, "Correlation Length", minval=5, group="Correlation")

// ── Regime (mirrors the RC Tools Regime Classifier — keep in sync if running both) ──
int   erLen    = input.int(20, "Efficiency Ratio Lookback", minval=2, group="Regime",
     tooltip="Regime is measured on the CURRENT chart's own price action, not the compare symbol.")
float erThresh = input.float(0.35, "Directionality Threshold", minval=0.05, maxval=0.95, step=0.01, group="Regime")
int   rvLen     = input.int(20, "Realised Volatility Lookback", minval=2, group="Regime")
int   pctWindow = input.int(750, "Percentile Ranking Window (bars)", minval=50, group="Regime")
int   volThresh = input.int(50, "Volatility Percentile Threshold", minval=1, maxval=99, group="Regime")

// ── Display ────────────────────────────────────────────────────────────────────
bool   showTable = input.bool(true, "Show Stats Table", group="Display")
string tablePos  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")
bool   paintMainChart = input.bool(false, "Paint Main Chart Background", group="Display",
     tooltip="Off by default — if you're also running the Regime Classifier on the same chart, only enable main-chart painting on one of them to avoid the two backgrounds fighting.")
color colExpansion  = input.color(color.new(color.lime,   72), "Trending — Expansion",  group="Colours")
color colExhaustion = input.color(color.new(color.orange, 72), "Trending — Exhaustion", group="Colours")
color colVolatile   = input.color(color.new(color.red,    72), "Ranging — Volatile",    group="Colours")
color colQuiet      = input.color(color.new(color.gray,   85), "Ranging — Quiet",       group="Colours")


// ─────────────────────────────────────────────────────────────────────────────
// COMPARE SYMBOL DATA
// ─────────────────────────────────────────────────────────────────────────────
float secClose = request.security(compareSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)


// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS — Regime (identical logic to the RC Tools Regime Classifier)
// ─────────────────────────────────────────────────────────────────────────────
float netMove = math.abs(close - close[erLen])
float sumMove = math.sum(math.abs(close - close[1]), erLen)
float er      = sumMove != 0 ? netMove / sumMove : 0.0

float logRet = math.log(close / close[1])
float rv     = ta.stdev(logRet, rvLen)
float volPct = ta.percentrank(rv, pctWindow)

bool warmedUp    = bar_index >= pctWindow and not na(volPct) and not na(er)
bool trendingNow = er > erThresh
bool volatileNow = volPct > volThresh

// State codes: 0 = Trending-Expansion, 1 = Trending-Exhaustion,
//              2 = Ranging-Volatile,   3 = Ranging-Quiet
int rawState = na
if warmedUp
    rawState := trendingNow and volatileNow ? 0 :
         trendingNow and not volatileNow ? 1 :
         (not trendingNow) and volatileNow ? 2 : 3

var int regimeState = na
if barstate.isconfirmed
    regimeState := rawState

stateName(s) =>
    s == 0 ? "Trending — Expansion" :
     s == 1 ? "Trending — Exhaustion" :
     s == 2 ? "Ranging — Volatile" :
     s == 3 ? "Ranging — Quiet" : "Warming up…"

stateColor(s) =>
    s == 0 ? colExpansion :
     s == 1 ? colExhaustion :
     s == 2 ? colVolatile :
     s == 3 ? colQuiet : na


// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS — Correlation (confirmed-close-only)
// ─────────────────────────────────────────────────────────────────────────────
float rawCorr = ta.correlation(close, secClose, corrLen)

var float corr = na
if barstate.isconfirmed
    corr := rawCorr


// ─────────────────────────────────────────────────────────────────────────────
// PER-REGIME CORRELATION STATS
// Both the correlation reading and the regime are "as of now" — contemporaneous,
// so no forward-looking attribution is needed here (unlike the Regime
// Classifier's base-rate table, which deliberately looks at forward returns).
// ─────────────────────────────────────────────────────────────────────────────
var float[] sumCorr  = array.new_float(4, 0.0)
var float[] sumCorr2 = array.new_float(4, 0.0)
var int[]   cnt       = array.new_int(4, 0)

if barstate.isconfirmed and not na(corr) and not na(regimeState)
    int idx = regimeState
    array.set(sumCorr,  idx, array.get(sumCorr, idx)  + corr)
    array.set(sumCorr2, idx, array.get(sumCorr2, idx) + corr * corr)
    array.set(cnt,      idx, array.get(cnt, idx) + 1)

avgCorr(idx) =>
    int n = array.get(cnt, idx)
    n > 0 ? array.get(sumCorr, idx) / n : na

stdevCorr(idx) =>
    int n = array.get(cnt, idx)
    if n > 1
        float mean = array.get(sumCorr, idx) / n
        float variance = array.get(sumCorr2, idx) / n - mean * mean
        math.sqrt(math.max(variance, 0.0))
    else
        na


// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(corr, "Correlation", color=color.new(color.yellow, 0), linewidth=2)
hline(0,    "Zero",           color=color.gray, linestyle=hline.style_solid)
hline(0.5,  "+0.5",           color=color.gray, linestyle=hline.style_dashed)
hline(-0.5, "-0.5",           color=color.gray, linestyle=hline.style_dashed)

bgcolor(warmedUp ? stateColor(regimeState) : na, title="Regime Background (pane)")
bgcolor(paintMainChart and warmedUp ? stateColor(regimeState) : na, force_overlay=true, title="Regime Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// STATS TABLE
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"     ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left : position.top_right

fmt(v) => na(v) ? "—" : str.tostring(v, "#.##")

if showTable and barstate.islast
    var table t = table.new(getPosition(tablePos), 4, 7,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(t, 0, 0, "Regime-Conditional Correlation vs " + compareSymbol, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 2, 0, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 3, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Current Regime", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, warmedUp ? stateName(regimeState) : "Warming up…", text_color=warmedUp ? stateColor(regimeState) : color.gray, text_size=size.small)
    table.cell(t, 2, 1, "Current Corr", text_color=color.gray, text_size=size.small)
    table.cell(t, 3, 1, fmt(corr), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 2, "Regime", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, "Avg Corr", text_color=color.gray, text_size=size.small)
    table.cell(t, 2, 2, "Std Dev", text_color=color.gray, text_size=size.small)
    table.cell(t, 3, 2, "N", text_color=color.gray, text_size=size.small)

    table.cell(t, 0, 3, "Expansion", text_color=colExpansion, text_size=size.small)
    table.cell(t, 1, 3, fmt(avgCorr(0)), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 3, fmt(stdevCorr(0)), text_color=color.white, text_size=size.small)
    table.cell(t, 3, 3, str.tostring(array.get(cnt, 0)), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 4, "Exhaustion", text_color=colExhaustion, text_size=size.small)
    table.cell(t, 1, 4, fmt(avgCorr(1)), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 4, fmt(stdevCorr(1)), text_color=color.white, text_size=size.small)
    table.cell(t, 3, 4, str.tostring(array.get(cnt, 1)), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 5, "Ranging-Vol", text_color=colVolatile, text_size=size.small)
    table.cell(t, 1, 5, fmt(avgCorr(2)), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 5, fmt(stdevCorr(2)), text_color=color.white, text_size=size.small)
    table.cell(t, 3, 5, str.tostring(array.get(cnt, 2)), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 6, "Ranging-Quiet", text_color=colQuiet, text_size=size.small)
    table.cell(t, 1, 6, fmt(avgCorr(3)), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 6, fmt(stdevCorr(3)), text_color=color.white, text_size=size.small)
    table.cell(t, 3, 6, str.tostring(array.get(cnt, 3)), text_color=color.white, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - Correlation is measured over a short rolling window (default 20 bars) —
//   it is noisy by nature and will swing even when the "true" relationship
//   is stable.
// - The compare symbol is fetched via request.security on the same
//   timeframe; illiquid or misaligned session symbols can introduce lag or
//   NA values, especially across different exchanges/sessions.
// - Regime classification carries the same caveats as the Regime Classifier:
//   backward-looking, unstable near threshold boundaries, needs history.
// - Per-regime correlation stats accumulate only from the point the chart's
//   history begins loading — early sample sizes (N) are small and not yet
//   statistically meaningful. Check N before trusting an average.
// - This script does NOT repaint. All classification and correlation
//   display values update on confirmed bar close only.
// ────────────────────────────────────────────────────────────────────────────
````
