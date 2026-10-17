# SMA 8 Hook Signal PRO

- url: https://www.tradingview.com/script/pajszGNK/
- type: indicator
- pine_id: PUB;8d63e183d7bd4c7db51dcb130253cd86
- version: 1.0

## Description

▲▼ SMA 8 Hook Signal PRO

A hook detection system built on the SMA 8, designed for scalping
and intraday trading — optimized for SPX / ES futures.

The indicator identifies the exact moment the SMA 8 changes direction
after separating from the SMA 20, filtering out low-quality signals
through three layers of validation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The core logic detects a confirmed slope change in the SMA 8 — what
traders call a "hook" — and validates it through three filters before
firing a signal:

🎣 FILTER 1 — Hook curvature
Checks that in the candles prior to the turn, the SMA 8 had enough
separation from the SMA 20 and accumulated slope. This ensures the
hook comes from a real move, not a flat consolidation zone.

🔬 FILTER 2 — Distance to price
Confirms that price is not "glued" to the SMA 8 at the time of the
signal, or that the signal candle is large enough to justify the
entry regardless.

📐 FILTER 3 — Moving average position and separation
Validates that the SMA 8 is on the correct side of the SMA 20 for
the signal direction (LONG or SHORT), with a minimum percentage
separation between both averages. A powerful candle can bypass
this filter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▲ LONG  — appears below the candle when the SMA 8 turns upward
▼ SHORT — appears above the candle when the SMA 8 turns downward

Hover over the label to see:
  • Entry price
  • Take Profit level
  • Stop Loss level
  • R/R ratio calculated automatically

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TP / SL LEVELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Levels are calculated dynamically using ATR:

  • Take Profit = Slow ATR (14) × TP multiplier
  • Stop Loss   = Slow ATR (14) × SL multiplier

Lines project to the right with configurable extension and display
labels showing the value in points.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MOVING AVERAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • SMA 8  — changes color based on its current slope
              (green = rising / red = falling)
  • SMA 20 — background trend reference

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONFIGURABLE PARAMETERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ ATR
  • Fast ATR period (entry filters)            — default: 7
  • Slow ATR period (TP and SL)               — default: 14
  • Take Profit multiplier                    — default: 1.0
  • Stop Loss multiplier                      — default: 0.5

🎣 Hook
  • Candles back for curvature measurement    — default: 6
  • Min SMA8/SMA20 separation (× fast ATR)   — default: 0.5
  • Minimum accumulated slope                 — default: 0.0

🔬 Filters
  • Max price-SMA8 distance when glued        — default: 0.2
  • Min large candle range (exception)        — default: 1.5
  • Min SMA8-SMA20 separation (%)            — default: 0.20
  • Min powerful candle body (%)             — default: 0.10

🎨 Visual
  • Show / hide TP and SL levels
  • Show / hide price labels
  • Line extension length (in candles)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Three alert conditions ready to activate:
  • BUY Signal
  • SELL Signal
  • BUY or SELL Signal (combined)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED TIMEFRAMES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Works best on:
  1 min · 2 min · 3 min · 5 min

Recommended instruments:
  SPX · ES1! · QQQ · NQ1! · any instrument with clean trending moves

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Signals are confirmed on the previous closed candle,
  never on the current bar — no repainting.

- This indicator is a decision-support tool. Always use it
  in context with market flow, GEX levels, and relevant
  support and resistance zones.

- This is not financial advice.

## Source Code

````pine
//@version=5
indicator("SMA 8 Hook Signal PRO", overlay=true, max_lines_count=500)

// ══════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════
periodoATREntrada = input.int(7,     title="ATR rápido (filtros de entrada)", minval=1,   group="⚡ ATR")
periodoATRNivel   = input.int(14,    title="ATR lento (TP y SL)",            minval=1,   group="⚡ ATR")
multTP            = input.float(1.0, title="Take Profit (x ATR lento)",      step=0.1, minval=0.1, group="⚡ ATR")
multSL            = input.float(0.5, title="Stop Loss (x ATR lento)",        step=0.1, minval=0.1, group="⚡ ATR")

velasAtras        = input.int(6,     title="Velas atrás para curvatura",                         minval=3, maxval=20, group="🎣 Gancho")
multSeparacion    = input.float(0.5, title="Separación mínima SMA8/SMA20 (x ATR rápido)",        step=0.1, minval=0.1, group="🎣 Gancho")
pendienteMinima   = input.float(0.0, title="Pendiente acumulada mínima del gancho",              step=0.05, minval=0.0, group="🎣 Gancho")

