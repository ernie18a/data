# Heikin ERL Pulse

- url: https://www.tradingview.com/script/K5ZLoVA5/
- type: indicator
- pine_id: PUB;51cce34721df4f74aa5b805e54637391
- version: 2.0

## Description

Heikin ERL Pulse

This indicator combines ICT concepts with a Heikin Ashi trend filter to generate clean breakout signals.

How it works:

Plots External Range Liquidity (ERL) levels based on swing highs and lows.
When price breaks an ERL High → Buy signal
When price breaks an ERL Low → Sell signal
Signals are filtered by a Heikin Ashi Moving Average. Buys are only allowed when price is above the HA MA, and sells only when price is below it.
Also displays Fair Value Gaps (FVG) and Change in State of Delivery (CSD) for additional context.

Key Features:

Heikin ERL Pulse break signals
Heikin Ashi MA trend filter
Optional FVG and CSD visuals
Clean and minimal design

Ideal for traders who want simple liquidity break signals aligned with the short-term trend.

## Source Code

````pine
//@version=6
indicator("Heikin ERL Pulse", overlay=true, max_boxes_count=300, max_lines_count=300)

// ==========================================
// 1. INPUTS
// ==========================================
var string G_IRL = "Internal Range Liquidity (FVG)"
showFVG       = input.bool(true, "Show Active FVG", group=G_IRL)
fvgColorBull  = input.color(color.new(color.green, 88), "Bullish FVG", group=G_IRL)
fvgColorBear  = input.color(color.new(color.red, 88), "Bearish FVG", group=G_IRL)
removeFilled  = input.bool(true, "Remove FVG when filled", group=G_IRL)

var string G_ERL = "External Range Liquidity (ERL)"
showERL       = input.bool(true, "Show ERL Lines", group=G_ERL)
swingLen      = input.int(5, "Swing Lookback", minval=1, group=G_ERL)
maxLines      = input.int(4, "Max Active ERL Lines", minval=1, maxval=10, group=G_ERL)

var string G_CSD = "Change in State of Delivery"
showCSD       = input.bool(true, "Show CSD Arrows", group=G_CSD)

var string G_HA = "Heikin Ashi MA Filter"
showHAMA      = input.bool(true, "Show HA Moving Average", group=G_HA)
haLen         = input.int(25, "HA MA Length", minval=1, maxval=500, group=G_HA)
useHAFilter   = input.bool(true, "Use HA MA Trend Filter", group=G_HA)

var string G_SIG = "ERL Break Signals"
showSignals   = input.bool(true, "Show Break Signals", group=G_SIG)

// ==========================================
// 2. HEIKIN ASHI MA
// ==========================================
haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (nz(haOpen[1]) + nz(haClose[1])) / 2
haHigh = math.max(high, math.max(haOpen, haClose))
haLow  = math.min(low, math.min(haOpen, haClose))

haAvg = (haOpen + haHigh + haLow + haClose) / 4
HA_MA = ta.wma(haAvg, haLen)

bool haBullish = HA_MA > HA_MA[1]   // Yeşil
bool haBearish = HA_MA < HA_MA[1]   // Kırmızı

haMAColor = haBullish ? color.green : color.red
plot(showHAMA ? HA_MA : na, title="Heikin Ashi MA", color=haMAColor, linewidth=2)

// ==========================================
// 3. FVG
// ==========================================
type FVG_Data
    box fvgBox
    float top
    float bottom
    bool isBull
    bool mitigated

var FVG_Data[] bullFVG_Array = array.new<FVG_Data>()
var FVG_Data[] bearFVG_Array = array.new<FVG_Data>()

isBullFVG = low > high[2]
isBearFVG = high < low[2]

if showFVG and barstate.isconfirmed
    if isBullFVG
        bTop = low
        bBottom = high[2]
        newBox = box.new(left=bar_index-2, top=bTop, right=bar_index+5, bottom=bBottom, 
                         bgcolor=fvgColorBull, border_color=color.new(color.green, 70))
        array.push(bullFVG_Array, FVG_Data.new(newBox, bTop, bBottom, true, false))

    if isBearFVG
        bTop = low[2]
        bBottom = high
        newBox = box.new(left=bar_index-2, top=bTop, right=bar_index+5, bottom=high, 
                         bgcolor=fvgColorBear, border_color=color.new(color.red, 70))
        array.push(bearFVG_Array, FVG_Data.new(newBox, bTop, bBottom, false, false))

