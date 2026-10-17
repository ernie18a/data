# MACD Pressure Zones | Alpha S+

- url: https://www.tradingview.com/script/fuDnvMxD-MACD-Pressure-Zones-Alpha-S/
- type: indicator
- pine_id: PUB;c96e2f3e96a64ec1a77700926f361c90
- version: 2.0

## Description

Range Compression Map | Alpha S+

Range Compression Map is a chart-based range and sideways-structure detection tool designed to help users study price compression directly on the chart.

Instead of displaying a separate oscillator or status panel, this script draws volatility-adjusted range boxes around areas where price remains contained inside a controlled structure. The box then changes its border and background state when price breaks above, breaks below, or returns back into the range after a failed break.

The script does not provide entry or exit recommendations. Its purpose is to help users study range compression, sideways structure, breakout context, failed breaks, and the relationship between price action and volatility-adjusted boundaries.

────────────────────
Core Concept
────────────────────

Markets often alternate between expansion and compression.

During compression, price tends to remain inside a relatively narrow structure before a directional move develops.

This script uses a volatility-adjusted range model to identify when recent closing prices remain inside an ATR-based boundary around a central price line.

The main concept is:

• calculate a central range reference
• build upper and lower boundaries using ATR-based volatility
• check whether recent closing prices remain inside those boundaries
• draw a range box when price is contained
• keep the visual focus on the box instead of adding many chart labels
• change the box state when price breaks upward or downward
• optionally detect failed breaks when price returns back into the range
• use border and background color changes instead of heavy signal markers

This makes the indicator useful as a chart-based range structure viewer rather than a standalone buy or sell signal tool.

────────────────────
What This Script Shows
────────────────────

The script can display:

• range compression boxes
• active sideways structure zones
• volatility-adjusted upper and lower range boundaries
• dotted range midpoint line
• unbroken range state
• upward break state
• downward break state
• optional fakeout state
• optional break labels
• optional fakeout labels
• optional adaptive center mode
• optional top and bottom range lines

These elements are designed to help users identify whether price is still compressed inside a range or has moved outside of the structure.

────────────────────
How It Works
────────────────────

1. The script calculates a central price reference using the selected center mode.
2. In SMA mode, the center is based on a moving average of the selected source.
3. In Adaptive mode, the center updates only when price moves far enough from the previous center using an ATR-based step.
4. The script builds an upper and lower range boundary around the center.
5. It checks whether recent closing prices remain inside the volatility-adjusted range.
6. When the selected number of recent bars stays inside the range, the script draws a range compression box.
7. If a new detected range overlaps with an existing box, the structure can be merged instead of creating unnecessary duplicate boxes.
8. While the range remains unbroken, the box stays in its neutral range color.
9. If price closes above the active range boundary, the box changes into an upward break state.
10. If price closes below the active range boundary, the box changes into a downward break state.
11. If fakeout detection is enabled, the script can change the box into a fakeout state when price returns back inside after a break.
12. The midpoint line helps users visually track the center of the detected range structure.
13. Optional labels can be enabled, but the default design keeps the chart clean by using box color states.

This structure helps users study compression, range behavior, breakout context, and failed-break behavior without relying on crowded markers.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• minimum range length
• range width multiplier
• ATR length
• source price
• center mode: SMA or Adaptive
• adaptive ATR length
• adaptive factor
• overlap merging behavior
• cooldown after break
• maximum active range duration
• trend pause classification using ADX
• break buffer
• body confirmation for break conditions
• fakeout detection
• fakeout window
• midpoint line visibility
• top and bottom range line visibility
• optional break labels
• optional fakeout labels
• range box colors
• break box colors
• fakeout box colors
• border transparency
• background transparency
• border width
• signal border width

The default settings are designed to keep the chart clean while making range structures visible directly on the price chart.

────────────────────
Visual Elements
────────────────────

The script includes:

• range box
• midpoint line
• optional range top and bottom lines
• border color state
• background color state
• optional break labels
• optional fakeout labels

The range box is the main visual element.

The midpoint line shows the central level of the detected structure.

The border and background color provide the main state information without requiring large labels.

Optional labels can be enabled for users who prefer explicit text confirmation, but the primary design is based on clean chart boxes.

────────────────────
Reference States
────────────────────

