# Koda Full System

- url: https://www.tradingview.com/script/tU5f5YHW-Koda-Full-System/
- type: indicator
- pine_id: PUB;694b8c4dc05c4348810ea9042da408fa
- version: 1.0

## Description

Koda Full System – (In Developement)

What It Does
The Koda Full System is a structured trading indicator designed to identify high-probability liquidity sweeps (KLS setups) using a combination of:
•	Liquidity sweeps (stop hunts) 
•	Market structure confirmation (BOS) 
•	VWAP bias filtering 
•	ATR-based volatility and risk alignment 
•	Session-based timing (Asian, London, New York) 
It not only finds trade opportunities but also provides built-in risk levels, targets, and a quality score for each signal.
________________________________________
Core Features
1. KLS Signals (Koda Liquidity Sweep)
The indicator detects when price:
•	Sweeps a previous high or low (liquidity grab) 
•	Shows rejection (wick confirmation) 
•	Optionally confirms with: 
o	Break of Structure (BOS) 
o	VWAP alignment 
o	Minimum ATR-based move 
Outputs:
•	KLS Buy 
•	KLS Sell 
________________________________________
2. Smart Session Filtering
Only generates signals during selected sessions:
•	Asian 
•	London 
•	New York 
Helps you trade when liquidity is actually present.
________________________________________
3. ATR-Based Risk System
Uses daily ATR to automatically calculate:
•	Stop loss distance 
•	Target levels (TP1, TP2) 
•	Minimum valid sweep size 
Keeps your trades aligned with volatility.
________________________________________
4. Built-In Trade Levels
When a signal appears, it plots:
•	Stop Loss (red dashed line) 
•	Target 1 (green dashed) 
•	Target 2 (green solid) 
________________________________________
5. Trade Quality Score (0–100)
Each setup is scored based on:
•	Sweep validity 
•	BOS confirmation 
•	VWAP alignment 
•	ATR strength 
•	Session validity 
Helps you filter out weak setups.
________________________________________
6. Dashboard (Movable)
Displays:
•	ATR and 30% ATR 
•	Minimum sweep size 
•	Session status (ACTIVE/OFF) 
•	VWAP / BOS status 
•	Current signal 
•	Trade quality score 
Can be placed:
•	Top / Bottom 
•	Left / Center / Right 
________________________________________
How to Use It
Step 1: Choose Your Sessions
Enable only the sessions you trade:
•	Scalpers → London + New York 
•	Swing traders → All sessions 
________________________________________
Step 2: Wait for KLS Signals
Look for:
•	KLS Buy below price → potential long 
•	KLS Sell above price → potential short 
________________________________________
Step 3: Confirm Conditions
Higher-quality trades:
•	Score ≥ 70 
•	Align with VWAP direction 
•	Occur during active session 
•	Strong rejection wick 
________________________________________
Step 4: Use Auto Risk Levels
When a signal prints:
•	Entry: current close 
•	Stop: ATR-based 
•	Targets: TP1 and TP2 
You can plug these directly into bracket orders.
________________________________________
Step 5: Manage the Trade
•	Take partial profit at TP1 
•	Let runner go to TP2 
•	Exit early if structure breaks 
________________________________________
Best Practices
•	Avoid trading outside selected sessions 
•	Ignore signals with low quality scores 
•	Do not override stops (they’re volatility-based) 
•	Combine with your own bias (trend, higher timeframe) 
________________________________________
Ideal For
•	Scalpers (especially NASDAQ / ES / MNQ) 
•	Intraday traders 
•	Traders using liquidity + structure concepts 
________________________________________
Simple Strategy Example
Buy Setup:
•	KLS Buy appears 
•	Score ≥ 70 
•	Price above VWAP 
•	During London/NY session 
Enter long → use plotted stop → target TP1/TP2
________________________________________
Bottom Line
The Koda Full System helps you:
Trade only when liquidity, structure, volatility, and timing all align.
It removes guesswork and replaces it with:
•	Clear signals 
•	Defined risk 
•	Measurable trade quality 
________________________________________
If you want, I can also:
•	Turn this into a TradingView description page 
•	Or simplify it into a quick cheat sheet for daily use

## Source Code

