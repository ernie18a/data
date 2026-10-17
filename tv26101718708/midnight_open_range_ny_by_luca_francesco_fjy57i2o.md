# Midnight Open Range NY by Luca Francesco

- url: https://www.tradingview.com/script/FJy57I2o/
- type: indicator
- pine_id: PUB;ff552ec316764a1db1a13cabdf95d608
- version: 1.0

## Description

**Midnight Open Range NY**

* Berechnet die Midnight Open Range von **00:00 bis 00:30 New York Zeit**.
* Zeichnet ein halbtransparentes graues Rechteck für die Range.
* Zeigt Fibonacci-Level bei **100 %, 75 %, 50 %, 25 % und 0 %**.
* Alle Level werden nach rechts unendlich verlängert.
* Datum wird links neben jeder Range angezeigt.
* Speichert und zeigt die letzten **20 Ranges**.
* Funktioniert auf **M1, M5 und M15**.
* Automatische Aktualisierung ohne Repainting.
* Geeignet für Breakouts, ICT-Konzepte, Liquidity Sweeps sowie Intraday- und Scalping-Trading.

## Source Code

````pine
//@version=6
indicator("Midnight Open Range NY", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
// SETTINGS
// ============================================================================

string TZ = "America/New_York"
int MAX_RANGES = 20

// Colors
color BOX_COLOR = color.new(color.gray, 85)

color LVL100 = color.green
color LVL75  = color.blue
color LVL50  = color.yellow
color LVL25  = color.orange
color LVL0   = color.red

// ============================================================================
// ARRAYS FOR OBJECT MANAGEMENT
// ============================================================================

var box[] rangeBoxes = array.new_box()

var line[] lvl100Lines = array.new_line()
var line[] lvl75Lines  = array.new_line()
var line[] lvl50Lines  = array.new_line()
var line[] lvl25Lines  = array.new_line()
var line[] lvl0Lines   = array.new_line()

var label[] lvl100Labels = array.new_label()
var label[] lvl75Labels  = array.new_label()
var label[] lvl50Labels  = array.new_label()
var label[] lvl25Labels  = array.new_label()
var label[] lvl0Labels   = array.new_label()

var label[] dateLabels = array.new_label()

// ============================================================================
// NEW YORK TIME
// ============================================================================

nyHour   = hour(time, TZ)
nyMinute = minute(time, TZ)

isRangeStart = nyHour == 0 and nyMinute == 0
isRangeBar   = nyHour == 0 and nyMinute < 30
isRangeEnd   = nyHour == 0 and nyMinute == 30

// ============================================================================
// RANGE VARIABLES
// ============================================================================

var float rangeHigh = na
var float rangeLow  = na
var int rangeStartBar = na

// ============================================================================
// START NEW RANGE
// ============================================================================

if isRangeStart
    rangeHigh := high
    rangeLow := low
    rangeStartBar := bar_index

// ============================================================================
// BUILD RANGE
// ============================================================================

if isRangeBar
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow, low)

// ============================================================================
// CREATE OBJECTS AFTER RANGE CLOSES
// ============================================================================

if isRangeEnd and not na(rangeHigh) and not na(rangeLow)

    float size = rangeHigh - rangeLow

    float lvl100 = rangeHigh
    float lvl75  = rangeLow + size * 0.75
    float lvl50  = rangeLow + size * 0.50
    float lvl25  = rangeLow + size * 0.25
    float lvl0   = rangeLow

    // ------------------------------------------------------------------------
    // RANGE BOX
    // ------------------------------------------------------------------------

    box b = box.new(
         rangeStartBar,
         rangeHigh,
         bar_index,
         rangeLow,
         bgcolor = BOX_COLOR,
         border_color = color.gray,
         border_width = 1)

    array.push(rangeBoxes, b)

    // ------------------------------------------------------------------------
    // FIB LEVELS
    // ------------------------------------------------------------------------

    line l100 = line.new(
         bar_index,
         lvl100,
         bar_index + 1,
         lvl100,
         extend = extend.right,
         color = LVL100,
         width = 2)

    line l75 = line.new(
         bar_index,
         lvl75,
         bar_index + 1,
         lvl75,
         extend = extend.right,
         color = LVL75,
         width = 2)

    line l50 = line.new(
         bar_index,
         lvl50,
         bar_index + 1,
         lvl50,
         extend = extend.right,
         color = LVL50,
         width = 2)

    line l25 = line.new(
         bar_index,
         lvl25,
         bar_index + 1,
         lvl25,
         extend = extend.right,
         color = LVL25,
         width = 2)

    line l0 = line.new(
         bar_index,
         lvl0,
         bar_index + 1,
         lvl0,
         extend = extend.right,
         color = LVL0,
         width = 2)

    array.push(lvl100Lines, l100)
    array.push(lvl75Lines, l75)
    array.push(lvl50Lines, l50)
    array.push(lvl25Lines, l25)
    array.push(lvl0Lines, l0)

    // ------------------------------------------------------------------------
    // LEVEL LABELS
    // ------------------------------------------------------------------------

    label lb100 = label.new(
         bar_index,
         lvl100,
         "100%",
         style = label.style_label_left,
         textcolor = color.white,
         color = LVL100)

    label lb75 = label.new(
         bar_index,
         lvl75,
         "75%",
         style = label.style_label_left,
         textcolor = color.white,
         color = LVL75)

    label lb50 = label.new(
         bar_index,
         lvl50,
         "50%",
         style = label.style_label_left,
         textcolor = color.black,
         color = LVL50)

    label lb25 = label.new(
         bar_index,
         lvl25,
         "25%",
         style = label.style_label_left,
         textcolor = color.white,
         color = LVL25)

    label lb0 = label.new(
         bar_index,
         lvl0,
         "0%",
         style = label.style_label_left,
         textcolor = color.white,
         color = LVL0)

    array.push(lvl100Labels, lb100)
    array.push(lvl75Labels, lb75)
    array.push(lvl50Labels, lb50)
    array.push(lvl25Labels, lb25)
    array.push(lvl0Labels, lb0)

    // ------------------------------------------------------------------------
    // DATE LABEL
    // ------------------------------------------------------------------------

    string dateText =
         str.tostring(year(time, TZ)) + "-" +
         str.tostring(month(time, TZ)) + "-" +
         str.tostring(dayofmonth(time, TZ))

    label dLabel = label.new(
         rangeStartBar,
         rangeHigh,
         dateText,
         style = label.style_label_left,
         color = color.new(color.gray, 30),
         textcolor = color.white)

    array.push(dateLabels, dLabel)

    // ------------------------------------------------------------------------
    // KEEP ONLY MOST RECENT 20 RANGES
    // ------------------------------------------------------------------------

    while array.size(rangeBoxes) > MAX_RANGES

        box.delete(array.shift(rangeBoxes))

        line.delete(array.shift(lvl100Lines))
        line.delete(array.shift(lvl75Lines))
        line.delete(array.shift(lvl50Lines))
        line.delete(array.shift(lvl25Lines))
        line.delete(array.shift(lvl0Lines))

        label.delete(array.shift(lvl100Labels))
        label.delete(array.shift(lvl75Labels))
        label.delete(array.shift(lvl50Labels))
        label.delete(array.shift(lvl25Labels))
        label.delete(array.shift(lvl0Labels))

        label.delete(array.shift(dateLabels))

    // Reset variables
    rangeHigh := na
    rangeLow := na
    rangeStartBar := na
````
