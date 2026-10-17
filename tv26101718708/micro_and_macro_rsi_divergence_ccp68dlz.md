# Micro and Macro RSI Divergence

- url: https://www.tradingview.com/script/ccP68DLZ-Micro-and-Macro-RSI-Divergence/
- type: indicator
- pine_id: PUB;1dfc684c77464f55aa70b2563c1da117
- version: 1.0

## Description

█ OVERVIEW
Micro and Macro RSI Divergence is a multi-scale system for detecting divergences between price and RSI, designed for simultaneous analysis of short-term market structure (micro) and the broader trend context (macro).

The indicator does not limit itself to a simple price vs RSI comparison. It utilizes pivot structure, advanced signal quality filtering, and an additional layer of smoothed RSI, which allows it to effectively distinguish high-quality divergences from random market noise.

Each detected divergence is additionally verified in terms of structural integrity, distance between pivots, and momentum consistency. This enables significantly more selective and contextual market readings compared to classic divergence indicators.

█ CONCEPTS
In standard indicators, divergences are typically detected using a single, fixed pivot length. This causes signals to often be either delayed relative to the actual price movement or to react to very small, local fluctuations that have no greater structural significance.

This indicator was created precisely to solve this problem by introducing multi-scale pivot analysis. This makes it possible to simultaneously compare small, local divergences (micro) with larger movement structures (macro).

This allows for a better assessment of whether a local momentum change:
- is merely a short-term correction within an existing trend,
- or an element of a larger, structural change in market direction.
As a result, the user receives not only information about the divergence itself, but also an assessment of its real significance in the broader market context and the potential strength of the price direction change.

Divergence Types
- Regular Bullish - price forms a lower low, RSI forms a higher low
- Regular Bearish - price forms a higher high, RSI forms a lower high
- Hidden Bullish - higher low in price with weaker RSI (continuation of uptrend)
- Hidden Bearish - lower high in price with stronger RSI (continuation of downtrend)

Micro vs Macro Logic
Micro divergences are more reactive and generate a greater number of signals. In contrast, macro divergences filter the broader market structure and represent stronger, more significant turning points.
Both layers operate independently, but their confluence significantly enhances the quality of market interpretation.

█ FEATURES
RSI Engine
- RSI calculation based on the selected source (default close)
- Configurable RSI length
- Overbought/oversold levels (70/30)

Smoothed RSI Layer
- Optional smoothed RSI layer
- Available smoothing methods: SMA, EMA, RMA, WMA, HMA
- Serves as an additional confirmation layer and noise reduction

Divergence Engine (Micro + Macro)
- Detection system in two scales simultaneously
- Independent calculations for micro and macro
- Micro Pivot Length - for local structure analysis
- Macro Pivot Length - for higher-order structure analysis

Pivot Detection System
- Pivots based on High/Low or Close
- Configurable left/right pivot length
- Minimum and maximum distance restrictions between pivots
- Noise reduction and excessive signal count reduction

Divergence Types Detection
- Regular bullish and bearish divergences
- Hidden bullish and bearish divergences
- Separate logic for micro and macro scales

Structure Validation Engine
The indicator includes advanced structural integrity validation, known as line break check.
This validation checks whether the line connecting two consecutive pivots has not been broken by price movement (in High/Low mode) or by the RSI indicator itself (in oscillator mode). This allows rejection of divergences whose structure has been damaged by subsequent movement - which significantly improves signal quality.

Important limitation:
Line break validation operates exclusively in two cases:
- When pivot detection is based on High/Low (i.e., on wicks),
- When the indicator operates in oscillator mode (pivots calculated directly on RSI values).
In Close mode (when pivots are calculated on closing prices) line break validation is not applied, because the line connecting two consecutive closes does not have structural significance in this case and cannot be reliably broken.

Filtering System
- RSI alignment filter relative to the 50 level
- Smoothed RSI alignment filter relative to the 50 level
- RSI momentum direction filter
- Smoothed RSI momentum direction filter
- Minimum RSI value difference between pivots
- Pivot distance restrictions

Visualization System
The indicator offers a flexible visualization system that works in two modes:
- Overlay mode - draws divergence lines directly on the price chart
- Oscillator mode - draws divergence lines in the RSI panel

Additional cross-drawing options are available:
- When the indicator runs in the RSI panel, you can enable simultaneous drawing on the price chart
- When the indicator runs on the price chart, you can enable simultaneous drawing in the RSI panel

Available visual elements:
- Divergence lines between pivots
- Text labels (Bull / Bear / hBull / hBear and macro versions: BullM, BearM, hBullM, hBearM)
- Separation of micro and macro
- Shape markers indicating divergence detection points: circles (micro) and diamonds (macro)

Alert System
- Alerts for all types of divergences
- Separate alerts for micro and macro scales
- Separate alerts for regular and hidden divergences

█ APPLICATIONS
1. Trend Weakness Context
Regular divergences are not an entry signal, but information about the weakening of the current move.
Example:
You have an open long position and a bearish divergence appears - momentum is losing strength. You start paying more attention to potential resistance levels, profit-taking zones, and possible changes in market structure.

2. Trend Continuation Context
Hidden divergences may indicate trend continuation after a correction.
Example:
In an uptrend, a hidden bullish divergence appears - the correction may be exhausting. You do not enter automatically, but check support levels, trend structure, and additional momentum confirmations.

3. Support & Resistance Context
Divergences have the greatest value when they appear near key levels.
- Bearish divergence near resistance - greater risk of price rejection
- Bullish divergence near support - potential upward reaction
Important: Divergence by itself is not an entry signal - it provides context for analyzing levels and market structure.

4. Exit & Risk Management
Divergences can help with:
- Earlier position closing
- Profit protection
- Identification of the final phase of the impulse

█ NOTES
Divergences are detected with a delay resulting directly from the pivot length - the larger the pivot, the greater the detection delay (equal to its length).

The indicator is a contextual tool, not a signal tool. It should be treated as support for the decision-making process, not as a standalone system generating entry signals.

By default, divergence detection points are marked on the chart as follows:
- Micro divergences - circles
- Macro divergences - diamonds

