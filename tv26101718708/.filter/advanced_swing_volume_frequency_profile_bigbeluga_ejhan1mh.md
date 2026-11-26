# Advanced Swing Volume & Frequency Profile [BigBeluga]

- url: https://www.tradingview.com/script/EJhan1MH-Advanced-Swing-Volume-Frequency-Profile-BigBeluga/
- type: indicator
- pine_id: PUB;f233480e7ad64a2793338d7bf89628ae
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]Advanced Swing Volume & Frequency Profile [BigBeluga][/b] is an indicator that builds a horizontal profile of trading activity between the two most recent swing points, plotting both Volume Profile and Frequency Profile side by side. It solves the problem of measuring how much volume traded at each price — and how often price visited each level — within a specific swing, helping traders spot true Points of Control rather than relying on fixed-session profiles.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The indicator anchors a profile to the last two swing points, bins price into ATR-based rows, and renders two mirrored profiles:

[b]1 — Swing Detection & Anchoring[/b]
[list]
[*] [b]Swing Points:[/b] Uses the [i]Swing Length[/i] lookback to locate the most recent highest high and lowest low, labeling them as S1 and S2.
[*] [b]Anchor Range:[/b] The profile is drawn between the two swing points and extends to the current bar plus the [i]Profile Offset Bars[/i].
[*] [b]Resolution:[/b] The vertical range is divided into price rows using ATR (100) multiplied by the [i]Resolution Multiplier[/i].
[/list]

[b]2 — Volume & Frequency Binning[/b]
[list]
[*] [b]Volume Profile:[/b] Accumulates traded volume into each price row for every bar inside the swing range.
[*] [b]Frequency Profile:[/b] Counts how many bars touched each price row, measuring time spent at each level.
[*] [b]Points of Control:[/b] The row with the highest volume becomes the Volume POC, and the row with the most touches becomes the Frequency POC.
[/list]

[b]3 — Profile Rendering[/b]
[list]
[*] [b]Right-Side Volume Bars:[/b] Volume boxes extend to the right of the range, with width proportional to volume and color intensity scaled to the maximum.
[*] [b]Left-Side Frequency Bars:[/b] Frequency boxes extend to the left, with width proportional to visit count and matching color scaling.
[*] [b]Gradient Grid Lines:[/b] Dotted horizontal lines span the range, with color intensity reflecting the selected [i]Grid Gradient Source[/i].
[*] [b]POC Highlights:[/b] Dedicated boxes mark the Volume and Frequency POCs with their values labeled directly on the chart.
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond visualizing activity distribution, the indicator can be applied in several ways:

[list=1]
[*] [b]Spot Value Areas:[/b] Use the Volume POC to identify the price level with the most traded volume — a natural magnet and support/resistance zone.
[*] [b]Spot High-Interest Levels:[/b] Use the Frequency POC to find the price where the market spent the most time — often a consolidation or acceptance level.
[*] [b]Compare Volume vs Frequency:[/b] When the two POCs sit at different levels, it reveals where big trades occurred versus where price simply lingered.
[*] [b]Trade Swing Ranges:[/b] Use the profile shape to judge whether the swing was balanced or skewed, and position entries near the POC rows.
[*] [b]Switch Gradient Source:[/b] Toggle [i]Grid Gradient Source[/i] to recolor the grid based on Volume or Frequency, depending on which metric matters more.
[*] [b]Declutter the View:[/b] Turn off grid lines or individual POC boxes to focus on just the profiles.
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Draws Volume and Frequency profiles side by side in the same view, letting traders compare both metrics instantly.
[*] Anchors the profile to the most recent swing range instead of a fixed session or lookback window.
[*] Uses ATR-based binning so resolution auto-adapts to volatility without manual adjustment.
[*] Fully customizable colors, profile width, offset, and display toggles to match any chart style.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Advanced Swing Volume & Frequency Profile [BigBeluga]", overlay = true, max_boxes_count = 500, max_bars_back = 5000, max_lines_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
swLen   = input.int(100, "Swing Length", minval=1, group="Swing Settings", tooltip="Lookback period used to find highest/lowest swing points.")
profTp  = input.string("Volume Profile", "Grid Gradient Source", options = ["Volume Profile", "Frequency Profile"], group="Profile Settings")
atrLen  = 100
atrMlt  = input.float(0.4, "Resolution Multiplier", minval=0.1, step=0.1, group="Profile Settings")
prWdth  = input.float(0.2, "Profile Width Factor", minval=0.05, maxval=1.0, step=0.05, group="Profile Settings")
rtOff   = input.int(5, "Profile Offset Bars", minval=0, group="Profile Settings")

