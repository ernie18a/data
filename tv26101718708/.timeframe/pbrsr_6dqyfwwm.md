# *PBR.S/R

- url: https://www.tradingview.com/script/6dqYfwWm-PBR-S-R/
- type: indicator
- pine_id: PUB;81cbe257c2f6452f8006e1a6e064f1cf
- version: 1.0

## Description

PBR — Pullback Reclaim

A multi-feature indicator built around the Pullback Reclaim (PR) strategy for identifying trend continuation entries.

Core features:

Detects PR long/short signals using EMA 13/21 cloud direction and trend with optional RSI and Stoch RSI confluence filters
Displays SL, TP1, and TP2 levels with position sizing based on account size and risk %
Built-in S/R engine that identifies and scores support/resistance levels by pivot touch count and confluence with SMAs, Bollinger Bands, and round numbers
S/R proximity filter divides price into three zones — long zone (near support), short zone (near resistance), and dead zone (mid-range) — blocking longs near resistance and shorts near support to reduce false signals and improve trade location
1H and 4H trend filters to avoid counter-trend signals
Counter Trade Mode to flip signal direction
Visual trade boxes, EMA cloud, proximity zone backgrounds, and an info panel
Works on any asset and any market. Recommended timeframes: H1 for signal confirmation, M15 for entry timing.

## Source Code

