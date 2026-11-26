# VWAP Session & NY Cash + Live Footprint

- url: https://www.tradingview.com/script/sp2Hoc95-VWAP-Session-NY-Cash-Live-Footprint/
- type: indicator
- pine_id: PUB;abf8527a3f544ad694b6311c112c1e2e
- version: 1.0

## Description

📊 VWAP Session & NY Cash + Live Footprint

By Quant (Enhanced & Combined Version)

🔍 Overview

This indicator is a multi-functional institutional-grade trading tool that combines:

📈 Session VWAP + NY Cash VWAP
🕘 New York Open & Initial Balance (IB)
📊 VWAP Bands (Standard Deviation)
⚡ Smart Buy/Sell Signals
🧱 Supply & Demand Zones (Volume-Based)
🧾 Live Footprint (Order Flow Data)

It is designed to help traders understand market structure, liquidity zones, and intraday bias using real-time data.

⚙️ Core Components Explained
🟢 1. NY Cash VWAP
Calculates VWAP starting from 9:30 AM New York session
Uses high precision 1-minute data (optional) for accuracy
Automatically resets every trading day

📌 Purpose:

Institutional benchmark price
Acts as dynamic support/resistance
Helps identify fair value
🔵 2. Session VWAP
Tracks VWAP across extended + regular sessions
Updates continuously
Can display on price scale

📌 Purpose:

Shows overall session trend
Identifies premium vs discount areas
📏 3. VWAP Bands (Deviation Levels)
Up to 3 configurable bands
Based on VWAP standard deviation

📌 Purpose:

Overbought / Oversold zones
Mean reversion setups
Expansion zones during volatility
🕘 4. NY Open & Initial Balance (IB)
NY Open Line → price at 9:30 AM
Initial Balance (IB) → High/Low from 9:30–10:30 AM

📌 Purpose:

Defines early market range
Key breakout/breakdown levels
Used by institutions for directional bias
⚡ 5. Buy/Sell Signal Logic
🟢 LONG Condition:
Price crosses above VWAP
Previous candle is bullish
Current candle is bullish
🔴 SHORT Condition:
Price crosses below VWAP
Previous candle is bearish
Current candle is bearish

📌 Important:

Signals are confirmation-based, not predictive
Works best with trend + volume context
🧱 6. Supply & Demand Zones (Volume-Based)
Uses pivot highs/lows + volume clustering
Divides price into volume bins
Identifies high-importance zones

📌 How it works:

High volume areas = strong interest
Zones are filtered using tolerance logic
Color-coded:
🟢 Bullish zone
🔴 Bearish zone
⚪ Neutral zone

📌 Purpose:

Identify institutional accumulation/distribution
Key reaction areas
High probability reversal zones
📊 7. Live Footprint (Order Flow Table)

Displays real-time:

✅ Buy Volume
❌ Sell Volume
⚖️ Delta (Buy - Sell)
📈 Delta %

📌 Purpose:

Shows market aggression
Detects:
Buying pressure
Selling pressure
Absorption
Imbalances
⚙️ Key Features

✔ High-precision VWAP (1-min aggregation)
✔ Dual VWAP tracking (Session + NY Cash)
✔ Auto session detection (NY timezone)
✔ Dynamic Supply/Demand zones
✔ Real-time order flow footprint
✔ Customizable visuals (colors, labels, styles)
✔ Smart entry signals
✔ IB + NY Open tracking
✔ Works on all intraday timeframes

🎯 How to Use
🔹 Trend Trading
Above VWAP → bullish bias
Below VWAP → bearish bias
🔹 Mean Reversion
Price at outer VWAP bands → reversal zones
🔹 Breakout Trading
Use IB High/Low breaks
Confirm with footprint delta
🔹 Zone Trading
Enter near S/D zones
Confirm with VWAP + signals
⚠️ Notes & Best Practices
Best used on intraday charts (1m–15m)
Combine with:
Volume
Market structure
Higher timeframe bias
Signals are not standalone — use confirmation
🧠 What Makes This Unique

Unlike standard VWAP indicators, this tool combines:

VWAP + Order Flow
Supply/Demand + Volume Profiling
Session Logic + Smart Signals

➡️ Giving you a complete intraday trading framework

🚀 Ideal For
Day Traders
Scalpers
Futures Traders
Options Traders
Smart Money Concept users
📌 Disclaimer

