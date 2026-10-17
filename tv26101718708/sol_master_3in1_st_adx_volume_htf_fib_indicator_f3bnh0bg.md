# SOL Master 3-in-1 | ST + ADX + Volume + HTF Fib (Indicator)

- url: https://www.tradingview.com/script/f3Bnh0bg-SOL-Master-3-in-1-ST-ADX-Volume-HTF-Fib-Indicator/
- type: indicator
- pine_id: PUB;d7ea8cdc5b88437ab4f2f82b0f79d673
- version: 1.0

## Description

sol master 5/1 right settings on a 5 min show a 52% win rate dose this prove anything not until time runs its course slipage 10 resiliant

## Source Code

````pine
//@version=6
indicator(
     "SOL Master 3-in-1 | ST + ADX + Volume + HTF Fib (Indicator)",
     shorttitle = "SOL Master 3in1 IND",
     overlay = true
)

//────────────────────────────
// INPUT GROUPS
//────────────────────────────
groupMode   = "Mode"
groupST     = "Supertrend"
groupADX    = "ADX"
groupVol    = "Volume"
groupFib    = "HTF Fib"
groupDC     = "Donchian"
groupPB     = "Pullback"
groupKC     = "Keltner"
groupATR    = "ATR Filter"
groupQual   = "Signal Quality"
groupSig    = "Signal Controls"
groupDisp   = "Display"

//────────────────────────────
// MODE
//────────────────────────────
mode = input.string("Donchian Breakout", "Strategy Mode",
     options = ["Donchian Breakout", "Pullback Continuation", "Keltner Expansion"],
     group = groupMode)

//────────────────────────────
// SUPERTREND
//────────────────────────────
useSupertrend = input.bool(true, "Use Supertrend Direction Filter", group=groupST)
stAtrLen      = input.int(14, "Supertrend ATR Length", minval=1, group=groupST)
stFactor      = input.float(3.5, "Supertrend Factor", step=0.1, group=groupST)

//────────────────────────────
// ADX
//────────────────────────────
useADX        = input.bool(true, "Use ADX Strength Filter", group=groupADX)
adxLen        = input.int(14, "ADX Length", minval=1, group=groupADX)
adxThreshold  = input.float(20.0, "ADX Threshold", step=0.1, group=groupADX)
requireADXUp  = input.bool(false, "Require ADX Rising", group=groupADX)

//────────────────────────────
// VOLUME
//────────────────────────────
useVolFilter  = input.bool(true, "Use Volume Build Filter", group=groupVol)
volLen        = input.int(20, "Volume Average Length", minval=1, group=groupVol)
volMult       = input.float(1.10, "Volume Multiplier", step=0.05, group=groupVol)
requireVolUp  = input.bool(true, "Require Volume > Previous Bar", group=groupVol)

//────────────────────────────
// HTF FIB
//────────────────────────────
useFibFilter  = input.bool(true, "Use HTF Fib Zone Filter", group=groupFib)
fibTF         = input.timeframe("15", "Fib Higher Timeframe", group=groupFib)
fibLookback   = input.int(20, "Fib Swing Lookback (HTF Bars)", minval=2, group=groupFib)
fibLongMin    = input.float(0.50, "Long Zone Min Retrace", step=0.01, group=groupFib)
fibLongMax    = input.float(0.618, "Long Zone Max Retrace", step=0.001, group=groupFib)
fibShortMin   = input.float(0.50, "Short Zone Min Retrace", step=0.01, group=groupFib)
fibShortMax   = input.float(0.618, "Short Zone Max Retrace", step=0.001, group=groupFib)
fibTouchBars  = input.int(3, "Allow Fib Touch Within Last N Bars", minval=1, group=groupFib)

//────────────────────────────
// DONCHIAN
//────────────────────────────
useCloseBreak = input.bool(true, "Require Close Beyond Donchian", group=groupDC)
dcLen         = input.int(20, "Donchian Length", minval=2, group=groupDC)

//────────────────────────────
// PULLBACK
//────────────────────────────
pbFastLen     = input.int(20, "Pullback Fast EMA", minval=1, group=groupPB)
pbSlowLen     = input.int(50, "Pullback Slow EMA", minval=1, group=groupPB)
pullbackBars  = input.int(3, "Pullback Lookback Bars", minval=1, group=groupPB)

//────────────────────────────
// KELTNER
//────────────────────────────
kcLen         = input.int(20, "Keltner EMA Length", minval=1, group=groupKC)
kcAtrLen      = input.int(20, "Keltner ATR Length", minval=1, group=groupKC)
kcMult        = input.float(1.5, "Keltner Multiplier", step=0.1, group=groupKC)

