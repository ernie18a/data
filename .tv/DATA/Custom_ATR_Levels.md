<!-- tradingview-pine-id: PUB;e655014d6dd447e4a95d8a0d53340e6c -->
<!-- tradingviewscripts-format: 1 -->
# Custom ATR Levels

Source: https://www.tradingview.com/script/9Hs3Zkug-ATR-Levels-OVTYLR/

## Description

ATR Levels for OVTYLR-With anchored trade date for 1Day

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// Enhanced version with customizable colors, styles, and additional ATR levels
// Refactored: same inputs/behavior as before, but the 8 near-identical
// line/label blocks are replaced with a single array-driven loop.

//@version=6
indicator(title="Custom ATR Levels", shorttitle="ATR Levels", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS - Basic Settings
// ═══════════════════════════════════════════════════════════════════════════
atrLength       = input.int(14,  title="ATR Length", group="Basic Settings")
labelOffsetBars = input.int(10,  title="Label Offset (bars to the right)", minval=0, maxval=100, group="Basic Settings")
anchorTime      = input.time(timestamp("2024-01-01 00:00"), title="Trade Entry (drag on chart)", group="Basic Settings", confirm=true)

labelFontSize = input.string(defval="small", title="Label Font Size",
     options=["tiny", "small", "normal", "large", "huge"], group="Basic Settings")

var fSize = size.small
if labelFontSize == "tiny"
    fSize := size.tiny
else if labelFontSize == "small"
    fSize := size.small
else if labelFontSize == "normal"
    fSize := size.normal
else if labelFontSize == "large"
    fSize := size.large
else
    fSize := size.huge

labelTextColor = input.color(color.white, title="Label Text Color", group="Basic Settings")

// ═══════════════════════════════════════════════════════════════════════════
// PRICE LEVEL SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPriceLabel    = input.bool(true, title="Show Price Level", group="Price Level")
priceColor        = input.color(color.green, title="Line Color", group="Price Level")
priceLineStyle    = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Price Level")
priceLineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="Price Level")
priceLabelColor   = input.color(color.new(color.green, 60), title="Label Background Color", group="Price Level")

// ═══════════════════════════════════════════════════════════════════════════
// STOP LOSS (-.5 ATR) SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showStopLossLabel    = input.bool(true, title="Show Stop Loss (-.5 ATR)", group="Stop Loss (-.5 ATR)")
stopLossColor        = input.color(color.orange, title="Line Color", group="Stop Loss (-.5 ATR)")
stopLossLineStyle    = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Stop Loss (-.5 ATR)")
stopLossLineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="Stop Loss (-.5 ATR)")
stopLossLabelColor   = input.color(color.new(color.orange, 60), title="Label Background Color", group="Stop Loss (-.5 ATR)")

// ═══════════════════════════════════════════════════════════════════════════
// EMERGENCY EXIT (-2 ATR) SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showEmergencyLabel   = input.bool(false, title="Show Emergency Exit (-2 ATR)", group="Emergency Exit (-2 ATR)")
emergencyExitColor   = input.color(color.red, title="Line Color", group="Emergency Exit (-2 ATR)")
emergencyLineStyle   = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Emergency Exit (-2 ATR)")
emergencyLineWidth   = input.int(2, title="Line Width", minval=1, maxval=5, group="Emergency Exit (-2 ATR)")
emergencyLabelColor  = input.color(color.new(color.red, 60), title="Label Background Color", group="Emergency Exit (-2 ATR)")

// ═══════════════════════════════════════════════════════════════════════════
// +1 ATR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPlus1Label    = input.bool(true, title="Show +1 ATR", group="+1 ATR")
plus1Color        = input.color(color.blue, title="Line Color", group="+1 ATR")
plus1LineStyle    = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="+1 ATR")
plus1LineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="+1 ATR")
plus1LabelColor   = input.color(color.new(color.blue, 60), title="Label Background Color", group="+1 ATR")

// ═══════════════════════════════════════════════════════════════════════════
// +2 ATR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPlus2Label    = input.bool(true, title="Show +2 ATR", group="+2 ATR")
plus2Color        = input.color(color.blue, title="Line Color", group="+2 ATR")
plus2LineStyle    = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="+2 ATR")
plus2LineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="+2 ATR")
plus2LabelColor   = input.color(color.new(color.blue, 80), title="Label Background Color", group="+2 ATR")

