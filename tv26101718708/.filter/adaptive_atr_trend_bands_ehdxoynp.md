# Adaptive ATR Trend Bands

- url: https://www.tradingview.com/script/EHdxoyNP-Adaptive-ATR-Trend-Bands/
- type: indicator
- pine_id: PUB;88efa65a9ce747f199103fee9805e4ce
- version: 1.0

## Description

Adaptive ATR Trend Bands is a volatility-based trend-state indicator built around a selectable moving average basis and ATR-derived upper/lower bands.

The script creates a dynamic channel around the selected basis type: EMA, SMA, or VWMA. Band width is calculated from ATR length and ATR multiplier settings. The area between the bands changes color according to the current trend state, making it easier to read whether price is operating in bullish or bearish conditions.

Trend shifts are detected when price breaks above the previous upper band from a bearish state or breaks below the previous lower band from a bullish state. When a bullish shift is confirmed, the script can print a LONG label. When a bearish shift is confirmed, the script can print a SHORT label.

[b]Main features:[/b]
• ATR-based upper and lower volatility bands;
• Selectable basis type: EMA, SMA, or VWMA;
• Optional basis line with direction-based coloring;
• Trend-state fill between the bands;
• Bullish and bearish trend shift labels;
• Minimum bar distance between repeated labels;
• Optional bar-close confirmation;
• Adaptive basis slope filter;
• Adaptive ATR expansion filter;
• Optional multi-timeframe RSI filter;
• Optional higher-timeframe EMA trend filter;
• Alert conditions for bullish and bearish trend shifts.

The adaptive slope filter checks whether the basis line has enough directional movement relative to current ATR conditions. This helps reduce labels when the basis is too flat and price movement is less directional.

The adaptive ATR expansion filter compares current ATR with its own average for the active chart timeframe. This helps reduce labels during lower-volatility conditions where band breaks may be less meaningful.

The optional multi-timeframe RSI filter uses the previous completed RSI value from the selected higher timeframe. Bullish shifts are allowed when the higher-timeframe RSI is in the lower zone, while bearish shifts are allowed when the higher-timeframe RSI is in the upper zone.

The optional higher-timeframe EMA filter uses the previous completed higher-timeframe close and EMA value. Bullish shifts are allowed when the higher-timeframe close is above the EMA. Bearish shifts are allowed when the higher-timeframe close is below the EMA.

[b]Practical use:[/b]
The bands can be used to read volatility-based trend structure. A bullish label marks a confirmed shift from bearish to bullish conditions according to the band break and enabled filters. A bearish label marks a confirmed shift from bullish to bearish conditions according to the band break and enabled filters.

[i]This script is intended for chart analysis and educational use.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0

//@version=6
indicator("Adaptive ATR Trend Bands", overlay = true)


// INPUTS

groupBands   = "Band Settings"
groupSignals = "Signal Settings"
groupFilters = "Filter Settings"

basisType = input.string("EMA", "Basis Type", options = ["EMA", "SMA", "VWMA"], group = groupBands)
basisLen  = input.int(100, "Basis Length", minval = 1, group = groupBands)

atrLen  = input.int(14, "ATR Length", minval = 1, group = groupBands)
atrMult = input.float(3.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = groupBands)

showMiddleBand      = input.bool(true, "Show Basis Line", group = groupBands)
middleColorLookback = input.int(1, "Basis Direction Lookback", minval = 1, group = groupBands)

showLabels     = input.bool(true, "Show Trend Shift Labels", group = groupSignals)
onlyClosedBars = input.bool(true, "Confirm Signals On Bar Close", group = groupSignals)

minBarsBetweenSignals = input.int(10, "Minimum Bars Between Labels", minval = 0, group = groupSignals)

useRsiFilter = input.bool(false, "Use MTF RSI Filter", group = groupFilters)
rsiMtfTf     = input.timeframe("720", "RSI Filter Timeframe", group = groupFilters)
rsiLen       = input.int(14, "RSI Length", minval = 1, group = groupFilters)

