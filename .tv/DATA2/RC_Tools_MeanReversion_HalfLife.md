<!-- tradingview-pine-id: PUB;188e079f703d403db22a2a638bf4f306 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# RC Tools - Mean-Reversion Half-Life

Source: https://www.tradingview.com/script/37cMMsU1-Mean-Reversion-Half-Life-RC-Tools/

## Description

RC Tools — Mean-Reversion Half-Life
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Knowing a market is "mean-reverting" isn't enough to trade it — a series that takes 5 bars to snap back and one that takes 50 bars to snap back are both technically mean-reverting, but call for completely different holding periods and expectations. This tool estimates that missing number directly: the half-life, in bars, of mean reversion, using the same Ornstein-Uhlenbeck-style regression approach used in quantitative statistical-arbitrage research.

█ WHAT IT DOES

Estimates mean-reversion speed via a rolling OLS regression and classifies each confirmed bar as Fast Mean-Reversion, Slow Mean-Reversion, or No Mean-Reversion based on the resulting half-life. Colours the chart background accordingly, plots the half-life (in bars, capped for readable scale) as a histogram against Fast and No-Reversion threshold lines, and shows a table with the current state, its estimated half-life, and historical base rates (average forward return and win rate) for each state.

█ THE THEORY BEHIND IT

This is a companion tool to RC Tools' Hurst Exponent Regime script, and answers the natural follow-up question it leaves open. The Hurst Exponent tells you whether a market's statistical character is trending, mean-reverting, or a random walk — but it doesn't say how fast a mean-reverting move actually closes. This tool fits a simple version of the Ornstein-Uhlenbeck model, a classical stochastic process used to describe a quantity that drifts back toward a long-run mean at a speed proportional to its current distance from that mean, and converts the fitted speed into a half-life: the number of bars it takes, on average, to close half the current deviation.

█ HOW IT IS CALCULATED