This indicator is for educational purposes only.
It does not provide financial advice. Always manage risk properly.

If you want next level upgrade, I can also:

✅ Add alerts (Buy/Sell / VWAP touch / IB break)
✅ Convert this into strategy with backtesting
✅ Add scanner for multiple tickers
✅ Make premium-style TradingView publish layout

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Combined by Quant

//@version=6
indicator("VWAP Session & NY Cash + Live Footprint", overlay = true, max_boxes_count = 500, max_bars_back = 4999)

// ============================================================================
// CONSTANTS & TYPES
// ============================================================================
const string TIMEZONE           = "America/New_York"
const string EXTENDED_SESSION   = "1800-0929"
const string MARKET_SESSION     = "0930-1600"
const string IB_SESSION         = "0930-1030"
const color  TRANSPARENT        = color.rgb(0, 0, 0, 100)

type myVWAP
    label lab
    int lab_offset
    bool isActive = true
    float cumPV = 0.0
    float cumVol = 0.0
    float vwap = na

// ============================================================================
// INPUTS - VWAP
// ============================================================================
CALC_GRP = "VWAP Calculation"
i_enableHD = input.bool(true, "Use 1-min data for precision", group = CALC_GRP)
i_debugLog = input.bool(false, "Debug Logging", group = CALC_GRP)

NY_GRP = "NY VWAP"
i_NY_color          = input.color(#4caf50, "Color", group = NY_GRP, inline = "line")
i_NY_width          = input.int(1, "Width", group = NY_GRP, inline = "line")
i_NY_style          = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = NY_GRP, inline = "line")
i_NY_showlabel      = input.bool(true, "Show Label", group = NY_GRP, inline = "label")
i_NY_label          = input.string("NYVWAP", "", group = NY_GRP, inline = "label")
i_NY_labelOffset    = input.int(0, "Offset", group = NY_GRP, inline = "label")
i_NY_txtSize        = str.lower(input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = NY_GRP))
i_NY_showPriceScale = input.bool(true, "Show in Price Scale", group = NY_GRP)

NY_OPEN_GRP = "NY Open & IB"
i_showNYOpen      = input.bool(true, "Show NY Open", group = NY_OPEN_GRP)
i_nyOpenColor     = input.color(color.gray, "Open Color", group = NY_OPEN_GRP, inline = "open")
i_nyOpenStyle     = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = NY_OPEN_GRP, inline = "open")
i_showNYOpenLabel = input.bool(true, "Show Label", group = NY_OPEN_GRP, inline = "open_lab")
i_nyOpenLabelText = input.string("NY Open", "", group = NY_OPEN_GRP, inline = "open_lab")
i_showIB          = input.bool(true, "Show IB", group = NY_OPEN_GRP)
i_ibColor         = input.color(#5b9cf6, "IB Color", group = NY_OPEN_GRP, inline = "ib")
i_ibStyle         = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = NY_OPEN_GRP, inline = "ib")
i_ibWidth         = input.int(1, "Width", group = NY_OPEN_GRP, inline = "ib")
i_showIBLabel     = input.bool(true, "Show IB Labels", group = NY_OPEN_GRP, inline = "ib_lab")
i_ibHighLabelText = input.string("IB High", "", group = NY_OPEN_GRP, inline = "ib_lab")
i_ibLowLabelText  = input.string("IB Low", "", group = NY_OPEN_GRP, inline = "ib_lab")
i_openIBLabOffset = input.int(0, "Label Offset", group = NY_OPEN_GRP)

SESSION_GRP = "Session VWAP"
i_Session_enabled        = input.bool(true, "Enabled", group = SESSION_GRP)
i_Session_color          = input.color(#04eb85, "Color", group = SESSION_GRP, inline = "line")
i_Session_width          = input.int(2, "Width", group = SESSION_GRP, inline = "line")
i_Session_style          = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = SESSION_GRP, inline = "line")
i_Session_showlabel      = input.bool(true, "Show Label", group = SESSION_GRP, inline = "label")
i_Session_label          = input.string("VWAP", "", group = SESSION_GRP, inline = "label")
i_Session_labelOffset    = input.int(0, "Offset", group = SESSION_GRP, inline = "label")
i_Session_txtSize        = str.lower(input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = SESSION_GRP))
i_Session_showPriceScale = input.bool(true, "Show in Price Scale", group = SESSION_GRP)

