# VWAP Anker: Time, ATH/ATL, Swings, Pivots & Dynamic Alerts

- url: https://www.tradingview.com/script/C8QueFWm/
- type: indicator
- pine_id: PUB;291b18f277b148b7b88872bdfcfdba5b
- version: 1.0

## Description

VWAP Ultimate: Time, ATH/ATL & Bear-Market Swings

VWAP Ultimate combines multiple important VWAP anchors into a single indicator, helping traders identify institutional price levels, long-term market structure, and key support and resistance zones.

Instead of relying on a single traditional VWAP, this indicator provides several anchoring methods that offer different perspectives on market behavior.

Included VWAP Types
📅 Time-Based VWAPs
Daily VWAP
Weekly VWAP
Monthly VWAP

These VWAPs automatically reset at the beginning of each new period and are especially useful for:

Intraday trading
Swing trading
Trend identification
Dynamic support and resistance levels
🚀 All-Time High VWAP (ATH VWAP)

This VWAP is anchored from the asset's historical all-time high.

Use cases:

Evaluating market strength after major bullish moves
Identifying long-term resistance and support zones
Estimating institutional cost basis above historical highs
📉 All-Time Low VWAP (ATL VWAP)

This VWAP is anchored from the asset's historical all-time low.

Use cases:

Analyzing long-term accumulation phases
Identifying major support areas
Evaluating long-term market cycles
🐻 Bear Market Swing VWAPs

The indicator detects significant swing highs and swing lows using a 20/20 pivot structure.

Calculated levels:

VWAP anchored to the most recent significant swing high
VWAP anchored to the most recent significant swing low

These levels are particularly useful during:

Bear markets
Market corrections
Trend reversals
Identification of institutional entry and exit zones
Customization

Each VWAP category can be enabled or disabled independently:

✅ Time-Based VWAPs (D/W/M)
✅ ATH / ATL VWAPs
✅ Bear Market Swing VWAPs

This allows traders to tailor the chart to their specific trading style and analysis needs.

Markets & Use Cases

This indicator can be applied to:

Stocks
Cryptocurrencies
Indices
Futures
Forex

It is especially valuable for traders and investors who analyze multiple time horizons and want to combine key market anchors into a single tool.

Core Concept

VWAP levels are widely used by institutional market participants as a benchmark for fair value. By combining time-based, historical, and structural anchor points, this indicator provides a broader view of market structure than a standard VWAP alone.

A comprehensive tool for analyzing trend direction, market structure, and long-term support and resistance levels within a single indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skaype

//@version=6
indicator(
     "VWAP Ultimate v6.1: Time, ATH/ATL, Swings, Pivots & Dynamic Alerts",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 100,
     max_labels_count = 100
)

//────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────
show_time = input.bool(true, "Zeit-VWAPs D/W/M", group = "01 Sichtbarkeit")
show_at   = input.bool(true, "ATH / ATL VWAPs", group = "01 Sichtbarkeit")
show_bear = input.bool(true, "Swing-VWAPs", group = "01 Sichtbarkeit")
show_piv  = input.bool(true, "Daily / Weekly / Monthly Pivots", group = "01 Sichtbarkeit")

pivotLen = input.int(20, "Swing Pivot links/rechts", minval = 1, maxval = 250, group = "02 Swing-Anker")
swingMode = input.string(
     "Pivot-Bar rechnerisch",
     "Swing-VWAP Modus",
     options = ["Confirm-Bar", "Pivot-Bar rechnerisch"],
     group = "02 Swing-Anker"
)

showExtensions = input.bool(true, "Linien nach rechts verlängern", group = "03 Linienverlängerung")
lineExtendBars = input.int(10, "Linienverlängerung in Kerzen", minval = 0, maxval = 500, group = "03 Linienverlängerung")
lineStyleInput = input.string(
     "Solide",
     "Verlängerungs-Linienstil",
     options = ["Solide", "Gestrichelt", "Gepunktet"],
     group = "03 Linienverlängerung"
)

markerMode = input.string(
     "Beschriftung",
     "Markierung an Linien",
     options = ["Aus", "Beschriftung", "Symbol", "Symbol + Beschriftung"],
     group = "04 Beschriftung / Symbol"
)

