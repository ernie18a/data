<!-- tradingview-pine-id: PUB;227cbf33a4ab4275be5e1e9fe3cf3712 -->
<!-- tradingviewscripts-format: 1 -->
# Laxman Rekha Reversal Strategy [15m Setup -&gt; 5m Trigger] v6.4 ET Session Filter

Source: https://www.tradingview.com/script/z9ZAdxT0-Laxman-Rekha-Reversal-Strategy/

## Description

HTF - 15m
LTF - 5m

HTF - 3m
LTF - 2m

works on both combinations and is most suited for shorts

---

## Source Code

````pine
//@version=6
strategy("Laxman Rekha Reversal Strategy [15m Setup -> 5m Trigger] v6.4 ET Session Filter",
     shorttitle = "LR 15m/5m v6.4",
     overlay = true,
     initial_capital = 10000,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 10,
     pyramiding = 0,
     calc_on_every_tick = false,
     process_orders_on_close = true,
     margin_long = 1,
     margin_short = 1,
     max_lines_count = 200,
     max_labels_count = 200)

// =====================================================================================
// IMPORTANT: Add this script on your 5-MINUTE chart. The 15m pattern is pulled in via
// request.security(). Instrument should match what you're trading so point value / stop
// sizing is correct in the Strategy Tester -> Properties tab.
// =====================================================================================

// Warn when the strategy is not running on a 5-minute chart.
isFiveMinuteChart = timeframe.isminutes and timeframe.multiplier == 5
var table tfWarning = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(tfWarning, 0, 0,
         isFiveMinuteChart ? "LR v5: 15m setup -> 5m trigger" : "WARNING: Run this strategy on a 5-minute chart",
         text_color = color.white,
         bgcolor = isFiveMinuteChart ? color.new(color.green, 45) : color.new(color.red, 15))

// ============================= SESSION FILTER =============================
grpSession = "Trading Session"
useSessionFilter = input.bool(true, "Enable 8:00 AM - 2:00 PM ET Filter", group = grpSession)
tradeSession = input.session("0800-1400", "Trading Session", group = grpSession)
inSession = not na(time(timeframe.period, tradeSession, "America/New_York"))
sessionOk = not useSessionFilter or inSession

// ============================= DIRECTION =============================
grpDir = "Direction"
enableShort = input.bool(true, "Enable Short Setups (2 Red Candle Pattern)", group = grpDir)
enableLong  = input.bool(true, "Enable Long Setups (2 Green Candle Pattern, mirror)", group = grpDir)

// ============================= 15M PATTERN INPUTS (shared) =============================
grpPattern = "15m Pattern Settings"
sizeMode       = input.string("Range (High-Low)", "Candle Size Measure", options = ["Range (High-Low)", "Body (|Close-Open|)"], group = grpPattern)
maxBarsWatch15 = input.int(20, "Max 15m Bars to Wait for Confirmation Candle", group = grpPattern)
useWickFilter  = input.bool(false, "Require Rejection Wick on Reference Candle", group = grpPattern, tooltip = "Short: red#1 upper wick >= body. Long: green#1 lower wick >= body.")
wickBodyMult   = input.float(1.0, "Wick >= Body x", group = grpPattern, step = 0.1)

// ============================= SETUP QUALITY FILTERS (15m, shared) =============================
grpQuality = "Setup Quality Filters (15m)"
volFilterMode  = input.string("Off", "Volatility Filter", options = ["ATR Expansion", "ADX", "Both", "Off"], group = grpQuality)
atrLen15       = input.int(14, "ATR Length (15m)", group = grpQuality)
atrSmaLen15    = input.int(20, "ATR SMA Length (15m)", group = grpQuality)
adxLen         = input.int(14, "ADX Length", group = grpQuality)
adxThreshold   = input.float(20, "ADX Threshold", group = grpQuality)
useVolumeFilter = input.bool(false, "Require Volume > SMA(Volume) on Confirmation Candle", group = grpQuality)
volumeSmaLen    = input.int(20, "Volume SMA Length", group = grpQuality)
useRsiFilter    = input.bool(false, "Require RSI Momentum Turn on Confirmation Candle", group = grpQuality)
rsiLen          = input.int(14, "RSI Length", group = grpQuality)
rsiOverbought   = input.float(65, "RSI Overbought (Shorts)", group = grpQuality)
rsiOversold     = input.float(35, "RSI Oversold (Longs)", group = grpQuality)