Unbroken Range:
Price remains inside the detected volatility-adjusted range. The box stays in its neutral range color.

Upward Break:
Price closes above the active range boundary. The box changes to the upward break color.

Downward Break:
Price closes below the active range boundary. The box changes to the downward break color.

Fakeout:
If fakeout detection is enabled, price breaks out of the range and then returns back inside the structure within the selected fakeout window. The box changes to the fakeout color.

Trend Pause:
When ADX-based classification is enabled, some range structures can be treated as trend-pause zones rather than pure sideways ranges. This can help distinguish quiet consolidation from temporary pauses inside a stronger directional environment.

Adaptive Range:
When Adaptive mode is selected, the center line updates less frequently and only shifts when price moves far enough away from the previous center. This can create a more stable range reference in some market conditions.

These states are informational and should not be interpreted as trading instructions.

────────────────────
How To Use
────────────────────

Use this script as a chart-based range structure viewer.

General interpretation examples:

• A neutral range box can help users identify where price is moving inside a controlled sideways or compression structure.
• A green upward-break box can help users review where price moved above the detected range.
• A red downward-break box can help users review where price moved below the detected range.
• A yellow fakeout box, when enabled, can help users study failed range breaks.
• The midpoint line can be used as a visual reference for the center of the range.
• The adaptive center mode can be tested when users want a slower-moving center reference.
• The SMA center mode can be used when users want a more standard range-detection approach.
• Optional labels can be turned on for explicit break text, but the box color state is designed to be the primary visual guide.

This script is best reviewed together with price action, volume, volatility, support and resistance, trend structure, and higher-timeframe context.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script uses recent closing prices and ATR-based boundaries to detect range structures.

Range boxes can update as new candles appear.

On realtime candles, values can change before the candle closes because price, ATR, and range conditions can update intrabar.

Break states are based on price moving beyond the active range boundary.

For more conservative analysis, users should evaluate range breaks after candle confirmation.

The script does not use future price data to predict market direction.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide entry or exit recommendations.

A range break does not guarantee trend continuation.

A fakeout state does not guarantee reversal.

ATR length, range length, and width multiplier can materially change how often ranges appear.

Very low-liquidity markets, large gaps, news-driven moves, and extreme volatility can reduce the usefulness of range-based analysis.

In strong trending markets, some detected ranges may represent temporary pauses rather than true sideways structures.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to trade any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Range Compression Map | Alpha S+

Range Compression Map은 가격이 일정한 변동성 기준 범위 안에서 압축되거나 횡보하는 구조를 차트 위에 직접 표시하는 Range 구조 분석 도구입니다.

별도의 오실레이터나 큰 상태 패널을 중심으로 보여주는 방식이 아니라, 가격이 통제된 범위 안에 머무르는 구간을 박스로 표시하고, 이후 상단 돌파·하단 이탈·Fakeout 상태를 박스의 테두리와 배경색 변화로 구분합니다.

이 스크립트는 진입 또는 청산 추천을 제공하지 않습니다. 목적은 횡보 압축, 박스권 구조, 돌파 컨텍스트, 실패 돌파, 그리고 가격 행동과 변동성 기반 경계 사이의 관계를 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

시장은 확장과 압축을 반복하는 경우가 많습니다.

압축 구간에서는 가격이 비교적 제한된 구조 안에 머물다가 이후 방향성 움직임이 나타날 수 있습니다.

이 스크립트는 중심 가격선을 기준으로 ATR 기반 상단·하단 경계를 만들고, 최근 종가들이 해당 범위 안에 머무르는지를 확인해 Range 구조를 감지합니다.

핵심 개념은 다음과 같습니다.

• 중심 Range 기준선 계산
• ATR 기반 상단·하단 경계 생성
• 최근 종가들이 해당 경계 안에 머무르는지 확인
• 가격이 통제된 범위 안에 있으면 Range 박스 표시
• 많은 라벨보다 박스 자체를 중심으로 시각화
• 상단 돌파 또는 하단 이탈 시 박스 상태 변경
• 선택적으로 돌파 실패 후 Range 안으로 복귀하는 Fakeout 감지
• 무거운 마커 대신 테두리와 배경색 변화 중심으로 표현

