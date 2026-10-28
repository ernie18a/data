# Dynamic Swing Anchored VWAP | Alpha S+

- url: https://www.tradingview.com/script/dB77cXxH-Dynamic-Swing-Anchored-VWAP-Alpha-S/
- type: indicator
- pine_id: PUB;3d9a032c88934778bc5c3a9722f1f8d1
- version: 1.0

## Description

Dynamic Swing Anchored VWAP

Dynamic Swing Anchored VWAP is a swing-based VWAP tool designed to help users study how price behaves around a dynamically anchored volume-weighted average price.

Instead of anchoring VWAP to a fixed session, date, or manually selected point, this script updates its anchor from detected swing changes. The result is a VWAP reference that follows the latest swing structure and adapts to changing market conditions.

The script does not provide entry or exit recommendations. Its purpose is to help users study swing direction, VWAP position, distance from VWAP, and context around swing-based support or resistance behavior.

────────────────────
Core Concept
────────────────────

VWAP is commonly used as a volume-weighted reference level.

Traditional VWAP often resets by session or uses a fixed anchor point.

This script uses a different approach.

It detects swing changes using recent high and low behavior, then recalculates a dynamic anchored VWAP from the latest swing anchor area.

The main concept is:

• detect the current swing direction
• anchor the VWAP calculation from the latest swing change
• smooth the VWAP tracking behavior
• optionally adapt the tracking speed to volatility
• compare current price with the swing-anchored VWAP
• visualize whether price is above, below, or near the VWAP reference
• use a compact chart label and context ribbon instead of relying on a large status panel

This makes the indicator useful as a visual swing-context VWAP reference rather than a simple static VWAP line.

────────────────────
What This Script Shows
────────────────────

The script can display:

• dynamic swing-anchored VWAP line
• VWAP glow line
• VWAP context ribbon
• bullish or bearish VWAP line color
• swing direction background
• optional swing point labels
• compact chart-based context label
• distance from VWAP in percentage
• swing flip anchor dots
• optional status panel
• alert conditions for VWAP crosses and swing flips

These elements are designed to help users identify whether price is holding above or below the current swing-based VWAP reference.

────────────────────
How It Works
────────────────────

1. The script scans recent highs and lows using the selected swing detection sensitivity.
2. The latest swing high and swing low areas are tracked.
3. Swing direction is determined by comparing the latest high and low swing locations.
4. When swing direction changes, the script updates the VWAP anchor.
5. The VWAP calculation uses price-volume accumulation with adaptive smoothing.
6. If volatility adaptation is enabled, tracking speed adjusts according to the ATR volatility ratio.
7. The script calculates the percentage distance between price and the swing-anchored VWAP.
8. Price above the VWAP with bullish swing direction is classified as bullish context.
9. Price below the VWAP with bearish swing direction is classified as bearish context.
10. Strong context is detected when price is far enough from VWAP using the selected distance threshold.
11. A context ribbon is drawn around the VWAP to make the active VWAP zone easier to read.
12. A compact chart label summarizes the current context and VWAP distance.
13. Optional anchor dots show where swing direction flips occur.
14. Optional alerts can notify VWAP crosses, swing flips, and strong context states.

This structure helps users study the relationship between price, swing direction, and volume-weighted reference behavior.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• swing detection sensitivity
• base price tracking speed
• volatility adaptation
• volatility sensitivity
• ATR period
• strong distance percentage
• VWAP line thickness
• VWAP glow line visibility
• VWAP context ribbon visibility
• ribbon width based on ATR
• direction background visibility
• swing point label visibility
• anchor dot visibility
• bullish VWAP color
• bearish VWAP color
• neutral color
• swing point color
• compact context label visibility
• label offset
• label ATR offset
• status panel visibility
• panel position
• panel size
• alert settings

The default settings are designed to keep the chart clean while making the VWAP context readable directly on the price chart.

────────────────────
Visual Elements
────────────────────

The script includes:

• main VWAP line
• glow line
• VWAP context ribbon
• compact context label
• optional swing labels
• optional anchor dots
• optional status panel

The main VWAP line shows the active dynamic swing-anchored VWAP.

