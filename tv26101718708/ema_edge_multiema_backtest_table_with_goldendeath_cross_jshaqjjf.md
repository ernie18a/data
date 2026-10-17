# EMA Edge - Multi-EMA Backtest Table with Golden/Death Cross

- url: https://www.tradingview.com/script/jsHaQJjF-EMA-Edge-Multi-EMA-Backtest-Table-with-Golden-Death-Cross/
- type: indicator
- pine_id: PUB;cd964e2b446d4edb9802d991b180a9d5
- version: 2.0

## Description

EMA Edge — Multi-EMA Backtest Table with Golden/Death Cross

A clean, all-in-one performance dashboard that backtests 6 long-only strategies side-by-side against a Buy & Hold benchmark — 5 single-EMA crossover strategies plus a classic Golden Cross / Death Cross strategy — with on-chart cross markers and built-in alerts.
Instead of guessing which EMA length works best for a given stock or timeframe, this indicator runs the math for you and shows the answer in a single glance, ranked against simply holding the asset.

What It Does
For each of 5 user-defined EMA lengths, the indicator simulates a simple long-only strategy:

Buy when price closes above the EMA (when flat)
Sell when price closes below the EMA (when long)
Equity starts at 100 and compounds across trades using the close-to-close return of each trade

A 6th strategy row tests the classic Golden/Death Cross:

