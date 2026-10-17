# Multi-Tilson MA[WR]

- url: https://www.tradingview.com/script/mfxvdGzQ/
- type: indicator
- pine_id: PUB;f21ec92aa86d40dea60a9a33b7dd44a7
- version: 1.0

## Description

Multi-Tilson MA with Crossover HL Gap (EN/KR)
The Multi-Horizon Tilson MA is a premium-grade trend intelligence engine designed to solve the ultimate dilemma of technical moving averages: The trade-off between lag and smoothness. 
By processing price data through a 6-stage cascading exponential moving average, it delivers unmatched smoothness with almost zero lag compared to standard EMAs. This script supercharges the original T3 logic by stacking three distinct time horizons (Short, Mid, Long) and introduces a proprietary Crossover HL Gap system to map historical liquidity pivots.

🔑 Key Features
1. 6-Stage Tilson T3 Smoothing (Volume Factor = 0.7)
Unlike lagging standard moving averages, the T3 calculation employs Tim Tillson's rigorous mathematical dampening formula. It effectively filters out volatile market noise while reacting instantly to real structural trend shifts.

2. Triple Horizon Trend Matrix (Short / Mid / Long)
Plots 3 adaptive Fast/Slow T3 assemblies simultaneously.


Set 1 (Short-Term): Designed for immediate scalping momentum and micro-reversals.

Set 2 (Mid-Term): Tracks intra-day structural trends and swing entries.

Set 3 (Long-Term): Establishes the macro institutional trend bias (The Ultimate Guide).

3. Proprietary Crossover HL Gap (Historical S/R Blocks)
The indicator dynamically locks and prints the precise price levels whenever a T3 Fast/Slow crossover or crossunder occurs. It stretches this range forward as a colored horizontal channel, visualizing exactly where structural trend-changing decisions were finalized.

⚙️ Settings Guide & My Personal Setup
💡 Developer's Personal Setup: I engineered this multi-horizon layout for professional intraday trade execution. I personally use this on the Bitcoin (BTC) 3-minute chart for high-frequency scalping. I leave Short (Set 1) and Mid (Set 2) enabled to ride micro-trends, while using the ultra-heavy 480/640 Long (Set 3) cloud as my absolute baseline for macro institutional support/resistance.


T3 Display Options: Toggle Short, Mid, or Long sets individually to keep your chart canvas clean according to your trading style.


T3 HL Gap: Toggle this to reveal the exact historical price brackets where trend crossovers happened. These gaps act as highly reliable mitigation blocks and support/resistance flips when retested.

[KR] 3중 틸슨 MA & 크로스오버 갭 시스템
📝 개요 (Description)
Multi-Horizon Tilson T3는 모든 이동평균선의 고질적인 한계인 '지연 시간(Lag)과 부드러움(Smoothness)의 모순'을 수학적으로 해결한 고성능 추세 추적 엔진입니다.

🌟 주요 기능 (Key Features)
1. 6단계 틸슨 T3 추세 필터링 (Volume Factor = 0.7 고정)
횡보 장세에서 캔들이 조금만 흔들려도 가짜 신호(휩소)를 연발하는 일반 이평선과 다릅니다. T3 알고리즘은 미세한 소음은 완벽하게 감쇠시키면서, 실제 추세가 터지는 순간에는 그 어떤 이평선보다 민첩하게 반응합니다.

2. 3중 시간 프레임 결합 (단기 / 중기 / 장기 매트릭스)
서로 다른 호흡을 가진 3쌍의 Fast/Slow T3 라인을 차트에 동시에 시각화합니다.


Set 1 (단기): 마이크로 파동의 흐름을 읽고 단기 스캘핑 진입 타점을 잡는 용도입니다.

Set 2 (중기): 당일 주도적인 스윙 추세의 기준점 및 트레일링 스탑의 기준이 됩니다.

