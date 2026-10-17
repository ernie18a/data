# Earnings & Sales Growth Table - PepeTheKing

- url: https://www.tradingview.com/script/lhRv0IGR-Earnings-Sales-Growth-Table-PepeTheKing/
- type: indicator
- pine_id: PUB;70747b52ed0842c29cc1283b4b8b8a52
- version: 1.0

## Description

Earnings & Sales Growth Table

Earnings & Sales Growth Table automatically displays historical EPS (Diluted) and Total Revenue growth directly on your chart, making it easy to evaluate a company's fundamental performance without leaving TradingView.

The indicator retrieves financial data for the stock currently on your chart and presents it in a clean, easy-to-read table showing both the reported values and their year-over-year growth rates.

Features
Automatically detects the chart's ticker and pulls its financial data.
Supports both:
Quarterly reporting
Annual reporting
Displays:
Diluted EPS
Total Revenue
Year-over-year growth percentages
Positive and negative growth are color-coded for quick analysis.
Adjustable table position.
Configurable number of historical periods displayed (up to 30).
Revenue is automatically formatted into K, M, or B values for improved readability.
How Growth is Calculated

Growth is calculated using the standard year-over-year formula:

Growth % = (Current Period − Same Period Last Year) ÷ |Same Period Last Year| × 100

Quarterly reports are compared against the same quarter from the previous year, while annual reports are compared against the previous fiscal year.

Built for Accuracy

Unlike many fundamental indicators that can accidentally duplicate financial reports as new bars load, this indicator stores each reporting period only once using a unique period key. If a company restates its financials, the existing value is updated instead of creating duplicate entries, resulting in a clean and reliable historical table.

Best Results

For the most complete history:

Use on Daily or Weekly charts.
Load several years of historical data.
Works with stocks that have TradingView fundamental financial data available.

This indicator is designed for investors and swing traders who want to quickly evaluate whether a company's earnings and revenue are accelerating or decelerating directly from the chart.

## Source Code

````pine
//@version=6
indicator("Earnings & Sales Growth Table - PepeTheKing", overlay=true, max_bars_back=5000)

// =========================================================
// EARNINGS & SALES GROWTH TABLE
// Automatically pulls quarterly/annual EPS (diluted) and Total
// Revenue for whatever ticker is on your active chart and
// displays YoY growth, similar to a "Stats Table" style card.
//
// Each period is stored in a keyed slot (year, or year*10+quarter)
// so a value can only ever occupy its own period's slot -- it can
// update in place but never get double-counted or duplicated.
//
// NOTES:
// - Use on a Daily or Weekly chart with several years of history
//   loaded so enough reports have been captured.
// - Works on stocks with fundamental data available on TradingView.
// - Growth % = (this period - same period last year) / |same
//   period last year| * 100
// =========================================================

