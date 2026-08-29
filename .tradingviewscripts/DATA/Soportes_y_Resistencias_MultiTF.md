<!-- tradingview-pine-id: PUB;2d58aca9281c4321ab0428cf02018f3c -->
<!-- tradingviewscripts-format: 1 -->
# Soportes y Resistencias Multi-TF.

Source: https://www.tradingview.com/script/YbhWaaX8/

## Description

# Soportes y Resistencias Multi-TF

> ⬇️ **Todo lo que sigue hasta la línea de "FIN DE LA DESCRIPCIÓN" es el texto que va pegado tal cual en el campo de descripción de TradingView al publicar.** Después de esa línea hay consejos para vos, que NO se pegan ahí.

## 📌 Resumen

**Soportes y Resistencias Multi-TF** detecta automáticamente niveles horizontales de soporte y resistencia a partir de pivotes de precio, y los adapta a cada temporalidad de forma independiente. A diferencia de un indicador de S/R genérico con parámetros fijos, este script recalcula tres variables clave (sensibilidad de detección, tolerancia de agrupado, y ventana de historial) según el timeframe activo, para que los niveles sean igual de limpios y relevantes tanto en 1 minuto como en semanal, sin que el usuario tenga que reconfigurar nada al cambiar de TF.

## ⚙️ Cómo funciona

1. **Detección de pivotes**: el script identifica máximos y mínimos locales (`pivot high` / `pivot low`) usando una cantidad de velas de confirmación a cada lado (lookback), que se ajusta automáticamente según el timeframe.
2. **Agrupado por tolerancia**: cada pivote nuevo se compara contra los niveles ya detectados. Si cae dentro de un porcentaje de tolerancia (también auto-escalado por TF), se fusiona con el nivel existente y suma un "toque"; si no, se registra como un nivel nuevo.
3. **Filtro de vigencia por antigüedad**: el sistema descarta de la memoria los niveles cuyo último toque sea demasiado viejo, priorizando que la memoria del indicador se mantenga poblada de precios recientes en vez de quedar ocupada por niveles históricos irrelevantes.
4. **Ventana de historial dinámica**: solo se dibujan niveles cuyo último toque ocurrió dentro de una ventana de días que también se auto-escala por TF (desde 1 día en gráficos de 1 minuto hasta 2 años en semanal), evitando que resistencias o soportes de hace meses tapen la acción de precio actual.
5. **Separación mínima garantizada**: antes de dibujar, el indicador exige que cada nivel visible esté separado del resto por al menos la tolerancia configurada, evitando el efecto de "franja sólida" que producen otros indicadores similares cuando hay mucho ruido de precio.
6. **Ranking por relevancia**: de todos los niveles vigentes, solo se dibujan los N más relevantes (configurable), priorizando primero por cantidad de toques y luego por recencia.

## 🎨 Cómo leer el indicador

| Elemento | Significado |
|---|---|
| Línea verde clara / naranja clara | Nivel con 1 solo toque |
| Línea verde media / roja media, etiqueta "doble" | Nivel con 2 toques |
| Línea verde oscura / roja oscura, etiqueta "x3", "x4"... | Nivel con 3 o más toques (mayor relevancia estructural) |
| Grosor de línea | Aumenta con la cantidad de toques |
| "S" | Soporte |
| "R" | Resistencia |

Cuanto más gruesa y oscura la línea, más veces el precio reaccionó ahí — mayor probabilidad de que vuelva a actuar como zona de decisión.

## 🔧 Parámetros configurables

- **Tolerancia manual (%)**: 0 = automática por TF. Subila si querés niveles más "gruesos" (agrupa zonas más amplias); bajala para mayor precisión quirúrgica.
- **Máximo de niveles en memoria**: cuántos niveles distintos puede recordar el indicador antes de empezar a descartar los más antiguos. Subilo en TFs altos (Diario/Semanal) con mucha historia.
- **Máximo de niveles visibles**: cuántas líneas se dibujan en pantalla simultáneamente. Menos = gráfico más limpio; más = mayor contexto.
- **Lookback manual de pivotes**: 0 = automático por TF. Controla qué tan "sensible" es la detección de un pivote.
- **Días de historial manual**: 0 = automático por TF. Define qué tan atrás se considera relevante un nivel.
- **Barras de extensión**: cuánto se proyectan las líneas hacia la derecha del último precio.
- **Mostrar etiquetas de toques**: activa/desactiva las etiquetas "S x3", "R doble", etc.

