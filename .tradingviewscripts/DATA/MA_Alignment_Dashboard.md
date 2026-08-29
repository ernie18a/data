<!-- tradingview-pine-id: PUB;4f9a9c3599b84993adb90fc9026aeb7e -->
<!-- tradingviewscripts-format: 1 -->
# MA Alignment Dashboard

Source: https://www.tradingview.com/script/oMAqZwmU/

## Description

TradingView 퍼블리시 설명 — MA Alignment Dashboard

영어/한국어 버전 둘 다 만들었어.

영어 버전

MA Alignment Dashboard

A multi-moving-average dashboard that shows trend alignment, moving-average crossovers, and real-time execution speed at a glance.

What it does

This indicator tracks four moving averages (default 7 / 21 / 50 / 200) and displays how they are aligned relative to each other. Instead of reading four separate lines, you get a compact table showing whether each pair is bullish or bearish, so you can instantly judge the overall trend structure.

Features

Four customizable MAs — choose type (SMA, EMA, HMA, WMA, VWMA), length, color, and visibility for each
Alignment table — shows the relationship of each MA pair (7/21, 21/50, 50/200) with color-coded arrows: bullish, bearish, or neutral
Cross markers on the moving averages — marks golden/death crosses exactly at the crossover point on the line itself, not on the candle. Choose which pair to track (7/21, 21/50, 50/200, or all), the marker shape (8 options), size, and colors
Execution speed — a rate-based volume reading that measures how fast trades are flowing right now compared to the average, independent of how far the current candle has progressed. Displays as Fast / Normal / Slow with a multiplier
Flexible table placement — 8 positions on the chart
Alerts — golden cross, death cross, and execution-speed surge

How to use

When all pairs align in the same direction, the trend structure is strong and consistent
Cross markers highlight potential trend shifts at the exact price where the MAs meet
Execution speed helps confirm whether a move is backed by active trading or is just drifting
Combine the alignment table with the cross markers to filter which crosses occur in a supportive trend

Notes

Execution speed is meaningful only on the live (last) bar, since it measures the current candle's real-time flow
Use on any timeframe; slower MA pairs (50/200) suit trend trading, faster pairs (7/21) suit shorter-term entries

This indicator is for educational and informational purposes only and is not financial advice.

한국어 버전

MA Alignment Dashboard (이동평균 정렬 대시보드)

여러 이동평균의 정렬 상태, 크로스, 실시간 체결 속도를 한눈에 보여주는 대시보드입니다.

기능 개요

네 개의 이동평균(기본 7 / 21 / 50 / 200)이 서로 어떻게 정렬돼 있는지 표로 보여줍니다. 네 개의 선을 일일이 읽는 대신, 각 쌍이 정배열인지 역배열인지 색상으로 한눈에 파악해 전체 추세 구조를 즉시 판단할 수 있습니다.

주요 기능

이동평균 4개 커스터마이즈 — 종류(SMA, EMA, HMA, WMA, VWMA), 기간, 색상, 표시 여부를 각각 설정
정렬 테이블 — 각 이평 쌍(7/21, 21/50, 50/200)의 관계를 색상 화살표로 표시 (정배열/역배열/중립)
이평선 위 크로스 마커 — 골든/데드크로스를 캔들이 아니라 두 이평선이 실제로 만나는 교차 지점에 표시. 대상 쌍(7/21, 21/50, 50/200, 전체), 기호(8종), 크기, 색상 선택 가능
체결 속도 — 캔들 진행률과 무관하게 지금 이 순간의 체결 흐름이 평균 대비 얼마나 빠른지 측정. 빠름/보통/느림 + 배수로 표시
테이블 위치 8곳 선택
알림 — 골든크로스, 데드크로스, 체결 속도 급증

활용법

모든 쌍이 같은 방향으로 정렬되면 추세 구조가 강하고 일관됨
크로스 마커는 이평선이 만나는 정확한 가격에 추세 전환 가능성을 표시
체결 속도로 움직임이 활발한 거래에 기반한 것인지, 그냥 흘러가는 것인지 확인
정렬 테이블과 크로스 마커를 함께 보면 추세에 부합하는 크로스만 선별 가능

참고사항

체결 속도는 현재 캔들의 실시간 흐름을 측정하므로 마지막(실시간) 봉에서만 의미가 있습니다
모든 타임프레임에서 사용 가능하며, 느린 쌍(50/200)은 추세 매매, 빠른 쌍(7/21)은 단기 진입에 적합합니다

본 지표는 교육 및 정보 제공 목적이며 투자 조언이 아닙니다.

---

## Source Code

````pine
//@version=6
indicator("MA Alignment Dashboard", overlay=true, max_labels_count=500)

// ══════════════════ 이동평균 설정 ══════════════════
grpMA = "이동평균 설정"
maType = input.string("EMA", "MA 타입", options=["SMA","EMA","HMA","WMA","VWMA"], group=grpMA)