````pine
//@version=5
indicator("Koda Full System", shorttitle="Koda Full", overlay=true, max_lines_count=200, max_labels_count=200)

// Author: Tono Miakoda

//====================================================
// INPUTS
//====================================================
groupSessions = "Sessions"
useAsian      = input.bool(false, "Use Asian Session", group=groupSessions)
useLondon     = input.bool(true, "Use London Session", group=groupSessions)
useNewYork    = input.bool(true, "Use New York Session", group=groupSessions)
asianSession  = input.session("1800-0300", "Asian Session", group=groupSessions)
londonSession = input.session("0300-1130", "London Session", group=groupSessions)
nySession     = input.session("0930-1600", "New York Session", group=groupSessions)
tzPreset      = input.string("New York", "Session Timezone Preset", options=["New York", "London", "Exchange", "UTC"], group=groupSessions)

groupSweep    = "Sweep Logic"
lookbackLiq   = input.int(20, "Liquidity Lookback", minval=5, group=groupSweep)
useBOS        = input.bool(true, "Require BOS Confirmation", group=groupSweep)
bosLookback   = input.int(10, "BOS Lookback", minval=2, group=groupSweep)
useVWAP       = input.bool(true, "Use VWAP Filter", group=groupSweep)
minWickRatio  = input.float(0.35, "Min Rejection Wick Ratio", step=0.05, group=groupSweep)

groupATR      = "ATR / Risk Alignment"
atrLen        = input.int(14, "ATRD Length", minval=1, group=groupATR)
minATRFrac    = input.float(0.15, "Minimum Sweep Size as Fraction of 30% ATRD", step=0.01, group=groupATR)
stopATRFrac   = input.float(0.30, "Stop Distance = Fraction of ATRD", step=0.01, group=groupATR)
tp1R          = input.float(1.0, "Target 1 (R)", step=0.25, group=groupATR)
tp2R          = input.float(2.0, "Target 2 (R)", step=0.25, group=groupATR)

groupDisplay  = "Display"
showStops     = input.bool(true, "Show Stop / Target Lines", group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
dashPosInput  = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupDisplay)
showLabels    = input.bool(true, "Show KLS Labels", group=groupDisplay)

//====================================================
// COLORS
//====================================================
kodaBlue   = color.rgb(25, 70, 160)
kodaYellow = color.rgb(245, 200, 35)
kodaGreen  = color.rgb(22, 163, 74)
kodaRed    = color.rgb(214, 40, 57)
kodaGray   = color.rgb(100, 116, 139)

//====================================================
// TIMEZONE
//====================================================
sessionTz = "America/New_York"
if tzPreset == "London"
    sessionTz := "Europe/London"
if tzPreset == "Exchange"
    sessionTz := syminfo.timezone
if tzPreset == "UTC"
    sessionTz := "Etc/UTC"

//====================================================
// SESSION FILTER
//====================================================
inAsian   = not na(time(timeframe.period, asianSession, sessionTz))
inLondon  = not na(time(timeframe.period, londonSession, sessionTz))
inNewYork = not na(time(timeframe.period, nySession, sessionTz))

sessionValid = (useAsian and inAsian) or (useLondon and inLondon) or (useNewYork and inNewYork)

//====================================================
// ATRD
//====================================================
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLen))
atrStop  = dailyATR * stopATRFrac
atr30    = dailyATR * 0.30
minSweep = atr30 * minATRFrac

//====================================================
// VWAP
//====================================================
vwapValue = ta.vwap(hlc3)

//====================================================
// LIQUIDITY LEVELS
//====================================================
prevHigh = ta.highest(high, lookbackLiq)[1]
prevLow  = ta.lowest(low, lookbackLiq)[1]

//====================================================
// CANDLE STRUCTURE / REJECTION
//====================================================
rng = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bullBody = close > open
bearBody = close < open

bullReject = lowerWick / rng >= minWickRatio and close > prevLow
bearReject = upperWick / rng >= minWickRatio and close < prevHigh

//====================================================
// SWEEP DETECTION
//====================================================
sweepLow  = low < prevLow and close > prevLow
sweepHigh = high > prevHigh and close < prevHigh

realBuySweep  = sweepLow and bullReject
realSellSweep = sweepHigh and bearReject

