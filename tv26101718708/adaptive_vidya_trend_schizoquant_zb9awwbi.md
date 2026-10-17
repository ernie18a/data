# Adaptive VIDYA Trend [SchizoQuant]

- url: https://www.tradingview.com/script/Zb9AwWBi-Adaptive-VIDYA-Trend-SchizoQuant/
- type: indicator
- pine_id: PUB;240ca427df1c48b682ae46527590301b
- version: 1.0

## Description

[b]🟣Adaptive VIDYA Trend[/b] is an adaptive trend-regime indicator that uses a volatility-responsive moving average together with residual-volatility bands to identify persistent bullish and bearish market states.

Instead of using a fixed smoothing rate, the indicator adjusts the responsiveness of VIDYA according to the relationship between short-term and long-term volatility.

When short-term volatility becomes stronger relative to the longer-term reference, VIDYA can respond more quickly to movement in the selected source.

When short-term volatility is weaker relative to the longer-term reference, the smoothing rate decreases and VIDYA reacts more gradually.

Adaptive bands built from the statistical dispersion of the selected source around VIDYA are then used to determine when the active trend regime changes.

[b]🟣✦ How It Works[/b]

[quote]The calculation follows this structure:

Short-Term Source Volatility  
↓  
Long-Term Source Volatility  
↓  
Volatility Ratio  
↓  
Adaptive VIDYA Smoothing  
↓  
Source-to-VIDYA Residual  
↓  
Residual Deviation  
↓  
Adaptive Upper / Lower Bands  
↓  
Persistent Bullish / Bearish Regime

The indicator first compares short-term and long-term standard deviation.

This relationship determines how aggressively VIDYA responds to the selected source.

The resulting VIDYA is then used as the central reference for measuring source displacement and constructing the adaptive trend bands.[/quote]

[b]🟣✦ Volatility Ratio[/b]

[quote]The adaptive behavior begins with two volatility measurements.

Short Deviation Length → Measures recent short-term dispersion.

Long Deviation Length → Provides the broader volatility reference.

The script calculates both standard deviations and divides the short-term value by the long-term value:

[pine]float shortDeviation = ta.stdev(src, shortLen)
float longDeviation  = ta.stdev(src, longLen)

float k = longDeviation > 0.0 ? shortDeviation / longDeviation : 0.0[/pine]

This produces the VIDYA Volatility Ratio.

A higher ratio indicates that recent volatility is elevated relative to the longer-term environment.

A lower ratio indicates that recent volatility is subdued relative to the longer-term reference.[/quote]

[b]🟣✦ Adaptive VIDYA Smoothing[/b]

[quote]The volatility ratio is multiplied by the selected Base Smoothing value.

The resulting adaptive smoothing factor is then constrained between 0 and 1:

[pine]float adaptiveSmoothing = k * baseSmoothing
adaptiveSmoothing := math.max(0.0, math.min(1.0, adaptiveSmoothing))[/pine]

That value determines how much weight the recursive VIDYA calculation gives to the current source relative to its previous value:

[pine]var float vidya = na
vidya := na(vidya[1]) ? src : adaptiveSmoothing * src + (1.0 - adaptiveSmoothing) * vidya[1][/pine]

Higher adaptive smoothing places more weight on the current source value.

Lower adaptive smoothing places more weight on the previous VIDYA value.

This allows the centerline to change its responsiveness as the relationship between short-term and long-term volatility changes.[/quote]

[b]🟣✦ Price Residual[/b]

[quote]After calculating VIDYA, the indicator measures the difference between the selected source and the adaptive centerline:

[pine]float residual = src - vidya[/pine]

This value is called the residual.

Positive residual values indicate that the selected source is above VIDYA.

Negative residual values indicate that the selected source is below VIDYA.

The magnitude and variability of these residuals provide a direct measurement of how widely the selected source has recently been moving around the adaptive trend baseline.[/quote]

[b]🟣✦ Residual Volatility Bands[/b]

[quote]The standard deviation of the residual is calculated over the selected Band Length:

[pine]float residualDeviation = ta.stdev(residual, bandLength)[/pine]

That residual deviation is multiplied independently by the Upper Band Multiplier and Lower Band Multiplier to construct the two adaptive boundaries around VIDYA:

[pine]float upperBand = vidya + residualDeviation * upperMultiplier
float lowerBand = vidya - residualDeviation * lowerMultiplier[/pine]

Upper Band → VIDYA + Residual Deviation × Upper Band Multiplier

Lower Band → VIDYA − Residual Deviation × Lower Band Multiplier

Because the bands are based on the dispersion of the selected source around VIDYA, their distance naturally changes as residual volatility expands or contracts.

Higher residual volatility produces wider bands.

Lower residual volatility produces narrower bands.

The two independent multipliers also allow bullish and bearish regime-change thresholds to be configured asymmetrically.[/quote]

[b]🟣✦ Trend Regime[/b]

[quote]The indicator maintains a persistent bullish or bearish trend regime.

