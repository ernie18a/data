# Aegis Synergy Impulse MACD

- url: https://www.tradingview.com/script/LtMNz5zD/
- type: indicator
- pine_id: PUB;f9387dc5da2a4ab69bab173954dc6877
- version: 1.0

## Description

Aegis Synergy Impulse MACD [wjdtks255]

■ OVERVIEW
The Aegis Synergy Impulse MACD is an advanced momentum oscillator designed to merge traditional volume-weighted momentum tracking with an institutional impulse noise-filtering matrix. By tracking structural alignment across multiple velocity calculations, this indicator isolates high-probability trend execution points while avoiding choppy consolidation traps.

■ KEY FEATURES

Volume-Weighted MACD Engine: Replaces standard EMAs with Volume-Weighted Moving Averages (VWMA) to ensure that directional momentum is validated by real capital inflow.

Impulse Noise Filter: Utilizes an adaptive exponential envelope to strip out low-liquidity micro-fluctuations, focusing purely on macroeconomic speed changes.

Aegis Confluence Matrix: Dynamic four-color histogram system that instantly signals when traditional momentum, institutional impulse, and 200 EMA structural filters line up in perfect synergy.

■ 개요 (Korean)
Aegis Synergy Impulse MACD는 전통적인 거래량 가중 모멘텀 추적 기술과 기관급 임펄스 노이즈 필터링 매트릭스를 결합한 고성능 오실레이터 지표입니다. 복수의 연산 구조를 통해 시장의 일시적인 속임수 파동을 걸러내고 강력한 추세가 실리는 진짜 타점만을 포착합니다.

■ 핵심 기능

거래량 가중 MACD 엔진: 일반 EMA 대신 거래량 가중 이동평균(VWMA)을 선택 구조로 적용하여 진정한 자금 유입이 동반된 모멘텀 확산 상태를 여과합니다.

임펄스 노이즈 필터: 적응형 지수 채널 계산식을 통해 미세한 횡보성 소음을 제거하고, 시장의 본질적인 속도 변화에 집중합니다.

이지스 시너지 매트릭스: 전통 MACD 모멘텀, 기관 임펄스 필터, 그리고 200 EMA 장기 장벽이 완벽히 한 방향으로 정렬될 때 직관적인 형광 신호(BUY/SELL)를 출력합니다.

■ Credits & Acknowledgments
This oscillator framework is built upon public domain open-source logic. Deep appreciation goes to the TradingView developer community for providing the underlying structural concepts of volume-weighted momentum and adaptive oscillators.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Synergy Impulse MACD - Visual Enhanced & Stable Version
indicator("Aegis Synergy Impulse MACD", shorttitle="Aegis Synergy MACD", overlay=false)

// =========================================================================
// 1. 설정 (Inputs)
// =========================================================================
grp1 = "전통 모멘텀 MACD (거래량 가중)"
fastLen = input.int(12, "Fast Length", group=grp1)
slowLen = input.int(26, "Slow Length", group=grp1)
sigLen  = input.int(9,  "Signal Length", group=grp1)

grp2 = "임펄스 노이즈 필터"
impLen  = input.int(34, "Impulse MA Length", group=grp2)

grp3 = "Aegis 정확도 극대화 필터"
useTrendFilter = input.bool(true, "장기 추세 필터 (200 EMA) 적용", tooltip="역추세 매매를 방지하여 승률을 대폭 높입니다.", group=grp3)
trendLen = input.int(200, "장기 추세선 기간", group=grp3)
volFilter = input.bool(true, "거래량 가중(VWMA) 적용", tooltip="단순 가격이 아닌 거래량이 실린 진짜 움직임만 포착합니다.", group=grp3)

// =========================================================================
// 2. 핵심 로직 계산
// =========================================================================
fastMA = volFilter ? ta.vwma(close, fastLen) : ta.ema(close, fastLen)
slowMA = volFilter ? ta.vwma(close, slowLen) : ta.ema(close, slowLen)
macdLine = fastMA - slowMA
macdSig = ta.ema(macdLine, sigLen)
macdHist = macdLine - macdSig

hi = ta.highest(high, impLen)
lo = ta.lowest(low, impLen)
mi = ta.ema(close, impLen)

md = (close > mi) ? (close - hi) : (close < mi) ? (close - lo) : 0
impMACD = ta.ema(md, sigLen)
impSig = ta.sma(impMACD, sigLen)
impHist = impMACD - impSig

baseline = ta.ema(close, trendLen)
bullTrend = useTrendFilter ? (close > baseline) : true
bearTrend = useTrendFilter ? (close < baseline) : true

// =========================================================================
// 3. Aegis 시너지 (Confluence) 판별
// =========================================================================
confluenceUp = (macdHist > 0) and (impHist > 0) and (impMACD > 0)
confluenceDn = (macdHist < 0) and (impHist < 0) and (impMACD < 0)

color histColor = color.new(color.gray, 70) // 기본: 횡보 노이즈

if confluenceUp and bullTrend
    histColor := color.new(#00FF00, 20) // 완벽한 상승 타점 (형광 초록)
else if macdHist > 0
    histColor := color.new(#006400, 40) // 약한 상승/조정 (어두운 초록)
else if confluenceDn and bearTrend
    histColor := color.new(#FF0000, 20) // 완벽한 하락 타점 (형광 빨강)
else if macdHist < 0
    histColor := color.new(#8B0000, 40) // 약한 하락/조정 (어두운 빨강)

// =========================================================================
// 4. 차트 출력 및 스케일 보정 (Plotting)
// =========================================================================
// 임펄스 변화량을 nz() 함수로 안전하게 처리하여 스케일링 가시성 확보 (v6 안전 문법 적용)
impChange = ta.change(impHist)
synergyHist = macdHist + (na(impChange) ? 0.0 : impChange * 0.1)

plot(synergyHist * 2, "Synergy Histogram", style=plot.style_columns, color=histColor)

plot(macdLine, "MACD Line", color=color.new(#00BFFF, 0), linewidth=2)
plot(macdSig, "Signal Line", color=color.new(#FF8C00, 0), linewidth=1)
plot(0, "Zero Line", color=color.new(color.white, 60))

// =========================================================================
// 5. 시그널 출력 (AEGIS BUY / SELL)
// =========================================================================
longCond = ta.crossover(macdLine, macdSig) and confluenceUp and bullTrend
shortCond = ta.crossunder(macdLine, macdSig) and confluenceDn and bearTrend

plotshape(longCond, "Aegis Buy", shape.triangleup, location=location.bottom, color=color.new(#00FF00, 0), size=size.small, text="BUY", textcolor=color.white)
plotshape(shortCond, "Aegis Sell", shape.triangledown, location=location.top, color=color.new(#FF0000, 0), size=size.small, text="SELL", textcolor=color.white)
````
