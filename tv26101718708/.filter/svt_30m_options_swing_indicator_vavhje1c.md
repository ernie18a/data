# SVT 30M Options Swing Indicator

- url: https://www.tradingview.com/script/vAVhJe1C-SVT-30M-Options-Swing-Indicator/
- type: strategy
- pine_id: PUB;fa94f08c061e48d1acc58f5f729540ef
- version: 1.0

## Description

SVT 30M Options Swing Indicator Description

This indicator is designed as a swing trading assistant for SPY / QQQ options using the 30-minute chart for entries and exits, while using the Daily and 2H timeframes to confirm the larger trend direction.

The main idea is:

Trend is your friend.
Daily + 2H define direction.
30M gives the timing.
Lorentzian-style score confirms trade quality.

This indicator is not designed for scalping. It is designed to help identify higher-quality CALL and PUT opportunities that can potentially be held for a swing move, while avoiding low-quality trades during chop, consolidation, or weak momentum.

Strategy Logic

The strategy combines several layers of confirmation:

1. Higher Timeframe Trend

The indicator first checks the Daily and 2H charts.

The Daily timeframe is used to define the larger market bias:

Daily Bullish = price above Daily EMA 50 and RSI above 50
Daily Bearish = price below Daily EMA 50 and RSI below 50

The 2H timeframe is used to confirm the active swing direction:

2H Bullish = price above EMA 20, RSI above 50, and MACD above signal
2H Bearish = price below EMA 20, RSI below 50, and MACD below signal

This helps avoid trading against the bigger trend.

2. 30-Minute Entry Timing

The 30-minute chart is used for actual entry timing.

A CALL setup looks for:

Daily / 2H bullish direction
Recent 30M pullback
30M MACD bullish cross
RSI recovery
Price reclaiming EMA 20
Bullish Lorentzian-style score
No chop / consolidation warning

A PUT setup looks for:

Daily / 2H bearish direction
Recent 30M pullback or rejection
30M MACD bearish cross
RSI weakness
Price rejecting EMA 20
Bearish Lorentzian-style score
No chop / consolidation warning
3. Lorentzian-Style Score

The indicator uses a Lorentzian-inspired quality score to confirm whether the market condition supports the trade.

The score uses:

RSI 14
RSI 9
WaveTrend
CCI
ADX
MACD momentum
EMA trend structure

For CALLs, the score checks if momentum and trend conditions are bullish.

For PUTs, the score checks if momentum and trend conditions are bearish.

This helps filter out weaker signals.

4. Chop / Consolidation Filter

The indicator avoids trades when the market is sideways.

It checks:

Low ADX
EMA 20 and EMA 50 compression
Tight price range
Price moving inside a range

When the market is choppy, the table may show:

Chop: No Trade

That means the signal should be avoided because options can lose value quickly in sideways action due to theta decay.

5. Exit Logic

The strategy does not exit on every small pullback. It looks for stronger confirmation.

CALL exits can happen when:

30M MACD crosses bearish
RSI weakens
Price loses EMA 20
2H trend turns bearish
Price breaks below EMA 50 with weakness
ATR stop is hit
Maximum hold time is reached

PUT exits can happen when:

30M MACD crosses bullish
RSI recovers
Price reclaims EMA 20
2H trend turns bullish
Price breaks above EMA 50 with strength
ATR stop is hit
Maximum hold time is reached

The goal is to hold winners longer but exit when the trend clearly weakens.

Meaning of the Table

The table is the main decision dashboard.

Daily

Shows the larger market bias.

Bullish = larger trend favors CALLs
Bearish = larger trend favors PUTs
Neutral = no clear daily direction
2H

Shows the active swing trend.

Strong Bull = 2H supports CALLs strongly
Bull Recovery = 2H may be turning bullish
Strong Bear = 2H supports PUTs strongly
Bear Recovery = 2H may be turning bearish
Neutral = no strong 2H direction
30M

Shows the current 30-minute trend.

30M Bull = short-term trend favors CALLs
30M Bear = short-term trend favors PUTs
Neutral = short-term trend is unclear
MACD

Shows the recent 30-minute MACD cross.

Bull Cross = recent bullish MACD cross
Bear Cross = recent bearish MACD cross
No Fresh Cross = no recent MACD timing signal