이 구조는 단독 매수·매도 신호가 아니라, 차트 위에서 Range 구조를 분석하는 데 적합합니다.

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 횡보 압축 박스
• 활성 sideways structure zone
• 변동성 기반 상단·하단 Range 경계
• 점선 중앙선
• 아직 돌파되지 않은 Range 상태
• 상단 돌파 상태
• 하단 이탈 상태
• 선택 가능한 Fakeout 상태
• 선택 가능한 돌파 라벨
• 선택 가능한 Fakeout 라벨
• 선택 가능한 Adaptive Center 모드
• 선택 가능한 상단·하단 Range 라인

이 요소들은 가격이 아직 Range 안에서 압축 중인지, 또는 해당 구조를 벗어났는지를 확인하는 데 도움을 줍니다.

────────────────────
작동 방식
────────────────────

1. 스크립트는 선택한 center mode를 기준으로 중심 가격선을 계산합니다.
2. SMA 모드에서는 선택한 기준 가격의 이동평균을 중심선으로 사용합니다.
3. Adaptive 모드에서는 가격이 이전 중심선에서 ATR 기반 기준 이상으로 멀어졌을 때만 중심선이 단계적으로 갱신됩니다.
4. 중심선을 기준으로 상단·하단 Range 경계를 만듭니다.
5. 최근 종가들이 변동성 기반 Range 안에 머무르는지 확인합니다.
6. 설정된 기간 동안 가격이 Range 안에 머무르면 차트 위에 Range Compression 박스를 표시합니다.
7. 새로 감지된 Range가 기존 박스와 겹치면 불필요한 중복 박스를 만들지 않고 병합할 수 있습니다.
8. Range가 돌파되지 않은 동안 박스는 기본 Range 색상으로 유지됩니다.
9. 가격이 활성 Range 상단을 종가 기준으로 돌파하면 박스가 상방 돌파 상태로 변경됩니다.
10. 가격이 활성 Range 하단을 종가 기준으로 이탈하면 박스가 하방 이탈 상태로 변경됩니다.
11. Fakeout 감지를 켜면 돌파 후 다시 Range 안으로 복귀하는 경우 박스가 Fakeout 상태로 변경될 수 있습니다.
12. 중앙선은 감지된 Range 구조의 중심 위치를 시각적으로 확인하는 데 도움을 줍니다.
13. 선택형 라벨을 켤 수 있지만, 기본 설계는 박스 색상 상태를 중심으로 차트를 깔끔하게 유지하는 방식입니다.

이 구조는 복잡한 마커 없이 압축, Range 행동, 돌파 컨텍스트, 실패 돌파를 분석하는 데 도움을 줍니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• 최소 Range 길이
• Range 폭 배수
• ATR 길이
• 기준 가격
• 중심선 모드: SMA 또는 Adaptive
• Adaptive ATR 길이
• Adaptive factor
• 겹치는 Range 병합 여부
• 돌파 후 cooldown
• 최대 활성 Range 유지 기간
• ADX 기반 Trend Pause 분류
• 돌파 버퍼
• 돌파 조건의 몸통 확인 여부
• Fakeout 감지
• Fakeout 확인 기간
• 중앙선 표시 여부
• 상단·하단 Range 라인 표시 여부
• 선택형 돌파 라벨
• 선택형 Fakeout 라벨
• Range 박스 색상
• 돌파 박스 색상
• Fakeout 박스 색상
• 테두리 투명도
• 배경 투명도
• 테두리 두께
• 신호 상태 테두리 두께

기본 설정은 차트를 깔끔하게 유지하면서 Range 구조를 가격 차트 위에서 직접 읽을 수 있도록 설계되어 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• Range box
• Midpoint line
• 선택 가능한 Range top / bottom lines
• Border color state
• Background color state
• 선택 가능한 break labels
• 선택 가능한 fakeout labels

Range box는 이 지표의 핵심 시각 요소입니다.

Midpoint line은 감지된 구조의 중심 레벨을 보여줍니다.

테두리와 배경색은 큰 라벨 없이도 현재 Range 상태를 구분할 수 있게 합니다.

선택형 라벨은 명시적인 텍스트 확인을 원하는 사용자를 위해 제공되지만, 기본 설계는 박스 색상 상태를 중심으로 합니다.

