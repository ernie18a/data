# VWAP 5Mt-1yr Multi-Timeframe

- url: https://www.tradingview.com/script/DwY5CDXZ-VWAP-5Mt-1yr-Multi-Timeframe/
- type: indicator
- pine_id: PUB;7af6322cff5740e6a2f8f726039e74de
- version: 1.0

## Description

this vwap contain 5mt.15mt.30mt.1h.2h,4h d w m 3m 6m 12m vwap in one any time frame

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © patelpurima byCSP

//@version=6
indicator("VWAP 5Mt-1yr Multi-Timeframe", overlay=true)

//Source Value For VWAP
vwapSource = input.source(hlc3, title="Source Value To Use For VWAP Calculations", group="Source Value")

//Identification Labels
labelsOn = input.bool(true, title="All Labels On/Off", group="Labels")
labelOffset = input.int(20, title="Label Offset", group="Labels")
labelColor = input.color(color.white, title="Label Text Color", group="Labels")

//Fill Colors For Trends
upTrendColor = input.color(color.rgb(0, 230, 119, 85), title="Up Trend Color", group="Trend Color Fills")
downTrendColor = input.color(color.rgb(255, 82, 82, 85), title="Down Trend Color", group="Trend Color Fills")

//VWAP On/Off, Color & Linewidth Settings
vwap5MinOn = input.bool(false, title="VWAP 5Min On/Off", group="VWAP 5Min")
vwap5MinColor = input.color(color.aqua, title="Line Color", group="VWAP 5Min")
fill5MinOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 5Min")
vwap5MinLinewidth = input.int(1, title="Linewidth", group="VWAP 5Min")
vwap5MinLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 5Min")

vwap15MinOn = input.bool(false, title="VWAP 15Min On/Off", group="VWAP 15Min")
vwap15MinColor = input.color(color.aqua, title="Line Color", group="VWAP 15Min")
fill15MinOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 15Min")
vwap15MinLinewidth = input.int(1, title="Linewidth", group="VWAP 15Min")
vwap15MinLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 15Min")


vwap30MinOn = input.bool(false, title="VWAP 30Min On/Off", group="VWAP 30Min")
vwap30MinColor = input.color(color.aqua, title="Line Color", group="VWAP 30Min")
fill30MinOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 30Min")
vwap30MinLinewidth = input.int(1, title="Linewidth", group="VWAP 30Min")
vwap30MinLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 30Min")

vwap1HOn = input.bool(false, title="VWAP 1H On/Off", group="VWAP 1H")
vwap1HColor = input.color(color.aqua, title="Line Color", group="VWAP 1H")
fill1HOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 1H")
vwap1HLinewidth = input.int(1, title="Linewidth", group="VWAP 1H")
vwap1HLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 1H")

vwap2HOn = input.bool(true, title="VWAP 2H On/Off", group="VWAP 2H")
vwap2HColor = input.color(color.aqua, title="Line Color", group="VWAP 2H")
fill2HOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 2H")
vwap2HLinewidth = input.int(1, title="Linewidth", group="VWAP 2H")
vwap2HLabelsOn = input.bool(false, title="Label On/Off", group="VWAP 2H")

vwap4HOn = input.bool(true, title="VWAP 4H On/Off", group="VWAP 4H")
vwap4HColor = input.color(color.aqua, title="Line Color", group="VWAP 4H")
fill4HOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 4H")
vwap4HLinewidth = input.int(1, title="Linewidth", group="VWAP 4H")
vwap4HLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 4H")

vwap1DOn = input.bool(true, title="VWAP 1D On/Off", group="VWAP 1D")
vwap1DColor = input.color(color.yellow, title="Line Color", group="VWAP 1D")
fill1DOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 1D")
vwap1DLinewidth = input.int(2, title="Linewidth", group="VWAP 1D")
vwap1DLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 1D")

vwap1WOn = input.bool(true, title="VWAP 1W On/Off", group="VWAP 1W")
vwap1WColor = input.color(color.orange, title="Line Color", group="VWAP 1W")
fill1WOn = input.bool(true, title="Trend Color Fill On/Off", group="VWAP 1W")
vwap1WLinewidth = input.int(3, title="Linewidth", group="VWAP 1W")
vwap1WLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 1W")

