<!-- tradingview-pine-id: PUB;3186610fe1ad44df88d2b2201e8843f4 -->
<!-- tradingviewscripts-format: 1 -->
# Point Grid Lines

Source: https://www.tradingview.com/script/74I0Sbsx-CLAUDIA-REA-Point-Grid-Lines/

## Description

FOR _CLAUDIAREA <3 
Adjustable grid lines every 25pts by default

---

## Source Code

````pine
//@version=6
indicator("Point Grid Lines", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================================
// Draws horizontal reference lines at every N points, centered around current price.
// Redrawn on the last bar each time the script recalculates, so the grid always covers
// wherever price currently is.
// =====================================================================================

grpES = "ES"
iEnableES   = input.bool(true, "Enable Grid for ES", group=grpES)
iIntervalES = input.float(25, "ES Point Interval", minval=0.0001, step=1, group=grpES)

grpNQ = "NQ"
iEnableNQ   = input.bool(true, "Enable Grid for NQ", group=grpNQ)
iIntervalNQ = input.float(50, "NQ Point Interval", minval=0.0001, step=1, group=grpNQ)

grpYM = "YM"
iEnableYM   = input.bool(true, "Enable Grid for YM", group=grpYM)
iIntervalYM = input.float(100, "YM Point Interval", minval=0.0001, step=1, group=grpYM)

grpRTY = "RTY"
iEnableRTY   = input.bool(true, "Enable Grid for RTY", group=grpRTY)
iIntervalRTY = input.float(10, "RTY Point Interval", minval=0.0001, step=1, group=grpRTY)

grpCL = "CL"
iEnableCL   = input.bool(true, "Enable Grid for CL", group=grpCL)
iIntervalCL = input.float(1, "CL Point Interval", minval=0.0001, step=0.1, group=grpCL)

grpGC = "GC"
iEnableGC   = input.bool(true, "Enable Grid for GC", group=grpGC)
iIntervalGC = input.float(25, "GC Point Interval", minval=0.0001, step=1, group=grpGC)

grpOther = "Other Symbols"
iEnableOther   = input.bool(true, "Enable Grid for Other Symbols", group=grpOther)
iIntervalOther = input.float(25, "Other Symbols Point Interval", minval=0.0001, step=1, group=grpOther)

// =====================================================================================
// PER-SYMBOL SELECTION — matches root ticker (handles micro-contract variants too)
// =====================================================================================
symRoot = syminfo.root
isES  = symRoot == "ES"  or symRoot == "MES"
isNQ  = symRoot == "NQ"  or symRoot == "MNQ"
isYM  = symRoot == "YM"  or symRoot == "MYM"
isRTY = symRoot == "RTY" or symRoot == "M2K"
isCL  = symRoot == "CL"  or symRoot == "MCL"
isGC  = symRoot == "GC"  or symRoot == "MGC" or symRoot == "1OZ"

iPointInterval = isES ? iIntervalES : isNQ ? iIntervalNQ : isYM ? iIntervalYM : isRTY ? iIntervalRTY : isCL ? iIntervalCL : isGC ? iIntervalGC : iIntervalOther
gridEnabled    = isES ? iEnableES  : isNQ ? iEnableNQ  : isYM ? iEnableYM  : isRTY ? iEnableRTY  : isCL ? iEnableCL  : isGC ? iEnableGC  : iEnableOther

grpRange = "Grid Range"
iLinesAbove = input.int(40, "Lines Above Current Price", minval=1, maxval=200, group=grpRange)
iLinesBelow = input.int(40, "Lines Below Current Price", minval=1, maxval=200, group=grpRange)

grpStyle = "Line Style"
iLineColor    = input.color(color.new(color.green, 0), "Line Color", group=grpStyle)
iLineWidth    = input.int(3, "Line Thickness", minval=1, maxval=10, group=grpStyle)
iLineStyleStr = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

grpLabels = "Price Labels"
iShowPriceLabels = input.bool(true, "Show Price Values Near Axis", group=grpLabels)
iLabelOffsetBars = input.int(70, "Label Offset from Last Bar (bars)", minval=0, group=grpLabels)
iLabelSizeStr    = input.string("Small", "Label Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLabels)
iLabelBgColor    = input.color(color.new(color.green, 0), "Label Background Color", group=grpLabels)
iLabelTextColor  = input.color(color.white, "Label Text Color", group=grpLabels)

f_lineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_labelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

// =====================================================================================
// DRAW GRID — clears and redraws the full set of lines each time, centered on the
// current price rounded to the nearest interval
// =====================================================================================
var array<line> gridLines = array.new<line>()
var array<label> gridLabels = array.new<label>()

if barstate.islast
    while gridLines.size() > 0
        line.delete(gridLines.pop())
    while gridLabels.size() > 0
        label.delete(gridLabels.pop())

    if gridEnabled
        baseLevel = math.round(close / iPointInterval) * iPointInterval
        styleVal = f_lineStyle(iLineStyleStr)
        labelSizeVal = f_labelSize(iLabelSizeStr)
        labelX = bar_index + iLabelOffsetBars

        for i = -iLinesBelow to iLinesAbove
            level = baseLevel + i * iPointInterval
            gridLines.push(line.new(bar_index, level, bar_index + 1, level, xloc=xloc.bar_index, extend=extend.both, color=iLineColor, width=iLineWidth, style=styleVal))
            if iShowPriceLabels
                gridLabels.push(label.new(labelX, level, str.tostring(level, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=iLabelBgColor, textcolor=iLabelTextColor, size=labelSizeVal))
````
