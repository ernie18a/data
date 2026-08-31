<!-- tradingview-pine-id: PUB;cb00bd2c3da6494bb326ea7c08026729 -->
<!-- tradingviewscripts-format: 1 -->
# Currency Bro

Source: https://www.tradingview.com/script/DLIYmXVU-Currency-Bro/

## Description

Higher Timeframe Market Structure Tracker. This is used to help you stay aligned in the markets while operating your trades on a weekly basis. This Indicator uses SMC Market Structure techniques to keep track of the higher timeframe trends. Use this everyday when placing trades to help keep you in line for directional bias.

---

## Source Code

````pine
//@version=6
indicator("Currency Bro", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// === Inputs ===
pivLen            = input.int(5, "Pivot Length", minval=1, group="Structure")
trianglesLookback = input.int(150, "Triangles lookback (bars)", minval=10, group="Structure", tooltip="How far back to draw the swing-point triangles. Doesn't affect the tracker — BOS, CHoCH, LS, and structure bias still use ALL pivots.")

showBOS     = input.bool(true, "Show BOS / CHoCH lines", group="BOS")
bosLookback = input.int(100, "BOS lookback (bars)", minval=10, group="BOS")
bosColor    = input.color(color.gray, "BOS color", group="BOS")
chochColor  = input.color(color.orange, "CHoCH color", group="BOS")

showLS      = input.bool(true, "Show liquidity sweeps", group="Liquidity Sweeps")
lsLookback  = input.int(100, "LS lookback (bars)", minval=10, group="Liquidity Sweeps")
lsMaxPivots = input.int(20, "Max pivots tracked for sweeps", minval=5, group="Liquidity Sweeps")
lsColor     = input.color(color.new(color.yellow, 20), "LS color", group="Liquidity Sweeps")

showFVG        = input.bool(true, "Show FVGs", group="FVG")
fvgBoxBars     = input.int(8, "FVG box width (bars)", minval=1, group="FVG")
fvgRecentBars  = input.int(24, "Recent window (bars)", minval=1, group="FVG")
fvgMitPct      = input.float(0.5, "Mitigation threshold", minval=0.0, maxval=1.0, step=0.05, group="FVG")
fvgShowOldMit  = input.bool(false, "Show old mitigated FVGs", group="FVG")
fvgMatchBOS    = input.bool(false, "Only FVGs matching last BOS direction", group="FVG")
fvgBullCol     = input.color(color.new(color.aqua, 80), "Bullish FVG", group="FVG")
fvgBearCol     = input.color(color.new(color.gray, 70), "Bearish FVG", group="FVG")

showTable      = input.bool(true, "Show structure readout", group="Display")
show1W         = input.bool(true, "Show 1W structure", group="Display", tooltip="Weekly HTF structure row.")
show1D         = input.bool(true, "Show 1D structure", group="Display", tooltip="Daily HTF structure row.")
show4H         = input.bool(true, "Show 4H structure", group="Display", tooltip="4-hour HTF structure row.")
tablePosStr    = input.string("top_right", "Readout position", options=["top_right", "top_center", "top_left", "middle_right", "middle_left", "bottom_right", "bottom_center", "bottom_left"], group="Display", tooltip="Where the readout anchors. On mobile, middle_right often avoids overlap with the symbol/OHLC label at top-right.")
tablePos       = tablePosStr == "top_right" ? position.top_right : (tablePosStr == "top_center" ? position.top_center : (tablePosStr == "top_left" ? position.top_left : (tablePosStr == "middle_right" ? position.middle_right : (tablePosStr == "middle_left" ? position.middle_left : (tablePosStr == "bottom_right" ? position.bottom_right : (tablePosStr == "bottom_center" ? position.bottom_center : position.bottom_left))))))

// === Types ===
type BOSMark
    line ln
    label lbl
    int barIdx

type FVG
    box b
    int barIdx
    float top
    float bottom
    int dir
    bool mitigated

type SweepMark
    line ln
    label lbl
    int barIdx

type TrackedPivot
    float price
    int barIdx
    int dir
    bool broken
    bool swept
    SweepMark sweepRef

// === Chart-TF pivots ===
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)

var float lastPH    = na
var int   lastPHbar = na
var bool  phBroken  = false