labelOffsetBars = input.int(5, "Beschriftung/Symbol in Kerzen vor aktueller Kerze", minval = 0, maxval = 500, group = "04 Beschriftung / Symbol")
markerSymbol = input.string("◆", "Symbol", group = "04 Beschriftung / Symbol")
showPriceInText = input.bool(true, "Preis in Beschriftung anzeigen", group = "04 Beschriftung / Symbol")
markerSizeInput = input.string(
     "Small",
     "Textgröße",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = "04 Beschriftung / Symbol"
)

alertsEnabled = input.bool(true, "Dynamische Alarme aktivieren", group = "05 Alarme")
alertMode = input.string(
     "Kerze berührt Linie",
     "Alarm-Auslöser",
     options = ["Kerze berührt Linie", "Close kreuzt Linie"],
     group = "05 Alarme"
)

alertFreqInput = input.string(
     "Einmal pro Kerze",
     "Alarm-Frequenz",
     options = ["Einmal pro Kerze", "Einmal pro Kerzenschluss"],
     group = "05 Alarme"
)

al_dvwap = input.bool(false, "Alarm: Daily VWAP", group = "05 Alarme")
al_wvwap = input.bool(false, "Alarm: Weekly VWAP", group = "05 Alarme")
al_mvwap = input.bool(false, "Alarm: Monthly VWAP", group = "05 Alarme")
al_ath   = input.bool(false, "Alarm: ATH VWAP", group = "05 Alarme")
al_atl   = input.bool(false, "Alarm: ATL VWAP", group = "05 Alarme")
al_sh    = input.bool(false, "Alarm: Swing High VWAP", group = "05 Alarme")
al_sl    = input.bool(false, "Alarm: Swing Low VWAP", group = "05 Alarme")
al_dpiv  = input.bool(false, "Alarm: Daily Pivot", group = "05 Alarme")
al_wpiv  = input.bool(false, "Alarm: Weekly Pivot", group = "05 Alarme")
al_mpiv  = input.bool(false, "Alarm: Monthly Pivot", group = "05 Alarme")

//────────────────────────────────────────────────────
// FARBEN
//────────────────────────────────────────────────────
c_dvwap = color.new(color.blue, 40)
c_wvwap = color.new(color.orange, 0)
c_mvwap = color.new(color.red, 0)

c_ath = color.new(color.teal, 0)
c_atl = color.new(color.maroon, 0)

c_swing_high = color.new(color.gray, 0)
c_swing_low  = color.new(color.yellow, 0)

c_dpiv = color.new(color.aqua, 0)
c_wpiv = color.new(color.fuchsia, 0)
c_mpiv = color.new(color.lime, 0)

//────────────────────────────────────────────────────
// HELFER
//────────────────────────────────────────────────────
vol = nz(volume, 0.0)
pv  = hlc3 * vol

calc_vwap(bool reset) =>
    var float sum_pv = na
    var float sum_v  = na

    bool do_reset = reset or na(sum_pv) or na(sum_v)

    sum_pv := do_reset ? pv  : sum_pv + pv
    sum_v  := do_reset ? vol : sum_v + vol

    sum_v > 0 ? sum_pv / sum_v : na

f_lineStyle(string s) =>
    switch s
        "Gestrichelt" => line.style_dashed
        "Gepunktet"  => line.style_dotted
        => line.style_solid

f_labelSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_markerText(string name, float y) =>
    string priceTxt = showPriceInText and not na(y) ? "  " + str.tostring(y, format.mintick) : ""
    string caption  = name + priceTxt

    switch markerMode
        "Beschriftung"          => caption
        "Symbol"                => markerSymbol
        "Symbol + Beschriftung" => markerSymbol + " " + caption
        => ""

f_levelHit(float level) =>
    bool crossHit = ta.cross(close, level)
    bool wickHit  = not na(level) and high >= level and low <= level

    alertMode == "Close kreuzt Linie" ? crossHit : wickHit

f_addHit(string acc, bool cond, string name, float level) =>
    cond and not na(level)
         ? acc + (str.length(acc) > 0 ? " | " : "") + name + " @ " + str.tostring(level, format.mintick)
         : acc

