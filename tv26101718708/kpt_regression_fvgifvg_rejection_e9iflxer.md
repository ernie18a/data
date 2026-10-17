# KPT Regression FVG/IFVG Rejection

- url: https://www.tradingview.com/script/e9IFlxER-KPT-Regression-FVG-IFVG-Rejection/
- type: indicator
- pine_id: PUB;b425165722d44f02905f7e7e104312d7
- version: 1.0

## Description

[b]📊 KPT Regression FVG/IFVG Rejection Signals (RR + Automation Ready)[/b]

This indicator combines [b]regression-based momentum[/b], [b]Fair Value Gap (FVG / IFVG) structure[/b], and [b]risk-managed trade execution[/b] into a complete system designed for high-probability reversal entries and automated trading.

━━━━━━━━━━━━━━━━━━━━

[b]🧠 How It Works[/b]

This script is built around three core concepts:

[b]1. Regression Bias (Market Direction)[/b]
The regression engine measures where price is relative to its statistical mean:
• y > 0 → bullish momentum  
• y < 0 → bearish momentum  
• Zero-line crosses help confirm trend shifts  

This acts as your [b]bias filter[/b], keeping you trading with flow instead of against it.

━━━━━━━━━━━━━━━━━━━━

[b]2. FVG / IFVG Liquidity Zones (Entry Logic)[/b]

The script detects [b]Fair Value Gaps (FVGs)[/b]:
• Bullish FVG → imbalance below price  
• Bearish FVG → imbalance above price  

It also tracks [b]IFVG flips[/b]:
• Bullish FVG breaks → becomes bearish IFVG  
• Bearish FVG breaks → becomes bullish IFVG  

These zones represent [b]liquidity inefficiencies[/b] where price is likely to react.

━━━━━━━━━━━━━━━━━━━━

[b]3. Rejection-Based Entries (Execution)[/b]

Trades trigger when:
• Price returns into a zone  
• Price [b]rejects[/b] that zone (not just taps it)  
• Regression bias confirms direction  

✔ No random entries  
✔ No chasing  
✔ Only structured reactions  

━━━━━━━━━━━━━━━━━━━━

[b]📦 Built-In Risk Management (RR Mode)[/b]

[b]Zone RR Mode (Recommended)[/b]
• Stop Loss → below/above FVG zone  
• Take Profit → based on RR multiple (ex: 1.2R)

[b]Fixed Mode[/b]
• Manual SL/TP in ticks

━━━━━━━━━━━━━━━━━━━━

[b]📈 Visual Trade Boxes[/b]

Each trade automatically draws:
• 🟢 Profit zone (TP)  
• 🔴 Risk zone (SL)  
• 📍 Entry, SL, TP labeled  

This gives you [b]instant visual feedback[/b] on trade quality and RR.

━━━━━━━━━━━━━━━━━━━━

[b]🕐 NY Session Control[/b]

Built-in session protection:
• Optional [b]NY session only trading[/b]  
• 🚫 [b]No trades 30 minutes before NY close[/b]  

Helps avoid low-liquidity chop and bad fills.

━━━━━━━━━━━━━━━━━━━━

[b]🤖 Automation Ready (KingPhantomTrading)[/b]

This script is fully integrated with webhook automation.

It sends [b]dynamic trade data in real-time[/b], including:
• Action (buy/sell)  
• Symbol  
• Entry price  
• Stop loss  
• Take profit  
• Unique signal ID  

Connect your automation here:
👉 https://kingphantomtrading.com/

[b]Platform Features:[/b]
• Multi-account trade routing  
• Performance tracking & analytics  
• Strategy management dashboard  
• Discord + automation integrations  

Includes a [b]free plan[/b] to get started.

━━━━━━━━━━━━━━━━━━━━

[b]⚙️ Key Features[/b]

• Regression-based trend filtering  
• FVG + IFVG detection  
• Rejection-based entries  
• Closest liquidity zone highlighting  
• One-trade-per-side logic  
• RR-based trade management  
• Visual SL/TP boxes  
• NY session + cutoff protection  
• Fully automated webhook alerts  

━━━━━━━━━━━━━━━━━━━━

[b]⚠️ Important Notes[/b]

• Best used on liquid markets (indices, futures, forex)  
• Works best with structure + liquidity context  
• Not designed for random scalping — this is [b]precision trading[/b]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BigBeluga
// Modified by KPT: Regression + FVG/IFVG Rejection Signals + RR Boxes + NY Cutoff + KPT Alerts

