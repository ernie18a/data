# Aegis VEP_CBP Hybrid [wjdtks255]

- url: https://www.tradingview.com/script/uZBvQM2E/
- type: indicator
- pine_id: PUB;d3bd4894162a453c96a21602712be311
- version: 3.0

## Description

■ OVERVIEW
The Aegis VEP_CBP Hybrid is a high-performance execution framework that synchronizes Volume Expansion Patterns (VEP) with Core Buying Pressure (CBP) to identify institutional accumulation and distribution phases. This script filters out retail noise by analyzing the net flow of capital within individual candle structures, ensuring that signals are only generated when true market delta is confirmed.

■ CORE ALGORITHMS

VEP (Volume Expansion) Engine: Scans historical price action to identify "Abnormal Volume" relative to the lookback period's maximums. A signal is only primed if the current volume exceeds the highest volume of opposing candles within the user-defined lookback.

CBP (Core Buying Pressure) Analysis: Calculates the "Net Pressure" by dissecting the candle range. It measures the delta between (Close - Low) and (High - Close), scaled by total volume, to reveal the hidden strength of market participants.

Hybrid Confirmation Logic: The system generates a GOLDEN or DEATH signal only when an abnormal volume expansion (VEP) aligns with a net pressure reading that exceeds its 20-period EMA.

■ VISUAL INTERPRETATION

GOLDEN (Yellow Triangle): Signals a high-conviction bullish expansion where buying pressure is statistically dominant.

DEATH (Purple Triangle): Signals a high-conviction bearish distribution where selling pressure has reached critical levels.

Dynamic Power Background: The background color reflects the real-time net capital flow, providing immediate bias feedback.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis VEP_CBP Hybrid [wjdtks255]", overlay=true)

// =========================================================================
// 1. Inputs Settings (설정 - 영어 (한글) 포맷 완벽 적용 및 그룹화)
// =========================================================================
group_vep  = "Aegis VEP Settings (거래량 폭발 설정)"
lenMA      = input.int(50, "Volume MA Period (거래량 이평선 주기)", minval=1, group=group_vep)
lookback   = input.int(10, "Pivot Lookback Period (피벗 탐색 기간)", minval=1, group=group_vep)

group_cbp  = "Aegis CBP Settings (실질 매집 압력 설정)"
cbpEmaLen  = input.int(20, "CBP Smoothing EMA Period (매집 압력 평활화 주기)", minval=1, group=group_cbp)

// =========================================================================
// 2. VEP (Volume Explosion Pivot) Core Engine Logic
// =========================================================================
vMA    = ta.sma(volume, lenMA)
isUp   = close > close[1]
isDown = close < close[1]

float maxD = 0.0
float maxU = 0.0

// 바 데이터가 충분히 쌓인 상태에서만 루프 연산이 안전하게 실행되도록 예외 쉴드 처리
if bar_index > lookback
    for i = 1 to lookback
        if close[i] < close[i+1]
            maxD := math.max(maxD, volume[i])
        if close[i] > close[i+1]
            maxU := math.max(maxU, volume[i])

isPPV = isUp and volume > maxD
isBPV = isDown and volume > maxU

// =========================================================================
// 3. CBP (Core Buying Pressure) Core Engine Logic
// =========================================================================
cRange = math.max(high - low, syminfo.mintick)
net_p  = volume * ((close - low) - (high - close)) / cRange
sMA    = ta.ema(net_p, cbpEmaLen)

// =========================================================================
// 4. Integrated Hybrid Matrix Signals (통합 신호 연산)
// =========================================================================
bull_signal = isPPV and net_p > sMA
bear_signal = isBPV and net_p < sMA

// =========================================================================
// 5. Visual Shading & Shape Plotting (시각화 레이아웃)
// =========================================================================
// 배경색: 현재 시장의 실질 수급 힘 (매수우위: 연초록, 매도우위: 연빨강)
bgcolor(net_p > 0 ? color.new(color.green, 97) : color.new(color.red, 97), title="Market Power Background")

// 강력 매수 (GOLDEN): 고가시성 노란색 삼각형 레이블 출력
plotshape(bull_signal, "Golden Bull Matrix", shape.triangleup, location.belowbar, color.yellow, 0, "GOLDEN", color.yellow, size=size.small)

// 강력 매도 (DEATH): 고가시성 보라색 삼각형 레이블 출력
plotshape(bear_signal, "Death Bear Matrix", shape.triangledown, location.abovebar, color.purple, 0, "DEATH", color.purple, size=size.small)

// 일반 수급 피벗 타점 (노이즈 방지용 미니 점 스타일 출력)
plotshape(isPPV and not bull_signal, "Normal Accumulation Pivot", shape.circle, location.belowbar, color.new(color.blue, 40), size=size.tiny)
plotshape(isBPV and not bear_signal, "Normal Distribution Pivot", shape.circle, location.abovebar, color.new(color.purple, 40), size=size.tiny)

// =========================================================================
// 6. Algorithmic Webhook & Real-time Execution Alerts (얼럿 엔진 탑재)
// =========================================================================
alertcondition(bull_signal, title="Aegis Hybrid GOLDEN (BUY)", message="[Aegis Hybrid] GOLDEN Institutional Buying Volume Triggered! Price: {{close}}")
alertcondition(bear_signal, title="Aegis Hybrid DEATH (SELL)", message="[Aegis Hybrid] DEATH Institutional Selling Volume Triggered! Price: {{close}}")
````
