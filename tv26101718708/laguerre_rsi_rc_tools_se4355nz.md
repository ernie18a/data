# Laguerre RSI [RC Tools]

- url: https://www.tradingview.com/script/SE4355nz-Laguerre-RSI-RC-Tools/
- type: indicator
- pine_id: PUB;e5069794ad3d4596b9e949b0f8eb2e91
- version: 1.0

## Description

RC Tools — Laguerre RSI
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Standard RSI computes gains and losses over a fixed lookback window, which means its reading is partly a function of what happens to fall in and out of that window as bars roll forward — not just what price is actually doing. John Ehlers' Laguerre RSI replaces the fixed window entirely with a 4-stage recursive filter, producing a bounded oscillator that is smoother and reacts with meaningfully less lag than a standard RSI at a comparable responsiveness.

█ WHAT IT DOES

Runs price through a 4-stage Laguerre filter cascade and computes an RSI-style ratio from the up/down relationships between adjacent filter stages, producing a bounded 0-1 oscillator. Classifies each confirmed bar as Bullish or Bearish on a midline (0.5) crossover, colours the chart background accordingly, plots the oscillator against reference Overbought/Oversold lines, and shows a table with the live (intrabar) and confirmed vote side by side, plus how long price has been in the current state.

█ THE THEORY BEHIND IT

A standard RSI's behaviour is tied to its lookback window: a sharp move several bars ago can still be influencing today's reading, right up until it falls out of the window, at which point the reading can shift even if nothing happened today. Ehlers' insight was to replace the fixed window with a Laguerre filter — a cascade of stages related to all-pass filters, each one a damped combination of the current and prior stage — controlled by a single damping factor rather than a lookback length. The RSI-style up/down ratio is then computed across the filter's own stages rather than across historical bars, which is what gives Laguerre RSI its smoother, faster-reacting character relative to a standard RSI.

█ HOW IT IS CALCULATED

1. Run price through four cascaded Laguerre stages (L0 through L3), each a damped recursive combination of the current input and the prior bar's stage values, controlled by the damping factor gamma.
2. For each of the three adjacent stage pairs (L0/L1, L1/L2, L2/L3), add the positive difference to a cumulative-up total (CU) if the earlier stage is greater or equal, otherwise add the difference to a cumulative-down total (CD).
3. Laguerre RSI = CU / (CU + CD), bounded 0 to 1.
4. The state classification uses a midline (0.5) crossover: LRSI crossing above 0.5 is classified Bullish, crossing below is classified Bearish. Between crossovers, the classification holds. The plotted Overbought/Oversold lines are reference context only and do not drive this classification.

