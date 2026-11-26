# RSI Bands (KenshinC)

- url: https://www.tradingview.com/script/fS0VIN5V-RSI-Bands-KenshinC/
- type: indicator
- pine_id: PUB;724b4d7ea20b4659975eb2b01c1d88cd
- version: 3.0

## Description

─────────────────────────────────────────────────────────────
//  [b]RSI BANDS (KenshinC) [/b]
// ─────────────────────────────────────────────────────────────
//
//  ███████╗██████╗ ███████╗    ██████╗  █████╗ ███╗   ██╗██████╗ ███████╗
//  ██╔════╝██╔══██╗██╔════╝    ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔════╝
//  ███████╗██████╔╝█████╗      ██████╔╝███████║██╔██╗ ██║██║  ██║███████╗
//  ╚════██║██╔══██╗██╔══╝      ██╔══██╗██╔══██║██║╚██╗██║██║  ██║╚════██║
//  ███████║██║  ██║███████╗    ██████╔╝██║  ██║██║ ╚████║██████╔╝███████║
//  ╚══════╝╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝
//
// [b] IMPORTANT DISCLAIMER:[/b]
//  This indicator is provided for EDUCATIONAL and TECHNICAL ANALYSIS purposes only.
//  It is NOT financial advice, investment recommendation, or trading signal.
//  Trading involves substantial risk of loss. Always do your own research and 
//  consult with a qualified financial advisor before making any investment decisions.
//  The author assumes no responsibility for any losses incurred from using this tool.
//
// ─────────────────────────────────────────────────────────────
// [b] INTRODUCTION[/b]
// ─────────────────────────────────────────────────────────────
// RSI Bands (KenshinC) is a powerful RSI-to-Price transformation indicator.
// Instead of showing RSI in a separate pane, it converts RSI levels into actual
// price levels directly on the main chart. This creates dynamic support/resistance
// zones based on RSI logic.
//
//[b] Key Features:[/b]
// • Custom RSI Source (Close/High/Low)
// • Fast RSI Length (default 8)
// • Multiple Overbought & Oversold bands with multiplier
// • RSI 50 equilibrium line
// • Custom RSI Upper (55) & Lower (45) bands
// • Real-time Statistics Table
// • Touch detection labels (▲/▼)
// • Labels on price scale with track price option
//
// ─────────────────────────────────────────────────────────────
// [b] HOW TO USE[/b]
// ─────────────────────────────────────────────────────────────
// 1. Market Context:
//    - Price near RSI Lower Band (45) or Oversold zones → Potential buy area
//    - Price near RSI Upper Band (55) or Overbought zones → Potential sell area
//    - Price around RSI 50 → Ranging / equilibrium market
//
// 2. Band Strength:
//    - Further bands (OB3–OB8 / OS3–OS8) represent stronger extremes.
//
// 3. Statistics Table:
//    - Shows current & historical % distance between Upper and Lower bands
//    - Helps quantify mean-reversion or breakout potential
//
// 4. Trading Styles:
//    - Mean Reversion: Buy at deep OS, Sell at deep OB
//    - Breakout: Strong break above OB1 or below OS1
//
// ─────────────────────────────────────────────────────────────
//  RECOMMENDED SETTINGS
// ─────────────────────────────────────────────────────────────
// • Scalping / Day Trading     → Timeframe 5m–1H, RSI Length 8
// • Swing Trading              → Timeframe 4H–Daily
// • Enable "Labels on Price Scale" + "Track Price" for cleaner look
// • Keep Statistics Table ON for better decision making
//
// ─────────────────────────────────────────────────────────────
//  SETTINGS GUIDE (Main Groups)
// ─────────────────────────────────────────────────────────────
// 1. Main Settings
//    - RSI Source, RSI Length, Overbought (85), Oversold (15)
//
// 2. RSI Levels Settings
//    - Multiplier (1.5): Controls spacing of extra bands
//    - RSI 50, RSI Lower Band (45), RSI Upper Band (55)
//
// 3. Outputs
//    - Labels, Touch Labels, Statistics Table, History Method
//
// ─────────────────────────────────────────────────────────────
//  FINAL REMINDER
// ─────────────────────────────────────────────────────────────
// This script is for educational and analytical purposes only.
// Past performance is not indicative of future results.
// Trade at your own risk.
//
// Created by: KenshinC
// Version: 1.0

