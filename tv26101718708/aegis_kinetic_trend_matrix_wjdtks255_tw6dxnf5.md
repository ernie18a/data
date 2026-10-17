# Aegis Kinetic Trend Matrix [wjdtks255]

- url: https://www.tradingview.com/script/tw6DXNf5/
- type: indicator
- pine_id: PUB;b5b922b63a7b45fcb73492f25fdb8102
- version: 2.0

## Description

Aegis Kinetic Trend Matrix [EMA + HalfTrend + NWE]

■ OVERVIEW
The Aegis Kinetic Trend Matrix is a professional-grade trend-following framework designed to unify macroeconomic bias filters, micro-execution entry triggers, and volatility boundaries into a single, cohesive candle-overlay system.

By integrating three robust open-source concepts—CM_EMA Trend Bars, HalfTrend, and the Nadaraya-Watson Envelope (NWE)—this system provides traders with a multi-layered filtration process to capture structural market swings with precision.

■ KEY FEATURES

CM_EMA Trend Bars: Dynamically shifts candlestick colors based on a 34-period EMA algorithm to isolate core macro direction and eliminate market noise.

HalfTrend Execution Spine: High-precision trailing anchor that tracks micro-trend pivots, offering distinct, instant BUY and SELL execution labels.

Nadaraya-Watson Envelope: Uses non-parametric kernel regression bounds to highlight overextended pricing and filter volatility exhaustion zones at major structural extremes.

■ 개요 (Korean)
Aegis Kinetic Trend Matrix는 거시적 추세 필터링, 미세 타점 포착, 그리고 변동성의 한계 구간을 단 하나의 캔들 오버레이 시스템으로 결합한 하이브리드 트레이딩 프레임워크입니다.

CM_EMA 트렌드 바, 하프트렌드(HalfTrend), 나다라야-왓슨 엔벨로프(NWE) 시스템을 유기적으로 결합하여, 거친 시장 소음을 여과하고 구조적 변곡점을 정밀하게 잡아내도록 설계되었습니다.

■ 핵심 기능

CM_EMA 트렌드 바: 34선 기준 가격 배열에 따라 캔들 색상을 직관적으로 변경하여 시장의 대추세 방향성을 명확히 정의합니다.

하프트렌드 실행 축: 단기적인 마이크로 추세 전환을 정밀하게 추적하며, 즉각적인 BUY/SELL 진입 라벨을 제공합니다.

Nadaraya-Watson 엔벨로프: 커널 회귀 분석 기반의 동적 밴드를 통해 가격의 과도한 이격을 감지하고 추세적 극한 구간의 반전 포인트를 필터링합니다.

■ Credits & Acknowledgments
This indicator is a combined integration based on public domain open-source works. Special credits and gratitude go to the original authors of CM_EMA, HalfTrend, and Nadaraya-Watson Envelope (AlexGrozav) for sharing their invaluable source code with the global community.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Kinetic Trend Matrix - Bug Fixed Version
indicator("Aegis Kinetic Trend Matrix [wjdtks255]", overlay = true)

// ==========================================
// 1. CM_EMA Trend Bars & Candle Color Logic
// ==========================================
group_ema = "1. Initial Trend (EMA Trend Bars)"
emaLen = input.int(34, "EMA Period", minval=1, group=group_ema)
showEmaLine = input.bool(false, "Show Core EMA Line", group=group_ema)

usedEma = ta.ema(close, emaLen)
emaUpTrend = hlc3 >= usedEma

barColor = emaUpTrend ? color.lime : color.red
barcolor(barColor)

plot(showEmaLine ? usedEma : na, "Base EMA Line", color=barColor, linewidth=1)

// ==========================================
// 2. HalfTrend Logic
// ==========================================
group_ht = "2. Short-Term Signal (HalfTrend)"
amplitude = input.int(2, "Amplitude", group=group_ht)
channelDeviation = input.int(2, "Channel Deviation", group=group_ht)
showHTSignals = input.bool(true, "Show HT Buy/Sell Signals", group=group_ht)

var int trend = 0
var int nextTrend = 0
var float maxLowPrice = nz(low[1], low)
var float minHighPrice = nz(high[1], high)
var float up = 0.0
var float down = 0.0

atr2 = ta.atr(100) / 2
dev = channelDeviation * atr2

highPrice = high[math.abs(ta.highestbars(amplitude))]
lowPrice = low[math.abs(ta.lowestbars(amplitude))]
highma = ta.sma(high, amplitude)
lowma = ta.sma(low, amplitude)

if nextTrend == 1
    maxLowPrice := math.max(lowPrice, maxLowPrice)
    if highma < maxLowPrice and close < nz(low[1], low)
        trend := 1
        nextTrend := 0
        minHighPrice := highPrice
else
    minHighPrice := math.min(highPrice, minHighPrice)
    if lowma > minHighPrice and close > nz(high[1], high)
        trend := 0
        nextTrend := 1
        maxLowPrice := lowPrice

