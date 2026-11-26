# VWAP Trend

- url: https://www.tradingview.com/script/lanhXxFg-VWAP-Trend/
- type: indicator
- pine_id: PUB;7dd2d93c51d640f89cf13984ec6ef6d2
- version: 2.0

## Description

VWAP Trend & Daily Map Execution by erdensedat

Description:
VWAP Trend is an advanced day-trading engine and market mapping tool designed for intra-day execution using purely objective price action metrics. Instead of relying on lagging oscillators, this indicator fuses VWAP (Volume Weighted Average Price) deviations, Daily Open levels, and an automated Previous Day High/Low (PDH/PDL) targeting system.

Key Features:

Dynamic Bias Engine: The indicator measures real-time alignment between the Daily VWAP and the Daily Open price. A "BULLISH PRESSURE" signal fires when price reclaims both key metrics, while a "BEARISH PRESSURE" signal fires when price breaks below them.
Smart Time Filter: Automatically ignores high-volatility chop during the initial hours of a session (default is set to hide major text signals before 07:00 exchange time).
Automated PDH/PDL Liquidity Targets: Previous Day Highs and Lows are tracked with a "Cut-on-Touch" system. When a signal is active, these levels act as objective take-profit zones. Once touched, the level is cut, and a "TARGET REACHED" label is placed automatically.
Multi-Timeframe Macro Dashboard: An unobtrusive, dark-mode compatible panel displays the macro environment (EMA 200 Main Trend, Weekly Bias, Weekly VWAP, Daily Bias) alongside live target levels.
Clean UI & 'Only Today' Mode: Avoid chart clutter. The indicator features an "Only Today" toggle that completely erases previous days' lines, bands, and signals every day at midnight, leaving you with a perfectly clean chart for the current session.
How to Use:

Observe the Main Dashboard for Macro Alignment (Weekly Bias & EMA 200).
Wait for the designated trading hour to begin (e.g., 07:00).
Look for a Bullish / Bearish Pressure alert (indicated by clean, background-free text and arrow markers).
Target the active PDH or PDL lines shown on the chart.
Alerts:
Includes a single, unified alert condition ("VWAP Trend Signal") that dynamically pushes "Bullish Pressure" or "Bearish Pressure" notification text upon bar close.

Disclaimer:
Disclaimer: The "VWAP Trend" indicator by erdensedat is provided for educational and informational purposes only. It is not financial advice, and you should not construct it as such. Trading in financial markets (including cryptocurrencies, forex, and equities) involves a significant risk of loss and is not suitable for all investors. Past performance of any trading system or methodology is not necessarily indicative of future results. Always conduct your own research and manage your risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("VWAP Trend", shorttitle="VWAP Trend", overlay=true, max_boxes_count=50, max_labels_count=500, max_lines_count=500)

// --- Inputs ---
grp_levels = "Visibility Toggles"
i_showPdhPdl = input.bool(true, "Show PDH / PDL Targets", group=grp_levels)
i_cutOnTouch = input.bool(true, "Cut PDH / PDL on Touch", group=grp_levels)
i_showOpen   = input.bool(true, "Show Daily Open", group=grp_levels)
i_showVWAP   = input.bool(true, "Show VWAP", group=grp_levels)
i_showVwapBands = input.bool(true, "Show VWAP SD Bands", group=grp_levels)
i_showOpenBands = input.bool(false, "Show Daily Open % Bands", group=grp_levels)
i_showEma    = input.bool(false, "Show EMA 200 (Main Trend)", group=grp_levels)
i_onlyToday  = input.bool(true, "Show Only Today (Hide Past Signals)", group=grp_levels)

grp_params = "Band Parameters"
i_vwapMult = input.float(0.5, "VWAP SD Multiplier", step=0.1, group=grp_params)
i_openPct  = input.float(0.5, "Daily Open Band %", step=0.1, group=grp_params)