vwap1MOn = input.bool(true, title="VWAP 1M On/Off", group="VWAP 1M")
vwap1MColor = input.color(color.fuchsia, title="Line Color", group="VWAP 1M")
fill1MOn = input.bool(false, title="Trend Color Fill On/Off", group="VWAP 1M")
vwap1MLinewidth = input.int(4, title="Linewidth", group="VWAP 1M")
vwap1MLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 1M")

vwap3MOn = input.bool(true, title="VWAP 3M On/Off", group="VWAP 3M")
vwap3MColor = input.color(color.aqua, title="Line Color", group="VWAP 3M")
fill3MOn = input.bool(false, title="Trend Color Fill On/Off", group="VWAP 3M")
vwap3MLinewidth = input.int(4, title="Linewidth", group="VWAP 3M")
vwap3MLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 3M")

vwap6MOn = input.bool(true, title="VWAP 6M On/Off", group="VWAP 6M")
vwap6MColor = input.color(color.aqua, title="Line Color", group="VWAP 6M")
fill6MOn = input.bool(false, title="Trend Color Fill On/Off", group="VWAP 6M")
vwap6MLinewidth = input.int(4, title="Linewidth", group="VWAP 6M")
vwap6MLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 6M")

vwap1YOn = input.bool(true, title="VWAP 1Y On/Off", group="VWAP 1Y")
vwap1YColor = input.color(color.white, title="Line Color", group="VWAP 1Y")
fill1YOn = input.bool(false, title="Trend Color Fill On/Off", group="VWAP 1Y")
vwap1YLinewidth = input.int(6, title="Linewidth", group="VWAP 1Y")
vwap1YLabelsOn = input.bool(true, title="Label On/Off", group="VWAP 1Y")

