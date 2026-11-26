# Flow-Regime

- url: https://www.tradingview.com/script/W46mSzC6-Flow-Regime/
- type: indicator
- pine_id: PUB;524931f29a294520a8f0bee01bb59da4
- version: 2.0

## Description

Flow-Regime

A multi-source flow oscillator. It normalizes three independent measures of
market flow to a unified ±100 scale and combines them into a conviction-
weighted composite line, so you can see at a glance whether OBV, A/D, and
price flow are agreeing or diverging.

▌ What's plotted

Three normalized lines, each computed through the same pipeline
(CCI → percentrank → linear map to ±100):

  • OBV-Flow — On-Balance Volume (signed cumulative volume)
  • AD-Flow — Chaikin Accumulation/Distribution
  • Price-Regime — price flow (ohlc4)

Plus a Fitted composite — the average of the three, amplified by |conviction|,
where conviction = average ÷ mean(|x|, |y|, |z|). When all three lines agree
the composite is amplified; when they conflict it is suppressed toward zero.
The Fitted line uses 5-tier coloring driven by how many of the three exceed
the neutral threshold (default ±20): solid green/red = all three agree, lighter
shades = two of three, gray = no consensus.

▌ Two lookback modes

Linear (default) — TF-specific lookback with sensible per-timeframe defaults
(1m=60, 5m=24, 15m=16, 1h=24, 4h=18, 1d=7, 1w=12, 1M=12), all editable.

Anchored — pick an anchor timestamp; the percentrank window grows from 0 at
that bar to (current_bar − anchor_bar) at the right edge of the chart. Use
this to lock the statistical baseline to a specific event — a regime start,
a major breakout, a news release. The anchor bar is marked with a yellow
diamond at fitted = 0.

▌ How to read it

The OB zone (≥ +70) and OS zone (≤ −70) are shaded — these are statistically
stretched conditions. Bars where the Fitted line reaches ±99 get a soft red/
green background tint as an "at the extreme" warning. Two corresponding alert
conditions are exposed for use with TV alerts.

This indicator does NOT emit trade signals. Per-line reversal dots and
confluence triangles are intentionally absent: those patterns can fit
historical noise convincingly without generalizing forward. Treat extremes
as flags to investigate, not entries to take.

Useful interpretive frames:

  • All three lines extreme in the same direction = strongest evidence of
    flow consensus.
  • One or two lines diverging from the others at extremes = a divergence
    worth examining on the chart.
  • Fitted approaching ±99 = statistical extreme, regardless of direction.

▌ Notes

In Anchored mode, the first few bars after the anchor have very few historical
points to rank against, so percentrank values can swing to ±100 from sparse
data — read these bars with caution. CCI itself always uses the full real
price history regardless of mode, so its 20-bar internal window is never
distorted by the anchor.

Enable the Debug label in settings to verify which mode and lookback are
currently active on the chart.

## Source Code

````pine
//@version=6
// =========================================================================
//  Flow-Regime  —  QTSE V7 auxiliary module
//
//  Three ±100-normalized flow lines (OBV / AD / Price) + fitted composite.
//
//  Pipeline per line:  CCI(len) → percentrank(lookback) → map to ±100
//  Fitted composite:   avg * |conviction|, where conviction = avg / mean(|x|,|y|,|z|)
//
//  Lookback resolution has two modes:
//    • Linear     — TF-specific lookback per chart TF (default).
//    • Anchored   — lookback grows from 0 at a user-defined anchor bar
//                   (regime start, breakout, news release, etc.).
// =========================================================================
indicator("Flow-Regime", "Flow-Regime", overlay=false, precision=1,
     max_labels_count=500, max_bars_back=5000)

