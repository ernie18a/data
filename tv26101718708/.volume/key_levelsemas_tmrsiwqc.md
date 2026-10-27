# Key Levels-EMAs

- url: https://www.tradingview.com/script/tmRsiwqC/
- type: indicator
- pine_id: PUB;df017e3de16745d69caf5e1aac22c4d1
- version: 3.0

## Description

Niveles de Precio: Trazado automático de Máximo/Mínimo del día anterior (PDH/PDL) y del Pre-mercado (PMH/PML).

Medias Móviles y VWAP: Soporte para hasta 8 EMAs configurables y VWAP integrado en un solo script.

P.D. Este indicador te permite tener 9 indicadores (8 EMAs + VWAP) usando un solo slot de TradingView. No garantiza que ganes todas tus operaciones, pero al menos tu gráfica dejará de parecer un dibujo de un niño de 5 años con crayones.

_________________________________________________
Key Features:

Price Levels: Automatic plotting of Previous Day High/Low (PDH/PDL) and Pre-Market High/Low (PMH/PML).

EMAs & VWAP: Supports up to 8 customizable EMAs and integrated VWAP within a single script.


P.S. This indicator it lets you run 9 indicators (8 EMAs + VWAP) while only using one TradingView slot. It won't guarantee a 100% win rate, but at least your chart will stop looking like a toddler’s masterpiece with crayons.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Broogomez


