<!-- tradingview-pine-id: PUB;978b1148dd5e40ab8416dd02821dd246 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Valid Highs & Lows (Structure Break)

Source: https://www.tradingview.com/script/G7pH1aM2/

## Description

# Valid Highs & Lows (Structure Break)

Most swing-detection tools mark a high the moment price turns down from it. That is a guess: at the time it is drawn, nothing has confirmed that the turn matters. This indicator uses a stricter rule — the one discretionary traders apply by eye but rarely write down.

**A swing high is only valid once price breaks the last swing low. A swing low is only valid once price breaks the last swing high.**

In other words, a turning point earns the label by producing a structure break. Until that happens, it is a candidate, not a point.

## What it draws

- **H** — a confirmed valid high, placed at the exact bar of the highest high reached since the previous valid low.
- **L** — a confirmed valid low, placed at the lowest low reached since the previous valid high.
- **Red / green lines** — the current valid high and valid low, extended to the right. These are the levels the structure is built on.
- **h? / l? (gray, dashed)** — the pending candidate: the extreme reached so far that has not yet been confirmed by a break. It updates live and disappears the moment it is either confirmed or replaced.

Points strictly alternate: high, low, high, low.

## How it works

The indicator tracks local pivots to define the break reference, and separately tracks the running extreme since the last confirmed point.

When price breaks the reference in the opposite direction, the running extreme becomes the new valid point. The break reference moves with price, so in a trend it is the most recent higher low (or lower high) that has to give way — not an old level from months back.

## Inputs

**Bars on each side** — how significant a local swing must be to serve as the break reference. Lower values produce more points, marked sooner, including minor structure. Higher values produce fewer, larger points, confirmed later. This is the only parameter that changes the character of the output; start at 5 and adjust to the scale you actually trade.

**Confirm break on close** — when enabled, the break only counts if a candle closes beyond the reference. Disabled, a wick is enough. Close-based is more conservative and produces fewer false structure breaks.

**Show pending candidate** — toggles the gray h? / l? marker.

## What to expect

**Confirmation is late by design.** By the time a high is validated, price has already broken the previous low, so it is well below that high. This is inherent to the definition, not a flaw. If you need a signal at the extreme itself, this is the wrong tool.

**The most recent swing is almost always pending.** The right edge of the chart will typically show a gray candidate rather than a confirmed point. That is the honest state of the market — the turn has not yet proven itself.

**Confirmed points do not repaint.** Once an H or L is printed it stays where it is. The gray candidate does move, which is the whole point of showing it in a different colour.

## Using it

The valid high and valid low define the active structure. A sequence of rising valid lows and rising valid highs is an uptrend; falling ones are a downtrend. A break of the current valid low in an uptrend is the first objective evidence that the trend has changed.

The indicator also publishes a hidden plot, **Structure bias**, returning 1 when the last confirmed point was a low (structure up) and -1 when it was a high (structure down). You can feed it into another script with `input.source` to use the structure state as a filter.

Alerts are available for both confirmations.

## Notes

This is an indicator, not a strategy. It marks structure — it does not generate entries, place stops, or size positions.

---

## Source Code

````pine
//@version=6
// A swing high becomes VALID only when price breaks the last swing low.
// A swing low becomes VALID only when price breaks the last swing high.
// The valid point is the extreme (highest high / lowest low) reached since the previous valid point.
// Until confirmation, the candidate is shown in gray with a "?".
indicator("Valid Highs & Lows (Structure Break)", "Valid H/L", overlay=true, max_labels_count=500, max_lines_count=20)

pivN       = input.int(5, "Bars on each side", minval=1, tooltip="Controls how significant a local swing must be to act as the break reference. Higher = fewer and larger structure points, slower confirmation.")
useClose   = input.bool(true, "Confirm break on close", tooltip="On: the break only counts when a candle closes beyond the reference. Off: a wick is enough.")
onBarClose = input.bool(false, "Validate only on closed bars", tooltip="On: points are confirmed only when the bar closes, so nothing appears or disappears while the candle is still forming.")
showPts    = input.bool(true, "Mark H / L")
showLvl    = input.bool(true, "Show current levels")
showPend   = input.bool(true, "Show pending candidate")
showBreak  = input.bool(true, "Show break levels", tooltip="Plots the pivot that price must break in order to validate the pending point.")
activeOnly = input.bool(true, "Only the level in play", tooltip="On: shows just the reference that matters now — the last pivot low while a high is pending, the last pivot high while a low is pending.")

