# Adaptive Breakout Oscillator [SchizoQuant]

- url: https://www.tradingview.com/script/DwkuitR1-Adaptive-Breakout-Oscillator-SchizoQuant/
- type: indicator
- pine_id: PUB;4ab384342b164016aac500299392d69b
- version: 1.0

## Description

[b]🟣Adaptive Breakout Oscillator[/b] is a multi-horizon directional-pressure indicator that combines completed price channels, compression-sensitive weighting, and adaptive confirmation thresholds to identify bullish and bearish trend regimes.

Instead of relying on a single breakout lookback or fixed threshold, the indicator evaluates short-, medium-, and long-term price structures and adjusts both their influence and the confirmation required for a directional reversal.

[b]🟣How It Works[/b]
[quote]The indicator combines three completed price channels to measure directional pressure across different structural horizons.

Each channel evaluates price relative to its midpoint and boundaries, producing a normalized pressure measurement between -1 and +1.

• Positive pressure indicates bullish structural positioning.
• Negative pressure indicates bearish structural positioning.
• Stronger displacement beyond a channel increases pressure toward its directional limit.

The three measurements are combined into a weighted consensus and scaled to an oscillator between -100 and +100.

Unlike a conventional fixed-threshold oscillator, the model adapts its weighting to structural compression and its confirmation requirements to disagreement between the three horizons.[/quote]

[b]🟣Compression-Aware Weighting[/b]
[quote]Each structural horizon receives an adaptive weight based on relative channel compression and directional pressure magnitude.

Channels that are compressed relative to their historical width receive greater influence, while stronger directional pressure increases the urgency component.

[pine]float shortUrgency = 0.5 + 0.5 * math.abs(shortPressure)
float shortWeight  = minimumWeight + (1.0 - minimumWeight) * shortCompression * shortUrgency[/pine]

The same calculation applies to the medium and long structures.

Minimum Weight prevents any horizon from losing all influence, while the final consensus normalizes their combined contributions.

This allows structurally compressed horizons to influence the oscillator without assigning permanently equal importance to every channel.[/quote]

[b]🟣Adaptive Confirmation Threshold[/b]
[quote]The indicator measures structural disagreement as the weighted deviation of each horizon's pressure from the combined consensus.

Greater disagreement increases the confirmation required for a regime reversal.

[pine]float adaptiveThreshold = baseThreshold + dispersion * thresholdAdaptation
adaptiveThreshold := math.max(baseThreshold, math.min(maximumThreshold, adaptiveThreshold))[/pine]

Base Threshold establishes the minimum confirmation requirement.

Disagreement Adaptation controls how strongly conflicting structures increase that requirement.

Maximum Threshold limits the upper confirmation boundary.

When the structural horizons agree, confirmation remains closer to its base level. When they conflict, the threshold can expand to demand stronger directional consensus.[/quote]

[b]🟣Signal Logic[/b]
[quote]LONG and SHORT markers identify changes in the indicator's persistent bullish or bearish breakout regime.

A reversal requires the oscillator to exceed the adaptive confirmation threshold in the opposing direction.

[pine]bool long  = oscillator > upperLevel
bool short = oscillator < lowerLevel

if long
    SQ := 1
else if short
    SQ := -1

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1[/pine]

A LONG condition requires:

• The oscillator to exceed the bullish confirmation level
• The internal regime to change from bearish to bullish

A SHORT condition requires:

• The oscillator to fall below the bearish confirmation level
• The internal regime to change from bullish to bearish

The previous regime persists until sufficient opposing pressure develops.

LONG and SHORT markers appear only when the internal regime changes, preventing repeated signals during an uninterrupted directional regime.[/quote]

[b]🟣Visual Feedback[/b]
[quote]The indicator displays a normalized pressure oscillator, adaptive bullish and bearish confirmation levels, and an optional shaded threshold region.

Individual short-, medium-, and long-term pressure components can also be displayed for comparison.

Neon green represents positive pressure and bullish conditions, while purple represents negative pressure and bearish conditions.

The oscillator follows current directional pressure, while optional candle coloring follows the persistent trend regime.

LONG and SHORT markers appear directly on the main price chart.

Additional pressure, compression, weighting, disagreement, and threshold measurements are available through TradingView's Data Window.[/quote]