────────────────────
참고 상태
────────────────────

Unbroken Range:
가격이 감지된 변동성 기반 Range 안에 머무르는 상태입니다. 박스는 기본 Range 색상으로 유지됩니다.

Upward Break:
가격이 활성 Range 상단을 종가 기준으로 돌파한 상태입니다. 박스는 상방 돌파 색상으로 변경됩니다.

Downward Break:
가격이 활성 Range 하단을 종가 기준으로 이탈한 상태입니다. 박스는 하방 이탈 색상으로 변경됩니다.

Fakeout:
Fakeout 감지가 켜져 있을 때, 가격이 Range를 돌파한 뒤 설정된 기간 안에 다시 Range 안으로 복귀한 상태입니다. 박스는 Fakeout 색상으로 변경됩니다.

Trend Pause:
ADX 기반 분류가 켜져 있을 때, 일부 Range 구조는 순수 횡보가 아니라 강한 방향성 흐름 중의 일시적 휴식 구간으로 분류될 수 있습니다.

Adaptive Range:
Adaptive mode를 선택하면 중심선이 매 봉마다 계속 흔들리지 않고, 가격이 이전 중심선에서 충분히 멀어졌을 때만 갱신됩니다. 일부 시장 조건에서는 더 안정적인 Range 기준을 제공할 수 있습니다.

이 상태들은 정보 제공용이며, 매매 지시로 해석해서는 안 됩니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 차트 기반 Range 구조 분석 도구로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• 기본 Range 박스는 가격이 통제된 횡보 또는 압축 구조 안에서 움직이는 구간을 확인하는 데 사용할 수 있습니다.
• 초록색 상방 돌파 박스는 가격이 감지된 Range 상단을 벗어난 구간을 복기하는 데 사용할 수 있습니다.
• 빨간색 하방 이탈 박스는 가격이 감지된 Range 하단을 벗어난 구간을 복기하는 데 사용할 수 있습니다.
• 노란색 Fakeout 박스는 Fakeout 감지를 켰을 때 실패한 Range 돌파를 검토하는 데 사용할 수 있습니다.
• 중앙선은 Range 중심 위치를 확인하는 시각 기준으로 사용할 수 있습니다.
• Adaptive Center 모드는 더 느리게 움직이는 중심 기준을 테스트하고 싶을 때 사용할 수 있습니다.
• SMA Center 모드는 더 표준적인 Range 감지 방식을 원할 때 사용할 수 있습니다.
• 선택형 라벨은 명시적 돌파 텍스트를 원할 때 켤 수 있지만, 박스 색상 상태가 기본 시각 가이드로 설계되어 있습니다.

이 스크립트는 가격 행동, 거래량, 변동성, 지지와 저항, 추세 구조, 상위 시간대 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 최근 종가와 ATR 기반 경계를 사용해 Range 구조를 감지합니다.

Range 박스는 새로운 캔들이 나타남에 따라 갱신될 수 있습니다.

실시간 캔들에서는 가격, ATR, Range 조건이 봉 마감 전까지 변할 수 있으므로 값이 변경될 수 있습니다.

돌파 상태는 가격이 활성 Range 경계를 벗어나는지를 기준으로 판단합니다.

보다 보수적인 분석을 원한다면 Range 돌파는 봉 마감 이후 확인하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

진입 또는 청산 추천을 제공하지 않습니다.

Range 돌파가 추세 지속을 보장하지 않습니다.

Fakeout 상태가 추세 반전을 보장하지 않습니다.

ATR 길이, Range 길이, 폭 배수는 Range가 표시되는 빈도에 큰 영향을 줄 수 있습니다.

저유동성 시장, 큰 갭, 뉴스 기반 급변동, 극단적 변동성 구간에서는 Range 기반 분석의 효율이 낮아질 수 있습니다.

강한 추세장에서는 일부 Range가 순수 횡보가 아니라 일시적 휴식 구간일 수 있습니다.

이 스크립트를 단독 매매 시스템으로 사용해서는 안 됩니다.

────────────────────
중요 고지
────────────────────

본 게시물은 교육 및 정보 제공 목적의 차트 분석 자료입니다.

투자 자문, 특정 금융상품 거래 권유, 또는 수익 보장을 의미하지 않습니다.

