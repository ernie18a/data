# Momentum Slope Navigator Strategy v1.0.2

- url: https://www.tradingview.com/script/bSGjA2Ie/
- type: strategy
- pine_id: PUB;034c0981db7542ec99de025efab85f36
- version: 2.0

## Description

📌 Momentum Slope Navigator Strategy
🔍 Overview

Momentum Slope Navigator is a systematic trading strategy built on a simple but powerful idea:

Market direction is not defined by absolute values, but by the rate of change of momentum.

Instead of relying on traditional overbought/oversold zones or static indicator thresholds, this strategy analyzes the slope (acceleration/deceleration) of a momentum oscillator derived from a Squeeze-style volatility model.

The goal is to capture early momentum shifts, while filtering out low-quality signals using trend and strength filters.

⚙️ Core Logic

The strategy is based on three layers:

1. Momentum Slope Detection (Entry Engine)

At its core, the system evaluates the directional consistency of the momentum histogram:

Long Entry
Momentum increases for N consecutive bars
(configurable: default = 2)

Short Entry
Momentum decreases for N consecutive bars

Important:

The strategy does not depend on histogram color or zero-line position
It reacts purely to momentum acceleration and deceleration

This allows earlier entries compared to traditional momentum systems.

2. Trend & Strength Filters

To improve signal quality, two optional filters are included:

📈 EMA Trend Filter
Long trades only when price is above EMA
Short trades only when price is below EMA
EMA length is fully customizable

This prevents trading against the dominant trend.

📊 ADX Strength Filter (Scientific Presets)

Instead of exposing complex ADX parameters, the strategy uses predefined scientific presets:

Soft (ADX 18) — Early trend detection
Normal (ADX 20) — Balanced filtering
Aggressive (ADX 25) — Strong trends only

This ensures usability while maintaining statistical integrity.

3. Volatility-Normalized Exit Engine

The strategy includes two exit models:

Fixed Percent Mode
Static stop-loss and trailing values
Simple and consistent

ATR-Based Mode (Recommended)

Exit levels are dynamically adjusted using volatility:

Hard Stop = ATR × multiplier
Trail Activation = ATR × multiplier
Trail Distance = ATR × multiplier

This makes the strategy:

Adaptive to different markets
Robust across timeframes
Less sensitive to parameter overfitting

📊 Strategy Behavior

This system is designed as a trend-following, asymmetric payoff model:

Lower win rate is acceptable

Profitability comes from:

Letting winners run
Cutting losses systematically

Key characteristic:

The edge is not in prediction, but in managing momentum continuation.

🧪 How to Use

Step 1 — Baseline Test
Disable all filters
Evaluate raw momentum slope performance

Step 2 — Add EMA Filter
Start with EMA 200
Adjust based on timeframe

Lower timeframes → EMA 100–200
Higher timeframes → EMA 200+

Step 3 — Add ADX Filter
Start with Normal

If too many trades → use Aggressive
If too few trades → use Soft

Step 4 — Optimize Exit Mode

Compare:

Fixed Percent → Stable, low-volatility assets
ATR Based → Volatile markets (crypto, high beta assets)

⚠️ Important Notes

This is not a reversal strategy

Works best in:

Trending environments
Expansion phases after volatility compression

Performance depends heavily on:

Market regime
Volatility conditions

🧠 Design Philosophy

This strategy is built around a key principle:

Momentum changes before price confirms direction.

By focusing on momentum slope instead of absolute levels, the system attempts to:

Enter earlier
Avoid lagging signals
Adapt across different instruments

🚀 Summary

Momentum Slope Navigator is a minimalist, systematic, and adaptive strategy designed to:

Capture early momentum shifts
Filter weak market conditions
Adapt exits to volatility

It is not optimized for one market

It is designed to be tested, validated, and understood across many

## Source Code

````pine
//@version=5
strategy("Momentum Slope Navigator Strategy v1.1.1 - Exit/Risk Layer", overlay=false, pyramiding=0, process_orders_on_close=true, initial_capital=10000, commission_type=strategy.commission.percent, commission_value=0.04, slippage=1)

// ===================== LANGUAGE =====================
lang = input.string("English", "Language / Dil", options=["English", "Türkçe"])

