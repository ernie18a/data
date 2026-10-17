# Volume Liquidity Sweep [XWiseTrade]

- url: https://www.tradingview.com/script/UghDr373-Volume-Liquidity-Sweep-XWiseTrade/
- type: indicator
- pine_id: PUB;8cde0c347c2444daa0d5e52258eaceca
- version: 1.0

## Description

Liquidity Sweep with Volume Confirmation

[b]Most liquidity sweep and stop-hunt indicators rely on price geometry alone — they flag any wick past a prior high or low. [/b]
The problem: in quiet conditions, price drifts past old levels with no real participation, producing constant false signals. This indicator adds the missing dimension: it only flags a sweep when volume confirms it.
What makes it different

A sweep is marked only when the breaking candle trades above a configurable multiple of average volume. Low-volume drifts past a level are ignored. This is the core distinction from geometry-only sweep tools — real liquidity grabs leave a volume footprint; quiet fakeouts don't.

What it shows
•Auto-detected swing highs/lows where liquidity rests (pivot-based)
•Bull sweep — price wicks below a prior low, then closes back above, on confirmed volume
•Bear sweep — price wicks above a prior high, then closes back below, on confirmed volume
Swept levels marked on the chart

Inputs
Pivot lookback, volume average length, volume spike multiplier, signal cooldown, level display toggle.

Built-in alerts for both directions. These are descriptive market-structure signals for discretionary use, not buy/sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

//@version=6
indicator("Volume Liquidity Sweep [XWiseTrade]", overlay=true, max_labels_count=500, max_lines_count=500)

// ===== Inputs =====
pivotLen = input.int(5, "Pivot lookback (swing high/low)", minval=1, group="Liquidity")
volLen   = input.int(20, "Volume average length", group="Volume")
volMult  = input.float(1.5, "Volume spike multiplier", step=0.1, minval=1.0, group="Volume", tooltip="扫荡那根成交量需 > 均量 × 此倍数才算放量确认")
showLines = input.bool(true, "Show swept levels", group="Display")
cooldown = input.int(3, "Signal cooldown (bars)", minval=0, group="Display")

// ===== 前高/前低(流动性)=====
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// ===== Volume 确认 =====
avgVol = ta.sma(volume, volLen)
volSpike = volume > avgVol * volMult

// ===== 严格插针式 sweep =====
// 扫上方流动性:本根 high 破前高,但 close 收回前高之下(假突破)+ 放量 → Bear
sweepHigh = not na(lastPH) and high > lastPH and close < lastPH and volSpike
// 扫下方流动性:本根 low 破前低,但 close 收回前低之上 + 放量 → Bull
sweepLow  = not na(lastPL) and low < lastPL and close > lastPL and volSpike

// ===== 冷却 =====
var int lastBull = -1000
var int lastBear = -1000
fireBull = sweepLow  and (bar_index - lastBull > cooldown)
fireBear = sweepHigh and (bar_index - lastBear > cooldown)
if fireBull
    lastBull := bar_index
if fireBear
    lastBear := bar_index

// ===== 标记 =====
if fireBull
    label.new(bar_index, low, "Bull\nsweep", yloc=yloc.belowbar,
         color=color.new(color.teal,0), textcolor=color.white,
         style=label.style_label_up, size=size.small)
    if showLines
        line.new(bar_index - pivotLen, lastPL, bar_index, lastPL, color=color.new(color.teal,40), style=line.style_dashed)
if fireBear
    label.new(bar_index, high, "Bear\nsweep", yloc=yloc.abovebar,
         color=color.new(color.red,0), textcolor=color.white,
         style=label.style_label_down, size=size.small)
    if showLines
        line.new(bar_index - pivotLen, lastPH, bar_index, lastPH, color=color.new(color.red,40), style=line.style_dashed)

// ===== Alerts =====
alertcondition(fireBull, "Bullish Liquidity Sweep", "Low swept below prior low with volume, closed back up")
alertcondition(fireBear, "Bearish Liquidity Sweep", "High swept above prior high with volume, closed back down")
````
