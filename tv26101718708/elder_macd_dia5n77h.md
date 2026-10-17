# Elder MACD

- url: https://www.tradingview.com/script/dIa5N77h/
- type: indicator
- pine_id: PUB;f29c7cbaf4634519b9c20c24e0b99c26
- version: 1.0

## Description

In this script we will see the signals of the Alexander Elder strategy, Here in green we see the buy signals and in red the sell signals, the orange one's means that the divergence could work but you need to be sure of it.

## Source Code

````pine
//@version=5
indicator("Elder – Divergencia Histograma MACD", overlay=true, shorttitle="Elder DIV")

// ─── PARAMETROS MACD ───────────────────────────────────────
fastLen  = input.int(12,   title="EMA Rapida", minval=1, group="MACD")
slowLen  = input.int(26,   title="EMA Lenta",  minval=1, group="MACD")
sigLen   = input.int(9,    title="Senal",      minval=1, group="MACD")

// ─── FILTROS MODO 1 ────────────────────────────────────────
minDist  = input.float(0.05, title="Distancia minima entre minimos/maximos",
                         minval=0.0, step=0.01, group="Modo 1 – Clasico")
minDepth = input.float(0.05, title="Profundidad minima",
                         minval=0.0, step=0.01, group="Modo 1 – Clasico")

// ─── FILTROS MODO 2 ────────────────────────────────────────
modo2On    = input.bool(true, title="Activar modo 2 (divergencia sin cruce de 0 intermedio)",
                         group="Modo 2 – Sin cruce intermedio")
minBounce2 = input.float(0.10, title="Rebote minimo intermedio sin cruzar 0",
                         minval=0.0, step=0.01, group="Modo 2 – Sin cruce intermedio")
minDist2   = input.float(0.08, title="Distancia minima entre los dos minimos (modo 2)",
                         minval=0.0, step=0.01, group="Modo 2 – Sin cruce intermedio")
minDepth2  = input.float(0.08, title="Profundidad minima al cruzar 0 tras el 2o minimo",
                         minval=0.0, step=0.01, group="Modo 2 – Sin cruce intermedio")

// ─── HISTOGRAMA MACD ───────────────────────────────────────
[_, _, hist] = ta.macd(close, fastLen, slowLen, sigLen)

histTrough = hist[1] < hist[2] and hist[1] < hist[0]
histPeak   = hist[1] > hist[2] and hist[1] > hist[0]

// ══════════════════════════════════════════════════════════
//  MODO 1 ALCISTA — Maquina de estados
// ══════════════════════════════════════════════════════════
var int   b1_state        = 0
var float b1_low1         = 0.0
var float b1_cmax         = 0.0
var float b1_low2         = 0.0
var bool  b1_green_fired  = false   // NUEVO: ha salido ya la señal verde
var float b1_trough_c     = 0.0    // NUEVO: valor del trough C donde salio el verde

// ══════════════════════════════════════════════════════════
//  MODO 1 BAJISTA — Maquina de estados
// ══════════════════════════════════════════════════════════
var int   r1_state        = 0
var float r1_high1        = 0.0
var float r1_cmin         = 0.0
var float r1_high2        = 0.0
var bool  r1_green_fired  = false   // NUEVO
var float r1_peak_c       = 0.0    // NUEVO

// ══════════════════════════════════════════════════════════
//  MODO 2 ALCISTA
// ══════════════════════════════════════════════════════════
var float bull2_low1       = na
var float bull2_bounce_max = 0.0
var bool  bull2_got_low2   = false
var float bull2_low2       = na
var float bull2_cross_max  = 0.0

// ══════════════════════════════════════════════════════════
//  MODO 2 BAJISTA
// ══════════════════════════════════════════════════════════
var float bear2_high1      = na
var float bear2_bounce_min = 0.0
var bool  bear2_got_high2  = false
var float bear2_high2      = na
var float bear2_cross_min  = 0.0

bullSignal        = false
bearSignal        = false
bullSignal2       = false
bearSignal2       = false
bullRecovSignal   = false   // NUEVO: naranja alcista (recuperacion)
bearRecovSignal   = false   // NUEVO: naranja bajista (recuperacion)

// ══════════════════════════════════════════════════════════
//  LOGICA MODO 1 ALCISTA
// ══════════════════════════════════════════════════════════
if b1_state == 0
    if hist < 0
        b1_state       := 1
        b1_low1        := hist
        b1_green_fired := false

else if b1_state == 1
    if hist < 0
        b1_low1 := math.min(b1_low1, hist)
    else
        b1_state := 2
        b1_cmax  := hist

else if b1_state == 2
    if hist >= 0
        b1_cmax := math.max(b1_cmax, hist)
    else
        if b1_cmax >= minDepth
            b1_state       := 3
            b1_low2        := hist
            b1_green_fired := false
        else
            b1_state := 1
            b1_low1  := math.min(b1_low1, hist)