//Trend Direction Table
trendTableOn = input.bool(true, title="VWAP Trend Table On/Off", group="Trend Table")
tablePosition = input.string("Bottom Right", title="Table Position", options=["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group="Trend Table")
bullishTrendColor = input.color(color.lime, title="Bullish Trend Color", group="Trend Table")
bearishTrendColor = input.color(color.red, title="Bearish Trend Color", group="Trend Table")
trendTextColor = input.color(color.white, title="Trend Text Color", group="Trend Table")

tableLocation = position.middle_right
if tablePosition == "Top Right" 
    tableLocation := position.top_right
if tablePosition == "Top Left" 
    tableLocation := position.top_left
if tablePosition == "Top Center" 
    tableLocation := position.top_center
if tablePosition == "Middle Right" 
    tableLocation := position.middle_right
if tablePosition == "Middle Left" 
    tableLocation := position.middle_left
if tablePosition == "Middle Center" 
    tableLocation := position.middle_center
if tablePosition == "Bottom Right" 
    tableLocation := position.bottom_right
if tablePosition == "Bottom Left" 
    tableLocation := position.bottom_left
if tablePosition == "Bottom Center" 
    tableLocation := position.bottom_center

//Timeframe changes to start new VWAP calculations
new1Y = timeframe.change("12M")
new6M = timeframe.change("6M")
new3M = timeframe.change("3M")
new1M = timeframe.change("1M")
new1W = timeframe.change("1W")
new1D = timeframe.change("1D")
new4H = timeframe.change("240")
new2H = timeframe.change("120")
new1H = timeframe.change("60")
new30Min = timeframe.change("30")
new15Min = timeframe.change("15")
new5Min = timeframe.change("5")


//Declaring variables
float vwapPrice5Min = na
float vwapPrice15Min = na
float vwapPrice30Min = na
float vwapPrice1H = na
float vwapPrice2H = na
float vwapPrice4H = na
float vwapPrice1D = na
float vwapPrice1W = na
float vwapPrice1M = na
float vwapPrice3M = na
float vwapPrice6M = na
float vwapPrice1Y = na

//Calculate Lower Timeframe VWAPs
if timeframe.isintraday
    if vwap5MinOn
        vwapPrice5Min := ta.vwap(vwapSource, new5Min)
    if vwap15MinOn
        vwapPrice15Min := ta.vwap(vwapSource, new15Min)

    if vwap30MinOn
        vwapPrice30Min := ta.vwap(vwapSource, new30Min)
    if vwap1HOn
        vwapPrice1H := ta.vwap(vwapSource, new1H)
    if vwap2HOn
        vwapPrice2H := ta.vwap(vwapSource, new2H)
    if vwap4HOn
        vwapPrice4H := ta.vwap(vwapSource, new4H)
    
//Calculate Higher Timeframe VWAPs
if vwap1DOn
    vwapPrice1D := request.security(syminfo.tickerid, timeframe.period, ta.vwap(vwapSource, new1D))
if vwap1WOn
    vwapPrice1W := request.security(syminfo.tickerid, "5", ta.vwap(vwapSource, new1W))
if vwap1MOn
    vwapPrice1M := request.security(syminfo.tickerid, "15", ta.vwap(vwapSource, new1M))
if vwap3MOn
    vwapPrice3M := request.security(syminfo.tickerid, "60", ta.vwap(vwapSource, new3M))
if vwap6MOn
    vwapPrice6M := request.security(syminfo.tickerid, "60", ta.vwap(vwapSource, new6M))
if vwap1YOn
    vwapPrice1Y := request.security(syminfo.tickerid, "60", ta.vwap(vwapSource, new1Y))

//Plot VWAPs On Chart
//Lower Timeframe Plots
plot5MinVWAP = plot(vwap5MinOn ? vwapPrice5Min : na, title="VWAP 5Min", color=vwap5MinColor, linewidth=vwap5MinLinewidth, style=plot.style_linebr)
plot15MinVWAP = plot(vwap15MinOn ? vwapPrice15Min : na, title="VWAP 15Min", color=vwap15MinColor, linewidth=vwap15MinLinewidth, style=plot.style_linebr)
plot30MinVWAP = plot(vwap30MinOn ? vwapPrice30Min : na, title="VWAP 30Min", color=vwap30MinColor, linewidth=vwap30MinLinewidth, style=plot.style_linebr)
plot1HVWAP = plot(vwap1HOn ? vwapPrice1H : na, title="VWAP 1H", color=vwap1HColor, linewidth=vwap1HLinewidth, style=plot.style_linebr)
plot2HVWAP = plot(vwap2HOn ? vwapPrice2H : na, title="VWAP 2H", color=vwap2HColor, linewidth=vwap2HLinewidth, style=plot.style_linebr)
plot4HVWAP = plot(vwap4HOn ? vwapPrice4H : na, title="VWAP 4H", color=vwap4HColor, linewidth=vwap4HLinewidth, style=plot.style_linebr)

//Higher Timeframe Plots
plot1DVWAP = plot(vwap1DOn ? vwapPrice1D : na, title="VWAP 1D", color=vwap1DColor, linewidth=vwap1DLinewidth, style=plot.style_linebr)
plot1WVWAP = plot(vwap1WOn ? vwapPrice1W : na, title="VWAP 1W", color=vwap1WColor, linewidth=vwap1WLinewidth, style=plot.style_linebr)
plot1MVWAP = plot(vwap1MOn ? vwapPrice1M : na, title="VWAP 1M", color=vwap1MColor, linewidth=vwap1MLinewidth, style=plot.style_linebr)
plot3MVWAP = plot(vwap3MOn ? vwapPrice3M : na, title="VWAP 3M", color=vwap3MColor, linewidth=vwap3MLinewidth, style=plot.style_linebr)
plot6MVWAP = plot(vwap6MOn ? vwapPrice6M : na, title="VWAP 6M", color=vwap6MColor, linewidth=vwap6MLinewidth, style=plot.style_linebr)
plot1YVWAP = plot(vwap1YOn ? vwapPrice1Y : na, title="VWAP 1Y", color=vwap1YColor, linewidth=vwap1YLinewidth, style=plot.style_linebr)

//Create & Update Labels
if labelsOn and barstate.islast
    if vwap5MinOn and vwap5MinLabelsOn
        label5Min = label.new(bar_index + labelOffset, vwapPrice5Min, text="5Min vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label5Min[1])
    if vwap15MinOn and vwap15MinLabelsOn
        label15Min = label.new(bar_index + labelOffset, vwapPrice15Min, text="15Min vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label15Min[1]) 
    if vwap30MinOn and vwap30MinLabelsOn
        label30Min = label.new(bar_index + labelOffset, vwapPrice30Min, text="30Min vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label30Min[1])
    if vwap1HOn and vwap1HLabelsOn
        label1H = label.new(bar_index + labelOffset, vwapPrice1H, text="1H vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label1H[1])
    if vwap2HOn and vwap2HLabelsOn
        label2H = label.new(bar_index + labelOffset, vwapPrice2H, text="2H vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label2H[1])
    if vwap4HOn and vwap4HLabelsOn
        label4H = label.new(bar_index + labelOffset, vwapPrice4H, text="4H vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label4H[1])
    if vwap1DOn and vwap1DLabelsOn
        label1D = label.new(bar_index + labelOffset, vwapPrice1D, text="1D vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label1D[1])
    if vwap1WOn and vwap1WLabelsOn
        label1W = label.new(bar_index + labelOffset, vwapPrice1W, text="1W vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label1W[1])
    if vwap1MOn and vwap1MLabelsOn
        label1M = label.new(bar_index + labelOffset, vwapPrice1M, text="1M vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label1M[1])
    if vwap3MOn and vwap3MLabelsOn
        label3M = label.new(bar_index + labelOffset, vwapPrice3M, text="3M vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label3M[1])
    if vwap6MOn and vwap6MLabelsOn
        label6M = label.new(bar_index + labelOffset, vwapPrice6M, text="6M vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label6M[1])
    if vwap1YOn and vwap1YLabelsOn
        label1Y = label.new(bar_index + labelOffset, vwapPrice1Y, text="1Y vwap", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=#00000000, textcolor=labelColor, size=size.small)
        label.delete(label1Y[1])

//Fill Colors Between Close Price & VWAPs
candlePlot = plot(close, title="Close Price Plot", color=#00000000)

fill(candlePlot, plot5MinVWAP, color=fill5MinOn and close >= vwapPrice5Min ? upTrendColor : fill5MinOn and close < vwapPrice5Min ? downTrendColor : #00000000, title="5Min Color Fill")
fill(candlePlot, plot15MinVWAP, color=fill15MinOn and close >= vwapPrice15Min ? upTrendColor : fill15MinOn and close < vwapPrice15Min ? downTrendColor : #00000000, title="15Min Color Fill")
fill(candlePlot, plot30MinVWAP, color=fill30MinOn and close >= vwapPrice30Min ? upTrendColor : fill30MinOn and close < vwapPrice30Min ? downTrendColor : #00000000, title="30Min Color Fill")
fill(candlePlot, plot1HVWAP, color=fill1HOn and close >= vwapPrice1H ? upTrendColor : fill1HOn and close < vwapPrice1H ? downTrendColor : #00000000, title="1H Color Fill")
fill(candlePlot, plot2HVWAP, color=fill2HOn and close >= vwapPrice2H ? upTrendColor : fill2HOn and close < vwapPrice2H ? downTrendColor : #00000000, title="2H Color Fill")
fill(candlePlot, plot4HVWAP, color=fill4HOn and close >= vwapPrice4H ? upTrendColor : fill4HOn and close < vwapPrice4H ? downTrendColor : #00000000, title="4H Color Fill")
fill(candlePlot, plot1DVWAP, color=fill1DOn and close >= vwapPrice1D ? upTrendColor : fill1DOn and close < vwapPrice1D ? downTrendColor : #00000000, title="1D Color Fill")
fill(candlePlot, plot1WVWAP, color=fill1WOn and close >= vwapPrice1W ? upTrendColor : fill1WOn and close < vwapPrice1W ? downTrendColor : #00000000, title="1W Color Fill")
fill(candlePlot, plot1MVWAP, color=fill1MOn and close >= vwapPrice1M ? upTrendColor : fill1MOn and close < vwapPrice1M ? downTrendColor : #00000000, title="1M Color Fill")
fill(candlePlot, plot3MVWAP, color=fill3MOn and close >= vwapPrice3M ? upTrendColor : fill3MOn and close < vwapPrice3M ? downTrendColor : #00000000, title="3M Color Fill")
fill(candlePlot, plot6MVWAP, color=fill6MOn and close >= vwapPrice6M ? upTrendColor : fill6MOn and close < vwapPrice6M ? downTrendColor : #00000000, title="6M Color Fill")
fill(candlePlot, plot1YVWAP, color=fill1YOn and close >= vwapPrice1Y ? upTrendColor : fill1YOn and close < vwapPrice1Y ? downTrendColor : #00000000, title="1Y Color Fill")

//Trend Table
trendTable = table.new(tableLocation, columns=1, rows=5)
if barstate.islast and trendTableOn
    table.cell(table_id=trendTable, column=0, row=0, text="VWAP", height=0, text_color=color.white, text_halign=text.align_center, text_valign= text.align_center, text_size=size.small, bgcolor=color.blue)
    if vwap1DOn
        table.cell(table_id=trendTable, column=0, row=1, text="Day", height=0, text_color=trendTextColor, text_halign=text.align_center, text_valign= text.align_center, text_size=size.small, bgcolor=close >= vwapPrice1D ? bullishTrendColor : bearishTrendColor)
    if vwap1WOn
        table.cell(table_id=trendTable, column=0, row=2, text="Week", height=0, text_color=trendTextColor, text_halign=text.align_center, text_valign= text.align_center, text_size=size.small, bgcolor=close >= vwapPrice1W ? bullishTrendColor : bearishTrendColor)
    if vwap1MOn
        table.cell(table_id=trendTable, column=0, row=3, text="Month", height=0, text_color=trendTextColor, text_halign=text.align_center, text_valign= text.align_center, text_size=size.small, bgcolor=close >= vwapPrice1M ? bullishTrendColor : bearishTrendColor)
    if vwap1YOn
        table.cell(table_id=trendTable, column=0, row=4, text="Year", height=0, text_color=trendTextColor, text_halign=text.align_center, text_valign= text.align_center, text_size=size.small, bgcolor=close >= vwapPrice1Y ? bullishTrendColor : bearishTrendColor)

//Trend Direction Filter Calculations
trendDirection = 0
numberOfVWAPsTurnedOn = 0
trendDirectionCount = 0

if vwap5MinOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice5Min
        trendDirectionCount += 1
    if close < vwapPrice5Min
        trendDirectionCount += -1

if vwap15MinOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice15Min
        trendDirectionCount += 1
    if close < vwapPrice15Min
        trendDirectionCount += -1


if vwap30MinOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice30Min
        trendDirectionCount += 1
    if close < vwapPrice30Min
        trendDirectionCount += -1

if vwap1HOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice1H
        trendDirectionCount += 1
    if close < vwapPrice1H
        trendDirectionCount += -1

if vwap2HOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice2H
        trendDirectionCount += 1
    if close < vwapPrice2H
        trendDirectionCount += -1

if vwap4HOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice4H
        trendDirectionCount += 1
    if close < vwapPrice4H
        trendDirectionCount += -1
if vwap1DOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice1D
        trendDirectionCount += 1
    if close < vwapPrice1D
        trendDirectionCount += -1

if vwap1WOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice1W
        trendDirectionCount += 1
    if close < vwapPrice1W
        trendDirectionCount += -1

if vwap1MOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice1M
        trendDirectionCount += 1
    if close < vwapPrice1M
        trendDirectionCount += -1

if vwap3MOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice3M
        trendDirectionCount += 1
    if close < vwapPrice3M
        trendDirectionCount += -1

if vwap6MOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice6M
        trendDirectionCount += 1
    if close < vwapPrice6M
        trendDirectionCount += -1

if vwap1YOn
    numberOfVWAPsTurnedOn += 1
    if close > vwapPrice1Y
        trendDirectionCount += 1
    if close < vwapPrice1Y
        trendDirectionCount += -1

//Trend Direction To Send To External Indicators
if trendDirectionCount == numberOfVWAPsTurnedOn
    trendDirection := 1
else if trendDirectionCount == (numberOfVWAPsTurnedOn * -1)
    trendDirection := -1
else
    trendDirection := 0
    
plot(trendDirection, title="Trend Direction To Send To External Indicators", color=#00000000, display=display.data_window)
````
