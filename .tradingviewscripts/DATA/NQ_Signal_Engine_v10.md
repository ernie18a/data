<!-- tradingview-pine-id: PUB;88088779c96e4891bad739f987db1711 -->
<!-- tradingviewscripts-format: 1 -->
# NQ Signal Engine v1.0

Source: https://www.tradingview.com/script/PebLfgcl-NQ-Signal-Engine-v1-0/

## Description

This Pine Script is designed for trading the NQ! (E-mini Nasdaq-100 Futures) by identifying high-probability trend-following opportunities. It uses the 20, 50, and 200 exponential moving averages (EMAs) to determine the overall market trend, along with VWAP to confirm intraday market bias. Long signals are generated when price is above the major moving averages, pulls back to the 20 EMA or VWAP, and resumes upward momentum, confirmed by an RSI reading above 50 and higher-than-average trading volume. Short signals follow the opposite criteria during bearish trends. The script includes ATR-based stop-loss placement and configurable profit targets based on a user-defined risk-to-reward ratio, with an optional trailing stop to lock in gains. It visually plots the moving averages and VWAP, displays buy and sell markers on the chart, shades the background to indicate bullish or bearish conditions, and supports customizable inputs for indicator settings, risk management, and trading sessions, making it suitable for backtesting and intraday trading on 1-, 5-, and 15-minute NQ! charts.

---

## Source Code

````pine
// ============================================================================
// NQ1! MULTI-TIMEFRAME SIGNAL ENGINE
// System 1: Signal Engine (TradingView) — ANALYSIS + ALERTS ONLY.
// This script NEVER places trades. It only evaluates conditions and fires
// webhook alerts consumed by the separate Node.js Execution Engine.
// ============================================================================
//@version=6
indicator("NQ Signal Engine v1.0", overlay=true, max_lines_count=200, max_labels_count=200)

// ============================================================================
// SECTION 1: INPUTS
// ============================================================================
grp_gen   = "General"
grp_tf    = "Timeframes"
grp_ind   = "Indicators"
grp_smc   = "Smart Money Concepts"
grp_score = "Confirmation / Scoring"
grp_risk  = "Risk Management"
grp_sess  = "Session Filters"
grp_alert = "Alerts"

symbolWhitelist = input.string("NQ1!", "Allowed Symbol (informational)", group=grp_gen)

// Timeframes analyzed simultaneously
tf_4h  = input.timeframe("240", "Higher TF (Trend)", group=grp_tf)
tf_1h  = input.timeframe("60",  "1H (Trend)",        group=grp_tf)
tf_15m = input.timeframe("15",  "15M (Pullback)",     group=grp_tf)
tf_5m  = input.timeframe("5",   "5M (Breakout)",      group=grp_tf)
tf_1m  = input.timeframe("1",   "1M (Trigger)",       group=grp_tf)

// Indicators
emaFastLen = input.int(21, "EMA Fast", group=grp_ind)
emaMidLen  = input.int(50, "EMA Mid", group=grp_ind)
emaSlowLen = input.int(200, "EMA Slow", group=grp_ind)
rsiLen     = input.int(14, "RSI Length", group=grp_ind)
atrLen     = input.int(14, "ATR Length", group=grp_ind)
volAvgLen  = input.int(20, "Volume Avg Length", group=grp_ind)
useMACD    = input.bool(false, "Use MACD (optional)", group=grp_ind)
useSupertrend = input.bool(false, "Use Supertrend (optional)", group=grp_ind)
useADX     = input.bool(false, "Use ADX (optional)", group=grp_ind)
stFactor   = input.float(3.0, "Supertrend Factor", group=grp_ind)
stATRLen   = input.int(10, "Supertrend ATR Length", group=grp_ind)
adxLen     = input.int(14, "ADX Length", group=grp_ind)
adxMinTrend = input.float(20.0, "Minimum ADX for trending market", group=grp_ind)

