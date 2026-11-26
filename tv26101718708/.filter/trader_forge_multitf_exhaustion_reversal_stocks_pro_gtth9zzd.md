# Trader Forge: Multi-TF Exhaustion Reversal Stocks Pro

- url: https://www.tradingview.com/script/GttH9zZD-Trader-Forge-Multi-TF-Exhaustion-Reversal-Stocks-Pro/
- type: indicator
- pine_id: PUB;df311641928843ea8a9aa2f01d20b640
- version: 1.0

## Description

🧠 Trader Forge: Multi-TF Exhaustion Reversal (Stocks)

Created by: Luis Sandoval (Trader Forge)

📖 What this indicator does

This indicator is designed to identify high-probability reversal points in stocks by combining:

Price extremes (Donchian Channels)
Momentum exhaustion (Stoch RSI)
Multi-timeframe alignment (1H, 4H, Daily)
Volume + market confirmation (QQQ/SPY)

👉 In simple terms:

It finds when a stock is too extended, losing momentum, and likely to reverse

🧬 The idea behind it (the edge)

Markets move in cycles:

Expansion (strong move)
Exhaustion (slowing down)
Reversal or pullback

Most traders:

Chase during expansion ❌
Get trapped at the top ❌

This indicator helps you:

Wait for exhaustion → then enter the reversal

⚙️ What it looks for
🟡 1. Price at extremes
Stock is at the top or bottom of the Donchian Channel
This means price is stretched
🟡 2. Weak candles (very important)
Small-bodied candles = momentum slowing
This is where smart money starts exiting
🟡 3. Momentum exhaustion (Stoch RSI)

Across:

1 Hour
4 Hour
Daily

All aligned:

Overbought → potential drop
Oversold → potential bounce
🟡 4. Market confirmation (QQQ/SPY)
If the overall market agrees → higher probability
Prevents trading against strong trends
🟡 5. Volume filter
Ensures the move actually matters
Avoids low-volume fake setups
🚦 The signals (THIS is how you trade it)
🟡 STEP 1 — WATCH (Preparation phase)

Label:

PUT WATCH (top exhaustion)
CALL WATCH (bottom exhaustion)

👉 Meaning:

“Everything is lining up… but WAIT”

❌ Do NOT enter yet

🔴🟢 STEP 2 — A+ TRIGGER (Execution phase)

Label:

A+ BUY PUT
A+ BUY CALL

👉 Meaning:

“Exhaustion confirmed + structure shifted = valid entry”

✅ This is where you take the trade

🎯 How to use it (simple workflow)
Step 1: Open your chart (1H timeframe)

Best for:

QQQ, SPY
NVDA, TSLA, AMD, META, AAPL
Step 2: Wait for WATCH label
Don’t rush
Let the setup form
Step 3: Wait for A+ signal

Only enter when:

A+ BUY PUT or CALL appears
Step 4: Entry
Enter on:
Small pullback
Or next candle confirmation
Step 5: Manage trade
Take partial profits early
Let runner ride if momentum continues
⚠️ When NOT to trade (very important)

Even if signals appear:

❌ Avoid strong trend days
News events
Market ripping in one direction
❌ Avoid first 15 minutes of market open
High manipulation
Low clarity
❌ Avoid low-volume stocks
Signals become unreliable
💡 Why this works

This strategy focuses on:

Timing reversals AFTER smart money finishes pushing price

Instead of guessing tops/bottoms, it waits for:

exhaustion
confirmation
structure shift

That’s the difference.

🧠 Philosophy behind Trader Forge

“Discipline before size.”

This indicator enforces:

patience
confirmation
selectivity

If there’s no A+:

There is no trade

🏁 Final rule (burn this in your brain)

“If it’s not A+, it’s not me.”

## Source Code

