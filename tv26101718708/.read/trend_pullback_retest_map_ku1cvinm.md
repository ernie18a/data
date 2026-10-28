# Trend Pullback Retest Map

- url: https://www.tradingview.com/script/kU1cVinM-Trend-Pullback-Retest-Map/
- type: indicator
- pine_id: PUB;0a2765560d224a80b106f56306b21ce0
- version: 1.0

## Description

Trend Pullback Retest Map

Trend Pullback Retest Map is a chart study designed to identify trend-based pullback setups, retest confirmations, failed continuation structures, and possible extension zones within an active market trend.

The script evaluates trend direction, pullback depth, structure bias, volatility range, and retest behavior. It then displays SET, RT, FAIL, and EXT markers to help users review whether price is preparing for continuation, confirming a retest, failing the setup, or becoming extended after a strong directional move.

It does not provide buy or sell recommendations. The purpose of this script is to help users study trend continuation structure, pullback quality, retest behavior, invalidation areas, and late-move extension risk.

────────────────────
Core Concept
────────────────────

Trend continuation analysis is often used to study whether price is likely to resume its previous direction after a controlled pullback.

A healthy pullback generally appears when price retraces within an existing trend without fully breaking the underlying structure.

A retest confirmation generally appears when price attempts to recover after the pullback and re-engage the trend direction.

A failed setup appears when price loses the expected continuation structure before confirmation.

An extension zone appears when price has already moved strongly in one direction and may carry higher late-entry risk.

This script focuses on four trend-continuation concepts:

• Trend-based pullback setup detection
• Retest confirmation after a pullback
• Setup invalidation and failure recognition
• Extension and exhaustion awareness after strong movement

When price pulls back into a valid trend structure, the chart may show a SET marker.

When price recovers from that area and confirms continuation behavior, the chart may show an RT marker.

When the expected structure breaks down, the chart may show a FAIL marker.

When price becomes stretched after a strong move, the chart may show an EXT marker.

────────────────────
What This Script Shows
────────────────────

The script can display:

• SET markers for potential pullback setup areas
• RT markers for retest confirmation
• FAIL markers for invalidated continuation setups
• EXT markers for possible extension or exhaustion zones
• Retest trigger reference lines
• Invalidation reference lines
• Completed setup reference lines
• Optional weak pullback markers

These elements are intended to make trend pullback, retest, failure, and extension behavior easier to review on the chart.

────────────────────
How It Works
────────────────────

1. The script evaluates trend direction using fast, trend, and slow EMA structure.
2. ATR is used to normalize pullback depth, trend progress, candle range, and extension distance.
3. A slow regime filter helps reduce signals against the broader trend environment.
4. A structure bias filter checks whether price is positioned on the correct side of the trend structure.
5. Recent impulse logic helps avoid weak sideways conditions with insufficient directional movement.
6. The script checks whether price has pulled back into a controlled area near the trend structure.
7. A pullback setup can be marked as SET when trend, depth, structure, volume, and candle quality conditions are met.
8. After SET, the script monitors whether price breaks the retest trigger or confirms momentum recovery.
9. If retest confirmation appears, the script marks RT.
10. If price breaks the invalidation area or loses the required trend structure, the script marks FAIL.
11. If price moves too far from the trend structure or shows exhaustion behavior, the script marks EXT.
12. Optional realtime behavior can be controlled so users can review signals with confirmed-bar logic.

────────────────────
Visual Elements
────────────────────

The script includes:

• SET marker
• RT marker
• FAIL marker
• EXT marker
• Optional WK marker
• Retest Trigger Line
• Invalidation Line
• Completed setup line state
• Color-coded event markers

SET is used as a preparation marker.

RT is used as a stronger continuation confirmation marker.

FAIL is used as a structure failure marker.

EXT is used as an extension or late-move caution marker.

The retest trigger line and invalidation line help users review the reference range that the script used while evaluating the setup.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• Trend EMA length
• Fast EMA length
• Slow regime EMA length
• ATR length
• Pullback lookback bars
• Minimum trend slope
• Minimum fast / trend EMA gap
• Minimum trend progress
• Minimum trend age
• Structure lookback
• Slow regime filter
• Directional impulse requirements
• Pullback depth range
• Trend hold buffer
• Fast EMA touch buffer
• SET quality score
• Volume quality filter
• Setup range filter
• Chop range filter
• Retest confirmation window
• Direct RT behavior
• EXT reset requirements
• Structure break requirements for RT
• Failure and invalidation settings
• Extension and exhaustion thresholds
• Signal visibility
• Line visibility
• Marker colors and text colors

The default settings are designed to reduce weak sideways signals and focus more on trend continuation structures where price pulls back, recovers, or fails around a defined reference area.

────────────────────
Reference Markers
────────────────────

The script includes several event markers.

SET:
Shows when price forms a potential pullback setup within a valid trend structure.

RT:
Shows when price confirms a retest or momentum recovery after a setup.

FAIL:
Shows when the setup loses its expected continuation structure or breaks the invalidation area.

EXT:
Shows when price appears extended after a strong directional movement and may require caution.

WK:
Optional weak pullback marker that can be enabled to observe deeper or weaker pullback behavior.

Retest Trigger Line:
Shows the reference area that price needs to recover or break through for continuation confirmation.

Invalidation Line:
Shows the reference area where the setup structure is considered weakened or failed.

These markers are not trading signals. They are visual reference points for studying pullback quality, retest confirmation, failed continuation, and extension risk.

────────────────────
How To Use
────────────────────

Use this script as a trend pullback and retest structure viewer.

General interpretation examples:

• SET can be used to review where a pullback setup begins to form.
• RT can be used to review where price confirms recovery after a pullback.
• FAIL can be used to review where the expected continuation structure breaks.
• EXT can be used to review where price may be stretched after a strong move.
• Retest trigger lines can help users understand the confirmation area.
• Invalidation lines can help users understand where the setup loses quality.
• The script should be reviewed together with price action, support and resistance, volume, volatility, and higher-timeframe trend context.

This script should be used with independent analysis, risk management, and a defined trading plan.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script calculates conditions using the available chart data.

Trend context, pullback depth, retest confirmation, failure conditions, and extension conditions can change while the current candle is still forming.

If users want more conservative signal interpretation, events should be evaluated after candle close.

The script does not use future price data to predict upcoming price movement.

Some signals may appear after a structure is already partially formed because confirmation conditions require price behavior to develop first.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

SET and RT markers are not guaranteed continuation signals.

FAIL markers may appear after part of the move has already occurred because failure confirmation requires price to break or weaken the expected structure.

EXT markers do not guarantee reversal. They only indicate that price may be extended relative to the selected trend and volatility conditions.

In choppy, low-liquidity, news-driven, or highly volatile markets, the script may produce weaker or delayed signals.

The script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Trend Pullback Retest Map

Trend Pullback Retest Map은 활성화된 시장 추세 안에서 추세 기반 눌림목 셋업, 리테스트 확인, 추세 지속 실패 구조, 과열 확장 구간을 식별하기 위한 차트 분석 보조지표입니다.

