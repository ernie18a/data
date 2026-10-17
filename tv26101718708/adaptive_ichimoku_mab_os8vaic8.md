# Adaptive Ichimoku+ [MAB]

- url: https://www.tradingview.com/script/os8vAic8-Adaptive-Ichimoku-MAB/
- type: indicator
- pine_id: PUB;691dad6d7e0d461eba63845d849f42e1
- version: 1.0

## Description

Adaptive Ichimoku+ is a self-optimizing trend and structure indicator that dynamically selects the most effective Ichimoku parameters

Instead of relying on fixed Tenkan-sen and Kijun-sen periods, this indicator continuously evaluates multiple configurations and automatically selects the ones that have been performing best on recent price action — delivering an Ichimoku system that adapts to evolving market structure and trend conditions.

[b]🔶 HOW IT WORKS[/b]

Traditional Ichimoku uses fixed parameters (9-26-52), which may not suit all market environments. Adaptive Ichimoku+ enhances this by dynamically optimizing its core components:

Tenkan-sen (Conversion Line) → Multiple short-term periods are tested
Kijun-sen (Base Line) → Multiple medium-term periods are evaluated

Each configuration is scored using an exponential performance model that measures how consistently price respects the selected levels.

On every bar:

The best-performing Tenkan period is selected
The best-performing Kijun period is selected
These are used to construct the full Ichimoku system

The remaining components:

Senkou Span A → Midpoint of adaptive Tenkan and Kijun
Senkou Span B → Standard midpoint (user-defined period)
Chikou Span → Lagging price

This results in a fully adaptive Ichimoku structure that adjusts to both trend strength and market conditions.

[b]🔶 USAGE[/b]

🔹 Trend & Structure

Blue line — Adaptive Tenkan-sen (short-term momentum)
Pink line — Adaptive Kijun-sen (trend baseline)

Price above Kijun — Bullish structure
Price below Kijun — Bearish structure

🔹 Cloud (Kumo)

Green cloud — Bullish environment (Span A above Span B)
Red cloud — Bearish environment (Span A below Span B)

The cloud dynamically reflects support/resistance zones and trend strength.

🔹 Key Signals

Tenkan / Kijun Cross — Momentum shift within the trend
Price vs Kijun — Trend confirmation
Price vs Cloud — Market regime (trend vs consolidation)

Because the underlying parameters are adaptive, these signals are aligned with the most relevant structure for current price action.

[b]🔶 SETTINGS[/b]

🔹 Adaptive Engine

Perf EMA Length — Controls how quickly the parameter selection adapts. Lower values react faster; higher values provide stability.

🔹 Ichimoku Settings

Cloud Displacement — Forward shift applied to the cloud (standard Ichimoku behavior)
Senkou Span B Period — Lookback period for Span B calculation

[b]🔶 NOTES[/b]

Suitable for all markets and timeframes.
Works best as a complete trend, structure, and support/resistance system.
Adaptive parameter selection helps improve responsiveness while maintaining stability.
Can be used for trend following, breakout confirmation, and dynamic support/resistance analysis.
Past performance of any selected parameter does not guarantee future results — always apply proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MarketAlgoBot

// This source code is subject to the terms of the Mozilla Public License 2.0
// © MarketAlgoBot

