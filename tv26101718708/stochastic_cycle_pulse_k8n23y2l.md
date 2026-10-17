# Stochastic Cycle Pulse

- url: https://www.tradingview.com/script/k8N23Y2L-Stochastic-Cycle-Pulse/
- type: indicator
- pine_id: PUB;06a0dd91e9d641fa9d3b8ca034a90257
- version: 1.0

## Description

Stochastic Cycle Pulse

Stochastic Cycle Pulse is a momentum-cycle oscillator based on the classic Stochastic Oscillator. It is designed to show where price is positioned inside its recent high-low range, while also tracking overbought / oversold cycles, %K / %D crossover behavior, and trend-context conditions.

The script calculates a smoothed %K and %D line, highlights the 80 / 20 reference zones, and adds a simple cycle-state system that helps users review when stochastic momentum moves from oversold recovery toward overbought exhaustion.

It does not provide buy or sell recommendations. The purpose of this script is to help users study stochastic momentum cycles, overbought and oversold behavior, crossover timing, and trend-context alignment.

────────────────────
Core Concept
────────────────────

The Stochastic Oscillator is based on the idea that momentum can be evaluated by comparing the current close to the recent high-low range.

When the oscillator is near the upper part of the range, price is closing closer to recent highs.

When the oscillator is near the lower part of the range, price is closing closer to recent lows.

This script focuses on four stochastic-cycle concepts:

• Overbought and oversold zone recognition
• %K and %D crossover behavior
• Momentum-cycle recovery after oversold conditions
• Potential cycle exhaustion after the upper zone is reached

A bullish cycle event can appear when %K crosses above %D from the oversold zone.

A bearish cycle event can appear when %K crosses below %D after the oscillator has reached the upper zone.

The script also includes trend-context filtering so users can review whether stochastic events are occurring with or against the broader chart direction.

────────────────────
What This Script Shows
────────────────────

The script can display:

• Smoothed %K line
• Smoothed %D line
• Overbought reference zone
• Oversold reference zone
• Midline reference
• Bullish cycle markers
• Bullish cycle refresh markers
• Bearish cycle markers
• Optional raw %K / %D crossover markers
• Trend-context background
• Status table with stochastic, zone, cycle, context, and ADX information

These elements are intended to make stochastic cycle movement easier to review on the chart.

────────────────────
How It Works
────────────────────

1. The script calculates the Stochastic %K value from the selected high-low range.
2. %K is smoothed using the selected smoothing length.
3. %D is calculated as a moving average of the smoothed %K.
4. The oscillator is compared against the overbought, oversold, and midline levels.
5. The script detects %K / %D bullish and bearish crossovers.
6. A cycle-state system checks whether a bullish crossover occurs from the oversold zone.
7. After a bullish cycle begins, the script waits for the oscillator to reach the upper zone.
8. After the upper zone is reached, a bearish crossover can mark a cycle-down event.
9. Optional refresh logic can mark another bullish crossover if the oscillator remains near the oversold region.
10. EMA and ADX / DMI context can be used to identify whether the broader trend is strong upward, strong downward, or mixed.
11. Optional counter-trend blocking can reduce signals that occur against a strong directional trend.
12. A status table summarizes the current stochastic value, zone, cycle state, trend context, and ADX value.

────────────────────
Visual Elements
────────────────────

The script includes:

• %K line
• %D line
• Overbought zone
• Oversold zone
• Midline
• Bullish cycle dot
• Bullish refresh dot
• Bearish cycle dot
• Optional raw crossover dot
• K / D momentum fill
• Trend-context background
• Status table

The bullish cycle dot is used to highlight a stochastic recovery attempt from the oversold zone.

The bearish cycle dot is used to highlight a potential cycle-down event after the oscillator has already reached the upper zone.

The refresh dot is used when another bullish crossover appears while the oscillator is still near the lower cycle region.

The background context helps users distinguish whether the broader price environment is upward, downward, or mixed.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• %K Length
• %K Smoothing
• %D Smoothing
• Overbought level
• Oversold level
• Midline
• Cycle state machine behavior
• GC refresh behavior
• DC confirmation rules
• Cycle timeout length
• EMA context lengths
• ADX and DMI settings
• Counter-trend blocking
• Minimum K / D gap after cross
• Slope-turn requirement
• Raw crossover visibility
• Main line visibility
• Momentum fill visibility
• Zone visibility
• Cycle signal visibility
• Context background visibility
• Status table visibility
• Line, zone, marker, and table colors

