# Normalized FX Majors Matrix FDP (8 Currencies)

- url: https://www.tradingview.com/script/d5bUjhgo/
- type: indicator
- pine_id: PUB;a09706e01a0140f8a1bfb8566629d75f
- version: 1.0

## Description

### Overview
The **Normalized FX Majors Matrix** is a premium Currency Strength Index designed to measure the absolute performance of the 8 major global currencies (USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD). 

Instead of looking at isolated currency pairs, this indicator processes a flawless mathematically symmetrical matrix of all 28 underlying cross-rates, extracting the true geometric equally-weighted strength of each individual currency.

### How It Works
1. **Mathematical Symmetry:** The indicator requests 28 major cross-rates to build an unbiased basket. Each currency is measured accurately against 7 other counterparties.
2. **Log Returns & Smoothing:** It calculates the logarithmic returns of each pair to handle volatility scaling properly, with an optional EMA smoothing parameter to filter out short-term market noise.
3. **Base 100 Rebase:** All 8 lines are re-anchored to a value of 100 at the beginning of the user-defined lookback window (`Normalization Window`). This allows for an instant visual comparison of cumulative returns.
4. **Dynamic Leaderboard:** A real-time dashboard ranks the currencies from strongest to weakest, color-coded dynamically to match the plot lines.

### How to Trade with It
- **Trend Following (Strong vs. Weak):** Look at the ranking table. Pair the strongest currency at the top with the weakest currency at the bottom (e.g., if USD is top and JPY is bottom, look for Long opportunities on USDJPY).
- **Crossover Signals:** When a currency line crosses above another, it indicates a shifting global capital flow.
- **Breakout Confirmation:** Use this matrix to confirm if a chart breakout is supported by true individual currency strength or if it is just a false move driven by the counter-currency.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ==========================================
// Indicatore: Normalized FX Matrix FDP
// Autore:     Fausto Della Peruta
// Anno:       2026
// ==========================================
//@version=5
indicator("Normalized FX Majors Matrix (8 Currencies)", overlay=false, max_lines_count=500, max_labels_count=500)

// ==========================================
// ⚙️ INPUTS & INTERFACE
// ==========================================
gp_feed = "Data Feed Configuration"
src     = input.string("FX_IDC", "Feed Prefix", options=["FX_IDC", "OANDA", "FOREXCOM"], group=gp_feed, tooltip="Select the data provider for cross-rates. FX_IDC is recommended for global averages.")
tf      = input.string("", "Custom Timeframe", group=gp_feed, tooltip="Leave blank to dynamically match the chart's current timeframe.")

gp_calc = "Calculation Parameters"
normBars = input.int(250, "Normalization Window (Bars)", minval=50, maxval=5000, group=gp_calc, tooltip="Number of historical bars used to anchor the index baseline to 100.")
smooth   = input.int(1, "EMA Smoothing Period", minval=1, maxval=20, group=gp_calc, tooltip="Smooths log returns to filter out minor market noise. 1 means raw data.")

