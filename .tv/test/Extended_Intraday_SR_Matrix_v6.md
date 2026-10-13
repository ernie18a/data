<!-- tradingview-pine-id: PUB;c556195de1ce4bceb6d438f26928b355 -->
<!-- tradingviewscripts-format: 1 -->
# Extended Intraday S/R Matrix (v6)

Source: https://www.tradingview.com/script/tTncKOId-Extended-Intraday-S-R-Matrix-v6/

## Description

Work in progress, but this uses VWAP and real time data to determine entry and exit with 1 standard deviation probability and gives support and resistance, all based on ATR and Volatility.

---

## Source Code

````pine
//@version=6
indicator("Extended Intraday S/R Matrix (v6)", overlay=true)

// --- INPUTS ---
atrLength   = input.int(14, title="ATR Length")
multiplier  = input.float(2.0, title="ATR Multiplier")
pivotPeriod = input.int(10, title="S/R Pivot Lookback Length")

// --- CALCULATIONS ---
vwapValue   = ta.vwap
atrValue    = ta.atr(atrLength)
upperTarget = vwapValue + (atrValue * multiplier)
lowerFloor  = vwapValue - (atrValue * multiplier)

// --- EXTENDED SUPPORT & RESISTANCE ENGINE ---
// Find recent localized swing pivots on the active time-interval
pHi = ta.pivothigh(high, pivotPeriod, pivotPeriod)
pLo = ta.pivotlow(low, pivotPeriod, pivotPeriod)

// Maintain memory trackers for the active levels
var float activeResistance = na
var float activeSupport    = na

if not na(pHi)
    activeResistance := pHi
if not na(pLo)
    activeSupport := pLo

// --- DYNAMIC LINE GENERATION & SCREEN EXTENSION ---
var line lineResistance = na
var line lineSupport    = na

// Delete older lines on every new tick to prevent cluttering the historical chart background
if barstate.islast
    line.delete(lineResistance)
    line.delete(lineSupport)
    
    // Draw and extend the localized Resistance line to the right edge of the screen (Solid Red)
    if not na(activeResistance)
        lineResistance := line.new(x1=bar_index - pivotPeriod, y1=activeResistance, 
                                   x2=bar_index, y2=activeResistance, 
                                   xloc=xloc.bar_index, extend=extend.right, 
                                   color=color.red, style=line.style_solid, width=1)
                                   
    // Draw and extend the localized Support line to the right edge of the screen (Solid Green)
    if not na(activeSupport)
        lineSupport    := line.new(x1=bar_index - pivotPeriod, y1=activeSupport, 
                                   x2=bar_index, y2=activeSupport, 
                                   xloc=xloc.bar_index, extend=extend.right, 
                                   color=color.green, style=line.style_solid, width=1)

// --- PLOTTING CORE VOLATILITY MATRIX ---
// Plot the core VWAP anchor as a thick solid blue line
plot(vwapValue, title="Real-Time VWAP Anchor", color=color.blue, linewidth=2)

// Plot volatility target band as a green dashed/broken line
plot(upperTarget, title="Intraday Long Profit Target", color=color.green, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)

// Plot volatility floor band as a red dashed/broken line
plot(lowerFloor, title="Intraday Risk Floor", color=color.red, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)

// --- VISUAL RIGHT-EDGE PRICE LABELS ---
var label lblUpper  = na
var label lblVWAP   = na
var label lblResist = na
var label lblSupp   = na

if barstate.islast
    label.delete(lblUpper)
    label.delete(lblVWAP)
    label.delete(lblResist)
    label.delete(lblSupp)
    
    lblUpper  := label.new(x=bar_index + 2, y=upperTarget, text="Volatility Target: " + str.tostring(upperTarget, "#.##"), color=color.green, textcolor=color.white, style=label.style_label_left)
    lblVWAP   := label.new(x=bar_index + 2, y=vwapValue,   text="VWAP Anchor: " + str.tostring(vwapValue, "#.##"),       color=color.blue,  textcolor=color.white, style=label.style_label_left)
    
    if not na(activeResistance)
        lblResist := label.new(x=bar_index + 2, y=activeResistance, text="Intraday Resistance: " + str.tostring(activeResistance, "#.##"), color=color.red, textcolor=color.white, style=label.style_label_left)
    if not na(activeSupport)
        lblSupp   := label.new(x=bar_index + 2, y=activeSupport,    text="Intraday Support: " + str.tostring(activeSupport, "#.##"),       color=color.green, textcolor=color.white, style=label.style_label_left)
````
