# Aegis SMRT Hybrid Spectrum System [wjdtks255]

- url: https://www.tradingview.com/script/8Oj7ACvd/
- type: indicator
- pine_id: PUB;01e0346bd3544a27ab03f20da622ef08
- version: 2.0

## Description

🛡️ Aegis SMRT Hybrid Spectrum System

■ OVERVIEW**
The Aegis SMRT Hybrid Spectrum System is a professional-grade all-in-one trading framework designed for high-clarity market analysis. By consolidating three powerful consensus tools—SMRT Volatility Bands, Chandelier Exit, and Zero Lag LSMA (ZLSMA)—into a single, highly optimized Pine Script v6 architecture, it completely eliminates chart clutter and reduces dynamic calculation lag.

This system provides a multi-layered approach to trend identification, dynamic trailing stops, and responsive momentum tracking simultaneously.

---

■ KEY FEATURES
1. SMRT Volatility Layers: Utilizes a 3-tier standard deviation ribbon centered on a core EMA to capture overextended market conditions and volatility expansions.
2. Chandelier Trailing Exit: Tracks systemic trend direction changes and provides objective trailing stop-loss coordinates with dynamic background state coloring.
3. ZLSMA Momentum Spine: A zero-lag least squares moving average (rendered in bold yellow) that offers ultra-responsive price tracking, helping traders isolate the true trend direction without mathematical delay.

---

■ 개요 (Korean)
Aegis SMRT Hybrid Spectrum System은 차트의 시각적 명확성과 분석의 정밀도를 극대화하기 위해 설계된 올인원 트레이딩 프레임워크입니다. 검증된 세 가지 메커니즘인 SMRT 변동성 밴드, 샹들리에 출구(Chandelier Exit), 제로랙 LSMA(ZLSMA)를 단 하나의 초경량화 스크립트로 통합하여 차트의 복잡함을 없애고 연산 효율을 높였습니다.

■ 핵심 기능
1. SMRT 변동성 레이어**: 중심 EMA를 기준으로 한 3단계 표준편차 리본을 통해 시장의 과매수/과매도 구간 및 변동성 확장을 포착합니다.
2. 샹들리에 트레일링 엑싯: 추세의 구조적 전환을 추적하고, 동적인 배경색 전환을 통해 객관적인 익절/손절 기준선을 제시합니다.
3. ZLSMA 모멘텀 라인: 반응성이 극대화된 노란색 제로랙 최소제곱이동평균선이 수학적 시차(Lag) 없이 실제 가격 추세의 중심축을 잡아줍니다.

---

■ Credits & Acknowledgments
This script is a modified integration based on public open-source concepts. Respect and credits go to the original creators of SMRT Algo, Chandelier Exit (Everget), and ZLSMA.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator('Aegis SMRT Hybrid Spectrum System [wjdtks255]', shorttitle = 'Aegis SMRT+CE+ZLSMA', overlay = true)

