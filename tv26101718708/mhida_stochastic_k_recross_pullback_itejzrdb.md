# MHIDa Stochastic %K Re-Cross Pullback

- url: https://www.tradingview.com/script/itejZrDb/
- type: indicator
- pine_id: PUB;0c9a6fcf54244afabc4781da7305d9c1
- version: 1.0

## Description

MHIDa Stochastic %K Re-Cross Pullback marks the moment the Stochastic %K turns back up out of the oversold zone, but ONLY while price is inside an uptrend. It is a context tool to help you look at a classic pullback inside a rising trend. It is not a trading signal and not financial advice.

WHAT IT DOES
The oscillator pane shows %K (blue) and %D (orange) with an oversold level, an overbought reference and a middle line. When %K was oversold and starts to rise again while the trend filter is bullish, a green circle labelled re-cross appears. If the same turn happens without an uptrend, only a small grey triangle is drawn: it is neutral context, not a pullback inside a rising market.

HOW IT IS CALCULATED
1) Raw %K = position of the close inside the high-low range of the last K bars (ta.stoch). %K is that value smoothed with a simple moving average; %D is a simple moving average of %K. Defaults: K 14, smoothing 3, D 3, oversold 20.
2) Re-cross, two selectable modes. Mode 1 (K crosses level): %K was below the oversold level on the previous bar and now crosses back above it. Mode 2 (K crosses %D in low zone): %K crosses above %D while it is still below oversold + 5.
3) Uptrend filter: close above a long EMA (default 50) and, optionally, the EMA higher than on the previous bar. A re-cross is highlighted only if this filter is true. The filter can be switched off in the settings.

WHY THE PIECES ARE COMBINED
An oversold reading alone is common in falling markets and often means nothing. The trend filter removes oversold turns that happen against the larger direction, so the highlighted moments are the ones where the oscillator unwinds while the structure stays bullish.

HOW TO USE IT
Add it to any symbol and timeframe. Each green circle is a place to go and evaluate with your own analysis (structure, volume, levels, risk). Defaults are starting points, not optimal values: change the lengths, the oversold level, the EMA and the re-cross mode and watch how the marked moments change. The markers are drawn only on standard chart types (not on Heikin Ashi, Renko, Kagi, Point and Figure or Range charts). The indicator does not repaint past markers once a bar is closed; the last bar updates in real time as usual.

DISCLAIMER
Educational context tool. Oscillators alone are not enough and nothing here is a promise of results. Every decision is yours.

## Source Code

````pine
//@version=6
// =============================================================================
// MHIDa Stochastic %K Re-Cross Pullback
// A context tool, not a signal and not financial advice. Not a standalone
// winner: you always make the decision.
// =============================================================================
//
// WHAT IT DOES
//   Highlights the moment the Stochastic %K turns back up out of the oversold
//   zone (a "re-cross") ONLY while price is inside an uptrend (above a long EMA
//   that is sloping up). It is the classic pullback-inside-an-uptrend read:
//   the oscillator unwinds, then starts to lift again while the larger
//   structure stays bullish.
//
// HOW IT IS CALCULATED
//   - Raw %K = position of the close inside the last "K length" high-low range
//     (ta.stoch), smoothed with a simple moving average = %K line.
//     %D = simple moving average of %K.
//   - Re-cross, two selectable definitions:
//       1) "K crosses level": %K was below the oversold level on the previous
//          bar and now crosses back above it.
//       2) "K crosses %D in low zone": %K crosses above %D while it was still
//          close to the oversold zone (below oversold + 5).
//   - Bull context: close above the trend EMA (default 50) and, optionally,
//     the EMA higher than on the previous bar. Without the bull context the
//     same turn is only drawn as a small grey triangle (neutral context, not
//     a pullback inside an uptrend).
//
// HOW TO USE IT
//   Look at the green circles on the oscillator pane: each one is a moment to
//   go and evaluate with your own eyes (structure, volume, levels, risk).
//   Defaults (K=14, smooth=3, D=3, oversold=20, EMA=50) are starting points,
//   not "right" values. Change them and watch how the marked moments change.
// =============================================================================

