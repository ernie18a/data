# FX Market Open Session Vertical Lines (JST)

- url: https://www.tradingview.com/script/6GYQBrsa/
- type: indicator
- pine_id: PUB;875e25a066714c3aac86813eab56dbaf
- version: 2.0

## Description

※English description is available below.

FX主要市場の開場時間に垂直線を表示するインジケーターです（JST基準）。

東京、豪州、英国、欧州、米国市場の開場時間に縦線を描画します。
ロンドンとニューヨークの夏時間（DST）は自動判定します。

【機能】
• 昨日 / 本日 / 明日 の表示切替
• 先週 / 今週 / 来週 の表示切替
• 東京 / 豪州 / 英国 / 欧州 / 米国市場の選択表示
• ロンドン・ニューヨークの夏時間自動判定
• 線の色・太さ・種類をカスタマイズ可能

【用途】
• 市場切り替わり前後の値動き確認
• エントリー時間の絞り込み
• 過去チャートの振り返り
• 市場ごとの相場の特徴確認

In English,

This indicator displays vertical lines for major FX market opening times (JST-based).

It draws vertical lines at the opening times of Tokyo, Australia, UK, Europe, and US market sessions.
Daylight Saving Time (DST) for London and New York is detected automatically.

[Features]
• Yesterday / Today / Tomorrow display options
• Last Week / This Week / Next Week display options
• Selectable Tokyo / Australia / UK / Europe / US sessions
• Automatic DST detection for London and New York
• Customizable line color, width, and style

[Use Cases]
• Analyze price action around market transitions
• Filter trading entry times
• Review historical charts
• Observe session-specific market behavior

## Source Code

````pine
//@version=6
indicator("FX Market Open Session Vertical Lines (JST)", overlay=true, max_lines_count=300)

// ===== 設定項目 =====
showYesterday = input.bool(false,"昨日", group="表示日時",inline="day")
showToday     = input.bool(true,"本日", group="表示日時",inline="day")
showTomorrow  = input.bool(true,"明日", group="表示日時",inline="day")
showLastWeek  = input.bool(false,"先週", group="表示日時",inline="week")
showThisWeek  = input.bool(true,"今週", group="表示日時",inline="week")
showNextWeek  = input.bool(false,"来週", group="表示日時",inline="week")

drawYesterday = showThisWeek ? false : showYesterday
drawToday = showThisWeek ? false : showToday
drawTomorrow = showThisWeek ? false : showTomorrow

// ===== 市場 =====
showTokyo=input.bool(
    true,
    "東京",
    group="市場",
    tooltip="9時"
)

showAustralia=input.bool(
    true,
    "豪州",
    group="市場",
    tooltip="10時"
)

showEarly=input.bool(
    true,
    "英国",
    group="市場",
    tooltip="夏15時 冬16時"
)

showLondon=input.bool(
    true,
    "欧州",
    group="市場",
    tooltip="夏16時 冬17時"
)

showNY=input.bool(
    true,
    "米国",
    group="市場",
    tooltip="夏21時 冬22時"
)

// ===== 線 =====
lineColor = input.color(
    color.new(color.gray,0),
    "色",
    group="線設定",
    inline="line"
)

lineWidth = input.int(
    1,
    "太さ",
    minval=1,
    maxval=5,
    group="線設定",
    inline="line"
)

lineType=input.string(
    "Dotted",
    "種類",
    options=["Solid","Dashed","Dotted"],
    group="線設定",
    inline="line"
)

lineStyle=switch lineType
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

// ===== 線保存 =====
var lines=array.new_line()

// ===== 現在日付 =====
nowJST = timenow

yy = year(nowJST, "Asia/Tokyo")
mm = month(nowJST, "Asia/Tokyo")
dd = dayofmonth(nowJST, "Asia/Tokyo")

weekday = dayofweek(nowJST, "Asia/Tokyo")
mondayOffset = -(weekday - dayofweek.monday)

// ===== 描画関数 =====
draw(sessionHour,offset)=>

    t=timestamp(
      "Asia/Tokyo",
      yy,
      mm,
      dd+offset,
      sessionHour,
      0
      )

    l=line.new(
      x1=t,
      y1=low,
      x2=t,
      y2=high,
      xloc=xloc.bar_time,
      extend=extend.both,
      width=lineWidth,
      style=lineStyle,
      color=lineColor
      )

    array.push(lines,l)

// ===== 夏時間の判定と開場時間 =====
isLondonDST = hour(time,"Europe/London") != hour(time,"UTC")
isNYDST = hour(time,"America/New_York") != hour(time,"UTC")

tokyo=9
australia=10
early = isLondonDST ? 15 : 16
london = isLondonDST ? 16 : 17
ny = isNYDST ? 21 : 22

// ===== 市場描画 =====
drawMarkets(offset)=>

    if showTokyo
        draw(tokyo,offset)

    if showAustralia
        draw(australia,offset)

    if showEarly
        draw(early,offset)

    if showLondon
        draw(london,offset)

    if showNY
        draw(ny,offset)

// ===== 最終バーだけ =====
if barstate.islast

    if array.size(lines)>0
        for i=0 to array.size(lines)-1
            line.delete(array.get(lines,i))

    array.clear(lines)

    if drawYesterday
        drawMarkets(-1)

    if drawToday
        drawMarkets(0)

    if drawTomorrow
        drawMarkets(1)

    if showLastWeek
        for d=-7+mondayOffset to -3+mondayOffset
            drawMarkets(d)

    if showThisWeek
        for d=mondayOffset to mondayOffset+4
            drawMarkets(d)

    if showNextWeek
        for d=7+mondayOffset to 11+mondayOffset
            drawMarkets(d)
````
