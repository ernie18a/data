# Obsidian Divergence Ledger [JOAT]

- url: https://www.tradingview.com/script/TmPruv7o-Obsidian-Divergence-Ledger-JOAT/
- type: indicator
- pine_id: PUB;88c3286df5bb400d9984249da8bc398d
- version: 1.0

## Description

[b]Obsidian Divergence Ledger [JOAT][/b]

[b]Introduction[/b]

Obsidian Divergence Ledger is an open-source divergence engine built around confirmed pivot logic and a composite oscillator. It tracks regular and hidden divergence, draws ledger lines between the relevant pivot points, and can optionally project those same relationships onto price. The design is meant to make divergence readable as a structured event instead of a vague visual impression.

The problem this script solves is that many divergence tools are either too loose or too noisy. They often compare incompatible pivots, ignore volatility context, or signal before the pivot is confirmed. Obsidian avoids that by waiting for confirmed pivot structures, enforcing minimum spread requirements, and optionally filtering signals through baseline context and volatility expansion.

[image]https://www.tradingview.com/x/m34W6dCg/[/image]

[b]Core Concepts[/b]

[b]1. Composite Oscillator Construction[/b]

The script does not depend on one oscillator only. It blends RSI, CMO, and ROC into one composite measure, then normalizes and smooths it. This helps reduce the chance that one indicator-specific quirk dominates the entire divergence decision.

[b]2. Pivot-Confirmed Divergence Logic[/b]

Divergence is only evaluated after `ta.pivothigh()` and `ta.pivotlow()` confirm the turning points. That means the signal appears later than an unconfirmed visual guess, but it also means the structure is stable and suitable for non-repainting use.

[pine]
pricePivotHigh = ta.pivothigh(high, leftBars, rightBars)
pricePivotLow  = ta.pivotlow(low, leftBars, rightBars)
[/pine]

[b]3. Regular and Hidden Divergence[/b]

The script distinguishes between reversal-type divergence and continuation-type divergence:

[list]
[*][b]Regular bullish:[/b] price makes a lower low while the oscillator makes a higher low
[*][b]Regular bearish:[/b] price makes a higher high while the oscillator makes a lower high
[*][b]Hidden bullish:[/b] price makes a higher low while the oscillator makes a lower low
[*][b]Hidden bearish:[/b] price makes a lower high while the oscillator makes a higher high
[/list]

[b]4. Ledger Line Visualization and Divergence Zoning[/b]

Each confirmed event is recorded visually with lines on the oscillator pane. When enabled, price-side lines are also drawn on the main chart using `force_overlay = true`. Regular divergence and hidden divergence use different color families and line styles so reversal and continuation structures are easy to distinguish. Fresh divergence events can also paint oscillator-side pivot zones and price-side context boxes so the compared structure is visible as an area, not just a single line.

[b]5. Context, Freshness, and Impulse Framing[/b]

The script tracks whether a divergence is still fresh, whether it aligns with baseline context, and whether current volatility supports the signal. A central impulse ribbon and intensity band expand and contract with current state strength so the pane itself carries more information even when the dashboard is kept compact.

[b]Features[/b]

[list]
[*][b]Composite oscillator:[/b] RSI, CMO, and ROC blended into one smoother divergence source
[*][b]Confirmed pivots only:[/b] No divergence state is confirmed before pivot confirmation
[*][b]Regular and hidden divergence:[/b] Reversal and continuation structures handled separately
[*][b]Optional volatility filter:[/b] Can require expansion before accepting signals
[*][b]Optional baseline filter:[/b] Can require directional context relative to a baseline
[*][b]Oscillator and price ledger lines:[/b] Divergence is drawn in both the pane and the price chart when enabled
[*][b]Oscillator pivot zones:[/b] Fresh divergence events can stamp colored zones around the compared oscillator pivots
[*][b]Price context boxes:[/b] The related price swing area can be boxed directly on the chart for faster structural reading
[*][b]On-chart divergence tags:[/b] Compact labels identify regular-vs-hidden bullish and bearish events on the chart itself
[*][b]Impulse ribbon and intensity band:[/b] The pane carries fresh-state emphasis through layered fills, not only through text
[*][b]Compact dashboard summary:[/b] State, freshness, oscillator bias, and context remain available in a smaller top-right panel
[/list]