else if b1_state == 3
    if hist < 0
        b1_low2 := math.min(b1_low2, hist)

        // ── SEÑAL VERDE: primer trough de C por encima de A ──
        if histTrough and hist[1] > b1_low1 and not b1_green_fired
            dif = hist[1] - b1_low1
            dep = -hist[1]
            if dif >= minDist and dep >= minDepth
                bullSignal     := true
                b1_green_fired := true
                b1_trough_c    := hist[1]   // guardamos el nivel de C

        // ── SEÑAL NARANJA: recuperacion tras caida post-verde ──
        // Condicion: verde ya salio, hay un nuevo trough por encima de A
        // pero por debajo del trough C original (fue un poco mas abajo),
        // y ahora vuelve a girar hacia arriba
        if histTrough and hist[1] > b1_low1 and b1_green_fired
            if hist[1] < b1_trough_c  // bajo mas que C pero no tanto como A
                dif = hist[1] - b1_low1
                dep = -hist[1]
                if dif >= minDist and dep >= minDepth
                    bullRecovSignal := true
                    b1_trough_c     := hist[1]   // actualizamos C al nuevo fondo

    else
        // Cruza 0: reset para la siguiente divergencia
        b1_state       := 2
        b1_cmax        := hist
        b1_low1        := b1_low2
        b1_low2        := 0.0
        b1_green_fired := false
        b1_trough_c    := 0.0

// ══════════════════════════════════════════════════════════
//  LOGICA MODO 1 BAJISTA
// ══════════════════════════════════════════════════════════
if r1_state == 0
    if hist > 0
        r1_state       := 1
        r1_high1       := hist
        r1_green_fired := false

else if r1_state == 1
    if hist > 0
        r1_high1 := math.max(r1_high1, hist)
    else
        r1_state := 2
        r1_cmin  := hist

else if r1_state == 2
    if hist <= 0
        r1_cmin := math.min(r1_cmin, hist)
    else
        if r1_cmin <= -minDepth
            r1_state       := 3
            r1_high2       := hist
            r1_green_fired := false
        else
            r1_state := 1
            r1_high1 := math.max(r1_high1, hist)

else if r1_state == 3
    if hist > 0
        r1_high2 := math.max(r1_high2, hist)

        // ── SEÑAL ROJA: primer peak de C por debajo de A ──
        if histPeak and hist[1] < r1_high1 and not r1_green_fired
            dif = r1_high1 - hist[1]
            dep = hist[1]
            if dif >= minDist and dep >= minDepth
                bearSignal     := true
                r1_green_fired := true
                r1_peak_c      := hist[1]

        // ── SEÑAL NARANJA BAJISTA: recuperacion tras subida post-roja ──
        if histPeak and hist[1] < r1_high1 and r1_green_fired
            if hist[1] > r1_peak_c  // subio mas que C pero no tanto como A
                dif = r1_high1 - hist[1]
                dep = hist[1]
                if dif >= minDist and dep >= minDepth
                    bearRecovSignal := true
                    r1_peak_c       := hist[1]

    else
        r1_state       := 2
        r1_cmin        := hist
        r1_high1       := r1_high2
        r1_high2       := 0.0
        r1_green_fired := false
        r1_peak_c      := 0.0

// ══════════════════════════════════════════════════════════
//  LOGICA MODO 2 ALCISTA
// ══════════════════════════════════════════════════════════
if modo2On
    if not na(bull2_low1) and not bull2_got_low2 and hist >= minDepth2
        bull2_low1       := na
        bull2_bounce_max := 0.0
        bull2_low2       := na

    if histTrough and hist[1] < 0 and not bull2_got_low2
        bull2_low1       := hist[1]
        bull2_bounce_max := 0.0
        bull2_cross_max  := 0.0
        bull2_low2       := na

    if not na(bull2_low1) and not bull2_got_low2 and hist < 0
        bull2_bounce_max := math.max(bull2_bounce_max, hist - bull2_low1)

    if histTrough and hist[1] < 0 and not bull2_got_low2 and not na(bull2_low1)
        diferencia2 = hist[1] - bull2_low1
        if hist[1] > bull2_low1 and diferencia2 >= minDist2 and bull2_bounce_max >= minBounce2
            bull2_got_low2  := true
            bull2_low2      := hist[1]
            bull2_cross_max := 0.0
        else
            bull2_low1       := hist[1]
            bull2_bounce_max := 0.0

    if bull2_got_low2 and hist > 0
        bull2_cross_max := math.max(bull2_cross_max, hist)
        if bull2_cross_max >= minDepth2
            bullSignal2      := true
            bull2_got_low2   := false
            bull2_low1       := na
            bull2_low2       := na
            bull2_bounce_max := 0.0
            bull2_cross_max  := 0.0

    if bull2_got_low2 and histTrough and hist[1] < 0
        if hist[1] < bull2_low1
            bull2_got_low2   := false
            bull2_low1       := hist[1]
            bull2_low2       := na
            bull2_bounce_max := 0.0
            bull2_cross_max  := 0.0