The indicator also allows simultaneous display of divergence lines both on the price chart and in the RSI panel (cross-drawing function), which provides full flexibility depending on the preferred analysis style.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('Micro and Macro RSI Divergence', overlay = false, max_lines_count = 500, max_labels_count = 500, precision = 2)

groupRSI = "RSI"
rsiLength = input.int(14, "RSI Length", minval = 1, group = groupRSI)
rsiSource = input.source(close, "RSI Source", group = groupRSI)
obLevelRSI = input.float(70.0, "Overbought (RSI)", minval = 50, group = groupRSI)
osLevelRSI = input.float(30.0, "Oversold (RSI)", maxval = 50, group = groupRSI)
rsi = ta.rsi(rsiSource, rsiLength)

// SMOOTHED RSI 
groupSmooth = "Smoothed RSI"
showSmoothedRsi = input.bool(true, "Show Smoothed RSI", group = groupSmooth)
smoothType = input.string("EMA", "Smoothing Type", options = ["SMA", "EMA", "RMA", "WMA", "HMA"], group = groupSmooth)
smoothLength = input.int(60, "Smoothing Length", minval = 1, group = groupSmooth)

float smoothedRsi = na
if smoothType == "SMA"
    smoothedRsi := ta.sma(rsi, smoothLength)
else if smoothType == "EMA"
    smoothedRsi := ta.ema(rsi, smoothLength)
else if smoothType == "RMA"
    smoothedRsi := ta.rma(rsi, smoothLength)
else if smoothType == "WMA"
    smoothedRsi := ta.wma(rsi, smoothLength)
else if smoothType == "HMA"
    smoothedRsi := ta.hma(rsi, smoothLength)

// DIVERGENCES 
groupDiv = 'Divergences'
calculateDivergence = input.bool(true, 'Enable Divergences', group = groupDiv)
forceOverlay = input.bool(true, 'Draw on price chart', group = groupDiv)
showRegularDiv = input.bool(true, 'Show Regular Divergences (Bullish/Bearish)', group = groupDiv)
showHiddenDiv = input.bool(true, 'Show Hidden Divergences', group = groupDiv)
pivotLength       = input.int(2,  'Micro Pivot Length (left/right)', minval = 1, group = groupDiv)
pivotLengthMacro  = input.int(10,  'Macro Pivot Length (left/right)', minval = 2, group = groupDiv)
pivotMode = input.string("High/Low", "Price Pivot Mode (High/Low or Close)", options = ["High/Low", "Close"], group = groupDiv)
minPivotBars = input.int(5, "Min. bars between pivots", minval = 1, group = groupDiv)
maxPivotBars = input.int(100, "Max. bars between pivots", minval = 1, group = groupDiv)
minDivDiff = input.float(4, "Min. RSI difference (filter)", minval = 0.0, step = 1, group = groupDiv)
alsoDrawRsiLines   = input.bool(true, 'When drawing on price chart: also draw RSI lines in panel', group = groupDiv)
alsoDrawPriceLines = input.bool(true, 'When in oscillator mode: also draw price lines on chart', group = groupDiv)
showDivLabels = input.bool(true, 'Show divergence labels', group = groupDiv)
showShapes = input.bool(true, 'Show divergence markers on chart', group = groupDiv)

enableDivFilter = input.bool(false, "Enable RSI Level Filter (RSI aligned with 50 level)", group = groupDiv)
enableSmoothedDivFilter = input.bool(false, "Enable Smoothed RSI Filter (Smoothed RSI aligned with 50 level)", group = groupDiv)
enableRsiDirectionFilter = input.bool(false, "Enable RSI Direction Filter (aligned with divergence)", group = groupDiv)
enableSmoothedRsiDirectionFilter = input.bool(false, "Enable Smoothed RSI Direction Filter (aligned with divergence)", group = groupDiv)

// RSI COLORS & GRADIENT 
groupRSIColors = "RSI Colors"
colSmoothedRSILine  = input.color(color.rgb(240, 225, 16), "Smoothed RSI Line Color", group = groupRSIColors)
bullGradientColor   = input.color(color.rgb(6, 162, 47), "Bullish Color (RSI line + gradient above 50)", group = groupRSIColors)
bearGradientColor   = input.color(color.rgb(207, 23, 23), "Bearish Color (RSI line + gradient below 50)", group = groupRSIColors)
showRSIGradient     = input.bool(true, "Show gradient fill between RSI and 50 level", group = groupRSIColors)
rsiPeakTransp       = input.int(80, "Gradient peak transparency (%)", minval = 0, maxval = 100, group = groupRSIColors)
colOverbought = input.color(color.new(color.red, 30), "Overbought Line Color", group = groupRSIColors)
colOversold   = input.color(color.new(color.green, 30), "Oversold Line Color", group = groupRSIColors)

// Gradient colors (fading)
c_bull_peak = color.new(bullGradientColor, rsiPeakTransp)
c_bull_mid  = color.new(bullGradientColor, 100)
c_bear_peak = color.new(bearGradientColor, rsiPeakTransp)
c_bear_mid  = color.new(bearGradientColor, 100)

// RSI line color
rsiLineColor = rsi > 50 ? bullGradientColor : bearGradientColor

// DIVERGENCE COLORS
groupDivColors = "Divergence Colors"
bullDivColor       = input.color(color.rgb(6, 162, 47),   'Regular Bullish Divergence Color (MICRO)', group = groupDivColors)
bearDivColor       = input.color(color.rgb(207, 23, 23),  'Regular Bearish Divergence Color (MICRO)', group = groupDivColors)
bullHiddenColor    = input.color(color.rgb(6, 162, 47),   'Hidden Bullish Divergence Color (MICRO)', group = groupDivColors)
bearHiddenColor    = input.color(color.rgb(207, 23, 23),  'Hidden Bearish Divergence Color (MICRO)', group = groupDivColors)

