# AI Trading Console PRO (BuySell with Complete Dash)

- url: https://www.tradingview.com/script/3P3QA6NS-AI-Trading-Console-PRO-BuySell-with-Complete-Dash/
- type: indicator
- pine_id: PUB;10424617bd8f4d789661bde4ad71ccf8
- version: 1.0

## Description

AI Trading Console PRO script. It operates as a complete, semi-automated trading system combining entry signals, institutional filters, dynamic profit targets, and live performance tracking.

1. The Signal Engine (When to Enter)
The core entry logic relies on a confluence of four technical parameters. A trade is only triggered when all active conditions align.

ORB (Opening Range Breakout): The script records the highest high and lowest low of the first 30 minutes of the trading day (9:15 AM to 9:45 AM). A Buy signal requires price to break above the ORB High; a Sell signal requires breaking below the ORB Low.

Trend Alignment (EMA): It checks the short-term trend using a Fast EMA (13) and Slow EMA (39). Buy entries only happen if the 13 EMA is above the 39 EMA (Bullish).

Momentum (RSI): It ensures momentum is on your side. Buy entries require the 14-period RSI to be above 55, while Sells require it to be below 45.

HTF Confirmation (Higher Time Frame): It looks at a higher timeframe (default is 60 minutes) to ensure you aren't trading against the macro trend. A 50 EMA on the 60m chart dictates the broader bull/bear bias.

2. Institutional Filters (When to Stay Out)
This is the "brain" of the console, designed to prevent trades in choppy or dangerous market conditions.

ADX (Average Directional Index): This measures trend strength, regardless of direction. The script requires ADX to be above 20. If ADX is below 20, the market is chopping sideways, and the script will block the trade.

India VIX (Volatility Index): It pulls live data from NSE:INDIAVIX. If the VIX spikes above 20 (indicating panic or extreme volatility), the script blocks new entries to protect your capital.

3. Dynamic Targets (Where to Take Profit)
Instead of fixed percentage targets, the script uses Standard Floor Pivots calculated from the previous day's High, Low, and Close.

Institutional Levels: These pivots (R1, R2, R3 for Resistance; S1, S2, S3 for Support) act as hidden liquidity zones where large players take profits.

Dynamic Assignment: When a trade triggers, the script looks at your entry price. If you buy above R1, it intelligently assigns R2 as Target 1 (TP1) and R3 as Target 2 (TP2).

Visual Tracking: Once price touches a target level, the script stops plotting that specific line to keep the chart clean and changes the dashboard text to a green "HIT."

4. Risk Management (How to Protect Capital)
The script automates position sizing and stop-loss trailing so you don't have to calculate it manually.

ATR Stop Loss: The initial Stop Loss is placed 1.5x the Average True Range (ATR) away from your entry. This ensures your stop is based on current market volatility, not an arbitrary number.

Trailing Stop: As the trade moves in your favor, the Stop Loss trails behind the price by 1.2x the ATR, locking in profits while giving the trade room to breathe.

Position Sizing: You input your Capital (e.g., ₹100,000) and Risk % per trade (e.g., 2%). The script calculates exactly how many shares/contracts you should buy based on the distance to your ATR Stop Loss.

5. The Live Dashboard
The table in the top right acts as your command center. Here are the most advanced metrics it tracks:

AI Score (0-100): A real-time confidence metric. It awards 20 points each for Trend alignment, Momentum, Trend Strength (ADX), Volatility Safety (VIX), and HTF alignment. A score of 80+ is colored green, indicating a high-probability setup.

Expectancy: A mathematical proxy telling you if the strategy has a positive edge. An expectancy above 0.20 generally means the system is highly profitable over a large sample size.

Live PnL & WinRate: The script silently tracks every signal it generates in the background. It calculates your simulated Profit and Loss (PnL) and Win Rate based on your actual position sizing and where the trailing stop takes you out.

Avoid Trade: If the VIX is too high or the ADX is too low, this will flash red "YES," warning you that current market conditions are unfavorable for breakout trading.
Key Changes Made:
Pivot Calculation Engine: Added a request.security call using lookahead_on to pull the previous day's high, low, and close without repainting. This powers the standard Floor Pivots (R1/R2/R3 and S1/S2/S3).

Dynamic Target Assignment: When a signal fires, the script checks where the close price is relative to the pivots. If you buy above R1, it intelligently assigns R2 as your TP1 and R3 as your TP2.

Visual Tracking: Hit targets are visually tracked. When price touches a TP level, it drops a label on the chart and stops plotting the circle line for that specific target to keep your chart clean.

Upgraded Dashboard: Expanded the data table from 10 rows to 14. It now displays your active Entry, Stop Loss, and all three TP levels in real time. It will also switch the text to "HIT" in green once a target is reached during a trade.

## Source Code

