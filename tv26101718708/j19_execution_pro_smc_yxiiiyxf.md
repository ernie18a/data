# J19 Execution Pro SMC

- url: https://www.tradingview.com/script/yxIiiyXF-J19-Execution-Pro-SMC/
- type: indicator
- pine_id: PUB;8d152be76a324e7fbe8f127f4e52c691
- version: 1.0

## Description

J19 Execution Pro Rules

Rule #1 — Trend Bias First

Never take a trade against the 200 EMA.

Buy Only
Price above 200 EMA
Market making Higher Highs (HH)
Market making Higher Lows (HL)

Sell Only
Price below 200 EMA
Market making Lower Highs (LH)
Market making Lower Lows (LL)

If price is chopping around the 200 EMA: ❌ No trade.

Rule #2 — Wait For Supply Or Demand

Demand Zone = Buy Area

Look for:
Green demand zone
Liquidity sweep low
HL forming
Bullish candle rejection

Then buy.
Supply Zone = Sell Area
Look for:
Red supply zone
Liquidity sweep high
LH forming
Bearish rejection candle

Then sell.
Rule #3 — Structure Before Entry
You are no longer buying because:
"Price touched EMA."
You are buying because:
"Price touched demand and structure confirms."

Buy Checklist
✅ Above 200 EMA
✅ Demand Zone
✅ HL formed
✅ Bullish candle closes
✅ Liquidity sweep or BOS

Sell Checklist
✅ Below 200 EMA
✅ Supply Zone
✅ LH formed
✅ Bearish candle closes
✅ Liquidity sweep or BOS

Rule #4 — Break Of Structure (BOS)
A BOS means market direction is changing.
Bullish BOS
Price breaks above previous swing high.
Result: 🟢 Buyers taking control.
Bearish BOS
Price breaks below previous swing low.
Result: 🔴 Sellers taking control.
BOS gives confidence to enter.

Rule #5 — Liquidity Sweeps
These are some of the strongest entries.
Buy Sweep
Price takes out old lows.
Everyone sells.
Then price immediately reverses.

💰 Buy.
Sell Sweep
Price takes out old highs.
Everyone buys.
Then price reverses.

🔥 Sell.
Rule #6 — The 50 EMA
The 50 EMA is no longer your signal.
The 50 EMA is:
Reaction zone
Pullback zone
Continuation zone
Think:
"Price pulled back to the 50 inside trend."
Not:
"Price touched the 50, buy immediately."

Rule #7 — The 400 EMA
The 400 EMA is your caution zone.
When price reaches it:

⚠️ Expect:
accumulation
consolidation
large reactions
smart money activity
This is where institutions often build positions.

Rule #8 — Confidence Score
80-100
🔥 High probability
60-79
👍 Good setup
40-59
⚠️ Wait
Under 40
❌ No trade
J19 Execution Pro Golden Rule
Structure → Zone → Confirmation → Entry
Not:
❌ Indicator → Entry
Always:
✅ HH / HL / LH / LL
✅ Supply / Demand
✅ BOS
✅ Liquidity Sweep
✅ Confirmation Candle
✅ Entry

Your Best Pairs For This System
🔥 XAUUSD (Gold)
🔥 GBPUSD
🔥 EURUSD
🔥 NAS100
🔥 SPX500

## Source Code

````pine
//@version=5
indicator("J19 Execution Pro SMC", overlay=true, max_labels_count=300, max_boxes_count=100)

//====================
// INPUTS
//====================
showSignals = input.bool(true, "Show SMC Buy/Sell")
showStructure = input.bool(true, "Show HH/HL/LH/LL")
showZones = input.bool(true, "Show Supply/Demand")
showDashboard = input.bool(true, "Show Dashboard")

pivotLen = input.int(6, "Market Structure Strength", minval=2)
cooldownBars = input.int(35, "Bars Between Signals", minval=5)
zoneExtend = input.int(80, "Zone Extension", minval=20)
atrMult = input.float(1.2, "Displacement Strength", step=0.1)

//====================
// EMAS
//====================
ema10 = ta.ema(close, 10)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
ema400 = ta.ema(close, 400)

plot(ema10, "10 EMA Momentum", color=color.yellow, linewidth=2)
plot(ema50, "50 EMA Scalp Zone", color=color.blue, linewidth=2)
plot(ema200, "200 EMA Trend Bias", color=color.white, linewidth=2)
plot(ema400, "400 EMA Accumulation", color=color.purple, linewidth=2)

//====================
// MARKET STRUCTURE
//====================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na
var string highType = ""
var string lowType = ""

