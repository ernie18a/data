# Institutional Fibonacci + Elliott Wave

- url: https://www.tradingview.com/script/05vkuC7b-Institutional-Fibonacci-Elliott-Wave/
- type: indicator
- pine_id: PUB;1ca6a101824840e4905d2f6e88a31de7
- version: 1.0

## Description

Institutional Fibonacci + Elliott Wave — Indicator Description
Overview
This indicator combines three powerful technical analysis tools into a single overlay: Fibonacci retracement/extension levels, Elliott Wave detection, and a Volume Point of Control (POC) line. It is designed to help traders identify high-probability entry zones, validate wave structure, and project take-profit targets with institutional-grade precision.

Core Components
1. Fibonacci Retracement & Extension Levels
The indicator automatically detects the most recent confirmed swing high and swing low using a configurable pivot length, then draws the full Fibonacci grid from that range.
Retracement levels (entry/pullback zones):

0.236, 0.382, 0.500, 0.618 (Golden Ratio), 0.705 (Institutional), 0.786 (Deep), 0.886 (Extreme)

Extension levels (take-profit targets):

1.000 (TP1 — equal move), 1.272 (TP2 — Wave 3 target), 1.618 (TP3 — Golden Extension), 2.000 (TP4), 2.618 (TP5)

The Golden Zone (0.618–0.786) is highlighted with a shaded box — historically the highest-probability reversal area in trending markets. A TP1 zone box is also drawn around the 1.000 extension.
Direction is set automatically: if the most recent confirmed pivot was a high, the grid is drawn bullish (low → high); if a low, it draws bearish (high → low). Every level includes an optional price label and percentage distance from the 0.618 entry.

2. Elliott Wave Detection
The indicator scans recent pivot history for a valid 5-wave impulse pattern, applying the three core Elliott Wave rules:

Wave 2 never retraces beyond the start of Wave 1
Wave 3 is never the shortest impulse wave
Wave 4 does not overlap Wave 1's price territory

When a pattern is confirmed, it draws labeled wave points (W1–W5) connected by colored lines — solid cyan for impulse waves, dashed orange for corrective waves. It also projects forward targets:

W5 Min / W5 Max — expected completion range for Wave 5
ABC-C — the likely endpoint of the subsequent corrective wave

Both bullish and bearish impulse structures are detected.

3. Point of Control (POC)
The POC line marks the price level with the highest traded volume over a configurable lookback window (default: 300 bars). It is calculated by dividing the price range into buckets and finding the bucket with the most cumulative volume — similar to a simplified volume profile.
The POC acts as a strong support/resistance magnet. Price tends to revisit and consolidate around it, making it useful for:

Confirming Fibonacci entry zones when POC aligns with the 0.618–0.786 area
Identifying likely reversal points if price is extended far from POC


4. Information Table
A compact on-chart table (position configurable) displays:

All 7 key price levels (0.618 entry through 2.618 TP5) with current prices and % move from the 0.618 entry
Elliott Wave phase status (Scanning / Bullish Impulse / Bearish Impulse)
Wave rule validation confirmation


How to Use It
Entering a trade:
Watch for price to pull back into the Golden Zone (0.618–0.786). If the POC line sits inside or near that zone, confluence is strong. Look for a reversal candle or momentum confirmation before entering.
Setting targets:
Use the extension levels from the table as a tiered take-profit plan — partial exit at TP1 (1.000), scale out at TP2 (1.272), and let runners run toward TP3 (1.618) or beyond.
Elliott Wave confluence:
If the indicator detects a bullish impulse and you are entering near the Wave 4 zone (between W3 and W4 labels), the W5 Min/Max projections give you a forward price target range that aligns with the extension levels.
Alerts:
Five built-in alerts are available — Golden Zone entry, TP1/TP2/TP3 hits, Elliott Wave confirmation, and a POC touch — configurable directly from TradingView's alert system.

Key Settings
Setting Default Notes Pivot Swing Length21Higher = fewer, more significant swings EW Pivot Length21Match to Swing Length for consistency POC Lookback300 bars Increase for longer-term POC Price Buckets200Higher = more precise POC, heavier CPU load Show Golden Zone On Recommended to leave on Show % from Entry On Shows distance from 0.618 for each level

