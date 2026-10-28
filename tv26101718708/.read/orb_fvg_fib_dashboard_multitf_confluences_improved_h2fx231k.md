# ORB + FVG -  FIB Dashboard & Multi-TF Confluences [Improved]

- url: https://www.tradingview.com/script/H2fx231K-ORB-FVG-FIB-Dashboard-Multi-TF-Confluences-Improved/
- type: indicator
- pine_id: PUB;6e84ea9b319e4a08857d5a01a1692ea0
- version: 1.0

## Description

Advanced ORB + ICT PD-Array Confluence System [15m]
This institutional-grade breakout indicator is designed specifically for high-precision trading on indices like QQQ, SPY, and NQ. It combines the power of the 15-Minute Opening Range Breakout (ORB) with ICT PD Arrays (Fair Value Gaps & Order Blocks) and a sophisticated multi-factor confluence engine.

Unlike standard breakout indicators, this system requires price action to prove itself through institutional momentum (FVGs) and structural retests (Fibonacci Pullbacks) before issuing a signal.

🧠 Core Methodology
1. The 15-Minute Opening Range
The script automatically captures the high and low of the first 15 minutes of the New York session (09:30–09:45). These levels act as the "Battleground" for the rest of the day.

2. Institutional PD Arrays (FVG & OB)
The indicator identifies and tracks Fair Value Gaps (+/-FVG) and Order Blocks (+/-OB) using standard ICT logic.

Internal FVGs: Identifies institutional buildup inside the range before the snap.
External FVGs: Confirms institutional displacement beyond the range during the breakout.
Persistent Tracking: Boxes extend to the right automatically and are removed only when the gap is "filled" by price action.
3. Multi-Factor Confluence Dashboard
The real-time dashboard monitors 9 unique confluences to give you a "Strength Score" out of 9:

Volume & RSI: Momentum and relative strength confirmation.
MACD & EMA Cross: Trend alignment.
4H EMA: Higher Timeframe (HTF) trend filtering.
Fibonacci Pullback: Option to require a pullback to the .382, .500, or .618 levels before signal confirmation (preventing "chasing" the move).
📊 Performance Dashboard
Stop guessing which confluences work best. The built-in Performance Dashboard tracks:

