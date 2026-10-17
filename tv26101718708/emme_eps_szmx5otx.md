# EMME EPS 

- url: https://www.tradingview.com/script/Szmx5oTX-EMME-EPS/
- type: indicator
- pine_id: PUB;1be27ea10f3a4e31807aeeb9112fde0f
- version: 1.0

## Description

Main Features

Moving Averages
The script displays important moving averages to help identify the stock’s trend, trend alignment, and potential areas of support or resistance.

Relative Strength
Relative strength helps compare the stock’s performance against the broader market, allowing traders to identify names that are outperforming or underperforming.

Volume Analysis
The volume component helps highlight unusual activity and confirms whether a price move is supported by strong institutional participation or increased market interest.

How I Use It

This script is mainly intended for stock traders looking for momentum setups, especially when a stock is:

Trending above key moving averages
Showing relative strength versus the market
Breaking out or moving with increased volume
Building constructive bases or continuation patterns

The goal is not to predict price movements, but to make it easier to quickly evaluate whether a stock has the technical characteristics of a strong momentum candidate.

## Source Code

````pine
//@version=6
indicator("Berg EPS Flat Line + Estimate", shorttitle="Berg EPS Flat", overlay=false, max_labels_count=500, max_bars_back=5000)

// ==============================================================================
// BERG EPS FLAT LINE + ESTIMATE — SEPARATE PANEL / TOTALLY FLAT
// ==============================================================================

grpEPS = "EPS Line"

showEPSLine        = input.bool(true, "Show EPS Line", group=grpEPS)
showEPSTooltips    = input.bool(true, "Show Earnings Tooltip Markers", group=grpEPS)
showNextEarnings   = input.bool(true, "Show Next Earnings Marker", group=grpEPS)

epsLineSource      = input.string(
     "TTM Actual",
     "EPS Line Source",
     options=["TTM Actual", "TTM Standardized", "Quarterly Actual", "Quarterly Standardized"],
     group=grpEPS
)

epsLineColor       = input.color(color.rgb(55, 170, 65), "EPS Line Color", group=grpEPS)
epsLineWidth       = input.int(2, "EPS Line Width", minval=1, maxval=5, group=grpEPS)

epsTickColor       = input.color(color.rgb(55, 170, 65), "Earnings Tick Color", group=grpEPS)
nextEpsTickColor   = input.color(color.rgb(255, 190, 0), "Next Earnings Marker Color", group=grpEPS)

epsMarkerShapeInput     = input.string("Tick", "Earnings Marker Shape", options=["Tick", "Dot"], group=grpEPS)
nextEpsMarkerShapeInput = input.string("Dot", "Next Earnings Marker Shape", options=["Tick", "Dot"], group=grpEPS)

