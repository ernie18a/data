# Reported EPS & Revenue Growth Table - Historical

- url: https://www.tradingview.com/script/vFFFPqV3/
- type: indicator
- pine_id: PUB;60fed3e03095417988ea72e96bf12561
- version: 3.0

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

## Source Code

````pine
//@version=6
indicator("Earnings Growth & Acceleration Dashboard", overlay=false)
// Version 2.1 - Updated chart and documentation.
//==================================================
// PURPOSE
//
// EPS and Revenue performance dashboard that automatically
// follows the rightmost visible chart bar.
//
// 1 row = 1 quarter
//
// Report | EPS | QoQ | 2Q | YoY | | Revenue | QoQ | 2Q | YoY
//
// Scroll the chart left or right to automatically change
// the dashboard snapshot date.
//==================================================

//==================================================
// SETTINGS
//==================================================

rowsToShow = input.int(
     5,
     "Quarters to Display",
     minval=4,
     maxval=8)

//==================================================
// RIGHT-EDGE AUTO SNAPSHOT
//
// The rightmost visible daily bar becomes the reference date.
//
// Moving the chart:
// Right edge = today → latest results
// Right edge = past  → historical snapshot
//
// Future earnings data is excluded automatically.
//==================================================

referenceTime = chart.right_visible_bar_time

//==================================================
// RAW DATA
//==================================================

//--------------------------------------------------
// Reported EPS
//--------------------------------------------------

reportedEPS = request.earnings(
     syminfo.tickerid,
     earnings.actual,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off)

//--------------------------------------------------
// Quarterly Revenue
//--------------------------------------------------

quarterRevenue = request.financial(
     syminfo.tickerid,
     "TOTAL_REVENUE",
     "FQ",
     gaps=barmerge.gaps_on,
     ignore_invalid_symbol=true)

//==================================================
// ELIGIBLE DATA
//==================================================

bool dateAllowed =
     time <= referenceTime

//==================================================
// ARRAYS
//==================================================

var epsValues = array.new_float()
var epsTimes = array.new_int()
var revValues = array.new_float()

//==================================================
// STORE EPS
//==================================================

if not na(reportedEPS) and dateAllowed
    array.push(
         epsValues,
         reportedEPS)

    array.push(
         epsTimes,
         time)

//==================================================
// STORE REVENUE
//==================================================

if not na(quarterRevenue) and dateAllowed
    array.push(
         revValues,
         quarterRevenue)

//==================================================
// LIMIT HISTORY
//==================================================

maxHistory = 100

while array.size(epsValues) > maxHistory
    array.shift(epsValues)
    array.shift(epsTimes)

while array.size(revValues) > maxHistory
    array.shift(revValues)

//==================================================
// FUNCTIONS
//==================================================

//--------------------------------------------------
// Revenue Percentage Change
//--------------------------------------------------

pctChange(current, previous) =>
    float result = na

    if not na(current) and not na(previous) and previous != 0
        result :=
             ((current / previous) - 1.0) *
             100.0

    result

//--------------------------------------------------
// EPS Percentage Change
//--------------------------------------------------

epsPctChange(current, previous) =>
    float result = na

    if not na(current) and not na(previous) and previous != 0
        result :=
             ((current - previous) /
              math.abs(previous)) *
             100.0

    result

//--------------------------------------------------
// EPS FORMAT
//--------------------------------------------------

fmtEPS(v) =>
    string result = "—"

    if not na(v)
        result := str.tostring(v, "#.##")

    result

//--------------------------------------------------
// REVENUE FORMAT
//--------------------------------------------------

fmtRevenue(v) =>
    string result = "—"

    if not na(v)
        if math.abs(v) >= 1000000000
            result :=
                 str.tostring(
                      v / 1000000000,
                      "#.##") +
                 "B"

        else if math.abs(v) >= 1000000
            result :=
                 str.tostring(
                      v / 1000000,
                      "#.##") +
                 "M"

        else if math.abs(v) >= 1000
            result :=
                 str.tostring(
                      v / 1000,
                      "#.##") +
                 "K"

        else
            result :=
                 str.tostring(
                      v,
                      "#.##")

    result

