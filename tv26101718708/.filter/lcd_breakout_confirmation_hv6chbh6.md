# LCD  Breakout Confirmation

- url: https://www.tradingview.com/script/Hv6cHBH6/
- type: indicator
- pine_id: PUB;be99530d442640ffb4bef55adfa2efad
- version: 7.0

## Description

LCD  Breakout Confirmation  Free Indicator

by @Miguelrosal1994

What this is / Qué es esto
Most traders enter breakouts blind. Price breaks a level — they buy or sell. Then price reverses and they wonder why.
This indicator doesn't predict. It measures. It tells you in real time whether the breakout you're watching has the three elements that separate institutional conviction from a retail trap.
La mayoría de los traders entran en breakouts a ciegas. El precio rompe un nivel — compran o venden. Luego el precio revierte y se preguntan por qué.
Este indicador no predice. Mide. Te dice en tiempo real si el breakout que estás viendo tiene los tres elementos que separan la convicción institucional de una trampa retail.

The three factors / Los tres factores
Factor 1 — Volume / Volumen
Volume is the fuel of any real move. When institutions enter, they can't hide — they need size, and size shows up in volume.
If the breakout candle has volume below the 20-bar average, nobody important is participating. That's a fakeout waiting to happen.
Default threshold: 1.2× average. The breakout bar must have at least 20% more volume than normal to score this factor.
El volumen es el combustible de cualquier movimiento real. Cuando los institucionales entran, no pueden esconderse — necesitan tamaño, y el tamaño aparece en el volumen.
Si la vela del breakout tiene volumen por debajo del promedio de 20 barras, nadie importante está participando. Eso es un fakeout esperando ocurrir.
Umbral por defecto: 1.2× el promedio. La vela de ruptura debe tener al menos 20% más volumen que lo normal para puntuar este factor.

Factor 2 — Candle Body / Cuerpo de vela
A real breakout closes far from the broken level. A fakeout touches the level with a long wick and closes back inside — the price tested but didn't commit.
The body is measured relative to the ATR (Average True Range) — the average movement of the instrument in recent bars. This makes the indicator adaptive: a strong body in a low-volatility environment is different from a strong body in a high-volatility one.
Default threshold: 0.4× ATR. The candle body must be at least 40% of the recent average range.
Un breakout real cierra lejos del nivel roto. Un fakeout toca el nivel con una mecha larga y cierra de vuelta adentro — el precio testeó pero no se comprometió.
El cuerpo se mide relativo al ATR (Average True Range) — el movimiento promedio del instrumento en barras recientes. Esto hace el indicador adaptativo: un cuerpo fuerte en un entorno de baja volatilidad es diferente a un cuerpo fuerte en uno de alta volatilidad.
Umbral por defecto: 0.4× ATR. El cuerpo de la vela debe ser al menos 40% del rango promedio reciente.

Factor 3 — Volume Delta (Tick Rule) / Delta de volumen
This is the most sophisticated factor. It doesn't just look at how much volume there was — it looks at where within the bar that volume was traded.
The Tick Rule splits each bar's volume into buy pressure and sell pressure based on where price closed within the range:

Close near the high → buyers were aggressive → positive delta
Close near the low → sellers were aggressive → negative delta
Close in the middle → equilibrium → delta near zero

Formula: delta = volume × (2 × (close - low) / (high - low) - 1)
If price breaks up but the delta is negative — sellers absorbed the move. That's a fakeout. If price breaks up and the delta is strongly positive — buyers drove the move. That's conviction.
Este es el factor más sofisticado. No solo mira cuánto volumen hubo — mira dónde dentro de la vela se negoció ese volumen.
La Tick Rule divide el volumen de cada vela en presión compradora y vendedora según dónde cerró el precio dentro del rango:

Cierre cerca del high → compradores agresivos → delta positivo
Cierre cerca del low → vendedores agresivos → delta negativo
Cierre en el medio → equilibrio → delta cerca de cero

