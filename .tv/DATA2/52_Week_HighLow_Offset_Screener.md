<!-- tradingview-pine-id: PUB;50bb67d6bcbd498d86938dd84e63e9c2 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# 52 Week High/Low Offset Screener

Source: https://www.tradingview.com/script/48vB0ple/

## Description

Title:
52 Week High/Low Offset Screener

Visibility: Open (recommended) or Protected
Category: Indicator (not overlay)
Companion script: 52 Week High/Low (Current & Offset)
  → After the indicator is published, paste its script URL here in the description
    (English NOTES / German HINWEISE).

----- Description (paste below; English first) -----

[A German description follows the English text.]

█ OVERVIEW

This is a Pine Screener companion to “52 Week High/Low (Current & Offset)”.

It scans a watchlist for where price sits relative to a lagged 52-week high/low (default offset: 52 weeks). You can constrain those distances in the script settings and/or with column filters in the Pine Screener.

Same calculation as the chart indicator. This script does not overlay on price; it outputs columns and a Hit flag.

This is a scan helper, not a buy or sell signal.

█ HOW TO RUN THE SCAN

1. Add this script to your Favorites (star). It will not appear in Pine Screener otherwise.
2. Open Products → Screeners → Pine (or tradingview.com/pine-screener/).
3. Choose a watchlist (keep it under 1,000 symbols).
4. Select “52 Week High/Low Offset Screener”.
5. Set the timeframe (daily is typical) and optional distance filters in the script settings.
6. Click Scan.
7. To apply the built-in distance filters, add a column filter: Hit = 1.

Only one Pine script can be used per scan.

█ COLUMNS

• Hit — 1 if all enabled script filters match, otherwise 0
• Distance % nearer offset — distance to the closer of the two offset levels
• Nearer to (1=High, −1=Low)
• Distance % offset high / offset low
• Offset high / Offset low — lagged 52-week levels
• Current 52W high / Current 52W low
• Close

Distance formula:
(close − offset level) / close × 100
Positive = price above that level, negative = below.

█ DISTANCE FILTERS (SCRIPT SETTINGS)

Disabled filters are ignored. All enabled filters must pass for Hit = 1.

• Side: All / only nearer to offset high / only nearer to offset low
• Constrain nearer distance (from % / to %)
• Constrain distance to offset high
• Constrain distance to offset low (DCA-style example: −15 to +8)
• Only below offset low
• Only above offset high

You can also filter on the columns themselves. Numeric filters are literal:

• Distance % offset low < 1 includes +0.08 (slightly above the low) and −16 (below the low)
• Below the offset low only: Distance % offset low < 0
• At least 1% below the low: Distance % offset low < −1
• Within 1% of the low: between −1 and 1

█ ALERT

Alert condition “52W Offset Hit” fires when a symbol matches the script’s distance filters.

█ NOTES

• Uses 52 weekly bars and a weekly offset; the current 52-week high/low includes the developing week.
• Chart companion: “52 Week High/Low (Current & Offset)”.
  (Add the published indicator URL here after step 1 of the publishing sequence.)

This script does not generate trading signals and is not investment advice.

--------------------------------------------------------------------------------
DEUTSCH

█ ÜBERBLICK

Das ist der Pine-Screener zum Indikator „52 Week High/Low (Current & Offset)“.

Er scannt eine Watchlist danach, wo der Kurs relativ zu einem zeitversetzten 52-Wochen-Hoch/-Tief steht (Standard-Offset: 52 Wochen). Diese Abstände kannst du in den Skript-Einstellungen und/oder über Spaltenfilter im Pine Screener eingrenzen.

Dieselbe Berechnung wie der Chart-Indikator. Dieses Skript liegt nicht über dem Kurs; es liefert Spalten und ein Hit-Flag.

Das ist eine Scan-Hilfe, kein Kauf- oder Verkaufssignal.

