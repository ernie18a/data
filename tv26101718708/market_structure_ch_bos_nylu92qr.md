# Market Structure CH / BOS

- url: https://www.tradingview.com/script/NYlu92QR-Market-Structure-CH-BOS/
- type: indicator
- pine_id: PUB;a39adef094c34ccdbc97af6b9ba67815
- version: 6.0

## Description

Market Structure CH / BOS
Automatic intraday market structure mapping — Change of Character (CH) and Break of Structure (BOS) — built for the New York regular session.

This indicator tracks the live trend structure of any intraday chart using a state machine that follows two key levels at all times:

BOS (Break of Structure): the most recent structural extreme in the direction of the trend. A close beyond it confirms trend continuation.
CH (Change of Character): the origin of the current impulse. A close beyond it flips the structure to the opposite direction.
In a bearish structure the CH sits above and the BOS below; in a bullish structure it's mirrored.

How it works
Closes only. Wicks never break a level — only a confirmed candle close validates a BOS or a CH break. Nothing is decided on the in-progress candle.
Daily reset. The indicator works exclusively during the 09:30–15:59 New York regular session. The 09:30 candle sets the initial range, logic starts at 09:31, and everything is cleared and reinitialized at the next day's open. Outside the session, structure and drawings freeze.
Initialization. While direction is undefined, the day's running high/low are tracked. The first close below the opening low starts a bearish structure (and the first close above the opening high, a bullish one).
Continuation (BOS break): the BOS moves to the new extreme. The CH only advances if the prior pullback was significant.
Flip (CH break): the structure reverses, and the new CH is anchored to the absolute extreme of the finished phase — where the reversal impulse was actually born.
Minimum Pullback Filter
A standout feature: the Minimum Retracement (%) input. Small, single-candle dips inside the same impulse used to drag the CH around incorrectly. This filter measures each pullback as a percentage of the CH→BOS leg and only moves the CH when the retracement is real:

A ~63% rebound → moves the CH.
A ~20% dip → ignored as noise.
Configurable from 10% to 90% (default 35%).
Inputs
Regular session — session window (default 0930–1600 NY).
CH / BOS colors and line thickness (1–4).
Line extension — how many candles forward the levels project (default 15).
Minimum retracement (%) — the pullback filter described above.
Notes
Designed for intraday timeframes only.
Only the active CH/BOS pair is shown; previous levels are removed to keep the chart clean.
Times are fixed to the America/New_York timezone regardless of your chart's local time.

## Source Code

````pine
//@version=6
indicator("Market Structure CH / BOS", "CH/BOS", overlay = true)

// ───────────────── Inputs ─────────────────
tzRTH   = input.string("America/New_York", "Timezone", options = ["America/Chicago", "America/New_York", "America/Sao_Paulo", "Asia/Kolkata", "Asia/Shanghai", "Asia/Singapore", "Asia/Tokyo", "Australia/Sydney", "Europe/London", "Europe/Madrid", "UTC"], tooltip = "Timezone used to interpret the session and the daily reset. Default America/New_York.")
sesRTH  = input.session("0930-1600", "Regular session", tooltip = "Default 09:30 to 15:59. The opening candle defines the initial levels and the logic starts one minute later. Set this in the timezone selected above (e.g. NSE: 0915-1530 with Asia/Kolkata).")
colCH   = input.color(color.white, "CH color")
colBOS  = input.color(color.white, "BOS color")
grosor  = input.int(1, "Line width", minval = 1, maxval = 4)
extDer  = input.int(15, "Line extension (candles)", minval = 3, maxval = 100)
minRetr = input.float(35, "Minimum pullback to move the CH (%)", minval = 10, maxval = 90, step = 5, tooltip = "Percentage of the CH→BOS leg that price must retrace for that pullback to count as the new origin of the impulse. Smaller pullbacks are treated as noise and the CH does not move.")

// ──────── Sesión / cambio de día ────────
inRTH  = not na(time(timeframe.period, sesRTH, tzRTH))
nyDia  = dayofmonth(time, tzRTH)
nvoDia = nyDia != nyDia[1]
newRTH = inRTH and (not inRTH[1] or nvoDia)   // vela de las 09:30

// ───────────────── Estado ─────────────────
var int   dir    = 0      // 0 = sin definir, -1 = bajista, +1 = alcista
var float iniH   = na     // high/low de la vela de 09:30
var float iniL   = na
var float maxH   = na     // extremos acumulados en fase inicial
var int   bMaxH  = na
var float minL   = na
var int   bMinL  = na
var float chLvl  = na     // nivel CH vigente
var int   chBar  = na
var float bosLvl = na     // nivel BOS vigente
var int   bosBar = na
var float pbCand = na     // extremo del retroceso (candidato a nuevo CH en continuación)
var int   pbBar  = na
var float tExt   = na     // extremo de la tendencia, mechas incluidas (CH si hay flip)
var int   bTExt  = na

