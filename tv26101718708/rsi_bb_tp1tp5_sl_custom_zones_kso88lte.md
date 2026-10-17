# RSI + BB TP1-TP5 + SL + Custom Zones

- url: https://www.tradingview.com/script/kSo88LTE-RSI-BB-TP1-TP5-SL-Custom-Zones/
- type: indicator
- pine_id: PUB;ce7a51acd6a64ed9bf2bad604f00a856
- version: 1.0

## Description

RSI + BB Reversal Signals with TP1–TP5, Stop Loss & Custom Time Zones

This indicator combines RSI and Bollinger Bands to find mean-reversion entries. It adds a five-level take-profit ladder, a stop loss, session-based signal filtering and a live dashboard.

HOW IT WORKS

1. Setup
- When RSI crosses below the Buy Level (default 25), the script starts waiting for a BUY.
- When RSI crosses above the Sell Level (default 75), the script starts waiting for a SELL.

2. Entry confirmation
- A BUY fires on the first confirmed bullish candle (close > open) after the oversold setup.
- A SELL fires on the first confirmed bearish candle (close < open) after the overbought setup.
- Signals only fire on closed bars, so they don't repaint.

3. Targets and stop loss
- TP1 is the distance from the entry price to the upper Bollinger Band for buys, or the lower band for sells.
- TP2 to TP5 are multiples of that TP1 distance (defaults 1.25x, 1.5x, 1.75x and 2.0x, all adjustable).
- The stop loss is placed using the signal candle's range, scaled by the Stop Loss Multiplier (default 2.0).
- A trade closes when TP5 or the stop loss is hit. TP1 to TP4 are marked on the chart as they're reached.

4. Custom time zones (optional)
- Define up to 5 trading windows and choose the timezone they use (Adelaide, New York or UTC).
- When the zone filter is on, signals only fire inside an enabled window. Each window can be shaded on the chart in its own colour.

5. Dashboard
- Current State: BUY, SELL, NO TRADE, STOPPED OUT or TP5 HIT.
- Setup: TRADE RUNNING, WAITING BUY, WAITING SELL or NONE. It also tells you when a setup is pending but the current time is outside your zones.
- A level table shows the SL and TP1–TP5 prices and whether each has been hit.

SETTINGS
- RSI length and buy/sell levels
- Bollinger Band length and multiplier
- Stop loss multiplier and TP2–TP5 multipliers
- Zone filter on/off, timezone, and per-zone session, colour and transparency

ALERTS
Alerts are available for BUY entry, SELL entry, Stop Loss, and TP1 through TP5.

NOTES
- The indicator tracks one trade at a time. A new signal replaces the previous trade's levels.
- TP/SL hits are detected on bar high/low, so the order of events within a single candle isn't known.
- Best used as a decision aid alongside your own analysis, risk management and higher-timeframe context. Test settings on your market and timeframe before using them.

DISCLAIMER
This script is for educational and informational purposes only and is not financial advice. Trading involves risk, and past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("RSI + BB TP1-TP5 + SL + Custom Zones", overlay=true, max_boxes_count=500)

//━━━━━━━━━━ SETTINGS ━━━━━━━━━━
rsiLength = input.int(14, "RSI Length", minval=1)
oversold = input.float(25, "RSI Buy Level")
overbought = input.float(75, "RSI Sell Level")

bbLength = input.int(20, "BB Length", minval=1)
bbMult = input.float(2.0, "BB Multiplier", minval=0.1)

slMultiplier = input.float(2.0, "Stop Loss Multiplier", minval=0.1)
tp2Mult = input.float(1.25, "TP2 Multiplier", minval=1.0)
tp3Mult = input.float(1.50, "TP3 Multiplier", minval=1.0)
tp4Mult = input.float(1.75, "TP4 Multiplier", minval=1.0)
tp5Mult = input.float(2.00, "TP5 Multiplier", minval=1.0)

