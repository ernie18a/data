# RSI Divergence Momentum Engine

- url: https://www.tradingview.com/script/gJbbP467-RSI-Divergence-Momentum-Engine/
- type: indicator
- pine_id: PUB;015bd62247c3433590184c2650caed0c
- version: 1.0

## Description

RSI Divergence Momentum Engine

RSI Divergence Momentum Engine is a momentum and divergence analysis tool based on the Relative Strength Index. It is designed to help users study RSI trend tone, overbought / oversold behavior, RSI signal-line interaction, regular divergence, hidden divergence, and price-structure confirmation.

The script combines RSI with a signal moving average, pivot-based divergence detection, ADX trend-strength filtering, RSI trend-lock logic, gap protection, and a price-structure score. The goal is to reduce weak divergence interpretation and provide a more structured view of momentum reversal and continuation conditions.

It does not provide buy or sell recommendations. The purpose of this script is to help users analyze RSI momentum behavior, divergence quality, trend context, and structure alignment.

────────────────────
Core Concept
────────────────────

RSI is a momentum oscillator that measures the speed and magnitude of recent price changes.

A high RSI reading can show strong upside momentum or overbought pressure.

A low RSI reading can show strong downside momentum or oversold pressure.

Divergence occurs when price and RSI move in different structural directions.

A bullish regular divergence occurs when price makes a lower low while RSI forms a higher low.

A bearish regular divergence occurs when price makes a higher high while RSI forms a lower high.

Hidden divergence can be used to study potential continuation behavior inside an existing trend.

This script focuses on four main ideas:

• RSI momentum tone
• RSI signal-line interaction
• regular and hidden divergence
• divergence quality filtering through structure, ADX, and trend context

────────────────────
What This Script Shows
────────────────────

The script can display:

• RSI line
• RSI signal moving average
• RSI / signal fill
• overbought and oversold zones
• RSI middle level
• momentum tone ribbon
• bullish divergence labels
• bearish divergence labels
• hidden divergence labels
• divergence lines
• optional divergence zones
• RSI 50 recovery / loss markers
• RSI signal moving average crossover markers
• overbought / oversold event markers
• confidence percentage
• strength grade markers

These elements are intended to help users review whether RSI momentum is confirming, weakening, diverging, or aligning with price structure.

────────────────────
How It Works
────────────────────

1. The script calculates RSI from the selected source and length.
2. A configurable signal moving average is applied to the RSI.
3. RSI tone is classified by comparing RSI with the middle level and its signal line.
4. Overbought, oversold, and middle reference levels are plotted.
5. Pivot lows and pivot highs are detected on the RSI.
6. Price pivots and RSI pivots are compared to detect regular divergence.
7. Optional hidden divergence can also be detected.
8. Divergence distance and RSI gap filters help reduce very small or crowded signals.
9. ADX filtering checks whether the market has enough trend strength for the divergence context.
10. Trend-lock logic can block counter-trend divergence when RSI remains in a strong trend state.
11. Gap protection can reduce counter-direction signals immediately after strong gap movement.
12. A price-structure score checks EMA, VWAP, swing, and reversal-candle alignment.
13. A confidence score is calculated from ADX, structure score, RSI extreme location, divergence gap, and gap-protection context.
14. The script assigns weak, normal, or strong divergence grades based on the selected thresholds.

This structure is intended to make RSI divergence interpretation more selective than a simple pivot-to-pivot comparison.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• RSI source
• RSI length
• RSI signal moving average length
• RSI signal moving average type
• overbought level
• oversold level
• middle level
• signal mode
• RSI 50 cross confirmation window
• RSI / signal gap requirement
• divergence pivot length
• minimum and maximum pivot distance
• minimum RSI divergence gap
• divergence line visibility
• hidden divergence visibility
• divergence cooldown
• strength grading thresholds
• confidence percentage visibility
• ADX filter settings
• trend-lock settings
• gap-protection settings
• price-structure score settings
• trend EMA filter
• volume filter
• RSI extreme filter
• RSI background zones
• RSI signal fill
• momentum tone ribbon
• guide labels

The default settings are designed to focus on clearer RSI divergence structures while reducing weak signals from noisy pivots, trend conflicts, and poor structure alignment.

────────────────────
Visual Elements
────────────────────

The script includes:

• RSI line
• RSI Signal MA
• RSI Signal Fill
• Overbought Zone
• Oversold Zone
• Middle Line
• Momentum Tone Ribbon
• Bull divergence label
• Bear divergence label
• Hidden Bull label
• Hidden Bear label
• Divergence line
• Optional divergence zone
• RSI+ marker
• RSI- marker
• MA cross marker
• OB / OS marker

The RSI line changes color according to bullish, bearish, or neutral momentum tone.

The fill between RSI and the signal moving average helps show short-term RSI pressure.

The momentum tone ribbon gives a compact view of whether RSI is above or below its signal and middle level.

The divergence labels show the detected direction, strength grade, and optional confidence percentage.

────────────────────
Reference Markers
────────────────────

Bull:
Shows a regular bullish RSI divergence.

Bear:
Shows a regular bearish RSI divergence.

H-Bull:
Shows a hidden bullish divergence.

H-Bear:
Shows a hidden bearish divergence.

RSI+:
Shows a stronger RSI recovery above the middle level.

RSI-:
Shows a stronger RSI loss below the middle level.

MA↑:
Shows RSI crossing above its signal moving average.

MA↓:
Shows RSI crossing below its signal moving average.

OB:
Shows RSI crossing into the overbought zone.

OS:
Shows RSI crossing into the oversold zone.

These markers are not trading signals. They are visual references for studying RSI momentum, divergence quality, and trend context.

────────────────────
How To Use
────────────────────

Use this script as an RSI momentum and divergence analysis tool.

General interpretation examples:

• A bullish divergence can help users review whether downside price movement is losing RSI momentum.
• A bearish divergence can help users review whether upside price movement is losing RSI momentum.
• A stronger divergence grade can indicate that the event satisfied more ADX, structure, RSI extreme, and divergence-gap conditions.
• RSI+ can help users review when RSI recovers above the middle level with strength.
• RSI- can help users review when RSI loses the middle level with weakness.
• Hidden divergence can be used to study potential continuation behavior, especially when aligned with trend context.
• The RSI signal moving average can help users review short-term momentum shifts.
• The momentum tone ribbon can help users quickly read bullish, bearish, or neutral RSI pressure.

