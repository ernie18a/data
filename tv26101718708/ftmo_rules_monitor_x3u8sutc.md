# FTMO Rules Monitor

- url: https://www.tradingview.com/script/X3U8sUTC-FTMO-Rules-Monitor/
- type: strategy
- pine_id: PUB;3b75acbcd93a477ebd65a02512b07db7
- version: 1.0

## Description

FTMO Rules Monitor: Stay on Track with Your FTMO Challenge Goals

[i]TLDR;[/i] You can test with this template whether your strategy for one asset would pass the FTMO challenges step 1 then step 2, then with real money conditions.

Passing a prop firm challenge is ... challenging.
I believe a toolkit allowing to test in minutes whether a strategy would have passed a prop firm challenge in the past could be very powerful.

The FTMO Rules Monitor is designed to help you stay within FTMO’s strict risk management guidelines directly on your chart. Whether you’re aiming for the $10,000 or the $200,000 account challenge, this tool provides real-time tracking of your performance against FTMO’s rules to ensure you don’t accidentally breach any limits.

[b]NOTES[/b]

The connected indicator for this post doesn't matter.
It's just a dummy double supertrends (see below)

The strategy results for this script post does not matter as I'm posting a FTMO rules template on which you can connect any indicator/strategy.

[pine]
//@version=5
indicator("Supertrends", overlay=true)

// Supertrend 1 Parameters
var string ST1 = "Supertrend 1 Settings"
st1_atrPeriod = input.int(10, "ATR Period", minval=1, maxval=50, group=ST1)
st1_factor = input.float(2, "Factor", minval=0.5, maxval=10, step=0.5, group=ST1)

// Supertrend 2 Parameters
var string ST2 = "Supertrend 2 Settings"
st2_atrPeriod = input.int(14, "ATR Period", minval=1, maxval=50, group=ST2)
st2_factor = input.float(3, "Factor", minval=0.5, maxval=10, step=0.5, group=ST2)

// Calculate Supertrends
[supertrend1, direction1] = ta.supertrend(st1_factor, st1_atrPeriod)
[supertrend2, direction2] = ta.supertrend(st2_factor, st2_atrPeriod)

// Entry conditions
longCondition = direction1 == -1 and direction2 == -1 and direction1[1] == 1
shortCondition = direction1 == 1 and direction2 == 1 and direction1[1] == -1

// Optional: Plot Supertrends
plot(supertrend1, "Supertrend 1", color = direction1 == -1 ? color.green : color.red, linewidth=3)
plot(supertrend2, "Supertrend 2", color = direction2 == -1 ? color.lime : color.maroon, linewidth=3)

plotshape(series=longCondition, location=location.belowbar, color=color.green, style=shape.triangleup, title="Long")
plotshape(series=shortCondition, location=location.abovebar, color=color.red, style=shape.triangledown, title="Short")

signal = longCondition ? 1 : shortCondition ? -1 : na
plot(signal, "Signal", display = display.data_window)
[/pine]

To connect your indicator to this FTMO rules monitor template, please update it as follow

[list=1]
[*] Create a signal variable to store 1 for the long/buy signal or -1 for the short/sell signal
[*] Plot it in the display.data_window panel so that it doesn't clutter your chart
[/list]

[pine]
signal = longCondition ? 1 : shortCondition ? -1 : na
plot(signal, "Signal", display = display.data_window)
[/pine]

In the FTMO Rules Monitor template, I'm capturing this external signal with this [b]input.source [/b] variable

[pine]
entry_connector = input.source(close, "Entry Connector", group="Entry Connector")
longCondition  = entry_connector == 1
shortCondition = entry_connector == -1
[/pine]

[b]🔶 USAGE[/b]

This indicator displays essential FTMO Challenge rules and tracks your progress toward meeting each one. Here’s what’s monitored:

Max Daily Loss
• 10k Account: $500
• 25k Account: $1,250
• 50k Account: $2,500
• 100k Account: $5,000
• 200k Account: $10,000

Max Total Loss
• 10k Account: $1,000
• 25k Account: $2,500
• 50k Account: $5,000
• 100k Account: $10,000
• 200k Account: $20,000

Profit Target
• 10k Account: $1,000
• 25k Account: $2,500
• 50k Account: $5,000
• 100k Account: $10,000
• 200k Account: $20,000

Minimum Trading Days: 4 consecutive days for all account sizes

[b]🔹 Key Features[/b]

1. Real-Time Compliance Check
The FTMO Rules Monitor keeps track of your daily and total losses, profit targets, and trading days. Each metric updates in real-time, giving you peace of mind that you’re within FTMO’s rules.

2. Color-Coded Visual Feedback
Each rule’s status is shown clearly with a ✓ for compliance or ✗ if the limit is breached. When a rule is broken, the indicator highlights it in red, so there’s no confusion.

