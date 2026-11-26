# Liquidity Sweep Trap Zones

- url: https://www.tradingview.com/script/AfUuxK4D-Liquidity-Sweep-Trap-Zones/
- type: indicator
- pine_id: PUB;33256fcb84864225945971b271190622
- version: 1.0

## Description

Liquidity Sweep Trap Zones

Liquidity Sweep Trap Zones is a liquidity-based market structure tool designed to detect swing high and swing low sweeps, possible stop-hunt behavior, trap confirmation zones, and mitigation behavior around swept liquidity levels.

The script evaluates whether price temporarily breaks above a previous swing high or below a previous swing low, then reclaims the level through wick or close behavior. It combines sweep penetration, wick quality, ADX / DMI strength, EMA regime, Ichimoku cloud context, volatility activity, premium / discount location, and zone health tracking to filter weaker sweep events.

It does not provide buy or sell recommendations. The purpose of this script is to help users study liquidity sweeps, false breakouts, trap zones, mitigation behavior, and possible reversal or continuation risk around important swing levels.

────────────────────
Core Concept
────────────────────

Liquidity sweep analysis is based on the idea that price often moves beyond visible swing highs or swing lows before reversing or continuing.

A swing high sweep occurs when price moves above a previous high, potentially triggering breakout entries or stop orders, then fails to hold above that level.

A swing low sweep occurs when price moves below a previous low, potentially triggering breakdown entries or stop orders, then fails to hold below that level.

This script focuses on four liquidity-related concepts:

• Swing high and swing low sweep detection
• Wick reclaim or close reclaim behavior
• Trap confirmation after a swept level
• Liquidity zone tracking and mitigation awareness

When price sweeps a previous swing high and reclaims below it, the script may identify a bearish liquidity trap zone.

When price sweeps a previous swing low and reclaims above it, the script may identify a bullish liquidity trap zone.

The script then uses confirmation and scoring logic to separate stronger trap structures from weaker sweep events.

────────────────────
What This Script Shows
────────────────────

The script can display:

• Bearish liquidity sweep markers
• Bullish liquidity sweep markers
• Bearish trap confirmation labels
• Bullish trap confirmation labels
• Sweep wick zones
• Liquidity sweep reference levels
• Mitigated or expired zone behavior
• Trap score percentages
• Zone health information
• Zone retest count information

These elements are intended to help users review where price interacted with prior liquidity, whether the sweep was reclaimed, and whether the zone remains structurally relevant.

────────────────────
How It Works
────────────────────

1. The script identifies confirmed swing highs and swing lows using pivot-based structure.
2. It monitors whether price breaks above a swing high or below a swing low.
3. ATR is used to normalize sweep penetration so the script can avoid extremely small or excessively large sweeps.
4. Wick ratio logic checks whether the candle shows meaningful rejection around the swept level.
5. ADX and DMI conditions evaluate whether the market has enough directional activity or is trapped in low-energy chop.
6. EMA regime and optional Ichimoku cloud context help evaluate the broader trend environment.
7. Premium / discount logic checks whether the sweep occurs in a more contextually meaningful part of the recent dealing range.
8. Volume and ATR activity filters help reduce weak or inactive market signals.
9. When a sweep is detected, the script creates a liquidity zone around the swept wick and reference level.
10. Trap confirmation can occur immediately or after follow-through, depending on the selected settings.
11. The script assigns a trap score based on reclaim quality, wick behavior, volume, ADX, DMI alignment, regime context, premium / discount location, and candle range.
12. Zone health and tested-count tracking help users review whether a liquidity zone has been repeatedly interacted with or weakened over time.
13. Mitigation logic can mark a level as no longer structurally fresh once price reclaims through it.

────────────────────
Visual Elements
────────────────────

The script includes:

• SWEEP marker
• TRAP↑ label
• TRAP↓ label
• TRAP↑+ label for stronger bullish trap structures
• TRAP↓+ label for stronger bearish trap structures
• Liquidity sweep level line
• Sweep wick zone top and bottom lines
• Semi-transparent sweep zone fill
• Optional weak trap marker
• Trap confidence percentage
• Zone health value
• Zone tested-count value

SWEEP marks a raw liquidity sweep event.

TRAP↑ marks a bullish trap confirmation after a downside sweep.

TRAP↓ marks a bearish trap confirmation after an upside sweep.

TRAP↑+ and TRAP↓+ mark stronger trap structures based on the internal score threshold.

The sweep zone shows the wick area and reference level used by the script while evaluating the liquidity event.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• Swing length
• Sweep trigger mode
• Confirmation on candle close
• Minimum and maximum sweep penetration
• Minimum sweep wick ratio
• Local extreme lookback
• Sweep cooldown
• Same-level blocking distance
• ATR length
• Volume moving average length
• Follow-through confirmation behavior
• Trap confirmation window
• Strong and valid trap score thresholds
• ADX and DMI filters
• EMA regime filter
• Ichimoku cloud context
• ATR activity filter
• Volume activity filter
• Spike sweep blocking
• Premium / discount range
• Liquidity zone visibility
• Zone holding period
• Zone mitigation tracking
• Zone health capacity
• Strong, valid, weak, and sweep marker visibility
• Trap label display
• Marker and zone colors

The default settings are designed to focus on visible liquidity sweep structures while reducing low-quality signals from narrow chop, inactive volatility, repeated mitigated levels, or extreme one-candle spikes.

────────────────────
Reference Markers
────────────────────

The script includes several reference markers and zones.

SWEEP:
Shows when price sweeps a previous swing high or swing low and satisfies the selected reclaim and wick conditions.

TRAP↑:
Shows when a downside liquidity sweep develops into a bullish trap confirmation.

TRAP↓:
Shows when an upside liquidity sweep develops into a bearish trap confirmation.

TRAP↑+:
Shows when a bullish trap confirmation reaches the stronger score threshold.

TRAP↓+:
Shows when a bearish trap confirmation reaches the stronger score threshold.

Sweep Wick Zone:
Shows the wick area created by the sweep candle.

Liquidity Sweep Level:
Shows the prior swing level that was swept and reclaimed.

Zone Health:
Shows a simplified measure of how much interaction the zone has absorbed relative to the configured volume capacity.

Test Count:
Shows how many times the zone has been meaningfully retested after formation.

These markers are not trading signals. They are visual reference points for studying liquidity behavior, false breakouts, stop-hunt style movement, and trap confirmation around prior swing levels.

────────────────────
How To Use
────────────────────

