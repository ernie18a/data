# Elaborate Session Levels & Dynamic S/R (Fixed)

- url: https://www.tradingview.com/script/bxviWqRV-Elaborate-Session-Levels-Dynamic-S-R-Fixed/
- type: indicator
- pine_id: PUB;e5b736c86ed94b58942906619cebdbae
- version: 1.0

## Description

High-Performance Intra-Day Session Levels & Dynamic S/R Engine (Pine Script v6)
This institutional-grade utility tracks historical intraday volatility structures across major world markets and projects real-time execution key zones directly onto your screen—completely independent of historical candle clutter.

🌟 Key Functionalities:
True Session Extremes: Tracks precise High and Low parameters for the Asian, London, and New York sessions from the previous completed trading day.

No Chart Clutter: Bypasses conventional historical multi-line tracking. Using raw real-time conditional architecture (barstate.islast), the script cleaner projects lines into the future right-side blank space, perfectly matching your active price action.

Algorithmic Support & Resistance Tracker: Dynamically tracks structural fractional pivot coordinates (ta.pivothigh / ta.pivotlow). If price returns and tests a previous structural vertex within a close percentage proximity threshold (touchThresh), the script flags it as a dominant market structure line (Main Support or Main Resistance).

Fully Adaptive Inputs: Easily modify session times, switch up custom colors, or calibrate pivot sensitivity settings directly inside the indicator options panel to tailor the calculations to your specific timeline asset or strategy.

Perfect for ICT, SMC, or raw Price Action traders who want clean execution metrics at a single glance!

## Source Code

````pine
//@version=6
indicator("Simple Session Levels & S/R (v6 Clean)", overlay=true, max_lines_count=50, max_labels_count=50)

// ==========================================
// INPUTS & CONFIGURATION
// ==========================================
var string G_SESS  = "Session Times"
asiaSess   = input.session("1900-0300", "Asia Session", group=G_SESS)
londonSess = input.session("0300-1100", "London Session", group=G_SESS)
nySess     = input.session("0800-1700", "New York Session", group=G_SESS)

var string G_COL   = "Line Colors"
c_asia     = input.color(color.blue, "Asia Color", group=G_COL)
c_london   = input.color(color.orange, "London Color", group=G_COL)
c_ny       = input.color(color.red, "New York Color", group=G_COL)
c_sup      = input.color(color.green, "Main Support", group=G_COL)
c_res      = input.color(color.maroon, "Main Resistance", group=G_COL)

// ==========================================
// SELECTION & TRACKING LOGIC
// ==========================================
inSession(sessTime) => not na(time(timeframe.period, sessTime))

// Active status
asiaActive = inSession(asiaSess)
lonActive  = inSession(londonSess)
nyActive   = inSession(nySess)

// Check for new sessions to capture previous data
asiaNew = asiaActive and not asiaActive[1]
lonNew  = lonActive and not lonActive[1]
nyNew   = nyActive and not nyActive[1]

// Internal tracking registers
var float hAsia = na, var float lAsia = na
var float hLon  = na, var float lLon  = na
var float hNy   = na, var float lNy   = na

// Live capture during market hours
hAsia := asiaActive ? (asiaNew ? high : math.max(high, hAsia)) : hAsia
lAsia := asiaActive ? (asiaNew ? low  : math.min(low, lAsia))   : lAsia

hLon  := lonActive  ? (lonNew  ? high : math.max(high, hLon))  : hLon
lLon  := lonActive  ? (lonNew  ? low  : math.min(low, lLon))   : lLon

hNy   := nyActive   ? (nyNew   ? high : math.max(high, hNy))   : hNy
lNy   := nyActive   ? (nyNew   ? low  : math.min(low, lNy))    : lNy

// Historical capture for "Previous Day/Session" display
var float pAsiaH = na, var float pAsiaL = na
var float pLonH  = na, var float pLonL  = na
var float pNyH   = na, var float pNyL   = na

if asiaNew
    pAsiaH := hAsia[1], pAsiaL := lAsia[1]
if lonNew
    pLonH := hLon[1], pLonL := lLon[1]
if nyNew
    pNyH := hNy[1], pNyL := lNy[1]

