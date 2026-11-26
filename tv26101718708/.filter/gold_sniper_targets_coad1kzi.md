# Gold Sniper Targets

- url: https://www.tradingview.com/script/cOaD1kZi-Gold-Sniper-Targets/
- type: indicator
- pine_id: PUB;e7bf2d78b2fd4ae7bc0463844399e514
- version: 1.0

## Description

Gold Sniper Targets 

[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

What This Indicator Is

Gold Sniper Targets is a complete, Gold specific trading system built around a simple exponential moving average crossover, but wrapped in a full stack of confirming conditions so that a signal only appears when momentum, trend strength, volume, multi timeframe agreement, the US Dollar's behavior, the trading session, the day's remaining volatility budget, and proper spacing from the last trade all line up together at once. This is not a generic moving average indicator adapted for Gold, it was designed from the ground up specifically for how Gold behaves, including its relationship with the US Dollar Index. Every time a valid signal fires, the system also builds a complete trade plan around it, an entry, a volatility based stop loss, and three profit targets, and then tracks that trade candle by candle until it closes, so you can see directly on the chart whether it won or lost. Everything is summarized in a set of live panels so you never have to do the math yourself.
[image]https://www.tradingview.com/x/vkzcsMmt/[/image]

Why It Was Built

A plain moving average crossover fires constantly and most of those crossovers are noise, especially on an intraday Gold chart where price chops back and forth around the fast and slow averages all day. This system was built to solve that specific problem by demanding that a real trend, real participation, and real macro context all agree before a crossover is allowed to become a trade. It also solves a second common problem, which is that most indicators tell you when to enter but leave you to figure out the stop and targets yourself, and never tell you afterward whether that specific setup actually worked. Gold Sniper Targets handles both ends of the trade automatically and keeps an honest, visible scoreboard of how the whole process has performed on the exact chart you are looking at.

[image]https://www.tradingview.com/x/GKEqROac/[/image]

How It Works

The foundation is a fast exponential moving average, nine periods by default, crossing a slower one, twenty one periods by default. A cross above is a bullish trigger, a cross below is bearish, and by default the system waits for the candle to close before accepting the cross, so a wick that reverses intrabar cannot create a false signal. On its own, a crossover is not trusted. Every crossover has to pass a confluence filter built from eight separate factors, and at least a minimum number of them, five out of eight by default, must agree with the direction of the cross. Those eight factors are whether price is above or below the session volume weighted average price, whether the fourteen period RSI is above or below its fifty midline, whether the MACD line is above or below its signal line, whether the fast EMA is above or below the slow EMA as a second vote on the crossover itself, whether the ADX trend strength reading is above twenty five with price on the correct side of the fast EMA, whether current volume is above its twenty period average with the candle closing in the trigger's direction, a second RSI calculated on a separate, smaller confirmation timeframe to catch cases where the smaller timeframe is already turning against the bigger picture, and finally a Dollar Index factor. That eighth factor checks whether the Dollar Index is above or below its own moving average, and separately calculates a rolling statistical correlation between Gold and the Dollar Index. Only when that correlation is meaningfully negative does the system trust the classic inverse relationship between the two and award a point; when Gold and the Dollar are temporarily moving together instead of opposite each other, this factor deliberately stays neutral rather than guessing. If this Dollar factor is switched off entirely, the system automatically drops to seven total factors and rescales the minimum requirement to match.

Before any of that scoring even matters, a Gold recognition guard checks the symbol's base currency, its ticker text, its futures root, and an optional custom keyword you can type in yourself, to confirm you are actually looking at a Gold chart; if Gold only mode is on and the symbol is not recognized, the whole dashboard switches to a warning color and every signal is disabled, since this system is tuned specifically for Gold's behavior. A session filter then restricts full signals to the London and New York trading windows, since that is when Gold's real liquidity and cleanest moves happen, while a crossover that occurs outside those hours still gets marked on the chart with a small grey cross so you can see it was seen and rejected rather than simply ignored; the chart also gently tints its background for the London window, the New York window, and a brighter tint where the two overlap. An Average Daily Range exhaustion filter compares how much of the typical daily range, based on the last several fully completed days, today has already used up, and blocks new entries once that percentage is reached, on the idea that a day which has already made its big move is a poor place to chase a fresh entry. A simple spacing rule also requires a minimum number of bars between one trade opening and the next, so the system cannot fire a cluster of overlapping trades in quick succession. Only once a crossover clears the score check, the Gold check, the session check, the ADR check, and the spacing check does it become a real signal, shown as a labeled Buy or Sell directly on the triggering candle, which is itself colored to make it easy to find again later.

Once a signal fires, the trade ladder is built automatically. The stop distance is the Average True Range multiplied by an adjustable factor, so it naturally widens in volatile conditions and tightens in quiet ones. The entry is drawn as a dashed line at the signal candle's close, the stop as a solid line at the calculated distance, and three targets are plotted at exactly one, two, and three times that same risk distance, the classic one, two, three risk to reward ladder. From there the trade is actively managed bar by bar: if price reaches the stop first, the trade closes as a loss; if the first target is reached and the breakeven option is enabled, the stop is moved up to the entry price and the entry line turns into a dotted line to show breakeven protection is now active, so a later pullback to that level closes the trade at breakeven instead of a loss; if price keeps going and reaches the final target, the trade closes as a full win. While a trade is open its lines keep extending forward with new candles; once it closes, its lines freeze exactly where the trade ended. To keep the chart from turning into a wall of old setups, only the most recently completed trade's full ladder stays drawn on the chart by default, while every completed trade, visible or not, still counts toward the rolling performance history described below. There is also a fast EMA retest highlight, which colors a candle a distinct color whenever, while a trade is open, price pulls back to touch the fast EMA without fully crossing the slow EMA, flagging a spot where a trader might consider adding to the position since the trend has not actually been invalidated.
[image]https://www.tradingview.com/x/JMq214Ut/[/image]

How To Read The Chart

A colored Buy or Sell label appears directly below or above the signal candle, and that same candle is painted in the corresponding color so it stands out from the rest of the chart. Small grey cross marks show every crossover that was seen but rejected by one of the filters. The space between the fast and slow EMA is filled green when the fast average is on top and red when it flips beneath, giving an instant read on short term trend direction without needing to read any numbers. Once a trade is live, its entry line is dashed, its stop line is solid, and its three target lines are dashed as well, each carrying a label with the exact price and the distance to it in both currency and points; a target line turns a highlight color and gains a checkmark once it has actually been touched, and the entry line turns dotted the moment breakeven protection switches on.
[image]https://www.tradingview.com/x/iX8THXBk/[/image]

How To Use It For Analysis

Start with the main dashboard's bull and bear scores and overall bias label to get an immediate read on which side currently has the stronger case, well before any crossover even happens. When a crossover does occur, check the confluence checklist panel for the side that just triggered, since it shows exactly which of the eight factors are currently in agreement and which are not, so you understand precisely why a signal did or did not fire. Pay attention to the Gold gates section as well, since a strong score with a failing gate, wrong session or an exhausted daily range, is very different from a strong score with every gate open. Once a trade is live, treat the moving stop and the three targets as your working plan rather than something to second guess candle by candle, and use the fast EMA retest highlight as a secondary cue for scaling into a position that already has a live signal behind it. As always, this indicator encodes a specific, transparent rule set, it does not replace your own judgment about broader context, news events, or personal risk tolerance before you actually place a trade.
[image]https://www.tradingview.com/x/GcewSWyA/[/image]

What The Dashboard Shows

The main panel in the corner of the chart is the command center. It names the instrument and states whether it is recognized as Gold, shows the live bull score and bear score as both a fraction and a percentage, gives an overall market bias label ranging from strong bull to strong bear based on the gap between the two scores, and then lists individual readouts for price versus VWAP, the RSI value, the MACD state and its histogram value, the ADX value with a small arrow for its directional bias, whether the EMA alignment is bullish or bearish, whether volume is currently high or low relative to its average, the confirmation timeframe RSI, the Dollar Index reading together with its trend arrow and the live correlation coefficient showing whether the inverse relationship is currently trusted, the current trading session, how much of the Average Daily Range has been used in both currency and percentage terms, the ATR value converted into both currency and points, the distance the next stop would sit at, the overall confluence score against its required minimum, which entry gates are open or which one is currently blocking things, how many trades are open and in which direction, a summary of the most recent trade and its status, a running tally of the completed trade history showing how many reached at least the first target, how many ran all the way to the final target, how many were stopped out, and how many closed at breakeven, and finally a signal line stating whether a new signal just fired or, if not, what the most recently blocked crossover was and why. A separate panel holds a static, unchanging legend labeled how it works, walking through the entire logic in seven short numbered lines from the crossover trigger through to the spacing rule, with a footer reminding you which symbols count as Gold. Another panel shows a live confluence checklist for whichever side currently has the stronger score, a tick or cross next to every one of the eight factors, followed by a Gold gates section with its own three ticks or crosses for whether this is genuinely a Gold chart, whether the session is currently London or New York, and whether the Average Daily Range is not yet exhausted, closing with a plain language footer line stating whether the system just fired, is fully armed and waiting on the next crossover, or is currently blocked and why. A final small panel is just a three column footer summarizing the strategy in one line, what conditions and timeframes it is best suited for, and which specific Gold instruments it is designed around.

Settings Worth Knowing Before Use

The fast and slow EMA lengths, whether the system waits for candle close, the minimum confluence score required, every Dollar Index setting including its symbol, EMA length, correlation lookback and threshold, the Gold recognition options including the custom keyword, the London and New York session windows and their timezone, the Average Daily Range lookback and exhaustion percentage, the minimum bar spacing between trades, the confirmation timeframe and its RSI length, the ATR length and stop multiplier, whether breakeven management is enabled, how many completed trades stay visually drawn versus simply counted in history, and every color used can all be adjusted from the indicator's settings panel to suit different brokers, Gold instruments, and personal preferences.

Disclaimer

This indicator is a technical analysis tool and does not constitute financial advice. The confluence score, the trade ladder, and the historical tally describe a specific, mechanical rule set being applied to past and current price action, not a guarantee of future profitability. All trading involves risk, and past performance of any signal or strategy does not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: Gold Sniper Targets
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader, purpose built for Gold rather than a generic moving average crossover script. The eight factor confluence scoring engine, including a Gold and US Dollar Index inverse correlation factor that deliberately awards no point when the correlation is not reliably negative, the Gold only recognition guard, the London and New York session restriction with soft fail visual marking, the Average Daily Range exhaustion filter, the minimum trade spacing rule, the full ATR based entry, stop, and three target trade ladder with breakeven management and a rolling trade history tally, the fast EMA retest highlighting, and the multi panel live dashboard were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. EMA crossovers, RSI, MACD, ADX, VWAP, ATR, and risk to reward based target ladders are all well known, generic public domain technical analysis building blocks not owned by any individual author. Only the specific combination, scoring, filtering, trade management, and dashboard logic built around them here is original to this script, and nothing in this script was copied or adapted from another author's published work.

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : Gold Sniper Targets
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader, purpose-built for Gold rather than a generic
//   moving-average crossover script. The 8-factor confluence scoring engine
//   (session VWAP position, RSI midline, MACD state, EMA alignment, ADX with
//   directional price filter, volume participation, a secondary confirmation
//   timeframe RSI, and a Gold/US Dollar Index inverse-correlation factor that
//   deliberately awards no point when the correlation is not reliably
//   negative), the Gold-only recognition guard, the London/New York session
//   restriction with soft-fail visual marking, the Average Daily Range
//   exhaustion filter, the minimum trade-spacing rule, the full ATR-based
//   entry/stop/three-target trade ladder with breakeven management and a
//   rolling trade-history tally, the fast-EMA retest highlighting, and the
//   multi-panel live dashboard were all independently conceived and
//   implemented for this publication. No proprietary source code, private
//   scripts, or copyrighted material belonging to any other author has been
//   copied, mashed-up, or reused in any part of this script.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. EMA crossovers, RSI, MACD, ADX, VWAP, ATR and
//   Fibonacci-style risk-reward ladders are all well-known, generic public-
//   domain technical-analysis building blocks not owned by any individual
//   author. Only the specific combination, scoring, filtering, trade-
//   management, and dashboard logic built around them here is original to
//   this script - nothing in this script was copied or adapted from another
//   author's published work.
// =============================================================================

indicator("Gold Sniper Targets", shorttitle = "Gold Sniper", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 50)

// =============================================================================
// INPUTS
// =============================================================================

grpTrigger = "1. EMA Crossover Trigger"
fastLen = input.int(9, "Fast EMA Length", minval = 1, group = grpTrigger)
slowLen = input.int(21, "Slow EMA Length", minval = 1, group = grpTrigger)
confirmOnClose = input.bool(true, "Wait for Candle Close", group = grpTrigger,
     tooltip = "Only treat a crossover as valid once the candle has fully closed, so an intrabar wick that reverses cannot fake a signal.")

grpScore = "2. Confluence Score"
minScoreOf8 = input.int(5, "Minimum Factors Required (out of 8)", minval = 1, maxval = 8, group = grpScore,
     tooltip = "If the DXY factor is disabled below, total factors drop to 7 and this minimum is automatically rescaled.")

grpDxy = "8. DXY Inverse-Correlation Factor"
useDxyFactor = input.bool(true, "Enable DXY Factor", group = grpDxy)
dxySymbol    = input.symbol("TVC:DXY", "Dollar Index Symbol", group = grpDxy)
dxyEmaLen    = input.int(20, "DXY EMA Length", minval = 1, group = grpDxy)
corrLen      = input.int(20, "Correlation Lookback (bars)", minval = 5, group = grpDxy)
corrThreshold = input.float(-0.3, "Inverse-Correlation Threshold", maxval = 0.0, step = 0.05, group = grpDxy,
     tooltip = "The Gold/DXY correlation must be at or below this value for the inverse link to be considered active. Otherwise the DXY factor awards no point to either side.")

grpGold = "3. Gold-Only Guard"
goldOnlyMode = input.bool(true, "Only Signal on Recognized Gold Symbols", group = grpGold)
customGoldKeyword = input.string("", "Extra Custom Keyword (optional)", group = grpGold,
     tooltip = "If your broker's Gold symbol looks unusual, type a piece of its ticker text here to also count as recognized.")

grpSession = "4. Trading Session Filter"
useSessionFilter = input.bool(true, "Restrict Signals to London/New York", group = grpSession,
     tooltip = "Automatically ignored on Daily and higher timeframes.")
londonSession = input.session("0700-1030", "London Session", group = grpSession)
nySession     = input.session("1300-1600", "New York Session", group = grpSession)
sessionTZ     = input.string("GMT", "Session Timezone", group = grpSession)

grpAdr = "5. ADR Exhaustion Filter"
useAdrFilter = input.bool(true, "Enable ADR Exhaustion Filter", group = grpAdr,
     tooltip = "Automatically ignored on Weekly and Monthly timeframes.")
adrLookbackDays = input.int(14, "ADR Lookback (completed days)", minval = 2, group = grpAdr)
adrExhaustPct   = input.float(100, "Block New Entries After Using (% of ADR)", minval = 10, group = grpAdr)

grpSpacing = "Trade Spacing"
minBarsBetweenTrades = input.int(10, "Minimum Bars Between New Trades", minval = 0, group = grpSpacing)

grpConfirmTf = "7. Secondary Confirmation RSI"
confirmTf = input.timeframe("5", "Confirmation Timeframe", group = grpConfirmTf)
confirmRsiLen = input.int(14, "Confirmation RSI Length", minval = 1, group = grpConfirmTf)

grpRisk = "6. Trade Ladder (ATR Stop + 3 Targets)"
atrLen = input.int(14, "ATR Length", minval = 1, group = grpRisk)
atrMult = input.float(1.5, "Stop Distance (x ATR)", minval = 0.1, step = 0.1, group = grpRisk)
useBreakeven = input.bool(true, "Move Stop to Breakeven After TP1", group = grpRisk)
tradeLabelOffset = input.int(12, "Open Trade Line/Label Forward Offset (bars)", minval = 1, group = grpRisk)
maxVisibleClosed = input.int(1, "Max Visible Completed Trade Ladders", minval = 0, maxval = 20, group = grpRisk,
     tooltip = "How many of the most recently CLOSED trades keep their entry/SL/TP lines drawn on the chart. Open trades are always drawn regardless of this setting. Lower this (e.g. 1) so the chart isn't cluttered with every historical trade - the History row in the dashboard still counts every completed trade up to Max Completed Trades Kept, whether or not it is still drawn.")
maxHistory = input.int(50, "Max Completed Trades Kept in History Tally", minval = 5, maxval = 200, group = grpRisk)

grpColors = "Colors"
bullColor = input.color(color.new(color.lime, 0), "Bullish / Buy Color", group = grpColors)
bearColor = input.color(color.new(color.red, 0),  "Bearish / Sell Color", group = grpColors)
hitColor  = input.color(color.new(color.yellow, 0), "Target Hit Color", group = grpColors)
retestColor = input.color(color.new(color.orange, 0), "EMA Retest Bar Color", group = grpColors)

// =============================================================================
// 3. GOLD-ONLY RECOGNITION GUARD
// =============================================================================

baseUp   = str.upper(syminfo.basecurrency)
tickerUp = str.upper(syminfo.ticker)
rootUp   = str.upper(syminfo.root)
keywordUp = str.upper(customGoldKeyword)

isGoldSymbol = str.contains(baseUp, "XAU") or str.contains(tickerUp, "XAU") or str.contains(tickerUp, "GOLD") or
     rootUp == "GC" or rootUp == "MGC" or (customGoldKeyword != "" and str.contains(tickerUp, keywordUp))

goldOk = not goldOnlyMode or isGoldSymbol

// =============================================================================
// CORE INDICATOR CALCULATIONS
// =============================================================================

fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
rsiMain = ta.rsi(close, 14)
[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)
[diPlus, diMinus, adxValue] = ta.dmi(14, 14)
volAvg = ta.sma(volume, 20)
vwapValue = ta.vwap(hlc3)
atrValue = ta.atr(atrLen)

confirmRsi = request.security(syminfo.tickerid, confirmTf, ta.rsi(close, confirmRsiLen), lookahead = barmerge.lookahead_off)

dxyClose = request.security(dxySymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
dxyEma   = request.security(dxySymbol, timeframe.period, ta.ema(close, dxyEmaLen), lookahead = barmerge.lookahead_off)
correlationValue = ta.correlation(close, dxyClose, corrLen)
inverseActive = correlationValue <= corrThreshold
dxyWeak   = dxyClose < dxyEma
dxyStrong = dxyClose > dxyEma

// =============================================================================
// EMA CROSSOVER TRIGGER
// =============================================================================

triggerReady = confirmOnClose ? barstate.isconfirmed : true
crossUp = triggerReady and ta.crossover(fastEMA, slowEMA)
crossDn = triggerReady and ta.crossunder(fastEMA, slowEMA)

// =============================================================================
// 2 & 8. THE 8-FACTOR CONFLUENCE ENGINE
// =============================================================================

f1Bull = close > vwapValue
f1Bear = close < vwapValue
f2Bull = rsiMain > 50
f2Bear = rsiMain < 50
f3Bull = macdLine > macdSignal
f3Bear = macdLine < macdSignal
f4Bull = fastEMA > slowEMA
f4Bear = fastEMA < slowEMA
f5Bull = adxValue > 25 and close > fastEMA
f5Bear = adxValue > 25 and close < fastEMA
f6Bull = volume > volAvg and close > open
f6Bear = volume > volAvg and close < open
f7Bull = confirmRsi > 50
f7Bear = confirmRsi < 50
f8Bull = useDxyFactor and inverseActive and dxyWeak
f8Bear = useDxyFactor and inverseActive and dxyStrong

bullScore = (f1Bull ? 1 : 0) + (f2Bull ? 1 : 0) + (f3Bull ? 1 : 0) + (f4Bull ? 1 : 0) + (f5Bull ? 1 : 0) +
     (f6Bull ? 1 : 0) + (f7Bull ? 1 : 0) + (useDxyFactor ? (f8Bull ? 1 : 0) : 0)
bearScore = (f1Bear ? 1 : 0) + (f2Bear ? 1 : 0) + (f3Bear ? 1 : 0) + (f4Bear ? 1 : 0) + (f5Bear ? 1 : 0) +
     (f6Bear ? 1 : 0) + (f7Bear ? 1 : 0) + (useDxyFactor ? (f8Bear ? 1 : 0) : 0)

totalFactors = useDxyFactor ? 8 : 7
effectiveMin = math.round(minScoreOf8 * totalFactors / 8.0)

bullQualifies = bullScore >= effectiveMin
bearQualifies = bearScore >= effectiveMin

gapScore = bullScore - bearScore
biasLabel = gapScore >= 4 ? "STRONG BULL" : gapScore >= 2 ? "BULL" : gapScore >= 1 ? "MILD BULL" :
     gapScore <= -4 ? "STRONG BEAR" : gapScore <= -2 ? "BEAR" : gapScore <= -1 ? "MILD BEAR" : "NEUTRAL"
biasColor = gapScore > 0 ? bullColor : gapScore < 0 ? bearColor : color.gray

// =============================================================================
// 4. SESSION FILTER
// =============================================================================

londonWin = not na(time(timeframe.period, londonSession, sessionTZ))
nyWin     = not na(time(timeframe.period, nySession, sessionTZ))
sessionActive = londonWin or nyWin
sessionFilterApplies = useSessionFilter and timeframe.isintraday
sessionOk = not sessionFilterApplies or sessionActive
sessionName = londonWin and nyWin ? "OVERLAP" : londonWin ? "LONDON" : nyWin ? "NEW YORK" : "OFF-SESSION"

bgcolor(timeframe.isintraday and londonWin and not nyWin ? color.new(color.blue, 92) : na, title = "London Session")
bgcolor(timeframe.isintraday and nyWin and not londonWin ? color.new(color.purple, 92) : na, title = "New York Session")
bgcolor(timeframe.isintraday and londonWin and nyWin ? color.new(color.yellow, 85) : na, title = "Session Overlap")

// =============================================================================
// 5. ADR EXHAUSTION FILTER
// =============================================================================

adrValue = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLookbackDays), lookahead = barmerge.lookahead_off)[1]
todayHigh = request.security(syminfo.tickerid, "D", high, lookahead = barmerge.lookahead_off)
todayLow  = request.security(syminfo.tickerid, "D", low, lookahead = barmerge.lookahead_off)
todayRangeSoFar = todayHigh - todayLow
adrUsedPct = adrValue > 0 ? todayRangeSoFar / adrValue * 100.0 : 0.0
isDailyPlus = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
adrFilterApplies = useAdrFilter and not isDailyPlus
adrExhausted = adrUsedPct >= adrExhaustPct
adrOk = not adrFilterApplies or not adrExhausted

