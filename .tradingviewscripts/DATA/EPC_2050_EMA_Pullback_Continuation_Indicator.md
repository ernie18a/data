<!-- tradingview-pine-id: PUB;c4da2f7e63904fa3a0f686271180c6f5 -->
<!-- tradingviewscripts-format: 1 -->
# EPC 20/50 | EMA Pullback Continuation [Indicator]

Source: https://www.tradingview.com/script/wSV9lnXY-EPC-20-50-EMA-Pullback-Continuation-Indicator/

## Description

//@version=6
indicator("EPC 20/50 | EMA Pullback Continuation [Indicator]", overlay=true, max_lines_count=500, max_labels_count=500)

// ============ INPUTS ============
fastLen  = input.int(20, "Fast EMA")
slowLen  = input.int(50, "Slow EMA")
atrLen   = input.int(14, "ATR Length")
sepMult  = input.float(0.25, "EMA separation gate × ATR (anti-chop)")
slopeLB  = input.int(3, "Slope lookback (bars)")
slBuffer = input.float(2.0, "SL buffer (pts)")
atrFloor = input.float(0.8, "SL ATR floor ×")
rrTP     = input.float(3.0, "TP (R)")
rrBE     = input.float(1.0, "Breakeven trigger (R)")

lonSess = input.session("0700-1100", "London (UTC)")
nySess  = input.session("1230-1600", "New York (UTC)")
inLon = not na(time(timeframe.period, lonSess, "GMT"))
inNY  = not na(time(timeframe.period, nySess,  "GMT"))
inSession = inLon or inNY

// ============ EMAs + REGIME ============
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
atr  = ta.atr(atrLen)
sep  = math.abs(emaF - emaS)
sepOK = sep >= sepMult * atr

upSlope = emaF > emaF[slopeLB]
dnSlope = emaF < emaF[slopeLB]

// 1H alignment
htfEma = request.security(syminfo.tickerid, "60", ta.ema(close, slowLen))
htfCl  = request.security(syminfo.tickerid, "60", close)

longRegime  = emaF > emaS and upSlope and sepOK and htfCl > htfEma
shortRegime = emaF < emaS and dnSlope and sepOK and htfCl < htfEma

// ============ PULLBACK ENTRY ============
// Long: price dipped to touch fast EMA, then closes back above with bullish body
touchedUp = low <= emaF
touchedDn = high >= emaF
bullBody  = close > open
bearBody  = close < open

longEntry  = inSession and longRegime  and touchedUp and close > emaF and bullBody
shortEntry = inSession and shortRegime and touchedDn and close < emaF and bearBody

// ============ LEVELS ============
longSL  = math.min(low, low[1]) - slBuffer
shortSL = math.max(high, high[1]) + slBuffer
longDist  = math.max(close - longSL, atrFloor*atr)
shortDist = math.max(shortSL - close, atrFloor*atr)
longTP  = close + rrTP*longDist
shortTP = close - rrTP*shortDist
longBE  = close + rrBE*longDist
shortBE = close - rrBE*shortDist

// ============ PLOTS ============
plot(emaF, "EMA20", color=color.aqua, linewidth=2)
plot(emaS, "EMA50", color=color.orange, linewidth=2)
bgcolor(longRegime ? color.new(color.green,92) : shortRegime ? color.new(color.red,92) : na)
bgcolor(inSession ? color.new(color.blue,95) : na)

plotshape(longEntry,  "BUY",  shape.triangleup,   location.belowbar, color.lime, size=size.small, text="EPC▲")
plotshape(shortEntry, "SELL", shape.triangledown, location.abovebar, color.red,  size=size.small, text="EPC▼")

if longEntry
    line.new(bar_index, longSL, bar_index+12, longSL, color=color.red, width=1)
    line.new(bar_index, longTP, bar_index+12, longTP, color=color.green, width=1)
    line.new(bar_index, longBE, bar_index+12, longBE, color=color.gray, style=line.style_dotted)
    label.new(bar_index, longTP, "TP 3R", style=label.style_label_down, color=color.new(color.green,80), size=size.tiny)
if shortEntry
    line.new(bar_index, shortSL, bar_index+12, shortSL, color=color.red, width=1)
    line.new(bar_index, shortTP, bar_index+12, shortTP, color=color.green, width=1)
    line.new(bar_index, shortBE, bar_index+12, shortBE, color=color.gray, style=line.style_dotted)

