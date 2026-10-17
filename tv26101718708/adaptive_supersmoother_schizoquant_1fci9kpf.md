# Adaptive SuperSmoother [SchizoQuant]

- url: https://www.tradingview.com/script/1FcI9kpF-Adaptive-SuperSmoother-SchizoQuant/
- type: indicator
- pine_id: PUB;4020700546084ebda118a9269b187972
- version: 1.0

## Description

[b]🟣Adaptive SuperSmoother[/b] is a trend-regime indicator that combines a volatility-adaptive moving average, an Ehlers-style SuperSmoother filter, directional-efficiency weighting, and a noise-adjusted slope threshold.

The indicator adapts both its responsiveness and its filtering behavior to changing market conditions. Volatility determines the effective moving-average period, directional efficiency determines the balance between the faster adaptive component and the smoother filtered component, and the final trend slope must exceed an adaptive noise threshold before the internal directional regime changes.

[b]🟣✦ How It Works[/b]

[b]🟣Volatility-Adaptive Moving Average[/b]

[quote]The first stage measures the standard deviation of price changes and compares current volatility with a dynamically calculated volatility range.

Higher volatility reduces the effective moving-average period toward the Minimum MA Period, increasing responsiveness. Lower volatility increases the effective period toward the Maximum MA Period, creating smoother tracking.

[pine]
float adaptiveLength = s <= sMin ? maMax : s >= sMax ? maMin : maMax - (maMax - maMin) * volatilityPosition
float alpha          = 2.0 / (adaptiveLength + 1.0)
[/pine]

The resulting smoothing factor is applied recursively to create the adaptive moving average rather than switching between several fixed averages.[/quote]

[b]🟣SuperSmoother Filter[/b]

[quote]The volatility-adaptive moving average is then passed through a two-pole SuperSmoother-style recursive filter.

This produces a more heavily filtered version of the adaptive trend component, allowing the indicator to combine responsiveness with additional smoothing rather than relying on either characteristic alone.[/quote]

[b]🟣Directional Efficiency[/b]

[quote]Directional efficiency compares the net distance traveled by the selected source with the total path traveled over the Efficiency Length.

A reading closer to 1 represents cleaner directional movement, while a reading closer to 0 represents a more irregular or noisy price path.

This measurement is used as a dynamic weighting mechanism rather than as a standalone signal.[/quote]

[b]🟣Adaptive Filter Blend[/b]

[quote]Directional efficiency controls how much influence is assigned to the faster adaptive moving average versus the slower SuperSmoother.

As efficiency increases, the indicator favors the responsive adaptive component. As efficiency decreases, more weight shifts toward the smoother filtered component.

[pine]
float fastWeight = fastBias + (1.0 - fastBias) * efficiency
float slowWeight = 1.0 - fastWeight
float trend      = adaptiveMA * fastWeight + smoothMA * slowWeight
[/pine]

Minimum Fast Weight establishes the minimum contribution of the responsive adaptive-average component. Higher values preserve more responsiveness during inefficient conditions, while lower values allow the SuperSmoother to exert greater influence.[/quote]

[b]🟣Noise-Adaptive Trend Threshold[/b]

[quote]The final blended trend is evaluated through its slope.

Instead of treating every small positive or negative slope change as meaningful, the indicator measures the recent average magnitude of slope movement and converts it into an adaptive threshold.

[pine]
float slope      = trend - trend[1]
float slopeNoise = ta.rma(math.abs(slope), noiseLength)
float threshold  = slopeNoise * noiseMult
[/pine]

A bullish condition requires the trend slope to exceed the positive threshold, while a bearish condition requires it to move below the negative threshold.

This helps suppress minor fluctuations that would otherwise cause unnecessary directional changes.[/quote]

[b]🟣Signal Logic[/b]

[quote]Bullish and bearish conditions are determined by comparing the final trend slope with its adaptive noise threshold.

[pine]
bool long  = slope > threshold
bool short = slope < -threshold
[/pine]

Once a directional condition becomes active, the indicator maintains that internal regime until the opposite condition is established.

LONG and SHORT markers are displayed only when the internal regime changes, rather than on every bar that remains bullish or bearish.[/quote]

