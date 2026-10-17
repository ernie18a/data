# Futures ORB 8:30 + EMA + Improved Signals

- url: https://www.tradingview.com/script/PtT7pu0w-Futures-ORB-8-30-EMA-Improved-Signals/
- type: indicator
- pine_id: PUB;e52fbcf8bd734fe2a57aac30ab0c6653
- version: 1.0

## Description

📊 Futures ORB + EMA + Signal Indicator (Summary)
🔒 Market Rules
Works ONLY on futures symbols (ES, NQ, GC, CL, etc.)
Designed for 5-minute charts only
Uses CME Central Time (America/Chicago) session logic
🕒 Opening Range (ORB)
Captures the first 5-minute candle starting at 8:30 AM CT
Marks:
📈 High of that candle
📉 Low of that candle
These levels are extended and displayed until 12:00 PM CT
🔺 Trade Signals
Generates a BUY signal (green triangle) when:
A candle closes above ORB High
Only the first breakout counts
Generates a SELL signal (red triangle) when:
A candle closes below ORB Low
Only the first breakdown counts
IMPORTANT CHANGE YOU REQUESTED:
Signal triggers if ONLY the close crosses ORB
Does NOT require full candle body to be outside anymore
This makes signals faster and more responsive
📊 EMA Overlay (from 1-minute data)

Even on a 5-minute chart, it plots:

🔵 EMA 9 (1-minute)
🟠 EMA 15 (1-minute)
🟣 EMA 21 (1-minute)

This gives you lower-timeframe trend structure inside higher timeframe entries

⚙️ Visual Enhancements
Signals use small but visible triangles
ORB levels are clearly marked in green/red
Includes safety warnings if:
Not using futures
Not on a 5-minute chart
🧠 In simple terms

This is a:

Futures opening-range breakout system with fast EMA trend context and first-break signal logic

## Source Code

````pine
//@version=5
indicator("Futures ORB 8:30 + EMA + Improved Signals", overlay=true)

//========================
// 🔒 FUTURES + TIMEFRAME LOCK
//========================
isFutures = syminfo.type == "futures"
is5m = timeframe.isminutes and timeframe.multiplier == 5

//========================
// 🕒 SESSION (CME CT)
//========================
session = "0830-1200"
inSession = not na(time(timeframe.period, session, "America/Chicago"))

newSession = inSession and not inSession[1]

//========================
// 📏 ORB LEVELS
//========================
var float orbHigh = na
var float orbLow  = na

if newSession
    orbHigh := high
    orbLow  := low

plot(isFutures and inSession ? orbHigh : na, "ORB High", color=color.green, linewidth=2)
plot(isFutures and inSession ? orbLow  : na, "ORB Low",  color=color.red, linewidth=2)

//========================
// 🚨 IMPROVED SIGNAL LOGIC
// (NOW ONLY CLOSE MATTERS)
//========================
bullSignalRaw = close > orbHigh
bearSignalRaw = close < orbLow

var bool bullDone = false
var bool bearDone = false

if newSession
    bullDone := false
    bearDone := false

bullSignal = bullSignalRaw and not bullDone
bearSignal = bearSignalRaw and not bearDone

if bullSignal
    bullDone := true

if bearSignal
    bearDone := true

//========================
// 🔺 BIGGER TRIANGLES
//========================
plotshape(isFutures and is5m and bullSignal,
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,   // ⬅️ increased visibility
     color=color.lime,
     title="BUY SIGNAL")

plotshape(isFutures and is5m and bearSignal,
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,   // ⬅️ increased visibility
     color=color.red,
     title="SELL SIGNAL")

//========================
// 📊 EMA (1 MIN ON 5 MIN)
//========================
ema9  = request.security(syminfo.tickerid, "1", ta.ema(close, 9))
ema15 = request.security(syminfo.tickerid, "1", ta.ema(close, 15))
ema21 = request.security(syminfo.tickerid, "1", ta.ema(close, 21))

plot(isFutures ? ema9  : na, color=color.blue,   title="EMA 9 (1m)")
plot(isFutures ? ema15 : na, color=color.orange, title="EMA 15 (1m)")
plot(isFutures ? ema21 : na, color=color.purple, title="EMA 21 (1m)")

//========================
// SAFETY LABELS
//========================
if not isFutures
    label.new(bar_index, high, "FUTURES ONLY", style=label.style_label_down, color=color.red)

if not is5m
    label.new(bar_index, high, "USE 5-MIN CHART", style=label.style_label_down, color=color.orange)
````