[b]Input Parameters[/b]

[b]Composite Oscillator:[/b]
[list]
[*]RSI Length
[*]CMO Length
[*]ROC Length
[*]Normalization Window
[*]Oscillator Smoothing
[/list]

[b]Divergence Engine:[/b]
[list]
[*]Pivot Left Bars and Pivot Right Bars
[*]Hidden Divergence toggle
[*]Maximum Ledger Lines
[/list]

[b]Quality Filters:[/b]
[list]
[*]Volatility Expansion toggle and length
[*]Baseline Context toggle and baseline length
[*]Minimum Oscillator Pivot Spread
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Wait for a Confirmed State[/b]
Use the dashboard's State and Freshness rows first. The script is designed to treat confirmed divergence as the event, not the early suspicion of divergence.

[b]Step 2: Separate Reversal From Continuation[/b]
Regular divergence is generally more useful when looking for exhaustion. Hidden divergence is generally more useful when looking for pullback continuation. The script keeps those two ideas separate on purpose.

[b]Step 3: Read Context Before Weighting the Signal[/b]
A bullish divergence below a weak baseline can still fail. A bearish divergence into expanding volatility can still continue. Use the Context and Volatility rows before deciding how much weight to give the latest signal.

[b]Step 4: Use the Zones, Not Only the Lines[/b]
The oscillator pivot zones and price context boxes are there to show the compared structure as an area. This is useful when a divergence is technically valid but forms in a narrow or low-importance pocket. A wider, cleaner zone often carries more practical significance than a tiny local pivot mismatch.

[b]Step 5: Use the Price Overlay Lines as Reference[/b]
The overlay lines show the exact price pivots involved in the latest comparison. The companion price labels and boxes make it easier to judge whether the divergence formed in an important location or in minor local noise.

[b]Indicator Limitations[/b]

[list]
[*]Pivot confirmation creates intentional delay because the script waits for bars on the right side of each pivot
[*]Divergence can persist through multiple additional swings before price meaningfully reverses
[*]A composite oscillator reduces single-indicator bias but cannot eliminate false positives
[*]Hidden divergence is context-dependent and is less useful if the broader trend is weak or unclear
[*]Fresh divergence boxes and labels describe the compared structure, but they do not guarantee that the marked zone will react again
[/list]

[b]Originality Statement[/b]

Obsidian Divergence Ledger is original in the way it structures divergence as a confirmed ledger of relationships rather than a simple shape marker. The script combines a custom composite oscillator, explicit regular-vs-hidden separation, freshness tracking, context filters, synchronized pane-plus-price ledger lines, oscillator pivot zoning, and price-context divergence boxes into one coherent tool.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice. Divergence is a contextual condition, not a guarantee of reversal or continuation. False signals can occur frequently, especially in strong trends and low-liquidity markets. Use independent confirmation and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Obsidian Divergence Ledger [JOAT]", shorttitle="Obsidian Ledger [JOAT]", overlay=false, max_bars_back=5000, max_lines_count=120, max_labels_count=20, max_boxes_count=20)

//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
string grpOsc = "Composite Oscillator"
string grpDiv = "Divergence Engine"
string grpFilter = "Quality Filters"
string grpVisual = "Visual System"
string grpDash = "Dashboard"

//------------------------------------------------------------------------------
// Oscillator inputs
//------------------------------------------------------------------------------
src = input.source(close, "Source", group=grpOsc)
rsiLength = input.int(14, "RSI Length", minval=2, maxval=100, group=grpOsc)
cmoLength = input.int(18, "CMO Length", minval=2, maxval=100, group=grpOsc)
rocLength = input.int(9, "ROC Length", minval=1, maxval=50, group=grpOsc)
normalizeWindow = input.int(100, "Normalization Window", minval=20, maxval=400, group=grpOsc)
oscSmooth = input.int(5, "Oscillator Smoothing", minval=1, maxval=20, group=grpOsc)

