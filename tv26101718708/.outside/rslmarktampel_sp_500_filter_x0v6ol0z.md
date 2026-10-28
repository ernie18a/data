# RSL-Marktampel (S&P 500 Filter)

- url: https://www.tradingview.com/script/x0V6oL0Z/
- type: indicator
- pine_id: PUB;64a7034771354b4b877812b4160ee330
- version: 1.0

## Description

Umsetzung der Marktampel für die RSL-Strategie:

Die RSL-Marktampel (S&P 500 Filter)
Zone GRÜN: „Offensive“
• Bedingung: S&P 500 notiert über dem SMA 26 (Woche) UND
über dem SMA 200 (Tag).
• Marktlage: Stabiler Aufwärtstrend. Die RSL-Strategie entfaltet
ihre volle Kraft.
• Handlung:
◦ Volle Investitionsquote (gemäß deiner Strategie).
◦ Käufe strikt nach RSL-Ranking (z.B. Top 125).
◦ Verkäufe nur bei Abstieg im Ranking oder RSL < 1,0 der
Einzelaktie.
Zone GELB: „Vorsicht & Kaufstopp“
• Bedingung: S&P 500 schließt eine Woche unter dem SMA
26 (Woche) ODER fällt unter den SMA 50 (Tag).
• Marktlage: Erste Risse im Trend. Gefahr einer größeren
Korrektur oder eines beginnenden Crashs.
• Handlung:
◦ Absoluter Kaufstopp: Keine neuen Positionen eröffnen,
egal wie gut das Ranking aussieht.
◦ Selektives Halten: Bestehende Positionen nur halten,
wenn sie selbst noch über ihrem eigenen SMA 26
(Woche) notieren.
◦ Fällt eine Einzelaktie unter ihren SMA 26 (Woche), wird
sie sofort verkauft (unabhängig vom Rankingplatz).
Zone ROT: „Kapitalschutz & Exit“
• Bedingung: S&P 500 schließt die zweite Woche in Folge
unter dem SMA 26 (Woche) ODER notiert unter dem SMA
200 (Tag).
• Marktlage: Bärenmarkt oder Crash-Modus. Hohe Korrelation
(alles fällt gleichzeitig).
• Handlung:
◦ Komplette Liquidation: Alle verbleibenden Positionen
werden verkauft.
◦ 100 % Cash-Quote: Schutz des Kapitals steht über der
Renditechance.
◦ Beobachter-Status: Du wartest an der Seitenlinie, bis
der Markt sich beruhigt.
Der Wiedereinstieg (Zurück nach Grün)
Ein Neustart des Systems erfolgt erst, wenn die Panik abgeklungen
ist:
1. Primärsignal: S&P 500 schließt wieder über dem SMA 26
(Woche).
2. Bestätigung: Ein neues RSL-Ranking wird erstellt. Du kaufst
die Titel, die zu diesem Zeitpunkt die höchste relative Stärke
aufweisen (Achtung: Das sind oft andere als vor dem Crash!).
Zusammenfassung der Timeframes für
TradingView:
• Gesamtmarkt-Check (SPX):
◦ Wochen-Chart: SMA 26 ( Levy-Standard)
◦ Tages-Chart: SMA 200 (Institutionelle Trennlinie zwischen
Bullen- und Bärenmarkt)
• Einzelaktien-Check:
◦ Wochen-Chart: SMA 26 (Identisch mit RSL = 1,0)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Maik1969


//@version=6
indicator("RSL-Marktampel (S&P 500 Filter)", overlay=true, max_labels_count=500, max_boxes_count=500)

// ============================================================
// EINSTELLUNGEN
// ============================================================
useCustomSymbol = input.bool(false, "Eigenes Symbol für Marktampel verwenden",
     tooltip="Wenn deaktiviert, wird automatisch der S&P 500 (SPX) als Filter genutzt – unabhängig davon, welchen Chart du gerade ansiehst.")
marktSymbol     = input.symbol("SP:SPX", "Marktsymbol (Filter)",
     tooltip="Standard: S&P 500. Wird nur verwendet, wenn 'Eigenes Symbol' aktiviert ist.")

smaWeekLen      = input.int(26,  "SMA Wochen-Chart", minval=1)
smaDayShortLen  = input.int(50,  "SMA Tages-Chart (kurz, für Gelb)", minval=1)
smaDayLongLen   = input.int(200, "SMA Tages-Chart (lang, für Grün/Rot)", minval=1)

zeigeSMA        = input.bool(true,  "SMAs auf Marktsymbol einblenden (nur sinnvoll, wenn Chart = Marktsymbol)")
zeigeAmpelBG    = input.bool(true,  "Hintergrundfarbe = Ampelzone")
zeigeWechsel    = input.bool(true,  "Wechsel der Ampelfarbe markieren")
zeigeStatusLabel= input.bool(true,  "Aktuelles Ampel-Label rechts im Chart anzeigen")

// ============================================================
// DATEN HOLEN (S&P 500 als Marktfilter)
// ============================================================
sym = useCustomSymbol ? marktSymbol : "SP:SPX"

// Wochen-Schlusskurs und Wochen-SMA (von Marktsymbol)
spxWeekClose = request.security(sym, "1W", close, barmerge.gaps_off, barmerge.lookahead_off)
spxWeekSMA   = request.security(sym, "1W", ta.sma(close, smaWeekLen), barmerge.gaps_off, barmerge.lookahead_off)