모든 투자 판단과 그 결과에 대한 책임은 이용자 본인에게 있습니다.

## Source Code

````pine
//@version=6
indicator("Range Compression Map | Alpha S+", shorttitle="RangeMap", overlay=true, max_boxes_count=500, max_labels_count=200, max_lines_count=500)

// Build: V1.4 SMA / ATR Range Engine

//====================================================
// INPUTS
//====================================================
groupDetect = "Range Detection"
rangeLen          = input.int(20, "Minimum Range Length", minval=2, maxval=200, group=groupDetect)
rangeMult         = input.float(1.0, "Range Width Multiplier", minval=0.1, maxval=10.0, step=0.1, group=groupDetect)
atrLen            = input.int(500, "ATR Length", minval=1, maxval=3000, group=groupDetect)
src               = input.source(close, "Source", group=groupDetect)
centerMode        = input.string("SMA", "Center Mode", options=["SMA", "Adaptive"], group=groupDetect)
confirmBars       = input.int(1, "Range Confirm Bars", minval=1, maxval=20, group=groupDetect)
mergeOverlaps     = input.bool(true, "Merge Overlapping Ranges", group=groupDetect)
cooldownBars      = input.int(3, "Cooldown After Break", minval=0, maxval=100, group=groupDetect)
maxActiveBars     = input.int(240, "Max Active Range Bars", minval=20, maxval=1000, group=groupDetect)

groupAdaptive = "Adaptive Center"
adaptiveLen    = input.int(200, "Adaptive ATR Length", minval=2, maxval=3000, group=groupAdaptive)
adaptiveFactor = input.float(6.0, "Adaptive Factor", minval=0.5, maxval=20.0, step=0.5, group=groupAdaptive)

groupTrend = "Range Type"
useTrendPauseType = input.bool(true, "Separate Trend Pause By ADX", group=groupTrend)
dmiLen            = input.int(14, "DMI Length", minval=5, maxval=100, group=groupTrend)
adxSmooth         = input.int(14, "ADX Smoothing", minval=5, maxval=100, group=groupTrend)
trendPauseAdx     = input.float(22.0, "Trend Pause ADX Threshold", minval=5.0, maxval=60.0, step=0.5, group=groupTrend)

groupBreak = "Break / Fakeout"
breakBufferAtr      = input.float(0.00, "Break Buffer / ATR", minval=0.00, maxval=3.0, step=0.01, group=groupBreak)
useBodyConfirm      = input.bool(false, "Use Body Confirmation", group=groupBreak)
breakBodyAtr        = input.float(0.20, "Break Body / ATR", minval=0.00, maxval=3.0, step=0.05, group=groupBreak)
fakeoutEnabled      = input.bool(true, "Detect Fakeout", group=groupBreak)
fakeoutWindow       = input.int(5, "Fakeout Check Bars", minval=1, maxval=50, group=groupBreak)
fakeoutNeedMidline  = input.bool(false, "Fakeout Requires Midline Cross", group=groupBreak)

groupDisplay = "Display"
showMidLine       = input.bool(true, "Show Midline", group=groupDisplay)
showRangeLines    = input.bool(false, "Show Top / Bottom Lines", group=groupDisplay)
showBreakLabels   = input.bool(false, "Show Break Labels", group=groupDisplay)
showFakeoutLabels = input.bool(false, "Show Fakeout Labels", group=groupDisplay)
labelSizeOpt      = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal"], group=groupDisplay)
labelOffsetAtr    = input.float(1.0, "Label Offset / ATR", minval=0.1, maxval=5.0, step=0.1, group=groupDisplay)

groupStyle = "Box Style"
rangeBorderColor = input.color(color.rgb(78, 160, 255), "Range Border", group=groupStyle)
rangeFillColor   = input.color(color.rgb(78, 160, 255), "Range Background", group=groupStyle)
pauseBorderColor = input.color(color.rgb(120, 190, 255), "Trend Pause Border", group=groupStyle)
pauseFillColor   = input.color(color.rgb(120, 190, 255), "Trend Pause Background", group=groupStyle)
bullBreakColor   = input.color(color.rgb(30, 220, 110), "Bull Break Color", group=groupStyle)
bearBreakColor   = input.color(color.rgb(255, 85, 95), "Bear Break Color", group=groupStyle)
fakeoutColor     = input.color(color.rgb(255, 195, 50), "Fakeout Color", group=groupStyle)
midLineColor     = input.color(color.rgb(210, 220, 230), "Midline Color", group=groupStyle)