bullDivColorMacro      = input.color(color.rgb(0, 200, 120),  'Regular Bullish Divergence Color (MACRO)', group = groupDivColors)
bearDivColorMacro      = input.color(color.rgb(255, 90, 90),  'Regular Bearish Divergence Color (MACRO)', group = groupDivColors)
bullHiddenColorMacro   = input.color(color.rgb(0, 180, 130),  'Hidden Bullish Divergence Color (MACRO)', group = groupDivColors)
bearHiddenColorMacro   = input.color(color.rgb(255, 110, 110), 'Hidden Bearish Divergence Color (MACRO)', group = groupDivColors)

textColor = input.color(color.white, 'Label text color', group = groupDivColors)

divSource = rsi
pLen = pivotLength
useCloseForPivots = pivotMode == "Close"
priceLow = useCloseForPivots ? close : low
priceHigh = useCloseForPivots ? close : high

isRsiPivotMode = not forceOverlay
pivotSrcLow  = isRsiPivotMode ? rsi : priceLow
pivotSrcHigh = isRsiPivotMode ? rsi : priceHigh

// MICRO PIVOTS
pivotLowVal = ta.pivotlow(pivotSrcLow, pLen, pLen)
pivotHighVal = ta.pivothigh(pivotSrcHigh, pLen, pLen)

oscAtLowPivot  = isRsiPivotMode ? pivotLowVal : (not na(pivotLowVal) ? rsi[pLen] : na)
oscAtHighPivot = isRsiPivotMode ? pivotHighVal : (not na(pivotHighVal) ? rsi[pLen] : na)
priceAtLowPivot  = not na(pivotLowVal) ? priceLow[pLen] : na
priceAtHighPivot = not na(pivotHighVal) ? priceHigh[pLen] : na

smoothedRsiAtLowPivot  = not na(pivotLowVal) ? smoothedRsi[pLen] : na
smoothedRsiAtHighPivot = not na(pivotHighVal) ? smoothedRsi[pLen] : na

prevOscLow = ta.valuewhen(not na(pivotLowVal), oscAtLowPivot, 1)
prevPriceLow = ta.valuewhen(not na(pivotLowVal), priceAtLowPivot, 1)
prevLowBar = ta.valuewhen(not na(pivotLowVal), bar_index[pLen], 1)
prevOscHigh = ta.valuewhen(not na(pivotHighVal), oscAtHighPivot, 1)
prevPriceHigh = ta.valuewhen(not na(pivotHighVal), priceAtHighPivot, 1)
prevHighBar = ta.valuewhen(not na(pivotHighVal), bar_index[pLen], 1)

// PREVIOUS SMOOTHED RSI (MICRO)
prevSmoothedRsiLow = ta.valuewhen(not na(pivotLowVal), smoothedRsiAtLowPivot, 1)
prevSmoothedRsiHigh = ta.valuewhen(not na(pivotHighVal), smoothedRsiAtHighPivot, 1)

int lowDist = not na(prevLowBar) ? bar_index[pLen] - prevLowBar : na
int highDist = not na(prevHighBar) ? bar_index[pLen] - prevHighBar : na

bool lowDistOK = not na(lowDist) and lowDist >= minPivotBars and lowDist <= maxPivotBars
bool highDistOK = not na(highDist) and highDist >= minPivotBars and highDist <= maxPivotBars

// MACRO PIVOTS
pLenMacro = pivotLengthMacro

pivotLowValMacro = ta.pivotlow(pivotSrcLow, pLenMacro, pLenMacro)
pivotHighValMacro = ta.pivothigh(pivotSrcHigh, pLenMacro, pLenMacro)

oscAtLowPivotMacro  = isRsiPivotMode ? pivotLowValMacro : (not na(pivotLowValMacro) ? rsi[pLenMacro] : na)
oscAtHighPivotMacro = isRsiPivotMode ? pivotHighValMacro : (not na(pivotHighValMacro) ? rsi[pLenMacro] : na)
priceAtLowPivotMacro  = not na(pivotLowValMacro) ? priceLow[pLenMacro] : na
priceAtHighPivotMacro = not na(pivotHighValMacro) ? priceHigh[pLenMacro] : na

smoothedRsiAtLowPivotMacro  = not na(pivotLowValMacro) ? smoothedRsi[pLenMacro] : na
smoothedRsiAtHighPivotMacro = not na(pivotHighValMacro) ? smoothedRsi[pLenMacro] : na

prevOscLowMacro = ta.valuewhen(not na(pivotLowValMacro), oscAtLowPivotMacro, 1)
prevPriceLowMacro = ta.valuewhen(not na(pivotLowValMacro), priceAtLowPivotMacro, 1)
prevLowBarMacro = ta.valuewhen(not na(pivotLowValMacro), bar_index[pLenMacro], 1)
prevOscHighMacro = ta.valuewhen(not na(pivotHighValMacro), oscAtHighPivotMacro, 1)
prevPriceHighMacro = ta.valuewhen(not na(pivotHighValMacro), priceAtHighPivotMacro, 1)
prevHighBarMacro = ta.valuewhen(not na(pivotHighValMacro), bar_index[pLenMacro], 1)

// PREVIOUS SMOOTHED RSI (MACRO) 
prevSmoothedRsiLowMacro = ta.valuewhen(not na(pivotLowValMacro), smoothedRsiAtLowPivotMacro, 1)
prevSmoothedRsiHighMacro = ta.valuewhen(not na(pivotHighValMacro), smoothedRsiAtHighPivotMacro, 1)

int lowDistMacro = not na(prevLowBarMacro) ? bar_index[pLenMacro] - prevLowBarMacro : na
int highDistMacro = not na(prevHighBarMacro) ? bar_index[pLenMacro] - prevHighBarMacro : na

bool lowDistOKMacro = not na(lowDistMacro) and lowDistMacro >= minPivotBars and lowDistMacro <= maxPivotBars
bool highDistOKMacro = not na(highDistMacro) and highDistMacro >= minPivotBars and highDistMacro <= maxPivotBars

