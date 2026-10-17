# Calculador de Lotajes - copy

- url: https://www.tradingview.com/script/2uUxMTTL/
- type: indicator
- pine_id: PUB;f3b21a0ab4144ac9a8f2cdd307f585cc
- version: 1.0

## Description

Calculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copyCalculador de Lotajes - copy

## Source Code

````pine
// This Pine Script™
// © Modified for Futures Contracts - Sạch & Gọn (Có Bật/Tắt)
//@version=5
indicator("Calculador de Lotajes - copy", overlay = true)

// --- 1. CORE INPUTS ---
targetRisk = input.float(150, title = "Target Risk ($)", group = "Core")
symbol_choice = input.string("MNQ", title="Mã Giao Dịch", options = ["NQ","MNQ","GC","MGC"], group = "Core")
use_topstep = input.bool(true, title="Bật làm tròn hợp đồng (1,2,3,4,5,10,15)", group = "Core")
display_opt = input.string("USD", title="Hiện trên Label TP/SL:", options=["USD", "Points", "Ticks", "Giá"], group = "Core")

visualOpt = input.string("Fill", title = "Visual:", options = ["Fill","Line"], group = "Core")
lineClr = input.color(color.white,title="Line Color:", group = "Core")

// --- 2. KÉO THẢ TRÊN CHART ---
entryPrice = input.price(0, title = "Entry Price:", confirm = true, group = "Levels")
stopPrice = input.price(0, title = "Stop Price:", confirm = true, group = "Levels")
tpPrice1 = input.price(0,title="Take-Profit Price #1:", confirm = true, group = "Levels")
tpPrice2 = input.price(0,title="Take-Profit Price #2 (Tùy chọn):", group = "Levels")
tpPrice3 = input.price(0,title="Take-Profit Price #3 (Tùy chọn):", group = "Levels")

showDrawing = input.bool(true,title="Show TP & SL?", group = "Levels")
showTargetVal = input.bool(true,title="Show Targets Profit", group = "Dashboard")

colors1 = input.color(color.white,title = "Colors:", inline = "i_1", group = "Dashboard")
colors2 = input.color(color.white,title = "", inline = "i_1", group = "Dashboard")
textSize = input.string("Normal",title="Label Size:", options=["Tiny","Small","Normal","Large","Huge"], inline = "i_2", group='Dashboard')  
tablePosition = input.string(title='Dashboard Position:',  defval=position.top_right, options=[position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], inline="i_3", group='Dashboard')

showLotLabel = input.bool(true, "Show Lot Label On Chart", group = "Lot Label")
lotLabelColor = input.color(color.rgb(55, 71, 79), "Lot Label Color", group = "Lot Label")
lotLabelTextColor = input.color(color.white, "Lot Label Text Color", group = "Lot Label")

