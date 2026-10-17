# Impulse Momentum Oscillator

- url: https://www.tradingview.com/script/PmUXJ5B4-Impulse-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;bf2968e761204ccd8b0366bbaa7ac069
- version: 1.0

## Description

Impulse Momentum Oscillator

Impulse Momentum Oscillator is a momentum-based chart study designed to visualize impulse movement, signal-line interaction, histogram acceleration, and momentum state changes.

The script uses a smoothed high/low channel, a zero-lag midpoint line, a signal line, and a histogram to help users study how momentum expands, slows, crosses, and changes direction.

It does not provide buy or sell recommendations. The purpose of this script is to help users study momentum structure and oscillator behavior.

────────────────────
Core Concept
────────────────────

This script is based on an impulse-style oscillator model.

Instead of comparing only two moving averages, the script first builds a smoothed high/low channel and then compares a zero-lag midpoint line against that channel.

The impulse line moves away from zero when the midpoint line extends above the smoothed high channel or below the smoothed low channel.

A signal line is then calculated from the impulse line, and the histogram measures the distance between the impulse line and the signal line.

The result is an oscillator that can be used to study:

• Momentum expansion
• Momentum slowdown
• Zero-line bias
• Golden cross and dead cross behavior
• Strong cross conditions above or below the zero line

────────────────────
What This Script Shows
────────────────────

The script can display:

• Impulse line
• Signal line
• Momentum histogram
• Zero line
• Golden cross and dead cross dots
• Strong cross pulse effect
• Last-bar status label
• Momentum state panel
• Optional crossover background

These visual elements are intended to make momentum transitions easier to review.

────────────────────
How It Works
────────────────────

1. The script calculates a smoothed high channel and a smoothed low channel.
2. It calculates a zero-lag midpoint line from the selected source.
3. When the midpoint line moves above the high channel, the impulse value becomes positive.
4. When the midpoint line moves below the low channel, the impulse value becomes negative.
5. When the midpoint line stays inside the channel, the impulse value remains neutral.
6. A signal line is calculated from the impulse line.
7. The histogram is calculated as the difference between the impulse line and the signal line.
8. Optional release emphasis visually strengthens histogram movement after compression.
9. Cross markers are plotted at interpolated cross locations for cleaner visual alignment.

────────────────────
Momentum States
────────────────────

The histogram is classified into several visual states:

Strong Bull:
Histogram is positive, growing, and aligned with bullish zero-line bias.

Bull Hold:
Histogram remains positive but begins slowing.

Strong Bear:
Histogram is negative, falling, and aligned with bearish zero-line bias.

Bear Hold:
Histogram remains negative but begins slowing.

Wait:
Momentum is mixed, neutral, or less clearly aligned.

These states are visual classifications only. They are not trading instructions.

────────────────────
Cross Markers

The script highlights two main crossover events:

Golden Cross:
The impulse line crosses above the signal line.

Dead Cross:
The impulse line crosses below the signal line.

Strong Golden Cross:
A golden cross occurs above the zero line.

Strong Dead Cross:
A dead cross occurs below the zero line.

The script estimates the visual cross location by interpolating between the previous bar and the current bar. This is intended to place the dot closer to the actual line intersection.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• Source
• Impulse length
• Signal length
• Release emphasis
• Release power
• Higher timeframe mode
• Zero-bias coloring
• Compression lookback
• Line visibility
• Histogram visibility
• Cross dots
• Strong cross pulse effect
• Last-bar label
• Status panel
• Marker size
• Colors

────────────────────
How To Use
────────────────────

Use this script as a momentum context tool.

General interpretation examples:

• Impulse line above signal line may show stronger upward momentum structure.
• Impulse line below signal line may show weaker or downward momentum structure.
• Histogram expansion may show increasing momentum pressure.
• Histogram slowdown may show weakening momentum pressure.
• Crosses above the zero line can be reviewed differently from crosses below the zero line.
• The status panel can help summarize the current oscillator state.

