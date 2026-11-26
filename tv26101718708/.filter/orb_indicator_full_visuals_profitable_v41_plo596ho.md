# ORB Indicator + Full Visuals (PROFITABLE V4.1)

- url: https://www.tradingview.com/script/PLO596hO-ORB-Indicator-Full-Visuals-PROFITABLE-V4-1/
- type: indicator
- pine_id: PUB;f1afa655fcef4558b699c2eae204ff14
- version: 1.0

## Description

Here is a clean, professional, and ready-to-use description you can copy and paste when publishing this script on TradingView.

ORB Strategy + Full Visuals (PROFITABLE V4.1) — Pure Indicator Edition
Overview
This script is a comprehensive conversion of the highly robust Opening Range Breakout (ORB) system into a fully visualized Indicator. Built specifically for active intraday traders targeting liquid instruments like Nasdaq-100 Futures (MNQ/NQ), Gold Futures (MGC/GC), and high-momentum equities, this tool handles complex mathematical tracking entirely on your chart without requiring the strategy tester.

Equipped with dual execution methodologies (Breakout and Mean Reversion), it features an intelligent, multi-target tracking state engine designed to scale out of positions and trail protection rules in real time.

Key Features
Intraday State Machine Tracking Engine: Automatically maps out dynamic, simulated trades directly from bar closes—calculating entry levels, profit targets, and trailing parameters seamlessly.

Multi-Target Scaling Logic:

Target 1 (1.5x ATR): Deployed as a high-probability scale-out marker. When achieved, the internal engine automatically trails the initial stop-loss to a strict breakeven level (entryPrice).

Target 2 (3.0x ATR): Stretched run target to maximize structural trends.

Dual Mode Architecture: Toggle instantly via inputs between asset classes and regimes:

Breakout Mode: Captures explosive volatility expansions when high/low thresholds cross along with supporting EMA and SMA alignment.

Mean Reversion Mode: Fades overextended moves targeting standard deviation extremes outside the Volume Weighted Average Price (VWAP).

Comprehensive Visual HUD & Dashboard: Built-in table tracking real-time asset distance from VWAP deviations, current ORB structures, and Yesterday's High/Low reference bands.

Capital Protection Guardrails: Fully restricted by a mandatory daily trade ceiling cap (maxTrades) preventing over-trading and emotional revenges during choppy distributions.

How to Trade It & Visual Legends
▲ LONG / ▼ SHORT: Clear entry signals plotted on the candle trigger.

TP1 Label (Small ✖): Confirms Target 1 was successfully scaled. Protection parameters for remaining units instantly snap to the entry price line.

TP2 TARGET Label (Large ✖): Confirms the final target was met and the trade has successfully completed.

STOP Label (✖): Highlights where either initial structural stop-loss or breakeven parameters were hit.

Inputs and Configurations
ORB Window: Default setup at 0930-0945 (First 15 minutes of the New York session).

Trading Hours: Default trading execution cutoff at 1130 to prevent trading into low-liquidity afternoon lunch doldrums.

Risk Metrics: Fully adjustable ATR multipliers for complete adaptability across volatile timeframes (1-minute, 3-minute, or 5-minute charts).

## Source Code

````pine
//@version=6
indicator('ORB Indicator + Full Visuals (PROFITABLE V4.1)', overlay = true, max_labels_count = 100)

// ===== INPUTS =====
sess = input.session('0930-0945', 'ORB Window')
tz = input.string('America/New_York', 'Timezone')
mode = input.string('Breakout', 'Logic', options = ['Breakout', 'MeanReversion'])
fastLen = input.int(9, 'Fast EMA (blue)')
slowLen = input.int(20, 'Slow EMA (orange)')
midLen = input.int(50, 'Mid SMA (white)')
tradeStart = input.session('0930-1130', 'Trading Hours')
showBands = input.bool(true, 'VWAP σ Bands')

// --- Fixed Multi-Target Scaling Inputs ---
atrLen = input.int(14, 'ATR Length')
tp1AtrMult = input.float(1.5, 'Target 1 ATR Multiplier')
tp2AtrMult = input.float(3.0, 'Target 2 ATR Multiplier')
maxTrades = input.int(2, 'Max Daily Trades')

tickSz = syminfo.mintick

// ===== ORB =====
inORB = not na(time(timeframe.period, sess, tz))
newDay = ta.change(time('D')) != 0

var float orbH = na
var float orbL = na
var bool orbDone = false
if newDay
    orbH := na
    orbL := na
    orbDone := false
    orbDone
if inORB
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low : math.min(orbL, low)
    orbL
else if not na(orbH)
    orbDone := true
    orbDone

// ===== PRIOR DAY =====
pdh = request.security(syminfo.tickerid, 'D', high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_on)

// ===== MAs & ATR =====
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
smaMid = ta.sma(close, midLen)
atr = ta.atr(atrLen)

plot(emaFast, 'Fast EMA', color.new(color.blue, 0), 2)
plot(emaSlow, 'Slow EMA', color.new(color.orange, 0), 2)
plot(smaMid, 'Mid SMA', color.new(color.white, 0), 2)

