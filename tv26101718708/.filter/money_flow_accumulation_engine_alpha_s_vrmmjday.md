# Money Flow Accumulation Engine | Alpha S+

- url: https://www.tradingview.com/script/VrMMJdAy-Money-Flow-Accumulation-Engine-Alpha-S/
- type: indicator
- pine_id: PUB;c4a1e3a794bf4ff78bc647daf1af237f
- version: 1.0

## Description

Money Flow Accumulation Engine

Money Flow Accumulation Engine is a volume-flow oscillator designed to help users study accumulation, distribution, inflow, outflow, and flow divergence conditions.

The script combines several volume and price-pressure concepts into one normalized flow structure. It uses Money Flow Index behavior, Chaikin Money Flow logic, OBV deviation, price-location pressure, relative volume, and smoothed flow direction to create a broader view of whether volume behavior is leaning toward accumulation or distribution.

The script does not provide entry or exit recommendations. Its purpose is to help users study money-flow pressure, flow confirmation, flow weakness, divergence behavior, and accumulation or distribution zones in a structured oscillator format.

────────────────────
Core Concept
────────────────────

Volume can provide additional context that price alone does not show.

A rising price move with weak flow may have a different meaning from a rising price move with strong inflow.

A sideways price area with improving flow may suggest accumulation behavior.

A sideways or rising price area with weakening flow may suggest distribution behavior.

This script combines multiple flow components:

• MFI-based money flow pressure
• CMF-style volume pressure
• OBV deviation from its trend
• candle body and close-location pressure
• relative volume
• smoothed money-flow direction
• accumulation and distribution zone logic
• flow confirmation and flow weakness states
• divergence checks between price and flow

The goal is to give users a cleaner way to study whether volume pressure is strengthening, weakening, accumulating, or distributing.

────────────────────
What This Script Shows
────────────────────

The script can display:

• money flow histogram
• smoothed money flow line
• flow signal line
• smart money line
• accumulation ribbon
• distribution ribbon
• inflow and outflow guide levels
• strong inflow and strong outflow guide levels
• accumulation and distribution start labels
• flow confirmation markers
• flow out markers
• optional flow weakness labels
• optional divergence labels
• current state badge
• debug component plots

These elements are intended to help users review whether market participation is showing stronger inflow, outflow, accumulation, distribution, or weaker flow conditions.

────────────────────
How It Works
────────────────────

1. The script calculates Money Flow Index and converts it into a centered flow value.
2. It calculates a CMF-style money-flow component using close location within the candle range and volume.
3. It calculates OBV and measures OBV deviation from its EMA trend.
4. It calculates price-volume pressure from candle body direction, close location, and relative volume.
5. These components are combined into a single raw money-flow value.
6. The raw value is smoothed to create the main money-flow line.
7. A slower signal line is created from the flow value.
8. A smart money line is calculated from the smoothed flow.
9. Accumulation candidates are detected when price is flat or down, price is near the lower part of its range, flow improves, and relative volume is present.
10. Distribution candidates are detected when price is flat or up, price is near the upper part of its range, flow weakens, and relative volume is present.
11. Accumulation and distribution zones require conditions to persist for a selected number of bars.
12. Flow confirmation is detected when flow strength, smart money slope, signal-line alignment, and relative volume agree.
13. Flow out confirmation can be blocked near short-term lows to reduce late bearish labels.
14. Divergence checks compare price extremes with flow behavior over the selected lookback period.
15. Cooldowns reduce repeated labels in the same region.
16. Scores are calculated for accumulation, distribution, flow confirmation, weakness, and divergence states.

This structure helps users study money-flow behavior without relying on a single volume indicator.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• source price
• money flow length
• flow smoothing
• OBV trend length
• CMF length
• volume moving average length
• accumulation lookback
• distribution lookback
• flat price ATR range
• flow confirmation level
• flow weak level
• divergence lookback
• signal cooldown bars
• accumulation and distribution zone minimum bars
• minimum divergence score
• minimum confirm score
• minimum accumulation score
• minimum distribution score
• flow-out filter near short-term lows
• near-low and near-high range thresholds
• histogram visibility
• flow line visibility
• smart money line visibility
• accumulation and distribution ribbons
• start labels
• signal labels
• small markers
• divergence labels
• guide lines
• current badge
• debug plots
• label language
• score visibility

The default settings are designed to keep the oscillator readable while highlighting only higher-priority flow states.

────────────────────
Visual Elements
────────────────────

The script includes:

• histogram columns
• flow line
• signal line
• smart money line
• upper and lower flow guide levels
• accumulation ribbon
• distribution ribbon
• compact markers
• optional text labels
• optional current badge

The histogram shows the current composite money-flow value.

The flow line smooths the composite flow pressure.

The signal line gives a slower comparison reference.

The smart money line is a secondary smoothed flow reference used in accumulation, distribution, and confirmation logic.

The ribbons mark persistent accumulation or distribution environments.

Markers and labels are prioritized so that accumulation and distribution zone starts appear before lower-priority states.

────────────────────
Reference States
────────────────────