Fórmula: delta = volumen × (2 × (close - low) / (high - low) - 1)
Si el precio rompe al alza pero el delta es negativo — los vendedores absorbieron el movimiento. Eso es un fakeout. Si el precio rompe al alza y el delta es fuertemente positivo — los compradores impulsaron el movimiento. Eso es convicción.

The score / La puntuación
🟢 3/3 — REAL BREAKOUT

All three factors confirm. Volume is there, the candle committed, and order flow agrees. This is where institutions moved. Pay attention.
Los tres factores confirman. El volumen está, la vela se comprometió y el flujo de órdenes concuerda. Aquí es donde se movieron los institucionales. Presta atención.
🟡 2/3 — POSSIBLE — wait

Two factors confirm, one doesn't. The move has partial conviction. Wait for the next candle to confirm or look for additional confluence before entering.
Dos factores confirman, uno no. El movimiento tiene convicción parcial. Espera que la siguiente vela confirme o busca confluencia adicional antes de entrar.
🔴 1/3 or less — FAKEOUT likely

The breakout lacks institutional backing. High probability of reclaim — price returning inside the broken level. Do not chase. Wait.
El breakout carece de respaldo institucional. Alta probabilidad de reclaim — el precio regresando dentro del nivel roto. No persigas. Espera.

How to read the panel / Cómo leer el panel
The panel in the top right always shows the last breakout that occurred — not the current bar. This is intentional. It tells you the quality of the most recent structural move so you can decide whether to trade the aftermath.
The three lines in the sub-panel show current bar values in real time — volume ratio, body ratio, and normalized delta. Watch these lines before a breakout: when volume starts rising and delta starts trending in one direction, something is about to happen.
El panel en la esquina superior derecha siempre muestra el último breakout que ocurrió — no la barra actual. Esto es intencional. Te dice la calidad del movimiento estructural más reciente para que puedas decidir si operar las consecuencias.
Las tres líneas en el sub-panel muestran valores de la barra actual en tiempo real — ratio de volumen, ratio de cuerpo y delta normalizado. Observa estas líneas antes de un breakout: cuando el volumen empieza a subir y el delta empieza a moverse en una dirección, algo está a punto de ocurrir.

How to use it / Cómo usarlo
Works on any instrument and any timeframe. No repainting. No lookahead bias.
Use green columns (3/3) as reference Order Blocks — levels where institutional conviction was confirmed. When price returns to those levels, that's where the reaction is most likely.
I don't give signals. I show where price has to define itself.
Funciona en cualquier instrumento y cualquier temporalidad. Sin repintado. Sin sesgo de lookahead.
Usa las columnas verdes (3/3) como Order Blocks de referencia — niveles donde se confirmó la convicción institucional. Cuando el precio regresa a esos niveles, ahí es donde la reacción es más probable.
No doy señales. Doy puntos donde el precio tiene que definir.

Want more free tools? Comment below. 👇

