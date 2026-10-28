# A+ Confluence Monitor for SPY/QQQ - MKTheGreat

- url: https://www.tradingview.com/script/mhD9qiYd-A-Confluence-Monitor-for-SPY-QQQ-MKTheGreat/
- type: indicator
- pine_id: PUB;ae2987e4c04b4f5db938454afd9d4e26
- version: 1.0

## Description

Credit to - Manish Kapoor ( MKTheGreat) 
For QQQ/SPY, start like this:

Setting	Value
Chart timeframe	3 minutes
Higher timeframe	5 minutes
Minimum A+ score	6 out of 7
Volume multiplier	1.0
Breakout lookback	20
EMA	9 / 20 / 50
RSI	14
MACD	12 / 26 / 9

When it gives A+ CALL, don’t blindly buy. Use it as:
“Now check the option chain: ATM/slightly ITM, tight spread, high volume, clear stop.”

When it gives A+ PUT, same logic.

For alerts, use Once Per Bar Close so you avoid false alerts before the candle finishes.

## Source Code

````pine
//@version=6
indicator("A+ Confluence Monitor for SPY/QQQ - Sachin v2", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================

emaFastLen     = input.int(9,  "Fast EMA", minval=1)
emaMidLen      = input.int(20, "Mid EMA", minval=1)
emaSlowLen     = input.int(50, "Slow EMA", minval=1)

rsiLen         = input.int(14, "RSI Length", minval=1)
rsiBullLevel   = input.float(50, "Bullish RSI Above")
rsiBearLevel   = input.float(50, "Bearish RSI Below")

macdFastLen    = input.int(12, "MACD Fast", minval=1)
macdSlowLen    = input.int(26, "MACD Slow", minval=1)
macdSignalLen  = input.int(9,  "MACD Signal", minval=1)

volLen         = input.int(20, "Volume Average Length", minval=1)
volMultiplier  = input.float(1.0, "Volume Must Be Above Avg x", step=0.1)

breakoutLen    = input.int(20, "Recent High/Low Lookback", minval=5)
atrLen         = input.int(14, "ATR Length", minval=1)
atrBufferMult  = input.float(0.05, "Breakout Buffer ATR Multiplier", step=0.01)

useHTFConfirm  = input.bool(true, "Use Higher Timeframe Confirmation?")
htf            = input.timeframe("5", "Higher Timeframe")

minScore       = input.int(6, "Minimum A+ Score Out of 7", minval=4, maxval=7)

showEMAs       = input.bool(true, "Show EMAs")
showVWAP       = input.bool(true, "Show VWAP")
showLevels     = input.bool(true, "Show Key Levels")
showBg         = input.bool(true, "Show Background Bias")
showDashboard  = input.bool(true, "Show Dashboard")

premarketSess  = input.session("0400-0929", "Premarket Session")
regularSess    = input.session("0930-1600", "Regular Session")
openRangeSess  = input.session("0930-0945", "Opening Range Session")

//====================================================
// CORE INDICATORS
//====================================================

emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

vwapVal = ta.vwap(hlc3)

rsiVal = ta.rsi(close, rsiLen)

[macdLine, macdSignal, macdHist] = ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)

volAvg = ta.sma(volume, volLen)
volOk  = volume >= volAvg * volMultiplier

atrVal = ta.atr(atrLen)
buffer = atrVal * atrBufferMult

//====================================================
// SESSION LOGIC
//====================================================

inPremarket = not na(time(timeframe.period, premarketSess))
inRegular   = not na(time(timeframe.period, regularSess))
inOR        = not na(time(timeframe.period, openRangeSess))
newDay      = ta.change(time("D")) != 0

//====================================================
// PREMARKET HIGH / LOW
//====================================================

var float pmHigh = na
var float pmLow  = na

if newDay
    pmHigh := na
    pmLow  := na

if inPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)

//====================================================
// OPENING RANGE HIGH / LOW
//====================================================

var float orHigh = na
var float orLow  = na

if newDay
    orHigh := na
    orLow  := na

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

//====================================================
// PREVIOUS DAY HIGH / LOW
//====================================================

prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

//====================================================
// RECENT STRUCTURE HIGH / LOW
//====================================================

recentHigh = ta.highest(high[1], breakoutLen)
recentLow  = ta.lowest(low[1], breakoutLen)

//====================================================
// HIGHER TIMEFRAME CONFIRMATION
//====================================================

