# MESA Phase-Adaptive Band Trend [SchizoQuant]

- url: https://www.tradingview.com/script/mGCGl56t-MESA-Phase-Adaptive-Band-Trend-SchizoQuant/
- type: indicator
- pine_id: PUB;d6c256729f8b40a29b83c0a2b1c64f75
- version: 1.0

## Description

[b]MESA Phase-Adaptive Band Trend[/b] is an adaptive trend-regime indicator that combines John F. Ehlers’ MESA/MAMA phase-estimation methodology with an EMA trend baseline and volatility-responsive bands.

Instead of using a conventional MAMA/FAMA pair as the final trend model, the indicator uses the underlying phase and dominant-cycle calculations from the MESA/MAMA framework to estimate how actively market phase is changing.

That phase response is then converted into an adaptive band multiplier.

When phase activity becomes stronger, the bands move toward the faster Active Multiplier.

When phase activity weakens, the bands move toward the slower Multiplier.

This creates a trend framework in which trend direction, phase behavior, and volatility are handled through separate mechanisms.

[b]🟣 How It Works[/b]

The indicator is built from four main stages:

MESA / MAMA Phase Engine → Estimates dominant-cycle and phase behavior using Hilbert-transform-based calculations.

Phase Activity → Measures changes in market phase and converts them into a normalized adaptive response.

Trend Baseline → Uses an EMA as the central trend reference.

Adaptive Volatility Bands → Combines phase activity with return volatility to determine the bullish and bearish regime boundaries.

The resulting upper and lower bands define when the persistent trend regime changes.

[b]🟣 MESA / MAMA Phase Engine[/b]

The phase engine is based on the MESA/MAMA methodology developed by John F. Ehlers.

Price is first passed through a weighted smoothing process.

The smoothed series is then processed through a Hilbert-transform sequence that calculates the detrender, quadrature component, in-phase component, and their phase-shifted counterparts.

These components are combined into smoothed in-phase and quadrature values.

The script then derives real and imaginary components from those values and uses their relationship to estimate the dominant market period.

The period estimate is constrained relative to its previous value so that it cannot change excessively from one bar to the next.

It is also bounded between 6 and 50 bars before additional smoothing is applied.

This produces the adaptive dominant-cycle estimate used by the phase calculation.

[b]🟣 Phase Measurement[/b]

The relationship between the quadrature and in-phase components is used to estimate market phase.

The indicator then measures the change in phase from the previous bar.

This phase change determines the adaptive phase response.

Fast Limit defines the strongest response available to the system.

Slow Limit defines the minimum response during weaker phase movement.

The resulting response is normalized into a Phase Activity value between 0 and 1.

Higher Phase Activity represents stronger or faster phase movement.

Lower Phase Activity represents slower or weaker phase movement.

Although the phase engine is derived from the MESA/MAMA framework, the indicator does not construct a traditional MAMA/FAMA moving-average pair.

Instead, the phase information is used to control the sensitivity of the surrounding volatility bands.

[b]🟣 Trend Baseline[/b]

The central trend line is calculated using an exponential moving average of the selected source.

Trend Length controls the responsiveness of this baseline.

Lower values allow the trend to react more quickly to recent price movement.

Higher values create a smoother and slower trend reference.

The EMA itself is not directly modified by the phase engine.

Instead, phase behavior controls the adaptive bands surrounding the trend.

[b]🟣 Return Volatility[/b]

Volatility is measured using the standard deviation of one-bar percentage returns.

The current bands use the previous completed return-volatility value.

Volatility Length controls how much historical return data contributes to the volatility estimate.

Higher values create a steadier volatility measurement.

Lower values allow band width to react more quickly to recent changes in price dispersion.

[b]🟣 Phase-Adaptive Bands[/b]

The band multiplier continuously moves between the user-defined Active Multiplier and Slow Multiplier.

When Phase Activity increases, the multiplier moves toward Active Multiplier.

When Phase Activity decreases, the multiplier moves toward Slow Multiplier.

The upper and lower bands are constructed around the EMA trend:

Upper Band = Trend + Adaptive Multiplier × Return Volatility × Trend

Lower Band = Trend - Adaptive Multiplier × Return Volatility × Trend

This creates two separate forms of adaptation.

MESA/MAMA phase behavior determines how sensitive the band system should be.

Return volatility determines the actual distance of the bands from the trend baseline.

[b]🟣 Persistent Regime Logic[/b]

A bullish condition occurs when the current close is above the upper adaptive band.

A bearish condition occurs when the current close is below the lower adaptive band.

The existing regime remains active while price stays between the two bands.

Price above Upper Band → Bullish regime

Price below Lower Band → Bearish regime

Price between the bands → Previous regime remains active