// ───────── INPUTS ─────────
grpCore = "Core Parameters"
cciLen     = input.int(20,  "CCI Length",       minval=2,   group=grpCore)
obThr      = input.int(70,  "OB Threshold",     minval=0,   maxval=100, group=grpCore)
osThr      = input.int(-70, "OS Threshold",     minval=-100, maxval=0,  group=grpCore)
neutralThr = input.int(20,  "Neutral Threshold", minval=0, maxval=100, group=grpCore,
     tooltip="Coloring-only threshold (does not affect triggers).\n" +
             "• CCI-Colored mode: each line is green above +Neutral, red below −Neutral, gray in between.\n" +
             "• Fitted line 5-tier coloring: counts how many lines exceed ±Neutral.")

// ── Lookback Mode ──
grpMode = "Lookback Mode"
lbMode = input.string("Linear", "Mode", options=["Linear", "Anchored"], group=grpMode,
     tooltip="Linear: TF-specific lookback per chart TF.\n" +
             "Anchored: lookback = bars since the anchor timestamp below.\n\n" +
             "In Anchored mode, percentrank's window grows from 0 at the anchor bar " +
             "to (current_bar − anchor_bar) at the chart's right edge.")

// Anchor timestamp — TV renders a native datetime picker (precision: minute).
anchorTime = input.time(timestamp("2026-01-01 00:00 +0000"),
     "Anchor Time (Anchored mode only)", group=grpMode,
     tooltip="The bar containing this timestamp becomes the statistical baseline.\n" +
             "Bars at or before this time produce fitted = 0.\n" +
             "Bars after: percentrank is computed only over post-anchor history.\n\n" +
             "Note: TV automatically aligns the timestamp to the nearest bar on the " +
             "current chart TF. E.g., 09:15 on a 1h chart resolves to the 09:00 bar.\n\n" +
             "If the anchor is set in the future, all bars produce fitted = 0 — " +
             "enable the Debug label to verify.")

// ── Lookback period — TF-specific (Linear mode) ──
grpLB = "Linear Mode: Lookback Period (by TF)"
lb_1m  = input.int(60, "1m  default lookback",  minval=10, group=grpLB)
lb_5m  = input.int(24, "5m  default lookback",  minval=10, group=grpLB)
lb_15m = input.int(16, "15m default lookback",  minval=10, group=grpLB)
lb_1h  = input.int(24, "1h  default lookback",  minval=10, group=grpLB)
lb_4h  = input.int(18, "4h  default lookback",  minval=10, group=grpLB)
lb_1d  = input.int(7,  "1d  default lookback",  minval=3,  group=grpLB)
lb_1w  = input.int(12, "1w  default lookback",  minval=3,  group=grpLB)
lb_1M  = input.int(12, "1M  default lookback",  minval=3,  group=grpLB)

// Resolve effective lookback from chart TF (Linear mode)
tfSec = timeframe.in_seconds(timeframe.period)
lb_auto = tfSec <= 120 ? lb_1m : tfSec <= 540 ? lb_5m : tfSec <= 1800 ? lb_15m : tfSec <= 7200 ? lb_1h : tfSec <= 21600 ? lb_4h : tfSec <= 86400 ? lb_1d : tfSec <= 604800 ? lb_1w : lb_1M
lookback_linear = math.max(lb_auto, 3)

// ── Anchor bar counter (Anchored mode) ──
// On the anchor bar:    bars_since = 1 → lb_dyn = 0 → percentrank = 50 → fitted = 0.
// Pre-anchor / future:  bars_since = 0 → lb_dyn = 0 → fitted = 0.
var int bars_since_anchor = 0
isAfterAnchor = time >= anchorTime
if isAfterAnchor
    bars_since_anchor := bars_since_anchor + 1
else
    bars_since_anchor := 0

// The anchor bar itself shouldn't rank against itself — subtract 1.
lb_dyn = math.max(bars_since_anchor - 1, 0)

// ── Line visibility / coloring ──
grpLines = "Line Visibility"
showFit   = input.bool(true,  "Show Fitted Line (main)", group=grpLines)
showOBV   = input.bool(false, "Show OBV-Flow",            group=grpLines)
showAD    = input.bool(false, "Show AD-Flow",             group=grpLines)
showPrice = input.bool(false, "Show Price-Regime",        group=grpLines)

