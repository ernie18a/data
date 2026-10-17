# Uptrick: Liquid Reversal Bands

- url: https://www.tradingview.com/script/NkOJyPWb-Uptrick-Liquid-Reversal-Bands/
- type: indicator
- pine_id: PUB;c4cef8550e5b4f83957f35e83421681f
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Liquid Reversal Bands is an overlay indicator designed to help traders identify dynamic support and resistance zones, detect mean-reversion opportunities, and read price position within a volatility-aware envelope. Rather than using fixed standard deviation bands around a single moving average, this system builds its band width from multiple volatility components simultaneously, creating a more adaptive and stable envelope that responds to changing market conditions without overreacting to short-term noise. The candle coloring, fair value line, and band fills all carry live visual information, making it possible to assess market state and recent signal context at a glance without needing additional tools on the chart.

[b][i]How It Works[/i][/b]
The centerline, referred to as the Liquid Fair Value, is computed by blending an EMA and an ALMA with a fixed offset and phase bias, then applying a secondary smoothing pass. This produces a centerline that is faster than a plain EMA but more stable than a raw ALMA, reducing lag while avoiding erratic pivots.

Band width is calculated from four volatility components: the standard deviation of price deviation from the fair value, a standard ATR reading, an EMA of absolute deviation, and an EMA of bar range energy. These four components are weighted and blended into a single composite width value that is then smoothed again before being applied to the upper and lower bands. This approach means the bands widen during high-volatility conditions driven by any combination of momentum, range expansion, or sustained deviation, rather than relying on a single measure that may miss one type of volatility while overreacting to another.

Reversal signals are generated when price closes back inside a band after having closed outside it on the prior bar. This close-crossing logic filters out brief wicks and requires a confirmed return into the envelope before triggering. An optional cooldown parameter prevents back-to-back signals within a defined number of bars.

Candle coloring operates in two selectable modes. In Reversal Heat mode, candles are colored continuously based on their real-time position within the band range, shifting from the bullish teal near the lower band to the bearish magenta near the upper band, with a full gradient in between. In Latest Signal mode, all candles take the solid color of the most recent confirmed signal direction, holding that color until the opposite signal fires. This mode is useful for traders who want a persistent visual reminder of the current signal bias rather than a moment-to-moment position readout.

The fair value line uses a separate slope-based gradient that transitions between bull and bear color depending on the direction and smoothed magnitude of the centerline trend. Optional outer bands extend beyond the primary envelope and can be enabled to identify extreme extension zones.

[b][i]Baseline Design Rationale[/i][/b]
The Liquid Fair Value uses EMA and ALMA specifically because they address opposite weaknesses. A standard EMA is computationally stable and reacts smoothly to recent price but carries lag from its uniform weighting. ALMA uses a Gaussian-weighted kernel that concentrates sensitivity toward recent bars while suppressing older data, which reduces lag but can introduce instability on sharp reversals. Blending the two captures the smoothness and stability of the EMA alongside the reduced lag of the ALMA, producing a centerline that neither drags excessively in trends nor overreacts to brief spikes. The secondary EMA pass applied afterward further damps any residual instability from the ALMA component without reintroducing significant lag.

[b][i]Features[/i][/b]
[list]
[*] Liquid Fair Value centerline blending EMA and ALMA with dual-pass smoothing for a stable yet responsive mid-line
[*] Composite band width derived from four volatility sources: deviation standard deviation, ATR, absolute deviation EMA, and bar range energy EMA
[*] Primary upper and lower bands with independent multiplier controls
[*] Optional outer bands for identifying extreme price extension, each with its own multiplier
[*] Candle Coloring Mode selector with two options: Reversal Heat for continuous gradient coloring based on live band position, and Latest Signal for persistent directional coloring based on the most recent confirmed signal
[*] Slope-based gradient coloring on the fair value line, transitioning between bullish and bearish color depending on trend direction and strength
[*] Slope sensitivity and smoothing controls to tune how quickly the fair value line color responds to directional changes
[*] Close-crossing reversal signals that trigger only when price re-enters a band after a confirmed close outside it
[*] Configurable signal cooldown to space out signals and reduce repetitive triggers in choppy conditions
[*] Gradient band fills between the fair value and upper and lower bands using directional color transparency
[*] Outer band fills rendered separately with their own transparency layer when enabled
[*] Alert conditions for both buy and sell signals
[/list]