var float lastPL    = na
var int   lastPLbar = na
var bool  plBroken  = false

if not na(ph)
    lastPH    := ph
    lastPHbar := bar_index - pivLen
    phBroken  := false

if not na(pl)
    lastPL    := pl
    lastPLbar := bar_index - pivLen
    plBroken  := false

// === Chart-TF break classification & drawing ===
// State machine: structState (1=bullish, -1=bearish, 0=neutral).
// A break in the same direction as state → BOS (continuation).
// A break OPPOSITE to state → CHoCH (character change), state flips.
// First break ever (state=0) is treated as BOS.
// legStartBar tracks the last bar where state actually changed — defines the
// "current leg" window for leg-based checks in the readout.
bullBreak = (not na(lastPH)) and (not phBroken) and (close > lastPH)
bearBreak = (not na(lastPL)) and (not plBroken) and (close < lastPL)

var int lastBOSdir     = 0
var int lastBOSbar     = na
var int lastPureBOSdir = 0
var int lastPureBOSbar = na
var int lastChochDir   = 0
var int lastChochBar   = na
var int legStartBar    = na
var int structState    = 0
var array<BOSMark> bosMarks = array.new<BOSMark>()

if bullBreak
    phBroken    := true
    isChochU    = structState == -1
    isNewLegU   = structState != 1
    structState := 1
    lastBOSdir  := 1
    lastBOSbar  := bar_index
    if isChochU
        lastChochDir := 1
        lastChochBar := bar_index
    else
        lastPureBOSdir := 1
        lastPureBOSbar := bar_index
    if isNewLegU
        legStartBar := bar_index
    if showBOS
        colUse = isChochU ? chochColor : bosColor
        txtUse = isChochU ? "CHoCH" : "BOS"
        ln1  = line.new(lastPHbar, lastPH, bar_index, lastPH, color=colUse, width=1)
        mid1 = math.floor((lastPHbar + bar_index) / 2)
        lb1  = label.new(mid1, lastPH, txtUse, style=label.style_none, textcolor=colUse, size=size.small)
        array.push(bosMarks, BOSMark.new(ln1, lb1, bar_index))

if bearBreak
    plBroken    := true
    isChochD    = structState == 1
    isNewLegD   = structState != -1
    structState := -1
    lastBOSdir  := -1
    lastBOSbar  := bar_index
    if isChochD
        lastChochDir := -1
        lastChochBar := bar_index
    else
        lastPureBOSdir := -1
        lastPureBOSbar := bar_index
    if isNewLegD
        legStartBar := bar_index
    if showBOS
        colUse = isChochD ? chochColor : bosColor
        txtUse = isChochD ? "CHoCH" : "BOS"
        ln2  = line.new(lastPLbar, lastPL, bar_index, lastPL, color=colUse, width=1)
        mid2 = math.floor((lastPLbar + bar_index) / 2)
        lb2  = label.new(mid2, lastPL, txtUse, style=label.style_none, textcolor=colUse, size=size.small)
        array.push(bosMarks, BOSMark.new(ln2, lb2, bar_index))

if array.size(bosMarks) > 0
    for i = (array.size(bosMarks) - 1) to 0
        bm = array.get(bosMarks, i)
        if (bar_index - bm.barIdx) > bosLookback
            line.delete(bm.ln)
            label.delete(bm.lbl)
            array.remove(bosMarks, i)

// === Liquidity Sweep detection ===
var array<TrackedPivot> lsPivots = array.new<TrackedPivot>()
var array<SweepMark> sweepMarks = array.new<SweepMark>()

if not na(ph)
    array.push(lsPivots, TrackedPivot.new(ph, bar_index - pivLen, 1, false, false, na))
    if array.size(lsPivots) > lsMaxPivots
        array.shift(lsPivots)

if not na(pl)
    array.push(lsPivots, TrackedPivot.new(pl, bar_index - pivLen, -1, false, false, na))
    if array.size(lsPivots) > lsMaxPivots
        array.shift(lsPivots)