grpStyle = "Line Coloring"
colorMode = input.string("CCI-Colored", "Line Color Mode",
     options=["CCI-Colored", "Distinct"], group=grpStyle,
     tooltip="CCI-Colored: every line green/red/gray by its own ±20 threshold.\n" +
             "Distinct: three fixed colors (OBV=red, AD=green, Price=blue).")

grpDebug = "Debug"
showLBLabel = input.bool(false, "Show active lookback in top-right", group=grpDebug,
     tooltip="Shows current mode, active lookback value, and (if Anchored) bars-since-anchor.")

// ───────── INPUT SERIES ─────────
direction  = nz(math.sign(ta.change(close)))
obv_series = ta.cum(direction * volume)

clv_den   = high - low
clv       = clv_den != 0 ? ((close - low) - (high - close)) / clv_den : 0.0
ad_series = ta.cum(clv * volume)

price_src = (open + high + low + close) / 4.0

// ───────── PERCENTRANK — Linear vs Anchored ─────────
// Linear path uses ta.percentrank (simple-int length, fast).
// Anchored path needs a hand-written version (series-int length).
// Both compute the rank of `src` over the trailing `len` bars.
f_percentrank_dyn(src, len) =>
    float result = 50.0   // fallback when len < 1 (anchor bar / pre-anchor)
    if len >= 1
        float cnt = 0.0
        for i = 1 to len
            if not na(src[i]) and src[i] < src
                cnt := cnt + 1
        result := 100.0 * cnt / len
    result

// ───────── METHOD A: CCI → percentrank → ±100 ─────────
// CCI uses the full real-price history regardless of mode — this is critical.
// Zeroing pre-anchor data would corrupt CCI's 20-bar window for the first
// ~20 bars after the anchor and contaminate the entire output.
f_flow(src) =>
    c   = ta.cci(src, cciLen)
    pr  = lbMode == "Linear" ? ta.percentrank(c, lookback_linear) / 100.0 : f_percentrank_dyn(c, lb_dyn) / 100.0
    (pr - 0.5) * 200.0

obv_flow   = f_flow(obv_series)
ad_flow    = f_flow(ad_series)
price_flow = f_flow(price_src)

// ───────── FITTED LINE ─────────
avg_val    = (obv_flow + ad_flow + price_flow) / 3.0
abs_mean   = (math.abs(obv_flow) + math.abs(ad_flow) + math.abs(price_flow)) / 3.0
conviction = abs_mean != 0 ? avg_val / abs_mean : 0.0
fitted     = avg_val * math.abs(conviction)

// ───────── COLORING ─────────
f_cci_color(v) =>
    v >  neutralThr ? color.new(color.green, 0) :
     v < -neutralThr ? color.new(color.red,  0) :
                       color.new(color.gray, 30)

