# Supply Demand Volume Zones

- url: https://www.tradingview.com/script/wqRZEaEg-Supply-Demand-Volume-Zones/
- type: indicator
- pine_id: PUB;644ea2f671a24ac5a408a2e98872e784
- version: 2.0

## Description

Supply Demand Volume Zones

Supply Demand Volume Zones is a chart study designed to identify potential supply and demand areas using pivot-based price structure, zone width normalization, volume context, reaction strength, and proximity-based ranking.

The script builds supply zones near confirmed pivot highs and demand zones near confirmed pivot lows. Each zone can be scored using the average volume inside the base area and the size of the reaction that followed the pivot.

It does not provide buy or sell recommendations. The purpose of this script is to help users study possible support and resistance areas created by prior price reactions and volume activity.

────────────────────
Core Concept
────────────────────

Supply and demand analysis is often used to study where price previously reacted from a defined area.

A supply zone generally represents a prior area where selling pressure or resistance appeared.

A demand zone generally represents a prior area where buying pressure or support appeared.

This script focuses on four main zone concepts:

• Pivot-based reaction areas
• Base-zone range construction
• Volume and reaction-strength scoring
• Distance-based zone ranking

When price approaches a prior supply zone, users may observe whether resistance or rejection appears.

When price approaches a prior demand zone, users may observe whether support or reaction appears.

When a zone is broken completely, the script can remove it to keep the chart focused on active areas.

────────────────────
What This Script Shows
────────────────────

The script can display:

• Supply zones
• Demand zones
• Zone labels
• Strength labels
• Score labels
• Distance-adjusted zone ranking
• Optional session background
• Active zone touch alerts
• Active zone break alerts

These elements are intended to make supply and demand areas easier to review on the chart.

────────────────────
How It Works
────────────────────

1. The script detects pivot highs and pivot lows using configurable left and right pivot bars.
2. When a pivot high is confirmed, it builds a potential supply zone from the selected base area.
3. When a pivot low is confirmed, it builds a potential demand zone from the selected base area.
4. The zone range can be built from wick range, body range, or a hybrid method.
5. The script normalizes zone height using ATR-based minimum and maximum height limits.
6. It calculates average volume across the base zone.
7. It compares base volume against a volume moving average to estimate volume expansion.
8. It measures the reaction move after the pivot in ATR units.
9. It combines volume context and reaction strength into a zone score.
10. It can filter zones with weak volume if the volume filter is enabled.
11. It prevents same-side duplicate zones using an ATR-based merge tolerance.
12. It can hide conflicting supply and demand overlap areas.
13. It ranks active zones by score and proximity to current price.
14. It fades distant zones and can delete zones after a complete break.
15. It updates active boxes and labels as the chart progresses.

────────────────────
Visual Elements
────────────────────

The script includes:

• Orange supply / resistance zones
• Blue demand / support zones
• Zone strength labels
• Optional score display
• Optional session background
• Transparent box styling for older or distant zones

Zone labels can show a simple meaning label, a score label, or both.

Examples:

• SUP 1 STRONG
• SUP 2 MID
• DEM 1 STRONG
• DEM 2 BASE

The rank number reflects the relative priority of the active zone after considering strength and distance from current price.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• Pivot left bars
• Pivot right bars
• Base zone bars
• ATR length
• Supply-only, demand-only, or both-side display
• Zone height calculation mode
• Minimum and maximum ATR-based zone height
• Right-side box extension
• Volume filter
• Volume moving average length
• Minimum volume multiplier
• Volume score weight
• Reaction score weight
• Strong and mid score thresholds
• Maximum number of supply zones
• Maximum number of demand zones
• Label display mode
• Broken-zone deletion
• Same-side merge tolerance
• Opposite-side conflict filter
• Far-zone fading
• Zone colors and transparency
• Optional session background

The default settings are designed to keep the chart readable while preserving the nearest and higher-ranked supply / demand zones.

────────────────────
Reference Markers
────────────────────

The script includes optional zone labels and alert conditions.

Supply Zone:
Shows a potential resistance area built from a confirmed pivot high and its surrounding base range.

Demand Zone:
Shows a potential support area built from a confirmed pivot low and its surrounding base range.

Strength Label:
Shows whether the zone is classified as BASE, MID, or STRONG according to the calculated score.

Score Label:
Shows the raw strength score based on the selected volume and reaction-weighting settings.

Zone Touch Alert:
Triggers when price enters or touches an active supply or demand zone.

Zone Break Alert:
Triggers when price completely breaks through an active supply or demand zone.

These markers and alerts are not trading signals. They are visual reference points for studying support, resistance, reaction zones, and price-location context.

────────────────────
How To Use
────────────────────

Use this script as a supply and demand zone viewer.

General interpretation examples:

• A supply zone above current price may act as a resistance reference area.
• A demand zone below current price may act as a support reference area.
• A zone with a higher score means the base area had stronger internal volume and/or a larger reaction move.
• A nearby high-ranked zone may be more relevant for short-term chart review than a distant lower-ranked zone.
• A complete break through a zone may reduce the usefulness of that zone as an active reference area.
• Overlapping or conflicting zones can be filtered to keep the chart cleaner.

This script should be used with independent analysis, risk management, and a defined trading plan.

────────────────────
Confirmation And Repainting Notes
────────────────────

Supply and demand zones are based on pivot logic.

A pivot requires the selected number of right-side bars to confirm, so a new zone appears only after the pivot has been confirmed.

The script does not use future price data beyond the required pivot confirmation window.

Because active candles can change before close, users who want confirmed conditions should evaluate zone touches and zone breaks after bar close.

Zone boxes are extended forward and updated as new bars appear. If broken-zone deletion is enabled, zones can disappear after price completely breaks through them.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

Supply and demand zones are approximate visual reference areas, not exact price guarantees.

Pivot-based zones can appear after the initial reaction has already started because pivot confirmation requires additional bars.

In sideways or low-liquidity markets, many zones may form close to each other and may require additional filtering.

A high score does not guarantee that price will react from a zone.

The script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Supply Demand Volume Zones

Supply Demand Volume Zones는 피벗 기반 가격 구조, 구간 폭 정규화, 거래량 컨텍스트, 반응 강도, 가격 근접도 기반 랭킹을 사용해 잠재적인 Supply / Demand 구간을 표시하는 차트 분석 보조지표입니다.

이 스크립트는 확정된 피벗 고점 부근에는 Supply 구간을, 확정된 피벗 저점 부근에는 Demand 구간을 생성합니다. 각 구간은 base 영역의 평균 거래량과 피벗 이후 발생한 반응 크기를 바탕으로 점수화할 수 있습니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다.
목적은 과거 가격 반응과 거래량 활동으로 형성된 잠재적 지지 / 저항 영역을 관찰하는 것입니다.

────────────────────
핵심 개념
────────────────────

Supply / Demand 분석은 가격이 과거에 특정 구간에서 어떻게 반응했는지 관찰하는 데 자주 사용됩니다.

Supply 구간은 일반적으로 과거에 매도 압력 또는 저항이 나타난 영역을 의미합니다.

Demand 구간은 일반적으로 과거에 매수 압력 또는 지지가 나타난 영역을 의미합니다.

이 스크립트는 네 가지 구간 개념에 초점을 둡니다.

• 피벗 기반 반응 구간
• Base zone 범위 구성
• 거래량 및 반응 강도 점수
• 가격 거리 기반 구간 랭킹