//━━━━━━━━━━ CUSTOM TIME ZONES ━━━━━━━━━━
useZoneFilter = input.bool(true, "Enable Custom Zone Filter")
zoneTimezone = input.string("Australia/Adelaide", "Zone Timezone",
     options=["Australia/Adelaide", "America/New_York", "Etc/UTC"])
showZoneBackground = input.bool(true, "Show Zone Backgrounds")

// Zone 1
z1Enabled = input.bool(true, "Enable Zone 1", group="Zone 1")
z1Session = input.session("0800-0900", "Time", group="Zone 1")
z1Color = input.color(color.green, "Zone Color", group="Zone 1")
z1Transparency = input.int(85, "Transparency", minval=0, maxval=100, group="Zone 1")

// Zone 2
z2Enabled = input.bool(true, "Enable Zone 2", group="Zone 2")
z2Session = input.session("1000-1100", "Time", group="Zone 2")
z2Color = input.color(color.blue, "Zone Color", group="Zone 2")
z2Transparency = input.int(85, "Transparency", minval=0, maxval=100, group="Zone 2")

// Zone 3
z3Enabled = input.bool(true, "Enable Zone 3", group="Zone 3")
z3Session = input.session("1300-1400", "Time", group="Zone 3")
z3Color = input.color(color.purple, "Zone Color", group="Zone 3")
z3Transparency = input.int(85, "Transparency", minval=0, maxval=100, group="Zone 3")

// Zone 4
z4Enabled = input.bool(true, "Enable Zone 4", group="Zone 4")
z4Session = input.session("1600-1700", "Time", group="Zone 4")
z4Color = input.color(color.orange, "Zone Color", group="Zone 4")
z4Transparency = input.int(85, "Transparency", minval=0, maxval=100, group="Zone 4")

// Zone 5
z5Enabled = input.bool(true, "Enable Zone 5", group="Zone 5")
z5Session = input.session("1900-2000", "Time", group="Zone 5")
z5Color = input.color(color.red, "Zone Color", group="Zone 5")
z5Transparency = input.int(85, "Transparency", minval=0, maxval=100, group="Zone 5")

//━━━━━━━━━━ ZONE CALCULATIONS ━━━━━━━━━━
inZ1 = not na(time(timeframe.period, z1Session, zoneTimezone))
inZ2 = not na(time(timeframe.period, z2Session, zoneTimezone))
inZ3 = not na(time(timeframe.period, z3Session, zoneTimezone))
inZ4 = not na(time(timeframe.period, z4Session, zoneTimezone))
inZ5 = not na(time(timeframe.period, z5Session, zoneTimezone))

inAnyEnabledZone = (z1Enabled and inZ1) or
     (z2Enabled and inZ2) or
     (z3Enabled and inZ3) or
     (z4Enabled and inZ4) or
     (z5Enabled and inZ5)

allowSignal = not useZoneFilter or inAnyEnabledZone

// Show colored backgrounds. If zones overlap, the later bgcolor call may cover earlier colors.
bgcolor(showZoneBackground and z1Enabled and inZ1 ? color.new(z1Color, z1Transparency) : na, title="Zone 1 Background")
bgcolor(showZoneBackground and z2Enabled and inZ2 ? color.new(z2Color, z2Transparency) : na, title="Zone 2 Background")
bgcolor(showZoneBackground and z3Enabled and inZ3 ? color.new(z3Color, z3Transparency) : na, title="Zone 3 Background")
bgcolor(showZoneBackground and z4Enabled and inZ4 ? color.new(z4Color, z4Transparency) : na, title="Zone 4 Background")
bgcolor(showZoneBackground and z5Enabled and inZ5 ? color.new(z5Color, z5Transparency) : na, title="Zone 5 Background")

//━━━━━━━━━━ RSI & BOLLINGER BANDS ━━━━━━━━━━
rsiValue = ta.rsi(close, rsiLength)
basis = ta.sma(close, bbLength)
dev = bbMult * ta.stdev(close, bbLength)
upper = basis + dev
lower = basis - dev

