#  Emas Strategy

- url: https://www.tradingview.com/script/R8bQPXQw/
- type: indicator
- pine_id: PUB;df68e297d20443aca2dbcf18ee008170
- version: 2.0

## Description

La posibilidad de poder agregar 15 emas totalmente modificable con sus variantes.

## Source Code

````pine
//@version=6
indicator("Emas)", overlay=true)

// --- FUNCIONES AUXILIARES PARA MEDIAS AVANZADAS ---
dema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    val_dema = 2 * ema1 - ema2
    val_dema

tema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    val_tema = 3 * ema1 - 3 * ema2 + ema3
    val_tema

get_ma(type, src, len) =>
    float ma_result = na
    if type == "SMA"
        ma_result := ta.sma(src, len)
    else if type == "EMA"
        ma_result := ta.ema(src, len)
    else if type == "WMA"
        ma_result := ta.wma(src, len)
    else if type == "VWMA"
        ma_result := ta.vwma(src, len)
    else if type == "HMA"
        ma_result := ta.hma(src, len)
    else if type == "DEMA"
        ma_result := dema(src, len)
    else if type == "TEMA"
        ma_result := tema(src, len)
    else if type == "ALMA"
        ma_result := ta.alma(src, len, 0.85, 6)
    else
        ma_result := ta.sma(src, len)
    ma_result

// --- CONFIGURACIÓN DE VISUALIZACIÓN DE ETIQUETAS ---
group_visuals = "Configuración de Etiquetas y Leyenda"
show_labels   = input.bool(true, title="Mostrar etiquetas flotantes en las líneas", group=group_visuals)
show_table    = input.bool(true, title="Mostrar tabla resumen (Leyenda)", group=group_visuals)
table_pos     = input.string("Derecha Superior", title="Posición de la Tabla", options=["Derecha Superior", "Derecha Inferior", "Izquierda Superior", "Izquierda Inferior"], group=group_visuals)

// Función para convertir texto de posición
get_table_pos(pos) =>
    pos_res = position.top_right
    if pos == "Derecha Superior"
        pos_res := position.top_right
    else if pos == "Derecha Inferior"
        pos_res := position.bottom_right
    else if pos == "Izquierda Superior"
        pos_res := position.top_left
    else if pos == "Izquierda Inferior"
        pos_res := position.bottom_left
    pos_res

// --- CONFIGURACIÓN DE INPUTS POR CADA MA ---

// MA 1
ma1_show = input.bool(true, title="Activar Media 1", group="Media 1")
ma1_type = input.string("TEMA", title="MA 1 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 1")
ma1_len  = input.int(50, title="MA 1 Periodo", minval=1, group="Media 1")
ma1_col  = input.color(color.aqua, title="MA 1 Color", group="Media 1")
ma1_thk  = input.int(2, title="MA 1 Grosor", minval=1, maxval=4, group="Media 1")
ma1_lbl  = input.string("Rápida", title="Etiqueta Personalizada", group="Media 1")

// MA 2
ma2_show = input.bool(true, title="Activar Media 2", group="Media 2")
ma2_type = input.string("ALMA", title="MA 2 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 2")
ma2_len  = input.int(750, title="MA 2 Periodo", minval=1, group="Media 2")
ma2_col  = input.color(color.orange, title="MA 2 Color", group="Media 2")
ma2_thk  = input.int(2, title="MA 2 Grosor", minval=1, maxval=4, group="Media 2")
ma2_lbl  = input.string("Macro", title="Etiqueta Personalizada", group="Media 2")

// MA 3
ma3_show = input.bool(false, title="Activar Media 3", group="Media 3")
ma3_type = input.string("EMA", title="MA 3 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 3")
ma3_len  = input.int(125, title="MA 3 Periodo", minval=1, group="Media 3")
ma3_col  = input.color(color.yellow, title="MA 3 Color", group="Media 3")
ma3_thk  = input.int(1, title="MA 3 Grosor", minval=1, maxval=4, group="Media 3")
ma3_lbl  = input.string("Confirmación", title="Etiqueta Personalizada", group="Media 3")

// MA 4
ma4_show = input.bool(false, title="Activar Media 4", group="Media 4")
ma4_type = input.string("EMA", title="MA 4 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 4")
ma4_len  = input.int(250, title="MA 4 Periodo", minval=1, group="Media 4")
ma4_col  = input.color(color.green, title="MA 4 Color", group="Media 4")
ma4_thk  = input.int(1, title="MA 4 Grosor", minval=1, maxval=4, group="Media 4")
ma4_lbl  = input.string("S/R", title="Etiqueta Personalizada", group="Media 4")

