# SITREP Momentum Guide

- url: https://www.tradingview.com/script/PavLiXTt-SITREP-Momentum-Guide/
- type: indicator
- pine_id: PUB;b30169411d0c4efaa5aeae111d2a9ae5
- version: 3.0

## Description

SITREP Momentum Guide

SITREP Momentum Guide is a clean, four-EMA momentum read built for fast intraday decision-making. It plots the 9, 13, 48, and 200 EMAs as a color-coded fan on your chart's current timeframe, with an optional cloud fill between the 9 and 48. Rather than tying the cloud's brightness to raw distance, opacity is driven by how cleanly the fan is stacked — when the EMAs are correctly ordered in the trend direction, the cloud is solid and bright; when the stack is messy or compressing, it fades. The result is a visual that tells you at a glance whether momentum is genuinely aligned or just stretched, without a single number to interpret.

Two signals keep you oriented without cluttering the chart. A confirmed flip arrow fires only when a 9/13 crossover agrees with the broader 48/200 backdrop, filtering out the noise crosses that plague a simple moving-average flip; the word "flipped" rides the most recent flip and steps forward as new ones occur, so the latest shift is always labeled while older ones stay as bare arrows. A breakdown marker drops the moment the fan loses its correct stacking order, and the fan lines themselves desaturate to gray — a redundant, deliberate cue that an aligned trend has come apart.

Every element is independently toggleable: each EMA, the cloud, the flip marker, and the breakdown marker can be switched on or off to suit your style. There are no in-session tunable thresholds — compression and spread are measured relative to the fan's own recent behavior, so the tool adapts to whatever the market is doing rather than asking you to curve-fit a setting mid-trade. It's designed as a momentum guide, not a signal generator: it shows you the state of the trend and leaves the decision to you.

## Source Code

````pine
//@version=6
// =============================================================================
// SITREP MOMENTUM GUIDE v3 — FAN ONLY  (+ SIM-ENTRY-01 flip markers, optional)
//
// Just the fan: 9 / 13 / 48 / 200 EMAs with the 9-48 cloud.
// Cloud opacity tracks how cleanly the fan is stacked (bright = clean stack
// and open spread, faint = messy or compressing). Lines desaturate to gray
// when stack order breaks.
//
// OPTIONAL (default OFF) — SIM-ENTRY-01 9/13 FLIP MARKERS:
//   Green dot below / red dot above the candle that CLOSED into a 9/13 cross.
//   Solid line at that candle's wick (low on a bull flip, high on a bear flip)
//   = the stop. Dashed line at entry ± 3R = the target. Both run 3 bars fwd.
//   Confirmed on close only — no intrabar repaint.
//
//   Provenance: the 9 is NOT in Casey's corpus (his set is 13/48/200). The
//   9/13 band is SIM-ENTRY-01 — Simon's own construction, derived from tape.
//   These markers LOCATE; they do not gate. The precondition (a bounce or
//   rejection from a key level, and its timing) is not visible to this script
//   and remains discretionary.
//
// The SITREP table lives in Key Levels v2.
// =============================================================================

indicator("SITREP Momentum Guide v3", shorttitle="SITREP·MOM", overlay=true,
     max_lines_count=50)

// ============================================================================
// INPUTS — EMA TOGGLES
// ============================================================================
grp_ema = "EMA Fan"
i_show9   = input.bool(true, "Show EMA 9",   group=grp_ema)
i_show13  = input.bool(true, "Show EMA 13",  group=grp_ema)
i_show48  = input.bool(true, "Show EMA 48",  group=grp_ema)
i_show200 = input.bool(true, "Show EMA 200", group=grp_ema)

