# Ulcer Index Baseline Deviation - Z Columns & Percentile

- url: https://www.tradingview.com/script/7eGdhuvR/
- type: indicator
- pine_id: PUB;d57a29f19803412ea91e82c2a0561c1a
- version: 1.0

## Description

This indicator compares Peter Martin's Ulcer Index against its own long-term baseline, then shows the result through two scale-free readouts, so that readings carry the same meaning across different symbols.
The Ulcer Index (Martin and McCann, 1989) measures the depth and duration of percentage drawdowns from prior highs, in other words how painful it has been to hold a position. Unlike standard deviation, it looks only at the downside. Martin read the index against its own long-term average: pain rising above its normal range signals elevated downside risk.
The script computes the Ulcer Index over a rolling window (default 50 daily bars), subtracts its long-term EMA (default 200 bars, roughly one year on a daily chart) to obtain the deviation, then presents that deviation in two ways over the same 200-bar window. The columns are a robust z-score, built from the median and the median absolute deviation with the usual 1.4826 consistency factor, so column height reads in standard-deviation equivalents and keeps resolving even while new records are being set. Column color follows the sign of the z-score: red when the deviation sits above its trailing median, teal when below. The orange line is a percentile rank scaled to zero-to-one: 0.5 means today's deviation sits at the trailing median, 1 means it is the record of the window.
How to read it: tall red columns with the orange line pinned near 1 mark a genuine extreme. Tall columns with the line in mid-range mean a large move that is routine for this symbol. A pinned line above modest columns means a normally calm symbol breaking its own record at ordinary size. Columns are persistent and will stay one color for weeks inside a drawdown regime. Note that the color flip only approximates the true baseline crossover: the deviation series is right-skewed, its trailing median sits slightly below zero, so the flip typically leads the crossover by a few bars. For the exact regime, chart the raw Ulcer Index against its EMA.
Notes and limits: both readouts are normalized to each symbol's own history, so they compare rarity and relative size, not absolute drawdown. To compare absolute pain across symbols, chart the raw Ulcer Index instead. Use identical settings on every symbol you compare, and allow several hundred bars of history for warm-up. The deviation, z-score, and percentile layers are an original extension, not part of Martin's published work, so validate behavior against historical drawdowns you recognize. This is a risk-regime gauge, not a buy or sell signal generator, and nothing here is investment advice.

## Source Code

````pine
//@version=6
// =============================================================================
// Ulcer Index Baseline Deviation — Z Columns & Percentile
// -----------------------------------------------------------------------------
// Pipeline:
//   1) Ulcer Index over `uiLength` bars: root-mean-square of percentage
//      drawdowns from the period high (Peter Martin's formula).
//   2) Deviation: ulcerIndex - EMA(ulcerIndex, baselineLength). How far
//      current pain sits above or below this symbol's own long-term norm.
//   3) Two scale-free readouts of the finished deviation, both over the same
//      `baselineLength` window:
//        - COLUMNS: robust z-score (median / MAD, x1.4826), in
//          sigma-equivalent units. Height = magnitude. Color = sign of z:
//          red above the trailing median, teal below.
//        - ORANGE LINE: percentile rank scaled to 0..1. Rarity of today's
//          deviation within the window; 0.5 = median, 1 = window record.
//
// Notes:
//   - The column color flip only approximates the true baseline crossover.
//     The deviation series is right-skewed, so its trailing median sits
//     slightly below zero and the flip typically leads the crossover by a
//     few bars. For the exact regime, chart the raw Ulcer Index vs its EMA.
//   - Z columns are persistent: inside a drawdown regime they stay one color
//     for weeks. Large solid blocks are expected behavior.
//   - Both readouts are normalized to each symbol's own history; absolute
//     cross-symbol pain is not on this chart. Use identical settings on
//     every symbol compared. Allow several hundred bars of warm-up.
// =============================================================================
indicator("Ulcer Index Baseline Deviation — Z Columns & Percentile", shorttitle="UI Dev Z+%ile", overlay=false)

// -- Inputs --
uiLength       = input.int(50,  "Ulcer Index length",  minval=1,
     tooltip="Drawdown window for the Ulcer Index.")
baselineLength = input.int(200, "Baseline EMA length", minval=2,
     tooltip="Long-term EMA of the Ulcer Index. Also the window for the robust z-score and the percentile rank.")
priceSource    = input.source(close, "Price source")

// -- Ulcer Index (Peter Martin) --
periodHigh  = ta.highest(priceSource, uiLength)
drawdownPct = 100.0 * (priceSource - periodHigh) / periodHigh            // <= 0
ulcerIndex  = math.sqrt(math.sum(drawdownPct * drawdownPct, uiLength) / uiLength)

// -- Deviation: pain gauge vs its long-term baseline --
deviation = ulcerIndex - ta.ema(ulcerIndex, baselineLength)

// -- Magnitude: robust z in sigma-equivalent units --
// MAD uses each bar's rolling median inside abs() (streaming approximation).
// 1.4826 is the usual consistency factor; the floor guards against division
// by ~zero in flat stretches.
medDeviation = ta.median(deviation, baselineLength)
madDeviation = ta.median(math.abs(deviation - medDeviation), baselineLength)
robustZ      = (deviation - medDeviation) / math.max(1.4826 * madDeviation, 1.0e-4)

// -- Rarity: percentile rank scaled to 0..1 --
rarityPercentile = ta.percentrank(deviation, baselineLength) / 100.0

// -- Plot: columns first, line on top --
columnColor = robustZ >= 0 ? color.new(color.red, 40) : color.new(color.teal, 40)
plot(robustZ,          "Robust z (sigma)",         color=columnColor,                style=plot.style_columns)
plot(rarityPercentile, "Rarity percentile (0..1)", color=color.new(color.orange, 0), linewidth=2)
hline(0.5, "Percentile median",           color=color.gray,                linestyle=hline.style_dashed)
hline(1.0, "Percentile ceiling",          color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(0.0, "Zero (z) / percentile floor", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// Not investment advice. The Ulcer Index and its deviation describe past
// drawdowns; they do not predict future behavior.
````