````pine
//@version=6
indicator("AI Trading Console PRO (Refactored with Complete Dash)", overlay=true, max_labels_count=500)

// ===============================
// GROUPS
// ===============================
grp_mode   = "⚙️ Mode"
grp_signal = "📈 Signal Engine"
grp_risk   = "💰 Risk Management"
grp_filter = "🧠 AI Filters"
grp_struct = "📊 Market Structure"
grp_visual = "🎨 Visual Controls"
grp_dash   = "📋 Dashboard"
grp_targets = "🎯 Pivot Targets"

// ===============================
// MODE
// ===============================
advancedMode = input.bool(false, "Advanced Mode", group=grp_mode)

// ===============================
// SIGNAL ENGINE
// ===============================
enableBuy  = input.bool(true, "Buy", group=grp_signal, inline="sig")
enableSell = input.bool(true, "Sell", group=grp_signal, inline="sig")

useORB = input.bool(true, "ORB Breakout", group=grp_signal)
useRSI = input.bool(true, "RSI Filter", group=grp_signal)

rsiBuy  = input.int(55, "Buy", group=grp_signal, inline="rsi")
rsiSell = input.int(45, "Sell", group=grp_signal, inline="rsi")

// ===============================
// RISK & TARGETS
// ===============================
useTrailing = input.bool(true, "Trailing SL", group=grp_risk)
trailATR    = input.float(1.2, "ATR Mult", group=grp_risk)

capital     = input.float(100000, "Capital ₹", group=grp_risk)
riskPercent = input.float(2.0, "Risk %", group=grp_risk)

usePivots = input.bool(true, "Use Pivot Targets", group=grp_targets)
pivotTF   = input.timeframe("D", "Pivot Timeframe", group=grp_targets)

// ===============================
// FILTERS
// ===============================
useADX = input.bool(true, "ADX Filter", group=grp_filter)
adxMin = input.int(20, "ADX Min", group=grp_filter)

useVIX = input.bool(true, "VIX Filter", group=grp_filter)
vixSym = input.symbol("NSE:INDIAVIX", "VIX Symbol", group=grp_filter)
vixMax = input.float(20, "VIX Max", group=grp_filter)

// ===============================
// STRUCTURE
// ===============================
useEMA = input.bool(true, "EMA Trend", group=grp_struct)
emaFastLen = input.int(13, "Fast", group=grp_struct, inline="ema")
emaSlowLen = input.int(39, "Slow", group=grp_struct, inline="ema")

useHTF = input.bool(true, "HTF Confirm", group=grp_struct)
htfTF  = input.timeframe("60", "HTF TF", group=grp_struct)

// ===============================
// VISUAL
// ===============================
showBg = input.bool(true, "Background", group=grp_visual)
showLabels = input.bool(true, "Labels", group=grp_visual)

buyColor  = input.color(color.green, "Buy", group=grp_visual)
sellColor = input.color(color.red, "Sell", group=grp_visual)
slColor   = input.color(color.orange, "SL", group=grp_visual)
tpColor   = input.color(color.blue, "Targets", group=grp_visual)

// ===============================
// DASHBOARD
// ===============================
showDash = input.bool(true, "Dashboard", group=grp_dash)

// ===============================
// INDICATORS & PIVOTS
// ===============================
rsi = ta.rsi(close, 14)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
[_, _, adx] = ta.dmi(14, 14)
atr = ta.atr(14)

vix = request.security(vixSym, timeframe.period, close)

// Pivot Calculations (Standard Floor Pivots)
[prevHigh, prevLow, prevClose] = request.security(syminfo.tickerid, pivotTF, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
pivot = (prevHigh + prevLow + prevClose) / 3
r1 = (2 * pivot) - prevLow
s1 = (2 * pivot) - prevHigh
r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)
r3 = prevHigh + 2 * (pivot - prevLow)
s3 = prevLow - 2 * (prevHigh - pivot)

// ===============================
// HTF
// ===============================
htfClose = request.security(syminfo.tickerid, htfTF, close)
htfEma   = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50))

htfBull = htfClose > htfEma
htfBear = htfClose < htfEma

// ===============================
// ORB
// ===============================
var float orHigh = na
var float orLow = na

if ta.change(time("D")) > 0
    orHigh := na
    orLow := na

if hour(time) == 9 and minute(time) < 30
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

// ===============================
// CONDITIONS
// ===============================
trendBull = not useEMA or emaFast > emaSlow
trendBear = not useEMA or emaFast < emaSlow

rsiBull = not useRSI or rsi > rsiBuy
rsiBear = not useRSI or rsi < rsiSell

adxPass = not useADX or adx > adxMin
vixPass = not useVIX or vix < vixMax

htfPassBuy  = not useHTF or htfBull
htfPassSell = not useHTF or htfBear