rangeBoxTransp   = input.int(91, "Range Background Transparency", minval=60, maxval=98, group=groupStyle)
pauseBoxTransp   = input.int(92, "Trend Pause Background Transparency", minval=60, maxval=98, group=groupStyle)
breakBoxTransp   = input.int(88, "Break Background Transparency", minval=60, maxval=98, group=groupStyle)
fakeoutBoxTransp = input.int(86, "Fakeout Background Transparency", minval=60, maxval=98, group=groupStyle)
normalBorderTr   = input.int(25, "Normal Border Transparency", minval=0, maxval=95, group=groupStyle)
signalBorderTr   = input.int(0, "Signal Border Transparency", minval=0, maxval=95, group=groupStyle)
midLineTransp    = input.int(60, "Midline Transparency", minval=0, maxval=95, group=groupStyle)
normalBorderW    = input.int(1, "Normal Border Width", minval=1, maxval=4, group=groupStyle)
signalBorderW    = input.int(2, "Signal Border Width", minval=1, maxval=4, group=groupStyle)

//====================================================
// HELPERS
//====================================================
f_label_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : size.small

f_normal_border(_type) =>
    _type == 1 ? color.new(pauseBorderColor, normalBorderTr) : color.new(rangeBorderColor, normalBorderTr)

f_normal_bg(_type) =>
    _type == 1 ? color.new(pauseFillColor, pauseBoxTransp) : color.new(rangeFillColor, rangeBoxTransp)

f_signal_color(_dir) =>
    _dir == 1 ? bullBreakColor : bearBreakColor

f_apply_break_style(_box, _dir) =>
    if not na(_box)
        c = f_signal_color(_dir)
        box.set_border_color(_box, color.new(c, signalBorderTr))
        box.set_bgcolor(_box, color.new(c, breakBoxTransp))
        box.set_border_width(_box, signalBorderW)

f_apply_fakeout_style(_box) =>
    if not na(_box)
        box.set_border_color(_box, color.new(fakeoutColor, signalBorderTr))
        box.set_bgcolor(_box, color.new(fakeoutColor, fakeoutBoxTransp))
        box.set_border_width(_box, signalBorderW)

f_label_y(_dir, _top, _bottom, _atr, _offset) =>
    _dir == 1 ? _top + _atr * _offset : _bottom - _atr * _offset

//====================================================
// CORE CALCULATION
//====================================================
atrRange = ta.atr(atrLen) * rangeMult
smaCenter = ta.sma(src, rangeLen)

adaptiveStepAtr = ta.atr(adaptiveLen) * adaptiveFactor
var float adaptiveCenter = na
adaptiveCenter := na(adaptiveCenter) ? src : src - adaptiveCenter > adaptiveStepAtr ? adaptiveCenter + adaptiveStepAtr : adaptiveCenter - src > adaptiveStepAtr ? adaptiveCenter - adaptiveStepAtr : adaptiveCenter

center = centerMode == "Adaptive" ? adaptiveCenter : smaCenter
upperBand = center + atrRange
lowerBand = center - atrRange
midBand = center

[diplus, diminus, adxV] = ta.dmi(dmiLen, adxSmooth)
rangeTypeNow = useTrendPauseType and adxV >= trendPauseAdx ? 1 : 0

enoughBars = bar_index >= rangeLen and not na(center) and not na(atrRange)

outCount = 0
if enoughBars
    for i = 0 to rangeLen - 1
        outCount += math.abs(src[i] - center) > atrRange ? 1 : 0

rangeCandidate = enoughBars and outCount == 0

var int confirmCount = 0
confirmCount := rangeCandidate ? confirmCount + 1 : 0

rangeConfirmed = confirmCount >= confirmBars

//====================================================
// STATE
//====================================================
var bool inRange = false
var int cooldownUntil = na

var box activeBox = na
var line activeMidLine = na
var line activeTopLine = na
var line activeBottomLine = na

