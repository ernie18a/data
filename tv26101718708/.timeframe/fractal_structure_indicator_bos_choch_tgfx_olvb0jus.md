# Fractal Structure Indicator  BOS CHoCH TGFX

- url: https://www.tradingview.com/script/OlvB0juS-Fractal-Structure-Indicator-BOS-CHoCH-TGFX/
- type: indicator
- pine_id: PUB;ad6921bf6625487c8262ba5f6e599068
- version: 1.0

## Description

Fractal Market Structure — BOS / CHoCH

OVERVIEW
This tool maps market structure automatically using fractal pivots. It detects swing and internal structure, labels each break as BOS (continuation) or CHoCH (change of character / reversal), tracks the current fractal high and low (FH / FL), highlights the premium and discount zones of the active range, and summarises higher-timeframe structure in a table.

THE CONCEPTS
- Fractal pivots: highs and lows are detected as Williams-style pivots (a high or low with N bars on each side). Two layers are available — swing structure (larger pivots) and internal structure (smaller pivots inside the swings).
- BOS (Break of Structure): price closes beyond the prior structural point in the direction of the trend — a continuation event.
- CHoCH (Change of Character): the first break against the prevailing structure — an early sign of a potential reversal.
- Current FH / FL: the most recent fractal high and low, where liquidity tends to rest.
- Premium / Discount: the active range is split at its 50% equilibrium. Above it is premium (relatively expensive); below it is discount (relatively cheap).
- Multi-timeframe table: shows the structural bias and the zone (premium / discount) of higher timeframes at a glance.

NON-REPAINTING
A fractal is only confirmed once N bars have closed on each side, so a pivot is fixed after confirmation and does not repaint. Structure breaks (BOS / CHoCH) are evaluated on bar close.

SETTINGS
- Swing fractal length and internal fractal length.
- Show / hide internal structure.
- Show current FH / FL lines and labels.
- Show BOS / CHoCH labels.
- Show premium / discount zones.
- Colors, line extension, and the multi-timeframe table (timeframes and position).

HOW TO READ IT
- Green = bullish structure, red = bearish structure.
- BOS suggests trend continuation; CHoCH warns of a possible reversal.
- Price reaching discount within a bullish bias, or premium within a bearish bias, is the classic context many traders use to look for entries in the direction of structure.

NOTES
This script is an original implementation of standard, public price-action concepts (fractal pivots, market structure, BOS / CHoCH, premium / discount, equilibrium). It is a visualization and context tool — it does not generate buy/sell signals and makes no claim about future performance. Best used together with your own analysis and risk management.

## Source Code

