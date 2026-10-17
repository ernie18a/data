# Kaufman Adaptive Channel Trend

- url: https://www.tradingview.com/script/VklTVwwI-Kaufman-Adaptive-Channel-Trend/
- type: indicator
- pine_id: PUB;9d04dc68a1344e53b5a3daf1f057d016
- version: 1.0

## Description

[b]🟣Kaufman Adaptive Channel Trend[/b] is an adaptive trend-regime indicator that combines Kaufman's Efficiency Ratio, Kaufman Adaptive Moving Average (KAMA), volatility-based bands, and completed price-channel structure.

The indicator is designed to distinguish efficient directional movement from irregular price behavior and use that distinction to adapt its trend-defense mechanism.

Rather than relying exclusively on a moving average, a fixed volatility multiplier, or a traditional breakout channel, the model continuously adjusts the influence of KAMA-based volatility bands and completed market structure.

The result is a one-way adaptive trend trail that identifies bullish and bearish regimes while responding to changes in directional efficiency.

[b]🟣How It Works[/b]
[quote]The indicator combines five primary components:

• Kaufman Efficiency Ratio measures the directional efficiency of price movement.
• KAMA adapts its smoothing response to changing market efficiency.
• Adaptive volatility bands measure price displacement around KAMA.
• A completed price channel identifies broader structural support and resistance.
• An efficiency-weighted trailing mechanism combines these components into a persistent bullish or bearish trend regime.

The interaction between these components allows the indicator to adjust structural defense according to prevailing price conditions rather than applying an identical trailing method in every environment.[/quote]

[b]🟣Kaufman Efficiency Ratio[/b]
[quote]Kaufman's Efficiency Ratio evaluates how efficiently price has traveled over a selected observation period.

It compares the absolute net price movement with the accumulated absolute movement between consecutive observations.

[pine]
float ER = totalMovement > 0.0 ? netMovement / totalMovement : 0.0
ER := math.max(0.0, math.min(1.0, ER))
[/pine]

The resulting value is constrained between 0 and 1.

• Values closer to 1 indicate relatively efficient directional movement.
• Values closer to 0 indicate greater irregularity or back-and-forth price movement.

The Efficiency Length setting determines the observation horizon used to calculate this measurement.

Efficiency Ratio serves two purposes within the indicator: it controls KAMA's smoothing response and determines the influence assigned to structural price-channel defense.[/quote]

[b]🟣Kaufman Adaptive Moving Average[/b]
[quote]KAMA forms the adaptive price baseline.

Its smoothing factor is calculated from the Efficiency Ratio together with configurable fast and slow smoothing lengths.

During efficient directional conditions, the smoothing factor moves toward the faster response.

During less efficient conditions, the smoothing factor moves toward the slower response.

The smoothing constant is squared before being applied recursively to the moving average.

This allows KAMA to respond differently to persistent directional movement and irregular price fluctuations without requiring the user to manually switch moving-average lengths.[/quote]

[b]🟣Adaptive Volatility Bands[/b]
[quote]The model estimates price displacement around KAMA using the root mean square of the residual difference between price and the adaptive moving average.

This residual measurement provides a volatility-sensitive distance for the upper and lower bands.

The Band Multiplier controls how strongly the residual displacement affects band width.

A separate ATR-based minimum distance prevents the adaptive bands from becoming narrower than the configured volatility floor.

The resulting upper and lower bands therefore reflect both:

• Price displacement around the adaptive baseline
• A minimum volatility allowance derived from ATR

The bands are displayed as an optional shaded channel around KAMA.

Their primary purpose is to provide a volatility-based component for the adaptive trend-defense calculation.[/quote]

[b]🟣Completed Price Channel[/b]
[quote]The indicator calculates an upper and lower price channel from the highest highs and lowest lows over a configurable lookback.

Importantly, the channel references the previous completed calculation rather than allowing the current candle to redefine the structural level being evaluated.

This creates a structural reference based on already established price extremes.

The Channel Length setting determines how much completed price history contributes to these levels.

A shorter lookback produces a more responsive channel, while a longer lookback reflects broader price structure.

The completed channel provides the structural component of the indicator's adaptive defense.[/quote]

[b]🟣Efficiency-Weighted Structural Defense[/b]
[quote]The indicator combines two distinct approaches to trend defense:

