# Equal Highs & Lows + Volume Profile

- url: https://www.tradingview.com/script/ylzaLAgz-Equal-Highs-Lows-Volume-Profile/
- type: indicator
- pine_id: PUB;37d18f845da7404ab13e35945c203a89
- version: 1.0

## Description

Equal Highs & Lows + Volume Profile

Two tools that answer the same question from opposite directions: where is price likely to react, and why. Equal highs and lows mark the resting liquidity on the chart itself. The volume profile on the right shows where the business actually got done.

Equal highs and equal lows

A single swing high is a level. Two swings that print at effectively the same price is engineered liquidity, because stops stack between them and above them, and that is what gets targeted.

So this draws nothing for a lone swing. Every confirmed pivot goes into a waiting list, invisible. Only when a second swing lands within tolerance of a waiting one does the pair become a level, and at that moment one line replaces the two, tagged EQH or EQL. Your chart stays empty except where the pattern genuinely exists.

If a third or fourth swing joins the same level, the tag updates to EQH x3 and the line thickens, because that is one pool of orders getting deeper rather than several separate levels.

Lines extend to the right until price trades through them. Once taken, the line dims and stops at the bar that swept it, so at any moment the bright lines are the liquidity still sitting on the chart and the faded ones are the record of what has already been run.

Two rules keep it honest. Waiting levels expire after a set number of bars, because a high from four hundred bars ago is not pairing with anything meaningful today. And a waiting level is dropped the moment price trades through it, so a swing that was taken out before finding a partner can never come back later to form a false pair.

Volume profile

Built from the lookback window and drawn as a horizontal histogram anchored past the last bar, clear of price.

Each bar's volume is distributed across every row its range covers rather than dumped at the closing price. That matters. A profile that assigns a whole bar's volume to one price is not describing where trading happened, and on wide bars the difference is severe.

The value area is calculated properly rather than approximated. It starts at the point of control and expands outward one row at a time, always taking the heavier neighbouring row, until it has captured the target share of total volume. The point of control, value area high and value area low are drawn across the lookback window with their prices labelled, and rows inside the value area are coloured distinctly from those outside.

An optional split shows how much of each row traded on up bars against down bars, which is useful for seeing where one side did the work.

Settings

Equality tolerance is the main control for the levels. It is measured as a percentage of ATR, so it scales across instruments and timeframes without retuning. Raise it if obvious equal highs on your chart are being missed, lower it if unrelated levels are being joined.

Swing length sets how significant a pivot must be before it counts. Minimum bars apart stops two swings from the same cluster registering as a pair, so you can demand a genuine return to the level.

Break trigger chooses whether a wick through the level counts as taken or whether only a body close does.

For the profile, rows and lookback control resolution against speed. Width, gap and transparency control how it sits next to price. Value area percentage defaults to the conventional seventy.

Notes

Pivots confirm after the swing completes, so a level appears on the chart some bars after the swings that formed it. The line is drawn back to the correct bar, but it cannot exist before the second pivot is confirmed.

The volume profile requires volume data from your feed. It is rebuilt on the last bar and updates live.

This is a levels and context tool. It does not generate entries, exits or directional signals, and makes no claim about what price will do at any level it draws.

Want a short version for the one-line summary field?

wait update the code i cant see the vp

Almost certainly it's drawing about 100 bars into the future, past the right edge of your visible chart. Also, ta.highest(high, 300) returns na until the chart has 300 bars, which kills it entirely on shorter history. Fixing both.

That's the Eq type's own x0 field, unrelated to the local I removed. Placement math confirms the overlay now sits over the last ~60 bars instead of 100 bars into empty space.

Two reasons it was invisible, both fixed.

It was drawing off-screen. The profile started 6 bars past the last candle and extended up to 90 bars further right, into empty space your chart doesn't show unless you scroll. There's now a Placement setting defaulting to "Overlay on price", which anchors the profile at the last bar and grows it leftward across your recent candles, the way TradingView's own visible-range profile sits. It can't be off-screen. "Right of price" is still there if you prefer the clean look and don't mind scrolling.