//────────────────────────────
// ATR FILTER
//────────────────────────────
useATRFilter  = input.bool(true, "Use ATR Expansion Filter", group=groupATR)
atrLen        = input.int(14, "ATR Length", minval=1, group=groupATR)
atrMaLen      = input.int(20, "ATR MA Length", minval=1, group=groupATR)
minAtrPct     = input.float(0.30, "Min ATR % of Price", step=0.01, group=groupATR)

//────────────────────────────
// SIGNAL QUALITY
//────────────────────────────
useBreakFilter = input.bool(true, "Require Break of Prior Candle", group=groupQual)
useBodyFilter  = input.bool(false, "Require Strong Candle Body", group=groupQual)
minBodyATRMult = input.float(0.30, "Min Body as ATR Multiple", step=0.05, group=groupQual)

//────────────────────────────
// SIGNAL CONTROLS
//────────────────────────────
allowLongs       = input.bool(true, "Allow Long Signals", group=groupSig)
allowShorts      = input.bool(true, "Allow Short Signals", group=groupSig)
oneSignalPerSide = input.bool(true, "Only Fire First Signal Per Side", group=groupSig)

//────────────────────────────
// DISPLAY
//────────────────────────────
showSupertrend = input.bool(true, "Show Supertrend", group=groupDisp)
showFibZone    = input.bool(true, "Show Fib Zone", group=groupDisp)
showDonchian   = input.bool(true, "Show Donchian", group=groupDisp)
showKeltner    = input.bool(false, "Show Keltner", group=groupDisp)
showSignals    = input.bool(true, "Show Signals", group=groupDisp)
showBg         = input.bool(true, "Show Background", group=groupDisp)

//────────────────────────────
// CORE CALCS
//────────────────────────────