The glow line makes the VWAP reference more visible without adding extra signals.

The context ribbon creates a soft VWAP zone around the line, helping users see whether price is holding near or away from the swing-based VWAP reference.

The compact chart label summarizes the current context without requiring a large panel.

Anchor dots mark swing direction changes in a minimal way.

────────────────────
Reference States
────────────────────

Strong Above VWAP:
Price is above the swing-anchored VWAP, swing direction is bullish, and the distance from VWAP is above the selected threshold.

Above Swing VWAP:
Price is above the swing-anchored VWAP while the swing direction supports the bullish context.

Strong Below VWAP:
Price is below the swing-anchored VWAP, swing direction is bearish, and the distance from VWAP is below the negative threshold.

Below Swing VWAP:
Price is below the swing-anchored VWAP while the swing direction supports the bearish context.

Neutral VWAP:
Price position and swing direction are not aligned strongly enough to define a clear context.

Bullish Swing Flip:
Swing direction changed into a bullish swing state.

Bearish Swing Flip:
Swing direction changed into a bearish swing state.

These states are informational and should not be interpreted as trading instructions.

────────────────────
How To Use
────────────────────

Use this script as a swing-based VWAP context viewer.

General interpretation examples:

• When price holds above the dynamic swing-anchored VWAP, users can study whether the current swing structure is maintaining positive VWAP context.
• When price stays below the dynamic swing-anchored VWAP, users can study whether the current swing structure is maintaining negative VWAP context.
• A wider distance from VWAP can show stronger separation from the current swing-based volume reference.
• The context ribbon can help users identify whether price is interacting with the VWAP zone or moving away from it.
• Swing flip anchor dots can help users review where the VWAP anchor logic changed direction.
• The compact label can be used for quick context reading without adding a large status panel.
• The optional panel can be enabled for more detailed review, but the main interpretation is designed to happen directly on the chart.

This script is best reviewed together with price action, volume, volatility, support and resistance, trend structure, and higher-timeframe context.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script uses recent high and low behavior to detect swing direction.

Swing direction and the VWAP anchor can update when new highs or lows appear inside the selected sensitivity window.

The dynamic VWAP line recalculates as price and volume update.

On realtime candles, values can change before the candle closes because price, volume, ATR, and swing conditions can update intrabar.

For more conservative analysis, users should evaluate context after candle confirmation.

The script does not use future price data to predict market direction.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide entry or exit recommendations.

A price cross above or below VWAP does not guarantee trend continuation.

Strong distance from VWAP can represent strength, extension, or stretched conditions depending on broader context.

Swing detection sensitivity can materially change how often the anchor updates.

In choppy markets, swing direction and VWAP context may change frequently.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to trade any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Dynamic Swing Anchored VWAP

Dynamic Swing Anchored VWAP은 스윙 변화에 따라 동적으로 기준점이 갱신되는 VWAP 도구입니다. 가격이 현재 스윙 기반 volume-weighted average price 주변에서 어떻게 움직이는지 분석하는 데 사용됩니다.

이 스크립트는 고정된 세션, 날짜, 수동 앵커 지점에 VWAP을 고정하지 않습니다. 대신 감지된 스윙 변화에 따라 앵커를 갱신합니다. 그 결과 최신 스윙 구조를 따라가며 변화하는 시장 조건에 적응하는 VWAP 기준선을 제공합니다.

이 지표는 진입 또는 청산 추천을 제공하지 않습니다. 목적은 스윙 방향, VWAP 대비 가격 위치, VWAP과의 거리, 그리고 스윙 기반 지지·저항 컨텍스트를 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

VWAP은 거래량을 반영한 기준 가격으로 자주 사용됩니다.

일반적인 VWAP은 세션 기준으로 초기화되거나 고정된 앵커 지점을 사용합니다.

이 스크립트는 다른 접근 방식을 사용합니다.

최근 고점과 저점 행동을 사용해 스윙 변화를 감지하고, 최신 스윙 앵커 구간을 기준으로 dynamic anchored VWAP을 다시 계산합니다.

핵심 개념은 다음과 같습니다.