//────────────────────────────────────────────────────
// 1. ZEIT-VWAPS
//────────────────────────────────────────────────────
newD = timeframe.change("D")
newW = timeframe.change("W")
newM = timeframe.change("M")

vwap_d = calc_vwap(newD)
vwap_w = calc_vwap(newW)
vwap_m = calc_vwap(newM)

//────────────────────────────────────────────────────
// 2. ATH / ATL VWAPS
//────────────────────────────────────────────────────
var float ath_p = na
var float atl_p = na

bool newATH = na(ath_p) or high > ath_p
bool newATL = na(atl_p) or low < atl_p

if newATH
    ath_p := high

if newATL
    atl_p := low

vwap_ath = calc_vwap(newATH)
vwap_atl = calc_vwap(newATL)

//────────────────────────────────────────────────────
// 3. SWING-VWAPS
//────────────────────────────────────────────────────
p_bear_high = ta.pivothigh(high, pivotLen, pivotLen)
p_bear_low  = ta.pivotlow(low, pivotLen, pivotLen)

newSwingHigh = not na(p_bear_high)
newSwingLow  = not na(p_bear_low)

// Confirm-Bar-Modus: sauber no-repaint, Start auf Bestätigungskerze.
var bool swingHighConfirmActive = false
var bool swingLowConfirmActive  = false

if newSwingHigh
    swingHighConfirmActive := true

if newSwingLow
    swingLowConfirmActive := true

vwap_swing_high_confirm_raw = calc_vwap(newSwingHigh)
vwap_swing_low_confirm_raw  = calc_vwap(newSwingLow)

vwap_swing_high_confirm = swingHighConfirmActive ? vwap_swing_high_confirm_raw : na
vwap_swing_low_confirm  = swingLowConfirmActive  ? vwap_swing_low_confirm_raw  : na

// Pivot-Bar rechnerisch: ab echter Pivot-Kerze gerechnet,
// aber erst nach Pivot-Bestätigung sichtbar.
cum_pv = ta.cum(pv)
cum_v  = ta.cum(vol)

var float swingHigh_base_pv = na
var float swingHigh_base_v  = na
var float swingLow_base_pv  = na
var float swingLow_base_v   = na

var bool swingHighActive = false
var bool swingLowActive  = false

if newSwingHigh
    swingHighActive := true

    // Basis = kumulierter Wert vor der echten Pivot-Kerze.
    swingHigh_base_pv := bar_index > pivotLen ? nz(cum_pv[pivotLen + 1], 0.0) : 0.0
    swingHigh_base_v  := bar_index > pivotLen ? nz(cum_v[pivotLen + 1], 0.0)  : 0.0

if newSwingLow
    swingLowActive := true

    // Basis = kumulierter Wert vor der echten Pivot-Kerze.
    swingLow_base_pv := bar_index > pivotLen ? nz(cum_pv[pivotLen + 1], 0.0) : 0.0
    swingLow_base_v  := bar_index > pivotLen ? nz(cum_v[pivotLen + 1], 0.0)  : 0.0

swingHigh_den = swingHighActive ? cum_v - swingHigh_base_v : na
swingLow_den  = swingLowActive  ? cum_v - swingLow_base_v  : na

vwap_swing_high_pivot = swingHighActive and swingHigh_den > 0 ? (cum_pv - swingHigh_base_pv) / swingHigh_den : na
vwap_swing_low_pivot  = swingLowActive  and swingLow_den > 0  ? (cum_pv - swingLow_base_pv)  / swingLow_den  : na

vwap_swing_high = swingMode == "Confirm-Bar" ? vwap_swing_high_confirm : vwap_swing_high_pivot
vwap_swing_low  = swingMode == "Confirm-Bar" ? vwap_swing_low_confirm  : vwap_swing_low_pivot

