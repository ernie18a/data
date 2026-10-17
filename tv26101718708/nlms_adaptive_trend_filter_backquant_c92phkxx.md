# NLMS Adaptive Trend Filter [BackQuant]

- url: https://www.tradingview.com/script/C92phkXx-NLMS-Adaptive-Trend-Filter-BackQuant/
- type: indicator
- pine_id: PUB;da5619c9f9e8474fad31c07b38763fe5
- version: 1.0

## Description

[b]NLMS Adaptive Trend Filter [BackQuant][/b]

[b]Overview[/b]

The NLMS Adaptive Trend Filter is a machine learning inspired trend-following indicator built around one of the most important adaptive filtering algorithms in signal processing: the [b]Normalized Least Mean Squares (NLMS) filter[/b].

Unlike traditional moving averages that use fixed weighting schemes, the NLMS filter continuously learns from incoming market data and updates its internal coefficients in real time. Rather than assuming that price behavior remains constant, the filter attempts to adapt its structure as market conditions evolve.

This approach originates from the field of digital signal processing, where adaptive filters have been used for decades in applications such as:

• Telecommunications
• Radar systems
• Echo cancellation
• Noise reduction
• Speech processing
• Control systems
• Financial signal extraction

The goal of this indicator is to bring one of these adaptive filtering concepts into market analysis by creating a trend model that continually adjusts itself based on prediction error rather than relying on static averaging methods.

[b]Historical Background[/b]

The roots of the NLMS filter can be traced back to the work of Bernard Widrow and Ted Hoff in the late 1950s and early 1960s.

While working at Stanford University, they developed what became known as the:

[b]Least Mean Squares (LMS) Algorithm[/b]

The LMS algorithm was revolutionary because it provided a computationally simple method for training adaptive systems using gradient descent.

Rather than solving a complex optimization problem all at once, the LMS algorithm updates its weights incrementally after each observation.

The basic concept was:

1. Make a prediction.
2. Measure the prediction error.
3. Adjust the model slightly.
4. Repeat indefinitely.

This idea eventually became one of the foundational concepts behind modern machine learning and online optimization.

Many modern neural networks still rely on the same underlying principle:

[b]Error → Gradient → Weight Update[/b]
The LMS algorithm later evolved into several variants, one of the most important being:

[b]Normalized Least Mean Squares (NLMS)[/b]
NLMS improves stability by scaling weight updates according to the energy of the input signal.
This prevents learning rates from becoming too aggressive during high-volatility periods and too weak during low-volatility periods.
As a result, NLMS became one of the most widely used adaptive filtering algorithms in engineering.

[b]What Makes NLMS Different From Moving Averages?[/b]
Traditional moving averages use predetermined weights.

For example:

[b]Simple Moving Average (SMA)[/b]
Every observation receives equal weight.

Example:
20-period SMA
Each bar contributes:
1 / 20 = 5%
regardless of market conditions.

[b]Exponential Moving Average (EMA)[/b]
Recent observations receive more weight.
The weighting structure is fixed and never changes.

[b]Weighted Moving Average (WMA)[/b]
Uses linearly decreasing weights.
Again, the weighting scheme is fixed.
The problem is that markets do not operate under fixed conditions.
Volatility changes.
Trend persistence changes.
Noise levels change.
Market structure changes.
Yet traditional moving averages continue using the exact same weighting model.
NLMS takes a different approach.
Instead of assigning permanent weights, it learns them dynamically.
The filter constantly asks
"What weighting structure would have predicted the current market best?"
It then updates itself accordingly.

[b]The Core Idea Behind Adaptive Filters[/b]
Imagine trying to forecast today's price using the previous 20 bars.
A normal moving average assumes a fixed weighting pattern.
An adaptive filter attempts to learn the optimal weighting pattern.

At every bar:

• A prediction is generated.
• Actual price is observed.
• Prediction error is measured.
• Weights are adjusted.

The process repeats indefinitely.

Over time, the filter learns which historical observations are most useful and which are less important.

[b]Understanding Filter Taps[/b]
One of the most important concepts in adaptive filtering is the idea of:

[b]Taps[/b]
A tap is simply a historical observation used as an input.

If the indicator uses:

20 taps
it means:

[pine]Price[1]
Price[2]
Price[3]
...
Price[20][/pine]

are all being used to generate the prediction.

Each tap receives a learned weight.

Instead of:
Current Estimate =Average of past 20 bars

the filter becomes:

[pine]Current Estimate =
(w1 × Price[1]) +
(w2 × Price[2]) +
(w3 × Price[3])

...
(w20 × Price[20])
[/pine]

The weights are continuously adjusted through learning.

[b]How Prediction Works[/b]
The indicator attempts to estimate current price using previous observations.