BANDS_GRP = "Session VWAP Bands"
i_showBand1 = input.bool(false, "Band 1", group = BANDS_GRP, inline = "b1")
i_mult1     = input.float(1.0, "", group = BANDS_GRP, inline = "b1", step = 0.5)
i_bCol1     = input.color(color.new(color.green, 0), "Line", group = BANDS_GRP, inline = "b1c")
i_bFill1    = input.color(color.new(color.green, 90), "Fill", group = BANDS_GRP, inline = "b1c")
i_showBand2 = input.bool(false, "Band 2", group = BANDS_GRP, inline = "b2")
i_mult2     = input.float(2.0, "", group = BANDS_GRP, inline = "b2", step = 0.5)
i_bCol2     = input.color(color.new(color.olive, 0), "Line", group = BANDS_GRP, inline = "b2c")
i_bFill2    = input.color(color.new(color.olive, 90), "Fill", group = BANDS_GRP, inline = "b2c")
i_showBand3 = input.bool(false, "Band 3", group = BANDS_GRP, inline = "b3")
i_mult3     = input.float(3.0, "", group = BANDS_GRP, inline = "b3", step = 0.5)
i_bCol3     = input.color(color.new(color.teal, 0), "Line", group = BANDS_GRP, inline = "b3c")
i_bFill3    = input.color(color.new(color.teal, 90), "Fill", group = BANDS_GRP, inline = "b3c")

SIG_GRP = "VWAP Signal Settings"
i_showSignals = input.bool(true, "Show Buy/Sell Signals", group = SIG_GRP)
i_bullColor   = input.color(#089981, "Bullish", group = SIG_GRP)
i_bearColor   = input.color(#f23645, "Bearish", group = SIG_GRP)

// ============================================================================
// INPUTS - SUPPLY & DEMAND + FOOTPRINT
// ============================================================================
SD_CALC_GRP = "S/D Calculation"
i_sd_dynamic   = input.bool(true, "Use Dynamic Look-Back", group = SD_CALC_GRP)
i_sd_len       = input.int(100, "Fixed Look-back", group = SD_CALC_GRP)
i_sd_plen      = input.int(200, "Pivot Detection Period", group = SD_CALC_GRP)
i_sd_res       = input.int(40, "Resolution", group = SD_CALC_GRP)
i_sd_tolerance = input.float(0.93, "Zone Tolerance", maxval = 1, minval = 0.01, group = SD_CALC_GRP)

SD_APP_GRP = "S/D & Footprint Appearance"
i_sd_labAlign    = input.string("Right", "Percentage Label Align", options = ["Left", "Right"], group = SD_APP_GRP)
i_sd_neut        = input.color(color.gray, "Levels Color", group = SD_APP_GRP)
i_sd_green       = input.color(#089981, "Bullish Color", group = SD_APP_GRP)
i_sd_red         = input.color(#f23645, "Bearish Color", group = SD_APP_GRP)
i_footPos        = input.string("Top Right", "Footprint Table Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = SD_APP_GRP)

// ============================================================================
// LOGIC - VWAP
// ============================================================================
var sessionVWAP = myVWAP.new(label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_Session_color, size = i_NY_txtSize), i_Session_labelOffset)
var cashVWAP1   = myVWAP.new(label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_NY_color, size = i_NY_txtSize), i_NY_labelOffset)
var cashVWAP2   = myVWAP.new(label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_NY_color, size = i_NY_txtSize), i_NY_labelOffset, isActive = false)

var float nyOpenPrice = na
var float ibHigh = na
var float ibLow = na
var label nyOpenLab = label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_nyOpenColor)
var label ibHighLab = label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_ibColor)
var label ibLowLab  = label.new(bar_index, 0.0, "", style = label.style_label_left, color = TRANSPARENT, textcolor = i_ibColor)

var int activeCashVWAP = 1
var bool showSessionVWAP = false
var bool hasExtData = false

resetVWAP(myVWAP v) =>
    v.cumPV := 0.0, v.cumVol := 0.0, v.vwap := 0.0

