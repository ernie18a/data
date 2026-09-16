<!-- tradingview-pine-id: PUB;70a5fa711d9c456cb646e929dc325980 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 3 EMA + HH/LL Structure Break PRO v2

Source: https://www.tradingview.com/script/MASmzuAI-3-EMA-HH-LL-Structure-Break-Trend-and-Structure-combined-v2/

## Description

3EMA PRO V2 is a structured EMA + market-structure indicator designed for intraday trading on instruments such as XAUUSD and BTCUSD.

The system combines 20 EMA, 50 EMA and 100 EMA with 10/10 pivot-based market structure to identify trend-following and reversal opportunities.

🔹 Core EMA Logic

Trend Following BUY

100 EMA is below both 20 EMA and 50 EMA.
20 EMA crosses above 50 EMA.
The system looks for confirmation through market structure.

Trend Following SELL

100 EMA is above both 20 EMA and 50 EMA.
20 EMA crosses below 50 EMA.
The system looks for bearish structure confirmation.

Reversal BUY

Fast and middle EMA move/cross above the 100 EMA.
Used to identify potential bullish reversal conditions.

Reversal SELL

Fast and middle EMA move/cross below the 100 EMA.
Used to identify potential bearish reversal conditions.
🔹 Market Structure Confirmation

The indicator uses 10 Left / 10 Right pivots to identify:

HH — Higher High
HL — Higher Low
LH — Lower High
LL — Lower Low

The important concept is EMA signal + structure confirmation, rather than taking every EMA crossover immediately.

If the EMA signal appears before the structure break, the system waits for the corresponding HH/LL breakout candle to close.

If the structure break happens before the EMA signal, the system waits for the EMA confirmation and then looks for a neckline retest before entry.

🔹 Entry

The indicator provides:

🟢 BUY labels
🔴 SELL labels
Entry price
SL
TP1
TP2
TP3
Reversal / Trend classification
🔹 Risk Management

TP and SL are fully configurable in dollar values.

You can independently adjust:

TP1 ($)
TP2 ($)
TP3 ($)
SL ($)
Position size
🔹 Backtest Statistics

The indicator includes an internal last 500 signals performance table, displaying:

Total signals
Win rate
Wins / losses
Break-even trades
Net P/L
Profit Factor
Maximum drawdown
BUY / SELL count
Reversal / Trend count
TP1 / TP2 / TP3 hits
SL hits
Current EMA and pivot settings
⚠️ Important

This indicator is intended as a technical analysis and decision-support tool, not a guarantee of profitable trading. Backtest results can vary significantly depending on the symbol, timeframe, spread, commission, slippage and execution conditions.

Suggested starting configuration:
EMA: 20 / 50 / 100
Pivot: 10 / 10
Markets: XAUUSD / BTCUSD
Timeframes: 1M / 5M

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shakeelahamed493

//@version=6
indicator("3 EMA + HH/LL Structure Break PRO v2", shorttitle="3EMA PRO v2", overlay=true, max_labels_count=500, max_lines_count=500)

//=====================================================================
// 1. EMA SETTINGS
//=====================================================================
groupEMA = "EMA SETTINGS"

fastLen = input.int(20, "Fast EMA", minval=1, group=groupEMA)
midLen  = input.int(50, "Middle EMA", minval=1, group=groupEMA)
slowLen = input.int(100, "Slow EMA", minval=1, group=groupEMA)

fastEMA = ta.ema(close, fastLen)
midEMA  = ta.ema(close, midLen)
slowEMA = ta.ema(close, slowLen)

plot(fastEMA, "Fast EMA", color=color.blue, linewidth=2)
plot(midEMA, "Middle EMA", color=color.orange, linewidth=2)
plot(slowEMA, "Slow EMA", color=color.red, linewidth=2)

//=====================================================================
// 2. METHOD SETTINGS
//=====================================================================
groupMethod = "ENTRY METHODS"

useReversal = input.bool(true, "Use Reversal Method", group=groupMethod)
useTrend    = input.bool(true, "Use Trend Following Method", group=groupMethod)

