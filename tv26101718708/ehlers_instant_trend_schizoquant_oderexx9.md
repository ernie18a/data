# Ehlers Instant Trend [SchizoQuant]

- url: https://www.tradingview.com/script/ODERexX9-Ehlers-Instant-Trend-SchizoQuant/
- type: indicator
- pine_id: PUB;eb8e07c951b64cd8817a16ab46492fbc
- version: 1.0

## Description

[b]🟣Ehlers Instant Trend[/b] is an adaptive trend-regime indicator that combines John Ehlers' Instantaneous Trendline, directional momentum, residual noise estimation, and a one-way trailing defense to identify bullish and bearish market conditions.

Rather than relying on conventional moving-average crossovers or a fixed trailing distance, the indicator adapts its trend boundaries to price behavior and volatility while requiring directional confirmation before reversing the active regime.

[b]🟣✦ How It Works[/b]
[quote]The indicator combines four primary components:

• Ehlers Instantaneous Trendline establishes a smoothed price reference.
• A leading Ehlers Trigger measures emerging directional momentum.
• Residual RMS noise and ATR determine adaptive trend-defense distance.
• A one-way trailing mechanism maintains the active trend until price and directional confirmation support a reversal.

This approach separates the underlying trend, its directional momentum, and the structural boundary required to establish a new regime.[/quote]

[b]🟣Ehlers Trend and Momentum[/b]
[quote]The Ehlers Instantaneous Trendline uses recursive filtering to create a responsive price baseline while reducing short-term fluctuations.

Trend Response controls the filter's sensitivity. Higher values react faster, while lower values produce smoother behavior.

A leading trigger is calculated from the current trendline and its value two bars earlier.

[pine]float trigger       = 2.0 * instantTrend - nz(instantTrend[2], instantTrend)
float trendMomentum = trigger - instantTrend[/pine]

Positive momentum indicates that the trigger is above the trendline, while negative momentum indicates that it is below.

The trigger contributes directional confirmation to the reversal logic rather than acting as an independent crossover signal.[/quote]

[b]🟣Adaptive Trend Defense[/b]
[quote]The indicator measures residual tracking error between price and the Ehlers trendline using a smoothed root mean square calculation.

This provides a noise-sensitive distance that expands when price deviates more strongly from the filtered baseline.

ATR establishes a separate minimum defense distance.

[pine]float noiseDistance   = residualRMS * bandMultiplier
float minimumDistance = atrValue * minimumATR
float defenseDistance = math.max(noiseDistance, minimumDistance)[/pine]

The model uses whichever distance is larger.

This prevents the trend boundaries from becoming excessively narrow during quieter conditions while allowing them to expand when residual price noise increases.

Bullish defense is positioned below the Ehlers trendline, while bearish defense is positioned above it.[/quote]

[b]🟣One-Way Trend Trail[/b]
[quote]The active trailing boundary follows a one-way mechanism.

• During bullish regimes, the trail can advance upward but cannot move downward.
• During bearish regimes, the trail can advance downward but cannot move upward.

This prevents changing noise measurements from loosening an already established trailing boundary.

Following a reversal, the trail is reinitialized using the relevant Ehlers defense boundary and an ATR-based minimum distance from price.

The adaptive defense then resumes its one-way progression in the direction of the new regime.[/quote]

[b]🟣Signal Logic[/b]
[quote]LONG and SHORT markers identify changes in the indicator's internal bullish or bearish trend regime.

A reversal requires price to cross the active trailing boundary together with either opposing Ehlers momentum or a sufficiently strong price displacement beyond the trendline.

[pine]bool short = previousSQ == 1 and src < trendTrail and (bearishMomentum or strongBearishBreak)
bool long  = previousSQ == -1 and src > trendTrail and (bullishMomentum or strongBullishBreak)[/pine]

A LONG condition requires:

• The previous trend regime to be bearish
• Price to move above the active trend trail
• Bullish Ehlers momentum or a strong bullish reversal override

A SHORT condition requires:

• The previous trend regime to be bullish
• Price to move below the active trend trail
• Bearish Ehlers momentum or a strong bearish reversal override

Reversal Override controls the ATR-based distance required for price to bypass the momentum confirmation.

Once a reversal occurs, the indicator updates its internal regime and resets the trail on the opposite side of price.

LONG and SHORT markers appear only when the internal regime changes, avoiding repeated signals during an uninterrupted trend.[/quote]

[b]🟣Visual Feedback[/b]
[quote]The indicator displays the Ehlers trendline, optional leading trigger, and active bullish or bearish trailing defense.

