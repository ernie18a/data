# LS TopinTrade

- url: https://www.tradingview.com/script/n6bCJPyk-LS-TopinTrade/
- type: indicator
- pine_id: PUB;c1ca5fd966684e8f8f2e8264e8c500f0
- version: 1.0

## Description

⚠️ This indicator is exclusively designed for the LS Strategy.

To use this tool effectively, you must first have a solid understanding 
of the LS Strategy concepts and methodology. Simply following the signals 
without proper knowledge of the strategy will not produce reliable results.

📌 What is this indicator?
This indicator is a custom-built tool developed specifically for LS Strategy 
traders. It is not a standalone signal generator — it is a confirmation 
and execution tool for those who are already trained in the LS method.

🎯 Who is this for?
- Traders who have studied and understand the LS Strategy
- Users who know how to read market structure within this system
- Those who use LS rules for entries, exits, and risk management

⚙️ How to use:
The indicator assists in identifying key zones and confirmations 
based on LS Strategy logic. Signals are only valid when interpreted 
within the full context of the strategy.

⚠️ Disclaimer:
This is not financial advice. Past performance does not guarantee 
future results. Always manage your risk properly.

## Source Code

````pine
//@version=6
// /*==============================================================================
//     INDICATOR: LS TopinTrade (Simplified - No Volume Delta)
//     AUTHOR: erfan
//     VERSION: 2.0
//     MODIFICATION: Removed volume delta filter, shows all LS patterns
// ==============================================================================*/
indicator("LS TopinTrade", overlay=true, max_labels_count=500, max_lines_count=500)

// ================= Early Alert Settings =================
enableEarlyAlert = input.bool(true, "Enable Early Alert", group="Alert Settings")
minutesBeforeClose = input.int(2, "Minutes Before Candle Close", minval=0, maxval=60, group="Alert Settings", tooltip="Alert will trigger X minutes before the candle closes if LS pattern is detected")

// ================= Session Filter =================
enableSessionFilter = input.bool(true, "Activate Session Filter", group="Session Settings")

// Session presets
sessionChoice = input.string("Tehran", "Trading Session", options=["Tehran", "New York", "London", "Asia", "Custom"], group="Session Settings")

// Custom session inputs
customSession1 = input.session("0000-0830", "Custom Session 1", group="Session Settings")
customSession2 = input.session("1530-2030", "Custom Session 2", group="Session Settings")

// Define session ranges (UTC times)
var string s1 = na
var string s2 = na

if sessionChoice == "Tehran"
    s1 := "0700-2100"
    s2 := "1530-2030"
else if sessionChoice == "New York"
    s1 := "1330-2000"
    s2 := na
else if sessionChoice == "London"
    s1 := "0700-1630"
    s2 := na
else if sessionChoice == "Asia"
    s1 := "0000-0900"
    s2 := na
else if sessionChoice == "Custom"
    s1 := customSession1
    s2 := customSession2

// Detect active session
inSession1 = not na(s1) and not na(time(timeframe.period, s1))
inSession2 = not na(s2) and not na(time(timeframe.period, s2))
inSession  = inSession1 or inSession2

// ================= Time Until Candle Close =================
timeframeMs = timeframe.in_seconds() * 1000
timeElapsed = (timenow - time)
timeRemaining = timeframeMs - timeElapsed
minutesRemaining = timeRemaining / 60000
inAlertWindow = enableEarlyAlert and minutesRemaining <= minutesBeforeClose and minutesRemaining > 0

// ================= LS Candle Pattern =================
f_lsCondition() =>
    body = math.abs(close - open)
    upperShadow = high - math.max(open, close)
    lowerShadow = math.min(open, close) - low
    longLS  = lowerShadow > 1 * body and lowerShadow > 1 * upperShadow and upperShadow < 7.0 * body
    shortLS = upperShadow > 1 * body and upperShadow > 1 * lowerShadow and lowerShadow < 7.0 * body
    [longLS, shortLS]

[longLS, shortLS] = f_lsCondition()

// Show all LS patterns regardless of color or direction
showLong  = longLS
showShort = shortLS

bgcolor(enableSessionFilter and inSession ? color.new(color.green, 90) : na)

plotshape((not enableSessionFilter or inSession) and showLong,  title="Long LS Pattern",  location=location.belowbar, color=color.green, style=shape.triangleup,   size=size.small)
plotshape((not enableSessionFilter or inSession) and showShort, title="Short LS Pattern", location=location.abovebar,  color=color.red,   style=shape.triangledown, size=size.small)

// ================= Info Table =================
var table infoTable = table.new(position.top_right, 2, 3, border_width=1)

if bar_index % 5 == 0 or barstate.islast
    // In Session
    table.cell(infoTable, 0, 0, "Session", text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, enableSessionFilter ? (inSession ? "✅ Open" : "❌ Closed") : "🔕 Disabled", text_color= enableSessionFilter ? (inSession ? color.lime : color.red) : color.gray, bgcolor=color.black, text_size=size.small)
    
    // Pattern Status
    table.cell(infoTable, 0, 1, "Pattern", text_color=color.white, bgcolor=color.gray, text_size=size.small)
    patternText = showLong ? "🔼 Long" : (showShort ? "🔽 Short" : "➖ None")
    patternColor = showLong ? color.green : (showShort ? color.red : color.gray)
    table.cell(infoTable, 1, 1, patternText, text_color=patternColor, bgcolor=color.black, text_size=size.small)
    
    // Time to Close
    table.cell(infoTable, 0, 2, "Time to Close", text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 2, str.format("{0}m {1}s", math.floor(minutesRemaining), math.floor((minutesRemaining % 1) * 60)), text_color=inAlertWindow ? color.orange : color.white, bgcolor=color.black, text_size=size.small)

// ================= Alerts =================
// Standard alerts (on candle close)
alertcondition(barstate.isconfirmed and (not enableSessionFilter or inSession) and showLong,  title="📈 Long LS Pattern (Confirmed)",  message="📈 Long LS pattern confirmed at candle close")
alertcondition(barstate.isconfirmed and (not enableSessionFilter or inSession) and showShort, title="📉 Short LS Pattern (Confirmed)", message="📉 Short LS pattern confirmed at candle close")
alertcondition(barstate.isconfirmed and (not enableSessionFilter or inSession) and (showLong or showShort), title="📊 Any LS Pattern (Confirmed)", message="📊 LS pattern confirmed (Long or Short)")

// Early warning alerts (X minutes before close)
alertcondition(inAlertWindow and (not enableSessionFilter or inSession) and showLong,  title="⏰ Long LS Pattern (Early Warning)",  message="⏰ Potential Long LS pattern detected - Check chart!")
alertcondition(inAlertWindow and (not enableSessionFilter or inSession) and showShort, title="⏰ Short LS Pattern (Early Warning)", message="⏰ Potential Short LS pattern detected - Check chart!")
alertcondition(inAlertWindow and (not enableSessionFilter or inSession) and (showLong or showShort), title="⏰ Any LS Pattern (Early Warning)", message="⏰ Potential LS pattern detected - Check chart!")
````