Classification occurs ONLY on confirmed bar close — the plotted LRSI value, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Source (default close)
• Damping Factor / gamma (default 0.5, Ehlers' classical value) — higher is smoother and slower, lower is faster and noisier
• Overbought / Oversold Levels (default 0.85 / 0.15) — reference lines only, plotted for context
• Table visibility, position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the statistics pane

█ HOW TO USE IT

Use it as a smoother, lower-lag alternative to a standard RSI for gauging momentum state, not as a standalone entry signal. The Overbought/Oversold reference lines can be used the way you'd use classic RSI bands — as a visual cue for stretched conditions — even though they don't drive the Bullish/Bearish classification itself. The Live row can still change until the bar closes; only the Confirmed row is safe to treat as settled.

Works on any asset and timeframe.

█ LIMITATIONS

• Laguerre RSI is a BOUNDED 0-1 oscillator, not a magnitude measure. Any use of it as a precision reversal forecast is a misuse.
• The classification here is driven by the midline (0.5) crossover, not the plotted Overbought/Oversold levels — those are reference lines only.
• The damping factor (gamma) trades responsiveness for smoothness just like a lookback length would in a standard RSI; there is no single correct value for every asset or timeframe.
• Because the filter replaces a fixed lookback with recursive stages, it has no hard "warm-up window" the way a standard RSI does — early bars converge gradually rather than becoming reliable at a fixed bar count.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any momentum state does not indicate future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Laguerre RSI [RC Tools]", shorttitle="RCT Laguerre RSI", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Laguerre RSI — John Ehlers, 2001 ("Time Warp — Without Space Travel,"
// republished in Cybernetic Analysis for Stocks and Futures). A public,
// well-documented technique. Independent implementation, built from the
// public formula.
//
// Standard RSI computes gains/losses over a fixed lookback window, which
// means it reacts to data falling in and out of that window rather than to
// price itself. Laguerre RSI replaces the fixed window with a 4-stage
// Laguerre filter — a cascade of all-pass-like stages controlled by a single
// damping factor — and computes the up/down ratio across the filter's own
// internal stages instead. The result is a bounded 0-1 oscillator that is
// smoother and reacts with less lag than a standard fixed-window RSI at a
// comparable responsiveness.
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src      = input.source(close, "Source", group="Laguerre RSI")
gamma    = input.float(0.5, "Damping Factor (gamma)", minval=0.01, maxval=0.99, step=0.01, group="Laguerre RSI",
     tooltip="Controls the Laguerre filter's responsiveness. Higher = smoother and slower, lower = faster and noisier. Ehlers' classical default: 0.5.")
obLevel  = input.float(0.85, "Overbought Level", minval=0.5, maxval=0.99, step=0.01, group="Laguerre RSI",
     tooltip="Reference line only — plotted for context, does not drive the classification below.")
osLevel  = input.float(0.15, "Oversold Level", minval=0.01, maxval=0.5, step=0.01, group="Laguerre RSI",
     tooltip="Reference line only — plotted for context, does not drive the classification below.")

bool   showLiveTable = input.bool(true, "Show Live/Confirmed Table", group="Tables")
string livePos       = input.string("Top Middle", "Live/Confirmed Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colBull        = input.color(color.new(color.lime, 60), "Bullish (LRSI > 0.5)", group="Colours")
color colBear        = input.color(color.new(color.red,  60), "Bearish (LRSI < 0.5)", group="Colours")
bool  paintPaneChart = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// LAGUERRE FILTER & RSI
// ─────────────────────────────────────────────────────────────────────────────
// 4-stage Laguerre filter cascade:
//   L0 = (1-gamma)*price + gamma*L0[1]
//   L1 = -gamma*L0 + L0[1] + gamma*L1[1]
//   L2 = -gamma*L1 + L1[1] + gamma*L2[1]
//   L3 = -gamma*L2 + L2[1] + gamma*L3[1]
// Then CU/CD are accumulated across the three adjacent-stage pairs for the
// CURRENT bar only (not a running sum over history) — this is what replaces
// the fixed lookback window a standard RSI uses.
var float l0 = 0.0
var float l1 = 0.0
var float l2 = 0.0
var float l3 = 0.0

float l0Prev = l0
float l1Prev = l1
float l2Prev = l2
float l3Prev = l3

l0 := (1.0 - gamma) * src + gamma * nz(l0Prev, 0.0)
l1 := -gamma * l0 + nz(l0Prev, 0.0) + gamma * nz(l1Prev, 0.0)
l2 := -gamma * l1 + nz(l1Prev, 0.0) + gamma * nz(l2Prev, 0.0)
l3 := -gamma * l2 + nz(l2Prev, 0.0) + gamma * nz(l3Prev, 0.0)

float cu = 0.0
float cd = 0.0
if l0 >= l1
    cu += l0 - l1
else
    cd += l1 - l0
if l1 >= l2
    cu += l1 - l2
else
    cd += l2 - l1
if l2 >= l3
    cu += l2 - l3
else
    cd += l3 - l2

lrsi  = (cu + cd) != 0.0 ? cu / (cu + cd) : 0.0
ready = bar_index >= 4

// Live vote: LRSI crosses above the midline (0.5) => bullish, below => bearish,
// otherwise holds the previous vote (persistence). The midline, not the
// overbought/oversold levels, drives the classification — those are plotted
// as reference only.
var int liveSig = 0
if ta.crossover(lrsi, 0.5)
    liveSig := 1
if ta.crossunder(lrsi, 0.5)
    liveSig := 0

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
// State codes: 0 = Bearish, 1 = Bullish
var float dispLrsi     = na
var int   currentState = na
if barstate.isconfirmed
    dispLrsi     := lrsi
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) => s == 1 ? "Bullish" : s == 0 ? "Bearish" : "Warming up…"
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
plot(lrsi, "Laguerre RSI", color=ready ? stateColor(currentState) : color.gray, linewidth=2)
hline(0.5,     "Midline",    color=color.new(color.gray, 40), linestyle=hline.style_solid)
hline(obLevel, "Overbought", color=color.new(colBull, 0),      linestyle=hline.style_dashed)
hline(osLevel, "Oversold",   color=color.new(colBear, 0),      linestyle=hline.style_dashed)
hline(1.0, "Max", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(0.0, "Min", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

bgcolor(paintPaneChart and ready ? stateColor(currentState) : na, title="Laguerre RSI Background (pane)")
bgcolor(paintMainChart and ready ? stateColor(currentState) : na, force_overlay=true, title="Laguerre RSI Background (main chart)")


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

    table.cell(lt, 0, 0, "Laguerre RSI", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
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
// - Laguerre RSI is a BOUNDED 0-1 oscillator, not a magnitude measure. Any
//   use of it as a precision reversal forecast is a misuse.
// - The classification here is driven by the midline (0.5) crossover, not
//   the plotted Overbought/Oversold levels — those are reference lines only.
// - The damping factor (gamma) trades responsiveness for smoothness just
//   like a lookback length would in a standard RSI; there is no single
//   correct value for every asset or timeframe.
// - Because the filter replaces a fixed lookback with recursive stages, it
//   has no hard "warm-up window" the way a standard RSI does — early bars
//   converge gradually rather than becoming reliable at a fixed bar count.
// - This script does NOT repaint. All classification updates on confirmed
//   bar close only.
// ─────────────────────────────────────────────────────────────────────────────
````
