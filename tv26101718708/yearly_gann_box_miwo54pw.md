# Yearly Gann Box

- url: https://www.tradingview.com/script/MIWO54pw-Yearly-Gann-Box/
- type: indicator
- pine_id: PUB;dd43cffcf03e48bd87863c6e325f9b9a
- version: 1.0

## Description

Yearly Gann Box (Structural Crypto, 0↔0.618)

This indicator projects a full-year structural Gann framework using the previous year's price range as the foundational measurement. The prior year's low-to-high range is mapped into a geometric 0 ↔ 0.618 scaling model and extended into the current trading year.

The script creates both bullish and bearish yearly Gann structures with synchronized price and time divisions, allowing traders to analyze long-term market geometry, timing relationships, and structural reaction zones.

The framework is designed for macro market analysis, cycle observation, and identifying potential areas of expansion, compression, support, resistance, and directional transitions.

Core Features
Uses previous yearly high and low as the base measurement
Projects the structure across the current calendar year
Separate Bull and Bear structural boxes
Fibonacci/Gann-based ratio mapping
Time and price synchronization
Primary and midpoint diagonal structures
Optional geometric mesh overlay
Automatic yearly reset and recalculation
Optimized object management for TradingView limits
Included Ratio Levels

The script plots the following structural levels:

0
0.25
0.382
0.5
0.618
0.75
1
1.272

These levels are projected both horizontally (price) and vertically (time), forming a synchronized Gann-style grid.

Structural Components
Bull Structure

The bullish framework expands upward from the previous year's low using the 0 ↔ 0.618 mapping model.

Bear Structure

The bearish framework expands downward from the previous year's high using the inverse mapping model.

Primary Diagonals

The indicator draws major corner-to-corner diagonals representing dominant structural balance lines.

Midpoint Diagonals

Additional midpoint diagonals divide the structure into secondary geometric relationships.

Background Mesh

Optional full-grid mesh projection for advanced structural and geometric analysis.

Customization Options

Users can independently control:

Bull Box visibility
Bear Box visibility
Labels
Background mesh
Border thickness
Level line thickness
Diagonal thickness
Mesh thickness
Intended Use

This indicator is designed for traders who study:

Gann geometry
Market structure
Time-price symmetry
Cycle analysis
Long-term crypto market behavior
Structural expansion and contraction zones

It is best used on higher timeframes where yearly structural relationships become more meaningful.

Notes
The indicator recalculates automatically at the start of each new year.
Structures are based entirely on the previous yearly candle.
Time divisions are normalized to the 1.272 structural expansion.
Designed primarily for overlay analysis rather than direct trade signals.

## Source Code

