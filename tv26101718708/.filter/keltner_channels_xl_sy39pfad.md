# Keltner Channels XL

- url: https://www.tradingview.com/script/sy39PfAD-Keltner-Channels-XL/
- type: indicator
- pine_id: PUB;b85f8b5056914bdbb4b6d50429223ab1
- version: 6.0

## Description

This script plots a Keltner Channel built around a user-selected moving average (EMA or SMA) of price. The upper and lower bands are derived by adding and subtracting a volatility measure, which can be based on ATR, True Range, or a smoothed high–low range.

Trend direction is determined by measuring the percentage change of the basis line over a configurable lookback period. That change is compared against a neutral threshold, which defaults to 0.05%. If the basis rises more than this threshold, it is classified as an uptrend; if it falls more than the threshold, it is classified as a downtrend. If the movement stays within that range, it is treated as neutral, meaning the market is effectively moving sideways.

The basis line is plotted with increased thickness and changes color based on this trend classification. The channel bands and background fill adopt the same color, so the entire channel visually reflects whether the market is trending up, trending down, or consolidating.

## Source Code

````pine
//@version=6
indicator(title="Keltner Channels XL", shorttitle="Keltner XL", overlay=true, max_polylines_count=100)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
noRepaint = input.bool(true, "Non-Repainting Mode", tooltip="When enabled, all calculations use confirmed closed bars only (src[1] instead of current bar). Eliminates repainting at the cost of 1-bar lag.")

grpCore = "General"
length = input.int(200, "Basis Length", minval=1, group=grpCore)
mult = input.float(1.0, "Multiplier", step=0.1, group=grpCore)
src = input.source(close, "Source", group=grpCore)
basisType = input.string("Simple MA", "Basis Type", options=["Simple MA", "Exponential MA", "Weighted MA", "Smoothed MA (RMA)", "Volume Weighted MA", "Hull MA", "Double EMA", "Triple EMA", "Arnaud Legoux MA", "Least Squares MA"], group=grpCore)
almaOffset = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.01, group=grpCore, tooltip="Only used when Basis Type = Arnaud Legoux MA.")
almaSigma  = input.float(6.0, "ALMA Sigma", minval=0.0, step=0.5, group=grpCore, tooltip="Only used when Basis Type = Arnaud Legoux MA.")
lsmaOffset = input.int(0, "LSMA Offset", group=grpCore, tooltip="Only used when Basis Type = Least Squares MA.")

grpTrendLine = "Trendline Style"
showBasis = input.bool(true, "Show Basis Line", group=grpTrendLine)
basisColor = input.color(color.black, "Trendline Color", group=grpTrendLine)
basisWidth = input.int(2, "Trendline Thickness", minval=1, maxval=4, group=grpTrendLine)
basisStyleStr = input.string("Solid", "Trendline Style", options=["Solid", "Dashed", "Dotted"], group=grpTrendLine)

grpBands = "Bands"
showBands = input.bool(true, "Show Band Lines", group=grpBands)
bandsStyle = input.string("Average True Range", "Bands Style", options=["Average True Range", "True Range", "Range"], group=grpBands)
atrLength = input.int(200, "ATR Length", minval=1, group=grpBands)
bandWidth = input.int(1, "Band Thickness", minval=1, maxval=4, group=grpBands)
bandStyleStr = input.string("Solid", "Band Line Style", options=["Solid", "Dashed", "Dotted"], group=grpBands)

grpTrend = "Channel Background"
colorMode = input.string("MonoColor", "Background Mode", options=["None", "MonoColor", "Trend Color"], group=grpTrend)
monoColor = input.color(color.new(color.gray, 50), "MonoColor", group=grpTrend)
trendLookback = input.int(10, "Slope Lookback (bars)", minval=1, maxval=200, step=1, group=grpTrend)
upColor = input.color(color.new(color.lime, 70), "Uptrend Color", group=grpTrend)
downColor = input.color(color.new(color.red, 70), "Downtrend Color", group=grpTrend)
neutralThresholdAtr = input.float(0.25, "Neutral Slope Threshold ATR", minval=0.0, maxval=2.0, step=0.01, group=grpTrend)
flatColor = input.color(color.new(color.gray, 70), "Flat/Neutral Color", group=grpTrend)

//────────────────────────────────────
// Calculations
//────────────────────────────────────
resolvedSrc = noRepaint ? src[1] : src

_sma  = ta.sma(resolvedSrc, length)
_ema  = ta.ema(resolvedSrc, length)
_wma  = ta.wma(resolvedSrc, length)
_rma  = ta.rma(resolvedSrc, length)
_vwma = ta.vwma(resolvedSrc, length)
_hma  = ta.wma(2 * ta.wma(resolvedSrc, int(length / 2)) - ta.wma(resolvedSrc, length), int(math.round(math.sqrt(length))))