Accumulation:
A persistent lower-range condition where price is flat or down, price remains near the lower part of its range, and flow behavior is improving.

Distribution:
A persistent upper-range condition where price is flat or up, price remains near the upper part of its range, and flow behavior is weakening.

Flow Confirm:
A stronger positive-flow state where flow, signal-line relationship, smart money slope, and relative volume support the same direction.

Flow Out:
A stronger negative-flow state where flow, signal-line relationship, smart money slope, and relative volume support outflow behavior.

Flow Weak:
A condition where price movement continues but flow behavior weakens compared with prior flow.

Bullish Flow Divergence:
Price forms a lower low while flow does not confirm the same weakness.

Bearish Flow Divergence:
Price forms a higher high while flow does not confirm the same strength.

These states are informational and should not be interpreted as trading instructions.

────────────────────
How To Use
────────────────────

Use this script as a money-flow and accumulation-distribution analysis tool.

General interpretation examples:

• Positive flow values suggest stronger inflow pressure.
• Negative flow values suggest stronger outflow pressure.
• Flow above the signal line can show improving flow pressure.
• Flow below the signal line can show weakening flow pressure.
• A rising smart money line can support improving flow context.
• A falling smart money line can support weakening flow context.
• Accumulation ribbons can help users study areas where price is not advancing strongly but flow conditions are improving.
• Distribution ribbons can help users study areas where price is not declining strongly but flow conditions are weakening.
• Flow Confirm labels can help users identify stronger positive-flow alignment.
• Flow Out labels can help users identify stronger negative-flow alignment.
• Divergence labels can help users compare price extremes with flow behavior.
• Scores can be used as a relative strength reference for each detected state.

This script is best reviewed together with price action, trend structure, support and resistance, volume context, volatility, and higher-timeframe conditions.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script calculates flow values from current and historical price-volume data.

On realtime candles, values can change before the candle closes because price, volume, range position, MFI, CMF, OBV, and smoothing values can update intrabar.

For more conservative analysis, users should review flow states after candle confirmation.

The script does not use future price data to predict market direction.

Divergence and zone labels are based on selected lookback windows and may depend on how the current candle closes.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide entry or exit recommendations.

Accumulation does not guarantee an upward move.

Distribution does not guarantee a downward move.

Strong inflow can appear during late-stage continuation or exhaustion.

Strong outflow can appear near short-term lows, which is why the script includes an optional flow-out filter.

Divergence can persist for a long time before price reacts.

Different symbols and timeframes may require different settings.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to trade any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Money Flow Accumulation Engine

Money Flow Accumulation Engine은 매집, 분산, 자금 유입, 자금 이탈, 흐름 다이버전스 조건을 분석하기 위한 거래량 기반 money-flow 오실레이터입니다.

이 스크립트는 여러 거래량 및 가격 압력 개념을 하나의 정규화된 flow 구조로 결합합니다. Money Flow Index, Chaikin Money Flow 방식의 압력, OBV 편차, 가격 위치 압력, 상대 거래량, smoothed flow direction을 사용해 거래량 행동이 accumulation 또는 distribution 쪽으로 기울고 있는지 분석합니다.

이 지표는 진입 또는 청산 추천을 제공하지 않습니다. 목적은 money-flow pressure, flow confirmation, flow weakness, divergence behavior, accumulation 또는 distribution zone을 구조화된 오실레이터 형태로 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

거래량은 가격만으로는 보이지 않는 추가 컨텍스트를 제공할 수 있습니다.

약한 flow를 동반한 가격 상승과 강한 inflow를 동반한 가격 상승은 서로 다르게 해석될 수 있습니다.

가격이 횡보하는 동안 flow가 개선되면 accumulation behavior를 검토할 수 있습니다.

가격이 횡보하거나 상승하는 동안 flow가 약해지면 distribution behavior를 검토할 수 있습니다.

이 스크립트는 다음 flow component를 결합합니다.

• MFI 기반 money flow pressure
• CMF 스타일 volume pressure
• OBV trend 대비 deviation
• candle body 및 close-location pressure
• relative volume
• smoothed money-flow direction
• accumulation 및 distribution zone logic
• flow confirmation 및 flow weakness states
• price와 flow 사이의 divergence checks

목표는 거래량 압력이 강화, 약화, 매집, 분산 중 어디에 가까운지 더 깔끔하게 검토할 수 있도록 돕는 것입니다.

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• money flow histogram
• smoothed money flow line
• flow signal line
• smart money line
• accumulation ribbon
• distribution ribbon
• inflow and outflow guide levels
• strong inflow and strong outflow guide levels
• accumulation and distribution start labels
• flow confirmation markers
• flow out markers
• optional flow weakness labels
• optional divergence labels
• current state badge
• debug component plots

이 요소들은 시장 참여가 강한 inflow, outflow, accumulation, distribution 또는 weaker flow 조건 중 어디에 가까운지 검토하는 데 도움을 줍니다.

────────────────────
작동 방식
────────────────────