This script is best reviewed together with price action, support and resistance, volatility, trend structure, and higher-timeframe context.

────────────────────
Confirmation And Repainting Notes
────────────────────

This script uses RSI pivot highs and pivot lows.

Pivot-based divergence requires bars on both sides of the RSI turning point before the pivot is confirmed.

Because of this, divergence labels and divergence lines appear only after the relevant pivot is confirmed.

If realtime mode is used, some signal conditions may change before candle close.

For more conservative use, users can select bar-close confirmation and evaluate signals after candle close.

The script does not use future price data to predict market direction. However, pivot-based structures naturally require confirmation bars, so divergence markers are confirmed after the pivot has formed.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

RSI divergence does not guarantee reversal.

Hidden divergence does not guarantee continuation.

RSI can remain overbought or oversold during strong trends.

Divergence signals can be less reliable in low-volatility ranges, fast news-driven moves, or unstable market conditions.

The confidence score is a structural reference, not a probability of profit.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

RSI Divergence Momentum Engine

RSI Divergence Momentum Engine은 Relative Strength Index를 기반으로 한 모멘텀 및 다이버전스 분석 보조지표입니다. RSI 추세 톤, 과매수 / 과매도 행동, RSI 시그널선 상호작용, 일반 다이버전스, 히든 다이버전스, 가격 구조 확인을 함께 분석할 수 있도록 설계되었습니다.

이 스크립트는 RSI와 시그널 이동평균, 피벗 기반 다이버전스 감지, ADX 추세 강도 필터, RSI 트렌드 락 로직, 갭 보호, 가격 구조 점수를 결합합니다. 목적은 약한 다이버전스 해석을 줄이고, 모멘텀 반전과 지속 조건을 더 구조적으로 확인하는 것입니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다. 목적은 RSI 모멘텀 행동, 다이버전스 품질, 추세 컨텍스트, 구조 정렬을 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

RSI는 최근 가격 변화의 속도와 크기를 측정하는 모멘텀 오실레이터입니다.

높은 RSI 값은 강한 상승 모멘텀 또는 과매수 압력을 보여줄 수 있습니다.

낮은 RSI 값은 강한 하락 모멘텀 또는 과매도 압력을 보여줄 수 있습니다.

다이버전스는 가격과 RSI가 서로 다른 구조적 방향으로 움직일 때 발생합니다.

상승 일반 다이버전스는 가격이 더 낮은 저점을 만들지만 RSI는 더 높은 저점을 만들 때 발생합니다.

하락 일반 다이버전스는 가격이 더 높은 고점을 만들지만 RSI는 더 낮은 고점을 만들 때 발생합니다.

히든 다이버전스는 기존 추세 안에서 잠재적인 지속 행동을 관찰하는 데 사용할 수 있습니다.

이 스크립트는 네 가지 핵심 개념에 초점을 둡니다.

• RSI 모멘텀 톤
• RSI 시그널선 상호작용
• 일반 및 히든 다이버전스
• 구조, ADX, 추세 컨텍스트를 통한 다이버전스 품질 필터링

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• RSI 라인
• RSI 시그널 이동평균
• RSI / 시그널 fill
• 과매수 및 과매도 구간
• RSI 중앙선
• 모멘텀 톤 리본
• 상승 다이버전스 라벨
• 하락 다이버전스 라벨
• 히든 다이버전스 라벨
• 다이버전스 라인
• 선택 가능한 다이버전스 존
• RSI 50선 회복 / 이탈 마커
• RSI 시그널 이동평균 교차 마커
• 과매수 / 과매도 이벤트 마커
• 신뢰도 퍼센트
• 강도 등급 마커

이 요소들은 RSI 모멘텀이 가격을 확인하는지, 약해지는지, 다이버전스를 형성하는지, 또는 가격 구조와 정렬되는지를 복기할 수 있도록 돕습니다.

────────────────────
작동 방식
────────────────────

1. 선택한 소스와 길이를 기준으로 RSI를 계산합니다.
2. 설정 가능한 시그널 이동평균을 RSI에 적용합니다.
3. RSI를 중앙선 및 시그널선과 비교해 모멘텀 톤을 분류합니다.
4. 과매수, 과매도, 중앙 기준선을 표시합니다.
5. RSI의 피벗 저점과 피벗 고점을 감지합니다.
6. 가격 피벗과 RSI 피벗을 비교해 일반 다이버전스를 감지합니다.
7. 선택적으로 히든 다이버전스도 감지할 수 있습니다.
8. 피벗 거리와 RSI gap 필터를 사용해 너무 작거나 밀집된 신호를 줄입니다.
9. ADX 필터는 다이버전스 컨텍스트에 충분한 추세 강도가 있는지 확인합니다.
10. 트렌드 락 로직은 RSI가 강한 추세 상태를 유지할 때 역추세 다이버전스를 차단할 수 있습니다.
11. 갭 보호 로직은 강한 갭 움직임 직후 반대 방향 신호를 줄일 수 있습니다.
12. 가격 구조 점수는 EMA, VWAP, 스윙, 반전 캔들 정렬을 확인합니다.
13. ADX, 구조 점수, RSI 극단 위치, 다이버전스 gap, 갭 보호 컨텍스트를 기반으로 신뢰도 점수를 계산합니다.
14. 선택한 기준에 따라 약함, 보통, 강함 등급을 부여합니다.

이 구조는 단순한 피벗 비교보다 더 선별적인 RSI 다이버전스 해석을 목표로 합니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• RSI source
• RSI length
• RSI signal moving average length
• RSI signal moving average type
• overbought level
• oversold level
• middle level
• signal mode
• RSI 50 cross confirmation window
• RSI / signal gap requirement
• divergence pivot length
• minimum and maximum pivot distance
• minimum RSI divergence gap
• divergence line visibility
• hidden divergence visibility
• divergence cooldown
• strength grading thresholds
• confidence percentage visibility
• ADX filter settings
• trend-lock settings
• gap-protection settings
• price-structure score settings
• trend EMA filter
• volume filter
• RSI extreme filter
• RSI background zones
• RSI signal fill
• momentum tone ribbon
• guide labels

