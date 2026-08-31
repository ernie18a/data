<!-- tradingview-pine-id: PUB;c1a259659e1c4fa8a55371d78c5ed148 -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku + ADX + EMA - Visual Intuitive (Fixed)

Source: https://www.tradingview.com/script/EondL96g/

## Description

***Ichimoku + ADX + EMA — Confluencia Visual de Tendencia***
- Herramienta de confirmación de tendencia que combina tres indicadores clásicos en una sola lectura visual, pensada para identificar de un vistazo cuándo el mercado está en tendencia fuerte y en qué dirección.
Cómo funciona:
- Nube de Ichimoku (Tenkan/Kijun/Senkou A-B/Chikou, calculada de forma manual y estable) muestra la estructura de tendencia de mediano plazo. La nube cambia a gris automáticamente cuando el ADX indica que la tendencia es débil — así evitas operar señales de Ichimoku en mercados sin dirección clara.
- ADX mide la fuerza de la tendencia (no la dirección) — coloreado en verde/amarillo/rojo según qué tan fuerte es el movimiento actual, con línea de referencia en el umbral que configures.
- EMA 50 da la dirección de fondo — cambia de azul a naranja según el precio esté por encima o por debajo.
- Señal de confluencia: el fondo del gráfico se pinta de verde o rojo tenue solo cuando las tres condiciones coinciden a la vez (precio sobre/bajo la nube + precio sobre/bajo la EMA + ADX por encima de tu umbral) — y aparece un triángulo justo en el momento en que esa confluencia se activa, no en cada vela que la cumple, para evitar saturar el gráfico.
- Totalmente personalizable: todos los períodos de Ichimoku, la longitud y umbral del ADX, y la longitud de la EMA son ajustables desde el panel de configuración.
    ***Guía rápida para principiantes — cómo leer este indicador:***
*No necesitas entender la matemática detrás de Ichimoku o el ADX para usarlo. Fíjate solo en estas tres cosas:
- ¿De qué color es el fondo del gráfico?
Verde tenue = las tres herramientas apuntan hacia arriba al mismo tiempo (posible tendencia alcista fuerte).
Rojo tenue = las tres apuntan hacia abajo (posible tendencia bajista fuerte).
Sin color = no hay acuerdo entre las tres — mejor esperar, el mercado no está dando una señal clara.
- ¿Apareció un triángulo?
Un triángulo verde hacia arriba marca el momento exacto en que empezó una posible tendencia alcista.
Un triángulo rojo hacia abajo marca el inicio de una posible tendencia bajista.
Los triángulos solo aparecen una vez al inicio de cada señal, no se repiten mientras dura — así no se llena el gráfico de marcas.
- ¿La nube está gris o de color?
Si la nube está gris, el ADX te está avisando que la tendencia es débil en este momento — ten más cuidado, aunque el resto se vea alineado.
Si la nube está verde o roja, hay más fuerza detrás del movimiento.
Consejo para empezar: no uses este indicador solo — combínalo con tu propio análisis y gestión de riesgo (nunca arriesgues más de lo que estás dispuesto a perder). Este indicador te ayuda a identificar cuándo hay más probabilidad de tendencia, no te dice cuándo comprar o vender con certeza.
Este contenido es informativo y educativo, no constituye asesoría financiera ni recomendación de inversión. Los indicadores técnicos no garantizan resultados futuros.

---

## Source Code

````pine
//@version=6
indicator("Ichimoku + ADX + EMA - Visual Intuitive (Fixed)", overlay = true)

// ── Inputs ajustables ──
tenkanPeriod   = input.int(9,   "Tenkan-sen", minval=1)
kijunPeriod    = input.int(26,  "Kijun-sen", minval=1)
senkouBPeriod  = input.int(52,  "Senkou Span B", minval=1)
displacement   = input.int(26,  "Displacement (Cloud/Chikou)", minval=1)

adxLen         = input.int(14, "ADX Length", minval=1)
adxThreshold   = input.int(25, "ADX Umbral Tendencia Fuerte", minval=10, maxval=50)
emaLen         = input.int(50, "EMA Length", minval=1)

// ── Función auxiliar Donchian (midpoint high/low) ──
donchian(len) =>
    math.avg(ta.highest(high, len), ta.lowest(low, len))

// ── Ichimoku manual (estándar y sin errores) ──
tenkan   = donchian(tenkanPeriod)
kijun    = donchian(kijunPeriod)
senkouA  = math.avg(tenkan, kijun)
senkouB  = donchian(senkouBPeriod)
chikou   = close

// ── Nube con opacidad ──
cloudColor   = senkouA > senkouB ? color.new(color.green, 30) : color.new(color.red, 30)

// ── ADX ──
[diplus, diminus, adx_val] = ta.dmi(adxLen, adxLen)

// Nube gris cuando ADX débil
weakTrend    = adx_val < adxThreshold ? color.new(color.gray, 60) : cloudColor

// ── Plots nube proyectada (offset positivo = futuro) ──
pA = plot(senkouA, offset = displacement, color = cloudColor, title = "Senkou A")
pB = plot(senkouB, offset = displacement, color = cloudColor, title = "Senkou B")
fill(pA, pB, color = weakTrend, title = "Cloud")

// Chikou (lagging = offset negativo)
plot(chikou, offset = -displacement, color = color.new(color.purple, 50), title = "Chikou Span")

// ── EMA 50 condicional ──
ema50 = ta.ema(close, emaLen)
plot(ema50, color = close > ema50 ? color.new(color.blue, 0) : color.new(color.orange, 0), linewidth = 2, title = "EMA 50")

// ── ADX plot con colores ──
adxColor = adx_val > 30 ? color.green : adx_val > adxThreshold ? color.yellow : color.red
plot(adx_val, title = "ADX", color = adxColor, linewidth = 2)

// Umbral ADX
hline(adxThreshold, title = "ADX Umbral", color = color.red, linestyle = hline.style_dotted)

// ── Condiciones precio vs nube (usamos valores proyectados) ──
// Para la barra actual, miramos senkouA/B sin offset adicional (porque ya están proyectados)
priceAboveCloud = close > math.max(senkouA[displacement], senkouB[displacement])
priceBelowCloud = close < math.min(senkouA[displacement], senkouB[displacement])

// ── Fondo para tendencia fuerte ──
bgBull  = priceAboveCloud and close > ema50 and adx_val > adxThreshold
bgBear  = priceBelowCloud and close < ema50 and adx_val > adxThreshold

bgcolor(bgBull ? color.new(color.green, 92) : bgBear ? color.new(color.red, 92) : na, title = "Tendencia Fuerte")

// ── Triángulos solo al activarse ──
plotshape(bgBull and not bgBull[1], title = "Mantener Compra", style = shape.triangleup,   location = location.belowbar, color = color.green,  size = size.small)
plotshape(bgBear and not bgBear[1], title = "Mantener Venta", style = shape.triangledown, location = location.abovebar,  color = color.red,    size = size.small)

// Opcional: Tenkan y Kijun visibles (comenta si satura)
plot(tenkan, color = color.blue,   title = "Tenkan-sen", linewidth=1)
plot(kijun,  color = color.red,    title = "Kijun-sen",  linewidth=1)
````
