# Percentile Context [RC Tools]

- url: https://www.tradingview.com/script/MphD5aIk-Percentile-Context-RC-Tools/
- type: indicator
- pine_id: PUB;66ee9eb79f7b47769eac897c63cbe629
- version: 2.0

## Description

RC Tools — Percentile Context
─────────────────────────────────────────────────────────────

█ OVERVIEW

Not "is RSI over 70" — "where does today's reading actually sit in its own history?" This tool takes a metric of your choice (realised volatility, RSI, volume, rate of change, or any custom source you plug in) and ranks it as a percentile against its own trailing distribution. It's the statistical primitive underneath most technical analysis, made explicit instead of buried in a fixed threshold.

█ WHAT IT DOES

Plots a 0–100 percentile-rank line for the selected metric, flags "extreme" zones (default: below the 10th percentile or above the 90th), and shows a stats table with the current value, current percentile, all-time min/max seen on the chart, and how many bars it's been since the metric last hit either extreme.

█ THE THEORY BEHIND IT

Fixed thresholds ("RSI > 70 = overbought") assume a metric's meaningful range never changes. It does — across assets, and across time on the same asset. A percentile rank fixes this by asking a relative question instead of an absolute one: given everything this metric has done over its own trailing window, how unusual is today's reading? This is the same idea underneath the Regime Classifier's volatility-state measure, generalised to any metric.

█ HOW IT IS CALCULATED

The selected metric is computed per bar:

• Realised Volatility: stdev(log(close/close[1]), N)
• RSI: standard Wilder RSI
• Volume: raw bar volume
• Rate of Change %: (close − close[N]) / close[N] × 100
• Custom Source: whatever series you plug into the source input (e.g. another indicator's plot)

The metric is then percentile-ranked against its own trailing window (default 750 bars ≈ 3 years on daily): what percentage of the last N readings were below today's value. Display values update ONLY on confirmed bar close — nothing here repaints.

█ SETTINGS & CONFIGURATION

• Metric (default Realised Volatility) — what gets ranked
• Custom Source — only used when Metric = Custom Source
• Realised Volatility / RSI / Rate of Change lookbacks (defaults 20 / 14 / 20)
• Percentile Ranking Window (default 750 bars) — longer = more stable, needs more history
• Low / High Extreme Thresholds (default 10 / 90)
• Paint Main Chart Background — off by default to avoid clashing with the Regime Classifier's background if you run both at once

█ HOW TO USE IT

Use it to calibrate how seriously to take a "normal" indicator reading. Example: RSI at 75 means something different on a stock that's rarely above 60 than on one that regularly touches 85 — the percentile rank makes that comparison explicit for the SAME asset over time. Also useful for volatility context ahead of position sizing: current realised vol at the 95th percentile is a different risk environment than the same absolute vol reading at the 40th percentile.

Works on any asset and timeframe with sufficient history for the percentile window.

█ LIMITATIONS

• Percentile rank describes the past relative to itself — it says nothing about direction or what happens next. A metric at its 99th percentile can stay there.
• Needs substantial history for a stable ranking. On short-history assets, treat the percentile as unreliable.
• "Extreme" is relative to the metric's OWN range. A percentile extreme on a low-volatility asset is not directly comparable in absolute terms to one on a high-volatility asset — that's the point of the tool, but it means percentiles aren't comparable across symbols.
• All-time min/max and "bars since" stats are only as long as the chart's available history, not a fixed universal record.
• This script does NOT repaint. Display values update on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any metric does not indicate future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Percentile Context [RC Tools]", shorttitle="RCT Pctl Context", overlay=false, precision=2)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Not "is RSI over 70" — "where does today's reading sit in its own trailing
// distribution?" This is the statistical primitive underneath most technical
// analysis, made explicit. Pick a metric, rank it as a percentile against its
// own history, and see how extreme "extreme" actually is.
//
// Classification/table values update ONLY on confirmed bar close, so nothing
// here repaints. See the "Limitations" section at the bottom of this file.
// ─────────────────────────────────────────────────────────────────────────────



// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// ── Metric Selection ──────────────────────────────────────────────────────────
string srcMode  = input.string("Realised Volatility", "Metric", options=["Realised Volatility", "RSI", "Volume", "Rate of Change %", "Custom Source"], group="Metric",
     tooltip="Choose what gets percentile-ranked. 'Custom Source' uses the source input below (e.g. plug in another indicator's output).")
float customSrc = input.source(close, "Custom Source (used only if Metric = Custom Source)", group="Metric")

int rvLen  = input.int(20, "Realised Volatility Lookback", minval=2, group="Metric")
int rsiLen = input.int(14, "RSI Length", minval=2, group="Metric")
int rocLen = input.int(20, "Rate of Change Length", minval=1, group="Metric")

// ── Percentile Window ─────────────────────────────────────────────────────────
int pctWindow = input.int(750, "Percentile Ranking Window (bars)", minval=50, group="Percentile",
     tooltip="Trailing window the metric is ranked against. Default ≈ 3 years on the daily timeframe. Longer = more stable, needs more history.")
int lowExtreme  = input.int(10, "Low Extreme Threshold", minval=1, maxval=49, group="Percentile")
int highExtreme = input.int(90, "High Extreme Threshold", minval=51, maxval=99, group="Percentile")

// ── Display ────────────────────────────────────────────────────────────────────
bool showTable      = input.bool(true, "Show Stats Table", group="Display")
string tablePos     = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background on Extremes", group="Display",
     tooltip="Uses force_overlay to highlight the price chart when the metric is in an extreme zone. Off by default to avoid clashing with the Regime Classifier's background if you run both.")