• 현재 스윙 방향 감지
• 최신 스윙 변화 구간에서 VWAP 계산 기준 갱신
• VWAP tracking behavior 평활화
• 선택적으로 변동성에 따라 tracking speed 조정
• 현재 가격과 swing-anchored VWAP 비교
• 가격이 VWAP 위, 아래, 또는 근처에 있는지 시각화
• 큰 상태 패널 대신 compact chart label과 context ribbon 중심으로 표시

이 구조는 단순 고정 VWAP 라인이 아니라, 스윙 컨텍스트 기반 VWAP 기준선을 시각적으로 보여주는 데 적합합니다.

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• dynamic swing-anchored VWAP line
• VWAP glow line
• VWAP context ribbon
• bullish 또는 bearish VWAP line color
• swing direction background
• 선택 가능한 swing point labels
• compact chart-based context label
• VWAP과의 percentage distance
• swing flip anchor dots
• 선택 가능한 status panel
• VWAP cross 및 swing flip alert conditions

이 요소들은 가격이 현재 스윙 기반 VWAP 기준선 위 또는 아래에서 유지되고 있는지 확인하는 데 도움을 줍니다.

────────────────────
작동 방식
────────────────────

1. 선택한 swing detection sensitivity를 기준으로 최근 고점과 저점을 스캔합니다.
2. 최신 swing high와 swing low 구간을 추적합니다.
3. 최신 high swing과 low swing 위치를 비교해 swing direction을 판단합니다.
4. Swing direction이 바뀌면 VWAP anchor를 갱신합니다.
5. VWAP 계산은 price-volume accumulation과 adaptive smoothing을 사용합니다.
6. Volatility adaptation이 켜져 있으면 ATR volatility ratio에 따라 tracking speed가 조정됩니다.
7. 가격과 swing-anchored VWAP 사이의 percentage distance를 계산합니다.
8. 가격이 VWAP 위에 있고 swing direction이 bullish이면 bullish context로 분류합니다.
9. 가격이 VWAP 아래에 있고 swing direction이 bearish이면 bearish context로 분류합니다.
10. 가격이 선택한 distance threshold 이상으로 VWAP에서 멀어지면 strong context로 감지합니다.
11. VWAP 주변에 context ribbon을 표시해 활성 VWAP 구간을 쉽게 확인할 수 있게 합니다.
12. Compact chart label은 현재 context와 VWAP distance를 요약합니다.
13. 선택 가능한 anchor dots는 swing direction flip 지점을 표시합니다.
14. 선택 가능한 alerts는 VWAP cross, swing flip, strong context 상태를 알릴 수 있습니다.

이 구조는 가격, 스윙 방향, 거래량 기반 기준선 사이의 관계를 분석하는 데 도움을 줍니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• swing detection sensitivity
• base price tracking speed
• volatility adaptation
• volatility sensitivity
• ATR period
• strong distance percentage
• VWAP line thickness
• VWAP glow line visibility
• VWAP context ribbon visibility
• ATR 기반 ribbon width
• direction background visibility
• swing point label visibility
• anchor dot visibility
• bullish VWAP color
• bearish VWAP color
• neutral color
• swing point color
• compact context label visibility
• label offset
• label ATR offset
• status panel visibility
• panel position
• panel size
• alert settings

기본 설정은 차트를 깔끔하게 유지하면서 VWAP 컨텍스트를 가격 차트 위에서 직접 읽을 수 있도록 설계되어 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• main VWAP line
• glow line
• VWAP context ribbon
• compact context label
• optional swing labels
• optional anchor dots
• optional status panel

Main VWAP line은 현재 활성화된 dynamic swing-anchored VWAP을 보여줍니다.

Glow line은 추가 신호 없이 VWAP 기준선을 더 잘 보이게 합니다.

Context ribbon은 VWAP 주변에 부드러운 구간을 만들어, 가격이 swing-based VWAP 기준선 주변에 머무는지 또는 멀어지는지 쉽게 확인할 수 있게 합니다.

Compact chart label은 큰 패널 없이 현재 상태를 요약합니다.