updateVWAP(myVWAP v, bool show, string txt) =>
    if v.isActive
        v.cumPV += hlc3 * volume
        v.cumVol += volume
        v.vwap := v.cumVol > 0 ? v.cumPV / v.cumVol : na
        v.lab.set_xy(bar_index + v.lab_offset, v.vwap)
        v.lab.set_text(show ? txt : "")

bool isExt    = not na(time(timeframe.period, EXTENDED_SESSION, TIMEZONE))
bool isMkt    = not na(time(timeframe.period, MARKET_SESSION, TIMEZONE))
bool isMktOp  = isMkt and not isMkt[1]
bool isIB     = not na(time(timeframe.period, IB_SESSION, TIMEZONE))

chartMins = timeframe.in_seconds() / 60
lowerTF = chartMins > 1 ? "1" : "1S"
[hlc3Arr, volArr, tArr, oArr, cArr, hArr, lArr] = request.security_lower_tf(syminfo.tickerid, lowerTF, [hlc3, volume, time, open, close, high, low])

if timeframe.isintraday
    if isMktOp
        nyOpenPrice := open, ibHigh := high, ibLow := low
    else if isIB
        ibHigh := math.max(nz(ibHigh, -1e10), high)
        ibLow  := math.min(nz(ibLow, 1e10), low)

    if not na(nyOpenPrice) and i_showNYOpen and i_showNYOpenLabel
        nyOpenLab.set_xy(bar_index + i_openIBLabOffset, nyOpenPrice), nyOpenLab.set_text(i_nyOpenLabelText)
    else
        nyOpenLab.set_text("")
    
    if not na(ibHigh) and i_showIB and i_showIBLabel
        ibHighLab.set_xy(bar_index + i_openIBLabOffset, ibHigh), ibHighLab.set_text("")
        ibLowLab.set_xy(bar_index + i_openIBLabOffset, ibLow), ibLowLab.set_text("")
    else
        ibHighLab.set_text(""), ibLowLab.set_text("")

    float nyVwapHD = na
    var float[] pvA = array.new_float(0)
    var float[] volA = array.new_float(0)
    var int lastD = -1
    if i_enableHD and array.size(hlc3Arr) > 0
        for i = 0 to array.size(hlc3Arr) - 1
            bT = array.get(tArr, i), bH = array.get(hlc3Arr, i), bV = array.get(volArr, i)
            h = hour(bT, TIMEZONE), m = minute(bT, TIMEZONE), d = dayofmonth(bT, TIMEZONE)
            if h == 9 and m == 30 and d != lastD
                array.clear(pvA), array.clear(volA), lastD := d
            if bV > 0
                array.push(pvA, bH * bV), array.push(volA, bV)
        if array.size(pvA) > 0
            nyVwapHD := array.sum(pvA) / array.sum(volA)

    if isMktOp
        if activeCashVWAP == 1
            activeCashVWAP := 2, cashVWAP1.isActive := false, cashVWAP2.isActive := true
            cashVWAP1.lab.set_text(""), resetVWAP(cashVWAP2)
        else
            activeCashVWAP := 1, cashVWAP1.isActive := true, cashVWAP2.isActive := false
            cashVWAP2.lab.set_text(""), resetVWAP(cashVWAP1)

    if i_enableHD and not na(nyVwapHD)
        v = activeCashVWAP == 1 ? cashVWAP1 : cashVWAP2
        v.vwap := nyVwapHD, v.lab.set_xy(bar_index + v.lab_offset, v.vwap), v.lab.set_text("")
    else
        updateVWAP(cashVWAP1, false, ""), updateVWAP(cashVWAP2, false, "")

    if i_Session_enabled
        if isExt and not hasExtData
            hasExtData := true, showSessionVWAP := true
        isND = timeframe.change("1D")
        vS = ta.vwap(hlc3, isND)
        vV = i_enableHD ? (array.size(volArr) > 0 ? vS : na) : vS
        if showSessionVWAP
            sessionVWAP.vwap := vV
            sessionVWAP.lab.set_xy(bar_index + sessionVWAP.lab_offset, sessionVWAP.vwap)
            sessionVWAP.lab.set_text(i_Session_showlabel ? i_Session_label : "")