//====================================================
// BOS CONFIRMATION
//====================================================
bullBos = close > ta.highest(high, bosLookback)[1]
bearBos = close < ta.lowest(low, bosLookback)[1]

buyBosOk  = not useBOS or bullBos
sellBosOk = not useBOS or bearBos

//====================================================
// VWAP FILTER
//====================================================
buyVwapOk  = not useVWAP or close >= vwapValue
sellVwapOk = not useVWAP or close <= vwapValue

//====================================================
// ATR SPACE FILTER
//====================================================
buySweepSize  = prevLow - low
sellSweepSize = high - prevHigh

buyAtrOk  = buySweepSize >= minSweep
sellAtrOk = sellSweepSize >= minSweep

//====================================================
// FINAL SIGNALS
//====================================================
KLS_Buy  = realBuySweep and buyBosOk and buyVwapOk and buyAtrOk and sessionValid
KLS_Sell = realSellSweep and sellBosOk and sellVwapOk and sellAtrOk and sessionValid

//====================================================
// AUTO RISK LEVELS
//====================================================
buyEntry = close
sellEntry = close

buyStop = buyEntry - atrStop
sellStop = sellEntry + atrStop

buyTP1 = buyEntry + atrStop * tp1R
buyTP2 = buyEntry + atrStop * tp2R
sellTP1 = sellEntry - atrStop * tp1R
sellTP2 = sellEntry - atrStop * tp2R

//====================================================
// TRADE QUALITY SCORE
//====================================================
buyScore =
     (realBuySweep ? 25 : 0) +
     (buyBosOk ? 20 : 0) +
     (buyVwapOk ? 15 : 0) +
     (buyAtrOk ? 25 : 0) +
     (sessionValid ? 15 : 0)

sellScore =
     (realSellSweep ? 25 : 0) +
     (sellBosOk ? 20 : 0) +
     (sellVwapOk ? 15 : 0) +
     (sellAtrOk ? 25 : 0) +
     (sessionValid ? 15 : 0)

//====================================================
// PLOTS
//====================================================
plotshape(KLS_Buy and showLabels, title="KLS Buy", location=location.belowbar, style=shape.labelup, text="KLS Buy", color=kodaBlue, textcolor=color.white, size=size.small)
plotshape(KLS_Sell and showLabels, title="KLS Sell", location=location.abovebar, style=shape.labeldown, text="KLS Sell", color=kodaYellow, textcolor=color.black, size=size.small)

plot(useVWAP ? vwapValue : na, title="VWAP", color=color.new(kodaBlue, 0), linewidth=2)

plot(prevHigh, title="Liquidity High", color=color.new(kodaYellow, 80), linewidth=1, style=plot.style_linebr)
plot(prevLow, title="Liquidity Low", color=color.new(kodaBlue, 80), linewidth=1, style=plot.style_linebr)

//====================================================
// STOP / TARGET LINES
//====================================================
var line buyStopLine = na
var line buyTp1Line  = na
var line buyTp2Line  = na
var line sellStopLine = na
var line sellTp1Line  = na
var line sellTp2Line  = na

if KLS_Buy and showStops
    if not na(buyStopLine)
        line.delete(buyStopLine)
    if not na(buyTp1Line)
        line.delete(buyTp1Line)
    if not na(buyTp2Line)
        line.delete(buyTp2Line)

    buyStopLine := line.new(bar_index, buyStop, bar_index + 1, buyStop, xloc=xloc.bar_index, extend=extend.right, color=kodaRed, style=line.style_dashed, width=2)
    buyTp1Line  := line.new(bar_index, buyTP1, bar_index + 1, buyTP1, xloc=xloc.bar_index, extend=extend.right, color=kodaGreen, style=line.style_dashed, width=2)
    buyTp2Line  := line.new(bar_index, buyTP2, bar_index + 1, buyTP2, xloc=xloc.bar_index, extend=extend.right, color=kodaGreen, style=line.style_solid, width=2)

