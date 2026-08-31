<!-- tradingview-pine-id: PUB;6d77e70a2db5499e9fe3b6cc8c0aa2e5 -->
<!-- tradingviewscripts-format: 1 -->
# EPS & Revenue Growth Table

Source: https://www.tradingview.com/script/fOJJY5tX/

## Description

English

EPS & Revenue Growth Table

This indicator provides a compact view of quarterly EPS and revenue growth, designed to make changes in fundamental momentum easier to identify.

It displays the latest quarterly results in a table and tracks both short-term and year-over-year growth trends.

Features:

Quarterly Diluted EPS
Quarterly Revenue
Quarter-over-Quarter (Q Trend) growth
Year-over-Year (Y Trend) growth
2-quarter trend to help reduce the impact of seasonality
Acceleration / deceleration indicators for both EPS and Revenue

How to read it:

Green EPS / Revenue: Higher than the previous quarter
Red EPS / Revenue: Lower than the previous quarter
↑ Green: Growth momentum is accelerating
↓ Red: Growth momentum is decelerating
→: Growth momentum is roughly unchanged

2Q compares the combined performance of two consecutive quarters with the corresponding two-quarter period from the previous year. Only the direction of acceleration is displayed to keep the table compact.

For example:

Y Trend +40% ↑

means the current quarter grew 40% year-over-year, and the YoY growth rate accelerated compared with the previous quarter.

The indicator is intended to quickly identify companies showing improving or accelerating fundamental momentum and can be used alongside price, volume, relative strength, and technical setup analysis.

日本語

EPS & Revenue Growth Table

四半期ごとのEPSと売上高を一覧表示し、業績モメンタムの加速・減速を素早く確認するためのインジケーターです。

直近の決算データについて、EPS・売上高そのものだけでなく、前四半期比・前年同期比・2四半期ベースでの業績トレンドを表示します。

主な機能：

四半期希薄化後EPS
四半期売上高
前四半期比（Q Trend）
前年同期比（Y Trend）
季節性の影響を軽減するための2四半期トレンド（2Q）
EPS・売上高それぞれの成長加速／減速判定

表示の見方：

EPS / Revenueが緑： 前四半期より増加
EPS / Revenueが赤： 前四半期より減少
↑ 緑： 成長率が加速
↓ 赤： 成長率が減速
→： 成長率がおおむね横ばい

2Qは、連続する2四半期の合計を前年の対応する2四半期と比較することで、単一四半期に生じる季節性の影響を軽減してトレンドを確認するための指標です。表をコンパクトにするため、2Qについては加速・減速の方向のみ表示します。

たとえば、

Y Trend +40% ↑

なら、前年同期比で40%成長しており、さらにYoY成長率が前四半期より加速していることを意味します。

株価・出来高・相対的強さ・チャートパターンなどと組み合わせて、ファンダメンタルズが改善・加速している企業を素早く確認することを目的としています。

---

## Source Code

````pine
//@version=6
indicator("EPS & Revenue Growth Table", overlay = false)

//==================================================
// Settings
//==================================================
rowsToShow = input.int(
     5,
     "表示する四半期数",
     minval = 4,
     maxval = 12)

//==================================================
// Financial Data
//==================================================

eps = request.financial(
     syminfo.tickerid,
     "EARNINGS_PER_SHARE_DILUTED",
     "FQ",
     gaps = barmerge.gaps_on)

revenue = request.financial(
     syminfo.tickerid,
     "TOTAL_REVENUE",
     "FQ",
     gaps = barmerge.gaps_on)

//==================================================
// Arrays
//==================================================

var epsArr     = array.new_float()
var revenueArr = array.new_float()
var timeArr    = array.new_int()

newQuarter = not na(eps)

if newQuarter
    array.unshift(epsArr, eps)
    array.unshift(revenueArr, revenue)
    array.unshift(timeArr, time)

    // 2Q / YoY判定用に余分に保持
    if array.size(epsArr) > rowsToShow + 7
        array.pop(epsArr)
        array.pop(revenueArr)
        array.pop(timeArr)

//==================================================
// Functions
//==================================================

pctChange(current, previous) =>
    not na(current) and
     not na(previous) and
     previous != 0 ?
     ((current / previous) - 1) * 100 :
     na

fmtEPS(v) =>
    na(v) ?
     "—" :
     str.tostring(v, "#.##")

fmtRevenue(v) =>
    na(v) ?
     "—" :
     math.abs(v) >= 1000000000 ?
         str.tostring(v / 1000000000, "#.##") + "B" :
     math.abs(v) >= 1000000 ?
         str.tostring(v / 1000000, "#.##") + "M" :
     math.abs(v) >= 1000 ?
         str.tostring(v / 1000, "#.##") + "K" :
         str.tostring(v, "#.##")

