<!-- tradingview-pine-id: PUB;6ca5bdbae11f4866b29b136f0ef01054 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fisher Transform Turning Points [RC Tools]

Source: https://www.tradingview.com/script/Q3LUoyAA-Fisher-Transform-Turning-Points-RC-Tools/

## Description

RC Tools — Fisher Transform Turning Points
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Most oscillators produce a roughly bell-curve distribution of values, which means they spend a lot of time hovering near their own extremes without committing one way or the other — turning points end up gradual and easy to miss. The Fisher Transform, developed by John Ehlers, fixes this by re-shaping the distribution itself: it converts a naturally Gaussian-ish read into one with much sharper, more decisive swings, so genuine turning points stand out rather than blur together.

█ WHAT IT DOES

Computes the Fisher Transform of price's position within its recent high/low range and classifies each confirmed bar as Bullish or Bearish on a zero-line crossover. Plots a 4-colour momentum histogram (Expansion, Slowdown, Contraction, Recovery) showing not just direction but whether momentum is accelerating or fading, colours the chart background by the confirmed state, and shows a table with the current state, how long price has been in it, and historical base rates (average forward return and win rate) for each state.

█ THE THEORY BEHIND IT

Most price-derived oscillators (RSI, Stochastic, and similar) are bounded and tend to spend a disproportionate amount of time in the middle of their range, with actual extremes reached only briefly. Ehlers' insight was that if you first normalise price's position within its recent range to roughly -1 to +1, then run that through the inverse hyperbolic tangent function, you get an output whose distribution is much closer to genuinely Gaussian — which sounds abstract, but has a very practical effect: the statistic moves through its extremes quickly rather than lingering, producing sharper, more decisive turning points instead of a gradual roll-over.

█ HOW IT IS CALCULATED

1. Normalise price's position within its recent high/low range (over the Length window) to roughly -1 to +1, damped against the prior bar's reading to reduce noise.
2. Run that normalised value through 0.5 × ln((1 + x) / (1 - x)) — the inverse hyperbolic tangent, via a standard logarithmic identity — again damped against the prior output.
3. The resulting Fish value crossing above zero is classified Bullish; crossing below zero is classified Bearish. Between crossovers, the classification holds.
4. Separately, a 4-colour momentum state (Expansion/Slowdown/Contraction/Recovery) is derived from Fish's bar-to-bar change — this is a cosmetic diagnostic layer and does not affect the Bullish/Bearish classification itself.

Note: a trigger-line crossover (Fish against its own lagged value) was tested during development and found too whipsaw-prone for this technique — the zero-line crossover used here produced meaningfully cleaner classification.

