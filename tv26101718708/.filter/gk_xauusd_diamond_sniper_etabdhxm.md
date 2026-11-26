# GK XAUUSD Diamond Sniper

- url: https://www.tradingview.com/script/ETabdhXm-GK-XAUUSD-Diamond-Sniper/
- type: indicator
- pine_id: PUB;66e07d6cf5ed4091acac9d8f63fc7bc3
- version: 1.0

## Description

What GK XAUUSD Diamond Sniper Does
GK XAUUSD Diamond Sniper is a Gold-focused trend and signal tool designed to help identify high-probability directional moves on XAU/USD.
The system combines:
GK BUY / GK SELL trend prints
Strong trend context filtering
A main 10-pip TP system
1-minute diamond confirmation prints projected onto selected timeframes
A separate diamond TP system
Trend-state filtering
Cooldown logic to reduce overprinting
Weekly and previous-month TP hit-status tracking
A 2-month diamond hit-status tracker
The goal is to help traders follow the current Gold structure instead of forcing random entries.
How The Main Signals Work
The main GK BUY and GK SELL prints are generated using a combination of:
Zero-lag style trend logic
Fast and main trend line separation
ATR-based movement filtering
Candle strength filtering
Range/chop avoidance
Breakout confirmation
One-print-per-trend logic
Cooldown protection
When the system detects enough trend pressure, it prints either:
GK BUY
or
GK SELL
These are designed to catch directional movement in line with the current market pressure.
The main TP target is set to 10 pips.
How The Diamond Prints Work
The diamond prints are an additional confirmation layer.
They appear as:
GK BUY 💎
or
GK SELL 💎
These are based on the faster 1-minute logic and projected onto the active trading chart. The purpose of the diamond prints is to highlight sharper momentum shifts and possible continuation/reversal opportunities.
The diamond TP is set to 19 pips.
Diamond prints are separate from the normal GK BUY / GK SELL prints and have their own TP logic.
TP Hit Status
The indicator includes a built-in stats table showing:
This week’s TP hit status
Previous month TP hit status
Two-month-back TP hit status
2-month diamond TP hit status
This helps users visually track how the system has been performing over recent historical structure.
The stats are there for guidance and review, not as a guarantee of future results.
How To Use It
The best way to use GK XAUUSD Diamond Sniper is to combine the signals with your own analysis.
Recommended use:
Focus mainly on XAU/USD only
Use the 15-minute timeframe as the preferred timeframe
Watch the overall market structure before taking a signal
Do not blindly enter every print without checking trend, support, resistance, news, and volatility
Understand that price can sometimes move into drawdown first before pushing toward TP
Trust the process, but always manage risk properly
Avoid overtrading between signals
Let the market come to you
Sometimes a print may appear and price may pull back first before continuing toward TP. This is normal in Gold because XAU/USD often retests, sweeps liquidity, or creates temporary drawdown before continuing in the intended direction.
The indicator is designed to assist decision-making, not replace your own trading brain.
Important Trading Disclaimer
This indicator does not guarantee profits and is not financial advice.
No trading indicator is 100% accurate. Losses can happen, and users should always apply proper risk management, position sizing, and their own analysis before entering any trade.
Gold is highly volatile and can move aggressively during news events, market opens, liquidity grabs, and geopolitical headlines. Always trade responsibly.

## Source Code