가격이 이전 Supply 구간에 접근할 때 사용자는 저항이나 반락 반응이 나타나는지 관찰할 수 있습니다.

가격이 이전 Demand 구간에 접근할 때 사용자는 지지나 반등 반응이 나타나는지 관찰할 수 있습니다.

구간이 완전히 돌파되면, 설정에 따라 해당 구간을 삭제하여 차트에 활성 구간만 남길 수 있습니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• Supply 구간
• Demand 구간
• 구간 라벨
• 강도 라벨
• 점수 라벨
• 거리 반영 구간 랭킹
• 선택 가능한 세션 배경
• 활성 구간 터치 알림
• 활성 구간 돌파 알림

이 요소들은 차트 위에서 Supply / Demand 영역을 더 쉽게 복기하기 위한 시각적 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 설정 가능한 left / right pivot bars를 사용해 피벗 고점과 피벗 저점을 감지합니다.
2. 피벗 고점이 확정되면 선택한 base 영역을 기준으로 잠재 Supply 구간을 생성합니다.
3. 피벗 저점이 확정되면 선택한 base 영역을 기준으로 잠재 Demand 구간을 생성합니다.
4. 구간 범위는 wick range, body range, hybrid 방식 중 하나로 구성할 수 있습니다.
5. ATR 기반 최소 / 최대 구간 높이를 적용해 zone height를 정규화합니다.
6. Base zone 안의 평균 거래량을 계산합니다.
7. Base volume을 거래량 이동평균과 비교해 거래량 확장 정도를 추정합니다.
8. 피벗 이후 발생한 반응 움직임을 ATR 단위로 측정합니다.
9. 거래량 컨텍스트와 반응 강도를 조합해 구간 점수를 계산합니다.
10. Volume Filter를 활성화하면 약한 거래량 구간을 필터링할 수 있습니다.
11. ATR 기반 merge tolerance를 사용해 같은 방향의 중복 구간을 줄입니다.
12. Supply와 Demand가 충돌하는 중첩 구간을 숨길 수 있습니다.
13. 활성 구간을 점수와 현재 가격과의 거리 기준으로 랭킹화합니다.
14. 먼 구간은 더 흐리게 표시하고, 완전히 돌파된 구간은 삭제할 수 있습니다.
15. 차트가 진행됨에 따라 활성 박스와 라벨을 계속 업데이트합니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• 주황색 Supply / Resistance 구간
• 파란색 Demand / Support 구간
• 구간 강도 라벨
• 선택 가능한 점수 표시
• 선택 가능한 세션 배경
• 오래되었거나 먼 구간을 위한 투명 박스 스타일

구간 라벨은 단순 의미, 점수, 또는 둘 다 표시할 수 있습니다.

예시:

• SUP 1 STRONG
• SUP 2 MID
• DEM 1 STRONG
• DEM 2 BASE

랭킹 숫자는 현재 가격과의 거리 및 구간 강도를 반영한 활성 구간의 상대적 우선순위를 의미합니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• Pivot Left Bars
• Pivot Right Bars
• Base Zone Bars
• ATR Length
• Supply only, Demand only, 양방향 표시
• Zone Height 계산 방식
• ATR 기반 최소 / 최대 구간 높이
• 우측 박스 연장 길이
• Volume Filter
• Volume MA Length
• Minimum Volume Multiplier
• Volume Score Weight
• Reaction Score Weight
• Strong / Mid Score 기준
• 최대 Supply 구간 수
• 최대 Demand 구간 수
• 라벨 표시 방식
• 돌파된 구간 삭제
• 같은 방향 구간 병합 허용 범위
• 반대 방향 중첩 구간 필터
• 먼 구간 흐림 처리
• 구간 색상 및 투명도
• 선택 가능한 세션 배경

기본 설정은 차트 가독성을 유지하면서 현재 가격과 가까운 주요 Supply / Demand 구간을 남기도록 구성되어 있습니다.

────────────────────
참고 마커
────────────────────

이 스크립트에는 선택 가능한 구간 라벨과 알림 조건이 포함되어 있습니다.

Supply Zone:
확정된 피벗 고점과 주변 base range를 기준으로 만들어진 잠재 저항 구간을 표시합니다.

Demand Zone:
확정된 피벗 저점과 주변 base range를 기준으로 만들어진 잠재 지지 구간을 표시합니다.

Strength Label:
계산된 점수에 따라 BASE, MID, STRONG 중 하나로 구간 강도를 표시합니다.

Score Label:
선택한 거래량 및 반응 강도 가중치 설정을 기준으로 계산된 원시 강도 점수를 표시합니다.

Zone Touch Alert:
가격이 활성 Supply 또는 Demand 구간에 진입하거나 터치할 때 발생합니다.

Zone Break Alert:
가격이 활성 Supply 또는 Demand 구간을 완전히 돌파할 때 발생합니다.

이 마커와 알림은 매매 신호가 아닙니다.
지지, 저항, 반응 구간, 가격 위치 컨텍스트를 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 Supply / Demand 구간 확인용 보조지표로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 현재 가격 위의 Supply 구간은 저항 참고 영역으로 볼 수 있습니다.
• 현재 가격 아래의 Demand 구간은 지지 참고 영역으로 볼 수 있습니다.
• 점수가 높은 구간은 base 영역의 거래량이 상대적으로 강했거나 이후 반응 움직임이 컸다는 의미입니다.
• 현재 가격과 가까운 높은 순위의 구간은 멀리 있는 낮은 순위 구간보다 단기 차트 복기에 더 유용할 수 있습니다.
• 구간이 완전히 돌파되면 해당 구간의 활성 참고 가치가 낮아졌다고 볼 수 있습니다.
• 중복되거나 충돌하는 구간은 필터링하여 차트를 더 깔끔하게 유지할 수 있습니다.

이 스크립트는 독립적인 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

Supply / Demand 구간은 피벗 기반 로직으로 계산됩니다.

피벗은 선택한 우측 확인 캔들이 필요하므로, 새로운 구간은 피벗이 확정된 뒤에 표시됩니다.

이 스크립트는 필요한 피벗 확인 구간 외에 미래 가격 데이터를 사용하지 않습니다.

현재 진행 중인 캔들은 마감 전까지 값이 변할 수 있으므로, 확정 조건을 원하는 사용자는 구간 터치와 구간 돌파를 봉 마감 이후 기준으로 확인해야 합니다.

구간 박스는 우측으로 연장되며 새 캔들이 형성될 때마다 업데이트됩니다. Broken-zone deletion이 활성화되어 있으면 가격이 구간을 완전히 돌파한 뒤 해당 구간이 사라질 수 있습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

Supply / Demand 구간은 정확한 가격 보장이 아니라 대략적인 시각 참고 영역입니다.

피벗 기반 구간은 우측 확인 캔들이 필요하므로, 초기 반응이 이미 발생한 뒤 구간이 표시될 수 있습니다.

횡보장 또는 저유동성 시장에서는 많은 구간이 가까운 위치에 형성될 수 있으며 추가 필터링이 필요할 수 있습니다.

높은 점수는 해당 구간에서 반드시 가격이 반응한다는 의미가 아닙니다.

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
indicator("Supply Demand Reaction Zones", shorttitle="SDReact", overlay=true, max_boxes_count=300, max_labels_count=300, max_bars_back=5000)