if array.size(lsPivots) > 0
    for i = (array.size(lsPivots) - 1) to 0
        p = array.get(lsPivots, i)
        if not p.broken
            if not p.swept
                if p.dir == 1
                    if (high > p.price) and (close <= p.price)
                        p.swept := true
                        if showLS
                            lnS  = line.new(p.barIdx, p.price, bar_index, p.price, color=lsColor, width=1)
                            midS = math.floor((p.barIdx + bar_index) / 2)
                            lbS  = label.new(midS, p.price, "$", style=label.style_none, textcolor=lsColor, size=size.small)
                            sm   = SweepMark.new(lnS, lbS, bar_index)
                            p.sweepRef := sm
                            array.push(sweepMarks, sm)
                    else if close > p.price
                        p.broken := true
                else
                    if (low < p.price) and (close >= p.price)
                        p.swept := true
                        if showLS
                            lnS  = line.new(p.barIdx, p.price, bar_index, p.price, color=lsColor, width=1)
                            midS = math.floor((p.barIdx + bar_index) / 2)
                            lbS  = label.new(midS, p.price, "$", style=label.style_none, textcolor=lsColor, size=size.small)
                            sm   = SweepMark.new(lnS, lbS, bar_index)
                            p.sweepRef := sm
                            array.push(sweepMarks, sm)
                    else if close < p.price
                        p.broken := true
            else
                // Already swept — check for close-through (upgrade to BOS)
                upgraded = false
                if (p.dir == 1) and (close > p.price)
                    upgraded := true
                if (p.dir == -1) and (close < p.price)
                    upgraded := true
                if upgraded
                    p.broken := true
                    if not na(p.sweepRef)
                        line.delete(p.sweepRef.ln)
                        label.delete(p.sweepRef.lbl)

if array.size(sweepMarks) > 0
    for i = (array.size(sweepMarks) - 1) to 0
        sm = array.get(sweepMarks, i)
        if (bar_index - sm.barIdx) > lsLookback
            line.delete(sm.ln)
            label.delete(sm.lbl)
            array.remove(sweepMarks, i)

// === FVG detection & tracking ===
var array<FVG> fvgs = array.new<FVG>()

bullFVG = low > high[2]
bearFVG = high < low[2]

bullMatchOK = (not fvgMatchBOS) or (lastBOSdir == 1)
bearMatchOK = (not fvgMatchBOS) or (lastBOSdir == -1)

if barstate.isconfirmed and showFVG and bullFVG and bullMatchOK
    topP1 = low
    botP1 = high[2]
    bx1   = box.new(bar_index - 1, topP1, bar_index - 1 + fvgBoxBars, botP1, border_color=fvgBullCol, bgcolor=fvgBullCol)
    array.push(fvgs, FVG.new(bx1, bar_index - 1, topP1, botP1, 1, false))

if barstate.isconfirmed and showFVG and bearFVG and bearMatchOK
    topP2 = low[2]
    botP2 = high
    bx2   = box.new(bar_index - 1, topP2, bar_index - 1 + fvgBoxBars, botP2, border_color=fvgBearCol, bgcolor=fvgBearCol)
    array.push(fvgs, FVG.new(bx2, bar_index - 1, topP2, botP2, -1, false))

if array.size(fvgs) > 0
    for i = (array.size(fvgs) - 1) to 0
        fvg = array.get(fvgs, i)
        sz  = fvg.top - fvg.bottom
        fullyViolated = false
        if fvg.dir == 1 and close < fvg.bottom
            fullyViolated := true
        if fvg.dir == -1 and close > fvg.top
            fullyViolated := true
        if fullyViolated
            box.delete(fvg.b)
            array.remove(fvgs, i)
        else
            if not fvg.mitigated
                if fvg.dir == 1
                    thr1 = fvg.top - (fvgMitPct * sz)
                    if low <= thr1
                        fvg.mitigated := true
                else
                    thr2 = fvg.bottom + (fvgMitPct * sz)
                    if high >= thr2
                        fvg.mitigated := true
            age = bar_index - fvg.barIdx
            if fvg.mitigated and (age > fvgRecentBars) and (not fvgShowOldMit)
                box.delete(fvg.b)
                array.remove(fvgs, i)

// === Triangles ===
plotshape(not na(ph) and (last_bar_index - bar_index <= trianglesLookback), title="Swing High", style=shape.triangledown, location=location.abovebar, color=color.new(color.gray, 0), size=size.tiny, offset=-pivLen)
plotshape(not na(pl) and (last_bar_index - bar_index <= trianglesLookback), title="Swing Low",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.gray, 0), size=size.tiny, offset=-pivLen)

