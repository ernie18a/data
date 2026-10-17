# Aegis Royal Edge: Linear Alpha [wjdtks255]

- url: https://www.tradingview.com/script/LOsjFBnw/
- type: indicator
- pine_id: PUB;15073c9c0f8f4994b9fd9c4af20b40f6
- version: 2.0

## Description

■ OVERVIEW
The Aegis Royal Edge: Linear Alpha is a sophisticated market analysis framework that utilizes a high-precision Linear Regression Engine to identify institutional order blocks and trend transitions. This script solves the lagging issue of traditional moving averages by calculating the asset's current "equilibrium price" in real-time.

■ TECHNICAL ARCHITECTURE

Alpha Regression Engine: Employs a 144-period regression model to determine the core trend vector.

Momentum Slope Filter: Calculates the rate of change (slopeThresh) to distinguish between high-conviction trending phases and low-volume consolidation zones.

Adaptive Volatility Zones: Utilizes a 1.8x Standard Deviation multiplier to create dynamic boundaries that encapsulate 90%+ of standard price action, marking extreme deviations for potential reversal points.

■ SIGNAL METHODOLOGY

Mean-Reversion (Alpha Buy/Sell): Triggered when the price aggressively overextends beyond the volatility bands and recovers, capturing institutional-grade "buying the dip" or "selling the rip" opportunities.

Structural Trend (UP/DOWN Labels): These high-conviction signals appear only when the regression slope is statistically significant and the price breaks the median "Fair Value" line, signaling a macro trend shift.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Royal Edge Series: Linear Alpha (Customizable)
// Powered by wjdtks255
indicator("Aegis Royal Edge: Linear Alpha [wjdtks255]", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. Configuration Inputs (설정 - 영어 (한글) 포맷 완벽 적용 및 그룹화)
// =========================================================================
group_reg   = "Aegis Linear Regression Settings"
length      = input.int(144, "Linear Regression Period (선형 회귀 주기)", minval=10, group=group_reg)
bandMult    = input.float(1.8, "Volatility Band Deviation Multiplier (변동성 밴드 표준편차 승수)", minval=0.1, step=0.1, group=group_reg)
slopeThresh = input.float(0.00015, "Minimum Trend Slope Filter (최소 추세 기울기 필터)", step=0.00005, group=group_reg)

group_vis   = "Aegis Visual Layout Styles"
mainColor   = input.color(color.teal, "Center Line Equilibrium Color (중심선 밸런스 색상)", group=group_vis)
mainWidth   = input.int(2, "Center Line Width (중심선 두께)", minval=1, maxval=10, group=group_vis)
bandColor   = input.color(color.purple, "Outer Deviation Band Color (외곽 밴드 라인 색상)", group=group_vis)
bandWidth   = input.int(1, "Outer Deviation Band Width (외곽 밴드 라인 두께)", minval=1, maxval=10, group=group_vis)
fillTransp  = input.int(95, "Dynamic Shading Transparency (채널 내부 음영 투명도 [0-100])", minval=0, maxval=100, group=group_vis)

// =========================================================================
// 2. Core Technical Engine Logic (수학적 데이터 연산)
// =========================================================================
source  = close
regLine = ta.linreg(source, length, 0)
dev     = ta.stdev(source, length)
upper   = regLine + dev * bandMult
lower   = regLine - dev * bandMult

// Trend Vector Slope Calculation
slope = (regLine - regLine[1]) / regLine[1]
isTrending = math.abs(slope) > slopeThresh

// =========================================================================
// 3. Premium Signal Matrix Logic (추세 돌파 및 과매수/과매도 반전 연산)
// =========================================================================
// 역추세 타점 (Mean-Reversion)
longRev   = low[1] < lower[1] and ta.crossover(source, lower)
shortRev  = high[1] > upper[1] and ta.crossunder(source, upper)

// 순추세 타점 (Structural Trend-Following)
longTrend  = isTrending and ta.crossover(source, regLine)
shortTrend = isTrending and ta.crossunder(source, regLine)

// =========================================================================
// 4. Visual Plotting & Dynamic Shading (시각화 및 하이브리드 필링)
// =========================================================================
p_reg = plot(regLine, "Equilibrium Center Line", color=mainColor, linewidth=mainWidth)
p_up  = plot(upper, "Upper Deviation Band", color=color.new(bandColor, 50), linewidth=bandWidth)
p_lo  = plot(lower, "Lower Deviation Band", color=color.new(bandColor, 50), linewidth=bandWidth)

// Premium Background Hybrid Fills
fill(p_up, p_reg, color = source > regLine ? color.new(color.green, fillTransp) : na, title="Bullish Zone Shading")
fill(p_lo, p_reg, color = source < regLine ? color.new(color.red, fillTransp) : na, title="Bearish Zone Shading")

// =========================================================================
// 5. Signals Plotting (고가시성 쉐이프 출력)
// =========================================================================
plotshape(longRev,   title="Alpha Buy Signal",   style=shape.square, location=location.belowbar, color=color.lime,   size=size.tiny)
plotshape(shortRev,  title="Alpha Sell Signal",  style=shape.square, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(longTrend,  title="Royal Up Label",    style=shape.labelup,   location=location.belowbar, color=color.green, size=size.small, text="UP",    textcolor=color.white)
plotshape(shortTrend, title="Royal Down Label",  style=shape.labeldown, location=location.abovebar, color=color.red,   size=size.small, text="DOWN", textcolor=color.white)

// =========================================================================
// 6. Algorithmic Webhook & Real-time Execution Alerts (얼럿 엔진 탑재)
// =========================================================================
alertcondition(longRev,    title="Alpha BUY (Reversion)", message="[Royal Edge] Alpha BUY Signal Triggered! Counter-Trend Long Entry. Price: {{close}}")
alertcondition(shortRev,   title="Alpha SELL (Reversion)", message="[Royal Edge] Alpha SELL Signal Triggered! Counter-Trend Short Entry. Price: {{close}}")
alertcondition(longTrend,  title="Royal UP (Trend Follow)", message="[Royal Edge] Royal UP Trend Confirmed! Center Line Breakout. Price: {{close}}")
alertcondition(shortTrend, title="Royal DOWN (Trend Follow)", message="[Royal Edge] Royal DOWN Trend Confirmed! Center Line Breakdown. Price: {{close}}")
````
