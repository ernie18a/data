# NLMS Volatility Trail [BackQuant]

- url: https://www.tradingview.com/script/UUXdk60N-NLMS-Volatility-Trail-BackQuant/
- type: indicator
- pine_id: PUB;ac5f8a3ff9b64418a8e37f9ca2d229ab
- version: 1.0

## Description

[b]NLMS Volatility Trail [BackQuant][/b]

[b]Overview[/b]
NLMS Volatility Trail is an adaptive trend-following overlay that combines a machine-learning style adaptive filter with a volatility-based trailing structure. It is built around the [b]Normalized Least Mean Squares (NLMS)[/b] algorithm, then converts that adaptive estimate into an ATR-based trailing line designed to follow directional regimes while filtering out minor noise.

The indicator has two core layers:
[list]
[*]An [b]NLMS adaptive filter[/b], which learns a dynamic price estimate from prior bars.
[*]An [b]ATR volatility trail[/b], which converts that learned estimate into a step-like directional trailing structure.
[/list]

The goal is to produce a trend line that is more adaptive than a traditional moving average and more structured than a raw adaptive filter. The NLMS engine learns the underlying price path, while the ATR trail adds volatility-aware confirmation so trend shifts only occur when the adaptive estimate moves meaningfully.

[b]Core idea[/b]
Most trend filters use fixed smoothing rules. An EMA, SMA, WMA, or HMA always applies the same mathematical weighting scheme regardless of whether the market is trending, ranging, expanding, or compressing.

NLMS is different. It continuously updates its internal weights based on prediction error.

This means the filter is not just averaging price. It is constantly asking:
[list]
[*]How well did the previous weighting structure predict the current bar?
[*]How large was the error?
[*]How should the weights adjust to reduce future error?
[/list]

The second layer then takes that adaptive estimate and applies an ATR-based trailing mechanism around it. This creates a volatility-adjusted trend trail that reacts to confirmed shifts while ignoring smaller movements that do not exceed the range structure.

[b]What NLMS is[/b]
NLMS stands for [b]Normalized Least Mean Squares[/b]. It is an adaptive filtering algorithm from digital signal processing. It is closely related to the original LMS algorithm developed by Bernard Widrow and Ted Hoff, which became one of the foundational online learning methods used in adaptive systems.

Adaptive filters have historically been used in:
[list]
[*]Noise cancellation
[*]Echo cancellation
[*]Telecommunications
[*]Radar and sonar processing
[*]Signal prediction
[*]Control systems
[/list]

The basic purpose is to estimate or predict a signal while continuously adapting to changing conditions.

In trading terms, this indicator uses NLMS to build a learned estimate of price from prior bars.

[b]How the NLMS filter works[/b]
The filter uses a set of historical inputs called [b]taps[/b].

If taps = 72, the model uses the previous 72 bars:
[list]
[*]source[1]
[*]source[2]
[*]source[3]
[*]...
[*]source[72]
[/list]

Each tap has a learned weight.

The prediction is calculated as:
[list]
[*]prediction = w1 × source[1] + w2 × source[2] + ... + wM × source[M]
[/list]

The filter then compares the prediction to the actual current source:
[list]
[*]error = source - prediction
[/list]

That error drives the weight update.

If the prediction was poor, the weights adjust more.
If the prediction was accurate, the weights adjust less.

This creates an adaptive estimate that evolves with market behavior.

[b]Why it is normalized[/b]
The normal LMS algorithm updates weights based on the raw input and prediction error. The issue is that if the input signal becomes large or volatile, updates can become unstable.

NLMS solves this by dividing the update by the input power:
[list]
[*]power = sum(source[i]²)
[/list]

The update becomes:
[list]
[*]w = w + (μ / (ε + power)) × error × input
[/list]

This normalization makes the learning process more stable across different volatility environments.

When the input power is high:
[list]
[*]Updates are scaled down.
[*]The filter avoids overreacting.
[/list]

When the input power is low:
[list]
[*]Updates are allowed to remain meaningful.
[/list]

This is why NLMS is better suited to markets than a basic adaptive filter. Markets constantly shift between quiet and volatile regimes.

[b]Weight initialization[/b]
The script initializes all weights equally:
[list]
[*]weight = 1 / M
[/list]

This means the filter starts with an SMA-like prior. Before learning begins, every historical bar contributes equally.

Over time, the filter adapts away from that equal-weight baseline and learns its own weighting structure.

[b]Inputs that control the NLMS engine[/b]

[b]Filter Taps (M)[/b]
Controls how many historical bars the model learns from.

Higher taps:
[list]
[*]More memory
[*]Smoother adaptive estimate
[*]Slower response to regime change
[/list]

