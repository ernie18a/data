# Aegis Prime Flow [wjdtks255]

- url: https://www.tradingview.com/script/kiBLyYBm/
- type: indicator
- pine_id: PUB;f5133fff6c2e4238a5e0b8736f7b7ebf
- version: 2.0

## Description

Aegis Prime Flow [wjdtks255]: Advanced Momentum & Liquidity Engine

■ OVERVIEW 
Aegis Prime Flow is a high-precision trading oscillator engineered to visualize the hidden dynamics of market liquidity and momentum confluence. By utilizing a refined WaveTrend algorithm, it tracks the velocity of price action while the Money Flow Cloud illuminates the underlying capital bias.

■ KEY TRADING ARCHITECTURE

Kinetic Power Bars: Integrated at the top (90) and bottom (-90) levels, these bars act as a "Heat Map" for trend intensity, signaling when the market is entering a phase of extreme expansion.

Money Flow Cloud: A smoothed liquidity filter that fills the oscillator background, helping traders stay on the right side of the institutional trend.

Aegis Reversal Signals: Precision-tuned triangle alerts (Teal/Red) identify high-probability pivot points where momentum exhaustion meets a structural shift.

OB/OS Logic: Built-in Overbought (OB) and Oversold (OS) labels provide immediate visual confirmation of historical price extremes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Premium Oscillator Series: Prime Flow
// Powered by wjdtks255
indicator("Aegis Prime Flow [wjdtks255]", shorttitle="Aegis_Flow+", overlay=false, precision=2)

// =========================================================================
// 1. Inputs Configuration (설정 - 영어 (한글) 포맷 완벽 적용 및 그룹화)
// =========================================================================
group_logic = "Core Technical Logic Settings (핵심 연산 알고리즘 설정)"
len         = input.int(14, "Oscillator Calculation Period (오실레이터 연산 주기)", minval=1, group=group_logic)
smooth      = input.int(3, "Signal Smoothness Length (시그널 평활화 주기)", minval=1, group=group_logic)
src         = input(hlc3, "Source Data Price (기준 데이터 소스)", group=group_logic)

// 네온 스타일 감성 컬러 세팅
color_teal    = #00ffbb
color_red     = #ff3a2d
color_bg_teal = color.new(color_teal, 80)
color_bg_red  = color.new(color_red, 80)

// =========================================================================
// 2. Core Logic Engine: Money Flow & WaveTrend
// =========================================================================
ap  = src
esa = ta.ema(ap, len)
d   = ta.ema(math.abs(ap - esa), len)
ci  = (ap - esa) / (0.015 * d)
tci = ta.ema(ci, smooth) 
wt2 = ta.sma(tci, 4)

// 배경 수급 음영 연산용 Money Flow 데이터
mf  = ta.sma(tci, 10)

// =========================================================================
// 3. Dynamic Power Bars Logic (상하단 추세 압착 바 연산)
// =========================================================================
upper_bar     = 90
lower_bar     = -90
bar_color_top = tci > 0 ? (tci > 60 ? color_teal : color.new(color_teal, 50)) : color.new(color.gray, 80)
bar_color_bot = tci < 0 ? (tci < -60 ? color_red : color.new(color_red, 50)) : color.new(color.gray, 80)

// =========================================================================
// 4. Premium Visualization Layout (시각화 및 하이브리드 가이드라인)
// =========================================================================
// 1. 배경 Money Flow (중앙 수급 구름 효과)
p_mf = plot(mf, "Money Flow Line", color=na)
p_z  = plot(0, "Zero Base Plot", color=na)
fill(p_mf, p_z, color = mf > 0 ? color_bg_teal : color_bg_red, title="Money Flow Cloud Layer")

// 2. 오실레이터 가이드 라인 고정
hline(60, "Overbought Boundary", color=color.new(color.white, 80), linestyle=hline.style_dashed)
hline(-60, "Oversold Boundary", color=color.new(color.white, 80), linestyle=hline.style_dashed)
hline(0, "Quantum Zero Line", color=color.new(color.white, 90))

// 3. 상하단 트렌드 강도 컴프레션 파워 바 (Power Bars)
plot(upper_bar, "Upper Power Bar Track", color=bar_color_top, linewidth=4, style=plot.style_linebr)
plot(lower_bar, "Lower Power Bar Track", color=bar_color_bot, linewidth=4, style=plot.style_linebr)

// 4. 메인 오실레이터 액티브 라인
osc_color = tci > wt2 ? color_teal : color_red
plot(tci, "Main Flow Oscillator", color=osc_color, linewidth=2)

// =========================================================================
// 5. Signal Matrix & Plotshapes (수급 밴드 돌파 및 변곡 시그널)
// =========================================================================
// 과매수(OB) / 과매도(OS) 구조적 상태 포착
is_os = ta.crossunder(tci, -60)
is_ob = ta.crossover(tci, 60)

// 프리미엄 반전 타점 화살표 로직 (과매수/과매도 스퀴즈 구간 크로스오버)
buy_sig  = ta.crossover(tci, wt2) and tci < -50
sell_sig = ta.crossunder(tci, wt2) and tci > 50

// OB / OS 텍스트 레이블 가시성 정렬
plotshape(is_os, title="Oversold Alert Label", style=shape.labelup, location=location.bottom, color=color.orange, text="OS", textcolor=color.black, size=size.tiny)
plotshape(is_ob, title="Overbought Alert Label", style=shape.labeldown, location=location.top, color=color.orange, text="OB", textcolor=color.black, size=size.tiny)

// 모멘텀 핵심 반전 화살표 시각화
plotshape(buy_sig, title="Bullish Reversal Arrow", style=shape.triangleup, location=location.bottom, color=color_teal, size=size.small)
plotshape(sell_sig, title="Bearish Reversal Arrow", style=shape.triangledown, location=location.top, color=color_red, size=size.small)

// =========================================================================
// 6. Algorithmic Webhook & Real-time Alerts (실시간 웹훅 알림 엔진)
// =========================================================================
alertcondition(buy_sig, title="Bullish Reversal (강력 매수 반전)", message="[Prime Flow] Bullish Reversal Signal Triggered! Capital Inflow Starting. Price: {{close}}")
alertcondition(sell_sig, title="Bearish Reversal (강력 매도 반전)", message="[Prime Flow] Bearish Reversal Signal Triggered! Capital Outflow Starting. Price: {{close}}")
alertcondition(is_os, title="Oversold Entrance (과매도 진입)", message="[Prime Flow] Market Entered Oversold Zone. Watch for Reversal. Price: {{close}}")
alertcondition(is_ob, title="Overbought Entrance (과매수 진입)", message="[Prime Flow] Market Entered Overbought Zone. Watch for Correction. Price: {{close}}")
````
