<!-- tradingview-pine-id: PUB;e598d7cc8a7d43018f6fffac35fd98b9 -->
<!-- tradingviewscripts-format: 1 -->
# Sop/Res con % Fer_inversiones

Source: https://www.tradingview.com/script/F5oSYlwU/

## Description

**Soporte y Resistencia Dinámico con Porcentaje / Dynamic Support & Resistance with Percentage**

**[ES] Descripción:**
Esta herramienta está diseñada para identificar y trazar automáticamente **niveles dinámicos de soporte y resistencia** en el gráfico, facilitando la visualización de zonas clave de oferta y demanda en tiempo real.

* **Cálculo Dinámico:** El script evalúa la estructura de precios para determinar niveles relevantes que se adaptan a la acción del precio.
* **Margen Porcentual:** Incorpora un ajuste en porcentaje para definir zonas de reacción en lugar de líneas rígidas, contemplando la volatilidad del mercado.
* **Uso:** Ideal para identificar zonas de rebote (soportes) y techos de presión vendedora (resistencias). Funciona en cualquier temporalidad y mercado (Acciones, Criptos, Índices).

---

**[EN] Description:**
This tool is designed to automatically identify and plot **dynamic support and resistance levels** on the chart, helping traders visualize key supply and demand zones in real time.

* **Dynamic Calculation:** Evaluates price action structure to plot key levels that automatically adjust over time.
* **Percentage Margin:** Incorporates a percentage buffer to define reaction zones rather than single rigid lines, taking market volatility into account.
* **Usage:** Great for identifying potential bounce zones (supports) and rejection areas (resistances). Works across all timeframes and assets (Stocks, Crypto, Indices).

---

---

## Source Code

````pine
//@version=6
indicator(title='Sop/Res con % Fer_inversiones', shorttitle="Sop/Res DINÁMICO", overlay=true, max_bars_back=500)

// --- CONFIGURACIÓN DE LA IMAGEN ---
poi_group = 'SUPPLY/DEMAND ZONE'
swing_length = input.int(10, title = 'Swing High/Low Length', group = poi_group, minval = 1)
history_max  = input.int(20, title = 'History To Keep', group = poi_group, minval = 1)

// --- CONFIGURACIÓN ADICIONAL ---
use_vol_filter = input.bool(true, title = 'Filtrar solo zonas con volumen > promedio', group = poi_group)

// --- CONFIGURACIÓN DE GROSOR DINÁMICO ---
grosor_group   = 'Grosor Dinámico Porcentual (0-100%)'
atr_length     = input.int(50, title = 'Período del ATR', group = grosor_group, minval = 1)
max_height_atr = input.float(1.5, title = 'Altura Máxima de la Zona (en ATRs al 100%)', group = grosor_group, minval = 0.1, step = 0.1)

// --- COLORES Y TEXTO DE ZONAS ---
visual_group = 'Visual Settings'
show_supply = input.bool(true, title = 'Mostrar Supply Fresca', group = visual_group)
show_demand = input.bool(true, title = 'Mostrar Demand Fresca', group = visual_group)
show_tested = input.bool(true, title = 'Mostrar Zonas Testeadas', group = visual_group)

supply_color = input.color(color.new(color.red, 70), title = 'Color Supply Fresca', group = visual_group)
demand_color = input.color(color.new(color.green, 70), title = 'Color Demand Fresca', group = visual_group)
tested_color = input.color(color.new(color.gray, 85), title = 'Color Zona Testeada (Gris)', group = visual_group)

supply_out   = input.color(color.new(color.black, 20), title = 'Supply Outline', group = visual_group)
demand_out   = input.color(color.new(color.black, 20), title = 'Demand Outline', group = visual_group)
text_color_input = input.color(color.rgb(0, 0, 0), title = 'Color del Texto', group = visual_group)

// OPCIONES DE TEXTO PARA ZONAS
text_size_zone_input = input.string("Small", title="Tamaño del Texto de Zonas", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = visual_group)
font_family_input    = input.string("Default", title="Estilo de Fuente de Zonas", options=["Default", "Monospace"], group = visual_group)
compact_text_input   = input.bool(false, title="Texto Compacto en Zonas", group = visual_group)

get_font_family(string f) =>
    f == "Monospace" ? font.family_monospace : font.family_default

get_text_size(string sz) =>
    switch sz
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

// --- PANEL DE PRECIOS EN PANTALLA ---
info_group   = 'Panel de Precios'
show_table   = input.bool(true, title = 'Mostrar Panel de Precios', group = info_group)
price_type   = input.string("Entrada (Proximal)", title = 'Precio a mostrar', options = ["Entrada (Proximal)", "50% (Equilibrium)", "Límite Opuesto (Distal)"], group = info_group)
pos_table    = input.string("Top Center", title = 'Posición del Panel', options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = info_group)
table_text_sz_input = input.string("Small", title = 'Tamaño del Texto del Panel', options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = info_group)