Best Practices

Works on any timeframe and instrument (stocks, forex, crypto, futures)
Higher timeframes (4H, Daily) produce more reliable pivot detections
Elliott Wave detection is most reliable in trending, impulsive markets — use with caution in choppy, ranging conditions
Confluence of a Fibonacci level + POC + Elliott Wave count is the strongest signal this indicator can produce

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Institutional Fibonacci + Elliott Wave Complete v2.0

//@version=6
indicator('Institutional Fibonacci + Elliott Wave', overlay = true, max_lines_count = 500, max_labels_count = 200, max_boxes_count = 50)

// ══════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════
grp1 = 'Fibonacci Settings'
swingLen = input.int(21, 'Pivot Swing Length', minval = 5, maxval = 100, group = grp1)
showFibZone = input.bool(true, 'Show Golden Zone (0.618-0.786)', group = grp1)
fibLineWid = input.int(1, 'Line Width', minval = 1, maxval = 3, group = grp1)
fibStyle = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = grp1)

grp2 = 'Fibonacci Levels'
fib_236 = input.bool(true, '0.236 (Minor)', group = grp2)
fib_382 = input.bool(true, '0.382 (Major)', group = grp2)
fib_500 = input.bool(true, '0.500 (50%)', group = grp2)
fib_618 = input.bool(true, '0.618 (Golden Ratio)', group = grp2)
fib_705 = input.bool(true, '0.705 (Institutional)', group = grp2)
fib_786 = input.bool(true, '0.786 (Deep)', group = grp2)
fib_886 = input.bool(false, '0.886 (Extreme)', group = grp2)
fib_100 = input.bool(true, '1.000 (TP1 - Equal Move)', group = grp2)
fib_127 = input.bool(true, '1.272 (TP2 - Wave 3)', group = grp2)
fib_161 = input.bool(true, '1.618 (TP3 - Golden Ext.)', group = grp2)
fib_200 = input.bool(false, '2.000 (TP4 - Double)', group = grp2)
fib_261 = input.bool(false, '2.618 (TP5 - Extreme)', group = grp2)

