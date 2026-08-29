<!-- tradingview-pine-id: PUB;60fed3e03095417988ea72e96bf12561 -->
<!-- tradingviewscripts-format: 1 -->
# Reported EPS & Revenue Growth Table - Historical

Source: https://www.tradingview.com/script/vFFFPqV3/

## Description

English

EPS & Revenue Growth Board – Historical Analysis

A fundamental analysis board designed to visualize EPS and revenue growth, acceleration, and deceleration using reported financial results.

Unlike a standard fundamentals dashboard that only shows the latest results, this indicator includes a historical date selection feature, allowing you to go back in time and examine what a company's fundamentals looked like at a specific point in the past.

This makes it useful not only for current stock analysis, but also for studying historical market leaders and major breakout stocks.

The board displays:

Quarterly EPS YoY growth
Quarterly Revenue YoY growth
Annual EPS growth
Annual Revenue growth
Quarterly growth trend
Annual growth trend
Short-term 2-quarter trend
Acceleration / deceleration indicators

Growth values are based on reported results, rather than analyst estimates or earnings surprise data.

Positive growth is displayed in green, while negative growth is displayed in red.

Trend arrows provide a quick visual indication of whether growth is accelerating or decelerating.

Historical Analysis

A date can be specified in the indicator settings.

The board will then display the financial information that would have been available around that point in time.

This allows you to study questions such as:

What did EPS and revenue growth look like before a major stock advance?
Was earnings growth accelerating before the breakout?
Did revenue growth confirm the EPS acceleration?
How did the fundamentals of past market leaders compare before their major moves?

This feature is especially useful for historical research into growth stocks and for studying characteristics commonly associated with CAN SLIM and momentum investing.

Purpose

The goal is not to predict stock prices from fundamentals alone, but to make changes in a company's growth profile easier to recognize and to combine that information with price, volume, relative strength, and chart patterns.

日本語

EPS & Revenue Growth Board – Historical Analysis

企業のEPS・売上成長率と、その加速・減速を視覚的に確認するための業績分析ボードです。

通常の業績インジケーターのように最新決算だけを見るのではなく、過去の日付を指定して、その時点で確認できた業績状態を再現できる機能を搭載しています。

そのため現在の銘柄分析だけでなく、過去の大化け株・先導株が大きく上昇する前にどのような業績だったのかを検証する用途にも使用できます。

ボードでは主に以下を表示します。

四半期EPS YoY成長率
四半期売上 YoY成長率
年間EPS成長率
年間売上成長率
四半期成長トレンド
年間成長トレンド
直近2四半期の短期トレンド
成長の加速 / 減速

数値にはアナリスト予想やサプライズではなく、**実際に発表された業績値（Reported Results）**を使用します。

成長率がプラスの場合は緑、マイナスの場合は赤で表示。

さらに矢印によって、EPSや売上成長が加速しているのか、減速しているのかを素早く確認できます。

過去分析機能

設定から日付を指定することで、過去の任意の時点まで戻って業績ボードを確認できます。

これにより、

大幅上昇前のEPS成長率はどうだったか
ブレイクアウト前にEPSは加速していたか
EPSだけでなく売上も加速していたか
過去の先導株にはどのような共通点があったか

といった検証が可能になります。

特に、過去の成長株・大化け株を研究し、CAN SLIMやモメンタム投資の観点からファンダメンタルズの共通点を探す用途を想定しています。

目的

このボード単独で株価を予測することが目的ではありません。

EPS・売上の変化を素早く把握し、価格・出来高・RS・チャートパターンなどのテクニカル分析と組み合わせて使用するための補助ツールです。

---

## Source Code

````pine
//@version=6
indicator("Reported EPS & Revenue Growth Table - Historical", overlay = false)

//==================================================
// Settings
//==================================================

rowsToShow = input.int(
     5,
     "表示する四半期数",
     minval = 4,
     maxval = 8)

// モード
mode = input.string(
     "Latest",
     "Mode",
     options = ["Latest", "Historical"])

// Historical Mode の基準日
historicalDate = input.time(
     timestamp("01 Jan 2023 23:59 +0000"),
     "Historical Date")

//==================================================
// Data
//==================================================

