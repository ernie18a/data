# ATR Trailing Stop Pro

- url: https://www.tradingview.com/script/WlBvCWuY-ATR-Trailing-Stop-Pro/
- type: indicator
- pine_id: PUB;a067de4a150047959197e92bd8ad6de9
- version: 1.0

## Description

Title:

ATR Trailing Stop Pro — Long & Short | Close/Wick Filter | Alerts | Risk %

Description:
A fully-featured ATR-based trailing stop anchored to a specific entry date and price — built for traders who want to manage an open position with a clean, rules-based stop rather than a signal generator.
Unlike generic ATR stop indicators that run on every bar from the beginning of the chart, this one starts exactly where your trade did.

Features
🔴 Long & Short — trails upward for longs, downward for shorts
📅 Entry date & price — set your exact entry point; leave price at 0 to use the day's close automatically
📊 ATR-based trailing — stop only ever moves in your favour, never against you
🕯️ Close vs wick stop-out — choose whether a close below the stop triggers it, or any wick (reduces false exits on volatile assets like BTC/crypto)
🏷️ Chart labels — marks your entry price and stop-out point directly on the chart
📋 Info table — live overlay showing entry price, current stop level, risk % from entry, and trade direction
🔔 Built-in alert — set it once and get notified when your stop is hit without watching the chart

How to use

Add the indicator to a daily chart
Open settings and enter your entry year, month, day
Enter your entry price or leave at 0 to use that day's close
Select Long or Short
Adjust the ATR multiplier to suit your risk tolerance (higher = wider stop, less noise)
Toggle Close mode on if you want to avoid getting stopped out by intraday wicks
Set an alert on the indicator for hands-off monitoring

Works on any asset — stocks, crypto, forex, commodities. Designed and tested on Bitcoin daily. For best results use on the 1D timeframe.

## Source Code

````pine
//@version=6
indicator("ATR Trailing Stop Pro", overlay=true)

// === Inputs ===
grp1 = "Entry Settings"
entryDateYear   = input.int(2026,   title="Entry Year",   minval=2000, maxval=2030,   group=grp1)
entryDateMonth  = input.int(6,      title="Entry Month",  minval=1,    maxval=12,     group=grp1)
entryDateDay    = input.int(1,      title="Entry Day",    minval=1,    maxval=31,     group=grp1)
entryPrice      = input.float(0,    title="Entry Price (0 = use day's close)", minval=0, maxval=10000000, group=grp1)
tradeDirection  = input.string("Long", title="Trade Direction", options=["Long", "Short"], group=grp1)

grp2 = "ATR Settings"
atrLength       = input.int(14,   title="ATR Period",      minval=1,   group=grp2)
atrMultiplier   = input.float(3.0, title="ATR Multiplier", minval=0.1, group=grp2)

grp3 = "Stop Behaviour"
useClose        = input.bool(true,  title="Use Close (not Low/High) to trigger stop-out", group=grp3)
showLabel       = input.bool(true,  title="Show Entry & Stop Labels",                     group=grp3)
showInfoTable   = input.bool(true,  title="Show Info Table",                              group=grp3)

// === ATR Calculation ===
atrValue = ta.atr(atrLength)

// === Entry Timestamp ===
entryDate = timestamp(entryDateYear, entryDateMonth, entryDateDay, 0, 0)

// === Entry Level ===
var float entryLevel = na
if na(entryLevel) and time >= entryDate
    entryLevel := entryPrice > 0 ? entryPrice : close

// === Start Condition ===
startCalculating = time >= entryDate
isLong = tradeDirection == "Long"

// === Trailing Stop Logic ===
var float trailingStop = na
var bool stopTriggered = false

if startCalculating and not stopTriggered
    if na(trailingStop[1])
        // First bar: set initial stop using ATR from entry level
        trailingStop := isLong
             ? entryLevel - atrMultiplier * atrValue
             : entryLevel + atrMultiplier * atrValue
    else
        if isLong
            float newStop = high - atrMultiplier * atrValue
            trailingStop := newStop > trailingStop[1] ? newStop : trailingStop[1]
        else
            float newStop = low + atrMultiplier * atrValue
            trailingStop := newStop < trailingStop[1] ? newStop : trailingStop[1]

// === Stop-out condition (close or wick based) ===
triggerPrice = useClose ? close : (isLong ? low : high)

if not na(trailingStop) and not stopTriggered
    if isLong and triggerPrice < trailingStop
        stopTriggered := true
    if not isLong and triggerPrice > trailingStop
        stopTriggered := true

// === Risk % from entry ===
riskPct = not na(entryLevel) and not na(trailingStop)
     ? math.abs(entryLevel - trailingStop) / entryLevel * 100
     : na

// === Plotting ===
stopColor = isLong ? color.red : color.green
plot(startCalculating and not stopTriggered ? trailingStop : na,
     color=stopColor, title="Trailing Stop", linewidth=2)

// === Entry line ===
plot(startCalculating and not stopTriggered ? entryLevel : na,
     color=color.gray, title="Entry Level", linewidth=1, style=plot.style_linebr)

// === Labels ===
if showLabel and not na(entryLevel) and time == entryDate
    label.new(bar_index, entryLevel,
         text="Entry: " + str.tostring(entryLevel, "#.##"),
         color=color.gray, textcolor=color.white, style=label.style_label_right, size=size.small)

if showLabel and stopTriggered and not stopTriggered[1]
    label.new(bar_index, trailingStop[1],
         text="Stopped out", color=color.red,
         textcolor=color.white, style=label.style_label_up, size=size.small)

// === Alert ===
alertcondition(stopTriggered and not stopTriggered[1],
     title="Stop Hit", message="ATR Trailing Stop has been triggered!")

// === Info Table ===
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)

if showInfoTable and barstate.islast
    table.cell(infoTable, 0, 0, "Entry",       text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 0, not na(entryLevel) ? str.tostring(entryLevel, "#.##") : "—",
         text_color=color.white, text_size=size.small)

    table.cell(infoTable, 0, 1, "Stop",        text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 1, not na(trailingStop) ? str.tostring(trailingStop, "#.##") : "—",
         text_color=color.red,   text_size=size.small)

    table.cell(infoTable, 0, 2, "Risk %",      text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 2, not na(riskPct) ? str.tostring(riskPct, "#.##") + "%" : "—",
         text_color=color.orange, text_size=size.small)

    table.cell(infoTable, 0, 3, "Direction",   text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 3, tradeDirection,
         text_color=isLong ? color.green : color.red, text_size=size.small)
````
