# Precision ORB Framework

- url: https://www.tradingview.com/script/1joi0HR0-Precision-ORB-Framework/
- type: indicator
- pine_id: PUB;6ef5168670334fa28b90ed37205d8bbc
- version: 1.0

## Description

Precision ORB Clean v17 is part of the Precision ORB Framework — a structured futures trading model developed around opening range behavior, VWAP positioning, liquidity sweeps, market acceptance, and clean breakout confirmation.

This framework was built specifically for NQ and index futures execution, combining:
• Opening Range Breakouts (ORB)
• VWAP trend alignment
• Liquidity sweep detection
• Acceptance candle confirmation
• Trend bias filtering
• REV? rejection warnings
• Dynamic TP1 / TP2 targeting
• Price discovery grid targets

The companion “Precision Entry Assistant” indicator was developed alongside this framework to assist with lower timeframe execution, market state filtering, and cleaner trade timing.

This is not intended to be a prediction tool or signal-selling script. The framework is designed to help traders structure decision-making around momentum, liquidity, volatility expansion, and disciplined execution.

## Source Code

````pine
//@version=6
indicator("Precision ORB Clean v17 Clean Breakout REV Only", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50, max_bars_back=500)

// === SETTINGS ===
tz = input.string("America/New_York", "Timezone")
useBodyRange = input.bool(true, "Use Candle Body ORB")

thursdayMode = input.string("Warn", "Thursday Mode", options=["Normal", "Warn", "Strict", "Disable"])

minBreakPoints = input.float(1.0, "Minimum Break Distance", step=0.25)
closeStrengthPct = input.float(55.0, "Close Strength %", minval=50, maxval=95)

thursdayBreakMultiplier = input.float(1.5, "Thursday Break Multiplier", step=0.25)
thursdayCloseStrengthAdd = input.float(10.0, "Thursday Extra Close Strength %", step=1.0)

swingLen = input.int(2, "Swing Pivot Strength", minval=1, maxval=10)
maxSwingLookback = input.int(50, "Swing Lookback Bars", minval=10, maxval=250)

minTargetR = input.float(0.25, "Minimum Target R", step=0.25)
maxTargetR = input.float(3.0, "Maximum Target R", step=0.25)

tp1R = input.float(1.0, "Fallback TP1 R", step=0.25)
tp2R = input.float(2.0, "Fallback TP2 R", step=0.25)

targetBars = input.int(40, "Target Line Length", minval=10, maxval=100)

// === PRICE DISCOVERY TARGETS ===
useGridTargets = input.bool(true, "Use Grid Targets When No Liquidity")
gridStepPoints = input.float(50.0, "Grid Target Step Points", step=5)
minGridTargetPoints = input.float(25.0, "Minimum Grid Target Distance", step=5)
tp1GridSteps = input.int(1, "TP1 Grid Steps", minval=1, maxval=5)
tp2GridSteps = input.int(2, "TP2 Grid Steps", minval=1, maxval=8)

// === VWAP / BIAS ===
showVWAP = input.bool(true, "Show True VWAP")
useVWAPFilter = input.bool(true, "Use VWAP Filter")

useBiasFilter = input.bool(true, "Use Trend Bias Filter")
biasEmaLen = input.int(21, "Bias EMA Length", minval=5, maxval=100)
biasSlopeBars = input.int(3, "Bias Slope Bars", minval=1, maxval=10)
blockCounterTrend = input.bool(true, "Block Countertrend Main Signals")

useAcceptance = input.bool(true, "Require Acceptance Candle")
acceptBarsNeeded = input.int(1, "Acceptance Bars Needed", minval=1, maxval=3)

// === CLEAN REV WARNING ===
showRevWarning = input.bool(true, "Show REV? Only On Breakout Candle")
minLiquiditySweepPoints = input.float(8.0, "Minimum Liquidity Sweep Points", step=0.25)
wickRejectPct = input.float(35.0, "Trap Wick Rejection %", minval=10, maxval=80)
suppressMainOnRevWarning = input.bool(true, "Suppress Main Signal On REV? Candle")

// === TIME ===
hr = hour(time, tz)
mn = minute(time, tz)
dom = dayofmonth(time, tz)

