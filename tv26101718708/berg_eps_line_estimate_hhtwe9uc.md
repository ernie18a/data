# Berg EPS Line + Estimate

- url: https://www.tradingview.com/script/hhtWe9uC-Berg-EPS-Line-Estimate/
- type: indicator
- pine_id: PUB;8a7425d7a67348c4abbcf8a4abb93d3b
- version: 1.0

## Description

The Moving Average Trend System is a clean, powerful, and easy-to-use technical analysis indicator designed to help traders identify market direction, trend strength, potential entry zones, and possible reversal areas using a structured moving average methodology.

This indicator is built around one of the most widely used concepts in technical analysis: moving averages. By smoothing price action and filtering out short-term market noise, moving averages allow traders to focus on the broader market structure and make more objective trading decisions.

The purpose of this tool is to provide a clearer visual representation of trend behavior across different market conditions. Whether the market is trending upward, trending downward, consolidating, or preparing for a possible breakout, this indicator helps traders interpret price movement with greater confidence.

## Source Code

````pine
//@version=6
indicator("Berg EPS Line + Estimate", shorttitle="Berg EPS", overlay=true, scale=scale.none, max_labels_count=500)

// ==============================================================================
// BERG EPS LINE + ESTIMATE
// ==============================================================================

grpEPS = "EPS Line"

showEPSLine        = input.bool(true, "Show EPS Line", group=grpEPS)
showEPSTooltips    = input.bool(true, "Show Earnings Tooltip Markers", group=grpEPS)

epsLineSource      = input.string(
     "TTM Actual",
     "EPS Line Source",
     options=["TTM Actual", "TTM Standardized", "Quarterly Actual", "Quarterly Standardized"],
     group=grpEPS
)

useEventSmoothing  = input.bool(true, "Event Smoothing", group=grpEPS)
smoothingLength    = input.int(2, "Smoothing Length", minval=1, maxval=10, group=grpEPS)

// Use -1 quando quiser alinhar o earnings ao candle anterior.
epsDateShiftBars   = input.int(-1, "Earnings Date Shift Bars", minval=-5, maxval=0, group=grpEPS)

tooltipDateMode    = input.string(
     "Visual Marker Date",
     "Tooltip Date Mode",
     options=["Visual Marker Date", "TradingView Event Date"],
     group=grpEPS
)

epsLineColor       = input.color(color.rgb(55, 170, 65), "EPS Line Color", group=grpEPS)
epsLineWidth       = input.int(2, "EPS Line Width", minval=1, maxval=5, group=grpEPS)

epsTickColor       = input.color(color.rgb(55, 170, 65), "Earnings Tick Color", group=grpEPS)
epsTickSizeInput   = input.string("Normal", "Earnings Tick Size", options=["Tiny", "Small", "Normal", "Large"], group=grpEPS)

currencySymbol     = input.string("$", "Currency Symbol", group=grpEPS)
epsDecimals        = input.int(2, "EPS Decimals", minval=0, maxval=4, group=grpEPS)
pctDecimals        = input.int(1, "% Decimals", minval=0, maxval=3, group=grpEPS)

maxEarningsMarkers = input.int(450, "Max Earnings Tooltip Markers", minval=20, maxval=500, group=grpEPS)

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

epsTickSize() =>
    epsTickSizeInput == "Tiny" ? size.tiny :
     epsTickSizeInput == "Small" ? size.small :
     epsTickSizeInput == "Large" ? size.large : size.normal

visualMarkerTime() =>
    int result = time

    if tooltipDateMode == "Visual Marker Date"
        if epsDateShiftBars == -5 and not na(time[5])
            result := time[5]
        else if epsDateShiftBars == -4 and not na(time[4])
            result := time[4]
        else if epsDateShiftBars == -3 and not na(time[3])
            result := time[3]
        else if epsDateShiftBars == -2 and not na(time[2])
            result := time[2]
        else if epsDateShiftBars == -1 and not na(time[1])
            result := time[1]

    result

// ==============================================================================
// DATA
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

isEventActual = not na(epsActual)
isEventStd    = not na(epsStandardized)

// ==============================================================================
// TTM SERIES
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

epsLineBase =
     epsLineSource == "TTM Actual" ? epsTTMActual :
     epsLineSource == "TTM Standardized" ? epsTTMStd :
     epsLineSource == "Quarterly Standardized" ? epsStandardized :
     epsActual

// ==============================================================================
// EVENT-BASED SMOOTHING
// ==============================================================================

isLineEvent = not na(epsLineBase)

alpha = smoothingLength <= 1 ? 1.0 : 2.0 / (smoothingLength + 1.0)

var float epsEventEma = na

if isLineEvent
    epsEventEma := na(epsEventEma[1]) ? epsLineBase : epsEventEma[1] + alpha * (epsLineBase - epsEventEma[1])
else
    epsEventEma := epsEventEma[1]

epsLineSeries = isLineEvent ? (useEventSmoothing ? epsEventEma : epsLineBase) : na

// ==============================================================================
// TOOLTIP METRICS
// ==============================================================================

epsLastYear = ta.valuewhen(isEventActual, epsActual, 4)

epsSurprise = not na(epsActual) and not na(epsEstimate) and epsEstimate != 0 ?
     ((epsActual - epsEstimate) / math.abs(epsEstimate)) * 100 : na

// ==============================================================================
// EPS LINE
// ==============================================================================

plot(
     showEPSLine ? epsLineSeries : na,
     title="EPS Line",
     color=epsLineColor,
     linewidth=epsLineWidth,
     style=plot.style_line,
     display=display.all - display.status_line,
     offset=epsDateShiftBars
)

// ==============================================================================
// TOOLTIP MARKERS
// ==============================================================================

var label[] epsMarkers = array.new_label()

if showEPSTooltips and not na(epsLineSeries)
    int tooltipTime = visualMarkerTime()

    string tooltipText =
         str.format_time(tooltipTime, "MM/dd/yyyy") +
         "\nReported: " + formatEPS(epsActual) +
         "\nEstimate: " + formatEPS(epsEstimate) +
         "\nSurprise: " + formatPct(epsSurprise) +
         "\nvs Last Year: " + formatEPS(epsLastYear)

    label epsMarker = label.new(
         bar_index + epsDateShiftBars,
         epsLineSeries,
         "│",
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=epsTickColor,
         size=epsTickSize(),
         tooltip=tooltipText,
         yloc=yloc.price
    )

    array.push(epsMarkers, epsMarker)

if array.size(epsMarkers) > maxEarningsMarkers
    label oldMarker = array.shift(epsMarkers)
    label.delete(oldMarker)

if not showEPSTooltips and array.size(epsMarkers) > 0
    f_clear_labels(epsMarkers)
````