// ═══════════════════════════════════════════════════════════════════════════
// +3 ATR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPlus3Label    = input.bool(false, title="Show +3 ATR", group="+3 ATR")
plus3Color        = input.color(color.purple, title="Line Color", group="+3 ATR")
plus3LineStyle    = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="+3 ATR")
plus3LineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="+3 ATR")
plus3LabelColor   = input.color(color.new(color.purple, 60), title="Label Background Color", group="+3 ATR")

// ═══════════════════════════════════════════════════════════════════════════
// +4 ATR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPlus4Label    = input.bool(false, title="Show +4 ATR", group="+4 ATR")
plus4Color        = input.color(color.fuchsia, title="Line Color", group="+4 ATR")
plus4LineStyle    = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="+4 ATR")
plus4LineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="+4 ATR")
plus4LabelColor   = input.color(color.new(color.fuchsia, 60), title="Label Background Color", group="+4 ATR")

// ═══════════════════════════════════════════════════════════════════════════
// +5 ATR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
showPlus5Label    = input.bool(false, title="Show +5 ATR", group="+5 ATR")
plus5Color        = input.color(color.navy, title="Line Color", group="+5 ATR")
plus5LineStyle    = input.string("Dotted", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="+5 ATR")
plus5LineWidth    = input.int(2, title="Line Width", minval=1, maxval=5, group="+5 ATR")
plus5LabelColor   = input.color(color.new(color.navy, 60), title="Label Background Color", group="+5 ATR")

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTION - Convert line style string to line.style
// ═══════════════════════════════════════════════════════════════════════════
getLineStyle(styleStr) =>
    styleStr == "Dashed" ? line.style_dashed :
     styleStr == "Dotted" ? line.style_dotted :
     line.style_solid

// ═══════════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════
atr = ta.atr(atrLength)

// Lock in entry price + ATR the first bar at/after the anchor time.
// Both stay fixed after that -- dragging the anchor to a new bar on the
// chart resets them for a new trade.
var float anchorPrice = na
var float anchorATR   = na
var int   anchorBar   = na
var bool  anchorSet   = false

if not anchorSet and time_close >= anchorTime
    anchorPrice := close
    anchorATR   := atr
    anchorBar   := bar_index
    anchorSet   := true

currentPrice = anchorPrice
stopLossLevel    = anchorSet ? anchorPrice - anchorATR * 1.0 : na
emergencyLevel   = anchorSet ? anchorPrice - anchorATR * 2.0 : na
plus1Level       = anchorSet ? anchorPrice + anchorATR * 1.0 : na
plus2Level       = anchorSet ? anchorPrice + anchorATR * 2.0 : na
plus3Level       = anchorSet ? anchorPrice + anchorATR * 3.0 : na
plus4Level       = anchorSet ? anchorPrice + anchorATR * 4.0 : na
plus5Level       = anchorSet ? anchorPrice + anchorATR * 5.0 : na

// ═══════════════════════════════════════════════════════════════════════════
// PERSISTENT LINE & LABEL ARRAYS (index order must match the arrays below)
// 0=Price  1=Stop Loss  2=Emergency Exit  3=+1  4=+2  5=+3  6=+4  7=+5
// ═══════════════════════════════════════════════════════════════════════════
var lines  = array.new<line>(8, na)
var labels = array.new<label>(8, na)