groupDetect = "① Displacement Detection"
sensitivity = input.string("Balanced", "Sensitivity", options=["Conservative", "Balanced", "Aggressive"], group=groupDetect)
obSearchBars = input.int(8, "Opposite Candle Search Bars", minval=1, maxval=30, group=groupDetect)
breakLookback = input.int(12, "Displacement Break Lookback", minval=3, maxval=80, group=groupDetect)
atrLen = input.int(14, "ATR Length", minval=1, group=groupDetect)
useVolume = input.bool(true, "Use Volume Confirmation", group=groupDetect)
volLen = input.int(20, "Volume MA Length", minval=1, group=groupDetect)
volMult = input.float(1.05, "Volume Multiplier", minval=0.10, step=0.05, group=groupDetect)
zoneSource = input.string("Hybrid", "Zone Source", options=["Full Candle", "Body Only", "Hybrid"], group=groupDetect)

groupPivot = "② Pivot Volume Fallback"
usePivotFallback = input.bool(true, "Use Pivot Volume Fallback", group=groupPivot)
pivotLeft = input.int(4, "Pivot Left Bars", minval=1, maxval=30, group=groupPivot)
pivotRight = input.int(4, "Pivot Right Bars", minval=1, maxval=30, group=groupPivot)
baseBars = input.int(10, "Base Zone Bars", minval=3, maxval=60, group=groupPivot)
pivotZoneMode = input.string("Both", "Pivot Zone Mode", options=["Both", "Supply Only", "Demand Only"], group=groupPivot)
pivotZoneHeightMode = input.string("Hybrid", "Pivot Zone Height Mode", options=["Wick Range", "Body Range", "Hybrid"], group=groupPivot)
pivotUseVolumeFilter = input.bool(false, "Use Pivot Volume Filter", group=groupPivot)
pivotMinVolumeMult = input.float(0.70, "Minimum Pivot Volume Multiplier", minval=0.0, maxval=10.0, step=0.05, group=groupPivot)
pivotVolumeWeight = input.float(0.62, "Pivot Volume Score Weight", minval=0.0, maxval=1.0, step=0.01, group=groupPivot)
pivotReactionWeight = input.float(0.38, "Pivot Reaction Score Weight", minval=0.0, maxval=1.0, step=0.01, group=groupPivot)
pivotStrongScore = input.float(1.35, "Pivot Strong Score", minval=0.1, maxval=5.0, step=0.05, group=groupPivot)
pivotMidScore = input.float(1.05, "Pivot Mid Score", minval=0.1, maxval=5.0, step=0.05, group=groupPivot)

groupQuality = "③ Zone Quality"
weakQualityScore = input.float(38.0, "Weak Zone Score", minval=0.0, maxval=100.0, step=1.0, group=groupQuality)
validQualityScore = input.float(50.0, "Valid Zone Score", minval=0.0, maxval=100.0, step=1.0, group=groupQuality)
coreQualityScore = input.float(70.0, "Core Candidate Score", minval=0.0, maxval=100.0, step=1.0, group=groupQuality)
preferCloseBreak = input.bool(true, "Prefer Close Beyond Prior Range", group=groupQuality)
coreValidationBars = input.int(4, "Core Validation Bars", minval=2, maxval=12, group=groupQuality)
coreContinuationATR = input.float(0.25, "Core Continuation ATR", minval=0.0, maxval=3.0, step=0.05, group=groupQuality)
coreHoldBufferATR = input.float(0.10, "Core Hold Buffer ATR", minval=0.0, maxval=1.0, step=0.01, group=groupQuality)
mitigationMode = input.string("Penetration", "Mitigation Mode", options=["Penetration", "Close Inside", "Wick Touch"], group=groupQuality)
mitigationDelayBars = input.int(2, "Mitigation Delay Bars", minval=0, maxval=20, group=groupQuality)
mitigationDepthPct = input.float(25.0, "Mitigation Penetration %", minval=1.0, maxval=100.0, step=1.0, group=groupQuality)
reactionConfirmATR = input.float(0.35, "Reaction Confirmation ATR", minval=0.05, maxval=3.0, step=0.05, group=groupQuality)
reactionWindowBars = input.int(16, "Reaction Window Bars", minval=2, maxval=100, group=groupQuality)
mitigatedHideAfterBars = input.int(120, "Hide Mitigated After Bars", minval=5, maxval=1500, group=groupQuality)
hideMitNearReaction = input.bool(true, "Hide MIT Near HOLD / REJECT", group=groupQuality)
reactionPriorityOverlapPct = input.float(35.0, "Reaction Priority Overlap %", minval=5.0, maxval=100.0, step=5.0, group=groupQuality)
breakerConfirmATR = input.float(0.28, "Breaker Confirmation ATR", minval=0.0, maxval=3.0, step=0.05, group=groupQuality)
minZoneAtr = input.float(0.22, "Minimum Zone Height ATR", minval=0.01, maxval=3.0, step=0.01, group=groupQuality)
maxPivotZoneAtr = input.float(1.15, "Maximum Pivot Zone Height ATR", minval=0.20, maxval=6.0, step=0.05, group=groupQuality)
overlapMergePct = input.float(55.0, "Overlap Merge %", minval=5.0, maxval=100.0, step=5.0, group=groupQuality)
conflictOverlapPct = input.float(35.0, "Supply / Demand Conflict Overlap %", minval=5.0, maxval=100.0, step=5.0, group=groupQuality)

groupDisplay = "④ Display"
maxZones = input.int(22, "Maximum Stored Zones", minval=1, maxval=80, group=groupDisplay)
maxAgeBars = input.int(420, "Maximum Zone Age", minval=20, maxval=3000, group=groupDisplay)
coreExtendBars = input.int(180, "Core Zone Extend Bars", minval=10, maxval=500, group=groupDisplay)
validExtendBars = input.int(120, "Valid Zone Extend Bars", minval=10, maxval=500, group=groupDisplay)
weakExtendBars = input.int(80, "Weak Zone Extend Bars", minval=10, maxval=500, group=groupDisplay)
mitigatedExtendBars = input.int(70, "Mitigated Zone Extend Bars", minval=10, maxval=500, group=groupDisplay)
reactedExtendBars = input.int(100, "Hold / Reject Extend Bars", minval=10, maxval=500, group=groupDisplay)
breakerExtendBars = input.int(60, "Breaker Zone Extend Bars", minval=10, maxval=500, group=groupDisplay)
showOnlyNearPrice = input.bool(true, "Show Only Near Current Price", group=groupDisplay)
nearATR = input.float(8.0, "Near Price Distance ATR", minval=0.5, maxval=50.0, step=0.5, group=groupDisplay)
showClosestOnly = input.bool(true, "Show Closest Key Zones Only", group=groupDisplay)
keyZonesPerSide = input.int(2, "Key Zones Per Side", minval=1, maxval=4, group=groupDisplay)
recentAlwaysVisibleBars = input.int(60, "Recent Zones Always Visible Bars", minval=0, maxval=500, group=groupDisplay)
showWeakZones = input.bool(false, "Show Weak Zones", group=groupDisplay)
showPivotZones = input.bool(true, "Show Pivot Fallback Zones", group=groupDisplay)
showMitigated = input.bool(true, "Show Mitigated Zones", group=groupDisplay)
showReacted = input.bool(true, "Show Hold / Reject Zones", group=groupDisplay)
showBreakers = input.bool(true, "Show Breaker Zones", group=groupDisplay)
showInvalidated = input.bool(false, "Show Invalidated Zones", group=groupDisplay)
showBoxText = input.bool(true, "Show Zone Text", group=groupDisplay)
labelMode = input.string("Full", "Label Mode", options=["Full", "Compact"], group=groupDisplay)
showQualityScore = input.bool(false, "Show Quality Score", group=groupDisplay)
showZoneMarkers = input.bool(false, "Show Price-In-Zone Markers", group=groupDisplay)