• KAMA volatility bands
• Completed price-channel structure

The Kaufman Efficiency Ratio determines their relative influence.

[pine]float structuralWeight = math.min(ER * structureInfluence, 1.0)
float bandWeight       = 1.0 - structuralWeight

float bullishDefense = bandWeight * lowerBand + structuralWeight * channelLower
float bearishDefense = bandWeight * upperBand + structuralWeight * channelUpper[/pine]

When directional efficiency is low, the adaptive defense places greater emphasis on the KAMA volatility bands.

As directional efficiency increases, the completed price channel receives progressively greater influence.

Structure Influence controls how quickly the weighting shifts toward structural defense.

A value of zero removes the channel's influence from the defense calculation, while higher settings allow the completed price structure to become more dominant during efficient market conditions.

This approach enables the model to adapt its trailing reference using the characteristics of price movement rather than relying on one fixed defense mechanism.[/quote]

[b]🟣One-Way Adaptive Trend Trail[/b]
[quote]The indicator maintains a persistent bullish or bearish trend regime through a one-way trailing mechanism.

During a bullish regime, the active trail can move higher but cannot move lower.

During a bearish regime, the active trail can move lower but cannot move higher.

[pine]if previousSQ == 1
    trendTrail := math.max(previousTrail, bullishDefense)
else
    trendTrail := math.min(previousTrail, bearishDefense)[/pine]

This mechanism prevents changes in volatility or structural weighting from loosening an established trend trail.

When the regime reverses, the trail is reinitialized using a configurable ATR-based reset distance.

The reset distance cannot be smaller than the current adaptive band distance.

After initialization, the efficiency-weighted structural defense resumes control of the trail.

This creates a distinction between the initial volatility allowance after a reversal and the subsequent structural progression of the trend.[/quote]

[b]🟣Signal Logic[/b]
[quote]LONG and SHORT markers identify changes in the indicator's internal bullish or bearish trend regime.

A reversal occurs when the selected price source crosses the active adaptive structural trail in the opposite direction of the prevailing regime.

[pine]bool long  = previousSQ == -1 and src > trendTrail
bool short = previousSQ == 1 and src < trendTrail[/pine]

A LONG condition requires:

• The previous trend regime to be bearish
• The selected price source to move above the active adaptive structural trail

A SHORT condition requires:

• The previous trend regime to be bullish
• The selected price source to move below the active adaptive structural trail

The active trail combines KAMA volatility bands and completed price-channel structure, with their relative influence determined by Kaufman's Efficiency Ratio.

Once a reversal occurs, the indicator updates its internal trend regime and resets the trail in the direction of the new regime.

The reset distance is determined by the greater of the configured ATR-based reset distance and the current adaptive band distance.

LONG and SHORT markers are displayed only when the internal regime changes, avoiding repeated signals during an uninterrupted bullish or bearish regime.[/quote]

[b]🟣Visual Feedback[/b]
[quote]The indicator provides several complementary chart elements.

• KAMA displays the adaptive price baseline.
• Upper and Lower Adaptive Bands display volatility-based price boundaries.
• Adaptive Band Cloud highlights the region between the bands.
• Upper and Lower Price Channels display completed market structure.
• Bullish Trend Trail displays the active bullish structural defense.
• Bearish Trend Trail displays the active bearish structural defense.
• LONG markers identify bullish regime transitions.
• SHORT markers identify bearish regime transitions.

Neon green represents the active bullish trend regime.

Purple represents the active bearish trend regime.

Optional candle coloring applies the same regime colors directly to the price chart.

KAMA, adaptive bands, price channels, trend trails, signal markers, and candle coloring can be displayed or hidden independently.

Disabling these visualization options does not change the underlying calculations or signal logic.[/quote]

[b]🟣Data Window[/b]
[quote]The indicator provides additional measurements through TradingView's Data Window:

• Kaufman Efficiency Ratio
• Structural Defense Weight
• Band Distance ATR
• Internal Trend State

Kaufman Efficiency Ratio represents directional efficiency on a normalized scale.

Structural Defense Weight indicates how much influence the completed price channel currently contributes to the adaptive defense.

Band Distance ATR expresses the adaptive band distance relative to current ATR.

Internal Trend State identifies the active bullish or bearish regime numerically.

These values provide additional transparency into how the model adapts to changing market conditions.[/quote]

