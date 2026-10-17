# ADX Lifecycle Trail [SchizoQuant]

- url: https://www.tradingview.com/script/0644fdvm-ADX-Lifecycle-Trail-SchizoQuant/
- type: indicator
- pine_id: PUB;7c30584507844691947a874a436ba28f
- version: 1.0

## Description

[b]🟣ADX Lifecycle Trail[/b] is an adaptive trend-regime indicator that combines directional movement, changes in ADX strength, and completed price structure to identify bullish and bearish market conditions.

Rather than relying on a fixed trailing distance or a single structural lookback, the indicator adjusts its structural defense according to whether ADX is strengthening or weakening.

The resulting one-way structural trail adapts to the lifecycle of directional strength while requiring opposing directional dominance before the active trend regime can reverse.

[b]🟣How It Works[/b]
[quote]The indicator combines three main components:

• Directional movement establishes bullish or bearish directional dominance.
• ADX lifecycle analysis determines how structural defense adapts.
• A one-way trailing mechanism maintains the active trend regime until price and opposing directional strength support a reversal.

These components work together to create a structural trend framework rather than a conventional moving-average crossover or fixed-distance trailing indicator.[/quote]

[b]🟣Directional Movement Engine[/b]
[quote]The directional engine calculates positive directional movement (+DI), negative directional movement (-DI), and Average Directional Index (ADX) using Wilder-style smoothing.

The relationship between +DI and -DI is normalized into a directional dominance measurement.

Positive dominance indicates stronger bullish directional movement, while negative dominance indicates stronger bearish directional movement.

The Dominance Required setting determines how much opposing directional strength must exist before a regime reversal can occur.

Higher settings require stronger confirmation, while lower settings allow the indicator to respond to weaker directional changes.[/quote]

[b]🟣ADX Lifecycle Adaptation[/b]
[quote]Instead of treating ADX as a simple trend-strength threshold, the indicator measures how ADX changes over a configurable lookback.

[pine]float previousADX = nz(adx[lifecycleLength], adx)
float adxChange   = adx - previousADX

float lifecycle = adxChange / lifecycleScale
lifecycle := math.max(-1.0, math.min(1.0, lifecycle))[/pine]

The resulting lifecycle value is constrained between -1 and +1.

• Strengthening ADX shifts structural defense toward the longer horizon.
• Weakening ADX shifts structural defense toward the shorter horizon.
• Smaller ADX changes keep structural defense closer to the medium horizon.

Lifecycle Scale controls the sensitivity of this adjustment. Higher values require larger ADX changes to produce the same structural adaptation.

This allows the indicator to respond to changes in directional strength without requiring ADX to cross a fixed threshold.[/quote]

[b]🟣Adaptive Structural Defense[/b]
[quote]The indicator maintains three completed structural horizons:

• Short Defense
• Medium Defense
• Long Defense

Bullish structural defense is calculated from previously completed lows, while bearish structural defense is calculated from previously completed highs.

Rather than selecting only one horizon, the indicator continuously blends their structural values according to the ADX lifecycle.

[pine]float bullishDefense = lifecycle >= 0.0 ? mediumLow + lifecycle * (longLow - mediumLow) : mediumLow + (-lifecycle) * (shortLow - mediumLow)

float bearishDefense = lifecycle >= 0.0 ? mediumHigh + lifecycle * (longHigh - mediumHigh) : mediumHigh + (-lifecycle) * (shortHigh - mediumHigh)[/pine]

When ADX strengthens, the blend moves toward longer-term completed price structure.

When ADX weakens, the blend moves toward shorter-term completed price structure.

This approach changes the structural defense itself instead of simply widening or narrowing an ATR multiplier.[/quote]

[b]🟣One-Way Structural Trail[/b]
[quote]The active trail uses a one-way mechanism to preserve the established trend regime.

During a bullish regime, the trail can move upward but cannot move downward.

During a bearish regime, the trail can move downward but cannot move upward.

This prevents changes in the adaptive structural defense from loosening an already established trailing level.

Following a bullish or bearish reversal, the trail is reinitialized using a configurable ATR-based distance from the selected price source.