groupStyle = "⑤ Style"
bullColor = input.color(color.rgb(0, 190, 120), "Demand Color", group=groupStyle)
bearColor = input.color(color.rgb(220, 70, 90), "Supply Color", group=groupStyle)
pivotDemandColor = input.color(color.rgb(0, 122, 255), "Pivot Demand Color", group=groupStyle)
pivotSupplyColor = input.color(color.rgb(255, 126, 0), "Pivot Supply Color", group=groupStyle)
reactBullColor = input.color(color.rgb(40, 220, 150), "Hold Color", group=groupStyle)
reactBearColor = input.color(color.rgb(255, 95, 115), "Reject Color", group=groupStyle)
breakerColor = input.color(color.rgb(255, 165, 0), "Breaker Color", group=groupStyle)
invalidColor = input.color(color.rgb(130, 130, 130), "Invalidated Color", group=groupStyle)
textColor = input.color(color.white, "Text Color", group=groupStyle)

float impulseAtrMult = sensitivity == "Conservative" ? 1.35 : sensitivity == "Balanced" ? 1.02 : 0.78
float bodyAtrMult = sensitivity == "Conservative" ? 0.68 : sensitivity == "Balanced" ? 0.45 : 0.30
float wickTolerance = sensitivity == "Conservative" ? 0.06 : sensitivity == "Balanced" ? 0.12 : 0.20

atr = ta.atr(atrLen)
volMA = ta.sma(volume, volLen)
rng = high - low
body = math.abs(close - open)
prevRangeHigh = ta.highest(high, breakLookback)[1]
prevRangeLow = ta.lowest(low, breakLookback)[1]
atrSafe = math.max(atr, syminfo.mintick)
volRatio = volume / math.max(volMA, 1.0)

validationLowestClose = ta.lowest(close, coreValidationBars)
validationHighestClose = ta.highest(close, coreValidationBars)
validationLowestLow = ta.lowest(low, coreValidationBars)
validationHighestHigh = ta.highest(high, coreValidationBars)

var box[] zoneBoxes = array.new_box()
var float[] zoneTops = array.new_float()
var float[] zoneBottoms = array.new_float()
var int[] zoneDirs = array.new_int()
var int[] zoneStates = array.new_int()
var int[] zoneBornBars = array.new_int()
var int[] zoneMitigatedBars = array.new_int()
var float[] zoneScores = array.new_float()
var int[] zoneTiers = array.new_int()
var bool[] zoneCoreCandidates = array.new_bool()
var bool[] zoneValidated = array.new_bool()
var int[] zoneSources = array.new_int()

f_body_high(_offset, _bars) =>
    float result = na
    for i = 0 to _bars - 1
        int o = _offset + i
        float v = math.max(open[o], close[o])
        result := na(result) ? v : math.max(result, v)
    result

f_body_low(_offset, _bars) =>
    float result = na
    for i = 0 to _bars - 1
        int o = _offset + i
        float v = math.min(open[o], close[o])
        result := na(result) ? v : math.min(result, v)
    result

f_wick_high(_offset, _bars) =>
    float result = na
    for i = 0 to _bars - 1
        int o = _offset + i
        float v = high[o]
        result := na(result) ? v : math.max(result, v)
    result

f_wick_low(_offset, _bars) =>
    float result = na
    for i = 0 to _bars - 1
        int o = _offset + i
        float v = low[o]
        result := na(result) ? v : math.min(result, v)
    result

f_base_volume(_offset, _bars) =>
    float result = 0.0
    for i = 0 to _bars - 1
        int o = _offset + i
        result += nz(volume[o], 0.0)
    result / math.max(_bars, 1)

f_lastOppositeCandle(_dir, _maxSearch) =>
    int found = na
    for i = 1 to _maxSearch
        bool isOpp = _dir == 1 ? close[i] < open[i] : close[i] > open[i]
        if na(found) and isOpp
            found := i
    found

f_rawTop(_off) =>
    float top = na
    if zoneSource == "Full Candle"
        top := high[_off]
    else if zoneSource == "Body Only"
        top := math.max(open[_off], close[_off])
    else
        top := (high[_off] + math.max(open[_off], close[_off])) / 2.0
    top

f_rawBottom(_off) =>
    float bot = na
    if zoneSource == "Full Candle"
        bot := low[_off]
    else if zoneSource == "Body Only"
        bot := math.min(open[_off], close[_off])
    else
        bot := (low[_off] + math.min(open[_off], close[_off])) / 2.0
    bot

f_adjustTop(_top, _bot, _atr) =>
    float minH = math.max(_atr * minZoneAtr, syminfo.mintick * 20.0)
    float h = _top - _bot
    float mid = (_top + _bot) / 2.0
    h < minH ? mid + minH / 2.0 : _top

f_adjustBottom(_top, _bot, _atr) =>
    float minH = math.max(_atr * minZoneAtr, syminfo.mintick * 20.0)
    float h = _top - _bot
    float mid = (_top + _bot) / 2.0
    h < minH ? mid - minH / 2.0 : _bot

f_fixPivotZoneHeight(_isSupply, _top, _bot) =>
    float t = _top
    float b = _bot
    float mid = (t + b) * 0.5
    float h = math.max(t - b, syminfo.mintick)
    float minH = atrSafe * minZoneAtr
    if h < minH
        t := mid + minH * 0.5
        b := mid - minH * 0.5
    float maxH = atrSafe * maxPivotZoneAtr
    if t - b > maxH
        if _isSupply
            b := t - maxH
        else
            t := b + maxH
    [t, b]

f_qualityScore(_breakStrength, _bodyAtr, _rangeAtr, _volRatio, _closeBreak) =>
    float s1 = math.min(35.0, _breakStrength * 28.0)
    float s2 = math.min(25.0, _bodyAtr * 24.0)
    float s3 = math.min(20.0, _rangeAtr * 12.0)
    float s4 = useVolume ? math.min(15.0, _volRatio * 9.0) : 12.0
    float s5 = _closeBreak ? 5.0 : 0.0
    math.min(100.0, s1 + s2 + s3 + s4 + s5)

f_pivotScore(_volumeMult, _reactionAtr) =>
    float weightSum = math.max(pivotVolumeWeight + pivotReactionWeight, 0.01)
    float volComponent = _volumeMult
    float reactionComponent = math.min(_reactionAtr, 3.0) / 2.0
    float rawScore = (volComponent * pivotVolumeWeight + reactionComponent * pivotReactionWeight) / weightSum
    math.max(rawScore, 0.01)

f_initialTier(_score) =>
    int tier = 0
    if _score >= validQualityScore
        tier := 1
    else
        tier := 0
    tier

f_pivotTier(_score) =>
    int tier = 0
    if _score >= pivotStrongScore
        tier := 2
    else if _score >= pivotMidScore
        tier := 1
    else
        tier := 0
    tier

f_coreCandidate(_score, _closeBreak, _volPass) =>
    _score >= coreQualityScore and _closeBreak and _volPass

