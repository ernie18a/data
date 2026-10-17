# Wave Structure Projection Map

- url: https://www.tradingview.com/script/XsASDEZX-Wave-Structure-Projection-Map/
- type: indicator
- pine_id: PUB;a63026a8b2714a2eb4e2e5cdd7ed5407
- version: 1.0

## Description

Wave Structure Projection Map

Wave Structure Projection Map is a pivot-based structure analysis tool designed to organize swing highs, swing lows, ABC corrective structure, Fibonacci retracement levels, and forward projection guides into one visual framework.

The script is built to help users study how price forms swing structure, how pullbacks behave inside a broader move, where a possible C-point may develop, and where retracement or extension reference levels may become important.

It does not provide buy or sell recommendations. The purpose of this script is to help users analyze wave-like price structure, corrective movement, retracement behavior, and potential continuation or invalidation zones.

────────────────────
Core Concept
────────────────────

This script is based on the idea that market structure often moves in swings rather than in a straight line.

Price tends to form:

• impulsive moves
• corrective pullbacks
• retracement zones
• continuation or invalidation points

This script focuses on a practical swing-structure workflow rather than strict automatic Elliott Wave counting.

The main concept is:

1. Detect meaningful pivot highs and pivot lows
2. Build a ZigZag-style structure map
3. Evaluate whether the recent sequence resembles an ABC corrective structure
4. Measure the pullback using Fibonacci retracement logic
5. Project possible continuation paths and extension guides from the C-point

This approach helps users review whether a pullback is shallow, normal, deep, or structurally weak.

────────────────────
What This Script Shows / What It Detects
────────────────────

The script can display:

• swing highs and swing lows
• ZigZag structure lines
• ABC structure labeling
• Fibonacci retracement levels
• projected extension guides
• projection fan lines
• trend zone context
• continuation breakout / breakdown tags
• structure invalidation status
• pullback-zone context

These elements are intended to help users understand where the current structure stands and how recent swings connect with retracement and continuation behavior.

────────────────────
How It Works
────────────────────

1. The script detects pivot highs and pivot lows using the selected swing length.
2. It stores recent pivots and organizes them into a ZigZag-style structure map.
3. The latest three-pivot sequence is evaluated as a possible A-B-C corrective structure.
4. The BC leg is measured relative to the AB leg.
5. The retracement is filtered using minimum and maximum retracement settings.
6. Additional range and trend filters can be used to reduce weaker structures.
7. If the structure is valid, the script draws Fibonacci retracement levels based on the active swing.
8. Projection fan lines are drawn forward from the C-point to visualize possible continuation paths.
9. AB=CD, 1.272, and 1.618 style extension guides are also plotted as reference objectives.
10. If price breaks beyond the B-point with the selected ATR buffer, the script can classify the move as a continuation breakout or continuation breakdown.
11. If price violates the base structure, the script can label the setup as invalidated.

This allows the indicator to function as a structured pullback and continuation map rather than a simple swing marker.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• swing detection length
• pivot memory
• swing label count
• projection lookahead distance
• trend zone visibility
• ZigZag visibility
• pivot label visibility
• Fibonacci visibility
• projection fan visibility
• ABC label visibility
• structure tag visibility
• impulse extension guide visibility
• minimum and maximum retracement thresholds
• valid-bars-after-C limit
• range filter sensitivity
• ATR-based structure distance filter
• breakout ATR buffer
• optional trend-alignment requirement
• ATR and trend-factor settings
• zone width settings
• line, label, and projection colors

The default settings are intended to provide a balanced view of swing structure without forcing very small or overly noisy pivots into the map.

────────────────────
How To Use
────────────────────

This script is best used as a structure-analysis and projection-assistance tool.

General interpretation examples:

• A clear ABC structure can help users study whether the current move is a pullback inside a larger trend or the start of a deeper reversal.
• Fibonacci retracement levels can help users review whether the pullback is occurring in a commonly observed retracement zone.
• The C-point can be treated as a structural reference area, not as a guaranteed turning point.
• A continuation breakout tag can help users review whether price is moving beyond the corrective structure.
• A structure invalidation label can help users identify where the prior wave interpretation is no longer supported.
• Projection fan lines and extension guides can be used as forward reference paths, not as fixed price targets.

This script is best reviewed together with higher-timeframe structure, support and resistance, trend context, and price-action confirmation.

────────────────────
Confirmation And Repainting Notes
────────────────────