gp_ui   = "UI & Visual Customization"
showTable = input.bool(true, "Display Ranking Table", group=gp_ui)
tablePos  = input.string("Top Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=gp_ui)
tipEvery  = input.int(10, "Tooltip Label Frequency", minval=1, maxval=200, group=gp_ui, tooltip="Generates interactive hoverable tooltips every X bars on the chart.")
tipCap    = input.int(50, "Max Tooltips Per Currency", minval=10, maxval=200, group=gp_ui)

// ==========================================
// 📐 HELPERS & SECURITY REQUESTS
// ==========================================
t_pos = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Top Left" ? position.top_left : position.bottom_left

sym(p) => src + ":" + p
req(s) => request.security(s, tf == "" ? timeframe.period : tf, close, barmerge.gaps_off, barmerge.lookahead_off)
logret(x) => math.log(x) - math.log(x[1])
emaR(x) => smooth > 1 ? ta.ema(logret(x), smooth) : logret(x)

rebase100(cum) =>
    _base = bar_index >= normBars ? cum[normBars] : cum
    100 * math.exp(cum - _base)

// Fetching all 28 pairs to complete a flawless 8x8 matrix
EURUSD = req(sym("EURUSD")), GBPUSD = req(sym("GBPUSD")), AUDUSD = req(sym("AUDUSD")), NZDUSD = req(sym("NZDUSD"))
USDJPY = req(sym("USDJPY")), USDCHF = req(sym("USDCHF")), USDCAD = req(sym("USDCAD")), EURGBP = req(sym("EURGBP"))
EURJPY = req(sym("EURJPY")), EURCHF = req(sym("EURCHF")), EURCAD = req(sym("EURCAD")), EURAUD = req(sym("EURAUD"))
EURNZD = req(sym("EURNZD")), GBPJPY = req(sym("GBPJPY")), GBPCHF = req(sym("GBPCHF")), GBPCAD = req(sym("GBPCAD"))
GBPAUD = req(sym("GBPAUD")), GBPNZD = req(sym("GBPNZD")), AUDJPY = req(sym("AUDJPY")), AUDCHF = req(sym("AUDCHF"))
AUDCAD = req(sym("AUDCAD")), AUDNZD = req(sym("AUDNZD")), NZDJPY = req(sym("NZDJPY")), NZDCHF = req(sym("NZDCHF"))
NZDCAD = req(sym("NZDCAD")), CADJPY = req(sym("CADJPY")), CHFJPY = req(sym("CHFJPY")), CADCHF = req(sym("CADCHF"))

// ==========================================
// 📊 EQUALLY WEIGHTED LOG RETURNS
// ==========================================
r_EUR = (emaR(EURUSD) + emaR(EURGBP) + emaR(EURJPY) + emaR(EURCHF) + emaR(EURCAD) + emaR(EURAUD) + emaR(EURNZD)) / 7
r_GBP = (-emaR(EURGBP) + emaR(GBPUSD) + emaR(GBPJPY) + emaR(GBPCHF) + emaR(GBPCAD) + emaR(GBPAUD) + emaR(GBPNZD)) / 7
r_AUD = (-emaR(EURAUD) - emaR(GBPAUD) + emaR(AUDUSD) + emaR(AUDJPY) + emaR(AUDCHF) + emaR(AUDCAD) + emaR(AUDNZD)) / 7
r_NZD = (-emaR(EURNZD) - emaR(GBPNZD) - emaR(AUDNZD) + emaR(NZDUSD) + emaR(NZDJPY) + emaR(NZDCHF) + emaR(NZDCAD)) / 7
r_USD = (-emaR(EURUSD) - emaR(GBPUSD) - emaR(AUDUSD) - emaR(NZDUSD) + emaR(USDJPY) + emaR(USDCHF) + emaR(USDCAD)) / 7
r_JPY = (-emaR(USDJPY) - emaR(EURJPY) - emaR(GBPJPY) - emaR(AUDJPY) - emaR(NZDJPY) - emaR(CADJPY) - emaR(CHFJPY)) / 7
r_CHF = (-emaR(USDCHF) - emaR(EURCHF) - emaR(GBPCHF) - emaR(AUDCHF) - emaR(NZDCHF) - emaR(CADCHF) + emaR(CHFJPY)) / 7
r_CAD = (-emaR(USDCAD) - emaR(EURCAD) - emaR(GBPCAD) - emaR(AUDCAD) - emaR(NZDCAD) + emaR(CADJPY) + emaR(CADCHF)) / 7

// Cumulative Index Normalization (Base 100)
cum_EUR = rebase100(ta.cum(r_EUR)), cum_GBP = rebase100(ta.cum(r_GBP))
cum_AUD = rebase100(ta.cum(r_AUD)), cum_NZD = rebase100(ta.cum(r_NZD))
cum_USD = rebase100(ta.cum(r_USD)), cum_JPY = rebase100(ta.cum(r_JPY))
cum_CHF = rebase100(ta.cum(r_CHF)), cum_CAD = rebase100(ta.cum(r_CAD))

// ==========================================
// 🎨 VISUAL OUTPUTS & PLOTS
// ==========================================
cEUR = #1f77b4, cGBP = #e377c2, cUSD = #2ca02c, cJPY = #ff7f0e
cCHF = #7f7f7f, cCAD = #d62728, cAUD = #17becf, cNZD = #9467bd

hline(100, "Baseline 100", color=color.new(color.gray, 60), linestyle=hline.style_dashed)

plot(cum_EUR, title="EUR", color=cEUR, linewidth=2)
plot(cum_GBP, title="GBP", color=cGBP, linewidth=2)
plot(cum_USD, title="USD", color=cUSD, linewidth=2)
plot(cum_JPY, title="JPY", color=cJPY, linewidth=2)
plot(cum_CHF, title="CHF", color=cCHF, linewidth=2)
plot(cum_CAD, title="CAD", color=cCAD, linewidth=2)
plot(cum_AUD, title="AUD", color=cAUD, linewidth=2)
plot(cum_NZD, title="NZD", color=cNZD, linewidth=2)

// ==========================================
// 💬 INTERACTIVE TOOLTIPS
// ==========================================
var arr_EUR = array.new_label(), var arr_GBP = array.new_label()
var arr_USD = array.new_label(), var arr_JPY = array.new_label()
var arr_CHF = array.new_label(), var arr_CAD = array.new_label()
var arr_AUD = array.new_label(), var arr_NZD = array.new_label()

f_tip(arr, y, name, col) =>
    if bar_index % tipEvery == 0
        tt = name + ": " + str.tostring(y, "0.00")
        lbl = label.new(x=bar_index, y=y, text="", xloc=xloc.bar_index, yloc=yloc.price,
              style=label.style_circle, color=color.new(col, 85), textcolor=color.white,
              size=size.tiny, tooltip=tt)
        array.push(arr, lbl)
        if array.size(arr) > tipCap
            old = array.shift(arr)
            label.delete(old)

f_tip(arr_EUR, cum_EUR, "EUR", cEUR), f_tip(arr_GBP, cum_GBP, "GBP", cGBP)
f_tip(arr_USD, cum_USD, "USD", cUSD), f_tip(arr_JPY, cum_JPY, "JPY", cJPY)
f_tip(arr_CHF, cum_CHF, "CHF", cCHF), f_tip(arr_CAD, cum_CAD, "CAD", cCAD)
f_tip(arr_AUD, cum_AUD, "AUD", cAUD), f_tip(arr_NZD, cum_NZD, "NZD", cNZD)

// ==========================================
// 📊 REAL-TIME RANKING TABLE
// ==========================================
var table t = table.new(t_pos, 2, 9, bgcolor=color.new(#1e222d, 15), border_color=color.new(color.gray, 80), border_width=1)
if barstate.islast and showTable
    table.clear(t, 0, 0, 1, 8)
    table.cell(t, 0, 0, "Currency", bgcolor=#2a2e39, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, "Index", bgcolor=#2a2e39, text_color=color.white, text_size=size.small)
    
    vals = array.new_string()
    nums = array.new_float()
    cols = array.new_color()
    
    array.push(vals, "EUR"), array.push(nums, cum_EUR), array.push(cols, cEUR)
    array.push(vals, "GBP"), array.push(nums, cum_GBP), array.push(cols, cGBP)
    array.push(vals, "USD"), array.push(nums, cum_USD), array.push(cols, cUSD)
    array.push(vals, "JPY"), array.push(nums, cum_JPY), array.push(cols, cJPY)
    array.push(vals, "CHF"), array.push(nums, cum_CHF), array.push(cols, cCHF)
    array.push(vals, "CAD"), array.push(nums, cum_CAD), array.push(cols, cCAD)
    array.push(vals, "AUD"), array.push(nums, cum_AUD), array.push(cols, cAUD)
    array.push(vals, "NZD"), array.push(nums, cum_NZD), array.push(cols, cNZD)
    
    // Bubble Sort
    for i = 0 to array.size(nums) - 2
        for j = i + 1 to array.size(nums) - 1
            if array.get(nums, j) > array.get(nums, i)
                tmpN = array.get(nums, i), tmpS = array.get(vals, i), tmpC = array.get(cols, i)
                array.set(nums, i, array.get(nums, j)), array.set(vals, i, array.get(vals, j)), array.set(cols, i, array.get(cols, j))
                array.set(nums, j, tmpN), array.set(vals, j, tmpS), array.set(cols, j, tmpC)
                
    // Render dynamic rows with matching line colors
    for rI = 0 to array.size(vals) - 1
        color rowBg = rI % 2 == 0 ? color.new(#131722, 10) : color.new(#1e222d, 10)
        table.cell(t, 0, rI + 1, array.get(vals, rI), bgcolor=rowBg, text_color=array.get(cols, rI), text_size=size.small, text_font_family=font.family_monospace)
        table.cell(t, 1, rI + 1, str.tostring(array.get(nums, rI), "0.00"), bgcolor=rowBg, text_color=color.white, text_size=size.small, text_font_family=font.family_monospace)
````
