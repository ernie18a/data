# Monthly Gann Box 

- url: https://www.tradingview.com/script/6UPscRTw-Monthly-Gann-Box/
- type: indicator
- pine_id: PUB;59751757a0d440d7b40cc130a1cc8e5f
- version: 1.0

## Description

Monthly Gann Box (Structural Crypto, 0↔0.618)

This indicator projects a monthly structural Gann framework using the previous month's price range as the foundational measurement. The prior month's low-to-high range is mapped into a geometric 0 ↔ 0.618 scaling model and projected across the current trading month.

The script generates both bullish and bearish monthly Gann structures with synchronized price and time divisions, allowing traders to study recurring market geometry, timing relationships, expansion zones, and structural reaction areas within the active month.

The framework is designed for swing traders, intraday traders, and market structure analysts seeking a repeatable monthly geometric reference model.

Core Features
Uses previous monthly high and low as the structural base
Projects the structure across the current calendar month
Separate Bull and Bear Gann structures
Fibonacci/Gann-based ratio mapping
Time and price synchronization
Primary diagonal balance lines
Midpoint structural diagonals
Optional geometric mesh overlay
Automatic monthly reset and recalculation
Efficient object handling for TradingView limits
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

These levels are projected both horizontally (price) and vertically (time), creating a synchronized structural grid for monthly analysis.

Structural Components
Bull Structure

The bullish framework expands upward from the previous month's low using the 0 ↔ 0.618 mapping model.

Bear Structure

The bearish framework expands downward from the previous month's high using the inverse mapping model.

Primary Diagonals

Major corner-to-corner diagonals visualize dominant structural balance and directional symmetry.

Midpoint Diagonals

Secondary diagonals divide the structure into additional geometric relationships and midpoint reactions.

Background Mesh

Optional full-grid mesh projection for advanced geometric and structural analysis.

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
Time-price relationships
Monthly cycle behavior
Expansion and compression zones
Structural crypto analysis
Swing and intraday market timing

The framework can be used on both higher and lower timeframes while maintaining monthly structural alignment.

Notes
The indicator recalculates automatically at the start of each new month.
Structures are derived entirely from the previous monthly candle.
Time divisions are normalized using the 1.272 structural expansion.
Designed primarily as a structural and geometric analysis tool rather than a standalone signal generator.

## Source Code