````pine
//@version=6
// =============================================================================
//  FRACTAL STRUCTURE INDICATOR
//  Replica gratuita del "Fractal Structure Indicator" (The Trading Academy)
//
//  Detecta:
//   - Fractal Highs / Lows (swing + internos)  -> current FH / current FL
//   - Rupturas de estructura:  BOS (continuacion) y CHoCH (reversion)
//   - Premium / Discount sobre el rango activo (equilibrio 50%)
//   - Tabla multi-timeframe con bias y zona
//
//  Logica de fractal = pivote de Williams (N velas a cada lado).
//  NO repinta: un fractal queda fijo al confirmarse N velas despues,
//  y las rupturas se evaluan al cierre.
// =============================================================================
indicator("Fractal Structure Indicator", shorttitle = "Fractal Structure", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// =============================================================================
//                                  INPUTS
// =============================================================================
gF = "── Deteccion de Fractales ──"
swingLen   = input.int(5, "Longitud fractal SWING", minval = 1, group = gF, tooltip = "Velas a cada lado para un fractal mayor (swing). Williams clasico = 2. Mas alto = menos fractales pero mas significativos.")
intLen     = input.int(2, "Longitud fractal INTERNO", minval = 1, group = gF, tooltip = "Velas a cada lado para estructura menor / interna.")
showInt    = input.bool(true, "Mostrar estructura interna", group = gF)

gD = "── Visual ──"
showFHFL   = input.bool(true, "Lineas + etiquetas current FH / FL", group = gD)
showBreaks = input.bool(true, "Etiquetas BOS / CHoCH", group = gD)
showPD     = input.bool(true, "Zonas Premium / Discount", group = gD)
extLen     = input.int(15, "Extender lineas (velas a la derecha)", minval = 0, group = gD)
bosTxt     = input.string("BOS",   "Texto continuacion", group = gD)
chochTxt   = input.string("CHoCH", "Texto reversion", group = gD)

gC = "── Colores ──"
bullCol    = input.color(#089981, "Alcista", group = gC)
bearCol    = input.color(#f23645, "Bajista", group = gC)
fhCol      = input.color(#2962ff, "Fractal High", group = gC)
flCol      = input.color(#2962ff, "Fractal Low", group = gC)

gT = "── Tabla Multi-Timeframe ──"
showTable  = input.bool(true, "Mostrar tabla", group = gT)
tf1        = input.timeframe("D",   "Temporalidad alta 1", group = gT)
tf2        = input.timeframe("240", "Temporalidad alta 2", group = gT)
tblPos     = input.string("top_right", "Posicion", options = ["top_right","top_left","bottom_right","bottom_left","middle_right"], group = gT)

// =============================================================================
//                          FUNCION NUCLEO DE ESTRUCTURA
//  Devuelve [FH, FL, bias, ruptura, equilibrio, barFH, barFL]
//   bias     :  1 alcista | -1 bajista | 0 neutro
//   ruptura  :  1 BOS up | 2 CHoCH up | -1 BOS down | -2 CHoCH down | 0 nada
// =============================================================================
f_struct(int len) =>
    var float fh       = na
    var float fl       = na
    var int   fhBar    = na
    var int   flBar    = na
    var int   bias     = 0
    var bool  fhBroken = true
    var bool  flBroken = true
    int brk = 0

    ph = ta.pivothigh(len, len)
    pl = ta.pivotlow(len, len)

    if not na(ph)
        fh       := ph
        fhBar    := bar_index - len
        fhBroken := false
    if not na(pl)
        fl       := pl
        flBar    := bar_index - len
        flBroken := false

    // Ruptura al cierre del FH activo
    if not na(fh) and not fhBroken and close > fh
        brk      := bias < 0 ? 2 : 1     // si veniamos bajistas -> CHoCH, si no -> BOS
        bias     := 1
        fhBroken := true
    // Ruptura al cierre del FL activo
    if not na(fl) and not flBroken and close < fl
        brk      := bias > 0 ? -2 : -1
        bias     := -1
        flBroken := true

    float eq = (na(fh) or na(fl)) ? na : (fh + fl) / 2.0
    [fh, fl, bias, brk, eq, fhBar, flBar]

// =============================================================================
//                  ESTRUCTURA EN LA TEMPORALIDAD DEL GRAFICO
// =============================================================================
[fhS, flS, biasS, brkS, eqS, fhBarS, flBarS] = f_struct(swingLen)
[fhI, flI, biasI, brkI, eqI, fhBarI, flBarI] = f_struct(intLen)

// =============================================================================
//                       LINEAS + ETIQUETAS current FH / FL
// =============================================================================
var line  lnFH = na
var line  lnFL = na
var label lbFH = na
var label lbFL = na

if barstate.islast
    line.delete(lnFH)
    line.delete(lnFL)
    label.delete(lbFH)
    label.delete(lbFL)
    if showFHFL
        if not na(fhS)
            lnFH := line.new(fhBarS, fhS, bar_index + extLen, fhS, color = fhCol, style = line.style_dotted, width = 1)
            lbFH := label.new(bar_index + extLen, fhS, "current FH", style = label.style_label_left, color = color.new(color.black, 100), textcolor = fhCol, size = size.small)
        if not na(flS)
            lnFL := line.new(flBarS, flS, bar_index + extLen, flS, color = flCol, style = line.style_dotted, width = 1)
            lbFL := label.new(bar_index + extLen, flS, "current FL", style = label.style_label_left, color = color.new(color.black, 100), textcolor = flCol, size = size.small)

// =============================================================================
//                          ZONAS PREMIUM / DISCOUNT
// =============================================================================
var box boxPrem = na
var box boxDisc = na

if barstate.islast
    box.delete(boxPrem)
    box.delete(boxDisc)
    if showPD and not na(eqS) and not na(fhS) and not na(flS)
        leftB = math.min(fhBarS, flBarS)
        boxPrem := box.new(leftB, fhS, bar_index + extLen, eqS, border_color = color.new(bearCol, 80), bgcolor = color.new(bearCol, 92))
        boxDisc := box.new(leftB, eqS, bar_index + extLen, flS, border_color = color.new(bullCol, 80), bgcolor = color.new(bullCol, 92))

// =============================================================================
//                          ETIQUETAS BOS / CHoCH
// =============================================================================
plotBreak(int brk, float lvl, bool internal) =>
    if showBreaks and brk != 0
        up   = brk > 0
        choc = math.abs(brk) == 2
        txt  = choc ? chochTxt : bosTxt
        col  = up ? bullCol : bearCol
        sty  = up ? label.style_label_up : label.style_label_down
        label.new(bar_index, lvl, (internal ? "i-" : "") + txt, color = color.new(col, internal ? 50 : 0), textcolor = color.white, style = sty, size = internal ? size.tiny : size.small)

plotBreak(brkS, brkS > 0 ? fhS : flS, false)
if showInt
    plotBreak(brkI, brkI > 0 ? fhI : flI, true)

// =============================================================================
//                          TABLA MULTI-TIMEFRAME
// =============================================================================
[fh1, fl1, bias1, brk1, eq1, fhb1, flb1] = request.security(syminfo.tickerid, tf1, f_struct(swingLen), lookahead = barmerge.lookahead_off)
[fh2, fl2, bias2, brk2, eq2, fhb2, flb2] = request.security(syminfo.tickerid, tf2, f_struct(swingLen), lookahead = barmerge.lookahead_off)

biasTxt(b)  => b > 0 ? "Bull" : b < 0 ? "Bear" : "—"
biasColr(b) => b > 0 ? bullCol : b < 0 ? bearCol : color.gray
zoneTxt(eq) => na(eq) ? "—" : close > eq ? "Premium" : "Discount"
zoneColr(eq) => na(eq) ? color.gray : close > eq ? bearCol : bullCol
tfLabel(tf) =>
    tf == "D" or tf == "1D" ? "1D" : tf == "W" ? "1W" : tf == "240" ? "4H" : tf == "60" or tf == "1H" ? "1H" : tf == "30" ? "30M" : tf == "15" ? "15M" : tf == "5" ? "5M" : tf

var table tbl = na
if showTable and barstate.islast
    pos = tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : tblPos == "bottom_left" ? position.bottom_left : tblPos == "middle_right" ? position.middle_right : position.top_right
    tbl := table.new(pos, 3, 5, border_color = color.new(color.gray, 50), border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)
    table.cell(tbl, 0, 0, "Estructura", text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 55))
    table.cell(tbl, 1, 0, "Bias",       text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 55))
    table.cell(tbl, 2, 0, "Zona",       text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 55))
    // HTF 1
    table.cell(tbl, 0, 1, tfLabel(tf1) + " Fractal", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 1, 1, biasTxt(bias1), text_color = biasColr(bias1), text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 2, 1, zoneTxt(eq1),   text_color = zoneColr(eq1),   text_size = size.small, bgcolor = color.new(color.black, 30))
    // HTF 2
    table.cell(tbl, 0, 2, tfLabel(tf2) + " Fractal", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 1, 2, biasTxt(bias2), text_color = biasColr(bias2), text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 2, 2, zoneTxt(eq2),   text_color = zoneColr(eq2),   text_size = size.small, bgcolor = color.new(color.black, 30))
    // Grafico - Swing
    table.cell(tbl, 0, 3, "Swing", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 1, 3, biasTxt(biasS), text_color = biasColr(biasS), text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 2, 3, zoneTxt(eqS),   text_color = zoneColr(eqS),   text_size = size.small, bgcolor = color.new(color.black, 30))
    // Grafico - Interno
    table.cell(tbl, 0, 4, "Interno", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 1, 4, biasTxt(biasI), text_color = biasColr(biasI), text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 2, 4, zoneTxt(eqI),   text_color = zoneColr(eqI),   text_size = size.small, bgcolor = color.new(color.black, 30))

// =============================================================================
//                              ALERTAS (Jarvis)
// =============================================================================
alertcondition(brkS ==  1, "BOS alcista (swing)",   "Swing BOS arriba — continuacion alcista")
alertcondition(brkS == -1, "BOS bajista (swing)",   "Swing BOS abajo — continuacion bajista")
alertcondition(brkS ==  2, "CHoCH alcista (swing)", "Swing CHoCH arriba — reversion alcista")
alertcondition(brkS == -2, "CHoCH bajista (swing)", "Swing CHoCH abajo — reversion bajista")
````
