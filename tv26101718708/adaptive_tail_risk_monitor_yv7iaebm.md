# Adaptive Tail Risk Monitor

- url: https://www.tradingview.com/script/yv7iAEbM-Adaptive-Tail-Risk-Monitor/
- type: indicator
- pine_id: PUB;b3421ec57bef49ecaaed47e372317323
- version: 1.0

## Description

Adaptive Tail Risk Monitor (ATRM)

What It Is

The Adaptive Tail Risk Monitor (ATRM) is a real-time statistical framework designed to map the changing architecture of asset return distributions. Most traditional indicators measure momentum, trend, or simple volatility. ATRM measures something deeper: the structural asymmetry and tail behavior of recent returns.

By calculating the 3rd moment (Skewness) and 4th moment (Kurtosis) of the return distribution and processing them through a rolling percentile framework, ATRM normalizes this advanced data against an asset’s own historical footprint. The result is a dynamic, self-calibrating view of market risk that automatically adapts to any financial instrument or timeframe.

Why It Was Built

Standard technical tools are largely blind to distributional shifts. A market can trend calmly while quietly accumulating statistical instability long before price confirmation becomes visually obvious. Hidden anomalies—such as fat tails, negative skew, and rising kurtosis—frequently precede major market regime transitions.

ATRM was built to surface these hidden conditions. By combining rolling central moment (skewness and kurtosis) estimation with adaptive percentile ranking, it converts abstract mathematical concepts into a highly interpretable visual dashboard. It tells you not just what the market is doing, but what kind of statistical regime you are operating in.

Core Concepts

🧠 Adaptive Percentile Framework

ATRM operates without static thresholds.

Instead, Skewness and Kurtosis are continuously evaluated relative to their own historical distributions using rolling percentile ranking.

This adaptive approach allows the framework to:

• Normalize behavior across asset classes
• Adapt across timeframes
• Remain responsive to structural market shifts
• Improve regime consistency

Key Takeaway:

Percentile levels represent relative statistical positioning unique to that specific asset’s history, rather than arbitrary fixed values.

1. Skewness — Asymmetric Return Conditions

Skewness is directional, measuring whether the return distribution is becoming positively or negatively imbalanced. It defines which side of the distribution carries the greater tail concentration.

Positive Skewness:
• Upside returns dominate
• Positive outliers become more frequent
• Bullish expansion conditions may be developing

Negative Skewness:
• Downside returns dominate
• Negative outliers increase
• Bearish asymmetry may be emerging

🟩 Skewness Color Mapping

The skewness line dynamically changes color according to its historical percentile state:

🟩 Extreme Positive Asymmetry: ≥ 90th percentile
🍏 Positive Asymmetry: 65th–90th percentile
⬜ Neutral Symmetry: 35th–65th percentile
🍎 Negative Asymmetry: 10th–35th percentile
🟥 Extreme Negative Asymmetry: < 10th percentile

2. Kurtosis — Extreme Return Conditions (Tail Risk)

Kurtosis measures the concentration and extremity of outliers (the thickness of the tails). Excess kurtosis is non-directional; it flags the probability of extreme price shocks regardless of sign. Elevated kurtosis tells you that the tails are getting fat, extreme returns are becoming more frequent, while Skewness provides the directional context.

High Kurtosis typically flags:
• Volatility expansion
• Large price movements
• Panic or euphoric phases
• Unstable regime transitions

Low Kurtosis reflects:
• Stable, balanced conditions
• Mean-reverting environments
• Limited tail expansion

🔵 Kurtosis Color Mapping

The kurtosis plot dynamically shifts color to indicate tail expansion intensity:

🔵 Extreme Expansion: ≥ 90th percentile
🔹 Elevated Expansion: 75th–90th percentile
⚪ Baseline Conditions: < 75th percentile

🖥️ Market Condition Framework