if not na(ph)
    highType := na(lastHigh) ? "HH" : ph > lastHigh ? "HH" : "LH"
    if showStructure
        label.new(bar_index[pivotLen], ph, highType, style=label.style_label_down,
         color=highType == "HH" ? color.green : color.red, textcolor=color.white, size=size.small)
    lastHigh := ph

if not na(pl)
    lowType := na(lastLow) ? "HL" : pl > lastLow ? "HL" : "LL"
    if showStructure
        label.new(bar_index[pivotLen], pl, lowType, style=label.style_label_up,
         color=lowType == "HL" ? color.green : color.red, textcolor=color.white, size=size.small)
    lastLow := pl

//====================
// SMART MONEY LOGIC
//====================
atr = ta.atr(14)
bullDisplacement = close > open and (close - open) > atr * atrMult
bearDisplacement = open > close and (open - close) > atr * atrMult

bullBOS = not na(lastHigh) and close > lastHigh
bearBOS = not na(lastLow) and close < lastLow

liquiditySweepLow = low < ta.lowest(low[1], 10) and close > open
liquiditySweepHigh = high > ta.highest(high[1], 10) and close < open

bullTrend = close > ema200
bearTrend = close < ema200

//====================
// SUPPLY / DEMAND ZONES
//====================
var box demandBox = na
var box supplyBox = na

if showZones and bullDisplacement
    if not na(demandBox)
        box.delete(demandBox)
    demandBox := box.new(
     bar_index - 1, low[1],
     bar_index + zoneExtend, high[1],
     bgcolor=color.new(color.green, 85),
     border_color=color.green)

if showZones and bearDisplacement
    if not na(supplyBox)
        box.delete(supplyBox)
    supplyBox := box.new(
     bar_index - 1, high[1],
     bar_index + zoneExtend, low[1],
     bgcolor=color.new(color.red, 85),
     border_color=color.red)

//====================
// PRICE INSIDE ZONES
//====================
inDemand = not na(demandBox) and low <= box.get_top(demandBox) and high >= box.get_bottom(demandBox)
inSupply = not na(supplyBox) and high >= box.get_bottom(supplyBox) and low <= box.get_top(supplyBox)

//====================
// SIGNAL COOLDOWN
//====================
var int lastSignal = na
canSignal = na(lastSignal) or bar_index - lastSignal >= cooldownBars

//====================
// PROFESSIONAL SMC SIGNALS
//====================
buySMC =
 showSignals and canSignal and bullTrend and inDemand and
 (lowType == "HL" or liquiditySweepLow or bullBOS) and
 close > open

sellSMC =
 showSignals and canSignal and bearTrend and inSupply and
 (highType == "LH" or liquiditySweepHigh or bearBOS) and
 close < open

if buySMC or sellSMC
    lastSignal := bar_index

plotshape(buySMC, title="J19 SMC Buy", text="J19 BUY 💰", style=shape.labelup,
 location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal)

plotshape(sellSMC, title="J19 SMC Sell", text="J19 SELL 🔥", style=shape.labeldown,
 location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

//====================
// DASHBOARD
//====================
var table dash = table.new(position.top_right, 2, 6, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "J19 EXECUTION PRO", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "SMC MODE", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Trend Bias", text_color=color.white)
    table.cell(dash, 1, 1, bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "CHOP",
     text_color=color.white, bgcolor=bullTrend ? color.green : color.red)

    table.cell(dash, 0, 2, "Structure", text_color=color.white)
    table.cell(dash, 1, 2, highType + " / " + lowType, text_color=color.white)

    table.cell(dash, 0, 3, "Demand Zone", text_color=color.white)
    table.cell(dash, 1, 3, inDemand ? "ACTIVE" : "WAIT", text_color=color.white,
     bgcolor=inDemand ? color.green : color.gray)

    table.cell(dash, 0, 4, "Supply Zone", text_color=color.white)
    table.cell(dash, 1, 4, inSupply ? "ACTIVE" : "WAIT", text_color=color.white,
     bgcolor=inSupply ? color.red : color.gray)

    table.cell(dash, 0, 5, "Signal Rule", text_color=color.white)
    table.cell(dash, 1, 5, "Zone + Structure", text_color=color.white)

//====================
// ALERTS
//====================
alertcondition(buySMC, "J19 SMC Buy", "J19 Execution Pro: SMC BUY from Demand + Structure")
alertcondition(sellSMC, "J19 SMC Sell", "J19 Execution Pro: SMC SELL from Supply + Structure")
````