The raw directional conditions are defined by the selected source moving outside the adaptive bands:

[pine]bool long  = src > upperBand
bool short = src < lowerBand[/pine]

The internal regime is initialized from the relationship between the selected source and VIDYA:

[pine]var int SQ = src >= vidya ? 1 : -1[/pine]

A move above the upper band changes the regime to bullish.

A move below the lower band changes the regime to bearish.

[pine]if long
    SQ := 1
else if short
    SQ := -1[/pine]

When the selected source remains between the two bands, neither condition is triggered and the previous regime is preserved.

This creates a persistent state rather than repeatedly switching direction whenever the selected source moves around the VIDYA centerline.[/quote]

[b]🟣✦ Regime Transitions[/b]

[quote]LONG and SHORT markers identify changes in the internal trend regime rather than every bar that remains bullish or bearish.

The transition logic is:

[pine]bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1[/pine]

LONG → The internal regime has changed into the bullish state.

SHORT → The internal regime has changed into the bearish state.

Once a regime is established, another signal is not generated until the opposite band condition causes the internal state to reverse.

This separates regime-change events from the persistent bullish or bearish state that follows them.[/quote]

[b]🟣✦ Visual Feedback[/b]

[quote]The active regime determines the primary chart color:

[pine]color col = SQ == 1 ? longColor : shortColor[/pine]

Neon Green → Bullish regime

Purple → Bearish regime

The Adaptive VIDYA centerline uses the active regime color.

Optional upper and lower adaptive bands show the current residual-volatility boundaries around VIDYA.

An optional fill between the bands provides additional visual emphasis for the active regime.

LONG and SHORT markers identify regime transitions.

Optional candle coloring makes the current bullish or bearish state immediately visible on the price chart.[/quote]

[b]🟣✦ Data Window Metrics[/b]

[quote]Several internal values are exposed through the TradingView Data Window:

VIDYA Volatility Ratio

VIDYA Adaptive Smoothing

Price VIDYA Residual

Residual Deviation

The script makes these values available without plotting them directly on the visible chart:

[pine]plot(k, title="VIDYA Volatility Ratio", display=display.data_window)
plot(adaptiveSmoothing, title="VIDYA Adaptive Smoothing", display=display.data_window)
plot(residual, title="Price VIDYA Residual", display=display.data_window)
plot(residualDeviation, title="Residual Deviation", display=display.data_window)[/pine]

These measurements provide additional visibility into how the moving average and adaptive bands are responding to current market conditions.[/quote]

[b]🟣✦ User Controls[/b]

[quote]Source → Selects the price series used throughout the adaptive calculation and regime logic.

Short Deviation Length → Controls the short-term volatility measurement used in the VIDYA ratio.

Long Deviation Length → Controls the longer-term volatility reference used in the VIDYA ratio.

Base Smoothing → Controls the base responsiveness of VIDYA before volatility adaptation is applied.

Band Length → Controls how much residual history is used to estimate dispersion around VIDYA.

Upper Band Multiplier → Controls the residual-deviation distance above VIDYA. Higher values require greater upward displacement before the regime can change bullish.

Lower Band Multiplier → Controls the residual-deviation distance below VIDYA. Higher values require greater downward displacement before the regime can change bearish.

Visualization settings allow the bands, band fill, regime-change signals, and candle coloring to be independently displayed or hidden without changing the underlying calculations.[/quote]

[b]🟣✦ Intended Use[/b]

[quote]Adaptive VIDYA Trend is designed for identifying persistent directional regimes while adapting both its trend baseline and reversal boundaries to changing market behavior.

It can be used as:

A standalone trend-state indicator

A directional trend filter

An adaptive moving-average framework

A confirmation layer for systematic strategies

A regime filter for identifying sustained bullish or bearish conditions

A visual framework for evaluating source displacement relative to an adaptive trend baseline[/quote]

[b]🟣✦ Limitations[/b]

[quote]Adaptive VIDYA Trend is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

The responsiveness of VIDYA depends on the relationship between short-term and long-term volatility, so rapid changes in volatility can materially alter the smoothing rate.

The adaptive bands depend on the historical dispersion of the selected source around VIDYA. Wider residual volatility can delay regime changes, while narrower residual volatility can make the regime more sensitive to source displacement.

The Upper Band Multiplier and Lower Band Multiplier independently affect bullish and bearish reversal sensitivity. Higher values require larger displacement on the corresponding side of VIDYA before the regime changes, while lower values create tighter thresholds. Using different upper and lower values creates asymmetric regime sensitivity.

The selected source, volatility lengths, smoothing factor, and residual-band settings can materially change the behavior of the indicator.

The script does not use higher-timeframe requests or lookahead logic.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Adaptive VIDYA Trend", overlay=true)