MACD is used for timing, but it should be confirmed by the trend and L-Score.

Pullback

Shows whether price recently pulled back into a potential entry area.

CALL Pullback = possible CALL setup area
PUT Pullback = possible PUT setup area
None = no pullback setup

A pullback alone is not an entry. It needs MACD, trend, and L-Score confirmation.

L-Score

This is the Lorentzian-style quality score.

Bull 5 or higher = bullish conditions are strong
Bear 5 or higher = bearish conditions are strong
Weak = no strong quality confirmation

The stronger the L-Score, the better the trade quality.

Chop

Shows whether the market is tradable or sideways.

Trade OK = market is not detected as choppy
No Trade = market is consolidating or too sideways

Avoid new trades when this says No Trade.

Position

Shows the current strategy position.

CALL = currently in a CALL / long trade
PUT = currently in a PUT / short trade
Flat = no active trade
Action

This is the simplified guidance.

Hold CALL = stay in the CALL trade
Hold PUT = stay in the PUT trade
CALL Watch = conditions are building for CALL
PUT Watch = conditions are building for PUT
Wait = no high-quality setup
How to Use the Indicator

For a strong CALL setup, look for:

Daily: Bullish
2H: Strong Bull or Bull Recovery
30M: 30M Bull
MACD: Bull Cross
Pullback: CALL Pullback
L-Score: Bull 5 or higher
Chop: Trade OK
Action: CALL Watch or Hold CALL

For a strong PUT setup, look for:

Daily: Bearish
2H: Strong Bear or Bear Recovery
30M: 30M Bear
MACD: Bear Cross
Pullback: PUT Pullback
L-Score: Bear 5 or higher
Chop: Trade OK
Action: PUT Watch or Hold PUT

Avoid trades when:

Daily and 2H disagree strongly
L-Score is Weak
Chop says No Trade
MACD is opposite the desired direction
Price is too extended away from EMA 20
Action says Wait
Simple Trading Rules
Entry Rule
Only enter when the higher timeframe direction, 30M MACD, pullback, L-Score, and chop filter agree.
Exit Rule
Do not exit on the first small pullback.
Exit when MACD, RSI, price, or 2H trend confirm weakness, or when the strategy prints EXIT.
Trend Rule
If Daily and 2H are bullish, focus on CALLs.
If Daily and 2H are bearish, focus on PUTs.
If trend is mixed, wait for a cleaner setup.
Theta Rule
Avoid sitting in sideways trades.
Options lose value when price does not move.
If Chop says No Trade or the trade is not moving, be cautious.
Summary

This indicator is a multi-timeframe swing options strategy that uses:

Daily trend
2H confirmation
30M MACD timing
Pullback entries
Lorentzian-style quality score
Chop filter
ATR runner stop
RSI + MACD exit confirmation

It is meant to help traders avoid random entries and focus on higher-quality swing setups where the trend, momentum, and market condition are aligned.

## Source Code

````pine
//@version=5
strategy("30M Options Swing Edge - Lorentzian Style Trend Pullback", overlay=true, pyramiding=0, process_orders_on_close=true, initial_capital=100000, max_labels_count=500)

// =====================
// Inputs
// =====================
dailyTF = input.timeframe("D", "Daily Bias Timeframe")
confirmTF = input.timeframe("120", "2H Confirmation Timeframe")

mode = input.string("Balanced", "Signal Mode", options=["Aggressive", "Balanced", "Safe"])

rsiLen = input.int(14, "RSI 14 Length", minval=1)
rsiFastLen = input.int(9, "RSI 9 Length", minval=1)
rsiMaLen = input.int(14, "RSI MA Length", minval=1)

macdFast = input.int(12, "MACD Fast Length", minval=1)
macdSlow = input.int(26, "MACD Slow Length", minval=1)
macdSignalLen = input.int(9, "MACD Signal Length", minval=1)
macdCrossActiveBars = input.int(5, "30M MACD Cross Active Bars", minval=1)

emaFastLen = input.int(20, "EMA 20 Length", minval=1)
emaMidLen = input.int(50, "EMA 50 Length", minval=1)
emaSlowLen = input.int(200, "EMA 200 Length", minval=1)