//------------------------------------------------------------------------------
// Divergence inputs
//------------------------------------------------------------------------------
leftBars = input.int(5, "Pivot Left Bars", minval=1, maxval=20, group=grpDiv)
rightBars = input.int(5, "Pivot Right Bars", minval=1, maxval=20, group=grpDiv)
allowHidden = input.bool(true, "Enable Hidden Divergence", group=grpDiv)
maxLedgerLines = input.int(14, "Max Ledger Lines", minval=4, maxval=30, group=grpDiv)

//------------------------------------------------------------------------------
// Quality filter inputs
//------------------------------------------------------------------------------
useVolatilityFilter = input.bool(true, "Require Volatility Expansion", group=grpFilter)
volatilityLength = input.int(20, "Volatility Length", minval=5, maxval=100, group=grpFilter)
useTrendFilter = input.bool(true, "Require Baseline Context", group=grpFilter)
baselineLength = input.int(55, "Baseline Length", minval=5, maxval=200, group=grpFilter)
minimumSpread = input.float(0.15, "Minimum Oscillator Pivot Spread", minval=0.0, maxval=5.0, step=0.05, group=grpFilter)

//------------------------------------------------------------------------------
// Visual inputs
//------------------------------------------------------------------------------
themeMode = input.string("Graphite Ember", "Theme", options=["Graphite Ember", "Harbor Ink", "Cinder Moss"], group=grpVisual)
showLedgerLines = input.bool(true, "Show Ledger Lines", group=grpVisual)
showPriceOverlay = input.bool(true, "Show Price Overlay Lines", group=grpVisual)
showComposite = input.bool(true, "Show Composite Oscillator", group=grpVisual)
showSignalBand = input.bool(true, "Show Divergence Intensity Band", group=grpVisual)
showBackgroundState = input.bool(true, "Show State Background", group=grpVisual)
showPivotZones = input.bool(true, "Show Pivot Zones", group=grpVisual)
showSignalLabels = input.bool(true, "Show Divergence Labels", group=grpVisual)
showPriceLevelZones = input.bool(true, "Show Price Context Zones", group=grpVisual)
showImpulseRibbon = input.bool(true, "Show Impulse Ribbon", group=grpVisual)

//------------------------------------------------------------------------------
// Dashboard inputs
//------------------------------------------------------------------------------
showDashboard = input.bool(true, "Show Dashboard", group=grpDash)
dashboardPosition = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
dashboardSize = input.string("Medium", "Size", options=["Small", "Medium", "Large"], group=grpDash)

