# Real Rate Mortgage Framework [Gabremoku]

- url: https://www.tradingview.com/script/drFPl7u8-Real-Rate-Mortgage-Framework-Gabremoku/
- type: indicator
- pine_id: PUB;1c7303fa8b9e400eb24415fee979d196
- version: 1.0

## Description

[b]Real Rate Mortgage Framework [/b]is a macro context indicator that estimates a simplified real-rate proxy by subtracting CPI YoY from a nominal government yield series. It is designed to help users assess borrowing conditions from a broader economic perspective, rather than to predict a specific mortgage quote or lender offer.

The script currently includes preset configurations for the United States and Italy, and it also supports custom sources so the framework can be extended to additional countries without changing the core logic. This modular structure makes the indicator suitable as a reusable framework for future country presets and custom macro implementations.

To make the output easier to read, the real-rate proxy is classified into four clearly labeled regimes: Excellent Rate, Good Rate, Acceptable Rate, and High Rate. These labels are paired with a color structure that makes the current macro environment immediately visible on the chart, in the label, and in the dashboard.

A moving average is applied to inflation to reduce the stair-step effect caused by monthly CPI updates and improve visual readability. The indicator also includes a summary dashboard, optional background regime shading, alerts, and a disclaimer so users can interpret the output as informational context rather than financial advice.

This script is intended for traders and investors who want a simple cross-country real-rate framework for macro analysis, mortgage context, and future expansion to additional national datasets. If you would like a new country or a different sovereign yield / inflation pair added, feel free to message me with your request so I can consider it for a future implementation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Real Rate Mortgage Framework [Gabremoku]", overlay=false, precision=2)


// ==============================================================================
// OVERVIEW
// ------------------------------------------------------------------------------
// This indicator builds a simplified macro framework for mortgage conditions.
//
// Core approximation:
//     Real Rate ≈ Nominal Government Yield - CPI YoY
//
// The script supports:
// - preset country configurations,
// - custom macro sources,
// - threshold-based regime classification,
// - contextual coloring,
// - dashboard output,
// - alert conditions.
//
// It is designed as a macro context tool, not as a direct mortgage quote.
// ==============================================================================


// ==============================================================================
// INPUTS: CORE CONFIGURATION
// ------------------------------------------------------------------------------
// These inputs define the active operating mode:
// - preset country mode,
// - or fully custom sources.
// They also control inflation smoothing.
// ==============================================================================
grpCore = "Core Setup"
modeInput = input.string("Preset Country", "Source Mode", options=["Preset Country", "Custom Sources"], group=grpCore)
countryInput = input.string("United States", "Country Preset", options=["United States", "Italy"], group=grpCore)
smoothLen = input.int(20, "Inflation Smoothing", minval=1, maxval=60, group=grpCore)


// ==============================================================================
// INPUTS: CUSTOM DATA SOURCES
// ------------------------------------------------------------------------------
// These inputs are used only when the script runs in Custom Sources mode.
// They allow future extensions without rewriting the core framework.
// ==============================================================================
grpCustom = "Custom Sources"
customNominalTicker = input.string("US10Y", "Custom Nominal Yield Ticker", group=grpCustom)
customInflationTicker = input.string("USIRYY", "Custom Inflation YoY Ticker", group=grpCustom)
customCountryLabel = input.string("Custom", "Custom Label", group=grpCustom)


// ==============================================================================
// INPUTS: THRESHOLDS
// ------------------------------------------------------------------------------
// These thresholds divide the real-rate proxy into three evaluation zones:
// - favorable,
// - acceptable,
// - unfavorable.
//
// Preset mode can use built-in thresholds, while custom mode can override them.
// ==============================================================================
grpThresholds = "Thresholds"
usePresetThresholds = input.bool(true, "Use Preset Thresholds", group=grpThresholds)
optimalThresholdInput = input.float(0.0, "Optimal Threshold (%)", step=0.1, group=grpThresholds)
acceptableThresholdInput = input.float(2.0, "Acceptable Threshold (%)", step=0.1, group=grpThresholds)


// ==============================================================================
// INPUTS: DISPLAY
// ------------------------------------------------------------------------------
// These toggles control optional visual components of the indicator.
// ==============================================================================
grpDisplay = "Display"
showLabelInput = input.bool(true, "Show Dynamic Label", group=grpDisplay)
showDashboardInput = input.bool(true, "Show Dashboard", group=grpDisplay)
showDisclaimerInput = input.bool(true, "Show Disclaimer", group=grpDisplay)
showBgZonesInput = input.bool(true, "Show Background Zones", group=grpDisplay)


