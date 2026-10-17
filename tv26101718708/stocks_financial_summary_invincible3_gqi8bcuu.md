# Stocks: Financial Summary [invincible3]

- url: https://www.tradingview.com/script/gqI8bCUu-Stocks-Financial-Summary-invincible3/
- type: indicator
- pine_id: PUB;c79a1d248b82457ba25023707c738695
- version: 2.0

## Description

[b]Stocks: Financial Summary [invincible3][/b]

Stocks: Financial Summary is a compact fundamental dashboard designed to visualize a company’s key financial statements directly on the TradingView chart.

The indicator displays three major financial sections:

[b]Income Statement[/b]
Revenue, Gross Profit, EBIT or Operating Income, Pretax Income, and Net Income.

[b]Balance Sheet[/b]
Total Assets, Total Liabilities, and Shareholders’ Equity.

[b]Cash Flow[/b]
Cash Flow from Operations, Cash Flow from Investing, Cash Flow from Financing, and Free Cash Flow.

The dashboard is drawn on the right side of the chart using a clean multi-panel bar-chart layout. It allows traders and investors to quickly compare historical yearly or quarterly financial data without leaving the price chart.

[b]Key Features[/b]

* Supports Yearly and Quarterly financial views.
* Optional TTM display for Income Statement and Cash Flow.
* Visual comparison of historical financial periods.
* Auto unit formatting: Raw, K, M, B, and T.
* Customizable dashboard position, spacing, bar width, colors, and transparency.
* Right-side layout designed to keep the price chart readable.
* Uses actual TradingView financial data through `request.financial()`.
* Includes manual fiscal year and quarter override options when exchange reporting labels need adjustment.

This tool is designed for fundamental analysis, long-term stock screening, and quick financial statement comparison. It can help users visually inspect whether a company’s revenue, profitability, assets, liabilities, cash flow, and free cash flow are improving or weakening over time.

