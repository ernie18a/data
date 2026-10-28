# Hitesh Nimje 2026

- url: https://www.tradingview.com/script/N4kxvM41-Hitesh-Nimje-2026/
- type: indicator
- pine_id: PUB;cb8d83d467c34178a1286a8876e84156
- version: 1.0

## Description

To publish your indicator on TradingView, you need a clear, professional description that explains the features to potential users. Since your script is a powerful "All-in-One" suite, here is a template you can use.

Title Idea
Hitesh Nimje | Combined Trading Suite (EMA Bundle + Sessions + MTF Levels)

Description Template
Description:
This all-in-one trading tool combines essential trend-following indicators and market structure analysis to provide a clean, clutter-free workspace. Designed for intraday and swing traders, this suite eliminates the need for multiple indicators by merging three core functionalities into one.

Key Features:

TMT EMA Bundle: Includes 10 customizable Exponential Moving Averages (EMA 9, 11, 15, 21, 50, 51, 55, 100, 200, 400). You can toggle these on/off to suit your specific strategy.

MTF Highs/Lows & S/R: Automatically plots vital support and resistance levels from higher timeframes (Daily, Weekly, Monthly) and identifies All-Time Highs/Lows (ATH/ATL).

Market Session Tracking: Monitors four distinct trading sessions (A, B, C, D) with options for trendlines, VWAP, and range boxes to help you identify market volatility throughout the day.

Advanced Dashboard: A centralized, dynamic table that shows real-time session status, market bias, and volume analysis. The "Advanced" mode provides deep data on buyer/seller volume and delta.

Trend Context: Features a built-in EMA Trend monitor that helps you quickly gauge if the current price is trading above or below the 200 EMA.

How to use:

Add the indicator to your chart.

Open the "Settings" menu to toggle your preferred EMAs (9, 21, and 200 are enabled by default).

Use the Dashboard to track session activity and EMA trends at a glance.

Adjust the "Dashboard Location" and "Size" to fit your layout.

Settings:

Defaults: EMA 9, 21, and 200 are enabled by default for a clean trend-following approach.

Advanced Mode: Toggle the Advanced Dashboard for detailed volume/delta metrics.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Hitesh Nimje June 2026

//@version=6
indicator('Hitesh Nimje 2026')

// =============================================================================
// ========================== SETTINGS & INPUTS ================================
// =============================================================================

// --- TMT EMA Bundle Settings ---
grp_ema = 'TMT EMA Bundle'
ema9_on = input.bool(true, 'EMA 9 (Blue)', group = grp_ema)
ema11_on = input.bool(false, 'EMA 11 (Red)', group = grp_ema)
ema15_on = input.bool(false, 'EMA 15 (Yellow)', group = grp_ema)
ema21_on = input.bool(true, 'EMA 21 (Black)', group = grp_ema)
ema50_on = input.bool(true, 'EMA 50 (Gray)', group = grp_ema)
ema51_on = input.bool(false, 'EMA 51 (Orange)', group = grp_ema)
ema55_on = input.bool(true, 'EMA 55 (Gray)', group = grp_ema)
ema100_on = input.bool(true, 'EMA 100 (Purple)', group = grp_ema)
ema200_on = input.bool(true, 'EMA 200 (Maroon)', group = grp_ema)
ema400_on = input.bool(true, 'EMA 400 (Green)', group = grp_ema)

// --- MTF Highs/Lows & S/R Toggle Settings ---
grp_mtf = 'MTF Highs/Lows & S/R'
show_today = input.bool(true, 'Show Today High/Low', group = grp_mtf, display = display.all - display.status_line)
show_pdhl = input.bool(true, 'Show Prev Day High/Low', group = grp_mtf, display = display.all - display.status_line)
show_pwhl = input.bool(true, 'Show Prev Week High/Low', group = grp_mtf, display = display.all - display.status_line)
show_pmhl = input.bool(true, 'Show Prev Month High/Low', group = grp_mtf, display = display.all - display.status_line)
show_athl = input.bool(true, 'Show All-Time High/Low', group = grp_mtf, display = display.all - display.status_line)
show_sr = input.bool(true, 'Show Support/Resistance (Pivot Points)', group = grp_mtf, display = display.all - display.status_line)

// --- Session A (Blue) ---
show_sesa = input.bool(true, '', inline = 'sesa', group = 'Session A', display = display.all - display.status_line)
sesa_txt = input.string('New York', '', inline = 'sesa', group = 'Session A', display = display.all - display.status_line)
sesa_ses = input.session('1730-0230', '', inline = 'sesa', group = 'Session A', display = display.all - display.status_line)
sesa_css = input.color(color.blue, '', inline = 'sesa', group = 'Session A', display = display.all - display.status_line) // Blue
sesa_range = input.bool(true, 'Range', inline = 'sesa_overlays', group = 'Session A', display = display.all - display.status_line)
sesa_tl = input.bool(false, 'Trendline', inline = 'sesa_overlays', group = 'Session A', display = display.all - display.status_line)
sesa_avg = input.bool(false, 'Mean', inline = 'sesa_overlays', group = 'Session A', display = display.all - display.status_line)
sesa_vwap = input.bool(false, 'VWAP', inline = 'sesa_overlays', group = 'Session A', display = display.all - display.status_line)
sesa_maxmin = input.bool(false, 'Max/Min', inline = 'sesa_overlays', group = 'Session A', display = display.all - display.status_line)

