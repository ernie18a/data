# [PJ]RSI

- url: https://www.tradingview.com/script/cq6cYxuu-PJ-RSI/
- type: indicator
- pine_id: PUB;7aefcf2e22544fc3a1b0e9f0eb8aa394
- version: 1.0

## Description

RSI 40/60 tracker with positive and negative reverse divergence indicator

## Source Code

````pine
//@version=6
indicator(title = '[PJ]RSI', format = format.inherit)//, timeframe = '', timeframe_gaps = true)
lbR = input(title = 'Pivot Lookback Right', defval = 2)
lbL = input(title = 'Pivot Lookback Left', defval = 3)
textColor = color.white
noneColor = color.new(color.white, 100)
osc = ta.rsi(close, 14)

plot(osc, title = 'RSI', linewidth = 2, color = color.black)
hline(50, title = 'Middle Line', color = #787B86, linestyle = hline.style_dotted)
obLevel = hline(60, title = 'Overbought', color = #787B86, linestyle = hline.style_dotted)
osLevel = hline(40, title = 'Oversold', color = #787B86, linestyle = hline.style_dotted)
fill(obLevel, osLevel, title = 'Background', color = color.new(color.purple, 85))

plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true
_inRange(cond) =>
    Bars = ta.barssince(cond == true)
    5 <= Bars and Bars <= 15

//------------------------------------------------------------------------------
// Regular Bullish
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1]) // Osc: Higher Low
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1) // Price: Lower Low
bullCondAlert = priceLL and oscHL and plFound and osc[lbR] < 40
bullCond = true and bullCondAlert
plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish', linewidth = 2, color = bullCond ? color.new(color.green,50) : noneColor)
plotshape(bullCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish Label', text = ' Bull ', style = shape.labelup, location = location.absolute, color = color.new(color.green,50), textcolor = textColor)

//------------------------------------------------------------------------------
// PRD - Positive Reverse Divergence. Continue to remain Bullish
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])// Osc: Lower Low
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)// Price: Higher Low
bullPRDCondAlert = priceHL and oscLL and plFound and osc[lbR] > 60
bullPRDCond = true and bullPRDCondAlert
bullPRDTGT = low[lbR] - ta.valuewhen(plFound, low[lbR], 1) + ta.valuewhen(phFound, close[lbR], 1) // tell the target
plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Bullish Positive Reverse Divergence', linewidth = 2, color = bullPRDCond ? color.green : noneColor)
var string ABCText = ' Bull PRD ' + str.format('{0, number, #.#}', bullPRDTGT)
plotshape(bullPRDCond ? osc[lbR] : na, offset = -lbR, title = 'Bullish PRD', text = 'Bull PRD', style = shape.labelup, location = location.absolute, color = color.green, textcolor = textColor)


//------------------------------------------------------------------------------
// Regular Bearish
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1]) // Osc: Lower High
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)// Price: Higher High
bearCondAlert = priceHH and oscLH and phFound and osc[lbR] > 60 //bearCond = plotBear and bearCondAlert
bearCond = true and bearCondAlert
plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish', linewidth = 2, color = bearCond ? color.new(color.red,50) : noneColor)
plotshape(bearCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish Label', text = ' Bear ', style = shape.labeldown, location = location.absolute, color = color.new(color.red,50), textcolor = textColor)

//------------------------------------------------------------------------------
// NRD - Negative Reverse Divergence. Continue to remain Bearish
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])// Osc: Higher High
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)// Price: Lower High
bearNRDCondAlert = priceLH and oscHH and phFound and osc[lbR] < 40
bearNRDCond = true and bearNRDCondAlert
plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Bearish Negative Reverse Divergence', linewidth = 2, color = bearNRDCond ? color.red : noneColor)
plotshape(bearNRDCond ? osc[lbR] : na, offset = -lbR, title = 'Bearish NRD', text = ' Bear NRD ', style = shape.labeldown, location = location.absolute, color = color.red, textcolor = textColor)


//------------------------------------------------------------------------------
// RSI value label at end of line (1 decimal)

var label rsiValueLabel = na

if barstate.islast
    if not na(rsiValueLabel)
        label.delete(rsiValueLabel) // delete previous label
    rsiText = str.format("{0,number,#.#}", osc)
    rsiValueLabel := label.new( x=bar_index+1, y=40, text=rsiText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, size=size.large, color=color.new(color.white,100), textcolor=color.black)
````
