# Campaign Map - Contreras Law

- url: https://www.tradingview.com/script/dc88QwYs-Campaign-Map-Contreras-Law/
- type: indicator
- pine_id: PUB;01c60109efc7408f85ece32968c6be26
- version: 3.0

## Description

[ES] Version en espanol mas abajo.  ·  [EN] English version first, Spanish below.
 
─────────────────────────────────
 
CAMPAIGN MAP — CONTRERAS' LAW
 
WHAT IT MEASURES
 
This indicator builds the historical distribution of a symbol's
campaign corrections (peak→trough declines confirmed by reversal) and
places the CURRENT correction inside that map: is it normal breathing,
a deep pullback, or statistically unusual territory?
 
THE OBSERVATION BEHIND IT
 
Contreras' Law (Jacinto Contreras, June 2026): in US large-cap
technology stocks, the typical depth of campaign corrections converges
to a structural constant (~14-15% median at campaign scale),
regardless of the symbol. What differentiates each stock is not its
median but its historical maximum tail (observed: from ~25% to ~53%
depending on the symbol, across ~11 years of hourly data on 9 names).
 
Operational takeaway: MONITOR WITH THE MEDIAN, SIZE WITH THE TAIL.
 
HOW IT WORKS
 
· A reversal-threshold zigzag detects campaign peaks and troughs.
· Only COMPLETED corrections (confirmed by reversal) enter the
  statistics: median, 75th percentile, and historical maximum.
· The main line plots the depth of the ongoing correction, colored by
  zone: normal (teal), deep (orange), unusual (red).
· Summary table with the symbol's map and current status.
· Two alerts: median cross and P75 cross.
 
HOW TO USE IT
 
· Below the median: normal breathing; the pullback alone carries no
  trend-change information.
· Between median and P75: deep but normal correction.
· Above P75: statistically unusual territory. The correct reading is
  NOT "it must bounce now" — it is: look for exhaustion evidence
  (divergences, capitulation) and demand confirmation.
· The historical maximum (the tail) is the worst-case reference for
  position sizing and campaign stops.
 
INPUTS
 
· Reversal (%): rally confirming the end of a bearish campaign.
  8% = campaign scale (default). 3% = swing scale.
· Minimum depth (%): smaller corrections are excluded from the map.
  10% campaign / 5% swing.
 
LIMITATIONS (read before use)
 
· Statistics do NOT repaint (completed corrections only), but the
  ONGOING correction is provisional by nature: its campaign peak may
  extend until the reversal confirms.
· The median convergence was observed in US large-cap tech on the
  hourly timeframe; it may not hold in other sectors, assets or
  timeframes. Verify it on your symbol before relying on it.
· Enough campaigns (>8-10) are required for the map to be
  statistically meaningful; the indicator shows "calibrating…" until
  then.
· This is a MEASUREMENT and context tool. It does not generate buy or
  sell signals and guarantees no outcome. Not financial advice.
 
─────────────────────────────────
 
VERSIÓN EN ESPAÑOL
 
MAPA DE CAMPAÑAS — LEY DE CONTRERAS
 
QUÉ MIDE
 
Este indicador construye la distribución histórica de las correcciones
de campaña de un valor (caídas máximo→mínimo confirmadas por reversión)
y sitúa la corrección actual dentro de ese mapa: ¿es una respiración
normal, una corrección profunda o territorio inusual?
 
LA OBSERVACIÓN QUE LO ORIGINA
 
Ley de Contreras (Jacinto Contreras, junio de 2026): en valores
tecnológicos estadounidenses de alta capitalización, la profundidad
típica de las correcciones de campaña converge en una constante
estructural (~14-15% de mediana, escala campaña), independiente del
símbolo. Lo que diferencia a cada valor no es su mediana, sino su cola
máxima histórica (observado: desde ~25% hasta ~53% según el símbolo,
sobre ~11 años de datos horarios en 9 valores).
 
Moraleja operativa: VIGILAR CON LA MEDIANA, DIMENSIONAR CON LA COLA.
 
CÓMO FUNCIONA
 
· Un zigzag por umbral de reversión detecta picos y valles de campaña.
· Solo las correcciones COMPLETADAS (confirmadas por reversión) entran
  en la estadística: mediana, percentil 75 y máximo histórico.
· La línea principal muestra la profundidad de la corrección en curso,
  coloreada según la zona: normal (verde), profunda (naranja),
  inusual (rojo).
· Tabla resumen con el mapa del símbolo y el estado actual.
· Dos alertas: cruce de la mediana y cruce del P75.
 
