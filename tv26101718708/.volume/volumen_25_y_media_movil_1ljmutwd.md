# volumen 2.5 y media movil

- url: https://www.tradingview.com/script/1lJMUtwd/
- type: indicator
- pine_id: PUB;c473a03e0660452783e8a7b1174a9c7b
- version: 1.0

## Description

volumen. utc-3. media movil y linea multiplicadora. franjas.

## Source Code

````pine
//@version=5
indicator("Volumen con Media 2.5x", shorttitle="Vol 2.5x", overlay=false)

// Configuración de longitud (por defecto 20 períodos)
length = input.int(20, title="Longitud de la Media")
multiplicador = input.float(2.5, title="Multiplicador de Alerta")

// Cálculos
vol_sma = ta.sma(volume, length)
linea_alerta = vol_sma * multiplicador

// Colores de las barras de volumen (Verde si sube, Rojo si baja)
vol_color = close > open ? color.new(#089981, 50) : color.new(#f23645, 50)

// Gráficos
plot(volume, title="Volumen", style=plot.style_columns, color=vol_color)
plot(vol_sma, title="Media Simple", color=color.gray, linewidth=1)
plot(linea_alerta, title="Línea 2.5x", color=color.yellow, linewidth=2, style=plot.style_line)

// Opcional: Resaltar cuando el volumen cruza la línea 2.5x
bgcolor(volume > linea_alerta ? color.new(color.yellow, 90) : na)
````