이 스크립트는 추세 방향, 눌림 깊이, 구조 편향, 변동성 범위, 리테스트 행동을 평가합니다. 이후 SET, RT, FAIL, EXT 마커를 표시해 가격이 추세 지속을 준비하는지, 리테스트를 확인하는지, 셋업이 실패하는지, 또는 강한 방향성 이동 이후 과도하게 확장되었는지 복기할 수 있도록 돕습니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다.
목적은 추세 지속 구조, 눌림목 품질, 리테스트 행동, 무효화 영역, 늦은 진입 위험이 있는 확장 구간을 관찰하는 것입니다.

────────────────────
핵심 개념
────────────────────

추세 지속 분석은 가격이 일정한 눌림 이후 기존 방향으로 다시 이어질 수 있는지를 관찰하는 데 자주 사용됩니다.

건강한 눌림은 일반적으로 기존 추세 구조를 완전히 깨지 않으면서 가격이 일정 부분 되돌림을 보일 때 나타납니다.

리테스트 확인은 눌림 이후 가격이 다시 회복하면서 기존 추세 방향으로 재진입하려는 행동을 보일 때 나타납니다.

실패한 셋업은 확인이 나오기 전에 가격이 기대했던 추세 지속 구조를 잃을 때 나타납니다.

확장 구간은 가격이 이미 한 방향으로 강하게 움직인 뒤 늦은 진입 위험이 커질 수 있는 구간을 의미합니다.

이 스크립트는 네 가지 추세 지속 개념에 초점을 둡니다.

• 추세 기반 눌림목 셋업 감지
• 눌림 이후 리테스트 확인
• 셋업 무효화 및 실패 인식
• 강한 움직임 이후 확장 및 과열 인식

가격이 유효한 추세 구조 안으로 눌리면 차트에 SET 마커가 표시될 수 있습니다.

가격이 해당 구간에서 회복하고 추세 지속 행동을 확인하면 RT 마커가 표시될 수 있습니다.

기대했던 구조가 무너지면 FAIL 마커가 표시될 수 있습니다.

가격이 강한 움직임 이후 과도하게 확장되면 EXT 마커가 표시될 수 있습니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 잠재적 눌림목 셋업 구간을 나타내는 SET 마커
• 리테스트 확인을 나타내는 RT 마커
• 무효화된 추세 지속 셋업을 나타내는 FAIL 마커
• 과열 또는 확장 가능성을 나타내는 EXT 마커
• 리테스트 트리거 기준선
• 무효화 기준선
• 완료된 셋업 기준선
• 선택 가능한 약한 눌림 마커

이 요소들은 차트 위에서 추세 눌림, 리테스트, 실패, 확장 행동을 더 쉽게 복기하기 위한 시각적 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 빠른 EMA, 추세 EMA, 장기 EMA 구조를 사용해 추세 방향을 평가합니다.
2. ATR을 사용해 눌림 깊이, 추세 진행도, 캔들 범위, 확장 거리를 정규화합니다.
3. 장기 레짐 필터를 통해 더 넓은 추세 환경과 반대되는 신호를 줄입니다.
4. 구조 편향 필터를 통해 가격이 추세 구조의 적절한 방향에 위치해 있는지 확인합니다.
5. 최근 임펄스 로직을 통해 방향성이 부족한 약한 횡보 구간을 줄입니다.
6. 가격이 추세 구조 근처의 통제된 영역으로 눌렸는지 확인합니다.
7. 추세, 눌림 깊이, 구조, 거래량, 캔들 품질 조건이 충족되면 SET으로 표시될 수 있습니다.
8. SET 이후 가격이 리테스트 트리거를 돌파하거나 모멘텀 회복을 확인하는지 관찰합니다.
9. 리테스트 확인이 나타나면 RT를 표시합니다.
10. 가격이 무효화 영역을 깨거나 필요한 추세 구조를 잃으면 FAIL을 표시합니다.
11. 가격이 추세 구조에서 지나치게 멀어지거나 과열 행동을 보이면 EXT를 표시합니다.
12. 선택 가능한 실시간 동작 설정을 통해 확정봉 기준으로 신호를 검토할 수 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• SET 마커
• RT 마커
• FAIL 마커
• EXT 마커
• 선택 가능한 WK 마커
• Retest Trigger Line
• Invalidation Line
• 완료된 셋업 라인 상태
• 색상으로 구분된 이벤트 마커

SET은 준비 구간 마커로 사용됩니다.

RT는 더 강한 추세 지속 확인 마커로 사용됩니다.

FAIL은 구조 실패 마커로 사용됩니다.

EXT는 확장 또는 늦은 진입 주의 마커로 사용됩니다.

리테스트 트리거 라인과 무효화 라인은 스크립트가 셋업을 평가할 때 사용한 기준 범위를 복기하는 데 도움을 줍니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• Trend EMA Length
• Fast EMA Length
• Slow Regime EMA Length
• ATR Length
• Pullback Lookback Bars
• 최소 추세 기울기
• 최소 Fast / Trend EMA 간격
• 최소 추세 진행도
• 최소 추세 유지 시간
• 구조 기준 lookback
• 장기 레짐 필터
• 방향성 임펄스 조건
• 눌림 깊이 범위
• 추세 유지 버퍼
• Fast EMA 터치 버퍼
• SET 품질 점수
• 거래량 품질 필터
• 셋업 범위 필터
• 횡보 범위 필터
• 리테스트 확인 구간
• Direct RT 동작
• EXT 이후 reset 조건
• RT 구조 돌파 조건
• 실패 및 무효화 설정
• 확장 및 과열 기준
• 신호 표시 여부
• 라인 표시 여부
• 마커 색상 및 텍스트 색상

기본 설정은 약한 횡보 신호를 줄이고, 가격이 눌림 이후 회복하거나 실패하는 추세 지속 구조에 더 집중하도록 구성되어 있습니다.

────────────────────
참고 마커
────────────────────

이 스크립트에는 여러 이벤트 마커가 포함되어 있습니다.

SET:
가격이 유효한 추세 구조 안에서 잠재적 눌림목 셋업을 형성할 때 표시됩니다.

RT:
가격이 셋업 이후 리테스트 또는 모멘텀 회복을 확인할 때 표시됩니다.

FAIL:
셋업이 기대했던 추세 지속 구조를 잃거나 무효화 영역을 이탈할 때 표시됩니다.

EXT:
가격이 강한 방향성 이동 이후 확장되어 주의가 필요할 수 있을 때 표시됩니다.

WK:
더 깊거나 약한 눌림 행동을 관찰하기 위해 선택적으로 활성화할 수 있는 약한 눌림 마커입니다.

Retest Trigger Line:
가격이 추세 지속 확인을 위해 회복하거나 돌파해야 하는 기준 영역을 표시합니다.

Invalidation Line:
셋업 구조가 약화되거나 실패했다고 볼 수 있는 기준 영역을 표시합니다.