기본 설정은 노이즈성 피벗, 추세 충돌, 구조 정렬이 부족한 약한 신호를 줄이면서 더 명확한 RSI 다이버전스 구조에 집중하도록 설계되어 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• RSI line
• RSI Signal MA
• RSI Signal Fill
• Overbought Zone
• Oversold Zone
• Middle Line
• Momentum Tone Ribbon
• Bull divergence label
• Bear divergence label
• Hidden Bull label
• Hidden Bear label
• Divergence line
• Optional divergence zone
• RSI+ marker
• RSI- marker
• MA cross marker
• OB / OS marker

RSI 라인은 상승, 하락, 중립 모멘텀 톤에 따라 색상이 바뀝니다.

RSI와 시그널 이동평균 사이의 fill은 단기 RSI 압력을 보여줍니다.

모멘텀 톤 리본은 RSI가 시그널선과 중앙선 위 또는 아래에 있는지 빠르게 확인하는 데 도움을 줍니다.

다이버전스 라벨은 감지된 방향, 강도 등급, 선택 가능한 신뢰도 퍼센트를 표시합니다.

────────────────────
참고 마커
────────────────────

Bull:
일반 상승 RSI 다이버전스를 표시합니다.

Bear:
일반 하락 RSI 다이버전스를 표시합니다.

H-Bull:
히든 상승 다이버전스를 표시합니다.

H-Bear:
히든 하락 다이버전스를 표시합니다.

RSI+:
RSI가 중앙선 위로 강하게 회복되는 구간을 표시합니다.

RSI-:
RSI가 중앙선 아래로 약하게 이탈하는 구간을 표시합니다.

MA↑:
RSI가 시그널 이동평균을 상향 돌파하는 구간을 표시합니다.

MA↓:
RSI가 시그널 이동평균을 하향 이탈하는 구간을 표시합니다.

OB:
RSI가 과매수 구간으로 진입하는 구간을 표시합니다.

OS:
RSI가 과매도 구간으로 진입하는 구간을 표시합니다.

이 마커들은 매매 신호가 아닙니다. RSI 모멘텀, 다이버전스 품질, 추세 컨텍스트를 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 RSI 모멘텀 및 다이버전스 분석 도구로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• 상승 다이버전스는 가격 하락 움직임에서 RSI 모멘텀이 약해지고 있는지 확인하는 데 사용할 수 있습니다.
• 하락 다이버전스는 가격 상승 움직임에서 RSI 모멘텀이 약해지고 있는지 확인하는 데 사용할 수 있습니다.
• 더 강한 다이버전스 등급은 ADX, 구조, RSI 극단 위치, divergence gap 조건을 더 많이 충족했다는 의미일 수 있습니다.
• RSI+는 RSI가 중앙선을 강하게 회복하는 구간을 복기하는 데 사용할 수 있습니다.
• RSI-는 RSI가 중앙선을 약하게 이탈하는 구간을 복기하는 데 사용할 수 있습니다.
• 히든 다이버전스는 특히 추세 컨텍스트와 정렬될 때 잠재적인 지속 행동을 분석하는 데 사용할 수 있습니다.
• RSI 시그널 이동평균은 단기 모멘텀 전환을 확인하는 데 사용할 수 있습니다.
• 모멘텀 톤 리본은 상승, 하락, 중립 RSI 압력을 빠르게 읽는 데 도움을 줄 수 있습니다.

이 스크립트는 가격 행동, 지지와 저항, 변동성, 추세 구조, 상위 시간대 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 RSI 피벗 고점과 피벗 저점을 사용합니다.

피벗 기반 다이버전스는 RSI 전환점의 양쪽에 일정 수의 봉이 형성되어야 확정됩니다.

따라서 다이버전스 라벨과 라인은 관련 피벗이 확정된 이후에만 표시됩니다.

Realtime 모드를 사용할 경우 일부 신호 조건은 봉 마감 전까지 변경될 수 있습니다.

보다 보수적인 사용을 원한다면 Bar Close Confirmed 모드를 선택하고 봉 마감 이후 신호를 확인하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다. 다만 피벗 기반 구조는 확인봉이 필요하므로 다이버전스 마커는 피벗이 형성된 뒤 확정됩니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

RSI 다이버전스는 반전을 보장하지 않습니다.

히든 다이버전스는 추세 지속을 보장하지 않습니다.

강한 추세에서는 RSI가 장시간 과매수 또는 과매도 상태에 머무를 수 있습니다.

저변동성 횡보, 뉴스성 급변, 불안정한 시장 환경에서는 다이버전스 신호의 신뢰도가 낮아질 수 있습니다.

신뢰도 점수는 구조적 참고값이지 수익 확률이 아닙니다.

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
indicator("RSI Divergence Momentum Engine", shorttitle="RSIDiv", overlay=false, max_lines_count=250, max_labels_count=250, max_boxes_count=100, max_bars_back=5000)

groupRSI = "① RSI Core"
src = input.source(close, "RSI Source", group=groupRSI)
rsiLen = input.int(14, "RSI Length", minval=1, group=groupRSI)
rsiMaLen = input.int(9, "RSI Signal MA Length", minval=1, group=groupRSI)
rsiMaType = input.string("EMA", "RSI Signal MA Type", options=["SMA", "EMA", "RMA", "WMA"], group=groupRSI)
obLevel = input.float(70.0, "Overbought Level", minval=50.0, maxval=100.0, step=0.5, group=groupRSI)
osLevel = input.float(30.0, "Oversold Level", minval=0.0, maxval=50.0, step=0.5, group=groupRSI)
midLevel = input.float(50.0, "Middle Level", minval=1.0, maxval=99.0, step=0.5, group=groupRSI)

