# Supply-Demand Imbalance Prevalence (SDI-P)

- url: https://www.tradingview.com/script/FPeXlyz5-Supply-Demand-Imbalance-Prevalence-SDI-P/
- type: indicator
- pine_id: PUB;b793efbe72fd45ca96d7c92ae55cde4b
- version: 2.0

## Description

[b]Supply-Demand Imbalance Prevalence (SDI-P)[/b]

[b]Overview[/b]

Most indicators focus on candle closes or volume in isolation. SDI-P (Supply-Demand Imbalance Prevalence) looks deeper into [i]intra-bar price dynamics[/i] by analyzing buying and selling pressure. It quantifies which side is more successful at pushing the price away from the extremes, then calculates how consistently that dominance occurs over a historical window.

[b]The Core Logic[/b]

For every bar, the indicator calculates the [i]Supply Pressure (S)[/i]—the distance from the High to the Close—and the [i]Demand Pressure (B)[/i]—the distance from the Close to the Low. The indicator, then calculates the difference [i]D[/i] between the two:
[list]
[*] D = B - S
[*] D > 0$: Buying pressure exceeded selling pressure.
[*] D < 0$: Selling pressure exceeded buying pressure.
[/list]
Based on the above differences, the indicator calculates the percentage of bars where buying pressure prevailed over the selling pressure over a lookback window of a user-specified size. A number of different weighting schemes can be applied during this computation as described below. 

[b]Key Features[/b]
[list]
[*] Dual Weighting Modes: Choose [i]Uniform[/i] for a raw win-rate or [i]SDI Weighted[/i] (default) to give more "voting power" to bars with higher supply-demand imbalances.
[*] Volume Weighting (Toggleable): Factor in capital commitment. A "win" on high volume is treated as more significant than a win on thin liquidity.
[*] Quantile Normalization (The Purple Line): This shows you how the current buyer/seller prevalence compares to the last [i]Q[/i] bars. A reading above 80 means the current intensity is in the top 20% of historical readings. This line is displayed only when there are at least [i]Q[/i] bars of history available.
[/list]

[b]How to Read the Lines[/b]
[list]
[*] Prevalence (Gray Line): The raw, bar-by-bar (weighted) percentage. High volatility.
[*] SMA of Prevalence (Teal/Orange Line): The smoothed trend of the "win rate." This is your primary directional bias.
[*] Smoothed Quantile (Purple Line): The "rarity" of the current movement. Use this to identify exhaustion points (extremes) or breakout confirmation.
[/list]

[b]Multi-Timeframe Strategy: Micro Signals vs. Macro Context[/b]

To get the most out of SDI-P, it should be viewed as a fractal tool. The "prevalence" of demand on a Weekly chart means something very different than on a daily chart.

[b]1. Finer Timescales (Daily / Intraday): The Early Warning System[/b]

Use lower timeframes to spot **incipient trend shifts** before they are obvious in the price structure.

Furthermore, consider the behavior of [i]SDI-P[/i] in conjunction with price trajectory for detecting. This is often effective for detecting divergences before price trajectory shifts. For example: If price is continuing trending higher, but [i]SDI-P[/i] is declining and making lower highs, it is a strong indicator of buyers' exhaustion and a warning of an upcoming price decline.
 
[b]2. Coarser Timescales (Weekly / Monthly): The Strategic Anchor[/b]

Higher timeframes provide the [i]structural context[/i] and serve to confirm durability of longer-term trends.
[list]
[*] Confirming Durable Changes: For example, a "durable" trend change is confirmed when the Weekly [i]SDI-P[/i] crosses the 50-median and holds. This filters out the "noise" of daily volatility and identifies shifts in institutional commitment.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2026 thermowild

//@version=6
indicator("Supply-Demand Imbalance Prevalence", shorttitle="SDI-P", overlay=false, precision=0)

// --- Inputs ---
lWindow         = input.int(8, title="Lookback Window", minval=1)
sWindow         = input.int(3, title="Prevalence Smoothing Window", minval=1)
qWindow         = input.int(208, title="Quantile Window", minval=2)
qsWindow        = input.int(3, title="Quantile Smoothing Window", minval=1)
sdiScale        = input.string("Absolute", title="SDI Scale", options=["Relative", "Absolute"])
weightingType   = input.string("True Range", title="Weighting Type", options=["Uniform", "True Range"])
volumeWeighting = input.bool(true, title="Volume Weighting")

// --- Logic ---

// 1. Compute the Difference D and True Range
sVal = high - close
bVal = close - low
float dVal = bVal - sVal
trVal = ta.tr(true)

// Handle Scaling
if sdiScale == "Relative"
    dVal := dVal / close

// 2. Compute Prevalence (P)
float prevalence = 0.0
float sumPos = 0.0
float sumTotal = 0.0

for i = 0 to lWindow - 1
    float val = dVal[i]
    float w   = volumeWeighting ? volume[i] : 1.0
    
    if weightingType == "Uniform"
        // Every positive bar counts as 100 * weight
        // Every negative bar counts as 0, but total weight is still accumulated
        sumTotal += w
        if val > 0
            sumPos += 100.0 * w
        // Note: we divide by sumTotal at the end to get the percentage
    else
        // True Range Weighted: Weighting by the true range of the bar * volume weight
        float tr_weight = trVal[i] * w
        sumTotal += tr_weight
        if val > 0
            sumPos += tr_weight

// Final Prevalence Calculation
if weightingType == "Uniform"
    prevalence := (sumTotal != 0 ? sumPos / sumTotal : 0.0)
else
    // For True Range: (Sum of Weighted Positive / Sum of Weighted Total) * 100
    prevalence := (sumTotal != 0 ? (sumPos / sumTotal) * 100.0 : 0.0)

// 3. Compute SMA of Prevalence
prevalenceSMA = ta.sma(prevalence, sWindow)

// 4. Compute Quantile of Prevalence over window Q
prevalenceQuantileRaw = ta.percentrank(prevalence, qWindow)

// 5. Apply Smoothing to the Quantile
prevalenceQuantileSmoothed = ta.sma(prevalenceQuantileRaw, qsWindow)

// --- Visualization ---

// Plot 1: Prevalence (The raw percentage)
plot(prevalence, title="Prevalence (P)", color=color.new(color.gray, 60), linewidth=1)

// Plot 2: SMA of Prevalence
smaColor = prevalenceSMA > 50 ? color.teal : color.orange
plot(prevalenceSMA, title="SMA of Prevalence", color=smaColor, linewidth=2)

// Plot 3: Smoothed Quantile of Prevalence - Purple line
plot(prevalenceQuantileSmoothed, title="Smoothed Quantile", color=color.purple, linewidth=2)

// --- Reference Levels ---
hline(50, "Median", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(80, "High Prevalence", color=color.new(color.green, 80), linestyle=hline.style_dotted)
hline(20, "Low Prevalence", color=color.new(color.red, 80), linestyle=hline.style_dotted)
````
