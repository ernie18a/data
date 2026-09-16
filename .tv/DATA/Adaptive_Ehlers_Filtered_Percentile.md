<!-- tradingview-pine-id: PUB;c0858335f5fc4cef8a2d9fbf4e6ea498 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Ehlers Filtered Percentile

Source: https://www.tradingview.com/script/zdQ2A3zf-Adaptive-Ehlers-Filtered-Percentile/

## Description

Adaptive Ehlers Filtered Percentile is a trend-regime indicator that combines a volatility-adaptive moving average, a displacement-weighted nonlinear filter, and percentile-based price-deviation bands.

The indicator is designed to separate three tasks: adapt the baseline response to changing price variability, further filter that baseline according to historical displacement, and derive regime thresholds from the observed distribution of price-to-trend deviations rather than from a fixed percentage or standard-deviation multiplier.

🟣How It Works
The first stage measures the standard deviation of one-bar price changes.

That volatility measurement is compared with a rolling reference range. The resulting position inside the range determines the effective moving-average period between the user-defined Minimum MA Period and Maximum MA Period.

Higher volatility favors the shorter period, while lower volatility favors the longer period.

The adaptive period is converted into a smoothing coefficient and applied recursively to produce the Adaptive MA.

🟣Displacement-Weighted Filter
The Adaptive MA is then processed through a nonlinear weighted filter.

For each observation in the filter window, the script compares the current Adaptive MA value with another Adaptive MA value separated by the Momentum Length.

The absolute displacement between those observations becomes the weighting coefficient.

Observations associated with larger displacement therefore contribute more heavily to the final filtered trend value, while observations with little displacement contribute less.

If valid weighting coefficients are unavailable, a simple moving average of the Adaptive MA is used as a fallback.

🟣Percentile Bands
The indicator measures the absolute distance between price and the filtered trend:

Absolute Deviation = |Price - Filtered Trend|

These deviations are ranked over the selected Percentile Length.

The chosen Percentile Level determines the historical deviation used as the base band distance.

Unlike standard-deviation bands, this approach does not assume a particular distribution of deviations. The band width instead comes directly from the ranked historical observations.

Separate upper and lower multipliers allow the two sides of the structure to be adjusted independently.

🟣Regime Logic
A bullish regime begins when the selected source moves above the upper percentile band.

A bearish regime begins when the selected source moves below the lower percentile band.

When price remains between the two bands, the previous regime is retained.

LONG and SHORT markers are therefore displayed only when the persistent regime changes rather than on every bar that remains outside a threshold.

🟣Main Settings
Minimum MA Period / Maximum MA Period define the response range of the volatility-adaptive moving average.

Volatility Period controls how much recent price-change history is used to determine the adaptive response.

Filter Length determines how many Adaptive MA observations contribute to the displacement-weighted filter.

Momentum Length determines the historical separation used when measuring displacement for the filter weights.

Percentile Length defines the sample of historical price-to-filter deviations.

Percentile Level determines which ranked deviation becomes the base band width. Higher percentiles generally create more selective thresholds.

Upper Band Multiplier / Lower Band Multiplier independently scale the bullish and bearish thresholds.

🟣Design Purpose
The indicator uses each component for a specific role:

Price-change volatility → Adaptive MA response
Adaptive-MA displacement → Nonlinear filtering weights
Historical absolute deviation → Percentile band width
Band breakout → Persistent market regime

The percentile stage is applied to the actual distance between price and the adaptive filtered baseline. This allows the threshold structure to adjust to the historical distribution of deviations rather than relying only on a fixed volatility multiplier.

The asymmetric upper and lower multipliers also allow the bullish and bearish breakout requirements to be configured independently.

🟣Limitations
This indicator is a trend-regime tool and not a complete trading system. LONG and SHORT labels identify changes in the indicator's internal regime; they do not imply guaranteed trade outcomes or future performance.

Percentile thresholds are based on historical observations within the selected lookback. A change in market behavior can therefore alter the band width as new deviations enter the sample.

The adaptive moving average and nonlinear filter are derived from current and historical price information and remain dependent on the selected parameters.

The script does not use higher-timeframe requests or lookahead logic.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Adaptive Ehlers Filtered Percentile", overlay=true)

// USER INPUTS
string adaptivePeriodTip = "Minimum MA Period sets the fastest adaptive response used during higher volatility, while Maximum MA Period sets the slowest response used during calmer conditions. Lower the minimum for quicker reactions, and increase the maximum for a smoother baseline."
string ehlersTip         = "Filter Length controls how many Adaptive MA observations contribute to the nonlinear Ehlers filter, while Momentum Length controls how far apart those observations are compared when calculating their weights. Increase Filter Length for a smoother trendline, and increase Momentum Length to emphasize broader price displacement."
string percentileTip     = "Percentile Length sets how much historical price-to-filter displacement is ranked, while Percentile Level selects which ranked distance becomes the base band width. Increase the length for a broader sample and increase the percentile level for wider, more selective bands."
string multiplierTip     = "Upper Band Multiplier scales the percentile distance above the filtered trend, while Lower Band Multiplier scales the distance below it. Increase either multiplier to widen that side of the regime threshold and require a larger price move before a breakout."
string colorTip          = "Bullish Color is used for bullish regimes, LONG signals, the upper band, and bullish candle coloring, while Bearish Color is used for bearish regimes, SHORT signals, the lower band, and bearish candle coloring."

