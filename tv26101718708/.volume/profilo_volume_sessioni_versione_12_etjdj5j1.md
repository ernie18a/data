# Profilo Volume + Sessioni versione 1.2

- url: https://www.tradingview.com/script/ETjdJ5J1/
- type: indicator
- pine_id: PUB;c07f133202ce4b009ef8ff072d22e5a3
- version: 4.0

## Description

Profilo Volume + Range Sessioni, lavora su base fuso orario Europa/Roma
Ho inserito tooltip in modo tale da poter impostare bene lo script sulla base dei vostri parametri ideali
Aggiornerò continuamente lo script, quindi cercate di aggiornarlo se tradingview vi da avviso di aggiornamento disponibile
per qualsiasi richiesta, bug o miglioramenti scrivete pure nei commenti 
spero che possa esservi di grande aiuto

## Source Code

````pine
//@version=6
indicator("Profilo Volume + Sessioni (versione 1.4)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// ©️ Mirkoworz
// Script: Profilo Volume Asia + Box Sessioni - Europe/Rome

//
// Questo indicatore calcola un Volume Profile giornaliero partendo dall'inizio della sessione Asia,
// usando il fuso orario Europe/Rome, e disegna anche i box delle principali sessioni operative:
// Asia, Londra e New York.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT PRINCIPALI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fusoOrario = input.string("Europe/Rome", "Fuso Orario", group="01. Impostazioni Base", tooltip="Fuso orario usato per calcolare inizio Asia, Volume Profile e box sessioni. Consigliato: Europe/Rome.")
giorniStorico = input.int(5, "Giorni Storico da Mostrare", minval=1, maxval=30, group="01. Impostazioni Base", tooltip="Mostra solo gli ultimi N giorni di Volume Profile e box sessioni. Default consigliato: 5.")

mostraProfilo = input.bool(true, "Mostra Volume Profile", group="02. Volume Profile", tooltip="Attiva/disattiva il Volume Profile calcolato da inizio Asia.")
mostraBoxProfilo = input.bool(true, "Mostra Box Profilo", group="02. Volume Profile", tooltip="Mostra il box massimo/minimo del periodo usato per il Volume Profile.")
mostraPoc = input.bool(true, "Mostra POC", group="02. Volume Profile", tooltip="Mostra il livello con maggior volume della sessione.")
mostraVA = input.bool(true, "Mostra VAH / VAL", group="02. Volume Profile", tooltip="Mostra Value Area High e Value Area Low.")
mostraLive = input.bool(true, "Mostra Profilo Live", group="02. Volume Profile", tooltip="Aggiorna in tempo reale il profilo della sessione corrente.")

oraAsia = input.int(0, "Ora Inizio Calcolo Asia", minval=0, maxval=23, group="03. Orario Calcolo Profilo", tooltip="Ora da cui parte il calcolo del Volume Profile.")
minutoAsia = input.int(0, "Minuto Inizio Calcolo Asia", minval=0, maxval=59, group="03. Orario Calcolo Profilo", tooltip="Minuto da cui parte il calcolo. Usa 0 per 00:00 oppure 15 per 00:15.")

risoluzione = input.int(30, "Risoluzione Profilo", minval=5, maxval=80, group="04. Parametri Volume Profile", tooltip="Numero di fasce del Volume Profile. Più alto = più preciso ma più pesante.")
percentualeVA = input.int(70, "Value Area %", minval=1, maxval=100, group="04. Parametri Volume Profile", tooltip="Percentuale di volume usata per calcolare VAH/VAL. Standard: 70%.")
larghezzaProfilo = input.int(35, "Larghezza Profilo %", minval=5, maxval=100, group="04. Parametri Volume Profile", tooltip="Larghezza grafica del Volume Profile rispetto alla sessione.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT BOX SESSIONI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mostraBoxAsia = input.bool(true, "Mostra Box Asia", group="05. Box Sessioni", tooltip="Disegna il box della sessione asiatica.")
mostraBoxLondra = input.bool(true, "Mostra Box Londra", group="05. Box Sessioni", tooltip="Disegna il box della sessione Londra.")
mostraBoxNewYork = input.bool(true, "Mostra Box New York", group="05. Box Sessioni", tooltip="Disegna il box della sessione New York.")

orarioAsia = input.session("0000-0700", "Orario Asia", group="06. Orari Box Sessioni", tooltip="Orario sessione Asia secondo il fuso selezionato.")
orarioLondra = input.session("0800-1700", "Orario Londra", group="06. Orari Box Sessioni", tooltip="Orario sessione Londra secondo il fuso selezionato.")
orarioNewYork = input.session("1430-2200", "Orario New York", group="06. Orari Box Sessioni", tooltip="Orario sessione New York secondo il fuso selezionato.")

mostraLabelSessioni = input.bool(true, "Mostra Nome Sessione", group="07. Etichette", tooltip="Mostra il nome della sessione sopra il box.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORI E STILE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
coloreVolumeUp = input.color(color.new(color.green, 55), "Volume Rialzista", group="08. Colori Volume Profile")
coloreVolumeDown = input.color(color.new(color.red, 55), "Volume Ribassista", group="08. Colori Volume Profile")
coloreBoxProfilo = input.color(color.new(color.orange, 90), "Box Profilo", group="08. Colori Volume Profile")
colorePoc = input.color(color.red, "POC", group="08. Colori Volume Profile")
coloreVA = input.color(color.aqua, "VAH / VAL", group="08. Colori Volume Profile")

coloreAsia = input.color(color.new(color.yellow, 88), "Box Asia", group="09. Colori Box Sessioni")
coloreLondra = input.color(color.new(color.blue, 88), "Box Londra", group="09. Colori Box Sessioni")
coloreNewYork = input.color(color.new(color.purple, 88), "Box New York", group="09. Colori Box Sessioni")

spessoreBox = input.int(1, "Spessore Box", minval=1, maxval=5, group="10. Stile")
spessorePoc = input.int(2, "Spessore POC", minval=1, maxval=5, group="10. Stile")
spessoreVA = input.int(1, "Spessore VAH / VAL", minval=1, maxval=5, group="10. Stile")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FILTRO STORICO
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int millisecondiGiorno = 24 * 60 * 60 * 1000
int tempoLimiteStorico = timenow - giorniStorico * millisecondiGiorno
bool barraDentroStorico = time >= tempoLimiteStorico

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VARIABILI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int indiceInizioAsia = na

var float[] volumiUp = array.new_float(risoluzione, 0.0)
var float[] volumiDown = array.new_float(risoluzione, 0.0)
var float[] livelliProfilo = array.new_float(risoluzione, 0.0)

var box[] boxLive = array.new_box()
var line[] lineeLive = array.new_line()
var label[] labelLive = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULIZIA PROFILO LIVE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pulisciLive() =>
    int numeroBox = array.size(boxLive)
    if numeroBox > 0
        for i = 0 to numeroBox - 1
            box.delete(array.get(boxLive, i))

    int numeroLinee = array.size(lineeLive)
    if numeroLinee > 0
        for i = 0 to numeroLinee - 1
            line.delete(array.get(lineeLive, i))

    int numeroLabel = array.size(labelLive)
    if numeroLabel > 0
        for i = 0 to numeroLabel - 1
            label.delete(array.get(labelLive, i))

    array.clear(boxLive)
    array.clear(lineeLive)
    array.clear(labelLive)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNZIONI VOLUME PROFILE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
aggiungiVolumeAllaZona(float o, float h, float l, float c, float v, float massimo, float minimo) =>
    float rangeCandela = math.max(h - l, syminfo.mintick)
    float passo = math.max((massimo - minimo) / risoluzione, syminfo.mintick)
    bool candelaRialzista = c >= o

    for i = 0 to risoluzione - 1
        float zonaAlta = massimo - passo * i
        float zonaBassa = zonaAlta - passo
        float parteDentro = math.max(math.min(h, zonaAlta) - math.max(l, zonaBassa), 0.0)
        float volumeZona = parteDentro / rangeCandela * v

        if candelaRialzista
            array.set(volumiUp, i, array.get(volumiUp, i) + volumeZona)
        else
            array.set(volumiDown, i, array.get(volumiDown, i) + volumeZona)

calcolaProfilo(int numeroBarre, int offsetIniziale) =>
    array.fill(volumiUp, 0.0)
    array.fill(volumiDown, 0.0)

    float massimo = na
    float minimo = na

    for j = 0 to numeroBarre - 1
        int off = offsetIniziale + j
        massimo := na(massimo) ? high[off] : math.max(massimo, high[off])
        minimo := na(minimo) ? low[off] : math.min(minimo, low[off])

    float passo = math.max((massimo - minimo) / risoluzione, syminfo.mintick)

    for i = 0 to risoluzione - 1
        array.set(livelliProfilo, i, massimo - passo * i)

    for j = 0 to numeroBarre - 1
        int off = offsetIniziale + j
        aggiungiVolumeAllaZona(open[off], high[off], low[off], close[off], volume[off], massimo, minimo)

    [massimo, minimo, passo]

trovaPoc(float passo) =>
    float volumeMassimo = 0.0
    int indicePoc = 0

    for i = 0 to risoluzione - 1
        float volumeTotale = array.get(volumiUp, i) + array.get(volumiDown, i)
        if volumeTotale > volumeMassimo
            volumeMassimo := volumeTotale
            indicePoc := i

    array.get(livelliProfilo, indicePoc) - passo / 2.0

trovaValueArea(float poc, float passo) =>
    float volumeTotale = array.sum(volumiUp) + array.sum(volumiDown)
    float volumeTarget = volumeTotale * percentualeVA / 100.0

    int indicePoc = 0
    for i = 0 to risoluzione - 1
        float zonaAlta = array.get(livelliProfilo, i)
        float zonaBassa = zonaAlta - passo
        if poc <= zonaAlta and poc >= zonaBassa
            indicePoc := i

    float volumeVA = array.get(volumiUp, indicePoc) + array.get(volumiDown, indicePoc)
    int sopra = indicePoc - 1
    int sotto = indicePoc + 1

    float vah = array.get(livelliProfilo, indicePoc)
    float val = array.get(livelliProfilo, indicePoc) - passo

    while volumeVA < volumeTarget and (sopra >= 0 or sotto < risoluzione)
        float volumeSopra = sopra >= 0 ? array.get(volumiUp, sopra) + array.get(volumiDown, sopra) : -1.0
        float volumeSotto = sotto < risoluzione ? array.get(volumiUp, sotto) + array.get(volumiDown, sotto) : -1.0

        if volumeSopra >= volumeSotto
            volumeVA += volumeSopra
            vah := array.get(livelliProfilo, sopra)
            sopra -= 1
        else
            volumeVA += volumeSotto
            val := array.get(livelliProfilo, sotto) - passo
            sotto += 1

    [vah, val]

disegnaProfilo(int numeroBarre, int offsetIniziale, bool live) =>
    if numeroBarre > 1
        [massimo, minimo, passo] = calcolaProfilo(numeroBarre, offsetIniziale)

        int xSinistra = bar_index - offsetIniziale - numeroBarre + 1
        int xDestra = bar_index - offsetIniziale
        int larghezzaMax = math.max(1, int(numeroBarre * larghezzaProfilo / 100.0))

        float volumeMassimo = 0.0
        for i = 0 to risoluzione - 1
            volumeMassimo := math.max(volumeMassimo, array.get(volumiUp, i) + array.get(volumiDown, i))

        if volumeMassimo > 0
            if mostraProfilo
                for i = 0 to risoluzione - 1
                    float zonaAlta = array.get(livelliProfilo, i)
                    float zonaBassa = zonaAlta - passo
                    float volUp = array.get(volumiUp, i)
                    float volDown = array.get(volumiDown, i)

                    int larghezzaUp = int(larghezzaMax * volUp / volumeMassimo)
                    int larghezzaDown = int(larghezzaMax * volDown / volumeMassimo)

                    box bUp = box.new(xSinistra, zonaAlta, xSinistra + larghezzaUp, zonaBassa, border_width=0, bgcolor=coloreVolumeUp)
                    box bDown = box.new(xSinistra + larghezzaUp, zonaAlta, xSinistra + larghezzaUp + larghezzaDown, zonaBassa, border_width=0, bgcolor=coloreVolumeDown)

                    if live
                        array.push(boxLive, bUp)
                        array.push(boxLive, bDown)

            if mostraBoxProfilo
                box bProfilo = box.new(xSinistra, massimo, xDestra, minimo, border_color=chart.fg_color, border_width=spessoreBox, border_style=line.style_dotted, bgcolor=coloreBoxProfilo)
                if live
                    array.push(boxLive, bProfilo)

            float poc = trovaPoc(passo)
            [vah, val] = trovaValueArea(poc, passo)

            if mostraPoc
                line lPoc = line.new(xSinistra, poc, xDestra, poc, color=colorePoc, width=spessorePoc)
                if live
                    array.push(lineeLive, lPoc)

            if mostraVA
                line lVah = line.new(xSinistra, vah, xDestra, vah, color=coloreVA, width=spessoreVA)
                line lVal = line.new(xSinistra, val, xDestra, val, color=coloreVA, width=spessoreVA)

                if live
                    array.push(lineeLive, lVah)
                    array.push(lineeLive, lVal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNZIONE BOX SESSIONI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disegnaBoxSessione(bool mostra, string sessione, string nome, color coloreSfondo) =>
    var box boxSessione = na
    var label labelSessione = na
    var float massimoSessione = na
    var float minimoSessione = na
    var int inizioSessione = na

    bool dentroSessione = not na(time(timeframe.period, sessione, fusoOrario))
    bool nuovaSessione = dentroSessione and not dentroSessione[1]
    bool sessioneAttiva = dentroSessione and mostra and barraDentroStorico

    if nuovaSessione and mostra and barraDentroStorico
        massimoSessione := high
        minimoSessione := low
        inizioSessione := bar_index
        boxSessione := box.new(inizioSessione, massimoSessione, bar_index, minimoSessione, border_color=chart.fg_color, border_width=spessoreBox, border_style=line.style_dotted, bgcolor=coloreSfondo)

        if mostraLabelSessioni
            labelSessione := label.new(inizioSessione, massimoSessione, nome, style=label.style_label_down, color=color.new(color.black, 100), textcolor=chart.fg_color)

    if sessioneAttiva and not na(boxSessione)
        massimoSessione := math.max(massimoSessione, high)
        minimoSessione := math.min(minimoSessione, low)

        box.set_right(boxSessione, bar_index)
        box.set_top(boxSessione, massimoSessione)
        box.set_bottom(boxSessione, minimoSessione)

        if mostraLabelSessioni and not na(labelSessione)
            label.set_x(labelSessione, int((inizioSessione + bar_index) / 2))
            label.set_y(labelSessione, massimoSessione)

    if not dentroSessione and dentroSessione[1]
        boxSessione := na
        labelSessione := na
        massimoSessione := na
        minimoSessione := na
        inizioSessione := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOGICA INIZIO ASIA PER VOLUME PROFILE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int minutiStartAsia = oraAsia * 60 + minutoAsia
int minutiOra = hour(time, fusoOrario) * 60 + minute(time, fusoOrario)
int minutiPrecedenti = hour(time[1], fusoOrario) * 60 + minute(time[1], fusoOrario)

int giornoCorrente = dayofmonth(time, fusoOrario)
int meseCorrente = month(time, fusoOrario)
int annoCorrente = year(time, fusoOrario)

int giornoPrecedente = dayofmonth(time[1], fusoOrario)
int mesePrecedente = month(time[1], fusoOrario)
int annoPrecedente = year(time[1], fusoOrario)

bool nuovoGiorno = giornoCorrente != giornoPrecedente or meseCorrente != mesePrecedente or annoCorrente != annoPrecedente
bool nuovoInizioAsia = minutiOra >= minutiStartAsia and (minutiPrecedenti < minutiStartAsia or nuovoGiorno)

if na(indiceInizioAsia) and minutiOra >= minutiStartAsia
    indiceInizioAsia := bar_index

if nuovoInizioAsia and not na(indiceInizioAsia) and bar_index > indiceInizioAsia
    pulisciLive()
    int barreSessioneChiusa = bar_index - indiceInizioAsia
    bool sessioneChiusaDentroStorico = time[1] >= tempoLimiteStorico

    if sessioneChiusaDentroStorico
        disegnaProfilo(barreSessioneChiusa, 1, false)

    indiceInizioAsia := bar_index

if barstate.islast and mostraLive and not na(indiceInizioAsia) and barraDentroStorico
    pulisciLive()
    int barreSessioneLive = bar_index - indiceInizioAsia + 1
    disegnaProfilo(barreSessioneLive, 0, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISEGNO BOX SESSIONI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disegnaBoxSessione(mostraBoxAsia, orarioAsia, "Asia", coloreAsia)
disegnaBoxSessione(mostraBoxLondra, orarioLondra, "Londra", coloreLondra)
disegnaBoxSessione(mostraBoxNewYork, orarioNewYork, "New York", coloreNewYork)
````