f_overlapPct(_top1, _bot1, _top2, _bot2) =>
    float overlapTop = math.min(_top1, _top2)
    float overlapBot = math.max(_bot1, _bot2)
    float overlap = math.max(0.0, overlapTop - overlapBot)
    float h1 = math.max(_top1 - _bot1, syminfo.mintick)
    float h2 = math.max(_top2 - _bot2, syminfo.mintick)
    float base = math.min(h1, h2)
    overlap / base * 100.0

f_hasSimilarZone(_dir, _top, _bot, _tier, _atr) =>
    bool found = false
    float tol = math.max(_atr * 0.18, syminfo.mintick * 10.0)
    int sz = array.size(zoneBoxes)
    if sz > 0
        for i = 0 to sz - 1
            bool sameDir = array.get(zoneDirs, i) == _dir
            bool sameTop = math.abs(array.get(zoneTops, i) - _top) <= tol
            bool sameBot = math.abs(array.get(zoneBottoms, i) - _bot) <= tol
            bool overlapped = f_overlapPct(_top, _bot, array.get(zoneTops, i), array.get(zoneBottoms, i)) >= overlapMergePct
            int st = array.get(zoneStates, i)
            int oldTier = array.get(zoneTiers, i)
            if sameDir and st < 3 and oldTier >= _tier and ((sameTop and sameBot) or overlapped)
                found := true
    found

f_hasOppositeConflict(_idx, _dir, _top, _bot) =>
    bool conflict = false
    int sz = array.size(zoneBoxes)
    if sz > 0
        for j = 0 to sz - 1
            if j != _idx
                int otherDir = array.get(zoneDirs, j)
                int otherState = array.get(zoneStates, j)
                float otherTop = array.get(zoneTops, j)
                float otherBot = array.get(zoneBottoms, j)
                bool otherAlive = otherState == 0 or otherState == 1 or otherState == 4 or otherState == 5
                bool opposite = otherDir != _dir
                bool overlapped = f_overlapPct(_top, _bot, otherTop, otherBot) >= conflictOverlapPct
                if otherAlive and opposite and overlapped
                    conflict := true
    conflict

f_hasNearbyReaction(_idx, _top, _bot) =>
    bool found = false
    int sz = array.size(zoneBoxes)
    if sz > 0
        for j = 0 to sz - 1
            if j != _idx
                int otherState = array.get(zoneStates, j)
                float otherTop = array.get(zoneTops, j)
                float otherBot = array.get(zoneBottoms, j)
                bool reacted = otherState == 4 or otherState == 5
                bool overlapped = f_overlapPct(_top, _bot, otherTop, otherBot) >= reactionPriorityOverlapPct
                if reacted and overlapped
                    found := true
    found

f_zoneLabel(_dir, _tier, _compact, _src) =>
    string txt = ""
    bool pivotSrc = _src == 1
    if _compact
        if _dir == 1
            txt := pivotSrc ? (_tier == 2 ? "VD+" : _tier == 1 ? "VD" : "VDW") : (_tier == 2 ? "D+" : _tier == 1 ? "D" : "DW")
        else
            txt := pivotSrc ? (_tier == 2 ? "VS+" : _tier == 1 ? "VS" : "VSW") : (_tier == 2 ? "S+" : _tier == 1 ? "S" : "SW")
    else
        if _dir == 1
            txt := pivotSrc ? (_tier == 2 ? "CORE VOLUME DEMAND" : _tier == 1 ? "VOLUME DEMAND" : "WEAK VOLUME DEMAND") : (_tier == 2 ? "CORE DEMAND" : _tier == 1 ? "DEMAND" : "WEAK DEMAND")
        else
            txt := pivotSrc ? (_tier == 2 ? "CORE VOLUME SUPPLY" : _tier == 1 ? "VOLUME SUPPLY" : "WEAK VOLUME SUPPLY") : (_tier == 2 ? "CORE SUPPLY" : _tier == 1 ? "SUPPLY" : "WEAK SUPPLY")
    txt

f_stateSuffix(_state, _compact) =>
    string txt = ""
    if _compact
        if _state == 1
            txt := "-MIT"
        else if _state == 2
            txt := "-BRK"
        else if _state == 3
            txt := "-INV"
        else if _state == 4
            txt := "-HOLD"
        else if _state == 5
            txt := "-REJ"
    else
        if _state == 1
            txt := " · MIT"
        else if _state == 2
            txt := " · BRK"
        else if _state == 3
            txt := " · INV"
        else if _state == 4
            txt := " · HOLD"
        else if _state == 5
            txt := " · REJECT"
    txt

f_zoneText(_dir, _state, _score, _tier, _src) =>
    bool compact = labelMode == "Compact"
    string base = f_zoneLabel(_dir, _tier, compact, _src) + f_stateSuffix(_state, compact)
    string scoreText = _src == 1 ? "\nV " + str.tostring(_score, "#.##") + "x" : "\nQ " + str.tostring(math.round(_score))
    showQualityScore ? base + scoreText : base

f_zoneBaseColor(_dir, _state, _src) =>
    color c = _dir == 1 ? bullColor : bearColor
    if _src == 1
        c := _dir == 1 ? pivotDemandColor : pivotSupplyColor
    if _state == 2
        c := breakerColor
    else if _state == 3
        c := invalidColor
    else if _state == 4
        c := reactBullColor
    else if _state == 5
        c := reactBearColor
    c

f_zoneBg(_dir, _state, _visible, _tier, _key, _conflict, _mitSuppressed, _src) =>
    color c = f_zoneBaseColor(_dir, _state, _src)
    int transp = 100
    if _state == 0
        transp := _tier == 2 ? 78 : _tier == 1 ? 84 : 94
    else if _state == 1
        transp := _tier == 2 ? 93 : _tier == 1 ? 96 : 98
    else if _state == 4 or _state == 5
        transp := _tier == 2 ? 84 : _tier == 1 ? 88 : 95
    else if _state == 2
        transp := _tier == 2 ? 90 : _tier == 1 ? 93 : 97
    else
        transp := 98
    if not _key and _tier < 2
        transp := math.min(98, transp + 4)
    if _conflict
        transp := math.min(98, transp + 3)
    if _mitSuppressed
        transp := 100
    _visible ? color.new(c, transp) : color.new(c, 100)

f_zoneBorder(_dir, _state, _visible, _tier, _key, _conflict, _mitSuppressed, _src) =>
    color c = f_zoneBaseColor(_dir, _state, _src)
    int transp = 100
    if _state == 0
        transp := _tier == 2 ? 0 : _tier == 1 ? 18 : 72
    else if _state == 1
        transp := _tier == 2 ? 68 : _tier == 1 ? 78 : 92
    else if _state == 4 or _state == 5
        transp := _tier == 2 ? 10 : _tier == 1 ? 24 : 72
    else if _state == 2
        transp := _tier == 2 ? 36 : _tier == 1 ? 52 : 82
    else
        transp := 90
    if not _key and _tier < 2
        transp := math.min(92, transp + 10)
    if _conflict
        transp := math.min(92, transp + 8)
    if _mitSuppressed
        transp := 100
    _visible ? color.new(c, transp) : color.new(c, 100)