1. Money Flow Index를 계산하고 이를 중심화된 flow 값으로 변환합니다.
2. 캔들 범위 내 종가 위치와 거래량을 사용해 CMF 스타일 money-flow component를 계산합니다.
3. OBV를 계산하고 OBV가 EMA trend에서 얼마나 벗어났는지 측정합니다.
4. 캔들 몸통 방향, 종가 위치, 상대 거래량을 사용해 price-volume pressure를 계산합니다.
5. 이 component들을 하나의 raw money-flow value로 결합합니다.
6. Raw value를 평활화하여 main money-flow line을 만듭니다.
7. Flow value에서 더 느린 signal line을 만듭니다.
8. Smoothed flow에서 smart money line을 계산합니다.
9. Accumulation candidate는 가격이 flat 또는 down이고, 가격이 범위 하단부에 있으며, flow가 개선되고, relative volume이 존재할 때 감지됩니다.
10. Distribution candidate는 가격이 flat 또는 up이고, 가격이 범위 상단부에 있으며, flow가 약해지고, relative volume이 존재할 때 감지됩니다.
11. Accumulation 및 distribution zone은 조건이 선택한 봉 수 이상 지속되어야 합니다.
12. Flow confirmation은 flow strength, smart money slope, signal-line alignment, relative volume이 같은 방향으로 정렬될 때 감지됩니다.
13. Flow out confirmation은 단기 저점 부근에서 늦은 bearish label을 줄이기 위해 선택적으로 차단할 수 있습니다.
14. Divergence check는 선택한 lookback period에서 price extreme과 flow behavior를 비교합니다.
15. Cooldown은 같은 구간에서 반복 label을 줄입니다.
16. Score는 accumulation, distribution, flow confirmation, weakness, divergence state별로 계산됩니다.

이 구조는 단일 거래량 지표에만 의존하지 않고 money-flow behavior를 검토할 수 있게 합니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• source price
• money flow length
• flow smoothing
• OBV trend length
• CMF length
• volume moving average length
• accumulation lookback
• distribution lookback
• flat price ATR range
• flow confirmation level
• flow weak level
• divergence lookback
• signal cooldown bars
• accumulation and distribution zone minimum bars
• minimum divergence score
• minimum confirm score
• minimum accumulation score
• minimum distribution score
• short-term low 부근 flow-out filter
• near-low 및 near-high range thresholds
• histogram visibility
• flow line visibility
• smart money line visibility
• accumulation and distribution ribbons
• start labels
• signal labels
• small markers
• divergence labels
• guide lines
• current badge
• debug plots
• label language
• score visibility

기본 설정은 오실레이터를 읽기 쉽게 유지하면서, 우선순위가 높은 flow state만 강조하도록 설계되어 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• histogram columns
• flow line
• signal line
• smart money line
• upper and lower flow guide levels
• accumulation ribbon
• distribution ribbon
• compact markers
• optional text labels
• optional current badge

Histogram은 현재 composite money-flow value를 보여줍니다.

Flow line은 composite flow pressure를 평활화한 값입니다.

Signal line은 더 느린 비교 기준선입니다.

Smart money line은 accumulation, distribution, confirmation logic에 사용되는 secondary smoothed flow reference입니다.

Ribbon은 persistent accumulation 또는 distribution environment를 표시합니다.

Marker와 label은 accumulation 및 distribution zone start가 낮은 우선순위 상태보다 먼저 표시되도록 정리되어 있습니다.

────────────────────
참고 상태
────────────────────

Accumulation:
가격이 flat 또는 down이고, 가격이 범위 하단부에 머물며, flow behavior가 개선되는 persistent lower-range condition입니다.

Distribution:
가격이 flat 또는 up이고, 가격이 범위 상단부에 머물며, flow behavior가 약해지는 persistent upper-range condition입니다.

Flow Confirm:
Flow, signal-line relationship, smart money slope, relative volume이 같은 방향으로 정렬된 stronger positive-flow state입니다.

Flow Out:
Flow, signal-line relationship, smart money slope, relative volume이 outflow behavior를 지지하는 stronger negative-flow state입니다.

Flow Weak:
가격 움직임은 이어지지만 flow behavior가 과거 flow와 비교해 약해지는 상태입니다.

Bullish Flow Divergence:
가격이 lower low를 만들지만 flow가 같은 약세를 확인하지 않는 상태입니다.

Bearish Flow Divergence:
가격이 higher high를 만들지만 flow가 같은 강세를 확인하지 않는 상태입니다.

