# Adaptive SuperTrend Map | Alpha S+

- url: https://www.tradingview.com/script/y1z2be1a-Adaptive-SuperTrend-Map-Alpha-S/
- type: indicator
- pine_id: PUB;918fe4f3828949c6b023e4d8ec0b7962
- version: 1.0

## Description

Adaptive SuperTrend Map | Alpha S+

Adaptive SuperTrend Map is a trend-following and regime-aware SuperTrend tool built on the standard SuperTrend calculation structure.

It uses a classic ATR-based SuperTrend formula, then adds an adaptive multiplier, market-regime filtering, flip confirmation logic, and a smoother curved visual line for cleaner chart presentation.

The main purpose of this script is to help users study trend direction, trend-following structure, volatility-adjusted trailing levels, and changing market conditions directly on the price chart.

────────────────────
Core Concept
────────────────────

The core idea of this script is to keep the logic of a standard SuperTrend while improving how it adapts to different market environments.

A normal SuperTrend uses:

• a source price
• ATR
• an ATR multiplier
• upper and lower trailing bands
• trend direction changes when price crosses the previous active band

This script keeps that structure but adds adaptive behavior.

The multiplier can adjust based on:

• relative volatility expansion or contraction
• ADX-based trend or chop conditions
• user-defined minimum and maximum multiplier limits

This means the SuperTrend can become more conservative during choppy conditions and more responsive during stronger trend conditions, depending on the selected settings.

The script also separates the calculation logic from the visual display.

The raw SuperTrend line is used for trend direction, flip logic, and alerts.

The curved visual line is used only for chart readability, allowing the trend path to appear smoother without replacing the underlying calculation logic.

────────────────────
What This Script Shows
────────────────────

This script can display:

• adaptive SuperTrend line
• curved visual trend line
• optional raw SuperTrend reference line
• bullish trend flips
• bearish trend flips
• regime ribbon
• current trend state label
• chop / wait state
• adaptive multiplier value
• ADX-based market regime
• volatility ratio between fast ATR and slow ATR

The visual structure is designed to help users quickly see whether the market is trending upward, trending downward, or moving through a weaker sideways environment.

────────────────────
How It Works
────────────────────

1. The script calculates ATR using the selected ATR method.
2. It builds standard SuperTrend upper and lower bands using the selected source price and multiplier.
3. The trend direction changes when price closes beyond the previous active SuperTrend band.
4. The active SuperTrend line becomes the trailing reference for the current trend.
5. The script measures relative volatility by comparing fast ATR and slow ATR.
6. ADX is used to classify whether the market is closer to a trend condition or a choppy condition.
7. The base multiplier can be adjusted upward or downward depending on volatility and regime conditions.
8. Optional flip filters can require EMA position, minimum ADX, and candle body confirmation.
9. The raw SuperTrend line remains the logic reference for trend direction and alerts.
10. The curved visual line smooths the displayed SuperTrend path for better chart readability.
11. A regime ribbon can be displayed around the visual line to emphasize the current trend environment.
12. A current-state label can display trend state, multiplier, ADX, curve mode, and ATR mode.

This structure is designed to keep the indicator understandable while adding adaptive behavior to the classic SuperTrend framework.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• ATR period
• source price
• base multiplier
• ATR calculation method
• adaptive multiplier on/off
• minimum multiplier
• maximum multiplier
• fast ATR length
• slow ATR length
• volatility sensitivity
• ADX length
• ADX smoothing
• chop ADX threshold
• trend ADX threshold
• chop multiplier adjustment
• trend multiplier adjustment
• flip quality filter
• EMA filter length
• minimum ADX for flip markers
• candle body confirmation
• minimum body size relative to ATR
• curved visual line on/off
• curve smoothing mode
• curve smoothing length
• curve reset on trend flip
• raw line reference
• main line visibility
• glow line visibility
• flip markers
• regime ribbon
• current state label
• background highlight
• line width
• glow width
• colors and transparency

These settings allow the script to be adjusted for different symbols, timeframes, and trading styles.

────────────────────
Visual Elements
────────────────────