isOpenBar = hr == 9 and mn == 30
tradeWindow = (hr > 9 or (hr == 9 and mn >= 45)) and hr < 11
activeSession = hr >= 9 and hr <= 13
newDay = ta.change(dom) != 0

isThursday = dayofweek == dayofweek.thursday
thursdayBlocked = thursdayMode == "Disable" and isThursday
thursdayStrict = thursdayMode == "Strict" and isThursday

breakNeeded = thursdayStrict ? minBreakPoints * thursdayBreakMultiplier : minBreakPoints
closeStrengthNeeded = thursdayStrict ? closeStrengthPct + thursdayCloseStrengthAdd : closeStrengthPct

// === VARIABLES ===
var float orbHigh = na
var float orbLow = na
var bool rangeSet = false
var bool signalDone = false
var bool revWarningDone = false

var int bullAcceptCount = 0
var int bearAcceptCount = 0

var box orbBox = na
var label orbText = na

var line activeTp1Line = na
var line activeTp2Line = na
var label activeTp1Label = na
var label activeTp2Label = na

// === DELETE TARGETS ===
deleteActiveTargets() =>
    if not na(activeTp1Line)
        line.delete(activeTp1Line)
    if not na(activeTp2Line)
        line.delete(activeTp2Line)
    if not na(activeTp1Label)
        label.delete(activeTp1Label)
    if not na(activeTp2Label)
        label.delete(activeTp2Label)

// === DAILY RESET ===
if newDay
    orbHigh := na
    orbLow := na
    rangeSet := false
    signalDone := false
    revWarningDone := false
    bullAcceptCount := 0
    bearAcceptCount := 0
    orbBox := na
    orbText := na
    activeTp1Line := na
    activeTp2Line := na
    activeTp1Label := na
    activeTp2Label := na

// === OPENING RANGE ===
if isOpenBar
    bodyHigh = math.max(open, close)
    bodyLow = math.min(open, close)

    orbHigh := useBodyRange ? bodyHigh : high
    orbLow := useBodyRange ? bodyLow : low
    rangeSet := true

    orbBox := box.new(bar_index, orbHigh, bar_index, orbLow, bgcolor=color.new(color.rgb(20, 105, 255), 90), border_color=color.new(color.rgb(20, 105, 255), 60))
    orbText := label.new(bar_index, (orbHigh + orbLow) / 2, "OR", style=label.style_none, textcolor=color.new(color.rgb(20, 105, 255), 20), size=size.tiny)

    if isThursday and thursdayMode != "Normal"
        label.new(bar_index, orbHigh, "⚠", style=label.style_label_down, color=color.new(color.orange, 80), textcolor=color.rgb(130, 70, 0), size=size.tiny)

if rangeSet and activeSession and not na(orbBox)
    box.set_right(orbBox, bar_index)

if rangeSet and activeSession and not na(orbText)
    label.set_x(orbText, math.round((box.get_left(orbBox) + box.get_right(orbBox)) / 2))
    label.set_y(orbText, (orbHigh + orbLow) / 2)

// === VWAP / BIAS ===
trueVWAP = ta.vwap(hlc3)
biasEMA = ta.ema(close, biasEmaLen)

vwapRising = trueVWAP > trueVWAP[biasSlopeBars]
vwapFalling = trueVWAP < trueVWAP[biasSlopeBars]
emaRising = biasEMA > biasEMA[biasSlopeBars]
emaFalling = biasEMA < biasEMA[biasSlopeBars]

strongBullBias = close > trueVWAP and close > biasEMA and vwapRising and emaRising
strongBearBias = close < trueVWAP and close < biasEMA and vwapFalling and emaFalling

allowMainBuy = not useBiasFilter or not blockCounterTrend or not strongBearBias
allowMainSell = not useBiasFilter or not blockCounterTrend or not strongBullBias

// === CLOSE STRENGTH ===
confirmed = barstate.isconfirmed
barRange = high - low
closePos = barRange > 0 ? ((close - low) / barRange) * 100 : 50

bullStrong = closePos >= closeStrengthNeeded
bearStrong = closePos <= (100 - closeStrengthNeeded)

