# Divergence Strength Analyzer-John Hayden

- url: https://www.tradingview.com/script/qgl8rkyK-Divergence-Strength-Analyzer-John-Hayden/
- type: indicator
- pine_id: PUB;193f8d0e553c452896bbdb7bf767ca49
- version: 7.0

## Description

[b]Hayden Momentum Regimes & Time-Decay Divergence Analyzer[/b]

Overview:

Most retail traders treat the Relative Strength Index (RSI) as a basic overbought/oversold oscillator—shorting above 70 and buying below 30. In *"RSI: The Complete Guide," John Hayden* completely flips this flawed conventional wisdom on its head. Hayden demonstrates that extreme RSI levels actually represent high-velocity structural momentum expansions rather than impending reversals.

This open-source Pine Script tool here maps Hayden's proprietary market regimes, isolates institutional *Hidden and Normal Divergences, and introduces a strict **Time-Decay Strength Matrix* to filter out low-velocity market noise.

 [b]Core Mechanics[/b]

1. The High-Velocity Regime Speedometer
Instead of looking for immediate trend reversals when the RSI enters extreme territories, this indicator uses these levels to categorize the macro trend structure:

  *The Bull Market Regime (40/80 Range):* Initiated when the RSI breaks out above 70. Once confirmed, the RSI establishes a firm support floor around the *40* line during pullbacks, indicating heavy institutional backing.

  *The Bear Market Regime (20/60 Range):* Initiated when the RSI drops below 30. Relief rallies consistently stall out and find a ceiling around the *60* line, proving persistent distribution.

 2. The Power of Hayden's Hidden Divergence

While normal divergence frequently acts as a near-term counter-trend trap, Hayden highlights *Hidden Divergence* as the ultimate trend-continuation footprint.

 * In a confirmed bullish regime, the price prints a structurally higher low while the RSI registers a deeply oversold lower low. This discrepancy indicates that while emotional momentum has fully cooled off, structural buying pressure remains completely intact, creating a coiled spring ready to unleash the next "superfast" leg up.

3. The Time-Decay Strength Matrix (%)

A primary reason traders fail with standard divergence indicators is that they fail to account for the element of time. Hayden explicitly teaches that the validity of a momentum discrepancy decays the longer it takes to form.

This script mathematically calculates the precise distance between structural peaks or troughs and scores the setup using Hayden’s time-based parameters:

 * 🚀 *100% Strength (Ultra Condensed):* \le 4 bars between pivots. Highly explosive immediate velocity.
 * 📈 *75% Strength (Standard Strong):* 5 to 8 bars between pivots. Highly reliable trend-joiner.
 * ⚖️ *50% Strength (Moderate):* 9 to 12 bars between pivots. Average momentum reliability.
 * ❌ *0% Strength (Decayed/Filtered):* > 16 bars between pivots. The setup is completely ignored and filtered off your chart to prevent slow, sideways chops.

 How to Trade This Script

 1. *Scan the Regime Background:* Look for a faint green chart overlay to confirm you are inside   a valid Hayden Bull Regime.

 2. *Locate the Footprint:* Wait for the indicator to map an *MDRP Hidden Bull* or *Normal Bull* label.

 3. *Verify the Strength %:* Prioritize signals showcasing *75% to 100% Strength*. This ensures you are striking right at the inflection point of structural trend acceleration.

 4. *Invalidation:* If the macro RSI breaks out of its trend bounds (e.g., dropping below the 40-floor buffer in a bull market), the regime shifts to neutral, and current long-bias expectations are discarded.

[b]Features[/b]

  *Pure Price & Momentum Geometry:* Zero volume filters are utilized, making this script ideal for clean execution across both highly liquid indexes and choppy small-cap resource scripts.
 
 *Dynamic Chart Labels:* Eliminates chart confusion by printing the exact divergence type alongside its dynamic strength rating directly on the key pivot bar.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pridarasx
//@version=6
indicator("Hayden Divergence Strength Analyzer - [Pridarasx]", overlay=true)

// --- Inputs ---
rsiLength   = input.int(14, title="RSI Length", group="RSI Settings")
rsiSource   = input.source(close, title="RSI Source", group="RSI Settings")
pivotLookbk = input.int(4, title="Pivot Window (Left/Right)", group="Divergence Geometry")
showLines   = input.bool(true, title="Draw Divergence Lines", group="Visual Styling")

