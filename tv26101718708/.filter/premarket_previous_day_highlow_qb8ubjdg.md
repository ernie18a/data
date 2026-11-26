# Pre-Market + Previous Day High/Low

- url: https://www.tradingview.com/script/QB8ubjdG-Pre-Market-Previous-Day-High-Low/
- type: indicator
- pine_id: PUB;77b0f7ff4ec54e6880d26ede25953625
- version: 2.0

## Description

Pre-Market & Previous Day High/Low (PMH · PML · PDH · PDL)

This indicator automatically plots four key intraday reference levels as horizontal lines that extend to the right, each with its own label:

• PMH / PML — Pre-Market High and Low, calculated over the 04:00 to 09:29 range (New York time).
• PDH / PDL — Previous Day High and Low, calculated over the regular session of the prior day, from 09:30 to 15:59 (New York time).

The indicator always displays only the most recent set of levels. When a new pre-market begins or a new regular session closes, the previous levels are removed and the current ones are drawn. Each line originates at the candle that produced the extreme and projects forward, serving as support/resistance zones and breakout reference points.

CUSTOMIZABLE
• Line width and style (dotted, dashed or solid).
• Independent color for each level.
• Configurable session hours.

USAGE NOTES
• Works on intraday timeframes (1m, 5m, 15m, etc.).
• Enable Extended Trading Hours on your chart so the pre-market range is calculated correctly.
• All times use the New York time zone, so the levels adjust automatically regardless of your chart's time zone.

Ideal for opening-range traders, breakout strategies and anyone trading off key market levels.

## Source Code

````pine
//@version=6
indicator("Pre-Market + Previous Day High/Low", "PM+PD", overlay = true)

// ───────────────── Inputs ─────────────────
grosor   = input.int(2, "Line width", minval = 1, maxval = 4)
estiloIn = input.string("Dotted", "Line style", options = ["Dotted", "Dashed", "Solid"])

sesPM  = input.session("0400-0930", "Pre-market session", group = "Pre-Market", tooltip = "04:00 to 09:29 (New York time). The 09:30 candle is no longer counted.")
colPMH = input.color(color.white, "PMH color", group = "Pre-Market")
colPML = input.color(color.white, "PML color", group = "Pre-Market")

sesRTH = input.session("0930-1600", "Regular session", group = "Previous Day", tooltip = "09:30 to 15:59 (New York time). The 16:00 candle is no longer counted.")
colPDH = input.color(color.white, "PDH color", group = "Previous Day")
colPDL = input.color(color.white, "PDL color", group = "Previous Day")

estilo = estiloIn == "Dotted" ? line.style_dotted : estiloIn == "Dashed" ? line.style_dashed : line.style_solid

// ──────── Detección de sesiones (solo intradía) ────────
inPM   = not na(time(timeframe.period, sesPM,  "America/New_York"))
inRTH  = not na(time(timeframe.period, sesRTH, "America/New_York"))
nyDia  = dayofmonth(time, "America/New_York")
nvoDia = nyDia != nyDia[1]

newPM  = inPM and not inPM[1]
newRTH = inRTH and (not inRTH[1] or nvoDia)                          // primera vela RTH del día
finRTH = (inRTH[1] and not inRTH) or (inRTH[1] and inRTH and nvoDia) // terminó la RTH de ayer

// Posición X de los textos: última vela visible (se recalcula al hacer scroll/zoom)
xTxt = chart.right_visible_bar_time

// ───────────────── Estado ─────────────────
// Pre-market
var float pmH = na
var float pmL = na
var line  lnPMH = na
var line  lnPML = na
var label lbPMH = na
var label lbPML = na

// Día en curso (acumuladores RTH) y niveles publicados del día anterior
var float dH  = na
var float dL  = na
var int   bDH = na
var int   bDL = na
var float pdH = na
var float pdL = na
var line  lnPDH = na
var line  lnPDL = na
var label lbPDH = na
var label lbPDL = na

// ═══════════ PMH / PML ═══════════
if newPM
    line.delete(lnPMH)
    line.delete(lnPML)
    label.delete(lbPMH)
    label.delete(lbPML)
    pmH := high
    pmL := low
    lnPMH := line.new(bar_index, pmH, bar_index + 1, pmH, extend = extend.right, color = colPMH, style = estilo, width = grosor)
    lnPML := line.new(bar_index, pmL, bar_index + 1, pmL, extend = extend.right, color = colPML, style = estilo, width = grosor)
    lbPMH := label.new(xTxt, pmH, "PMH", xloc = xloc.bar_time, style = label.style_label_right, color = color.new(color.black, 100), textcolor = colPMH, size = 12, text_formatting = text.format_bold)
    lbPML := label.new(xTxt, pmL, "PML", xloc = xloc.bar_time, style = label.style_label_right, color = color.new(color.black, 100), textcolor = colPML, size = 12, text_formatting = text.format_bold)
else if inPM
    if high > pmH
        pmH := high
        line.set_xy1(lnPMH, bar_index, pmH)
        line.set_xy2(lnPMH, bar_index + 1, pmH)
    if low < pmL
        pmL := low
        line.set_xy1(lnPML, bar_index, pmL)
        line.set_xy2(lnPML, bar_index + 1, pmL)

// ═══════════ PDH / PDL ═══════════
// Al terminar la sesión regular, el high/low acumulado se publica como nivel del "día anterior"
if finRTH and not na(dH)
    line.delete(lnPDH)
    line.delete(lnPDL)
    label.delete(lbPDH)
    label.delete(lbPDL)
    pdH := dH
    pdL := dL
    lnPDH := line.new(bDH, pdH, bDH + 1, pdH, extend = extend.right, color = colPDH, style = estilo, width = grosor)
    lnPDL := line.new(bDL, pdL, bDL + 1, pdL, extend = extend.right, color = colPDL, style = estilo, width = grosor)
    lbPDH := label.new(xTxt, pdH, "PDH", xloc = xloc.bar_time, style = label.style_label_right, color = color.new(color.black, 100), textcolor = colPDH, size = 12, text_formatting = text.format_bold)
    lbPDL := label.new(xTxt, pdL, "PDL", xloc = xloc.bar_time, style = label.style_label_right, color = color.new(color.black, 100), textcolor = colPDL, size = 12, text_formatting = text.format_bold)

// Acumular el high/low de la sesión regular en curso
if newRTH
    dH  := high
    dL  := low
    bDH := bar_index
    bDL := bar_index
else if inRTH
    if high > dH
        dH  := high
        bDH := bar_index
    if low < dL
        dL  := low
        bDL := bar_index

// ─────── Textos siempre pegados a la derecha ───────
if not na(lbPMH)
    label.set_x(lbPMH, xTxt)
    label.set_y(lbPMH, pmH)
    label.set_x(lbPML, xTxt)
    label.set_y(lbPML, pmL)
if not na(lbPDH)
    label.set_x(lbPDH, xTxt)
    label.set_y(lbPDH, pdH)
    label.set_x(lbPDL, xTxt)
    label.set_y(lbPDL, pdL)
````