indicator("MHIDa Stochastic %K Re-Cross Pullback", shorttitle="Stoch-ReX", overlay=false, format=format.price, precision=2)

// ---------------------------- INPUTS (defaults = starting points) ------------
grpStoch    = "Stochastic (classic defaults, editable)"
lenK        = input.int(14, "%K length", minval=1, group=grpStoch)
smoothK     = input.int(3, "%K smoothing", minval=1, group=grpStoch)
lenD        = input.int(3, "%D length", minval=1, group=grpStoch)
osLevel     = input.float(20, "Oversold level", minval=1, maxval=49, group=grpStoch)

grpTrend    = "Bull filter (uptrend context)"
useTrend    = input.bool(true, "Require uptrend context", group=grpTrend)
emaLen      = input.int(50, "Trend EMA length", minval=1, group=grpTrend)
needSlope   = input.bool(true, "Require EMA sloping up", group=grpTrend)

grpMode     = "Re-cross definition"
recrossMode = input.string("K crosses level", "Re-cross mode", options=["K crosses level", "K crosses %D in low zone"], group=grpMode)

grpView     = "Display"
showMarks   = input.bool(true, "Show re-cross markers", group=grpView)

// ---------------------------- STOCHASTIC -------------------------------------
rawK = ta.stoch(close, high, low, lenK)
k    = ta.sma(rawK, smoothK)
d    = ta.sma(k, lenD)

// ---------------------------- BULL FILTER ------------------------------------
emaT    = ta.ema(close, emaLen)
trendUp = close > emaT
slopeUp = emaT > emaT[1]
bullCtx = (not useTrend) or (trendUp and (not needSlope or slopeUp))

// ---------------------------- RE-CROSS EVENT ---------------------------------
crossUpLevel = (k[1] < osLevel) and ta.crossover(k, osLevel)
crossUpKD    = (k[1] < osLevel + 5) and ta.crossover(k, d)

recrossRaw = recrossMode == "K crosses level" ? crossUpLevel : crossUpKD

recross      = recrossRaw and bullCtx
oversoldPure = recrossRaw and not bullCtx

// ---------------------------- PLOTS ------------------------------------------
colK = color.new(#2962FF, 0)
colD = color.new(#FF6D00, 0)
plot(k, "%K", color=colK, linewidth=2)
plot(d, "%D", color=colD, linewidth=1)

hline(osLevel, "Oversold", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(100 - osLevel, "Overbought (reference)", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(50, "Middle line", color=color.new(color.gray, 75), linestyle=hline.style_dotted)

bgcolor(k < osLevel ? color.new(color.gray, 92) : na, title="Oversold zone")

// Filled circle = re-cross inside the uptrend (to LOOK at).
// Small grey triangle = oversold turn without uptrend (context only).
// Markers are drawn only on standard chart types (not Heikin Ashi, Renko, Kagi, P&F, Range).
plotshape(showMarks and recross and chart.is_standard, title="Re-cross in uptrend", style=shape.circle, location=location.bottom, color=color.new(#00C853, 0), size=size.small, text="re-cross")
plotshape(showMarks and oversoldPure and chart.is_standard, title="Oversold turn (no uptrend)", style=shape.triangleup, location=location.bottom, color=color.new(color.gray, 30), size=size.tiny)

// ---------------------------- ON-CHART NOTE ----------------------------------
var table note = table.new(position.top_right, 1, 1, border_width=0)
if barstate.islast
    txt = "Context tool, not a signal.\nLook at the re-crosses inside the uptrend and decide yourself."
    table.cell(note, 0, 0, txt, text_size=size.small, text_color=color.new(color.gray, 0), bgcolor=color.new(color.gray, 90))
````
