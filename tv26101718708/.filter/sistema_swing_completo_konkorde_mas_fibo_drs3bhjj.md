# Sistema Swing Completo (Konkorde + MAs + Fibo)

- url: https://www.tradingview.com/script/DRS3bhJj/
- type: indicator
- pine_id: PUB;3740dc912bdd4778a82667f959b4b261
- version: 3.0

## Description

// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Sistema Swing Completo (Konkorde + MAs + Fibo)", overlay=false)

// =====================================================================
// 1. KONCORDE (VOLUMEN DE BALLENAS VS MINORISTAS)
// =====================================================================
// Cálculo de PVI (Minoristas) y NVI (Ballenas)
var float pvi = 1000.0
var float nvi = 1000.0

if bar_index > 0
    pvi := volume > volume[1] ? pvi[1] + ((close - close[1]) / close[1]) * pvi[1] : pvi[1]
    nvi := volume < volume[1] ? nvi[1] + ((close - close[1]) / close[1]) * nvi[1] : nvi[1]

// Oscilación de Minoristas (Manos Débiles)
pvim = ta.ema(pvi, 15)
pvimax = ta.highest(pvim, 90)
pvimin = ta.lowest(pvim, 90)
minoristas = (pvi - pvim) * 100 / math.max(pvimax - pvimin, 1)

// Oscilación de Ballenas (Manos Fuertes)
nvim = ta.ema(nvi, 15)
nvimax = ta.highest(nvim, 90)
nvimin = ta.lowest(nvim, 90)
ballenas = (nvi - nvim) * 100 / math.max(nvimax - nvimin, 1)

plot(minoristas, color=color.new(color.green, 40), style=plot.style_area, title="Volumen Minorista (Verde)")
plot(ballenas, color=color.new(color.blue, 20), style=plot.style_area, title="Volumen Ballenas (Azul)")

// =====================================================================
// 2. INDICADOR DE MOMENTUM (MACD)
// =====================================================================
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
escala_momentum = 5 // Multiplicador para igualar la escala del Konkorde visualmente

color_hist = hist > hist[1] ? color.new(color.orange, 0) : color.new(color.red, 0)
plot(hist * escala_momentum, color=color_hist, style=plot.style_columns, title="Momentum (Columnas)")

hline(0, color=color.gray, linestyle=hline.style_dashed)

// =====================================================================
// 3. MEDIAS MÓVILES CONFIGURABLES (Proyectadas al gráfico superior)
// =====================================================================
len1 = input.int(9, title="Longitud EMA 1")
len2 = input.int(21, title="Longitud EMA 2")
len3 = input.int(50, title="Longitud EMA 3")

ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)

// El uso de force_overlay=true envía estas líneas a las velas japonesas
plot(ema1, color=color.new(color.yellow, 0), linewidth=2, title="EMA Rápida", force_overlay=true)
plot(ema2, color=color.new(color.white, 0), linewidth=2, title="EMA Media", force_overlay=true)
plot(ema3, color=color.new(color.purple, 0), linewidth=2, title="EMA Lenta", force_overlay=true)

// =====================================================================
// 4. RETROCESO DE FIBONACCI (Proyectado al gráfico superior)
// =====================================================================
fibo_lookback = input.int(100, title="Periodo para Fibonacci")

hh = ta.highest(high, fibo_lookback)
ll = ta.lowest(low, fibo_lookback)
diff = hh - ll

plot(hh, color=color.new(color.red, 50), title="100% (Máximo)", force_overlay=true)
plot(hh - diff * 0.236, color=color.new(color.gray, 60), title="76.4%", force_overlay=true)
plot(hh - diff * 0.382, color=color.new(color.gray, 60), title="61.8%", force_overlay=true)
plot(hh - diff * 0.500, color=color.new(color.aqua, 20), linewidth=2, title="50.0% (Equilibrio)", force_overlay=true)
plot(hh - diff * 0.618, color=color.new(color.gray, 60), title="38.2%", force_overlay=true)
plot(ll, color=color.new(color.green, 50), title="0% (Mínimo)", force_overlay=true)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Sistema Swing Completo (Konkorde + MAs + Fibo)", overlay=false)

// =====================================================================
// FUNCIONES AUXILIARES (deben ir en el ámbito global, no dentro de if)
// =====================================================================
check(bool c) => c ? "✓" : "✗"
colcheck(bool c) => c ? color.new(color.green, 0) : color.new(color.red, 0)

// =====================================================================
// 1. KONCORDE (VOLUMEN DE BALLENAS VS MINORISTAS)
// =====================================================================
var float pvi = 1000.0
var float nvi = 1000.0

