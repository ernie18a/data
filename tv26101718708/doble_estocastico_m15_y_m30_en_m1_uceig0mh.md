# Doble Estocastico (M15 y M30 en M1)

- url: https://www.tradingview.com/script/ucEiG0MH/
- type: indicator
- pine_id: PUB;ae2f6b335bd34c928411622aa938e983
- version: 2.0

## Description

Oscilador Estocástico doble diseñado específicamente para gráficos de 1 minuto (M1). El indicador normaliza y escala matemáticamente las longitudes temporales para visualizar la estructura y los giros de momentum de temporalidades mayores (M15 y M30) de forma fluida y dinámica, eliminando el efecto escalonado de las funciones MTF nativas.
​Configuración integrada (Proporción 10, 14, 3):
​Líneas Rojas (M15): Longitud %K de 150 periodos, suavizado %K de 14 y %D de 3.
​Líneas Azules (M30): Longitud %K de 300 periodos, suavizado %K de 14 y %D de 3.
​Niveles: Bandas estándar de sobrecompra en 80 y sobreventa en 20.
​Ideal para optimizar el espacio de trabajo en cuentas con límites de indicadores, agrupando dos osciladores clave en un único panel inferior.

## Source Code

````pine
//@version=6
indicator("Dual Stochastic (M15 & M30 in M1)", overlay=false)

// Inputs for M15 (Scaled to 1m)
stoch15K   = input.int(150, "M15 %K Length", minval=1)
stoch15SmK = input.int(14, "M15 %K Smooth", minval=1)
stoch15D   = input.int(3, "M15 %D Smooth", minval=1)

// Inputs for M30 (Scaled to 1m)
stoch30K   = input.int(300, "M30 %K Length", minval=1)
stoch30SmK = input.int(14, "M30 %K Smooth", minval=1)
stoch30D   = input.int(3, "M30 %D Smooth", minval=1)

// Calculations
// M15
stoch15_k_raw = ta.stoch(close, high, low, stoch15K)
stoch15_k     = ta.ema(stoch15_k_raw, stoch15SmK)
stoch15_d     = ta.ema(stoch15_k, stoch15D)

// M30
stoch30_k_raw = ta.stoch(close, high, low, stoch30K)
stoch30_k     = ta.ema(stoch30_k_raw, stoch30SmK)
stoch30_d     = ta.ema(stoch30_k, stoch30D)

// Plots
plot(stoch15_k, "M15 %K", color=color.blue, linewidth=2)
plot(stoch15_d, "M15 %D", color=color.new(color.blue, 40), style=plot.style_line)

plot(stoch30_k, "M30 %K", color=color.red, linewidth=2)
plot(stoch30_d, "M30 %D", color=color.new(color.red, 40), style=plot.style_line)

// Levels
hline(80, "Overbought", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
hline(20, "Oversold", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
````
