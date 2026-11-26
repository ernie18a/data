# Tradeflight Panel

- url: https://www.tradingview.com/script/SGIoObb4-Tradeflight-Panel/
- type: indicator
- pine_id: PUB;7345605556874c6ea0b4a92d215d2b19
- version: 2.0

## Description

Tradeflight Panel puts the 14, 50 and 200 EMA picture for five timeframes into one table, so you can see the whole trend structure without flipping charts.

What the table shows, for the 4H, 1H, 15m, 5m and 1m:
- Moving: UP when price is above a rising 14 EMA, DOWN when below a falling one, RANGE otherwise.
- Stack: R>G>P when 14 > 50 > 200 (bullish order), P>G>R when 200 > 50 > 14 (bearish order), MIXED in between.
- Closest: the EMA nearest to price on that timeframe and whether it sits above or below.
- Line above / Line below: the nearest EMA above and below price, its price, and the distance from price.
- vs R14: how far price is from that timeframe's 14 EMA.
- Closes vs R14: the last 3 closed candles against that timeframe's 14 EMA, oldest to newest (▲ above, ▼ below). Two ▲ after a ▼ shows the 14 being reclaimed.
- Swing H / L (20): the recent swing high and low from the last 20 closed candles on that timeframe.

Below the table:
- PDH / PDL: yesterday's high and low, and whether today has already traded through them.
- Current price and symbol.

It also draws the 14, 50 and 200 EMAs on your chart (red, gold, purple). You can turn the lines off in the settings, change the EMA lengths, and move or resize the panel.

How to use it:
Lines are most useful when they are stacked and spread apart, which shows a trend. When they are flat and tangled, price is ranging and the lines mean less. A pullback into the 14 EMA in a clean stack is a common entry area; the 50 and 200 often act as deeper support or resistance. Higher timeframe EMAs between price and a target often slow price down.

Notes:
- Values for timeframes lower than your chart are the latest completed values TradingView can provide.
- The last candle on every timeframe is still forming, so the table updates until it closes.
- For education and chart reading only. Not financial advice.

## Source Code

````pine
//@version=6
// Tradeflight Panel
// One table for five timeframes (1m, 5m, 15m, 1H, 4H): which way price is moving, v1.1
// how the 14 / 50 / 200 EMAs are stacked, the closest EMA above and below price
// with its distance, and price against the 14. Also yesterday's high and low and
// whether today has taken them. Draws the three EMAs on the chart as well.
indicator('Tradeflight Panel', overlay = true)

posIn = input.string('Top Right', 'Panel position', options = ['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'])
sizeIn = input.string('Small', 'Text size', options = ['Tiny', 'Small', 'Normal'])
lenFast = input.int(14, 'Red EMA')
lenMid = input.int(50, 'Gold EMA')
lenSlow = input.int(200, 'Purple EMA')
showLines = input.bool(true, 'Draw the 14 / 50 / 200 EMAs on this chart')

