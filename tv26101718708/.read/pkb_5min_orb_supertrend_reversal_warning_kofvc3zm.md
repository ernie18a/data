# PKB- 5-Min ORB + SuperTrend + Reversal Warning 

- url: https://www.tradingview.com/script/kOfvC3ZM-PKB-5-Min-ORB-SuperTrend-Reversal-Warning/
- type: indicator
- pine_id: PUB;8381f82b526144aa99f0ef2e627551d5
- version: 1.0

## Description

5-min ORB stratgey.  I hope this helps anyone who uses it and needs more visuals.  

Plots the exact 5-Min Opening Range automatically.  
Adds SuperTrend (ATR trailing stop) — the #1 tool pros use to avoid holding losers too long while still giving winners room to breathe (so you don’t sell right before the turnaround).  
VWAP for quick bias.  
Visual + alert system so you know exactly when to exit mechanically (no more emotion).

SuperTrend is perfect: It trails price using ATR → it stays green during normal pullbacks (you don’t panic-sell).  
It only flips red when momentum has actually shifted → you exit before big losses, but not too early.  
When your trade is red, watch the SuperTrend line: if price is still above it (on a long), hold — the reversal is likely coming. Only exit on the flip.

## Source Code

````pine
//@version=5
indicator("5-Min ORB + SuperTrend + Reversal Warning 📈", shorttitle="ORB + ST + Warning", overlay=true, precision=2)

// ── Inputs ─────────────────────────────────────
showORB      = input.bool(true,  "Show 5-Min Opening Range", group="Opening Range")
atrLength    = input.int(10,    "SuperTrend ATR Length", minval=1, group="SuperTrend")
factor       = input.float(3.0, "SuperTrend Factor", minval=0.1, step=0.1, group="SuperTrend")
warningDist  = input.float(0.6, "Reversal Warning Distance (ATR multiplier)", minval=0.1, step=0.1, group="Reversal Warning")

// ── 5-Min Opening Range ──
newDay = ta.change(time("D"))
var float orHigh = na
var float orLow  = na

if newDay
    orHigh := high
    orLow  := low

plot(showORB ? orHigh : na, "ORB High", color=color.red,   linewidth=2, style=plot.style_linebr)
plot(showORB ? orLow  : na, "ORB Low",  color=color.green, linewidth=2, style=plot.style_linebr)

// ── VWAP ──
vwapValue = ta.vwap(hl2)
plot(vwapValue, "VWAP", color=color.purple, linewidth=2)

// ── SuperTrend ──
atr = ta.atr(atrLength)
upperBand = hl2 - (factor * atr)
lowerBand = hl2 + (factor * atr)

var float superTrend = na
var int direction = 1

if direction[1] == 1
    superTrend := math.max(upperBand, nz(superTrend[1]))
    if close < superTrend
        direction := -1
        superTrend := lowerBand
else
    superTrend := math.min(lowerBand, nz(superTrend[1]))
    if close > superTrend
        direction := 1
        superTrend := upperBand

stColor = direction == 1 ? color.lime : color.red
plot(superTrend, "SuperTrend Trail", color=stColor, linewidth=3, style=plot.style_linebr)

// ── Reversal Warning Logic ──
distToST = direction == 1 ? (close - superTrend) / atr : (superTrend - close) / atr
warningTriggered = distToST <= warningDist and distToST > 0

// ── Plots & Background ──
bgcolor(direction == 1 ? color.new(color.green, 92) : color.new(color.red, 92))
bgcolor(warningTriggered ? color.new(color.yellow, 85) : na, title="Reversal Warning Background")

// ── Reversal Warning Label ──
var label warnLabel = na
if warningTriggered and barstate.isconfirmed
    label.delete(warnLabel)
    warnLabel := label.new(bar_index, high * 1.005, "⚠️ REVERSAL WARNING\nTighten stop or take profit!", 
                           color=color.yellow, textcolor=color.black, style=label.style_label_down, 
                           size=size.normal, yloc=yloc.abovebar)

// ── Info Table ──
var table info = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 85), border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "Trend", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, direction == 1 ? "BULLISH (Hold)" : "BEARISH (Exit)", 
               text_color = direction == 1 ? color.lime : color.red, text_size=size.normal)
    
    table.cell(info, 0, 1, "5m OR High", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(orHigh, "#.##"), text_color=color.red)
    
    table.cell(info, 0, 2, "5m OR Low", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(orLow, "#.##"), text_color=color.green)
    
    table.cell(info, 0, 3, "SuperTrend", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, direction == 1 ? "Bullish Trail" : "Bearish Flip", 
               text_color = direction == 1 ? color.lime : color.red)
    
    table.cell(info, 0, 4, "Distance to ST", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, str.tostring(distToST, "0.00") + " ATR", text_color=color.white)
    
    table.cell(info, 0, 5, "🟡 Warning", text_color=color.yellow, text_size=size.normal)
    table.cell(info, 1, 5, "Close to flip → Take profit / Tighten stop", text_color=color.white, text_size=size.small)
    
    table.cell(info, 0, 6, "🔴 Exit", text_color=color.red, text_size=size.normal)
    table.cell(info, 1, 6, "SuperTrend flipped → EXIT position", text_color=color.white, text_size=size.small)

// ── Alerts ──
alertcondition(ta.change(direction) and direction == -1, "SuperTrend Bearish Flip", "🚨 SUPER TREND FLIPPED BEARISH → EXIT LONG NOW")
alertcondition(warningTriggered, "Reversal Warning", "⚠️ REVERSAL WARNING → Price nearing SuperTrend. Consider taking profit!")
````