Anchor dot은 swing direction change를 최소한의 방식으로 표시합니다.

────────────────────
참고 상태
────────────────────

Strong Above VWAP:
가격이 swing-anchored VWAP 위에 있고, swing direction이 bullish이며, VWAP과의 거리가 선택한 기준값 이상인 상태입니다.

Above Swing VWAP:
가격이 swing-anchored VWAP 위에 있고, swing direction이 bullish context를 지지하는 상태입니다.

Strong Below VWAP:
가격이 swing-anchored VWAP 아래에 있고, swing direction이 bearish이며, VWAP과의 거리가 음의 기준값 이하인 상태입니다.

Below Swing VWAP:
가격이 swing-anchored VWAP 아래에 있고, swing direction이 bearish context를 지지하는 상태입니다.

Neutral VWAP:
가격 위치와 swing direction이 명확한 컨텍스트로 정렬되지 않은 상태입니다.

Bullish Swing Flip:
Swing direction이 bullish swing state로 바뀐 상태입니다.

Bearish Swing Flip:
Swing direction이 bearish swing state로 바뀐 상태입니다.

이 상태들은 정보 제공용이며, 매매 지시로 해석해서는 안 됩니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 swing-based VWAP context viewer로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• 가격이 dynamic swing-anchored VWAP 위에서 유지되면, 현재 스윙 구조가 positive VWAP context를 유지하는지 검토할 수 있습니다.
• 가격이 dynamic swing-anchored VWAP 아래에 머물면, 현재 스윙 구조가 negative VWAP context를 유지하는지 검토할 수 있습니다.
• VWAP과의 거리가 넓어질수록 현재 스윙 기반 거래량 기준선에서 가격이 더 크게 분리되어 있음을 보여줄 수 있습니다.
• Context ribbon은 가격이 VWAP zone과 상호작용하는지, 또는 그 구간에서 멀어지는지 확인하는 데 도움을 줍니다.
• Swing flip anchor dot은 VWAP anchor logic이 방향을 바꾼 지점을 복기하는 데 사용할 수 있습니다.
• Compact label은 큰 상태 패널 없이 빠른 컨텍스트 해석에 사용할 수 있습니다.
• Optional panel은 더 자세한 검토용으로 켤 수 있지만, 기본 해석은 차트 위에서 직접 이루어지도록 설계되었습니다.

이 스크립트는 가격 행동, 거래량, 변동성, 지지와 저항, 추세 구조, 상위 시간대 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 최근 high와 low 행동을 사용해 swing direction을 감지합니다.

Swing direction과 VWAP anchor는 선택한 sensitivity window 안에서 새로운 고점 또는 저점이 나타날 때 갱신될 수 있습니다.

Dynamic VWAP line은 가격과 거래량이 업데이트됨에 따라 다시 계산됩니다.

실시간 캔들에서는 가격, 거래량, ATR, swing condition이 봉 마감 전까지 변경될 수 있으므로 값이 변할 수 있습니다.

보다 보수적인 분석을 원한다면 봉 마감 이후 context를 검토하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

진입 또는 청산 추천을 제공하지 않습니다.

VWAP 위 또는 아래로의 교차가 추세 지속을 보장하지 않습니다.

VWAP과의 강한 거리는 전체 컨텍스트에 따라 강세, 약세, 과확장 상태 중 하나로 해석될 수 있습니다.

Swing detection sensitivity는 anchor update 빈도에 큰 영향을 줄 수 있습니다.

Choppy market에서는 swing direction과 VWAP context가 자주 바뀔 수 있습니다.

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
indicator("Dynamic Swing Anchored VWAP | Alpha S+", shorttitle="SwingVWAP", overlay=true, max_bars_back=5000, max_labels_count=200)

// Dynamic Swing Anchored VWAP
// Swing-based anchored VWAP viewer using dynamic swing detection, adaptive tracking,
// VWAP distance, context ribbon, and optional chart-based state label.

//────────────────────────────────────────────────────────────────────
// Groups
//────────────────────────────────────────────────────────────────────
groupCore = "Core Settings"
groupVisual = "Visual Settings"
groupLabel = "Chart Label"
groupPanel = "Status Panel"
groupAlerts = "Alerts"

