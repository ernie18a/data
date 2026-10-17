# KST Cross Switch

- url: https://www.tradingview.com/script/vztZrrkZ-KST-Cross-Switch/
- type: indicator
- pine_id: PUB;466168fc88874015bce19415af470df4
- version: 1.0

## Description

The Know Sure Thing (KST) oscillator is a powerful momentum indicator, but its constantly fluctuating lines can sometimes make it difficult to determine the definitive market state at a glance.

This script transforms the traditional KST indicator into a clean, 3-stage State Machine tracker. Instead of staring at curved lines, this indicator locks the current market condition into three absolute levels: 100 for Bullish, 0 for Bearish, and 50 for Neutral.

When a strong bullish crossover occurs, the indicator locks to 100 with a lime green background. When a bearish crossunder happens, it locks to 0 with a maroon red background.
The core feature of this script is the Neutral Zone Threshold. In choppy or consolidating markets, KST lines often cross back and forth repeatedly, causing false signals. To solve this, the script checks the absolute distance between the KST line and the Signal line. If they are too close and moving sideways within your defined threshold, the indicator automatically resets to 50 with a neutral yellow/grey background. This helps you avoid overtrading during low-volatility squeeze periods.

You can fully customize the four different Rate of Change (ROC) lengths and their moving averages, as well as the signal line length. The Neutral Zone Threshold can also be finely tuned depending on the asset and timeframe you are trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rikyu04
//@version=6
indicator(title="KST Cross Switch", format=format.price, precision=4, overlay=false)

// ===== 1. INPUTS =====
roclen1 = input.int(10, minval=1, title="ROC Length #1")
roclen2 = input.int(15, minval=1, title="ROC Length #2")
roclen3 = input.int(20, minval=1, title="ROC Length #3")
roclen4 = input.int(30, minval=1, title="ROC Length #4")
smalen1 = input.int(10, minval=1, title="SMA Length #1")
smalen2 = input.int(10, minval=1, title="SMA Length #2")
smalen3 = input.int(10, minval=1, title="SMA Length #3")
smalen4 = input.int(15, minval=1, title="SMA Length #4")
siglen  = input.int(9,  minval=1, title="Signal Line Length")

// Neutral zone threshold: If KST and Signal are closer than this value, the state resets to 50.
neutral_threshold = input.float(0.5, step=0.1, title="Neutral Zone Threshold", tooltip="If abs(KST - Signal) < this, state becomes 50.")

// ===== 2. CALCULATIONS =====
smaroc(roclen, smalen) => ta.sma(ta.roc(close, roclen), smalen)

kst = smaroc(roclen1, smalen1) + 2 * smaroc(roclen2, smalen2) + 3 * smaroc(roclen3, smalen3) + 4 * smaroc(roclen4, smalen4)
sig = ta.sma(kst, siglen)

// Cross detection
goldenCross = ta.crossover(kst, sig)
deathCross  = ta.crossunder(kst, sig)

// ===== 3. STATE MACHINE (WITH NEUTRAL ZONE) =====
var int kstState = 50  // Initial state starts at 50

if goldenCross
    // Strong Bullish Crossover -> Lock to 100
    kstState := 100
else if deathCross
    // Strong Bearish Crossunder -> Lock to 0
    kstState := 0
else
    // No active cross: Check if the lines are too close (ambiguous)
    diff = math.abs(kst - sig)
    if diff < neutral_threshold
        // Too close to call a direction -> Set to Neutral (50)
        kstState := 50
    // else: If diff is large enough, keep the previous state (100 or 0)

// ===== 4. RENDERING (SUB-PANE) =====
// Reference Grid Lines
hline(100, "Long Ceiling", color=color.new(#00ff08, 60), linestyle=hline.style_solid)
hline(50,  "Center Baseline", color=color.gray, linestyle=hline.style_dashed)
hline(0,   "Short Floor",  color=color.new(#ff0055, 60), linestyle=hline.style_solid)

// Main State Line (Lime for 100, Maroon for 0, Yellow for 50)
plot(kstState, "KST State Tracker", color=kstState == 100 ? color.lime : kstState == 0 ? color.maroon : color.yellow, linewidth=2)

// Background Fill (Green for Long, Red for Short, Grey for Neutral)
bgFillColor = kstState == 100 ? color.new(#00ff08, 93) : kstState == 0 ? color.new(#ff0055, 93) : color.new(#808080, 93)
var p1 = plot(kstState, display=display.none)
var p2 = plot(50, display=display.none)
fill(p1, p2, color=bgFillColor, title="KST State Fill")
````