upperWickPct = barRange > 0 ? ((high - math.max(open, close)) / barRange) * 100 : 0
lowerWickPct = barRange > 0 ? ((math.min(open, close) - low) / barRange) * 100 : 0

// === SWINGS ===
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

recentSwingHigh = ta.valuewhen(not na(pivotHigh), pivotHigh, 0)
recentSwingLow = ta.valuewhen(not na(pivotLow), pivotLow, 0)

// === BREAKOUT BASE ===
bullBreakBase = confirmed and rangeSet and tradeWindow and close > orbHigh and close - orbHigh >= breakNeeded
bearBreakBase = confirmed and rangeSet and tradeWindow and close < orbLow and orbLow - close >= breakNeeded

// === ACCEPTANCE COUNTS ===
if confirmed and rangeSet and tradeWindow
    bullAcceptCount := close > orbHigh ? bullAcceptCount + 1 : 0
    bearAcceptCount := close < orbLow ? bearAcceptCount + 1 : 0

bullAccepted = not useAcceptance or bullAcceptCount >= acceptBarsNeeded
bearAccepted = not useAcceptance or bearAcceptCount >= acceptBarsNeeded

// === CLEAN REV? ONLY ON BREAKOUT CANDLE ===
upSweepDistance = not na(recentSwingHigh) ? high - recentSwingHigh : 0
downSweepDistance = not na(recentSwingLow) ? recentSwingLow - low : 0

upTookLiquidity = not na(recentSwingHigh) and high > recentSwingHigh and upSweepDistance >= minLiquiditySweepPoints
downTookLiquidity = not na(recentSwingLow) and low < recentSwingLow and downSweepDistance >= minLiquiditySweepPoints

upRevWarning = confirmed and not revWarningDone and bullBreakBase and upTookLiquidity and (upperWickPct >= wickRejectPct or close < orbHigh or not bullStrong)
downRevWarning = confirmed and not revWarningDone and bearBreakBase and downTookLiquidity and (lowerWickPct >= wickRejectPct or close > orbLow or not bearStrong)

if upRevWarning
    revWarningDone := true
    if showRevWarning
        label.new(bar_index, high, "REV?", style=label.style_label_down, color=color.new(color.purple, 84), textcolor=color.rgb(85, 20, 130), size=size.tiny)

if downRevWarning
    revWarningDone := true
    if showRevWarning
        label.new(bar_index, low, "REV?", style=label.style_label_up, color=color.new(color.purple, 84), textcolor=color.rgb(85, 20, 130), size=size.tiny)

// === MAIN SIGNALS ===
buySignal = bullBreakBase and bullAccepted and not signalDone and not thursdayBlocked and bullStrong and allowMainBuy and (not useVWAPFilter or close > trueVWAP) and not (suppressMainOnRevWarning and upRevWarning)
sellSignal = bearBreakBase and bearAccepted and not signalDone and not thursdayBlocked and bearStrong and allowMainSell and (not useVWAPFilter or close < trueVWAP) and not (suppressMainOnRevWarning and downRevWarning)

// === GRID TARGET FALLBACKS ===
buyGridTarget(_entry, _steps) =>
    base = math.ceil((_entry + minGridTargetPoints) / gridStepPoints) * gridStepPoints
    base + ((_steps - 1) * gridStepPoints)

sellGridTarget(_entry, _steps) =>
    base = math.floor((_entry - minGridTargetPoints) / gridStepPoints) * gridStepPoints
    base - ((_steps - 1) * gridStepPoints)

// === TARGET LOGIC ===
findBuyTP(_entry, _risk, _targetNumber) =>
    r = _targetNumber == 1 ? tp1R : tp2R
    rFallback = _entry + _risk * r
    gridFallback = buyGridTarget(_entry, _targetNumber == 1 ? tp1GridSteps : tp2GridSteps)
    fallback = useGridTargets ? gridFallback : rFallback

    minPrice = _entry + _risk * minTargetR
    maxPrice = _entry + _risk * maxTargetR

    float first = na
    float second = na
    safeLookback = math.min(maxSwingLookback, bar_index - swingLen - 1)

    if safeLookback >= swingLen
        for i = swingLen to safeLookback
            ph = pivotHigh[i]
            if not na(ph) and ph >= minPrice and ph <= maxPrice
                if na(first) or ph < first
                    second := first
                    first := ph
                else if ph > first and (na(second) or ph < second)
                    second := ph

    result = _targetNumber == 1 ? first : second
    na(result) ? fallback : result

