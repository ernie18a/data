# HyperWave Trend Catcher Confluence

- url: https://www.tradingview.com/script/eVooHGUf/
- type: indicator
- pine_id: PUB;2ba1e534ed6b43c3b8cad098d2b45722
- version: 1.0

## Description

Neu jetzt Mit zahlen 

ich muss mehr schreibene hauhsuhdu912hdzig2d3zgb32d1zugbd2udb2d2

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("HyperWave Trend Catcher Confluence", overlay = true, max_labels_count = 500, max_lines_count = 500)

// --- Constants ---
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color NEUTRAL_COLOR = #5b9cf6

// --- Inputs ---
// HyperWave Settings (WaveTrend based)
grp_hw = "HyperWave (Oscillator) Settings"
hwN1 = input.int(10, "Channel Length", minval = 1, group = grp_hw)
hwN2 = input.int(21, "Average Length", minval = 1, group = grp_hw)
hwLevel = input.float(80.0, "Crossing Level", group = grp_hw)

// Trend Catcher Settings
grp_tc = "Trend Catcher Settings"
tcLength = input.int(20, "Cloud Length", minval = 1, group = grp_tc)

// Money Flow Index Settings
grp_mfi = "Money Flow Settings"
mfiLength = input.int(14, "MFI Length", minval = 1, group = grp_mfi)
mfiThreshold = input.float(50.0, "MFI Threshold", group = grp_mfi)

// Market Structure Settings
grp_ms = "Market Structure (BoS/CHoCH)"
pivotLen = input.int(5, "Pivot Length", minval = 1, group = grp_ms, tooltip = "Length used to identify swing highs and lows.")
showBoS = input.bool(true, "Show Break of Structure (BoS)", group = grp_ms)
showCHoCH = input.bool(true, "Show Change of Character (CHoCH)", group = grp_ms)

// --- Calculations ---

// 1. HyperWave
ap = hlc3
esa = ta.ema(ap, hwN1)
d = ta.ema(math.abs(ap - esa), hwN1)
ci = (ap - esa) / (0.015 * d)
wt1 = ta.ema(ci, hwN2)
wt2 = ta.sma(wt1, 4)
hyperWaveCross = ta.crossover(wt1, hwLevel)

// 2. Trend Catcher
smaHigh = ta.sma(high, tcLength)
smaLow = ta.sma(low, tcLength)
isTrendBullish = close > smaHigh

// 3. Money Flow Index
mfi = ta.mfi(close, mfiLength)
isMFIBullish = mfi > mfiThreshold

// --- Signal Confluence ---
longSignal = hyperWaveCross and isTrendBullish and isMFIBullish

// --- Market Structure (BoS / CHoCH) ---
var int trend = 0
var float lastPH = na
var int lastPHIndex = na
var float lastPL = na
var int lastPLIndex = na

var bool phCrossed = false
var bool plCrossed = false

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph)
    lastPH := ph
    lastPHIndex := bar_index - pivotLen
    phCrossed := false

if not na(pl)
    lastPL := pl
    lastPLIndex := bar_index - pivotLen
    plCrossed := false

// Check for crosses
if not na(lastPH) and not phCrossed and close > lastPH
    phCrossed := true
    isCHoCH = trend == -1
    isBoS = trend == 1
    if isCHoCH
        trend := 1
        if showCHoCH
            line.new(lastPHIndex, lastPH, bar_index, lastPH, color=BULL_COLOR, style=line.style_dashed)
            label.new(bar_index, lastPH, "CHoCH", color=BULL_COLOR, textcolor=color.white, style=label.style_label_down, size=size.normal)
    else if isBoS
        if showBoS
            line.new(lastPHIndex, lastPH, bar_index, lastPH, color=BULL_COLOR, style=line.style_dotted)
            label.new(bar_index, lastPH, "BoS", color=color(na), textcolor=BULL_COLOR, style=label.style_label_down, size=size.tiny)

if not na(lastPL) and not plCrossed and close < lastPL
    plCrossed := true
    isCHoCH = trend == 1
    isBoS = trend == -1
    if isCHoCH
        trend := -1
        if showCHoCH
            line.new(lastPLIndex, lastPL, bar_index, lastPL, color=BEAR_COLOR, style=line.style_dashed)
            label.new(bar_index, lastPL, "CHoCH", color=BEAR_COLOR, textcolor=color.white, style=label.style_label_up, size=size.normal)
    else if isBoS
        if showBoS
            line.new(lastPLIndex, lastPL, bar_index, lastPL, color=BEAR_COLOR, style=line.style_dotted)
            label.new(bar_index, lastPL, "BoS", color=color(na), textcolor=BEAR_COLOR, style=label.style_label_up, size=size.tiny)


// --- Visuals ---
// Trend Catcher Cloud
pHigh = plot(smaHigh, "Trend Catcher High", color = isTrendBullish ? BULL_COLOR : BEAR_COLOR, linewidth = 1)
pLow = plot(smaLow, "Trend Catcher Low", color = isTrendBullish ? BULL_COLOR : BEAR_COLOR, linewidth = 1)
fill(pHigh, pLow, isTrendBullish ? color.new(BULL_COLOR, 85) : color.new(BEAR_COLOR, 85), "Trend Catcher Fill")

// Signal Markers
plotshape(longSignal, "Long Signal", shape.triangleup, location.belowbar, BULL_COLOR, size = size.small, text = "BUY", textcolor = BULL_COLOR)

// Visualizing HyperWave Zone
bgcolor(wt1 > hwLevel ? color.new(BULL_COLOR, 90) : na, title = "HyperWave OB Zone")

// --- Dashboard (MFI Display) ---
var table mfiTable = table.new(position.top_right, 1, 1, frame_color = chart.fg_color, frame_width = 1)
if barstate.islast
    color mfiBgColor = isMFIBullish ? color.new(BULL_COLOR, 60) : color.new(BEAR_COLOR, 60)
    table.cell(mfiTable, 0, 0, "MFI: " + str.tostring(mfi, "#.##"), text_color = chart.fg_color, bgcolor = mfiBgColor, text_size = size.normal)

// --- Alerts ---
alertcondition(longSignal, title="HyperWave Trend Catcher Signal", message="HyperWave Trend Catcher Signal: Long Entry")
````
