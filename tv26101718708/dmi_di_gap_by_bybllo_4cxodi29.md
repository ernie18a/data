# DMI DI Gap by Bybllo

- url: https://www.tradingview.com/script/4CxoDI29/
- type: indicator
- pine_id: PUB;464a5c0bf0174109ba3288cbc988c7ed
- version: 2.0

## Description

DMI DI Gap by Bybllo
This indicator plots the gap (difference) between the DI+ and DI- lines of the Directional Movement Index (DMI). Instead of visually comparing two separate DI+ / DI- lines to spot a crossover, the difference (DI+ minus DI-) is calculated directly and plotted as a single line around a zero baseline.
A cross above the zero line signals a shift toward bullish momentum, while a cross below the zero line signals a shift toward bearish momentum — each crossing is automatically marked with a buy or sell arrow, so there is no need to eyeball where the two DI lines intersect.
Key Features

A single "DI Gap" line (DI+ minus DI-) replaces the need to watch two overlapping DI+ / DI- lines and spot their crossovers by eye.
Zero-line crossover / crossunder is detected automatically and marked with buy (upward) and sell (downward) triangle arrows, offset a configurable distance from the zero line.
An optional ADX line, rescaled from its native 0–100 range to a custom min/max range, can be overlaid to gauge trend strength alongside the directional gap.
A filled cloud area between the gap line and the zero line is colored according to whether the current gap is positive or negative.
+25 / -25 dotted reference lines help gauge how strong the current directional imbalance is.
Real-price calculation via request.security() ensures values stay consistent regardless of chart type (Heikin Ashi, Renko, etc.).

How to Use

When the DI Gap line crosses above zero, a buy arrow appears below the zero line, indicating directional momentum has turned bullish (DI+ has overtaken DI-).
When the DI Gap line crosses below zero, a sell arrow appears above the zero line, indicating directional momentum has turned bearish (DI- has overtaken DI+).
Use the optional rescaled ADX line to check whether the broader trend has enough strength to support the signal before acting on it.
The +25 / -25 dotted lines can be used as a rough guide for how pronounced the current directional imbalance is.

Notes

The rescaled ADX line is for visual reference only; it does not represent the standard 0–100 ADX scale unless the scale inputs are set to 0 and 100.
Works consistently across chart types since real market price data is always pulled via request.security(), regardless of the chart type currently displayed.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bybllo

