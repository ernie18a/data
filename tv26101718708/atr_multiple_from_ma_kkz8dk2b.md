# ATR % Multiple From MA

- url: https://www.tradingview.com/script/KKZ8dk2b-ATR-Multiple-From-MA/
- type: indicator
- pine_id: PUB;9ca2e43469814ca484f7d33933915e1c
- version: 1.0

## Description

ATR % Multiple From MA OF YOUR CHOICE. Gives you the ATR% multiple from your chosen EMA

## Source Code

````pine
//@version=6
indicator("ATR % Multiple From MA", shorttitle="ATR Dist MA", overlay=true)

maType = input.string("EMA", "MA Type", options=["EMA", "SMA"])
maLength = input.int(50, "MA Length", minval=1)
atrLength = input.int(14, "ATR Length", minval=1)
showTable = input.bool(true, "Show Stats Table")
showMA = input.bool(true, "Plot Reference MA")
maColor = input.color(color.orange, "MA Color")
textColor = input.color(color.rgb(255, 190, 92), "Table Text Color")
bgColor = input.color(color.new(color.black, 100), "Table Background")
frameColor = input.color(color.new(color.gray, 85), "Table Frame Color")

ma = maType == "EMA" ? ta.ema(close, maLength) : ta.sma(close, maLength)
atr = ta.atr(atrLength)
atrPct = close != 0 ? (atr / close) * 100 : na
pctGainFromMA = ma != 0 ? ((close - ma) / ma) * 100 : na
atrPctMultipleFromMA = atrPct != 0 ? pctGainFromMA / atrPct : na
atrMultipleFromMA = atr != 0 ? (close - ma) / atr : na

plot(showMA ? ma : na, "Reference MA", color=maColor, linewidth=2)

var table stats = table.new(position.middle_right, 2, 3, bgcolor=bgColor, frame_color=frameColor, frame_width=1)

if barstate.islast
    if showTable
        table.cell(stats, 0, 0, "ATR% Multiple From MA", text_color=textColor, text_size=size.small, bgcolor=bgColor)
        table.cell(stats, 1, 0, na(atrPctMultipleFromMA) ? "n/a" : str.tostring(atrPctMultipleFromMA, "#.##") + "x", text_color=textColor, text_size=size.small, bgcolor=bgColor)
        table.cell(stats, 0, 1, "% Gain From MA", text_color=textColor, text_size=size.small, bgcolor=bgColor)
        table.cell(stats, 1, 1, na(pctGainFromMA) ? "n/a" : str.tostring(pctGainFromMA, "#.##") + "%", text_color=textColor, text_size=size.small, bgcolor=bgColor)
        table.cell(stats, 0, 2, "ATR %", text_color=textColor, text_size=size.small, bgcolor=bgColor)
        table.cell(stats, 1, 2, na(atrPct) ? "n/a" : str.tostring(atrPct, "#.##") + "%", text_color=textColor, text_size=size.small, bgcolor=bgColor)
    else
        table.clear(stats, 0, 0, 1, 2)

alertcondition(ta.crossover(atrMultipleFromMA, 2), "ATR Distance Above 2x", "Price moved above 2 ATRs from the selected MA")
alertcondition(ta.crossunder(atrMultipleFromMA, -2), "ATR Distance Below -2x", "Price moved below -2 ATRs from the selected MA")
````