## Source Code

````pine
//@version=5
// ============================================================
// RSI BANDS (KenshinC) - Professional Edition
// ============================================================
// Features:
// - Dynamic RSI Bands converted to price
// - Extended Overbought (OB1-OB8) & Oversold (OS1-OS8) levels
// - RSI 50 Linear Regression Slope + Pearson R (Trend Strength)
// - Touch Labels with RSI value display
// - Conditional OHLC % distance to OB/OS levels
// - Statistics Table with historical analysis
// - Clean English interface & documentation
// ============================================================

indicator('RSI Bands (KenshinC)', overlay=true, max_bars_back=1000)

// ============================================================
// INPUT GROUPS
// ============================================================
config      = "Main Settings"
levels      = "RSI Levels Settings"
outputs     = "Outputs Settings"
slope_group = "Slope RSI 50 (Linear Regression)"

// ============================================================
// MAIN INPUTS
// ============================================================
rsi_source = input.string('close', 'RSI Source', options=['close', 'high', 'low'], group=config)

length     = input.int(8,   'RSI Length',          group=config)
rsitop     = input.float(85, "Overbought Level",   group=config, inline='ob')
rsibot     = input.float(15, "Oversold Level",     group=config, inline='os')
color_1    = input.color(color.new(color.aqua, 10), '', group=config, inline='ob')
color_2    = input.color(color.new(color.blue, 10), '', group=config, inline='os')