epsTickSizeInput   = input.string("Small", "Earnings Marker Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpEPS)

currencySymbol     = input.string("$", "Currency Symbol", group=grpEPS)
epsDecimals        = input.int(2, "EPS Decimals", minval=0, maxval=4, group=grpEPS)
pctDecimals        = input.int(1, "% Decimals", minval=0, maxval=3, group=grpEPS)

flatLineLevel      = input.float(1.0, "Flat Line Level", step=0.1, group=grpEPS)

maxEarningsMarkers = input.int(120, "Max Earnings Markers", minval=20, maxval=450, group=grpEPS)

// ==============================================================================
// HELPERS
// ==============================================================================

f_clear_labels(_arr) =>
    if array.size(_arr) > 0
        for _i = 0 to array.size(_arr) - 1
            label.delete(array.get(_arr, _i))
        array.clear(_arr)

epsFormatString() =>
    epsDecimals == 0 ? "#0" :
     epsDecimals == 1 ? "#0.0" :
     epsDecimals == 2 ? "#0.00" :
     epsDecimals == 3 ? "#0.000" : "#0.0000"

pctFormatString() =>
    pctDecimals == 0 ? "#0" :
     pctDecimals == 1 ? "#0.0" :
     pctDecimals == 2 ? "#0.00" : "#0.000"

formatEPS(float val) =>
    na(val) ? "N/A" : currencySymbol + str.tostring(val, epsFormatString())

formatPct(float val) =>
    na(val) ? "N/A" : (val >= 0 ? "+" : "") + str.tostring(val, pctFormatString()) + "%"

formatRevenue(float val) =>
    string result = "N/A"
    if not na(val)
        float absVal = math.abs(val)
        if absVal >= 1e12
            result := currencySymbol + str.tostring(val / 1e12, "#.##") + "T"
        else if absVal >= 1e9
            result := currencySymbol + str.tostring(val / 1e9, "#.##") + "B"
        else if absVal >= 1e6
            result := currencySymbol + str.tostring(val / 1e6, "#.##") + "M"
        else if absVal >= 1e3
            result := currencySymbol + str.tostring(val / 1e3, "#.##") + "K"
        else
            result := currencySymbol + str.tostring(val, "#.##")
    result

epsTickSize() =>
    epsTickSizeInput == "Tiny" ? size.tiny :
     epsTickSizeInput == "Small" ? size.small :
     epsTickSizeInput == "Normal" ? size.normal :
     epsTickSizeInput == "Large" ? size.large : size.huge

epsDotSize() =>
    epsTickSizeInput == "Tiny" ? size.small :
     epsTickSizeInput == "Small" ? size.normal :
     epsTickSizeInput == "Normal" ? size.large : size.huge

markerSize(_shapeInput) =>
    _shapeInput == "Dot" ? epsDotSize() : epsTickSize()

formatDate(int val) =>
    na(val) ? "N/A" : str.format_time(val, "MM/dd/yyyy")

markerText(_shapeInput) =>
    _shapeInput == "Dot" ? "⬤" : "│"

// ==============================================================================
// EPS DATA
// ==============================================================================

epsActual = request.earnings(
     syminfo.tickerid,
     earnings.actual,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

epsEstimate = request.earnings(
     syminfo.tickerid,
     earnings.estimate,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

epsStandardized = request.earnings(
     syminfo.tickerid,
     earnings.standardized,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

nextEarningsTime    = earnings.future_time
nextEarningsEPS     = earnings.future_eps
nextEarningsRevenue = earnings.future_revenue

isEventActual = not na(epsActual)
isEventStd    = not na(epsStandardized)

// ==============================================================================
// REVENUE DATA
// ==============================================================================

revenueRaw = request.financial(
     syminfo.tickerid,
     "TOTAL_REVENUE",
     "FQ",
     gaps=barmerge.gaps_on,
     ignore_invalid_symbol=true
)

revenueEstimateRaw = request.financial(
     syminfo.tickerid,
     "SALES_ESTIMATES",
     "FQ",
     gaps=barmerge.gaps_on,
     ignore_invalid_symbol=true
)

revenueCurrent = ta.valuewhen(not na(revenueRaw), revenueRaw, 0)
revenueEstimateCurrent = ta.valuewhen(not na(revenueEstimateRaw), revenueEstimateRaw, 0)
revenueLastYear = ta.valuewhen(not na(revenueRaw), revenueRaw, 4)

revenueYoY = not na(revenueCurrent) and not na(revenueLastYear) and revenueLastYear != 0 ?
     ((revenueCurrent - revenueLastYear) / math.abs(revenueLastYear)) * 100 : na

// ==============================================================================
// TTM EPS SERIES
// ==============================================================================

qAct0 = ta.valuewhen(isEventActual, epsActual, 0)
qAct1 = ta.valuewhen(isEventActual, epsActual, 1)
qAct2 = ta.valuewhen(isEventActual, epsActual, 2)
qAct3 = ta.valuewhen(isEventActual, epsActual, 3)

qStd0 = ta.valuewhen(isEventStd, epsStandardized, 0)
qStd1 = ta.valuewhen(isEventStd, epsStandardized, 1)
qStd2 = ta.valuewhen(isEventStd, epsStandardized, 2)
qStd3 = ta.valuewhen(isEventStd, epsStandardized, 3)

epsTTMActual = isEventActual and not na(qAct0) and not na(qAct1) and not na(qAct2) and not na(qAct3) ? qAct0 + qAct1 + qAct2 + qAct3 : na
epsTTMStd    = isEventStd and not na(qStd0) and not na(qStd1) and not na(qStd2) and not na(qStd3) ? qStd0 + qStd1 + qStd2 + qStd3 : na

// ==============================================================================
// LINE SERIES SELECTION
// ==============================================================================

epsLineRaw =
     epsLineSource == "TTM Actual" ? epsTTMActual :
     epsLineSource == "TTM Standardized" ? epsTTMStd :
     epsLineSource == "Quarterly Standardized" ? epsStandardized :
     epsActual

// ==============================================================================
// EPS TOOLTIP METRICS
// ==============================================================================

epsLastYear = ta.valuewhen(isEventActual, epsActual, 4)

epsYoYChange = not na(epsActual) and not na(epsLastYear) and epsLastYear != 0 ?
     ((epsActual - epsLastYear) / math.abs(epsLastYear)) * 100 : na

epsSurprise = not na(epsActual) and not na(epsEstimate) and epsEstimate != 0 ?
     ((epsActual - epsEstimate) / math.abs(epsEstimate)) * 100 : na

nextEarningsLastYearEPS = ta.valuewhen(isEventActual, epsActual, 3)
nextEarningsEPSYoY = not na(nextEarningsEPS) and not na(nextEarningsLastYearEPS) and nextEarningsLastYearEPS != 0 ?
     ((nextEarningsEPS - nextEarningsLastYearEPS) / math.abs(nextEarningsLastYearEPS)) * 100 : na

nextEarningsLastYearRevenue = ta.valuewhen(not na(revenueRaw), revenueRaw, 3)
nextEarningsRevenueYoY = not na(nextEarningsRevenue) and not na(nextEarningsLastYearRevenue) and nextEarningsLastYearRevenue != 0 ?
     ((nextEarningsRevenue - nextEarningsLastYearRevenue) / math.abs(nextEarningsLastYearRevenue)) * 100 : na

// ==============================================================================
// FLAT EPS LINE
// ==============================================================================

plot(
     showEPSLine ? flatLineLevel : na,
     title="EPS Flat Line",
     color=epsLineColor,
     linewidth=epsLineWidth,
     style=plot.style_line,
     display=display.all - display.status_line
)

// ==============================================================================
// TOOLTIP MARKERS
// ==============================================================================

var label[] epsMarkers = array.new_label()
var label nextEpsMarker = na

if showEPSTooltips and not na(epsLineRaw)
    string tooltipText =
         str.format_time(time, "MM/dd/yyyy") +
         "\nReported EPS: " + formatEPS(epsActual) +
         "\nEstimated EPS: " + formatEPS(epsEstimate) +
         "\nEPS Surprise: " + formatPct(epsSurprise) +
         "\nLast Year EPS: " + formatEPS(epsLastYear) +
         "\nEPS YoY %: " + formatPct(epsYoYChange) +
         "\nRevenue: " + formatRevenue(revenueCurrent) +
         "\nEstimated Revenue: " + formatRevenue(revenueEstimateCurrent) +
         "\nRevenue YoY %: " + formatPct(revenueYoY)

    label epsMarker = label.new(
         bar_index,
         flatLineLevel,
         markerText(epsMarkerShapeInput),
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=epsTickColor,
         size=markerSize(epsMarkerShapeInput),
         tooltip=tooltipText,
         yloc=yloc.price
    )

    array.push(epsMarkers, epsMarker)

if array.size(epsMarkers) > maxEarningsMarkers
    label oldMarker = array.shift(epsMarkers)
    label.delete(oldMarker)

if not showEPSTooltips and array.size(epsMarkers) > 0
    f_clear_labels(epsMarkers)

if barstate.islast
    if not na(nextEpsMarker)
        label.delete(nextEpsMarker)
        nextEpsMarker := na

    if showNextEarnings and not na(nextEarningsTime)
        string nextTooltipText =
             "Next Earnings: " + formatDate(nextEarningsTime) +
             "\nEstimated EPS: " + formatEPS(nextEarningsEPS) +
             "\nEstimated Revenue: " + formatRevenue(nextEarningsRevenue) +
             "\nLast Year EPS: " + formatEPS(nextEarningsLastYearEPS) +
             "\nEstimated EPS YoY %: " + formatPct(nextEarningsEPSYoY) +
             "\nLast Year Revenue: " + formatRevenue(nextEarningsLastYearRevenue) +
             "\nEstimated Revenue YoY %: " + formatPct(nextEarningsRevenueYoY)

        nextEpsMarker := label.new(
             nextEarningsTime,
             flatLineLevel,
             markerText(nextEpsMarkerShapeInput),
             xloc=xloc.bar_time,
             style=label.style_none,
             color=color.new(color.black, 100),
             textcolor=nextEpsTickColor,
             size=markerSize(nextEpsMarkerShapeInput),
             tooltip=nextTooltipText,
             yloc=yloc.price
        )
````