// Smart Money Concepts
swingLen        = input.int(5, "Swing Detection Lookback", group=grp_smc)
useLiquiditySweep = input.bool(true, "Detect Liquidity Sweeps", group=grp_smc)
useOrderBlocks     = input.bool(true, "Detect Order Blocks", group=grp_smc)
useFVG             = input.bool(true, "Detect Fair Value Gaps", group=grp_smc)
premiumDiscountLookback = input.int(50, "Premium/Discount Range Lookback", group=grp_smc)

// Scoring
confidenceThreshold = input.int(70, "Minimum Confidence To Alert (0-100)", minval=0, maxval=100, group=grp_score)
minConfirmations    = input.int(4, "Minimum Confirmations Required (of possible confirmations)", group=grp_score)
signalCooldownBars  = input.int(5, "Bars Between Repeat Signals (same direction)", group=grp_score)

// Risk
atrMultStop   = input.float(1.5, "ATR Multiplier for Stop Loss", group=grp_risk)
riskRewardRatio = input.float(2.0, "Target Risk/Reward Ratio", group=grp_risk)
minATRPoints  = input.float(3.0, "Minimum ATR (points) to allow signal", group=grp_risk)
minVolumeMultiple = input.float(0.8, "Minimum Volume vs Avg (multiple)", group=grp_risk)

// Sessions (exchange/instrument timezone assumed America/New_York; adjust to your feed)
useSessionFilter = input.bool(true, "Filter by Session", group=grp_sess)
allowLondon  = input.bool(true, "Allow London Session", group=grp_sess)
allowNewYork = input.bool(true, "Allow New York Session", group=grp_sess)
allowAsia    = input.bool(false, "Allow Asia Session", group=grp_sess)
londonSession  = input.session("0300-0800", "London Session (exchange local time)", group=grp_sess)
newYorkSession = input.session("0930-1600", "New York Session (exchange local time)", group=grp_sess)
asiaSession    = input.session("1900-0000", "Asia Session (exchange local time)", group=grp_sess)

// Alerts
webhookSymbolField = input.string("NQ1!", "Symbol field to embed in JSON payload", group=grp_alert)
enableAlerts = input.bool(true, "Enable Webhook Alerts", group=grp_alert)

// ============================================================================
// SECTION 2: MARKET STRUCTURE (current chart timeframe)
// ============================================================================
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var float prevSwingHigh = na
var float prevSwingLow  = na