plot(basis, "BB Middle", color=color.blue)
plot(upper, "BB Upper", color=color.orange)
plot(lower, "BB Lower", color=color.orange)

//━━━━━━━━━━ ENTRY SETUP ━━━━━━━━━━
var bool waitingBuy = false
var bool waitingSell = false

if ta.crossunder(rsiValue, oversold)
    waitingBuy := true
    waitingSell := false

if ta.crossover(rsiValue, overbought)
    waitingSell := true
    waitingBuy := false

buySignal = waitingBuy and close > open and barstate.isconfirmed and allowSignal
sellSignal = waitingSell and close < open and barstate.isconfirmed and allowSignal

if buySignal
    waitingBuy := false

if sellSignal
    waitingSell := false

//━━━━━━━━━━ SIGNAL DATA ━━━━━━━━━━
var string lastSignal = "No signal yet"

//━━━━━━━━━━ TRADE STATE ━━━━━━━━━━
var int activeTrade = 0
var float entryPrice = na
var float tpDistance = na
var float stopLoss = na
var string tradeStatus = "NO TRADE"

var bool hit1Done = false
var bool hit2Done = false
var bool hit3Done = false
var bool hit4Done = false
var bool hit5Done = false
var bool slDone = false

//━━━━━━━━━━ BUY ENTRY ━━━━━━━━━━
if buySignal
    lastSignal := "BUY"
    activeTrade := 1
    entryPrice := close
    tpDistance := math.max(upper - close, syminfo.mintick)
    stopLoss := close - slMultiplier * (close - low)
    tradeStatus := "ACTIVE"
    hit1Done := false
    hit2Done := false
    hit3Done := false
    hit4Done := false
    hit5Done := false
    slDone := false

//━━━━━━━━━━ SELL ENTRY ━━━━━━━━━━
if sellSignal
    lastSignal := "SELL"
    activeTrade := -1
    entryPrice := close
    tpDistance := math.max(close - lower, syminfo.mintick)
    stopLoss := close + slMultiplier * (high - close)
    tradeStatus := "ACTIVE"
    hit1Done := false
    hit2Done := false
    hit3Done := false
    hit4Done := false
    hit5Done := false
    slDone := false

//━━━━━━━━━━ TP TARGETS ━━━━━━━━━━
tp1 = not na(entryPrice) ? entryPrice + (lastSignal == "BUY" ? 1 : -1) * tpDistance : na
tp2 = not na(entryPrice) ? entryPrice + (lastSignal == "BUY" ? 1 : -1) * tpDistance * tp2Mult : na
tp3 = not na(entryPrice) ? entryPrice + (lastSignal == "BUY" ? 1 : -1) * tpDistance * tp3Mult : na
tp4 = not na(entryPrice) ? entryPrice + (lastSignal == "BUY" ? 1 : -1) * tpDistance * tp4Mult : na
tp5 = not na(entryPrice) ? entryPrice + (lastSignal == "BUY" ? 1 : -1) * tpDistance * tp5Mult : na

//━━━━━━━━━━ STOP LOSS DETECTION ━━━━━━━━━━
slTouched = activeTrade == 1 ? low <= stopLoss : activeTrade == -1 ? high >= stopLoss : false
slSignal = activeTrade != 0 and not slDone and slTouched and barstate.isconfirmed

//━━━━━━━━━━ TP DETECTION ━━━━━━━━━━
tp1Touched = activeTrade == 1 ? high >= tp1 : activeTrade == -1 ? low <= tp1 : false
tp2Touched = activeTrade == 1 ? high >= tp2 : activeTrade == -1 ? low <= tp2 : false
tp3Touched = activeTrade == 1 ? high >= tp3 : activeTrade == -1 ? low <= tp3 : false
tp4Touched = activeTrade == 1 ? high >= tp4 : activeTrade == -1 ? low <= tp4 : false
tp5Touched = activeTrade == 1 ? high >= tp5 : activeTrade == -1 ? low <= tp5 : false

