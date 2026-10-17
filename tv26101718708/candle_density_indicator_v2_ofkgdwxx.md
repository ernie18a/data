# Candle Density Indicator v2

- url: https://www.tradingview.com/script/oFKgdWxx/
- type: indicator
- pine_id: PUB;018464ac4e924bf1ac6585e2470207ee
- version: 1.0

## Description

Candle Density Indicator (EN/KR)
The Candle Density Indicator (CDI) is a dynamic support and resistance tool that mathematically extracts the most heavily congested price levels within a lookback window. Unlike volume profiles that require tick/volume data, this indicator breaks down the precise proportional overlap of candle bodies across volatility-calculated price bins.

🔑 Key Features
1. Multi-Bin Density Engine
The script dynamically segments the price action between the highest and lowest candle bodies of the lookback period into adaptive price bins (steps regulated by ATR). It calculates exactly how much of each candle's body lived inside each bin.

2. Time-at-Price Concurrency (Hits)
It scores each price bin based on candle body overlap. The bin with the highest score represents the true point of control where price compressed heavily. If the maximum score doesn't pass the minimum threshold (Min Hits), it organically hides to prevent noise.

3. Verification Stabilization (Hold Filter)
To prevent the S/R box from rapidly shifting and causing chart chaos during choppy price action, a 5-bar verification loop is built in. The dense zone will only update and lock onto a new level after it has proven structural stability, acting as an automatic debounce filter.

⚙️ Settings Guide & My Personal Setup
💡 Developer's Personal Setup: I engineered this indicator for tight intraday executions. I personally use this on the Bitcoin (BTC) 3-minute chart for high-frequency scalping. When the gray CDI Box remains flat for a long time, it defines a major value area. A sharp close outside this zone often signals an explosive expansion phase.

CDI Box Length: The lookback window (default 30 bars) to measure density. Smaller values focus on immediate scalping nodes; higher values map macro structural balance zones.

CDI Min Hits: The threshold score required to draw a zone. Keeps the chart clean by filtering out loose, volatile price action that lacks density.

============================================================

[KR] 한국어 버전 설명
📝 개요 (Description)
Candle Density Indicator (CDI)는 캔들 몸통의 중첩 밀집도를 분석하여, 특정 기간 동안 가격이 가장 치열하게 싸우며 머물렀던 '핵심 균형 가격대'를 찾아주는 고성능 알고리즘 지표입니다. 거래량 매물대(Volume Profile)와 유사하지만, 오직 가격 데이터와 변동성(ATR) 매칭을 통해 시간과 캔들 실체가 가장 많이 묶인 진짜 지지/저항 축을 계산해 냅니다.

🌟 주요 기능 (Key Features)
1. 변동성 기반 가격 밴드 분할 연산
설정한 룩백 기간(Box Length) 내의 최고점과 최저점 몸통 범위를 구한 뒤, 현재 시장의 변동성(ATR)을 기준으로 가격 구간을 촘촘한 빈(Bin)으로 자동 쪼갭니다. 이후 각 캔들의 몸통이 어느 가격대에 가장 많이 걸쳐 있었는지 수학적 비중을 계산합니다.

2. 가로축 밀집도 스코어링 (Hits)
단순히 터치한 횟수가 아니라, 캔들의 실체가 머문 시간을 누적 점수화합니다. 가장 높은 점수를 받은 가격대를 찾아내어 차트에 회색의 'CDI 밸런스 박스'로 채워줍니다. 만약 설정한 최소 밀집 점수(Min Hits)를 넘지 못하면 시장에 뚜렷한 기준 축이 없다고 판단해 신호를 숨김 처리합니다.

3. 락온(Lock-on) 안정화 필터
횡보 장세나 미세한 가격 변동 때문에 매물대 상하단 라인이 지저분하게 흔들리는 것을 막기 위해 5캔들 연속 검증 제어 장치가 내장되어 있습니다. 새로 계산된 밀집 구역이 최소 5캔들 동안 구조적 안정성을 유지할 때만 차트의 박스를 갱신하여 휩소를 방지합니다.