// ═══════════════════════════════════════════════════════════════════════════
// PER-BAR SETTINGS ARRAYS (built fresh each bar from the inputs above)
// ═══════════════════════════════════════════════════════════════════════════
levelNames   = array.from("Price", "Stop Loss -.5 ATR", "Emer. Exit -2 ATR", "+1 ATR", "+2 ATR", "+3 ATR", "+4 ATR", "+5 ATR")
levelValues  = array.from(currentPrice, stopLossLevel, emergencyLevel, plus1Level, plus2Level, plus3Level, plus4Level, plus5Level)
showFlags    = array.from(showPriceLabel, showStopLossLabel, showEmergencyLabel, showPlus1Label, showPlus2Label, showPlus3Label, showPlus4Label, showPlus5Label)
lineColors   = array.from(priceColor, stopLossColor, emergencyExitColor, plus1Color, plus2Color, plus3Color, plus4Color, plus5Color)
lineWidths   = array.from(priceLineWidth, stopLossLineWidth, emergencyLineWidth, plus1LineWidth, plus2LineWidth, plus3LineWidth, plus4LineWidth, plus5LineWidth)
lineStyles   = array.from(priceLineStyle, stopLossLineStyle, emergencyLineStyle, plus1LineStyle, plus2LineStyle, plus3LineStyle, plus4LineStyle, plus5LineStyle)
labelBgColors = array.from(priceLabelColor, stopLossLabelColor, emergencyLabelColor, plus1LabelColor, plus2LabelColor, plus3LabelColor, plus4LabelColor, plus5LabelColor)

// ═══════════════════════════════════════════════════════════════════════════
// SINGLE LOOP - handles create/update for every level's line + label
// Only runs once the trade entry (anchor) has been set.
// ═══════════════════════════════════════════════════════════════════════════
if anchorSet
    for i = 0 to 7
        lvl      = array.get(levelValues, i)
        show     = array.get(showFlags, i)
        lnColor  = array.get(lineColors, i)
        lnWidth  = array.get(lineWidths, i)
        lnStyle  = getLineStyle(array.get(lineStyles, i))
        lblBg    = array.get(labelBgColors, i)
        lblXPos  = bar_index + labelOffsetBars

        // --- line: left edge stays pinned to the entry bar forever.
        // right edge extends automatically, so the level's y-value is the
        // only thing that ever changes, and it only changes once, at entry.
        ln = array.get(lines, i)
        if na(ln)
            newLn = line.new(anchorBar, lvl, anchorBar + 1, lvl,
                 color=lnColor, width=lnWidth, style=lnStyle, extend=extend.right)
            array.set(lines, i, newLn)
            ln := newLn

        // visible + styled when shown, invisible/width-0 when hidden (matches original behavior)
        if show
            line.set_color(ln, lnColor)
            line.set_width(ln, lnWidth)
            line.set_style(ln, lnStyle)
        else
            line.set_color(ln, color.new(lnColor, 100))
            line.set_width(ln, 0)

        // --- label: position tracks the current bar (so it stays visible
        // near the right edge as new bars form) but the price it shows
        // never changes, since lvl is frozen at entry.
        lb = array.get(labels, i)
        if show
            txt = array.get(levelNames, i) + ": " + str.tostring(lvl, format.mintick)
            if na(lb)
                newLb = label.new(lblXPos, lvl, txt, xloc.bar_index, yloc.price,
                     lblBg, label.style_label_left, labelTextColor, fSize)
                array.set(labels, i, newLb)
            else
                label.set_xy(lb, lblXPos, lvl)
                label.set_text(lb, txt)
                label.set_color(lb, lblBg)
                label.set_textcolor(lb, labelTextColor)
                label.set_style(lb, label.style_label_left)
                label.set_size(lb, fSize)
        else
            if not na(lb)
                label.delete(lb)
                array.set(labels, i, na)

// ═══════════════════════════════════════════════════════════════════════════
// STATUS LINE
// ═══════════════════════════════════════════════════════════════════════════
plot(currentPrice,   title="Price",  color=priceColor,          display=display.status_line, editable=false)
plot(stopLossLevel,  title="SL",     color=stopLossColor,       display=display.status_line, editable=false)
plot(emergencyLevel, title="Emerg",  color=emergencyExitColor,  display=display.status_line, editable=false)
plot(plus1Level,     title="+1",     color=plus1Color,          display=display.status_line, editable=false)
plot(plus2Level,     title="+2",     color=plus2Color,          display=display.status_line, editable=false)
plot(plus3Level,     title="+3",     color=plus3Color,          display=display.status_line, editable=false)
plot(plus4Level,     title="+4",     color=plus4Color,          display=display.status_line, editable=false)
plot(plus5Level,     title="+5",     color=plus5Color,          display=display.status_line, editable=false)
````