The script includes several visual elements:

• Main SuperTrend line:
Shows the active adaptive SuperTrend path.

• Glow line:
Adds a wider transparent layer around the main line for better visibility.

• Curved visual line:
Smooths the displayed SuperTrend path while keeping raw SuperTrend logic as the calculation reference.

• Raw SuperTrend reference:
Optional line that shows the unsmoothed SuperTrend value.

• UP / DN markers:
Optional markers that appear when filtered bullish or bearish trend flips are detected.

• Regime ribbon:
A subtle ribbon around the SuperTrend line that helps visualize the current trend or chop state.

• Current state label:
Displays the current trend state, adaptive multiplier, ADX, curve mode, and ATR mode.

• Optional background:
Can lightly highlight bullish, bearish, or chop environments.

────────────────────
Reference States
────────────────────

Trend Up:
The active SuperTrend direction is bullish. Price has moved above the previous bearish band and the trend state is upward.

Trend Down:
The active SuperTrend direction is bearish. Price has moved below the previous bullish band and the trend state is downward.

Chop / Wait:
ADX is below the selected chop threshold. This indicates that the environment may be weaker, more sideways, or less suitable for aggressive trend-following interpretation.

Bullish Flip:
A bullish transition occurs when the SuperTrend changes from bearish to bullish. If flip filtering is enabled, the marker appears only when the additional quality conditions are met.

Bearish Flip:
A bearish transition occurs when the SuperTrend changes from bullish to bearish. If flip filtering is enabled, the marker appears only when the additional quality conditions are met.

Adaptive Multiplier:
The multiplier can expand or contract based on volatility and regime conditions. This helps the SuperTrend behave differently in trend and chop environments.

Curved Visual Line:
The curved line is a display layer. It is designed for readability and does not replace the raw SuperTrend calculation used for direction and alerts.

────────────────────
How To Use
────────────────────

This script can be used as a trend structure and regime filter.

General interpretation examples:

• When the SuperTrend line is below price and the trend state is bullish, the market is in an upward SuperTrend structure.
• When the SuperTrend line is above price and the trend state is bearish, the market is in a downward SuperTrend structure.
• UP markers can highlight bullish trend flip conditions.
• DN markers can highlight bearish trend flip conditions.
• When the script shows a chop or wait condition, trend-following signals may require more caution.
• The regime ribbon can help users visually separate cleaner trend environments from weaker or more uncertain conditions.
• The raw reference line can be enabled when users want to compare the smoothed visual line with the underlying calculation line.

This script is best used together with price action, support and resistance, volume, volatility, momentum, and higher-timeframe context.

It should be treated as a trend-following structure tool, not as a standalone entry or exit system.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script uses standard SuperTrend-style bar-based logic.

Trend direction and flip conditions are based on the raw SuperTrend calculation.

The curved visual line is only a smoothing layer for display. It is not intended to replace the raw trend logic.

On realtime candles, values can update before the candle closes because price, ATR, ADX, and volatility conditions can still change intrabar.

For more conservative interpretation, users should wait for candle close confirmation before acting on trend flips or state changes.

The script does not use future price data to predict market direction.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not identify exact tops or bottoms.

It does not guarantee that a SuperTrend flip will lead to a sustained trend.

Like most trend-following tools, it can react late during sharp reversals.

In sideways or noisy markets, false flips can still occur.

The adaptive multiplier may reduce some noise, but it cannot remove all false signals.

Different symbols and timeframes may require different settings.

The curved visual line can make the chart easier to read, but users should remember that raw SuperTrend logic is the actual calculation reference.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to trade any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Adaptive SuperTrend Map | Alpha S+

Adaptive SuperTrend Map은 표준 SuperTrend 계산 구조를 기반으로 만든 추세 추종 및 시장 상태 분석 지표입니다.

기본적인 ATR 기반 SuperTrend 공식에 adaptive multiplier, 시장 상태 필터, 추세 전환 확인 로직, 그리고 더 부드러운 곡선형 시각화 라인을 결합했습니다.

