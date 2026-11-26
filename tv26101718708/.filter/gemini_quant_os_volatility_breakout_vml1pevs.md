#  Gemini Quant OS - Volatility Breakout

- url: https://www.tradingview.com/script/VML1PEVs/
- type: indicator
- pine_id: PUB;c27d010b2e224dc7b22a3ba117f50648
- version: 1.0

## Description

\

Overview

Gemini Quant OS — Volatility Breakout is a volatility expansion framework designed to detect potential breakout conditions and momentum continuation opportunities.

This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

Financial markets often transition between contraction and expansion phases. This framework attempts to identify periods where volatility compression may precede directional expansion.

The model combines:

breakout structure analysis

ATR expansion

momentum confirmation

volatility contraction logic

trend filtering

volume-based confirmation


The framework is designed to assist traders in identifying possible expansion phases following low-volatility environments.


---

Features

Breakout condition detection

Volatility expansion monitoring

Momentum confirmation

ATR-based filtering

Multi-market compatibility

Trend-aware structure analysis



---

Best Use Cases

Best suited for:

breakout trading

momentum environments

volatility expansion phases

trend continuation setups

H1–D1 analysis



---

Notes

This script is designed for educational and analytical purposes only.

Not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Gemini_Quant_Lab
//@version=6
indicator("Gemini Volatility Breakout Alert ", overlay=true, max_labels_count=500)

//==============================
// Inputs
//==============================
group_main = "=== 策略參數 ==="
len_ema = input.int(200, "Trend EMA Period", group=group_main, minval=1)
len_donch = input.int(24, "Breakout Period (Donchian)", group=group_main, minval=2)

group_vol = "=== 成交量過濾 (Volume) ==="
len_vol_ma = input.int(20, "Volume Avg Period", group=group_vol, minval=1)
vol_mult = input.float(1.5, "Volume Multiplier (爆量倍數)", step=0.1, group=group_vol)

group_sig = "=== 訊號設定 ==="
confirm_on_close = input.bool(true, "Confirm on Bar Close (建議開)", group=group_sig)
one_shot = input.bool(true, "One-shot signal (避免連續提示)", group=group_sig)

group_vis = "=== 視覺 ==="
show_bands = input.bool(true, "Show Donchian Bands", group=group_vis)
show_fill = input.bool(true, "Fill Bands", group=group_vis)
show_labels= input.bool(true, "Show Entry Labels", group=group_vis)
mark_hv = input.bool(true, "Color High Volume Bars", group=group_vis)

//==============================
// Calculations
//==============================
emaValue = ta.ema(close, len_ema)
breakHigh = ta.highest(high, len_donch)[1]
breakLow = ta.lowest(low, len_donch)[1]

volMA = ta.sma(volume, len_vol_ma)
isHighVol = not na(volMA) and volume > (volMA * vol_mult)

// Guard
canTrade = not na(breakHigh) and not na(breakLow)

// Breakout rule (clean): CLOSE breaks level
rawLong = canTrade and close > emaValue and close > breakHigh and isHighVol
rawShort = canTrade and close < emaValue and close < breakLow and isHighVol

// Confirm option
longSig = confirm_on_close ? (rawLong and barstate.isconfirmed) : rawLong
shortSig = confirm_on_close ? (rawShort and barstate.isconfirmed) : rawShort

// One-shot (fire only on first bar entering signal state)
longFire = one_shot ? (longSig and not longSig[1]) : longSig
shortFire = one_shot ? (shortSig and not shortSig[1]) : shortSig

//==============================
// Visuals
//==============================
plot(emaValue, "Trend EMA", color=color.orange, linewidth=2)

u = plot(show_bands ? breakHigh : na, "Break High", color=color.new(color.blue, 80))
l = plot(show_bands ? breakLow : na, "Break Low", color=color.new(color.blue, 80))
fill(u, l, color = (show_bands and show_fill) ? color.new(color.blue, 92) : na)

barcolor(mark_hv and isHighVol ? color.new(color.purple, 0) : na, title="High Volume Bar")

if show_labels and longFire
    label.new(bar_index, low, "BUY\nVol Break", style=label.style_label_up, textcolor=color.white, color=color.green)

if show_labels and shortFire
    label.new(bar_index, high, "SELL\nVol Break", style=label.style_label_down, textcolor=color.white, color=color.red)

//==============================
// Alerts
//==============================
alertcondition(longFire, title="BUY: Gold Vol Breakout", message="BUY signal: Vol Breakout (close > Donchian High, high volume, above EMA)")
alertcondition(shortFire, title="SELL: Gold Vol Breakout", message="SELL signal: Vol Breakout (close < Donchian Low, high volume, below EMA)")
````
