# Atr exit manager

- url: https://www.tradingview.com/script/stvoUpxq/
- type: indicator
- pine_id: PUB;d3ed0369fd54484a9bb8025c1e5e6a8f
- version: 1.0

## Description

This script manages trade exits using the ATR (Average True Range) indicator. It calculates dynamic exit levels based on current market volatility, helping to adjust stop losses technically to protect profits and manage risk effectively.

## Source Code

````pine
//@version=5
indicator("Niveles Oro Limpios", overlay=true)

// Configuración
distancia = input.int(10, title="Incremento entre líneas")
colorLineas = input.color(color.blue, title="Color de las líneas")

// Cálculo de niveles visibles en pantalla
startPrice = math.floor(low / distancia) * distancia
for i = 0 to 20
    level = startPrice + (i * distancia)
    // Dibujamos la línea
    line.new(bar_index[100], level, bar_index + 10, level, color=color.new(colorLineas, 50), width=1, style=line.style_solid)
    // Dibujamos el texto sobre la línea, NO en el eje
    label.new(bar_index + 2, level, str.tostring(level, "#"), style=label.style_none, textcolor=colorLineas, textalign=text.align_left)
````
