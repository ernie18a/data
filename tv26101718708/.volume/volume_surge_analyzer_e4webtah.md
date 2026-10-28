# Volume Surge Analyzer

- url: https://www.tradingview.com/script/e4WeBtah-Volume-Surge-Analyzer/
- type: indicator
- pine_id: PUB;0c1889a0f91d468687f6e3111a5b8049
- version: 1.0

## Description

Volume Surge Analyzer

Volume Surge Analyzer is a volume-based chart study designed to help users observe relative volume expansion, volume acceleration, candle pressure, and buy/sell pressure balance.

The script highlights normal volume activity, stronger volume burst conditions, high-RVOL warning areas, and a special gold-highlighted volume start condition after a quieter volume phase.

It does not provide buy or sell recommendations. The purpose of this script is to help users study how volume expands and how candle structure may reflect relative buy or sell pressure.

────────────────────
Core Concept
────────────────────

Volume expansion can provide useful context when studying price movement.

This script does not look at raw volume alone. It combines several volume and candle-based measurements:

• Relative volume compared with a volume SMA
• Volume expansion compared with the previous bar
• Volume EMA and volume SMA relationship
• Candle body pressure
• Close location inside the candle range
• Estimated buy and sell pressure balance

By combining these elements, the script attempts to separate ordinary volume changes from more meaningful volume expansion conditions.

────────────────────
What This Script Shows
────────────────────

The script can display:

• Volume bars
• Volume SMA
• Volume EMA
• Optional RVOL line
• Buy volume burst marker
• Sell volume burst marker
• High RVOL warning marker
• Gold volume start highlight
• Gold reference star
• Buy / sell pressure gauge

These elements are intended to make volume behavior easier to review visually.

────────────────────
How It Works
────────────────────

1. The script calculates a volume SMA and volume EMA.
2. It calculates RVOL by comparing current volume with the volume SMA.
3. It measures volume expansion against the previous bar.
4. It estimates candle pressure using candle body size and close location inside the candle range.
5. It normalizes buy-side and sell-side pressure.
6. It checks whether volume is above its average and expanding with sufficient RVOL.
7. It classifies burst conditions as buy-side or sell-side depending on the pressure model.
8. It flags very high RVOL areas as possible exhaustion or warning conditions.
9. It highlights a gold volume start when volume expands after a quieter prior phase.

────────────────────
Gold Volume Start
────────────────────

The gold volume start condition is designed to highlight a specific type of volume change.

It checks whether:

• The previous area had relatively quiet volume
• Current RVOL is above the selected threshold
• Current volume expands compared with the previous bar
• Current volume breaks above recent volume levels
• Optional candle and buy-pressure filters are satisfied
• The condition is not classified as an exhaustion warning

This condition is not a trade signal. It is a visual reference for studying early volume expansion after quieter activity.

────────────────────
Buy / Sell Pressure Gauge
────────────────────

The gauge estimates the balance between buy-side and sell-side pressure.

The pressure model uses:

• Candle body direction
• Candle body size relative to range
• Close location inside the candle
• Normalized buy and sell pressure

On realtime bars, the script can optionally average pressure readings during the active candle to smooth the displayed value.

This is an approximation based on candle structure, not actual order-flow data.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• Volume SMA length
• Volume EMA length
• RVOL threshold
• Minimum expansion percentage
• Exhaustion RVOL threshold
• Minimum body pressure
• Gold volume start sensitivity
• Quiet volume lookback
• Previous volume breakout lookback
• Candle and pressure filters
• Gauge position and size
• Visual colors
• Marker visibility
• Optional RVOL line

────────────────────
How To Use
────────────────────

Use this script as a volume context tool.

General interpretation examples:

• Higher RVOL may show stronger participation compared with recent average volume.
• Buy volume burst markers can help identify candles with stronger buy-side pressure and expanding volume.
• Sell volume burst markers can help identify candles with stronger sell-side pressure and expanding volume.
• High RVOL warning markers may appear when volume is unusually high and may require caution.
• Gold volume start highlights can help users study early expansion after a quieter volume phase.