groupSignals = "② Momentum Signals"
showSignals = input.bool(true, "Show Signals", group=groupSignals)
signalMode = input.string("Realtime", "Signal Mode", options=["Realtime", "Bar Close Confirmed"], group=groupSignals)
showStrongCross = input.bool(false, "Show RSI+ / RSI-", group=groupSignals)
showOverSignals = input.bool(false, "Show Overbought / Oversold Signals", group=groupSignals)
showMaCross = input.bool(false, "Show RSI Signal MA Cross", group=groupSignals)
signalCooldown = input.int(45, "RSI Signal Cooldown Bars", minval=1, maxval=200, group=groupSignals)
obOsCooldown = input.int(25, "OB / OS Cooldown Bars", minval=1, maxval=150, group=groupSignals)
crossConfirmBars = input.int(4, "RSI Cross Confirm Window", minval=0, maxval=10, group=groupSignals)
midConfirmGap = input.float(3.0, "RSI 50 Minimum Gap", minval=0.1, maxval=20.0, step=0.1, group=groupSignals)
signalGapMin = input.float(1.5, "RSI / Signal Minimum Gap", minval=0.0, maxval=20.0, step=0.1, group=groupSignals)
strongBullLevel = input.float(57.0, "RSI+ Minimum Level", minval=50.0, maxval=80.0, step=0.5, group=groupSignals)
strongBearLevel = input.float(43.0, "RSI- Maximum Level", minval=20.0, maxval=50.0, step=0.5, group=groupSignals)

groupDiv = "③ Divergence"
showDivergence = input.bool(true, "Show Divergence", group=groupDiv)
divLeft = input.int(5, "Pivot Left Bars", minval=1, maxval=25, group=groupDiv)
divRight = input.int(5, "Pivot Right Bars", minval=1, maxval=25, group=groupDiv)
minPivotDistance = input.int(12, "Minimum Pivot Distance", minval=1, maxval=150, group=groupDiv)
maxPivotDistance = input.int(80, "Maximum Pivot Distance", minval=10, maxval=350, group=groupDiv)
minRsiDivGap = input.float(5.0, "Minimum RSI Divergence Gap", minval=0.1, step=0.1, group=groupDiv)
showDivLines = input.bool(true, "Show Divergence Lines", group=groupDiv)
showDivZones = input.bool(false, "Show Momentum Divergence Zones", group=groupDiv)
showHiddenDiv = input.bool(false, "Show Hidden Divergence", group=groupDiv)
divSignalCooldown = input.int(22, "Divergence Cooldown Bars", minval=1, maxval=150, group=groupDiv)

groupGrade = "④ Divergence Strength"
useGradingSystem = input.bool(true, "Show Strength Grade", group=groupGrade)
showConfidencePct = input.bool(true, "Show Confidence Percentage", group=groupGrade)
strongAdxLevel = input.float(28.0, "Strong Grade ADX Level", minval=20.0, step=0.5, group=groupGrade)
normalAdxLevel = input.float(23.0, "Normal Grade ADX Level", minval=15.0, step=0.5, group=groupGrade)
strongDivGap = input.float(7.0, "Strong Grade Min Div Gap", minval=3.0, step=0.5, group=groupGrade)
strongStructureScore = input.int(4, "Strong Grade Min Structure Score", minval=1, maxval=4, group=groupGrade)
normalStructureScore = input.int(3, "Normal Grade Min Structure Score", minval=1, maxval=4, group=groupGrade)
strongRsiExtreme = input.float(35.0, "Strong Grade Bull RSI Max", minval=10.0, maxval=50.0, step=0.5, group=groupGrade)
strongRsiBearMin = input.float(65.0, "Strong Grade Bear RSI Min", minval=50.0, maxval=90.0, step=0.5, group=groupGrade)
hideWeakGrade = input.bool(false, "Hide Weak Grade Signals", group=groupGrade)
useDirectionPenalty = input.bool(true, "Apply Direction Misalignment Penalty", group=groupGrade)
directionPenaltyPct = input.float(25.0, "Direction Misalignment Penalty %", minval=0.0, maxval=50.0, step=1.0, group=groupGrade)

groupAdxFilter = "⑤ ADX Trend Strength Filter"
useAdxFilter = input.bool(true, "Require ADX Trend Strength", group=groupAdxFilter)
adxLen = input.int(14, "ADX Length", minval=1, maxval=50, group=groupAdxFilter)
adxSmoothLen = input.int(14, "ADX Smoothing", minval=1, maxval=50, group=groupAdxFilter)
minAdxLevel = input.float(21.0, "Minimum ADX for Divergence", minval=10.0, maxval=50.0, step=0.5, group=groupAdxFilter)

groupTrendLock = "⑥ Trend Lock Filter"
useTrendLock = input.bool(true, "Block Counter-Trend Divergence", group=groupTrendLock)
trendLockRsiBull = input.float(60.0, "Strong Bull RSI Level", minval=50.0, maxval=80.0, step=0.5, group=groupTrendLock)
trendLockRsiBear = input.float(40.0, "Strong Bear RSI Level", minval=20.0, maxval=50.0, step=0.5, group=groupTrendLock)
trendLockHoldBars = input.int(5, "Trend Lock Hold Bars", minval=1, maxval=20, group=groupTrendLock)

groupGapProtection = "⑦ Gap Protection Filter"
useGapProtection = input.bool(true, "Block Counter-Direction After Gap", group=groupGapProtection)
gapAtrMultiplier = input.float(1.0, "Gap Detection ATR Multiplier", minval=0.3, step=0.1, group=groupGapProtection)
gapProtectBars = input.int(8, "Gap Protection Bars", minval=1, maxval=20, group=groupGapProtection)

groupPriceStructure = "⑧ Price Structure Score"
usePriceStructureFilter = input.bool(true, "Use Price Structure Score", group=groupPriceStructure)
emaLen = input.int(20, "Price EMA Length", minval=1, maxval=200, group=groupPriceStructure)
structureLen = input.int(8, "Structure Lookback Length", minval=2, maxval=50, group=groupPriceStructure)
useEmaScore = input.bool(true, "Use EMA Score", group=groupPriceStructure)
useVwapScore = input.bool(true, "Use VWAP Score", group=groupPriceStructure)
useSwingScore = input.bool(true, "Use Swing Score", group=groupPriceStructure)
useReversalScore = input.bool(true, "Use Reversal Score", group=groupPriceStructure)
minStructureScore = input.int(2, "Minimum Structure Score", minval=0, maxval=4, group=groupPriceStructure)
breakoutBufferAtr = input.float(0.05, "Reversal Buffer ATR", minval=0.0, step=0.01, group=groupPriceStructure)

