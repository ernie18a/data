# Crypto Trade Plan Overlay Lite v1

- url: https://www.tradingview.com/script/dKJ1WA0I-Crypto-Trade-Plan-Overlay-Lite-v1/
- type: indicator
- pine_id: PUB;b3673168c52f4c0f919c32fb84c9e562
- version: 1.0

## Description

Crypto Trade Plan Overlay Lite is a BTC/ETH chart-planning overlay that shows bias, setup state, stop/invalidation, TP1, TP2, setup quality, and alert readiness.

What it shows:
- Bias: bullish, bearish, mixed, or avoid
- Setup: LONG, SHORT, WAIT, or CHECK
- Quality: wait, weak, okay, or strong
- Risk: TP1/TP2 R plan
- Signal: armed, fired, waiting, or check preset

When a confirmed setup appears, the overlay can draw entry, stop/invalidation, TP1, and TP2 planning levels. It is meant to make a trade idea easier to inspect, not to guarantee the result.

Lite presets:
- BTC 15m Active
- BTC 1H Day
- BTC 4H Swing
- ETH 15m Active

How to use:
1. Open BTCUSDT or ETHUSDT.
2. Select the matching preset.
3. Read the dashboard first.
4. If the dashboard says WAIT, no clean setup is active.
5. If the dashboard says CHECK, fix symbol/timeframe/preset.
6. If LONG or SHORT appears, inspect entry, stop, TP1, and TP2.
7. Set alerts only after understanding invalidation.

Alerts:
- CTPO Lite Long Setup
- CTPO Lite Short Setup
- Optional JSON alert payload for journaling or webhook workflows

Educational chart tool. Not financial advice. No profit guarantee. Historical examples do not guarantee future results. Signals confirm after candle close. Users control their own risk.

## Source Code

````pine
//@version=6
indicator("Crypto Trade Plan Overlay Lite v1", overlay=true, max_bars_back=5000, max_lines_count=100, max_labels_count=200, max_boxes_count=50)

string groupSetup = "Setup"
string groupRisk = "Trade Plan"
string groupVisual = "Visuals"
string groupAlerts = "Alerts"

string preset = input.string("BTC 4H Swing", "Preset", options=["BTC 15m Active", "BTC 1H Day", "BTC 4H Swing", "ETH 15m Active"], group=groupSetup)
string directionMode = input.string("Long + Short", "Direction", options=["Long + Short", "Long Only", "Short Only"], group=groupSetup)
int minQuality = input.int(65, "Minimum quality score", minval=0, maxval=100, group=groupSetup)

float atrStopMult = input.float(1.8, "Stop distance, ATR", minval=0.5, maxval=8.0, step=0.1, group=groupRisk)
float tp1R = input.float(1.5, "TP1, R multiple", minval=0.5, maxval=10.0, step=0.1, group=groupRisk)
float tp2R = input.float(3.0, "TP2, R multiple", minval=0.5, maxval=20.0, step=0.1, group=groupRisk)
int planForwardBars = input.int(12, "Plan display bars", minval=3, maxval=200, group=groupRisk)

bool showPlanVisuals = input.bool(true, "Show entry / stop / target plan", group=groupVisual)
bool showTrendLines = input.bool(true, "Show trend and value lines", group=groupVisual)
bool showBarTint = input.bool(false, "Tint signal bars", group=groupVisual)
bool showDashboard = input.bool(true, "Show dashboard", group=groupVisual)

bool sendDynamicAlerts = input.bool(false, "Send JSON alert() payload", group=groupAlerts)

int fastLen = switch preset
    "BTC 15m Active" => 21
    "BTC 1H Day" => 34
    "BTC 4H Swing" => 34
    "ETH 15m Active" => 21
    => 34

int slowLen = switch preset
    "BTC 15m Active" => 55
    "BTC 1H Day" => 89
    "BTC 4H Swing" => 144
    "ETH 15m Active" => 55
    => 89

int swingLen = switch preset
    "BTC 15m Active" => 24
    "BTC 1H Day" => 18
    "BTC 4H Swing" => 12
    "ETH 15m Active" => 24
    => 18

