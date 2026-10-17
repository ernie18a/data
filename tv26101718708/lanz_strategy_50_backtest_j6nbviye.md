# LANZ Strategy 5.0 [Backtest]

- url: https://www.tradingview.com/script/j6NBvIYE/
- type: strategy
- pine_id: PUB;8de5394a24284e29b63202130422c38b
- version: 3.0

## Description

[b]🔷 LANZ Strategy 5.0 [Backtest] — Rule-Based BUY Logic with Time Filter, Session Limits and Auto SL/TP Execution[/b]

This is the backtest version of LANZ Strategy 5.0, built as a strategy script to evaluate real performance under fixed intraday conditions. It automatically places BUY and SELL trades based on structured candle confirmation, EMA trend alignment, and session-based filters. The system simulates real-time execution with precise Stop Loss and Take Profit levels.

[i]📌 Built for traders seeking to simulate clean intraday logic with fully automated entries and performance metrics.[/i]

[b]🧠 Core Logic & Strategy Conditions[/b]

✅ BUY Signal Conditions:

[list=1]
[*]Price is above the EMA200
[*]The last 3 candles are bullish (close > open)
[*]The signal occurs within the defined session window (NY time)
[*]Daily trade limit has not been exceeded
[/list]

If all are true, a BUY order is executed at market, with SL and TP set immediately.

[i]🔻 SELL Signal Conditions (Optional):
Exactly inverse to BUY (below EMA + 3 bearish candles). Disabled by default.[/i]

[b]🕐 Operational Time Filter (New York Time)[/b]

You can fully customize your intraday window:

[list]
[*]Start Time: e.g., 01:15 NY
[*]End Time: e.g., 16:00 NY
[/list]

[i]The system evaluates signals only within this range, even across midnight if configured.[/i]

[b]🔁 Trade Management System[/b]

[list]
[*][i]One trade at a time per signal[/i]
[*]Trades include a Stop Loss (SL) and Take Profit (TP) based on pip distance
[*]Trade result is calculated automatically
[*]Each signal is shown with a triangle marker (BUY only, by default)
[/list]

[b]🧪 Backtest Accuracy[/b]

This version uses:

[list]
[*]strategy.order() for entries
[*]strategy.exit() for SL and TP
[*]strategy.close_all() at the configured manual closing time
[/list]

This ensures realistic behavior in the TradingView strategy tester.

[b]⚙️ Flow Summary (Step-by-Step)[/b]

On every bar, check:

[list]
[*]Is the time within the operational session?
[*]Is the price above the EMA?
[*]Are the last 3 candles bullish?
[/list]

If conditions met → A BUY trade is opened:

[list]
[*]SL = entry – X pips
[*]TP = entry + Y pips
[/list]

Trade closes:

[list]
[*]If SL or TP is hit
[*]Or at the configured manual close time (e.g., 16:00 NY)
[/list]
[b]
📊 Settings Overview[/b]

[list]
[i][*]Timeframe: 1-hour (ideal)[/i]
[*]SL/TP: Configurable in pips
[*]Max trades/day: User-defined (default = 99 = unlimited)
[*]Manual close: Adjustable by time
[*]Entry type: Market (not limit)
[*]Visuals: Plotshape triangle for BUY entry
[/list]

[b][i]👨‍💻 Credits:[/b]
💡 Developed by: LANZ
🧠 Strategy logic & execution: LANZ
✅ Designed for: Clean backtesting, clarity in execution, and intraday logic simulation[/i]

## Source Code

````pine
//@version=6
strategy(title="LANZ Strategy 5.0 [Backtest]", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=1000)

// === INPUTS ===
groupLimitaciones = "🚩 Daily Trade Limit"
maxTrades = input.int(99, "Maximum Trades per Day", minval=1, maxval=99, group=groupLimitaciones, tooltip="Use 99 if you want to take ALL available trades in the day.")

groupFilter = "🔍 Distance Filter"
minDistancePips = input.float(25.0, title="Minimum Distance Between Entries (Pips)", minval=0.1, group=groupFilter)

groupEMA = "📈 Exponential Moving Average (EMA)"
emaPeriod = input.int(200, title="EMA Period", minval=1, group=groupEMA)

groupRisk = "🎯 Risk Parameters"
slPips = input.float(40, title="Stop Loss (Pips)", minval=0.1, group=groupRisk)
tpPips = input.float(120, title="Take Profit (Pips)", minval=0.1, group=groupRisk)

groupClose = "🔚 Operational Time (NY)"
startHour = input.int(19, title="Start Hour", minval=0, maxval=23, group=groupClose)
startMinute = input.int(0, title="Start Minute", minval=0, maxval=59, group=groupClose)
manualCloseHour = input.int(15, title="End Hour", minval=0, maxval=23, group=groupClose)
manualCloseMinute = input.int(0, title="End Minute", minval=0, maxval=59, group=groupClose)