````pine
//@version=6
indicator("Trader Forge: Multi-TF Exhaustion Reversal Stocks Pro", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Settings"
donLen    = input.int(20, "Donchian Length", minval=5, group=groupCore)
atrLen    = input.int(14, "ATR Length", minval=5, group=groupCore)
nearMult  = input.float(0.35, "Near Channel ATR Tolerance", step=0.05, group=groupCore)
smallMult = input.float(0.45, "Small Candle Body ATR Max", step=0.05, group=groupCore)

groupStoch = "Stoch RSI Settings"
rsiLen   = input.int(14, "RSI Length", group=groupStoch)
stochLen = input.int(14, "Stoch Length", group=groupStoch)
smoothK  = input.int(3, "Smooth K", group=groupStoch)
obLevel  = input.float(80, "Overbought", group=groupStoch)
osLevel  = input.float(20, "Oversold", group=groupStoch)

groupTF = "Timeframes"
tfEntry = input.timeframe("60", "Entry TF", group=groupTF)
tfMid   = input.timeframe("240", "Confirm TF", group=groupTF)
tfMacro = input.timeframe("D", "Macro TF", group=groupTF)

groupMarket = "Market Confirmation"
useMarketConfirm = input.bool(true, "Use Market Confirmation", group=groupMarket)
marketSymbol = input.symbol("NASDAQ:QQQ", "Market Benchmark", group=groupMarket)
marketMustAlign = input.bool(false, "Require Benchmark Also Overbought/Oversold", group=groupMarket)

groupVolume = "Volume Filter"
useRelVol = input.bool(true, "Use Relative Volume Filter", group=groupVolume)
volLen = input.int(20, "Volume MA Length", minval=5, group=groupVolume)
minRelVol = input.float(0.85, "Minimum Relative Volume", step=0.05, group=groupVolume)

groupSession = "Session Filter"
useSession = input.bool(true, "Use Regular Stock Session", group=groupSession)
tradeSession = input.session("0945-1555", "Allowed Session ET", group=groupSession)
avoidOpen = input.bool(true, "Avoid First 15 Minutes", group=groupSession)

groupVisual = "Visuals"
showWatch = input.bool(true, "Show WATCH Labels", group=groupVisual)
showTriggers = input.bool(true, "Show A+ Labels", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
showDonchian = input.bool(true, "Show Donchian Channel", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_stochRsiK() =>
    r = ta.rsi(close, rsiLen)
    kRaw = ta.stoch(r, r, r, stochLen)
    ta.sma(kRaw, smoothK)

f_state(v) =>
    v >= obLevel ? "Overbought" : v <= osLevel ? "Oversold" : "Neutral"

f_bg(v) =>
    v >= obLevel ? color.new(color.red, 15) : v <= osLevel ? color.new(color.green, 15) : color.new(color.gray, 35)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOCK DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
oE = request.security(syminfo.tickerid, tfEntry, open)
hE = request.security(syminfo.tickerid, tfEntry, high)
lE = request.security(syminfo.tickerid, tfEntry, low)
cE = request.security(syminfo.tickerid, tfEntry, close)

upperE = request.security(syminfo.tickerid, tfEntry, ta.highest(high, donLen))
lowerE = request.security(syminfo.tickerid, tfEntry, ta.lowest(low, donLen))
midE   = (upperE + lowerE) / 2.0
atrE   = request.security(syminfo.tickerid, tfEntry, ta.atr(atrLen))

kEntry = request.security(syminfo.tickerid, tfEntry, f_stochRsiK())
kMid   = request.security(syminfo.tickerid, tfMid, f_stochRsiK())
kMacro = request.security(syminfo.tickerid, tfMacro, f_stochRsiK())

volEntry = request.security(syminfo.tickerid, tfEntry, volume)
volMA    = request.security(syminfo.tickerid, tfEntry, ta.sma(volume, volLen))
relVol   = volMA > 0 ? volEntry / volMA : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET BENCHMARK DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mKEntry = request.security(marketSymbol, tfEntry, f_stochRsiK())
mKMid   = request.security(marketSymbol, tfMid, f_stochRsiK())

marketPutOK =
     not useMarketConfirm or
     not marketMustAlign or
     (mKEntry >= obLevel and mKMid >= obLevel)

marketCallOK =
     not useMarketConfirm or
     not marketMustAlign or
     (mKEntry <= osLevel and mKMid <= osLevel)

// Softer market bias confirmation
marketSoftPutOK =
     not useMarketConfirm or
     mKEntry >= 50

marketSoftCallOK =
     not useMarketConfirm or
     mKEntry <= 50

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyE = math.abs(cE - oE)
smallCandle = bodyE <= atrE * smallMult

nearTop = hE >= upperE - atrE * nearMult
nearBottom = lE <= lowerE + atrE * nearMult

entryOB = kEntry >= obLevel
midOB   = kMid >= obLevel
macroOB = kMacro >= obLevel

entryOS = kEntry <= osLevel
midOS   = kMid <= osLevel
macroOS = kMacro <= osLevel

relVolOK = not useRelVol or relVol >= minRelVol

inSession = not useSession or not na(time(timeframe.period, tradeSession, "America/New_York"))
openDanger = avoidOpen and not na(time(timeframe.period, "0930-0945", "America/New_York"))
sessionOK = inSession and not openDanger

putWatch =
     sessionOK and
     relVolOK and
     nearTop and
     smallCandle and
     entryOB and
     midOB and
     macroOB and
     marketSoftPutOK and
     marketPutOK

callWatch =
     sessionOK and
     relVolOK and
     nearBottom and
     smallCandle and
     entryOS and
     midOS and
     macroOS and
     marketSoftCallOK and
     marketCallOK

putTrigger = putWatch[1] and cE < lE[1]
callTrigger = callWatch[1] and cE > hE[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showDonchian ? upperE : na, "Donchian High", color=color.new(color.red, 0), linewidth=1)
plot(showDonchian ? midE : na, "Donchian Mid", color=color.new(color.gray, 55), linewidth=1)
plot(showDonchian ? lowerE : na, "Donchian Low", color=color.new(color.green, 0), linewidth=1)

plotshape(showWatch and putWatch, title="PUT WATCH", text="PUT\nWATCH", style=shape.labeldown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
plotshape(showWatch and callWatch, title="CALL WATCH", text="CALL\nWATCH", style=shape.labelup, location=location.belowbar, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)

plotshape(showTriggers and putTrigger, title="A+ BUY PUT", text="A+ BUY\nPUT", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.normal)
plotshape(showTriggers and callTrigger, title="A+ BUY CALL", text="A+ BUY\nCALL", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.normal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(putWatch, "Trader Forge Stocks PUT WATCH", "Trader Forge Stocks: PUT WATCH forming on {{ticker}}")
alertcondition(callWatch, "Trader Forge Stocks CALL WATCH", "Trader Forge Stocks: CALL WATCH forming on {{ticker}}")
alertcondition(putTrigger, "Trader Forge Stocks A+ BUY PUT", "Trader Forge Stocks: A+ BUY PUT trigger on {{ticker}}")
alertcondition(callTrigger, "Trader Forge Stocks A+ BUY CALL", "Trader Forge Stocks: A+ BUY CALL trigger on {{ticker}}")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.bottom_right, 2, 10, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Trader Forge", text_color=color.white, bgcolor=color.new(color.blue, 20))
    table.cell(dash, 1, 0, "Stocks Pro", text_color=color.white, bgcolor=color.new(color.blue, 20))

    table.cell(dash, 0, 1, "Entry Stoch", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 1, f_state(kEntry), text_color=color.white, bgcolor=f_bg(kEntry))

    table.cell(dash, 0, 2, "4H Stoch", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 2, f_state(kMid), text_color=color.white, bgcolor=f_bg(kMid))

    table.cell(dash, 0, 3, "1D Stoch", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 3, f_state(kMacro), text_color=color.white, bgcolor=f_bg(kMacro))

    locTxt = nearTop ? "Top Channel" : nearBottom ? "Bottom Channel" : "Middle"
    table.cell(dash, 0, 4, "Donchian", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 4, locTxt, text_color=color.white, bgcolor=color.new(color.gray, 30))

    candleTxt = smallCandle ? "Small / Exhaustion" : "Normal"
    table.cell(dash, 0, 5, "Candle", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, candleTxt, text_color=color.white, bgcolor=smallCandle ? color.new(color.orange, 10) : color.new(color.gray, 30))

    rvTxt = na(relVol) ? "N/A" : str.tostring(relVol, "#.##") + "x"
    table.cell(dash, 0, 6, "Rel Volume", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 6, rvTxt, text_color=color.white, bgcolor=relVolOK ? color.new(color.green, 20) : color.new(color.red, 20))

    marketTxt = mKEntry >= obLevel ? "Market OB" : mKEntry <= osLevel ? "Market OS" : "Market Neutral"
    table.cell(dash, 0, 7, "Benchmark", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 7, marketTxt, text_color=color.white, bgcolor=f_bg(mKEntry))

    setupTxt = putWatch ? "PUT WATCH" : callWatch ? "CALL WATCH" : "None"
    table.cell(dash, 0, 8, "Setup", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 8, setupTxt, text_color=color.white, bgcolor=putWatch ? color.new(color.red, 15) : callWatch ? color.new(color.green, 15) : color.new(color.gray, 35))

    triggerTxt = putTrigger ? "A+ BUY PUT" : callTrigger ? "A+ BUY CALL" : openDanger ? "Open Danger" : "Waiting"
    table.cell(dash, 0, 9, "Trigger", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 9, triggerTxt, text_color=color.white, bgcolor=putTrigger ? color.new(color.red, 0) : callTrigger ? color.new(color.green, 0) : openDanger ? color.new(color.orange, 0) : color.new(color.gray, 35))
````
