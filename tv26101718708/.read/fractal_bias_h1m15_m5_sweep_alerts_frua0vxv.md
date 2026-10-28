# Fractal Bias H1/M15 + M5 Sweep Alerts

- url: https://www.tradingview.com/script/Frua0VXV/
- type: indicator
- pine_id: PUB;93e48178b8fe4a72a672b8232dacf8a0
- version: 1.0

## Description

Fractal Bias H1/15 with M5 Sweep Alerts

ENGLISH

This indicator shows the market bias on H1 and M15 and combines it with M5 fractal sweep alerts. Its purpose is to filter the direction on higher timeframes and alert users to a setup they can then assess manually on M1.

How it works

The indicator uses five-candle fractals. The middle candle must have a higher high or lower low than the two candles on each side. A fractal is confirmed after both candles to its right have closed. Equal highs or lows do not qualify.

On H1 and M15, a candle close above the latest confirmed upper fractal sets the bias to Long. A close below the latest confirmed lower fractal sets it to Short. The bias remains until an opposite break occurs.

The table is green when both timeframes agree and red when they disagree.

M5 alerts

When H1 and M15 both show Short, an alert triggers when price moves above the latest confirmed upper M5 fractal.

When H1 and M15 both show Long, an alert triggers when price moves below the latest confirmed lower M5 fractal.

Here, a sweep means crossing the fractal level. A wick is enough. Neither a candle close nor a return through the level is required. Touching the level is not enough.

Each fractal is counted only once. Sweeps without a matching bias are not reported later. Sweeps already present when monitoring starts are not reported retrospectively.

Manual entry on M1

After an alert, users can switch to M1 and assess their entry. The indicator does not detect M1 entry signals, open trades or manage positions.

Alert setup

Create a TradingView alert for this indicator and select “Any alert() function call”. Enable sound notifications if desired. Long and Short alerts can be enabled separately in the settings.

Recreate the alert after changing the script or its settings.

Limitations

The indicator is designed for standard, time-based candle charts. H1, M15 and M5 remain fixed regardless of the chart timeframe.

Alerts work live. Historical alert markers are not displayed. Calculations depend on the available market data. If the available history does not contain a qualifying break, the bias is displayed as undetermined.

The alerts identify setups for manual review. They do not guarantee a successful entry or trading outcome.

German interface translations

Zeitrahmen: Timeframe
Nicht bestimmbar: Undetermined
Short-Vorbereitung melden: Enable Short preparation alerts
Long-Vorbereitung melden: Enable Long preparation alerts
M5-Sweep-Alarme: M5 sweep alerts
Gesweept: Swept
Jetzt auf M1 nach einem Short-/Long-Entry suchen: Look for a manual Short/Long entry on M1


DEUTSCH

Dieser Indikator zeigt den Bias auf H1 und M15 an und kombiniert ihn mit M5-Sweep-Alarmen. So kannst du Märkte überwachen und nach einem Alarm auf M1 deinen Einstieg selbst suchen.

So funktioniert der Bias

Der Indikator verwendet 5er-Fraktale. Die mittlere Kerze muss ein höheres Hoch oder tieferes Tief als die jeweils zwei Kerzen links und rechts haben. Das Fraktal ist erst bestätigt, wenn die beiden rechten Kerzen abgeschlossen sind. Gleiche Hochs oder Tiefs zählen nicht.

Ein Kerzenschluss über dem letzten bestätigten oberen Fraktal setzt den Bias auf Long. Ein Schlusskurs unter dem letzten bestätigten unteren Fraktal setzt ihn auf Short.

Die Richtung bleibt bis zum gegenteiligen Bruch bestehen.

Grüne Tabelle: H1 und M15 zeigen dieselbe Richtung.
Rote Tabelle: Die Richtungen stimmen nicht überein.

Wann kommt der Alarm?

Sind H1 und M15 beide Short, kommt der Alarm beim Überschreiten des oberen M5-Fraktals.

Sind H1 und M15 beide Long, kommt der Alarm beim Unterschreiten des unteren M5-Fraktals.

Eine Lunte reicht. Eine reine Berührung reicht nicht. Der Alarm wartet weder auf den Kerzenschluss noch auf eine Rückkehr hinter das Level.

Jedes Fraktal wird nur einmal gewertet. Sweeps ohne passenden Bias werden später nicht nachträglich gemeldet. Bereits beim Start vorhandene Sweeps werden ebenfalls nicht nachträglich alarmiert.