// LINE BREAK FILTER
lineIsBroken(src, olderOffset, newerOffset, isHigh) =>
    broken = false
    if na(olderOffset) or na(newerOffset)
        broken
    else
        distance = olderOffset - newerOffset
        if distance <= 1 or distance > maxPivotBars
            broken
        else
            startValue = src[olderOffset]
            endValue = src[newerOffset]
            slope = (endValue - startValue) / distance
            for i = 1 to distance - 1
                expected = startValue + slope * i
                actual = src[olderOffset - i]
                if isHigh
                    if actual > expected
                        broken := true
                        break
                else
                    if actual < expected
                        broken := true
                        break
            broken

bool priceLineBroken_Low  = lineIsBroken(priceLow, lowDist + pLen, pLen, false)
bool rsiLineBroken_Low    = lineIsBroken(divSource, lowDist + pLen, pLen, false)
bool priceLineBroken_High = lineIsBroken(priceHigh, highDist + pLen, pLen, true)
bool rsiLineBroken_High   = lineIsBroken(divSource, highDist + pLen, pLen, true)

bool priceLineOK_Low  = not priceLineBroken_Low
bool priceLineOK_High = not priceLineBroken_High
bool rsiLineOK_Low    = not rsiLineBroken_Low
bool rsiLineOK_High   = not rsiLineBroken_High

bool priceLineBroken_LowMacro  = lineIsBroken(priceLow, lowDistMacro + pLenMacro, pLenMacro, false)
bool rsiLineBroken_LowMacro    = lineIsBroken(divSource, lowDistMacro + pLenMacro, pLenMacro, false)
bool priceLineBroken_HighMacro = lineIsBroken(priceHigh, highDistMacro + pLenMacro, pLenMacro, true)
bool rsiLineBroken_HighMacro   = lineIsBroken(divSource, highDistMacro + pLenMacro, pLenMacro, true)

bool priceLineOK_LowMacro  = not priceLineBroken_LowMacro
bool priceLineOK_HighMacro = not priceLineBroken_HighMacro
bool rsiLineOK_LowMacro    = not rsiLineBroken_LowMacro
bool rsiLineOK_HighMacro   = not rsiLineBroken_HighMacro

bool isValidLowPivot  = not na(pivotLowVal) and not na(prevPriceLow) and lowDistOK
bool isValidHighPivot = not na(pivotHighVal) and not na(prevPriceHigh) and highDistOK

bool isValidLowPivotMacro  = not na(pivotLowValMacro) and not na(prevPriceLowMacro) and lowDistOKMacro
bool isValidHighPivotMacro = not na(pivotHighValMacro) and not na(prevPriceHighMacro) and highDistOKMacro

// RSI LEVEL 50 FILTERS
bool rsiAbove50_Low       = not na(oscAtLowPivot) and oscAtLowPivot > 50
bool rsiBelow50_High      = not na(oscAtHighPivot) and oscAtHighPivot < 50
bool rsiAbove50_LowMacro  = not na(oscAtLowPivotMacro) and oscAtLowPivotMacro > 50
bool rsiBelow50_HighMacro = not na(oscAtHighPivotMacro) and oscAtHighPivotMacro < 50

bool smoothedRsiAbove50_Low       = not na(smoothedRsiAtLowPivot) and smoothedRsiAtLowPivot > 50
bool smoothedRsiBelow50_High      = not na(smoothedRsiAtHighPivot) and smoothedRsiAtHighPivot < 50
bool smoothedRsiAbove50_LowMacro  = not na(smoothedRsiAtLowPivotMacro) and smoothedRsiAtLowPivotMacro > 50
bool smoothedRsiBelow50_HighMacro = not na(smoothedRsiAtHighPivotMacro) and smoothedRsiAtHighPivotMacro < 50

// RSI & SMOOTHED RSI DIRECTION FILTERS
bool rsiRising_Low       = not na(oscAtLowPivot) and not na(prevOscLow) and oscAtLowPivot > nz(prevOscLow)
bool rsiFalling_High     = not na(oscAtHighPivot) and not na(prevOscHigh) and oscAtHighPivot < nz(prevOscHigh)
bool rsiRising_LowMacro  = not na(oscAtLowPivotMacro) and not na(prevOscLowMacro) and oscAtLowPivotMacro > nz(prevOscLowMacro)
bool rsiFalling_HighMacro = not na(oscAtHighPivotMacro) and not na(prevOscHighMacro) and oscAtHighPivotMacro < nz(prevOscHighMacro)

bool smoothedRsiRising_Low       = not na(smoothedRsiAtLowPivot) and not na(prevSmoothedRsiLow) and smoothedRsiAtLowPivot > nz(prevSmoothedRsiLow)
bool smoothedRsiFalling_High     = not na(smoothedRsiAtHighPivot) and not na(prevSmoothedRsiHigh) and smoothedRsiAtHighPivot < nz(prevSmoothedRsiHigh)
bool smoothedRsiRising_LowMacro  = not na(smoothedRsiAtLowPivotMacro) and not na(prevSmoothedRsiLowMacro) and smoothedRsiAtLowPivotMacro > nz(prevSmoothedRsiLowMacro)
bool smoothedRsiFalling_HighMacro = not na(smoothedRsiAtHighPivotMacro) and not na(prevSmoothedRsiHighMacro) and smoothedRsiAtHighPivotMacro < nz(prevSmoothedRsiHighMacro)

// MICRO CONDITIONS
bool priceLower_Low = priceAtLowPivot < nz(prevPriceLow)
bool oscHigher_Low = oscAtLowPivot > nz(prevOscLow)
bool diffOK_Low = (minDivDiff <= 0 or (oscAtLowPivot - nz(prevOscLow) >= minDivDiff))

bool priceHigher_High = priceAtHighPivot > nz(prevPriceHigh)
bool oscLower_High = oscAtHighPivot < nz(prevOscHigh)
bool diffOK_High = (minDivDiff <= 0 or (nz(prevOscHigh) - oscAtHighPivot >= minDivDiff))

bool priceHigherForHidden = priceAtLowPivot > nz(prevPriceLow)
bool oscLowerForHidden = oscAtLowPivot < nz(prevOscLow)
bool diffOK_HiddenLow = (minDivDiff <= 0 or (nz(prevOscLow) - oscAtLowPivot >= minDivDiff))