var line  lnCH  = na
var line  lnBOS = na
var label lbCH  = na
var label lbBOS = na

// ───────── Máquina de estados (solo velas cerradas) ─────────
if barstate.isconfirmed
    if newRTH
        // Nuevo día: limpiar y fijar niveles iniciales con la vela de 09:30
        line.delete(lnCH)
        line.delete(lnBOS)
        label.delete(lbCH)
        label.delete(lbBOS)
        lnCH  := na
        lnBOS := na
        lbCH  := na
        lbBOS := na
        dir   := 0
        iniH  := high
        iniL  := low
        maxH  := high
        bMaxH := bar_index
        minL  := low
        bMinL := bar_index
        chLvl  := na
        bosLvl := na
        pbCand := na
        tExt   := na
    else if inRTH
        if dir == 0
            // Fase inicial: acumular extremos hasta la primera ruptura por cierre
            if high > maxH
                maxH  := high
                bMaxH := bar_index
            if low < minL
                minL  := low
                bMinL := bar_index
            if close < iniL
                dir    := -1
                chLvl  := maxH
                chBar  := bMaxH
                bosLvl := low
                bosBar := bar_index
                tExt   := minL
                bTExt  := bMinL
                pbCand := na
            else if close > iniH
                dir    := 1
                chLvl  := minL
                chBar  := bMinL
                bosLvl := high
                bosBar := bar_index
                tExt   := maxH
                bTExt  := bMaxH
                pbCand := na

        else if dir == -1
            // Extremo absoluto de la fase bajista (mechas incluidas)
            if low < tExt
                tExt  := low
                bTExt := bar_index
            // Seguimiento del retroceso al alza desde el último evento
            if na(pbCand) or high > pbCand
                pbCand := high
                pbBar  := bar_index
            if close < bosLvl
                // BOS de continuación: el CH solo se mueve si el retroceso fue significativo
                legSize = chLvl - bosLvl
                retr = not na(pbCand) and legSize > 0 ? (pbCand - bosLvl) / legSize * 100 : 0.0
                if retr >= minRetr
                    chLvl := pbCand
                    chBar := pbBar
                bosLvl := low
                bosBar := bar_index
                pbCand := na
            else if close > chLvl
                // Change of character → estructura alcista
                dir    := 1
                chLvl  := tExt
                chBar  := bTExt
                bosLvl := high
                bosBar := bar_index
                tExt   := high
                bTExt  := bar_index
                pbCand := na

        else
            // dir == +1 (espejo exacto)
            if high > tExt
                tExt  := high
                bTExt := bar_index
            if na(pbCand) or low < pbCand
                pbCand := low
                pbBar  := bar_index
            if close > bosLvl
                legSize = bosLvl - chLvl
                retr = not na(pbCand) and legSize > 0 ? (bosLvl - pbCand) / legSize * 100 : 0.0
                if retr >= minRetr
                    chLvl := pbCand
                    chBar := pbBar
                bosLvl := high
                bosBar := bar_index
                pbCand := na
            else if close < chLvl
                dir    := -1
                chLvl  := tExt
                chBar  := bTExt
                bosLvl := low
                bosBar := bar_index
                tExt   := low
                bTExt  := bar_index
                pbCand := na

// ───────── Dibujo ─────────
if inRTH and dir != 0 and not newRTH
    x2 = bar_index + extDer
    xl = bar_index + math.floor(extDer / 2)
    if na(lnCH)
        lnCH  := line.new(chBar, chLvl, x2, chLvl, color = colCH, style = line.style_dashed, width = grosor)
        lnBOS := line.new(bosBar, bosLvl, x2, bosLvl, color = colBOS, style = line.style_dashed, width = grosor)
        lbCH  := label.new(xl, chLvl, "CH", style = label.style_label_center, color = chart.bg_color, textcolor = colCH, size = 12, text_formatting = text.format_bold)
        lbBOS := label.new(xl, bosLvl, "BOS", style = label.style_label_center, color = chart.bg_color, textcolor = colBOS, size = 12, text_formatting = text.format_bold)
    line.set_xy1(lnCH, chBar, chLvl)
    line.set_xy2(lnCH, x2, chLvl)
    line.set_xy1(lnBOS, bosBar, bosLvl)
    line.set_xy2(lnBOS, x2, bosLvl)
    label.set_xy(lbCH, xl, chLvl)
    label.set_xy(lbBOS, xl, bosLvl)
````