// =============================================================================
// TRADE SPACING RULE
// =============================================================================

var int lastTradeOpenBar = na
spacingOk = na(lastTradeOpenBar) or (bar_index - lastTradeOpenBar) >= minBarsBetweenTrades

// =============================================================================
// FINAL SIGNAL DECISION
// =============================================================================

canSignalNow = goldOk and sessionOk and adrOk and spacingOk
rawBuySignal  = crossUp and bullQualifies
rawSellSignal = crossDn and bearQualifies
buySignal  = rawBuySignal and canSignalNow
sellSignal = rawSellSignal and canSignalNow
anyCross = crossUp or crossDn
blockedCross = anyCross and not (buySignal or sellSignal)

var string lastBlockReason = "NONE"
var string lastBlockDir = "NONE"
if blockedCross
    reasonTxt = not goldOk ? "NOT GOLD SYMBOL" : not sessionOk ? "OFF-SESSION" : not adrOk ? "ADR EXHAUSTED" :
         not spacingOk ? "TOO SOON (SPACING)" : crossUp ? "SCORE TOO LOW (BULL)" : "SCORE TOO LOW (BEAR)"
    lastBlockReason := reasonTxt
    lastBlockDir := crossUp ? "LONG" : "SHORT"

// =============================================================================
// SIGNAL / TRIGGER VISUALS
// =============================================================================