⚙️ 세팅 가이드 & 개발자 실전 활용법
💡 개발자 실전 팁: 저는 주로 비트코인(BTC) 3분봉 차트에서 단기 스캘핑(Scalping)을 진행할 때 이 지표를 핵심 가이드라인으로 활용합니다. 회색 박스가 길게 유지될수록 강력한 에너지가 응축되고 있음을 뜻하며, 이 박스 상단이나 하단을 캔들 실체가 강하게 이탈하며 마감할 때 매우 높은 확률로 강력한 추세 확장(돌파) 타점이 나옵니다.

CDI Box Length: 매물대 밀집도를 분석할 과거 캔들 개수(기본값 30)입니다. 단기 스캘핑 시에는 값을 낮추고, 스윙이나 매크로 작도 시에는 값을 높여 큰 추세의 매물대를 잡을 수 있습니다.

CDI Min Hits: 박스를 표시하기 위한 최소 밀집 점수 기준입니다. 이 값을 높이면 어설픈 횡보 구간의 박스는 모두 걷어내고, 정말 단단하게 뭉친 핵심 자리만 선별해 차트를 깔끔하게 유지할 수 있습니다.

## Source Code

````pine
//@version=6
indicator("Candle Density Indicator", overlay=true, max_lines_count=500)


grp_cdi = "3. CDI & LPOC Settings (Context)"
box_len = input.int(30, "CDI Box Length", group=grp_cdi)
minHits = input.int(10, "CDI Min Hits", group=grp_cdi)
atr_len = input.int(20, "atr_len")

// ==========================================
// 3. CDI ENGINE (SUP/RES calculation)
// ==========================================
// Body range
bodyLow  = math.min(open, close)
bodyHigh = math.max(open, close)

getMinMaxBody(_len) =>
    [ta.lowest(bodyLow, _len), ta.highest(bodyHigh, _len)]

var int maxBinsGuard = 400
var float[] hits = array.new_float(maxBinsGuard, 0.0)
var float ll_acc = na
var float lh_acc = na
var int hold = 0

f_calc_cdi(_len, _minHits) =>
    [minP, maxP] = getMinMaxBody(_len)
    step = ta.atr(atr_len)
    if na(step) or step == 0
        step := syminfo.mintick * 10
    
    minEdge = math.floor(minP / step) * step
    maxEdge = math.ceil(maxP / step) * step
    if maxEdge <= minEdge
        maxEdge += step

    binCount = int(math.ceil((maxEdge - minEdge) / step))
    if binCount > maxBinsGuard // Guard
        binCount := maxBinsGuard

    // Reset hits
    for i = 0 to binCount - 1
        array.set(hits, i, 0.0)

    // Accumulate
    for i = 0 to _len - 1
        if i > bar_index
            break
        lo = bodyLow[i]
        hi = bodyHigh[i]
        bodyLen = hi - lo
        if bodyLen <= 0
            continue
        
        s = int(math.floor((lo - minEdge) / step))
        e = int(math.ceil((hi - minEdge) / step)) - 1
        s := math.max(0, math.min(binCount - 1, s))
        e := math.max(0, math.min(binCount - 1, e))

        for b = s to e
            bLow  = minEdge + b * step
            bHigh = bLow + step
            ov = math.min(hi, bHigh) - math.max(lo, bLow)
            if ov > 0
                array.set(hits, b, array.get(hits, b) + ov / bodyLen)
    
    // Find Max
    maxScore = -1.0
    maxIdx = 0
    for b = 0 to binCount - 1
        v = array.get(hits, b)
        if v > maxScore
            maxScore := v
            maxIdx := b
            
    if maxScore < _minHits
        [na, na]
    else
        lEdge  = minEdge + maxIdx * step
        hEdge = lEdge + step
        [lEdge, hEdge]

// Calculate CDI
[ll_t, lh_t] = f_calc_cdi(box_len, minHits)
if not na(ll_t) and not na(lh_t)
    changed = na(ll_acc) or ll_t != ll_acc or lh_t != lh_acc
    if changed
        hold += 1
        if hold >= 5
            ll_acc := ll_t
            lh_acc := lh_t
            hold := 0
    else
        hold := 0


// ==========================================
// 6. VISUALIZATION (시각화)
// ==========================================
// CDI Boxes
pLow  = plot(ll_acc, title="CDI Low", color=color.new(color.gray, 10))
pHigh = plot(lh_acc, title="CDI High", color=color.new(color.gray, 10))
fill(pLow, pHigh, color=color.new(color.gray, 50), title="CDI Fill")
````
