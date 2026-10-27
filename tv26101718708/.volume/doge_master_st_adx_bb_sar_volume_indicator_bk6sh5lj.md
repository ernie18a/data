# DOGE Master | ST + ADX + BB + SAR + Volume (Indicator)

- url: https://www.tradingview.com/script/BK6Sh5lj-DOGE-Master-ST-ADX-BB-SAR-Volume-Indicator/
- type: indicator
- pine_id: PUB;9becec3551ca4328b5b0dd1de02fa80b
- version: 1.0

## Description

uni select 20% 5 min p&l paper not proven back test look promising slippage 5 so has resilient

## Source Code

````pine
//@version=6
indicator(
     "DOGE Master | ST + ADX + BB + SAR + Volume (Indicator)",
     shorttitle = "DOGE Master IND",
     overlay = true
)

//────────────────────────────
// INPUT GROUPS
//────────────────────────────
groupMode = "Mode"
groupST   = "Supertrend"
groupADX  = "ADX"
groupBB   = "Bollinger"
groupSAR  = "SAR"
groupVol  = "Volume"
groupATR  = "ATR Filter"
groupQual = "Signal Quality"
groupSig  = "Signal Controls"
groupDisp = "Display"

//────────────────────────────
// MODE
//────────────────────────────
mode = input.string("Band Expansion", "Bollinger Mode",
     options = ["Band Reclaim", "Band Expansion", "Basis Reclaim"],
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
// BOLLINGER
//────────────────────────────
bbLen         = input.int(20, "BB Length", minval=1, group=groupBB)
bbMult        = input.float(2.0, "BB Multiplier", step=0.1, group=groupBB)
useCloseBreak = input.bool(true, "Require Close Confirmation", group=groupBB)
useSqueeze    = input.bool(false, "Require Prior Squeeze", group=groupBB)
squeezeLen    = input.int(20, "Squeeze Lookback", minval=5, group=groupBB)
squeezePct    = input.float(5.0, "Max BB Width % For Squeeze", step=0.1, group=groupBB)

//────────────────────────────
// SAR
//────────────────────────────
useSAR           = input.bool(false, "Use SAR Validation", group=groupSAR)
sarStart         = input.float(0.02, "SAR Start", step=0.001, group=groupSAR)
sarIncrement     = input.float(0.02, "SAR Increment", step=0.001, group=groupSAR)
sarMax           = input.float(0.20, "SAR Max", step=0.01, group=groupSAR)
useSecondSarDot  = input.bool(false, "Use 2nd SAR Dot", group=groupSAR)

//────────────────────────────
// VOLUME
//────────────────────────────
useVolFilter      = input.bool(true, "Use Volume Build Filter", group=groupVol)
volLen            = input.int(20, "Volume Average Length", minval=1, group=groupVol)
volMultiplier     = input.float(1.20, "Volume Multiplier", step=0.05, group=groupVol)
requireVolUp      = input.bool(true, "Require Volume > Previous Bar", group=groupVol)
requireBullCandle = input.bool(true, "Require Bull/Bear Candle With Volume", group=groupVol)

//────────────────────────────
// ATR FILTER
//────────────────────────────
useATRFilter     = input.bool(true, "Use ATR Expansion Filter", group=groupATR)
atrLen           = input.int(14, "ATR Length", minval=1, group=groupATR)
atrMaLen         = input.int(20, "ATR MA Length", minval=1, group=groupATR)
minAtrPct        = input.float(0.35, "Min ATR % of Price", step=0.01, group=groupATR)

//────────────────────────────
// SIGNAL QUALITY
//────────────────────────────
useBreakFilter   = input.bool(true, "Require Break of Prior Candle", group=groupQual)
useBodyFilter    = input.bool(false, "Require Strong Candle Body", group=groupQual)
minBodyATRMult   = input.float(0.30, "Min Body as ATR Multiple", step=0.05, group=groupQual)

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
showBB         = input.bool(true, "Show Bollinger Bands", group=groupDisp)
showSAR        = input.bool(true, "Show SAR", group=groupDisp)
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

// Bollinger
bbBasis = ta.sma(close, bbLen)
bbDev   = ta.stdev(close, bbLen) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidthPct = ((bbUpper - bbLower) / bbBasis) * 100.0
squeezeSeen = ta.lowest(bbWidthPct, squeezeLen) <= squeezePct
squeezeOk = useSqueeze ? squeezeSeen : true

// SAR
sar = ta.sar(sarStart, sarIncrement, sarMax)
sarBullState = close > sar
sarBearState = close < sar
sarFlipLong  = sarBullState and not sarBullState[1]
sarFlipShort = sarBearState and not sarBearState[1]

var int bullCount = 0
var int bearCount = 0
bullCount := sarBullState ? (sarBullState[1] ? bullCount[1] + 1 : 1) : 0
bearCount := sarBearState ? (sarBearState[1] ? bearCount[1] + 1 : 1) : 0

sarLongOk  = useSAR ? (useSecondSarDot ? bullCount == 2 : sarFlipLong) : true
sarShortOk = useSAR ? (useSecondSarDot ? bearCount == 2 : sarFlipShort) : true

// Volume build
volMA = ta.sma(volume, volLen)
bullVolOk = useVolFilter ? (
     volume > volMA * volMultiplier and
     (requireVolUp ? volume > volume[1] : true) and
     (requireBullCandle ? close > open : true)
) : true

bearVolOk = useVolFilter ? (
     volume > volMA * volMultiplier and
     (requireVolUp ? volume > volume[1] : true) and
     (requireBullCandle ? close < open : true)
) : true

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
// MODE TRIGGERS
//────────────────────────────
bandReclaimLong  = useCloseBreak ? (close > bbBasis and low <= bbLower)  : (high > bbBasis and low <= bbLower)
bandReclaimShort = useCloseBreak ? (close < bbBasis and high >= bbUpper) : (low < bbBasis and high >= bbUpper)

bandExpandLong   = useCloseBreak ? close > bbUpper : high > bbUpper
bandExpandShort  = useCloseBreak ? close < bbLower : low < bbLower

basisReclaimLong  = close > bbBasis and close > high[1]
basisReclaimShort = close < bbBasis and close < low[1]

modeLongTrigger =
     mode == "Band Reclaim" ? bandReclaimLong :
     mode == "Band Expansion" ? bandExpandLong :
     basisReclaimLong

modeShortTrigger =
     mode == "Band Reclaim" ? bandReclaimShort :
     mode == "Band Expansion" ? bandExpandShort :
     basisReclaimShort

//────────────────────────────
// FINAL SIGNALS
//────────────────────────────
rawLongSignal =
     barstate.isconfirmed and
     allowLongs and
     dirLongOk and
     adxLongOk and
     atrOk and
     squeezeOk and
     bullVolOk and
     sarLongOk and
     breakLongOk and
     bodyLongOk and
     modeLongTrigger

rawShortSignal =
     barstate.isconfirmed and
     allowShorts and
     dirShortOk and
     adxShortOk and
     atrOk and
     squeezeOk and
     bearVolOk and
     sarShortOk and
     breakShortOk and
     bodyShortOk and
     modeShortTrigger

longSignal  = oneSignalPerSide ? (rawLongSignal and not rawLongSignal[1]) : rawLongSignal
shortSignal = oneSignalPerSide ? (rawShortSignal and not rawShortSignal[1]) : rawShortSignal

//────────────────────────────
// VISUALS
//────────────────────────────
plot(showSupertrend ? stLine : na, "Supertrend", color=superBull ? color.green : color.red, linewidth=2)
plot(showBB ? bbUpper : na, "BB Upper", color=color.orange)
plot(showBB ? bbBasis : na, "BB Basis", color=color.gray)
plot(showBB ? bbLower : na, "BB Lower", color=color.orange)
plot(showSAR ? sar : na, "SAR", style=plot.style_cross, color=color.aqua)

bgBull = dirLongOk and adxLongOk and atrOk
bgBear = dirShortOk and adxShortOk and atrOk
bgcolor(showBg ? (bgBull ? color.new(color.green, 92) : bgBear ? color.new(color.red, 92) : na) : na)

plotshape(showSignals and longSignal, title="Long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="L")
plotshape(showSignals and shortSignal, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="S")

plot(adx, "ADX", display=display.data_window)
plot(atrPct, "ATR %", display=display.data_window)
plot(bbWidthPct, "BB Width %", display=display.data_window)
plot(volMA, "Volume MA", display=display.data_window)

// Alerts
alertcondition(longSignal, title="DOGE Long Signal", message="DOGE Master LONG {{ticker}} {{interval}}")
alertcondition(shortSignal, title="DOGE Short Signal", message="DOGE Master SHORT {{ticker}} {{interval}}")
````