get_table_pos(string pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_center

// --- VARIABLES Y CONTENEDORES ---
var box[] active_supply = array.new_box()
var box[] active_demand = array.new_box()

var bool[] supply_tested = array.new_bool()
var bool[] demand_tested = array.new_bool()

vol_ma = ta.sma(volume, 20)
atrpoi = ta.atr(atr_length)

swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low  = ta.pivotlow(low, swing_length, swing_length)

// --- CÁLCULO DE VOLUMEN E INTENCIÓN ---
candle_range = high - low
buying_ratio = candle_range == 0 ? 0.5 : (close - low) / candle_range
selling_ratio = 1.0 - buying_ratio

vol_comprador = volume * buying_ratio
vol_vendedor = volume * selling_ratio
vol_total = volume > 0 ? volume : 1.0

// --- NUEVA SUPPLY (OFERTA) ---
if not na(swing_high) and (not use_vol_filter or volume[swing_length] > vol_ma[swing_length])
    pct_vendedor = (vol_vendedor[swing_length] / vol_total[swing_length]) * 100
    atr_buffer = (atrpoi[swing_length] * max_height_atr) * (pct_vendedor / 100.0)
    
    box_top = swing_high
    box_bottom = box_top - atr_buffer
    
    string info_text = compact_text_input ? 
                       "SUPPLY (" + str.tostring(pct_vendedor, "#.#") + "%)" : 
                       "SUPPLY [" + str.tostring(pct_vendedor, "#.#") + "% VENDEDORES]"
    
    current_bg = show_supply ? supply_color : color.new(color.white, 100)
    current_border = show_supply ? supply_out : color.new(color.white, 100)
    current_text = show_supply ? text_color_input : color.new(color.white, 100)

    sb = box.new(left=bar_index - swing_length, top=box_top, right=bar_index, bottom=box_bottom, 
                 border_color=current_border, bgcolor=current_bg, text=info_text, text_color=current_text, 
                 text_size=get_text_size(text_size_zone_input), text_font_family=get_font_family(font_family_input), extend=extend.right)
    array.push(active_supply, sb)
    array.push(supply_tested, false)
    
    if array.size(active_supply) > history_max
        box.delete(array.shift(active_supply))
        array.shift(supply_tested)

// --- NUEVA DEMAND (DEMANDA) ---
if not na(swing_low) and (not use_vol_filter or volume[swing_length] > vol_ma[swing_length])
    pct_comprador = (vol_comprador[swing_length] / vol_total[swing_length]) * 100
    atr_buffer = (atrpoi[swing_length] * max_height_atr) * (pct_comprador / 100.0)
    
    box_bottom = swing_low
    box_top = box_bottom + atr_buffer
    
    string info_text = compact_text_input ? 
                       "DEMAND (" + str.tostring(pct_comprador, "#.#") + "%)" : 
                       "DEMAND [" + str.tostring(pct_comprador, "#.#") + "% COMPRADORES]"
    
    current_bg = show_demand ? demand_color : color.new(color.white, 100)
    current_border = show_demand ? demand_out : color.new(color.white, 100)
    current_text = show_demand ? text_color_input : color.new(color.white, 100)

    db = box.new(left=bar_index - swing_length, top=box_top, right=bar_index, bottom=box_bottom, 
                 border_color=current_border, bgcolor=current_bg, text=info_text, text_color=current_text, 
                 text_size=get_text_size(text_size_zone_input), text_font_family=get_font_family(font_family_input), extend=extend.right)
    array.push(active_demand, db)
    array.push(demand_tested, false)
    
    if array.size(active_demand) > history_max
        box.delete(array.shift(active_demand))
        array.shift(demand_tested)

// --- CONTROL DE RE-TEST Y MITIGACIÓN DE SUPPLY ---
if array.size(active_supply) > 0
    for i = array.size(active_supply) - 1 to 0 by 1
        current_box = array.get(active_supply, i)
        box_top = box.get_top(current_box)
        box_bottom = box.get_bottom(current_box)
        
        if high >= box_bottom and close <= box_top
            array.set(supply_tested, i, true)
            
        is_tested = array.get(supply_tested, i)
        if is_tested
            if show_tested
                box.set_bgcolor(current_box, tested_color)
                box.set_border_color(current_box, tested_color)
            else
                box.set_bgcolor(current_box, color.new(color.white, 100))
                box.set_border_color(current_box, color.new(color.white, 100))
                box.set_text_color(current_box, color.new(color.white, 100))
        else
            if not show_supply
                box.set_bgcolor(current_box, color.new(color.white, 100))
                box.set_border_color(current_box, color.new(color.white, 100))
                box.set_text_color(current_box, color.new(color.white, 100))
            else
                box.set_bgcolor(current_box, supply_color)
                box.set_border_color(current_box, supply_out)
                box.set_text_color(current_box, text_color_input)
            
        if close > box_top
            box.delete(current_box)
            array.remove(active_supply, i)
            array.remove(supply_tested, i)

// --- CONTROL DE RE-TEST Y MITIGACIÓN DE DEMAND ---
if array.size(active_demand) > 0
    for i = array.size(active_demand) - 1 to 0 by 1
        current_box = array.get(active_demand, i)
        box_top = box.get_top(current_box)
        box_bottom = box.get_bottom(current_box)
        
        if low <= box_top and close >= box_bottom
            array.set(demand_tested, i, true)
            
        is_tested = array.get(demand_tested, i)
        if is_tested
            if show_tested
                box.set_bgcolor(current_box, tested_color)
                box.set_border_color(current_box, tested_color)
            else
                box.set_bgcolor(current_box, color.new(color.white, 100))
                box.set_border_color(current_box, color.new(color.white, 100))
                box.set_text_color(current_box, color.new(color.white, 100))
        else
            if not show_demand
                box.set_bgcolor(current_box, color.new(color.white, 100))
                box.set_border_color(current_box, color.new(color.white, 100))
                box.set_text_color(current_box, text_color_input)
            
        if close < box_bottom
            box.delete(current_box)
            array.remove(active_demand, i)
            array.remove(demand_tested, i)

// --- ZONAS MÁS CERCANAS ---
float[] s_prices = array.new_float()
if array.size(active_supply) > 0
    for i = 0 to array.size(active_supply) - 1
        box b = array.get(active_supply, i)
        s_top = box.get_top(b)
        s_bot = box.get_bottom(b)
        p = price_type == "Entrada (Proximal)" ? s_bot : price_type == "50% (Equilibrium)" ? (s_top + s_bot) / 2.0 : s_top
        array.push(s_prices, p)
array.sort(s_prices, order.ascending)

float supply_closest = array.size(s_prices) > 0 ? array.get(s_prices, 0) : na

float[] d_prices = array.new_float()
if array.size(active_demand) > 0
    for i = 0 to array.size(active_demand) - 1
        box b = array.get(active_demand, i)
        d_top = box.get_top(b)
        d_bot = box.get_bottom(b)
        p = price_type == "Entrada (Proximal)" ? d_top : price_type == "50% (Equilibrium)" ? (d_top + d_bot) / 2.0 : d_bot
        array.push(d_prices, p)
array.sort(d_prices, order.descending)

float demand_closest = array.size(d_prices) > 0 ? array.get(d_prices, 0) : na

plot(supply_closest, title="Supply Más Cercana", color=color.new(color.red, 100), display=display.data_window)
plot(demand_closest, title="Demand Más Cercana", color=color.new(color.green, 100), display=display.data_window)

// --- DIBUJAR TABLA PERSISTENTE (OPTIMIZADA) ---
var table info_table = table.new(position = get_table_pos(pos_table), columns = 2, rows = 3, bgcolor = color.new(color.black, 30), border_color = color.new(color.gray, 60), border_width = 1)

if barstate.islast
    if show_table
        tbl_sz = get_text_size(table_text_sz_input)

        // Encabezados
        table.cell(info_table, 0, 0, "Zona",       bgcolor=color.rgb(20, 30, 55), text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)
        table.cell(info_table, 1, 0, "   Precio   ", bgcolor=color.rgb(20, 30, 55), text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)

        // Fila Supply
        string s_val = not na(supply_closest) ? str.tostring(supply_closest, "#.00") : "N/A"
        table.cell(info_table, 0, 1, "SUPPLY", bgcolor=color.new(color.red, 30),   text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)
        table.cell(info_table, 1, 1, s_val,    bgcolor=color.new(color.black, 20), text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)

        // Fila Demand
        string d_val = not na(demand_closest) ? str.tostring(demand_closest, "#.00") : "N/A"
        table.cell(info_table, 0, 2, "DEMAND", bgcolor=color.new(color.green, 30), text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)
        table.cell(info_table, 1, 2, d_val,    bgcolor=color.black, text_color=color.white, text_size=tbl_sz, text_halign=text.align_center)
    else
        table.clear(info_table, 0, 0, 1, 2)
````