// ===== VWAP + BANDS =====
vw = ta.vwap(hlc3)
var float ss = 0.0
var float sv = 0.0
if newDay
    ss := 0.0
    sv := 0.0
    sv
ss := ss + volume * math.pow(hlc3 - vw, 2)
sv := sv + volume
dev = sv > 0 ? math.sqrt(ss / sv) : 0.0
cb = color.new(color.teal, 60)
plot(vw, 'VWAP', color.new(color.white, 0), 2)
plot(showBands ? vw + dev : na, '+1σ', cb)
plot(showBands ? vw + 2 * dev : na, '+2σ', cb)
plot(showBands ? vw + 3 * dev : na, '+3σ', cb)
plot(showBands ? vw - dev : na, '-1σ', cb)
plot(showBands ? vw - 2 * dev : na, '-2σ', cb)
plot(showBands ? vw - 2 * dev : na, '-2σ', cb)
plot(showBands ? vw - 3 * dev : na, '-3σ', cb)

// ===== LEVEL LINES =====
plot(orbDone ? orbH : na, 'ORB High', color.yellow, 2, plot.style_linebr)
plot(orbDone ? orbL : na, 'ORB Low', color.yellow, 2, plot.style_linebr)
plot(pdh, 'PDH', color.orange, 1, plot.style_linebr)
plot(pdl, 'PDL', color.orange, 1, plot.style_linebr)

// ===== RIGHT-EDGE LABELS =====
var label lOrbH = na
var label lOrbL = na
var label lPdh = na
var label lPdl = na
var label lVw = na
if barstate.islast
    label.delete(lOrbH)
    label.delete(lOrbL)
    label.delete(lPdh)
    label.delete(lPdl)
    label.delete(lVw)
    x = bar_index + 3
    if orbDone
        lOrbH := label.new(x, orbH, 'ORB High', style = label.style_label_left, color = color.new(color.yellow, 80), textcolor = color.yellow, size = size.small)
        lOrbL := label.new(x, orbL, 'ORB Low', style = label.style_label_left, color = color.new(color.yellow, 80), textcolor = color.yellow, size = size.small)
        lOrbL
    lPdh := label.new(x, pdh, 'PDH', style = label.style_label_left, color = color.new(color.orange, 80), textcolor = color.orange, size = size.small)
    lPdl := label.new(x, pdl, 'PDL', style = label.style_label_left, color = color.new(color.orange, 80), textcolor = color.orange, size = size.small)
    lVw := label.new(x, vw, 'VWAP', style = label.style_label_left, color = color.new(color.white, 80), textcolor = color.white, size = size.small)
    lVw

// ===== INFO TABLE =====
var table t = table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 20), border_width = 1)
if barstate.islast
    pos = close > vw + dev ? 'ABOVE +1σ' : close < vw - dev ? 'BELOW -1σ' : 'INSIDE BANDS'
    table.cell(t, 0, 0, 'Distance', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 0, str.tostring((close - vw) / vw * 100, '#.##') + '%', text_color = color.white, text_size = size.tiny)
    table.cell(t, 0, 1, 'Position', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 1, pos, text_color = color.teal, text_size = size.tiny)
    table.cell(t, 0, 2, 'ORB High', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 2, orbDone ? str.tostring(orbH) : 'Building...', text_color = color.yellow, text_size = size.tiny)
    table.cell(t, 0, 3, 'ORB Low', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 3, orbDone ? str.tostring(orbL) : 'Building...', text_color = color.yellow, text_size = size.tiny)
    table.cell(t, 0, 4, 'Prev High', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 4, str.tostring(pdh), text_color = color.orange, text_size = size.tiny)
    table.cell(t, 0, 5, 'Prev Low', text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 5, str.tostring(pdl), text_color = color.orange, text_size = size.tiny)

canTrade = not na(time(timeframe.period, tradeStart, tz))
risk = orbH - orbL

// ===== INTRADAY TRADE TRACKING STATE ENGINE =====
var int dailyTradesCount = 0
var int state = 0 // 0 = Flat, 1 = Long (Both Targets Active), 2 = Long (Target 1 Hit, Breakeven Stop Active), -1 = Short (Both Targets Active), -2 = Short (Target 1 Hit, Breakeven Stop Active)
var float entryPrice = na
var float initialStop = na
var float bp1 = na
var float bp2 = na

if newDay
    dailyTradesCount := 0
    state := 0
    entryPrice := na
    initialStop := na
    bp1 := na
    bp2 := na
    bp2

allowedByCap = dailyTradesCount < maxTrades

// ===== RAW CONDITIONS =====
longCondRaw = false
shortCondRaw = false
if mode == 'Breakout'
    longCondRaw := orbDone and canTrade and allowedByCap and ta.crossover(close, orbH) and emaFast > emaSlow and close > smaMid
    shortCondRaw := orbDone and canTrade and allowedByCap and ta.crossunder(close, orbL) and emaFast < emaSlow and close < smaMid
    shortCondRaw