이 상태들은 정보 제공용이며, 매매 지시로 해석해서는 안 됩니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 money-flow 및 accumulation-distribution analysis tool로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• Positive flow value는 stronger inflow pressure를 의미할 수 있습니다.
• Negative flow value는 stronger outflow pressure를 의미할 수 있습니다.
• Flow가 signal line 위에 있으면 improving flow pressure를 검토할 수 있습니다.
• Flow가 signal line 아래에 있으면 weakening flow pressure를 검토할 수 있습니다.
• Rising smart money line은 improving flow context를 보조할 수 있습니다.
• Falling smart money line은 weakening flow context를 보조할 수 있습니다.
• Accumulation ribbon은 가격이 강하게 상승하지 않더라도 flow condition이 개선되는 구간을 검토하는 데 사용할 수 있습니다.
• Distribution ribbon은 가격이 강하게 하락하지 않더라도 flow condition이 약해지는 구간을 검토하는 데 사용할 수 있습니다.
• Flow Confirm label은 stronger positive-flow alignment를 확인하는 데 사용할 수 있습니다.
• Flow Out label은 stronger negative-flow alignment를 확인하는 데 사용할 수 있습니다.
• Divergence label은 price extreme과 flow behavior를 비교하는 데 사용할 수 있습니다.
• Score는 각 detected state의 relative strength reference로 사용할 수 있습니다.

이 스크립트는 가격 행동, 추세 구조, 지지와 저항, 거래량 컨텍스트, 변동성, 상위 시간대 조건과 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 현재 및 과거 price-volume data에서 flow value를 계산합니다.

실시간 캔들에서는 price, volume, range position, MFI, CMF, OBV, smoothing value가 봉 마감 전까지 변경될 수 있으므로 값이 변할 수 있습니다.

보다 보수적인 분석을 원한다면 봉 마감 이후 flow state를 검토하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다.

Divergence 및 zone label은 선택한 lookback window와 현재 캔들의 마감 방식에 영향을 받을 수 있습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

진입 또는 청산 추천을 제공하지 않습니다.

Accumulation이 상승 움직임을 보장하지 않습니다.

Distribution이 하락 움직임을 보장하지 않습니다.

Strong inflow는 late-stage continuation 또는 exhaustion에서도 나타날 수 있습니다.

Strong outflow는 단기 저점 부근에서도 나타날 수 있으며, 이를 줄이기 위해 선택형 flow-out filter가 포함되어 있습니다.

Divergence는 가격이 반응하기 전까지 오래 지속될 수 있습니다.

종목과 시간대에 따라 적절한 설정값이 달라질 수 있습니다.

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
indicator("Money Flow Accumulation Engine | Alpha S+", shorttitle="MFAccum", overlay=false, max_labels_count=120, max_bars_back=5000)

// =====================
// Inputs
// =====================
groupCore = "Core"
src = input.source(hlc3, "Source", group=groupCore)
mfLen = input.int(20, "Money Flow Length", minval=2, maxval=300, group=groupCore)
flowSmooth = input.int(5, "Flow Smoothing", minval=1, maxval=100, group=groupCore)
obvLen = input.int(34, "OBV Trend Length", minval=2, maxval=300, group=groupCore)
cmfLen = input.int(20, "CMF Length", minval=2, maxval=300, group=groupCore)
volMaLen = input.int(50, "Volume MA Length", minval=2, maxval=300, group=groupCore)

groupDetect = "Detection"
accumLookback = input.int(34, "Accumulation Lookback", minval=5, maxval=300, group=groupDetect)
distLookback = input.int(34, "Distribution Lookback", minval=5, maxval=300, group=groupDetect)
priceFlatAtr = input.float(2.10, "Flat Price ATR Range", minval=0.10, step=0.10, group=groupDetect)
flowConfirmLevel = input.float(24.0, "Flow Confirm Level", minval=1.0, maxval=100.0, step=1.0, group=groupDetect)
flowWeakLevel = input.float(10.0, "Flow Weak Level", minval=1.0, maxval=100.0, step=1.0, group=groupDetect)
divLookback = input.int(24, "Divergence Lookback", minval=5, maxval=100, group=groupDetect)
signalCooldownBars = input.int(34, "Signal Cooldown Bars", minval=1, maxval=250, group=groupDetect)
zoneMinBars = input.int(5, "ACCUM/DIST Zone Min Bars", minval=1, maxval=80, group=groupDetect)
minDivScore = input.int(78, "Min Divergence Score", minval=1, maxval=100, group=groupDetect)
minConfirmScore = input.int(44, "Min Confirm Score", minval=1, maxval=100, group=groupDetect)
minAccumScore = input.int(52, "Min Accumulation Score", minval=1, maxval=100, group=groupDetect)
minDistScore = input.int(52, "Min Distribution Score", minval=1, maxval=100, group=groupDetect)

groupFlowOut = "Flow Out Filter"
blockFlowOutNearLow = input.bool(true, "Block FLOW OUT Near Short-Term Low", group=groupFlowOut)
nearLowPct = input.float(0.22, "Near Low Range %", minval=0.01, maxval=0.50, step=0.01, group=groupFlowOut)
nearHighPct = input.float(0.22, "Near High Range %", minval=0.01, maxval=0.50, step=0.01, group=groupFlowOut)

