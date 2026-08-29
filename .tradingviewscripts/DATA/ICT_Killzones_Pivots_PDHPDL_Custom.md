<!-- tradingview-pine-id: PUB;c04ff394948748f2bbac3241c22a640f -->
<!-- tradingviewscripts-format: 1 -->
# ICT Killzones & Pivots + PDH/PDL [Custom]

Source: https://www.tradingview.com/script/lUOh39H6-ICT-Killzones-Pivots/

## Description

ict killzone times/lines may also add pdh/pdl but wasnt working properly

---

## Source Code

````pine
//@version=6
indicator("ICT Killzones & Pivots + PDH/PDL [Custom]", shorttitle="ICT KZ+PDHL", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ======================================================================================
// GENERAL SETTINGS
// ======================================================================================
g_gen = "General"
sessionLimit  = input.int(3, "Session Drawing Limit", minval=1, maxval=20, group=g_gen, tooltip="How many past sessions' pivot lines stay on the chart per killzone.")
tfLimitInput  = input.timeframe("30", "Timeframe Limit", group=g_gen, tooltip="Killzones stop drawing on chart timeframes higher than this.")
sessTZ        = input.string("America/New_York", "Timezone", group=g_gen)
lblSizeInput  = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_gen)
txtColor      = input.color(color.new(color.black, 0), "Text Color", group=g_gen)

lblSize = lblSizeInput == "Tiny" ? size.tiny : lblSizeInput == "Small" ? size.small : lblSizeInput == "Large" ? size.large : lblSizeInput == "Huge" ? size.huge : size.normal

// Timeframe-limit gate: only draw on charts at/below the chosen timeframe
tfAllowed = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(tfLimitInput)

// ======================================================================================
// KILLZONE GLOBAL SETTINGS
// ======================================================================================
g_kz = "Killzones"
showBoxes  = input.bool(false, "Show Killzone Boxes", group=g_kz)
showLabels = input.bool(true,  "Display Text", group=g_kz)
boxTransp  = input.int(70, "Box Transparency", minval=0, maxval=100, group=g_kz)

g_piv = "Killzone Pivots"
showPivots  = input.bool(true,  "Show Pivots", group=g_piv)
alertBroken = input.bool(true,  "Alert Broken Pivots", group=g_piv)
showMid     = input.bool(false, "Show Pivot Midpoints", group=g_piv)
stopMitig   = input.bool(true,  "Stop Once Mitigated", group=g_piv)

// ======================================================================================
// KILLZONE 1 — ASIA
// ======================================================================================
g1 = "Killzone 1 — Asia"
k1_on   = input.bool(true, "Enable", group=g1)
k1_name = input.string("AS", "Label Prefix", group=g1)
k1_sess = input.session("2000-0000", "Session", group=g1)
k1_col  = input.color(color.blue, "Color", group=g1)

// ======================================================================================
// KILLZONE 2 — LONDON
// ======================================================================================
g2 = "Killzone 2 — London"
k2_on   = input.bool(true, "Enable", group=g2)
k2_name = input.string("LO", "Label Prefix", group=g2)
k2_sess = input.session("0200-0500", "Session", group=g2)
k2_col  = input.color(color.red, "Color", group=g2)