이 스크립트의 목적은 추세 방향, 추세 추적 구조, 변동성 기반 trailing level, 그리고 변화하는 시장 상태를 가격 차트 위에서 직접 분석할 수 있도록 돕는 것입니다.

────────────────────
핵심 개념
────────────────────

이 스크립트의 핵심은 표준 SuperTrend의 논리를 유지하면서, 다양한 시장 환경에 더 유연하게 반응하도록 만드는 것입니다.

일반적인 SuperTrend는 다음 요소를 사용합니다.

• 기준 가격
• ATR
• ATR multiplier
• 상단 및 하단 trailing band
• 가격이 이전 활성 밴드를 돌파하면 추세 방향 전환

이 스크립트는 이 구조를 유지하면서 adaptive behavior를 추가합니다.

Multiplier는 다음 조건에 따라 조정될 수 있습니다.

• 상대적인 변동성 확대 또는 축소
• ADX 기반 추세 또는 횡보 상태
• 사용자가 설정한 최소 및 최대 multiplier 제한

이를 통해 SuperTrend는 횡보 구간에서는 더 보수적으로, 강한 추세 구간에서는 더 민감하게 반응할 수 있습니다.

또한 이 스크립트는 계산 논리와 시각적 표시를 분리합니다.

Raw SuperTrend line은 추세 방향, 전환 판단, 알림 조건의 기준으로 사용됩니다.

Curved visual line은 차트 가독성을 위한 표시용 라인으로 사용되며, 실제 계산 논리를 대체하지 않습니다.

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• adaptive SuperTrend line
• 곡선형 visual trend line
• 선택 가능한 raw SuperTrend reference line
• 상승 추세 전환
• 하락 추세 전환
• regime ribbon
• 현재 추세 상태 라벨
• chop / wait 상태
• adaptive multiplier 값
• ADX 기반 시장 상태
• fast ATR과 slow ATR 사이의 변동성 비율

이 시각 구조는 시장이 상승 추세인지, 하락 추세인지, 또는 약한 횡보 환경인지 빠르게 파악하는 데 도움을 주도록 설계되었습니다.

────────────────────
작동 방식
────────────────────

1. 스크립트는 선택된 ATR 방식으로 ATR을 계산합니다.
2. 선택한 기준 가격과 multiplier를 사용해 표준 SuperTrend 상단 및 하단 밴드를 만듭니다.
3. 가격이 이전 활성 SuperTrend band를 종가 기준으로 벗어나면 추세 방향이 전환됩니다.
4. 활성 SuperTrend line은 현재 추세의 trailing reference 역할을 합니다.
5. Fast ATR과 Slow ATR을 비교해 상대적인 변동성 상태를 측정합니다.
6. ADX를 사용해 시장이 추세 환경에 가까운지, 횡보 환경에 가까운지 분류합니다.
7. 기본 multiplier는 변동성과 시장 상태에 따라 위아래로 조정될 수 있습니다.
8. 선택형 flip filter는 EMA 위치, 최소 ADX, 캔들 몸통 확인 조건을 요구할 수 있습니다.
9. Raw SuperTrend line은 추세 방향과 알림의 기준으로 유지됩니다.
10. Curved visual line은 차트 가독성을 위해 SuperTrend 경로를 부드럽게 표시합니다.
11. Regime ribbon은 현재 추세 환경을 더 시각적으로 보여줄 수 있습니다.
12. Current state label은 추세 상태, multiplier, ADX, curve mode, ATR mode를 표시할 수 있습니다.

이 구조는 클래식 SuperTrend의 이해하기 쉬운 구조를 유지하면서 adaptive behavior를 추가하기 위해 설계되었습니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• ATR period
• 기준 가격
• 기본 multiplier
• ATR 계산 방식
• adaptive multiplier 사용 여부
• 최소 multiplier
• 최대 multiplier
• fast ATR length
• slow ATR length
• volatility sensitivity
• ADX length
• ADX smoothing
• chop ADX threshold
• trend ADX threshold
• chop multiplier adjustment
• trend multiplier adjustment
• flip quality filter
• EMA filter length
• flip marker용 최소 ADX
• 캔들 몸통 확인 조건
• ATR 대비 최소 몸통 크기
• 곡선형 visual line 사용 여부
• curve smoothing 방식
• curve smoothing length
• 추세 전환 시 curve reset 여부
• raw line reference
• main line 표시 여부
• glow line 표시 여부
• flip marker
• regime ribbon
• current state label
• background highlight
• line width
• glow width
• 색상 및 투명도

