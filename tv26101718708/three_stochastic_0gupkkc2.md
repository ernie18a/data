# three Stochastic

- url: https://www.tradingview.com/script/0GuPKkC2/
- type: indicator
- pine_id: PUB;f7be52aa2d224df5ac05b19fcedec3df
- version: 1.0

## Description

Triple Stochastic Waves
단기 · 중기 · 장기 스토캐스틱 3개를 한 화면에서 동시에 확인하는 멀티타임프레임 모멘텀 지표

Overview
This indicator overlays three Stochastic oscillators — fast (5/3/3), medium (14/3/3), and slow (21/3/3) — on a single pane. By visualizing all three waves simultaneously, traders can instantly identify momentum alignment across short, mid, and long-term cycles without switching timeframes.
세 개의 스토캐스틱(5/3/3, 14/3/3, 21/3/3)을 하나의 패널에 겹쳐서 표시합니다. 단기·중기·장기 모멘텀의 흐름을 타임프레임 전환 없이 한눈에 비교할 수 있어, 추세 전환 시점과 과매수/과매도 구간을 보다 정밀하게 포착할 수 있습니다.

Settings / 설정값

Wave 1 (단기) — 5 / 3 / 3
Wave 2 (중기) — 14 / 3 / 3
Wave 3 (장기) — 21 / 3 / 3


How to use / 사용 방법
① Triple alignment (3파 정렬)
When all three waves are simultaneously below 20 or above 80, the signal has the highest reliability.
세 파동이 동시에 20 이하(과매도) 또는 80 이상(과매수) 구간에 진입하면 신뢰도 높은 진입 시점으로 판단합니다.
② Wave sequence (파동 순서 확인)
A reversal is more likely when Wave 1 (fast) turns first, followed by Wave 2, then Wave 3.
단기(5) → 중기(14) → 장기(21) 순서로 방향이 전환될 때 추세 전환 가능성이 높습니다.
③ Divergence (다이버전스 포착)
Compare price action against the slow wave (21/3/3) to spot hidden divergences.
장기 파동(21/3/3)과 가격의 방향이 엇갈리는 다이버전스를 관찰하면 추세 약화를 미리 감지할 수 있습니다.

Notes / 유의사항

This indicator works best with additional confirmation (volume, price structure) and is not a standalone signal.
다른 지표(거래량, 캔들패턴 등)와 함께 사용하는 것을 권장하며, 단독 매매 신호로 사용하지 마세요.
Suitable for all timeframes. Recommended: 1H and above for swing trading.
모든 타임프레임에서 사용 가능하며, 스윙 트레이딩에는 1시간봉 이상을 권장합니다.


Tags: stochastic, momentum, oscillator, multi-timeframe, overbought oversold

## Source Code

````pine
//@version=5
indicator("3단 분리 스토캐스틱", shorttitle="스토캐스틱 3단분리", overlay=false)

// --------------------------------------------------
// 스토캐스틱 계산을 쉽게 해주는 사용자 정의 함수
// --------------------------------------------------
getStoch(len, k_smooth, d_smooth) =>
    k = ta.sma(ta.stoch(close, high, low, len), k_smooth)
    d = ta.sma(k, d_smooth)
    [k, d]

// --------------------------------------------------
// 1. 상단 스토캐스틱 (5, 3, 3) - 위치: 200 ~ 300
// --------------------------------------------------
[k1, d1] = getStoch(5, 3, 3)
offset1 = 200 // 위로 200만큼 끌어올림

plot(k1 + offset1, color=color.black, title="5-3-3 %K", linewidth=1)
plot(d1 + offset1, color=color.gray, title="5-3-3 %D", style=plot.style_cross, linewidth=1) // 점선 느낌을 위해 cross 스타일 적용

h1_ob = hline(80 + offset1, "5-3-3 과매수", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
h1_os = hline(20 + offset1, "5-3-3 과매도", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
fill(h1_ob, h1_os, color=color.new(#8080c0, 80), title="상단 배경") // 사진과 비슷한 푸른/보라빛 옅은 배경

// --------------------------------------------------
// 2. 중단 스토캐스틱 (10, 6, 6) - 위치: 100 ~ 200
// --------------------------------------------------
[k2, d2] = getStoch(10, 6, 6)
offset2 = 100 // 위로 100만큼 끌어올림

plot(k2 + offset2, color=color.black, title="10-6-6 %K", linewidth=1)
plot(d2 + offset2, color=color.gray, title="10-6-6 %D", style=plot.style_cross, linewidth=1)

h2_ob = hline(80 + offset2, "10-6-6 과매수", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
h2_os = hline(20 + offset2, "10-6-6 과매도", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
fill(h2_ob, h2_os, color=color.new(#8080c0, 80), title="중단 배경")

// --------------------------------------------------
// 3. 하단 스토캐스틱 (20, 12, 12) - 위치: 0 ~ 100
// --------------------------------------------------
[k3, d3] = getStoch(20, 12, 12)
offset3 = 0 // 원래 위치 그대로

plot(k3 + offset3, color=color.black, title="20-12-12 %K", linewidth=1)
plot(d3 + offset3, color=color.gray, title="20-12-12 %D", style=plot.style_cross, linewidth=1)

h3_ob = hline(80 + offset3, "20-12-12 과매수", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
h3_os = hline(20 + offset3, "20-12-12 과매도", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
fill(h3_ob, h3_os, color=color.new(#8080c0, 80), title="하단 배경")

// --------------------------------------------------
// 각 층을 나누는 희미한 가이드라인 (선택사항)
// --------------------------------------------------
hline(200, color=color.new(color.gray, 80))
hline(100, color=color.new(color.gray, 80))
````