//@version=6
indicator("Adaptive Ichimoku+",  overlay=true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
perfAlpha  = input.int(10, "Perf EMA Length",        minval=2, maxval=50,  group="Adaptive Engine")
displacement = input.int(26, "Cloud Displacement",   minval=1, maxval=52,  group="Ichimoku Settings")
senkouBPer = input.int(52,  "Senkou Span B Period",  minval=26, maxval=104, group="Ichimoku Settings")

// ─────────────────────────────────────────────
// HELPER — Ichimoku midpoint of highest/lowest
// ─────────────────────────────────────────────
ichiMid(len) =>
    (ta.highest(high, len) + ta.lowest(low, len)) / 2.0

// ─────────────────────────────────────────────
// PRE-COMPUTE ALL TENKAN SERIES AT GLOBAL SCOPE
// Tenkan variants: 7,9,11,13,15,17,19,21  (fixed Kijun=26 reference)
// Rule 1: NO ta.* inside loops
// ─────────────────────────────────────────────
tK7  = ichiMid(7)
tK9  = ichiMid(9)
tK11 = ichiMid(11)
tK13 = ichiMid(13)
tK15 = ichiMid(15)
tK17 = ichiMid(17)
tK19 = ichiMid(19)
tK21 = ichiMid(21)

// ─────────────────────────────────────────────
// PRE-COMPUTE ALL KIJUN SERIES AT GLOBAL SCOPE
// Kijun variants: 20,24,26,28,32,36,42,52  (fixed Tenkan=9 reference)
// ─────────────────────────────────────────────
kJ20 = ichiMid(20)
kJ24 = ichiMid(24)
kJ26 = ichiMid(26)
kJ28 = ichiMid(28)
kJ32 = ichiMid(32)
kJ36 = ichiMid(36)
kJ42 = ichiMid(42)
kJ52 = ichiMid(52)

// ─────────────────────────────────────────────
// PERFORMANCE SCORING — TENKAN LEADERBOARD
// Bullish: price > tenkan (tenkan rising as proxy: tenkan > tenkan[1])
// Score = EMA of math.sign(tenkan - tenkan[1])
// ─────────────────────────────────────────────
var float perfT7  = 0.0
var float perfT9  = 0.0
var float perfT11 = 0.0
var float perfT13 = 0.0
var float perfT15 = 0.0
var float perfT17 = 0.0
var float perfT19 = 0.0
var float perfT21 = 0.0

emaW = 2.0 / (perfAlpha + 1)

// Score = does price move WITH the tenkan direction?
// Tenkan is bullish when close > tenkan → align with price trend
perfT7  += emaW * (math.sign(close > tK7  ? 1 : -1) - perfT7)
perfT9  += emaW * (math.sign(close > tK9  ? 1 : -1) - perfT9)
perfT11 += emaW * (math.sign(close > tK11 ? 1 : -1) - perfT11)
perfT13 += emaW * (math.sign(close > tK13 ? 1 : -1) - perfT13)
perfT15 += emaW * (math.sign(close > tK15 ? 1 : -1) - perfT15)
perfT17 += emaW * (math.sign(close > tK17 ? 1 : -1) - perfT17)
perfT19 += emaW * (math.sign(close > tK19 ? 1 : -1) - perfT19)
perfT21 += emaW * (math.sign(close > tK21 ? 1 : -1) - perfT21)

// Best Tenkan — chained ternary (no array.get in critical path — Rule 3)
bestTPerf = math.max(perfT7, perfT9, perfT11, perfT13, perfT15, perfT17, perfT19, perfT21)

bestTenkan = bestTPerf == perfT7  ? tK7  :
             bestTPerf == perfT9  ? tK9  :
             bestTPerf == perfT11 ? tK11 :
             bestTPerf == perfT13 ? tK13 :
             bestTPerf == perfT15 ? tK15 :
             bestTPerf == perfT17 ? tK17 :
             bestTPerf == perfT19 ? tK19 : tK21

bestTenkanPer = bestTPerf == perfT7  ? 7  :
                 bestTPerf == perfT9  ? 9  :
                 bestTPerf == perfT11 ? 11 :
                 bestTPerf == perfT13 ? 13 :
                 bestTPerf == perfT15 ? 15 :
                 bestTPerf == perfT17 ? 17 :
                 bestTPerf == perfT19 ? 19 : 21

// ─────────────────────────────────────────────
// PERFORMANCE SCORING — KIJUN LEADERBOARD
// Score = does price stay on the correct side of kijun?
// ─────────────────────────────────────────────
var float perfK20 = 0.0
var float perfK24 = 0.0
var float perfK26 = 0.0
var float perfK28 = 0.0
var float perfK32 = 0.0
var float perfK36 = 0.0
var float perfK42 = 0.0
var float perfK52 = 0.0

perfK20 += emaW * (math.sign(close > kJ20 ? 1 : -1) - perfK20)
perfK24 += emaW * (math.sign(close > kJ24 ? 1 : -1) - perfK24)
perfK26 += emaW * (math.sign(close > kJ26 ? 1 : -1) - perfK26)
perfK28 += emaW * (math.sign(close > kJ28 ? 1 : -1) - perfK28)
perfK32 += emaW * (math.sign(close > kJ32 ? 1 : -1) - perfK32)
perfK36 += emaW * (math.sign(close > kJ36 ? 1 : -1) - perfK36)
perfK42 += emaW * (math.sign(close > kJ42 ? 1 : -1) - perfK42)
perfK52 += emaW * (math.sign(close > kJ52 ? 1 : -1) - perfK52)

// Best Kijun — chained ternary
bestKPerf = math.max(perfK20, perfK24, perfK26, perfK28, perfK32, perfK36, perfK42, perfK52)

bestKijun = bestKPerf == perfK20 ? kJ20 :
             bestKPerf == perfK24 ? kJ24 :
             bestKPerf == perfK26 ? kJ26 :
             bestKPerf == perfK28 ? kJ28 :
             bestKPerf == perfK32 ? kJ32 :
             bestKPerf == perfK36 ? kJ36 :
             bestKPerf == perfK42 ? kJ42 : kJ52

bestKijunPer = bestKPerf == perfK20 ? 20 :
               bestKPerf == perfK24 ? 24 :
               bestKPerf == perfK26 ? 26 :
               bestKPerf == perfK28 ? 28 :
               bestKPerf == perfK32 ? 32 :
               bestKPerf == perfK36 ? 36 :
               bestKPerf == perfK42 ? 42 : 52

// ─────────────────────────────────────────────
// ICHIMOKU COMPONENTS
// ─────────────────────────────────────────────

// Senkou Span A — midpoint of best Tenkan + best Kijun
senkouA = (bestTenkan + bestKijun) / 2.0

// Senkou Span B — 52-bar (or user) midpoint, displaced forward
senkouB = ichiMid(senkouBPer)

// Chikou Span — current close plotted back 'displacement' bars
chikouSpan = close

// ─────────────────────────────────────────────
// CLOUD DIRECTION
// ─────────────────────────────────────────────
bullishCloud = senkouA >= senkouB
cloudColorBull = color.new(#26a69a, 80)
cloudColorBear = color.new(#ef5350, 80)

// ─────────────────────────────────────────────
// PLOTS — 5 classic Ichimoku lines
// ─────────────────────────────────────────────

// 1. Tenkan-sen (Conversion Line) — adaptive
plot(bestTenkan, title="Tenkan-sen",
     color=color.new(#2196F3, 0), linewidth=1)

// 2. Kijun-sen (Base Line) — adaptive
plot(bestKijun, title="Kijun-sen",
     color=color.new(#E91E63, 0), linewidth=2)

// 3. Chikou Span — close offset into the past
plot(chikouSpan, title="Chikou Span",
     color=color.new(#9C27B0, 60), linewidth=1,
     offset=-displacement)

// 4 & 5. Senkou Span A & B — displaced into the future
p4 = plot(senkouA, title="Senkou Span A",
          color=color.new(#26a69a, 0), linewidth=1,
          offset=displacement)

p5 = plot(senkouB, title="Senkou Span B",
          color=color.new(#ef5350, 0), linewidth=1,
          offset=displacement)

// Cloud fill between Span A and Span B
fill(p4, p5,
     color=bullishCloud ? cloudColorBull : cloudColorBear,
     title="Kumo Cloud")
````
