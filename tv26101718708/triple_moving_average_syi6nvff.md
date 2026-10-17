# Triple Moving Average

- url: https://www.tradingview.com/script/syi6NVfF/
- type: indicator
- pine_id: PUB;43e7c94cb2024e8d8a25519630a6a362
- version: 1.0

## Description

📐 Qué es
Este indicador dibuja 3 medias móviles independientes en un solo gráfico. Permite combinar diferentes tipos de medias y periodos para identificar la tendencia del mercado, buscar cruces de líneas o usarlas como soporte y resistencia dinámicos, ahorrando espacio en tus indicadores de TradingView.

⚙️ Cómo funciona
El script calcula y muestra cada una de las 3 medias móviles de forma simultánea según los parámetros elegidos por el usuario. Viene configurado por defecto con una combinación clásica de tres líneas: corta, media y larga distancia.

Configuración por defecto:
Media Móvil 1 (Rápida): EMA de 9 periodos (Color Azul). Ideal para ver la dirección del precio a muy corto plazo.

Media Móvil 2 (Media): EMA de 21 periodos (Color Rojo). Sirve de apoyo y confirmación de tendencia.

Media Móvil 3 (Lenta): SMA de 200 periodos (Color Verde). El estándar del mercado para definir la tendencia principal (alcista o bajista).

🔧 Funciones Clave
4 Tipos de Medias Disponibles: Elige de forma independiente para cada línea entre:

SMA: Media Móvil Simple.

EMA: Media Móvil Exponencial (prioriza el precio reciente).

WMA: Media Móvil Ponderada.

VWMA: Media Móvil Ponderada por Volumen.

Filtro de Visibilidad: Puedes activar o desactivar cualquiera de las 3 medias mediante un botón (Check) sin necesidad de borrar el código ni perder tu configuración.

Fuente Personalizable: Permite calcular las medias usando el cierre (close), la apertura (open), los máximos (high), mínimos (low) o combinaciones de estos.

## Source Code

````pine
//@version=6
indicator(title="Triple Moving Average", shorttitle="3xMA", overlay=true, timeframe="", timeframe_gaps=true)

// Inputs para 3 medias móviles
groupMA1 = "Media Móvil 1"
Tipo_MA1 = input.string("EMA", title="Tipo", options=["SMA", "EMA", "WMA", "VWMA"], group=groupMA1)
Periodo_MA1 = input.int(9, title="Período", group=groupMA1)
Fuente_MA1 = input.source(close, title="Fuente", group=groupMA1)
Mostrar_MA1 = input.bool(true, title="Mostrar", group=groupMA1)
Color_MA1 = input.color(color.blue, title="Color", group=groupMA1)

groupMA2 = "Media Móvil 2"
Tipo_MA2 = input.string("EMA", title="Tipo", options=["SMA", "EMA", "WMA", "VWMA"], group=groupMA2)
Periodo_MA2 = input.int(21, title="Período", group=groupMA2)
Fuente_MA2 = input.source(close, title="Fuente", group=groupMA2)
Mostrar_MA2 = input.bool(true, title="Mostrar", group=groupMA2)
Color_MA2 = input.color(color.red, title="Color", group=groupMA2)

groupMA3 = "Media Móvil 3"
Tipo_MA3 = input.string("SMA", title="Tipo", options=["SMA", "EMA", "WMA", "VWMA"], group=groupMA3)
Periodo_MA3 = input.int(200, title="Período", group=groupMA3)
Fuente_MA3 = input.source(close, title="Fuente", group=groupMA3)
Mostrar_MA3 = input.bool(true, title="Mostrar", group=groupMA3)
Color_MA3 = input.color(color.green, title="Color", group=groupMA3)

// Función para calcular la media móvil
f_ma(tipo, periodo, fuente) => tipo == "SMA" ? ta.sma(fuente, periodo) : tipo == "EMA" ? ta.ema(fuente, periodo) : tipo == "WMA" ? ta.wma(fuente, periodo) : tipo == "VWMA" ? ta.vwma(fuente, periodo) : na

// Cálculo de cada media móvil
ma1 = f_ma(Tipo_MA1, Periodo_MA1, Fuente_MA1)
ma2 = f_ma(Tipo_MA2, Periodo_MA2, Fuente_MA2)
ma3 = f_ma(Tipo_MA3, Periodo_MA3, Fuente_MA3)

// Dibujar medias móviles en el gráfico
plot(Mostrar_MA1 ? ma1 : na, title="Media Móvil 1", color=Color_MA1, linewidth=1)
plot(Mostrar_MA2 ? ma2 : na, title="Media Móvil 2", color=Color_MA2, linewidth=1)
plot(Mostrar_MA3 ? ma3 : na, title="Media Móvil 3", color=Color_MA3, linewidth=1)
````