## 📈 Recomendaciones de uso

- **Scalping (1m–15m)**: dejá todo en automático. La ventana de historial corta evita que niveles de hace semanas contaminen el gráfico.
- **Intradía / Swing (30m–4h)**: funciona bien como confirmación de zonas de entrada/salida junto con estructura de mercado o velas japonesas.
- **Posicional (Diario/Semanal)**: subí el "máximo de niveles en memoria" si operás activos con mucha historia, para no perder niveles estructurales importantes.
- Combinalo con volumen o un indicador de tendencia para filtrar falsos rechazos en niveles de un solo toque.

## ⚠️ Limitaciones

- Es un indicador de estructura de precio, no genera señales de compra/venta.
- Los niveles se recalculan y pueden desplazarse levemente hasta que un pivote queda confirmado (lag inherente a cualquier detección de pivote).
- El comportamiento pasado de un nivel no garantiza reacción futura del precio.

---

*Este script no constituye asesoría financiera. Es una herramienta de análisis técnico visual; toda decisión de trading es responsabilidad del usuario.*

---

## Source Code

````pine
//@version=6
indicator("Soportes y Resistencias Multi-TF.", overlay=true, max_lines_count=500, max_labels_count=500)

// ============ INPUTS ============
grpConfig = "Configuración"
toleranceInput  = input.float(0.0, "Tolerancia manual % (0 = automática por TF)", minval=0.0, maxval=3.0, step=0.01, group=grpConfig)
maxLevels       = input.int(150, "Máximo de niveles en memoria (sube esto en Diario/4h con mucha historia)", minval=5, maxval=200, group=grpConfig)
maxVisible      = input.int(20, "Máximo de niveles VISIBLES en pantalla", minval=5, maxval=50, group=grpConfig)
showLabels      = input.bool(true, "Mostrar etiquetas de toques", group=grpConfig)
extendBars      = input.int(30, "Barras a extender a la derecha", minval=0, maxval=200, group=grpConfig)
pivotLenInput   = input.int(0, "Lookback manual de pivotes (0 = automático por TF)", minval=0, group=grpConfig)
lookbackDaysInput = input.int(0, "Días de historial manual (0 = automático por TF)", minval=0, maxval=3650, group=grpConfig)