// Tages-Schlusskurs und Tages-SMAs (von Marktsymbol)
spxDayClose  = request.security(sym, "1D", close,                       barmerge.gaps_off, barmerge.lookahead_off)
spxDaySMA50  = request.security(sym, "1D", ta.sma(close, smaDayShortLen), barmerge.gaps_off, barmerge.lookahead_off)
spxDaySMA200 = request.security(sym, "1D", ta.sma(close, smaDayLongLen),  barmerge.gaps_off, barmerge.lookahead_off)

// Vorwoche – um zu prüfen, ob 2 Wochen in Folge unter SMA 26 (Woche) geschlossen haben
spxWeekClosePrev = request.security(sym, "1W", close[1],                       barmerge.gaps_off, barmerge.lookahead_off)
spxWeekSMAPrev   = request.security(sym, "1W", ta.sma(close, smaWeekLen)[1],   barmerge.gaps_off, barmerge.lookahead_off)

// ============================================================
// AMPEL-LOGIK
// ============================================================
weekUnderSMA26     = spxWeekClose      < spxWeekSMA
weekUnderSMA26Prev = spxWeekClosePrev  < spxWeekSMAPrev
dayUnderSMA50      = spxDayClose       < spxDaySMA50
dayUnderSMA200     = spxDayClose       < spxDaySMA200

// Zone ROT: 2 Wochen in Folge unter SMA26(W) ODER Tages-Close unter SMA200(D)
istRot  = (weekUnderSMA26 and weekUnderSMA26Prev) or dayUnderSMA200

// Zone GELB: Wochen-Close unter SMA26(W) ODER Tages-Close unter SMA50(D) – aber nur, wenn nicht schon ROT
istGelb = (not istRot) and (weekUnderSMA26 or dayUnderSMA50)

// Zone GRÜN: SPX über SMA26(W) UND über SMA200(D)
istGruen = (not istRot) and (not istGelb) and (spxWeekClose > spxWeekSMA) and (spxDayClose > spxDaySMA200)

// Numerischer Status: 1=Grün, 2=Gelb, 3=Rot, 0=undefiniert
ampelStatus = istGruen ? 1 : istGelb ? 2 : istRot ? 3 : 0

// ============================================================
// VISUALISIERUNG IM CHART
// ============================================================
bgcolor(zeigeAmpelBG and istGruen ? color.new(color.green,  85) : na, title="Hintergrund Grün")
bgcolor(zeigeAmpelBG and istGelb  ? color.new(color.yellow, 80) : na, title="Hintergrund Gelb")
bgcolor(zeigeAmpelBG and istRot   ? color.new(color.red,    80) : na, title="Hintergrund Rot")

plot(zeigeSMA ? spxWeekSMA   : na, title="SMA 26 (W)",  color=color.new(color.blue,   0), linewidth=2)
plot(zeigeSMA ? spxDaySMA50  : na, title="SMA 50 (D)",  color=color.new(color.orange, 0), linewidth=1)
plot(zeigeSMA ? spxDaySMA200 : na, title="SMA 200 (D)", color=color.new(color.red,    0), linewidth=2)

// ============================================================
// HILFSFUNKTIONEN: Farben und Texte je nach Ampelstatus
// ============================================================
getLabelFarbe(int status) =>
    switch status
        1 => color.new(color.green,  0)
        2 => color.new(color.yellow, 0)
        3 => color.new(color.red,    0)
        => color.new(color.gray, 0)

getLabelText(int status) =>
    switch status
        1 => "🟢 GRÜN\nOffensive"
        2 => "🟡 GELB\nKaufstopp"
        3 => "🔴 ROT\nExit / Cash"
        => ""

getStatusText(int status) =>
    switch status
        1 => "🟢 GRÜN – Offensive\nVolle Investitionsquote"
        2 => "🟡 GELB – Vorsicht\nKaufstopp aktiv"
        3 => "🔴 ROT – Kapitalschutz\n100% Cash"
        => "⚪ Aufbauphase / keine Daten"

getTextFarbe(int status) =>
    status == 2 ? color.black : color.white

labelFarbe = getLabelFarbe(ampelStatus)
labelText  = getLabelText(ampelStatus)
textFarbe  = getTextFarbe(ampelStatus)

// ============================================================
// WECHSEL DER AMPELFARBE MARKIEREN
// ============================================================
ampelGewechselt = ta.change(ampelStatus) != 0 and ampelStatus != 0

if zeigeWechsel and ampelGewechselt
    label.new(x = bar_index, y = low, text = labelText, style = label.style_label_up, color = labelFarbe, textcolor = textFarbe, size = size.normal, yloc = yloc.belowbar)

// ============================================================
// AKTUELLER STATUS RECHTS IM CHART
// ============================================================
var label statusLabel = na
if zeigeStatusLabel
    label.delete(statusLabel)
    aktuellerText = getStatusText(ampelStatus)
    statusLabel := label.new(x = bar_index + 5, y = close, text = aktuellerText, style = label.style_label_left, color = labelFarbe, textcolor = textFarbe, size = size.large, xloc = xloc.bar_index)

// ============================================================
// ALERTS
// ============================================================
alertcondition(ampelGewechselt and ampelStatus == 1, title="Wechsel auf GRÜN", message="RSL-Marktampel: Wechsel auf GRÜN (Offensive)")
alertcondition(ampelGewechselt and ampelStatus == 2, title="Wechsel auf GELB", message="RSL-Marktampel: Wechsel auf GELB (Kaufstopp)")
alertcondition(ampelGewechselt and ampelStatus == 3, title="Wechsel auf ROT",  message="RSL-Marktampel: Wechsel auf ROT (Exit / Cash)")
````
