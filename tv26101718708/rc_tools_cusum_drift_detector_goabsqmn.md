# RC Tools - CUSUM Drift Detector

- url: https://www.tradingview.com/script/gOaBSqmn-RC-Tools-CUSUM-Drift-Detector/
- type: indicator
- pine_id: PUB;5e07c081cf25445fb0dd1f630a06ff48
- version: 2.0

## Description

────────────────────────────────────────────────────────────────────

█ OVERVIEW

Most trend tools measure a single bar or a moving-average deviation, so a slow, persistent drift that never produces one dramatic bar can slip under their radar. This tool applies CUSUM — Cumulative Sum Control Chart, a classical statistical process control technique — to detect exactly that: a sustained departure from "no drift" that accumulates over many small moves rather than one large one.

█ WHAT IT DOES

Tracks two running sums of log returns — one for upward drift, one for downward — and flags a directional regime once the accumulated drift breaches a volatility-scaled threshold. Colours the chart background Bullish or Bearish Drift accordingly, plots the two accumulating sums against their threshold lines in a dedicated pane, and shows a table with the current state, how long price has been in it, and historical base rates (average forward return and win rate) for each state.

█ THE THEORY BEHIND IT

CUSUM was developed by E.S. Page in 1954 for detecting a persistent shift in a manufacturing process mean — the same statistical question as "has this market started drifting in a new direction," just applied to price instead of a factory line. The key property that separates it from a moving average or a single-bar threshold: CUSUM accumulates. A string of small, consistent moves in one direction builds up and eventually crosses the detection threshold, even if no individual bar looks remarkable. Pure noise — moves that cancel out — never accumulates at all, because a small "allowance" is subtracted from every observation before it's added to the running sum.

Critically, the reference point CUSUM measures departure from is fixed at zero, not a rolling average of the same series. A rolling mean would chase the trend and cancel out the very drift being measured — anchoring at a fixed "no drift" baseline is what makes the classical test work.

█ HOW IT IS CALCULATED

1. Compute log returns of the selected source.
2. Estimate sigma — the rolling standard deviation of those log returns over the Window Length — as the local noise scale.
3. Two running sums accumulate each bar:
   S+ = max(0, S+ prev + (log return − k))  — accumulates upward drift
   S− = min(0, S− prev + (log return + k))  — accumulates downward drift
   where k (the Drift Allowance) is a small multiple of sigma, subtracted out so ordinary noise never builds a signal.
4. When S+ crosses above the threshold h (a larger multiple of sigma), a sustained upward drift is declared, the background flips Bullish, and S+ resets to zero to begin monitoring fresh. S− works symmetrically for downward drift.
5. Between detections, the classification holds — this is deliberate persistence, not a bug: CUSUM is built to answer "has the regime changed," not to flicker every bar.

Classification occurs ONLY on confirmed bar close — the plotted sums, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Source (default close)
• Window Length (default 14) — rolling window for the sigma (noise-scale) estimate
• Decision Threshold h (default 2.0σ) — how much accumulated drift is required before a regime shift is declared
• Drift Allowance k (default 0.2σ) — moves smaller than this are subtracted out and never accumulate
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Table position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the CUSUM pane

█ HOW TO USE IT

Use it as a slow-drift filter alongside faster tools, not as a standalone entry trigger. Because CUSUM only flips after drift has genuinely accumulated, it tends to confirm a regime later than a fast oscillator but with fewer false starts in choppy conditions — the trade-off is lag for reliability. Check the base-rate table's sample count before treating any single state as meaningfully predictive.

Works on any asset and timeframe with sufficient history for the Window Length.

█ LIMITATIONS