groupFilter = "⑨ Optional Filters"
useTrendFilter = input.bool(false, "Use Trend EMA Filter", group=groupFilter)
trendEmaLen = input.int(50, "Trend EMA Length", minval=1, group=groupFilter)
useVolumeFilter = input.bool(false, "Use Volume Filter", group=groupFilter)
volumeFilterLen = input.int(20, "Volume Average Length", minval=1, group=groupFilter)
useExtremeFilter = input.bool(true, "Divergence Requires RSI Extreme Zone", group=groupFilter)
bullExtremeMax = input.float(40.0, "Bull Div RSI Max", minval=1.0, maxval=70.0, step=0.5, group=groupFilter)
bearExtremeMin = input.float(60.0, "Bear Div RSI Min", minval=30.0, maxval=99.0, step=0.5, group=groupFilter)

groupAtr = "⑩ ATR"
atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=groupAtr)

groupUI = "⑪ UI"
showBgZones = input.bool(true, "Show RSI Zone Background", group=groupUI)
showRsiFill = input.bool(true, "Show RSI / Signal Fill", group=groupUI)
showSignalLine = input.bool(true, "Show RSI Signal MA", group=groupUI)
showTrendRibbon = input.bool(true, "Show Trend RSI Ribbon", group=groupUI)
showGuideLabels = input.bool(false, "Show Guide Labels", group=groupUI)

rsi = ta.rsi(src, rsiLen)

rsiSignal = switch rsiMaType
    "SMA" => ta.sma(rsi, rsiMaLen)
    "EMA" => ta.ema(rsi, rsiMaLen)
    "RMA" => ta.rma(rsi, rsiMaLen)
    "WMA" => ta.wma(rsi, rsiMaLen)
    => ta.ema(rsi, rsiMaLen)

trendEma = ta.ema(close, trendEmaLen)
volAvg = ta.sma(volume, volumeFilterLen)
priceEma = ta.ema(close, emaLen)
atr = ta.atr(atrLen)
vwapValue = ta.vwap(hlc3)

trendBullOk = not useTrendFilter or close >= trendEma
trendBearOk = not useTrendFilter or close <= trendEma
volOk = not useVolumeFilter or volume >= volAvg
signalConfirmOk = signalMode == "Realtime" or barstate.isconfirmed

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmoothLen)
adxStrengthOk = not useAdxFilter or adx >= minAdxLevel

bullDiPriority = diPlus > diMinus
bearDiPriority = diMinus > diPlus
adxRising = adx > adx[1]

overbought = rsi >= obLevel
oversold = rsi <= osLevel

rsiBullTone = rsi > midLevel and rsi > rsiSignal
rsiBearTone = rsi < midLevel and rsi < rsiSignal

rsiAboveMidGap = rsi >= midLevel + midConfirmGap
rsiBelowMidGap = rsi <= midLevel - midConfirmGap
rsiSignalBullGap = rsi - rsiSignal >= signalGapMin
rsiSignalBearGap = rsiSignal - rsi >= signalGapMin

rsiCrossUp = ta.crossover(rsi, midLevel)
rsiCrossDown = ta.crossunder(rsi, midLevel)
barsSinceCrossUp = ta.barssince(rsiCrossUp)
barsSinceCrossDown = ta.barssince(rsiCrossDown)

recentCrossUp = not na(barsSinceCrossUp) and barsSinceCrossUp <= crossConfirmBars
recentCrossDown = not na(barsSinceCrossDown) and barsSinceCrossDown <= crossConfirmBars

strongBullRsiState = rsi >= trendLockRsiBull
strongBearRsiState = rsi <= trendLockRsiBear
strongBullRsiHold = ta.barssince(not strongBullRsiState)
strongBearRsiHold = ta.barssince(not strongBearRsiState)

strongBullTrendActive = useTrendLock and not na(strongBullRsiHold) and strongBullRsiHold >= trendLockHoldBars
strongBearTrendActive = useTrendLock and not na(strongBearRsiHold) and strongBearRsiHold >= trendLockHoldBars

bearTrendLockBlocked = strongBullTrendActive
bullTrendLockBlocked = strongBearTrendActive

gapBullDetected = open > close[1] + atr * gapAtrMultiplier
gapBearDetected = open < close[1] - atr * gapAtrMultiplier
barsSinceBullGap = ta.barssince(gapBullDetected)
barsSinceBearGap = ta.barssince(gapBearDetected)

postBullGapBearBlocked = useGapProtection and not na(barsSinceBullGap) and barsSinceBullGap <= gapProtectBars
postBearGapBullBlocked = useGapProtection and not na(barsSinceBearGap) and barsSinceBearGap <= gapProtectBars

prevSwingLow = ta.lowest(low[1], structureLen)
prevSwingHigh = ta.highest(high[1], structureLen)

bullEmaBase = close >= priceEma and priceEma >= priceEma[1]
bearEmaBase = close <= priceEma and priceEma <= priceEma[1]
bullVwapBase = close >= vwapValue
bearVwapBase = close <= vwapValue
higherLowBase = low > prevSwingLow or low > low[1]
lowerHighBase = high < prevSwingHigh or high < high[1]
bullReversalBase = close > open and close >= (high + low) / 2
bearReversalBase = close < open and close <= (high + low) / 2

bullEmaScore = not useEmaScore or bullEmaBase ? 1 : 0
bullVwapScore = not useVwapScore or bullVwapBase ? 1 : 0
bullSwingScore = not useSwingScore or higherLowBase ? 1 : 0
bullReversalScore = not useReversalScore or bullReversalBase ? 1 : 0