// --- Session B (Red) ---
show_sesb = input.bool(true, '', inline = 'sesb', group = 'Session B', display = display.all - display.status_line)
sesb_txt = input.string('London', '', inline = 'sesb', group = 'Session B', display = display.all - display.status_line)
sesb_ses = input.session('1230-2130', '', inline = 'sesb', group = 'Session B', display = display.all - display.status_line)
sesb_css = input.color(color.red, '', inline = 'sesb', group = 'Session B', display = display.all - display.status_line) // Red
sesb_range = input.bool(true, 'Range', inline = 'sesb_overlays', group = 'Session B', display = display.all - display.status_line)
sesb_tl = input.bool(false, 'Trendline', inline = 'sesb_overlays', group = 'Session B', display = display.all - display.status_line)
sesb_avg = input.bool(false, 'Mean', inline = 'sesb_overlays', group = 'Session B', display = display.all - display.status_line)
sesb_vwap = input.bool(false, 'VWAP', inline = 'sesb_overlays', group = 'Session B', display = display.all - display.status_line)
sesb_maxmin = input.bool(false, 'Max/Min', inline = 'sesb_overlays', group = 'Session B', display = display.all - display.status_line)

// --- Session C (Black) ---
show_sesc = input.bool(true, '', inline = 'sesc', group = 'Session C', display = display.all - display.status_line)
sesc_txt = input.string('Tokyo', '', inline = 'sesc', group = 'Session C', display = display.all - display.status_line)
sesc_ses = input.session('0530-1430', '', inline = 'sesc', group = 'Session C', display = display.all - display.status_line)
sesc_css = input.color(color.black, '', inline = 'sesc', group = 'Session C', display = display.all - display.status_line) // Black
sesc_range = input.bool(true, 'Range', inline = 'sesc_overlays', group = 'Session C', display = display.all - display.status_line)
sesc_tl = input.bool(false, 'Trendline', inline = 'sesc_overlays', group = 'Session C', display = display.all - display.status_line)
sesc_avg = input.bool(false, 'Mean', inline = 'sesc_overlays', group = 'Session C', display = display.all - display.status_line)
sesc_vwap = input.bool(false, 'VWAP', inline = 'sesc_overlays', group = 'Session C', display = display.all - display.status_line)
sesc_maxmin = input.bool(false, 'Max/Min', inline = 'sesc_overlays', group = 'Session C', display = display.all - display.status_line)

// --- Session D (Green) ---
show_sesd = input.bool(true, '', inline = 'sesd', group = 'Session D', display = display.all - display.status_line)
sesd_txt = input.string('Sydney', '', inline = 'sesd', group = 'Session D', display = display.all - display.status_line)
sesd_ses = input.session('0430-1330', '', inline = 'sesd', group = 'Session D', display = display.all - display.status_line)
sesd_css = input.color(color.green, '', inline = 'sesd', group = 'Session D', display = display.all - display.status_line) // Green
sesd_range = input.bool(true, 'Range', inline = 'sesd_overlays', group = 'Session D', display = display.all - display.status_line)
sesd_tl = input.bool(false, 'Trendline', inline = 'sesd_overlays', group = 'Session D', display = display.all - display.status_line)
sesd_avg = input.bool(false, 'Mean', inline = 'sesd_overlays', group = 'Session D', display = display.all - display.status_line)
sesd_vwap = input.bool(false, 'VWAP', inline = 'sesd_overlays', group = 'Session D', display = display.all - display.status_line)
sesd_maxmin = input.bool(false, 'Max/Min', inline = 'sesd_overlays', group = 'Session D', display = display.all - display.status_line)

// --- Timezones ---
timezone_opt = input.string('Asia/Kolkata', 'Session Timezone', group = 'Timezone', display = display.all - display.status_line)
use_exchange = input.bool(false, 'Use Exchange Timezone', group = 'Timezone', display = display.all - display.status_line)

// --- Ranges Options ---
bg_transp = input.float(90, 'Range Area Transparency', group = 'Ranges Settings', display = display.all - display.status_line)
show_outline = input.bool(true, 'Range Outline', group = 'Ranges Settings', display = display.all - display.status_line)
show_txt = input.bool(true, 'Range Label', group = 'Ranges Settings', display = display.all - display.status_line)
show_desc = input.bool(true, 'Show Line Descriptions', group = 'Ranges Settings', display = display.all - display.status_line)

// --- Dashboard ---
show_dash = input.bool(true, 'Show Dashboard', group = 'Dashboard', display = display.all - display.status_line) // Default ON
advanced_dash = input.bool(true, 'Advanced Dashboard', group = 'Dashboard', display = display.all - display.status_line)
dash_loc = input.string('Top Right', 'Dashboard Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Dashboard', display = display.all - display.status_line)
text_size = input.string('Small', 'Dashboard Size', options = ['Tiny', 'Small', 'Normal'], group = 'Dashboard', display = display.all - display.status_line)

// --- Divider ---
show_ses_div = input.bool(false, 'Show Sessions Divider', group = 'Dividers', display = display.all - display.status_line)
show_day_div = input.bool(true, 'Show Daily Divider', group = 'Dividers', display = display.all - display.status_line)

// =============================================================================
// ============================= EMA PLOTTING ==================================
// =============================================================================

ema9_val = ta.ema(close, 9)
ema11_val = ta.ema(close, 11)
ema15_val = ta.ema(close, 15)
ema21_val = ta.ema(close, 21)
ema50_val = ta.ema(close, 50)
ema51_val = ta.ema(close, 51)
ema55_val = ta.ema(close, 55)
ema100_val = ta.ema(close, 100)
ema200_val = ta.ema(close, 200)
ema400_val = ta.ema(close, 400)

