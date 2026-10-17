# All-Time High ATH support - SantiCruz

- url: https://www.tradingview.com/script/kIEkSGln-All-Time-High-ATH-support-SantiCruz/
- type: indicator
- pine_id: PUB;219521e2e2b248e7a57970976d16faec
- version: 1.0

## Description

This scipt will draw a Support Line / Horizontal Line in the ALL-TIME-HIGH price point of any asset.
It is a very heplful way to automatically detect the ATH without the need of continuous updating .  This line will automatically update to to the All time High. EXPREMELY USEFUL. 

All time high tends to be a price reversal zone specially for stocks.  Stocks tend to react more on the all time high specailly vs FOREX Pairs and some ETF that involve many other assets that may drive the reversal deceision rather than just the ETF tough it may also funciotion as a reversal zone.

## Source Code

````pine
//@version=6
indicator("All-Time High ATH support - SantiCruz", overlay=true, max_lines_count=100, max_labels_count=100)

// -----------------------------------------------------------------
// 1. Configuración de Colores (Personalizables desde el menú)
// -----------------------------------------------------------------
group_style = "Configuración Visual"
line_color  = input.color(color.rgb(211, 47, 47), title="Color de Línea y Texto", group=group_style)

// -----------------------------------------------------------------
// 2. Cálculo del Máximo Histórico Real (ATH)
// -----------------------------------------------------------------
var float ath_price = na

if barstate.isfirst
    ath_price := high
else
    if high > ath_price
        ath_price := high

// -----------------------------------------------------------------
// 3. Renderizado de la Línea de Soporte y Etiqueta ATH
// -----------------------------------------------------------------
var line ath_line = na
var label atm_label = na

if barstate.islast
    if na(ath_line)
        // Usamos bar_index nativo y extend.both para que cruce todo el chart de forma infinita
        ath_line := line.new(
             x1=bar_index, y1=ath_price, 
             x2=bar_index + 1, y2=ath_price, 
             xloc=xloc.bar_index, 
             extend=extend.both, 
             color=line_color, 
             style=line.style_solid, 
             width=4
             )
    else
        line.set_xy1(ath_line, bar_index, ath_price)
        line.set_xy2(ath_line, bar_index + 1, ath_price)
        line.set_color(ath_line, line_color)

    // Posición del texto "ATM" (5 barras a la derecha del precio actual)
    int label_x_position = bar_index + 5

    if na(atm_label)
        atm_label := label.new(
             x=label_x_position, 
             y=ath_price, 
             text="ATH", 
             xloc=xloc.bar_index, 
             yloc=yloc.price, 
             color=color.new(color.white, 100), // Fondo transparente
             textcolor=line_color, 
             style=label.style_label_upper_left, // Texto abajo y a la derecha de la línea
             size=size.large
             )
    else
        label.set_x(atm_label, label_x_position)
        label.set_y(atm_label, ath_price)
        label.set_textcolor(atm_label, line_color)
````