bearEmaScore = not useEmaScore or bearEmaBase ? 1 : 0
bearVwapScore = not useVwapScore or bearVwapBase ? 1 : 0
bearSwingScore = not useSwingScore or lowerHighBase ? 1 : 0
bearReversalScore = not useReversalScore or bearReversalBase ? 1 : 0

bullStructureScore = bullEmaScore + bullVwapScore + bullSwingScore + bullReversalScore
bearStructureScore = bearEmaScore + bearVwapScore + bearSwingScore + bearReversalScore

bullPriceStructureOK = not usePriceStructureFilter or bullStructureScore >= minStructureScore
bearPriceStructureOK = not usePriceStructureFilter or bearStructureScore >= minStructureScore

var int lastBullSignalBar = na
var int lastBearSignalBar = na
var int lastOBOSBar = na
var int lastDivBar = na

bullCooldownOk = na(lastBullSignalBar) or bar_index - lastBullSignalBar > signalCooldown
bearCooldownOk = na(lastBearSignalBar) or bar_index - lastBearSignalBar > signalCooldown
obosCooldownOk = na(lastOBOSBar) or bar_index - lastOBOSBar > obOsCooldown
divCooldownOk = na(lastDivBar) or bar_index - lastDivBar > divSignalCooldown

rsiStrongBull = showSignals and showStrongCross and signalConfirmOk and bullCooldownOk and recentCrossUp and rsi >= strongBullLevel and rsiAboveMidGap and rsi > rsiSignal and rsiSignalBullGap and trendBullOk and volOk
rsiStrongBear = showSignals and showStrongCross and signalConfirmOk and bearCooldownOk and recentCrossDown and rsi <= strongBearLevel and rsiBelowMidGap and rsi < rsiSignal and rsiSignalBearGap and trendBearOk and volOk

rsiMaBull = showSignals and showMaCross and signalConfirmOk and bullCooldownOk and ta.crossover(rsi, rsiSignal) and rsi > midLevel and rsi < obLevel and trendBullOk and volOk
rsiMaBear = showSignals and showMaCross and signalConfirmOk and bearCooldownOk and ta.crossunder(rsi, rsiSignal) and rsi < midLevel and rsi > osLevel and trendBearOk and volOk

rsiOB = showSignals and showOverSignals and signalConfirmOk and obosCooldownOk and ta.crossover(rsi, obLevel)
rsiOS = showSignals and showOverSignals and signalConfirmOk and obosCooldownOk and ta.crossunder(rsi, osLevel)

if rsiStrongBull or rsiMaBull
    lastBullSignalBar := bar_index

if rsiStrongBear or rsiMaBear
    lastBearSignalBar := bar_index

if rsiOB or rsiOS
    lastOBOSBar := bar_index

pivotRsiLow = ta.pivotlow(rsi, divLeft, divRight)
pivotRsiHigh = ta.pivothigh(rsi, divLeft, divRight)

var float prevLowPrice = na
var float prevLowRsi = na
var int prevLowBar = na
var float prevHighPrice = na
var float prevHighRsi = na
var int prevHighBar = na

var bool bullDiv = false
var bool bearDiv = false
var bool hiddenBullDiv = false
var bool hiddenBearDiv = false
var int bullGrade = 0
var int bearGrade = 0
var float bullConfidence = 0.0
var float bearConfidence = 0.0
var float currentPivotLowRsi = na
var float currentPivotHighRsi = na
var int currentPivotLowBar = na
var int currentPivotHighBar = na

bullDiv := false
bearDiv := false
hiddenBullDiv := false
hiddenBearDiv := false
bullGrade := 0
bearGrade := 0
bullConfidence := 0.0
bearConfidence := 0.0
currentPivotLowRsi := na
currentPivotHighRsi := na
currentPivotLowBar := na
currentPivotHighBar := na

if showDivergence and not na(pivotRsiLow)
    currentPivotLowPrice = low[divRight]
    currentPivotLowRsi := rsi[divRight]
    currentPivotLowBar := bar_index - divRight
    lowPivotDistance = not na(prevLowBar) ? currentPivotLowBar - prevLowBar : na
    lowDistanceOk = not na(lowPivotDistance) and lowPivotDistance >= minPivotDistance and lowPivotDistance <= maxPivotDistance
    bullExtremeOk = not useExtremeFilter or currentPivotLowRsi <= bullExtremeMax or prevLowRsi <= bullExtremeMax
    divGapBull = not na(prevLowRsi) ? currentPivotLowRsi - prevLowRsi : 0.0
    bullRegular = not na(prevLowPrice) and lowDistanceOk and currentPivotLowPrice < prevLowPrice and divGapBull >= minRsiDivGap and bullExtremeOk and trendBullOk and volOk and divCooldownOk and adxStrengthOk and bullPriceStructureOK and not bullTrendLockBlocked and not postBearGapBullBlocked
    bullHidden = showHiddenDiv and not na(prevLowPrice) and lowDistanceOk and currentPivotLowPrice > prevLowPrice and currentPivotLowRsi < prevLowRsi - minRsiDivGap and trendBullOk and volOk and divCooldownOk and adxStrengthOk and bullPriceStructureOK and not bullTrendLockBlocked and not postBearGapBullBlocked

    if bullRegular
        confAdx = adx >= strongAdxLevel ? 30.0 : adx >= normalAdxLevel ? 20.0 : 10.0
        confStructure = bullStructureScore >= 4 ? 25.0 : bullStructureScore >= 3 ? 18.0 : bullStructureScore >= 2 ? 12.0 : 5.0
        confExtreme = currentPivotLowRsi <= strongRsiExtreme ? 20.0 : currentPivotLowRsi <= bullExtremeMax ? 14.0 : 7.0
        confDivGap = divGapBull >= strongDivGap ? 15.0 : divGapBull >= minRsiDivGap + 2.0 ? 10.0 : 6.0
        confGap = not postBearGapBullBlocked ? 10.0 : 0.0
        baseConfBull = confAdx + confStructure + confExtreme + confDivGap + confGap
        directionMisalignBull = useDirectionPenalty and bearDiPriority and adxRising
        bullConfidence := directionMisalignBull ? math.max(baseConfBull - directionPenaltyPct, 10.0) : baseConfBull
        bullGrade := (adx >= strongAdxLevel and bullStructureScore >= strongStructureScore and divGapBull >= strongDivGap and currentPivotLowRsi <= strongRsiExtreme and not directionMisalignBull) ? 3 : (adx >= normalAdxLevel and bullStructureScore >= normalStructureScore and not directionMisalignBull) ? 2 : 1
        bullDiv := not (hideWeakGrade and bullGrade == 1)

    hiddenBullDiv := bullHidden

    if (bullDiv or bullHidden) and showDivLines
        lineColor = bullGrade == 3 ? color.new(color.lime, 0) : bullGrade == 2 ? color.new(color.green, 20) : bullGrade == 1 ? color.new(color.green, 50) : color.new(color.teal, 0)
        lineWidth = bullGrade == 3 ? 3 : bullGrade == 2 ? 2 : 1
        line.new(prevLowBar, prevLowRsi, currentPivotLowBar, currentPivotLowRsi, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth)

    if (bullDiv or bullHidden) and showDivZones
        box.new(prevLowBar, math.max(prevLowRsi, currentPivotLowRsi) + 2.0, currentPivotLowBar, math.min(prevLowRsi, currentPivotLowRsi) - 2.0, xloc=xloc.bar_index, border_color=color.new(color.lime, 78), bgcolor=color.new(color.lime, 92))

    if bullDiv or bullHidden
        lastDivBar := bar_index

    prevLowPrice := currentPivotLowPrice
    prevLowRsi := currentPivotLowRsi
    prevLowBar := currentPivotLowBar