//--------------------------------------------------
// DATE FORMAT
//--------------------------------------------------

fmtDate(t) =>
    string result = "—"

    if not na(t)
        result :=
             str.tostring(year(t)) +
             "-" +
             str.tostring(month(t), "00") +
             "-" +
             str.tostring(dayofmonth(t), "00")

    result

//--------------------------------------------------
// TREND DISPLAY
//--------------------------------------------------

fmtTrend(currentGrowth, previousGrowth) =>
    string result = "—"

    if not na(currentGrowth)

        string sign =
             currentGrowth > 0
             ? "+"
             : ""

        string base =
             sign +
             str.tostring(
                  currentGrowth,
                  "#.#") +
             "%"

        string arrow = ""

        if not na(previousGrowth)
            if currentGrowth > previousGrowth
                arrow := " ↑"

            else if currentGrowth < previousGrowth
                arrow := " ↓"

            else
                arrow := " →"

        result :=
             base +
             arrow

    result

//--------------------------------------------------
// ARROW ONLY
//--------------------------------------------------

fmtArrow(currentGrowth, previousGrowth) =>
    string result = "—"

    if not na(currentGrowth) and not na(previousGrowth)

        if currentGrowth > previousGrowth
            result := "↑"

        else if currentGrowth < previousGrowth
            result := "↓"

        else
            result := "→"

    result

//--------------------------------------------------
// TREND COLOR
//--------------------------------------------------

trendColor(
     currentGrowth,
     previousGrowth,
     positiveColor,
     negativeColor,
     normalColor) =>

    color result = normalColor

    if not na(currentGrowth) and not na(previousGrowth)

        if currentGrowth > previousGrowth
            result := positiveColor

        else if currentGrowth < previousGrowth
            result := negativeColor

    result

//--------------------------------------------------
// SAFE FLOAT ARRAY GET
//--------------------------------------------------

safeGetFloat(arr, index) =>
    float result = na

    if not na(index)
        if index >= 0 and index < array.size(arr)
            result :=
                 array.get(
                      arr,
                      index)

    result

//--------------------------------------------------
// SAFE TIME ARRAY GET
//--------------------------------------------------

safeGetTime(arr, index) =>
    int result = na

    if not na(index)
        if index >= 0 and index < array.size(arr)
            result :=
                 array.get(
                      arr,
                      index)

    result

//==================================================
// TABLE
//
// Column layout:
//
// 0 Report
// 1 EPS
// 2 QoQ
// 3 2Q
// 4 YoY
// 5 Separator
// 6 Revenue
// 7 QoQ
// 8 2Q
// 9 YoY
//==================================================

var table tbl = table.new(
     position.middle_center,
     10,
     rowsToShow + 2,
     border_width=1,
     border_color=color.rgb(
          170,
          170,
          170))

//==================================================
// DRAW
//==================================================