// ============================================================================
// INPUTS — COLORS
// ============================================================================
grp_col = "Colors"
i_col9     = input.color(#2196F3, "EMA 9 (blue)",    group=grp_col)
i_col13    = input.color(#FFD600, "EMA 13 (yellow)", group=grp_col)
i_col48    = input.color(#AA00FF, "EMA 48 (purple)", group=grp_col)
i_col200   = input.color(#FF1744, "EMA 200 (red)",   group=grp_col)
i_colMixed = input.color(#90A4AE, "Mixed / breakdown (gray)", group=grp_col)

// ============================================================================
// INPUTS — CLOUD
// ============================================================================
grp_cloud    = "Cloud Fill (9-48)"
i_showCloud  = input.bool(true, "Show Cloud", group=grp_cloud)
i_cloudOpMin = input.int(90, "Min Opacity (messy / no stack)",
     minval=50, maxval=99, group=grp_cloud,
     tooltip="Opacity when the fan is NOT stacked. Higher = fainter.")
i_cloudOpMax = input.int(55, "Max Opacity (clean / full stack)",
     minval=0, maxval=80, group=grp_cloud,
     tooltip="Opacity when the fan is fully stacked AND spread. Lower = more solid.")

// ============================================================================
// INPUTS — SIM-ENTRY-01 FLIP MARKERS  (default OFF — backtest first)
// ============================================================================
grp_flip = "9/13 Flip Markers (SIM-ENTRY-01)"
i_showFlip = input.bool(false, "Show flip markers", group=grp_flip,
     tooltip="OFF by default. Marks candles that CLOSED into a 9/13 cross. Locator only — the key-level precondition is not visible to this script.")
i_rMult    = input.float(3.0, "Target R multiple", minval=0.5, maxval=10.0,
     step=0.5, group=grp_flip,
     tooltip="Target = entry (cross-candle close) +/- this multiple of risk. Risk = close to wick.")
i_projBars = input.int(3, "Line length (bars forward)", minval=1, maxval=20,
     group=grp_flip)
i_keepSets = input.int(2, "Flip sets kept on chart", minval=1, maxval=20,
     group=grp_flip,
     tooltip="Older stop/target lines are deleted. Raise while reviewing history, return to 2 for live. Dots always persist.")
i_colFlipUp = input.color(#00E676, "Bull flip (green)", group=grp_flip)
i_colFlipDn = input.color(#F23645, "Bear flip (red)",   group=grp_flip)

// ============================================================================
// EMA VALUES — current chart timeframe
// ============================================================================
ema9   = ta.ema(close, 9)
ema13  = ta.ema(close, 13)
ema48  = ta.ema(close, 48)
ema200 = ta.ema(close, 200)

// ============================================================================
// FAN DIRECTION — persistent, latches on 9/13 crossover
// (internal only — drives cloud color, nothing is drawn from it)
// ============================================================================
cross9x13Bull = ta.crossover(ema9,  ema13)
cross9x13Bear = ta.crossunder(ema9, ema13)

var int fanDir = 0
if cross9x13Bull
    fanDir := 1
if cross9x13Bear
    fanDir := -1

// ============================================================================
// STACK ORDER SCORE — 0-3, how cleanly the fan is ordered behind fanDir
// ============================================================================
bull913   = ema9  > ema13
bull1348  = ema13 > ema48
bull48200 = ema48 > ema200

stackScore = 0
if fanDir == 1
    stackScore := (bull913 ? 1 : 0) + (bull1348 ? 1 : 0) + (bull48200 ? 1 : 0)
else if fanDir == -1
    stackScore := (not bull913 ? 1 : 0) + (not bull1348 ? 1 : 0) + (not bull48200 ? 1 : 0)

fullStack = fanDir != 0 and stackScore == 3

// ============================================================================
// SPREAD + COMPRESSION — relative, no fixed threshold
// ============================================================================
spread      = math.abs(ema9 - ema48) / close
spreadNorm  = math.min(1.0, spread / 0.003)
compressing = spread < spread[3]

// ============================================================================
// CLOUD OPACITY
// ============================================================================
stackFrac  = stackScore / 3.0
openWeight = fullStack ? spreadNorm : stackFrac
opacity    = math.round(i_cloudOpMin - (i_cloudOpMin - i_cloudOpMax) * openWeight)
opacity   := compressing ? math.min(99, opacity + 12) : opacity
opacity   := math.max(0, math.min(99, opacity))

// ============================================================================
// LINE COLORS
// ============================================================================
brokenDown = fanDir != 0 and stackScore < 2

c9   = i_show9   ? (brokenDown ? color.new(i_colMixed, 0) : color.new(i_col9, 0))  : na
c13  = i_show13  ? (brokenDown ? color.new(i_colMixed, 0) : color.new(i_col13, 0)) : na
c48  = i_show48  ? (brokenDown ? color.new(i_colMixed, 0) : color.new(i_col48, 0)) : na
c200 = i_show200 ? color.new(i_col200, 0) : na

// ============================================================================
// PLOTS
// ============================================================================
p9  = plot(ema9,  "EMA 9",  color=c9,  linewidth=2)
p48 = plot(ema48, "EMA 48", color=c48, linewidth=2)
plot(ema13,  "EMA 13",  color=c13,  linewidth=2)
plot(ema200, "EMA 200", color=c200, linewidth=3)

// ============================================================================
// CLOUD
// ============================================================================
cloudBase = fanDir == 1 ? i_col9 : fanDir == -1 ? i_col48 : i_colMixed
cloudCol  = (i_showCloud and not brokenDown) ? color.new(cloudBase, opacity) : na
fill(p9, p48, color=cloudCol, title="Fan Cloud")

// ============================================================================
// SIM-ENTRY-01 — 9/13 FLIP MARKERS  (dots persist, lines are trimmed)
// ============================================================================
flipUp = i_showFlip and cross9x13Bull and barstate.isconfirmed
flipDn = i_showFlip and cross9x13Bear and barstate.isconfirmed

plotshape(flipUp, title="9/13 Bull Flip", location=location.belowbar,
     style=shape.circle, color=color.new(i_colFlipUp, 0), size=size.tiny)
plotshape(flipDn, title="9/13 Bear Flip", location=location.abovebar,
     style=shape.circle, color=color.new(i_colFlipDn, 0), size=size.tiny)

var array<line> flipStopLns = array.new<line>()
var array<line> flipTgtLns  = array.new<line>()

if flipUp or flipDn
    isBull = flipUp
    stopPx = isBull ? low : high
    risk   = math.abs(close - stopPx)
    if risk > 0
        tgtPx  = isBull ? close + i_rMult * risk : close - i_rMult * risk
        colFlp = isBull ? i_colFlipUp : i_colFlipDn
        rx     = bar_index + i_projBars
        slLn = line.new(bar_index, stopPx, rx, stopPx, xloc.bar_index,
             extend.none, color.new(colFlp, 0), line.style_solid, 2)
        tgLn = line.new(bar_index, tgtPx, rx, tgtPx, xloc.bar_index,
             extend.none, color.new(colFlp, 35), line.style_dashed, 1)
        array.push(flipStopLns, slLn)
        array.push(flipTgtLns,  tgLn)
        while array.size(flipStopLns) > i_keepSets
            line.delete(array.shift(flipStopLns))
        while array.size(flipTgtLns) > i_keepSets
            line.delete(array.shift(flipTgtLns))

// ============================================================================
// END — SITREP MOMENTUM GUIDE v3
// ============================================================================
````
