<!-- tradingview-pine-id: PUB;0fc278aecaec42cfb3b4e5dad5ce1fef -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# RC Tools - Mann-Kendall Trend Significance

Source: https://www.tradingview.com/script/vbgeMN5N-Mann-Kendall-Trend-Significance-RC-Tools/

## Description

RC Tools — Mann-Kendall Trend Significance
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Most trend tools answer "which way is price going." This one answers a different question: "how statistically unlikely is it that this trend is just noise." It applies the Mann-Kendall test — a nonparametric hypothesis test from statistics, most commonly used in hydrology and climate-science time-series analysis — to price, turning "trend" into a proper standardised test statistic rather than a slope or a moving-average read.

█ WHAT IT DOES

Computes a standardised Z-statistic for monotonic trend over a rolling window and classifies each confirmed bar as a Significant Uptrend or Significant Downtrend once that statistic crosses a configurable significance threshold. Colours the chart background accordingly, plots both the smoothed and raw Z line in a dedicated pane against static threshold lines, and shows a table with the current state, how long price has been in it, and historical base rates (average forward return and win rate) for each state.

█ THE THEORY BEHIND IT

The Mann-Kendall test was developed to detect a monotonic trend in a time series without assuming any particular distribution or that the trend is linear — it only asks whether values tend to rise (or fall) more often than chance would predict. It does this by comparing every pair of points in a window and tallying how often the later point is higher versus lower than the earlier one. Under the null hypothesis of no trend, that tally has a known variance, which lets the raw count be converted into a Z-score — the same logic behind any standard statistical significance test. A Z-score of 1.645, for example, corresponds to the classic 90% one-tailed critical value: at that level, the observed pattern would be expected by pure chance less than 10% of the time.

This is a meaningfully different question from "has price been going up." A choppy market can have more up-days than down-days without ever producing a statistically significant Z-score; a genuinely persistent trend will.

█ HOW IT IS CALCULATED

1. Over a rolling window, compute S — the sum, across every pair of points in the window, of the sign of (later value − earlier value). A persistent uptrend pushes S strongly positive; a persistent downtrend pushes it strongly negative; a directionless window keeps it near zero.
2. Under the null hypothesis of no trend, S has a known variance: Var(S) = n(n−1)(2n+5) / 18, where n is the window length (this assumes no tied values, a reasonable approximation for continuous price data).
3. Standardise S into a Z-score, with the standard continuity correction applied.
4. Optionally smooth the Z-statistic (it is naturally "steppy," since individual pairs enter and exit the window discretely as new bars form).
5. When smoothed Z rises above the long threshold, the state flips to Significant Uptrend. When it falls below the (negative) short threshold, it flips to Significant Downtrend. Otherwise the state holds — this is hysteresis, not noise.

Classification occurs ONLY on confirmed bar close — the plotted Z, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Source (default close)
• Window Length (default 20, capped at 50 to keep the pairwise comparison fast)
• Long / Short Significance Thresholds (default 1.645 each, the classic 90% one-tailed critical value) — set independently so long and short conviction can be tuned separately rather than assuming symmetric behaviour
• Smoothing Length and Type (default 3-period EMA) — reduces the raw statistic's step-like behaviour
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Table visibility, position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the statistics pane

█ HOW TO USE IT

Use it as a trend-confirmation filter, not a standalone entry trigger. Because it requires the statistic to clear a significance threshold rather than simply cross zero, it tends to flag fewer, more deliberate trend changes than a typical oscillator — useful for filtering out other tools' false starts in choppy conditions. Check the base-rate table's sample count before treating any single state as meaningfully predictive.

Works on any asset and timeframe with sufficient history for the Window Length.

█ LIMITATIONS