grp_style = "Colors & Styles"
c_pdh_pdl    = input.color(color.new(#5272be, 0), "PDH / PDL Target Color", group=grp_style)
c_open       = input.color(color.new(#434651, 0), "Daily Open Color", group=grp_style)
style_open   = input.string("Dotted", "Daily Open Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)
c_open_band  = input.color(color.new(#434651, 50), "Daily Open Band Color", group=grp_style)
c_vwap       = input.color(color.new(#2962FF, 0), "VWAP Default Color", group=grp_style)
style_vwap   = input.string("Solid", "VWAP Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)
c_ema        = input.color(color.new(color.gray, 50), "EMA 200 Color", group=grp_style)

grp_logic = "Signals & Dashboard"
i_showDash   = input.bool(true, "Show Dashboard", group=grp_logic)
i_showSignals= input.bool(true, "Show Crossover Signals", group=grp_logic)
i_showArrows = input.bool(true, "Show Small Arrows (Subsequent Signals)", group=grp_logic)
i_startHour  = input.int(7, "Start Hour for Signals", minval=0, maxval=23, group=grp_logic)
i_tz         = input.string("UTC+3", "Chart Timezone (for hour filter)", group=grp_logic)

// Helpers for line style
getLineStyle(str) =>
    str == "Solid" ? line.style_solid : str == "Dashed" ? line.style_dashed : line.style_dotted

// Fixed Colors
c_bull = color.new(#089981, 0)
c_bear = color.new(#f23645, 0)
c_neutral = color.new(#787B86, 0)

// Dynamic Color mapping for dark/light mode compatibility on custom dark colors
color dynamic_c_open = color.r(c_open) == 67 and color.g(c_open) == 70 and color.b(c_open) == 81 ? chart.fg_color : c_open
color dynamic_c_open_band = color.new(dynamic_c_open, 50)

// Object Tracking for "Only Today" logic
var label[] sigLabels = array.new_label()

// EMA 200 Plot & Main Trend
float ema200 = ta.ema(close, 200)
plot(i_showEma ? ema200 : na, "EMA 200", color=c_ema, linewidth=2)
string mainTrendState = close > ema200 ? "BULLISH" : close < ema200 ? "BEARISH" : "NEUTRAL"
color mainTrendColor = close > ema200 ? c_bull : close < ema200 ? c_bear : c_neutral

// --- Weekly Engine (For Dashboard) ---
var float w_open = na
var float w_vwap = na
var float sum_w_vol = 0
var float sum_w_src_vol = 0

isNewWeek = timeframe.change("W")

if isNewWeek
    w_open := open
    sum_w_vol := volume
    sum_w_src_vol := hlc3 * volume
else
    sum_w_vol += volume
    sum_w_src_vol += hlc3 * volume

if sum_w_vol > 0
    w_vwap := sum_w_src_vol / sum_w_vol

string wBiasState = close > w_open ? "BULL" : close < w_open ? "BEAR" : "NEUTRAL"
color wBiasColor = close > w_open ? c_bull : close < w_open ? c_bear : c_neutral

string wVwapState = close > w_vwap ? "BULL" : close < w_vwap ? "BEAR" : "NEUTRAL"
color wVwapColor = close > w_vwap ? c_bull : close < w_vwap ? c_bear : c_neutral


// --- PDH / PDL Target Engine (from erdensedat) ---
touches(float level) =>
    low <= level and high >= level

endTime(int hitT) =>
    na(hitT) ? time : hitT

var int   pdhTime  = na
var float pdhPrice = na
var int   pdlTime  = na
var float pdlPrice = na
var int   doStartTime = na

var int   currentDayHighTime = na
var float currentDayHigh     = na
var int   currentDayLowTime  = na
var float currentDayLow      = na

var int pdhHitTime = na
var int pdlHitTime = na

// --- Daily VWAP & Open Logic ---
var float d_open = na
var float d_vwap = na
var float sum_vol = 0
var float sum_src_vol = 0
var float sum_src_vol_sq = 0

isNewDay = timeframe.change("D")

float src = hlc3

if isNewDay
    // Save previous day for PDH/PDL engine
    pdhTime  := currentDayHighTime
    pdhPrice := currentDayHigh
    pdlTime  := currentDayLowTime
    pdlPrice := currentDayLow

    // Reset current day trackers
    currentDayHighTime := time
    currentDayHigh     := high
    currentDayLowTime  := time
    currentDayLow      := low

    doStartTime := time
    pdhHitTime := na
    pdlHitTime := na

    // Reset VWAP and Open
    d_open := open
    sum_vol := volume
    sum_src_vol := src * volume
    sum_src_vol_sq := volume * math.pow(src, 2)
        
    // Clean up past signals if Only Today is enabled
    if i_onlyToday
        for lbl in sigLabels
            label.delete(lbl)
        array.clear(sigLabels)
else
    // Accumulate PDH/PDL
    if na(currentDayHigh) or high > currentDayHigh
        currentDayHigh := high
        currentDayHighTime := time

    if na(currentDayLow) or low < currentDayLow
        currentDayLow := low
        currentDayLowTime := time
        
    // Accumulate VWAP
    sum_vol += volume
    sum_src_vol += src * volume
    sum_src_vol_sq += volume * math.pow(src, 2)

if sum_vol > 0
    d_vwap := sum_src_vol / sum_vol

// Calculate VWAP Standard Deviation
float vwap_variance = (sum_src_vol_sq / sum_vol) - math.pow(d_vwap, 2)
float vwap_stdev = vwap_variance > 0 ? math.sqrt(vwap_variance) : 0
float vwap_upper = d_vwap + (vwap_stdev * i_vwapMult)
float vwap_lower = d_vwap - (vwap_stdev * i_vwapMult)

// Calculate Open Bands (% based, purely horizontal)
float open_upper = d_open + (d_open * (i_openPct / 100))
float open_lower = d_open - (d_open * (i_openPct / 100))

// --- Touch Detection for PDH/PDL Targets ---
if i_cutOnTouch and i_showPdhPdl and na(pdhHitTime) and not na(pdhPrice) and not na(doStartTime) and time >= doStartTime
    if touches(pdhPrice)
        pdhHitTime := time
        lbl = label.new(bar_index, high, "", style=label.style_circle, color=color.new(color.red, 50), size=size.small)
        array.push(sigLabels, lbl)

if i_cutOnTouch and i_showPdhPdl and na(pdlHitTime) and not na(pdlPrice) and not na(doStartTime) and time >= doStartTime
    if touches(pdlPrice)
        pdlHitTime := time
        lbl = label.new(bar_index, low, "", style=label.style_circle, color=color.new(color.green, 50), size=size.small)
        array.push(sigLabels, lbl)

// --- Trend & Bias Logic ---
bool isVeryBullish = vwap_lower > open_upper
bool isVeryBearish = vwap_upper < open_lower
bool isBullish = d_vwap > d_open and not isVeryBullish
bool isBearish = d_vwap < d_open and not isVeryBearish

string biasState = isVeryBullish ? "STRONG BULL" : isBullish ? "BULL" : isVeryBearish ? "STRONG BEAR" : isBearish ? "BEAR" : "NEUTRAL"
color biasColor = (isVeryBullish or isBullish) ? c_bull : (isVeryBearish or isBearish) ? c_bear : c_neutral

// VWAP dynamic colors
color current_vwap_c = isVeryBullish ? c_bull : isVeryBearish ? c_bear : c_vwap
color current_vwap_band_c = color.new(current_vwap_c, 50)

// Draw Levels
var line l_high = na
var line l_low = na
var line l_open = na
var line l_open_up = na
var line l_open_dn = na
var line l_vwap = na
var line l_vwap_up = na
var line l_vwap_dn = na

var label lb_high = na
var label lb_low = na
var label lb_open = na
var label lb_open_up = na
var label lb_open_dn = na
var label lb_vwap = na
var label lb_vwap_up = na
var label lb_vwap_dn = na

// Draw PDH/PDL Engine Visuals
if not na(l_high)
    line.delete(l_high)
if not na(l_low)
    line.delete(l_low)
if not na(lb_high)
    label.delete(lb_high)
if not na(lb_low)
    label.delete(lb_low)

if i_showPdhPdl and not na(pdhTime) and not na(pdhPrice)
    bool isHit = not na(pdhHitTime) and i_cutOnTouch
    int x2 = isHit ? pdhHitTime : time
    l_high  := line.new(x1=pdhTime, y1=pdhPrice, x2=x2, y2=pdhPrice, xloc=xloc.bar_time, color=c_pdh_pdl, width=1, style=line.style_solid)
    
    if isHit
        int midTime = math.round((pdhTime + pdhHitTime) / 2)
        lb_high := label.new(x=midTime, y=pdhPrice, xloc=xloc.bar_time, yloc=yloc.price, text="BULLISH TARGET REACHED\nPOSSIBLE REVERSAL ZONE", textcolor=c_pdh_pdl, style=label.style_none, size=size.normal, textalign=text.align_center)
    else
        lb_high := label.new(x=x2, y=pdhPrice, xloc=xloc.bar_time, yloc=yloc.price, text="   TARGET PDH - " + str.tostring(pdhPrice, format.mintick), textcolor=c_pdh_pdl, style=label.style_none, size=size.normal, textalign=text.align_left)

if i_showPdhPdl and not na(pdlTime) and not na(pdlPrice)
    bool isHit = not na(pdlHitTime) and i_cutOnTouch
    int x2 = isHit ? pdlHitTime : time
    l_low  := line.new(x1=pdlTime, y1=pdlPrice, x2=x2, y2=pdlPrice, xloc=xloc.bar_time, color=c_pdh_pdl, width=1, style=line.style_solid)
    
    if isHit
        int midTime = math.round((pdlTime + pdlHitTime) / 2)
        lb_low := label.new(x=midTime, y=pdlPrice, xloc=xloc.bar_time, yloc=yloc.price, text="POSSIBLE REVERSAL ZONE\nBEARISH TARGET REACHED", textcolor=c_pdh_pdl, style=label.style_none, size=size.normal, textalign=text.align_center)
    else
        lb_low := label.new(x=x2, y=pdlPrice, xloc=xloc.bar_time, yloc=yloc.price, text="   TARGET PDL - " + str.tostring(pdlPrice, format.mintick), textcolor=c_pdh_pdl, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw Daily Open & VWAP
if isNewDay
    if not na(l_open)
        line.delete(l_open), line.delete(l_open_up), line.delete(l_open_dn)
        label.delete(lb_open), label.delete(lb_open_up), label.delete(lb_open_dn)
    
    if i_showOpen
        l_open  := line.new(bar_index, d_open, bar_index, d_open, color=dynamic_c_open, style=getLineStyle(style_open))
        lb_open := label.new(bar_index, d_open, "D.OPEN", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=dynamic_c_open, size=size.normal)
    
    if i_showOpenBands
        l_open_up  := line.new(bar_index, open_upper, bar_index, open_upper, color=dynamic_c_open_band, style=line.style_dashed)
        l_open_dn  := line.new(bar_index, open_lower, bar_index, open_lower, color=dynamic_c_open_band, style=line.style_dashed)
        lb_open_up := label.new(bar_index, open_upper, "+" + str.tostring(i_openPct) + "%", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=dynamic_c_open_band, size=size.normal)
        lb_open_dn := label.new(bar_index, open_lower, "-" + str.tostring(i_openPct) + "%", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=dynamic_c_open_band, size=size.normal)

    if not na(l_vwap)
        line.delete(l_vwap), line.delete(l_vwap_up), line.delete(l_vwap_dn)
        label.delete(lb_vwap), label.delete(lb_vwap_up), label.delete(lb_vwap_dn)
        
    if i_showVWAP
        l_vwap  := line.new(bar_index, d_vwap, bar_index, d_vwap, color=current_vwap_c, style=getLineStyle(style_vwap))
        lb_vwap := label.new(bar_index, d_vwap, "D.VWAP", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=current_vwap_c, size=size.normal)
        
    if i_showVwapBands
        l_vwap_up  := line.new(bar_index, vwap_upper, bar_index, vwap_upper, color=current_vwap_band_c, style=line.style_dashed)
        l_vwap_dn  := line.new(bar_index, vwap_lower, bar_index, vwap_lower, color=current_vwap_band_c, style=line.style_dashed)
        lb_vwap_up := label.new(bar_index, vwap_upper, "+" + str.tostring(i_vwapMult) + " SD", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=current_vwap_band_c, size=size.normal)
        lb_vwap_dn := label.new(bar_index, vwap_lower, "-" + str.tostring(i_vwapMult) + " SD", style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=current_vwap_band_c, size=size.normal)

if not isNewDay
    if i_showOpen
        line.set_x2(l_open, bar_index)
        label.set_x(lb_open, bar_index)
    if i_showOpenBands
        line.set_x2(l_open_up, bar_index), line.set_x2(l_open_dn, bar_index)
        label.set_x(lb_open_up, bar_index), label.set_x(lb_open_dn, bar_index)
    if i_showVWAP
        line.set_x2(l_vwap, bar_index), line.set_y2(l_vwap, d_vwap), line.set_color(l_vwap, current_vwap_c)
        label.set_x(lb_vwap, bar_index), label.set_y(lb_vwap, d_vwap), label.set_textcolor(lb_vwap, current_vwap_c)
    if i_showVwapBands
        line.set_x2(l_vwap_up, bar_index), line.set_y2(l_vwap_up, vwap_upper), line.set_color(l_vwap_up, current_vwap_band_c)
        label.set_x(lb_vwap_up, bar_index), label.set_y(lb_vwap_up, vwap_upper), label.set_textcolor(lb_vwap_up, current_vwap_band_c)
        line.set_x2(l_vwap_dn, bar_index), line.set_y2(l_vwap_dn, vwap_lower), line.set_color(l_vwap_dn, current_vwap_band_c)
        label.set_x(lb_vwap_dn, bar_index), label.set_y(lb_vwap_dn, vwap_lower), label.set_textcolor(lb_vwap_dn, current_vwap_band_c)

// --- State & Signals ---
var int lastSignalBar = 0
var bool hasLongedAfter7 = false
var bool hasShortedAfter7 = false

if isNewDay
    hasLongedAfter7 := false
    hasShortedAfter7 := false

bool isAfter7 = hour(time, i_tz) >= i_startHour
bool canSignal = (bar_index - lastSignalBar) > 1 // Prevent consecutive signals

bool isBullState = close > d_vwap and close > d_open
bool isBearState = close < d_vwap and close < d_open

bool prevBullState = close[1] > d_vwap[1] and close[1] > d_open[1]
bool prevBearState = close[1] < d_vwap[1] and close[1] < d_open[1]

bool longSignal = isBullState and not prevBullState and canSignal
bool shortSignal = isBearState and not prevBearState and canSignal

if longSignal and i_showSignals
    lastSignalBar := bar_index
    if isAfter7 and not hasLongedAfter7
        lbl = label.new(bar_index, na, "\nBULLISH PRESSURE\n▲", yloc=yloc.belowbar, style=label.style_none, textcolor=c_bull, size=size.normal)
        array.push(sigLabels, lbl)
        hasLongedAfter7 := true
    else if i_showArrows
        lbl = label.new(bar_index, na, "\n▲", yloc=yloc.belowbar, style=label.style_none, textcolor=c_bull, size=size.normal)
        array.push(sigLabels, lbl)

if shortSignal and i_showSignals
    lastSignalBar := bar_index
    if isAfter7 and not hasShortedAfter7
        lbl = label.new(bar_index, na, "▼\nBEARISH PRESSURE\n", yloc=yloc.abovebar, style=label.style_none, textcolor=c_bear, size=size.normal)
        array.push(sigLabels, lbl)
        hasShortedAfter7 := true
    else if i_showArrows
        lbl = label.new(bar_index, na, "▼\n", yloc=yloc.abovebar, style=label.style_none, textcolor=c_bear, size=size.normal)
        array.push(sigLabels, lbl)

// --- Alerts ---
bool anySignal = longSignal or shortSignal
alertcondition(anySignal, title="VWAP Trend Signal", message="VWAP Trend Signal Triggered")

if longSignal
    alert("Bullish Pressure", alert.freq_once_per_bar_close)

if shortSignal
    alert("Bearish Pressure", alert.freq_once_per_bar_close)

// --- Dashboard ---
var table tb = table.new(position.top_right, 2, 8, bgcolor=color.new(chart.bg_color, 10), border_width=1, border_color=color.new(chart.fg_color, 80))
if i_showDash and barstate.islast
    table.cell(tb, 0, 0, "VWAP Trend", text_color=chart.fg_color, bgcolor=color.new(chart.fg_color, 90))
    table.cell(tb, 1, 0, "erdensedat", text_color=chart.fg_color, bgcolor=color.new(chart.fg_color, 90))
    
    table.cell(tb, 0, 1, "Main Trend", text_color=chart.fg_color)
    table.cell(tb, 1, 1, mainTrendState, text_color=mainTrendColor)
    
    table.cell(tb, 0, 2, "Weekly Bias", text_color=chart.fg_color)
    table.cell(tb, 1, 2, wBiasState, text_color=wBiasColor)

    table.cell(tb, 0, 3, "W.VWAP Trend", text_color=chart.fg_color)
    table.cell(tb, 1, 3, wVwapState, text_color=wVwapColor)
    
    table.cell(tb, 0, 4, "Daily Bias", text_color=chart.fg_color)
    table.cell(tb, 1, 4, biasState, text_color=biasColor)
    
    table.cell(tb, 0, 5, "Target PDH", text_color=chart.fg_color)
    table.cell(tb, 1, 5, str.tostring(pdhPrice, format.mintick), text_color=c_pdh_pdl)
    
    table.cell(tb, 0, 6, "Target PDL", text_color=chart.fg_color)
    table.cell(tb, 1, 6, str.tostring(pdlPrice, format.mintick), text_color=c_pdh_pdl)
    
    table.cell(tb, 0, 7, "D.OPEN", text_color=chart.fg_color)
    table.cell(tb, 1, 7, str.tostring(d_open, format.mintick), text_color=dynamic_c_open)
````
