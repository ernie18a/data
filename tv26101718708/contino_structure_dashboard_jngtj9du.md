# CONTINO - Structure Dashboard

- url: https://www.tradingview.com/script/jNGTj9DU-CONTINO-Structure-Dashboard/
- type: indicator
- pine_id: PUB;a31d2467d13141cf85e0b2204b7915e4
- version: 1.0

## Description

CONTINO - Structure Dashboard

A multi-timeframe market structure dashboard that shows, in one compact table, whether each timeframe is bullish or bearish and what the last structural event was — so you can check your top-down bias without switching charts.

HOW IT WORKS
Structure is detected with pivot highs/lows (Structure Length). When a candle CLOSES beyond the last unbroken pivot:
- In the same direction as the current trend → BoS (Break of Structure)
- Against the current trend → MSS (Market Structure Shift)
Swing labels (HH / HL / LH / LL) are calculated separately with Swing Length.
The same logic is run on up to 4 timeframes at once and summarized in the table.

WHAT THE TABLE SHOWS
Simple mode (default): timeframe + last event (BoS ▲ / MSS ▼…), colored green or red, plus an alignment row.
Full mode:
- Structure — current bias per timeframe
- Last — last event (BoS / MSS and direction)
- Broken level — price of the pivot that was broken
- Bars ago — how fresh the event is, in bars of that timeframe
- Swings — latest swing high / swing low labels (HH/LH – HL/LL)
- MSS if closes — the price where a close would shift structure against the current bias (your invalidation level)

The bottom row shows ALIGNED ▲ / ALIGNED ▼ when all active timeframes agree, or MIXED with the count of bullish/bearish timeframes.

HOW TO USE IT
1. Place it on your execution chart (e.g. M15 or M1).
2. Read top-down: the highest timeframe gives the bias, the middle one tells you if execution is with or against it, the lowest one is for timing only.
3. Use the "MSS if closes" level as a reference for where your idea is invalidated.
4. Optional alerts: "Structure aligned BULLISH / BEARISH" when all active timeframes line up.

SETTINGS
- Structure Length / Swing Length — use the same values as your structure indicator so the table matches what you see on the chart.
- Timeframes — up to 4, each can be switched on/off and set to any timeframe.
- Visual — Simple/Full mode, table position, text size, colors.

NOTES
- Breaks are evaluated on the current bar's close, so an event can appear intrabar and disappear if the candle does not close beyond the level. Wait for the candle close before acting.
- Pivots need Structure Length bars on each side to confirm, so pivot levels appear with that delay.
- Timeframes lower than the chart timeframe work but with limited history; best used on your lowest execution timeframe.
- One Structure/Swing Length value is applied to all timeframes.

This tool is for chart analysis and education only. It is not financial advice and does not generate buy/sell signals on its own.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
// CONTINO - Structure Dashboard
// Misma logica de estructura que "CONTINO - ICT MASTER" (BoS/MSS por cierre + swings HH/HL/LH/LL),
// leida en varios timeframes a la vez y mostrada en una tabla.
//@version=6
indicator("CONTINO - Structure Dashboard", overlay = true)

// ==============================================================================
// INPUTS
// ==============================================================================
var G_STRUCT = "Estructura (usar los mismos valores que el MASTER)"
structLength = input.int(5,  "Structure Length (BOS/MSS)", minval = 1, group = G_STRUCT)
swingLength  = input.int(14, "Swing Length (HH/HL/LH/LL)", minval = 1, group = G_STRUCT)

var G_TF = "Timeframes"
use1 = input.bool(true,  "", inline = "t1", group = G_TF)
tf1  = input.timeframe("60", "TF 1", inline = "t1", group = G_TF)
use2 = input.bool(true,  "", inline = "t2", group = G_TF)
tf2  = input.timeframe("15", "TF 2", inline = "t2", group = G_TF)
use3 = input.bool(false, "", inline = "t3", group = G_TF)
tf3  = input.timeframe("5",  "TF 3", inline = "t3", group = G_TF)
use4 = input.bool(true,  "", inline = "t4", group = G_TF)
tf4  = input.timeframe("1",  "TF 4", inline = "t4", group = G_TF)