The default settings use the common 14 / 3 / 3 stochastic structure with 80 / 20 reference levels, while adding cycle-state logic to reduce random crossover interpretation.

────────────────────
Reference Markers
────────────────────

The script includes several reference markers.

Bullish Cycle Marker:
Shows when %K crosses above %D from the oversold zone and the cycle-state conditions are satisfied.

Bullish Refresh Marker:
Shows when another bullish crossover occurs while the oscillator remains near the lower cycle region.

Bearish Cycle Marker:
Shows when %K crosses below %D after the oscillator has already reached the upper zone.

Raw Crossover Marker:
Optional marker showing basic %K / %D crosses without the full cycle-state filter.

Overbought Zone:
Shows when the stochastic value is near the upper part of its recent range.

Oversold Zone:
Shows when the stochastic value is near the lower part of its recent range.

Status Table:
Displays the current stochastic value, zone, cycle state, context, and ADX reading.

These markers are not trading signals. They are visual reference points for studying stochastic momentum, cycle recovery, and possible exhaustion behavior.

────────────────────
How To Use
────────────────────

Use this script as a stochastic momentum-cycle viewer.

General interpretation examples:

• A bullish cycle marker can help users review where stochastic momentum begins to recover from the oversold zone.
• A bullish refresh marker can help users identify repeated recovery attempts near the lower cycle area.
• A bearish cycle marker can help users review where stochastic momentum weakens after reaching the upper zone.
• The overbought zone can help users identify when price is closing near the upper part of its recent range.
• The oversold zone can help users identify when price is closing near the lower part of its recent range.
• The trend-context background can help users review whether oscillator signals are aligned with the broader trend environment.
• The status table can be used to quickly check the current stochastic zone, cycle state, and ADX context.

This script is best reviewed together with price action, trend structure, support and resistance, volatility, and higher-timeframe context.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script calculates stochastic values from the current high-low range and closing price.

Signals can change while the current candle is still forming because %K, %D, crossover conditions, and zone status can change before candle close.

For more conservative analysis, users should evaluate cycle markers after candle confirmation.

The script does not use future price data to predict upcoming price movement.

Because this script is based on oscillator behavior, signals may appear before, during, or after visible price turning points depending on market speed and volatility.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

Overbought does not always mean price must fall.

Oversold does not always mean price must rise.

In strong trends, the stochastic oscillator can remain overbought or oversold for extended periods.

Crossover markers can become noisy in sideways markets, low-volatility ranges, or unstable news-driven conditions.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Stochastic Cycle Pulse

Stochastic Cycle Pulse는 고전적인 Stochastic Oscillator를 기반으로 한 모멘텀 사이클 보조지표입니다. 가격이 최근 고가-저가 범위 안에서 어느 위치에 있는지 보여주면서, 과매수 / 과매도 사이클, %K / %D 교차 행동, 추세 컨텍스트를 함께 추적하도록 설계되었습니다.

이 스크립트는 smoothing 처리된 %K와 %D 라인을 계산하고, 80 / 20 기준 구간을 표시하며, 스토캐스틱 모멘텀이 과매도 회복 구간에서 과매수 소진 구간으로 이동하는 과정을 복기할 수 있도록 간단한 사이클 상태 시스템을 추가합니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다. 목적은 스토캐스틱 모멘텀 사이클, 과매수와 과매도 행동, 교차 타이밍, 추세 컨텍스트 정렬을 관찰하는 것입니다.

────────────────────
핵심 개념
────────────────────

Stochastic Oscillator는 현재 종가가 최근 고가-저가 범위 안에서 어느 위치에 있는지를 비교해 모멘텀을 평가할 수 있다는 개념을 기반으로 합니다.

오실레이터가 상단 범위에 가까울수록 가격이 최근 고점에 가깝게 마감되고 있음을 의미합니다.

오실레이터가 하단 범위에 가까울수록 가격이 최근 저점에 가깝게 마감되고 있음을 의미합니다.

