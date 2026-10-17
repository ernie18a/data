# RTY Polarity Zones v2

- url: https://www.tradingview.com/script/1OaBTzOi-RTY-Polarity-Zones-v2/
- type: indicator
- pine_id: PUB;468887aee5c44d43ad941302ce7c4950
- version: 1.0

## Description

RTY Polarity Zones v2- Z1 and Z2 polarity Zones for retracement and potential bounce zones

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OriginalDuval

//@version=6
//@version=5
indicator("RTY Polarity Zones v2", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── Level Settings ───
baseLevel    = input.int(1800, "Base Level", step=100, group="Levels")
topLevel     = input.int(2800, "Top Level", step=100, group="Levels")
levelInterval= input.int(100, "Level Interval", minval=10, step=10, group="Levels")
majorInterval= input.int(1000, "Major Level Interval (Emphasized)", minval=100, step=100, group="Levels")
showLabels   = input.bool(true, "Show Labels", group="Levels")

// ─── Zone Distances (RTY: 100pt levels, ±20 Z1, +21 to +50 Z2) ───
z1Bot = input.float(20.0, "Z1 Bottom Distance (below level)", minval=1, step=1, group="Zone Distances")
z1Top = input.float(20.0, "Z1 Top Distance (above level)", minval=1, step=1, group="Zone Distances")
z2Top = input.float(50.0, "Z2 Top / Breakthrough Distance", minval=1, step=1, group="Zone Distances")

// ─── Zone Colors ───
z1Clr = input.color(#a67df5, "Z1 Fill Color", group="Zone 1 (Approach)")
z1Op  = input.int(82, "Z1 Transparency", minval=0, maxval=100, group="Zone 1 (Approach)")

z2Clr = input.color(#f0a030, "Z2 Fill Color", group="Zone 2 (Deep)")
z2Op  = input.int(82, "Z2 Transparency", minval=0, maxval=100, group="Zone 2 (Deep)")

// ─── Level Line (Standard) ───
lvlClr   = input.color(#22c07a, "Level Line Color", group="Level Line (Standard)")
lvlOp    = input.int(30, "Level Line Transp", minval=0, maxval=100, group="Level Line (Standard)")
lvlWidth = input.int(2, "Level Line Width", minval=1, maxval=5, group="Level Line (Standard)")

// ─── Major Level Line (1000-point emphasis) ───
majClr   = input.color(#ff3860, "Major Level Color", group="Major Level Line")
majOp    = input.int(0, "Major Level Transp", minval=0, maxval=100, group="Major Level Line")
majWidth = input.int(4, "Major Level Width", minval=1, maxval=10, group="Major Level Line")
majStyle = input.string("Solid", "Major Level Style", options=["Solid", "Dashed", "Dotted"], group="Major Level Line")
majGlow  = input.bool(true, "Add Glow Effect to Major Levels", group="Major Level Line")
majBgClr = input.color(#ff3860, "Major Level Background Tint", group="Major Level Line")
majBgOp  = input.int(92, "Major Background Transp", minval=0, maxval=100, group="Major Level Line")

// ─── Breakthrough Line (Z2 Top) ───
z2lClr   = input.color(#f0a030, "Breakthrough Line Color", group="Zone Lines")
z2lOp    = input.int(50, "Breakthrough Transp", minval=0, maxval=100, group="Zone Lines")
z2lWidth = input.int(1, "Breakthrough Width", minval=1, maxval=5, group="Zone Lines")
z2lStyle = input.string("Dashed", "Breakthrough Style", options=["Solid", "Dashed", "Dotted"], group="Zone Lines")

// ─── Zone Bottom Line (Z1 Bottom) ───
zbClr    = input.color(#a67df5, "Zone Bottom Line Color", group="Zone Lines")
zbOp     = input.int(50, "Zone Bottom Transp", minval=0, maxval=100, group="Zone Lines")
zbWidth  = input.int(1, "Zone Bottom Width", minval=1, maxval=5, group="Zone Lines")
zbStyle  = input.string("Dashed", "Zone Bottom Style", options=["Solid", "Dashed", "Dotted"], group="Zone Lines")

// ─── Label Colors ───
z1LblClr  = input.color(#a67df5, "Z1 Label Color", group="Labels")
z2LblClr  = input.color(#f0a030, "Z2 Label Color", group="Labels")
lvlLblClr = input.color(#22c07a, "Level Label Color", group="Labels")
majLblClr = input.color(#ff3860, "Major Level Label Color", group="Labels")

// ─── Helpers ───
getStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

isMajorLevel(float lvl) =>
    math.abs(lvl - math.round(lvl / majorInterval) * majorInterval) < 0.01

// ─── State Tracking ───
numLevels = math.floor((topLevel - baseLevel) / levelInterval) + 1

var bool[] activated    = array.new_bool(numLevels, false)
var int[]  activBar     = array.new_int(numLevels, na)
var int[]  activTime    = array.new_int(numLevels, na)

// ─── Activation Logic ───
for i = 0 to numLevels - 1
    if not array.get(activated, i)
        lf = float(baseLevel + i * levelInterval)
        zb = lf - z1Bot
        
        if high >= zb
            array.set(activated, i, true)
            array.set(activBar, i, bar_index)
            array.set(activTime, i, time)

// ─── Drawing ───
var box[]   drawnBoxes  = array.new_box()
var line[]  drawnLines  = array.new_line()
var label[] drawnLabels = array.new_label()

if barstate.islast
    for b in drawnBoxes
        box.delete(b)
    for ln in drawnLines
        line.delete(ln)
    for lb in drawnLabels
        label.delete(lb)
    array.clear(drawnBoxes)
    array.clear(drawnLines)
    array.clear(drawnLabels)

    futureTime = time + (time - time[1]) * 80

    for i = 0 to numLevels - 1
        if array.get(activated, i)
            lf    = float(baseLevel + i * levelInterval)
            sTime = array.get(activTime, i)
            isMajor = isMajorLevel(lf)
            
            if not na(sTime)
                // ── Z1 Box ──
                array.push(drawnBoxes, box.new(
                     sTime, lf + z1Top, futureTime, lf - z1Bot,
                     xloc=xloc.bar_time, 
                     border_color=color.new(z1Clr, 95), 
                     bgcolor=color.new(z1Clr, z1Op), 
                     border_width=0, 
                     extend=extend.right))
                
                // ── Z2 Box ──
                array.push(drawnBoxes, box.new(
                     sTime, lf + z2Top, futureTime, lf + z1Top + 1,
                     xloc=xloc.bar_time, 
                     border_color=color.new(z2Clr, 95), 
                     bgcolor=color.new(z2Clr, z2Op), 
                     border_width=0, 
                     extend=extend.right))
                
                // ── Major Level Background Highlight ──
                if isMajor
                    array.push(drawnBoxes, box.new(
                         sTime, lf + z2Top + 30, futureTime, lf - z1Bot - 30,
                         xloc=xloc.bar_time, 
                         border_color=color.new(majBgClr, 100), 
                         bgcolor=color.new(majBgClr, majBgOp), 
                         border_width=0, 
                         extend=extend.right))
                
                // ── Level Line (major or standard) ──
                if isMajor
                    // Glow effect: draw thicker, more transparent line behind
                    if majGlow
                        array.push(drawnLines, line.new(
                             sTime, lf, futureTime, lf,
                             xloc=xloc.bar_time, 
                             color=color.new(majClr, 70), 
                             width=majWidth + 4, 
                             extend=extend.right))
                    // Main major line
                    array.push(drawnLines, line.new(
                         sTime, lf, futureTime, lf,
                         xloc=xloc.bar_time, 
                         color=color.new(majClr, majOp), 
                         width=majWidth, 
                         style=getStyle(majStyle),
                         extend=extend.right))
                else
                    array.push(drawnLines, line.new(
                         sTime, lf, futureTime, lf,
                         xloc=xloc.bar_time, 
                         color=color.new(lvlClr, lvlOp), 
                         width=lvlWidth, 
                         extend=extend.right))
                
                // ── Zone Bottom Line ──
                array.push(drawnLines, line.new(
                     sTime, lf - z1Bot, futureTime, lf - z1Bot,
                     xloc=xloc.bar_time, 
                     color=color.new(zbClr, zbOp), 
                     width=zbWidth, 
                     style=getStyle(zbStyle),
                     extend=extend.right))
                
                // ── Breakthrough Line ──
                array.push(drawnLines, line.new(
                     sTime, lf + z2Top, futureTime, lf + z2Top,
                     xloc=xloc.bar_time, 
                     color=color.new(z2lClr, z2lOp), 
                     width=z2lWidth, 
                     style=getStyle(z2lStyle),
                     extend=extend.right))
                
                // ── Labels ──
                if showLabels
                    nobg = color.new(color.white, 100)
                    lvlStr = str.tostring(baseLevel + i * levelInterval)
                    
                    // Level name label (larger and emphasized for major levels)
                    array.push(drawnLabels, label.new(
                         futureTime, lf, 
                         isMajor ? "★ " + lvlStr + " ★" : lvlStr,
                         xloc=xloc.bar_time, color=nobg, 
                         textcolor=isMajor ? majLblClr : lvlLblClr, 
                         style=label.style_label_left, 
                         size=isMajor ? size.large : size.normal))
                    
                    // Z1 label
                    z1Mid = lf - z1Bot + (z1Bot + z1Top) / 2
                    array.push(drawnLabels, label.new(
                         futureTime, z1Mid, "Z1",
                         xloc=xloc.bar_time, color=nobg, 
                         textcolor=z1LblClr, 
                         style=label.style_label_left, 
                         size=size.small))
                    
                    // Z2 label
                    z2Mid = lf + z1Top + (z2Top - z1Top) / 2
                    array.push(drawnLabels, label.new(
                         futureTime, z2Mid, "Z2",
                         xloc=xloc.bar_time, color=nobg, 
                         textcolor=z2LblClr, 
                         style=label.style_label_left, 
                         size=size.small))
````