multPegado        = input.float(0.2,  title="Dist. máx precio-SMA8 pegado (x ATR rápido)",        step=0.1, minval=0.05, group="🔬 Filtros")
multVelaGrande    = input.float(1.5,  title="Rango mínimo vela grande excepción (x ATR rápido)",  step=0.1, minval=0.1,  group="🔬 Filtros")
sepPct            = input.float(0.20, title="Separación mínima SMA8-SMA20 (%)",                   step=0.05, minval=0.01, group="🔬 Filtros")
pctVelaPoderosa   = input.float(0.10, title="Cuerpo vela poderosa: omite filtros de medias (%)", step=0.01, minval=0.01, group="🔬 Filtros")

modoDiagnostico   = input.bool(true, title="Modo diagnóstico", group="🛠 Diagnóstico")

mostrarTP_SL      = input.bool(true, title="Mostrar niveles TP / SL",           group="🎨 Visual")
mostrarEtiquetas  = input.bool(true, title="Mostrar etiquetas TP / SL",         group="🎨 Visual")
anchoProlongacion = input.int(8,     title="Prolongación líneas TP/SL (velas)", minval=2, maxval=30, group="🎨 Visual")

// ══════════════════════════════════════════════════════════
// ATR
// ══════════════════════════════════════════════════════════
atrRapido = ta.atr(periodoATREntrada)
atrLento  = ta.atr(periodoATRNivel)

puntosTP         = atrLento  * multTP
puntosSL         = atrLento  * multSL
separacionMinima = atrRapido * multSeparacion
distPegada       = atrRapido * multPegado
velaGrande       = atrRapido * multVelaGrande

// ══════════════════════════════════════════════════════════
// MEDIAS MÓVILES
// ══════════════════════════════════════════════════════════
sma8  = ta.sma(close, 8)
sma20 = ta.sma(close, 20)

pendiente(i) => sma8[i] - sma8[i + 1]

colorSma8 = pendiente(0) > 0 ? color.new(color.lime, 15) : color.new(color.red, 15)

plot(sma20, title="SMA 20",       color=color.new(color.rgb(100, 120, 255), 10), linewidth=2)
plot(sma8,  title="SMA 8 base",  color=color.new(color.yellow, 0),               linewidth=1)
plot(sma8,  title="SMA 8 color", color=colorSma8,                                linewidth=3)

// ══════════════════════════════════════════════════════════
// CAMBIO DE COLOR — velas confirmadas
// ══════════════════════════════════════════════════════════
sma8SubiendoConf = pendiente(1) > 0
sma8BajandoConf  = pendiente(1) < 0
cambioAVerde     = sma8SubiendoConf and pendiente(2) < 0
cambioARojo      = sma8BajandoConf  and pendiente(2) > 0

// ══════════════════════════════════════════════════════════
// FILTRO 1 — CURVATURA DEL GANCHO
// ══════════════════════════════════════════════════════════
maxSepAntes   = 0.0
pendienteAcum = 0.0
for i = 2 to velasAtras + 1
    maxSepAntes   := math.max(maxSepAntes, math.abs(sma8[i] - sma20[i]))
    pendienteAcum := pendienteAcum + math.abs(pendiente(i))

f1_gancho = maxSepAntes >= separacionMinima[1] and pendienteAcum >= pendienteMinima

// ══════════════════════════════════════════════════════════
// FILTRO 2 — DISTANCIA AL PRECIO
// ══════════════════════════════════════════════════════════
distanciaSma8 = math.abs(close[1] - sma8[1])
rangVela      = high[1] - low[1]
f2_distancia  = distanciaSma8 > distPegada[1] or rangVela >= velaGrande[1]

// ══════════════════════════════════════════════════════════
// FILTRO 3 — POSICIÓN Y SEPARACIÓN DE MEDIAS
// ══════════════════════════════════════════════════════════
sma8SobreSma20 = sma8[1] > sma20[1]
sma8BajoSma20  = sma8[1] < sma20[1]
sepActual      = math.abs(sma8[1] - sma20[1]) / close[1] * 100
f3_sepPct      = sepActual >= sepPct
f3_direccion   = (cambioAVerde and sma8BajoSma20) or (cambioARojo and sma8SobreSma20)
f3_medias      = f3_sepPct and f3_direccion

cuerpoVela   = math.abs(close[1] - open[1])
velaPoderosa = (cuerpoVela / close[1] * 100) >= pctVelaPoderosa
f3_ok        = velaPoderosa or f3_medias

// ══════════════════════════════════════════════════════════
// SEÑALES FINALES
// ══════════════════════════════════════════════════════════
senalLong  = cambioAVerde and f1_gancho and f2_distancia and f3_ok
senalShort = cambioARojo  and f1_gancho and f2_distancia and f3_ok