useHtfFilter = input.bool(false, "Use HTF EMA Filter", group = groupFilters)
htfTf        = input.timeframe("60", "HTF Filter Timeframe", group = groupFilters)
htfEmaLen    = input.int(100, "HTF EMA Length", minval = 1, group = groupFilters)


// HELPERS

f_basis(string type, series float price, int length) =>
    switch type
        "SMA"  => ta.sma(price, length)
        "VWMA" => ta.vwma(price, length)
        => ta.ema(price, length)


// BASE BANDS

basis    = f_basis(basisType, close, basisLen)
atrValue = ta.atr(atrLen)

rawUpperBand = basis + atrValue * atrMult
rawLowerBand = basis - atrValue * atrMult


// FINAL BAND LEVELS

var float finalUpperBand = na
var float finalLowerBand = na

finalUpperBand :=
     na(finalUpperBand[1]) ? rawUpperBand :
     rawUpperBand < finalUpperBand[1] or close[1] > finalUpperBand[1] ? rawUpperBand :
     finalUpperBand[1]

finalLowerBand :=
     na(finalLowerBand[1]) ? rawLowerBand :
     rawLowerBand > finalLowerBand[1] or close[1] < finalLowerBand[1] ? rawLowerBand :
     finalLowerBand[1]


// ADAPTIVE FILTERS

tfSeconds = timeframe.in_seconds(timeframe.period)

isVeryFastTf = not na(tfSeconds) and tfSeconds <= 300
isFastTf     = not na(tfSeconds) and tfSeconds > 300 and tfSeconds <= 900
isMediumTf   = not na(tfSeconds) and tfSeconds > 900 and tfSeconds <= 3600
isSlowTf     = not na(tfSeconds) and tfSeconds > 3600 and tfSeconds <= 14400

basisSlope =
     isVeryFastTf ? basis - basis[8] :
     isFastTf     ? basis - basis[6] :
     isMediumTf   ? basis - basis[5] :
     isSlowTf     ? basis - basis[4] :
     basis - basis[3]

atrAverage =
     isVeryFastTf ? ta.ema(atrValue, 100) :
     isFastTf     ? ta.ema(atrValue, 80) :
     isMediumTf   ? ta.ema(atrValue, 60) :
     isSlowTf     ? ta.ema(atrValue, 50) :
     ta.ema(atrValue, 40)

slopeAtrRatio = atrValue > 0 ? math.abs(basisSlope) / atrValue : 0.0

slopeRatioAverage =
     isVeryFastTf ? ta.ema(slopeAtrRatio, 100) :
     isFastTf     ? ta.ema(slopeAtrRatio, 80) :
     isMediumTf   ? ta.ema(slopeAtrRatio, 60) :
     isSlowTf     ? ta.ema(slopeAtrRatio, 50) :
     ta.ema(slopeAtrRatio, 40)

adaptiveSlopeStrength = math.max(0.05, math.min(0.30, slopeRatioAverage * 0.60))

longSlopeOk =
     basisSlope > atrValue * adaptiveSlopeStrength

shortSlopeOk =
     basisSlope < -atrValue * adaptiveSlopeStrength

atrRatio = atrAverage > 0 ? atrValue / atrAverage : 1.0

atrRatioAverage =
     isVeryFastTf ? ta.ema(atrRatio, 100) :
     isFastTf     ? ta.ema(atrRatio, 80) :
     isMediumTf   ? ta.ema(atrRatio, 60) :
     isSlowTf     ? ta.ema(atrRatio, 50) :
     ta.ema(atrRatio, 40)

adaptiveAtrExpansion = math.max(0.70, math.min(1.10, atrRatioAverage * 0.85))

atrOk =
     atrRatio >= adaptiveAtrExpansion


// MTF RSI FILTER