Manueller Einstieg auf M1

Nach dem Alarm wechselst du auf M1 und suchst deinen Einstieg selbst. Der Indikator prüft keine M1-Einstiege, eröffnet keine Trades und verwaltet keine Positionen.

Alarm aktivieren

Erstelle in TradingView einen Alarm für diesen Indikator und wähle „Beliebiger alert()-Funktionsaufruf“. Aktiviere bei Bedarf den Ton. Long- und Short-Meldungen kannst du in den Einstellungen getrennt einschalten.

Nach Änderungen am Script oder den Einstellungen den Alarm neu erstellen.

Hinweise

Verwende normale, zeitbasierte Kerzencharts. Die überwachten Zeitrahmen H1, M15 und M5 bleiben unabhängig vom geöffneten Chart fest eingestellt.

Die Alarme arbeiten live. Vergangene Alarme werden nicht als Markierungen dargestellt. Die Berechnung hängt von den verfügbaren Marktdaten ab. Ist darin kein gültiger Fraktalbruch enthalten, erscheint „Nicht bestimmbar“.

Die Alarme dienen zur Vorbereitung und manuellen Prüfung eines möglichen Einstiegs. Sie garantieren keinen erfolgreichen Trade.

## Source Code

````pine
//@version=6
indicator("Fractal Bias H1/M15 + M5 Sweep Alerts", overlay = true, dynamic_requests = true)

bool alertShorts = input.bool(true, "Short-Vorbereitung melden", group = "M5-Sweep-Alarme")
bool alertLongs = input.bool(true, "Long-Vorbereitung melden", group = "M5-Sweep-Alarme")

// Fuer normale, zeitbasierte Kerzencharts.
// 1 = Long, -1 = Short, 0 = kein Bruch in der verfuegbaren Historie.
// Neue, ungebrochene Fraktale setzen die gespeicherte Richtung NICHT zurueck.
f_bias() =>
    var float upper = na
    var float lower = na
    var int direction = 0

    // Strikte 5er-Fraktale: zwei niedrigere Hochs / hoehere Tiefs je Seite.
    bool upFractal = high[2] > high[4] and high[2] > high[3] and high[2] > high[1] and high[2] > high
    bool downFractal = low[2] < low[4] and low[2] < low[3] and low[2] < low[1] and low[2] < low

    if upFractal
        upper := high[2]
    if downFractal
        lower := low[2]

    // Dochte und Schlusskurse exakt auf dem Level reichen nicht aus.
    // Verbrauchte Levels entfernen, damit nur neue Brueche zaehlen.
    if not na(upper) and close > upper
        direction := 1
        upper := na
    if not na(lower) and close < lower
        direction := -1
        lower := na
    direction

f_snapshot() =>
    int direction = f_bias()
    [direction, direction[1]]

f_readBias(string targetTf) =>
    var int result = 0
    if timeframe.in_seconds() < timeframe.in_seconds(targetTf)
        // Bestaetigter HTF-Wert ab Beginn der naechsten Zielkerze.
        result := nz(request.security(syminfo.tickerid, targetTf, f_bias()[1], lookahead = barmerge.lookahead_on, calc_bars_count = 100000), 0)
    else if timeframe.in_seconds() == timeframe.in_seconds(targetTf)
        // Historie auch hier separat anfordern, unabhaengig vom sichtbaren Ausschnitt.
        [current, previous] = request.security(syminfo.tickerid, targetTf, f_snapshot(), lookahead = barmerge.lookahead_off, calc_bars_count = 100000)
        result := barstate.isconfirmed ? current : nz(previous, 0)
    else
        // Auch auf H4, Tageschart usw. alle verfuegbaren Unterkerzen auswerten.
        [directions, closingTimes] = request.security_lower_tf(syminfo.tickerid, targetTf, [f_bias(), time_close], calc_bars_count = 100000)
        int cutoff = barstate.isrealtime ? timenow : time_close
        int i = array.size(directions) - 1
        while i >= 0
            if array.get(closingTimes, i) <= cutoff
                result := array.get(directions, i)
                break
            i -= 1
    result

f_label(int direction) =>
    direction == 1 ? "Long" : direction == -1 ? "Short" : "Nicht bestimmbar"