// ══════════════════════════════════════════════════════════
//  LOGICA MODO 2 BAJISTA
// ══════════════════════════════════════════════════════════
if modo2On
    if not na(bear2_high1) and not bear2_got_high2 and hist <= -minDepth2
        bear2_high1      := na
        bear2_bounce_min := 0.0
        bear2_high2      := na

    if histPeak and hist[1] > 0 and not bear2_got_high2
        bear2_high1      := hist[1]
        bear2_bounce_min := 0.0
        bear2_cross_min  := 0.0
        bear2_high2      := na

    if not na(bear2_high1) and not bear2_got_high2 and hist > 0
        bear2_bounce_min := math.min(bear2_bounce_min, hist - bear2_high1)

    if histPeak and hist[1] > 0 and not bear2_got_high2 and not na(bear2_high1)
        diferencia2 = bear2_high1 - hist[1]
        if hist[1] < bear2_high1 and diferencia2 >= minDist2 and bear2_bounce_min <= -minBounce2
            bear2_got_high2 := true
            bear2_high2     := hist[1]
            bear2_cross_min := 0.0
        else
            bear2_high1      := hist[1]
            bear2_bounce_min := 0.0

    if bear2_got_high2 and hist < 0
        bear2_cross_min := math.min(bear2_cross_min, hist)
        if bear2_cross_min <= -minDepth2
            bearSignal2      := true
            bear2_got_high2  := false
            bear2_high1      := na
            bear2_high2      := na
            bear2_bounce_min := 0.0
            bear2_cross_min  := 0.0

    if bear2_got_high2 and histPeak and hist[1] > 0
        if hist[1] > bear2_high1
            bear2_got_high2  := false
            bear2_high1      := hist[1]
            bear2_high2      := na
            bear2_bounce_min := 0.0
            bear2_cross_min  := 0.0

// ══════════════════════════════════════════════════════════
//  SEÑALES VISUALES
// ══════════════════════════════════════════════════════════

// Verde alcista — aparece en el trough de C
plotshape(bullSignal,
     title    = "Divergencia Alcista (modo 1)",
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(color.green, 0),
     textcolor= color.white,
     text     = "DIV+",
     size     = size.normal)

// Roja bajista — aparece en el peak de C
plotshape(bearSignal,
     title    = "Divergencia Bajista (modo 1)",
     style    = shape.labeldown,
     location = location.abovebar,
     color    = color.new(color.red, 0),
     textcolor= color.white,
     text     = "DIV-",
     size     = size.normal)

// Naranja alcista — divergencia que parecia invalidada pero se recupera
plotshape(bullRecovSignal,
     title    = "Divergencia Alcista Recuperada",
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(color.orange, 0),
     textcolor= color.white,
     text     = "DIV+",
     size     = size.normal)

// Naranja bajista — divergencia que parecia invalidada pero se recupera
plotshape(bearRecovSignal,
     title    = "Divergencia Bajista Recuperada",
     style    = shape.labeldown,
     location = location.abovebar,
     color    = color.new(color.orange, 0),
     textcolor= color.white,
     text     = "DIV-",
     size     = size.normal)

// Teal modo 2 alcista
plotshape(bullSignal2,
     title    = "Divergencia Alcista (modo 2)",
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(color.teal, 0),
     textcolor= color.white,
     text     = "DIV+(2)",
     size     = size.normal)

// Teal modo 2 bajista
plotshape(bearSignal2,
     title    = "Divergencia Bajista (modo 2)",
     style    = shape.labeldown,
     location = location.abovebar,
     color    = color.new(color.teal, 0),
     textcolor= color.white,
     text     = "DIV-(2)",
     size     = size.normal)

// ══════════════════════════════════════════════════════════
//  ALERTAS
// ══════════════════════════════════════════════════════════
alertcondition(bullSignal,
     title   = "Elder – Divergencia ALCISTA",
     message = "DIV+ Divergencia Alcista — {{ticker}} en {{interval}}")
alertcondition(bearSignal,
     title   = "Elder – Divergencia BAJISTA",
     message = "DIV- Divergencia Bajista — {{ticker}} en {{interval}}")
alertcondition(bullRecovSignal,
     title   = "Elder – Divergencia ALCISTA recuperada",
     message = "DIV+ Divergencia Alcista recuperada — {{ticker}} en {{interval}}")
alertcondition(bearRecovSignal,
     title   = "Elder – Divergencia BAJISTA recuperada",
     message = "DIV- Divergencia Bajista recuperada — {{ticker}} en {{interval}}")
alertcondition(bullSignal2,
     title   = "Elder – Divergencia ALCISTA modo 2",
     message = "DIV+(2) Divergencia Alcista modo 2 — {{ticker}} en {{interval}}")
alertcondition(bearSignal2,
     title   = "Elder – Divergencia BAJISTA modo 2",
     message = "DIV-(2) Divergencia Bajista modo 2 — {{ticker}} en {{interval}}")
````
