# ENOCH Sniper Pro 2.0

- url: https://www.tradingview.com/script/m8NcTwJh-ENOCH-Sniper-Pro-2-0/
- type: indicator
- pine_id: PUB;47c0a809b65c44f3be3ce8f3fb65b341
- version: 1.0

## Description

this indicator shows you when to enter the trade, where to set your stop loss and where to take profit. UPDATE TO ENOCH SNIPER PRO update may 2026

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("SMC Sniper Pro [Clone]", "SMC Sniper Pro", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// --- Constants ---
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #5b9cf6
color TRANSP_COLOR  = color.new(color.white, 100)

// --- Inputs ---
// --- Market Structure ---
int structureLenInput = input.int(5, "Structure Length", minval = 2, group = "Market Structure", tooltip = "Number of bars for swing high/low detection.")

// --- Trade Setups ---
float riskRewardInput = input.float(2.0, "Risk:Reward Ratio", minval = 0.1, step = 0.1, group = "Trade Setups", tooltip = "Used to calculate TP lines.")

// --- Visibility ---
bool showOBInput        = input.bool(true, "Show Order Blocks", group = "Visibility")
bool showFVGInput       = input.bool(true, "Show Fair Value Gaps", group = "Visibility")
bool showStructureInput = input.bool(true, "Show BOS/CHoCH", group = "Visibility")
bool showTradeInput     = input.bool(true, "Show Trade Setup", group = "Visibility")

// --- Types ---
type OrderBlock
    box  boxId
    int  direction // 1: Bullish, -1: Bearish

type FairValueGap
    box  boxId
    int  direction // 1: Bullish, -1: Bearish

// --- Global Variables ---
var float lastHigh      = na
var float lastLow       = na
var int   lastHighIndex = na
var int   lastLowIndex  = na
var int   trend         = 0 // 1: Bullish, -1: Bearish

// Storage
var OrderBlock[]   obs  = array.new<OrderBlock>()
var FairValueGap[] fvgs = array.new<FairValueGap>()

// Trade Setup Lines
var line  entryLine  = na
var line  slLine     = na
var line  tpLine     = na
var label entryLabel = na
var label slLabel    = na
var label tpLabel    = na

// --- Functions ---
addOrderBlock(int dir) =>
    if showOBInput
        // Look back for the last opposite candle before the move
        for i = 1 to 15
            if (dir == 1 and close[i] < open[i]) or (dir == -1 and close[i] > open[i])
                obBox = box.new(bar_index - i, high[i], bar_index, low[i], 
                                 bgcolor = color.new(dir == 1 ? BULL_COLOR : BEAR_COLOR, 85), 
                                 border_color = color.new(dir == 1 ? BULL_COLOR : BEAR_COLOR, 50))
                array.push(obs, OrderBlock.new(obBox, dir))
                break

// --- Market Structure Logic ---
float ph = ta.pivothigh(structureLenInput, structureLenInput)
float pl = ta.pivotlow(structureLenInput, structureLenInput)

if not na(ph)
    lastHigh      := ph
    lastHighIndex := bar_index - structureLenInput

if not na(pl)
    lastLow       := pl
    lastLowIndex  := bar_index - structureLenInput

// Detect Structure Breaks
bool bullBreak = ta.crossover(close, lastHigh)
bool bearBreak = ta.crossunder(close, lastLow)

// --- Signal Handling ---
if bullBreak
    string txt = (trend == -1 or trend == 0) ? "CHoCH" : "BOS"
    if showStructureInput
        line.new(lastHighIndex, lastHigh, bar_index, lastHigh, color = BULL_COLOR, style = line.style_dashed)
        label.new(int(math.avg(lastHighIndex, bar_index)), lastHigh, txt, color = TRANSP_COLOR, textcolor = BULL_COLOR, style = label.style_label_down, size = size.tiny)
    
    // Trade Plan
    if showTradeInput
        line.delete(entryLine), line.delete(slLine), line.delete(tpLine)
        label.delete(entryLabel), label.delete(slLabel), label.delete(tpLabel)
        
        float sl = lastLow
        float tp = close + (close - sl) * riskRewardInput
        
        entryLine  := line.new(bar_index, close, bar_index + 20, close, color = NEUTRAL_COLOR, width = 2)
        slLine     := line.new(bar_index, sl, bar_index + 20, sl, color = BEAR_COLOR, width = 2)
        tpLine     := line.new(bar_index, tp, bar_index + 20, tp, color = BULL_COLOR, width = 2)
        
        entryLabel := label.new(bar_index + 20, close, "Sniper Entry (Long)", color = TRANSP_COLOR, textcolor = NEUTRAL_COLOR, style = label.style_label_left, size = size.small)
        slLabel    := label.new(bar_index + 20, sl, "Stop Loss", color = TRANSP_COLOR, textcolor = BEAR_COLOR, style = label.style_label_left, size = size.small)
        tpLabel    := label.new(bar_index + 20, tp, "Take Profit", color = TRANSP_COLOR, textcolor = BULL_COLOR, style = label.style_label_left, size = size.small)
    
    // OB Detection
    addOrderBlock(1)
    
    trend    := 1
    lastHigh := na 

if bearBreak
    string txt = (trend == 1 or trend == 0) ? "CHoCH" : "BOS"
    if showStructureInput
        line.new(lastLowIndex, lastLow, bar_index, lastLow, color = BEAR_COLOR, style = line.style_dashed)
        label.new(int(math.avg(lastLowIndex, bar_index)), lastLow, txt, color = TRANSP_COLOR, textcolor = BEAR_COLOR, style = label.style_label_up, size = size.tiny)
    
    // Trade Plan
    if showTradeInput
        line.delete(entryLine), line.delete(slLine), line.delete(tpLine)
        label.delete(entryLabel), label.delete(slLabel), label.delete(tpLabel)
        
        float sl = lastHigh
        float tp = close - (sl - close) * riskRewardInput
        
        entryLine  := line.new(bar_index, close, bar_index + 20, close, color = NEUTRAL_COLOR, width = 2)
        slLine     := line.new(bar_index, sl, bar_index + 20, sl, color = BEAR_COLOR, width = 2)
        tpLine     := line.new(bar_index, tp, bar_index + 20, tp, color = BULL_COLOR, width = 2)
        
        entryLabel := label.new(bar_index + 20, close, "Sniper Entry (Short)", color = TRANSP_COLOR, textcolor = NEUTRAL_COLOR, style = label.style_label_left, size = size.small)
        slLabel    := label.new(bar_index + 20, sl, "Stop Loss", color = TRANSP_COLOR, textcolor = BEAR_COLOR, style = label.style_label_left, size = size.small)
        tpLabel    := label.new(bar_index + 20, tp, "Take Profit", color = TRANSP_COLOR, textcolor = BULL_COLOR, style = label.style_label_left, size = size.small)
    
    // OB Detection
    addOrderBlock(-1)

    trend   := -1
    lastLow := na

// --- Fair Value Gap Logic ---
if showFVGInput
    // Bullish FVG
    if low > high[2] and close[1] > high[2]
        fvgBox = box.new(bar_index - 2, low, bar_index, high[2], bgcolor = color.new(BULL_COLOR, 90), border_color = na)
        array.push(fvgs, FairValueGap.new(fvgBox, 1))
    // Bearish FVG
    if high < low[2] and close[1] < low[2]
        fvgBox = box.new(bar_index - 2, low[2], bar_index, high, bgcolor = color.new(BEAR_COLOR, 90), border_color = na)
        array.push(fvgs, FairValueGap.new(fvgBox, -1))

// --- Zone Management & Mitigation ---
// Order Blocks
if array.size(obs) > 0
    for i = array.size(obs) - 1 to 0
        ob = array.get(obs, i)
        box.set_right(ob.boxId, bar_index)
        
        bool mitigated = false
        if ob.direction == 1 and close < box.get_bottom(ob.boxId)
            mitigated := true
        else if ob.direction == -1 and close > box.get_top(ob.boxId)
            mitigated := true
            
        if mitigated
            box.delete(ob.boxId)
            array.remove(obs, i)

// FVGs
if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        fvg = array.get(fvgs, i)
        box.set_right(fvg.boxId, bar_index)
        
        bool mitigated = false
        if fvg.direction == 1 and low < box.get_bottom(fvg.boxId)
            mitigated := true
        else if fvg.direction == -1 and high > box.get_top(fvg.boxId)
            mitigated := true
            
        if mitigated
            box.delete(fvg.boxId)
            array.remove(fvgs, i)

// --- Visuals ---
plotshape(bullBreak, "Bull Signal", shape.triangleup, location.belowbar, BULL_COLOR, size = size.small)
plotshape(bearBreak, "Bear Signal", shape.triangledown, location.abovebar, BEAR_COLOR, size = size.small)

// Update Trade Line positions for real-time clarity
if barstate.islast and showTradeInput
    if not na(entryLine)
        line.set_x2(entryLine, bar_index + 20)
        label.set_x(entryLabel, bar_index + 20)
    if not na(slLine)
        line.set_x2(slLine, bar_index + 20)
        label.set_x(slLabel, bar_index + 20)
    if not na(tpLine)
        line.set_x2(tpLine, bar_index + 20)
        label.set_x(tpLabel, bar_index + 20)

// Directional Background
bgcolor(trend == 1 ? color.new(BULL_COLOR, 95) : trend == -1 ? color.new(BEAR_COLOR, 95) : na)
````