¿Quieres más herramientas gratuitas? Comenta abajo. 👇

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════
// LCD — Breakout Participation & Zone Quality · v1.3.3
// Break / Bounce Zone Marker
// by @Miguelrosal1994
//
// Objetivo:
//   No busca dar entradas automáticas.
//   Evalúa si una ruptura muestra suficiente participación y aceptación
//   para que el nivel roto merezca seguimiento como zona Break/Bounce.
//
// Lectura:
//   Score 4/4 = participación alta según las 4 reglas LCD.
//   Score 3/4 = ruptura de calidad.
//   Score 2/4 = evidencia mixta.
//   Score 0-1 = ruptura débil / ruido.
//
// IMPORTANTE:
//   · El score es heurístico: 4/4 NO significa 100% de probabilidad.
//   · Los 4 factores comparten información y no son pruebas independientes.
//   · "Pressure Proxy" NO es delta real de order flow.
//   · En símbolos con tick volume, "Volume" mide actividad relativa del feed.
//   · Si el símbolo realmente no ofrece volumen, Volume y Pressure quedan N/A; el score máximo observable será 2/4.
//
// CAMBIOS v1.3 — Audit + Visual System (07 sep 2026):
//   · Se elimina "Institutional" de nombre, verdicts y alertas.
//   · PDH/PDL usan HTF confirmado: [1] + lookahead_on.
//   · Se muestra syminfo.volumetype y se advierte cuando el volumen no es comparable.
//   · ATR de cada zona queda congelado al nacer: el criterio de fallo no cambia después.
//   · Los bounces ahora cuentan retests independientes: la zona debe separarse y rearmarse.
//   · "Require body direction" pasa a describir correctamente que solo controla el punto Body.
//   · Modo limpio real por defecto: componentes OFF y background OFF.
//   · Paleta unificada LCD con baja fatiga y adaptación claro/oscuro.
//   · Panel adaptativo a tema claro/oscuro con chart.bg_color / chart.fg_color.
//   · Menos saturación y opacidad en plots, niveles y marcadores para reducir fatiga visual.
//
// CAMBIO v1.3.1 — Familiar Green patch:
//   · El breakout 4/4 vuelve a VERDE para mantener continuidad con usuarios existentes.
//   · 3/4 permanece ORO.
//   · AZUL queda como acento analítico/de marca en panel y componentes.
//   · No cambia ninguna condición, score, alerta ni lógica de zona.
// CAMBIO v1.3.2 — Futures volume detection fix:
//   · volumeAvailable comprueba la serie volume directamente, no syminfo.volumetype.
//   · syminfo.volumetype queda solo como metadato descriptivo del feed.
//   · Un volumetype "n/a" ya no desactiva Volume/Pressure si el activo sí entrega volume.
//   · El panel distingue "type unspecified" de ausencia real de volumen.
//
// CAMBIO v1.3.3 — Visual reading notes (07 sep 2026):
//   · Guía de lectura visual para publicación.
//   · No cambia score, zona, alertas ni umbrales.
//   · 4/4 = high participation. 3/4 = quality breakout.
//   · 2/4 or lower = no new zone.
//   · Trade the retest, not the circle.
//
// No se modifican los umbrales base de breakout/score de v1.2.
// Sí cambia el ciclo de vida de la zona (ATR congelado + retests independientes).
// ════════════════════════════════════════════════════════════════

indicator("LCD — Breakout Participation & Zone Quality",
     shorttitle    = "LCD · B/B Zone v1.3.3",
     overlay       = false,
     max_bars_back = 500)

// ──────────────────────────────────────────
// INPUTS — LEVEL / STRUCTURE
// ──────────────────────────────────────────
grp_level = "Level / Structure"
levelMode = input.string("Rolling", "Level mode",
     options = ["Rolling", "Previous Day"],
     group   = grp_level,
     tooltip = "Rolling = high/low de las últimas N velas. Previous Day = PDH/PDL.")
structureLookback = input.int(10, "Rolling structure lookback", minval=3, maxval=100, group=grp_level)
zoneMinScore   = input.int(3, "Min score to create Break/Bounce zone", minval=2, maxval=4, group=grp_level)
zoneExpiryBars = input.int(40, "Zone expiry (bars)", minval=5, maxval=300, group=grp_level)
zoneFailATR    = input.float(0.10, "Zone fail tolerance (× zone ATR)", minval=0.0, maxval=1.0, step=0.05, group=grp_level,
     tooltip="La zona falla solo si el cierre atraviesa el nivel por más de este margen calculado con el ATR congelado cuando nació la zona.")
zoneRearmATR   = input.float(0.25, "Retest re-arm distance (× zone ATR)", minval=0.05, maxval=2.0, step=0.05, group=grp_level,
     tooltip="Después de un bounce, el precio debe alejarse al menos esta distancia antes de que un nuevo contacto cuente como otro retest independiente.")
showZoneOnChart = input.bool(true, "Plot active zone on price chart", group=grp_level,
     tooltip="Dibuja el nivel operativo del último breakout válido en el gráfico principal.")