// Simple Support & Resistance (Highest high / Lowest low of last 50 bars)
mainRes = ta.highest(high, 50)
mainSup = ta.lowest(low, 50)

// ==========================================
// CLEAN DRAWING MODULE (RIGHT-SIDE LINES)
// ==========================================
// Using native type references only
var line l_ah = na, var line l_al = na
var line l_lh = na, var line l_ll = na
var line l_nh = na, var line l_nl = na
var line l_mr = na, var line l_ms = na

var label lb_ah = na, var label lb_al = na
var label lb_lh = na, var label lb_ll = na
var label lb_nh = na, var label lb_nl = na
var label lb_mr = na, var label lb_ms = na

if barstate.islast
    // Delete previous frame instances natively
    line.delete(l_ah), label.delete(lb_ah)
    line.delete(l_al), label.delete(lb_al)
    line.delete(l_lh), label.delete(lb_lh)
    line.delete(l_ll), label.delete(lb_ll)
    line.delete(l_nh), label.delete(lb_nh)
    line.delete(l_nl), label.delete(lb_nl)
    line.delete(l_mr), label.delete(lb_mr)
    line.delete(l_ms), label.delete(lb_ms)

    // Render Right-Side Extensions (15 bars into the future)
    extX = bar_index + 15
    lblX = bar_index + 16

    if not na(pAsiaH)
        l_ah  := line.new(bar_index, pAsiaH, extX, pAsiaH, color=c_asia, style=line.style_dashed)
        lb_ah := label.new(lblX, pAsiaH, "Asia High (" + str.tostring(pAsiaH, "#.##") + ")", textcolor=c_asia, style=label.style_label_left, size=size.small, color=color.new(c_asia, 90))
    if not na(pAsiaL)
        l_al  := line.new(bar_index, pAsiaL, extX, pAsiaL, color=c_asia, style=line.style_dashed)
        lb_al := label.new(lblX, pAsiaL, "Asia Low (" + str.tostring(pAsiaL, "#.##") + ")", textcolor=c_asia, style=label.style_label_left, size=size.small, color=color.new(c_asia, 90))

    if not na(pLonH)
        l_lh  := line.new(bar_index, pLonH, extX, pLonH, color=c_london, style=line.style_dashed)
        lb_lh := label.new(lblX, pLonH, "London High (" + str.tostring(pLonH, "#.##") + ")", textcolor=c_london, style=label.style_label_left, size=size.small, color=color.new(c_london, 90))
    if not na(pLonL)
        l_ll  := line.new(bar_index, pLonL, extX, pLonL, color=c_london, style=line.style_dashed)
        lb_ll := label.new(lblX, pLonL, "London Low (" + str.tostring(pLonL, "#.##") + ")", textcolor=c_london, style=label.style_label_left, size=size.small, color=color.new(c_london, 90))

    if not na(pNyH)
        l_nh  := line.new(bar_index, pNyH, extX, pNyH, color=c_ny, style=line.style_dashed)
        lb_nh := label.new(lblX, pNyH, "N.Y High (" + str.tostring(pNyH, "#.##") + ")", textcolor=c_ny, style=label.style_label_left, size=size.small, color=color.new(c_ny, 90))
    if not na(pNyL)
        l_nl  := line.new(bar_index, pNyL, extX, pNyL, color=c_ny, style=line.style_dashed)
        lb_nl := label.new(lblX, pNyL, "N.Y Low (" + str.tostring(pNyL, "#.##") + ")", textcolor=c_ny, style=label.style_label_left, size=size.small, color=color.new(c_ny, 90))

    // Main Support / Resistance
    l_mr  := line.new(bar_index, mainRes, extX, mainRes, color=c_res, width=2)
    lb_mr := label.new(lblX, mainRes, "Main Resistance (" + str.tostring(mainRes, "#.##") + ")", textcolor=c_res, style=label.style_label_left, size=size.small, color=color.new(c_res, 90))
    
    l_ms  := line.new(bar_index, mainSup, extX, mainSup, color=c_sup, width=2)
    lb_ms := label.new(lblX, mainSup, "Main Support (" + str.tostring(mainSup, "#.##") + ")", textcolor=c_sup, style=label.style_label_left, size=size.small, color=color.new(c_sup, 90))
````