if bar_index > 0
    pvi := volume > volume[1] ? pvi[1] + ((close - close[1]) / close[1]) * pvi[1] : pvi[1]
    nvi := volume < volume[1] ? nvi[1] + ((close - close[1]) / close[1]) * nvi[1] : nvi[1]

// Oscilación de Minoristas (Manos Débiles)
pvim = ta.ema(pvi, 15)
pvimax = ta.highest(pvim, 90)
pvimin = ta.lowest(pvim, 90)
minoristas = (pvi - pvim) * 100 / math.max(pvimax - pvimin, 1)

// Oscilación de Ballenas (Manos Fuertes)
nvim = ta.ema(nvi, 15)
nvimax = ta.highest(nvim, 90)
nvimin = ta.lowest(nvim, 90)
ballenas = (nvi - nvim) * 100 / math.max(nvimax - nvimin, 1)

plot(minoristas, color=color.new(color.green, 40), style=plot.style_area, title="Volumen Minorista (Verde)")
plot(ballenas, color=color.new(color.blue, 20), style=plot.style_area, title="Volumen Ballenas (Azul)")

// =====================================================================
// 2. INDICADOR DE MOMENTUM (MACD)
// =====================================================================
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
escala_momentum = 5

color_hist = hist > hist[1] ? color.new(color.orange, 0) : color.new(color.red, 0)
plot(hist * escala_momentum, color=color_hist, style=plot.style_columns, title="Momentum (Columnas)")

hline(0, color=color.gray, linestyle=hline.style_dashed)

// =====================================================================
// 3. MEDIAS MÓVILES CONFIGURABLES
// =====================================================================
len1 = input.int(9, title="Longitud EMA 1")
len2 = input.int(21, title="Longitud EMA 2")
len3 = input.int(50, title="Longitud EMA 3")

ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)

plot(ema1, color=color.new(color.yellow, 0), linewidth=2, title="EMA Rápida", force_overlay=true)
plot(ema2, color=color.new(color.white, 0), linewidth=2, title="EMA Media", force_overlay=true)
plot(ema3, color=color.new(color.purple, 0), linewidth=2, title="EMA Lenta", force_overlay=true)

// =====================================================================
// 4. RETROCESO DE FIBONACCI
// =====================================================================
fibo_lookback = input.int(100, title="Periodo para Fibonacci")

hh = ta.highest(high, fibo_lookback)
ll = ta.lowest(low, fibo_lookback)
diff = hh - ll

fib_236 = hh - diff * 0.236
fib_382 = hh - diff * 0.382
fib_500 = hh - diff * 0.500
fib_618 = hh - diff * 0.618

plot(hh, color=color.new(color.red, 50), title="0% (Máximo)", force_overlay=true)
plot(fib_236, color=color.new(color.gray, 60), title="23.6%", force_overlay=true)
plot(fib_382, color=color.new(color.gray, 60), title="38.2%", force_overlay=true)
plot(fib_500, color=color.new(color.aqua, 20), linewidth=2, title="50.0% (Equilibrio)", force_overlay=true)
plot(fib_618, color=color.new(color.gray, 60), title="61.8%", force_overlay=true)
plot(ll, color=color.new(color.green, 50), title="100% (Mínimo)", force_overlay=true)

// =====================================================================
// 5. SISTEMA DE CONFLUENCIA — SEÑAL DE COMPRA (3 de 4)
// =====================================================================
umbral = input.int(3, title="Condiciones mínimas para COMPRA", minval=1, maxval=4, group="Señal de Compra", tooltip="Cuántas de las 4 capas deben cumplirse para generar la señal (3 = tu configuración)")

// CONDICIÓN 1: Tendencia (medias apiladas en orden alcista)
cond_tendencia = ema1 > ema2 and ema2 > ema3

// CONDICIÓN 2: Ballenas acumulando
cond_ballenas = ballenas > minoristas or (ballenas > ballenas[1] and ballenas > 0)

// CONDICIÓN 3: Precio en zona Fibonacci de valor (entre 0.382 y 0.618)
// El nivel 0.618 es un precio MÁS BAJO que el 0.382, por eso close entre ambos
cond_fibo = close <= fib_382 and close >= fib_618

// CONDICIÓN 4: Momentum girando a favor (histograma creciendo)
cond_momentum = hist > hist[1]

// Contar cuántas condiciones se cumplen
score = (cond_tendencia ? 1 : 0) + (cond_ballenas ? 1 : 0) + (cond_fibo ? 1 : 0) + (cond_momentum ? 1 : 0)

// Señal de compra: se cumple el umbral y no veníamos ya en señal
senial_compra = score >= umbral and not (score[1] >= umbral)

