# Household Equity Allocation -- Positioning Gauge

- url: https://www.tradingview.com/script/Hv8hnAt3-Household-Equity-Allocation-Positioning-Gauge/
- type: indicator
- pine_id: PUB;fcd9a79ab53c4cb189c29565d941ca2f
- version: 1.0

## Description

█ OVERVIEW

This indicator plots, in its own pane, the percentage of United States household financial assets held in corporate equities, requested live from the Federal Reserve Z.1 financial accounts. It ranks the current reading against an embedded multi-decade history, classifies it into posture zones, and reports an indicative long-horizon estimate, presenting household equity positioning as a slow, low-frequency context gauge rather than a price-derived trading signal.


█ HISTORY / BACKGROUND

The series shown is published by the Federal Reserve Board in the Z.1 Financial Accounts of the United States, formerly the Flow of Funds, available quarterly since 1945. It measures households' directly and indirectly held corporate equities as a share of their financial assets. Its use as a forward-looking context measure was popularized by the analyst writing as Philosophical Economics in 2013, who examined its historical relationship with subsequent long-horizon equity returns and contrasted it with Robert Shiller's cyclically adjusted price-to-earnings ratio.

The conceptual basis is an accounting identity rather than a behavioral model: investors in aggregate must hold the entire outstanding supply of equities, so the equity share of household assets can rise only when equity prices rise relative to the supply of other assets. The measure is therefore a positioning and relative-valuation reading expressed in committed dollars, not a sentiment survey. The script applies no proprietary transformation to the series; it requests the published values and contextualizes them.


█ HOW IT WORKS

 - The script requests the series named by the [i]FRED series[/i] input (default FRED:BOGZ1FL153064486Q) with request.security at a quarterly (3M) resolution, lookahead disabled and gaps off, taking the published close as the current allocation reading.
 - A fixed baseline of annual year-end values from 1945 through 2025 is loaded once into an array on the first bar. After a hardcoded cutoff (Q4 2025) the script appends each new distinct live reading to that array, so the baseline extends automatically as new quarters are published.
 - A percentile routine counts the baseline entries less than or equal to the current reading and returns that count as a percentage of the array size, giving the reading's full-history percentile.
 - The reading is classified into one of four zones by comparison against the three threshold inputs: below [i]Bottom-quintile[/i], below [i]Top-quintile[/i], below [i]Above historical range[/i], or at or above it. Each zone maps to a color and a posture label.
 - An indicative estimate is computed as a fixed linear function of the reading, with intercept 12.338 and slope -0.3978, using constants hardcoded in the script. When the reading exceeds the in-sample maximum of 38.7, the estimate is marked as an extrapolation.
 - The allocation is drawn as a line colored by the active zone. Three dashed horizontal lines mark the thresholds, and an optional background tint shades the pane by zone. An optional table in the top right reports the current value, its full-history percentile, the posture, the indicative estimate (flagged when extrapolated), the in-sample maximum, and the data source. The table is built only on the last bar.


█ HOW TO USE

The output is read from the pane and the table.

 - The line and its color show where positioning currently sits: green for the lowest band, gold for a neutral band, amber for an elevated band, and red for a reading above the historical range. The posture label in the table names the same state.
 - The dashed lines are the zone thresholds, and the optional background tint repeats the active zone for quick reading.
 - The table states the current value, its percentile against the full history, the posture, and the indicative long-horizon estimate, with a flag when that estimate is extrapolated beyond the historical range.

Recommended timeframe: the underlying data is quarterly and the script requests it at a quarterly resolution regardless of the chart's timeframe, so the displayed value is identical on every chart timeframe. A monthly or weekly chart on a long-history instrument is suggested only so the plotted line spans a useful visual range; the value and table do not depend on the chart timeframe or the chart symbol. Because the series is slow and lagged, it is intended for strategic, low-frequency context, not intraday or short-term use.