float arrowUp = na
float arrowDown = na

if trend == 0
    if not na(trend[1]) and trend[1] != 0
        up := na(down[1]) ? down : down[1]
        arrowUp := up - atr2
    else
        up := na(up[1]) ? maxLowPrice : math.max(maxLowPrice, up[1])
else
    if not na(trend[1]) and trend[1] != 1
        down := na(up[1]) ? up : up[1]
        arrowDown := down + atr2
    else
        down := na(down[1]) ? minHighPrice : math.min(minHighPrice, down[1])

htLine = trend == 0 ? up : down
htColor = trend == 0 ? color.blue : color.red
plot(htLine, "HalfTrend Core Line", color=htColor, linewidth=3)

buySignal = not na(arrowUp) and trend == 0 and trend[1] == 1
sellSignal = not na(arrowDown) and trend == 1 and trend[1] == 0

plotshape(showHTSignals and buySignal ? low : na, "HT Buy Shape", style=shape.labelup, location=location.absolute, color=color.blue, text="BUY", textcolor=color.white, size=size.tiny)
plotshape(showHTSignals and sellSignal ? high : na, "HT Sell Shape", style=shape.labeldown, location=location.absolute, color=color.red, text="SELL", textcolor=color.white, size=size.tiny)

// ==========================================
// 3. Nadaraya-Watson Envelope Logic
// ==========================================
group_nwe = "3. Volatility Bound (NWE Envelope)"
h = input.float(8., 'Bandwidth', minval = 0, group=group_nwe)
mult = input.float(3., 'Multiplier', minval = 0, group=group_nwe)
repaint = input.bool(false, 'Repainting Mode (Smoothing)', group=group_nwe)
upCss = input.color(color.teal, 'Upper Band Color', group=group_nwe)
dnCss = input.color(color.red, 'Lower Band Color', group=group_nwe)
showNWEFill = input.bool(true, "Show Envelope Fill", group=group_nwe)

gauss(x, h) => math.exp(-(math.pow(x, 2)/(h * h * 2)))

// 가중치 배열 최적화 초기화
var coefs = array.new_float(0)
var float den = na
if barstate.isfirst and not repaint
    for i = 0 to 499
        coefs.push(gauss(i, h))
    den := array.sum(coefs)

out = 0.
if not repaint
    for i = 0 to 499
        out += close[i] * coefs.get(i)
    out /= den

mae = ta.sma(math.abs(close - out), 499) * mult
nwe_upper = out + mae
nwe_lower = out - mae

p_upper = plot(repaint ? na : nwe_upper, 'NWE Upper Bound', color=upCss, linewidth=1)
p_lower = plot(repaint ? na : nwe_lower, 'NWE Lower Bound', color=dnCss, linewidth=1)

fill(p_upper, p_lower, color = showNWEFill and not repaint ? color.new(color.gray, 90) : na, title="NWE Envelope Channel Fill")

// 리페인팅 모드 시 라인 드로잉 버그 수정
if barstate.islast and repaint
    float y2 = na
    float y1 = na
    nwe_array = array.new<float>(0)
    sae = 0.
    int max_bars = math.min(499, bar_index - 1)
    
    for i = 0 to max_bars
        sum = 0.
        sumw = 0.
        for j = 0 to max_bars
            w = gauss(i - j, h)
            sum += close[j] * w
            sumw += w
        y2 := sum / sumw
        sae += math.abs(close[i] - y2)
        nwe_array.push(y2)
    
    sae := sae / max_bars * mult
    
    // 첫 데이터 안전화 처리 (y1 초기화 오류 수정)
    if array.size(nwe_array) > 0
        y1 := array.get(nwe_array, 0)
        
    for i = 0 to max_bars
        if i % 2 == 0 and i > 0 // 인덱스 초과 및 na 진입 방지
            line.new(bar_index-i+1, y1 + sae, bar_index-i, array.get(nwe_array, i) + sae, color = upCss)
            line.new(bar_index-i+1, y1 - sae, bar_index-i, array.get(nwe_array, i) - sae, color = dnCss)
        y1 := array.get(nwe_array, i)

// 돌파 신호 플로팅
plotshape(ta.crossunder(close, nwe_lower) ? low : na, "NWE Lower Breakout (Buy Point)", style=shape.triangleup, location=location.belowbar, color=upCss, size=size.small)
plotshape(ta.crossover(close, nwe_upper) ? high : na, "NWE Upper Breakout (Sell Point)", style=shape.triangledown, location=location.abovebar, color=dnCss, size=size.small)

var tb = table.new(position.top_right, 1, 1, bgcolor = #1e222d, border_color = #373a46, border_width = 1)
if repaint
    tb.cell(0, 0, "Repainting Enabled", text_color = color.white, text_size = size.small)
````