3. Completion Notification
Once all FTMO requirements are met, the indicator closes all open positions and displays a celebratory message on your chart, letting you know you’ve successfully completed the challenge.

4. Easy-to-Read Table
A table on your chart provides an overview of each rule, your target, current performance, and whether you’re meeting each goal. The table adjusts its color scheme based on your chart settings for optimal visibility.

5. Dynamic Position Sizing
Integrated ATR-based position sizing helps you manage risk and avoid large drawdowns, ensuring each trade aligns with FTMO’s risk management principles.

Daveatt

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Daveatt

//@version=5
strategy("FTMO Rules Monitor", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=1, calc_on_every_tick=true, process_orders_on_close=true)

// Entry Connector
entry_connector = input.source(close, "Entry Connector", group="Entry Connector")

// Account Settings
var string G1 = "FTMO Account Settings"
accountSize = input.float(10000, "Account Size ($)", group=G1, options=[10000, 25000, 50000, 100000, 200000], tooltip = "Set the account size in the Properties tab with the same value")
isChallengePhase = input.bool(true, "Is Challenge Phase?", group=G1)

// Define account-specific parameters
getMaxDailyLoss(size) =>
    switch size
        10000  => -500
        25000  => -1250
        50000  => -2500
        100000 => -5000
        => -10000  // 200000

getMaxTotalLoss(size) =>
    switch size
        10000  => -1000
        25000  => -2500
        50000  => -5000
        100000 => -10000
        => -20000  // 200000

getProfitTarget(size) =>
    switch size
        10000  => 1000
        25000  => 2500
        50000  => 5000
        100000 => 10000
        => 20000  // 200000

// Strategy Parameters
var string G2 = "Strategy Parameters"
riskPercent = input.float(1.0, "Risk Percent", minval=0.1, maxval=10.0, step=0.1, group=G2, tooltip = "Set the risk percent in the Properties tab with the same value")*0.01
atrPeriod = input.int(14, "ATR Period", group=G2, tooltip = "Set the ATR period in the Properties tab with the same value")
atrMultiplier = input.float(2.0, "ATR Multiplier", minval=0.5, maxval=5.0, step=0.1, group=G2, tooltip = "Set the ATR multiplier in the Properties tab with the same value")


// Entry conditions
longCondition  = entry_connector == 1
shortCondition = entry_connector == -1

// Position sizing based on ATR
atr = ta.atr(atrPeriod)
stopLoss = atrMultiplier * atr
positionSize = riskPercent// * strategy.equity 

// Execute trades
if longCondition
    strategy.entry("Long", strategy.long, qty=positionSize)
    strategy.exit("Long Exit", "Long", stop=close - stopLoss, limit=close + stopLoss*2)

if shortCondition
    strategy.entry("Short", strategy.short, qty=positionSize)
    strategy.exit("Short Exit", "Short", stop=close + stopLoss, limit=close - stopLoss*2)

// FTMO Rules Tracking
var float maxDailyLoss = getMaxDailyLoss(accountSize)
var float maxLoss = getMaxTotalLoss(accountSize)
var float profitTarget = getProfitTarget(accountSize)
var int minTradingDays = 4

// Track daily and total performance
var float previousDayEquity = strategy.equity
var int tradingDays = 0
var int consecutiveTradingDays = 0
var int maxConsecutiveDays = 0
var float dailyPnL = 0.0
var float maxDailyDrawdown = 0.0
var float maxDrawdown = 0.0
var int lastTradeDay = 0  // Store the last day we counted

// Reset tracking on new day if no trades were made
if ta.change(dayofmonth)
    if dayofmonth != lastTradeDay + 1 and lastTradeDay > 0
        tradingDays := 0
        consecutiveTradingDays := 0
    previousDayEquity := strategy.equity
    dailyPnL := 0.0

// Update tracking variables when new trades are opened
if strategy.opentrades != strategy.opentrades[1] and dayofmonth != lastTradeDay
    tradingDays := tradingDays + 1
    
    // Update consecutive days
    if dayofmonth == lastTradeDay + 1 or lastTradeDay == 0
        consecutiveTradingDays := consecutiveTradingDays + 1
    else
        consecutiveTradingDays := 1
    
    // Update max consecutive days if needed
    if consecutiveTradingDays > maxConsecutiveDays
        maxConsecutiveDays := consecutiveTradingDays
    
    lastTradeDay := dayofmonth

// Calculate current daily PnL
dailyPnL := strategy.netprofit - strategy.netprofit[1]
if dailyPnL < maxDailyDrawdown
    maxDailyDrawdown := dailyPnL

// Track peak equity
var float peakEquity = strategy.equity
if strategy.equity > peakEquity
    peakEquity := strategy.equity

// Calculate drawdown from peak
curDrawdown = strategy.equity - peakEquity
if curDrawdown < maxDrawdown
    maxDrawdown := curDrawdown

