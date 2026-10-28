# RGB ODTE  Script

- url: https://www.tradingview.com/script/t6hGdZXe-RGB-ODTE-Script/
- type: indicator
- pine_id: PUB;3fa739c8f94a4d1d84aac5f28441409e
- version: 1.0

## Description

OWL 0DTE Range Engine, this easily identifies the range of trading for SPX ODTE trading

## Source Code

````pine
//@version=5
indicator("Universal Range Strategy - Presets + VWAP Trade Type", shorttitle="Preset Range VWAP", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================
// PRESET SELECTION
// =====================================================

preset = input.string("SPX 0DTE", "Preset Setup", options=["SPX 0DTE", "SPY ETF", "QQQ ETF", "Large Cap Stock", "High Vol Stock", "ES Futures", "NQ Futures", "BTC Crypto", "ETH Crypto", "Custom"])

// =====================================================
// CUSTOM INPUTS
// =====================================================

customBodyLookback = input.int(10, "Custom Body Range Lookback Days", minval=5, maxval=50)
customBufferMult = input.float(1.33, "Custom Body Range Buffer", step=0.01)
customPriceStep = input.float(5.0, "Custom Strike / Price Step", step=0.01)
customWingSteps = input.int(2, "Custom Hedge / Wing Steps", minval=1, maxval=20)

customUseVix = input.bool(true, "Custom Use VIX Filter?")
customVixMax = input.float(22.0, "Custom Max VIX", step=0.25)
customUseVixTrend = input.bool(true, "Custom Avoid Rising VIX?")

customUseAtr = input.bool(true, "Custom Use ATR % Filter?")
customAtrMaxPct = input.float(1.30, "Custom Max ATR %", step=0.05)

customUseAtrShock = input.bool(true, "Custom Use ATR / Body Shock Filter?")
customAtrBodyMax = input.float(2.25, "Custom Max ATR / Body Ratio", step=0.05)

customUseTrend = input.bool(true, "Custom Use Trend Filter?")
customTrendLimit = input.float(0.35, "Custom Max EMA Spread as ATR Multiple", step=0.05)

customUseTime = input.bool(true, "Custom Use Time Filter?")
customStartHour = input.int(10, "Custom Entry Start Hour", minval=0, maxval=23)
customStartMinute = input.int(15, "Custom Entry Start Minute", minval=0, maxval=59)
customEndHour = input.int(14, "Custom Entry End Hour", minval=0, maxval=23)
customEndMinute = input.int(0, "Custom Entry End Minute", minval=0, maxval=59)

// =====================================================
// GENERAL INPUTS
// =====================================================

divideByTwo = input.bool(true, "Divide Buffered Range by 2?")
minRangeDistance = input.float(0.0, "Minimum Range Distance", step=0.25)

vixSym = input.symbol("CBOE:VIX", "VIX Symbol")
vixMaLen = input.int(5, "VIX Daily MA Length", minval=3, maxval=30)

atrLen = input.int(14, "ATR Length", minval=5, maxval=50)

trendEmaFast = input.int(20, "Fast EMA", minval=5, maxval=100)
trendEmaSlow = input.int(50, "Slow EMA", minval=20, maxval=300)

timeZoneInput = input.string("America/New_York", "Time Zone")

useMarketTrendFilter = input.bool(false, "Use External Market Trend Filter?")
marketTrendSymbol = input.symbol("SPY", "External Market Symbol")
marketTrendFast = input.int(20, "External Market Fast EMA", minval=5, maxval=100)
marketTrendSlow = input.int(50, "External Market Slow EMA", minval=20, maxval=300)

showHedgeLevels = input.bool(true, "Show Hedge / Wing Levels?")

// =====================================================
// VWAP DIRECTIONAL INPUTS
// =====================================================

useVWAPTradeType = input.bool(true, "Use Anchored VWAP Trade Type?")
vwapNeutralBufferPct = input.float(0.05, "VWAP Neutral Buffer %", step=0.01)
vwapTimeframe = input.string("15", "VWAP Confirmation Timeframe")

// =====================================================
// PRESET FLAGS
// =====================================================

isCustom = preset == "Custom"
isSPX = preset == "SPX 0DTE"
isSPY = preset == "SPY ETF"
isQQQ = preset == "QQQ ETF"
isLargeStock = preset == "Large Cap Stock"
isHighVolStock = preset == "High Vol Stock"
isES = preset == "ES Futures"
isNQ = preset == "NQ Futures"
isBTC = preset == "BTC Crypto"
isETH = preset == "ETH Crypto"

isCryptoMode = isBTC or isETH
isFuturesMode = isES or isNQ
isOptionsMode = isSPX or isSPY or isQQQ or isLargeStock or isHighVolStock or isCustom

// =====================================================
// PRESET VALUES
// =====================================================

bodyLookback = isCustom ? customBodyLookback : 10
bufferMult = isCustom ? customBufferMult : isSPX ? 1.33 : isSPY ? 1.35 : isQQQ ? 1.40 : isLargeStock ? 1.50 : isHighVolStock ? 1.75 : isES ? 1.40 : isNQ ? 1.60 : isBTC ? 2.00 : isETH ? 2.00 : 1.33
priceStep = isCustom ? customPriceStep : isSPX ? 5.0 : isSPY ? 1.0 : isQQQ ? 1.0 : isLargeStock ? 1.0 : isHighVolStock ? 5.0 : isES ? 5.0 : isNQ ? 25.0 : isBTC ? 100.0 : isETH ? 10.0 : 5.0
wingSteps = isCustom ? customWingSteps : 2

useVixFilter = isCustom ? customUseVix : isSPX or isSPY or isQQQ or isLargeStock or isHighVolStock
vixMax = isCustom ? customVixMax : isSPX ? 22.0 : isSPY ? 22.0 : isQQQ ? 22.0 : isLargeStock ? 24.0 : isHighVolStock ? 25.0 : 22.0
useVixTrendFilter = isCustom ? customUseVixTrend : isSPX or isSPY or isQQQ

useAtrFilter = isCustom ? customUseAtr : true
atrMaxPct = isCustom ? customAtrMaxPct : isSPX ? 1.30 : isSPY ? 1.50 : isQQQ ? 1.80 : isLargeStock ? 2.25 : isHighVolStock ? 3.50 : isES ? 1.50 : isNQ ? 2.00 : isBTC ? 4.00 : isETH ? 5.00 : 1.30

useAtrShockFilter = isCustom ? customUseAtrShock : true
atrBodyMaxRatio = isCustom ? customAtrBodyMax : isSPX ? 2.25 : isSPY ? 2.35 : isQQQ ? 2.50 : isLargeStock ? 2.75 : isHighVolStock ? 3.25 : isES ? 2.35 : isNQ ? 2.75 : isBTC ? 3.50 : isETH ? 3.75 : 2.25

useTrendFilter = isCustom ? customUseTrend : true
trendAtrLimit = isCustom ? customTrendLimit : isSPX ? 0.35 : isSPY ? 0.40 : isQQQ ? 0.45 : isLargeStock ? 0.50 : isHighVolStock ? 0.65 : isES ? 0.45 : isNQ ? 0.55 : isBTC ? 0.75 : isETH ? 0.85 : 0.35

useTimeFilter = isCustom ? customUseTime : not isCryptoMode
entryStartHour = isCustom ? customStartHour : isES or isNQ ? 9 : isBTC or isETH ? 0 : 10
entryStartMinute = isCustom ? customStartMinute : isES or isNQ ? 45 : isBTC or isETH ? 0 : 15
entryEndHour = isCustom ? customEndHour : isES or isNQ ? 15 : isBTC or isETH ? 23 : 14
entryEndMinute = isCustom ? customEndMinute : isES or isNQ ? 30 : isBTC or isETH ? 59 : 0

// =====================================================
// BODY RANGE ENGINE
// =====================================================

avgBodyRange = request.security(syminfo.tickerid, "1D", ta.sma(math.abs(close - open), bodyLookback)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bufferedRange = avgBodyRange * bufferMult
rangeDistance = divideByTwo ? bufferedRange / 2.0 : bufferedRange

// =====================================================
// ROUNDING FUNCTIONS
// =====================================================

roundUpToStep(x, step) =>
    math.ceil(x / step) * step

roundDownToStep(x, step) =>
    math.floor(x / step) * step

roundNearestStep(x, step) =>
    math.round(x / step) * step

// =====================================================
// LEVEL CALCULATION
// =====================================================

rawUpper = close + rangeDistance
rawLower = close - rangeDistance

upperLevel = isOptionsMode ? roundUpToStep(rawUpper, priceStep) : roundNearestStep(rawUpper, priceStep)
lowerLevel = isOptionsMode ? roundDownToStep(rawLower, priceStep) : roundNearestStep(rawLower, priceStep)

upperHedge = upperLevel + wingSteps * priceStep
lowerHedge = lowerLevel - wingSteps * priceStep

// =====================================================
// VIX FILTER
// =====================================================

vixLive = request.security(vixSym, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vixDailyMA = request.security(vixSym, "1D", ta.sma(close, vixMaLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

vixApplicable = not isCryptoMode and not isFuturesMode

vixLevelOK = not useVixFilter or not vixApplicable or vixLive <= vixMax
vixTrendOK = not useVixTrendFilter or not vixApplicable or vixLive <= vixDailyMA

// =====================================================
// ATR FILTER
// =====================================================

dailyATR = request.security(syminfo.tickerid, "1D", ta.atr(atrLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

atrPct = dailyATR / close * 100.0
atrOK = not useAtrFilter or atrPct <= atrMaxPct

atrBodyRatio = avgBodyRange != 0 ? dailyATR / avgBodyRange : na
atrShockOK = not useAtrShockFilter or atrBodyRatio <= atrBodyMaxRatio

// =====================================================
// TREND FILTER
// =====================================================

emaFast = ta.ema(close, trendEmaFast)
emaSlow = ta.ema(close, trendEmaSlow)
emaSpread = math.abs(emaFast - emaSlow)

trendOK = not useTrendFilter or emaSpread <= dailyATR * trendAtrLimit

// =====================================================
// EXTERNAL MARKET TREND FILTER
// =====================================================

marketFast = request.security(marketTrendSymbol, timeframe.period, ta.ema(close, marketTrendFast), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
marketSlow = request.security(marketTrendSymbol, timeframe.period, ta.ema(close, marketTrendSlow), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

marketTrendOK = not useMarketTrendFilter or marketFast >= marketSlow

// =====================================================
// TIME FILTER
// =====================================================

chartHour = hour(time, timeZoneInput)
chartMinute = minute(time, timeZoneInput)

afterStart = chartHour > entryStartHour or (chartHour == entryStartHour and chartMinute >= entryStartMinute)
beforeEnd = chartHour < entryEndHour or (chartHour == entryEndHour and chartMinute <= entryEndMinute)

timeOK = not useTimeFilter or (afterStart and beforeEnd)

// =====================================================
// CUSTOM DAILY ANCHORED VWAP FUNCTION
// =====================================================

f_daily_avwap() =>
    var float cumPV = na
    var float cumVol = na
    newDay = ta.change(time("D")) != 0
    volSafe = na(volume) or volume <= 0 ? 1.0 : volume
    if newDay or na(cumPV)
        cumPV := hlc3 * volSafe
        cumVol := volSafe
    else
        cumPV := cumPV + hlc3 * volSafe
        cumVol := cumVol + volSafe
    cumVol != 0 ? cumPV / cumVol : na

anchoredVWAP = f_daily_avwap()
closeConfirm = request.security(syminfo.tickerid, vwapTimeframe, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwapConfirm = request.security(syminfo.tickerid, vwapTimeframe, f_daily_avwap(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

vwapBuffer = closeConfirm * vwapNeutralBufferPct / 100.0

aboveVWAP = closeConfirm > vwapConfirm + vwapBuffer
belowVWAP = closeConfirm < vwapConfirm - vwapBuffer
nearVWAP = not aboveVWAP and not belowVWAP

// =====================================================
// FINAL SETUP DECISION
// =====================================================

rangeOK = not na(avgBodyRange) and avgBodyRange > 0 and rangeDistance >= minRangeDistance

baseSetupOK = rangeOK and vixLevelOK and vixTrendOK and atrOK and atrShockOK and trendOK and marketTrendOK and timeOK

bullishPutSpreadOK = baseSetupOK and (not useVWAPTradeType or aboveVWAP)
bearishCallSpreadOK = baseSetupOK and useVWAPTradeType and belowVWAP
neutralCondorOK = baseSetupOK and useVWAPTradeType and nearVWAP

setupOK = bullishPutSpreadOK or bearishCallSpreadOK or neutralCondorOK

tradeType = neutralCondorOK ? "IRON CONDOR" : bullishPutSpreadOK ? "SELL PUT SPREAD" : bearishCallSpreadOK ? "SELL CALL SPREAD" : "NO TRADE"

// =====================================================
// LABELS
// =====================================================

upperName = isOptionsMode ? "Sell Call / Upper Strike" : "Upper Range Level"
lowerName = isOptionsMode ? "Sell Put / Lower Strike" : "Lower Range Level"
upperHedgeName = isOptionsMode ? "Buy Call Hedge" : "Upper Risk Level"
lowerHedgeName = isOptionsMode ? "Buy Put Hedge" : "Lower Risk Level"

// =====================================================
// PLOTS BASED ON TRADE TYPE
// =====================================================

bgcolor(setupOK ? color.new(color.green, 88) : color.new(color.red, 92), title="Setup Permission")

plot(neutralCondorOK or bearishCallSpreadOK ? upperLevel : na, "Sell Call / Upper Level", color.red, 2, plot.style_linebr)
plot(neutralCondorOK or bullishPutSpreadOK ? lowerLevel : na, "Sell Put / Lower Level", color.green, 2, plot.style_linebr)

plot(showHedgeLevels and (neutralCondorOK or bearishCallSpreadOK) ? upperHedge : na, "Buy Call Hedge / Upper Risk", color.orange, 1, plot.style_circles)
plot(showHedgeLevels and (neutralCondorOK or bullishPutSpreadOK) ? lowerHedge : na, "Buy Put Hedge / Lower Risk", color.lime, 1, plot.style_circles)

plot(anchoredVWAP, "Daily Anchored VWAP", color.blue, 2, plot.style_line)

plot(avgBodyRange, "Average Body Range", color.yellow, 2, display=display.data_window)
plot(bufferedRange, "Buffered Range", color.blue, 2, display=display.data_window)
plot(rangeDistance, "Range Distance", color.aqua, 2, display=display.data_window)
plot(atrPct, "ATR %", color.purple, 2, display=display.data_window)
plot(atrBodyRatio, "ATR / Body Ratio", color.gray, 2, display=display.data_window)

plotshape(neutralCondorOK and barstate.islast, title="Iron Condor Ready", location=location.bottom, color=color.green, style=shape.labelup, text="CONDOR")
plotshape(bullishPutSpreadOK and not neutralCondorOK and barstate.islast, title="Put Spread Ready", location=location.bottom, color=color.green, style=shape.labelup, text="PUT SPREAD")
plotshape(bearishCallSpreadOK and barstate.islast, title="Call Spread Ready", location=location.bottom, color=color.red, style=shape.labeldown, text="CALL SPREAD")

// =====================================================
// WHITE BACKGROUND FRIENDLY TABLE
// =====================================================

tableBg = color.new(color.white, 0)
labelBg = color.new(color.silver, 15)
valueBg = color.new(color.white, 0)
labelText = color.black
neutralText = color.black
goodText = color.rgb(0, 120, 0)
badText = color.rgb(180, 0, 0)
warnText = color.rgb(180, 100, 0)
blueText = color.rgb(0, 80, 180)

var table info = table.new(position.top_right, 2, 22, bgcolor=tableBg, border_width=1, frame_color=color.gray, border_color=color.gray)

if barstate.islast
    table.cell(info, 0, 0, "Preset", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 0, preset, text_color=blueText, bgcolor=valueBg)

    table.cell(info, 0, 1, "Trade Type", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 1, tradeType, text_color=setupOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 2, "Lookback", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 2, str.tostring(bodyLookback), text_color=neutralText, bgcolor=valueBg)

    table.cell(info, 0, 3, "Buffer", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 3, str.tostring(bufferMult, "#.##"), text_color=blueText, bgcolor=valueBg)

    table.cell(info, 0, 4, "Avg Body", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 4, str.tostring(avgBodyRange, "#.##"), text_color=neutralText, bgcolor=valueBg)

    table.cell(info, 0, 5, "Distance Used", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 5, str.tostring(rangeDistance, "#.##"), text_color=rangeOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 6, upperName, text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 6, str.tostring(upperLevel, "#.##"), text_color=badText, bgcolor=valueBg)

    table.cell(info, 0, 7, upperHedgeName, text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 7, str.tostring(upperHedge, "#.##"), text_color=warnText, bgcolor=valueBg)

    table.cell(info, 0, 8, lowerName, text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 8, str.tostring(lowerLevel, "#.##"), text_color=goodText, bgcolor=valueBg)

    table.cell(info, 0, 9, lowerHedgeName, text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 9, str.tostring(lowerHedge, "#.##"), text_color=goodText, bgcolor=valueBg)

    table.cell(info, 0, 10, "VWAP Bias", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 10, aboveVWAP ? "Above VWAP" : belowVWAP ? "Below VWAP" : "Near VWAP", text_color=aboveVWAP ? goodText : belowVWAP ? badText : blueText, bgcolor=valueBg)

    table.cell(info, 0, 11, "15m Close", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 11, str.tostring(closeConfirm, "#.##"), text_color=neutralText, bgcolor=valueBg)

    table.cell(info, 0, 12, "15m VWAP", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 12, str.tostring(vwapConfirm, "#.##"), text_color=blueText, bgcolor=valueBg)

    table.cell(info, 0, 13, "VIX", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 13, vixApplicable ? str.tostring(vixLive, "#.##") : "N/A", text_color=vixLevelOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 14, "VIX Trend", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 14, vixApplicable ? (vixTrendOK ? "OK" : "Rising") : "N/A", text_color=vixTrendOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 15, "ATR %", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 15, str.tostring(atrPct, "#.##") + "%", text_color=atrOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 16, "ATR / Body", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 16, str.tostring(atrBodyRatio, "#.##"), text_color=atrShockOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 17, "Trend", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 17, trendOK ? "OK" : "Strong", text_color=trendOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 18, "Market Filter", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 18, marketTrendOK ? "OK" : "Weak", text_color=marketTrendOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 19, "Time", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 19, timeOK ? "OK" : "Avoid", text_color=timeOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 20, "Base Setup", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 20, baseSetupOK ? "YES" : "NO", text_color=baseSetupOK ? goodText : badText, bgcolor=valueBg)

    table.cell(info, 0, 21, "Final Setup", text_color=labelText, bgcolor=labelBg)
    table.cell(info, 1, 21, setupOK ? "YES" : "NO", text_color=setupOK ? goodText : badText, bgcolor=valueBg)

// =====================================================
// ALERT
// =====================================================

alertMessage = "VWAP Trade Setup | Preset: " + preset + " | Trade Type: " + tradeType + " | Upper: " + str.tostring(upperLevel, "#.##") + " | Lower: " + str.tostring(lowerLevel, "#.##") + " | Upper Hedge: " + str.tostring(upperHedge, "#.##") + " | Lower Hedge: " + str.tostring(lowerHedge, "#.##") + " | Distance: " + str.tostring(rangeDistance, "#.##")

if setupOK and not setupOK[1]
    alert(alertMessage, alert.freq_once_per_bar_close)
````