grp3 = 'Elliott Wave Settings'
ewLen = input.int(21, 'EW Pivot Length', minval = 5, maxval = 100, group = grp3)
showEW = input.bool(true, 'Show Elliott Wave Labels', group = grp3)
showEWLines = input.bool(true, 'Show Wave Lines', group = grp3)
showEWInfo = input.bool(true, 'Show Wave Rules Panel', group = grp3)
ewImpulse = input.color(color.new(#00E5FF, 0), 'Impulse Wave Color', group = grp3)
ewCorrect = input.color(color.new(#FF9800, 0), 'Corrective Wave Color', group = grp3)

grp4 = 'Take Profit Zones'
showTP = input.bool(true, 'Show TP Zone Boxes', group = grp4)
tp1Col = input.color(color.new(#00E5FF, 80), 'TP1 Color', group = grp4)

grp5 = 'Display'
showLabels = input.bool(true, 'Show Price Labels', group = grp5)
showPct = input.bool(true, 'Show % from Entry', group = grp5)
tblPos = input.string('Top Right', 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = grp5)

grp6 = 'Point of Control (POC)'
showPOC = input.bool(true, 'Show POC Line', group = grp6)
pocLen = input.int(300, 'POC Lookback (bars)', minval = 10, maxval = 5000, group = grp6)
pocRes = input.int(200, 'Price Buckets', minval = 50, maxval = 500, group = grp6)
pocColor = input.color(color.new(#FF1744, 0), 'POC Line Color', group = grp6)
pocWidth = input.int(2, 'POC Line Width', minval = 1, maxval = 4, group = grp6)
showPOCLbl = input.bool(true, 'Show POC Label', group = grp6)

// ══════════════════════════════════════════════════════════════════
// LINE STYLE HELPER
// ══════════════════════════════════════════════════════════════════
getLineStyle() =>
    fibStyle == 'Dashed' ? line.style_dashed : fibStyle == 'Dotted' ? line.style_dotted : line.style_solid

// ══════════════════════════════════════════════════════════════════
// SWING PIVOT DETECTION
// Track the most recent confirmed swing high and swing low,
// plus the one before each — so we always have a valid high-to-low
// or low-to-high range to draw Fibonacci from.
// ══════════════════════════════════════════════════════════════════
pivHigh = ta.pivothigh(high, swingLen, swingLen)
pivLow = ta.pivotlow(low, swingLen, swingLen)

var float sh1 = na // most recent swing high price
var float sh2 = na // previous swing high price
var int shb1 = na // most recent swing high bar
var int shb2 = na

var float sl1 = na // most recent swing low price
var float sl2 = na // previous swing low price
var int slb1 = na
var int slb2 = na

if not na(pivHigh)
    sh2 := sh1
    shb2 := shb1
    sh1 := pivHigh
    shb1 := bar_index - swingLen
    shb1

if not na(pivLow)
    sl2 := sl1
    slb2 := slb1
    sl1 := pivLow
    slb1 := bar_index - swingLen
    slb1

// Determine direction: whichever pivot confirmed most recently sets direction
// bullFib = last pivot was a HIGH  → draw from swing low UP to swing high
// bearFib = last pivot was a LOW   → draw from swing high DOWN to swing low
bullFib = not na(sh1) and not na(sl1) and shb1 > slb1
bearFib = not na(sh1) and not na(sl1) and slb1 > shb1

fibHigh = bullFib ? sh1 : bearFib ? sh1 : sh1
fibLow = bullFib ? sl1 : bearFib ? sl1 : sl1
fibHBar = bullFib ? shb1 : shb1
fibLBar = bullFib ? slb1 : slb1
fibRange = fibHigh - fibLow

// ══════════════════════════════════════════════════════════════════
// FIBONACCI PRICE CALCULATORS
// Retracement: measures back INTO the move (entry zones)
// Extension:   measures BEYOND the move (take profit zones)
// ══════════════════════════════════════════════════════════════════
fibLevel(ratio, isBull) =>
    // Retracement from the END of the move back toward the start
    isBull ? fibHigh - fibRange * ratio : fibLow + fibRange * ratio

fibExtLevel(ratio, isBull) =>
    // Extension BEYOND the start of the move
    isBull ? fibLow + fibRange * ratio : fibHigh - fibRange * ratio

// ══════════════════════════════════════════════════════════════════
// FIB LEVEL DEFINITIONS
// ══════════════════════════════════════════════════════════════════
var array<float> FL_RATIO = array.new_float(0)
var array<string> FL_NAME = array.new_string(0)
var array<color> FL_COLOR = array.new_color(0)
var array<bool> FL_ON = array.new_bool(0)

if barstate.isfirst
    array.push(FL_RATIO, 0.000)
    array.push(FL_NAME, '0.000 Origin')
    array.push(FL_COLOR, color.new(color.white, 30))
    array.push(FL_ON, true)
    array.push(FL_RATIO, 0.236)
    array.push(FL_NAME, '0.236')
    array.push(FL_COLOR, color.new(#64B5F6, 0))
    array.push(FL_ON, fib_236)
    array.push(FL_RATIO, 0.382)
    array.push(FL_NAME, '0.382 Major')
    array.push(FL_COLOR, color.new(#42A5F5, 0))
    array.push(FL_ON, fib_382)
    array.push(FL_RATIO, 0.500)
    array.push(FL_NAME, '0.500 Mid')
    array.push(FL_COLOR, color.new(#FFFFFF, 10))
    array.push(FL_ON, fib_500)
    array.push(FL_RATIO, 0.618)
    array.push(FL_NAME, '0.618 Golden')
    array.push(FL_COLOR, color.new(#FFD700, 0))
    array.push(FL_ON, fib_618)
    array.push(FL_RATIO, 0.705)
    array.push(FL_NAME, '0.705 Institutional')
    array.push(FL_COLOR, color.new(#FFC107, 0))
    array.push(FL_ON, fib_705)
    array.push(FL_RATIO, 0.786)
    array.push(FL_NAME, '0.786 Deep')
    array.push(FL_COLOR, color.new(#FF9800, 0))
    array.push(FL_ON, fib_786)
    array.push(FL_RATIO, 0.886)
    array.push(FL_NAME, '0.886 Extreme')
    array.push(FL_COLOR, color.new(#FF5722, 0))
    array.push(FL_ON, fib_886)
    array.push(FL_RATIO, 1.000)
    array.push(FL_NAME, '1.000 TP1')
    array.push(FL_COLOR, color.new(#4CAF50, 0))
    array.push(FL_ON, fib_100)
    array.push(FL_RATIO, 1.272)
    array.push(FL_NAME, '1.272 TP2')
    array.push(FL_COLOR, color.new(#00BCD4, 0))
    array.push(FL_ON, fib_127)
    array.push(FL_RATIO, 1.618)
    array.push(FL_NAME, '1.618 TP3')
    array.push(FL_COLOR, color.new(#E040FB, 0))
    array.push(FL_ON, fib_161)
    array.push(FL_RATIO, 2.000)
    array.push(FL_NAME, '2.000 TP4')
    array.push(FL_COLOR, color.new(#9C27B0, 0))
    array.push(FL_ON, fib_200)
    array.push(FL_RATIO, 2.618)
    array.push(FL_NAME, '2.618 TP5')
    array.push(FL_COLOR, color.new(#673AB7, 0))
    array.push(FL_ON, fib_261)

// ══════════════════════════════════════════════════════════════════
// DRAW FIBONACCI — redraw every bar so lines persist on chart
// ══════════════════════════════════════════════════════════════════
var array<line> fibLines = array.new_line(0)
var array<label> fibLabels = array.new_label(0)
var array<box> fibBoxes = array.new_box(0)

// Redraw every bar (not just islast) so they stay visible
if not na(fibHigh) and not na(fibLow) and fibRange > 0
    // Delete old drawings
    for ln in fibLines
        line.delete(ln)
    array.clear(fibLines)
    for lb in fibLabels
        label.delete(lb)
    array.clear(fibLabels)
    for bx in fibBoxes
        box.delete(bx)
    array.clear(fibBoxes)

    startBar = math.min(fibHBar, fibLBar)
    endBar = bar_index + 20
    isBull = bullFib
    lstyle = getLineStyle()
    entry0 = fibLevel(0.618, isBull)

    // Golden Zone box
    if showFibZone and fib_618 and fib_786
        gz_hi = math.max(fibLevel(0.618, isBull), fibLevel(0.786, isBull))
        gz_lo = math.min(fibLevel(0.618, isBull), fibLevel(0.786, isBull))
        array.push(fibBoxes, box.new(startBar, gz_hi, endBar, gz_lo, border_color = color.new(#FFD700, 40), bgcolor = color.new(#FFD700, 88), border_width = 1))

    // TP1 zone box
    if showTP and fib_100
        tp1p = fibExtLevel(1.000, isBull)
        array.push(fibBoxes, box.new(startBar, math.max(tp1p, fibExtLevel(1.050, isBull)), endBar, math.min(tp1p, fibExtLevel(0.950, isBull)), border_color = color.new(#00E5FF, 30), bgcolor = tp1Col, border_width = 1))

    // Draw each active level
    for i = 0 to array.size(FL_RATIO) - 1 by 1
        if array.get(FL_ON, i)
            ratio = array.get(FL_RATIO, i)
            lvlName = array.get(FL_NAME, i)
            lvlColor = array.get(FL_COLOR, i)
            isExt = ratio > 1.0
            price = isExt ? fibExtLevel(ratio, isBull) : fibLevel(ratio, isBull)
            lw = isExt ? math.min(fibLineWid + 1, 4) : fibLineWid
            array.push(fibLines, line.new(startBar, price, endBar, price, color = lvlColor, width = lw, style = lstyle))

            if showLabels
                pctPart = ''
                if showPct and not na(entry0) and entry0 != 0.0
                    pctVal = math.round((price - entry0) / math.abs(entry0) * 1000.0) / 10.0
                    pctPart := ' | ' + str.tostring(pctVal) + '%'
                    pctPart
                lblTxt = lvlName + '  ' + str.tostring(math.round(price * 100.0) / 100.0) + pctPart
                array.push(fibLabels, label.new(endBar, price, lblTxt, style = label.style_label_left, color = color.new(color.black, 80), textcolor = lvlColor, size = size.small))

// ══════════════════════════════════════════════════════════════════
// ELLIOTT WAVE — PIVOT HISTORY
// ══════════════════════════════════════════════════════════════════
var array<float> ew_prices = array.new_float(0)
var array<int> ew_bars = array.new_int(0)
var array<bool> ew_isHigh = array.new_bool(0)

ewPivH = ta.pivothigh(high, ewLen, ewLen)
ewPivL = ta.pivotlow(low, ewLen, ewLen)

if not na(ewPivH)
    array.push(ew_prices, ewPivH)
    array.push(ew_bars, bar_index - ewLen)
    array.push(ew_isHigh, true)
    if array.size(ew_prices) > 12
        array.shift(ew_prices)
        array.shift(ew_bars)
        array.shift(ew_isHigh)

if not na(ewPivL)
    array.push(ew_prices, ewPivL)
    array.push(ew_bars, bar_index - ewLen)
    array.push(ew_isHigh, false)
    if array.size(ew_prices) > 12
        array.shift(ew_prices)
        array.shift(ew_bars)
        array.shift(ew_isHigh)

// ══════════════════════════════════════════════════════════════════
// ELLIOTT WAVE — PERSISTENT STATE
// ══════════════════════════════════════════════════════════════════
var bool ew_found = false
var bool ew_bull = false
var float ew_ws1 = na
var float ew_we1 = na
var float ew_we2 = na
var float ew_we3 = na
var float ew_we4 = na
var float ew_we5 = na
var int ew_b0 = na
var int ew_b1 = na
var int ew_b2 = na
var int ew_b3 = na
var int ew_b4 = na
var int ew_b5 = na
var string ewPhase = 'Scanning...'

// ══════════════════════════════════════════════════════════════════
// ELLIOTT WAVE — DETECTION
// ══════════════════════════════════════════════════════════════════
n = array.size(ew_prices)
if n >= 6
    p0 = array.get(ew_prices, n - 6)
    p1 = array.get(ew_prices, n - 5)
    p2 = array.get(ew_prices, n - 4)
    p3 = array.get(ew_prices, n - 3)
    p4 = array.get(ew_prices, n - 2)
    p5 = array.get(ew_prices, n - 1)
    h0 = array.get(ew_isHigh, n - 6)
    h1 = array.get(ew_isHigh, n - 5)
    h2 = array.get(ew_isHigh, n - 4)
    h3 = array.get(ew_isHigh, n - 3)
    h4 = array.get(ew_isHigh, n - 2)
    h5 = array.get(ew_isHigh, n - 1)
    r0 = array.get(ew_bars, n - 6)
    r1 = array.get(ew_bars, n - 5)
    r2 = array.get(ew_bars, n - 4)
    r3 = array.get(ew_bars, n - 3)
    r4 = array.get(ew_bars, n - 2)
    r5 = array.get(ew_bars, n - 1)

    // Bullish impulse: Low-High-Low-High-Low-High
    if not h0 and h1 and not h2 and h3 and not h4 and h5
        w1v = p1 - p0
        w3v = p3 - p2
        w5v = p5 - p4
        if p2 > p0 and w3v >= w1v and w3v >= w5v and p4 > p1
            ew_found := true
            ew_bull := true
            ew_ws1 := p0
            ew_we1 := p1
            ew_we2 := p2
            ew_we3 := p3
            ew_we4 := p4
            ew_we5 := p5
            ew_b0 := r0
            ew_b1 := r1
            ew_b2 := r2
            ew_b3 := r3
            ew_b4 := r4
            ew_b5 := r5
            ewPhase := 'Bullish Impulse'
            ewPhase

    // Bearish impulse: High-Low-High-Low-High-Low
    if h0 and not h1 and h2 and not h3 and h4 and not h5
        w1v = p0 - p1
        w3v = p2 - p3
        w5v = p4 - p5
        if p2 < p0 and w3v >= w1v and w3v >= w5v and p4 < p1
            ew_found := true
            ew_bull := false
            ew_ws1 := p0
            ew_we1 := p1
            ew_we2 := p2
            ew_we3 := p3
            ew_we4 := p4
            ew_we5 := p5
            ew_b0 := r0
            ew_b1 := r1
            ew_b2 := r2
            ew_b3 := r3
            ew_b4 := r4
            ew_b5 := r5
            ewPhase := 'Bearish Impulse'
            ewPhase

// ══════════════════════════════════════════════════════════════════
// DRAW ELLIOTT WAVE — redraw every bar so it persists
// ══════════════════════════════════════════════════════════════════
var array<line> ewLines = array.new_line(0)
var array<label> ewLabels = array.new_label(0)

if ew_found and showEW
    for l in ewLines
        line.delete(l)
    array.clear(ewLines)
    for lb in ewLabels
        label.delete(lb)
    array.clear(ewLabels)

    wPrices = array.new_float(6)
    wBars = array.new_int(6)
    array.set(wPrices, 0, ew_ws1)
    array.set(wBars, 0, ew_b0)
    array.set(wPrices, 1, ew_we1)
    array.set(wBars, 1, ew_b1)
    array.set(wPrices, 2, ew_we2)
    array.set(wBars, 2, ew_b2)
    array.set(wPrices, 3, ew_we3)
    array.set(wBars, 3, ew_b3)
    array.set(wPrices, 4, ew_we4)
    array.set(wBars, 4, ew_b4)
    array.set(wPrices, 5, ew_we5)
    array.set(wBars, 5, ew_b5)

    if showEWLines
        for i = 0 to 4 by 1
            p1v = array.get(wPrices, i)
            p2v = array.get(wPrices, i + 1)
            br1 = array.get(wBars, i)
            br2 = array.get(wBars, i + 1)
            isImp = i == 0 or i == 2 or i == 4
            wCol = isImp ? ewImpulse : ewCorrect
            wSty = isImp ? line.style_solid : line.style_dashed
            array.push(ewLines, line.new(br1, p1v, br2, p2v, color = wCol, width = 2, style = wSty))

    waveNames = array.from('W1', 'W2', 'W3', 'W4', 'W5', 'W5')
    for i = 0 to 5 by 1
        wp = array.get(wPrices, i)
        wb = array.get(wBars, i)
        wn = array.get(waveNames, i)
        isCorr = i == 1 or i == 3
        wc = isCorr ? ewCorrect : ewImpulse
        lst = isCorr ? label.style_label_down : label.style_label_up
        array.push(ewLabels, label.new(wb, wp, wn, style = lst, color = color.new(wc, 20), textcolor = color.white, size = size.large))

    if ew_bull
        w1range = ew_we1 - ew_ws1
        w5_min = ew_we4 + w1range * 0.618
        w5_max = ew_we4 + w1range * 1.000
        abc_c = ew_we4 - (ew_we5 - ew_we4) * 0.618
        array.push(ewLines, line.new(ew_b5, w5_min, bar_index + 15, w5_min, color = color.new(#4CAF50, 30), width = 1, style = line.style_solid))
        array.push(ewLines, line.new(ew_b5, w5_max, bar_index + 15, w5_max, color = color.new(#00BCD4, 30), width = 1, style = line.style_solid))
        array.push(ewLines, line.new(ew_b5, abc_c, bar_index + 25, abc_c, color = color.new(#FF9800, 40), width = 1, style = line.style_solid))
        array.push(ewLabels, label.new(bar_index + 15, w5_min, 'W5 Min', style = label.style_label_left, color = color.new(#4CAF50, 30), textcolor = color.white, size = size.small))
        array.push(ewLabels, label.new(bar_index + 15, w5_max, 'W5 Max', style = label.style_label_left, color = color.new(#00BCD4, 30), textcolor = color.white, size = size.small))
        array.push(ewLabels, label.new(bar_index + 25, abc_c, 'ABC-C', style = label.style_label_left, color = color.new(#FF9800, 30), textcolor = color.white, size = size.small))

// ══════════════════════════════════════════════════════════════════
// TAKE PROFIT INFO TABLE
// ══════════════════════════════════════════════════════════════════
tblPosition = switch tblPos
    'Top Left' => position.top_left
    'Bottom Right' => position.bottom_right
    'Bottom Left' => position.bottom_left
    => position.top_right

var table tpTable = table.new(tblPosition, 3, 12, bgcolor = color.new(color.black, 65), border_color = color.new(color.gray, 50), border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)

if barstate.islast and not na(fibHigh) and not na(fibLow)
    isBull = bullFib
    entry = fibLevel(0.618, isBull)

    table.cell(tpTable, 0, 0, 'INSTITUTIONAL FIBONACCI', text_color = color.white, text_size = size.normal, bgcolor = color.new(color.navy, 20))
    table.cell(tpTable, 1, 0, '', bgcolor = color.new(color.navy, 20))
    table.cell(tpTable, 2, 0, '', bgcolor = color.new(color.navy, 20))
    table.merge_cells(tpTable, 0, 0, 2, 0)
    table.cell(tpTable, 0, 1, 'Level', text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.gray, 80))
    table.cell(tpTable, 1, 1, 'Price', text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.gray, 80))
    table.cell(tpTable, 2, 1, '% Move', text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.gray, 80))

    tp_names = array.from('0.618 Entry', '0.786 Entry', '1.000 TP1', '1.272 TP2', '1.618 TP3', '2.000 TP4', '2.618 TP5')
    tp_prices = array.new_float(7)
    array.set(tp_prices, 0, fibLevel(0.618, isBull))
    array.set(tp_prices, 1, fibLevel(0.786, isBull))
    array.set(tp_prices, 2, fibExtLevel(1.000, isBull))
    array.set(tp_prices, 3, fibExtLevel(1.272, isBull))
    array.set(tp_prices, 4, fibExtLevel(1.618, isBull))
    array.set(tp_prices, 5, fibExtLevel(2.000, isBull))
    array.set(tp_prices, 6, fibExtLevel(2.618, isBull))

    for i = 0 to 6 by 1
        lvName = array.get(tp_names, i)
        lvPrice = array.get(tp_prices, i)
        rowBg = color.from_gradient(i, 0, 6, color.new(#1A237E, 50), color.new(#4A148C, 50))
        pctMove = 0.0
        if not na(entry) and entry != 0.0
            pctMove := math.round((lvPrice - entry) / math.abs(entry) * 1000.0) / 10.0
            pctMove
        pctStr = (pctMove >= 0.0 ? '+' : '') + str.tostring(pctMove) + '%'
        pctCol = pctMove >= 0.0 ? color.new(#00E5FF, 0) : color.new(#FF5252, 0)
        table.cell(tpTable, 0, i + 2, lvName, text_color = color.white, text_size = size.small, bgcolor = rowBg)
        table.cell(tpTable, 1, i + 2, str.tostring(math.round(lvPrice * 100.0) / 100.0), text_color = color.white, text_size = size.small, bgcolor = rowBg)
        table.cell(tpTable, 2, i + 2, pctStr, text_color = pctCol, text_size = size.small, bgcolor = rowBg)

    table.cell(tpTable, 0, 9, 'ELLIOTT WAVE', text_color = color.white, text_size = size.normal, bgcolor = color.new(color.navy, 20))
    table.cell(tpTable, 1, 9, '', bgcolor = color.new(color.navy, 20))
    table.cell(tpTable, 2, 9, '', bgcolor = color.new(color.navy, 20))
    table.merge_cells(tpTable, 0, 9, 2, 9)
    table.cell(tpTable, 0, 10, 'Phase', text_color = color.gray, text_size = size.small)
    table.cell(tpTable, 1, 10, ewPhase, text_color = ew_found ? color.green : color.orange, text_size = size.small)
    table.cell(tpTable, 2, 10, '', text_size = size.small)
    table.merge_cells(tpTable, 1, 10, 2, 10)

    if showEWInfo
        rulesTxt = ew_found ? 'All 3 EW rules validated' : 'Scanning for 5-wave pattern'
        table.cell(tpTable, 0, 11, rulesTxt, text_color = ew_found ? color.green : color.gray, text_size = size.small, bgcolor = color.new(color.black, 60))
        table.cell(tpTable, 1, 11, '', bgcolor = color.new(color.black, 60))
        table.cell(tpTable, 2, 11, '', bgcolor = color.new(color.black, 60))
        table.merge_cells(tpTable, 0, 11, 2, 11)

// ══════════════════════════════════════════════════════════════════
// POINT OF CONTROL (POC)
// ══════════════════════════════════════════════════════════════════
pocHH = ta.highest(high, pocLen)
pocLL = ta.lowest(low, pocLen)

var line pocLine = na
var label pocLabel = na

if showPOC
    line.delete(pocLine)
    label.delete(pocLabel)
    rangeSize = pocHH - pocLL
    bucketH = rangeSize / pocRes
    volBuckets = array.new_float(pocRes, 0.0)
    for i = 0 to pocLen - 1 by 1
        if bar_index - i >= 0
            barMid = (high[i] + low[i]) / 2.0
            if bucketH > 0
                bucketIdx = math.max(0, math.min(math.floor((barMid - pocLL) / bucketH), pocRes - 1))
                array.set(volBuckets, bucketIdx, array.get(volBuckets, bucketIdx) + volume[i])
    maxBucket = array.indexof(volBuckets, array.max(volBuckets))
    pocPrice = pocLL + (maxBucket + 0.5) * bucketH
    pocLine := line.new(bar_index - pocLen + 1, pocPrice, bar_index + 20, pocPrice, color = pocColor, width = pocWidth, style = line.style_solid)
    if showPOCLbl
        pocLabel := label.new(bar_index + 20, pocPrice, 'POC  ' + str.tostring(math.round(pocPrice * 100) / 100), style = label.style_label_left, color = color.new(color.black, 70), textcolor = pocColor, size = size.small)
        pocLabel

// ══════════════════════════════════════════════════════════════════
// PIVOT MARKERS
// ══════════════════════════════════════════════════════════════════
plotshape(not na(pivHigh) and showEW, title = 'Pivot High', style = shape.circle, location = location.abovebar, color = color.new(#FF5252, 20), size = size.tiny)
plotshape(not na(pivLow) and showEW, title = 'Pivot Low', style = shape.circle, location = location.belowbar, color = color.new(#00E5FF, 20), size = size.tiny)

// ══════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════
_fibReady = not na(fibHigh) and not na(fibLow)
alertcondition(_fibReady and ta.crossover(close, fibExtLevel(1.000, bullFib)), 'TP1 Hit (1.000)', 'Fibonacci TP1 reached!')
alertcondition(_fibReady and ta.crossover(close, fibExtLevel(1.272, bullFib)), 'TP2 Hit (1.272)', 'Fibonacci TP2 reached!')
alertcondition(_fibReady and ta.crossover(close, fibExtLevel(1.618, bullFib)), 'TP3 Hit (1.618)', 'Fibonacci TP3 Golden Extension reached!')
alertcondition(_fibReady and ta.crossunder(close, fibLevel(0.618, bullFib)), 'Golden Zone Entry', 'Price entered Fibonacci Golden Zone!')
alertcondition(ew_found, 'Elliott Wave Detected', 'Elliott Wave 5-wave impulse confirmed!')
pocAlertPrice = ta.valuewhen(volume == ta.highest(volume, pocLen), close, 0)
alertcondition(showPOC and math.abs(close - pocAlertPrice) / pocAlertPrice < 0.001, 'Price at POC', 'Price is testing the Point of Control!')
````