Use this script as a liquidity sweep and trap-zone viewer.

General interpretation examples:

• A sweep above a prior swing high can show where upside liquidity may have been taken.
• A sweep below a prior swing low can show where downside liquidity may have been taken.
• A bearish trap label can help review failed upside breakout behavior.
• A bullish trap label can help review failed downside breakdown behavior.
• A stronger trap label can help identify sweeps with better context, rejection, and scoring conditions.
• A liquidity zone can help users monitor whether the swept area remains relevant.
• Zone health and test count can help users evaluate whether a level is fresh, repeatedly tested, or weakened.
• Mitigation behavior can help users avoid treating old levels as fresh liquidity areas.

This script is best reviewed together with price action, market structure, support and resistance, volume, volatility, and higher-timeframe trend context.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script uses pivot-based swing highs and swing lows. Pivot structures require bars on both sides of the swing point before they are confirmed.

Because of this, swing reference levels appear only after the pivot condition is confirmed.

Sweep and trap conditions are calculated from available chart data. If confirmation on candle close is enabled, signals are intended to be evaluated after the candle closes.

If users disable close confirmation or use realtime bars, intrabar movement may change sweep, reclaim, or trap conditions before the candle closes.

The script does not use future price data to predict upcoming price movement. However, pivot-based swing references are naturally confirmed after a delay because the swing structure itself requires confirmation bars.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

A liquidity sweep does not guarantee reversal.

A trap label does not guarantee continuation in the opposite direction.

Strong trap scores only indicate that the event satisfied more of the selected structural, volatility, regime, and activity conditions.

In very strong trends, price can sweep liquidity and continue in the same direction.

In choppy, low-liquidity, news-driven, or extremely volatile conditions, sweep and trap signals may become less reliable.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Liquidity Sweep Trap Zones

Liquidity Sweep Trap Zones는 스윙 고점과 스윙 저점의 유동성 스윕, 잠재적인 스탑헌팅 움직임, 트랩 확인 구간, 스윕된 유동성 레벨 주변의 미티게이션 행동을 분석하기 위한 유동성 기반 시장 구조 보조지표입니다.

이 스크립트는 가격이 이전 스윙 고점 위 또는 이전 스윙 저점 아래를 일시적으로 돌파한 뒤, wick 또는 종가 기준으로 해당 레벨을 다시 회수하는지 평가합니다. 스윕 침투 깊이, wick 품질, ADX / DMI 강도, EMA 레짐, 일목구름 컨텍스트, 변동성 활동성, 프리미엄 / 디스카운트 위치, 존 헬스 추적을 함께 사용해 약한 스윕 이벤트를 필터링합니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다. 목적은 유동성 스윕, 거짓 돌파, 트랩 구간, 미티게이션 행동, 주요 스윙 레벨 주변의 반전 또는 지속 위험을 관찰하는 것입니다.

────────────────────
핵심 개념
────────────────────

유동성 스윕 분석은 가격이 눈에 잘 보이는 스윙 고점 또는 스윙 저점을 넘어선 뒤 반전하거나 계속 진행되는 경우가 많다는 개념을 기반으로 합니다.

스윙 고점 스윕은 가격이 이전 고점 위로 올라가 돌파 매수 또는 손절 주문을 유발한 뒤, 그 레벨 위에서 유지되지 못할 때 발생합니다.

스윙 저점 스윕은 가격이 이전 저점 아래로 내려가 이탈 매도 또는 손절 주문을 유발한 뒤, 그 레벨 아래에서 유지되지 못할 때 발생합니다.

이 스크립트는 네 가지 유동성 관련 개념에 초점을 둡니다.

• 스윙 고점과 스윙 저점 스윕 감지
• Wick 회수 또는 종가 회수 행동
• 스윕된 레벨 이후 트랩 확인
• 유동성 존 추적 및 미티게이션 인식

가격이 이전 스윙 고점을 스윕한 뒤 다시 아래로 회수하면, 스크립트는 하락형 유동성 트랩 구간을 식별할 수 있습니다.

가격이 이전 스윙 저점을 스윕한 뒤 다시 위로 회수하면, 스크립트는 상승형 유동성 트랩 구간을 식별할 수 있습니다.

이후 확인 및 스코어링 로직을 사용해 강한 트랩 구조와 약한 스윕 이벤트를 구분합니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 하락형 유동성 스윕 마커
• 상승형 유동성 스윕 마커
• 하락형 트랩 확인 라벨
• 상승형 트랩 확인 라벨
• Sweep wick zone
• 유동성 스윕 기준 레벨
• 미티게이션 또는 만료된 존 행동
• 트랩 점수 퍼센트
• 존 헬스 정보
• 존 재테스트 횟수 정보

이 요소들은 가격이 이전 유동성과 어디에서 상호작용했는지, 스윕 이후 회수 행동이 있었는지, 해당 존이 여전히 구조적으로 의미가 있는지 복기할 수 있도록 돕습니다.

────────────────────
작동 방식
────────────────────

1. 피벗 기반 구조를 사용해 확정된 스윙 고점과 스윙 저점을 식별합니다.
2. 가격이 스윙 고점 위 또는 스윙 저점 아래로 돌파하는지 감시합니다.
3. ATR을 사용해 스윕 침투 깊이를 정규화하여 너무 작은 스윕이나 과도하게 큰 스윕을 줄입니다.
4. Wick 비율 로직을 통해 스윕된 레벨 주변에서 의미 있는 거부 반응이 있었는지 확인합니다.
5. ADX와 DMI 조건을 통해 시장에 충분한 방향성 활동성이 있는지 또는 저에너지 횡보인지 평가합니다.
6. EMA 레짐과 선택 가능한 일목구름 컨텍스트를 통해 더 넓은 추세 환경을 확인합니다.
7. 프리미엄 / 디스카운트 로직은 스윕이 최근 dealing range 안에서 더 의미 있는 위치에서 발생했는지 평가합니다.
8. 거래량과 ATR 활동성 필터는 약하거나 비활성화된 시장 신호를 줄이는 데 사용됩니다.
9. 스윕이 감지되면 스크립트는 스윕 wick과 기준 레벨 주변에 유동성 존을 생성합니다.
10. 선택한 설정에 따라 트랩 확인은 즉시 발생하거나 후속 움직임 이후 발생할 수 있습니다.
11. 스크립트는 회수 품질, wick 행동, 거래량, ADX, DMI 정렬, 레짐 컨텍스트, 프리미엄 / 디스카운트 위치, 캔들 범위를 기반으로 트랩 점수를 부여합니다.
12. 존 헬스와 테스트 횟수 추적은 유동성 존이 반복적으로 테스트되었는지 또는 시간이 지나며 약화되었는지 복기할 수 있도록 돕습니다.
13. 미티게이션 로직은 가격이 해당 레벨을 다시 회수하면 그 레벨이 더 이상 신선한 구조가 아닐 수 있음을 표시할 수 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• SWEEP 마커
• TRAP↑ 라벨
• TRAP↓ 라벨
• 더 강한 상승형 트랩 구조를 나타내는 TRAP↑+ 라벨
• 더 강한 하락형 트랩 구조를 나타내는 TRAP↓+ 라벨
• Liquidity sweep level line
• Sweep wick zone 상단 및 하단 라인
• 반투명 sweep zone fill
• 선택 가능한 약한 트랩 마커
• 트랩 신뢰도 퍼센트
• 존 헬스 값
• 존 테스트 횟수 값