// USER INPUTS
string shortTip      = "Sets the short-term standard deviation lookback used in the VIDYA volatility ratio. Lower values make the adaptive response more sensitive to recent volatility."
string longTip       = "Sets the long-term standard deviation lookback used as the reference volatility in the VIDYA adaptation ratio. Higher values create a slower volatility reference."
string smoothingTip  = "Sets the base smoothing factor multiplied by the short-to-long volatility ratio. Higher values make VIDYA respond faster to price changes."
string bandTip       = "Sets the lookback used to measure the standard deviation of price displacement from VIDYA. Higher values create a steadier estimate of residual volatility."
string multiplierTip = "Upper Band Multiplier controls the residual-deviation distance above VIDYA, while Lower Band Multiplier controls the distance below it. Higher values widen the corresponding side and require stronger price displacement before the trend regime changes."
string bandsTip      = "Shows or hides the adaptive upper and lower VIDYA bands. Disabling this option only affects the display and does not change calculations or signals."
string fillTip       = "Shows or hides the colored area between the adaptive VIDYA bands. Disabling this option only affects the display and does not change calculations or signals."
string signalsTip    = "Shows or hides LONG and SHORT markers when the active trend regime changes. Disabling this option only affects the display and does not change signal calculations."
string barsTip       = "Colors price candles according to the active bullish or bearish trend regime. Disabling this option only affects the display and does not change calculations or signals."
string colorTip      = "Bullish Color represents bullish trend regimes and LONG signals, while Bearish Color represents bearish regimes and SHORT signals."

float src             = input.source(title="Source", defval=close, group="VIDYA Settings", tooltip="Choose the price source used by the adaptive VIDYA calculation, residual measurement, bands, and regime logic.")
int   shortLen        = input.int(title="Short Deviation Length", defval=10, minval=2, group="VIDYA Settings", inline="V1", tooltip=shortTip)
int   longLen         = input.int(title="Long Deviation Length", defval=30, minval=3, group="VIDYA Settings", inline="V1", tooltip=longTip)
float baseSmoothing   = input.float(title="Base Smoothing", defval=0.20, minval=0.01, maxval=1.00, step=0.01, group="VIDYA Settings", tooltip=smoothingTip)
int   bandLength      = input.int(title="Band Length", defval=20, minval=2, group="Adaptive Bands", tooltip=bandTip)
float upperMultiplier = input.float(title="Upper Band Multiplier", defval=1.50, minval=0.10, step=0.10, group="Adaptive Bands", inline="B1", tooltip=multiplierTip)
float lowerMultiplier = input.float(title="Lower Band Multiplier", defval=1.50, minval=0.10, step=0.10, group="Adaptive Bands", inline="B1", tooltip=multiplierTip)
bool  showBands       = input.bool(title="Show Bands", defval=true, group="Visualization", tooltip=bandsTip)
bool  showFill        = input.bool(title="Show Fill", defval=true, group="Visualization", tooltip=fillTip)
bool  showSignals     = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip=signalsTip)
bool  colorBars       = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip=barsTip)
color longColor       = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="COL1", tooltip=colorTip)
color shortColor      = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="COL1", tooltip=colorTip)

// CALCULATIONS
float shortDeviation = ta.stdev(src, shortLen)
float longDeviation  = ta.stdev(src, longLen)

float k = longDeviation > 0.0 ? shortDeviation / longDeviation : 0.0

float adaptiveSmoothing = k * baseSmoothing
adaptiveSmoothing := math.max(0.0, math.min(1.0, adaptiveSmoothing))

var float vidya = na
vidya := na(vidya[1]) ? src : adaptiveSmoothing * src + (1.0 - adaptiveSmoothing) * vidya[1]

float residual          = src - vidya
float residualDeviation = ta.stdev(residual, bandLength)

float upperBand = vidya + residualDeviation * upperMultiplier
float lowerBand = vidya - residualDeviation * lowerMultiplier

// SIGNALS
bool long  = src > upperBand
bool short = src < lowerBand

var int SQ = src >= vidya ? 1 : -1

if long
    SQ := 1
else if short
    SQ := -1

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color col = SQ == 1 ? longColor : shortColor

// PLOTS
plot(vidya, title="Adaptive VIDYA", color=col, linewidth=3)
upperPlot = plot(showBands ? upperBand : na, title="Upper Adaptive Band", color=color.new(longColor, 65), linewidth=1)
lowerPlot = plot(showBands ? lowerBand : na, title="Lower Adaptive Band", color=color.new(shortColor, 65), linewidth=1)
fill(upperPlot, lowerPlot, color=showFill ? color.new(col, 90) : na, title="Adaptive Trend Fill")
plot(k, title="VIDYA Volatility Ratio", display=display.data_window)
plot(adaptiveSmoothing, title="VIDYA Adaptive Smoothing", display=display.data_window)
plot(residual, title="Price VIDYA Residual", display=display.data_window)
plot(residualDeviation, title="Residual Deviation", display=display.data_window)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Adaptive VIDYA Trend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Adaptive VIDYA Trend Short Signal on {{ticker}}")
````