barcolor(buySignal ? bullColor : sellSignal ? bearColor : na, title = "Signal Candle")
plotshape(blockedCross, title = "Blocked Crossover", style = shape.xcross,
     location = location.abovebar, color = color.gray, size = size.tiny)

p1 = plot(fastEMA, "Fast EMA", color = color.new(color.aqua, 30))
p2 = plot(slowEMA, "Slow EMA", color = color.new(color.orange, 30))
fill(p1, p2, color = fastEMA > slowEMA ? color.new(color.green, 75) : color.new(color.red, 75), title = "EMA Ribbon")

plotshape(buySignal, title = "BUY", style = shape.labelup, location = location.belowbar, color = bullColor,
     text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSignal, title = "SELL", style = shape.labeldown, location = location.abovebar, color = bearColor,
     text = "SELL", textcolor = color.white, size = size.small)

// =============================================================================
// RETEST HIGHLIGHT
// =============================================================================

var int openTradeCount = 0
touchFast = low <= fastEMA and high >= fastEMA
notCrossedSlow = fastEMA > slowEMA ? low > slowEMA : high < slowEMA
retestBar = openTradeCount > 0 and touchFast and notCrossedSlow and not buySignal and not sellSignal
barcolor(retestBar ? retestColor : na, title = "EMA Retest")