█ SETTINGS

 - [i]FRED series[/i] (symbol, default FRED:BOGZ1FL153064486Q): the economic series the script requests and contextualizes.
 - [i]Shade posture zones[/i] (on or off, default on): toggles the background tint that colors the pane by the active zone.
 - [i]Show info table[/i] (on or off, default on): toggles the top-right summary table.
 - [i]Bottom-quintile (cheap) below[/i] (number, default 14.0): the upper bound of the lowest zone, in percent.
 - [i]Top-quintile (underweight) above[/i] (number, default 28.0): the level above which the reading is treated as elevated.
 - [i]Above historical range above[/i] (number, default 39.0): the level above which the reading is treated as beyond the historical range.


█ WHAT MAKES IT ORIGINAL

The script does not compute a price-based study. It is a self-contained method for contextualizing a single external economic series on a chart. Its construction is specific: it pulls the series live through request.security; it ranks the current reading against a historical distribution embedded directly in the script and extended automatically after a cutoff date, so the percentile is point-in-time and does not depend on how much chart history is loaded; it maps the reading to posture zones by user thresholds; and it computes an indicative estimate from a fixed linear fit while explicitly flagging when the current reading lies beyond the data range that produced the fit. The combination of an embedded, self-extending baseline for percentile ranking, the posture zoning, and the extrapolation flag, presented together for this macro series in one pane and table, is what distinguishes it. It applies no proprietary formula on price; the contribution is the contextualization method.


█ NOTES / LIMITATIONS

 - Data dependence: the script plots an external economic series, not chart price, and requires access to the configured economic symbol through your data subscription. If the symbol cannot be resolved the request returns na, the line does not plot, and the table shows n/a.
 - Chart history and rendering: the percentile baseline and the table are independent of chart history because the baseline is embedded in the script, but the plotted line spans only the bars loaded on the chart, so on a short chart the visible line is short. The table is built only on the last bar.
 - Frequency and revision: the source is quarterly and reported with a lag, so the value changes only when a new quarter is published, and the most recent value can be revised by the source.
 - Request behavior: the series is requested with lookahead disabled, so no future data is placed on historical bars, and values are carried forward between releases. Historical readings do not repaint; only the most recent reading can change as the source releases or revises a quarter.
 - Baseline granularity and cutoff: the embedded baseline holds one value per year (annual year-end) from 1945 through 2025, and live values are appended only after the hardcoded Q4 2025 cutoff, so the percentile reference is annual before that date and extends quarterly thereafter.
 - Extrapolation: the indicative estimate is fit over readings up to 38.7, and current readings exceed that, so the estimate lies outside the fitted range and is flagged as such.
 - Symbol scope: the script is independent of the chart symbol and can be applied to any chart, since it does not read the chart's price.


This script displays historical economic data and a derived estimate for research and educational purposes. It is not investment advice.

## Source Code

````pine
// @version=6
// Household Equity Allocation -- Positioning Gauge
// Live, self-updating off FRED:BOGZ1FL153064486Q (Fed Z.1: households' directly
// and indirectly held corporate equities as a percentage of financial assets).
//
// What it does:
//   - Pulls the latest quarterly reading live from FRED (self-updates each release).
//   - Ranks it against full history (annual year-end baseline 1945-2025, auto-
//     extended by live prints) to give a point-in-time percentile.
//   - Maps the level to a posture zone and an indicative forward 10-year real
//     return estimate from the backtest fit.
//
// Backtest basis (1945-2025, 254 quarterly starts):
//   Spearman(allocation, fwd 10y real return) = -0.50  (beats CAPE's -0.43).
//   Linear fit: est fwd 10y real % = 12.338 - 0.3978 * allocation.
//   In-sample allocation range 9.5%-38.7%; current readings are above it,
//   so the estimate is an EXTRAPOLATION and is flagged as such.
//
// Use it as a strategic positioning / return-expectation gauge, NOT a timing
// tool. It is quarterly, lagged, slow-moving, and read "extended" for years
// while markets rose. Pair it with CAPE for corroboration.
//
// Retrospective analysis only. No causal mechanism claimed. Not investment advice.

indicator("Household Equity Allocation -- Positioning Gauge", "HH Equity Alloc", overlay = false)

// ============================== inputs ==============================
g_data = "Data"
g_disp = "Display"
g_zone = "Zone thresholds (%)"