if barstate.islast

    //==================================================
    // COLORS
    //==================================================

    headerBg =
         color.rgb(
              230,
              230,
              230)

    infoBg =
         color.rgb(
              235,
              245,
              255)

    cellBg =
         color.white

    separatorBg =
         color.rgb(
              160,
              160,
              160)

    normalText =
         color.black

    positiveText =
         color.rgb(
              0,
              130,
              0)

    negativeText =
         color.rgb(
              200,
              0,
              0)

    //==================================================
    // LATEST ARRAY INDEX
    //==================================================

    int epsLastIndex =
         array.size(epsValues) > 0
         ? array.size(epsValues) - 1
         : na

    int revLastIndex =
         array.size(revValues) > 0
         ? array.size(revValues) - 1
         : na

    //==================================================
    // SNAPSHOT INFORMATION
    //==================================================

    string modeText =
         "Snapshot: " +
         fmtDate(referenceTime)

    table.cell(
         tbl,
         0,
         0,
         modeText,
         bgcolor=infoBg,
         text_color=normalText)

    for c = 1 to 9
        table.cell(
             tbl,
             c,
             0,
             "",
             bgcolor=
                  c == 5
                  ? separatorBg
                  : infoBg)

    //==================================================
    // HEADER
    //==================================================

    table.cell(
         tbl,
         0,
         1,
         "Report",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         1,
         1,
         "EPS",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         2,
         1,
         "QoQ",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         3,
         1,
         "2Q",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         4,
         1,
         "YoY",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         5,
         1,
         "",
         width=1,
         bgcolor=separatorBg)

    table.cell(
         tbl,
         6,
         1,
         "Revenue",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         7,
         1,
         "QoQ",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         8,
         1,
         "2Q",
         bgcolor=headerBg,
         text_color=normalText)

    table.cell(
         tbl,
         9,
         1,
         "YoY",
         bgcolor=headerBg,
         text_color=normalText)

    //==================================================
    // ROWS
    //==================================================

    for i = 0 to rowsToShow - 1

        //--------------------------------------------------
        // ARRAY INDEXES
        //--------------------------------------------------

        int ei =
             not na(epsLastIndex)
             ? epsLastIndex - i
             : na

        int ri =
             not na(revLastIndex)
             ? revLastIndex - i
             : na

        //==================================================
        // EPS VALUES
        //==================================================

        float currentEPS =
             safeGetFloat(
                  epsValues,
                  ei)

        float previousEPS =
             safeGetFloat(
                  epsValues,
                  not na(ei)
                  ? ei - 1
                  : na)

        float twoAgoEPS =
             safeGetFloat(
                  epsValues,
                  not na(ei)
                  ? ei - 2
                  : na)

        float yearAgoEPS =
             safeGetFloat(
                  epsValues,
                  not na(ei)
                  ? ei - 4
                  : na)

        float fiveAgoEPS =
             safeGetFloat(
                  epsValues,
                  not na(ei)
                  ? ei - 5
                  : na)

        float sixAgoEPS =
             safeGetFloat(
                  epsValues,
                  not na(ei)
                  ? ei - 6
                  : na)

        //==================================================
        // REVENUE VALUES
        //==================================================

        float currentRevenue =
             safeGetFloat(
                  revValues,
                  ri)

        float previousRevenue =
             safeGetFloat(
                  revValues,
                  not na(ri)
                  ? ri - 1
                  : na)

        float twoAgoRevenue =
             safeGetFloat(
                  revValues,
                  not na(ri)
                  ? ri - 2
                  : na)

        float yearAgoRevenue =
             safeGetFloat(
                  revValues,
                  not na(ri)
                  ? ri - 4
                  : na)

        float fiveAgoRevenue =
             safeGetFloat(
                  revValues,
                  not na(ri)
                  ? ri - 5
                  : na)

        float sixAgoRevenue =
             safeGetFloat(
                  revValues,
                  not na(ri)
                  ? ri - 6
                  : na)

        //==================================================
        // REPORT TIME
        //==================================================

        int reportTime =
             safeGetTime(
                  epsTimes,
                  ei)

        //==================================================
        // EPS QoQ
        //==================================================

        float epsQ =
             epsPctChange(
                  currentEPS,
                  previousEPS)

        float previousEPSQ =
             epsPctChange(
                  previousEPS,
                  twoAgoEPS)

        //==================================================
        // EPS YoY
        //==================================================

        float epsY =
             epsPctChange(
                  currentEPS,
                  yearAgoEPS)

        float previousEPSY =
             epsPctChange(
                  previousEPS,
                  fiveAgoEPS)

        //==================================================
        // EPS 2Q
        //==================================================

        float eps2QCurrent = na

        if not na(currentEPS) and
           not na(previousEPS) and
           not na(yearAgoEPS) and
           not na(fiveAgoEPS)

            eps2QCurrent :=
                 epsPctChange(
                      currentEPS +
                      previousEPS,
                      yearAgoEPS +
                      fiveAgoEPS)

        float eps2QPrevious = na

        if not na(previousEPS) and
           not na(twoAgoEPS) and
           not na(fiveAgoEPS) and
           not na(sixAgoEPS)

            eps2QPrevious :=
                 epsPctChange(
                      previousEPS +
                      twoAgoEPS,
                      fiveAgoEPS +
                      sixAgoEPS)

        //==================================================
        // REVENUE QoQ
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
        // REVENUE YoY
        //==================================================

        float revenueY =
             pctChange(
                  currentRevenue,
                  yearAgoRevenue)

        float previousRevenueY =
             pctChange(
                  previousRevenue,
                  fiveAgoRevenue)

        //==================================================
        // REVENUE 2Q
        //==================================================

        float revenue2QCurrent = na

        if not na(currentRevenue) and
           not na(previousRevenue) and
           not na(yearAgoRevenue) and
           not na(fiveAgoRevenue)

            revenue2QCurrent :=
                 pctChange(
                      currentRevenue +
                      previousRevenue,
                      yearAgoRevenue +
                      fiveAgoRevenue)

        float revenue2QPrevious = na

        if not na(previousRevenue) and
           not na(twoAgoRevenue) and
           not na(fiveAgoRevenue) and
           not na(sixAgoRevenue)

            revenue2QPrevious :=
                 pctChange(
                      previousRevenue +
                      twoAgoRevenue,
                      fiveAgoRevenue +
                      sixAgoRevenue)

        //==================================================
        // EPS VALUE COLOR
        //==================================================

        color epsValueColor =
             normalText

        if not na(currentEPS) and not na(previousEPS)

            if currentEPS > previousEPS
                epsValueColor := positiveText

            else if currentEPS < previousEPS
                epsValueColor := negativeText

        //==================================================
        // REVENUE VALUE COLOR
        //==================================================

        color revenueValueColor =
             normalText

        if not na(currentRevenue) and not na(previousRevenue)

            if currentRevenue > previousRevenue
                revenueValueColor := positiveText

            else if currentRevenue < previousRevenue
                revenueValueColor := negativeText

        //==================================================
        // TREND COLORS
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
        // TABLE CELLS
        //==================================================

        table.cell(
             tbl,
             0,
             i + 2,
             fmtDate(reportTime),
             bgcolor=cellBg,
             text_color=normalText)

        table.cell(
             tbl,
             1,
             i + 2,
             fmtEPS(currentEPS),
             bgcolor=cellBg,
             text_color=epsValueColor)

        table.cell(
             tbl,
             2,
             i + 2,
             fmtTrend(
                  epsQ,
                  previousEPSQ),
             bgcolor=cellBg,
             text_color=epsQColor)

        table.cell(
             tbl,
             3,
             i + 2,
             fmtArrow(
                  eps2QCurrent,
                  eps2QPrevious),
             bgcolor=cellBg,
             text_color=eps2QColor)

        table.cell(
             tbl,
             4,
             i + 2,
             fmtTrend(
                  epsY,
                  previousEPSY),
             bgcolor=cellBg,
             text_color=epsYColor)

        //==================================================
        // SEPARATOR
        //==================================================

        table.cell(
             tbl,
             5,
             i + 2,
             "",
             width=1,
             bgcolor=separatorBg)

        table.cell(
             tbl,
             6,
             i + 2,
             fmtRevenue(currentRevenue),
             bgcolor=cellBg,
             text_color=revenueValueColor)

        table.cell(
             tbl,
             7,
             i + 2,
             fmtTrend(
                  revenueQ,
                  previousRevenueQ),
             bgcolor=cellBg,
             text_color=revenueQColor)

        table.cell(
             tbl,
             8,
             i + 2,
             fmtArrow(
                  revenue2QCurrent,
                  revenue2QPrevious),
             bgcolor=cellBg,
             text_color=revenue2QColor)

        table.cell(
             tbl,
             9,
             i + 2,
             fmtTrend(
                  revenueY,
                  previousRevenueY),
             bgcolor=cellBg,
             text_color=revenueYColor)

//==================================================
// DEBUG DATA WINDOW
//==================================================

plot(
     array.size(epsValues),
     "Debug - EPS Reports Stored",
     display=display.data_window)

plot(
     array.size(revValues),
     "Debug - Revenue Reports Stored",
     display=display.data_window)
````
