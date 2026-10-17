# Solar & Lunar Eclipse Cycles [WenMoonLambo]

- url: https://www.tradingview.com/script/Ky64VxMx-Solar-Lunar-Eclipse-Cycles-WenMoonLambo/
- type: indicator
- pine_id: PUB;3fdcfdc1b08b44b3916a1eb3470400d0
- version: 2.0

## Description

This indicator puts every solar and lunar eclipse from 2009 to 2040 on any chart, in two views.

Cycle bands (default)
• Shades the chart in alternating solar-led (green) and lunar-led (red) periods of roughly 18 months, 14 periods from 2009 to 2034, each starting on an eclipse.
• Labels each period at its start (for example ☀ S5, 12 Aug '26) and draws a grey boundary line.
• Marks the eclipses inside each period with dashed lines and small dates along the bottom. Choose which: those matching the period's type, totals only, all, or none.
• Shades upcoming periods past today, and a panel shows the current period and the next eclipse.
• The colours only show which eclipse type leads a period. They are not buy or sell signals.

All eclipses
• A line at the moment of greatest eclipse (solid for total eclipses, dotted for the rest) and a label on the bar, with the exact time in the tooltip.
• Each eclipse type can be switched on and off; upcoming eclipses are drawn ahead of the last bar.
• An alert condition fires on the bar containing an eclipse.

Data
All 146 eclipse dates and types come from NASA's Five Millennium Canon of eclipses (Espenak and Meeus, NASA Goddard Space Flight Center). Times are the instant of greatest eclipse in Terrestrial Time, about 69 seconds ahead of UTC, so the date is never affected. Borderline penumbral events that the canon doesn't count, such as 18 August 2016, are left out.

A note on use
This is a calendar tool. Eclipses are precisely predictable astronomical events; whether they relate to market moves is a separate question, and tests of lunar-cycle effects on Bitcoin have not found a reliable edge. Use it to check claims against the chart yourself, not as a signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © WenMoonLambo
//@version=6
indicator("Solar & Lunar Eclipse Cycles [WenMoonLambo]", shorttitle="Eclipses", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// Every solar and lunar eclipse from 2009 to 2040, from NASA's Five Millennium Canon
// tables (Espenak & Meeus, NASA GSFC). Times are the instant of greatest eclipse in
// Terrestrial Time, about 69 seconds ahead of UTC, so the date is never affected.
//
// Two modes:
//   Cycle bands  - alternating solar-led / lunar-led periods of roughly 18 months
//                  (14 periods, 2009-2034), each starting on an eclipse.
//   All eclipses - a line and label at every eclipse.
// Colours show which eclipse type leads a period. They are not buy or sell signals,
// and this script makes no claim that eclipses move prices.

// ── Inputs ───────────────────────────────────────────────────────────────────
mode        = input.string("Cycle bands", "Mode", options=["Cycle bands", "All eclipses"])
solarColor  = input.color(#10b981, "Solar colour", inline="c")
lunarColor  = input.color(#ef4444, "Lunar colour", inline="c")

grpB = "Cycle bands"
bandOpacity = input.int(10, "Band opacity %", minval=0, maxval=60, group=grpB)
markerMode  = input.string("Matching the band", "Eclipse markers", options=["Matching the band", "Total only", "All", "None"], group=grpB,
             tooltip="Matching the band: solar eclipses in solar-led periods, lunar in lunar-led. Total only: the same, totals only.")
showHeads   = input.bool(true, "Period labels", group=grpB)

grpA = "All eclipses"
sTotal      = input.bool(true, "Solar: total",     group=grpA, inline="s1")
sAnnular    = input.bool(true, "annular",          group=grpA, inline="s1")
sHybrid     = input.bool(true, "hybrid",           group=grpA, inline="s1")
sPartial    = input.bool(true, "partial",          group=grpA, inline="s1")
lTotal      = input.bool(true, "Lunar: total",     group=grpA, inline="l1")
lPartial    = input.bool(true, "partial",          group=grpA, inline="l1")
lPenumbral  = input.bool(true, "penumbral",        group=grpA, inline="l1")
showLabels  = input.bool(true, "Labels",           group=grpA)
showBg      = input.bool(false, "Highlight the eclipse bar", group=grpA)

grpD = "Display"
yearsAhead  = input.int(8, "Years ahead (eclipse markers)", minval=1, maxval=15, group=grpD,
             tooltip="Periods are always shaded to the end of the table (May 2034).")
showNext    = input.bool(true, "Countdown panel", group=grpD, inline="p")
panelPos    = input.string("Top right", "", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=grpD, inline="p")

bandsMode = mode == "Cycle bands"
BOUNDARY  = #64748b
LABEL_BG  = color.new(#0a0e1a, 15)
DAY_MS    = 86400000

// ── Data ─────────────────────────────────────────────────────────────────────
type Eclipse
    int    t
    string kind   // "Solar" | "Lunar"
    string typ    // Total | Annular | Hybrid | Partial | Penumbral

type Band
    string id
    string kind   // "Solar" | "Lunar"
    int    t0     // first day (00:00 UTC, the day of its opening eclipse)
    int    t1     // first day of the next period

ecl(int y, int m, int d, int h, int mi, string kind, string typ) =>
    Eclipse.new(timestamp("UTC", y, m, d, h, mi), kind, typ)

var array<Eclipse> E = array.new<Eclipse>()
var array<Band>    B = array.new<Band>()
if barstate.isfirst
    E.push(ecl(2009, 1, 26, 7, 59, "Solar", "Annular"))
    E.push(ecl(2009, 2, 9, 14, 39, "Lunar", "Penumbral"))
    E.push(ecl(2009, 7, 7, 9, 39, "Lunar", "Penumbral"))
    E.push(ecl(2009, 7, 22, 2, 36, "Solar", "Total"))
    E.push(ecl(2009, 8, 6, 0, 40, "Lunar", "Penumbral"))
    E.push(ecl(2009, 12, 31, 19, 23, "Lunar", "Partial"))
    E.push(ecl(2010, 1, 15, 7, 7, "Solar", "Annular"))
    E.push(ecl(2010, 6, 26, 11, 39, "Lunar", "Partial"))
    E.push(ecl(2010, 7, 11, 19, 34, "Solar", "Total"))
    E.push(ecl(2010, 12, 21, 8, 18, "Lunar", "Total"))
    E.push(ecl(2011, 1, 4, 8, 51, "Solar", "Partial"))
    E.push(ecl(2011, 6, 1, 21, 17, "Solar", "Partial"))
    E.push(ecl(2011, 6, 15, 20, 13, "Lunar", "Total"))
    E.push(ecl(2011, 7, 1, 8, 39, "Solar", "Partial"))
    E.push(ecl(2011, 11, 25, 6, 21, "Solar", "Partial"))
    E.push(ecl(2011, 12, 10, 14, 32, "Lunar", "Total"))
    E.push(ecl(2012, 5, 20, 23, 53, "Solar", "Annular"))
    E.push(ecl(2012, 6, 4, 11, 4, "Lunar", "Partial"))
    E.push(ecl(2012, 11, 13, 22, 12, "Solar", "Total"))
    E.push(ecl(2012, 11, 28, 14, 34, "Lunar", "Penumbral"))
    E.push(ecl(2013, 4, 25, 20, 8, "Lunar", "Partial"))
    E.push(ecl(2013, 5, 10, 0, 26, "Solar", "Annular"))
    E.push(ecl(2013, 5, 25, 4, 11, "Lunar", "Penumbral"))
    E.push(ecl(2013, 10, 18, 23, 51, "Lunar", "Penumbral"))
    E.push(ecl(2013, 11, 3, 12, 47, "Solar", "Hybrid"))
    E.push(ecl(2014, 4, 15, 7, 46, "Lunar", "Total"))
    E.push(ecl(2014, 4, 29, 6, 4, "Solar", "Annular"))
    E.push(ecl(2014, 10, 8, 10, 55, "Lunar", "Total"))
    E.push(ecl(2014, 10, 23, 21, 45, "Solar", "Partial"))
    E.push(ecl(2015, 3, 20, 9, 46, "Solar", "Total"))
    E.push(ecl(2015, 4, 4, 12, 1, "Lunar", "Total"))
    E.push(ecl(2015, 9, 13, 6, 55, "Solar", "Partial"))
    E.push(ecl(2015, 9, 28, 2, 48, "Lunar", "Total"))
    E.push(ecl(2016, 3, 9, 1, 58, "Solar", "Total"))
    E.push(ecl(2016, 3, 23, 11, 48, "Lunar", "Penumbral"))
    E.push(ecl(2016, 9, 1, 9, 8, "Solar", "Annular"))
    E.push(ecl(2016, 9, 16, 18, 55, "Lunar", "Penumbral"))
    E.push(ecl(2017, 2, 11, 0, 45, "Lunar", "Penumbral"))
    E.push(ecl(2017, 2, 26, 14, 54, "Solar", "Annular"))
    E.push(ecl(2017, 8, 7, 18, 21, "Lunar", "Partial"))
    E.push(ecl(2017, 8, 21, 18, 26, "Solar", "Total"))
    E.push(ecl(2018, 1, 31, 13, 31, "Lunar", "Total"))
    E.push(ecl(2018, 2, 15, 20, 52, "Solar", "Partial"))
    E.push(ecl(2018, 7, 13, 3, 2, "Solar", "Partial"))
    E.push(ecl(2018, 7, 27, 20, 22, "Lunar", "Total"))
    E.push(ecl(2018, 8, 11, 9, 47, "Solar", "Partial"))
    E.push(ecl(2019, 1, 6, 1, 42, "Solar", "Partial"))
    E.push(ecl(2019, 1, 21, 5, 13, "Lunar", "Total"))
    E.push(ecl(2019, 7, 2, 19, 24, "Solar", "Total"))
    E.push(ecl(2019, 7, 16, 21, 31, "Lunar", "Partial"))
    E.push(ecl(2019, 12, 26, 5, 18, "Solar", "Annular"))
    E.push(ecl(2020, 1, 10, 19, 11, "Lunar", "Penumbral"))
    E.push(ecl(2020, 6, 5, 19, 26, "Lunar", "Penumbral"))
    E.push(ecl(2020, 6, 21, 6, 41, "Solar", "Annular"))
    E.push(ecl(2020, 7, 5, 4, 31, "Lunar", "Penumbral"))
    E.push(ecl(2020, 11, 30, 9, 44, "Lunar", "Penumbral"))
    E.push(ecl(2020, 12, 14, 16, 14, "Solar", "Total"))
    E.push(ecl(2021, 5, 26, 11, 19, "Lunar", "Total"))
    E.push(ecl(2021, 6, 10, 10, 43, "Solar", "Annular"))
    E.push(ecl(2021, 11, 19, 9, 4, "Lunar", "Partial"))
    E.push(ecl(2021, 12, 4, 7, 34, "Solar", "Total"))
    E.push(ecl(2022, 4, 30, 20, 42, "Solar", "Partial"))
    E.push(ecl(2022, 5, 16, 4, 12, "Lunar", "Total"))
    E.push(ecl(2022, 10, 25, 11, 1, "Solar", "Partial"))
    E.push(ecl(2022, 11, 8, 11, 0, "Lunar", "Total"))
    E.push(ecl(2023, 4, 20, 4, 17, "Solar", "Hybrid"))
    E.push(ecl(2023, 5, 5, 17, 24, "Lunar", "Penumbral"))
    E.push(ecl(2023, 10, 14, 18, 0, "Solar", "Annular"))
    E.push(ecl(2023, 10, 28, 20, 15, "Lunar", "Partial"))
    E.push(ecl(2024, 3, 25, 7, 13, "Lunar", "Penumbral"))
    E.push(ecl(2024, 4, 8, 18, 18, "Solar", "Total"))
    E.push(ecl(2024, 9, 18, 2, 45, "Lunar", "Partial"))
    E.push(ecl(2024, 10, 2, 18, 46, "Solar", "Annular"))
    E.push(ecl(2025, 3, 14, 6, 59, "Lunar", "Total"))
    E.push(ecl(2025, 3, 29, 10, 48, "Solar", "Partial"))
    E.push(ecl(2025, 9, 7, 18, 12, "Lunar", "Total"))
    E.push(ecl(2025, 9, 21, 19, 43, "Solar", "Partial"))
    E.push(ecl(2026, 2, 17, 12, 13, "Solar", "Annular"))
    E.push(ecl(2026, 3, 3, 11, 34, "Lunar", "Total"))
    E.push(ecl(2026, 8, 12, 17, 47, "Solar", "Total"))
    E.push(ecl(2026, 8, 28, 4, 14, "Lunar", "Partial"))
    E.push(ecl(2027, 2, 6, 16, 0, "Solar", "Annular"))
    E.push(ecl(2027, 2, 20, 23, 14, "Lunar", "Penumbral"))
    E.push(ecl(2027, 7, 18, 16, 4, "Lunar", "Penumbral"))
    E.push(ecl(2027, 8, 2, 10, 7, "Solar", "Total"))
    E.push(ecl(2027, 8, 17, 7, 14, "Lunar", "Penumbral"))
    E.push(ecl(2028, 1, 12, 4, 14, "Lunar", "Partial"))
    E.push(ecl(2028, 1, 26, 15, 8, "Solar", "Annular"))
    E.push(ecl(2028, 7, 6, 18, 20, "Lunar", "Partial"))
    E.push(ecl(2028, 7, 22, 2, 56, "Solar", "Total"))
    E.push(ecl(2028, 12, 31, 16, 53, "Lunar", "Total"))
    E.push(ecl(2029, 1, 14, 17, 13, "Solar", "Partial"))
    E.push(ecl(2029, 6, 12, 4, 6, "Solar", "Partial"))
    E.push(ecl(2029, 6, 26, 3, 23, "Lunar", "Total"))
    E.push(ecl(2029, 7, 11, 15, 37, "Solar", "Partial"))
    E.push(ecl(2029, 12, 5, 15, 3, "Solar", "Partial"))
    E.push(ecl(2029, 12, 20, 22, 43, "Lunar", "Total"))
    E.push(ecl(2030, 6, 1, 6, 29, "Solar", "Annular"))
    E.push(ecl(2030, 6, 15, 18, 34, "Lunar", "Partial"))
    E.push(ecl(2030, 11, 25, 6, 51, "Solar", "Total"))
    E.push(ecl(2030, 12, 9, 22, 28, "Lunar", "Penumbral"))
    E.push(ecl(2031, 5, 7, 3, 52, "Lunar", "Penumbral"))
    E.push(ecl(2031, 5, 21, 7, 16, "Solar", "Annular"))
    E.push(ecl(2031, 6, 5, 11, 45, "Lunar", "Penumbral"))
    E.push(ecl(2031, 10, 30, 7, 46, "Lunar", "Penumbral"))
    E.push(ecl(2031, 11, 14, 21, 7, "Solar", "Hybrid"))
    E.push(ecl(2032, 4, 25, 15, 14, "Lunar", "Total"))
    E.push(ecl(2032, 5, 9, 13, 26, "Solar", "Annular"))
    E.push(ecl(2032, 10, 18, 19, 3, "Lunar", "Total"))
    E.push(ecl(2032, 11, 3, 5, 34, "Solar", "Partial"))
    E.push(ecl(2033, 3, 30, 18, 2, "Solar", "Total"))
    E.push(ecl(2033, 4, 14, 19, 13, "Lunar", "Total"))
    E.push(ecl(2033, 9, 23, 13, 54, "Solar", "Partial"))
    E.push(ecl(2033, 10, 8, 10, 56, "Lunar", "Total"))
    E.push(ecl(2034, 3, 20, 10, 18, "Solar", "Total"))
    E.push(ecl(2034, 4, 3, 19, 6, "Lunar", "Penumbral"))
    E.push(ecl(2034, 9, 12, 16, 19, "Solar", "Annular"))
    E.push(ecl(2034, 9, 28, 2, 47, "Lunar", "Partial"))
    E.push(ecl(2035, 2, 22, 9, 6, "Lunar", "Penumbral"))
    E.push(ecl(2035, 3, 9, 23, 5, "Solar", "Annular"))
    E.push(ecl(2035, 8, 19, 1, 12, "Lunar", "Partial"))
    E.push(ecl(2035, 9, 2, 1, 56, "Solar", "Total"))
    E.push(ecl(2036, 2, 11, 22, 13, "Lunar", "Total"))
    E.push(ecl(2036, 2, 27, 4, 46, "Solar", "Partial"))
    E.push(ecl(2036, 7, 23, 10, 32, "Solar", "Partial"))
    E.push(ecl(2036, 8, 7, 2, 52, "Lunar", "Total"))
    E.push(ecl(2036, 8, 21, 17, 25, "Solar", "Partial"))
    E.push(ecl(2037, 1, 16, 9, 48, "Solar", "Partial"))
    E.push(ecl(2037, 1, 31, 14, 1, "Lunar", "Total"))
    E.push(ecl(2037, 7, 13, 2, 40, "Solar", "Total"))
    E.push(ecl(2037, 7, 27, 4, 9, "Lunar", "Partial"))
    E.push(ecl(2038, 1, 5, 13, 47, "Solar", "Annular"))
    E.push(ecl(2038, 1, 21, 3, 49, "Lunar", "Penumbral"))
    E.push(ecl(2038, 6, 17, 2, 45, "Lunar", "Penumbral"))
    E.push(ecl(2038, 7, 2, 13, 32, "Solar", "Annular"))
    E.push(ecl(2038, 7, 16, 11, 35, "Lunar", "Penumbral"))
    E.push(ecl(2038, 12, 11, 17, 44, "Lunar", "Penumbral"))
    E.push(ecl(2038, 12, 26, 1, 0, "Solar", "Total"))
    E.push(ecl(2039, 6, 6, 18, 54, "Lunar", "Partial"))
    E.push(ecl(2039, 6, 21, 17, 12, "Solar", "Annular"))
    E.push(ecl(2039, 11, 30, 16, 56, "Lunar", "Partial"))
    E.push(ecl(2039, 12, 15, 16, 23, "Solar", "Total"))
    E.push(ecl(2040, 5, 11, 3, 43, "Solar", "Partial"))
    E.push(ecl(2040, 5, 26, 11, 46, "Lunar", "Total"))
    E.push(ecl(2040, 11, 4, 19, 9, "Solar", "Partial"))
    E.push(ecl(2040, 11, 18, 19, 4, "Lunar", "Total"))
    B.push(Band.new("S0", "Solar", timestamp("UTC", 2009, 1, 26, 0, 0), timestamp("UTC", 2010, 12, 21, 0, 0)))
    B.push(Band.new("L1", "Lunar", timestamp("UTC", 2010, 12, 21, 0, 0), timestamp("UTC", 2012, 5, 20, 0, 0)))
    B.push(Band.new("S1", "Solar", timestamp("UTC", 2012, 5, 20, 0, 0), timestamp("UTC", 2014, 4, 15, 0, 0)))
    B.push(Band.new("L2", "Lunar", timestamp("UTC", 2014, 4, 15, 0, 0), timestamp("UTC", 2016, 3, 9, 0, 0)))
    B.push(Band.new("S2", "Solar", timestamp("UTC", 2016, 3, 9, 0, 0), timestamp("UTC", 2018, 1, 31, 0, 0)))
    B.push(Band.new("L3", "Lunar", timestamp("UTC", 2018, 1, 31, 0, 0), timestamp("UTC", 2019, 7, 2, 0, 0)))
    B.push(Band.new("S3", "Solar", timestamp("UTC", 2019, 7, 2, 0, 0), timestamp("UTC", 2021, 5, 26, 0, 0)))
    B.push(Band.new("L4", "Lunar", timestamp("UTC", 2021, 5, 26, 0, 0), timestamp("UTC", 2023, 4, 20, 0, 0)))
    B.push(Band.new("S4", "Solar", timestamp("UTC", 2023, 4, 20, 0, 0), timestamp("UTC", 2025, 3, 14, 0, 0)))
    B.push(Band.new("L5", "Lunar", timestamp("UTC", 2025, 3, 14, 0, 0), timestamp("UTC", 2026, 8, 12, 0, 0)))
    B.push(Band.new("S5", "Solar", timestamp("UTC", 2026, 8, 12, 0, 0), timestamp("UTC", 2028, 12, 31, 0, 0)))
    B.push(Band.new("L6", "Lunar", timestamp("UTC", 2028, 12, 31, 0, 0), timestamp("UTC", 2030, 6, 1, 0, 0)))
    B.push(Band.new("S6", "Solar", timestamp("UTC", 2030, 6, 1, 0, 0), timestamp("UTC", 2032, 4, 25, 0, 0)))
    B.push(Band.new("L7", "Lunar", timestamp("UTC", 2032, 4, 25, 0, 0), timestamp("UTC", 2034, 5, 22, 0, 0)))

// ── Helpers ──────────────────────────────────────────────────────────────────
colorOf(string kind) =>
    kind == "Solar" ? solarColor : lunarColor

icon(string kind) =>
    kind == "Solar" ? "☀" : "☽"

shortDate(int t) =>
    str.format_time(t, "dd MMM", "UTC") + " '" + str.format_time(t, "yy", "UTC")

bandAt(int t) =>
    Band found = na
    for b in B
        if t >= b.t0 and t < b.t1
            found := b
            break
    found

isBoundary(Eclipse x) =>
    bool hit = false
    for b in B
        if x.t >= b.t0 and x.t < b.t0 + DAY_MS
            hit := true
            break
    hit

wantedAll(Eclipse x) =>
    if x.kind == "Solar"
        x.typ == "Total" ? sTotal : x.typ == "Annular" ? sAnnular : x.typ == "Hybrid" ? sHybrid : sPartial
    else
        x.typ == "Total" ? lTotal : x.typ == "Partial" ? lPartial : lPenumbral

wantedBand(Eclipse x) =>
    Band b = bandAt(x.t)
    bool matches = false
    if not na(b)
        matches := b.kind == x.kind
    markerMode == "All" ? true : markerMode == "None" ? false : markerMode == "Total only" ? matches and x.typ == "Total" : matches

textOf(Eclipse x) =>
    icon(x.kind) + " " + x.typ + " " + str.lower(x.kind)

tipOf(Eclipse x) =>
    x.typ + " " + str.lower(x.kind) + " eclipse\n" + str.format_time(x.t, "yyyy-MM-dd HH:mm", "UTC") + " (greatest eclipse)"

// Running price extremes: period labels sit at the top, marker dates at the bottom.
var float hiAll = high
var float loAll = low
hiAll := math.max(hiAll, high)
loAll := math.min(loAll, low)
var int firstBarTime = time

// ── Cycle bands: shading on existing bars ────────────────────────────────────
var int bIdx = 0
while bandsMode and bIdx < B.size() and B.get(bIdx).t1 <= time
    bIdx += 1
color bandBg = na
if bandsMode and bIdx < B.size()
    Band cb = B.get(bIdx)
    if time >= cb.t0
        bandBg := color.new(colorOf(cb.kind), 100 - bandOpacity)
bgcolor(bandBg)

// ── Cycle bands: everything else, drawn once on the last bar ─────────────────
var bool bandsDrawn = false
if bandsMode and barstate.islast and not bandsDrawn
    bandsDrawn := true
    horizon = time_close + yearsAhead * 365 * DAY_MS
    for b in B
        if b.t1 <= firstBarTime
            continue
        c = colorOf(b.kind)
        // Shading past the last bar: a fill between two invisible vertical lines.
        // Extended lines fill the full chart height at any zoom, and only their short
        // anchor segment counts towards autoscale (a tall box would squash the price).
        if b.t1 > time_close
            edgeL = line.new(math.max(b.t0, time_close), close, math.max(b.t0, time_close), close * 1.01,
                             xloc=xloc.bar_time, extend=extend.both, color=color.new(c, 100))
            edgeR = line.new(b.t1, close, b.t1, close * 1.01,
                             xloc=xloc.bar_time, extend=extend.both, color=color.new(c, 100))
            linefill.new(edgeL, edgeR, color.new(c, 100 - bandOpacity))
        if b.t0 >= firstBarTime
            line.new(b.t0, close, b.t0, close * 1.01, xloc=xloc.bar_time, extend=extend.both, color=BOUNDARY, width=1)
            if showHeads
                label.new(b.t0, hiAll, icon(b.kind) + " " + b.id + "\n" + shortDate(b.t0), xloc=xloc.bar_time,
                          yloc=yloc.price, style=label.style_label_down, color=LABEL_BG, textcolor=c, size=size.small,
                          tooltip=(b.kind == "Solar" ? "Solar-led period " : "Lunar-led period ") + b.id + ": "
                                  + str.format_time(b.t0, "yyyy-MM-dd", "UTC") + " to " + str.format_time(b.t1 - DAY_MS, "yyyy-MM-dd", "UTC"))
    for x in E
        if x.t > horizon
            break
        if x.t < firstBarTime or isBoundary(x) or not wantedBand(x)
            continue
        c = colorOf(x.kind)
        line.new(x.t, close, x.t, close * 1.01, xloc=xloc.bar_time, extend=extend.both, color=color.new(c, 70), style=line.style_dashed, width=1)
        label.new(x.t, loAll, shortDate(x.t), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up,
                  color=color.new(color.black, 100), textcolor=color.new(c, 20), size=size.tiny, tooltip=tipOf(x))

// ── All eclipses: mark each one on the bar that contains it ──────────────────
// A pointer walks the sorted list once. An eclipse that falls in a gap (a weekend
// on a stock chart) is marked on the next bar; its label still shows the real date.
var int idx = 0
hitText = ""
hitTip  = ""
color hitColor = na
while not bandsMode and idx < E.size() and E.get(idx).t < time_close
    x = E.get(idx)
    if x.t >= firstBarTime and wantedAll(x)
        line.new(x.t, close, x.t, close * 1.01, xloc=xloc.bar_time, extend=extend.both,
                 color=color.new(colorOf(x.kind), x.typ == "Total" ? 0 : 45),
                 style=x.typ == "Total" ? line.style_solid : line.style_dotted, width=1)
        hitText := hitText == "" ? textOf(x) : hitText + "\n" + textOf(x)
        hitTip  := hitTip  == "" ? tipOf(x)  : hitTip  + "\n\n" + tipOf(x)
        hitColor := colorOf(x.kind)
    idx += 1

hit = hitText != ""
if hit and showLabels
    label.new(bar_index, high, hitText, yloc=yloc.abovebar, style=label.style_label_down,
              color=color.new(hitColor, 20), textcolor=color.white, size=size.small, tooltip=hitTip)
bgcolor(showBg and hit ? color.new(hitColor, 85) : na)
alertcondition(hit, "Eclipse on this bar (All eclipses mode)", "An eclipse falls on the current bar")

// Upcoming eclipses past the last bar (the idx guard matters: Pine's for loop
// counts DOWN when start > end).
var bool futureDrawn = false
if not bandsMode and barstate.islast and not futureDrawn and idx < E.size()
    futureDrawn := true
    horizon = time_close + yearsAhead * 365 * DAY_MS
    for i = idx to E.size() - 1
        x = E.get(i)
        if x.t > horizon
            break
        if wantedAll(x)
            line.new(x.t, close, x.t, close * 1.01, xloc=xloc.bar_time, extend=extend.both,
                     color=color.new(colorOf(x.kind), x.typ == "Total" ? 0 : 45),
                     style=x.typ == "Total" ? line.style_solid : line.style_dotted, width=1)
            if showLabels
                label.new(x.t, high, textOf(x) + "\n" + str.format_time(x.t, "yyyy-MM-dd", "UTC"),
                          xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down,
                          color=color.new(colorOf(x.kind), 40), textcolor=color.white, size=size.small,
                          tooltip=tipOf(x))

// ── Countdown panel ──────────────────────────────────────────────────────────
var table panel = table.new(panelPos == "Top left" ? position.top_left : panelPos == "Bottom right" ? position.bottom_right : panelPos == "Bottom left" ? position.bottom_left : position.top_right, 1, 2, bgcolor=color.new(color.gray, 85), border_width=1)
if barstate.islast and showNext
    string nextMsg = "No eclipse left in the table"
    for x in E
        if x.t > timenow and (bandsMode or wantedAll(x))
            days = math.ceil((x.t - timenow) / 86400000.0)
            nextMsg := "Next: " + x.typ + " " + str.lower(x.kind) + " eclipse, " + shortDate(x.t) + " (in " + str.tostring(days) + " days)"
            break
    table.cell(panel, 0, 0, nextMsg, text_color=chart.fg_color, text_size=size.small)
    if bandsMode
        Band cur = bandAt(timenow)
        if na(cur)
            table.cell(panel, 0, 1, "Outside the 2009-2034 periods", text_color=chart.fg_color, text_size=size.small)
        else
            curMsg = "Now: " + icon(cur.kind) + " " + cur.id + " " + str.lower(cur.kind) + "-led period, " + shortDate(cur.t0) + " to " + shortDate(cur.t1 - DAY_MS)
            table.cell(panel, 0, 1, curMsg, text_color=colorOf(cur.kind), text_size=size.small)
````