confirmOnClose = input.bool(true, "Confirmar señales al cierre", group=grp_level,
     tooltip="ON: breakout, score, bounce y fail se confirman únicamente al cierre de vela. OFF: evaluación intrabar; el valor puede cambiar hasta el cierre. Para alertas, usar ON.")

// ──────────────────────────────────────────
// INPUTS — PARTICIPATION
// ──────────────────────────────────────────
grp_vol = "1) Volume"
volLookback   = input.int(20,    "Volume lookback previous bars", minval=5, maxval=100, group=grp_vol)
volMultiplier = input.float(1.20, "Volume multiplier (× previous avg)", minval=1.0, maxval=5.0, step=0.05, group=grp_vol)

grp_body = "2) Candle Body"
bodyATRmult = input.float(0.40, "Min body (× ATR)", minval=0.05, maxval=3.0, step=0.05, group=grp_body)
requireBodyDirection = input.bool(true, "Body point requires breakout direction", group=grp_body,
     tooltip="ON: para sumar el punto Body, el cuerpo debe cerrar en la dirección de la ruptura. No bloquea por sí solo la creación de zona si los otros factores alcanzan el score mínimo.")

grp_pressure = "3) Pressure Proxy"
pressureLookback = input.int(5, "Pressure lookback (bars)", minval=1, maxval=20, group=grp_pressure,
     tooltip="Acumula presión proxy sobre N velas. 1 = más rápido; 5 = más suave.")
pressureThresh = input.float(0.10, "Pressure threshold", minval=0.0, maxval=1.0, step=0.05, group=grp_pressure,
     tooltip="0.10 exige presión clara. 0.00 solo exige signo positivo/negativo.")

grp_ext = "4) Close Extension"
closeExtATR = input.float(0.10, "Min close extension beyond level (× ATR)", minval=0.0, maxval=2.0, step=0.05, group=grp_ext,
     tooltip="Mide aceptación: cuánto cierra la vela fuera del nivel roto.")

grp_vis = "Visual"
showBgColor    = input.bool(false, "Background color by score", group=grp_vis,
     tooltip="OFF por defecto: si este indicador corre junto a Módulo B u otros en el mismo chart, el fondo sombreado compite visualmente en vez de ayudar. Actívalo solo si usas este indicador solo.")
showPanel      = input.bool(true, "Show panel", group=grp_vis)
showComponents = input.bool(false, "Show component lines", group=grp_vis,
     tooltip="OFF por defecto: modo limpio. Activa las líneas solo cuando quieras auditar Volume / Body / Pressure / Acceptance.")

// ──────────────────────────────────────────
// BASE DATA
// ──────────────────────────────────────────
atr  = ta.atr(14)
body = math.abs(close - open)
rng  = high - low

// El tipo de volumen depende del feed: base / quote / tick / n/a.
volumeType      = syminfo.volumetype
volumeAvailable = not na(volume)

// Volumen medio PREVIO, no contaminado por la vela actual.
volAvgPrev = volumeAvailable ? ta.sma(volume[1], volLookback) : na
volRatio   = volumeAvailable and not na(volAvgPrev) and volAvgPrev > 0 ? volume / volAvgPrev : na

// Cuerpo relativo.
bodyRatio = atr > 0 ? body / atr : 0.0

// Niveles rolling: siempre excluyen la vela actual.
rollingHigh = ta.highest(high[1], structureLookback)
rollingLow  = ta.lowest(low[1],  structureLookback)

// Previous Day confirmado. [1] + lookahead_on devuelve el último valor diario cerrado.
pdh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)
pdl = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

refHigh = levelMode == "Previous Day" ? pdh : rollingHigh
refLow  = levelMode == "Previous Day" ? pdl : rollingLow

// ──────────────────────────────────────────
// BREAKOUT DETECTION — sin repintado si confirmOnClose
// ──────────────────────────────────────────
barOK = not confirmOnClose or barstate.isconfirmed

breakoutUp   = barOK and not na(refHigh) and high > refHigh and close > refHigh
breakoutDown = barOK and not na(refLow)  and low  < refLow  and close < refLow
isBreakout   = breakoutUp or breakoutDown
dir = breakoutUp ? 1 : breakoutDown ? -1 : 0
brokenLevel = breakoutUp ? refHigh : breakoutDown ? refLow : na