SWEEP은 기본 유동성 스윕 이벤트를 표시합니다.

TRAP↑는 하방 스윕 이후 상승형 트랩 확인을 표시합니다.

TRAP↓는 상방 스윕 이후 하락형 트랩 확인을 표시합니다.

TRAP↑+와 TRAP↓+는 내부 점수 기준을 충족한 더 강한 트랩 구조를 표시합니다.

스윕 존은 스크립트가 유동성 이벤트를 평가할 때 사용한 wick 영역과 기준 레벨을 보여줍니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• Swing Length
• Sweep Trigger Mode
• Confirm Only On Closed Bar
• 최소 및 최대 스윕 침투 깊이
• 최소 sweep wick ratio
• Local extreme lookback
• Sweep cooldown
• Same-level blocking distance
• ATR Length
• Volume MA Length
• Follow-through confirmation behavior
• Trap confirmation window
• Strong / valid trap score thresholds
• ADX and DMI filters
• EMA regime filter
• Ichimoku cloud context
• ATR activity filter
• Volume activity filter
• Spike sweep blocking
• Premium / discount range
• Liquidity zone visibility
• Zone holding period
• Zone mitigation tracking
• Zone health capacity
• Strong, valid, weak, sweep marker visibility
• Trap label display
• Marker and zone colors

기본 설정은 좁은 횡보, 비활성 변동성, 반복적으로 미티게이션된 레벨, 극단적인 단일 캔들 스파이크에서 발생하는 저품질 신호를 줄이면서, 눈에 보이는 유동성 스윕 구조에 집중하도록 구성되어 있습니다.

────────────────────
참고 마커
────────────────────

이 스크립트에는 여러 참고 마커와 존이 포함되어 있습니다.

SWEEP:
가격이 이전 스윙 고점 또는 스윙 저점을 스윕하고, 선택한 회수 및 wick 조건을 만족할 때 표시됩니다.

TRAP↑:
하방 유동성 스윕이 상승형 트랩 확인으로 발전할 때 표시됩니다.

TRAP↓:
상방 유동성 스윕이 하락형 트랩 확인으로 발전할 때 표시됩니다.

TRAP↑+:
상승형 트랩 확인이 더 강한 점수 기준을 충족할 때 표시됩니다.

TRAP↓+:
하락형 트랩 확인이 더 강한 점수 기준을 충족할 때 표시됩니다.

Sweep Wick Zone:
스윕 캔들이 만든 wick 영역을 표시합니다.

Liquidity Sweep Level:
스윕되고 회수된 이전 스윙 레벨을 표시합니다.

Zone Health:
설정된 거래량 capacity 대비 해당 존이 얼마나 많은 상호작용을 흡수했는지 단순화해 보여줍니다.

Test Count:
존 형성 이후 해당 구간이 의미 있게 재테스트된 횟수를 표시합니다.

이 마커들은 매매 신호가 아닙니다. 유동성 행동, 거짓 돌파, 스탑헌팅성 움직임, 이전 스윙 레벨 주변의 트랩 확인을 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 유동성 스윕과 트랩 존 확인용 보조지표로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 이전 스윙 고점 위의 스윕은 상방 유동성이 처리된 위치를 보여줄 수 있습니다.
• 이전 스윙 저점 아래의 스윕은 하방 유동성이 처리된 위치를 보여줄 수 있습니다.
• 하락형 트랩 라벨은 실패한 상방 돌파 행동을 복기하는 데 사용할 수 있습니다.
• 상승형 트랩 라벨은 실패한 하방 이탈 행동을 복기하는 데 사용할 수 있습니다.
• 더 강한 트랩 라벨은 컨텍스트, 거부 반응, 스코어 조건이 더 양호한 스윕을 식별하는 데 도움을 줄 수 있습니다.
• 유동성 존은 스윕된 구간이 여전히 의미 있는지 관찰하는 데 사용할 수 있습니다.
• 존 헬스와 테스트 횟수는 해당 레벨이 신선한지, 반복 테스트되었는지, 또는 약화되었는지 평가하는 데 도움을 줄 수 있습니다.
• 미티게이션 행동은 오래된 레벨을 신선한 유동성 영역으로 계속 해석하지 않도록 돕습니다.

이 스크립트는 가격 행동, 시장 구조, 지지와 저항, 거래량, 변동성, 상위 시간대 추세 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 피벗 기반 스윙 고점과 스윙 저점을 사용합니다. 피벗 구조는 스윙 지점의 좌우에 필요한 수의 봉이 형성된 뒤에 확정됩니다.

따라서 스윙 기준 레벨은 피벗 조건이 확정된 후에만 나타납니다.

스윕과 트랩 조건은 차트에서 사용 가능한 데이터를 기준으로 계산됩니다. 봉 마감 확인 옵션이 켜져 있다면, 신호는 봉 마감 이후 평가하는 것을 전제로 합니다.

사용자가 종가 확인을 비활성화하거나 실시간 봉에서 사용할 경우, 봉이 마감되기 전의 움직임에 따라 스윕, 회수, 트랩 조건이 달라질 수 있습니다.

이 스크립트는 향후 가격 움직임을 예측하기 위해 미래 가격 데이터를 사용하지 않습니다. 다만 피벗 기반 스윙 기준은 구조상 확인봉이 필요하기 때문에 자연스럽게 지연되어 확정됩니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

유동성 스윕은 반전을 보장하지 않습니다.

트랩 라벨은 반대 방향의 지속을 보장하지 않습니다.