Lower taps:
[list]
[*]Less memory
[*]Faster reaction
[*]More noise sensitivity
[/list]

[b]Step Size (μ)[/b]
Controls the learning rate.

Lower μ:
[list]
[*]Slower learning
[*]Smoother output
[*]More stable
[/list]

Higher μ:
[list]
[*]Faster learning
[*]More responsive
[*]Can become noisy if too aggressive
[/list]

This is one of the most important settings. It controls how quickly the model changes its internal weights.

[b]Regularization (ε)[/b]
Prevents instability when input power is very low.

It acts as a stabilizer in the denominator:
[list]
[*]ε + power
[/list]

Higher values make updates more conservative.
Lower values allow stronger adaptation but can become less stable in quiet conditions.

[b]From adaptive filter to volatility trail[/b]
The raw NLMS output is not plotted directly as the main trend line. Instead, it is passed into a volatility trailing structure.

The script builds an ATR band around the NLMS estimate:
[list]
[*]Upper band = NLMS output + ATR × factor
[*]Lower band = NLMS output - ATR × factor
[/list]

Then it creates a trailing value that only updates when the NLMS band structure forces it to move.

This creates a trail that behaves similarly to a volatility stop, but the center is not price or hl2. It is the [b]learned NLMS estimate[/b].

[b]ATR volatility trail logic[/b]
The trail starts from the NLMS output, then carries forward its previous value:
[list]
[*]nlmsAtr := previous nlmsAtr
[/list]

Then:
[list]
[*]If lower band rises above the trail, the trail moves up.
[*]If upper band falls below the trail, the trail moves down.
[/list]

This creates a directional trailing structure:
[list]
[*]In bullish regimes, the trail ratchets upward.
[*]In bearish regimes, the trail ratchets downward.
[/list]

It filters out small movements because price must move enough relative to ATR and the adaptive estimate to change the trail direction.

[b]Why combine NLMS with ATR[/b]
NLMS alone gives an adaptive estimate, but it can still wiggle as the model learns.

ATR alone gives volatility structure, but it is usually tied to raw price and fixed smoothing.

Combining them gives:
[list]
[*]Adaptive intelligence from NLMS.
[*]Volatility confirmation from ATR.
[*]Cleaner trend state transitions.
[*]Less dependence on fixed moving-average assumptions.
[/list]

The NLMS model learns the underlying price behavior, while ATR decides whether movement is large enough to matter.

[b]Trend direction[/b]
Trend flips are detected from the trail itself:
[list]
[*]Bullish when nlmsAtr crosses above its previous value.
[*]Bearish when nlmsAtr crosses below its previous value.
[/list]

This means signals are generated when the volatility trail changes direction, not when price simply crosses the line.

That is important because:
[list]
[*]The trail must structurally move.
[*]The signal is tied to confirmed trail direction.
[*]Noise around the line does not automatically create a flip.
[/list]

[b]Visual design[/b]
The indicator includes several visual layers.

[b]Main trail line[/b]
The central plotted line is the NLMS ATR trail. It changes color based on the current trend state:
[list]
[*]Green for bullish trail direction.
[*]Red for bearish trail direction.
[*]Gray before a trend state is established.
[/list]

[b]Gradient fill[/b]
The script fills the space between price and the trail:
[list]
[*]If price is above the trail, bullish fill is shown.
[*]If price is below the trail, bearish fill is shown.
[/list]

The fill is stronger near the trail and fades toward price, making the trail feel like the active structural reference.

[b]Trail glow[/b]
A soft glow is drawn around the trail using a small ATR offset:
[list]
[*]glow = ATR(14) × 0.06
[/list]

This highlights the trail visually without cluttering the chart.

[b]Trend candles[/b]
Candles are colored by trend state:
[list]
[*]Bullish trend = bullish candles.
[*]Bearish trend = bearish candles.
[/list]

This allows the script to function as a complete regime overlay.

[b]How to interpret the indicator[/b]

[b]Bullish state[/b]
A bullish state occurs when the NLMS volatility trail turns upward.

This suggests:
[list]
[*]The adaptive filter is shifting higher.
[*]The ATR trail has confirmed upward structure.
[*]Trend pressure has turned bullish.
[/list]

[b]Bearish state[/b]
A bearish state occurs when the NLMS volatility trail turns downward.

This suggests:
[list]
[*]The adaptive estimate is shifting lower.
[*]The volatility trail has confirmed downside structure.
[*]Trend pressure has turned bearish.
[/list]

[b]Price above the trail[/b]
Generally indicates bullish structure.

[b]Price below the trail[/b]
Generally indicates bearish structure.