이 스크립트는 네 가지 스토캐스틱 사이클 개념에 초점을 둡니다.

• 과매수 및 과매도 구간 인식
• %K와 %D 교차 행동
• 과매도 이후 모멘텀 회복 사이클
• 상단 구간 도달 이후 잠재적인 사이클 소진

%K가 과매도 구간에서 %D를 상향 돌파하면 상승 사이클 이벤트가 나타날 수 있습니다.

오실레이터가 상단 구간에 도달한 뒤 %K가 %D를 하향 돌파하면 하락 사이클 이벤트가 나타날 수 있습니다.

또한 이 스크립트는 추세 컨텍스트 필터를 포함해, 스토캐스틱 이벤트가 더 넓은 차트 방향성과 일치하는지 또는 반대되는지 확인할 수 있도록 돕습니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• Smoothed %K line
• Smoothed %D line
• 과매수 기준 구간
• 과매도 기준 구간
• 중앙선 기준
• 상승 사이클 마커
• 상승 사이클 refresh 마커
• 하락 사이클 마커
• 선택 가능한 기본 %K / %D 교차 마커
• 추세 컨텍스트 배경
• Stochastic, Zone, Cycle, Context, ADX 정보를 포함한 상태 테이블

이 요소들은 차트에서 스토캐스틱 사이클 움직임을 더 쉽게 복기하기 위한 시각적 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 선택한 고가-저가 범위를 기준으로 Stochastic %K 값을 계산합니다.
2. 선택한 smoothing 길이로 %K를 부드럽게 처리합니다.
3. %D는 smoothing 처리된 %K의 이동평균으로 계산됩니다.
4. 오실레이터를 과매수, 과매도, 중앙선 레벨과 비교합니다.
5. %K / %D의 상승 및 하락 교차를 감지합니다.
6. 사이클 상태 시스템은 과매도 구간에서 상승 교차가 발생했는지 확인합니다.
7. 상승 사이클이 시작되면, 오실레이터가 상단 구간에 도달하는지 기다립니다.
8. 상단 구간 도달 이후 하락 교차가 발생하면 cycle-down 이벤트로 표시할 수 있습니다.
9. 선택 가능한 refresh 로직은 오실레이터가 여전히 하단 사이클 영역 근처에 있을 때 또 다른 상승 교차를 표시할 수 있습니다.
10. EMA와 ADX / DMI 컨텍스트를 사용해 더 넓은 추세가 강한 상승, 강한 하락, 혼합 상태인지 확인할 수 있습니다.
11. 선택 가능한 counter-trend blocking은 강한 방향성 추세에 반대되는 신호를 줄이는 데 사용할 수 있습니다.
12. 상태 테이블은 현재 stochastic 값, zone, cycle state, trend context, ADX 값을 요약합니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• %K line
• %D line
• Overbought zone
• Oversold zone
• Midline
• Bullish cycle dot
• Bullish refresh dot
• Bearish cycle dot
• Optional raw crossover dot
• K / D momentum fill
• Trend-context background
• Status table

상승 사이클 도트는 과매도 구간에서 스토캐스틱 모멘텀이 회복을 시도하는 위치를 강조하는 데 사용됩니다.

하락 사이클 도트는 오실레이터가 이미 상단 구간에 도달한 이후 잠재적인 cycle-down 이벤트를 강조하는 데 사용됩니다.

Refresh 도트는 오실레이터가 여전히 하단 사이클 영역 근처에 있을 때 또 다른 상승 교차가 나타나는 경우를 표시합니다.

배경 컨텍스트는 더 넓은 가격 환경이 상승, 하락, 혼합 중 어디에 가까운지 구분하는 데 도움을 줍니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• %K Length
• %K Smoothing
• %D Smoothing
• Overbought level
• Oversold level
• Midline
• Cycle state machine behavior
• GC refresh behavior
• DC confirmation rules
• Cycle timeout length
• EMA context lengths
• ADX and DMI settings
• Counter-trend blocking
• Minimum K / D gap after cross
• Slope-turn requirement
• Raw crossover visibility
• Main line visibility
• Momentum fill visibility
• Zone visibility
• Cycle signal visibility
• Context background visibility
• Status table visibility
• Line, zone, marker, and table colors

