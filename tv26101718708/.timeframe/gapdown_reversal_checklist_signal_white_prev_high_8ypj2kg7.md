# Gap-Down Reversal Checklist Signal (WHITE - Prev. High)

- url: https://www.tradingview.com/script/8ypJ2kG7-Gap-Down-Reversal-Checklist-Signal-WHITE-Prev-High/
- type: indicator
- pine_id: PUB;a41bd10c7f3940e1b0444af097658f3e
- version: 1.0

## Description

This indicator is a bullish gap-down reversal scanner that identifies stocks recovering from early weakness and regaining technical strength throughout the trading session. Unlike the previous version, it uses the previous regular trading session high (RTH high) rather than the previous daily candle high as a key confirmation level.

What It Looks For

A bullish reversal signal ("R") is generated when the stock:

Trades above VWAP → intraday buyers are in control.
Reclaims the previous day's close → gap-down weakness has been reversed.
Breaks above the 15-minute Opening Range High → confirms momentum.
Approaches or exceeds the prior regular-session high → demonstrates significant recovery strength.
Shows constructive interaction with the 50-day or 200-day moving average (optional requirement).
Has RSI below a specified limit (default 70) → avoids chasing overbought conditions.
Has a rising or flat RSI moving average → momentum is improving.
Key Difference vs. the Green Version

Instead of comparing price to the previous day's high, this version compares price to the:

Previous Regular Trading Hours (RTH) High

This can provide a cleaner institutional reference point by excluding premarket and after-hours price action.

Visual Output

Green "R" Label

All checklist conditions are satisfied.
Represents a high-quality reversal candidate.

Yellow Circle

Partial setup.
At least 4 of the 7 conditions are met.

Red X

Technical reversal conditions are met, but RSI is already above the maximum threshold.

Orange X

Reversal conditions are met, but the RSI moving average is declining.
Dashboard

The dashboard continuously tracks:

Above VWAP
Reclaimed prior close
Above Opening Range High
Near/Above Previous RTH High
Constructive 50D/200D interaction
RSI below threshold
RSI MA trend
Total setup score (0–7)
Best Use Case

This indicator is particularly useful for:

Gap-down reversal trades
Failed breakdown setups
Intraday momentum recoveries
Earnings/news reversals
Relative-strength stocks reclaiming key levels

## Source Code

````pine
//@version=5
indicator("Gap-Down Reversal Checklist Signal (WHITE - Prev. High)", overlay=true, max_labels_count=500)

