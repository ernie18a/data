# DMP-PnFBot-Ghost-V3-Update

- url: https://www.tradingview.com/script/a1irREKG-DMP-PnFBot-Ghost-V3-Update/
- type: indicator
- pine_id: PUB;8df1ccd4bcdb428e9f9908e297e2f94f
- version: 1.0

## Description

Point & figure  daily High low tarditional, box 0.25, rev 3, analyse cndlestick chart 1hr

## Source Code

````pine
//@version=5
indicator("DMP-PnFBot-Ghost-V3-Update", overlay=true, max_labels_count=500)

// --- 1. SETTINGS ---
secretToken    = input.string("Dmp_PNF23", "Bot Password")
stratId        = input.string("d1175f84a50ab5b35", "Strategy ID")
manualEntryRev = input.float(1.0, "Entry Reversal ($)", tooltip="Initial sensitive trigger amount")
autoRevPercent = input.float(3.0, "Trend Protection (%)", tooltip="Wider protection used AFTER entry")
slOffset       = input.float(0.500, "Stop Loss Offset")
tradeQty       = input.float(1.0, "Quantity")

// --- 2. PERSISTENT MEMORY (Intra-bar) ---
varip float lastHigh     = high
varip float lastLow      = low
varip string currentTrend = "X" 
varip float activeRev    = manualEntryRev 
varip float currentSL     = na

// --- 3. DYNAMIC REVERSAL CALCULATOR ---
// Using / 100 for true percentage calculation
getAutoRev(price) => (price * (autoRevPercent / 100))

// --- 4. THE CORE LOGIC ---
float flipTarget = currentTrend == "X" ? (lastHigh - activeRev) : (lastLow + activeRev)

bool triggerBuy  = false
bool triggerSell = false

// BEARISH PROGRESSION (O-Column)
if currentTrend == "O"
    if high >= flipTarget
        // TREND FLIPS TO BUY
        currentTrend := "X"
        lastHigh     := high
        activeRev    := manualEntryRev // Reset to sensitive
        currentSL    := low - slOffset
        triggerBuy   := true
    else
        if low < lastLow
            lastLow   := low 
            activeRev := getAutoRev(low) // Update to 3% trailing protection

// BULLISH PROGRESSION (X-Column)
else // currentTrend == "X"
    if low <= flipTarget
        // TREND FLIPS TO SELL
        currentTrend := "O"
        lastLow      := low
        activeRev    := manualEntryRev // Reset to sensitive
        currentSL    := high + slOffset
        triggerSell  := true
    else
        if high > lastHigh
            lastHigh  := high
            activeRev := getAutoRev(high) // Update to 3% trailing protection

// --- 5. ALERTS & LABELS ---
if triggerBuy
    label.new(bar_index, low, "BUY\n" + str.tostring(low), color=color.green, style=label.style_label_up, textcolor=color.white)
    msg = '{"symbol":"' + syminfo.ticker + '","side":"buy","qty":"' + str.tostring(tradeQty) + '","stop_loss":"' + str.tostring(currentSL) + '","trigger_time":"' + str.format("{0,time,hh:mm:ss a}", timenow) + '","strategy_id":"' + stratId + '"}'
    alert(msg, alert.freq_once_per_bar)

if triggerSell
    label.new(bar_index, high, "SELL\n" + str.tostring(high), color=color.red, style=label.style_label_down, textcolor=color.white)
    msg = '{"symbol":"' + syminfo.ticker + '","side":"sell","qty":"' + str.tostring(tradeQty) + '","stop_loss":"' + str.tostring(currentSL) + '","trigger_time":"' + str.format("{0,time,hh:mm:ss a}", timenow) + '","strategy_id":"' + stratId + '"}'
    alert(msg, alert.freq_once_per_bar)

// --- 6. VISUALS ---
// Plot dots for continuation (Performance friendly)
plotchar(ta.change(lastHigh) and currentTrend == "X", "Cont X", "•", location.abovebar, color.green, size=size.small)
plotchar(ta.change(lastLow) and currentTrend == "O", "Cont O", "•", location.belowbar, color.red, size=size.small)

// Reversal and SL Lines
plot(flipTarget, "Reversal Target", color=color.new(color.orange, 50), style=plot.style_stepline, linewidth=2)
plot(currentSL, "Stop Loss", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=2)

// Trend Background
bgcolor(currentTrend == "X" ? color.new(color.green, 95) : color.new(color.red, 95))

// --- 7. DASHBOARD ---
var table statusTable = table.new(position.top_right, 2, 4, border_width = 1, frame_color=color.gray, border_color=color.gray)

if barstate.islast
    table.cell(statusTable, 0, 0, "TREND", bgcolor=color.black, text_color=color.white)
    table.cell(statusTable, 1, 0, currentTrend == "X" ? "BULLISH" : "BEARISH", bgcolor=currentTrend == "X" ? color.green : color.red, text_color=color.white)
    
    table.cell(statusTable, 0, 1, "FLIP AT", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 1, str.tostring(flipTarget, "#.##"), bgcolor=color.black, text_color=color.orange)

    table.cell(statusTable, 0, 2, "STOP LOSS", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 2, str.tostring(currentSL, "#.##"), bgcolor=color.black, text_color=color.yellow)

    table.cell(statusTable, 0, 3, "ACTIVE REV", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 3, str.tostring(activeRev, "#.##"), bgcolor=color.black, text_color=color.white)
````