quarterText(t) =>
    m = month(t)
    q = math.ceil(m / 3.0)

    str.tostring(year(t)) +
     " Q" +
     str.tostring(int(q))

//==================================================
// Growth % + acceleration arrow
//==================================================

fmtTrend(currentGrowth, previousGrowth) =>
    if na(currentGrowth)
        "—"
    else
        base =
             (currentGrowth > 0 ? "+" : "") +
             str.tostring(currentGrowth, "#.#") +
             "%"

        arrow =
             na(previousGrowth) ?
             "" :
             currentGrowth > previousGrowth ?
             " ↑" :
             currentGrowth < previousGrowth ?
             " ↓" :
             " →"

        base + arrow

//==================================================
// Arrow only
//==================================================

fmtArrow(currentGrowth, previousGrowth) =>
    na(currentGrowth) or na(previousGrowth) ?
     "—" :
     currentGrowth > previousGrowth ?
     "↑" :
     currentGrowth < previousGrowth ?
     "↓" :
     "→"

//==================================================
// Trend Color
//==================================================

trendColor(currentGrowth, previousGrowth, positiveColor, negativeColor, normalColor) =>
    na(currentGrowth) or na(previousGrowth) ?
     normalColor :
     currentGrowth > previousGrowth ?
     positiveColor :
     currentGrowth < previousGrowth ?
     negativeColor :
     normalColor

//==================================================
// Table
//==================================================

var table tbl = table.new(
     position.middle_center,
     9,
     rowsToShow + 1,
     border_width = 1,
     border_color = color.rgb(170, 170, 170))

//==================================================
// Draw
//==================================================