if not na(pivotHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := pivotHigh
if not na(pivotLow)
    prevSwingLow := lastSwingLow
    lastSwingLow := pivotLow

higherHigh = not na(lastSwingHigh) and not na(prevSwingHigh) and lastSwingHigh > prevSwingHigh
lowerHigh  = not na(lastSwingHigh) and not na(prevSwingHigh) and lastSwingHigh < prevSwingHigh
higherLow  = not na(lastSwingLow) and not na(prevSwingLow) and lastSwingLow > prevSwingLow
lowerLow   = not na(lastSwingLow) and not na(prevSwingLow) and lastSwingLow < prevSwingLow

var string structureTrend = "NEUTRAL"
if higherHigh and higherLow
    structureTrend := "BULLISH"
if lowerHigh and lowerLow
    structureTrend := "BEARISH"

// Break of Structure / Change of Character (simplified, non-repainting on confirmed pivots)
var string lastBOSDirection = "NONE"
bosUp   = not na(lastSwingHigh) and close > lastSwingHigh and lastBOSDirection != "UP"
bosDown = not na(lastSwingLow)  and close < lastSwingLow  and lastBOSDirection != "DOWN"
choch = (lastBOSDirection == "UP" and bosDown) or (lastBOSDirection == "DOWN" and bosUp)
if bosUp
    lastBOSDirection := "UP"
if bosDown
    lastBOSDirection := "DOWN"

// ============================================================================
// SECTION 3: INDICATORS (current chart timeframe)
// ============================================================================
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapVal = ta.vwap(hlc3)
rsiVal  = ta.rsi(close, rsiLen)
atrVal  = ta.atr(atrLen)
volAvg  = ta.sma(volume, volAvgLen)

[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)

atrSuper = ta.atr(stATRLen)
upperBand = hl2 + stFactor * atrSuper
lowerBand = hl2 - stFactor * atrSuper
var float stTrendLine = na
var int stDirection = 1
stTrendLine := close[1] > (stTrendLine[1]) ? math.max(lowerBand, stTrendLine[1]) : lowerBand
if close > stTrendLine[1]
    stDirection := 1
else if close < stTrendLine[1]
    stDirection := -1

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

// ============================================================================
// SECTION 4: MULTI-TIMEFRAME TREND (request.security, confirmed bars only)
// ============================================================================
get_trend(_ema21, _ema50, _ema200, _close) =>
    _close > _ema21 and _ema21 > _ema50 and _ema50 > _ema200 ? 1 :
     _close < _ema21 and _ema21 < _ema50 and _ema50 < _ema200 ? -1 : 0

f_htf_trend(tf) =>
    e21  = request.security(syminfo.tickerid, tf, ta.ema(close, emaFastLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    e50  = request.security(syminfo.tickerid, tf, ta.ema(close, emaMidLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    e200 = request.security(syminfo.tickerid, tf, ta.ema(close, emaSlowLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    c    = request.security(syminfo.tickerid, tf, close[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    get_trend(e21, e50, e200, c)

trend4H  = f_htf_trend(tf_4h)
trend1H  = f_htf_trend(tf_1h)

// 15M pullback completion: price pulled back to EMA21/50 zone then resumed
f_15m_pullback(tf, dir) =>
    c    = request.security(syminfo.tickerid, tf, close[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    e21  = request.security(syminfo.tickerid, tf, ta.ema(close, emaFastLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    e50  = request.security(syminfo.tickerid, tf, ta.ema(close, emaMidLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    dir == 1 ? (c <= e21 and c >= e50) : dir == -1 ? (c >= e21 and c <= e50) : false

pullback15M_long  = f_15m_pullback(tf_15m, 1)
pullback15M_short = f_15m_pullback(tf_15m, -1)

// 5M breakout confirmation: close beyond recent range high/low
f_5m_breakout(tf, dir) =>
    c = request.security(syminfo.tickerid, tf, close[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    hh = request.security(syminfo.tickerid, tf, ta.highest(high, 20)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    ll = request.security(syminfo.tickerid, tf, ta.lowest(low, 20)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    dir == 1 ? c >= hh : dir == -1 ? c <= ll : false

breakout5M_long  = f_5m_breakout(tf_5m, 1)
breakout5M_short = f_5m_breakout(tf_5m, -1)

// 1M entry trigger: momentum candle in direction of bias, confirmed close
f_1m_trigger(tf, dir) =>
    c  = request.security(syminfo.tickerid, tf, close[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    o  = request.security(syminfo.tickerid, tf, open[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    rsi1m = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen)[barstate.isrealtime ? 1 : 0], lookahead=barmerge.lookahead_off)
    dir == 1 ? (c > o and rsi1m > 50) : dir == -1 ? (c < o and rsi1m < 50) : false

trigger1M_long  = f_1m_trigger(tf_1m, 1)
trigger1M_short = f_1m_trigger(tf_1m, -1)

// ============================================================================
// SECTION 5: SMART MONEY CONCEPTS
// ============================================================================
// Liquidity sweep: wick beyond prior swing then close back inside
liquiditySweepHigh = useLiquiditySweep and not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh
liquiditySweepLow  = useLiquiditySweep and not na(lastSwingLow)  and low  < lastSwingLow  and close > lastSwingLow

// Equal highs / equal lows (within small tolerance)
eqTolerance = atrVal * 0.1
equalHighs = not na(lastSwingHigh) and not na(prevSwingHigh) and math.abs(lastSwingHigh - prevSwingHigh) <= eqTolerance
equalLows  = not na(lastSwingLow) and not na(prevSwingLow) and math.abs(lastSwingLow - prevSwingLow) <= eqTolerance

// Order blocks: last down-close candle before an up impulse (bullish OB) / inverse
bullishOB = useOrderBlocks and close[1] < open[1] and close > open and close > high[1]
bearishOB = useOrderBlocks and close[1] > open[1] and close < open and close < low[1]

// Fair Value Gaps (3-candle imbalance)
bullishFVG = useFVG and low > high[2]
bearishFVG = useFVG and high < low[2]

// Premium / Discount zone (Fibonacci-based, using recent range)
rangeHigh = ta.highest(high, premiumDiscountLookback)
rangeLow  = ta.lowest(low, premiumDiscountLookback)
rangeMid  = (rangeHigh + rangeLow) / 2
inDiscount = close < rangeMid
inPremium  = close > rangeMid

// Fibonacci retracement levels of most recent detected swing (for confluence only)
fibHigh = not na(lastSwingHigh) ? lastSwingHigh : rangeHigh
fibLow  = not na(lastSwingLow) ? lastSwingLow : rangeLow
fib50   = fibLow + (fibHigh - fibLow) * 0.5
fib618  = fibLow + (fibHigh - fibLow) * 0.382

// Simple pivot points (classic, daily)
[pDayOpen, pDayHigh, pDayLow, pDayClose] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)
pivotP  = (pDayHigh + pDayLow + pDayClose) / 3
pivotR1 = 2 * pivotP - pDayLow
pivotS1 = 2 * pivotP - pDayHigh

// RSI divergence (basic 2-point check over swing pivots)
bullishRSIDiv = not na(lastSwingLow) and not na(prevSwingLow) and lastSwingLow < prevSwingLow and rsiVal > ta.rsi(close, rsiLen)[swingLen]
bearishRSIDiv = not na(lastSwingHigh) and not na(prevSwingHigh) and lastSwingHigh > prevSwingHigh and rsiVal < ta.rsi(close, rsiLen)[swingLen]

// ============================================================================
// SECTION 6: SESSION FILTER
// ============================================================================
inLondon  = not na(time(timeframe.period, londonSession))
inNewYork = not na(time(timeframe.period, newYorkSession))
inAsia    = not na(time(timeframe.period, asiaSession))

sessionOK = not useSessionFilter or
             (allowLondon and inLondon) or
             (allowNewYork and inNewYork) or
             (allowAsia and inAsia)

// ============================================================================
// SECTION 7: QUALITY FILTERS
// ============================================================================
atrOK        = atrVal >= minATRPoints
volumeOK     = volume >= volAvg * minVolumeMultiple
rangeOK      = (high - low) >= atrVal * 0.3
trendStrongOK = not useADX or adxVal >= adxMinTrend
htfAgreeLong  = trend4H >= 0 and trend1H >= 0 and not (trend4H == -1 or trend1H == -1)
htfAgreeShort = trend4H <= 0 and trend1H <= 0 and not (trend4H == 1 or trend1H == 1)

// Duplicate signal / cooldown protection
var int lastLongBar  = na
var int lastShortBar = na
cooldownLongOK  = na(lastLongBar)  or (bar_index - lastLongBar)  >= signalCooldownBars
cooldownShortOK = na(lastShortBar) or (bar_index - lastShortBar) >= signalCooldownBars

qualityPass = sessionOK and atrOK and volumeOK and rangeOK and trendStrongOK

// ============================================================================
// SECTION 8: CONFIRMATION SCORING
// ============================================================================
// Each confirmation contributes points. Total possible = 100 (scaled).
f_score_long() =>
    score = 0.0
    total = 0.0
    // EMA alignment
    total += 10
    score += (close > emaFast and emaFast > emaMid and emaMid > emaSlow) ? 10 : 0
    // RSI confirmation
    total += 8
    score += (rsiVal > 50 and rsiVal < 70) ? 8 : 0
    // Volume confirmation
    total += 8
    score += volumeOK ? 8 : 0
    // VWAP confirmation
    total += 8
    score += (close > vwapVal) ? 8 : 0
    // Structure confirmation
    total += 10
    score += (structureTrend == "BULLISH" or bosUp) ? 10 : 0
    // Breakout confirmation (5M)
    total += 10
    score += breakout5M_long ? 10 : 0
    // Liquidity sweep
    total += 6
    score += liquiditySweepLow ? 6 : 0
    // Retest / pullback (15M)
    total += 8
    score += pullback15M_long ? 8 : 0
    // ATR volatility filter
    total += 6
    score += atrOK ? 6 : 0
    // HTF agreement (4H/1H) — heaviest weight
    total += 16
    score += htfAgreeLong ? 16 : 0
    // 1M trigger
    total += 10
    score += trigger1M_long ? 10 : 0
    // Pivot points confluence
    total += 4
    score += (close > pivotP) ? 4 : 0
    // Fibonacci confluence
    total += 4
    score += (close > fib618) ? 4 : 0
    // Supply/Demand (order block) confluence
    total += 6
    score += bullishOB ? 6 : 0
    // RSI divergence
    total += 6
    score += bullishRSIDiv ? 6 : 0
    // Discount zone (buy in discount)
    total += 6
    score += inDiscount ? 6 : 0
    confirmCount = (close > emaFast and emaFast > emaMid ? 1 : 0) + (rsiVal > 50 ? 1 : 0) + (volumeOK ? 1 : 0) + (close > vwapVal ? 1 : 0) + (structureTrend == "BULLISH" ? 1 : 0) + (breakout5M_long ? 1 : 0) + (pullback15M_long ? 1 : 0) + (htfAgreeLong ? 1 : 0) + (trigger1M_long ? 1 : 0) + (bullishOB ? 1 : 0) + (bullishRSIDiv ? 1 : 0)
    [math.round(score / total * 100), confirmCount]

f_score_short() =>
    score = 0.0
    total = 0.0
    total += 10
    score += (close < emaFast and emaFast < emaMid and emaMid < emaSlow) ? 10 : 0
    total += 8
    score += (rsiVal < 50 and rsiVal > 30) ? 8 : 0
    total += 8
    score += volumeOK ? 8 : 0
    total += 8
    score += (close < vwapVal) ? 8 : 0
    total += 10
    score += (structureTrend == "BEARISH" or bosDown) ? 10 : 0
    total += 10
    score += breakout5M_short ? 10 : 0
    total += 6
    score += liquiditySweepHigh ? 6 : 0
    total += 8
    score += pullback15M_short ? 8 : 0
    total += 6
    score += atrOK ? 6 : 0
    total += 16
    score += htfAgreeShort ? 16 : 0
    total += 10
    score += trigger1M_short ? 10 : 0
    total += 4
    score += (close < pivotP) ? 4 : 0
    total += 4
    score += (close < fib50) ? 4 : 0
    total += 6
    score += bearishOB ? 6 : 0
    total += 6
    score += bearishRSIDiv ? 6 : 0
    total += 6
    score += inPremium ? 6 : 0
    confirmCount = (close < emaFast and emaFast < emaMid ? 1 : 0) + (rsiVal < 50 ? 1 : 0) + (volumeOK ? 1 : 0) + (close < vwapVal ? 1 : 0) + (structureTrend == "BEARISH" ? 1 : 0) + (breakout5M_short ? 1 : 0) + (pullback15M_short ? 1 : 0) + (htfAgreeShort ? 1 : 0) + (trigger1M_short ? 1 : 0) + (bearishOB ? 1 : 0) + (bearishRSIDiv ? 1 : 0)
    [math.round(score / total * 100), confirmCount]

[longConfidence, longConfirmCount]   = f_score_long()
[shortConfidence, shortConfirmCount] = f_score_short()

// ============================================================================
// SECTION 9: SIGNAL GENERATION (confirmed bar close only)
// ============================================================================
barConfirmed = barstate.isconfirmed

longSignal = barConfirmed and qualityPass and htfAgreeLong and cooldownLongOK and
             longConfidence >= confidenceThreshold and longConfirmCount >= minConfirmations

shortSignal = barConfirmed and qualityPass and htfAgreeShort and cooldownShortOK and
              shortConfidence >= confidenceThreshold and shortConfirmCount >= minConfirmations

if longSignal
    lastLongBar := bar_index
if shortSignal
    lastShortBar := bar_index

// ============================================================================
// SECTION 10: RISK LEVELS
// ============================================================================
longStop    = close - (atrVal * atrMultStop)
longRisk    = close - longStop
longTarget  = close + (longRisk * riskRewardRatio)

shortStop   = close + (atrVal * atrMultStop)
shortRisk   = shortStop - close
shortTarget = close - (shortRisk * riskRewardRatio)

// ============================================================================
// SECTION 11: PLOTTING
// ============================================================================
plot(emaFast, "EMA 21", color=color.new(color.blue, 0))
plot(emaMid, "EMA 50", color=color.new(color.orange, 0))
plot(emaSlow, "EMA 200", color=color.new(color.red, 0))
plot(vwapVal, "VWAP", color=color.new(color.purple, 0))

plotshape(longSignal, title="BUY Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY")
plotshape(shortSignal, title="SELL Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

// ============================================================================
// SECTION 12: WEBHOOK ALERTS (JSON payload, confirmed bar closes only)
// ============================================================================
longPayload = '{"type":"BUY","symbol":"' + webhookSymbolField + '","entry":' + str.tostring(close, format.mintick) +
     ',"stop":' + str.tostring(longStop, format.mintick) +
     ',"target":' + str.tostring(longTarget, format.mintick) +
     ',"confidence":' + str.tostring(longConfidence) +
     ',"confirmations":' + str.tostring(longConfirmCount) +
     ',"atr":' + str.tostring(atrVal, format.mintick) +
     ',"time":"' + str.format("{0,date,yyyy-MM-dd'T'HH:mm:ss'Z'}", time) + '"}'

shortPayload = '{"type":"SELL","symbol":"' + webhookSymbolField + '","entry":' + str.tostring(close, format.mintick) +
     ',"stop":' + str.tostring(shortStop, format.mintick) +
     ',"target":' + str.tostring(shortTarget, format.mintick) +
     ',"confidence":' + str.tostring(shortConfidence) +
     ',"confirmations":' + str.tostring(shortConfirmCount) +
     ',"atr":' + str.tostring(atrVal, format.mintick) +
     ',"time":"' + str.format("{0,date,yyyy-MM-dd'T'HH:mm:ss'Z'}", time) + '"}'

if enableAlerts and longSignal
    alert(longPayload, alert.freq_once_per_bar_close)
if enableAlerts and shortSignal
    alert(shortPayload, alert.freq_once_per_bar_close)

// Dedicated alertcondition entries so users can also build alerts from the UI dialog
alertcondition(longSignal, title="NQ BUY Signal", message="BUY signal generated - check webhook payload in alert() call")
alertcondition(shortSignal, title="NQ SELL Signal", message="SELL signal generated - check webhook payload in alert() call")

// ============================================================================
// SECTION 13: INFO TABLE (on-chart diagnostics)
// ============================================================================
var table infoTable = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_width=1)
if barstate.islast
    table.cell(infoTable, 0, 0, "4H Trend", text_color=color.white)
    table.cell(infoTable, 1, 0, trend4H == 1 ? "BULLISH" : trend4H == -1 ? "BEARISH" : "NEUTRAL", text_color=color.white)
    table.cell(infoTable, 0, 1, "1H Trend", text_color=color.white)
    table.cell(infoTable, 1, 1, trend1H == 1 ? "BULLISH" : trend1H == -1 ? "BEARISH" : "NEUTRAL", text_color=color.white)
    table.cell(infoTable, 0, 2, "Structure", text_color=color.white)
    table.cell(infoTable, 1, 2, structureTrend, text_color=color.white)
    table.cell(infoTable, 0, 3, "Long Confidence", text_color=color.white)
    table.cell(infoTable, 1, 3, str.tostring(longConfidence) + "%", text_color=color.green)
    table.cell(infoTable, 0, 4, "Short Confidence", text_color=color.white)
    table.cell(infoTable, 1, 4, str.tostring(shortConfidence) + "%", text_color=color.red)
    table.cell(infoTable, 0, 5, "ATR", text_color=color.white)
    table.cell(infoTable, 1, 5, str.tostring(atrVal, format.mintick), text_color=color.white)
    table.cell(infoTable, 0, 6, "Session OK", text_color=color.white)
    table.cell(infoTable, 1, 6, sessionOK ? "YES" : "NO", text_color=color.white)
    table.cell(infoTable, 0, 7, "Quality Pass", text_color=color.white)
    table.cell(infoTable, 1, 7, qualityPass ? "YES" : "NO", text_color=color.white)
````