기본 설정은 일반적인 14 / 3 / 3 스토캐스틱 구조와 80 / 20 기준선을 사용하며, 무작위 교차 해석을 줄이기 위해 사이클 상태 로직을 추가한 형태입니다.

────────────────────
참고 마커
────────────────────

이 스크립트에는 여러 참고 마커가 포함되어 있습니다.

Bullish Cycle Marker:
%K가 과매도 구간에서 %D를 상향 돌파하고 사이클 상태 조건을 만족할 때 표시됩니다.

Bullish Refresh Marker:
오실레이터가 여전히 하단 사이클 영역 근처에 있을 때 또 다른 상승 교차가 발생하면 표시됩니다.

Bearish Cycle Marker:
오실레이터가 이미 상단 구간에 도달한 이후 %K가 %D를 하향 돌파하면 표시됩니다.

Raw Crossover Marker:
전체 사이클 상태 필터 없이 기본 %K / %D 교차를 보여주는 선택형 마커입니다.

Overbought Zone:
스토캐스틱 값이 최근 범위의 상단부에 가까운 구간을 표시합니다.

Oversold Zone:
스토캐스틱 값이 최근 범위의 하단부에 가까운 구간을 표시합니다.

Status Table:
현재 stochastic 값, zone, cycle state, context, ADX 값을 표시합니다.

이 마커들은 매매 신호가 아닙니다. 스토캐스틱 모멘텀, 사이클 회복, 잠재적인 소진 행동을 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 스토캐스틱 모멘텀 사이클 확인용 보조지표로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 상승 사이클 마커는 과매도 구간에서 스토캐스틱 모멘텀이 회복되기 시작한 위치를 복기하는 데 사용할 수 있습니다.
• 상승 refresh 마커는 하단 사이클 영역 근처에서 반복적인 회복 시도가 나타나는지 확인하는 데 도움을 줄 수 있습니다.
• 하락 사이클 마커는 상단 구간 도달 이후 스토캐스틱 모멘텀이 약화되는 위치를 복기하는 데 사용할 수 있습니다.
• 과매수 구간은 가격이 최근 범위의 상단부에 가깝게 마감되는 상태를 확인하는 데 사용할 수 있습니다.
• 과매도 구간은 가격이 최근 범위의 하단부에 가깝게 마감되는 상태를 확인하는 데 사용할 수 있습니다.
• 추세 컨텍스트 배경은 오실레이터 신호가 더 넓은 추세 환경과 일치하는지 확인하는 데 도움을 줄 수 있습니다.
• 상태 테이블은 현재 stochastic zone, cycle state, ADX context를 빠르게 확인하는 데 사용할 수 있습니다.

이 스크립트는 가격 행동, 추세 구조, 지지와 저항, 변동성, 상위 시간대 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 현재 고가-저가 범위와 종가를 기준으로 stochastic 값을 계산합니다.

현재 캔들이 형성되는 동안에는 %K, %D, 교차 조건, zone 상태가 변할 수 있으므로 신호가 달라질 수 있습니다.

보다 보수적인 분석을 원하는 사용자는 봉 마감 이후 사이클 마커를 확인하는 것이 적절합니다.

이 스크립트는 향후 가격 움직임을 예측하기 위해 미래 가격 데이터를 사용하지 않습니다.

오실레이터 기반 스크립트이기 때문에 시장 속도와 변동성에 따라 신호가 눈에 보이는 가격 전환점보다 빠르거나, 전환 중간에 나오거나, 일부 늦게 표시될 수 있습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

과매수는 가격이 반드시 하락한다는 뜻이 아닙니다.

과매도는 가격이 반드시 상승한다는 뜻이 아닙니다.

강한 추세에서는 Stochastic Oscillator가 장시간 과매수 또는 과매도 상태에 머무를 수 있습니다.

횡보장, 저변동성 구간, 뉴스성 급변 구간에서는 교차 마커가 노이즈처럼 많이 발생할 수 있습니다.

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
indicator(title="Stochastic Cycle Pulse", shorttitle="StochPulse", format=format.price, precision=2, max_labels_count=50)

