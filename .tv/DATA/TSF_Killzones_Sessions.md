<!-- tradingview-pine-id: PUB;6fd9f19cf186469ca6fe3b3432c1d4d1 -->
<!-- tradingviewscripts-format: 1 -->
# TSF Killzones & Sessions

Source: https://www.tradingview.com/script/8ZyrtDLE/

## Description

TSF Killzones & Sessions

════════════════════════ ENGLISH ═════════════════════════════

OVERVIEW This indicator highlights the main global trading sessions and their killzones directly on the chart, and flags the opening of the world's major stock exchanges. A live dashboard shows which session is currently open and displays every schedule converted to your local time. It is designed for intraday traders (recommended on 1m–30m timeframes) who structure their trading around session behavior, liquidity and volatility windows.

WHAT IT PLOTS

Sessions (Asia, Frankfurt, London, New York): each session's high and low are drawn as dotted horizontal lines spanning the session, marking the session range as liquidity-reference levels.
Killzones: the opening window of each session (where activity usually concentrates) is drawn as a filled box covering the high-to-low range of that window.
Stock exchange opens: the opening of the European and US cash-equity markets is flagged with a temporary on-chart banner and optional alerts.
Live dashboard: a panel listing every session with its schedule (converted to your chosen timezone) and its live status (open / closed / in killzone), a clock, and the currently active session.

HOW IT WORKS

Each session and killzone is defined by a time range in UTC and detected with Pine's time() function. Because the reference is UTC, the boxes stay correct regardless of the chart's exchange timezone.
The dashboard converts every UTC schedule to a display timezone (default: Argentina, UTC-3) so you read the times in your own local time.
Session high/low lines and killzone boxes update in real time as each window develops and remain afterward as historical reference.
A stock-exchange open is detected as the first bar of its configured market window; the banner appears on that bar and clears on the next one. Alerts fire once per opening.

HOW TO USE IT

Add the indicator to an intraday chart (1m–30m recommended).
In the settings, if your broker uses a timezone other than UTC, set the UTC offset so the sessions align with your candles.
Enable/disable any session, killzone or exchange, and customize colors and hours.
To be notified when a market opens, create an alert on the indicator and pick the "Apertura Bolsa Americana" / "Apertura Bolsa Europea" condition.

USER-INTERFACE TEXT (English translation) The panel and on-chart labels are written in Spanish. English meaning:

"TSF SESSIONS" = panel title.
"SESIÓN" = Session · "ARG" = local time (Argentina) · "ESTADO" = Status.
"ABIERTA" = Open · "cerrada" = closed · "KZ" = Killzone.
"BOLSAS DE VALORES" = Stock exchanges · "Europa" = Europe · "EE.UU." = USA.
"AHORA" = Now (currently active session).
"APERTURA BOLSA AMERICANA / EUROPEA" = US / European stock-market open.
"Trading Sin Fronteras" = the author's brand name.

This script is open-source. Feel free to study it, learn from it and adapt it.

═══════════════════════ ESPAÑOL ═════════════════════════════

Indicador que marca las principales sesiones del mercado (Asia, Frankfurt, Londres y Nueva York) y sus killzones, más la apertura de las bolsas Europea y Americana, con un panel en vivo que muestra qué sesión está abierta y todos los horarios en tu hora local (por defecto, Argentina).

QUÉ DIBUJA

Sesiones: el máximo y el mínimo de cada sesión se marcan con líneas punteadas que abarcan toda la sesión (niveles de referencia de liquidez).
Killzones: la ventana de apertura de cada sesión se dibuja como una caja rellena con su rango máximo/mínimo.
Apertura de bolsas: la apertura de la bolsa Europea y la Americana se avisa con un cartel temporal y alertas opcionales.
Panel en vivo: lista cada sesión con su horario (convertido a tu huso) y su estado (abierta / cerrada / en killzone), un reloj y la sesión activa.

CÓMO FUNCIONA Los horarios se cargan en UTC (por eso las cajas caen siempre bien sin importar el huso del gráfico) y el panel los convierte a tu hora local. Las líneas y cajas se actualizan en vivo y quedan como referencia histórica.

CÓMO USARLO Agregalo a un gráfico intradía (1m–30m). Si tu broker usa otro huso, ajustá el offset UTC en los ajustes. Todo es configurable: colores, horarios, zona horaria y qué elementos mostrar. Para el aviso de apertura de bolsa, creá una alerta y elegí la condición correspondiente.