This script should be used with independent analysis, risk management, and a defined trading plan.

────────────────────
Confirmation And Repainting Notes
────────────────────

The oscillator is calculated from current and historical price data.

The script does not use future price data.

When higher timeframe mode is enabled, values are requested from the selected higher timeframe with lookahead disabled.

Cross markers are based on current bar crossover conditions. If users want confirmed readings, they should evaluate conditions after bar close.

The interpolated cross dots are visual aids and should be understood as approximate line-intersection markers.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

Oscillators can produce frequent crosses during sideways or low-volatility markets.

Momentum readings can lag or change while the current candle is still forming.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Impulse Momentum Oscillator

Impulse Momentum Oscillator는 임펄스 움직임, 시그널 라인과의 관계, 히스토그램 가속, 모멘텀 상태 변화를 시각적으로 확인하기 위한 모멘텀 기반 차트 분석 보조지표입니다.

이 스크립트는 스무딩된 고점/저점 채널, 제로랙 중간선, 시그널 라인, 히스토그램을 사용해 모멘텀이 어떻게 확장되고 둔화되며 교차하고 방향을 바꾸는지 관찰할 수 있도록 돕습니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다.
목적은 모멘텀 구조와 오실레이터 흐름을 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

이 스크립트는 임펄스형 오실레이터 구조를 기반으로 합니다.

단순히 두 이동평균을 비교하는 방식이 아니라, 먼저 스무딩된 고점/저점 채널을 만들고, 제로랙 중간선이 이 채널과 어떤 관계에 있는지를 확인합니다.

중간선이 스무딩된 고점 채널 위로 확장되면 임펄스 값은 양수 방향으로 움직입니다.

중간선이 스무딩된 저점 채널 아래로 확장되면 임펄스 값은 음수 방향으로 움직입니다.

임펄스 라인에서 시그널 라인을 계산하고, 두 선의 차이를 히스토그램으로 표시합니다.

이를 통해 다음 요소를 관찰할 수 있습니다.

• 모멘텀 확장
• 모멘텀 둔화
• 0선 기준 방향성
• 골든크로스와 데드크로스
• 0선 위/아래에서 발생하는 강한 교차 조건

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 임펄스 라인
• 시그널 라인
• 모멘텀 히스토그램
• 0선
• 골든크로스 / 데드크로스 점
• 강한 교차 펄스 효과
• 마지막 봉 상태 라벨
• 모멘텀 상태 패널
• 선택 가능한 교차 배경 강조

이 시각 요소들은 모멘텀 전환을 더 쉽게 복기하기 위한 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 스무딩된 고점 채널과 저점 채널을 계산합니다.
2. 선택한 소스에서 제로랙 중간선을 계산합니다.
3. 중간선이 고점 채널 위로 이동하면 임펄스 값은 양수로 계산됩니다.
4. 중간선이 저점 채널 아래로 이동하면 임펄스 값은 음수로 계산됩니다.
5. 중간선이 채널 안에 있으면 임펄스 값은 중립에 가깝게 유지됩니다.
6. 임펄스 라인에서 시그널 라인을 계산합니다.
7. 임펄스 라인과 시그널 라인의 차이를 히스토그램으로 계산합니다.
8. 선택에 따라 압축 이후 히스토그램 확장 구간을 시각적으로 강조합니다.
9. 교차 마커는 선의 실제 교차 위치에 더 가깝게 보이도록 보간 방식으로 표시됩니다.

────────────────────
모멘텀 상태
────────────────────

히스토그램은 다음 상태로 분류됩니다.

Strong Bull:
히스토그램이 양수이고 증가하며, 0선 기준 상승 방향과 정렬된 상태입니다.

Bull Hold:
히스토그램은 양수지만 상승 압력이 둔화되는 상태입니다.

