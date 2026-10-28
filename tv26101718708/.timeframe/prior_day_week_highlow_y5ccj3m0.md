# Prior Day & Week High/Low

- url: https://www.tradingview.com/script/Y5Ccj3M0/
- type: indicator
- pine_id: PUB;b728442e6c324db5961fa3754065da7c
- version: 1.0

## Description

This indicator automatically plots the most important price reference levels directly on your chart no manual drawing required.

Daily Levels (white)

PDH / PDL – Previous Day High and Low
HOD / LOD – High and Low of the current trading day

Weekly Levels (yellow)

PWH / PWL – Previous Week High and Low
HOW / LOW – High and Low of the current trading week

Each level is displayed as a horizontal line extending from the bar where the high or low was formed to the right edge of the chart, paired with a clearly labeled tag for quick identification. All eight levels can be toggled on or off individually in the settings, and the colors for daily and weekly levels are fully customizable.
Use cases: Ideal for identifying key support and resistance zones, planning entries and exits around institutional reference points, and tracking intraday price action relative to prior session extremes.

## Source Code

````pine
//@version=6
indicator("Prior Day & Week High/Low", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════════
// EINSTELLUNGEN
// ═══════════════════════════════════════════════════════════════════════════════

ref_group = "═══════ REFERENZPUNKTE ═══════"

// Previous Day
pdh_enable = input.bool(true, "PDH (Previous Day High)", group=ref_group)
pdl_enable = input.bool(true, "PDL (Previous Day Low)", group=ref_group)

// Current Day
hod_enable = input.bool(true, "HOD (High of Day)", group=ref_group)
lod_enable = input.bool(true, "LOD (Low of Day)", group=ref_group)

// Previous Week
pwh_enable = input.bool(true, "PWH (Previous Week High)", group=ref_group)
pwl_enable = input.bool(true, "PWL (Previous Week Low)", group=ref_group)

// Current Week
how_enable = input.bool(true, "HOW (High of Week)", group=ref_group)
low_enable = input.bool(true, "LOW (Low of Week)", group=ref_group)

// Farben
ref_color_daily  = input.color(color.new(color.white, 50), "Farbe Daily", group=ref_group)
ref_color_weekly = input.color(color.new(color.yellow, 50), "Farbe Weekly", group=ref_group)

// ═══════════════════════════════════════════════════════════════════════════════
// VARIABLEN
// ═══════════════════════════════════════════════════════════════════════════════

// Neue Periode erkennen
newDay  = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0

// === DAILY ===
var float currentDayHigh    = na
var float currentDayLow     = na
var int   currentDayHighBar = na
var int   currentDayLowBar  = na

var float prevDayHigh    = na
var float prevDayLow     = na
var int   prevDayHighBar = na
var int   prevDayLowBar  = na

// === WEEKLY ===
var float currentWeekHigh    = na
var float currentWeekLow     = na
var int   currentWeekHighBar = na
var int   currentWeekLowBar  = na

var float prevWeekHigh    = na
var float prevWeekLow     = na
var int   prevWeekHighBar = na
var int   prevWeekLowBar  = na

// ═══════════════════════════════════════════════════════════════════════════════
// TRACKING LOGIK
// ═══════════════════════════════════════════════════════════════════════════════

// === DAILY TRACKING ===
if newDay
    prevDayHigh    := currentDayHigh
    prevDayLow     := currentDayLow
    prevDayHighBar := currentDayHighBar
    prevDayLowBar  := currentDayLowBar
    currentDayHigh    := high
    currentDayLow     := low
    currentDayHighBar := bar_index
    currentDayLowBar  := bar_index
else
    if high > currentDayHigh
        currentDayHigh    := high
        currentDayHighBar := bar_index
    if low < currentDayLow
        currentDayLow    := low
        currentDayLowBar := bar_index

// === WEEKLY TRACKING ===
if newWeek
    prevWeekHigh    := currentWeekHigh
    prevWeekLow     := currentWeekLow
    prevWeekHighBar := currentWeekHighBar
    prevWeekLowBar  := currentWeekLowBar
    currentWeekHigh    := high
    currentWeekLow     := low
    currentWeekHighBar := bar_index
    currentWeekLowBar  := bar_index
else
    if high > currentWeekHigh
        currentWeekHigh    := high
        currentWeekHighBar := bar_index
    if low < currentWeekLow
        currentWeekLow    := low
        currentWeekLowBar := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
// ZEICHNUNGS-FUNKTIONEN
// ═══════════════════════════════════════════════════════════════════════════════

// === DAILY LINES & LABELS ===
var line pdh_line = na
var line pdl_line = na
var line hod_line = na
var line lod_line = na

var label pdh_label = na
var label pdl_label = na
var label hod_label = na
var label lod_label = na

// === WEEKLY LINES & LABELS ===
var line pwh_line = na
var line pwl_line = na
var line how_line = na
var line low_line = na

var label pwh_label = na
var label pwl_label = na
var label how_label = na
var label low_label = na

// Funktion: Linie aktualisieren oder erstellen
updateLine(lineVar, startBar, priceLevel, lineColor) =>
    result = lineVar
    if not na(startBar) and not na(priceLevel)
        if not na(result)
            line.delete(result)
        result := line.new(startBar, priceLevel, bar_index + 20, priceLevel, 
                          color=lineColor, style=line.style_solid, width=1)
    result

// Funktion: Label aktualisieren oder erstellen
updateLabel(labelVar, priceLevel, labelText, labelColor) =>
    result = labelVar
    if not na(priceLevel)
        if not na(result)
            label.delete(result)
        result := label.new(bar_index + 22, priceLevel, labelText,
                           style=label.style_label_left,
                           color=color.new(labelColor, 100),
                           textcolor=labelColor,
                           size=size.small)
    result

// ═══════════════════════════════════════════════════════════════════════════════
// ZEICHNUNG
// ═══════════════════════════════════════════════════════════════════════════════

// === DAILY ===
if pdh_enable and not na(prevDayHigh) and not na(prevDayHighBar)
    pdh_line  := updateLine(pdh_line, prevDayHighBar, prevDayHigh, ref_color_daily)
    pdh_label := updateLabel(pdh_label, prevDayHigh, "PDH", ref_color_daily)

if pdl_enable and not na(prevDayLow) and not na(prevDayLowBar)
    pdl_line  := updateLine(pdl_line, prevDayLowBar, prevDayLow, ref_color_daily)
    pdl_label := updateLabel(pdl_label, prevDayLow, "PDL", ref_color_daily)

if hod_enable and not na(currentDayHigh) and not na(currentDayHighBar)
    hod_line  := updateLine(hod_line, currentDayHighBar, currentDayHigh, ref_color_daily)
    hod_label := updateLabel(hod_label, currentDayHigh, "HOD", ref_color_daily)

if lod_enable and not na(currentDayLow) and not na(currentDayLowBar)
    lod_line  := updateLine(lod_line, currentDayLowBar, currentDayLow, ref_color_daily)
    lod_label := updateLabel(lod_label, currentDayLow, "LOD", ref_color_daily)

// === WEEKLY ===
if pwh_enable and not na(prevWeekHigh) and not na(prevWeekHighBar)
    pwh_line  := updateLine(pwh_line, prevWeekHighBar, prevWeekHigh, ref_color_weekly)
    pwh_label := updateLabel(pwh_label, prevWeekHigh, "PWH", ref_color_weekly)

if pwl_enable and not na(prevWeekLow) and not na(prevWeekLowBar)
    pwl_line  := updateLine(pwl_line, prevWeekLowBar, prevWeekLow, ref_color_weekly)
    pwl_label := updateLabel(pwl_label, prevWeekLow, "PWL", ref_color_weekly)

if how_enable and not na(currentWeekHigh) and not na(currentWeekHighBar)
    how_line  := updateLine(how_line, currentWeekHighBar, currentWeekHigh, ref_color_weekly)
    how_label := updateLabel(how_label, currentWeekHigh, "HOW", ref_color_weekly)

if low_enable and not na(currentWeekLow) and not na(currentWeekLowBar)
    low_line  := updateLine(low_line, currentWeekLowBar, currentWeekLow, ref_color_weekly)
    low_label := updateLabel(low_label, currentWeekLow, "LOW", ref_color_weekly)
````
