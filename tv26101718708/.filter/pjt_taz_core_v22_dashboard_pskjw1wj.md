# PJT TAZ Core v2.2 [Dashboard]

- url: https://www.tradingview.com/script/psKJW1Wj-PJT-TAZ-Core-v2-2-Dashboard/
- type: indicator
- pine_id: PUB;7e3c7ce989134e88acf165604f4b39e4
- version: 1.0

## Description

Most traders enter too early or too late.

The PJT TAZ Core highlights structured pullback zones within a confirmed trend, helping you focus on disciplined entries instead of guessing.

---

PJT TAZ Core v2.2

This script identifies the Trading Activity Zone (TAZ), where price pulls back within a trend before continuation.

---

What it does:
• Identifies trend using moving averages  
• Highlights pullback zones (TAZ)  
• Helps locate structured entry areas  
• Filters out low-quality setups  

---

How to use:
1. Confirm trend direction  
2. Wait for price to enter the TAZ  
3. Look for confirmation  
4. Execute with discipline  

---

Williams %R is used as a supporting momentum tool to help confirm pullbacks within the trend.

---

Part of the PJT Trading Framework:

This tool is designed to be used alongside the PJT Position Calculator to create a complete trade planning workflow.

---

Who this is for:
• Traders learning trend-following  
• Traders struggling with entries  
• Traders focused on discipline  

---

Follow for more tools from the PJT Academy.

---

Keywords:
trend trading, pullback trading, moving averages, trading system, day trading, price action

Disclaimer: For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=5
indicator("PJT TAZ Core v2.2 [Dashboard]", overlay=true)

//====================================================
// WHAT CHANGED FROM v2.1
// 1. Dashboard language aligned with PJT teaching framework
// 2. "Trend (10>30)" → "Market Structure"
// 3. "W%R (3)" → "Market Pressure"
// 4. Added W%R state text:
//    - WEAK (Pullback)
//    - STRONG (Extended)
//    - NEUTRAL
// 5. "Setup" → "Scan Status"
// 6. "TAZ Signal" → "TAZ Status"
// 7. "Full Align?" → "Execution Status"
// 8. Signal label mode kept:
//    - All
//    - First Only (default)
//    - None
//====================================================

//====================================================
// INPUTS
//====================================================
showMAs       = input.bool(true,  "Show Moving Averages")
showTAZFill   = input.bool(true,  "Show TAZ Fill")
showSignals   = input.bool(true,  "Show TAZ Signals")
showDashboard = input.bool(true,  "Show Master Dashboard")

mktSymbol = input.symbol("SPY", "Market Symbol")
wrLen     = input.int(3, "Williams %R Length", minval=2)

labelMode = input.string("First Only", "Signal Label Mode", options=["All", "First Only", "None"])

