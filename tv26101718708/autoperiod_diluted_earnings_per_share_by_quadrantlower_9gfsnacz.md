# Auto-Period Diluted Earnings Per Share by QuadrantLower

- url: https://www.tradingview.com/script/9GfsnacZ-Auto-Period-Diluted-Earnings-Per-Share-by-QuadrantLower/
- type: indicator
- pine_id: PUB;b4f948098d034fb4917345c402905c7e
- version: 4.0

## Description

This script is for folks who like having Diluted Earnings Per Share appear on a separate pane underneath their chart but resent the screen real-estate taken up by needing to display both Diluted EPS(FQ) and Diluted EPS(FH) to cater for markets with different reporting periods.

In addition to auto-detecting the reporting period, this script has a bunch of useful visual customisation options including the ability to highlight significant percentage changes and differentiate between positive and negative earnings.

[b]RISK DISCLAIMER[/b]

All content, including tools, scripts and comments, by QuadrantLower are purely for informational and educational purposes only. Nothing herein should be construed as financial advice or a recommendation to buy, sell or hold any security or financial instrument. All trading involves risk and may not be suitable for all investors. You are solely responsible for your own trading decisions. Past performance is not indicative of future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © 2026 QuadrantLower

//@version=6
indicator("Auto-Period Diluted Earnings Per Share by QuadrantLower", shorttitle="▚ Diluted EPS", overlay=false, max_labels_count = 500)

//──────────────────────────────────────────────────────────────────────────
// User Inputs
//──────────────────────────────────────────────────────────────────────────

posColor          = input.color(color.new(color.green, 0), "Positive Earnings Color")
negColor          = input.color(color.new(color.red, 0), "Negative Earnings Color")
textColor         = input.color(color.white, "Default Text Color")
textHighlightColor = input.color(color.rgb(0, 0, 0), "Default Text BG Color")
highlightPctColor   = input.color(color.yellow, "Highlight Color")

textSize = input.string("Normal", "Text  ", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "textSize")
textBold = input.string("Bold", "", options = ["Bold", "Normal"], inline = "textSize")
textPosition = input.string("Centered", "", options = ["Period Start", "Centered"], inline = "textSize")

highlightATHL = input.bool(true, "Highlight ATH/ATL    ", inline = "highlightATHL")
highlightATHLApplyTo = input.string("Text", "", options = ["Text", "Background"], inline = "highlightATHL", active = highlightATHL ? true : false)
highlightATHLHistoric = input.bool(false, "Historic    ", inline = "highlightATHL", active = highlightATHL ? true : false, tooltip = "Please note: ATH/ATL highlighting is disabled on chart timeframes <1H due to a likely lack of historic EPS data.")

highlightPctChange  = input.bool(true, "Highlight % ≥ ±              ", inline = "highlightPct")
highlightPctThresh  = input.float(50.0, "", minval = 1.0, maxval = 1000.0, inline = "highlightPct", active = highlightPctChange ? true : false)
highlightPctApplyTo = input.string("Text", "", options = ["Text", "Background"], inline = "highlightPct", active = highlightPctChange ? true : false)

colorEarnings      = input.bool(false, "Color EPS                ", inline = "colorEarnings")
colorEarningsApplyTo = input.string("Background", "", options = ["Text", "Background"], inline = "colorEarnings", active = colorEarnings ? true : false)
colorEarningsColorBool = input.bool(false, "", inline = "colorEarnings", active = colorEarnings ? true : false)
colorEarningsPosColor = input.color(color.new(color.green, 0), "", inline = "colorEarnings", active = colorEarningsColorBool and colorEarnings ? true : false)
colorEarningsNegColor = input.color(color.new(color.red, 0), "", inline = "colorEarnings", active = colorEarningsColorBool and colorEarnings ? true : false)