The indicator synthesizes both Skewness and Kurtosis states into a unified classification system, painting the chart background when critical structural transitions occur.

🟩 Bright Green — Positive Returns Dominant
Skewness ≥ 90th percentile & Kurtosis ≥ 90th percentile

🍏 Light Green — Positive Returns More Frequent
Skewness 65th–90th percentile & Kurtosis ≥ 75th percentile

🟦 Blue — Neutral Expansion
Skewness 35th–65th percentile & Kurtosis ≥ 75th percentile

🍎 Light Red — Negative Returns More Frequent
Skewness 10th–35th percentile & Kurtosis ≥ 75th percentile

🟥 Bright Red — Negative Returns Dominant
Skewness < 10th percentile & Kurtosis ≥ 90th percentile

⬛ Baseline Conditions
Kurtosis < 75th percentile
(Stable, low-dispersion environment)

This framework allows traders to quickly assess whether market conditions are becoming increasingly directional, increasingly unstable, or returning toward equilibrium.

🛠️ User Settings & Customization

Rolling Window

Controls the initial Skewness and Kurtosis estimation lookback.

• Shorter windows increase responsiveness
• Longer windows increase statistical stability

Minimum recommended: Intraday/Daily 63+, Weekly 52+, Monthly 36+. 

Percentile Window

Sets the lookback for historical percentile ranking. For statistical integrity, this window must exceed the Rolling Window length for Skewness and Kurtosis.

Minimum recommended: Intraday/Daily 126+, Weekly 52+,  Monthly 36+. Longer windows produce more stable percentile ranks

EMA Smoothing

Applies exponential smoothing to reduce noise on raw statistical estimates.

• 3–5 = higher responsiveness
• 8–13 = greater stability

Higher values improve stability but increase lag during regime transitions.

Display Style Flexibility

Users can independently switch display formats (Line, Columns, Histogram, or Area) for both Kurtosis and Skewness via the native TradingView Style menu.

Visibility Controls & Legends

Fully customize or toggle:
• Percentile bands
• Background colors
• Legend tables

⚙️ Multi-Panel Configuration Note

For maximum clarity, consider loading ATRM twice as separate indicator panes:

• One configured to display only Skewness
• One configured to display only Kurtosis

⚠️ CRITICAL REQUIREMENT: When stacking multiple ATRM instances across separate panes, maintain identical Rolling Window lengths to keep percentile states synchronized.

Different lookback windows create independent historical distributions, which may lead to desynchronized percentile states and inconsistent regime classification between panels.


📈 Application Examples & Strategy Filters

1. ATRM + RSI — Filtering False Reversals

RSI is designed to identify overbought and oversold conditions but cannot evaluate whether the surrounding market environment supports stable mean reversion or continued directional expansion. ATRM fills that gap by providing distributional context around the signal.

The Oversold Trap — Avoiding False Reversals

The Setup
RSI overbought/oversold signals perform best during mean-reverting environments but often struggle during sustained trends or market dislocation phases. A common trap is buying a deeply oversold RSI reading during an aggressive market decline. The RSI signal looks like a reversal opportunity but the market continues lower.

The Filter
If RSI flashes an oversold signal while ATRM Skewness is firmly in its lower percentiles (< 35th percentile) and Kurtosis is elevated (> 75th percentile), the return distribution remains heavily negatively skewed with elevated tail expansion. Avoid mean-reversion longs in this environment. Wait for Skewness to recover toward the neutral zone before attempting reversal entries.

The Confirmed Reversal — High-Confidence Mean Reversion

The Setup
Following a period of market stress, RSI moves into oversold territory while distributional conditions begin to stabilize. The question is whether the signal reflects genuine mean-reversion potential or another false recovery.

The Filter
When Kurtosis is below the 75th percentile and Skewness is neutral, the market is operating in a more stable, symmetric environment where RSI reversal signals carry higher confidence.

2. ATRM + MACD — Confirming Breakouts & Avoiding Whipsaws