// Laeuft ausschliesslich im M5-Kontext. Ein Sweep ist hier das erste
// strikte Ueber-/Unterschreiten, ohne Rueckkehr- oder Schlusskursbedingung.
f_m5Sweeps() =>
    var float upper = na
    var float lower = na
    var int upperId = na
    var int lowerId = na
    var int sweptUpperId = na
    var int sweptLowerId = na
    var float sweptUpperPrice = na
    var float sweptLowerPrice = na

    // Nur abgeschlossene Kerzen fuer die Fraktalbildung verwenden.
    // [3] ist die Mitte; [2] und [1] sind die beiden fertigen rechten Kerzen.
    bool confirmedUpper = high[3] > high[5] and high[3] > high[4] and high[3] > high[2] and high[3] > high[1]
    bool confirmedLower = low[3] < low[5] and low[3] < low[4] and low[3] < low[2] and low[3] < low[1]
    if confirmedUpper
        upper := high[3]
        upperId := time[3]
    if confirmedLower
        lower := low[3]
        lowerId := time[3]

    // high/low der laufenden M5-Kerze: Die Lunte reicht bereits aus.
    if not na(upper) and high > upper
        sweptUpperId := upperId
        sweptUpperPrice := upper
        upper := na
    if not na(lower) and low < lower
        sweptLowerId := lowerId
        sweptLowerPrice := lower
        lower := na
    [sweptUpperId, sweptLowerId, sweptUpperPrice, sweptLowerPrice]

if not chart.is_standard or timeframe.isticks
    runtime.error("Bitte einen normalen, zeitbasierten Kerzenchart verwenden.")

int h1 = f_readBias("60")
int m15 = f_readBias("15")
bool ready = h1 != 0 and m15 != 0
bool aligned = ready and h1 == m15
color rowColor = aligned ? color.rgb(27, 135, 65) : color.rgb(190, 45, 45)

// Fuer die Live-Alarme wird bewusst die LAUFENDE M5-Kerze abgefragt.
// Auf groesseren Charts liefert security() live die juengste Unterkerze.
// Historische Alarmmarker werden damit nicht rekonstruiert.
[upperSweepId, lowerSweepId, upperSweepPrice, lowerSweepPrice] = request.security(syminfo.tickerid, "5", f_m5Sweeps(), lookahead = barmerge.lookahead_off, calc_bars_count = 100000)

// varip verhindert Wiederholungen auf weiteren Ticks derselben Chartkerze.
// Beim Start vorhandene Sweeps nicht nachtraeglich melden.
varip bool liveInitialized = false
varip int seenUpperId = na
varip int seenLowerId = na
if barstate.isrealtime
    if not liveInitialized
        seenUpperId := upperSweepId
        seenLowerId := lowerSweepId
        liveInitialized := true
    else
        bool newUpperSweep = not na(upperSweepId) and (na(seenUpperId) or upperSweepId != seenUpperId)
        bool newLowerSweep = not na(lowerSweepId) and (na(seenLowerId) or lowerSweepId != seenLowerId)
        if newUpperSweep
            // Auch ohne passenden Bias verbrauchen: kein spaeter Alarm.
            seenUpperId := upperSweepId
            if alertShorts and h1 == -1 and m15 == -1
                alert(syminfo.ticker + " | SHORT-Vorbereitung: H1 und M15 Short. Oberes M5-Fraktal bei " + str.tostring(upperSweepPrice, format.mintick) + " gesweept. Jetzt auf M1 nach einem Short-Entry suchen.", alert.freq_all)
        if newLowerSweep
            seenLowerId := lowerSweepId
            if alertLongs and h1 == 1 and m15 == 1
                alert(syminfo.ticker + " | LONG-Vorbereitung: H1 und M15 Long. Unteres M5-Fraktal bei " + str.tostring(lowerSweepPrice, format.mintick) + " gesweept. Jetzt auf M1 nach einem Long-Entry suchen.", alert.freq_all)

var table panel = table.new(position.top_right, 2, 3, border_width = 1, border_color = color.new(color.white, 60))
if barstate.islast
    table.cell(panel, 0, 0, "Zeitrahmen", text_color = color.white, bgcolor = color.rgb(40, 40, 40))
    table.cell(panel, 1, 0, "Bias", text_color = color.white, bgcolor = color.rgb(40, 40, 40))
    table.cell(panel, 0, 1, "H1", text_color = color.white, bgcolor = rowColor)
    table.cell(panel, 1, 1, f_label(h1), text_color = color.white, bgcolor = rowColor)
    table.cell(panel, 0, 2, "M15", text_color = color.white, bgcolor = rowColor)
    table.cell(panel, 1, 2, f_label(m15), text_color = color.white, bgcolor = rowColor)
````