//============================================================================
// Inputs
//============================================================================
groupCalc = "① Stochastic Calculation"
periodK = input.int(14, title="%K Length", minval=1, group=groupCalc)
smoothK = input.int(3, title="%K Smoothing", minval=1, group=groupCalc)
periodD = input.int(3, title="%D Smoothing", minval=1, group=groupCalc)

groupLevels = "② Reference Levels"
upperBand = input.int(80, title="Overbought Level", minval=51, maxval=99, group=groupLevels)
midBand = input.int(50, title="Midline", minval=1, maxval=99, group=groupLevels)
lowerBand = input.int(20, title="Oversold Level", minval=1, maxval=49, group=groupLevels)

groupCycle = "③ Cycle Logic"
useCycleMachine = input.bool(true, title="Use Cycle State Machine", group=groupCycle)
allowGcRefresh = input.bool(true, title="Refresh GC While Still Oversold", group=groupCycle)
dcAfterUpperOnly = input.bool(true, title="DC Requires Prior Upper Zone Visit", group=groupCycle)
allowDcAboveUpper = input.bool(true, title="Allow DC While Still Above Upper Zone", group=groupCycle)
cycleResetBars = input.int(80, title="Cycle Timeout Bars", minval=10, maxval=500, group=groupCycle)

groupContext = "④ Context Filter"
useContextFilter = input.bool(true, title="Use Trend Context Filter", group=groupContext)
emaFastLen = input.int(21, title="Fast EMA Length", minval=1, maxval=300, group=groupContext)
emaSlowLen = input.int(55, title="Slow EMA Length", minval=2, maxval=500, group=groupContext)
adxLen = input.int(14, title="ADX Length", minval=1, maxval=50, group=groupContext)
adxSmooth = input.int(14, title="ADX Smoothing", minval=1, maxval=50, group=groupContext)
strongAdx = input.float(25.0, title="Strong Trend ADX", minval=5.0, maxval=80.0, step=0.5, group=groupContext)
blockCounterTrend = input.bool(false, title="Block Counter-Trend Cycle Signals", group=groupContext)

groupQuality = "⑤ Signal Quality"
minCrossGap = input.float(0.20, title="Minimum K/D Gap After Cross", minval=0.0, maxval=20.0, step=0.05, group=groupQuality)
requireSlopeTurn = input.bool(true, title="Require K Slope Turn", group=groupQuality)
showRawCrosses = input.bool(false, title="Show Raw K/D Crosses", group=groupQuality)

groupDisplay = "⑥ Display"
showMainLines = input.bool(true, title="Show %K / %D Lines", group=groupDisplay)
showFillBetween = input.bool(true, title="Show K/D Momentum Fill", group=groupDisplay)
showZones = input.bool(true, title="Show Overbought / Oversold Zones", group=groupDisplay)
showCycleSignals = input.bool(true, title="Show Cycle Signals", group=groupDisplay)
showContextBars = input.bool(true, title="Show Context Background", group=groupDisplay)
showStatusTable = input.bool(true, title="Show Status Table", group=groupDisplay)

groupStyle = "⑦ Style"
colorK = input.color(color.rgb(0, 229, 255), title="%K Color", group=groupStyle)
colorD = input.color(color.rgb(255, 179, 0), title="%D Color", group=groupStyle)
colorUpper = input.color(color.rgb(255, 23, 68), title="Upper Level Color", group=groupStyle)
colorLower = input.color(color.rgb(0, 230, 118), title="Lower Level Color", group=groupStyle)
colorMid = input.color(color.rgb(120, 130, 140), title="Midline Color", group=groupStyle)
colorBull = input.color(color.rgb(118, 255, 3), title="Bullish Cycle Color", group=groupStyle)
colorBear = input.color(color.rgb(255, 61, 0), title="Bearish Cycle Color", group=groupStyle)
colorRaw = input.color(color.rgb(160, 160, 160), title="Raw Cross Color", group=groupStyle)
tableBg = input.color(color.new(color.black, 20), title="Table Background", group=groupStyle)
tableText = input.color(color.white, title="Table Text", group=groupStyle)

//============================================================================
// Calculations
//============================================================================
kRaw = ta.stoch(close, high, low, periodK)
k = ta.sma(kRaw, smoothK)
d = ta.sma(k, periodD)

