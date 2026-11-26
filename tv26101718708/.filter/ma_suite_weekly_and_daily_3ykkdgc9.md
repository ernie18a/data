# MA Suite  Weekly and Daily

- url: https://www.tradingview.com/script/3YKKDGC9/
- type: indicator
- pine_id: PUB;d78170782a7c488c88f41f4faa57d237
- version: 1.0

## Description

MA Suite – Weekly & Daily
Ein Multi-Timeframe-Trendindikator, der acht gleitende Durchschnitte aus drei Zeitebenen auf einem einzigen Chart bündelt: zwei Weekly-EMAs (5/9), vier Daily-MAs (EMA 50/100/200 + SMA 200) sowie zwei EMAs (10/20), die sich dem aktuell eingestellten Chart-Timeframe anpassen. Alle höheren Timeframes werden repaint-frei abgefragt, sodass die Linien auf jedem Timeframe stabil bleiben.
Kernstück ist ein Ampel-Cockpit, das die Trendlage zu einem klaren Status verdichtet:
🟢 RISK ON – Preis über allen kurz- und mittelfristigen MAs (voller Aufwärtstrend)

🟠 NEUTRAL – über den Daily-200ern, aber unter einzelnen kurzfristigen MAs (die Tabelle nennt die konkret unterschrittenen Linien)

🔴 RISK OFF – Preis unter Daily EMA 200 und SMA 200 (langfristiger Abwärtsdruck)
Eine optionale Detail-Tabelle zeigt pro MA den Wert und die prozentuale Distanz zum Preis, farbcodiert nach Nähe — so ist sofort erkennbar, welche Linie die nächste Hürde oder Stütze ist. Eine Anti-Flacker-Logik puffert Statuswechsel über einstellbare Bestätigungs-Bars, und fünf Alerts melden Trendwechsel sowie Kreuzungen wichtiger Linien.

## Source Code

````pine
//@version=6
indicator("MA Suite – Weekly & Daily", overlay = true, max_labels_count = 500)