이 설정들을 통해 서로 다른 종목, 시간대, 매매 스타일에 맞게 조정할 수 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• Main SuperTrend line:
활성 adaptive SuperTrend 경로를 보여줍니다.

• Glow line:
메인 라인 주변에 더 넓은 반투명 레이어를 추가해 가시성을 높입니다.

• Curved visual line:
Raw SuperTrend logic은 유지하면서, 화면에 표시되는 SuperTrend 경로를 더 부드럽게 보여줍니다.

• Raw SuperTrend reference:
스무딩되지 않은 SuperTrend 값을 확인할 수 있는 선택형 라인입니다.

• UP / DN markers:
필터링된 상승 또는 하락 추세 전환이 감지될 때 나타나는 선택형 마커입니다.

• Regime ribbon:
SuperTrend line 주변에 표시되는 얇은 리본으로, 현재 추세 또는 횡보 상태를 시각적으로 구분하는 데 도움을 줍니다.

• Current state label:
현재 추세 상태, adaptive multiplier, ADX, curve mode, ATR mode를 표시합니다.

• Optional background:
상승, 하락, 횡보 환경을 약하게 배경으로 강조할 수 있습니다.

────────────────────
참고 상태
────────────────────

Trend Up:
활성 SuperTrend 방향이 상승 상태입니다. 가격이 이전 bearish band 위로 이동했고, 추세 상태가 상승으로 전환된 상태입니다.

Trend Down:
활성 SuperTrend 방향이 하락 상태입니다. 가격이 이전 bullish band 아래로 이동했고, 추세 상태가 하락으로 전환된 상태입니다.

Chop / Wait:
ADX가 설정된 chop threshold보다 낮은 상태입니다. 이는 시장 환경이 약하거나, 횡보 성격이 강하거나, 공격적인 추세 추종 해석에 적합하지 않을 수 있음을 의미합니다.

Bullish Flip:
SuperTrend가 하락에서 상승으로 전환되는 상태입니다. Flip filter가 켜져 있으면 추가 품질 조건이 충족될 때만 마커가 표시됩니다.

Bearish Flip:
SuperTrend가 상승에서 하락으로 전환되는 상태입니다. Flip filter가 켜져 있으면 추가 품질 조건이 충족될 때만 마커가 표시됩니다.

Adaptive Multiplier:
변동성과 시장 상태에 따라 multiplier가 확장되거나 축소될 수 있습니다. 이는 SuperTrend가 추세와 횡보 환경에서 다르게 반응하도록 돕습니다.

Curved Visual Line:
곡선형 라인은 표시용 레이어입니다. 방향과 알림에 사용되는 raw SuperTrend 계산을 대체하지 않습니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 추세 구조와 시장 상태를 확인하는 필터로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• SuperTrend line이 가격 아래에 있고 추세 상태가 bullish라면 상승 SuperTrend 구조로 볼 수 있습니다.
• SuperTrend line이 가격 위에 있고 추세 상태가 bearish라면 하락 SuperTrend 구조로 볼 수 있습니다.
• UP marker는 상승 추세 전환 조건을 보여줄 수 있습니다.
• DN marker는 하락 추세 전환 조건을 보여줄 수 있습니다.
• 스크립트가 chop 또는 wait 상태를 표시할 때는 추세 추종 신호를 더 보수적으로 해석하는 것이 좋습니다.
• Regime ribbon은 더 깨끗한 추세 환경과 약하거나 불확실한 구간을 시각적으로 구분하는 데 도움을 줄 수 있습니다.
• Raw reference line은 스무딩된 visual line과 실제 계산 라인을 비교하고 싶을 때 켤 수 있습니다.