[b]🟣Visual Feedback[/b]

[quote]The Adaptive SuperSmoother Trend line changes between the selected bullish and bearish colors according to the active directional regime.

Optional LONG and SHORT markers identify changes between bullish and bearish states.

When Color Bars is enabled, price candles are also colored using the active regime color.

Disabling Show Signals or Color Bars only changes the chart presentation and does not alter the underlying calculations or signal logic.
[/quote]

[b]🟣Data Window Metrics[/b]

[quote]Several internal components are available through TradingView's Data Window for additional analysis:

• Adaptive MA
• SuperSmoothed MA
• Efficiency Ratio
• Fast Filter Weight

These values allow users to inspect how volatility and directional efficiency are influencing the adaptive filtering process.[/quote]

[b]🟣User Controls[/b]

[quote]The indicator provides controls for:

• Source
• Minimum and Maximum MA Period
• Volatility Period
• SuperSmoother Length
• Efficiency Length
• Minimum Fast Weight
• Noise Length
• Noise Multiplier
• Signal visibility
• Candle coloring
• Bullish and bearish colors[/quote]

[b]🟣Alerts[/b]

[quote]Separate TradingView alert conditions are provided for bullish and bearish directional changes.

The LONG alert is triggered when the indicator enters its bullish regime, while the SHORT alert is triggered when it enters its bearish regime.[/quote]

[b]🟣Intended Use[/b]

[quote]Adaptive SuperSmoother is designed for identifying directional market regimes while adapting both responsiveness and noise filtering to changing market conditions.

It can be used to:

• Identify bullish and bearish trend conditions
• Highlight directional regime changes
• Filter minor slope fluctuations
• Adjust moving-average responsiveness according to volatility
• Adapt smoothing according to directional efficiency
• Provide a trend overlay for discretionary or systematic analysis[/quote]

[b]🟣Limitations[/b]

[quote]Adaptive SuperSmoother is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

The adaptive moving-average response depends on the relationship between current and recent price-change volatility. Sudden changes in volatility can therefore alter the effective smoothing period.

Directional efficiency affects the weighting between the adaptive moving average and SuperSmoother, so irregular price movement can intentionally increase the influence of the slower filtered component.

Noise Length and Noise Multiplier directly affect how much slope movement is required before the regime can change. Higher filtering thresholds generally reduce sensitivity, while lower thresholds allow more frequent directional changes.

Minimum Fast Weight controls the lowest possible contribution of the responsive adaptive-average component. When set to zero, that component can receive zero weight when directional efficiency reaches zero.

The script does not request higher-timeframe data and does not use lookahead logic.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Adaptive SuperSmoother", overlay=true)

// USER INPUTS
string adaptTip   = "Adapts the moving-average period to price-change volatility. Higher volatility shortens the effective period for faster response while lower volatility lengthens it for smoother tracking."
string filterTip  = "Applies an Ehlers SuperSmoother to the adaptive moving average. The final trend dynamically blends the responsive adaptive line with this smoother version."
string erTip      = "Measures directional efficiency. Clean directional movement gives more weight to the faster adaptive MA while noisy movement gives more weight to the SuperSmoother."
string signalTip  = "Uses the trend slope and a small adaptive noise threshold to prevent insignificant movements from repeatedly changing the internal trend regime."
string signalsTip = "Shows or hides LONG and SHORT markers when the internal trend regime changes. Disabling this option only affects the display and does not change signal calculations."
string barsTip    = "Shows or hides price candles colored according to the active bullish or bearish trend regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip   = "Bullish Color represents the active bullish trend regime while Bearish Color represents the active bearish trend regime."

