# NDOG & NWOG

- url: https://www.tradingview.com/script/XLhdDaRo-NDOG-NWOG/
- type: indicator
- pine_id: PUB;03c8d8c797da46cc933dc0b0788a9961
- version: 1.0

## Description

New Day Opening Gaps and New Week Opening Gaps with Quadrants

## Source Code

````pine
//@version=6
indicator("NDOG & NWOG", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ==========================================
// --- General Logic ---
// ==========================================
gp_gen       = "General Logic"
extBars      = input.int(40, "Extension Bars Offset", minval = 0, group = gp_gen)
showDetails  = input.bool(true, "Show Prices in Labels", group = gp_gen)
textSize     = input.string("small", "Label Text Size", options = ["tiny", "small", "normal", "large"], group = gp_gen)

f_getStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

// ==========================================
// --- NDOG Grouped Settings ---
// ==========================================
gp_ndog      = "NDOG (New Day Opening Gap)"
showNDOG     = input.bool(true, "Enable NDOG", group = gp_ndog)
ndogKeep     = input.int(5, "Historical NDOGs to Show", minval = 1, group = gp_ndog)

ndFillCur    = input.color(color.new(#ADD8E6, 50), "Current Fill", group = gp_ndog, inline = "nd_c")
ndLineCur    = input.color(color.new(color.black, 90), "Border", group = gp_ndog, inline = "nd_c")
ndTextCur    = input.color(#333333, "Text", group = gp_ndog, inline = "nd_c")
ndFillHis    = input.color(color.new(color.gray, 80), "History Fill", group = gp_ndog)

showNdMid    = input.bool(true, "Show Midline (0.5)", group = gp_ndog, inline = "nd_m")
ndMidCol     = input.color(color.gray, "", group = gp_ndog, inline = "nd_m")
ndMidStyle   = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = gp_ndog, inline = "nd_m")

showNdQuad   = input.bool(false, "Show Quadrants (0.25/0.75)", group = gp_ndog, inline = "nd_q")
ndQuadCol    = input.color(color.gray, "", group = gp_ndog, inline = "nd_q")
ndQuadStyle  = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = gp_ndog, inline = "nd_q")

// ==========================================
// --- NWOG Grouped Settings ---
// ==========================================
gp_nwog      = "NWOG (New Week Opening Gap)"
showNWOG     = input.bool(true, "Enable NWOG", group = gp_nwog)
nwogKeep     = input.int(3, "Historical NWOGs to Show", minval = 1, group = gp_nwog)

nwFillCur    = input.color(color.new(color.orange, 50), "Current Fill", group = gp_nwog, inline = "nw_c")
nwLineCur    = input.color(color.new(color.black, 90), "Border", group = gp_nwog, inline = "nw_c")
nwTextCur    = input.color(#FF8C00, "Text", group = gp_nwog, inline = "nw_c")
nwFillHis    = input.color(color.new(color.gray, 80), "History Fill", group = gp_nwog)

showNwMid    = input.bool(true, "Show Midline (0.5)", group = gp_nwog, inline = "nw_m")
nwMidCol     = input.color(color.gray, "", group = gp_nwog, inline = "nw_m")
nwNwStyle    = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = gp_nwog, inline = "nw_m")

showNwQuad   = input.bool(false, "Show Quadrants (0.25/0.75)", group = gp_nwog, inline = "nw_q")
nwQuadCol    = input.color(color.gray, "", group = gp_nwog, inline = "nw_q")
nwNwQStyle   = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = gp_nwog, inline = "nw_q")

// ==========================================
// --- Detection Logic ---
// ==========================================
is_new_day  = ta.change(time("D")) != 0
is_new_week = ta.change(time("W")) != 0
float session_close_price = close[1]

bool trigger_ndog = is_new_day and not is_new_week
bool trigger_nwog = is_new_week

// Arrays
var box[] ndBoxes = array.new_box(), var box[] nwBoxes = array.new_box()
var line[] ndLM = array.new_line(), var line[] ndLQ1 = array.new_line(), var line[] ndLQ3 = array.new_line()
var line[] nwLM = array.new_line(), var line[] nwLQ1 = array.new_line(), var line[] nwLQ3 = array.new_line()
var label[] ndLab = array.new_label(), var label[] nwLab = array.new_label()
var int[] ndTim = array.new_int(), var int[] nwTim = array.new_int()

f_getMonthName(m) =>
    string monthName = switch m
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        12 => "Dec"
        => ""
    monthName

format_label(header, hi, mi, lo, q1, q3, sQ) =>
    string res = header
    if showDetails
        res := res + "\n1 [" + str.tostring(hi, format.mintick) + "]"
        if sQ
            res := res + "\n0.75 [" + str.tostring(q3, format.mintick) + "]"
        res := res + "\n0.5 [" + str.tostring(mi, format.mintick) + "]"
        if sQ
            res := res + "\n0.25 [" + str.tostring(q1, format.mintick) + "]"
        res := res + "\n0 [" + str.tostring(lo, format.mintick) + "]"
    res

process(isTrig, cP, oP, gT, bA, lM, lQ1, lQ3, lbA, tA, fC, lC, tC, fH, mC, mS, qC, qS, sM, sQ, pref, lim) =>
    if isTrig and not na(cP)
        h = math.max(cP, oP), l = math.min(cP, oP), m = (h + l) / 2
        q1 = l + (h - l) * 0.25, q3 = l + (h - l) * 0.75
        rX = bar_index + extBars
        
        array.push(bA, box.new(bar_index, h, rX, l, bgcolor=fC, border_color=lC))
        array.push(lM, sM ? line.new(bar_index, m, rX, m, color=mC, style=f_getStyle(mS)) : line(na))
        array.push(lQ1, sQ ? line.new(bar_index, q1, rX, q1, color=qC, style=f_getStyle(qS)) : line(na))
        array.push(lQ3, sQ ? line.new(bar_index, q3, rX, q3, color=qC, style=f_getStyle(qS)) : line(na))
        array.push(tA, gT)
        array.push(lbA, label.new(rX, m, format_label(pref + " Current", h, m, l, q1, q3, sQ), style=label.style_label_left, color=color.new(color.white, 100), textcolor=tC, size=textSize))
        
        if array.size(lbA) > 1
            for i = 0 to array.size(lbA) - 2
                oB = array.get(bA, i), oM = array.get(lM, i), oQ1 = array.get(lQ1, i), oQ3 = array.get(lQ3, i), oLb = array.get(lbA, i), oT = array.get(tA, i)
                box.set_bgcolor(oB, fH)
                if not na(oM)
                    line.set_color(oM, mC)
                if not na(oQ1)
                    line.set_color(oQ1, qC)
                if not na(oQ3)
                    line.set_color(oQ3, qC)
                dStr = pref + " " + str.tostring(dayofmonth(oT)) + "-" + f_getMonthName(month(oT)) + "-" + str.tostring(year(oT))
                oh = box.get_top(oB), ol = box.get_bottom(oB)
                label.set_text(oLb, format_label(dStr, oh, (oh+ol)/2, ol, ol+(oh-ol)*0.25, ol+(oh-ol)*0.75, sQ))

        if array.size(bA) > lim
            box.delete(array.shift(bA)), line.delete(array.shift(lM)), line.delete(array.shift(lQ1)), line.delete(array.shift(lQ3)), label.delete(array.shift(lbA)), array.shift(tA)

if showNDOG
    process(trigger_ndog, session_close_price, open, time, ndBoxes, ndLM, ndLQ1, ndLQ3, ndLab, ndTim, ndFillCur, ndLineCur, ndTextCur, ndFillHis, ndMidCol, ndMidStyle, ndQuadCol, ndQuadStyle, showNdMid, showNdQuad, "NDOG", ndogKeep)

if showNWOG
    process(trigger_nwog, session_close_price, open, time, nwBoxes, nwLM, nwLQ1, nwLQ3, nwLab, nwTim, nwFillCur, nwLineCur, nwTextCur, nwFillHis, nwMidCol, nwNwStyle, nwQuadCol, nwNwQStyle, showNwMid, showNwQuad, "NWOG", nwogKeep)

// Extension logic
tX = bar_index + extBars
f_ext(b, m, q1, q3, lb) =>
    if array.size(b) > 0
        for i = 0 to array.size(b) - 1
            box.set_right(array.get(b, i), tX)
            if not na(array.get(m, i))
                line.set_x2(array.get(m, i), tX)
            if not na(array.get(q1, i))
                line.set_x2(array.get(q1, i), tX)
            if not na(array.get(q3, i))
                line.set_x2(array.get(q3, i), tX)
            label.set_x(array.get(lb, i), tX)

f_ext(ndBoxes, ndLM, ndLQ1, ndLQ3, ndLab)
f_ext(nwBoxes, nwLM, nwLQ1, nwLQ3, nwLab)
````
