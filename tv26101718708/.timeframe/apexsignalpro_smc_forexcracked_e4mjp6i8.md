# ApexSignalPro SMC [ForexCracked]

- url: https://www.tradingview.com/script/E4mJP6i8-ApexSignalPro-SMC-ForexCracked/
- type: indicator
- pine_id: PUB;2282e1f33e9e4acebf40c1b4532a7c07
- version: 1.0

## Description

🔵 OVERVIEW

ApexSignalPro SMC is a confluence-scored Smart Money Concepts indicator that fires a signal only when multiple institutional footprints align on the same bar. Every signal carries a live score from 0 to 5 showing how many structural conditions agree — market structure, order blocks, fair value gaps, premium/discount location, and higher-timeframe bias.

Instead of the "every crossover is a signal" approach, it uses a strict confluence gate, a range-regime filter, and forced signal alternation — far fewer signals, much higher conviction. A live dashboard shows the score, active zones, and the last trade plan at a glance.

🔵 WHY THESE COMPONENTS ARE COMBINED

A break of structure alone, an order-block touch alone, or a single fair value gap all fire often and fail often. They become far more reliable when they occur together and agree with the higher-timeframe trend. Rather than overlaying five separate tools and leaving you to judge them, this script quantifies their agreement into one 0–5 score and only trades when enough align. Three principles guide it: 
• Direction comes from market structure (BOS / CHoCH), not from price crossing smoothed averages 
• Entries require confluence, never a single condition 
• Signals alternate (BUY → SELL → BUY), never stacking the same direction in one leg

🔵 THE FIVE SCORED FACTORS (1 point each) 
1️⃣ Market structure (BOS / CHoCH) points in the signal direction
2️⃣ Price is inside an unmitigated order block
3️⃣ Price is inside an unmitigated fair value gap 
4️⃣ Correct half of the range — discount for longs, premium for shorts 
5️⃣ Higher-timeframe EMA bias agrees

🔵 HOW A SIGNAL FIRES A BUY or SELL prints only when ALL of these are true: 
• The confluence score meets your minimum (default 3 of 5) 
• A strong-bodied candle closes in that direction 
• The ADX regime filter confirms trending, not ranging 
• The signal is opposite the previous one (forced alternation) Each signal draws Entry, Stop (beyond the nearest order block + ATR buffer), and Take Profit (configurable R:R), with pip labels.

🔵 HOW IT READS THE MARKET 
• Market structure — confirmed swing pivots; a close beyond the last pivot is a BOS, the first break against structure is a CHoCH that flips the state 
• Order blocks — the last opposing candle before an impulsive displacement (body > 1.2× ATR); tracked until mitigated or aged out 
• Fair value gaps — three-candle imbalances filtered by a minimum ATR size; removed when filled 
• Premium / discount — the swing-range midpoint splits discount (below) from premium (above) • Regime — ADX must exceed your minimum, suppressing signals in flat ranges

🔵 HOW TO USE 
• Favour score 4–5 signals; treat score 3 with extra confirmation 
• Require the dashboard HTF bias to match the signal for trend-aligned entries 
• Use retests of unmitigated OBs or FVGs in the trend direction as continuation entries 
• Size each trade off the drawn stop distance at a fixed account risk 
• Raise Min Confluences to 4 for fewer, stronger signals

🔵 RECOMMENDED SETTINGS 
• Swing Length: 5 
• Higher Timeframe: 240 (H4) on H1 charts, D on H4 charts 
• HTF EMA: 50 · OB Max Age: 20 · FVG Min Size: 0.3× ATR 
• ADX Min: 22 · Min Confluences: 3 · SL Buffer: 0.5× ATR · R:R: 2.0

🔵 BEST / WEAKEST CONDITIONS ✅ Trending majors, gold, and indices on H1–H4; London / New York overlap ⚠️ Low-volatility ranges, gapped markets, and sub-5-minute noise

⚠️ DISCLAIMER ApexSignalPro SMC structures signals from Smart Money Concepts. It does not predict future price movement. Results depend on market conditions, settings, and your own execution and risk management. Shared for educational and research purposes; not financial advice.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ForexCracked

