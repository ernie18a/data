# Tendencia Diaria - EMA 20 / 50 / 200

- url: https://www.tradingview.com/script/JY9jfaCf/
- type: indicator
- pine_id: PUB;6d7d519b154941feabf00c2cf7eba61a
- version: 1.0

## Description

Armé un indicador simple para TradingView pensado para leer la tendencia diaria de una forma visual, sin llenar el gráfico de señales invasivas.

La base usa tres medias móviles:

• EMA 20: muestra el movimiento de corto plazo y sirve para detectar recuperación o pérdida de impulso.
• EMA 50: ayuda a identificar la tendencia de mediano plazo.
• EMA 200: funciona como referencia de tendencia estructural o de fondo.

Además de dibujar las medias, el indicador muestra una tabla con el precio actual, el valor de cada EMA y la distancia porcentual del precio respecto de ellas.

La tabla clasifica el contexto en distintos estados:

🟢 Alcista fuerte
El precio está por encima de EMA 20, EMA 50 y EMA 200. Además, las medias están ordenadas de menor a mayor plazo y la EMA 200 acompaña subiendo. Es el escenario más favorable para buscar compras.

🟢 Alcista
El precio se mantiene por encima de EMA 50 y la EMA 50 está arriba de EMA 200. La tendencia general sigue siendo positiva, aunque el corto plazo puede estar corrigiendo.

🟠 Corrección alcista
El activo pierde la EMA 20, pero sigue con una estructura de fondo positiva: continúa arriba de EMA 200 y la EMA 50 sigue por encima de la EMA 200. Puede ser una corrección dentro de una tendencia alcista.

🟠 Debilitamiento
El precio está debajo de EMA 20, EMA 50 y EMA 200, pero la EMA 50 todavía permanece arriba de EMA 200. No es una tendencia bajista de fondo plenamente confirmada, pero sí una señal clara de deterioro.

🔴 Bajista
El precio está debajo de EMA 50 y la EMA 50 ya está por debajo de EMA 200. El contexto general es negativo.

🔴 Bajista fuerte
El precio está debajo de las tres medias, ordenadas de forma bajista, y la EMA 200 no muestra pendiente positiva. Es el escenario más débil.

🟠 Rebote bajista
El precio recupera la EMA 20, pero sigue debajo de EMA 200 y la EMA 50 continúa debajo de la EMA 200. Puede haber rebote, pero la estructura principal sigue siendo bajista.

⚪ Neutral
Las medias están mezcladas o el precio está entre ellas. No hay una tendencia clara y conviene evitar decisiones apuradas.

La señal bull del indicador aparece cuando el precio recupera la EMA 20 dentro de una estructura positiva: el precio debe estar por encima de EMA 50 y la EMA 50 debe estar por encima de EMA 200. La idea no es comprar cualquier cruce, sino buscar una recuperación de impulso dentro de una tendencia que ya acompaña.

Las señales se muestran con triángulos discretos para no ensuciar el gráfico.

Importante: esto no busca predecir el mercado ni reemplaza análisis de volumen, soportes, resistencias, contexto macro o gestión de riesgo. Es una herramienta visual para ordenar la lectura de tendencia.

## Source Code

````pine
//@version=6
indicator("Tendencia Diaria - EMA 20 / 50 / 200", shorttitle="Trend 20-50-200", overlay=true)

// ─────────────────────────────────────────────
// CONFIGURACIÓN
// ─────────────────────────────────────────────
grupoMedias = "Medias móviles"

mostrarEMA20  = input.bool(true, "Mostrar EMA 20", group=grupoMedias)
mostrarEMA50  = input.bool(true, "Mostrar EMA 50", group=grupoMedias)
mostrarEMA200 = input.bool(true, "Mostrar EMA 200", group=grupoMedias)

colorEMA20  = input.color(color.lime, "Color EMA 20", group=grupoMedias)
colorEMA50  = input.color(color.orange, "Color EMA 50", group=grupoMedias)
colorEMA200 = input.color(color.blue, "Color EMA 200", group=grupoMedias)

grosor = input.int(2, "Grosor de líneas", minval=1, maxval=5, group=grupoMedias)

grupoVisual = "Visual"

mostrarEtiquetas = input.bool(true, "Mostrar etiquetas en última vela", group=grupoVisual)
offsetEtiquetas  = input.int(4, "Separación etiquetas hacia la derecha", minval=0, maxval=20, group=grupoVisual)