// ──────────────────────────────────────────
// FACTOR 1 — VOLUME PARTICIPATION
// ──────────────────────────────────────────
volScore = isBreakout and volumeAvailable and not na(volRatio) and volRatio >= volMultiplier

// ──────────────────────────────────────────
// FACTOR 2 — BODY / INTENT
// ──────────────────────────────────────────
bodyDirectionOK = dir == 1 ? close > open : dir == -1 ? close < open : false
bodyScore = isBreakout and bodyRatio >= bodyATRmult and (not requireBodyDirection or bodyDirectionOK)

// ──────────────────────────────────────────
// FACTOR 3 — PRESSURE PROXY
// ──────────────────────────────────────────
barPressure(idx) =>
    h   = high[idx]
    l   = low[idx]
    c   = close[idx]
    v   = volume[idx]
    r   = h - l
    r > 0 ? v * (2 * (c - l) / r - 1) : 0.0

accPressure = 0.0
for i = 0 to pressureLookback - 1
    accPressure += barPressure(i)

pressureDen  = volAvgPrev > 0 ? volAvgPrev * pressureLookback : na
normPressure = not na(pressureDen) and pressureDen > 0 ? accPressure / pressureDen : 0.0

pressureScore = isBreakout and volumeAvailable and (
     (dir == 1 and normPressure >= pressureThresh) or
     (dir == -1 and normPressure <= -pressureThresh))

// ──────────────────────────────────────────
// FACTOR 4 — ACCEPTANCE / CLOSE EXTENSION
// ──────────────────────────────────────────
closeExtRatio = isBreakout and atr > 0 ?
     (dir == 1 ? (close - brokenLevel) / atr : (brokenLevel - close) / atr) : 0.0
closeExtScore = isBreakout and closeExtRatio >= closeExtATR

// ──────────────────────────────────────────
// TOTAL SCORE 0–4
// ──────────────────────────────────────────
score = int(
     (volScore      ? 1 : 0) +
     (bodyScore     ? 1 : 0) +
     (pressureScore ? 1 : 0) +
     (closeExtScore ? 1 : 0))

qualityBreak = isBreakout and score >= zoneMinScore

// ──────────────────────────────────────────
// BREAK / BOUNCE ZONE TRACKING
// ──────────────────────────────────────────
var bool  hasBreakout       = false
var int   lastScore         = na
var int   lastDir           = 0
var float lastLevel         = na
var float lastVolRatio      = na
var float lastBodyRatio     = na
var float lastPressure      = na
var float lastCloseExt      = na
var bool  lastVolScore      = false
var bool  lastBodyScore     = false
var bool  lastPressureScore = false
var bool  lastExtScore      = false

var float  zoneLevel        = na
var float  zoneATR          = na
var int    zoneDir          = 0
var int    zoneBar          = na
var int    zoneScore        = na
var int    zoneBounces      = 0
var bool   zoneRetestArmed  = false
var string zoneState        = "NO ZONE"

if isBreakout
    hasBreakout       := true
    lastScore         := score
    lastDir           := dir
    lastLevel         := brokenLevel
    lastVolRatio      := volRatio
    lastBodyRatio     := bodyRatio
    lastPressure      := normPressure
    lastCloseExt      := closeExtRatio
    lastVolScore      := volScore
    lastBodyScore     := bodyScore
    lastPressureScore := pressureScore
    lastExtScore      := closeExtScore

if qualityBreak
    zoneLevel       := brokenLevel
    zoneATR         := atr
    zoneDir         := dir
    zoneBar         := bar_index
    zoneScore       := score
    zoneBounces     := 0
    zoneRetestArmed := false
    zoneState       := "ACTIVE"

zoneExists = not na(zoneLevel) and not na(zoneBar) and not na(zoneATR)
zoneAge    = zoneExists ? bar_index - zoneBar : na
zoneLive   = zoneExists and zoneAge <= zoneExpiryBars and zoneState != "FAILED" and zoneState != "EXPIRED"