This script uses pivot highs and pivot lows.

Pivot-based structures require bars on both sides of the turning point before they become confirmed.

Because of that, swing labels and related structure lines are naturally confirmed after the pivot is formed.

The script does not use future price data to predict exact market direction, but the pivot-confirmation process means that structural labels appear only after the relevant swing is confirmed.

Users should understand that this is normal behavior for pivot-based structure tools.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

An ABC structure does not guarantee continuation or reversal.

A Fibonacci retracement level does not guarantee support or resistance.

Projection fan lines and extension levels are forward reference tools, not promises of future path or target completion.

In highly volatile or choppy conditions, price structure may become noisy and less reliable.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Wave Structure Projection Map

Wave Structure Projection Map는 pivot 기반 구조 분석 도구로, 스윙 고점과 저점, ABC 보정 구조, Fibonacci 되돌림 레벨, 그리고 전방 투영 가이드를 하나의 시각적 프레임워크 안에서 정리하도록 설계된 보조지표입니다.

이 스크립트는 가격이 어떤 스윙 구조를 만들고 있는지, 더 큰 움직임 안에서 눌림이 어떻게 진행되는지, 잠재적인 C포인트가 어디에서 형성되는지, 그리고 어떤 되돌림 또는 확장 레벨이 중요해질 수 있는지를 분석하는 데 도움을 주기 위해 만들어졌습니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다. 목적은 파동형 가격 구조, 보정 움직임, 되돌림 행동, 그리고 잠재적인 지속 또는 무효화 구간을 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

이 스크립트는 시장 구조가 직선으로 움직이기보다 스윙 단위로 전개되는 경우가 많다는 개념을 바탕으로 합니다.

가격은 보통 다음과 같은 구조를 만듭니다.

• 추세성 진행 구간
• 보정성 눌림 구간
• 되돌림 구간
• 지속 또는 무효화 구간

이 스크립트는 정통 자동 Elliott Wave 카운팅보다는, 실전에서 활용하기 쉬운 스윙 구조 해석 흐름에 초점을 둡니다.

핵심 흐름은 다음과 같습니다.

1. 의미 있는 pivot high / low 감지
2. ZigZag 스타일 구조 형성
3. 최근 시퀀스가 ABC 보정 구조에 가까운지 평가
4. AB 대비 BC의 되돌림 비율 측정
5. C포인트 이후의 잠재적 진행 경로와 확장 가이드 투영

이 접근법은 현재 눌림이 얕은지, 정상적인지, 깊은지, 구조적으로 약한지를 검토하는 데 도움이 됩니다.

────────────────────
이 스크립트가 보여주는 것 / 감지하는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 스윙 고점과 스윙 저점
• ZigZag 구조 라인
• ABC 구조 라벨
• Fibonacci 되돌림 레벨
• 전방 확장 가이드
• Projection fan 라인
• Trend zone 컨텍스트
• continuation breakout / breakdown 태그
• structure invalidation 상태
• pullback-zone 컨텍스트

이 요소들은 현재 구조가 어떤 단계에 있는지, 최근 스윙이 되돌림과 지속 구조와 어떻게 연결되는지를 이해하는 데 도움을 주기 위한 시각적 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 선택한 swing length를 기준으로 pivot high와 pivot low를 감지합니다.
2. 최근 pivot들을 저장하고 ZigZag 스타일 구조 맵으로 정리합니다.
3. 최신 3개 pivot 시퀀스를 잠재적 A-B-C 보정 구조로 평가합니다.
4. BC 구간을 AB 구간 대비 얼마나 되돌렸는지 측정합니다.
5. 최소 및 최대 retracement 기준으로 구조를 필터링합니다.
6. 추가적인 range 필터와 trend 필터로 약한 구조를 줄일 수 있습니다.
7. 구조가 유효하면, 활성 스윙 기준으로 Fibonacci 되돌림 레벨을 그립니다.
8. C포인트 이후에는 projection fan 라인을 앞으로 연장해 잠재적 진행 경로를 시각화합니다.
9. AB=CD, 1.272, 1.618 형태의 확장 가이드도 참고용으로 함께 표시합니다.
10. 가격이 선택된 ATR buffer를 포함해 B포인트를 돌파하면 continuation breakout 또는 continuation breakdown으로 분류할 수 있습니다.
11. 가격이 기본 구조를 무너뜨리면 setup invalidated 상태로 표시할 수 있습니다.

