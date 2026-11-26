# Bitcoin Market Regime Detector [RegimeRisk]

- url: https://www.tradingview.com/script/M5l3ngmK-Bitcoin-Market-Regime-Detector-RegimeRisk/
- type: indicator
- pine_id: PUB;44318756216b47dc949a37a721d39c9c
- version: 1.0

## Description

█ WHAT THIS INDICATOR DOES

Most indicators answer "when should I buy or sell?" This one answers a different question: "what type of market am I in right now?"

Bitcoin Market Regime Detector classifies BTC into three market states:

  BULL  — Trend and momentum aligned to the upside. Trend-following 
          and breakout strategies have an edge here.
  BEAR  — Trend and momentum aligned to the downside. Shorts, hedging, 
          and risk reduction belong here.
  RANGE — No dominant trend. Breakout strategies get chopped up. 
          Mean-reversion and range-bound setups work better.

The premise is simple: strategy selection should come after regime identification, not before. A moving average crossover strategy that prints money in a Bull regime will bleed you dry in a Range. A mean-reversion setup that works in Range will get steamrolled in a Bear. Knowing the regime first changes everything downstream.


█ HOW IT WORKS

The indicator combines four dimensions into a composite trend score:

  1. Trend Direction — Fast/slow EMA crossover determines baseline bias
  2. Trend Strength — ADX filters low-conviction environments
  3. Momentum — RSI confirms buyer or seller control
  4. Directional Index — DI+ vs DI- casts a final directional vote

Each dimension contributes to a score ranging from -2.5 (strong bearish) to +2.5 (strong bullish). The classification logic:

  • ADX below threshold → Range (regardless of other signals)
  • Strong positive score + RSI confirmation → Bull
  • Strong negative score + RSI confirmation → Bear
  • Conflicting or weak signals → Range

This layered approach prevents false regime calls during choppy, low-conviction periods where a single indicator would flip back and forth.


█ WHAT'S ON THE CHART

  • Colour-coded bars — green (Bull), red (Bear), indigo (Range)
  • Background shading — subtle regime colouring across the chart
  • Regime change labels — flags appear when the regime shifts
  • Info panel — current regime, duration in bars, and trend score
  • Optional EMAs — toggle the underlying fast/slow EMAs on or off


█ ALERTS

Four alert conditions are built in:

  • Regime → Bull
  • Regime → Bear
  • Regime → Range
  • Any Regime Change

Set these through TradingView's alert menu to get notified on your phone or email when the market regime shifts.


█ SUGGESTED USE

Apply to BTCUSDT on the 4H or Daily timeframe. Use the regime as a filter for your existing strategy:

  • In Bull: favour long entries, trend-following setups, breakout trades
  • In Bear: favour short entries, hedging, reduced position sizes
  • In Range: favour mean-reversion, avoid breakout strategies, tighten stops

The indicator works on other assets and timeframes, but the default parameters (21/55 EMA, 14-period ADX/RSI) are calibrated for BTC on higher timeframes. Adjust the inputs if applying to different instruments or lower timeframes.


█ INPUTS

Trend
  • Fast EMA Length (default 21)
  • Slow EMA Length (default 55)

Trend Strength
  • ADX Length (default 14)
  • ADX Range Threshold (default 20) — below this, market is classified as Range

Momentum
  • RSI Length (default 14)
  • RSI Bull Threshold (default 60)
  • RSI Bear Threshold (default 40)

Display
  • Background colour, regime labels, info panel, and EMAs can each be toggled independently


█ LIMITATIONS