This script should be used with independent analysis, risk management, and a defined trading plan.

────────────────────
Confirmation And Repainting Notes
────────────────────

Volume and candle pressure values update while the current candle is still forming.

Users who want confirmed readings should evaluate values after bar close.

The realtime pressure averaging option can update during the active candle, so the gauge may change before the candle closes.

The script does not use future price data.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

The buy/sell pressure gauge is based on candle structure and does not represent actual exchange order flow.

High volume can appear during continuation, reversal, exhaustion, or news-driven movement.

In low-liquidity markets, volume spikes may be less reliable.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Volume Surge Analyzer

Volume Surge Analyzer는 상대 거래량 확장, 거래량 증가 속도, 캔들 압력, 매수·매도 압력 균형을 관찰하기 위한 거래량 기반 차트 분석 보조지표입니다.

이 스크립트는 일반 거래량 흐름, 강한 거래량 Burst 조건, 높은 RVOL 경고 구간, 그리고 조용한 거래량 구간 이후 발생하는 Gold Volume Start 조건을 시각적으로 강조합니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다.
목적은 거래량이 어떻게 확장되는지, 그리고 캔들 구조가 상대적인 매수·매도 압력을 어떻게 보여줄 수 있는지 관찰하는 것입니다.

────────────────────
핵심 개념
────────────────────

거래량 확장은 가격 움직임을 분석할 때 중요한 참고 요소가 될 수 있습니다.

이 스크립트는 단순 거래량만 보지 않습니다. 여러 거래량 및 캔들 기반 측정값을 함께 사용합니다.

• Volume SMA 대비 상대 거래량
• 전봉 대비 거래량 확장률
• Volume EMA와 Volume SMA의 관계
• 캔들 몸통 압력
• 캔들 범위 안에서 종가의 위치
• 추정 매수·매도 압력 균형

이 요소들을 함께 사용해 일반적인 거래량 변화와 더 의미 있는 거래량 확장 조건을 구분하려고 합니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 거래량 막대
• Volume SMA
• Volume EMA
• 선택 가능한 RVOL 라인
• Buy Volume Burst 마커
• Sell Volume Burst 마커
• High RVOL Warning 마커
• Gold Volume Start 강조 막대
• Gold reference star
• Buy / Sell Pressure 게이지

이 요소들은 거래량 흐름을 시각적으로 더 쉽게 복기하기 위한 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. Volume SMA와 Volume EMA를 계산합니다.
2. 현재 거래량을 Volume SMA와 비교해 RVOL을 계산합니다.
3. 전봉 대비 거래량 확장률을 측정합니다.
4. 캔들 몸통 크기와 캔들 범위 안에서의 종가 위치를 사용해 캔들 압력을 추정합니다.
5. 매수 측 압력과 매도 측 압력을 정규화합니다.
6. 거래량이 평균 이상이고 충분한 RVOL과 확장률을 보이는지 확인합니다.
7. 압력 모델에 따라 Burst 조건을 매수 측 또는 매도 측으로 분류합니다.
8. 매우 높은 RVOL 구간을 과열 또는 주의 조건으로 표시합니다.
9. 조용한 거래량 구간 이후 거래량이 확장될 때 Gold Volume Start로 강조합니다.

────────────────────
Gold Volume Start
────────────────────

Gold Volume Start 조건은 특정한 거래량 변화 구간을 강조하기 위해 설계되었습니다.

이 조건은 다음 요소를 확인합니다.

• 이전 구간의 거래량이 비교적 조용했는지
• 현재 RVOL이 선택한 기준 이상인지
• 현재 거래량이 전봉 대비 확장되었는지
• 현재 거래량이 최근 거래량 수준을 돌파했는지
• 선택된 캔들 및 매수 압력 필터가 충족되었는지
• 과열 경고 조건으로 분류되지 않는지

이 조건은 매매 신호가 아닙니다.
조용한 거래량 구간 이후 발생하는 초기 거래량 확장을 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
Buy / Sell Pressure Gauge
────────────────────