if showDivergence and not na(pivotRsiHigh)
    currentPivotHighPrice = high[divRight]
    currentPivotHighRsi := rsi[divRight]
    currentPivotHighBar := bar_index - divRight
    highPivotDistance = not na(prevHighBar) ? currentPivotHighBar - prevHighBar : na
    highDistanceOk = not na(highPivotDistance) and highPivotDistance >= minPivotDistance and highPivotDistance <= maxPivotDistance
    bearExtremeOk = not useExtremeFilter or currentPivotHighRsi >= bearExtremeMin or prevHighRsi >= bearExtremeMin
    divGapBear = not na(prevHighRsi) ? prevHighRsi - currentPivotHighRsi : 0.0
    bearRegular = not na(prevHighPrice) and highDistanceOk and currentPivotHighPrice > prevHighPrice and divGapBear >= minRsiDivGap and bearExtremeOk and trendBearOk and volOk and divCooldownOk and adxStrengthOk and bearPriceStructureOK and not bearTrendLockBlocked and not postBullGapBearBlocked
    bearHidden = showHiddenDiv and not na(prevHighPrice) and highDistanceOk and currentPivotHighPrice < prevHighPrice and currentPivotHighRsi > prevHighRsi + minRsiDivGap and trendBearOk and volOk and divCooldownOk and adxStrengthOk and bearPriceStructureOK and not bearTrendLockBlocked and not postBullGapBearBlocked

    if bearRegular
        confAdxBear = adx >= strongAdxLevel ? 30.0 : adx >= normalAdxLevel ? 20.0 : 10.0
        confStructureBear = bearStructureScore >= 4 ? 25.0 : bearStructureScore >= 3 ? 18.0 : bearStructureScore >= 2 ? 12.0 : 5.0
        confExtremeBear = currentPivotHighRsi >= strongRsiBearMin ? 20.0 : currentPivotHighRsi >= bearExtremeMin ? 14.0 : 7.0
        confDivGapBear = divGapBear >= strongDivGap ? 15.0 : divGapBear >= minRsiDivGap + 2.0 ? 10.0 : 6.0
        confGapBear = not postBullGapBearBlocked ? 10.0 : 0.0
        baseConfBear = confAdxBear + confStructureBear + confExtremeBear + confDivGapBear + confGapBear
        directionMisalignBear = useDirectionPenalty and bullDiPriority and adxRising
        bearConfidence := directionMisalignBear ? math.max(baseConfBear - directionPenaltyPct, 10.0) : baseConfBear
        bearGrade := (adx >= strongAdxLevel and bearStructureScore >= strongStructureScore and divGapBear >= strongDivGap and currentPivotHighRsi >= strongRsiBearMin and not directionMisalignBear) ? 3 : (adx >= normalAdxLevel and bearStructureScore >= normalStructureScore and not directionMisalignBear) ? 2 : 1
        bearDiv := not (hideWeakGrade and bearGrade == 1)

    hiddenBearDiv := bearHidden

    if (bearDiv or bearHidden) and showDivLines
        lineColorBear = bearGrade == 3 ? color.new(color.red, 0) : bearGrade == 2 ? color.new(color.maroon, 20) : bearGrade == 1 ? color.new(color.red, 50) : color.new(color.orange, 0)
        lineWidthBear = bearGrade == 3 ? 3 : bearGrade == 2 ? 2 : 1
        line.new(prevHighBar, prevHighRsi, currentPivotHighBar, currentPivotHighRsi, xloc=xloc.bar_index, extend=extend.none, color=lineColorBear, width=lineWidthBear)

    if (bearDiv or bearHidden) and showDivZones
        box.new(prevHighBar, math.max(prevHighRsi, currentPivotHighRsi) + 2.0, currentPivotHighBar, math.min(prevHighRsi, currentPivotHighRsi) - 2.0, xloc=xloc.bar_index, border_color=color.new(color.red, 78), bgcolor=color.new(color.red, 92))

    if bearDiv or bearHidden
        lastDivBar := bar_index

    prevHighPrice := currentPivotHighPrice
    prevHighRsi := currentPivotHighRsi
    prevHighBar := currentPivotHighBar

bullStarText = useGradingSystem ? (bullGrade == 3 ? " ★★★" : bullGrade == 2 ? " ★★" : bullGrade == 1 ? " ★" : "") : ""
bearStarText = useGradingSystem ? (bearGrade == 3 ? " ★★★" : bearGrade == 2 ? " ★★" : bearGrade == 1 ? " ★" : "") : ""
bullPctText = showConfidencePct ? " " + str.tostring(math.round(bullConfidence)) + "%" : ""
bearPctText = showConfidencePct ? " " + str.tostring(math.round(bearConfidence)) + "%" : ""
bullLabelText = "Bull" + bullStarText + bullPctText
bearLabelText = "Bear" + bearStarText + bearPctText