// ============================= HTF TREND FILTER (shared) =============================
grpTrend = "Higher Timeframe Trend Filter"
useTrendFilter = input.bool(true, "Trade Only With HTF Trend", group = grpTrend, tooltip = "Shorts only below HTF EMA, longs only above it")
trendTF        = input.timeframe("60", "Trend Timeframe", group = grpTrend)
trendEmaLen    = input.int(200, "Trend EMA Length", group = grpTrend)

// ============================= 5M ENTRY SETTINGS (shared) =============================
grpTrigger = "5m Entry Settings"
maxBarsWatch5  = input.int(30, "Max 5m Bars to Wait for Entry Trigger", group = grpTrigger, tooltip = "Any 5m candle may become the setup candle if it physically touches the Laxman Rekha level")

// ============================= RISK MANAGEMENT (shared) =============================
grpRisk = "Risk Management"
riskReward = 1.5

grpSizing = "Position Sizing"
orderQuantity = input.float(1.0, "Order Quantity", minval = 1.0, step = 1.0, group = grpSizing,
     tooltip = "Number of contracts, shares, or units submitted per trade.")

grpTradeMgmt = "Trade Management"
maxTradesPerDay  = input.int(3, "Max Trades Per Day", group = grpTradeMgmt)
maxConsecLosses  = input.int(2, "Stop After N Consecutive Losses (per day)", group = grpTradeMgmt)

// ============================= 15M CONTEXT: PATTERN DETECTION =============================
// Evaluated bar-by-bar on the 15m series via request.security() below.
// SHORT: green ref -> red closes below green body low -> second red closes below red #1 body low.
// LONG: red ref -> green closes above red body high -> second green closes above green #1 body high.
f_detect() =>
    isGreen = close > open
    isRed   = close < open
    barSize = sizeMode == "Range (High-Low)" ? (high - low) : math.abs(close - open)
    bodyLow  = math.min(open, close)
    bodyHigh = math.max(open, close)
    upperWick = high - bodyHigh
    lowerWick = bodyLow - low

    atr15    = ta.atr(atrLen15)
    atrSma15 = ta.sma(atr15, atrSmaLen15)
    [diplus, diminus, adxVal] = ta.dmi(adxLen, adxLen)
    volOk = volFilterMode == "Off" ? true :
             volFilterMode == "ATR Expansion" ? atr15 > atrSma15 :
             volFilterMode == "ADX" ? adxVal > adxThreshold :
             (atr15 > atrSma15 and adxVal > adxThreshold) // "Both"

    volumeOk = not useVolumeFilter or volume > ta.sma(volume, volumeSmaLen)

    rsiVal = ta.rsi(close, rsiLen)
    rsiOkShort = not useRsiFilter or (rsiVal[1] > rsiOverbought and rsiVal < rsiVal[1])
    rsiOkLong  = not useRsiFilter or (rsiVal[1] < rsiOversold and rsiVal > rsiVal[1])

    wickOkShort = not useWickFilter or upperWick >= (bodyHigh - bodyLow) * wickBodyMult
    wickOkLong  = not useWickFilter or lowerWick >= (bodyHigh - bodyLow) * wickBodyMult

    // ---------------- SHORT SIDE STATE MACHINE ----------------
    var int shortState     = 1   // 1 = scanning for red#1, 2 = watching for red#2
    var float greenRefSize = na
    var float greenRefLow  = na
    var float red1BodyLow  = na
    var float red1High     = na
    var int shortBarsLeft  = 0
    var bool shortSetup    = false
    var float shortLR      = na

    shortSetup := false

    if enableShort
        if shortState == 1
            if isGreen
                greenRefSize := barSize
                greenRefLow  := bodyLow
            else if isRed and not na(greenRefSize) and close < greenRefLow and wickOkShort and volOk
                red1BodyLow   := bodyLow
                red1High      := bodyHigh
                shortState    := 2
                shortBarsLeft := maxBarsWatch15
        else if shortState == 2
            shortBarsLeft -= 1
            if isRed and close < red1BodyLow and volumeOk and rsiOkShort
                shortLR    := bodyLow
                shortSetup := true
                shortState := 1
                greenRefSize := na
                greenRefLow  := na
                red1BodyLow  := na
                red1High     := na
            else if isGreen and close > red1High
                shortState := 1
                greenRefSize := na
                greenRefLow  := na
                red1BodyLow  := na
                red1High     := na
            else if shortBarsLeft <= 0
                shortState := 1
                greenRefSize := na
                greenRefLow  := na
                red1BodyLow  := na
                red1High     := na

    // ---------------- LONG SIDE STATE MACHINE (exact mirror) ----------------
    var int longState        = 1   // 1 = scanning for green#1, 2 = watching for green#2
    var float redRefSize     = na
    var float redRefHigh     = na
    var float green1BodyHigh = na
    var float green1Low      = na
    var int longBarsLeft     = 0
    var bool longSetup       = false
    var float longLR         = na

    longSetup := false

    if enableLong
        if longState == 1
            if isRed
                redRefSize := barSize
                redRefHigh := bodyHigh
            else if isGreen and not na(redRefSize) and close > redRefHigh and wickOkLong and volOk
                green1BodyHigh := bodyHigh
                green1Low      := bodyLow
                longState      := 2
                longBarsLeft   := maxBarsWatch15
        else if longState == 2
            longBarsLeft -= 1
            if isGreen and close > green1BodyHigh and volumeOk and rsiOkLong
                longLR    := bodyHigh
                longSetup := true
                longState := 1
                redRefSize := na
                redRefHigh := na
                green1BodyHigh := na
                green1Low := na
            else if isRed and close < green1Low
                longState := 1
                redRefSize := na
                redRefHigh := na
                green1BodyHigh := na
                green1Low := na
            else if longBarsLeft <= 0
                longState := 1
                redRefSize := na
                redRefHigh := na
                green1BodyHigh := na
                green1Low := na

    [shortSetup, shortLR, longSetup, longLR]