//@version=6
// =============================================================================
// ApexSignalPro SMC - Confluence-Scored Smart Money Concepts
//
// A confluence-scored institutional-structure indicator. A signal fires only
// when multiple Smart Money Concepts footprints align on the same bar, and the
// script grades how many agree from 0 to 5 so marginal setups are filtered out:
//   1. BOS / CHoCH    - market structure confirmed in the signal direction
//   2. Order Block    - price inside a valid unmitigated OB
//   3. Fair Value Gap - price inside an unfilled FVG
//   4. Premium/Discount - BUYs only in discount, SELLs only in premium
//   5. HTF Trend      - higher-timeframe EMA bias aligns with the signal
//   6. ADX Regime     - market must be trending, not ranging
//
// A signal fires only when the confluence score meets your minimum threshold, a
// strong-bodied confirmation candle closes in that direction, the ADX regime
// filter passes, and the new signal is opposite the previous one (forced
// alternation). Stop loss is placed beyond the relevant order block with an ATR
// buffer; take profit is a configurable risk-to-reward multiple.
//
// Educational tool. Not financial advice.
// =============================================================================
indicator("ApexSignalPro SMC [ForexCracked]", shorttitle="ApexSMC [FXC]", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================== INPUTS =======================================
grpStruct = "Market Structure"
swingLen  = input.int(5, "Swing Length", minval=2, maxval=30, group=grpStruct,
     tooltip="Pivot lookback. 5 is good for H1/H4. Higher = fewer, stronger swings.")
htfTrend  = input.timeframe("240", "Higher Timeframe Trend", group=grpStruct,
     tooltip="Used for HTF bias filter. Default 4H. Use D for H4/H1 charts.")
htfEMAper = input.int(50, "HTF EMA Period", minval=10, maxval=200, group=grpStruct)

grpOB  = "Order Blocks"
obLookback = input.int(20, "OB Max Age (bars)", minval=5, maxval=100, group=grpOB,
     tooltip="Maximum bars an unmitigated OB stays valid.")
obBufferATR = input.float(0.5, "OB Proximity (ATR)", minval=0.1, maxval=3.0, step=0.1, group=grpOB,
     tooltip="How close price must be to an OB to count as 'in zone'.")

grpFVG = "Fair Value Gaps"
fvgMaxAge = input.int(20, "FVG Max Age (bars)", minval=5, maxval=100, group=grpFVG)
fvgMinSize = input.float(0.3, "Min FVG Size (ATR)", minval=0.1, maxval=2.0, step=0.1, group=grpFVG,
     tooltip="Filters out tiny noise FVGs.")

grpFilter = "Regime Filters"
useADX    = input.bool(true,  "ADX regime filter", group=grpFilter)
adxPer    = input.int(14, "ADX Period", group=grpFilter)
adxMin    = input.float(22, "Min ADX", minval=10, maxval=40, step=1, group=grpFilter)

grpQuality = "Signal Quality"
minConfluence = input.int(3, "Min Confluences to Fire (of 5)", minval=2, maxval=5, group=grpQuality,
     tooltip="3 = balanced. 4 = very selective. 5 = extremely rare but highest quality.")

grpRisk = "Risk Management"
atrPer  = input.int(14,   "ATR Period",  group=grpRisk)
slBufferATR = input.float(0.5, "SL Buffer (ATR)", minval=0.0, maxval=2.0, step=0.1, group=grpRisk,
     tooltip="SL placed this many ATRs BEYOND the OB low/high, to survive wick hunts.")
rrRatio = input.float(2.0, "Risk:Reward", step=0.1, group=grpRisk)

grpDisp = "Display"
showOB   = input.bool(true, "Show Order Blocks",       group=grpDisp)
showFVG  = input.bool(true, "Show Fair Value Gaps",    group=grpDisp)
showPD   = input.bool(true, "Show Premium/Discount",   group=grpDisp)
showDash = input.bool(true, "Show Dashboard",          group=grpDisp)
dashPos  = input.string("top_right", "Dashboard Position",
     options=["top_left","top_right","bottom_left","bottom_right","middle_right"], group=grpDisp)
buyColor   = input.color(#16a34a, "Buy Color",   group=grpDisp)
sellColor  = input.color(#dc2626, "Sell Color",  group=grpDisp)
obBullCol  = input.color(color.new(#16a34a, 75), "Bull OB",  group=grpDisp)
obBearCol  = input.color(color.new(#dc2626, 75), "Bear OB",  group=grpDisp)
fvgBullCol = input.color(color.new(#60a5fa, 80), "Bull FVG", group=grpDisp)
fvgBearCol = input.color(color.new(#f59e0b, 80), "Bear FVG", group=grpDisp)

// ============================ PIP SIZE =======================================
pipSize = (syminfo.mintick == 0.00001 or syminfo.mintick == 0.001) ? syminfo.mintick * 10 : syminfo.mintick

// =========================== INDICATORS ======================================
atr = ta.atr(atrPer)

[_diP, _diM, adxVal] = ta.dmi(adxPer, adxPer)
adxOk = useADX ? adxVal >= adxMin : true

// HTF trend EMA - request.security for higher-timeframe bias
htfClose = request.security(syminfo.tickerid, htfTrend, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEMA   = request.security(syminfo.tickerid, htfTrend, ta.ema(close, htfEMAper), barmerge.gaps_off, barmerge.lookahead_off)
htfBullish = htfClose > htfEMA
htfBearish = htfClose < htfEMA

// ======================= SWING PIVOTS (for structure) =======================
pivHigh = ta.pivothigh(high, swingLen, swingLen)
pivLow  = ta.pivotlow (low,  swingLen, swingLen)

var float lastPivHigh    = na
var int   lastPivHighBar = na
var float lastPivLow     = na
var int   lastPivLowBar  = na
var float prevPivHigh    = na
var float prevPivLow     = na

if not na(pivHigh)
    prevPivHigh    := lastPivHigh
    lastPivHigh    := pivHigh
    lastPivHighBar := bar_index - swingLen
if not na(pivLow)
    prevPivLow    := lastPivLow
    lastPivLow    := pivLow
    lastPivLowBar := bar_index - swingLen

// =================== BOS / CHoCH: STRUCTURE DIRECTION =======================
var int structureDir = 0

bullBOS  = not na(lastPivHigh) and close > lastPivHigh and close[1] <= lastPivHigh
bearBOS  = not na(lastPivLow)  and close < lastPivLow  and close[1] >= lastPivLow

bullCHoCH = bullBOS and structureDir != 1
bearCHoCH = bearBOS and structureDir != -1

if bullBOS
    structureDir := 1
if bearBOS
    structureDir := -1

// ======================= ORDER BLOCK DETECTION ==============================
displacementUp   = close - open > atr * 1.2 and close > open
displacementDown = open - close > atr * 1.2 and close < open

var box[]   bullOBs      = array.new_box()
var float[] bullOBHighs  = array.new_float()
var float[] bullOBLows   = array.new_float()
var int[]   bullOBBars   = array.new_int()

var box[]   bearOBs      = array.new_box()
var float[] bearOBHighs  = array.new_float()
var float[] bearOBLows   = array.new_float()
var int[]   bearOBBars   = array.new_int()

if displacementUp and bullBOS
    for lookback = 1 to 10
        if close[lookback] < open[lookback]
            obHigh = high[lookback]
            obLow  = low[lookback]
            obBar  = bar_index - lookback
            if showOB
                newOB = box.new(obBar, obHigh, bar_index + 20, obLow,
                     border_color=color.new(#16a34a, 50), bgcolor=obBullCol, border_width=1)
                array.push(bullOBs, newOB)
            array.push(bullOBHighs, obHigh)
            array.push(bullOBLows, obLow)
            array.push(bullOBBars, obBar)
            break

if displacementDown and bearBOS
    for lookback = 1 to 10
        if close[lookback] > open[lookback]
            obHigh = high[lookback]
            obLow  = low[lookback]
            obBar  = bar_index - lookback
            if showOB
                newOB = box.new(obBar, obHigh, bar_index + 20, obLow,
                     border_color=color.new(#dc2626, 50), bgcolor=obBearCol, border_width=1)
                array.push(bearOBs, newOB)
            array.push(bearOBHighs, obHigh)
            array.push(bearOBLows, obLow)
            array.push(bearOBBars, obBar)
            break

if array.size(bullOBHighs) > 0
    i = array.size(bullOBHighs) - 1
    while i >= 0
        obAge = bar_index - array.get(bullOBBars, i)
        mitigated = close < array.get(bullOBLows, i)
        if obAge > obLookback or mitigated
            if showOB and array.size(bullOBs) > i
                box.delete(array.get(bullOBs, i))
                array.remove(bullOBs, i)
            array.remove(bullOBHighs, i)
            array.remove(bullOBLows,  i)
            array.remove(bullOBBars,  i)
        i -= 1

if array.size(bearOBHighs) > 0
    i = array.size(bearOBHighs) - 1
    while i >= 0
        obAge = bar_index - array.get(bearOBBars, i)
        mitigated = close > array.get(bearOBHighs, i)
        if obAge > obLookback or mitigated
            if showOB and array.size(bearOBs) > i
                box.delete(array.get(bearOBs, i))
                array.remove(bearOBs, i)
            array.remove(bearOBHighs, i)
            array.remove(bearOBLows,  i)
            array.remove(bearOBBars,  i)
        i -= 1

if showOB and array.size(bullOBs) > 0
    for i = 0 to array.size(bullOBs) - 1
        box.set_right(array.get(bullOBs, i), bar_index + 10)
if showOB and array.size(bearOBs) > 0
    for i = 0 to array.size(bearOBs) - 1
        box.set_right(array.get(bearOBs, i), bar_index + 10)

priceInBullOB = false
if array.size(bullOBHighs) > 0
    for i = 0 to array.size(bullOBHighs) - 1
        obH = array.get(bullOBHighs, i)
        obL = array.get(bullOBLows,  i)
        if low <= obH + atr * obBufferATR and low >= obL - atr * obBufferATR
            priceInBullOB := true
            break

priceInBearOB = false
if array.size(bearOBHighs) > 0
    for i = 0 to array.size(bearOBHighs) - 1
        obH = array.get(bearOBHighs, i)
        obL = array.get(bearOBLows,  i)
        if high >= obL - atr * obBufferATR and high <= obH + atr * obBufferATR
            priceInBearOB := true
            break

// ====================== FAIR VALUE GAP DETECTION ============================
bullFVG = low > high[2] and (low - high[2]) > atr * fvgMinSize
bearFVG = high < low[2] and (low[2] - high) > atr * fvgMinSize

var box[]   bullFVGBoxes = array.new_box()
var float[] bullFVGTops  = array.new_float()
var float[] bullFVGBots  = array.new_float()
var int[]   bullFVGBars  = array.new_int()

var box[]   bearFVGBoxes = array.new_box()
var float[] bearFVGTops  = array.new_float()
var float[] bearFVGBots  = array.new_float()
var int[]   bearFVGBars  = array.new_int()

if bullFVG
    topPrice = low
    botPrice = high[2]
    if showFVG
        newBox = box.new(bar_index - 2, topPrice, bar_index + 20, botPrice,
             border_color=color.new(#60a5fa, 60), bgcolor=fvgBullCol, border_width=1)
        array.push(bullFVGBoxes, newBox)
    array.push(bullFVGTops, topPrice)
    array.push(bullFVGBots, botPrice)
    array.push(bullFVGBars, bar_index)

if bearFVG
    topPrice = low[2]
    botPrice = high
    if showFVG
        newBox = box.new(bar_index - 2, topPrice, bar_index + 20, botPrice,
             border_color=color.new(#f59e0b, 60), bgcolor=fvgBearCol, border_width=1)
        array.push(bearFVGBoxes, newBox)
    array.push(bearFVGTops, topPrice)
    array.push(bearFVGBots, botPrice)
    array.push(bearFVGBars, bar_index)

if array.size(bullFVGTops) > 0
    i = array.size(bullFVGTops) - 1
    while i >= 0
        age = bar_index - array.get(bullFVGBars, i)
        filled = low <= array.get(bullFVGBots, i)
        if age > fvgMaxAge or filled
            if showFVG and array.size(bullFVGBoxes) > i
                box.delete(array.get(bullFVGBoxes, i))
                array.remove(bullFVGBoxes, i)
            array.remove(bullFVGTops, i)
            array.remove(bullFVGBots, i)
            array.remove(bullFVGBars, i)
        i -= 1

if array.size(bearFVGTops) > 0
    i = array.size(bearFVGTops) - 1
    while i >= 0
        age = bar_index - array.get(bearFVGBars, i)
        filled = high >= array.get(bearFVGBots, i)
        if age > fvgMaxAge or filled
            if showFVG and array.size(bearFVGBoxes) > i
                box.delete(array.get(bearFVGBoxes, i))
                array.remove(bearFVGBoxes, i)
            array.remove(bearFVGTops, i)
            array.remove(bearFVGBots, i)
            array.remove(bearFVGBars, i)
        i -= 1

if showFVG and array.size(bullFVGBoxes) > 0
    for i = 0 to array.size(bullFVGBoxes) - 1
        box.set_right(array.get(bullFVGBoxes, i), bar_index + 10)
if showFVG and array.size(bearFVGBoxes) > 0
    for i = 0 to array.size(bearFVGBoxes) - 1
        box.set_right(array.get(bearFVGBoxes, i), bar_index + 10)

priceInBullFVG = false
if array.size(bullFVGTops) > 0
    for i = 0 to array.size(bullFVGTops) - 1
        if low <= array.get(bullFVGTops, i) and low >= array.get(bullFVGBots, i)
            priceInBullFVG := true
            break

priceInBearFVG = false
if array.size(bearFVGTops) > 0
    for i = 0 to array.size(bearFVGTops) - 1
        if high >= array.get(bearFVGBots, i) and high <= array.get(bearFVGTops, i)
            priceInBearFVG := true
            break

// ======================= PREMIUM / DISCOUNT ZONES ===========================
rangeHi_fallback = ta.highest(high, 50)
rangeLo_fallback = ta.lowest(low,  50)
rangeHi = not na(lastPivHigh) ? lastPivHigh : rangeHi_fallback
rangeLo = not na(lastPivLow)  ? lastPivLow  : rangeLo_fallback
rangeMid = (rangeHi + rangeLo) / 2

inDiscount = close < rangeMid
inPremium  = close > rangeMid

var line pdLine = na
if showPD and barstate.islast
    if not na(pdLine)
        line.delete(pdLine)
    pdLine := line.new(bar_index - 50, rangeMid, bar_index + 5, rangeMid,
         color=color.new(color.yellow, 50), style=line.style_dashed, width=1)

// ============================ CONFLUENCE SCORE ==============================
bullScore = 0
bullScore += structureDir == 1 ? 1 : 0
bullScore += priceInBullOB    ? 1 : 0
bullScore += priceInBullFVG   ? 1 : 0
bullScore += inDiscount       ? 1 : 0
bullScore += htfBullish       ? 1 : 0

bearScore = 0
bearScore += structureDir == -1 ? 1 : 0
bearScore += priceInBearOB     ? 1 : 0
bearScore += priceInBearFVG    ? 1 : 0
bearScore += inPremium         ? 1 : 0
bearScore += htfBearish        ? 1 : 0

// =========================== SIGNAL TRIGGER =================================
var int lastSignalDir = 0

strongBull = close > open and (close - open) > atr * 0.5 and close > close[1]
strongBear = close < open and (open - close) > atr * 0.5 and close < close[1]

rawBuy  = bullScore >= minConfluence and strongBull and adxOk
rawSell = bearScore >= minConfluence and strongBear and adxOk

buySignal  = rawBuy  and lastSignalDir != 1
sellSignal = rawSell and lastSignalDir != -1

if buySignal
    lastSignalDir := 1
if sellSignal
    lastSignalDir := -1

// =========================== ARROWS + BG TINT ===============================
plotshape(buySignal,  title="BUY",  location=location.belowbar,
     style=shape.triangleup, size=size.normal, color=buyColor, text="BUY", textcolor=buyColor)
plotshape(sellSignal, title="SELL", location=location.abovebar,
     style=shape.triangledown, size=size.normal, color=sellColor, text="SELL", textcolor=sellColor)

bgcolor(buySignal  ? color.new(buyColor,  85) : na, title="Buy bar")
bgcolor(sellSignal ? color.new(sellColor, 85) : na, title="Sell bar")

// ======================== SL / TP CALCULATION ===============================
var float lastEntry = na
var float lastSL    = na
var float lastTP    = na
var int   lastDir   = 0
var int   lastScore = 0

var line entryLn = na
var line slLn    = na
var line tpLn    = na
var label entryLb = na
var label slLb    = na
var label tpLb    = na

if buySignal or sellSignal
    isBuy = buySignal
    entry = close

    float sl = na
    if isBuy
        if array.size(bullOBLows) > 0
            lowestOB = array.min(bullOBLows)
            sl := lowestOB - atr * slBufferATR
        else
            sl := entry - atr * 1.5
    else
        if array.size(bearOBHighs) > 0
            highestOB = array.max(bearOBHighs)
            sl := highestOB + atr * slBufferATR
        else
            sl := entry + atr * 1.5

    slDist = math.abs(entry - sl)
    tp = isBuy ? entry + slDist * rrRatio : entry - slDist * rrRatio

    lastEntry := entry
    lastSL    := sl
    lastTP    := tp
    lastDir   := isBuy ? 1 : -1
    lastScore := isBuy ? bullScore : bearScore

    if not na(entryLn)
        line.delete(entryLn)
        line.delete(slLn)
        line.delete(tpLn)
        label.delete(entryLb)
        label.delete(slLb)
        label.delete(tpLb)

    xEnd = bar_index + 30
    entryLn := line.new(bar_index, entry, xEnd, entry, color=#ffd700, style=line.style_solid,  width=2)
    slLn    := line.new(bar_index, sl,    xEnd, sl,    color=#dc143c, style=line.style_dashed, width=2)
    tpLn    := line.new(bar_index, tp,    xEnd, tp,    color=#32cd32, style=line.style_dashed, width=2)

    slPips = slDist / pipSize
    tpPips = (slDist * rrRatio) / pipSize

    entryLb := label.new(xEnd, entry, "ENTRY  " + str.tostring(entry, format.mintick),
         style=label.style_label_left, color=color.new(color.black, 80),
         textcolor=#ffd700, size=size.small)
    slLb := label.new(xEnd, sl, "SL  " + str.tostring(sl, format.mintick) +
         "  (-" + str.tostring(math.round(slPips)) + "p)",
         style=label.style_label_left, color=color.new(color.black, 80),
         textcolor=#dc143c, size=size.small)
    tpLb := label.new(xEnd, tp, "TP  " + str.tostring(tp, format.mintick) +
         "  (+" + str.tostring(math.round(tpPips)) + "p)",
         style=label.style_label_left, color=color.new(color.black, 80),
         textcolor=#32cd32, size=size.small)

// ============================ DASHBOARD ======================================
posMap(p) =>
    switch p
        "top_left"     => position.top_left
        "top_right"    => position.top_right
        "bottom_left"  => position.bottom_left
        "bottom_right" => position.bottom_right
        "middle_right" => position.middle_right
        =>               position.top_right

scoreColor(score) =>
    result = score >= 4 ? color.lime : score == 3 ? color.orange : color.new(#888888, 0)
    result

var table dash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(posMap(dashPos), 2, 14,
             bgcolor=color.new(#0f1420, 0), frame_color=color.gray,
             frame_width=1, border_color=color.new(color.gray, 50), border_width=1)

    table.cell(dash, 0, 0, "APEX SMC PRO", bgcolor=color.new(#192d50, 0),
         text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  " + timeframe.period,
         bgcolor=color.new(#192d50, 0), text_color=color.silver,
         text_size=size.small, text_halign=text.align_right)

    htfTxt = htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL"
    htfCol = htfBullish ? color.lime : htfBearish ? color.new(#ff6347, 0) : color.silver
    table.cell(dash, 0, 1, "HTF (" + htfTrend + ")", text_color=color.silver,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, htfTxt, text_color=htfCol,
         text_halign=text.align_right, text_size=size.small)

    structTxt = structureDir == 1 ? "BULLISH" : structureDir == -1 ? "BEARISH" : "UNDEFINED"
    structCol = structureDir == 1 ? color.lime : structureDir == -1 ? color.new(#ff6347, 0) : color.silver
    table.cell(dash, 0, 2, "Structure", text_color=color.silver,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, structTxt, text_color=structCol,
         text_halign=text.align_right, text_size=size.small)

    regimeTxt = adxVal >= adxMin ? "TRENDING" : "RANGING"
    regimeCol = adxVal >= adxMin ? color.lime : color.new(#ff6347, 0)
    table.cell(dash, 0, 3, "Regime (ADX " + str.tostring(adxVal, "#.0") + ")",
         text_color=color.silver, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, regimeTxt, text_color=regimeCol,
         text_halign=text.align_right, text_size=size.small)

    pdTxt = inDiscount ? "DISCOUNT" : inPremium ? "PREMIUM" : "EQUILIBRIUM"
    pdCol = inDiscount ? color.lime : inPremium ? color.new(#ff6347, 0) : color.silver
    table.cell(dash, 0, 4, "P/D Zone", text_color=color.silver,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, pdTxt, text_color=pdCol,
         text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 5, "-- CONFLUENCE SCORE --", text_color=color.aqua,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 5, "", text_halign=text.align_right)

    table.cell(dash, 0, 6, "BUY score  (/5)", text_color=buyColor,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(bullScore) + " / 5",
         text_color=scoreColor(bullScore), text_halign=text.align_right, text_size=size.normal)

    table.cell(dash, 0, 7, "SELL score (/5)", text_color=sellColor,
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(bearScore) + " / 5",
         text_color=scoreColor(bearScore), text_halign=text.align_right, text_size=size.normal)

    table.cell(dash, 0, 8, "Active Bull OBs",  text_color=color.silver, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(array.size(bullOBHighs)),
         text_color=color.lime, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 9, "Active Bear OBs", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(array.size(bearOBHighs)),
         text_color=color.new(#ff6347, 0), text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 10, "Active FVGs (B/S)", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(array.size(bullFVGTops)) + " / " + str.tostring(array.size(bearFVGTops)),
         text_color=color.white, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 11, "-- LAST SIGNAL --", text_color=color.new(#ffd700, 0),
         text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 11, "", text_halign=text.align_right)

    if lastDir == 0
        table.cell(dash, 0, 12, "Direction", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 12, "Waiting...", text_color=color.silver, text_halign=text.align_right, text_size=size.small)
        table.cell(dash, 0, 13, "", text_halign=text.align_left)
        table.cell(dash, 1, 13, "", text_halign=text.align_right)
    else
        dirTxt = lastDir == 1 ? "BUY" : "SELL"
        dirCol = lastDir == 1 ? buyColor : sellColor
        table.cell(dash, 0, 12, "Direction (score " + str.tostring(lastScore) + "/5)",
             text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 12, dirTxt, text_color=dirCol,
             text_halign=text.align_right, text_size=size.normal)

        table.cell(dash, 0, 13, "E / SL / TP", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 13,
             str.tostring(lastEntry, format.mintick) + " / " +
             str.tostring(lastSL, format.mintick) + " / " +
             str.tostring(lastTP, format.mintick),
             text_color=color.white, text_halign=text.align_right, text_size=size.small)

// ============================ ALERTS =========================================
alertcondition(buySignal,  title="SMC Buy",  message="ApexSMC BUY {{ticker}} {{interval}} @ {{close}}")
alertcondition(sellSignal, title="SMC Sell", message="ApexSMC SELL {{ticker}} {{interval}} @ {{close}}")

if buySignal
    slD = math.abs(close - lastSL)
    alert("ApexSMC BUY " + syminfo.ticker + " " + timeframe.period +
          " @ " + str.tostring(close, format.mintick) +
          " | SL " + str.tostring(lastSL, format.mintick) +
          " | TP " + str.tostring(lastTP, format.mintick) +
          " | Score " + str.tostring(bullScore) + "/5",
          alert.freq_once_per_bar_close)
if sellSignal
    alert("ApexSMC SELL " + syminfo.ticker + " " + timeframe.period +
          " @ " + str.tostring(close, format.mintick) +
          " | SL " + str.tostring(lastSL, format.mintick) +
          " | TP " + str.tostring(lastTP, format.mintick) +
          " | Score " + str.tostring(bearScore) + "/5",
          alert.freq_once_per_bar_close)
````
