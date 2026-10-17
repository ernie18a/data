# Premium / Discount Zones

- url: https://www.tradingview.com/script/t3nRAaHy-Premium-Discount-Zones/
- type: indicator
- pine_id: PUB;ca77269bf51443e783f09af86225da54
- version: 1.0

## Description

A standalone ~30-line indicator that splits the current dealing range into premium (upper half) and discount (lower half), with the 50% equilibrium as the divider. It's the smart-money framing layer — buy in discount, sell in premium.

How it calculates: It takes the highest high and lowest low over the lookback window, then splits that range at the midpoint:

Premium = midpoint → range high (red tint)
Discount = range low → midpoint (green tint)
Equilibrium (EQ 50%) = the midpoint itself (orange dotted line, extends right)
What it draws:

Premium box (red tint) — upper half
Discount box (green tint) — lower half
EQ 50% line (orange dotted, extends right)
PREMIUM / DISCOUNT / EQ 50% labels at the right edge
Range table bottom-right with the three live prices
Inputs (all under Range):

Input	Default	Notes
Range Lookback (bars)	100	On your 1-min MNQ chart ≈ last 100 minutes
Right Extension (bars)	60	How far boxes project forward
Fill Opacity	94	Lower = more opaque
Show Range / Labels / EQ Line / Table	all on	Individual toggles
Two things to know about the defaults:

1. 100 bars on a 1-minute chart is a short range. The original HTF & CISD PRO measured 100 HTF bars (≈2.5 weeks on 4H). This one measures 100 chart bars, so on your 1-min MNQ chart the dealing range is roughly the last 100 minutes — an intraday range, not a swing range. Bump the lookback if you want a wider window.

2. It's rolling, not session-anchored. The range recomputes every bar, so the premium/discount boundaries drift as old highs/lows fall out of the lookback window. That's standard ICT dealing-range behaviour — but it means the zones aren't fixed for the session.

Why it's standalone: No request.security, no lookahead, so nothing on it repaints. It was deliberately kept single-purpose to avoid colliding with the CISD/FVG/sweep layers you already run — the original script would have put a second HTF & CISD PRO on your chart.

How to use it: Price in discount + bullish structure = look for longs. Price in premium + bearish structure = look for shorts. Price at EQ = no edge, wait. It's a location filter, not a trigger — it tells you whether the price you're paying is cheap or expensive within the current range, and the actual entry still comes from your sweep/CISD/fib layers.

## Source Code

````pine
//Author Midnitblade Thanks to Tradingview Remix AI Chart Copilot for coding.
//@version=6
indicator("Premium / Discount Zones", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//#region Inputs
lookback = input.int(100, "Range Lookback (bars)", minval=10, maxval=1000, group="Range")
showRange = input.bool(true, "Show Premium/Discount Range", group="Range")
showLabels = input.bool(true, "Show PREMIUM / DISCOUNT Labels", group="Range")
showMid = input.bool(true, "Show Equilibrium (50%) Line", group="Range")
extendBars = input.int(60, "Right Extension (bars)", minval=0, maxval=500, group="Range")
premOpacity = input.int(94, "Premium Fill Opacity", minval=0, maxval=100, group="Range")
discOpacity = input.int(94, "Discount Fill Opacity", minval=0, maxval=100, group="Range")
showTable = input.bool(true, "Show Range Table", group="Range")
//#endregion

//#region Range
rangeHigh = ta.highest(high, lookback)
rangeLow = ta.lowest(low, lookback)
rangeMid = (rangeHigh + rangeLow) / 2.0
//#endregion

//#region Drawings
var box premBox = na
var box discBox = na
var line midLine = na
var label premLbl = na
var label discLbl = na
var label eqLbl = na
var table pdTable = table.new(position.bottom_right, 2, 4, border_width=1)

if barstate.islast
    if not na(premBox)
        premBox.delete()
    if not na(discBox)
        discBox.delete()
    if not na(midLine)
        midLine.delete()
    if not na(premLbl)
        premLbl.delete()
    if not na(discLbl)
        discLbl.delete()
    if not na(eqLbl)
        eqLbl.delete()

    if showRange
        premBox := box.new(left=bar_index - 2, top=rangeHigh, right=bar_index + extendBars, bottom=rangeMid, xloc=xloc.bar_index, border_color=color.new(color.red, 70), bgcolor=color.new(color.red, premOpacity))
        discBox := box.new(left=bar_index - 2, top=rangeMid, right=bar_index + extendBars, bottom=rangeLow, xloc=xloc.bar_index, border_color=color.new(color.green, 70), bgcolor=color.new(color.green, discOpacity))
        midLine := line.new(bar_index - 2, rangeMid, bar_index + extendBars, rangeMid, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.orange, 0), style=line.style_dotted, width=1)

        if showLabels
            premLbl := label.new(bar_index + extendBars, rangeHigh, "PREMIUM", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
            discLbl := label.new(bar_index + extendBars, rangeLow, "DISCOUNT", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
            if showMid
                eqLbl := label.new(bar_index + extendBars, rangeMid, "EQ 50%", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

    if showTable
        pdTable.cell(0, 0, "Zone", text_color=color.white, bgcolor=color.new(color.gray, 0))
        pdTable.cell(1, 0, "Price", text_color=color.white, bgcolor=color.new(color.gray, 0))
        pdTable.cell(0, 1, "Premium", text_color=color.white)
        pdTable.cell(1, 1, str.tostring(rangeHigh, format.mintick), text_color=color.white)
        pdTable.cell(0, 2, "EQ", text_color=color.white)
        pdTable.cell(1, 2, str.tostring(rangeMid, format.mintick), text_color=color.white)
        pdTable.cell(0, 3, "Discount", text_color=color.white)
        pdTable.cell(1, 3, str.tostring(rangeLow, format.mintick), text_color=color.white)
//#endregion
````