이 마커들은 매매 신호가 아닙니다.
눌림 품질, 리테스트 확인, 추세 지속 실패, 확장 위험을 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 추세 눌림과 리테스트 구조 확인용 보조지표로 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• SET은 눌림목 셋업이 형성되기 시작한 위치를 복기하는 데 사용할 수 있습니다.
• RT는 눌림 이후 가격이 회복을 확인한 위치를 복기하는 데 사용할 수 있습니다.
• FAIL은 기대했던 추세 지속 구조가 무너진 위치를 복기하는 데 사용할 수 있습니다.
• EXT는 강한 움직임 이후 가격이 과도하게 확장되었을 수 있는 구간을 복기하는 데 사용할 수 있습니다.
• 리테스트 트리거 라인은 확인 기준 영역을 이해하는 데 도움을 줄 수 있습니다.
• 무효화 라인은 셋업 품질이 사라지는 구간을 이해하는 데 도움을 줄 수 있습니다.
• 이 스크립트는 가격 행동, 지지와 저항, 거래량, 변동성, 상위 시간대 추세 컨텍스트와 함께 검토해야 합니다.

이 스크립트는 독립적인 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 차트에서 사용 가능한 데이터를 기준으로 조건을 계산합니다.

현재 캔들이 형성되는 동안에는 추세 컨텍스트, 눌림 깊이, 리테스트 확인, 실패 조건, 확장 조건이 달라질 수 있습니다.

보다 보수적인 신호 해석을 원하는 사용자는 봉 마감 이후 이벤트를 확인해야 합니다.

이 스크립트는 향후 가격 움직임을 예측하기 위해 미래 가격 데이터를 사용하지 않습니다.

일부 신호는 확인 조건이 가격 행동의 진행을 필요로 하기 때문에 구조가 일부 형성된 뒤 표시될 수 있습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

SET과 RT 마커는 추세 지속을 보장하지 않습니다.

FAIL 마커는 실패 확인을 위해 가격이 구조를 깨거나 약화되는 과정이 필요하므로 움직임이 일부 진행된 뒤 표시될 수 있습니다.

EXT 마커는 반전을 보장하지 않습니다. 선택한 추세 및 변동성 조건 대비 가격이 확장되었을 가능성을 나타낼 뿐입니다.

횡보가 심한 시장, 저유동성 시장, 뉴스성 급등락, 급변동 구간에서는 신호가 약해지거나 늦게 표시될 수 있습니다.

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
indicator("Trend Pullback Retest Map", shorttitle="PBRTMap", overlay=true, max_bars_back=5000)

//========================
// Inputs
//========================
groupCore = "① Core"
trendLen = input.int(50, "Trend EMA Length", minval=5, maxval=300, group=groupCore)
fastLen = input.int(20, "Fast EMA Length", minval=3, maxval=200, group=groupCore)
slowLen = input.int(100, "Slow Regime EMA Length", minval=20, maxval=500, group=groupCore)
atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=groupCore)
lookbackBars = input.int(30, "Pullback Lookback Bars", minval=5, maxval=200, group=groupCore)

groupTrend = "② Trend Context"
minTrendSlopeATR = input.float(0.08, "Minimum Trend Slope ATR", minval=0.0, maxval=1.0, step=0.01, group=groupTrend)
minTrendGapATR = input.float(0.20, "Minimum Fast / Trend Gap ATR", minval=0.0, maxval=3.0, step=0.02, group=groupTrend)
minTrendProgressATR = input.float(0.95, "Minimum Trend Progress ATR", minval=0.0, maxval=10.0, step=0.05, group=groupTrend)
progressLookback = input.int(20, "Trend Progress Lookback", minval=5, maxval=100, group=groupTrend)
minTrendAgeBars = input.int(10, "Minimum Trend Age Bars", minval=0, maxval=100, group=groupTrend)

groupBias = "③ Structure Bias"
useStructureBias = input.bool(true, "Use Structure Bias", group=groupBias)
structureLookback = input.int(12, "Structure Lookback", minval=3, maxval=100, group=groupBias)
minCloseTrendGapATR = input.float(0.14, "Minimum Close / Trend EMA Gap ATR", minval=0.0, maxval=5.0, step=0.02, group=groupBias)
useSlowRegimeFilter = input.bool(true, "Use Slow Regime Filter", group=groupBias)
slowRegimeBufferATR = input.float(0.08, "Slow Regime Buffer ATR", minval=0.0, maxval=3.0, step=0.02, group=groupBias)
requireRecentImpulse = input.bool(true, "Require Recent Directional Impulse", group=groupBias)
impulseLookback = input.int(10, "Impulse Lookback", minval=3, maxval=100, group=groupBias)
minImpulseATR = input.float(1.05, "Minimum Impulse ATR", minval=0.0, maxval=10.0, step=0.05, group=groupBias)
blockOppositeTrendBody = input.bool(true, "Block Opposite Large Body", group=groupBias)
oppositeBodyATR = input.float(0.75, "Opposite Body ATR", minval=0.0, maxval=5.0, step=0.05, group=groupBias)

groupPullback = "④ Pullback Setup"
minPullbackATR = input.float(0.48, "Minimum Pullback Depth ATR", minval=0.05, maxval=5.0, step=0.05, group=groupPullback)
maxPullbackATR = input.float(2.75, "Maximum Healthy Pullback ATR", minval=0.20, maxval=10.0, step=0.10, group=groupPullback)
deepPullbackATR = input.float(3.20, "Deep Pullback ATR", minval=0.50, maxval=15.0, step=0.10, group=groupPullback)
holdBufferATR = input.float(0.36, "Trend Hold Buffer ATR", minval=0.0, maxval=3.0, step=0.05, group=groupPullback)
fastTouchBufferATR = input.float(0.50, "Fast EMA Touch Buffer ATR", minval=0.0, maxval=3.0, step=0.05, group=groupPullback)
setupClosePct = input.float(57.0, "SET Close Position %", minval=1.0, maxval=100.0, step=1.0, group=groupPullback)
failClosePct = input.float(42.0, "FAIL Close Position %", minval=1.0, maxval=100.0, step=1.0, group=groupPullback)
minSETScore = input.float(68.0, "Minimum SET Score", minval=0.0, maxval=100.0, step=1.0, group=groupPullback)

groupVolume = "⑤ Volume"
volumeLen = input.int(20, "Volume MA Length", minval=1, maxval=200, group=groupVolume)
useVolumeQuality = input.bool(true, "Use Volume Quality", group=groupVolume)
pullbackVolMax = input.float(1.22, "Pullback Max Volume xMA", minval=0.10, maxval=5.0, step=0.05, group=groupVolume)
retestVolMin = input.float(0.60, "Retest Min Volume xMA", minval=0.10, maxval=5.0, step=0.05, group=groupVolume)