````pine
//@version=6
indicator("Monthly Gann Box (Structural Crypto, 0↔0.618)", overlay=true, max_lines_count=500, max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBullBox   = input.bool(true, "Show Bull Box")
showBearBox   = input.bool(true, "Show Bear Box")
showLabels    = input.bool(true, "Show Labels")
showMesh      = input.bool(false, "Show Background Mesh")

borderWidth   = input.int(1, "Border Width", minval=1, maxval=4)
levelWidth    = input.int(1, "Level Width", minval=1, maxval=4)
primaryWidth  = input.int(2, "Primary Diagonal Width", minval=1, maxval=5)
midWidth      = input.int(2, "Midpoint Diagonal Width", minval=1, maxval=5)
meshWidth     = input.int(1, "Mesh Width", minval=1, maxval=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
colBorder      = color.new(color.white, 0)
colBullLevel   = color.new(color.lime, 0)
colBearLevel   = color.new(color.orange, 0)
colVert        = color.new(color.aqua, 0)
colPrimaryDiag = color.new(color.white, 0)
colMidDiag     = color.new(color.yellow, 0)
colMesh        = color.new(color.gray, 0)
colBullText    = color.new(color.lime, 0)
colBearText    = color.new(color.orange, 0)

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
// MONTHLY SOURCE + CURRENT MONTH WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
prevMonthHigh = request.security(syminfo.tickerid, "M", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevMonthLow  = request.security(syminfo.tickerid, "M", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

currMonthStart = request.security(syminfo.tickerid, "M", time,       barmerge.gaps_off, barmerge.lookahead_off)
currMonthEnd   = request.security(syminfo.tickerid, "M", time_close, barmerge.gaps_off, barmerge.lookahead_off)

newMonth = ta.change(time("M")) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE MAPPING
// Previous month low↔high mapped to 0↔0.618
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
var line[] bullHoriz   = array.new_line(8)
var line[] bullVert    = array.new_line(8)
var line[] bullPrimary = array.new_line(2)
var line[] bullMid     = array.new_line(4)
var line[] bullMesh    = array.new_line(64)

var label[] bullLeftLbl   = array.new_label(8)
var label[] bullRightLbl  = array.new_label(8)
var label[] bullTopLbl    = array.new_label(8)
var label[] bullBottomLbl = array.new_label(8)

var line[] bearBorders = array.new_line(4)
var line[] bearHoriz   = array.new_line(8)
var line[] bearVert    = array.new_line(8)
var line[] bearPrimary = array.new_line(2)
var line[] bearMid     = array.new_line(4)
var line[] bearMesh    = array.new_line(64)

var label[] bearLeftLbl   = array.new_label(8)
var label[] bearRightLbl  = array.new_label(8)
var label[] bearTopLbl    = array.new_label(8)
var label[] bearBottomLbl = array.new_label(8)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLEAR ON FIRST BAR / NEW MONTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isfirst or newMonth
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
// DRAW FIXED CURRENT-MONTH BOX
// USING PREVIOUS-MONTH PRICES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool ready = not na(prevMonthHigh) and not na(prevMonthLow) and not na(currMonthStart) and not na(currMonthEnd)

if ready
    float bullBottom = bullPrice(prevMonthLow, prevMonthHigh, 0.0)
    float bullTop    = bullPrice(prevMonthLow, prevMonthHigh, 1.272)

    float bearTop    = bearPrice(prevMonthLow, prevMonthHigh, 0.0)
    float bearBottom = bearPrice(prevMonthLow, prevMonthHigh, 1.272)

    // Bull structure
    if showBullBox
        setOrCreateLine(bullBorders, 0, currMonthStart, bullTop,    currMonthEnd, bullTop,    colBorder, borderWidth)
        setOrCreateLine(bullBorders, 1, currMonthStart, bullBottom, currMonthEnd, bullBottom, colBorder, borderWidth)
        setOrCreateLine(bullBorders, 2, currMonthStart, bullBottom, currMonthStart, bullTop,  colBorder, borderWidth)
        setOrCreateLine(bullBorders, 3, currMonthEnd,   bullBottom, currMonthEnd,   bullTop,  colBorder, borderWidth)

        for i = 0 to levelCount - 1
            float lvl = levelRatio(i)
            float yv  = bullPrice(prevMonthLow, prevMonthHigh, lvl)
            int xv    = timeAtRatio(currMonthStart, currMonthEnd, lvl)
            color lc  = levelColor(i, true)
            string tx = levelText(i)

            setOrCreateLine(bullHoriz, i, currMonthStart, yv, currMonthEnd, yv, lc, levelWidth)
            setOrCreateLine(bullVert,  i, xv, bullBottom, xv, bullTop, colVert, levelWidth)

            if showLabels
                setOrCreateLabel(bullLeftLbl,   i, currMonthStart, yv, tx, colBullText)
                setOrCreateLabel(bullRightLbl,  i, currMonthEnd,   yv, tx, colBullText)
                setOrCreateLabel(bullTopLbl,    i, xv, bullTop, tx, colBullText)
                setOrCreateLabel(bullBottomLbl, i, xv, bullBottom, tx, colBullText)
            else
                deleteLabelArray(bullLeftLbl)
                deleteLabelArray(bullRightLbl)
                deleteLabelArray(bullTopLbl)
                deleteLabelArray(bullBottomLbl)

        setOrCreateLine(bullPrimary, 0, currMonthStart, bullBottom, currMonthEnd, bullTop,    colPrimaryDiag, primaryWidth)
        setOrCreateLine(bullPrimary, 1, currMonthStart, bullTop,    currMonthEnd, bullBottom, colPrimaryDiag, primaryWidth)

        float bullMidY = bullPrice(prevMonthLow, prevMonthHigh, 0.5)
        setOrCreateLine(bullMid, 0, currMonthStart, bullBottom, currMonthEnd, bullMidY,   colMidDiag, midWidth)
        setOrCreateLine(bullMid, 1, currMonthStart, bullMidY,   currMonthEnd, bullTop,    colMidDiag, midWidth)
        setOrCreateLine(bullMid, 2, currMonthStart, bullTop,    currMonthEnd, bullMidY,   colMidDiag, midWidth)
        setOrCreateLine(bullMid, 3, currMonthStart, bullMidY,   currMonthEnd, bullBottom, colMidDiag, midWidth)

        if showMesh
            for li = 0 to levelCount - 1
                for ri = 0 to levelCount - 1
                    int idx = li * levelCount + ri
                    float y1 = bullPrice(prevMonthLow, prevMonthHigh, levelRatio(li))
                    float y2 = bullPrice(prevMonthLow, prevMonthHigh, levelRatio(ri))
                    setOrCreateLine(bullMesh, idx, currMonthStart, y1, currMonthEnd, y2, colMesh, meshWidth)
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
        setOrCreateLine(bearBorders, 0, currMonthStart, bearTop,    currMonthEnd, bearTop,    colBorder, borderWidth)
        setOrCreateLine(bearBorders, 1, currMonthStart, bearBottom, currMonthEnd, bearBottom, colBorder, borderWidth)
        setOrCreateLine(bearBorders, 2, currMonthStart, bearBottom, currMonthStart, bearTop,  colBorder, borderWidth)
        setOrCreateLine(bearBorders, 3, currMonthEnd,   bearBottom, currMonthEnd,   bearTop,  colBorder, borderWidth)

        for i = 0 to levelCount - 1
            float lvl = levelRatio(i)
            float yv  = bearPrice(prevMonthLow, prevMonthHigh, lvl)
            int xv    = timeAtRatio(currMonthStart, currMonthEnd, lvl)
            color lc  = levelColor(i, false)
            string tx = levelText(i)

            setOrCreateLine(bearHoriz, i, currMonthStart, yv, currMonthEnd, yv, lc, levelWidth)
            setOrCreateLine(bearVert,  i, xv, bearBottom, xv, bearTop, colVert, levelWidth)

            if showLabels
                setOrCreateLabel(bearLeftLbl,   i, currMonthStart, yv, tx, colBearText)
                setOrCreateLabel(bearRightLbl,  i, currMonthEnd,   yv, tx, colBearText)
                setOrCreateLabel(bearTopLbl,    i, xv, bearTop, tx, colBearText)
                setOrCreateLabel(bearBottomLbl, i, xv, bearBottom, tx, colBearText)
            else
                deleteLabelArray(bearLeftLbl)
                deleteLabelArray(bearRightLbl)
                deleteLabelArray(bearTopLbl)
                deleteLabelArray(bearBottomLbl)

        setOrCreateLine(bearPrimary, 0, currMonthStart, bearBottom, currMonthEnd, bearTop,    colPrimaryDiag, primaryWidth)
        setOrCreateLine(bearPrimary, 1, currMonthStart, bearTop,    currMonthEnd, bearBottom, colPrimaryDiag, primaryWidth)

        float bearMidY = bearPrice(prevMonthLow, prevMonthHigh, 0.5)
        setOrCreateLine(bearMid, 0, currMonthStart, bearBottom, currMonthEnd, bearMidY,   colMidDiag, midWidth)
        setOrCreateLine(bearMid, 1, currMonthStart, bearMidY,   currMonthEnd, bearTop,    colMidDiag, midWidth)
        setOrCreateLine(bearMid, 2, currMonthStart, bearTop,    currMonthEnd, bearMidY,   colMidDiag, midWidth)
        setOrCreateLine(bearMid, 3, currMonthStart, bearMidY,   currMonthEnd, bearBottom, colMidDiag, midWidth)

        if showMesh
            for li = 0 to levelCount - 1
                for ri = 0 to levelCount - 1
                    int idx = li * levelCount + ri
                    float y1 = bearPrice(prevMonthLow, prevMonthHigh, levelRatio(li))
                    float y2 = bearPrice(prevMonthLow, prevMonthHigh, levelRatio(ri))
                    setOrCreateLine(bearMesh, idx, currMonthStart, y1, currMonthEnd, y2, colMesh, meshWidth)
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