█ SCAN AUSFÜHREN

1. Dieses Skript zu den Favoriten hinzufügen (Stern). Sonst erscheint es nicht im Pine Screener.
2. Products → Screeners → Pine öffnen (oder tradingview.com/pine-screener/).
3. Eine Watchlist wählen (unter 1.000 Symbole halten).
4. „52 Week High/Low Offset Screener“ auswählen.
5. Timeframe setzen (typisch Tageschart) und optional die Abstandsfilter in den Skript-Einstellungen.
6. Scan klicken.
7. Um die eingebauten Abstandsfilter anzuwenden, Spaltenfilter setzen: Hit = 1.

Pro Scan kann nur ein Pine-Skript verwendet werden.

█ SPALTEN

• Hit — 1, wenn alle aktivierten Skript-Filter zutreffen, sonst 0
• Distance % nearer offset — Abstand zum näheren der beiden Offset-Niveaus
• Nearer to (1=High, −1=Low)
• Distance % offset high / offset low
• Offset high / Offset low — zeitversetzte 52-Wochen-Niveaus
• Current 52W high / Current 52W low
• Close

Abstandsformel:
(Schlusskurs − Offset-Niveau) / Schlusskurs × 100
Positiv = Kurs über diesem Niveau, negativ = darunter.

█ ABSTANDSFILTER (SKRIPT-EINSTELLUNGEN)

Deaktivierte Filter werden ignoriert. Alle aktivierten Filter müssen für Hit = 1 gleichzeitig erfüllt sein.

• Side: All / only nearer to offset high / only nearer to offset low
• Constrain nearer distance (from % / to %)
• Constrain distance to offset high
• Constrain distance to offset low (DCA-Beispiel: −15 bis +8)
• Only below offset low
• Only above offset high

Du kannst auch direkt über die Spalten filtern. Numerische Filter gelten wörtlich:

• Distance % offset low < 1 enthält +0,08 (knapp über dem Tief) und −16 (unter dem Tief)
• Nur unter dem Offset-Tief: Distance % offset low < 0
• Mindestens 1 % unter dem Tief: Distance % offset low < −1
• Höchstens 1 % vom Tief entfernt: zwischen −1 und 1

█ ALERT

Die Alert-Bedingung „52W Offset Hit“ löst aus, wenn ein Symbol die Abstandsfilter des Skripts erfüllt.

█ HINWEISE

• Nutzt 52 Wochenkerzen und einen Wochen-Offset; das aktuelle 52-Wochen-Hoch/-Tief bezieht die laufende Woche ein.
• Chart-Begleiter: „52 Week High/Low (Current & Offset)“.
  (Nach der Indikator-Veröffentlichung hier die Skript-URL einfügen.)

Dieses Skript erzeugt keine Handelssignale und ist keine Anlageberatung.

---

## Source Code

````pine
//@version=6
// by makurypt
// Companion indicator https://de.tradingview.com/script/R7YAnkjH/
// Pine Screener: add this script to Favorites, then Products → Screeners → Pine.
// Column "Hit" = 1 applies the distance filters below.
indicator("52 Week High/Low Offset Screener", shorttitle="52W Offset Screen", overlay=false)

grpCalc = "52-week setup"
grpFilt = "Scan filters"

basis = input.string("Highs/Lows", "Basis for 52-week values", options=["Highs/Lows", "Close"], group=grpCalc, tooltip="Highs/Lows: candle extremes. Close: highest/lowest closing price.")
offsetWeeks = input.int(52, "Historical offset (weeks)", minval=1, group=grpCalc)

filterSide = input.string("All", "Side", options=["All", "Only nearer to offset high", "Only nearer to offset low"], group=grpFilt, tooltip="Keep symbols whose price is nearer the offset high or the offset low.")