if barstate.islast

    //==================================================
    // Colors
    //==================================================

    headerBg = color.rgb(230, 230, 230)
    cellBg   = color.white

    normalText   = color.black
    positiveText = color.rgb(0, 130, 0)
    negativeText = color.rgb(200, 0, 0)

    //==================================================
    // Header
    //==================================================

    table.cell(tbl, 0, 0, "Quarter",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 1, 0, "EPS",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 2, 0, "Q Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 3, 0, "2Q",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 4, 0, "Y Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 5, 0, "Revenue",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 6, 0, "Q Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 7, 0, "2Q",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(tbl, 8, 0, "Y Trend",
         bgcolor = headerBg,
         text_color = normalText)

    //==================================================
    // Rows
    //==================================================

    for i = 0 to rowsToShow - 1

        //==================================================
        // EPS Values
        //==================================================

        float currentEPS =
             array.size(epsArr) > i ?
             array.get(epsArr, i) : na

        float previousEPS =
             array.size(epsArr) > i + 1 ?
             array.get(epsArr, i + 1) : na

        float twoAgoEPS =
             array.size(epsArr) > i + 2 ?
             array.get(epsArr, i + 2) : na

        float yearAgoEPS =
             array.size(epsArr) > i + 4 ?
             array.get(epsArr, i + 4) : na

        //==================================================
        // Revenue Values
        //==================================================

        float currentRevenue =
             array.size(revenueArr) > i ?
             array.get(revenueArr, i) : na

        float previousRevenue =
             array.size(revenueArr) > i + 1 ?
             array.get(revenueArr, i + 1) : na

        float twoAgoRevenue =
             array.size(revenueArr) > i + 2 ?
             array.get(revenueArr, i + 2) : na

        float yearAgoRevenue =
             array.size(revenueArr) > i + 4 ?
             array.get(revenueArr, i + 4) : na

        //==================================================
        // Quarter
        //==================================================

        int quarterTime =
             array.size(timeArr) > i ?
             array.get(timeArr, i) : na

        //==================================================
        // EPS Q Trend
        //==================================================

        float epsQ =
             pctChange(currentEPS, previousEPS)

        float previousEPSQ =
             pctChange(previousEPS, twoAgoEPS)

        //==================================================
        // EPS Y Trend
        //==================================================

        float epsY =
             pctChange(currentEPS, yearAgoEPS)

        float previousEPSY =
             array.size(epsArr) > i + 5 ?
             pctChange(
                 array.get(epsArr, i + 1),
                 array.get(epsArr, i + 5)) :
             na

        //==================================================
        // EPS 2Q Trend
        //
        // 今期 + 前期
        //      VS
        // 4Q前 + 5Q前
        //==================================================

        float eps2QCurrent =
             array.size(epsArr) > i + 5 ?
             pctChange(
                 array.get(epsArr, i) +
                 array.get(epsArr, i + 1),

                 array.get(epsArr, i + 4) +
                 array.get(epsArr, i + 5)) :
             na

        // 一つ前の時点での2Q成長率
        float eps2QPrevious =
             array.size(epsArr) > i + 6 ?
             pctChange(
                 array.get(epsArr, i + 1) +
                 array.get(epsArr, i + 2),

                 array.get(epsArr, i + 5) +
                 array.get(epsArr, i + 6)) :
             na

        //==================================================
        // Revenue Q Trend
        //==================================================

        float revenueQ =
             pctChange(
                 currentRevenue,
                 previousRevenue)

        float previousRevenueQ =
             pctChange(
                 previousRevenue,
                 twoAgoRevenue)

        //==================================================
        // Revenue Y Trend
        //==================================================

        float revenueY =
             pctChange(
                 currentRevenue,
                 yearAgoRevenue)

        float previousRevenueY =
             array.size(revenueArr) > i + 5 ?
             pctChange(
                 array.get(revenueArr, i + 1),
                 array.get(revenueArr, i + 5)) :
             na

        //==================================================
        // Revenue 2Q Trend
        //==================================================

        float revenue2QCurrent =
             array.size(revenueArr) > i + 5 ?
             pctChange(
                 array.get(revenueArr, i) +
                 array.get(revenueArr, i + 1),

                 array.get(revenueArr, i + 4) +
                 array.get(revenueArr, i + 5)) :
             na

        float revenue2QPrevious =
             array.size(revenueArr) > i + 6 ?
             pctChange(
                 array.get(revenueArr, i + 1) +
                 array.get(revenueArr, i + 2),

                 array.get(revenueArr, i + 5) +
                 array.get(revenueArr, i + 6)) :
             na

        //==================================================
        // EPS / Revenue Value Colors
        //==================================================

        color epsValueColor =
             na(currentEPS) or na(previousEPS) ?
             normalText :
             currentEPS > previousEPS ?
             positiveText :
             currentEPS < previousEPS ?
             negativeText :
             normalText

        color revenueValueColor =
             na(currentRevenue) or na(previousRevenue) ?
             normalText :
             currentRevenue > previousRevenue ?
             positiveText :
             currentRevenue < previousRevenue ?
             negativeText :
             normalText

        //==================================================
        // Trend Colors
        //==================================================

        color epsQColor =
             trendColor(
                 epsQ,
                 previousEPSQ,
                 positiveText,
                 negativeText,
                 normalText)

        color eps2QColor =
             trendColor(
                 eps2QCurrent,
                 eps2QPrevious,
                 positiveText,
                 negativeText,
                 normalText)

        color epsYColor =
             trendColor(
                 epsY,
                 previousEPSY,
                 positiveText,
                 negativeText,
                 normalText)

        color revenueQColor =
             trendColor(
                 revenueQ,
                 previousRevenueQ,
                 positiveText,
                 negativeText,
                 normalText)

        color revenue2QColor =
             trendColor(
                 revenue2QCurrent,
                 revenue2QPrevious,
                 positiveText,
                 negativeText,
                 normalText)

        color revenueYColor =
             trendColor(
                 revenueY,
                 previousRevenueY,
                 positiveText,
                 negativeText,
                 normalText)

        //==================================================
        // Table Cells
        //==================================================

        // Quarter
        table.cell(
             tbl, 0, i + 1,
             na(quarterTime) ? "—" : quarterText(quarterTime),
             bgcolor = cellBg,
             text_color = normalText)

        // EPS
        table.cell(
             tbl, 1, i + 1,
             fmtEPS(currentEPS),
             bgcolor = cellBg,
             text_color = epsValueColor)

        // EPS Q Trend
        table.cell(
             tbl, 2, i + 1,
             fmtTrend(epsQ, previousEPSQ),
             bgcolor = cellBg,
             text_color = epsQColor)

        // EPS 2Q arrow
        table.cell(
             tbl, 3, i + 1,
             fmtArrow(eps2QCurrent, eps2QPrevious),
             bgcolor = cellBg,
             text_color = eps2QColor)

        // EPS Y Trend
        table.cell(
             tbl, 4, i + 1,
             fmtTrend(epsY, previousEPSY),
             bgcolor = cellBg,
             text_color = epsYColor)

        // Revenue
        table.cell(
             tbl, 5, i + 1,
             fmtRevenue(currentRevenue),
             bgcolor = cellBg,
             text_color = revenueValueColor)

        // Revenue Q Trend
        table.cell(
             tbl, 6, i + 1,
             fmtTrend(revenueQ, previousRevenueQ),
             bgcolor = cellBg,
             text_color = revenueQColor)

        // Revenue 2Q arrow
        table.cell(
             tbl, 7, i + 1,
             fmtArrow(revenue2QCurrent, revenue2QPrevious),
             bgcolor = cellBg,
             text_color = revenue2QColor)

        // Revenue Y Trend
        table.cell(
             tbl, 8, i + 1,
             fmtTrend(revenueY, previousRevenueY),
             bgcolor = cellBg,
             text_color = revenueYColor)
````