// La tolerancia usa el ATR congelado al crear la zona.
zoneFail = zoneLive and zoneAge > 0 and barOK and (
     (zoneDir == 1 and close < zoneLevel - zoneFailATR * zoneATR) or
     (zoneDir == -1 and close > zoneLevel + zoneFailATR * zoneATR))

// Un nuevo retest solo puede contarse después de que el precio se haya alejado.
zoneRearm = zoneLive and zoneAge > 0 and not zoneRetestArmed and barOK and (
     (zoneDir == 1 and close >= zoneLevel + zoneRearmATR * zoneATR) or
     (zoneDir == -1 and close <= zoneLevel - zoneRearmATR * zoneATR))

zoneBounce = zoneLive and zoneAge > 0 and zoneRetestArmed and barOK and not zoneFail and (
     (zoneDir == 1 and low <= zoneLevel and close >= zoneLevel) or
     (zoneDir == -1 and high >= zoneLevel and close <= zoneLevel))

if zoneFail
    zoneState       := "FAILED"
    zoneRetestArmed := false
else if zoneBounce
    zoneBounces     += 1
    zoneState       := "BOUNCE ×" + str.tostring(zoneBounces)
    zoneRetestArmed := false
else if zoneRearm
    zoneRetestArmed := true
else if zoneExists and zoneAge > zoneExpiryBars and zoneState != "FAILED"
    zoneState       := "EXPIRED"
    zoneRetestArmed := false

// ──────────────────────────────────────────
// COLORS — LCD VISUAL SYSTEM v1.3.3
// Verde = 4/4 / breakout de máxima calidad (continuidad visual con versiones públicas previas).
// Oro = 3/4 / breakout de calidad.
// Azul = acento analítico/de marca en panel y componentes, no sustituye la señal visual familiar.
// Verde/rojo siguen comunicando soporte/resistencia en la zona activa.
// Neutros = chart.fg_color para adaptarse al tema claro/oscuro.
// ──────────────────────────────────────────
col_blue    = #4A7FC1
col_gold    = #C8954A
col_mid     = #8A7D6B
col_softred = #A65A5A
col_long    = #2E7D32
col_short   = #A32D2D
col_text    = chart.fg_color
col_muted   = color.new(chart.fg_color, 55)
col_neutral = color.new(chart.fg_color, 72)
col_frame   = color.new(chart.fg_color, 88)
col_panel   = color.new(chart.bg_color, 4)
col_header  = color.new(col_blue, 90)

// Score: 4/4 conserva el verde histórico/familiar; 3/4 usa oro.
// El azul queda como color de marca/analítico para no romper el hábito visual del usuario.
scoreColor = score >= 4 ? col_long : score == 3 ? col_gold : score == 2 ? col_mid : col_softred
zoneColor  = zoneDir == 1 ? color.new(col_long, 22) : zoneDir == -1 ? color.new(col_short, 22) : col_muted

// Fondos extremadamente suaves; OFF por defecto.
col_bg_4 = color.new(col_long, 94)
col_bg_3 = color.new(col_gold, 95)
col_bg_2 = color.new(col_mid, 96)
col_bg_1 = color.new(col_softred, 96)

// ──────────────────────────────────────────
// PLOTS — PANE
// ──────────────────────────────────────────
plot(isBreakout ? score : na,
     "Breakout Quality Score",
     color     = color.new(scoreColor, 24),
     style     = plot.style_columns,
     linewidth = 2)

// Modo audit opcional: líneas neutras, deliberadamente discretas.
plot(showComponents ? volRatio      : na, "Vol / Prev Avg",       color=col_neutral, linewidth=1, style=plot.style_line)
plot(showComponents ? bodyRatio     : na, "Body / ATR",           color=col_neutral, linewidth=1, style=plot.style_stepline)
plot(showComponents ? normPressure  : na, "Pressure Proxy",       color=col_neutral, linewidth=1, style=plot.style_circles)
plot(showComponents ? closeExtRatio : na, "Close Extension / ATR", color=col_neutral, linewidth=1, style=plot.style_line)