LONG and SHORT markers therefore appear only when the active regime changes rather than on every bar that remains outside a band.

[b]🟣 Main Settings[/b]

Source determines the price series used by the phase engine and EMA trend baseline.

Fast Limit controls the strongest phase response available to the adaptive process.

Slow Limit controls the minimum phase response during weaker phase activity.

Trend Length controls the EMA trend baseline.

Volatility Length controls the historical window used to estimate return dispersion.

Active Multiplier controls band width during stronger phase activity.

Slow Multiplier controls band width during weaker phase activity.

Show Bands displays or hides the adaptive upper and lower bands.

Show Fill displays or hides the shaded region between the bands.

Show Signals controls the visibility of LONG and SHORT regime-change markers.

Color Bars colors chart candles according to the currently active trend regime.

[b]🟣 Design Purpose[/b]

Each component serves a separate role:

Weighted smoothing → Reduces short-term noise before phase analysis

MESA/MAMA phase engine → Estimates dominant-cycle and phase behavior

Dominant period → Stabilizes the adaptive phase calculation

Delta phase → Measures the rate of change in market phase

Phase response → Determines adaptive band sensitivity

EMA trend → Provides the central trend baseline

Return volatility → Determines adaptive band distance

Adaptive multiplier → Moves the system between faster and slower band sensitivity

Persistent regime → Maintains the active bullish or bearish trend state between boundary transitions

The main design characteristic is that trend direction, phase behavior, and volatility are handled independently.

The EMA defines the central trend.

The MESA/MAMA phase engine controls how responsive the bands should be.

Return volatility determines how far those bands are positioned from the trend.

This allows regime sensitivity to adapt to changing phase behavior without requiring the centerline itself to become aggressively adaptive.

[b]🟣 Limitations[/b]

MESA Phase-Adaptive Band Trend is a trend-regime indicator and not a complete trading system.

LONG and SHORT markers identify changes in the indicator’s internal regime and do not imply guaranteed trading outcomes or future performance.

The MESA/MAMA phase calculations are derived from historical price behavior and their estimates evolve as new market data becomes available.

Phase behavior can vary significantly between assets, market conditions, and timeframes.

During quieter conditions, wider adaptive bands can delay regime changes.

During stronger phase activity, narrower bands can increase sensitivity to shorter-term price movement.

The volatility bands are based on historical return dispersion, so large recent price movements can widen the bands and increase the distance required for subsequent regime changes.

Like other band-based trend methods, abrupt reversals may require price to cross the opposite adaptive boundary before the persistent regime changes.

The script does not use higher-timeframe requests or lookahead logic.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("MESA Phase-Adaptive Band Trend", overlay=true)

// USER INPUTS
string phaseTip = "Fast Limit sets the quickest phase response the indicator can use, while Slow Limit sets the slowest. Increase Fast Limit for stronger reactions during rapid phase movement. Lower Slow Limit for more smoothing when phase activity is weak."
string trendTip = "Trend Length controls the EMA centerline, while Volatility Length controls how much return history is used for the adaptive bands. Increase Trend Length for a smoother centerline and increase Volatility Length for steadier band width."
string bandTip  = "Active Multiplier controls band width when phase activity is strong, while Slow Multiplier controls band width when phase activity is weak. Lower Active Multiplier for faster regime changes during active markets, and increase Slow Multiplier to require larger moves during quieter conditions."
string colorTip = "Bullish Color is used for bullish regimes and LONG signals, while Bearish Color is used for bearish regimes and SHORT signals."

float src         = input.source(title="Source", defval=hl2, group="Phase Settings", tooltip="Choose the price source used to estimate Hilbert phase behavior and calculate the trend.")
float fastLimit   = input.float(title="Fast Limit", defval=0.50, minval=0.01, maxval=1.0, step=0.01, group="Phase Settings", inline="P1", tooltip=phaseTip)
float slowLimit   = input.float(title="Slow Limit", defval=0.05, minval=0.001, maxval=1.0, step=0.001, group="Phase Settings", inline="P1", tooltip=phaseTip)
int   trendLength = input.int(title="Trend Length", defval=20, minval=2, group="Trend Settings", inline="T1", tooltip=trendTip)
int   volLength   = input.int(title="Volatility Length", defval=20, minval=2, group="Trend Settings", inline="T1", tooltip=trendTip)
float activeMult  = input.float(title="Active Multiplier", defval=1.5, minval=0.1, step=0.1, group="Adaptive Bands", inline="B1", tooltip=bandTip)
float slowMult    = input.float(title="Slow Multiplier", defval=3.0, minval=0.1, step=0.1, group="Adaptive Bands", inline="B1", tooltip=bandTip)
bool  showBands   = input.bool(title="Show Bands", defval=true, group="Visualization", tooltip="Show or hide the phase-responsive volatility bands. Turning this off only changes the chart display and does not affect the trend or signal calculations.")
bool  showFill    = input.bool(title="Show Fill", defval=true, group="Visualization", tooltip="Show or hide the shaded area between the upper and lower adaptive bands. This is visual only and does not change the indicator calculations.")
bool  showSignals = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show or hide LONG and SHORT markers when the active trend regime changes. Turning this off does not change the underlying regime calculation.")
bool  colorBars   = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color the price candles according to the currently active trend regime. Turning this off only removes candle coloring and does not affect signals.")
color longColor   = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="C1", tooltip=colorTip)
color shortColor  = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="C1", tooltip=colorTip)

