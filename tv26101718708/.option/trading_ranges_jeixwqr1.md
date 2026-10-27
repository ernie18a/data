# Trading Ranges

- url: https://www.tradingview.com/script/JEixwQr1-Trading-Ranges/
- type: indicator
- pine_id: PUB;d242f89cca5147319e5bf8b1ab1efee8
- version: 2.0

## Description

I made this script to easily see how a instrument is trading compared to the previous larger timeframes trading ranges. I added 3 candles representing the larger timeframe eg: Daily on a 5 minute chart. The fill area is the range of the previous larger timeframe and there is a parameter to show the open and close lines, you can also set the gradient colors and transparency levels of the lines. I also added some basic alerts for breakout above and below the range. The code could be condensed into functions but I did it like this to get around some pinescript issues.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoToolZ

//@version=6
indicator("Trading Ranges", overlay=true)

i_res = input.timeframe('1D', "Resolution", options=['1H', '4H', '12H', '1D', '4D', 'W', 'M'])

rp_security(_symbol, _res, _src) => request.security(_symbol, _res, _src[barstate.isrealtime ? 1 : 0])
rp_security2(_symbol, _res, _src, _back) => request.security(_symbol, _res, _src[_back], lookahead = barmerge.lookahead_on)//last
rp_security3(_symbol, _res, _src) => request.security(_symbol, _res, _src[1])//previous1
rp_security4(_symbol, _res, _src) => request.security(_symbol, _res, _src[2])//previous2

tfOpen = rp_security(syminfo.tickerid, i_res, open)
tfClose = rp_security(syminfo.tickerid, i_res, close)
tfHigh = rp_security(syminfo.tickerid, i_res, high)
tfLow = rp_security(syminfo.tickerid, i_res, low)

index = 1

thColor = input.color(color.green,"Top/High Color",group="Appearance")
blColor = input.color(color.red,"Bottom/Low Color",group="Appearance")

lineTransp = input.int(80,"High/Low Transparency",minval=0,maxval=100,step=5,group="Appearance")

plotOpenClose = input.bool(true,"Plot Open and Close Lines")

plot(plotOpenClose ? tfOpen[index] : na, color=color.green,linewidth = 2)
plot(plotOpenClose ? tfClose[index] : na, color=color.red,linewidth = 2)

hCol = color.new(thColor, lineTransp)
lCol = color.new(blColor, lineTransp)

rHigh = plot(tfHigh[index],color=hCol,linewidth = 2)
rLow = plot(tfLow[index],color=lCol,linewidth = 2)

transp = input.int(80,"Fill Transparency",minval=0,maxval=100,step=5,group="Appearance")
topCol = color.new(thColor,transp)
botCol = color.new(blColor,transp)

fill(rHigh,rLow,tfHigh[index],tfLow[index],topCol,botCol)

movedUp = ta.crossover(close,tfHigh[index]) and barstate.isconfirmed and barstate.islast
movedDown = ta.crossunder(close,tfLow[index]) and barstate.isconfirmed and barstate.islast

alertcondition(movedUp ,title="Trading Ranges Moved Above", message= "Price Above Range {{ticker}}")
alertcondition(movedDown ,title="Trading Ranges Moved Below", message= "Price Below Range {{ticker}}")

//plotcandle(tfOpen, tfHigh, tfLow, tfClose, title='Title',show_last = 5, color = open < close ? color.green : color.red, wickcolor=open < close ? color.green : color.red)


// ─────────────────────────────────────────────
// FUNCTION: Draw a candle at offset to the right
// ─────────────────────────────────────────────

candleOffset = input.int(1,"Candle Offset", group="Candles")
candleSpacing = input.int(4,"Candle Spacing", group="Candles")

candleWidth = input.int(6, "Candle Width (bars)", minval=1, group="Candles")
candleWidth := candleWidth % 2 == 0 ? candleWidth + 1 : candleWidth   // force odd

wickWidth = input.int(1, "Candle Wick Width (bars)", minval=1, group="Candles")
wickWidth := wickWidth % 2 == 0 ? wickWidth + 1 : wickWidth   // force odd

wickColor = input.color(color.gray, "Wick Color", group="Candles")
bullColor = input.color(color.green, "Bullish Candle Color", group="Candles")
bearColor = input.color(color.red, "Bearish Candle Color", group="Candles")

// ─────────────────────────────────────────────
// PERSISTENT BOXES FOR 3 CANDLES
// ─────────────────────────────────────────────
var box uw0 = na
var box lw0 = na
var box bd0 = na

var box uw1 = na
var box lw1 = na
var box bd1 = na

var box uw2 = na
var box lw2 = na
var box bd2 = na

candleCount = 3