Total Trades: Every signal fired within your chosen date range.
Win/Loss Record: Based on a strict 1:1 Risk/Reward logic (opposite range side as SL).
Win Rate %: Updates in real-time as you toggle confluences on or off, allowing you to find the "Sweet Spot" for the current market regime.
🛠 How to Trade This System
Establish the Range: Wait for the 15-minute box to form at the NY Open.
Monitor the Bias: The dashboard will show Long or Short Bias based on price relation to the range midline.
Check Confluences: Look for a Strength Score of 7/9 or higher.
The Retest: If enabled, wait for the price to tap the chosen Fibonacci level after the breakout.
Entry: Execute on the BUY/SELL or FLIP labels.
Exit: The script prints a clear ORANGE EXIT label when the 9/20 EMA crosses in the opposite direction.
⚙️ Settings Highlights
Custom Sessions: Adjust the ORB window (e.g., 5-min or 30-min).
ICT Visuals: Lighter neon green FVGs and internal box labels (+FVG, -OB).
Date Range Backtest: Define a specific start/end date for the performance stats.
Fully Configurable: Toggle every filter on or off to suit your style.
Disclaimer: Trading involves significant risk. This tool is designed to assist with confluence and data visualization, not to provide financial advice. Always practice proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("ORB + FVG - Dashboard & Multi-TF Confluences [Improved]", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ── Constants ──
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #5b9cf6
color EXIT_COLOR    = #ff9800

// ── Inputs ──
// ORB Settings
string orbSession     = input.session("0930-0945", "ORB Session", group = "ORB Settings")
string orbTf          = input.timeframe("1", "ORB Calculation Timeframe", group = "ORB Settings")
color fibColor        = input.color(color.new(#ff9800, 70), "Golden Pocket Color", group = "ORB Settings")
color orbBorderColor  = input.color(color.new(color.gray, 80), "ORB Border Color", group = "ORB Settings")

// Confluence Filters
bool useVolFilter   = input.bool(true,  "Volume Filter",   group = "Confluences")
bool useRsiFilter   = input.bool(true,  "RSI Filter",      group = "Confluences")
bool useFvgFilter   = input.bool(true,  "FVG Filter",      group = "Confluences")
bool useMacdFilter  = input.bool(true,  "MACD Filter",     group = "Confluences")
bool useEma4hFilter = input.bool(true,  "4H EMA Filter",   group = "Confluences")
bool useEmaCross    = input.bool(true,  "EMA Cross Filter",group = "Confluences")

// Advanced Confluences
bool useIntFvg      = input.bool(false, "Internal FVG Confluence", group = "Advanced Confluences")
bool useExtFvg      = input.bool(false, "External FVG Confluence", group = "Advanced Confluences")
bool useFib382      = input.bool(false, "Require .382 Retrace", group = "Advanced Confluences", inline = "fib")
bool useFib500      = input.bool(false, "Require .500 Retrace", group = "Advanced Confluences", inline = "fib")
bool useFib618      = input.bool(false, "Require .618 Retrace", group = "Advanced Confluences", inline = "fib")

// Filter Settings
float volMult       = input.float(1.1, "Volume Multiplier", minval = 0.1, group = "Filter Settings")
int rsiThresh       = input.int(50, "RSI Threshold", minval = 1, maxval = 99, group = "Filter Settings")
int emaFastLen      = input.int(9,  "Fast EMA Length",  group = "Filter Settings")
int emaSlowLen      = input.int(20, "Slow EMA Length",  group = "Filter Settings")
int ema4hLen        = input.int(20, "4H EMA Length",    group = "Filter Settings")

// Performance Settings
bool showPerfDB     = input.bool(true, "Show Performance Dashboard", group = "Performance Settings")
string perfDBPos    = input.string("Bottom Right", "Performance Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Performance Settings")
int startTime       = input.time(timestamp("2024-01-01 00:00"), "Backtest Start Date", group = "Performance Settings")
int endTime         = input.time(timestamp("2030-01-01 00:00"), "Backtest End Date", group = "Performance Settings")

// Visual Settings
bool showDashboard  = input.bool(true,  "Show Signal Dashboard",   group = "Visual Settings")
string dbPosition   = input.string("Top Right", "Signal Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Visual Settings")
bool showLabels     = input.bool(true,  "Show Signal Labels", group = "Visual Settings")
bool showFvgBoxes   = input.bool(true,  "Show FVG Boxes",     group = "Visual Settings")
int fvgOpacity      = input.int(85, "FVG Opacity", minval = 0, maxval = 100, group = "Visual Settings")

// ── UDT for FVG Tracking ──
type FVG_Data
    box   boxObj
    float top
    float bottom
    bool  isBull
    bool  isFilled

// ── Functions ──
f_dbCell(table tbl, int col, string title, bool filterUsed, bool cond) =>
    color colr = filterUsed ? (cond ? color.new(BULL_COLOR, 30) : color.new(BEAR_COLOR, 30)) : color.new(color.gray, 60)
    table.cell(tbl, col, 0, title, text_color = chart.fg_color, text_size = size.small)
    table.cell(tbl, col, 1, filterUsed ? (cond ? "MET" : "WAIT") : "OFF", bgcolor = colr, text_color = color.white, text_size = size.small)

// ── ORB Logic ──
[hTf, lTf] = request.security(syminfo.tickerid, orbTf, [high, low], lookahead = barmerge.lookahead_on)

bool inSession = not na(time(timeframe.period, orbSession, "America/New_York"))
bool isNewDay  = ta.change(time("D")) != 0

var float orbHigh = na
var float orbLow  = na
var int   orbStartIdx = na

// State Tracking
var bool hasIntFvgLong = false
var bool hasIntFvgShort = false
var bool hasExtFvgLong = false
var bool hasExtFvgShort = false
var float breakoutPeak = na
var float breakoutTrough = na
var bool metFib382 = false
var bool metFib500 = false
var bool metFib618 = false

if isNewDay
    orbHigh := na, orbLow := na, orbStartIdx := na
    hasIntFvgLong := false, hasIntFvgShort := false, hasExtFvgLong := false, hasExtFvgShort := false
    breakoutPeak := na, breakoutTrough := na
    metFib382 := false, metFib500 := false, metFib618 := false

if inSession
    if na(orbStartIdx)
        orbStartIdx := bar_index
    orbHigh := na(orbHigh) ? hTf : math.max(orbHigh, hTf)
    orbLow  := na(orbLow)  ? lTf : math.min(orbLow,  lTf)

// ── Indicators ──
float volAvg     = ta.sma(volume, 20)
bool  volMet     = volume > volAvg * volMult or volume > volume[1]
[_, _, macdHist] = ta.macd(close, 12, 26, 9)
float rsiVal     = ta.rsi(close, 14)
float ema4h      = request.security(syminfo.tickerid, "240", ta.ema(close, ema4hLen)[1])
float emaFast    = ta.ema(close, emaFastLen)
float emaSlow    = ta.ema(close, emaSlowLen)

// ── FVG Logic & Visuals ──
bool bullFVG = low > high[2]
bool bearFVG = high < low[2]

var fvgArray = array.new<FVG_Data>()

if not na(orbHigh)
    if bullFVG
        if high[2] < orbHigh and high[2] > orbLow
            hasIntFvgLong := true
        if low > orbHigh
            hasExtFvgLong := true
    if bearFVG
        if low[2] > orbLow and low[2] < orbHigh
            hasIntFvgShort := true
        if high < orbLow
            hasExtFvgShort := true

if showFvgBoxes
    if bullFVG
        box b = box.new(bar_index-2, low, bar_index, high[2], bgcolor = color.new(BULL_COLOR, fvgOpacity), border_color = na)
        fvgArray.push(FVG_Data.new(b, low, high[2], true, false))
    if bearFVG
        box b = box.new(bar_index-2, low[2], bar_index, high, bgcolor = color.new(BEAR_COLOR, fvgOpacity), border_color = na)
        fvgArray.push(FVG_Data.new(b, low[2], high, false, false))

if fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        FVG_Data gap = fvgArray.get(i)
        if not gap.isFilled
            if gap.isBull
                if low <= gap.bottom
                    gap.isFilled := true
            else
                if high >= gap.top
                    gap.isFilled := true
            if not gap.isFilled
                gap.boxObj.set_right(bar_index)
        
        if bar_index - gap.boxObj.get_left() > 300
            if not gap.isFilled
                gap.boxObj.delete()
            fvgArray.remove(i)

// ── Fib Retrace Logic ──
if not na(orbHigh)
    if close > orbHigh
        breakoutPeak := math.max(nz(breakoutPeak, high), high)
        float dist = breakoutPeak - orbHigh
        if dist > 0
            if low <= breakoutPeak - dist * 0.382 
                metFib382 := true
            if low <= breakoutPeak - dist * 0.500 
                metFib500 := true
            if low <= breakoutPeak - dist * 0.618 
                metFib618 := true
    else if close < orbLow
        breakoutTrough := math.min(nz(breakoutTrough, low), low)
        float dist = orbLow - breakoutTrough
        if dist > 0
            if high >= breakoutTrough + dist * 0.382 
                metFib382 := true
            if high >= breakoutTrough + dist * 0.500 
                metFib500 := true
            if high >= breakoutTrough + dist * 0.618 
                metFib618 := true

// ── Signal Conditions ──
bool baseLong  = (not useVolFilter or volMet) and (not useRsiFilter or rsiVal > rsiThresh) and (not useFvgFilter or bullFVG) and (not useMacdFilter or macdHist > 0) and (not useEma4hFilter or close > ema4h) and (not useEmaCross or emaFast > emaSlow)
bool baseShort = (not useVolFilter or volMet) and (not useRsiFilter or rsiVal < (100 - rsiThresh)) and (not useFvgFilter or bearFVG) and (not useMacdFilter or macdHist < 0) and (not useEma4hFilter or close < ema4h) and (not useEmaCross or emaFast < emaSlow)

bool fibActive = useFib382 or useFib500 or useFib618
bool fibMet    = (not useFib382 or metFib382) and (not useFib500 or metFib500) and (not useFib618 or metFib618)
bool advLong   = (not useIntFvg or hasIntFvgLong) and (not useExtFvg or hasExtFvgLong) and (not fibActive or fibMet)
bool advShort  = (not useIntFvg or hasIntFvgShort) and (not useExtFvg or hasExtFvgShort) and (not fibActive or fibMet)

var int signalState = 0
bool afterSession = not inSession and not na(orbHigh)
bool withinRange  = time >= startTime and time <= endTime

bool buySignal   = withinRange and afterSession and signalState == 0 and close > orbHigh and baseLong and advLong
bool sellSignal  = withinRange and afterSession and signalState == 0 and close < orbLow and baseShort and advShort
bool flipToShort = withinRange and signalState == 1 and close < orbLow and baseShort and advShort
bool flipToLong  = withinRange and signalState == -1 and close > orbHigh and baseLong and advLong

// Exit Logic State
var bool exitTriggered = true
var int  lastSignalBar = 0
bool exitLong  = false
bool exitShort = false

if buySignal or flipToLong
    signalState := 1
    exitTriggered := false
    lastSignalBar := bar_index
else if sellSignal or flipToShort
    signalState := -1
    exitTriggered := false
    lastSignalBar := bar_index

// Detect 9/20 EMA Cross in opposite direction - ensuring it's not the same bar as the signal
if not exitTriggered and bar_index > lastSignalBar
    if signalState == 1 and ta.crossunder(emaFast, emaSlow)
        exitLong := true
        exitTriggered := true
    else if signalState == -1 and ta.crossover(emaFast, emaSlow)
        exitShort := true
        exitTriggered := true

if isNewDay
    signalState := 0
    exitTriggered := true

// ── Performance Logic ──
var int   totalTrades = 0
var int   wins        = 0
var bool  tradeActive = false
var int   tradeDir    = 0
var float tpPrice     = 0.0
var float slPrice     = 0.0

if withinRange
    if (buySignal or flipToLong) and not tradeActive
        tradeActive := true, tradeDir := 1, totalTrades += 1
        float risk = close - orbLow
        tpPrice := close + risk, slPrice := orbLow
    else if (sellSignal or flipToShort) and not tradeActive
        tradeActive := true, tradeDir := -1, totalTrades += 1
        float risk = orbHigh - close
        tpPrice := close - risk, slPrice := orbHigh

    if tradeActive
        if tradeDir == 1
            if high >= tpPrice
                wins += 1, tradeActive := false
            else if low <= slPrice
                tradeActive := false
        else if tradeDir == -1
            if low <= tpPrice
                wins += 1, tradeActive := false
            else if high >= slPrice
                tradeActive := false

// ── Dashboards ──
if barstate.islast
    if showDashboard
        string posS = dbPosition == "Top Right" ? position.top_right : dbPosition == "Top Left" ? position.top_left : dbPosition == "Bottom Right" ? position.bottom_right : position.bottom_left
        table db = table.new(posS, 13, 2, border_width = 1, border_color = color.new(chart.fg_color, 70))
        bool biasL = close > (orbHigh + orbLow) / 2
        table.cell(db, 0, 0, "Confluence", bgcolor = color.new(chart.fg_color, 90), text_color = chart.fg_color)
        table.cell(db, 0, 1, biasL ? "LONG BIAS" : "SHORT BIAS", bgcolor = biasL ? color.new(BULL_COLOR, 70) : color.new(BEAR_COLOR, 70), text_color = color.white)
        f_dbCell(db, 1, "Vol", useVolFilter, volMet), f_dbCell(db, 2, "RSI", useRsiFilter, biasL ? rsiVal > rsiThresh : rsiVal < (100 - rsiThresh)), f_dbCell(db, 3, "FVG", useFvgFilter, biasL ? bullFVG : bearFVG), f_dbCell(db, 4, "MACD", useMacdFilter, biasL ? macdHist > 0 : macdHist < 0), f_dbCell(db, 5, "4H EMA", useEma4hFilter, biasL ? close > ema4h : close < ema4h), f_dbCell(db, 6, "Cross", useEmaCross, biasL ? emaFast > emaSlow : emaFast < emaSlow), f_dbCell(db, 7, "Int FVG", useIntFvg, biasL ? hasIntFvgLong : hasIntFvgShort), f_dbCell(db, 8, "Ext FVG", useExtFvg, biasL ? hasExtFvgLong : hasExtFvgShort), f_dbCell(db, 9, ".382", useFib382, metFib382), f_dbCell(db, 10, ".500", useFib500, metFib500), f_dbCell(db, 11, ".618", useFib618, metFib618)
    
    if showPerfDB
        string posP = perfDBPos == "Top Right" ? position.top_right : perfDBPos == "Top Left" ? position.top_left : perfDBPos == "Bottom Right" ? position.bottom_right : position.bottom_left
        table pdb = table.new(posP, 2, 4, border_width = 1, border_color = color.new(chart.fg_color, 70))
        float wr = totalTrades > 0 ? (wins / float(totalTrades)) * 100 : 0
        table.cell(pdb, 0, 0, "Performance", bgcolor = color.new(chart.fg_color, 80), text_color = color.white), table.merge_cells(pdb, 0, 0, 1, 0)
        table.cell(pdb, 0, 1, "Total Trades:", text_color = chart.fg_color, text_halign = text.align_left), table.cell(pdb, 1, 1, str.tostring(totalTrades), text_color = chart.fg_color)
        table.cell(pdb, 0, 2, "Wins / Losses:", text_color = chart.fg_color, text_halign = text.align_left), table.cell(pdb, 1, 2, str.tostring(wins) + " / " + str.tostring(totalTrades - wins), text_color = chart.fg_color)
        table.cell(pdb, 0, 3, "Win Rate:", text_color = color.white, bgcolor = BULL_COLOR, text_halign = text.align_left), table.cell(pdb, 1, 3, str.tostring(wr, "#.##") + "%", text_color = color.white, bgcolor = BULL_COLOR)

// ── Visuals ──
p1 = plot(orbHigh, "ORB High", BULL_COLOR, 2, plot.style_linebr)
p2 = plot(orbLow,  "ORB Low",  BEAR_COLOR, 2, plot.style_linebr)
plotshape(showLabels and buySignal, style = shape.labelup, location = location.belowbar, color = BULL_COLOR, size = size.small, text = "BUY", textcolor = color.white)
plotshape(showLabels and sellSignal, style = shape.labeldown, location = location.abovebar, color = BEAR_COLOR, size = size.small, text = "SELL", textcolor = color.white)
plotshape(showLabels and flipToLong, style = shape.labelup, location = location.belowbar, color = BULL_COLOR, size = size.small, text = "FLIP BUY", textcolor = color.white)
plotshape(showLabels and flipToShort, style = shape.labeldown, location = location.abovebar, color = BEAR_COLOR, size = size.small, text = "FLIP SELL", textcolor = color.white)

// Exit Labels
plotshape(showLabels and exitLong, style = shape.labeldown, location = location.abovebar, color = EXIT_COLOR, size = size.small, text = "EXIT", textcolor = color.white)
plotshape(showLabels and exitShort, style = shape.labelup, location = location.belowbar, color = EXIT_COLOR, size = size.small, text = "EXIT", textcolor = color.white)
````