_ema1 = _ema
_ema2 = ta.ema(_ema1, length)
_ema3 = ta.ema(_ema2, length)
_dema = 2 * _ema1 - _ema2
_tema = 3 * (_ema1 - _ema2) + _ema3

_alma = ta.alma(resolvedSrc, length, almaOffset, almaSigma)
_lsma = ta.linreg(resolvedSrc, length, lsmaOffset)

basis = switch basisType
    "Simple MA"          => _sma
    "Exponential MA"     => _ema
    "Weighted MA"        => _wma
    "Smoothed MA (RMA)"  => _rma
    "Volume Weighted MA" => _vwma
    "Hull MA"            => _hma
    "Double EMA"         => _dema
    "Triple EMA"         => _tema
    "Arnaud Legoux MA"   => _alma
    "Least Squares MA"   => _lsma
    => _sma

float rangeMa = na
if bandsStyle == "True Range"
    rangeMa := ta.tr(true)
else if bandsStyle == "Average True Range"
    rangeMa := ta.atr(atrLength)
else
    rangeMa := ta.rma(high - low, length)

upper = basis + rangeMa * mult
lower = basis - rangeMa * mult

basisChange = basis - basis[trendLookback]
normalizer = ta.atr(atrLength)
normalizedAtrChange = normalizer != 0 ? basisChange / normalizer : 0.0

isUpTrend   = colorMode == "Trend Color" and normalizedAtrChange >  neutralThresholdAtr
isDownTrend = colorMode == "Trend Color" and normalizedAtrChange < -neutralThresholdAtr

activeFillColor =
     colorMode == "MonoColor"     ? color.new(monoColor, 50)
     : colorMode == "Trend Color" ?
         isUpTrend   ? upColor :
         isDownTrend ? downColor :
         flatColor
     : color.new(color.black, 100)

//────────────────────────────────────
// Line-style resolution
//────────────────────────────────────
bandsSolid = bandStyleStr == "Solid"
basisSolid = basisStyleStr == "Solid"

// Solid renders via plot(); non-solid is plotted transparent and drawn as a polyline.
upperPlotColor = (showBands and bandsSolid) ? basisColor : color.new(basisColor, 100)
lowerPlotColor = (showBands and bandsSolid) ? basisColor : color.new(basisColor, 100)
basisPlotColor = (showBasis and basisSolid) ? basisColor : color.new(basisColor, 100)

//────────────────────────────────────
// Plots (fill + solid rendering)
//────────────────────────────────────
u = plot(upper, color=upperPlotColor, linewidth=bandWidth, editable=false)
plot(basis, color=basisPlotColor, linewidth=basisWidth, editable=false)
l = plot(lower, color=lowerPlotColor, linewidth=bandWidth, editable=false)

fill(u, l, color=activeFillColor)

//────────────────────────────────────
// Dashed / Dotted rendering via polylines (full history)
//────────────────────────────────────
maxPts = 10000

var array<chart.point> upperPts = array.new<chart.point>()
var array<chart.point> lowerPts = array.new<chart.point>()
var array<chart.point> basisPts = array.new<chart.point>()

collectPts(arr, doCollect, y) =>
    if doCollect and not na(y)
        arr.push(chart.point.from_index(bar_index, y))
        if arr.size() > maxPts
            arr.shift()

// Collect only for lines that need a non-solid style (saves memory).
if barstate.isconfirmed
    collectPts(upperPts, showBands and not bandsSolid, upper)
    collectPts(lowerPts, showBands and not bandsSolid, lower)
    collectPts(basisPts, showBasis and not basisSolid, basis)

var polyline upperPoly = na
var polyline lowerPoly = na
var polyline basisPoly = na

styleOf(styleStr) => styleStr == "Dashed" ? line.style_dashed : line.style_dotted

if barstate.islast
    polyline.delete(upperPoly)
    polyline.delete(lowerPoly)
    polyline.delete(basisPoly)

    if showBands and not bandsSolid and upperPts.size() > 1
        upperPoly := polyline.new(upperPts, xloc=xloc.bar_index, line_color=basisColor, line_style=styleOf(bandStyleStr), line_width=bandWidth)
    if showBands and not bandsSolid and lowerPts.size() > 1
        lowerPoly := polyline.new(lowerPts, xloc=xloc.bar_index, line_color=basisColor, line_style=styleOf(bandStyleStr), line_width=bandWidth)
    if showBasis and not basisSolid and basisPts.size() > 1
        basisPoly := polyline.new(basisPts, xloc=xloc.bar_index, line_color=basisColor, line_style=styleOf(basisStyleStr), line_width=basisWidth)
````
