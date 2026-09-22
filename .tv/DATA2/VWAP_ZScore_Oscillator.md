<!-- tradingview-pine-id: PUB;3e36fbaa26834ed7a86c61d2661f4086 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Z-Score Oscillator

Source: https://www.tradingview.com/script/Jxs0GSaH-VWAP-Z-Score-Oscillator/

## Description

**VWAP Z-Score Oscillator — Complete Description**

**Overview**

The indicator is a single-pane oscillator that measures how far price has moved from a rolling, volume-weighted average price. It answers one question on every bar: how far is price from its recent volume-weighted fair value, and how significant is that gap. The output can be shown either as a normalized standard-deviation reading or as the raw price distance, selectable by the user.

**Core Calculation**

- **Moving VWAP.** A rolling volume-weighted mean of price is computed over a user-set lookback. Unlike a session VWAP, it slides forward continuously and never resets at the session boundary.
- **Volume-weighted standard deviation.** The dispersion of price around that Moving VWAP is calculated as a volume-weighted variance, then square-rooted. It expands when volatility rises and contracts when the market is quiet.
- **Oscillator value.** In Z-Score mode the plotted value is the price-to-VWAP gap divided by that standard deviation, so the reading is expressed in standard deviations. In Distance mode the plotted value is the raw gap in the instrument's own price units. Zero means price is resting on the Moving VWAP; positive means above, negative means below.

**Two Display Modes**

- **Z-Score (σ).** Normalized. The band levels are read directly as standard deviations, and reference lines sit at constant levels. Because the scale is unit-free, the same levels carry the same meaning on any symbol or timeframe.
- **Distance.** Raw. The oscillator shows the actual price gap, and each band is drawn at its level multiplied by the standard deviation, so the bands widen and tighten with volatility while the raw distance stays interpretable.

**Multi-Timeframe Calculation**

A calculation-timeframe selector runs the entire computation on a chosen timeframe rather than only the chart's. The default uses the chart timeframe. Choosing a higher timeframe recomputes the Moving VWAP, the standard deviation, and the oscillator on that timeframe's bars and pulls the result back through a single combined data request. The request runs without look-ahead, so no future higher-timeframe data leaks into historical bars; the current higher-timeframe value continues updating until that bar closes.

**Visual Output**

- The oscillator plots as a histogram, colored by which side of the Moving VWAP price is on.
- The histogram fades across a user-defined transparency range: faint near the VWAP, intensifying to full color as price stretches to a set distance, then holding solid beyond it.
- A solid zero line marks the Moving VWAP.
- Three standard-deviation bands are drawn above and below zero, each with its own toggle, level, and color.

**User Inputs**

*Calculation Timeframe*
- **Calculation Timeframe** — the timeframe the oscillator is computed on. Options are labeled in plain language across seconds, minutes, hours, days, weeks, and a month, plus Chart. Chart uses the current chart timeframe. Higher timeframes give a broader context; lower-than-chart selections are not recommended, and seconds-based options only work on charts that support second-level data.

*Settings*
- **Oscillator Mode** — switches between Z-Score (σ), the normalized standard-deviation reading, and Distance, the raw price gap with volatility-scaled bands.
- **Source** — the price series feeding both the Moving VWAP and the distance measurement. Defaults to the average of high, low, and close; a close-only source reacts faster.
- **Moving VWAP Length** — the number of bars in the rolling window for both the VWAP and its standard deviation. Larger values are smoother and slower; smaller values are more reactive.
- **Fallback to MA on no-volume symbols** — when enabled, symbols that report no volume use a simple moving average and plain standard deviation so the oscillator still functions; when disabled, such symbols show nothing.

*Standard Deviation Bands (three identical rows: Band 1, Band 2, Band 3)*
- **Toggle** — shows or hides that band's upper and lower lines independently.
- **Level (Σ)** — that band's distance from zero, in standard deviations, adjustable in fine steps. Defaults are 1, 2, and 3.
- **Color** — the color applied to both the upper and lower line of that band.
- Band 2's level additionally sets the threshold used by the two stretch alerts.

*Colors*
- **Above VWAP** — histogram color when the oscillator is positive.
- **Below VWAP** — histogram color when the oscillator is negative.
- **Transparency at VWAP** — histogram transparency when price sits on the Moving VWAP; the faint end of the color range.
- **Transparency at Full Color** — histogram transparency once price reaches the full-color distance; the solid end of the range.
- **Full-Color Distance (σ)** — the standard-deviation distance over which the histogram fades from faint to solid; beyond it, the color holds solid.