Standard indicators like RSI, MACD, or Moving Averages track trend and momentum but cannot detect the underlying shape of the return distribution. ATRM acts as a distributional condition filter—helping determine whether a strategy's signals are operating in a favorable or unstable statistical environment.

The Breakout Confirmation — Filtering False Crossovers

The Setup
MACD crossovers frequently generate false signals during choppy, low-conviction markets. Look for periods where Kurtosis is compressed near the bottom of its historical range, indicating a low-dispersion environment where crossover signals should be treated with skepticism.

The Filter
When a fresh MACD crossover occurs simultaneously with Kurtosis breaking upward through the 75th percentile, it confirms the return distribution is expanding to support a genuine directional move. The MACD provides the directional entry; ATRM confirms the structural conditions support it.

The Exhaustion Warning — Avoiding Late-Stage Exposure

The Setup
A bullish MACD crossover occurs after a prolonged advance, potentially pulling in late buyers near the late-stage extension point of a structural move.

The Filter
If the crossover occurs while Kurtosis is already above the 90th percentile and Skewness remains highly positive, the distribution is statistically stretched. Reduce position sizing or trail stops aggressively rather than initiating fresh exposure at that stage.

3. ATRM + Moving Average Crossovers — Filtering Trend Whipsaws

Moving average crossovers are designed to capture shifting trends but have no built-in mechanism to evaluate whether the market environment actually supports a sustained directional move. ATRM fills that gap by providing the distributional context the crossover itself cannot see.

The Squeeze and Launch — High-Probability Breakouts

The Setup
During sideways, range-bound markets, moving averages flatten and cross repeatedly in both directions, generating false signals. Look for periods where the averages are tangled while ATRM Kurtosis is flat near the bottom of its historical range — this is a compressed, low-dispersion environment where breakout signals should be treated with skepticism.

The Filter
Do not trade minor crossovers while Kurtosis remains compressed. Wait for the bar where a fresh MA crossover coincides with Kurtosis breaking upward through the 75th percentile. This indicates the return distribution is beginning to expand, which is consistent with a genuine directional move emerging from the consolidation. The crossover gives direction; ATRM confirms the distributional conditions have shifted to support it.

The Climax Trap — Avoiding Late-Stage Entries

The Setup
An asset enters a strong, sustained advance. A lagging moving average crossover finally triggers a bullish signal after price has already moved significantly, pulling in late trend-followers near the exhaustion point.

The Filter
If the crossover occurs while Kurtosis is already above the 90th percentile and Skewness is in the upper percentiles, the distribution is statistically extended. This does not guarantee reversal, but it indicates the market is in a high-dispersion, asymmetric state that is less favorable for new long entries. Use this condition to trail existing stops aggressively rather than initiating fresh positions.

The Dead Cat Bounce — Identifying False Recoveries

The Setup
Following a sharp decline, price bounces and shorter-term moving averages cross back to the upside, creating the appearance of a trend reversal. This pattern frequently traps traders who interpret the crossover as confirmation that the worst is over.

The Filter
If the bullish crossover occurs while ATRM Skewness remains below the 10th percentile, the return distribution is still heavily negatively skewed. The underlying conditions that drove the decline have not resolved. Treat the crossover as a potential continuation pattern rather than a confirmed reversal, and approach any long signal with significantly reduced conviction until skewness recovers toward the neutral zone.

📌Important note: ATRM is not a standalone entry/exit signal. Use it as a market condition filter layered over your existing strategy — tighten risk or reduce exposure when tail risk is accumulating, increase exposure when distributional conditions are favorable.


Disclaimer

ATRM is an analytical framework developed for educational and research purposes. It does not constitute financial or investment advice.

All trading involves substantial financial risk.

## Source Code