int valueLen = switch preset
    "BTC 15m Active" => 48
    "BTC 1H Day" => 34
    "BTC 4H Swing" => 21
    "ETH 15m Active" => 48
    => 34

float atrFloorPct = switch preset
    "BTC 15m Active" => 0.0015
    "BTC 1H Day" => 0.0025
    "BTC 4H Swing" => 0.0040
    "ETH 15m Active" => 0.0020
    => 0.0025

color uiLong = #26A69A
color uiShort = #EF5350
color uiBlue = #42A5F5
color uiTeal = #00BCD4
color uiWarn = #FFB74D
color uiNeutral = #9E9E9E
color uiPanel = color.new(#131722, 8)
color uiLine = color.new(#2A2E39, 35)

float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float valueLine = ta.vwma(close, valueLen)
float rsi = ta.rsi(close, 14)
float atr = ta.atr(14)
float atrPct = atr / close
float volMa = ta.sma(volume, valueLen)

bool allowLong = directionMode != "Short Only"
bool allowShort = directionMode != "Long Only"
bool volatilityOk = atrPct >= atrFloorPct
bool volumeOk = volume >= volMa
bool bullTrend = emaFast > emaSlow and close > emaSlow
bool bearTrend = emaFast < emaSlow and close < emaSlow
bool bullMomentum = rsi > 52 and rsi < 78
bool bearMomentum = rsi < 48 and rsi > 22
bool aboveValue = close >= valueLine
bool belowValue = close <= valueLine

float priorHigh = ta.highest(high, swingLen)[1]
float priorLow = ta.lowest(low, swingLen)[1]
bool reclaimLong = close > emaFast and close[1] <= emaFast[1]
bool reclaimShort = close < emaFast and close[1] >= emaFast[1]
bool breakoutLong = close > priorHigh and close > open
bool breakoutShort = close < priorLow and close < open
bool longTrigger = reclaimLong or breakoutLong
bool shortTrigger = reclaimShort or breakoutShort

string expectedTf = switch preset
    "BTC 15m Active" => "15"
    "BTC 1H Day" => "60"
    "BTC 4H Swing" => "240"
    "ETH 15m Active" => "15"
    => timeframe.period

bool wantsBTC = str.contains(preset, "BTC")
bool wantsETH = str.contains(preset, "ETH")
bool symbolPresetOk = (wantsBTC and str.contains(syminfo.tickerid, "BTC")) or (wantsETH and str.contains(syminfo.tickerid, "ETH"))
bool timeframePresetOk = timeframe.period == expectedTf
bool presetOk = symbolPresetOk and timeframePresetOk

f_quality(isLong) =>
    int score = 0
    score += (isLong ? bullTrend : bearTrend) ? 30 : 0
    score += (isLong ? bullMomentum : bearMomentum) ? 20 : 0
    score += (isLong ? aboveValue : belowValue) ? 15 : 0
    score += volatilityOk ? 15 : 0
    score += volumeOk ? 10 : 0
    score += (isLong ? longTrigger : shortTrigger) ? 10 : 0
    score

f_quality_text(score) =>
    score >= 80 ? "Strong" : score >= 65 ? "Okay" : score >= 45 ? "Weak" : "Wait"

f_quality_color(score) =>
    score >= 80 ? uiLong : score >= 65 ? uiTeal : score >= 45 ? uiWarn : uiNeutral

f_price(price) =>
    str.tostring(price, format.mintick)

f_preset_short(value) =>
    switch value
        "BTC 15m Active" => "BTC 15m"
        "BTC 1H Day" => "BTC 1H"
        "BTC 4H Swing" => "BTC 4H"
        "ETH 15m Active" => "ETH 15m"
        => value

f_delete_line(id) =>
    if not na(id)
        line.delete(id)

f_delete_label(id) =>
    if not na(id)
        label.delete(id)

f_delete_box(id) =>
    if not na(id)
        box.delete(id)

f_json(side, quality, entry, stop, target1, target2) =>
    "{\"schema\":\"ctpo-lite-v1\",\"event\":\"setup\",\"side\":\"" + side + "\",\"ticker\":\"" + syminfo.tickerid + "\",\"timeframe\":\"" + timeframe.period + "\",\"bar_time\":" + str.tostring(time) + ",\"quality\":" + str.tostring(quality) + ",\"entry\":" + f_price(entry) + ",\"stop\":" + f_price(stop) + ",\"tp1\":" + f_price(target1) + ",\"tp2\":" + f_price(target2) + ",\"preset\":\"" + preset + "\"}"

int longQuality = f_quality(true)
int shortQuality = f_quality(false)

bool longSignalRaw = barstate.isconfirmed and presetOk and allowLong and bullTrend and bullMomentum and longTrigger and volatilityOk and longQuality >= minQuality
bool shortSignalRaw = barstate.isconfirmed and presetOk and allowShort and bearTrend and bearMomentum and shortTrigger and volatilityOk and shortQuality >= minQuality
bool longSignal = longSignalRaw and (not shortSignalRaw or longQuality >= shortQuality)
bool shortSignal = shortSignalRaw and not longSignal

float longStop = math.min(priorLow, close - atr * atrStopMult)
float shortStop = math.max(priorHigh, close + atr * atrStopMult)
float longRisk = close - longStop
float shortRisk = shortStop - close
bool longPlanValid = longSignal and longRisk > syminfo.mintick
bool shortPlanValid = shortSignal and shortRisk > syminfo.mintick

var bool planActive = false
var int planDir = 0
var int planStartBar = na
var float planEntry = na
var float planStop = na
var float planTP1 = na
var float planTP2 = na
var string planSetup = "WAIT"
var int planQuality = na

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var box riskBox = na
var box rewardBox = na
var label signalLabel = na
var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label statusLabel = na

bool stopHit = planActive and ((planDir == 1 and low <= planStop) or (planDir == -1 and high >= planStop))
bool tp2Hit = planActive and ((planDir == 1 and high >= planTP2) or (planDir == -1 and low <= planTP2))
bool planExpired = planActive and bar_index - planStartBar > planForwardBars
bool clearPlan = stopHit or tp2Hit or planExpired or longPlanValid or shortPlanValid

if clearPlan
    f_delete_line(entryLine)
    f_delete_line(stopLine)
    f_delete_line(tp1Line)
    f_delete_line(tp2Line)
    f_delete_box(riskBox)
    f_delete_box(rewardBox)
    f_delete_label(signalLabel)
    f_delete_label(entryLabel)
    f_delete_label(stopLabel)
    f_delete_label(tp1Label)
    f_delete_label(tp2Label)
    f_delete_label(statusLabel)
    entryLine := na
    stopLine := na
    tp1Line := na
    tp2Line := na
    riskBox := na
    rewardBox := na
    signalLabel := na
    entryLabel := na
    stopLabel := na
    tp1Label := na
    tp2Label := na
    statusLabel := na
    planActive := false

if not showPlanVisuals
    f_delete_line(entryLine)
    f_delete_line(stopLine)
    f_delete_line(tp1Line)
    f_delete_line(tp2Line)
    f_delete_box(riskBox)
    f_delete_box(rewardBox)
    f_delete_label(signalLabel)
    f_delete_label(entryLabel)
    f_delete_label(stopLabel)
    f_delete_label(tp1Label)
    f_delete_label(tp2Label)
    f_delete_label(statusLabel)
    entryLine := na
    stopLine := na
    tp1Line := na
    tp2Line := na
    riskBox := na
    rewardBox := na
    signalLabel := na
    entryLabel := na
    stopLabel := na
    tp1Label := na
    tp2Label := na
    statusLabel := na

if longPlanValid or shortPlanValid
    int side = longPlanValid ? 1 : -1
    float risk = longPlanValid ? longRisk : shortRisk
    float entry = close
    float stop = longPlanValid ? longStop : shortStop
    float target1 = side == 1 ? entry + risk * tp1R : entry - risk * tp1R
    float target2 = side == 1 ? entry + risk * tp2R : entry - risk * tp2R
    int quality = side == 1 ? longQuality : shortQuality
    string sideText = side == 1 ? "LONG" : "SHORT"
    string triggerText = side == 1 ? (breakoutLong ? "Breakout" : "Pullback") : (breakoutShort ? "Breakdown" : "Pullback")
    int right = bar_index + planForwardBars
    int labelX = right
    planActive := true
    planDir := side
    planStartBar := bar_index
    planEntry := entry
    planStop := stop
    planTP1 := target1
    planTP2 := target2
    planSetup := triggerText + " " + sideText
    planQuality := quality
    if showPlanVisuals
        color sideColor = side == 1 ? uiLong : uiShort
        float signalY = side == 1 ? low - atr * 0.35 : high + atr * 0.35
        signalStyle = side == 1 ? label.style_label_up : label.style_label_down
        signalLabel := label.new(bar_index, signalY, sideText + " " + f_quality_text(quality), xloc=xloc.bar_index, style=signalStyle, color=color.new(sideColor, 0), textcolor=color.white, size=size.small, tooltip="Entry " + f_price(entry) + "\nStop " + f_price(stop) + "\nTP1 " + f_price(target1) + "\nTP2 " + f_price(target2) + "\nQuality " + str.tostring(quality))
        entryLine := line.new(bar_index, entry, right, entry, xloc=xloc.bar_index, color=color.new(uiBlue, 0), style=line.style_dotted, width=1)
        stopLine := line.new(bar_index, stop, right, stop, xloc=xloc.bar_index, color=color.new(uiShort, 0), style=line.style_solid, width=1)
        tp1Line := line.new(bar_index, target1, right, target1, xloc=xloc.bar_index, color=color.new(uiTeal, 0), style=line.style_dashed, width=1)
        tp2Line := line.new(bar_index, target2, right, target2, xloc=xloc.bar_index, color=color.new(uiLong, 0), style=line.style_dashed, width=1)
        riskBox := box.new(bar_index, math.max(entry, stop), right, math.min(entry, stop), xloc=xloc.bar_index, bgcolor=color.new(uiShort, 90), border_color=color.new(uiShort, 55))
        rewardBox := box.new(bar_index, math.max(entry, target2), right, math.min(entry, target2), xloc=xloc.bar_index, bgcolor=color.new(uiLong, 91), border_color=color.new(uiLong, 55))
        entryLabel := label.new(labelX, entry, "ENTRY " + f_price(entry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(uiBlue, 0), textcolor=color.white, size=size.tiny)
        stopLabel := label.new(labelX, stop, "STOP " + f_price(stop), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(uiShort, 0), textcolor=color.white, size=size.tiny)
        tp1Label := label.new(labelX, target1, "TP1 " + str.tostring(tp1R, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(uiTeal, 0), textcolor=color.white, size=size.tiny)
        tp2Label := label.new(labelX, target2, "TP2 " + str.tostring(tp2R, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(uiLong, 0), textcolor=color.white, size=size.tiny)
        float statusY = side == 1 ? target2 + math.abs(target2 - entry) * 0.05 : target2 - math.abs(target2 - entry) * 0.05
        statusLabel := label.new(labelX, statusY, f_quality_text(quality) + " " + str.tostring(quality), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(f_quality_color(quality), 10), textcolor=color.white, size=size.tiny)
    if sendDynamicAlerts
        alert(f_json(side == 1 ? "long" : "short", quality, entry, stop, target1, target2), alert.freq_once_per_bar_close)

if planActive and showPlanVisuals
    int right = bar_index + planForwardBars
    int labelX = right
    if not na(entryLine)
        line.set_x2(entryLine, right)
    if not na(stopLine)
        line.set_x2(stopLine, right)
    if not na(tp1Line)
        line.set_x2(tp1Line, right)
    if not na(tp2Line)
        line.set_x2(tp2Line, right)
    if not na(riskBox)
        box.set_right(riskBox, right)
    if not na(rewardBox)
        box.set_right(rewardBox, right)
    if not na(entryLabel)
        label.set_x(entryLabel, labelX)
    if not na(stopLabel)
        label.set_x(stopLabel, labelX)
    if not na(tp1Label)
        label.set_x(tp1Label, labelX)
    if not na(tp2Label)
        label.set_x(tp2Label, labelX)
    if not na(statusLabel)
        label.set_x(statusLabel, labelX)

plot(showTrendLines ? emaFast : na, "Fast trend", color=color.new(uiBlue, 10), linewidth=1)
plot(showTrendLines ? emaSlow : na, "Slow trend", color=color.new(uiNeutral, 20), linewidth=2)
plot(showTrendLines ? valueLine : na, "Volume value line", color=color.new(uiWarn, 20), linewidth=1)
barcolor(showBarTint ? (longSignal ? color.new(uiLong, 0) : shortSignal ? color.new(uiShort, 0) : na) : na)

string biasText = not volatilityOk ? "Avoid" : bullTrend ? "Bullish" : bearTrend ? "Bearish" : "Mixed"
color biasColor = not volatilityOk ? uiWarn : bullTrend ? uiLong : bearTrend ? uiShort : uiNeutral
int liveQuality = bullTrend ? longQuality : bearTrend ? shortQuality : math.max(longQuality, shortQuality)
bool setupLive = longSignal or shortSignal or planActive
int displayQuality = planActive and not na(planQuality) ? planQuality : liveQuality
string modeText = presetOk ? f_preset_short(preset) : "Check preset"
string setupText = not presetOk ? "CHECK" : longSignal ? "LONG" : shortSignal ? "SHORT" : planActive ? (planDir == 1 ? "LONG" : "SHORT") : "WAIT"
string qualityText = not presetOk ? "Preset" : setupLive ? f_quality_text(displayQuality) + " " + str.tostring(displayQuality) : "WAIT"
color qualityBg = not presetOk ? uiWarn : setupLive ? f_quality_color(displayQuality) : uiNeutral
string signalText = not presetOk ? "Check preset" : longSignal or shortSignal ? "Fired" : volatilityOk ? "Armed" : "Waiting"

var table dash = table.new(position.middle_right, 2, 7, bgcolor=uiPanel, frame_color=uiLine, border_color=uiLine, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "TPO", text_color=color.white, bgcolor=color.new(#0B1118, 0), text_size=size.small)
    table.cell(dash, 1, 0, "Lite", text_color=color.new(color.white, 15), bgcolor=color.new(#0B1118, 0), text_size=size.small)
    table.cell(dash, 0, 1, "Mode", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 1, modeText, text_color=color.white, bgcolor=not presetOk ? color.new(uiWarn, 25) : na, text_size=size.tiny)
    table.cell(dash, 0, 2, "Bias", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 2, biasText, text_color=color.white, bgcolor=color.new(biasColor, 20), text_size=size.tiny)
    table.cell(dash, 0, 3, "Setup", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 3, setupText, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 4, "Quality", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 4, qualityText, text_color=color.white, bgcolor=color.new(qualityBg, 25), text_size=size.tiny)
    table.cell(dash, 0, 5, "Risk", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(tp1R, "#.##") + "R / " + str.tostring(tp2R, "#.##") + "R", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 6, "Signal", text_color=color.new(color.white, 25), text_size=size.tiny)
    table.cell(dash, 1, 6, signalText, text_color=color.white, text_size=size.tiny)

if not showDashboard and barstate.islast
    for col = 0 to 1
        for row = 0 to 6
            table.cell(dash, col, row, "", text_color=color.new(color.white, 100), bgcolor=color.new(#131722, 100), text_size=size.tiny)

alertcondition(longSignal, title="CTPO Lite Long Setup", message="Crypto Trade Plan Overlay Lite: LONG setup confirmed after bar close. Open chart for entry, stop, TP1, and TP2.")
alertcondition(shortSignal, title="CTPO Lite Short Setup", message="Crypto Trade Plan Overlay Lite: SHORT setup confirmed after bar close. Open chart for entry, stop, TP1, and TP2.")
````