float src          = input.source(title="Source", defval=close, group="Adaptive MA Settings", tooltip="Choose the price source used throughout the indicator.")
int   maMin        = input.int(title="Minimum MA Period", defval=14, minval=1, group="Adaptive MA Settings", inline="A1", tooltip=adaptTip)
int   maMax        = input.int(title="Maximum MA Period", defval=50, minval=2, group="Adaptive MA Settings", inline="A1", tooltip=adaptTip)
int   volLen       = input.int(title="Volatility Period", defval=9, minval=2, group="Adaptive MA Settings", tooltip=adaptTip)
int   smoothLength = input.int(title="SuperSmoother Length", defval=3, minval=3, group="Filter Settings", tooltip=filterTip)
int   erLength     = input.int(title="Efficiency Length", defval=10, minval=2, group="Efficiency Settings", tooltip=erTip)
float fastBias     = input.float(title="Minimum Fast Weight", defval=0.30, minval=0.0, maxval=1.0, step=0.05, group="Efficiency Settings", tooltip="Sets the minimum contribution of the responsive adaptive MA during noisy conditions. Increase it to keep more of the faster adaptive response or decrease it to favor the SuperSmoother more strongly.")
int   noiseLength  = input.int(title="Noise Length", defval=20, minval=2, group="Signal Settings", inline="S1", tooltip=signalTip)
float noiseMult    = input.float(title="Noise Multiplier", defval=0.60, minval=0.0, step=0.05, group="Signal Settings", inline="S1", tooltip=signalTip)
bool  showSignals  = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars    = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor    = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor   = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float deltaP = src - src[1]
float s      = ta.stdev(deltaP, volLen)
float sMean  = ta.sma(s, volLen)

float sMin = sMean * 0.25
float sMax = sMean * 1.75

float volatilityRange    = sMax - sMin
float volatilityPosition = volatilityRange > 0.0 ? math.max(0.0, math.min(1.0, (s - sMin) / volatilityRange)) : 0.0

float adaptiveLength = s <= sMin ? maMax : s >= sMax ? maMin : maMax - (maMax - maMin) * volatilityPosition
float alpha          = 2.0 / (adaptiveLength + 1.0)

var float adaptiveMA = na
adaptiveMA := na(adaptiveMA[1]) ? src : adaptiveMA[1] + alpha * (src - adaptiveMA[1])

float a1 = math.exp(-1.414 * math.pi / smoothLength)
float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / smoothLength)
float c2 = b1
float c3 = -a1 * a1
float c1 = 1.0 - c2 - c3

var float smoothMA = na
smoothMA := na(smoothMA[1]) or na(smoothMA[2]) ? adaptiveMA : c1 * (adaptiveMA + nz(adaptiveMA[1], adaptiveMA)) * 0.5 + c2 * smoothMA[1] + c3 * smoothMA[2]

float direction = math.abs(src - nz(src[erLength], src))
float noise     = 0.0

for i = 0 to erLength - 1
    noise += math.abs(nz(src[i], src) - nz(src[i + 1], src))

float efficiency = noise > 0.0 ? direction / noise : 0.0
efficiency := math.max(0.0, math.min(1.0, efficiency))

float fastWeight = fastBias + (1.0 - fastBias) * efficiency
float slowWeight = 1.0 - fastWeight
float trend      = adaptiveMA * fastWeight + smoothMA * slowWeight

float slope      = trend - trend[1]
float slopeNoise = ta.rma(math.abs(slope), noiseLength)
float threshold  = slopeNoise * noiseMult

// SIGNALS
bool long  = slope > threshold
bool short = slope < -threshold

var int SQ = 0

if long
    SQ := 1
else if short
    SQ := -1

bool longSignal  = SQ == 1 and SQ[1] != 1
bool shortSignal = SQ == -1 and SQ[1] != -1

// COLORS
color col    = SQ == 1 ? longColor : shortColor
color colors = colorBars ? col : na

// PLOTS
plot(trend, title="Adaptive SuperSmoother Trend", color=col, linewidth=2)
plot(adaptiveMA, title="Adaptive MA", display=display.data_window)
plot(smoothMA, title="SuperSmoothed MA", display=display.data_window)
plot(efficiency, title="Efficiency Ratio", display=display.data_window)
plot(fastWeight, title="Fast Filter Weight", display=display.data_window)

plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)

barcolor(colors, title = "Plot Bars")
plotcandle(open, high, low, close, "Plot Bars", colors, colors, bordercolor = colors, force_overlay = true)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Adaptive SuperSmoother Trend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Adaptive SuperSmoother Trend Short Signal on {{ticker}}")
````