// =============================================================================
// 6. TRADE LADDER - OPEN NEW TRADES
// =============================================================================

var int[]    tDir       = array.new_int()
var float[]  tEntry     = array.new_float()
var int[]    tEntryBar  = array.new_int()
var float[]  tSl        = array.new_float()
var float[]  tTp1       = array.new_float()
var float[]  tTp2       = array.new_float()
var float[]  tTp3       = array.new_float()
var bool[]   tTp1Hit    = array.new_bool()
var bool[]   tTp2Hit    = array.new_bool()
var bool[]   tTp3Hit    = array.new_bool()
var bool[]   tBE        = array.new_bool()
var bool[]   tClosed    = array.new_bool()
var bool[]   tHidden    = array.new_bool()
var int[]    tCloseBar  = array.new_int()
var string[] tOutcome   = array.new_string()
var line[]   tEntryLine = array.new_line()
var line[]   tSlLine    = array.new_line()
var line[]   tTp1Line   = array.new_line()
var line[]   tTp2Line   = array.new_line()
var line[]   tTp3Line   = array.new_line()
var label[]  tEntryLabel = array.new_label()
var label[]  tSlLabel    = array.new_label()
var label[]  tTp1Label   = array.new_label()
var label[]  tTp2Label   = array.new_label()
var label[]  tTp3Label   = array.new_label()