[shortTrig, shortLR15, longTrig, longLR15] =
     request.security(syminfo.tickerid, "15", f_detect(), lookahead = barmerge.lookahead_off)

// Guard against the 15m signal repeating across the underlying 5m bars
htf15Time = request.security(syminfo.tickerid, "15", time, lookahead = barmerge.lookahead_off)
isNew15Bar = ta.change(htf15Time) != 0

// ============================= HTF TREND FILTER =============================
trendEmaVal  = request.security(syminfo.tickerid, trendTF, ta.ema(close, trendEmaLen), lookahead = barmerge.lookahead_off)
trendOkShort = not useTrendFilter or close < trendEmaVal
trendOkLong  = not useTrendFilter or close > trendEmaVal

// ============================= 5M CONTEXT: TRIGGER + ENTRY =============================
atr5 = ta.atr(14) // used only for label offset placement on the 5m chart
isGreen5  = close > open
isRed5    = close < open
bodyLow5  = math.min(open, close)
bodyHigh5 = math.max(open, close)

// ---- Trade management counters (shared across both directions) ----
var int dailyCount    = 0
var int consecLosses  = 0
newDay = dayofmonth(time) != dayofmonth(time[1])
if newDay
    dailyCount := 0
    consecLosses := 0
tradeMgmtOk = dailyCount < maxTradesPerDay and consecLosses < maxConsecLosses
flatNow = strategy.position_size == 0
canShortNow = strategy.position_size >= 0
canLongNow  = strategy.position_size <= 0

// ---- SHORT trigger state ----
var int mStateShort      = 0
var float lrShort        = na
var float gLow5          = na
var float gHigh5         = na
var int mBarsLeftShort   = 0
var bool enterShort      = false
var line lrLineShort     = na

// ---- LONG trigger state ----
var int mStateLong       = 0
var float lrLong         = na
var float rLow5          = na
var float rHigh5         = na
var int mBarsLeftLong    = 0
var bool enterLong       = false
var line lrLineLong      = na

// ---- Shared position management state ----
var float entryPx  = na
var float initSL   = na
var float tpPrice  = na
var float equityBeforeTrade  = na
var bool  inTradeCycle       = false
var bool  posSeen            = false

enterShort := false
enterLong  := false

// Cancel pending LR trigger states outside the allowed session.
if useSessionFilter and not inSession
    mStateShort := 0
    mStateLong  := 0


// ---------------- SHORT: setup registration ----------------
if shortTrig and isNew15Bar and sessionOk
    mStateShort := 1
    lrShort := shortLR15
    mBarsLeftShort := maxBarsWatch5
    if not na(lrLineShort)
        line.delete(lrLineShort)
    lrLineShort := line.new(bar_index, lrShort, bar_index + 1, lrShort, extend = extend.right, color = color.red, style = line.style_dashed, width = 2)
    label.new(bar_index, high + atr5, "Sell LR\nLR " + str.tostring(lrShort, format.mintick),
         style = label.style_label_down, color = color.new(color.red, 10), textcolor = color.white, size = size.small)