//────────────────────────────────────────────────────────────────────
// Core settings
//────────────────────────────────────────────────────────────────────
swingSensitivity = input.int(50, "Swing Detection Sensitivity", minval=5, maxval=100, step=5, group=groupCore, tooltip="Higher values detect larger swing changes. Lower values react more slowly.")
baseTrackingSpeed = input.float(20.0, "Base Price Tracking Speed", minval=5.0, maxval=50.0, step=1.0, group=groupCore, tooltip="Controls how quickly the VWAP calculation adapts after anchoring.")
enableAdaptiveTracking = input.bool(false, "Enable Volatility Adaptation", group=groupCore, tooltip="When enabled, the tracking speed adapts to volatility conditions.")
volatilitySensitivity = input.float(10.0, "Volatility Sensitivity", minval=1.0, maxval=20.0, step=0.5, group=groupCore)
atrPeriod = input.int(50, "ATR Period", minval=5, maxval=300, group=groupCore)
strongDistancePct = input.float(0.5, "Strong Distance %", minval=0.1, maxval=10.0, step=0.1, group=groupCore)

//────────────────────────────────────────────────────────────────────
// Visual settings
//────────────────────────────────────────────────────────────────────
lineThickness = input.int(3, "VWAP Line Thickness", minval=1, maxval=8, group=groupVisual)
showGlowLine = input.bool(true, "Show VWAP Glow Line", group=groupVisual)
showRibbon = input.bool(true, "Show VWAP Context Ribbon", group=groupVisual)
ribbonAtrMult = input.float(0.28, "Ribbon Width ATR", minval=0.05, maxval=2.0, step=0.05, group=groupVisual)
showTrendBackground = input.bool(false, "Show Direction Background", group=groupVisual)
showSwingLabels = input.bool(false, "Show Swing Point Labels", group=groupVisual)
showAnchorDots = input.bool(true, "Show Anchor Dots", group=groupVisual)