//@version=6
// ══════════════════════════════════════════════════════════════════
// DMI DI Gap by Bybllo
// ══════════════════════════════════════════════════════════════════
// OVERVIEW
// This indicator plots the gap (difference) between the DI+ and DI-
// lines of the Directional Movement Index (DMI). Instead of visually
// comparing two separate DI+ / DI- lines to spot a crossover, the
// difference (DI+ minus DI-) is calculated directly and plotted as a
// single line around a zero baseline. A cross above the zero line
// signals a shift toward bullish momentum, while a cross below the
// zero line signals a shift toward bearish momentum - each crossing
// is automatically marked with a buy or sell arrow, so there is no
// need to eyeball where the two DI lines intersect.
//
// WHY A SINGLE "GAP" LINE INSTEAD OF TWO DI LINES
// The standard DMI/ADX display plots DI+ and DI- as two separate,
// overlapping lines - a crossover is only visible when you can spot
// the exact moment one line passes through the other, which gets
// harder to read the more volatile or choppy the two lines are.
// This indicator removes that ambiguity entirely by pre-computing
// DI+ minus DI- as one line: positive values mean DI+ is currently
// above DI- (bullish directional pressure), negative values mean
// DI- is above DI+ (bearish directional pressure), and the zero line
// is the exact crossover point. The result is a single, unambiguous
// line whose sign alone tells you which side is in control, and
// whose distance from zero tells you by how much.
//
// HOW THE GAP AND SIGNALS ARE CALCULATED
// - DI+ and DI- are calculated exactly as in the built-in "ADX and DI
//   with 2 Levels" study (Wilder's smoothing of directional movement
//   and true range over the "DI Length" input), so the underlying
//   math matches what most traders are already familiar with.
// - DI Gap = DI+ − DI-, which naturally ranges between -100 and +100.
// - A Buy Arrow is plotted the moment the DI Gap crosses above zero
//   (equivalent to a DI+ / DI- golden cross).
// - A Sell Arrow is plotted the moment the DI Gap crosses below zero
//   (equivalent to a DI+ / DI- dead cross).
// - Arrows are offset a configurable distance from the zero line
//   (Buy arrows below it, Sell arrows above it) purely so they don't
//   overlap the Gap line itself and stay easy to spot.
//
// OPTIONAL ADX OVERLAY (RESCALED)
// ADX (trend strength, 0-100, independent of direction) is calculated
// on the same "DI Length" and can be optionally overlaid as a dashed
// line on the same pane. Because ADX's native 0-100 scale would sit
// far outside the -100/+100 range of the Gap line, it is linearly
// rescaled to a custom min/max range you define ("ADX Scale Min/Max")
// so both series stay readable together. This line is for visual,
// relative reference only - use it to sanity-check whether the
// broader trend has enough strength behind a Gap crossover before
// treating it as significant, not as an absolute ADX reading unless
// the scale is explicitly set to 0/100.
//
// CLOUD AREA AND REFERENCE LINES
// - The area between the Gap line and the zero line is filled with
//   one color when the Gap is positive and another when it's
//   negative, making the current directional bias visible at a
//   glance even without looking at the line's exact value. The "Area
//   Fill Ratio" input controls how closely the fill hugs the Gap
//   line versus the zero line.
// - Dotted reference lines at +25 and -25 give a rough, at-a-glance
//   benchmark for how pronounced the current directional imbalance
//   is - values beyond these lines indicate a comparatively strong
//   one-sided reading, while values hovering near zero indicate a
//   more balanced, indecisive market.
//
// COLOR CUSTOMIZATION
// Line color, area color, and arrow colors can all be set
// independently for the positive (bullish) and negative (bearish)
// zones, so the indicator can be adapted to match your own chart
// theme or color conventions.
//
// CHART-TYPE COMPATIBILITY
// All price data is pulled via request.security() against the plain
// underlying ticker rather than read directly from the chart, so the
// DI+, DI-, Gap, and ADX values are identical whether your chart is
// displaying candlesticks, Heikin Ashi, Renko, or any other
// non-standard chart type - no distorted or unusable readings on
// synthetic chart types.
//
// HOW TO USE
// - When the DI Gap line crosses above zero, a buy arrow appears
//   below the zero line, indicating directional momentum has turned
//   bullish (DI+ has overtaken DI-).
// - When the DI Gap line crosses below zero, a sell arrow appears
//   above the zero line, indicating directional momentum has turned
//   bearish (DI- has overtaken DI+).
// - Use the optional rescaled ADX line to check whether the broader
//   trend has enough strength to support the signal before acting
//   on it - a crossover during a low, flat ADX reading is generally
//   less reliable than one occurring while ADX is elevated or rising.
// - The +25 / -25 dotted lines can be used as a rough guide for how
//   pronounced the current directional imbalance is, and can help
//   you distinguish a strong directional shift from a marginal,
//   near-zero wobble.
//
// NOTES
// - The rescaled ADX line is for visual reference only; it does not
//   represent the standard 0-100 ADX scale unless the scale inputs
//   are set to 0 and 100.
// - Works consistently across chart types since real market price
//   data is always pulled via request.security(), regardless of the
//   chart type currently displayed.
//
// DISCLAIMER
// For educational and informational purposes only. This is not
// financial advice. Past performance and simulated signals do not
// guarantee future results. Always backtest and forward-test before
// using with real capital.
// ══════════════════════════════════════════════════════════════════
indicator(title = 'DMI DI Gap by Bybllo', overlay = false, explicit_plot_zorder = true)

// ═══════════════════════════════
// INPUTS
// ═══════════════════════════════
len = input.int(14, 'DI Length')

