<!-- tradingview-pine-id: PUB;fd70fdecb2494c3493e7ba52235520ab -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Label

Source: https://www.tradingview.com/script/3C7bqZb3-Liquidity-Label-above-Bar/

## Description

Liquidity Label

Shows a single floating label above the latest candle with the stock's average traded value (liquidity), so you can judge at a glance whether a stock is liquid enough to trade without opening a screener.

Time unit: Days or Minutes
Period count: number of periods used for averaging (default 50)
Price source: close by default
Display unit: Crore, Lakh, Million, Billion, or Raw
Decimals and optional unit suffix (Cr, L, M, B)

Label look

Text size, text color, background color
Shape: down arrow, box, or plain text

Margins

Vertical margin: how far above the high the label sits, as a percent of price
Horizontal margin: shift the label left or right by bars

Notes

Only one label is drawn, always on the last bar, and it updates live
Crore and Lakh units make this handy for NSE/BSE traders, while Million/Billion covers global markets
Works on any symbol and any chart timeframe

Also You can use it for intraday

---

## Source Code

````pine
//@version=6
indicator("Liquidity Label", overlay = true)

// ── Formula ──────────────────────────────────────────────────────
grpF   = "Formula"
unit   = input.string("Days", "Time unit", options = ["Days", "Minutes"], group = grpF)
n      = input.int(50, "Period count (1-n)", minval = 1, group = grpF)
src    = input.source(close, "Price source", group = grpF)
dispU  = input.string("Crore", "Display unit", options = ["Crore", "Lakh", "Million", "Billion", "Raw"], group = grpF)
dec    = input.int(2, "Decimals", minval = 0, maxval = 4, group = grpF)
suffix = input.bool(true, "Show unit suffix (Cr / M)", group = grpF)

// ── Look ─────────────────────────────────────────────────────────
grpL   = "Label look"
txtSz  = input.string("Large", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpL)
txtCol = input.color(color.white, "Text color", group = grpL)
bgCol  = input.color(#198ff7, "Background color", group = grpL)
shape  = input.string("Down arrow", "Shape", options = ["Down arrow", "Box", "Text only"], group = grpL)

// ── Margins ──────────────────────────────────────────────────────
grpM   = "Margins"
vMarg  = input.float(1.0, "Vertical margin (% of price above high)", minval = 0, step = 0.25, group = grpM)
hMarg  = input.int(0, "Horizontal margin (bars right of candle)", minval = -50, maxval = 50, group = grpM)

// ── Calc ─────────────────────────────────────────────────────────
tf     = unit == "Days" ? "D" : "1"
avgVol = request.security(syminfo.tickerid, tf, ta.sma(volume, n), lookahead = barmerge.lookahead_off)
liq    = src * avgVol

div = dispU == "Crore" ? 1e7 : dispU == "Lakh" ? 1e5 : dispU == "Million" ? 1e6 : dispU == "Billion" ? 1e9 : 1.0
sfx = dispU == "Crore" ? " Cr" : dispU == "Lakh" ? " L" : dispU == "Million" ? " M" : dispU == "Billion" ? " B" : ""
fmtStr = dec == 0 ? "#,###" : "#,###." + str.repeat("0", dec)
txt = str.tostring(liq / div, fmtStr) + (suffix ? sfx : "")

sz  = txtSz == "Tiny" ? size.tiny : txtSz == "Small" ? size.small : txtSz == "Normal" ? size.normal : txtSz == "Large" ? size.large : size.huge
sty = shape == "Down arrow" ? label.style_label_down : shape == "Box" ? label.style_label_center : label.style_none

// ── Draw ─────────────────────────────────────────────────────────
var label lb = na
if barstate.islast
    yPos = high * (1 + vMarg / 100)
    if na(lb)
        lb := label.new(bar_index + hMarg, yPos, txt, xloc = xloc.bar_index, yloc = yloc.price, style = sty, color = bgCol, textcolor = shape == "Text only" ? txtCol : txtCol, size = sz)
    else
        label.set_xy(lb, bar_index + hMarg, yPos)
        label.set_text(lb, txt)
        label.set_style(lb, sty)
        label.set_color(lb, bgCol)
        label.set_textcolor(lb, txtCol)
        label.set_size(lb, sz)
````