**Data Window Outputs**

Two values are exposed for inspection or use by other scripts: the Moving VWAP and the standard deviation. The oscillator value itself is also readable from the histogram plot. These do not draw on the chart pane.

**Alerts**

Four alert conditions are available: price crossing above the Moving VWAP, crossing below it, stretching beyond Band 2's upper level, and stretching beyond Band 2's lower level. The stretch alerts follow Band 2's configured level in both modes.

**Behavioral Notes**

- In Z-Score mode the oscillator is unbounded. During a violent move it can spike past four or five standard deviations, which reflects genuine dislocation rather than a display error.
- The Style tab is intentionally empty; all appearance and behavior controls live in the Inputs tab, so nothing there can override the code-driven output.
- The indicator's sole basis is price distance from the Moving VWAP; there is no market-structure logic in the calculation.

---

## Source Code

````pine
//@version=6
indicator("VWAP Z-Score Oscillator", shorttitle="VZO", overlay=false)

// ══════════════════════════════════════════════════════════════════════════════
// VWAP Z-SCORE OSCILLATOR  |  Price distance from a rolling Moving VWAP.
//
//   Moving VWAP = rolling, volume-weighted mean of price over N bars. It slides
//   forward every bar and never resets at the session.
//
//   TWO DISPLAY MODES (Oscillator Mode input):
//
//     • Z-Score (σ)  — plots (price - Moving VWAP) / standard deviation.
//                       A normalized value: the band levels are read directly as
//                       standard deviations from fair value. Same scale on any
//                       symbol or timeframe. Band lines are constant levels.
//
//     • Distance     — plots the raw price gap (price - Moving VWAP) in the
//                       symbol's own units. Each band is drawn at (level × stdev)
//                       around zero, so the bands widen and tighten with
//                       volatility and the raw distance stays interpretable.
//
//   The standard deviation is VOLUME-WEIGHTED around the VWAP in both modes.
//   The three bands are user-configurable (toggle, level, and color each).
//   0 = price on the Moving VWAP; +/- = above/below.
// ══════════════════════════════════════════════════════════════════════════════


// ── Calculation Timeframe ─────────────────────────────────────────────────────
calcTF     = input.string("Chart", "Calculation Timeframe",
     options=["Chart",
              "1 second", "5 seconds", "15 seconds", "30 seconds",
              "1 minute", "3 minutes", "5 minutes", "15 minutes", "30 minutes", "45 minutes",
              "1 hour", "2 hours", "3 hours", "4 hours", "6 hours", "8 hours", "12 hours",
              "1 day", "1 week", "1 month"],
     group="Calculation Timeframe",
     tooltip="Timeframe the oscillator is calculated on. 'Chart' uses the current chart timeframe. Pick a higher timeframe to read the Moving VWAP distance from a broader, higher-timeframe context while trading a lower timeframe. Selecting a timeframe lower than the chart is not recommended. Note: seconds-based timeframes only work on charts that support them.")


// ── Settings ──────────────────────────────────────────────────────────────────
mode       = input.string("Distance", "Oscillator Mode",
     options=["Distance", "Z-Score (σ)"], group="Settings",
     tooltip="Z-Score (σ): distance from the Moving VWAP divided by its standard deviation — normalized, where the band levels are standard deviations and the scale is comparable across symbols and timeframes.  Distance: the raw price gap from the Moving VWAP in the symbol's own units, with the standard-deviation bands drawn dynamically around it.")
src        = input.source(hlc3, "Source", group="Settings",
     tooltip="Price series used for both the Moving VWAP and the distance measurement. HLC3 (average of high, low, and close) is a balanced default; switch to Close for a faster, close-only reading.")
length     = input.int(50, "Moving VWAP Length", minval=2, maxval=1000, group="Settings",
     tooltip="Number of bars in the rolling Moving VWAP window and its standard deviation. Larger values give a smoother, slower fair-value reference; smaller values react faster.")
useFallback= input.bool(true, "Fallback to MA on no-volume symbols", group="Settings",
     tooltip="Some symbols (certain forex/indices) report no volume. When on, the oscillator falls back to a simple moving average and plain standard deviation so it still works. When off, it shows nothing on volumeless symbols.")