fmtDist(priceDist) =>
    pts = priceDist / syminfo.mintick / 10
    "$" + str.tostring(priceDist, format.mintick) + " / " + str.tostring(pts, "#.#") + " pts"

if buySignal or sellSignal
    dir = buySignal ? 1 : -1
    entryP = close
    riskDist = atrValue * atrMult
    slP  = dir == 1 ? entryP - riskDist : entryP + riskDist
    tp1P = dir == 1 ? entryP + riskDist : entryP - riskDist
    tp2P = dir == 1 ? entryP + riskDist * 2 : entryP - riskDist * 2
    tp3P = dir == 1 ? entryP + riskDist * 3 : entryP - riskDist * 3
    sideColor = dir == 1 ? bullColor : bearColor
    xEnd = bar_index + tradeLabelOffset

    eLine = line.new(bar_index, entryP, xEnd, entryP, color = sideColor, style = line.style_dashed, width = 1)
    sLine = line.new(bar_index, slP, xEnd, slP, color = color.new(color.red, 0), style = line.style_solid, width = 1)
    t1Line = line.new(bar_index, tp1P, xEnd, tp1P, color = color.new(color.teal, 0), style = line.style_dashed, width = 1)
    t2Line = line.new(bar_index, tp2P, xEnd, tp2P, color = color.new(color.teal, 0), style = line.style_dashed, width = 1)
    t3Line = line.new(bar_index, tp3P, xEnd, tp3P, color = color.new(color.teal, 0), style = line.style_dashed, width = 1)

    eLabel = label.new(xEnd, entryP, "ENTRY: " + str.tostring(entryP, format.mintick), style = label.style_label_left,
         color = color.new(color.black, 100), textcolor = sideColor, size = size.small)
    sLabel = label.new(xEnd, slP, "SL: " + str.tostring(slP, format.mintick) + " (" + fmtDist(riskDist) + ")",
         style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.red, size = size.small)
    t1Label = label.new(xEnd, tp1P, "TP1: " + str.tostring(tp1P, format.mintick) + " (" + fmtDist(riskDist) + ")",
         style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.teal, size = size.small)
    t2Label = label.new(xEnd, tp2P, "TP2: " + str.tostring(tp2P, format.mintick) + " (" + fmtDist(riskDist * 2) + ")",
         style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.teal, size = size.small)
    t3Label = label.new(xEnd, tp3P, "TP3: " + str.tostring(tp3P, format.mintick) + " (" + fmtDist(riskDist * 3) + ")",
         style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.teal, size = size.small)

    array.push(tDir, dir)
    array.push(tEntry, entryP)
    array.push(tEntryBar, bar_index)
    array.push(tSl, slP)
    array.push(tTp1, tp1P)
    array.push(tTp2, tp2P)
    array.push(tTp3, tp3P)
    array.push(tTp1Hit, false)
    array.push(tTp2Hit, false)
    array.push(tTp3Hit, false)
    array.push(tBE, false)
    array.push(tClosed, false)
    array.push(tHidden, false)
    array.push(tCloseBar, -1)
    array.push(tOutcome, "")
    array.push(tEntryLine, eLine)
    array.push(tSlLine, sLine)
    array.push(tTp1Line, t1Line)
    array.push(tTp2Line, t2Line)
    array.push(tTp3Line, t3Line)
    array.push(tEntryLabel, eLabel)
    array.push(tSlLabel, sLabel)
    array.push(tTp1Label, t1Label)
    array.push(tTp2Label, t2Label)
    array.push(tTp3Label, t3Label)

    lastTradeOpenBar := bar_index

// =============================================================================
// TRADE LADDER - MANAGE OPEN TRADES EVERY BAR
// =============================================================================

openCountNow = 0
openDirNow = 0