이 스크립트는 가격 행동, 지지와 저항, 거래량, 변동성, 모멘텀, 상위 시간대 흐름과 함께 사용하는 것이 좋습니다.

단독 진입 또는 청산 시스템이 아니라, 추세 추종 구조 분석 도구로 보는 것이 적절합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 표준 SuperTrend 방식의 봉 기반 로직을 사용합니다.

추세 방향과 flip 조건은 raw SuperTrend 계산값을 기준으로 합니다.

Curved visual line은 표시를 위한 smoothing layer일 뿐, raw trend logic을 대체하지 않습니다.

실시간 캔들에서는 가격, ATR, ADX, 변동성 조건이 봉 마감 전까지 변할 수 있으므로 값이 변동될 수 있습니다.

보다 보수적인 해석을 원한다면 추세 전환 또는 상태 변경은 봉 마감 이후 확인하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

정확한 고점 또는 저점을 식별하기 위한 도구가 아닙니다.

SuperTrend flip이 지속적인 추세로 이어진다는 보장은 없습니다.

대부분의 추세 추종형 도구처럼 급격한 반전 구간에서는 반응이 늦을 수 있습니다.

횡보 또는 노이즈가 많은 시장에서는 false flip이 발생할 수 있습니다.

Adaptive multiplier는 일부 노이즈를 줄이는 데 도움을 줄 수 있지만, 모든 가짜 신호를 제거하지는 못합니다.

종목과 시간대에 따라 다른 설정이 필요할 수 있습니다.

