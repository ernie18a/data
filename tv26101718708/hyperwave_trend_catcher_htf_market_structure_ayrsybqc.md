# HyperWave Trend Catcher + HTF Market Structure

- url: https://www.tradingview.com/script/ayRsYBqc/
- type: indicator
- pine_id: PUB;f44eb64879c041e3b6a5e77b4627f128
- version: 1.0

## Description

Test :) für meinen tollen Indikator

bitte lade jetzt einfach hoch :)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("HyperWave Trend Catcher + HTF Market Structure", shorttitle="HWTC + HTF MS", overlay=true, max_labels_count=500, max_lines_count=500)

// --- Constants ---
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color NEUTRAL_COLOR = #787b86

// --- Inputs ---
// Trend Settings
tcLength  = input.int(20, "Trend Catcher Length", minval=1, group="Trend Catcher Settings")

// Higher-Level Market Structure Settings
msLen = input.int(21, "HTF MS Pivot Strength", minval=5, group="Market Structure", tooltip="Higher values detect only major (higher timeframe) structure. Lower values show minor structure.")
showBOS = input.bool(true, "Show Valid BOS", group="Market Structure")
showCHoCH = input.bool(true, "Show Valid CHoCH", group="Market Structure")

// --- Calculations ---

// 1. Trend Catcher (SMA High/Low Channel)
smaHigh = ta.sma(high, tcLength)
smaLow  = ta.sma(low, tcLength)
bool isBullTrend = close > smaHigh
bool isBearTrend = close < smaLow

// 2. Higher-Level Market Structure Logic
var float lastPH = na
var float lastPL = na
var int lastPH_idx = na
var int lastPL_idx = na
var bool isBullMS = true

// Find Major Pivots
ph = ta.pivothigh(high, msLen, msLen)
pl = ta.pivotlow(low, msLen, msLen)

if not na(ph)
    lastPH := ph
    lastPH_idx := bar_index - msLen

if not na(pl)
    lastPL := pl
    lastPL_idx := bar_index - msLen

// "Valid" Breakout Check (using Close for confirmation)
bool breakHigh = close > lastPH
bool breakLow  = close < lastPL

// Logic for Higher-Level BOS vs CHoCH
if breakHigh and not na(lastPH)
    if not isBullMS
        // VALID CHoCH: Shift from Bearish to Bullish Structure
        if showCHoCH
            label.new(bar_index, high, "CHoCH (HTF)", color=color.new(BULL_COLOR, 100), textcolor=BULL_COLOR, style=label.style_label_down, size=size.small)
            line.new(lastPH_idx, lastPH, bar_index, lastPH, color=BULL_COLOR, style=line.style_dashed, width=2)
        isBullMS := true
    else
        // VALID BOS: Continuation of Bullish Structure
        if showBOS
            label.new(bar_index, high, "BOS (HTF)", color=color.new(BULL_COLOR, 100), textcolor=BULL_COLOR, style=label.style_label_down, size=size.tiny)
            line.new(lastPH_idx, lastPH, bar_index, lastPH, color=BULL_COLOR, style=line.style_dotted, width=1)
    lastPH := na // Prevent multiple signals for the same level

if breakLow and not na(lastPL)
    if isBullMS
        // VALID CHoCH: Shift from Bullish to Bearish Structure
        if showCHoCH
            label.new(bar_index, low, "CHoCH (HTF)", color=color.new(BEAR_COLOR, 100), textcolor=BEAR_COLOR, style=label.style_label_up, size=size.small)
            line.new(lastPL_idx, lastPL, bar_index, lastPL, color=BEAR_COLOR, style=line.style_dashed, width=2)
        isBullMS := false
    else
        // VALID BOS: Continuation of Bearish Structure
        if showBOS
            label.new(bar_index, low, "BOS (HTF)", color=color.new(BEAR_COLOR, 100), textcolor=BEAR_COLOR, style=label.style_label_up, size=size.tiny)
            line.new(lastPL_idx, lastPL, bar_index, lastPL, color=BEAR_COLOR, style=line.style_dotted, width=1)
    lastPL := na // Prevent multiple signals for the same level

// --- Visuals ---

// Plot Trend Catcher Channel
p_high = plot(smaHigh, "Trend High", color=color.new(BULL_COLOR, 50))
p_low  = plot(smaLow, "Trend Low", color=color.new(BEAR_COLOR, 50))
fill(p_high, p_low, isBullTrend ? color.new(BULL_COLOR, 90) : isBearTrend ? color.new(BEAR_COLOR, 90) : color.new(NEUTRAL_COLOR, 95), title="Trend Zone")
````