// CALCULATIONS
float smooth       = (4.0 * src + 3.0 * nz(src[1], src) + 2.0 * nz(src[2], src) + nz(src[3], src)) / 10.0
var float period   = 10.0
float periodFactor = 0.075 * nz(period[1], 10.0) + 0.54

float detrender = (0.0962 * smooth + 0.5769 * nz(smooth[2]) - 0.5769 * nz(smooth[4]) - 0.0962 * nz(smooth[6])) * periodFactor
float q1        = (0.0962 * detrender + 0.5769 * nz(detrender[2]) - 0.5769 * nz(detrender[4]) - 0.0962 * nz(detrender[6])) * periodFactor
float i1        = nz(detrender[3])

float jI = (0.0962 * i1 + 0.5769 * nz(i1[2]) - 0.5769 * nz(i1[4]) - 0.0962 * nz(i1[6])) * periodFactor
float jQ = (0.0962 * q1 + 0.5769 * nz(q1[2]) - 0.5769 * nz(q1[4]) - 0.0962 * nz(q1[6])) * periodFactor

float i2Raw = i1 - jQ
float q2Raw = q1 + jI

var float i2 = 0.0
var float q2 = 0.0

i2 := 0.2 * i2Raw + 0.8 * nz(i2[1])
q2 := 0.2 * q2Raw + 0.8 * nz(q2[1])

float reRaw = i2 * nz(i2[1]) + q2 * nz(q2[1])
float imRaw = i2 * nz(q2[1]) - q2 * nz(i2[1])

var float re = 0.0
var float im = 0.0

re := 0.2 * reRaw + 0.8 * nz(re[1])
im := 0.2 * imRaw + 0.8 * nz(im[1])

float angle          = re != 0.0 ? math.atan(im / re) * 180.0 / math.pi : 0.0
float rawPeriod      = angle != 0.0 ? math.abs(360.0 / angle) : nz(period[1], 10.0)
float previousPeriod = nz(period[1], 10.0)
float limitedPeriod  = math.min(rawPeriod, 1.5 * previousPeriod)

limitedPeriod := math.max(limitedPeriod, 0.67 * previousPeriod)
limitedPeriod := math.max(6.0, math.min(50.0, limitedPeriod))
period        := 0.2 * limitedPeriod + 0.8 * previousPeriod

var float phase = 0.0
phase := i1 != 0.0 ? math.atan(q1 / i1) * 180.0 / math.pi : nz(phase[1])

float deltaPhase = nz(phase[1]) - phase
deltaPhase := math.max(deltaPhase, 1.0)

float alphaPhase = fastLimit / deltaPhase
alphaPhase := math.max(alphaPhase, slowLimit)

float phaseRange    = math.max(fastLimit - slowLimit, 0.0001)
float phaseActivity = math.max(0.0, math.min(1.0, (alphaPhase - slowLimit) / phaseRange))

float trend       = ta.ema(src, trendLength)
float priceReturn = src[1] != 0.0 ? (src - src[1]) / src[1] : 0.0
float volatility  = ta.stdev(priceReturn, volLength)[1]

float adaptiveMult = slowMult - (slowMult - activeMult) * phaseActivity
float upperBand    = trend + adaptiveMult * volatility * trend
float lowerBand    = trend - adaptiveMult * volatility * trend

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
plot(trend, title="Trend", color=col, linewidth=2)
upperPlot = plot(showBands ? upperBand : na, title="Upper Phase Band", color=color.new(longColor, 35), linewidth=1)
lowerPlot = plot(showBands ? lowerBand : na, title="Lower Phase Band", color=color.new(shortColor, 35), linewidth=1)
fill(upperPlot, lowerPlot, title="Phase Band Fill", color=showFill ? color.new(col, 90) : na)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS

alertcondition(longSignal, title="Long Signal", message="Phase-Responsive Band Trend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Phase-Responsive Band Trend Short Signal on {{ticker}}")
````
