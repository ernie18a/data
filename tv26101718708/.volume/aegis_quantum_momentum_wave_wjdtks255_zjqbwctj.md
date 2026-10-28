# Aegis Quantum Momentum Wave [wjdtks255]

- url: https://www.tradingview.com/script/zjQbWcTj/
- type: indicator
- pine_id: PUB;a81bc73551ac45848edd81095f974823
- version: 2.0

## Description

Quantum Momentum Wave [wjdtks255]: Energy-Based Oscillator
■ OVERVIEW (English)
Quantum Momentum Wave is a sophisticated oscillator that quantifies market inertia by synthesizing price velocity and volume data. Unlike standard momentum tools, it identifies the "hidden energy" behind price movements, allowing traders to spot trend exhaustion and reversal points before they manifest in price action.

■ CORE FEATURES

Force Index Evolution: Utilizes a modified Elder’s Force Index to visualize buying and selling pressure as a continuous wave.

Momentum Pivot Detection: Specialized signal dots identify precise moments when energy shifts, providing early warnings for trend reversals.

Smart Divergence Engine: Automatically detects bullish and bearish divergences (Yellow Diamond signals) where price and energy drift apart, predicting high-probability exhaustion zones.

Zero-Line Polarity: Instant visual confirmation of market dominance through color-coded area plots (Aqua for Bulls, Red for Bears).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Premium Oscillator Series: Quantum Momentum Wave
// Powered by wjdtks255
indicator("Aegis Quantum Momentum Wave [wjdtks255]", shorttitle="Aegis QMW", precision=2, max_labels_count=500)

// =========================================================================
// 1. Settings
// =========================================================================
group_gen   = "Global System Settings"
i_lang      = input.string("English", "System Language", options=["English", "Korean"], group=group_gen)
ko          = i_lang == "Korean"
group_core  = "Core Wave Parameters"
len         = input.int(13, "Wave Sensitivity", minval=1, group=group_core)
smooth      = input.int(8, "Signal Smoothness", minval=1, group=group_core)
group_visual = "Visual Style"
bullColor    = input.color(#00ffbb, "Bullish Color", group=group_visual)
bearColor    = input.color(#ff1100, "Bearish Color", group=group_visual)

// =========================================================================
// 2. Logic
// =========================================================================
raw_force = (close - close[1]) * volume
wave      = ta.ema(raw_force, len)
signal    = ta.wma(wave, smooth)

wave_col = wave > 0 ? color.new(bullColor, 30) : color.new(bearColor, 30)
plot(wave, "Momentum Wave", color=wave_col, style=plot.style_area)
plot(signal, "Signal Line", color=color.new(color.white, 40), linewidth=1)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

bull_pivot = ta.crossover(wave, signal) and wave < 0
bear_pivot = ta.crossunder(wave, signal) and wave > 0

plotshape(bull_pivot, "Bull Pivot", shape.circle, location.bottom, color=bullColor, size=size.tiny)
plotshape(bear_pivot, "Bear Pivot", shape.circle, location.top, color=bearColor, size=size.tiny)

// =========================================================================
// 3. Divergence Engine (에러 원천 차단형 로직)
// =========================================================================
low_p = ta.pivotlow(wave, 5, 5)

var float last_low_p_wave = na
var float last_low_p_price = na
var int last_low_p_index = na

if not na(low_p)
    last_low_p_wave := wave[5]
    last_low_p_price := low[5]
    last_low_p_index := bar_index - 5

is_div = not na(low_p) and low[5] < last_low_p_price[1] and wave[5] > last_low_p_wave[1]

// 에러 해결: 작도 시 bar_index 보존
if is_div
    line.new(last_low_p_index, last_low_p_price[1], bar_index - 5, wave[5], color=color.yellow, width=2)
    label.new(bar_index - 5, wave[5], "▲", color=color.new(color.white, 100), textcolor=color.yellow, style=label.style_label_up, size=size.small)

alertcondition(bull_pivot, "Bull Pivot", "Bullish Energy Pivot")
alertcondition(bear_pivot, "Bear Pivot", "Bearish Energy Pivot")
alertcondition(is_div, "Divergence", "Divergence Detected")
````