if input.bool(true, "Draw Candles")
    // ─────────────────────────────────────────────
    // CANDLE 2 (OLDEST)
    // ─────────────────────────────────────────────
    O2 = rp_security2(syminfo.tickerid, i_res, open,  2)
    C2 = rp_security2(syminfo.tickerid, i_res, close, 2)
    H2 = rp_security2(syminfo.tickerid, i_res, high,  2)
    L2 = rp_security2(syminfo.tickerid, i_res, low,   2)

    offset2 = candleOffset + (candleCount - 2) * (candleWidth + candleSpacing)

    bodyTop2    = math.max(O2, C2)
    bodyBottom2 = math.min(O2, C2)
    isBull2     = C2 >= O2

    bodyColor2   = isBull2 ? color.new(bullColor, 40) : color.new(bearColor, 40)
    borderColor2 = isBull2 ? bullColor : bearColor

    wickBodyColor2  = color.new(wickColor, 40)
    wickBorderColor2 = color.new(wickColor, 0)

    left2  = bar_index + offset2
    right2 = left2 + candleWidth
    mid2   = left2 + candleWidth / 2

    halfWick2 = wickWidth / 2
    wickLeft2  = mid2 - halfWick2
    wickRight2 = mid2 + halfWick2

    if na(uw2)
        uw2 := box.new(wickLeft2, H2, wickRight2, bodyTop2, bgcolor = wickBodyColor2, border_color = wickBorderColor2)
        lw2 := box.new(wickLeft2, bodyBottom2, wickRight2, L2, bgcolor = wickBodyColor2, border_color = wickBorderColor2)
        bd2 := box.new(left2, bodyTop2, right2, bodyBottom2, bgcolor = bodyColor2, border_color = borderColor2)
    else
        box.set_lefttop(uw2, wickLeft2, H2)
        box.set_rightbottom(uw2, wickRight2, bodyTop2)

        box.set_lefttop(lw2, wickLeft2, bodyBottom2)
        box.set_rightbottom(lw2, wickRight2, L2)

        box.set_lefttop(bd2, left2, bodyTop2)
        box.set_rightbottom(bd2, right2, bodyBottom2)
        box.set_bgcolor(bd2, bodyColor2)
        box.set_border_color(bd2, borderColor2)

    // ─────────────────────────────────────────────
    // CANDLE 1 (PREVIOUS)
    // ─────────────────────────────────────────────
    O1 = rp_security2(syminfo.tickerid, i_res, open,  1)
    C1 = rp_security2(syminfo.tickerid, i_res, close, 1)
    H1 = rp_security2(syminfo.tickerid, i_res, high,  1)
    L1 = rp_security2(syminfo.tickerid, i_res, low,   1)

    offset1 = candleOffset + (candleCount - 1) * (candleWidth + candleSpacing)

    bodyTop1    = math.max(O1, C1)
    bodyBottom1 = math.min(O1, C1)
    isBull1     = C1 >= O1

    bodyColor1   = isBull1 ? color.new(bullColor, 40) : color.new(bearColor, 40)
    borderColor1 = isBull1 ? bullColor : bearColor

    wickBodyColor1  = color.new(wickColor, 40)
    wickBorderColor1 = color.new(wickColor, 0)

    left1  = bar_index + offset1
    right1 = left1 + candleWidth
    mid1   = left1 + candleWidth / 2

    halfWick1 = wickWidth / 2
    wickLeft1  = mid1 - halfWick1
    wickRight1 = mid1 + halfWick1

    if na(uw1)
        uw1 := box.new(wickLeft1, H1, wickRight1, bodyTop1, bgcolor = wickBodyColor1, border_color = wickBorderColor1)
        lw1 := box.new(wickLeft1, bodyBottom1, wickRight1, L1, bgcolor = wickBodyColor1, border_color = wickBorderColor1)
        bd1 := box.new(left1, bodyTop1, right1, bodyBottom1, bgcolor = bodyColor1, border_color = borderColor1)
    else
        box.set_lefttop(uw1, wickLeft1, H1)
        box.set_rightbottom(uw1, wickRight1, bodyTop1)

        box.set_lefttop(lw1, wickLeft1, bodyBottom1)
        box.set_rightbottom(lw1, wickRight1, L1)

        box.set_lefttop(bd1, left1, bodyTop1)
        box.set_rightbottom(bd1, right1, bodyBottom1)
        box.set_bgcolor(bd1, bodyColor1)
        box.set_border_color(bd1, borderColor1)

    // ─────────────────────────────────────────────
    // CANDLE 0 (NEWEST)
    // ─────────────────────────────────────────────
    O0 = rp_security2(syminfo.tickerid, i_res, open,  0)
    C0 = rp_security2(syminfo.tickerid, i_res, close, 0)
    H0 = rp_security2(syminfo.tickerid, i_res, high,  0)
    L0 = rp_security2(syminfo.tickerid, i_res, low,   0)

    offset0 = candleOffset + (candleCount - 0) * (candleWidth + candleSpacing)

    bodyTop0    = math.max(O0, C0)
    bodyBottom0 = math.min(O0, C0)
    isBull0     = C0 >= O0

    bodyColor0   = isBull0 ? color.new(bullColor, 40) : color.new(bearColor, 40)
    borderColor0 = isBull0 ? bullColor : bearColor

    wickBodyColor0  = color.new(wickColor, 40)
    wickBorderColor0 = color.new(wickColor, 0)

    left0  = bar_index + offset0
    right0 = left0 + candleWidth
    mid0   = left0 + candleWidth / 2

    halfWick0 = wickWidth / 2
    wickLeft0  = mid0 - halfWick0
    wickRight0 = mid0 + halfWick0

    if na(uw0)
        uw0 := box.new(wickLeft0, H0, wickRight0, bodyTop0, bgcolor = wickBodyColor0, border_color = wickBorderColor0)
        lw0 := box.new(wickLeft0, bodyBottom0, wickRight0, L0, bgcolor = wickBodyColor0, border_color = wickBorderColor0)
        bd0 := box.new(left0, bodyTop0, right0, bodyBottom0, bgcolor = bodyColor0, border_color = borderColor0)
    else
        box.set_lefttop(uw0, wickLeft0, H0)
        box.set_rightbottom(uw0, wickRight0, bodyTop0)

        box.set_lefttop(lw0, wickLeft0, bodyBottom0)
        box.set_rightbottom(lw0, wickRight0, L0)

        box.set_lefttop(bd0, left0, bodyTop0)
        box.set_rightbottom(bd0, right0, bodyBottom0)
        box.set_bgcolor(bd0, bodyColor0)
        box.set_border_color(bd0, borderColor0)
````