wtChannelLen = input.int(10, "WaveTrend Channel Length", minval=1)
wtAverageLen = input.int(11, "WaveTrend Average Length", minval=1)

cciLen = input.int(20, "CCI Length", minval=1)

adxLen = input.int(20, "ADX Length", minval=1)
adxSmooth = input.int(14, "ADX Smoothing", minval=1)
adxMin = input.float(16.0, "Minimum ADX", step=0.5)

atrLen = input.int(14, "ATR Length", minval=1)
emergencyStopAtr = input.float(2.2, "Emergency Stop ATR", step=0.1)
trailStartAtr = input.float(2.0, "Start Trailing After ATR Profit", step=0.1)
trailAtr = input.float(3.2, "Trailing Stop ATR", step=0.1)

pullbackBars = input.int(12, "Pullback Active Bars", minval=1)

cooldownAfterEntry = input.int(10, "Cooldown After Entry Bars", minval=0)
cooldownAfterExit = input.int(4, "Cooldown After Exit Bars", minval=0)
minHoldBars = input.int(8, "Minimum Hold Bars", minval=1)
maxHoldBars = input.int(78, "Maximum Hold Bars", minval=1)

useChopFilter = input.bool(true, "Use Chop Filter")
chopLookback = input.int(24, "Chop Lookback", minval=5)
chopAdx = input.float(15.0, "Chop ADX Threshold", step=0.5)
emaCompressionAtr = input.float(0.35, "EMA Compression ATR", step=0.05)

useThetaProtection = input.bool(false, "Use Theta No-Progress Exit")
thetaCheckBars = input.int(18, "Theta Check Bars", minval=1)
minMoveAtrToHold = input.float(0.60, "Minimum ATR Move To Hold", step=0.05)

showEma20 = input.bool(true, "Show EMA 20")
showEma50 = input.bool(true, "Show EMA 50")
showEma200 = input.bool(false, "Show EMA 200")
showStopLine = input.bool(true, "Show Active Stop")
showSignals = input.bool(true, "Show CALL / PUT / EXIT Labels")
showTable = input.bool(true, "Show Status Table")

// =====================
// Mode thresholds
// =====================
lorentzThreshold = mode == "Aggressive" ? 4 : mode == "Balanced" ? 5 : 6

// =====================
// WaveTrend helper
// =====================
f_wavetrend(src, n1, n2) =>
    esa = ta.ema(src, n1)
    dev = ta.ema(math.abs(src - esa), n1)
    ci = dev != 0 ? (src - esa) / (0.015 * dev) : 0.0
    wt1 = ta.ema(ci, n2)
    wt2 = ta.sma(wt1, 4)
    [wt1, wt2]

// =====================
// HTF helper
// =====================
f_htfData() =>
    e20 = ta.ema(close, emaFastLen)
    e50 = ta.ema(close, emaMidLen)
    e200 = ta.ema(close, emaSlowLen)
    rsi14 = ta.rsi(close, rsiLen)
    rsi9 = ta.rsi(close, rsiFastLen)
    [m, s, h] = ta.macd(close, macdFast, macdSlow, macdSignalLen)
    [pdiVal, mdiVal, ax] = ta.dmi(adxLen, adxSmooth)
    cciVal = ta.cci(hlc3, cciLen)
    [wtA, wtB] = f_wavetrend(hlc3, wtChannelLen, wtAverageLen)
    [close, e20, e50, e200, rsi14, rsi9, m, s, h, pdiVal, mdiVal, ax, cciVal, wtA, wtB]

// =====================
// Higher timeframe data
// =====================
[dClose, dEma20, dEma50, dEma200, dRsi, dRsiFast, dMacd, dSignal, dHist, dPdi, dMdi, dAdx, dCci, dWt1, dWt2] = request.security(syminfo.tickerid, dailyTF, f_htfData(), lookahead=barmerge.lookahead_off)
[cClose, cEma20, cEma50, cEma200, cRsi, cRsiFast, cMacd, cSignal, cHist, cPdi, cMdi, cAdx, cCci, cWt1, cWt2] = request.security(syminfo.tickerid, confirmTF, f_htfData(), lookahead=barmerge.lookahead_off)

// =====================
// 30M indicators
// =====================
ema20 = ta.ema(close, emaFastLen)
ema50 = ta.ema(close, emaMidLen)
ema200 = ta.ema(close, emaSlowLen)