CÓMO USARLO
 
· Por debajo de la mediana: respiración normal; el retroceso no es,
  por sí solo, información de cambio de tendencia.
· Entre mediana y P75: corrección profunda pero dentro de lo normal.
· Por encima del P75: territorio estadísticamente inusual. La lectura
  correcta no es "ya tiene que rebotar", sino: buscar señales de
  agotamiento (divergencias, capitulación) y exigir confirmación.
· El máximo histórico (la cola) es la referencia de peor caso para
  dimensionar posición y stops de campaña.
 
PARÁMETROS
 
· Reversión (%): rally que confirma el fin de una campaña bajista.
  8% = escala campaña (por defecto). 3% = escala swing.
· Profundidad mínima (%): correcciones menores no entran al mapa.
  10% campaña / 5% swing.
 
LIMITACIONES (léelas antes de usar)
 
· Las estadísticas NO repintan (solo correcciones completadas), pero
  la corrección EN CURSO es provisional por naturaleza: su máximo de
  campaña puede extenderse hasta que la reversión confirme.
· La convergencia de medianas está observada en tecnológicas USA de
  alta capitalización en marco horario; en otros sectores, activos o
  marcos puede no cumplirse. Compruébalo en tu símbolo antes de usarlo.
· Se necesitan suficientes campañas (>8-10) para que el mapa tenga
  valor estadístico; el indicador muestra "calibrando…" mientras tanto.
· Es una herramienta de MEDICIÓN y contexto. No genera señales de
  compra/venta ni garantiza resultado alguno. No es asesoramiento
  financiero.

## Source Code

````pine
//@version=6
// ============================================================
//  MAPA DE CAMPAÑAS — Ley de Contreras
//  "La profundidad de las campañas converge; la identidad del
//   valor vive en su cola."        — Jacinto Contreras, 12/06/2026
//
//  QUÉ HACE: detecta las correcciones de campaña (máximo→mínimo
//  con reversión confirmada) de todo el histórico del gráfico y
//  construye la distribución del propio valor: mediana, P75 y
//  máximo. Después sitúa la corrección ACTUAL dentro de ese mapa.
//
//  LECTURA OPERATIVA:
//   · Por debajo de la mediana  → respiración normal de campaña.
//   · Mediana → P75             → corrección profunda pero normal.
//   · P75 → Máximo              → territorio inusual: buscar
//     agotamiento (divergencias, capitulación), no predecir suelo.
//   · Vigilar con la mediana, dimensionar con la cola (Máx).
//
//  HONESTIDAD TÉCNICA (también va en la descripción al publicar):
//   · Las estadísticas usan SOLO correcciones completadas
//     (confirmadas por reversión) → no repintan.
//   · La corrección EN CURSO es provisional por naturaleza: su
//     máximo de campaña puede extenderse hasta que confirme.
//   · Esto es una herramienta de MEDICIÓN y contexto, no una
//     señal de compra/venta ni una promesa de rentabilidad.
//   · Evidencia origen: ~11 años 1H en 9 tecnológicas USA
//     (medianas de campaña convergiendo en 14-15%; colas 25-53%).
//   · La convergencia se mantiene también en escala diaria
//     (NFLX 1D: 256 campañas, mediana 15.9%).
// ============================================================
indicator("Campaign Map - Contreras Law", shorttitle = 'Ley de Contreras', overlay = false, max_bars_back = 500)

// ───────────── Inputs (3: dentro del protocolo anti-sobreajuste) ─────────────
rev_pct = input.float(8.0, 'Reversión que confirma giro (%)', minval = 2.0, maxval = 20.0, step = 0.5, tooltip = 'Rally mínimo desde el mínimo para dar la campaña bajista por terminada. 8% = escala campaña (validado). 3% = escala swing.')
min_corr = input.float(10.0, 'Profundidad mínima de campaña (%)', minval = 3.0, maxval = 30.0, step = 1.0, tooltip = 'Solo las correcciones con esta profundidad mínima entran en la estadística. 10% = campañas (validado). 5% = swings.')
ver_tabla = input.bool(true, 'Mostrar tabla resumen')

// ───────────── Zigzag de campañas (solo correcciones COMPLETADAS) ─────────────
var int dir = 0 //  1 = tramo alcista (buscando pico) · -1 = bajista (buscando valle)
var float ext = na // extremo en curso del tramo
var float pico_camp = na // último pico de campaña confirmado
var array<float> profundidades = array.new_float()

if dir == 0
    ext := high
    dir := 1
    dir