• Neon green identifies bullish regimes and LONG signals.
• Purple identifies bearish regimes and SHORT signals.
• The trendline follows the active regime color.
• Optional candle coloring reflects the prevailing trend regime.

Users can independently control the trendline, trigger, trail, signals, and candle coloring.

Additional measurements are available through TradingView's Data Window:

• Normalized Ehlers Momentum
• Defense Distance ATR
• SQ Regime[/quote]

[b]🟣User Controls and Alerts[/b]
[quote]Configurable settings include Trend Response, Noise Length, Defense Multiplier, ATR Length, Minimum ATR Distance, and Reversal Override.

These parameters control trendline responsiveness, noise sensitivity, volatility protection, and reversal requirements.

Separate TradingView alerts are provided for Long Signal and Short Signal regime transitions.[/quote]

[b]🟣What Makes It Different[/b]
[quote]Ehlers Instant Trend combines recursive trend filtering with an adaptive trailing mechanism that responds to measured price noise.

Rather than treating the Ehlers trendline as a standalone crossover indicator, the model uses:

• Ehlers momentum for directional confirmation
• Residual RMS noise for adaptive defense
• ATR for minimum volatility protection
• One-way trailing boundaries for trend persistence
• An opposing-price displacement override for additional reversal responsiveness

The distinctive feature is the interaction between adaptive noise defense, directional confirmation, and persistent structural trailing.[/quote]

[b]🟣Intended Use[/b]
[quote]Ehlers Instant Trend is designed for trend-regime identification, adaptive support and resistance monitoring, and potential directional reversal analysis.

It can be used to identify prevailing market direction, monitor trailing trend boundaries, and filter trading decisions within an existing trading methodology.

The indicator can be applied across different markets and chart timeframes, with sensitivity determined by its configurable settings.[/quote]

[b]🟣Limitations[/b]
[quote]Ehlers Instant Trend is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in its internal regime and do not imply guaranteed trading outcomes or future performance.

During sideways or irregular market conditions, repeated trailing-boundary breaks may produce frequent regime changes.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Ehlers Instant Trend", overlay=true)

// USER INPUTS
string sourceTip   = "Choose the price source used by the Ehlers Instantaneous Trendline, trend boundaries, and reversal confirmation."
string alphaTip    = "Controls the response speed of the Ehlers Instantaneous Trendline. Higher values react faster to price changes, while lower values produce a smoother and slower trendline."
string noiseTip    = "Sets the smoothing period used to estimate the residual tracking error between price and the Ehlers trendline. Higher values produce a more stable noise estimate."
string bandTip     = "Multiplies the estimated residual noise to determine the structural defense distance. Higher values create wider trend boundaries, while lower values make the trail more responsive."
string atrTip      = "Sets the ATR period used to calculate the minimum trend defense distance and measure strong opposing price movements."
string minimumTip  = "Sets the minimum trend defense distance as a multiple of ATR. This prevents the trail from becoming excessively tight when the estimated residual noise is low."
string reversalTip = "Sets the ATR distance beyond the Ehlers trendline required for a strong opposing price movement to override the momentum confirmation. Higher values require a deeper reversal move."
string ehlersTip   = "Shows or hides the Ehlers Instantaneous Trendline. Disabling this option only affects the display and does not change calculations or signals."
string triggerTip  = "Shows or hides the leading Ehlers Trigger line used to evaluate trend momentum. Disabling this option only affects the display and does not change calculations or signals."
string trailTip    = "Shows or hides the active bullish or bearish trend trail. Disabling this option only affects the display and does not change calculations or signals."
string signalsTip  = "Shows or hides LONG and SHORT markers when the internal trend regime changes. Disabling this option only affects the display and does not change calculations or signals."
string barsTip     = "Shows or hides candles colored according to the active bullish or bearish trend regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip    = "Bullish Color represents the active bullish trend regime, while Bearish Color represents the active bearish trend regime."

