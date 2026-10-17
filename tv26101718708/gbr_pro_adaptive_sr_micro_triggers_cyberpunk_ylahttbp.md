# GBR Pro Adaptive S/R + Micro Triggers [Cyberpunk]

- url: https://www.tradingview.com/script/YlAHtTbp-GBR-Pro-Adaptive-S-R-Micro-Triggers-Cyberpunk/
- type: indicator
- pine_id: PUB;b3ee707b24f741beb4d6fd1d61296601
- version: 1.0

## Description

The GBR Pro Adaptive S/R is the ultimate structural engine designed specifically for professional prop firm scalpers. It solves the two biggest problems in day trading: visual chart clutter and entry hesitation.

By combining a strict Macro S/R filter with lightning-fast Micro Breakout triggers (Smart Money / BoS logic), this indicator gives you the exact boundaries of the battlefield and pulls the trigger for you when the structure breaks.

🔥 Pro-Tier Features:

Macro Anti-Clutter Engine: Hard-capped at a maximum of 4 active Resistance (UV Purple) and 4 active Support (Cyan Blue) levels. Dynamic floating price labels keep your candlesticks fully visible.

Micro Ghost Triggers (BoS): The engine continuously tracks immediate local pivots using faint, dotted gray lines. The moment a candle breaks these micro-structures, the ghost line is consumed, and a permanent, high-precision BUY ▲ or SELL ▼ signal is printed on the chart (fully visible for historical backtesting).

Institutional Aesthetic: Utilizing the signature FreeLab Cyberpunk color palette to drastically reduce eye strain during intensive 1m-5m scalping sessions.

Minimalist HUD Dashboard: A clean radar in the bottom right corner tracks your immediate macro boundaries in real-time.

🎯 How to execute:
Do not trade in a vacuum. Use the thick Cyan and Purple lines to understand the macro framework. When the price approaches these key structural zones, wait for the Micro Ghost Triggers to confirm the reversal or continuation with a printed Breakout signal, then execute your trade with confidence.

## Source Code

````pine
//@version=6
indicator("GBR Pro Adaptive S/R [Cyberpunk]", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// 1. SETTINGS
// ==========================================
grp1 = "Macro Zones"
pivotLen  = input.int(15, title="Macro Pivot Length", group=grp1)
maxLevels = input.int(4, title="Max Active Levels", group=grp1)

grp2 = "Micro Ghost Triggers"
trigLen = input.int(5, title="Trigger Pivot Length", group=grp2)

colRes = color.new(#B200FF, 0) // UV Lila
colSup = color.new(#00E5FF, 0) // Cián Kék
colGhost = color.new(color.gray, 50) // Szellemvonal

// ==========================================
// 2. MACRO LOGIC (Vastag Falak)
// ==========================================
type Level
    float price
    line ln
    label lbl

var array<Level> resLevels = array.new<Level>()
var array<Level> supLevels = array.new<Level>()

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph) and bar_index > pivotLen
    ln = line.new(bar_index[pivotLen], ph, bar_index, ph, color=colRes, style=line.style_solid, width=2)
    lbl = label.new(bar_index, ph, str.tostring(ph, "#.##"), color=color.new(color.white, 100), textcolor=colRes, style=label.style_none, size=size.small)
    resLevels.push(Level.new(ph, ln, lbl))
    if resLevels.size() > maxLevels
        popped = resLevels.shift()
        line.delete(popped.ln)
        label.delete(popped.lbl)

if not na(pl) and bar_index > pivotLen
    ln = line.new(bar_index[pivotLen], pl, bar_index, pl, color=colSup, style=line.style_solid, width=2)
    lbl = label.new(bar_index, pl, str.tostring(pl, "#.##"), color=color.new(color.white, 100), textcolor=colSup, style=label.style_none, size=size.small)
    supLevels.push(Level.new(pl, ln, lbl))
    if supLevels.size() > maxLevels
        popped = supLevels.shift()
        line.delete(popped.ln)
        label.delete(popped.lbl)

var float closestRes = na
var float closestSup = na
closestRes := na
closestSup := na
minResDist = 999999.9
minSupDist = 999999.9

if resLevels.size() > 0
    for i = resLevels.size() - 1 to 0
        lvl = resLevels.get(i)
        line.set_x2(lvl.ln, bar_index)
        x1 = line.get_x1(lvl.ln)
        mid_x = math.round((x1 + bar_index) / 2)
        label.set_xy(lvl.lbl, mid_x, lvl.price)
        
        if close > lvl.price
            line.delete(lvl.ln)
            label.delete(lvl.lbl)
            resLevels.remove(i)
        else
            dist = lvl.price - close
            if dist > 0 and dist < minResDist
                minResDist := dist
                closestRes := lvl.price

if supLevels.size() > 0
    for i = supLevels.size() - 1 to 0
        lvl = supLevels.get(i)
        line.set_x2(lvl.ln, bar_index)
        x1 = line.get_x1(lvl.ln)
        mid_x = math.round((x1 + bar_index) / 2)
        label.set_xy(lvl.lbl, mid_x, lvl.price)
        
        if close < lvl.price
            line.delete(lvl.ln)
            label.delete(lvl.lbl)
            supLevels.remove(i)
        else
            dist = close - lvl.price
            if dist > 0 and dist < minSupDist
                minSupDist := dist
                closestSup := lvl.price

// ==========================================
// 3. MICRO GHOST LOGIC (Az új, bombabiztos motor)
// ==========================================
mph = ta.pivothigh(high, trigLen, trigLen)
mpl = ta.pivotlow(low, trigLen, trigLen)

var float microRes = na
var float microSup = na

if not na(mph)
    microRes := mph
if not na(mpl)
    microSup := mpl

bool buySig = false
bool sellSig = false

// Törés figyelése
if not na(microRes) and close > microRes
    buySig := true
    microRes := na // Vonal resetelése a törés után

if not na(microSup) and close < microSup
    sellSig := true
    microSup := na // Vonal resetelése a törés után

// Szellemvonalak rajzolása (Pöttyözött stílus)
plot(microRes, color=colGhost, style=plot.style_circles, linewidth=1, title="Ghost Res")
plot(microSup, color=colGhost, style=plot.style_circles, linewidth=1, title="Ghost Sup")

// Jelek rajzolása a chartra
plotshape(buySig, title="BUY", style=shape.labelup, location=location.belowbar, color=color.new(#00FF00, 85), text="BUY ▲", textcolor=color.new(#00FF00, 0), size=size.tiny)
plotshape(sellSig, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(#FF0033, 85), text="SELL ▼", textcolor=color.new(#FF0033, 0), size=size.tiny)

// ==========================================
// 4. RADAR
// ==========================================
var table dash = table.new(position.bottom_right, 2, 3, frame_color=color.new(color.gray, 80), frame_width=1, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    table.cell(dash, 0, 0, "GBR RADAR", text_color=color.white, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 0, "LEVEL", text_color=color.white, bgcolor=color.new(color.black, 40))
    table.cell(dash, 0, 1, "Resistance", text_color=colRes, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 1, na(closestRes) ? "N/A" : str.tostring(closestRes, "#.##"), text_color=colRes, bgcolor=color.new(color.black, 40))
    table.cell(dash, 0, 2, "Support", text_color=colSup, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 2, na(closestSup) ? "N/A" : str.tostring(closestSup, "#.##"), text_color=colSup, bgcolor=color.new(color.black, 40))
````
