# Adaptive Persistence Trail [SchizoQuant]

- url: https://www.tradingview.com/script/d5b9Xvft-Adaptive-Persistence-Trail-SchizoQuant/
- type: indicator
- pine_id: PUB;302cf70ff3cb4fceb4097189b14d7a4a
- version: 1.0

## Description

[b]Adaptive Persistence Trail[/b] is a directional trend indicator that measures the balance between bullish and bearish price travel and uses that information to control how aggressively a persistent trailing level advances.

Instead of using a fixed trailing speed, the indicator evaluates how one-sided or two-sided recent price movement has been.

When price travel is strongly directional, the trail advances more quickly toward the active regime extreme.

When price movement is more balanced and two-sided, the trail advances more slowly.

This creates a persistence-based trailing framework that adapts to the quality of directional movement rather than relying on a constant acceleration rate.

[b]🟣✦ How It Works[/b]

[quote]The calculation follows this structure:

Bullish Price Travel vs Bearish Price Travel  
↓  
Directional Persistence  
↓  
Absolute Persistence  
↓  
Adaptive Trail Acceleration  
↓  
Structure-Protected Persistent Trail  
↓  
Bullish / Bearish Regime

The indicator measures cumulative upward and downward price travel over the selected Persistence Length.

These values are converted into a normalized persistence score ranging from -1 to +1.

Positive values indicate stronger bullish travel.

Negative values indicate stronger bearish travel.

Values closer to zero indicate more balanced two-sided movement.[/quote]

[b]🟣✦ Directional Persistence[/b]

[quote]Bullish and bearish price travel are measured independently.

Each positive price change contributes to bullish travel.

Each negative price change contributes to bearish travel.

The two are then compared using a normalized relationship:

Bullish Travel − Bearish Travel  
divided by  
Total Travel

This produces the Directional Persistence value.

A reading near +1 indicates strongly one-sided bullish movement.

A reading near -1 indicates strongly one-sided bearish movement.

A reading near 0 indicates that bullish and bearish travel are more balanced.[/quote]

[b]🟣✦ Trend Clarity[/b]

[quote]The absolute value of Directional Persistence is used as a measure of directional clarity.

High absolute persistence means recent movement has been relatively one-sided.

Low absolute persistence means price has been travelling in both directions more evenly.

This clarity measurement controls the trail's adaptive acceleration.[/quote]

[b]🟣✦ Adaptive Trail Acceleration[/b]

[quote]The indicator maps trend clarity between the selected Minimum Acceleration and Maximum Acceleration values.

During stronger directional movement, the acceleration factor moves toward the maximum setting.

This causes the trail to approach the active regime extreme more quickly.

During less directional or noisier movement, the acceleration factor moves toward the minimum setting.

This causes the trail to advance more gradually.

The result is a trail that reacts to directional persistence rather than using a fixed trailing speed.[/quote]

[b]🟣✦ Regime Extreme[/b]

[quote]While a bullish regime is active, the indicator tracks the highest price reached during that regime.

While a bearish regime is active, it tracks the lowest price reached during that regime.

The adaptive trail is continuously advanced toward this regime extreme according to the current acceleration factor.

This allows the trail to tighten naturally as directional persistence strengthens.[/quote]

[b]🟣✦ Structure Protection[/b]

[quote]The accelerating trail is constrained by recent market structure.

During bullish regimes, recent low structure constrains new upward advancement of the trail.

During bearish regimes, recent high structure constrains new downward advancement of the trail.

This helps prevent the adaptive acceleration process from forcing the trail too aggressively through nearby price structure.

The Structure Protection setting controls how much recent price history is considered.[/quote]

[b]🟣✦ Persistent Trend Regime[/b]

[quote]The indicator maintains a persistent bullish or bearish regime.

Bullish regime → Trail advances upward beneath price.

Bearish regime → Trail advances downward above price.

A bullish transition occurs when price crosses above the active bearish trail.

A bearish transition occurs when price crosses below the active bullish trail.

If neither reversal condition occurs, the previous regime remains active.

This persistence prevents repeated regime changes when price remains on the same side of the active trail.[/quote]

[b]🟣✦ Trail Reset[/b]

[quote]When a new regime begins, the trail is reset using an ATR-based distance from price.