게이지는 매수 측과 매도 측 압력의 균형을 추정합니다.

압력 모델은 다음 요소를 사용합니다.

• 캔들 몸통 방향
• 캔들 범위 대비 몸통 크기
• 캔들 안에서 종가 위치
• 정규화된 매수·매도 압력

실시간 봉에서는 활성 캔들 동안의 압력 값을 평균화하여 표시값을 조금 더 부드럽게 보여줄 수 있습니다.

이 값은 캔들 구조를 기반으로 한 추정값이며, 실제 거래소 호가창 또는 주문 흐름 데이터가 아닙니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• Volume SMA 기간
• Volume EMA 기간
• RVOL 기준값
• 최소 거래량 확장률
• 과열 RVOL 기준값
• 최소 몸통 압력
• Gold Volume Start 민감도
• 조용한 거래량 구간 확인 기간
• 이전 거래량 돌파 확인 기간
• 캔들 및 압력 필터
• 게이지 위치와 크기
• 시각 색상
• 마커 표시 여부
• 선택 가능한 RVOL 라인

────────────────────
사용 방법
────────────────────

이 스크립트는 거래량 흐름을 확인하는 보조도구로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 높은 RVOL은 최근 평균 거래량 대비 강한 참여를 보여줄 수 있습니다.
• Buy Volume Burst 마커는 거래량이 확장되면서 매수 측 압력이 강한 캔들을 확인하는 데 도움을 줄 수 있습니다.
• Sell Volume Burst 마커는 거래량이 확장되면서 매도 측 압력이 강한 캔들을 확인하는 데 도움을 줄 수 있습니다.
• High RVOL Warning 마커는 거래량이 비정상적으로 큰 구간에서 주의가 필요할 수 있음을 보여줍니다.
• Gold Volume Start는 조용한 거래량 구간 이후 초기 확장 구간을 관찰하는 데 사용할 수 있습니다.

이 스크립트는 독립적인 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

거래량과 캔들 압력 값은 현재 캔들이 진행되는 동안 계속 변할 수 있습니다.

확정된 값을 원하는 사용자는 봉 마감 이후 기준으로 확인해야 합니다.

실시간 압력 평균화 옵션을 사용하는 경우, 활성 캔들 동안 게이지 값이 변할 수 있습니다.

이 스크립트는 미래 가격 데이터를 사용하지 않습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

Buy / Sell Pressure 게이지는 캔들 구조를 기반으로 한 추정값이며, 실제 거래소 주문 흐름을 의미하지 않습니다.

높은 거래량은 추세 지속, 반전, 과열, 뉴스성 움직임 등 다양한 상황에서 나타날 수 있습니다.

저유동성 시장에서는 거래량 급증 신호의 신뢰도가 낮아질 수 있습니다.

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
indicator("Volume Surge Analyzer", overlay=false, max_labels_count=500, max_bars_back=5000)

// Volume Surge Analyzer
// This script studies relative volume expansion, volume acceleration,
// candle pressure, and buy/sell pressure balance.
// It is intended for educational chart analysis and does not provide trade signals.

//────────────────────────────────────────────────────────────────────
// Groups
//────────────────────────────────────────────────────────────────────
groupCore = "Volume Averages"
groupPressure = "Pressure Model"
groupBurst = "Burst Detection"
groupStart = "Volume Start Highlight"
groupStar = "Reference Star"
groupDisplay = "Display Settings"
groupGauge = "Pressure Gauge"
groupAlerts = "Alerts"

//────────────────────────────────────────────────────────────────────
// Core volume settings
//────────────────────────────────────────────────────────────────────
volumeSmaLength = input.int(20, "Volume SMA Length", minval=1, group=groupCore)
volumeEmaLength = input.int(10, "Volume EMA Length", minval=1, group=groupCore)
showVolumeSma = input.bool(true, "Show Volume SMA", group=groupCore)
showVolumeEma = input.bool(true, "Show Volume EMA", group=groupCore)
showRvolLine = input.bool(false, "Show RVOL Line", group=groupCore)