// --- Hayden RSI Calculations & Regimes ---
rsiVal = ta.rsi(rsiSource, rsiLength)

var bool isBullRegime = false
if rsiVal > 70
    isBullRegime := true
if rsiVal < 40
    isBullRegime := false
//Visual refresh
//Visual 
//visual refresh
//Visual Refresh
// --- Identify Pivots ---
rsiLowIdx  = ta.pivotlow(rsiVal, pivotLookbk, pivotLookbk)
rsiHighIdx = ta.pivothigh(rsiVal, pivotLookbk, pivotLookbk)

// Persistent Structural Memory Arrays for Troughs (Lows)
var float rsiT1 = na, var float rsiT2 = na
var float prcL1 = na, var float prcL2 = na
var int   barL1 = na, var int   barL2 = na

if not na(rsiLowIdx)
    rsiT1 := rsiT2, prcL1 := prcL2, barL1 := barL2
    rsiT2 := rsiVal[pivotLookbk]
    prcL2 := low[pivotLookbk]
    barL2 := bar_index - pivotLookbk

// Persistent Structural Memory Arrays for Peaks (Highs)
var float rsiP1 = na, var float rsiP2 = na
var float prcH1 = na, var float prcH2 = na
var int   barH1 = na, var int   barH2 = na

if not na(rsiHighIdx)
    rsiP1 := rsiP2, prcH1 := prcH2, barH1 := barH2
    rsiP2 := rsiVal[pivotLookbk]
    prcH2 := high[pivotLookbk]
    barH2 := bar_index - pivotLookbk

// --- ORIGINAL Time-Based Strength Matrix ---
getStrengthPercent(int barDistance) =>
    float strength = 0.0
    if barDistance <= 4
        strength := 100.0
    else if barDistance <= 8
        strength := 75.0
    else if barDistance <= 12
        strength := 50.0
    else if barDistance <= 16
        strength := 25.0
    else
        strength := 0.0
    strength

// --- Divergence Logic Gate Engine ---
bool normalBull = false
bool hiddenBull = false
bool normalBear = false
float divStrength = na

// Bullish Scenarios (Looking at Lows/Troughs)
if ta.change(barL2) != 0 and not na(barL1)
    int elapsedLows = barL2 - barL1
    divStrength := getStrengthPercent(elapsedLows)
    
    if divStrength > 0 // Kept the filter to completely hide 0% entries
        if prcL2 < prcL1 and rsiT2 > rsiT1
            normalBull := true
        else if prcL2 > prcL1 and rsiT2 < rsiT1 and isBullRegime
            hiddenBull := true

// Bearish Scenarios (Looking at Highs/Peaks)
if ta.change(barH2) != 0 and not na(barH1)
    int elapsedHighs = barH2 - barH1
    divStrength := getStrengthPercent(elapsedHighs)
    
    if divStrength > 0 // Kept the filter to completely hide 0% entries
        if prcH2 > prcH1 and rsiP2 < rsiP1
            normalBear := true

// --- Dynamic Label & Line Generation ---
if normalBull
    label.new(x=barL2, y=low[pivotLookbk], text="Normal Bull\n" + str.tostring(divStrength) + "% Str", 
              color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.small)
    if showLines
        line.new(x1=barL1, y1=prcL1, x2=barL2, y2=prcL2, color=color.blue, width=2, style=line.style_solid)

if hiddenBull
    label.new(x=barL2, y=low[pivotLookbk], text="HIDDEN BULL\n" + str.tostring(divStrength) + "% Str", 
              color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)
    if showLines
        line.new(x1=barL1, y1=prcL1, x2=barL2, y2=prcL2, color=color.green, width=2, style=line.style_dashed)

if normalBear
    label.new(x=barH2, y=high[pivotLookbk], text="Bear Div\n" + str.tostring(divStrength) + "% Str", 
              color=color.maroon, textcolor=color.white, style=label.style_label_down, size=size.small)
    if showLines
        line.new(x1=barH1, y1=prcH1, x2=barH2, y2=prcH2, color=color.maroon, width=2, style=line.style_solid)

// Background Structural Regime Overlay
bgcolor(isBullRegime ? color.new(color.green, 97) : color.new(color.red, 97))
````
