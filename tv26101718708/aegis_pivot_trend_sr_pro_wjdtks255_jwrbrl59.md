# Aegis Pivot Trend & S/R Pro [wjdtks255]

- url: https://www.tradingview.com/script/jwRBrL59/
- type: indicator
- pine_id: PUB;e78e7631be53486ca7561dfafb71e99d
- version: 1.0

## Description

Aegis Pivot Trend & S/R Pro [wjdtks255]

A precision technical analysis tool designed to visualize market structure. By automatically mapping key Support/Resistance levels and trendlines based on pivot point analysis, this indicator helps traders identify critical price zones and momentum shifts instantly.

[Key Features]

Auto-Horizontal S/R: Automatically plots recent Pivot Highs (Red) and Lows (Green) as key horizontal price levels.

Pivot-to-Pivot Trendlines: Draws stable, non-repainting diagonal trendlines (White/Yellow) to provide a clear view of market structure.

Clean Interface: Designed to keep your chart clutter-free while highlighting essential technical levels.

[How to Use]

Pivot Sensitivity: Adjust the 'Pivot Lookback' input to match your preferred timeframe and trading style (Default: 15).

Breakout & Reversal: Use the horizontal lines as entry/exit zones and observe price reactions at the diagonal trendlines for potential breakout or reversal signals.

Strategy Confirmation: Best used as a primary structural confirmation tool alongside your trend-following strategies.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis Pivot Trend & S/R Pro [wjdtks255]", shorttitle="Aegis Pivot Trend & S/R Pro [wjdtks255]", overlay=true)

// --- 1. 설정 ---
lookback = input.int(15, "피벗 기간 (Pivot Lookback)")

// --- 2. 피벗 포인트 계산 ---
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

// --- 3. 수평 지지/저항선 ---
var line horizRes = na
var line horizSup = na

if not na(ph)
    line.delete(horizRes)
    horizRes := line.new(bar_index[lookback], ph, bar_index, ph, color=color.red, width=2, style=line.style_solid)
    line.set_extend(horizRes, extend.right)

if not na(pl)
    line.delete(horizSup)
    horizSup := line.new(bar_index[lookback], pl, bar_index, pl, color=color.green, width=2, style=line.style_solid)
    line.set_extend(horizSup, extend.right)

// --- 4. 빗각 추세선 (피벗 투 피벗) ---
var int last_ph_idx = na
var float last_ph_val = na
var int last_pl_idx = na
var float last_pl_val = na

var line trendlineHigh = na
var line trendlineLow = na

// 고점 추세선 업데이트
if not na(ph)
    if not na(last_ph_idx)
        line.delete(trendlineHigh)
        trendlineHigh := line.new(last_ph_idx, last_ph_val, bar_index[lookback], ph, color=color.white, width=2, style=line.style_dashed)
        line.set_extend(trendlineHigh, extend.right)
    last_ph_idx := bar_index[lookback]
    last_ph_val := ph

// 저점 추세선 업데이트
if not na(pl)
    if not na(last_pl_idx)
        line.delete(trendlineLow)
        trendlineLow := line.new(last_pl_idx, last_pl_val, bar_index[lookback], pl, color=color.yellow, width=2, style=line.style_dashed)
        line.set_extend(trendlineLow, extend.right)
    last_pl_idx := bar_index[lookback]
    last_pl_val := pl
````