colUp = color.new(#26a69a, 0)
colDn = color.new(#ef5350, 0)
colMix = color.new(#dcb23c, 0)
colBg = color.new(#131822, 0)
colHead = color.new(#1c2331, 0)
colTxt = color.new(#e3e7f0, 0)
colDim = color.new(#8e98ad, 0)

calc() =>
    e14 = ta.ema(close, lenFast)
    e50 = ta.ema(close, lenMid)
    e200 = ta.ema(close, lenSlow)
    stk = e14 > e50 and e50 > e200 ? 1 : e14 < e50 and e50 < e200 ? -1 : 0
    mv = close > e14 and e14 > e14[3] ? 1 : close < e14 and e14 < e14[3] ? -1 : 0
    // last 3 CLOSED candles vs the 14 EMA, oldest to newest: 1 above, -1 below
    k3 = close[3] > e14[3] ? 1 : -1
    k2 = close[2] > e14[2] ? 1 : -1
    k1 = close[1] > e14[1] ? 1 : -1
    // recent swing high and low from the last 20 closed candles
    swH = ta.highest(high[1], 20)
    swL = ta.lowest(low[1], 20)
    [close, e14, e50, e200, stk, mv, k3, k2, k1, swH, swL]

[c1, r1, g1, p1, s1, m1, a1, b1, d1, h1, l1] = request.security(syminfo.tickerid, '1', calc())
[c5, r5, g5, p5, s5, m5, a5, b5, d5, h5, l5] = request.security(syminfo.tickerid, '5', calc())
[c15, r15, g15, p15, s15, m15, a15, b15, d15, h15, l15] = request.security(syminfo.tickerid, '15', calc())
[c60, r60, g60, p60, s60, m60, a60, b60, d60, h60, l60] = request.security(syminfo.tickerid, '60', calc())
[c240, r240, g240, p240, s240, m240, a240, b240, d240, h240, l240] = request.security(syminfo.tickerid, '240', calc())
[pdh, pdl, dHigh, dLow] = request.security(syminfo.tickerid, 'D', [high[1], low[1], high, low], lookahead = barmerge.lookahead_on)

fmtP(x) =>
    na(x) ? '-' : str.tostring(x, format.mintick)
fmtD(x) =>
    na(x) ? '-' : str.tostring(math.round(x * 4) / 4, '#.##')

nearestAbove(c, r, g, p) =>
    string nm = 'none'
    float ds = na
    if r > c
        nm := 'R14'
        ds := r - c
        ds
    if g > c and (na(ds) or g - c < ds)
        nm := 'G50'
        ds := g - c
        ds
    if p > c and (na(ds) or p - c < ds)
        nm := 'P200'
        ds := p - c
        ds
    [nm, ds]

nearestBelow(c, r, g, p) =>
    string nm = 'none'
    float ds = na
    if r < c
        nm := 'R14'
        ds := c - r
        ds
    if g < c and (na(ds) or c - g < ds)
        nm := 'G50'
        ds := c - g
        ds
    if p < c and (na(ds) or c - p < ds)
        nm := 'P200'
        ds := c - p
        ds
    [nm, ds]

pos = posIn == 'Top Right' ? position.top_right : posIn == 'Bottom Right' ? position.bottom_right : posIn == 'Top Left' ? position.top_left : position.bottom_left
txtSize = sizeIn == 'Tiny' ? size.tiny : sizeIn == 'Small' ? size.small : size.normal

eF = ta.ema(close, lenFast)
eM = ta.ema(close, lenMid)
eS = ta.ema(close, lenSlow)
plot(showLines ? eF : na, 'EMA 14', color = color.new(#ef4a3c, 0), linewidth = 1)
plot(showLines ? eM : na, 'EMA 50', color = color.new(#dcb23c, 0), linewidth = 1)
plot(showLines ? eS : na, 'EMA 200', color = color.new(#b35be0, 0), linewidth = 2)

var table t = table.new(pos, 9, 8, bgcolor = colBg, border_color = colHead, border_width = 1, frame_color = colHead, frame_width = 1)

cell(col, row, txt, tc) =>
    table.cell(t, col, row, txt, text_color = tc, text_size = txtSize, text_halign = text.align_left)

tfRow(row, name, c, r, g, p, s, m, k3, k2, k1, swH, swL) =>
    [an, ad] = nearestAbove(c, r, g, p)
    [bn, bd] = nearestBelow(c, r, g, p)
    closest = na(ad) ? bn + ' below' : na(bd) ? an + ' above' : ad < bd ? an + ' above' : bn + ' below'
    cell(0, row, name, colTxt)
    cell(1, row, m == 1 ? 'UP' : m == -1 ? 'DOWN' : 'RANGE', m == 1 ? colUp : m == -1 ? colDn : colMix)
    cell(2, row, s == 1 ? 'R>G>P' : s == -1 ? 'P>G>R' : 'MIXED', s == 1 ? colUp : s == -1 ? colDn : colMix)
    cell(3, row, closest, colTxt)
    cell(4, row, na(ad) ? '-' : an + ' ' + fmtP(c + ad) + ' (+' + fmtD(ad) + ')', colDn)
    cell(5, row, na(bd) ? '-' : bn + ' ' + fmtP(c - bd) + ' (-' + fmtD(bd) + ')', colUp)
    cell(6, row, fmtD(c - r), colDim)
    cell(7, row, (k3 == 1 ? '▲' : '▼') + (k2 == 1 ? '▲' : '▼') + (k1 == 1 ? '▲' : '▼'), k1 == 1 and k2 == 1 ? colUp : k1 == -1 and k2 == -1 ? colDn : colMix)
    cell(8, row, fmtP(swH) + ' / ' + fmtP(swL), colTxt)

if barstate.islast
    cell(0, 0, 'TF', colDim)
    cell(1, 0, 'Moving', colDim)
    cell(2, 0, 'Stack', colDim)
    cell(3, 0, 'Closest', colDim)
    cell(4, 0, 'Line above (pts)', colDim)
    cell(5, 0, 'Line below (pts)', colDim)
    cell(6, 0, 'vs R14', colDim)
    cell(7, 0, 'Closes vs R14', colDim)
    cell(8, 0, 'Swing H / L (20)', colDim)
    tfRow(1, '4H', c240, r240, g240, p240, s240, m240, a240, b240, d240, h240, l240)
    tfRow(2, '1H', c60, r60, g60, p60, s60, m60, a60, b60, d60, h60, l60)
    tfRow(3, '15m', c15, r15, g15, p15, s15, m15, a15, b15, d15, h15, l15)
    tfRow(4, '5m', c5, r5, g5, p5, s5, m5, a5, b5, d5, h5, l5)
    tfRow(5, '1m', c1, r1, g1, p1, s1, m1, a1, b1, d1, h1, l1)
    cell(0, 6, 'PDH', colDim)
    cell(1, 6, fmtP(pdh), colTxt)
    cell(2, 6, dHigh > pdh ? 'taken' : 'untaken', dHigh > pdh ? colDim : colMix)
    cell(0, 7, 'PDL', colDim)
    cell(1, 7, fmtP(pdl), colTxt)
    cell(2, 7, dLow < pdl ? 'taken' : 'untaken', dLow < pdl ? colDim : colMix)
    cell(3, 6, 'Price ' + fmtP(close), colTxt)
    cell(3, 7, syminfo.ticker, colDim)
````