//=====================================================================
// 3. EMA SIGNAL LOGIC
//=====================================================================

// Trend Following:
// BUY  = slow below fast & middle + fast crosses middle upward
// SELL = slow above fast & middle + fast crosses middle downward

trendBuy =
     slowEMA < fastEMA and
     slowEMA < midEMA and
     ta.crossover(fastEMA, midEMA)

trendSell =
     slowEMA > fastEMA and
     slowEMA > midEMA and
     ta.crossunder(fastEMA, midEMA)

// Reversal:
// BUY  = fast/middle cross ABOVE slow
// SELL = fast/middle cross BELOW slow

reversalBuy =
     (ta.crossover(fastEMA, slowEMA) and midEMA > slowEMA) or
     (ta.crossover(midEMA, slowEMA) and fastEMA > slowEMA)

reversalSell =
     (ta.crossunder(fastEMA, slowEMA) and midEMA < slowEMA) or
     (ta.crossunder(midEMA, slowEMA) and fastEMA < slowEMA)

emaBuy = useTrend and trendBuy or useReversal and reversalBuy
emaSell = useTrend and trendSell or useReversal and reversalSell

buyMethod = reversalBuy ? 1 : 2
sellMethod = reversalSell ? 1 : 2

//=====================================================================
// 4. PIVOT STRUCTURE
//=====================================================================
groupStructure = "STRUCTURE SETTINGS"

pivotLeft  = input.int(10, "Pivot Left", minval=1, group=groupStructure)
pivotRight = input.int(10, "Pivot Right", minval=1, group=groupStructure)

showStructure = input.bool(true, "Show HH / HL / LH / LL", group=groupStructure)
showBreaks = input.bool(true, "Show HH / LL Break", group=groupStructure)

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastHigh = na
var float previousHigh = na

var float lastLow = na
var float previousLow = na

if not na(pivotHigh)
    previousHigh := lastHigh
    lastHigh := pivotHigh

if not na(pivotLow)
    previousLow := lastLow
    lastLow := pivotLow

isHH = not na(pivotHigh) and not na(previousHigh) and pivotHigh > previousHigh
isLH = not na(pivotHigh) and not na(previousHigh) and pivotHigh < previousHigh

isHL = not na(pivotLow) and not na(previousLow) and pivotLow > previousLow
isLL = not na(pivotLow) and not na(previousLow) and pivotLow < previousLow

if showStructure

    if isHH
        label.new(
             bar_index - pivotRight,
             pivotHigh,
             "HH",
             style=label.style_label_down,
             color=color.green,
             textcolor=color.white,
             size=size.tiny)

    if isLH
        label.new(
             bar_index - pivotRight,
             pivotHigh,
             "LH",
             style=label.style_label_down,
             color=color.orange,
             textcolor=color.white,
             size=size.tiny)

    if isHL
        label.new(
             bar_index - pivotRight,
             pivotLow,
             "HL",
             style=label.style_label_up,
             color=color.teal,
             textcolor=color.white,
             size=size.tiny)

    if isLL
        label.new(
             bar_index - pivotRight,
             pivotLow,
             "LL",
             style=label.style_label_up,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)

//=====================================================================
// 5. CONFIRMED STRUCTURE BREAK
//=====================================================================

bullBreak =
     not na(lastHigh) and
     close > lastHigh and
     close[1] <= lastHigh

bearBreak =
     not na(lastLow) and
     close < lastLow and
     close[1] >= lastLow

if showBreaks and bullBreak
    label.new(
         bar_index,
         high,
         "HH BREAK",
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         size=size.tiny)

if showBreaks and bearBreak
    label.new(
         bar_index,
         low,
         "LL BREAK",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.tiny)

//=====================================================================
// 6. SETUP ENGINE
//
// LONG STATE
// 0 = Nothing
// 1 = EMA signal came first, waiting for HH break
// 2 = HH break came first, waiting for EMA signal
// 3 = Both confirmed, waiting for retest
//
// SHORT STATE
// same logic
//=====================================================================

var int longState = 0
var int shortState = 0