// MA 5
ma5_show = input.bool(false, title="Activar Media 5", group="Media 5")
ma5_type = input.string("EMA", title="MA 5 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 5")
ma5_len  = input.int(500, title="MA 5 Periodo", minval=1, group="Media 5")
ma5_col  = input.color(color.teal, title="MA 5 Color", group="Media 5")
ma5_thk  = input.int(1, title="MA 5 Grosor", minval=1, maxval=4, group="Media 5")
ma5_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 5")

// MA 6
ma6_show = input.bool(false, title="Activar Media 6", group="Media 6")
ma6_type = input.string("EMA", title="MA 6 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 6")
ma6_len  = input.int(1000, title="MA 6 Periodo", minval=1, group="Media 6")
ma6_col  = input.color(color.blue, title="MA 6 Color", group="Media 6")
ma6_thk  = input.int(1, title="MA 6 Grosor", minval=1, maxval=4, group="Media 6")
ma6_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 6")

// MA 7
ma7_show = input.bool(false, title="Activar Media 7", group="Media 7")
ma7_type = input.string("EMA", title="MA 7 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 7")
ma7_len  = input.int(1250, title="MA 7 Periodo", minval=1, group="Media 7")
ma7_col  = input.color(color.navy, title="MA 7 Color", group="Media 7")
ma7_thk  = input.int(1, title="MA 7 Grosor", minval=1, maxval=4, group="Media 7")
ma7_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 7")

// MA 8
ma8_show = input.bool(false, title="Activar Media 8", group="Media 8")
ma8_type = input.string("EMA", title="MA 8 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 8")
ma8_len  = input.int(1500, title="MA 8 Periodo", minval=1, group="Media 8")
ma8_col  = input.color(color.purple, title="MA 8 Color", group="Media 8")
ma8_thk  = input.int(1, title="MA 8 Grosor", minval=1, maxval=4, group="Media 8")
ma8_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 8")

// MA 9
ma9_show = input.bool(false, title="Activar Media 9", group="Media 9")
ma9_type = input.string("EMA", title="MA 9 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 9")
ma9_len  = input.int(90, title="MA 9 Periodo", minval=1, group="Media 9")
ma9_col  = input.color(color.maroon, title="MA 9 Color", group="Media 9")
ma9_thk  = input.int(1, title="MA 9 Grosor", minval=1, maxval=4, group="Media 9")
ma9_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 9")

// MA 10
ma10_show = input.bool(false, title="Activar Media 10", group="Media 10")
ma10_type = input.string("EMA", title="MA 10 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 10")
ma10_len  = input.int(100, title="MA 10 Periodo", minval=1, group="Media 10")
ma10_col  = input.color(color.fuchsia, title="MA 10 Color", group="Media 10")
ma10_thk  = input.int(1, title="MA 10 Grosor", minval=1, maxval=4, group="Media 10")
ma10_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 10")

// MA 11
ma11_show = input.bool(false, title="Activar Media 11", group="Media 11")
ma11_type = input.string("EMA", title="MA 11 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 11")
ma11_len  = input.int(120, title="MA 11 Periodo", minval=1, group="Media 11")
ma11_col  = input.color(color.lime, title="MA 11 Color", group="Media 11")
ma11_thk  = input.int(1, title="MA 11 Grosor", minval=1, maxval=4, group="Media 11")
ma11_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 11")

// MA 12
ma12_show = input.bool(false, title="Activar Media 12", group="Media 12")
ma12_type = input.string("EMA", title="MA 12 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 12")
ma12_len  = input.int(140, title="MA 12 Periodo", minval=1, group="Media 12")
ma12_col  = input.color(color.olive, title="MA 12 Color", group="Media 12")
ma12_thk  = input.int(1, title="MA 12 Grosor", minval=1, maxval=4, group="Media 12")
ma12_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 12")

// MA 13
ma13_show = input.bool(false, title="Activar Media 13", group="Media 13")
ma13_type = input.string("EMA", title="MA 13 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 13")
ma13_len  = input.int(160, title="MA 13 Periodo", minval=1, group="Media 13")
ma13_col  = input.color(color.silver, title="MA 13 Color", group="Media 13")
ma13_thk  = input.int(1, title="MA 13 Grosor", minval=1, maxval=4, group="Media 13")
ma13_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 13")

// MA 14
ma14_show = input.bool(false, title="Activar Media 14", group="Media 14")
ma14_type = input.string("EMA", title="MA 14 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 14")
ma14_len  = input.int(180, title="MA 14 Periodo", minval=1, group="Media 14")
ma14_col  = input.color(color.gray, title="MA 14 Color", group="Media 14")
ma14_thk  = input.int(1, title="MA 14 Grosor", minval=1, maxval=4, group="Media 14")
ma14_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 14")