Strong Bear:
히스토그램이 음수이고 하락하며, 0선 기준 하락 방향과 정렬된 상태입니다.

Bear Hold:
히스토그램은 음수지만 하락 압력이 둔화되는 상태입니다.

Wait:
모멘텀이 혼합, 중립, 또는 명확하지 않은 상태입니다.

이 상태 분류는 시각적 참고용이며 매매 지시가 아닙니다.

────────────────────
교차 마커
────────────────────

이 스크립트는 두 가지 주요 교차 이벤트를 표시합니다.

Golden Cross:
임펄스 라인이 시그널 라인을 상향 교차합니다.

Dead Cross:
임펄스 라인이 시그널 라인을 하향 교차합니다.

Strong Golden Cross:
0선 위에서 골든크로스가 발생합니다.

Strong Dead Cross:
0선 아래에서 데드크로스가 발생합니다.

스크립트는 이전 봉과 현재 봉 사이의 값을 보간하여 시각적 교차 위치를 계산합니다. 이는 점이 실제 선 교차 지점에 더 가깝게 표시되도록 하기 위한 시각적 보조 기능입니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• Source
• Impulse length
• Signal length
• Release emphasis
• Release power
• Higher timeframe mode
• Zero-bias coloring
• Compression lookback
• 라인 표시 여부
• 히스토그램 표시 여부
• 교차 점
• 강한 교차 펄스 효과
• 마지막 봉 라벨
• 상태 패널
• 마커 크기
• 색상

────────────────────
사용 방법
────────────────────

이 스크립트는 모멘텀 흐름을 확인하는 보조도구로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 임펄스 라인이 시그널 라인 위에 있으면 상승 모멘텀 구조가 상대적으로 강할 수 있습니다.
• 임펄스 라인이 시그널 라인 아래에 있으면 하락 또는 약한 모멘텀 구조일 수 있습니다.
• 히스토그램 확장은 모멘텀 압력 증가를 보여줄 수 있습니다.
• 히스토그램 둔화는 모멘텀 압력 약화를 보여줄 수 있습니다.
• 0선 위에서 발생한 교차와 0선 아래에서 발생한 교차는 서로 다르게 복기할 수 있습니다.
• 상태 패널은 현재 오실레이터 상태를 요약하는 데 도움을 줍니다.

이 스크립트는 독립적인 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 오실레이터는 현재 및 과거 가격 데이터를 기반으로 계산됩니다.

이 스크립트는 미래 가격 데이터를 사용하지 않습니다.

상위 시간봉 모드를 사용할 경우, lookahead 비활성 상태로 선택한 시간봉의 값을 가져옵니다.

교차 마커는 현재 봉의 교차 조건을 기준으로 표시됩니다. 확정 값을 원하는 사용자는 봉 마감 이후 기준으로 확인해야 합니다.

보간된 교차 점은 시각적 보조 기능이며, 선 교차 위치를 근사해 보여주는 참고 마커로 이해해야 합니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

오실레이터는 횡보장 또는 저변동성 구간에서 잦은 교차를 만들 수 있습니다.

현재 캔들이 완성되기 전에는 모멘텀 값이 변할 수 있습니다.

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
indicator("Impulse Momentum Oscillator", overlay=false, max_labels_count=500, max_bars_back=5000)

// Impulse Momentum Oscillator
// This script studies impulse-style momentum using a smoothed high/low channel,
// a zero-lag midpoint line, a signal line, and a histogram.
// It is intended for educational chart analysis and does not provide trade signals.

//────────────────────────────────────────────────────────────────────
// Groups
//────────────────────────────────────────────────────────────────────
groupCore = "Core Settings"
groupMTF = "Higher Timeframe"
groupFilter = "Momentum Filters"
groupDisplay = "Display Settings"
groupWidth = "Line Width"
groupMarker = "Cross Markers"
groupColor = "Colors"
groupPanel = "Status Panel"
groupAlerts = "Alerts"

