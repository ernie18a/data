# Time Block Shading (TC2000 Style)

- url: https://www.tradingview.com/script/GSUQ6tQT/
- type: indicator
- pine_id: PUB;2499168011b2481dbc95e49aeb1fcdaf
- version: 1.0

## Description

This indicator solves the classic time-offset issue when migrating from platforms like TC2000 or ThinkOrSwim to TradingView. While TradingView forces 1-hour candles to open at 9:30 AM NY, this script groups candles on the 30-minute chart to recreate pure hourly blocks starting at 10:00 AM NY.

[b]Can only be used on the 30-minute timeframe.[/b]

[b]Key Features:[/b]
Smart Grouping: Automatically detects 30-minute candle pairs starting from 10:00 AM.

[b]Range Boxes (High/Low):[/b] Draws visual rectangles that frame the exact high and low of each hourly block.

[b]Strict Open/Close Coloring[/b]: Compares the close of the second candle against the open of the first candle in the block (Green for bullish, Red for bearish).

[b]Clean Design:[/b] Shading is strictly restricted to its specific pair of candles, without distorting past or future data. It is only visible on the 30-minute timeframe to prevent noise on other timeframes.

## Source Code

````pine
//@version=6
indicator("Velas de Hora TC2000 con Mechas V6 - Corregido", overlay=true)

// 1. Restringir estrictamente a la temporalidad de 30 minutos
is_30m = timeframe.isminutes and timeframe.multiplier == 30

// 2. Configurar la sesión de mercado (Horario de Nueva York: 10:00 AM a 4:00 PM)
in_session = not na(time(timeframe.period, "1000-1600:23456"))

// 3. Detectar si la vela abre exactamente en la hora en punto (10:00, 11:00, etc.)
is_hour_start = (hour * 60 + minute) % 60 == 0

// Variables persistentes para el control del grupo y objetos visuales
var float group_open  = na
var float group_high  = na
var float group_low   = na
var int   start_bar   = na
var box   hour_box    = na
var line  top_wick    = na
var line  bottom_wick = na

// Lógica principal aplicada solo en 30 minutos y dentro de la sesión
if is_30m and in_session
    if is_hour_start
        // --- VELA 1 DE LA HORA (En punto) ---
        group_open := open
        group_high := high
        group_low  := low
        start_bar  := bar_index
        
        // Determinar colores iniciales provisionales basados en el cierre de la primera vela
        bool is_bullish = close >= group_open
        color_box = is_bullish ? color.new(color.green, 90) : color.new(color.red, 90)
        color_border = is_bullish ? color.new(color.green, 50) : color.new(color.red, 50)
        color_wick = is_bullish ? color.new(color.green, 60) : color.new(color.red, 60)
        
        // Determinar niveles del cuerpo provisional (Caja)
        float body_top = math.max(group_open, close)
        float body_bottom = math.min(group_open, close)
        
        // Crear la caja (Cuerpo de la vela de hora)
        hour_box := box.new(left=start_bar, top=body_top, right=bar_index, bottom=body_bottom,
                             bgcolor=color_box, border_color=color_border, border_style=line.style_dashed)
                             
        // Crear las líneas para las mechas usando el índice entero de la primera barra (start_bar)
        top_wick := line.new(x1=start_bar, y1=group_high, x2=start_bar, y2=body_top, 
                             color=color_wick, style=line.style_dashed, width=1)
        bottom_wick := line.new(x1=start_bar, y1=body_bottom, x2=start_bar, y2=group_low, 
                                color=color_wick, style=line.style_dashed, width=1)
                             
    else if not na(start_bar) and (bar_index == start_bar + 1)
        // --- VELA 2 DE LA HORA (Media hora) ---
        // Actualizar el máximo y mínimo definitivos combinando ambas velas
        group_high := math.max(group_high, high)
        group_low  := math.min(group_low, low)
        
        // Determinar niveles del cuerpo final reales usando el cierre de la segunda vela
        float body_top = math.max(group_open, close)
        float body_bottom = math.min(group_open, close)
        
        // Determinar color final comparando el CIERRE de la 2da vela contra la APERTURA de la 1ra
        bool is_bullish = close >= group_open
        color_box = is_bullish ? color.new(color.green, 85) : color.new(color.red, 85)
        color_border = is_bullish ? color.green : color.red
        color_wick = is_bullish ? color.green : color.red
        
        // 1. Modificar la caja para que abarque horizontalmente ambas velas y verticalmente el cuerpo real
        box.set_right(hour_box, bar_index)
        box.set_top(hour_box, body_top)
        box.set_bottom(hour_box, body_bottom)
        box.set_bgcolor(hour_box, color_box)
        box.set_border_color(hour_box, color_border)
        box.set_border_style(hour_box, line.style_solid)
        box.set_border_width(hour_box, 2)
        
        // 2. Modificar las mechas definitivas alineadas a la primera barra
        // Mecha superior: Desde el precio máximo total hasta la parte alta del cuerpo
        line.set_xy1(top_wick, start_bar, group_high)
        line.set_xy2(top_wick, start_bar, body_top)
        line.set_color(top_wick, color_wick)
        line.set_style(top_wick, line.style_solid)
        line.set_width(top_wick, 2)
        
        // Mecha inferior: Desde la parte baja del cuerpo hasta el precio mínimo total
        line.set_xy1(bottom_wick, start_bar, body_bottom)
        line.set_xy2(bottom_wick, start_bar, group_low)
        line.set_color(bottom_wick, color_wick)
        line.set_style(bottom_wick, line.style_solid)
        line.set_width(bottom_wick, 2)
````
