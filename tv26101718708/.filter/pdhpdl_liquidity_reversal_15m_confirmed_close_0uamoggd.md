# PDH/PDL Liquidity Reversal - 15M Confirmed Close

- url: https://www.tradingview.com/script/0uAmOgGD-PDH-PDL-Liquidity-Reversal-15M-Confirmed-Close/
- type: indicator
- pine_id: PUB;88709913e7444db89676448552f4bf64
- version: 15.0

## Description

🔍 Overview

This indicator identifies high-probability reversal setups based on Previous Day High (PDH) and Previous Day Low (PDL) liquidity sweeps. It is designed for use on the 15-minute timeframe, using higher timeframe context from the daily range.

The strategy focuses on capturing false breakouts (liquidity grabs) where price moves beyond a key level, traps traders, and then reverses.

🧠 Core Concept

Markets often:

Break above resistance (PDH) → trigger breakout buyers → reverse down
Break below support (PDL) → trigger breakout sellers → reverse up

This script detects those conditions and signals when a confirmed reversal is likely underway.

⚙️ How It Works
1. Previous Day Levels
Automatically plots:
Previous Day High (PDH)
Previous Day Low (PDL)

These act as key liquidity zones.

2. Liquidity Sweep Detection
Tracks when price:
Moves above PDH
Moves below PDL

This indicates a potential stop hunt or liquidity grab.

3. 15-Minute Confirmation (Critical Rule)

Signals are only generated when:

BUY Setup:
Price sweeps below PDL
A 15M candle closes back above PDL
Optional: candle shows bullish rejection (closes in upper half)
SELL Setup:
Price sweeps above PDH
A 15M candle closes back below PDH
Optional: bearish rejection confirmation

👉 This prevents false signals from wick-only moves.

4. Trade Signals
BUY / SELL markers appear on the chart at the signal candle
Signals are limited to one per direction per day (optional)

Each signal includes:

Entry price (based on candle close)
Stop loss (based on current day extreme + buffer)
Target projection using configurable Risk:Reward
5. Risk & Trade Structure
Stop Loss:
BUY → below current day low
SELL → above current day high
Configurable buffer to avoid premature stop-outs
Minimum Risk:Reward filter (default 1.5R)
6. Smart Trailing Stop (Key Feature)

A structure-based trailing system is included:

Activates only after price reaches +1R
Trails using:
Higher lows (BUY trades)
Lower highs (SELL trades)
Includes ATR-based buffer to avoid tight stop-outs

👉 This allows trades to breathe while still locking in profits.

7. Visual Features
Clear PDH/PDL levels
BUY/SELL markers at confirmed entries
Order info labels (Entry, Stop, Target)
Adjustable label offset to prevent chart clutter
Trailing stop plotted dynamically
⏰ Best Use Cases
15-minute charts
High-liquidity sessions (New York session preferred)
Works across:
Futures (e.g., S&P 500 / Nasdaq-100)
Forex
High-volume stocks
⚠️ Important Notes
This is a confirmation-based system — patience is required
Not all sweeps lead to reversals; filtering is built in
Avoid low-volume or ranging market conditions
🎯 Strategy Objective

To consistently capture high-probability reversals after liquidity sweeps while:

Reducing false entries
Maintaining structured risk management
Allowing winners to run using adaptive trailing stops

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BoomerNuc7987