var float activeTop = na
var float activeBottom = na
var float activeMid = na
var int activeStart = na
var int activeType = 0
var int activeBreakDir = 0
var int activeBreakBar = na
var float breakTop = na
var float breakBottom = na
var float breakMid = na

//====================================================
// RANGE START / MERGE
//====================================================
canBuild = na(cooldownUntil) or bar_index > cooldownUntil

startX = bar_index - rangeLen + 1
candidateTop = upperBand
candidateBottom = lowerBand
candidateMid = midBand

rangeStart = rangeConfirmed and not inRange and canBuild

if rangeStart
    overlapWithLast = mergeOverlaps and not na(activeBox) and startX <= box.get_right(activeBox)

    if overlapWithLast
        activeTop := math.max(candidateTop, box.get_top(activeBox))
        activeBottom := math.min(candidateBottom, box.get_bottom(activeBox))
        activeMid := math.avg(activeTop, activeBottom)
        activeStart := box.get_left(activeBox)
        activeType := math.max(activeType, rangeTypeNow)
        activeBreakDir := 0
        activeBreakBar := na
        breakTop := na
        breakBottom := na
        breakMid := na
        inRange := true

        box.set_top(activeBox, activeTop)
        box.set_bottom(activeBox, activeBottom)
        box.set_right(activeBox, bar_index)
        box.set_border_color(activeBox, f_normal_border(activeType))
        box.set_bgcolor(activeBox, f_normal_bg(activeType))
        box.set_border_width(activeBox, normalBorderW)

        if showMidLine and not na(activeMidLine)
            line.set_x1(activeMidLine, activeStart)
            line.set_x2(activeMidLine, bar_index)
            line.set_y1(activeMidLine, activeMid)
            line.set_y2(activeMidLine, activeMid)
            line.set_color(activeMidLine, color.new(midLineColor, midLineTransp))
    else
        activeTop := candidateTop
        activeBottom := candidateBottom
        activeMid := candidateMid
        activeStart := startX
        activeType := rangeTypeNow
        activeBreakDir := 0
        activeBreakBar := na
        breakTop := na
        breakBottom := na
        breakMid := na
        inRange := true

        activeBox := box.new(
             activeStart,
             activeTop,
             bar_index,
             activeBottom,
             xloc=xloc.bar_index,
             border_color=f_normal_border(activeType),
             bgcolor=f_normal_bg(activeType),
             border_width=normalBorderW)

        if showMidLine
            activeMidLine := line.new(
                 activeStart,
                 activeMid,
                 bar_index,
                 activeMid,
                 xloc=xloc.bar_index,
                 color=color.new(midLineColor, midLineTransp),
                 style=line.style_dotted,
                 width=1)

        if showRangeLines
            activeTopLine := line.new(
                 activeStart,
                 activeTop,
                 bar_index,
                 activeTop,
                 xloc=xloc.bar_index,
                 color=color.new(rangeBorderColor, 45),
                 width=1)

            activeBottomLine := line.new(
                 activeStart,
                 activeBottom,
                 bar_index,
                 activeBottom,
                 xloc=xloc.bar_index,
                 color=color.new(rangeBorderColor, 45),
                 width=1)