enNearer = input.bool(false, "Constrain nearer distance", group=grpFilt)
nearerMin = input.float(-50.0, "from %", step=0.5, inline="near", group=grpFilt)
nearerMax = input.float(50.0, "to %", step=0.5, inline="near", group=grpFilt)

enHigh = input.bool(false, "Constrain distance to offset high", group=grpFilt, tooltip="Positive = price above the offset high, negative = below.")
highMin = input.float(-30.0, "from %", step=0.5, inline="hi", group=grpFilt)
highMax = input.float(5.0, "to %", step=0.5, inline="hi", group=grpFilt)

enLow = input.bool(false, "Constrain distance to offset low", group=grpFilt, tooltip="Positive = price above the offset low, negative = below. Typical DCA: e.g. −15 to +8.")
lowMin = input.float(-20.0, "from %", step=0.5, inline="lo", group=grpFilt)
lowMax = input.float(10.0, "to %", step=0.5, inline="lo", group=grpFilt)

onlyBelowLow = input.bool(false, "Only below offset low", group=grpFilt)
onlyAboveHigh = input.bool(false, "Only above offset high", group=grpFilt)

srcH() => basis == "Highs/Lows" ? high : close
srcL() => basis == "Highs/Lows" ? low : close

pctFromClose(level) =>
    not na(level) and close != 0 ? (close - level) / close * 100.0 : na

inRange(v, en, lo, hi) =>
    not en or (not na(v) and v >= lo and v <= hi)

[wHigh52, wLow52, histHigh, histLow] = request.security(syminfo.tickerid, "W",
     [ta.highest(srcH(), 52),
      ta.lowest(srcL(), 52),
      ta.highest(srcH(), 52)[offsetWeeks],
      ta.lowest(srcL(), 52)[offsetWeeks]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

var float weekHi = na
var float weekLo = na
if timeframe.change("W") or na(weekHi)
    weekHi := srcH()
    weekLo := srcL()
else
    weekHi := math.max(weekHi, srcH())
    weekLo := math.min(weekLo, srcL())

currHigh = math.max(nz(wHigh52), weekHi)
currLow  = math.min(nz(wLow52, 1e10), weekLo)

distHigh = pctFromClose(histHigh)
distLow  = pctFromClose(histLow)
nearerIsHigh = math.abs(close - histHigh) <= math.abs(close - histLow)
nearerDist = nearerIsHigh ? distHigh : distLow

sideOk = filterSide == "All" or (filterSide == "Only nearer to offset high" and nearerIsHigh) or (filterSide == "Only nearer to offset low" and not nearerIsHigh)
belowLowOk = not onlyBelowLow or (not na(distLow) and distLow < 0)
aboveHighOk = not onlyAboveHigh or (not na(distHigh) and distHigh > 0)

hit = sideOk and inRange(nearerDist, enNearer, nearerMin, nearerMax) and inRange(distHigh, enHigh, highMin, highMax) and inRange(distLow, enLow, lowMin, lowMax) and belowLowOk and aboveHighOk

// First plots become Pine Screener columns (first 10 are added automatically).
plot(hit ? 1 : 0, title="Hit", color=hit ? color.green : color.gray, linewidth=2, style=plot.style_histogram)
plot(nearerDist, title="Distance % nearer offset", color=color.blue)
plot(nearerIsHigh ? 1 : -1, title="Nearer to (1=High, −1=Low)", color=color.orange)
plot(distHigh, title="Distance % offset high", color=color.green)
plot(distLow, title="Distance % offset low", color=color.red)
plot(histHigh, title="Offset high", color=color.green)
plot(histLow, title="Offset low", color=color.red)
plot(currHigh, title="Current 52W high", color=color.new(color.green, 40))
plot(currLow, title="Current 52W low", color=color.new(color.red, 40))
plot(close, title="Close", color=color.white)

alertcondition(hit, title="52W Offset Hit", message="{{ticker}} matches the distance filters")
bgcolor(hit ? color.new(color.green, 85) : na)
````
