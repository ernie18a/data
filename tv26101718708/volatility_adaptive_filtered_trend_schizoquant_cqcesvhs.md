# Volatility Adaptive Filtered Trend [SchizoQuant]

- url: https://www.tradingview.com/script/cQcESVhS-Volatility-Adaptive-Filtered-Trend-SchizoQuant/
- type: indicator
- pine_id: PUB;c4c0ce4dbcaf4a0fae2e36f97a819593
- version: 1.0

## Description

[b]Volatility Adaptive Filtered Trend[/b] is an adaptive trend-regime indicator that adjusts its smoothing response according to both current volatility and directional price movement, then applies a displacement-weighted filter before constructing volatility-responsive breakout bands.

Instead of relying on a fixed moving-average speed, the indicator continuously estimates how active current market conditions are relative to their recent history. That activity measurement determines the smoothing coefficient used by the adaptive trend, allowing the baseline to respond faster during stronger movement and more slowly during quieter conditions.

[b]🟣 ✦ How It Works[/b]

The indicator is built from four main stages:

Market Activity → Measures current ATR and directional price movement relative to their recent averages.

Adaptive Trend → Converts that activity measurement into a variable smoothing coefficient.

Filtered Trend → Applies additional EMA smoothing followed by a displacement-weighted filtering process.

Volatility Bands → Builds upper and lower thresholds around the filtered trend using the standard deviation of price returns.

The resulting bands define the bullish and bearish regime boundaries.

[b]🟣 ✦ Adaptive Market Response[/b]

The first stage measures two forms of market activity.

ATR Factor compares current ATR with its recent ATR average.

Change Factor compares the absolute directional movement of price over the Volatility Length with its own recent average.

These two measurements are averaged into a Combined Factor and normalized to a range between 0 and 1.

Higher normalized values represent stronger current activity relative to recent conditions.

Lower normalized values represent quieter or less directional conditions.

[b]🟣 ✦ Adaptive Trend[/b]

The normalized activity measurement is mapped between the user-defined Minimum Smoothing and Maximum Smoothing values.

Higher market activity moves the smoothing coefficient toward Maximum Smoothing, making the adaptive trend react more quickly to price.

Lower activity moves the coefficient toward Minimum Smoothing, producing a slower and more filtered response.

The adaptive trend is calculated recursively, allowing its effective response speed to change continuously as market conditions evolve.

[b]🟣 ✦ EMA Stabilization[/b]

The adaptive trend is passed through an additional EMA smoothing stage.

This step reduces short-term variation in the adaptive baseline before the final filtering process is applied.

EMA Smoothing therefore provides an additional trade-off between responsiveness and stability.

Lower values preserve more of the adaptive trend's immediate movement.

Higher values create a smoother intermediate series.

[b]🟣 ✦ Displacement-Weighted Filter[/b]

The EMA-smoothed adaptive trend is then processed through a displacement-weighted filter.

For each observation inside the Filter Length, the script compares the current sample with a sample located Momentum Length bars farther back.

The absolute difference between those observations becomes the weighting coefficient.

Larger historical displacement therefore gives that observation greater influence on the final filtered trend.

The weighted observations are combined into the final trend baseline.

If no usable displacement weights are available, a simple moving average of the EMA-smoothed adaptive trend is used as a fallback.

[b]🟣 ✦ Volatility Bands[/b]

Band volatility is measured from the standard deviation of one-bar percentage returns.

The volatility measurement uses the previous completed value of return volatility when constructing the current bands.

The upper and lower thresholds are calculated independently around the filtered trend:

Upper Band = Filtered Trend + Upper Multiplier × Return Volatility × Filtered Trend

Lower Band = Filtered Trend - Lower Multiplier × Return Volatility × Filtered Trend

Because the upper and lower multipliers are independent, bullish and bearish regime sensitivity can be configured separately.

[b]🟣 ✦ Persistent Regime Logic[/b]

A bullish condition occurs when the current price is above the upper volatility band.

A bearish condition occurs when the current price is below the lower volatility band.

The indicator maintains a persistent regime:

Price above Upper Band → Bullish regime

Price below Lower Band → Bearish regime

Price between the bands → Previous regime remains active

LONG and SHORT markers therefore appear only when the persistent regime changes rather than on every bar that remains outside a band.

[b]🟣 ✦ Main Settings[/b]

Volatility Length controls the ATR and directional-price-movement measurements used to estimate current market activity.

Normalization Length determines how much historical data is used to establish the reference levels for ATR and directional movement.

Minimum Smoothing defines the slowest adaptive trend response.