강한 트랩 점수는 해당 이벤트가 선택된 구조, 변동성, 레짐, 활동성 조건을 더 많이 만족했다는 의미일 뿐입니다.

강한 추세에서는 가격이 유동성을 스윕한 뒤 같은 방향으로 계속 진행될 수 있습니다.

횡보가 심한 시장, 저유동성 환경, 뉴스성 급등락, 극단적 변동성 구간에서는 스윕 및 트랩 신호의 신뢰도가 낮아질 수 있습니다.

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
indicator("Liquidity Sweep Trap Zones", shorttitle="LiqTrap", overlay=true, max_labels_count=100, max_bars_back=5000)

//============================================================================
// Inputs
//============================================================================
groupSwing = "① Swing / Sweep Detection"
swingLen = input.int(8, "Swing Length", minval=2, maxval=50, group=groupSwing)
sweepMode = input.string("Wick Reclaim", "Sweep Trigger Mode", options=["Wick Reclaim", "Close Reclaim"], group=groupSwing)
confirmOnClose = input.bool(true, "Confirm Only On Closed Bar", group=groupSwing)
minSweepPenAtr = input.float(0.08, "Minimum Sweep Penetration ATR", minval=0.01, maxval=2.0, step=0.01, group=groupSwing)
maxSweepPenAtr = input.float(1.45, "Maximum Healthy Sweep Penetration ATR", minval=0.10, maxval=5.0, step=0.05, group=groupSwing)
minSweepWickRatio = input.float(0.34, "Minimum Sweep Wick Ratio", minval=0.10, maxval=0.95, step=0.01, group=groupSwing)
sweepExtremeLookback = input.int(5, "Local Extreme Lookback", minval=2, maxval=50, group=groupSwing)
sweepCooldownBars = input.int(10, "Sweep Cooldown Bars", minval=1, maxval=100, group=groupSwing)
sameLevelAtrBlock = input.float(0.24, "Same Level ATR Block", minval=0.01, maxval=3.0, step=0.01, group=groupSwing)

groupTrap = "② Trap Confirmation"
atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=groupTrap)
volLen = input.int(20, "Volume MA Length", minval=1, maxval=200, group=groupTrap)
useFollowThrough = input.bool(false, "Require Follow-Through", group=groupTrap)
confirmBars = input.int(1, "Minimum Bars To Confirm", minval=1, maxval=5, group=groupTrap)
maxBarsToConfirm = input.int(4, "Maximum Bars To Confirm", minval=1, maxval=10, group=groupTrap)
confirmMoveAtr = input.float(0.08, "Confirm Move ATR", minval=0.00, maxval=2.0, step=0.01, group=groupTrap)
minStrongScore = input.int(74, "Strong Trap Score", minval=50, maxval=100, group=groupTrap)
minValidScore = input.int(52, "Valid Trap Score", minval=20, maxval=95, group=groupTrap)
minSignalGapBars = input.int(8, "Minimum Trap Signal Gap Bars", minval=0, maxval=100, group=groupTrap)

groupADX = "③ ADX / DMI Quality Filter"
useAdxFilter = input.bool(true, "Use ADX Strength Filter", group=groupADX)
adxLen = input.int(14, "ADX Length", minval=1, maxval=50, group=groupADX)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, maxval=50, group=groupADX)
minAdxForTrap = input.float(14.0, "Minimum ADX For Trap", minval=5.0, maxval=60.0, step=0.5, group=groupADX)
strongAdxLevel = input.float(23.0, "Strong ADX Level", minval=10.0, maxval=80.0, step=0.5, group=groupADX)
useDmiAlignment = input.bool(true, "Use DMI Direction Quality", group=groupADX)
dmiPenalty = input.float(8.0, "DMI Misalignment Penalty", minval=0.0, maxval=40.0, step=1.0, group=groupADX)
blockLowEnergyDmi = input.bool(true, "Block Low-Energy DMI Chop", group=groupADX)
chopAdxMax = input.float(13.0, "Chop ADX Max", minval=5.0, maxval=40.0, step=0.5, group=groupADX)
chopDiGapMax = input.float(3.0, "Chop DI Gap Max", minval=0.0, maxval=20.0, step=0.25, group=groupADX)

groupRegime = "④ Regime / Cloud Filter"
useEmaRegime = input.bool(true, "Use EMA Regime Filter", group=groupRegime)
emaFastLen = input.int(21, "Fast EMA", minval=1, maxval=300, group=groupRegime)
emaSlowLen = input.int(55, "Slow EMA", minval=2, maxval=500, group=groupRegime)
useKumoFilter = input.bool(false, "Use Ichimoku Cloud Context", group=groupRegime)
tenkanLen = input.int(9, "Tenkan Length", minval=1, maxval=100, group=groupRegime)
kijunLen = input.int(26, "Kijun Length", minval=1, maxval=200, group=groupRegime)
spanBLen = input.int(52, "Senkou B Length", minval=2, maxval=300, group=groupRegime)
regimeSoftPenalty = input.float(7.0, "Counter-Regime Soft Penalty", minval=0.0, maxval=40.0, step=1.0, group=groupRegime)
hardBlockAgainstStrongRegime = input.bool(false, "Hard Block Against Strong Regime", group=groupRegime)
strongRegimeHoldBars = input.int(8, "Strong Regime Hold Bars", minval=1, maxval=50, group=groupRegime)

groupNoise = "⑤ Noise / Activity Filters"
useAtrActivityFilter = input.bool(true, "Use ATR Activity Filter", group=groupNoise)
atrMaLen = input.int(50, "ATR MA Length", minval=5, maxval=300, group=groupNoise)
minAtrRel = input.float(0.65, "Minimum ATR / ATR MA", minval=0.10, maxval=5.0, step=0.05, group=groupNoise)
useVolumeFilter = input.bool(false, "Use Volume Activity Filter", group=groupNoise)
minVolRel = input.float(0.60, "Minimum Volume / Volume MA", minval=0.10, maxval=5.0, step=0.05, group=groupNoise)
volStrongMult = input.float(1.20, "Strong Volume Multiple", minval=0.10, maxval=10.0, step=0.05, group=groupNoise)
volValidMult = input.float(0.85, "Valid Volume Multiple", minval=0.10, maxval=10.0, step=0.05, group=groupNoise)
maxCandleRangeAtr = input.float(4.80, "Maximum Candle Range ATR", minval=0.50, maxval=20.0, step=0.10, group=groupNoise)
blockSpikeSweeps = input.bool(true, "Block Extreme Spike Sweeps", group=groupNoise)
postSpikeBlockBars = input.int(1, "Post Spike Block Bars", minval=0, maxval=20, group=groupNoise)