It needed 300 bars of history to draw anything at all. ta.highest(high, 300) returns nothing until the chart has 300 bars, so on shorter history the whole block was skipped silently. The range is now measured directly over whatever bars actually exist, so it renders on any chart.

I also made it tell you when it can't work: if the symbol has no volume data, you now get a label saying so instead of an empty chart that looks broken.

Width dropped to 60 bars and the gap to 2, which sits better in overlay mode. If it covers too much price action, lower the width or raise the transparency.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rcj101208

//@version=6
// ==============================================================================
//  EQUAL HIGHS & LOWS + VOLUME PROFILE
//
//  Left side of the chart: equal highs and equal lows. Two or more swings that
//  print at effectively the same price get one line and an EQH / EQL tag. A
//  lone swing draws nothing, because a single high is a level, not a pool.
//  Lines extend right until price trades through them, then dim and stop.
//
//  Right side: a volume profile built from the lookback window, drawn as a
//  horizontal histogram anchored past the last bar, with the point of control
//  and the value area marked.
// ==============================================================================
indicator("Equal Highs & Lows + Volume Profile", "EQH/EQL + VP", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1000)

// -- Equal highs and lows -----------------------------------------------------
gE        = "Equal highs and lows"
swLen     = input.int(8, "Swing length", minval = 2, maxval = 50, group = gE, tooltip = "Bars either side of a swing. Higher finds fewer, more significant levels.")
tolPct    = input.float(10, "Equality tolerance (% of ATR)", minval = 1, maxval = 100, step = 1, group = gE, tooltip = "How close two swings must print to count as equal. This is the main dial. Raise it if obvious equal highs are being missed.")
minGap    = input.int(3, "Minimum bars apart", minval = 0, maxval = 200, group = gE, tooltip = "Stops two swings in the same cluster of bars registering as a pair.")
pendLife  = input.int(200, "Level expiry (bars)", minval = 10, maxval = 2000, group = gE, tooltip = "How long an unmatched swing stays eligible for a partner.")
breakMode = input.string("Wick through", "Break trigger", options = ["Wick through", "Close through"], group = gE)
stopAtBrk = input.bool(true, "Stop line at the break", group = gE)
padBars   = input.int(5, "Extend past current bar", minval = 0, maxval = 100, group = gE)
maxKeep   = input.int(25, "Max levels per side", minval = 3, maxval = 80, group = gE)
dimAmt    = input.int(72, "Broken line dim amount", minval = 0, maxval = 95, step = 5, group = gE)
showTags  = input.bool(true, "Show EQH / EQL tags", group = gE)
colEQH    = input.color(#26a69a, "Equal highs", group = gE)
colEQL    = input.color(#ef5350, "Equal lows", group = gE)
eqWidth   = input.int(1, "Line width", minval = 1, maxval = 4, group = gE)

// -- Volume profile -----------------------------------------------------------
gV       = "Volume profile"
showVP   = input.bool(true, "Show volume profile", group = gV)
vpPlace  = input.string("Overlay on price", "Placement", options = ["Overlay on price", "Right of price"], group = gV, tooltip = "Overlay on price anchors the profile at the last bar and grows LEFT across recent candles, so it is always in view. Right of price puts it in the empty space past the last bar, which looks cleaner but needs the chart scrolled right to see it.")
vpLen    = input.int(300, "Lookback (bars)", minval = 20, maxval = 900, group = gV, tooltip = "Uses whatever history is available if the chart has fewer bars than this.")
vpRows   = input.int(80, "Rows", minval = 10, maxval = 200, group = gV, tooltip = "More rows give finer price resolution and a slower script.")
vpWidth  = input.int(60, "Profile width (bars)", minval = 5, maxval = 400, group = gV)
vpGap    = input.int(2, "Gap from the last bar", minval = 0, maxval = 100, group = gV)
vaPct    = input.float(70, "Value area (%)", minval = 30, maxval = 95, step = 5, group = gV)
splitUD  = input.bool(false, "Split buying and selling volume", group = gV, tooltip = "Overlays the share of each row that traded on up bars. Doubles the number of drawings.")
showVALn = input.bool(true, "Draw POC / VAH / VAL across the chart", group = gV)
vpTransp = input.int(65, "Profile transparency", minval = 0, maxval = 95, step = 5, group = gV)
colVA    = input.color(#2962ff, "Value area", group = gV)
colOut   = input.color(#787b86, "Outside value area", group = gV)
colPOC   = input.color(#ff9800, "Point of control", group = gV)
colUp    = input.color(#089981, "Up volume", group = gV)
atrLen   = input.int(14, "ATR length", minval = 1, group = gV)

// ==============================================================================
//  GLOBAL CALCULATIONS  (every ta.* at global scope, as v6 requires)
// ==============================================================================
atr  = ta.atr(atrLen)
ph   = ta.pivothigh(high, swLen, swLen)
pl   = ta.pivotlow(low, swLen, swLen)
tol  = nz(atr) * tolPct / 100.0

// ==============================================================================
//  EQUAL HIGH / LOW STORE
//   Pend = a swing with no partner yet. Nothing is drawn for it.
//   Eq   = two or more swings at the same price. One line is drawn.
// ==============================================================================
type Pend
    float price
    int   bx

type Eq
    float price
    int   x0
    line  ln
    label lb
    int   n
    bool  broken

var array<Pend> pendHi = array.new<Pend>()
var array<Pend> pendLo = array.new<Pend>()
var array<Eq>   eqHi   = array.new<Eq>()
var array<Eq>   eqLo   = array.new<Eq>()

findEq(array<Eq> arr, float p) =>
    idx = -1
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            e = arr.get(i)
            if not e.broken and math.abs(e.price - p) <= tol
                idx := i
                break
    idx

findPend(array<Pend> arr, float p, int pb) =>
    idx = -1
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            q = arr.get(i)
            if math.abs(q.price - p) <= tol and (pb - q.bx) >= minGap
                idx := i
                break
    idx

onSwing(array<Pend> pend, array<Eq> eqs, float p, bool isHigh) =>
    pb  = bar_index - swLen
    col = isHigh ? colEQH : colEQL
    hit = findEq(eqs, p)
    if hit >= 0
        e = eqs.get(hit)
        e.n     += 1
        e.price := isHigh ? math.max(e.price, p) : math.min(e.price, p)
    else
        q = findPend(pend, p, pb)
        if q >= 0
            pe = pend.get(q)
            pend.remove(q)
            lvl = isHigh ? math.max(pe.price, p) : math.min(pe.price, p)
            ln  = line.new(pe.bx, lvl, bar_index + padBars, lvl, color = col, width = eqWidth)
            lb  = showTags ? label.new(bar_index + padBars, lvl, isHigh ? "EQH" : "EQL", style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = size.small) : na
            eqs.push(Eq.new(lvl, pe.bx, ln, lb, 2, false))
            if eqs.size() > maxKeep
                old = eqs.shift()
                if not na(old.ln)
                    line.delete(old.ln)
                if not na(old.lb)
                    label.delete(old.lb)
        else
            pend.push(Pend.new(p, pb))
            if pend.size() > maxKeep
                pend.shift()
    eqs.size()

prunePend(array<Pend> arr, bool isHigh) =>
    i = 0
    while i < arr.size()
        q    = arr.get(i)
        dead = (bar_index - q.bx) > pendLife or (isHigh ? high > q.price : low < q.price)
        if dead
            arr.remove(i)
        else
            i += 1
    arr.size()

updateEq(array<Eq> eqs, bool isHigh) =>
    col = isHigh ? colEQH : colEQL
    if eqs.size() > 0
        for i = 0 to eqs.size() - 1
            e = eqs.get(i)
            if e.broken
                if not stopAtBrk
                    line.set_x2(e.ln, bar_index + padBars)
            else
                gone = bar_index > e.x0 and (breakMode == "Close through" ? (isHigh ? close > e.price : close < e.price) : (isHigh ? high > e.price : low < e.price))
                if gone
                    e.broken := true
                    line.set_color(e.ln, color.new(col, dimAmt))
                    line.set_style(e.ln, line.style_dotted)
                    line.set_width(e.ln, 1)
                    line.set_x2(e.ln, stopAtBrk ? bar_index : bar_index + padBars)
                    if not na(e.lb)
                        label.set_textcolor(e.lb, color.new(col, dimAmt))
                else
                    line.set_xy1(e.ln, e.x0, e.price)
                    line.set_xy2(e.ln, bar_index + padBars, e.price)
                    line.set_width(e.ln, int(math.min(eqWidth + e.n - 2, 4)))
                    if not na(e.lb)
                        label.set_xy(e.lb, bar_index + padBars, e.price)
                        label.set_text(e.lb, (isHigh ? "EQH" : "EQL") + (e.n > 2 ? " x" + str.tostring(e.n) : ""))
    eqs.size()

if not na(ph)
    onSwing(pendHi, eqHi, ph, true)

if not na(pl)
    onSwing(pendLo, eqLo, pl, false)

prunePend(pendHi, true)
prunePend(pendLo, false)

updateEq(eqHi, true)
updateEq(eqLo, false)

// ==============================================================================
//  VOLUME PROFILE
//  Rebuilt on the last bar only, and the previous drawings are cleared first.
// ==============================================================================
var array<box> vpBox = array.new<box>()
var line  lnPOC = na
var line  lnVAH = na
var line  lnVAL = na
var label lbPOC = na
var label lbVAH = na
var label lbVAL = na

var label vpWarn = na

if showVP and barstate.islast
    // Clear the previous render
    if vpBox.size() > 0
        for i = 0 to vpBox.size() - 1
            box.delete(vpBox.get(i))
        vpBox.clear()

    // Use whatever history the chart actually has, so short charts still render
    nBars = int(math.max(2, math.min(vpLen, bar_index + 1)))

    vpHi = high
    vpLo = low
    for i = 0 to nBars - 1
        vpHi := math.max(vpHi, nz(high[i], vpHi))
        vpLo := math.min(vpLo, nz(low[i], vpLo))

    span   = vpHi - vpLo
    rowH   = span > 0 ? span / vpRows : 0.0
    prof   = array.new<float>(vpRows, 0.0)
    profUp = array.new<float>(vpRows, 0.0)

    if rowH > 0
        for i = 0 to nBars - 1
            v = nz(volume[i])
            if v > 0
                r0 = int(math.max(0, math.min(vpRows - 1, math.floor((nz(low[i], vpLo) - vpLo) / rowH))))
                r1 = int(math.max(0, math.min(vpRows - 1, math.floor((nz(high[i], vpLo) - vpLo) / rowH))))
                share = v / (r1 - r0 + 1)
                isUp  = nz(close[i]) >= nz(open[i])
                for r = r0 to r1
                    prof.set(r, prof.get(r) + share)
                    if isUp
                        profUp.set(r, profUp.get(r) + share)

    maxV  = prof.max()
    total = prof.sum()

    // Say so plainly rather than drawing nothing and looking broken
    if total <= 0
        if na(vpWarn)
            vpWarn := label.new(bar_index, high, "", style = label.style_label_left, color = color.new(#ff9800, 20), textcolor = color.white, size = size.small)
        label.set_xy(vpWarn, bar_index, high)
        label.set_text(vpWarn, "No volume data on this symbol, so no profile")
    else if not na(vpWarn)
        label.delete(vpWarn)
        vpWarn := na

    if maxV > 0 and total > 0
        pocIdx = prof.indexof(maxV)

        // Value area: grow outward from the POC, always taking the heavier side
        goal = total * vaPct / 100.0
        acc  = prof.get(pocIdx)
        vaUp = pocIdx
        vaDn = pocIdx
        while acc < goal and (vaUp < vpRows - 1 or vaDn > 0)
            nUp = vaUp < vpRows - 1 ? prof.get(vaUp + 1) : -1.0
            nDn = vaDn > 0 ? prof.get(vaDn - 1) : -1.0
            if nUp < 0 and nDn < 0
                break
            if nUp >= nDn
                vaUp += 1
                acc  += nUp
            else
                vaDn -= 1
                acc  += nDn

        // Overlay grows LEFT from the anchor so it is always on screen.
        // Right-of-price grows into the empty space past the last bar.
        toRight = vpPlace == "Right of price"
        anchor  = bar_index + vpGap

        for r = 0 to vpRows - 1
            v = prof.get(r)
            w = int(math.round(vpWidth * v / maxV))
            if w > 0
                bot  = vpLo + rowH * r
                top  = vpLo + rowH * (r + 1)
                xa   = toRight ? anchor : anchor - w
                xb   = toRight ? anchor + w : anchor
                inVA = r >= vaDn and r <= vaUp
                col  = r == pocIdx ? colPOC : inVA ? colVA : colOut
                tp   = int(r == pocIdx ? math.max(vpTransp - 25, 0) : vpTransp)
                vpBox.push(box.new(xa, top, xb, bot, border_color = color.new(col, 100), bgcolor = color.new(col, tp)))
                if splitUD
                    wu = int(math.round(vpWidth * profUp.get(r) / maxV))
                    if wu > 0
                        xu = toRight ? anchor + wu : anchor
                        xv = toRight ? anchor : anchor - wu
                        vpBox.push(box.new(int(math.min(xu, xv)), top, int(math.max(xu, xv)), bot, border_color = color.new(colUp, 100), bgcolor = color.new(colUp, int(math.max(tp - 10, 0)))))

        pocPx = vpLo + rowH * (pocIdx + 0.5)
        vahPx = vpLo + rowH * (vaUp + 1)
        valPx = vpLo + rowH * vaDn
        xL    = showVALn ? bar_index - nBars + 1 : (toRight ? anchor : anchor - vpWidth)
        xR    = toRight ? anchor + vpWidth : anchor + vpGap

        if na(lnPOC)
            lnPOC := line.new(xL, pocPx, xR, pocPx, color = colPOC, width = 2)
            lnVAH := line.new(xL, vahPx, xR, vahPx, color = color.new(colVA, 30), style = line.style_dashed, width = 1)
            lnVAL := line.new(xL, valPx, xR, valPx, color = color.new(colVA, 30), style = line.style_dashed, width = 1)
            lbPOC := label.new(xR, pocPx, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = colPOC, size = size.small)
            lbVAH := label.new(xR, vahPx, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = colVA, size = size.small)
            lbVAL := label.new(xR, valPx, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = colVA, size = size.small)
        else
            line.set_xy1(lnPOC, xL, pocPx)
            line.set_xy2(lnPOC, xR, pocPx)
            line.set_xy1(lnVAH, xL, vahPx)
            line.set_xy2(lnVAH, xR, vahPx)
            line.set_xy1(lnVAL, xL, valPx)
            line.set_xy2(lnVAL, xR, valPx)
            label.set_xy(lbPOC, xR, pocPx)
            label.set_xy(lbVAH, xR, vahPx)
            label.set_xy(lbVAL, xR, valPx)

        label.set_text(lbPOC, "POC " + str.tostring(pocPx, format.mintick))
        label.set_text(lbVAH, "VAH " + str.tostring(vahPx, format.mintick))
        label.set_text(lbVAL, "VAL " + str.tostring(valPx, format.mintick))

// ==============================================================================
//  ALERTS
// ==============================================================================
alertcondition(not na(ph), "New swing high", "New swing high confirmed on {{ticker}} {{interval}}")
alertcondition(not na(pl), "New swing low", "New swing low confirmed on {{ticker}} {{interval}}")
````
