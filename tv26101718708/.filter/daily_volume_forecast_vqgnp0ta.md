# Daily Volume Forecast

- url: https://www.tradingview.com/script/vQGnp0TA/
- type: indicator
- pine_id: PUB;2f065966281941a49d12875ac987193d
- version: 1.0

## Description

[b]Daily Volume Forecast[/b]

[b]What this indicator does[/b]

[b]Daily Volume Forecast[/b] projects the [b]full-day trading volume[/b] of the current, still-running day — its expected value at the closing bell. It is designed for the [b]Daily chart[/b], where the live bar already carries the volume accumulated so far; the indicator scales that partial volume up to an estimate for the whole session.

The goal is to answer a simple question intraday: [i]is today on track for above- or below-average volume?[/i] — before the day is actually over.

[b]How it works[/b]

[list=1]
[*][b]Partial volume so far:[/b] On the Daily chart the current bar's volume is the cumulative volume traded since the session open. This is the basis that gets extrapolated.
[*][b]Elapsed session time:[/b] On a daily bar the bar's own hour/minute is the open time, not the current time. The indicator therefore derives the elapsed time from the real wall-clock (timenow) in the instrument's exchange timezone, relative to the configured session, so it knows how far the day has progressed.
[*][b]Two forecast methods are available:[/b]
[list]
[*][b]Intraday Profile (recommended):[/b] Intraday volume (e.g. 5-minute) is pulled per day via request.security_lower_tf and averaged into a typical [i]volume-by-time-of-day curve[/i]. Because real volume is U-shaped (heavy at the open and close, light at midday), this curve captures how much of a day's volume is normally done by the current time. The forecast is current_volume / expected_fraction_done_by_now, which adapts automatically to the instrument's own shape. Until enough intraday history exists, it falls back to the linear method.
[*][b]Linear:[/b] Assumes volume is spread evenly across the session: forecast = current_volume × (session_length / elapsed_minutes). Simple, requires no extra data, but overestimates the remainder in the morning because it ignores the U-shape.
[/list]
[*][b]Live update:[/b] The estimate is computed on the current (last) bar and updates as the day develops. When the market is closed, elapsed time clamps to the full session, so the forecast converges to the actual day's volume.
[/list]

[b]Display[/b]

[list]
[*][b]Volume columns[/b] of the actual daily volume (historical and current), coloured by up/down day — green when close ≥ open, red otherwise.
[*][b]Forecast line[/b] for the projected full-day volume, extended to the right edge (trackprice) on the current bar.
[*][b]Label[/b] on the last bar showing the estimate (e.g. "Est. 3.2M").
[*][b]Info table[/b] (optional, bottom-right) with the selected method, the forecast, percent of the session elapsed, the current volume, and the number of days used to build the profile.
[/list]

[b]Settings[/b]

[list]
[*][b]Forecast Method:[/b] Intraday Profile or Linear.
[*][b]Trading Session:[/b] Session string (default 0930-1600 for US RTH); adjust to the instrument (e.g. 0900-1730 EU stocks, 0000-2400 for 24h / crypto / FX).
[*][b]Profile Resolution (min):[/b] Intraday resolution used to build the volume curve (Intraday Profile only).
[*][b]Show Historical Daily Volumes:[/b] Toggle the volume columns.
[*][b]Show Info Table:[/b] Toggle the table.
[*][b]Colours[/b] for up and down volume.
[/list]

[b]How to use it[/b]

Apply it to a [b]Daily chart[/b] (a warning label appears on other timeframes). Use it to gauge participation in real time — to confirm breakouts on rising projected volume, to flag unusually quiet days, or as a context filter alongside a price strategy. The Intraday Profile method is recommended whenever the instrument has a pronounced intraday volume shape; Linear is a lightweight fallback that needs no intraday history.

[b]Notes[/b]

[list]
[*]request.security_lower_tf provides only a limited amount of recent intraday history (a TradingView/plan limit), so the profile is built from the most recent available days and rolls forward naturally.
[*]The profile method needs a few completed days to warm up; until then it uses the linear fallback.
[*]The session string must match the instrument, otherwise the elapsed-time scaling — and therefore the forecast — is distorted. Extended-hours volume is not considered.
[*]This script is an analysis tool and does not constitute financial advice. A volume forecast is an extrapolation, not a guarantee of the day's outcome.
[/list]


[b]═══════════════════════════════════════[/b]


[b]Daily Volume Forecast — Deutsch[/b]