// Supertrend
[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
superBull = stDir < 0
superBear = stDir > 0
dirLongOk  = useSupertrend ? superBull : true
dirShortOk = useSupertrend ? superBear : true

// ADX
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxRising = adx > adx[1]
adxLongOk  = useADX ? (adx > adxThreshold and (requireADXUp ? adxRising : true)) : true
adxShortOk = useADX ? (adx > adxThreshold and (requireADXUp ? adxRising : true)) : true

// ATR
atr = ta.atr(atrLen)
atrMa = ta.sma(atr, atrMaLen)
atrPct = (atr / close) * 100.0
atrOk = useATRFilter ? (atr > atrMa and atrPct >= minAtrPct) : true

// Volume build
volMA = ta.sma(volume, volLen)
bullVolOk = useVolFilter ? (volume > volMA * volMult and close > open and (requireVolUp ? volume > volume[1] : true)) : true
bearVolOk = useVolFilter ? (volume > volMA * volMult and close < open and (requireVolUp ? volume > volume[1] : true)) : true

// Candle quality
bullBreak = close > high[1]
bearBreak = close < low[1]
breakLongOk  = useBreakFilter ? bullBreak : true
breakShortOk = useBreakFilter ? bearBreak : true

bodySize = math.abs(close - open)
bodyStrong = bodySize >= atr * minBodyATRMult
bodyLongOk  = useBodyFilter ? bodyStrong : true
bodyShortOk = useBodyFilter ? bodyStrong : true

//────────────────────────────
// HTF FIB LOGIC
//────────────────────────────
htfHigh = request.security(syminfo.tickerid, fibTF, ta.highest(high, fibLookback)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfLow  = request.security(syminfo.tickerid, fibTF, ta.lowest(low, fibLookback)[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfRange = math.max(htfHigh - htfLow, syminfo.mintick)

// Bullish fib pullback zone
fibBullUpper = htfHigh - htfRange * fibLongMin
fibBullLower = htfHigh - htfRange * fibLongMax

// Bearish fib pullback zone
fibBearLower = htfLow + htfRange * fibShortMin
fibBearUpper = htfLow + htfRange * fibShortMax

inBullFibZone = close >= fibBullLower and close <= fibBullUpper
inBearFibZone = close >= fibBearLower and close <= fibBearUpper

bullFibTouched = ta.barssince(inBullFibZone) <= fibTouchBars - 1
bearFibTouched = ta.barssince(inBearFibZone) <= fibTouchBars - 1

fibLongOk  = useFibFilter ? bullFibTouched : true
fibShortOk = useFibFilter ? bearFibTouched : true

//────────────────────────────
// MODE-SPECIFIC TRIGGERS
//────────────────────────────

// 1) Donchian breakout
dcHigh = ta.highest(high, dcLen)
dcLow  = ta.lowest(low, dcLen)
prevDcHigh = dcHigh[1]
prevDcLow  = dcLow[1]

donchianLong = useCloseBreak ? close > prevDcHigh : high > prevDcHigh
donchianShort = useCloseBreak ? close < prevDcLow : low < prevDcLow

// 2) Pullback continuation
emaFast = ta.ema(close, pbFastLen)
emaSlow = ta.ema(close, pbSlowLen)

bullPullbackSeen = ta.lowest(low, pullbackBars) <= emaFast
bearPullbackSeen = ta.highest(high, pullbackBars) >= emaFast

pullbackLong = emaFast > emaSlow and bullPullbackSeen and close > high[1]
pullbackShort = emaFast < emaSlow and bearPullbackSeen and close < low[1]

// 3) Keltner expansion
kcBasis = ta.ema(close, kcLen)
kcAtr = ta.atr(kcAtrLen)
kcUpper = kcBasis + kcAtr * kcMult
kcLower = kcBasis - kcAtr * kcMult

keltnerLong = close > kcUpper and close > high[1]
keltnerShort = close < kcLower and close < low[1]

// Mode selection
modeLongTrigger =
     mode == "Donchian Breakout" ? donchianLong :
     mode == "Pullback Continuation" ? pullbackLong :
     keltnerLong

modeShortTrigger =
     mode == "Donchian Breakout" ? donchianShort :
     mode == "Pullback Continuation" ? pullbackShort :
     keltnerShort

//────────────────────────────
// FINAL SIGNALS
//────────────────────────────
rawLongSignal =
     barstate.isconfirmed and
     allowLongs and
     dirLongOk and
     adxLongOk and
     atrOk and
     bullVolOk and
     fibLongOk and
     breakLongOk and
     bodyLongOk and
     modeLongTrigger

rawShortSignal =
     barstate.isconfirmed and
     allowShorts and
     dirShortOk and
     adxShortOk and
     atrOk and
     bearVolOk and
     fibShortOk and
     breakShortOk and
     bodyShortOk and
     modeShortTrigger

longSignal  = oneSignalPerSide ? (rawLongSignal and not rawLongSignal[1]) : rawLongSignal
shortSignal = oneSignalPerSide ? (rawShortSignal and not rawShortSignal[1]) : rawShortSignal

//────────────────────────────
// VISUALS
//────────────────────────────
plot(showSupertrend ? stLine : na, "Supertrend", color=superBull ? color.green : color.red, linewidth=2)

plot(showFibZone and dirLongOk ? fibBullUpper : na, "Bull Fib Upper", color=color.new(color.green, 40))
plot(showFibZone and dirLongOk ? fibBullLower : na, "Bull Fib Lower", color=color.new(color.green, 40))
plot(showFibZone and dirShortOk ? fibBearUpper : na, "Bear Fib Upper", color=color.new(color.red, 40))
plot(showFibZone and dirShortOk ? fibBearLower : na, "Bear Fib Lower", color=color.new(color.red, 40))

plot(showDonchian and mode == "Donchian Breakout" ? prevDcHigh : na, "Donchian High", color=color.orange)
plot(showDonchian and mode == "Donchian Breakout" ? prevDcLow : na, "Donchian Low", color=color.orange)

plot(showKeltner and mode == "Keltner Expansion" ? kcUpper : na, "KC Upper", color=color.aqua)
plot(showKeltner and mode == "Keltner Expansion" ? kcLower : na, "KC Lower", color=color.aqua)
plot(showKeltner and mode == "Keltner Expansion" ? kcBasis : na, "KC Basis", color=color.gray)

bgBull = dirLongOk and adxLongOk and atrOk
bgBear = dirShortOk and adxShortOk and atrOk
bgcolor(showBg ? (bgBull ? color.new(color.green, 92) : bgBear ? color.new(color.red, 92) : na) : na)

plotshape(showSignals and longSignal, title="Long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="L")
plotshape(showSignals and shortSignal, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="S")

plot(adx, "ADX", display=display.data_window)
plot(atrPct, "ATR %", display=display.data_window)
plot(volMA, "Volume MA", display=display.data_window)
plot(htfHigh, "HTF Fib High", display=display.data_window)
plot(htfLow, "HTF Fib Low", display=display.data_window)

// Alerts
alertcondition(longSignal, title="SOL Long Signal", message="SOL Master LONG {{ticker}} {{interval}}")
alertcondition(shortSignal, title="SOL Short Signal", message="SOL Master SHORT {{ticker}} {{interval}}")
````