groupUI = "UI"
showFlowHistogram = input.bool(true, "Show Flow Histogram", group=groupUI)
showFlowLine = input.bool(true, "Show Flow Line", group=groupUI)
showSmartMoneyLine = input.bool(true, "Show Smart Money Line", group=groupUI)
showAccumDistRibbons = input.bool(true, "Show ACCUM/DIST Ribbons", group=groupUI)
showAccumDistStartLabels = input.bool(true, "Show ACCUM/DIST Start Labels", group=groupUI)
showSignalLabels = input.bool(true, "Show Flow Confirm Labels", group=groupUI)
showSmallMarkers = input.bool(true, "Show Small Markers", group=groupUI)
showFlowWeakLabels = input.bool(false, "Show FLOW WEAK Labels", group=groupUI)
showDivLabels = input.bool(false, "Show Divergence Labels", group=groupUI)
showGuideLines = input.bool(true, "Show Guide Lines", group=groupUI)
showCurrentBadge = input.bool(false, "Show Current Badge", group=groupUI)
showDebugPlots = input.bool(false, "Show Debug Plots", group=groupUI)
labelSizeOpt = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=groupUI)
badgeOffsetBars = input.int(5, "Current Badge Offset Bars", minval=1, maxval=50, group=groupUI)

groupText = "Text"
labelMode = input.string("English", "Label Language", options=["English", "Korean"], group=groupText)
showScore = input.bool(true, "Show Score", group=groupText)

// =====================
// Helpers
// =====================
f_label_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Normal" ? size.normal :
     size.small

f_text(_en, _kr) =>
    labelMode == "Korean" ? _kr : _en

f_with_score(_txt, _score) =>
    showScore ? (_txt + " " + str.tostring(_score)) : _txt

f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _v))

f_hist_col(_v) =>
    _v > 0 ? (_v >= 35 ? color.new(color.lime, 0) : color.new(color.teal, 0)) :
     _v < 0 ? (_v <= -35 ? color.new(color.red, 0) : color.new(color.orange, 0)) :
     color.new(color.rgb(55, 59, 70), 90)

f_state_col(_state) =>
    _state == 4 ? color.new(color.lime, 0) :
     _state == 3 ? color.new(color.teal, 0) :
     _state == 2 ? color.new(color.lime, 0) :
     _state == -4 ? color.new(color.red, 0) :
     _state == -3 ? color.new(color.red, 0) :
     _state == -2 ? color.new(color.orange, 0) :
     color.new(color.rgb(55, 59, 70), 75)

// =====================
// Core calculations
// =====================
atrV = ta.atr(14)
volMA = ta.sma(volume, volMaLen)
volRel = volMA != 0.0 ? volume / volMA : 0.0

accumHigh = ta.highest(high, accumLookback)
accumLow = ta.lowest(low, accumLookback)
distHigh = ta.highest(high, distLookback)
distLow = ta.lowest(low, distLookback)
divLowPrev = ta.lowest(low, divLookback)[1]
divHighPrev = ta.highest(high, divLookback)[1]

mfiV = ta.mfi(src, mfLen)
mfiFlow = (mfiV - 50.0) * 2.0

mfMult = high != low ? ((close - low) - (high - close)) / (high - low) : 0.0
mfVol = mfMult * volume
cmfVolSum = math.sum(mfVol, cmfLen)
volumeSum = math.sum(volume, cmfLen)
cmfRaw = cmfVolSum / math.max(volumeSum, 1.0)
cmfFlow = f_clamp(cmfRaw * 100.0, -100.0, 100.0)

var float obv = 0.0
obv := nz(obv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0.0)
obvMA = ta.ema(obv, obvLen)
obvDev = ta.stdev(obv, obvLen)
obvZ = obvDev != 0.0 ? (obv - obvMA) / obvDev : 0.0
obvFlow = f_clamp(obvZ * 28.0, -100.0, 100.0)

barRange = high - low
closeLocation = barRange != 0.0 ? ((close - low) / barRange) * 2.0 - 1.0 : 0.0
bodyPressure = close > open ? 1.0 : close < open ? -1.0 : 0.0
pvPressureRaw = (closeLocation * 0.65 + bodyPressure * 0.35) * math.min(volRel, 3.0) * 30.0
pvFlow = f_clamp(pvPressureRaw, -100.0, 100.0)

flowRaw = (mfiFlow * 0.30) + (cmfFlow * 0.30) + (obvFlow * 0.25) + (pvFlow * 0.15)
flow = ta.ema(flowRaw, flowSmooth)
flowSignal = ta.ema(flow, math.max(2, flowSmooth * 2))

smartMoney = ta.ema(flow, 13)
smartMoneySlope = smartMoney - smartMoney[1]

flowLowestPrev = ta.lowest(flow, divLookback)[1]
flowHighestPrev = ta.highest(flow, divLookback)[1]

accumPriceRange = accumHigh - accumLow
distPriceRange = distHigh - distLow
flatPriceAccum = atrV > 0 ? accumPriceRange <= atrV * priceFlatAtr : false
flatPriceDist = atrV > 0 ? distPriceRange <= atrV * priceFlatAtr : false

flowRising = smartMoney > smartMoney[1] and smartMoney[1] >= smartMoney[2]
flowFalling = smartMoney < smartMoney[1] and smartMoney[1] <= smartMoney[2]
flowTurningUp = flow > flow[1] and flow[1] <= flow[2]
flowTurningDown = flow < flow[1] and flow[1] >= flow[2]