Maximum Smoothing defines the fastest adaptive trend response.

EMA Smoothing controls the additional smoothing applied before the displacement-weighted filter.

Filter Length determines how many observations contribute to the final weighted trend.

Momentum Length determines the historical distance used when calculating each observation's displacement weight.

Band Volatility Length controls how much return history is used to estimate volatility around the filtered trend.

Upper Multiplier controls the distance of the bullish threshold above the filtered trend.

Lower Multiplier controls the distance of the bearish threshold below the filtered trend.

[b]🟣 ✦ Design Purpose[/b]

Each component serves a separate role:

ATR activity → Measures current volatility intensity

Directional movement → Measures recent price displacement

Normalized activity → Determines adaptive smoothing speed

Adaptive smoothing → Dynamic trend response

EMA smoothing → Reduces short-term variation

Displacement weighting → Emphasizes observations associated with stronger movement

Return volatility → Determines adaptive band width

Persistent regime → Maintains the active bullish or bearish trend state

The main design characteristic is that trend responsiveness and regime sensitivity are controlled through different mechanisms.

The trend baseline adapts according to relative market activity, while the surrounding thresholds respond independently to return volatility.

This allows the centerline and the regime boundaries to adjust to changing market conditions without relying on the same volatility measurement for both tasks.

[b]🟣 ✦ Limitations[/b]

Volatility Adaptive Filtered Trend is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

The adaptive smoothing mechanism depends on historical ATR and directional price movement. Rapid changes in market conditions can therefore alter the responsiveness of the trend baseline.

The displacement-weighted filter gives greater influence to observations associated with larger historical changes. During irregular or highly volatile conditions, this weighting can shift the filtered trend toward periods containing stronger displacement.

The volatility bands are based on historical return dispersion. Large recent price movements can widen the bands and increase the distance required for subsequent regime changes.

Like other band-based trend methods, the indicator may respond later to abrupt reversals because price must cross the opposite volatility threshold before the persistent regime changes.

Signals are evaluated on the active chart bar and are not restricted to confirmed candle closes. As a result, a regime condition or LONG/SHORT signal can change before the current candle closes.

The script does not use higher-timeframe requests or lookahead logic.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Volatility Adaptive Filtered Trend", overlay=true)

// USER INPUTS
string adaptiveTrendTip  = "Volatility Length controls how far back the indicator measures ATR and directional price movement, while Normalization Length sets the reference window used to judge whether current conditions are unusually active or quiet. Lower either value for faster adaptation, or increase them for a steadier response."
string smoothingLimitTip = "Minimum Smoothing sets the slowest response the adaptive trend can use, while Maximum Smoothing sets the fastest. Lower Minimum Smoothing for more filtering during quiet conditions, and increase Maximum Smoothing for quicker reactions during stronger movement."
string ehlersTip         = "Filter Length controls how many recent EMA-smoothed adaptive trend observations contribute to the displacement-weighted filter, while Momentum Length controls how far apart those observations are compared when calculating their weights. Increase Filter Length for a smoother trendline, and increase Momentum Length to emphasize movement across a broader span of bars."
string bandMultiplierTip = "Upper Multiplier controls how far the bullish threshold sits above the filtered trendline, while Lower Multiplier controls how far the bearish threshold sits below it. Increase either multiplier to widen that side of the bands and require a larger price move before a regime change."
string colorTip          = "Bullish Color is used for bullish regimes, LONG signals, the upper band, and bullish candle coloring, while Bearish Color is used for bearish regimes, SHORT signals, the lower band, and bearish candle coloring."