````pine
//@version=6
indicator("GK XAUUSD Diamond Sniper", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mainLen = input.int(34, "Main Trend Length", minval=2)
fastLen = input.int(13, "Fast Trigger Length", minval=2)
atrLen = input.int(14, "ATR Length", minval=1)

rangeLookback = input.int(20, "Range Lookback", minval=5)
noPrintRangePips = input.float(30.0, "No Print Range Size", step=0.5)
breakBufferPips = input.float(2.5, "Breakout Buffer", step=0.1)

tpMove = input.float(10.0, "Main TP Move", step=0.1)

minSepATR = input.float(0.08, "Min Line Separation ATR", step=0.01)
minSlopeATR = input.float(0.045, "Min Main Slope ATR", step=0.005)
minCandleATR = input.float(0.30, "Min Candle Range ATR", step=0.01)
lineBlockATR = input.float(0.35, "Too Close To Line Block ATR", step=0.01)

cooldownBars = input.int(10, "Cooldown Bars After Print", minval=1)

showMainLine = input.bool(true, "Show GK Line")
showRangeLines = input.bool(false, "Show Range Lines")
showTP = input.bool(true, "Show Main TP")
showStats = input.bool(true, "Show Weekly / Previous Month Stats")
showPrintCandle = input.bool(true, "Highlight Print Candle Neon Blue")

// 1H STRONG CONTEXT SETTINGS
htfTf = input.timeframe("60", "Strong Context HTF")
htfLen = input.int(50, "1H Trend Strength Length", minval=5)
htfSlopeLookback = input.int(2, "1H Slope Lookback", minval=1)
htfSlopeATR = input.float(0.035, "1H Strong Trend Slope ATR", step=0.005)

// 25M ARROW SETTINGS
show25mArrows = input.bool(true, "Show 25M Signal Arrows")
signalTf25 = input.timeframe("25", "25M Signal Timeframe")
buyArrowColor = input.color(color.aqua, "25M Buy Arrow Color")
sellArrowColor = input.color(color.yellow, "25M Sell Arrow Color")

// 1M DIAMOND SETTINGS
show1mDiamonds = input.bool(true, "Show 1M Diamond Prints")
microTf = input.timeframe("1", "Diamond Source Timeframe")
showDiamondTP = input.bool(true, "Show Diamond TP")
diamondTpMove = input.float(19.0, "Diamond TP Move", step=0.1)
diamondColor = input.color(color.rgb(40, 110, 255), "Diamond Box Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOCK TO LAUNCH TIMEFRAMES ONLY
// 5M / 15M / 20M / 25M / 30M
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isAllowedTf = timeframe.period == "5" or timeframe.period == "15" or timeframe.period == "20" or timeframe.period == "25" or timeframe.period == "30"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZLEMA ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lagMain = int(math.floor((mainLen - 1) / 2))
mainAdj = lagMain > 0 ? close + (close - close[lagMain]) : close
mainLine = ta.ema(mainAdj, mainLen)

lagFast = int(math.floor((fastLen - 1) / 2))
fastAdj = lagFast > 0 ? close + (close - close[lagFast]) : close
fastLine = ta.ema(fastAdj, fastLen)

atr = ta.atr(atrLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE / CHOP FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rangeHigh = ta.highest(high, rangeLookback)[1]
rangeLow = ta.lowest(low, rangeLookback)[1]
rangeSize = rangeHigh - rangeLow

insideCompression = rangeSize <= noPrintRangePips and close <= rangeHigh and close >= rangeLow

rangeBreakBuy = close > rangeHigh + breakBufferPips
rangeBreakSell = close < rangeLow - breakBufferPips

distanceFromLine = math.abs(close - mainLine)
tooCloseToLine = distanceFromLine < atr * lineBlockATR

allowPrintZone = not insideCompression and not tooCloseToLine

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND + PRESSURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mainSlope = mainLine - mainLine[1]
sep = math.abs(fastLine - mainLine)

bullLine = fastLine > mainLine and close > mainLine
bearLine = fastLine < mainLine and close < mainLine

bullSlope = mainSlope > atr * minSlopeATR
bearSlope = mainSlope < -atr * minSlopeATR

sepOk = sep > atr * minSepATR

candleRange = high - low
candleForce = candleRange > atr * minCandleATR

bullPressure = close > high[1] and close > open
bearPressure = close < low[1] and close < open

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RAW SETUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rawBuy = allowPrintZone and rangeBreakBuy and bullLine and bullSlope and sepOk and candleForce and bullPressure
rawSell = allowPrintZone and rangeBreakSell and bearLine and bearSlope and sepOk and candleForce and bearPressure

buyTrigger = barstate.isconfirmed and rawBuy
sellTrigger = barstate.isconfirmed and rawSell

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1 PRINT PER TREND + COOLDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int trendLock = 0
var int lastSignalBar = na

cooldownActive = not na(lastSignalBar) and (bar_index - lastSignalBar < cooldownBars)
canPrint = not cooldownActive

baseGkBuy = buyTrigger and trendLock != 1 and canPrint
baseGkSell = sellTrigger and trendLock != -1 and canPrint

gkBuy = isAllowedTf and baseGkBuy
gkSell = isAllowedTf and baseGkSell

trendLock := baseGkBuy ? 1 : baseGkSell ? -1 : trendLock
lastSignalBar := baseGkBuy or baseGkSell ? bar_index : lastSignalBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1H STRONG TREND CONTEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfAtr = request.security(syminfo.tickerid, htfTf, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)
htfLine = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlope = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfLen) - ta.ema(close, htfLen)[htfSlopeLookback], barmerge.gaps_off, barmerge.lookahead_off)

strongBull1H = htfClose > htfLine and htfSlope > htfAtr * htfSlopeATR
strongBear1H = htfClose < htfLine and htfSlope < -htfAtr * htfSlopeATR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRONG LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
strongBuy = gkBuy and strongBear1H
strongSell = gkSell and strongBull1H

cleanBuy = gkBuy and not strongBuy
cleanSell = gkSell and not strongSell

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 25M HTF SIGNAL ARROWS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buy25Signal = request.security(syminfo.tickerid, signalTf25, baseGkBuy ? 1 : 0, barmerge.gaps_off, barmerge.lookahead_off)
sell25Signal = request.security(syminfo.tickerid, signalTf25, baseGkSell ? 1 : 0, barmerge.gaps_off, barmerge.lookahead_off)

buy25Arrow = isAllowedTf and show25mArrows and buy25Signal == 1 and buy25Signal[1] != 1
sell25Arrow = isAllowedTf and show25mArrows and sell25Signal == 1 and sell25Signal[1] != 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1M DIAMOND PRINTS ON LAUNCH TIMEFRAMES
// 1 PRINT PER DIAMOND TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isDiamondHostTf = isAllowedTf

buy1mSignal = request.security(syminfo.tickerid, microTf, baseGkBuy ? 1 : 0, barmerge.gaps_off, barmerge.lookahead_off)
sell1mSignal = request.security(syminfo.tickerid, microTf, baseGkSell ? 1 : 0, barmerge.gaps_off, barmerge.lookahead_off)

buy1mPriceRaw = request.security(syminfo.tickerid, microTf, baseGkBuy ? close : na, barmerge.gaps_off, barmerge.lookahead_off)
sell1mPriceRaw = request.security(syminfo.tickerid, microTf, baseGkSell ? close : na, barmerge.gaps_off, barmerge.lookahead_off)

rawBuy1mDiamond = show1mDiamonds and isDiamondHostTf and buy1mSignal == 1 and buy1mSignal[1] != 1
rawSell1mDiamond = show1mDiamonds and isDiamondHostTf and sell1mSignal == 1 and sell1mSignal[1] != 1

var int diamondTrendLock = 0

buy1mDiamond = rawBuy1mDiamond and diamondTrendLock != 1
sell1mDiamond = rawSell1mDiamond and diamondTrendLock != -1

diamondTrendLock := buy1mDiamond ? 1 : sell1mDiamond ? -1 : diamondTrendLock

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP ENGINE — MAIN SYSTEM 10 PIPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float entryPrice = na
var int entryBar = na
var int tradeDir = 0
var bool tpDone = false

entryPrice := gkBuy ? close : gkSell ? close : entryPrice
entryBar := gkBuy or gkSell ? bar_index : entryBar
tradeDir := gkBuy ? 1 : gkSell ? -1 : tradeDir
tpDone := gkBuy or gkSell ? false : tpDone

afterEntry = not na(entryBar) and bar_index > entryBar

buyTP = isAllowedTf and showTP and afterEntry and tradeDir == 1 and not tpDone and high >= entryPrice + tpMove
sellTP = isAllowedTf and showTP and afterEntry and tradeDir == -1 and not tpDone and low <= entryPrice - tpMove

tpDone := buyTP or sellTP ? true : tpDone

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIAMOND TP ENGINE — 19 PIPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float diamondEntryPrice = na
var int diamondEntryBar = na
var int diamondTradeDir = 0
var bool diamondTpDone = false

diamondEntryPrice := buy1mDiamond ? nz(buy1mPriceRaw, close) : sell1mDiamond ? nz(sell1mPriceRaw, close) : diamondEntryPrice
diamondEntryBar := buy1mDiamond or sell1mDiamond ? bar_index : diamondEntryBar
diamondTradeDir := buy1mDiamond ? 1 : sell1mDiamond ? -1 : diamondTradeDir
diamondTpDone := buy1mDiamond or sell1mDiamond ? false : diamondTpDone

afterDiamondEntry = not na(diamondEntryBar) and bar_index > diamondEntryBar

diamondBuyTP = isAllowedTf and showDiamondTP and afterDiamondEntry and diamondTradeDir == 1 and not diamondTpDone and high >= diamondEntryPrice + diamondTpMove
diamondSellTP = isAllowedTf and showDiamondTP and afterDiamondEntry and diamondTradeDir == -1 and not diamondTpDone and low <= diamondEntryPrice - diamondTpMove

diamondTpDone := diamondBuyTP or diamondSellTP ? true : diamondTpDone

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WEEKLY + PREVIOUS MONTH HIT STATUS
// MAIN STATS + 2 MONTH DIAMOND STATS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
signalNow = gkBuy or gkSell ? 1 : 0
tpNow = buyTP or sellTP ? 1 : 0

diamondSignalNow = buy1mDiamond or sell1mDiamond ? 1 : 0
diamondTpNow = diamondBuyTP or diamondSellTP ? 1 : 0

newWeek = not na(time[1]) and (weekofyear(time) != weekofyear(time[1]) or year(time) != year(time[1]))
newMonth = not na(time[1]) and (month(time) != month(time[1]) or year(time) != year(time[1]))

var int weekSignals = 0
var int weekTP = 0

weekSignals := newWeek ? signalNow : weekSignals + signalNow
weekTP := newWeek ? tpNow : weekTP + tpNow

var int currentMonthSignals = 0
var int currentMonthTP = 0

var int prevMonthSignals = 0
var int prevMonthTP = 0
var int prevMonthNumber = na

var int twoBackMonthSignals = 0
var int twoBackMonthTP = 0
var int twoBackMonthNumber = na

var int currentDiamondSignals = 0
var int currentDiamondTP = 0

var int prevDiamondSignals = 0
var int prevDiamondTP = 0

var int twoBackDiamondSignals = 0
var int twoBackDiamondTP = 0

oldCurrentMonthSignals = currentMonthSignals
oldCurrentMonthTP = currentMonthTP
oldPrevMonthSignals = prevMonthSignals
oldPrevMonthTP = prevMonthTP
oldPrevMonthNumber = prevMonthNumber

oldCurrentDiamondSignals = currentDiamondSignals
oldCurrentDiamondTP = currentDiamondTP
oldPrevDiamondSignals = prevDiamondSignals
oldPrevDiamondTP = prevDiamondTP

twoBackMonthSignals := newMonth ? oldPrevMonthSignals : twoBackMonthSignals
twoBackMonthTP := newMonth ? oldPrevMonthTP : twoBackMonthTP
twoBackMonthNumber := newMonth ? oldPrevMonthNumber : twoBackMonthNumber

prevMonthSignals := newMonth ? oldCurrentMonthSignals : prevMonthSignals
prevMonthTP := newMonth ? oldCurrentMonthTP : prevMonthTP
prevMonthNumber := newMonth ? month(time[1]) : prevMonthNumber

currentMonthSignals := newMonth ? signalNow : currentMonthSignals + signalNow
currentMonthTP := newMonth ? tpNow : currentMonthTP + tpNow

twoBackDiamondSignals := newMonth ? oldPrevDiamondSignals : twoBackDiamondSignals
twoBackDiamondTP := newMonth ? oldPrevDiamondTP : twoBackDiamondTP

prevDiamondSignals := newMonth ? oldCurrentDiamondSignals : prevDiamondSignals
prevDiamondTP := newMonth ? oldCurrentDiamondTP : prevDiamondTP

currentDiamondSignals := newMonth ? diamondSignalNow : currentDiamondSignals + diamondSignalNow
currentDiamondTP := newMonth ? diamondTpNow : currentDiamondTP + diamondTpNow

weekRatio = weekSignals > 0 ? (weekTP * 100.0) / weekSignals : na
prevMonthRatio = prevMonthSignals > 0 ? (prevMonthTP * 100.0) / prevMonthSignals : na
twoBackMonthRatio = twoBackMonthSignals > 0 ? (twoBackMonthTP * 100.0) / twoBackMonthSignals : na

diamondTwoMonthSignals = prevDiamondSignals + twoBackDiamondSignals
diamondTwoMonthTP = prevDiamondTP + twoBackDiamondTP
diamondTwoMonthRatio = diamondTwoMonthSignals > 0 ? (diamondTwoMonthTP * 100.0) / diamondTwoMonthSignals : na

weekText = weekSignals > 0 ? str.tostring(weekTP) + "/" + str.tostring(weekSignals) + " | " + str.tostring(weekRatio, "#.##") + "%" : "0/0 | n/a"
prevMonthText = prevMonthSignals > 0 ? str.tostring(prevMonthTP) + "/" + str.tostring(prevMonthSignals) + " | " + str.tostring(prevMonthRatio, "#.##") + "%" : "0/0 | n/a"
twoBackMonthText = twoBackMonthSignals > 0 ? str.tostring(twoBackMonthTP) + "/" + str.tostring(twoBackMonthSignals) + " | " + str.tostring(twoBackMonthRatio, "#.##") + "%" : "0/0 | n/a"
diamondTwoMonthText = diamondTwoMonthSignals > 0 ? str.tostring(diamondTwoMonthTP) + "/" + str.tostring(diamondTwoMonthSignals) + " | " + str.tostring(diamondTwoMonthRatio, "#.##") + "%" : "0/0 | n/a"

prevMonthName = na(prevMonthNumber) ? "PREV MONTH" : prevMonthNumber == 1 ? "JANUARY" : prevMonthNumber == 2 ? "FEBRUARY" : prevMonthNumber == 3 ? "MARCH" : prevMonthNumber == 4 ? "APRIL" : prevMonthNumber == 5 ? "MAY" : prevMonthNumber == 6 ? "JUNE" : prevMonthNumber == 7 ? "JULY" : prevMonthNumber == 8 ? "AUGUST" : prevMonthNumber == 9 ? "SEPTEMBER" : prevMonthNumber == 10 ? "OCTOBER" : prevMonthNumber == 11 ? "NOVEMBER" : "DECEMBER"
twoBackMonthName = na(twoBackMonthNumber) ? "2 MONTHS AGO" : twoBackMonthNumber == 1 ? "JANUARY" : twoBackMonthNumber == 2 ? "FEBRUARY" : twoBackMonthNumber == 3 ? "MARCH" : twoBackMonthNumber == 4 ? "APRIL" : twoBackMonthNumber == 5 ? "MAY" : twoBackMonthNumber == 6 ? "JUNE" : twoBackMonthNumber == 7 ? "JULY" : twoBackMonthNumber == 8 ? "AUGUST" : twoBackMonthNumber == 9 ? "SEPTEMBER" : twoBackMonthNumber == 10 ? "OCTOBER" : twoBackMonthNumber == 11 ? "NOVEMBER" : "DECEMBER"

var table statsTable = table.new(position.top_right, 2, 5, border_width=1)

table.cell(statsTable, 0, 0, showStats ? "GK STATS" : "", text_color=color.white, bgcolor=color.black)
table.cell(statsTable, 1, 0, showStats ? "TP HIT STATUS" : "", text_color=color.white, bgcolor=color.black)

table.cell(statsTable, 0, 1, showStats ? "THIS WEEK" : "", text_color=color.white, bgcolor=color.new(color.blue, 25))
table.cell(statsTable, 1, 1, showStats ? weekText : "", text_color=color.white, bgcolor=color.new(color.blue, 25))

table.cell(statsTable, 0, 2, showStats ? prevMonthName : "", text_color=color.white, bgcolor=color.new(color.purple, 35))
table.cell(statsTable, 1, 2, showStats ? prevMonthText : "", text_color=color.white, bgcolor=color.new(color.purple, 35))

table.cell(statsTable, 0, 3, showStats ? twoBackMonthName : "", text_color=color.white, bgcolor=color.new(color.orange, 35))
table.cell(statsTable, 1, 3, showStats ? twoBackMonthText : "", text_color=color.white, bgcolor=color.new(color.orange, 35))

table.cell(statsTable, 0, 4, showStats ? "2M 💎" : "", text_color=color.white, bgcolor=color.new(color.rgb(40, 110, 255), 20))
table.cell(statsTable, 1, 4, showStats ? diamondTwoMonthText : "", text_color=color.white, bgcolor=color.new(color.rgb(40, 110, 255), 20))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lineColor = bullLine ? color.lime : bearLine ? color.red : color.orange

plot(isAllowedTf and showMainLine ? mainLine : na, title="GK Main Line", color=lineColor, linewidth=3)

plot(isAllowedTf and showRangeLines ? rangeHigh : na, title="Range High", color=color.new(color.red, 35), linewidth=1)
plot(isAllowedTf and showRangeLines ? rangeLow : na, title="Range Low", color=color.new(color.green, 35), linewidth=1)

// NEON SKY BLUE PRINT CANDLE
barcolor(isAllowedTf and showPrintCandle and (gkBuy or gkSell) ? color.rgb(0, 255, 255) : na)

// MAIN GK PRINTS
plotshape(cleanBuy, title="GK BUY", text="GK BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal)
plotshape(cleanSell, title="GK SELL", text="GK SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

plotshape(strongBuy, title="GK BUY STRONG", text="GK BUY\nStrong", style=shape.labelup, location=location.belowbar, color=color.orange, textcolor=color.white, size=size.normal)
plotshape(strongSell, title="GK SELL STRONG", text="GK SELL\nStrong", style=shape.labeldown, location=location.abovebar, color=color.orange, textcolor=color.white, size=size.normal)

// 25M ARROWS
plotshape(buy25Arrow, title="25M BUY ARROW", text="", style=shape.triangleup, location=location.belowbar, color=buyArrowColor, size=size.tiny)
plotshape(sell25Arrow, title="25M SELL ARROW", text="", style=shape.triangledown, location=location.abovebar, color=sellArrowColor, size=size.tiny)

// MAIN TP
plotshape(buyTP, title="TP BUY", text="TP", style=shape.labeldown, location=location.abovebar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(sellTP, title="TP SELL", text="TP", style=shape.labelup, location=location.belowbar, color=color.red, textcolor=color.white, size=size.tiny)

// 1M DIAMOND PRINTS
plotshape(buy1mDiamond, title="GK BUY DIAMOND", text="GK BUY 💎", style=shape.labelup, location=location.belowbar, color=diamondColor, textcolor=color.white, size=size.small)
plotshape(sell1mDiamond, title="GK SELL DIAMOND", text="GK SELL 💎", style=shape.labeldown, location=location.abovebar, color=diamondColor, textcolor=color.white, size=size.small)

// 1M DIAMOND TP
plotshape(diamondBuyTP, title="DIAMOND TP BUY", text="TP 💎", style=shape.labeldown, location=location.abovebar, color=diamondColor, textcolor=color.white, size=size.tiny)
plotshape(diamondSellTP, title="DIAMOND TP SELL", text="TP 💎", style=shape.labelup, location=location.belowbar, color=diamondColor, textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(cleanBuy, title="GK BUY", message="GK BUY printed")
alertcondition(cleanSell, title="GK SELL", message="GK SELL printed")
alertcondition(strongBuy, title="GK BUY STRONG", message="GK BUY STRONG printed against strong 1H bearish context")
alertcondition(strongSell, title="GK SELL STRONG", message="GK SELL STRONG printed against strong 1H bullish context")
alertcondition(buy25Arrow, title="25M BUY ARROW", message="25M GK BUY print appeared")
alertcondition(sell25Arrow, title="25M SELL ARROW", message="25M GK SELL print appeared")
alertcondition(buyTP or sellTP, title="TP", message="10 pip TP printed")
alertcondition(buy1mDiamond, title="GK BUY DIAMOND", message="1M GK BUY 💎 projected onto launch timeframe")
alertcondition(sell1mDiamond, title="GK SELL DIAMOND", message="1M GK SELL 💎 projected onto launch timeframe")
alertcondition(diamondBuyTP or diamondSellTP, title="DIAMOND TP", message="19 pip diamond TP printed")
````