````pine
//@version=6
indicator("Yearly Gann Box (Structural Crypto, 0↔0.618)", overlay=true, max_lines_count=500, max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBullBox = input.bool(true, "Show Bull Box")
showBearBox = input.bool(true, "Show Bear Box")
showLabels = input.bool(true, "Show Labels")
showMesh = input.bool(false, "Show Background Mesh")

borderWidth = input.int(1, "Border Width", minval=1, maxval=4)
levelWidth = input.int(1, "Level Width", minval=1, maxval=4)
primaryWidth = input.int(2, "Primary Diagonal Width", minval=1, maxval=5)
midWidth = input.int(2, "Midpoint Diagonal Width", minval=1, maxval=5)
meshWidth = input.int(1, "Mesh Width", minval=1, maxval=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
colBorder = color.new(color.white, 0)
colBullLevel = color.new(color.lime, 0)
colBearLevel = color.new(color.orange, 0)
colVert = color.new(color.aqua, 0)
colPrimaryDiag = color.new(color.white, 0)
colMidDiag = color.new(color.yellow, 0)
colMesh = color.new(color.gray, 0)
colBullText = color.new(color.lime, 0)
colBearText = color.new(color.orange, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int levelCount = 8

levelRatio(int idx) =>
    float r = na
    if idx == 0
        r := 0.0
    else if idx == 1
        r := 0.25
    else if idx == 2
        r := 0.382
    else if idx == 3
        r := 0.5
    else if idx == 4
        r := 0.618
    else if idx == 5
        r := 0.75
    else if idx == 6
        r := 1.0
    else
        r := 1.272
    r

levelText(int idx) =>
    string t = ""
    if idx == 0
        t := "0"
    else if idx == 1
        t := "0.25"
    else if idx == 2
        t := "0.382"
    else if idx == 3
        t := "0.5"
    else if idx == 4
        t := "0.618"
    else if idx == 5
        t := "0.75"
    else if idx == 6
        t := "1"
    else
        t := "1.272"
    t

levelColor(int idx, bool isBull) =>
    color c = isBull ? colBullLevel : colBearLevel
    if idx == 0
        c := color.new(color.white, 0)
    else if idx == 4
        c := color.new(color.aqua, 0)
    else if idx == 7
        c := isBull ? color.new(color.lime, 0) : color.new(color.orange, 0)
    c

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// YEARLY SOURCE + CURRENT YEAR WINDOW
// Previous year projected across current year
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
prevYearHigh = request.security(syminfo.tickerid, "12M", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevYearLow = request.security(syminfo.tickerid, "12M", low[1], barmerge.gaps_off, barmerge.lookahead_off)

currYearStart = request.security(syminfo.tickerid, "12M", time, barmerge.gaps_off, barmerge.lookahead_off)
currYearEnd = request.security(syminfo.tickerid, "12M", time_close, barmerge.gaps_off, barmerge.lookahead_off)

newYear = ta.change(time("12M")) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE MAPPING
// Previous year low↔high mapped to 0↔0.618
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullPrice(float prevLo, float prevHi, float lvl) =>
    float rngSize = prevHi - prevLo
    float unitVal = rngSize / 0.618
    prevLo + unitVal * lvl

bearPrice(float prevLo, float prevHi, float lvl) =>
    float rngSize = prevHi - prevLo
    float unitVal = rngSize / 0.618
    prevHi - unitVal * lvl

timeAtRatio(int xStart, int xEnd, float lvl) =>
    xStart + int(math.round((xEnd - xStart) * (lvl / 1.272)))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECT HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
setOrCreateLine(line[] arr, int idx, int x1, float y1, int x2, float y2, color col, int width) =>
    line ln = array.get(arr, idx)
    if na(ln)
        ln := line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_time, color=col, width=width)
        array.set(arr, idx, ln)
    else
        line.set_x1(ln, x1)
        line.set_y1(ln, y1)
        line.set_x2(ln, x2)
        line.set_y2(ln, y2)
        line.set_color(ln, col)
        line.set_width(ln, width)

setOrCreateLabel(label[] arr, int idx, int x, float y, string txt, color txtCol) =>
    label lb = array.get(arr, idx)
    if na(lb)
        lb := label.new(x=x, y=y, text=txt, xloc=xloc.bar_time, style=label.style_none, textcolor=txtCol, size=size.small)
        array.set(arr, idx, lb)
    else
        label.set_x(lb, x)
        label.set_y(lb, y)
        label.set_text(lb, txt)
        label.set_textcolor(lb, txtCol)

deleteLineArray(line[] arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            line ln = array.get(arr, i)
            if not na(ln)
                line.delete(ln)
                array.set(arr, i, na)

deleteLabelArray(label[] arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            label lb = array.get(arr, i)
            if not na(lb)
                label.delete(lb)
                array.set(arr, i, na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] bullBorders = array.new_line(4)
var line[] bullHoriz = array.new_line(8)
var line[] bullVert = array.new_line(8)
var line[] bullPrimary = array.new_line(2)
var line[] bullMid = array.new_line(4)
var line[] bullMesh = array.new_line(64)

var label[] bullLeftLbl = array.new_label(8)
var label[] bullRightLbl = array.new_label(8)
var label[] bullTopLbl = array.new_label(8)
var label[] bullBottomLbl = array.new_label(8)

var line[] bearBorders = array.new_line(4)
var line[] bearHoriz = array.new_line(8)
var line[] bearVert = array.new_line(8)
var line[] bearPrimary = array.new_line(2)
var line[] bearMid = array.new_line(4)
var line[] bearMesh = array.new_line(64)

var label[] bearLeftLbl = array.new_label(8)
var label[] bearRightLbl = array.new_label(8)
var label[] bearTopLbl = array.new_label(8)
var label[] bearBottomLbl = array.new_label(8)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLEAR ON FIRST BAR / NEW YEAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isfirst or newYear
    deleteLineArray(bullBorders)
    deleteLineArray(bullHoriz)
    deleteLineArray(bullVert)
    deleteLineArray(bullPrimary)
    deleteLineArray(bullMid)
    deleteLineArray(bullMesh)
    deleteLabelArray(bullLeftLbl)
    deleteLabelArray(bullRightLbl)
    deleteLabelArray(bullTopLbl)
    deleteLabelArray(bullBottomLbl)

    deleteLineArray(bearBorders)
    deleteLineArray(bearHoriz)
    deleteLineArray(bearVert)
    deleteLineArray(bearPrimary)
    deleteLineArray(bearMid)
    deleteLineArray(bearMesh)
    deleteLabelArray(bearLeftLbl)
    deleteLabelArray(bearRightLbl)
    deleteLabelArray(bearTopLbl)
    deleteLabelArray(bearBottomLbl)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW FIXED CURRENT-YEAR BOX
// USING PREVIOUS-YEAR PRICES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool ready = not na(prevYearHigh) and not na(prevYearLow) and not na(currYearStart) and not na(currYearEnd)

if ready
    float bullBottom = bullPrice(prevYearLow, prevYearHigh, 0.0)
    float bullTop = bullPrice(prevYearLow, prevYearHigh, 1.272)

    float bearTop = bearPrice(prevYearLow, prevYearHigh, 0.0)
    float bearBottom = bearPrice(prevYearLow, prevYearHigh, 1.272)

    // Bull structure
    if showBullBox
        setOrCreateLine(bullBorders, 0, currYearStart, bullTop, currYearEnd, bullTop, colBorder, borderWidth)
        setOrCreateLine(bullBorders, 1, currYearStart, bullBottom, currYearEnd, bullBottom, colBorder, borderWidth)
        setOrCreateLine(bullBorders, 2, currYearStart, bullBottom, currYearStart, bullTop, colBorder, borderWidth)
        setOrCreateLine(bullBorders, 3, currYearEnd, bullBottom, currYearEnd, bullTop, colBorder, borderWidth)

        for i = 0 to levelCount - 1
            float lvl = levelRatio(i)
            float yv = bullPrice(prevYearLow, prevYearHigh, lvl)
            int xv = timeAtRatio(currYearStart, currYearEnd, lvl)
            color lc = levelColor(i, true)
            string tx = levelText(i)

            setOrCreateLine(bullHoriz, i, currYearStart, yv, currYearEnd, yv, lc, levelWidth)
            setOrCreateLine(bullVert, i, xv, bullBottom, xv, bullTop, colVert, levelWidth)

            if showLabels
                setOrCreateLabel(bullLeftLbl, i, currYearStart, yv, tx, colBullText)
                setOrCreateLabel(bullRightLbl, i, currYearEnd, yv, tx, colBullText)
                setOrCreateLabel(bullTopLbl, i, xv, bullTop, tx, colBullText)
                setOrCreateLabel(bullBottomLbl, i, xv, bullBottom, tx, colBullText)
            else
                deleteLabelArray(bullLeftLbl)
                deleteLabelArray(bullRightLbl)
                deleteLabelArray(bullTopLbl)
                deleteLabelArray(bullBottomLbl)

        setOrCreateLine(bullPrimary, 0, currYearStart, bullBottom, currYearEnd, bullTop, colPrimaryDiag, primaryWidth)
        setOrCreateLine(bullPrimary, 1, currYearStart, bullTop, currYearEnd, bullBottom, colPrimaryDiag, primaryWidth)

        float bullMidY = bullPrice(prevYearLow, prevYearHigh, 0.5)
        setOrCreateLine(bullMid, 0, currYearStart, bullBottom, currYearEnd, bullMidY, colMidDiag, midWidth)
        setOrCreateLine(bullMid, 1, currYearStart, bullMidY, currYearEnd, bullTop, colMidDiag, midWidth)
        setOrCreateLine(bullMid, 2, currYearStart, bullTop, currYearEnd, bullMidY, colMidDiag, midWidth)
        setOrCreateLine(bullMid, 3, currYearStart, bullMidY, currYearEnd, bullBottom, colMidDiag, midWidth)

        if showMesh
            for li = 0 to levelCount - 1
                for ri = 0 to levelCount - 1
                    int idx = li * levelCount + ri
                    float y1 = bullPrice(prevYearLow, prevYearHigh, levelRatio(li))
                    float y2 = bullPrice(prevYearLow, prevYearHigh, levelRatio(ri))
                    setOrCreateLine(bullMesh, idx, currYearStart, y1, currYearEnd, y2, colMesh, meshWidth)
        else
            deleteLineArray(bullMesh)
    else
        deleteLineArray(bullBorders)
        deleteLineArray(bullHoriz)
        deleteLineArray(bullVert)
        deleteLineArray(bullPrimary)
        deleteLineArray(bullMid)
        deleteLineArray(bullMesh)
        deleteLabelArray(bullLeftLbl)
        deleteLabelArray(bullRightLbl)
        deleteLabelArray(bullTopLbl)
        deleteLabelArray(bullBottomLbl)

    // Bear structure
    if showBearBox
        setOrCreateLine(bearBorders, 0, currYearStart, bearTop, currYearEnd, bearTop, colBorder, borderWidth)
        setOrCreateLine(bearBorders, 1, currYearStart, bearBottom, currYearEnd, bearBottom, colBorder, borderWidth)
        setOrCreateLine(bearBorders, 2, currYearStart, bearBottom, currYearStart, bearTop, colBorder, borderWidth)
        setOrCreateLine(bearBorders, 3, currYearEnd, bearBottom, currYearEnd, bearTop, colBorder, borderWidth)

        for i = 0 to levelCount - 1
            float lvl = levelRatio(i)
            float yv = bearPrice(prevYearLow, prevYearHigh, lvl)
            int xv = timeAtRatio(currYearStart, currYearEnd, lvl)
            color lc = levelColor(i, false)
            string tx = levelText(i)

            setOrCreateLine(bearHoriz, i, currYearStart, yv, currYearEnd, yv, lc, levelWidth)
            setOrCreateLine(bearVert, i, xv, bearBottom, xv, bearTop, colVert, levelWidth)

            if showLabels
                setOrCreateLabel(bearLeftLbl, i, currYearStart, yv, tx, colBearText)
                setOrCreateLabel(bearRightLbl, i, currYearEnd, yv, tx, colBearText)
                setOrCreateLabel(bearTopLbl, i, xv, bearTop, tx, colBearText)
                setOrCreateLabel(bearBottomLbl, i, xv, bearBottom, tx, colBearText)
            else
                deleteLabelArray(bearLeftLbl)
                deleteLabelArray(bearRightLbl)
                deleteLabelArray(bearTopLbl)
                deleteLabelArray(bearBottomLbl)

        setOrCreateLine(bearPrimary, 0, currYearStart, bearBottom, currYearEnd, bearTop, colPrimaryDiag, primaryWidth)
        setOrCreateLine(bearPrimary, 1, currYearStart, bearTop, currYearEnd, bearBottom, colPrimaryDiag, primaryWidth)

        float bearMidY = bearPrice(prevYearLow, prevYearHigh, 0.5)
        setOrCreateLine(bearMid, 0, currYearStart, bearBottom, currYearEnd, bearMidY, colMidDiag, midWidth)
        setOrCreateLine(bearMid, 1, currYearStart, bearMidY, currYearEnd, bearTop, colMidDiag, midWidth)
        setOrCreateLine(bearMid, 2, currYearStart, bearTop, currYearEnd, bearMidY, colMidDiag, midWidth)
        setOrCreateLine(bearMid, 3, currYearStart, bearMidY, currYearEnd, bearBottom, colMidDiag, midWidth)

        if showMesh
            for li = 0 to levelCount - 1
                for ri = 0 to levelCount - 1
                    int idx = li * levelCount + ri
                    float y1 = bearPrice(prevYearLow, prevYearHigh, levelRatio(li))
                    float y2 = bearPrice(prevYearLow, prevYearHigh, levelRatio(ri))
                    setOrCreateLine(bearMesh, idx, currYearStart, y1, currYearEnd, y2, colMesh, meshWidth)
        else
            deleteLineArray(bearMesh)
    else
        deleteLineArray(bearBorders)
        deleteLineArray(bearHoriz)
        deleteLineArray(bearVert)
        deleteLineArray(bearPrimary)
        deleteLineArray(bearMid)
        deleteLineArray(bearMesh)
        deleteLabelArray(bearLeftLbl)
        deleteLabelArray(bearRightLbl)
        deleteLabelArray(bearTopLbl)
        deleteLabelArray(bearBottomLbl)
````
