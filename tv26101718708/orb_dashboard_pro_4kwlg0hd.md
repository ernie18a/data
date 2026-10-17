# ORB Dashboard Pro

- url: https://www.tradingview.com/script/4kwLg0hd-ORB-Dashboard-Pro/
- type: indicator
- pine_id: PUB;e202fd6127bc4d9d8a32440949a8615a
- version: 1.0

## Description

ORB Dashboard Pro provides real-time Opening Range analytics designed to answer the questions most ORB traders never ask.

Instead of simply marking the opening range, the dashboard continuously measures how today's session is developing relative to historical behavior.

The indicator tracks Opening Range structure, session development, acceptance above or below the range, expected expansion potential, and overall market phase.

The result is a powerful decision-support tool that helps traders quickly understand where today's auction stands compared to normal conditions.

Key Features

✔ Opening Range statistics and averages

✔ ORB compression and expansion analysis

✔ Session range tracking

✔ Range Used and Range Left calculations

✔ Acceptance Above / Below ORB detection

✔ Expansion phase identification

✔ EER (Expected Expansion Range) analytics

✔ Session development monitoring

✔ Real-time dashboard display

✔ Built-in breakout and acceptance alerts

Dashboard Sections
Open Structure
ORB Range
Average ORB Range
Compression Analysis
Structure Classification
Day Bias
Session Range
Average Session Range
Today's Range
Range Used
Range Left
Session Development
Expansion measured in R multiples
Acceptance Above/Below ORB
Market Development Phase
Expected Expansion Tracking
Ideal For
Opening Range traders
ES and NQ futures traders
Market Profile traders
Auction Market Theory practitioners
Intraday momentum traders
Traders seeking objective market context
Why It Matters

A breakout tells you where price moved.

The dashboard tells you how significant that move actually is.

By comparing today's development against historical session behavior, traders gain a better understanding of opportunity, exhaustion, and remaining potential throughout the trading day. 
Pasted text.txt

Real Trading. Real Testing. Real Results.

**  Related Indicators from Traders Workshop

• ORB Expansion Pro
• ORB Dashboard Pro
• ORB Sessions
• Everex Lite
• Flow MA Cloud

## Source Code

````pine
//@version=6
indicator('ORB Dashboard Pro', overlay = true)

//====================================================
// ORB Dashboard Pro
// Opening Range Analytics
// Author: Christopher C. Berg
// Platform: TradingView
// Version: 1.0
// Release: 2026
//====================================================

//====================================================
// Inputs
//====================================================
orbMinutes = input.int(30, 'ORB Minutes', options = [5, 10, 15, 20, 30, 45, 60])
orbSession = input.session('0830-1500', 'Session')
statsLookback = input.int(20, 'Stats Lookback Sessions', minval = 3, maxval = 100)

showDashboard = input.bool(true, 'Show Dashboard')
tableCloseOnly = input.bool(true, 'Update Table On Candle Close Only')
showEERSection = input.bool(true, 'Show EER / Phase Row')
showSessionRange = input.bool(true, 'Show Session Range Section')

alertsEnabled = input.bool(true, 'Enable Alerts')
alertOrbBreakouts = input.bool(true, 'Alert: ORB Breakouts')
alertAcceptanceShifts = input.bool(true, 'Alert: Acceptance Above/Below ORB')

//====================================================
// Helpers
//====================================================
f_fmt_pts(_v) =>
    na(_v) ? 'na' : str.tostring(_v, '#.##') + ' pts'

f_fmt_pts_pair(_v, _avg) =>
    not na(_v) and not na(_avg) ? str.tostring(_v, '#.##') + ' (Avg ' + str.tostring(_avg, '#.##') + ')' : 'na'

f_fmt_r(_v) =>
    string _txt = 'na'
    if not na(_v)
        float _r = math.round(_v * 10.0) / 10.0
        string _sign = _r > 0 ? '+' : _r < 0 ? '-' : ''
        _txt := _sign + str.tostring(math.abs(_r), '0.0') + 'R'
        _txt
    _txt

f_fmt_pct(_v) =>
    na(_v) ? 'na' : str.tostring(_v, '#.0') + '%'