// === HTF structure classification (state-machine, nuanced 5-state) ===
f_htfStructure() =>
    ph2 = ta.pivothigh(high, pivLen, pivLen)
    pl2 = ta.pivotlow(low,  pivLen, pivLen)

    var float lastPH2      = na
    var bool  phBroken2    = false
    var float lastPL2      = na
    var bool  plBroken2    = false
    var int   htfDir       = 0
    var int   htfState     = 0
    var int   htfConfirmed = 0

    if not na(ph2)
        lastPH2   := ph2
        phBroken2 := false
    if not na(pl2)
        lastPL2   := pl2
        plBroken2 := false

    if (not na(lastPH2)) and (not phBroken2) and (close > lastPH2)
        phBroken2 := true
        isChochU2 = htfState == -1
        if not isChochU2
            htfConfirmed := 1
        htfState := 1
        htfDir   := 1
    if (not na(lastPL2)) and (not plBroken2) and (close < lastPL2)
        plBroken2 := true
        isChochD2 = htfState == 1
        if not isChochD2
            htfConfirmed := -1
        htfState := -1
        htfDir   := -1

    s = "RANGE"
    if htfState == 1
        s := htfConfirmed == 1 ? "BULLISH TREND" : "BULLISH TRANSITION"
    else if htfState == -1
        s := htfConfirmed == -1 ? "BEARISH TREND" : "BEARISH TRANSITION"

    s

h4Structure = request.security(syminfo.tickerid, "240", f_htfStructure(), lookahead=barmerge.lookahead_off)
dStructure  = request.security(syminfo.tickerid, "D",   f_htfStructure(), lookahead=barmerge.lookahead_off)
wStructure  = request.security(syminfo.tickerid, "W",   f_htfStructure(), lookahead=barmerge.lookahead_off)

// === Readout ===
// HTF structure rows: 1W → 1D → 4H (top-down bias reading).
// Each row toggleable independently. Table sizes to enabled rows.
enabledRows = (show1W ? 1 : 0) + (show1D ? 1 : 0) + (show4H ? 1 : 0)
tableRows   = math.max(enabledRows, 1)
var table t = table.new(tablePos, 2, tableRows, border_width=1)
if barstate.islast and showTable and (enabledRows > 0)
    lblBg = color.new(color.black, 30)

    rowIdx = 0
    if show1W
        wCol = wStructure == "BULLISH TREND" ? color.new(color.green, 70) : (wStructure == "BULLISH TRANSITION" ? color.new(color.green, 85) : (wStructure == "BEARISH TREND" ? color.new(color.red, 70) : (wStructure == "BEARISH TRANSITION" ? color.new(color.red, 85) : color.new(color.gray, 70))))
        table.cell(t, 0, rowIdx, "Structure (1W)", bgcolor=lblBg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, rowIdx, wStructure,       bgcolor=wCol,  text_color=color.white, text_size=size.small)
        rowIdx := rowIdx + 1
    if show1D
        dCol = dStructure == "BULLISH TREND" ? color.new(color.green, 70) : (dStructure == "BULLISH TRANSITION" ? color.new(color.green, 85) : (dStructure == "BEARISH TREND" ? color.new(color.red, 70) : (dStructure == "BEARISH TRANSITION" ? color.new(color.red, 85) : color.new(color.gray, 70))))
        table.cell(t, 0, rowIdx, "Structure (1D)", bgcolor=lblBg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, rowIdx, dStructure,       bgcolor=dCol,  text_color=color.white, text_size=size.small)
        rowIdx := rowIdx + 1
    if show4H
        h4Col = h4Structure == "BULLISH TREND" ? color.new(color.green, 70) : (h4Structure == "BULLISH TRANSITION" ? color.new(color.green, 85) : (h4Structure == "BEARISH TREND" ? color.new(color.red, 70) : (h4Structure == "BEARISH TRANSITION" ? color.new(color.red, 85) : color.new(color.gray, 70))))
        table.cell(t, 0, rowIdx, "Structure (4H)", bgcolor=lblBg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, rowIdx, h4Structure,      bgcolor=h4Col, text_color=color.white, text_size=size.small)
        rowIdx := rowIdx + 1
````