float src            = input.source(title="Source", defval=hlc3, group="Adaptive Trend Settings", tooltip="Choose the price source used throughout the adaptive trend calculation. HLC3 provides a balanced view of each candle by averaging the high, low, and close.")
int   volLength      = input.int(title="Volatility Length", defval=15, minval=2, group="Adaptive Trend Settings", inline="AT1", tooltip=adaptiveTrendTip)
int   normalLength   = input.int(title="Normalization Length", defval=30, minval=5, group="Adaptive Trend Settings", inline="AT1", tooltip=adaptiveTrendTip)
float minSC          = input.float(title="Minimum Smoothing", defval=0.084, minval=0.001, maxval=1.0, step=0.001, group="Smoothing Limits", inline="SL1", tooltip=smoothingLimitTip)
float maxSC          = input.float(title="Maximum Smoothing", defval=0.330, minval=0.001, maxval=1.0, step=0.001, group="Smoothing Limits", inline="SL1", tooltip=smoothingLimitTip)
int   emaLength      = input.int(title="EMA Smoothing", defval=5, minval=1, group="Smoothing", tooltip="Adds an extra smoothing step to the adaptive trend before the final filter is applied. Increase it to reduce short-term noise or decrease it to preserve more responsiveness.")
int   ehlersLength   = input.int(title="Filter Length", defval=9, minval=2, group="Ehlers Filter", inline="EF1", tooltip=ehlersTip)
int   ehlersMomentum = input.int(title="Momentum Length", defval=2, minval=1, group="Ehlers Filter", inline="EF1", tooltip=ehlersTip)
int   bandVolLength  = input.int(title="Volatility Length", defval=22, minval=2, group="Volatility Bands", tooltip="Sets how much return history is used to estimate band volatility. Lower values make the bands adjust faster to changing volatility, while higher values create a steadier band width.")
float upperMult      = input.float(title="Upper Multiplier", defval=2.0, minval=0.1, step=0.1, group="Volatility Bands", inline="VB1", tooltip=bandMultiplierTip)
float lowerMult      = input.float(title="Lower Multiplier", defval=2.0, minval=0.1, step=0.1, group="Volatility Bands", inline="VB1", tooltip=bandMultiplierTip)
bool  showBands      = input.bool(title="Show Bands", defval=true, group="Visualization", tooltip="Show or hide the upper and lower volatility bands around the filtered trendline. Turning this off only changes the chart display and does not affect the trend calculations or signals.")
bool  showFill       = input.bool(title="Show Fill", defval=true, group="Visualization", tooltip="Show or hide the shaded area between the upper and lower volatility bands. This is visual only and does not change the indicator calculations.")
bool  showSignals    = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show or hide LONG and SHORT markers when the active trend regime changes. Turning this off does not change the underlying regime calculation.")
bool  colorBars      = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color price candles according to the currently active trend regime. Turning this off only removes candle coloring and does not affect the signals.")
color longColor      = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor     = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float atr            = ta.atr(volLength)
float netChange      = math.abs(src - src[volLength])
float atrBaseline    = ta.sma(atr, normalLength)
float changeBaseline = ta.sma(netChange, normalLength)

float atrFactor        = atrBaseline != 0.0 ? atr / atrBaseline : 1.0
float changeFactor     = changeBaseline != 0.0 ? netChange / changeBaseline : 1.0
float combinedFactor   = (atrFactor + changeFactor) * 0.5
float normalizedFactor = math.max(0.0, math.min(1.0, combinedFactor / 2.0))

float adaptiveSC = minSC + (maxSC - minSC) * normalizedFactor

var float adaptiveTrend = na
adaptiveTrend := na(adaptiveTrend[1]) ? src : adaptiveTrend[1] + adaptiveSC * (src - adaptiveTrend[1])

float emaTrend = ta.ema(adaptiveTrend, emaLength)

float ehlersNumerator      = 0.0
float ehlersCoefficientSum = 0.0

for i = 0 to ehlersLength - 1
    float currentSample   = emaTrend[i]
    float referenceSample = emaTrend[i + ehlersMomentum]

    if not na(currentSample) and not na(referenceSample)
        float coefficient = math.abs(currentSample - referenceSample)
        ehlersNumerator      += coefficient * currentSample
        ehlersCoefficientSum += coefficient

float ehlersFallback = ta.sma(emaTrend, ehlersLength)
float trendMA        = ehlersCoefficientSum > 0.0 ? ehlersNumerator / ehlersCoefficientSum : ehlersFallback

float priceReturn = src[1] != 0.0 ? (src - src[1]) / src[1] : 0.0
float volatility  = ta.stdev(priceReturn, bandVolLength)[1]

float upperBand = trendMA + upperMult * volatility * trendMA
float lowerBand = trendMA - lowerMult * volatility * trendMA

// SIGNALS
bool long  = close > upperBand
bool short = close < lowerBand

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
plot(trendMA, title="Filtered Adaptive Trend", color=col, linewidth=2)
upperPlot = plot(showBands ? upperBand : na, title="Upper Volatility Band", color=color.new(longColor, 35), linewidth=1)
lowerPlot = plot(showBands ? lowerBand : na, title="Lower Volatility Band", color=color.new(shortColor, 35), linewidth=1)
fill(upperPlot, lowerPlot, title="Volatility Band Fill", color=showFill ? color.new(col, 90) : na)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Volatility Adaptive Filtered Trend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Volatility Adaptive Filtered Trend Short Signal on {{ticker}}")
````