rsi = ta.rsi(close, rsiLen)
rsiFast = ta.rsi(close, rsiFastLen)
rsiMA = ta.sma(rsi, rsiMaLen)

[macdLine, signalLine, hist] = ta.macd(close, macdFast, macdSlow, macdSignalLen)

[pdi, mdi, adx] = ta.dmi(adxLen, adxSmooth)
cci = ta.cci(hlc3, cciLen)
[wt1, wt2] = f_wavetrend(hlc3, wtChannelLen, wtAverageLen)

atr = ta.atr(atrLen)

// =====================
// HTF trend direction
// =====================
dailyBull = dClose > dEma50 and dRsi > 50
dailyBear = dClose < dEma50 and dRsi < 50

dailyStrongBull = dClose > dEma50 and dEma50 > dEma200 and dRsi > 52
dailyStrongBear = dClose < dEma50 and dEma50 < dEma200 and dRsi < 48

twoHourBull = cClose > cEma20 and cRsi > 50 and cMacd > cSignal
twoHourBear = cClose < cEma20 and cRsi < 50 and cMacd < cSignal

twoHourBullStrong = cClose > cEma50 and cEma20 > cEma50 and cRsi > 50 and cMacd > cSignal
twoHourBearStrong = cClose < cEma50 and cEma20 < cEma50 and cRsi < 50 and cMacd < cSignal

twoHourBullRecovery = cHist > cHist[1] and cRsi > 45 and cClose > cEma20
twoHourBearRecovery = cHist < cHist[1] and cRsi < 55 and cClose < cEma20

// =====================
// 30M trend
// =====================
chartBull = close > ema20 and ema20 >= ema50
chartBear = close < ema20 and ema20 <= ema50

// =====================
// 30M MACD timing
// =====================
macdCrossUp = ta.crossover(macdLine, signalLine)
macdCrossDown = ta.crossunder(macdLine, signalLine)

macdBullBars = ta.barssince(macdCrossUp)
macdBearBars = ta.barssince(macdCrossDown)

macdBullRecent = not na(macdBullBars) and macdBullBars <= macdCrossActiveBars
macdBearRecent = not na(macdBearBars) and macdBearBars <= macdCrossActiveBars

macdBullMomentum = macdLine > signalLine and hist > hist[1]
macdBearMomentum = macdLine < signalLine and hist < hist[1]

// =====================
// Lorentzian-style score
// Features: RSI 14, WT, CCI, ADX, RSI 9
// =====================
bullLorentzScore = 0
bullLorentzScore += rsi > 50 ? 1 : 0
bullLorentzScore += rsiFast > rsi ? 1 : 0
bullLorentzScore += wt1 > wt2 ? 1 : 0
bullLorentzScore += cci > 0 ? 1 : 0
bullLorentzScore += adx >= adxMin and pdi > mdi ? 1 : 0
bullLorentzScore += macdBullMomentum ? 1 : 0
bullLorentzScore += close > ema20 and close > ema50 ? 1 : 0

bearLorentzScore = 0
bearLorentzScore += rsi < 50 ? 1 : 0
bearLorentzScore += rsiFast < rsi ? 1 : 0
bearLorentzScore += wt1 < wt2 ? 1 : 0
bearLorentzScore += cci < 0 ? 1 : 0
bearLorentzScore += adx >= adxMin and mdi > pdi ? 1 : 0
bearLorentzScore += macdBearMomentum ? 1 : 0
bearLorentzScore += close < ema20 and close < ema50 ? 1 : 0

bullLorentzOk = bullLorentzScore >= lorentzThreshold
bearLorentzOk = bearLorentzScore >= lorentzThreshold

// =====================
// Pullback logic
// =====================
pullbackCallNow = low <= ema20 or low <= ema50 or rsi < 45
pullbackPutNow = high >= ema20 or high >= ema50 or rsi > 55

barsSinceCallPullback = ta.barssince(pullbackCallNow)
barsSincePutPullback = ta.barssince(pullbackPutNow)

pullbackCall = not na(barsSinceCallPullback) and barsSinceCallPullback <= pullbackBars
pullbackPut = not na(barsSincePutPullback) and barsSincePutPullback <= pullbackBars