//@version=6
indicator("KPT Regression FVG/IFVG Rejection Signals RR", overlay=true, max_bars_back=500, max_boxes_count=500, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupReg = "Regression"
length  = input.int(400, "Regression Length", minval=20, group=groupReg)
length1 = input.int(100, "Regression Normalization", minval=20, group=groupReg)
length2 = input.int(50, "Signal Line", minval=5, group=groupReg)

groupFVG = "FVG / IFVG"
useFVG = input.bool(true, "Use FVG Zones", group=groupFVG)
useIFVG = input.bool(true, "Use IFVG Flip Zones", group=groupFVG)
maxZones = input.int(25, "Max Active Zones", minval=1, maxval=100, group=groupFVG)
deleteMitigated = input.bool(false, "Delete Zone After Signal", group=groupFVG)
deleteInvalid = input.bool(false, "Delete Invalid Instead Of Flip", group=groupFVG)
zoneExtendBars = input.int(150, "Zone Extend Bars", minval=20, maxval=500, group=groupFVG)
minGapTicks = input.int(1, "Minimum FVG Size Ticks", minval=0, group=groupFVG)

groupSignal = "Signals"
signalOnClose = input.bool(true, "Only Signal On Bar Close", group=groupSignal)
alternateSignals = input.bool(true, "Alternate Long/Short Signals", group=groupSignal)
requireRegressionBias = input.bool(true, "Require Regression Bias", group=groupSignal)
requireRejectionCandle = input.bool(true, "Require Candle Direction Rejection", group=groupSignal)

groupSession = "NY Session Cutoff"
useNYSessionFilter = input.bool(false, "Only Allow Trades During NY Session", group=groupSession)
useNYCutoff = input.bool(true, "Block Trades 30 Minutes Before NY Close", group=groupSession)
nySession = input.session("0930-1600", "NY Session", group=groupSession)
nyNoTradeSession = input.session("1530-1600", "NY No Trade Zone", group=groupSession)
nyTimezone = input.string("America/New_York", "NY Timezone", group=groupSession)
showNoTradeBg = input.bool(true, "Show NY No Trade Background", group=groupSession)

groupRisk = "RR / Bracket"
riskMode = input.string("Zone RR", "Risk Mode", options=["Fixed Ticks", "Zone RR"], group=groupRisk)
rrMultiple = input.float(1.2, "RR Multiple", minval=0.1, step=0.1, group=groupRisk)
fixedStopTicks = input.float(40, "Fixed Stop Ticks", minval=1, group=groupRisk)
fixedTargetTicks = input.float(80, "Fixed Target Ticks", minval=1, group=groupRisk)
zoneStopBufferTicks = input.int(4, "Zone Stop Buffer Ticks", minval=0, group=groupRisk)
alertSLTPMode = input.string("Prices", "Alert SL/TP Mode", options=["Prices", "Ticks"], group=groupRisk)

groupRRBox = "RR Box Visuals"
showRRBoxes = input.bool(true, "Show RR Boxes", group=groupRRBox)
rrBoxBars = input.int(30, "RR Box Extend Bars", minval=5, maxval=300, group=groupRRBox)
maxRRBoxes = input.int(40, "Max RR Box Sets", minval=1, maxval=100, group=groupRRBox)

groupVisual = "Visuals"
showRegressionLine = input.bool(true, "Show Regression Line", group=groupVisual)
showCandleColor = input.bool(true, "Color Candles", group=groupVisual)
showSignals = input.bool(true, "Show Buy/Sell Labels", group=groupVisual)

bullColor = input.color(color.new(color.aqua, 78), "Bullish Zone Color", group=groupVisual)
bearColor = input.color(color.new(color.red, 78), "Bearish Zone Color", group=groupVisual)
ifvgBullColor = input.color(color.new(color.lime, 76), "Bullish IFVG Color", group=groupVisual)
ifvgBearColor = input.color(color.new(color.orange, 76), "Bearish IFVG Color", group=groupVisual)
closestColor = input.color(color.new(color.purple, 65), "Closest Zone Color", group=groupVisual)
regColor = input.color(#049ef7, "Regression Bull Color", group=groupVisual)

groupKPT = "KingPhantomTrading Alerts"
webhookSecret = input.string("a07de788fb88bd6d8c42c84a", "Webhook Secret", group=groupKPT)
strategyKey = input.string("kpt_regression", "Strategy Key", group=groupKPT)
qty = input.int(1, "Qty", minval=1, group=groupKPT)

//====================================================
// REGRESSION BASE
//====================================================
regression_indicator(src, len) =>
    sum_x = 0.0
    sum_y = 0.0
    sum_xy = 0.0
    sum_x_sq = 0.0

    for i = 0 to len - 1
        x = i + 1
        sum_x := sum_x + x
        sum_y := sum_y + src[i]
        sum_xy := sum_xy + x * src[i]
        sum_x_sq := sum_x_sq + math.pow(x, 2)

    slope = (len * sum_xy - sum_x * sum_y) / (len * sum_x_sq - math.pow(sum_x, 2))
    intercept = (sum_y - slope * sum_x) / len
    y1 = intercept + slope

    distance = close - y1
    stdev = ta.stdev(distance, length1)
    norm = stdev != 0 ? (distance - ta.sma(distance, length1)) / stdev : 0.0
    distance_n = ta.sma(norm, 10)

    [distance_n, y1]

[y, y1] = regression_indicator(close, length)

mean = ta.sma(y, length2)
mean1 = ta.ema(y, 5)

regBull = y > 0
regBear = y < 0
trendUpCross = ta.crossover(y, 0)
trendDnCross = ta.crossunder(y, 0)

candleColor = y > 0 ? color.from_gradient(y, 0, 1, na, regColor) : color.from_gradient(y, -1, 0, chart.fg_color, na)

barcolor(showCandleColor ? candleColor : na)
plot(showRegressionLine ? y1 : na, "Regression Line", color=candleColor, linewidth=2)

//====================================================
// SESSION FILTER
//====================================================
inNYSession = not na(time(timeframe.period, nySession, nyTimezone))
inNYNoTrade = not na(time(timeframe.period, nyNoTradeSession, nyTimezone))

sessionAllowed = not useNYSessionFilter or inNYSession
cutoffAllowed = not useNYCutoff or not inNYNoTrade
tradeWindowAllowed = sessionAllowed and cutoffAllowed

bgcolor(showNoTradeBg and useNYCutoff and inNYNoTrade ? color.new(color.red, 88) : na, title="NY No Trade Zone")

//====================================================
// ARRAYS
//====================================================
var array<box> zones = array.new_box()
var array<float> tops = array.new_float()
var array<float> bottoms = array.new_float()
var array<int> sides = array.new_int()
var array<bool> ifvgs = array.new_bool()
var array<bool> used = array.new_bool()

var array<box> rrProfitBoxes = array.new_box()
var array<box> rrRiskBoxes = array.new_box()
var array<label> rrLabels = array.new_label()

var int lastSignalSide = 0

minGap = minGapTicks * syminfo.mintick
barReady = signalOnClose ? barstate.isconfirmed : true

//====================================================
// FUNCTIONS
//====================================================
f_delete_zone(int idx) =>
    if idx >= 0 and idx < array.size(zones)
        bx = array.get(zones, idx)
        if not na(bx)
            box.delete(bx)

        array.remove(zones, idx)
        array.remove(tops, idx)
        array.remove(bottoms, idx)
        array.remove(sides, idx)
        array.remove(ifvgs, idx)
        array.remove(used, idx)

f_zone_color(int side, bool isIfvg, bool isClosest) =>
    color result = bearColor

    if isClosest
        result := closestColor
    else if side == 1 and isIfvg
        result := ifvgBullColor
    else if side == -1 and isIfvg
        result := ifvgBearColor
    else if side == 1
        result := bullColor
    else
        result := bearColor

    result

f_zone_text(int side, bool isIfvg) =>
    string txt = "Bear IFVG"

    if side == 1 and not isIfvg
        txt := "Bull FVG"
    else if side == -1 and not isIfvg
        txt := "Bear FVG"
    else if side == 1 and isIfvg
        txt := "Bull IFVG"
    else
        txt := "Bear IFVG"

    txt

f_add_zone(float top, float bottom, int side, bool isIfvg) =>
    bx = box.new(left=bar_index - 2, top=top, right=bar_index + zoneExtendBars, bottom=bottom, bgcolor=f_zone_color(side, isIfvg, false), border_color=color.new(color.white, 75), text=f_zone_text(side, isIfvg), text_color=color.white, text_size=size.tiny)

    array.push(zones, bx)
    array.push(tops, top)
    array.push(bottoms, bottom)
    array.push(sides, side)
    array.push(ifvgs, isIfvg)
    array.push(used, false)

f_touch_zone(float top, float bottom) =>
    high >= bottom and low <= top

f_reject_bull(float top, float bottom) =>
    touched = f_touch_zone(top, bottom)
    closeAbove = close > bottom
    candleOk = not requireRejectionCandle or close > open
    touched and closeAbove and candleOk

f_reject_bear(float top, float bottom) =>
    touched = f_touch_zone(top, bottom)
    closeBelow = close < top
    candleOk = not requireRejectionCandle or close < open
    touched and closeBelow and candleOk

f_trim_rr_boxes() =>
    while array.size(rrProfitBoxes) > maxRRBoxes
        pb = array.get(rrProfitBoxes, 0)
        rb = array.get(rrRiskBoxes, 0)
        lb = array.get(rrLabels, 0)

        if not na(pb)
            box.delete(pb)
        if not na(rb)
            box.delete(rb)
        if not na(lb)
            label.delete(lb)

        array.remove(rrProfitBoxes, 0)
        array.remove(rrRiskBoxes, 0)
        array.remove(rrLabels, 0)

f_draw_rr(bool isLong, float entry, float stop, float target) =>
    if showRRBoxes
        profitTop = isLong ? target : entry
        profitBottom = isLong ? entry : target
        riskTop = isLong ? entry : stop
        riskBottom = isLong ? stop : entry

        profitBox = box.new(left=bar_index, top=profitTop, right=bar_index + rrBoxBars, bottom=profitBottom, bgcolor=color.new(color.lime, 82), border_color=color.new(color.lime, 25), text="TP", text_color=color.white, text_size=size.tiny)
        riskBox = box.new(left=bar_index, top=riskTop, right=bar_index + rrBoxBars, bottom=riskBottom, bgcolor=color.new(color.red, 82), border_color=color.new(color.red, 25), text="SL", text_color=color.white, text_size=size.tiny)

        labelText = (isLong ? "LONG " : "SHORT ") + str.tostring(rrMultiple) + "R\nEntry: " + str.tostring(entry, format.mintick) + "\nSL: " + str.tostring(stop, format.mintick) + "\nTP: " + str.tostring(target, format.mintick)
        rrLabel = label.new(x=bar_index, y=target, text=labelText, style=label.style_label_left, color=color.new(color.black, 10), textcolor=color.white, size=size.small)

        array.push(rrProfitBoxes, profitBox)
        array.push(rrRiskBoxes, riskBox)
        array.push(rrLabels, rrLabel)

        f_trim_rr_boxes()

f_calc_stop(bool isLong, float top, float bottom, float entry) =>
    float stop = na
    buffer = zoneStopBufferTicks * syminfo.mintick

    if riskMode == "Fixed Ticks"
        stop := isLong ? entry - fixedStopTicks * syminfo.mintick : entry + fixedStopTicks * syminfo.mintick
    else
        stop := isLong ? bottom - buffer : top + buffer

    stop

f_calc_target(bool isLong, float entry, float stop) =>
    float target = na

    if riskMode == "Fixed Ticks"
        target := isLong ? entry + fixedTargetTicks * syminfo.mintick : entry - fixedTargetTicks * syminfo.mintick
    else
        risk = math.abs(entry - stop)
        target := isLong ? entry + risk * rrMultiple : entry - risk * rrMultiple

    target

f_payload_value(float entry, float priceValue) =>
    float result = priceValue

    if alertSLTPMode == "Ticks"
        result := math.abs(entry - priceValue) / syminfo.mintick

    str.tostring(result, format.mintick)

f_kptPayload(string action, float entry, float stop, float target) =>
    string payload = ""
    payload := payload + "action=" + action + "\n"
    payload := payload + "symbol=" + syminfo.ticker + "\n"
    payload := payload + "secret=" + webhookSecret + "\n"
    payload := payload + "strategy=" + strategyKey + "\n"
    payload := payload + "signal_id=kpt-" + syminfo.ticker + "-" + timeframe.period + "-" + str.tostring(time) + "\n"
    payload := payload + "qty=" + str.tostring(qty) + "\n"
    payload := payload + "bracket=fixed\n"
    payload := payload + "order_type=market\n"
    payload := payload + "tif=DAY\n"
    payload := payload + "reference_price=" + str.tostring(entry, format.mintick) + "\n"
    payload := payload + "stop_loss=" + f_payload_value(entry, stop) + "\n"
    payload := payload + "take_profit=" + f_payload_value(entry, target)
    payload

//====================================================
// CREATE FVG ZONES
//====================================================
bullFVG = useFVG and low > high[2] and (low - high[2]) >= minGap
bearFVG = useFVG and high < low[2] and (low[2] - high) >= minGap

if bullFVG
    f_add_zone(low, high[2], 1, false)

if bearFVG
    f_add_zone(low[2], high, -1, false)

//====================================================
// FLIP INVALID FVG INTO IFVG
//====================================================
if array.size(zones) > 0
    i = array.size(zones) - 1
    while i >= 0
        top = array.get(tops, i)
        bottom = array.get(bottoms, i)
        side = array.get(sides, i)
        isIfvg = array.get(ifvgs, i)

        bullInvalid = side == 1 and close < bottom
        bearInvalid = side == -1 and close > top

        if not isIfvg and useIFVG and not deleteInvalid
            if bullInvalid
                array.set(sides, i, -1)
                array.set(ifvgs, i, true)
                array.set(used, i, false)

            if bearInvalid
                array.set(sides, i, 1)
                array.set(ifvgs, i, true)
                array.set(used, i, false)

        else if not isIfvg and deleteInvalid
            if bullInvalid or bearInvalid
                f_delete_zone(i)

        i -= 1

//====================================================
// TRIM OLD ZONES
//====================================================
while array.size(zones) > maxZones
    f_delete_zone(0)

//====================================================
// CLOSEST ZONE
//====================================================
int closestIndex = na
float closestDist = na

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        top = array.get(tops, i)
        bottom = array.get(bottoms, i)
        mid = (top + bottom) / 2.0
        dist = math.abs(close - mid)

        if na(closestDist) or dist < closestDist
            closestDist := dist
            closestIndex := i

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        bx = array.get(zones, i)
        side = array.get(sides, i)
        isIfvg = array.get(ifvgs, i)

        isClosest = i == closestIndex
        box.set_right(bx, bar_index + zoneExtendBars)
        box.set_bgcolor(bx, f_zone_color(side, isIfvg, isClosest))
        box.set_text(bx, isClosest ? "Closest " + f_zone_text(side, isIfvg) : f_zone_text(side, isIfvg))

//====================================================
// SIGNALS
//====================================================
bool buySignal = false
bool sellSignal = false
float signalEntry = na
float signalStop = na
float signalTarget = na

canBuy = not alternateSignals or lastSignalSide != 1
canSell = not alternateSignals or lastSignalSide != -1

if barReady and tradeWindowAllowed and array.size(zones) > 0
    i = array.size(zones) - 1
    while i >= 0
        top = array.get(tops, i)
        bottom = array.get(bottoms, i)
        side = array.get(sides, i)
        wasUsed = array.get(used, i)

        longBias = not requireRegressionBias or regBull or trendUpCross
        shortBias = not requireRegressionBias or regBear or trendDnCross

        validLong = side == 1 and not wasUsed and canBuy and longBias and f_reject_bull(top, bottom)
        validShort = side == -1 and not wasUsed and canSell and shortBias and f_reject_bear(top, bottom)

        if validLong and not buySignal and not sellSignal
            entry = close
            stop = f_calc_stop(true, top, bottom, entry)
            target = f_calc_target(true, entry, stop)

            validRisk = stop < entry and target > entry

            if validRisk
                buySignal := true
                signalEntry := entry
                signalStop := stop
                signalTarget := target
                lastSignalSide := 1
                array.set(used, i, true)
                f_draw_rr(true, entry, stop, target)

                if deleteMitigated
                    f_delete_zone(i)

        if validShort and not buySignal and not sellSignal
            entry = close
            stop = f_calc_stop(false, top, bottom, entry)
            target = f_calc_target(false, entry, stop)

            validRisk = stop > entry and target < entry

            if validRisk
                sellSignal := true
                signalEntry := entry
                signalStop := stop
                signalTarget := target
                lastSignalSide := -1
                array.set(used, i, true)
                f_draw_rr(false, entry, stop, target)

                if deleteMitigated
                    f_delete_zone(i)

        i -= 1

//====================================================
// VISUAL SIGNALS
//====================================================
plotshape(showSignals and buySignal, title="BUY FVG/IFVG Rejection", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, text="BUY\nFVG", size=size.small)
plotshape(showSignals and sellSignal, title="SELL FVG/IFVG Rejection", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, text="SELL\nFVG", size=size.small)

plotchar(trendUpCross ? close : na, "Regression Trend Up", "⦿", location=location.absolute, color=#0364a5, size=size.tiny)
plotchar(trendDnCross ? close : na, "Regression Trend Down", "⦿", location=location.absolute, color=chart.fg_color, size=size.tiny)

//====================================================
// ALERTS
//====================================================
if buySignal
    alert(f_kptPayload("buy", signalEntry, signalStop, signalTarget), alert.freq_once_per_bar_close)

if sellSignal
    alert(f_kptPayload("sell", signalEntry, signalStop, signalTarget), alert.freq_once_per_bar_close)
````
