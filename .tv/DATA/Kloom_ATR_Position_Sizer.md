<!-- tradingview-pine-id: PUB;2adbd708ebcc4290b38e72a4ab51ee93 -->
<!-- tradingviewscripts-format: 1 -->
# Kloom ATR Position Sizer

Source: https://www.tradingview.com/script/ApizScHE-Kloom-ATR-Position-Sizer-Risk-Based-Quantity-Calc/

## Description

Stop guessing position size. Enter your equity and risk percentage, read the exact quantity for an ATR-based stop.

How it works
• Stop distance = ATR(14) x multiplier (both configurable).
• Quantity = (equity x risk%) / stop distance - the classic fixed-fractional formula.
• The table shows risk in money, current ATR, stop distance, resulting quantity, position value and implied leverage (highlighted red above 3x, as a warning that the position is larger than the account).
• Stop levels are drawn from the current price in both directions.

How to use it
Set your equity once, read the quantity before every entry. Works on crypto, forex, futures and stocks - anything with a price and an ATR.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KloomStudio

//@version=6
indicator("Kloom ATR Position Sizer", shorttitle="K.Sizer", overlay=true)

// ── Inputs ─────────────────────────────────────────────────────────────────────
grpAcc  = "Account"
equity  = input.float(10000, "Account equity", minval=10, group=grpAcc)
riskPct = input.float(1.0, "Risk per trade (%)", minval=0.1, maxval=10, step=0.1, group=grpAcc)

grpAtr  = "Stop distance"
atrLen  = input.int(14, "ATR length", minval=1, maxval=100, group=grpAtr)
atrMult = input.float(2.0, "ATR multiplier for stop", minval=0.5, maxval=10, step=0.5, group=grpAtr)

grpViz  = "Display"
showLvl = input.bool(true, "Show stop levels from current price", group=grpViz)

// ── Sizing math ────────────────────────────────────────────────────────────────
atr        = ta.atr(atrLen)
stopDist   = atr * atrMult
riskMoney  = equity * riskPct / 100
qty        = stopDist > 0 ? riskMoney / stopDist : na
posValue   = qty * close
leverage   = posValue / equity

longStop  = close - stopDist
shortStop = close + stopDist

// ── Plots ──────────────────────────────────────────────────────────────────────
plot(showLvl ? longStop : na,  "Long stop",  color=color.new(color.teal, 40), style=plot.style_linebr)
plot(showLvl ? shortStop : na, "Short stop", color=color.new(color.red, 40),  style=plot.style_linebr)

// ── Table ──────────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast
    hdr  = color.new(color.black, 20)
    cell = color.new(color.black, 40)
    table.cell(t, 0, 0, "Risk",        text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 0, str.tostring(riskMoney, "#.##") + " (" + str.tostring(riskPct, "#.#") + "%)", text_color=color.white, bgcolor=cell, text_size=size.small)
    table.cell(t, 0, 1, "ATR",         text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 1, str.tostring(atr, format.mintick), text_color=color.white, bgcolor=cell, text_size=size.small)
    table.cell(t, 0, 2, "Stop dist",   text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 2, str.tostring(stopDist, format.mintick), text_color=color.white, bgcolor=cell, text_size=size.small)
    table.cell(t, 0, 3, "Qty",         text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 3, str.tostring(qty, "#.####"), text_color=color.white, bgcolor=color.new(color.teal, 30), text_size=size.small)
    table.cell(t, 0, 4, "Pos. value",  text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 4, str.tostring(posValue, "#.##"), text_color=color.white, bgcolor=cell, text_size=size.small)
    table.cell(t, 0, 5, "Leverage",    text_color=color.white, bgcolor=hdr,  text_size=size.small)
    table.cell(t, 1, 5, str.tostring(leverage, "#.##") + "x", text_color=color.white, bgcolor=leverage > 3 ? color.new(color.red, 30) : cell, text_size=size.small)
````