즉, 이 지표는 단순한 스윙 마커가 아니라 구조화된 눌림 및 지속 맵으로 작동하도록 설계되었습니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• swing detection length
• pivot memory
• swing label count
• projection lookahead distance
• trend zone visibility
• ZigZag visibility
• pivot label visibility
• Fibonacci visibility
• projection fan visibility
• ABC label visibility
• structure tag visibility
• impulse extension guide visibility
• minimum and maximum retracement thresholds
• valid-bars-after-C limit
• range filter sensitivity
• ATR 기반 구조 거리 필터
• breakout ATR buffer
• optional trend-alignment requirement
• ATR 및 trend-factor settings
• zone width settings
• line, label, and projection colors

기본 설정은 너무 작은 pivot이나 과도한 노이즈를 억지로 구조에 포함시키지 않으면서, 균형 잡힌 스윙 구조를 보여주도록 설계되어 있습니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 구조 분석 및 projection 보조 도구로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• 명확한 ABC 구조는 현재 움직임이 큰 추세 안의 눌림인지, 아니면 더 깊은 반전의 시작인지 검토하는 데 도움이 될 수 있습니다.
• Fibonacci 되돌림 레벨은 현재 눌림이 자주 관찰되는 되돌림 구간에서 진행되고 있는지 확인하는 데 사용할 수 있습니다.
• C포인트는 확정적인 반전점이 아니라 구조적 기준점으로 해석하는 것이 적절합니다.
• continuation breakout 태그는 가격이 보정 구조를 넘어 다시 진행하는지 검토하는 데 사용할 수 있습니다.
• structure invalidation 라벨은 기존 구조 해석이 더 이상 유효하지 않은 위치를 확인하는 데 도움을 줄 수 있습니다.
• projection fan 라인과 extension 가이드는 미래 경로에 대한 참고선이지, 고정된 목표가가 아닙니다.

이 스크립트는 상위 시간대 구조, 지지와 저항, 추세 컨텍스트, 가격 행동 확인과 함께 보는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 pivot high와 pivot low를 사용합니다.

Pivot 기반 구조는 전환점 양쪽에 일정 수의 봉이 형성되어야 확정됩니다.

따라서 스윙 라벨과 관련 구조선은 해당 pivot이 확인된 뒤에 자연스럽게 표시됩니다.

이 스크립트는 미래 가격 데이터를 사용해 방향을 예측하지 않지만, pivot 확정 과정 자체 때문에 구조 라벨은 관련 스윙이 확인된 뒤에만 나타납니다.

이는 pivot 기반 구조 지표에서 정상적인 동작입니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

ABC 구조가 나타났다고 해서 반드시 추세 지속이나 반전을 보장하지는 않습니다.

Fibonacci 되돌림 레벨이 반드시 지지나 저항으로 작동하는 것은 아닙니다.

Projection fan 라인과 extension 레벨은 참고용 전방 가이드일 뿐, 실제 경로나 목표 달성을 보장하지 않습니다.

변동성이 매우 크거나 횡보가 심한 구간에서는 구조가 노이즈처럼 보일 수 있으며 신뢰도가 낮아질 수 있습니다.

이 스크립트를 단독 매매 시스템으로 사용해서는 안 됩니다.

────────────────────
중요 고지
────────────────────

본 게시물은 교육 및 정보 제공 목적의 차트 분석 자료입니다.

투자 자문, 매수·매도 추천, 특정 금융상품 거래 권유를 의미하지 않습니다.

모든 투자 판단과 그 결과에 대한 책임은 이용자 본인에게 있습니다.

## Source Code

````pine
//@version=6
indicator("Wave Structure Projection Map", shorttitle="WaveMap", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50, max_bars_back=5000)

groupCore = "Core Structure"
pivotLen = input.int(12, "Swing Detection Length", minval=2, maxval=100, group=groupCore)
maxPivotMemory = input.int(40, "Pivot Memory", minval=8, maxval=100, group=groupCore)
pivotLabelCount = input.int(14, "Swing Label Count", minval=3, maxval=40, group=groupCore)
rightBars = input.int(90, "Right Projection Bars", minval=20, maxval=300, group=groupCore)
labelRightBars = input.int(18, "Right Label Offset", minval=3, maxval=100, group=groupCore)