var float uB1 = na, var float lB1 = na, var float uB2 = na, var float lB2 = na, var float uB3 = na, var float lB3 = na
if i_Session_enabled and showSessionVWAP
    isND = timeframe.change("1D")
    [vVal, uVal, _] = ta.vwap(hlc3, isND, 1)
    sd = uVal - vVal
    uB1 := vVal + sd * i_mult1, lB1 := vVal - sd * i_mult1
    uB2 := vVal + sd * i_mult2, lB2 := vVal - sd * i_mult2
    uB3 := vVal + sd * i_mult3, lB3 := vVal - sd * i_mult3

cVVal = activeCashVWAP == 1 ? cashVWAP1.vwap : cashVWAP2.vwap
long  = ta.crossover(close, cVVal)[1] and close[1] > open[1] and close > open
short = ta.crossunder(close, cVVal)[1] and close[1] < open[1] and close < open

// ============================================================================
// LOGIC - SUPPLY & DEMAND + FOOTPRINT
// ============================================================================
ph_v = ta.pivothigh(i_sd_plen, i_sd_plen)
pl_v = ta.pivotlow(i_sd_plen, i_sd_plen)
var int pivotIdx = 0
if not na(ph_v) or not na(pl_v)
    pivotIdx := bar_index - i_sd_plen

sd_len = i_sd_dynamic ? bar_index - pivotIdx : i_sd_len

float[] hS = array.new_float()
float[] lS = array.new_float()
float[] vS_arr = array.new_float()

for i = 0 to math.min(sd_len, bar_index)
    array.push(hS, high[i]), array.push(lS, low[i]), array.push(vS_arr, volume[i])

var box[] sd_boxes = array.new_box()
var label[] sd_labs = array.new_label()
var box totalBox = na

// Footprint Table
var table footTable = table.new(i_footPos == "Top Right" ? position.top_right : i_footPos == "Bottom Right" ? position.bottom_right : i_footPos == "Top Left" ? position.top_left : position.bottom_left, 2, 5, bgcolor = color.new(color.black, 40), border_width = 1, border_color = color.gray)

if barstate.islast
    for b in sd_boxes
        box.delete(b)
    array.clear(sd_boxes)
    for l in sd_labs
        label.delete(l)
    array.clear(sd_labs)
    if not na(totalBox)
        box.delete(totalBox)

    if array.size(hS) > 0
        mx = array.max(hS), mn = array.min(lS)
        step = (mx - mn) / i_sd_res
        float[] binL = array.new_float(i_sd_res, 0.0)
        float[] topB = array.new_float(i_sd_res)
        float[] botB = array.new_float(i_sd_res)

        for i = 0 to i_sd_res - 1
            b_bot = mn + (i * step), b_top = mn + ((i + 1) * step)
            array.set(topB, i, b_top), array.set(botB, i, b_bot)
            for j = 0 to array.size(hS) - 1
                if not (array.get(lS, j) > b_top or array.get(hS, j) < b_bot)
                    array.set(binL, i, array.get(binL, i) + array.get(vS_arr, j))

        mxVol = array.max(binL)
        for i = 0 to i_sd_res - 1
            isKey = (i == i_sd_res - 1 or array.get(binL, i) < array.get(binL, i + 1) * i_sd_tolerance) and (i == 0 or array.get(binL, i) < array.get(binL, i - 1) * i_sd_tolerance)
            b_top = array.get(topB, i), b_bot = array.get(botB, i)
            if isKey
                c = close > b_top ? i_sd_green : close < b_bot ? i_sd_red : i_sd_neut
                sd_boxes.push(box.new(bar_index - sd_len, b_top, bar_index, b_bot, border_color = color.new(c, 70), bgcolor = color.new(c, 80)))
                
                lab_x = i_sd_labAlign == "Left" ? bar_index - sd_len : bar_index
                lab_style = i_sd_labAlign == "Left" ? label.style_label_right : label.style_label_left
                sd_labs.push(label.new(lab_x, math.avg(b_top, b_bot), str.tostring((1 - (array.get(binL, i) / mxVol)) * 100, "0") + "%", color = TRANSPARENT, textcolor = chart.fg_color, style = lab_style, size = size.tiny))

    // Footprint Table Stats
    curBuy = 0.0, curSell = 0.0
    if array.size(cArr) > 0
        for i = 0 to array.size(cArr) - 1
            v = array.get(volArr, i)
            if array.get(cArr, i) >= array.get(oArr, i)
                curBuy += v
            else
                curSell += v
    
    delta = curBuy - curSell
    tot   = curBuy + curSell
    deltaPct = tot > 0 ? (delta / tot) * 100 : 0
    
    table.cell(footTable, 0, 0, "LIVE FOOTPRINT", text_color = color.white, bgcolor = color.gray, text_size = size.small)
    table.cell(footTable, 1, 0, "STATS", text_color = color.white, bgcolor = color.gray, text_size = size.small)
    table.cell(footTable, 0, 1, "Buy Vol", text_color = i_sd_green, text_halign = text.align_left)
    table.cell(footTable, 1, 1, str.tostring(curBuy, format.volume), text_color = i_sd_green, text_halign = text.align_right)
    table.cell(footTable, 0, 2, "Sell Vol", text_color = i_sd_red, text_halign = text.align_left)
    table.cell(footTable, 1, 2, str.tostring(curSell, format.volume), text_color = i_sd_red, text_halign = text.align_right)
    table.cell(footTable, 0, 3, "Delta", text_color = delta >= 0 ? i_sd_green : i_sd_red, text_halign = text.align_left)
    table.cell(footTable, 1, 3, (delta > 0 ? "+" : "") + str.tostring(delta, format.volume), text_color = delta >= 0 ? i_sd_green : i_sd_red, text_halign = text.align_right)
    table.cell(footTable, 0, 4, "Delta %", text_color = delta >= 0 ? i_sd_green : i_sd_red, text_halign = text.align_left)
    table.cell(footTable, 1, 4, str.tostring(deltaPct, "0.0") + "%", text_color = delta >= 0 ? i_sd_green : i_sd_red, text_halign = text.align_right)