if dir == 1
    if high > ext
        ext := high
        ext
    else if low <= ext * (1 - rev_pct / 100)
        pico_camp := ext // pico confirmado
        dir := -1
        ext := low
        ext
else if dir == -1
    if low < ext
        ext := low
        ext
    else if high >= ext * (1 + rev_pct / 100)
        prof = (pico_camp - ext) / pico_camp * 100
        if prof >= min_corr
            array.push(profundidades, prof) // corrección completada → entra al mapa
        dir := 1
        ext := high
        ext

// ───────────── Estadísticas del mapa (no repintan: solo completadas) ─────────────
n_corr = array.size(profundidades)
float mediana = n_corr >= 5 ? array.median(profundidades) : na
float p75 = n_corr >= 5 ? array.percentile_linear_interpolation(profundidades, 75) : na
float maximo = n_corr >= 1 ? array.max(profundidades) : na

// ───────────── Corrección actual (provisional hasta que confirme) ─────────────
float maximo_campana = dir == 1 ? ext : pico_camp
float dd_actual = not na(maximo_campana) ? (maximo_campana - close) / maximo_campana * 100 : 0.0
dd_actual := math.max(dd_actual, 0.0)

estado = na(mediana) ? 'calibrando…' : dd_actual < mediana ? 'NORMAL' : na(p75) or dd_actual < p75 ? 'PROFUNDA' : na(maximo) or dd_actual < maximo ? 'INUSUAL' : 'EXTREMA'

// ───────────── Visualización ─────────────
col_actual = na(mediana) ? color.gray : dd_actual < mediana ? color.teal : not na(p75) and dd_actual < p75 ? color.orange : color.red

plot(dd_actual, 'Corrección actual %', color = col_actual, linewidth = 2)
pm = plot(mediana, 'Mediana', color = color.new(color.teal, 30), linewidth = 1)
pp = plot(p75, 'P75', color = color.new(color.orange, 30), linewidth = 1)
px = plot(maximo, 'Máximo histórico (la cola)', color = color.new(color.red, 30), linewidth = 1)
fill(pm, pp, color = color.new(color.orange, 92), title = 'Zona profunda')
fill(pp, px, color = color.new(color.red, 94), title = 'Zona inusual')
hline(0, 'Cero', color = color.gray, linestyle = hline.style_dotted)
// Margen invisible: extiende la escala bajo cero para reservar una franja
// vacía donde reposa la tabla resumen sin pisar los datos
plot(na(maximo) ? -10.0 : -maximo * 0.32, 'Margen banda', color = color.new(color.white, 100), editable = false, display = display.pane)

// Tabla resumen — bloque compacto 3×2 anclado abajo-izquierda.
// La celda inferior-izquierda se deja vacía: es la franja que solapa el logo de TradingView.
var table t = table.new(position.bottom_left, 3, 2, border_width = 1)
if ver_tabla and barstate.islast
    // Fila superior (queda por encima del logo)
    table.cell(t, 0, 0, 'Campañas\n' + str.tostring(n_corr), text_color = chart.fg_color, bgcolor = color.new(color.gray, 80), text_size = size.small)
    table.cell(t, 1, 0, 'Mediana\n' + (na(mediana) ? '—' : str.tostring(mediana, '0.0') + '%'), text_color = chart.fg_color, bgcolor = color.new(color.gray, 80), text_size = size.small)
    table.cell(t, 2, 0, 'P75\n' + (na(p75) ? '—' : str.tostring(p75, '0.0') + '%'), text_color = chart.fg_color, bgcolor = color.new(color.gray, 80), text_size = size.small)
    // Fila inferior — (0,1) vacía y transparente para ceder el hueco al logo
    table.cell(t, 0, 1, '', bgcolor = color.new(color.gray, 100))
    table.cell(t, 1, 1, 'MÁX\n' + (na(maximo) ? '—' : str.tostring(maximo, '0.0') + '%'), text_color = color.red, bgcolor = color.new(color.gray, 80), text_size = size.small)
    table.cell(t, 2, 1, 'ACTUAL\n' + str.tostring(dd_actual, '0.0') + '%\n' + estado, text_color = col_actual, bgcolor = color.new(color.gray, 80), text_size = size.small)

// Alertas
alertcondition(not na(mediana) and ta.crossover(dd_actual, mediana), 'Cruza la mediana', 'Corrección supera la mediana de campaña: profunda pero normal')
alertcondition(not na(p75) and ta.crossover(dd_actual, p75), 'Cruza el P75', 'Corrección entra en territorio inusual: vigilar agotamiento (Ley de Contreras)')
````