The completed structural defense subsequently takes over the trail's progression.

The ATR component therefore controls the initial reset distance, while the ADX lifecycle and completed price structure determine the continuing trail behavior.[/quote]

[b]🟣Signal Logic[/b]
[quote]LONG and SHORT markers identify changes in the indicator's internal bullish or bearish trend regime.

A reversal requires both a structural trail break and sufficient opposing directional dominance.

[pine]bool long  = previousSQ == -1 and src > trendTrail and dominance > dominanceLevel
bool short = previousSQ == 1 and src < trendTrail and dominance < -dominanceLevel[/pine]

A LONG condition requires:

• The previous trend regime to be bearish
• The selected price source to move above the active structural trail
• Bullish directional dominance to exceed the configured requirement

A SHORT condition requires:

• The previous trend regime to be bullish
• The selected price source to move below the active structural trail
• Bearish directional dominance to exceed the configured requirement

Once a reversal occurs, the indicator updates its internal trend regime and resets the trail in the direction of the new regime.

LONG and SHORT markers are displayed only when the internal regime changes, avoiding repeated signals during an uninterrupted bullish or bearish regime.[/quote]

[b]🟣Visual Feedback[/b]
[quote]The indicator provides a visual representation of the active trend regime.

• Neon green identifies bullish conditions.
• Purple identifies bearish conditions.
• The structural trail follows the active regime color.
• LONG markers identify transitions into a bullish regime.
• SHORT markers identify transitions into a bearish regime.

Optional candle coloring applies the active regime color directly to price candles.

The trend trail, signal markers, and candle coloring can be controlled independently.

Disabling a visualization option does not change the underlying calculations or signal logic[/quote]

[b]🟣Data Window[/b]
[quote]Additional values are available through TradingView's Data Window:

• DMI Dominance
• Positive Directional Indicator (+DI)
• Negative Directional Indicator (-DI)
• ADX
• ADX Change
• ADX Lifecycle
• Bullish Structural Defense
• Bearish Structural Defense

These measurements provide further visibility into the directional and structural components behind the active trend regime.[/quote]

[b]🟣User Controls[/b]
[quote]The indicator provides configurable inputs for:

• Price Source
• DMI Length
• Directional Dominance Requirement
• ADX Lifecycle Lookback
• ADX Lifecycle Scale
• Short Structural Defense
• Medium Structural Defense
• Long Structural Defense
• ATR Length
• ATR Reset Multiplier
• Trend Trail Visibility
• Signal Visibility
• Candle Coloring
• Bullish and Bearish Colors

These controls allow the user to adjust structural responsiveness, lifecycle sensitivity, and reversal requirements across different markets and chart timeframes.[/quote]

[b]🟣Alerts[/b]
[quote]Separate TradingView alert conditions are provided for:

• Long Signal
• Short Signal

These alerts correspond to transitions into the indicator's bullish or bearish trend regime and can be used to monitor changes in directional structure.[/quote]

[b]🟣What Makes It Different[/b]
[quote]ADX Lifecycle Trail uses changes in ADX strength to control structural trail behavior rather than simply using ADX as a filter.

The model continuously blends three completed structural horizons according to the direction and magnitude of ADX change.

This structural adaptation is combined with:

• Normalized directional dominance
• Completed price highs and lows
• One-way structural trail progression
• ATR-based trail initialization
• Dual-confirmation reversal conditions

The result is a trend-regime framework in which directional strength influences structural defense, while actual regime reversals still require agreement between price and opposing directional movement.[/quote]

[b]🟣Intended Use[/b]
[quote]ADX Lifecycle Trail is designed for trend-regime analysis and structural trend monitoring.

It can be used to:

• Identify bullish and bearish market conditions
• Monitor dynamically adapting structural defense
• Observe the relationship between ADX strength and the active trail
• Identify potential directional reversals
• Filter trading decisions according to the prevailing trend regime
• Add structural confirmation to an existing trading methodology

The indicator can be applied to different markets and chart timeframes. Its behavior depends on the instrument, selected timeframe, and configured settings.[/quote]

