# Initial Balance Extensions - GOLD

- url: https://www.tradingview.com/script/imTmrpHz-Initial-Balance-Extensions-GOLD/
- type: indicator
- pine_id: PUB;effb082cc0d1493dabe7a4d9200e732a
- version: 2.0

## Description

Initial Balance for Gold which starts at 8:20am EST

Lines are labelled
Stats Table
Range in Points

## Source Code

````pine
// Released under the Mozilla Public License 2.0 — see https://mozilla.org/MPL/2.0/
//@version=6

indicator("Initial Balance Extensions - GOLD", shorttitle="GOLD IB Extensions", overlay=true, max_bars_back=5000)

// ╔═════════════════════╗
// ║   USER PREFERENCES  ║
// ╚═════════════════════╝
// Modified for COMEX Gold Open (08:20 ET)
ibWindow = input.session("0820-0920", "Gold IB window", group="Range Settings", tooltip="First hour of Gold trading (COMEX Open)")
sessionName = input.string("GOLD IB", "Label Prefix", options=["GOLD IB", "IB", "OR"], group="Range Settings")

drawExtras = input.bool(true, "Plot whole-number extensions (1x…)", group="Display")
maxWholeExt = input.int(5, "Max whole-number extension (x)", minval=1, maxval=9, group="Display")
drawHalfLadder = input.bool(true, "Plot 0.5Δ ladder (±NΔ)", group="Display")
ladderMaxDelta = input.float(4.5, "Ladder max Δ (in 0.5 steps)", minval=0.5, maxval=4.5, step=0.5, group="Display")
drawMidPoints = input.bool(true, "Plot 50 % mid-levels (Mid)", group="Display")
showRangeLabel = input.bool(true, "Show Range Info Label (Points)", group="Display")
shadeWindow = input.bool(false, "Highlight window on chart", group="Display")
renderLabels = input.bool(true, "Show text labels", group="Display")
shadeZones = input.bool(true, "Tint high-low area", group="Display")
thisDayOnly = input.bool(true, "Keep only today's levels", group="Display")
showDeltaInfo = input.bool(false, "Show 20-day Δ stats", group="Display")

// FIX: three independent price-on-label toggles — High/Low together, Mid on
// its own, and the extension ladder (whole-number + 0.5Δ) on its own.
showHighLowPriceInput = input.bool(false, "Show Price on High/Low Labels (IB High/Low)", group="Display")
showMidPriceInput     = input.bool(false, "Show Price on Mid Label (IB Mid)", group="Display")
showExtPriceInput     = input.bool(false, "Show Price on Extension Labels", group="Display")

// Manual position control for the Range label — X is a bar offset from the
// start of the IB window, Y is a price offset from the IB High. Both default
// to 0, so out of the box it sits exactly at the IB High (left edge); nudge
// Y up (and/or X) to clear the shaded zone or move it wherever reads best.
rangeLabelXOffset = input.int(0, "Range Label X Offset (bars)", group="Display")
rangeLabelYOffset = input.float(0.0, "Range Label Y Offset (price)", group="Display", step=0.1)