This indicator is for educational and informational purposes only. It is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator(
     "Stocks: Financial Summary [invincible3]",
     shorttitle = "Fin",
     overlay = true,
     max_polylines_count = 100,
     max_lines_count = 500,
     max_labels_count = 500,
     dynamic_requests = true
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpMain = "Main Settings"

periodMode = input.string(
     "Yearly",
     "Report Period",
     options = ["Yearly", "Quarterly"],
     group = grpMain
     )

periodsToShow = input.int(
     4,
     "Historical Periods",
     minval = 1,
     maxval = 4,
     group = grpMain
     )

showTTM = input.bool(
     true,
     "Show TTM for Income Statement and Cash Flow",
     group = grpMain
     )

opSource = input.string(
     "EBIT",
     "Operating Profit Source",
     options = ["EBIT", "Operating Income"],
     group = grpMain
     )

unitMode = input.string(
     "Auto",
     "Statement Units",
     options = ["Auto", "Raw", "K", "M", "B", "T"],
     group = grpMain
     )

latestFYOverride = input.int(
     0,
     "Latest FY Year Override, 0 = Auto",
     minval = 0,
     maxval = 2100,
     group = grpMain
     )

latestFQYearOverride = input.int(
     0,
     "Latest FQ Year Override, 0 = Auto",
     minval = 0,
     maxval = 2100,
     group = grpMain
     )

latestFQQuarterOverride = input.int(
     0,
     "Latest FQ Quarter Override, 0 = Auto",
     minval = 0,
     maxval = 4,
     group = grpMain,
     tooltip = "Use 0 for auto. Use 1, 2, 3, or 4 if TradingView labels quarters incorrectly."
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RATIO INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpRatios = "Ratios Section"

showRatios = input.bool(
     true,
     "Show Ratio Mini Cards",
     group = grpRatios
     )

ratioPeriodsToShow = input.int(
     5,
     "Ratio Fiscal Years to Show",
     minval = 3,
     maxval = 8,
     group = grpRatios
     )

ratioValueLabels = input.string(
     "Latest Only",
     "Ratio Value Labels",
     options = ["Off", "Latest Only", "All"],
     group = grpRatios
     )

showRatioYears = input.bool(
     true,
     "Show Ratio Year Labels",
     group = grpRatios
     )

showRatioDots = input.bool(
     true,
     "Show Ratio Dots",
     group = grpRatios
     )

smoothRatioLines = input.bool(
     true,
     "Smooth Ratio Lines",
     group = grpRatios
     )

ratioCardGapBars = input.int(
     4,
     "Ratio Card Gap Bars",
     minval = 1,
     maxval = 12,
     group = grpRatios
     )

ratioHeightMult = input.float(
     1.45,
     "Ratio Section Height",
     minval = 1.00,
     maxval = 2.80,
     step = 0.10,
     group = grpRatios,
     tooltip = "Lower value gives more height to Income Statement, Balance Sheet, and Cash Flow."
     )

financialHeightBoost = input.float(
     1.15,
     "Financial Section Height Boost",
     minval = 1.00,
     maxval = 1.50,
     step = 0.05,
     group = grpRatios,
     tooltip = "Makes the three financial statement panels taller. Ratio section adjusts automatically."
     )

ratioLineWidth = input.int(
     2,
     "Ratio Curve Width",
     minval = 1,
     maxval = 5,
     group = grpRatios
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LAYOUT INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpLayout = "Right Side Layout"

rightOffsetBars = input.int(
     25,
     "Right Side Offset Bars",
     minval = 1,
     maxval = 200,
     group = grpLayout,
     tooltip = "Moves the dashboard to the right side of the latest candle. Increase chart right margin if needed."
      )

verticalLookback = input.int(
     150,
     "Vertical Range Lookback",
     minval = 20,
     maxval = 500,
     group = grpLayout,
     tooltip = "Recent price range used to vertically fit the dashboard."
     )

topPaddingPct = input.float(
     5.0,
     "Top Padding %",
     minval = 0.0,
     maxval = 25.0,
     step = 0.5,
     group = grpLayout
     )

bottomPaddingPct = input.float(
     5.0,
     "Bottom Padding %",
     minval = 0.0,
     maxval = 25.0,
     step = 0.5,
     group = grpLayout
     )

sectionGapPct = input.float(
     2.5,
     "Gap Between Sections %",
     minval = 0.5,
     maxval = 10.0,
     step = 0.5,
     group = grpLayout
     )

barWidthBars = input.int(
     2,
     "Bar Width Bars",
     minval = 1,
     maxval = 4,
     group = grpLayout
     )

barGapBars = input.int(
     1,
     "Bar Gap Bars",
     minval = 0,
     maxval = 3,
     group = grpLayout
     )

groupGapBars = input.int(
     5,
     "Year Group Gap Bars",
     minval = 1,
     maxval = 10,
     group = grpLayout
     )

showValueLabels = input.bool(
     false,
     "Show Statement Value Labels",
     group = grpLayout
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpStyle = "Colors"

cRevenue = input.color(#2962FF, "Revenue / Assets / CFO", group = grpStyle)
cGross   = input.color(#7E57C2, "Gross Profit / Liabilities / CFI", group = grpStyle)
cOp      = input.color(#FFCA28, "Operating Profit", group = grpStyle)
cPretax  = input.color(#26A69A, "Pretax Income", group = grpStyle)
cNet     = input.color(#FF9800, "Net Income", group = grpStyle)
cEquity  = input.color(#089981, "Shareholders' Equity", group = grpStyle)
cFin     = input.color(#AB47BC, "Cash Flow Financing", group = grpStyle)
cFcf     = input.color(#F23645, "Free Cash Flow", group = grpStyle)

// Lighter solid ratio curve defaults.
cRatioGood = input.color(#089981, "EPS / Op Margin / ROIC Ratio Line", group = grpStyle)
cRatioDebt = input.color(#F23645, "Debt-to-Equity Ratio Line", group = grpStyle)

panelTransp = input.int(
     5,
     "Panel Background Transparency",
     minval = 0,
     maxval = 100,
     group = grpStyle
     )

gridTransp = input.int(
     82,
     "Grid Transparency",
     minval = 0,
     maxval = 100,
     group = grpStyle
     )

ratioCardTransp = input.int(
     94,
     "Ratio Card Fill Transparency",
     minval = 85,
     maxval = 100,
     group = grpStyle
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_periodTag() => periodMode == "Quarterly" ? "FQ" : "FY"

f_supportsTTM(int st) => periodMode == "Yearly" and showTTM and (st == 0 or st == 2)

f_statementTitle(int st) =>
    switch st
        0 => "Income Statement"
        1 => "Balance Sheet"
        2 => "Cash Flow"
        => ""

f_metricCount(int st) => st == 0 ? 5 : st == 1 ? 3 : 4

f_metricName(int st, int m) =>
    if st == 0
        switch m
            0 => "Revenue"
            1 => "Gross Profit"
            2 => opSource == "EBIT" ? "Operating Profit(EBIT)" : "Operating Income"
            3 => "Profit before Taxation"
            4 => "Net Income"
            => ""
    else if st == 1
        switch m
            0 => "Total Assets"
            1 => "Total Liabilities"
            2 => "Shareholders' Equity"
            => ""
    else
        switch m
            0 => "Cashflow from Operations"
            1 => "Cashflow from Investing"
            2 => "Cashflow from Financing"
            3 => "Free Cash Flow"
            => ""

f_metricShort(int st, int m) =>
    if st == 0
        switch m
            0 => "Revenue"
            1 => "Gross"
            2 => "EBIT"
            3 => "Pretax"
            4 => "Net"
            => ""
    else if st == 1
        switch m
            0 => "Assets"
            1 => "Liab."
            2 => "Equity"
            => ""
    else
        switch m
            0 => "CFO"
            1 => "CFI"
            2 => "CFF"
            3 => "FCF"
            => ""

f_metricColor(int st, int m) =>
    if st == 0
        switch m
            0 => cRevenue
            1 => cGross
            2 => cOp
            3 => cPretax
            4 => cNet
            => chart.fg_color
    else if st == 1
        switch m
            0 => cRevenue
            1 => cGross
            2 => cEquity
            => chart.fg_color
    else
        switch m
            0 => cRevenue
            1 => cGross
            2 => cFin
            3 => cFcf
            => chart.fg_color

f_fmt(float x) =>
    string out = "n/a"
    if not na(x)
        float ax = math.abs(x)
        float div = 1.0
        string suf = ""
        if unitMode == "Raw"
            div := 1.0
        else if unitMode == "K"
            div := 1e3
            suf := "K"
        else if unitMode == "M"
            div := 1e6
            suf := "M"
        else if unitMode == "B"
            div := 1e9
            suf := "B"
        else if unitMode == "T"
            div := 1e12
            suf := "T"
        else
            if ax >= 1e12
                div := 1e12
                suf := "T"
            else if ax >= 1e9
                div := 1e9
                suf := "B"
            else if ax >= 1e6
                div := 1e6
                suf := "M"
            else if ax >= 1e3
                div := 1e3
                suf := "K"
        float y = x / div
        string fmt = math.abs(y) >= 100 ? "#.0" : math.abs(y) >= 10 ? "#.00" : "#.000"
        out := str.tostring(y, fmt) + suf
    out

f_fmtRatio(float x, string suffix) =>
    string out = "n/a"
    if not na(x)
        float ax = math.abs(x)
        string fmt = ax >= 100 ? "#.0" : ax >= 10 ? "#.00" : "#.##"
        out := str.tostring(x, fmt) + suffix
    out

f_periodLabel() =>
    if periodMode == "Yearly"
        str.tostring(year(time) - 1)
    else
        int qNow = int(math.ceil(month(time) / 3.0))
        int q = qNow - 1
        int y = year(time)
        if q == 0
            q := 4
            y -= 1
        "Q" + str.tostring(q) + " " + str.tostring(y)

f_valToY(float v, float lo, float hi, float yBot, float yTop) =>
    hi == lo ? (yTop + yBot) / 2.0 : yBot + ((v - lo) / (hi - lo)) * (yTop - yBot)

f_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))

f_catmull(float p0, float p1, float p2, float p3, float t) =>
    0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t * t * t)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING OBJECT STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var polyline[] gPolys = array.new<polyline>()
var line[]     gLines = array.new<line>()
var label[]    gLabs  = array.new<label>()

f_clearObjects() =>
    while array.size(gPolys) > 0
        polyline.delete(array.pop(gPolys))
    while array.size(gLines) > 0
        line.delete(array.pop(gLines))
    while array.size(gLabs) > 0
        label.delete(array.pop(gLabs))

f_polyRect(int x1, float y1, int x2, float y2, color fillCol, color lineCol) =>
    float yLo = math.min(y1, y2)
    float yHi = math.max(y1, y2)
    array<chart.point> pts = array.from(
         chart.point.from_index(x1, yLo),
         chart.point.from_index(x1, yHi),
         chart.point.from_index(x2, yHi),
         chart.point.from_index(x2, yLo)
     )
    pl = polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_index, line_color = lineCol, fill_color = fillCol, line_width = 1)
    array.push(gPolys, pl)

f_hLine(int x1, int x2, float y, color col, int w) =>
    ln = line.new(x1, y, x2, y, xloc.bar_index, extend.none, col, width = w)
    array.push(gLines, ln)

f_vLine(int x, float y1, float y2, color col, int w) =>
    ln = line.new(x, y1, x, y2, xloc.bar_index, extend.none, col, width = w)
    array.push(gLines, ln)

f_text(int x, float y, string txt, color txtCol, string sz) =>
    lb = label.new(x, y, txt, xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_none, txtCol, size = sz, textalign = text.align_center)
    array.push(gLabs, lb)

f_dot(int x, float y, color col) =>
    lb = label.new(x, y, "●", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_none, col, size = size.normal, textalign = text.align_center)
    array.push(gLabs, lb)

f_opaque(color c) => color.rgb(color.r(c), color.g(c), color.b(c), 0)
f_darker(color c) => color.rgb(int(color.r(c) * 0.55), int(color.g(c) * 0.55), int(color.b(c) * 0.55), 0)

f_polyCurve(array<chart.point> pts, color col, int w) =>
    pl = polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = col, fill_color = na, line_width = w)
    array.push(gPolys, pl)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA UDTs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type FinData
    string lbl
    float incRev
    float incGross
    float incOp
    float incPretax
    float incNet
    float bsAssets
    float bsLiab
    float bsEquity
    float cfOper
    float cfInvest
    float cfFin
    float cfFcf

var array<FinData> aData = array.new<FinData>()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST FUNDAMENTAL DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
periodTag = f_periodTag()

inc_rev     = request.financial(syminfo.tickerid, "TOTAL_REVENUE", periodTag, gaps = barmerge.gaps_on)
inc_gross   = request.financial(syminfo.tickerid, "GROSS_PROFIT", periodTag, gaps = barmerge.gaps_on)
inc_pretax  = request.financial(syminfo.tickerid, "PRETAX_INCOME", periodTag, gaps = barmerge.gaps_on)
inc_net     = request.financial(syminfo.tickerid, "NET_INCOME", periodTag, gaps = barmerge.gaps_on)
inc_op      = request.financial(syminfo.tickerid, opSource == "EBIT" ? "EBIT" : "OPER_INCOME", periodTag, gaps = barmerge.gaps_on)

var float inc_rev_ttm = na, var float inc_gross_ttm = na, var float inc_pretax_ttm = na, var float inc_net_ttm = na
var float inc_op_ttm = na, var float cf_oper_ttm = na, var float cf_invest_ttm = na, var float cf_fin_ttm = na, var float cf_fcf_ttm = na

if showTTM and periodMode == "Yearly" and barstate.islast
    inc_rev_ttm    := request.financial(syminfo.tickerid, "TOTAL_REVENUE", "TTM")
    inc_gross_ttm  := request.financial(syminfo.tickerid, "GROSS_PROFIT", "TTM")
    inc_pretax_ttm := request.financial(syminfo.tickerid, "PRETAX_INCOME", "TTM")
    inc_net_ttm    := request.financial(syminfo.tickerid, "NET_INCOME", "TTM")
    inc_op_ttm     := request.financial(syminfo.tickerid, opSource == "EBIT" ? "EBIT" : "OPER_INCOME", "TTM")
    cf_oper_ttm    := request.financial(syminfo.tickerid, "CASH_F_OPERATING_ACTIVITIES", "TTM")
    cf_invest_ttm  := request.financial(syminfo.tickerid, "CASH_F_INVESTING_ACTIVITIES", "TTM")
    cf_fin_ttm     := request.financial(syminfo.tickerid, "CASH_F_FINANCING_ACTIVITIES", "TTM")
    cf_fcf_ttm     := request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "TTM")

bs_assets = request.financial(syminfo.tickerid, "TOTAL_ASSETS", periodTag, gaps = barmerge.gaps_on)
bs_liab   = request.financial(syminfo.tickerid, "TOTAL_LIABILITIES", periodTag, gaps = barmerge.gaps_on)
bs_equity = not na(bs_assets) and not na(bs_liab) ? bs_assets - bs_liab : na

cf_oper   = request.financial(syminfo.tickerid, "CASH_F_OPERATING_ACTIVITIES", periodTag, gaps = barmerge.gaps_on)
cf_invest = request.financial(syminfo.tickerid, "CASH_F_INVESTING_ACTIVITIES", periodTag, gaps = barmerge.gaps_on)
cf_fin    = request.financial(syminfo.tickerid, "CASH_F_FINANCING_ACTIVITIES", periodTag, gaps = barmerge.gaps_on)
cf_fcf    = request.financial(syminfo.tickerid, "FREE_CASH_FLOW", periodTag, gaps = barmerge.gaps_on)

ratio_eps_basic = showRatios ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC", "FY", gaps = barmerge.gaps_on) : na
ratio_op_margin = showRatios ? request.financial(syminfo.tickerid, "OPERATING_MARGIN", "FY", gaps = barmerge.gaps_on) : na
ratio_de        = showRatios ? request.financial(syminfo.tickerid, "DEBT_TO_EQUITY", "FY", gaps = barmerge.gaps_on) : na
ratio_roic      = showRatios ? request.financial(syminfo.tickerid, "RETURN_ON_INVESTED_CAPITAL", "FY", gaps = barmerge.gaps_on) : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORICAL STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(inc_rev) or not na(bs_assets) or not na(cf_oper)
    aData.push(FinData.new(f_periodLabel(), inc_rev, inc_gross, inc_op, inc_pretax, inc_net, bs_assets, bs_liab, bs_equity, cf_oper, cf_invest, cf_fin, cf_fcf))
    if aData.size() > 30
        aData.shift()

var float[] aRatioEPS = array.new_float(), var int[] aRatioEPSY = array.new_int()
var float[] aRatioOPM = array.new_float(), var int[] aRatioOPMY = array.new_int()
var float[] aRatioDE  = array.new_float(), var int[] aRatioDEY  = array.new_int()
var float[] aRatioROIC= array.new_float(), var int[] aRatioROICY= array.new_int()

f_captureRatio(float v, float[] vals, int[] yrs, int keep) =>
    if not na(v)
        int yr = year(time)
        int sz = array.size(vals)
        if sz == 0 or array.get(yrs, sz - 1) != yr
            array.push(vals, v)
            array.push(yrs, yr)
        else
            array.set(vals, sz - 1, v)
        while array.size(vals) > keep
            array.shift(vals)
            array.shift(yrs)

if showRatios
    f_captureRatio(ratio_eps_basic, aRatioEPS, aRatioEPSY, ratioPeriodsToShow)
    f_captureRatio(ratio_op_margin, aRatioOPM, aRatioOPMY, ratioPeriodsToShow)
    f_captureRatio(ratio_de, aRatioDE, aRatioDEY, ratioPeriodsToShow)
    f_captureRatio(ratio_roic, aRatioROIC, aRatioROICY, ratioPeriodsToShow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALUE GETTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_histVal(int st, int m, int back) =>
    int idx = aData.size() - 1 - back
    float out = na
    if idx >= 0
        d = aData.get(idx)
        if st == 0
            out := switch m
                0 => d.incRev
                1 => d.incGross
                2 => d.incOp
                3 => d.incPretax
                4 => d.incNet
                => na
        else if st == 1
            out := switch m
                0 => d.bsAssets
                1 => d.bsLiab
                2 => d.bsEquity
                => na
        else
            out := switch m
                0 => d.cfOper
                1 => d.cfInvest
                2 => d.cfFin
                3 => d.cfFcf
                => na
    out

f_ttmVal(int st, int m) =>
    float out = na
    if st == 0
        out := switch m
            0 => inc_rev_ttm
            1 => inc_gross_ttm
            2 => inc_op_ttm
            3 => inc_pretax_ttm
            4 => inc_net_ttm
            => na
    else if st == 2
        out := switch m
            0 => cf_oper_ttm
            1 => cf_invest_ttm
            2 => cf_fin_ttm
            3 => cf_fcf_ttm
            => na
    out

f_groupValue(int st, int m, int g) =>
    f_supportsTTM(st) and g == 0 ? f_ttmVal(st, m) : f_histVal(st, m, f_supportsTTM(st) ? g - 1 : g)

f_latestFYYear() => latestFYOverride > 0 ? latestFYOverride : year(timenow) - 1

f_quarterBackLabel(int back) =>
    int qNow = int(math.ceil(month(timenow) / 3.0))
    int qBase = latestFQQuarterOverride > 0 ? latestFQQuarterOverride : (qNow == 1 ? 4 : qNow - 1)
    int yBase = latestFQYearOverride > 0 ? latestFQYearOverride : (qNow == 1 ? year(timenow) - 1 : year(timenow))
    int total = yBase * 4 + qBase - 1 - back
    "Q" + str.tostring(total % 4 + 1) + " " + str.tostring(int(math.floor(total / 4)))

f_groupLabel(int st, int g) =>
    f_supportsTTM(st) and g == 0 ? "TTM" : (periodMode == "Yearly" ? str.tostring(f_latestFYYear() - (f_supportsTTM(st) ? g - 1 : g)) : f_quarterBackLabel(f_supportsTTM(st) ? g - 1 : g))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION DRAWERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
metricSlot = barWidthBars + barGapBars
commonGroupSpan = 5 * metricSlot + groupGapBars

f_drawSection(int st, float sectionTop, float sectionBot, int xStart, int panelXEnd) =>
    int metricCount = f_metricCount(st)
    int groups = math.min(periodsToShow, aData.size()) + (f_supportsTTM(st) ? 1 : 0)
    float sectionH = math.abs(sectionTop - sectionBot)
    int xMid = int(math.round((xStart + panelXEnd) / 2.0))
    float plotTop = sectionTop - sectionH * 0.245
    float plotBot = sectionBot + sectionH * 0.140

    f_polyRect(xStart - 4, sectionBot, panelXEnd + 4, sectionTop, color.new(chart.bg_color, panelTransp), color.new(chart.fg_color, 82))
    
    float headerY = sectionTop - sectionH * 0.155
    f_text(xStart + 6, headerY, f_statementTitle(st), chart.fg_color, size.normal)

    int legendSpacing = st == 0 ? 8 : 9
    int legendStart = panelXEnd - (metricCount - 1) * legendSpacing - 2
    for m = 0 to metricCount - 1
        f_text(legendStart + m * legendSpacing, headerY, "● " + f_metricShort(st, m), f_metricColor(st, m), size.small)

    if groups > 0
        float maxRaw = na, float minRaw = na
        for g = 0 to groups - 1
            for m = 0 to metricCount - 1
                float v = f_groupValue(st, m, g)
                if not na(v)
                    maxRaw := na(maxRaw) ? v : math.max(maxRaw, v)
                    minRaw := na(minRaw) ? v : math.min(minRaw, v)

        if not na(maxRaw) and not na(minRaw)
            float pad = math.abs(maxRaw - minRaw) * 0.08
            float hi = math.max(maxRaw + pad, 0), lo = math.min(minRaw - pad, 0)
            if minRaw >= 0
                lo := 0
            if hi == lo
                hi += 1, lo -= 1

            float yHi = f_valToY(hi, lo, hi, plotBot, plotTop)
            float yMid = f_valToY((hi + lo) / 2.0, lo, hi, plotBot, plotTop)
            float yZero = f_valToY(0, lo, hi, plotBot, plotTop)
            float yLo = f_valToY(lo, lo, hi, plotBot, plotTop)

            color gridCol = color.new(chart.fg_color, gridTransp), softTxt = color.new(chart.fg_color, 10)
            f_hLine(xStart - 1, panelXEnd + 1, yHi, gridCol, 1)
            f_hLine(xStart - 1, panelXEnd + 1, yMid, gridCol, 1)
            f_hLine(xStart - 1, panelXEnd + 1, yLo, gridCol, 1)
            f_hLine(xStart - 1, panelXEnd + 1, yZero, color.new(chart.fg_color, 45), 2)

            f_text(xStart - 8, yHi, f_fmt(hi), softTxt, size.small)
            f_text(xStart - 8, yZero, "0", softTxt, size.small)
            if lo < 0
                f_text(xStart - 8, yLo, f_fmt(lo), softTxt, size.small)

            for g = 0 to groups - 1
                int groupX = xStart + g * commonGroupSpan
                for m = 0 to metricCount - 1
                    float v = f_groupValue(st, m, g)
                    if not na(v)
                        int x1 = groupX + m * metricSlot
                        float y0 = f_valToY(0, lo, hi, plotBot, plotTop), yv = f_valToY(v, lo, hi, plotBot, plotTop)
                        if math.abs(yv - y0) < sectionH * 0.01
                            yv := v >= 0 ? y0 + sectionH * 0.01 : y0 - sectionH * 0.01
                        f_polyRect(x1, y0, x1 + barWidthBars, yv, color.new(f_metricColor(st, m), 0), color.new(f_metricColor(st, m), 0))
                        if showValueLabels
                            f_text(x1 + int(math.round(barWidthBars / 2.0)), v >= 0 ? yv + sectionH * 0.025 : yv - sectionH * 0.025, f_fmt(v), softTxt, size.tiny)
                f_text(groupX + int(math.round((metricCount * metricSlot) / 2.0)), sectionBot + sectionH * 0.045, f_groupLabel(st, g), softTxt, size.small)
        else
            f_text(xMid, (sectionTop + sectionBot) / 2.0, "No data available", color.new(chart.fg_color, 10), size.small)
    else
        f_text(xMid, (sectionTop + sectionBot) / 2.0, "No data available", color.new(chart.fg_color, 10), size.small)

f_drawRatioCard(string title, float[] vals, int[] yrs, string suffix, int xLeft, int xRight, float yTop, float yBot, color curveColor) =>
    float cardH = math.abs(yTop - yBot)
    color muted = color.new(chart.fg_color, 38)
    int xMid = int(math.round((xLeft + xRight) / 2.0))
    f_text(xLeft + 4, yTop - cardH * 0.080, title, chart.fg_color, size.normal)

    int n = array.size(vals)
    if n < 2
        f_text(xMid, (yTop + yBot) / 2.0, "No FY data", muted, size.normal)
    else
        float vMin = array.min(vals), vMax = array.max(vals), rng = math.max(vMax - vMin, 1.0)
        float plotTop = yTop - cardH * 0.220, plotBottom = yBot + cardH * 0.230
        int px1 = xLeft + 5, px2 = xRight - 5
        float[] yPts = array.new_float(), int[] xPts = array.new_int()
        for i = 0 to n - 1
            array.push(yPts, plotBottom + ((array.get(vals, i) - vMin) / rng) * (plotTop - plotBottom))
            array.push(xPts, int(math.round(px1 + ((px2 - px1) * i) / math.max(n - 1, 1))))

        array<chart.point> curvePts = array.new<chart.point>()
        if smoothRatioLines
            int steps = 12
            for i = 0 to n - 2
                for s = 0 to steps
                    if i == 0 or s > 0
                        float t = s / float(steps)
                        array.push(curvePts, chart.point.from_index(int(math.round(array.get(xPts, i) + (array.get(xPts, i + 1) - array.get(xPts, i)) * t)), f_clamp(f_catmull(array.get(yPts, math.max(i - 1, 0)), array.get(yPts, i), array.get(yPts, i + 1), array.get(yPts, math.min(i + 2, n - 1)), t), plotBottom, plotTop)))
        else
            for i = 0 to n - 1
                array.push(curvePts, chart.point.from_index(array.get(xPts, i), array.get(yPts, i)))

        color solidCurve = f_opaque(curveColor)
        f_polyCurve(curvePts, solidCurve, ratioLineWidth)

        for i = 0 to n - 1
            if showRatioDots
                f_dot(array.get(xPts, i), array.get(yPts, i), solidCurve)
            if showRatioYears
                f_text(array.get(xPts, i), yBot + cardH * 0.070, str.tostring(array.get(yrs, i)), muted, size.small)
            if ratioValueLabels == "All" and i < n - 1
                f_text(array.get(xPts, i), array.get(yPts, i) + cardH * 0.095, f_fmtRatio(array.get(vals, i), suffix), muted, size.tiny)
 
        f_text(xRight - 7, yTop - cardH * 0.105, f_fmtRatio(array.get(vals, n - 1), suffix), solidCurve, size.normal)

f_drawRatioSection(float sectionTop, float sectionBot, int xStart, int panelXEnd) =>
    float sectionH = math.abs(sectionTop - sectionBot)
    f_polyRect(xStart - 4, sectionBot, panelXEnd + 4, sectionTop, color.new(chart.bg_color, panelTransp), color.new(chart.fg_color, 82))

    float cardsTop = sectionTop - sectionH * 0.150, cardsBot = sectionBot + sectionH * 0.070, rowMid = (cardsTop + cardsBot) / 2.0
    float rowGap = sectionH * 0.070
    float topRowBot = rowMid + rowGap * 0.25, botRowTop = rowMid - rowGap * 0.25
    int cardW = math.max(int(math.floor((math.max(panelXEnd - xStart, 44) - math.max(ratioCardGapBars * 3, 6)) / 2)), 18)

    color gridCol = color.new(chart.fg_color, 86)
    f_vLine(xStart + cardW + int(math.round(math.max(ratioCardGapBars * 3, 6) / 2.0)), cardsBot, cardsTop, gridCol, 1)
    f_hLine(xStart, panelXEnd, rowMid, gridCol, 1)

    f_drawRatioCard("EPS", aRatioEPS, aRatioEPSY, "", xStart, xStart + cardW, cardsTop, topRowBot, cRatioGood)
    f_drawRatioCard("Op Margin", aRatioOPM, aRatioOPMY, "%", panelXEnd - cardW, panelXEnd, cardsTop, topRowBot, cRatioGood)
    f_drawRatioCard("D/E", aRatioDE, aRatioDEY, "", xStart, xStart + cardW, botRowTop, cardsBot, cRatioDebt)
    f_drawRatioCard("ROIC", aRatioROIC, aRatioROICY, "%", panelXEnd - cardW, panelXEnd, botRowTop, cardsBot, cRatioGood)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW DASHBOARD ON RIGHT SIDE OF CHART
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceRange = math.max(ta.highest(high, verticalLookback) - ta.lowest(low, verticalLookback), syminfo.mintick * 100.0)
dashTop = ta.highest(high, verticalLookback) - priceRange * topPaddingPct / 100.0
dashBot = ta.lowest(low, verticalLookback) + priceRange * bottomPaddingPct / 100.0
usableHeight = math.max(dashTop - dashBot, priceRange)

panelUsableHeight = math.max(dashTop - usableHeight * 0.090 - dashBot, usableHeight)
gap = panelUsableHeight * sectionGapPct / 100.0

float baseH = showRatios ? (panelUsableHeight - gap * 3.0) / (3.0 * financialHeightBoost + ratioHeightMult) : (panelUsableHeight - gap * 2.0) / 3.0
statementH = math.max(showRatios ? baseH * financialHeightBoost : baseH, syminfo.mintick * 20.0)
ratioH = math.max(showRatios ? baseH * ratioHeightMult : baseH, syminfo.mintick * 20.0)

if barstate.islast
    f_clearObjects()
    int xStart = bar_index + rightOffsetBars
    int xEndTitle = math.max(xStart + math.max(math.min(periodsToShow, aData.size()) + 1, 1) * commonGroupSpan - groupGapBars, xStart + (showRatios ? 100 : 55))
    
    f_text(int(math.round((xStart + xEndTitle) / 2.0)), dashTop - (dashTop - dashBot) * 0.030, "Financial Summary + Ratios | " + syminfo.ticker + " (" + periodMode + ")", chart.fg_color, size.huge)

    float panelsTop = dashTop - (dashTop - dashBot) * 0.090
    f_drawSection(0, panelsTop, panelsTop - statementH, xStart, xEndTitle)
    f_drawSection(1, panelsTop - statementH - gap, panelsTop - statementH * 2 - gap, xStart, xEndTitle)
    f_drawSection(2, panelsTop - statementH * 2 - gap * 2, panelsTop - statementH * 3 - gap * 2, xStart, xEndTitle)

    if showRatios
        f_drawRatioSection(panelsTop - statementH * 3 - gap * 3, panelsTop - statementH * 3 - gap * 3 - ratioH, xStart, xEndTitle)
````