[b][i]Inputs[/i][/b]
[list]
[*]Source: The price series used for all calculations. Defaults to close.
[*]Fair Value Length: Controls the lookback period for both the EMA and ALMA that form the Liquid Fair Value centerline. Higher values produce a smoother and slower centerline.
[*]Z-Width Lookback: The lookback window used to compute deviation standard deviation and absolute deviation mean. Larger values stabilize band width but reduce responsiveness to recent volatility shifts.
[*]Band Smoothness: Controls the final EMA smoothing applied to the composite band width. Higher values produce wider, more stable bands.
[*]Upper Band Multiplier and Lower Band Multiplier: Scale the upper and lower band distances from the fair value independently. Higher values push the bands further out, producing fewer signal triggers.
[*]Outer Upper Band Multiplier and Outer Lower Band Multiplier: Applied on top of the primary multipliers to define the outer band distance. Only visible when outer bands are enabled.
[*]Candle Coloring Mode: Selects how candles are colored. Reversal Heat maps each candle continuously to its current position within the band range. Latest Signal holds the color of the most recent confirmed buy or sell signal until the opposite signal fires.
[*]Show Signals: Toggle to enable or disable reversal signal labels on the chart.
[*]Signal Cooldown: Minimum number of bars that must pass between consecutive signals. Set to zero to allow signals on every qualifying bar.
[*]Show Outer Bands: Toggle to enable or disable the outer band plots and their fills.
[*]Slope Smoothing Length: Controls how many bars are used to smooth the fair value slope before it is mapped to a color. Lower values make the line color react faster to direction changes.
[*]Slope Color Sensitivity: Scales how aggressively the slope magnitude maps to the color gradient. Lower values cause the line to reach full bull or bear color more quickly.
[/list]

[b][i]Originality[/i][/b]
Most band-based indicators derive their width from a single volatility measure, typically standard deviation or ATR alone. Liquid Reversal Bands constructs its width from a weighted blend of four distinct volatility inputs, each capturing a different aspect of market activity. The additional smoothing hierarchy applied to both the centerline and the width ensures that bands expand and contract in a measured way rather than spiking on single-bar outliers. The dual candle coloring system offers two meaningfully different visual modes: one that reflects continuous real-time price positioning within the envelope, and one that reflects confirmed signal direction as a persistent state, giving traders a choice between positional awareness and signal context depending on their preference. The slope gradient on the fair value line is driven by a normalized and smoothed slope calculation, making it resistant to brief direction changes while still reflecting genuine trend shifts.

[b][i]Conclusion[/i][/b]
Liquid Reversal Bands is built for traders who want a mean-reversion and trend context tool that adapts to volatility through multiple lenses simultaneously. The composite width model, the selectable candle coloring modes, and the close-crossing signal logic together produce a system designed for clarity, stability, and honest visual representation of price state within the envelope.

[quote]Disclaimer
This indicator is published for educational and analytical purposes only. It does not constitute financial advice. Past behavior of any indicator does not guarantee future results. Always apply your own analysis and risk management before making any trading decisions.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0) 
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick
//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝ 
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗ 
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝

