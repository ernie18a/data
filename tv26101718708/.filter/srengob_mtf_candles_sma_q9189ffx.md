# SRENG-OB + MTF Candles + SMA

- url: https://www.tradingview.com/script/Q9189FFx-SRENG-OB-MTF-Candles-SMA/
- type: indicator
- pine_id: PUB;82f7660153234d87964b848b4552c20d
- version: 1.0

## Description

Cambodia-ICT Macro Pro v3.0 – Professional Smart Money / ICT Toolkit for serious day traders

This indicator combines the most requested ICT/SMC concepts into one clean, high-performance overlay tool – specially tuned for 1-minute to 15-minute trading.

Main features:

• 10 predefined Macro session windows (Asian Midnight, Asian, Pre-London, London Open, London Macro, NY AM, NY Lunch, NY PM, NY Close + more)
• 7 fully customizable Killzones with your own times & colors
• Beautiful session boxes that expand in real-time + show final range & name
• Liquidity dashboard showing:
- Recent swing high/low liquidity
- Daily high/low
- Weekly high/low
- ADR 50% & 100% levels
• Liquidity sweep detection + displacement confirmation labels
• Advanced 1-minute optimized Consolidation detector (6-factor scoring)
- Range contraction
- Inside bars / overlapping candles
- Body size compression
- Trapped at key levels
- No recent displacement
- Flat EMA + visual patterns
• Micro-breakout & fakeout (wick grab) detection inside consolidations
• Liquidity Heatmap – visual strength zones based on equal highs/lows, tight ranges & price clustering
• True Move / Fakeout detector after strong displacement candles
• Inducement (low body % + big wick) lines + Equal highs/lows marking
• Real-time session behavior label (current direction, range %, expected ICT narrative)
• Beautiful tables:
- Session status overview
- Consolidation checklist (shows which factors are active)
- Liquidity distance & % table
- ADR & range statistics

Best used on:
• Forex majors & indices (especially 1 min – 5 min)
• High-liquidity sessions (London & New York)

Style & performance:
→ Clean dark theme friendly colors
→ Many elements can be turned off (heatmap, tables, labels, etc.)
→ Optimized object count – should run smoothly even on lower timeframes

Perfect for traders who follow ICT concepts (Power of 3, liquidity grabs, inducement, displacement, consolidation → expansion, session profiling, ...)

Enjoy responsible trading ✦
Not financial advice – just a visualization tool.

## Source Code

````pine
//@version=6
indicator("SRENG-OB + MTF Candles + SMA", "SRENG-OB + MTF + SMA", overlay=true, max_boxes_count=300, max_lines_count=300)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 1: SRENG-OB ORIGINAL SETTINGS (LOOSENED FOR 1MIN)
//---------------------------------------------------------------------------------------------------------------------{
length   = input.int(8, 'Swing Lookback', minval = 3, tooltip="Lower for 1min (6-10), Higher for higher TFs (20-30)")
useBody  = input(true, 'Use Candle Body')

