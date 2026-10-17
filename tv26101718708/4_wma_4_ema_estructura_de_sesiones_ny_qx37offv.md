# 4 WMA + 4 EMA + Estructura de Sesiones NY

- url: https://www.tradingview.com/script/Qx37oFFV/
- type: indicator
- pine_id: PUB;2e747e53b0994641bb804073b9dde5a9
- version: 1.0

## Description

Script para mostrar y marcar el premarket y postmarker, junto con las medias moviles simples y ponderadas

## Source Code

````pine
//@version=6
indicator(title="4 WMA + 4 EMA + Estructura de Sesiones NY", shorttitle="Multi-MA + Sesiones NY", overlay=true, timeframe="", timeframe_gaps=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUENTE Y CONFIGURACIONES GENERALES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src = input.source(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none)
tz = "America/New_York"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS DE MEDIAS MÓVILES (WMA & EMA)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wmaLen1 = input.int(9, minval=1, title="WMA 1 Length", group="WMA Settings")
wmaLen2 = input.int(20, minval=1, title="WMA 2 Length", group="WMA Settings")
wmaLen3 = input.int(40, minval=1, title="WMA 3 Length", group="WMA Settings")
wmaLen4 = input.int(200, minval=1, title="WMA 4 Length", group="WMA Settings")

emaLen1 = input.int(9, minval=1, title="EMA 1 Length", group="EMA Settings")
emaLen2 = input.int(20, minval=1, title="EMA 2 Length", group="EMA Settings")
emaLen3 = input.int(40, minval=1, title="EMA 3 Length", group="EMA Settings")
emaLen4 = input.int(200, minval=1, title="EMA 4 Length", group="EMA Settings")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS DE SESIONES Y COLORES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
preMarket   = input.session("2400-0930:23456", "Pre Market Hours", group="Session Settings")
market      = input.session("0930-1600:23456", "Regular Market Hours", group="Session Settings")
postMarket  = input.session("1600-2400:23456", "Post Market Hours", group="Session Settings")

preColor          = input.color(color.new(color.blue, 90), "Pre Market Color", group="Session Colors")
marketColor       = input.color(color.new(color.white, 100), "Market Hours Color (Inicio/Fin)", group="Session Colors")
medioAmarilloColor = input.color(color.new(color.yellow, 85), "Periodo Medio Lateral (11:40-13:50)", group="Session Colors")
postColor         = input.color(color.new(#ff0000, 90), "Post Market Color", group="Session Colors")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CÁLCULOS DE TIEMPO Y SESIONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isPre    = not na(time(timeframe.period, preMarket, tz))
isMarket = not na(time(timeframe.period, market, tz))
isPost   = not na(time(timeframe.period, postMarket, tz))

// Filtro específico para los 130 minutos intermedios (Lunch Time de NY)
en_periodo_medio = not na(time(timeframe.period, "1140-1350:23456", tz))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONTROL DEL COLOR DE FONDO (PINTADO)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fcolor = en_periodo_medio ? medioAmarilloColor : isPre ? preColor : isMarket ? marketColor : isPost ? postColor : na
bgcolor(fcolor, title="Fondo Dinámico de Sesión")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CÁLCULOS DE MEDIAS MÓVILES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wma1 = ta.wma(src, wmaLen1)
wma2 = ta.wma(src, wmaLen2)
wma3 = ta.wma(src, wmaLen3)
wma4 = ta.wma(src, wmaLen4)

ema1 = ta.ema(src, emaLen1)
ema2 = ta.ema(src, emaLen2)
ema3 = ta.ema(src, emaLen3)
ema4 = ta.ema(src, emaLen4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS DE MEDIAS MÓVILES (Visibilidad configurada por defecto)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WMA
plot(wma1, title="WMA 1", color=color.blue, offset=offset, linewidth=2, display=display.none) // Oculta por defecto
plot(wma2, title="WMA 2", color=color.orange, offset=offset, linewidth=2)                     // ACTIVADA por defecto
plot(wma3, title="WMA 3", color=color.green, offset=offset, linewidth=2, display=display.none) // Oculta por defecto
plot(wma4, title="WMA 4", color=color.purple, offset=offset, linewidth=2)                    // ACTIVADA por defecto

// EMA
plot(ema1, title="EMA 1", color=color.aqua, offset=offset, linewidth=2)                      // ACTIVADA por defecto
plot(ema2, title="EMA 2", color=color.red, offset=offset, linewidth=2, display=display.none)  // Oculta por defecto
plot(ema3, title="EMA 3", color=color.lime, offset=offset, linewidth=2, display=display.none) // Oculta por defecto
plot(ema4, title="EMA 4", color=color.fuchsia, offset=offset, linewidth=2, display=display.none) // Oculta por defecto
````