Set 3 (장기): 시장의 거대한 기관급 대추세(Macro) 방향성을 정의하는 마스터 라인입니다.

3. 크로스오버 HL 갭 (추세 전환 매물대 블록)
Fast 라인과 Slow 라인이 골든크로스(Crossover) 혹은 데드크로스(Crossunder)를 일으키는 그 역사적인 순간의 가격 축을 지표가 기억하여 수평 밴드(HL Gap) 형태로 길게 뿌려줍니다. 추세의 성격이 바뀐 핵심 자리이기 때문에 향후 가격이 되돌아올 때 매우 강력한 지지/저항 역할을 합니다.

⚙️ 세팅 가이드 & 개발자 실전 활용법
💡 개발자 실전 팁: 저는 주로 비트코인(BTC) 3분봉 차트에서 단기 스캘핑(Scalping)을 진행할 때 이 지표를 기본 베이스로 깔아둡니다. 단기(Set 1)와 중기(Set 2) 클라우드의 색상 변화로 즉각적인 타점을 진입하고, 수치가 무거운 장기(Set 3, 480/640) 클라우드를 배수진 삼아 대추세 역추세 매매를 방지합니다.


T3 HL Gap 옵션 활성화: 평소 지지 저항 작도가 어려우신 분들은 이 옵션을 켜보세요. 이평선 교차가 일어났던 주요 매물대 구간이 차트에 자동으로 고정(Lock)되어 표시되므로, 기막힌 리테스트 반등 타점을 직관적으로 찾아낼 수 있습니다.

## Source Code

````pine
//@version=6
indicator("Tilson T3", overlay=true)

// ============================================================
// Tilson T3 moving average function
// ============================================================
_tilson(src, _len) =>
    e1 = ta.ema(src, _len)
    e2 = ta.ema(e1, _len)
    e3 = ta.ema(e2, _len)
    e4 = ta.ema(e3, _len)
    e5 = ta.ema(e4, _len)
    e6 = ta.ema(e5, _len)
    ab  = 0.7
    ab2 = ab * ab
    ab3 = ab2 * ab
    c1 = -ab3
    c2 = 3 * ab2 + 3 * ab3
    c3 = -6 * ab2 - 3 * ab - 3 * ab3
    c4 = 1 + 3 * ab + ab3 + 3 * ab2
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

// ============================================================
// T3 input settings
// ============================================================
showSet1 = input.bool(true, title="Show Set 1 (Short-Term)", group="T3 Display Options")
showSet2 = input.bool(true, title="Show Set 2 (Mid-Term)", group="T3 Display Options")
showSet3 = input.bool(true, title="Show Set 3 (Long-Term)", group="T3 Display Options")

showGap1 = input.bool(false, title="Set 1 HL Gap", group="T3 HL Gap")
showGap2 = input.bool(false, title="Set 2 HL Gap", group="T3 HL Gap")
showGap3 = input.bool(false, title="Set 3 HL Gap", group="T3 HL Gap")

len1Fast = input.int(6,   title="Fast", minval=1, group="T3 Set 1 (Short-Term)")
len1Slow = input.int(8,   title="Slow", minval=1, group="T3 Set 1 (Short-Term)")
len2Fast = input.int(30,  title="Fast", minval=1, group="T3 Set 2 (Mid-Term)")
len2Slow = input.int(40,  title="Slow", minval=1, group="T3 Set 2 (Mid-Term)")
len3Fast = input.int(480, title="Fast", minval=1, group="T3 Set 3 (Long-Term)")
len3Slow = input.int(640, title="Slow", minval=1, group="T3 Set 3 (Long-Term)")

// ============================================================
// T3 calculation
// ============================================================
ma1Fast = _tilson(close, len1Fast)
ma1Slow = _tilson(close, len1Slow)
ma2Fast = _tilson(close, len2Fast)
ma2Slow = _tilson(close, len2Slow)
ma3Fast = _tilson(close, len3Fast)
ma3Slow = _tilson(close, len3Slow)