groupShow = "Display"
showTrendZone = input.bool(true, "Trend Zone", group=groupShow)
showZigZag = input.bool(true, "ZigZag Structure", group=groupShow)
showPivotLabels = input.bool(true, "Swing Price Labels", group=groupShow)
showFib = input.bool(true, "Fibonacci Levels", group=groupShow)
showFan = input.bool(true, "Projection Fan", group=groupShow)
showABC = input.bool(true, "ABC Structure Labels", group=groupShow)
showSignalTag = input.bool(true, "Current Structure Tag", group=groupShow)
showImpulseGuide = input.bool(true, "Impulse Extension Guide", group=groupShow)

groupFilter = "Structure Filter"
minRetrace = input.float(0.236, "Minimum BC / AB Retracement", minval=0.05, maxval=1.5, step=0.001, group=groupFilter)
maxRetrace = input.float(0.886, "Maximum BC / AB Retracement", minval=0.1, maxval=2.0, step=0.001, group=groupFilter)
abcMaxBarsAfterC = input.int(60, "ABC Valid Bars After C", minval=5, maxval=150, group=groupFilter)
rangeLookback = input.int(20, "Range Filter Lookback", minval=5, maxval=100, group=groupFilter)
minRangeAtr = input.float(1.10, "Minimum Range ATR", minval=0.1, maxval=5.0, step=0.05, group=groupFilter)
pivotMinAtr = input.float(1.00, "Swing Minimum Distance ATR", minval=0.0, maxval=5.0, step=0.05, group=groupFilter)
breakoutAtrBuffer = input.float(0.15, "Breakout ATR Buffer", minval=0.0, maxval=2.0, step=0.01, group=groupFilter)
requireTrendAlignment = input.bool(false, "Require Trend Alignment", group=groupFilter)

groupTrend = "Trend Zone"
atrPeriod = input.int(10, "ATR Length", minval=1, maxval=100, group=groupTrend)
trendFactor = input.float(3.0, "Trend Factor", minval=0.1, maxval=20.0, step=0.1, group=groupTrend)
zoneAtrMult = input.float(1.25, "Zone Width ATR", minval=0.1, maxval=5.0, step=0.05, group=groupTrend)

groupStyle = "Style"
colUp = input.color(color.rgb(32, 220, 145), "Bull Color", group=groupStyle)
colDown = input.color(color.rgb(255, 76, 90), "Bear Color", group=groupStyle)
colFib = input.color(color.rgb(188, 70, 255), "Fibonacci Color", group=groupStyle)
colFan1 = input.color(color.rgb(255, 170, 20), "Fast Projection Color", group=groupStyle)
colFan2 = input.color(color.rgb(230, 210, 40), "Mid Projection Color", group=groupStyle)
colFan3 = input.color(color.rgb(60, 190, 90), "Slow Projection Color", group=groupStyle)
colZone = input.color(color.rgb(105, 165, 255), "Pullback Zone Color", group=groupStyle)
colNeutral = input.color(color.rgb(210, 215, 225), "Neutral Text Color", group=groupStyle)
labelSizeOpt = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=groupStyle)

atrVal = ta.atr(14)
labelGap = math.max(atrVal * 1.18, syminfo.mintick * 20)
breakGap = atrVal * breakoutAtrBuffer

f_labelSize() =>
    labelSizeOpt == "Tiny" ? size.tiny : labelSizeOpt == "Normal" ? size.normal : size.small