[b]Was macht dieser Indikator?[/b]

[b]Daily Volume Forecast[/b] prognostiziert das [b]gesamte Tagesvolumen[/b] des aktuellen, noch laufenden Tages — den zu erwartenden Wert zum Handelsschluss. Er ist für den [b]Daily-Chart[/b] ausgelegt, wo die laufende Kerze bereits das bisher kumulierte Volumen trägt; der Indikator skaliert dieses Teilvolumen auf eine Schätzung für die ganze Session hoch.

Ziel ist es, schon während des Tages eine einfache Frage zu beantworten: [i]Läuft der heutige Tag auf über- oder unterdurchschnittliches Volumen hinaus?[/i] — bevor der Tag tatsächlich vorbei ist.

[b]Wie es funktioniert[/b]

[list=1]
[*][b]Bisheriges Teilvolumen:[/b] Auf dem Daily-Chart ist das Volumen der aktuellen Kerze das seit Session-Eröffnung kumulierte Volumen. Das ist die Basis, die hochgerechnet wird.
[*][b]Verstrichene Session-Zeit:[/b] Auf einer Tageskerze ist deren Stunde/Minute die Eröffnungszeit, nicht die aktuelle Uhrzeit. Der Indikator leitet die verstrichene Zeit deshalb aus der realen Uhrzeit (timenow) in der Börsen-Zeitzone des Instruments ab, relativ zur eingestellten Session — so weiss er, wie weit der Tag fortgeschritten ist.
[*][b]Zwei Prognosemethoden stehen zur Wahl:[/b]
[list]
[*][b]Intraday Profile (empfohlen):[/b] Über request.security_lower_tf wird das Intraday-Volumen (z. B. 5-Minuten) je Tag erhoben und zu einer typischen [i]Volumenkurve nach Tageszeit[/i] gemittelt. Da reales Volumen U-förmig ist (viel bei Eröffnung und Schluss, wenig am Mittag), erfasst diese Kurve, welcher Anteil des Tagesvolumens zur aktuellen Uhrzeit normalerweise schon gehandelt ist. Die Prognose ist aktuelles_Volumen / erwarteter_Anteil_bis_jetzt und passt sich automatisch an die Form des Instruments an. Bis genug Intraday-Historie vorliegt, greift der lineare Fallback.
[*][b]Linear:[/b] Nimmt an, dass das Volumen gleichmässig über die Session verteilt ist: Prognose = aktuelles_Volumen × (Session-Länge / verstrichene_Minuten). Einfach, ohne Zusatzdaten, überschätzt aber am Vormittag den Rest, weil die U-Form ignoriert wird.
[/list]
[*][b]Live-Update:[/b] Die Schätzung wird auf der aktuellen (letzten) Kerze berechnet und aktualisiert sich im Tagesverlauf. Bei geschlossenem Markt wird die verstrichene Zeit auf die volle Session begrenzt, sodass die Prognose gegen das tatsächliche Tagesvolumen konvergiert.
[/list]

[b]Anzeige[/b]

[list]
[*][b]Volumen-Säulen[/b] des tatsächlichen Tagesvolumens (historisch und aktuell), eingefärbt nach Up/Down-Tag — grün wenn close ≥ open, sonst rot.
[*][b]Prognose-Linie[/b] für das hochgerechnete Tagesvolumen, auf der aktuellen Kerze bis zum rechten Rand verlängert (trackprice).
[*][b]Label[/b] am letzten Balken mit der Schätzung (z. B. "Est. 3.2M").
[*][b]Info-Tabelle[/b] (optional, unten rechts) mit gewählter Methode, Prognose, Anteil der bereits verstrichenen Session, aktuellem Volumen und Anzahl der für das Profil genutzten Tage.
[/list]

[b]Einstellungen[/b]

[list]
[*][b]Forecast Method:[/b] Intraday Profile oder Linear.
[*][b]Trading Session:[/b] Session-String (Standard 0930-1600 für US-RTH); an das Instrument anpassen (z. B. 0900-1730 EU-Aktien, 0000-2400 für 24h / Krypto / FX).
[*][b]Profile Resolution (min):[/b] Intraday-Auflösung zum Aufbau der Volumenkurve (nur Intraday Profile).
[*][b]Show Historical Daily Volumes:[/b] Volumen-Säulen ein-/ausblenden.
[*][b]Show Info Table:[/b] Tabelle ein-/ausblenden.
[*][b]Farben[/b] für Up- und Down-Volumen.
[/list]