priceReclaimCall = close > ema20 and close > close[1] and close > open
priceRejectPut = close < ema20 and close < close[1] and close < open

notExtendedCall = close <= ema20 + atr * 2.3
notExtendedPut = close >= ema20 - atr * 2.3

// =====================
// Chop filter
// =====================
rangeHigh = ta.highest(high, chopLookback)
rangeLow = ta.lowest(low, chopLookback)
rangeSize = rangeHigh - rangeLow

emaCompressed = math.abs(ema20 - ema50) < atr * emaCompressionAtr
weakAdx = adx < chopAdx
tightRange = rangeSize < atr * 1.6
insideRange = close < rangeHigh and close > rangeLow

chopZone = useChopFilter and weakAdx and emaCompressed and tightRange and insideRange

bullBreakFromChop = close > rangeHigh[1] and macdBullMomentum and rsi > 50
bearBreakFromChop = close < rangeLow[1] and macdBearMomentum and rsi < 50

tradeAllowedByChop = not chopZone or bullBreakFromChop or bearBreakFromChop

// =====================
// Bias rules: trend is your friend
// =====================
callBias = mode == "Safe" ? dailyBull and (twoHourBull or twoHourBullRecovery) : dailyBull or twoHourBull or twoHourBullRecovery
putBias = mode == "Safe" ? dailyBear and (twoHourBear or twoHourBearRecovery) : dailyBear or twoHourBear or twoHourBearRecovery

// =====================
// Entry logic
// =====================
callSetup =
     callBias and
     pullbackCall and
     macdBullRecent and
     macdBullMomentum and
     bullLorentzOk and
     priceReclaimCall and
     chartBull and
     notExtendedCall and
     tradeAllowedByChop

putSetup =
     putBias and
     pullbackPut and
     macdBearRecent and
     macdBearMomentum and
     bearLorentzOk and
     priceRejectPut and
     chartBear and
     notExtendedPut and
     tradeAllowedByChop

// Strong trend continuation entry
callContinuation =
     dailyStrongBull and
     twoHourBullStrong and
     chartBull and
     macdBullRecent and
     bullLorentzOk and
     close > ema20 and
     notExtendedCall and
     tradeAllowedByChop

putContinuation =
     dailyStrongBear and
     twoHourBearStrong and
     chartBear and
     macdBearRecent and
     bearLorentzOk and
     close < ema20 and
     notExtendedPut and
     tradeAllowedByChop

finalCallSetup = callSetup or callContinuation
finalPutSetup = putSetup or putContinuation

// =====================
// Cooldown / entry control
// =====================
var int lastEntryBar = na
var int lastExitBar = na

entryCooldownOk = na(lastEntryBar) or bar_index - lastEntryBar > cooldownAfterEntry
exitCooldownOk = na(lastExitBar) or bar_index - lastExitBar > cooldownAfterExit
canEnter = entryCooldownOk and exitCooldownOk

callEntry = barstate.isconfirmed and strategy.position_size <= 0 and finalCallSetup and canEnter
putEntry = barstate.isconfirmed and strategy.position_size >= 0 and finalPutSetup and canEnter

// Do not fight strong 2H direction
callEntry := callEntry and not twoHourBearStrong
putEntry := putEntry and not twoHourBullStrong

// =====================
// Trade tracking
// =====================
var int entryBar = na
var float entryAtr = na
var float highSinceEntry = na
var float lowSinceEntry = na
var float activeStop = na

if callEntry
    if strategy.position_size < 0
        strategy.close("PUT")
    strategy.entry("CALL", strategy.long)
    lastEntryBar := bar_index
    entryBar := bar_index
    entryAtr := atr
    highSinceEntry := high
    lowSinceEntry := low
    activeStop := close - atr * emergencyStopAtr

if putEntry
    if strategy.position_size > 0
        strategy.close("CALL")
    strategy.entry("PUT", strategy.short)
    lastEntryBar := bar_index
    entryBar := bar_index
    entryAtr := atr
    highSinceEntry := high
    lowSinceEntry := low
    activeStop := close + atr * emergencyStopAtr

if strategy.position_size > 0
    highSinceEntry := na(highSinceEntry) ? high : math.max(highSinceEntry, high)
    lowSinceEntry := na(lowSinceEntry) ? low : math.min(lowSinceEntry, low)