tp1Signal = false
tp2Signal = false
tp3Signal = false
tp4Signal = false
tp5Signal = false

if slSignal
    slDone := true
    tradeStatus := "STOPPED OUT"
    activeTrade := 0
else
    tp1Signal := activeTrade != 0 and not hit1Done and tp1Touched and barstate.isconfirmed
    tp2Signal := activeTrade != 0 and not hit2Done and tp2Touched and barstate.isconfirmed
    tp3Signal := activeTrade != 0 and not hit3Done and tp3Touched and barstate.isconfirmed
    tp4Signal := activeTrade != 0 and not hit4Done and tp4Touched and barstate.isconfirmed
    tp5Signal := activeTrade != 0 and not hit5Done and tp5Touched and barstate.isconfirmed

    if tp1Signal
        hit1Done := true
    if tp2Signal
        hit2Done := true
    if tp3Signal
        hit3Done := true
    if tp4Signal
        hit4Done := true
    if tp5Signal
        hit5Done := true
        tradeStatus := "TP5 HIT"
        activeTrade := 0

//━━━━━━━━━━ ENTRY MARKERS ━━━━━━━━━━
plotshape(buySignal, title="BUY Entry", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white)
plotshape(sellSignal, title="SELL Entry", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white)

//━━━━━━━━━━ EXIT MARKERS ━━━━━━━━━━
plotshape(slSignal, title="STOP LOSS", style=shape.labelup, location=location.belowbar, color=color.maroon, text="SL", textcolor=color.white)
plotshape(tp1Signal, title="TP1", style=shape.labeldown, location=location.abovebar, color=color.blue, text="TP1", textcolor=color.white, size=size.tiny)
plotshape(tp2Signal, title="TP2", style=shape.labeldown, location=location.abovebar, color=color.teal, text="TP2", textcolor=color.white, size=size.tiny)
plotshape(tp3Signal, title="TP3", style=shape.labeldown, location=location.abovebar, color=color.purple, text="TP3", textcolor=color.white, size=size.tiny)
plotshape(tp4Signal, title="TP4", style=shape.labeldown, location=location.abovebar, color=color.orange, text="TP4", textcolor=color.white, size=size.tiny)
plotshape(tp5Signal, title="TP5", style=shape.labeldown, location=location.abovebar, color=color.red, text="TP5", textcolor=color.white, size=size.tiny)

plot(activeTrade != 0 ? stopLoss : na, "Stop Loss Level", color=color.red, linewidth=2, style=plot.style_linebr)

//━━━━━━━━━━ DASHBOARD TABLES ━━━━━━━━━━
var table signalBox = table.new(position.top_right, 1, 4, border_width=1)
var table tpTable = table.new(position.middle_right, 3, 8, border_width=1)