if array.size(bullFVG_Array) > 0
    for i = array.size(bullFVG_Array) - 1 to 0
        FVG_Data item = array.get(bullFVG_Array, i)
        if not item.mitigated
            if removeFilled and low <= item.top
                item.mitigated := true
                box.delete(item.fvgBox)

if array.size(bearFVG_Array) > 0
    for i = array.size(bearFVG_Array) - 1 to 0
        FVG_Data item = array.get(bearFVG_Array, i)
        if not item.mitigated
            if removeFilled and high >= item.bottom
                item.mitigated := true
                box.delete(item.fvgBox)

// ==========================================
// 4. ERL + KIRILIM
// ==========================================
type Swing_Line
    line lineId
    label labelId
    float priceLevel
    bool isHigh
    bool broken

var Swing_Line[] activeHighLines = array.new<Swing_Line>()
var Swing_Line[] activeLowLines  = array.new<Swing_Line>()

pHi = ta.pivothigh(high, swingLen, swingLen)
pLo = ta.pivotlow(low, swingLen, swingLen)

if not na(pHi) and showERL
    int startIdx = bar_index - swingLen
    line l = line.new(startIdx, pHi, bar_index + 8, pHi, color=color.red, width=1, style=line.style_dashed)
    label lb = label.new(bar_index + 8, pHi, "ERL High", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_left, size=size.small)
    array.push(activeHighLines, Swing_Line.new(l, lb, pHi, true, false))
    
    if array.size(activeHighLines) > maxLines
        Swing_Line oldest = array.shift(activeHighLines)
        line.delete(oldest.lineId)
        label.delete(oldest.labelId)

if not na(pLo) and showERL
    int startIdx = bar_index - swingLen
    line l = line.new(startIdx, pLo, bar_index + 8, pLo, color=color.green, width=1, style=line.style_dashed)
    label lb = label.new(bar_index + 8, pLo, "ERL Low", color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_left, size=size.small)
    array.push(activeLowLines, Swing_Line.new(l, lb, pLo, false, false))

    if array.size(activeLowLines) > maxLines
        Swing_Line oldest = array.shift(activeLowLines)
        line.delete(oldest.lineId)
        label.delete(oldest.labelId)

bool rawBuySignal  = false
bool rawSellSignal = false

// ERL High kırılırsa → BUY
if array.size(activeHighLines) > 0
    for i = array.size(activeHighLines) - 1 to 0
        Swing_Line item = array.get(activeHighLines, i)
        if not item.broken
            if high >= item.priceLevel
                item.broken := true
                rawBuySignal := true
                line.delete(item.lineId)
                label.delete(item.labelId)
                array.remove(activeHighLines, i)
            else
                line.set_x2(item.lineId, bar_index + 4)
                label.set_x(item.labelId, bar_index + 4)

// ERL Low kırılırsa → SELL
if array.size(activeLowLines) > 0
    for i = array.size(activeLowLines) - 1 to 0
        Swing_Line item = array.get(activeLowLines, i)
        if not item.broken
            if low <= item.priceLevel
                item.broken := true
                rawSellSignal := true
                line.delete(item.lineId)
                label.delete(item.labelId)
                array.remove(activeLowLines, i)
            else
                line.set_x2(item.lineId, bar_index + 4)
                label.set_x(item.labelId, bar_index + 4)

// ==========================================
// 5. HA MA YÖN FİLTRESİ (Düzeltilmiş)
// ==========================================
bool buySignal  = rawBuySignal  and (not useHAFilter or haBullish)
bool sellSignal = rawSellSignal and (not useHAFilter or haBearish)

// ==========================================
// 6. CSD (görsel)
// ==========================================
var float lastDownCloseOpen = na
if close < open
    lastDownCloseOpen := open
rawBullCSD = not na(lastDownCloseOpen) and ta.crossover(close, lastDownCloseOpen)

var float lastUpCloseOpen = na
if close > open
    lastUpCloseOpen := open
rawBearCSD = not na(lastUpCloseOpen) and ta.crossunder(close, lastUpCloseOpen)

plotshape(showCSD and rawBullCSD, title="Bull CSD", style=shape.arrowup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(showCSD and rawBearCSD, title="Bear CSD", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.tiny)

// ==========================================
// 7. SİNYALLER
// ==========================================
plotshape(showSignals and buySignal,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.lime, textcolor=color.black, text="BUY", size=size.normal)
plotshape(showSignals and sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.fuchsia, textcolor=color.white, text="SELL", size=size.normal)

alertcondition(buySignal,  title="BUY Signal",  message="ERL High Break + HA Bullish → BUY")
alertcondition(sellSignal, title="SELL Signal", message="ERL Low Break + HA Bearish → SELL")
````
