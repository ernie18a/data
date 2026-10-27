# Delta Divergenza Footprint REI X 080526

- url: https://www.tradingview.com/script/8Vvrn9mX/
- type: indicator
- pine_id: PUB;6f2df85281594dc8b2e3c5d916635e94
- version: 1.0

## Description

questo script trova divergenze tra pressione compratori/aggressivi e direzione del prezzo, trova il giusto settaggio secondo strumento e time frame (consiglio da 1 minuto ad 1 h max) e affina i settaggi per non avere troppi segnali ma solo i migliori, testalo a favore di trend di time frame superiore e reversal del time frame inferiore o anche semplicemente reversal e condividi le tue osservazioni da trader. buon lavoro

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║   DELTA DIVERGENZA — FOOTPRINT NATIVO [No Repaint]  v2.4        ║
// ║                                                                  ║
// ║  SORGENTE DELTA:                                                 ║
// ║   1. request.footprint() → delta reale bid/ask                  ║
// ║      Richiede piano Premium/Ultimate + feed IB                   ║
// ║   2. Fallback automatico → delta stimato (posizione close)       ║
// ║                                                                  ║
// ║  ANTI-REPAINTING:                                                ║
// ║   - ta.pivotlow/high con rightbars=0                            ║
// ║   - Segnali sulla barra corrente di conferma                     ║
// ║   - Alert solo su bar_close                                      ║
// ╚══════════════════════════════════════════════════════════════════╝

//@version=6
indicator("Delta Divergenza Footprint REI X 080526[No Repaint]", overlay=true, max_lines_count=500, max_labels_count=500)


// ═══════════════════════════════════════════════════════════════════
// GRUPPO 1 — FOOTPRINT & DELTA
// ═══════════════════════════════════════════════════════════════════
grp_fp = "═══ Footprint & Delta ═══"

int ticksPerRiga = input.int(5, "Ticks per Riga Footprint", minval=1, maxval=500,
     group=grp_fp,
     tooltip="Numero di tick per ogni riga del footprint.\n" +
             "Valori consigliati:\n" +
             "  FDAX 2min → 3  |  FDAX 3min → 5\n" +
             "  ES   2min → 6  |  ES   3min → 8\n" +
             "  NQ   2min → 8  |  NQ   3min → 12")

int vaPercent = input.int(70, "Value Area %", minval=1, maxval=100,
     group=grp_fp,
     tooltip="Percentuale di volume per calcolo Value Area. Standard: 70%.")

int periodoSmooth = input.int(2, "Smoothing Delta (barre)", minval=1, maxval=10,
     group=grp_fp,
     tooltip="EMA sul delta grezzo. 1=nessuno smoothing, 2-3=consigliato per 2-3min futures.")


// ═══════════════════════════════════════════════════════════════════
// GRUPPO 2 — RILEVAMENTO PIVOT
// ═══════════════════════════════════════════════════════════════════
grp_pivot = "═══ Rilevamento Pivot ═══"

int lookbackPivot = input.int(10, "Lookback Pivot (barre a sinistra)", minval=2, maxval=50,
     group=grp_pivot,
     tooltip="Barre a sinistra per confermare un pivot. rightbars=0: zero repainting.\nConsigliato 2-3min futures: 10-12.")

int maxDistanza = input.int(50, "Distanza massima tra pivot (barre)", minval=10, maxval=300,
     group=grp_pivot,
     tooltip="Distanza massima in barre tra i due pivot confrontati. Consigliato: 40-60.")


// ═══════════════════════════════════════════════════════════════════
// GRUPPO 3 — FILTRI QUALITÀ
// ═══════════════════════════════════════════════════════════════════
grp_filter = "═══ Filtri Qualità ═══"

float minVariazioneDelta = input.float(25.0, "Variazione minima Delta %", minval=0.0, maxval=100.0,
     group=grp_filter,
     tooltip="Differenza % minima tra i due delta pivot. 25-35% = solo divergenze significative.")

bool usaFiltroVolume = input.bool(true, "Abilita filtro volume", group=grp_filter)

float moltiplicatoreVol = input.float(1.0, "Volume minimo (x Media)", minval=0.1, step=0.1,
     group=grp_filter,
     tooltip="Volume pivot >= media × questo valore. 1.0 = almeno pari alla media.")

int periodoMediaVol = input.int(20, "Periodo media volume", minval=5, group=grp_filter)

bool usaFiltroCVD = input.bool(true, "Abilita filtro CVD", group=grp_filter,
     tooltip="CVD deve essere allineato con la direzione della divergenza. Riduce i falsi segnali.")