// ===================== CORE INPUTS =====================
length       = input.int(20, "BB Length", minval=1)
multKC       = input.float(1.5, "KC MultFactor", minval=0.1, step=0.1)
lengthKC     = input.int(20, "KC Length", minval=1)
useTrueRange = input.bool(true, "Use TrueRange / TrueRange Kullan")
tradeMode    = input.string("Both", "Trade Direction / İşlem Yönü", options=["Both", "Long Only", "Short Only"])

// ===================== ENTRY =====================
confirmBars = input.int(2, "Consecutive Histogram Bars / Ardışık Histogram Barı", minval=1, maxval=20)

// ===================== FILTERS =====================
useEMAFilter = input.bool(false, "EMA Trend Filter / EMA Trend Filtresi")
emaLength    = input.int(200, "EMA Length / EMA Uzunluğu", minval=1)

useADXFilter = input.bool(false, "ADX Strength Filter / ADX Güç Filtresi")
adxPreset    = input.string("Normal", "ADX Mode / ADX Modu", options=["Soft", "Normal", "Aggressive"])

adxLength    = 14
adxSmoothing = 14
adxThreshold = adxPreset == "Soft" ? 18.0 : adxPreset == "Normal" ? 20.0 : 25.0

// ===================== EXIT SWITCHES =====================
exitMode = input.string("Fixed Percent", "Exit Mode / Çıkış Modu", options=["Fixed Percent", "ATR Based"])

useHardStop      = input.bool(true, "Use Hard Stop / Sabit Stop Kullan")
useTrailStop     = input.bool(true, "Use Trailing Stop / Trailing Stop Kullan")
useBreakEven     = input.bool(false, "Use Break-Even / Başa Baş Kullan")
usePartialTP     = input.bool(false, "Use Partial TP / Kısmi Kar Al Kullan")
useTimeExit      = input.bool(false, "Use Time Exit / Süre Çıkışı Kullan")
useMaxStopFilter = input.bool(false, "Use Max Stop Filter / Maksimum Stop Filtresi")

maxStopAllowedPct = input.float(5.0, "Max Stop Allowed %", minval=0.1, step=0.1)

// ===================== FIXED EXIT INPUTS =====================
fixedHardStopPct     = input.float(2.0, "Fixed Hard Stop %", minval=0.1, step=0.1)
fixedActivationPct   = input.float(3.0, "Fixed Trail Activation %", minval=0.1, step=0.1)
fixedCallbackRatePct = input.float(1.0, "Fixed Trail Follow Distance %", minval=0.1, step=0.1)

fixedBreakEvenActivationPct = input.float(1.5, "Fixed Break-Even Activation %", minval=0.1, step=0.1)
fixedBreakEvenOffsetPct     = input.float(0.1, "Fixed Break-Even Offset %", minval=0.0, step=0.1)

fixedPartialTPPct = input.float(2.0, "Fixed Partial TP %", minval=0.1, step=0.1)
partialTPQtyPct   = input.float(50.0, "Partial TP Quantity %", minval=1.0, maxval=99.0, step=1.0)

timeExitBars = input.int(50, "Time Exit Bars / Süre Çıkışı Bar", minval=1)

// ===================== ATR EXIT INPUTS =====================
atrLength = input.int(14, "ATR Length", minval=1)

atrHardStopMult   = input.float(2.0, "ATR Hard Stop Mult", minval=0.1, step=0.1)
atrActivationMult = input.float(3.0, "ATR Trail Activation Mult", minval=0.1, step=0.1)
atrCallbackMult   = input.float(1.0, "ATR Trail Follow Distance Mult", minval=0.1, step=0.1)

atrBreakEvenActivationMult = input.float(1.5, "ATR Break-Even Activation Mult", minval=0.1, step=0.1)
atrBreakEvenOffsetMult     = input.float(0.1, "ATR Break-Even Offset Mult", minval=0.0, step=0.1)
atrPartialTPMult           = input.float(2.0, "ATR Partial TP Mult", minval=0.1, step=0.1)

// ===================== SQZMOM CORE =====================
source = close

basis  = ta.sma(source, length)
dev    = multKC * ta.stdev(source, length)
upperBB = basis + dev
lowerBB = basis - dev

