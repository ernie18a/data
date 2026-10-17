# Market Structure Scanner

- url: https://www.tradingview.com/script/uZkfuRSd-Market-Structure-Scanner/
- type: indicator
- pine_id: PUB;69dd30b0743f4fda97c394430484ec80
- version: 1.0

## Description

Market Structure Scanner

Market Structure Scanner is a pivot-based chart study designed to visualize market structure using upper and lower structure rails.

The script focuses on how price is forming structure over time. It does not attempt to predict future price movement or provide buy and sell recommendations. Its purpose is to help users study channels, ranges, compression phases, directional pressure, and expansion behavior directly on the chart.

────────────────────
Core Concept
────────────────────

The script uses confirmed swing pivots to build a simplified view of market structure.

Instead of labeling every candle movement, it looks for a sequence of alternating pivot highs and pivot lows. From these pivots, the script builds two reference rails:

• Upper rail from pivot highs
• Lower rail from pivot lows

The relationship between these two rails is then evaluated.

The script checks whether the rails are:

• Rising together
• Falling together
• Moving in a relatively parallel structure
• Compressing toward each other
• Expanding away from each other
• Forming a balance or range area

This allows the chart to be viewed as a structural environment rather than a collection of isolated candles.

────────────────────
What This Script Detects
────────────────────

The scanner can identify several structure conditions, including:

• Trend Channel · Up
• Trend Channel · Down
• Balance Range
• Ascending Pressure
• Descending Pressure
• Symmetric Compression
• Volatility Expansion

These labels are structural descriptions only. They are not trade signals.

────────────────────
How It Works
────────────────────

1. The script detects confirmed pivot highs and pivot lows.
2. It stores recent pivots and keeps only alternating swing points.
3. It uses the latest five pivot points to build upper and lower structure rails.
4. It measures rail slope, flatness, distance change, compression, expansion, and fit error.
5. It applies ATR-based height filtering to avoid weak or insignificant structures.
6. It applies a quality score to reduce noisy or low-quality structures.
7. It avoids drawing duplicate structures that are too close in time and price.
8. When a structure passes the filters, it draws rails, zones, nodes, labels, and a status panel.

────────────────────
Visual Elements
────────────────────

The script can display:

• Upper structure rail
• Lower structure rail
• Structure zone
• Structure nodes
• Optional internal pivot links
• Optional pivot numbers
• Structure label
• Latest structure status panel

The status panel shows the latest detected structure type, structure mode, quality grade, upper rail, lower rail, and structure width.

────────────────────
Inputs And Customization
────────────────────

Main settings include:

Pivot left strength:
Controls how many bars are required on the left side of a pivot.

Pivot right confirmation bars:
Controls how many bars are required after a pivot before it is confirmed.

Minimum pivot deviation:
Filters small pivot changes that may create noisy structures.

Minimum structure quality:
Controls how selective the scanner is.

Minimum structure width:
Requires a structure to cover a minimum number of bars.

Minimum structure height × ATR:
Filters structures that are too small relative to recent volatility.

Maximum rail fit error:
Controls how closely pivots must fit their corresponding structure rails.

Compression and expansion ratios:
Control how strongly the upper and lower rails must contract or expand.

────────────────────
Confirmation And Repainting Notes
────────────────────

This script uses pivot confirmation.

A pivot can only be confirmed after the required number of right-side confirmation bars has completed. Because of this, detected structures may appear after the actual pivot point.

Lower right-confirmation settings can make the scanner respond faster, but they may also increase sensitivity.

Higher right-confirmation settings can make the scanner more stable, but structures may appear later.

The script is intended as a confirmed structure scanner, not a real-time prediction engine.

────────────────────
How To Use
────────────────────

Use this script as a market structure study.

General interpretation examples:

• Trend Channel · Up may show a rising structure with relatively parallel rails.
• Trend Channel · Down may show a falling structure with relatively parallel rails.
• Balance Range may show a flatter market structure.
• Ascending Pressure may show rising lower pressure against a flatter upper rail.
• Descending Pressure may show falling upper pressure against a flatter lower rail.
• Symmetric Compression may show price contracting between two rails.
• Volatility Expansion may show rails moving away from each other.

The script is most useful when combined with independent chart analysis, risk management, and a defined trading plan.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

It does not guarantee that a detected structure will continue, break out, or reverse.

Because the script uses confirmed pivots, structures may appear after confirmation.

In low-volatility or noisy sideways markets, structure detection may be less reliable.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Market Structure Scanner

Market Structure Scanner는 확정 피봇을 기반으로 상단/하단 구조 레일을 만들어 시장 구조를 시각화하는 차트 분석 보조지표입니다.

