<!-- tradingview-pine-id: PUB;6018dc8bdb98415da652c58d31258cdb -->
<!-- tradingviewscripts-format: 1 -->
# Strong Engulfing

Source: https://www.tradingview.com/script/3MoEsu1L-Strong-Engulfing/

## Description

This indicator marks outside bars that both swept the previous
bar's extreme and closed away from it, near their own end.

How it works
A bar qualifies on the long side when all four conditions hold:
  1. Its low trades below the previous bar's low.
  2. It closes above the previous bar's body top.
  3. Its high trades above the previous bar's high.
  4. Its close lands in the top third of its own range,
     measured as (high - close) / (high - low).
The short side applies the mirror of each condition.

Conditions 1 and 3 together mean the previous bar sits entirely
inside the marked bar. Condition 4 is expressed as a ratio of
the bar's own range rather than in points, so the threshold
carries the same meaning across symbols and timeframes.

What separates this from a plain engulfing
A standard engulfing pattern only compares bodies, so a bar can
qualify without ever trading below the previous low. Requiring
that sweep in condition 1 excludes bars that expanded upward
without first reaching below the previous bar's extreme. The
close-position filter in condition 4 further excludes outside
bars that gave most of their range back before the close.

Evaluation timing
All conditions are checked with barstate.isconfirmed, so marks
are placed on closed bars only and never appear intrabar and
then disappear.

Settings
- Long side / Short side: enable each direction independently.
- Arrows: show or hide the triangle markers, with a color for
  each side.
- Paint the signal candle: recolors the body of the qualifying
  bar. Border and wick keep the colors from the chart's own
  candle settings, which Pine cannot override on the main
  series.

The close-position threshold is fixed at one third and is not
exposed as an input, since it forms part of the pattern
definition rather than a tuning parameter.

Alerts
Two conditions are available, one per side, each firing on the
close of a qualifying bar.

This script is for chart analysis only and is not investment
advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla
// Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JoeyWave

//@version=6

// STRONG ENGULFING
//
// A "strong" engulfing is an outside bar that swept the previous
// bar's extreme and then closed away from it, near its own end.
//
// Rules, long side (short is the mirror):
//   1. SWEEP : this bar's low takes out the previous bar's low
//   2. BODY  : it closes above the previous bar's body top
//   3. COVER : it also takes out the previous bar's high
//              (1 + 3 mean the previous bar sits inside this one)
//   4. CLOSE : the close lands in the top third of this bar's own
//              range, measured as (high - close) / (high - low).
//              Being a ratio, it carries the same meaning on any
//              symbol or timeframe. See WICK_MAX below.
//
// A weak engulfing fails rule 1: it never dips below the previous
// low, so resting orders under that low were never reached, and
// the bar is not marked.
//
// Signals are evaluated on closed bars only, so a mark never
// appears intrabar and then disappears.

indicator("Strong Engulfing", overlay = true)

// --- Display --------------------------------------------------
GRP_SIDE = "Sides"
GRP_STYLE = "Style"

useBull = input.bool(true, "Long side", inline = "side",
     group = GRP_SIDE)
useBear = input.bool(true, "Short side", inline = "side",
     group = GRP_SIDE)

showArr = input.bool(true, "Arrows", inline = "arr",
     group = GRP_STYLE)
cBull = input.color(#26A69A, "", inline = "arr",
     group = GRP_STYLE)
cBear = input.color(#EF5350, "", inline = "arr",
     group = GRP_STYLE)

paintBar = input.bool(true, "Paint the signal candle",
     inline = "sig", group = GRP_STYLE)
cSig = input.color(#FFD600, "", inline = "sig",
     group = GRP_STYLE)

// --- Rule constant --------------------------------------------
// Rule 4: most range allowed past the close, as a percentage of
// the bar's range. 33 puts the close in the top third for a long
// signal, bottom third for a short one. Kept fixed on purpose:
// the threshold is part of the pattern definition.
WICK_MAX = 33.0

// --- Detection ------------------------------------------------
rng = high - low
pBodyTop = math.max(open[1], close[1])
pBodyBot = math.min(open[1], close[1])

// Room left above / below the close, as a percentage of range.
// A zero-range bar returns 100 so that it fails rule 4.
upPast = rng > 0 ? (high - close) / rng * 100 : 100.0
dnPast = rng > 0 ? (close - low) / rng * 100 : 100.0

covers = low < low[1] and high > high[1]  // rules 1 and 3
ok = covers and barstate.isconfirmed      // closed bars only

bull = useBull and ok and close > open and close > pBodyTop and upPast <= WICK_MAX
bear = useBear and ok and close < open and close < pBodyBot and dnPast <= WICK_MAX

// --- Output ---------------------------------------------------
plotshape(showArr and bull, "Strong engulfing long",
     shape.triangleup, location.belowbar, cBull, size = size.tiny)
plotshape(showArr and bear, "Strong engulfing short",
     shape.triangledown, location.abovebar, cBear,
     size = size.tiny)

// Recolors the body of the chart's own candles. Border and wick
// keep the colors set in the chart's candle settings, which Pine
// cannot override on the main series.
paint = paintBar and (bull or bear)
barcolor(paint ? cSig : na, title = "Signal candle")

alertcondition(bull, "Strong engulfing long", "A long strong engulfing bar closed: it swept the prior low and closed in the upper third of its range.")
alertcondition(bear, "Strong engulfing short", "A short strong engulfing bar closed: it swept the prior high and closed in the lower third of its range.")
````