len1 = input.int(7,   "MA 1", minval=1, group=grpMA, inline="m1")
show1 = input.bool(true, "표시", group=grpMA, inline="m1")
col1 = input.color(#9db2bd, "색", group=grpMA, inline="m1")

len2 = input.int(21,  "MA 2", minval=1, group=grpMA, inline="m2")
show2 = input.bool(true, "표시", group=grpMA, inline="m2")
col2 = input.color(#a9bcc5, "색", group=grpMA, inline="m2")

len3 = input.int(50,  "MA 3", minval=1, group=grpMA, inline="m3")
show3 = input.bool(true, "표시", group=grpMA, inline="m3")
col3 = input.color(#88a0d0, "색", group=grpMA, inline="m3")

len4 = input.int(200, "MA 4", minval=1, group=grpMA, inline="m4")
show4 = input.bool(true, "표시", group=grpMA, inline="m4")
col4 = input.color(#e0e3eb, "색", group=grpMA, inline="m4")

masterMA = input.bool(true, "▶ 전체 이평선 표시", group=grpMA)

// ══════════════════ 크로스 표시 설정 ══════════════════
grpX = "크로스 표시"
showCross = input.bool(true, "크로스 마커 표시", group=grpX)
crossPair = input.string("50/200", "크로스 대상", options=["7/21","21/50","50/200","전체"], group=grpX)
crossShape = input.string("삼각형", "표시 기호", options=["삼각형","원","사각형","십자","다이아몬드","화살표","깃발","X표시"], group=grpX)
crossSize  = input.string("small", "기호 크기", options=["tiny","small","normal","large","huge"], group=grpX)
crossUpCol = input.color(#00E676, "골든크로스 색", group=grpX)
crossDnCol = input.color(#FF1744, "데드크로스 색", group=grpX)
showCrossText = input.bool(false, "크로스 글자 표시(GC/DC)", group=grpX)

// ══════════════════ 체결 속도 설정 ══════════════════
grpV = "체결 속도"
showVolSpeed = input.bool(true, "체결 속도 표시", group=grpV)
volMaLen = input.int(20, "거래량 평균 기간", minval=1, group=grpV)
volFastMult = input.float(2.0, "빠름 기준 (배수)", minval=1, step=0.1, group=grpV)

// ══════════════════ 표시 설정 ══════════════════
grpD = "표시 설정"
tablePos = input.string("top_right", "테이블 위치", options=["top_right","top_left","top_center","middle_right","middle_left","bottom_right","bottom_left","bottom_center"], group=grpD)
txtSize  = input.string("small", "글씨 크기", options=["tiny","small","normal","large"], group=grpD)
showTable = input.bool(true, "테이블 표시", group=grpD)

upColor   = input.color(#26a69a, "정배열 색상", group=grpD)
downColor = input.color(#ef5350, "역배열 색상", group=grpD)
mixColor  = input.color(#ffb74d, "혼조 색상", group=grpD)

// ══════════════════ 이동평균 계산 ══════════════════
ma(len) =>
    switch maType
        "SMA"  => ta.sma(close, len)
        "EMA"  => ta.ema(close, len)
        "HMA"  => ta.hma(close, len)
        "WMA"  => ta.wma(close, len)
        "VWMA" => ta.vwma(close, len)
        => ta.sma(close, len)

m1 = ma(len1)
m2 = ma(len2)
m3 = ma(len3)
m4 = ma(len4)

// ══════════════════ 정렬 판정 ══════════════════
p12 = m1 > m2
p23 = m2 > m3
p34 = m3 > m4
n12 = m1 < m2
n23 = m2 < m3
n34 = m3 < m4

perfectUp   = p12 and p23 and p34
perfectDown = n12 and n23 and n34

// ══════════════════ 체결 속도 계산 ══════════════════
tfSec = timeframe.in_seconds()
barElapsed = (timenow - time) / 1000.0
barElapsed := barElapsed <= 0 ? 1.0 : barElapsed
barElapsedMin = barElapsed / 60.0
barElapsedMin := barElapsedMin < (1.0/60.0) ? (1.0/60.0) : barElapsedMin

curSpeed = volume / barElapsedMin

tfMin = tfSec / 60.0
tfMin := tfMin < (1.0/60.0) ? (1.0/60.0) : tfMin
avgSpeed = ta.sma(volume, volMaLen) / tfMin

speedRatio = avgSpeed > 0 ? curSpeed / avgSpeed : 0
volState = speedRatio >= volFastMult ? "빠름" : speedRatio >= 1.0 ? "보통" : "느림"
volStateColor = speedRatio >= volFastMult ? upColor : speedRatio >= 1.0 ? mixColor : color.gray

// ══════════════════ 이평선 표시 ══════════════════
plot(masterMA and show1 ? m1 : na, "MA 1", color.new(col1, 0), 1)
plot(masterMA and show2 ? m2 : na, "MA 2", color.new(col2, 0), 1)
plot(masterMA and show3 ? m3 : na, "MA 3", color.new(col3, 0), 2)
plot(masterMA and show4 ? m4 : na, "MA 4", color.new(col4, 0), 2)

// ══════════════════ 크로스 감지 ══════════════════
gc12 = ta.crossover(m1, m2)
dc12 = ta.crossunder(m1, m2)
gc23 = ta.crossover(m2, m3)
dc23 = ta.crossunder(m2, m3)
gc34 = ta.crossover(m3, m4)
dc34 = ta.crossunder(m3, m4)

// ══════════════════ 크로스 마커 함수 ══════════════════
getCrossSize() =>
    switch crossSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

getSymbol(isUp) =>
    switch crossShape
        "삼각형"     => isUp ? "▲" : "▼"
        "원"         => "●"
        "사각형"     => "■"
        "십자"       => "✚"
        "다이아몬드" => "◆"
        "화살표"     => isUp ? "↑" : "↓"
        "깃발"       => "⚑"
        "X표시"      => "✖"
        => isUp ? "▲" : "▼"

// 크로스 마커 생성 (교차 지점 가격에 표시)
drawCross(isGold, price, pairLabel) =>
    sym = getSymbol(isGold)
    txt = showCrossText ? sym + " " + pairLabel : sym
    col = isGold ? crossUpCol : crossDnCol
    style = isGold ? label.style_label_up : label.style_label_down
    label.new(bar_index, price, txt, style=style, color=color.new(col, 20), textcolor=color.white, size=getCrossSize(), yloc=yloc.price)

// 대상별 크로스 표시
if showCross
    if crossPair == "7/21" or crossPair == "전체"
        if gc12
            drawCross(true,  m2, "7/21")
        if dc12
            drawCross(false, m2, "7/21")
    if crossPair == "21/50" or crossPair == "전체"
        if gc23
            drawCross(true,  m3, "21/50")
        if dc23
            drawCross(false, m3, "21/50")
    if crossPair == "50/200" or crossPair == "전체"
        if gc34
            drawCross(true,  m4, "50/200")
        if dc34
            drawCross(false, m4, "50/200")

// 알림용 통합 크로스 신호
anyGC = (crossPair=="7/21" ? gc12 : crossPair=="21/50" ? gc23 : crossPair=="50/200" ? gc34 : (gc12 or gc23 or gc34))
anyDC = (crossPair=="7/21" ? dc12 : crossPair=="21/50" ? dc23 : crossPair=="50/200" ? dc34 : (dc12 or dc23 or dc34))

// ══════════════════ 테이블 ══════════════════
getPos() =>
    switch tablePos
        "top_right"     => position.top_right
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "middle_right"  => position.middle_right
        "middle_left"   => position.middle_left
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.top_right

getTxt() =>
    switch txtSize
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        => size.normal

pairColor(isUp, isDown) =>
    isUp ? color.new(upColor, 20) : isDown ? color.new(downColor, 20) : color.new(color.gray, 55)

pairText(isUp, isDown) =>
    isUp ? "▲" : isDown ? "▼" : "―"

var table t = table.new(getPos(), 4, 2, border_width=1, frame_width=1, frame_color=color.new(color.gray, 60))

if barstate.islast and showTable
    hdrBg = color.new(color.gray, 45)
    txt = getTxt()

    table.cell(t, 0, 0, str.tostring(len1)+"/"+str.tostring(len2), bgcolor=hdrBg, text_color=color.white, text_size=txt, width=6)
    table.cell(t, 1, 0, str.tostring(len2)+"/"+str.tostring(len3), bgcolor=hdrBg, text_color=color.white, text_size=txt, width=6)
    table.cell(t, 2, 0, str.tostring(len3)+"/"+str.tostring(len4), bgcolor=hdrBg, text_color=color.white, text_size=txt, width=6)
    if showVolSpeed
        table.cell(t, 3, 0, "체결속도", bgcolor=hdrBg, text_color=color.white, text_size=txt, width=6)

    table.cell(t, 0, 1, pairText(p12,n12), bgcolor=pairColor(p12,n12), text_color=color.white, text_size=txt, width=6)
    table.cell(t, 1, 1, pairText(p23,n23), bgcolor=pairColor(p23,n23), text_color=color.white, text_size=txt, width=6)
    table.cell(t, 2, 1, pairText(p34,n34), bgcolor=pairColor(p34,n34), text_color=color.white, text_size=txt, width=6)
    if showVolSpeed
        volText = volState + " " + str.tostring(speedRatio, "#.#") + "x"
        table.cell(t, 3, 1, volText, bgcolor=color.new(volStateColor, 30), text_color=color.white, text_size=txt, width=6)

// ══════════════════ 알림 ══════════════════
alertcondition(anyGC, title="골든크로스", message="골든크로스 발생")
alertcondition(anyDC, title="데드크로스", message="데드크로스 발생")
alertcondition(showVolSpeed and speedRatio >= volFastMult, title="체결 속도 급증", message="체결 속도 평균 초과")
````