// ======================================================================================
// KILLZONE 3 — NY AM
// ======================================================================================
g3 = "Killzone 3 — NY AM"
k3_on   = input.bool(true, "Enable", group=g3)
k3_name = input.string("NYAM", "Label Prefix", group=g3)
k3_sess = input.session("0930-1100", "Session", group=g3)
k3_col  = input.color(color.new(#0e9e6d, 0), "Color", group=g3)

// ======================================================================================
// KILLZONE 4 — NY LUNCH
// ======================================================================================
g4 = "Killzone 4 — NY Lunch"
k4_on   = input.bool(true, "Enable", group=g4)
k4_name = input.string("NYL", "Label Prefix", group=g4)
k4_sess = input.session("1200-1300", "Session", group=g4)
k4_col  = input.color(color.yellow, "Color", group=g4)

// ======================================================================================
// KILLZONE 5 — NY PM
// ======================================================================================
g5 = "Killzone 5 — NY PM"
k5_on   = input.bool(true, "Enable", group=g5)
k5_name = input.string("NYPM", "Label Prefix", group=g5)
k5_sess = input.session("1330-1600", "Session", group=g5)
k5_col  = input.color(color.purple, "Color", group=g5)

// ======================================================================================
// PREVIOUS DAY HIGH / LOW  (new addition)
// ======================================================================================
g_pdhl      = "Previous Day High/Low"
showPDHL    = input.bool(true, "Show Previous Day High/Low", group=g_pdhl)
showPDHLLbl = input.bool(true, "Show Labels", group=g_pdhl)
extendPDHL  = input.bool(true, "Extend to Current Bar", group=g_pdhl)
pdhCol      = input.color(color.new(color.aqua, 0), "PDH Color", group=g_pdhl)
pdlCol      = input.color(color.new(color.fuchsia, 0), "PDL Color", group=g_pdhl)
pdhlStyleIn = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g_pdhl)
pdhlWidth   = input.int(1, "Line Width", minval=1, maxval=5, group=g_pdhl)

f_lineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ======================================================================================
// KILLZONE ENGINE
// ======================================================================================
f_killzone(bool enabled, string kzName, string sess, color kzCol) =>
    var box    kzBox      = na
    var float  sessHigh   = na
    var float  sessLow    = na
    var int    sessHighBar = na
    var int    sessLowBar  = na
    var bool   inSessPrev = false
    var bool   hiBroken   = false
    var bool   loBroken   = false

    var array<line>  hiLines = array.new<line>()
    var array<line>  loLines = array.new<line>()
    var array<line>  midLines = array.new<line>()
    var array<label> hiLbls  = array.new<label>()
    var array<label> loLbls  = array.new<label>()

    var line  hiLine = na
    var line  loLine = na
    var label hiLbl  = na
    var label loLbl  = na

    inSess = enabled and tfAllowed and not na(time(timeframe.period, sess, sessTZ))

    // ---- session just started ----
    if inSess and not inSessPrev
        sessHigh    := high
        sessLow     := low
        sessHighBar := bar_index
        sessLowBar  := bar_index
        if showBoxes
            kzBox := box.new(bar_index, high, bar_index, low, border_color=kzCol, bgcolor=color.new(kzCol, boxTransp), extend=extend.none)

    // ---- inside session: track range ----
    if inSess
        if high > sessHigh
            sessHigh    := high
            sessHighBar := bar_index
        if low < sessLow
            sessLow    := low
            sessLowBar := bar_index
        if showBoxes and not na(kzBox)
            box.set_right(kzBox, bar_index)
            box.set_top(kzBox, sessHigh)
            box.set_bottom(kzBox, sessLow)

    // ---- session just ended: draw pivot lines ----
    if not inSess and inSessPrev and showPivots
        hiLine := line.new(sessHighBar, sessHigh, bar_index, sessHigh, color=kzCol, width=1)
        loLine := line.new(sessLowBar, sessLow, bar_index, sessLow, color=kzCol, width=1)
        array.push(hiLines, hiLine)
        array.push(loLines, loLine)
        hiBroken := false
        loBroken := false
        if showMid
            midLine = line.new(sessHighBar, (sessHigh + sessLow) / 2, bar_index, (sessHigh + sessLow) / 2, color=kzCol, style=line.style_dotted)
            array.push(midLines, midLine)
        if showLabels
            hiLbl := label.new(sessHighBar, sessHigh, kzName + ".H", style=label.style_none, textcolor=txtColor, size=lblSize, color=color.new(color.white, 100))
            loLbl := label.new(sessLowBar, sessLow, kzName + ".L", style=label.style_none, textcolor=txtColor, size=lblSize, color=color.new(color.white, 100))
            array.push(hiLbls, hiLbl)
            array.push(loLbls, loLbl)

        // purge beyond session limit
        if array.size(hiLines) > sessionLimit
            line.delete(array.shift(hiLines))
            line.delete(array.shift(loLines))
            if array.size(midLines) > 0
                line.delete(array.shift(midLines))
            if array.size(hiLbls) > 0
                label.delete(array.shift(hiLbls))
                label.delete(array.shift(loLbls))

    // ---- extend the most recent pivot lines forward + check mitigation ----
    if showPivots and array.size(hiLines) > 0
        lastHi = array.get(hiLines, array.size(hiLines) - 1)
        lastLo = array.get(loLines, array.size(loLines) - 1)
        hiY = line.get_y1(lastHi)
        loY = line.get_y1(lastLo)

        if not (stopMitig and hiBroken)
            line.set_x2(lastHi, bar_index)
        if not (stopMitig and loBroken)
            line.set_x2(lastLo, bar_index)

        if high >= hiY and not hiBroken
            hiBroken := true
            if alertBroken
                alert(kzName + " High swept", alert.freq_once_per_bar_close)
        if low <= loY and not loBroken
            loBroken := true
            if alertBroken
                alert(kzName + " Low swept", alert.freq_once_per_bar_close)

    inSessPrev := inSess

// run each killzone
f_killzone(k1_on, k1_name, k1_sess, k1_col)
f_killzone(k2_on, k2_name, k2_sess, k2_col)
f_killzone(k3_on, k3_name, k3_sess, k3_col)
f_killzone(k4_on, k4_name, k4_sess, k4_col)
f_killzone(k5_on, k5_name, k5_sess, k5_col)

// ======================================================================================
// PREVIOUS DAY HIGH / LOW
// ======================================================================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)

var line  pdhLine = na
var line  pdlLine = na
var label pdhLbl  = na
var label pdlLbl  = na
var float lastPdh = na
var float lastPdl = na

newPDHL = pdh != lastPdh or pdl != lastPdl

if showPDHL
    if newPDHL
        pdhLine := line.new(bar_index, pdh, bar_index, pdh, color=pdhCol, style=f_lineStyle(pdhlStyleIn), width=pdhlWidth, extend=extendPDHL ? extend.right : extend.none)
        pdlLine := line.new(bar_index, pdl, bar_index, pdl, color=pdlCol, style=f_lineStyle(pdhlStyleIn), width=pdhlWidth, extend=extendPDHL ? extend.right : extend.none)
        if showPDHLLbl
            pdhLbl := label.new(bar_index + 2, pdh, "PDH", style=label.style_label_left, textcolor=pdhCol, size=lblSize, color=color.new(color.white, 100))
            pdlLbl := label.new(bar_index + 2, pdl, "PDL", style=label.style_label_left, textcolor=pdlCol, size=lblSize, color=color.new(color.white, 100))
        lastPdh := pdh
        lastPdl := pdl
    else if showPDHLLbl and not na(pdhLbl)
        label.set_x(pdhLbl, bar_index + 2)
        label.set_x(pdlLbl, bar_index + 2)
````