groupPD = "⑥ Premium / Discount Context"
useDealingRangeScore = input.bool(true, "Use Premium / Discount Score", group=groupPD)
pdLookback = input.int(80, "Dealing Range Lookback", minval=10, maxval=500, group=groupPD)
premiumThreshold = input.float(0.60, "Premium Threshold", minval=0.50, maxval=0.95, step=0.01, group=groupPD)
discountThreshold = input.float(0.40, "Discount Threshold", minval=0.05, maxval=0.50, step=0.01, group=groupPD)

groupZone = "⑦ Zone Tracking"
showLiquidityZones = input.bool(true, "Show Liquidity Zone", group=groupZone)
showOnlyLatestZone = input.bool(true, "Show Only Latest Zone", group=groupZone)
zoneHoldBars = input.int(120, "Zone Hold Bars", minval=5, maxval=500, group=groupZone)
zoneLineWidth = input.int(2, "Zone Line Width", minval=1, maxval=4, group=groupZone)
zoneFillTransparency = input.int(88, "Zone Fill Transparency", minval=70, maxval=98, group=groupZone)
useMitigationTracking = input.bool(true, "Track Mitigation", group=groupZone)
mitigationMode = input.string("Close", "Mitigation Mode", options=["Wick", "Close"], group=groupZone)
hideMitigatedLevelSignals = input.bool(true, "Hide Signals At Mitigated Level", group=groupZone)
zoneHealthCapacity = input.float(3.0, "Zone Health Capacity Volume xMA", minval=0.5, maxval=20.0, step=0.5, group=groupZone)
showZoneHealth = input.bool(true, "Show Zone Health", group=groupZone)
showTestedCount = input.bool(true, "Show Tested Count", group=groupZone)

groupDisplay = "⑧ Display"
showStrongOnly = input.bool(false, "Show Strong Only", group=groupDisplay)
showValidSignals = input.bool(true, "Show Valid Trap Signals", group=groupDisplay)
showWeakSignals = input.bool(false, "Show Weak Trap Signals", group=groupDisplay)
showSweepSignals = input.bool(true, "Show Sweep Markers", group=groupDisplay)
suppressSweepWhenTrap = input.bool(true, "Hide Sweep If Trap Same Bar", group=groupDisplay)
suppressSweepNearTrap = input.bool(false, "Hide Sweep Near Trap", group=groupDisplay)
sweepSuppressBars = input.int(6, "Sweep Suppress Bars After Trap", minval=1, maxval=50, group=groupDisplay)
showConfidencePct = input.bool(true, "Show Confidence %", group=groupDisplay)
showSignalTags = input.bool(true, "Show Trap Text Labels", group=groupDisplay)

groupStyle = "⑨ Style"
sweepColor = input.color(color.rgb(255, 210, 70), "Sweep Color", group=groupStyle)
bearTrapColor = input.color(color.rgb(230, 80, 100), "Bearish Trap Color", group=groupStyle)
bearTrapValidColor = input.color(color.rgb(255, 150, 70), "Bearish Valid Color", group=groupStyle)
bullTrapColor = input.color(color.rgb(0, 200, 160), "Bullish Trap Color", group=groupStyle)
bullTrapValidColor = input.color(color.rgb(80, 210, 255), "Bullish Valid Color", group=groupStyle)
weakColor = input.color(color.rgb(150, 150, 150), "Weak Marker Color", group=groupStyle)
expiredColor = input.color(color.rgb(120, 120, 120), "Expired Zone Color", group=groupStyle)
textColor = input.color(color.white, "Text Color", group=groupStyle)

//============================================================================
// Core Series
//============================================================================
atrV = ta.atr(atrLen)
atrMA = ta.sma(atrV, atrMaLen)
atrSafe = math.max(nz(atrV), syminfo.mintick)

volMA = ta.sma(volume, volLen)
volRel = not na(volMA) and volMA > 0 ? volume / volMA : 1.0
atrRel = not na(atrMA) and atrMA > 0 ? atrV / atrMA : 1.0

rangeNow = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperWickRatio = upperWick / rangeNow
lowerWickRatio = lowerWick / rangeNow
rangeAtr = rangeNow / atrSafe

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmooth)
diGap = math.abs(diPlus - diMinus)
adxStrengthOk = not useAdxFilter or adx >= minAdxForTrap

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaBull = emaFast > emaSlow and close >= emaFast
emaBear = emaFast < emaSlow and close <= emaFast

emaBullHold = ta.barssince(not emaBull)
emaBearHold = ta.barssince(not emaBear)
strongEmaBull = useEmaRegime and not na(emaBullHold) and emaBullHold >= strongRegimeHoldBars
strongEmaBear = useEmaRegime and not na(emaBearHold) and emaBearHold >= strongRegimeHoldBars

tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2.0
kijun = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2.0
spanA = (tenkan + kijun) / 2.0
spanB = (ta.highest(high, spanBLen) + ta.lowest(low, spanBLen)) / 2.0
kumoTop = math.max(spanA, spanB)
kumoBottom = math.min(spanA, spanB)

kumoBull = close > kumoTop and spanA >= spanB
kumoBear = close < kumoBottom and spanA <= spanB
kumoNeutral = not kumoBull and not kumoBear

bearRegimeOk = (not useEmaRegime or emaBear or not strongEmaBull) and (not useKumoFilter or kumoBear or kumoNeutral)
bullRegimeOk = (not useEmaRegime or emaBull or not strongEmaBear) and (not useKumoFilter or kumoBull or kumoNeutral)

hardBearBlocked = hardBlockAgainstStrongRegime and ((useEmaRegime and strongEmaBull) or (useKumoFilter and kumoBull))
hardBullBlocked = hardBlockAgainstStrongRegime and ((useEmaRegime and strongEmaBear) or (useKumoFilter and kumoBear))

lowEnergyChop = blockLowEnergyDmi and adx <= chopAdxMax and diGap <= chopDiGapMax
activityOk = (not useAtrActivityFilter or atrRel >= minAtrRel) and (not useVolumeFilter or volRel >= minVolRel)
spikeBlocked = blockSpikeSweeps and rangeAtr > maxCandleRangeAtr
recentSpikeBar = ta.barssince(rangeAtr > maxCandleRangeAtr)
postSpikeBlocked = postSpikeBlockBars > 0 and not na(recentSpikeBar) and recentSpikeBar <= postSpikeBlockBars