colorPctChange     = input.bool(false, "Color %                  ", inline = "colorPct")
colorPctApplyTo    = input.string("Background", "", options = ["Text", "Background"], inline = "colorPct", active = colorPctChange ? true : false)
colorPctChangeColorBool = input.bool(false, "", inline = "colorPct", active = colorPctChange ? true : false)
colorPctChangePosColor = input.color(color.new(color.green, 0), "", inline = "colorPct", active = colorPctChangeColorBool and colorPctChange ? true : false)
colorPctChangeNegColor = input.color(color.new(color.red, 0), "", inline = "colorPct", active = colorPctChangeColorBool and colorPctChange ? true : false)

resolvedTextSize = textSize == "Tiny" ? size.tiny :
  textSize == "Small" ? size.small :
  textSize == "Large" ? size.large :
  textSize == "Huge" ? size.huge :
  size.normal

resolvedTextFormat = textBold == "Bold" ? text.format_bold : text.format_none

// if chart timeframe is <1H we don't want to highlight ATH/ATLs due to the lack of historic EPS data
bool athEnabled = highlightATHL and timeframe.in_seconds() >= 3600

// Precomputed constants
const int DEADZONE_MS = 10 * 24 * 60 * 60 * 1000  // 10 days in ms — label deadzone in Centered mode
const float INF_SENTINEL = 1.0e10                  // sentinel for ±∞% change (when previous EPS was 0)

//──────────────────────────────────────────────────────────────────────────
// Reporting frequency detection
//──────────────────────────────────────────────────────────────────────────

// Count FQ vs FH reports to determine the company's reporting cadence.
float eps_Q = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FQ", barmerge.gaps_on, ignore_invalid_symbol = true)
float eps_H = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FH", barmerge.gaps_on, ignore_invalid_symbol = true)
float eps_Y = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FY", barmerge.gaps_on, ignore_invalid_symbol = true)

var int count_Q = 0
var int count_H = 0

if not na(eps_Q) and na(eps_Q[1])
    count_Q += 1

if not na(eps_H) and na(eps_H[1])
    count_H += 1

// Valid if any cadence has returned data.
bool symbol_valid = count_Q > 0 or count_H > 0 or not na(eps_Y)

//──────────────────────────────────────────────────────────────────────────
// Financial data retrieval
//──────────────────────────────────────────────────────────────────────────

// Selects the correct reporting period based on frequency detection
float dilutedEPS = na

if symbol_valid
    dilutedEPS := count_Q > count_H ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FQ", barmerge.gaps_off) :
      count_H > count_Q ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FH", barmerge.gaps_off) :
      request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FY", barmerge.gaps_off)

// Report change detection
bool newReport = symbol_valid and not na(dilutedEPS) and (na(dilutedEPS[1]) or dilutedEPS != dilutedEPS[1])

//──────────────────────────────────────────────────────────────────────────
// Helper Functions
//──────────────────────────────────────────────────────────────────────────

// Currency ISO → display symbol
f_currencySymbol(code) =>
    switch code
        "USD" => "$"
        "GBP" => "£"
        "GBX" => "£"
        "EUR" => "€"
        "JPY" => "JP¥"
        "CNY" => "CN¥"
        "CHF" => "CHF "
        "CAD" => "C$"
        "AUD" => "A$"
        "NZD" => "NZ$"
        "HKD" => "HK$"
        "SGD" => "S$"
        "INR" => "₹"
        "KRW" => "₩"
        "SEK" => "kr"
        "NOK" => "kr"
        "DKK" => "kr"
        "ZAR" => "R"
        "BRL" => "R$"
        "MXN" => "MX$"
        => code + " "

// Resolves whether an emphasis color applies to text or background
f_resolveColors(useEmphasis, useBg, emphasisColor, baseTextColor, baseBgColor) =>
    textC = useEmphasis and not useBg ? emphasisColor : baseTextColor
    bgC = useEmphasis and useBg ? emphasisColor : baseBgColor
    [textC, bgC]

// Binary search for the first report at or just before the visible window's left edge
f_findStartIndex(timesArray, targetTime) =>
    idx = array.binary_search_leftmost(timesArray, targetTime)
    math.max(idx - 1, 0)