else
    longCondRaw := orbDone and canTrade and allowedByCap and close < vw - 2 * dev and ta.crossover(close, low[1]) and close > smaMid
    shortCondRaw := orbDone and canTrade and allowedByCap and close > vw + 2 * dev and ta.crossunder(close, high[1]) and close < smaMid
    shortCondRaw

// Only trigger entry signals if the engine is completely flat
longCond = longCondRaw and state == 0
shortCond = shortCondRaw and state == 0

// ===== STATE MANAGEMENT ENGINE =====
if longCond
    state := 1
    dailyTradesCount := dailyTradesCount + 1
    entryPrice := close
    initialStop := mode == 'Breakout' ? orbL : entryPrice - risk
    bp1 := entryPrice + atr * tp1AtrMult
    bp2 := entryPrice + atr * tp2AtrMult
    bp2

if shortCond
    state := -1
    dailyTradesCount := dailyTradesCount + 1
    entryPrice := close
    initialStop := mode == 'Breakout' ? orbH : entryPrice + risk
    bp1 := entryPrice - atr * tp1AtrMult
    bp2 := entryPrice - atr * tp2AtrMult
    bp2

// --- Active Trade Simulation Management ---
bool longExitedTp1 = false
bool longExitedTp2 = false
bool longExitedStop = false

bool shortExitedTp1 = false
bool shortExitedTp2 = false
bool shortExitedStop = false

// Long Management Loops
if state == 1
    if high >= bp1
        state := 2 // Target 1 Achieved -> Trail stop to Breakeven
        longExitedTp1 := true
        longExitedTp1
    if low <= initialStop
        state := 0 // Stopped out completely
        longExitedStop := true
        longExitedStop

if state == 2
    if high >= bp2
        state := 0 // Target 2 Achieved -> Trade Finished Successfully
        longExitedTp2 := true
        longExitedTp2
    if low <= entryPrice
        state := 0 // Stopped out at Breakeven
        longExitedStop := true
        longExitedStop

// Short Management Loops
if state == -1
    if low <= bp1
        state := -2 // Target 1 Achieved -> Trail stop to Breakeven
        shortExitedTp1 := true
        shortExitedTp1
    if high >= initialStop
        state := 0 // Stopped out completely
        shortExitedStop := true
        shortExitedStop

if state == -2
    if low <= bp2
        state := 0 // Target 2 Achieved -> Trade Finished Successfully
        shortExitedTp2 := true
        shortExitedTp2
    if high >= entryPrice
        state := 0 // Stopped out at Breakeven
        shortExitedStop := true
        shortExitedStop

// End of Day force-flush optimization
if newDay and state != 0
    state := 0
    state

// ===== PLOTS, SHAPES & ALERTS =====
plotshape(longCond, 'LONG ENTRY', shape.triangleup, location.belowbar, color.new(color.green, 0), size = size.small, text = 'LONG')
plotshape(shortCond, 'SHORT ENTRY', shape.triangledown, location.abovebar, color.new(color.red, 0), size = size.small, text = 'SHORT')

// Exit tracking plots for charting precision
plotshape(longExitedTp1, 'LONG TP1 HIT', shape.xcross, location.abovebar, color.new(color.green, 30), size = size.tiny, text = 'TP1')
plotshape(longExitedTp2, 'LONG TP2 HIT', shape.xcross, location.abovebar, color.new(color.green, 0), size = size.small, text = 'TP2 TARGET')
plotshape(longExitedStop, 'LONG STOPPED', shape.xcross, location.belowbar, color.new(color.red, 0), size = size.small, text = 'STOP')

plotshape(shortExitedTp1, 'SHORT TP1 HIT', shape.xcross, location.belowbar, color.new(color.red, 30), size = size.tiny, text = 'TP1')
plotshape(shortExitedTp2, 'SHORT TP2 HIT', shape.xcross, location.belowbar, color.new(color.red, 0), size = size.small, text = 'TP2 TARGET')
plotshape(shortExitedStop, 'SHORT STOPPED', shape.xcross, location.abovebar, color.new(color.red, 0), size = size.small, text = 'STOP')

// Native Conditional Alert Triggers
alertcondition(longCond, title = 'Long Entry Alert', message = 'ORB Indicator: Long Breakout Entry Triggered.')
alertcondition(shortCond, title = 'Short Entry Alert', message = 'ORB Indicator: Short Breakout Entry Triggered.')
alertcondition(longExitedTp1 or shortExitedTp1, title = 'Scale Target 1 Alert', message = 'ORB Indicator: Target 1 Scaling achieved. Stop adjusted to Breakeven.')
alertcondition(longExitedTp2 or shortExitedTp2, title = 'Target 2 Profit Complete Alert', message = 'ORB Indicator: Target 2 completely filled. Trade finished.')
alertcondition(longExitedStop or shortExitedStop, title = 'Stop-Loss Hit Alert', message = 'ORB Indicator: Stop-loss executed. Protection closed position.')
````