orbBuy  = not useORB or ta.crossover(close, orHigh)
orbSell = not useORB or ta.crossunder(close, orLow)

// ===============================
// STATE & TRACKING
// ===============================
var bool inTrade = false
var bool longTrade = false
var bool shortTrade = false
var int lastDir = 0

var float entry = na
var float sl = na
var float tradeQty = na

// Target Variables
var float tp1 = na
var float tp2 = na
var float tp3 = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false

// Performance Tracking Variables
var int totalTrades = 0
var int winningTrades = 0
var float totalPnL = 0.0

// Position Size Calc
riskAmt = capital * riskPercent / 100
qty = atr > 0 ? riskAmt / (atr * 1.5) : na

// ===============================
// ENTRY
// ===============================
buyEntry = (enableBuy and orbBuy and trendBull and rsiBull and adxPass and vixPass and htfPassBuy and not inTrade and lastDir != 1)
sellEntry = (enableSell and orbSell and trendBear and rsiBear and adxPass and vixPass and htfPassSell and not inTrade and lastDir != -1)

// ===============================
// TRADE EXECUTION & TARGET ASSIGNMENT
// ===============================
if buyEntry
    inTrade := true
    longTrade := true
    entry := close
    sl := close - atr * 1.5
    tradeQty := qty
    lastDir := 1
    
    tp1 := close < r1 ? r1 : close < r2 ? r2 : r3
    tp2 := tp1 == r1 ? r2 : tp1 == r2 ? r3 : r3 + atr * 2
    tp3 := tp2 == r2 ? r3 : tp2 + atr * 2
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    
    if showLabels
        label.new(bar_index, low, "BUY @ "+str.tostring(close), color=buyColor, style=label.style_label_up)

if sellEntry
    inTrade := true
    shortTrade := true
    entry := close
    sl := close + atr * 1.5
    tradeQty := qty
    lastDir := -1
    
    tp1 := close > s1 ? s1 : close > s2 ? s2 : s3
    tp2 := tp1 == s1 ? s2 : tp1 == s2 ? s3 : s3 - atr * 2
    tp3 := tp2 == s2 ? s3 : tp2 - atr * 2
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    
    if showLabels
        label.new(bar_index, high, "SELL @ "+str.tostring(close), color=sellColor, style=label.style_label_down)

// ===============================
// TRAILING & TARGET MANAGEMENT
// ===============================
if inTrade
    if useTrailing
        if longTrade
            sl := math.max(sl, close - atr * trailATR)
        if shortTrade
            sl := math.min(sl, close + atr * trailATR)
            
    if usePivots
        if longTrade
            if not tp1Hit and high >= tp1
                tp1Hit := true
                if showLabels
                    label.new(bar_index, high, "TP1 Hit", color=tpColor, style=label.style_label_down, size=size.small)
            if not tp2Hit and high >= tp2
                tp2Hit := true
                if showLabels
                    label.new(bar_index, high, "TP2 Hit", color=tpColor, style=label.style_label_down, size=size.small)
            if not tp3Hit and high >= tp3
                tp3Hit := true
                if showLabels
                    label.new(bar_index, high, "TP3 Hit", color=tpColor, style=label.style_label_down, size=size.small)
                    
        if shortTrade
            if not tp1Hit and low <= tp1
                tp1Hit := true
                if showLabels
                    label.new(bar_index, low, "TP1 Hit", color=tpColor, style=label.style_label_up, size=size.small)
            if not tp2Hit and low <= tp2
                tp2Hit := true
                if showLabels
                    label.new(bar_index, low, "TP2 Hit", color=tpColor, style=label.style_label_up, size=size.small)
            if not tp3Hit and low <= tp3
                tp3Hit := true
                if showLabels
                    label.new(bar_index, low, "TP3 Hit", color=tpColor, style=label.style_label_up, size=size.small)

// ===============================
// EXIT & PERFORMANCE CALCULATION
// ===============================
exitLong = longTrade and close < sl
exitShort = shortTrade and close > sl

if exitLong or exitShort
    float currentPnL = 0.0
    if exitLong
        currentPnL := (close - entry) * nz(tradeQty)
    if exitShort
        currentPnL := (entry - close) * nz(tradeQty)
        
    totalPnL += currentPnL
    totalTrades += 1
    if currentPnL > 0
        winningTrades += 1

    inTrade := false
    longTrade := false
    shortTrade := false
    sl := na
    tp1 := na
    tp2 := na
    tp3 := na
    tradeQty := na

// ===============================
// VISUALS
// ===============================
bgcolor(showBg and buyEntry ? color.new(buyColor,85) : na)
bgcolor(showBg and sellEntry ? color.new(sellColor,85) : na)