c_obv_dist   = color.new(#d62728, 0)
c_ad_dist    = color.new(#2ca02c, 0)
c_price_dist = color.new(#1f77b4, 0)

col_obv   = colorMode == "CCI-Colored" ? f_cci_color(obv_flow)   : c_obv_dist
col_ad    = colorMode == "CCI-Colored" ? f_cci_color(ad_flow)    : c_ad_dist
col_price = colorMode == "CCI-Colored" ? f_cci_color(price_flow) : c_price_dist

bullCnt = (obv_flow >  neutralThr ? 1 : 0) + (ad_flow >  neutralThr ? 1 : 0) + (price_flow >  neutralThr ? 1 : 0)
bearCnt = (obv_flow < -neutralThr ? 1 : 0) + (ad_flow < -neutralThr ? 1 : 0) + (price_flow < -neutralThr ? 1 : 0)

col_fit = bullCnt == 3 ? color.new(color.green, 0)  :
          bearCnt == 3 ? color.new(color.red,   0)  :
          bullCnt == 2 ? color.new(color.green, 40) :
          bearCnt == 2 ? color.new(color.red,   40) :
                         color.new(color.gray,  20)

// ───────── OB/OS BACKGROUND ─────────
// hline() requires compile-time constants; use invisible plots + fill instead.
p_top = plot(100,    "(top)",    display=display.none, editable=false)
p_ob  = plot(obThr,  "(ob thr)", display=display.none, editable=false)
p_os  = plot(osThr,  "(os thr)", display=display.none, editable=false)
p_bot = plot(-100,   "(bot)",    display=display.none, editable=false)

fill(p_top, p_ob,  color=color.new(color.red,   92), title="OB Zone")
fill(p_os,  p_bot, color=color.new(color.green, 92), title="OS Zone")

plot(0, "Zero", color=color.new(color.gray, 60), linewidth=1, editable=false)

// ───────── LINES ─────────
plot(showOBV   ? obv_flow   : na, "OBV-Flow",     color=col_obv,   linewidth=1)
plot(showAD    ? ad_flow    : na, "AD-Flow",      color=col_ad,    linewidth=1)
plot(showPrice ? price_flow : na, "Price-Regime", color=col_price, linewidth=1)
plot(showFit   ? fitted     : na, "Fitted",       color=col_fit,   linewidth=3)

// ───────── ANCHOR MARKER (Anchored mode visual aid) ─────────
// A yellow diamond at fitted = 0 on the anchor bar — visually reinforces
// that the anchor establishes 0 as the baseline (not +100 / not -100).
isAnchorBar = bars_since_anchor == 1
plotshape(lbMode == "Anchored" and isAnchorBar ? 0 : na, "Anchor",
     shape.diamond, location.absolute, color=color.new(color.yellow, 0),
     size=size.small)

// ───────── FITTED EXTREME WARNING ─────────
// The only directional cue this indicator emits. Per-line reversal dots and
// confluence triangles were removed: those patterns were derived from data
// we now know is overfit, and would mislead before regime-gating is in place.
fitted_warn_high = fitted >=  99
fitted_warn_low  = fitted <= -99

// Subtle bg tint on the warning bar. Color is directional only as a readability
// aid (matches the panel's red/green OB/OS regions), NOT as a trade cue.
bgcolor(fitted_warn_high ? color.new(color.red,   85) : na, title="Fitted ≥ +99")
bgcolor(fitted_warn_low  ? color.new(color.green, 85) : na, title="Fitted ≤ −99")

// ───────── ALERTS ─────────
alertcondition(fitted_warn_high, "Fitted extreme high (≥ +99)",
     "Flow-Regime: fitted line at upper extreme")
alertcondition(fitted_warn_low,  "Fitted extreme low (≤ −99)",
     "Flow-Regime: fitted line at lower extreme")

// ───────── DEBUG: show active mode & lookback on the last bar ─────────
if showLBLabel and barstate.islast
    string txt = ""
    if lbMode == "Linear"
        bucket = tfSec <= 120 ? "1m" : tfSec <= 540 ? "5m" : tfSec <= 1800 ? "15m" : tfSec <= 7200 ? "1h" : tfSec <= 21600 ? "4h" : tfSec <= 86400 ? "1d" : tfSec <= 604800 ? "1w" : "1M"
        txt := "Linear  lookback=" + str.tostring(lookback_linear) + "  (auto:" + bucket + ")"
    else
        anchorReached = bars_since_anchor > 0
        txt := anchorReached ?
             "Anchored  bars_since=" + str.tostring(bars_since_anchor) + "  lb_dyn=" + str.tostring(lb_dyn) :
             "Anchored  ⚠ anchor in future — all bars = 0"
    label.new(bar_index, 90, txt,
         style=label.style_label_down, color=color.new(color.blue, 80),
         textcolor=color.white, size=size.small)
````