[b]🟣Limitations[/b]
[quote]ADX Lifecycle Trail is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

The model depends on price structure, directional movement, and changes in ADX strength.

During sideways or irregular market conditions, repeated structural trail breaks and changes in directional dominance may produce frequent regime reversals.

Longer structural horizons and stronger dominance requirements can reduce responsiveness, while shorter horizons and lower thresholds can increase sensitivity to short-term price movement.

The ATR Reset Multiplier controls the initial distance of the trend trail after a reversal but does not constitute a complete trade-level risk-management system.

The indicator does not incorporate volume, external market positioning, or fundamental data into its calculations.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("ADX Lifecycle Trail", overlay=true)

// USER INPUTS
string dmiTip       = "Sets the directional movement horizon used to calculate +DI, -DI, and ADX."
string dominanceTip = "Sets the minimum normalized +DI versus -DI dominance required to confirm an opposite trend reversal. Higher values require stronger directional dominance before the trend regime can reverse."
string lifecycleTip = "Measures how ADX has changed over the selected lookback. Strengthening ADX shifts structural defense toward the longer horizon while weakening ADX shifts defense toward the shorter horizon."
string scaleTip     = "Controls how much ADX change is required to move fully between short, medium, and long structural defense. Higher values make lifecycle adaptation slower while lower values make it more responsive."
string structureTip = "Defines three completed structural horizons. The ADX lifecycle continuously blends between these fixed horizons rather than changing their lengths dynamically."
string atrTip       = "Sets the ATR period used to initialize the trend trail after a new bullish or bearish regime begins."
string resetTip     = "Controls the initial ATR-based trail distance after a regime reversal before structural defense takes over. Higher values initialize the trail farther from price."
string trailTip     = "Shows or hides the active structural trend trail. Disabling this option only affects the display and does not change calculations or signals."
string signalsTip   = "Shows or hides LONG and SHORT markers when the internal trend regime changes. Disabling this option only affects the display and does not change signal calculations."
string barsTip      = "Shows or hides candles colored according to the active bullish or bearish trend regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip     = "Bullish Color represents the active bullish trend regime while Bearish Color represents the active bearish trend regime."

float src             = input.source(title="Source", defval=close, group="Directional Engine", tooltip="Choose the price source used for trend-trail break confirmation.")
int   dmiLength       = input.int(title="DMI Length", defval=17, minval=2, group="Directional Engine", inline="D1", tooltip=dmiTip)
float dominanceLevel  = input.float(title="Dominance Required", defval=0.10, minval=0.00, maxval=0.80, step=0.01, group="Directional Engine", inline="D1", tooltip=dominanceTip)
int   lifecycleLength = input.int(title="ADX Lifecycle Lookback", defval=4, minval=1, group="Lifecycle Adaptation", inline="A1", tooltip=lifecycleTip)
float lifecycleScale  = input.float(title="Lifecycle Scale", defval=8.0, minval=0.5, step=0.5, group="Lifecycle Adaptation", inline="A1", tooltip=scaleTip)
int   shortLength     = input.int(title="Short Defense", defval=5, minval=2, group="Structural Defense", inline="S1", tooltip=structureTip)
int   mediumLength    = input.int(title="Medium Defense", defval=12, minval=3, group="Structural Defense", inline="S1", tooltip=structureTip)
int   longLength      = input.int(title="Long Defense", defval=24, minval=4, group="Structural Defense", inline="S1", tooltip=structureTip)
int   atrLength       = input.int(title="ATR Length", defval=14, minval=1, group="Trail Reset", inline="R1", tooltip=atrTip)
float resetMultiplier = input.float(title="Reset Multiplier", defval=2.5, minval=0.1, step=0.1, group="Trail Reset", inline="R1", tooltip=resetTip)
bool  showTrail       = input.bool(title="Show Trend Trail", defval=true, group="Visualization", tooltip=trailTip)
bool  showSignals     = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars       = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor       = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor      = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float upMove   = high - nz(high[1], high)
float downMove = nz(low[1], low) - low

