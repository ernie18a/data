# SAR + Supertrend + ADX Master (Indicator)

- url: https://www.tradingview.com/script/wrB7mOwB-SAR-Supertrend-ADX-Master-Indicator/
- type: indicator
- pine_id: PUB;d5b07461065649db9dc77a5c55d941c6
- version: 1.0

## Description

eth 5 min slipage 10 seems okay but neds paper not overly selective but robust trades and is profitable low draw

## Source Code

````pine
//@version=6
indicator(
     "SAR + Supertrend + ADX Master (Indicator)",
     shorttitle = "SAR ST ADX IND",
     overlay = true
)

//────────────────────────────
// INPUTS
//────────────────────────────
groupSAR   = "SAR"
groupST    = "Supertrend"
groupADX   = "ADX"
groupCHOP  = "CHOP"
groupRange = "Range Filter"
groupATR   = "ATR Filter"
groupQual  = "Signal Quality"
groupSig   = "Signal Controls"
groupDisp  = "Display"

// SAR
useSAR          = input.bool(true, "Use SAR Trigger", group=groupSAR)
sarStart        = input.float(0.02, "SAR Start", step=0.001, group=groupSAR)
sarInc          = input.float(0.02, "SAR Increment", step=0.001, group=groupSAR)
sarMax          = input.float(0.20, "SAR Max", step=0.01, group=groupSAR)
useSecondDot    = input.bool(false, "Use 2nd SAR Dot Confirmation", group=groupSAR)

// Supertrend
useSupertrend   = input.bool(true, "Use Supertrend Direction Filter", group=groupST)
stAtrLen        = input.int(10, "Supertrend ATR Length", minval=1, group=groupST)
stFactor        = input.float(3.0, "Supertrend Factor", step=0.1, group=groupST)

// ADX
useADX          = input.bool(true, "Use ADX Filter", group=groupADX)
adxLen          = input.int(14, "ADX Length", minval=1, group=groupADX)
adxThreshold    = input.float(20.0, "ADX Threshold", step=0.1, group=groupADX)
requireAdxRise  = input.bool(false, "Require ADX Rising", group=groupADX)

// CHOP
useChop         = input.bool(false, "Use CHOP Filter", group=groupCHOP)
chopLen         = input.int(14, "CHOP Length", minval=2, group=groupCHOP)
chopMax         = input.float(61.8, "Max CHOP Allowed", step=0.1, group=groupCHOP)

// Range filter
useRangeFilter  = input.bool(false, "Use Range Filter", group=groupRange)
rangeLookback   = input.int(20, "Range Lookback", minval=2, group=groupRange)
minRangePct     = input.float(1.0, "Min Range %", step=0.1, group=groupRange)

// ATR filter
useATRFilter    = input.bool(false, "Use ATR Expansion Filter", group=groupATR)
atrLen          = input.int(14, "ATR Length", minval=1, group=groupATR)
atrMaLen        = input.int(20, "ATR MA Length", minval=1, group=groupATR)
minAtrPct       = input.float(0.20, "Min ATR % of Price", step=0.01, group=groupATR)

// Trade quality
useBreakFilter  = input.bool(true, "Require Break of Prior Candle", group=groupQual)
useBodyFilter   = input.bool(false, "Require Strong Candle Body", group=groupQual)
minBodyATRMult  = input.float(0.5, "Min Body as ATR Multiple", step=0.1, group=groupQual)

// Signal controls
allowLongs      = input.bool(true, "Allow Long Signals", group=groupSig)
allowShorts     = input.bool(true, "Allow Short Signals", group=groupSig)
oneSignalPerSide = input.bool(true, "Only Fire First Signal Per Side", group=groupSig)

// Display
showSAR         = input.bool(true, "Show SAR", group=groupDisp)
showSupertrend  = input.bool(true, "Show Supertrend", group=groupDisp)
showSignals     = input.bool(true, "Show Signals", group=groupDisp)
showBg          = input.bool(true, "Show Background", group=groupDisp)

//────────────────────────────
// CORE CALCS
//────────────────────────────

// SAR
sar = ta.sar(sarStart, sarInc, sarMax)
sarBullState = close > sar
sarBearState = close < sar

sarFlipLong  = sarBullState and not sarBullState[1]
sarFlipShort = sarBearState and not sarBearState[1]