//────────────────────────────────────────────────────────────────────
// Core inputs
//────────────────────────────────────────────────────────────────────
src = input.source(hlc3, "Source", group=groupCore)
impulseLength = input.int(26, "Impulse Length", minval=1, group=groupCore)
signalLength = input.int(7, "Signal Length", minval=1, group=groupCore)
useReleaseEmphasis = input.bool(true, "Use Release Emphasis", group=groupCore, tooltip="Adds visual emphasis to the histogram when momentum expands after compression.")
releasePower = input.float(0.35, "Release Emphasis Power", minval=0.0, maxval=2.0, step=0.05, group=groupCore)

//────────────────────────────────────────────────────────────────────
// Higher timeframe inputs
//────────────────────────────────────────────────────────────────────
useHigherTimeframe = input.bool(false, "Use Higher Timeframe", group=groupMTF)
higherTimeframe = input.timeframe("", "Higher Timeframe", group=groupMTF)

//────────────────────────────────────────────────────────────────────
// Filter inputs
//────────────────────────────────────────────────────────────────────
useZeroBiasColoring = input.bool(true, "Use Zero-Bias Coloring", group=groupFilter, tooltip="Histogram colors are filtered by whether the impulse line is above or below the zero line.")
compressionLength = input.int(20, "Compression Detection Lookback", minval=5, group=groupFilter)

//────────────────────────────────────────────────────────────────────
// Display inputs
//────────────────────────────────────────────────────────────────────
showImpulseLine = input.bool(true, "Show Impulse Line", group=groupDisplay)
showSignalLine = input.bool(true, "Show Signal Line", group=groupDisplay)
showHistogram = input.bool(true, "Show Histogram", group=groupDisplay)
showCrossDots = input.bool(true, "Show Cross Dots", group=groupDisplay)
showStrongPulse = input.bool(true, "Show Strong Cross Pulse", group=groupDisplay)
showLastBarLabel = input.bool(true, "Show Last-Bar Status Label", group=groupDisplay)
showSignalPanel = input.bool(true, "Show Signal Panel", group=groupDisplay)
showCrossBackground = input.bool(false, "Show Cross Background", group=groupDisplay)

//────────────────────────────────────────────────────────────────────
// Width inputs
//────────────────────────────────────────────────────────────────────
impulseWidth = input.int(2, "Impulse Line Width", minval=1, maxval=5, group=groupWidth)
signalWidth = input.int(2, "Signal Line Width", minval=1, maxval=5, group=groupWidth)
histogramWidth = input.int(3, "Histogram Width", minval=1, maxval=5, group=groupWidth)

//────────────────────────────────────────────────────────────────────
// Marker inputs
//────────────────────────────────────────────────────────────────────
maxCrossDots = input.int(1000, "Max Stored Cross Dots", minval=50, maxval=2000, group=groupMarker)
glowDotSizeInput = input.string("Normal", "Glow Dot Size", options=["Small", "Normal", "Large"], group=groupMarker)
coreDotSizeInput = input.string("Tiny", "Core Dot Size", options=["Tiny", "Small", "Normal"], group=groupMarker)