if array.size(tDir) > 0
    for i = 0 to array.size(tDir) - 1
        if not array.get(tClosed, i)
            dir  = array.get(tDir, i)
            entryP = array.get(tEntry, i)
            slP  = array.get(tSl, i)
            tp1P = array.get(tTp1, i)
            tp2P = array.get(tTp2, i)
            tp3P = array.get(tTp3, i)
            be   = array.get(tBE, i)
            tp1h = array.get(tTp1Hit, i)
            tp2h = array.get(tTp2Hit, i)
            tp3h = array.get(tTp3Hit, i)
            effectiveStop = be ? entryP : slP
            closedNow = false
            outcomeNow = ""

            if dir == 1
                if low <= effectiveStop
                    closedNow := true
                    outcomeNow := be ? "BE" : "SL"
                else
                    if not tp1h and high >= tp1P
                        tp1h := true
                        array.set(tTp1Hit, i, true)
                        line.set_color(array.get(tTp1Line, i), hitColor)
                        label.set_textcolor(array.get(tTp1Label, i), hitColor)
                        if useBreakeven
                            be := true
                            array.set(tBE, i, true)
                            line.set_style(array.get(tEntryLine, i), line.style_dotted)
                    if tp1h and not tp2h and high >= tp2P
                        tp2h := true
                        array.set(tTp2Hit, i, true)
                        line.set_color(array.get(tTp2Line, i), hitColor)
                        label.set_textcolor(array.get(tTp2Label, i), hitColor)
                    if tp2h and not tp3h and high >= tp3P
                        tp3h := true
                        array.set(tTp3Hit, i, true)
                        line.set_color(array.get(tTp3Line, i), hitColor)
                        label.set_textcolor(array.get(tTp3Label, i), hitColor)
                        closedNow := true
                        outcomeNow := "TP3_FULL"
            else
                if high >= effectiveStop
                    closedNow := true
                    outcomeNow := be ? "BE" : "SL"
                else
                    if not tp1h and low <= tp1P
                        tp1h := true
                        array.set(tTp1Hit, i, true)
                        line.set_color(array.get(tTp1Line, i), hitColor)
                        label.set_textcolor(array.get(tTp1Label, i), hitColor)
                        if useBreakeven
                            be := true
                            array.set(tBE, i, true)
                            line.set_style(array.get(tEntryLine, i), line.style_dotted)
                    if tp1h and not tp2h and low <= tp2P
                        tp2h := true
                        array.set(tTp2Hit, i, true)
                        line.set_color(array.get(tTp2Line, i), hitColor)
                        label.set_textcolor(array.get(tTp2Label, i), hitColor)
                    if tp2h and not tp3h and low <= tp3P
                        tp3h := true
                        array.set(tTp3Hit, i, true)
                        line.set_color(array.get(tTp3Line, i), hitColor)
                        label.set_textcolor(array.get(tTp3Label, i), hitColor)
                        closedNow := true
                        outcomeNow := "TP3_FULL"

            if closedNow
                array.set(tClosed, i, true)
                array.set(tCloseBar, i, bar_index)
                array.set(tOutcome, i, outcomeNow)
                line.set_x2(array.get(tEntryLine, i), bar_index)
                line.set_x2(array.get(tSlLine, i), bar_index)
                line.set_x2(array.get(tTp1Line, i), bar_index)
                line.set_x2(array.get(tTp2Line, i), bar_index)
                line.set_x2(array.get(tTp3Line, i), bar_index)
                slHitColor = outcomeNow == "SL" ? color.new(color.red, 0) : color.new(color.gray, 0)
                if outcomeNow == "SL" or outcomeNow == "BE"
                    label.set_text(array.get(tSlLabel, i), label.get_text(array.get(tSlLabel, i)) + "  ✕")
            else
                xEnd = bar_index + tradeLabelOffset
                line.set_x2(array.get(tEntryLine, i), xEnd)
                line.set_x2(array.get(tSlLine, i), xEnd)
                line.set_x2(array.get(tTp1Line, i), xEnd)
                line.set_x2(array.get(tTp2Line, i), xEnd)
                line.set_x2(array.get(tTp3Line, i), xEnd)
                label.set_x(array.get(tEntryLabel, i), xEnd)
                label.set_x(array.get(tSlLabel, i), xEnd)
                label.set_x(array.get(tTp1Label, i), xEnd)
                label.set_x(array.get(tTp2Label, i), xEnd)
                label.set_x(array.get(tTp3Label, i), xEnd)
                openCountNow += 1
                openDirNow := dir

openTradeCount := openCountNow

// =============================================================================
// DECLUTTER - only the most recently CLOSED trades keep their ladder drawn;
// older completed trades still count toward the history tally below, they
// just stop cluttering the chart visually
// =============================================================================

if array.size(tClosed) > 0
    for i = 0 to array.size(tClosed) - 1
        if array.get(tClosed, i) and not array.get(tHidden, i)
            myCloseBar = array.get(tCloseBar, i)
            rank = 0
            for j = 0 to array.size(tClosed) - 1
                if array.get(tClosed, j) and array.get(tCloseBar, j) > myCloseBar
                    rank += 1
            if rank >= maxVisibleClosed
                elnH = array.get(tEntryLine, i)
                slnH = array.get(tSlLine, i)
                t1H  = array.get(tTp1Line, i)
                t2H  = array.get(tTp2Line, i)
                t3H  = array.get(tTp3Line, i)
                if not na(elnH)
                    line.delete(elnH)
                    array.set(tEntryLine, i, na)
                if not na(slnH)
                    line.delete(slnH)
                    array.set(tSlLine, i, na)
                if not na(t1H)
                    line.delete(t1H)
                    array.set(tTp1Line, i, na)
                if not na(t2H)
                    line.delete(t2H)
                    array.set(tTp2Line, i, na)
                if not na(t3H)
                    line.delete(t3H)
                    array.set(tTp3Line, i, na)
                elbH = array.get(tEntryLabel, i)
                slbH = array.get(tSlLabel, i)
                t1bH = array.get(tTp1Label, i)
                t2bH = array.get(tTp2Label, i)
                t3bH = array.get(tTp3Label, i)
                if not na(elbH)
                    label.delete(elbH)
                    array.set(tEntryLabel, i, na)
                if not na(slbH)
                    label.delete(slbH)
                    array.set(tSlLabel, i, na)
                if not na(t1bH)
                    label.delete(t1bH)
                    array.set(tTp1Label, i, na)
                if not na(t2bH)
                    label.delete(t2bH)
                    array.set(tTp2Label, i, na)
                if not na(t3bH)
                    label.delete(t3bH)
                    array.set(tTp3Label, i, na)
                array.set(tHidden, i, true)

// ---- prune oldest completed trade once beyond the history limit ----
closedTotal = 0
if array.size(tClosed) > 0
    for i = 0 to array.size(tClosed) - 1
        if array.get(tClosed, i)
            closedTotal += 1