if barstate.islast
    // ── Current state ──
    string stateText = "NO TRADE"
    color stateColor = color.gray

    if activeTrade == 1
        stateText := "BUY"
        stateColor := color.green
    else if activeTrade == -1
        stateText := "SELL"
        stateColor := color.red
    else if tradeStatus == "STOPPED OUT"
        stateText := "STOPPED OUT"
        stateColor := color.maroon
    else if tradeStatus == "TP5 HIT"
        stateText := "TP5 HIT"
        stateColor := color.teal

    // ── Setup / waiting info ──
    string setupText = "NONE"
    color setupColor = color.new(color.gray, 70)

    if activeTrade != 0
        setupText := "TRADE RUNNING"
        setupColor := stateColor
    else if waitingBuy
        setupText := useZoneFilter and not allowSignal ? "WAITING BUY (outside zone)" : "WAITING BUY"
        setupColor := color.new(color.green, 40)
    else if waitingSell
        setupText := useZoneFilter and not allowSignal ? "WAITING SELL (outside zone)" : "WAITING SELL"
        setupColor := color.new(color.red, 40)

    table.cell(signalBox, 0, 0, "CURRENT STATE", bgcolor=color.black, text_color=color.white)
    table.cell(signalBox, 0, 1, stateText, bgcolor=stateColor, text_color=color.white, text_size=size.large)
    table.cell(signalBox, 0, 2, "SETUP", bgcolor=color.black, text_color=color.white)
    table.cell(signalBox, 0, 3, setupText, bgcolor=setupColor, text_color=color.white)

    table.cell(tpTable, 0, 0, "LEVEL", bgcolor=color.black, text_color=color.white)
    table.cell(tpTable, 1, 0, "PRICE", bgcolor=color.black, text_color=color.white)
    table.cell(tpTable, 2, 0, "STATUS", bgcolor=color.black, text_color=color.white)

    table.cell(tpTable, 0, 1, "SL")
    table.cell(tpTable, 1, 1, na(stopLoss) ? "—" : str.tostring(stopLoss, format.mintick))
    table.cell(tpTable, 2, 1, slDone ? "HIT" : activeTrade != 0 ? "ACTIVE" : "—", bgcolor=slDone ? color.red : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 2, "TP1")
    table.cell(tpTable, 1, 2, na(tp1) ? "—" : str.tostring(tp1, format.mintick))
    table.cell(tpTable, 2, 2, hit1Done ? "HIT" : activeTrade != 0 ? "WAIT" : "—", bgcolor=hit1Done ? color.green : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 3, "TP2")
    table.cell(tpTable, 1, 3, na(tp2) ? "—" : str.tostring(tp2, format.mintick))
    table.cell(tpTable, 2, 3, hit2Done ? "HIT" : activeTrade != 0 ? "WAIT" : "—", bgcolor=hit2Done ? color.green : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 4, "TP3")
    table.cell(tpTable, 1, 4, na(tp3) ? "—" : str.tostring(tp3, format.mintick))
    table.cell(tpTable, 2, 4, hit3Done ? "HIT" : activeTrade != 0 ? "WAIT" : "—", bgcolor=hit3Done ? color.green : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 5, "TP4")
    table.cell(tpTable, 1, 5, na(tp4) ? "—" : str.tostring(tp4, format.mintick))
    table.cell(tpTable, 2, 5, hit4Done ? "HIT" : activeTrade != 0 ? "WAIT" : "—", bgcolor=hit4Done ? color.green : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 6, "TP5")
    table.cell(tpTable, 1, 6, na(tp5) ? "—" : str.tostring(tp5, format.mintick))
    table.cell(tpTable, 2, 6, hit5Done ? "HIT" : activeTrade != 0 ? "WAIT" : "—", bgcolor=hit5Done ? color.green : color.new(color.gray, 70), text_color=color.white)

    table.cell(tpTable, 0, 7, "TRADE")
    table.cell(tpTable, 1, 7, activeTrade == 1 ? "BUY" : activeTrade == -1 ? "SELL" : "—")
    table.cell(tpTable, 2, 7, tradeStatus, bgcolor=tradeStatus == "STOPPED OUT" ? color.red : tradeStatus == "TP5 HIT" ? color.green : color.new(color.gray, 70), text_color=color.white)

//━━━━━━━━━━ ALERTS ━━━━━━━━━━
alertcondition(buySignal, "BUY Entry", "RSI BUY entry")
alertcondition(sellSignal, "SELL Entry", "RSI SELL entry")
alertcondition(slSignal, "Stop Loss Hit", "Stop loss touched")
alertcondition(tp1Signal, "TP1 Hit", "TP1 reached")
alertcondition(tp2Signal, "TP2 Hit", "TP2 reached")
alertcondition(tp3Signal, "TP3 Hit", "TP3 reached")
alertcondition(tp4Signal, "TP4 Hit", "TP4 reached")
alertcondition(tp5Signal, "TP5 Hit", "TP5 reached")
````