// MA 15
ma15_show = input.bool(false, title="Activar Media 15", group="Media 15")
ma15_type = input.string("EMA", title="MA 15 Tipo", options=["SMA", "EMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ALMA"], group="Media 15")
ma15_len  = input.int(200, title="MA 15 Periodo", minval=1, group="Media 15")
ma15_col  = input.color(color.white, title="MA 15 Color", group="Media 15")
ma15_thk  = input.int(1, title="MA 15 Grosor", minval=1, maxval=4, group="Media 15")
ma15_lbl  = input.string("", title="Etiqueta Personalizada", group="Media 15")

// --- CÁLCULOS DE LAS MEDIAS ---
v1 = get_ma(ma1_type, close, ma1_len)
v2 = get_ma(ma2_type, close, ma2_len)
v3 = get_ma(ma3_type, close, ma3_len)
v4 = get_ma(ma4_type, close, ma4_len)
v5 = get_ma(ma5_type, close, ma5_len)
v6 = get_ma(ma6_type, close, ma6_len)
v7 = get_ma(ma7_type, close, ma7_len)
v8 = get_ma(ma8_type, close, ma8_len)
v9 = get_ma(ma9_type, close, ma9_len)
v10 = get_ma(ma10_type, close, ma10_len)
v11 = get_ma(ma11_type, close, ma11_len)
v12 = get_ma(ma12_type, close, ma12_len)
v13 = get_ma(ma13_type, close, ma13_len)
v14 = get_ma(ma14_type, close, ma14_len)
v15 = get_ma(ma15_type, close, ma15_len)

// --- PLOTEO EN EL GRÁFICO ---
plot(ma1_show ? v1 : na, title="MA 1", color=ma1_col, linewidth=ma1_thk)
plot(ma2_show ? v2 : na, title="MA 2", color=ma2_col, linewidth=ma2_thk)
plot(ma3_show ? v3 : na, title="MA 3", color=ma3_col, linewidth=ma3_thk)
plot(ma4_show ? v4 : na, title="MA 4", color=ma4_col, linewidth=ma4_thk)
plot(ma5_show ? v5 : na, title="MA 5", color=ma5_col, linewidth=ma5_thk)
plot(ma6_show ? v6 : na, title="MA 6", color=ma6_col, linewidth=ma6_thk)
plot(ma7_show ? v7 : na, title="MA 7", color=ma7_col, linewidth=ma7_thk)
plot(ma8_show ? v8 : na, title="MA 8", color=ma8_col, linewidth=ma8_thk)
plot(ma9_show ? v9 : na, title="MA 9", color=ma9_col, linewidth=ma9_thk)
plot(ma10_show ? v10 : na, title="MA 10", color=ma10_col, linewidth=ma10_thk)
plot(ma11_show ? v11 : na, title="MA 11", color=ma11_col, linewidth=ma11_thk)
plot(ma12_show ? v12 : na, title="MA 12", color=ma12_col, linewidth=ma12_thk)
plot(ma13_show ? v13 : na, title="MA 13", color=ma13_col, linewidth=ma13_thk)
plot(ma14_show ? v14 : na, title="MA 14", color=ma14_col, linewidth=ma14_thk)
plot(ma15_show ? v15 : na, title="MA 15", color=ma15_col, linewidth=ma15_thk)

// --- LÓGICA PARA ETIQUETAS FLOTANTES (SOLO EN LA ÚLTIMA VELA) ---
get_label_text(type, len, custom_lbl) =>
    str = type + " (" + str.tostring(len) + ")"
    res_text = custom_lbl != "" ? str + " - " + custom_lbl : str
    res_text