htfClose = request.security(syminfo.tickerid, htf, close)
htfVWAP  = request.security(syminfo.tickerid, htf, ta.vwap(hlc3))
htfEMA9  = request.security(syminfo.tickerid, htf, ta.ema(close, emaFastLen))
htfEMA20 = request.security(syminfo.tickerid, htf, ta.ema(close, emaMidLen))
htfRSI   = request.security(syminfo.tickerid, htf, ta.rsi(close, rsiLen))

[htfMACDLine, htfMACDSignal, htfMACDHist] = request.security(
     syminfo.tickerid,
     htf,
     ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)
)

htfBull = htfClose > htfVWAP and htfEMA9 > htfEMA20 and htfRSI > rsiBullLevel and htfMACDLine > htfMACDSignal
htfBear = htfClose < htfVWAP and htfEMA9 < htfEMA20 and htfRSI < rsiBearLevel and htfMACDLine < htfMACDSignal

//====================================================
// PRECOMPUTE ALL CROSSOVER / CROSSUNDER VALUES
// This fixes Pine warning CW1000.
//====================================================

pmHighSafe = nz(pmHigh, close)
pmLowSafe  = nz(pmLow, close)
orHighSafe = nz(orHigh, close)
orLowSafe  = nz(orLow, close)

crossRecentUp = ta.crossover(close, recentHigh + buffer)
crossPMUp     = ta.crossover(close, pmHighSafe + buffer)
crossPDHUp    = ta.crossover(close, prevDayHigh + buffer)
crossORUp     = ta.crossover(close, orHighSafe + buffer)

crossRecentDown = ta.crossunder(close, recentLow - buffer)
crossPMDown     = ta.crossunder(close, pmLowSafe - buffer)
crossPDLDown    = ta.crossunder(close, prevDayLow - buffer)
crossORDown     = ta.crossunder(close, orLowSafe - buffer)

//====================================================
// BULLISH CONDITIONS
//====================================================

priceAboveVWAP = close > vwapVal
emaBull        = emaFast > emaMid and close > emaFast
rsiBull        = rsiVal > rsiBullLevel
macdBull       = macdLine > macdSignal and macdHist > macdHist[1]
volumeBull     = volOk
structureBull  = close > emaSlow

breakRecentUp = crossRecentUp
breakPMUp     = not na(pmHigh) and crossPMUp
breakPDHUp    = crossPDHUp
breakORUp     = not na(orHigh) and crossORUp

bullBreakoutTrigger = breakRecentUp or breakPMUp or breakPDHUp or breakORUp

bullScore = 
     (priceAboveVWAP ? 1 : 0) +
     (emaBull ? 1 : 0) +
     (rsiBull ? 1 : 0) +
     (macdBull ? 1 : 0) +
     (volumeBull ? 1 : 0) +
     (structureBull ? 1 : 0) +
     (bullBreakoutTrigger ? 1 : 0)

//====================================================
// BEARISH CONDITIONS
//====================================================

priceBelowVWAP = close < vwapVal
emaBear        = emaFast < emaMid and close < emaFast
rsiBear        = rsiVal < rsiBearLevel
macdBear       = macdLine < macdSignal and macdHist < macdHist[1]
volumeBear     = volOk
structureBear  = close < emaSlow

breakRecentDown = crossRecentDown
breakPMDown     = not na(pmLow) and crossPMDown
breakPDLDown    = crossPDLDown
breakORDown     = not na(orLow) and crossORDown

bearBreakdownTrigger = breakRecentDown or breakPMDown or breakPDLDown or breakORDown

bearScore = 
     (priceBelowVWAP ? 1 : 0) +
     (emaBear ? 1 : 0) +
     (rsiBear ? 1 : 0) +
     (macdBear ? 1 : 0) +
     (volumeBear ? 1 : 0) +
     (structureBear ? 1 : 0) +
     (bearBreakdownTrigger ? 1 : 0)

//====================================================
// FINAL A+ SIGNALS
//====================================================

htfCallOk = not useHTFConfirm or htfBull
htfPutOk  = not useHTFConfirm or htfBear

aPlusCallRaw = inRegular and bullScore >= minScore and htfCallOk
aPlusPutRaw  = inRegular and bearScore >= minScore and htfPutOk

aPlusCall = aPlusCallRaw and not aPlusCallRaw[1]
aPlusPut  = aPlusPutRaw and not aPlusPutRaw[1]

//====================================================
// CHOP / NO TRADE ZONE
//====================================================