groupCutoff = "⏳ Entry Cutoff (Bars)"
barsBeforeClose = input.int(1, "Stop New Entries N Bars Before End", minval=1, maxval=500, group=groupCutoff, tooltip="Number of bars before closing at which new entries are blocked.")

groupMode = "⚙️ Operation Mode"
enableBuy = input.bool(true, "✅ Enable Buy Signals", group=groupMode)
enableSell = input.bool(false, "✅ Enable Sell Signals", group=groupMode)

// === CALCULATIONS ===
pipSize = syminfo.mintick * 10
ema = ta.ema(close, emaPeriod)

// === TRACK LAST ENTRY ===
var float lastEntryPrice = na
distanceOk = na(lastEntryPrice) or math.abs(close - lastEntryPrice) >= (minDistancePips * pipSize)

// === DAILY OPERATIONS ACCOUNTANT ===
var int dailyCounter = 0
var int lastDayTimestamp = na
todayNY = timestamp("America/New_York", year, month, dayofmonth, 0, 0)

if na(lastDayTimestamp) or todayNY != lastDayTimestamp
    dailyCounter := 0
    lastDayTimestamp := todayNY

// === OPERATING HOURS ===
nyHour = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
isSameDayRange = manualCloseHour > startHour or (manualCloseHour == startHour and manualCloseMinute > startMinute)
isWithinOperationalHours = isSameDayRange ? (nyHour > startHour or (nyHour == startHour and nyMinute >= startMinute)) and (nyHour < manualCloseHour or (nyHour == manualCloseHour and nyMinute <= manualCloseMinute)) : (nyHour > startHour or (nyHour == startHour and nyMinute >= startMinute)) or (nyHour < manualCloseHour or (nyHour == manualCloseHour and nyMinute <= manualCloseMinute))

// === ENTRY WINDOW ===
startTotal  = startHour * 60 + startMinute
endTotal    = manualCloseHour * 60 + manualCloseMinute
tfSec       = timeframe.in_seconds()
cutoffMins  = int(math.round(barsBeforeClose * (tfSec / 60.0)))

sessionSpan = isSameDayRange ? (endTotal - startTotal) : (endTotal - startTotal + 1440)
validWindow = cutoffMins < sessionSpan

cutoffTotal = (endTotal - cutoffMins + 1440) % 1440
nyTotal     = nyHour * 60 + nyMinute

isWithinEntryWindow = validWindow ? (isSameDayRange ? (nyTotal >= startTotal and nyTotal < cutoffTotal) : (nyTotal >= startTotal or nyTotal < cutoffTotal)) : false

// === BUY/SELL SIGNAL ===
isAboveEMA = close > ema
isBelowEMA = close < ema
bullish1 = close > open
bullish2 = close[1] > open[1]
bullish3 = close[2] > open[2]
bearish1 = close < open
bearish2 = close[1] < open[1]
bearish3 = close[2] < open[2]

buySignal = enableBuy and isAboveEMA and bullish1 and bullish2 and bullish3
sellSignal = enableSell and isBelowEMA and bearish1 and bearish2 and bearish3

// === FILTER: Trading Limit and Operating Hours + Distance ===
canOpen = dailyCounter < maxTrades and isWithinEntryWindow and distanceOk

// === RUN MULTIPLE ENTRIES ===
if buySignal and canOpen
    float entry = close
    float sl = entry - slPips * pipSize
    float tp = entry + tpPips * pipSize
    string id = "Buy_" + str.tostring(bar_index) + "_" + str.tostring(timenow)
    strategy.order(id, strategy.long, qty=1)
    strategy.exit("Exit_" + id, from_entry=id, stop=sl, limit=tp)
    dailyCounter += 1
    lastEntryPrice := entry

if sellSignal and canOpen
    float entry = close
    float sl = entry + slPips * pipSize
    float tp = entry - tpPips * pipSize
    string id = "Sell_" + str.tostring(bar_index) + "_" + str.tostring(timenow)
    strategy.order(id, strategy.short, qty=1)
    strategy.exit("Exit_" + id, from_entry=id, stop=sl, limit=tp)
    dailyCounter += 1
    lastEntryPrice := entry

// === CONFIGURABLE MANUAL CLOSURE NY TIME ===
isCloseTime = (nyHour == manualCloseHour and nyMinute == manualCloseMinute)
if isCloseTime
    strategy.close_all(comment="Manual Close" + str.tostring(manualCloseHour) + ":" + str.tostring(manualCloseMinute, "00"))
    lastEntryPrice := na

// === RESET FILTER AFTER SL or TP ===
tradeClosed = strategy.opentrades[1] > 0 and strategy.opentrades == 0
if tradeClosed
    lastEntryPrice := na

// === PLOT SIGNALS ===
plotshape(buySignal and canOpen, title="Backtest Buy Signal", location=location.bottom, color=color.rgb(255, 129, 129), style=shape.triangleup, size=size.tiny)
````