pdHigh = ta.highest(high, pdLookback)
pdLow = ta.lowest(low, pdLookback)
pdRange = math.max(pdHigh - pdLow, syminfo.mintick)
pdPosition = (close - pdLow) / pdRange
inPremium = pdPosition >= premiumThreshold
inDiscount = pdPosition <= discountThreshold

penetrationAtrMax = maxSweepPenAtr * 0.65

//============================================================================
// Swing Structure
//============================================================================
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - swingLen

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - swingLen

validHighRef = not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index > lastSwingHighBar
validLowRef = not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index > lastSwingLowBar

bearPenAtr = validHighRef ? (high - lastSwingHigh) / atrSafe : 0.0
bullPenAtr = validLowRef ? (lastSwingLow - low) / atrSafe : 0.0

bearBreak = validHighRef and high > lastSwingHigh + atrSafe * minSweepPenAtr
bullBreak = validLowRef and low < lastSwingLow - atrSafe * minSweepPenAtr

bearReclaim = validHighRef and close < lastSwingHigh
bullReclaim = validLowRef and close > lastSwingLow

bearWickOk = upperWickRatio >= minSweepWickRatio
bullWickOk = lowerWickRatio >= minSweepWickRatio

bearExtreme = high >= ta.highest(high, sweepExtremeLookback)
bullExtreme = low <= ta.lowest(low, sweepExtremeLookback)

bearModeOk = sweepMode == "Wick Reclaim" ? bearReclaim and bearWickOk : bearReclaim
bullModeOk = sweepMode == "Wick Reclaim" ? bullReclaim and bullWickOk : bullReclaim

confirmedOk = not confirmOnClose or barstate.isconfirmed

//============================================================================
// Zone / Mitigation State
//============================================================================
var float zoneTop = na
var float zoneBottom = na
var float zoneLevel = na
var int zoneSide = 0
var int zoneState = 0
var int zoneStartBar = na
var int zoneConfirmBar = na
var float zoneCumulativeVolume = 0.0
var int zoneTestedCount = 0
var float zoneHealthPct = 100.0
var bool zoneIsMitigated = false

var float lastBearLevel = na
var float lastBullLevel = na
var bool lastBearMitigated = false
var bool lastBullMitigated = false
var int lastBearTestCount = 0
var int lastBullTestCount = 0
var float lastBearHealth = 100.0
var float lastBullHealth = 100.0

bearMitigatedNow = useMitigationTracking and not na(lastBearLevel) and (mitigationMode == "Close" ? close > lastBearLevel : high > lastBearLevel + atrSafe * 0.20)
bullMitigatedNow = useMitigationTracking and not na(lastBullLevel) and (mitigationMode == "Close" ? close < lastBullLevel : low < lastBullLevel - atrSafe * 0.20)

if bearMitigatedNow and not lastBearMitigated
    lastBearMitigated := true
    if zoneSide == 1
        zoneIsMitigated := true
        zoneState := 4

if bullMitigatedNow and not lastBullMitigated
    lastBullMitigated := true
    if zoneSide == -1
        zoneIsMitigated := true
        zoneState := 4

bearMitigatedBlocked = hideMitigatedLevelSignals and not na(lastBearLevel) and validHighRef and math.abs(lastSwingHigh - lastBearLevel) <= atrSafe * sameLevelAtrBlock and lastBearMitigated
bullMitigatedBlocked = hideMitigatedLevelSignals and not na(lastBullLevel) and validLowRef and math.abs(lastSwingLow - lastBullLevel) <= atrSafe * sameLevelAtrBlock and lastBullMitigated

//============================================================================
// Sweep Signals
//============================================================================
var int lastBearSweepBar = na
var int lastBullSweepBar = na
var float lastBearSweepPrice = na
var float lastBullSweepPrice = na
var int lastTrapBar = na

bearCooldownOk = na(lastBearSweepBar) or bar_index - lastBearSweepBar >= sweepCooldownBars
bullCooldownOk = na(lastBullSweepBar) or bar_index - lastBullSweepBar >= sweepCooldownBars

bearLevelOk = na(lastBearSweepPrice) or math.abs(high - lastBearSweepPrice) > atrSafe * sameLevelAtrBlock
bullLevelOk = na(lastBullSweepPrice) or math.abs(low - lastBullSweepPrice) > atrSafe * sameLevelAtrBlock

nearTrapBlocked = suppressSweepNearTrap and not na(lastTrapBar) and bar_index - lastTrapBar <= sweepSuppressBars

bearSweepRaw = confirmedOk and bearBreak and bearModeOk and bearExtreme and bearPenAtr <= maxSweepPenAtr and activityOk and adxStrengthOk and not lowEnergyChop and not spikeBlocked and not postSpikeBlocked and bearRegimeOk and not hardBearBlocked and not bearMitigatedBlocked
bullSweepRaw = confirmedOk and bullBreak and bullModeOk and bullExtreme and bullPenAtr <= maxSweepPenAtr and activityOk and adxStrengthOk and not lowEnergyChop and not spikeBlocked and not postSpikeBlocked and bullRegimeOk and not hardBullBlocked and not bullMitigatedBlocked

bearSweepSignal = bearSweepRaw and bearCooldownOk and bearLevelOk and not nearTrapBlocked
bullSweepSignal = bullSweepRaw and bullCooldownOk and bullLevelOk and not nearTrapBlocked

if bearSweepSignal
    lastBearSweepBar := bar_index
    lastBearSweepPrice := high
    lastBearLevel := lastSwingHigh
    lastBearMitigated := false
    lastBearTestCount := 1
    lastBearHealth := 100.0
    if showLiquidityZones and showOnlyLatestZone
        zoneTop := high
        zoneBottom := lastSwingHigh
        zoneLevel := lastSwingHigh
        zoneSide := 1
        zoneState := 1
        zoneStartBar := bar_index
        zoneConfirmBar := na
        zoneCumulativeVolume := 0.0
        zoneTestedCount := 1
        zoneHealthPct := 100.0
        zoneIsMitigated := false