// ---------------- Inputs ----------------
periodMode     = input.string("Quarterly", "Period", options=["Quarterly", "Yearly"])
quartersToShow = input.int(29, "Number of Periods to Display", minval=4, maxval=30)
tablePosStr    = input.string("top_left", "Table Position",
     options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"])
posGreen = input.color(color.new(color.green, 0), "Positive Growth Color")
posRed   = input.color(color.new(color.red, 0), "Negative Growth Color")

f_tablePos(s) =>
    switch s
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.top_left

// ---------------- Pull fundamental data ----------------
periodCode = periodMode == "Quarterly" ? "FQ" : "FY"
keyDelta   = periodMode == "Quarterly" ? 10 : 1   // key difference that means "1 year ago"

epsRaw = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", periodCode)
revRaw = request.financial(syminfo.tickerid, "TOTAL_REVENUE", periodCode)

// Period key: Yearly -> just the year (e.g. 2024). Quarterly -> year*10+quarter (e.g. 20241)
y = year(time)
m = month(time)
q = int(math.ceil(m / 3.0))
periodKey = periodMode == "Quarterly" ? y * 10 + q : y

// ---------------- Keyed storage (each key can only ever hold ONE slot) ----------------
var int[]    epsKeys = array.new_int(0)
var float[]  epsVals = array.new_float(0)
var int[]    revKeys = array.new_int(0)
var float[]  revVals = array.new_float(0)

f_upsert(keysArr, valsArr, k, v, maxSize) =>
    idx = array.indexof(keysArr, k)
    if idx >= 0
        // Same period seen again (e.g. restated) -- update in place, never duplicate
        array.set(valsArr, idx, v)
    else
        array.unshift(keysArr, k)
        array.unshift(valsArr, v)
        if array.size(keysArr) > maxSize
            array.pop(keysArr)
            array.pop(valsArr)
    true  // explicit trailing statement so the if/else above doesn't determine the function's return type

maxSize = quartersToShow + 3  // small buffer for YoY lookups near the edge

var float lastEps = na
var float lastRev = na

if not na(epsRaw) and (na(lastEps) or epsRaw != lastEps)
    f_upsert(epsKeys, epsVals, periodKey, epsRaw, maxSize)
    lastEps := epsRaw

if not na(revRaw) and (na(lastRev) or revRaw != lastRev)
    f_upsert(revKeys, revVals, periodKey, revRaw, maxSize)
    lastRev := revRaw

// ---------------- Formatting helpers ----------------
f_formatMoneyLarge(x) =>
    ax = math.abs(x)
    string txt = na
    if ax >= 1000000000
        txt := "$" + str.tostring(x / 1000000000, "#.##") + "B"
    else if ax >= 1000000
        txt := "$" + str.tostring(x / 1000000, "#.##") + "M"
    else if ax >= 1000
        txt := "$" + str.tostring(x / 1000, "#.##") + "K"
    else
        txt := "$" + str.tostring(x, "#.##")
    txt

f_formatEps(x) =>
    "$" + str.tostring(x, "#.##")

f_growthText(cur, prior) =>
    string txt = "n/a"
    if not na(cur) and not na(prior) and prior != 0
        g = (cur - prior) / math.abs(prior) * 100
        txt := (g >= 0 ? "+" : "") + str.tostring(g, "#.##") + "%"
    txt

f_growthColor(cur, prior) =>
    color c = color.gray
    if not na(cur) and not na(prior) and prior != 0
        g = (cur - prior) / math.abs(prior) * 100
        c := g >= 0 ? posGreen : posRed
    c

f_labelFromKey(k) =>
    string lbl = na
    if periodMode == "Quarterly"
        yy = int(math.floor(k / 10))
        qq = k - yy * 10
        lbl := str.tostring(yy) + ":Q" + str.tostring(qq)
    else
        lbl := str.tostring(k)
    lbl

// ---------------- Draw table on last bar ----------------
if barstate.islast
    // Build the union of period keys present in either series, sorted most-recent-first
    var int[] allKeys = array.new_int(0)
    array.clear(allKeys)
    for i = 0 to array.size(epsKeys) - 1
        array.push(allKeys, array.get(epsKeys, i))
    for i = 0 to array.size(revKeys) - 1
        k = array.get(revKeys, i)
        if array.indexof(allKeys, k) < 0
            array.push(allKeys, k)
    array.sort(allKeys, order.descending)

    n = math.min(quartersToShow, array.size(allKeys))
    var table tbl = table.new(f_tablePos(tablePosStr), n + 1, 3,
         bgcolor = color.new(color.black, 0), border_width = 1, border_color = color.new(color.gray, 50))

    table.cell(tbl, 0, 0, "Stats Table",
         bgcolor = color.new(color.gray, 70), text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 1, "Earnings",
         bgcolor = color.new(color.gray, 85), text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 2, "Sales",
         bgcolor = color.new(color.gray, 85), text_color = color.white, text_size = size.small)

    for i = 0 to n - 1
        colPos = i + 1
        idx = n - 1 - i  // oldest period on the left, most recent on the right
        k = array.get(allKeys, idx)
        priorK = k - keyDelta

        epsIdx = array.indexof(epsKeys, k)
        revIdx = array.indexof(revKeys, k)
        epsPriorIdx = array.indexof(epsKeys, priorK)
        revPriorIdx = array.indexof(revKeys, priorK)

        float epsVal   = epsIdx >= 0 ? array.get(epsVals, epsIdx) : na
        float revVal   = revIdx >= 0 ? array.get(revVals, revIdx) : na
        float epsPrior = epsPriorIdx >= 0 ? array.get(epsVals, epsPriorIdx) : na
        float revPrior = revPriorIdx >= 0 ? array.get(revVals, revPriorIdx) : na

        lbl = f_labelFromKey(k)
        epsGrowthTxt = f_growthText(epsVal, epsPrior)
        revGrowthTxt = f_growthText(revVal, revPrior)
        epsColor = f_growthColor(epsVal, epsPrior)
        revColor = f_growthColor(revVal, revPrior)

        epsText = na(epsVal) ? "n/a" : f_formatEps(epsVal) + "\n" + epsGrowthTxt
        revText = na(revVal) ? "n/a" : f_formatMoneyLarge(revVal) + "\n" + revGrowthTxt

        table.cell(tbl, colPos, 0, lbl,
             bgcolor = color.new(color.gray, 80), text_color = color.white, text_size = size.small)
        table.cell(tbl, colPos, 1, epsText,
             text_color = epsColor, text_size = size.small)
        table.cell(tbl, colPos, 2, revText,
             text_color = revColor, text_size = size.small)
````