곡선형 visual line은 차트 가독성을 높일 수 있지만, raw SuperTrend logic이 실제 계산 기준이라는 점을 기억해야 합니다.

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
indicator("Adaptive SuperTrend Map | Alpha S+", shorttitle="AST Map", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// Build: V1.2 Standard SuperTrend Formula Verified + Curved Visual Line

groupCore = "SuperTrend Core"
atrLen = input.int(10, "ATR Period", minval=1, maxval=300, group=groupCore)
src = input.source(hl2, "Source", group=groupCore)
baseFactor = input.float(3.0, "Base Multiplier", minval=0.5, maxval=20.0, step=0.1, group=groupCore)
atrMode = input.string("RMA ATR", "ATR Calculation Method", options=["RMA ATR", "SMA True Range"], group=groupCore)
useAdaptiveFactor = input.bool(true, "Use Adaptive Multiplier", group=groupCore)
minFactor = input.float(1.6, "Minimum Multiplier", minval=0.5, maxval=20.0, step=0.1, group=groupCore)
maxFactor = input.float(5.5, "Maximum Multiplier", minval=0.5, maxval=20.0, step=0.1, group=groupCore)

groupAdaptive = "Adaptive Multiplier Logic"
volFastLen = input.int(14, "Fast ATR Length", minval=1, maxval=200, group=groupAdaptive)
volSlowLen = input.int(80, "Slow ATR Length", minval=5, maxval=500, group=groupAdaptive)
volSensitivity = input.float(1.0, "Volatility Sensitivity", minval=0.0, maxval=5.0, step=0.1, group=groupAdaptive)
adxLen = input.int(14, "ADX Length", minval=5, maxval=100, group=groupAdaptive)
adxSmooth = input.int(14, "ADX Smoothing", minval=5, maxval=100, group=groupAdaptive)
chopAdx = input.float(18.0, "Chop ADX", minval=5.0, maxval=50.0, step=0.5, group=groupAdaptive)
trendAdx = input.float(25.0, "Trend ADX", minval=5.0, maxval=60.0, step=0.5, group=groupAdaptive)
chopFactorAdd = input.float(0.8, "Chop Multiplier Add", minval=0.0, maxval=5.0, step=0.1, group=groupAdaptive)
trendFactorReduce = input.float(0.4, "Trend Multiplier Reduce", minval=0.0, maxval=5.0, step=0.1, group=groupAdaptive)

groupConfirm = "Flip Confirmation"
useFlipFilter = input.bool(true, "Use Flip Quality Filter", group=groupConfirm)
emaFilterLen = input.int(50, "EMA Filter Length", minval=5, maxval=300, group=groupConfirm)
minFlipAdx = input.float(16.0, "Minimum ADX For Flip Marker", minval=5.0, maxval=60.0, step=0.5, group=groupConfirm)
useBodyConfirm = input.bool(true, "Use Body Confirmation", group=groupConfirm)
minBodyAtr = input.float(0.18, "Minimum Body / ATR", minval=0.0, maxval=3.0, step=0.05, group=groupConfirm)

groupCurve = "Curved Visual Line"
useCurvedLine = input.bool(true, "Use Curved Visual Line", group=groupCurve)
curveMode = input.string("EMA", "Curve Mode", options=["EMA", "RMA", "Hybrid"], group=groupCurve)
curveLength = input.int(5, "Curve Smooth Length", minval=1, maxval=50, group=groupCurve)
resetCurveOnFlip = input.bool(true, "Reset Curve On Trend Flip", group=groupCurve)
showRawLine = input.bool(false, "Show Raw SuperTrend Reference", group=groupCurve)
rawLineTransparency = input.int(78, "Raw Line Transparency", minval=0, maxval=100, group=groupCurve)

groupVisual = "Visual"
showMainLine = input.bool(true, "Show SuperTrend Line", group=groupVisual)
showGlow = input.bool(true, "Show Glow Line", group=groupVisual)
showFlipMarkers = input.bool(true, "Show Flip Markers", group=groupVisual)
showRegimeRibbon = input.bool(true, "Show Regime Ribbon", group=groupVisual)
showStateLabel = input.bool(true, "Show Current State Label", group=groupVisual)
showBackground = input.bool(false, "Show Background", group=groupVisual)
lineWidth = input.int(3, "Line Width", minval=1, maxval=6, group=groupVisual)
glowWidth = input.int(8, "Glow Width", minval=2, maxval=14, group=groupVisual)
labelOffsetAtr = input.float(1.0, "State Label Offset / ATR", minval=0.1, maxval=5.0, step=0.1, group=groupVisual)
labelXOffset = input.int(3, "State Label X Offset", minval=0, maxval=50, group=groupVisual)

groupStyle = "Colors"
bullColor = input.color(color.rgb(30, 220, 120), "Bull Trend Color", group=groupStyle)
bearColor = input.color(color.rgb(255, 85, 95), "Bear Trend Color", group=groupStyle)
neutralColor = input.color(color.rgb(130, 145, 165), "Neutral / Chop Color", group=groupStyle)
ribbonBullColor = input.color(color.rgb(30, 220, 120), "Bull Ribbon Color", group=groupStyle)
ribbonBearColor = input.color(color.rgb(255, 85, 95), "Bear Ribbon Color", group=groupStyle)
ribbonChopColor = input.color(color.rgb(120, 145, 180), "Chop Ribbon Color", group=groupStyle)
ribbonTransparency = input.int(88, "Ribbon Transparency", minval=60, maxval=98, group=groupStyle)
backgroundTransparency = input.int(94, "Background Transparency", minval=80, maxval=98, group=groupStyle)

//====================================================
// HELPERS
//====================================================
f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_smooth(_prev, _value, _len, _mode) =>
    alphaEma = 2.0 / (_len + 1.0)
    alphaRma = 1.0 / _len
    alphaHybrid = (alphaEma + alphaRma) * 0.5
    alpha = _mode == "EMA" ? alphaEma : _mode == "RMA" ? alphaRma : alphaHybrid
    na(_prev) ? _value : _prev + alpha * (_value - _prev)

//====================================================
// ATR CALCULATION
//====================================================
prevClose = nz(close[1], close)
trueRange = math.max(high - low, math.max(math.abs(high - prevClose), math.abs(low - prevClose)))

atrRma = ta.atr(atrLen)
atrSma = ta.sma(trueRange, atrLen)
atrBase = atrMode == "RMA ATR" ? atrRma : atrSma

atrFast = ta.atr(volFastLen)
atrSlow = ta.atr(volSlowLen)
volRatio = atrSlow > 0 ? atrFast / atrSlow : 1.0

//====================================================
// REGIME / ADAPTIVE MULTIPLIER
//====================================================
[diplus, diminus, adxVal] = ta.dmi(adxLen, adxSmooth)

emaFilter = ta.ema(close, emaFilterLen)
body = math.abs(close - open)
bodyAtr = atrBase > 0 ? body / atrBase : 0.0

isChop = adxVal <= chopAdx
isTrend = adxVal >= trendAdx

factorVolAdj = (volRatio - 1.0) * volSensitivity
factorRegimeAdj = isChop ? chopFactorAdd : isTrend ? -trendFactorReduce : 0.0
adaptiveFactorRaw = baseFactor + factorVolAdj + factorRegimeAdj
factor = useAdaptiveFactor ? f_clamp(adaptiveFactorRaw, minFactor, maxFactor) : baseFactor

//====================================================
// STANDARD SUPERTREND FORMULA
//====================================================
// Standard structure:
// up = source - multiplier * ATR
// dn = source + multiplier * ATR
// trend flips upward when close > previous dn
// trend flips downward when close < previous up

up = src - factor * atrBase
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up

dn = src + factor * atrBase
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

var int trendDir = 1
trendDir := nz(trendDir[1], trendDir)
trendDir := trendDir == -1 and close > dn1 ? 1 : trendDir == 1 and close < up1 ? -1 : trendDir

superTrendRaw = trendDir == 1 ? up : dn

rawBullFlip = trendDir == 1 and trendDir[1] == -1
rawBearFlip = trendDir == -1 and trendDir[1] == 1
rawFlip = rawBullFlip or rawBearFlip

//====================================================
// FLIP MARKER FILTER
//====================================================
bullFilterOk = not useFlipFilter or (close > emaFilter and adxVal >= minFlipAdx and (not useBodyConfirm or bodyAtr >= minBodyAtr))
bearFilterOk = not useFlipFilter or (close < emaFilter and adxVal >= minFlipAdx and (not useBodyConfirm or bodyAtr >= minBodyAtr))

bullFlip = rawBullFlip and bullFilterOk
bearFlip = rawBearFlip and bearFilterOk

//====================================================
// CURVED VISUAL LINE
//====================================================
var float curvedSuperTrend = na

curvedSuperTrend := not useCurvedLine ? superTrendRaw :
     resetCurveOnFlip and rawFlip ? superTrendRaw :
     f_smooth(curvedSuperTrend[1], superTrendRaw, curveLength, curveMode)

visualSuperTrend = useCurvedLine ? curvedSuperTrend : superTrendRaw

lineColor = isChop ? neutralColor : trendDir == 1 ? bullColor : bearColor
glowColor = color.new(lineColor, 74)

bullRawLine = trendDir == 1 ? superTrendRaw : na
bearRawLine = trendDir == -1 ? superTrendRaw : na

bullVisualLine = trendDir == 1 ? visualSuperTrend : na
bearVisualLine = trendDir == -1 ? visualSuperTrend : na

plot(showRawLine ? bullRawLine : na, "Raw SuperTrend Up", color=color.new(bullColor, rawLineTransparency), linewidth=1, style=plot.style_linebr)
plot(showRawLine ? bearRawLine : na, "Raw SuperTrend Down", color=color.new(bearColor, rawLineTransparency), linewidth=1, style=plot.style_linebr)

plot(showGlow ? bullVisualLine : na, "Curved SuperTrend Glow Up", color=color.new(bullColor, 76), linewidth=glowWidth, style=plot.style_linebr)
plot(showGlow ? bearVisualLine : na, "Curved SuperTrend Glow Down", color=color.new(bearColor, 76), linewidth=glowWidth, style=plot.style_linebr)

plot(showMainLine ? bullVisualLine : na, "Adaptive SuperTrend Up", color=lineColor, linewidth=lineWidth, style=plot.style_linebr)
plot(showMainLine ? bearVisualLine : na, "Adaptive SuperTrend Down", color=lineColor, linewidth=lineWidth, style=plot.style_linebr)

//====================================================
// REGIME RIBBON
//====================================================
ribbonTop = visualSuperTrend + atrBase * 0.10
ribbonBottom = visualSuperTrend - atrBase * 0.10

ribbonColor = isChop ? color.new(ribbonChopColor, ribbonTransparency) :
     trendDir == 1 ? color.new(ribbonBullColor, ribbonTransparency) :
     color.new(ribbonBearColor, ribbonTransparency)

pRibbonTop = plot(showRegimeRibbon ? ribbonTop : na, "Regime Ribbon Upper", color=color.new(lineColor, 100), display=display.none)
pRibbonBottom = plot(showRegimeRibbon ? ribbonBottom : na, "Regime Ribbon Lower", color=color.new(lineColor, 100), display=display.none)
fill(pRibbonTop, pRibbonBottom, color=ribbonColor, title="Regime Ribbon")

//====================================================
// MARKERS / BACKGROUND / LABEL
//====================================================
plotshape(showFlipMarkers and bullFlip ? superTrendRaw : na, title="Bullish SuperTrend Flip", style=shape.triangleup, location=location.absolute, color=color.new(bullColor, 0), text="UP", textcolor=color.white, size=size.tiny)
plotshape(showFlipMarkers and bearFlip ? superTrendRaw : na, title="Bearish SuperTrend Flip", style=shape.triangledown, location=location.absolute, color=color.new(bearColor, 0), text="DN", textcolor=color.white, size=size.tiny)

bgcolor(showBackground ? (isChop ? color.new(neutralColor, backgroundTransparency) : trendDir == 1 ? color.new(bullColor, backgroundTransparency) : color.new(bearColor, backgroundTransparency)) : na)

var label stateLabel = na

if barstate.islast and showStateLabel
    if not na(stateLabel)
        label.delete(stateLabel)

    stateText = isChop ? "CHOP / WAIT" : trendDir == 1 ? "TREND UP" : "TREND DOWN"
    factorText = "Mult " + str.tostring(factor, "#.##")
    adxText = "ADX " + str.tostring(adxVal, "#.#")
    curveText = useCurvedLine ? "Curve " + curveMode : "Raw"
    atrText = atrMode == "RMA ATR" ? "ATR RMA" : "ATR SMA"
    labelText = stateText + "\n" + factorText + " / " + adxText + "\n" + curveText + " / " + atrText

    labelY = trendDir == 1 ? high + atrBase * labelOffsetAtr : low - atrBase * labelOffsetAtr
    labelStyle = trendDir == 1 ? label.style_label_down : label.style_label_up
    labelColor = isChop ? neutralColor : trendDir == 1 ? bullColor : bearColor

    stateLabel := label.new(
         bar_index + labelXOffset,
         labelY,
         labelText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=labelStyle,
         color=color.new(labelColor, 10),
         textcolor=color.white,
         size=size.small)

//====================================================
// ALERTS
//====================================================
alertcondition(bullFlip, title="Bullish SuperTrend Flip", message="Adaptive SuperTrend Map: bullish flip detected.")
alertcondition(bearFlip, title="Bearish SuperTrend Flip", message="Adaptive SuperTrend Map: bearish flip detected.")
alertcondition(isChop, title="Chop Regime", message="Adaptive SuperTrend Map: chop regime detected.")
alertcondition(isTrend and trendDir == 1, title="Bull Trend Regime", message="Adaptive SuperTrend Map: bullish trend regime detected.")
alertcondition(isTrend and trendDir == -1, title="Bear Trend Regime", message="Adaptive SuperTrend Map: bearish trend regime detected.")

//====================================================
// DATA WINDOW
//====================================================
plot(factor, "Adaptive Multiplier", display=display.data_window)
plot(adxVal, "ADX", display=display.data_window)
plot(volRatio, "ATR Volatility Ratio", display=display.data_window)
plot(trendDir, "Trend Direction", display=display.data_window)
plot(superTrendRaw, "Raw SuperTrend", display=display.data_window)
plot(visualSuperTrend, "Visual SuperTrend", display=display.data_window)
plot(atrBase, "ATR Used", display=display.data_window)
````