[b]🟣User Controls[/b]
[quote]Users can configure the three structural lengths, compression memory, minimum adaptive weight, base threshold, disagreement adaptation, and maximum threshold.

Visualization controls manage confirmation levels, threshold fill, individual structural components, signals, and candle coloring.

Separate TradingView alerts are provided for LONG and SHORT regime transitions.

The indicator can be applied across different markets and chart timeframes, with responsiveness determined by the selected structural and confirmation settings.[/quote]

[b]🟣What Makes It Different[/b]
[quote]Adaptive Breakout Oscillator uses two complementary adaptation mechanisms:

• Adaptive weighting changes how strongly each structural horizon contributes to directional consensus.
• Adaptive confirmation changes how much opposing pressure is required when those horizons disagree.

Combining completed price structure, compression-sensitive weighting, and disagreement-based thresholds creates a directional regime framework that responds to both structural importance and structural agreement.

This distinguishes the model from a simple average of breakout measurements or an oscillator using permanently fixed confirmation levels.[/quote]

[b]🟣Intended Use[/b]
[quote]Adaptive Breakout Oscillator is designed for directional-pressure monitoring, multi-horizon breakout analysis, and trend-regime filtering.

It can help identify bullish and bearish structural conditions, evaluate agreement between different price horizons, and monitor potential directional reversals.

The oscillator and its confirmation levels can also provide additional context when used alongside an existing trading methodology.[/quote]

[b]🟣Limitations[/b]
[quote]Adaptive Breakout Oscillator is a structural-pressure and trend-regime indicator, not a complete trading system. LONG and SHORT markers identify changes in its internal regime and do not imply guaranteed trading outcomes or future performance.

During sideways or irregular markets, conflicting structural pressures may reduce directional consensus or generate repeated regime changes.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant
//@version=6
indicator("Adaptive Breakout Oscillator", overlay=false)

// USER INPUTS
string sourceTip      = "Choose the price source used to evaluate breakout pressure across the short, medium, and long completed market structures."
string lengthTip      = "Short, Medium, and Long Lengths define three completed breakout structures. Short structure reacts first, while longer structures represent progressively broader market breakouts. Lower values increase responsiveness, while higher values create slower structural measurements."
string compressionTip = "Measures each channel width against its own longer-term width. Breakouts from relatively compressed structures receive greater influence than breakouts from structures that are already expanded."
string weightTip      = "Minimum Weight prevents any structural horizon from losing all influence. Higher values distribute influence more evenly across the short, medium, and long structures, while lower values allow adaptive weighting to become more selective."
string thresholdTip   = "Base Threshold sets the minimum breakout consensus required to establish a directional regime. Higher values require stronger agreement before a regime change, while lower values increase sensitivity."
string adaptationTip  = "Controls how strongly disagreement between the three breakout structures increases the confirmation threshold. Higher values demand stronger consensus when the structural horizons conflict."
string maximumTip     = "Caps the adaptive confirmation threshold. Higher values allow disagreement to create a wider confirmation zone, while lower values limit how far the threshold can expand."
string thresholdsTip  = "Shows or hides the adaptive bullish and bearish confirmation levels. Disabling this option only affects the display and does not change calculations or signals."
string fillTip        = "Shows or hides the region between the adaptive bullish and bearish confirmation levels. Disabling this option only affects the display and does not change calculations or signals."
string membersTip     = "Shows or hides the individual short, medium, and long breakout-pressure components. Disabling this option only affects the display and does not change calculations or signals."
string signalsTip     = "Shows or hides LONG and SHORT markers when the persistent breakout regime changes. Disabling this option only affects the display and does not change calculations or signals."
string barsTip        = "Shows or hides candles colored according to the active bullish or bearish breakout regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip       = "Bullish Color represents positive breakout pressure, bullish regimes, and LONG signals, while Bearish Color represents negative breakout pressure, bearish regimes, and SHORT signals."