groupGate = "⑥ Setup Gate"
useSetupGate = input.bool(true, "Use Setup Gate", group=groupGate)
setupRangeLookback = input.int(18, "Setup Range Lookback", minval=5, maxval=100, group=groupGate)
minSetupRangeATR = input.float(1.55, "Minimum Setup Range ATR", minval=0.0, maxval=10.0, step=0.05, group=groupGate)
maxSetupCandleRangeATR = input.float(2.40, "Max Setup Candle Range ATR", minval=0.5, maxval=10.0, step=0.10, group=groupGate)
requireFastEmaSlope = input.bool(true, "Require Fast EMA Slope", group=groupGate)
blockInsideChop = input.bool(true, "Block Narrow Chop Setup", group=groupGate)
chopRangeLookback = input.int(32, "Chop Range Lookback", minval=5, maxval=100, group=groupGate)
minChopRangeATR = input.float(2.35, "Minimum Non-Chop Range ATR", minval=0.10, maxval=10.0, step=0.05, group=groupGate)

groupRetest = "⑦ Retest Confirmation"
minBarsAfterSET = input.int(1, "Retest Min Bars After SET", minval=1, maxval=20, group=groupRetest)
cycleTimeoutBars = input.int(24, "Setup Timeout Bars", minval=3, maxval=200, group=groupRetest)
triggerBreakATR = input.float(0.02, "Trigger Break ATR", minval=0.0, maxval=2.0, step=0.01, group=groupRetest)
previousBarBreakATR = input.float(0.01, "Previous Bar Break ATR", minval=0.0, maxval=2.0, step=0.01, group=groupRetest)
retestClosePct = input.float(55.0, "RT Close Position %", minval=1.0, maxval=100.0, step=1.0, group=groupRetest)
minRTScore = input.float(48.0, "Minimum RT Score", minval=0.0, maxval=100.0, step=1.0, group=groupRetest)
allowMomentumRT = input.bool(true, "Allow Momentum RT", group=groupRetest)
allowTriggerRT = input.bool(true, "Allow Trigger Line RT", group=groupRetest)
allowDirectRT = input.bool(true, "Allow Direct RT Without SET", group=groupRetest)
directRTLookback = input.int(7, "Direct RT Pullback Lookback", minval=2, maxval=20, group=groupRetest)
directRTCooldownBars = input.int(10, "Direct RT Cooldown Bars", minval=0, maxval=100, group=groupRetest)
blockDirectRTAfterEXTBars = input.int(18, "Block Direct RT After EXT Bars", minval=0, maxval=100, group=groupRetest)
blockCycleRTAfterEXTBars = input.int(10, "Block Cycle RT After EXT Bars", minval=0, maxval=100, group=groupRetest)
requireEXTResetForRT = input.bool(true, "Require Pullback Reset After EXT", group=groupRetest)
maxRTGapAfterEXTATR = input.float(1.65, "Max Price / Trend Gap For RT After EXT", minval=0.5, maxval=20.0, step=0.10, group=groupRetest)
resetAfterEXTDepthMult = input.float(1.55, "Reset After EXT Pullback Depth Mult", minval=0.5, maxval=5.0, step=0.05, group=groupRetest)
resetAfterEXTNeedTrendTouch = input.bool(true, "Reset After EXT Needs Trend EMA Area", group=groupRetest)
requireRTStructureBreak = input.bool(true, "Require RT Structure Break", group=groupRetest)
rtStructureLookback = input.int(4, "RT Structure Break Lookback", minval=2, maxval=20, group=groupRetest)

groupFail = "⑧ Fail / Invalidation"
useEarlyFail = input.bool(true, "Use Early Fail", group=groupFail)
earlyFailBodyATR = input.float(0.16, "Early Fail Body ATR", minval=0.0, maxval=5.0, step=0.01, group=groupFail)
earlyFailVolumeRatio = input.float(0.95, "Early Fail Volume xMA", minval=0.0, maxval=10.0, step=0.05, group=groupFail)
invalidBufferATR = input.float(0.05, "Invalidation Break Buffer ATR", minval=0.0, maxval=2.0, step=0.01, group=groupFail)

groupExhaustion = "⑨ Extension / Exhaustion"
showSoftExtension = input.bool(true, "Show Soft EXT Warning", group=groupExhaustion)
useHardExhaustionBlock = input.bool(true, "Use Hard Exhaustion Block", group=groupExhaustion)
extensionLookback = input.int(30, "Extension Lookback Bars", minval=5, maxval=200, group=groupExhaustion)
maxTrendProgressATR = input.float(7.80, "Soft Max Trend Progress ATR", minval=1.0, maxval=30.0, step=0.25, group=groupExhaustion)
maxPriceTrendGapATR = input.float(4.35, "Soft Max Price / Trend EMA Gap ATR", minval=0.5, maxval=20.0, step=0.10, group=groupExhaustion)
hardTrendProgressATR = input.float(9.80, "Hard Max Trend Progress ATR", minval=1.0, maxval=40.0, step=0.25, group=groupExhaustion)
hardPriceTrendGapATR = input.float(5.75, "Hard Max Price / Trend EMA Gap ATR", minval=0.5, maxval=30.0, step=0.10, group=groupExhaustion)
wickExhaustionPct = input.float(50.0, "Wick Exhaustion %", minval=5.0, maxval=95.0, step=1.0, group=groupExhaustion)
exhaustionVolumeRatio = input.float(1.55, "Exhaustion Volume xMA", minval=0.10, maxval=10.0, step=0.05, group=groupExhaustion)
postHardExtensionBlockBars = input.int(14, "Block New SET After Hard EXT Bars", minval=0, maxval=100, group=groupExhaustion)

groupSignals = "⑩ Signals"
showSET = input.bool(true, "Show SET", group=groupSignals)
showRT = input.bool(true, "Show RT", group=groupSignals)
showFAIL = input.bool(true, "Show FAIL", group=groupSignals)
showWK = input.bool(false, "Show WK", group=groupSignals)
showEXT = input.bool(true, "Show EXT", group=groupSignals)
cooldownBars = input.int(22, "Signal Cooldown Bars", minval=0, maxval=200, group=groupSignals)
extCooldownBars = input.int(18, "EXT Cooldown Bars", minval=0, maxval=200, group=groupSignals)

groupLineUI = "⑪ Line UI"
showRetestLines = input.bool(true, "Show Trigger / Invalidation Lines", group=groupLineUI)
keepCompletedLines = input.bool(true, "Keep Completed Lines", group=groupLineUI)
completedHoldBars = input.int(80, "Completed Line Hold Bars", minval=5, maxval=500, group=groupLineUI)
showEventMarkers = input.bool(true, "Show Event Markers", group=groupLineUI)
lineWidth = input.int(2, "Plot Line Width", minval=1, maxval=4, group=groupLineUI)

groupStyle = "⑫ Style"
triggerActiveColor = input.color(color.rgb(120, 170, 255), "Active Trigger Line Color", group=groupStyle)
invalidActiveColor = input.color(color.rgb(230, 80, 100), "Active Invalidation Line Color", group=groupStyle)
rtColor = input.color(color.rgb(0, 200, 140), "RT Color", group=groupStyle)
failColor = input.color(color.rgb(230, 80, 100), "FAIL Color", group=groupStyle)
weakColor = input.color(color.rgb(255, 185, 80), "WK Color", group=groupStyle)
extensionColor = input.color(color.rgb(255, 150, 0), "EXT Color", group=groupStyle)
expiredColor = input.color(color.rgb(120, 120, 120), "Expired Line Color", group=groupStyle)
textColor = input.color(color.white, "Text Color", group=groupStyle)