// ── Standard Deviation Bands ──────────────────────────────────────────────────
// Each band row: on/off toggle, level in standard deviations (Σ), and color.
b1On  = input.bool(false, "Band 1", inline="b1", group="Standard Deviation Bands")
b1Lvl = input.float(1.0, "Σ",      inline="b1", group="Standard Deviation Bands", minval=0.0, step=0.1)
b1Col = input.color(color.new(color.gray, 40), "", inline="b1", group="Standard Deviation Bands",
     tooltip="Band 1 — nearest band. Toggle shows/hides its upper and lower lines; Σ sets its level in standard deviations; the color applies to both lines.")
b2On  = input.bool(true, "Band 2", inline="b2", group="Standard Deviation Bands")
b2Lvl = input.float(2.0, "Σ",      inline="b2", group="Standard Deviation Bands", minval=0.0, step=0.1)
b2Col = input.color(color.new(color.orange, 30), "", inline="b2", group="Standard Deviation Bands",
     tooltip="Band 2 — middle band. Toggle, level (Σ), and color. Note: Band 2's level also sets the threshold for the two 'stretched' alerts.")
b3On  = input.bool(false, "Band 3", inline="b3", group="Standard Deviation Bands")
b3Lvl = input.float(3.0, "Σ",      inline="b3", group="Standard Deviation Bands", minval=0.0, step=0.1)
b3Col = input.color(color.new(color.red, 20), "", inline="b3", group="Standard Deviation Bands",
     tooltip="Band 3 — outermost band. Toggle, level (Σ), and color, for flagging extreme dislocation.")