//────────────────────────────────────────────────────────────────────
// Color inputs
//────────────────────────────────────────────────────────────────────
colorStrongBull = input.color(#00E676, "Strong Bull Histogram", group=groupColor)
colorBullHold = input.color(#43A047, "Bull Hold Histogram", group=groupColor)
colorStrongBear = input.color(#F44336, "Strong Bear Histogram", group=groupColor)
colorBearHold = input.color(#8E2424, "Bear Hold Histogram", group=groupColor)
colorNeutralPositive = input.color(#26A69A, "Neutral Positive Histogram", group=groupColor)
colorNeutralNegative = input.color(#FF9800, "Neutral Negative Histogram", group=groupColor)
colorImpulseLine = input.color(#00BCD4, "Impulse Line", group=groupColor)
colorSignalLine = input.color(#FF9800, "Signal Line", group=groupColor)

//────────────────────────────────────────────────────────────────────
// Panel inputs
//────────────────────────────────────────────────────────────────────
panelPositionInput = input.string("Top Right", "Panel Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=groupPanel)

//────────────────────────────────────────────────────────────────────
// Alert inputs
//────────────────────────────────────────────────────────────────────
enableAlerts = input.bool(true, "Enable Alerts", group=groupAlerts)

//────────────────────────────────────────────────────────────────────
// Helper functions
//────────────────────────────────────────────────────────────────────
f_clamp01(float value) =>
    na(value) ? na : math.max(0.0, math.min(1.0, value))

f_zlema(series float source, int length) =>
    ema1 = ta.ema(source, length)
    ema2 = ta.ema(ema1, length)
    ema1 + (ema1 - ema2)

f_calcImpulse(series float source, int length, int sigLength) =>
    hiChannel = ta.rma(high, length)
    loChannel = ta.rma(low, length)
    midLine = f_zlema(source, length)
    impulse = midLine > hiChannel ? midLine - hiChannel : midLine < loChannel ? midLine - loChannel : 0.0
    signal = ta.sma(impulse, sigLength)
    histogram = impulse - signal
    [impulse, signal, histogram]

f_panelText(bool isActive, string label) =>
    isActive ? "▶ " + label + " ◀" : "  " + label

f_panelBg(color baseColor, bool isActive) =>
    isActive ? color.new(baseColor, 0) : color.new(baseColor, 78)

f_panelTextColor(bool isActive) =>
    isActive ? color.white : color.new(color.white, 20)

f_labelSize(string sizeText) =>
    sizeText == "Large" ? size.large : sizeText == "Normal" ? size.normal : sizeText == "Small" ? size.small : size.tiny

f_panelPosition(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Bottom Left" ? position.bottom_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.top_right

//────────────────────────────────────────────────────────────────────
// Engine
//────────────────────────────────────────────────────────────────────
[localImpulse, localSignal, localHistogram] = f_calcImpulse(src, impulseLength, signalLength)

[htfImpulse, htfSignal, htfHistogram] = request.security(
     syminfo.tickerid,
     higherTimeframe == "" ? timeframe.period : higherTimeframe,
     f_calcImpulse(src, impulseLength, signalLength),
     barmerge.gaps_off,
     barmerge.lookahead_off)

useHtfActive = useHigherTimeframe and higherTimeframe != ""

impulseLine = useHtfActive ? htfImpulse : localImpulse
signalLine = useHtfActive ? htfSignal : localSignal
histBase = useHtfActive ? htfHistogram : localHistogram

//────────────────────────────────────────────────────────────────────
// Release emphasis
//────────────────────────────────────────────────────────────────────
histAcceleration = histBase - nz(histBase[1])
compressionBase = ta.sma(math.abs(histBase), compressionLength)
inCompression = math.abs(histBase) <= nz(compressionBase) * 0.80

releaseUp = inCompression[1] and not inCompression and histBase > 0
releaseDown = inCompression[1] and not inCompression and histBase < 0

boostUp = useReleaseEmphasis and releaseUp ? releasePower * math.max(0.0, histAcceleration) : 0.0
boostDown = useReleaseEmphasis and releaseDown ? releasePower * math.min(0.0, histAcceleration) : 0.0

histogram = histBase + boostUp + boostDown

//────────────────────────────────────────────────────────────────────
// Histogram state
//────────────────────────────────────────────────────────────────────
histPrev = nz(histogram[1])
histPositive = histogram >= 0.0
histGrowing = histogram > histPrev
histFalling = histogram < histPrev

bullBias = not useZeroBiasColoring or impulseLine >= 0.0
bearBias = not useZeroBiasColoring or impulseLine <= 0.0

strongBullHist = histPositive and histGrowing and bullBias
bullHoldHist = histPositive and histFalling and bullBias
strongBearHist = not histPositive and histFalling and bearBias
bearHoldHist = not histPositive and histGrowing and bearBias

histColor =
     strongBullHist ? colorStrongBull :
     bullHoldHist ? colorBullHold :
     strongBearHist ? colorStrongBear :
     bearHoldHist ? colorBearHold :
     histPositive ? colorNeutralPositive : colorNeutralNegative

//────────────────────────────────────────────────────────────────────
// Cross conditions
//────────────────────────────────────────────────────────────────────
goldenCross = ta.crossover(impulseLine, signalLine)
deadCross = ta.crossunder(impulseLine, signalLine)

strongGoldenCross = goldenCross and impulseLine > 0.0
strongDeadCross = deadCross and impulseLine < 0.0

trendUp = impulseLine > signalLine
trendDown = impulseLine < signalLine

//────────────────────────────────────────────────────────────────────
// Cross point interpolation
//────────────────────────────────────────────────────────────────────
impulsePrev = impulseLine[1]
signalPrev = signalLine[1]

diffPrev = impulsePrev - signalPrev
diffNow = impulseLine - signalLine

denom = diffPrev - diffNow
rawCrossT = (goldenCross or deadCross) and not na(denom) and math.abs(denom) > 1e-10 ? diffPrev / denom : na
crossT = f_clamp01(rawCrossT)

interpImpulse = not na(crossT) ? impulsePrev + (impulseLine - impulsePrev) * crossT : na
crossY = (goldenCross or deadCross) and not na(interpImpulse) ? interpImpulse : na

barTimeDelta = time - nz(time[1], time)
crossTime = (goldenCross or deadCross) and not na(crossT) and not na(time[1]) ? int(time - math.round(barTimeDelta * (1.0 - crossT))) : time

//────────────────────────────────────────────────────────────────────
// Plots
//────────────────────────────────────────────────────────────────────
hline(0, "Zero Line", color=color.gray)

plot(showHistogram ? histogram : na, style=plot.style_columns, color=histColor, linewidth=histogramWidth, title="Momentum Histogram")
plot(showImpulseLine ? impulseLine : na, color=trendUp ? colorImpulseLine : color.gray, linewidth=impulseWidth, title="Impulse Line")
plot(showSignalLine ? signalLine : na, color=colorSignalLine, linewidth=signalWidth, title="Signal Line")

plot(showStrongPulse and strongGoldenCross ? crossY : na, style=plot.style_circles, linewidth=10, color=color.new(colorStrongBull, 60), title="Strong Golden Cross Pulse")
plot(showStrongPulse and strongDeadCross ? crossY : na, style=plot.style_circles, linewidth=10, color=color.new(colorStrongBear, 60), title="Strong Dead Cross Pulse")

//────────────────────────────────────────────────────────────────────
// Precise cross dots
//────────────────────────────────────────────────────────────────────
var array<label> crossDots = array.new_label()

if showCrossDots
    if goldenCross and not na(crossY)
        glowBull = label.new(x=crossTime, y=crossY, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_circle, text="", color=color.new(colorStrongBull, 78), size=f_labelSize(glowDotSizeInput), textcolor=color.white)
        coreBull = label.new(x=crossTime, y=crossY, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_circle, text="", color=colorStrongBull, size=f_labelSize(coreDotSizeInput), textcolor=color.white)
        array.push(crossDots, glowBull)
        array.push(crossDots, coreBull)

    if deadCross and not na(crossY)
        glowBear = label.new(x=crossTime, y=crossY, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_circle, text="", color=color.new(colorStrongBear, 78), size=f_labelSize(glowDotSizeInput), textcolor=color.white)
        coreBear = label.new(x=crossTime, y=crossY, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_circle, text="", color=colorStrongBear, size=f_labelSize(coreDotSizeInput), textcolor=color.white)
        array.push(crossDots, glowBear)
        array.push(crossDots, coreBear)

    while array.size(crossDots) > maxCrossDots * 2
        oldDot = array.shift(crossDots)
        label.delete(oldDot)

//────────────────────────────────────────────────────────────────────
// Background
//────────────────────────────────────────────────────────────────────
bgcolor(showCrossBackground and goldenCross ? color.new(colorStrongBull, 88) : na)
bgcolor(showCrossBackground and deadCross ? color.new(colorStrongBear, 88) : na)

//────────────────────────────────────────────────────────────────────
// Status state
//────────────────────────────────────────────────────────────────────
signalState =
     strongBullHist ? 1 :
     bullHoldHist ? 2 :
     (strongBearHist or bearHoldHist) ? 3 :
     4

statusText =
     strongGoldenCross ? "Strong Golden Cross" :
     strongDeadCross ? "Strong Dead Cross" :
     goldenCross ? "Golden Cross" :
     deadCross ? "Dead Cross" :
     strongBullHist ? "Strong Bull" :
     bullHoldHist ? "Bull Hold" :
     strongBearHist ? "Strong Bear" :
     bearHoldHist ? "Bear Hold" :
     histPositive ? "Neutral +" : "Neutral -"

statusColor =
     strongGoldenCross ? colorStrongBull :
     strongDeadCross ? colorStrongBear :
     goldenCross ? colorStrongBull :
     deadCross ? colorStrongBear :
     histColor

//────────────────────────────────────────────────────────────────────
// Last-bar label
//────────────────────────────────────────────────────────────────────
var label lastStatusLabel = na

if barstate.islast
    if not na(lastStatusLabel)
        label.delete(lastStatusLabel)
    if showLastBarLabel
        lastStatusLabel := label.new(bar_index + 1, histogram, statusText, style=label.style_label_left, color=statusColor, textcolor=color.white, size=size.normal)

//────────────────────────────────────────────────────────────────────
// Signal panel
//────────────────────────────────────────────────────────────────────
var table signalPanel = table.new(f_panelPosition(panelPositionInput), 1, 5, border_width=1)

if barstate.islast
    if showSignalPanel
        table.cell(signalPanel, 0, 0, "Momentum State", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
        table.cell(signalPanel, 0, 1, f_panelText(signalState == 1, "Strong Bull"), text_color=f_panelTextColor(signalState == 1), text_size=size.small, bgcolor=f_panelBg(colorStrongBull, signalState == 1))
        table.cell(signalPanel, 0, 2, f_panelText(signalState == 2, "Bull Hold"), text_color=f_panelTextColor(signalState == 2), text_size=size.small, bgcolor=f_panelBg(colorBullHold, signalState == 2))
        table.cell(signalPanel, 0, 3, f_panelText(signalState == 3, "Bear"), text_color=f_panelTextColor(signalState == 3), text_size=size.small, bgcolor=f_panelBg(colorStrongBear, signalState == 3))
        table.cell(signalPanel, 0, 4, f_panelText(signalState == 4, "Wait"), text_color=f_panelTextColor(signalState == 4), text_size=size.small, bgcolor=f_panelBg(histPositive ? colorNeutralPositive : colorNeutralNegative, signalState == 4))
    else
        for row = 0 to 4
            table.cell(signalPanel, 0, row, "", bgcolor=color.new(color.black, 100))

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
alertcondition(enableAlerts and goldenCross, "Golden Cross", "Impulse line crossed above the signal line.")
alertcondition(enableAlerts and deadCross, "Dead Cross", "Impulse line crossed below the signal line.")
alertcondition(enableAlerts and strongGoldenCross, "Strong Golden Cross", "Impulse line crossed above the signal line while above the zero line.")
alertcondition(enableAlerts and strongDeadCross, "Strong Dead Cross", "Impulse line crossed below the signal line while below the zero line.")
````