bool priceLowerForHidden = priceAtHighPivot < nz(prevPriceHigh)
bool oscHigherForHidden = oscAtHighPivot > nz(prevOscHigh)
bool diffOK_HiddenHigh = (minDivDiff <= 0 or (oscAtHighPivot - nz(prevOscHigh) >= minDivDiff))

bool coreBullLow = calculateDivergence and showRegularDiv and isValidLowPivot and priceLower_Low and oscHigher_Low and diffOK_Low 
     and (not enableDivFilter or rsiAbove50_Low) 
     and (not enableSmoothedDivFilter or smoothedRsiAbove50_Low)
     and (not enableRsiDirectionFilter or rsiRising_Low)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiRising_Low)

bool coreBearHigh = calculateDivergence and showRegularDiv and isValidHighPivot and priceHigher_High and oscLower_High and diffOK_High 
     and (not enableDivFilter or rsiBelow50_High) 
     and (not enableSmoothedDivFilter or smoothedRsiBelow50_High)
     and (not enableRsiDirectionFilter or rsiFalling_High)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiFalling_High)

bool coreHiddenBullLow = showHiddenDiv and calculateDivergence and isValidLowPivot and priceHigherForHidden and oscLowerForHidden and diffOK_HiddenLow 
     and (not enableDivFilter or rsiAbove50_Low) 
     and (not enableSmoothedDivFilter or smoothedRsiAbove50_Low)
     and (not enableRsiDirectionFilter or rsiRising_Low)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiRising_Low)

bool coreHiddenBearHigh = showHiddenDiv and calculateDivergence and isValidHighPivot and priceLowerForHidden and oscHigherForHidden and diffOK_HiddenHigh 
     and (not enableDivFilter or rsiBelow50_High) 
     and (not enableSmoothedDivFilter or smoothedRsiBelow50_High)
     and (not enableRsiDirectionFilter or rsiFalling_High)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiFalling_High)

bullDivOverlay = coreBullLow and priceLineOK_Low
bearDivOverlay = coreBearHigh and priceLineOK_High
hiddenBullDivOverlay = coreHiddenBullLow and priceLineOK_Low
hiddenBearDivOverlay = coreHiddenBearHigh and priceLineOK_High

bullDivOsc = coreBullLow and rsiLineOK_Low
bearDivOsc = coreBearHigh and rsiLineOK_High
hiddenBullDivOsc = coreHiddenBullLow and rsiLineOK_Low
hiddenBearDivOsc = coreHiddenBearHigh and rsiLineOK_High

// MACRO CONDITIONS
bool priceLower_LowMacro = priceAtLowPivotMacro < nz(prevPriceLowMacro)
bool oscHigher_LowMacro = oscAtLowPivotMacro > nz(prevOscLowMacro)
bool diffOK_LowMacro = (minDivDiff <= 0 or (oscAtLowPivotMacro - nz(prevOscLowMacro) >= minDivDiff))

bool priceHigher_HighMacro = priceAtHighPivotMacro > nz(prevPriceHighMacro)
bool oscLower_HighMacro = oscAtHighPivotMacro < nz(prevOscHighMacro)
bool diffOK_HighMacro = (minDivDiff <= 0 or (nz(prevOscHighMacro) - oscAtHighPivotMacro >= minDivDiff))

bool priceHigherForHiddenMacro = priceAtLowPivotMacro > nz(prevPriceLowMacro)
bool oscLowerForHiddenMacro = oscAtLowPivotMacro < nz(prevOscLowMacro)
bool diffOK_HiddenLowMacro = (minDivDiff <= 0 or (nz(prevOscLowMacro) - oscAtLowPivotMacro >= minDivDiff))

bool priceLowerForHiddenMacro = priceAtHighPivotMacro < nz(prevPriceHighMacro)
bool oscHigherForHiddenMacro = oscAtHighPivotMacro > nz(prevOscHighMacro)
bool diffOK_HiddenHighMacro = (minDivDiff <= 0 or (oscAtHighPivotMacro - nz(prevOscHighMacro) >= minDivDiff))

bool coreBullLowMacro = calculateDivergence and showRegularDiv and isValidLowPivotMacro and priceLower_LowMacro and oscHigher_LowMacro and diffOK_LowMacro 
     and (not enableDivFilter or rsiAbove50_LowMacro) 
     and (not enableSmoothedDivFilter or smoothedRsiAbove50_LowMacro)
     and (not enableRsiDirectionFilter or rsiRising_LowMacro)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiRising_LowMacro)

bool coreBearHighMacro = calculateDivergence and showRegularDiv and isValidHighPivotMacro and priceHigher_HighMacro and oscLower_HighMacro and diffOK_HighMacro 
     and (not enableDivFilter or rsiBelow50_HighMacro) 
     and (not enableSmoothedDivFilter or smoothedRsiBelow50_HighMacro)
     and (not enableRsiDirectionFilter or rsiFalling_HighMacro)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiFalling_HighMacro)

bool coreHiddenBullLowMacro = showHiddenDiv and calculateDivergence and isValidLowPivotMacro and priceHigherForHiddenMacro and oscLowerForHiddenMacro and diffOK_HiddenLowMacro 
     and (not enableDivFilter or rsiAbove50_LowMacro) 
     and (not enableSmoothedDivFilter or smoothedRsiAbove50_LowMacro)
     and (not enableRsiDirectionFilter or rsiRising_LowMacro)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiRising_LowMacro)

bool coreHiddenBearHighMacro = showHiddenDiv and calculateDivergence and isValidHighPivotMacro and priceLowerForHiddenMacro and oscHigherForHiddenMacro and diffOK_HiddenHighMacro 
     and (not enableDivFilter or rsiBelow50_HighMacro) 
     and (not enableSmoothedDivFilter or smoothedRsiBelow50_HighMacro)
     and (not enableRsiDirectionFilter or rsiFalling_HighMacro)
     and (not enableSmoothedRsiDirectionFilter or smoothedRsiFalling_HighMacro)