var int longMethod = 0
var int shortMethod = 0

var float longNeck = na
var float shortNeck = na

var int longEMAbar = na
var int shortEMAbar = na

var int longBreakBar = na
var int shortBreakBar = na

//=====================================================================
// 7. EMA FIRST
//=====================================================================

if emaBuy and longState == 0
    longState := 1
    longMethod := buyMethod
    longEMAbar := bar_index

if emaSell and shortState == 0
    shortState := 1
    shortMethod := sellMethod
    shortEMAbar := bar_index

//=====================================================================
// 8. STRUCTURE FIRST
//=====================================================================

if bullBreak

    longNeck := lastHigh
    longBreakBar := bar_index

    if longState == 1
        longState := 0

        // EMA signal already happened.
        // Break candle itself confirms the setup.
        longState := 1

    else
        longState := 2

if bearBreak

    shortNeck := lastLow
    shortBreakBar := bar_index

    if shortState == 1
        shortState := 1
    else
        shortState := 2

//=====================================================================
// 9. STRUCTURE FIRST -> EMA SIGNAL
//=====================================================================

if longState == 2 and emaBuy

    longState := 3
    longMethod := buyMethod
    longEMAbar := bar_index

if shortState == 2 and emaSell

    shortState := 3
    shortMethod := sellMethod
    shortEMAbar := bar_index

//=====================================================================
// 10. EMA FIRST -> STRUCTURE BREAK
//=====================================================================

longBreakEntry =
     longState == 1 and
     not na(longEMAbar) and
     bullBreak and
     bar_index >= longEMAbar

shortBreakEntry =
     shortState == 1 and
     not na(shortEMAbar) and
     bearBreak and
     bar_index >= shortEMAbar

//=====================================================================
// 11. RETEST SETTINGS
//=====================================================================
groupRetest = "RETEST SETTINGS"

requireRetestClose = input.bool(
     true,
     "Require Retest Candle Close",
     group=groupRetest)

retestTolerance = input.float(
     0.0,
     "Retest Tolerance",
     minval=0,
     step=0.01,
     group=groupRetest)

// BUY retest:
// Price touches HH neckline and closes back above it.

longRetest =
     longState == 3 and
     not na(longNeck) and
     bar_index > nz(longBreakBar, bar_index) and
     low <= longNeck + retestTolerance and
     (not requireRetestClose or close > longNeck)

// SELL retest:
// Price touches LL neckline and closes back below it.

shortRetest =
     shortState == 3 and
     not na(shortNeck) and
     bar_index > nz(shortBreakBar, bar_index) and
     high >= shortNeck - retestTolerance and
     (not requireRetestClose or close < shortNeck)

//=====================================================================
// 12. FINAL ENTRY
//=====================================================================

finalBuy =
     longBreakEntry or longRetest

finalSell =
     shortBreakEntry or shortRetest

//=====================================================================
// 13. RISK MANAGEMENT
//=====================================================================
groupRisk = "TP / SL SETTINGS"

positionSize = input.float(
     1.0,
     "Position Size",
     minval=0.000001,
     step=0.01,
     group=groupRisk)

dollarPerMove = input.float(
     1.0,
     "Dollar Value Per 1.00 Price Move",
     minval=0.000001,
     step=0.01,
     group=groupRisk)

tp1Dollar = input.float(
     5.0,
     "TP1 ($)",
     minval=0.01,
     step=0.01,
     group=groupRisk)

tp2Dollar = input.float(
     10.0,
     "TP2 ($)",
     minval=0.01,
     step=0.01,
     group=groupRisk)

tp3Dollar = input.float(
     15.0,
     "TP3 ($)",
     minval=0.01,
     step=0.01,
     group=groupRisk)

slDollar = input.float(
     5.0,
     "SL ($)",
     minval=0.01,
     step=0.01,
     group=groupRisk)

// Convert dollar targets to price distance.

tp1Distance = tp1Dollar / (positionSize * dollarPerMove)
tp2Distance = tp2Dollar / (positionSize * dollarPerMove)
tp3Distance = tp3Dollar / (positionSize * dollarPerMove)
slDistance  = slDollar / (positionSize * dollarPerMove)