bullishVwapColor = input.color(#FFB800, "Bullish VWAP Color", group=groupVisual)
bearishVwapColor = input.color(#FF6B35, "Bearish VWAP Color", group=groupVisual)
neutralColor = input.color(#9E9E9E, "Neutral Color", group=groupVisual)
swingPointColor = input.color(#4ECDC4, "Swing Point Color", group=groupVisual)

//────────────────────────────────────────────────────────────────────
// Chart label settings
//────────────────────────────────────────────────────────────────────
showContextLabel = input.bool(true, "Show Compact Context Label", group=groupLabel)
labelOffsetBars = input.int(3, "Label Offset Bars", minval=1, maxval=30, group=groupLabel)
labelAtrOffset = input.float(0.75, "Label ATR Offset", minval=0.1, maxval=5.0, step=0.05, group=groupLabel)

//────────────────────────────────────────────────────────────────────
// Panel settings
//────────────────────────────────────────────────────────────────────
showStatusPanel = input.bool(false, "Show Status Panel", group=groupPanel)
panelPositionInput = input.string("Top Right", "Panel Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=groupPanel)
panelSizeInput = input.string("Small", "Panel Size", options=["Tiny", "Small", "Normal"], group=groupPanel)

//────────────────────────────────────────────────────────────────────
// Alert settings
//────────────────────────────────────────────────────────────────────
enableAlerts = input.bool(true, "Enable Alerts", group=groupAlerts)

//────────────────────────────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────────────────────────────
f_panelPosition(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Bottom Left" ? position.bottom_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.top_right

f_panelSize(string sizeText) =>
    sizeText == "Tiny" ? size.tiny :
     sizeText == "Normal" ? size.normal :
     size.small

f_calculateAlpha(float trackingSpeed) =>
    decayFactor = math.exp(-math.log(2.0) / math.max(1.0, trackingSpeed))
    1.0 - decayFactor

f_contextText(bool strongBull, bool strongBear, bool bull, bool bear) =>
    txt = "Neutral VWAP"
    if strongBull
        txt := "Strong Above VWAP"
    else if strongBear
        txt := "Strong Below VWAP"
    else if bull
        txt := "Above Swing VWAP"
    else if bear
        txt := "Below Swing VWAP"
    txt

f_contextColor(bool strongBull, bool strongBear, bool bull, bool bear) =>
    col = neutralColor
    if strongBull or bull
        col := bullishVwapColor
    else if strongBear or bear
        col := bearishVwapColor
    col

//────────────────────────────────────────────────────────────────────
// Swing detection
//────────────────────────────────────────────────────────────────────
currentBar = bar_index

var float swingHigh = na
var float swingLow = na
var int highBar = currentBar
var int lowBar = currentBar
var int swingDirection = na
var int lastSwingDirection = na
var float previousExtreme = na

highestBars = ta.highestbars(high, swingSensitivity)
lowestBars = ta.lowestbars(low, swingSensitivity)

if highestBars == 0
    swingHigh := high
    highBar := currentBar

if lowestBars == 0
    swingLow := low
    lowBar := currentBar

swingDirection := highBar > lowBar ? 1 : -1
swingDirectionChanged = swingDirection != swingDirection[1] and not na(swingDirection[1])

//────────────────────────────────────────────────────────────────────
// Adaptive tracking speed
//────────────────────────────────────────────────────────────────────
currentAtr = ta.atr(atrPeriod)
averageAtr = ta.rma(currentAtr, atrPeriod)
volatilityRatio = averageAtr > 0.0 ? currentAtr / averageAtr : 1.0

rawTrackingSpeed =
     enableAdaptiveTracking ?
     baseTrackingSpeed / math.pow(volatilityRatio, volatilitySensitivity) :
     baseTrackingSpeed

adaptiveTrackingSpeed = math.max(5.0, math.min(300.0, rawTrackingSpeed))
finalTrackingSpeed = math.round(adaptiveTrackingSpeed)
currentAlpha = f_calculateAlpha(finalTrackingSpeed)

//────────────────────────────────────────────────────────────────────
// Swing-anchored VWAP calculation
//────────────────────────────────────────────────────────────────────
var float priceVolumeSum = hlc3 * volume
var float volumeSum = volume
var float swingAnchoredVwap = na

var array<label> swingLabels = array.new_label()

if swingDirectionChanged
    anchorBar = swingDirection > 0 ? lowBar : highBar
    anchorPrice = swingDirection > 0 ? swingLow : swingHigh

    if showSwingLabels
        labelStyle = swingDirection > 0 ? label.style_label_up : label.style_label_down

        string patternText = ""

        if swingDirection > 0 and not na(previousExtreme) and swingLow < previousExtreme
            patternText := "LL"
        else if swingDirection > 0 and not na(previousExtreme) and swingLow > previousExtreme
            patternText := "HL"
        else if swingDirection < 0 and not na(previousExtreme) and swingHigh < previousExtreme
            patternText := "LH"
        else if swingDirection < 0 and not na(previousExtreme) and swingHigh > previousExtreme
            patternText := "HH"

        if patternText != ""
            swingLabel = label.new(
                 x=anchorBar,
                 y=anchorPrice,
                 text=patternText,
                 style=labelStyle,
                 color=color.new(swingPointColor, 70),
                 textcolor=color.white,
                 size=size.small)

            array.push(swingLabels, swingLabel)

            while array.size(swingLabels) > 100
                oldLabel = array.shift(swingLabels)
                label.delete(oldLabel)

    previousExtreme := swingDirection > 0 ? swingHigh[1] : swingLow[1]

    barsBack = currentBar - anchorBar

    if barsBack >= 0 and barsBack < 5000
        priceVolumeSum := anchorPrice * nz(volume[barsBack], volume)
        volumeSum := nz(volume[barsBack], volume)
    else
        priceVolumeSum := anchorPrice * volume
        volumeSum := volume

currentPriceVolume = hlc3 * volume
currentVolume = volume

priceVolumeSum := (1.0 - currentAlpha) * priceVolumeSum + currentAlpha * currentPriceVolume
volumeSum := (1.0 - currentAlpha) * volumeSum + currentAlpha * currentVolume
swingAnchoredVwap := volumeSum > 0.0 ? priceVolumeSum / volumeSum : na

//────────────────────────────────────────────────────────────────────
// Direction color
//────────────────────────────────────────────────────────────────────
var color vwapLineColor = bullishVwapColor

if swingDirection != lastSwingDirection
    lastSwingDirection := swingDirection
    vwapLineColor := swingDirection > 0 ? bullishVwapColor : bearishVwapColor

//────────────────────────────────────────────────────────────────────
// VWAP relationship
//────────────────────────────────────────────────────────────────────
vwapDistancePct = swingAnchoredVwap > 0.0 ? ((close - swingAnchoredVwap) / swingAnchoredVwap) * 100.0 : 0.0

priceAboveVwap = close > swingAnchoredVwap
priceBelowVwap = close < swingAnchoredVwap

bullishContext = priceAboveVwap and swingDirection > 0
bearishContext = priceBelowVwap and swingDirection < 0

strongBullishContext = bullishContext and vwapDistancePct > strongDistancePct
strongBearishContext = bearishContext and vwapDistancePct < -strongDistancePct

priceCrossesAboveVwap = ta.crossover(close, swingAnchoredVwap)
priceCrossesBelowVwap = ta.crossunder(close, swingAnchoredVwap)

bullishSwingFlip = swingDirectionChanged and swingDirection > 0
bearishSwingFlip = swingDirectionChanged and swingDirection < 0

contextText = f_contextText(strongBullishContext, strongBearishContext, bullishContext, bearishContext)
contextColor = f_contextColor(strongBullishContext, strongBearishContext, bullishContext, bearishContext)

//────────────────────────────────────────────────────────────────────
// Ribbon and plots
//────────────────────────────────────────────────────────────────────
ribbonWidth = currentAtr * ribbonAtrMult
ribbonUpper = swingAnchoredVwap + ribbonWidth
ribbonLower = swingAnchoredVwap - ribbonWidth

pVwapMain = plot(swingAnchoredVwap, title="Dynamic Swing Anchored VWAP", color=vwapLineColor, linewidth=lineThickness, style=plot.style_line)

pVwapGlow = plot(
     showGlowLine ? swingAnchoredVwap : na,
     title="VWAP Glow",
     color=color.new(vwapLineColor, 82),
     linewidth=lineThickness + 4,
     style=plot.style_line)

pRibbonUpper = plot(showRibbon ? ribbonUpper : na, title="VWAP Context Ribbon Upper", color=color.new(contextColor, 88), linewidth=1)
pRibbonLower = plot(showRibbon ? ribbonLower : na, title="VWAP Context Ribbon Lower", color=color.new(contextColor, 88), linewidth=1)

fill(pRibbonUpper, pRibbonLower, color=showRibbon ? color.new(contextColor, strongBullishContext or strongBearishContext ? 88 : 93) : na, title="VWAP Context Ribbon")

bgColor = swingDirection > 0 ? color.new(bullishVwapColor, 98) : color.new(bearishVwapColor, 98)
bgcolor(showTrendBackground ? bgColor : na, title="Direction Background")

plotshape(showAnchorDots and bullishSwingFlip ? swingAnchoredVwap : na, title="Bullish Anchor Dot", style=shape.circle, location=location.absolute, color=color.new(bullishVwapColor, 0), size=size.tiny)
plotshape(showAnchorDots and bearishSwingFlip ? swingAnchoredVwap : na, title="Bearish Anchor Dot", style=shape.circle, location=location.absolute, color=color.new(bearishVwapColor, 0), size=size.tiny)

// Data window
plot(swingAnchoredVwap, "Swing Anchored VWAP", color=color.new(color.white, 100), display=display.data_window)
plot(vwapDistancePct, "VWAP Distance %", color=color.new(color.white, 100), display=display.data_window)
plot(swingDirection, "Swing Direction", color=color.new(color.white, 100), display=display.data_window)
plot(strongBullishContext ? 1 : 0, "Strong Bullish Context", color=color.new(color.white, 100), display=display.data_window)
plot(strongBearishContext ? 1 : 0, "Strong Bearish Context", color=color.new(color.white, 100), display=display.data_window)
plot(finalTrackingSpeed, "Tracking Speed", color=color.new(color.white, 100), display=display.data_window)

//────────────────────────────────────────────────────────────────────
// Compact chart label
//────────────────────────────────────────────────────────────────────
var label contextLabel = na

if barstate.islast
    label.delete(contextLabel)

    if showContextLabel and not na(swingAnchoredVwap)
        labelY = close >= swingAnchoredVwap ? high + currentAtr * labelAtrOffset : low - currentAtr * labelAtrOffset
        labelStyle = close >= swingAnchoredVwap ? label.style_label_down : label.style_label_up
        signText = vwapDistancePct > 0 ? "+" : ""
        labelText = contextText + "\nDist " + signText + str.tostring(vwapDistancePct, "#.##") + "%"

        contextLabel := label.new(
             x=bar_index + labelOffsetBars,
             y=labelY,
             text=labelText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=labelStyle,
             color=color.new(contextColor, strongBullishContext or strongBearishContext ? 12 : 28),
             textcolor=color.white,
             size=size.small)

//────────────────────────────────────────────────────────────────────
// Status panel
//────────────────────────────────────────────────────────────────────
panelPosition = f_panelPosition(panelPositionInput)
panelSize = f_panelSize(panelSizeInput)

var table statusPanel = table.new(panelPosition, 2, 5, border_width=1)

if barstate.islast and showStatusPanel
    directionText = swingDirection > 0 ? "Bullish Swing" : "Bearish Swing"

    vwapPositionText =
         priceAboveVwap ? "Above VWAP" :
         priceBelowVwap ? "Below VWAP" :
         "At VWAP"

    table.cell(statusPanel, 0, 0, "Swing VWAP", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=panelSize)
    table.cell(statusPanel, 1, 0, contextText, text_color=color.white, bgcolor=color.new(contextColor, 15), text_size=panelSize)

    table.cell(statusPanel, 0, 1, "Direction", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=panelSize)
    table.cell(statusPanel, 1, 1, directionText, text_color=color.white, bgcolor=swingDirection > 0 ? color.new(bullishVwapColor, 35) : color.new(bearishVwapColor, 35), text_size=panelSize)

    table.cell(statusPanel, 0, 2, "Price", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=panelSize)
    table.cell(statusPanel, 1, 2, vwapPositionText, text_color=color.white, bgcolor=priceAboveVwap ? color.new(bullishVwapColor, 35) : priceBelowVwap ? color.new(bearishVwapColor, 35) : color.new(color.gray, 35), text_size=panelSize)

    table.cell(statusPanel, 0, 3, "Distance", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=panelSize)
    table.cell(statusPanel, 1, 3, str.tostring(vwapDistancePct, "#.00") + "%", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=panelSize)

    table.cell(statusPanel, 0, 4, "Tracking", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=panelSize)
    table.cell(statusPanel, 1, 4, str.tostring(finalTrackingSpeed), text_color=color.white, bgcolor=enableAdaptiveTracking ? color.new(color.teal, 35) : color.new(color.gray, 35), text_size=panelSize)

if barstate.islast and not showStatusPanel
    table.clear(statusPanel, 0, 0, 1, 4)

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
alertcondition(enableAlerts and priceCrossesAboveVwap, "Price Crosses Above VWAP", "Price crossed above the dynamic swing anchored VWAP.")
alertcondition(enableAlerts and priceCrossesBelowVwap, "Price Crosses Below VWAP", "Price crossed below the dynamic swing anchored VWAP.")
alertcondition(enableAlerts and bullishSwingFlip, "Bullish Swing Flip", "Swing direction changed to bullish.")
alertcondition(enableAlerts and bearishSwingFlip, "Bearish Swing Flip", "Swing direction changed to bearish.")
alertcondition(enableAlerts and strongBullishContext, "Strong Bullish Context", "Price is above the dynamic swing anchored VWAP with bullish swing direction.")
alertcondition(enableAlerts and strongBearishContext, "Strong Bearish Context", "Price is below the dynamic swing anchored VWAP with bearish swing direction.")
````