rsiMtfValue = request.security(syminfo.tickerid, rsiMtfTf, ta.rsi(close, rsiLen)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

longRsiOk =
     not useRsiFilter or
     rsiMtfValue <= 30

shortRsiOk =
     not useRsiFilter or
     rsiMtfValue >= 70


// HTF EMA FILTER

htfClose = request.security(syminfo.tickerid, htfTf, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

longHtfOk =
     not useHtfFilter or
     htfClose > htfEma

shortHtfOk =
     not useHtfFilter or
     htfClose < htfEma

longFiltersOk  = atrOk and longSlopeOk and longRsiOk and longHtfOk
shortFiltersOk = atrOk and shortSlopeOk and shortRsiOk and shortHtfOk


// TREND STATE

var int trendState = 0

previousTrendState = nz(trendState[1], 0)

closedBarOk = not onlyClosedBars or barstate.isconfirmed

longBreak  = close > nz(finalUpperBand[1], rawUpperBand)
shortBreak = close < nz(finalLowerBand[1], rawLowerBand)

if closedBarOk
    if previousTrendState == 0
        trendState := close >= basis ? 1 : -1
    else if previousTrendState == -1 and longBreak and longFiltersOk
        trendState := 1
    else if previousTrendState == 1 and shortBreak and shortFiltersOk
        trendState := -1
    else
        trendState := previousTrendState
else
    trendState := previousTrendState


// LABEL CONDITIONS

var int lastSignalDirection = 0
var int lastSignalBar = na

barsFromLastSignal = na(lastSignalBar) ? 100000 : bar_index - lastSignalBar
cooldownOk = barsFromLastSignal >= minBarsBetweenSignals

rawLongSignal =
     trendState == 1 and
     previousTrendState == -1

rawShortSignal =
     trendState == -1 and
     previousTrendState == 1

longSignal =
     rawLongSignal and
     lastSignalDirection != 1 and
     cooldownOk

shortSignal =
     rawShortSignal and
     lastSignalDirection != -1 and
     cooldownOk

if longSignal
    lastSignalDirection := 1
    lastSignalBar := bar_index

if shortSignal
    lastSignalDirection := -1
    lastSignalBar := bar_index


// BASIS LINE COLOR

middleLineUp   = basis > basis[middleColorLookback]
middleLineDown = basis < basis[middleColorLookback]

middleLineColor =
     middleLineUp ? color.new(color.lime, 0) :
     middleLineDown ? color.new(color.red, 0) :
     color.new(color.gray, 0)


// PLOTS

bandColor =
     trendState == 1 ? color.new(color.lime, 85) :
     trendState == -1 ? color.new(color.red, 85) :
     color.new(color.gray, 90)

upperPlot = plot(rawUpperBand, "Upper Band", color = color.new(color.gray, 0), linewidth = 1)
lowerPlot = plot(rawLowerBand, "Lower Band", color = color.new(color.gray, 0), linewidth = 1)

plot(showMiddleBand ? basis : na, "Basis Line", color = middleLineColor, linewidth = 2)

fill(upperPlot, lowerPlot, color = bandColor, title = "Trend Band Fill")


// LABELS

plotshape(showLabels and longSignal, title = "Bullish Trend Shift", style = shape.labelup, location = location.belowbar, text = "LONG", color = color.new(color.lime, 0), textcolor = color.white, size = size.normal)

plotshape(showLabels and shortSignal, title = "Bearish Trend Shift", style = shape.labeldown, location = location.abovebar, text = "SHORT", color = color.new(color.red, 0), textcolor = color.white, size = size.normal)


// ALERTS

alertcondition(longSignal, title = "Bullish Trend Shift", message = "Bullish trend shift on {{ticker}} at {{close}}")
alertcondition(shortSignal, title = "Bearish Trend Shift", message = "Bearish trend shift on {{ticker}} at {{close}}")
````