if strategy.position_size < 0
    highSinceEntry := na(highSinceEntry) ? high : math.max(highSinceEntry, high)
    lowSinceEntry := na(lowSinceEntry) ? low : math.min(lowSinceEntry, low)

barsInTrade = strategy.position_size != 0 and not na(entryBar) ? bar_index - entryBar : 0
activeAtr = na(entryAtr) ? atr : entryAtr

// =====================
// Runner stop logic
// =====================
longEmergencyStop = strategy.position_avg_price - activeAtr * emergencyStopAtr
shortEmergencyStop = strategy.position_avg_price + activeAtr * emergencyStopAtr

longProfitMove = strategy.position_size > 0 and highSinceEntry >= strategy.position_avg_price + activeAtr * trailStartAtr
shortProfitMove = strategy.position_size < 0 and lowSinceEntry <= strategy.position_avg_price - activeAtr * trailStartAtr

longTrailStop = highSinceEntry - activeAtr * trailAtr
shortTrailStop = lowSinceEntry + activeAtr * trailAtr

longBreakEvenStop = strategy.position_avg_price + activeAtr * 0.10
shortBreakEvenStop = strategy.position_avg_price - activeAtr * 0.10

if strategy.position_size > 0
    activeStop := longProfitMove ? math.max(longBreakEvenStop, longTrailStop) : longEmergencyStop

if strategy.position_size < 0
    activeStop := shortProfitMove ? math.min(shortBreakEvenStop, shortTrailStop) : shortEmergencyStop

// =====================
// Exit logic
// =====================
callMacdExit = strategy.position_size > 0 and barsInTrade >= minHoldBars and macdCrossDown and rsi < rsiMA and close < ema20 and bearLorentzScore >= 4
putMacdExit = strategy.position_size < 0 and barsInTrade >= minHoldBars and macdCrossUp and rsi > rsiMA and close > ema20 and bullLorentzScore >= 4

callHtfFail = strategy.position_size > 0 and barsInTrade >= minHoldBars and twoHourBearStrong
putHtfFail = strategy.position_size < 0 and barsInTrade >= minHoldBars and twoHourBullStrong

callDeepFail = strategy.position_size > 0 and barsInTrade >= minHoldBars and close < ema50 and macdLine < signalLine and rsi < 45
putDeepFail = strategy.position_size < 0 and barsInTrade >= minHoldBars and close > ema50 and macdLine > signalLine and rsi > 55

longNoProgress = useThetaProtection and strategy.position_size > 0 and barsInTrade >= thetaCheckBars and highSinceEntry < strategy.position_avg_price + activeAtr * minMoveAtrToHold and not twoHourBullStrong
shortNoProgress = useThetaProtection and strategy.position_size < 0 and barsInTrade >= thetaCheckBars and lowSinceEntry > strategy.position_avg_price - activeAtr * minMoveAtrToHold and not twoHourBearStrong

timeExit = strategy.position_size != 0 and barsInTrade >= maxHoldBars

if strategy.position_size > 0
    strategy.exit("CALL Exit", from_entry="CALL", stop=activeStop)

if strategy.position_size < 0
    strategy.exit("PUT Exit", from_entry="PUT", stop=activeStop)

if callMacdExit or callHtfFail or callDeepFail or longNoProgress or timeExit
    strategy.close("CALL")

if putMacdExit or putHtfFail or putDeepFail or shortNoProgress or timeExit
    strategy.close("PUT")

callClosed = strategy.position_size[1] > 0 and strategy.position_size == 0
putClosed = strategy.position_size[1] < 0 and strategy.position_size == 0

if callClosed or putClosed
    lastExitBar := bar_index

if strategy.position_size == 0
    entryBar := na
    entryAtr := na
    highSinceEntry := na
    lowSinceEntry := na
    activeStop := na

// =====================
// Plots
// =====================
plot(showEma20 ? ema20 : na, "EMA 20", color=color.yellow, linewidth=1)
plot(showEma50 ? ema50 : na, "EMA 50", color=color.orange, linewidth=2)
plot(showEma200 ? ema200 : na, "EMA 200", color=color.blue, linewidth=2)