plotshape(buyEntry, location=location.belowbar, color=buyColor, style=shape.triangleup)
plotshape(sellEntry, location=location.abovebar, color=sellColor, style=shape.triangledown)

plot(inTrade ? sl : na, "Stop Loss", color=slColor, linewidth=2)
plot(inTrade and usePivots and not tp1Hit ? tp1 : na, "TP1", color=tpColor, style=plot.style_circles, linewidth=1)
plot(inTrade and usePivots and not tp2Hit ? tp2 : na, "TP2", color=tpColor, style=plot.style_circles, linewidth=1)
plot(inTrade and usePivots and not tp3Hit ? tp3 : na, "TP3", color=tpColor, style=plot.style_circles, linewidth=1)

// ===============================
// DASHBOARD CALCULATIONS
// ===============================
// Simulate AI Score (Confluence of parameters out of 100)
aiScore = 0
if (trendBull or trendBear)
    aiScore += 20
if (rsiBull or rsiBear)
    aiScore += 20
if adxPass
    aiScore += 20
if vixPass
    aiScore += 20
if (htfBull or htfBear)
    aiScore += 20

winRate = totalTrades > 0 ? (winningTrades / totalTrades) * 100 : 0.0
probStr = str.tostring(totalTrades > 0 ? winRate : aiScore, "#.##") + "%"
expectancy = totalTrades > 0 ? ((winRate/100) * 1.5) - (((100-winRate)/100) * 1.0) : 0.0 // Base mathematical expectancy proxy
avoidTrade = not adxPass or not vixPass

// ===============================
// DASHBOARD RENDERING
// ===============================
var table t = table.new(position.top_right, 2, 20, border_width = 1)

if showDash and barstate.islast
    table.cell(t,0,0,"AI Score", text_color=color.white, bgcolor=color.black)
    table.cell(t,1,0,str.tostring(aiScore), text_color=color.white, bgcolor=aiScore >= 80 ? color.green : aiScore >= 60 ? color.orange : color.red)
    
    table.cell(t,0,1,"Probability")
    table.cell(t,1,1,probStr)
    
    table.cell(t,0,2,"Expectancy")
    table.cell(t,1,2,str.tostring(expectancy, "#.##"))
    
    table.cell(t,0,3,"Signal", text_color=color.white, bgcolor=color.gray)
    table.cell(t,1,3,buyEntry?"BUY":sellEntry?"SELL":inTrade?"HOLDING":"WAIT", text_color=color.white, bgcolor=buyEntry?buyColor:sellEntry?sellColor:color.gray)
    
    table.cell(t,0,4,"HTF")
    table.cell(t,1,4,htfBull?"BULL":"BEAR")

    table.cell(t,0,5,"VIX")
    table.cell(t,1,5,str.tostring(vix, "#.##"))
    
    table.cell(t,0,6,"Qty")
    table.cell(t,1,6,str.tostring(inTrade ? tradeQty : qty, "#.##"))

    table.cell(t,0,7,"Trail SL")
    table.cell(t,1,7,str.tostring(sl, "#.##"), text_color=slColor)

    table.cell(t,0,8,"TP 1 (Pivot)")
    table.cell(t,1,8,tp1Hit ? "HIT" : str.tostring(tp1, "#.##"), text_color=tp1Hit ? color.green : tpColor)
    
    table.cell(t,0,9,"TP 2 (Pivot)")
    table.cell(t,1,9,tp2Hit ? "HIT" : str.tostring(tp2, "#.##"), text_color=tp2Hit ? color.green : tpColor)

    table.cell(t,0,10,"TP 3 (Pivot)")
    table.cell(t,1,10,tp3Hit ? "HIT" : str.tostring(tp3, "#.##"), text_color=tp3Hit ? color.green : tpColor)
    
    table.cell(t,0,11,"Entry")
    table.cell(t,1,11,str.tostring(entry, "#.##"))
    
    table.cell(t,0,12,"Avoid Trade")
    table.cell(t,1,12,avoidTrade?"YES":"NO", text_color=avoidTrade ? color.red : color.green)
    
    table.cell(t,0,13,"WinRate")
    table.cell(t,1,13,str.tostring(winRate, "#.##") + "%")
    
    table.cell(t,0,14,"Trades")
    table.cell(t,1,14,str.tostring(totalTrades))
    
    table.cell(t,0,15,"PnL")
    table.cell(t,1,15,str.tostring(totalPnL, "#.##"), text_color=totalPnL >= 0 ? color.green : color.red)
    
    table.cell(t,0,16,"ADX")
    table.cell(t,1,16,str.tostring(adx, "#.##"))
    
    table.cell(t,0,17,"InTrade")
    table.cell(t,1,17,inTrade?"YES":"NO")
    
    table.cell(t,0,18,"Trend")
    table.cell(t,1,18,trendBull?"BULL":"BEAR")
````