// Inputs
orSession = input.session("0930-0945", "Opening Range Window")
regularSession = input.session("0930-1600", "Regular Session")
nearPct = input.float(0.50, "Near Previous High / MA Threshold (%)", step=0.05)
requireMAFilter = input.bool(false, "Require 50D/200D Constructive Interaction?")
rsiLength = input.int(14, "RSI Length", minval=1)
rsiLimit = input.float(70.0, "Only Show Signal When RSI Below", step=0.5)
rsiMaType = input.string("SMA", "RSI-based MA Type", options=["None", "SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
rsiMaLength = input.int(14, "RSI-based MA Length", minval=1)
showVWAP = input.bool(true, "Show VWAP")
showORH = input.bool(true, "Show Opening Range High")
showPrevClose = input.bool(true, "Show Previous Close")
showPrevHigh = input.bool(true, "Show Previous Regular Session High")
showDailyMAs = input.bool(true, "Show 50D / 200D MAs")

// Session logic
inRegularSession = not na(time(timeframe.period, regularSession))
inORWindow = not na(time(timeframe.period, orSession))
newDay = ta.change(time("D"))

// Opening range high / low
var float orHigh = na
var float orLow = na
var bool orDone = false

if newDay
    orHigh := na
    orLow := na
    orDone := false

if inORWindow
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

if not inORWindow and not na(orHigh)
    orDone := true

// Previous regular-session high
newRegularSession = inRegularSession and not inRegularSession[1]

var float currentRegularHigh = na
var float prevRegularHigh = na

if newRegularSession
    prevRegularHigh := currentRegularHigh
    currentRegularHigh := high
else if inRegularSession
    currentRegularHigh := na(currentRegularHigh) ? high : math.max(currentRegularHigh, high)

prevHigh = prevRegularHigh

// Daily reference levels
prevClose = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)
dailyMA50 = request.security(syminfo.tickerid, "D", ta.sma(close, 50), barmerge.gaps_off, barmerge.lookahead_off)
dailyMA200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

// VWAP
vwapValue = ta.vwap(hlc3)

// RSI
rsiValue = ta.rsi(close, rsiLength)
rsiOk = rsiValue < rsiLimit

// RSI-based MA function
rsiMa(source, length, maType) =>
    switch maType
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        => na

// RSI-based MA slope filter
enableRsiMa = rsiMaType != "None"
rsiBasedMA = enableRsiMa ? rsiMa(rsiValue, rsiMaLength, rsiMaType) : na
rsiMaSlopeOk = not enableRsiMa or na(rsiBasedMA[1]) or rsiBasedMA >= rsiBasedMA[1]

// Checklist conditions
aboveVWAP = close > vwapValue
reclaimedPrevClose = close > prevClose
brokeORH = orDone and close > orHigh
nearPrevHigh = not na(prevHigh) and close >= prevHigh * (1 - nearPct / 100)
brokePrevHigh = not na(prevHigh) and close > prevHigh
prevHighCondition = nearPrevHigh or brokePrevHigh

nearMA50 = close >= dailyMA50 * (1 - nearPct / 100) and close <= dailyMA50 * (1 + nearPct / 100)
nearMA200 = close >= dailyMA200 * (1 - nearPct / 100) and close <= dailyMA200 * (1 + nearPct / 100)
reclaimedMA50 = close > dailyMA50 and close[1] <= dailyMA50
reclaimedMA200 = close > dailyMA200 and close[1] <= dailyMA200
aboveMA50 = close > dailyMA50
aboveMA200 = close > dailyMA200
constructiveMA = nearMA50 or nearMA200 or reclaimedMA50 or reclaimedMA200 or aboveMA50 or aboveMA200
maOk = not requireMAFilter or constructiveMA

// Main signal
bullishReversalSignalRaw = inRegularSession and aboveVWAP and reclaimedPrevClose and brokeORH and prevHighCondition and maOk
bullishReversalSignal = bullishReversalSignalRaw and rsiOk and rsiMaSlopeOk

// Score
score = 0
score += aboveVWAP ? 1 : 0
score += reclaimedPrevClose ? 1 : 0
score += brokeORH ? 1 : 0
score += prevHighCondition ? 1 : 0
score += constructiveMA ? 1 : 0
score += rsiOk ? 1 : 0
score += rsiMaSlopeOk ? 1 : 0

// Plots with distinct colors
plot(showVWAP ? vwapValue : na, "VWAP", color=color.blue, linewidth=2)
plot(showORH ? orHigh : na, "15-Min Opening Range High", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(showPrevClose ? prevClose : na, "Previous Close", color=color.gray, linewidth=1, style=plot.style_linebr)
plot(showPrevHigh ? prevHigh : na, "Previous Regular Session High", color=color.green, linewidth=1, style=plot.style_linebr)
plot(showDailyMAs ? dailyMA50 : na, "50-Day SMA", color=color.purple, linewidth=1)
plot(showDailyMAs ? dailyMA200 : na, "200-Day SMA", color=color.red, linewidth=1)

// Hidden RSI MA plots
plot(rsiValue, "RSI", color=color.purple, display=display.none)
plot(rsiBasedMA, "RSI-based MA", color=color.yellow, display=display.none)

// Signal markers with distinct colors
plotshape(bullishReversalSignal, title="Bullish Reversal Checklist Met + RSI + RSI MA Slope", style=shape.labelup, text="R", location=location.belowbar, size=size.tiny, color=color.lime, textcolor=color.black)
plotshape(score >= 4 and not bullishReversalSignal and inRegularSession, title="Partial Setup", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.yellow)
plotshape(bullishReversalSignalRaw and not rsiOk, title="Reversal Blocked By RSI Limit", style=shape.xcross, location=location.abovebar, size=size.tiny, color=color.red)
plotshape(bullishReversalSignalRaw and rsiOk and not rsiMaSlopeOk, title="Reversal Blocked By Falling RSI MA", style=shape.xcross, location=location.abovebar, size=size.tiny, color=color.orange)

// Dashboard
var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "Condition", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 0, "Status", text_color=color.white, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 1, "Above VWAP", text_color=color.white, bgcolor=color.blue, text_size=size.tiny)
    table.cell(dash, 1, 1, aboveVWAP ? "Yes" : "No", text_color=color.white, bgcolor=aboveVWAP ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 2, "Reclaimed Prior Close", text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, reclaimedPrevClose ? "Yes" : "No", text_color=color.white, bgcolor=reclaimedPrevClose ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 3, "Above 15m OR High", text_color=color.white, bgcolor=color.orange, text_size=size.tiny)
    table.cell(dash, 1, 3, brokeORH ? "Yes" : "No", text_color=color.white, bgcolor=brokeORH ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 4, "Near/Above Prev RTH High", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 1, 4, prevHighCondition ? "Yes" : "No", text_color=color.white, bgcolor=prevHighCondition ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 5, "50D/200D Constructive", text_color=color.white, bgcolor=color.purple, text_size=size.tiny)
    table.cell(dash, 1, 5, constructiveMA ? "Yes" : "No", text_color=color.white, bgcolor=constructiveMA ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 6, "RSI < Limit", text_color=color.white, bgcolor=color.maroon, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(rsiValue, "#.##") + " < " + str.tostring(rsiLimit, "#.##"), text_color=color.white, bgcolor=rsiOk ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 7, "RSI MA Rising/Flat", text_color=color.white, bgcolor=color.orange, text_size=size.tiny)
    table.cell(dash, 1, 7, enableRsiMa ? str.tostring(rsiBasedMA, "#.##") + " >= " + str.tostring(rsiBasedMA[1], "#.##") : "MA Off", text_color=color.white, bgcolor=rsiMaSlopeOk ? color.green : color.red, text_size=size.tiny)

    table.cell(dash, 0, 8, "Score", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 8, str.tostring(score) + "/7", text_color=color.white, bgcolor=score >= 6 ? color.green : color.red, text_size=size.tiny)

// Alert
alertcondition(bullishReversalSignal, title="Bullish Gap-Down Reversal Signal", message="White R")
````