rawGc = ta.crossover(k, d)
rawDc = ta.crossunder(k, d)

kSlopeUp = k > nz(k[1], k)
kSlopeDown = k < nz(k[1], k)

crossGap = math.abs(k - d)

inOversold = k <= lowerBand
inOverbought = k >= upperBand
inNeutral = not inOversold and not inOverbought

gcQualityOk = crossGap >= minCrossGap and (not requireSlopeTurn or kSlopeUp)
dcQualityOk = crossGap >= minCrossGap and (not requireSlopeTurn or kSlopeDown)

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxSmooth)

trendUp = emaFast > emaSlow and diPlus >= diMinus
trendDown = emaFast < emaSlow and diMinus >= diPlus
strongTrend = adxValue >= strongAdx

bullContextOk = not useContextFilter or not blockCounterTrend or not (trendDown and strongTrend)
bearContextOk = not useContextFilter or not blockCounterTrend or not (trendUp and strongTrend)

rawGcSignal = rawGc and gcQualityOk
rawDcSignal = rawDc and dcQualityOk

//============================================================================
// Cycle State Machine
// 0 = Waiting for oversold GC
// 1 = GC detected, waiting for upper zone
// 2 = Upper zone reached, waiting for DC
//============================================================================
var int cycleState = 0
var int cycleStartBar = na
var int upperTouchBar = na

cycleAge = not na(cycleStartBar) ? bar_index - cycleStartBar : na
cycleTimedOut = useCycleMachine and not na(cycleAge) and cycleAge > cycleResetBars

signalGc = false
signalDc = false
signalGcRefresh = false

if cycleTimedOut
    cycleState := 0
    cycleStartBar := na
    upperTouchBar := na

if not useCycleMachine
    signalGc := rawGcSignal and inOversold and bullContextOk
    signalDc := rawDcSignal and inOverbought and bearContextOk
else
    canStartGc = cycleState == 0 and rawGcSignal and inOversold and bullContextOk
    canRefreshGc = allowGcRefresh and cycleState == 1 and rawGcSignal and inOversold and bullContextOk

    if canStartGc
        signalGc := true
        cycleState := 1
        cycleStartBar := bar_index
        upperTouchBar := na

    if canRefreshGc
        signalGcRefresh := true
        cycleState := 1
        cycleStartBar := bar_index
        upperTouchBar := na

    if cycleState == 1 and k >= upperBand
        cycleState := 2
        upperTouchBar := bar_index

    dcAllowedByZone = dcAfterUpperOnly ? cycleState == 2 : true
    dcAllowedByLocation = allowDcAboveUpper ? true : k < upperBand

    if dcAllowedByZone and dcAllowedByLocation and rawDcSignal and bearContextOk
        signalDc := true
        cycleState := 0
        cycleStartBar := na
        upperTouchBar := na

//============================================================================
// Plot Lines / Zones
//============================================================================
plotK = plot(showMainLines ? k : na, title="%K", color=colorK, linewidth=2)
plotD = plot(showMainLines ? d : na, title="%D", color=colorD, linewidth=2)

hUpper = hline(upperBand, title="Overbought", color=colorUpper, linestyle=hline.style_dashed, linewidth=1)
hMid = hline(midBand, title="Midline", color=color.new(colorMid, 30), linestyle=hline.style_dotted, linewidth=1)
hLower = hline(lowerBand, title="Oversold", color=colorLower, linestyle=hline.style_dashed, linewidth=1)

hTop = hline(100, title="Top", display=display.none)
hBottom = hline(0, title="Bottom", display=display.none)

fill(hUpper, hTop, color=showZones ? color.new(colorUpper, 88) : na, title="Overbought Zone")
fill(hLower, hBottom, color=showZones ? color.new(colorLower, 88) : na, title="Oversold Zone")

kdFillColor = k >= d ? color.new(colorBull, 92) : color.new(colorBear, 92)
fill(plotK, plotD, color=showFillBetween ? kdFillColor : na, title="K/D Momentum Fill")

//============================================================================
// Context Background
//============================================================================
contextColor =
     not showContextBars ? na :
     trendUp and strongTrend ? color.new(colorBull, 92) :
     trendDown and strongTrend ? color.new(colorBear, 92) :
     color.new(colorMid, 96)