이 스크립트는 가격이 시간에 따라 어떤 구조를 형성하는지 관찰하는 데 초점을 둡니다. 미래 가격 움직임을 예측하거나 매수·매도 추천을 제공하지 않습니다. 목적은 채널, 레인지, 압축, 방향성 압력, 확장 구조를 차트 위에서 쉽게 확인하는 것입니다.

────────────────────
핵심 개념
────────────────────

이 스크립트는 확정된 스윙 피봇을 사용해 시장 구조를 단순화해서 보여줍니다.

각 캔들의 움직임을 모두 해석하기보다, 피봇 고점과 피봇 저점이 번갈아 형성되는 구조를 확인합니다. 이후 피봇을 바탕으로 두 개의 기준 레일을 만듭니다.

• 피봇 고점 기반 상단 레일
• 피봇 저점 기반 하단 레일

그다음 두 레일의 관계를 평가합니다.

스크립트는 레일이 다음 중 어떤 상태인지 확인합니다.

• 함께 상승하는지
• 함께 하락하는지
• 비교적 평행하게 움직이는지
• 서로 압축되고 있는지
• 서로 확장되고 있는지
• 균형 또는 레인지 구간을 형성하는지

이를 통해 차트를 단일 캔들의 모음이 아니라 구조적 환경으로 볼 수 있도록 돕습니다.

────────────────────
감지 구조
────────────────────

이 스캐너는 다음 구조 상태를 감지할 수 있습니다.

• Trend Channel · Up
• Trend Channel · Down
• Balance Range
• Ascending Pressure
• Descending Pressure
• Symmetric Compression
• Volatility Expansion

이 문구들은 구조 설명일 뿐이며, 매매 신호가 아닙니다.

────────────────────
작동 방식
────────────────────

1. 확정된 피봇 고점과 피봇 저점을 감지합니다.
2. 최근 피봇을 저장하고, 번갈아 형성되는 스윙 포인트만 유지합니다.
3. 최근 5개의 피봇을 사용해 상단/하단 구조 레일을 만듭니다.
4. 레일 기울기, 평탄도, 거리 변화, 압축, 확장, 레일 적합도를 측정합니다.
5. ATR 기반 높이 필터를 적용해 너무 약한 구조를 제외합니다.
6. 품질 점수 필터를 적용해 노이즈성 구조를 줄입니다.
7. 시간과 가격이 너무 가까운 중복 구조 표시를 줄입니다.
8. 필터를 통과한 구조에 대해 레일, 영역, 노드, 라벨, 상태 패널을 표시합니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 상단 구조 레일
• 하단 구조 레일
• 구조 영역
• 구조 노드
• 선택 가능한 내부 피봇 연결선
• 선택 가능한 피봇 번호
• 구조 라벨
• 최신 구조 상태 패널

상태 패널은 최신 감지 구조의 유형, 모드, 품질 등급, 상단 레일, 하단 레일, 구조 폭을 보여줍니다.

────────────────────
입력값 및 설정
────────────────────

주요 설정은 다음과 같습니다.

Pivot left strength:
피봇 왼쪽에서 필요한 확인 봉 수를 조정합니다.

Pivot right confirmation bars:
피봇이 확정되기 위해 오른쪽에서 필요한 확인 봉 수를 조정합니다.

Minimum pivot deviation:
너무 작은 피봇 변화를 필터링하여 노이즈성 구조를 줄입니다.

Minimum structure quality:
스캐너가 구조를 얼마나 엄격하게 선별할지 조정합니다.

Minimum structure width:
구조가 최소 몇 개의 봉을 포함해야 하는지 설정합니다.

Minimum structure height × ATR:
최근 변동성 대비 너무 작은 구조를 제외합니다.

Maximum rail fit error:
피봇이 구조 레일에 얼마나 잘 맞아야 하는지 설정합니다.

Compression and expansion ratios:
상단/하단 레일이 얼마나 강하게 압축 또는 확장되어야 하는지 조정합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 피봇 확인 방식을 사용합니다.

피봇은 오른쪽 확인 봉이 완성된 후에만 확정됩니다. 따라서 감지된 구조는 실제 피봇 지점보다 늦게 표시될 수 있습니다.

오른쪽 확인 봉 설정을 낮추면 더 빠르게 반응하지만 민감도가 높아질 수 있습니다.

오른쪽 확인 봉 설정을 높이면 더 안정적일 수 있지만 구조 표시가 늦어질 수 있습니다.

이 스크립트는 실시간 예측 엔진이 아니라 확정 구조 스캐너입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 시장 구조 분석 보조도구로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• Trend Channel · Up은 비교적 평행한 상승 구조를 보여줄 수 있습니다.
• Trend Channel · Down은 비교적 평행한 하락 구조를 보여줄 수 있습니다.
• Balance Range는 평탄한 시장 구조를 보여줄 수 있습니다.
• Ascending Pressure는 평평한 상단 레일에 대해 하단 압력이 높아지는 구조를 보여줄 수 있습니다.
• Descending Pressure는 평평한 하단 레일에 대해 상단 압력이 낮아지는 구조를 보여줄 수 있습니다.
• Symmetric Compression은 두 레일 사이에서 가격이 압축되는 구조를 보여줄 수 있습니다.
• Volatility Expansion은 두 레일이 서로 멀어지는 구조를 보여줄 수 있습니다.