f_zoneTextColor(_state, _visible, _tier, _key, _conflict, _mitSuppressed) =>
    int transp = 100
    if _state == 0
        transp := _tier == 2 ? 0 : _tier == 1 ? 18 : 70
    else if _state == 1
        transp := _tier == 2 ? 60 : _tier == 1 ? 70 : 88
    else if _state == 4 or _state == 5
        transp := _tier == 2 ? 0 : _tier == 1 ? 14 : 70
    else if _state == 2
        transp := _tier == 2 ? 28 : _tier == 1 ? 42 : 76
    else
        transp := 82
    if not _key and _tier < 2
        transp := math.min(92, transp + 8)
    if _conflict
        transp := math.min(90, transp + 8)
    if _mitSuppressed
        transp := 100
    _visible ? color.new(textColor, transp) : color.new(textColor, 100)

f_borderWidth(_tier, _key, _state) =>
    (_tier == 2 or _state == 4 or _state == 5) ? 2 : _key ? 1 : 1

f_dynamicExtend(_state, _tier) =>
    int ex = validExtendBars
    if _state == 0
        ex := _tier == 2 ? coreExtendBars : _tier == 1 ? validExtendBars : weakExtendBars
    else if _state == 1
        ex := mitigatedExtendBars
    else if _state == 4 or _state == 5
        ex := reactedExtendBars
    else if _state == 2
        ex := breakerExtendBars
    else
        ex := breakerExtendBars
    ex

f_priorityWeight(_state, _tier) =>
    float w = 1.0
    if _state == 4 or _state == 5
        w := 0.45
    else if _tier == 2
        w := 0.60
    else if _state == 0
        w := 0.80
    else if _state == 1
        w := 1.20
    w

f_addZone(_dir, _left, _top, _bot, _score, _tier, _coreCandidate, _src) =>
    bool validZone = not na(_top) and not na(_bot) and _top > _bot and not f_hasSimilarZone(_dir, _top, _bot, _tier, atrSafe)
    if validZone
        string txt = showBoxText ? f_zoneText(_dir, 0, _score, _tier, _src) : ""
        box bx = box.new(left=_left, top=_top, right=bar_index + f_dynamicExtend(0, _tier), bottom=_bot, xloc=xloc.bar_index, bgcolor=f_zoneBg(_dir, 0, true, _tier, true, false, false, _src), border_color=f_zoneBorder(_dir, 0, true, _tier, true, false, false, _src), border_width=f_borderWidth(_tier, true, 0), text=txt, text_size=size.tiny, text_color=f_zoneTextColor(0, true, _tier, true, false, false), text_halign=text.align_left, text_valign=text.align_center)
        array.push(zoneBoxes, bx)
        array.push(zoneTops, _top)
        array.push(zoneBottoms, _bot)
        array.push(zoneDirs, _dir)
        array.push(zoneStates, 0)
        array.push(zoneBornBars, _left)
        array.push(zoneMitigatedBars, na)
        array.push(zoneScores, _score)
        array.push(zoneTiers, _tier)
        array.push(zoneCoreCandidates, _coreCandidate)
        array.push(zoneValidated, false)
        array.push(zoneSources, _src)
    validZone

bullCloseBreak = close > prevRangeHigh
bearCloseBreak = close < prevRangeLow

bullDisplacement = not na(atr) and not na(prevRangeHigh) and close > open and rng >= atrSafe * impulseAtrMult and body >= atrSafe * bodyAtrMult
bearDisplacement = not na(atr) and not na(prevRangeLow) and close < open and rng >= atrSafe * impulseAtrMult and body >= atrSafe * bodyAtrMult

bullBreakStrength = not na(prevRangeHigh) ? math.max(0.0, (close - prevRangeHigh) / atrSafe) : 0.0
bearBreakStrength = not na(prevRangeLow) ? math.max(0.0, (prevRangeLow - close) / atrSafe) : 0.0

volumePass = not useVolume or (not na(volMA) and volume >= volMA * volMult)

bullSetup = bullDisplacement and volumePass and (not preferCloseBreak or bullCloseBreak)
bearSetup = bearDisplacement and volumePass and (not preferCloseBreak or bearCloseBreak)

bullScore = f_qualityScore(bullBreakStrength, body / atrSafe, rng / atrSafe, volRatio, bullCloseBreak)
bearScore = f_qualityScore(bearBreakStrength, body / atrSafe, rng / atrSafe, volRatio, bearCloseBreak)

bullTierInitial = f_initialTier(bullScore)
bearTierInitial = f_initialTier(bearScore)

bullCoreCandidate = f_coreCandidate(bullScore, bullCloseBreak, volumePass)
bearCoreCandidate = f_coreCandidate(bearScore, bearCloseBreak, volumePass)

newDemandZone = false
newSupplyZone = false
newPivotDemandZone = false
newPivotSupplyZone = false

if bullSetup and bullScore >= weakQualityScore
    int off = f_lastOppositeCandle(1, obSearchBars)
    if not na(off)
        float rawTop = f_rawTop(off)
        float rawBot = f_rawBottom(off)
        float top = f_adjustTop(rawTop, rawBot, atrSafe)
        float bot = f_adjustBottom(rawTop, rawBot, atrSafe)
        newDemandZone := f_addZone(1, bar_index - off, top, bot, bullScore, bullTierInitial, bullCoreCandidate, 0)

if bearSetup and bearScore >= weakQualityScore
    int off = f_lastOppositeCandle(-1, obSearchBars)
    if not na(off)
        float rawTop = f_rawTop(off)
        float rawBot = f_rawBottom(off)
        float top = f_adjustTop(rawTop, rawBot, atrSafe)
        float bot = f_adjustBottom(rawTop, rawBot, atrSafe)
        newSupplyZone := f_addZone(-1, bar_index - off, top, bot, bearScore, bearTierInitial, bearCoreCandidate, 0)

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
canUseBase = usePivotFallback and bar_index > pivotRight + baseBars + 5