ATR is used only to determine this initial reset distance.

It does not continuously control the trailing behavior.

After the reset, the trail is driven by:

Directional persistence  
Adaptive acceleration  
Regime extreme  
Recent price structure

The Reset ATR Length controls the volatility measurement used during the transition.

The Reset Multiplier controls how far the new trail is initially placed from price.[/quote]

[b]🟣✦ Visual Feedback[/b]

[quote]The indicator displays separate bullish and bearish trail segments.

Neon Green → Bullish regime

Purple → Bearish regime

LONG and SHORT markers identify changes in the persistent regime.

Optional candle coloring makes the active directional state immediately visible on the chart.[/quote]

[b]🟣✦ Data Window Metrics[/b]

[quote]Several internal values are available in the Data Window:

Directional Persistence  
Trend Clarity  
Trail Acceleration  
Regime Extreme  
Reset Distance

These values make it possible to observe how the trail is adapting to current market behavior.[/quote]

[b]🟣✦ User Controls[/b]

[quote]Persistence Length → Controls how much recent price travel is used to evaluate directional persistence.

Minimum Acceleration → Sets the slowest trail advancement used during weak directional persistence.

Maximum Acceleration → Sets the fastest trail advancement used during strong directional persistence.

Structure Protection → Controls the recent price-structure window used to constrain the trail.

Reset ATR Length → Controls the ATR lookback used when a new regime begins.

Reset Multiplier → Controls the initial trail distance after a regime transition.

Visualization settings allow the trail, regime-change signals, and candle coloring to be independently displayed or hidden without changing the underlying calculations.[/quote]

[b]🟣✦ Intended Use[/b]

[quote]Adaptive Persistence Trail is designed for identifying persistent directional regimes while adapting trailing sensitivity to the strength and consistency of recent price travel.

It can be used as:

A standalone trend-state indicator

A trailing trend filter

A directional confirmation layer

A regime filter for systematic strategies

A visual framework for distinguishing persistent directional movement from more balanced two-sided price action[/quote]

[b]🟣✦ Limitations[/b]

[quote]Adaptive Persistence Trail is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

Strong directional persistence causes the trail to tighten more quickly, which can make the regime more sensitive after extended one-sided movement.

Weak persistence produces slower trail advancement, which can keep the active regime in place longer during choppy markets.

The structure-protection window and reset distance can materially affect reversal sensitivity.

The script does not use higher-timeframe requests or lookahead logic.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Adaptive Persistence Trail", overlay=true)

// USER INPUTS
string persistenceTip = "Sets the lookback used to compare cumulative upward and downward price travel. More one-sided movement produces stronger directional persistence, while balanced movement represents less directional conditions."
string accelerationTip = "Minimum Acceleration controls how slowly the trail advances during weak persistence, while Maximum Acceleration controls how quickly it approaches the active regime extreme during strongly directional conditions."
string protectionTip = "Sets the recent price-structure window used to prevent the accelerating trail from advancing through nearby highs or lows. Increase it for broader structural protection or decrease it for a tighter trail."
string resetTip = "Reset ATR Length controls the volatility lookback used when a new regime begins, while Reset Multiplier scales how far the new trail is initially placed from price. ATR is used only for this reset distance and does not continuously drive the trail."
string colorTip = "Bullish Color represents bullish persistence regimes, LONG signals, and bullish visual elements, while Bearish Color represents bearish persistence regimes, SHORT signals, and bearish visual elements."

