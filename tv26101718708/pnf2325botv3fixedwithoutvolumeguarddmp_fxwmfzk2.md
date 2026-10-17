# PNF2325-Bot-V3-FIXED-Without-Volume-Guard-DMP

- url: https://www.tradingview.com/script/FxWmfZk2-PNF2325-Bot-V3-FIXED-Without-Volume-Guard-DMP/
- type: indicator
- pine_id: PUB;3503b1631c6f485d8d59c95a96dc8c29
- version: 1.0

## Description

Point & figure trading indicator with alert sysytem pnf method high low.

## Source Code

````pine
//@version=5
indicator("PNF2325-Bot-V3-FIXED-Without-Volume-Guard-DMP", overlay=true, max_labels_count=500)

// --- 1. SETTINGS ---
secretToken    = input.string("SECRET_PNF23", "Bot Password")
stratId        = input.string("13f5d1c10e4cb47b0eeb589f48cdd674", "Strategy ID")
manualEntryRev = input.float(1.0, "Entry Reversal ($1.00)")
autoRevPercent = input.float(3.0, "Trend Protection (%)")
slOffset       = input.float(0.500, "Stop Loss Offset")
tradeQty       = input.float(1)

// --- 2. PERSISTENT MEMORY (Using varip for Real-Time Accuracy) ---
varip float lastHigh      = high
varip float lastLow       = low
varip string currentTrend = "X" 
varip float activeRev     = manualEntryRev 
varip float currentSL     = 0.0 // Default to 0.0 to avoid 'na' JSON errors

// --- 3. DYNAMIC REVERSAL CALCULATOR ---
getAutoRev() => (high * (autoRevPercent / 100))

// --- 4. THE CORE LOGIC ---
float flipTarget = currentTrend == "X" ? (lastHigh - activeRev) : (lastLow + activeRev)

// BEARISH REVERSAL (SELL RIP)
if currentTrend == "X" and low <= flipTarget
    currentTrend := "O"
    lastLow      := low
    activeRev    := manualEntryRev
    currentSL    := high + slOffset
    //, "stop_loss": ' + str.tostring(currentSL) + ',
    // FIXED MESSAGE CONSTRUCTION
    msg = '{"symbol": "' + syminfo.ticker + '", "side": "sell", "qty": "' + str.tostring(math.round(tradeQty)) + '", "trigger_time": "' + str.tostring(timenow) + '", "strategy_id": "' + stratId + '"}'
    
    alert(msg, alert.freq_once_per_bar)
    label.new(bar_index, high, "SELL", color=color.red, style=label.style_label_down, textcolor=color.white)

// BULLISH REVERSAL (BUY DROP)
else if currentTrend == "O" and high >= flipTarget
    currentTrend := "X"
    lastHigh     := high
    activeRev    := manualEntryRev
    currentSL    := low - slOffset
    
    // FIXED MESSAGE CONSTRUCTION
    msg = '{"symbol": "' + syminfo.ticker + '", "side": "buy", "qty": "' + str.tostring(math.round(tradeQty)) + '", "trigger_time": "' + str.tostring(timenow) + '", "strategy_id": "' + stratId + '"}'
    
    alert(msg, alert.freq_once_per_bar)
    label.new(bar_index, low, "BUY", color=color.green, style=label.style_label_up, textcolor=color.white)

// --- CONTINUATION LOGIC ---
if currentTrend == "X" and high > lastHigh
    lastHigh := high
    activeRev := getAutoRev()
else if currentTrend == "O" and low < lastLow
    lastLow := low
    activeRev := getAutoRev()

// --- 5. VISUALS ---
plot(flipTarget, "Reversal Target", color=color.new(color.yellow, 40), style=plot.style_linebr, linewidth=2)
plot(currentSL > 0 ? currentSL : na, "Stop Loss", color=color.new(color.red, 20), linewidth=4, style = plot.style_steplinebr)
````
