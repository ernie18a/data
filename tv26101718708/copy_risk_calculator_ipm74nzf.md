#  copy Risk Calculator

- url: https://www.tradingview.com/script/ipM74NzF/
- type: indicator
- pine_id: PUB;65a767e4e44941358a05f3a6318849b0
- version: 1.0

## Description

copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator copy Risk Calculator

## Source Code

````pine
//@version=5
indicator(" copy Risk Calculator", overlay=true)

// --- 1. CÀI ĐẶT (SETTINGS) ---
risk_usd = input.float(150, title="Target Risk (USD)", step=10, group="Quản lý Vốn")

symbol_choice = input.string("MNQ ($2/point)", title="Mã Giao Dịch", 
     options=["MNQ ($2/point)", "NQ ($20/point)", "MGC ($10/point)", "GC ($100/point)"], 
     group="Quản lý Vốn")

use_topstep = input.bool(true, title="Bật Ép Lot Topstep", group="Quản lý Vốn")

// --- 2. HỆ SỐ NHÂN TIỀN (MULTIPLIER) & TÊN MÃ RÚT GỌN ---
var float multiplier = 2.0
var string sym_label = "MNQ"

if symbol_choice == "NQ ($20/point)"
    multiplier := 20.0
    sym_label := "NQ"
else if symbol_choice == "MGC ($10/point)"
    multiplier := 10.0
    sym_label := "MGC"
else if symbol_choice == "GC ($100/point)"
    multiplier := 100.0
    sym_label := "GC"
else
    multiplier := 2.0
    sym_label := "MNQ"

// --- 3. HÀM TÍNH TOÁN LOT & RISK ---
get_order(raw_sl) =>
    // Luật ép an toàn (Min 7 - Max 22)
    float sl_calc = raw_sl
    if raw_sl < 7.0
        sl_calc := 7.0
    else if raw_sl > 22.0
        sl_calc := 22.0
        
    float ideal_qty = risk_usd / (sl_calc * multiplier)
    int qty = 1
    
    if use_topstep
        if ideal_qty >= 12.5
            qty := 15
        else if ideal_qty >= 7.5
            qty := 10
        else if ideal_qty >= 4.5
            qty := 5
        else if ideal_qty >= 3.5
            qty := 4
        else if ideal_qty >= 2.5
            qty := 3
        else if ideal_qty >= 1.5
            qty := 2
        else
            qty := 1
    else
        qty := math.max(1, math.floor(ideal_qty))
        
    float actual_risk = qty * sl_calc * multiplier
    [qty, actual_risk]

// --- 4. LẤY DỮ LIỆU NẾN ---
size_curr = high - low
[qty_curr, risk_curr] = get_order(size_curr)

size_prev = high[1] - low[1]
[qty_prev, risk_prev] = get_order(size_prev)

// --- 5. VẼ BẢNG GIAO DIỆN ---
var table ui = table.new(position.bottom_right, 4, 4, border_width=1, border_color=color.black, frame_color=color.black, frame_width=1)

if barstate.islast
    bg_header = color.rgb(15, 15, 15)
    bg_cell   = color.rgb(25, 25, 25)
    
    col_header = #888888
    col_text   = color.white
    col_order  = #FF0055
    col_risk   = #FFFF99

    // Hàng 0: Tiêu đề
    table.cell(ui, 0, 0, "CANDLE", text_color=col_header, bgcolor=bg_header, text_size=size.small)
    table.cell(ui, 1, 0, "SIZE", text_color=col_header, bgcolor=bg_header, text_size=size.small)
    table.cell(ui, 2, 0, "ORDER", text_color=col_header, bgcolor=bg_header, text_size=size.small)
    table.cell(ui, 3, 0, "RISK", text_color=col_header, bgcolor=bg_header, text_size=size.small)

    // Hàng 1: Nến Live
    table.cell(ui, 0, 1, "Live", text_color=col_text, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 1, 1, str.tostring(math.round(size_curr, 2)), text_color=col_text, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 2, 1, str.tostring(qty_curr), text_color=col_order, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 3, 1, str.tostring(math.round(risk_curr, 0)), text_color=col_risk, bgcolor=bg_cell, text_size=size.small)

    // Hàng 2: Nến Prev
    table.cell(ui, 0, 2, "Prev", text_color=col_text, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 1, 2, str.tostring(math.round(size_prev, 2)), text_color=col_text, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 2, 2, str.tostring(qty_prev), text_color=col_order, bgcolor=bg_cell, text_size=size.small)
    table.cell(ui, 3, 2, str.tostring(math.round(risk_prev, 0)), text_color=col_risk, bgcolor=bg_cell, text_size=size.small)
    
    // Hàng 3: Hiển thị mã đang Setting
    table.cell(ui, 0, 3, "SYMBOL: " + sym_label, text_color=col_header, bgcolor=bg_header, text_size=size.small)
    table.merge_cells(ui, 0, 3, 3, 3)
````