showADX     = input.bool(true, 'Show ADX', group = 'ADX')
adxColor    = input.color(#93af12, 'ADX Color', group = 'ADX')
adxScaleMin = input.float(-18, 'ADX Scale Min', group = 'ADX', tooltip = 'Rescales ADX (originally 0-100) to this min-max range for display')
adxScaleMax = input.float(120, 'ADX Scale Max', group = 'ADX')

showArrows     = input.bool(true, 'Show Buy/Sell Arrows', group = 'Arrows')
buyArrowColor  = input.color(#d70000, 'Buy Arrow Color', group = 'Arrows')
sellArrowColor = input.color(#067814, 'Sell Arrow Color', group = 'Arrows')
arrowOffset    = input.float(13, 'Arrow - Zero Line Offset', minval = 0, group = 'Arrows', tooltip = 'Buy arrows are offset below the zero line, and sell arrows above the zero line, by this amount')

// ═══════════════════════════════
// Force real market prices regardless of chart type (Heikin Ashi,
// Renko, etc.) via request.security
// ═══════════════════════════════
t = ticker.new(syminfo.prefix, syminfo.ticker)
[rh, rl, rc] = request.security(t, timeframe.period, [high, low, close])

// ═══════════════════════════════
// DI+ / DI- calculation (same logic as the built-in ADX+DI with 2 Levels)
// ═══════════════════════════════
TrueRange = math.max(math.max(rh - rl, math.abs(rh - nz(rc[1]))), math.abs(rl - nz(rc[1])))
DirectionalMovementPlus = rh - nz(rh[1]) > nz(rl[1]) - rl ? math.max(rh - nz(rh[1]), 0) : 0
DirectionalMovementMinus = nz(rl[1]) - rl > rh - nz(rh[1]) ? math.max(nz(rl[1]) - rl, 0) : 0

SmoothedTrueRange = 0.0
SmoothedTrueRange := nz(SmoothedTrueRange[1]) - nz(SmoothedTrueRange[1]) / len + TrueRange

SmoothedDirectionalMovementPlus = 0.0
SmoothedDirectionalMovementPlus := nz(SmoothedDirectionalMovementPlus[1]) - nz(SmoothedDirectionalMovementPlus[1]) / len + DirectionalMovementPlus

SmoothedDirectionalMovementMinus = 0.0
SmoothedDirectionalMovementMinus := nz(SmoothedDirectionalMovementMinus[1]) - nz(SmoothedDirectionalMovementMinus[1]) / len + DirectionalMovementMinus

DIPlus  = SmoothedDirectionalMovementPlus  / SmoothedTrueRange * 100
DIMinus = SmoothedDirectionalMovementMinus / SmoothedTrueRange * 100

// ═══════════════════════════════
// DI Gap = difference between DI+ and DI- (-100 to +100)
// ═══════════════════════════════
diGap = DIPlus - DIMinus

// ═══════════════════════════════
// ADX calculation (0-100) → rescaled to the user-defined range
// ═══════════════════════════════
DX  = math.abs(DIPlus - DIMinus) / (DIPlus + DIMinus) * 100
ADX = ta.sma(DX, len)
adxRescaled = adxScaleMin + (ADX / 100) * (adxScaleMax - adxScaleMin)

// ═══════════════════════════════
// Colors (positive/negative zones, line and area configured separately)
// ═══════════════════════════════
lineUpColor   = input.color(#d70000,    "Line Color (Positive)", inline = "line", group = "Colors")
lineDownColor = input.color(#067814,    "Line Color (Negative)", inline = "line2", group = "Colors")
areaUpColor   = input.color(color.new(#f23645, 90),  "Area Color (Above / Below Zero)", inline = "area", group = "Colors")
areaDownColor = input.color(color.new(#4caf50, 91),  "",                                inline = "area", group = "Colors")
areaFillRatio = input.float(97, "Area Fill Ratio (%, proximity to line)", minval = 50, maxval = 100, step = 1, group = "Colors") / 100

gapAreaColor = diGap >= 0 ? areaUpColor : areaDownColor

gapLineColor = diGap >= 0 ? lineUpColor : lineDownColor

// ═══════════════════════════════
// Golden cross (turn positive) / dead cross (turn negative) detection
// ═══════════════════════════════
buyCross  = ta.crossover(diGap, 0)
sellCross = ta.crossunder(diGap, 0)
buyArrowY  = 0 - arrowOffset
sellArrowY = 0 + arrowOffset

// ═══════════════════════════════
// Draw order (explicit_plot_zorder=true, so the order below is applied as-is)
// 1. Area fill (drawn first, bottom-most) → 2. Reference lines (0, +25, -25)
//    → 3. ADX → 4. Line → 5. Arrows (top-most)
// ═══════════════════════════════
zeroPlot    = plot(0,    title = 'Zero Line (hidden, fill reference)',    display = display.none, editable = false)
fillRefPlot = plot(diGap * areaFillRatio, title = 'DI Gap (hidden, fill reference)', display = display.none, editable = false)
fill(zeroPlot, fillRefPlot, color = gapAreaColor, title = 'DI Gap Cloud Area')

hline(0,   title = 'Zero Line',   color = color.new(#787b86, 10), linestyle = hline.style_solid,  linewidth = 1)
hline(25,  title = 'Upper Line',  color = color.new(#787b86, 0),  linestyle = hline.style_dotted, linewidth = 1)
hline(-25, title = 'Lower Line',  color = color.new(#787b86, 0),  linestyle = hline.style_dotted, linewidth = 1)

plot(showADX ? adxRescaled : na, color = adxColor, title = 'ADX Line', linewidth = 1, precision = 2, linestyle = plot.linestyle_dashed)

plot(diGap, color = gapLineColor, title = 'DMI DI Gap Line', linewidth = 2, precision = 2)

plotshape(showArrows and buyCross  ? buyArrowY  : na, title = 'Buy Arrow',  style = shape.triangleup,   location = location.absolute, color = buyArrowColor,  size = size.tiny)
plotshape(showArrows and sellCross ? sellArrowY : na, title = 'Sell Arrow', style = shape.triangledown, location = location.absolute, color = sellArrowColor, size = size.tiny)
````