bgcolor(contextColor, title="Trend Context Background")

//============================================================================
// Signal Markers
//============================================================================
plotshape(showRawCrosses and rawGcSignal ? d : na, title="Raw GC", style=shape.circle, location=location.absolute, color=color.new(colorRaw, 20), size=size.tiny)
plotshape(showRawCrosses and rawDcSignal ? d : na, title="Raw DC", style=shape.circle, location=location.absolute, color=color.new(colorRaw, 20), size=size.tiny)

plotshape(showCycleSignals and signalGc ? d : na, title="Cycle GC", style=shape.circle, location=location.absolute, color=colorBull, size=size.normal)
plotshape(showCycleSignals and signalGcRefresh ? d : na, title="Cycle GC Refresh", style=shape.circle, location=location.absolute, color=color.new(colorBull, 0), size=size.small)
plotshape(showCycleSignals and signalDc ? d : na, title="Cycle DC", style=shape.circle, location=location.absolute, color=colorBear, size=size.normal)

bgcolor(showCycleSignals and signalGc ? color.new(colorBull, 76) : na, title="Cycle GC Background")
bgcolor(showCycleSignals and signalGcRefresh ? color.new(colorBull, 84) : na, title="Cycle GC Refresh Background")
bgcolor(showCycleSignals and signalDc ? color.new(colorBear, 76) : na, title="Cycle DC Background")

//============================================================================
// Status Table
//============================================================================
stateText =
     cycleState == 0 ? "Waiting GC" :
     cycleState == 1 ? "GC Active" :
     "Upper Reached"

zoneText =
     inOversold ? "Oversold" :
     inOverbought ? "Overbought" :
     "Neutral"

contextText =
     trendUp and strongTrend ? "Strong Up" :
     trendDown and strongTrend ? "Strong Down" :
     trendUp ? "Up Bias" :
     trendDown ? "Down Bias" :
     "Mixed"

var table statusTable = table.new(position.top_right, 2, 5, border_width=1)

if showStatusTable and barstate.islast
    table.cell(statusTable, 0, 0, "Stochastic", text_color=tableText, bgcolor=tableBg)
    table.cell(statusTable, 1, 0, str.tostring(k, "#.##") + " / " + str.tostring(d, "#.##"), text_color=tableText, bgcolor=tableBg)

    table.cell(statusTable, 0, 1, "Zone", text_color=tableText, bgcolor=tableBg)
    table.cell(statusTable, 1, 1, zoneText, text_color=inOversold ? colorLower : inOverbought ? colorUpper : tableText, bgcolor=tableBg)

    table.cell(statusTable, 0, 2, "Cycle", text_color=tableText, bgcolor=tableBg)
    table.cell(statusTable, 1, 2, stateText, text_color=tableText, bgcolor=tableBg)

    table.cell(statusTable, 0, 3, "Context", text_color=tableText, bgcolor=tableBg)
    table.cell(statusTable, 1, 3, contextText, text_color=trendUp ? colorBull : trendDown ? colorBear : tableText, bgcolor=tableBg)

    table.cell(statusTable, 0, 4, "ADX", text_color=tableText, bgcolor=tableBg)
    table.cell(statusTable, 1, 4, str.tostring(adxValue, "#.##"), text_color=tableText, bgcolor=tableBg)

if not showStatusTable and barstate.islast
    table.clear(statusTable, 0, 0, 1, 4)

//============================================================================
// Alerts
//============================================================================
alertcondition(signalGc, title="Cycle GC", message="Stochastic cycle GC detected in the oversold zone.")
alertcondition(signalGcRefresh, title="Cycle GC Refresh", message="Stochastic cycle GC refreshed while still in the oversold zone.")
alertcondition(signalDc, title="Cycle DC", message="Stochastic cycle DC detected after the upper zone was reached.")
alertcondition(rawGcSignal, title="Raw Stochastic GC", message="Raw stochastic %K/%D bullish crossover detected.")
alertcondition(rawDcSignal, title="Raw Stochastic DC", message="Raw stochastic %K/%D bearish crossover detected.")
````