Buy when the fast EMA crosses above the slow EMA (Golden Cross)
Sell when the fast EMA crosses below the slow EMA (Death Cross)
Special first-bar handling: if the fast EMA is already above the slow EMA at the start of your backtest window (i.e., we're mid-trend with no fresh Golden Cross to wait for), the strategy enters immediately at that bar's opening price. This avoids the unrealistic outcome of sitting in cash for years waiting for a cross that already happened.

All strategies are compared against a Buy & Hold baseline that starts at the close of the first in-range bar. If a position is open at the last bar, its equity is marked-to-market so every strategy is compared on equal terms — fully invested vs. partially invested at the cutoff.

Features

5 configurable EMAs — defaults 9 / 21 / 50 / 100 / 200, fully editable
Golden/Death Cross strategy — uses independent fast/slow EMA inputs (default 50 / 200)
Performance table showing Return %, delta vs. Buy & Hold, and Outperform / Underperform status per strategy
Flexible backtest window — X weeks, X years, or full chart lifetime
On-chart GC / DC markers with optional subtle background tint on cross bars
Built-in alerts for both Golden Cross and Death Cross events
Fully customizable table — 9 position options, 6 text sizes, all colors exposed as inputs
Soft, light color palette designed not to dominate the chart
Optional EMA plotting (off by default to keep the chart clean)


How To Read The Table
ColumnMeaningStrategyThe rule being testedReturnTotal % return of the strategy over the chosen windowVs StockDifference between the strategy's return and Buy & HoldStatus▲ Outperform if the strategy beat Buy & Hold, ▼ Underperform if not

Green-tinted rows = strategy beat Buy & Hold
Red-tinted rows = strategy underperformed Buy & Hold
Cream row = the Buy & Hold baseline itself


How To Use

Add the indicator to any chart — works on stocks, ETFs, crypto, forex, any timeframe.
Choose your backtest window (e.g., 1 Year, 5 Years, or Lifetime).
Scan the table to see which strategy historically beat Buy & Hold on this asset.
Use the on-chart GC / DC labels to spot historical and live cross events. Right-click any marker → Add Alert to be notified on new crosses.

Tip: Test the same EMA lengths across daily and weekly timeframes and across different assets. You'll usually find that what works on a steady index like SPY does not work on a volatile single stock, and vice versa. That's the entire point of the table — to make those differences visible instead of assumed.

Key Inputs

EMA 1–5: Lengths for the 5 single-EMA strategies
Show EMAs: Plot EMAs on chart (off by default)
Use Lifetime Performance: Backtest from the very first bar instead of a fixed window
Performance Timeframe Type / Value: Weeks or Years lookback
Crosses group: Toggle GC/DC display, set fast/slow EMA lengths, customize colors
Table Style group: Position, text size, background and text colors


Notes & Limitations

All strategies are long-only — no shorts, no leverage, no stops, no commissions, no slippage. This is a clean rule-based comparison, not a turnkey trading system. Live results will differ.
Entries and exits use close prices, except for the GC/DC strategy's first-bar entry when already in a golden state, which uses open.
Open positions at the last bar are marked-to-market so the comparison vs. Buy & Hold is apples-to-apples.
Past performance is not indicative of future results. Use this as a research and screening tool.
The GC/DC strategy uses separate EMA lengths from the 5 table EMAs by design, so you can run 9/21/50/100/200 in the table while still testing the classic 50/200 cross.


Alerts Available

Golden Cross: Fast EMA crossed above Slow EMA
Death Cross: Fast EMA crossed below Slow EMA


If you find this useful, a boost is appreciated. Suggestions and feedback welcome in the comments.
Open-source — feel free to study, fork, and adapt.

## Source Code

````pine
//@version=5
// Released for the TradingView community. Feel free to use and modify.
indicator("EMA Edge — Multi-EMA Backtest Table with Golden/Death Cross", overlay=true)


// === EMA Inputs ===
ema1 = input.int(9,   "EMA 1")
ema2 = input.int(21,  "EMA 2")
ema3 = input.int(50,  "EMA 3")
ema4 = input.int(100, "EMA 4")
ema5 = input.int(200, "EMA 5")

showEMAs = input.bool(false, "Show EMAs")

useLifetime = input.bool(false, "Use Lifetime Performance")
periodType = input.string("Years", "Performance Timeframe Type", options=["Weeks", "Years"])
periodValue = input.int(1, "Performance Timeframe Value", minval=1)

// === Golden / Death Cross Inputs ===
showGoldenCross = input.bool(true, "Show Golden Cross", group="Crosses")
showDeathCross  = input.bool(true, "Show Death Cross",  group="Crosses")
fastCrossLen    = input.int(50,  "Fast EMA for Cross",  minval=1, group="Crosses")
slowCrossLen    = input.int(200, "Slow EMA for Cross",  minval=1, group="Crosses")
goldenColor     = input.color(color.new(#D4AF37, 0), "Golden Cross Color", group="Crosses")
deathColor      = input.color(color.new(#B91C1C, 0), "Death Cross Color",  group="Crosses")

// === Table Style Inputs ===
tablePos = input.string("Top Right", "Table Position",
     options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group="Table Style")
tableSize = input.string("Normal", "Table Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge", "Auto"],
     group="Table Style")
headerColor   = input.color(color.new(#E5E7EB, 0),  "Header Background",  group="Table Style")
titleColor    = input.color(color.new(#F3F4F6, 0),  "Title Background",   group="Table Style")
rowBgColor    = input.color(color.new(#FFFFFF, 0),  "Row Background",     group="Table Style")
altRowBgColor = input.color(color.new(#F9FAFB, 0),  "Alt Row Background", group="Table Style")
outperfColor  = input.color(color.new(#D1FAE5, 30), "Outperform Color",   group="Table Style")
underperfColor= input.color(color.new(#FEE2E2, 30), "Underperform Color", group="Table Style")
stockRowColor = input.color(color.new(#FEF3C7, 30), "Buy & Hold Color",   group="Table Style")
textColor     = input.color(#374151, "Text Color",          group="Table Style")
accentColor   = input.color(#6B7280, "Accent Text Color",   group="Table Style")

// === Resolve Position & Size ===
getPos(p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center : position.bottom_right

getSize(s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     s == "Large" ? size.large :
     s == "Huge" ? size.huge : size.auto

posVal  = getPos(tablePos)
sizeVal = getSize(tableSize)

// === Timeframe Calculation ===
msInDay = 24 * 60 * 60 * 1000
lookbackDays = periodType == "Weeks" ? periodValue * 7 : periodValue * 365
startTime = useLifetime ? 0 : timenow - lookbackDays * msInDay
inRange = time >= startTime

// === Strategy Calculation Function ===
calcPerf(_emaLen) =>
    emaVal = ta.ema(close, _emaLen)

    var float entryPrice = na
    var float equity = 100.0
    var bool inTrade = false
    var bool started = false

    if inRange and not started
        equity := 100.0
        entryPrice := na
        inTrade := false
        started := true

    if inRange
        buySignal = close > emaVal and not inTrade
        sellSignal = close < emaVal and inTrade

        if buySignal
            entryPrice := close
            inTrade := true

        if sellSignal
            tradeReturn = close / entryPrice
            equity := equity * tradeReturn
            inTrade := false
            entryPrice := na

    openEquity = inTrade ? equity * (close / entryPrice) : equity
    perf = started ? openEquity - 100.0 : na

    [perf, emaVal]

// === Golden / Death Cross Detection ===
fastEMA = ta.ema(close, fastCrossLen)
slowEMA = ta.ema(close, slowCrossLen)

goldenCross = ta.crossover(fastEMA, slowEMA)
deathCross  = ta.crossunder(fastEMA, slowEMA)

// === Golden/Death Cross Strategy ===
// Buy at Golden Cross, sell at Death Cross
// If fast EMA > slow EMA at start of backtest window, enter at that bar's open
calcCrossPerf() =>
    var float entryPrice = na
    var float equity = 100.0
    var bool inTrade = false
    var bool started = false

    if inRange and not started
        equity := 100.0
        entryPrice := na
        inTrade := false
        started := true
        // Already in golden state → buy at opening price of first in-range bar
        if fastEMA > slowEMA
            entryPrice := open
            inTrade := true

    if inRange and started
        // Golden Cross → enter long at close
        if goldenCross and not inTrade
            entryPrice := close
            inTrade := true
        // Death Cross → exit at close
        if deathCross and inTrade
            tradeReturn = close / entryPrice
            equity := equity * tradeReturn
            inTrade := false
            entryPrice := na

    openEquity = inTrade ? equity * (close / entryPrice) : equity
    started ? openEquity - 100.0 : na

// === EMA Performances ===
[perf1, e1] = calcPerf(ema1)
[perf2, e2] = calcPerf(ema2)
[perf3, e3] = calcPerf(ema3)
[perf4, e4] = calcPerf(ema4)
[perf5, e5] = calcPerf(ema5)

crossPerf = calcCrossPerf()

// === Buy & Hold Performance ===
var float startClose = na
var bool stockStarted = false

if inRange and not stockStarted
    startClose := close
    stockStarted := true

stockPerf = stockStarted ? ((close / startClose) - 1) * 100 : na

// === Plot EMAs ===
plot(showEMAs ? e1 : na, "EMA 1", color=color.new(#93C5FD, 0))
plot(showEMAs ? e2 : na, "EMA 2", color=color.new(#C4B5FD, 0))
plot(showEMAs ? e3 : na, "EMA 3", color=color.new(#F9A8D4, 0))
plot(showEMAs ? e4 : na, "EMA 4", color=color.new(#FCD34D, 0))
plot(showEMAs ? e5 : na, "EMA 5", color=color.new(#6EE7B7, 0))

// === Cross Markers & Alerts ===
plotshape(showGoldenCross and goldenCross, title="Golden Cross",
     style=shape.labelup, location=location.belowbar,
     color=goldenColor, textcolor=color.white, text="GC", size=size.small)

plotshape(showDeathCross and deathCross, title="Death Cross",
     style=shape.labeldown, location=location.abovebar,
     color=deathColor, textcolor=color.white, text="DC", size=size.small)

// Background tint (very subtle) on cross bars
bgcolor(showGoldenCross and goldenCross ? color.new(goldenColor, 85) : na, title="Golden Cross BG")
bgcolor(showDeathCross  and deathCross  ? color.new(deathColor,  85) : na, title="Death Cross BG")

// Alerts
alertcondition(goldenCross, title="Golden Cross Alert", message="Golden Cross: Fast EMA crossed above Slow EMA")
alertcondition(deathCross,  title="Death Cross Alert",  message="Death Cross: Fast EMA crossed below Slow EMA")

// === Helpers ===
formatPct(x) =>
    na(x) ? "N/A" : str.tostring(x, "#.##") + "%"

rowColor(x) =>
    na(x) ? color.new(color.gray, 90) : x >= stockPerf ? outperfColor : underperfColor

statusText(x) =>
    na(x) ? "N/A" : x >= stockPerf ? "▲ Outperform" : "▼ Underperform"

altBg(i) =>
    i % 2 == 0 ? rowBgColor : altRowBgColor

timeframeLabel = useLifetime ? "Lifetime" : str.tostring(periodValue) + " " + periodType

// === Table ===
var table perfTable = table.new(posVal, 4, 9, border_width=1, border_color=color.new(#E5E7EB, 0))

if barstate.islast
    // Title row
    table.cell(perfTable, 0, 0, "Timeframe",    bgcolor=titleColor, text_color=accentColor, text_size=sizeVal)
    table.cell(perfTable, 1, 0, timeframeLabel, bgcolor=titleColor, text_color=textColor,   text_size=sizeVal)
    table.cell(perfTable, 2, 0, "",             bgcolor=titleColor, text_color=textColor,   text_size=sizeVal)
    table.cell(perfTable, 3, 0, "",             bgcolor=titleColor, text_color=textColor,   text_size=sizeVal)

    // Header row
    table.cell(perfTable, 0, 1, "Strategy", bgcolor=headerColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 1, 1, "Return",   bgcolor=headerColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 2, 1, "Vs Stock", bgcolor=headerColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 3, 1, "Status",   bgcolor=headerColor, text_color=textColor, text_size=sizeVal)

    // Buy & Hold row
    table.cell(perfTable, 0, 2, "Buy & Hold",         bgcolor=stockRowColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 1, 2, formatPct(stockPerf), bgcolor=stockRowColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 2, 2, "Base",               bgcolor=stockRowColor, text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 3, 2, "★ Benchmark",        bgcolor=stockRowColor, text_color=textColor, text_size=sizeVal)

    // EMA rows
    emas  = array.from(ema1, ema2, ema3, ema4, ema5)
    perfs = array.from(perf1, perf2, perf3, perf4, perf5)

    for i = 0 to 4
        rowIdx = 3 + i
        emaLen = array.get(emas, i)
        p = array.get(perfs, i)
        table.cell(perfTable, 0, rowIdx, "EMA " + str.tostring(emaLen), bgcolor=altBg(i),    text_color=textColor, text_size=sizeVal)
        table.cell(perfTable, 1, rowIdx, formatPct(p),                   bgcolor=rowColor(p), text_color=textColor, text_size=sizeVal)
        table.cell(perfTable, 2, rowIdx, formatPct(p - stockPerf),       bgcolor=altBg(i),    text_color=textColor, text_size=sizeVal)
        table.cell(perfTable, 3, rowIdx, statusText(p),                  bgcolor=rowColor(p), text_color=textColor, text_size=sizeVal)

    // Golden/Death Cross strategy row
    crossLabel = "GC/DC (" + str.tostring(fastCrossLen) + "/" + str.tostring(slowCrossLen) + ")"
    table.cell(perfTable, 0, 8, crossLabel,                       bgcolor=altBg(5),            text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 1, 8, formatPct(crossPerf),             bgcolor=rowColor(crossPerf), text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 2, 8, formatPct(crossPerf - stockPerf), bgcolor=altBg(5),            text_color=textColor, text_size=sizeVal)
    table.cell(perfTable, 3, 8, statusText(crossPerf),            bgcolor=rowColor(crossPerf), text_color=textColor, text_size=sizeVal)
````