````pine
//@version=6
indicator("Adaptive Tail Risk Monitor", shorttitle="ATRM", overlay=false)
// © TrendAdvantage
// ═══════════════════════════════════════════════════
// Adaptive Tail Risk Monitor (ATRM)
// ═══════════════════════════════════════════════════
// Description:
// A statistical framework that monitors the shape of the
// return distribution in real time using:
//
// • 3rd Moment → Skewness
// • 4th Moment → Kurtosis
//
// Skewness and kurtosis are evaluated relative to their
// own historical distributions through rolling percentile
// analysis to identify evolving market regimes and tail
// risk conditions.
// ═══════════════════════════════════════════════════
// License: Mozilla Public License 2.0 (MPL-2.0)
// https://mozilla.org/MPL/2.0/
//
// This source code is subject to the terms of the MPL 2.0.
// Any derivative work must retain this copyright notice.
// ═══════════════════════════════════════════════════
// TradingView: tradingview.com/u/TrendAdvantage
// ============================================================
// HOUSE RULES COMPLIANCE & RISK DISCLAIMER
// ============================================================
// This indicator is an adaptive econometric regime-monitoring tool.
// Statistical properties of historical returns do not guarantee
// future market behavior. Higher-order moments such as skewness
// and kurtosis may lag during rapid market transitions.
// ============================================================
// INPUTS
// ============================================================

roll_len = input.int(
     63,
     "Rolling Window (Kurtosis and Skewness)",
     minval = 36,
     maxval = 500,
     tooltip = "Minimum recommended: Intraday/Daily 63+ | Weekly 52+ | Monthly 36+. Longer windows improve stability, shorter windows improve responsiveness."
)

pct_len = input.int(
     252,
     "Percentile Window (Lookback)",
     minval = 36,
     maxval = 1000,
     tooltip = "Builds the baseline probability distribution. Minimum recommended: Intraday/Daily 126+ | Weekly 52+ | Monthly 36+. Critical: Should exceed the Rolling Window (Kurtosis and Skewness). Longer windows produce more stable percentile ranks"
)

smooth_len = input.int(
     5,
     "EMA Smoothing Length",
     minval = 1,
     maxval = 20,
     tooltip = "Smooths kurtosis and skewness to reduce noise. Recommended: 3-5 for responsiveness | 8-13 for stability. Higher values improve stability but increase lag during regime transitions."
)

// ============================================================
// VISIBILITY CONTROLS
// ============================================================

show_skewness = input.bool(
     true,
     "Show Skewness"
)

show_skew_percentiles = input.bool(
     true,
     "Show Skewness Percentile Levels",
     tooltip = "Displays adaptive percentile levels for skewness to help identify asymmetric returns conditions."
)

show_kurtosis = input.bool(
     true,
     "Show Kurtosis"
)

show_kurt_percentiles = input.bool(
     true,
     "Show Kurtosis Percentile Levels",
     tooltip = "Displays adaptive percentile levels for kurtosis to help identify extreme returns conditions."
)

legend_choice = input.string(
     "None",
     "Show Legend",
     options = ["None", "Skewness", "Kurtosis", "Market Condition"]
)

// ============================================================
// CORE DISTRIBUTIONAL ENGINE
// ============================================================

float returns = math.log(close / close[1])

// Rolling Central Moments
float mean_r   = ta.sma(returns, roll_len)
float variance = ta.sma(math.pow(returns - mean_r, 2), roll_len)
float m3       = ta.sma(math.pow(returns - mean_r, 3), roll_len)
float m4       = ta.sma(math.pow(returns - mean_r, 4), roll_len)

// Raw Skewness / Excess Kurtosis
float skew_raw =
     variance > 0
     ? m3 / math.pow(variance, 1.5)
     : 0.0

float kurt_raw =
     variance > 0
     ? m4 / math.pow(variance, 2.0) - 3.0
     : 0.0

// EMA Smoothing
float skew_smooth = ta.ema(skew_raw, smooth_len)
float kurt_smooth = ta.ema(kurt_raw, smooth_len)