But the most important signal is the direction of the trail itself, not every price touch.

[b]How to use it in practice[/b]

[b]1) Trend following[/b]
Use the trail direction as the primary bias:
[list]
[*]Favor longs when the trail is bullish.
[*]Favor shorts when the trail is bearish.
[/list]

[b]2) Dynamic support/resistance[/b]
The trail can act like a dynamic structural level:
[list]
[*]In uptrends, pullbacks toward the trail can act as support.
[*]In downtrends, rallies toward the trail can act as resistance.
[/list]

[b]3) Trade management[/b]
The trail can be used as:
[list]
[*]A trailing stop guide.
[*]A regime invalidation level.
[*]A trend continuation reference.
[/list]

[b]4) Regime filtering[/b]
Because the line adapts using NLMS and only flips when the volatility trail turns, it can be used to filter other entries:
[list]
[*]Take only long setups during bullish trail regimes.
[*]Take only short setups during bearish trail regimes.
[*]Avoid countertrend trades when the trail is strongly directional.
[/list]

[b]Difference from normal Supertrend or ATR trails[/b]
A normal ATR trail is usually built directly from price or hl2.

This indicator is different because the trail is built around an adaptive learned estimate.

That means:
[list]
[*]The centerline is not raw price.
[*]It is not a fixed moving average.
[*]It is a continuously learned NLMS estimate.
[/list]

So the trail has a different character:
[list]
[*]More adaptive than a standard moving average trail.
[*]More stable than a raw price-based ATR stop.
[*]More responsive to changing market structure than fixed filters.
[/list]

[b]Difference from the NLMS Adaptive Trend Filter[/b]
The NLMS Adaptive Trend Filter plots the learned estimate directly and reads trend from its slope.

NLMS Volatility Trail goes one step further:
[list]
[*]It uses the learned estimate as the base.
[*]Then wraps it with ATR structure.
[*]Then turns that into a trailing regime line.
[/list]

So this version is more structure-oriented and better suited for trailing trend behavior.

[b]Parameter tuning[/b]

[b]Taps[/b]
Use higher taps for smoother trend structure.
Use lower taps for faster adaptation.

[b]Step Size[/b]
Use lower step size for stability.
Use higher step size for responsiveness.

[b]Regularization[/b]
Use higher regularization when the filter feels unstable.
Use lower regularization when the filter is too sluggish.

[b]ATR Period[/b]
Controls volatility estimate:
[list]
[*]Shorter = more reactive trail.
[*]Longer = smoother trail.
[/list]

[b]ATR Factor[/b]
Controls band width:
[list]
[*]Higher factor = wider trail, fewer flips.
[*]Lower factor = tighter trail, more flips.
[/list]

[b]Strengths[/b]
[list]
[*]Combines adaptive filtering with volatility trailing logic.
[*]Learns from market structure instead of using fixed weights.
[*]Uses ATR to reduce noise and confirm meaningful movement.
[*]Good for trend following and trailing stop frameworks.
[*]Visually clean with gradient fill and candle coloring.
[/list]

[b]Limitations[/b]
[list]
[*]Still reactive, not predictive.
[*]Can lag during violent reversals.
[*]High learning rates may create noise.
[*]Low ATR factors may cause whipsaws.
[*]Requires tuning for timeframe and asset volatility.
[/list]

[b]Summary[/b]
NLMS Volatility Trail combines an adaptive NLMS predictor with an ATR-based trailing structure. The NLMS layer continuously learns a dynamic estimate of price from historical bars, while the ATR trail converts that estimate into a cleaner directional regime line. This makes the indicator more adaptive than a traditional moving average and more structured than a raw adaptive filter. It is best used as a trend-following overlay, dynamic support/resistance guide, and volatility-aware trailing framework.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("NLMS Volatility Trail [BackQuant]", overlay=true)

// Group Names
const string g1 = "NLMS Filter"
const string g2 = "ATR Calculation Settings"
const string plt = "Plotting Settings"

// Inputs
float src    = input.source(close, "Source", group = g1)
int   taps   = input.int(72, "Filter Taps (M)", minval = 2, maxval = 200, group = g1, tooltip = "Number of past bars (learned weights). More taps = more memory / smoother.")
float mu     = input.float(0.195, "Step Size (μ)", minval = 0.001, maxval = 1.50, step = 0.001, group = g1, tooltip = "Learning rate (gradient step). Low keeps weights diffuse / smooth. High = reactive but noisy.")
float eps    = input.float(0.6, "Regularization (ε)", minval = 0.0, step = 0.1, group = g1, tooltip = "Prevents divide-by-zero when input power is tiny.")