// ==============================================================================
// INPUTS: DASHBOARD
// ------------------------------------------------------------------------------
// These inputs control the position and text size of the summary dashboard.
// ==============================================================================
grpDashboard = "Dashboard"
dashPosInput = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDashboard)
dashTextSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grpDashboard)


// ==============================================================================
// INPUTS: COLORS
// ------------------------------------------------------------------------------
// The color palette follows the current mortgage-condition hierarchy:
// - Excellent Rate  -> light green
// - Good Rate       -> dark green
// - Acceptable Rate -> yellow
// - High Rate       -> red
//
// Missing data is shown in gray.
// ==============================================================================
grpColors = "Colors"
excellentColor = input.color(color.rgb(76, 175, 80), "Excellent Rate", group=grpColors)
goodColor = input.color(color.rgb(0, 77, 64), "Good Rate", group=grpColors)
acceptableColor = input.color(color.rgb(255, 235, 59), "Acceptable Rate", group=grpColors)
highColor = input.color(color.rgb(255, 59, 72), "High Rate", group=grpColors)
missingDataColor = input.color(color.rgb(140, 140, 150), "Missing Data", group=grpColors)


// ==============================================================================
// HELPER FUNCTIONS
// ------------------------------------------------------------------------------
// This section centralizes reusable logic for:
// - preset ticker selection,
// - label resolution,
// - threshold selection,
// - regime classification,
// - dynamic color generation.
// ==============================================================================
f_getPresetNominalTicker(_country) =>
    _country == "Italy" ? "IT10Y" : "US10Y"

f_getPresetInflationTicker(_country) =>
    _country == "Italy" ? "ITIRYY" : "USIRYY"

f_getCountryLabel(_mode, _country, _customLabel) =>
    _mode == "Custom Sources" ? _customLabel : _country

f_getOptimalThreshold(_country) =>
    _country == "Italy" ? 0.0 : 0.0

f_getAcceptableThreshold(_country) =>
    _country == "Italy" ? 2.0 : 2.0

f_getAssessment(_value, _optimal, _acceptable) =>
    _value <= _optimal ? "FAVORABLE" : _value <= _acceptable ? "ACCEPTABLE" : "UNFAVORABLE"

f_getAssessmentLabel(_value, _optimal, _acceptable) =>
    _value <= _optimal ? "✅ FAVORABLE MOMENT" : _value <= _acceptable ? "⚠️ ACCEPTABLE MOMENT" : "❌ UNFAVORABLE MOMENT"

// Builds the line color using a value-sensitive gradient.
// Lower values transition between the green tones.
// Higher values transition from yellow toward red.
f_getGradientColor(_isValid, _value, _optimal, _acceptable, _excellent, _good, _acceptableColor, _high, _naColor) =>
    if not _isValid
        _naColor
    else if _value <= _optimal
        color.from_gradient(_value, -6.0, _optimal, _excellent, _good)
    else
        color.from_gradient(_value, _optimal, 4.0, _acceptableColor, _high)


// ==============================================================================
// SOURCE RESOLUTION
// ------------------------------------------------------------------------------
// This block resolves the active data sources and thresholds based on the
// selected mode.
// ==============================================================================
nominalTicker = modeInput == "Custom Sources" ? customNominalTicker : f_getPresetNominalTicker(countryInput)
inflationTicker = modeInput == "Custom Sources" ? customInflationTicker : f_getPresetInflationTicker(countryInput)
countryLabel = f_getCountryLabel(modeInput, countryInput, customCountryLabel)

presetOptimalThreshold = f_getOptimalThreshold(countryInput)
presetAcceptableThreshold = f_getAcceptableThreshold(countryInput)

optimalThreshold = usePresetThresholds and modeInput == "Preset Country" ? presetOptimalThreshold : optimalThresholdInput
acceptableThreshold = usePresetThresholds and modeInput == "Preset Country" ? presetAcceptableThreshold : acceptableThresholdInput


// ==============================================================================
// DATA REQUEST
// ------------------------------------------------------------------------------
// The script requests:
// - a nominal government yield series,
// - an inflation YoY series.
//
// Both are requested on the daily timeframe for stable rendering.
// ==============================================================================
nominalRate = request.security(nominalTicker, "D", close)
inflation = request.security(inflationTicker, "D", close)


// ==============================================================================
// CALCULATION
// ------------------------------------------------------------------------------
// Inflation is smoothed to reduce the visual stair-step effect.
// The real-rate proxy is then calculated as:
//
//     Real Rate = Nominal Yield - Smoothed Inflation
// ==============================================================================
inflationSmooth = ta.sma(inflation, smoothLen)
realRate = nominalRate - inflationSmooth
validData = not na(nominalRate) and not na(inflation)