mostrarFondo   = input.bool(true, "Colorear fondo según tendencia", group=grupoVisual)
mostrarSenales = input.bool(true, "Mostrar señales de entrada/salida", group=grupoVisual)
mostrarTabla    = input.bool(true, "Mostrar tabla de distancias", group=grupoVisual)

// ─────────────────────────────────────────────
// CÁLCULOS
// ─────────────────────────────────────────────
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

pendienteEMA200 = ema200 > ema200[10]

// ─────────────────────────────────────────────
// ESTADOS DE TENDENCIA
// ─────────────────────────────────────────────

// Precio arriba de todas las medias y estructura ordenada
alcistaFuerte = close > ema20 and ema20 > ema50 and ema50 > ema200 and pendienteEMA200

// Precio arriba de EMA 50 y EMA 50 arriba de EMA 200
alcista = close > ema50 and ema50 > ema200

// Baja de corto plazo, pero estructura de fondo todavía sana
correccionAlcista = close < ema20 and close > ema200 and ema50 > ema200

// Precio debajo de EMA 20, EMA 50 y EMA 200,
// pero EMA 50 todavía está arriba de EMA 200.
// Es el caso actual de Microsoft en tu ejemplo.
debilitamiento = close < ema20 and close < ema50 and close < ema200 and ema50 > ema200

// Estructura completamente bajista
bajistaFuerte = close < ema20 and ema20 < ema50 and ema50 < ema200 and not pendienteEMA200

// Precio debajo de EMA 50 y EMA 50 debajo de EMA 200
bajista = close < ema50 and ema50 < ema200

// Rebote corto dentro de una estructura todavía bajista
reboteBajista = close > ema20 and close < ema200 and ema50 < ema200

estadoTendencia = alcistaFuerte ? "ALCISTA FUERTE" :
                  alcista ? "ALCISTA" :
                  correccionAlcista ? "CORRECCIÓN ALCISTA" :
                  debilitamiento ? "DEBILITAMIENTO" :
                  bajistaFuerte ? "BAJISTA FUERTE" :
                  bajista ? "BAJISTA" :
                  reboteBajista ? "REBOTE BAJISTA" :
                  "NEUTRAL"

colorTendencia = alcistaFuerte ? color.lime :
                 alcista ? color.green :
                 correccionAlcista ? color.orange :
                 debilitamiento ? color.orange :
                 bajistaFuerte ? color.red :
                 bajista ? color.maroon :
                 reboteBajista ? color.orange :
                 color.gray

// ─────────────────────────────────────────────
// SEÑALES OPERATIVAS
// ─────────────────────────────────────────────

// Compra: recuperación de EMA 20 dentro de estructura positiva
compra = ta.crossover(close, ema20) and close > ema50 and ema50 > ema200

// Venta: pérdida de EMA 20 dentro de estructura bajista
venta = ta.crossunder(close, ema20) and close < ema50 and ema50 < ema200

// ─────────────────────────────────────────────
// DISTANCIAS PORCENTUALES
// ─────────────────────────────────────────────
distEMA20  = ((close - ema20) / ema20) * 100
distEMA50  = ((close - ema50) / ema50) * 100
distEMA200 = ((close - ema200) / ema200) * 100

// ─────────────────────────────────────────────
// FUNCIONES
// ─────────────────────────────────────────────
f_colorDistancia(_distancia) =>
    _distancia > 0 ? color.lime : _distancia < 0 ? color.red : color.gray

f_textoDistancia(_distancia) =>
    (_distancia >= 0 ? "+" : "") + str.tostring(_distancia, "#.##") + "%"

// ─────────────────────────────────────────────
// MEDIAS MÓVILES
// ─────────────────────────────────────────────
plot(mostrarEMA20 ? ema20 : na, title="EMA 20", color=colorEMA20, linewidth=grosor)
plot(mostrarEMA50 ? ema50 : na, title="EMA 50", color=colorEMA50, linewidth=grosor)
plot(mostrarEMA200 ? ema200 : na, title="EMA 200", color=colorEMA200, linewidth=grosor)

// ─────────────────────────────────────────────
// FONDO SEGÚN TENDENCIA
// ─────────────────────────────────────────────
bgcolor(
     mostrarFondo ?
     alcistaFuerte ? color.new(color.green, 88) :
     alcista ? color.new(color.green, 94) :
     correccionAlcista ? color.new(color.orange, 94) :
     debilitamiento ? color.new(color.orange, 88) :
     bajistaFuerte ? color.new(color.red, 88) :
     bajista ? color.new(color.red, 94) :
     reboteBajista ? color.new(color.orange, 94) :
     na
     : na
)