이 스크립트는 독립적인 차트 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

감지된 구조가 반드시 지속, 돌파, 반전된다는 것을 보장하지 않습니다.

확정 피봇을 사용하기 때문에 구조는 확인 이후 표시될 수 있습니다.

저변동성 또는 노이즈가 많은 횡보장에서는 구조 감지의 유용성이 낮아질 수 있습니다.

────────────────────
중요 고지
────────────────────

본 게시물은 교육 및 정보 제공 목적의 차트 분석 자료입니다.

투자 자문, 매수·매도 추천, 특정 금융상품 거래 권유를 의미하지 않습니다.

모든 투자 판단과 그 결과에 대한 책임은 이용자 본인에게 있습니다.

## Source Code

````pine
//@version=6
indicator("Market Structure Scanner", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=120, max_bars_back=500)

// Market Structure Scanner
// This script studies pivot-confirmed market structure using upper/lower rails,
// compression and expansion behavior, range/channel conditions, and quality filters.
// It is intended for educational chart analysis and does not provide trade signals.

//────────────────────────────────────────────────────────────────────
// Groups
//────────────────────────────────────────────────────────────────────
grpPivot   = "Pivot Engine"
grpScan    = "Structure Detection"
grpQuality = "Quality Filters"
grpVisual  = "Visual Settings"
grpHistory = "History / Duplicate Control"
grpPanel   = "Status Panel"
grpAlert   = "Alerts"

//────────────────────────────────────────────────────────────────────
// Structure codes
//────────────────────────────────────────────────────────────────────
STRUCT_NONE        = 0
STRUCT_UP_CHANNEL  = 1
STRUCT_DOWN_CHANNEL = 2
STRUCT_RANGE       = 3
STRUCT_UP_PRESSURE = 4
STRUCT_DOWN_PRESSURE = 5
STRUCT_COMPRESSION = 6
STRUCT_EXPANSION   = 7

MODE_NONE      = 0
MODE_FLOW      = 1
MODE_PRESSURE  = 2
MODE_BALANCE   = 3
MODE_EXPANSION = 4

//────────────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────────────
pivotLeft = input.int(5, "Pivot left strength", minval=2, maxval=25, group=grpPivot)
pivotRight = input.int(2, "Pivot right confirmation bars", minval=1, maxval=15, group=grpPivot, tooltip="Lower values react faster but may be more sensitive. Higher values are more stable but confirm later.")
maxPivotMemory = input.int(90, "Pivot memory depth", minval=20, maxval=250, group=grpPivot)
minPivotDeviationPct = input.float(0.35, "Minimum pivot deviation %", minval=0.05, maxval=5.0, step=0.05, group=grpPivot)

extendBars = input.int(12, "Right rail extension bars", minval=0, maxval=80, group=grpScan)
detectChannels = input.bool(true, "Detect channel structures", group=grpScan)
detectCompression = input.bool(true, "Detect compression structures", group=grpScan)
detectExpansion = input.bool(false, "Detect expansion structures", group=grpScan)

minimumQuality = input.int(72, "Minimum structure quality", minval=0, maxval=100, group=grpQuality)
minimumWidthBars = input.int(18, "Minimum structure width bars", minval=5, maxval=200, group=grpQuality)
minimumHeightAtr = input.float(2.0, "Minimum structure height × ATR", minval=0.3, maxval=10.0, step=0.1, group=grpQuality)
maximumFitErrorPct = input.float(1.2, "Maximum rail fit error %", minval=0.2, maxval=8.0, step=0.1, group=grpQuality)
flatTolerancePct = input.float(1.35, "Flat rail tolerance %", minval=0.2, maxval=5.0, step=0.05, group=grpQuality)
parallelTolerancePct = input.float(28.0, "Parallel gap tolerance %", minval=5.0, maxval=80.0, step=1.0, group=grpQuality)
compressionRatio = input.float(0.78, "Compression gap ratio", minval=0.35, maxval=0.95, step=0.01, group=grpQuality)
expansionRatio = input.float(1.25, "Expansion gap ratio", minval=1.05, maxval=2.5, step=0.01, group=grpQuality)

showHistoricalStructures = input.bool(true, "Show historical structures", group=grpHistory)
maxHistoricalStructures = input.int(12, "Max historical structures", minval=1, maxval=40, group=grpHistory)
duplicateBars = input.int(25, "Duplicate check bars", minval=0, maxval=200, group=grpHistory)
duplicatePricePct = input.float(0.8, "Duplicate midpoint distance %", minval=0.1, maxval=5.0, step=0.1, group=grpHistory)

