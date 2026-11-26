# Aegis Quantum Energy Band [wjdtks255]

- url: https://www.tradingview.com/script/4zxvPrjE/
- type: indicator
- pine_id: PUB;b853bc4c7d244b72a42acc84bfc00cac
- version: 3.0

## Description

Aegis Quantum Energy Band [wjdtks255]: High-Volatility Breakout System

■ OVERVIEW 
Aegis Quantum Energy Band is a volatility-based breakout framework that utilizes a hybrid envelope system to identify institutional entry points. By integrating Standard Deviation Bands with a Volume Spike Filter, it distinguishes between market noise and high-conviction momentum shifts, ensuring traders only enter when real energy is present.

■ CORE STRATEGY

Energy Confirmation: Signals are only generated when volume exceeds the average by 1.8x, confirming institutional participation.

Structural Breakout Filter: Validates the strength of the breakout bar’s body to avoid "Fake-outs."

Flat Market Protection: Incorporates a slope-based filter to prevent entries during low-volatility consolidation phases.

Dynamic Risk Execution: Automatically calculates and plots Target (TP) and Stop (SL) levels based on ATR, providing a clear execution roadmap.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis Quantum Energy Band [wjdtks255]", overlay=true, precision=2, max_labels_count=500)

// === 1. 설정 (영어/한글 병기하여 범용성 극대화) ===
group_core = "Core Parameters (핵심 설정)"
energyLength  = input.int(20, "Period (기간)", minval=1, group=group_core)
volMultiplier = input.float(1.8, "Volume Spike Multiplier (거래량 폭발 배율)", group=group_core)
bandMult      = input.float(2.5, "Band Width (밴드 폭)", group=group_core)
tpMult        = input.float(1.5, "Take Profit ATR Mult (익절 배율)", group=group_core)

// === 2. 하이브리드 밴드 계산 ===
basis = ta.sma(close, energyLength)
dev   = bandMult * ta.stdev(close, energyLength)
upper = basis + dev
lower = basis - dev

// === 3. 에너지 필터 (고도화) ===
avgVol     = ta.sma(volume, energyLength)
isVolSpike = volume > (avgVol * volMultiplier)
bodySize   = math.abs(close - open)
isStrong   = bodySize > ta.sma(bodySize, energyLength)
isFlat     = math.abs(ta.change(basis)) < (ta.atr(14) * 0.1)

longSignal  = isVolSpike and isStrong and close > upper and not isFlat
shortSignal = isVolSpike and isStrong and close < lower and not isFlat

// === 4. 시각화 (인기 지표의 핵심은 가독성) ===
plot(basis, "Middle Line", color=close > basis ? #00ff88 : #ff0055, linewidth=2)
p1 = plot(upper, color=color.new(#00ff88, 70))
p2 = plot(lower, color=color.new(#ff0055, 70))
fill(p1, p2, color=close > basis ? color.new(#00ff88, 96) : color.new(#ff0055, 96))

barcolor(longSignal ? #00ff88 : shortSignal ? #ff0055 : isVolSpike ? color.yellow : na)

// === 5. 익절/손절가 및 시그널 라벨 (위치 최적화) ===
atr = ta.atr(14)
var float tp = na
var float sl = na

if longSignal
    tp := close + (atr * tpMult)
    sl := basis
if shortSignal
    tp := close - (atr * tpMult)
    sl := basis

plot(longSignal or shortSignal ? tp : na, "Target Line", color=color.aqua, style=plot.style_linebr, linewidth=2)
plot(longSignal or shortSignal ? sl : na, "Stop Line", color=color.orange, style=plot.style_linebr, linewidth=2)

plotshape(longSignal, "Buy", shape.labelup, location.belowbar, #00ff88, text="CORE BUY", textcolor=color.black, size=size.small)
plotshape(shortSignal, "Sell", shape.labeldown, location.abovebar, #ff0055, text="CORE SELL", textcolor=color.white, size=size.small)

// === 6. 얼럿 추가 (퍼블리시 인기 지표 필수 조건) ===
alertcondition(longSignal, "Core Buy Alert", "Bullish Energy Breakout Detected")
alertcondition(shortSignal, "Core Sell Alert", "Bearish Energy Breakout Detected")
````
