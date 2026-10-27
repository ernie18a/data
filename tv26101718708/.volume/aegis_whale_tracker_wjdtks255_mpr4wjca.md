# Aegis Whale Tracker [wjdtks255]

- url: https://www.tradingview.com/script/mPR4WJca/
- type: indicator
- pine_id: PUB;2bdbfff437bb45e28fbfd8b79b99b670
- version: 2.0

## Description

Aegis Whale Tracker: Advanced Supply-Demand Engine [wjdtks255] 
■ OVERVIEW
The Aegis Whale Tracker is a high-fidelity volume analysis framework designed to detect institutional accumulation and distribution phases through Whale Momentum Detection and Supply-Demand Acceleration. Unlike standard volume bars, this engine deciphers the "intent" behind the volume by calculating the net pressure and velocity of capital flow.

■ CORE ARCHITECTURE

Whale Energy Engine (VEP Optimization): Scans a user-defined lookback period to identify volume that exceeds the maximum opposing pressure. This effectively captures "Whale" activity where institutional orders overwhelm the retail side.

Velocity Slope Analysis: A proprietary formula that measures the Acceleration (volSlope) of volume. It identifies whether a trend is gaining sustainable fuel or if it's a climactic "Blow-off" move.

Triple-Layer Pressure Filter: Utilizes an upgraded CBP (Core Buying Pressure) logic to categorize net market delta into 3 distinct stages, visualized through a precise dot system.

■ VISUAL INTERPRETATION

Blue/Purple Columns (Whale Signals): High-conviction institutional accumulation (Blue) or distribution (Purple) confirmed by the Whale Energy Engine.

Mint/Red Gradient: Represents standard price action, with brighter shades indicating high-velocity momentum.

Institutional Pressure Dots: Lower status indicators that separate "Normal" pressure from "Strong" institutional intervention.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Premium Volume Series: Whale Tracker
// Powered by wjdtks255
indicator("Aegis Whale Tracker [wjdtks255]", overlay=false)

// =========================================================================
// 1. Inputs Configuration (설정 - 영어 (한글) 포맷 완벽 적용 및 그룹화)
// =========================================================================
group_whale  = "Aegis Whale Detection Core Settings (고래 포착 핵심 설정)"
lenMA        = input.int(50, "Volume Baseline Period (평균 수급 기준선 주기)", minval=1, group=group_whale)
lookback     = input.int(10, "Whale Comparison History (고래 비교 분석 기간)", minval=1, group=group_whale)

group_accel  = "Volume Velocity & Pressure Settings (수급 가속도 및 압력 설정)"
energy_s     = input.int(10, "Velocity Slope Sensitivity (수급 가속도 감도)", minval=1, group=group_accel)
cbpEmaLen    = input.int(20, "CBP Smoothing Period (실질 압력 평활화 주기)", minval=1, group=group_accel)

// =========================================================================
// 2. Core Whale Tracker Engine & Velocity Logic (수급 가속도 및 고래 추적 연산)
// =========================================================================
volMA = ta.sma(volume, lenMA)
isUp  = close > close[1]
isDn  = close < close[1]

// 수급 가속도(기울기) 벡터 연산
volSlope = (volume - ta.sma(volume, energy_s)) / math.max(ta.sma(volume, energy_s), 1) * 100

// 고래 매집/투매 역대급 거래량 추적 매트릭스 (VEP 최적화)
float maxDownVol = 0.0
float maxUpVol   = 0.0

// 바 히스토리가 충분히 누적되었을 때만 안정적으로 루프가 돌도록 안전장치 적용
if bar_index > lookback
    for i = 1 to lookback
        if close[i] < close[i+1]
            maxDownVol := math.max(maxDownVol, volume[i])
        if close[i] > close[i+1]
            maxUpVol   := math.max(maxUpVol, volume[i])

isPPV = isUp and volume > maxDownVol // 매집 고래 포착 (Blue)
isBPV = isDn and volume > maxUpVol   // 투매 고래 포착 (Purple)

// =========================================================================
// 3. CBP Core buying Pressure Filter (실질 압력 필터 시스템 업그레이드)
// =========================================================================
cRange = math.max(high - low, syminfo.mintick)
net_p  = volume * ((close - low) - (high - close)) / cRange
p_sig  = ta.ema(net_p, cbpEmaLen)

// 압력 강도 세분화 연산 (3단계 마킹 도트 아키텍처)
isStrongBuy  = net_p > p_sig and net_p > nz(p_sig[1]) * 1.5
isStrongSell = net_p < p_sig and net_p < nz(p_sig[1]) * 1.5

// =========================================================================
// 4. Advanced Visualization & Hybrid Shading (시각화 및 하이브리드 채색)
// =========================================================================
// 가속도 벡터와 고래 신호에 따른 동적 크로마토그래피 컬러 엔진
volCol = isPPV ? #0081ff : isBPV ? #9c27b0 : 
         isUp  ? (volSlope > 20 ? #00ffcc : #26a69a) : 
         isDn  ? (volSlope > 20 ? #ff5252 : #ef5350) : #b2b5be

plot(volume, style=plot.style_columns, color=volCol, title="Whale Energy Volume Histogram")
plot(volMA, color=color.new(color.white, 60), linewidth=1, title="Volume Base Line")

// 하단 실질 압력 마커 매트릭스 (사각형: 일반 수급 / 원형: 기관급 강력 수급)
plotshape(net_p > p_sig, "Normal Cumulative Pressure", shape.square, location.bottom, color.new(color.lime, 50), size=size.tiny)
plotshape(isStrongBuy,   "Strong Institutional Inflow", shape.circle, location.bottom, color.new(color.lime, 0),  size=size.tiny)
plotshape(net_p < p_sig, "Normal Distributive Pressure", shape.square, location.bottom, color.new(color.maroon, 50), size=size.tiny)
plotshape(isStrongSell,  "Strong Institutional Outflow", shape.circle, location.bottom, color.new(color.maroon, 0),  size=size.tiny)

// 고래 신호 포착 시 하위 백그라운드 구역 스마트 하이라이트
bgcolor(isPPV ? color.new(#0081ff, 90) : isBPV ? color.new(#9c27b0, 90) : na, title="Whale Activity Overlay Zone")

// =========================================================================
// 5. Algorithmic Webhook & Real-time Execution Alerts (얼럿 엔진 탑재)
// =========================================================================
alertcondition(isPPV, title="Whale Accumulation (매집 고래)", message="[Whale Tracker] Massive Whale Accumulation Detected! (Blue Volume) Price: {{close}}")
alertcondition(isBPV, title="Whale Distribution (투매 고래)", message="[Whale Tracker] Massive Whale Distribution Detected! (Purple Volume) Price: {{close}}")
alertcondition(isStrongBuy, title="Strong Buy Pressure (강력 매집 압력)", message="[Whale Tracker] Institutional Core Buying Pressure Triggered! Price: {{close}}")
alertcondition(isStrongSell, title="Strong Sell Pressure (강력 투매 압력)", message="[Whale Tracker] Institutional Core Selling Pressure Triggered! Price: {{close}}")
````