//====================================================
// COLORS — LOCKED TO PJT BRAND
//====================================================
colSMA10  = color.new(#FFCC00, 0)
colEMA30  = color.new(#00D4FF, 0)
colSMA200 = color.new(#FF0050, 0)
colTAZ    = color.new(#00D4FF, 92)

colGood = color.new(color.lime,   0)
colBad  = color.new(color.red,    0)
colWarn = color.new(color.orange, 0)
colDim  = color.new(color.black, 70)

//====================================================
// CORE MOVING AVERAGES
//====================================================
sma10  = ta.sma(close, 10)
ema30  = ta.ema(close, 30)
sma200 = ta.sma(close, 200)

//====================================================
// STOCK-LEVEL TAZ SIGNALS
//====================================================
inTAZlong  = close < sma10 and close > ema30 and sma10 > ema30 and close > sma200
inTAZshort = close > sma10 and close < ema30 and sma10 < ema30 and close < sma200

longSignal  = inTAZlong
shortSignal = inTAZshort

newLongSignal  = longSignal and not longSignal[1]
newShortSignal = shortSignal and not shortSignal[1]

showLongLabel =
     labelMode == "All" ? longSignal :
     labelMode == "First Only" ? newLongSignal :
     false

showShortLabel =
     labelMode == "All" ? shortSignal :
     labelMode == "First Only" ? newShortSignal :
     false

//====================================================
// PLOTS + TAZ FILL
//====================================================
p1 = plot(showMAs ? sma10  : na, "SMA 10",  colSMA10,  2)
p2 = plot(showMAs ? ema30  : na, "EMA 30",  colEMA30,  2)
plot(showMAs ? sma200 : na, "SMA 200", colSMA200, 2)

fill(p1, p2, showTAZFill ? colTAZ : na, title="TAZ Fill")

plotshape(showSignals and showLongLabel,  style=shape.labelup,   text="L", color=color.green, size=size.tiny, location=location.belowbar)
plotshape(showSignals and showShortLabel, style=shape.labeldown, text="S", color=color.red,   size=size.tiny, location=location.abovebar)

//====================================================
// MARKET DATA (SPY — DAILY)
//====================================================
mSMA10 = request.security(mktSymbol, "D", ta.sma(close, 10))
mEMA30 = request.security(mktSymbol, "D", ta.ema(close, 30))

hh     = request.security(mktSymbol, "D", ta.highest(high, wrLen))
ll     = request.security(mktSymbol, "D", ta.lowest(low,  wrLen))
mClose = request.security(mktSymbol, "D", close)
mWR    = hh == ll ? 0.0 : (hh - mClose) / (hh - ll) * -100.0

//====================================================
// MARKET LOGIC
//====================================================
mktTrendUp   = mSMA10 > mEMA30
mktTrendDown = mSMA10 < mEMA30

trendText  = mktTrendUp ? "UP" : mktTrendDown ? "DOWN" : "FLAT"
trendColor = mktTrendUp ? colGood : mktTrendDown ? colBad : colWarn

wrText = str.tostring(mWR, "#.0") + "%"

wrInScanZone = mWR <= -75
wrColor      = wrInScanZone ? colGood : colDim

wrState = mWR <= -80 ? "WEAK (Pullback)" : mWR >= -20 ? "STRONG (Extended)" : "NEUTRAL"
wrDisplay = wrText + " | " + wrState

longSetupReady  = mktTrendUp and mWR <= -75
shortSetupReady = mktTrendDown and mWR >= -20

setupText  = longSetupReady ? "LONG SETUP READY" : shortSetupReady ? "SHORT SETUP READY" : "WAIT"
setupColor = longSetupReady ? colGood : shortSetupReady ? colBad : colWarn

sigText  = longSignal ? "IN TAZ LONG" : shortSignal ? "IN TAZ SHORT" : "WAIT"
sigColor = longSignal ? colGood : shortSignal ? colBad : colDim

fullAlignLong  = longSignal and longSetupReady
fullAlignShort = shortSignal and shortSetupReady
fullAlign      = fullAlignLong or fullAlignShort

fullAlignText  = fullAlign ? "YES — VALIDATE CANDLE" : "NOT YET"
fullAlignColor = fullAlign ? colGood : colDim

//====================================================
// ALERTS
//====================================================
alertcondition(longSetupReady,  "PJT — Scan Window Open (Long)",  "SPY W%R scan window open — begin scanning for TAZ long setups")
alertcondition(shortSetupReady, "PJT — Scan Window Open (Short)", "SPY W%R scan window open — begin scanning for TAZ short setups")
alertcondition(fullAlignLong,   "PJT — Full Long Alignment",      "PJT Full Long Alignment — SPY ready + stock in TAZ. Validate candle, plan order after close.")
alertcondition(fullAlignShort,  "PJT — Full Short Alignment",     "PJT Full Short Alignment — SPY ready + stock in TAZ. Validate candle, plan order after close.")

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 2, 7, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "PJT DASH",          text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, syminfo.ticker,      text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Market",            text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 1, mktSymbol,           text_color=color.white, bgcolor=colDim)

    table.cell(dash, 0, 2, "Market Structure",  text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 2, trendText,           text_color=color.white, bgcolor=trendColor)

    table.cell(dash, 0, 3, "Market Pressure",   text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 3, wrDisplay,           text_color=color.white, bgcolor=wrColor)

    table.cell(dash, 0, 4, "Scan Status",       text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 4, setupText,           text_color=color.white, bgcolor=setupColor)

    table.cell(dash, 0, 5, "TAZ Status",        text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 5, sigText,             text_color=color.white, bgcolor=sigColor)

    table.cell(dash, 0, 6, "Execution Status",  text_color=color.white, bgcolor=colDim)
    table.cell(dash, 1, 6, fullAlignText,       text_color=color.white, bgcolor=fullAlignColor)
````
