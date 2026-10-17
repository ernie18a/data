# Aegis DTC Style Bounce Back System

- url: https://www.tradingview.com/script/nqwu8jt5/
- type: indicator
- pine_id: PUB;7ba1b095cc2349bfa8f89bfabcf9a31e
- version: 2.0

## Description

Aegis DTC Style Bounce Back System 

■ OVERVIEW
Aegis DTC Style Bounce Back System is a trend-following and mean-reversion hybrid strategy. It utilizes a dynamic EMA Ribbon to identify the primary market bias and automatically generates Support/Resistance zones based on recent price extremes. The system is designed to catch high-probability "bounce back" opportunities within an established trend.

■ KEY FEATURES

Gradient EMA Ribbon: A multi-layered EMA cloud that visualizes trend strength and potential exhaustion points through color transitions.

Auto-Dynamic Zones: High-precision support and resistance boxes that update in real-time based on lookback periods, marking institutional supply and demand areas.

Target Projection: Provides dashed target lines upon signal generation to assist in profit-taking and trade planning.

Trend-Validated Signals: BUY/SELL labels are filtered through the EMA ribbon to ensure entries are aligned with the prevailing momentum.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis DTC Bounce Back System [wjdtks255]", overlay=true, precision=2, max_boxes_count=500)

// === 1. 설정 ===
group_ribbon = "Trend Ribbon Settings"
ema_len1 = input.int(20, "Fast EMA", group=group_ribbon)
ema_len4 = input.int(50, "Slow EMA", group=group_ribbon)
lookback  = input.int(20, "Lookback Period", group="Settings")

// === 2. EMA 리본 ===
e1 = ta.ema(close, ema_len1)
e4 = ta.ema(close, ema_len4)
fill(plot(e1, color=color.new(#00ff88, 70)), plot(e4, color=color.new(#ff1100, 70)), color=e1 > e4 ? color.new(color.green, 90) : color.new(color.red, 90))

// === 3. 자동 지지/저항 박스 엔진 (에러 완전 해결) ===
hi = ta.highest(high, lookback)
lo = ta.lowest(low, lookback)

var box resistBox = na
var box supportBox = na

// ta.change(hi) != 0 으로 확실하게 참/거짓 판단
if ta.change(hi) != 0
    box.delete(resistBox)
    resistBox := box.new(bar_index[lookback], hi, bar_index, hi * 0.998, bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 0), border_width=1)

if ta.change(lo) != 0
    box.delete(supportBox)
    supportBox := box.new(bar_index[lookback], lo * 1.002, bar_index, lo, bgcolor=color.new(color.green, 80), border_color=color.new(color.green, 0), border_width=1)

// === 4. 시그널 및 라인 ===
longCondition  = ta.crossover(e1, e4)
shortCondition = ta.crossunder(e1, e4)

plotshape(longCondition, "Buy", shape.labelup, location.belowbar, #00ff88, text="BUY", textcolor=color.white, size=size.small)
plotshape(shortCondition, "Sell", shape.labeldown, location.abovebar, #ff1100, text="SELL", textcolor=color.white, size=size.small)

var line targetLine = na
if longCondition
    line.delete(targetLine)
    targetLine := line.new(bar_index, close * 1.05, bar_index + 15, close * 1.05, color=color.gray, style=line.style_dashed)

alertcondition(longCondition, "Aegis Buy", "Bullish Signal")
alertcondition(shortCondition, "Aegis Sell", "Bearish Signal")
````
