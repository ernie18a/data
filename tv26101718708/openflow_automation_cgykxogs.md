# OPENFLOW AUTOMATION

- url: https://www.tradingview.com/script/CGyKXoGS-OPENFLOW-AUTOMATION/
- type: indicator
- pine_id: PUB;5dc370c025b940e28fc5f9c16d875026
- version: 1.0

## Description

OpenFlow Automation is built to remove emotion and execute the strategy with precision. This system is designed to automatically identify high-probability setups based on the OpenFlow model and trigger entries in real time—so you don’t miss moves or hesitate on execution.

## Source Code

````pine
//@version=6
indicator("OPENFLOW AUTOMATION BY CashFelz", overlay=true, max_labels_count=500)

// ======== INPUTS ========
ticksOffset = input.int(40, "Ticks Offset")

// ======== TIME DETECTION ========
nyTz = "America/New_York"

nyHour = hour(time, nyTz)
nyMinute = minute(time, nyTz)
nySecond = second(time, nyTz)
nyDate = year(time, nyTz) * 10000 + month(time, nyTz) * 100 + dayofmonth(time, nyTz)

// Trigger at 9:29:55 (end of the 9:29:50-9:29:55 5-second candle)
triggerTime = nyHour == 9 and nyMinute == 29 and nySecond == 55

// Day change
isNewDay = ta.change(nyDate) != 0

// ======== STATE VARIABLES ========
var float upperLevel = na
var float lowerLevel = na
var bool levelsCalculated = false

// ======== CALCULATE AT TRIGGER TIME ========
// Use the previous bar (the 9:29:50-9:29:55 5-second candle that just closed)
if triggerTime and not levelsCalculated
    bodyHigh = math.max(open[1], close[1])
    bodyLow = math.min(open[1], close[1])
    tickSize = syminfo.mintick
    upperLevel := bodyHigh + (ticksOffset * tickSize)
    lowerLevel := bodyLow - (ticksOffset * tickSize)
    levelsCalculated := true

// ======== DAILY RESET ========
if isNewDay
    upperLevel := na
    lowerLevel := na
    levelsCalculated := false

// ======== PLOT LEVELS ========
plot(upperLevel, "Upper Level", color=color.green, linewidth=2, style=plot.style_stepline)
plot(lowerLevel, "Lower Level", color=color.red, linewidth=2, style=plot.style_stepline)

// ======== ALERT CONDITIONS ========
// Alert triggers when levels are GENERATED (go from na to having a value)
upperLevelGenerated = not na(upperLevel) and na(upperLevel[1])
lowerLevelGenerated = not na(lowerLevel) and na(lowerLevel[1])

// ======== ALERTCONDITION FOR WEBHOOK (RoboQuant) ========
// Create alert in TradingView -> select condition -> copy webhook message below

// BUY STOP at upper level (place stop order above market)
alertcondition(upperLevelGenerated, title="Buy Stop Generated", message='{"accountId":,"symbol":"NQM6","order_type":"stop","side":"buy","quantity":2,"price":{{plot_0}},"stopLoss":40,"stopLossType":"ticks","takeProfit":48,"takeProfitType":"ticks"}')

// SELL STOP at lower level (place stop order below market)
alertcondition(lowerLevelGenerated, title="Sell Stop Generated", message='{"accountId":,"symbol":"NQM6","order_type":"stop","side":"sell","quantity":2,"price":{{plot_1}},"stopLoss":40,"stopLossType":"ticks","takeProfit":48,"takeProfitType":"ticks"}')

// BOTH orders at once (OCO - One Cancels Other style)
alertcondition(upperLevelGenerated and lowerLevelGenerated, title="Both Levels Generated", message='{"accountId":,"orders":[{"symbol":"NQM6","order_type":"stop","side":"buy","quantity":2,"price":{{plot_0}},"stopLoss":40,"stopLossType":"ticks","takeProfit":48,"takeProfitType":"ticks"},{"symbol":"NQM6","order_type":"stop","side":"sell","quantity":2,"price":{{plot_1}},"stopLoss":40,"stopLossType":"ticks","takeProfit":48,"takeProfitType":"ticks"}]}')

// ======== DISPLAY ========
var table infoTable = na
if barstate.islast
    if na(infoTable)
        infoTable := table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 80), border_width=0)
    
    if not na(upperLevel)
        table.cell(table_id=infoTable, column=0, row=0, text=str.tostring(upperLevel, "#.##"), text_color=color.green, text_size=size.huge)
        table.cell(table_id=infoTable, column=1, row=0, text="", text_color=color.white, text_size=size.huge)
        table.cell(table_id=infoTable, column=0, row=1, text=str.tostring(lowerLevel, "#.##"), text_color=color.red, text_size=size.huge)
        table.cell(table_id=infoTable, column=1, row=1, text="", text_color=color.white, text_size=size.huge)
````