Mathematically:
[pine]Prediction = Σ(weight × historical price)[/pine]

This prediction becomes the filter output.

If the prediction is accurate:
Weights change very little.

If the prediction is poor:
Weights adjust more aggressively.

This allows the model to gradually adapt to changing market conditions.

[b]Prediction Error[/b]
The engine measures:
[pine]Error = Actual Price − Predicted Price[/pine]
This error drives all learning.
Large error means:

The model is wrong.
Small error means:
The model is performing well.

The objective is to minimize prediction error over time.

[b]The LMS Learning Rule[/b]
The original LMS update rule is:
[pine]New Weight =Old Weight + Learning Rate × Error × Input[/pine]
This is effectively a form of gradient descent.
The filter moves its weights in the direction that reduces future prediction error.
This is conceptually identical to many machine learning optimization methods.

[b]Why Normalization Matters[/b]
The original LMS algorithm has a weakness.
When input values become very large:
Weight updates can become unstable.

This is particularly problematic in financial markets where volatility constantly changes.
NLMS solves this problem by normalizing updates according to signal energy.

Instead of:
Weight Update ∝ Error

it becomes:
Weight Update ∝ Error / Signal Power

This creates adaptive scaling.
When volatility expands:
Updates automatically shrink.
When volatility contracts:
Updates automatically expand.
This improves stability significantly.

[b]How the Indicator Uses NLMS[/b]
The script implements an online one-step predictor.

For every new bar:

1. Previous M bars are gathered.
2. Current price is predicted.
3. Prediction error is calculated.
4. Weight vector is updated.
5. New estimate becomes available.

This process occurs continuously as new data arrives.
Because no future data is used, the filter remains fully causal and suitable for live trading.

[b]Weight Initialization[/b]
Initially all weights are equal:

[pine]1 / M[/pine]

This effectively starts the model as a simple moving average.
Over time the filter learns a custom weighting structure based on market behavior.
The initial equal-weight state acts as a neutral prior.

[b]Step Size (μ)[/b]
The learning rate controls how aggressively the filter adapts.
Lower values:

• More stable
• Smoother output
• Slower adaptation

Higher values:

• Faster adaptation
• More responsiveness
• Greater noise sensitivity

Think of μ as controlling the intelligence speed of the model.
Small values make it conservative.
Large values make it reactive.

[b]Regularization (ε)[/b]
Regularization prevents division by very small values.

Without it:
Periods of extremely low signal power could create unstable updates.
Regularization improves numerical stability and robustness.
It acts as a safety mechanism for the learning process.

[b]Output Smoothing[/b]
After the NLMS estimate is generated, an optional EMA can be applied.
This smoothing is not part of the NLMS algorithm itself.
It exists purely for visual clarity.
The raw adaptive filter already contains the learning logic.
The smoothing stage simply reduces small fluctuations.
Setting smoothing to 1 effectively disables it.

[b]Trend Detection[/b]
Trend direction is derived from the slope of the adaptive filter.

Bullish:
NLMS Output > Previous Output

Bearish:
NLMS Output < Previous Output

This creates a directional state machine.
Unlike crossover systems, trend changes occur whenever the adaptive estimate changes slope.

[b]Bullish Flips[/b]
A bullish signal occurs when:
Trend changes from bearish to bullish.
This means the adaptive filter has transitioned from declining to rising.

[b]Bearish Flips[/b]
A bearish signal occurs when:
Trend changes from bullish to bearish.
This means the adaptive filter has transitioned from rising to falling.

[b]Visual Components[/b]
The indicator includes several visualization layers.

[b]Adaptive Filter Line[/b]
The main output of the NLMS model.
This represents the learned trend estimate.

[b]Gradient Fill[/b]
The space between price and filter is colorized.
Price Above Filter:
Bullish shading.

Price Below Filter:
Bearish shading.
This provides immediate visual context regarding trend alignment.

[b]Edge Glow[/b]
An ATR-based glow surrounds price.
This helps emphasize directional conditions while improving chart readability.

[b]Trend Candles[/b]
Candles can optionally inherit trend coloration.

Green:
Adaptive trend rising.

Red:
Adaptive trend falling.
This allows traders to visualize the model's directional state directly on price.

[b]How It Differs From Traditional Trend Filters[/b]
Most trend indicators answer:
"What is the average price?"

NLMS attempts to answer:
"What weighting structure best predicts current price?"
This distinction is extremely important.
The indicator is not simply smoothing price.
It is continuously learning how price behaves.
Traditional indicators use fixed mathematics.
NLMS uses adaptive mathematics.