float plusDM  = upMove > downMove and upMove > 0.0 ? upMove : 0.0
float minusDM = downMove > upMove and downMove > 0.0 ? downMove : 0.0

float trueRange  = ta.tr(true)
float smoothedTR = math.max(ta.rma(trueRange, dmiLength), syminfo.mintick)

float plusDI  = 100.0 * ta.rma(plusDM, dmiLength) / smoothedTR
float minusDI = 100.0 * ta.rma(minusDM, dmiLength) / smoothedTR

float diSum     = plusDI + minusDI
float dominance = diSum > 0.0 ? (plusDI - minusDI) / diSum : 0.0

float dx  = diSum > 0.0 ? 100.0 * math.abs(plusDI - minusDI) / diSum : 0.0
float adx = ta.rma(dx, dmiLength)

float previousADX = nz(adx[lifecycleLength], adx)
float adxChange   = adx - previousADX

float lifecycle = adxChange / lifecycleScale
lifecycle := math.max(-1.0, math.min(1.0, lifecycle))

float shortLow  = nz(ta.lowest(low, shortLength)[1], low)
float mediumLow = nz(ta.lowest(low, mediumLength)[1], low)
float longLow   = nz(ta.lowest(low, longLength)[1], low)

float shortHigh  = nz(ta.highest(high, shortLength)[1], high)
float mediumHigh = nz(ta.highest(high, mediumLength)[1], high)
float longHigh   = nz(ta.highest(high, longLength)[1], high)

float bullishDefense = lifecycle >= 0.0 ? mediumLow + lifecycle * (longLow - mediumLow) : mediumLow + (-lifecycle) * (shortLow - mediumLow)
float bearishDefense = lifecycle >= 0.0 ? mediumHigh + lifecycle * (longHigh - mediumHigh) : mediumHigh + (-lifecycle) * (shortHigh - mediumHigh)

float atrValue      = math.max(ta.atr(atrLength), syminfo.mintick)
float resetDistance = atrValue * resetMultiplier

// SIGNALS
var int   SQ         = dominance >= 0.0 ? 1 : -1
var float trendTrail = na

int previousSQ = nz(SQ[1], SQ)

float previousTrail = nz(trendTrail[1], previousSQ == 1 ? src - resetDistance : src + resetDistance)

if previousSQ == 1
    trendTrail := math.max(previousTrail, bullishDefense)
else
    trendTrail := math.min(previousTrail, bearishDefense)

bool long  = previousSQ == -1 and src > trendTrail and dominance > dominanceLevel
bool short = previousSQ == 1 and src < trendTrail and dominance < -dominanceLevel

if long
    SQ := 1
    trendTrail := src - resetDistance
else if short
    SQ := -1
    trendTrail := src + resetDistance
else
    SQ := previousSQ

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color col    = SQ == 1 ? longColor : shortColor
color colors = colorBars ? col : na

// PLOTS
plot(showTrail and SQ == 1 ? trendTrail : na, title="Bullish Lifecycle Trail", color=longColor, linewidth=2, style=plot.style_linebr)
plot(showTrail and SQ == -1 ? trendTrail : na, title="Bearish Lifecycle Trail", color=shortColor, linewidth=2, style=plot.style_linebr)

plot(dominance * 100.0, title="DMI Dominance", display=display.data_window)
plot(plusDI, title="+DI", display=display.data_window)
plot(minusDI, title="-DI", display=display.data_window)
plot(adx, title="ADX", display=display.data_window)
plot(adxChange, title="ADX Change", display=display.data_window)
plot(lifecycle, title="ADX Lifecycle", display=display.data_window)
plot(bullishDefense, title="Bullish Structural Defense", display=display.data_window)
plot(bearishDefense, title="Bearish Structural Defense", display=display.data_window)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)
barcolor(colors, title = "Color Bars")
plotcandle(open, high, low, close, "Color Bars", colors, colors, bordercolor = colors, force_overlay = true)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="ADX Lifecycle Trail Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="ADX Lifecycle Trail Short Signal on {{ticker}}")
````