[b]Verwendung[/b]

Auf einen [b]Daily-Chart[/b] anwenden (auf anderen Timeframes erscheint ein Hinweis-Label). Geeignet, um die Marktbeteiligung in Echtzeit einzuschätzen — etwa zur Bestätigung von Ausbrüchen bei steigender prognostizierter Beteiligung, zum Markieren ungewöhnlich ruhiger Tage oder als Kontext-Filter neben einer Kursstrategie. Die Methode Intraday Profile wird empfohlen, wenn das Instrument eine ausgeprägte Intraday-Volumenform hat; Linear ist ein leichtgewichtiger Fallback ohne Intraday-Historie.

[b]Hinweise[/b]

[list]
[*]request.security_lower_tf liefert nur eine begrenzte Menge jüngster Intraday-Historie (TradingView-/Abo-Limit), daher basiert das Profil auf den jüngsten verfügbaren Tagen und rollt natürlich mit.
[*]Die Profil-Methode braucht einige abgeschlossene Tage zum "Aufwärmen"; bis dahin greift der lineare Fallback.
[*]Der Session-String muss zum Instrument passen, sonst werden die Zeit-Skalierung — und damit die Prognose — verzerrt. Vor-/Nachbörsliches Volumen wird nicht berücksichtigt.
[*]Dieses Skript ist ein Analyse-Werkzeug und stellt keine Anlageberatung dar. Eine Volumenprognose ist eine Hochrechnung, keine Garantie für den Tagesausgang.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tools-for-Trader


//@version=6
indicator("Daily Volume Forecast", overlay = false, format = format.volume)