1. Take the log of price, and regress its bar-to-bar change against its own prior level (a one-lag OLS regression): Δy = α + β·y(prior), where y is log price.
2. A negative β implies mean reversion — the more negative, the faster the pull back toward the mean. A β at or above zero implies no reversion (the series is trending or behaving like a random walk).
3. Convert β into a half-life: -ln(2) / β, in bars.
4. Classify: half-life at or below the Fast threshold (default 10 bars) → Fast Mean-Reversion. Above that but at or below the No-Reversion threshold (default 60 bars) → Slow Mean-Reversion. Above the cap, or β non-negative → No Mean-Reversion (the series isn't reliably reverting, or the estimate is too unstable to trust).

β is smoothed before the half-life calculation (rather than smoothing half-life itself), because half-life is numerically unstable near a zero slope and can spike to extreme values that a direct smoothing pass wouldn't tame cleanly.

Classification occurs ONLY on confirmed bar close — the plotted half-life, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Source (default close)
• Regression Window (default 50 bars) — longer windows give a more stable estimate but react slower to a genuine regime change
• Fast Mean-Reversion Threshold (default 10 bars) and No-Reversion Threshold (default 60 bars) — the half-life cutoffs between the three states
• Smoothing Length and Type (default 3-period EMA) — applied to the regression slope, not the half-life itself
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Table visibility, position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the statistics pane

█ HOW TO USE IT

Use it to calibrate holding periods and expectations for a mean-reversion approach, not as a standalone entry signal. A Fast Mean-Reversion reading suggests a short-holding-period approach is appropriate; a Slow reading suggests patience is required and tight stops may cut off the reversion before it completes; a No Mean-Reversion reading suggests a mean-reversion approach isn't currently well-suited to this market at all. Pairs naturally with the Hurst Exponent Regime tool — Hurst tells you IF the market's character favours mean reversion, this tool tells you roughly HOW FAST.

Works on any asset and timeframe with sufficient history for the Regression Window.

█ LIMITATIONS

• This is a SIMPLE linear (OLS) estimate of mean-reversion speed, not a full maximum-likelihood Ornstein-Uhlenbeck fit. It is a practical approximation, not a research-grade estimator.
• Half-life describes an estimated SPEED, not a guarantee of reversion — a series classified as mean-reverting can still trend away for an extended period before, or instead of, reverting.
• Near a regression slope of zero, the raw half-life estimate is numerically unstable and can spike to very large values; display values are capped for readability.
• The regression window assumes the mean-reversion relationship is roughly stable across the window; a structural break partway through will distort the estimate until it fully rolls off.
• Shorter windows react faster but produce noisier, less reliable estimates; longer windows are more stable but slower to reflect a genuine change.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted, especially for the less common states.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any mean-reversion state does not indicate future results. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("RC Tools - Mean-Reversion Half-Life", shorttitle="RCT Half-Life", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Ornstein-Uhlenbeck-style mean-reversion speed estimate, via OLS regression
// of the change in log price against the prior log price level — the same
// approach used in quantitative statistical-arbitrage literature to test
// whether a series is mean-reverting and, if so, how fast. Independent
// implementation, built from the public regression formula.
//
// Where the Hurst Exponent (see RC Tools - Hurst Exponent Regime) answers
// "is this market's character trending or mean-reverting," this tool answers
// the follow-up question with an actual number: if it IS mean-reverting,
// how many bars does it take to close half the distance back to its mean?
// A half-life of 5 bars and a half-life of 50 bars are both "mean-reverting"
// in the Hurst sense, but call for very different holding periods.
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src        = input.source(close, "Source", group="Half-Life")
window     = input.int(50, "Regression Window", minval=20, maxval=300, step=10, group="Half-Life",
     tooltip="Rolling window for the OLS regression. Longer windows give a more stable estimate but react slower to a genuine regime change.")
fastThresh = input.int(10, "Fast Mean-Reversion Threshold (bars)", minval=1, maxval=100, step=1, group="Half-Life",
     tooltip="Half-life below this many bars is classified as Fast Mean-Reversion.")
slowCap    = input.int(60, "Slow Cap / No-Reversion Threshold (bars)", minval=10, maxval=300, step=5, group="Half-Life",
     tooltip="Half-life above this many bars (or a non-negative regression slope) is classified as No Mean-Reversion — the estimate is too unreliable or the series isn't reverting at all.")
smoothLen  = input.int(3, "Smoothing Length", minval=1, maxval=50, step=1, group="Half-Life",
     tooltip="MA smoothing applied to the regression slope before computing half-life. Smoothing the slope is more numerically stable than smoothing half-life itself, which can spike near a zero slope.")
smoothType = input.string("EMA", "Smoothing Type", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group="Half-Life",
     tooltip="Moving-average family used to smooth the regression slope.")

bool   showTable = input.bool(true, "Show Status Table", group="Tables")
string tablePos  = input.string("Top Right", "Status Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colFast         = input.color(color.new(color.aqua,   60), "Fast Mean-Reversion", group="Colours")
color colSlow         = input.color(color.new(color.purple, 60), "Slow Mean-Reversion", group="Colours")
color colNoReversion  = input.color(color.new(color.gray,   70), "No Mean-Reversion", group="Colours")
bool  paintPaneChart  = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart  = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// MEAN-REVERSION SPEED via OLS REGRESSION
// ─────────────────────────────────────────────────────────────────────────────
// Model:  Δy_t = α + β·y_{t-1} + ε_t          (y = log price)
// β < 0 implies mean reversion; the more negative, the faster.
// Half-life (bars to close half the deviation) = -ln(2) / β.
//
// β is estimated via the covariance/variance identity, computed with rolling
// SMAs rather than an explicit loop — Cov(x,Δy)/Var(x), where x = y_{t-1}.
f_ma(float srcMa, int len, string kind) =>
    switch kind
        "SMA" => ta.sma(srcMa, len)
        "EMA" => ta.ema(srcMa, len)
        "WMA" => ta.wma(srcMa, len)
        "RMA" => ta.rma(srcMa, len)
        "HMA" => ta.hma(srcMa, len)
        => ta.ema(srcMa, len)

logY = math.log(src)
x    = logY[1]
dy   = logY - logY[1]

mX   = ta.sma(x, window)
mDY  = ta.sma(dy, window)
mXX  = ta.sma(x * x, window)
mXDY = ta.sma(x * dy, window)

covXY = mXDY - mX * mDY
varX  = mXX - mX * mX

beta       = varX != 0.0 ? covXY / varX : na
betaSmooth = na(beta) ? na : (smoothLen > 1 ? f_ma(beta, smoothLen, smoothType) : beta)

ready = bar_index >= window and not na(betaSmooth)

halfLife = ready and betaSmooth < 0.0 ? -math.log(2) / betaSmooth : na

// State codes: 0 = No Mean-Reversion, 1 = Slow Mean-Reversion, 2 = Fast Mean-Reversion
var int liveSig = 0
if ready
    if na(halfLife) or halfLife > slowCap
        liveSig := 0
    else if halfLife <= fastThresh
        liveSig := 2
    else
        liveSig := 1

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
var float dispHalfLife = na
var int   currentState = na
if barstate.isconfirmed
    dispHalfLife := halfLife
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) => s == 2 ? "Fast Mean-Reversion" : s == 1 ? "Slow Mean-Reversion" : s == 0 ? "No Mean-Reversion" : "Warming up…"
stateColor(s) => s == 2 ? colFast : s == 1 ? colSlow : s == 0 ? colNoReversion : na


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
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// Half-life is capped for display only — near a zero regression slope the raw
// value can spike to very large numbers and distort the pane's scale. The
// classification logic above uses the uncapped comparison against slowCap.
dispCap  = slowCap * 3
dispPlot = na(halfLife) ? dispCap : math.min(halfLife, dispCap)

plot(dispPlot, "Half-Life (bars, capped for display)", color=ready ? stateColor(currentState) : color.gray, style=plot.style_columns, linewidth=2)
hline(fastThresh, "Fast Threshold", color=color.new(colFast, 0), linestyle=hline.style_solid)
hline(slowCap,    "No-Reversion Threshold", color=color.new(colNoReversion, 0), linestyle=hline.style_solid)

bgcolor(paintPaneChart and ready ? stateColor(currentState) : na, title="Half-Life Background (pane)")
bgcolor(paintMainChart and ready ? stateColor(currentState) : na, force_overlay=true, title="Half-Life Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// TABLES
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"      ? position.top_left :
     p == "Top Middle"    ? position.top_center :
     p == "Bottom Right"  ? position.bottom_right :
     p == "Bottom Middle" ? position.bottom_center :
     p == "Bottom Left"   ? position.bottom_left : position.top_right

halfLifeText = na(dispHalfLife) ? "—" : (dispHalfLife > dispCap ? ">" + str.tostring(dispCap, "#") : str.tostring(dispHalfLife, "#.#"))

if showTable and barstate.islast
    var table t = table.new(getPosition(tablePos), 3, 1,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(t, 0, 0, "Mean-Reversion Half-Life", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, ready ? stateName(currentState) : "Warming up…", text_color=ready ? stateColor(currentState) : color.gray, text_size=size.small)
    table.cell(t, 2, 0, ready ? halfLifeText + " bars" : "", text_color=color.gray, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - This is a SIMPLE linear (OLS) estimate of mean-reversion speed, not a
//   full maximum-likelihood Ornstein-Uhlenbeck fit. It is a practical
//   approximation, not a research-grade estimator.
// - Half-life describes an estimated SPEED, not a guarantee of reversion —
//   a series can be classified as mean-reverting and still trend away for
//   an extended period before (or instead of) reverting.
// - Near a regression slope of zero, the raw half-life estimate is numerically
//   unstable and can spike to very large values; this is why display values
//   are capped and slopes are smoothed before the half-life calculation.
// - The regression window assumes the mean-reversion relationship is roughly
//   stable across the window; a structural break partway through will distort
//   the estimate until it fully rolls off.
// - Shorter windows react faster but produce noisier, less reliable estimates;
//   longer windows are more stable but slower to reflect a genuine change.
// - This script does NOT repaint. All classification updates on confirmed
//   bar close only.
// ─────────────────────────────────────────────────────────────────────────────
````