//@version=6
indicator("PDH/PDL Liquidity Reversal - 15M Confirmed Close", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================================================
// INPUTS
//====================================================
groupLevels = "Previous Day Levels"
showPDH = input.bool(true, "Show Previous Day High", group = groupLevels)
showPDL = input.bool(true, "Show Previous Day Low", group = groupLevels)
showPDMid = input.bool(true, "Show PDH/PDL Midline", group = groupLevels)

groupSignal = "Signal Rules"
requireRejectionClose = input.bool(true, "Require Rejection Candle Close", group = groupSignal)
oneBuyPerDay = input.bool(false, "Only One BUY Signal Per Day", group = groupSignal)
oneSellPerDay = input.bool(false, "Only One SELL Signal Per Day", group = groupSignal)

//====================================================
// MULTI-SYMBOL SCANNER MODE
//====================================================
//groupScanner = "Scanner Mode"
//
//useScannerMode = input.bool(false, "Enable Multi-Symbol Scanner", group = groupScanner)
//scannerTF = input.timeframe("15", "Scanner Timeframe", group = groupScanner)
//
//scanSymbol1  = input.symbol("NASDAQ:AAPL",  "Symbol 1", group = groupScanner)
//scanSymbol2  = input.symbol("NASDAQ:MSFT",  "Symbol 2", group = groupScanner)
//scanSymbol3  = input.symbol("NASDAQ:NVDA",  "Symbol 3", group = groupScanner)
//scanSymbol4  = input.symbol("NASDAQ:TSLA",  "Symbol 4", group = groupScanner)
//scanSymbol5  = input.symbol("NASDAQ:AMD",   "Symbol 5", group = groupScanner)
//scanSymbol6  = input.symbol("NASDAQ:AMZN",  "Symbol 6", group = groupScanner)
//scanSymbol7  = input.symbol("NASDAQ:META",  "Symbol 7", group = groupScanner)
//scanSymbol8  = input.symbol("NASDAQ:GOOGL", "Symbol 8", group = groupScanner)
//scanSymbol9  = input.symbol("NYSE:JPM",     "Symbol 9", group = groupScanner)
//scanSymbol10 = input.symbol("NYSE:XOM",     "Symbol 10", group = groupScanner)

//====================================================
// LABELS & DISPLAY
//====================================================
groupLabels = "Labels & Display"
resetChartDisplay = input.bool(false, "Reset This Chart Display", group = groupLabels)
showHistoricalArrows = input.bool(false, "Show Historical Buy/Sell Arrows", group = groupLabels)

//====================================================
// LABEL OFFSET (DEFINE ONCE)
//====================================================
labelATRmult = input.float(3.0, "Label Offset ATR Multiplier", step = 0.5)
labelTickMult = input.int(50, "Extra Tick Offset", minval = 0)

atrValue = ta.atr(14)
tickOffset = syminfo.mintick * labelTickMult

labelOffset = (atrValue * labelATRmult) + tickOffset

//====================================================
// A+ SCORING SYSTEM
//====================================================
groupScore = "A+ Scoring System"

showScorePanel = input.bool(false, "Show Score Panel", group = groupScore)
onlyAlertAPlus = input.bool(true, "Only Alert If A+", group = groupScore)

aPlusThreshold = input.int(8, "A+ Score Minimum", minval = 1, maxval = 10, group = groupScore)
aThreshold = input.int(7, "A Score Minimum", minval = 1, maxval = 10, group = groupScore)
bThreshold = input.int(5, "B Score Minimum", minval = 1, maxval = 10, group = groupScore)

useRSIScore = input.bool(true, "Use RSI Confirmation", group = groupScore)
rsiLength = input.int(14, "RSI Length", group = groupScore)

//====================================================
// NEAR PDH/PDL ALERT INPUTS
//====================================================
groupNear = "Near PDH/PDL Alerts"
useNearAlerts = input.bool(true, "Enable Near PDH/PDL Alerts", group = groupNear)
nearPercent = input.float(0.15, "Near Level Distance %", step = 0.05, group = groupNear)

groupRisk = "Risk / Stop Settings"
stopBufferTicks = input.int(2, "Stop Buffer in Ticks", minval = 0, group = groupRisk)
minRR = input.float(2.0, "Minimum Reward/Risk Filter", step = 0.25, group = groupRisk)

groupTrail = "Trailing Stop"
useTrailingStop = input.bool(true, "Show Structure Trailing Stop", group = groupTrail)
trailAfterR = input.float(1.5, "Start Trailing After R Multiple", step = 0.25, group = groupTrail)
pivotLeft = input.int(2, "Structure Pivot Left Bars", minval = 1, group = groupTrail)
pivotRight = input.int(2, "Structure Pivot Right Bars", minval = 1, group = groupTrail)
atrLength = input.int(14, "ATR Length", minval = 1, group = groupTrail)
atrBufferMult = input.float(0.50, "ATR Buffer Multiplier", step = 0.10, group = groupTrail)

groupSession = "Session Filter"
useNYSessionOnly = input.bool(true, "Use NY Session Only", group = groupSession)
nySession = input.session("0930-1200", "NY Session", group = groupSession)
sessionTimezone = input.string("America/New_York", "Session Timezone", group = groupSession)

inNYSession = not na(time(timeframe.period, nySession, sessionTimezone))
sessionOK = not useNYSessionOnly or inNYSession

//====================================================
// TRADE STATE VARIABLES (MUST BE AT TOP)
//====================================================
var bool inLong = false
var bool inShort = false

var float longEntry = na
var float longInitialStop = na
var float longRisk = na
var float longTrailStop = na

var float shortEntry = na
var float shortInitialStop = na
var float shortRisk = na
var float shortTrailStop = na

//====================================================
// CUSTOM SESSION PREVIOUS HIGH / LOW
//====================================================
groupPDSession = "PDH/PDL Session Source"

pdSession = input.session("0930-1600", "PDH/PDL Session", group = groupPDSession)
pdTimezone = input.string("America/New_York", "PDH/PDL Timezone", group = groupPDSession)

inPDSession = not na(time(timeframe.period, pdSession, pdTimezone))

pdSessionDay = time("D", pdSession, pdTimezone)
newPDSession = inPDSession and ta.change(pdSessionDay) != 0

var float sessionHigh = na
var float sessionLow = na
var float prevSessionHigh = na
var float prevSessionLow = na

if inPDSession
    if newPDSession
        if not na(sessionHigh) and not na(sessionLow)
            prevSessionHigh := sessionHigh
            prevSessionLow := sessionLow

        sessionHigh := high
        sessionLow := low
    else
        sessionHigh := math.max(nz(sessionHigh, high), high)
        sessionLow := math.min(nz(sessionLow, low), low)

pdh = prevSessionHigh
pdl = prevSessionLow

pdMid =
     not na(pdh) and
     not na(pdl)
     ? (pdh + pdl) / 2
     : na

plot(showPDH ? pdh : na,
     "Previous Day High",
     color = color.new(color.red, 0),
     linewidth = 2)

plot(showPDL ? pdl : na,
     "Previous Day Low",
     color = color.new(color.green, 0),
     linewidth = 2)

plot(showPDMid ? pdMid : na,
     "PDH/PDL Midline",
     color = color.new(color.yellow, 0),
     linewidth = 2)


//====================================================
// NEAR PDH / PDL ALERT LOGIC
//====================================================

nearDistance =
     close *
     (nearPercent / 100)

nearPDH =
     useNearAlerts and
     sessionOK and
     not na(pdh) and
     math.abs(close - pdh) <= nearDistance

nearPDL =
     useNearAlerts and
     sessionOK and
     not na(pdl) and
     math.abs(close - pdl) <= nearDistance

//====================================================
// CURRENT DAY HIGH / LOW
//====================================================
newDay = ta.change(time("D")) != 0

var float currentDayHigh = na
var float currentDayLow = na

if newDay
    currentDayHigh := high
    currentDayLow := low
else
    currentDayHigh := math.max(nz(currentDayHigh, high), high)
    currentDayLow := math.min(nz(currentDayLow, low), low)

//====================================================
// DAILY TRADE DISPLAY RESET
// Clears old panel/trade state at start of new day
//====================================================
if newDay
    inLong := false
    inShort := false

    longEntry := na
    longInitialStop := na
    longRisk := na
    longTrailStop := na

    shortEntry := na
    shortInitialStop := na
    shortRisk := na
    shortTrailStop := na
    
//====================================================
// SWEEP DETECTION
//====================================================
var bool sweptPDL = false
var bool sweptPDH = false

var bool buyTakenToday = false
var bool sellTakenToday = false

if newDay
    sweptPDL := false
    sweptPDH := false
    buyTakenToday := false
    sellTakenToday := false
 
if low < pdl
    sweptPDL := true

if high > pdh
    sweptPDH := true

//====================================================
// 15M CLOSE CONFIRMATION LOGIC
//====================================================
// BUY rejection: candle closes back above PDL and closes in upper half of candle
buyRejectionClose = close > ((high + low) / 2)

// SELL rejection: candle closes back below PDH and closes in lower half of candle
sellRejectionClose = close < ((high + low) / 2)

buyCloseConfirmed =
     sweptPDL and
     close > pdl and
     close[1] <= pdl and
     barstate.isconfirmed and
     (not requireRejectionClose or buyRejectionClose)

sellCloseConfirmed =
     sweptPDH and
     close < pdh and
     close[1] >= pdh and
     barstate.isconfirmed and
     (not requireRejectionClose or sellRejectionClose)

//====================================================
// TRADE STATE FILTER
// Prevent opposite signals while currently in a trade
//====================================================
canBuy =
     sessionOK and
     buyCloseConfirmed and
     not inShort and
     (not oneBuyPerDay or not buyTakenToday)

canSell =
     sessionOK and
     sellCloseConfirmed and
     not inLong and
     (not oneSellPerDay or not sellTakenToday)

//====================================================
// ENTRY / STOP / TARGET ESTIMATES
//====================================================
tickBuffer = stopBufferTicks * syminfo.mintick

buyEntry = close
buyStop = currentDayLow - tickBuffer
buyRisk = buyEntry - buyStop
buyTarget = buyEntry + (buyRisk * minRR)

sellEntry = close
sellStop = currentDayHigh + tickBuffer
sellRisk = sellStop - sellEntry
sellTarget = sellEntry - (sellRisk * minRR)

validBuyRisk = buyRisk > syminfo.mintick
validSellRisk = sellRisk > syminfo.mintick

finalBuySignal = canBuy and validBuyRisk
finalSellSignal = canSell and validSellRisk

if finalBuySignal
    buyTakenToday := true
    sweptPDL := false

if finalSellSignal
    sellTakenToday := true
    sweptPDH := false

//====================================================
// A+ SETUP SCORING LOGIC
//====================================================
rsiValue = ta.rsi(close, rsiLength)

buyRSIConfirm = rsiValue > rsiValue[1] and rsiValue <= 45
sellRSIConfirm = rsiValue < rsiValue[1] and rsiValue >= 55

buyStrongClose = close > ((high + low) / 2)
sellStrongClose = close < ((high + low) / 2)

buySweepQuality = low < pdl and close > pdl
sellSweepQuality = high > pdh and close < pdh

buyScore = 0
sellScore = 0

// BUY SCORE
buyScore += nearPDL ? 2 : 0
buyScore += buySweepQuality ? 2 : 0
buyScore += buyStrongClose ? 2 : 0
buyScore += sessionOK ? 2 : 0
buyScore += useRSIScore and buyRSIConfirm ? 2 : 0

// SELL SCORE
sellScore += nearPDH ? 2 : 0
sellScore += sellSweepQuality ? 2 : 0
sellScore += sellStrongClose ? 2 : 0
sellScore += sessionOK ? 2 : 0
sellScore += useRSIScore and sellRSIConfirm ? 2 : 0

activeScore = finalBuySignal ? buyScore : finalSellSignal ? sellScore : math.max(buyScore, sellScore)

scoreGrade =
     activeScore >= aPlusThreshold ? "A+" :
     activeScore >= aThreshold ? "A" :
     activeScore >= bThreshold ? "B" :
     "SKIP"

scoreColor =
     scoreGrade == "A+" ? color.new(color.green, 0) :
     scoreGrade == "A" ? color.new(color.lime, 0) :
     scoreGrade == "B" ? color.new(color.orange, 0) :
     color.new(color.red, 0)

isAPlusBuy = finalBuySignal and buyScore >= aPlusThreshold
isAPlusSell = finalSellSignal and sellScore >= aPlusThreshold

//====================================================
// TRADE INFO TABLE
//====================================================
showTradeInfoTable = input.bool(true, "Show Trade Info Table", group = groupLabels)

var table tradeInfoTable = table.new(position.bottom_right, 2, 6, border_width = 1)

var string lastTradeDirection = ""
var string lastTradeGrade = ""
var float lastTradeScore = na
var float lastTradeEntry = na
var float lastTradeStop = na
var float lastTradeTarget = na
var color lastTradeColor = color.gray

if newDay
    lastTradeDirection := ""
    lastTradeGrade := ""
    lastTradeScore := na
    lastTradeEntry := na
    lastTradeStop := na
    lastTradeTarget := na
    lastTradeColor := color.gray

if finalBuySignal
    lastTradeDirection := "BUY"
    lastTradeGrade := scoreGrade
    lastTradeScore := buyScore
    lastTradeEntry := buyEntry
    lastTradeStop := buyStop
    lastTradeTarget := buyTarget
    lastTradeColor :=
         scoreGrade == "A+" ? color.new(color.green, 0) :
         scoreGrade == "A" ? color.new(color.green, 20) :
         scoreGrade == "B" ? color.new(color.green, 40) :
         color.new(color.gray, 20)

if finalSellSignal
    lastTradeDirection := "SELL"
    lastTradeGrade := scoreGrade
    lastTradeScore := sellScore
    lastTradeEntry := sellEntry
    lastTradeStop := sellStop
    lastTradeTarget := sellTarget
    lastTradeColor :=
         scoreGrade == "A+" ? color.new(color.red, 0) :
         scoreGrade == "A" ? color.new(color.red, 20) :
         scoreGrade == "B" ? color.new(color.red, 40) :
         color.new(color.gray, 20)

if showTradeInfoTable and barstate.islast

    if lastTradeDirection == ""

        table.cell(tradeInfoTable, 0, 0, "Trade", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 0, "No Active Trade", text_color = color.white, bgcolor = color.new(color.gray, 50))

        table.cell(tradeInfoTable, 0, 1, "", bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 1, "", bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 2, "", bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 2, "", bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 3, "", bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 3, "", bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 4, "", bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 4, "", bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 5, "", bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 5, "", bgcolor = color.black)

    else

        table.cell(tradeInfoTable, 0, 0, "Trade", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 0, lastTradeDirection + " " + lastTradeGrade, text_color = color.white, bgcolor = lastTradeColor)

        table.cell(tradeInfoTable, 0, 1, "Score", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 1, str.tostring(lastTradeScore) + "/10", text_color = color.white, bgcolor = lastTradeColor)

        table.cell(tradeInfoTable, 0, 2, "Entry", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 2, str.tostring(lastTradeEntry, format.mintick), text_color = color.white, bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 3, "Stop", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 3, str.tostring(lastTradeStop, format.mintick), text_color = color.white, bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 4, "Target", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 4, str.tostring(lastTradeTarget, format.mintick), text_color = color.white, bgcolor = color.black)

        table.cell(tradeInfoTable, 0, 5, "RR", text_color = color.white, bgcolor = color.black)
        table.cell(tradeInfoTable, 1, 5, str.tostring(minRR) + "R", text_color = color.white, bgcolor = color.black)

if resetChartDisplay
    lastTradeDirection := ""
    lastTradeGrade := ""
    lastTradeScore := na
    lastTradeEntry := na
    lastTradeStop := na
    lastTradeTarget := na
    lastTradeColor := color.gray

    inLong := false
    inShort := false

    longEntry := na
    longInitialStop := na
    longRisk := na
    longTrailStop := na

    shortEntry := na
    shortInitialStop := na
    shortRisk := na
    shortTrailStop := na
    
//====================================================
// SCORE PANEL
//====================================================
var table scoreTable = table.new(position.top_right, 1, 2, border_width = 1)

if showScorePanel and barstate.islast
    table.cell(
         scoreTable,
         0,
         0,
         "Setup Score",
         text_color = color.white,
         bgcolor = color.new(color.black, 0),
         text_size = size.large
    )

    table.cell(
         scoreTable,
         0,
         1,
         str.tostring(activeScore) + "/10  " + scoreGrade,
         text_color = color.white,
         bgcolor = scoreColor,
         text_size = size.huge
    )

//====================================================
// BUY / SELL TRIGGER ARROWS
//====================================================

plotshape(
     showHistoricalArrows and finalBuySignal,
     title = "Buy Arrow",
     style = shape.arrowup,
     location = location.belowbar,
     color = color.green,
     size = size.large,
     text = "BUY"
)

plotshape(
     showHistoricalArrows and finalSellSignal,
     title = "Sell Arrow",
     style = shape.arrowdown,
     location = location.abovebar,
     color = color.red,
     size = size.large,
     text = "SELL"
)

//====================================================
// TRAILING STOP LOGIC 
//====================================================
atr = ta.atr(atrLength)
atrBuffer = atr * atrBufferMult

pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

if finalBuySignal
    inLong := true
    inShort := false
    longEntry := buyEntry
    longInitialStop := buyStop
    longRisk := buyRisk
    longTrailStop := buyStop

if finalSellSignal
    inShort := true
    inLong := false
    shortEntry := sellEntry
    shortInitialStop := sellStop
    shortRisk := sellRisk
    shortTrailStop := sellStop

longReachedTrailActivation = inLong and high >= longEntry + (longRisk * trailAfterR)
shortReachedTrailActivation = inShort and low <= shortEntry - (shortRisk * trailAfterR)

// Long trailing stop: trail under confirmed 15M higher lows after +1R
if useTrailingStop and longReachedTrailActivation and not na(pivotLow)
    proposedLongTrail = pivotLow - atrBuffer
    longTrailStop := math.max(longTrailStop, proposedLongTrail)

// Short trailing stop: trail above confirmed 15M lower highs after +1R
if useTrailingStop and shortReachedTrailActivation and not na(pivotHigh)
    proposedShortTrail = pivotHigh + atrBuffer
    shortTrailStop := math.min(shortTrailStop, proposedShortTrail)

// Stop-out tracking for visual reset
if inLong and low <= longTrailStop
    inLong := false
    longEntry := na
    longInitialStop := na
    longRisk := na
    longTrailStop := na

    lastTradeDirection := ""
    lastTradeGrade := ""
    lastTradeScore := na
    lastTradeEntry := na
    lastTradeStop := na
    lastTradeTarget := na
    lastTradeColor := color.gray

if inShort and high >= shortTrailStop
    inShort := false
    shortEntry := na
    shortInitialStop := na
    shortRisk := na
    shortTrailStop := na

    lastTradeDirection := ""
    lastTradeGrade := ""
    lastTradeScore := na
    lastTradeEntry := na
    lastTradeStop := na
    lastTradeTarget := na
    lastTradeColor := color.gray

plot(inLong ? longTrailStop : na, "Long Structure Trail", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(inShort ? shortTrailStop : na, "Short Structure Trail", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)

//====================================================
// MULTI-SYMBOL SCANNER FUNCTION
//====================================================
//scannerEval(_symbol) =>
//    _pdh = request.security(_symbol, "D", high[1], lookahead = barmerge.lookahead_off)
//    _pdl = request.security(_symbol, "D", low[1], lookahead = barmerge.lookahead_off)
//
//    [_h, _l, _c, _rsi, _rsiPrev, _sessionOK] = request.security(
//         _symbol,
//         scannerTF,
//         [
//             high,
//             low,
//             close,
//             ta.rsi(close, rsiLength),
//             ta.rsi(close, rsiLength)[1],
//             not useNYSessionOnly or not na(time(timeframe.period, nySession, sessionTimezone))
//         ],
//         lookahead = barmerge.lookahead_off
//    )
//
//    _nearDistance = _c * (nearPercent / 100)
//
//    _nearPDH = math.abs(_c - _pdh) <= _nearDistance
//    _nearPDL = math.abs(_c - _pdl) <= _nearDistance
//
//    _buySweep = _l < _pdl and _c > _pdl
//    _sellSweep = _h > _pdh and _c < _pdh
//
//    _buyStrongClose = _c > ((_h + _l) / 2)
//    _sellStrongClose = _c < ((_h + _l) / 2)
//
//    _buyRSIConfirm = _rsi > _rsiPrev and _rsi <= 45
//    _sellRSIConfirm = _rsi < _rsiPrev and _rsi >= 55
//
//    _buyScore = 0
//    _sellScore = 0
//
//    _buyScore += _nearPDL ? 2 : 0
//    _buyScore += _buySweep ? 2 : 0
//    _buyScore += _buyStrongClose ? 2 : 0
//    _buyScore += _sessionOK ? 2 : 0
//    _buyScore += useRSIScore and _buyRSIConfirm ? 2 : 0
//
//    _sellScore += _nearPDH ? 2 : 0
//    _sellScore += _sellSweep ? 2 : 0
//    _sellScore += _sellStrongClose ? 2 : 0
//    _sellScore += _sessionOK ? 2 : 0
//    _sellScore += useRSIScore and _sellRSIConfirm ? 2 : 0
//
//    _buySignal = _sessionOK and _buySweep and _buyScore >= aPlusThreshold
//    _sellSignal = _sessionOK and _sellSweep and _sellScore >= aPlusThreshold
//
//    [_buySignal, _sellSignal, _buyScore, _sellScore]

//====================================================
// ALERTS
//====================================================
buyAlertAllowed = onlyAlertAPlus ? isAPlusBuy : finalBuySignal
sellAlertAllowed = onlyAlertAPlus ? isAPlusSell : finalSellSignal

alertcondition(
     buyAlertAllowed,
     title = "A+ BUY Signal",
     message = "A+ BUY on {{ticker}} | {{interval}} | PDL sweep confirmed | 15M close back above | Score passed."
)

alertcondition(
     sellAlertAllowed,
     title = "A+ SELL Signal",
     message = "A+ SELL on {{ticker}} | {{interval}} | PDH sweep confirmed | 15M close back below | Score passed."
)

//====================================================
// MULTI-SYMBOL SCANNER ALERTS
//====================================================
//[s1Buy, s1Sell, s1BuyScore, s1SellScore] = scannerEval(scanSymbol1)
//[s2Buy, s2Sell, s2BuyScore, s2SellScore] = scannerEval(scanSymbol2)
//[s3Buy, s3Sell, s3BuyScore, s3SellScore] = scannerEval(scanSymbol3)
//[s4Buy, s4Sell, s4BuyScore, s4SellScore] = scannerEval(scanSymbol4)
//[s5Buy, s5Sell, s5BuyScore, s5SellScore] = scannerEval(scanSymbol5)
//[s6Buy, s6Sell, s6BuyScore, s6SellScore] = scannerEval(scanSymbol6)
//[s7Buy, s7Sell, s7BuyScore, s7SellScore] = scannerEval(scanSymbol7)
//[s8Buy, s8Sell, s8BuyScore, s8SellScore] = scannerEval(scanSymbol8)
//[s9Buy, s9Sell, s9BuyScore, s9SellScore] = scannerEval(scanSymbol9)
//[s10Buy, s10Sell, s10BuyScore, s10SellScore] = scannerEval(scanSymbol10)

//if useScannerMode and barstate.isconfirmed
    //if s1Buy
    //    alert("A+ BUY: " + scanSymbol1 + " | Score: " + str.tostring(s1BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s1Sell
    //    alert("A+ SELL: " + scanSymbol1 + " | Score: " + str.tostring(s1SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s2Buy
    //    alert("A+ BUY: " + scanSymbol2 + " | Score: " + str.tostring(s2BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s2Sell
    //    alert("A+ SELL: " + scanSymbol2 + " | Score: " + str.tostring(s2SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s3Buy
    //    alert("A+ BUY: " + scanSymbol3 + " | Score: " + str.tostring(s3BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s3Sell
    //    alert("A+ SELL: " + scanSymbol3 + " | Score: " + str.tostring(s3SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s4Buy
    //    alert("A+ BUY: " + scanSymbol4 + " | Score: " + str.tostring(s4BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s4Sell
    //    alert("A+ SELL: " + scanSymbol4 + " | Score: " + str.tostring(s4SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s5Buy
    //    alert("A+ BUY: " + scanSymbol5 + " | Score: " + str.tostring(s5BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s5Sell
    //    alert("A+ SELL: " + scanSymbol5 + " | Score: " + str.tostring(s5SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s6Buy
    //    alert("A+ BUY: " + scanSymbol6 + " | Score: " + str.tostring(s6BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s6Sell
    //    alert("A+ SELL: " + scanSymbol6 + " | Score: " + str.tostring(s6SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s7Buy
    //    alert("A+ BUY: " + scanSymbol7 + " | Score: " + str.tostring(s7BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s7Sell
    //    alert("A+ SELL: " + scanSymbol7 + " | Score: " + str.tostring(s7SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s8Buy
    //    alert("A+ BUY: " + scanSymbol8 + " | Score: " + str.tostring(s8BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s8Sell
    //    alert("A+ SELL: " + scanSymbol8 + " | Score: " + str.tostring(s8SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s9Buy
    //    alert("A+ BUY: " + scanSymbol9 + " | Score: " + str.tostring(s9BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s9Sell
    //    alert("A+ SELL: " + scanSymbol9 + " | Score: " + str.tostring(s9SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)

    //if s10Buy
    //    alert("A+ BUY: " + scanSymbol10 + " | Score: " + str.tostring(s10BuyScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
    //if s10Sell
    //    alert("A+ SELL: " + scanSymbol10 + " | Score: " + str.tostring(s10SellScore) + "/10 | TF: " + scannerTF, alert.freq_once_per_bar_close)
````