srcSym = input.symbol("FRED:BOGZ1FL153064486Q", "FRED series", group = g_data, tooltip = "Fed Z.1 household equities as % of financial assets. Quarterly, ~10-12wk reporting lag.")
showZones = input.bool(true, "Shade posture zones", group = g_disp)
showTable = input.bool(true, "Show info table", group = g_disp)

tCheap = input.float(14.0, "Bottom-quintile (cheap) below", group = g_zone)
tNeutral = input.float(28.0, "Top-quintile (underweight) above", group = g_zone)
tExtreme = input.float(39.0, "Above historical range above", group = g_zone)

// ====================== backtest fit constants ======================
FIT_B = 12.338      // intercept, forward 10y real return in percent
FIT_M = -0.3978     // slope per percentage point of allocation
INSAMPLE_MAX = 38.7 // richest starting allocation with a full 10y forward window

// ============================ live data =============================
// Native quarterly resolution; lookahead off so it does not repaint.
float alloc = request.security(srcSym, "3M", close, lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

// =================== percentile baseline (history) ==================
// Annual year-end values, 1945-2025. Kept compact (one per year) so the
// percentile is meaningful on any chart length without loading 80y of bars.
var array<float> hist = array.new<float>()

seed_a(a) =>
    array.push(a, 22.52)
    array.push(a, 19.88)
    array.push(a, 18.34)
    array.push(a, 17.56)
    array.push(a, 18.09)
    array.push(a, 19.47)
    array.push(a, 20.10)
    array.push(a, 19.01)
    array.push(a, 18.09)
    array.push(a, 21.07)
    array.push(a, 23.18)
    array.push(a, 23.54)
    array.push(a, 21.10)
    array.push(a, 24.23)
    array.push(a, 25.16)
    array.push(a, 24.27)
    array.push(a, 27.08)
    array.push(a, 25.49)
    array.push(a, 25.82)
    array.push(a, 27.53)
    array.push(a, 28.76)
    array.push(a, 25.01)
    array.push(a, 28.06)
    array.push(a, 30.03)
    array.push(a, 24.62)
    array.push(a, 22.82)
    array.push(a, 23.71)

seed_b(a) =>
    array.push(a, 25.72)
    array.push(a, 18.75)
    array.push(a, 11.41)
    array.push(a, 13.68)
    array.push(a, 15.40)
    array.push(a, 12.30)
    array.push(a, 11.40)
    array.push(a, 12.11)
    array.push(a, 13.93)
    array.push(a, 11.63)
    array.push(a, 11.62)
    array.push(a, 12.20)
    array.push(a, 10.72)
    array.push(a, 12.29)
    array.push(a, 13.20)
    array.push(a, 12.48)
    array.push(a, 13.87)
    array.push(a, 15.68)
    array.push(a, 13.80)
    array.push(a, 17.87)
    array.push(a, 19.46)
    array.push(a, 21.12)
    array.push(a, 20.22)
    array.push(a, 24.40)
    array.push(a, 26.53)
    array.push(a, 30.49)
    array.push(a, 33.35)

seed_c(a) =>
    array.push(a, 37.44)
    array.push(a, 33.52)
    array.push(a, 29.83)
    array.push(a, 24.07)
    array.push(a, 28.92)
    array.push(a, 29.29)
    array.push(a, 30.10)
    array.push(a, 32.56)
    array.push(a, 31.44)
    array.push(a, 20.86)
    array.push(a, 25.86)
    array.push(a, 27.82)
    array.push(a, 25.68)
    array.push(a, 27.38)
    array.push(a, 32.01)
    array.push(a, 33.26)
    array.push(a, 31.97)
    array.push(a, 33.00)
    array.push(a, 35.94)
    array.push(a, 32.85)
    array.push(a, 36.70)
    array.push(a, 39.10)
    array.push(a, 42.42)
    array.push(a, 37.12)
    array.push(a, 40.54)
    array.push(a, 44.07)
    array.push(a, 47.11)

var bool seeded = false
if not seeded
    seed_a(hist)
    seed_b(hist)
    seed_c(hist)
    seeded := true

// auto-extend the baseline with live prints past the seeded cutoff (Q4 2025)
int cutoff = timestamp("UTC", 2025, 10, 1, 0, 0)
var float lastV = na
if not na(alloc) and (na(lastV) or alloc != lastV)
    if time > cutoff
        array.push(hist, alloc)
    lastV := alloc

// =================== percentile of current value ====================
pctile(arr, v) =>
    n = array.size(arr)
    float res = na
    if n > 0 and not na(v)
        int c = 0
        for i = 0 to n - 1
            if array.get(arr, i) <= v
                c := c + 1
        res := 100.0 * c / n
    res
float pc = pctile(hist, alloc)

// ========================= zone / posture ===========================
// 0 cheap (max weight), 1 neutral, 2 underweight, 3 above-range (caution)
int zone = na(alloc) ? na : alloc < tCheap ? 0 : alloc < tNeutral ? 1 : alloc < tExtreme ? 2 : 3
color cGreen = #2E8B57
color cGold = #C9A84C
color cAmber = #E08A3C
color cRed = #C0392B
color zoneCol = zone == 0 ? cGreen : zone == 1 ? cGold : zone == 2 ? cAmber : cRed
string posture = zone == 0 ? "Max equity weight" : zone == 1 ? "Neutral / policy" : zone == 2 ? "Underweight" : "Max caution (record)"

float estRet = FIT_B + FIT_M * alloc
bool extrap = not na(alloc) and alloc > INSAMPLE_MAX

// ============================== plot ================================
plot(alloc, "Household equity %", color = zoneCol, linewidth = 2)
hline(tCheap, "Cheap line", color = color.new(cGreen, 40), linestyle = hline.style_dashed)
hline(tNeutral, "Underweight line", color = color.new(cAmber, 40), linestyle = hline.style_dashed)
hline(tExtreme, "Above-range line", color = color.new(cRed, 40), linestyle = hline.style_dashed)
bgcolor(showZones and not na(zone) ? color.new(zoneCol, 90) : na, title = "Posture zone tint")

// ============================ info table ============================
color C_NAVY = #0A1628
color C_BODY = #142640
color C_GOLD = #C9A84C
color C_MUTE = #9FB0C3
color C_FLAG = #FF9966

var table tb = table.new(position.top_right, 2, 8, border_color = C_NAVY, border_width = 1, frame_color = C_GOLD, frame_width = 1)
if barstate.islast and showTable
    table.cell(tb, 0, 0, "HH EQUITY ALLOCATION", bgcolor = C_NAVY, text_color = C_GOLD, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, na(alloc) ? "n/a" : str.tostring(alloc, "0.0") + "%", bgcolor = C_NAVY, text_color = color.white, text_size = size.small)
    table.cell(tb, 0, 1, "Full-history pctile", bgcolor = C_BODY, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 1, na(pc) ? "n/a" : str.tostring(pc, "0") + "th", bgcolor = C_BODY, text_color = color.white, text_size = size.small)
    table.cell(tb, 0, 2, "Posture", bgcolor = C_BODY, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 2, posture, bgcolor = C_BODY, text_color = zoneCol, text_size = size.small)
    table.cell(tb, 0, 3, "Est fwd 10y real", bgcolor = C_BODY, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 3, na(estRet) ? "n/a" : str.tostring(estRet, "0.0") + "%/yr" + (extrap ? " *" : ""), bgcolor = C_BODY, text_color = extrap ? C_FLAG : color.white, text_size = size.small)
    table.cell(tb, 0, 4, "In-sample max", bgcolor = C_BODY, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 4, "38.7% (2000 era)", bgcolor = C_BODY, text_color = color.white, text_size = size.small)
    table.cell(tb, 0, 5, "Source", bgcolor = C_BODY, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 5, "FRED Z.1, quarterly", bgcolor = C_BODY, text_color = color.white, text_size = size.small)
    table.cell(tb, 0, 6, extrap ? "* extrapolated" : "decade signal", bgcolor = C_BODY, text_color = extrap ? C_FLAG : C_MUTE, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 6, extrap ? "beyond history" : "not timing", bgcolor = C_BODY, text_color = extrap ? C_FLAG : C_MUTE, text_size = size.tiny)
    table.cell(tb, 0, 7, "Not investment advice", bgcolor = C_NAVY, text_color = C_MUTE, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 7, "", bgcolor = C_NAVY, text_color = C_MUTE, text_size = size.tiny)
````