• Mann-Kendall tests for a MONOTONIC trend within the window. It says nothing about the trend's magnitude, and any use of it as a precision entry/exit signal is a misuse.
• The variance formula assumes no tied values, which is reasonable for continuous price data but can be mildly optimistic on assets with heavy price discretisation (e.g. very low-priced or thinly-traded instruments).
• The window length is capped at 50 to keep the pairwise comparison fast — larger structural trends spanning more bars are not captured directly.
• The raw Z statistic is discrete and "steppy" by construction; smoothing trades responsiveness for a cleaner state transition.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted, especially in a low-frequency-flip regime or on a short history.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any trend-significance state does not indicate future results. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("RC Tools - Mann-Kendall Trend Significance", shorttitle="RCT Mann-Kendall", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Mann-Kendall Trend Test — Mann, 1945; Kendall, 1975. A genuine nonparametric
// statistical hypothesis test for monotonic trend, most commonly used in
// hydrology and climate-science time-series analysis, applied here to price.
// Independent implementation, built from the public statistical formula.
//
// Unlike a moving-average slope or a "for-loop" rank-vs-history score, this
// produces a standardised Z-statistic with a known null distribution — so the
// output answers "how statistically unlikely is this trend to be pure noise,"
// not just "has price been going up more than down."
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src          = input.source(close, "Source", group="Mann-Kendall")
length       = input.int(14, "Window Length", minval=5, maxval=50, step=1, group="Mann-Kendall",
     tooltip="Pairwise-comparison window. Capped at 50 to keep the O(n²) loop fast.")
zThreshLong  = input.float(1.645, "Long Significance Threshold (Z)", minval=0.5, maxval=3.0, step=0.05, group="Mann-Kendall",
     tooltip="How large the standardised trend statistic must be before a bullish state fires. 1.645 = classic 90% one-tailed critical value.")
zThreshShort = input.float(1.645, "Short Significance Threshold (|Z|)", minval=0.5, maxval=3.0, step=0.05, group="Mann-Kendall",
     tooltip="How large the statistic must be, in magnitude, before a bearish state fires. Split from the long threshold so conviction can be tuned independently per direction.")
smoothLen    = input.int(2, "Smoothing Length", minval=1, maxval=50, step=1, group="Mann-Kendall",
     tooltip="MA smoothing applied to the raw Z statistic before the threshold check. 1 = no smoothing. The raw Z is 'steppy' since individual pairs enter/exit the window discretely.")
smoothType   = input.string("EMA", "Smoothing Type", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group="Mann-Kendall",
     tooltip="Moving-average family used to smooth Z prior to the threshold check.")

bool   showLiveTable = input.bool(true, "Show Live/Confirmed Table", group="Tables")
string livePos       = input.string("Top Middle", "Live/Confirmed Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colBull        = input.color(color.new(color.lime, 60), "Bullish (Z > +Threshold)", group="Colours")
color colBear        = input.color(color.new(color.red,  60), "Bearish (Z < -Threshold)", group="Colours")
bool  paintPaneChart = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// MANN-KENDALL S STATISTIC (pairwise sign sum over the window)
// ─────────────────────────────────────────────────────────────────────────────
f_ma(float srcMa, int len, string kind) =>
    switch kind
        "SMA" => ta.sma(srcMa, len)
        "EMA" => ta.ema(srcMa, len)
        "WMA" => ta.wma(srcMa, len)
        "RMA" => ta.rma(srcMa, len)
        "HMA" => ta.hma(srcMa, len)
        => ta.ema(srcMa, len)

sCount = 0.0
for m1 = 1 to length - 1
    for m2 = 0 to m1 - 1
        float diff = src[m2] - src[m1]
        sCount += diff > 0.0 ? 1.0 : (diff < 0.0 ? -1.0 : 0.0)

n     = length
varS  = n * (n - 1) * (2.0 * n + 5.0) / 18.0
// Standardised Z-score with the standard continuity correction.
zStat = sCount > 0.0 ? (sCount - 1.0) / math.sqrt(varS) : sCount < 0.0 ? (sCount + 1.0) / math.sqrt(varS) : 0.0
zSmooth = smoothLen > 1 ? f_ma(zStat, smoothLen, smoothType) : zStat

ready = bar_index >= length

// Live vote: smoothed Z above +threshold => bullish, below -threshold => bearish,
// otherwise holds the previous state (hysteresis).
var int liveSig = 0
if ready and zSmooth > zThreshLong
    liveSig := 1
if ready and zSmooth < -zThreshShort
    liveSig := 0

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
// State codes: 0 = Bearish (significant downtrend), 1 = Bullish (significant uptrend)
var float dispS        = na
var float dispZ        = na
var int   currentState = na
if barstate.isconfirmed
    dispS        := sCount
    dispZ        := zSmooth
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) => s == 1 ? "Significant Uptrend" : s == 0 ? "Significant Downtrend" : "Warming up…"
stateColor(s) => s == 1 ? colBull : s == 0 ? colBear : na


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
plot(zSmooth, "Z (smoothed)", color=ready ? stateColor(currentState) : color.gray, style=plot.style_line, linewidth=2)
plot(zStat, "Z (raw)", color=color.new(color.gray, 60), linewidth=1)
hline(zThreshLong,   "+Threshold", color=color.new(colBull, 0), linestyle=hline.style_solid)
hline(-zThreshShort, "-Threshold", color=color.new(colBear, 0), linestyle=hline.style_solid)
hline(0.0, "Zero", color=color.new(color.gray, 70))

bgcolor(paintPaneChart and ready ? stateColor(currentState) : na, title="Trend Background (pane)")
bgcolor(paintMainChart and ready ? stateColor(currentState) : na, force_overlay=true, title="Trend Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// TABLES
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"      ? position.top_left :
     p == "Top Middle"    ? position.top_center :
     p == "Bottom Right"  ? position.bottom_right :
     p == "Bottom Middle" ? position.bottom_center :
     p == "Bottom Left"   ? position.bottom_left : position.top_right

liveLabel = ready ? (liveSig == 1 ? "BULL" : "BEAR") : "—"
liveColor = ready ? (liveSig == 1 ? colBull : colBear) : color.gray
confLabel = ready ? (currentState == 1 ? "BULL" : "BEAR") : "—"
confColor = ready ? (currentState == 1 ? colBull : colBear) : color.gray

// ── Table 1: Live (intrabar) vs Confirmed (non-repainting) vote ──────────────
// The live value can still change until the bar closes; only Confirmed is
// safe to trade off.
if showLiveTable and barstate.islast
    var table lt = table.new(getPosition(livePos), 2, 5,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(lt, 0, 0, "Mann-Kendall Trend Significance", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(lt, 1, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(lt, 0, 1, "Live (intrabar)", text_color=color.gray, text_size=size.small)
    table.cell(lt, 1, 1, liveLabel, text_color=color.white, bgcolor=color.new(liveColor, 45), text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 2, "Confirmed", text_color=color.white, text_size=size.small)
    table.cell(lt, 1, 2, confLabel, text_color=color.white, bgcolor=color.new(confColor, 25), text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 3, "Streak", text_color=color.gray, text_size=size.small)
    table.cell(lt, 1, 3, ready ? str.tostring(streak) + " bars" : "—", text_color=color.gray, text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 4, "⚠ Live can change until close — trade off Confirmed only", text_color=color.white, bgcolor=color.new(color.orange, 65), text_halign=text.align_left, text_size=size.small)
    table.merge_cells(lt, 0, 4, 1, 4)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - Mann-Kendall tests for a MONOTONIC trend within the window. It says
//   nothing about the trend's magnitude, and any use of it as a precision
//   entry/exit signal is a misuse.
// - The variance formula assumes no tied values, which is reasonable for
//   continuous price data but can be mildly optimistic on assets with heavy
//   discretisation (e.g. very low-priced or thinly-traded instruments).
// - The window length is capped at 50 to keep the pairwise O(n²) loop fast.
//   Larger structural trends spanning more bars will not be captured directly
//   — combine with a longer-window tool if that matters to your use case.
// - The raw Z statistic is discrete and "steppy" by construction; smoothing
//   trades responsiveness for a cleaner state transition.
// - This script does NOT repaint. All classification updates on confirmed bar
//   close only.
// ─────────────────────────────────────────────────────────────────────────────
````