plotshape(senial_compra, title="COMPRA", style=shape.labelup, location=location.bottom, color=color.new(color.green, 0), textcolor=color.white, text="COMPRA", size=size.normal, force_overlay=true)

bgcolor(score >= umbral ? color.new(color.green, 90) : na, title="Zona de confluencia")

// =====================================================================
// 5B. SISTEMA DE CONFLUENCIA — SEÑAL DE VENTA (3 de 4 señales de agotamiento)
// =====================================================================
umbral_venta = input.int(3, title="Señales de agotamiento para VENTA", minval=1, maxval=4, group="Señal de Venta", tooltip="Cuántas señales de agotamiento deben cumplirse para generar la venta (3 = recomendado)")

// SEÑAL 1: Quiebre de tendencia (EMA rápida cruza debajo de la media)
salida_tendencia = ema1 < ema2

// SEÑAL 2: Ballenas distribuyendo (manos fuertes bajan y minoristas suben = smart money vendiendo al retail)
salida_ballenas = ballenas < minoristas or (ballenas < ballenas[1] and minoristas > minoristas[1])

// SEÑAL 3: Precio en zona alta del Fibonacci (objetivo cumplido, cerca del máximo)
salida_fibo = close >= fib_236

// SEÑAL 4: Momentum contrayéndose (histograma achicándose)
salida_momentum = hist < hist[1]

// Contar señales de agotamiento
score_venta = (salida_tendencia ? 1 : 0) + (salida_ballenas ? 1 : 0) + (salida_fibo ? 1 : 0) + (salida_momentum ? 1 : 0)

// Señal de venta: se cumple el umbral y no veníamos ya en señal
senial_venta = score_venta >= umbral_venta and not (score_venta[1] >= umbral_venta)

plotshape(senial_venta, title="VENTA", style=shape.labeldown, location=location.top, color=color.new(color.red, 0), textcolor=color.white, text="VENTA", size=size.normal, force_overlay=true)

bgcolor(score_venta >= umbral_venta ? color.new(color.red, 90) : na, title="Zona de venta")

// Salida defensiva rápida: pierde la EMA 21 en cierre (stop estructural)
perdida_ema21 = ta.crossunder(close, ema2)
plotshape(perdida_ema21, title="STOP (pierde EMA21)", style=shape.xcross, location=location.abovebar, color=color.new(color.orange, 0), size=size.tiny, force_overlay=true)

// =====================================================================
// 6. TABLA DE ESTADO DE LAS 4 CONDICIONES
// =====================================================================
mostrar_tabla = input.bool(true, title="Mostrar tabla de condiciones", group="Señal de Compra")

var table tabla = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if mostrar_tabla and barstate.islast
    table.cell(tabla, 0, 0, "CONFLUENCIA " + str.tostring(score) + "/4", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=size.normal)
    table.merge_cells(tabla, 0, 0, 1, 0)

    table.cell(tabla, 0, 1, "1. Tendencia (MAs)", text_color=color.gray, text_size=size.small)
    table.cell(tabla, 1, 1, check(cond_tendencia), text_color=colcheck(cond_tendencia), text_size=size.small)

    table.cell(tabla, 0, 2, "2. Ballenas acum.", text_color=color.gray, text_size=size.small)
    table.cell(tabla, 1, 2, check(cond_ballenas), text_color=colcheck(cond_ballenas), text_size=size.small)

    table.cell(tabla, 0, 3, "3. Zona Fibonacci", text_color=color.gray, text_size=size.small)
    table.cell(tabla, 1, 3, check(cond_fibo), text_color=colcheck(cond_fibo), text_size=size.small)

    table.cell(tabla, 0, 4, "4. Momentum", text_color=color.gray, text_size=size.small)
    table.cell(tabla, 1, 4, check(cond_momentum), text_color=colcheck(cond_momentum), text_size=size.small)

    estado = score >= umbral ? "COMPRA" : score_venta >= umbral_venta ? "VENTA" : "ESPERAR"
    estado_col = score >= umbral ? color.new(color.green, 0) : score_venta >= umbral_venta ? color.new(color.red, 0) : color.new(color.gray, 0)
    table.cell(tabla, 0, 5, "Estado", text_color=color.gray, text_size=size.small)
    table.cell(tabla, 1, 5, estado, text_color=estado_col, text_size=size.small)

// =====================================================================
// 7. ALERTAS
// =====================================================================
alertcondition(senial_compra, title="Señal de COMPRA (3 de 4)", message="Señal de COMPRA — Confluencia alcanzada")
alertcondition(senial_venta, title="Señal de VENTA (3 de 4)", message="Señal de VENTA — Agotamiento detectado")
alertcondition(perdida_ema21, title="STOP - pierde EMA21", message="STOP — El precio perdio la EMA 21 en cierre")
````