if KLS_Sell and showStops
    if not na(sellStopLine)
        line.delete(sellStopLine)
    if not na(sellTp1Line)
        line.delete(sellTp1Line)
    if not na(sellTp2Line)
        line.delete(sellTp2Line)

    sellStopLine := line.new(bar_index, sellStop, bar_index + 1, sellStop, xloc=xloc.bar_index, extend=extend.right, color=kodaRed, style=line.style_dashed, width=2)
    sellTp1Line  := line.new(bar_index, sellTP1, bar_index + 1, sellTP1, xloc=xloc.bar_index, extend=extend.right, color=kodaGreen, style=line.style_dashed, width=2)
    sellTp2Line  := line.new(bar_index, sellTP2, bar_index + 1, sellTP2, xloc=xloc.bar_index, extend=extend.right, color=kodaGreen, style=line.style_solid, width=2)

//====================================================
// DASHBOARD TABLES
//====================================================
var table dashTopLeft = table.new(position.top_left, 1, 9, border_width=1)
var table dashTopCenter = table.new(position.top_center, 1, 9, border_width=1)
var table dashTopRight = table.new(position.top_right, 1, 9, border_width=1)
var table dashBottomLeft = table.new(position.bottom_left, 1, 9, border_width=1)
var table dashBottomCenter = table.new(position.bottom_center, 1, 9, border_width=1)
var table dashBottomRight = table.new(position.bottom_right, 1, 9, border_width=1)

f_clearDash(_dash) =>
    table.clear(_dash, 0, 0, 0, 8)

f_drawDash(_dash) =>
    string activeSessionText = sessionValid ? "ACTIVE" : "OFF"
    string signalText = KLS_Buy ? "KLS BUY" : KLS_Sell ? "KLS SELL" : "NO SIGNAL"
    string qualityText = KLS_Buy ? str.tostring(buyScore) : KLS_Sell ? str.tostring(sellScore) : "0"

    table.cell(_dash, 0, 0, "Koda Full System", text_color=color.white, bgcolor=kodaBlue)
    table.cell(_dash, 0, 1, "ATRD: " + str.tostring(dailyATR, format.mintick), text_color=color.black, bgcolor=kodaYellow)
    table.cell(_dash, 0, 2, "30% ATRD: " + str.tostring(atr30, format.mintick), text_color=color.white, bgcolor=color.new(kodaBlue, 10))
    table.cell(_dash, 0, 3, "Min Sweep: " + str.tostring(minSweep, format.mintick), text_color=color.white, bgcolor=color.new(kodaBlue, 20))
    table.cell(_dash, 0, 4, "Session: " + activeSessionText, text_color=color.white, bgcolor=sessionValid ? color.new(kodaGreen, 0) : color.new(kodaGray, 20))
    table.cell(_dash, 0, 5, "VWAP: " + (useVWAP ? "ON" : "OFF"), text_color=color.white, bgcolor=color.new(kodaBlue, 30))
    table.cell(_dash, 0, 6, "BOS: " + (useBOS ? "ON" : "OFF"), text_color=color.white, bgcolor=color.new(kodaBlue, 40))
    table.cell(_dash, 0, 7, "Signal: " + signalText, text_color=KLS_Sell ? color.black : color.white, bgcolor=KLS_Buy ? kodaBlue : KLS_Sell ? kodaYellow : color.new(kodaGray, 30))
    table.cell(_dash, 0, 8, "Quality: " + qualityText + "/100", text_color=color.white, bgcolor=color.new(kodaGreen, 25))

if barstate.islast
    f_clearDash(dashTopLeft)
    f_clearDash(dashTopCenter)
    f_clearDash(dashTopRight)
    f_clearDash(dashBottomLeft)
    f_clearDash(dashBottomCenter)
    f_clearDash(dashBottomRight)

    if showDashboard
        if dashPosInput == "Top Left"
            f_drawDash(dashTopLeft)
        else if dashPosInput == "Top Center"
            f_drawDash(dashTopCenter)
        else if dashPosInput == "Top Right"
            f_drawDash(dashTopRight)
        else if dashPosInput == "Bottom Left"
            f_drawDash(dashBottomLeft)
        else if dashPosInput == "Bottom Center"
            f_drawDash(dashBottomCenter)
        else
            f_drawDash(dashBottomRight)

//====================================================
// ALERTS
//====================================================
alertcondition(KLS_Buy, "Koda Full System Buy", "KLS Buy on {{ticker}}")
alertcondition(KLS_Sell, "Koda Full System Sell", "KLS Sell on {{ticker}}")
````