[b]Strengths[/b]
• Self-adjusting weighting structure.
• Adapts to changing market conditions.
• Based on established signal-processing theory.
• Stable due to normalization.
• Less reliant on arbitrary moving-average formulas.
• Learns continuously.
• Fully causal and non-lookahead.

[b]Limitations[/b]
• Not a predictive model in the forecasting sense.
• Can still lag during major regime shifts.
• Excessively large learning rates may introduce noise.
• Small tap counts can become unstable.
• Large tap counts can become sluggish.

Like all adaptive systems, there is a tradeoff between responsiveness and stability.

[b]Best Use Cases[/b]
The NLMS Adaptive Trend Filter is particularly effective for:
• Trend identification.
• Regime classification.
• Dynamic support/resistance visualization.
• Adaptive trend following.
• Noise reduction.
• Signal confirmation.

[b]Summary[/b]
The NLMS Adaptive Trend Filter applies one of the most important adaptive algorithms in modern signal processing to financial markets. Rather than relying on fixed moving-average weights, it continuously learns from prediction error and updates its internal model in real time. Built upon the pioneering work of Widrow and Hoff, the indicator combines adaptive filtering, normalized gradient descent, and online learning principles into a practical trend-following tool that evolves alongside changing market conditions. The result is a trend model that is fundamentally different from traditional moving averages, not because it smooths price differently, but because it learns how to smooth price as new information arrives.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("NLMS Adaptive Trend Filter [BackQuant]", "NLMS Trend [BackQuant]", overlay = true)

// Inputs
const string g1 = "NLMS Filter"
const string g2 = "UI Settings"

float src    = input.source(close, "Source", group = g1)
int   taps   = input.int(20, "Filter Taps (M)", minval = 2, maxval = 200, group = g1, tooltip = "Number of past bars (learned weights). More taps = more memory / smoother.")
float mu     = input.float(0.02, "Step Size (μ)", minval = 0.001, maxval = 1.50, step = 0.001, group = g1, tooltip = "Learning rate (gradient step). Low keeps weights diffuse / smooth. High = reactive but noisy.")
float eps    = input.float(1.0, "Regularization (ε)", minval = 0.0, step = 0.1, group = g1, tooltip = "Prevents divide-by-zero when input power is tiny.")
int   smooth = input.int(5, "Output Smoothing", minval = 1, maxval = 50, group = g1, tooltip = "Cosmetic EMA on the NLMS output. NOT part of the NLMS math — just cleans the trend line. 1 = off.")

bool  showLine = input.bool(true, "Show Filter Line", group = g2)
bool  showFill = input.bool(true, "Gradient Fill", group = g2)
bool  paintBar = input.bool(true, "Color Candles", group = g2)
int   lineW    = input.int(3, "Line Width", minval = 1, maxval = 6, group = g2)
color longCol  = input.color(#00ff00, "Bullish", inline = "c", group = g2)
color shortCol = input.color(#ff0000, "Bearish", inline = "c", group = g2)

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
float lms = ta.ema(raw, smooth)

// Trend
var int trend = 0
if lms > lms[1]
    trend := 1
else if lms < lms[1]
    trend := -1

color trendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray
bool  bullFlip = trend == 1 and trend[1] == -1
bool  bearFlip = trend == -1 and trend[1] == 1

// Plots
pLine  = plot(showLine ? lms : na, "NLMS Filter", color = trendCol, linewidth = lineW)
pPrice = plot(close, "Price ref", display = display.none, editable = false)

// gradient fill between price and filter
fill(pPrice, pLine, close > lms ? close : lms, close > lms ? lms : close, showFill and close > lms ? color.new(longCol, 20) : na,  showFill and close > lms ? color.new(longCol, 92) : na,  title = "Bull Fill")
fill(pPrice, pLine, close < lms ? lms : close, close < lms ? close : lms, showFill and close < lms ? color.new(shortCol, 20) : na, showFill and close < lms ? color.new(shortCol, 92) : na, title = "Bear Fill")

// edge glow
float glow = ta.atr(14) * 0.06
pEdgeUp = plot(close - glow, display = display.none, editable = false)
pEdgeDn = plot(close + glow, display = display.none, editable = false)
fill(pPrice, pEdgeUp, showFill and close > lms ? color.new(longCol, 45) : na,  title = "Bull Edge")
fill(pPrice, pEdgeDn, showFill and close < lms ? color.new(shortCol, 45) : na, title = "Bear Edge")

// candles
barcolor(paintBar ? color.new(trendCol, 10) : na, title = "Trend Candles")

// Alerts
alertcondition(bullFlip, "NLMS Bullish", "NLMS Adaptive Trend turned bullish on {{ticker}}")
alertcondition(bearFlip, "NLMS Bearish", "NLMS Adaptive Trend turned bearish on {{ticker}}")
````