hline(4, "4/4 · High participation", color=color.new(col_long, 76), linestyle=hline.style_dashed)
hline(3, "3/4 · Quality breakout",  color=color.new(col_gold, 80), linestyle=hline.style_dashed)
hline(0, "Zero",                    color=color.new(chart.fg_color, 90), linestyle=hline.style_solid)

bgcolor(showBgColor and isBreakout and score >= 4 ? col_bg_4 :
        showBgColor and isBreakout and score == 3 ? col_bg_3 :
        showBgColor and isBreakout and score == 2 ? col_bg_2 :
        showBgColor and isBreakout and score <= 1 ? col_bg_1 : na,
        title="Score background")

// ──────────────────────────────────────────
// PRICE CHART — ACTIVE ZONE + QUALITY MARKERS
// ──────────────────────────────────────────
plot(showZoneOnChart and zoneLive ? zoneLevel : na,
     "Active Break/Bounce Zone",
     color         = zoneColor,
     linewidth     = 2,
     style         = plot.style_linebr,
     force_overlay = true)

// Calidad se comunica con verde/oro. La posición del marcador comunica dirección.
// El 4/4 mantiene el verde por continuidad visual con usuarios ya familiarizados con LCD.
plotshape(isBreakout and score >= 4 and dir == 1,
     title="High Participation Breakout Up 4/4", style=shape.circle,
     location=location.abovebar, color=color.new(col_long, 6), size=size.tiny,
     text="4", textcolor=color.white, force_overlay=true)
plotshape(isBreakout and score >= 4 and dir == -1,
     title="High Participation Breakout Down 4/4", style=shape.circle,
     location=location.belowbar, color=color.new(col_long, 6), size=size.tiny,
     text="4", textcolor=color.white, force_overlay=true)
