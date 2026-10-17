# Strat Bar Type Scanner

- url: https://www.tradingview.com/script/pK9v5IbN-Strat-Bar-Type-Scanner/
- type: indicator
- pine_id: PUB;eaead70272d8405fa99d0eae8982cdd9
- version: 10.0

## Description

Made for use with the Pine Screener (beta).

Select "Choose Indicator" then click "strat bar scanner"

First adjust the columns. Click the 3 bars on the right for drop down. Remove all the "shapes" columns. Add current strat type and previous strat type.

You can now scan your watch list for all types of candles.
1 bars print as "1"
2 up bars print as "21"
2 down bars print as "22"
3 bars print as "3"

current strat type shows your current candle type
previous strat type shows your previous candle type.

For manually scanning specific types you would do the following - 

To scan for 1 bars:
Click "current strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "1"

To scan for 2 down bars:
Click "current strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "22"

To scan for 2 up bars:
Click "current strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "21"

To scan for 3 bars:
Click "current strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "3"

To scan for patterns by using the pervious strat type dropdown - 
for instance 3-1 conslidation:
Click "current strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "1"
Click "previous strat type" dropdown then manual setup.
First drop down select "equal"
Second drop down leave on "value"
Third drop down type "3"

## Source Code

````pine
//@version=6
indicator("Strat Bar Type Scanner", overlay=true)

is_holiday(t) =>
    m   = month(t, "America/New_York")
    d   = dayofmonth(t, "America/New_York")
    y   = year(t, "America/New_York")
    dow = dayofweek(t, "America/New_York")
    bool result =
         (m == 1  and d == 1) or
         (m == 12 and d == 31 and dow == dayofweek.friday) or
         (m == 1  and d == 2  and dow == dayofweek.monday) or
         (m == 1  and d >= 15 and d <= 21 and dow == dayofweek.monday) or
         (m == 2  and d >= 15 and d <= 21 and dow == dayofweek.monday) or
         (y == 2024 and m == 3  and d == 29) or
         (y == 2025 and m == 4  and d == 18) or
         (y == 2026 and m == 4  and d == 3)  or
         (y == 2027 and m == 3  and d == 26) or
         (y == 2028 and m == 4  and d == 14) or
         (y == 2029 and m == 3  and d == 30) or
         (y == 2030 and m == 4  and d == 19) or
         (m == 5  and d >= 25 and dow == dayofweek.monday) or
         (m == 6  and d == 19) or
         (m == 6  and d == 18 and dow == dayofweek.friday) or
         (m == 6  and d == 20 and dow == dayofweek.monday) or
         (m == 7  and d == 4)  or
         (m == 7  and d == 3  and dow == dayofweek.friday) or
         (m == 7  and d == 5  and dow == dayofweek.monday) or
         (m == 9  and d <= 7  and dow == dayofweek.monday) or
         (m == 11 and d >= 22 and d <= 28 and dow == dayofweek.thursday) or
         (m == 12 and d == 25) or
         (m == 12 and d == 24 and dow == dayofweek.friday) or
         (m == 12 and d == 26 and dow == dayofweek.monday)
    result

// ── Market-close helpers ──────────────────────────────────────────────────────
eastHour = hour(timenow, "America/New_York")
eastDow  = dayofweek(timenow, "America/New_York")

isDailyClose =
     not is_holiday(timenow) and
     eastDow != dayofweek.saturday and
     eastDow != dayofweek.sunday and
     eastHour >= 16

isWeeklyClose =
     not is_holiday(timenow) and
     eastDow == dayofweek.friday and
     eastHour >= 16

// ── Per-bar confirmation gate ─────────────────────────────────────────────────
bool confirmed =
     timeframe.isdaily    ? (barstate.isconfirmed or isDailyClose) :
     timeframe.isweekly   ? (barstate.isconfirmed or isWeeklyClose) :
     timeframe.ismonthly  ? (barstate.isconfirmed or barstate.islast) :
     timeframe.isintraday ? barstate.isconfirmed :
     barstate.isconfirmed

// ── Raw classification (computed every bar regardless of confirmation) ─────────
bool rawOne   = high <= high[1] and low >= low[1]
bool rawThree = high > high[1]  and low < low[1]
bool rawTwoUp = high > high[1]  and low >= low[1]
bool rawTwoDn = low < low[1]    and high <= high[1]

int rawCode = rawOne ? 1 : rawTwoUp ? 21 : rawTwoDn ? 22 : rawThree ? 3 : 0

// ── Latch: only update the displayed code when the bar is confirmed ────────────
var int lastConfirmedCode  = 0
var int prevConfirmedCode  = 0
var int priorConfirmedCode = 0

if confirmed
    priorConfirmedCode := prevConfirmedCode
    prevConfirmedCode  := lastConfirmedCode
    lastConfirmedCode  := rawCode

// ── Plots (data window) ───────────────────────────────────────────────────────
plot(lastConfirmedCode,  title="Current Strat Type",  display=display.none)
plot(prevConfirmedCode,  title="Previous Strat Type", display=display.none)
plot(priorConfirmedCode, title="Prior Strat Type",    display=display.none)

// ── Chart labels (only paint on confirmed bars, persist via var latch) ─────────
var bool latchTwoUp = false
var bool latchTwoDn = false
var bool latchOne   = false
var bool latchThree = false

if confirmed
    latchTwoUp := rawTwoUp
    latchTwoDn := rawTwoDn
    latchOne   := rawOne
    latchThree := rawThree

plotchar(latchTwoUp, char="2", location=location.abovebar, color=color.green,  size=size.normal, title="2Up")
plotchar(latchTwoDn, char="2", location=location.belowbar, color=color.red,    size=size.normal, title="2Dn")
plotchar(latchOne,   char="1", location=location.belowbar, color=color.yellow, size=size.normal, title="1")
plotchar(latchThree, char="3", location=location.belowbar, color=color.purple, size=size.normal, title="3")
````
