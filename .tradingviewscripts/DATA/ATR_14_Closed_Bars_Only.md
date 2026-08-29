<!-- tradingview-pine-id: PUB;26b291ecda274cd29d387bb958c0e451 -->
<!-- tradingviewscripts-format: 1 -->
# ATR (14) — Closed Bars Only

Source: https://www.tradingview.com/script/D4OmXSk5-ATR-Displayed-on-screen/

## Description

ATR displayed in the bottom left of the chart. Custom cycles available.

---

## Source Code

````pine
//@version=6
indicator("ATR (14) — Closed Bars Only", overlay = true)

// ── Inputs ──────────────────────────────────────────────────────────
atrLength = input.int(14, "ATR Length", minval = 1)

showProj  = input.bool(true, "Show ATR projection", group = "Projection")
atrMult   = input.float(1.0, "ATR multiplier", minval = 0.0, step = 0.1, group = "Projection")
projBars  = input.int(20, "Project forward (bars)", minval = 1, maxval = 400, group = "Projection")
projColor = input.color(color.new(color.gray, 20), "Line colour", group = "Projection")

// ── Calculation (closed bars only) ──────────────────────────────────
atrRaw    = ta.atr(atrLength)   // must run every bar to keep RMA state correct
atrClosed = atrRaw[1]           // value as of the previous bar's close
atrOffset = atrClosed * atrMult // the projected distance
refClose  = close[1]            // the last completed close — projection anchor

multStr   = str.tostring(atrMult, "#.##")

// ── Readout ─────────────────────────────────────────────────────────
var table t = table.new(position.bottom_left, 1, 1,
     bgcolor = color.new(color.black, 20), border_width = 1)

if barstate.islast and not na(atrClosed)
    txt = "ATR(" + str.tostring(atrLength) + "): " + str.tostring(atrClosed, format.mintick)
    if atrMult != 1.0
        txt := txt + "   ×" + multStr + " = " + str.tostring(atrOffset, format.mintick)
    table.cell(t, 0, 0, txt, text_color = color.white, text_size = size.normal)

// ── Projection lines ────────────────────────────────────────────────
var line  upLine = na
var line  dnLine = na
var label upLbl  = na
var label dnLbl  = na

if barstate.islast
    active  = showProj and not na(atrClosed)
    upPrice = refClose + atrOffset
    dnPrice = refClose - atrOffset
    x1      = bar_index - 1          // the reference (last closed) bar
    x2      = bar_index + projBars   // how far into the future to draw

    if active
        if na(upLine)
            upLine := line.new(x1, upPrice, x2, upPrice, xloc = xloc.bar_index,
                 style = line.style_dashed, color = projColor, width = 1)
            dnLine := line.new(x1, dnPrice, x2, dnPrice, xloc = xloc.bar_index,
                 style = line.style_dashed, color = projColor, width = 1)
            upLbl  := label.new(x2, upPrice, "", xloc = xloc.bar_index,
                 style = label.style_label_left, color = color.new(color.black, 100),
                 textcolor = projColor, size = size.small)
            dnLbl  := label.new(x2, dnPrice, "", xloc = xloc.bar_index,
                 style = label.style_label_left, color = color.new(color.black, 100),
                 textcolor = projColor, size = size.small)
        else
            line.set_xy1(upLine, x1, upPrice)
            line.set_xy2(upLine, x2, upPrice)
            line.set_color(upLine, projColor)
            line.set_xy1(dnLine, x1, dnPrice)
            line.set_xy2(dnLine, x2, dnPrice)
            line.set_color(dnLine, projColor)
            label.set_xy(upLbl, x2, upPrice)
            label.set_xy(dnLbl, x2, dnPrice)
            label.set_textcolor(upLbl, projColor)
            label.set_textcolor(dnLbl, projColor)

        label.set_text(upLbl, "+" + multStr + "×ATR  " + str.tostring(upPrice, format.mintick))
        label.set_text(dnLbl, "−" + multStr + "×ATR  " + str.tostring(dnPrice, format.mintick))
    else
        if not na(upLine)
            line.delete(upLine)
            line.delete(dnLine)
            label.delete(upLbl)
            label.delete(dnLbl)
            upLine := na
            dnLine := na
            upLbl  := na
            dnLbl  := na
````