// ============================================================
// PERCENTILE RANK ENGINE
// ============================================================


float skew_pct =
     bar_index >= roll_len
     ? ta.percentrank(skew_smooth, pct_len)
     : 50.0

float kurt_pct =
     bar_index >= roll_len
     ? ta.percentrank(kurt_smooth, pct_len)
     : 50.0

// ============================================================
// COLOR ENGINES
// ============================================================

color skew_color =
     skew_pct >= 90 ? color.new(#00ff66, 0) :
     skew_pct >= 65 ? color.new(#2ecc71, 0) :
     skew_pct >= 35 ? color.new(#cccccc, 20) :
     skew_pct >= 10 ? color.new(#ff7675, 0) :
     color.new(#ff003c, 0)

color kurt_color =
     kurt_pct >= 90 ? color.new(#00d2ff, 40) :
     kurt_pct >= 75 ? color.new(#5dade2, 40) :
     color.new(#7f8c8d, 75)

// ============================================================
// MAIN VISUAL PLOTS
// ============================================================

plot(
     show_skewness ? skew_smooth : na,
     "Skewness Line",
     color = skew_color,
     linewidth = 2
)

plot(
     show_kurtosis ? kurt_smooth : na,
     "Kurtosis Area",
     color = kurt_color,
     linewidth = 3,
     style = plot.style_area
)

hline(
     0,
     "Zero Equilibrium Axis",
     color = color.new(color.white, 70),
     linestyle = hline.style_dashed,
     linewidth = 1
)

// ============================================================
// PERCENTILE LEVELS
// ============================================================

// Skewness Percentile Levels
float guide_p10_skew =
     ta.percentile_nearest_rank(skew_smooth, pct_len, 10)

float guide_p35_skew =
     ta.percentile_nearest_rank(skew_smooth, pct_len, 35)

float guide_p65_skew =
     ta.percentile_nearest_rank(skew_smooth, pct_len, 65)

float guide_p90_skew =
     ta.percentile_nearest_rank(skew_smooth, pct_len, 90)

// Kurtosis Percentile Levels
float guide_p75_kurt =
     ta.percentile_nearest_rank(kurt_smooth, pct_len, 75)

float guide_p90_kurt =
     ta.percentile_nearest_rank(kurt_smooth, pct_len, 90)

// ============================================================
// CONDITIONAL PERCENTILE PLOTS
// ============================================================

// Skewness Percentile Levels
plot(
     show_skew_percentiles ? guide_p90_skew : na,
     "Skew 90th Percentile",
     color = color.new(#27ae60, 75)
)

plot(
     show_skew_percentiles ? guide_p65_skew : na,
     "Skew 65th Percentile",
     color = color.new(#2ecc71, 80)
)

plot(
     show_skew_percentiles ? guide_p35_skew : na,
     "Skew 35th Percentile",
     color = color.new(#ff7675, 80)
)

plot(
     show_skew_percentiles ? guide_p10_skew : na,
     "Skew 10th Percentile",
     color = color.new(#ff003c, 75)
)

// Kurtosis Percentile Levels
plot(
     show_kurt_percentiles ? guide_p90_kurt : na,
     "Kurt 90th Percentile",
     color = color.new(#00d2ff, 75)
)

plot(
     show_kurt_percentiles ? guide_p75_kurt : na,
     "Kurt 75th Percentile",
     color = color.new(#5dade2, 75)
)

// ============================================================
// REGIME STATE LOGIC
// ============================================================

bool skew_extreme_pos = skew_pct >= 90
bool skew_positive    = skew_pct >= 65 and skew_pct < 90
bool skew_neutral     = skew_pct >= 35 and skew_pct < 65
bool skew_negative    = skew_pct >= 10 and skew_pct < 35
bool skew_extreme_neg = skew_pct < 10

bool kurt_elevated = kurt_pct >= 75 and kurt_pct < 90
bool kurt_extreme  = kurt_pct >= 90

// ============================================================
// BACKGROUND REGIME MAPPING
// ============================================================


color bg_color =
     skew_extreme_pos and kurt_extreme              ? color.new(#00ff66, 88) :
     skew_positive    and (kurt_elevated or kurt_extreme) ? color.new(#2ecc71, 90) :
     skew_extreme_neg and kurt_extreme              ? color.new(#ff003c, 88) :
     skew_negative    and (kurt_elevated or kurt_extreme) ? color.new(#e74c3c, 90) :
     skew_neutral     and (kurt_elevated or kurt_extreme) ? color.new(#3498db, 90) :
     na

bgcolor(bg_color)

// ============================================================
// LEGEND ENGINE
// ============================================================

var table legend_tbl = na

if barstate.islast and legend_choice != "None"

    legend_tbl := table.new(
         position = position.middle_right,
         columns = 2,
         rows = 7,
         bgcolor = color.new(#1c1c26, 10),
         border_color = color.new(color.white, 80),
         border_width = 1,
         frame_color = color.new(color.white, 60),
         frame_width = 1
     )

    // ========================================================
    // SKEWNESS LEGEND
    // ========================================================

    if legend_choice == "Skewness"

        table.cell(legend_tbl, 0, 0, "ROLLING SKEWNESS STATE", text_color = color.white, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 0, "Percentile", text_color = color.new(color.white, 50), text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 1, "▬ Extreme Positive Asymmetry", text_color = #00ff66, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 1, ">= 90th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 2, "▬ Positive Asymmetry", text_color = #2ecc71, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 2, "65-90th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 3, "▬ Baseline Symmetry", text_color = #b2babb, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 3, "35-65th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 4, "▬ Negative Asymmetry", text_color = #ff7675, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 4, "10-35th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 5, "▬ Extreme Negative Asymmetry", text_color = #ff003c, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 5, "< 10th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

    // ========================================================
    // KURTOSIS LEGEND
    // ========================================================

    if legend_choice == "Kurtosis"

        table.cell(legend_tbl, 0, 0, "ROLLING KURTOSIS STATE", text_color = color.white, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 0, "Percentile", text_color = color.new(color.white, 50), text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 1, "█ Extreme Expansion", text_color = #00d2ff, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 1, ">= 90th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 2, "█ Elevated Expansion", text_color = #5dade2, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 2, "75-90th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 3, "█ Baseline Conditions", text_color = #a6b9bb, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 3, "< 75th", text_color = color.white, text_size = size.small, text_halign = text.align_center)

    // ========================================================
    // MARKET CONDITION LEGEND
    // ========================================================

    if legend_choice == "Market Condition"

        table.cell(legend_tbl, 0, 0, "MARKET CONDITION", text_color = color.white, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 0, "Percentile", text_color = color.new(color.white, 50), text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 1, "██ Positive Returns Dominant", text_color = #00ff66, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 1, "Skew >= 90 & Kurt >= 90", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 2, "██ Positive Returns More Frequent", text_color = #2ecc71, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 2, "Skew 65-90 & Kurt >= 75", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 3, "██ Neutral Expansion", text_color = #3498db, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 3, "Skew 35-65 & Kurt >= 75", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 4, "██ Negative Returns More Frequent", text_color = #ff7675, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 4, "Skew 10-35 & Kurt >= 75", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 5, "██ Negative Returns Dominant", text_color = #ff003c, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 5, "Skew < 10 & Kurt >= 90", text_color = color.white, text_size = size.small, text_halign = text.align_center)

        table.cell(legend_tbl, 0, 6, "██ Baseline Conditions", text_color = color.white, text_size = size.small, text_halign = text.align_left)
        table.cell(legend_tbl, 1, 6, "Kurt < 75", text_color = color.white, text_size = size.small, text_halign = text.align_center)
````