//@version=6
indicator("Key Levels-EMA", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 0. CONFIGURACIÓN DE NIVELES
// ==========================================
grp_levels = "Levels Settings"
in_ext_right   = input.int(10, title="Extend Levels", group=grp_levels)
in_ext_pd_left = input.bool(true, title="Extend PDH/L Left", group=grp_levels)
in_ext_pm_left = input.bool(true, title="Extend PMH/L Left", group=grp_levels)

in_show_name  = input.bool(true, title="Show Name", inline="show_lbl", group=grp_levels)
in_show_price = input.bool(true, title="Show Price", inline="show_lbl", group=grp_levels)

show_pdh = input.bool(true, title="Prior Day High", inline="pdh_line", group=grp_levels)
c_pdh = input.color(color.green, title="", inline="pdh_line", group=grp_levels)
s_pdh = input.string("Solid", title="", options=["Solid", "Dashed", "Dotted"], inline="pdh_line", group=grp_levels)

show_pdl = input.bool(true, title="Prior Day Low", inline="pdl_line", group=grp_levels)
c_pdl = input.color(color.red, title="", inline="pdl_line", group=grp_levels)
s_pdl = input.string("Solid", title="", options=["Solid", "Dashed", "Dotted"], inline="pdl_line", group=grp_levels)

show_pmh = input.bool(true, title="Pre-Market High", inline="pmh_line", group=grp_levels)
c_pmh = input.color(color.green, title="", inline="pmh_line", group=grp_levels)
s_pmh = input.string("Dotted", title="", options=["Solid", "Dashed", "Dotted"], inline="pmh_line", group=grp_levels)

show_pml = input.bool(true, title="Pre-Market Low", inline="pml_line", group=grp_levels)
c_pml = input.color(color.red, title="", inline="pml_line", group=grp_levels)
s_pml = input.string("Dotted", title="", options=["Solid", "Dashed", "Dotted"], inline="pml_line", group=grp_levels)

get_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ==========================================
// 1. MISCELÁNEOS
// ==========================================
grp_misc = "Miscellaneous"
in_hide_prev_pd = input.bool(true, title="Hide Previous Day Highs/Lows", group=grp_misc)
in_hide_prev_pm = input.bool(true, title="Hide Previous Pre-Market Highs/Lows", group=grp_misc)

// ==========================================
// 2. CAPA DE MEDIAS MÓVILES Y VWAP
// ==========================================
grp_ema = "EMA & VWAP Settings"

show_e1 = input.bool(true, title="", inline="e1", group=grp_ema)
len_e1  = input.int(8, title="EMA 1", inline="e1", group=grp_ema, minval=1)
col_e1  = input.color(color.rgb(156, 39, 176), title="", inline="e1", group=grp_ema)

show_e2 = input.bool(true, title="", inline="e2", group=grp_ema)
len_e2  = input.int(9, title="EMA 2", inline="e2", group=grp_ema, minval=1)
col_e2  = input.color(color.rgb(43, 202, 223), title="", inline="e2", group=grp_ema)

show_e3 = input.bool(true, title="", inline="e3", group=grp_ema)
len_e3  = input.int(15, title="EMA 3", inline="e3", group=grp_ema, minval=1)
col_e3  = input.color(color.red, title="", inline="e3", group=grp_ema)

show_e4 = input.bool(false, title="", inline="e4", group=grp_ema)
len_e4  = input.int(20, title="EMA 4", inline="e4", group=grp_ema, minval=1)
col_e4  = input.color(color.gray, title="", inline="e4", group=grp_ema)

show_e5 = input.bool(false, title="", inline="e5", group=grp_ema)
len_e5  = input.int(30, title="EMA 5", inline="e5", group=grp_ema, minval=1)
col_e5  = input.color(color.green, title="", inline="e5", group=grp_ema)

show_e6 = input.bool(false, title="", inline="e6", group=grp_ema)
len_e6  = input.int(50, title="EMA 6", inline="e6", group=grp_ema, minval=1)
col_e6  = input.color(color.rgb(255, 158, 2), title="", inline="e6", group=grp_ema)

show_e7 = input.bool(false, title="", inline="e7", group=grp_ema)
len_e7  = input.int(65, title="EMA 7", inline="e7", group=grp_ema, minval=1)
col_e7  = input.color(color.rgb(223, 53, 40, 1), title="", inline="e7", group=grp_ema)

show_e8 = input.bool(false, title="", inline="e8", group=grp_ema)
len_e8  = input.int(200, title="EMA 8", inline="e8", group=grp_ema, minval=1)
col_e8  = input.color(color.white, title="", inline="e8", group=grp_ema)

// Ajustes del VWAP (movido a Entradas de Datos)
show_vwap = input.bool(true, title="VWAP", inline="vwap", group=grp_ema)
col_vwap  = input.color(color.yellow, title="", inline="vwap", group=grp_ema)

// Dibujo de las EMAs y VWAP ('editable=false' oculta el menú feo de la pestaña "Estilo")
plot(show_e1 ? ta.ema(close, len_e1) : na, color=col_e1, editable=false) 
plot(show_e2 ? ta.ema(close, len_e2) : na, color=col_e2, editable=false) 
plot(show_e3 ? ta.ema(close, len_e3) : na, color=col_e3, editable=false)               
plot(show_e4 ? ta.ema(close, len_e4) : na, color=col_e4, editable=false)               
plot(show_e5 ? ta.ema(close, len_e5) : na, color=col_e5, editable=false)            
plot(show_e6 ? ta.ema(close, len_e6) : na, color=col_e6, editable=false)            
plot(show_e7 ? ta.ema(close, len_e7) : na, color=col_e7, editable=false)          
plot(show_e8 ? ta.ema(close, len_e8) : na, color=col_e8, editable=false)            

plot(show_vwap ? ta.vwap(hlc3) : na, color=col_vwap, editable=false)

// ==========================================
// 3. NIVELES CLAVE Y DIBUJO DE LÍNEAS
// ==========================================
var float pdh = na, var int pdh_idx = na
var float pdl = na, var int pdl_idx = na
var float cur_d_h = na, var int cur_d_h_idx = na
var float cur_d_l = na, var int cur_d_l_idx = na

var float pmh = na, var int pmh_idx = na
var float pml = na, var int pml_idx = na
var float cur_pmh = na, var int cur_pmh_idx = na
var float cur_pml = na, var int cur_pml_idx = na

is_reg = session.ismarket
is_pm = session.ispremarket

is_new_day = ta.change(dayofweek) != 0
new_reg_session = session.isfirstbar_regular or (is_reg and is_new_day)

if is_pm
    if na(cur_pmh) or high > cur_pmh
        cur_pmh := high, cur_pmh_idx := bar_index
    if na(cur_pml) or low < cur_pml
        cur_pml := low, cur_pml_idx := bar_index

if new_reg_session
    pdh := cur_d_h, pdh_idx := cur_d_h_idx
    pdl := cur_d_l, pdl_idx := cur_d_l_idx
    pmh := cur_pmh, pmh_idx := cur_pmh_idx
    pml := cur_pml, pml_idx := cur_pml_idx
    cur_d_h := high, cur_d_h_idx := bar_index
    cur_d_l := low, cur_d_l_idx := bar_index
    cur_pmh := na, cur_pml := na
else if is_reg
    if na(cur_d_h) or high > cur_d_h
        cur_d_h := high, cur_d_h_idx := bar_index
    if na(cur_d_l) or low < cur_d_l
        cur_d_l := low, cur_d_l_idx := bar_index

var line[] a_pdh = array.new_line(), var label[] a_lbl_pdh = array.new_label()
var line[] a_pdl = array.new_line(), var label[] a_lbl_pdl = array.new_label()
var line[] a_pmh = array.new_line(), var label[] a_lbl_pmh = array.new_label()
var line[] a_pml = array.new_line(), var label[] a_lbl_pml = array.new_label()

lbl_txt(name, price) =>
    t = ""
    if in_show_name
        t += name + " "
    if in_show_price
        t += str.tostring(price, format.mintick)
    t

if new_reg_session
    if in_hide_prev_pd
        for ln in a_pdh
            line.delete(ln)
        for ln in a_pdl
            line.delete(ln)
        for lb in a_lbl_pdh
            label.delete(lb)
        for lb in a_lbl_pdl
            label.delete(lb)
        array.clear(a_pdh), array.clear(a_pdl)
        array.clear(a_lbl_pdh), array.clear(a_lbl_pdl)
        
    if in_hide_prev_pm
        for ln in a_pmh
            line.delete(ln)
        for ln in a_pml
            line.delete(ln)
        for lb in a_lbl_pmh
            label.delete(lb)
        for lb in a_lbl_pml
            label.delete(lb)
        array.clear(a_pmh), array.clear(a_pml)
        array.clear(a_lbl_pmh), array.clear(a_lbl_pml)

    x1_pdh = in_ext_pd_left and not na(pdh_idx) ? pdh_idx : bar_index
    x1_pdl = in_ext_pd_left and not na(pdl_idx) ? pdl_idx : bar_index
    x1_pmh = in_ext_pm_left and not na(pmh_idx) ? pmh_idx : bar_index
    x1_pml = in_ext_pm_left and not na(pml_idx) ? pml_idx : bar_index
    x2 = bar_index + in_ext_right

    if show_pdh and not na(pdh)
        array.push(a_pdh, line.new(x1_pdh, pdh, x2, pdh, color=c_pdh, style=get_style(s_pdh)))
        array.push(a_lbl_pdh, label.new(x2, pdh, lbl_txt("PDH", pdh), color=color.new(color.black, 100), textcolor=c_pdh, style=label.style_label_left))
    
    if show_pdl and not na(pdl)
        array.push(a_pdl, line.new(x1_pdl, pdl, x2, pdl, color=c_pdl, style=get_style(s_pdl)))
        array.push(a_lbl_pdl, label.new(x2, pdl, lbl_txt("PDL", pdl), color=color.new(color.black, 100), textcolor=c_pdl, style=label.style_label_left))

    if show_pmh and not na(pmh)
        array.push(a_pmh, line.new(x1_pmh, pmh, x2, pmh, color=c_pmh, style=get_style(s_pmh)))
        array.push(a_lbl_pmh, label.new(x2, pmh, lbl_txt("PMH", pmh), color=color.new(color.black, 100), textcolor=c_pmh, style=label.style_label_left))

    if show_pml and not na(pml)
        array.push(a_pml, line.new(x1_pml, pml, x2, pml, color=c_pml, style=get_style(s_pml)))
        array.push(a_lbl_pml, label.new(x2, pml, lbl_txt("PML", pml), color=color.new(color.black, 100), textcolor=c_pml, style=label.style_label_left))

if is_reg
    x2_live = bar_index + in_ext_right
    if array.size(a_pdh) > 0
        line.set_x2(array.last(a_pdh), x2_live), label.set_x(array.last(a_lbl_pdh), x2_live)
    if array.size(a_pdl) > 0
        line.set_x2(array.last(a_pdl), x2_live), label.set_x(array.last(a_lbl_pdl), x2_live)
    if array.size(a_pmh) > 0
        line.set_x2(array.last(a_pmh), x2_live), label.set_x(array.last(a_lbl_pmh), x2_live)
    if array.size(a_pml) > 0
        line.set_x2(array.last(a_pml), x2_live), label.set_x(array.last(a_lbl_pml), x2_live)
````