int periodoCVDBaseline = input.int(20, "Periodo baseline CVD", minval=5, maxval=50, group=grp_filter)


// ═══════════════════════════════════════════════════════════════════
// GRUPPO 4 — VISUALIZZAZIONE
// ═══════════════════════════════════════════════════════════════════
grp_style = "═══ Visualizzazione ═══"

bool mostraBull        = input.bool(true,  "Mostra Divergenza Rialzista", group=grp_style)
bool mostraBear        = input.bool(true,  "Mostra Divergenza Ribassista", group=grp_style)
bool mostraHidden      = input.bool(false, "Mostra Divergenza Nascosta", group=grp_style)
bool mostraPanel       = input.bool(true,  "Mostra pannello informazioni", group=grp_style)
bool mostraSfondo      = input.bool(true,  "Mostra sfondo colorato barre segnale", group=grp_style)

color coloreBull       = input.color(color.new(#00E676, 0), "Colore divergenza rialzista", group=grp_style)
color coloreBear       = input.color(color.new(#FF5252, 0), "Colore divergenza ribassista", group=grp_style)
int trasparenzaHidden  = input.int(65, "Trasparenza divergenze nascoste", minval=0, maxval=100, group=grp_style)


// ═══════════════════════════════════════════════════════════════════
// GRUPPO 5 — ALERT
// ═══════════════════════════════════════════════════════════════════
grp_alert = "═══ Alert ═══"
bool alertAbilitato = input.bool(true, "Abilita alert automatici (a candela chiusa)", group=grp_alert)


// ═══════════════════════════════════════════════════════════════════
// CALCOLO DELTA — FOOTPRINT NATIVO CON FALLBACK
// ═══════════════════════════════════════════════════════════════════
var bool usaFootprintReale = false

footprint fp = request.footprint(ticksPerRiga, vaPercent)
float deltaFP = not na(fp) ? fp.delta() : na

deltaStimato() =>
    float rangeBar       = math.max(high - low, syminfo.mintick)
    float posizioneClose = (close - low) / rangeBar
    volume * (2.0 * posizioneClose - 1.0)

float deltaGrezzo     = not na(deltaFP) ? deltaFP : deltaStimato()
usaFootprintReale    := not na(deltaFP)

float delta            = ta.ema(deltaGrezzo, periodoSmooth)
float cumDelta         = ta.cum(deltaGrezzo)
float cvdBaseline      = ta.sma(cumDelta, periodoCVDBaseline)
bool  cvdSopraBaseline = cumDelta > cvdBaseline


// ═══════════════════════════════════════════════════════════════════
// FILTRO VOLUME
// ═══════════════════════════════════════════════════════════════════
float mediaVolume = ta.sma(volume, periodoMediaVol)
bool  volumeOk    = not usaFiltroVolume or (volume >= mediaVolume * moltiplicatoreVol)


// ═══════════════════════════════════════════════════════════════════
// RILEVAMENTO PIVOT — rightbars=0, ZERO LOOKAHEAD
// ═══════════════════════════════════════════════════════════════════
float pivotMin = ta.pivotlow( low,  lookbackPivot, 0)
float pivotMax = ta.pivothigh(high, lookbackPivot, 0)


// ═══════════════════════════════════════════════════════════════════
// MOTORE DIVERGENZA
// ═══════════════════════════════════════════════════════════════════
var float ultimoMinPrezzo = na
var float ultimoMinDelta  = na
var int   ultimoMinBarra  = na

var float ultimoMaxPrezzo = na
var float ultimoMaxDelta  = na
var int   ultimoMaxBarra  = na

var bool divRialzista      = false
var bool divRibassista     = false
var bool divNascostaRialz  = false
var bool divNascostaRibass = false

divRialzista      := false
divRibassista     := false
divNascostaRialz  := false
divNascostaRibass := false

var int   lineaX1 = na
var float lineaY1 = na
var int   lineaX2 = na
var float lineaY2 = na


// ── DIVERGENZA RIALZISTA ────────────────────────────────────────
if not na(pivotMin)
    float prezzoCorrente = low
    float deltaCorrente  = delta
    int   barraCorrente  = bar_index

    if not na(ultimoMinPrezzo) and (barraCorrente - ultimoMinBarra) <= maxDistanza
        float varDelta    = math.abs(deltaCorrente - ultimoMinDelta) / math.max(math.abs(ultimoMinDelta), 1) * 100
        bool cvdAllineato = not usaFiltroCVD or cvdSopraBaseline

        if prezzoCorrente < ultimoMinPrezzo and deltaCorrente > ultimoMinDelta
            if varDelta >= minVariazioneDelta and volumeOk and cvdAllineato
                divRialzista := true
                lineaX1 := ultimoMinBarra
                lineaY1 := ultimoMinPrezzo
                lineaX2 := barraCorrente
                lineaY2 := prezzoCorrente

        if mostraHidden and prezzoCorrente > ultimoMinPrezzo and deltaCorrente < ultimoMinDelta
            if varDelta >= minVariazioneDelta and volumeOk
                divNascostaRialz := true
                lineaX1 := ultimoMinBarra
                lineaY1 := ultimoMinPrezzo
                lineaX2 := barraCorrente
                lineaY2 := prezzoCorrente

    ultimoMinPrezzo := prezzoCorrente
    ultimoMinDelta  := deltaCorrente
    ultimoMinBarra  := barraCorrente


// ── DIVERGENZA RIBASSISTA ───────────────────────────────────────
if not na(pivotMax)
    float prezzoCorrente = high
    float deltaCorrente  = delta
    int   barraCorrente  = bar_index

    if not na(ultimoMaxPrezzo) and (barraCorrente - ultimoMaxBarra) <= maxDistanza
        float varDelta    = math.abs(deltaCorrente - ultimoMaxDelta) / math.max(math.abs(ultimoMaxDelta), 1) * 100
        bool cvdAllineato = not usaFiltroCVD or not cvdSopraBaseline

        if prezzoCorrente > ultimoMaxPrezzo and deltaCorrente < ultimoMaxDelta
            if varDelta >= minVariazioneDelta and volumeOk and cvdAllineato
                divRibassista := true
                lineaX1 := ultimoMaxBarra
                lineaY1 := ultimoMaxPrezzo
                lineaX2 := barraCorrente
                lineaY2 := prezzoCorrente

        if mostraHidden and prezzoCorrente < ultimoMaxPrezzo and deltaCorrente > ultimoMaxDelta
            if varDelta >= minVariazioneDelta and volumeOk
                divNascostaRibass := true
                lineaX1 := ultimoMaxBarra
                lineaY1 := ultimoMaxPrezzo
                lineaX2 := barraCorrente
                lineaY2 := prezzoCorrente

    ultimoMaxPrezzo := prezzoCorrente
    ultimoMaxDelta  := deltaCorrente
    ultimoMaxBarra  := barraCorrente


// ═══════════════════════════════════════════════════════════════════
// DISEGNO
// ═══════════════════════════════════════════════════════════════════
if divRialzista and mostraBull
    label.new(bar_index, low,
         usaFootprintReale ? "▲ Bull\nΔ Reale" : "▲ Bull\nΔ Stim.",
         style=label.style_label_up, color=coloreBull,
         textcolor=color.white, size=size.small)
    line.new(lineaX1, lineaY1, lineaX2, lineaY2,
         color=coloreBull, width=2, style=line.style_solid)

if divRibassista and mostraBear
    label.new(bar_index, high,
         usaFootprintReale ? "▼ Bear\nΔ Reale" : "▼ Bear\nΔ Stim.",
         style=label.style_label_down, color=coloreBear,
         textcolor=color.white, size=size.small)
    line.new(lineaX1, lineaY1, lineaX2, lineaY2,
         color=coloreBear, width=2, style=line.style_solid)

if divNascostaRialz and mostraHidden
    color coloreH = color.new(coloreBull, trasparenzaHidden)
    label.new(bar_index, low, "▲ H.Bull\nΔ Div",
         style=label.style_label_up, color=coloreH,
         textcolor=color.white, size=size.tiny)
    line.new(lineaX1, lineaY1, lineaX2, lineaY2,
         color=coloreH, width=1, style=line.style_dashed)

if divNascostaRibass and mostraHidden
    color coloreH = color.new(coloreBear, trasparenzaHidden)
    label.new(bar_index, high, "▼ H.Bear\nΔ Div",
         style=label.style_label_down, color=coloreH,
         textcolor=color.white, size=size.tiny)
    line.new(lineaX1, lineaY1, lineaX2, lineaY2,
         color=coloreH, width=1, style=line.style_dashed)


// ═══════════════════════════════════════════════════════════════════
// SFONDO BARRE
// ═══════════════════════════════════════════════════════════════════
barcolor(divRialzista  and mostraBull and mostraSfondo ? coloreBull :
         divRibassista and mostraBear and mostraSfondo ? coloreBear : na)
bgcolor(divRialzista  and mostraBull and mostraSfondo ? color.new(coloreBull, 88) : na,
         title="Sfondo divergenza rialzista")
bgcolor(divRibassista and mostraBear and mostraSfondo ? color.new(coloreBear, 88) : na,
         title="Sfondo divergenza ribassista")


// ═══════════════════════════════════════════════════════════════════
// PANNELLO INFORMAZIONI — posizione.bottom_left
// ═══════════════════════════════════════════════════════════════════
if barstate.islast and mostraPanel
    var table pannello = table.new(position.bottom_left, 2, 8,
         bgcolor=color.new(#0D1117, 8),
         border_width=1,
         border_color=color.new(color.gray, 60))

    table.cell(pannello, 0, 0, "Fonte Δ",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(#0D1117, 0))
    table.cell(pannello, 1, 0,
         usaFootprintReale ? "✅ REALE" : "⚠️ STIMATO",
         text_color=usaFootprintReale ? #00E676 : #FFB300,
         text_size=size.small, bgcolor=color.new(#0D1117, 0))

    table.cell(pannello, 0, 1, "Delta",     text_color=color.silver, text_size=size.small)
    table.cell(pannello, 1, 1, str.tostring(math.round(delta, 0)),
         text_color=delta >= 0 ? #00E676 : #FF5252, text_size=size.small)

    table.cell(pannello, 0, 2, "Δ Cum.",    text_color=color.silver, text_size=size.small)
    table.cell(pannello, 1, 2, str.tostring(math.round(cumDelta, 0)),
         text_color=cvdSopraBaseline ? #00E676 : #FF5252, text_size=size.small)

    table.cell(pannello, 0, 3, "Vol/Media", text_color=color.silver, text_size=size.small)
    table.cell(pannello, 1, 3, str.tostring(math.round(volume / mediaVolume, 2)) + "x",
         text_color=volume >= mediaVolume ? #00E676 : color.gray, text_size=size.small)

    table.cell(pannello, 0, 4, "CVD Trend", text_color=color.silver, text_size=size.small)
    table.cell(pannello, 1, 4, cvdSopraBaseline ? "▲ Rialz." : "▼ Ribass.",
         text_color=cvdSopraBaseline ? #00E676 : #FF5252, text_size=size.small)

    table.cell(pannello, 0, 5, "Lookback",
         text_color=color.new(color.gray, 30), text_size=size.tiny)
    table.cell(pannello, 1, 5, str.tostring(lookbackPivot) + " | right=0",
         text_color=color.new(color.gray, 30), text_size=size.tiny)

    table.cell(pannello, 0, 6, "Δ min %",
         text_color=color.new(color.gray, 30), text_size=size.tiny)
    table.cell(pannello, 1, 6, str.tostring(minVariazioneDelta) + "%",
         text_color=color.new(color.gray, 30), text_size=size.tiny)

    table.cell(pannello, 0, 7, "Repaint",
         text_color=color.new(color.gray, 30), text_size=size.tiny)
    table.cell(pannello, 1, 7, "✔ OFF",
         text_color=#00E676, text_size=size.tiny)


// ═══════════════════════════════════════════════════════════════════
// ALERT
// ═══════════════════════════════════════════════════════════════════
alertcondition(divRialzista,      "Divergenza Rialzista Delta",    "▲ Divergenza RIALZISTA — Prezzo lower low, Delta higher low")
alertcondition(divRibassista,     "Divergenza Ribassista Delta",    "▼ Divergenza RIBASSISTA — Prezzo higher high, Delta lower high")
alertcondition(divNascostaRialz,  "Divergenza Nascosta Rialzista",  "▲ Divergenza NASCOSTA RIALZISTA Delta")
alertcondition(divNascostaRibass, "Divergenza Nascosta Ribassista", "▼ Divergenza NASCOSTA RIBASSISTA Delta")

if alertAbilitato and divRialzista
    alert("▲ Divergenza RIALZISTA Delta @ " + str.tostring(close) +
         (usaFootprintReale ? " [FP Reale]" : " [Stimato]"),
         alert.freq_once_per_bar_close)
if alertAbilitato and divRibassista
    alert("▼ Divergenza RIBASSISTA Delta @ " + str.tostring(close) +
         (usaFootprintReale ? " [FP Reale]" : " [Stimato]"),
         alert.freq_once_per_bar_close)
````