float src               = input.source(title="Source", defval=close, group="Persistence Settings", tooltip="Choose the price source used to measure directional price travel and evaluate trail reversals.")
int   persistenceLength = input.int(title="Persistence Length", defval=20, minval=2, group="Persistence Settings", tooltip=persistenceTip)
float minAcceleration   = input.float(title="Minimum Acceleration", defval=0.5, minval=0.01, maxval=1.00, step=0.01, group="Acceleration Trail", inline="A1", tooltip=accelerationTip)
float maxAcceleration   = input.float(title="Maximum Acceleration", defval=1, minval=0.01, maxval=1.00, step=0.01, group="Acceleration Trail", inline="A1", tooltip=accelerationTip)
int   protectionLength  = input.int(title="Structure Protection", defval=21, minval=1, group="Acceleration Trail", tooltip=protectionTip)
int   atrLength         = input.int(title="Reset ATR Length", defval=14, minval=1, group="Trail Reset", inline="R1", tooltip=resetTip)
float resetMultiplier   = input.float(title="Reset Multiplier", defval=2, minval=0.10, step=0.10, group="Trail Reset", inline="R1", tooltip=resetTip)
bool  showTrail         = input.bool(title="Show Trail", defval=true, group="Visualization", tooltip="Show or hide the adaptive persistence acceleration trail. Turning this off only changes the chart display and does not affect regime calculations or signals.")
bool  showSignals       = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show or hide LONG and SHORT markers whenever the active persistence regime changes. Turning this off does not change the underlying regime calculation.")
bool  colorBars         = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color price candles according to the active persistence regime. Turning this off only removes candle coloring and does not affect signals.")
color longColor         = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor        = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float bullishTravel = 0.0
float bearishTravel = 0.0

for i = 0 to persistenceLength - 1
    float priceChange = nz(src[i], src) - nz(src[i + 1], src)

    if priceChange > 0.0
        bullishTravel += priceChange
    else if priceChange < 0.0
        bearishTravel += -priceChange

float totalTravel = bullishTravel + bearishTravel
float persistence = totalTravel > 0.0 ? (bullishTravel - bearishTravel) / totalTravel : 0.0
persistence := math.max(-1.0, math.min(1.0, persistence))

float clarity = math.abs(persistence)

float lowerAcceleration = math.min(minAcceleration, maxAcceleration)
float upperAcceleration = math.max(minAcceleration, maxAcceleration)
float acceleration      = lowerAcceleration + clarity * (upperAcceleration - lowerAcceleration)

float atrValue      = math.max(ta.atr(atrLength), syminfo.mintick)
float resetDistance = atrValue * resetMultiplier

float recentLow  = ta.lowest(low, protectionLength)
float recentHigh = ta.highest(high, protectionLength)

// SIGNALS
var int SQ              = persistence >= 0.0 ? 1 : -1
var float regimeExtreme = src
var float trendTrail    = na

int previousSQ          = nz(SQ[1], SQ)
float previousExtreme   = nz(regimeExtreme[1], src)
float previousTrail     = nz(trendTrail[1], previousSQ == 1 ? src - resetDistance : src + resetDistance)

if previousSQ == 1
    regimeExtreme := math.max(previousExtreme, high)

    float acceleratedTrail = previousTrail + acceleration * (regimeExtreme - previousTrail)
    float protectedTrail   = math.min(acceleratedTrail, recentLow)

    trendTrail := math.max(previousTrail, protectedTrail)
else
    regimeExtreme := math.min(previousExtreme, low)

    float acceleratedTrail = previousTrail + acceleration * (regimeExtreme - previousTrail)
    float protectedTrail   = math.max(acceleratedTrail, recentHigh)

    trendTrail := math.min(previousTrail, protectedTrail)

bool long  = previousSQ == -1 and src > trendTrail
bool short = previousSQ == 1 and src < trendTrail

if long
    SQ            := 1
    regimeExtreme := high
    trendTrail    := src - resetDistance
else if short
    SQ            := -1
    regimeExtreme := low
    trendTrail    := src + resetDistance
else
    SQ := previousSQ

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color col = SQ == 1 ? longColor : shortColor

// PLOTS
plot(showTrail and SQ == 1 ? trendTrail : na, title="Bullish Persistence Trail", color=longColor, linewidth=2, style=plot.style_linebr)
plot(showTrail and SQ == -1 ? trendTrail : na, title="Bearish Persistence Trail", color=shortColor, linewidth=2, style=plot.style_linebr)
plot(persistence, title="Directional Persistence", display=display.data_window)
plot(clarity, title="Trend Clarity", display=display.data_window)
plot(acceleration, title="Trail Acceleration", display=display.data_window)
plot(regimeExtreme, title="Regime Extreme", display=display.data_window)
plot(resetDistance, title="Reset Distance", display=display.data_window)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Smart Persistence Acceleration Trail Trend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Smart Persistence Acceleration Trail Trend Short Signal on {{ticker}}")
````
