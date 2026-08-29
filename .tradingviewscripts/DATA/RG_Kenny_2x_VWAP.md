<!-- tradingview-pine-id: PUB;a375b93d5724428eb873ef4b96d6d6fb -->
<!-- tradingviewscripts-format: 1 -->
# RG Kenny 2x VWAP

Source: https://www.tradingview.com/script/nN0f336P/

## Description

Skrypt automatycznie wyświetla najważniejsze poziomy wykorzystywane podczas handlu intraday na rynku amerykańskim:

🔵 Session VWAP – bieżący VWAP liczony od otwarcia sesji (9:30 ET).
🟠 Prior-Day / Multi-Day VWAP – VWAP liczony od otwarcia premarketu poprzedniego dnia.
🔴 Previous Day High – maksimum poprzedniej sesji.
🟢 Previous Day Low – minimum poprzedniej sesji.
🟡 Premarket High – najwyższa cena premarketu.
🟡 Premarket Low – najniższa cena premarketu.
Przeznaczenie

Wskaźnik został zaprojektowany do handlu intraday akcjami i ETF-ami na rynku USA, szczególnie na interwałach 1 min, 5 min i 15 min.

---

## Source Code

````pine
//@version=6
indicator("RG Kenny 2x VWAP", shorttitle="RG Kenny VWAP", overlay=true)

// ============================================================
// USTAWIENIA
// ============================================================

string tz = "America/New_York"

bool showBlue   = input.bool(true, "Blue VWAP - 1:00 ET", group="VWAP")
bool showYellow = input.bool(true, "Yellow MultiDay - Monday 1:00 ET", group="VWAP")

// ============================================================
// CZAS NOWEGO JORKU
// ============================================================

int nyHour      = hour(time, tz)
int nyMinute    = minute(time, tz)
int nyDayOfWeek = dayofweek(time, tz)

// ============================================================
// BLUE VWAP
// RESET CODZIENNIE O 1:00 ET
// ============================================================

// Pierwsza świeca dostępna od 1:00 ET
bool afterBlueAnchor = nyHour > 1 or (nyHour == 1 and nyMinute >= 0)

int blueDateKey =
     year(time, tz) * 10000 +
     month(time, tz) * 100 +
     dayofmonth(time, tz)

var int lastBlueDateKey = na

bool newBlueAnchor =
     afterBlueAnchor and
     (na(lastBlueDateKey) or blueDateKey != lastBlueDateKey)

var float bluePV = 0.0
var float blueVol = 0.0
var bool blueStarted = false

if newBlueAnchor
    bluePV := hlc3 * volume
    blueVol := volume
    blueStarted := true
    lastBlueDateKey := blueDateKey

else if blueStarted
    bluePV += hlc3 * volume
    blueVol += volume

float blueVWAP =
     blueStarted and blueVol > 0
     ? bluePV / blueVol
     : na

plot(
     showBlue ? blueVWAP : na,
     title="Blue VWAP 1:00 ET",
     color=color.blue,
     linewidth=3
)

// ============================================================
// YELLOW MULTIDAY VWAP
// RESET W PONIEDZIAŁEK O 1:00 ET
// ============================================================

bool afterYellowAnchor = nyHour > 1 or (nyHour == 1 and nyMinute >= 0)

int weekKey =
     year(time, tz) * 100 +
     weekofyear(time, tz)

var int lastWeekKey = na

bool newYellowAnchor =
     nyDayOfWeek == dayofweek.monday and
     afterYellowAnchor and
     (na(lastWeekKey) or weekKey != lastWeekKey)

var float yellowPV = 0.0
var float yellowVol = 0.0
var bool yellowStarted = false

if newYellowAnchor
    yellowPV := hlc3 * volume
    yellowVol := volume
    yellowStarted := true
    lastWeekKey := weekKey

else if yellowStarted
    yellowPV += hlc3 * volume
    yellowVol += volume

float yellowVWAP =
     yellowStarted and yellowVol > 0
     ? yellowPV / yellowVol
     : na

plot(
     showYellow ? yellowVWAP : na,
     title="Yellow MultiDay VWAP",
     color=color.yellow,
     linewidth=2,
     style=plot.style_line
)
````