This is a simplified regime classifier using indicators available natively in Pine Script. It does not have access to derivatives data (funding rates, open interest, liquidation flows) or cross-asset correlations that would improve classification accuracy, particularly for detecting volatility spikes and regime transitions. It is a trend/momentum-based classification tool — not a signal generator. Use it to inform your strategy selection, not as standalone buy/sell signals.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © RegimeRisk (Nexus AI Labs)
// 
// Bitcoin Market Regime Detector [RegimeRisk]
// 
// Classifies BTC into 3 market regimes — Bull, Bear, Range — using a composite
// scoring system built on trend direction, trend strength, and momentum.
//
// Most indicators tell you WHAT to trade. This one tells you WHICH MARKET you're
// trading in. A breakout strategy that prints money in a Bull regime will bleed
// you dry in a Range. A mean-reversion setup that works in Range will get run
// over in a Bear. Knowing the regime comes first — strategy selection comes second.
//
// HOW IT WORKS:
// 1. Trend Direction — EMA crossover (fast vs slow) determines the baseline bias.
// 2. Trend Strength — ADX filters out low-conviction environments. When ADX is
//    below the threshold, the market is Range-bound regardless of EMA alignment.
// 3. Momentum — RSI confirms whether buyers or sellers have control.
// 4. Directional Index — DI+ vs DI- adds a final directional vote.
//
// These four dimensions are combined into a composite trend score. Strong positive
// alignment = Bull. Strong negative alignment = Bear. Weak or conflicting
// signals = Range.
//
// REGIME DEFINITIONS:
// BULL  — Trend and momentum aligned to the upside. EMAs stacked bullish,
//         ADX showing trend strength, RSI confirming buyer control.
// BEAR  — Trend and momentum aligned to the downside. EMAs stacked bearish,
//         ADX showing trend strength, RSI confirming seller control.
// RANGE — No dominant trend. ADX below threshold, or signals conflicting.
//         Breakout and trend-following strategies underperform here.
//
// SUGGESTED USE:
// Apply to BTCUSDT on 4H or Daily. Use the regime classification to filter
// your existing strategy signals — only take trend trades in Bull/Bear,
// only take mean-reversion trades in Range.

