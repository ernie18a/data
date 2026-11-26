# HEDGE FUND Liquidity Sniper

- url: https://www.tradingview.com/script/oEpoSDyY-HEDGE-FUND-Liquidity-Sniper/
- type: indicator
- pine_id: PUB;0fe047a97d3a43e79e6f4da421b9356c
- version: 1.0

## Description

🧠 HOW TO USE (IMPORTANT)
✅ Best Setup

Timeframe: 5m / 15m

Confirm HTF bias (1H or 4H)

Trade only A+ setups (few but strong)

## Source Code

````pine
//This pine script code is subject to the terms of the Venusj. All rights reserved. 
//Unauthorized copying, modification, or distribution is strictly prohibited.

//@version=6
indicator("HEDGE FUND Liquidity Sniper", overlay=true, max_labels_count=300)

// ===== INPUTS =====
lookback = input.int(10, "Liquidity Lookback")
atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "SL Multiplier")

htfTF = input.timeframe("1H", "HTF Bias")

// ===== CORE =====
atr = ta.atr(atrLen)

// ===== HTF BIAS =====
htfHigh = request.security(syminfo.tickerid, htfTF, high)
htfLow  = request.security(syminfo.tickerid, htfTF, low)

htfBull = close > ta.sma(htfLow, 20)
htfBear = close < ta.sma(htfHigh, 20)

// ===== LIQUIDITY =====
liqHigh = high > ta.highest(high, lookback)[1] and close < high
liqLow  = low < ta.lowest(low, lookback)[1] and close > low

// ===== MSS =====
bullMSS = ta.crossover(close, ta.highest(high, lookback)[1])
bearMSS = ta.crossunder(close, ta.lowest(low, lookback)[1])

// ===== DISPLACEMENT =====
body = math.abs(close - open)
displacement = body > atr * 0.8

// ===== FVG =====
fvgBull = low > high[2]
fvgBear = high < low[2]

// ===== ORDER BLOCK (Simple ICT) =====
bullOB = close[1] < open[1] and close > high[1]
bearOB = close[1] > open[1] and close < low[1]

// ===== FINAL SETUP =====
buySetup = liqLow and bullMSS and displacement and fvgBull and bullOB and htfBull
sellSetup = liqHigh and bearMSS and displacement and fvgBear and bearOB and htfBear

// ===== TRADE STATE =====
var bool inTrade = false
var float entry = na
var float sl = na
var float tp = na

// ===== STATS =====
var int wins = 0
var int losses = 0

// ===== ENTRY =====
if not inTrade and buySetup
    inTrade := true
    entry := close
    sl := low - atr * atrMult
    risk = entry - sl
    tp := entry + risk * 2

    label.new(bar_index, low, "BUY HF", color=color.green)

if not inTrade and sellSetup
    inTrade := true
    entry := close
    sl := high + atr * atrMult
    risk = sl - entry
    tp := entry - risk * 2

    label.new(bar_index, high, "SELL HF", color=color.red)

// ===== TRAILING STOP =====
if inTrade
    if close > entry
        sl := math.max(sl, close - atr)

// ===== EXIT =====
if inTrade
    tpHit = high >= tp or low <= tp
    slHit = low <= sl or high >= sl

    if tpHit
        wins += 1
        inTrade := false

    if slHit
        losses += 1
        inTrade := false

// ===== DASHBOARD =====
var table dash = table.new(position.top_right, 2, 2)

total = wins + losses
winrate = total > 0 ? (wins / total) * 100 : 0

table.cell(dash, 0, 0, "Wins")
table.cell(dash, 1, 0, str.tostring(wins))

table.cell(dash, 0, 1, "Win %")
table.cell(dash, 1, 1, str.tostring(winrate, "#.##"))

// ===== ALERTS =====
newBuy = buySetup and not inTrade[1]
newSell = sellSetup and not inTrade[1]

alertcondition(newBuy, "HF BUY", "BUY {{ticker}} @ {{close}}")
alertcondition(newSell, "HF SELL", "SELL {{ticker}} @ {{close}}")
````