//────────────────────────────────────────────────────────────────────
// Pressure model settings
//────────────────────────────────────────────────────────────────────
minimumBodyPressure = input.float(0.35, "Minimum Body Pressure", minval=0.0, maxval=1.0, step=0.05, group=groupPressure)
useRealtimePressureAveraging = input.bool(true, "Use Realtime Pressure Averaging", group=groupPressure)

//────────────────────────────────────────────────────────────────────
// Burst detection settings
//────────────────────────────────────────────────────────────────────
showBurstMarkers = input.bool(true, "Show Volume Burst Markers", group=groupBurst)
rvolThreshold = input.float(1.8, "Burst RVOL Threshold", minval=0.1, step=0.1, group=groupBurst)
expansionThreshold = input.float(20.0, "Minimum Expansion % vs Previous Bar", minval=0.0, step=1.0, group=groupBurst)
exhaustionRvol = input.float(4.5, "Exhaustion RVOL Threshold", minval=0.1, step=0.1, group=groupBurst)

//────────────────────────────────────────────────────────────────────
// Volume start highlight settings
//────────────────────────────────────────────────────────────────────
showVolumeStart = input.bool(true, "Show Gold Volume Start", group=groupStart)
startSensitivity = input.string("Normal", "Start Sensitivity", options=["Strict", "Normal", "Loose"], group=groupStart)
showStartGlow = input.bool(true, "Show Gold Glow", group=groupStart)
quietLookback = input.int(6, "Quiet Lookback", minval=2, maxval=50, group=groupStart)
previousVolumeLookback = input.int(6, "Previous Volume Breakout Lookback", minval=2, maxval=50, group=groupStart)
requireBullCandle = input.bool(true, "Require Bull Candle", group=groupStart)
requireVolumeEmaAboveSma = input.bool(false, "Require Volume EMA > SMA", group=groupStart)
useBuyPressureFilter = input.bool(true, "Use Buy Pressure Filter", group=groupStart)
goldVolumeColor = input.color(#FFD700, "Gold Volume Color", group=groupStart)

//────────────────────────────────────────────────────────────────────
// Reference star settings
//────────────────────────────────────────────────────────────────────
showGoldStar = input.bool(true, "Show Gold Reference Star", group=groupStar)
goldStarOffsetPct = input.float(12.0, "Star Offset % Above Bar", minval=1.0, maxval=100.0, step=1.0, group=groupStar)
maxStoredGoldStars = input.int(200, "Max Stored Gold Stars", minval=20, maxval=500, group=groupStar)
goldStarColor = input.color(#FFD700, "Star Color", group=groupStar)

//────────────────────────────────────────────────────────────────────
// Display settings
//────────────────────────────────────────────────────────────────────
bullVolumeColor = input.color(color.lime, "Bull Volume Color", group=groupDisplay)
bearVolumeColor = input.color(color.red, "Bear Volume Color", group=groupDisplay)
buyBurstColor = input.color(color.rgb(0, 102, 255), "Buy Burst Color", group=groupDisplay)
sellBurstColor = input.color(color.rgb(255, 59, 59), "Sell Burst Color", group=groupDisplay)
warningColor = input.color(color.yellow, "Exhaustion Warning Color", group=groupDisplay)

//────────────────────────────────────────────────────────────────────
// Gauge settings
//────────────────────────────────────────────────────────────────────
showGauge = input.bool(true, "Show Buy / Sell Pressure Gauge", group=groupGauge)
gaugePositionInput = input.string("Top Right", "Gauge Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupGauge)
gaugeTextSizeInput = input.string("Small", "Gauge Text Size", options=["Tiny", "Small", "Normal"], group=groupGauge)

//────────────────────────────────────────────────────────────────────
// Alert settings
//────────────────────────────────────────────────────────────────────
enableAlerts = input.bool(true, "Enable Alerts", group=groupAlerts)

//────────────────────────────────────────────────────────────────────
// Sensitivity parameters
//────────────────────────────────────────────────────────────────────
startRvolThreshold =
     startSensitivity == "Strict" ? 2.2 :
     startSensitivity == "Normal" ? 1.7 :
     1.35

startExpansionThreshold =
     startSensitivity == "Strict" ? 25.0 :
     startSensitivity == "Normal" ? 12.0 :
     0.0

quietRvolMax =
     startSensitivity == "Strict" ? 1.00 :
     startSensitivity == "Normal" ? 1.10 :
     1.20

breakVsPreviousMax =
     startSensitivity == "Strict" ? 1.25 :
     startSensitivity == "Normal" ? 1.10 :
     1.00

minimumBuyPressurePct =
     startSensitivity == "Strict" ? 58.0 :
     startSensitivity == "Normal" ? 53.0 :
     50.0

//────────────────────────────────────────────────────────────────────
// Volume calculations
//────────────────────────────────────────────────────────────────────
volumeSma = ta.sma(volume, volumeSmaLength)
volumeEma = ta.ema(volume, volumeEmaLength)

rvol = volumeSma > 0 ? volume / volumeSma : 0.0
previousVolume = nz(volume[1], volume)
expansionPct = previousVolume > 0 ? ((volume / previousVolume) - 1.0) * 100.0 : 0.0

//────────────────────────────────────────────────────────────────────
// Candle pressure model
//────────────────────────────────────────────────────────────────────
candleRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)

bodyBuyPressure = close >= open ? bodySize / candleRange : 0.0
bodySellPressure = close < open ? bodySize / candleRange : 0.0

locationBuyPressure = (close - low) / candleRange
locationSellPressure = (high - close) / candleRange

rawBuyPressure = bodyBuyPressure * 0.55 + locationBuyPressure * 0.45
rawSellPressure = bodySellPressure * 0.55 + locationSellPressure * 0.45

totalRawPressure = rawBuyPressure + rawSellPressure
normalizedBuyPressure = totalRawPressure > 0 ? rawBuyPressure / totalRawPressure : 0.5
normalizedSellPressure = totalRawPressure > 0 ? rawSellPressure / totalRawPressure : 0.5

//────────────────────────────────────────────────────────────────────
// Realtime pressure averaging
//────────────────────────────────────────────────────────────────────
varip float realtimeBuySum = 0.0
varip float realtimeSellSum = 0.0
varip int realtimeSamples = 0
varip int realtimeBarIndex = na

newRealtimeBar = barstate.isrealtime and (na(realtimeBarIndex) or bar_index != realtimeBarIndex)

if newRealtimeBar
    realtimeBuySum := 0.0
    realtimeSellSum := 0.0
    realtimeSamples := 0
    realtimeBarIndex := bar_index

if barstate.isrealtime and useRealtimePressureAveraging
    realtimeBuySum += normalizedBuyPressure
    realtimeSellSum += normalizedSellPressure
    realtimeSamples += 1
    realtimeBarIndex := bar_index

averageBuyPressure =
     barstate.isrealtime and useRealtimePressureAveraging and realtimeSamples > 0 ?
     realtimeBuySum / realtimeSamples :
     normalizedBuyPressure

averageSellPressure =
     barstate.isrealtime and useRealtimePressureAveraging and realtimeSamples > 0 ?
     realtimeSellSum / realtimeSamples :
     normalizedSellPressure

averageTotalPressure = averageBuyPressure + averageSellPressure
buyPressurePct = averageTotalPressure > 0 ? (averageBuyPressure / averageTotalPressure) * 100.0 : 50.0

buyTenth = int(math.round(buyPressurePct * 10.0))
buyTenth := math.max(0, math.min(1000, buyTenth))
sellTenth = 1000 - buyTenth

buyText = str.tostring(buyTenth / 10.0, "#.0")
sellText = str.tostring(sellTenth / 10.0, "#.0")

//────────────────────────────────────────────────────────────────────
// Burst logic
//────────────────────────────────────────────────────────────────────
volumeAboveSma = volume > volumeSma
volumeEmaAboveSma = volumeEma > volumeSma

strongRvol = rvol >= rvolThreshold
volumeExpanding = expansionPct >= expansionThreshold

buyIntentStrong = averageBuyPressure >= minimumBodyPressure
sellIntentStrong = averageSellPressure >= minimumBodyPressure

exhaustionWarning = rvol >= exhaustionRvol and expansionPct < 5.0

realBuyBurst = volumeAboveSma and volumeEmaAboveSma and strongRvol and volumeExpanding and buyIntentStrong and not exhaustionWarning
realSellBurst = volumeAboveSma and volumeEmaAboveSma and strongRvol and volumeExpanding and sellIntentStrong and not exhaustionWarning

highRvolWarning = rvol >= exhaustionRvol

//────────────────────────────────────────────────────────────────────
// Gold volume start logic
//────────────────────────────────────────────────────────────────────
recentQuietRvol = ta.lowest(rvol[1], quietLookback)
quietZoneDetected = not na(recentQuietRvol) and recentQuietRvol <= quietRvolMax

previousHighestVolume = ta.highest(volume[1], previousVolumeLookback)
breaksRecentVolumeMax = not na(previousHighestVolume) and volume >= previousHighestVolume * breakVsPreviousMax

startRvolOk = rvol >= startRvolThreshold
startExpansionOk = expansionPct >= startExpansionThreshold
bullCandleOk = not requireBullCandle or close >= open
volumeTrendOk = not requireVolumeEmaAboveSma or volumeEmaAboveSma
buyPressureOk = not useBuyPressureFilter or buyPressurePct >= minimumBuyPressurePct

goldVolumeStart =
     showVolumeStart and
     quietZoneDetected and
     startRvolOk and
     startExpansionOk and
     breaksRecentVolumeMax and
     bullCandleOk and
     volumeTrendOk and
     buyPressureOk and
     not exhaustionWarning

//────────────────────────────────────────────────────────────────────
// Volume plots
//────────────────────────────────────────────────────────────────────
baseVolumeColor = close >= open ? color.new(bullVolumeColor, 0) : color.new(bearVolumeColor, 0)

plot(goldVolumeStart ? na : volume, title="Volume", style=plot.style_columns, color=baseVolumeColor, linewidth=1)

plot(showVolumeStart and showStartGlow and goldVolumeStart ? volume : na, title="Gold Volume Outer Glow", style=plot.style_columns, color=color.new(goldVolumeColor, 86), linewidth=11)
plot(showVolumeStart and showStartGlow and goldVolumeStart ? volume : na, title="Gold Volume Mid Glow", style=plot.style_columns, color=color.new(goldVolumeColor, 68), linewidth=7)
plot(showVolumeStart and goldVolumeStart ? volume : na, title="Gold Volume Core", style=plot.style_columns, color=color.new(goldVolumeColor, 10), linewidth=4)
plot(showVolumeStart and goldVolumeStart ? volume : na, title="Gold Volume Inner Beam", style=plot.style_columns, color=color.new(color.white, 70), linewidth=1)

plot(showVolumeSma ? volumeSma : na, title="Volume SMA", linewidth=2, color=color.new(color.teal, 0))
plot(showVolumeEma ? volumeEma : na, title="Volume EMA", linewidth=2, color=color.new(color.orange, 0))

plot(showRvolLine ? rvol : na, title="RVOL", linewidth=2, color=color.new(color.fuchsia, 0))

//────────────────────────────────────────────────────────────────────
// Burst markers
//────────────────────────────────────────────────────────────────────
plotshape(showBurstMarkers and realBuyBurst and not goldVolumeStart, title="Buy Volume Burst", style=shape.circle, location=location.top, size=size.tiny, color=color.new(buyBurstColor, 0), text="B", textcolor=color.new(buyBurstColor, 0))
plotshape(showBurstMarkers and realSellBurst and not goldVolumeStart, title="Sell Volume Burst", style=shape.circle, location=location.top, size=size.tiny, color=color.new(sellBurstColor, 0), text="S", textcolor=color.new(sellBurstColor, 0))
plotshape(showBurstMarkers and highRvolWarning and not goldVolumeStart, title="High RVOL Warning", style=shape.triangledown, location=location.top, size=size.tiny, color=color.new(warningColor, 0), text="X", textcolor=color.new(warningColor, 0))

//────────────────────────────────────────────────────────────────────
// Gold reference stars
//────────────────────────────────────────────────────────────────────
var array<label> goldStarLabels = array.new_label()

if showGoldStar and goldVolumeStart and barstate.isnew
    goldStarY = volume * (1.0 + goldStarOffsetPct / 100.0)

    glowStar = label.new(
         x=bar_index,
         y=goldStarY,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         text="★",
         style=label.style_none,
         color=color.new(goldStarColor, 100),
         textcolor=color.new(goldStarColor, 55),
         size=size.normal)

    coreStar = label.new(
         x=bar_index,
         y=goldStarY,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         text="★",
         style=label.style_none,
         color=color.new(goldStarColor, 100),
         textcolor=color.new(goldStarColor, 0),
         size=size.small)

    array.push(goldStarLabels, glowStar)
    array.push(goldStarLabels, coreStar)

    while array.size(goldStarLabels) > maxStoredGoldStars * 2
        oldLabel = array.shift(goldStarLabels)
        label.delete(oldLabel)

//────────────────────────────────────────────────────────────────────
// Gauge
//────────────────────────────────────────────────────────────────────
gaugePosition =
     gaugePositionInput == "Top Right" ? position.top_right :
     gaugePositionInput == "Top Left" ? position.top_left :
     gaugePositionInput == "Bottom Right" ? position.bottom_right :
     position.bottom_left

gaugeTextSize =
     gaugeTextSizeInput == "Tiny" ? size.tiny :
     gaugeTextSizeInput == "Small" ? size.small :
     size.normal

buyBackground = color.new(buyBurstColor, 20)
sellBackground = color.new(sellBurstColor, 20)
neutralBackground = color.new(color.gray, 82)
goldBackground = color.new(goldVolumeColor, 0)

pressureBackground =
     buyTenth > sellTenth ? buyBackground :
     sellTenth > buyTenth ? sellBackground :
     neutralBackground

volumeState =
     goldVolumeStart ? "GOLD VOLUME START" :
     realBuyBurst ? "BUY VOLUME BURST" :
     realSellBurst ? "SELL VOLUME BURST" :
     highRvolWarning ? "HIGH RVOL WARNING" :
     "NORMAL"

volumeStateBackground =
     goldVolumeStart ? goldBackground :
     realBuyBurst ? buyBackground :
     realSellBurst ? sellBackground :
     highRvolWarning ? color.new(warningColor, 20) :
     neutralBackground

volumeStateTextColor = goldVolumeStart ? color.black : color.white

var table gauge = table.new(gaugePosition, 1, 3, border_width=1)

if barstate.islast and showGauge
    table.cell(gauge, 0, 0, "Buy / Sell Pressure", text_color=color.white, text_size=gaugeTextSize, bgcolor=color.new(color.black, 0))
    table.cell(gauge, 0, 1, "Buy " + buyText + "%  |  Sell " + sellText + "%", text_color=color.white, text_size=gaugeTextSize, bgcolor=pressureBackground)
    table.cell(gauge, 0, 2, volumeState + "  |  RVOL " + str.tostring(rvol, "#.00"), text_color=volumeStateTextColor, text_size=gaugeTextSize, bgcolor=volumeStateBackground)
else if not showGauge
    table.clear(gauge, 0, 0, 0, 2)

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
alertcondition(enableAlerts and realBuyBurst, "Buy Volume Burst", "A buy-side volume burst was detected.")
alertcondition(enableAlerts and realSellBurst, "Sell Volume Burst", "A sell-side volume burst was detected.")
alertcondition(enableAlerts and highRvolWarning, "High RVOL Warning", "A high relative-volume condition was detected.")
alertcondition(enableAlerts and goldVolumeStart, "Gold Volume Start", "A gold volume start condition was detected.")
````