if barstate.islast and show_labels
    if ma1_show
        label.new(bar_index, v1, text=get_label_text(ma1_type, ma1_len, ma1_lbl), color=color.new(ma1_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma2_show
        label.new(bar_index, v2, text=get_label_text(ma2_type, ma2_len, ma2_lbl), color=color.new(ma2_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma3_show
        label.new(bar_index, v3, text=get_label_text(ma3_type, ma3_len, ma3_lbl), color=color.new(ma3_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma4_show
        label.new(bar_index, v4, text=get_label_text(ma4_type, ma4_len, ma4_lbl), color=color.new(ma4_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma5_show
        label.new(bar_index, v5, text=get_label_text(ma5_type, ma5_len, ma5_lbl), color=color.new(ma5_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma6_show
        label.new(bar_index, v6, text=get_label_text(ma6_type, ma6_len, ma6_lbl), color=color.new(ma6_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma7_show
        label.new(bar_index, v7, text=get_label_text(ma7_type, ma7_len, ma7_lbl), color=color.new(ma7_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma8_show
        label.new(bar_index, v8, text=get_label_text(ma8_type, ma8_len, ma8_lbl), color=color.new(ma8_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma9_show
        label.new(bar_index, v9, text=get_label_text(ma9_type, ma9_len, ma9_lbl), color=color.new(ma9_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma10_show
        label.new(bar_index, v10, text=get_label_text(ma10_type, ma10_len, ma10_lbl), color=color.new(ma10_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma11_show
        label.new(bar_index, v11, text=get_label_text(ma11_type, ma11_len, ma11_lbl), color=color.new(ma11_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma12_show
        label.new(bar_index, v12, text=get_label_text(ma12_type, ma12_len, ma12_lbl), color=color.new(ma12_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma13_show
        label.new(bar_index, v13, text=get_label_text(ma13_type, ma13_len, ma13_lbl), color=color.new(ma13_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma14_show
        label.new(bar_index, v14, text=get_label_text(ma14_type, ma14_len, ma14_lbl), color=color.new(ma14_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)
    if ma15_show
        label.new(bar_index, v15, text=get_label_text(ma15_type, ma15_len, ma15_lbl), color=color.new(ma15_col, 20), textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_index)

// --- LÓGICA PARA CONSTRUIR LA TABLA DE LEYENDA ---
var table legendTable = na
if barstate.islast and show_table
    int active_count = 0
    if ma1_show
        active_count += 1
    if ma2_show
        active_count += 1
    if ma3_show
        active_count += 1
    if ma4_show
        active_count += 1
    if ma5_show
        active_count += 1
    if ma6_show
        active_count += 1
    if ma7_show
        active_count += 1
    if ma8_show
        active_count += 1
    if ma9_show
        active_count += 1
    if ma10_show
        active_count += 1
    if ma11_show
        active_count += 1
    if ma12_show
        active_count += 1
    if ma13_show
        active_count += 1
    if ma14_show
        active_count += 1
    if ma15_show
        active_count += 1

    if active_count > 0
        legendTable := table.new(get_table_pos(table_pos), columns=3, rows=active_count + 1, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.gray)
        
        table.cell(legendTable, 0, 0, "Media", text_color=color.white, text_size=size.small, bgcolor=color.gray)
        table.cell(legendTable, 1, 0, "Periodo", text_color=color.white, text_size=size.small, bgcolor=color.gray)
        table.cell(legendTable, 2, 0, "Nombre / Nota", text_color=color.white, text_size=size.small, bgcolor=color.gray)
        
        int row_index = 1
        
        if ma1_show
            table.cell(legendTable, 0, row_index, ma1_type, text_color=color.white, bgcolor=ma1_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma1_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma1_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma2_show
            table.cell(legendTable, 0, row_index, ma2_type, text_color=color.white, bgcolor=ma2_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma2_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma2_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma3_show
            table.cell(legendTable, 0, row_index, ma3_type, text_color=color.white, bgcolor=ma3_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma3_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma3_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma4_show
            table.cell(legendTable, 0, row_index, ma4_type, text_color=color.white, bgcolor=ma4_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma4_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma4_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma5_show
            table.cell(legendTable, 0, row_index, ma5_type, text_color=color.white, bgcolor=ma5_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma5_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma5_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma6_show
            table.cell(legendTable, 0, row_index, ma6_type, text_color=color.white, bgcolor=ma6_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma6_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma6_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma7_show
            table.cell(legendTable, 0, row_index, ma7_type, text_color=color.white, bgcolor=ma7_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma7_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma7_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma8_show
            table.cell(legendTable, 0, row_index, ma8_type, text_color=color.white, bgcolor=ma8_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma8_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma8_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma9_show
            table.cell(legendTable, 0, row_index, ma9_type, text_color=color.white, bgcolor=ma9_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma9_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma9_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma10_show
            table.cell(legendTable, 0, row_index, ma10_type, text_color=color.white, bgcolor=ma10_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma10_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma10_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma11_show
            table.cell(legendTable, 0, row_index, ma11_type, text_color=color.white, bgcolor=ma11_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma11_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma11_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma12_show
            table.cell(legendTable, 0, row_index, ma12_type, text_color=color.white, bgcolor=ma12_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma12_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma12_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma13_show
            table.cell(legendTable, 0, row_index, ma13_type, text_color=color.white, bgcolor=ma13_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma13_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma13_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma14_show
            table.cell(legendTable, 0, row_index, ma14_type, text_color=color.white, bgcolor=ma14_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma14_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma14_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
        if ma15_show
            table.cell(legendTable, 0, row_index, ma15_type, text_color=color.white, bgcolor=ma15_col, text_size=size.small)
            table.cell(legendTable, 1, row_index, str.tostring(ma15_len), text_color=color.white, text_size=size.small)
            table.cell(legendTable, 2, row_index, ma15_lbl, text_color=color.white, text_size=size.small)
            row_index += 1
````