//=====================================================================
// 14. ACTIVE TRADE
//=====================================================================

var bool inTrade = false
var int tradeDirection = 0
var int tradeMethod = 0

var float entryPrice = na
var float tradeSL = na
var float tradeTP1 = na
var float tradeTP2 = na
var float tradeTP3 = na

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false

//=====================================================================
// 15. LAST 500 TRADE ARRAYS
//=====================================================================

var array<float> pnlArray = array.new_float()
var array<int> directionArray = array.new_int()
var array<int> methodArray = array.new_int()
var array<int> outcomeArray = array.new_int()

var array<int> tp1Array = array.new_int()
var array<int> tp2Array = array.new_int()
var array<int> tp3Array = array.new_int()
var array<int> slArray = array.new_int()

//=====================================================================
// 16. STORE TRADE
//=====================================================================

storeTrade(float pnl, int direction, int method, int outcome, int tp1, int tp2, int tp3, int sl) =>

    array.push(pnlArray, pnl)
    array.push(directionArray, direction)
    array.push(methodArray, method)
    array.push(outcomeArray, outcome)

    array.push(tp1Array, tp1)
    array.push(tp2Array, tp2)
    array.push(tp3Array, tp3)
    array.push(slArray, sl)

    if array.size(pnlArray) > 500

        array.shift(pnlArray)
        array.shift(directionArray)
        array.shift(methodArray)
        array.shift(outcomeArray)

        array.shift(tp1Array)
        array.shift(tp2Array)
        array.shift(tp3Array)
        array.shift(slArray)

//=====================================================================
// 17. BUY ENTRY
//=====================================================================

buyEntry = finalBuy and not inTrade