//Sweeps
showBullSweep = input(true, 'Dynamic Bullish Sweeps', inline = 'inline1', group = 'Dynamic Sweeps')
bullSweepCss  = input(#089981, '', inline = 'inline1', group = 'Dynamic Sweeps')

showBearSweep = input(true, 'Dynamic Bearish Sweeps', inline = 'inline2', group = 'Dynamic Sweeps')
bearSweepCss  = input(#f23645, '', inline = 'inline2', group = 'Dynamic Sweeps')

//Volume & Rejection (LOOSENED)
volLength = input.int(8, "Volume SMA Length", tooltip="Lower for 1min (5-10)")
volMultiplier = input.float(1.3, "Volume Multiplier", minval = 0.1, maxval = 3.0, step = 0.1, tooltip="Lower for 1min (1.2-1.4)")
wickPercent = input.float(0.35, "Wick Percentage for Rejection", minval = 0.1, maxval = 0.9, step = 0.1, tooltip="Lower for 1min (0.3-0.4)")
minWickPct = input.float(0.04, "Minimum Wick Size (% of Range)", minval = 0.03, maxval = 0.3, step = 0.01, tooltip="Lower for 1min (0.03-0.06)")

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 2: MTF CANDLES SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
tfInput     = input.timeframe("15", "Higher Timeframe", group = "MTF Candles", tooltip="For 1min use 15 or 60")
offsetBars  = input.int(3, "Projection Offset", minval=1, group = "MTF Candles", tooltip="Lower for 1min (3-5)")

// Candle visibility
showLive    = input.bool(true,  "Show Live HTF Candle", group = "MTF Candles")
showC1      = input.bool(true,  "Show Previous 1", group = "MTF Candles")
showC2      = input.bool(true,  "Show Previous 2", group = "MTF Candles")
showC3      = input.bool(true,  "Show Previous 3", group = "MTF Candles")
showC4      = input.bool(false, "Show Previous 4", group = "MTF Candles")
showC5      = input.bool(false, "Show Previous 5", group = "MTF Candles")
showC6      = input.bool(false, "Show Previous 6", group = "MTF Candles")
showC7      = input.bool(false, "Show Previous 7", group = "MTF Candles")
showC8      = input.bool(false, "Show Previous 8", group = "MTF Candles")
showC9      = input.bool(false, "Show Previous 9", group = "MTF Candles")
showC10     = input.bool(false, "Show Previous 10", group = "MTF Candles")

// Feature toggles for MTF
showBody    = input.bool(true,  "Show Bodies", group = "MTF Candles")
showWicks   = input.bool(true,  "Show Wicks", group = "MTF Candles")
showLevels  = input.bool(false, "Show High/Low Levels", group = "MTF Candles")
showMid     = input.bool(false, "Show Midpoint (50%)", group = "MTF Candles")
showPD      = input.bool(false, "Show Premium/Discount", group = "MTF Candles")

// MTF Colors
bullColor   = color.new(color.green, 20)
bearColor   = color.new(color.red,   20)
wickColor   = color.new(color.gray,  30)
levelColor  = color.new(color.blue,  50)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 3: SMA SETTINGS (LOOSENED)
//---------------------------------------------------------------------------------------------------------------------{
smaLen = input.int(15, minval=1, title="SMA Length", group = "Simple Moving Average", tooltip="Lower for 1min (10-20)")
smaSrc = input(close, title="SMA Source", group = "Simple Moving Average")

GRP = "Smoothing MA"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected"
maTypeInput = input.string("EMA", "Smoothing Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP)
var isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(7, "Smoothing Length", group = GRP, active = maTypeInput != "None", tooltip="Lower for 1min (5-9)")
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, active = isBB)
var enableMA = maTypeInput != "None"

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 4: QUANT SCORE PARAMETERS (LOWER THRESHOLD)
//---------------------------------------------------------------------------------------------------------------------{
quantGroup = "Quant Score Settings"
signalThreshold = input.int(55, "Signal Threshold (0-100)", minval=30, maxval=90, group=quantGroup, tooltip="Lower for 1min (50-60)")
scoreStructure = input.int(8, "Structure Score", minval=0, maxval=30, group=quantGroup)
scoreOBPresence = input.int(15, "OB Presence Score", minval=0, maxval=30, group=quantGroup)
scoreOBStrength = input.int(8, "OB Strength Score", minval=0, maxval=20, group=quantGroup)
scoreRejection = input.int(15, "Rejection Score", minval=0, maxval=30, group=quantGroup)
scoreVolume = input.int(8, "Volume Score", minval=0, maxval=20, group=quantGroup)
scoreLiquiditySweep = input.int(12, "Liquidity Sweep Score", minval=0, maxval=20, group=quantGroup)
scoreTrendAlignment = input.int(10, "Trend Alignment Score", minval=0, maxval=20, group=quantGroup)
scoreSessionActive = input.int(8, "Session Active Score", minval=0, maxval=15, group=quantGroup)

atrMomentumGroup = "Predictive Momentum (Leading Indicators for 1min Scalping)"

// === LEADING INDICATORS (not lagging ATR) ===
momLookback  = input.int(3,  "Fast Momentum Lookback", minval=2, maxval=8, group=atrMomentumGroup)
slowMomLookback = input.int(8, "Slow Momentum Lookback", minval=5, maxval=14, group=atrMomentumGroup)
volumeConfirmation = input.bool(true, "Require Volume Confirmation", group=atrMomentumGroup)

//---------------------------------------------------------------------------------------------------------------------}
// UDT
//---------------------------------------------------------------------------------------------------------------------{
type ob
    float top = na
    float btm = na

type swing
    float y = na
    int   x = na
    bool  crossed = false


//---------------------------------------------------------------------------------------------------------------------}
// Functions
//---------------------------------------------------------------------------------------------------------------------{
swings(len)=>
    var os = 0
    var swing swingTop = swing.new(na, na)
    var swing swingBtm = swing.new(na, na)
    
    upper = ta.highest(len)
    lower = ta.lowest(len)

    os := high[len] > upper ? 0 : low[len] < lower ? 1 : os

    if os == 0 and os[1] != 0
        swingTop := swing.new(high[len], bar_index[len])
    
    if os == 1 and os[1] != 1
        swingBtm := swing.new(low[len], bar_index[len])

    [swingTop, swingBtm]


//---------------------------------------------------------------------------------------------------------------------}
// Detect Swings
//---------------------------------------------------------------------------------------------------------------------{
n = bar_index

[swingTop, swingBtm] = swings(length)
max = useBody ? math.max(close, open) : high
min = useBody ? math.min(close, open) : low

//---------------------------------------------------------------------------------------------------------------------}
// Bullish OB
//---------------------------------------------------------------------------------------------------------------------{
var bullish_ob = array.new<ob>()

if close > swingTop.y and not swingTop.crossed
    swingTop.crossed := true

    minima = max[1]
    maxima = min[1]

    for i = 1 to (n - swingTop.x)-1
        minima := math.min(min[i], minima)
        maxima := minima == min[i] ? max[i] : maxima

    bullish_ob.unshift(ob.new(maxima, minima))

if bullish_ob.size() > 0
    for i = bullish_ob.size()-1 to 0
        element = bullish_ob.get(i)
    
        if math.min(close, open) < element.btm
            bullish_ob.remove(i)

bull_top = bullish_ob.size() > 0 ? bullish_ob.get(0).top : na
bull_btm = bullish_ob.size() > 0 ? bullish_ob.get(0).btm : na

//---------------------------------------------------------------------------------------------------------------------}
// Bearish OB
//---------------------------------------------------------------------------------------------------------------------{
var bearish_ob = array.new<ob>()

if close < swingBtm.y and not swingBtm.crossed
    swingBtm.crossed := true

    minima = min[1]
    maxima = max[1]

    for i = 1 to (n - swingBtm.x)-1
        maxima := math.max(max[i], maxima)
        minima := maxima == max[i] ? min[i] : minima

    bearish_ob.unshift(ob.new(maxima, minima))

if bearish_ob.size() > 0
    for i = bearish_ob.size()-1 to 0
        element = bearish_ob.get(i)
 
        if math.max(close, open) > element.top
            bearish_ob.remove(i)

bear_top = bearish_ob.size() > 0 ? bearish_ob.get(0).top : na
bear_btm = bearish_ob.size() > 0 ? bearish_ob.get(0).btm : na

avg = math.avg(bear_top, bull_btm)

//---------------------------------------------------------------------------------------------------------------------}
// Plot SRENG-OB
//---------------------------------------------------------------------------------------------------------------------{
//Bull
plot_bull_top = plot(bull_top, 'Bullish OB Top', bull_btm != bull_btm[1] ? na : color.new(#089981, 100), style = plot.style_linebr)
plot_bull_btm = plot(bull_btm, 'Bullish OB Bottom', bull_btm != bull_btm[1] ? na : #089981, style = plot.style_linebr)

//Bear
plot_bear_top = plot(bear_top, 'Bearish OB Top', bear_top != bear_top[1] ? na : #f23645, style = plot.style_linebr)
plot_bear_btm = plot(bear_btm, 'Bearish OB Bottom', bear_top != bear_top[1] ? na : color.new(#f23645, 100), style = plot.style_linebr)

plot(avg, 'Average', #ff5d00, style = plot.style_linebr)

//Fills
fill(plot_bull_top, plot_bull_btm, title = 'Bullish OB Area', color = bull_btm != bull_btm[1] ? na : color.new(#089981, 80))
fill(plot_bear_top, plot_bear_btm, title = 'Bearish OB Area', color = bear_top != bear_top[1] ? na : color.new(#f23645, 80))

//Dynamic Sweeps
plotcandle(bull_btm, bull_btm, low, low, color = color(na), wickcolor = color(na), bordercolor = low < bull_btm and close > bull_btm ? bullSweepCss : color(na), display = showBullSweep ? display.all - display.status_line : display.none, editable = false)
plotcandle(bear_top, bear_top, high, high, color = color(na), wickcolor = color(na), bordercolor = high > bear_top and close < bear_top ? bearSweepCss : color(na), display = showBearSweep ? display.all - display.status_line : display.none, editable = false)

//---------------------------------------------------------------------------------------------------------------------}
// REAL VOLUME FROM GOLD FUTURES (GC1! - COMEX)
//---------------------------------------------------------------------------------------------------------------------{
futuresVol = request.security("GC1!", timeframe.period, volume)
volMA = ta.sma(futuresVol, volLength)
volRatio = futuresVol / volMA

volumeSpike = volRatio > volMultiplier
volumeAboveAvg = futuresVol > volMA * 1.03
volRising = ta.rising(futuresVol, 3)
highVolConfirmation = volumeSpike or volumeAboveAvg or volRising
highVolConfirmationBear = highVolConfirmation

// Rejection logic
bodyHigh = math.max(close, open)
bodyLow = math.min(close, open)
bodyRange = bodyHigh - bodyLow
upperWick = high - bodyHigh
lowerWick = bodyLow - low
totalRange = high - low
minWickSize = totalRange * minWickPct

bullRejection = close > open and upperWick > bodyRange * wickPercent and upperWick >= minWickSize
bearRejection = close < open and lowerWick > bodyRange * wickPercent and lowerWick >= minWickSize

// OB presence
validBullOB = not na(bull_top) and not na(bull_btm)
validBearOB = not na(bear_top) and not na(bear_btm)
nearBullOB = validBullOB and close <= bull_top and close >= bull_btm
nearBearOB = validBearOB and close <= bear_top and close >= bear_btm
bullStructure = close > swingTop.y and not na(swingTop.y)
bearStructure = close < swingBtm.y and not na(swingBtm.y)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 5: PREDICTIVE MOMENTUM SYSTEM (1min Gold → 15min Targets)
//---------------------------------------------------------------------------------------------------------------------{

// === RATE OF CHANGE (Leading) ===
rocFast = (close - close[momLookback]) / close[momLookback] * 100
rocSlow = (close - close[slowMomLookback]) / close[slowMomLookback] * 100

// === MOMENTUM DIVERGENCE (Predicts reversals BEFORE they happen) ===
bullDivergence = rocFast > rocSlow and rocFast > rocFast[1] and close < close[1]
bearDivergence = rocFast < rocSlow and rocFast < rocFast[1] and close > close[1]

// === VOLUME PRESSURE (Leading indicator) ===
volumeSMA = ta.sma(volume, 5)
volumePressure = volume / volumeSMA
bullVolumePressure = volumePressure > 1.2 and close > open
bearVolumePressure = volumePressure > 1.2 and close < open

// === ORDER FLOW IMBALANCE (Simulated for 1min) ===
bullImbalance = (close - low) > (high - close) * 1.5 and volume > volumeSMA
bearImbalance = (high - close) > (close - low) * 1.5 and volume > volumeSMA

// === ACCELERATION (Predicts momentum continuation) ===
momentum1 = close - close[1]
momentum2 = momentum1 - momentum1[1]
acceleration = momentum2 - momentum2[1]

bullAcceleration = acceleration > 0 and momentum1 > 0
bearAcceleration = acceleration < 0 and momentum1 < 0

// === EARLY ENTRY SIGNALS (Before ATR expands) ===
earlyBullSignal = (bullDivergence or bullVolumePressure or bullImbalance) and bullAcceleration
earlyBearSignal = (bearDivergence or bearVolumePressure or bearImbalance) and bearAcceleration

// === ATR Calculations (for confirmation only) ===
atrFast = ta.atr(3)
atrSlow = ta.atr(20)
atrRatio = atrFast / atrSlow

// === CONFIRMATION (After ATR confirms - for safe entries) ===
atrConfirmBull = earlyBullSignal[1] and atrRatio > 1.05
atrConfirmBear = earlyBearSignal[1] and atrRatio > 1.05

// === DYNAMIC MOMENTUM THRESHOLD ===
momStrength = (close - close[5]) / atrSlow
adaptiveThreshold = 0.3

momentumStrongBull = momStrength > adaptiveThreshold
momentumStrongBear = momStrength < -adaptiveThreshold

// === TRUE IMPULSE (Combines leading + lagging) ===
trueImpulseBull = (earlyBullSignal or momentumStrongBull) and (bullStructure or bullDivergence)
trueImpulseBear = (earlyBearSignal or momentumStrongBear) and (bearStructure or bearDivergence)

// === ATR STRENGTH (For reference only - not primary) ===
atrStrengthRaw = (atrRatio - 0.7) * 400
atrStrength = math.min(100, math.max(0, atrStrengthRaw))

atrStateCondition = atrStrength > 60 ? "EXPANDING ⚡" : atrStrength > 35 ? "ACTIVE →" : atrStrength > 15 ? "BUILDING" : "COMPRESSING"

// === VISUAL INDICATORS ===
// Momentum histogram (leading)
momentumColor = momStrength > 0 ? (momStrength > adaptiveThreshold ? color.new(#089981, 0) : color.new(#089981, 60)) : (momStrength < -adaptiveThreshold ? color.new(#f23645, 0) : color.new(#f23645, 60))

plot(momStrength, "Momentum (x ATR)", momentumColor, linewidth=2, style=plot.style_columns)

// ROC Fast line (leading)
plot(rocFast, "ROC Fast %", color.new(#089981, 70), linewidth=1, style=plot.style_line)
plot(rocSlow, "ROC Slow %", color.new(#f23645, 70), linewidth=1, style=plot.style_line)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// ATR Strength (lagging - for reference)
plot(atrStrength, "ATR Strength %", color.new(color.purple, 50), linewidth=1, style=plot.style_area)
hline(60, "Strong Expansion", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline(35, "Active", color=color.new(color.orange, 70), linestyle=hline.style_dotted)

// Early signal markers
plotshape(earlyBullSignal, "Early Bull", shape.triangleup, location.belowbar, 
          color.new(#089981, 50), size=size.tiny)
plotshape(earlyBearSignal, "Early Bear", shape.triangledown, location.abovebar, 
          color.new(#f23645, 50), size=size.tiny)



// Background for impulse
bgcolor(trueImpulseBull ? color.new(color.lime, 90) : 
        trueImpulseBear ? color.new(color.red, 90) : 
        bullDivergence ? color.new(color.green, 95) :
        bearDivergence ? color.new(color.maroon, 95) : na, 
        title="Impulse State")

// === TP PROJECTION (Dynamic based on momentum) ===
momentumFactor = math.min(2.0, math.max(0.5, math.abs(momStrength) / 0.5))

projected15minMove = atrSlow * 1.2 * momentumFactor
projectedMaxMove = atrSlow * 2.0 * momentumFactor

// === SCORING CONTRIBUTION ===
atrContribution = trueImpulseBull or trueImpulseBear ? 25 :
                  earlyBullSignal or earlyBearSignal ? 18 :
                  (math.abs(momStrength) > 0.30) ? 12 :
                  bullDivergence or bearDivergence ? 15 : 0

volumeBonus = (bullVolumePressure or bearVolumePressure) ? 8 : 0
atrContribution := atrContribution + volumeBonus

// === DIAGNOSTIC LABEL ===
if barstate.islast
    var label momentumLabel = na
    label.delete(momentumLabel)
    momentumLabel := label.new(bar_index, high + (atrSlow * 0.5),
         "Momentum: " + str.tostring(momStrength, "#.##") + "x ATR\n" +
         "ATR Ratio: " + str.tostring(atrRatio, "#.##") + "\n" +
         "15min Target: $" + str.tostring(projected15minMove, "#.##"),
         color = color.new(color.blue, 80),
         textcolor = color.white,
         style = label.style_label_left,
         size = size.small)

//---------------------------------------------------------------------------------------------------------------------}
// FULL QUANT ENGINE
//---------------------------------------------------------------------------------------------------------------------{

// OB STRENGTH
bullOBSize = bull_top - bull_btm
bearOBSize = bear_top - bear_btm

// Normalize OB strength
bullOBStrength = validBullOB ? math.min(100, (bullOBSize / atrFast) * 100) : 0
bearOBStrength = validBearOB ? math.min(100, (bearOBSize / atrFast) * 100) : 0

// LIQUIDITY SWEEP
bullSweep = low < bull_btm and close > bull_btm
bearSweep = high > bear_top and close < bear_top

// TREND FILTER (SMA)
smaOut_local = ta.sma(close, smaLen)

trendBull = close > smaOut_local
trendBear = close < smaOut_local

// SESSION FILTER (LOOSENED - more hours)
hourVal = hour(time)
sessionActive = (hourVal >= 2 and hourVal <= 23)

// 1MIN SPECIFIC FILTERS (LOOSENED)
mom = close - close[5]
momentumStrong = math.abs(mom) > ta.atr(14) * 0.35

// Range filter (LOOSENED)
rangeSize = high - low
rangeNormal = rangeSize / ta.atr(14)
isChoppy = rangeNormal < 0.25

// Quick reversal detection
quickReversal = (close[1] > open[1] and close < open) or (close[1] < open[1] and close > open)

// QUANT SCORE SYSTEM
score = 0.0

// Structure
score := score + (bullStructure or bearStructure ? scoreStructure : 0)

// OB presence
score := score + ((nearBullOB or nearBearOB) ? scoreOBPresence : 0)

// OB strength
score := score + ((bullOBStrength > 50 or bearOBStrength > 50) ? scoreOBStrength : 3)

// Rejection
score := score + ((bullRejection or bearRejection) ? scoreRejection : 0)

// Volume
score := score + ((highVolConfirmation or highVolConfirmationBear) ? scoreVolume : 0)

// Liquidity sweep
score := score + ((bullSweep or bearSweep) ? scoreLiquiditySweep : 0)

// Trend alignment
score := score + (((trendBull and bullStructure) or (trendBear and bearStructure)) ? scoreTrendAlignment : 0)

// Session timing
score := score + (sessionActive ? scoreSessionActive : 0)

// 1min specific filters
score := score + (momentumStrong ? 8 : 0)
score := score + (isChoppy ? -10 : 0)
score := score + (quickReversal ? 8 : 0)

// Add ATR contribution
score := score + atrContribution

quantScore = math.round(score)

// Signal generation with user-defined threshold
buySignal = quantScore >= signalThreshold and bullStructure and nearBullOB and trendBull
sellSignal = quantScore >= signalThreshold and bearStructure and nearBearOB and trendBear

// ENTRY GRADING
grade = "X"

if quantScore >= 80
    grade := "A+"
else if quantScore >= 70
    grade := "A"
else if quantScore >= signalThreshold
    grade := "B"
else if quantScore >= 45
    grade := "C"

// CLEAN LABEL
var label signalLabel = na

if buySignal or sellSignal
    label.delete(signalLabel)

    signalText = (buySignal ? "BUY" : "SELL") + 
                 "\nScore: " + str.tostring(quantScore) + 
                 "\nGrade: " + grade +
                 "\nTarget: $" + str.tostring(projected15minMove, "#.##")

    signalColor = buySignal ? color.new(#089981, 0) : color.new(#f23645, 0)

    signalLabel := label.new(bar_index, buySignal ? low : high,
         signalText,
         style = buySignal ? label.style_label_up : label.style_label_down,
         color = signalColor,
         textcolor = color.white,
         size = size.normal)

// Plot signals
plotshape(buySignal, "BUY", shape.triangleup, location.belowbar, color.new(#089981, 0), size=size.small)
plotshape(sellSignal, "SELL", shape.triangledown, location.abovebar, color.new(#f23645, 0), size=size.small)

// Alert conditions
alertcondition(buySignal, "Buy Signal", "Bullish OB with confirmation")
alertcondition(sellSignal, "Sell Signal", "Bearish OB with confirmation")
alertcondition(earlyBullSignal or earlyBearSignal, "Early Signal", "Early momentum signal - watch for entry")

//---------------------------------------------------------------------------------------------------------------------}
// CHECKLIST TABLE
//---------------------------------------------------------------------------------------------------------------------{
var table checklist = table.new(position.top_right, 2, 17, border_width = 1)

if barstate.islast
    table.cell(checklist, 0, 0, "CHECKLIST", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(checklist, 1, 0, "STATUS", bgcolor=color.gray, text_color=color.white, text_size=size.small)

    structureStatus = bullStructure ? "Bullish ✓" : bearStructure ? "Bearish ✓" : "Neutral"
    structureColor = bullStructure ? color.new(#089981, 70) : bearStructure ? color.new(#f23645, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 1, "Structure", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 1, structureStatus, bgcolor=structureColor, text_color=color.white, text_size=size.small)

    obStatus = nearBullOB ? "Bull OB ✓" : nearBearOB ? "Bear OB ✓" : "No"
    obColor = nearBullOB ? color.new(#089981, 70) : nearBearOB ? color.new(#f23645, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 2, "Price @ OB", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 2, obStatus, bgcolor=obColor, text_color=color.white, text_size=size.small)

    rejectionStatus = bullRejection ? "Bullish ✓" : bearRejection ? "Bearish ✓" : "None"
    rejectionColor = bullRejection ? color.new(#089981, 70) : bearRejection ? color.new(#f23645, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 3, "Rejection", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 3, rejectionStatus, bgcolor=rejectionColor, text_color=color.white, text_size=size.small)

    volRatioValue = futuresVol / volMA
    volumeStatus = volumeSpike ? "Spike! (" + str.tostring(volRatioValue, "#.0") + "x)" : 
                   volumeAboveAvg ? "Above Avg (" + str.tostring(volRatioValue, "#.1") + "x)" :
                   volRising ? "Rising ✓" :
                   "Low"
    volumeColor = (volumeSpike or volumeAboveAvg or volRising) ? color.new(#089981, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 4, "Futures Vol", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 4, volumeStatus, bgcolor=volumeColor, text_color=color.white, text_size=size.small)

    alignment = (bullStructure and nearBullOB and bullRejection and highVolConfirmation) or (bearStructure and nearBearOB and bearRejection and highVolConfirmationBear)
    alignmentColor = alignment ? color.new(#089981, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 5, "Alignment", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 5, alignment ? "YES ✓" : "NO", bgcolor=alignmentColor, text_color=color.white, text_size=size.small)

    earlySignalStatus = earlyBullSignal ? "Early Bull ⚡" : earlyBearSignal ? "Early Bear ⚡" : "None"
    earlySignalColor = earlyBullSignal ? color.new(#089981, 50) : earlyBearSignal ? color.new(#f23645, 50) : color.new(color.gray, 80)
    table.cell(checklist, 0, 6, "Early Signal", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 6, earlySignalStatus, bgcolor=earlySignalColor, text_color=color.white, text_size=size.small)

    divergenceStatus = bullDivergence ? "Bull Divergence ✓" : bearDivergence ? "Bear Divergence ✓" : "None"
    divergenceColor = bullDivergence ? color.new(#00ff00, 70) : bearDivergence ? color.new(#ff0000, 70) : color.new(color.gray, 80)
    table.cell(checklist, 0, 7, "Divergence", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 7, divergenceStatus, bgcolor=divergenceColor, text_color=color.white, text_size=size.small)

    signal = buySignal ? "BUY" : sellSignal ? "SELL" : "WAIT"
    signalColor = buySignal ? color.new(#089981, 0) : sellSignal ? color.new(#f23645, 0) : color.new(color.gray, 80)
    table.cell(checklist, 0, 8, "SIGNAL", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 8, signal, bgcolor=signalColor, text_color=color.white, text_size=size.large)
    
    table.cell(checklist, 0, 9, "Wick: " + str.tostring(wickPercent * 100) + "%", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.black, 80))
    table.cell(checklist, 1, 9, "Vol Mult: " + str.tostring(volMultiplier) + "x", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.black, 80))
    
    table.cell(checklist, 0, 10, "Min Wick: " + str.tostring(minWickPct * 100) + "%", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.black, 80))
    table.cell(checklist, 1, 10, "Vol SMA: " + str.tostring(volLength), text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.black, 80))
    
    table.cell(checklist, 0, 11, "Vol Source: GC1! Futures", text_color=color.new(#ff5d00, 0), text_size=size.tiny, bgcolor=color.new(color.black, 80))
    table.cell(checklist, 1, 11, "", bgcolor=color.new(color.black, 80))
    
    table.cell(checklist, 0, 12, "MTF TF: " + tfInput, text_color=color.new(#ff5d00, 0), text_size=size.tiny, bgcolor=color.new(color.black, 80))
    table.cell(checklist, 1, 12, "SMA Len: " + str.tostring(smaLen), text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.black, 80))
    
    table.cell(checklist, 0, 13, "Quant Score", bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(checklist, 1, 13, str.tostring(quantScore),
         bgcolor = quantScore >= 70 ? color.new(#089981, 70) :
                   quantScore >= 55 ? color.new(color.orange, 70) :
                   color.new(color.gray, 80),
         text_color=color.white)

    table.cell(checklist, 0, 14, "Grade", bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(checklist, 1, 14, grade,
         bgcolor = grade == "A+" ? color.new(#089981, 0) :
                   grade == "A"  ? color.new(#089981, 50) :
                   grade == "B"  ? color.new(color.orange, 50) :
                   color.new(color.gray, 80),
         text_color=color.white)

    table.cell(checklist, 0, 15, "ATR State", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 15, str.tostring(math.round(atrStrength)) + "% (" + atrStateCondition + ")", 
               text_color=color.white, bgcolor=atrStrength > 60 ? color.new(#089981, 0) : atrStrength > 35 ? color.new(color.orange, 0) : color.new(color.gray, 50))
    
    table.cell(checklist, 0, 16, "15min Target", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(checklist, 1, 16, "$" + str.tostring(projected15minMove, "#.##"), 
               text_color=color.white, bgcolor=color.new(color.blue, 70))

//---------------------------------------------------------------------------------------------------------------------}
// MTF CANDLES DRAWING
//---------------------------------------------------------------------------------------------------------------------{
// Fetch all 11 candles
[o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10] = request.security(syminfo.tickerid, tfInput, [open, open[1], open[2], open[3], open[4], open[5], open[6], open[7], open[8], open[9], open[10]])
[h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10] = request.security(syminfo.tickerid, tfInput, [high, high[1], high[2], high[3], high[4], high[5], high[6], high[7], high[8], high[9], high[10]])
[l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10] = request.security(syminfo.tickerid, tfInput, [low, low[1], low[2], low[3], low[4], low[5], low[6], low[7], low[8], low[9], low[10]])
[c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10] = request.security(syminfo.tickerid, tfInput, [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], close[10]])

var box[] bodies = array.new_box()
var line[] wicks = array.new_line()
var line[] levelsArr = array.new_line()
var line[] mids = array.new_line()
var box[] pds = array.new_box()
var bool needsRedraw = true

clearAllMTF() =>
    if array.size(bodies) > 0
        for i = 0 to array.size(bodies) - 1
            box.delete(array.get(bodies, i))
    if array.size(wicks) > 0
        for i = 0 to array.size(wicks) - 1
            line.delete(array.get(wicks, i))
    if array.size(levelsArr) > 0
        for i = 0 to array.size(levelsArr) - 1
            line.delete(array.get(levelsArr, i))
    if array.size(mids) > 0
        for i = 0 to array.size(mids) - 1
            line.delete(array.get(mids, i))
    if array.size(pds) > 0
        for i = 0 to array.size(pds) - 1
            box.delete(array.get(pds, i))
    array.clear(bodies)
    array.clear(wicks)
    array.clear(levelsArr)
    array.clear(mids)
    array.clear(pds)

if barstate.isnew
    clearAllMTF()
    needsRedraw := true

if barstate.isrealtime and not barstate.isconfirmed
    clearAllMTF()
    needsRedraw := true

f_draw(float o, float h, float l, float c, int shift, int candleIdx) =>
    base = bar_index + offsetBars + shift
    xOffset = candleIdx * 3
    isBull = c >= o
    top = math.max(o, c)
    bot = math.min(o, c)
    mid = (h + l) / 2.0
    
    if showBody
        b = box.new(base + xOffset, top, base + 2 + xOffset, bot, border_color=na, bgcolor=isBull ? bullColor : bearColor, extend=extend.none)
        array.push(bodies, b)
    
    if showWicks
        w1 = line.new(base + 1 + xOffset, h, base + 1 + xOffset, top, color=wickColor, width=1)
        w2 = line.new(base + 1 + xOffset, l, base + 1 + xOffset, bot, color=wickColor, width=1)
        array.push(wicks, w1)
        array.push(wicks, w2)
    
    if showLevels
        lh = line.new(bar_index, h, base + 4 + xOffset, h, color=color.new(color.red, 60), style=line.style_dashed, width=1)
        ll = line.new(bar_index, l, base + 4 + xOffset, l, color=color.new(color.green, 60), style=line.style_dashed, width=1)
        array.push(levelsArr, lh)
        array.push(levelsArr, ll)
    
    if showMid
        lm = line.new(bar_index, mid, base + 4 + xOffset, mid, color=color.new(color.yellow, 50), style=line.style_dotted, width=1)
        array.push(mids, lm)
    
    if showPD
        p1 = box.new(base + 3 + xOffset, h, base + 5 + xOffset, mid, bgcolor=color.new(color.red, 85), border_color=na)
        p2 = box.new(base + 3 + xOffset, mid, base + 5 + xOffset, l, bgcolor=color.new(color.green, 85), border_color=na)
        array.push(pds, p1)
        array.push(pds, p2)

if (barstate.islast or barstate.isrealtime) and needsRedraw
    if showLive
        f_draw(o0, h0, l0, c0, 4, 10)
    if showC1
        f_draw(o1, h1, l1, c1, 2, 9)
    if showC2
        f_draw(o2, h2, l2, c2, 0, 8)
    if showC3
        f_draw(o3, h3, l3, c3, -2, 7)
    if showC4
        f_draw(o4, h4, l4, c4, -4, 6)
    if showC5
        f_draw(o5, h5, l5, c5, -6, 5)
    if showC6
        f_draw(o6, h6, l6, c6, -8, 4)
    if showC7
        f_draw(o7, h7, l7, c7, -10, 3)
    if showC8
        f_draw(o8, h8, l8, c8, -12, 2)
    if showC9
        f_draw(o9, h9, l9, c9, -14, 1)
    if showC10
        f_draw(o10, h10, l10, c10, -16, 0)
    needsRedraw := false

if barstate.isrealtime and not barstate.isconfirmed
    needsRedraw := true

// MTF Alerts
touchHigh = (high >= h1 and low <= h1) or (high >= h2 and low <= h2) or (high >= h3 and low <= h3) or (high >= h4 and low <= h4) or (high >= h5 and low <= h5) or (high >= h6 and low <= h6) or (high >= h7 and low <= h7) or (high >= h8 and low <= h8) or (high >= h9 and low <= h9) or (high >= h10 and low <= h10)
touchLow = (high >= l1 and low <= l1) or (high >= l2 and low <= l2) or (high >= l3 and low <= l3) or (high >= l4 and low <= l4) or (high >= l5 and low <= l5) or (high >= l6 and low <= l6) or (high >= l7 and low <= l7) or (high >= l8 and low <= l8) or (high >= l9 and low <= l9) or (high >= l10 and low <= l10)

alertcondition(touchHigh, "Touch HTF High", "Price touched previous HTF high")
alertcondition(touchLow,  "Touch HTF Low",  "Price touched previous HTF low")

//---------------------------------------------------------------------------------------------------------------------}
// SIMPLE MOVING AVERAGE
//---------------------------------------------------------------------------------------------------------------------{
smaOut = ta.sma(smaSrc, smaLen)
plot(smaOut, "SMA", color=color.blue, linewidth=2, offset=0)

// Smoothing MA
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA = enableMA ? ma(smaOut, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(smaOut, maLengthInput) * bbMultInput : na
plot(smoothingMA, "Smoothing MA", color=color.yellow, display = enableMA ? display.all : display.none)
bbUpper = plot(smoothingMA + smoothingStDev, title = "Upper BB", color=color.green, display = isBB ? display.all : display.none)
bbLower = plot(smoothingMA - smoothingStDev, title = "Lower BB", color=color.green, display = isBB ? display.all : display.none)
fill(bbUpper, bbLower, color= isBB ? color.new(color.green, 90) : na, title="BB Fill", display = isBB ? display.all : display.none)
````