shwGrd  = input.bool(true, "Show Grid Lines", group="Grid Settings")
shwVPc  = input.bool(true, "Show Volume POC Box", group="POC Settings")
shwFPc  = input.bool(true, "Show Frequency POC Box", group="POC Settings")

volCol  = input.color(color.blue, "Volume Profile Color", group="Colors")
frqCol  = input.color(color.orange, "Frequency Profile Color", group="Colors")
vPocCl  = input.color(color.blue, "Volume POC Color", group="Colors")
fPocCl  = input.color(color.orange, "Frequency POC Color", group="Colors")
// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
H = ta.highest(swLen)
L = ta.lowest(swLen)

pivH = high[1] == H[1] and high < H 
pivL = low[1] == L[1] and low > L

var dir = false 

if high == H 
    dir := true
if low == L 
    dir := false

var lStgV = close 
var lStgI = bar_index 
var fStgV = close 
var fStgI = bar_index 
var sStgV = close 
var sStgI = bar_index 

switch 
    pivH => lStgV := high[1], lStgI := bar_index[1]
    pivL => lStgV := low[1], lStgI := bar_index[1]

if dir != dir[1]
    sStgV := lStgV
    sStgI := lStgI

switch
    not dir and low == L  => fStgV := low, fStgI := bar_index
    dir and high == H  => fStgV := high, fStgI := bar_index

type str
    label lbl1 
    label lbl2 
    label cir1 
    label cir2 
    array<line> grdLns 
    array<box>  volBxs 
    array<box>  frqBxs 
    box         vPocBx
    box         fPocBx

var slots = str.new(na, na, na, na, array.new<line>(), array.new<box>(), array.new<box>(), na, na)