showStructureRails = input.bool(true, "Show structure rails", group=grpVisual)
showStructureZone = input.bool(true, "Show structure zone", group=grpVisual)
showInternalLinks = input.bool(false, "Show internal pivot links", group=grpVisual)
showStructureNodes = input.bool(true, "Show structure nodes", group=grpVisual)
showPivotNumbers = input.bool(false, "Show numbered pivots", group=grpVisual)
showStructureLabel = input.bool(true, "Show structure label", group=grpVisual)
showQualityInLabel = input.bool(true, "Show quality in label", group=grpVisual)
railWidth = input.int(3, "Rail width", minval=1, maxval=5, group=grpVisual)
labelSizeInput = input.string("small", "Label size", options=["tiny", "small", "normal", "large"], group=grpVisual)
nodeSizeInput = input.string("tiny", "Node size", options=["tiny", "small", "normal"], group=grpVisual)
labelOffsetBars = input.int(2, "Label right offset bars", minval=0, maxval=20, group=grpVisual)

showPanel = input.bool(true, "Show latest structure panel", group=grpPanel)
panelPositionInput = input.string("Top Right", "Panel position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpPanel)

enableAlerts = input.bool(true, "Enable structure alert", group=grpAlert)

//────────────────────────────────────────────────────────────────────
// Colors
//────────────────────────────────────────────────────────────────────
colGold = #F5C518
colOrange = #FF9800
colGreen = #10B981
colRed = #EF4444
colBlue = #2196F3
colCyan = #38BDF8
colPurple = #7C3AED
colPink = #EC4899
colGray = #6B7280
colPanel = #111827
colPanelKey = #1F2937

atrValue = ta.atr(14)

//────────────────────────────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────────────────────────────
f_labelSize(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : size.large

labelSize = f_labelSize(labelSizeInput)
nodeSize = f_labelSize(nodeSizeInput)

f_panelPosition(string s) =>
    s == "Top Left" ? position.top_left :
     s == "Bottom Left" ? position.bottom_left :
     s == "Bottom Right" ? position.bottom_right :
     position.top_right

panelPosition = f_panelPosition(panelPositionInput)

f_lineValue(int x1, float y1, int x2, float y2, int x) =>
    x2 == x1 ? y2 : y1 + (y2 - y1) * (x - x1) / (x2 - x1)

f_absPctDiff(float a, float b) =>
    math.min(math.abs(a), math.abs(b)) != 0.0 ? math.abs(a - b) / math.min(math.abs(a), math.abs(b)) * 100.0 : 999.0

f_structureName(int t) =>
    t == STRUCT_UP_CHANNEL ? "Trend Channel · Up" :
     t == STRUCT_DOWN_CHANNEL ? "Trend Channel · Down" :
     t == STRUCT_RANGE ? "Balance Range" :
     t == STRUCT_UP_PRESSURE ? "Ascending Pressure" :
     t == STRUCT_DOWN_PRESSURE ? "Descending Pressure" :
     t == STRUCT_COMPRESSION ? "Symmetric Compression" :
     t == STRUCT_EXPANSION ? "Volatility Expansion" : "None"

f_structureTag(int t) =>
    t == STRUCT_UP_CHANNEL ? "Up Channel" :
     t == STRUCT_DOWN_CHANNEL ? "Down Channel" :
     t == STRUCT_RANGE ? "Range" :
     t == STRUCT_UP_PRESSURE ? "Asc Pressure" :
     t == STRUCT_DOWN_PRESSURE ? "Desc Pressure" :
     t == STRUCT_COMPRESSION ? "Compression" :
     t == STRUCT_EXPANSION ? "Expansion" : "None"

f_structureMode(int t) =>
    t == STRUCT_UP_CHANNEL or t == STRUCT_DOWN_CHANNEL ? MODE_FLOW :
     t == STRUCT_RANGE ? MODE_BALANCE :
     t == STRUCT_UP_PRESSURE or t == STRUCT_DOWN_PRESSURE or t == STRUCT_COMPRESSION ? MODE_PRESSURE :
     t == STRUCT_EXPANSION ? MODE_EXPANSION :
     MODE_NONE

f_modeText(int m) =>
    m == MODE_FLOW ? "Flow" :
     m == MODE_PRESSURE ? "Pressure" :
     m == MODE_BALANCE ? "Balance" :
     m == MODE_EXPANSION ? "Expansion" : "None"

f_structureColor(int t) =>
    t == STRUCT_UP_CHANNEL ? color.new(colGold, 0) :
     t == STRUCT_DOWN_CHANNEL ? color.new(colBlue, 0) :
     t == STRUCT_RANGE ? color.new(colOrange, 0) :
     t == STRUCT_UP_PRESSURE ? color.new(colGold, 0) :
     t == STRUCT_DOWN_PRESSURE ? color.new(colRed, 0) :
     t == STRUCT_COMPRESSION ? color.new(colPurple, 0) :
     t == STRUCT_EXPANSION ? color.new(colPink, 0) :
     color.new(colGray, 0)

f_qualityGrade(float q) =>
    q >= 90 ? "A+" : q >= 82 ? "A" : q >= 74 ? "B+" : q >= 66 ? "B" : q >= 58 ? "C" : "Low"

f_priceText(float x) =>
    str.tostring(x, format.mintick)

f_isDuplicate(int lastBar, float lastMid, int curBar, float curMid) =>
    bool closeInBars = curBar - lastBar <= duplicateBars
    bool closeInPrice = not na(lastMid) and f_absPctDiff(curMid, lastMid) <= duplicatePricePct
    closeInBars and closeInPrice

//────────────────────────────────────────────────────────────────────
// Object management
//────────────────────────────────────────────────────────────────────
var array<line> lineObjects = array.new_line()
var array<label> labelObjects = array.new_label()
var array<box> boxObjects = array.new_box()

f_objectLimit(int multiplier) =>
    (showHistoricalStructures ? maxHistoricalStructures : 1) * multiplier

f_trimLines() =>
    while array.size(lineObjects) > f_objectLimit(8)
        line.delete(array.shift(lineObjects))
    true

f_trimLabels() =>
    while array.size(labelObjects) > f_objectLimit(8)
        label.delete(array.shift(labelObjects))
    true

f_trimBoxes() =>
    while array.size(boxObjects) > f_objectLimit(4)
        box.delete(array.shift(boxObjects))
    true

f_addLine(int x1, float y1, int x2, float y2, color c, int w, line_style) =>
    line ln = line.new(x1, y1, x2, y2, color=c, width=w, style=line_style)
    array.push(lineObjects, ln)
    f_trimLines()
    ln

f_addLabel(int x, float y, string txt, label_style, color bg, color tc, label_size) =>
    label lb = label.new(x, y, txt, style=label_style, color=bg, textcolor=tc, size=label_size)
    array.push(labelObjects, lb)
    f_trimLabels()
    lb

f_addBox(int l, float t, int r, float b, color bg, color border) =>
    box bx = box.new(l, t, r, b, bgcolor=bg, border_color=border)
    array.push(boxObjects, bx)
    f_trimBoxes()
    bx

//────────────────────────────────────────────────────────────────────
// Pivot engine
//────────────────────────────────────────────────────────────────────
var array<float> pivotPrices = array.new_float()
var array<int> pivotBars = array.new_int()
var array<int> pivotDirs = array.new_int()

pivotHighRaw = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLowRaw = ta.pivotlow(low, pivotLeft, pivotRight)

f_addPivot(float price, int bar, int dir) =>
    bool changed = false
    int sz = array.size(pivotPrices)

    if sz == 0
        array.push(pivotPrices, price)
        array.push(pivotBars, bar)
        array.push(pivotDirs, dir)
        changed := true
    else
        int lastDir = array.get(pivotDirs, sz - 1)
        float lastPrice = array.get(pivotPrices, sz - 1)

        if dir == lastDir
            bool replacePivot = (dir == 1 and price > lastPrice) or (dir == -1 and price < lastPrice)
            if replacePivot
                array.set(pivotPrices, sz - 1, price)
                array.set(pivotBars, sz - 1, bar)
                changed := true
        else
            float deviation = lastPrice != 0.0 ? math.abs(price - lastPrice) / math.abs(lastPrice) * 100.0 : 999.0
            if deviation >= minPivotDeviationPct
                array.push(pivotPrices, price)
                array.push(pivotBars, bar)
                array.push(pivotDirs, dir)
                changed := true

                if array.size(pivotPrices) > maxPivotMemory
                    array.shift(pivotPrices)
                    array.shift(pivotBars)
                    array.shift(pivotDirs)

    changed

bool pivotChanged = false

if not na(pivotHighRaw)
    pivotChanged := f_addPivot(pivotHighRaw, bar_index - pivotRight, 1)

if not na(pivotLowRaw)
    bool lowChanged = f_addPivot(pivotLowRaw, bar_index - pivotRight, -1)
    pivotChanged := pivotChanged or lowChanged

//────────────────────────────────────────────────────────────────────
// Latest structure state
//────────────────────────────────────────────────────────────────────
var int latestStructure = STRUCT_NONE
var int latestMode = MODE_NONE
var float latestQuality = na
var float latestUpper = na
var float latestLower = na
var float latestMid = na
var int latestStartBar = na
var int latestEndBar = na

var int lastDrawBar = -100000
var float lastDrawMid = na

structureEvent = false

//────────────────────────────────────────────────────────────────────
// Structure detection
//────────────────────────────────────────────────────────────────────
if pivotChanged and array.size(pivotPrices) >= 5
    int sz = array.size(pivotPrices)

    int b1 = array.get(pivotBars, sz - 5)
    int b2 = array.get(pivotBars, sz - 4)
    int b3 = array.get(pivotBars, sz - 3)
    int b4 = array.get(pivotBars, sz - 2)
    int b5 = array.get(pivotBars, sz - 1)

    float p1 = array.get(pivotPrices, sz - 5)
    float p2 = array.get(pivotPrices, sz - 4)
    float p3 = array.get(pivotPrices, sz - 3)
    float p4 = array.get(pivotPrices, sz - 2)
    float p5 = array.get(pivotPrices, sz - 1)

    int d1 = array.get(pivotDirs, sz - 5)
    int d2 = array.get(pivotDirs, sz - 4)
    int d3 = array.get(pivotDirs, sz - 3)
    int d4 = array.get(pivotDirs, sz - 2)
    int d5 = array.get(pivotDirs, sz - 1)

    bool alternating = d1 != d2 and d2 != d3 and d3 != d4 and d4 != d5

    float firstHigh = na
    float lastHigh = na
    int firstHighBar = na
    int lastHighBar = na

    float firstLow = na
    float lastLow = na
    int firstLowBar = na
    int lastLowBar = na

    int highCount = 0
    int lowCount = 0

    if d1 == 1
        firstHigh := p1
        lastHigh := p1
        firstHighBar := b1
        lastHighBar := b1
        highCount += 1
    else
        firstLow := p1
        lastLow := p1
        firstLowBar := b1
        lastLowBar := b1
        lowCount += 1

    if d2 == 1
        if na(firstHigh)
            firstHigh := p2
            firstHighBar := b2
        lastHigh := p2
        lastHighBar := b2
        highCount += 1
    else
        if na(firstLow)
            firstLow := p2
            firstLowBar := b2
        lastLow := p2
        lastLowBar := b2
        lowCount += 1

    if d3 == 1
        if na(firstHigh)
            firstHigh := p3
            firstHighBar := b3
        lastHigh := p3
        lastHighBar := b3
        highCount += 1
    else
        if na(firstLow)
            firstLow := p3
            firstLowBar := b3
        lastLow := p3
        lastLowBar := b3
        lowCount += 1

    if d4 == 1
        if na(firstHigh)
            firstHigh := p4
            firstHighBar := b4
        lastHigh := p4
        lastHighBar := b4
        highCount += 1
    else
        if na(firstLow)
            firstLow := p4
            firstLowBar := b4
        lastLow := p4
        lastLowBar := b4
        lowCount += 1

    if d5 == 1
        if na(firstHigh)
            firstHigh := p5
            firstHighBar := b5
        lastHigh := p5
        lastHighBar := b5
        highCount += 1
    else
        if na(firstLow)
            firstLow := p5
            firstLowBar := b5
        lastLow := p5
        lastLowBar := b5
        lowCount += 1

    int startBar = b1
    int endBar = b5
    int widthBars = endBar - startBar

    bool hasRails = not na(firstHigh) and not na(lastHigh) and not na(firstLow) and not na(lastLow) and firstHighBar != lastHighBar and firstLowBar != lastLowBar

    if alternating and hasRails and highCount >= 2 and lowCount >= 2 and widthBars >= minimumWidthBars
        float upperStart = f_lineValue(firstHighBar, firstHigh, lastHighBar, lastHigh, startBar)
        float upperEnd = f_lineValue(firstHighBar, firstHigh, lastHighBar, lastHigh, endBar)
        float lowerStart = f_lineValue(firstLowBar, firstLow, lastLowBar, lastLow, startBar)
        float lowerEnd = f_lineValue(firstLowBar, firstLow, lastLowBar, lastLow, endBar)

        if upperStart < lowerStart
            float swapStart = upperStart
            float swapEnd = upperEnd
            upperStart := lowerStart
            upperEnd := lowerEnd
            lowerStart := swapStart
            lowerEnd := swapEnd

        float gapStart = upperStart - lowerStart
        float gapEnd = upperEnd - lowerEnd
        float maxHeight = math.max(gapStart, gapEnd)
        float midEnd = (upperEnd + lowerEnd) / 2.0

        float highMovePct = f_absPctDiff(firstHigh, lastHigh)
        float lowMovePct = f_absPctDiff(firstLow, lastLow)

        bool highFlat = highMovePct <= flatTolerancePct
        bool lowFlat = lowMovePct <= flatTolerancePct

        bool highUp = lastHigh > firstHigh and not highFlat
        bool highDown = lastHigh < firstHigh and not highFlat
        bool lowUp = lastLow > firstLow and not lowFlat
        bool lowDown = lastLow < firstLow and not lowFlat

        float gapChangePct = gapStart > 0 ? math.abs(gapEnd - gapStart) / gapStart * 100.0 : 999.0
        bool parallelRails = gapChangePct <= parallelTolerancePct
        bool compressingRails = gapStart > 0 and gapEnd > 0 and gapEnd <= gapStart * compressionRatio
        bool expandingRails = gapStart > 0 and gapEnd > 0 and gapEnd >= gapStart * expansionRatio

        float maxFitError = 0.0

        for j = 0 to 4
            int bj = j == 0 ? b1 : j == 1 ? b2 : j == 2 ? b3 : j == 3 ? b4 : b5
            float pj = j == 0 ? p1 : j == 1 ? p2 : j == 2 ? p3 : j == 3 ? p4 : p5
            int dj = j == 0 ? d1 : j == 1 ? d2 : j == 2 ? d3 : j == 3 ? d4 : d5
            float railValue = dj == 1 ? f_lineValue(firstHighBar, firstHigh, lastHighBar, lastHigh, bj) : f_lineValue(firstLowBar, firstLow, lastLowBar, lastLow, bj)
            float err = f_absPctDiff(pj, railValue)
            maxFitError := math.max(maxFitError, err)

        bool fitOk = maxFitError <= maximumFitErrorPct
        bool heightOk = atrValue > 0 ? maxHeight / atrValue >= minimumHeightAtr : true

        int detected = STRUCT_NONE

        if detectCompression and highFlat and lowUp and compressingRails
            detected := STRUCT_UP_PRESSURE
        else if detectCompression and lowFlat and highDown and compressingRails
            detected := STRUCT_DOWN_PRESSURE
        else if detectCompression and highDown and lowUp and compressingRails
            detected := STRUCT_COMPRESSION
        else if detectChannels and highUp and lowUp and parallelRails
            detected := STRUCT_UP_CHANNEL
        else if detectChannels and highDown and lowDown and parallelRails
            detected := STRUCT_DOWN_CHANNEL
        else if detectChannels and parallelRails and (highFlat or lowFlat or gapChangePct <= parallelTolerancePct)
            detected := STRUCT_RANGE
        else if detectExpansion and expandingRails
            detected := STRUCT_EXPANSION

        bool allowed = detected != STRUCT_NONE and fitOk and heightOk
        bool duplicate = f_isDuplicate(lastDrawBar, lastDrawMid, endBar, midEnd)

        if allowed and not duplicate
            float qualityFit = math.max(0.0, 35.0 * (1.0 - maxFitError / maximumFitErrorPct))
            float qualityWidth = math.min(20.0, widthBars / minimumWidthBars * 10.0)
            float qualityHeight = atrValue > 0 ? math.min(20.0, maxHeight / atrValue / minimumHeightAtr * 12.0) : 10.0
            float qualityStructure = detected == STRUCT_UP_PRESSURE or detected == STRUCT_DOWN_PRESSURE or detected == STRUCT_COMPRESSION ? (compressingRails ? 20.0 : 8.0) :
                 detected == STRUCT_UP_CHANNEL or detected == STRUCT_DOWN_CHANNEL or detected == STRUCT_RANGE ? (parallelRails ? 20.0 : 8.0) :
                 detected == STRUCT_EXPANSION ? (expandingRails ? 18.0 : 6.0) : 0.0
            float qualityTouches = highCount + lowCount >= 5 ? 5.0 : 0.0
            float qualityScore = qualityFit + qualityWidth + qualityHeight + qualityStructure + qualityTouches

            if qualityScore >= minimumQuality
                color c = f_structureColor(detected)
                int mode = f_structureMode(detected)

                int rightBar = endBar + extendBars
                float upperRight = f_lineValue(firstHighBar, firstHigh, lastHighBar, lastHigh, rightBar)
                float lowerRight = f_lineValue(firstLowBar, firstLow, lastLowBar, lastLow, rightBar)

                if showStructureZone
                    float zoneTop = math.max(upperStart, upperEnd)
                    float zoneBottom = math.min(lowerStart, lowerEnd)
                    f_addBox(startBar, zoneTop, endBar, zoneBottom, color.new(c, 94), color.new(c, 92))

                if showStructureRails
                    f_addLine(firstHighBar, firstHigh, rightBar, upperRight, c, railWidth, line.style_solid)
                    f_addLine(firstLowBar, firstLow, rightBar, lowerRight, color.new(c, 18), math.max(1, railWidth - 1), line.style_dashed)

                if showInternalLinks
                    f_addLine(b1, p1, b2, p2, color.new(c, 55), 1, line.style_dotted)
                    f_addLine(b2, p2, b3, p3, color.new(c, 55), 1, line.style_dotted)
                    f_addLine(b3, p3, b4, p4, color.new(c, 55), 1, line.style_dotted)
                    f_addLine(b4, p4, b5, p5, color.new(c, 55), 1, line.style_dotted)

                if showStructureNodes
                    f_addLabel(b1, p1, "◆", d1 == 1 ? label.style_label_down : label.style_label_up, color.new(#101010, 0), c, nodeSize)
                    f_addLabel(b2, p2, "◆", d2 == 1 ? label.style_label_down : label.style_label_up, color.new(#101010, 0), c, nodeSize)
                    f_addLabel(b3, p3, "◆", d3 == 1 ? label.style_label_down : label.style_label_up, color.new(#101010, 0), c, nodeSize)
                    f_addLabel(b4, p4, "◆", d4 == 1 ? label.style_label_down : label.style_label_up, color.new(#101010, 0), c, nodeSize)
                    f_addLabel(b5, p5, "◆", d5 == 1 ? label.style_label_down : label.style_label_up, color.new(#101010, 0), c, nodeSize)

                if showPivotNumbers
                    f_addLabel(b1, p1, "1", d1 == 1 ? label.style_label_down : label.style_label_up, color.new(c, 0), color.black, nodeSize)
                    f_addLabel(b2, p2, "2", d2 == 1 ? label.style_label_down : label.style_label_up, color.new(c, 0), color.black, nodeSize)
                    f_addLabel(b3, p3, "3", d3 == 1 ? label.style_label_down : label.style_label_up, color.new(c, 0), color.black, nodeSize)
                    f_addLabel(b4, p4, "4", d4 == 1 ? label.style_label_down : label.style_label_up, color.new(c, 0), color.black, nodeSize)
                    f_addLabel(b5, p5, "5", d5 == 1 ? label.style_label_down : label.style_label_up, color.new(c, 0), color.black, nodeSize)

                if showStructureLabel
                    string labelText = "Structure Scan\n" + f_structureTag(detected)
                    if showQualityInLabel
                        labelText += "\n" + f_modeText(mode) + " · " + f_qualityGrade(qualityScore)
                    float labelY = upperEnd + atrValue * 0.85
                    f_addLabel(endBar + labelOffsetBars, labelY, labelText, label.style_label_left, color.new(#0B0B0B, 4), color.new(colGold, 0), labelSize)

                latestStructure := detected
                latestMode := mode
                latestQuality := qualityScore
                latestUpper := upperEnd
                latestLower := lowerEnd
                latestMid := midEnd
                latestStartBar := startBar
                latestEndBar := endBar

                lastDrawBar := endBar
                lastDrawMid := midEnd
                structureEvent := true

//────────────────────────────────────────────────────────────────────
// Panel
//────────────────────────────────────────────────────────────────────
var table panel = table.new(panelPosition, 2, 7, border_width=1, frame_color=color.new(colGold, 75), border_color=color.new(colGold, 85))

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "Structure", text_color=color.new(colGold, 0), bgcolor=color.new(colPanel, 0), text_size=size.small)
    table.cell(panel, 1, 0, "Scanner", text_color=color.white, bgcolor=color.new(colPanel, 0), text_size=size.small)

    table.cell(panel, 0, 1, "Type", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 1, f_structureName(latestStructure), text_color=color.white, bgcolor=color.new(colPanel, 0), text_size=size.tiny)

    table.cell(panel, 0, 2, "Mode", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 2, f_modeText(latestMode), text_color=color.new(colGold, 0), bgcolor=color.new(colPanel, 0), text_size=size.tiny)

    table.cell(panel, 0, 3, "Quality", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 3, na(latestQuality) ? "-" : f_qualityGrade(latestQuality) + " (" + str.tostring(latestQuality, "#") + ")", text_color=color.new(colGreen, 0), bgcolor=color.new(colPanel, 0), text_size=size.tiny)

    table.cell(panel, 0, 4, "Upper Rail", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 4, na(latestUpper) ? "-" : f_priceText(latestUpper), text_color=color.new(colGold, 0), bgcolor=color.new(colPanel, 0), text_size=size.tiny)

    table.cell(panel, 0, 5, "Lower Rail", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 5, na(latestLower) ? "-" : f_priceText(latestLower), text_color=color.new(colBlue, 0), bgcolor=color.new(colPanel, 0), text_size=size.tiny)

    table.cell(panel, 0, 6, "Width", text_color=color.white, bgcolor=color.new(colPanelKey, 0), text_size=size.tiny)
    table.cell(panel, 1, 6, na(latestStartBar) or na(latestEndBar) ? "-" : str.tostring(latestEndBar - latestStartBar) + " bars", text_color=color.white, bgcolor=color.new(colPanel, 0), text_size=size.tiny)

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
alertcondition(enableAlerts and structureEvent, "Market Structure Scan", "A new market structure was detected.")
````