[b]🟣User Controls[/b]
[quote]The indicator includes configurable settings for:

• Price Source
• Efficiency Length
• Fast KAMA Length
• Slow KAMA Length
• Adaptive Band Length
• Band Multiplier
• Minimum Band ATR
• Price Channel Length
• Structure Influence
• ATR Length
• Reset Distance
• KAMA Visibility
• Adaptive Band Visibility
• Price Channel Visibility
• Trend Trail Visibility
• Signal Visibility
• Candle Coloring
• Bullish and Bearish Colors

These settings allow the indicator's smoothing response, structural sensitivity, volatility tolerance, and trend-trail behavior to be adjusted for different instruments and chart timeframes.[/quote]

[b]🟣Alerts[/b]
[quote]Separate TradingView alert conditions are provided for:

• Long Signal
• Short Signal

These alerts correspond to transitions into the indicator's bullish or bearish trend regime.

They allow changes in the adaptive trend structure to be monitored through TradingView's alert system.[/quote]

[b]🟣What Makes It Different[/b]
[quote]Kaufman Adaptive Channel Trend extends the traditional use of Kaufman's Efficiency Ratio beyond adaptive moving-average smoothing.

The same efficiency measurement that controls KAMA's responsiveness also determines how much influence completed price structure receives within the trend-defense calculation.

This creates a connected framework in which:

• Directional efficiency influences moving-average responsiveness.
• Residual price displacement determines adaptive band geometry.
• ATR establishes a minimum volatility allowance.
• Completed price channels provide structural references.
• Efficiency-dependent weighting combines volatility and structure.
• A one-way trailing mechanism maintains the active trend regime.

The distinctive feature is the interaction between adaptive smoothing, volatility-based defense, and completed market structure.

Rather than treating these measurements as separate indicators that must independently agree, the model combines them into a single adaptive trailing mechanism.[/quote]

[b]🟣Intended Use[/b]
[quote]Kaufman Adaptive Channel Trend is designed for trend-regime analysis, structural trend monitoring, and directional market-context assessment.

It can be used to:

• Identify the prevailing bullish or bearish trend regime
• Monitor adaptive structural support and resistance
• Evaluate whether price movement is efficient or irregular
• Observe how structural influence changes with directional efficiency
• Identify potential trend reversals through adaptive trail breaks
• Filter trading decisions according to the prevailing market regime
• Combine directional structure with an existing trading methodology

The indicator can be applied to different financial markets and chart timeframes. Its behavior depends on the instrument, volatility environment, timeframe, and selected parameters.[/quote]

[b]🟣Limitations[/b]
[quote]Kaufman Adaptive Channel Trend is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

The model depends on price movement, volatility, and completed price-channel structure.

During sideways or irregular market conditions, repeated trail breaks may produce frequent changes in the active trend regime.

Shorter smoothing or channel lengths can increase responsiveness but may also increase sensitivity to short-term price fluctuations.

Longer lengths and wider adaptive bands can reduce sensitivity while increasing the distance required for a trend reversal.

The Efficiency Ratio measures directional efficiency within the selected lookback and should not be interpreted as a probability of future trend continuation.

The adaptive bands represent modeled price displacement and volatility allowances rather than statistically guaranteed price boundaries.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Kaufman Adaptive Channel Trend", overlay=true)

