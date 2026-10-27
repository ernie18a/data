# BANGU$ 1

- url: https://www.tradingview.com/script/9Ttf2qpw-BANGU-1/
- type: indicator
- pine_id: PUB;66d140da6dd04a82b042ea264de1f1df
- version: 1.0

## Description

MSB, OB, FVG & Liquidity Signals
HTF-LTF fvg’s, EMA’s and VWAP

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo / EmreKb (Combined and Modified)

//@version=6
indicator("MSB, OB, FVG & Liquidity Signals", "Combined Strategy", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 4900)

// --- Groups ---
G_MSB  = "Market Structure & Order Blocks"
G_FVG  = "Fair Value Gaps"
G_EMA  = "EMA & VWAP"
G_SES  = "Session Levels"
G_SIG  = "Liquidity & Signals"

// --- Inputs ---
// MSB & OB
zigzagLen      = input.int(9, "ZigZag Length", group = G_MSB)
fibFactor      = input.float(0.33, "Breakout Confirmation (Fib)", 0, 1, 0.01, group = G_MSB)
showZigzag     = input.bool(true, "Show ZigZag", group = G_MSB)
showOB         = input.bool(true, "Show Order Blocks", group = G_MSB)

// FVG
fvgThreshold   = input.float(0, "FVG Threshold %", minval = 0, group = G_FVG)
fvgTf          = input.timeframe("60", "HTF FVG Timeframe", group = G_FVG)
fvgBodyFill    = input.bool(true, "Mitigate FVG by Body Close (HTF)", group = G_FVG)
bullFvgColor   = input.color(color.new(#089981, 80), "Bullish FVG", group = G_FVG)
bearFvgColor   = input.color(color.new(#f23645, 80), "Bearish FVG", group = G_FVG)

// EMA & VWAP
emaPeriod      = input.int(9, "EMA Period", minval = 1, group = G_EMA)
emaTf          = input.timeframe("15", "EMA Timeframe", group = G_EMA)
showEma        = input.bool(true, "Show MTF EMA", group = G_EMA)
showVwap       = input.bool(true, "Show VWAP", group = G_EMA)

// Sessions
showSessions   = input.bool(true, "Show Daily Session Range", group = G_SES)
sessionColor   = input.color(color.new(#5b9cf6, 90), "Session Range Color", group = G_SES)
labelColor     = input.color(color.new(color.gray, 0), "Session Label Color", group = G_SES)

// Signals
showSignals    = input.bool(true, "Show Buy/Sell Signals (Liquidity Sweep)", group = G_SIG)

// --- Session High/Low Tracking (Boxed & Labeled) ---
var box sessionBox = na
var label hiLabel  = na
var label loLabel  = na
var float dayHigh  = na
var float dayLow   = na
isNewDay = timeframe.change("1D")

if isNewDay
    dayHigh := high
    dayLow  := low
    if showSessions
        sessionBox := box.new(bar_index, dayHigh, bar_index, dayLow, bgcolor = sessionColor, border_color = color.new(sessionColor, 50))
        hiLabel := label.new(bar_index, dayHigh, "Session High", style = label.style_none, textcolor = labelColor, size = size.tiny)
        loLabel := label.new(bar_index, dayLow, "Session Low", style = label.style_none, textcolor = labelColor, size = size.tiny)
else
    dayHigh := math.max(dayHigh, high)
    dayLow  := math.min(dayLow, low)
    if showSessions and not na(sessionBox)
        box.set_top(sessionBox, dayHigh)
        box.set_bottom(sessionBox, dayLow)
        box.set_right(sessionBox, bar_index)
        label.set_xy(hiLabel, bar_index, dayHigh)
        label.set_xy(loLabel, bar_index, dayLow)

// --- Core MSB Logic (EmreKb) ---
var float[] highPointsArr = array.new_float(0)
var int[]   highIndexArr  = array.new_int(0)
var float[] lowPointsArr  = array.new_float(0)
var int[]   lowIndexArr   = array.new_int(0)
var box[]   buObBoxes     = array.new_box(0)
var box[]   beObBoxes     = array.new_box(0)

toUp   = high >= ta.highest(zigzagLen)
toDown = low <= ta.lowest(zigzagLen)

var int trend = 1
trend := trend == 1 and toDown ? -1 : trend == -1 and toUp ? 1 : trend

lastTrendUpSince   = ta.barssince(toUp[1])
lowVal             = ta.lowest(nz(lastTrendUpSince > 0 ? lastTrendUpSince : 1, 1))
lowIndex           = bar_index - ta.barssince(lowVal == low)

lastTrendDownSince = ta.barssince(toDown[1])
highVal            = ta.highest(nz(lastTrendDownSince > 0 ? lastTrendDownSince : 1, 1))
highIndex          = bar_index - ta.barssince(highVal == high)

if ta.change(trend) != 0
    if trend == 1
        array.push(lowPointsArr, lowVal)
        array.push(lowIndexArr, lowIndex)
    if trend == -1
        array.push(highPointsArr, highVal)
        array.push(highIndexArr, highIndex)

f_get_high(int ind) =>
    size = array.size(highPointsArr)
    if size > ind 
        [array.get(highPointsArr, size - 1 - ind), array.get(highIndexArr, size - 1 - ind)]
    else
        [float(na), int(na)]

f_get_low(int ind) =>
    size = array.size(lowPointsArr)
    if size > ind 
        [array.get(lowPointsArr, size - 1 - ind), array.get(lowIndexArr, size - 1 - ind)]
    else
        [float(na), int(na)]

[h0, h0i] = f_get_high(0)
[h1, h1i] = f_get_high(1)
[l0, l0i] = f_get_low(0)
[l1, l1i] = f_get_low(1)

if ta.change(trend) != 0 and showZigzag
    if trend == 1 and not na(h0) and not na(l0)
        line.new(h0i, h0, l0i, l0, color = chart.fg_color, width = 1, style = line.style_dotted)
    if trend == -1 and not na(l0) and not na(h0)
        line.new(l0i, l0, h0i, h0, color = chart.fg_color, width = 1, style = line.style_dotted)

var int market = 1
lastMarket = market
lastL0 = ta.valuewhen(ta.change(market) != 0, l0, 0)
lastH0 = ta.valuewhen(ta.change(market) != 0, h0, 0)

if not na(l1) and not na(h1) and not na(l0) and not na(h0)
    market := (lastL0 == l0 or lastH0 == h0) ? market : (market == 1 and l0 < l1 and l0 < l1 - math.abs(h0 - l1) * fibFactor) ? -1 : (market == -1 and h0 > h1 and h0 > h1 + math.abs(h1 - l0) * fibFactor) ? 1 : market

// MSB Alert
msbOccurred = ta.change(market) != 0

// OB Calculation
var int buObIndex = bar_index
var int beObIndex = bar_index

if msbOccurred
    if market == 1 and not na(h1)
        line.new(h1i, h1, bar_index, h1, color = #089981, width = 2)
        label.new(chart.point.from_index(math.round(math.avg(h1i, bar_index)), h1), "MSB", color = #00000000, style = label.style_label_down, textcolor = #089981, size = size.small)
        
        // Find OB
        for i = 0 to 50
            if open[i] > close[i]
                buObIndex := bar_index[i]
                break
        
        if showOB
            buOb = box.new(buObIndex, high[bar_index - buObIndex], bar_index, low[bar_index - buObIndex], bgcolor = color.new(#089981, 85), border_color = #089981, text = "Bull OB", text_color = #089981, text_size = size.tiny)
            array.push(buObBoxes, buOb)
            
    if market == -1 and not na(l1)
        line.new(l1i, l1, bar_index, l1, color = #f23645, width = 2)
        label.new(chart.point.from_index(math.round(math.avg(l1i, bar_index)), l1), "MSB", color = #00000000, style = label.style_label_up, textcolor = #f23645, size = size.small)
        
        // Find OB
        for i = 0 to 50
            if open[i] < close[i]
                beObIndex := bar_index[i]
                break
        
        if showOB
            beOb = box.new(beObIndex, high[bar_index - beObIndex], bar_index, low[bar_index - beObIndex], bgcolor = color.new(#f23645, 85), border_color = #f23645, text = "Bear OB", text_color = #f23645, text_size = size.tiny)
            array.push(beObBoxes, beOb)

// OB Management
if array.size(buObBoxes) > 0
    for i = array.size(buObBoxes) - 1 to 0
        b = array.get(buObBoxes, i)
        if close < box.get_bottom(b)
            box.delete(b)
            array.remove(buObBoxes, i)
        else
            box.set_right(b, bar_index)

if array.size(beObBoxes) > 0
    for i = array.size(beObBoxes) - 1 to 0
        b = array.get(beObBoxes, i)
        if close > box.get_top(b)
            box.delete(b)
            array.remove(beObBoxes, i)
        else
            box.set_right(b, bar_index)

// --- FVG Logic ---
type Fvg
    box   bx
    float level
    bool  isBull

var Fvg[] fvgArray = array.new<Fvg>(0)

[m_o, m_h, m_l, m_c, m_h2, m_l2] = request.security(syminfo.tickerid, fvgTf, [open[1], high, low, close[1], high[2], low[2]], barmerge.gaps_off, barmerge.lookahead_on)

deltaPer = (m_c - m_o) / m_o * 100
bullFvgCnd = m_l > m_h2 and m_c > m_h2 and deltaPer > fvgThreshold
bearFvgCnd = m_h < m_l2 and m_c < m_l2 and -deltaPer > fvgThreshold

if ta.change(time(fvgTf)) != 0
    if bullFvgCnd
        bx = box.new(bar_index - 1, m_l, bar_index + 1, m_h2, bgcolor = bullFvgColor, border_color = #00000000)
        array.push(fvgArray, Fvg.new(bx, m_h2, true))
    if bearFvgCnd
        bx = box.new(bar_index - 1, m_l2, bar_index + 1, m_h, bgcolor = bearFvgColor, border_color = #00000000)
        array.push(fvgArray, Fvg.new(bx, m_l2, false))

// Manage FVGs
if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        fvgObj = array.get(fvgArray, i)
        box.set_right(fvgObj.bx, bar_index)
        
        mitigated = fvgObj.isBull ? (fvgBodyFill ? close < fvgObj.level : low < fvgObj.level) : (fvgBodyFill ? close > fvgObj.level : high > fvgObj.level)
        
        if mitigated
            box.delete(fvgObj.bx)
            array.remove(fvgArray, i)

// --- EMA & VWAP ---
mtfEma = request.security(syminfo.tickerid, emaTf, ta.ema(close, emaPeriod))
myVwap = ta.vwap(close)

plot(showEma ? mtfEma : na, "MTF EMA", color = #5b9cf6, linewidth = 2)
plot(showVwap ? myVwap : na, "VWAP", color = #ffeb3b, linewidth = 1)

// --- Liquidity Sweeps & Signals ---
// Key liquidity can now be swing points OR session highs/lows
float topLiq = math.max(h0, dayHigh)
float botLiq = math.min(l0, dayLow)

bool bullSwp = low < botLiq and close > botLiq
bool bearSwp = high > topLiq and close < topLiq

var bool bullSwpt = false
var bool bearSwpt = false

if bullSwp
    bullSwpt := true
if bearSwp
    bearSwpt := true

if msbOccurred
    bullSwpt := false
    bearSwpt := false

bullE = close > open[1] and close > high[1] and open < close[1]
bearE = close < open[1] and close < low[1] and open > close[1]

bool bSig = bullSwpt and bullE and low <= botLiq * 1.005
bool sSig = bearSwpt and bearE and high >= topLiq * 0.995

if showSignals
    if bSig
        label.new(chart.point.from_index(bar_index, low), "BUY", color = #089981, style = label.style_label_up, textcolor = color.white, size = size.small)
        bullSwpt := false
    
    if sSig
        label.new(chart.point.from_index(bar_index, high), "SELL", color = #f23645, style = label.style_label_down, textcolor = color.white, size = size.small)
        bearSwpt := false

// --- Alerts ---
alertcondition(msbOccurred, "Market Structure Break", "MSB occurred: Trend shifted")
alertcondition(bSig, "Liquidity Buy Signal", "Buy signal: Liquidity level swept + Engulfing confirmation")
alertcondition(sSig, "Liquidity Sell Signal", "Sell signal: Liquidity level swept + Engulfing confirmation")
````
