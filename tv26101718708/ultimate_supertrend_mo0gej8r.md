# Ultimate Supertrend

- url: https://www.tradingview.com/script/mo0Gej8r-Ultimate-Supertrend/
- type: indicator
- pine_id: PUB;a33f6b8aafc8433c9a718538d8e67d78
- version: 1.0

## Description

1. The Core: NLMS Adaptive Filter
At its heart is the Normalized Least Mean Squares (NLMS) filter. Unlike a standard moving average (SMA/EMA) that statically averages the last X bars, the NLMS is an "online" machine-learning predictor.

It looks at the past M bars (taps) and uses gradient descent to calculate "weights" that best predict the current price.

The Step Size (μ) dictates how aggressively it learns. A higher step size makes it hug the price very closely (reactive), while a lower step size keeps the baseline smooth.

This creates an incredibly adaptive baseline that tracks market movement more intelligently than traditional moving averages.

2. Volatility Bands (ATR)
Instead of just using the raw NLMS line, the script applies an Average True Range (ATR) multiplier on top of it.

It calculates an upper and lower boundary based on the ATR around the NLMS baseline.

If the baseline tries to move past these upper/lower extremes, the indicator "ratchets" or snaps the trailing line to the boundary.

This creates the characteristic "stair-step" trailing stop behavior you see in Supertrends.

3. Trend Direction & Signals
The indicator determines the trend by looking at the trajectory of the final NLMS-ATR trailing line:

Bullish Trend (Green): Triggered when the trailing line ticks upward (crosses over its previous value).

Bearish Trend (Red): Triggered when the trailing line ticks downward (crosses under its previous value).

It fires automated alert conditions (alertcondition) whenever these trend flips occur.

4. Visual Enhancements
To make it visually intuitive for trading, the script includes premium aesthetics:

Trend Candles: Automatically paints the actual price candles green or red depending on the current trend.

Gradient Fills: Fills the area between the price and the trailing line, fading softly towards the price to show momentum density.

Trail Glow: Adds a sleek visual glow (semi-transparent bands) around the trailing line itself.

In short, it’s a highly-responsive, volatility-adjusted trailing stop that uses an adaptive algorithm to filter out market noise while keeping you on the right side of the trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © greymyst
// Created by greymyst

//@version=6
indicator("Greymyst Ultimate Supertrend", shorttitle="Supertrend", overlay=true)

// Group Names
const string g1 = "NLMS Filter Settings"
const string g2 = "ATR Settings"
const string plt = "Plotting Settings"

// Inputs
float src    = input.source(close, "Source", group = g1)
int   taps   = input.int(72, "Filter Taps (M)", minval = 2, maxval = 200, group = g1, tooltip = "Number of past bars (learned weights). More taps = more memory / smoother.")
float mu     = input.float(0.195, "Step Size (μ)", minval = 0.001, maxval = 1.50, step = 0.001, group = g1, tooltip = "Learning rate (gradient step). Low keeps weights diffuse / smooth. High = reactive but noisy.")
float eps    = input.float(0.6, "Regularization (ε)", minval = 0.0, step = 0.1, group = g1, tooltip = "Prevents divide-by-zero when input power is tiny.")

int periodAtr = input.int(14, "ATR Period", group = g2)
float factorAtr = input.float(1.7, "ATR Factor", step = 0.01, group = g2)

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
plotcandle(open,high,low,close,"Trend Candles", paintBar ? trendCol : na, paintBar ? trendCol : na, true, bordercolor=paintBar ? trendCol : na)

plot(nlmsAtr, "Greymyst Supertrend", color=col, linewidth=lineW)

// Alerts
alertcondition(nlmsAtrLong, "Greymyst Supertrend Bullish", "Greymyst Supertrend turned bullish on {{ticker}}")
alertcondition(nlmsAtrShort, "Greymyst Supertrend Bearish", "Greymyst Supertrend turned bearish on {{ticker}}")
````