if bullSweepSignal
    lastBullSweepBar := bar_index
    lastBullSweepPrice := low
    lastBullLevel := lastSwingLow
    lastBullMitigated := false
    lastBullTestCount := 1
    lastBullHealth := 100.0
    if showLiquidityZones and showOnlyLatestZone
        zoneTop := lastSwingLow
        zoneBottom := low
        zoneLevel := lastSwingLow
        zoneSide := -1
        zoneState := 1
        zoneStartBar := bar_index
        zoneConfirmBar := na
        zoneCumulativeVolume := 0.0
        zoneTestedCount := 1
        zoneHealthPct := 100.0
        zoneIsMitigated := false

//============================================================================
// Score Engine
//============================================================================
f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_score(_isBear) =>
    float penAtr = _isBear ? bearPenAtr : bullPenAtr
    float wickRatio = _isBear ? upperWickRatio : lowerWickRatio
    bool reclaimOk = _isBear ? bearReclaim : bullReclaim
    bool wickOk = _isBear ? bearWickOk : bullWickOk
    bool dmiAligned = _isBear ? diMinus > diPlus : diPlus > diMinus
    bool regimeAligned = _isBear ? (emaBear or kumoBear) : (emaBull or kumoBull)
    bool pdAligned = _isBear ? inPremium : inDiscount
    float score = 0.0
    score += reclaimOk ? 22.0 : 0.0
    score += wickOk ? f_clamp(wickRatio / math.max(minSweepWickRatio, 0.01) * 15.0, 0.0, 15.0) : 0.0
    score += penAtr >= minSweepPenAtr and penAtr <= penetrationAtrMax ? 12.0 : penAtr <= maxSweepPenAtr ? 6.0 : 0.0
    score += volRel >= volStrongMult ? 14.0 : volRel >= volValidMult ? 8.0 : 0.0
    score += adx >= strongAdxLevel ? 10.0 : adx >= minAdxForTrap ? 6.0 : 0.0
    score += dmiAligned ? 10.0 : useDmiAlignment ? -dmiPenalty : 0.0
    score += regimeAligned ? 8.0 : -regimeSoftPenalty
    score += useDealingRangeScore and pdAligned ? 9.0 : useDealingRangeScore ? -5.0 : 0.0
    score += rangeAtr <= maxCandleRangeAtr ? 5.0 : -10.0
    f_clamp(score, 0.0, 100.0)

bearBaseScore = f_score(true)
bullBaseScore = f_score(false)

//============================================================================
// Pending Trap Confirmation
//============================================================================
var int pendingSide = 0
var float pendingScore = na
var int pendingBar = na
var float pendingConfirmTarget = na
var float pendingLevel = na
var float pendingTop = na
var float pendingBottom = na

canArmBear = bearSweepSignal and pendingSide == 0
canArmBull = bullSweepSignal and pendingSide == 0

if canArmBear
    pendingSide := 1
    pendingScore := bearBaseScore
    pendingBar := bar_index
    pendingConfirmTarget := close - atrSafe * confirmMoveAtr
    pendingLevel := lastSwingHigh
    pendingTop := high
    pendingBottom := lastSwingHigh

if canArmBull
    pendingSide := -1
    pendingScore := bullBaseScore
    pendingBar := bar_index
    pendingConfirmTarget := close + atrSafe * confirmMoveAtr
    pendingLevel := lastSwingLow
    pendingTop := lastSwingLow
    pendingBottom := low

pendingAge = pendingSide != 0 and not na(pendingBar) ? bar_index - pendingBar : na
pendingReady = pendingSide != 0 and not na(pendingAge) and pendingAge >= confirmBars
pendingExpired = pendingSide != 0 and not na(pendingAge) and pendingAge > maxBarsToConfirm

bearFollowThrough = pendingSide == 1 and pendingReady and close <= pendingConfirmTarget
bullFollowThrough = pendingSide == -1 and pendingReady and close >= pendingConfirmTarget

triggerNow = pendingSide != 0 and (not useFollowThrough ? pendingAge == 0 : bearFollowThrough or bullFollowThrough)

var int lastPrintedTrapBar = na
canPrintTrap = na(lastPrintedTrapBar) or bar_index - lastPrintedTrapBar >= minSignalGapBars

bool strongBearTrap = false
bool validBearTrap = false
bool weakBearTrap = false
bool strongBullTrap = false
bool validBullTrap = false
bool weakBullTrap = false

var float lastSignalScore = 0.0
var int lastSignalTests = 0
var float lastSignalHealth = 100.0

if triggerNow and canPrintTrap
    finalScore = f_clamp(nz(pendingScore, 0.0), 0.0, 100.0)
    lastSignalScore := finalScore
    if pendingSide == 1
        strongBearTrap := finalScore >= minStrongScore
        validBearTrap := finalScore >= minValidScore and finalScore < minStrongScore
        weakBearTrap := finalScore < minValidScore
        lastSignalTests := lastBearTestCount
        lastSignalHealth := lastBearHealth
        if showLiquidityZones and (strongBearTrap or validBearTrap)
            zoneState := 2
            zoneConfirmBar := bar_index
    if pendingSide == -1
        strongBullTrap := finalScore >= minStrongScore
        validBullTrap := finalScore >= minValidScore and finalScore < minStrongScore
        weakBullTrap := finalScore < minValidScore
        lastSignalTests := lastBullTestCount
        lastSignalHealth := lastBullHealth
        if showLiquidityZones and (strongBullTrap or validBullTrap)
            zoneState := 3
            zoneConfirmBar := bar_index
    if strongBearTrap or validBearTrap or strongBullTrap or validBullTrap
        lastTrapBar := bar_index
    lastPrintedTrapBar := bar_index
    pendingSide := 0
    pendingScore := na
    pendingBar := na
    pendingConfirmTarget := na
    pendingLevel := na
    pendingTop := na
    pendingBottom := na
else if triggerNow and not canPrintTrap
    pendingSide := 0
    pendingScore := na
    pendingBar := na
    pendingConfirmTarget := na
    pendingLevel := na
    pendingTop := na
    pendingBottom := na

if pendingExpired
    if showLiquidityZones and zoneState == 1
        zoneState := 4
        zoneConfirmBar := bar_index
    pendingSide := 0
    pendingScore := na
    pendingBar := na
    pendingConfirmTarget := na
    pendingLevel := na
    pendingTop := na
    pendingBottom := na

//============================================================================
// Zone Health / Test Tracking
//============================================================================
zoneActiveRaw = showLiquidityZones and not na(zoneTop) and not na(zoneBottom) and not na(zoneStartBar)

