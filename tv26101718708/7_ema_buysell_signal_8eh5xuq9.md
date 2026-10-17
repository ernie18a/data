# 7 ema + Buy/Sell Signal

- url: https://www.tradingview.com/script/8Eh5xuq9/
- type: indicator
- pine_id: PUB;c3f08613ef2e4c1ca3e6ff65b8bb6c91
- version: 1.0

## Description

7 EMA + Buy/Sell Signal 

Ribbon de 7 medias móviles (3 - 9 - 20 - 50 - 100 - 200 - 800) con señales de alineación perfecta.

Características principales:

• 7 medias móviles configurables (EMA, SMA o WMA)
• Colores neutrales y profesionales (fáciles de distinguir)
• Grosor de líneas personalizable
• Fuente configurable (por defecto Close)
• Señales de compra y venta cuando las 7 medias se alinean perfectamente en la misma dirección (sin cruces)
• Señales muy discretas: triángulos pequeños o etiquetas "BUY"/"SELL"
• Totalmente personalizable (colores, grosores, tipo de media, etc.)

Ideal para:
- Operaciones en tendencia fuerte
- Scalping e intradía en Oro (XAUUSD), divisas, índices o criptos
- Estrategias de seguimiento de tendencia (Trend Following)

La señal de compra aparece solo cuando las 7 medias están ordenadas alcistamente (MA3 > MA9 > MA20 > ... > MA800).  
La señal de venta cuando están ordenadas bajistamente.

¡Simple, limpio y potente!

Cualquier duda o sugerencia, déjala en los comentarios.  
¡Éxito en tus operaciones! 

---

## Source Code

````pine
//@version=5
indicator("7 ema + Buy/Sell Signal", overlay = true, max_labels_count = 500)

// ── CONFIGURACIÓN GENERAL ──
src         = input.source(close, "Fuente (Source)", group = "Configuración General")
maTypeInput = input.string("EMA", "Tipo de Media Móvil", options = ["EMA", "SMA", "WMA"], group = "Configuración General")

// Longitudes
len1 = input.int(3,   "Longitud 1 (rápida)",  minval = 1, group = "Longitudes")
len2 = input.int(9,   "Longitud 2",           minval = 1, group = "Longitudes")
len3 = input.int(20,  "Longitud 3",           minval = 1, group = "Longitudes")
len4 = input.int(50,  "Longitud 4",           minval = 1, group = "Longitudes")
len5 = input.int(100, "Longitud 5",           minval = 1, group = "Longitudes")
len6 = input.int(200, "Longitud 6",           minval = 1, group = "Longitudes")
len7 = input.int(800, "Longitud 7 (lenta)",   minval = 1, group = "Longitudes")

// Colores
col1 = input.color(#00CED1, "Color MA 3",   group = "Colores")
col2 = input.color(#20B2AA, "Color MA 9",   group = "Colores")
col3 = input.color(#4682B4, "Color MA 20",  group = "Colores")
col4 = input.color(#5F9EA0, "Color MA 50",  group = "Colores")
col5 = input.color(#2E8B57, "Color MA 100", group = "Colores")
col6 = input.color(#191970, "Color MA 200", group = "Colores")
col7 = input.color(#4B0082, "Color MA 800", group = "Colores")

// Grosores
wid1 = input.int(3, "Grosor MA 3",   minval = 1, maxval = 10, group = "Grosores")
wid2 = input.int(2, "Grosor MA 9",   minval = 1, maxval = 10, group = "Grosores")
wid3 = input.int(2, "Grosor MA 20",  minval = 1, maxval = 10, group = "Grosores")
wid4 = input.int(2, "Grosor MA 50",  minval = 1, maxval = 10, group = "Grosores")
wid5 = input.int(2, "Grosor MA 100", minval = 1, maxval = 10, group = "Grosores")
wid6 = input.int(1, "Grosor MA 200", minval = 1, maxval = 10, group = "Grosores")
wid7 = input.int(1, "Grosor MA 800", minval = 1, maxval = 10, group = "Grosores")

// ── FUNCIÓN PARA CAMBIAR TIPO DE MEDIA ──
ma(src, length) =>
    if maTypeInput == "SMA"
        ta.sma(src, length)
    else if maTypeInput == "WMA"
        ta.wma(src, length)
    else
        ta.ema(src, length)

// ── CÁLCULO DE LAS 7 MEDIAS ──
ma1 = ma(src, len1)
ma2 = ma(src, len2)
ma3 = ma(src, len3)
ma4 = ma(src, len4)
ma5 = ma(src, len5)
ma6 = ma(src, len6)
ma7 = ma(src, len7)

// ── PLOT DE LAS MEDIAS ──
plot(ma1, title="MA 3",   color=col1, linewidth=wid1)
plot(ma2, title="MA 9",   color=col2, linewidth=wid2)
plot(ma3, title="MA 20",  color=col3, linewidth=wid3)
plot(ma4, title="MA 50",  color=col4, linewidth=wid4)
plot(ma5, title="MA 100", color=col5, linewidth=wid5)
plot(ma6, title="MA 200", color=col6, linewidth=wid6)
plot(ma7, title="MA 800", color=col7, linewidth=wid7)

// ── SEÑALES DE ALINEACIÓN ──
bullAligned = ma1 > ma2 and ma2 > ma3 and ma3 > ma4 and ma4 > ma5 and ma5 > ma6 and ma6 > ma7
bearAligned = ma1 < ma2 and ma2 < ma3 and ma3 < ma4 and ma4 < ma5 and ma5 < ma6 and ma6 < ma7

buySignal  = bullAligned and not bullAligned[1]
sellSignal = bearAligned and not bearAligned[1]

// ── CONFIGURACIÓN DE SEÑALES ──
showSignals = input.bool(true,  "Mostrar Señales de Alineación", group = "Señales")
signalType  = input.string("Triángulo", "Tipo de Señal", options = ["Triángulo", "Etiqueta"], group = "Señales")
buyCol      = input.color(#00FF7F, "Color Señal COMPRA", group = "Señales")
sellCol     = input.color(#000000, "Color Señal VENTA", group = "Señales")

// ── DIBUJAR SEÑALES ──
plotshape(showSignals and buySignal,  title="Buy",  location=location.belowbar, style=shape.triangleup,   color=buyCol,  size=size.tiny)
plotshape(showSignals and sellSignal, title="Sell", location=location.abovebar, style=shape.triangledown, color=sellCol, size=size.tiny)

// Etiquetas (solo si eliges "Etiqueta")
if showSignals and signalType == "Etiqueta"
    if buySignal
        label.new(bar_index, low - ta.tr, "BUY", style=label.style_label_up, color=buyCol, textcolor=color.white, size=size.tiny)
    if sellSignal
        label.new(bar_index, high + ta.tr, "SELL", style=label.style_label_down, color=sellCol, textcolor=color.white, size=size.tiny)
````