priceNearLowRange = close <= accumLow + accumPriceRange * 0.54
priceNearHighRange = close >= distLow + distPriceRange * 0.46

shortHigh = ta.highest(high, divLookback)
shortLow = ta.lowest(low, divLookback)
shortRange = shortHigh - shortLow
nearShortLow = shortRange > 0 ? close <= shortLow + shortRange * nearLowPct : false
nearShortHigh = shortRange > 0 ? close >= shortLow + shortRange * (1.0 - nearHighPct) : false

priceDownOrFlat = close <= close[accumLookback] or flatPriceAccum
priceUpOrFlat = close >= close[distLookback] or flatPriceDist

accumCandidate = priceDownOrFlat and priceNearLowRange and smartMoney > smartMoney[1] and flow > flowSignal + 0.75 and smartMoney > -24 and volRel >= 0.55
distCandidate = priceUpOrFlat and priceNearHighRange and smartMoney < smartMoney[1] and flow < flowSignal - 0.75 and smartMoney < 24 and volRel >= 0.55

var int accumZoneCount = 0
var int distZoneCount = 0
accumZoneCount := accumCandidate ? accumZoneCount + 1 : 0
distZoneCount := distCandidate ? distZoneCount + 1 : 0

accumZone = accumZoneCount >= zoneMinBars
distZone = distZoneCount >= zoneMinBars
accumZoneStart = accumZone and not accumZone[1]
distZoneStart = distZone and not distZone[1]

flowConfirmBullRaw = flow > flowConfirmLevel and smartMoneySlope > 0 and flow > flowSignal and volRel >= 0.90
flowConfirmBearBase = flow < -flowConfirmLevel and smartMoneySlope < 0 and flow < flowSignal and volRel >= 0.90
flowConfirmBearRaw = blockFlowOutNearLow ? (flowConfirmBearBase and not nearShortLow) : flowConfirmBearBase

flowWeakBullRaw = close > close[divLookback] and flow < flow[divLookback] and flow < flowWeakLevel and flowFalling and volRel >= 0.75
flowWeakBearRaw = close < close[divLookback] and flow > flow[divLookback] and flow > -flowWeakLevel and flowRising and volRel >= 0.75

bullDivRaw = low < divLowPrev and flow > flowLowestPrev and flowTurningUp and smartMoneySlope > 0 and not flowConfirmBullRaw
bearDivRaw = high > divHighPrev and flow < flowHighestPrev and flowTurningDown and smartMoneySlope < 0 and not flowConfirmBearRaw

// Scores
accumScoreBase = accumZone ? 48.0 : accumCandidate ? 30.0 : 0.0
accumScoreFlow = math.max(0.0, math.min(30.0, (smartMoney + 28.0) * 0.65))
accumScoreTurn = flowRising or flowTurningUp ? 12.0 : 0.0
accumScoreVol = math.max(0.0, math.min(10.0, volRel * 6.0))
accumScore = math.round(math.min(100.0, accumScoreBase + accumScoreFlow + accumScoreTurn + accumScoreVol))

distScoreBase = distZone ? 48.0 : distCandidate ? 30.0 : 0.0
distScoreFlow = math.max(0.0, math.min(30.0, (28.0 - smartMoney) * 0.65))
distScoreTurn = flowFalling or flowTurningDown ? 12.0 : 0.0
distScoreVol = math.max(0.0, math.min(10.0, volRel * 6.0))
distScore = math.round(math.min(100.0, distScoreBase + distScoreFlow + distScoreTurn + distScoreVol))

confirmScore = math.round(math.min(100.0, math.abs(flow) * 0.8 + math.min(volRel, 3.0) * 10.0 + math.abs(smartMoneySlope) * 2.0))
weakScore = math.round(math.min(100.0, math.abs(flow - flow[divLookback]) * 1.2 + math.abs(close - close[divLookback]) / math.max(atrV, syminfo.mintick) * 5.0))
divScore = math.round(math.min(100.0, math.abs(flow - flow[divLookback]) * 1.5 + math.abs(smartMoneySlope) * 8.0 + 40.0))

// Cooldowns
var int lastAccumBar = na
var int lastDistBar = na
var int lastBullConfirmBar = na
var int lastBearConfirmBar = na
var int lastWeakBar = na
var int lastDivBar = na

canAccum = na(lastAccumBar) or bar_index - lastAccumBar > signalCooldownBars
canDist = na(lastDistBar) or bar_index - lastDistBar > signalCooldownBars
canBullConfirm = na(lastBullConfirmBar) or bar_index - lastBullConfirmBar > signalCooldownBars
canBearConfirm = na(lastBearConfirmBar) or bar_index - lastBearConfirmBar > signalCooldownBars
canWeak = na(lastWeakBar) or bar_index - lastWeakBar > signalCooldownBars
canDiv = na(lastDivBar) or bar_index - lastDivBar > signalCooldownBars

