# Bridge Wealth & CO. - MTF Probability Setup

- url: https://www.tradingview.com/script/Qg2c0uur-Bridge-Wealth-CO-MTF-Probability-Setup/
- type: indicator
- pine_id: PUB;9acf02c30bb84747bb31ba61fd7bc663
- version: 1.0

## Description

indicator that uses multiple strategies combined together in one indicator

## Source Code

````pine
//@version=5
indicator("Bridge Wealth & CO. - MTF Probability Setup", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================================================================
// INPUTS (Strictly Identical)
// =========================================================================
grp1 = "Analysis Window"
lookback = input.int(100, "Lookback Period (Recent Candles)", group=grp1)
minScore = input.float(65.0, "Minimum Probability % to Signal", group=grp1)

grp2 = "Trade Setup (Risk/Reward)"
rrRatio  = input.float(1.5, "Risk to Reward Ratio", step=0.1, group=grp2)
slBuffer = input.float(0.05, "Stop Loss Buffer (%)", step=0.01, group=grp2)

grp3 = "Multi-Timeframe Agreement"
useMTF = input.bool(false, "Enable Multi-TF Agreement", group=grp3)
tf1 = input.timeframe("15", "Timeframe 1", group=grp3)
tf2 = input.timeframe("60", "Timeframe 2", group=grp3)
tf3 = input.timeframe("240", "Timeframe 3", group=grp3)

grp4 = "Visuals & History"
showHistory = input.bool(true, "Show Historical Setups", group=grp4, tooltip="Keep past setups on the chart to review performance.")

// =========================================================================
// PROBABILITY / CONFIDENCE CALCULATION (Strictly Identical)
// =========================================================================
f_calc_bias() =>
    bullBody = close > open ? (close - open) : 0
    bearBody = open > close ? (open - close) : 0
    totalBullBody = math.sum(bullBody, lookback)
    totalBearBody = math.sum(bearBody, lookback)
    totalBody = totalBullBody + totalBearBody
    
    bullDominance = totalBody == 0 ? 50 : (totalBullBody / totalBody) * 100
    bearDominance = totalBody == 0 ? 50 : (totalBearBody / totalBody) * 100
    
    ma = ta.sma(close, lookback)
    trendBull = close > ma
    trendBear = close < ma
    
    bullProb = (bullDominance * 0.7) + (trendBull ? 30 : 0)
    bearProb = (bearDominance * 0.7) + (trendBear ? 30 : 0)
    
    string bias = "NEUTRAL"
    float prob = math.max(bullProb, bearProb)
    
    if bullProb > minScore
        bias := "BUY"
    else if bearProb > minScore
        bias := "SELL"
        
    [bias, prob, bullDominance, bearDominance, trendBull, trendBear]

[localBias, localProb, bullDom, bearDom, tBull, tBear] = f_calc_bias()
[bias1, prob1, _, _, _, _] = request.security(syminfo.tickerid, tf1, f_calc_bias(), lookahead=barmerge.lookahead_off)
[bias2, prob2, _, _, _, _] = request.security(syminfo.tickerid, tf2, f_calc_bias(), lookahead=barmerge.lookahead_off)
[bias3, prob3, _, _, _, _] = request.security(syminfo.tickerid, tf3, f_calc_bias(), lookahead=barmerge.lookahead_off)

string rawBias = localBias
float  rawProb = localProb

if useMTF
    buyCount = (localBias == "BUY" ? 1 : 0) + (bias1 == "BUY" ? 1 : 0) + (bias2 == "BUY" ? 1 : 0) + (bias3 == "BUY" ? 1 : 0)
    sellCount = (localBias == "SELL" ? 1 : 0) + (bias1 == "SELL" ? 1 : 0) + (bias2 == "SELL" ? 1 : 0) + (bias3 == "SELL" ? 1 : 0)
    
    if buyCount >= 3
        rawBias := "BUY"
        rawProb := (localProb + prob1 + prob2 + prob3) / 4 
    else if sellCount >= 3
        rawBias := "SELL"
        rawProb := (localProb + prob1 + prob2 + prob3) / 4
    else
        rawBias := "NEUTRAL"
        rawProb := 0

// =========================================================================
// NON-REPAINTING LOCK & EXPLANATION ENGINE (Strictly Identical)
// =========================================================================
var string currentBias = "NEUTRAL"
var float  activeProb  = 0.0
var string reasonText  = "Awaiting clear data."

if barstate.isconfirmed
    currentBias := rawBias
    activeProb  := rawProb
    
    if currentBias == "BUY"
        reasonText := "Bullish volume dominates (" + str.tostring(bullDom, "#.0") + "%). Price is " + (tBull ? "above" : "below") + " the moving average, confirming upward momentum."
        if useMTF
            reasonText := reasonText + " High Timeframes agree."
    else if currentBias == "SELL"
        reasonText := "Bearish volume dominates (" + str.tostring(bearDom, "#.0") + "%). Price is " + (tBear ? "below" : "above") + " the moving average, confirming downward momentum."
        if useMTF
            reasonText := reasonText + " High Timeframes agree."
    else
        reasonText := "Market is choppy. Lack of dominant volume or clear trend alignment."

// =========================================================================
// SETUP GENERATION & NEUTRAL CANCELLATION (Fix Applied)
// =========================================================================
var string activeSignal = "NEUTRAL"
var float  entryPrice   = na
var float  slPrice      = na
var float  tpPrice      = na
var string setupStatus  = "N/A"
var int    signalBar    = na

bool isTradeRunning = (setupStatus == "PENDING" or setupStatus == "TRIGGERED (ACTIVE)")

bool newBuy  = currentBias == "BUY"  and currentBias[1] != "BUY"  and not isTradeRunning
bool newSell = currentBias == "SELL" and currentBias[1] != "SELL" and not isTradeRunning
bool toNeutral = currentBias == "NEUTRAL" and currentBias[1] != "NEUTRAL"

swingLow  = ta.lowest(low, 20)
swingHigh = ta.highest(high, 20)

// Visual Objects
var line lineEntry = na
var line lineSL    = na
var line lineTP    = na
var label lblSetup = na
var label lblTrigger = na

if newBuy
    activeSignal := "BUY"
    entryPrice   := close 
    slPrice      := swingLow * (1 - (slBuffer/100))
    tpPrice      := entryPrice + ((entryPrice - slPrice) * rrRatio)
    setupStatus  := "PENDING"
    signalBar    := bar_index
    
    if not showHistory
        line.delete(lineEntry), line.delete(lineSL), line.delete(lineTP), label.delete(lblSetup), label.delete(lblTrigger)
        
    lineEntry := line.new(signalBar, entryPrice, signalBar + 8, entryPrice, color=color.gray, style=line.style_dashed, width=2)
    lineSL    := line.new(signalBar, slPrice, signalBar + 8, slPrice, color=color.red, style=line.style_solid, width=2)
    lineTP    := line.new(signalBar, tpPrice, signalBar + 8, tpPrice, color=color.green, style=line.style_solid, width=2)
    lblSetup  := label.new(signalBar + 8, entryPrice, text="PENDING BUY", color=color.new(color.black, 40), textcolor=color.green, style=label.style_label_left)

if newSell
    activeSignal := "SELL"
    entryPrice   := close
    slPrice      := swingHigh * (1 + (slBuffer/100))
    tpPrice      := entryPrice - ((slPrice - entryPrice) * rrRatio)
    setupStatus  := "PENDING"
    signalBar    := bar_index
    
    if not showHistory
        line.delete(lineEntry), line.delete(lineSL), line.delete(lineTP), label.delete(lblSetup), label.delete(lblTrigger)
        
    lineEntry := line.new(signalBar, entryPrice, signalBar + 8, entryPrice, color=color.gray, style=line.style_dashed, width=2)
    lineSL    := line.new(signalBar, slPrice, signalBar + 8, slPrice, color=color.red, style=line.style_solid, width=2)
    lineTP    := line.new(signalBar, tpPrice, signalBar + 8, tpPrice, color=color.green, style=line.style_solid, width=2)
    lblSetup  := label.new(signalBar + 8, entryPrice, text="PENDING SELL", color=color.new(color.black, 40), textcolor=color.red, style=label.style_label_left)

// STRICT NEUTRAL CANCEL: If market goes neutral before a pending setup triggers, delete it completely.
if toNeutral
    if setupStatus == "PENDING"
        activeSignal := "NEUTRAL"
        setupStatus  := "N/A"
        line.delete(lineEntry)
        line.delete(lineSL)
        line.delete(lineTP)
        label.delete(lblSetup)
        label.delete(lblTrigger)

// =========================================================================
// INTRA-BAR ACTIVATION & ANCHORING (Strictly Identical)
// =========================================================================
if activeSignal == "BUY"
    if low <= entryPrice and setupStatus == "PENDING"
        setupStatus := "TRIGGERED (ACTIVE)"
        lblTrigger := label.new(bar_index, low, text="⚡ Triggered", color=color.new(color.blue, 0), textcolor=color.white, style=label.style_label_up, size=size.small)
        label.set_text(lblSetup, "ACTIVE BUY")
    if high >= tpPrice and (setupStatus == "TRIGGERED (ACTIVE)" or setupStatus == "PENDING")
        setupStatus := "HIT TP"
        label.set_text(lblSetup, "HIT TP")
        line.set_x2(lineEntry, bar_index)
        line.set_x2(lineSL, bar_index)
        line.set_x2(lineTP, bar_index)
        label.set_x(lblSetup, bar_index + 1)
    if low <= slPrice and (setupStatus == "TRIGGERED (ACTIVE)" or setupStatus == "PENDING")
        setupStatus := "HIT SL"
        label.set_text(lblSetup, "HIT SL")
        line.set_x2(lineEntry, bar_index)
        line.set_x2(lineSL, bar_index)
        line.set_x2(lineTP, bar_index)
        label.set_x(lblSetup, bar_index + 1)

if activeSignal == "SELL"
    if high >= entryPrice and setupStatus == "PENDING"
        setupStatus := "TRIGGERED (ACTIVE)"
        lblTrigger := label.new(bar_index, high, text="⚡ Triggered", color=color.new(color.blue, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
        label.set_text(lblSetup, "ACTIVE SELL")
    if low <= tpPrice and (setupStatus == "TRIGGERED (ACTIVE)" or setupStatus == "PENDING")
        setupStatus := "HIT TP"
        label.set_text(lblSetup, "HIT TP")
        line.set_x2(lineEntry, bar_index)
        line.set_x2(lineSL, bar_index)
        line.set_x2(lineTP, bar_index)
        label.set_x(lblSetup, bar_index + 1)
    if high >= slPrice and (setupStatus == "TRIGGERED (ACTIVE)" or setupStatus == "PENDING")
        setupStatus := "HIT SL"
        label.set_text(lblSetup, "HIT SL")
        line.set_x2(lineEntry, bar_index)
        line.set_x2(lineSL, bar_index)
        line.set_x2(lineTP, bar_index)
        label.set_x(lblSetup, bar_index + 1)

if activeSignal != "NEUTRAL"
    if setupStatus == "PENDING" or setupStatus == "TRIGGERED (ACTIVE)"
        line.set_x2(lineEntry, bar_index + 8)
        line.set_x2(lineSL, bar_index + 8)
        line.set_x2(lineTP, bar_index + 8)
        label.set_x(lblSetup, bar_index + 8) 

// =========================================================================
// DASHBOARD UI (Strictly Identical)
// =========================================================================
var table dash = table.new(position.top_right, 2, 6, border_width=1, border_color=color.gray)

if barstate.islast
    color bgColor = currentBias == "BUY" ? color.new(color.green, 80) : currentBias == "SELL" ? color.new(color.red, 80) : color.new(color.gray, 80)
    color txtColor = currentBias == "BUY" ? color.green : currentBias == "SELL" ? color.red : color.gray
    
    table.cell(dash, 0, 0, "STATUS", text_color=color.white, bgcolor=color.new(color.black, 50))
    table.cell(dash, 1, 0, currentBias, text_color=txtColor, bgcolor=bgColor, text_halign=text.align_center)
    
    table.cell(dash, 0, 1, "PROBABILITY", text_color=color.white, bgcolor=color.new(color.black, 50))
    table.cell(dash, 1, 1, str.tostring(activeProb, "#.##") + "%", text_color=txtColor, bgcolor=bgColor)
    
    table.cell(dash, 0, 2, "REASON", text_color=color.white, bgcolor=color.new(color.black, 50))
    table.cell(dash, 1, 2, reasonText, text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
    
    if activeSignal != "NEUTRAL" and setupStatus != "N/A"
        table.cell(dash, 0, 3, "SETUP STATUS", text_color=color.white, bgcolor=color.new(color.black, 50))
        table.cell(dash, 1, 3, setupStatus, text_color=setupStatus == "HIT TP" ? color.green : setupStatus == "HIT SL" ? color.red : color.yellow, bgcolor=color.new(color.black, 50))
        
        table.cell(dash, 0, 4, "ACTIVE TP", text_color=color.white, bgcolor=color.new(color.black, 50))
        table.cell(dash, 1, 4, str.tostring(tpPrice, "#.#####"), text_color=color.green, bgcolor=color.new(color.black, 50))
        
        table.cell(dash, 0, 5, "ACTIVE SL", text_color=color.white, bgcolor=color.new(color.black, 50))
        table.cell(dash, 1, 5, str.tostring(slPrice, "#.#####"), text_color=color.red, bgcolor=color.new(color.black, 50))
````