// USER INPUTS
string sourceTip      = "Choose the price source used to calculate Kaufman Efficiency Ratio, Kaufman Adaptive Moving Average, and trend reversal conditions."
string efficiencyTip  = "Sets the lookback used to calculate Kaufman Efficiency Ratio. Higher values measure directional efficiency across a longer period, while lower values respond more quickly to changes in price behavior."
string fastTip        = "Sets the fast smoothing horizon for Kaufman Adaptive Moving Average. Lower values allow the moving average to respond more quickly during efficient directional movement."
string slowTip        = "Sets the slow smoothing horizon for Kaufman Adaptive Moving Average. Higher values produce stronger smoothing when directional efficiency is low."
string bandLengthTip  = "Sets the smoothing period used to estimate the residual tracking error between price and KAMA. Higher values produce a more stable measure of price displacement."
string bandTip        = "Multiplies the residual RMS deviation around KAMA to determine adaptive band distance. Higher values create wider bands, while lower values increase sensitivity to price movement."
string floorTip       = "Sets the minimum adaptive band distance as a multiple of ATR. This prevents the bands from becoming excessively narrow when residual price noise is low."
string channelTip     = "Sets the completed price-channel lookback used to calculate structural highs and lows. Higher values represent broader market structure, while lower values make the structural channel more responsive."
string structureTip   = "Controls how strongly Kaufman Efficiency Ratio shifts trend defense toward the completed price channel. Higher values give structure more influence during efficient trends, while lower values emphasize KAMA bands."
string atrTip         = "Sets the ATR period used to calculate volatility and the initial trail distance after a bullish or bearish regime reversal."
string resetTip       = "Sets the ATR multiplier used to initialize the trend trail following a reversal. The reset distance cannot be smaller than the current adaptive band distance."
string kamaTip        = "Shows or hides Kaufman Adaptive Moving Average. Disabling this option only affects the display and does not change calculations or signals."
string bandsTip       = "Shows or hides the adaptive KAMA bands and their shaded region. Disabling this option only affects the display and does not change calculations or signals."
string channelsTip    = "Shows or hides the completed upper and lower price channels. Disabling this option only affects the display and does not change calculations or signals."
string trailTip       = "Shows or hides the active bullish or bearish adaptive trend trail. Disabling this option only affects the display and does not change calculations or signals."
string signalsTip     = "Shows or hides LONG and SHORT markers when the internal trend regime changes. Disabling this option only affects the display and does not change calculations or signals."
string barsTip        = "Shows or hides candles colored according to the active bullish or bearish trend regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip       = "Bullish Color represents the active bullish trend regime, while Bearish Color represents the active bearish trend regime."

float src                = input.source(title="Source", defval=close, group="Kaufman Engine", tooltip=sourceTip)
int   erLength           = input.int(title="Efficiency Length", defval=14, minval=2, group="Kaufman Engine", tooltip=efficiencyTip)
int   fastLength         = input.int(title="Fast Length", defval=2, minval=1, group="Kaufman Engine", inline="K1", tooltip=fastTip)
int   slowLength         = input.int(title="Slow Length", defval=30, minval=2, group="Kaufman Engine", inline="K1", tooltip=slowTip)
int   bandLength         = input.int(title="Band Length", defval=20, minval=2, group="Adaptive Bands", inline="B1", tooltip=bandLengthTip)
float bandMultiplier     = input.float(title="Band Multiplier", defval=2, minval=0.1, step=0.1, group="Adaptive Bands", inline="B1", tooltip=bandTip)
float bandFloor          = input.float(title="Minimum Band ATR", defval=0.7, minval=0.0, step=0.1, group="Adaptive Bands", tooltip=floorTip)
int   channelLength      = input.int(title="Channel Length", defval=22, minval=2, group="Price Channel", tooltip=channelTip)
float structureInfluence = input.float(title="Structure Influence", defval=1.25, minval=0.0, maxval=2.0, step=0.05, group="Adaptive Defense", tooltip=structureTip)
int   atrLength          = input.int(title="ATR Length", defval=14, minval=1, group="Adaptive Defense", inline="D1", tooltip=atrTip)
float resetATR           = input.float(title="Reset Distance", defval=1.5, minval=0.1, step=0.1, group="Adaptive Defense", inline="D1", tooltip=resetTip)
bool  showKAMA           = input.bool(title="Show KAMA", defval=true, group="Visualization", tooltip=kamaTip)
bool  showBands          = input.bool(title="Show Adaptive Bands", defval=true, group="Visualization", tooltip=bandsTip)
bool  showChannels       = input.bool(title="Show Price Channel", defval=true, group="Visualization", tooltip=channelsTip)
bool  showTrail          = input.bool(title="Show Trend Trail", defval=true, group="Visualization", tooltip=trailTip)
bool  showSignals        = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars          = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor          = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor         = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float netMovement = math.abs(src - nz(src[erLength], src))
float totalMovement = 0.0

for i = 0 to erLength - 1
    float movement = math.abs(nz(src[i], src) - nz(src[i + 1], src))
    totalMovement += movement

float ER = totalMovement > 0.0 ? netMovement / totalMovement : 0.0
ER := math.max(0.0, math.min(1.0, ER))

int effectiveFast = math.min(fastLength, slowLength)
int effectiveSlow = math.max(fastLength, slowLength)

