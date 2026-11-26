# S/R Max Pain - Full Levels

- url: https://www.tradingview.com/script/4VXpXn4x-S-R-Max-Pain-Full-Levels/
- type: indicator
- pine_id: PUB;8fa7cc61ee084905ae1397e3cdb381fe
- version: 6.0

## Description

S/R Max Pain - Full Levels

S/R Max Pain - Full Levels

S/R Max Pain - Full Levels

S/R Max Pain - Full Levels

## Source Code

````pine
//@version=6
indicator("Vishall-Gann's S/R-Range-Cash-Future GAP", overlay=true, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
lookbackBars    = input.int(100, "Lookback", minval=20)
showPoc         = input.bool(true, "Show POC")
showMaxPain     = input.bool(true, "Show Max Pain")
showCurrent     = input.bool(true, "Show Current Levels")
showNew         = input.bool(true, "Show New Levels After Trigger")
showLabels      = input.bool(true, "Show Labels")
showTable       = input.bool(true, "Show Program 1 Table")
gannBaseSource  = input.string("Close", "Gann Base Price", options=["Close", "POC", "Max Pain"])
gannStep        = input.float(0.125, "Gann Step", step=0.001)
showProg2Table  = input.bool(true, "Show Program 2 Table")

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
f_txt(v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

f_prog2_txt(v) =>
    str.tostring(nz(v, 0), format.mintick)

f_prog2_val_color(v) =>
    nz(v, 0) > 0 ? color.lime : nz(v, 0) < 0 ? color.red : color.white

//---------------------------------------------------------
// Program 1 : POC and Max Pain
//---------------------------------------------------------
poc = ta.vwap(hlc3)

var float maxPain = na
if bar_index % 20 == 0
    weightedSum = 0.0
    totalWeight = 0.0
    for i = 0 to lookbackBars - 1
        vol = volume[i]
        price = close[i]
        weight = vol * math.abs(close - price)
        weightedSum += price * weight
        totalWeight += weight
    maxPain := totalWeight > 0 ? weightedSum / totalWeight : close
else
    maxPain := nz(maxPain[1], close)

//---------------------------------------------------------
// Program 1 : Base price
//---------------------------------------------------------
basePriceRaw =
     gannBaseSource == "POC" ? poc :
     gannBaseSource == "Max Pain" ? maxPain :
     close

//---------------------------------------------------------
// Program 1 : Slab-wise refresh percent
//---------------------------------------------------------
refreshPct =
     basePriceRaw <= 100 ? 20.0 :
     basePriceRaw <= 500 ? 15.0 :
     basePriceRaw <= 1000 ? 12.0 :
     basePriceRaw <= 10000 ? 10.0 : 6.0

//---------------------------------------------------------
// Program 1 : New day tracking
//---------------------------------------------------------
newDay = ta.change(time("D")) != 0

var float dayStartPrice = na
if barstate.isfirst
    dayStartPrice := close
else if newDay
    dayStartPrice := close

dayPctMove = dayStartPrice != 0 ? math.abs(close - dayStartPrice) / dayStartPrice * 100 : 0.0
refreshTrigger = dayPctMove >= refreshPct

//---------------------------------------------------------
// Program 1 : Gann calculations
//---------------------------------------------------------
sqrtBase = math.sqrt(math.max(basePriceRaw, 0.0000001))

calcR1 = math.pow(sqrtBase + gannStep * 1, 2)
calcR2 = math.pow(sqrtBase + gannStep * 2, 2)
calcR3 = math.pow(sqrtBase + gannStep * 3, 2)
calcR4 = math.pow(sqrtBase + gannStep * 4, 2)

calcS1 = math.pow(math.max(sqrtBase - gannStep * 1, 0), 2)
calcS2 = math.pow(math.max(sqrtBase - gannStep * 2, 0), 2)
calcS3 = math.pow(math.max(sqrtBase - gannStep * 3, 0), 2)
calcS4 = math.pow(math.max(sqrtBase - gannStep * 4, 0), 2)

//---------------------------------------------------------
// Program 1 : Main levels
//---------------------------------------------------------
var float r1 = na
var float r2 = na
var float r3 = na
var float r4 = na
var float s1 = na
var float s2 = na
var float s3 = na
var float s4 = na

//---------------------------------------------------------
// Program 1 : New levels
//---------------------------------------------------------
var float newR1 = na
var float newR2 = na
var float newR3 = na
var float newR4 = na
var float newS1 = na
var float newS2 = na
var float newS3 = na
var float newS4 = na

var bool refreshedToday = false

if barstate.isfirst
    r1 := calcR1
    r2 := calcR2
    r3 := calcR3
    r4 := calcR4
    s1 := calcS1
    s2 := calcS2
    s3 := calcS3
    s4 := calcS4
    refreshedToday := false

if newDay
    r1 := calcR1
    r2 := calcR2
    r3 := calcR3
    r4 := calcR4
    s1 := calcS1
    s2 := calcS2
    s3 := calcS3
    s4 := calcS4

    newR1 := na
    newR2 := na
    newR3 := na
    newR4 := na
    newS1 := na
    newS2 := na
    newS3 := na
    newS4 := na
    refreshedToday := false

if refreshTrigger and not refreshedToday
    newR1 := calcR1
    newR2 := calcR2
    newR3 := calcR3
    newR4 := calcR4
    newS1 := calcS1
    newS2 := calcS2
    newS3 := calcS3
    newS4 := calcS4
    refreshedToday := true

//---------------------------------------------------------
// Program 1 : Active names and values
//---------------------------------------------------------
dispR1 = refreshedToday and not na(newR1) ? newR1 : r1
dispR2 = refreshedToday and not na(newR2) ? newR2 : r2
dispR3 = refreshedToday and not na(newR3) ? newR3 : r3
dispR4 = refreshedToday and not na(newR4) ? newR4 : r4

dispS1 = refreshedToday and not na(newS1) ? newS1 : s1
dispS2 = refreshedToday and not na(newS2) ? newS2 : s2
dispS3 = refreshedToday and not na(newS3) ? newS3 : s3
dispS4 = refreshedToday and not na(newS4) ? newS4 : s4

dispR1Name = refreshedToday and not na(newR1) ? "New R1" : "R1"
dispR2Name = refreshedToday and not na(newR2) ? "New R2" : "R2"
dispR3Name = refreshedToday and not na(newR3) ? "New R3" : "R3"
dispR4Name = refreshedToday and not na(newR4) ? "New R4" : "R4"

dispS1Name = refreshedToday and not na(newS1) ? "New S1" : "S1"
dispS2Name = refreshedToday and not na(newS2) ? "New S2" : "S2"
dispS3Name = refreshedToday and not na(newS3) ? "New S3" : "S3"
dispS4Name = refreshedToday and not na(newS4) ? "New S4" : "S4"

//---------------------------------------------------------
// Program 1 : Plots
//---------------------------------------------------------
plot(showCurrent ? dispR1 : na, "R1 Active", color=color.red, linewidth=1)
plot(showCurrent ? dispR2 : na, "R2 Active", color=color.new(color.red, 10), linewidth=1)
plot(showCurrent ? dispR3 : na, "R3 Active", color=color.new(color.red, 20), linewidth=1)
plot(showCurrent ? dispR4 : na, "R4 Active", color=color.new(color.red, 30), linewidth=1)

plot(showCurrent ? dispS1 : na, "S1 Active", color=color.lime, linewidth=1)
plot(showCurrent ? dispS2 : na, "S2 Active", color=color.new(color.lime, 10), linewidth=1)
plot(showCurrent ? dispS3 : na, "S3 Active", color=color.new(color.lime, 20), linewidth=1)
plot(showCurrent ? dispS4 : na, "S4 Active", color=color.new(color.lime, 30), linewidth=1)

// POC in blue
plot(showPoc ? poc : na, "POC", color=color.blue, linewidth=2)

// Max Pain
plot(showMaxPain ? maxPain : na, "Max Pain", color=color.orange, linewidth=2, style=plot.style_circles)

//---------------------------------------------------------
// POC right-end label
//---------------------------------------------------------
var label pocLbl = label.new(na, na, "")

if barstate.islast
    if showPoc and not na(poc)
        label.set_xy(pocLbl, bar_index + 1, poc)
        label.set_text(pocLbl, "POC")
        label.set_textcolor(pocLbl, color.blue)
        label.set_style(pocLbl, label.style_none)
        label.set_size(pocLbl, size.small)
    else
        label.set_text(pocLbl, "")

//---------------------------------------------------------
// Program 1 : Labels
//---------------------------------------------------------
var label lblR1 = na
var label lblR2 = na
var label lblR3 = na
var label lblR4 = na
var label lblS1 = na
var label lblS2 = na
var label lblS3 = na
var label lblS4 = na

if barstate.islast and showLabels
    label.delete(lblR1), label.delete(lblR2), label.delete(lblR3), label.delete(lblR4)
    label.delete(lblS1), label.delete(lblS2), label.delete(lblS3), label.delete(lblS4)

    lblR1 := label.new(bar_index + 1, dispR1, dispR1Name + " " + f_txt(dispR1), style=label.style_none, textcolor=color.red, size=size.small)
    lblR2 := label.new(bar_index + 1, dispR2, dispR2Name + " " + f_txt(dispR2), style=label.style_none, textcolor=color.red, size=size.small)
    lblR3 := label.new(bar_index + 1, dispR3, dispR3Name + " " + f_txt(dispR3), style=label.style_none, textcolor=color.red, size=size.small)
    lblR4 := label.new(bar_index + 1, dispR4, dispR4Name + " " + f_txt(dispR4), style=label.style_none, textcolor=color.red, size=size.small)

    lblS1 := label.new(bar_index + 1, dispS1, dispS1Name + " " + f_txt(dispS1), style=label.style_none, textcolor=color.lime, size=size.small)
    lblS2 := label.new(bar_index + 1, dispS2, dispS2Name + " " + f_txt(dispS2), style=label.style_none, textcolor=color.lime, size=size.small)
    lblS3 := label.new(bar_index + 1, dispS3, dispS3Name + " " + f_txt(dispS3), style=label.style_none, textcolor=color.lime, size=size.small)
    lblS4 := label.new(bar_index + 1, dispS4, dispS4Name + " " + f_txt(dispS4), style=label.style_none, textcolor=color.lime, size=size.small)

//---------------------------------------------------------
// Table colors
//---------------------------------------------------------
var color tblHeaderBg = color.rgb(70, 73, 82)
var color tblRowBg    = color.rgb(95, 98, 107)
var color tblText     = color.white
var color tblFrame    = color.rgb(80, 80, 80)

//---------------------------------------------------------
// Program 2 : Safe symbol logic
//---------------------------------------------------------
string chartPrefix = syminfo.prefix
string chartTicker = ticker.standard(syminfo.tickerid)
string p2SpotSym   = chartTicker
string p2FutureSym = na(syminfo.root) or syminfo.root == "" ? chartTicker : chartPrefix + ":" + syminfo.root + "1!"

st_close_1d_p2    = request.security(p2SpotSym, "1D", close, ignore_invalid_symbol=true)
st_ha_sym_p2      = ticker.heikinashi(p2SpotSym)
st_ha_close_1d_p2 = request.security(st_ha_sym_p2, "1D", close, ignore_invalid_symbol=true)
cash_gap_p2       = st_close_1d_p2 - st_ha_close_1d_p2

fut_close_1d_p2    = request.security(p2FutureSym, "1D", close, ignore_invalid_symbol=true)
fut_ha_sym_p2      = ticker.heikinashi(p2FutureSym)
fut_ha_close_1d_p2 = request.security(fut_ha_sym_p2, "1D", close, ignore_invalid_symbol=true)
future_gap_p2      = fut_close_1d_p2 - fut_ha_close_1d_p2

difference_p2 = na(future_gap_p2) or na(cash_gap_p2) ? cash_gap_p2 : future_gap_p2 - cash_gap_p2

//---------------------------------------------------------
// Program 1 Table
//---------------------------------------------------------
var table infoTable = table.new(position.top_right, 2, 11, border_width=1, frame_color=tblFrame, frame_width=1)

if barstate.islast or barstate.islastconfirmedhistory
    table.clear(infoTable, 0, 0, 1, 10)

    if showTable
        table.cell(infoTable, 0, 0, "LEVEL", text_color=color.white, bgcolor=tblHeaderBg, text_size=size.tiny)
        table.cell(infoTable, 1, 0, "PRICE", text_color=color.white, bgcolor=tblHeaderBg, text_size=size.tiny)

        table.cell(infoTable, 0, 1, dispR4Name, text_color=color.red, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 1, f_txt(dispR4), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 2, dispR3Name, text_color=color.red, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 2, f_txt(dispR3), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 3, dispR2Name, text_color=color.red, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 3, f_txt(dispR2), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 4, dispR1Name, text_color=color.red, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 4, f_txt(dispR1), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 5, "POC", text_color=color.blue, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 5, f_txt(poc), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 6, "Max Pain", text_color=color.orange, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 6, f_txt(maxPain), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 7, dispS1Name, text_color=color.lime, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 7, f_txt(dispS1), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 8, dispS2Name, text_color=color.lime, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 8, f_txt(dispS2), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 9, dispS3Name, text_color=color.lime, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 9, f_txt(dispS3), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(infoTable, 0, 10, dispS4Name, text_color=color.lime, bgcolor=tblRowBg, text_size=size.tiny)
        table.cell(infoTable, 1, 10, f_txt(dispS4), text_color=tblText, bgcolor=tblRowBg, text_size=size.tiny)

//---------------------------------------------------------
// Program 2 Table
//---------------------------------------------------------
var table prog2Table = table.new(position.middle_right, 2, 6, border_width=1, frame_color=tblFrame, frame_width=1)

if barstate.islast or barstate.islastconfirmedhistory
    table.clear(prog2Table, 0, 0, 1, 5)

    if showProg2Table
        table.cell(prog2Table, 0, 0, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=6)
        table.cell(prog2Table, 1, 0, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=6)

        table.cell(prog2Table, 0, 1, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=6)
        table.cell(prog2Table, 1, 1, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=6)

        table.cell(prog2Table, 0, 2, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=4)
        table.cell(prog2Table, 1, 2, "", bgcolor=color.new(color.black, 100), text_size=size.tiny, height=4)

        table.cell(prog2Table, 0, 3, "CG", text_color=color.white, bgcolor=tblHeaderBg, text_size=size.tiny)
        table.cell(prog2Table, 1, 3, f_prog2_txt(cash_gap_p2), text_color=f_prog2_val_color(cash_gap_p2), bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(prog2Table, 0, 4, "FG", text_color=color.white, bgcolor=tblHeaderBg, text_size=size.tiny)
        table.cell(prog2Table, 1, 4, f_prog2_txt(future_gap_p2), text_color=f_prog2_val_color(future_gap_p2), bgcolor=tblRowBg, text_size=size.tiny)

        table.cell(prog2Table, 0, 5, "DF", text_color=color.white, bgcolor=tblHeaderBg, text_size=size.tiny)
        table.cell(prog2Table, 1, 5, f_prog2_txt(difference_p2), text_color=f_prog2_val_color(difference_p2), bgcolor=tblRowBg, text_size=size.tiny)
````