grpColores = "Colores"
col1Sup = input.color(color.new(color.lime, 55),  "Soporte simple",   group=grpColores)
col2Sup = input.color(color.new(color.green, 25), "Soporte doble",    group=grpColores)
col3Sup = input.color(#004d00,                     "Soporte triple+",  group=grpColores)

col1Res = input.color(color.new(color.orange, 55), "Resistencia simple",  group=grpColores)
col2Res = input.color(color.new(color.red, 25),    "Resistencia doble",   group=grpColores)
col3Res = input.color(#660000,                      "Resistencia triple+", group=grpColores)

// ============ LOOKBACK AUTOMÁTICO DE PIVOTES POR TEMPORALIDAD ============
getAutoLen() =>
    tf = timeframe.period
    len = 10
    if tf == "1"
        len := 6
    else if tf == "3"
        len := 6
    else if tf == "5"
        len := 6
    else if tf == "15"
        len := 8
    else if tf == "30"
        len := 9
    else if tf == "60"
        len := 10
    else if tf == "120"
        len := 10
    else if tf == "240"
        len := 12
    else if tf == "D" or tf == "1D"
        len := 15
    else if tf == "W" or tf == "1W"
        len := 12
    else
        len := 10
    len

pivotLen = pivotLenInput == 0 ? getAutoLen() : pivotLenInput

// ============ TOLERANCIA AUTOMÁTICA POR TEMPORALIDAD ============
getAutoTolerance() =>
    tf = timeframe.period
    tol = 0.05
    if tf == "1"
        tol := 0.01
    else if tf == "3"
        tol := 0.02
    else if tf == "5"
        tol := 0.03
    else if tf == "15"
        tol := 0.05
    else if tf == "30"
        tol := 0.08
    else if tf == "60"
        tol := 0.12
    else if tf == "120"
        tol := 0.18
    else if tf == "240"
        tol := 0.28
    else if tf == "D" or tf == "1D"
        tol := 0.55
    else if tf == "W" or tf == "1W"
        tol := 0.90
    else
        tol := 0.05
    tol

tolerancePct = toleranceInput == 0.0 ? getAutoTolerance() : toleranceInput

// ============ DÍAS DE HISTORIAL AUTOMÁTICOS POR TEMPORALIDAD ============
getAutoLookbackDays() =>
    tf = timeframe.period
    d = 10
    if tf == "1"
        d := 1
    else if tf == "3"
        d := 1
    else if tf == "5"
        d := 2
    else if tf == "15"
        d := 3
    else if tf == "30"
        d := 5
    else if tf == "60"
        d := 10
    else if tf == "120"
        d := 15
    else if tf == "240"
        d := 20
    else if tf == "D" or tf == "1D"
        d := 180
    else if tf == "W" or tf == "1W"
        d := 730
    else
        d := 10
    d

lookbackDays = lookbackDaysInput == 0 ? getAutoLookbackDays() : lookbackDaysInput

// ============ ARRAYS DE NIVELES ============
var float[] levelPrice    = array.new_float(0)
var int[]   levelTouches  = array.new_int(0)
var int[]   levelFirstTime= array.new_int(0)
var int[]   levelLastTime = array.new_int(0)
var bool[]  levelIsSup    = array.new_bool(0)
var line[]  levelLine     = array.new_line(0)
var label[] levelLabel    = array.new_label(0)

// ============ DETECTAR PIVOTES ============
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
pivotTime = time[pivotLen]

// ============ AGREGAR O ACTUALIZAR NIVEL ============
addOrUpdate(float price, bool isSup, int touchTime) =>
    n = array.size(levelPrice)
    matched = -1
    if n > 0
        for i = 0 to n - 1
            existing = array.get(levelPrice, i)
            sameType = array.get(levelIsSup, i) == isSup
            withinTol = math.abs(price - existing) / existing * 100 <= tolerancePct
            if sameType and withinTol
                matched := i
                break
    if matched >= 0
        newTouches = array.get(levelTouches, matched) + 1
        array.set(levelTouches, matched, newTouches)
        avgPrice = (array.get(levelPrice, matched) + price) / 2
        array.set(levelPrice, matched, avgPrice)
        array.set(levelLastTime, matched, touchTime)
    else
        array.push(levelPrice, price)
        array.push(levelTouches, 1)
        array.push(levelFirstTime, touchTime)
        array.push(levelLastTime, touchTime)
        array.push(levelIsSup, isSup)
        array.push(levelLine, na)
        array.push(levelLabel, na)

if not na(ph)
    addOrUpdate(ph, false, pivotTime)

if not na(pl)
    addOrUpdate(pl, true, pivotTime)

// ============ TOPE DE MEMORIA (se descarta siempre el nivel con toque más antiguo, sin importar cuántos toques tenga) ============
if array.size(levelPrice) > maxLevels
    worstIdx = 0
    worstLastTime = array.get(levelLastTime, 0)
    for i = 1 to array.size(levelPrice) - 1
        lt = array.get(levelLastTime, i)
        if lt < worstLastTime
            worstLastTime := lt
            worstIdx := i
    oldLine = array.get(levelLine, worstIdx)
    oldLabel = array.get(levelLabel, worstIdx)
    line.delete(oldLine)
    label.delete(oldLabel)
    array.remove(levelPrice, worstIdx)
    array.remove(levelTouches, worstIdx)
    array.remove(levelFirstTime, worstIdx)
    array.remove(levelLastTime, worstIdx)
    array.remove(levelIsSup, worstIdx)
    array.remove(levelLine, worstIdx)
    array.remove(levelLabel, worstIdx)

// ============ COLOR Y GROSOR SEGÚN TOQUES ============
getColor(bool isSup, int touches) =>
    c = isSup ? (touches >= 3 ? col3Sup : touches == 2 ? col2Sup : col1Sup) : (touches >= 3 ? col3Res : touches == 2 ? col2Res : col1Res)
    c

getWidth(int touches) =>
    touches >= 3 ? 3 : touches == 2 ? 2 : 1

// ============ VARIABLES DE ALERTA ============
var bool touchSupport    = false
var bool touchResistance = false
var bool breakSupport    = false
var bool breakResistance = false

// ============ DIBUJAR SOLO LOS NIVELES RELEVANTES (recientes + con separación mínima) ============
if barstate.islast
    n = array.size(levelPrice)
    cutoffTime = time - lookbackDays * 86400000

    // Prioridad solo para niveles cuyo último toque está dentro de la ventana de días (auto por TF)
    priority = array.new_float(n)
    passWindowCount = 0
    for i = 0 to n - 1
        touches = array.get(levelTouches, i)
        lastTime = array.get(levelLastTime, i)
        withinWindow = lastTime >= cutoffTime
        if withinWindow
            passWindowCount += 1
        score = withinWindow ? touches * 1.0 + lastTime / 1.0e15 : -1.0e30
        array.set(priority, i, score)

    sortedIdx = array.sort_indices(priority, order.descending)

    barMs = timeframe.in_seconds() * 1000
    endTime = time + extendBars * barMs

    drawnPrices = array.new_float(0)
    drawnIsSup = array.new_bool(0)
    visibleCount = 0

    for j = 0 to n - 1
        i = array.get(sortedIdx, j)
        oldLine  = array.get(levelLine, i)
        oldLabel = array.get(levelLabel, i)
        line.delete(oldLine)
        label.delete(oldLabel)

        price = array.get(levelPrice, i)
        pr    = array.get(priority, i)

        tooClose = false
        if array.size(drawnPrices) > 0
            for k = 0 to array.size(drawnPrices) - 1
                dp = array.get(drawnPrices, k)
                if math.abs(price - dp) / dp * 100 <= tolerancePct
                    tooClose := true
                    break

        if not tooClose and pr > -1.0e29 and visibleCount < maxVisible
            touches   = array.get(levelTouches, i)
            firstTime = array.get(levelFirstTime, i)
            isSup     = array.get(levelIsSup, i)

            newLine = line.new(firstTime, price, endTime, price,
                 xloc=xloc.bar_time, color=getColor(isSup, touches),
                 width=getWidth(touches), extend=extend.none)
            array.set(levelLine, i, newLine)

            if showLabels
                tipo = isSup ? "S" : "R"
                txt = touches >= 3 ? tipo + " x" + str.tostring(touches) : touches == 2 ? tipo + " doble" : tipo
                newLabel = label.new(endTime, price, txt,
                     xloc=xloc.bar_time, style=isSup ? label.style_label_up : label.style_label_down,
                     color=color.new(color.black, 100), textcolor=getColor(isSup, touches), size=size.small)
                array.set(levelLabel, i, newLabel)

            array.push(drawnPrices, price)
            array.push(drawnIsSup, isSup)
            visibleCount += 1
        else
            array.set(levelLine, i, na)
            array.set(levelLabel, i, na)

    // ============ CHEQUEO DE TOQUE Y RUPTURA (solo contra niveles visibles) ============
    touchSupport := false
    touchResistance := false
    breakSupport := false
    breakResistance := false

    for m = 0 to array.size(drawnPrices) - 1
        lvlPrice = array.get(drawnPrices, m)
        lvlIsSup = array.get(drawnIsSup, m)

        touched = high >= lvlPrice and low <= lvlPrice
        brokenUp = close[1] <= lvlPrice and close > lvlPrice
        brokenDown = close[1] >= lvlPrice and close < lvlPrice

        if touched
            if lvlIsSup
                touchSupport := true
            else
                touchResistance := true

        if lvlIsSup and brokenDown
            breakSupport := true
        if not lvlIsSup and brokenUp
            breakResistance := true

// ============ CONDICIONES DE ALERTA (configurables desde el icono de campana de TradingView) ============
alertcondition(touchSupport, title="Toque de Soporte", message="{{ticker}} ({{interval}}): precio tocó un nivel de SOPORTE en {{close}}")
alertcondition(touchResistance, title="Toque de Resistencia", message="{{ticker}} ({{interval}}): precio tocó un nivel de RESISTENCIA en {{close}}")
alertcondition(breakSupport, title="Ruptura de Soporte", message="{{ticker}} ({{interval}}): cierre confirmado por DEBAJO de un soporte en {{close}}")
alertcondition(breakResistance, title="Ruptura de Resistencia", message="{{ticker}} ({{interval}}): cierre confirmado por ENCIMA de una resistencia en {{close}}")
````
