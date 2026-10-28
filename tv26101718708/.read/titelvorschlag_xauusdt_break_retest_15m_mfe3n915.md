# Titel-Vorschlag: XAUUSDT Break & Retest (15m)

- url: https://www.tradingview.com/script/MfE3n915/
- type: indicator
- pine_id: PUB;1c20afc12b894848bf70a500de3f2ec2
- version: 2.0

## Description

Break & Retest für XAU/USDT auf dem 15-Minuten-Chart — ein vollständig regelbasierter Price-Action-Indikator, der Ausbrüche an strukturellen Tages-Levels markiert und den anschließenden Retest als Einstieg visualisiert. Jeder Trade wird mit Einstieg, Stop-Loss, Take-Profit und Ergebnis auf dem Chart nachgezeichnet, inklusive einer Statistik-Tabelle.

Idee dahinter
An gebrochenen Schlüssel-Levels liegt realer Orderflow: gefangene Positionen lösen sich auf, neue Trader nutzen den Retest als Einstieg. Statt frei interpretierbarer Linien arbeitet der Indikator mit objektiv definierten Levels und harten Regeln — jedes Signal ist reproduzierbar.

Funktionsweise
Levels: Vortages-Hoch/Tief und die Asien-Range (00–07 UTC)
Break: Eine 15m-Kerze schließt mindestens 0.25 × ATR(14) jenseits des Levels (filtert Docht-Fakeouts)
Retest: Kehrt der Kurs zum Level zurück (Limit am Level), entsteht ein Einstieg — nur innerhalb der Handels-Session (07–21 UTC) und max. 24 Kerzen nach dem Break
Invalidierung: Schließt der Kurs vor dem Retest wieder durch das Level, wird das Setup verworfen
Stop-Loss: 3.0 × ATR hinter dem Level · Take-Profit: 2 R
Konservativ: Trifft eine Kerze SL und TP gleichzeitig, wird sie als Verlust gewertet
Was angezeigt wird
Level-Linien (Vortag & Asien-Range), die verschwinden, sobald sie gebrochen wurden
„B"-Marker am Ausbruch
▲ LONG / ▼ SHORT am Retest-Einstieg mit mitlaufenden SL- (rot) und TP-Linien (grün)
„TP +2R" / „SL -1R"-Label beim Ausgang
Session-Schattierung (07–21 UTC)
Statistik-Tabelle: Trades, Trefferquote, Summe R
Alerts „Long/Short Entry" zum Einrichten eigener Benachrichtigungen
Einstellungen
Alle Parameter sind anpassbar: Break-Schwelle, SL-/TP-Multiplikatoren, Retest-Fenster, Session-Zeiten, Level-Quellen und ATR-Länge. Die Standardwerte entsprechen einer per Walk-Forward (In-Sample / Out-of-Sample) getesteten Konfiguration.

Empfohlene Nutzung
Gedacht für den 15-Minuten-Chart von XAU/USDT. Andere Timeframes oder Symbole verändern Levels und Signale.

⚠️ Hinweis: Dieser Indikator dient ausschließlich zu Bildungs- und Analysezwecken und ist keine Finanz- oder Anlageberatung. Die Darstellung enthält keine Gebühren, Slippage oder Funding-Kosten — reale Ergebnisse weichen ab. Vergangene oder simulierte Resultate sind keine Garantie für zukünftige Entwicklungen. Trading mit gehebelten Produkten birgt ein hohes Verlustrisiko. Triff eigene Entscheidungen und teste auf einem Demokonto.

Ein paar Hinweise:

Ich habe bewusst keine konkreten Gewinn-/Renditezahlen reingeschrieben — TradingView prüft Performance-Claims streng, und vage „getestet"-Formulierungen + Disclaimer sind der sichere Weg.
Bei öffentlicher Veröffentlichung verlangt TradingView i. d. R. eine englische Beschreibung (oder zusätzlich). Sag Bescheid, dann liefere ich dir die englische Version gleich mit.
Wenn du es „Nur auf Einladung" oder privat veröffentlichst, kannst du die Beschreibung kürzer halten.

## Source Code