// ── Colors ────────────────────────────────────────────────────────────────────
upCol      = input.color(color.new(#26A69A, 0), "Above VWAP", group="Colors",
     tooltip="Histogram color when price is above the Moving VWAP (positive oscillator).")
dnCol      = input.color(color.new(#EF5350, 0), "Below VWAP", group="Colors",
     tooltip="Histogram color when price is below the Moving VWAP (negative oscillator).")
nearTransp = input.int(65, "Transparency at VWAP", minval=0, maxval=100, group="Colors",
     tooltip="Histogram transparency when price sits on the Moving VWAP (0 = solid, 100 = invisible). The color fades from here toward the full-color transparency as price stretches away.")
farTransp  = input.int(0, "Transparency at Full Color", minval=0, maxval=100, group="Colors",
     tooltip="Histogram transparency once price reaches the full-color distance below. 0 = fully solid.")
fullSigma  = input.float(2.0, "Full-Color Distance (σ)", minval=0.1, step=0.1, group="Colors",
     tooltip="Distance in standard deviations at which the histogram reaches full color. Between the VWAP and this level the color fades across the transparency range set above. Beyond it the color stays solid.")

modeDist   = mode == "Distance"


// ══════════════════════════════════════════════════════════════════════════════
// MOVING VWAP
// ══════════════════════════════════════════════════════════════════════════════

avgVol  = ta.sma(volume, length)
hasVol  = avgVol > 0
mvwap   = hasVol ? ta.vwma(src, length) : (useFallback ? ta.sma(src, length) : na)


// ══════════════════════════════════════════════════════════════════════════════
// STANDARD DEVIATION OF PRICE AROUND THE VWAP
// ══════════════════════════════════════════════════════════════════════════════

// Volume-weighted variance: E[x^2 * w] / E[w] - vwap^2
vwMeanSq = hasVol ? ta.sma(src * src * volume, length) / avgVol : na
vwVar    = hasVol ? vwMeanSq - mvwap * mvwap : na
vwStdev  = hasVol and not na(vwVar) ? math.sqrt(math.max(vwVar, 0)) : na

// Plain standard deviation fallback for no-volume symbols
stdev    = hasVol and not na(vwStdev) and vwStdev > 0 ? vwStdev : ta.stdev(src, length)


// ══════════════════════════════════════════════════════════════════════════════
// OSCILLATOR VALUE  (per selected mode)
// ══════════════════════════════════════════════════════════════════════════════

dist  = src - mvwap                              // raw price distance
zDist = stdev > 0 ? dist / stdev : 0.0           // distance in standard deviations
osc   = modeDist ? dist : zDist


// ══════════════════════════════════════════════════════════════════════════════
// CALCULATION TIMEFRAME RESOLUTION
//   "Chart" resolves to the chart's own timeframe. Any higher timeframe
//   recomputes the Moving VWAP, standard deviation, and oscillator on that
//   timeframe's bars. lookahead_off keeps the value non-anticipating; it
//   updates until the higher-timeframe bar closes.
// ══════════════════════════════════════════════════════════════════════════════

tfRes = switch calcTF
    "Chart"      => timeframe.period
    "1 second"   => "1S"
    "5 seconds"  => "5S"
    "15 seconds" => "15S"
    "30 seconds" => "30S"
    "1 minute"   => "1"
    "3 minutes"  => "3"
    "5 minutes"  => "5"
    "15 minutes" => "15"
    "30 minutes" => "30"
    "45 minutes" => "45"
    "1 hour"     => "60"
    "2 hours"    => "120"
    "3 hours"    => "180"
    "4 hours"    => "240"
    "6 hours"    => "360"
    "8 hours"    => "480"
    "12 hours"   => "720"
    "1 day"      => "D"
    "1 week"     => "W"
    "1 month"    => "M"
    =>              timeframe.period

[oscTF, mvwapTF, stdevTF] = request.security(syminfo.tickerid, tfRes,
     [osc, mvwap, stdev], lookahead = barmerge.lookahead_off)


// ══════════════════════════════════════════════════════════════════════════════
// BAND LEVELS
//   Levels are standard-deviation multiples. In Z-Score mode a band is a
//   constant level; in Distance mode it becomes (level × stdev), so it moves
//   with volatility around zero.
// ══════════════════════════════════════════════════════════════════════════════

lvl1 = modeDist ? b1Lvl * stdevTF : b1Lvl
lvl2 = modeDist ? b2Lvl * stdevTF : b2Lvl
lvl3 = modeDist ? b3Lvl * stdevTF : b3Lvl


// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════

// Color by side of the VWAP, fading across the user color range from the VWAP
// (nearTransp) out to the full-color distance (farTransp). Beyond it stays solid.
baseCol = oscTF >= 0 ? upCol : dnCol
gRef    = modeDist ? fullSigma * stdevTF : fullSigma
histCol = color.from_gradient(math.abs(oscTF), 0.0, math.max(gRef, 0.0001),
     color.new(baseCol, nearTransp), color.new(baseCol, farTransp))

plot(oscTF, "VZO", style=plot.style_histogram, color=histCol, linewidth=4, editable=false)

hline(0, "VWAP (Zero)", color=color.new(color.gray, 20), linestyle=hline.style_solid, editable=false)

// Standard-deviation bands (constant in Z-Score mode, dynamic in Distance mode).
// Each band uses its own color and is gated by its own toggle.
plot(b1On ?  lvl1 : na, "+Band 1", color=b1Col, linewidth=1, display=display.pane, editable=false)
plot(b1On ? -lvl1 : na, "-Band 1", color=b1Col, linewidth=1, display=display.pane, editable=false)
plot(b2On ?  lvl2 : na, "+Band 2", color=b2Col, linewidth=1, display=display.pane, editable=false)
plot(b2On ? -lvl2 : na, "-Band 2", color=b2Col, linewidth=1, display=display.pane, editable=false)
plot(b3On ?  lvl3 : na, "+Band 3", color=b3Col, linewidth=1, display=display.pane, editable=false)
plot(b3On ? -lvl3 : na, "-Band 3", color=b3Col, linewidth=1, display=display.pane, editable=false)


// ══════════════════════════════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════════════════════════════

plot(mvwapTF, "Moving VWAP", display=display.data_window, editable=false)
plot(stdevTF, "Std Dev",     display=display.data_window, editable=false)


// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(ta.crossover(oscTF, 0),      "VZO: Cross Above VWAP", "VZO: Price crossed ABOVE the Moving VWAP")
alertcondition(ta.crossunder(oscTF, 0),     "VZO: Cross Below VWAP", "VZO: Price crossed BELOW the Moving VWAP")
alertcondition(ta.crossover(oscTF, lvl2),   "VZO: Stretched Above",  "VZO: Price stretched beyond the upper Band 2 level")
alertcondition(ta.crossunder(oscTF, -lvl2), "VZO: Stretched Below",  "VZO: Price stretched beyond the lower Band 2 level")
````