ma = ta.sma(source, lengthKC)
priceRange = useTrueRange ? ta.tr : high - low
rangema = ta.sma(priceRange, lengthKC)

upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

sqzOn  = lowerBB > lowerKC and upperBB < upperKC
sqzOff = lowerBB < lowerKC and upperBB > upperKC
noSqz  = not sqzOn and not sqzOff

mid = math.avg(math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)), ta.sma(close, lengthKC))
val = ta.linreg(source - mid, lengthKC, 0)

// ===================== COLORS =====================
bcolor = val > 0 ? val > nz(val[1]) ? color.lime : color.green : val < nz(val[1]) ? color.red : color.maroon
scolor = noSqz ? color.blue : sqzOn ? color.black : color.gray

// ===================== SLOPE FUNCTIONS =====================
f_rising(_src, _bars) =>
    bool ok = true
    for i = 0 to _bars - 1
        ok := ok and _src[i] > _src[i + 1]
    ok

f_falling(_src, _bars) =>
    bool ok = true
    for i = 0 to _bars - 1
        ok := ok and _src[i] < _src[i + 1]
    ok

// ===================== ENTRY LOGIC =====================
risingNow  = f_rising(val, confirmBars)
fallingNow = f_falling(val, confirmBars)

risingPrev  = f_rising(val[1], confirmBars)
fallingPrev = f_falling(val[1], confirmBars)

rawLongSignal  = risingNow and not risingPrev
rawShortSignal = fallingNow and not fallingPrev

// ===================== FILTERS =====================
emaValue = ta.ema(close, emaLength)
[plusDI, minusDI, adxValue] = ta.dmi(adxLength, adxSmoothing)

emaLongOK  = not useEMAFilter or close > emaValue
emaShortOK = not useEMAFilter or close < emaValue
adxOK      = not useADXFilter or adxValue > adxThreshold

longAllowed  = tradeMode != "Short Only"
shortAllowed = tradeMode != "Long Only"

// ===================== PRE-TRADE RISK FILTER =====================
atrValue = ta.atr(atrLength)

preTradeAtrHardStopPct = atrValue / close * 100 * atrHardStopMult
preTradeHardStopPct    = exitMode == "Fixed Percent" ? fixedHardStopPct : preTradeAtrHardStopPct
stopFilterOK           = not useMaxStopFilter or preTradeHardStopPct <= maxStopAllowedPct

finalLong  = rawLongSignal and longAllowed and emaLongOK and adxOK and stopFilterOK
finalShort = rawShortSignal and shortAllowed and emaShortOK and adxOK and stopFilterOK

// ===================== ENTRIES =====================
if finalLong
    strategy.close("Short")
    strategy.entry("Long", strategy.long)

if finalShort
    strategy.close("Long")
    strategy.entry("Short", strategy.short)

// ===================== POSITION STATE =====================
entryPrice = strategy.position_avg_price
inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0

newLong  = inLong and not inLong[1]
newShort = inShort and not inShort[1]

var float highestSinceEntry = na
var float lowestSinceEntry  = na
var int entryBarIndex = na

if newLong
    highestSinceEntry := high
    lowestSinceEntry  := low
    entryBarIndex := bar_index
else if newShort
    highestSinceEntry := high
    lowestSinceEntry  := low
    entryBarIndex := bar_index
else if inLong or inShort
    highestSinceEntry := math.max(nz(highestSinceEntry, high), high)
    lowestSinceEntry  := math.min(nz(lowestSinceEntry, low), low)
else
    highestSinceEntry := na
    lowestSinceEntry  := na
    entryBarIndex := na

barsInTrade = not na(entryBarIndex) ? bar_index - entryBarIndex : na

// ===================== ACTIVE EXIT VALUES =====================
atrHardStopPct   = entryPrice != 0 ? atrValue / entryPrice * 100 * atrHardStopMult : na
atrActivationPct = entryPrice != 0 ? atrValue / entryPrice * 100 * atrActivationMult : na
atrCallbackPct   = entryPrice != 0 ? atrValue / entryPrice * 100 * atrCallbackMult : na