if canUseBase
    bool supplyEnabled = showPivotZones and (pivotZoneMode == "Both" or pivotZoneMode == "Supply Only")
    bool demandEnabled = showPivotZones and (pivotZoneMode == "Both" or pivotZoneMode == "Demand Only")

    if supplyEnabled and not na(pivotHigh)
        int pivotBar = bar_index - pivotRight
        int leftBar = pivotBar - baseBars + 1

        float wickTop = f_wick_high(pivotRight, baseBars)
        float wickBottom = f_wick_low(pivotRight, baseBars)
        float bodyTop = f_body_high(pivotRight, baseBars)
        float bodyBottom = f_body_low(pivotRight, baseBars)

        float rawTop = pivotZoneHeightMode == "Body Range" ? bodyTop : wickTop
        float rawBottom = pivotZoneHeightMode == "Body Range" ? bodyBottom : pivotZoneHeightMode == "Hybrid" ? bodyBottom : wickBottom

        [zoneTop, zoneBottom] = f_fixPivotZoneHeight(true, rawTop, rawBottom)

        float baseVol = f_base_volume(pivotRight, baseBars)
        float volBase = nz(volMA[pivotRight], baseVol)
        float volumeMult = volBase > 0.0 ? baseVol / volBase : 1.0
        float atrAtPivot = nz(atr[pivotRight], atr)
        float reactionMove = pivotHigh - ta.lowest(low, pivotRight + 1)
        float reactionAtr = atrAtPivot > 0.0 ? math.max(reactionMove / atrAtPivot, 0.0) : 0.0
        float score = f_pivotScore(volumeMult, reactionAtr)
        int tier = f_pivotTier(score)

        bool volumeOK = not pivotUseVolumeFilter or volumeMult >= pivotMinVolumeMult
        bool validHeight = zoneTop > zoneBottom

        if volumeOK and validHeight
            newPivotSupplyZone := f_addZone(-1, leftBar, zoneTop, zoneBottom, score, tier, tier == 2, 1)

    if demandEnabled and not na(pivotLow)
        int pivotBar = bar_index - pivotRight
        int leftBar = pivotBar - baseBars + 1

        float wickTop = f_wick_high(pivotRight, baseBars)
        float wickBottom = f_wick_low(pivotRight, baseBars)
        float bodyTop = f_body_high(pivotRight, baseBars)
        float bodyBottom = f_body_low(pivotRight, baseBars)

        float rawTop = pivotZoneHeightMode == "Body Range" ? bodyTop : pivotZoneHeightMode == "Hybrid" ? bodyTop : wickTop
        float rawBottom = pivotZoneHeightMode == "Body Range" ? bodyBottom : wickBottom

        [zoneTop, zoneBottom] = f_fixPivotZoneHeight(false, rawTop, rawBottom)

        float baseVol = f_base_volume(pivotRight, baseBars)
        float volBase = nz(volMA[pivotRight], baseVol)
        float volumeMult = volBase > 0.0 ? baseVol / volBase : 1.0
        float atrAtPivot = nz(atr[pivotRight], atr)
        float reactionMove = ta.highest(high, pivotRight + 1) - pivotLow
        float reactionAtr = atrAtPivot > 0.0 ? math.max(reactionMove / atrAtPivot, 0.0) : 0.0
        float score = f_pivotScore(volumeMult, reactionAtr)
        int tier = f_pivotTier(score)

        bool volumeOK = not pivotUseVolumeFilter or volumeMult >= pivotMinVolumeMult
        bool validHeight = zoneTop > zoneBottom

        if volumeOK and validHeight
            newPivotDemandZone := f_addZone(1, leftBar, zoneTop, zoneBottom, score, tier, tier == 2, 1)

while array.size(zoneBoxes) > maxZones
    box oldBox = array.shift(zoneBoxes)
    box.delete(oldBox)
    array.shift(zoneTops)
    array.shift(zoneBottoms)
    array.shift(zoneDirs)
    array.shift(zoneStates)
    array.shift(zoneBornBars)
    array.shift(zoneMitigatedBars)
    array.shift(zoneScores)
    array.shift(zoneTiers)
    array.shift(zoneCoreCandidates)
    array.shift(zoneValidated)
    array.shift(zoneSources)

int demand1 = na
int demand2 = na
int demand3 = na
int demand4 = na
int supply1 = na
int supply2 = na
int supply3 = na
int supply4 = na

float demandD1 = 10e10
float demandD2 = 10e10
float demandD3 = 10e10
float demandD4 = 10e10
float supplyD1 = 10e10
float supplyD2 = 10e10
float supplyD3 = 10e10
float supplyD4 = 10e10

int scanSz = array.size(zoneBoxes)
if scanSz > 0
    for i = 0 to scanSz - 1
        float top = array.get(zoneTops, i)
        float bot = array.get(zoneBottoms, i)
        int dir = array.get(zoneDirs, i)
        int st = array.get(zoneStates, i)
        int tier = array.get(zoneTiers, i)
        int src = array.get(zoneSources, i)
        bool weakAllowed = tier > 0 or showWeakZones or src == 1
        bool eligible = weakAllowed and (st == 0 or st == 1 or st == 4 or st == 5)
        bool inZone = close <= top and close >= bot
        if eligible and dir == 1
            float dRaw = inZone ? 0.0 : close > top ? close - top : math.abs(close - bot)
            float d = dRaw * f_priorityWeight(st, tier)
            if d < demandD1
                demandD4 := demandD3
                demand4 := demand3
                demandD3 := demandD2
                demand3 := demand2
                demandD2 := demandD1
                demand2 := demand1
                demandD1 := d
                demand1 := i
            else if d < demandD2
                demandD4 := demandD3
                demand4 := demand3
                demandD3 := demandD2
                demand3 := demand2
                demandD2 := d
                demand2 := i
            else if d < demandD3
                demandD4 := demandD3
                demand4 := demand3
                demandD3 := d
                demand3 := i
            else if d < demandD4
                demandD4 := d
                demand4 := i
        if eligible and dir == -1
            float dRaw = inZone ? 0.0 : close < bot ? bot - close : math.abs(close - top)
            float d = dRaw * f_priorityWeight(st, tier)
            if d < supplyD1
                supplyD4 := supplyD3
                supply4 := supply3
                supplyD3 := supplyD2
                supply3 := supply2
                supplyD2 := supplyD1
                supply2 := supply1
                supplyD1 := d
                supply1 := i
            else if d < supplyD2
                supplyD4 := supplyD3
                supply4 := supply3
                supplyD3 := supplyD2
                supply3 := supply2
                supplyD2 := d
                supply2 := i
            else if d < supplyD3
                supplyD4 := supplyD3
                supply4 := supply3
                supplyD3 := d
                supply3 := i
            else if d < supplyD4
                supplyD4 := d
                supply4 := i

coreDemandPromoted = false
coreSupplyPromoted = false
demandHeld = false
supplyRejected = false