// ══════════════════════════════════════════════════════════
// VISUAL — etiquetas con tooltip al hover
// ══════════════════════════════════════════════════════════
if senalLong
    ttLong = "Entrada: " + str.tostring(open[1], "#.##") + "\nTP:      " + str.tostring(close[1] + puntosTP[1], "#.##") + "\nSL:      " + str.tostring(open[1] - puntosSL[1], "#.##") + "\nR/R:     1:" + str.tostring(math.round(puntosTP[1] / puntosSL[1], 1))
    label.new(bar_index - 1, low[1] - atrRapido[1] * 0.4, "▲ LONG", style=label.style_label_up, color=color.rgb(0, 200, 120), textcolor=color.white, size=size.normal, textalign=text.align_center, tooltip=ttLong)

if senalShort
    ttShort = "Entrada: " + str.tostring(open[1], "#.##") + "\nTP:      " + str.tostring(close[1] - puntosTP[1], "#.##") + "\nSL:      " + str.tostring(open[1] + puntosSL[1], "#.##") + "\nR/R:     1:" + str.tostring(math.round(puntosTP[1] / puntosSL[1], 1))
    label.new(bar_index - 1, high[1] + atrRapido[1] * 0.4, "▼ SHORT", style=label.style_label_down, color=color.rgb(230, 50, 50), textcolor=color.white, size=size.normal, textalign=text.align_center, tooltip=ttShort)

// ══════════════════════════════════════════════════════════
// VISUAL — TP / SL líneas y etiquetas
// ══════════════════════════════════════════════════════════
if senalLong and barstate.isconfirmed
    precioEntrada = open[1]
    nivelTP       = close[1] + puntosTP[1]
    nivelSL       = open[1]  - puntosSL[1]
    xIni          = bar_index - 1
    xFin          = bar_index + anchoProlongacion

    if mostrarTP_SL
        line.new(xIni, nivelTP,       xFin, nivelTP,       color=color.rgb(0, 200, 120),    width=2, style=line.style_dashed)
        line.new(xIni, nivelSL,       xFin, nivelSL,       color=color.rgb(230, 50, 50),    width=2, style=line.style_dashed)
        line.new(xIni, precioEntrada, xFin, precioEntrada, color=color.new(color.gray, 40), width=1, style=line.style_dotted)

    if mostrarEtiquetas
        label.new(xFin, nivelTP, "TP  +" + str.tostring(math.round(puntosTP[1], 1)), style=label.style_label_left, color=color.rgb(0, 200, 120), textcolor=color.white, size=size.small)
        label.new(xFin, nivelSL, "SL  -" + str.tostring(math.round(puntosSL[1], 1)), style=label.style_label_left, color=color.rgb(230, 50, 50),  textcolor=color.white, size=size.small)

if senalShort and barstate.isconfirmed
    precioEntrada = open[1]
    nivelTP       = close[1] - puntosTP[1]
    nivelSL       = open[1]  + puntosSL[1]
    xIni          = bar_index - 1
    xFin          = bar_index + anchoProlongacion

    if mostrarTP_SL
        line.new(xIni, nivelTP,       xFin, nivelTP,       color=color.rgb(0, 200, 120),    width=2, style=line.style_dashed)
        line.new(xIni, nivelSL,       xFin, nivelSL,       color=color.rgb(230, 50, 50),    width=2, style=line.style_dashed)
        line.new(xIni, precioEntrada, xFin, precioEntrada, color=color.new(color.gray, 40), width=1, style=line.style_dotted)

    if mostrarEtiquetas
        label.new(xFin, nivelTP, "TP  +" + str.tostring(math.round(puntosTP[1], 1)), style=label.style_label_left, color=color.rgb(0, 200, 120), textcolor=color.white, size=size.small)
        label.new(xFin, nivelSL, "SL  -" + str.tostring(math.round(puntosSL[1], 1)), style=label.style_label_left, color=color.rgb(230, 50, 50),  textcolor=color.white, size=size.small)

// ══════════════════════════════════════════════════════════
// ALERTAS
// ══════════════════════════════════════════════════════════
alertcondition(senalLong,               title="BUY Signal",        message="SMA8 Hook LONG | {{ticker}} | Precio: {{close}} | TF: {{interval}}")
alertcondition(senalShort,              title="SELL Signal",       message="SMA8 Hook SHORT | {{ticker}} | Precio: {{close}} | TF: {{interval}}")
alertcondition(senalLong or senalShort, title="BUY o SELL Signal", message="SMA8 Hook SENAL | {{ticker}} | Precio: {{close}} | TF: {{interval}}")
````