color colLow    = input.color(color.new(color.blue,   70), "Low Extreme Colour",  group="Display")
color colHigh   = input.color(color.new(color.red,    70), "High Extreme Colour", group="Display")
color colNormal = input.color(color.new(color.gray,   92), "Normal Zone Colour",  group="Display")


// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// ── Raw metric, per selected mode ─────────────────────────────────────────────
float metric = switch srcMode
    "Realised Volatility" => ta.stdev(math.log(close / close[1]), rvLen)
    "RSI"                 => ta.rsi(close, rsiLen)
    "Volume"              => volume
    "Rate of Change %"    => ta.roc(close, rocLen)
    "Custom Source"       => customSrc
    => na

// ── Percentile rank vs own trailing distribution ──────────────────────────────
float rawPctRank = ta.percentrank(metric, pctWindow)
bool  warmedUp   = bar_index >= pctWindow and not na(rawPctRank)

// ── Confirmed-close-only display (non-repainting) ─────────────────────────────
// The displayed percentile only updates when a bar is confirmed, so the
// table and extreme-zone flags never flicker mid-bar and then reverse.
var float pctRank = na
if barstate.isconfirmed
    pctRank := warmedUp ? rawPctRank : na

bool isLow  = not na(pctRank) and pctRank <= lowExtreme
bool isHigh = not na(pctRank) and pctRank >= highExtreme

zoneColor = isLow ? colLow : isHigh ? colHigh : colNormal


// ─────────────────────────────────────────────────────────────────────────────
// ALL-TIME MIN / MAX AND "LAST SEEN" TRACKING
// ─────────────────────────────────────────────────────────────────────────────
var float allTimeMin = na
var float allTimeMax = na
var int   lastHighBar = na
var int   lastLowBar  = na

if barstate.isconfirmed and not na(metric)
    allTimeMin := na(allTimeMin) ? metric : math.min(allTimeMin, metric)
    allTimeMax := na(allTimeMax) ? metric : math.max(allTimeMax, metric)
    if isHigh
        lastHighBar := bar_index
    if isLow
        lastLowBar := bar_index

barsSinceHigh = na(lastHighBar) ? na : bar_index - lastHighBar
barsSinceLow  = na(lastLowBar)  ? na : bar_index - lastLowBar


// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(pctRank, "Percentile Rank", color=color.new(color.aqua, 0), linewidth=2)
hline(50, "Median", color=color.gray, linestyle=hline.style_dotted)
hline(lowExtreme,  "Low Extreme",  color=colLow,  linestyle=hline.style_dashed)
hline(highExtreme, "High Extreme", color=colHigh, linestyle=hline.style_dashed)

bgcolor(warmedUp ? zoneColor : na, title="Extreme Zone (pane)")
bgcolor(paintMainChart and warmedUp ? zoneColor : na, force_overlay=true, title="Extreme Zone (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// STATS TABLE
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"     ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left : position.top_right

fmt(v) => na(v) ? "—" : str.tostring(v, "#.##")

if showTable and barstate.islast
    var table t = table.new(getPosition(tablePos), 2, 7,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(t, 0, 0, "Percentile Context", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Metric", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, srcMode, text_color=color.white, text_size=size.small)

    table.cell(t, 0, 2, "Current Value", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, fmt(metric), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 3, "Percentile Rank", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, warmedUp ? fmt(pctRank) : "Warming up…", text_color=warmedUp ? zoneColor : color.gray, text_size=size.small)

    table.cell(t, 0, 4, "All-Time Min / Max", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, fmt(allTimeMin) + " / " + fmt(allTimeMax), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 5, "Bars Since Last High", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 5, na(barsSinceHigh) ? "—" : str.tostring(barsSinceHigh), text_color=colHigh, text_size=size.small)

    table.cell(t, 0, 6, "Bars Since Last Low", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 6, na(barsSinceLow) ? "—" : str.tostring(barsSinceLow), text_color=colLow, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - Percentile rank describes the PAST relative to itself. It says nothing
//   about direction or what happens next.
// - Needs substantial history for a stable ranking (default window ≈3 years
//   daily). On short-history assets, treat the percentile as unreliable.
// - "Extreme" is relative to the metric's OWN range — a percentile extreme on
//   a low-volatility asset is not comparable in absolute terms to one on a
//   high-volatility asset. That is the point of the tool, not a flaw, but it
//   means percentiles are not directly comparable across different symbols.
// - All-time min/max and "bars since" stats are only as long as the chart's
//   available history in this session; they are not a fixed universal record.
// - This script does NOT repaint. Display values update on confirmed close only.
// ─────────────────────────────────────────────────────────────────────────────
````