// ── Inputs ────────────────────────────────────────────────────────────────
string methodInput = input.string("Intraday Profile", "Forecast Method", options = ["Intraday Profile", "Linear"], tooltip = "Intraday Profile: gelernte Tagesform (U-Form) aus jüngster Intraday-History. Linear: gleichmäßige Verteilung über die Session.")
string sessionStr  = input.session("0930-1600", "Trading Session")
string profileTF   = input.string("5", "Profile Resolution (min)", options = ["1", "5", "15", "30", "60"], group = "Intraday Profile", tooltip = "Intraday-Auflösung zum Aufbau der Volumenkurve (nur für Methode 'Intraday Profile')")
bool   showHistVol = input.bool(true, "Show Historical Daily Volumes")
bool   showTable   = input.bool(true, "Show Info Table")
color  upColInput  = input.color(#26a69a, "Up Volume",   group = "Colors")
color  dnColInput  = input.color(#ef5350, "Down Volume", group = "Colors")

// ── Session Parsing ───────────────────────────────────────────────────────
// Extract start/end hours and minutes from session string (e.g. "0930-1600")
// str.tonumber() returns a float — cast to int explicitly (implicit conversion errors in v6)
int sH = int(str.tonumber(str.substring(sessionStr,  0, 2)))
int sM = int(str.tonumber(str.substring(sessionStr,  2, 4)))
int eH = int(str.tonumber(str.substring(sessionStr,  5, 7)))
int eM = int(str.tonumber(str.substring(sessionStr,  7, 9)))

int sessionStartMin = sH * 60 + sM
int sessionEndMin   = eH * 60 + eM
int sessionLength   = sessionEndMin - sessionStartMin  // total trading minutes

// ── Elapsed Time ──────────────────────────────────────────────────────────
// On a DAILY chart, hour/minute give the bar's OPEN time, not "now".
// Derive the wall-clock time from timenow in the exchange timezone instead.
int nowMinute  = hour(timenow, syminfo.timezone) * 60 + minute(timenow, syminfo.timezone)
int elapsedMin = math.max(1, math.min(sessionLength, nowMinute - sessionStartMin))

// On a daily chart, volume of the current bar is already the day's cumulative
// volume so far (updates in realtime) — no manual accumulation needed.
float curVol = volume

// ── Method 2: Linear ──────────────────────────────────────────────────────
// Assumes volume is spread evenly across the session.
float linearEst = sessionLength > 0 ? curVol * sessionLength / elapsedMin : na

// ── Method 1: Intraday Volume Profile ─────────────────────────────────────
// Pull intraday volumes for each daily bar, build an average "share per bucket"
// curve over the available recent days, then scale the current partial volume
// by the expected cumulative fraction completed by now.
int tfMin      = math.max(1, int(str.tonumber(profileTF)))
int maxBuckets = math.max(1, int(sessionLength / tfMin) + 2)

array<float> intraVol = request.security_lower_tf(syminfo.tickerid, profileTF, volume)

var array<float> shareSum = array.new<float>(maxBuckets, 0.0)
var array<int>   shareCnt = array.new<int>(maxBuckets, 0)

// Accumulate per-bucket share on each confirmed (completed) daily bar
if barstate.isconfirmed and array.size(intraVol) > 0
    float tot = array.sum(intraVol)
    if tot > 0
        for i = 0 to array.size(intraVol) - 1
            if i < maxBuckets
                array.set(shareSum, i, array.get(shareSum, i) + array.get(intraVol, i) / tot)
                array.set(shareCnt, i, array.get(shareCnt, i) + 1)

// Expected cumulative fraction of daily volume completed by bucket k
expFraction(int k) =>
    float num = 0.0
    float den = 0.0
    for i = 0 to maxBuckets - 1
        int cnt = array.get(shareCnt, i)
        if cnt > 0
            float avg = array.get(shareSum, i) / cnt
            den += avg
            if i <= k
                num += avg
    den > 0 ? num / den : na

float ef         = expFraction(int(elapsedMin / tfMin))
float profileEst = (not na(ef) and ef > 0) ? curVol / ef : na

// ── Method Selection + Realtime Guard ─────────────────────────────────────
// Profile falls back to linear until enough intraday history exists.
float estRaw   = methodInput == "Linear" ? linearEst : (na(profileEst) ? linearEst : profileEst)
float estimate = (barstate.islast and sessionLength > 0) ? estRaw : na

// ── Daily-Chart Guard ─────────────────────────────────────────────────────
// This indicator is designed for the Daily chart. Warn once if it's not.
if barstate.islast and not timeframe.isdaily
    label.new(bar_index, 0.0, "⚠ Auf Daily Chart anwenden", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(color.red, 20), textcolor = color.white, size = size.small)

// ── Volume Formatter ──────────────────────────────────────────────────────
fmtVol(float v) =>
    na(v) ? "n/a" :
       v >= 1000000000 ? str.format("{0,number,.##}B", v / 1000000000) :
       v >= 1000000    ? str.format("{0,number,.##}M", v / 1000000) :
       v >= 1000       ? str.format("{0,number,.##}K", v / 1000) :
       str.format("{0,number,#}", v)

// ── Plots ─────────────────────────────────────────────────────────────────
// Historical / current daily volume as columns, colored by up/down day
color volCol = close >= open ? upColInput : dnColInput
plot(showHistVol ? volume : na, "Daily Volume", volCol, 4, plot.style_columns)

// Forecast as a line that extends to the right edge (trackprice)
plot(estimate, "Forecast", color.new(color.orange, 30), 2, plot.style_line, trackprice = true)

// ── Label on current bar ──────────────────────────────────────────────────
if barstate.islast and not na(estimate)
    label.new(bar_index, estimate, xloc = xloc.bar_index, text = "Est. " + fmtVol(estimate), style = label.style_label_center, textcolor = color.white, color = color.new(color.orange, 20), size = size.small)

// ── Info Table ────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table t = table.new(position.bottom_right, 2, 5, bgcolor = color.new(#111111, 75), border_width = 1, border_color = color.new(color.gray, 70))
    int    profileDays = array.get(shareCnt, 0)
    bool   isProfile   = methodInput == "Intraday Profile"
    string methodTxt   = isProfile ? (na(profileEst) ? "Profile (→Linear)" : "Intraday Profile") : "Linear"
    string elapsedTxt  = sessionLength > 0 ? str.tostring(100.0 * elapsedMin / sessionLength, "#") + "%" : "n/a"
    table.cell(t, 0, 0, "Method",      text_color = color.gray,  text_size = size.small, width = 8)
    table.cell(t, 1, 0, methodTxt,     text_color = color.white, text_size = size.small, width = 9)
    table.cell(t, 0, 1, "Forecast",    text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 1, fmtVol(estimate), text_color = color.orange, text_size = size.normal)
    table.cell(t, 0, 2, "Elapsed",     text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 2, elapsedTxt,    text_color = color.white, text_size = size.small)
    table.cell(t, 0, 3, "Current Vol", text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 3, fmtVol(curVol), text_color = color.white, text_size = size.small)
    table.cell(t, 0, 4, "Profile Days", text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 4, isProfile ? str.tostring(profileDays) : "n/a", text_color = color.white, text_size = size.small)
````