plot(showStopLine and strategy.position_size != 0 ? activeStop : na, "Active Stop", color=color.white, linewidth=2, style=plot.style_linebr)

bgcolor(chopZone ? color.new(color.gray, 88) : na)

plotshape(showSignals and callEntry, title="CALL Entry", text="CALL", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.normal)
plotshape(showSignals and putEntry, title="PUT Entry", text="PUT", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

plotshape(showSignals and callClosed, title="CALL Exit", text="EXIT", style=shape.labeldown, location=location.abovebar, color=color.yellow, textcolor=color.black, size=size.small)
plotshape(showSignals and putClosed, title="PUT Exit", text="EXIT", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.small)

// =====================
// Status table
// =====================
var table t = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast and showTable
    dailyText = dailyBull ? "Bullish" : dailyBear ? "Bearish" : "Neutral"
    twoHourText = twoHourBullStrong ? "Strong Bull" : twoHourBearStrong ? "Strong Bear" : twoHourBullRecovery ? "Bull Recovery" : twoHourBearRecovery ? "Bear Recovery" : "Neutral"
    chartText = chartBull ? "30M Bull" : chartBear ? "30M Bear" : "Neutral"
    macdText = macdBullRecent ? "Bull Cross" : macdBearRecent ? "Bear Cross" : "No Fresh Cross"
    pullbackText = pullbackCall ? "CALL Pullback" : pullbackPut ? "PUT Pullback" : "None"
    lorentzText = bullLorentzOk ? "Bull " + str.tostring(bullLorentzScore) : bearLorentzOk ? "Bear " + str.tostring(bearLorentzScore) : "Weak"
    chopText = chopZone ? "No Trade" : "Trade OK"
    posText = strategy.position_size > 0 ? "CALL" : strategy.position_size < 0 ? "PUT" : "Flat"
    actionText = strategy.position_size > 0 ? "Hold CALL" : strategy.position_size < 0 ? "Hold PUT" : finalCallSetup ? "CALL Watch" : finalPutSetup ? "PUT Watch" : "Wait"

    table.cell(t, 0, 0, "Daily", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, dailyText, text_color=color.white, bgcolor=dailyBull ? color.green : dailyBear ? color.red : color.gray)

    table.cell(t, 0, 1, "2H", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 1, twoHourText, text_color=color.white, bgcolor=twoHourBullStrong or twoHourBullRecovery ? color.green : twoHourBearStrong or twoHourBearRecovery ? color.red : color.gray)

    table.cell(t, 0, 2, "30M", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 2, chartText, text_color=color.white, bgcolor=chartBull ? color.green : chartBear ? color.red : color.gray)

    table.cell(t, 0, 3, "MACD", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 3, macdText, text_color=color.white, bgcolor=macdBullRecent ? color.green : macdBearRecent ? color.red : color.gray)

    table.cell(t, 0, 4, "Pullback", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 4, pullbackText, text_color=color.white, bgcolor=pullbackCall ? color.green : pullbackPut ? color.red : color.gray)

    table.cell(t, 0, 5, "L-Score", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 5, lorentzText, text_color=color.white, bgcolor=bullLorentzOk ? color.green : bearLorentzOk ? color.red : color.gray)

    table.cell(t, 0, 6, "Chop", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 6, chopText, text_color=color.white, bgcolor=chopZone ? color.gray : color.black)

    table.cell(t, 0, 7, "Position", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 7, posText, text_color=color.white, bgcolor=strategy.position_size > 0 ? color.green : strategy.position_size < 0 ? color.red : color.gray)

    table.cell(t, 0, 8, "Action", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 8, actionText, text_color=color.white, bgcolor=actionText == "Hold CALL" or actionText == "CALL Watch" ? color.green : actionText == "Hold PUT" or actionText == "PUT Watch" ? color.red : color.gray)

// =====================
// Alerts
// =====================
alertcondition(callEntry, "CALL Entry", "CALL entry: HTF trend + 30M MACD + Lorentzian-style bullish score")
alertcondition(putEntry, "PUT Entry", "PUT entry: HTF trend + 30M MACD + Lorentzian-style bearish score")
alertcondition(callClosed, "CALL Exit", "CALL exit detected")
alertcondition(putClosed, "PUT Exit", "PUT exit detected")
````
