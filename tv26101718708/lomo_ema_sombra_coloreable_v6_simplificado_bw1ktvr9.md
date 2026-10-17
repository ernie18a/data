# Lomo EMA + Sombra Coloreable (v6) - Simplificado

- url: https://www.tradingview.com/script/bW1kTVr9/
- type: indicator
- pine_id: PUB;2a4af2d08e8a4b1ebb46710195ea189e
- version: 1.0

## Description

Este indicador se puede utilizar para marcar la zona de la EMA y no una línea. Ideal para aquellos tradres que nos hemos iniciado y no tenemos el ojo afinado del todo.
Funcionamiento:
- El sombreado marca la zona donde no debemos realizar operación ninguna.
- Vela sale de zona de sombrado, dependiendo su estrategia puede realizar entrada.
- Para scalping.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BERSANCH

//@version=6
indicator("Lomo EMA + Sombra Coloreable (v6) - Simplificado", overlay=true)

// ---------- INPUTS: EMA ----------
useEMA    = input.bool(true, "Mostrar EMA")
emaLength = input.int(20, "Periodo EMA", minval=1)
emaColor  = input.color(color.orange, "Color EMA")
emaWidth  = input.int(2, "Grosor EMA", minval=1, maxval=5)
emaStyle  = input.string("Line", "Estilo EMA", options=["Line","Stepline"])

// ---------- INPUTS: BANDA / SOMBRA ----------
useBand       = input.bool(true, "Mostrar Banda / Sombra")
bandModePct   = input.bool(true, "Ancho en % (ON) / Puntos (OFF)")
bandWidthPerc = input.float(0.5, "Ancho de la Banda (%)", minval=0.0, step=0.1)
bandWidthPts  = input.float(0.0, "Ancho de la Banda (puntos)", minval=0.0, step=0.1)

fillModeSingle = input.bool(true, "Usar un solo color (ON) / Colores según precio (OFF)")

// Color único (si fillModeSingle = true)
singleFillColorBase = input.color(#1E90FF, "Color Sombra (único)")
singleFillOpacity   = input.int(60, "Opacidad Sombra (0=opaco,100=transparente)", minval=0, maxval=100)

// Colores por encima/por debajo (si fillModeSingle = false)
fillAboveColorBase = input.color(#26A69A, "Color Sombra cuando Precio > EMA")
fillAboveOpacity   = input.int(50, "Opacidad Sombra arriba (0=opaco,100=transparente)", minval=0, maxval=100)
fillBelowColorBase = input.color(#EF5350, "Color Sombra cuando Precio < EMA")
fillBelowOpacity   = input.int(70, "Opacidad Sombra abajo (0=opaco,100=transparente)", minval=0, maxval=100)

showBorder    = input.bool(true, "Mostrar bordes de la banda")
borderColor   = input.color(#1E90FF, "Color Bordes")
borderWidth   = input.int(1, "Grosor Bordes", minval=1, maxval=4)

showLines     = input.bool(false, "Mostrar líneas de banda (útil para debug)")

// ---------- CÁLCULOS BÁSICOS ----------
emaLine = ta.ema(close, emaLength)

// Calcular bandas según modo
upperBand_calc = bandModePct ? emaLine * (1 + bandWidthPerc / 100) : emaLine + bandWidthPts
lowerBand_calc = bandModePct ? emaLine * (1 - bandWidthPerc / 100) : emaLine - bandWidthPts

// Si la banda está desactivada, usamos emaLine para no romper fills
upperBand = useBand ? upperBand_calc : emaLine
lowerBand = useBand ? lowerBand_calc : emaLine

// ---------- UTILIDADES ----------
f_toAlpha(v) => math.min(math.max(math.round(v * 2.55), 0), 255)

// Colores finales (sin opacidad dinámica ni ATR)
singleFillColor = fillModeSingle ? color.new(singleFillColorBase, useBand ? f_toAlpha(singleFillOpacity) : 255) : color.new(singleFillColorBase, 255)
aboveFillColor  = fillModeSingle ? color.new(fillAboveColorBase, 255) : color.new(fillAboveColorBase, useBand ? f_toAlpha(fillAboveOpacity) : 255)
belowFillColor  = fillModeSingle ? color.new(fillBelowColorBase, 255) : color.new(fillBelowColorBase, useBand ? f_toAlpha(fillBelowOpacity) : 255)

// Borde final
borderColorFinal = (useBand and showBorder) ? borderColor : color.new(borderColor, 255)
borderWidthFinal = (useBand and showBorder) ? borderWidth : 1

// Preparar colores/anchos de plots (no usar linewidth=0; usar color transparente alpha=255 para ocultar)
invisibleColorUpper = color.new(borderColorFinal, 255)
invisibleColorLower = color.new(borderColorFinal, 255)
invisibleColorMid   = color.new(emaColor, 255)

upperColorPlot = showLines ? borderColorFinal : invisibleColorUpper
lowerColorPlot = showLines ? borderColorFinal : invisibleColorLower
midColorPlot   = useEMA ? emaColor : invisibleColorMid
upperWidthPlot = showLines ? borderWidthFinal : 1
lowerWidthPlot = showLines ? borderWidthFinal : 1
midWidthPlot   = useEMA ? emaWidth : 1

// Estilo EMA
emaPlotStyle = emaStyle == "Stepline" ? plot.style_stepline : plot.style_line

// ---------- SERIES PARA FILLS ----------
// Series base (siempre válidas para alimentar fills)
pUpperBase = plot(upperBand, title="Upper Band (base)", color=upperColorPlot, linewidth=upperWidthPlot, style=plot.style_line, display=display.all)
pMidBase   = plot(emaLine,  title="EMA (base)",         color=midColorPlot,   linewidth=midWidthPlot,   style=emaPlotStyle,    display=display.all)
pLowerBase = plot(lowerBand, title="Lower Band (base)", color=lowerColorPlot, linewidth=lowerWidthPlot, style=plot.style_line, display=display.all)

// Series condicionadas para above / below (si la condición no se cumple, igualan a EMA para que el fill sea nulo)
priceAbove = close > emaLine
priceBelow = close < emaLine

upperAbove = priceAbove ? upperBand : emaLine
lowerAbove = priceAbove ? lowerBand : emaLine

upperBelow = priceBelow ? upperBand : emaLine
lowerBelow = priceBelow ? lowerBand : emaLine

// Plots auxiliares para fills condicionales (si no visibles, usar color transparente y linewidth=1)
pUpperAbove = plot(upperAbove, title="Upper Above", color=color.new(fillAboveColorBase, 255), linewidth=1, display=display.none)
pLowerAbove = plot(lowerAbove, title="Lower Above", color=color.new(fillAboveColorBase, 255), linewidth=1, display=display.none)
pUpperBelow = plot(upperBelow, title="Upper Below", color=color.new(fillBelowColorBase, 255), linewidth=1, display=display.none)
pLowerBelow = plot(lowerBelow, title="Lower Below", color=color.new(fillBelowColorBase, 255), linewidth=1, display=display.none)

// EMA visible (separada para trackprice y control de visibilidad)
pEMA = plot(useEMA ? emaLine : na, title="EMA (visible)", color=emaColor, linewidth=emaWidth, style=emaPlotStyle, display=display.all, trackprice=useEMA)

// ---------- FILLS (SIEMPRE EN SCOPE GLOBAL) ----------
fill(pUpperBase, pLowerBase, color=singleFillColor)
fill(pUpperAbove, pLowerAbove, color=aboveFillColor)
fill(pUpperBelow, pLowerBelow, color=belowFillColor)
````