indicator("Uptrick: Liquid Reversal Bands", shorttitle="LRB", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpCore = "Core Settings"

src             = input.source(close, "Source", group=grpCore)
fairLen         = input.int(50, "Fair Value Length", minval=1, group=grpCore)
zLen            = input.int(100, "Z-Width Lookback", minval=10, group=grpCore)
smoothLen       = input.int(18, "Band Smoothness", minval=1, group=grpCore)

upperMult       = input.float(2.4, "Upper Band Multiplier", step=0.1, group=grpCore)
lowerMult       = input.float(2.4, "Lower Band Multiplier", step=0.1, group=grpCore)

outerUpperMult  = input.float(1.45, "Outer Upper Band Multiplier", step=0.05, group=grpCore)
outerLowerMult  = input.float(1.45, "Outer Lower Band Multiplier", step=0.05, group=grpCore)

grpSignals = "Signals"

enableSignals   = input.bool(true, "Show Signals", group=grpSignals)
cooldownBars    = input.int(0, "Signal Cooldown", minval=0, group=grpSignals)

grpVisual = "Visuals"

candleMode = input.string("Reversal Heat", "Candle Coloring Mode", options=[
     "Reversal Heat",
     "Latest Signal"
 ], group=grpVisual)

showOuterBands = input.bool(false, "Show Outer Bands", group=grpVisual)

grpLine = "Line Coloring"

lineSlopeLen         = input.int(5, "Slope Smoothing Length", minval=1, group=grpLine)
lineSlopeSensitivity = input.float(1.25, "Slope Color Sensitivity", step=0.05, group=grpLine)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullMain     = color.new(#5CF0D7, 0)
bearMain     = color.new(#B32AC3, 0)
labelTextCol = color.white
borderCol    = color.new(color.white, 50)
emptyCol     = color.new(#000104, 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_colorGradient(_ratio, _colA, _colB) =>
    rA = color.r(_colA)
    gA = color.g(_colA)
    bA = color.b(_colA)
    rB = color.r(_colB)
    gB = color.g(_colB)
    bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Liquid Fair Value
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaFair  = ta.ema(src, fairLen)
almaFair = ta.alma(src, fairLen, 0.85, 6.0)
fairRaw  = emaFair * 0.55 + almaFair * 0.45
fair     = ta.ema(fairRaw, math.max(1, int(smoothLen / 2)))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Liquid Band Width
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dev      = src - fair
devStdev = ta.stdev(dev, zLen)

atrValue    = ta.atr(14)
absDev      = ta.ema(math.abs(dev), zLen)
rangeEnergy = ta.ema(high - low, smoothLen)

baseWidth = devStdev * 0.60 + atrValue * 0.25 + absDev * 0.10 + rangeEnergy * 0.05
width     = ta.ema(baseWidth, smoothLen)

upperBand      = fair + width * upperMult
lowerBand      = fair - width * lowerMult
outerUpperBand = fair + width * upperMult * outerUpperMult
outerLowerBand = fair - width * lowerMult * outerLowerMult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Smooth Fair Value Line Color
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fairSlopeRaw    = nz(fair - fair[1], 0.0)
fairSlopeAvg    = ta.ema(math.abs(fairSlopeRaw), lineSlopeLen)
fairSlopeNorm   = fairSlopeAvg != 0.0 ? fairSlopeRaw / fairSlopeAvg : 0.0
fairSlopeSmooth = ta.ema(fairSlopeNorm, lineSlopeLen)

lineRatioRaw = 0.5 + fairSlopeSmooth / (2.0 * lineSlopeSensitivity)
lineRatio    = f_clamp(lineRatioRaw, 0.0, 1.0)

fairLineColor = f_colorGradient(lineRatio, bearMain, bullMain)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Close-Based Reversal Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawBuy  = close[1] <= lowerBand[1] and close > lowerBand
rawSell = close[1] >= upperBand[1] and close < upperBand

var int lastSignalBar = na
var string lastSignal = ""

barsOk = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

finalBuy  = enableSignals and rawBuy and barsOk
finalSell = enableSignals and rawSell and barsOk

if finalBuy
    lastSignalBar := bar_index
    lastSignal := "bull"

if finalSell
    lastSignalBar := bar_index
    lastSignal := "bear"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bandRange    = upperBand - lowerBand
ratioRaw     = bandRange != 0.0 ? (src - lowerBand) / bandRange : 0.5
ratioClamped = f_clamp(nz(ratioRaw, 0.5), 0.0, 1.0)

reversalCandleCol = f_colorGradient(ratioClamped, bullMain, bearMain)
latestSignalCol   = lastSignal == "bull" ? bullMain : lastSignal == "bear" ? bearMain : reversalCandleCol

candleCol = candleMode == "Reversal Heat" ? reversalCandleCol : latestSignalCol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotcandle(
     open,
     high,
     low,
     close,
     title="Liquid Reversal Candles",
     color=candleCol,
     wickcolor=candleCol,
     bordercolor=candleCol
)

pUpper = plot(upperBand, "Upper Band", color=borderCol, linewidth=1)
pLower = plot(lowerBand, "Lower Band", color=borderCol, linewidth=1)
pFair  = plot(fair, "Fair Value", color=fairLineColor, linewidth=1)

pOuterUpper = plot(showOuterBands ? outerUpperBand : na, "Outer Upper Band", color=color.new(borderCol, 80), linewidth=1)
pOuterLower = plot(showOuterBands ? outerLowerBand : na, "Outer Lower Band", color=color.new(borderCol, 80), linewidth=1)

fill(pUpper, pFair, upperBand, fair, color.new(bearMain, 80), emptyCol)
fill(pFair, pLower, fair, lowerBand, emptyCol, color.new(bullMain, 80))

fill(pOuterUpper, pUpper, outerUpperBand, upperBand, showOuterBands ? color.new(bearMain, 70) : na, showOuterBands ? color.new(bearMain, 100) : na)
fill(pLower, pOuterLower, lowerBand, outerLowerBand, showOuterBands ? color.new(bullMain, 100) : na, showOuterBands ? color.new(bullMain, 70) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(finalBuy, title="Buy", location=location.belowbar, style=shape.labelup, text="𝓤𝓹", color=bullMain, textcolor=#000000, size=size.small)
plotshape(finalSell, title="Sell", location=location.abovebar, style=shape.labeldown, text="𝓓𝓸𝔀𝓷", color=bearMain, textcolor=labelTextCol, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(finalBuy, title="Buy Signal", message="Uptrick LRB: Close crossed above lower band")
alertcondition(finalSell, title="Sell Signal", message="Uptrick LRB: Close crossed below upper band")
````