lblSizeOpt = input.string("Small", "Label size", options=["Auto","Huge","Large","Normal","Small","Tiny"], group="Styling")
lineWidth = input.int(1, "Line width", group="Styling")
// Gold theme colors
clrHigh = input.color(#FFD700, "High-side colour", group="Styling")
clrLow  = input.color(#C0C0C0, "Low-side colour",   group="Styling")
clrMid  = input.color(#FFD700aa, "Mid-level colour", group="Styling")
mainStyle   = input.string("Solid",  "Main level style", options=["Solid","Dashed","Dotted"], group="Styling")
extStyle    = input.string("Dashed", "Whole-number level style", options=["Solid","Dashed","Dotted"], group="Styling")
ladderStyle = input.string("Dashed", "Ladder level style", options=["Solid","Dashed","Dotted"], group="Styling")
midStyle    = input.string("Dotted", "Mid-level style", options=["Solid","Dashed","Dotted"], group="Styling")
zoneTint    = input.color(color.new(#FFD700, 92), "Zone fill colour", group="Styling")
rangeLabelColor   = input.color(color.gray, "Range Label Colour", group="Styling")
rangeLabelSizeOpt = input.string("Small", "Range Label Size", options=["Auto","Huge","Large","Normal","Small","Tiny"], group="Styling")

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────
styleOf(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        =>          line.style_dashed

within(string t) =>
    not na(time(timeframe.period, t, "America/New_York"))

getLblSize() =>
    switch lblSizeOpt
        "Huge"   => size.huge
        "Large"  => size.large
        "Small"  => size.small
        "Tiny"   => size.tiny
        "Auto"   => size.auto
        =>          size.normal

// Separate size lookup for the Range label, independent of the main label size
getRangeLblSize() =>
    switch rangeLabelSizeOpt
        "Huge"   => size.huge
        "Large"  => size.large
        "Small"  => size.small
        "Tiny"   => size.tiny
        "Auto"   => size.auto
        =>          size.normal

fmtMult(float k, bool isBelow) =>
    string prefix = isBelow ? "-" : ""
    prefix + str.tostring(math.abs(k), "#.#") + "x"

fmtIBLabel(float k, bool isBelow) =>
    sessionName + " " + fmtMult(k, isBelow)

// FIX: appends ": <price>" to a label's base text when the relevant toggle is on.
// Shared by the High/Low/Mid labels and the extension-ladder labels so each
// group's price display is driven by one line of logic instead of three.
appendPrice(string baseTxt, bool showPrice, float val) =>
    showPrice ? baseTxt + ": " + str.tostring(val, format.mintick) : baseTxt

mkOrUpdLabel(label lbIn, float y, color clr, string txt, int xPos) =>
    var label out = lbIn
    if na(out)
        out := label.new(xPos, y, text=txt, textcolor=clr, style=label.style_label_left, color=color.new(color.black, 100), size=getLblSize(), textalign=text.align_left)
    else
        label.set_x(out, xPos)
        label.set_y(out, y)
        label.set_text(out, txt)
        label.set_textcolor(out, clr)
        label.set_size(out, getLblSize())
    out

setRightEnd(line ln, int rightEdgeX) =>
    if not na(ln)
        int x1 = line.get_x2(ln)
        line.set_x2(ln, math.max(x1, rightEdgeX))

// ──────────────────────────────────────────────
// Logic
// ──────────────────────────────────────────────
var float delta = na
var int barsCount = 0
var array<float> dBuf = array.new_float(0)
var float currentIbHi  = na, var float currentIbLo  = na, var float currentIbMid = na
var line lnH = na, var line lnL = na, var line lnM = na
var label lbH = na, var label lbL = na, var label lbM = na, var label lbRange = na

var array<line> extUpLines = array.new_line(), var array<line> extDnLines = array.new_line()
var array<line> ladderLines = array.new_line(), var array<label> ladderLabels = array.new_label(), var array<float> ladderKVals = array.new_float()
var box ibBox = na

bool active = within(ibWindow)
bgcolor(shadeWindow and active ? color.new(#FFD700, 90) : na)

if active
    barsCount += 1

if active[1] and not active
    float ibHi = high[1], float ibLo = low[1]
    for i = 1 to barsCount
        ibLo := math.min(ibLo, low[i]), ibHi := math.max(ibHi, high[i])
    delta := ibHi - ibLo
    currentIbHi := ibHi, currentIbLo := ibLo, currentIbMid := (ibHi + ibLo) / 2.0

    if array.size(dBuf) >= 20
        array.shift(dBuf)
    array.push(dBuf, delta)

    if thisDayOnly
        line.delete(lnH), line.delete(lnL), line.delete(lnM)
        label.delete(lbH), label.delete(lbL), label.delete(lbM), label.delete(lbRange)
        if array.size(extUpLines) > 0
            for l in extUpLines
                line.delete(l)
            array.clear(extUpLines)
        if array.size(extDnLines) > 0
            for l in extDnLines
                line.delete(l)
            array.clear(extDnLines)
        if array.size(ladderLines) > 0
            for l in ladderLines
                line.delete(l)
            array.clear(ladderLines)
        if array.size(ladderLabels) > 0
            for lb in ladderLabels
                label.delete(lb)
            array.clear(ladderLabels)
        array.clear(ladderKVals)

    int x0 = bar_index[barsCount], int x1 = bar_index
    lnH := line.new(x0, ibHi, x1, ibHi, width=lineWidth, color=clrHigh, style=styleOf(mainStyle))
    lnL := line.new(x0, ibLo, x1, ibLo, width=lineWidth, color=clrLow, style=styleOf(mainStyle))
    if drawMidPoints
        lnM := line.new(x0, currentIbMid, x1, currentIbMid, width=lineWidth, color=clrMid, style=styleOf(midStyle))

    if renderLabels
        lbH := mkOrUpdLabel(lbH, ibHi, clrHigh, appendPrice(sessionName + " High", showHighLowPriceInput, ibHi), x1)
        lbL := mkOrUpdLabel(lbL, ibLo, clrLow, appendPrice(sessionName + " Low", showHighLowPriceInput, ibLo), x1)
        if drawMidPoints
            lbM := mkOrUpdLabel(lbM, currentIbMid, clrMid, appendPrice(sessionName + " Mid", showMidPriceInput, currentIbMid), x1)

    if showRangeLabel
        string rangeTxt = sessionName + " Range: " + str.tostring(delta, format.mintick) + " pts"
        // Note: this must use yloc=yloc.price (not the original yloc.abovebar) —
        // abovebar ignores whatever Y coordinate is passed in and always positions
        // relative to the actual candle at that bar, which is what buried this
        // label inside the shaded zone in the first place and would also silently
        // make the Y offset input below do nothing. With yloc.price, X/Y offsets
        // both default to 0 (so it starts at exactly the IB High, left edge) and
        // are fully adjustable from here.
        lbRange := label.new(x0 + rangeLabelXOffset, ibHi + rangeLabelYOffset, text=rangeTxt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=rangeLabelColor, style=label.style_label_down, size=getRangeLblSize())

    if drawExtras
        for n = 1 to maxWholeExt
            float upY = ibHi + delta * n, float dnY = ibLo - delta * n
            array.push(extUpLines, line.new(x0, upY, x1, upY, width=lineWidth, color=clrHigh, style=styleOf(extStyle)))
            array.push(extDnLines, line.new(x0, dnY, x1, dnY, width=lineWidth, color=clrLow, style=styleOf(extStyle)))
            if renderLabels
                array.push(ladderLabels, label.new(x1, upY, text=appendPrice(fmtIBLabel(n, false), showExtPriceInput, upY), textcolor=clrHigh, style=label.style_label_left, color=color.new(color.black, 100), size=getLblSize()))
                array.push(ladderKVals, float(n))
                array.push(ladderLabels, label.new(x1, dnY, text=appendPrice(fmtIBLabel(n, true), showExtPriceInput, dnY), textcolor=clrLow, style=label.style_label_left, color=color.new(color.black, 100), size=getLblSize()))
                array.push(ladderKVals, float(-n))

    if drawHalfLadder
        int steps = math.round(ladderMaxDelta / 0.5)
        for i = 1 to steps
            float k = i * 0.5
            if math.round(k) != k
                float yU = ibHi + delta * k, float yD = ibLo - delta * k
                array.push(ladderLines, line.new(x0, yU, x1, yU, width=lineWidth, color=clrHigh, style=styleOf(ladderStyle)))
                array.push(ladderLines, line.new(x0, yD, x1, yD, width=lineWidth, color=clrLow, style=styleOf(ladderStyle)))
                if renderLabels
                    array.push(ladderLabels, label.new(x1, yU, text=appendPrice(fmtIBLabel(k, false), showExtPriceInput, yU), textcolor=clrHigh, style=label.style_label_left, color=color.new(color.black, 100), size=getLblSize()))
                    array.push(ladderKVals, k)
                    array.push(ladderLabels, label.new(x1, yD, text=appendPrice(fmtIBLabel(k, true), showExtPriceInput, yD), textcolor=clrLow, style=label.style_label_left, color=color.new(color.black, 100), size=getLblSize()))
                    array.push(ladderKVals, -k)

    if shadeZones
        ibBox := box.new(x0, ibHi, x1, ibLo, bgcolor=zoneTint, border_color=#00000000)
    barsCount := 0

// ──────────────────────────────────────────────
// Maintenance
// ──────────────────────────────────────────────
if not active and not na(currentIbHi)
    setRightEnd(lnH, bar_index)
    setRightEnd(lnL, bar_index)
    if drawMidPoints
        setRightEnd(lnM, bar_index)

    if renderLabels
        if not na(lnH)
            lbH := mkOrUpdLabel(lbH, line.get_y1(lnH), clrHigh, appendPrice(sessionName + " High", showHighLowPriceInput, line.get_y1(lnH)), bar_index)
        if not na(lnL)
            lbL := mkOrUpdLabel(lbL, line.get_y1(lnL), clrLow, appendPrice(sessionName + " Low", showHighLowPriceInput, line.get_y1(lnL)), bar_index)
        if drawMidPoints and not na(lnM)
            lbM := mkOrUpdLabel(lbM, line.get_y1(lnM), clrMid, appendPrice(sessionName + " Mid", showMidPriceInput, line.get_y1(lnM)), bar_index)

    if array.size(extUpLines) > 0
        for l in extUpLines
            setRightEnd(l, bar_index)
    if array.size(extDnLines) > 0
        for l in extDnLines
            setRightEnd(l, bar_index)
    if array.size(ladderLines) > 0
        for l in ladderLines
            setRightEnd(l, bar_index)

    if renderLabels and array.size(ladderLabels) > 0
        for i = 0 to array.size(ladderLabels) - 1
            label lb = array.get(ladderLabels, i)
            float k = array.get(ladderKVals, i)
            float y = k >= 0 ? line.get_y1(lnH) + delta * k : line.get_y1(lnL) + delta * k
            label.set_xy(lb, bar_index, y)
            label.set_text(lb, appendPrice(fmtIBLabel(math.abs(k), k < 0), showExtPriceInput, y))

// ╔═════════════════════╗
// ║ PRICE SCALE MARKERS ║
// ╚═════════════════════╝
plot(currentIbHi, title="Marker High", color=color.new(clrHigh, 100), trackprice=true, show_last=1, editable=false)
plot(currentIbLo, title="Marker Low", color=color.new(clrLow, 100), trackprice=true, show_last=1, editable=false)
plot(drawMidPoints ? currentIbMid : na, title="Marker Mid", color=color.new(clrMid, 100), trackprice=true, show_last=1, editable=false)

// ╔═════════════════════╗
// ║   DELTA ANALYTICS   ║
// ╚═════════════════════╝
sentiment() =>
    int sz = array.size(dBuf)
    if sz == 0 or na(delta)
        "N/A"
    else
        float hi  = array.max(dBuf)
        float lo  = array.min(dBuf)
        float avg = array.avg(dBuf)
        float diffHi = math.abs(delta - hi)
        float diffLo = math.abs(delta - lo)
        float diffAv = math.abs(delta - avg)
        if diffHi < diffLo and diffHi < diffAv
            "Wide"
        else if diffLo < diffHi and diffLo < diffAv
            "Narrow"
        else
            "Average"

var table statTbl = table.new(position.bottom_left, 2, 6)
if showDeltaInfo and array.size(dBuf) > 0 and not na(delta)
    table.cell(statTbl, 0, 0, sessionName + "-Δ Stats", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 0, 1, "20-day Max", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 1, 1, str.tostring(array.max(dBuf), "#.####"), bgcolor=color.black, text_color=clrHigh)
    table.cell(statTbl, 0, 2, "20-day Mean", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 1, 2, str.tostring(array.avg(dBuf), "#.####"), bgcolor=color.black, text_color=clrMid)
    table.cell(statTbl, 0, 3, "20-day Min", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 1, 3, str.tostring(array.min(dBuf), "#.####"), bgcolor=color.black, text_color=clrLow)
    table.cell(statTbl, 0, 4, "Today Δ", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 1, 4, str.tostring(delta), bgcolor=color.black, text_color=color.blue)
    table.cell(statTbl, 0, 5, "Status", bgcolor=color.black, text_color=color.white)
    table.cell(statTbl, 1, 5, sentiment(), bgcolor=color.black, text_color=color.white)
````