accum = accumZoneStart and accumScore >= minAccumScore and canAccum
dist = distZoneStart and distScore >= minDistScore and canDist
flowConfirmBull = flowConfirmBullRaw and confirmScore >= minConfirmScore and canBullConfirm
flowConfirmBear = flowConfirmBearRaw and confirmScore >= minConfirmScore and canBearConfirm
flowWeakBull = flowWeakBullRaw and weakScore >= 55 and canWeak
flowWeakBear = flowWeakBearRaw and weakScore >= 55 and canWeak
bullDiv = bullDivRaw and divScore >= minDivScore and canDiv
bearDiv = bearDivRaw and divScore >= minDivScore and canDiv

if accum
    lastAccumBar := bar_index
if dist
    lastDistBar := bar_index
if flowConfirmBull
    lastBullConfirmBar := bar_index
if flowConfirmBear
    lastBearConfirmBar := bar_index
if flowWeakBull or flowWeakBear
    lastWeakBar := bar_index
if bullDiv or bearDiv
    lastDivBar := bar_index

int state = 0
state := accumZone ? 3 :
     distZone ? -3 :
     flowConfirmBull ? 4 :
     flowConfirmBear ? -4 :
     bullDiv ? 2 :
     bearDiv ? -2 :
     flowWeakBull or flowWeakBear ? 1 :
     0

stateText = state == 4 ? f_with_score(f_text("FLOW CONFIRM", "자금 유입 확인"), confirmScore) :
     state == -4 ? f_with_score(f_text("FLOW OUT", "자금 이탈"), confirmScore) :
     state == 3 ? f_with_score(f_text("ACCUMULATION", "매집"), accumScore) :
     state == -3 ? f_with_score(f_text("DISTRIBUTION", "분산"), distScore) :
     state == 2 ? f_with_score(f_text("BULL DIV", "상승 다이버전스"), divScore) :
     state == -2 ? f_with_score(f_text("BEAR DIV", "하락 다이버전스"), divScore) :
     state == 1 ? f_with_score(f_text("FLOW WEAK", "흐름 약화"), weakScore) :
     flow > flowConfirmLevel ? f_text("INFLOW", "유입") :
     flow < -flowConfirmLevel ? f_text("OUTFLOW", "이탈") :
     f_text("NEUTRAL", "중립")

// Label priority
accumLabelNow = accum
distLabelNow = dist and not accumLabelNow
majorBullNow = flowConfirmBull and not accumLabelNow and not distLabelNow
majorBearNow = flowConfirmBear and not accumLabelNow and not distLabelNow and not majorBullNow
flowConfirmLabelNow = majorBullNow and not accumZone and not distZone
flowOutLabelNow = majorBearNow and not accumZone and not distZone
bullDivLabelNow = bullDiv and showDivLabels and not accumLabelNow and not distLabelNow and not majorBullNow and not majorBearNow
bearDivLabelNow = bearDiv and showDivLabels and not accumLabelNow and not distLabelNow and not majorBullNow and not majorBearNow and not bullDivLabelNow
weakLabelNow = (flowWeakBull or flowWeakBear) and showFlowWeakLabels and not accumLabelNow and not distLabelNow and not majorBullNow and not majorBearNow and not bullDivLabelNow and not bearDivLabelNow

flowConfirmText = f_with_score(f_text("FLOW CONFIRM", "자금 유입"), confirmScore)
flowOutText = f_with_score(f_text("FLOW OUT", "자금 이탈"), confirmScore)
accumText = f_with_score(f_text("ACCUM", "매집"), accumScore)
distText = f_with_score(f_text("DIST", "분산"), distScore)
bullDivText = f_with_score(f_text("BULL DIV", "상승 DIV"), divScore)
bearDivText = f_with_score(f_text("BEAR DIV", "하락 DIV"), divScore)
weakText = f_with_score(f_text("FLOW WEAK", "흐름 약화"), weakScore)

txtSize = f_label_size(labelSizeOpt)

// =====================
// Pane visuals
// =====================
hline(0, "Zero", color=color.new(color.gray, 65))
hline(35, "Inflow Zone", color=showGuideLines ? color.new(color.teal, 84) : color.new(color.teal, 100), linestyle=hline.style_dotted)
hline(-35, "Outflow Zone", color=showGuideLines ? color.new(color.orange, 84) : color.new(color.orange, 100), linestyle=hline.style_dotted)
hline(60, "Strong Inflow", color=showGuideLines ? color.new(color.lime, 84) : color.new(color.lime, 100), linestyle=hline.style_dotted)
hline(-60, "Strong Outflow", color=showGuideLines ? color.new(color.red, 84) : color.new(color.red, 100), linestyle=hline.style_dotted)

accumRibbon = showAccumDistRibbons and accumZone ? 86.0 : na
distRibbon = showAccumDistRibbons and distZone ? -86.0 : na
plot(accumRibbon, "ACCUM Ribbon", style=plot.style_linebr, color=color.new(color.teal, 0), linewidth=2, display=display.pane)
plot(distRibbon, "DIST Ribbon", style=plot.style_linebr, color=color.new(color.red, 0), linewidth=2, display=display.pane)