//====================================================
// ACTIVE RANGE UPDATE
//====================================================
if inRange
    if activeBreakDir == 0
        if rangeCandidate
            activeTop := math.max(activeTop, candidateTop)
            activeBottom := math.min(activeBottom, candidateBottom)
            activeMid := math.avg(activeTop, activeBottom)
            activeType := math.max(activeType, rangeTypeNow)

        if not na(activeBox)
            box.set_right(activeBox, bar_index)
            box.set_top(activeBox, activeTop)
            box.set_bottom(activeBox, activeBottom)
            box.set_border_color(activeBox, f_normal_border(activeType))
            box.set_bgcolor(activeBox, f_normal_bg(activeType))

        if showMidLine and not na(activeMidLine)
            line.set_x2(activeMidLine, bar_index)
            line.set_y1(activeMidLine, activeMid)
            line.set_y2(activeMidLine, activeMid)

        if showRangeLines
            if not na(activeTopLine)
                line.set_x2(activeTopLine, bar_index)
                line.set_y1(activeTopLine, activeTop)
                line.set_y2(activeTopLine, activeTop)

            if not na(activeBottomLine)
                line.set_x2(activeBottomLine, bar_index)
                line.set_y1(activeBottomLine, activeBottom)
                line.set_y2(activeBottomLine, activeBottom)

    breakBuffer = ta.atr(atrLen) * breakBufferAtr
    bodyNow = math.abs(close - open)

    bullBreak =
         activeBreakDir == 0 and
         close > activeTop + breakBuffer and
         (not useBodyConfirm or bodyNow >= ta.atr(atrLen) * breakBodyAtr)

    bearBreak =
         activeBreakDir == 0 and
         close < activeBottom - breakBuffer and
         (not useBodyConfirm or bodyNow >= ta.atr(atrLen) * breakBodyAtr)

    if bullBreak or bearBreak
        activeBreakDir := bullBreak ? 1 : -1
        activeBreakBar := bar_index
        breakTop := activeTop
        breakBottom := activeBottom
        breakMid := activeMid

        f_apply_break_style(activeBox, activeBreakDir)

        if showMidLine and not na(activeMidLine)
            line.set_color(activeMidLine, color.new(f_signal_color(activeBreakDir), 25))

        if showBreakLabels
            label.new(
                 bar_index,
                 f_label_y(activeBreakDir, activeTop, activeBottom, ta.atr(atrLen), labelOffsetAtr),
                 activeBreakDir == 1 ? "BREAK↑" : "BREAK↓",
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=activeBreakDir == 1 ? label.style_label_up : label.style_label_down,
                 color=color.new(f_signal_color(activeBreakDir), 10),
                 textcolor=color.white,
                 size=f_label_size(labelSizeOpt))

//====================================================
// FAKEOUT / END
//====================================================
if inRange and activeBreakDir != 0
    barsAfterBreak = bar_index - activeBreakBar

    bullFakeout =
         fakeoutEnabled and
         activeBreakDir == 1 and
         barsAfterBreak >= 1 and
         barsAfterBreak <= fakeoutWindow and
         close < breakTop and
         (not fakeoutNeedMidline or close < breakMid)

    bearFakeout =
         fakeoutEnabled and
         activeBreakDir == -1 and
         barsAfterBreak >= 1 and
         barsAfterBreak <= fakeoutWindow and
         close > breakBottom and
         (not fakeoutNeedMidline or close > breakMid)

    if bullFakeout or bearFakeout
        f_apply_fakeout_style(activeBox)

        if showMidLine and not na(activeMidLine)
            line.set_color(activeMidLine, color.new(fakeoutColor, 20))

        if showFakeoutLabels
            label.new(
                 bar_index,
                 f_label_y(activeBreakDir, activeTop, activeBottom, ta.atr(atrLen), labelOffsetAtr),
                 activeBreakDir == 1 ? "FAKE↓" : "FAKE↑",
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=activeBreakDir == 1 ? label.style_label_down : label.style_label_up,
                 color=color.new(fakeoutColor, 10),
                 textcolor=color.black,
                 size=f_label_size(labelSizeOpt))

        inRange := false
        cooldownUntil := bar_index + cooldownBars
        activeBreakDir := 0
        activeBreakBar := na
        breakTop := na
        breakBottom := na
        breakMid := na

    else if barsAfterBreak > fakeoutWindow
        inRange := false
        cooldownUntil := bar_index + cooldownBars
        activeBreakDir := 0
        activeBreakBar := na
        breakTop := na
        breakBottom := na
        breakMid := na

//====================================================
// MAX ACTIVE RANGE LIMIT
//====================================================
if inRange and not na(activeStart) and bar_index - activeStart + 1 >= maxActiveBars
    inRange := false
    cooldownUntil := bar_index + cooldownBars
    activeBreakDir := 0
    activeBreakBar := na
    breakTop := na
    breakBottom := na
    breakMid := na

//====================================================
// DATA WINDOW
//====================================================
plot(center, "Range Center", display=display.data_window)
plot(upperBand, "Range Upper Band", display=display.data_window)
plot(lowerBand, "Range Lower Band", display=display.data_window)
plot(outCount, "Out Of Range Count", display=display.data_window)
plot(inRange ? 1 : 0, "Range Active", display=display.data_window)
plot(activeBreakDir, "Break Direction", display=display.data_window)
````