float maSrc           = input.source(title="Source", defval=close, group="Adaptive MA Settings", tooltip="Choose the price source used to calculate the volatility-adaptive moving average.")
int   maMin           = input.int(title="Minimum MA Period", defval=3, minval=1, group="Adaptive MA Settings", inline="AMA1", tooltip=adaptivePeriodTip)
int   maMax           = input.int(title="Maximum MA Period", defval=30, minval=2, group="Adaptive MA Settings", inline="AMA1", tooltip=adaptivePeriodTip)
int   volLen          = input.int(title="Volatility Period", defval=9, minval=2, group="Adaptive MA Settings", tooltip="Sets the lookback used to measure the standard deviation of price changes and adapt the moving average length. Increase it for steadier adaptation or decrease it for faster reactions to changing volatility.")
int   ehlersLength    = input.int(title="Filter Length", defval=9, minval=2, group="Ehlers Filter", inline="EF1", tooltip=ehlersTip)
int   ehlersMomentum  = input.int(title="Momentum Length", defval=15, minval=1, group="Ehlers Filter", inline="EF1", tooltip=ehlersTip)
int   percentileLen   = input.int(title="Percentile Length", defval=50, minval=2, group="Percentile Bands", inline="PB1", tooltip=percentileTip)
float percentileLevel = input.float(title="Percentile Level", defval=75.0, minval=1.0, maxval=99.0, step=1.0, group="Percentile Bands", inline="PB1", tooltip=percentileTip)
float upperMult       = input.float(title="Upper Band Multiplier", defval=0.7, minval=0.1, step=0.1, group="Percentile Bands", inline="PB2", tooltip=multiplierTip)
float lowerMult       = input.float(title="Lower Band Multiplier", defval=0.7, minval=0.1, step=0.1, group="Percentile Bands", inline="PB2", tooltip=multiplierTip)
bool  showMA          = input.bool(title="Show Adaptive Filter", defval=true, group="Visualization", tooltip="Show or hide the Ehlers-filtered Adaptive MA. Turning this off only changes the chart display and does not affect the calculations or signals.")
bool  showBands       = input.bool(title="Show Percentile Bands", defval=true, group="Visualization", tooltip="Show or hide the upper and lower percentile bands. Turning this off only changes the chart display and does not affect the regime calculations.")
bool  showFill        = input.bool(title="Show Band Fill", defval=true, group="Visualization", tooltip="Show or hide the shaded area between the upper and lower percentile bands. This is visual only and does not change the indicator calculations.")
bool  showSignals     = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show or hide LONG and SHORT markers whenever price establishes a new percentile-band regime. Turning this off does not change the underlying regime state.")
bool  colorBars       = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color price candles according to the currently active regime. Turning this off only removes candle coloring and does not affect signals.")
color longColor       = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="C1", tooltip=colorTip)
color shortColor      = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="C1", tooltip=colorTip)

// CALCULATIONS
float deltaP   = maSrc - maSrc[1]
float s        = ta.stdev(deltaP, volLen)
float sAverage = ta.sma(s, volLen)

float sMin     = sAverage * 0.25
float sMax     = sAverage * 1.75
float volRange = sMax - sMin

float adaptiveLength = volRange > 0.0 ? (s <= sMin ? maMax : s >= sMax ? maMin : maMax - (maMax - maMin) * (s - sMin) / volRange) : maMax
float alpha          = 2.0 / (adaptiveLength + 1.0)

var float adaptiveMA = na
adaptiveMA := na(adaptiveMA[1]) ? maSrc : adaptiveMA[1] + alpha * (maSrc - adaptiveMA[1])

float ehlersNumerator      = 0.0
float ehlersCoefficientSum = 0.0

for i = 0 to ehlersLength - 1
    float currentSample   = adaptiveMA[i]
    float referenceSample = adaptiveMA[i + ehlersMomentum]
    if not na(currentSample) and not na(referenceSample)
        float coefficient = math.abs(currentSample - referenceSample)
        ehlersNumerator      += coefficient * currentSample
        ehlersCoefficientSum += coefficient

float ehlersFallback = ta.sma(adaptiveMA, ehlersLength)
float trendMA        = ehlersCoefficientSum > 0.0 ? ehlersNumerator / ehlersCoefficientSum : ehlersFallback

float deviation          = math.abs(maSrc - trendMA)
float percentileDistance = ta.percentile_nearest_rank(deviation, percentileLen, percentileLevel)

float upperBand = trendMA + percentileDistance * upperMult
float lowerBand = trendMA - percentileDistance * lowerMult

// SIGNALS
bool long  = maSrc > upperBand
bool short = maSrc < lowerBand

var int SQ = 0

if long
    SQ := 1
else if short
    SQ := -1

bool longSignal  = SQ == 1 and SQ[1] != 1
bool shortSignal = SQ == -1 and SQ[1] != -1

// COLORS
color col = SQ == 1 ? longColor : shortColor

// PLOTS
plot(showMA ? trendMA : na, title="Adaptive Ehlers Filter", color=col, linewidth=2)
upperPlot = plot(showBands ? upperBand : na, title="Upper Percentile Band", color=color.new(longColor, 35), linewidth=1)
lowerPlot = plot(showBands ? lowerBand : na, title="Lower Percentile Band", color=color.new(shortColor, 35), linewidth=1)
fill(upperPlot, lowerPlot, title="Percentile Band Fill", color=showFill ? color.new(col, 92) : na)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Adaptive Ehlers Filtered Percentile Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Adaptive Ehlers Filtered Percentile Short Signal on {{ticker}}")
````