// Rules Status
bool isDailyLossOK = maxDailyDrawdown > maxDailyLoss
bool isTotalLossOK = maxDrawdown > maxLoss
bool isProfitTargetMet = strategy.netprofit >= profitTarget
bool isMinTradingDaysMet = tradingDays >= minTradingDays

// Close all positions when challenge is completed
if isProfitTargetMet and isMinTradingDaysMet and isDailyLossOK and isTotalLossOK
    strategy.close_all("Challenge Complete")

    alert("🏆 FTMO Challenge Complete!", alert.freq_once_per_bar_close)
    
    if barstate.islast
        label.new(bar_index, high, "🏆 FTMO Challenge Complete!", 
         color=color.green, 
         style=label.style_label_down, 
         textcolor=color.white,
         size=size.large)

// Color scheme settings
var string G3 = "Visual Settings"
colorScheme = input.string("Auto", "Color Scheme", options=["Auto", "Dark", "Light"], group=G3)

// Dynamic color function
getColorScheme() =>
    bgColor = chart.bg_color
    auto_isDark = (color.r(bgColor) + color.g(bgColor) + color.b(bgColor))/3 < 128
    
    isDarkMode = switch colorScheme
        "Auto"  => auto_isDark
        "Dark"  => true
        "Light" => false
    
    [isDarkMode ? color.white : color.black, isDarkMode ? color.rgb(66, 66, 66, 50) : color.rgb(240, 240, 240, 50), isDarkMode ? color.rgb(66, 66, 66) : color.rgb(220, 220, 220)]

[textColor, tableBgColor, headerBgColor] = getColorScheme()

// Create status table
var table statusTable = table.new(position.top_right, 4, 6, bgcolor=tableBgColor)

var string PASSED = "✓"
var string FAILED = "✗"

if barstate.islast
    // Header spanning all columns
    table.cell(statusTable, 0, 0, "FTMO Rules Monitor", bgcolor=headerBgColor, text_color=textColor, text_size=size.normal)
    table.merge_cells(statusTable, 0, 0, 3, 0)
    
    // Column headers
    table.cell(statusTable, 0, 1, "Rule", bgcolor=headerBgColor, text_color=textColor)
    table.cell(statusTable, 1, 1, "Target", bgcolor=headerBgColor, text_color=textColor)
    table.cell(statusTable, 2, 1, "Current", bgcolor=headerBgColor, text_color=textColor)
    table.cell(statusTable, 3, 1, "Status", bgcolor=headerBgColor, text_color=textColor)
    
    // Daily Loss Rule
    table.cell(statusTable, 0, 2, "Max Daily Loss", text_color=textColor)
    table.cell(statusTable, 1, 2, str.tostring(maxDailyLoss), text_color=textColor)
    table.cell(statusTable, 2, 2, str.tostring(maxDailyDrawdown, "#"), text_color=textColor)
    table.cell(statusTable, 3, 2, isDailyLossOK ? PASSED : FAILED, text_color=isDailyLossOK ? color.green : color.red, text_size=size.large)
    
    // Total Loss Rule
    table.cell(statusTable, 0, 3, "Max Total Loss", text_color=textColor)
    table.cell(statusTable, 1, 3, str.tostring(maxLoss), text_color=textColor)
    table.cell(statusTable, 2, 3, str.tostring(maxDrawdown, "#"), text_color=textColor)
    table.cell(statusTable, 3, 3, isTotalLossOK ? PASSED : FAILED, text_color=isTotalLossOK ? color.green : color.red, text_size=size.large)
    
    // Profit Target
    table.cell(statusTable, 0, 4, "Profit Target", text_color=textColor)
    table.cell(statusTable, 1, 4, str.tostring(profitTarget, "#"), text_color=textColor)
    table.cell(statusTable, 2, 4, str.tostring(strategy.netprofit, "#"), text_color=textColor)
    table.cell(statusTable, 3, 4, isProfitTargetMet ? PASSED : FAILED, text_color=isProfitTargetMet ? color.green : color.red, text_size=size.large)
    
    // Minimum Trading Days
    table.cell(statusTable, 0, 5, "Min Trading Days", text_color=textColor)
    table.cell(statusTable, 1, 5, str.tostring(minTradingDays), text_color=textColor)
    table.cell(statusTable, 2, 5, str.tostring(tradingDays, "#"), text_color=textColor)
    table.cell(statusTable, 3, 5, isMinTradingDaysMet ? PASSED : FAILED, text_color=isMinTradingDaysMet ? color.green : color.red, text_size=size.large)

// Add warning label for failed conditions
if barstate.islast and (not isDailyLossOK or not isTotalLossOK)
    label.new(bar_index, high, "⚠️ Risk Limits Exceeded", color=color.new(color.red, 0), style=label.style_label_down, textcolor=color.white)
````