//========================
// Core Series
//========================
emaTrend = ta.ema(close, trendLen)
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr = ta.atr(atrLen)
atrSafe = math.max(nz(atr), syminfo.mintick)

volMA = ta.sma(volume, volumeLen)
volBase = math.max(nz(volMA, volume), 1.0)
volRatio = volume / volBase

candleRange = math.max(high - low, syminfo.mintick)
candleBody = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

closePosPct = (close - low) / candleRange * 100.0
closePosBearPct = (high - close) / candleRange * 100.0
upperWickPct = upperWick / candleRange * 100.0
lowerWickPct = lowerWick / candleRange * 100.0

emaTrendPrev = nz(emaTrend[5], emaTrend)
trendSlope = math.abs(emaTrend - emaTrendPrev) / atrSafe
trendGap = math.abs(emaFast - emaTrend) / atrSafe

slowSlopeUp = emaSlow > nz(emaSlow[3], emaSlow)
slowSlopeDown = emaSlow < nz(emaSlow[3], emaSlow)

longSlowRegime = not useSlowRegimeFilter or (emaTrend >= emaSlow - atrSafe * slowRegimeBufferATR and close >= emaSlow - atrSafe * slowRegimeBufferATR and slowSlopeUp)
shortSlowRegime = not useSlowRegimeFilter or (emaTrend <= emaSlow + atrSafe * slowRegimeBufferATR and close <= emaSlow + atrSafe * slowRegimeBufferATR and slowSlopeDown)

lowestProgress = ta.lowest(low, progressLookback)
highestProgress = ta.highest(high, progressLookback)

trendProgressUp = (close - nz(lowestProgress, low)) / atrSafe
trendProgressDown = (nz(highestProgress, high) - close) / atrSafe

trendUp = emaFast > emaTrend and emaTrend > nz(emaTrend[1], emaTrend) and trendSlope >= minTrendSlopeATR and trendGap >= minTrendGapATR and trendProgressUp >= minTrendProgressATR and longSlowRegime
trendDown = emaFast < emaTrend and emaTrend < nz(emaTrend[1], emaTrend) and trendSlope >= minTrendSlopeATR and trendGap >= minTrendGapATR and trendProgressDown >= minTrendProgressATR and shortSlowRegime

trendUpAge = ta.barssince(not trendUp)
trendDownAge = ta.barssince(not trendDown)

highestRecent = ta.highest(high, lookbackBars)
lowestRecent = ta.lowest(low, lookbackBars)

pullbackDepthLong = trendUp ? (nz(highestRecent, high) - low) / atrSafe : 0.0
pullbackDepthShort = trendDown ? (high - nz(lowestRecent, low)) / atrSafe : 0.0

priorStructureHigh = ta.highest(high[1], structureLookback)
priorStructureLow = ta.lowest(low[1], structureLookback)

recentRangeImpulse = (ta.highest(high, impulseLookback) - ta.lowest(low, impulseLookback)) / atrSafe
recentLongImpulse = close > close[impulseLookback] and recentRangeImpulse >= minImpulseATR
recentShortImpulse = close < close[impulseLookback] and recentRangeImpulse >= minImpulseATR

largeBearBody = close < open and candleBody / atrSafe >= oppositeBodyATR
largeBullBody = close > open and candleBody / atrSafe >= oppositeBodyATR

longSetupBias = not useStructureBias or (longSlowRegime and close > emaTrend + atrSafe * minCloseTrendGapATR and (not requireRecentImpulse or recentLongImpulse) and (not blockOppositeTrendBody or not largeBearBody))
shortSetupBias = not useStructureBias or (shortSlowRegime and close < emaTrend - atrSafe * minCloseTrendGapATR and (not requireRecentImpulse or recentShortImpulse) and (not blockOppositeTrendBody or not largeBullBody))

longRTBias = not useStructureBias or (longSlowRegime and close > emaTrend + atrSafe * minCloseTrendGapATR and close > nz(priorStructureHigh, high) - atrSafe * 0.30 and (not blockOppositeTrendBody or not largeBearBody))
shortRTBias = not useStructureBias or (shortSlowRegime and close < emaTrend - atrSafe * minCloseTrendGapATR and close < nz(priorStructureLow, low) + atrSafe * 0.30 and (not blockOppositeTrendBody or not largeBullBody))

//========================
// Extension / Exhaustion
//========================
priorHighForExtension = ta.highest(high[1], extensionLookback)
priorLowForExtension = ta.lowest(low[1], extensionLookback)

longSoftProgress = trendProgressUp > maxTrendProgressATR
shortSoftProgress = trendProgressDown > maxTrendProgressATR

longSoftGap = (close - emaTrend) / atrSafe > maxPriceTrendGapATR
shortSoftGap = (emaTrend - close) / atrSafe > maxPriceTrendGapATR

longHardProgress = trendProgressUp > hardTrendProgressATR
shortHardProgress = trendProgressDown > hardTrendProgressATR

longHardGap = (close - emaTrend) / atrSafe > hardPriceTrendGapATR
shortHardGap = (emaTrend - close) / atrSafe > hardPriceTrendGapATR

longExhaustionCandle = trendUp and high >= nz(priorHighForExtension, high) and upperWickPct >= wickExhaustionPct and volRatio >= exhaustionVolumeRatio and close < open
shortExhaustionCandle = trendDown and low <= nz(priorLowForExtension, low) and lowerWickPct >= wickExhaustionPct and volRatio >= exhaustionVolumeRatio and close > open

longStallCandle = trendUp and (close < open or closePosPct < 45.0 or upperWickPct >= wickExhaustionPct)
shortStallCandle = trendDown and (close > open or closePosBearPct < 45.0 or lowerWickPct >= wickExhaustionPct)

longSoftEXTContext = trendUp and showSoftExtension and ((longSoftProgress or longSoftGap) and longStallCandle or longExhaustionCandle)
shortSoftEXTContext = trendDown and showSoftExtension and ((shortSoftProgress or shortSoftGap) and shortStallCandle or shortExhaustionCandle)

longHardEXTContext = trendUp and useHardExhaustionBlock and ((longHardProgress and longHardGap and longStallCandle) or longExhaustionCandle)
shortHardEXTContext = trendDown and useHardExhaustionBlock and ((shortHardProgress and shortHardGap and shortStallCandle) or shortExhaustionCandle)

var int lastEXTBar = na
var int lastHardEXTBar = na
var int lastEXTDir = 0

barsSinceEXT = na(lastEXTBar) ? na : bar_index - lastEXTBar
barsSinceHardEXT = na(lastHardEXTBar) ? na : bar_index - lastHardEXTBar

postSoftDirectRTBlocked = blockDirectRTAfterEXTBars > 0 and not na(barsSinceEXT) and barsSinceEXT <= blockDirectRTAfterEXTBars
postSoftCycleRTBlocked = blockCycleRTAfterEXTBars > 0 and not na(barsSinceEXT) and barsSinceEXT <= blockCycleRTAfterEXTBars
postHardEXTBlocked = useHardExhaustionBlock and postHardExtensionBlockBars > 0 and not na(barsSinceHardEXT) and barsSinceHardEXT <= postHardExtensionBlockBars