f_trimmed_avg(_arr) =>
    float _avg = na
    int _sz = array.size(_arr)
    if _sz == 1
        _avg := array.get(_arr, 0)
        _avg
    else if _sz == 2
        _avg := (array.get(_arr, 0) + array.get(_arr, 1)) / 2.0
        _avg
    else if _sz > 2
        float _sum = 0.0
        float _min = array.get(_arr, 0)
        float _max = array.get(_arr, 0)
        for i = 0 to _sz - 1 by 1
            float _v = array.get(_arr, i)
            _sum := _sum + _v
            _min := math.min(_min, _v)
            _max := math.max(_max, _v)
            _max
        _avg := (_sum - _min - _max) / (_sz - 2)
        _avg
    _avg

f_trim_array(_arr, _max) =>
    while array.size(_arr) > _max
        array.shift(_arr)

f_acceptance_text(_state) =>
    _state == 'Accepted Above' ? '[+] Accepted Above' : _state == 'Accepted Below' ? '[-] Accepted Below' : _state == 'Probing Above' ? '[+] Probing Above' : _state == 'Probing Below' ? '[-] Probing Below' : '[=] Inside ORB'

//====================================================
// Session state
//====================================================
inSess = not na(time(timeframe.period, orbSession))
newSess = inSess and not inSess[1]
orbBars = timeframe.isintraday ? math.ceil(orbMinutes / timeframe.multiplier) : na

//====================================================
// Persistent variables
//====================================================
var float orbHigh = na
var float orbLow = na
var float orbMid = na
var float orbRange = na
var float openPx = na

var float sessHigh = na
var float sessLow = na
var float rthHigh = na
var float rthLow = na

var bool orbBuilding = false
var bool orbLocked = false
var int sessStartBar = na

var array<float> orbRangeHist = array.new_float()
var array<float> sessRangeHist = array.new_float()

var table dashTbl = table.new(position.top_right, 2, 18, border_width = 1)

//====================================================
// Session lifecycle
//====================================================
if newSess
    if orbLocked and not na(orbRange) and orbRange > 0
        array.push(orbRangeHist, orbRange)
        f_trim_array(orbRangeHist, statsLookback)

    if not na(rthHigh) and not na(rthLow) and rthHigh > rthLow
        array.push(sessRangeHist, rthHigh - rthLow)
        f_trim_array(sessRangeHist, statsLookback)

    orbHigh := na
    orbLow := na
    orbMid := na
    orbRange := na
    sessHigh := na
    sessLow := na
    rthHigh := na
    rthLow := na
    openPx := open
    orbBuilding := true
    orbLocked := false
    sessStartBar := bar_index
    sessStartBar

//====================================================
// Track full session range
//====================================================
if inSess
    rthHigh := na(rthHigh) ? high : math.max(rthHigh, high)
    rthLow := na(rthLow) ? low : math.min(rthLow, low)
    rthLow

//====================================================
// Build ORB
//====================================================
barsSinceSessOpen = not na(sessStartBar) ? bar_index - sessStartBar : na
inOrbWindow = inSess and orbBuilding and not na(barsSinceSessOpen) and not na(orbBars) and barsSinceSessOpen < orbBars

if inOrbWindow
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
    orbLow

//====================================================
// Lock ORB
//====================================================
lockNow = inSess and orbBuilding and not orbLocked and not na(barsSinceSessOpen) and not na(orbBars) and barsSinceSessOpen >= orbBars

if lockNow
    orbBuilding := false
    orbLocked := true
    orbMid := (orbHigh + orbLow) / 2.0
    orbRange := orbHigh - orbLow
    sessHigh := high
    sessLow := low
    sessLow

//====================================================
// Track post-lock expansion
//====================================================
if inSess and orbLocked
    sessHigh := na(sessHigh) ? high : math.max(sessHigh, high)
    sessLow := na(sessLow) ? low : math.min(sessLow, low)
    sessLow

//====================================================
// Derived calculations
//====================================================
avgOrbRange = f_trimmed_avg(orbRangeHist)
avgSessRange = f_trimmed_avg(sessRangeHist)

float currentUpR = na
float currentDnR = na

if orbLocked and not na(orbRange) and orbRange > 0
    currentUpR := math.max(0.0, (sessHigh - orbHigh) / orbRange)
    currentDnR := math.max(0.0, (orbLow - sessLow) / orbRange)
    currentDnR