//------------------------------------------------------------------------------
// Theme colors
//------------------------------------------------------------------------------
var color bullCore = color.new(#4ac59a, 0)
var color bearCore = color.new(#d97b68, 0)
var color hiddenBullCore = color.new(#8bc4e8, 0)
var color hiddenBearCore = color.new(#bea070, 0)
var color neutralCore = color.new(#98a4b2, 0)
var color accentCore = color.new(#d3b07a, 0)
var color panelBg = color.new(#10151d, 0)
var color panelBgSoft = color.new(#171d27, 0)
var color panelBorder = color.new(#2a3441, 0)
var color textMain = color.new(#e7edf5, 0)
var color textDim = color.new(#90a0b3, 0)

if barstate.isfirst
    if themeMode == "Graphite Ember"
        bullCore := color.new(#49c39a, 0)
        bearCore := color.new(#cf7664, 0)
        hiddenBullCore := color.new(#86b9e1, 0)
        hiddenBearCore := color.new(#c0a06e, 0)
        accentCore := color.new(#d6b07a, 0)
    else if themeMode == "Harbor Ink"
        bullCore := color.new(#63b9b8, 0)
        bearCore := color.new(#ce7682, 0)
        hiddenBullCore := color.new(#8da9d3, 0)
        hiddenBearCore := color.new(#d0b58d, 0)
        accentCore := color.new(#8fb3d1, 0)
        panelBg := color.new(#0f141d, 0)
        panelBgSoft := color.new(#16202c, 0)
        panelBorder := color.new(#2f3b4e, 0)
    else
        bullCore := color.new(#6ec08d, 0)
        bearCore := color.new(#d78663, 0)
        hiddenBullCore := color.new(#9cb6d2, 0)
        hiddenBearCore := color.new(#c9b07f, 0)
        accentCore := color.new(#9abf9a, 0)
        panelBg := color.new(#111814, 0)
        panelBgSoft := color.new(#18201c, 0)
        panelBorder := color.new(#324038, 0)

//------------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------------
f_safe_div(float num, float den, float fallback) =>
    math.abs(den) > 1e-10 ? num / den : fallback

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_zscore(float seriesValue, int len) =>
    meanValue = ta.sma(seriesValue, len)
    deviation = ta.stdev(seriesValue, len)
    deviation > 0 ? (seriesValue - meanValue) / deviation : 0.0

f_scale_unit(float seriesValue, int len) =>
    lowValue = ta.lowest(seriesValue, len)
    highValue = ta.highest(seriesValue, len)
    f_safe_div(seriesValue - lowValue, highValue - lowValue, 0.5)

f_table_pos(string positionInput) =>
    if positionInput == "Top Right"
        position.top_right
    else if positionInput == "Top Left"
        position.top_left
    else if positionInput == "Bottom Right"
        position.bottom_right
    else
        position.bottom_left

f_table_size(string sizeInput) =>
    if sizeInput == "Small"
        size.small
    else if sizeInput == "Large"
        size.large
    else
        size.normal

f_trim_lines(array<line> lnArray, int maxCount) =>
    while array.size(lnArray) > maxCount
        oldLine = array.shift(lnArray)
        line.delete(oldLine)

f_trim_boxes(array<box> bxArray, int maxCount) =>
    while array.size(bxArray) > maxCount
        oldBox = array.shift(bxArray)
        box.delete(oldBox)

f_trim_labels(array<label> lbArray, int maxCount) =>
    while array.size(lbArray) > maxCount
        oldLabel = array.shift(lbArray)
        label.delete(oldLabel)

f_signal_text(int stateValue) =>
    stateValue == 2 ? "Regular Bullish" :
     stateValue == 1 ? "Hidden Bullish" :
     stateValue == -1 ? "Hidden Bearish" :
     stateValue == -2 ? "Regular Bearish" :
     "Neutral"

//------------------------------------------------------------------------------
// Composite oscillator
//------------------------------------------------------------------------------
rsiCore = ta.rsi(src, rsiLength)
cmoCore = ta.cmo(src, cmoLength)
rocCore = ta.roc(src, rocLength)

rsiUnit = f_scale_unit(rsiCore, normalizeWindow)
cmoUnit = f_scale_unit(cmoCore, normalizeWindow)
rocUnit = f_scale_unit(rocCore, normalizeWindow)

compositeRaw = (rsiUnit * 0.40 + cmoUnit * 0.35 + rocUnit * 0.25) * 100.0
composite = ta.ema(compositeRaw, oscSmooth)
compositeSlope = composite - nz(composite[1], composite)
compositeStrength = ta.ema(math.abs(compositeSlope), 10)

baseline = ta.ema(close, baselineLength)
volatilityState = ta.atr(volatilityLength) / math.max(ta.sma(ta.atr(volatilityLength), volatilityLength), syminfo.mintick)

upperGuide = 70.0
lowerGuide = 30.0
midGuide = 50.0

//------------------------------------------------------------------------------
// Pivot storage
//------------------------------------------------------------------------------
type PivotLedger
    int bar
    float osc
    float price

var array<PivotLedger> highPivots = array.new<PivotLedger>()
var array<PivotLedger> lowPivots = array.new<PivotLedger>()
var array<line> oscLedgerLines = array.new<line>()
var array<line> priceLedgerLines = array.new<line>()
var array<box> oscSignalZones = array.new<box>()
var array<box> priceSignalZones = array.new<box>()
var array<label> signalLabels = array.new<label>()

oscPivotHigh = ta.pivothigh(composite, leftBars, rightBars)
oscPivotLow = ta.pivotlow(composite, leftBars, rightBars)

if not na(oscPivotHigh)
    pivotBar = bar_index - rightBars
    array.push(highPivots, PivotLedger.new(pivotBar, oscPivotHigh, high[rightBars]))
    if array.size(highPivots) > 12
        array.shift(highPivots)

if not na(oscPivotLow)
    pivotBar = bar_index - rightBars
    array.push(lowPivots, PivotLedger.new(pivotBar, oscPivotLow, low[rightBars]))
    if array.size(lowPivots) > 12
        array.shift(lowPivots)

//------------------------------------------------------------------------------
// Divergence engine
//------------------------------------------------------------------------------
var int divergenceState = 0
var int lastDivergenceBar = na
var float intensityScore = 0.0

divergenceState := 0
intensityScore := 0.0

if barstate.isconfirmed and array.size(highPivots) >= 2
    recentHigh = array.get(highPivots, array.size(highPivots) - 1)
    previousHigh = array.get(highPivots, array.size(highPivots) - 2)
    oscSpread = math.abs(recentHigh.osc - previousHigh.osc)
    regularBear = recentHigh.price > previousHigh.price and recentHigh.osc < previousHigh.osc
    hiddenBear = recentHigh.price < previousHigh.price and recentHigh.osc > previousHigh.osc
    volatilityPass = not useVolatilityFilter or volatilityState > 1.0
    trendPassBear = not useTrendFilter or close < baseline
    spreadPassBear = oscSpread >= minimumSpread
    if regularBear and volatilityPass and trendPassBear and spreadPassBear
        divergenceState := -2
        lastDivergenceBar := recentHigh.bar
        intensityScore := oscSpread + math.abs(recentHigh.price - previousHigh.price) / math.max(ta.atr(14), syminfo.mintick)
        if showLedgerLines
            array.push(oscLedgerLines, line.new(previousHigh.bar, previousHigh.osc, recentHigh.bar, recentHigh.osc, xloc=xloc.bar_index, color=bearCore, width=2))
        if showPriceOverlay
            array.push(priceLedgerLines, line.new(previousHigh.bar, previousHigh.price, recentHigh.bar, recentHigh.price, xloc=xloc.bar_index, color=bearCore, width=2, force_overlay=true))
        if showPivotZones
            zoneTop = math.max(previousHigh.osc, recentHigh.osc) + 6.0
            zoneBottom = math.min(previousHigh.osc, recentHigh.osc) - 3.0
            array.push(oscSignalZones, box.new(previousHigh.bar, zoneTop, recentHigh.bar + 10, zoneBottom, xloc=xloc.bar_index, border_color=color.new(bearCore, 30), bgcolor=color.new(bearCore, 88), border_width=2))
        if showPriceLevelZones
            priceTop = math.max(previousHigh.price, recentHigh.price)
            priceBottom = math.min(previousHigh.price, recentHigh.price) - ta.atr(14) * 0.18
            array.push(priceSignalZones, box.new(previousHigh.bar, priceTop, recentHigh.bar + 10, priceBottom, xloc=xloc.bar_index, border_color=color.new(bearCore, 35), bgcolor=color.new(bearCore, 90), border_width=1, force_overlay=true))
        if showSignalLabels
            array.push(signalLabels, label.new(recentHigh.bar + 1, recentHigh.osc, "Regular Bearish\nLedger", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(bearCore, 8), textcolor=textMain, size=size.small))
            array.push(signalLabels, label.new(recentHigh.bar + 1, recentHigh.price, "RBR", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearCore, 0), textcolor=color.white, size=size.tiny, force_overlay=true))
    else if allowHidden and hiddenBear and volatilityPass and trendPassBear and spreadPassBear
        divergenceState := -1
        lastDivergenceBar := recentHigh.bar
        intensityScore := oscSpread + math.abs(recentHigh.price - previousHigh.price) / math.max(ta.atr(14), syminfo.mintick)
        if showLedgerLines
            array.push(oscLedgerLines, line.new(previousHigh.bar, previousHigh.osc, recentHigh.bar, recentHigh.osc, xloc=xloc.bar_index, color=hiddenBearCore, width=2, style=line.style_dotted))
        if showPriceOverlay
            array.push(priceLedgerLines, line.new(previousHigh.bar, previousHigh.price, recentHigh.bar, recentHigh.price, xloc=xloc.bar_index, color=hiddenBearCore, width=2, style=line.style_dotted, force_overlay=true))
        if showPivotZones
            zoneTop = math.max(previousHigh.osc, recentHigh.osc) + 5.0
            zoneBottom = math.min(previousHigh.osc, recentHigh.osc) - 2.0
            array.push(oscSignalZones, box.new(previousHigh.bar, zoneTop, recentHigh.bar + 10, zoneBottom, xloc=xloc.bar_index, border_color=color.new(hiddenBearCore, 35), bgcolor=color.new(hiddenBearCore, 90), border_width=1))
        if showPriceLevelZones
            priceTop = math.max(previousHigh.price, recentHigh.price)
            priceBottom = math.min(previousHigh.price, recentHigh.price) - ta.atr(14) * 0.12
            array.push(priceSignalZones, box.new(previousHigh.bar, priceTop, recentHigh.bar + 10, priceBottom, xloc=xloc.bar_index, border_color=color.new(hiddenBearCore, 40), bgcolor=color.new(hiddenBearCore, 92), border_width=1, force_overlay=true))
        if showSignalLabels
            array.push(signalLabels, label.new(recentHigh.bar + 1, recentHigh.osc, "Hidden Bearish\nLedger", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(hiddenBearCore, 10), textcolor=textMain, size=size.small))
            array.push(signalLabels, label.new(recentHigh.bar + 1, recentHigh.price, "HBR", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(hiddenBearCore, 0), textcolor=color.white, size=size.tiny, force_overlay=true))

if barstate.isconfirmed and array.size(lowPivots) >= 2 and divergenceState == 0
    recentLow = array.get(lowPivots, array.size(lowPivots) - 1)
    previousLow = array.get(lowPivots, array.size(lowPivots) - 2)
    oscSpread = math.abs(recentLow.osc - previousLow.osc)
    regularBull = recentLow.price < previousLow.price and recentLow.osc > previousLow.osc
    hiddenBull = recentLow.price > previousLow.price and recentLow.osc < previousLow.osc
    volatilityPass = not useVolatilityFilter or volatilityState > 1.0
    trendPassBull = not useTrendFilter or close > baseline
    spreadPassBull = oscSpread >= minimumSpread
    if regularBull and volatilityPass and trendPassBull and spreadPassBull
        divergenceState := 2
        lastDivergenceBar := recentLow.bar
        intensityScore := oscSpread + math.abs(recentLow.price - previousLow.price) / math.max(ta.atr(14), syminfo.mintick)
        if showLedgerLines
            array.push(oscLedgerLines, line.new(previousLow.bar, previousLow.osc, recentLow.bar, recentLow.osc, xloc=xloc.bar_index, color=bullCore, width=2))
        if showPriceOverlay
            array.push(priceLedgerLines, line.new(previousLow.bar, previousLow.price, recentLow.bar, recentLow.price, xloc=xloc.bar_index, color=bullCore, width=2, force_overlay=true))
        if showPivotZones
            zoneTop = math.max(previousLow.osc, recentLow.osc) + 3.0
            zoneBottom = math.min(previousLow.osc, recentLow.osc) - 6.0
            array.push(oscSignalZones, box.new(previousLow.bar, zoneTop, recentLow.bar + 10, zoneBottom, xloc=xloc.bar_index, border_color=color.new(bullCore, 30), bgcolor=color.new(bullCore, 88), border_width=2))
        if showPriceLevelZones
            priceTop = math.max(previousLow.price, recentLow.price) + ta.atr(14) * 0.18
            priceBottom = math.min(previousLow.price, recentLow.price)
            array.push(priceSignalZones, box.new(previousLow.bar, priceTop, recentLow.bar + 10, priceBottom, xloc=xloc.bar_index, border_color=color.new(bullCore, 35), bgcolor=color.new(bullCore, 90), border_width=1, force_overlay=true))
        if showSignalLabels
            array.push(signalLabels, label.new(recentLow.bar + 1, recentLow.osc, "Regular Bullish\nLedger", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(bullCore, 8), textcolor=textMain, size=size.small))
            array.push(signalLabels, label.new(recentLow.bar + 1, recentLow.price, "RB", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullCore, 0), textcolor=color.white, size=size.tiny, force_overlay=true))
    else if allowHidden and hiddenBull and volatilityPass and trendPassBull and spreadPassBull
        divergenceState := 1
        lastDivergenceBar := recentLow.bar
        intensityScore := oscSpread + math.abs(recentLow.price - previousLow.price) / math.max(ta.atr(14), syminfo.mintick)
        if showLedgerLines
            array.push(oscLedgerLines, line.new(previousLow.bar, previousLow.osc, recentLow.bar, recentLow.osc, xloc=xloc.bar_index, color=hiddenBullCore, width=2, style=line.style_dotted))
        if showPriceOverlay
            array.push(priceLedgerLines, line.new(previousLow.bar, previousLow.price, recentLow.bar, recentLow.price, xloc=xloc.bar_index, color=hiddenBullCore, width=2, style=line.style_dotted, force_overlay=true))
        if showPivotZones
            zoneTop = math.max(previousLow.osc, recentLow.osc) + 2.0
            zoneBottom = math.min(previousLow.osc, recentLow.osc) - 5.0
            array.push(oscSignalZones, box.new(previousLow.bar, zoneTop, recentLow.bar + 10, zoneBottom, xloc=xloc.bar_index, border_color=color.new(hiddenBullCore, 35), bgcolor=color.new(hiddenBullCore, 90), border_width=1))
        if showPriceLevelZones
            priceTop = math.max(previousLow.price, recentLow.price) + ta.atr(14) * 0.12
            priceBottom = math.min(previousLow.price, recentLow.price)
            array.push(priceSignalZones, box.new(previousLow.bar, priceTop, recentLow.bar + 10, priceBottom, xloc=xloc.bar_index, border_color=color.new(hiddenBullCore, 40), bgcolor=color.new(hiddenBullCore, 92), border_width=1, force_overlay=true))
        if showSignalLabels
            array.push(signalLabels, label.new(recentLow.bar + 1, recentLow.osc, "Hidden Bullish\nLedger", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(hiddenBullCore, 10), textcolor=textMain, size=size.small))
            array.push(signalLabels, label.new(recentLow.bar + 1, recentLow.price, "HB", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(hiddenBullCore, 0), textcolor=color.white, size=size.tiny, force_overlay=true))

f_trim_lines(oscLedgerLines, maxLedgerLines)
f_trim_lines(priceLedgerLines, maxLedgerLines)
f_trim_boxes(oscSignalZones, 8)
f_trim_boxes(priceSignalZones, 8)
f_trim_labels(signalLabels, 12)

recentSignalAge = not na(lastDivergenceBar) ? bar_index - lastDivergenceBar : 999
signalIsFresh = recentSignalAge <= (leftBars + rightBars + 6)

signalColor = divergenceState == 2 ? bullCore :
     divergenceState == 1 ? hiddenBullCore :
     divergenceState == -1 ? hiddenBearCore :
     divergenceState == -2 ? bearCore :
     neutralCore

backgroundColor = divergenceState == 2 ? color.new(bullCore, 90) :
     divergenceState == 1 ? color.new(hiddenBullCore, 90) :
     divergenceState == -1 ? color.new(hiddenBearCore, 90) :
     divergenceState == -2 ? color.new(bearCore, 90) :
     na

//------------------------------------------------------------------------------
// Plot layer
//------------------------------------------------------------------------------
plot(upperGuide, "Upper Guide", color.new(bearCore, 70), 1, plot.style_line)
plot(midGuide, "Mid Guide", color.new(neutralCore, 70), 1, plot.style_line)
plot(lowerGuide, "Lower Guide", color.new(bullCore, 70), 1, plot.style_line)

oscColor = composite >= midGuide ? color.from_gradient(composite, 50.0, 100.0, color.new(neutralCore, 10), bullCore) : color.from_gradient(composite, 0.0, 50.0, bearCore, color.new(neutralCore, 10))
plot(showComposite ? composite : na, "Composite Oscillator", oscColor, 2)
plot(showComposite ? composite : na, "Composite Glow", color.new(oscColor, 70), 5)

impulseTop = plot(showImpulseRibbon ? 50.0 + math.min(compositeStrength * 10.0, 16.0) : na, "Impulse Top", color.new(signalColor, 100), 1)
impulseBottom = plot(showImpulseRibbon ? 50.0 - math.min(compositeStrength * 10.0, 16.0) : na, "Impulse Bottom", color.new(signalColor, 100), 1)
fill(impulseTop, impulseBottom, showImpulseRibbon ? color.new(signalColor, signalIsFresh ? 84 : 92) : na)

bullBiasRibbon = plot(showImpulseRibbon and composite >= midGuide ? composite : na, "Bull Bias Ribbon", color.new(bullCore, 80), 2)
bearBiasRibbon = plot(showImpulseRibbon and composite < midGuide ? composite : na, "Bear Bias Ribbon", color.new(bearCore, 80), 2)
midRibbon = plot(showImpulseRibbon ? midGuide : na, "Mid Ribbon", color.new(neutralCore, 100), 1)
fill(bullBiasRibbon, midRibbon, showImpulseRibbon ? color.new(bullCore, 90) : na)
fill(bearBiasRibbon, midRibbon, showImpulseRibbon ? color.new(bearCore, 90) : na)

bandTop = plot(showSignalBand ? 50.0 + math.min(intensityScore * 4.0, 18.0) : na, "Intensity Top", color.new(signalColor, 100), 1)
bandBot = plot(showSignalBand ? 50.0 - math.min(intensityScore * 4.0, 18.0) : na, "Intensity Bottom", color.new(signalColor, 100), 1)
fill(bandTop, bandBot, showSignalBand and signalIsFresh ? color.new(signalColor, 88) : na)

plot(signalIsFresh and divergenceState > 0 ? composite : na, "Bull Ledger Mark", color.new(signalColor, 0), 3, plot.style_circles)
plot(signalIsFresh and divergenceState < 0 ? composite : na, "Bear Ledger Mark", color.new(signalColor, 0), 3, plot.style_circles)

bgcolor(showBackgroundState and signalIsFresh ? backgroundColor : na, title="Divergence State")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(panelBg, 0), border_width=1, border_color=color.new(panelBorder, 0), frame_width=1, frame_color=color.new(panelBorder, 30))

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 4)
    dashSize = size.normal
    directionText = composite > midGuide ? "Positive" : composite < midGuide ? "Negative" : "Neutral"
    contextText = close > baseline ? "Above Baseline" : close < baseline ? "Below Baseline" : "At Baseline"
    freshnessText = signalIsFresh ? "Fresh" : "Aged"
    stateText = f_signal_text(divergenceState)
    intensityText = str.tostring(intensityScore, "#.##")
    volatilityText = volatilityState > 1.2 ? "Expanded" : volatilityState < 0.9 ? "Quiet" : "Balanced"

    table.cell(dash, 0, 0, "Divergence Summary", text_color=textMain, text_size=dashSize, bgcolor=panelBgSoft, text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period, text_color=accentCore, text_size=size.small, bgcolor=panelBgSoft, text_halign=text.align_right)
    table.cell(dash, 0, 1, "State", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 1, stateText, text_color=signalColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Freshness", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 2, freshnessText, text_color=signalIsFresh ? signalColor : neutralCore, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Oscillator Bias", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 3, directionText, text_color=oscColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Context", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 4, contextText, text_color=close > baseline ? bullCore : close < baseline ? bearCore : neutralCore, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
else if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 4)
//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
regularBullConfirmed = barstate.isconfirmed and divergenceState == 2
hiddenBullConfirmed = barstate.isconfirmed and divergenceState == 1
hiddenBearConfirmed = barstate.isconfirmed and divergenceState == -1
regularBearConfirmed = barstate.isconfirmed and divergenceState == -2

alertcondition(regularBullConfirmed, "Obsidian Regular Bullish", "Obsidian ledger confirmed a regular bullish divergence.")
alertcondition(hiddenBullConfirmed, "Obsidian Hidden Bullish", "Obsidian ledger confirmed a hidden bullish divergence.")
alertcondition(hiddenBearConfirmed, "Obsidian Hidden Bearish", "Obsidian ledger confirmed a hidden bearish divergence.")
alertcondition(regularBearConfirmed, "Obsidian Regular Bearish", "Obsidian ledger confirmed a regular bearish divergence.")
````