ph = ta.pivothigh(high, pivN, pivN)
pl = ta.pivotlow(low,  pivN, pivN)

var float lastPH = na
var float lastPL = na

if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// running extremes since the last confirmed point
var float runHigh    = na
var int   runHighBar = na
var float runLow     = na
var int   runLowBar  = na

if na(runHigh) or high > runHigh
    runHigh    := high
    runHighBar := bar_index
if na(runLow) or low < runLow
    runLow    := low
    runLowBar := bar_index

var float VH   = na   // last valid high
var float VL   = na   // last valid low
var int   mode = 1    // 1 = waiting to validate a HIGH | 2 = waiting to validate a LOW

var line lnHigh = na
var line lnLow  = na

// both conditions are evaluated against the mode as it stood at the start of the bar,
// so a single candle can never validate a high and a low at the same time
ready     = not onBarClose or barstate.isconfirmed
breakDown = ready and mode == 1 and not na(lastPL) and not na(runHigh) and (useClose ? close < lastPL : low  < lastPL)
breakUp   = ready and mode == 2 and not na(lastPH) and not na(runLow)  and (useClose ? close > lastPH : high > lastPH)

// price broke the last low -> the high is validated
if breakDown
    VH   := runHigh
    mode := 2
    if showPts
        label.new(runHighBar, runHigh, "H", style=label.style_label_down, color=color.new(color.red, 30), textcolor=color.white, size=size.tiny)
    if showLvl
        if not na(lnHigh)
            line.delete(lnHigh)
        lnHigh := line.new(runHighBar, runHigh, bar_index, runHigh, extend=extend.right, color=color.new(color.red, 40), width=1)
    runLow    := low
    runLowBar := bar_index

// price broke the last high -> the low is validated
else if breakUp
    VL   := runLow
    mode := 1
    if showPts
        label.new(runLowBar, runLow, "L", style=label.style_label_up, color=color.new(color.green, 30), textcolor=color.white, size=size.tiny)
    if showLvl
        if not na(lnLow)
            line.delete(lnLow)
        lnLow := line.new(runLowBar, runLow, bar_index, runLow, extend=extend.right, color=color.new(color.green, 40), width=1)
    runHigh    := high
    runHighBar := bar_index

// reference levels price has to break — what the pending point is waiting for
plot(showBreak and (not activeOnly or mode == 2) ? lastPH : na, "Break level (last pivot high)", color=color.new(color.red, 20),   style=plot.style_circles, linewidth=1)
plot(showBreak and (not activeOnly or mode == 1) ? lastPL : na, "Break level (last pivot low)",  color=color.new(color.green, 20), style=plot.style_circles, linewidth=1)

// pending candidate — one object at a time, last bar only
var label lbPend = na
var line  lnPend = na

if barstate.islast and showPend
    if not na(lbPend)
        label.delete(lbPend)
    if not na(lnPend)
        line.delete(lnPend)
    if mode == 1 and not na(runHighBar)
        lbPend := label.new(runHighBar, runHigh, "h?", style=label.style_label_down, color=color.new(color.gray, 40), textcolor=color.white, size=size.tiny)
        lnPend := line.new(runHighBar, runHigh, bar_index, runHigh, color=color.new(color.gray, 50), style=line.style_dashed, width=1)
    if mode == 2 and not na(runLowBar)
        lbPend := label.new(runLowBar, runLow, "l?", style=label.style_label_up, color=color.new(color.gray, 40), textcolor=color.white, size=size.tiny)
        lnPend := line.new(runLowBar, runLow, bar_index, runLow, color=color.new(color.gray, 50), style=line.style_dashed, width=1)

// values for other scripts and for the data window
plot(VH, "Valid high", display=display.data_window)
plot(VL, "Valid low",  display=display.data_window)

// 1 = last confirmed point was a LOW (structure is up) | -1 = last confirmed point was a HIGH (structure is down)
plot(mode == 1 ? 1 : mode == 2 ? -1 : 0, "Structure bias", display=display.none)

alertcondition(mode == 2 and mode[1] == 1, "Valid high confirmed", "A swing high has been validated by a structure break")
alertcondition(mode == 1 and mode[1] == 2, "Valid low confirmed",  "A swing low has been validated by a structure break")
````