float eerExpPts = not na(avgSessRange) and not na(orbRange) and orbRange > 0 and avgSessRange > orbRange ? avgSessRange - orbRange : na
float eerMultiplier = not na(eerExpPts) and not na(orbRange) and orbRange > 0 ? eerExpPts / orbRange : na

float eerUpUsedPct = not na(currentUpR) and not na(eerMultiplier) and eerMultiplier > 0 ? currentUpR / eerMultiplier * 100.0 : na
float eerDnUsedPct = not na(currentDnR) and not na(eerMultiplier) and eerMultiplier > 0 ? currentDnR / eerMultiplier * 100.0 : na
float eerUsedPct = not na(eerUpUsedPct) and not na(eerDnUsedPct) ? math.max(eerUpUsedPct, eerDnUsedPct) : na

float orbCompressionPct = not na(orbRange) and not na(avgOrbRange) and avgOrbRange > 0 ? orbRange / avgOrbRange * 100.0 : na

string orbStructure = 'Building'
if orbLocked and not na(orbCompressionPct)
    orbStructure := orbCompressionPct < 70 ? 'Compressed' : orbCompressionPct <= 110 ? 'Balanced' : orbCompressionPct <= 130 ? 'Wide' : 'Very Wide'
    orbStructure

string dayBias = 'Balanced'
if orbLocked and not na(orbCompressionPct)
    dayBias := orbCompressionPct < 70 ? 'Expansion Likely' : orbCompressionPct < 110 ? 'Balanced' : orbCompressionPct < 130 ? 'Rotation Likely' : 'Exhaustion Risk'
    dayBias

string acceptance = 'Building'
if orbLocked and not na(orbHigh) and not na(orbLow)
    aboveNow = close > orbHigh
    belowNow = close < orbLow
    abovePrev = close[1] > orbHigh
    belowPrev = close[1] < orbLow

    acceptance := aboveNow and abovePrev ? 'Accepted Above' : belowNow and belowPrev ? 'Accepted Below' : aboveNow ? 'Probing Above' : belowNow ? 'Probing Below' : 'Inside ORB'
    acceptance

todayRange = not na(rthHigh) and not na(rthLow) ? rthHigh - rthLow : na
rangeUsedPct = not na(todayRange) and not na(avgSessRange) and avgSessRange > 0 ? todayRange / avgSessRange * 100.0 : na
rangeLeftPct = not na(rangeUsedPct) ? math.max(0.0, 100.0 - rangeUsedPct) : na

phaseInput = not na(eerUsedPct) and not na(rangeUsedPct) ? math.max(eerUsedPct, rangeUsedPct) : not na(eerUsedPct) ? eerUsedPct : not na(rangeUsedPct) ? rangeUsedPct : na

string phase = 'Opening'
if not na(phaseInput)
    phase := phaseInput < 30 ? 'Opening' : phaseInput < 80 ? 'Expanding' : phaseInput < 120 ? 'Extended' : 'Extreme'
    phase

//====================================================
// Alerts
//====================================================
orbBreakoutUp = alertsEnabled and alertOrbBreakouts and orbLocked and barstate.isconfirmed and ta.crossover(close, orbHigh)
orbBreakoutDown = alertsEnabled and alertOrbBreakouts and orbLocked and barstate.isconfirmed and ta.crossunder(close, orbLow)

acceptedAbove = alertsEnabled and alertAcceptanceShifts and orbLocked and barstate.isconfirmed and close > orbHigh and close[1] > orbHigh and not(close[1] > orbHigh and close[2] > orbHigh)
acceptedBelow = alertsEnabled and alertAcceptanceShifts and orbLocked and barstate.isconfirmed and close < orbLow and close[1] < orbLow and not(close[1] < orbLow and close[2] < orbLow)

alertcondition(orbBreakoutUp, title = 'ORB Breakout Up', message = 'ORB Dashboard Pro: confirmed close above ORB High')
alertcondition(orbBreakoutDown, title = 'ORB Breakout Down', message = 'ORB Dashboard Pro: confirmed close below ORB Low')
alertcondition(acceptedAbove, title = 'Accepted Above ORB', message = 'ORB Dashboard Pro: 2 confirmed closes above ORB High')
alertcondition(acceptedBelow, title = 'Accepted Below ORB', message = 'ORB Dashboard Pro: 2 confirmed closes below ORB Low')