// Strips trailing zeros from a fixed-decimal string (e.g. "1.20" → "1.2", "3.00" → "3")
f_stripTrailingZeros(s) =>
    result = s
    if str.contains(result, ".")
        while str.length(result) > 0 and str.substring(result, str.length(result) - 1, str.length(result)) == "0"
            result := str.substring(result, 0, str.length(result) - 1)
        if str.length(result) > 0 and str.substring(result, str.length(result) - 1, str.length(result)) == "."
            result := str.substring(result, 0, str.length(result) - 1)
    result

//──────────────────────────────────────────────────────────────────────────
// EPS report history
//──────────────────────────────────────────────────────────────────────────

var array<float>  epsHistory           = array.new<float>()
var array<int>    epsHistoryTime       = array.new<int>()       // Period Start label placement
var array<int>    epsHistoryActualTime = array.new<int>()       // Centered mode and Range/overlap
var array<string> epsHistoryValueText  = array.new<string>()    // formatted EPS value string
var array<string> epsHistoryPctText    = array.new<string>()    // formatted % change string ("" if none)
var array<float>  epsHistoryPctChange  = array.new<float>()     // raw % change value (na if none)

// Label arrays — parallel pair for independent text/% colouring
var array<label> epsValueLabels = array.new<label>()
var array<label> epsPctLabels   = array.new<label>()

// Viewport tracking — labels only redraw when the visible window actually changes
var int prevLeftVisible  = na
var int prevRightVisible = na

// Prior report value for % change calculation
var float prevReportedEPS = na

//──────────────────────────────────────────────────────────────────────────
// Build history on each new report
//──────────────────────────────────────────────────────────────────────────

if newReport
    pctChange = na(prevReportedEPS) ? na :
      prevReportedEPS == 0 ? (dilutedEPS > 0 ? INF_SENTINEL : dilutedEPS < 0 ? -INF_SENTINEL : na) :
      (dilutedEPS - prevReportedEPS) / math.abs(prevReportedEPS) * 100

    pctTextRaw = na(pctChange) ? "" :
      math.abs(pctChange) >= INF_SENTINEL ? (pctChange > 0 ? "+∞" : "-∞") + "%" :
      (pctChange >= 0 ? "+" : "") + str.tostring(pctChange, "#.##") + "%"

    currSym = syminfo.currency == "" ? "" : f_currencySymbol(syminfo.currency)
    valueStr = currSym + f_stripTrailingZeros(str.tostring(dilutedEPS, "#.####"))

    array.push(epsHistory, dilutedEPS)
    array.push(epsHistoryTime, bar_index > 0 ? time[1] : time) // pre-shifted (1 bar earlier)
    array.push(epsHistoryActualTime, bar_index > 0 ? time[1] : time) // pre-shifted (1 bar earlier)
    array.push(epsHistoryValueText, valueStr)
    array.push(epsHistoryPctText, pctTextRaw)
    array.push(epsHistoryPctChange, pctChange)

    prevReportedEPS := dilutedEPS

//──────────────────────────────────────────────────────────────────────────
// Label redraw (viewport-reactive)
//──────────────────────────────────────────────────────────────────────────