int periodAtr = input.int(14, "Period")
float factorAtr = input.float(1.7, "Factor", step = 0.01)

color longCol = input.color(#00ff00, "Long Color", group=plt)
color shortCol = input.color(#ff0000, "Short Color", group=plt)
int lineW = input.int(3, "Line Width", group=plt)
bool showFill = input.bool(true, "Gradient Fill", group=plt)
bool showGlow = input.bool(true, "Trail Glow", group=plt)
bool paintBar = input.bool(true, "Color Bars", group=plt)

// NLMS Adaptive Filter
// Online Widrow-Hoff (Normalized Least Mean Squares) one-step linear predictor.
// Learns M tap weights via normalized gradient descent on squared prediction error.
nlms(float source, simple int M, float step, float reg) =>
    var array<float> w = array.new_float(M, 1.0 / M)   // init = equal-weight (SMA) prior
    float est = na
    if bar_index >= M
        // predict current bar from past M bars (no lookahead)
        float pred  = 0.0
        float power = 0.0
        for i = 0 to M - 1
            float xi = source[i + 1]
            pred  += array.get(w, i) * xi
            power += xi * xi
        float err = source - pred
        // NLMS update: w += (μ / (ε + ||x||²)) * e * x
        float k = step / (reg + power)
        for i = 0 to M - 1
            array.set(w, i, array.get(w, i) + k * err * source[i + 1])
        est := pred
    est

float raw = nlms(src, taps, mu, eps)


nlmsAtrWithBands(lookback, atrFactor)=>
    
    nlmsOut = raw

    atr = ta.atr(lookback)
    trueRange = atr * atrFactor 

    nlmsAtr = nlmsOut 
    nlmsAtr := nz(nlmsAtr[1], nlmsAtr)

    trueRangeUpper = nlmsOut + trueRange
    trueRangeLower  = nlmsOut - trueRange 

    if trueRangeLower > nlmsAtr 
        nlmsAtr := trueRangeLower
    if trueRangeUpper < nlmsAtr 
        nlmsAtr := trueRangeUpper
    nlmsAtr 

// Function Out
nlmsAtr = nlmsAtrWithBands(periodAtr, factorAtr)

nlmsAtrLong = ta.crossover(nlmsAtr, nlmsAtr[1])
nlmsAtrShort = ta.crossunder(nlmsAtr, nlmsAtr[1])

var color col = na
if nlmsAtrLong
    col:=longCol
else if nlmsAtrShort
    col:=shortCol 

// Trend direction
var int trendDir = 0
if nlmsAtrLong
    trendDir := 1
else if nlmsAtrShort
    trendDir := -1
color trendCol = trendDir == 1 ? longCol : trendDir == -1 ? shortCol : color.gray

// Hidden reference plots for the fills
pTrail = plot(nlmsAtr, "Trail Ref", display = display.none, editable = false)
pPrice = plot(close,   "Price Ref", display = display.none, editable = false)

// Gradient fill between trail and price — intense at the trail, fading toward price
fill(pPrice, pTrail, close > nlmsAtr ? close : nlmsAtr, close > nlmsAtr ? nlmsAtr : close,
     showFill and close > nlmsAtr ? color.new(longCol, 90) : na,
     showFill and close > nlmsAtr ? color.new(longCol, 20) : na, title = "Bull Fill")
fill(pPrice, pTrail, close < nlmsAtr ? nlmsAtr : close, close < nlmsAtr ? close : nlmsAtr,
     showFill and close < nlmsAtr ? color.new(shortCol, 20) : na,
     showFill and close < nlmsAtr ? color.new(shortCol, 90) : na, title = "Bear Fill")

// Soft glow around the trail
float glow = ta.atr(14) * 0.06
pGlowUp = plot(nlmsAtr - glow, "Glow Lower Ref", display = display.none, editable = false)
pGlowDn = plot(nlmsAtr + glow, "Glow Upper Ref", display = display.none, editable = false)
fill(pTrail, pGlowUp, showGlow ? color.new(trendCol, 55) : na, title = "Glow Lower")
fill(pTrail, pGlowDn, showGlow ? color.new(trendCol, 55) : na, title = "Glow Upper")

// Trend candles
plotcandle(open,high,low,close,"Trend Candles", trendCol, trendCol, true, bordercolor=trendCol)

plot(nlmsAtr, "NLMS ATR", color=col, linewidth=lineW)

// Alerts
alertcondition(nlmsAtrLong, "NLMS ATR Bullish", "NLMS ATR Trend turned bullish on {{ticker}}")
alertcondition(nlmsAtrShort, "NLMS ATR Bearish", "NLMS ATR Trend turned bearish on {{ticker}}")
````