nearVWAP = math.abs(close - vwapVal) <= atrVal * 0.15
rsiChop  = rsiVal > 45 and rsiVal < 55
emaChop  = math.abs(emaFast - emaMid) <= atrVal * 0.05

chopZone = nearVWAP and rsiChop and emaChop

//====================================================
// PLOTS
//====================================================

plot(showEMAs ? emaFast : na, "EMA 9", color=color.yellow, linewidth=1)
plot(showEMAs ? emaMid  : na, "EMA 20", color=color.orange, linewidth=1)
plot(showEMAs ? emaSlow : na, "EMA 50", color=color.purple, linewidth=1)

plot(showVWAP ? vwapVal : na, "VWAP", color=color.blue, linewidth=2)

plot(showLevels ? prevDayHigh : na, "Previous Day High", color=color.new(color.green, 30), style=plot.style_linebr)
plot(showLevels ? prevDayLow  : na, "Previous Day Low",  color=color.new(color.red, 30), style=plot.style_linebr)

plot(showLevels ? pmHigh : na, "Premarket High", color=color.new(color.green, 55), style=plot.style_linebr)
plot(showLevels ? pmLow  : na, "Premarket Low",  color=color.new(color.red, 55), style=plot.style_linebr)

plot(showLevels ? orHigh : na, "Opening Range High", color=color.new(color.lime, 20), style=plot.style_linebr)
plot(showLevels ? orLow  : na, "Opening Range Low",  color=color.new(color.maroon, 20), style=plot.style_linebr)

plotshape(
     aPlusCall,
     title="A+ CALL",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="A+ CALL",
     textcolor=color.white,
     size=size.small
)

plotshape(
     aPlusPut,
     title="A+ PUT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="A+ PUT",
     textcolor=color.white,
     size=size.small
)

//====================================================
// BACKGROUND COLOR
//====================================================

bgColor = 
     aPlusCallRaw ? color.new(color.green, 88) :
     aPlusPutRaw  ? color.new(color.red, 88) :
     chopZone     ? color.new(color.gray, 86) :
     na

bgcolor(showBg ? bgColor : na)

//====================================================
// DASHBOARD
//====================================================

var table dash = table.new(position.top_right, 2, 10, border_width=1)

f_status(row, name, condition, valueText) =>
    table.cell(dash, 0, row, name, text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, row, valueText, text_color=color.white, bgcolor=condition ? color.new(color.green, 20) : color.new(color.red, 20))

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "A+ Monitor", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, syminfo.ticker + " " + timeframe.period, text_color=color.white, bgcolor=color.black)

    f_status(1, "Price vs VWAP", priceAboveVWAP, priceAboveVWAP ? "Bullish" : priceBelowVWAP ? "Bearish" : "Neutral")
    f_status(2, "EMA Direction", emaBull, emaBull ? "Bullish" : emaBear ? "Bearish" : "Mixed")
    f_status(3, "RSI", rsiBull, str.tostring(rsiVal, "#.##"))
    f_status(4, "MACD", macdBull, macdBull ? "Bullish" : macdBear ? "Bearish" : "Mixed")
    f_status(5, "Volume", volOk, volOk ? "Above Avg" : "Weak")
    f_status(6, "Breakout", bullBreakoutTrigger, bullBreakoutTrigger ? "Break Up" : bearBreakdownTrigger ? "Break Down" : "No Trigger")
    f_status(7, "HTF Confirm", htfCallOk, useHTFConfirm ? htfBull ? "Bullish" : htfBear ? "Bearish" : "No" : "Off")
    f_status(8, "Bull Score", bullScore >= minScore, str.tostring(bullScore) + "/7")
    f_status(9, "Bear Score", bearScore >= minScore, str.tostring(bearScore) + "/7")

//====================================================
// ALERTS
//====================================================

alertcondition(
     aPlusCall,
     title="A+ CALL Setup",
     message="A+ CALL setup on {{ticker}} {{interval}}. Check option liquidity, bid/ask spread, stop loss, and target before entry."
)

alertcondition(
     aPlusPut,
     title="A+ PUT Setup",
     message="A+ PUT setup on {{ticker}} {{interval}}. Check option liquidity, bid/ask spread, stop loss, and target before entry."
)

alertcondition(
     chopZone,
     title="Chop / No Trade Zone",
     message="{{ticker}} {{interval}} is in chop zone. Avoid forcing trades."
)
````
