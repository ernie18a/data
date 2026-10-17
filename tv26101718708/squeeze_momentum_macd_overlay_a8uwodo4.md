# Squeeze Momentum + MACD Overlay

- url: https://www.tradingview.com/script/a8UWODO4-Squeeze-Momentum-MACD-Overlay/
- type: indicator
- pine_id: PUB;57d2bda3c0964c0091cb54000b827f69
- version: 1.0

## Description

[b]Squeeze Momentum + MACD Overlay [Dynamic Scaling][/b]

[image]https://www.tradingview.com/x/ZzWO62za/[/image]

Description
This indicator is a powerful combination of LazyBear's famous Squeeze Momentum Indicator and the classic MACD (Moving Average Convergence Divergence).

The biggest challenge in combining these two is the difference in scales. Typically, overlaying them makes one look like a flat line. This script solves that problem using a Dynamic Scaling Engine that automatically adjusts the MACD's height to match the Squeeze Momentum's histogram, ensuring perfect visibility on any asset and timeframe.

Key Features
Volatiliy + Momentum: Monitor market compression (Squeeze) and trend direction (MACD) in a single pane.

Smart Scaling: MACD lines are automatically scaled based on relative volatility, preventing UI distortion.

Clean Visuals: MACD lines are rendered with 70% transparency to keep the focus on the Squeeze histogram while still providing clear crossover signals.

Squeeze Logic: Uses Bollinger Bands and Keltner Channels to identify periods of low volatility (Black dots) and high-momentum breakouts.

How to Use
Squeeze On (Black Dots): Market is consolidating. Prepare for a big move.

MACD Crossover: Look for MACD/Signal line crosses during or after a Squeeze for high-probability entries.

Histogram Color: Bright colors (Lime/Red) indicate strong momentum, while dark colors (Green/Maroon) suggest fading strength.


스퀴즈 모멘텀 + MACD 오버레이 [동적 스케일링 버전]

설명
이 지표는 LazyBear의 유명한 Squeeze Momentum 지표와 클래식한 MACD(이동평균 수렴 확산)를 하나로 결합한 강력한 도구입니다.

일반적으로 두 지표를 단순히 합치면 수치 단위(Scale)의 차이 때문에 한쪽 지표가 일직선으로 보이는 문제가 발생합니다. 본 스크립트는 **'동적 스케일링 엔진'**을 탑재하여, 어떤 종목이나 타임프레임에서도 MACD 선이 스퀴즈 히스토그램 크기에 맞춰 자동으로 조절되도록 설계되었습니다.

주요 특징
변동성 + 모멘텀: 시장의 압축(Squeeze)과 추세 방향(MACD)을 하나의 화면에서 동시에 모니터링할 수 있습니다.

스마트 스케일링: 상대적 변동성을 계산하여 MACD 높이를 자동 조절하므로 시각적 왜곡이 없습니다.

깔끔한 가독성: MACD 선에 70% 투명도를 적용하여, 스퀴즈 히스토그램의 색상 변화를 방해하지 않으면서도 교차 신호는 명확히 전달합니다.

스퀴즈 로직: 볼린저 밴드와 켈트너 채널을 활용해 저변동성 구간(검은 점)과 모멘텀 돌파 구간을 정확히 포착합니다.

활용 방법
스퀴즈 온 (검은 점): 시장이 에너지를 응축 중입니다. 곧 큰 변동성이 발생할 것임을 암시합니다.

MACD 골든/데드크로스: 스퀴즈 구간 전후로 발생하는 MACD 교차를 확인하여 진입 타점의 신뢰도를 높이세요.

히스토그램 색상: 밝은 색(라임/레드)은 강한 추세를, 어두운 색(그린/마룬)은 추세의 힘이 약해지고 있음을 나타냅니다.


Squeeze, Momentum, MACD, LazyBear, Overlay, Scalping

## Source Code

````pine
//@version=5
indicator(shorttitle="SQZMOM_MACD_LB", title="Squeeze Momentum + MACD Overlay", overlay=false)

// --- Squeeze Momentum 섹션 ---
length = input.int(20, title="BB Length")
mult = input.float(2.0, title="BB MultFactor")
lengthKC = input.int(20, title="KC Length")
multKC = input.float(1.5, title="KC MultFactor")
useTrueRange = input.bool(true, title="Use TrueRange (KC)")

// BB 계산
source = close
basis = ta.sma(source, length)
dev = mult * ta.stdev(source, length)
upperBB = basis + dev
lowerBB = basis - dev

// KC 계산
ma = ta.sma(source, lengthKC)
range_1 = useTrueRange ? ta.tr : (high - low)
rangema = ta.sma(range_1, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = (sqzOn == false) and (sqzOff == false)

// Squeeze 값 계산
val = ta.linreg(source - math.avg(math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)), ta.sma(close, lengthKC)), lengthKC, 0)

// --- MACD 섹션 (기본값 12, 26, 9) ---
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// --- 스케일 조정 (두 지표를 겹쳐보기 위한 처리) ---
// MACD의 범위를 Squeeze 값의 범위에 맞게 조정합니다.
// 이렇게 해야 한쪽이 너무 작게 보이는 현상을 막을 수 있습니다.
sqz_range = ta.stdev(val, 20)
macd_range = ta.stdev(macdLine, 20)
scale_factor = sqz_range / (macd_range == 0 ? 1 : macd_range)

scaled_macd = macdLine * scale_factor
scaled_signal = signalLine * scale_factor

// --- 색상 및 시각화 ---
bcolor = val > 0 ? (val > nz(val[1]) ? color.lime : color.green) : (val < nz(val[1]) ? color.red : color.maroon)
scolor = noSqz ? color.blue : sqzOn ? color.black : color.gray

// 1. Squeeze 히스토그램 (메인)
plot(val, color=bcolor, style=plot.style_histogram, linewidth=4, title="Squeeze Histogram")
plot(0, color=scolor, style=plot.style_cross, linewidth=2, title="Squeeze Dots")

// 2. MACD 선 (요청대로 흐리게 처리: 투명도 70%)
plot(scaled_macd, color=color.new(#2962FF, 70), linewidth=2, title="MACD Line")
plot(scaled_signal, color=color.new(#FF6D00, 70), linewidth=2, title="Signal Line")
````