//====================================================
// Dashboard
//====================================================
refreshDash = not tableCloseOnly or barstate.isconfirmed

if showDashboard and refreshDash
    openHdrBg = color.new(color.blue, 70)
    openRowBg = color.new(color.blue, 88)
    sessHdrBg = color.new(color.rgb(160, 82, 45), 70)
    sessRowBg = color.new(color.rgb(160, 82, 45), 88)
    rangeHdrBg = color.new(color.rgb(0, 128, 128), 70)
    rangeRowBg = color.new(color.rgb(0, 128, 128), 88)
    txtColor = color.white

    table.cell(dashTbl, 0, 0, 'OPEN STRUCTURE', text_color = txtColor, bgcolor = openHdrBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 0, '', text_color = txtColor, bgcolor = openHdrBg)

    table.cell(dashTbl, 0, 1, 'ORB Range', text_color = txtColor, bgcolor = openRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 1, f_fmt_pts_pair(orbRange, avgOrbRange), text_color = txtColor, bgcolor = openRowBg)

    table.cell(dashTbl, 0, 2, 'Structure', text_color = txtColor, bgcolor = openRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 2, orbStructure, text_color = txtColor, bgcolor = openRowBg)

    table.cell(dashTbl, 0, 3, 'Compression', text_color = txtColor, bgcolor = openRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 3, f_fmt_pct(orbCompressionPct), text_color = txtColor, bgcolor = openRowBg)

    table.cell(dashTbl, 0, 4, 'Day Bias', text_color = txtColor, bgcolor = openRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 4, dayBias, text_color = txtColor, bgcolor = openRowBg)

    if showSessionRange
        table.cell(dashTbl, 0, 5, 'SESSION RANGE', text_color = txtColor, bgcolor = rangeHdrBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 5, '', text_color = txtColor, bgcolor = rangeHdrBg)

        table.cell(dashTbl, 0, 6, 'Avg Range', text_color = txtColor, bgcolor = rangeRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 6, f_fmt_pts(avgSessRange), text_color = txtColor, bgcolor = rangeRowBg)

        table.cell(dashTbl, 0, 7, 'Today\'s Range', text_color = txtColor, bgcolor = rangeRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 7, f_fmt_pts(todayRange), text_color = txtColor, bgcolor = rangeRowBg)

        table.cell(dashTbl, 0, 8, 'Range Used', text_color = txtColor, bgcolor = rangeRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 8, f_fmt_pct(rangeUsedPct), text_color = txtColor, bgcolor = rangeRowBg)

        table.cell(dashTbl, 0, 9, 'Range Left', text_color = txtColor, bgcolor = rangeRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 9, f_fmt_pct(rangeLeftPct), text_color = txtColor, bgcolor = rangeRowBg)

    table.cell(dashTbl, 0, 10, 'SESSION DEVELOPMENT', text_color = txtColor, bgcolor = sessHdrBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 10, '', text_color = txtColor, bgcolor = sessHdrBg)

    table.cell(dashTbl, 0, 11, 'Up Move', text_color = txtColor, bgcolor = sessRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 11, f_fmt_r(currentUpR), text_color = txtColor, bgcolor = sessRowBg)

    table.cell(dashTbl, 0, 12, 'Down Move', text_color = txtColor, bgcolor = sessRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 12, f_fmt_r(-currentDnR), text_color = txtColor, bgcolor = sessRowBg)

    table.cell(dashTbl, 0, 13, 'Acceptance', text_color = txtColor, bgcolor = sessRowBg, text_halign = text.align_left)
    table.cell(dashTbl, 1, 13, f_acceptance_text(acceptance), text_color = txtColor, bgcolor = sessRowBg)

    if showEERSection
        table.cell(dashTbl, 0, 14, 'Phase', text_color = txtColor, bgcolor = sessRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 14, phase, text_color = txtColor, bgcolor = sessRowBg)

        table.cell(dashTbl, 0, 15, 'EER Range', text_color = txtColor, bgcolor = sessRowBg, text_halign = text.align_left)
        table.cell(dashTbl, 1, 15, not na(eerMultiplier) ? str.tostring(math.round(eerMultiplier * 10.0) / 10.0, '0.0') + 'R' : 'na', text_color = txtColor, bgcolor = sessRowBg)
````