priceTrendGapLong = (close - emaTrend) / atrSafe
priceTrendGapShort = (emaTrend - close) / atrSafe

//========================
// Setup Gate
//========================
recentSetupRange = ta.highest(high, setupRangeLookback) - ta.lowest(low, setupRangeLookback)
recentSetupRangeATR = recentSetupRange / atrSafe

chopRange = ta.highest(high, chopRangeLookback) - ta.lowest(low, chopRangeLookback)
chopRangeATR = chopRange / atrSafe
chopBlocked = blockInsideChop and chopRangeATR < minChopRangeATR

setupCandleRangeATR = candleRange / atrSafe

fastSlopeBull = emaFast > emaFast[1]
fastSlopeBear = emaFast < emaFast[1]

trendAgeLongOk = minTrendAgeBars == 0 or (not na(trendUpAge) and trendUpAge >= minTrendAgeBars)
trendAgeShortOk = minTrendAgeBars == 0 or (not na(trendDownAge) and trendDownAge >= minTrendAgeBars)

setupRangeOk = recentSetupRangeATR >= minSetupRangeATR
setupCandleOk = setupCandleRangeATR <= maxSetupCandleRangeATR
fastSlopeLongOk = not requireFastEmaSlope or fastSlopeBull
fastSlopeShortOk = not requireFastEmaSlope or fastSlopeBear

longSetupGateOK = not useSetupGate or (trendAgeLongOk and setupRangeOk and setupCandleOk and fastSlopeLongOk and not chopBlocked and not postHardEXTBlocked and longSetupBias)
shortSetupGateOK = not useSetupGate or (trendAgeShortOk and setupRangeOk and setupCandleOk and fastSlopeShortOk and not chopBlocked and not postHardEXTBlocked and shortSetupBias)

//========================
// Pullback Logic
//========================
longTrendHold = trendUp and low >= emaTrend - atrSafe * holdBufferATR and close >= emaTrend
shortTrendHold = trendDown and high <= emaTrend + atrSafe * holdBufferATR and close <= emaTrend

longPulledIntoFast = trendUp and low <= emaFast + atrSafe * fastTouchBufferATR and low >= emaTrend - atrSafe * holdBufferATR
shortPulledIntoFast = trendDown and high >= emaFast - atrSafe * fastTouchBufferATR and high <= emaTrend + atrSafe * holdBufferATR

longTrendTouchAfterEXT = trendUp and low <= emaTrend + atrSafe * holdBufferATR and close >= emaTrend
shortTrendTouchAfterEXT = trendDown and high >= emaTrend - atrSafe * holdBufferATR and close <= emaTrend

recentLongPulledBars = ta.barssince(longPulledIntoFast)
recentShortPulledBars = ta.barssince(shortPulledIntoFast)

recentLongTrendTouchBars = ta.barssince(longTrendTouchAfterEXT)
recentShortTrendTouchBars = ta.barssince(shortTrendTouchAfterEXT)

recentLongPulledIntoFast = not na(recentLongPulledBars) and recentLongPulledBars <= directRTLookback
recentShortPulledIntoFast = not na(recentShortPulledBars) and recentShortPulledBars <= directRTLookback

longResetAfterEXTCore = not na(barsSinceEXT) and recentLongPulledBars < barsSinceEXT and pullbackDepthLong >= minPullbackATR * resetAfterEXTDepthMult and priceTrendGapLong <= maxRTGapAfterEXTATR
shortResetAfterEXTCore = not na(barsSinceEXT) and recentShortPulledBars < barsSinceEXT and pullbackDepthShort >= minPullbackATR * resetAfterEXTDepthMult and priceTrendGapShort <= maxRTGapAfterEXTATR

longResetAfterEXTTouchOK = not resetAfterEXTNeedTrendTouch or not na(recentLongTrendTouchBars) and recentLongTrendTouchBars < barsSinceEXT
shortResetAfterEXTTouchOK = not resetAfterEXTNeedTrendTouch or not na(recentShortTrendTouchBars) and recentShortTrendTouchBars < barsSinceEXT

longResetAfterEXT = not requireEXTResetForRT or na(barsSinceEXT) or lastEXTDir != 1 or longResetAfterEXTCore and longResetAfterEXTTouchOK
shortResetAfterEXT = not requireEXTResetForRT or na(barsSinceEXT) or lastEXTDir != -1 or shortResetAfterEXTCore and shortResetAfterEXTTouchOK

longDepthOk = trendUp and pullbackDepthLong >= minPullbackATR and pullbackDepthLong <= maxPullbackATR
shortDepthOk = trendDown and pullbackDepthShort >= minPullbackATR and pullbackDepthShort <= maxPullbackATR

longVolumeHealthy = not useVolumeQuality or volRatio <= pullbackVolMax
shortVolumeHealthy = not useVolumeQuality or volRatio <= pullbackVolMax

longReclaimCandle = close > open and close > emaFast and close >= close[1] and closePosPct >= setupClosePct
shortReclaimCandle = close < open and close < emaFast and close <= close[1] and closePosBearPct >= setupClosePct

longRTStructureOK = not requireRTStructureBreak or close > ta.highest(high[1], rtStructureLookback)
shortRTStructureOK = not requireRTStructureBreak or close < ta.lowest(low[1], rtStructureLookback)

//========================
// Score Helpers
//========================
f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_scoreSET(_trendSlope, _trendGap, _depth, _closePos, _volRatio, _rangeATR) =>
    float slopeScore = f_clamp(_trendSlope / math.max(minTrendSlopeATR * 2.0, 0.01) * 18.0, 0.0, 18.0)
    float gapScore = f_clamp(_trendGap / math.max(minTrendGapATR * 2.0, 0.01) * 16.0, 0.0, 16.0)
    float depthMid = (minPullbackATR + maxPullbackATR) / 2.0
    float depthRange = math.max(maxPullbackATR - minPullbackATR, 0.01)
    float depthScore = f_clamp(22.0 - math.abs(_depth - depthMid) / depthRange * 22.0, 0.0, 22.0)
    float closeScore = f_clamp(_closePos / 100.0 * 20.0, 0.0, 20.0)
    float volScore = useVolumeQuality ? f_clamp((pullbackVolMax - _volRatio + 0.45) / 0.85 * 14.0, 0.0, 14.0) : 14.0
    float rangeScore = f_clamp(_rangeATR / math.max(minSetupRangeATR * 1.6, 0.01) * 10.0, 0.0, 10.0)
    f_clamp(slopeScore + gapScore + depthScore + closeScore + volScore + rangeScore, 0.0, 100.0)