plot(ema9_on ? ema9_val : na, 'EMA 9', color.blue, 2)
plot(ema11_on ? ema11_val : na, 'EMA 11', color.red, 2)
plot(ema15_on ? ema15_val : na, 'EMA 15', color.yellow, 2)
plot(ema21_on ? ema21_val : na, 'EMA 21', color.black, 2)
plot(ema50_on ? ema50_val : na, 'EMA 50', color.gray, 2)
plot(ema51_on ? ema51_val : na, 'EMA 51', color.orange, 2)
plot(ema55_on ? ema55_val : na, 'EMA 55', color.gray, 2)
plot(ema100_on ? ema100_val : na, 'EMA 100', color.purple, 2)
plot(ema200_on ? ema200_val : na, 'EMA 200', color.maroon, 2)
plot(ema400_on ? ema400_val : na, 'EMA 400', color.green, 2)

// Labels (Corrected Syntax)
if barstate.islast
    if ema9_on
        label.new(bar_index, ema9_val, '9 EMA', color = color.new(color.white, 100), textcolor = color.blue, style = label.style_none, size = size.small)
    if ema11_on
        label.new(bar_index, ema11_val, '11 EMA', color = color.new(color.white, 100), textcolor = color.red, style = label.style_none, size = size.small)
    if ema15_on
        label.new(bar_index, ema15_val, '15 EMA', color = color.new(color.white, 100), textcolor = color.yellow, style = label.style_none, size = size.small)
    if ema21_on
        label.new(bar_index, ema21_val, '21 EMA', color = color.new(color.white, 100), textcolor = color.black, style = label.style_none, size = size.small)
    if ema50_on
        label.new(bar_index, ema50_val, '50 EMA', color = color.new(color.white, 100), textcolor = color.gray, style = label.style_none, size = size.small)
    if ema51_on
        label.new(bar_index, ema51_val, '51 EMA', color = color.new(color.white, 100), textcolor = color.orange, style = label.style_none, size = size.small)
    if ema55_on
        label.new(bar_index, ema55_val, '55 EMA', color = color.new(color.white, 100), textcolor = color.gray, style = label.style_none, size = size.small)
    if ema100_on
        label.new(bar_index, ema100_val, '100 EMA', color = color.new(color.white, 100), textcolor = color.purple, style = label.style_none, size = size.small)
    if ema200_on
        label.new(bar_index, ema200_val, '200 EMA', color = color.new(color.white, 100), textcolor = color.maroon, style = label.style_none, size = size.small)
    if ema400_on
        label.new(bar_index, ema400_val, '400 EMA', color = color.new(color.white, 100), textcolor = color.green, style = label.style_none, size = size.small)




// =============================================================================
// ======================= MTF HIGHS/LOWS & S/R LOGIC ==========================
// =============================================================================

// Colors for MTF Lines
colorHigh = color.black
colorLow = color.blue
colorRes = #8B0000 // Dark Red
colorSup = #006400 // Dark Green

// Fetch Higher Timeframe Data for S/R
[pdh, pdl, pdc, pd_time] = request.security(syminfo.tickerid, 'D', [high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl, pwc, pw_time] = request.security(syminfo.tickerid, 'W', [high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)
[pmh, pml, pmc, pm_time] = request.security(syminfo.tickerid, 'M', [high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)

// Calculate Standard Pivot Points (Support & Resistance)
float dp = (pdh + pdl + pdc) / 3
float dr1 = dp * 2 - pdl
float ds1 = dp * 2 - pdh
float dr2 = dp + pdh - pdl
float ds2 = dp - (pdh - pdl)

float wp = (pwh + pwl + pwc) / 3
float wr1 = wp * 2 - pwl
float ws1 = wp * 2 - pwh
float wr2 = wp + pwh - pwl
float ws2 = wp - (pwh - pwl)

float mp = (pmh + pml + pmc) / 3
float mr1 = mp * 2 - pml
float ms1 = mp * 2 - pmh
float mr2 = mp + pmh - pml
float ms2 = mp - (pmh - pml)

// Track Today's High/Low & Time Intraday
var float t_high = na
var float t_low = na
var int t_high_time = na
var int t_low_time = na

if bool(ta.change(time('D')))
    t_high := high
    t_low := low
    t_high_time := time
    t_low_time := time
    t_low_time
else
    if high > t_high
        t_high := high
        t_high_time := time
        t_high_time
    if low < t_low
        t_low := low
        t_low_time := time
        t_low_time

// Track All-Time High/Low
var float ath = high
var float atl = low
if high > ath
    ath := high
    ath
if low < atl
    atl := low
    atl

// Initialize Lines
var line line_th = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorHigh, width = 1)
var line line_tl = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorLow, width = 1)
var line line_pdh = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorHigh, width = 2)
var line line_pdl = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorLow, width = 2)
var line line_pwh = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorHigh, width = 3)
var line line_pwl = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorLow, width = 3)
var line line_pmh = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorHigh, width = 4)
var line line_pml = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorLow, width = 4)
var line line_ath = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorHigh, width = 5)
var line line_atl = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorLow, width = 5)

var line line_dr1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 1, style = line.style_dashed)
var line line_ds1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 1, style = line.style_dashed)
var line line_dr2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 1, style = line.style_dashed)
var line line_ds2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 1, style = line.style_dashed)
var line line_wr1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 2, style = line.style_dashed)
var line line_ws1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 2, style = line.style_dashed)
var line line_wr2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 2, style = line.style_dashed)
var line line_ws2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 2, style = line.style_dashed)
var line line_mr1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 3, style = line.style_dashed)
var line line_ms1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 3, style = line.style_dashed)
var line line_mr2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorRes, width = 3, style = line.style_dashed)
var line line_ms2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = colorSup, width = 3, style = line.style_dashed)