float fastSC = 2.0 / (effectiveFast + 1.0)
float slowSC = 2.0 / (effectiveSlow + 1.0)

float adaptiveSC = ER * (fastSC - slowSC) + slowSC
float SC         = adaptiveSC * adaptiveSC

var float kama = na
kama := na(kama[1]) ? src : kama[1] + SC * (src - kama[1])

float trueRange = ta.tr(true)
float atrValue  = math.max(nz(ta.atr(atrLength), trueRange), syminfo.mintick)

float residual      = src - kama
float residualPower = ta.rma(residual * residual, bandLength)
float residualRMS   = math.sqrt(math.max(nz(residualPower, residual * residual), 0.0))

float bandDistance = math.max(residualRMS * bandMultiplier, atrValue * bandFloor)

float upperBand = kama + bandDistance
float lowerBand = kama - bandDistance

float highestCalc = ta.highest(high, channelLength)
float lowestCalc  = ta.lowest(low, channelLength)

float channelUpper = nz(highestCalc[1], high)
float channelLower = nz(lowestCalc[1], low)

float structuralWeight = math.min(ER * structureInfluence, 1.0)
float bandWeight       = 1.0 - structuralWeight

float bullishDefense = bandWeight * lowerBand + structuralWeight * channelLower
float bearishDefense = bandWeight * upperBand + structuralWeight * channelUpper

// SIGNALS
var int   SQ         = na
var float trendTrail = na

if na(SQ)
    SQ := src >= kama ? 1 : -1

int previousSQ = nz(SQ[1], SQ)

float resetDistance = math.max(atrValue * resetATR, bandDistance)
float initialTrail  = previousSQ == 1 ? src - resetDistance : src + resetDistance
float previousTrail = nz(trendTrail[1], initialTrail)

if previousSQ == 1
    trendTrail := math.max(previousTrail, bullishDefense)
else
    trendTrail := math.min(previousTrail, bearishDefense)

bool long  = previousSQ == -1 and src > trendTrail
bool short = previousSQ == 1 and src < trendTrail

if long
    SQ := 1
    trendTrail := src - resetDistance
else if short
    SQ := -1
    trendTrail := src + resetDistance
else
    SQ := previousSQ

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) == -1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) == 1

// COLORS
color regimeColor  = SQ == 1 ? longColor : shortColor
color colors       = colorBars ? regimeColor : na
color kamaColor    = color.new(regimeColor, 10)
color bandColor    = color.new(regimeColor, 50)
color channelColor = color.new(color.gray, 35)

// PLOTS
plot(showKAMA ? kama : na, title="Kaufman Adaptive Moving Average", color=kamaColor, linewidth=2)
pUpperBand = plot(showBands ? upperBand : na, title="Upper Adaptive Band", color=bandColor, linewidth=1)
pLowerBand = plot(showBands ? lowerBand : na, title="Lower Adaptive Band", color=bandColor, linewidth=1)
fill(pUpperBand, pLowerBand, color=showBands ? color.new(regimeColor, 92) : na, title="Adaptive Band Cloud")
plot(showChannels ? channelUpper : na, title="Upper Price Channel", color=channelColor, linewidth=1, style=plot.style_stepline)
plot(showChannels ? channelLower : na, title="Lower Price Channel", color=channelColor, linewidth=1, style=plot.style_stepline)
plot(showTrail and SQ == 1 ? trendTrail : na, title="Bullish Trend Trail", color=longColor, linewidth=3, style=plot.style_linebr)
plot(showTrail and SQ == -1 ? trendTrail : na, title="Bearish Trend Trail", color=shortColor, linewidth=3, style=plot.style_linebr)
plotshape(showSignals and longSignal, title="LONG", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="SHORT", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)
barcolor(colors, title = "Color Bars")
plotcandle(open, high, low, close, "Color Bars", colors, colors, bordercolor = colors, force_overlay = true)
plot(ER, title="Kaufman Efficiency Ratio", display=display.data_window)
plot(structuralWeight, title="Structural Defense Weight", display=display.data_window)
plot(bandDistance / atrValue, title="Band Distance ATR", display=display.data_window)
plot(SQ, title="SQ Trend State", display=display.data_window)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Kaufman Adaptive Channel Trend LONG on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Kaufman Adaptive Channel Trend SHORT on {{ticker}}")
````