Classification occurs ONLY on confirmed bar close — the plotted Fish value, the background colour and the table all update together, so nothing here can disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Length (default 10, the classical value from Ehlers' original publication) — the rolling high/low window used for the price-position read
• Table visibility, position and colours are fully configurable; the main-chart background painting can be toggled off if you only want the statistics pane
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table

█ HOW TO USE IT

Use it as a turning-point filter alongside your existing tools, not as a standalone entry signal. Because the transform is specifically built to sharpen turning points, it tends to react faster than smoother oscillators — useful for catching a genuine reversal early, at the cost of more false starts in choppy conditions. Check the base-rate table's sample count before treating any single state as meaningfully predictive.

Works on any asset and timeframe with sufficient history for the Length window.

█ LIMITATIONS

• Fisher Transform is a NORMALISED price-position statistic, not a measure of trend strength or magnitude. Any use of it as a precision reversal forecast is a misuse.
• The sharp, decisive turning points that make this technique distinctive also mean it can whipsaw in genuinely choppy, range-bound conditions.
• The high/low window resets its frame of reference every Length bars; a short length reacts fast but is noisier, a long length is smoother but slower to reflect a genuine change.
• The 4-colour momentum state is a cosmetic diagnostic layered on top of Fish's bar-to-bar change — it does not affect the Bullish/Bearish classification or the base-rate table.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any turning-point state does not indicate future results. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Fisher Transform Turning Points [RC Tools]", shorttitle="RCT Fisher", overlay=false)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Fisher Transform — John Ehlers, 2002 ("Using The Fisher Transform," Stocks &
// Commodities magazine). A public, well-documented technique — genuinely rare
// on TradingView relative to RSI/MACD/Stochastic despite being a textbook
// method. Independent implementation, built from the public formula.
//
// Most oscillators produce a roughly Gaussian (bell-curve) distribution of
// values, which means turning points are gradual and easy to miss. Fisher
// Transform normalises price's position within its recent high/low range,
// then runs that through the inverse hyperbolic tangent to convert the
// distribution into one with much sharper, more decisive turning points —
// the statistic spends less time near its extremes and moves through them
// quickly, which is the whole point of the transform.
//
// Classification updates ONLY on confirmed bar close, so nothing here repaints.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
length = input.int(10, "Length", minval=5, maxval=100, step=1, group="Fisher Transform",
     tooltip="Rolling high/low window for the price-position read. Classical default: 10.")

bool   showLiveTable = input.bool(true, "Show Live/Confirmed Table", group="Tables")
string livePos       = input.string("Top Middle", "Live/Confirmed Table Position", options=["Top Right","Top Middle","Top Left","Bottom Right","Bottom Middle","Bottom Left"], group="Tables")

color colBull        = input.color(color.new(color.lime, 60), "Bullish (Fish > 0)", group="Colours")
color colBear        = input.color(color.new(color.red,  60), "Bearish (Fish < 0)", group="Colours")
bool  paintPaneChart = input.bool(true, "Paint Pane Background", group="Colours",
     tooltip="Colours the background of this indicator's own pane (the one it opens on below the chart).")
bool  paintMainChart = input.bool(false, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background also shows on the main price chart, even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// FISHER TRANSFORM
// ─────────────────────────────────────────────────────────────────────────────
// 1. Normalise price's position within its recent high/low range to roughly
//    -1..+1, damped against the prior reading.
// 2. Run that through 0.5 * ln((1+x)/(1-x)) — the inverse hyperbolic tangent
//    via a log identity — damped against the prior output.
hh     = ta.highest(high, length)
ll     = ta.lowest(low, length)
rng    = hh - ll
rawPos = rng != 0.0 ? (close - ll) / rng - 0.5 : 0.0

var float value1 = 0.0
value1 := 0.33 * 2.0 * rawPos + 0.67 * nz(value1[1], 0.0)
value1 := math.max(-0.999, math.min(0.999, value1))

var float fish = 0.0
fish := 0.5 * math.log((1.0 + value1) / (1.0 - value1)) + 0.5 * nz(fish[1], 0.0)

ready = bar_index >= length

// Live vote: zero-line crossover of Fish itself, otherwise holds the previous
// vote (persistence) — a trigger-line crossover was tested and found too
// whipsaw-prone for this technique.
var int liveSig = 0
if ta.crossover(fish, 0.0)
    liveSig := 1
if ta.crossunder(fish, 0.0)
    liveSig := 0

// ── Confirmed (non-repainting) snapshot — latched once per bar at close ──────
// State codes: 0 = Bearish, 1 = Bullish
var float dispFish     = na
var int   currentState = na
if barstate.isconfirmed
    dispFish     := fish
    currentState := liveSig


// ─────────────────────────────────────────────────────────────────────────────
// 4-STATE MOMENTUM PALETTE (expansion / slowdown / contraction / recovery)
// Purely cosmetic/diagnostic — the Vote above (zero-line crossover) is
// unaffected and is the only thing driving the classification and tables.
// Derived from the same Bullish/Bearish colour inputs so the whole script
// stays consistently themed from two colour pickers.
// ─────────────────────────────────────────────────────────────────────────────
cExpand   = color.new(colBull, 0)
cSlowdown = color.new(colBull, 55)
cContract = color.new(colBear, 0)
cRecovery = color.new(colBear, 55)

histColor(f, fPrev) => f >= 0 ? (f > fPrev ? cExpand : cSlowdown) : (f < fPrev ? cContract : cRecovery)
histLabel(f, fPrev)  => f >= 0 ? (f > fPrev ? "Expansion" : "Slowdown") : (f < fPrev ? "Contraction" : "Recovery")

liveHistColor = histColor(fish, fish[1])
liveHistLabel = histLabel(fish, fish[1])


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
plot(fish, "Fish", color=liveHistColor, style=plot.style_columns, linewidth=2)
hline(0.0, "Zero", color=color.new(color.gray, 60))

bgcolor(paintPaneChart and ready ? (currentState == 1 ? colBull : colBear) : na, title="Turning Point Background (pane)")
bgcolor(paintMainChart and ready ? (currentState == 1 ? colBull : colBear) : na, force_overlay=true, title="Turning Point Background (main chart)")


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
    var table lt = table.new(getPosition(livePos), 2, 6,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(lt, 0, 0, "Fisher Transform Turning Points", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(lt, 1, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(lt, 0, 1, "Live (intrabar)", text_color=color.gray, text_size=size.small)
    table.cell(lt, 1, 1, liveLabel, text_color=color.white, bgcolor=color.new(liveColor, 45), text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 2, "Confirmed", text_color=color.white, text_size=size.small)
    table.cell(lt, 1, 2, confLabel, text_color=color.white, bgcolor=color.new(confColor, 25), text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 3, "Momentum State", text_color=color.gray, text_size=size.small)
    table.cell(lt, 1, 3, liveHistLabel, text_color=color.white, bgcolor=color.new(liveHistColor, 25), text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 4, "Streak", text_color=color.gray, text_size=size.small)
    table.cell(lt, 1, 4, ready ? str.tostring(streak) + " bars" : "—", text_color=color.gray, text_halign=text.align_center, text_size=size.small)

    table.cell(lt, 0, 5, "⚠ Live can change until close — trade off Confirmed only", text_color=color.white, bgcolor=color.new(color.orange, 65), text_halign=text.align_left, text_size=size.small)
    table.merge_cells(lt, 0, 5, 1, 5)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - Fisher Transform is a NORMALISED price-position statistic, not a measure
//   of trend strength or magnitude. Any use of it as a precision reversal
//   forecast is a misuse.
// - The sharp, decisive turning points that make this technique distinctive
//   also mean it can whipsaw in genuinely choppy, range-bound conditions —
//   a trigger-line crossover was tested for this script and found too
//   noise-prone, which is why the vote uses a zero-line crossover instead.
// - The high/low window resets its frame of reference every `length` bars;
//   a short length reacts fast but is noisier, a long length is smoother but
//   slower to reflect a genuine change.
// - The 4-colour momentum state (Expansion/Slowdown/Contraction/Recovery) is
//   a cosmetic diagnostic layered on top of Fish's bar-to-bar change — it
//   does not affect the Vote or the table's classification.
// - This script does NOT repaint. All classification updates on confirmed
//   bar close only.
// ─────────────────────────────────────────────────────────────────────────────
````