bullDivOverlayMacro = coreBullLowMacro and priceLineOK_LowMacro
bearDivOverlayMacro = coreBearHighMacro and priceLineOK_HighMacro
hiddenBullDivOverlayMacro = coreHiddenBullLowMacro and priceLineOK_LowMacro
hiddenBearDivOverlayMacro = coreHiddenBearHighMacro and priceLineOK_HighMacro

bullDivOscMacro = coreBullLowMacro and rsiLineOK_LowMacro
bearDivOscMacro = coreBearHighMacro and rsiLineOK_HighMacro
hiddenBullDivOscMacro = coreHiddenBullLowMacro and rsiLineOK_LowMacro
hiddenBearDivOscMacro = coreHiddenBearHighMacro and rsiLineOK_LowMacro

// DRAWING ON PRICE CHART (OVERLAY MODE)
if bullDivOverlay and forceOverlay
    line.new(prevLowBar, prevPriceLow, bar_index[pLen], priceAtLowPivot, color = bullDivColor, width = 1, style = line.style_solid, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLen], priceAtLowPivot, "Bull", style = label.style_label_up, color = color.new(bullDivColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if bearDivOverlay and forceOverlay
    line.new(prevHighBar, prevPriceHigh, bar_index[pLen], priceAtHighPivot, color = bearDivColor, width = 1, style = line.style_solid, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLen], priceAtHighPivot, "Bear", style = label.style_label_down, color = color.new(bearDivColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if hiddenBullDivOverlay and forceOverlay
    line.new(prevLowBar, prevPriceLow, bar_index[pLen], priceAtLowPivot, color = bullHiddenColor, width = 1, style = line.style_dashed, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLen], priceAtLowPivot, "hBull", style = label.style_label_up, color = color.new(bullHiddenColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if hiddenBearDivOverlay and forceOverlay
    line.new(prevHighBar, prevPriceHigh, bar_index[pLen], priceAtHighPivot, color = bearHiddenColor, width = 1, style = line.style_dashed, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLen], priceAtHighPivot, "hBear", style = label.style_label_down, color = color.new(bearHiddenColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

// MACRO - Overlay
if bullDivOverlayMacro and forceOverlay
    line.new(prevLowBarMacro, prevPriceLowMacro, bar_index[pLenMacro], priceAtLowPivotMacro, color = bullDivColorMacro, width = 1, style = line.style_solid, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLenMacro], priceAtLowPivotMacro, "BullM", style = label.style_label_up, color = color.new(bullDivColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if bearDivOverlayMacro and forceOverlay
    line.new(prevHighBarMacro, prevPriceHighMacro, bar_index[pLenMacro], priceAtHighPivotMacro, color = bearDivColorMacro, width = 1, style = line.style_solid, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLenMacro], priceAtHighPivotMacro, "BearM", style = label.style_label_down, color = color.new(bearDivColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if hiddenBullDivOverlayMacro and forceOverlay
    line.new(prevLowBarMacro, prevPriceLowMacro, bar_index[pLenMacro], priceAtLowPivotMacro, color = bullHiddenColorMacro, width = 1, style = line.style_dashed, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLenMacro], priceAtLowPivotMacro, "hBullM", style = label.style_label_up, color = color.new(bullHiddenColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if hiddenBearDivOverlayMacro and forceOverlay
    line.new(prevHighBarMacro, prevPriceHighMacro, bar_index[pLenMacro], priceAtHighPivotMacro, color = bearHiddenColorMacro, width = 1, style = line.style_dashed, force_overlay = true)
    if showDivLabels
        label.new(bar_index[pLenMacro], priceAtHighPivotMacro, "hBearM", style = label.style_label_down, color = color.new(bearHiddenColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

// DRAWING IN OSCILLATOR PANEL
if bullDivOsc and not forceOverlay
    line.new(prevLowBar, prevOscLow, bar_index[pLen], oscAtLowPivot, color = bullDivColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLen], oscAtLowPivot, "Bull", style = label.style_label_up, color = color.new(bullDivColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if bearDivOsc and not forceOverlay
    line.new(prevHighBar, prevOscHigh, bar_index[pLen], oscAtHighPivot, color = bearDivColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLen], oscAtHighPivot, "Bear", style = label.style_label_down, color = color.new(bearDivColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if hiddenBullDivOsc and not forceOverlay
    line.new(prevLowBar, prevOscLow, bar_index[pLen], oscAtLowPivot, color = bullHiddenColor, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLen], oscAtLowPivot, "hBull", style = label.style_label_up, color = color.new(bullHiddenColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if hiddenBearDivOsc and not forceOverlay
    line.new(prevHighBar, prevOscHigh, bar_index[pLen], oscAtHighPivot, color = bearHiddenColor, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLen], oscAtHighPivot, "hBear", style = label.style_label_down, color = color.new(bearHiddenColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

// MACRO - Oscillator
if bullDivOscMacro and not forceOverlay
    line.new(prevLowBarMacro, prevOscLowMacro, bar_index[pLenMacro], oscAtLowPivotMacro, color = bullDivColorMacro, width = 1, style = line.style_solid, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLenMacro], oscAtLowPivotMacro, "BullM", style = label.style_label_up, color = color.new(bullDivColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if bearDivOscMacro and not forceOverlay
    line.new(prevHighBarMacro, prevOscHighMacro, bar_index[pLenMacro], oscAtHighPivotMacro, color = bearDivColorMacro, width = 1, style = line.style_solid, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLenMacro], oscAtHighPivotMacro, "BearM", style = label.style_label_down, color = color.new(bearDivColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if hiddenBullDivOscMacro and not forceOverlay
    line.new(prevLowBarMacro, prevOscLowMacro, bar_index[pLenMacro], oscAtLowPivotMacro, color = bullHiddenColorMacro, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLenMacro], oscAtLowPivotMacro, "hBullM", style = label.style_label_up, color = color.new(bullHiddenColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

if hiddenBearDivOscMacro and not forceOverlay
    line.new(prevHighBarMacro, prevOscHighMacro, bar_index[pLenMacro], oscAtHighPivotMacro, color = bearHiddenColorMacro, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
    if showDivLabels
        label.new(bar_index[pLenMacro], oscAtHighPivotMacro, "hBearM", style = label.style_label_down, color = color.new(bearHiddenColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

// ADDITIONAL LINES (cross-drawing)
if alsoDrawPriceLines and not forceOverlay
    if bullDivOsc
        line.new(prevLowBar, prevPriceLow, bar_index[pLen], priceAtLowPivot, color = bullDivColor, width = 1, style = line.style_solid, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLen], priceAtLowPivot, "Bull", style = label.style_label_up, color = color.new(bullDivColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if bearDivOsc
        line.new(prevHighBar, prevPriceHigh, bar_index[pLen], priceAtHighPivot, color = bearDivColor, width = 1, style = line.style_solid, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLen], priceAtHighPivot, "Bear", style = label.style_label_down, color = color.new(bearDivColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if hiddenBullDivOsc
        line.new(prevLowBar, prevPriceLow, bar_index[pLen], priceAtLowPivot, color = bullHiddenColor, width = 1, style = line.style_dashed, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLen], priceAtLowPivot, "hBull", style = label.style_label_up, color = color.new(bullHiddenColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if hiddenBearDivOsc
        line.new(prevHighBar, prevPriceHigh, bar_index[pLen], priceAtHighPivot, color = bearHiddenColor, width = 1, style = line.style_dashed, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLen], priceAtHighPivot, "hBear", style = label.style_label_down, color = color.new(bearHiddenColor, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

    if bullDivOscMacro
        line.new(prevLowBarMacro, prevPriceLowMacro, bar_index[pLenMacro], priceAtLowPivotMacro, color = bullDivColorMacro, width = 1, style = line.style_solid, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLenMacro], priceAtLowPivotMacro, "BullM", style = label.style_label_up, color = color.new(bullDivColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if bearDivOscMacro
        line.new(prevHighBarMacro, prevPriceHighMacro, bar_index[pLenMacro], priceAtHighPivotMacro, color = bearDivColorMacro, width = 1, style = line.style_solid, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLenMacro], priceAtHighPivotMacro, "BearM", style = label.style_label_down, color = color.new(bearDivColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if hiddenBullDivOscMacro
        line.new(prevLowBarMacro, prevPriceLowMacro, bar_index[pLenMacro], priceAtLowPivotMacro, color = bullHiddenColorMacro, width = 1, style = line.style_dashed, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLenMacro], priceAtLowPivotMacro, "hBullM", style = label.style_label_up, color = color.new(bullHiddenColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)
    if hiddenBearDivOscMacro
        line.new(prevHighBarMacro, prevPriceHighMacro, bar_index[pLenMacro], priceAtHighPivotMacro, color = bearHiddenColorMacro, width = 1, style = line.style_dashed, force_overlay = true)
        if showDivLabels
            label.new(bar_index[pLenMacro], priceAtHighPivotMacro, "hBearM", style = label.style_label_down, color = color.new(bearHiddenColorMacro, 40), textcolor = textColor, size = size.small, yloc = yloc.price, force_overlay = true)

if alsoDrawRsiLines and forceOverlay
    if bullDivOverlay
        line.new(prevLowBar, prevOscLow, bar_index[pLen], oscAtLowPivot, color = bullDivColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLen], oscAtLowPivot, "Bull", style = label.style_label_up, color = color.new(bullDivColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if bearDivOverlay
        line.new(prevHighBar, prevOscHigh, bar_index[pLen], oscAtHighPivot, color = bearDivColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLen], oscAtHighPivot, "Bear", style = label.style_label_down, color = color.new(bearDivColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if hiddenBullDivOverlay
        line.new(prevLowBar, prevOscLow, bar_index[pLen], oscAtLowPivot, color = bullHiddenColor, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLen], oscAtLowPivot, "hBull", style = label.style_label_up, color = color.new(bullHiddenColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if hiddenBearDivOverlay
        line.new(prevHighBar, prevOscHigh, bar_index[pLen], oscAtHighPivot, color = bearHiddenColor, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLen], oscAtHighPivot, "hBear", style = label.style_label_down, color = color.new(bearHiddenColor, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

    if bullDivOverlayMacro
        line.new(prevLowBarMacro, prevOscLowMacro, bar_index[pLenMacro], oscAtLowPivotMacro, color = bullDivColorMacro, width = 1, style = line.style_solid, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLenMacro], oscAtLowPivotMacro, "BullM", style = label.style_label_up, color = color.new(bullDivColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if bearDivOverlayMacro
        line.new(prevHighBarMacro, prevOscHighMacro, bar_index[pLenMacro], oscAtHighPivotMacro, color = bearDivColorMacro, width = 1, style = line.style_solid, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLenMacro], oscAtHighPivotMacro, "BearM", style = label.style_label_down, color = color.new(bearDivColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if hiddenBullDivOverlayMacro
        line.new(prevLowBarMacro, prevOscLowMacro, bar_index[pLenMacro], oscAtLowPivotMacro, color = bullHiddenColorMacro, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLenMacro], oscAtLowPivotMacro, "hBullM", style = label.style_label_up, color = color.new(bullHiddenColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)
    if hiddenBearDivOverlayMacro
        line.new(prevHighBarMacro, prevOscHighMacro, bar_index[pLenMacro], oscAtHighPivotMacro, color = bearHiddenColorMacro, width = 1, style = line.style_dashed, xloc = xloc.bar_index)
        if showDivLabels
            label.new(bar_index[pLenMacro], oscAtHighPivotMacro, "hBearM", style = label.style_label_down, color = color.new(bearHiddenColorMacro, 30), textcolor = textColor, size = size.small, yloc = yloc.price)

// SHAPES - MICRO (circles) and MACRO (diamonds) on price chart
// Overlay mode (forceOverlay = true)
plotshape(bullDivOverlay and forceOverlay and showShapes, location = location.belowbar, style = shape.circle, size = size.tiny, color = bullDivColor, force_overlay = true)
plotshape(bearDivOverlay and forceOverlay and showShapes, location = location.abovebar, style = shape.circle, size = size.tiny, color = bearDivColor, force_overlay = true)
plotshape(hiddenBullDivOverlay and forceOverlay and showShapes, location = location.belowbar, style = shape.circle, size = size.tiny, color = bullHiddenColor, force_overlay = true)
plotshape(hiddenBearDivOverlay and forceOverlay and showShapes, location = location.abovebar, style = shape.circle, size = size.tiny, color = bearHiddenColor, force_overlay = true)

// MACRO - diamonds
plotshape(bullDivOverlayMacro and forceOverlay and showShapes, location = location.belowbar, style = shape.diamond, size = size.tiny, color = bullDivColorMacro, force_overlay = true)
plotshape(bearDivOverlayMacro and forceOverlay and showShapes, location = location.abovebar, style = shape.diamond, size = size.tiny, color = bearDivColorMacro, force_overlay = true)
plotshape(hiddenBullDivOverlayMacro and forceOverlay and showShapes, location = location.belowbar, style = shape.diamond, size = size.tiny, color = bullHiddenColorMacro, force_overlay = true)
plotshape(hiddenBearDivOverlayMacro and forceOverlay and showShapes, location = location.abovebar, style = shape.diamond, size = size.tiny, color = bearHiddenColorMacro, force_overlay = true)

// SHAPES in Oscillator mode - drawn on price chart (force_overlay = true)
plotshape(bullDivOsc and not forceOverlay and showShapes, location = location.belowbar, style = shape.circle, size = size.tiny, color = bullDivColor, force_overlay = true)
plotshape(bearDivOsc and not forceOverlay and showShapes, location = location.abovebar, style = shape.circle, size = size.tiny, color = bearDivColor, force_overlay = true)
plotshape(hiddenBullDivOsc and not forceOverlay and showShapes, location = location.belowbar, style = shape.circle, size = size.tiny, color = bullHiddenColor, force_overlay = true)
plotshape(hiddenBearDivOsc and not forceOverlay and showShapes, location = location.abovebar, style = shape.circle, size = size.tiny, color = bearHiddenColor, force_overlay = true)

// MACRO (diamonds) in oscillator mode - on price chart
plotshape(bullDivOscMacro and not forceOverlay and showShapes, location = location.belowbar, style = shape.diamond, size = size.tiny, color = bullDivColorMacro, force_overlay = true)
plotshape(bearDivOscMacro and not forceOverlay and showShapes, location = location.abovebar, style = shape.diamond, size = size.tiny, color = bearDivColorMacro, force_overlay = true)
plotshape(hiddenBullDivOscMacro and not forceOverlay and showShapes, location = location.belowbar, style = shape.diamond, size = size.tiny, color = bullHiddenColorMacro, force_overlay = true)
plotshape(hiddenBearDivOscMacro and not forceOverlay and showShapes, location = location.abovebar, style = shape.diamond, size = size.tiny, color = bearHiddenColorMacro, force_overlay = true)

// GRADIENT FILL (RSI ↔ 50)
pRSI = plot(rsi, color = na, display = display.none)
pMid = plot(50, color = na, display = display.none)

fill(pRSI, pMid,
     top_value = showRSIGradient and not na(rsi) and rsi > 50 ? rsi : na,
     bottom_value = showRSIGradient and not na(rsi) and rsi > 50 ? 50 : na,
     top_color = showRSIGradient and not na(rsi) and rsi > 50 ? c_bull_peak : na,
     bottom_color = showRSIGradient and not na(rsi) and rsi > 50 ? c_bull_mid : na)

fill(pMid, pRSI,
     top_value = showRSIGradient and not na(rsi) and rsi < 50 ? 50 : na,
     bottom_value = showRSIGradient and not na(rsi) and rsi < 50 ? rsi : na,
     top_color = showRSIGradient and not na(rsi) and rsi < 50 ? c_bear_mid : na,
     bottom_color = showRSIGradient and not na(rsi) and rsi < 50 ? c_bear_peak : na)

// PLOTS
plot(rsi, title = 'RSI', color = rsiLineColor, linewidth = 2)
plot(showSmoothedRsi ? smoothedRsi : na, title = "Smoothed RSI", color = colSmoothedRSILine, linewidth = 2)

hline(50, title = 'Midline', color = color.gray, linestyle = hline.style_dashed)
hline(obLevelRSI, title = 'Overbought', color = colOverbought, linestyle = hline.style_dashed)
hline(osLevelRSI, title = 'Oversold', color = colOversold, linestyle = hline.style_dashed)

// ALERTS 
alertcondition(bullDivOverlay or bullDivOsc, 
     title = "Regular Bullish Divergence (MICRO)", 
     message = "Regular Bullish Divergence (MICRO) detected")

alertcondition(bearDivOverlay or bearDivOsc, 
     title = "Regular Bearish Divergence (MICRO)", 
     message = "Regular Bearish Divergence (MICRO) detected")

alertcondition(hiddenBullDivOverlay or hiddenBullDivOsc, 
     title = "Hidden Bullish Divergence (MICRO)", 
     message = "Hidden Bullish Divergence (MICRO) detected")

alertcondition(hiddenBearDivOverlay or hiddenBearDivOsc, 
     title = "Hidden Bearish Divergence (MICRO)", 
     message = "Hidden Bearish Divergence (MICRO) detected")

// MACRO alerts
alertcondition(bullDivOverlayMacro or bullDivOscMacro, 
     title = "Regular Bullish Divergence (MACRO)", 
     message = "Regular Bullish Divergence (MACRO) detected")

alertcondition(bearDivOverlayMacro or bearDivOscMacro, 
     title = "Regular Bearish Divergence (MACRO)", 
     message = "Regular Bearish Divergence (MACRO) detected")

alertcondition(hiddenBullDivOverlayMacro or hiddenBullDivOscMacro, 
     title = "Hidden Bullish Divergence (MACRO)", 
     message = "Hidden Bullish Divergence (MACRO) detected")

alertcondition(hiddenBearDivOverlayMacro or hiddenBearDivOscMacro, 
     title = "Hidden Bearish Divergence (MACRO)", 
     message = "Hidden Bearish Divergence (MACRO) detected")
````