atr = ta.atr(atrLen) * atrMlt
// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if barstate.islast
    if not na(slots.lbl1)
        label.delete(slots.lbl1)
    if not na(slots.lbl2)
        label.delete(slots.lbl2)
    if not na(slots.cir1)
        label.delete(slots.cir1)
    if not na(slots.cir2)
        label.delete(slots.cir2)

    style1 = fStgV > sStgV ? label.style_label_down : label.style_label_up
    style2 = fStgV < sStgV ? label.style_label_down : label.style_label_up

    slots.lbl1 := label.new(fStgI, fStgV, text="S2", style=style1, color=color(na), textcolor=chart.fg_color)
    slots.lbl2 := label.new(sStgI, sStgV, text="S1", style=style2, color=color(na), textcolor=chart.fg_color)
    
    slots.cir1 := label.new(fStgI, fStgV, text="", style=label.style_circle, color=color.rgb(33, 149, 243, 50), size=size.tiny)
    slots.cir2 := label.new(sStgI, sStgV, text="", style=label.style_circle, color=color.rgb(33, 149, 243, 50), size=size.tiny)

    lftIdx = math.min(fStgI, sStgI)
    endIdx = bar_index + rtOff
    lkback = endIdx - lftIdx

    top = math.max(fStgV, sStgV)
    bot = math.min(fStgV, sStgV)

    range_ = (top - bot)
    binSz = math.max(1, int(range_ / atr))

    if array.size(slots.grdLns) > 0
        for l in slots.grdLns
            line.delete(l)
        array.clear(slots.grdLns)

    if array.size(slots.volBxs) > 0
        for b in slots.volBxs
            box.delete(b)
        array.clear(slots.volBxs)

    if array.size(slots.frqBxs) > 0
        for b in slots.frqBxs
            box.delete(b)
        array.clear(slots.frqBxs)

    if not na(slots.vPocBx)
        box.delete(slots.vPocBx)
    if not na(slots.fPocBx)
        box.delete(slots.fPocBx)

    // Removed 'var' so arrays resize correctly when binSz changes
    bVols = array.new<float>(binSz + 1, 0.0)
    bCnts = array.new<int>(binSz + 1, 0)

    for i = lftIdx to bar_index
        h_val = high[bar_index - i]
        l_val = low[bar_index - i]
        v_val = nz(volume[bar_index - i], 1.0)

        for b = 0 to binSz
            bBot = bot + (b * atr)
            bTop = bBot + atr
            if math.max(l_val, bBot) <= math.min(h_val, bTop)
                array.set(bVols, b, array.get(bVols, b) + v_val)
                array.set(bCnts, b, array.get(bCnts, b) + 1)

    maxVol = 0.0
    maxCnt = 0
    vPocIx = 0
    fPocIx = 0

    for b = 0 to binSz
        v = array.get(bVols, b)
        c = array.get(bCnts, b)
        
        if v > maxVol
            maxVol := v
            vPocIx := b
            
        if c > maxCnt
            maxCnt := c
            fPocIx := b

    maxVol := maxVol == 0 ? 1.0 : maxVol
    maxCnt := maxCnt == 0 ? 1 : maxCnt

    prfWd = math.max(5, int((bar_index - lftIdx) * prWdth))

    if shwGrd
        for i = 0 to binSz
            lineY = bot + (i * atr)
            
            metVal = profTp == "Volume Profile" ? array.get(bVols, i) / maxVol : float(array.get(bCnts, i)) / maxCnt
            trans = int(100 - (metVal * 100))
             
            linCol = profTp == "Volume Profile" ? color.new(volCol, trans) : color.new(frqCol, trans)
            
            nLine = line.new(lftIdx, lineY, endIdx, lineY, 
                               color = linCol, 
                               style = line.style_dotted,
                               width = 1)
            array.push(slots.grdLns, nLine)

    for i = 0 to binSz
        bBot = bot + (i * atr)
        bTop = bBot + atr
        vol = array.get(bVols, i)
        boxWd = int((vol / maxVol) * prfWd)
        
        if boxWd > 0 
            volRat = vol / maxVol
            bxTrns = int(90 - (volRat * 60))
            isPoc = (i == vPocIx)
            
            boxCol = isPoc ? color.new(vPocCl, 0) : color.new(volCol, bxTrns)
            
            newBox = box.new(endIdx, bTop, endIdx + boxWd, bBot,
                             bgcolor = boxCol,
                             border_color = chart.bg_color)
            array.push(slots.volBxs, newBox)

    for i = 0 to binSz
        bBot = bot + (i * atr)
        bTop = bBot + atr
        count = array.get(bCnts, i)
        boxWd = int((count / maxCnt) * prfWd)
        
        if boxWd > 0 
            cntRat = float(count) / maxCnt
            bxTrns = int(90 - (cntRat * 60))
            isPoc = (i == fPocIx)
            
            boxCol = isPoc ? color.new(fPocCl, 0) : color.new(frqCol, bxTrns)
            
            newBox = box.new(lftIdx - boxWd, bTop, lftIdx, bBot,
                             bgcolor = boxCol,
                             border_color = chart.bg_color)
            array.push(slots.frqBxs, newBox)

    if shwVPc
        pocBot = bot + (vPocIx * atr)
        pocTop = pocBot + atr
        vol = array.get(bVols, vPocIx)
        boxWd = int((vol / maxVol) * prfWd)
        slots.vPocBx := box.new(lftIdx, pocTop, endIdx + boxWd, pocBot,
                                   bgcolor = color.new(vPocCl, 85),
                                   border_color = na,
                                   border_width = 1, 
                                   text = "Vol: " + str.tostring(vol, "#.##"),
                                   text_color = color.white,
                                   text_size = size.small,
                                   text_halign = text.align_center,
                                   text_valign = text.align_center,
                                   force_overlay = true)

    if shwFPc
        pocBot = bot + (fPocIx * atr)
        pocTop = pocBot + atr
        count = array.get(bCnts, fPocIx)
        boxWd = int((count / maxCnt) * prfWd)
        slots.fPocBx := box.new(lftIdx - boxWd, pocTop, endIdx, pocBot,
                                    bgcolor = color.new(fPocCl, 85),
                                    border_color = na,
                                    border_width = 1, 
                                    text = "Count: " + str.tostring(count),
                                    text_color = color.white,
                                    text_size = size.small,
                                    text_halign = text.align_center,
                                    text_valign = text.align_center,
                                    force_overlay = true)
// }
````