plotshape(isBreakout and score == 3 and dir == 1,
     title="Quality Breakout Up 3/4", style=shape.circle,
     location=location.abovebar, color=color.new(col_gold, 10), size=size.tiny,
     text="3", textcolor=#161B22, force_overlay=true)
plotshape(isBreakout and score == 3 and dir == -1,
     title="Quality Breakout Down 3/4", style=shape.circle,
     location=location.belowbar, color=color.new(col_gold, 10), size=size.tiny,
     text="3", textcolor=#161B22, force_overlay=true)

// ──────────────────────────────────────────
// PANEL — compacto, adaptativo y de baja fatiga
// ──────────────────────────────────────────
if barstate.islast and showPanel
    var table panel = table.new(position.top_right, 2, 11,
         bgcolor=col_panel, border_width=0, frame_color=col_frame, frame_width=1)

    labelSz = size.tiny
    valueSz = size.small

    table.cell(panel, 0, 0, "LCD",      text_color=col_text, text_size=valueSz, bgcolor=col_header)
    table.cell(panel, 1, 0, "B/B ZONE", text_color=col_gold, text_size=valueSz, bgcolor=col_header)

    modeS = levelMode == "Previous Day" ? "PDH / PDL" : "Rolling " + str.tostring(structureLookback)
    table.cell(panel, 0, 1, "Mode", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 1, modeS,  text_color=col_text,  text_size=valueSz)

    bkS = not hasBreakout ? "No break" : lastDir == 1 ? "▲ Break Up" : "▼ Break Down"
    bkC = not hasBreakout ? col_muted : lastDir == 1 ? col_long : col_short
    table.cell(panel, 0, 2, "Last break", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 2, bkS,          text_color=bkC,       text_size=valueSz)

    scoreS = not hasBreakout ? "—" : str.tostring(lastScore) + " / 4" + (volumeAvailable ? "" : "*")
    scoreC = not hasBreakout ? col_muted : lastScore >= 4 ? col_long : lastScore == 3 ? col_gold : lastScore == 2 ? col_mid : col_softred
    table.cell(panel, 0, 3, "Score", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 3, scoreS,  text_color=scoreC,     text_size=valueSz)

    v1S = not volumeAvailable ? "N/A" : not hasBreakout ? "—" : (lastVolScore ? "✓ " : "· ") + str.tostring(math.round(lastVolRatio, 2)) + "×"
    v1C = not volumeAvailable ? col_muted : not hasBreakout ? col_muted : lastVolScore ? col_blue : col_muted
    table.cell(panel, 0, 4, "Volume", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 4, v1S,      text_color=v1C,       text_size=valueSz)

    v2S = not hasBreakout ? "—" : (lastBodyScore ? "✓ " : "· ") + str.tostring(math.round(lastBodyRatio, 2)) + " ATR"
    table.cell(panel, 0, 5, "Body", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 5, v2S,    text_color=lastBodyScore ? col_blue : col_muted, text_size=valueSz)

    v3S = not volumeAvailable ? "N/A" : not hasBreakout ? "—" : (lastPressureScore ? "✓ " : "· ") + str.tostring(math.round(lastPressure, 3))
    table.cell(panel, 0, 6, "Pressure*", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 6, v3S,         text_color=lastPressureScore ? col_blue : col_muted, text_size=valueSz)

    v4S = not hasBreakout ? "—" : (lastExtScore ? "✓ " : "· ") + str.tostring(math.round(lastCloseExt, 2)) + " ATR"
    table.cell(panel, 0, 7, "Acceptance", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 7, v4S,          text_color=lastExtScore ? col_blue : col_muted, text_size=valueSz)

    verdict = not hasBreakout ? "WAITING" :
         lastScore >= 4 ? "HIGH PARTICIPATION" :
         lastScore == 3 ? "QUALITY BREAKOUT" :
         lastScore == 2 ? "MIXED" :
         "WEAK / NOISE"
    table.cell(panel, 0, 8, "Verdict", text_color=col_muted, text_size=labelSz, bgcolor=col_header)
    table.cell(panel, 1, 8, verdict,   text_color=scoreC,     text_size=valueSz, bgcolor=col_header)

    zoneS = not zoneExists ? "No zone" :
         zoneState + " · " + (zoneDir == 1 ? "support" : "resistance") + " · age " + str.tostring(zoneAge)
    zoneC = not zoneExists ? col_muted : zoneState == "FAILED" ? col_softred : zoneState == "EXPIRED" ? col_muted : zoneDir == 1 ? col_long : col_short
    table.cell(panel, 0, 9, "B/B Zone", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 9, zoneS,      text_color=zoneC,     text_size=valueSz)

    volTypeS = volumeType == "tick" ? "TICK volume" : volumeType == "base" ? "BASE volume" : volumeType == "quote" ? "QUOTE volume" : volumeAvailable ? "VOLUME · type unspecified" : "VOLUME N/A"
    dataS = volTypeS + " · pressure proxy"
    table.cell(panel, 0, 10, "Data", text_color=col_muted, text_size=labelSz)
    table.cell(panel, 1, 10, dataS,   text_color=col_muted, text_size=labelSz)

// ──────────────────────────────────────────
// ALERTS — descriptivas, no entradas
// ──────────────────────────────────────────
alertcondition(isBreakout and score >= 4,
     title   = "High Participation Breakout 4/4",
     message = "LCD · HIGH PARTICIPATION BREAKOUT 4/4 · {{ticker}} · {{close}}")
alertcondition(isBreakout and score == 3,
     title   = "Quality Breakout 3/4",
     message = "LCD · QUALITY BREAKOUT 3/4 · {{ticker}} · {{close}}")
alertcondition(zoneBounce,
     title   = "Break/Bounce Zone Retest Holding",
     message = "LCD · BREAK/BOUNCE ZONE RETEST HOLDING · {{ticker}} · {{close}}")
alertcondition(zoneFail,
     title   = "Break/Bounce Zone Failed",
     message = "LCD · BREAK/BOUNCE ZONE FAILED · {{ticker}} · {{close}}")
````