float src                 = input.source(title="Source", defval=close, group="Breakout Structure", tooltip=sourceTip)
int   shortLength         = input.int(title="Short Length", defval=10, minval=2, group="Breakout Structure", inline="S1", tooltip=lengthTip)
int   mediumLength        = input.int(title="Medium Length", defval=20, minval=3, group="Breakout Structure", inline="S1", tooltip=lengthTip)
int   longLength          = input.int(title="Long Length", defval=40, minval=4, group="Breakout Structure", inline="S1", tooltip=lengthTip)
int   compressionLength   = input.int(title="Compression Memory", defval=50, minval=5, group="Adaptive Weighting", tooltip=compressionTip)
float minimumWeight       = input.float(title="Minimum Weight", defval=0.15, minval=0.00, maxval=1.00, step=0.05, group="Adaptive Weighting", tooltip=weightTip)
float baseThreshold       = input.float(title="Base Threshold", defval=0.30, minval=0.05, maxval=0.90, step=0.05, group="Adaptive Threshold", inline="T1", tooltip=thresholdTip)
float thresholdAdaptation = input.float(title="Disagreement Adaptation", defval=0.40, minval=0.00, maxval=1.00, step=0.05, group="Adaptive Threshold", inline="T1", tooltip=adaptationTip)
float maximumThreshold    = input.float(title="Maximum Threshold", defval=0.65, minval=0.10, maxval=0.95, step=0.05, group="Adaptive Threshold", tooltip=maximumTip)
bool  showThresholds      = input.bool(title="Show Thresholds", defval=true, group="Visualization", tooltip=thresholdsTip)
bool  showFill            = input.bool(title="Show Threshold Fill", defval=true, group="Visualization", tooltip=fillTip)
bool  showMembers         = input.bool(title="Show Members", defval=false, group="Visualization", tooltip=membersTip)
bool  showSignals         = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars           = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor           = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor          = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
breakoutPressure(float source, float upper, float lower) =>
    float width     = math.max(upper - lower, syminfo.mintick)
    float midpoint  = (upper + lower) * 0.5
    float halfWidth = math.max(width * 0.5, syminfo.mintick)
    float position  = (source - midpoint) / halfWidth
    float pressure  = 0.0

    if position > 1.0
        float excess        = position - 1.0
        float boundedExcess = excess / (1.0 + math.abs(excess))
        pressure := 0.5 + 0.5 * boundedExcess
    else if position < -1.0
        float excess        = position + 1.0
        float boundedExcess = excess / (1.0 + math.abs(excess))
        pressure := -0.5 + 0.5 * boundedExcess
    else
        pressure := position * 0.5

    pressure

compressionScore(float currentWidth, float averageWidth) =>
    float ratio = currentWidth > 0.0 ? averageWidth / currentWidth : 1.0
    float score = ratio / (1.0 + ratio)
    math.max(0.0, math.min(1.0, score))

float shortHigh  = nz(ta.highest(high, shortLength)[1], high)
float shortLow   = nz(ta.lowest(low, shortLength)[1], low)
float shortWidth = math.max(shortHigh - shortLow, syminfo.mintick)

float mediumHigh  = nz(ta.highest(high, mediumLength)[1], high)
float mediumLow   = nz(ta.lowest(low, mediumLength)[1], low)
float mediumWidth = math.max(mediumHigh - mediumLow, syminfo.mintick)

float longHigh  = nz(ta.highest(high, longLength)[1], high)
float longLow   = nz(ta.lowest(low, longLength)[1], low)
float longWidth = math.max(longHigh - longLow, syminfo.mintick)

float shortPressure  = breakoutPressure(src, shortHigh, shortLow)
float mediumPressure = breakoutPressure(src, mediumHigh, mediumLow)
float longPressure   = breakoutPressure(src, longHigh, longLow)

float shortWidthBaseline  = ta.rma(shortWidth, compressionLength)
float mediumWidthBaseline = ta.rma(mediumWidth, compressionLength)
float longWidthBaseline   = ta.rma(longWidth, compressionLength)

float shortCompression  = compressionScore(shortWidth, shortWidthBaseline)
float mediumCompression = compressionScore(mediumWidth, mediumWidthBaseline)
float longCompression   = compressionScore(longWidth, longWidthBaseline)

float shortUrgency  = 0.5 + 0.5 * math.abs(shortPressure)
float mediumUrgency = 0.5 + 0.5 * math.abs(mediumPressure)
float longUrgency   = 0.5 + 0.5 * math.abs(longPressure)

float shortWeight  = minimumWeight + (1.0 - minimumWeight) * shortCompression * shortUrgency
float mediumWeight = minimumWeight + (1.0 - minimumWeight) * mediumCompression * mediumUrgency
float longWeight   = minimumWeight + (1.0 - minimumWeight) * longCompression * longUrgency
float totalWeight  = shortWeight + mediumWeight + longWeight

