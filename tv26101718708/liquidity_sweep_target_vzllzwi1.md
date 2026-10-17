# Liquidity Sweep + Target

- url: https://www.tradingview.com/script/vZLLZwi1-Liquidity-Sweep-Target/
- type: indicator
- pine_id: PUB;014714e9c1f44458a6f0488032f561e1
- version: 1.0

## Description

[b]Liquidity Sweep + Target[/b]

This indicator detects liquidity sweeps — moments where price wicks beyond a recent swing high or low to trigger stops/liquidity, then closes back inside the range (a classic stop-hunt / SFP pattern). Once a sweep is confirmed, the indicator automatically plots a target level for the expected reversal move.
How it works:

Identifies swing highs and lows using an adjustable pivot lookback.
Bearish Sweep: price wicks above the last swing high but closes back below it → signals potential downside reversal, target plotted below.
Bullish Sweep: price wicks below the last swing low but closes back above it → signals potential upside reversal, target plotted above.
Target calculation: choose between (1) the next opposite-side liquidity level (previous swing point) or (2) a fixed risk:reward multiple of the sweep range — fully configurable in settings.

Features:

Clean sweep labels (bullish/bearish) plotted directly on the chart
Dashed target lines with price labels
Adjustable pivot sensitivity, wick threshold, and RR multiple
Built-in alert conditions for both bullish and bearish sweeps

How to use it:
Wait for a sweep label to print, then look for confirmation (structure shift, momentum candle, or your own entry trigger) before acting on the plotted target. This tool identifies liquidity grabs — it does not predict direction with certainty, so always combine with proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Liquidity Sweep + Target", overlay=true, max_labels_count=500, max_lines_count=500)

// ───────────────────────────── INPUTS ─────────────────────────────
pivotLen      = input.int(5, "Pivot Lookback (each side)", minval=1, tooltip="Bars on each side used to confirm a swing high/low")
sweepWickMin  = input.float(0.0, "Min Wick Beyond Level (points)", minval=0.0, tooltip="Minimum distance the wick must pierce the level to count as a sweep")
targetRR      = input.float(2.0, "Target Risk:Reward Multiple", minval=0.1, tooltip="Used only if 'Use Opposite Liquidity as Target' is off")
useOppositeTP = input.bool(true, "Use Opposite Liquidity as Target", tooltip="If on, target = most recent opposite-side swing level. If off, target = entry +/- (sweep range * RR)")
showLabels    = input.bool(true, "Show Sweep Labels")
showTargets   = input.bool(true, "Show Target Lines")
bullColor     = input.color(color.new(color.lime, 0), "Bullish Sweep Color")
bearColor     = input.color(color.new(color.red, 0), "Bearish Sweep Color")
targetColor   = input.color(color.new(color.orange, 0), "Target Line Color")

// ───────────────────────────── PIVOTS ─────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPH = na
var float lastPL = na

if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// track the previous swing (before the most recent one) so we still have
// a level to sweep even right after a new pivot forms
var float prevPH = na
var float prevPL = na

if not na(ph)
    prevPH := lastPH[1]
if not na(pl)
    prevPL := lastPL[1]

// ───────────────────────────── SWEEP DETECTION ─────────────────────────────
// Bearish sweep: high pierces above last swing high, but candle closes back below it
bearishSweep = not na(lastPH) and high > lastPH + sweepWickMin and close < lastPH and high[1] <= lastPH

// Bullish sweep: low pierces below last swing low, but candle closes back above it
bullishSweep = not na(lastPL) and low < lastPL - sweepWickMin and close > lastPL and low[1] >= lastPL

// ───────────────────────────── LABELS ─────────────────────────────
if bearishSweep and showLabels
    label.new(bar_index, high, "SFP ▼\nSweep High", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

if bullishSweep and showLabels
    label.new(bar_index, low, "SFP ▲\nSweep Low", style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

// ───────────────────────────── TARGETS ─────────────────────────────
// Bearish sweep -> expect move DOWN -> target = next opposite liquidity (recent swing low) or RR-based
if bearishSweep and showTargets
    float entry = close
    float stop  = high
    float rng = stop - entry
    float target = useOppositeTP and not na(lastPL) ? lastPL : entry - rng * targetRR
    line.new(bar_index, target, bar_index + 20, target, color=targetColor, style=line.style_dashed, width=2)
    label.new(bar_index + 20, target, "Target: " + str.tostring(target, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.tiny)

// Bullish sweep -> expect move UP -> target = next opposite liquidity (recent swing high) or RR-based
if bullishSweep and showTargets
    float entry = close
    float stop  = low
    float rng = entry - stop
    float target = useOppositeTP and not na(lastPH) ? lastPH : entry + rng * targetRR
    line.new(bar_index, target, bar_index + 20, target, color=targetColor, style=line.style_dashed, width=2)
    label.new(bar_index + 20, target, "Target: " + str.tostring(target, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.tiny)

// ───────────────────────────── PLOT PIVOT LEVELS (optional visual aid) ─────────────────────────────
plot(lastPH, "Last Swing High", color=color.new(bearColor, 70), style=plot.style_stepline)
plot(lastPL, "Last Swing Low", color=color.new(bullColor, 70), style=plot.style_stepline)

// ───────────────────────────── ALERTS ─────────────────────────────
alertcondition(bearishSweep, title="Bearish Liquidity Sweep", message="Bearish liquidity sweep detected — price swept high and closed back below.")
alertcondition(bullishSweep, title="Bullish Liquidity Sweep", message="Bullish liquidity sweep detected — price swept low and closed back above.")
````