if buyEntry

    inTrade := true
    tradeDirection := 1
    tradeMethod := longMethod

    entryPrice := close

    tradeSL := entryPrice - slDistance
    tradeTP1 := entryPrice + tp1Distance
    tradeTP2 := entryPrice + tp2Distance
    tradeTP3 := entryPrice + tp3Distance

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

    methodText = tradeMethod == 1 ? "REVERSAL" : "TREND"

    label.new(
         bar_index,
         low,
         "BUY\n" + methodText,
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal)

    label.new(
         bar_index,
         entryPrice,
         "ENTRY\n" + str.tostring(entryPrice, format.mintick),
         style=label.style_label_left,
         color=color.gray,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP1,
         "TP1\n$" + str.tostring(tp1Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP2,
         "TP2\n$" + str.tostring(tp2Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP3,
         "TP3\n$" + str.tostring(tp3Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeSL,
         "SL\n$" + str.tostring(slDollar, "#.##"),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    longState := 0
    longMethod := 0

//=====================================================================
// 18. SELL ENTRY
//=====================================================================

sellEntry = finalSell and not inTrade

if sellEntry

    inTrade := true
    tradeDirection := -1
    tradeMethod := shortMethod

    entryPrice := close

    tradeSL := entryPrice + slDistance
    tradeTP1 := entryPrice - tp1Distance
    tradeTP2 := entryPrice - tp2Distance
    tradeTP3 := entryPrice - tp3Distance

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

    methodText = tradeMethod == 1 ? "REVERSAL" : "TREND"

    label.new(
         bar_index,
         high,
         "SELL\n" + methodText,
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

    label.new(
         bar_index,
         entryPrice,
         "ENTRY\n" + str.tostring(entryPrice, format.mintick),
         style=label.style_label_left,
         color=color.gray,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP1,
         "TP1\n$" + str.tostring(tp1Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP2,
         "TP2\n$" + str.tostring(tp2Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeTP3,
         "TP3\n$" + str.tostring(tp3Dollar, "#.##"),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    label.new(
         bar_index,
         tradeSL,
         "SL\n$" + str.tostring(slDollar, "#.##"),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    shortState := 0
    shortMethod := 0

//=====================================================================
// 19. BUY TRADE MANAGEMENT
//=====================================================================

if inTrade and tradeDirection == 1

    // Conservative assumption:
    // If TP and SL are touched on the same candle,
    // SL is assumed to happen first.

    slTouched = low <= tradeSL

    tp1Touched = high >= tradeTP1
    tp2Touched = high >= tradeTP2
    tp3Touched = high >= tradeTP3

    if slTouched

        remaining =
             tp3Hit ? 0.0 :
             tp2Hit ? 0.34 :
             tp1Hit ? 0.67 :
             1.0

        pnl =
             (tp1Hit ? tp1Dollar * 0.33 : 0) +
             (tp2Hit ? tp2Dollar * 0.33 : 0) +
             (tp3Hit ? tp3Dollar * 0.34 : 0) -
             (slDollar * remaining)

        outcome = pnl > 0 ? 1 : pnl < 0 ? 0 : 2

        storeTrade(
             pnl,
             1,
             tradeMethod,
             outcome,
             tp1Hit ? 1 : 0,
             tp2Hit ? 1 : 0,
             tp3Hit ? 1 : 0,
             1)

        inTrade := false

    else

        if not tp1Hit and tp1Touched
            tp1Hit := true

        if not tp2Hit and tp2Touched
            tp2Hit := true

        if not tp3Hit and tp3Touched
            tp3Hit := true

        if tp3Hit

            pnl =
                 tp1Dollar * 0.33 +
                 tp2Dollar * 0.33 +
                 tp3Dollar * 0.34

            storeTrade(
                 pnl,
                 1,
                 tradeMethod,
                 1,
                 1,
                 1,
                 1,
                 0)

            inTrade := false

//=====================================================================
// 20. SELL TRADE MANAGEMENT
//=====================================================================

if inTrade and tradeDirection == -1

    slTouched = high >= tradeSL

    tp1Touched = low <= tradeTP1
    tp2Touched = low <= tradeTP2
    tp3Touched = low <= tradeTP3

    if slTouched

        remaining =
             tp3Hit ? 0.0 :
             tp2Hit ? 0.34 :
             tp1Hit ? 0.67 :
             1.0

        pnl =
             (tp1Hit ? tp1Dollar * 0.33 : 0) +
             (tp2Hit ? tp2Dollar * 0.33 : 0) +
             (tp3Hit ? tp3Dollar * 0.34 : 0) -
             (slDollar * remaining)

        outcome = pnl > 0 ? 1 : pnl < 0 ? 0 : 2

        storeTrade(
             pnl,
             -1,
             tradeMethod,
             outcome,
             tp1Hit ? 1 : 0,
             tp2Hit ? 1 : 0,
             tp3Hit ? 1 : 0,
             1)

        inTrade := false

    else

        if not tp1Hit and tp1Touched
            tp1Hit := true

        if not tp2Hit and tp2Touched
            tp2Hit := true

        if not tp3Hit and tp3Touched
            tp3Hit := true

        if tp3Hit

            pnl =
                 tp1Dollar * 0.33 +
                 tp2Dollar * 0.33 +
                 tp3Dollar * 0.34

            storeTrade(
                 pnl,
                 -1,
                 tradeMethod,
                 1,
                 1,
                 1,
                 1,
                 0)

            inTrade := false

//=====================================================================
// 21. BACKTEST TABLE
//=====================================================================

groupTable = "BACKTEST TABLE"

showTable = input.bool(true, "Show Backtest Table", group=groupTable)

tablePosInput = input.string(
     "Top Right",
     "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=groupTable)

tablePos =
     tablePosInput == "Top Left" ? position.top_left :
     tablePosInput == "Bottom Right" ? position.bottom_right :
     tablePosInput == "Bottom Left" ? position.bottom_left :
     position.top_right

var table stats = table.new(
     position.top_right,
     4,
     18,
     border_width=1)

//=====================================================================
// 22. CALCULATE LAST 500 RESULTS
//=====================================================================

tradeCount = array.size(pnlArray)

wins = 0
losses = 0
breakeven = 0

buyCount = 0
sellCount = 0

reversalCount = 0
trendCount = 0

tp1Count = 0
tp2Count = 0
tp3Count = 0
slCount = 0

netProfit = 0.0
grossProfit = 0.0
grossLoss = 0.0

equity = 0.0
peakEquity = 0.0
maxDD = 0.0

if tradeCount > 0

    for i = 0 to tradeCount - 1

        p = array.get(pnlArray, i)
        d = array.get(directionArray, i)
        m = array.get(methodArray, i)
        o = array.get(outcomeArray, i)

        t1 = array.get(tp1Array, i)
        t2 = array.get(tp2Array, i)
        t3 = array.get(tp3Array, i)
        sl = array.get(slArray, i)

        netProfit += p

        if p > 0
            grossProfit += p

        if p < 0
            grossLoss += math.abs(p)

        if o == 1
            wins += 1
        else if o == 0
            losses += 1
        else
            breakeven += 1

        if d == 1
            buyCount += 1
        else
            sellCount += 1

        if m == 1
            reversalCount += 1
        else
            trendCount += 1

        tp1Count += t1
        tp2Count += t2
        tp3Count += t3
        slCount += sl

        equity += p

        if equity > peakEquity
            peakEquity := equity

        drawdown = peakEquity - equity

        if drawdown > maxDD
            maxDD := drawdown

winRate =
     tradeCount > 0 ?
     wins / tradeCount * 100 :
     0.0

profitFactor =
     grossLoss > 0 ?
     grossProfit / grossLoss :
     na

//=====================================================================
// 23. TABLE
//=====================================================================

if showTable and barstate.islast

    table.set_position(stats, tablePos)

    table.clear(stats, 0, 0, 3, 17)

    table.cell(
         stats,
         0,
         0,
         "3 EMA PRO V2",
         bgcolor=color.rgb(60, 60, 60),
         text_color=color.white)

    table.merge_cells(stats, 0, 0, 3, 0)

    table.cell(
         stats,
         0,
         1,
         "LAST 500 SIGNALS",
         bgcolor=color.rgb(90, 90, 90),
         text_color=color.white)

    table.merge_cells(stats, 0, 1, 3, 1)

    // Trades / Win rate
    table.cell(stats, 0, 2, "Signals", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 2, str.tostring(tradeCount), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 2, "Win %", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 2, str.tostring(winRate, "#.##") + "%", bgcolor=color.black, text_color=color.lime)

    // Wins / losses
    table.cell(stats, 0, 3, "Wins", bgcolor=color.black, text_color=color.lime)
    table.cell(stats, 1, 3, str.tostring(wins), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 3, "Losses", bgcolor=color.black, text_color=color.red)
    table.cell(stats, 3, 3, str.tostring(losses), bgcolor=color.black, text_color=color.white)

    // BE / Net
    table.cell(stats, 0, 4, "BE", bgcolor=color.black, text_color=color.yellow)
    table.cell(stats, 1, 4, str.tostring(breakeven), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 4, "Net P/L", bgcolor=color.black, text_color=color.white)
    table.cell(
         stats,
         3,
         4,
         "$" + str.tostring(netProfit, "#.##"),
         bgcolor=color.black,
         text_color=netProfit >= 0 ? color.lime : color.red)

    // Profit factor
    table.cell(stats, 0, 5, "Profit Factor", bgcolor=color.black, text_color=color.white)
    table.cell(
         stats,
         1,
         5,
         na(profitFactor) ? "N/A" : str.tostring(profitFactor, "#.##"),
         bgcolor=color.black,
         text_color=color.white)

    table.merge_cells(stats, 1, 5, 3, 5)

    // Max DD
    table.cell(stats, 0, 6, "Max DD", bgcolor=color.black, text_color=color.white)
    table.cell(
         stats,
         1,
         6,
         "$" + str.tostring(maxDD, "#.##"),
         bgcolor=color.black,
         text_color=color.red)

    table.merge_cells(stats, 1, 6, 3, 6)

    // Direction
    table.cell(stats, 0, 7, "BUY", bgcolor=color.green, text_color=color.white)
    table.cell(stats, 1, 7, str.tostring(buyCount), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 7, "SELL", bgcolor=color.red, text_color=color.white)
    table.cell(stats, 3, 7, str.tostring(sellCount), bgcolor=color.black, text_color=color.white)

    // Method
    table.cell(stats, 0, 8, "REVERSAL", bgcolor=color.green, text_color=color.white)
    table.cell(stats, 1, 8, str.tostring(reversalCount), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 8, "TREND", bgcolor=color.teal, text_color=color.white)
    table.cell(stats, 3, 8, str.tostring(trendCount), bgcolor=color.black, text_color=color.white)

    // TP statistics
    table.cell(stats, 0, 9, "TP1 Hit", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 9, str.tostring(tp1Count), bgcolor=color.black, text_color=color.lime)

    table.cell(stats, 2, 9, "TP2 Hit", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 9, str.tostring(tp2Count), bgcolor=color.black, text_color=color.lime)

    table.cell(stats, 0, 10, "TP3 Hit", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 10, str.tostring(tp3Count), bgcolor=color.black, text_color=color.lime)

    table.cell(stats, 2, 10, "SL Hit", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 10, str.tostring(slCount), bgcolor=color.black, text_color=color.red)

    // EMA
    table.cell(stats, 0, 11, "EMA", bgcolor=color.black, text_color=color.yellow)

    table.cell(
         stats,
         1,
         11,
         str.tostring(fastLen) + "/" +
         str.tostring(midLen) + "/" +
         str.tostring(slowLen),
         bgcolor=color.black,
         text_color=color.white)

    table.cell(stats, 2, 11, "Pivot", bgcolor=color.black, text_color=color.yellow)

    table.cell(
         stats,
         3,
         11,
         str.tostring(pivotLeft) + "/" +
         str.tostring(pivotRight),
         bgcolor=color.black,
         text_color=color.white)

    // TP / SL values
    table.cell(stats, 0, 12, "TP1", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 12, "$" + str.tostring(tp1Dollar, "#.##"), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 12, "TP2", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 12, "$" + str.tostring(tp2Dollar, "#.##"), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 0, 13, "TP3", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 13, "$" + str.tostring(tp3Dollar, "#.##"), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 13, "SL", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 13, "$" + str.tostring(slDollar, "#.##"), bgcolor=color.black, text_color=color.white)

    // Active trade
    table.cell(stats, 0, 14, "Position", bgcolor=color.black, text_color=color.white)

    table.cell(
         stats,
         1,
         14,
         inTrade ? (tradeDirection == 1 ? "BUY" : "SELL") : "FLAT",
         bgcolor=color.black,
         text_color=inTrade ? color.yellow : color.white)

    table.cell(stats, 2, 14, "Size", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 14, str.tostring(positionSize), bgcolor=color.black, text_color=color.white)

    // Setup states
    table.cell(stats, 0, 15, "Long State", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 15, str.tostring(longState), bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 15, "Short State", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 15, str.tostring(shortState), bgcolor=color.black, text_color=color.white)

    // Legend
    table.cell(stats, 0, 16, "1", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 16, "Reversal", bgcolor=color.black, text_color=color.white)

    table.cell(stats, 2, 16, "2", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 16, "Trend", bgcolor=color.black, text_color=color.white)

    // Footer
    table.cell(
         stats,
         0,
         17,
         "20/50/100 • 10/10 • HH/LL",
         bgcolor=color.rgb(50, 50, 50),
         text_color=color.yellow)

    table.merge_cells(stats, 0, 17, 3, 17)

//=====================================================================
// 24. ALERTS
//=====================================================================

alertcondition(
     buyEntry,
     "3EMA PRO BUY",
     "3EMA PRO BUY confirmed")

alertcondition(
     sellEntry,
     "3EMA PRO SELL",
     "3EMA PRO SELL confirmed")

alertcondition(
     bullBreak,
     "HH Break",
     "Bullish HH structure break confirmed")

alertcondition(
     bearBreak,
     "LL Break",
     "Bearish LL structure break confirmed")
````