if barstate.islast
    bool windowChanged = na(prevLeftVisible) or chart.left_visible_bar_time != prevLeftVisible or chart.right_visible_bar_time != prevRightVisible

    if windowChanged
        // Delete existing labels
        int nValueLabels = array.size(epsValueLabels)
        if nValueLabels > 0
            for i = 0 to nValueLabels - 1
                label.delete(array.get(epsValueLabels, i))

        int nPctLabels = array.size(epsPctLabels)
        if nPctLabels > 0
            for i = 0 to nPctLabels - 1
                label.delete(array.get(epsPctLabels, i))

        array.clear(epsValueLabels)
        array.clear(epsPctLabels)

        int histSize = array.size(epsHistory)
        int startIdx = histSize > 0 ? f_findStartIndex(epsHistoryActualTime, chart.left_visible_bar_time) : 0

        // Hoist input-driven comparisons out of the per-label loop
        bool earningsUseBg  = colorEarningsApplyTo == "Background"
        bool pctUseBg       = colorPctApplyTo == "Background"
        bool highlightUseBg = highlightPctApplyTo == "Background"
        bool athUseBg       = highlightATHLApplyTo == "Background"

        // Compute ATH/ATL flags and global extremes in a single pass
        float epsATH = na
        float epsATL = na
        array<bool> isATHArr = array.new<bool>(histSize, false)
        array<bool> isATLArr = array.new<bool>(histSize, false)

        if histSize > 0
            float runHigh = na
            float runLow = na
            for j = 0 to histSize - 1
                val = array.get(epsHistory, j)
                runHigh := na(runHigh) ? val : math.max(runHigh, val)
                runLow := na(runLow) ? val : math.min(runLow, val)
                if athEnabled and histSize > 1 and highlightATHLHistoric and runHigh != runLow
                    array.set(isATHArr, j, val == runHigh)
                    array.set(isATLArr, j, val == runLow)
            epsATH := runHigh
            epsATL := runLow

            if athEnabled and histSize > 1
                if highlightATHLHistoric
                    // First report gets runHigh == runLow so no tag fires above.
                    // Retroactively tag it using the global extremes if it qualifies.
                    if epsATH != epsATL
                        firstVal = array.get(epsHistory, 0)
                        if firstVal == epsATH
                            array.set(isATHArr, 0, true)
                        if firstVal == epsATL
                            array.set(isATLArr, 0, true)
                else
                    for j = 0 to histSize - 1
                        val = array.get(epsHistory, j)
                        array.set(isATHArr, j, epsATH != epsATL and val == epsATH)
                        array.set(isATLArr, j, epsATH != epsATL and val == epsATL)

        // Local visible-report cache — populated in Pass 1, consumed in Pass 2
        array<int> visibleIdx      = array.new<int>()
        array<int> visibleSegStart = array.new<int>()
        array<int> visibleSegEnd   = array.new<int>()

        // ── Pass 1: range/quartile calc + cache visible set ────────────────
        float epsHighest = na
        float epsLowest  = na
        int visibleReportCount = 0

        if histSize > 0
            for i = startIdx to histSize - 1
                spanStart = array.get(epsHistoryActualTime, i)
                if spanStart > chart.right_visible_bar_time
                    break
                spanEnd = i < histSize - 1 ? array.get(epsHistoryActualTime, i + 1) : time
                if spanEnd >= chart.left_visible_bar_time
                    v = array.get(epsHistory, i)
                    epsHighest := na(epsHighest) ? v : math.max(epsHighest, v)
                    epsLowest  := na(epsLowest) ? v : math.min(epsLowest, v)
                    visibleReportCount += 1
                    array.push(visibleIdx, i)
                    array.push(visibleSegStart, spanStart)
                    array.push(visibleSegEnd, spanEnd)

        float epsRange = na(epsHighest) or na(epsLowest) ? na : epsHighest - epsLowest
        float epsQ1 = na(epsRange) ? na : epsLowest + epsRange * 0.25
        float epsQ3 = na(epsRange) ? na : epsLowest + epsRange * 0.75

        // ── Pass 2: label redraw ───────────────────────────────────────────
        if histSize > 0
            for k = 0 to histSize - 1
                v    = array.get(epsHistory, k)
                barT = array.get(epsHistoryTime, k)

                if textPosition == "Centered"
                    segStart = array.get(epsHistoryActualTime, k)
                    segEnd   = k < histSize - 1 ? array.get(epsHistoryActualTime, k + 1) : time

                    // Only clamp to visible window if this segment overlaps the screen edge
                    bool segVisible = segStart <= chart.right_visible_bar_time and segEnd >= chart.left_visible_bar_time

                    centerT = segVisible ?
                      math.max(segStart, chart.left_visible_bar_time) + (math.min(segEnd, chart.right_visible_bar_time) - math.max(segStart, chart.left_visible_bar_time)) / 2 :
                      segStart + (segEnd - segStart) / 2

                    if visibleReportCount > 1 and segVisible
                        minAllowed = segStart + DEADZONE_MS
                        maxAllowed = segEnd - DEADZONE_MS
                        barT := minAllowed <= maxAllowed ? math.max(minAllowed, math.min(maxAllowed, centerT)) : centerT
                    else
                        barT := centerT

                valueText    = array.get(epsHistoryValueText, k)
                pctText      = array.get(epsHistoryPctText, k)
                pctChangeVal = array.get(epsHistoryPctChange, k)
                hasPct       = pctText != ""

                bool inBottomQuartile = na(epsQ1) ? true : v <= epsQ1
                bool inTopQuartile    = na(epsQ3) ? false : v >= epsQ3
                prefix = inTopQuartile ? "\n" : ""
                suffix = inBottomQuartile ? "\n" : ""

                // Build EPS value text
                bool isATH = array.get(isATHArr, k)
                bool isATL = array.get(isATLArr, k)

                athSuffix = isATH and isATL ? " ATH/ATL" : isATH ? " ATH" : isATL ? " ATL" : ""
                contentA  = hasPct ? valueText + athSuffix + "\n" : valueText + athSuffix
                fullTextA = prefix + contentA + suffix

                // Resolve base earnings colour, then layer ATH/ATL highlight on top
                earningsEmphasisColor = colorEarningsColorBool ?
                  (v > 0 ? colorEarningsPosColor : colorEarningsNegColor) :
                  (v > 0 ? posColor : negColor)
                [colorA, bgColorA] = f_resolveColors(colorEarnings, earningsUseBg, earningsEmphasisColor, textColor, textHighlightColor)

                if isATH or isATL
                    if athUseBg
                        bgColorA := highlightPctColor
                    else
                        colorA := highlightPctColor

                labelA = label.new(barT, v, text = fullTextA, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_text_outline, color = bgColorA, textcolor = colorA, size = resolvedTextSize, text_formatting = resolvedTextFormat)
                array.push(epsValueLabels, labelA)

                // % change label (only when there's a value to show)
                if hasPct
                    fullTextB = prefix + "\n" + pctText + suffix

                    exceedsThreshold = highlightPctChange and not na(pctChangeVal) and math.abs(pctChangeVal) >= highlightPctThresh
                    pctEmphasisColor = colorPctChangeColorBool ?
                      (pctChangeVal >= 0 ? colorPctChangePosColor : colorPctChangeNegColor) :
                      (pctChangeVal >= 0 ? posColor : negColor)
                    
                    // Layer Color % then Highlight % — each targets its own slot (text/bg).
                    // If both target the same slot, Highlight % wins (applied last).
                    color colorB   = textColor
                    color bgColorB = textHighlightColor

                    if colorPctChange
                        if pctUseBg
                            bgColorB := pctEmphasisColor
                        else
                            colorB := pctEmphasisColor

                    if exceedsThreshold
                        if highlightUseBg
                            bgColorB := highlightPctColor
                        else
                            colorB := highlightPctColor

                    labelB = label.new(barT, v, text = fullTextB, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_text_outline, color = bgColorB, textcolor = colorB, size = resolvedTextSize, text_formatting = resolvedTextFormat)
                    array.push(epsPctLabels, labelB)

        prevLeftVisible  := chart.left_visible_bar_time
        prevRightVisible := chart.right_visible_bar_time

//──────────────────────────────────────────────────────────────────────────
// Plot
//──────────────────────────────────────────────────────────────────────────

epsColor = dilutedEPS > 0 ? posColor : negColor

plot(symbol_valid ? dilutedEPS : na, title = "Diluted EPS", color = epsColor, linewidth = 2, style = plot.style_stepline_diamond, editable = false)
````