TextSizeToEnum(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
enumTextSize = TextSizeToEnum(textSize) 

// --- 3. LÕI TÍNH TOÁN ---
var float multiplier = 2.0
var float mintick_val = 0.25

if symbol_choice == "NQ"
    multiplier := 20.0
    mintick_val := 0.25
else if symbol_choice == "MNQ"
    multiplier := 2.0
    mintick_val := 0.25
else if symbol_choice == "GC"
    multiplier := 100.0
    mintick_val := 0.1
else if symbol_choice == "MGC"
    multiplier := 10.0
    mintick_val := 0.1

has_setup = entryPrice != 0 and stopPrice != 0
slInPoints = math.abs(entryPrice - stopPrice)
float sl_calc = slInPoints <= 0 ? mintick_val : slInPoints

// Logic Tính Hợp Đồng (Có công tắc Bật/Tắt)
float ideal_qty = targetRisk / (sl_calc * multiplier)
int lotSize = 1

if has_setup
    if use_topstep
        // Ép về các mốc Topstep
        if ideal_qty >= 12.5
            lotSize := 15
        else if ideal_qty >= 7.5
            lotSize := 10
        else if ideal_qty >= 4.5
            lotSize := 5
        else if ideal_qty >= 3.5
            lotSize := 4
        else if ideal_qty >= 2.5
            lotSize := 3
        else if ideal_qty >= 1.5
            lotSize := 2
        else
            lotSize := 1
    else
        // Làm tròn xuống bình thường
        lotSize := math.max(1, math.floor(ideal_qty))

// Tính các chỉ số khoảng cách
riskCost = lotSize * slInPoints * multiplier
tpOneInPoints = math.abs(entryPrice - tpPrice1)
tpTwoInPoints = math.abs(entryPrice - tpPrice2)
tpThreeInPoints = math.abs(entryPrice - tpPrice3)

rValue = has_setup ? math.round(tpOneInPoints / sl_calc, 1) : 0
rValue2 = has_setup ? math.round(tpTwoInPoints / sl_calc, 1) : 0
rValue3 = has_setup ? math.round(tpThreeInPoints / sl_calc, 1) : 0

// HÀM TÙY CHỈNH TEXT (USD, Points, Ticks, Giá)
get_label_text(prefix, price_val, pts_val, is_profit) =>
    string sign = is_profit ? "+" : "-"
    float usd_val = lotSize * pts_val * multiplier
    int ticks_val = math.round(pts_val / mintick_val)
    
    string val_str = ""
    if display_opt == "USD"
        val_str := sign + str.tostring(math.round(usd_val, 2)) + "$"
    else if display_opt == "Points"
        val_str := sign + str.tostring(math.round(pts_val, 2)) + " pts"
    else if display_opt == "Ticks"
        val_str := sign + str.tostring(ticks_val) + " ticks"
    else if display_opt == "Giá"
        val_str := str.tostring(math.round(price_val, 2))
        
    prefix + " " + val_str

// VARS
transpClr = color.new(color.white,100)
var label stopLbl = na
var label tpLbl = na
var label tpLbl2 = na
var label tpLbl3 = na
var label entryLbl = na
var label lotLbl = na
var line entryLn = na
var line stopLn = na
var line tpOneLn = na
var line tpTwoLn = na
var line tpThreeLn = na

lotLabelY = (entryPrice + stopPrice) / 2.0
lotText = "QTY " + str.tostring(lotSize)

// PLOTS Deletion
label.delete(stopLbl[1])
label.delete(tpLbl[1])
label.delete(tpLbl2[1])
label.delete(tpLbl3[1])
label.delete(entryLbl[1])
label.delete(lotLbl[1])
line.delete(entryLn[1])
line.delete(tpOneLn[1])
line.delete(tpTwoLn[1])
line.delete(tpThreeLn[1])
line.delete(stopLn[1])

// Line Visuals
plot(has_setup and showDrawing and visualOpt == "Line" ? entryPrice : na, color = lineClr, show_last = 1)
plot(has_setup and showDrawing and visualOpt == "Line" ? stopPrice : na, color = lineClr, show_last = 1)
plot(has_setup and showDrawing and visualOpt == "Line" and tpPrice1 != 0 ? tpPrice1 : na, color = lineClr, show_last = 1)
plot(has_setup and showDrawing and visualOpt == "Line" and tpPrice2 != 0 ? tpPrice2 : na, color = lineClr, show_last = 1)
plot(has_setup and showDrawing and visualOpt == "Line" and tpPrice3 != 0 ? tpPrice3 : na, color = lineClr, show_last = 1)

if has_setup and showDrawing and visualOpt == "Line"
    entryLn := line.new(bar_index-5, entryPrice, bar_index+10, entryPrice, extend = extend.right, color = lineClr)
    entryLbl := label.new(bar_index+10, entryPrice, text = "ENTRY", color = transpClr, textcolor = lineClr, size = size.normal, style=label.style_none)

    stopLn := line.new(bar_index-5, stopPrice, bar_index+10, stopPrice, extend = extend.right, color = lineClr)
    tempTextSl = get_label_text("SL", stopPrice, slInPoints, false)
    stopLbl := label.new(bar_index+10, stopPrice, text = tempTextSl, color = transpClr, textcolor = lineClr, size = size.normal, style=label.style_none)

    if tpPrice1 != 0
        tempTextTp = get_label_text("TP-1", tpPrice1, tpOneInPoints, true)
        tpLbl := label.new(bar_index+10, tpPrice1, text = tempTextTp, color = transpClr, textcolor = lineClr, size = size.normal, style=label.style_none)
        tpOneLn := line.new(bar_index-5, tpPrice1, bar_index+10, tpPrice1, extend = extend.right, color = lineClr)

    if showLotLabel
        lotLbl := label.new(bar_index+10, lotLabelY, text = lotText, color = transpClr, textcolor = lineClr, size = size.normal, style = label.style_none)

// FILL Visuals
if has_setup and showDrawing and visualOpt == "Fill"
    tempTextSl = get_label_text("SL", stopPrice, slInPoints, false)
    stopLbl := label.new(bar_index+10, stopPrice, text = tempTextSl, color = color.red, textcolor = color.white, size = size.normal, style=label.style_label_center)
    entryLbl := label.new(bar_index+10, entryPrice, text = "R:"+str.tostring(rValue), color = color.gray, textcolor = color.white, size = size.normal, style=label.style_label_center)
    
    if tpPrice1 != 0
        tempTextTp = get_label_text("TP-1", tpPrice1, tpOneInPoints, true)
        tpLbl := label.new(bar_index+10, tpPrice1, text = tempTextTp, color = color.green, textcolor = color.white, size = size.normal, style=label.style_label_center)

    if showLotLabel
        lotLbl := label.new(bar_index+10, lotLabelY, text = lotText, color = lotLabelColor, textcolor = lotLabelTextColor, size = size.normal, style = label.style_label_center)

if has_setup and showDrawing and tpPrice2 != 0 and visualOpt == "Fill"
    tempTextTp2 = get_label_text("TP-2", tpPrice2, tpTwoInPoints, true)
    tpLbl2 := label.new(bar_index+10, tpPrice2, text = tempTextTp2, color = color.green, textcolor = color.white, size = size.normal, style=label.style_label_center)

if has_setup and showDrawing and tpPrice3 != 0 and visualOpt == "Fill"
    tempTextTp3 = get_label_text("TP-3", tpPrice3, tpThreeInPoints, true)
    tpLbl3 := label.new(bar_index+10, tpPrice3, text = tempTextTp3, color = color.green, textcolor = color.white, size = size.normal, style=label.style_label_center)

ep = plot(has_setup and visualOpt == "Fill" and showDrawing ? entryPrice : na, title = "Entry Price", show_last = 20, offset = 20, color = color.new(color.gray,100))
sp = plot(has_setup and visualOpt == "Fill" and showDrawing ? stopPrice : na, title = "Stop-Loss Price", show_last = 20, offset = 20, color = color.new(color.red,100))
tp = plot(has_setup and visualOpt == "Fill" and showDrawing and tpPrice1 != 0 ? tpPrice1 : na, title = "Take-Profit #1 Price", show_last = 20, offset = 20, color = color.new(color.green,100))
tp2 = plot(has_setup and visualOpt == "Fill" and showDrawing and tpPrice2 != 0 ? tpPrice2 : na, title = "Take-Profit #2 Price", show_last = 20, offset = 20, color = color.new(color.green,100))
tp3 = plot(has_setup and visualOpt == "Fill" and showDrawing and tpPrice3 != 0 ? tpPrice3 : na, title = "Take-Profit #3 Price", show_last = 20, offset = 20, color = color.new(color.green,100))

fill(ep, tp3, show_last=1, color=color.new(color.green,80))
fill(ep, tp2, show_last=1, color=color.new(color.green,80))
fill(ep, tp, show_last=1, color=color.new(color.green,80))
fill(ep, sp, show_last=1, color=color.new(color.red,80))

// --- BẢNG DASHBOARD ---
table nameDisplay = table.new(tablePosition, 3, 8, frame_width = 1, border_width = 1 , border_color = color.gray, frame_color = color.gray)
if barstate.islast and has_setup
    table.cell(nameDisplay, 0, 0, str.tostring(syminfo.ticker)+ " "+str.tostring(close), text_color=colors2,text_size=enumTextSize)
    table.merge_cells(nameDisplay,0,0,2,0)

    table.cell(nameDisplay, 0, 1, "Target Risk", text_color=colors1, bgcolor = color.new(color.gray,50),text_size=enumTextSize)
    table.cell(nameDisplay, 1, 1, "Symbol", text_color=colors1, bgcolor =color.new(color.gray,50),text_size=enumTextSize)
    table.cell(nameDisplay, 2, 1, "Contracts", text_color=colors1, bgcolor = color.new(color.gray,50),text_size=enumTextSize)

    table.cell(nameDisplay, 0, 2, "$"+str.tostring(targetRisk) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
    table.cell(nameDisplay, 1, 2, symbol_choice, text_color=colors1, bgcolor =color.new(color.black,50),text_size=enumTextSize)
    table.cell(nameDisplay, 2, 2, str.tostring(lotSize) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)

    if showTargetVal
        table.cell(nameDisplay, 0, 3, "SL", text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 1, 3, "-1", text_color=colors1, bgcolor =color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 2, 3, "-$"+str.tostring(math.round(riskCost, 2)) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)

    if showTargetVal and tpPrice1 != 0
        table.cell(nameDisplay, 0, 4, "TP #1", text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 1, 4, str.tostring(rValue), text_color=colors1, bgcolor =color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 2, 4, "+$"+str.tostring(math.round(lotSize * tpOneInPoints * multiplier, 2)) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)

    if showTargetVal and tpPrice2 != 0
        table.cell(nameDisplay, 0, 5, "TP #2", text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 1, 5, str.tostring(rValue2), text_color=colors1, bgcolor =color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 2, 5, "+$"+str.tostring(math.round(lotSize * tpTwoInPoints * multiplier, 2)) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)

    if showTargetVal and tpPrice3 != 0
        table.cell(nameDisplay, 0, 6, "TP #3", text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 1, 6, str.tostring(rValue3), text_color=colors1, bgcolor =color.new(color.black,50),text_size=enumTextSize)
        table.cell(nameDisplay, 2, 6, "+$"+str.tostring(math.round(lotSize * tpThreeInPoints * multiplier, 2)) , text_color=colors1, bgcolor = color.new(color.black,50),text_size=enumTextSize)
````