var int bullCount = 0
var int bearCount = 0
bullCount := sarBullState ? (sarBullState[1] ? bullCount[1] + 1 : 1) : 0
bearCount := sarBearState ? (sarBearState[1] ? bearCount[1] + 1 : 1) : 0

sarLongTrigger  = useSAR ? (useSecondDot ? bullCount == 2 : sarFlipLong) : true
sarShortTrigger = useSAR ? (useSecondDot ? bearCount == 2 : sarFlipShort) : true

// Supertrend
[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
superBull = stDir < 0
superBear = stDir > 0

dirLongOk  = useSupertrend ? superBull : true
dirShortOk = useSupertrend ? superBear : true

// ADX / DMI
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxRising = adx > adx[1]
adxLongOk  = useADX ? (adx > adxThreshold and (requireAdxRise ? adxRising : true)) : true
adxShortOk = useADX ? (adx > adxThreshold and (requireAdxRise ? adxRising : true)) : true

// ATR
atr = ta.atr(atrLen)
atrMa = ta.sma(atr, atrMaLen)
atrPct = (atr / close) * 100.0
atrOk = useATRFilter ? (atr > atrMa and atrPct >= minAtrPct) : true

// CHOP
sumTR = math.sum(ta.tr(true), chopLen)
hh = ta.highest(high, chopLen)
ll = ta.lowest(low, chopLen)
rng = math.max(hh - ll, syminfo.mintick)
chop = 100 * math.log10(sumTR / rng) / math.log10(chopLen)
chopOk = useChop ? (chop < chopMax) : true

// Range filter
rangeHigh = ta.highest(high, rangeLookback)
rangeLow = ta.lowest(low, rangeLookback)
rangePct = ((rangeHigh - rangeLow) / close) * 100.0
rangeOk = useRangeFilter ? (rangePct >= minRangePct) : true

// Candle quality
bullBreak = close > high[1]
bearBreak = close < low[1]
breakLongOk = useBreakFilter ? bullBreak : true
breakShortOk = useBreakFilter ? bearBreak : true

bodySize = math.abs(close - open)
bodyStrong = bodySize >= atr * minBodyATRMult
bodyLongOk = useBodyFilter ? bodyStrong : true
bodyShortOk = useBodyFilter ? bodyStrong : true

//────────────────────────────
// FINAL SIGNALS
//────────────────────────────
rawLongSignal =
     barstate.isconfirmed and
     allowLongs and
     dirLongOk and
     sarLongTrigger and
     adxLongOk and
     chopOk and
     rangeOk and
     atrOk and
     breakLongOk and
     bodyLongOk

rawShortSignal =
     barstate.isconfirmed and
     allowShorts and
     dirShortOk and
     sarShortTrigger and
     adxShortOk and
     chopOk and
     rangeOk and
     atrOk and
     breakShortOk and
     bodyShortOk

longSignal  = oneSignalPerSide ? (rawLongSignal and not rawLongSignal[1]) : rawLongSignal
shortSignal = oneSignalPerSide ? (rawShortSignal and not rawShortSignal[1]) : rawShortSignal

//────────────────────────────
// VISUALS
//────────────────────────────
plot(showSAR ? sar : na, "SAR", style=plot.style_cross, linewidth=2, color=sarBullState ? color.lime : color.red)
plot(showSupertrend ? stLine : na, "Supertrend", color=superBull ? color.green : color.red, linewidth=2)

bgBull = dirLongOk and adxLongOk and chopOk and rangeOk and atrOk
bgBear = dirShortOk and adxShortOk and chopOk and rangeOk and atrOk
bgcolor(showBg ? (bgBull ? color.new(color.green, 92) : bgBear ? color.new(color.red, 92) : na) : na)

plotshape(showSignals and longSignal, title="Long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="L")
plotshape(showSignals and shortSignal, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="S")

plot(adx, "ADX", display=display.data_window)
plot(chop, "CHOP", display=display.data_window)
plot(rangePct, "Range %", display=display.data_window)
plot(atrPct, "ATR %", display=display.data_window)

// Alerts
alertcondition(longSignal, title="Long Signal", message="Long {{ticker}} {{interval}}")
alertcondition(shortSignal, title="Short Signal", message="Short {{ticker}} {{interval}}")
````