plot(showFlowHistogram ? flow : na, "Money Flow Histogram", style=plot.style_columns, color=f_hist_col(flow), linewidth=3)
plot(showFlowLine ? flow : na, "Money Flow", color=color.new(color.aqua, 0), linewidth=2)
plot(showFlowLine ? flowSignal : na, "Flow Signal", color=color.new(color.yellow, 0), linewidth=1, display=display.pane)
plot(showSmartMoneyLine ? smartMoney : na, "Smart Money Line", color=color.new(color.orange, 0), linewidth=2)

plotshape(showSmallMarkers and majorBullNow ? 62.0 : na, title="FLOW CONFIRM Marker", text="", style=shape.triangleup, location=location.absolute, color=color.new(color.lime, 0), size=size.tiny)
plotshape(showSmallMarkers and majorBearNow ? -62.0 : na, title="FLOW OUT Marker", text="", style=shape.triangledown, location=location.absolute, color=color.new(color.red, 0), size=size.tiny)
plotshape(showSmallMarkers and accumLabelNow ? 60.0 : na, title="ACCUM Marker", text="", style=shape.circle, location=location.absolute, color=color.new(color.teal, 0), size=size.tiny)
plotshape(showSmallMarkers and distLabelNow ? -60.0 : na, title="DIST Marker", text="", style=shape.circle, location=location.absolute, color=color.new(color.red, 0), size=size.tiny)
plotshape(showSmallMarkers and bullDivLabelNow ? 42.0 : na, title="BULL DIV Marker", text="", style=shape.diamond, location=location.absolute, color=color.new(color.lime, 0), size=size.tiny)
plotshape(showSmallMarkers and bearDivLabelNow ? -42.0 : na, title="BEAR DIV Marker", text="", style=shape.diamond, location=location.absolute, color=color.new(color.red, 0), size=size.tiny)
plotshape(showSmallMarkers and weakLabelNow ? 25.0 : na, title="FLOW WEAK Marker", text="", style=shape.square, location=location.absolute, color=color.new(color.gray, 0), size=size.tiny)

// Text labels
if showAccumDistStartLabels and accumLabelNow
    label.new(bar_index, 64.0, accumText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.teal, 0), size=txtSize)

if showAccumDistStartLabels and distLabelNow
    label.new(bar_index, -64.0, distText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.red, 0), size=txtSize)

if showSignalLabels and flowConfirmLabelNow
    label.new(bar_index, 54.0, flowConfirmText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.lime, 0), size=txtSize)

if showSignalLabels and flowOutLabelNow
    label.new(bar_index, -54.0, flowOutText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.red, 0), size=txtSize)

if showSignalLabels and bullDivLabelNow
    label.new(bar_index, 48.0, bullDivText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.lime, 0), size=txtSize)

if showSignalLabels and bearDivLabelNow
    label.new(bar_index, -48.0, bearDivText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.red, 0), size=txtSize)

if showSignalLabels and weakLabelNow
    label.new(bar_index, 30.0, weakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.gray, 0), size=txtSize)

var label currentBadge = na

if showCurrentBadge and barstate.islast
    if not na(currentBadge)
        label.delete(currentBadge)
    currentBadge := label.new(bar_index + badgeOffsetBars, 76, stateText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=f_state_col(state), textcolor=color.white, size=txtSize)

if not showCurrentBadge and barstate.islast
    if not na(currentBadge)
        label.delete(currentBadge)
        currentBadge := na

plot(showDebugPlots ? mfiFlow : na, "MFI Flow", color=color.new(color.aqua, 0), linewidth=1)
plot(showDebugPlots ? cmfFlow : na, "CMF Flow", color=color.new(color.lime, 0), linewidth=1)
plot(showDebugPlots ? obvFlow : na, "OBV Flow", color=color.new(color.orange, 0), linewidth=1)
plot(showDebugPlots ? pvFlow : na, "PV Flow", color=color.new(color.purple, 0), linewidth=1)
plot(showDebugPlots ? accumScore : na, "Accumulation Score", color=color.new(color.teal, 0), linewidth=1)
plot(showDebugPlots ? distScore : na, "Distribution Score", color=color.new(color.red, 0), linewidth=1)

// =====================
// Alerts
// =====================
alertcondition(flowConfirmBull, title="Flow Confirm", message="Money Flow Accumulation Engine: bullish flow confirmed.")
alertcondition(flowConfirmBear, title="Flow Out", message="Money Flow Accumulation Engine: bearish outflow confirmed.")
alertcondition(accum, title="Accumulation Zone Started", message="Money Flow Accumulation Engine: accumulation zone started.")
alertcondition(dist, title="Distribution Zone Started", message="Money Flow Accumulation Engine: distribution zone started.")
alertcondition(bullDiv, title="Bullish Flow Divergence", message="Money Flow Accumulation Engine: bullish flow divergence detected.")
alertcondition(bearDiv, title="Bearish Flow Divergence", message="Money Flow Accumulation Engine: bearish flow divergence detected.")
alertcondition(flowWeakBull or flowWeakBear, title="Flow Weakness", message="Money Flow Accumulation Engine: flow weakness detected.")
````