````pine
//@version=6
// =============================================================================
//  XAUUSDT Break & Retest — visuelle Replik des Live-Bots (strategy_bnr.py)
//  Auf einen 15m XAU/USDT-Chart legen. Bildet die Bot-Engine (Variante I) nach:
//    Levels  : Vortages-Hoch/Tief + Asien-Range (00–07 UTC)
//    Break   : 15m-Close >= 0.25 x ATR(14) jenseits des Levels
//    Retest  : Limit am Level, max. 24 Kerzen, Fill nur in Session 07–21 UTC
//    SL      : 3.0 x ATR hinter dem Level   |   TP : 2 R
//    Fee     : Setup wird übersprungen, wenn Gebühr > 0.25R (enger SL/niedriger ATR)
//    Ties    : SL gewinnt (gleiche Kerze trifft SL+TP -> SL), konservativ
//  Hinweis: visuell, R netto nach Gebühren; ohne Hebel-Cap (R-neutral) und Slippage.
// =============================================================================
indicator("XAUUSDT Break & Retest BITGET 2.0", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ---------- Inputs (Defaults = Bot-Config) ----------
gS = "Strategie"
breakMult  = input.float(0.25, "Break ≥ × ATR",            group=gS, step=0.05)
slMult     = input.float(3.0,  "SL × ATR hinter Level",    group=gS, step=0.25)
tpR        = input.float(2.0,  "TP (R-Vielfaches)",        group=gS, step=0.5)
retestBars = input.int(24,     "Retest-Fenster (Kerzen)",  group=gS, minval=1)
invalMult  = input.float(0.10, "Invalidierung × ATR",      group=gS, step=0.05)
atrLen     = input.int(14,     "ATR-Länge",                group=gS, minval=1)
dedupPct   = input.float(0.25, "Level-Dedup %",            group=gS, step=0.05) / 100.0
makerFee   = input.float(0.02, "Maker-Fee % (Entry)",      group=gS, step=0.01) / 100.0
takerFee   = input.float(0.06, "Taker-Fee % (Exit)",       group=gS, step=0.01) / 100.0
maxFeeR    = input.float(0.25, "Fee-Filter: skip Setup wenn Fee > xR", group=gS, step=0.05)

gL = "Levels"
usePrevDay = input.bool(true, "Vortages-Hoch/Tief",        group=gL)
useAsia    = input.bool(true, "Asien-Range (00–07 UTC)",   group=gL)

gSe = "Session (UTC)"
sessStart = input.int(7,  "Session Start", group=gSe, minval=0, maxval=23)
sessEnd   = input.int(21, "Session Ende",  group=gSe, minval=1, maxval=24)
asiaEnd   = input.int(7,  "Asien-Ende (Start=0)", group=gSe, minval=1, maxval=12)

gV = "Anzeige"
showLevels = input.bool(true, "Levels zeichnen",       group=gV)
showBreaks = input.bool(true, "Break-Marker",          group=gV)
showTable  = input.bool(true, "Statistik-Tabelle",     group=gV)

// ---------- Grunddaten ----------
atr   = ta.atr(atrLen)
utch  = hour(time, "UTC")
inSession = utch >= sessStart and utch < sessEnd
newDay = nz(ta.change(dayofmonth(time, "UTC")), 0) != 0

// ---------- Vortages-Hoch/Tief (manuell, UTC-aligned) ----------
var float curHi = na
var float curLo = na
var float pdh = na
var float pdl = na
if newDay
    pdh := curHi
    pdl := curLo
    curHi := high
    curLo := low
else
    curHi := na(curHi) ? high : math.max(curHi, high)
    curLo := na(curLo) ? low  : math.min(curLo, low)

// ---------- Asien-Range (00–asiaEnd UTC) ----------
var float aHi = na
var float aLo = na
if newDay
    aHi := na
    aLo := na
if utch < asiaEnd
    aHi := na(aHi) ? high : math.max(aHi, high)
    aLo := na(aLo) ? low  : math.min(aLo, low)
asiaReady = utch >= asiaEnd and not na(aHi)

// ---------- Consumed-Flags (täglich zurückgesetzt) ----------
var bool cPdh = false
var bool cPdl = false
var bool cAh  = false
var bool cAl  = false
if newDay
    cPdh := false
    cPdl := false
    cAh  := false
    cAl  := false

// dedup: Asien-Level ignorieren, wenn zu nah am gleichseitigen Vortages-Level
ahDedup = usePrevDay and not na(pdh) and not na(aHi) and math.abs(aHi - pdh) / aHi < dedupPct
alDedup = usePrevDay and not na(pdl) and not na(aLo) and math.abs(aLo - pdl) / aLo < dedupPct

// Aktive Levels (für Break-Scan)
actPdh = usePrevDay and not na(pdh) and not cPdh
actPdl = usePrevDay and not na(pdl) and not cPdl
actAh  = useAsia and asiaReady and utch < sessEnd and not cAh and not ahDedup
actAl  = useAsia and asiaReady and utch < sessEnd and not cAl and not alDedup

// ---------- Zustands-Variablen ----------
var int   posDir   = 0          // 0 flat, 1 long, -1 short
var float posEntry = na
var float posSL    = na
var float posTP    = na
var float posFeeR  = na         // geschätzte Round-Trip-Gebühr in R (für Netto-Stats)
var int   pendDir  = 0
var float pendLvl  = na
var float pendATR  = na
var int   pendBar  = na

var line  enLine = na
var line  slLine = na
var line  tpLine = na

var int   nT = 0
var int   nW = 0
var int   nL = 0
var float sumR = 0.0

// =================== Kern-Logik (nur auf geschlossenen Kerzen) ===================
if barstate.isconfirmed
    // ---- 1) Offene Position verwalten (Ties -> SL) ----
    if posDir != 0
        slHit = posDir == 1 ? low  <= posSL : high >= posSL
        tpHit = posDir == 1 ? high >= posTP : low  <= posTP
        if slHit or tpHit
            win = tpHit and not slHit
            exitPx = win ? posTP : posSL
            line.set_x2(enLine, bar_index)
            line.set_x2(slLine, bar_index)
            line.set_x2(tpLine, bar_index)
            label.new(bar_index, exitPx, win ? "TP +" + str.tostring(tpR, "#.#") + "R" : "SL -1R",
                 color=win ? color.new(color.green, 20) : color.new(color.red, 20),
                 textcolor=color.white, style=win ? label.style_label_down : label.style_label_up,
                 size=size.small)
            nT += 1
            if win
                nW += 1
                sumR += tpR - posFeeR
            else
                nL += 1
                sumR -= 1.0 + posFeeR
            posDir := 0

    // ---- 2) Pending-Setup: auf Retest warten ----
    else if pendDir != 0
        if bar_index - pendBar > retestBars
            pendDir := 0                                   // verfallen
        else if bar_index > pendBar
            touched = pendDir == 1 ? low <= pendLvl : high >= pendLvl
            if touched
                if inSession
                    _sl   = pendDir == 1 ? pendLvl - slMult * pendATR : pendLvl + slMult * pendATR
                    _feeR = (makerFee + takerFee) * pendLvl / math.abs(pendLvl - _sl)
                    // Fee-Filter: enger SL (niedriger ATR) -> Gebuehr frisst Risiko -> skippen
                    if _feeR <= maxFeeR
                        posDir   := pendDir
                        posEntry := pendLvl
                        posSL    := _sl
                        posTP    := pendDir == 1 ? pendLvl + tpR * slMult * pendATR : pendLvl - tpR * slMult * pendATR
                        posFeeR  := _feeR
                        enLine := line.new(bar_index, posEntry, bar_index, posEntry, color=color.new(color.blue, 0), width=2)
                        slLine := line.new(bar_index, posSL, bar_index, posSL, color=color.new(color.red, 0), width=1, style=line.style_dashed)
                        tpLine := line.new(bar_index, posTP, bar_index, posTP, color=color.new(color.green, 0), width=1, style=line.style_dashed)
                        label.new(bar_index, posEntry, (pendDir == 1 ? "▲ LONG " : "▼ SHORT ") + str.tostring(posEntry, format.mintick),
                             color=pendDir == 1 ? color.new(color.green, 0) : color.new(color.red, 0),
                             textcolor=color.white, style=pendDir == 1 ? label.style_label_up : label.style_label_down,
                             size=size.small)
                        // Fill-Kerze: SL kann sofort auslösen (TP nicht) – konservativ
                        slNow = posDir == 1 ? low <= posSL : high >= posSL
                        if slNow
                            line.set_x2(enLine, bar_index)
                            line.set_x2(slLine, bar_index)
                            line.set_x2(tpLine, bar_index)
                            label.new(bar_index, posSL, "SL -1R", color=color.new(color.red, 20),
                                 textcolor=color.white, style=label.style_label_up, size=size.small)
                            nT += 1
                            nL += 1
                            sumR -= 1.0 + posFeeR
                            posDir := 0
                pendDir := 0                               // Retest konsumiert das Setup
            else
                inval = pendDir == 1 ? close < pendLvl - invalMult * pendATR : close > pendLvl + invalMult * pendATR
                if inval
                    pendDir := 0

    // ---- 3) Flach & kein Pending: Break suchen (nächstes aktives Level) ----
    else
        float bestDist = 1.0e15
        float bestLvl  = na
        int   bestDir  = 0
        int   bestId   = 0
        // Resistance (Long-Break: Close über Level + Schwelle)
        if actPdh and close > pdh + breakMult * atr and (close - pdh) < bestDist
            bestDist := close - pdh
            bestLvl := pdh
            bestDir := 1
            bestId := 1
        if actAh and close > aHi + breakMult * atr and (close - aHi) < bestDist
            bestDist := close - aHi
            bestLvl := aHi
            bestDir := 1
            bestId := 3
        // Support (Short-Break: Close unter Level - Schwelle)
        if actPdl and close < pdl - breakMult * atr and (pdl - close) < bestDist
            bestDist := pdl - close
            bestLvl := pdl
            bestDir := -1
            bestId := 2
        if actAl and close < aLo - breakMult * atr and (aLo - close) < bestDist
            bestDist := aLo - close
            bestLvl := aLo
            bestDir := -1
            bestId := 4
        if bestId != 0
            pendDir := bestDir
            pendLvl := bestLvl
            pendATR := atr
            pendBar := bar_index
            cPdh := bestId == 1 ? true : cPdh
            cPdl := bestId == 2 ? true : cPdl
            cAh  := bestId == 3 ? true : cAh
            cAl  := bestId == 4 ? true : cAl
            if showBreaks
                label.new(bar_index, bestDir == 1 ? high : low, "B",
                     color=color.new(color.gray, 30), textcolor=color.white,
                     style=bestDir == 1 ? label.style_label_down : label.style_label_up,
                     size=size.tiny)

    // ---- SL/TP-Linien mitziehen, solange Position offen ----
    if posDir != 0 and not na(slLine)
        line.set_x2(enLine, bar_index)
        line.set_x2(slLine, bar_index)
        line.set_x2(tpLine, bar_index)

// =================== Level-Linien ===================
plot(showLevels and actPdh ? pdh : na, "Vortageshoch", color=color.new(color.red, 0),    style=plot.style_linebr, linewidth=1)
plot(showLevels and actPdl ? pdl : na, "Vortagestief", color=color.new(color.green, 0),  style=plot.style_linebr, linewidth=1)
plot(showLevels and actAh  ? aHi : na, "Asien-Hoch",   color=color.new(color.orange, 0), style=plot.style_linebr, linewidth=1)
plot(showLevels and actAl  ? aLo : na, "Asien-Tief",   color=color.new(color.aqua, 0),   style=plot.style_linebr, linewidth=1)

// Session-Hintergrund
bgcolor(inSession ? color.new(color.blue, 94) : na, title="Session 07–21 UTC")

// =================== Statistik-Tabelle ===================
var table tb = na
if showTable and barstate.islast
    wr = nT > 0 ? nW / nT * 100 : 0.0
    tb := table.new(position.top_right, 2, 6, border_width=1, frame_color=color.gray, frame_width=1)
    table.cell(tb, 0, 0, "Break & Retest", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=size.small)
    table.cell(tb, 1, 0, "", bgcolor=color.new(color.blue, 0))
    table.cell(tb, 0, 1, "Trades", text_size=size.small)
    table.cell(tb, 1, 1, str.tostring(nT), text_size=size.small)
    table.cell(tb, 0, 2, "Gewinne", text_size=size.small)
    table.cell(tb, 1, 2, str.tostring(nW), text_color=color.green, text_size=size.small)
    table.cell(tb, 0, 3, "Verluste", text_size=size.small)
    table.cell(tb, 1, 3, str.tostring(nL), text_color=color.red, text_size=size.small)
    table.cell(tb, 0, 4, "Trefferquote", text_size=size.small)
    table.cell(tb, 1, 4, str.tostring(wr, "#.#") + "%", text_size=size.small)
    table.cell(tb, 0, 5, "Summe R (netto)", text_size=size.small)
    table.cell(tb, 1, 5, str.tostring(sumR, "+#.#;-#.#"), text_color=sumR >= 0 ? color.green : color.red, text_size=size.small)

// =================== Alerts (matchen die Bot-Entries) ===================
longEntry  = posDir == 1  and posDir[1] != 1
shortEntry = posDir == -1 and posDir[1] != -1
alertcondition(longEntry,  "B&R Long Entry",  "Break & Retest LONG Entry am Level")
alertcondition(shortEntry, "B&R Short Entry", "Break & Retest SHORT Entry am Level")
````