float src               = input.source(title="Source", defval=close, group="Ehlers Engine", tooltip=sourceTip)
float alpha             = input.float(title="Trend Response", defval=0.12, minval=0.02, maxval=0.50, step=0.01, group="Ehlers Engine", tooltip=alphaTip)
int   noiseLength       = input.int(title="Noise Length", defval=20, minval=2, group="Trend Defense", tooltip=noiseTip)
float bandMultiplier    = input.float(title="Defense Multiplier", defval=2.7, minval=0.2, step=0.1, group="Trend Defense", tooltip=bandTip)
int   atrLength         = input.int(title="ATR Length", defval=14, minval=1, group="Trend Defense", tooltip=atrTip)
float minimumATR        = input.float(title="Minimum ATR Distance", defval=0.8, minval=0.1, step=0.1, group="Trend Defense", tooltip=minimumTip)
float reversalStrength  = input.float(title="Reversal Override", defval=0.5, minval=0.0, step=0.1, group="Reversal Logic", tooltip=reversalTip)
bool  showEhlers        = input.bool(title="Show Ehlers Trendline", defval=true, group="Visualization", tooltip=ehlersTip)
bool  showTrigger       = input.bool(title="Show Ehlers Trigger", defval=false, group="Visualization", tooltip=triggerTip)
bool  showTrail         = input.bool(title="Show Trend Trail", defval=true, group="Visualization", tooltip=trailTip)
bool  showSignals       = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars         = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor         = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor        = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float a2 = alpha * alpha

float c0 = alpha - 0.25 * a2
float c1 = 0.50 * a2
float c2 = -(alpha - 0.75 * a2)
float c3 = 2.0 * (1.0 - alpha)
float c4 = -(1.0 - alpha) * (1.0 - alpha)

float seed = (src + 2.0 * nz(src[1], src) + nz(src[2], src)) / 4.0

var float instantTrend = na

if bar_index < 7
    instantTrend := seed
else
    instantTrend := c0 * src + c1 * nz(src[1], src) + c2 * nz(src[2], src) + c3 * nz(instantTrend[1], seed) + c4 * nz(instantTrend[2], seed)

float trigger       = 2.0 * instantTrend - nz(instantTrend[2], instantTrend)
float trendMomentum = trigger - instantTrend

float residual      = src - instantTrend
float residualPower = ta.rma(residual * residual, noiseLength)
float residualRMS   = math.sqrt(math.max(nz(residualPower, residual * residual), 0.0))

float atrValue = math.max(nz(ta.atr(atrLength), ta.tr(true)), syminfo.mintick)

float noiseDistance   = residualRMS * bandMultiplier
float minimumDistance = atrValue * minimumATR
float defenseDistance = math.max(noiseDistance, minimumDistance)

float bullishBoundary = instantTrend - defenseDistance
float bearishBoundary = instantTrend + defenseDistance

// SIGNALS
var int   SQ         = src >= instantTrend ? 1 : -1
var float trendTrail = na

int previousSQ = nz(SQ[1], SQ)

float initialTrail  = previousSQ == 1 ? src - defenseDistance : src + defenseDistance
float previousTrail = nz(trendTrail[1], initialTrail)

if previousSQ == 1
    trendTrail := math.max(previousTrail, bullishBoundary)
else
    trendTrail := math.min(previousTrail, bearishBoundary)

bool bearishMomentum = trendMomentum < 0.0
bool bullishMomentum = trendMomentum > 0.0

bool strongBearishBreak = src < instantTrend - atrValue * reversalStrength
bool strongBullishBreak = src > instantTrend + atrValue * reversalStrength

bool short = previousSQ == 1 and src < trendTrail and (bearishMomentum or strongBearishBreak)
bool long  = previousSQ == -1 and src > trendTrail and (bullishMomentum or strongBullishBreak)

if long
    SQ := 1
    trendTrail := math.min(bullishBoundary, src - minimumDistance)
else if short
    SQ := -1
    trendTrail := math.max(bearishBoundary, src + minimumDistance)
else
    SQ := previousSQ

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color regimeColor = SQ == 1 ? longColor : shortColor
color colors      = colorBars ? regimeColor : na

// PLOTS
plot(showEhlers ? instantTrend : na, title="Ehlers Instantaneous Trendline", color=color.new(regimeColor, 35), linewidth=2)
plot(showTrigger ? trigger : na, title="Ehlers Trigger", color=color.orange, linewidth=1)
plot(showTrail and SQ == 1 ? trendTrail : na, title="Bullish Trend Trail", color=longColor, linewidth=2, style=plot.style_linebr)
plot(showTrail and SQ == -1 ? trendTrail : na, title="Bearish Trend Trail", color=shortColor, linewidth=2, style=plot.style_linebr)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)
barcolor(colors, title = "Color Bars")
plotcandle(open, high, low, close, "Color Bars", colors, colors, bordercolor = colors, force_overlay = true)
plot(trendMomentum / atrValue, title="Normalized Ehlers Momentum", display=display.data_window)
plot(defenseDistance / atrValue, title="Defense Distance ATR", display=display.data_window)
plot(SQ, title="SQ Regime", display=display.data_window)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Ehlers Instant Trend LONG on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Ehlers Instant Trend SHORT on {{ticker}}")
````