// ─────────────────────────────────────────────
// SEÑALES DISCRETAS
// ─────────────────────────────────────────────
plotshape(
     mostrarSenales and compra,
     title="Compra",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny
)

plotshape(
     mostrarSenales and venta,
     title="Venta",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny
)

// ─────────────────────────────────────────────
// ETIQUETAS EN ÚLTIMA VELA
// ─────────────────────────────────────────────
var label lblEMA20 = na
var label lblEMA50 = na
var label lblEMA200 = na

if barstate.islast
    label.delete(lblEMA20)
    label.delete(lblEMA50)
    label.delete(lblEMA200)

    if mostrarEtiquetas
        if mostrarEMA20
            lblEMA20 := label.new(
                 bar_index + offsetEtiquetas,
                 ema20,
                 "EMA 20\n" + str.tostring(ema20, format.mintick),
                 style=label.style_label_left,
                 color=colorEMA20,
                 textcolor=color.black,
                 size=size.small
            )

        if mostrarEMA50
            lblEMA50 := label.new(
                 bar_index + offsetEtiquetas,
                 ema50,
                 "EMA 50\n" + str.tostring(ema50, format.mintick),
                 style=label.style_label_left,
                 color=colorEMA50,
                 textcolor=color.black,
                 size=size.small
            )

        if mostrarEMA200
            lblEMA200 := label.new(
                 bar_index + offsetEtiquetas,
                 ema200,
                 "EMA 200\n" + str.tostring(ema200, format.mintick),
                 style=label.style_label_left,
                 color=colorEMA200,
                 textcolor=color.white,
                 size=size.small
            )

// ─────────────────────────────────────────────
// TABLA DE DISTANCIAS - ARRIBA DERECHA
// ─────────────────────────────────────────────
var table tablaMedias = table.new(position.top_right, 3, 5, border_width=1)

if barstate.islast
    if mostrarTabla
        table.cell(
             tablaMedias, 0, 0, "Precio",
             bgcolor=color.rgb(35, 35, 35),
             text_color=color.white
        )

        table.cell(
             tablaMedias, 1, 0, str.tostring(close, format.mintick),
             bgcolor=color.rgb(35, 35, 35),
             text_color=color.white
        )

        table.cell(
             tablaMedias, 2, 0, estadoTendencia,
             bgcolor=color.rgb(35, 35, 35),
             text_color=colorTendencia
        )

        table.cell(
             tablaMedias, 0, 1, "Media",
             bgcolor=color.rgb(55, 55, 55),
             text_color=color.white
        )

        table.cell(
             tablaMedias, 1, 1, "Valor",
             bgcolor=color.rgb(55, 55, 55),
             text_color=color.white
        )

        table.cell(
             tablaMedias, 2, 1, "Distancia",
             bgcolor=color.rgb(55, 55, 55),
             text_color=color.white
        )

        table.cell(tablaMedias, 0, 2, "EMA 20", text_color=colorEMA20)
        table.cell(tablaMedias, 1, 2, str.tostring(ema20, format.mintick))
        table.cell(
             tablaMedias, 2, 2,
             f_textoDistancia(distEMA20),
             text_color=f_colorDistancia(distEMA20)
        )

        table.cell(tablaMedias, 0, 3, "EMA 50", text_color=colorEMA50)
        table.cell(tablaMedias, 1, 3, str.tostring(ema50, format.mintick))
        table.cell(
             tablaMedias, 2, 3,
             f_textoDistancia(distEMA50),
             text_color=f_colorDistancia(distEMA50)
        )

        table.cell(tablaMedias, 0, 4, "EMA 200", text_color=colorEMA200)
        table.cell(tablaMedias, 1, 4, str.tostring(ema200, format.mintick))
        table.cell(
             tablaMedias, 2, 4,
             f_textoDistancia(distEMA200),
             text_color=f_colorDistancia(distEMA200)
        )
    else
        table.clear(tablaMedias, 0, 0, 2, 4)

// ─────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────
alertcondition(
     compra,
     title="Compra - Tendencia alcista",
     message="Compra en {{ticker}}: el precio cruzó EMA 20 al alza, con EMA 50 por encima de EMA 200. Precio: {{close}}"
)

alertcondition(
     venta,
     title="Venta - Tendencia bajista",
     message="Venta en {{ticker}}: el precio cruzó EMA 20 a la baja, con EMA 50 por debajo de EMA 200. Precio: {{close}}"
)
````