if mStateShort == 1 or mStateShort == 2
    mBarsLeftShort -= 1
    if mBarsLeftShort <= 0
        mStateShort := 0

if mStateShort == 1
    touchesLRs = low <= lrShort and high >= lrShort

    // Same-candle short trigger:
    // A red 5m candle may touch LR and close below the previous green candle body low.
    sameCandleShort = touchesLRs and isRed5 and isGreen5[1] and close < bodyLow5[1] and close < lrShort and trendOkShort and tradeMgmtOk and canShortNow and sessionOk

    if sameCandleShort
        // Stop uses the immediately preceding green candle body high.
        slFinal = bodyHigh5[1]
        riskPts = slFinal - close
        if riskPts > 0
            entryPx := close
            initSL  := slFinal
            tpPrice := entryPx - riskPts * riskReward
            enterShort := true
            dailyCount += 1
            equityBeforeTrade := strategy.equity
            inTradeCycle := true
            posSeen := false
        mStateShort := 0

    else if touchesLRs
        // Any touching candle becomes the active short setup candle.
        gLow5  := bodyLow5
        gHigh5 := bodyHigh5
        mStateShort := 2
        mBarsLeftShort := maxBarsWatch5

else if mStateShort == 2
    // First check whether this candle confirms the existing setup.
    if isRed5
        canEnterShort = close < gLow5 and close < lrShort and trendOkShort and tradeMgmtOk and canShortNow and sessionOk
        if canEnterShort
            slFinal = gHigh5   // fixed stop = high of the green retracement candle
            riskPts = slFinal - close
            if riskPts > 0
                entryPx := close
                initSL  := slFinal
                tpPrice := entryPx - riskPts * riskReward
                enterShort := true
                dailyCount += 1
                equityBeforeTrade := strategy.equity
                inTradeCycle := true
                posSeen := false
        mStateShort := 0

// ---------------- LONG: setup registration ----------------
if longTrig and isNew15Bar and sessionOk
    mStateLong := 1
    lrLong := longLR15
    mBarsLeftLong := maxBarsWatch5
    if not na(lrLineLong)
        line.delete(lrLineLong)
    lrLineLong := line.new(bar_index, lrLong, bar_index + 1, lrLong, extend = extend.right, color = color.green, style = line.style_dashed, width = 2)
    label.new(bar_index, low - atr5, "Buy LR\nLR " + str.tostring(lrLong, format.mintick),
         style = label.style_label_up, color = color.new(color.green, 10), textcolor = color.white, size = size.small)

if mStateLong == 1 or mStateLong == 2
    mBarsLeftLong -= 1
    if mBarsLeftLong <= 0
        mStateLong := 0

if mStateLong == 1
    touchesLRl = high >= lrLong and low <= lrLong

    // Same-candle long trigger:
    // A green 5m candle may touch LR and close above the previous red candle body high.
    sameCandleLong = touchesLRl and isGreen5 and isRed5[1] and close > bodyHigh5[1] and close > lrLong and trendOkLong and tradeMgmtOk and canLongNow and sessionOk

    if sameCandleLong
        // Stop uses the immediately preceding red candle body low.
        slFinal = bodyLow5[1]
        riskPts = close - slFinal
        if riskPts > 0
            entryPx := close
            initSL  := slFinal
            tpPrice := entryPx + riskPts * riskReward
            enterLong := true
            dailyCount += 1
            equityBeforeTrade := strategy.equity
            inTradeCycle := true
            posSeen := false
        mStateLong := 0

    else if touchesLRl
        // Any touching candle becomes the active long setup candle.
        rLow5  := bodyLow5
        rHigh5 := bodyHigh5
        mStateLong := 2
        mBarsLeftLong := maxBarsWatch5

else if mStateLong == 2
    // First check whether this candle confirms the existing setup.
    if isGreen5
        canEnterLong = close > rHigh5 and close > lrLong and trendOkLong and tradeMgmtOk and canLongNow and sessionOk
        if canEnterLong
            slFinal = rLow5   // fixed stop = low of the red retracement candle
            riskPts = close - slFinal
            if riskPts > 0
                entryPx := close
                initSL  := slFinal
                tpPrice := entryPx + riskPts * riskReward
                enterLong := true
                dailyCount += 1
                equityBeforeTrade := strategy.equity
                inTradeCycle := true
                posSeen := false
        mStateLong := 0