// Track the price level at each fast/slow crossover, used to draw the HL Gap
var float h1A = na, var float h1B = na
var float h2A = na, var float h2B = na
var float h3A = na, var float h3B = na

if ta.crossover(ma1Fast, ma1Slow)
    h1A := ma1Fast
if ta.crossunder(ma1Fast, ma1Slow)
    h1B := ma1Fast
if ta.crossover(ma2Fast, ma2Slow)
    h2A := ma2Fast
if ta.crossunder(ma2Fast, ma2Slow)
    h2B := ma2Fast
if ta.crossover(ma3Fast, ma3Slow)
    h3A := ma3Fast
if ta.crossunder(ma3Fast, ma3Slow)
    h3B := ma3Fast

highest1 = math.max(h1A, h1B)
lowest1  = math.min(h1A, h1B)
highest2 = math.max(h2A, h2B)
lowest2  = math.min(h2A, h2B)
highest3 = math.max(h3A, h3B)
lowest3  = math.min(h3A, h3B)

col1 = ma1Fast > ma1Slow ? color.new(color.blue,   50) :
       ma1Fast < ma1Slow ? color.new(color.black,  70) : na
col2 = ma2Fast > ma2Slow ? color.new(color.lime,   70) :
       ma2Fast < ma2Slow ? color.new(color.purple, 70) : na
col3 = ma3Fast > ma3Slow ? color.new(#0ba800,      60) :
       ma3Fast < ma3Slow ? color.new(color.red,    60) : na

gapCol1 = color.new(color.blue,   70)
gapCol2 = color.new(color.orange, 70)
gapCol3 = color.new(color.yellow, 70)

// ============================================================
// Plot - T3
// ============================================================
p1Fast = plot(showSet1 ? ma1Fast : na, title="Set1 Fast", color=color.new(color.gray, 100))
p1Slow = plot(showSet1 ? ma1Slow : na, title="Set1 Slow", color=color.new(color.gray, 100))
fill(p1Fast, p1Slow, color=showSet1 ? col1 : na, title="Set1 Fill")

p1High = plot(showGap1 ? highest1 : na, title="Set1 High", color=color.new(color.gray, 100))
p1Low  = plot(showGap1 ? lowest1  : na, title="Set1 Low",  color=color.new(color.gray, 100))
fill(p1High, p1Low, color=showGap1 ? gapCol1 : na, title="Set1 HL Gap")

p2Fast = plot(showSet2 ? ma2Fast : na, title="Set2 Fast", color=color.new(color.gray, 100))
p2Slow = plot(showSet2 ? ma2Slow : na, title="Set2 Slow", color=color.new(color.gray, 100))
fill(p2Fast, p2Slow, color=showSet2 ? col2 : na, title="Set2 Fill")

p2High = plot(showGap2 ? highest2 : na, title="Set2 High", color=color.new(color.gray, 100))
p2Low  = plot(showGap2 ? lowest2  : na, title="Set2 Low",  color=color.new(color.gray, 100))
fill(p2High, p2Low, color=showGap2 ? gapCol2 : na, title="Set2 HL Gap")

p3Fast = plot(showSet3 ? ma3Fast : na, title="Set3 Fast", color=color.new(color.gray, 100))
p3Slow = plot(showSet3 ? ma3Slow : na, title="Set3 Slow", color=color.new(color.gray, 100))
fill(p3Fast, p3Slow, color=showSet3 ? col3 : na, title="Set3 Fill")

p3High = plot(showGap3 ? highest3 : na, title="Set3 High", color=color.new(color.gray, 100))
p3Low  = plot(showGap3 ? lowest3  : na, title="Set3 Low",  color=color.new(color.gray, 100))
fill(p3High, p3Low, color=showGap3 ? gapCol3 : na, title="Set3 HL Gap")
````