if closedTotal > maxHistory
    oldestIdx = -1
    oldestBar = 999999999
    for i = 0 to array.size(tClosed) - 1
        if array.get(tClosed, i) and array.get(tCloseBar, i) < oldestBar
            oldestBar := array.get(tCloseBar, i)
            oldestIdx := i
    if oldestIdx >= 0
        elnP = array.get(tEntryLine, oldestIdx)
        slnP = array.get(tSlLine, oldestIdx)
        t1P  = array.get(tTp1Line, oldestIdx)
        t2P  = array.get(tTp2Line, oldestIdx)
        t3P  = array.get(tTp3Line, oldestIdx)
        elbP = array.get(tEntryLabel, oldestIdx)
        slbP = array.get(tSlLabel, oldestIdx)
        t1bP = array.get(tTp1Label, oldestIdx)
        t2bP = array.get(tTp2Label, oldestIdx)
        t3bP = array.get(tTp3Label, oldestIdx)
        if not na(elnP)
            line.delete(elnP)
        if not na(slnP)
            line.delete(slnP)
        if not na(t1P)
            line.delete(t1P)
        if not na(t2P)
            line.delete(t2P)
        if not na(t3P)
            line.delete(t3P)
        if not na(elbP)
            label.delete(elbP)
        if not na(slbP)
            label.delete(slbP)
        if not na(t1bP)
            label.delete(t1bP)
        if not na(t2bP)
            label.delete(t2bP)
        if not na(t3bP)
            label.delete(t3bP)
        array.remove(tDir, oldestIdx)
        array.remove(tEntry, oldestIdx)
        array.remove(tEntryBar, oldestIdx)
        array.remove(tSl, oldestIdx)
        array.remove(tTp1, oldestIdx)
        array.remove(tTp2, oldestIdx)
        array.remove(tTp3, oldestIdx)
        array.remove(tTp1Hit, oldestIdx)
        array.remove(tTp2Hit, oldestIdx)
        array.remove(tTp3Hit, oldestIdx)
        array.remove(tBE, oldestIdx)
        array.remove(tClosed, oldestIdx)
        array.remove(tHidden, oldestIdx)
        array.remove(tCloseBar, oldestIdx)
        array.remove(tOutcome, oldestIdx)
        array.remove(tEntryLine, oldestIdx)
        array.remove(tSlLine, oldestIdx)
        array.remove(tTp1Line, oldestIdx)
        array.remove(tTp2Line, oldestIdx)
        array.remove(tTp3Line, oldestIdx)
        array.remove(tEntryLabel, oldestIdx)
        array.remove(tSlLabel, oldestIdx)
        array.remove(tTp1Label, oldestIdx)
        array.remove(tTp2Label, oldestIdx)
        array.remove(tTp3Label, oldestIdx)

// =============================================================================
// LIVE DASHBOARDS (rendered on the last bar only)
// =============================================================================

tick(cond) => cond ? "✓" : "✕"
tickColor(cond) => cond ? bullColor : bearColor

var table mainDash = table.new(position.top_right, 2, 24, bgcolor = color.new(color.black, 10),
     border_color = color.new(color.gray, 40), border_width = 1)
var table howItWorks = table.new(position.top_left, 1, 8, bgcolor = color.new(color.black, 10),
     border_color = color.new(color.gray, 40), border_width = 1)
var table confluenceTbl = table.new(position.bottom_left, 2, 13, bgcolor = color.new(color.black, 10),
     border_color = color.new(color.gray, 40), border_width = 1)
var table footerTbl = table.new(position.bottom_center, 3, 2, bgcolor = color.new(color.black, 10),
     border_color = color.new(color.gray, 40), border_width = 1)