// ============================= EXECUTION =============================
if enterShort
    wasLong = strategy.position_size > 0
    if wasLong
        strategy.close("Long", comment = "Reverse Long to Short", alert_message = "Long closed for opposite Short A++ setup")
        strategy.cancel("SLTP-Long")

    strategy.entry("Short", strategy.short, qty = orderQuantity, alert_message = "Short A+ entry triggered")
    strategy.exit("SLTP-Short", from_entry = "Short", stop = initSL, limit = tpPrice)

    label.new(bar_index, low,
         (wasLong ? "REVERSE TO SHORT A+" : "Short A++") +
         "\nQty " + str.tostring(orderQuantity, "#.##") +
         "\nRR 1:" + str.tostring(riskReward, "#.##"),
         style = label.style_label_up,
         color = color.new(color.maroon, 0),
         textcolor = color.white,
         size = size.normal)

    alert((wasLong ? "REVERSE LONG TO SHORT" : "SHORT A++") +
         " | Qty " + str.tostring(orderQuantity, "#.##") +
         " | Entry " + str.tostring(close) +
         " | SL " + str.tostring(initSL) +
         " | TP " + str.tostring(tpPrice),
         alert.freq_once_per_bar_close)

if enterLong
    wasShort = strategy.position_size < 0
    if wasShort
        strategy.close("Short", comment = "Reverse Short to Long", alert_message = "Short closed for opposite Long A++ setup")
        strategy.cancel("SLTP-Short")

    strategy.entry("Long", strategy.long, qty = orderQuantity, alert_message = "Long A+ entry triggered")
    strategy.exit("SLTP-Long", from_entry = "Long", stop = initSL, limit = tpPrice)

    label.new(bar_index, high,
         (wasShort ? "REVERSE TO LONG A+" : "Long A++") +
         "\nQty " + str.tostring(orderQuantity, "#.##") +
         "\nRR 1:" + str.tostring(riskReward, "#.##"),
         style = label.style_label_down,
         color = color.new(color.green, 0),
         textcolor = color.white,
         size = size.normal)

    alert((wasShort ? "REVERSE SHORT TO LONG" : "LONG A++") +
         " | Qty " + str.tostring(orderQuantity, "#.##") +
         " | Entry " + str.tostring(close) +
         " | SL " + str.tostring(initSL) +
         " | TP " + str.tostring(tpPrice),
         alert.freq_once_per_bar_close)

// ---- Consecutive loss tracking (round-trip P&L based, shared across directions) ----
if inTradeCycle
    if strategy.position_size != 0
        posSeen := true
    if posSeen and strategy.position_size == 0
        pnlCycle = strategy.equity - equityBeforeTrade
        if pnlCycle < 0
            consecLosses += 1
        else
            consecLosses := 0
        inTradeCycle := false

// Setup-formation alerts (fire even before the 5m trigger completes)
alertcondition(shortTrig, title = "Sell A++ Setup Formed", message = "15m two-red-candle pattern complete - Laxman Rekha marked")
alertcondition(longTrig,  title = "Buy A++ Setup Formed",  message = "15m two-green-candle pattern complete - Laxman Rekha marked")
alertcondition(enterShort, title = "Short A+ Entry", message = "Short A+ entry triggered")
alertcondition(enterLong,  title = "Long A+ Entry",   message = "Long A+ entry triggered")
alertcondition(enterShort and strategy.position_size > 0, title = "Reverse Long to Short", message = "Close Long and enter Short A++")
alertcondition(enterLong and strategy.position_size < 0, title = "Reverse Short to Long", message = "Close Short and enter Long A++")

// Lightly shade bars outside the allowed trading window.
bgcolor(useSessionFilter and not inSession ? color.new(color.gray, 93) : na, title = "Outside 8AM-2PM ET")

// ============================= PLOTTING =============================
plot(useTrendFilter ? trendEmaVal : na, "HTF Trend EMA", color = color.new(color.purple, 30), linewidth = 2)
plotshape(enterShort, title = "Short Entry Marker", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)
plotshape(enterLong, title = "Long Entry Marker", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
````