int total = array.size(zoneBoxes)
if total > 0
    for i = total - 1 to 0
        box bx = array.get(zoneBoxes, i)
        float top = array.get(zoneTops, i)
        float bot = array.get(zoneBottoms, i)
        int dir = array.get(zoneDirs, i)
        int state = array.get(zoneStates, i)
        int born = array.get(zoneBornBars, i)
        int mitBar = array.get(zoneMitigatedBars, i)
        float score = array.get(zoneScores, i)
        int tier = array.get(zoneTiers, i)
        bool coreCandidate = array.get(zoneCoreCandidates, i)
        bool validated = array.get(zoneValidated, i)
        int src = array.get(zoneSources, i)

        int age = bar_index - born
        float zoneHeight = math.max(top - bot, syminfo.mintick)
        float bullDepthPrice = top - zoneHeight * mitigationDepthPct / 100.0
        float bearDepthPrice = bot + zoneHeight * mitigationDepthPct / 100.0

        bool wickTouched = high >= bot and low <= top
        bool closeInside = close <= top and close >= bot
        bool penetration = dir == 1 ? low <= bullDepthPrice and high >= bot : high >= bearDepthPrice and low <= top
        bool mitigationRaw = mitigationMode == "Wick Touch" ? wickTouched : mitigationMode == "Close Inside" ? closeInside : penetration
        bool canMitigate = age >= mitigationDelayBars

        bool breakerNow = dir == 1 ? close < bot - atrSafe * wickTolerance : close > top + atrSafe * wickTolerance
        bool invalidNow = dir == 1 ? close < bot - atrSafe * breakerConfirmATR : close > top + atrSafe * breakerConfirmATR

        if state == 0 and breakerNow
            state := 2
        else if state == 0 and canMitigate and mitigationRaw
            state := 1
            mitBar := bar_index
        else if (state == 1 or state == 4 or state == 5) and breakerNow
            state := 2
        else if state == 2 and invalidNow
            state := 3

        bool hasMitBar = not na(mitBar)
        int barsFromMit = hasMitBar ? bar_index - mitBar : na
        bool withinReactionWindow = hasMitBar and barsFromMit <= reactionWindowBars
        bool demandReaction = dir == 1 and state == 1 and withinReactionWindow and high >= top + atrSafe * reactionConfirmATR and close > top
        bool supplyReaction = dir == -1 and state == 1 and withinReactionWindow and low <= bot - atrSafe * reactionConfirmATR and close < bot

        if demandReaction
            state := 4
            demandHeld := true
        else if supplyReaction
            state := 5
            supplyRejected := true

        if not validated and age >= coreValidationBars
            bool demandHold = validationLowestClose >= bot - atrSafe * coreHoldBufferATR
            bool supplyHold = validationHighestClose <= top + atrSafe * coreHoldBufferATR
            bool demandContinuation = validationHighestHigh >= top + atrSafe * coreContinuationATR
            bool supplyContinuation = validationLowestLow <= bot - atrSafe * coreContinuationATR
            bool corePass = coreCandidate and state == 0 and tier == 1 and (dir == 1 ? demandHold and demandContinuation : supplyHold and supplyContinuation)
            if corePass
                tier := 2
                if dir == 1
                    coreDemandPromoted := true
                else
                    coreSupplyPromoted := true
            validated := true

        array.set(zoneStates, i, state)
        array.set(zoneMitigatedBars, i, mitBar)
        array.set(zoneTiers, i, tier)
        array.set(zoneValidated, i, validated)

        bool inZoneNow = close <= top and close >= bot
        float distToZone = close > top ? close - top : close < bot ? bot - close : 0.0
        bool nearPrice = not showOnlyNearPrice or distToZone <= atrSafe * nearATR
        bool recentVisible = age <= recentAlwaysVisibleBars
        bool mitigatedTooOld = state == 1 and not na(mitBar) and bar_index - mitBar > mitigatedHideAfterBars

        bool keyDemand = i == demand1 or (keyZonesPerSide >= 2 and i == demand2) or (keyZonesPerSide >= 3 and i == demand3) or (keyZonesPerSide >= 4 and i == demand4)
        bool keySupply = i == supply1 or (keyZonesPerSide >= 2 and i == supply2) or (keyZonesPerSide >= 3 and i == supply3) or (keyZonesPerSide >= 4 and i == supply4)
        bool keyZone = not showClosestOnly or keyDemand or keySupply or inZoneNow or (tier == 2 and recentVisible)

        bool conflictZone = f_hasOppositeConflict(i, dir, top, bot)
        bool nearbyReaction = f_hasNearbyReaction(i, top, bot)
        bool mitSuppressed = hideMitNearReaction and state == 1 and nearbyReaction

        bool weakAllowed = tier > 0 or showWeakZones or src == 1
        bool activeAllowed = state == 0
        bool mitAllowed = state == 1 and showMitigated and not mitigatedTooOld and not mitSuppressed
        bool reactedAllowed = (state == 4 or state == 5) and showReacted
        bool breakerAllowed = state == 2 and showBreakers
        bool invalidAllowed = state == 3 and showInvalidated
        bool srcAllowed = src == 0 or showPivotZones

        bool stateAllowed = weakAllowed and srcAllowed and (activeAllowed or mitAllowed or reactedAllowed or breakerAllowed or invalidAllowed)
        bool ageAllowed = age <= maxAgeBars
        bool visible = keyZone and (nearPrice or recentVisible or tier == 2 or state == 4 or state == 5) and stateAllowed and ageAllowed

        int dynamicExtend = f_dynamicExtend(state, tier)
        box.set_right(bx, bar_index + dynamicExtend)
        box.set_bgcolor(bx, f_zoneBg(dir, state, visible, tier, keyZone, conflictZone, mitSuppressed, src))
        box.set_border_color(bx, f_zoneBorder(dir, state, visible, tier, keyZone, conflictZone, mitSuppressed, src))
        box.set_border_width(bx, f_borderWidth(tier, keyZone, state))
        box.set_text_color(bx, f_zoneTextColor(state, visible, tier, keyZone, conflictZone, mitSuppressed))
        box.set_text(bx, showBoxText and visible ? f_zoneText(dir, state, score, tier, src) : "")

        if age > maxAgeBars * 2
            box.delete(bx)
            array.remove(zoneBoxes, i)
            array.remove(zoneTops, i)
            array.remove(zoneBottoms, i)
            array.remove(zoneDirs, i)
            array.remove(zoneStates, i)
            array.remove(zoneBornBars, i)
            array.remove(zoneMitigatedBars, i)
            array.remove(zoneScores, i)
            array.remove(zoneTiers, i)
            array.remove(zoneCoreCandidates, i)
            array.remove(zoneValidated, i)
            array.remove(zoneSources, i)

activeBull = false
activeBear = false
mitigatedBull = false
mitigatedBear = false
holdBull = false
rejectBear = false

int sz = array.size(zoneBoxes)
if sz > 0
    for i = 0 to sz - 1
        int dir = array.get(zoneDirs, i)
        int st = array.get(zoneStates, i)
        int tier = array.get(zoneTiers, i)
        int src = array.get(zoneSources, i)
        float top = array.get(zoneTops, i)
        float bot = array.get(zoneBottoms, i)
        bool inZone = close <= top and close >= bot
        bool weakAllowed = tier > 0 or showWeakZones or src == 1
        if weakAllowed and inZone and dir == 1 and st == 0
            activeBull := true
        if weakAllowed and inZone and dir == -1 and st == 0
            activeBear := true
        if weakAllowed and inZone and dir == 1 and st == 1
            mitigatedBull := true
        if weakAllowed and inZone and dir == -1 and st == 1
            mitigatedBear := true
        if weakAllowed and dir == 1 and st == 4
            holdBull := true
        if weakAllowed and dir == -1 and st == 5
            rejectBear := true

plotshape(showZoneMarkers and activeBull, title="Inside Active Demand", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.new(bullColor, 0), text="")
plotshape(showZoneMarkers and activeBear, title="Inside Active Supply", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.new(bearColor, 0), text="")
plotshape(showZoneMarkers and mitigatedBull, title="Inside Mitigated Demand", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.new(bullColor, 55), text="")
plotshape(showZoneMarkers and mitigatedBear, title="Inside Mitigated Supply", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.new(bearColor, 55), text="")
plotshape(showZoneMarkers and holdBull, title="Demand Hold", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.new(reactBullColor, 0), text="")
plotshape(showZoneMarkers and rejectBear, title="Supply Reject", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.new(reactBearColor, 0), text="")

alertcondition(newDemandZone, title="New Demand Zone", message="New demand zone detected.")
alertcondition(newSupplyZone, title="New Supply Zone", message="New supply zone detected.")
alertcondition(newPivotDemandZone, title="New Volume Demand Zone", message="New volume-weighted demand zone detected.")
alertcondition(newPivotSupplyZone, title="New Volume Supply Zone", message="New volume-weighted supply zone detected.")
alertcondition(coreDemandPromoted, title="Core Demand Confirmed", message="Core demand zone confirmed.")
alertcondition(coreSupplyPromoted, title="Core Supply Confirmed", message="Core supply zone confirmed.")
alertcondition(demandHeld, title="Demand Hold Confirmed", message="Demand zone confirmed a hold reaction.")
alertcondition(supplyRejected, title="Supply Reject Confirmed", message="Supply zone confirmed a reject reaction.")
alertcondition(activeBull, title="Price Inside Active Demand", message="Price is inside an active demand zone.")
alertcondition(activeBear, title="Price Inside Active Supply", message="Price is inside an active supply zone.")
````