var G_VIS = "Visual"
modeIn   = input.string("Sencillo", "Modo visual", options = ["Sencillo", "Completo"], group = G_VIS)
posIn    = input.string("Top Right", "Posicion", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left", "Bottom Center"], group = G_VIS)
sizeIn   = input.string("Small", "Tamano de texto", options = ["Tiny", "Small", "Normal"], group = G_VIS)
showInv  = input.bool(true, "Completo: mostrar invalidacion (MSS)", group = G_VIS)
bullCol  = input.color(color.new(#089981, 0), "Alcista", inline = "c", group = G_VIS)
bearCol  = input.color(color.new(#f23645, 0), "Bajista", inline = "c", group = G_VIS)

bool simple = modeIn == "Sencillo"

// ==============================================================================
// LOGICA DE ESTRUCTURA (copia fiel del MASTER, sin dibujos)
// ==============================================================================
structState(int sLen, int swLen) =>
    var int   tr       = 0
    var float lph      = na
    var bool  phb      = true
    var float lpl      = na
    var bool  plb      = true
    var string lastEvt = "—"
    var float lastLvl  = na
    var int   lastBar  = na
    var float pSwH     = na
    var float lSwH     = na
    var float pSwL     = na
    var float lSwL     = na

    sph = ta.pivothigh(high, sLen, sLen)
    spl = ta.pivotlow(low, sLen, sLen)
    swh = ta.pivothigh(high, swLen, swLen)
    swl = ta.pivotlow(low, swLen, swLen)

    if not na(swh)
        pSwH := lSwH
        lSwH := swh
    if not na(swl)
        pSwL := lSwL
        lSwL := swl

    if not na(sph)
        lph := sph
        phb := false
    if not na(spl)
        lpl := spl
        plb := false

    if not na(lph) and not phb and close > lph
        lastEvt := tr == -1 ? "MSS ▲" : "BoS ▲"
        tr      := 1
        lastLvl := lph
        lastBar := bar_index
        phb     := true

    if not na(lpl) and not plb and close < lpl
        lastEvt := tr == 1 ? "MSS ▼" : "BoS ▼"
        tr      := -1
        lastLvl := lpl
        lastBar := bar_index
        plb     := true

    int barsAgo = na(lastBar) ? na : bar_index - lastBar
    string hiTag = na(lSwH) ? "—" : (na(pSwH) or lSwH > pSwH) ? "HH" : "LH"
    string loTag = na(lSwL) ? "—" : (na(pSwL) or lSwL > pSwL) ? "HL" : "LL"
    float inval = tr == 1 ? (plb ? na : lpl) : tr == -1 ? (phb ? na : lph) : na

    [tr, lastEvt, lastLvl, barsAgo, hiTag, loTag, inval]

[t1, e1, v1, a1, h1, o1, i1] = request.security(syminfo.tickerid, tf1, structState(structLength, swingLength))
[t2, e2, v2, a2, h2, o2, i2] = request.security(syminfo.tickerid, tf2, structState(structLength, swingLength))
[t3, e3, v3, a3, h3, o3, i3] = request.security(syminfo.tickerid, tf3, structState(structLength, swingLength))
[t4, e4, v4, a4, h4, o4, i4] = request.security(syminfo.tickerid, tf4, structState(structLength, swingLength))

// ==============================================================================
// ALINEACION
// ==============================================================================
int active = (use1 ? 1 : 0) + (use2 ? 1 : 0) + (use3 ? 1 : 0) + (use4 ? 1 : 0)
int bulls  = (use1 and t1 == 1 ? 1 : 0) + (use2 and t2 == 1 ? 1 : 0) + (use3 and t3 == 1 ? 1 : 0) + (use4 and t4 == 1 ? 1 : 0)
int bears  = (use1 and t1 == -1 ? 1 : 0) + (use2 and t2 == -1 ? 1 : 0) + (use3 and t3 == -1 ? 1 : 0) + (use4 and t4 == -1 ? 1 : 0)
bool fullBull = active > 0 and bulls == active
bool fullBear = active > 0 and bears == active

alertcondition(fullBull and not fullBull[1], "Estructura alineada ALCISTA", "CONTINO: todos los TF en estructura alcista")
alertcondition(fullBear and not fullBear[1], "Estructura alineada BAJISTA", "CONTINO: todos los TF en estructura bajista")

// ==============================================================================
// TABLA
// ==============================================================================
getPos(string p) =>
    switch p
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Bottom Right"  => position.bottom_right
        "Top Left"      => position.top_left
        "Middle Left"   => position.middle_left
        "Bottom Left"   => position.bottom_left
        => position.bottom_center

getSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    s >= 86400 ? tf : s >= 3600 ? "H" + str.tostring(math.round(s / 3600)) : "M" + str.tostring(math.round(s / 60))

fmt(float x) => na(x) ? "—" : str.tostring(x, format.mintick)

var table tb = table.new(getPos(posIn), 7, 6, bgcolor = chart.bg_color, border_color = chart.fg_color, frame_color = chart.fg_color, frame_width = 1, border_width = 1)

fillRow(int row, string tf, int tr, string evt, float lvl, int ago, string hi, string lo, float inval) =>
    txtSz = getSize(sizeIn)
    color c = tr == 1 ? bullCol : tr == -1 ? bearCol : color.gray
    table.cell(tb, 0, row, tfLabel(tf), text_color = chart.fg_color, text_size = txtSz)
    if simple
        table.cell(tb, 1, row, evt, text_color = color.white, bgcolor = c, text_size = txtSz)
    else
        string trTxt = tr == 1 ? "ALCISTA" : tr == -1 ? "BAJISTA" : "—"
        string invTxt = na(inval) ? "—" : (tr == 1 ? "< " : "> ") + fmt(inval)
        table.cell(tb, 1, row, trTxt, text_color = color.white, bgcolor = c, text_size = txtSz)
        table.cell(tb, 2, row, evt, text_color = c, text_size = txtSz)
        table.cell(tb, 3, row, fmt(lvl), text_color = chart.fg_color, text_size = txtSz)
        table.cell(tb, 4, row, na(ago) ? "—" : str.tostring(ago), text_color = chart.fg_color, text_size = txtSz)
        table.cell(tb, 5, row, hi + " / " + lo, text_color = chart.fg_color, text_size = txtSz)
        if showInv
            table.cell(tb, 6, row, invTxt, text_color = chart.fg_color, text_size = txtSz)

if barstate.islast
    table.clear(tb, 0, 0, 6, 5)
    txtSz = getSize(sizeIn)
    int row = 0

    if not simple
        table.cell(tb, 0, 0, "TF",           text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        table.cell(tb, 1, 0, "Estructura",   text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        table.cell(tb, 2, 0, "Ultimo",       text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        table.cell(tb, 3, 0, "Nivel roto",   text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        table.cell(tb, 4, 0, "Hace (velas)", text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        table.cell(tb, 5, 0, "Swings",       text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        if showInv
            table.cell(tb, 6, 0, "MSS si cierra", text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = txtSz)
        row := 1

    if use1
        fillRow(row, tf1, t1, e1, v1, a1, h1, o1, i1)
        row += 1
    if use2
        fillRow(row, tf2, t2, e2, v2, a2, h2, o2, i2)
        row += 1
    if use3
        fillRow(row, tf3, t3, e3, v3, a3, h3, o3, i3)
        row += 1
    if use4
        fillRow(row, tf4, t4, e4, v4, a4, h4, o4, i4)
        row += 1

    string alignTxt = fullBull ? "ALINEADO ▲" : fullBear ? "ALINEADO ▼" : "MIXTO (" + str.tostring(bulls) + "▲ / " + str.tostring(bears) + "▼)"
    color alignCol = fullBull ? bullCol : fullBear ? bearCol : color.gray
    int lastCol = simple ? 1 : (showInv ? 6 : 5)
    table.cell(tb, 0, row, alignTxt, text_color = color.white, bgcolor = alignCol, text_size = txtSz)
    table.merge_cells(tb, 0, row, lastCol, row)
````