//────────────────────────────────────────────────────
// 4. DAILY / WEEKLY / MONTHLY PIVOTS
// Klassischer Pivot Point: vorherige Periode HLC3.
//────────────────────────────────────────────────────
pivot_d = request.security(
     syminfo.tickerid,
     "D",
     (high[1] + low[1] + close[1]) / 3.0,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

pivot_w = request.security(
     syminfo.tickerid,
     "W",
     (high[1] + low[1] + close[1]) / 3.0,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

pivot_m = request.security(
     syminfo.tickerid,
     "M",
     (high[1] + low[1] + close[1]) / 3.0,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

//────────────────────────────────────────────────────
// 5. HISTORISCHE PLOTS
//────────────────────────────────────────────────────
plot(show_time ? vwap_d : na, title = "Daily VWAP", color = c_dvwap, linewidth = 1)
plot(show_time ? vwap_w : na, title = "Weekly VWAP", color = c_wvwap, linewidth = 2)
plot(show_time ? vwap_m : na, title = "Monthly VWAP", color = c_mvwap, linewidth = 2)

plot(show_at ? vwap_ath : na, title = "ATH VWAP", color = c_ath, linewidth = 3, style = plot.style_linebr)
plot(show_at ? vwap_atl : na, title = "ATL VWAP", color = c_atl, linewidth = 3, style = plot.style_linebr)

plot(show_bear ? vwap_swing_high : na, title = "Swing High VWAP", color = c_swing_high, linewidth = 2, style = plot.style_linebr)
plot(show_bear ? vwap_swing_low  : na, title = "Swing Low VWAP",  color = c_swing_low,  linewidth = 2, style = plot.style_linebr)

plot(show_piv ? pivot_d : na, title = "Daily Pivot", color = c_dpiv, linewidth = 1, style = plot.style_stepline)
plot(show_piv ? pivot_w : na, title = "Weekly Pivot", color = c_wpiv, linewidth = 2, style = plot.style_stepline)
plot(show_piv ? pivot_m : na, title = "Monthly Pivot", color = c_mpiv, linewidth = 2, style = plot.style_stepline)

//────────────────────────────────────────────────────
// 6. RECHTS-VERLÄNGERUNGEN + BESCHRIFTUNGEN / SYMBOLE
//────────────────────────────────────────────────────
var array<line>  extLines = array.new<line>()
var array<label> markers  = array.new<label>()

if barstate.isfirst
    for i = 0 to 9
        array.push(extLines, na)
        array.push(markers, na)

f_updateVisual(int idx, bool visible, float y, string name, color col, int width) =>
    line  ln = array.get(extLines, idx)
    label lb = array.get(markers, idx)

    bool valid = visible and not na(y)
    bool drawLine = showExtensions and valid
    bool drawMarker = markerMode != "Aus" and valid

    int x1 = bar_index
    int x2 = bar_index + math.max(lineExtendBars, labelOffsetBars)
    int lx = bar_index + labelOffsetBars

    if drawLine
        if na(ln)
            ln := line.new(
                 x1 = x1,
                 y1 = y,
                 x2 = x2,
                 y2 = y,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = col,
                 style = f_lineStyle(lineStyleInput),
                 width = width
            )
        else
            line.set_xy1(ln, x1, y)
            line.set_xy2(ln, x2, y)
            line.set_color(ln, col)
            line.set_style(ln, f_lineStyle(lineStyleInput))
            line.set_width(ln, width)
    else
        if not na(ln)
            line.delete(ln)
            ln := na

    if drawMarker
        string txt = f_markerText(name, y)

        if na(lb)
            lb := label.new(
                 x = lx,
                 y = y,
                 text = txt,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_none,
                 textcolor = col,
                 size = f_labelSize(markerSizeInput)
            )
        else
            label.set_x(lb, lx)
            label.set_y(lb, y)
            label.set_text(lb, txt)
            label.set_style(lb, label.style_none)
            label.set_textcolor(lb, col)
            label.set_size(lb, f_labelSize(markerSizeInput))
    else
        if not na(lb)
            label.delete(lb)
            lb := na

    array.set(extLines, idx, ln)
    array.set(markers, idx, lb)

if barstate.islast
    f_updateVisual(0, show_time, vwap_d, "D VWAP", c_dvwap, 1)
    f_updateVisual(1, show_time, vwap_w, "W VWAP", c_wvwap, 2)
    f_updateVisual(2, show_time, vwap_m, "M VWAP", c_mvwap, 2)

    f_updateVisual(3, show_at, vwap_ath, "ATH VWAP", c_ath, 3)
    f_updateVisual(4, show_at, vwap_atl, "ATL VWAP", c_atl, 3)

    f_updateVisual(5, show_bear, vwap_swing_high, "Swing High VWAP", c_swing_high, 2)
    f_updateVisual(6, show_bear, vwap_swing_low, "Swing Low VWAP", c_swing_low, 2)

    f_updateVisual(7, show_piv, pivot_d, "D Pivot", c_dpiv, 1)
    f_updateVisual(8, show_piv, pivot_w, "W Pivot", c_wpiv, 2)
    f_updateVisual(9, show_piv, pivot_m, "M Pivot", c_mpiv, 2)

//────────────────────────────────────────────────────
// 7. DYNAMISCHES ALARMSYSTEM
//────────────────────────────────────────────────────
// WICHTIG:
// f_levelHit() enthält ta.cross(). Solche Funktionen müssen auf jeder Kerze
// ausgeführt werden. Deshalb werden die Roh-Treffer zuerst ohne input-Filter
// berechnet und erst danach mit den Alarm-Schaltern kombiniert.
raw_hit_dvwap = f_levelHit(vwap_d)
raw_hit_wvwap = f_levelHit(vwap_w)
raw_hit_mvwap = f_levelHit(vwap_m)

raw_hit_ath = f_levelHit(vwap_ath)
raw_hit_atl = f_levelHit(vwap_atl)

raw_hit_sh = f_levelHit(vwap_swing_high)
raw_hit_sl = f_levelHit(vwap_swing_low)

raw_hit_dpiv = f_levelHit(pivot_d)
raw_hit_wpiv = f_levelHit(pivot_w)
raw_hit_mpiv = f_levelHit(pivot_m)

hit_dvwap = al_dvwap and raw_hit_dvwap
hit_wvwap = al_wvwap and raw_hit_wvwap
hit_mvwap = al_mvwap and raw_hit_mvwap

hit_ath = al_ath and raw_hit_ath
hit_atl = al_atl and raw_hit_atl

hit_sh = al_sh and raw_hit_sh
hit_sl = al_sl and raw_hit_sl

hit_dpiv = al_dpiv and raw_hit_dpiv
hit_wpiv = al_wpiv and raw_hit_wpiv
hit_mpiv = al_mpiv and raw_hit_mpiv

string hitList = ""
hitList := f_addHit(hitList, hit_dvwap, "Daily VWAP", vwap_d)
hitList := f_addHit(hitList, hit_wvwap, "Weekly VWAP", vwap_w)
hitList := f_addHit(hitList, hit_mvwap, "Monthly VWAP", vwap_m)

hitList := f_addHit(hitList, hit_ath, "ATH VWAP", vwap_ath)
hitList := f_addHit(hitList, hit_atl, "ATL VWAP", vwap_atl)

hitList := f_addHit(hitList, hit_sh, "Swing High VWAP", vwap_swing_high)
hitList := f_addHit(hitList, hit_sl, "Swing Low VWAP", vwap_swing_low)

hitList := f_addHit(hitList, hit_dpiv, "Daily Pivot", pivot_d)
hitList := f_addHit(hitList, hit_wpiv, "Weekly Pivot", pivot_w)
hitList := f_addHit(hitList, hit_mpiv, "Monthly Pivot", pivot_m)

anyLineAlert = alertsEnabled and str.length(hitList) > 0

alertcondition(
     anyLineAlert,
     title = "VWAP Ultimate Linienalarm",
     message = "Eine aktivierte VWAP/Pivot-Linie wurde berührt oder gekreuzt."
)

alertFreq = alertFreqInput == "Einmal pro Kerzenschluss" ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

if anyLineAlert and barstate.isrealtime
    alert(
         "VWAP Ultimate | " +
         syminfo.ticker +
         " | TF " +
         timeframe.period +
         " | " +
         alertMode +
         ": " +
         hitList +
         " | Close " +
         str.tostring(close, format.mintick),
         alertFreq
    )
````