• CUSUM detects a PERSISTENT departure from zero drift, not a magnitude or overbought/oversold level. Any use of it as a precise reversal forecast is a misuse.
• The fixed zero reference is directional-agnostic to any trend that existed before the current accumulation window began — it only measures drift accumulated since the last reset.
• h and k are both expressed in sigma multiples; a poorly-fit Window Length will misclassify ordinary volatility as drift, or vice versa.
• Resets on trigger mean the tool can flip again quickly after one large accumulation event, then need to rebuild before flipping a second time.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted, especially in a low-frequency-flip regime or on a short history.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any drift state does not indicate future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("RC Tools - CUSUM Drift Detector", shorttitle="RCT CUSUM", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// CUSUM (Cumulative Sum Control Chart) — Page, 1954. A public-domain technique
// from statistical process control: sequential monitoring for a PERSISTENT
// shift in a process mean, rather than a simple deviation-from-moving-average
// band. Independent implementation, built from the public formula description.
//
// Unlike a moving-average crossover, CUSUM accumulates small departures from a
// fixed zero reference over time — a series of small, consistent moves in one
// direction can trigger a signal well before any single bar looks significant,
// while pure noise (moves that cancel out) never accumulates at all.
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src    = input.source(close, "Source", group="CUSUM")
length = input.int(14, "Window Length", minval=5, maxval=100, step=1, group="CUSUM",
     tooltip="Rolling window used to estimate the volatility baseline (sigma). Whole-bar steps only.")
hMult  = input.float(2.0, "Decision Threshold h (σ multiple)", minval=1.0, maxval=10.0, step=0.5, group="CUSUM",
     tooltip="How many standard deviations of accumulated drift are required before a regime shift is declared.")
kMult  = input.float(0.2, "Drift Allowance k (σ multiple)", minval=0.0, maxval=2.0, step=0.1, group="CUSUM",
     tooltip="Moves smaller than k×σ are subtracted out and never accumulate — this is what keeps ordinary noise from building a false signal.")

bool   showLiveTable = input.bool(true, "Show Live/Confirmed Table", group="Tables")
string livePos       = input.string("Top Middle", "Live/Confirmed Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colBull        = input.color(color.new(color.lime, 60), "Bullish (S+)", group="Colours")
color colBear        = input.color(color.new(color.red,  60), "Bearish (S-)", group="Colours")
bool  paintPaneChart = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// CUSUM CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
// mu = fixed reference of 0 (NOT a rolling mean). Classical Page's test requires
// a stable, known target to detect departure FROM — a rolling mean of the same
// series you're monitoring would chase the trend and cancel out the very drift
// you're trying to detect. Anchoring at 0 tests "is there a persistent departure
// from no-drift," which is the textbook-correct formulation.
//
// sigma = rolling stdev of log returns (this one SHOULD adapt — it's the local
// noise scale, not the target).
logRet = math.log(src / src[1])
mu     = 0.0
sigma  = ta.stdev(logRet, length)
ready  = not na(sigma) and sigma > 0.0

kVal = ready ? kMult * sigma : 0.0
hVal = ready ? hMult * sigma : 0.0

xDevPos = ready ? logRet - mu - kVal : 0.0
xDevNeg = ready ? logRet - mu + kVal : 0.0

// Two running sums:
//   S+ = max(0, S+_prev + (logRet - k))  — accumulates upward drift
//   S- = min(0, S-_prev + (logRet + k))  — accumulates downward drift
var float sPos = 0.0
var float sNeg = 0.0
sPos := math.max(0.0, nz(sPos[1], 0.0) + xDevPos)
sNeg := math.min(0.0, nz(sNeg[1], 0.0) + xDevNeg)

// Live vote: S+ breaches +h => bullish, S- breaches -h => bearish, else holds
// the previous vote (persistence). Resets the breaching sum to 0 on trigger —
// classic Page's-test behaviour — to start monitoring fresh.
var int liveSig = 0
if ready and sPos > hVal
    liveSig := 1
    sPos    := 0.0
if ready and sNeg < -hVal
    liveSig := 0
    sNeg    := 0.0

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
// State codes: 0 = Bearish drift, 1 = Bullish drift
var float dispSPos     = na
var float dispSNeg     = na
var int   currentState = na
if barstate.isconfirmed
    dispSPos     := sPos
    dispSNeg     := sNeg
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) => s == 1 ? "Bullish Drift" : s == 0 ? "Bearish Drift" : "Warming up…"
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
plot(sPos,  "S+ (upward drift)",   color=color.new(colBull, 0), linewidth=2, style=plot.style_columns)
plot(sNeg,  "S- (downward drift)", color=color.new(colBear, 0), linewidth=2, style=plot.style_columns)
plot(hVal,  "+h threshold", color=color.new(color.gray, 40), style=plot.style_line)
plot(-hVal, "-h threshold", color=color.new(color.gray, 40), style=plot.style_line)
hline(0.0, "Zero", color=color.new(color.gray, 80))

bgcolor(paintPaneChart and ready ? stateColor(currentState) : na, title="Drift Background (pane)")
bgcolor(paintMainChart and ready ? stateColor(currentState) : na, force_overlay=true, title="Drift Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// STATS TABLE
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

    table.cell(lt, 0, 0, "CUSUM Drift Detector", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
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
// - CUSUM detects a PERSISTENT departure from zero drift. It is not a magnitude
//   or overbought/oversold measure, and any use of it as a forecast is a misuse.
// - The fixed zero reference means CUSUM is directional-agnostic to any trend
//   that already existed before the current accumulation window started — it
//   only measures drift accumulated since the last reset.
// - h and k are both expressed in sigma multiples; a badly-fit "Window Length"
//   for sigma will misclassify ordinary volatility as drift, or vice versa.
// - Resets on trigger mean the tool can flip quickly after a large single
//   accumulation event, then need to rebuild before flipping again.
// - This script does NOT repaint. All classification updates on confirmed bar
//   close only.
// ─────────────────────────────────────────────────────────────────────────────
````
