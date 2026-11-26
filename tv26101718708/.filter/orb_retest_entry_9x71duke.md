# ORB Retest Entry

- url: https://www.tradingview.com/script/9X71dUke-ORB-Retest-Entry/
- type: indicator
- pine_id: PUB;9df16000d9bf49c1a1c70a2b12653c6a
- version: 3.0

## Description

ORB Retest Entry with Time-Limited Logic
Advanced Opening Range Breakout Indicator with Smart Risk Management
📊 [b]Overview[/b]
The ORB Retest Entry with Time-Limited Logic is a sophisticated intraday trading tool designed for professional traders who specialize in retest patterns. Unlike traditional ORB indicators, this script incorporates a Time-Limited Validity Window that ensures signals are only generated when market momentum is fresh and actionable.
The indicator automatically detects the Opening Range, waits for a breakout, and then triggers a signal only when price retests the original level within a user-defined time window. This unique approach filters out late entries and improves signal quality by focusing on high-probability retest setups.

✨ [b]Key Features[/b]

Feature	                                                             Description
Dynamic ORB Detection :-	Automatically calculates High & Low of any user-defined timeframe (e.g., first 15 minutes).
Time-Limited Validity :-Signals only valid within specified time window (e.g., before 10:15 AM).
Smart Box Coloring :- Visual feedback system: Blue (Range Building) → Green/Red (Signal Generated).
Half-Range Stop Loss :- SL automatically set to 50% of ORB range $(High - Low) / 2$ for consistent risk.
Intelligent Line Management :-	Entry/SL/TP lines extend in real-time but freeze immediately upon being hit.
Historical Signal Control :-	Toggle how many past signals remain visible to prevent chart clutter.

________________________________________
⚙️ [b]How It Works[/b]
Plaintext
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: RANGE IDENTIFICATION                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Script identifies High & Low of user-defined period │    │
│  │ Box drawn with Teal background during this phase    │    │
│  └─────────────────────────────────────────────────────┘    │
│                          ▼                                  │
│  PHASE 2: BREAKOUT DETECTION                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Price must break above HV or below LV               │    │
│  │ Indicator enters "Waiting for Retest" state         │    │
│  └─────────────────────────────────────────────────────┘    │
│                          ▼                                  │
│  PHASE 3: RETEST CONFIRMATION                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Price returns to touch ORB level                    │    │
│  │ Must occur within Valid Retest Duration window      │    │
│  │ Signal fires with visual label (BUY/SELL)           │    │
│  └─────────────────────────────────────────────────────┘    │
│                          ▼                                  │
│  PHASE 4: RISK MANAGEMENT                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Entry: ORB level ± optional buffer                  │    │
│  │ Stop Loss: Entry ± 50% of ORB range                 │    │
│  │ Take Profit: Based on user-defined Risk-Reward      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
________________________________________
📋 Input Settings Guide

Setting	                    Description	                                  Default	                    Range
ORB Timeframe     |      initial range 	                               | 15 min	      |   Any timeframe
Valid Retest Duration	  |signals stop time (HH:mm)  	       |  10:15	      |  00:00 - 23:59
Show History	         | Toggle historical signal visibility    |     On	      |    Yes/No
History Lines	        | Number of past setups to display   |     10	      |   1 - 100
ORB Buffer %	    |  Buffer HV/LV to avoid false breakouts|   0.01%	      |  0 - 1%
Risk-Reward Ratio | 	TP multiplier relative to risk	        | 1.5              |   0.5 - 10
________________________________________

🚀[b] Practical Use Cases[/b]

📈 Bullish Scenario (Buy Retest)
1.	ORB range established (Green box).
2.	Price breaks above HV → Indicator arms.
3.	Price retests HV from above → BUY signal generated.
4.	Levels drawn: Entry at HV, SL at HV - (50\% \text{ of range}), TP based on RR ratio.
📉 Bearish Scenario (Sell Retest)
1.	ORB range established (Red box).
2.	Price breaks below LV → Indicator arms.
3.	Price retests LV from below → SELL signal generated.
4.	Levels drawn: Entry at LV, SL at [symbol="NEO:LV"]NEO:LV[/symbol] + (50\% \text{ of range})$, TP based on RR ratio.
________________________________________

💡 [b]Pro Tips[/b]
•	Session Timing: Set Valid Duration to 30-120 min after market open to capture early morning momentum before the mid-day "lunch" lull.
•	RR Strategy: Use a 1.5 - 2.0 RR ratio to ensure a positive expectancy even with a 50% win rate.
•	Visual Cleanup: If your chart looks busy, lower the History Lines value to 1 or 2 to only see the most recent trades.
________________________________________

⚠️[b] Important Notes[/b]
•	Clean Records: Lines stop extending once SL or TP is hit, providing a clean historical record for back testing reviews.
•	Time Format: The time window uses chart exchange time (HH:mm format). Ensure your chart time zone matches your local market.
________________________________________