````pine
//@version=5
indicator("*PBR.S/R", shorttitle="*PBR", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════
// PR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
useChartTF   = input.bool(true,      title="Use Chart Timeframe",                                                            group="PR Settings")
tfInput      = input.timeframe("15", title="Timeframe (if above is off)", options=["5","15","30","60","120","240","720"],     group="PR Settings")
waitForClose = input.bool(false,      title="Wait For Candle Close",                                                          group="PR Settings")
counterMode  = input.bool(false,     title="⚡ Counter Trade Mode",                                                          group="PR Settings")
confluence   = input.string("Either",  title="Confluence Filter", options=["Neither","RSI","Stoch RSI","Either","Both"],    group="PR Settings")
tpMode       = input.string("TP1 + TP2",title="TP Mode",           options=["TP1 Only","TP1 + TP2"],                         group="PR Settings")
showCloud    = input.bool(true,      title="Show EMA Cloud",                                                                 group="PR Settings")
showEMAScale = input.bool(false,     title="Show EMAs on Price Scale",                                                       group="PR Settings")
showInfo     = input.bool(true,      title="Show Info Box",                                                                  group="PR Settings")
showLevels   = input.bool(true,      title="Show SL/TP Labels",                                                              group="PR Settings")
recentOnly   = input.bool(true,     title="Most Recent Signal Only",                                                        group="PR Settings")
showBoxes    = input.bool(true,      title="Show SL/TP Boxes",                                                               group="PR Settings")
boxCount     = input.int(1,          title="Boxes — Last N Signals", minval=1, maxval=10,                                    group="PR Settings")
boxBars      = input.int(30,         title="Box Width (Bars)",        minval=5, maxval=200,                                  group="PR Settings")
showSize     = input.bool(true,      title="Show Position Size",                                                             group="PR Settings")
sizeDisplay  = input.string("Dollar Value", title="Position Size Display", options=["Quantity","Dollar Value"],                  group="PR Settings")
accountSize  = input.float(10000,    title="Account Size ($)", minval=1,                                                     group="PR Settings")
riskMode     = input.string("Percentage", title="Risk Mode",   options=["Percentage","Fixed $"],                             group="PR Settings")
riskPct      = input.float(1.0,      title="Risk %",   minval=0.01, maxval=100, step=0.1,                                   group="PR Settings")
riskFixed    = input.float(100.0,    title="Risk $ (Fixed)", minval=1,                                                      group="PR Settings")

// ═══════════════════════════════════════════════════════════════════════════
// S/R SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
useSR          = input.bool(false,  title="Enable S/R Proximity Filter",                                                    group="S/R Settings")
lookback       = input.int(5,       title="Pivot Lookback",        minval=2,  maxval=50,                                    group="S/R Settings")
tolerance      = input.float(0.5,   title="Cluster Tolerance %",  minval=0.1, maxval=2.0, step=0.1,                        group="S/R Settings")
maxLevels      = input.int(4,       title="Max Levels to Show",   minval=2,  maxval=10,                                    group="S/R Settings")
minStrength    = input.int(24,      title="Min Strength Score",   minval=0,  maxval=100,                                    group="S/R Settings")
autoBar        = input.bool(true,   title="Auto Bars (by Timeframe)",                                                       group="S/R Settings")
barsToAnalyze  = input.int(200,     title="Bars to Analyze (Manual)", minval=50, maxval=490,                                group="S/R Settings")
showSRLevels   = input.bool(true,   title="Show S/R Lines",                                                                 group="S/R Settings")
showSRLabels   = input.bool(false,  title="Show S/R Pane Labels",                                                           group="S/R Settings")
supportColor   = input.color(color.new(color.green, 20), title="Support Color",                                             group="S/R Settings")
resistanceColor= input.color(color.new(color.red,   20), title="Resistance Color",                                          group="S/R Settings")
long_max_pct   = input.float(35.0,  title="Long Zone Max %",  minval=10, maxval=50, step=5,                                 group="S/R Settings")
short_min_pct  = input.float(65.0,  title="Short Zone Min %", minval=50, maxval=90, step=5,                                 group="S/R Settings")
showZones      = input.bool(true,   title="Show Proximity Zones",                                                           group="S/R Settings")

showTP2 = tpMode == "TP1 + TP2"

// ═══════════════════════════════════════════════════════════════════════════
// PRICE FORMATTING
// ═══════════════════════════════════════════════════════════════════════════
fmtPrice(p) =>
    if p >= 1000
        str.tostring(math.round(p, 1))
    else if p >= 100
        str.tostring(math.round(p, 2))
    else if p >= 10
        str.tostring(math.round(p, 3))
    else if p >= 1
        str.tostring(math.round(p, 4))
    else if p >= 0.1
        str.tostring(math.round(p, 5))
    else
        str.tostring(math.round(p, 6))

// ═══════════════════════════════════════════════════════════════════════════
// PR — REQUEST SECURITY
// ═══════════════════════════════════════════════════════════════════════════
sameTF   = useChartTF or tfInput == timeframe.period
activeTF = useChartTF ? timeframe.period : tfInput

rsiRaw   = ta.rsi(close, 14)
stochRaw = ta.sma(ta.stoch(rsiRaw, rsiRaw, rsiRaw, 14), 3)

o_cc      = sameTF ? open[1]              : request.security(syminfo.tickerid, activeTF, open[1],              lookahead=barmerge.lookahead_on)
c_cc      = sameTF ? close[1]             : request.security(syminfo.tickerid, activeTF, close[1],             lookahead=barmerge.lookahead_on)
h_cc      = sameTF ? high[1]              : request.security(syminfo.tickerid, activeTF, high[1],              lookahead=barmerge.lookahead_on)
l_cc      = sameTF ? low[1]               : request.security(syminfo.tickerid, activeTF, low[1],               lookahead=barmerge.lookahead_on)
e13_cc    = sameTF ? ta.ema(close,13)[1]  : request.security(syminfo.tickerid, activeTF, ta.ema(close,13)[1],  lookahead=barmerge.lookahead_on)
e21_cc    = sameTF ? ta.ema(close,21)[1]  : request.security(syminfo.tickerid, activeTF, ta.ema(close,21)[1],  lookahead=barmerge.lookahead_on)
rsiVal_cc = sameTF ? rsiRaw[1]            : request.security(syminfo.tickerid, activeTF, rsiRaw[1],            lookahead=barmerge.lookahead_on)
rsiK_cc   = sameTF ? stochRaw[1]          : request.security(syminfo.tickerid, activeTF, stochRaw[1],          lookahead=barmerge.lookahead_on)

o_lv      = sameTF ? open              : request.security(syminfo.tickerid, activeTF, open,              lookahead=barmerge.lookahead_off)
c_lv      = sameTF ? close             : request.security(syminfo.tickerid, activeTF, close,             lookahead=barmerge.lookahead_off)
h_lv      = sameTF ? high              : request.security(syminfo.tickerid, activeTF, high,              lookahead=barmerge.lookahead_off)
l_lv      = sameTF ? low               : request.security(syminfo.tickerid, activeTF, low,               lookahead=barmerge.lookahead_off)
e13_lv    = sameTF ? ta.ema(close,13)  : request.security(syminfo.tickerid, activeTF, ta.ema(close,13),  lookahead=barmerge.lookahead_off)
e21_lv    = sameTF ? ta.ema(close,21)  : request.security(syminfo.tickerid, activeTF, ta.ema(close,21),  lookahead=barmerge.lookahead_off)
rsiVal_lv = sameTF ? rsiRaw            : request.security(syminfo.tickerid, activeTF, rsiRaw,            lookahead=barmerge.lookahead_off)
rsiK_lv   = sameTF ? stochRaw          : request.security(syminfo.tickerid, activeTF, stochRaw,          lookahead=barmerge.lookahead_off)

o      = waitForClose ? o_cc      : o_lv
c      = waitForClose ? c_cc      : c_lv
h      = waitForClose ? h_cc      : h_lv
l      = waitForClose ? l_cc      : l_lv
e13    = waitForClose ? e13_cc    : e13_lv
e21    = waitForClose ? e21_cc    : e21_lv
rsiVal = waitForClose ? rsiVal_cc : rsiVal_lv
rsiK   = waitForClose ? rsiK_cc   : rsiK_lv

// ═══════════════════════════════════════════════════════════════════════════
// EMA CLOUD
// ═══════════════════════════════════════════════════════════════════════════
ema13_display = sameTF ? ta.ema(close, 13) : request.security(syminfo.tickerid, activeTF, ta.ema(close, 13))
ema21_display = sameTF ? ta.ema(close, 21) : request.security(syminfo.tickerid, activeTF, ta.ema(close, 21))

p13 = plot(showCloud ? ema13_display : na, title="EMA 13", color=#00FF00, linewidth=1, display=showEMAScale ? display.all : display.pane)
p21 = plot(showCloud ? ema21_display : na, title="EMA 21", color=#00FFFF, linewidth=1, display=showEMAScale ? display.all : display.pane)
fill(p13, p21, color=ema13_display > ema21_display ? color.new(color.green, 80) : color.new(color.red, 80))

// ═══════════════════════════════════════════════════════════════════════════
// 1H / 4H TREND
// ═══════════════════════════════════════════════════════════════════════════
ema13_1h = request.security(syminfo.tickerid, "60",  ta.ema(close, 13)[1], lookahead=barmerge.lookahead_on)
close_1h = request.security(syminfo.tickerid, "60",  close[1],             lookahead=barmerge.lookahead_on)
slope_1h = request.security(syminfo.tickerid, "60",  (ta.ema(close,13)[1] - ta.ema(close,13)[4]) / ta.ema(close,13)[4] * 100, lookahead=barmerge.lookahead_on)
h1Trend  = close_1h > ema13_1h and slope_1h > 0.05 ? "L" : close_1h < ema13_1h and slope_1h < -0.05 ? "B" : "N"

ema13_4h = request.security(syminfo.tickerid, "240", ta.ema(close, 13)[1], lookahead=barmerge.lookahead_on)
close_4h = request.security(syminfo.tickerid, "240", close[1],             lookahead=barmerge.lookahead_on)
slope_4h = request.security(syminfo.tickerid, "240", (ta.ema(close,13)[1] - ta.ema(close,13)[4]) / ta.ema(close,13)[4] * 100, lookahead=barmerge.lookahead_on)
h4Trend  = close_4h > ema13_4h and slope_4h > 0.05 ? "Bullish" : close_4h < ema13_4h and slope_4h < -0.05 ? "Bearish" : "Neutral"

// ═══════════════════════════════════════════════════════════════════════════
// CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════
rsiOK(dir) =>
    if confluence == "Neither"
        true
    else if confluence == "RSI"
        dir == "LONG" ? rsiVal > 50 : rsiVal < 50
    else if confluence == "Stoch RSI"
        dir == "LONG" ? rsiK < 50 : rsiK > 50
    else if confluence == "Either"
        dir == "LONG" ? (rsiVal > 50 or rsiK < 50) : (rsiVal < 50 or rsiK > 50)
    else
        dir == "LONG" ? rsiVal > 50 and rsiK < 50 : rsiVal < 50 and rsiK > 50

// ═══════════════════════════════════════════════════════════════════════════
// S/R — AUTO BARS
// ═══════════════════════════════════════════════════════════════════════════
getAutoBars() =>
    int result = 200
    if timeframe.isminutes
        if timeframe.multiplier <= 5
            result := 288
        else if timeframe.multiplier <= 15
            result := 200
        else if timeframe.multiplier <= 60
            result := 100
        else if timeframe.multiplier <= 240
            result := 50
        else
            result := 100
    else if timeframe.isdaily
        result := 100
    else if timeframe.isweekly
        result := 52
    else if timeframe.ismonthly
        result := 24
    result

activeBars = math.min(autoBar ? getAutoBars() : barsToAnalyze, 490)

// ═══════════════════════════════════════════════════════════════════════════
// S/R — CONFLUENCE HELPERS
// ═══════════════════════════════════════════════════════════════════════════
sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)
[bbMid, bbUpper, bbLower] = ta.bb(close, 20, 2)

isRoundNumber(float price) =>
    result = false
    if price >= 1
        result := price % 1 == 0 or price % 5 == 0 or price % 10 == 0
    else
        result := math.round(price * 100) % 5 == 0
    result

getConfluence(float price) =>
    conf = 0
    if not na(sma20)   and math.abs(price - sma20)   / sma20   < 0.003
        conf += 1
    if not na(sma50)   and math.abs(price - sma50)   / sma50   < 0.003
        conf += 1
    if not na(bbUpper) and math.abs(price - bbUpper) / bbUpper < 0.003
        conf += 1
    if not na(bbMid)   and math.abs(price - bbMid)   / bbMid   < 0.003
        conf += 1
    if not na(bbLower) and math.abs(price - bbLower) / bbLower < 0.003
        conf += 1
    if isRoundNumber(price)
        conf += 1
    conf

scoreLevel(int touches, int confluence) =>
    math.min(touches * 10, 40) + confluence * 5 + 10

// ═══════════════════════════════════════════════════════════════════════════
// S/R — SCAN PIVOTS
// ═══════════════════════════════════════════════════════════════════════════
var resistanceLevels  = array.new<float>()
var resistanceTouches = array.new<int>()
var resistanceScores  = array.new<int>()
var supportLevels     = array.new<float>()
var supportTouches    = array.new<int>()
var supportScores     = array.new<int>()

if barstate.islast
    array.clear(resistanceLevels)
    array.clear(resistanceTouches)
    array.clear(resistanceScores)
    array.clear(supportLevels)
    array.clear(supportTouches)
    array.clear(supportScores)

    absoluteMax     = math.max(0, bar_index - lookback)
    safeBarsToScan  = math.min(activeBars, absoluteMax)

    if bar_index >= (lookback * 2 + 10) and safeBarsToScan >= lookback
        for i = lookback to safeBarsToScan
            if i + lookback <= bar_index and i >= lookback
                isPivotHigh = true
                pivotHigh   = high[i]
                for j = 1 to lookback
                    if high[i] <= high[i - j] or high[i] <= high[i + j]
                        isPivotHigh := false
                        break
                if isPivotHigh
                    matched = false
                    rSize = array.size(resistanceLevels)
                    if rSize > 0
                        for k = 0 to rSize - 1
                            if k < array.size(resistanceLevels)
                                ep = array.get(resistanceLevels, k)
                                if ep > 0 and math.abs(pivotHigh - ep) / ep < tolerance / 100
                                    t = array.get(resistanceTouches, k) + 1
                                    array.set(resistanceTouches, k, t)
                                    array.set(resistanceLevels, k, (ep * (t - 1) + pivotHigh) / t)
                                    matched := true
                                    break
                    if not matched
                        array.push(resistanceLevels, pivotHigh)
                        array.push(resistanceTouches, 1)
                        array.push(resistanceScores, 0)

                isPivotLow = true
                pivotLow   = low[i]
                for j = 1 to lookback
                    if low[i] >= low[i - j] or low[i] >= low[i + j]
                        isPivotLow := false
                        break
                if isPivotLow
                    matched = false
                    sSize = array.size(supportLevels)
                    if sSize > 0
                        for k = 0 to sSize - 1
                            if k < array.size(supportLevels)
                                ep = array.get(supportLevels, k)
                                if ep > 0 and math.abs(pivotLow - ep) / ep < tolerance / 100
                                    t = array.get(supportTouches, k) + 1
                                    array.set(supportTouches, k, t)
                                    array.set(supportLevels, k, (ep * (t - 1) + pivotLow) / t)
                                    matched := true
                                    break
                    if not matched
                        array.push(supportLevels, pivotLow)
                        array.push(supportTouches, 1)
                        array.push(supportScores, 0)

    rLen = array.size(resistanceLevels)
    if rLen > 0
        for i = 0 to rLen - 1
            if i < array.size(resistanceLevels)
                array.set(resistanceScores, i, scoreLevel(array.get(resistanceTouches, i), getConfluence(array.get(resistanceLevels, i))))

    sLen = array.size(supportLevels)
    if sLen > 0
        for i = 0 to sLen - 1
            if i < array.size(supportLevels)
                array.set(supportScores, i, scoreLevel(array.get(supportTouches, i), getConfluence(array.get(supportLevels, i))))

// ═══════════════════════════════════════════════════════════════════════════
// S/R — FILTER & SORT
// ═══════════════════════════════════════════════════════════════════════════
var topResistances      = array.new<float>()
var topResistanceScores = array.new<int>()
var topResistanceTouches= array.new<int>()
var topSupports         = array.new<float>()
var topSupportScores    = array.new<int>()
var topSupportTouches   = array.new<int>()

if barstate.islast
    array.clear(topResistances)
    array.clear(topResistanceScores)
    array.clear(topResistanceTouches)
    array.clear(topSupports)
    array.clear(topSupportScores)
    array.clear(topSupportTouches)

    rLen2 = array.size(resistanceLevels)
    if rLen2 > 0
        for i = 0 to rLen2 - 1
            if i < array.size(resistanceLevels)
                price  = array.get(resistanceLevels, i)
                score  = array.get(resistanceScores, i)
                touches= array.get(resistanceTouches, i)
                if price > close and score >= minStrength
                    array.push(topResistances,       price)
                    array.push(topResistanceScores,  score)
                    array.push(topResistanceTouches, touches)

    trLen = array.size(topResistances)
    if trLen > 1
        for i = 0 to trLen - 2
            for j = 0 to trLen - 2 - i
                if j + 1 < array.size(topResistanceScores)
                    if array.get(topResistanceScores, j) < array.get(topResistanceScores, j + 1)
                        ts = array.get(topResistanceScores, j)
                        array.set(topResistanceScores, j, array.get(topResistanceScores, j + 1))
                        array.set(topResistanceScores, j + 1, ts)
                        tp = array.get(topResistances, j)
                        array.set(topResistances, j, array.get(topResistances, j + 1))
                        array.set(topResistances, j + 1, tp)
                        tt = array.get(topResistanceTouches, j)
                        array.set(topResistanceTouches, j, array.get(topResistanceTouches, j + 1))
                        array.set(topResistanceTouches, j + 1, tt)

    sLen2 = array.size(supportLevels)
    if sLen2 > 0
        for i = 0 to sLen2 - 1
            if i < array.size(supportLevels)
                price  = array.get(supportLevels, i)
                score  = array.get(supportScores, i)
                touches= array.get(supportTouches, i)
                if price < close and score >= minStrength
                    array.push(topSupports,       price)
                    array.push(topSupportScores,  score)
                    array.push(topSupportTouches, touches)

    tsLen = array.size(topSupports)
    if tsLen > 1
        for i = 0 to tsLen - 2
            for j = 0 to tsLen - 2 - i
                if j + 1 < array.size(topSupportScores)
                    if array.get(topSupportScores, j) < array.get(topSupportScores, j + 1)
                        ts = array.get(topSupportScores, j)
                        array.set(topSupportScores, j, array.get(topSupportScores, j + 1))
                        array.set(topSupportScores, j + 1, ts)
                        tp = array.get(topSupports, j)
                        array.set(topSupports, j, array.get(topSupports, j + 1))
                        array.set(topSupports, j + 1, tp)
                        tt = array.get(topSupportTouches, j)
                        array.set(topSupportTouches, j, array.get(topSupportTouches, j + 1))
                        array.set(topSupportTouches, j + 1, tt)

// ═══════════════════════════════════════════════════════════════════════════
// PROXIMITY CALCULATION (barstate.islast only — full S/R)
// ═══════════════════════════════════════════════════════════════════════════
var float nearest_resistance = na
var float nearest_support    = na
var float range_pct          = na
var bool  long_room          = false
var bool  short_room         = false

if barstate.islast
    nearest_resistance := float(na)
    nearest_support    := float(na)
    float _min_r = float(na)
    float _min_s = float(na)

    _tr_size = array.size(topResistances)
    if _tr_size > 0
        for _i = 0 to _tr_size - 1
            _r  = array.get(topResistances, _i)
            _d  = _r - close
            if _d > 0 and (na(_min_r) or _d < _min_r)
                _min_r             := _d
                nearest_resistance := _r

    _ts_size = array.size(topSupports)
    if _ts_size > 0
        for _i = 0 to _ts_size - 1
            _s  = array.get(topSupports, _i)
            _d  = close - _s
            if _d > 0 and (na(_min_s) or _d < _min_s)
                _min_s          := _d
                nearest_support := _s

    _range_size = not na(nearest_resistance) and not na(nearest_support) ? nearest_resistance - nearest_support : float(na)
    range_pct  := not na(_range_size) and _range_size > 0 ? (close - nearest_support) / _range_size * 100 : float(na)
    long_room  := not na(range_pct) and range_pct <= long_max_pct
    short_room := not na(range_pct) and range_pct >= short_min_pct

// ═══════════════════════════════════════════════════════════════════════════
// PR DETECTION
// ═══════════════════════════════════════════════════════════════════════════
bodyPct   = math.abs(c - o) / c
emaSpread = math.abs(e13 - e21) / e21

srLongOK  = not useSR or long_room
srShortOK = not useSR or short_room

rawLongSignal  = e13 > e21 and c > o and (o < e13 or o < e21) and c > e13 and c > e21 and h1Trend != "B" and bodyPct >= 0.0015 and emaSpread >= 0.001 and rsiOK("LONG")  and srLongOK
rawShortSignal = e13 < e21 and c < o and (o > e13 or o > e21) and c < e13 and c < e21 and h1Trend != "L" and bodyPct >= 0.0015 and emaSpread >= 0.001 and rsiOK("SHORT") and srShortOK

longSignal  = counterMode ? rawShortSignal : rawLongSignal
shortSignal = counterMode ? rawLongSignal  : rawShortSignal

arrowOffset = waitForClose ? -1 : 0
labelOffset = waitForClose ? -1 : 0

// ═══════════════════════════════════════════════════════════════════════════
// STOP & TP LEVELS
// ═══════════════════════════════════════════════════════════════════════════
minStop = 0.015
maxStop = 0.03

_prLongStop  = math.min(l * 0.999, c * (1 - minStop))
_prShortStop = math.max(h * 1.001, c * (1 + minStop))
_prLongStop  := math.abs(c - _prLongStop)  / c > maxStop ? c * (1 - maxStop) : _prLongStop
_prShortStop := math.abs(_prShortStop - c) / c > maxStop ? c * (1 + maxStop) : _prShortStop

longStop  = _prLongStop
shortStop = _prShortStop

longRisk  = math.abs(c - longStop)
shortRisk = math.abs(c - shortStop)

longTP1  = c + longRisk  * 2
longTP2  = c + longRisk  * 3
shortTP1 = c - shortRisk * 2
shortTP2 = c - shortRisk * 3

// ═══════════════════════════════════════════════════════════════════════════
// TRACK SIGNALS
// ═══════════════════════════════════════════════════════════════════════════
var float  lastC    = na
var float  lastH    = na
var float  lastStop = na
var float  lastTP1  = na
var float  lastTP2  = na
var string lastDir  = na
var int    lastBar  = na

var array<float>  sigC    = array.new_float(0)
var array<float>  sigStop = array.new_float(0)
var array<float>  sigTP1  = array.new_float(0)
var array<float>  sigTP2  = array.new_float(0)
var array<int>    sigBar  = array.new_int(0)
var array<string> sigDir  = array.new_string(0)

if longSignal
    lastC    := c
    lastH    := h
    lastStop := longStop
    lastTP1  := longTP1
    lastTP2  := longTP2
    lastDir  := "LONG"
    lastBar  := bar_index + arrowOffset
    array.push(sigC,    c)
    array.push(sigStop, longStop)
    array.push(sigTP1,  longTP1)
    array.push(sigTP2,  longTP2)
    array.push(sigBar,  bar_index + arrowOffset)
    array.push(sigDir,  "LONG")
    if array.size(sigC) > 10
        array.shift(sigC)
        array.shift(sigStop)
        array.shift(sigTP1)
        array.shift(sigTP2)
        array.shift(sigBar)
        array.shift(sigDir)

if shortSignal
    lastC    := c
    lastH    := h
    lastStop := shortStop
    lastTP1  := shortTP1
    lastTP2  := shortTP2
    lastDir  := "SHORT"
    lastBar  := bar_index + arrowOffset
    array.push(sigC,    c)
    array.push(sigStop, shortStop)
    array.push(sigTP1,  shortTP1)
    array.push(sigTP2,  shortTP2)
    array.push(sigBar,  bar_index + arrowOffset)
    array.push(sigDir,  "SHORT")
    if array.size(sigC) > 10
        array.shift(sigC)
        array.shift(sigStop)
        array.shift(sigTP1)
        array.shift(sigTP2)
        array.shift(sigBar)
        array.shift(sigDir)

// ═══════════════════════════════════════════════════════════════════════════
// POSITION SIZE
// ═══════════════════════════════════════════════════════════════════════════
riskAmount     = riskMode == "Percentage" ? accountSize * (riskPct / 100) : riskFixed
longQty        = math.round(riskAmount / longRisk,  3)
shortQty       = math.round(riskAmount / shortRisk, 3)
longDollar     = math.round(longQty  * c, 2)
shortDollar    = math.round(shortQty * c, 2)
longSizeLabel  = sizeDisplay == "Quantity" ? "Qty: " + str.tostring(longQty)  : "$: " + str.tostring(longDollar)
shortSizeLabel = sizeDisplay == "Quantity" ? "Qty: " + str.tostring(shortQty) : "$: " + str.tostring(shortDollar)

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS — ARROWS
// ═══════════════════════════════════════════════════════════════════════════
longColor  = counterMode ? color.new(#CC44FF, 0) : color.green
shortColor = counterMode ? color.new(#FF8800, 0) : color.red

plotshape(longSignal,  title="Long",  location=location.belowbar, style=shape.triangleup,   color=longColor,  size=size.small, offset=arrowOffset)
plotshape(shortSignal, title="Short", location=location.abovebar, style=shape.triangledown, color=shortColor, size=size.small, offset=arrowOffset)

// ═══════════════════════════════════════════════════════════════════════════
// SIGNAL LABELS & LINES
// ═══════════════════════════════════════════════════════════════════════════
if not recentOnly and showLevels and longSignal
    label.new(bar_index + labelOffset, h, "E: " + fmtPrice(c), color=color.blue, textcolor=color.white, style=label.style_label_down, size=size.tiny)
    line.new(bar_index + labelOffset, longStop, bar_index + labelOffset + 4, longStop, color=color.red,  width=1, style=line.style_dashed)
    line.new(bar_index + labelOffset, longTP1,  bar_index + labelOffset + 4, longTP1,  color=color.lime, width=1, style=line.style_dashed)
    label.new(bar_index + labelOffset + 4, longStop, "SL "  + fmtPrice(longStop), color=color.red,  textcolor=color.white, style=label.style_label_left, size=size.tiny)
    label.new(bar_index + labelOffset + 4, longTP1,  "TP1 " + fmtPrice(longTP1),  color=color.lime, textcolor=color.black, style=label.style_label_left, size=size.tiny)
    if showTP2
        line.new(bar_index + labelOffset, longTP2, bar_index + labelOffset + 4, longTP2, color=color.green, width=1, style=line.style_dashed)
        label.new(bar_index + labelOffset + 4, longTP2, "TP2 " + fmtPrice(longTP2), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)

if not recentOnly and showSize and longSignal
    label.new(bar_index + labelOffset, longStop, longSizeLabel, color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.tiny)

if not recentOnly and showLevels and shortSignal
    label.new(bar_index + labelOffset, h, "E: " + fmtPrice(c), color=color.blue, textcolor=color.white, style=label.style_label_down, size=size.tiny)
    line.new(bar_index + labelOffset, shortStop, bar_index + labelOffset + 4, shortStop, color=color.red,  width=1, style=line.style_dashed)
    line.new(bar_index + labelOffset, shortTP1,  bar_index + labelOffset + 4, shortTP1,  color=color.lime, width=1, style=line.style_dashed)
    label.new(bar_index + labelOffset + 4, shortStop, "SL "  + fmtPrice(shortStop), color=color.red,  textcolor=color.white, style=label.style_label_left, size=size.tiny)
    label.new(bar_index + labelOffset + 4, shortTP1,  "TP1 " + fmtPrice(shortTP1),  color=color.lime, textcolor=color.black, style=label.style_label_left, size=size.tiny)
    if showTP2
        line.new(bar_index + labelOffset, shortTP2, bar_index + labelOffset + 4, shortTP2, color=color.green, width=1, style=line.style_dashed)
        label.new(bar_index + labelOffset + 4, shortTP2, "TP2 " + fmtPrice(shortTP2), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)

if not recentOnly and showSize and shortSignal
    label.new(bar_index + labelOffset, shortStop, shortSizeLabel, color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// MOST RECENT ONLY
// ═══════════════════════════════════════════════════════════════════════════
if recentOnly and barstate.islast and not na(lastC)
    isLong        = lastDir == "LONG"
    lastRisk      = math.round(riskAmount / math.abs(lastC - lastStop), 3)
    lastDollar    = math.round(lastRisk * lastC, 2)
    lastSizeLabel = sizeDisplay == "Quantity" ? "Qty: " + str.tostring(lastRisk) : "$: " + str.tostring(lastDollar)
    sizeY         = isLong ? lastStop + (lastStop * 0.006) : lastStop - (lastStop * 0.006)
    if showLevels
        line.new(bar_index - 300, lastC,    bar_index + 20, lastC,    color=color.blue,  width=1, style=line.style_dashed)
        line.new(bar_index - 300, lastStop, bar_index + 20, lastStop, color=color.red,   width=1, style=line.style_dashed)
        line.new(bar_index - 300, lastTP1,  bar_index + 20, lastTP1,  color=color.lime,  width=1, style=line.style_dashed)
        label.new(bar_index + 20, lastC,    "E: "  + fmtPrice(lastC),    color=color.blue,  textcolor=color.white, style=label.style_label_left, size=size.tiny)
        label.new(bar_index + 20, lastStop, "SL "  + fmtPrice(lastStop), color=color.red,   textcolor=color.white, style=label.style_label_left, size=size.tiny)
        label.new(bar_index + 20, lastTP1,  "TP1 " + fmtPrice(lastTP1),  color=color.lime,  textcolor=color.black, style=label.style_label_left, size=size.tiny)
        if showTP2
            line.new(bar_index - 300, lastTP2, bar_index + 20, lastTP2, color=color.green, width=1, style=line.style_dashed)
            label.new(bar_index + 20, lastTP2, "TP2 " + fmtPrice(lastTP2), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if showSize
        label.new(bar_index + 20, sizeY, lastSizeLabel, color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// BOXES
// ═══════════════════════════════════════════════════════════════════════════
if showBoxes and barstate.islast
    int total = array.size(sigC)
    if total > 0
        int start = math.max(0, total - boxCount)
        for i = start to total - 1
            bC    = array.get(sigC,    i)
            bStop = array.get(sigStop, i)
            bTP1  = array.get(sigTP1,  i)
            bTP2  = array.get(sigTP2,  i)
            bBar  = array.get(sigBar,  i)
            bIsLong = bTP1 > bC
            box.new(bBar, bIsLong ? bStop : bC,  bBar + boxBars, bIsLong ? bC   : bStop, bgcolor=color.new(color.red,   85), border_color=color.new(color.red,   60), border_width=1)
            box.new(bBar, bIsLong ? bC    : bTP1, bBar + boxBars, bIsLong ? bTP1 : bC,   bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 60), border_width=1)
            if showTP2
                box.new(bBar, bIsLong ? bTP1 : bTP2, bBar + boxBars, bIsLong ? bTP2 : bTP1, bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 70), border_width=1)

// ═══════════════════════════════════════════════════════════════════════════
// S/R — DISPLAY LEVELS
// ═══════════════════════════════════════════════════════════════════════════
levelsPerSide = int(maxLevels / 2)

if showSRLevels and barstate.islast
    rCount = math.min(array.size(topResistances), levelsPerSide)
    if rCount > 0
        for i = 0 to rCount - 1
            if i < array.size(topResistances)
                price   = array.get(topResistances, i)
                score   = array.get(topResistanceScores, i)
                touches = array.get(topResistanceTouches, i)
                lw      = score >= 70 ? 2 : 1
                strength= score >= 70 ? "Strong" : "Moderate"
                if price > close
                    line.new(bar_index - 100, price, bar_index + 50, price, xloc=xloc.bar_index, extend=extend.right, color=resistanceColor, width=lw)
                    if showSRLabels
                        label.new(bar_index + 40, price, "R" + str.tostring(i + 1) + " " + str.tostring(price, format.mintick) + "\n" + strength + " (" + str.tostring(score) + ")\n" + str.tostring(touches) + " touches", xloc=xloc.bar_index, color=resistanceColor, textcolor=color.white, style=label.style_label_left, size=size.small)

    sCount = math.min(array.size(topSupports), levelsPerSide)
    if sCount > 0
        for i = 0 to sCount - 1
            if i < array.size(topSupports)
                price   = array.get(topSupports, i)
                score   = array.get(topSupportScores, i)
                touches = array.get(topSupportTouches, i)
                lw      = score >= 70 ? 2 : 1
                strength= score >= 70 ? "Strong" : "Moderate"
                if price < close
                    line.new(bar_index - 100, price, bar_index + 50, price, xloc=xloc.bar_index, extend=extend.right, color=supportColor, width=lw)
                    if showSRLabels
                        label.new(bar_index + 40, price, "S" + str.tostring(i + 1) + " " + str.tostring(price, format.mintick) + "\n" + strength + " (" + str.tostring(score) + ")\n" + str.tostring(touches) + " touches", xloc=xloc.bar_index, color=supportColor, textcolor=color.white, style=label.style_label_left, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// S/R — PRICE SCALE PLOTS
// ═══════════════════════════════════════════════════════════════════════════
plot(showSRLevels and array.size(topResistances) >= 1 ? array.get(topResistances, 0) : na, title="R1", color=resistanceColor, display=display.price_scale)
plot(showSRLevels and array.size(topResistances) >= 2 ? array.get(topResistances, 1) : na, title="R2", color=resistanceColor, display=display.price_scale)
plot(showSRLevels and array.size(topSupports)    >= 1 ? array.get(topSupports,    0) : na, title="S1", color=supportColor,    display=display.price_scale)
plot(showSRLevels and array.size(topSupports)    >= 2 ? array.get(topSupports,    1) : na, title="S2", color=supportColor,    display=display.price_scale)

// ═══════════════════════════════════════════════════════════════════════════
// BLOCKED SIGNAL LABEL
// ═══════════════════════════════════════════════════════════════════════════
if useSR and barstate.islast and not na(range_pct)
    rawLong  = e13 > e21 and c > o and (o < e13 or o < e21) and c > e13 and c > e21 and h1Trend != "B" and bodyPct >= 0.0015 and emaSpread >= 0.001 and rsiOK("LONG")
    rawShort = e13 < e21 and c < o and (o > e13 or o > e21) and c < e13 and c < e21 and h1Trend != "L" and bodyPct >= 0.0015 and emaSpread >= 0.001 and rsiOK("SHORT")
    blockedLong  = (counterMode ? rawShort : rawLong)  and not longSignal
    blockedShort = (counterMode ? rawLong  : rawShort) and not shortSignal

    if blockedLong
        label.new(bar_index, l * 0.999, "L " + str.tostring(math.round(range_pct, 1)) + "%", color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up,   size=size.small)
    if blockedShort
        label.new(bar_index, h * 1.001, "S " + str.tostring(math.round(range_pct, 1)) + "%", color=color.new(color.red,   20), textcolor=color.white, style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// PROXIMITY ZONE BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════
bgcolor(showZones and barstate.islast and not na(range_pct) and range_pct > long_max_pct and range_pct < short_min_pct ? color.new(color.gray,  75) : na, title="Dead Zone")
bgcolor(showZones and barstate.islast and long_room  ? color.new(color.green, 80) : na, title="Long Zone")
bgcolor(showZones and barstate.islast and short_room ? color.new(color.red,   80) : na, title="Short Zone")

// ═══════════════════════════════════════════════════════════════════════════
// S/R INFO BOX
// ═══════════════════════════════════════════════════════════════════════════
getTFDisp() =>
    string r = ""
    if timeframe.isminutes
        m = timeframe.multiplier
        if m < 60
            r := str.tostring(m) + "m"
        else if m == 60
            r := "H1"
        else if m == 240
            r := "H4"
        else
            r := str.tostring(m) + "m"
    else if timeframe.isdaily
        r := "D1"
    else if timeframe.isweekly
        r := "W1"
    else
        r := timeframe.period
    r

if showSRLevels and barstate.islast
    absoluteMax     = math.max(0, bar_index - lookback)
    safeBarsToScan2 = math.min(activeBars, absoluteMax)
    tfMins    = timeframe.multiplier * (timeframe.isminutes ? 1.0 : timeframe.isdaily ? 1440.0 : timeframe.isweekly ? 10080.0 : 60.0)
    totalMins = safeBarsToScan2 * tfMins
    durStr    = totalMins < 120 ? str.tostring(math.round(totalMins)) + " mins" : totalMins < 2880 ? str.tostring(math.round(totalMins / 60, 1)) + " hours" : str.tostring(math.round(totalMins / 1440, 1)) + " days"
    autoLbl   = autoBar ? " (auto)" : " (manual)"
    zoneLabel = not na(range_pct) ? (long_room ? "LONG ZONE" : short_room ? "SHORT ZONE" : "DEAD ZONE") : "NO ZONE"
    zonePct   = not na(range_pct) ? " (" + str.tostring(math.round(range_pct, 1)) + "%)" : ""
    srInfoText = "S/R LEVELS\n----------------\nTF: " + getTFDisp() + "\nBars: " + str.tostring(safeBarsToScan2) + autoLbl + "\nDuration: " + durStr + "\nTotal bars: " + str.tostring(bar_index + 1) + "\n----------------\n" + zoneLabel + zonePct
    srBoxColor  = long_room ? color.new(color.green, 20) : short_room ? color.new(color.red, 20) : color.new(color.gray, 20)
    srBdrColor  = long_room ? color.new(color.green, 0)  : short_room ? color.new(color.red, 0)  : color.new(color.white, 60)
    var table srInfoTable = table.new(position=position.top_right, columns=1, rows=1, bgcolor=srBoxColor, border_width=1, border_color=srBdrColor)
    table.cell(srInfoTable, 0, 0, srInfoText, text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=srBoxColor)

// ═══════════════════════════════════════════════════════════════════════════
// INFO BOX
// ═══════════════════════════════════════════════════════════════════════════
if showInfo and barstate.islast
    _tfRaw     = useChartTF ? timeframe.period : tfInput
    _tfMult    = useChartTF ? timeframe.multiplier : int(str.tonumber(tfInput))
    _tfIsMin   = useChartTF ? timeframe.isminutes : true
    _tfFmt     = _tfIsMin and _tfMult < 60 ? "m" + str.tostring(_tfMult) : _tfIsMin and _tfMult == 60 ? "H1" : _tfIsMin and _tfMult == 120 ? "H2" : _tfIsMin and _tfMult == 240 ? "H4" : _tfIsMin and _tfMult == 720 ? "H12" : not _tfIsMin and timeframe.isdaily ? "D" + str.tostring(_tfMult) : not _tfIsMin and timeframe.isweekly ? "W" + str.tostring(_tfMult) : not _tfIsMin and timeframe.ismonthly ? "Mo" + str.tostring(_tfMult) : _tfRaw
    tfDisplay  = _tfFmt + (useChartTF ? " (Chart)" : "")
    h1Display  = h1Trend == "L" ? "Bullish" : h1Trend == "B" ? "Bearish" : "Neutral"
    modeLine   = waitForClose ? "" : "\n⚠️ Current Candle Mode"
    srLine     = useSR ? "\nS/R Filter: ON" + (not na(range_pct) ? " (" + str.tostring(math.round(range_pct, 1)) + "%)" : " (no levels)") : "\nS/R Filter: OFF"
    counterLine = counterMode ? "\n⚡ COUNTER MODE ON" : ""
    infoText   = "PR+\nTF: " + tfDisplay + "\nConfluence: " + confluence + "\nTP Mode: " + tpMode + "\n1H Trend: " + h1Display + "\n4H Trend: " + h4Trend + "\nRisk: " + (riskMode == "Percentage" ? str.tostring(riskPct) + "% = $" + str.tostring(math.round(riskAmount, 2)) : "$" + str.tostring(riskFixed)) + srLine + modeLine + counterLine
    boxBgColor  = counterMode ? color.new(#440066, 50) : color.new(color.gray, 40)
    boxBdrColor = counterMode ? color.new(#CC44FF, 0)  : color.new(color.gray, 50)
    var table infoTable = table.new(position.bottom_right, 1, 1, bgcolor=boxBgColor, border_color=boxBdrColor, border_width=1)
    table.cell(infoTable, 0, 0, infoText, text_color=color.white, text_size=size.small, bgcolor=boxBgColor)
````