f_scoreRT(_trendSlope, _trendGap, _closePos, _volRatio, _breakDistance) =>
    float slopeScore = f_clamp(_trendSlope / math.max(minTrendSlopeATR * 2.0, 0.01) * 16.0, 0.0, 16.0)
    float gapScore = f_clamp(_trendGap / math.max(minTrendGapATR * 2.0, 0.01) * 14.0, 0.0, 14.0)
    float closeScore = f_clamp(_closePos / 100.0 * 24.0, 0.0, 24.0)
    float volScore = useVolumeQuality ? f_clamp(_volRatio / math.max(retestVolMin * 1.5, 0.01) * 18.0, 0.0, 18.0) : 18.0
    float breakScore = f_clamp(_breakDistance / math.max(triggerBreakATR + 0.15, 0.01) * 28.0, 0.0, 28.0)
    f_clamp(slopeScore + gapScore + closeScore + volScore + breakScore, 0.0, 100.0)

setScoreLong = f_scoreSET(trendSlope, trendGap, pullbackDepthLong, closePosPct, volRatio, recentSetupRangeATR)
setScoreShort = f_scoreSET(trendSlope, trendGap, pullbackDepthShort, closePosBearPct, volRatio, recentSetupRangeATR)

//========================
// Setup State
//========================
var bool longCycleActive = false
var bool shortCycleActive = false
var int longCycleStartBar = na
var int shortCycleStartBar = na
var float longSetupHigh = na
var float longSetupLow = na
var float shortSetupHigh = na
var float shortSetupLow = na

var int lastSETBar = na
var int lastRTBar = na
var int lastFAILBar = na
var int lastWKBar = na

var float activeTriggerLine = na
var float activeInvalidLine = na
var int lineDirection = 0
var int lineState = 0
var int completedBar = na

canSET = na(lastSETBar) or bar_index - lastSETBar > cooldownBars
canRT = na(lastRTBar) or bar_index - lastRTBar > cooldownBars
canFAIL = na(lastFAILBar) or bar_index - lastFAILBar > cooldownBars
canWK = na(lastWKBar) or bar_index - lastWKBar > cooldownBars
canEXT = na(lastEXTBar) or bar_index - lastEXTBar > extCooldownBars

longSETRaw = trendUp and longTrendHold and longPulledIntoFast and longDepthOk and longReclaimCandle and longVolumeHealthy and longSetupGateOK and setScoreLong >= minSETScore and not longHardEXTContext
shortSETRaw = trendDown and shortTrendHold and shortPulledIntoFast and shortDepthOk and shortReclaimCandle and shortVolumeHealthy and shortSetupGateOK and setScoreShort >= minSETScore and not shortHardEXTContext

longSETOnce = longSETRaw and not longCycleActive and canSET
shortSETOnce = shortSETRaw and not shortCycleActive and canSET

longSET = showSET and longSETOnce
shortSET = showSET and shortSETOnce

if longSETOnce
    longCycleActive := true
    shortCycleActive := false
    longCycleStartBar := bar_index
    longSetupHigh := high
    longSetupLow := low
    lastSETBar := bar_index
    activeTriggerLine := high
    activeInvalidLine := low
    lineDirection := 1
    lineState := 1
    completedBar := na

if shortSETOnce
    shortCycleActive := true
    longCycleActive := false
    shortCycleStartBar := bar_index
    shortSetupHigh := high
    shortSetupLow := low
    lastSETBar := bar_index
    activeTriggerLine := low
    activeInvalidLine := high
    lineDirection := -1
    lineState := 1
    completedBar := na

//========================
// Retest / Fail Logic
//========================
longCycleBars = longCycleActive and not na(longCycleStartBar) ? bar_index - longCycleStartBar : 0
shortCycleBars = shortCycleActive and not na(shortCycleStartBar) ? bar_index - shortCycleStartBar : 0

longReady = longCycleActive and longCycleBars >= minBarsAfterSET
shortReady = shortCycleActive and shortCycleBars >= minBarsAfterSET

longTimedOut = longCycleActive and longCycleBars > cycleTimeoutBars
shortTimedOut = shortCycleActive and shortCycleBars > cycleTimeoutBars

longBreakDistance = not na(activeTriggerLine) ? (close - activeTriggerLine) / atrSafe : 0.0
shortBreakDistance = not na(activeTriggerLine) ? (activeTriggerLine - close) / atrSafe : 0.0

rtScoreLong = f_scoreRT(trendSlope, trendGap, closePosPct, volRatio, math.max(longBreakDistance, 0.0))
rtScoreShort = f_scoreRT(trendSlope, trendGap, closePosBearPct, volRatio, math.max(shortBreakDistance, 0.0))

longTriggerBreak = allowTriggerRT and not na(activeTriggerLine) and close > activeTriggerLine + atrSafe * triggerBreakATR
shortTriggerBreak = allowTriggerRT and not na(activeTriggerLine) and close < activeTriggerLine - atrSafe * triggerBreakATR

longMomentumRetest = allowMomentumRT and close > high[1] + atrSafe * previousBarBreakATR and close > emaFast and close > open and closePosPct >= retestClosePct and longRTStructureOK and longRTBias
shortMomentumRetest = allowMomentumRT and close < low[1] - atrSafe * previousBarBreakATR and close < emaFast and close < open and closePosBearPct >= retestClosePct and shortRTStructureOK and shortRTBias

cycleRTAllowedAfterEXT = lineDirection == 1 ? (not postSoftCycleRTBlocked or longResetAfterEXT) : lineDirection == -1 ? (not postSoftCycleRTBlocked or shortResetAfterEXT) : not postSoftCycleRTBlocked

longRTConfirm = longReady and trendUp and cycleRTAllowedAfterEXT and longResetAfterEXT and (longTriggerBreak or longMomentumRetest) and (not useVolumeQuality or volRatio >= retestVolMin) and rtScoreLong >= minRTScore and not longHardEXTContext
shortRTConfirm = shortReady and trendDown and cycleRTAllowedAfterEXT and shortResetAfterEXT and (shortTriggerBreak or shortMomentumRetest) and (not useVolumeQuality or volRatio >= retestVolMin) and rtScoreShort >= minRTScore and not shortHardEXTContext

directRTAllowedAfterEXTLong = not postSoftDirectRTBlocked or longResetAfterEXT
directRTAllowedAfterEXTShort = not postSoftDirectRTBlocked or shortResetAfterEXT
directRTAllowed = na(lastRTBar) or bar_index - lastRTBar > directRTCooldownBars

directRTLongRaw = allowDirectRT and directRTAllowedAfterEXTLong and longResetAfterEXT and not longCycleActive and trendUp and recentLongPulledIntoFast and longMomentumRetest and longSetupGateOK and not longHardEXTContext
directRTShortRaw = allowDirectRT and directRTAllowedAfterEXTShort and shortResetAfterEXT and not shortCycleActive and trendDown and recentShortPulledIntoFast and shortMomentumRetest and shortSetupGateOK and not shortHardEXTContext

directRTLong = showRT and directRTLongRaw and directRTAllowed
directRTShort = showRT and directRTShortRaw and directRTAllowed