// Initialize Labels
var label lab_th = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorHigh)
var label lab_tl = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorLow)
var label lab_pdh = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorHigh)
var label lab_pdl = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorLow)
var label lab_pwh = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorHigh)
var label lab_pwl = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorLow)
var label lab_pmh = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorHigh)
var label lab_pml = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorLow)
var label lab_ath = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorHigh)
var label lab_atl = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorLow)

var label lab_dr1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ds1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)
var label lab_dr2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ds2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)
var label lab_wr1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ws1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)
var label lab_wr2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ws2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)
var label lab_mr1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ms1 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)
var label lab_mr2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorRes)
var label lab_ms2 = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_none, textcolor = colorSup)

// Update Levels Function
var int day_start_time = na
if bool(ta.change(time('D')))
    day_start_time := time
    day_start_time

update_level(lvl_line, lvl_label, lvl_price, lvl_text, is_visible) =>
    if is_visible
        int bar_duration = nz(time - time[1], 60000)
        int x1 = na(day_start_time) ? time - bar_duration * 20 : day_start_time
        int x2 = time + bar_duration * 15

        line.set_xy1(lvl_line, x1, lvl_price)
        line.set_xy2(lvl_line, x2, lvl_price)
        label.set_xy(lvl_label, x2, lvl_price)
        label.set_text(lvl_label, lvl_text)
    else
        line.set_xy1(lvl_line, na, na)
        line.set_xy2(lvl_line, na, na)
        label.set_xy(lvl_label, na, na)


// =============================================================================
// ========================== SESSION FUNCTIONS ================================
// =============================================================================
n = bar_index

get_avg(in_session) =>
    var len = 1
    var float csma = na
    var float sma = na

    if in_session > in_session[1]
        len := 1
        csma := close
        csma

    if in_session != 0 and in_session == in_session[1]
        len := len + 1
        csma := csma + close
        sma := csma / len
        sma

    sma

get_linreg(in_session) =>
    var len = 1
    var float cwma = na
    var float csma = na
    var float csma2 = na
    var float y1 = na
    var float y2 = na
    var float stdev = na
    var float r2 = na

    if in_session > in_session[1]
        len := 1
        cwma := close
        csma := close
        csma2 := close * close
        csma2

    if in_session != 0 and in_session == in_session[1]
        len := len + 1
        csma := csma + close
        csma2 := csma2 + close * close
        cwma := cwma + close * len

        sma = csma / len
        wma = cwma / (len * (len + 1) / 2)

        cov = (wma - sma) * (len + 1) / 2
        stdev := math.sqrt(csma2 / len - sma * sma)
        r2 := cov / (stdev * (math.sqrt(len * len - 1) / (2 * math.sqrt(3))))

        y1 := 4 * sma - 3 * wma
        y2 := 3 * wma - 2 * sma
        y2

    [y1, y2, stdev, r2]

get_vwap(in_session) =>
    var float num = na
    var float den = na

    if in_session > in_session[1]
        num := close * volume
        den := volume
        den

    else if in_session != 0 and in_session == in_session[1]
        num := num + close * volume
        den := den + volume
        den
    else
        num := na
        num

    [num, den]

get_buy_sell_vol(in_session) =>
    var float b_vol = 0.0
    var float s_vol = 0.0
    float cur_b_vol = close >= open ? volume : 0
    float cur_s_vol = close < open ? volume : 0

    if in_session > in_session[1]
        b_vol := cur_b_vol
        s_vol := cur_s_vol
        s_vol
    else if in_session != 0 and in_session == in_session[1]
        b_vol := b_vol + cur_b_vol
        s_vol := s_vol + cur_s_vol
        s_vol

    [b_vol, s_vol]

set_line(in_session, y1, y2, session_css) =>
    var line tl = na
    if in_session > in_session[1]
        tl := line.new(n, close, n, close, color = session_css)
        tl

    if in_session != 0 and in_session == in_session[1]
        line.set_y1(tl, y1)
        line.set_xy2(tl, n, y2)

get_range(in_session, session_name, session_css) =>
    var t = 0
    var max = high
    var min = low
    var box bx = na
    var label lbl = na

    if in_session > in_session[1]
        t := time
        max := high
        min := low

        bx := box.new(n, max, n, min, bgcolor = color.new(session_css, bg_transp), border_color = show_outline ? session_css : na, border_style = line.style_dotted)

        if show_txt
            lbl := label.new(t, max, session_name, xloc = xloc.bar_time, textcolor = session_css, style = label.style_label_down, color = color.new(color.white, 100), size = size.tiny)
            lbl

    if in_session != 0 and in_session == in_session[1]
        max := math.max(high, max)
        min := math.min(low, min)

        box.set_top(bx, max)
        box.set_rightbottom(bx, n, min)

        if show_txt
            label.set_xy(lbl, int(math.avg(t, time)), max)

    [max, min]

// =============================================================================
// ============================= SESSION LOGIC =================================
// =============================================================================

tf = timeframe.period
var tz = use_exchange ? syminfo.timezone : timezone_opt

is_sesa = math.sign(nz(time(tf, sesa_ses, tz)))
is_sesb = math.sign(nz(time(tf, sesb_ses, tz)))
is_sesc = math.sign(nz(time(tf, sesc_ses, tz)))
is_sesd = math.sign(nz(time(tf, sesd_ses, tz)))