bullLabelColor = bullGrade == 3 ? color.new(color.lime, 0) : bullGrade == 2 ? color.new(color.green, 15) : bullGrade == 1 ? color.new(color.green, 35) : color.new(color.lime, 0)
bearLabelColor = bearGrade == 3 ? color.new(color.red, 0) : bearGrade == 2 ? color.new(color.maroon, 15) : bearGrade == 1 ? color.new(color.red, 35) : color.new(color.red, 0)

hOb = hline(obLevel, "Overbought", color=color.new(color.red, 45), linestyle=hline.style_dotted)
hMid = hline(midLevel, "Middle", color=color.new(color.gray, 42), linestyle=hline.style_dashed)
hOs = hline(osLevel, "Oversold", color=color.new(color.lime, 45), linestyle=hline.style_dotted)
hTop = hline(100, "RSI 100", color=color.new(color.gray, 100))
hBottom = hline(0, "RSI 0", color=color.new(color.gray, 100))

fill(hTop, hOb, color=showBgZones ? color.new(color.red, 95) : na, title="Overbought Zone")
fill(hOs, hBottom, color=showBgZones ? color.new(color.green, 95) : na, title="Oversold Zone")

rsiColor = rsiBullTone ? color.new(color.lime, 0) : rsiBearTone ? color.new(color.red, 0) : color.new(color.white, 0)
signalColor = color.new(color.orange, 48)

plotRsi = plot(rsi, "RSI", color=rsiColor, linewidth=2)
plotSignal = plot(showSignalLine ? rsiSignal : na, "RSI Signal MA", color=signalColor, linewidth=1)

fill(plotRsi, plotSignal, color=showRsiFill ? (rsi >= rsiSignal ? color.new(color.green, 93) : color.new(color.red, 93)) : na, title="RSI Signal Fill")

ribbonLevel = 6.0
ribbonColor = rsiBullTone ? color.new(color.lime, 42) : rsiBearTone ? color.new(color.red, 42) : color.new(color.gray, 75)
plot(showTrendRibbon ? ribbonLevel : na, "Momentum Tone Ribbon", color=ribbonColor, linewidth=2)

plotshape(rsiStrongBull ? midLevel - 5.0 : na, title="RSI Strong Recover", style=shape.labelup, text="RSI+", location=location.absolute, color=color.new(color.lime, 0), textcolor=color.white, size=size.tiny)
plotshape(rsiStrongBear ? midLevel + 5.0 : na, title="RSI Strong Lost", style=shape.labeldown, text="RSI-", location=location.absolute, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

plotshape(rsiMaBull ? rsi : na, title="RSI MA Bull Cross", style=shape.triangleup, text="MA↑", location=location.absolute, color=color.new(color.teal, 0), textcolor=color.white, size=size.tiny)
plotshape(rsiMaBear ? rsi : na, title="RSI MA Bear Cross", style=shape.triangledown, text="MA↓", location=location.absolute, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

plotshape(rsiOB ? obLevel + 3.0 : na, title="RSI Overbought", style=shape.labeldown, text="OB", location=location.absolute, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
plotshape(rsiOS ? osLevel - 3.0 : na, title="RSI Oversold", style=shape.labelup, text="OS", location=location.absolute, color=color.new(color.lime, 0), textcolor=color.white, size=size.tiny)

if bullDiv
    label.new(currentPivotLowBar, currentPivotLowRsi - 5.0, bullLabelText, xloc=xloc.bar_index, style=label.style_label_up, color=bullLabelColor, textcolor=color.white, size=size.small)

if bearDiv
    label.new(currentPivotHighBar, currentPivotHighRsi + 5.0, bearLabelText, xloc=xloc.bar_index, style=label.style_label_down, color=bearLabelColor, textcolor=color.white, size=size.small)

plotshape(hiddenBullDiv ? currentPivotLowRsi - 5.0 : na, title="Hidden Bullish Divergence", style=shape.labelup, text="H-Bull", location=location.absolute, color=color.new(color.teal, 0), textcolor=color.white, size=size.tiny, offset=-divRight)
plotshape(hiddenBearDiv ? currentPivotHighRsi + 5.0 : na, title="Hidden Bearish Divergence", style=shape.labeldown, text="H-Bear", location=location.absolute, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny, offset=-divRight)

if showGuideLabels and barstate.islast
    label.new(bar_index, obLevel, "Overbought", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)
    label.new(bar_index, midLevel, "RSI 50", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.gray, 70), textcolor=color.white, size=size.tiny)
    label.new(bar_index, osLevel, "Oversold", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)

alertcondition(bullDiv and bullGrade == 3, title="Strong Bullish RSI Divergence", message="Strong bullish RSI divergence detected.")
alertcondition(bullDiv and bullGrade == 2, title="Normal Bullish RSI Divergence", message="Normal bullish RSI divergence detected.")
alertcondition(bullDiv and bullGrade == 1, title="Weak Bullish RSI Divergence", message="Weak bullish RSI divergence detected.")
alertcondition(bearDiv and bearGrade == 3, title="Strong Bearish RSI Divergence", message="Strong bearish RSI divergence detected.")
alertcondition(bearDiv and bearGrade == 2, title="Normal Bearish RSI Divergence", message="Normal bearish RSI divergence detected.")
alertcondition(bearDiv and bearGrade == 1, title="Weak Bearish RSI Divergence", message="Weak bearish RSI divergence detected.")
alertcondition(hiddenBullDiv, title="Hidden Bullish RSI Divergence", message="Hidden bullish RSI divergence detected.")
alertcondition(hiddenBearDiv, title="Hidden Bearish RSI Divergence", message="Hidden bearish RSI divergence detected.")
alertcondition(rsiStrongBull, title="RSI Strong Recovery", message="RSI recovered above the midline with strength.")
alertcondition(rsiStrongBear, title="RSI Strong Loss", message="RSI lost the midline with weakness.")
````
