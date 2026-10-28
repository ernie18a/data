# Follow-Through Day (FTD) Detector

- url: https://www.tradingview.com/script/qmuk6WNR/
- type: indicator
- pine_id: PUB;476efd7c00924e5abc8ee938cee62522
- version: 1.0

## Description

// Follow-Through Day (FTD) Definition:
// - Day 1 begins after a new low with the first candle
//   that no longer undercuts that low.
// - Starting from Day 4, an FTD is identified when the price rises by at least
//   1.25%, volume is higher than the previous day, and the
//   low of Day 1 has not been undercut.
// Use only on the daily chart.

## Source Code

````pine
//@version=6
indicator("Follow-Through Day (FTD) Detector", overlay=true)

// Johannes Lauer, 22.3.2026
// Follow-Through Day (FTD) Definition:
// - Tag 1 beginnt nach einem neuen Tief mit der ersten Kerze,
//   die dieses Tief nicht mehr unterschreitet.
// - Ab Tag 4 wird ein FTD erkannt, wenn der Kurs um mindestens
//   1,25 % steigt, das Volumen über dem Vortag liegt und das
//   Tief von Tag 1 nicht unterschritten wurde.
// Nur im Tageschart anwenden.

// === Inputs ===
minGainPct = input.float(1.25, "Mindestanstieg für FTD (%)", step=0.05)
showTag1   = input.bool(true, "Tag 1 markieren")
showFTD    = input.bool(true, "FTD markieren")
useVolume  = input.bool(true, "Volumenbedingung verwenden")

// === Variables ===
var float rallyLow = na              // Tief des Selloffs / Referenztief
var float day1Low = na               // Tief von Tag 1
var int   day1Bar = na               // Bar-Index von Tag 1
var bool  rallyAttemptActive = false // Erholungsversuch aktiv
var bool  ftdFound = false           // FTD bereits gefunden?

// === Step 1: Neues Tief erkennen ===
// Neues Tief relativ zu den letzten 50 abgeschlossenen Kerzen
// JOL: Eigentlich sollte nach Jens Rabe erst gezählt werden, wenn der Markt 10% gefallen ist
isNewLow = low < ta.lowest(low[1], 50)

// Wenn neues Tief gemacht wird, Rally-Versuch zurücksetzen
if isNewLow
    rallyLow := low
    day1Low := na
    day1Bar := na
    rallyAttemptActive := false
    ftdFound := false

// === Step 2: Tag 1 erkennen ===
// Erste Kerze nach einem neuen Tief, die dieses Tief NICHT unterschreitet
isDay1 = not rallyAttemptActive and not na(rallyLow) and low >= rallyLow

if isDay1
    day1Low := low
    day1Bar := bar_index
    rallyAttemptActive := true
    ftdFound := false

// === Step 3: Rally-Versuch ungültig, wenn Tag-1-Tief unterschritten wird ===
if rallyAttemptActive and not na(day1Low) and low < day1Low
    rallyAttemptActive := false
    ftdFound := false
    day1Low := na
    day1Bar := na
    rallyLow := low

// === Step 4: Tage seit Tag 1 zählen ===
daysSinceDay1 = rallyAttemptActive and not na(day1Bar) ? (bar_index - day1Bar) : na

// === Step 5: FTD-Bedingungen ===
priceGainPct = ((close / close[1]) - 1.0) * 100.0
volumeOk = useVolume ? (volume > volume[1]) : true

isFTD = rallyAttemptActive and not ftdFound and not na(daysSinceDay1) and daysSinceDay1 >= 3 and priceGainPct >= minGainPct and volumeOk and low >= day1Low

if isFTD
    ftdFound := true

// === Plot Tag 1 ===
plotshape(showTag1 and isDay1, title="Tag 1", style=shape.labelup, location=location.belowbar, color=color.orange, text="Tag 1", textcolor=color.white, size=size.small)

// === Plot FTD ===
plotshape(showFTD and isFTD, title="FTD", style=shape.labelup, location=location.belowbar, color=color.green, text="FTD", textcolor=color.white, size=size.normal)

// === Optional: Tag-1-Tief als Linie anzeigen ===
plot(rallyAttemptActive ? day1Low : na, title="Tag 1 Tief", color=color.red, linewidth=2, style=plot.style_linebr)
````