// =================================================================
// HELFER
// =================================================================
htfSecurity(string tf, expression) =>
    request.security(syminfo.tickerid, tf, expression[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_on)

// =================================================================
// INPUTS
// =================================================================
int wlen5   = input.int(5,   "Weekly EMA kurz",   minval = 1, group = "Weekly")
int wlen9   = input.int(9,   "Weekly EMA lang",   minval = 1, group = "Weekly")
int dema50  = input.int(50,  "Daily EMA 50",      minval = 1, group = "Daily")
int dema100 = input.int(100, "Daily EMA 100",     minval = 1, group = "Daily")
int dema200 = input.int(200, "Daily EMA 200",     minval = 1, group = "Daily")
int dsma200 = input.int(200, "Daily SMA 200",     minval = 1, group = "Daily")
int clen10  = input.int(10,  "EMA 10 (Chart-TF)", minval = 1, group = "Aktueller Timeframe")
int clen20  = input.int(20,  "EMA 20 (Chart-TF)", minval = 1, group = "Aktueller Timeframe")

string tabPos     = input.string("Oben rechts", "Position", options = ["Oben rechts", "Oben links", "Unten rechts", "Unten links"], group = "Status-Tabelle")
bool   showDetail = input.bool(true, "Detail-Tabelle (alle MAs)", group = "Status-Tabelle")
int    confirmBars= input.int(1, "Bestätigungs-Bars (Anti-Flacker)", minval = 1, maxval = 20, group = "Status-Tabelle", tooltip = "Statuswechsel greift erst nach dieser Anzahl bestätigter Bars.")
float  nearPct    = input.float(0.5, "Schwelle 'nah an MA' (%)", minval = 0.0, step = 0.1, group = "Status-Tabelle", tooltip = "Distanzen unterhalb dieser Schwelle werden als 'knapp' markiert.")

// =================================================================
// BERECHNUNG
// =================================================================
weeklyEMA5  = htfSecurity("1W", ta.ema(close, wlen5))
weeklyEMA9  = htfSecurity("1W", ta.ema(close, wlen9))
dailyEMA50  = htfSecurity("1D", ta.ema(close, dema50))
dailyEMA100 = htfSecurity("1D", ta.ema(close, dema100))
dailyEMA200 = htfSecurity("1D", ta.ema(close, dema200))
dailySMA200 = htfSecurity("1D", ta.sma(close, dsma200))
chartEMA10  = ta.ema(close, clen10)
chartEMA20  = ta.ema(close, clen20)

// =================================================================
// PLOTS
// =================================================================
plot(weeklyEMA5,  title = "Weekly EMA 5",  color = color.black, linewidth = 2)
plot(weeklyEMA9,  title = "Weekly EMA 9",  color = color.gray,  linewidth = 2)
plot(dailyEMA50,  title = "Daily EMA 50",  color = #26a69a,     linewidth = 2)
plot(dailyEMA100, title = "Daily EMA 100", color = #8e24aa,     linewidth = 2)
plot(dailyEMA200, title = "Daily EMA 200", color = #1e88e5,     linewidth = 2)
plot(dailySMA200, title = "Daily SMA 200", color = #64b5f6,     linewidth = 2)
plot(chartEMA10,  title = "EMA 10 (TF)",   color = #ffb300,     linewidth = 1)
plot(chartEMA20,  title = "EMA 20 (TF)",   color = #ef5350,     linewidth = 1)

// =================================================================
// STATUS-LOGIK
// =================================================================
bool aboveDaily200 = close > dailyEMA200 and close > dailySMA200
bool aboveShort    = close > chartEMA10 and close > chartEMA20
bool aboveWeekly   = close > weeklyEMA5 and close > weeklyEMA9

// Roh-Status: 0 = rot, 1 = orange, 2 = grün
int rawStatus = not aboveDaily200 ? 0 : (aboveShort and aboveWeekly ? 2 : 1)

// --- Anti-Flacker: Wechsel erst nach confirmBars bestätigten Bars ---
var int confirmedStatus = rawStatus
var int pendingStatus    = rawStatus
var int pendingCount     = 0

if rawStatus == confirmedStatus
    pendingCount := 0
    pendingStatus := rawStatus
else if rawStatus == pendingStatus
    pendingCount += 1
    if pendingCount >= confirmBars
        confirmedStatus := pendingStatus
        pendingCount := 0
else
    pendingStatus := rawStatus
    pendingCount := 1

// --- Statuswechsel erkennen (für Alerts) ---
bool turnedGreen   = confirmedStatus == 2 and confirmedStatus[1] != 2
bool turnedOrange  = confirmedStatus == 1 and confirmedStatus[1] != 1
bool turnedRed     = confirmedStatus == 0 and confirmedStatus[1] != 0

// =================================================================
// ALERTS
// =================================================================
alertcondition(turnedGreen,  "Status → RISK ON",  "MA Suite: Status auf GRÜN (RISK ON) gewechselt")
alertcondition(turnedOrange, "Status → NEUTRAL",  "MA Suite: Status auf ORANGE (NEUTRAL) gewechselt")
alertcondition(turnedRed,    "Status → RISK OFF", "MA Suite: Status auf ROT (RISK OFF) gewechselt")
alertcondition(ta.cross(close, weeklyEMA5),  "Kreuzt Weekly 5",  "MA Suite: Preis kreuzt Weekly EMA 5")
alertcondition(ta.cross(close, dailyEMA200), "Kreuzt Daily 200", "MA Suite: Preis kreuzt Daily EMA 200")

// =================================================================
// DARSTELLUNG
// =================================================================
statusColor = confirmedStatus == 0 ? #8b0000 : confirmedStatus == 1 ? #ef6c00 : #2e7d32
statusText  = confirmedStatus == 0 ? "RISK OFF" : confirmedStatus == 1 ? "NEUTRAL" : "RISK ON"

statusInfo = ""
if confirmedStatus == 0
    statusInfo := "Unter Daily EMA 200 & SMA 200 –\nlangfristiger Abwärtsdruck"
else if confirmedStatus == 2
    statusInfo := "Über allen kurz- & mittelfristigen MAs –\nvoller Aufwärtstrend"
else
    string r = ""
    r := r + (close < weeklyEMA5 ? "W" + str.tostring(wlen5) + " " : "")
    r := r + (close < weeklyEMA9 ? "W" + str.tostring(wlen9) + " " : "")
    r := r + (close < chartEMA10 ? "EMA" + str.tostring(clen10) + " " : "")
    r := r + (close < chartEMA20 ? "EMA" + str.tostring(clen20) + " " : "")
    statusInfo := "Über Daily 200, aber unter:\n" + r

tablePosition = switch tabPos
    "Oben rechts"  => position.top_right
    "Oben links"   => position.top_left
    "Unten rechts" => position.bottom_right
    "Unten links"  => position.bottom_left
    => position.top_right

// --- Distanz-Helfer: liefert formatierten String + Farbe ---
distPct(float maVal) =>
    (close - maVal) / maVal * 100.0

cellColor(float d) =>
    above = d >= 0
    near  = math.abs(d) < nearPct
    above ? (near ? #66bb6a : #2e7d32) : (near ? #ffa726 : #c62828)

// --- Tabelle ---
int rows = showDetail ? 11 : 3
var table tab = table.new(tablePosition, 3, rows, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50))

addMARow(int rowIdx, string name, float maVal) =>
    float d = distPct(maVal)
    col = cellColor(d)
    table.cell(tab, 0, rowIdx, name, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = size.small, text_halign = text.align_left)
    table.cell(tab, 1, rowIdx, str.tostring(maVal, format.mintick), text_color = color.white, bgcolor = color.new(color.black, 40), text_size = size.small)
    table.cell(tab, 2, rowIdx, (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%", text_color = color.white, bgcolor = col, text_size = size.small)

if barstate.islast
    // Kopf: Sammelstatus über alle 3 Spalten
    table.cell(tab, 0, 0, "STATUS", text_color = color.white, bgcolor = color.new(color.black, 10), text_size = size.normal)
    table.cell(tab, 1, 0, statusText, text_color = color.white, bgcolor = statusColor, text_size = size.normal)
    table.cell(tab, 2, 0, "", bgcolor = statusColor)
    table.merge_cells(tab, 1, 0, 2, 0)

    // Begründungszeile über alle 3 Spalten
    table.cell(tab, 0, 1, statusInfo, text_color = color.white, bgcolor = color.new(statusColor, 70), text_size = size.small)
    table.merge_cells(tab, 0, 1, 2, 1)

    if showDetail
        // Spaltenüberschrift
        table.cell(tab, 0, 2, "MA",       text_color = color.silver, bgcolor = color.new(color.black, 20), text_size = size.tiny)
        table.cell(tab, 1, 2, "Wert",     text_color = color.silver, bgcolor = color.new(color.black, 20), text_size = size.tiny)
        table.cell(tab, 2, 2, "Distanz",  text_color = color.silver, bgcolor = color.new(color.black, 20), text_size = size.tiny)
        // Sortiert von kurz nach lang
        addMARow(3,  "EMA " + str.tostring(clen10),  chartEMA10)
        addMARow(4,  "EMA " + str.tostring(clen20),  chartEMA20)
        addMARow(5,  "W EMA " + str.tostring(wlen5), weeklyEMA5)
        addMARow(6,  "W EMA " + str.tostring(wlen9), weeklyEMA9)
        addMARow(7,  "D EMA " + str.tostring(dema50), dailyEMA50)
        addMARow(8,  "D EMA " + str.tostring(dema100), dailyEMA100)
        addMARow(9,  "D EMA " + str.tostring(dema200), dailyEMA200)
        addMARow(10, "D SMA " + str.tostring(dsma200), dailySMA200)
````