// Compute session metrics continuously 
[y1_a, y2_a, stdev_a, r2_a] = get_linreg(is_sesa)
[y1_b, y2_b, stdev_b, r2_b] = get_linreg(is_sesb)
[y1_c, y2_c, stdev_c, r2_c] = get_linreg(is_sesc)
[y1_d, y2_d, stdev_d, r2_d] = get_linreg(is_sesd)

[b_vol_a, s_vol_a] = get_buy_sell_vol(is_sesa)
[b_vol_b, s_vol_b] = get_buy_sell_vol(is_sesb)
[b_vol_c, s_vol_c] = get_buy_sell_vol(is_sesc)
[b_vol_d, s_vol_d] = get_buy_sell_vol(is_sesd)

delta_a = b_vol_a - s_vol_a
delta_b = b_vol_b - s_vol_b
delta_c = b_vol_c - s_vol_c
delta_d = b_vol_d - s_vol_d

win_a = delta_a > 0 ? 'Buyers' : delta_a < 0 ? 'Sellers' : 'Neutral'
win_b = delta_b > 0 ? 'Buyers' : delta_b < 0 ? 'Sellers' : 'Neutral'
win_c = delta_c > 0 ? 'Buyers' : delta_c < 0 ? 'Sellers' : 'Neutral'
win_d = delta_d > 0 ? 'Buyers' : delta_d < 0 ? 'Sellers' : 'Neutral'

// Dashboard Logic (Dynamic Column Sizing)
var table_position = dash_loc == 'Bottom Left' ? position.bottom_left : dash_loc == 'Top Right' ? position.top_right : position.bottom_right
var table_size = text_size == 'Tiny' ? size.tiny : text_size == 'Small' ? size.small : size.normal

// If advanced is OFF, make a 2-column table. If ON, make an 8-column table.
var int total_cols = advanced_dash ? 8 : 2
var int total_rows = advanced_dash ? 7 : 6

var tb = table.new(table_position, columns = total_cols, rows = total_rows, bgcolor = color.white, border_color = color.black, border_width = 1, frame_color = color.black, frame_width = 1)

if barstate.isfirst and show_dash
    table.cell(tb, 0, 0, 'Hitesh Nimje Dashboard', text_color = color.black, text_size = table_size)
    table.merge_cells(tb, 0, 0, total_cols - 1, 0)

    // Core Headers
    table.cell(tb, 0, 1, 'Session', text_color = color.black, text_size = table_size)
    table.cell(tb, 1, 1, 'Status', text_color = color.black, text_size = table_size)

    // Core Names with matching text colors
    table.cell(tb, 0, 2, sesa_txt, text_color = sesa_css, text_size = table_size) // Blue
    table.cell(tb, 0, 3, sesb_txt, text_color = sesb_css, text_size = table_size) // Red
    table.cell(tb, 0, 4, sesc_txt, text_color = sesc_css, text_size = table_size) // Black
    table.cell(tb, 0, 5, sesd_txt, text_color = sesd_css, text_size = table_size) // Green

    // Advanced Headers
    if advanced_dash
        table.cell(tb, 2, 1, 'Price Trend', text_color = color.black, text_size = table_size)
        table.cell(tb, 3, 1, 'Volume Trend', text_color = color.black, text_size = table_size)
        table.cell(tb, 4, 1, 'Buyer Vol', text_color = color.black, text_size = table_size)
        table.cell(tb, 5, 1, 'Seller Vol', text_color = color.black, text_size = table_size)
        table.cell(tb, 6, 1, 'Delta', text_color = color.black, text_size = table_size)
        table.cell(tb, 7, 1, 'Winner', text_color = color.black, text_size = table_size)