📜 [b]Disclaimer[/b]
FOR EDUCATIONAL AND TECHNICAL ANALYSIS PURPOSES ONLY.
              This indicator is a tool to assist with trading decisions and does not guarantee profits. Trading involves substantial risk of loss. Always conduct your own analysis and practice proper risk management. This indicator is a tool to assist with trading decisions and does not guarantee profits.
•	Past performance does not indicate future results
•	Always conduct your own analysis before entering trades
•	Practice proper risk management (never risk more than 1-2% per trade)
•	Market conditions can change rapidly; adapt your strategy accordingly
Trading involves substantial risk of loss. Trade responsibly.

## Source Code

````pine
//@version=6
indicator("ORB Break-Return-Cross Entry", "ORB_BRC", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- Inputs ---
tf            = input.timeframe("15", "ORB Timeframe",inline="Time")
lastentryTime = input.string("12:15", "Entry Valid Time (HH:mm)",inline="Time")
maxTrades     = input.int(2, "Max Retest Trades", minval = 1,inline="His")
ishist        = input(true, "",inline="His")
hist          = input.int(10, "History Signals Show", minval = 1,inline="His")

rrInput       = input.float(2, "Set Risk-Reward Ratio", step = 0.1,inline="Risk")
bfrRange      = input.float(0.00, "ORB buffer %", step=0.01,inline="Risk") / 100
// --- Global State ---
var float hv = na
var float lv = na
var bool activeRange = true
var int tradeCount = 0
var bool buySignalShown = false
var bool sellSignalShown = false

// --- State Machine for "Break-Return-Cross" ---
var bool hasBrokenOutUpper = false
var bool hasReturnedToUpper = false
var bool hasBrokenOutLower = false
var bool hasReturnedToLower = false

if session.isfirstbar
    tradeCount := 0
    activeRange := true
    buySignalShown := false
    sellSignalShown := false
    hasBrokenOutUpper := false
    hasReturnedToUpper := false
    hasBrokenOutLower := false
    hasReturnedToLower := false

if timeframe.change(tf) and (not session.isfirstbar)
    activeRange := false

var HighArray = array.new<float>()
var LowArray = array.new<float>()

if session.isfirstbar
    HighArray.clear()
    LowArray.clear()

if activeRange
    array.push(HighArray, high)
    array.push(LowArray, low)

startLine = (activeRange[1]) and (not activeRange)
// --- Helper function to convert "HH:mm" to total minutes ---
toMinutes(timeStr) =>
    parts = str.split(timeStr, ":")
    if array.size(parts) == 2
        int(str.tonumber(array.get(parts, 0))) * 60 + int(str.tonumber(array.get(parts, 1)))
    else
        0
// --- Time Check Logic ---
// Convert current bar time to minutes from midnight
currentMinutes = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
// Convert input string to minutes from midnight
lastEntryMinutes = toMinutes(lastentryTime)
// Now you can safely use the comparison operator
bool isWithinEntryTime = currentMinutes <= lastEntryMinutes// --- Types & Orders ---
type LL
    line Line
    label Label
type order
    LL entry
    LL sl
    LL tg
    float slPrice
    float tpPrice
    bool active      
    bool isBuy       

var order orderBuy = na
var order orderSell = na
var orderHistory = array.new<order>()
var signalLabels = array.new<label>()

drawLL(y, clr, txt) =>
    Line = line.new(bar_index, y, bar_index, y, color = clr, width = 2)
    Label = label.new(bar_index, y, text = txt, color = clr, style = label.style_label_left)
    LL.new(Line, Label)

orderList(ev, sv, tv, isBuy) =>
    E = drawLL(ev, color.blue, "Entry : " + str.tostring(ev, format.mintick))
    S = drawLL(sv, color.red, "SL : " + str.tostring(sv, format.mintick))
    T = drawLL(tv, color.green, "TP : " + str.tostring(tv, format.mintick))
    newOrder = order.new(E, S, T, sv, tv, true, isBuy)
    array.push(orderHistory, newOrder)
    newOrder

deleteOrder(_this) =>
    if not na(_this)
        line.delete(_this.entry.Line)
        label.delete(_this.entry.Label)
        line.delete(_this.sl.Line)
        label.delete(_this.sl.Label)
        line.delete(_this.tg.Line)
        label.delete(_this.tg.Label)
// --- ORB Box ---
var box orbBox = na   
if session.isfirstbar
    orbBox := box.new(left=bar_index, top=high, right=bar_index, bottom=low, border_width=1, bgcolor=color.new(color.blue, 90), border_color=color.new(color.blue, 90))

if startLine
    hv := array.max(HighArray) * (1 + bfrRange)
    lv := array.min(LowArray) * (1 - bfrRange)
    if not na(orbBox)
        box.set_top(orbBox, hv)
        box.set_bottom(orbBox, lv)

if not na(orbBox)
    box.set_right(orbBox, bar_index)

// --- Break-Return-Cross Logic ---
if not activeRange and not startLine
    // BUY Sequence: 1. Break HV -> 2. Touch/Dip below HV -> 3. Cross back above HV
    if not hasBrokenOutUpper and high > hv
        hasBrokenOutUpper := true
    
    if hasBrokenOutUpper and not hasReturnedToUpper and low <= hv
        hasReturnedToUpper := true
    
    // SELL Sequence: 1. Break LV -> 2. Touch/Rise above LV -> 3. Cross back below LV
    if not hasBrokenOutLower and low < lv
        hasBrokenOutLower := true
        
    if hasBrokenOutLower and not hasReturnedToLower and high >= lv
        hasReturnedToLower := true

// Entry Conditions: Must be in the "Returned" state and then price crosses the level again
bool buyEntryPending  =  hasReturnedToUpper and high > hv and isWithinEntryTime
bool sellEntryPending =  hasReturnedToLower and low < lv and isWithinEntryTime

float rangeHalf = (hv - lv) / 2

// Execution
if buyEntryPending and not buySignalShown and tradeCount < maxTrades
    entryPrice = hv
    slPrice = entryPrice - rangeHalf
    tpPrice = entryPrice + (rangeHalf * rrInput)
    tradeCount += 1 
    array.push(signalLabels, label.new(bar_index, low, "Buy Retest", style=label.style_label_up, color=color.blue, textcolor=color.white))
    orderBuy := orderList(entryPrice, slPrice, tpPrice, true)
    buySignalShown := true
    // Reset sequence flags
    hasBrokenOutUpper := false 
    hasReturnedToUpper := false

if sellEntryPending and not sellSignalShown and tradeCount < maxTrades
    entryPrice = lv
    slPrice = entryPrice + rangeHalf
    tpPrice = entryPrice - (rangeHalf * rrInput)
    tradeCount += 1
    array.push(signalLabels, label.new(bar_index, high, "Sell Retest", style=label.style_label_down, color=#811212, textcolor=color.white))
    orderSell := orderList(entryPrice, slPrice, tpPrice, false)
    sellSignalShown := true
    // Reset sequence flags
    hasBrokenOutLower := false
    hasReturnedToLower := false
// --- Exit & Reset Logic ---
checkExit(order chk, bool currentShownFlag) =>
    bool updatedFlag = currentShownFlag
    if not na(chk) and chk.active
        line.set_x2(chk.entry.Line, bar_index)
        label.set_x(chk.entry.Label, bar_index)
        line.set_x2(chk.sl.Line, bar_index)
        label.set_x(chk.sl.Label, bar_index)
        line.set_x2(chk.tg.Line, bar_index)
        label.set_x(chk.tg.Label, bar_index)

        if chk.isBuy
            if low <= chk.slPrice 
                chk.active := false
                updatedFlag := false 
                label.set_text(chk.sl.Label, "SL Hit")
                label.set_color(chk.sl.Label, color.maroon)
            else if high >= chk.tpPrice
                chk.active := false
                label.set_text(chk.tg.Label, "TP Hit")
        else 
            if high >= chk.slPrice
                chk.active := false
                updatedFlag := false 
                label.set_text(chk.sl.Label, "SL Hit")
                label.set_color(chk.sl.Label, color.maroon)
            else if low <= chk.tpPrice
                chk.active := false
                label.set_text(chk.tg.Label, "TP Hit")
    updatedFlag

buySignalShown  := checkExit(orderBuy, buySignalShown)
sellSignalShown := checkExit(orderSell, sellSignalShown)
// --- History & Visibility Control (FIXED) ---
if not ishist
    // Clear history arrays only
    if array.size(orderHistory) > 0
        for i = array.size(orderHistory) - 1 to 0
            order item = array.get(orderHistory, i)
            // Check if the current item is the active Buy or Sell order
            bool isCurrentBuy  = not na(orderBuy)  and item.entry.Line == orderBuy.entry.Line
            bool isCurrentSell = not na(orderSell) and item.entry.Line == orderSell.entry.Line
        
            // If it's NOT a current active order, delete it
            if not isCurrentBuy and not isCurrentSell
                deleteOrder(item)
                array.remove(orderHistory, i)
    // Manage signal labels
    if array.size(signalLabels) > 1
        for i = array.size(signalLabels) - 2 to 0
            label.delete(array.remove(signalLabels, i))
else
    if array.size(orderHistory) > hist
        deleteOrder(array.shift(orderHistory))
    if array.size(signalLabels) > hist
        label.delete(array.shift(signalLabels))
````