// RSI Levels Display
rsilvls    = input.bool(true,  "Show RSI Levels",           group=levels, inline='1')
cloudsonly = input.bool(false, "Background Only (Hide Lines)", group=levels, inline='1')
mid        = input.bool(true,  'Show RSI 50 Line',          group=levels, inline='rsi50')
color_4    = input.color(color.new(#00FF00, 50), '', group=levels, inline='rsi50')

show_extended_ob = input.bool(true, "Show Extended Overbought Levels (OB1-OB8)", group=levels)
show_extended_os = input.bool(true, "Show Extended Oversold Levels (OS1-OS8)",   group=levels)

variavel = input.float(1.5, 'Multiplier for Extended Levels', group=levels)

// RSI Bands
rsi_lower       = input.bool(true,  'Show RSI Lower Band', group=levels, inline='lower')
rsi_lower_value = input.float(45,   'Lower Band Level',    minval=0, maxval=100, group=levels, inline='lower')
color_lower     = input.color(color.new(#FF9800, 50), '', group=levels, inline='lower')

rsi_upper       = input.bool(true,  'Show RSI Upper Band', group=levels, inline='upper')
rsi_upper_value = input.float(55,   'Upper Band Level',    minval=0, maxval=100, group=levels, inline='upper')
color_upper     = input.color(color.new(#FF9800, 50), '', group=levels, inline='upper')

// Outputs
lblbool         = input.bool(false, 'Show Value Labels',          group=outputs)
LegPre          = input.bool(false, 'Show Labels on Price Scale', group=outputs)
trackp          = input.bool(false, 'Track Price',                group=outputs)
off             = input.int(0,      'Label Offset',               group=outputs)
showTouchLabels = input.bool(true,  "Show Touch Labels",          group=outputs)

show_stats_table   = input.bool(true,  "Show Statistics Table", group=outputs)
history_method     = input.string("Time Range", "History Method", options=["Time Range", "Max Bars"], group=outputs)
max_history        = input.int(1000, "Max History Length", minval=100, maxval=5000, group=outputs)
startCalculationDate = input.time(timestamp("01 Jan 2025"), "Start Calculation Date", group=outputs)
endCalculationDate   = input.time(timestamp("01 Jan 2027"), "End Calculation Date",   group=outputs)

// Conditional OHLC Percentage Inputs
show_ohlc_pcts       = input.bool(true,  "Show OHLC Pcts to OB/OS (Conditional on Mid)", group=outputs)
show_pct_high_os_ob  = input.bool(true,  "  • High Pct",  group=outputs)
show_pct_low_os_ob   = input.bool(true,  "  • Low Pct",   group=outputs)
show_pct_open_os_ob  = input.bool(true,  "  • Open Pct",  group=outputs)
show_pct_close_os_ob = input.bool(true,  "  • Close Pct", group=outputs)

// Slope Settings
show_slope      = input.bool(true,  "Show Slope of RSI 50",      group=slope_group)
slope_len       = input.int(20,     "Slope Calculation Length",   minval=5, maxval=200, group=slope_group)
show_slope_line = input.bool(true, "Plot Regression Line",       group=slope_group)
show_strength   = input.bool(true,  "Show Pearson R (Trend Strength)", group=slope_group)

// ============================================================
// VARIABLES
// ============================================================
displayset = LegPre ? display.pane + display.status_line + display.price_scale : display.pane + display.status_line
lblstyle   = trackp ? label.style_none : label.style_label_left
lbloffset  = trackp ? off + 4 : off

// ============================================================
// RSI CALCULATION
// ============================================================
rsi_src     = rsi_source == 'close' ? close : rsi_source == 'high' ? high : low
rsi_current = ta.rsi(rsi_src, length)

// ============================================================
// RSI TO PRICE FUNCTION
// ============================================================
rsi_to_plot(tf, rsi_lvl, len) =>
    ep  = 2 * len - 1
    auc = request.security(syminfo.tickerid, tf, ta.ema(math.max(close - close[1], 0), ep))
    adc = request.security(syminfo.tickerid, tf, ta.ema(math.max(close[1] - close, 0), ep))
    x   = (len - 1) * (adc * rsi_lvl / (100 - rsi_lvl) - auc)
    x >= 0 ? close + x : close + x * (100 - rsi_lvl) / rsi_lvl

// ============================================================
// EXTENDED LEVELS
// ============================================================
ob1 = rsitop + variavel * 1
ob2 = rsitop + variavel * 2
ob3 = rsitop + variavel * 3
ob4 = rsitop + variavel * 4
ob5 = rsitop + variavel * 5
ob6 = rsitop + variavel * 6
ob7 = rsitop + variavel * 7
ob8 = rsitop + variavel * 8

os1 = rsibot - variavel * 1
os2 = rsibot - variavel * 2
os3 = rsibot - variavel * 3
os4 = rsibot - variavel * 4
os5 = rsibot - variavel * 5
os6 = rsibot - variavel * 6
os7 = rsibot - variavel * 7
os8 = rsibot - variavel * 8

mid50           = 50
rsi_lower_level = rsi_lower_value
rsi_upper_level = rsi_upper_value

// ============================================================
// CONVERT RSI LEVELS TO PRICE
// ============================================================
ob1rsi = rsi_to_plot('', ob1, length)
ob2rsi = rsi_to_plot('', ob2, length)
ob3rsi = rsi_to_plot('', ob3, length)
ob4rsi = rsi_to_plot('', ob4, length)
ob5rsi = rsi_to_plot('', ob5, length)
ob6rsi = rsi_to_plot('', ob6, length)
ob7rsi = rsi_to_plot('', ob7, length)
ob8rsi = rsi_to_plot('', ob8, length)

os1rsi = rsi_to_plot('', os1, length)
os2rsi = rsi_to_plot('', os2, length)
os3rsi = rsi_to_plot('', os3, length)
os4rsi = rsi_to_plot('', os4, length)
os5rsi = rsi_to_plot('', os5, length)
os6rsi = rsi_to_plot('', os6, length)
os7rsi = rsi_to_plot('', os7, length)
os8rsi = rsi_to_plot('', os8, length)

mid50rsi      = rsi_to_plot('', mid50, length)
rsi_lower_rsi = rsi_to_plot('', rsi_lower_level, length)
rsi_upper_rsi = rsi_to_plot('', rsi_upper_level, length)
rsi_top       = rsi_to_plot('', rsitop, length)
rsi_bot       = rsi_to_plot('', rsibot, length)

// ============================================================
// LINEAR REGRESSION SLOPE + PEARSON R
// ============================================================
calcSlope(src, len) =>
    if len <= 1 or na(src)
        [float(na), float(na), float(na)]
    else
        sumX = 0.0
        sumY = 0.0
        sumXSqr = 0.0
        sumXY = 0.0
        for i = 0 to len - 1
            val = src[i]
            per = len - i
            sumX    += per
            sumY    += val
            sumXSqr += per * per
            sumXY   += val * per
        slope     = (len * sumXY - sumX * sumY) / (len * sumXSqr - sumX * sumX)
        avg       = sumY / len
        intercept = avg - slope * sumX / len
        [slope, avg, intercept]

calcDev(src, len, slope, avg, intercept) =>
    stdDevAcc = 0.0
    dsxx = 0.0
    dsyy = 0.0
    dsxy = 0.0
    periods = len - 1
    daY = intercept + slope * periods / 2
    val = intercept
    for i = 0 to periods
        price = src[i]
        stdDevAcc += (price - val) * (price - val)
        dxt = price - avg
        dyt = val - daY
        dsxx += dxt * dxt
        dsyy += dyt * dyt
        dsxy += dxt * dyt
        val += slope
    stdDev   = math.sqrt(stdDevAcc / math.max(periods, 1))
    pearsonR = dsxx == 0 or dsyy == 0 ? 0.0 : dsxy / math.sqrt(dsxx * dsyy)
    [stdDev, pearsonR]

[slope_rsi50, avg_rsi50, intercept_rsi50] = calcSlope(mid50rsi, slope_len)
[_, pearsonR] = calcDev(mid50rsi, slope_len, slope_rsi50, avg_rsi50, intercept_rsi50)

reg_line_price = intercept_rsi50 + slope_rsi50 * (slope_len - 1)

// ============================================================
// PLOTTING
// ============================================================
plot(rsi_top,  title='Overbought Main',  color=color_1, linewidth=1, display=displayset, trackprice=trackp)
plot(rsi_bot,  title='Oversold Main',    color=color_2, linewidth=1, display=displayset, trackprice=trackp)

// Extended OB Levels
plot(rsilvls and show_extended_ob ? ob1rsi : na, title='OB1', color=color.new(#ee8f00, 50), linewidth=1)
plot(rsilvls and show_extended_ob ? ob2rsi : na, title='OB2', color=color.new(#EABB35, 50), linewidth=1)
plot(rsilvls and show_extended_ob ? ob3rsi : na, title='OB3', color=color.new(#FF6700, 50), linewidth=2)
plot(rsilvls and show_extended_ob ? ob4rsi : na, title='OB4', color=color.new(#FE0301, 50), linewidth=2)
plot(rsilvls and show_extended_ob ? ob5rsi : na, title='OB5', color=color.new(#7F0100, 50), linewidth=2)
plot(rsilvls and show_extended_ob ? ob6rsi : na, title='OB6', color=color.new(#5B0000, 50), linewidth=2)
plot(rsilvls and show_extended_ob ? ob7rsi : na, title='OB7', color=color.new(#3C0000, 50), linewidth=2)
plot(rsilvls and show_extended_ob ? ob8rsi : na, title='OB8', color=color.new(#1E0000, 50), linewidth=2)

// Extended OS Levels
plot(rsilvls and show_extended_os ? os1rsi : na, title='OS1', color=color.new(#eeae00, 50), linewidth=1)
plot(rsilvls and show_extended_os ? os2rsi : na, title='OS2', color=color.new(#EABB35, 50), linewidth=1)
plot(rsilvls and show_extended_os ? os3rsi : na, title='OS3', color=color.new(#FF6700, 50), linewidth=2)
plot(rsilvls and show_extended_os ? os4rsi : na, title='OS4', color=color.new(#FE0301, 50), linewidth=2)
plot(rsilvls and show_extended_os ? os5rsi : na, title='OS5', color=color.new(#7F0100, 50), linewidth=2)
plot(rsilvls and show_extended_os ? os6rsi : na, title='OS6', color=color.new(#5B0000, 50), linewidth=2)
plot(rsilvls and show_extended_os ? os7rsi : na, title='OS7', color=color.new(#3C0000, 50), linewidth=2)
plot(rsilvls and show_extended_os ? os8rsi : na, title='OS8', color=color.new(#1E0000, 50), linewidth=2)

// Core Bands
plot(mid ? mid50rsi : na,            title='RSI 50 Line',     color=color_4,     linewidth=3)
plot(rsi_lower ? rsi_lower_rsi : na, title='RSI Lower Band',  color=color_lower, linewidth=1)
plot(rsi_upper ? rsi_upper_rsi : na, title='RSI Upper Band',  color=color_upper, linewidth=1)

// Slope Plotting
slope_color = slope_rsi50 >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
plot(show_slope ? slope_rsi50 : na, title="Slope RSI 50", color=slope_color, linewidth=2, style=plot.style_columns)
plot(show_slope_line ? reg_line_price : na, title="Regression Line", color=color.new(color.yellow, 30), linewidth=3, style=plot.style_linebr)

bgcolor(show_slope ? color.new(slope_rsi50 > 0 ? color.green : color.red, 92) : na)

// ============================================================
// VALUE LABELS
// ============================================================
var label label_top   = na
var label label_bot   = na
var label label_mid   = na
var label label_lower = na
var label label_upper = na

lbltxt(val) => str.format("{0,number,#,##0.####}", val)

update_label(lb, y, txt, col) =>
    if na(lb)
        label.new(bar_index + lbloffset, y, txt, 
                  textcolor = col, 
                  color     = color.new(color.black, 100), 
                  textalign = text.align_left, 
                  style     = lblstyle)
    else
        label.set_xy(lb, bar_index + lbloffset, y)
        label.set_text(lb, txt)
        lb

if lblbool
    label_top   := update_label(label_top,   rsi_top,      lbltxt(rsi_top),   color_1)
    label_bot   := update_label(label_bot,   rsi_bot,      lbltxt(rsi_bot),   color_2)
    
    if mid
        label_mid   := update_label(label_mid,   mid50rsi,     lbltxt(mid50rsi),  color_4)
    if rsi_lower
        label_lower := update_label(label_lower, rsi_lower_rsi, lbltxt(rsi_lower_rsi), color_lower)
    if rsi_upper
        label_upper := update_label(label_upper, rsi_upper_rsi, lbltxt(rsi_upper_rsi), color_upper)

// ============================================================
// TOUCH LABELS WITH RSI VALUE (Updated)
// ============================================================
if showTouchLabels
    rsi_str = str.tostring(rsi_current, "#.##")
    
    // Touch Overbought Level (OB1)
    if high >= ob1rsi and high[1] < ob1rsi[1]
        label.new(bar_index, high, "▼ RSI: " + rsi_str, 
                  color     = color.new(color.red, 0), 
                  textcolor = color.white, 
                  style     = label.style_label_down, 
                  size      = size.small)
    
    // Touch Oversold Level (OS1)
    if low <= os1rsi and low[1] > os1rsi[1]
        label.new(bar_index, low, "▲ RSI: " + rsi_str, 
                  color     = color.new(color.green, 0), 
                  textcolor = color.white, 
                  style     = label.style_label_up, 
                  size      = size.small)

// ============================================================
// STATISTICS TABLE
// ============================================================
pct_diff = rsi_upper_rsi != 0 and rsi_lower_rsi != 0 ? ((rsi_upper_rsi - rsi_lower_rsi) / rsi_lower_rsi) * 100 : na

// Conditional OHLC Pct Calculations
is_below_rsi50 = close <= mid50rsi

os_level_for_pct = rsi_bot
ob_level_for_pct = rsi_top

pct_high_to_os  = is_below_rsi50 and os_level_for_pct != 0 ? ((high  - os_level_for_pct) / high  * 100) : na
pct_low_to_os   = is_below_rsi50 and os_level_for_pct != 0 ? ((low   - os_level_for_pct) / low   * 100) : na
pct_open_to_os  = is_below_rsi50 and os_level_for_pct != 0 ? ((open  - os_level_for_pct) / open  * 100) : na
pct_close_to_os = is_below_rsi50 and os_level_for_pct != 0 ? ((close - os_level_for_pct) / close * 100) : na

pct_high_to_ob  = not is_below_rsi50 and ob_level_for_pct != 0 ? ((ob_level_for_pct - high)  / high  * 100) : na
pct_low_to_ob   = not is_below_rsi50 and ob_level_for_pct != 0 ? ((ob_level_for_pct - low)   / low   * 100) : na
pct_open_to_ob  = not is_below_rsi50 and ob_level_for_pct != 0 ? ((ob_level_for_pct - open)  / open  * 100) : na
pct_close_to_ob = not is_below_rsi50 and ob_level_for_pct != 0 ? ((ob_level_for_pct - close) / close * 100) : na

var float[] pct_diff_history = array.new_float()
if not na(pct_diff)
    if history_method == "Time Range"
        if time >= startCalculationDate and time <= endCalculationDate
            array.push(pct_diff_history, pct_diff)
    else
        array.push(pct_diff_history, pct_diff)
        if array.size(pct_diff_history) > max_history
            array.shift(pct_diff_history)

var table stats_table = na
if show_stats_table
    if not na(stats_table)
        table.delete(stats_table)
    
    stats_table := table.new(position.top_right, 3, 25,
         bgcolor     = color.new(color.gray, 80), 
         border_width= 1, 
         border_color= color.black,
         frame_width = 2, 
         frame_color = color.black)

    // Row 0
    table.cell(stats_table, 0, 0, "RSI Upper Price", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 0, str.format("{0,number,#,##0.####}", rsi_upper_rsi), text_color=color.red)
    table.cell(stats_table, 2, 0, "Current price of RSI Upper Band", text_color=color.gray, text_size=size.normal)

    // Row 1
    table.cell(stats_table, 0, 1, "RSI Lower Price", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 1, str.format("{0,number,#,##0.####}", rsi_lower_rsi), text_color=color.blue)
    table.cell(stats_table, 2, 1, "Current price of RSI Lower Band", text_color=color.gray, text_size=size.normal)

    // Row 2
    table.cell(stats_table, 0, 2, "Current Pct Diff", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 2, str.format("{0,number,#,##0.####}%", pct_diff), text_color=color.orange)
    table.cell(stats_table, 2, 2, "% difference between Upper & Lower Band now", text_color=color.gray, text_size=size.normal)

    // Row 3
    table.cell(stats_table, 0, 3, "Avg Pct Diff", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 3, array.size(pct_diff_history)>0 ? str.format("{0,number,#,##0.####}%", array.avg(pct_diff_history)) : "No Data", text_color=color.orange)
    table.cell(stats_table, 2, 3, "Average % difference over selected period", text_color=color.gray, text_size=size.normal)

    // Row 4
    table.cell(stats_table, 0, 4, "Max Pct Diff", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 4, array.size(pct_diff_history)>0 ? str.format("{0,number,#,##0.####}%", array.max(pct_diff_history)) : "No Data", text_color=color.orange)
    table.cell(stats_table, 2, 4, "Maximum % difference recorded", text_color=color.gray, text_size=size.normal)

    // Row 5
    table.cell(stats_table, 0, 5, "Min Pct Diff", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 5, array.size(pct_diff_history)>0 ? str.format("{0,number,#,##0.####}%", array.min(pct_diff_history)) : "No Data", text_color=color.orange)
    table.cell(stats_table, 2, 5, "Minimum % difference recorded", text_color=color.gray, text_size=size.normal)

    // Row 6
    table.cell(stats_table, 0, 6, "Data Range", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 6, history_method == "Time Range" ? 
         str.format("{0,date,short} - {1,date,short}", startCalculationDate, endCalculationDate) : 
         str.format("Last {0} Bars", max_history), text_color=color.orange)
    table.cell(stats_table, 2, 6, "Time period used for calculations", text_color=color.gray, text_size=size.normal)

    // Row 7
    table.cell(stats_table, 0, 7, "Current RSI", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 7, str.format("{0,number,#,##0.##}", rsi_current), text_color=color.orange)
    table.cell(stats_table, 2, 7, "Latest RSI value (based on selected source)", text_color=color.gray, text_size=size.normal)

    // Row 8 - Slope RSI 50
    table.cell(stats_table, 0, 8, "Slope RSI 50", text_color=color.black, bgcolor=color.new(color.gray,90))
    table.cell(stats_table, 1, 8, str.format("{0,number,#,##0.####}", slope_rsi50), text_color = slope_rsi50 >= 0 ? color.blue : color.red)
    table.cell(stats_table, 2, 8, "Current slope of RSI 50 line (+ = Bullish)", text_color=color.gray, text_size=size.normal)

    // Row 9-10 - Strength
    if show_strength
        r_squared = pearsonR * pearsonR
        slope_dir = slope_rsi50 >= 0 ? "Bullish" : "Bearish"
        slope_str = r_squared > 0.64 ? "Very Strong" : r_squared > 0.36 ? "Strong" : "Weak"
        slope_text = slope_dir + " " + slope_str
        slope_str_color = slope_rsi50 >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

        table.cell(stats_table, 0, 9, "Pearson R", text_color=color.black, bgcolor=color.new(color.gray,90))
        table.cell(stats_table, 1, 9, str.format("{0,number,#,##0.##}", pearsonR), text_color = pearsonR >= 0 ? color.new(color.green, 0) : color.new(color.red, 0))
        table.cell(stats_table, 2, 9, "Correlation quality (-1 to +1). Green = good fit", text_color=color.gray, text_size=size.normal)

        table.cell(stats_table, 0, 10, "Slope Strength", text_color=color.black, bgcolor=color.new(color.gray,90))
        table.cell(stats_table, 1, 10, slope_text, text_color = slope_str_color, text_size = size.large)
        table.cell(stats_table, 2, 10, "Trend direction + strength (based on R²)", text_color=color.gray, text_size=size.normal)

    // Conditional OHLC Pct Section
    if show_ohlc_pcts
        int trow = 11

        table.cell(stats_table, 0, trow, "Price Position vs RSI50", text_color=color.black, bgcolor=color.new(color.gray,90))
        table.cell(stats_table, 1, trow, is_below_rsi50 ? "BELOW Mid (focus OS)" : "ABOVE Mid (focus OB)", 
                   text_color = is_below_rsi50 ? color.new(color.blue,0) : color.new(color.red,0))
        table.cell(stats_table, 2, trow, "close compared to mid50rsi price level", text_color=color.gray, text_size=size.normal)
        trow += 1

        if show_pct_high_os_ob
            string high_lbl = is_below_rsi50 ? "High to OS %" : "High to OB %"
            float  high_v   = is_below_rsi50 ? pct_high_to_os : pct_high_to_ob
            string high_dsc = is_below_rsi50 ? "% distance from High down to Oversold level" : "% room from High up to Overbought level"
            table.cell(stats_table, 0, trow, high_lbl, text_color=color.black, bgcolor=color.new(color.gray,90))
            table.cell(stats_table, 1, trow, str.format("{0,number,#,##0.####}%", high_v), text_color=color.orange)
            table.cell(stats_table, 2, trow, high_dsc, text_color=color.gray, text_size=size.normal)
            trow += 1

        if show_pct_low_os_ob
            string low_lbl = is_below_rsi50 ? "Low to OS %" : "Low to OB %"
            float  low_v   = is_below_rsi50 ? pct_low_to_os : pct_low_to_ob
            string low_dsc = is_below_rsi50 ? "% distance from Low down to Oversold level" : "% room from Low up to Overbought level"
            table.cell(stats_table, 0, trow, low_lbl, text_color=color.black, bgcolor=color.new(color.gray,90))
            table.cell(stats_table, 1, trow, str.format("{0,number,#,##0.####}%", low_v), text_color=color.orange)
            table.cell(stats_table, 2, trow, low_dsc, text_color=color.gray, text_size=size.normal)
            trow += 1

        if show_pct_open_os_ob
            string open_lbl = is_below_rsi50 ? "Open to OS %" : "Open to OB %"
            float  open_v   = is_below_rsi50 ? pct_open_to_os : pct_open_to_ob
            string open_dsc = is_below_rsi50 ? "% distance from Open down to Oversold level" : "% room from Open up to Overbought level"
            table.cell(stats_table, 0, trow, open_lbl, text_color=color.black, bgcolor=color.new(color.gray,90))
            table.cell(stats_table, 1, trow, str.format("{0,number,#,##0.####}%", open_v), text_color=color.orange)
            table.cell(stats_table, 2, trow, open_dsc, text_color=color.gray, text_size=size.normal)
            trow += 1

        if show_pct_close_os_ob
            string close_lbl = is_below_rsi50 ? "Close to OS %" : "Close to OB %"
            float  close_v   = is_below_rsi50 ? pct_close_to_os : pct_close_to_ob
            string close_dsc = is_below_rsi50 ? "% distance from Close down to Oversold level" : "% room from Close up to Overbought level"
            table.cell(stats_table, 0, trow, close_lbl, text_color=color.black, bgcolor=color.new(color.gray,90))
            table.cell(stats_table, 1, trow, str.format("{0,number,#,##0.####}%", close_v), text_color=color.orange)
            table.cell(stats_table, 2, trow, close_dsc, text_color=color.gray, text_size=size.normal)
else
    if not na(stats_table)
        table.delete(stats_table)
````