Script de código abierto — Trading Sin Fronteras.

---

## Source Code

````pine
//@version=6
// ================================================================
//  TSF KILLZONES & SESSIONS  —  Trading Sin Fronteras © Rodrigo Pérez
//  v1.0  (edición final · Pine Script v6) — Sesiones + Killzones + Apertura de BOLSAS
//  Sesiones: Asia · Frankfurt · Londres · Nueva York
//  Bolsas: Europea y Americana (contorno dentro de la sesión)
//  Panel con hora de Argentina calculada automáticamente. Horarios en UTC.
// ================================================================
indicator("TSF Killzones & Sessions", shorttitle="TSF Sessions", overlay=true, max_bars_back=5000, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================ PALETA ============================
cTxt    = #E7EAF0
cDim    = #7B818C
cHead   = #08090D
cCellA  = #12141A
cCellB  = #191C24
cBorder = #2A2E37
cGold   = #E7B84B
cCel    = #00BFFF
cUp     = #00E19B
cDn     = #FF3B5C

// ============================ ZONA HORARIA ============================
gTZ = "▶ Zona Horaria"
utcOff  = input.int(0, "Offset UTC de los horarios (+/-)", minval=-12, maxval=14, group=gTZ, tooltip="Los horarios de sesión se cargan en UTC. El panel los convierte a hora de Argentina solo. Si tu broker usa otro huso, ajustá acá.")
useExch = input.bool(false, "Usar zona horaria del exchange", group=gTZ)
tzAR    = input.string("America/Argentina/Buenos_Aires", "Zona horaria del reloj (panel)", group=gTZ)
sessTz  = useExch ? syminfo.timezone : str.format("UTC{0}{1}", utcOff >= 0 ? "+" : "-", math.abs(utcOff))

// ============================ ESTILO ============================
gSt = "▶ Estilo"
transKZ   = input.int(78, "Transparencia caja Killzone", minval=0, maxval=100, group=gSt)
showOut   = input.bool(true,  "Borde de la Killzone", group=gSt)
showLbl   = input.bool(true,  "Etiqueta de sesión", group=gSt)
lineW     = input.int(1, "Grosor líneas de sesión (máx/mín)", minval=1, maxval=4, group=gSt)

// ============================ SESIONES ============================
g1 = "▶ 1 · ASIA"
on1   = input.bool(true, "Activar", inline="1a", group=g1)
col1  = input.color(#FB8C00, "", inline="1a", group=g1)
nm1   = input.string("ASIA", "", inline="1a", group=g1)
se1   = input.session("2320-0600", "Sesión", group=g1)
kz1   = input.session("2200-0355", "Killzone", group=g1)
box1  = input.bool(true, "Líneas", inline="1b", group=g1)
kzon1 = input.bool(true, "Caja KZ", inline="1b", group=g1)

g2 = "▶ 2 · FRANKFURT"
on2   = input.bool(true, "Activar", inline="2a", group=g2)
col2  = input.color(#FFD54F, "", inline="2a", group=g2)
nm2   = input.string("FRANKFURT", "", inline="2a", group=g2)
se2   = input.session("0600-0700", "Sesión", group=g2)
kz2   = input.session("0600-0700", "Killzone", group=g2)
box2  = input.bool(true, "Líneas", inline="2b", group=g2)
kzon2 = input.bool(true, "Caja KZ", inline="2b", group=g2)

g3 = "▶ 3 · LONDRES"
on3   = input.bool(true, "Activar", inline="3a", group=g3)
col3  = input.color(#26A69A, "", inline="3a", group=g3)
nm3   = input.string("LONDRES", "", inline="3a", group=g3)
se3   = input.session("0700-1600", "Sesión", group=g3)
kz3   = input.session("0700-0955", "Killzone", group=g3)
box3  = input.bool(true, "Líneas", inline="3b", group=g3)
kzon3 = input.bool(true, "Caja KZ", inline="3b", group=g3)

g4 = "▶ 4 · NUEVA YORK"
on4   = input.bool(true, "Activar", inline="4a", group=g4)
col4  = input.color(#F23645, "", inline="4a", group=g4)
nm4   = input.string("NUEVA YORK", "", inline="4a", group=g4)
se4   = input.session("1200-2100", "Sesión", group=g4)
kz4   = input.session("1200-1500", "Killzone", group=g4)
box4  = input.bool(true, "Líneas", inline="4b", group=g4)
kzon4 = input.bool(true, "Caja KZ", inline="4b", group=g4)

// ============================ BOLSAS DE VALORES ============================
gB = "▶ Bolsas de Valores (cartel + alerta al abrir)"
onEU   = input.bool(true, "Bolsa Europea", inline="be", group=gB)
colEU  = input.color(#29B6F6, "", inline="be", group=gB)
seEU   = input.session("0700-1630", "Horario Europa", group=gB, tooltip="04:00–13:30 ARG")
onUS   = input.bool(true, "Bolsa Americana", inline="bu", group=gB)
colUS  = input.color(#EC407A, "", inline="bu", group=gB)
seUS   = input.session("1330-2000", "Horario EE.UU.", group=gB, tooltip="10:30–17:00 ARG")
showBanner = input.bool(true, "Cartel flotante al abrir la bolsa (se borra solo)", group=gB, tooltip="Aparece arriba al centro en la vela de apertura y desaparece en la siguiente. Dura lo que dura la vela (no 3 segundos exactos: Pine no tiene temporizador).")
alertBolsa = input.bool(true, "Disparar alerta al abrir la bolsa (popup/sonido/celular)", group=gB)

gP = "▶ Panel / Divisores"
showPanel  = input.bool(true, "Panel en vivo (hora Argentina)", group=gP)
panelPos   = input.string("Arriba Derecha", "Posición panel", options=["Arriba Derecha","Arriba Izquierda","Abajo Derecha","Abajo Izquierda"], group=gP)
panelSize  = input.string("Normal", "Tamaño del panel", options=["Chico","Normal","Grande"], group=gP, tooltip="En el celular conviene 'Chico' para que no tape el gráfico; en la compu 'Grande' para leer más cómodo.")
showDayDiv = input.bool(true, "Divisor de día (línea punteada)", group=gP)

// ============================ HELPERS ============================
f2(int x) => (x < 10 ? "0" : "") + str.tostring(x)
// Convierte el horario de la sesión (en UTC+offset) a hora de Argentina (solo horas)
argSched(string s) =>
    sh  = int(str.tonumber(str.substring(s, 0, 2)))
    sm  = int(str.tonumber(str.substring(s, 2, 4)))
    eh  = int(str.tonumber(str.substring(s, 5, 7)))
    em  = int(str.tonumber(str.substring(s, 7, 9)))
    ash = (sh - utcOff - 3 + 48) % 24
    aeh = (eh - utcOff - 3 + 48) % 24
    startTxt = sm == 0 ? f2(ash) : f2(ash) + ":" + f2(sm)
    endTxt   = em == 0 ? f2(aeh) : f2(aeh) + ":" + f2(em)
    startTxt + "-" + endTxt

// ============================ FUNCIÓN: CAJA DE RANGO (sesión / killzone) ============================
drawRange(bool active, color col, string nm, int transp, bool drawBox, bool lbl) =>
    var box   b  = na
    var label lb = na
    var float hi = na
    var float lo = na
    var int   st = na
    started = active and not active[1]
    if started
        hi := high
        lo := low
        st := time
        if drawBox
            b := box.new(bar_index, hi, bar_index, lo, bgcolor=color.new(col, transp), border_color=showOut ? color.new(col, math.max(transp-40,0)) : na, border_style=line.style_dotted)
            if lbl
                lb := label.new(st, hi, nm, xloc=xloc.bar_time, textcolor=col, style=label.style_label_down, color=#00000000, size=size.tiny)
    else if active
        hi := math.max(high, hi)
        lo := math.min(low, lo)
        if drawBox and not na(b)
            box.set_top(b, hi)
            box.set_rightbottom(b, bar_index, lo)
            if lbl and not na(lb)
                label.set_xy(lb, int(math.avg(st, time)), hi)
    b

// ============================ FUNCIÓN: LÍNEAS DE SESIÓN (máx/mín punteados) ============================
drawSessLines(bool active, color col, string nm, bool draw, bool lbl) =>
    var line  hiL = na
    var line  loL = na
    var label lb  = na
    var float hi = na
    var float lo = na
    var int   sb = na
    var int   st = na
    started = active and not active[1]
    if started
        hi := high
        lo := low
        sb := bar_index
        st := time
        if draw
            hiL := line.new(sb, hi, bar_index, hi, xloc=xloc.bar_index, color=col, style=line.style_dotted, width=lineW)
            loL := line.new(sb, lo, bar_index, lo, xloc=xloc.bar_index, color=col, style=line.style_dotted, width=lineW)
            if lbl
                lb := label.new(st, hi, nm, xloc=xloc.bar_time, textcolor=col, style=label.style_label_down, color=#00000000, size=size.tiny)
    else if active and draw and not na(hiL)
        hi := math.max(high, hi)
        lo := math.min(low, lo)
        line.set_xy1(hiL, sb, hi)
        line.set_xy2(hiL, bar_index, hi)
        line.set_xy1(loL, sb, lo)
        line.set_xy2(loL, bar_index, lo)
        if lbl and not na(lb)
            label.set_xy(lb, int(math.avg(st, time)), hi)
    hiL

// ============================ ESTADO EN VIVO ============================
a1 = on1 and not na(time(timeframe.period, se1, sessTz))
a2 = on2 and not na(time(timeframe.period, se2, sessTz))
a3 = on3 and not na(time(timeframe.period, se3, sessTz))
a4 = on4 and not na(time(timeframe.period, se4, sessTz))
k1 = on1 and kzon1 and not na(time(timeframe.period, kz1, sessTz))
k2 = on2 and kzon2 and not na(time(timeframe.period, kz2, sessTz))
k3 = on3 and kzon3 and not na(time(timeframe.period, kz3, sessTz))
k4 = on4 and kzon4 and not na(time(timeframe.period, kz4, sessTz))
eEU = onEU and not na(time(timeframe.period, seEU, sessTz))
eUS = onUS and not na(time(timeframe.period, seUS, sessTz))

// ============================ DIBUJO ============================
// Sesiones: líneas punteadas en máximo y mínimo (con etiqueta)
drawSessLines(a1, col1, nm1, on1 and box1, showLbl)
drawSessLines(a2, col2, nm2, on2 and box2, showLbl)
drawSessLines(a3, col3, nm3, on3 and box3, showLbl)
drawSessLines(a4, col4, nm4, on4 and box4, showLbl)
// Killzones: caja rellena (sin etiqueta)
drawRange(k1, col1, nm1, transKZ, kzon1, false)
drawRange(k2, col2, nm2, transKZ, kzon2, false)
drawRange(k3, col3, nm3, transKZ, kzon3, false)
drawRange(k4, col4, nm4, transKZ, kzon4, false)
// Bolsas de valores: SIN etiquetas fijas. Solo alerta + cartel temporal.
justEU = eEU and not eEU[1]
justUS = eUS and not eUS[1]
if alertBolsa and justEU
    alert("Apertura de la Bolsa Europea", alert.freq_once_per_bar)
if alertBolsa and justUS
    alert("Apertura de la Bolsa Americana", alert.freq_once_per_bar)
alertcondition(justEU, "Apertura Bolsa Europea",  "Apertura de la Bolsa Europea")
alertcondition(justUS, "Apertura Bolsa Americana", "Apertura de la Bolsa Americana")

// ============================ DIVISOR DE DÍA ============================
newDay = dayofmonth(time, sessTz) != dayofmonth(time[1], sessTz)
if showDayDiv and newDay
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.gray, 55), style=line.style_dashed)

// ============================ PANEL EN VIVO (premium) ============================
clockAR = f2(hour(timenow, tzAR)) + ":" + f2(minute(timenow, tzAR))
sTxt(bool s, bool kz) => not s ? "cerrada" : kz ? "ABIERTA · KZ" : "ABIERTA"
sBg(bool s, bool kz)  => not s ? cCellB : kz ? color.new(cGold, 15) : color.new(cUp, 15)
sFg(bool s)           => s ? #05130D : cDim

activa = a4 ? nm4 : a3 ? nm3 : a2 ? nm2 : a1 ? nm1 : "— sin sesión —"
actCol = a4 ? col4 : a3 ? col3 : a2 ? col2 : a1 ? col1 : cDim

posTbl = panelPos=="Arriba Derecha" ? position.top_right : panelPos=="Arriba Izquierda" ? position.top_left : panelPos=="Abajo Derecha" ? position.bottom_right : position.bottom_left
var table t = table.new(posTbl, 3, 11, border_width=1, frame_color=cBorder, frame_width=1, bgcolor=cHead)

// Tamaño del panel (Chico para celular, Grande para PC)
szTitle = panelSize=="Chico" ? size.normal : panelSize=="Grande" ? size.huge  : size.large
szHead  = panelSize=="Chico" ? size.small  : panelSize=="Grande" ? size.large  : size.normal
szRow   = panelSize=="Chico" ? size.tiny   : panelSize=="Grande" ? size.normal : size.small
szSub   = panelSize=="Chico" ? size.tiny   : panelSize=="Grande" ? size.small  : size.tiny

if showPanel and barstate.islast
    // Encabezado
    table.cell(t, 0, 0, "◆ TSF", text_color=cCel, text_size=szTitle, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 0, "SESSIONS", text_color=cTxt, text_size=szHead, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 2, 0, clockAR + "  ARG", text_color=cCel, text_size=szHead, text_halign=text.align_right, bgcolor=cHead)
    // Cabecera de columnas
    table.cell(t, 0, 1, "SESIÓN", text_color=cCel, text_size=szSub, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 1, "ARG",    text_color=cCel, text_size=szSub, bgcolor=cHead)
    table.cell(t, 2, 1, "ESTADO", text_color=cCel, text_size=szSub, text_halign=text.align_right, bgcolor=cHead)
    // Sesiones
    table.cell(t, 0, 2, "● " + nm1, text_color=col1, text_size=szRow, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 2, argSched(se1), text_color=cTxt, text_size=szRow, bgcolor=cCellA)
    table.cell(t, 2, 2, sTxt(a1,k1), text_color=sFg(a1), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(a1,k1))
    table.cell(t, 0, 3, "● " + nm2, text_color=col2, text_size=szRow, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 3, argSched(se2), text_color=cTxt, text_size=szRow, bgcolor=cCellB)
    table.cell(t, 2, 3, sTxt(a2,false), text_color=sFg(a2), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(a2,false))
    table.cell(t, 0, 4, "● " + nm3, text_color=col3, text_size=szRow, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 4, argSched(se3), text_color=cTxt, text_size=szRow, bgcolor=cCellA)
    table.cell(t, 2, 4, sTxt(a3,k3), text_color=sFg(a3), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(a3,k3))
    table.cell(t, 0, 5, "● " + nm4, text_color=col4, text_size=szRow, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 5, argSched(se4), text_color=cTxt, text_size=szRow, bgcolor=cCellB)
    table.cell(t, 2, 5, sTxt(a4,k4), text_color=sFg(a4), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(a4,k4))
    // Bolsas
    table.cell(t, 0, 6, "BOLSAS DE VALORES", text_color=cCel, text_size=szSub, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 6, "", bgcolor=cHead)
    table.cell(t, 2, 6, "", bgcolor=cHead)
    table.cell(t, 0, 7, "● Europa", text_color=colEU, text_size=szRow, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 7, argSched(seEU), text_color=cTxt, text_size=szRow, bgcolor=cCellA)
    table.cell(t, 2, 7, sTxt(eEU,false), text_color=sFg(eEU), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(eEU,false))
    table.cell(t, 0, 8, "● EE.UU.", text_color=colUS, text_size=szRow, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 8, argSched(seUS), text_color=cTxt, text_size=szRow, bgcolor=cCellB)
    table.cell(t, 2, 8, sTxt(eUS,false), text_color=sFg(eUS), text_size=szRow, text_halign=text.align_right, bgcolor=sBg(eUS,false))
    // Sesión activa
    table.cell(t, 0, 9, "AHORA", text_color=cCel, text_size=szSub, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 9, "", bgcolor=cCellA)
    table.cell(t, 2, 9, activa, text_color=actCol, text_size=szRow, text_halign=text.align_right, bgcolor=cCellA)
    // Pie de marca
    table.cell(t, 0, 10, "Trading Sin Fronteras", text_color=cCel, text_size=szSub, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 10, "", bgcolor=cHead)
    table.cell(t, 2, 10, "TSF", text_color=cCel, text_size=szSub, text_halign=text.align_right, bgcolor=cHead)

// ============================ CARTEL FLOTANTE DE APERTURA (temporal, se borra solo) ============================
var table bnr = table.new(position.top_center, 1, 1, frame_width=0)
bTxt = justUS ? "●  APERTURA BOLSA AMERICANA" : justEU ? "●  APERTURA BOLSA EUROPEA" : ""
bCol = justUS ? colUS : justEU ? colEU : color.new(color.black, 100)
if showBanner
    if bTxt != ""
        table.cell(bnr, 0, 0, "  " + bTxt + "  ", text_color=#FFFFFF, text_size=size.large, bgcolor=color.new(bCol, 8))
    else
        table.cell(bnr, 0, 0, "", bgcolor=color.new(color.black, 100))
````