longEarlyFail = useEarlyFail and longCycleActive and close < open and candleBody >= atrSafe * earlyFailBodyATR and closePosPct <= failClosePct and (close < emaFast or close < nz(activeInvalidLine, low) - atrSafe * invalidBufferATR * 0.5) and (not useVolumeQuality or volRatio >= earlyFailVolumeRatio)
shortEarlyFail = useEarlyFail and shortCycleActive and close > open and candleBody >= atrSafe * earlyFailBodyATR and closePosBearPct <= failClosePct and (close > emaFast or close > nz(activeInvalidLine, high) + atrSafe * invalidBufferATR * 0.5) and (not useVolumeQuality or volRatio >= earlyFailVolumeRatio)

longHardFail = longCycleActive and (close < emaTrend - atrSafe * holdBufferATR or close < nz(activeInvalidLine, low) - atrSafe * invalidBufferATR or pullbackDepthLong >= deepPullbackATR)
shortHardFail = shortCycleActive and (close > emaTrend + atrSafe * holdBufferATR or close > nz(activeInvalidLine, high) + atrSafe * invalidBufferATR or pullbackDepthShort >= deepPullbackATR)

longFailConfirm = longEarlyFail or longHardFail
shortFailConfirm = shortEarlyFail or shortHardFail

longRT = showRT and ((longRTConfirm and canRT) or directRTLong)
shortRT = showRT and ((shortRTConfirm and canRT) or directRTShort)

longFAIL = showFAIL and longFailConfirm and canFAIL
shortFAIL = showFAIL and shortFailConfirm and canFAIL

if longRT or shortRT
    lineState := 2
    completedBar := bar_index
    lastRTBar := bar_index

if longFAIL or shortFAIL
    lineState := 3
    completedBar := bar_index
    lastFAILBar := bar_index

if longTimedOut or shortTimedOut or (longCycleActive and not trendUp) or (shortCycleActive and not trendDown)
    lineState := 4
    completedBar := bar_index

if longRT or longFAIL or longTimedOut or not trendUp
    longCycleActive := false
    longCycleStartBar := na
    longSetupHigh := na
    longSetupLow := na

if shortRT or shortFAIL or shortTimedOut or not trendDown
    shortCycleActive := false
    shortCycleStartBar := na
    shortSetupHigh := na
    shortSetupLow := na

if not keepCompletedLines and lineState != 1
    activeTriggerLine := na
    activeInvalidLine := na
    lineState := 0
    lineDirection := 0
    completedBar := na

if keepCompletedLines and lineState != 1 and not na(completedBar) and bar_index - completedBar > completedHoldBars
    activeTriggerLine := na
    activeInvalidLine := na
    lineState := 0
    lineDirection := 0
    completedBar := na

//========================
// Weak / Extension Markers
//========================
longWK = showWK and trendUp and pullbackDepthLong >= deepPullbackATR and close < emaFast and canWK
shortWK = showWK and trendDown and pullbackDepthShort >= deepPullbackATR and close > emaFast and canWK

if longWK or shortWK
    lastWKBar := bar_index

longEXT = showEXT and longSoftEXTContext and canEXT
shortEXT = showEXT and shortSoftEXTContext and canEXT

if longEXT
    lastEXTBar := bar_index
    lastEXTDir := 1

if shortEXT
    lastEXTBar := bar_index
    lastEXTDir := -1

if longHardEXTContext or shortHardEXTContext
    lastHardEXTBar := bar_index

//========================
// Lines
//========================
triggerPlot = showRetestLines ? activeTriggerLine : na
invalidPlot = showRetestLines ? activeInvalidLine : na

triggerColor = lineState == 1 ? triggerActiveColor : lineState == 2 ? rtColor : lineState == 3 ? color.new(expiredColor, 45) : lineState == 4 ? color.new(expiredColor, 55) : na
invalidColor = lineState == 1 ? color.new(invalidActiveColor, 15) : lineState == 2 ? color.new(expiredColor, 45) : lineState == 3 ? failColor : lineState == 4 ? color.new(expiredColor, 55) : na

plot(triggerPlot, title="Retest Trigger Line", color=triggerColor, linewidth=lineWidth, style=plot.style_linebr)
plot(invalidPlot, title="Invalidation Line", color=invalidColor, linewidth=lineWidth, style=plot.style_linebr)

//========================
// Markers
//========================
plotshape(showEventMarkers and longSET, title="SET Long", style=shape.circle, location=location.belowbar, color=color.new(rtColor, 0), text="SET", textcolor=textColor, size=size.tiny)
plotshape(showEventMarkers and shortSET, title="SET Short", style=shape.circle, location=location.abovebar, color=color.new(rtColor, 0), text="SET", textcolor=textColor, size=size.tiny)

plotshape(showEventMarkers and longRT, title="RT Long", style=shape.arrowup, location=location.belowbar, color=color.new(rtColor, 0), text="RT", textcolor=textColor, size=size.tiny)
plotshape(showEventMarkers and shortRT, title="RT Short", style=shape.arrowdown, location=location.abovebar, color=color.new(rtColor, 0), text="RT", textcolor=textColor, size=size.tiny)

plotshape(showEventMarkers and longFAIL, title="FAIL Long", style=shape.arrowdown, location=location.abovebar, color=color.new(failColor, 0), text="FAIL", textcolor=textColor, size=size.tiny)
plotshape(showEventMarkers and shortFAIL, title="FAIL Short", style=shape.arrowup, location=location.belowbar, color=color.new(failColor, 0), text="FAIL", textcolor=textColor, size=size.tiny)

plotshape(showEventMarkers and longWK, title="WK Long", style=shape.diamond, location=location.abovebar, color=color.new(weakColor, 0), text="WK", textcolor=textColor, size=size.tiny)
plotshape(showEventMarkers and shortWK, title="WK Short", style=shape.diamond, location=location.belowbar, color=color.new(weakColor, 0), text="WK", textcolor=textColor, size=size.tiny)

plotshape(showEventMarkers and longEXT, title="EXT Long", style=shape.triangledown, location=location.abovebar, color=color.new(extensionColor, 0), text="EXT", textcolor=textColor, size=size.tiny)
plotshape(showEventMarkers and shortEXT, title="EXT Short", style=shape.triangleup, location=location.belowbar, color=color.new(extensionColor, 0), text="EXT", textcolor=textColor, size=size.tiny)

//========================
// Alerts
//========================
alertcondition(longSET, title="SET Long", message="Long pullback setup detected.")
alertcondition(shortSET, title="SET Short", message="Short pullback setup detected.")
alertcondition(longRT, title="RT Long", message="Long retest confirmation detected.")
alertcondition(shortRT, title="RT Short", message="Short retest confirmation detected.")
alertcondition(longFAIL, title="FAIL Long", message="Long setup invalidation detected.")
alertcondition(shortFAIL, title="FAIL Short", message="Short setup invalidation detected.")
alertcondition(longWK, title="WK Long", message="Weak long pullback condition detected.")
alertcondition(shortWK, title="WK Short", message="Weak short pullback condition detected.")
alertcondition(longEXT, title="EXT Long", message="Possible upward extension or exhaustion context detected.")
alertcondition(shortEXT, title="EXT Short", message="Possible downward extension or exhaustion context detected.")
````