f_clearLines(arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

f_clearLabels(arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

f_clearFills(arr) =>
    while array.size(arr) > 0
        linefill.delete(array.pop(arr))

f_fmt(v) =>
    str.tostring(v, format.mintick)

f_newLine(arr, x1, y1, x2, y2, lineCol, lineStyle, lineWidth) =>
    ln = line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, extend=extend.none, color=lineCol, style=lineStyle, width=lineWidth)
    array.push(arr, ln)
    ln

f_newText(arr, x, y, txt, txtCol) =>
    lb = label.new(x=x, y=y, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=txtCol, size=f_labelSize())
    array.push(arr, lb)
    lb

f_newTextNormal(arr, x, y, txt, txtCol) =>
    lb = label.new(x=x, y=y, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=txtCol, size=size.normal)
    array.push(arr, lb)
    lb

f_newSoftTag(arr, x, y, txt, txtCol, bgCol) =>
    lb = label.new(x=x, y=y, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(bgCol, 82), textcolor=txtCol, size=size.normal)
    array.push(arr, lb)
    lb

[stLine, stDir] = ta.supertrend(trendFactor, atrPeriod)
trendAtr = ta.atr(atrPeriod)

midBody = plot((open + close) / 2.0, display=display.none)
upTrendPlot = plot(showTrendZone and stDir < 0 ? stLine : na, "Trend Support", color=color.new(colUp, 15), style=plot.style_linebr, linewidth=1)
downTrendPlot = plot(showTrendZone and stDir > 0 ? stLine : na, "Trend Resistance", color=color.new(colDown, 15), style=plot.style_linebr, linewidth=1)

upperZone = stLine + trendAtr * zoneAtrMult
lowerZone = stLine - trendAtr * zoneAtrMult

upZonePlot = plot(showTrendZone and stDir < 0 ? lowerZone : na, "Bull Zone Edge", color=color.new(colUp, 78), style=plot.style_linebr)
downZonePlot = plot(showTrendZone and stDir > 0 ? upperZone : na, "Bear Zone Edge", color=color.new(colDown, 78), style=plot.style_linebr)

fill(midBody, upTrendPlot, color=showTrendZone ? color.new(colUp, 92) : na, fillgaps=false)
fill(midBody, downTrendPlot, color=showTrendZone ? color.new(colDown, 92) : na, fillgaps=false)
fill(upTrendPlot, upZonePlot, color=showTrendZone ? color.new(colUp, 96) : na, fillgaps=false)
fill(downTrendPlot, downZonePlot, color=showTrendZone ? color.new(colDown, 96) : na, fillgaps=false)

var pivotBars = array.new_int()
var pivotPrices = array.new_float()
var pivotKinds = array.new_int()

var zigzagLines = array.new_line()
var fibLines = array.new_line()
var fanLines = array.new_line()
var guideLines = array.new_line()

var pivotLabels = array.new_label()
var fibLabels = array.new_label()
var fanLabels = array.new_label()
var abcLabels = array.new_label()
var setupLabels = array.new_label()

var fanFills = array.new_linefill()

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

f_addPivot(pBar, pPrice, pKind) =>
    n = array.size(pivotPrices)
    if n == 0
        array.push(pivotBars, pBar)
        array.push(pivotPrices, pPrice)
        array.push(pivotKinds, pKind)
    else
        lastKind = array.get(pivotKinds, n - 1)
        lastPrice = array.get(pivotPrices, n - 1)
        sameKind = lastKind == pKind
        replaceHigh = sameKind and pKind == 1 and pPrice > lastPrice
        replaceLow = sameKind and pKind == -1 and pPrice < lastPrice
        if replaceHigh or replaceLow
            array.set(pivotBars, n - 1, pBar)
            array.set(pivotPrices, n - 1, pPrice)
            array.set(pivotKinds, n - 1, pKind)
        else if not sameKind
            moveOk = math.abs(pPrice - lastPrice) >= atrVal * pivotMinAtr
            if moveOk
                array.push(pivotBars, pBar)
                array.push(pivotPrices, pPrice)
                array.push(pivotKinds, pKind)
    while array.size(pivotPrices) > maxPivotMemory
        array.shift(pivotBars)
        array.shift(pivotPrices)
        array.shift(pivotKinds)

if not na(ph)
    f_addPivot(bar_index - pivotLen, ph, 1)

if not na(pl)
    f_addPivot(bar_index - pivotLen, pl, -1)

pivotCount = array.size(pivotPrices)

has2 = pivotCount >= 2
has3 = pivotCount >= 3
has5 = pivotCount >= 5

x0 = has2 ? array.get(pivotBars, pivotCount - 2) : na
y0 = has2 ? array.get(pivotPrices, pivotCount - 2) : na

x1 = has2 ? array.get(pivotBars, pivotCount - 1) : na
y1 = has2 ? array.get(pivotPrices, pivotCount - 1) : na

xA = has3 ? array.get(pivotBars, pivotCount - 3) : na
yA = has3 ? array.get(pivotPrices, pivotCount - 3) : na
kA = has3 ? array.get(pivotKinds, pivotCount - 3) : na

xB = has3 ? array.get(pivotBars, pivotCount - 2) : na
yB = has3 ? array.get(pivotPrices, pivotCount - 2) : na
kB = has3 ? array.get(pivotKinds, pivotCount - 2) : na

xC = has3 ? array.get(pivotBars, pivotCount - 1) : na
yC = has3 ? array.get(pivotPrices, pivotCount - 1) : na
kC = has3 ? array.get(pivotKinds, pivotCount - 1) : na

moveAB = has3 ? math.abs(yB - yA) : na
retraceBC = has3 and moveAB > 0 ? math.abs(yC - yB) / moveAB : na

isLongABC = has3 and kA == -1 and kB == 1 and kC == -1 and yC > yA and yC < yB
isShortABC = has3 and kA == 1 and kB == -1 and kC == 1 and yC < yA and yC > yB
validRetrace = has3 and retraceBC >= minRetrace and retraceBC <= maxRetrace

barsSinceC = has3 ? bar_index - xC : na
abcFresh = has3 and barsSinceC <= abcMaxBarsAfterC

rangeNow = ta.highest(high, rangeLookback) - ta.lowest(low, rangeLookback)
rangeAlive = rangeNow >= atrVal * minRangeAtr

trendLongOk = not requireTrendAlignment or stDir < 0
trendShortOk = not requireTrendAlignment or stDir > 0

abcLongRaw = isLongABC and validRetrace
abcShortRaw = isShortABC and validRetrace

abcLongInvalid = abcLongRaw and close < yA
abcShortInvalid = abcShortRaw and close > yA

abcLong = abcLongRaw and abcFresh and rangeAlive and trendLongOk and not abcLongInvalid
abcShort = abcShortRaw and abcFresh and rangeAlive and trendShortOk and not abcShortInvalid

abcLongBreak = abcLong and close > yB + breakGap
abcShortBreak = abcShort and close < yB - breakGap

activeABC = abcLong or abcShort
inPullbackZone = activeABC and not abcLongBreak and not abcShortBreak

if barstate.islast
    f_clearLines(zigzagLines)
    f_clearLines(fibLines)
    f_clearLines(fanLines)
    f_clearLines(guideLines)
    f_clearLabels(pivotLabels)
    f_clearLabels(fibLabels)
    f_clearLabels(fanLabels)
    f_clearLabels(abcLabels)
    f_clearLabels(setupLabels)
    f_clearFills(fanFills)

if barstate.islast and showZigZag and pivotCount >= 2
    startDraw = math.max(1, pivotCount - 14)
    for i = startDraw to pivotCount - 1
        zx1 = array.get(pivotBars, i - 1)
        zy1 = array.get(pivotPrices, i - 1)
        zx2 = array.get(pivotBars, i)
        zy2 = array.get(pivotPrices, i)
        zzCol = zy2 >= zy1 ? color.new(colUp, 5) : color.new(colDown, 5)
        f_newLine(zigzagLines, zx1, zy1, zx2, zy2, zzCol, line.style_solid, 2)

if barstate.islast and showPivotLabels and pivotCount > 0
    labelStart = math.max(0, pivotCount - pivotLabelCount)
    for i = labelStart to pivotCount - 1
        px = array.get(pivotBars, i)
        py = array.get(pivotPrices, i)
        pk = array.get(pivotKinds, i)
        isHigh = pk == 1
        pTxt = isHigh ? "SH\n" + f_fmt(py) + "\n▼" : "▲\nSL\n" + f_fmt(py)
        pY = isHigh ? py + labelGap * 1.85 : py - labelGap * 1.85
        pCol = isHigh ? colDown : colUp
        f_newText(pivotLabels, px, pY, pTxt, pCol)

if barstate.islast and showFib and has2
    fibLeft = x0
    fibRight = bar_index + rightBars
    fibLabelX = bar_index + labelRightBars + 46

    swingLow = math.min(y0, y1)
    swingHigh = math.max(y0, y1)
    swingRange = swingHigh - swingLow
    trendUpSwing = y1 > y0

    level0 = trendUpSwing ? swingLow : swingHigh
    level236 = trendUpSwing ? swingLow + swingRange * 0.236 : swingHigh - swingRange * 0.236
    level382 = trendUpSwing ? swingLow + swingRange * 0.382 : swingHigh - swingRange * 0.382
    level500 = trendUpSwing ? swingLow + swingRange * 0.5 : swingHigh - swingRange * 0.5
    level618 = trendUpSwing ? swingLow + swingRange * 0.618 : swingHigh - swingRange * 0.618
    level786 = trendUpSwing ? swingLow + swingRange * 0.786 : swingHigh - swingRange * 0.786
    level886 = trendUpSwing ? swingLow + swingRange * 0.886 : swingHigh - swingRange * 0.886
    level100 = trendUpSwing ? swingHigh : swingLow
    level1272 = trendUpSwing ? swingLow + swingRange * 1.272 : swingHigh - swingRange * 1.272
    level1618 = trendUpSwing ? swingLow + swingRange * 1.618 : swingHigh - swingRange * 1.618

    f_newLine(fibLines, fibLeft, level0, fibRight, level0, color.new(colFib, 35), line.style_solid, 1)
    f_newLine(fibLines, fibLeft, level236, fibRight, level236, color.new(colFib, 58), line.style_dotted, 1)
    f_newLine(fibLines, fibLeft, level382, fibRight, level382, color.new(colFib, 45), line.style_solid, 1)
    f_newLine(fibLines, fibLeft, level500, fibRight, level500, color.new(colFib, 65), line.style_dashed, 1)
    f_newLine(fibLines, fibLeft, level618, fibRight, level618, color.new(colFib, 25), line.style_solid, 2)
    f_newLine(fibLines, fibLeft, level786, fibRight, level786, color.new(colFib, 45), line.style_solid, 1)
    f_newLine(fibLines, fibLeft, level886, fibRight, level886, color.new(colFib, 55), line.style_dotted, 1)
    f_newLine(fibLines, fibLeft, level100, fibRight, level100, color.new(colFib, 35), line.style_solid, 1)
    f_newLine(fibLines, fibLeft, level1272, fibRight, level1272, color.new(colFib, 55), line.style_dashed, 1)
    f_newLine(fibLines, fibLeft, level1618, fibRight, level1618, color.new(colFib, 30), line.style_solid, 1)

    f_newTextNormal(fibLabels, fibLabelX, level0, "0 (" + f_fmt(level0) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level236, "0.236 (" + f_fmt(level236) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level382, "0.382 (" + f_fmt(level382) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level500, "0.5 (" + f_fmt(level500) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level618, "0.618 (" + f_fmt(level618) + ")", colFib)
    f_newTextNormal(fibLabels, fibLabelX, level786, "0.786 (" + f_fmt(level786) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level886, "0.886 (" + f_fmt(level886) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level100, "1 (" + f_fmt(level100) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level1272, "1.272 (" + f_fmt(level1272) + ")", colNeutral)
    f_newTextNormal(fibLabels, fibLabelX, level1618, "1.618 (" + f_fmt(level1618) + ")", colFib)

if barstate.islast and showFan and activeABC
    fanStartX = xC
    fanStartY = yC
    fanEndX = bar_index + rightBars
    projectedBars = math.max(1, fanEndX - fanStartX)
    abBars = math.max(1, xB - xA)
    abMove = math.abs(yB - yA)
    baseSlopeAbs = abMove / abBars
    fanDirection = abcLong ? 1.0 : -1.0

    fanFastY = fanStartY + baseSlopeAbs * projectedBars * 1.0 * fanDirection
    fanMidY = fanStartY + baseSlopeAbs * projectedBars * 0.618 * fanDirection
    fanSlowY = fanStartY + baseSlopeAbs * projectedBars * 0.382 * fanDirection
    fanDeepY = fanStartY + baseSlopeAbs * projectedBars * 0.236 * fanDirection

    fastLine = f_newLine(fanLines, fanStartX, fanStartY, fanEndX, fanFastY, color.new(colFan1, 68), line.style_solid, 1)
    midLine = f_newLine(fanLines, fanStartX, fanStartY, fanEndX, fanMidY, color.new(colFan2, 34), line.style_solid, 1)
    slowLine = f_newLine(fanLines, fanStartX, fanStartY, fanEndX, fanSlowY, color.new(colFan3, 34), line.style_solid, 1)
    deepLine = f_newLine(fanLines, fanStartX, fanStartY, fanEndX, fanDeepY, color.new(colNeutral, 55), line.style_dashed, 1)

    array.push(fanFills, linefill.new(fastLine, midLine, color.new(colFan1, 97)))
    array.push(fanFills, linefill.new(midLine, slowLine, color.new(colFan2, 96)))
    array.push(fanFills, linefill.new(slowLine, deepLine, color.new(colFan3, 97)))

    fanLabelX = fanEndX + 4
    f_newText(fanLabels, fanLabelX, fanFastY + atrVal * 0.35 * fanDirection, "1/1", color.new(colFan1, 25))
    f_newText(fanLabels, fanLabelX, fanMidY + atrVal * 0.22 * fanDirection, "0.618", colFan2)
    f_newText(fanLabels, fanLabelX, fanSlowY + atrVal * 0.10 * fanDirection, "0.382", colFan3)
    f_newText(fanLabels, fanLabelX, fanDeepY - atrVal * 0.05 * fanDirection, "0.236", colNeutral)

if barstate.islast and showImpulseGuide and activeABC
    impulseDir = abcLong ? 1.0 : -1.0
    abMoveAbs = math.abs(yB - yA)
    target100 = yC + abMoveAbs * impulseDir
    target1272 = yC + abMoveAbs * 1.272 * impulseDir
    target1618 = yC + abMoveAbs * 1.618 * impulseDir
    guideX1 = xC
    guideX2 = bar_index + rightBars
    guideLabelX = bar_index + labelRightBars + 12

    f_newLine(guideLines, guideX1, target100, guideX2, target100, color.new(colFan1, 40), line.style_dashed, 1)
    f_newLine(guideLines, guideX1, target1272, guideX2, target1272, color.new(colFan2, 45), line.style_dotted, 1)
    f_newLine(guideLines, guideX1, target1618, guideX2, target1618, color.new(colFan1, 10), line.style_solid, 2)

    f_newTextNormal(fanLabels, guideLabelX, target100, "AB=CD 1.0", colFan1)
    f_newTextNormal(fanLabels, guideLabelX, target1272, "Ext 1.272", colNeutral)
    f_newTextNormal(fanLabels, guideLabelX, target1618, "Ext 1.618", colFan1)

if barstate.islast and showABC and activeABC
    abcCol = abcLong ? colUp : colDown
    cCol = colFan1

    aY = kA == 1 ? yA + labelGap * 2.5 : yA - labelGap * 2.5
    bY = kB == 1 ? yB + labelGap * 2.5 : yB - labelGap * 2.5
    cY = kC == 1 ? yC + labelGap * 5.0 : yC - labelGap * 5.0
    cX = xC + 12

    aTxt = kA == 1 ? "A\n▼" : "▲\nA"
    bTxt = kB == 1 ? "B\n▼" : "▲\nB"
    cTxt = kC == 1 ? "C\nR " + str.tostring(retraceBC, "#.###") + "\n▼" : "▲\nC\nR " + str.tostring(retraceBC, "#.###")

    f_newText(abcLabels, xA, aY, aTxt, abcCol)
    f_newText(abcLabels, xB, bY, bTxt, abcCol)
    f_newTextNormal(abcLabels, cX, cY, cTxt, cCol)

if barstate.islast and showSignalTag and has3
    setupText = "WAIT"
    setupCol = colNeutral
    tagX = bar_index + labelRightBars + 22
    tagY = close + atrVal * 7.5

    if abcLongInvalid or abcShortInvalid
        setupText := "STRUCTURE INVALIDATED"
        setupCol := colNeutral
        tagX := xA
        tagY := kA == 1 ? yA + labelGap * 3.4 : yA - labelGap * 3.4
    else if abcLongBreak
        setupText := "▲ CONTINUATION BREAKOUT"
        setupCol := colFan1
    else if abcShortBreak
        setupText := "CONTINUATION BREAKDOWN ▼"
        setupCol := colFan1
    else if abcLong
        setupText := "▲ ABC RECOVERY SETUP"
        setupCol := colUp
    else if abcShort
        setupText := "ABC REJECTION SETUP ▼"
        setupCol := colDown
    else if inPullbackZone
        setupText := "PULLBACK ZONE"
        setupCol := colZone
        tagX := bar_index + labelRightBars + 30
        tagY := close + atrVal * 8.6

    if inPullbackZone
        f_newSoftTag(setupLabels, tagX, tagY, setupText, setupCol, colZone)
    else
        f_newTextNormal(setupLabels, tagX, tagY, setupText, setupCol)

alertcondition(abcLong, title="ABC Recovery Setup", message="ABC recovery setup detected.")
alertcondition(abcShort, title="ABC Rejection Setup", message="ABC rejection setup detected.")
alertcondition(abcLongBreak, title="Continuation Breakout", message="ABC structure continuation breakout detected.")
alertcondition(abcShortBreak, title="Continuation Breakdown", message="ABC structure continuation breakdown detected.")
alertcondition(abcLongInvalid or abcShortInvalid, title="Structure Invalidated", message="Wave structure invalidated.")
````