alertcondition(longEntry,  "EPC Buy",  "EPC 20/50 BUY")
alertcondition(shortEntry, "EPC Sell", "EPC 20/50 SELL")

---

## Source Code

````pine
//@version=6
indicator("EPC 20/50 | EMA Pullback Continuation [Indicator]", overlay=true, max_lines_count=500, max_labels_count=500)

// ============ INPUTS ============
fastLen  = input.int(20, "Fast EMA")
slowLen  = input.int(50, "Slow EMA")
atrLen   = input.int(14, "ATR Length")
sepMult  = input.float(0.25, "EMA separation gate × ATR (anti-chop)")
slopeLB  = input.int(3, "Slope lookback (bars)")
slBuffer = input.float(2.0, "SL buffer (pts)")
atrFloor = input.float(0.8, "SL ATR floor ×")
rrTP     = input.float(3.0, "TP (R)")
rrBE     = input.float(1.0, "Breakeven trigger (R)")

lonSess = input.session("0700-1100", "London (UTC)")
nySess  = input.session("1230-1600", "New York (UTC)")
inLon = not na(time(timeframe.period, lonSess, "GMT"))
inNY  = not na(time(timeframe.period, nySess,  "GMT"))
inSession = inLon or inNY

// ============ EMAs + REGIME ============
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
atr  = ta.atr(atrLen)
sep  = math.abs(emaF - emaS)
sepOK = sep >= sepMult * atr

upSlope = emaF > emaF[slopeLB]
dnSlope = emaF < emaF[slopeLB]

// 1H alignment
htfEma = request.security(syminfo.tickerid, "60", ta.ema(close, slowLen))
htfCl  = request.security(syminfo.tickerid, "60", close)

longRegime  = emaF > emaS and upSlope and sepOK and htfCl > htfEma
shortRegime = emaF < emaS and dnSlope and sepOK and htfCl < htfEma

// ============ PULLBACK ENTRY ============
// Long: price dipped to touch fast EMA, then closes back above with bullish body
touchedUp = low <= emaF
touchedDn = high >= emaF
bullBody  = close > open
bearBody  = close < open

longEntry  = inSession and longRegime  and touchedUp and close > emaF and bullBody
shortEntry = inSession and shortRegime and touchedDn and close < emaF and bearBody

// ============ LEVELS ============
longSL  = math.min(low, low[1]) - slBuffer
shortSL = math.max(high, high[1]) + slBuffer
longDist  = math.max(close - longSL, atrFloor*atr)
shortDist = math.max(shortSL - close, atrFloor*atr)
longTP  = close + rrTP*longDist
shortTP = close - rrTP*shortDist
longBE  = close + rrBE*longDist
shortBE = close - rrBE*shortDist

// ============ PLOTS ============
plot(emaF, "EMA20", color=color.aqua, linewidth=2)
plot(emaS, "EMA50", color=color.orange, linewidth=2)
bgcolor(longRegime ? color.new(color.green,92) : shortRegime ? color.new(color.red,92) : na)
bgcolor(inSession ? color.new(color.blue,95) : na)

plotshape(longEntry,  "BUY",  shape.triangleup,   location.belowbar, color.lime, size=size.small, text="EPC▲")
plotshape(shortEntry, "SELL", shape.triangledown, location.abovebar, color.red,  size=size.small, text="EPC▼")

if longEntry
    line.new(bar_index, longSL, bar_index+12, longSL, color=color.red, width=1)
    line.new(bar_index, longTP, bar_index+12, longTP, color=color.green, width=1)
    line.new(bar_index, longBE, bar_index+12, longBE, color=color.gray, style=line.style_dotted)
    label.new(bar_index, longTP, "TP 3R", style=label.style_label_down, color=color.new(color.green,80), size=size.tiny)
if shortEntry
    line.new(bar_index, shortSL, bar_index+12, shortSL, color=color.red, width=1)
    line.new(bar_index, shortTP, bar_index+12, shortTP, color=color.green, width=1)
    line.new(bar_index, shortBE, bar_index+12, shortBE, color=color.gray, style=line.style_dotted)

alertcondition(longEntry,  "EPC Buy",  "EPC 20/50 BUY")
alertcondition(shortEntry, "EPC Sell", "EPC 20/50 SELL")
````