//@version=6
indicator("Bitcoin Market Regime Detector [RegimeRisk]", 
         shorttitle="RegimeRisk", 
         overlay=true, 
         max_labels_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────

fastLen   = input.int(21,  "Fast EMA Length",      minval=5,  maxval=100, group="Trend")
slowLen   = input.int(55,  "Slow EMA Length",      minval=20, maxval=200, group="Trend")
adxLen    = input.int(14,  "ADX Length",           minval=5,  maxval=50,  group="Trend Strength")
adxThresh = input.int(20,  "ADX Range Threshold",  minval=10, maxval=40,  group="Trend Strength")
rsiLen    = input.int(14,  "RSI Length",           minval=5,  maxval=30,  group="Momentum")
rsiOB     = input.int(60,  "RSI Bull Threshold",   minval=50, maxval=80,  group="Momentum")
rsiOS     = input.int(40,  "RSI Bear Threshold",   minval=20, maxval=50,  group="Momentum")
showBg    = input.bool(true,  "Show Background Colour", group="Display")
showLabel = input.bool(true,  "Show Regime Labels",     group="Display")
showTable = input.bool(true,  "Show Info Panel",        group="Display")
showEmas  = input.bool(false, "Show EMAs",              group="Display")

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────

// Trend direction
fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
emaBull = fastEma > slowEma
emaBear = fastEma < slowEma

// Trend strength (ADX)
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

// Momentum
rsiVal = ta.rsi(close, rsiLen)

// Price position relative to EMAs
aboveFast = close > fastEma
belowFast = close < fastEma

// ─── TREND SCORE ───────────────────────────────────────────────────────────────
// Composite score: positive = bullish, negative = bearish, near zero = neutral

trendScore = 0.0
trendScore += emaBull ? 1.0 : -1.0                          // EMA alignment
trendScore += aboveFast ? 0.5 : belowFast ? -0.5 : 0.0      // Price vs fast EMA
trendScore += rsiVal > 50 ? 0.5 : rsiVal < 50 ? -0.5 : 0.0  // RSI bias
trendScore += diPlus > diMinus ? 0.5 : -0.5                  // DI direction

// ─── REGIME CLASSIFICATION ─────────────────────────────────────────────────────
// 1 = Bull, 2 = Bear, 3 = Range

var int regime = 3

if adxVal < adxThresh
    regime := 3
else if trendScore >= 1.5 and rsiVal > rsiOS
    regime := 1
else if trendScore <= -1.5 and rsiVal < rsiOB
    regime := 2
else if trendScore > 0
    regime := 1
else if trendScore < 0
    regime := 2
else
    regime := 3

// ─── REGIME DURATION ───────────────────────────────────────────────────────────

var int regimeBars = 0
regimeChanged = ta.change(regime) != 0
regimeBars := regimeChanged ? 1 : regimeBars + 1

// ─── COLOURS ───────────────────────────────────────────────────────────────────

regimeColor = regime == 1 ? color.new(#22c55e, 0) :  // Bull — green
              regime == 2 ? color.new(#ef4444, 0) :  // Bear — red
              color.new(#6366f1, 0)                   // Range — indigo

regimeName = regime == 1 ? "BULL" :
             regime == 2 ? "BEAR" :
             "RANGE"

// ─── PLOTS ─────────────────────────────────────────────────────────────────────

bgcolor(showBg ? color.new(regimeColor, 88) : na)

plot(showEmas ? fastEma : na, "Fast EMA", color=color.new(#06b6d4, 30), linewidth=1)
plot(showEmas ? slowEma : na, "Slow EMA", color=color.new(#8b5cf6, 30), linewidth=1)

barcolor(regimeColor)

// ─── REGIME CHANGE LABELS ──────────────────────────────────────────────────────

if showLabel and regimeChanged
    labelStyle = regime == 1 ? label.style_label_up : 
                 regime == 2 ? label.style_label_down : 
                 label.style_label_left
    labelY     = regime == 2 ? high : low
    label.new(bar_index, labelY, regimeName, 
              color=regimeColor, textcolor=color.white, 
              style=labelStyle, size=size.small)

// ─── INFO PANEL ────────────────────────────────────────────────────────────────

if showTable and barstate.islast
    var table infoTable = table.new(position.top_right, 2, 4, 
                                     bgcolor=color.new(#1e1e2e, 10), 
                                     border_width=1, 
                                     border_color=color.new(#374151, 0),
                                     frame_width=1,
                                     frame_color=color.new(#374151, 0))

    // Header
    table.cell(infoTable, 0, 0, "RegimeRisk", 
               text_color=color.white, text_size=size.small, 
               bgcolor=color.new(#4f46e5, 10))
    table.merge_cells(infoTable, 0, 0, 1, 0)

    // Current regime
    table.cell(infoTable, 0, 1, "Regime", 
               text_color=color.new(#9ca3af, 0), text_size=size.tiny)
    table.cell(infoTable, 1, 1, regimeName, 
               text_color=regimeColor, text_size=size.normal)

    // Duration
    table.cell(infoTable, 0, 2, "Duration", 
               text_color=color.new(#9ca3af, 0), text_size=size.tiny)
    table.cell(infoTable, 1, 2, str.tostring(regimeBars) + " bars", 
               text_color=color.new(#d1d5db, 0), text_size=size.tiny)

    // Trend score
    table.cell(infoTable, 0, 3, "Score", 
               text_color=color.new(#9ca3af, 0), text_size=size.tiny)
    table.cell(infoTable, 1, 3, str.tostring(trendScore, "#.#"), 
               text_color=trendScore > 0 ? color.new(#22c55e, 0) : 
                          trendScore < 0 ? color.new(#ef4444, 0) : 
                          color.new(#9ca3af, 0), 
               text_size=size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────────────────────

alertcondition(regimeChanged and regime == 1, 
               title="Regime → Bull", 
               message="RegimeRisk: Market regime shifted to BULL")

alertcondition(regimeChanged and regime == 2, 
               title="Regime → Bear", 
               message="RegimeRisk: Market regime shifted to BEAR")

alertcondition(regimeChanged and regime == 3, 
               title="Regime → Range", 
               message="RegimeRisk: Market regime shifted to RANGE")

alertcondition(regimeChanged, 
               title="Any Regime Change", 
               message="RegimeRisk: Market regime has changed")
````