atrBreakEvenActivationPct = entryPrice != 0 ? atrValue / entryPrice * 100 * atrBreakEvenActivationMult : na
atrBreakEvenOffsetPct     = entryPrice != 0 ? atrValue / entryPrice * 100 * atrBreakEvenOffsetMult : na
atrPartialTPPct           = entryPrice != 0 ? atrValue / entryPrice * 100 * atrPartialTPMult : na

hardStopPct     = exitMode == "Fixed Percent" ? fixedHardStopPct : atrHardStopPct
activationPct   = exitMode == "Fixed Percent" ? fixedActivationPct : atrActivationPct
callbackRatePct = exitMode == "Fixed Percent" ? fixedCallbackRatePct : atrCallbackPct

breakEvenActivationPct = exitMode == "Fixed Percent" ? fixedBreakEvenActivationPct : atrBreakEvenActivationPct
breakEvenOffsetPct     = exitMode == "Fixed Percent" ? fixedBreakEvenOffsetPct : atrBreakEvenOffsetPct
partialTPPct           = exitMode == "Fixed Percent" ? fixedPartialTPPct : atrPartialTPPct

// ===================== BREAK-EVEN =====================
longBEActive  = inLong and useBreakEven and highestSinceEntry >= entryPrice * (1 + breakEvenActivationPct / 100)
shortBEActive = inShort and useBreakEven and lowestSinceEntry <= entryPrice * (1 - breakEvenActivationPct / 100)

longHardStopPrice  = entryPrice * (1 - hardStopPct / 100)
shortHardStopPrice = entryPrice * (1 + hardStopPct / 100)

longBEStopPrice  = entryPrice * (1 + breakEvenOffsetPct / 100)
shortBEStopPrice = entryPrice * (1 - breakEvenOffsetPct / 100)

longProtectiveStop  = useHardStop ? longHardStopPrice : na
shortProtectiveStop = useHardStop ? shortHardStopPrice : na

longFinalStop  = longBEActive ? math.max(nz(longProtectiveStop, longBEStopPrice), longBEStopPrice) : longProtectiveStop
shortFinalStop = shortBEActive ? math.min(nz(shortProtectiveStop, shortBEStopPrice), shortBEStopPrice) : shortProtectiveStop

// ===================== PARTIAL TP =====================
if inLong and usePartialTP
    strategy.exit("Long Partial TP", from_entry="Long", qty_percent=partialTPQtyPct, limit=entryPrice * (1 + partialTPPct / 100))

if inShort and usePartialTP
    strategy.exit("Short Partial TP", from_entry="Short", qty_percent=partialTPQtyPct, limit=entryPrice * (1 - partialTPPct / 100))

// ===================== PROTECTIVE EXITS =====================
if inLong
    if useTrailStop
        strategy.exit("Long Protective Trail", from_entry="Long", stop=longFinalStop, trail_price=entryPrice * (1 + activationPct / 100), trail_offset=entryPrice * (callbackRatePct / 100))
    else
        strategy.exit("Long Protective Stop", from_entry="Long", stop=longFinalStop)

if inShort
    if useTrailStop
        strategy.exit("Short Protective Trail", from_entry="Short", stop=shortFinalStop, trail_price=entryPrice * (1 - activationPct / 100), trail_offset=entryPrice * (callbackRatePct / 100))
    else
        strategy.exit("Short Protective Stop", from_entry="Short", stop=shortFinalStop)

// ===================== TIME EXIT =====================
if useTimeExit and inLong and barsInTrade >= timeExitBars
    strategy.close("Long", comment="Long Time Exit")

if useTimeExit and inShort and barsInTrade >= timeExitBars
    strategy.close("Short", comment="Short Time Exit")

// ===================== PLOTS =====================
plot(val, color=bcolor, style=plot.style_histogram, linewidth=4)
plot(0, color=scolor, style=plot.style_cross, linewidth=2)

plotshape(finalLong, title="Long Signal", style=shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny, text="L")
plotshape(finalShort, title="Short Signal", style=shape.triangledown, location=location.top, color=color.red, size=size.tiny, text="S")

plotshape(longBEActive, title="Long BE Active", style=shape.circle, location=location.bottom, color=color.new(color.lime, 0), size=size.tiny, text="BE")
plotshape(shortBEActive, title="Short BE Active", style=shape.circle, location=location.top, color=color.new(color.red, 0), size=size.tiny, text="BE")
````