// ==============================================================================
// CLASSIFICATION AND COLORS
// ------------------------------------------------------------------------------
// This block converts the real-rate proxy into:
// - a qualitative assessment,
// - a label string,
// - a dynamic line color,
// - and a matching background tone.
// ==============================================================================
assessment = validData ? f_getAssessment(realRate, optimalThreshold, acceptableThreshold) : "NO DATA"
assessmentText = validData ? f_getAssessmentLabel(realRate, optimalThreshold, acceptableThreshold) : "NO DATA"

lineColor = f_getGradientColor(validData, realRate, optimalThreshold, acceptableThreshold, excellentColor, goodColor, acceptableColor, highColor, missingDataColor)

// The background uses the same regime color with stronger transparency.
bgColor = validData ? color.new(lineColor, 88) : na


// ==============================================================================
// PLOTTING
// ------------------------------------------------------------------------------
// The plot shows the real-rate proxy together with the reference thresholds
// and an optional background regime overlay.
// ==============================================================================
plot(validData ? realRate : na, title="Real Rate", color=lineColor, linewidth=2)
hline(0, "Zero Line", color=color.new(color.white, 60), linestyle=hline.style_dashed, linewidth=1)
hline(optimalThreshold, "Optimal Threshold", color=color.new(goodColor, 40), linestyle=hline.style_dotted, linewidth=1)
hline(acceptableThreshold, "Acceptable Threshold", color=color.new(acceptableColor, 40), linestyle=hline.style_dotted, linewidth=1)

bgcolor(showBgZonesInput ? bgColor : na, title="Magnitude Background")


// ==============================================================================
// DYNAMIC LABEL
// ------------------------------------------------------------------------------
// The label is updated only on the last bar to avoid unnecessary clutter.
// It displays the latest regime and real-rate value.
// ==============================================================================
var label lbl = na

if showLabelInput and validData and barstate.islast
    label.delete(lbl)
    lbl := label.new(
         x=bar_index,
         y=realRate,
         text=str.format("{0}\n{1} Real Rate: {2}%", assessmentText, countryLabel, str.tostring(realRate, "#.##")),
         color=lineColor,
         textcolor=color.black,
         size=size.normal,
         style=label.style_label_left)


// ==============================================================================
// DASHBOARD CONFIGURATION
// ------------------------------------------------------------------------------
// This block translates the dashboard inputs into Pine enum values.
// ==============================================================================
dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left


// ==============================================================================
// DASHBOARD
// ------------------------------------------------------------------------------
// The dashboard summarizes the active configuration and current macro state.
// ==============================================================================
var table dash = table.new(dashPos, 2, 7, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 7, border_width=1)

if barstate.islast and showDashboardInput and validData
    table.cell(dash, 0, 0, "Country", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, countryLabel, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Nominal", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, str.tostring(nominalRate, "#.##") + "%", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Inflation", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, str.tostring(inflationSmooth, "#.##") + "%", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Real Rate", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, str.tostring(realRate, "#.##") + "%", text_color=lineColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, assessment, text_color=lineColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Nominal Tk", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, nominalTicker, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Infl. Tk", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, inflationTicker, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboardInput
    table.clear(dash, 0, 0, 1, 6)


// ==============================================================================
// DISCLAIMER
// ------------------------------------------------------------------------------
// This disclaimer clarifies the intended use of the script.
// ==============================================================================
var table disc = table.new(position.bottom_left, 1, 1, border_width=1)

if barstate.islast and showDisclaimerInput
    table.cell(
         disc,
         0,
         0,
         "Disclaimer: This indicator is for educational and informational purposes only. It does not constitute financial, investment, mortgage, or legal advice.",
         text_color=chart.fg_color,
         text_size=size.small,
         bgcolor=color.new(color.gray, 85),
         text_halign=text.align_left)


// ==============================================================================
// ALERTS
// ------------------------------------------------------------------------------
// Alerts notify the user when the real-rate proxy enters or leaves the main
// threshold zones.
// ==============================================================================
alertcondition(validData and realRate <= optimalThreshold,
     title="Real Rate - Favorable Moment",
     message="The real rate has moved below the optimal threshold. Borrowing conditions are favorable.")

alertcondition(validData and realRate[1] > acceptableThreshold and realRate <= acceptableThreshold,
     title="Real Rate - Acceptable Zone",
     message="The real rate has entered the acceptable zone.")

alertcondition(validData and realRate[1] <= acceptableThreshold and realRate > acceptableThreshold,
     title="Real Rate - Deterioration",
     message="The real rate has moved above the acceptable threshold. Borrowing conditions are less favorable.")
````