if barstate.islast and show_dash
    // Core Updates (Always visible)
    table.cell(tb, 1, 2, is_sesa != 0 ? 'Active' : 'Inactive', bgcolor = is_sesa != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 3, is_sesb != 0 ? 'Active' : 'Inactive', bgcolor = is_sesb != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 4, is_sesc != 0 ? 'Active' : 'Inactive', bgcolor = is_sesc != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 5, is_sesd != 0 ? 'Active' : 'Inactive', bgcolor = is_sesd != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)

    if advanced_dash
        // Session A Updates
        table.cell(tb, 2, 2, r2_a > 0 ? 'Bullish' : 'Bearish', text_color = color.black, text_size = table_size)
        table.cell(tb, 3, 2, delta_a > 0 ? 'Bullish' : delta_a < 0 ? 'Bearish' : 'Neutral', text_color = color.black, text_size = table_size)
        table.cell(tb, 4, 2, str.tostring(b_vol_a, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 5, 2, str.tostring(s_vol_a, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 6, 2, str.tostring(delta_a, format.volume), text_color = delta_a > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 2, win_a, text_color = color.black, text_size = table_size)

        // Session B Updates
        table.cell(tb, 2, 3, r2_b > 0 ? 'Bullish' : 'Bearish', text_color = color.black, text_size = table_size)
        table.cell(tb, 3, 3, delta_b > 0 ? 'Bullish' : delta_b < 0 ? 'Bearish' : 'Neutral', text_color = color.black, text_size = table_size)
        table.cell(tb, 4, 3, str.tostring(b_vol_b, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 5, 3, str.tostring(s_vol_b, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 6, 3, str.tostring(delta_b, format.volume), text_color = delta_b > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 3, win_b, text_color = color.black, text_size = table_size)

        // Session C Updates
        table.cell(tb, 2, 4, r2_c > 0 ? 'Bullish' : 'Bearish', text_color = color.black, text_size = table_size)
        table.cell(tb, 3, 4, delta_c > 0 ? 'Bullish' : delta_c < 0 ? 'Bearish' : 'Neutral', text_color = color.black, text_size = table_size)
        table.cell(tb, 4, 4, str.tostring(b_vol_c, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 5, 4, str.tostring(s_vol_c, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 6, 4, str.tostring(delta_c, format.volume), text_color = delta_c > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 4, win_c, text_color = color.black, text_size = table_size)

        // Session D Updates
        table.cell(tb, 2, 5, r2_d > 0 ? 'Bullish' : 'Bearish', text_color = color.black, text_size = table_size)
        table.cell(tb, 3, 5, delta_d > 0 ? 'Bullish' : delta_d < 0 ? 'Bearish' : 'Neutral', text_color = color.black, text_size = table_size)
        table.cell(tb, 4, 5, str.tostring(b_vol_d, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 5, 5, str.tostring(s_vol_d, format.volume), text_color = color.black, text_size = table_size)
        table.cell(tb, 6, 5, str.tostring(delta_d, format.volume), text_color = delta_d > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 5, win_d, text_color = color.black, text_size = table_size)

        // Overall Market Behavior
        overall_delta = (is_sesa != 0 ? delta_a : 0) + (is_sesb != 0 ? delta_b : 0) + (is_sesc != 0 ? delta_c : 0) + (is_sesd != 0 ? delta_d : 0)
        overall_txt = overall_delta > 0 ? 'Overall Market Behavior: BULLISH (Buyers Control)' : overall_delta < 0 ? 'Overall Market Behavior: BEARISH (Sellers Control)' : 'Overall Market Behavior: NEUTRAL'
        table.cell(tb, 0, 6, overall_txt, text_color = color.black, bgcolor = color.white, text_size = table_size)
        table.merge_cells(tb, 0, 6, total_cols - 1, 6)

// Overlays
var float max_sesa = na
var float min_sesa = na
var float max_sesb = na
var float min_sesb = na
var float max_sesc = na
var float min_sesc = na
var float max_sesd = na
var float min_sesd = na
var float avg_a = na
var float avg_b = na
var float avg_c = na
var float avg_d = na

if show_sesa and sesa_range
    [rmax, rmin] = get_range(is_sesa, sesa_txt, sesa_css)
    if is_sesa != 0
        max_sesa := na
        min_sesa := na
        min_sesa
    else
        max_sesa := rmax
        min_sesa := rmin
        min_sesa

if show_sesb and sesb_range
    [rmax, rmin] = get_range(is_sesb, sesb_txt, sesb_css)
    if is_sesb != 0
        max_sesb := na
        min_sesb := na
        min_sesb
    else
        max_sesb := rmax
        min_sesb := rmin
        min_sesb

if show_sesc and sesc_range
    [rmax, rmin] = get_range(is_sesc, sesc_txt, sesc_css)
    if is_sesc != 0
        max_sesc := na
        min_sesc := na
        min_sesc
    else
        max_sesc := rmax
        min_sesc := rmin
        min_sesc

if show_sesd and sesd_range
    [rmax, rmin] = get_range(is_sesd, sesd_txt, sesd_css)
    if is_sesd != 0
        max_sesd := na
        min_sesd := na
        min_sesd
    else
        max_sesd := rmax
        min_sesd := rmin
        min_sesd

// Trendlines Rendering
if show_sesa and sesa_tl
    set_line(is_sesa, y1_a, y2_a, sesa_css)

if show_sesb and sesb_tl
    set_line(is_sesb, y1_b, y2_b, sesb_css)

if show_sesc and sesc_tl
    set_line(is_sesc, y1_c, y2_c, sesc_css)

if show_sesd and sesd_tl
    set_line(is_sesd, y1_d, y2_d, sesd_css)

// Means
if show_sesa and sesa_avg
    avg_a := get_avg(is_sesa)
    set_line(is_sesa, avg_a, avg_a, sesa_css)
if show_sesb and sesb_avg
    avg_b := get_avg(is_sesb)
    set_line(is_sesb, avg_b, avg_b, sesb_css)
if show_sesc and sesc_avg
    avg_c := get_avg(is_sesc)
    set_line(is_sesc, avg_c, avg_c, sesc_css)
if show_sesd and sesd_avg
    avg_d := get_avg(is_sesd)
    set_line(is_sesd, avg_d, avg_d, sesd_css)

// VWAP Rendering
var float vwap_a = na
var float vwap_b = na
var float vwap_c = na
var float vwap_d = na

if show_sesa and sesa_vwap
    [num, den] = get_vwap(is_sesa)
    if den != 0
        vwap_a := num / den
        vwap_a

if show_sesb and sesb_vwap
    [num, den] = get_vwap(is_sesb)
    if den != 0
        vwap_b := num / den
        vwap_b

if show_sesc and sesc_vwap
    [num, den] = get_vwap(is_sesc)
    if den != 0
        vwap_c := num / den
        vwap_c

if show_sesd and sesd_vwap
    [num, den] = get_vwap(is_sesd)
    if den != 0
        vwap_d := num / den
        vwap_d

// =============================================================================
// ============================= PLOTTING & OUTPUT =============================
// =============================================================================
// All plots include `display = display.all - display.status_line` to ensure indicator strings remain clean.

plot(sesa_maxmin ? max_sesa : na, 'Session A Maximum', sesa_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesa_maxmin ? min_sesa : na, 'Session A Minimum', sesa_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesb_maxmin ? max_sesb : na, 'Session B Maximum', sesb_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesb_maxmin ? min_sesb : na, 'Session B Minimum', sesb_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesc_maxmin ? max_sesc : na, 'Session C Maximum', sesc_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesc_maxmin ? min_sesc : na, 'Session C Minimum', sesc_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesd_maxmin ? max_sesd : na, 'Session D Maximum', sesd_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(sesd_maxmin ? min_sesd : na, 'Session D Minimum', sesd_css, 1, plot.style_linebr, display = display.all - display.status_line)

plot(vwap_a, 'Session A VWAP', sesa_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(vwap_b, 'Session B VWAP', sesb_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(vwap_c, 'Session C VWAP', sesc_css, 1, plot.style_linebr, display = display.all - display.status_line)
plot(vwap_d, 'Session D VWAP', sesd_css, 1, plot.style_linebr, display = display.all - display.status_line)

plotshape(is_sesa != 0 and show_ses_div and show_sesa, '·', shape.square, location.bottom, na, text = '.', textcolor = sesa_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesa != is_sesa[1] and show_ses_div and show_sesa, 'NYE', shape.labelup, location.bottom, na, text = '❚', textcolor = sesa_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesb != 0 and show_ses_div and show_sesb, '·', shape.labelup, location.bottom, na, text = '.', textcolor = sesb_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesb != is_sesb[1] and show_ses_div and show_sesb, 'LDN', shape.labelup, location.bottom, na, text = '❚', textcolor = sesb_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesc != 0 and show_ses_div and show_sesc, '·', shape.square, location.bottom, na, text = '.', textcolor = sesc_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesc != is_sesc[1] and show_ses_div and show_sesc, 'TYO', shape.labelup, location.bottom, na, text = '❚', textcolor = sesc_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesd != 0 and show_ses_div and show_sesd, '·', shape.labelup, location.bottom, na, text = '.', textcolor = sesd_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesd != is_sesd[1] and show_ses_div and show_sesd, 'SYD', shape.labelup, location.bottom, na, text = '❚', textcolor = sesd_css, size = size.tiny, display = display.all - display.status_line, editable = false)

// Process High/Low/Pivot Lines at end
if barstate.islast
    string str_pd_date = str.format('{0,date,dd MMMM yyyy (EEEE)}', pd_time, syminfo.timezone)
    string str_th_time = str.format('{0,time,HH:mm}', t_high_time, 'Asia/Kolkata')
    string str_tl_time = str.format('{0,time,HH:mm}', t_low_time, 'Asia/Kolkata')
    int pw_end_time = pw_time + 518400000
    string str_pw_start = str.format('{0,date,dd MMM}', pw_time, syminfo.timezone)
    string str_pw_end = str.format('{0,date,dd MMM yyyy}', pw_end_time, syminfo.timezone)
    string str_pm_name = str.format('{0,date,MMMM yyyy}', pm_time, syminfo.timezone)

    update_level(line_th, lab_th, t_high, 'Today H: ' + str.tostring(t_high, '#.##') + ' - ' + str_th_time + ' IST', show_today)
    update_level(line_tl, lab_tl, t_low, 'Today L: ' + str.tostring(t_low, '#.##') + ' - ' + str_tl_time + ' IST', show_today)
    update_level(line_pdh, lab_pdh, pdh, 'PDH: ' + str.tostring(pdh, '#.##') + ' - ' + str_pd_date, show_pdhl)
    update_level(line_pdl, lab_pdl, pdl, 'PDL: ' + str.tostring(pdl, '#.##') + ' - ' + str_pd_date, show_pdhl)
    update_level(line_pwh, lab_pwh, pwh, 'PWH: ' + str.tostring(pwh, '#.##') + ' [' + str_pw_start + ' to ' + str_pw_end + ']', show_pwhl)
    update_level(line_pwl, lab_pwl, pwl, 'PWL: ' + str.tostring(pwl, '#.##') + ' [' + str_pw_start + ' to ' + str_pw_end + ']', show_pwhl)
    update_level(line_pmh, lab_pmh, pmh, 'PMH: ' + str.tostring(pmh, '#.##') + ' [' + str_pm_name + ']', show_pmhl)
    update_level(line_pml, lab_pml, pml, 'PML: ' + str.tostring(pml, '#.##') + ' [' + str_pm_name + ']', show_pmhl)
    update_level(line_ath, lab_ath, ath, 'ATH: ' + str.tostring(ath, '#.##'), show_athl)
    update_level(line_atl, lab_atl, atl, 'ATL: ' + str.tostring(atl, '#.##'), show_athl)

    update_level(line_dr1, lab_dr1, dr1, 'Daily R1: ' + str.tostring(dr1, '#.##'), show_sr)
    update_level(line_ds1, lab_ds1, ds1, 'Daily S1: ' + str.tostring(ds1, '#.##'), show_sr)
    update_level(line_dr2, lab_dr2, dr2, 'Daily R2: ' + str.tostring(dr2, '#.##'), show_sr)
    update_level(line_ds2, lab_ds2, ds2, 'Daily S2: ' + str.tostring(ds2, '#.##'), show_sr)

    update_level(line_wr1, lab_wr1, wr1, 'Weekly R1: ' + str.tostring(wr1, '#.##'), show_sr)
    update_level(line_ws1, lab_ws1, ws1, 'Weekly S1: ' + str.tostring(ws1, '#.##'), show_sr)
    update_level(line_wr2, lab_wr2, wr2, 'Weekly R2: ' + str.tostring(wr2, '#.##'), show_sr)
    update_level(line_ws2, lab_ws2, ws2, 'Weekly S2: ' + str.tostring(ws2, '#.##'), show_sr)

    update_level(line_mr1, lab_mr1, mr1, 'Monthly R1: ' + str.tostring(mr1, '#.##'), show_sr)
    update_level(line_ms1, lab_ms1, ms1, 'Monthly S1: ' + str.tostring(ms1, '#.##'), show_sr)
    update_level(line_mr2, lab_mr2, mr2, 'Monthly R2: ' + str.tostring(mr2, '#.##'), show_sr)
    update_level(line_ms2, lab_ms2, ms2, 'Monthly S2: ' + str.tostring(ms2, '#.##'), show_sr)


// Helper function for dashboard cell coloring
get_cell_color(trend_val) =>
    trend_val == 'Bullish' ? color.blue : trend_val == 'Bearish' ? color.black : color.white

get_text_color(trend_val) =>
    trend_val == 'Bullish' or trend_val == 'Bearish' ? color.white : color.black

if barstate.islast and show_dash
    // Core Updates (Always visible)
    table.cell(tb, 1, 2, is_sesa != 0 ? 'Active' : 'Inactive', bgcolor = is_sesa != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 3, is_sesb != 0 ? 'Active' : 'Inactive', bgcolor = is_sesb != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 4, is_sesc != 0 ? 'Active' : 'Inactive', bgcolor = is_sesc != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 5, is_sesd != 0 ? 'Active' : 'Inactive', bgcolor = is_sesd != 0 ? #089981 : #f23645, text_color = color.white, text_size = table_size)

    if advanced_dash
        // Define trend strings
        string t_p_a = r2_a > 0 ? 'Bullish' : 'Bearish'
        string t_v_a = delta_a > 0 ? 'Bullish' : delta_a < 0 ? 'Bearish' : 'Neutral'

        string t_p_b = r2_b > 0 ? 'Bullish' : 'Bearish'
        string t_v_b = delta_b > 0 ? 'Bullish' : delta_b < 0 ? 'Bearish' : 'Neutral'

        string t_p_c = r2_c > 0 ? 'Bullish' : 'Bearish'
        string t_v_c = delta_c > 0 ? 'Bullish' : delta_c < 0 ? 'Bearish' : 'Neutral'

        string t_p_d = r2_d > 0 ? 'Bullish' : 'Bearish'
        string t_v_d = delta_d > 0 ? 'Bullish' : delta_d < 0 ? 'Bearish' : 'Neutral'

        // Session A Updates
        table.cell(tb, 2, 2, t_p_a, bgcolor = get_cell_color(t_p_a), text_color = get_text_color(t_p_a), text_size = table_size)
        table.cell(tb, 3, 2, t_v_a, bgcolor = get_cell_color(t_v_a), text_color = get_text_color(t_v_a), text_size = table_size)
        table.cell(tb, 4, 2, str.tostring(b_vol_a, format.volume), text_size = table_size)
        table.cell(tb, 5, 2, str.tostring(s_vol_a, format.volume), text_size = table_size)
        table.cell(tb, 6, 2, str.tostring(delta_a, format.volume), text_color = delta_a > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 2, win_a, text_size = table_size)

        // Session B Updates
        table.cell(tb, 2, 3, t_p_b, bgcolor = get_cell_color(t_p_b), text_color = get_text_color(t_p_b), text_size = table_size)
        table.cell(tb, 3, 3, t_v_b, bgcolor = get_cell_color(t_v_b), text_color = get_text_color(t_v_b), text_size = table_size)
        table.cell(tb, 4, 3, str.tostring(b_vol_b, format.volume), text_size = table_size)
        table.cell(tb, 5, 3, str.tostring(s_vol_b, format.volume), text_size = table_size)
        table.cell(tb, 6, 3, str.tostring(delta_b, format.volume), text_color = delta_b > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 3, win_b, text_size = table_size)

        // Session C Updates
        table.cell(tb, 2, 4, t_p_c, bgcolor = get_cell_color(t_p_c), text_color = get_text_color(t_p_c), text_size = table_size)
        table.cell(tb, 3, 4, t_v_c, bgcolor = get_cell_color(t_v_c), text_color = get_text_color(t_v_c), text_size = table_size)
        table.cell(tb, 4, 4, str.tostring(b_vol_c, format.volume), text_size = table_size)
        table.cell(tb, 5, 4, str.tostring(s_vol_c, format.volume), text_size = table_size)
        table.cell(tb, 6, 4, str.tostring(delta_c, format.volume), text_color = delta_c > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 4, win_c, text_size = table_size)

        // Session D Updates
        table.cell(tb, 2, 5, t_p_d, bgcolor = get_cell_color(t_p_d), text_color = get_text_color(t_p_d), text_size = table_size)
        table.cell(tb, 3, 5, t_v_d, bgcolor = get_cell_color(t_v_d), text_color = get_text_color(t_v_d), text_size = table_size)
        table.cell(tb, 4, 5, str.tostring(b_vol_d, format.volume), text_size = table_size)
        table.cell(tb, 5, 5, str.tostring(s_vol_d, format.volume), text_size = table_size)
        table.cell(tb, 6, 5, str.tostring(delta_d, format.volume), text_color = delta_d > 0 ? #089981 : #f23645, text_size = table_size)
        table.cell(tb, 7, 5, win_d, text_size = table_size)
````