float breakoutConsensus = totalWeight > 0.0 ? (shortPressure * shortWeight + mediumPressure * mediumWeight + longPressure * longWeight) / totalWeight : 0.0
breakoutConsensus := math.max(-1.0, math.min(1.0, breakoutConsensus))

float dispersion = totalWeight > 0.0 ? (math.abs(shortPressure - breakoutConsensus) * shortWeight + math.abs(mediumPressure - breakoutConsensus) * mediumWeight + math.abs(longPressure - breakoutConsensus) * longWeight) / totalWeight : 0.0
dispersion := math.max(0.0, math.min(1.0, dispersion))

float adaptiveThreshold = baseThreshold + dispersion * thresholdAdaptation
adaptiveThreshold := math.max(baseThreshold, math.min(maximumThreshold, adaptiveThreshold))

float oscillator = breakoutConsensus * 100.0
float upperLevel = adaptiveThreshold * 100.0
float lowerLevel = -adaptiveThreshold * 100.0

float visualStrength = math.min(1.0, math.abs(oscillator) / 100.0)

int areaTransparency = int(math.round(82.0 - visualStrength * 32.0))
int fillTransparency = int(math.round(97.0 - visualStrength * 8.0))

// SIGNALS
bool long  = oscillator > upperLevel
bool short = oscillator < lowerLevel

var int SQ = oscillator >= 0.0 ? 1 : -1

if long
    SQ := 1
else if short
    SQ := -1

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color col       = SQ == 1 ? longColor : shortColor
color colors    = colorBars ? col : na
color pressCol  = oscillator >= 0.0 ? longColor : shortColor
color areaColor = color.new(pressCol, areaTransparency)

// PLOTS
plot(oscillator, title="Adaptive Breakout Pressure Area", style=plot.style_area, histbase=0.0, color=areaColor, linewidth=1)
plot(oscillator, title="Adaptive Breakout Pressure", color=pressCol, linewidth=1)
upperPlot = plot(showThresholds or showFill ? upperLevel : na, title="Bullish Confirmation", color=showThresholds ? color.new(longColor, 25) : na, linewidth=1)
lowerPlot = plot(showThresholds or showFill ? lowerLevel : na, title="Bearish Confirmation", color=showThresholds ? color.new(shortColor, 25) : na, linewidth=1)
fill(upperPlot, lowerPlot, title="Adaptive Threshold Fill", color=showFill ? color.new(col, fillTransparency) : na)
plot(0.0, title="Midpoint", color=color.new(pressCol, 55), linewidth=1)
plot(showMembers ? shortPressure * 100.0 : na, title="Short Breakout Pressure", color=color.new(pressCol, 50), linewidth=1)
plot(showMembers ? mediumPressure * 100.0 : na, title="Medium Breakout Pressure", color=color.new(pressCol, 68), linewidth=1)
plot(showMembers ? longPressure * 100.0 : na, title="Long Breakout Pressure", color=color.new(pressCol, 82), linewidth=1)
plot(shortPressure, title="Short Pressure", display=display.data_window)
plot(mediumPressure, title="Medium Pressure", display=display.data_window)
plot(longPressure, title="Long Pressure", display=display.data_window)
plot(shortCompression, title="Short Compression", display=display.data_window)
plot(mediumCompression, title="Medium Compression", display=display.data_window)
plot(longCompression, title="Long Compression", display=display.data_window)
plot(shortWeight / totalWeight, title="Short Adaptive Weight", display=display.data_window)
plot(mediumWeight / totalWeight, title="Medium Adaptive Weight", display=display.data_window)
plot(longWeight / totalWeight, title="Long Adaptive Weight", display=display.data_window)
plot(dispersion, title="Structural Disagreement", display=display.data_window)
plot(adaptiveThreshold, title="Adaptive Threshold", display=display.data_window)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white, force_overlay=true)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white, force_overlay=true)
barcolor(colors, title = "Color Bars")
plotcandle(open, high, low, close, "Color Bars", colors, colors, bordercolor = colors, force_overlay = true)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Adaptive Breakout Oscillator Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Adaptive Breakout Oscillator Short Signal on {{ticker}}")
````