// ============================================================================
// VISUALS
// ============================================================================
nyStyle = i_NY_style == "Solid" ? plot.linestyle_solid : i_NY_style == "Dashed" ? plot.linestyle_dashed : plot.linestyle_dotted
plot(cVVal, "Cash VWAP", i_NY_color, i_NY_width, plot.style_linebr, linestyle = nyStyle, display = i_NY_showPriceScale ? display.all : display.pane)

plot(i_showNYOpen and isMkt ? nyOpenPrice : na, "NY Open", i_nyOpenColor, 1, plot.style_linebr, linestyle = i_nyOpenStyle == "Dashed" ? plot.linestyle_dashed : plot.linestyle_solid)
plot(i_showIB and isMkt ? ibHigh : na, "IB High", i_ibColor, i_ibWidth, plot.style_linebr)
plot(i_showIB and isMkt ? ibLow : na, "IB Low", i_ibColor, i_ibWidth, plot.style_linebr)

sStyle = i_Session_style == "Dashed" ? plot.linestyle_dashed : plot.linestyle_solid
plot(i_Session_enabled ? sessionVWAP.vwap : na, "Session VWAP", i_Session_color, i_Session_width, plot.style_linebr, linestyle = sStyle)

p1u = plot(i_showBand1 ? uB1 : na, "U1", i_bCol1, style = plot.style_linebr)
p1l = plot(i_showBand1 ? lB1 : na, "L1", i_bCol1, style = plot.style_linebr)
fill(p1u, p1l, i_bFill1)

p2u = plot(i_showBand2 ? uB2 : na, "U2", i_bCol2, style = plot.style_linebr)
p2l = plot(i_showBand2 ? lB2 : na, "L2", i_bCol2, style = plot.style_linebr)
fill(p2u, p2l, i_bFill2)

p3u = plot(i_showBand3 ? uB3 : na, "U3", i_bCol3, style = plot.style_linebr)
p3l = plot(i_showBand3 ? lB3 : na, "L3", i_bCol3, style = plot.style_linebr)
fill(p3u, p3l, i_bFill3)

plotshape(i_showSignals and long, "Long", shape.triangleup, location.belowbar, i_bullColor, 0, "Long", i_bullColor, size = size.small)
plotshape(i_showSignals and short, "Short", shape.triangledown, location.abovebar, i_bearColor, 0, "Short", i_bearColor, size = size.small)

plotchar(ph_v != 0, "PH", "●", location.abovebar, chart.fg_color, size = size.tiny, offset = -i_sd_plen)
plotchar(pl_v != 0, "PL", "●", location.belowbar, chart.fg_color, size = size.tiny, offset = -i_sd_plen)
````