findSellTP(_entry, _risk, _targetNumber) =>
    r = _targetNumber == 1 ? tp1R : tp2R
    rFallback = _entry - _risk * r
    gridFallback = sellGridTarget(_entry, _targetNumber == 1 ? tp1GridSteps : tp2GridSteps)
    fallback = useGridTargets ? gridFallback : rFallback

    maxPrice = _entry - _risk * minTargetR
    minPrice = _entry - _risk * maxTargetR

    float first = na
    float second = na
    safeLookback = math.min(maxSwingLookback, bar_index - swingLen - 1)

    if safeLookback >= swingLen
        for i = swingLen to safeLookback
            pl = pivotLow[i]
            if not na(pl) and pl <= maxPrice and pl >= minPrice
                if na(first) or pl > first
                    second := first
                    first := pl
                else if pl < first and (na(second) or pl > second)
                    second := pl

    result = _targetNumber == 1 ? first : second
    na(result) ? fallback : result

// === DRAW TARGETS ===
drawTargets(_tp1, _tp2) =>
    tpColor = color.rgb(20, 105, 255)

    l1 = line.new(bar_index, _tp1, bar_index + targetBars, _tp1, color=tpColor, width=2, style=line.style_dotted)
    l2 = line.new(bar_index, _tp2, bar_index + targetBars, _tp2, color=tpColor, width=2, style=line.style_dotted)

    lb1 = label.new(bar_index + targetBars, _tp1, "TP1 ●", style=label.style_label_left, color=color.new(tpColor, 100), textcolor=tpColor)
    lb2 = label.new(bar_index + targetBars, _tp2, "TP2 ●", style=label.style_label_left, color=color.new(tpColor, 100), textcolor=tpColor)

    [l1, l2, lb1, lb2]

// === BUY ===
if buySignal
    signalDone := true
    deleteActiveTargets()

    entry = close
    stop = orbLow
    risk = entry - stop

    tp1 = findBuyTP(entry, risk, 1)
    tp2 = findBuyTP(entry, risk, 2)

    if tp2 <= tp1
        tp2 := buyGridTarget(entry, tp2GridSteps)

    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.rgb(20, 95, 230), textcolor=color.white)

    [l1, l2, lb1, lb2] = drawTargets(tp1, tp2)
    activeTp1Line := l1
    activeTp2Line := l2
    activeTp1Label := lb1
    activeTp2Label := lb2

// === SELL ===
if sellSignal
    signalDone := true
    deleteActiveTargets()

    entry = close
    stop = orbHigh
    risk = stop - entry

    tp1 = findSellTP(entry, risk, 1)
    tp2 = findSellTP(entry, risk, 2)

    if tp2 >= tp1
        tp2 := sellGridTarget(entry, tp2GridSteps)

    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.rgb(230, 120, 25), textcolor=color.white)

    [l1, l2, lb1, lb2] = drawTargets(tp1, tp2)
    activeTp1Line := l1
    activeTp2Line := l2
    activeTp1Label := lb1
    activeTp2Label := lb2

// === PLOTS ===
show = rangeSet and activeSession

plot(showVWAP ? trueVWAP : na, "True VWAP", color=color.rgb(35, 35, 35), linewidth=2)
plot(show ? orbHigh : na, "ORB High", color=color.rgb(20, 105, 255), linewidth=2, style=plot.style_linebr)
plot(show ? orbLow : na, "ORB Low", color=color.rgb(20, 105, 255), linewidth=2, style=plot.style_linebr)

// === ALERTS ===
alertcondition(buySignal, title="Precision ORB BUY", message="Precision ORB BUY")
alertcondition(sellSignal, title="Precision ORB SELL", message="Precision ORB SELL")
alertcondition(upRevWarning or downRevWarning, title="Precision ORB REV Warning", message="REV? breakout candle warning only.")
````