if barstate.islast
    // ---- tally closed-trade history ----
    tp1Count = 0
    fullCount = 0
    slCount = 0
    beCount = 0
    if array.size(tClosed) > 0
        for i = 0 to array.size(tClosed) - 1
            if array.get(tClosed, i)
                if array.get(tTp1Hit, i)
                    tp1Count += 1
                oc = array.get(tOutcome, i)
                if oc == "TP3_FULL"
                    fullCount += 1
                if oc == "SL"
                    slCount += 1
                if oc == "BE"
                    beCount += 1
    closedShown = math.min(closedTotal, maxHistory)

    latestDirTxt = "NONE"
    latestStatusTxt = "NONE"
    if array.size(tDir) > 0
        lastIdx = array.size(tDir) - 1
        latestDirTxt := array.get(tDir, lastIdx) == 1 ? "LONG" : "SHORT"
        lc = array.get(tClosed, lastIdx)
        latestStatusTxt := not lc ? "OPEN" : "CLOSED " + array.get(tOutcome, lastIdx)

    goldStatusTxt = isGoldSymbol ? "RECOGNIZED" : "NOT RECOGNIZED"
    goldStatusColor = isGoldSymbol ? bullColor : bearColor
    dashBg = (goldOnlyMode and not isGoldSymbol) ? color.new(color.red, 60) : color.new(color.black, 10)
    table.set_bgcolor(mainDash, dashBg)

    signalLineTxt = buySignal ? "NEW BUY SIGNAL FIRED" : sellSignal ? "NEW SELL SIGNAL FIRED" :
         "LAST BLOCK: " + lastBlockDir + " - " + lastBlockReason

    entryGatesTxt = canSignalNow ? "ALL OPEN" : (not goldOk ? "GOLD BLOCK" : not sessionOk ? "SESSION BLOCK" :
         not adrOk ? "ADR BLOCK" : "SPACING BLOCK")

    r = 0
    table.cell(mainDash, 0, r, "GOLD SNIPER", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(mainDash, 1, r, syminfo.ticker, text_color = color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Instrument", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, goldStatusTxt, text_color = goldStatusColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Bull Score", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(bullScore) + "/" + str.tostring(totalFactors) + "  (" +
         str.tostring(math.round(bullScore / totalFactors * 100)) + "%)", text_color = bullColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Bear Score", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(bearScore) + "/" + str.tostring(totalFactors) + "  (" +
         str.tostring(math.round(bearScore / totalFactors * 100)) + "%)", text_color = bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Market Bias", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, biasLabel, text_color = biasColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Price / VWAP", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, close > vwapValue ? "ABOVE" : "BELOW", text_color = close > vwapValue ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "RSI (14)", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(rsiMain, "#.#"), text_color = rsiMain > 50 ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "MACD", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, (macdLine > macdSignal ? "BULL " : "BEAR ") + str.tostring(macdHist, "#.##"),
         text_color = macdLine > macdSignal ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "ADX (14)", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(adxValue, "#.#") + (diPlus > diMinus ? " ▲" : " ▼"),
         text_color = adxValue > 25 ? (diPlus > diMinus ? bullColor : bearColor) : color.gray, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "EMA " + str.tostring(fastLen) + "/" + str.tostring(slowLen), text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, fastEMA > slowEMA ? "BULL" : "BEAR", text_color = fastEMA > slowEMA ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Volume", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, volume > volAvg ? "HIGH" : "LOW", text_color = volume > volAvg ? bullColor : color.gray, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, confirmTf + " RSI", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(confirmRsi, "#.#"), text_color = confirmRsi > 50 ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "DXY (inverse)", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, (dxyWeak ? "▼ " : "▲ ") + str.tostring(dxyClose, "#.##") + "  r " + str.tostring(correlationValue, "#.##") +
         (inverseActive ? " ✓" : " ✕"), text_color = inverseActive ? (dxyWeak ? bullColor : bearColor) : color.gray, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Session", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, sessionName, text_color = sessionActive ? color.yellow : color.gray, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "ADR (" + str.tostring(adrLookbackDays) + "d)", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, "$" + str.tostring(adrValue, format.mintick) + " - used " + str.tostring(math.round(adrUsedPct)) + "%",
         text_color = adrExhausted ? bearColor : color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "ATR (" + str.tostring(atrLen) + ")", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, fmtDist(atrValue), text_color = color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Next Stop Distance", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, fmtDist(atrValue * atrMult), text_color = color.orange, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Confluence", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(math.max(bullScore, bearScore)) + "/" + str.tostring(totalFactors) +
         " (min " + str.tostring(effectiveMin) + ")", text_color = color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Entry Gates", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, entryGatesTxt, text_color = canSignalNow ? bullColor : bearColor, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Open Trades", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(openTradeCount) + (openTradeCount > 0 ? (openDirNow == 1 ? " LONG" : " SHORT") : ""),
         text_color = openTradeCount > 0 ? (openDirNow == 1 ? bullColor : bearColor) : color.gray, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Latest Trade", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, latestDirTxt + " - " + latestStatusTxt, text_color = color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "History (last " + str.tostring(maxHistory) + ")", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, str.tostring(closedShown) + " closed - TP1 " + str.tostring(tp1Count) + " - full " +
         str.tostring(fullCount) + " - SL " + str.tostring(slCount) + " - BE " + str.tostring(beCount), text_color = color.white, text_size = size.small)
    r += 1
    table.cell(mainDash, 0, r, "Signal", text_color = color.gray, text_size = size.small)
    table.cell(mainDash, 1, r, signalLineTxt, text_color = (buySignal ? bullColor : sellSignal ? bearColor : color.gray), text_size = size.small)

    // ---- how it works legend ----
    table.cell(howItWorks, 0, 0, "HOW IT WORKS", text_color = color.yellow, text_size = size.small)
    table.cell(howItWorks, 0, 1, "1. Trigger: fast/slow EMA cross on bar close", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 2, "2. Score: " + str.tostring(effectiveMin) + "/" + str.tostring(totalFactors) + " factors must reach the minimum", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 3, "3. DXY inverse-correlation confirms the gold side", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 4, "4. Trade window: London / New York only", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 5, "5. ADR exhausted = no late entries", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 6, "6. ATR stop, 3 targets, BE at TP1, each trade runs to SL / TP", text_color = color.white, text_size = size.small)
    table.cell(howItWorks, 0, 7, "7. Entries stay at least " + str.tostring(minBarsBetweenTrades) + " bars apart. Gold-only: XAUUSD, GOLD, GC", text_color = color.gray, text_size = size.small)

    // ---- confluence checklist (whichever side currently scores stronger) ----
    showBull = bullScore >= bearScore

    table.cell(confluenceTbl, 0, 0, (showBull ? "BUY" : "SELL") + " CONFLUENCE  " + str.tostring(showBull ? bullScore : bearScore) + "/" + str.tostring(totalFactors),
         text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(confluenceTbl, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(confluenceTbl, 0, 1, "1 Price vs VWAP", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 1, tick(showBull ? f1Bull : f1Bear), text_color = tickColor(showBull ? f1Bull : f1Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 2, "2 RSI vs 50", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 2, tick(showBull ? f2Bull : f2Bear), text_color = tickColor(showBull ? f2Bull : f2Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 3, "3 MACD vs signal", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 3, tick(showBull ? f3Bull : f3Bear), text_color = tickColor(showBull ? f3Bull : f3Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 4, "4 Fast EMA vs slow", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 4, tick(showBull ? f4Bull : f4Bear), text_color = tickColor(showBull ? f4Bull : f4Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 5, "5 ADX > 25 on side", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 5, tick(showBull ? f5Bull : f5Bear), text_color = tickColor(showBull ? f5Bull : f5Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 6, "6 Volume push, matching candle", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 6, tick(showBull ? f6Bull : f6Bear), text_color = tickColor(showBull ? f6Bull : f6Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 7, "7 " + confirmTf + " RSI vs 50", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 7, tick(showBull ? f7Bull : f7Bear), text_color = tickColor(showBull ? f7Bull : f7Bear), text_size = size.small)
    table.cell(confluenceTbl, 0, 8, "8 DXY inverse link", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 8, useDxyFactor ? tick(showBull ? f8Bull : f8Bear) : "n/a", text_color = useDxyFactor ? tickColor(showBull ? f8Bull : f8Bear) : color.gray, text_size = size.small)

    table.cell(confluenceTbl, 0, 9, "GOLD GATES", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(confluenceTbl, 1, 9, "", bgcolor = color.new(color.black, 0))
    table.cell(confluenceTbl, 0, 10, "Gold chart", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 10, tick(goldOk), text_color = tickColor(goldOk), text_size = size.small)
    table.cell(confluenceTbl, 0, 11, "London / New York session", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 11, tick(sessionOk), text_color = tickColor(sessionOk), text_size = size.small)
    table.cell(confluenceTbl, 0, 12, "ADR not exhausted", text_color = color.white, text_size = size.small)
    table.cell(confluenceTbl, 1, 12, tick(adrOk), text_color = tickColor(adrOk), text_size = size.small)

    // ---- static strategy footer ----
    table.cell(footerTbl, 0, 0, "STRATEGY", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(footerTbl, 1, 0, "BEST FOR", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(footerTbl, 2, 0, "WORKS ON", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(footerTbl, 0, 1, "8-Factor Gold Confluence", text_color = color.white, text_size = size.small)
    table.cell(footerTbl, 1, 1, "XAUUSD 5m-1H intraday", text_color = color.white, text_size = size.small)
    table.cell(footerTbl, 2, 1, "Spot XAU - GC / MGC futures", text_color = color.white, text_size = size.small)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(buySignal, title = "Gold Sniper BUY", message = "Gold Sniper Targets: BUY signal fired.")
alertcondition(sellSignal, title = "Gold Sniper SELL", message = "Gold Sniper Targets: SELL signal fired.")
````