// 発表EPS
reportedEPS = request.earnings(
     syminfo.tickerid,
     earnings.actual,
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

// 四半期Revenue
quarterRevenue = request.financial(
     syminfo.tickerid,
     "TOTAL_REVENUE",
     "FQ",
     gaps = barmerge.gaps_on)

//==================================================
// Master Arrays
//==================================================

var epsValues = array.new_float()
var epsTimes  = array.new_int()

var revValues = array.new_float()
var revTimes  = array.new_int()

//==================================================
// Store EPS
//==================================================

if not na(reportedEPS)
    array.push(epsValues, reportedEPS)
    array.push(epsTimes, time)

//==================================================
// Store Revenue
//==================================================

if not na(quarterRevenue)
    array.push(revValues, quarterRevenue)
    array.push(revTimes, time)

//==================================================
// Functions
//==================================================

//--------------------------------------------------
// 通常のPercentage Change
// Revenue用
//--------------------------------------------------

pctChange(current, previous) =>
    not na(current) and
     not na(previous) and
     previous != 0 ?
     ((current / previous) - 1) * 100 :
     na

//--------------------------------------------------
// EPS Percentage Change
//
// 赤字EPSでも方向が逆転しないよう、
// 分母に絶対値を使用
//
// 例:
// -0.95 → +0.42 = +144.2%
// -1.07 → -0.80 = +25.2%
// +0.50 → -0.20 = -140.0%
//--------------------------------------------------

epsPctChange(current, previous) =>
    not na(current) and
     not na(previous) and
     previous != 0 ?
     ((current - previous) / math.abs(previous)) * 100 :
     na

//--------------------------------------------------
// EPS Format
//--------------------------------------------------

fmtEPS(v) =>
    na(v) ?
     "—" :
     str.tostring(v, "#.##")

//--------------------------------------------------
// Revenue Format
//--------------------------------------------------

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

//--------------------------------------------------
// Date Format
//--------------------------------------------------

fmtDate(t) =>
    na(t) ?
     "—" :
     str.tostring(year(t)) +
     "-" +
     str.tostring(month(t), "00") +
     "-" +
     str.tostring(dayofmonth(t), "00")

//--------------------------------------------------
// Trend Display
//--------------------------------------------------

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

//--------------------------------------------------
// Arrow Only
//--------------------------------------------------

fmtArrow(currentGrowth, previousGrowth) =>
    na(currentGrowth) or na(previousGrowth) ?
     "—" :
     currentGrowth > previousGrowth ?
     "↑" :
     currentGrowth < previousGrowth ?
     "↓" :
     "→"

//--------------------------------------------------
// Trend Color
//--------------------------------------------------

trendColor(
     currentGrowth,
     previousGrowth,
     positiveColor,
     negativeColor,
     normalColor) =>

    na(currentGrowth) or na(previousGrowth) ?
     normalColor :
     currentGrowth > previousGrowth ?
     positiveColor :
     currentGrowth < previousGrowth ?
     negativeColor :
     normalColor

//--------------------------------------------------
// Cutoff Date
//--------------------------------------------------

getCutoff() =>
    mode == "Historical" ?
     historicalDate :
     timenow

//--------------------------------------------------
// cutoff以前の最新データを探す
//--------------------------------------------------

findLastIndex(timesArray, cutoff) =>
    int result = na
    int size = array.size(timesArray)

    if size > 0
        for j = 0 to size - 1
            int t = array.get(timesArray, j)

            if t <= cutoff
                result := j

    result

//--------------------------------------------------
// Safe Float Array Get
//--------------------------------------------------

safeGetFloat(arr, index) =>
    float result = na

    if not na(index)
        if index >= 0 and index < array.size(arr)
            result := array.get(arr, index)

    result

//--------------------------------------------------
// Safe Time Array Get
//--------------------------------------------------

safeGetTime(arr, index) =>
    int result = na

    if not na(index)
        if index >= 0 and index < array.size(arr)
            result := array.get(arr, index)

    result

//==================================================
// Table
//==================================================

var table tbl = table.new(
     position.middle_center,
     9,
     rowsToShow + 2,
     border_width = 1,
     border_color = color.rgb(170, 170, 170))

//==================================================
// Draw
//==================================================

if barstate.islast

    //--------------------------------------------------
    // Colors
    //--------------------------------------------------

    headerBg = color.rgb(230, 230, 230)

    infoBg =
         mode == "Historical" ?
         color.rgb(255, 245, 200) :
         color.rgb(235, 245, 255)

    cellBg = color.white

    normalText   = color.black
    positiveText = color.rgb(0, 130, 0)
    negativeText = color.rgb(200, 0, 0)

    //--------------------------------------------------
    // Cutoff
    //--------------------------------------------------

    int cutoff = getCutoff()

    int epsLastIndex =
         findLastIndex(
             epsTimes,
             cutoff)

    int revLastIndex =
         findLastIndex(
             revTimes,
             cutoff)

    //--------------------------------------------------
    // Mode Information
    //--------------------------------------------------

    string modeText =
         mode == "Historical" ?
         "Historical Snapshot: " + fmtDate(historicalDate) :
         "Latest Results"

    table.cell(
         tbl,
         0,
         0,
         modeText,
         bgcolor = infoBg,
         text_color = normalText)

    for c = 1 to 8
        table.cell(
             tbl,
             c,
             0,
             "",
             bgcolor = infoBg)

    //--------------------------------------------------
    // Header
    //--------------------------------------------------

    table.cell(
         tbl, 0, 1, "Report",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 1, 1, "EPS",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 2, 1, "Q Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 3, 1, "2Q",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 4, 1, "Y Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 5, 1, "Revenue",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 6, 1, "Q Trend",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 7, 1, "2Q",
         bgcolor = headerBg,
         text_color = normalText)

    table.cell(
         tbl, 8, 1, "Y Trend",
         bgcolor = headerBg,
         text_color = normalText)

    //==================================================
    // Rows
    //==================================================

    for i = 0 to rowsToShow - 1

        //--------------------------------------------------
        // Array Indexes
        //--------------------------------------------------

        int ei =
             not na(epsLastIndex) ?
             epsLastIndex - i :
             na

        int ri =
             not na(revLastIndex) ?
             revLastIndex - i :
             na

        //--------------------------------------------------
        // EPS Values
        //--------------------------------------------------

        float currentEPS =
             safeGetFloat(
                 epsValues,
                 ei)

        float previousEPS =
             safeGetFloat(
                 epsValues,
                 not na(ei) ? ei - 1 : na)

        float twoAgoEPS =
             safeGetFloat(
                 epsValues,
                 not na(ei) ? ei - 2 : na)

        float yearAgoEPS =
             safeGetFloat(
                 epsValues,
                 not na(ei) ? ei - 4 : na)

        float fiveAgoEPS =
             safeGetFloat(
                 epsValues,
                 not na(ei) ? ei - 5 : na)

        float sixAgoEPS =
             safeGetFloat(
                 epsValues,
                 not na(ei) ? ei - 6 : na)

        //--------------------------------------------------
        // Revenue Values
        //--------------------------------------------------

        float currentRevenue =
             safeGetFloat(
                 revValues,
                 ri)

        float previousRevenue =
             safeGetFloat(
                 revValues,
                 not na(ri) ? ri - 1 : na)

        float twoAgoRevenue =
             safeGetFloat(
                 revValues,
                 not na(ri) ? ri - 2 : na)

        float yearAgoRevenue =
             safeGetFloat(
                 revValues,
                 not na(ri) ? ri - 4 : na)

        float fiveAgoRevenue =
             safeGetFloat(
                 revValues,
                 not na(ri) ? ri - 5 : na)

        float sixAgoRevenue =
             safeGetFloat(
                 revValues,
                 not na(ri) ? ri - 6 : na)

        //--------------------------------------------------
        // Report Time
        //--------------------------------------------------

        int reportTime =
             safeGetTime(
                 epsTimes,
                 ei)

        //--------------------------------------------------
        // EPS Q Trend
        //--------------------------------------------------

        float epsQ =
             epsPctChange(
                 currentEPS,
                 previousEPS)

        float previousEPSQ =
             epsPctChange(
                 previousEPS,
                 twoAgoEPS)

        //--------------------------------------------------
        // EPS Y Trend
        //--------------------------------------------------

        float epsY =
             epsPctChange(
                 currentEPS,
                 yearAgoEPS)

        float previousEPSY =
             epsPctChange(
                 previousEPS,
                 fiveAgoEPS)

        //--------------------------------------------------
        // EPS 2Q
        //--------------------------------------------------

        float eps2QCurrent =
             not na(currentEPS) and
             not na(previousEPS) and
             not na(yearAgoEPS) and
             not na(fiveAgoEPS) ?

             epsPctChange(
                 currentEPS + previousEPS,
                 yearAgoEPS + fiveAgoEPS) :
             na

        float eps2QPrevious =
             not na(previousEPS) and
             not na(twoAgoEPS) and
             not na(fiveAgoEPS) and
             not na(sixAgoEPS) ?

             epsPctChange(
                 previousEPS + twoAgoEPS,
                 fiveAgoEPS + sixAgoEPS) :
             na

        //--------------------------------------------------
        // Revenue Q Trend
        //--------------------------------------------------

        float revenueQ =
             pctChange(
                 currentRevenue,
                 previousRevenue)

        float previousRevenueQ =
             pctChange(
                 previousRevenue,
                 twoAgoRevenue)

        //--------------------------------------------------
        // Revenue Y Trend
        //--------------------------------------------------

        float revenueY =
             pctChange(
                 currentRevenue,
                 yearAgoRevenue)

        float previousRevenueY =
             pctChange(
                 previousRevenue,
                 fiveAgoRevenue)

        //--------------------------------------------------
        // Revenue 2Q
        //--------------------------------------------------

        float revenue2QCurrent =
             not na(currentRevenue) and
             not na(previousRevenue) and
             not na(yearAgoRevenue) and
             not na(fiveAgoRevenue) ?

             pctChange(
                 currentRevenue + previousRevenue,
                 yearAgoRevenue + fiveAgoRevenue) :
             na

        float revenue2QPrevious =
             not na(previousRevenue) and
             not na(twoAgoRevenue) and
             not na(fiveAgoRevenue) and
             not na(sixAgoRevenue) ?

             pctChange(
                 previousRevenue + twoAgoRevenue,
                 fiveAgoRevenue + sixAgoRevenue) :
             na

        //--------------------------------------------------
        // EPS Value Color
        //--------------------------------------------------

        color epsValueColor =
             na(currentEPS) or
             na(previousEPS) ?

             normalText :

             currentEPS > previousEPS ?
             positiveText :

             currentEPS < previousEPS ?
             negativeText :

             normalText

        //--------------------------------------------------
        // Revenue Value Color
        //--------------------------------------------------

        color revenueValueColor =
             na(currentRevenue) or
             na(previousRevenue) ?

             normalText :

             currentRevenue > previousRevenue ?
             positiveText :

             currentRevenue < previousRevenue ?
             negativeText :

             normalText

        //--------------------------------------------------
        // Trend Colors
        //--------------------------------------------------

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

        //--------------------------------------------------
        // Table Cells
        //--------------------------------------------------

        // Report
        table.cell(
             tbl,
             0,
             i + 2,
             fmtDate(reportTime),
             bgcolor = cellBg,
             text_color = normalText)

        // EPS
        table.cell(
             tbl,
             1,
             i + 2,
             fmtEPS(currentEPS),
             bgcolor = cellBg,
             text_color = epsValueColor)

        // EPS Q Trend
        table.cell(
             tbl,
             2,
             i + 2,
             fmtTrend(
                 epsQ,
                 previousEPSQ),
             bgcolor = cellBg,
             text_color = epsQColor)

        // EPS 2Q
        table.cell(
             tbl,
             3,
             i + 2,
             fmtArrow(
                 eps2QCurrent,
                 eps2QPrevious),
             bgcolor = cellBg,
             text_color = eps2QColor)

        // EPS Y Trend
        table.cell(
             tbl,
             4,
             i + 2,
             fmtTrend(
                 epsY,
                 previousEPSY),
             bgcolor = cellBg,
             text_color = epsYColor)

        // Revenue
        table.cell(
             tbl,
             5,
             i + 2,
             fmtRevenue(currentRevenue),
             bgcolor = cellBg,
             text_color = revenueValueColor)

        // Revenue Q Trend
        table.cell(
             tbl,
             6,
             i + 2,
             fmtTrend(
                 revenueQ,
                 previousRevenueQ),
             bgcolor = cellBg,
             text_color = revenueQColor)

        // Revenue 2Q
        table.cell(
             tbl,
             7,
             i + 2,
             fmtArrow(
                 revenue2QCurrent,
                 revenue2QPrevious),
             bgcolor = cellBg,
             text_color = revenue2QColor)

        // Revenue Y Trend
        table.cell(
             tbl,
             8,
             i + 2,
             fmtTrend(
                 revenueY,
                 previousRevenueY),
             bgcolor = cellBg,
             text_color = revenueYColor)
````