if zoneActiveRaw and bar_index > zoneStartBar
    zoneTouched = low <= zoneTop and high >= zoneBottom
    if zoneTouched
        capacityVol = nz(volMA, volume) * zoneHealthCapacity
        if capacityVol > 0
            zoneCumulativeVolume += volume
            zoneHealthPct := f_clamp(100.0 - zoneCumulativeVolume / capacityVol * 100.0, 0.0, 100.0)
        if zoneSide == 1 and high > zoneTop and high[1] <= zoneTop
            zoneTestedCount += 1
            lastBearTestCount := zoneTestedCount
            lastBearHealth := zoneHealthPct
        if zoneSide == -1 and low < zoneBottom and low[1] >= zoneBottom
            zoneTestedCount += 1
            lastBullTestCount := zoneTestedCount
            lastBullHealth := zoneHealthPct

if zoneActiveRaw and bar_index - zoneStartBar > zoneHoldBars
    zoneTop := na
    zoneBottom := na
    zoneLevel := na
    zoneSide := 0
    zoneState := 0
    zoneStartBar := na
    zoneConfirmBar := na
    zoneCumulativeVolume := 0.0
    zoneTestedCount := 0
    zoneHealthPct := 100.0
    zoneIsMitigated := false

//============================================================================
// Display Logic
//============================================================================
showBearStrong = strongBearTrap
showBullStrong = strongBullTrap
showBearValid = not showStrongOnly and showValidSignals and validBearTrap
showBullValid = not showStrongOnly and showValidSignals and validBullTrap
showBearWeak = not showStrongOnly and showWeakSignals and weakBearTrap
showBullWeak = not showStrongOnly and showWeakSignals and weakBullTrap

showBearSweep = showSweepSignals and bearSweepSignal and not (suppressSweepWhenTrap and (strongBearTrap or validBearTrap or weakBearTrap))
showBullSweep = showSweepSignals and bullSweepSignal and not (suppressSweepWhenTrap and (strongBullTrap or validBullTrap or weakBullTrap))

zoneActive = zoneActiveRaw and zoneState != 0

zoneBaseColor =
     zoneState == 1 ? sweepColor :
     zoneState == 2 ? bearTrapColor :
     zoneState == 3 ? bullTrapColor :
     zoneState == 4 ? expiredColor :
     expiredColor

zoneTopPlot = zoneActive ? zoneTop : na
zoneBottomPlot = zoneActive ? zoneBottom : na
zoneLevelPlot = zoneActive ? zoneLevel : na

zoneLineColor = zoneActive ? zoneBaseColor : color.new(expiredColor, 100)
zoneFillColor = zoneActive ? color.new(zoneBaseColor, zoneFillTransparency) : color.new(expiredColor, 100)

pZoneTop = plot(zoneTopPlot, title="Sweep Wick Zone Top", color=color.new(zoneLineColor, 35), linewidth=1, style=plot.style_linebr)
pZoneBottom = plot(zoneBottomPlot, title="Sweep Wick Zone Bottom", color=color.new(zoneLineColor, 35), linewidth=1, style=plot.style_linebr)
pZoneLevel = plot(zoneLevelPlot, title="Liquidity Sweep Level", color=zoneLineColor, linewidth=zoneLineWidth, style=plot.style_linebr)
fill(pZoneTop, pZoneBottom, color=zoneFillColor, title="Liquidity Sweep Wick Zone")

f_pct_text(_pct) =>
    showConfidencePct ? " " + str.tostring(math.round(_pct)) + "%" : ""

f_test_text(_count) =>
    showTestedCount and _count >= 2 ? " " + str.tostring(_count) + "x" : ""

f_health_text(_health) =>
    showZoneHealth ? " H" + str.tostring(math.round(_health)) : ""

bearStrongLabel = "TRAP↓+" + f_pct_text(lastSignalScore) + f_test_text(lastSignalTests) + f_health_text(lastSignalHealth)
bearValidLabel = "TRAP↓" + f_pct_text(lastSignalScore) + f_test_text(lastSignalTests) + f_health_text(lastSignalHealth)
bullStrongLabel = "TRAP↑+" + f_pct_text(lastSignalScore) + f_test_text(lastSignalTests) + f_health_text(lastSignalHealth)
bullValidLabel = "TRAP↑" + f_pct_text(lastSignalScore) + f_test_text(lastSignalTests) + f_health_text(lastSignalHealth)

plotshape(showBearSweep, title="Bearish Liquidity Sweep", style=shape.triangledown, location=location.abovebar, color=color.new(sweepColor, 0), size=size.tiny, text="SWEEP", textcolor=textColor)
plotshape(showBullSweep, title="Bullish Liquidity Sweep", style=shape.triangleup, location=location.belowbar, color=color.new(sweepColor, 0), size=size.tiny, text="SWEEP", textcolor=textColor)

if showSignalTags and showBearStrong
    label.new(bar_index, high, bearStrongLabel, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearTrapColor, 0), textcolor=textColor, size=size.small)

if showSignalTags and showBullStrong
    label.new(bar_index, low, bullStrongLabel, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullTrapColor, 0), textcolor=textColor, size=size.small)

if showSignalTags and showBearValid
    label.new(bar_index, high, bearValidLabel, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearTrapValidColor, 0), textcolor=textColor, size=size.small)

if showSignalTags and showBullValid
    label.new(bar_index, low, bullValidLabel, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullTrapValidColor, 0), textcolor=textColor, size=size.small)

plotshape(showBearWeak, title="Weak Bearish Sweep Trap", style=shape.triangledown, location=location.abovebar, color=color.new(weakColor, 20), size=size.tiny, text=".", textcolor=textColor)
plotshape(showBullWeak, title="Weak Bullish Sweep Trap", style=shape.triangleup, location=location.belowbar, color=color.new(weakColor, 20), size=size.tiny, text=".", textcolor=textColor)

//============================================================================
// Alerts
//============================================================================
alertcondition(bearSweepSignal, title="Bearish Liquidity Sweep", message="Bearish liquidity sweep detected.")
alertcondition(bullSweepSignal, title="Bullish Liquidity Sweep", message="Bullish liquidity sweep detected.")
alertcondition(strongBearTrap, title="Strong Bearish Sweep Trap", message="Strong bearish sweep trap confirmation detected.")
alertcondition(strongBullTrap, title="Strong Bullish Sweep Trap", message="Strong bullish sweep trap confirmation detected.")
alertcondition(validBearTrap, title="Bearish Sweep Trap", message="Bearish sweep trap confirmation detected.")
alertcondition(validBullTrap, title="Bullish Sweep Trap", message="Bullish sweep trap confirmation detected.")
````