// ==========================================
// [Group 1] SMRT Algo Settings
// ==========================================
const string smrtGroup = '1. SMRT Algo Settings (SMRT 추세 설정)'
emaLength   = input.int(20, "Center EMA Period (중심선 기간)", group=smrtGroup)
smrtSrc     = input.source(close, "Source Price (적용 가격)", group=smrtGroup)
devMult1    = input.float(1.5, "1st Band Multiplier (1차 밴드 배수)", step=0.1, group=smrtGroup)
devMult2    = input.float(2.0, "2nd Band Multiplier (2차 밴드 배수)", step=0.1, group=smrtGroup)
devMult3    = input.float(2.5, "3rd Band Multiplier (3차 밴드 배수)", step=0.1, group=smrtGroup)
cloudRed    = input.color(color.new(#ff6666, 30), "Upper Cloud Color (상단 구름색)", group=smrtGroup) 
cloudBlue   = input.color(color.new(#00ffff, 30), "Lower Cloud Color (하단 구름색)", group=smrtGroup) 

// ==========================================
// [Group 2] Chandelier Exit Settings
// ==========================================
const string ceCalcGroup = '2. Chandelier Exit - Calculation (매매 계산 설정)'
ceLength = input.int(22, title = 'ATR Period (변동성 기간)', group = ceCalcGroup)
ceMult   = input.float(3.0, step = 0.1, title = 'ATR Multiplier (ATR 배수)', group = ceCalcGroup)
useClose = input.bool(true, title = 'Use Close Price (종가 기준 사용)', group = ceCalcGroup)

const string ceVisualGroup = '2. Chandelier Exit - Visuals (시각 효과)'
showLabels     = input.bool(true, title = 'Show CE Buy/Sell Labels (매매 라벨 표시)', group = ceVisualGroup)
highlightState = input.bool(true, title = 'Highlight CE State (배경색 강조)', group = ceVisualGroup)

// ==========================================
// [Group 3] Zero Lag LSMA (ZLSMA) Settings
// ==========================================
const string zlsmaGroup = '3. Zero Lag LSMA Settings (핵심 추세선 설정)'
zlsmaLength = input.int(32, title="ZLSMA Length (추세선 기간)", group=zlsmaGroup)
zlsmaOffset = input.int(0, title="ZLSMA Offset (오프셋)", group=zlsmaGroup)
zlsmaSrc    = input.source(close, title="ZLSMA Source (추세선 적용 가격)", group=zlsmaGroup)

// ==========================================
// [Core Calculation Logic]
// ==========================================
emaLine = ta.ema(smrtSrc, emaLength)
stdDev  = ta.stdev(smrtSrc, emaLength)

up1 = emaLine + (devMult1 * stdDev)
up2 = emaLine + (devMult2 * stdDev)
up3 = emaLine + (devMult3 * stdDev)

dn1 = emaLine - (devMult1 * stdDev)
dn2 = emaLine - (devMult2 * stdDev)
dn3 = emaLine - (devMult3 * stdDev)

atr = ceMult * ta.atr(ceLength)
longStop  = (useClose ? ta.highest(close, ceLength) : ta.highest(high, ceLength)) - atr
shortStop = (useClose ? ta.lowest(close, ceLength) : ta.lowest(low, ceLength)) + atr

var int dir = 1
dir := close > nz(shortStop[1], shortStop) ? 1 : close < nz(longStop[1], longStop) ? -1 : dir

lsma  = ta.linreg(zlsmaSrc, zlsmaLength, zlsmaOffset)
lsma2 = ta.linreg(lsma, zlsmaLength, zlsmaOffset)
zlsma = lsma + (lsma - lsma2)

// ==========================================
// [Plotting]
// ==========================================
plot(emaLine, color=color.gray, linewidth=1, title="SMRT Center EMA")
p_u1 = plot(up1, color=color.new(cloudRed, 90), title="Up1")
p_u2 = plot(up2, color=color.new(cloudRed, 70), title="Up2")
p_u3 = plot(up3, color=color.new(cloudRed, 50), title="Up3")
p_d1 = plot(dn1, color=color.new(cloudBlue, 90), title="Dn1")
p_d2 = plot(dn2, color=color.new(cloudBlue, 70), title="Dn2")
p_d3 = plot(dn3, color=color.new(cloudBlue, 50), title="Dn3")

fill(p_u1, p_u2, color=color.new(cloudRed, 80))
fill(p_u2, p_u3, color=color.new(cloudRed, 70))
fill(p_d1, p_d2, color=color.new(cloudBlue, 80))
fill(p_d2, p_d3, color=color.new(cloudBlue, 70))

plot(dir == 1 ? longStop : na, color=color.green, style=plot.style_linebr, linewidth=2, title="Long Stop")
plot(dir == -1 ? shortStop : na, color=color.red, style=plot.style_linebr, linewidth=2, title="Short Stop")
plot(zlsma, color=color.yellow, linewidth=3, title="ZLSMA")

plotshape(showLabels and dir == 1 and dir[1] == -1, "Buy", shape.labelup, location.belowbar, color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(showLabels and dir == -1 and dir[1] == 1, "Sell", shape.labeldown, location.abovebar, color.red, text="SELL", textcolor=color.white, size=size.small)
bgcolor(highlightState ? (dir == 1 ? color.new(color.green, 95) : color.new(color.red, 95)) : na)
````
