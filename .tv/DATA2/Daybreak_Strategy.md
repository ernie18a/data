<!-- tradingview-pine-id: PUB;69334cf7100d4ea6bc5a587f8b0b578c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daybreak Strategy

Source: https://www.tradingview.com/script/MtKHXU6w-Daybreak-Strategy-Achira-Meegasthanne/

## Description

Daybreak Strategy

Daybreak Strategy is an Opening Range Breakout (ORB) strategy designed to capture potential directional moves based on the high and low of the 9:00 opening candle on the 1-hour timeframe.

The strategy places breakout stop orders above and below the opening range, with the entry distance dynamically adjusted using ATR and the selected Sensitivity.

🔹 KEY FEATURES

⏱️ 1-HOUR TIMEFRAME

The strategy is specifically designed to operate on the 1-hour timeframe.

The opening range is taken from the 9:00 candle, making the 1H timeframe important for the intended ORB calculation.

📊 OPENING RANGE BREAKOUT

The strategy records:

• Opening Range High
• Opening Range Low
• Opening Range Range
• Opening Range Midpoint

These levels are displayed in the on-chart dashboard and used to establish potential breakout entries.

🟢 LONG BREAKOUT

A Long stop order is placed above the Opening Range High.

The entry level is calculated using:

Opening Range High + ATR × Sensitivity

This allows the breakout distance to adapt to current market volatility.

🔴 SHORT BREAKOUT

A Short stop order is placed below the Opening Range Low.

The entry level is calculated using:

Opening Range Low − ATR × Sensitivity

This provides a volatility-adjusted downside breakout level.

⚙️ CUSTOMIZABLE SETTINGS

The strategy provides several user-controlled settings:

• Sensitivity
• Take Profit
• Stop Loss
• Up Color
• Down Color
• Dashboard
• Dashboard Size
• Dashboard Color

The default Sensitivity is 0.5.

🎯 TAKE PROFIT & STOP LOSS

Each Long and Short entry uses predefined Take Profit and Stop Loss values.

Default settings:

• Take Profit = 40 ticks
• Stop Loss = 25 ticks

These values can be adjusted according to the user's preferred testing configuration.

📈 ATR-BASED ENTRY

The strategy uses a 14-period ATR to dynamically calculate the distance between the opening range and the breakout entry level.

This allows the entry distance to respond to changing market volatility.

🌅 DAILY OPENING RANGE

The opening range is reset at the beginning of each new trading day.

The 9:00 candle high and low are captured once per day and used as the day's Opening Range levels.

🔄 ONE-TIME ORDER PLACEMENT

The strategy places the Long and Short breakout orders only once after the Opening Range has been established.

This prevents repeated placement of the same breakout orders during the session.

⏰ END-OF-DAY ORDER CANCELLATION

Untriggered Long and Short stop orders are cancelled during the defined end-of-session period around 21:30–22:00.

This prevents remaining breakout orders from continuing indefinitely after the intended trading session.

📍 VISUAL BREAKOUT LEVELS

The Opening Range High and Opening Range Low are plotted on the chart as step-style levels.

• Buy Stop level = Opening Range High
• Sell Stop level = Opening Range Low

These levels make the daily breakout structure easy to identify visually.

📋 TRADING DASHBOARD

The strategy includes an on-chart dashboard displaying important Opening Range information.

The dashboard can show:

• Current Bias
• Opening Range High
• Opening Range Low
• Opening Range Range
• Opening Range Mid

The dashboard also displays a message when the strategy is not being used on the 1-hour timeframe.

🧭 MARKET BIAS

The strategy determines a directional bias from the 9:00 opening candle.

The dashboard displays either:

Long

or

Short

based on the opening candle's relationship between its Close and Open.

📊 PERFORMANCE STATISTICS

The strategy includes a statistics dashboard containing:

• Total Trades
• Win Rate
• Starting Capital
• Ending Capital
• Average Win
• Average Loss
• Profit Factor
• Max Runup
• Return
• Max Drawdown

These statistics provide a quick overview of the strategy's historical backtest performance.

💰 PROFIT & LOSS ANALYSIS

The performance section uses the strategy's calculated trading results to display:

• Net Profit
• Gross Profit
• Gross Loss
• Winning Trades
• Losing Trades
• Return Percentage
• Profit Factor

This allows users to evaluate the historical performance directly from the chart.

🧠 HOW IT WORKS

1. Detect New Trading Day

The strategy resets the Opening Range variables at the beginning of each new day.

2. Capture the 9:00 Candle

The high and low of the 9:00 candle are recorded as the day's Opening Range High and Opening Range Low.

3. Calculate ATR

A 14-period ATR is used to measure current market volatility.

4. Calculate Breakout Levels

Long and Short stop orders are positioned around the Opening Range using ATR multiplied by Sensitivity.

5. Wait for Breakout

A Long position can be triggered when price reaches the upper breakout level.

A Short position can be triggered when price reaches the lower breakout level.

6. Apply Risk Management

Take Profit and Stop Loss values are applied to the corresponding position.

7. Cancel Remaining Orders

Untriggered breakout orders are cancelled during the defined end-of-day session.

8. Display Performance

The dashboard provides Opening Range information and historical strategy statistics.

📌 CORE CONCEPT

9:00 Opening Range → ATR Adjustment → Breakout Stop Orders → Take Profit / Stop Loss → End-of-Day Management

⚠️ IMPORTANT DISCLAIMER

This strategy is provided for market analysis, backtesting, and educational purposes.

Historical strategy performance does not guarantee future results.

Backtest statistics such as Win Rate, Profit Factor, Return, and Max Drawdown can vary significantly depending on the market, timeframe, trading session, and selected inputs.

Always perform your own analysis, apply proper risk management, and thoroughly test the strategy before using it with real capital.

Capture the opening range. Wait for the breakout. Let volatility define the entry.

---

## Source Code

````pine
//@version=6
strategy('Daybreak Strategy', overlay = true)


// Inputs
Sensitivity = input(0.5, "Sensitivity")
Profit = input(40, "Take Profit (in ticks)")
Loss   = input(25, "Stop Loss (in ticks)")

bullCol= input(color.new(#0df1c6, 20), 'Up Color')
bearCol= input(#871ee9, 'Dn Color')
//-

atr = ta.atr(14)
is1H = timeframe.period == "60"

// Track open range only once per day
var float openRangeHigh = na
var float openRangeLow  = na
var bool  ordersPlaced  = false

// Detect new day and 09:00 bar
newDay     = ta.change(time("D")) != 0

isOpenBar  = (hour(time) == 9)

// Capture 09:00 bar high/low once per day
if newDay
    openRangeHigh := na
    openRangeLow  := na
    ordersPlaced  := false

if isOpenBar and na(openRangeHigh)
    openRangeHigh := high
    openRangeLow  := low

// Place orders only once
if not ordersPlaced and not na(openRangeHigh) and is1H
    strategy.entry("Long", strategy.long, stop = openRangeHigh + atr*Sensitivity, qty = 1)
    strategy.exit("Exit Long", from_entry = "Long", profit = Profit, loss = Loss)

    strategy.entry("Short", strategy.short, stop = openRangeLow - atr*Sensitivity, qty = 1)
    strategy.exit("Exit Short", from_entry = "Short", profit = Profit, loss = Loss)

    ordersPlaced := true

// Cancel untriggered orders at 21:30 (EOD)
inEndSession = not na(time(timeframe.period, "2130-2200:23456")) and is1H
if inEndSession 
    strategy.cancel("Long")
    strategy.cancel("Short")

// Plots for visual reference
plot(is1H?openRangeHigh:na, "Buy Stop", color=bullCol, linewidth=1,style = plot.style_stepline)
plot(is1H?openRangeLow:na, "Sell Stop", color=bearCol, linewidth=1,style = plot.style_stepline)

// Dashboard setup
dashboard           = "DISPLAY"
showDashboard       = input.bool(true, "Dashboard", tooltip = "Changes the size of the dashboard", group = dashboard, display = display.none)
dashboardType       = "Optimal"//input.string("Optimal", "Dashboard Type", ["Optimal","Optimization", "Sensitivity"], tooltip = "Changes dashboard positions", group = dashboard, display = display.none)
dashboardLocation   = "Top Right"//input.string("Top Right", "Dashboard Location", ["Top Right", "Bottom Right", "Bottom Left"], tooltip = "Changes dashboard positions", group = dashboard, display = display.none)
dashboardSize       = input.string("Small", "Dashboard Size", ["Tiny", "Small", "Normal", "Large"], tooltip = "Changes the size of the dashboard", group = dashboard, display = display.none)
dashboardbg         = input.color(#1e222d, "Dashboard Color", tooltip = "Changes the size of the dashboard", group = dashboard, display = display.none)



table_position = dashboardLocation == 'Bottom Left' ? position.bottom_left 
  : dashboardLocation == 'Top Right' ? position.top_right 
  : position.bottom_right

table_size = dashboardSize == 'Tiny' ? size.tiny 
  : dashboardSize == 'Small' ? size.small 
  : size.normal

tb = table.new(table_position, 8, 19
  , bgcolor = dashboardbg
  , border_color = #373a46
  , border_width = 1
  , frame_color = #373a46
  , frame_width = 1)

// Declare performance tracking variables
var balance = strategy.initial_capital
var drawdown = 0.0
var maxDrawdown = 0.0
var maxBalance = 0.0
var totalWins = 0
var totalLoss = 0

// Prepare stats table
var table testTable = table.new(position.bottom_right, 5, 2, border_color = #373a46, border_width=1, frame_color = #373a46,frame_width = 1)
f_fillCell(_table, _column, _row, _title, _value, _bgcolor, _txtcolor) =>
    _cellText = _title + "\n" + _value
    table.cell(_table, _column, _row, _cellText, bgcolor=_bgcolor, text_color=_txtcolor,text_size = table_size)
    
// Custom function to truncate (cut) excess decimal places
truncate(_number, _decimalPlaces) =>
    _factor = math.pow(10, _decimalPlaces)
    int(_number * _factor) / _factor


orbRange = openRangeHigh - openRangeLow
orbMid   = (openRangeHigh + openRangeLow) / 2

// Detect bias (based on opening candle)
orbBull = openRangeHigh > openRangeLow ? close > open : false

// Track last trade direction
var string lastTrade = "None"

if strategy.position_size > 0
    lastTrade := "Long"
if strategy.position_size < 0
    lastTrade := "Short"

if barstate.isnew
    table.cell(tb, 0, 0, not is1H?"Use 1H TF Beacuse ORB Uses 9:00 Candle Range": '    Daybreak  Strategy   ', text_color = color.white, text_size = table_size)
    table.merge_cells(tb, 0, 0, 1, 0)
    if is1H
        // Existing
        tb.cell(0, 2, "Bias", text_color = color.white, text_size = table_size, text_halign = text.align_left)
        //tb.cell(0, 3, "Best Profits", text_color = color.white, text_size = table_size, text_halign = text.align_left)

        tb.cell(1, 2, orbBull?"Long":"Short", text_color = orbBull?bullCol:bearCol,bgcolor = orbBull?color.new(bullCol,70):color.new(bearCol,70), text_size = table_size)
        //tb.cell(1, 3, str.tostring(50), text_color= bullCol, text_size=table_size, bgcolor = color.new(bullCol,70))

        // ===== ORB DATA =====
        tb.cell(0, 5, "High", text_color = color.white, text_size = table_size)
        tb.cell(1, 5, str.tostring(openRangeHigh), text_color = bullCol, text_size = table_size)

        tb.cell(0, 6, "Low", text_color = color.white, text_size = table_size)
        tb.cell(1, 6, str.tostring(openRangeLow), text_color = bearCol, text_size = table_size)

        tb.cell(0, 7, "Range", text_color = color.white, text_size = table_size)
        tb.cell(1, 7, str.tostring(truncate(orbRange, 2)), text_color = color.white, text_size = table_size)

        tb.cell(0, 8, "Mid", text_color = color.white, text_size = table_size)
        tb.cell(1, 8, str.tostring(truncate(orbMid, 2)), text_color = color.white, text_size = table_size)
// Draw stats table
var bgcolor = dashboardbg 
if true and is1H
    if true
        // Update table
        dollarReturn = strategy.netprofit
        f_fillCell(testTable, 0, 0, "Total Trades:", str.tostring(strategy.closedtrades), bgcolor, color.white)
        f_fillCell(testTable, 0, 1, "Win Rate:", str.tostring(truncate((strategy.wintrades/strategy.closedtrades)*100,2)) + "%", bgcolor, color.white)
        f_fillCell(testTable, 1, 0, "Starting:", "$" + str.tostring(strategy.initial_capital), bgcolor, color.white)
        f_fillCell(testTable, 1, 1, "Ending:", "$" + str.tostring(truncate(strategy.initial_capital + strategy.netprofit,2)), bgcolor, color.white)
        f_fillCell(testTable, 2, 0, "Avg Win:", "$"+ str.tostring(truncate(strategy.grossprofit / strategy.wintrades, 2)), bgcolor, color.white)
        f_fillCell(testTable, 2, 1, "Avg Loss:", "$"+ str.tostring(truncate(strategy.grossloss / strategy.losstrades, 2)), bgcolor, color.white)
        f_fillCell(testTable, 3, 0, "Profit Factor:", str.tostring(truncate(strategy.grossprofit / strategy.grossloss,2)), strategy.grossprofit > strategy.grossloss ? bullCol : bearCol, color.white)
        f_fillCell(testTable, 3, 1, "Max Runup:",  str.tostring(truncate(strategy.max_runup, 2 )), bgcolor, color.white)
        f_fillCell(testTable, 4, 0, "Return:", (dollarReturn > 0 ? "+" : "") + str.tostring(truncate((dollarReturn / strategy.initial_capital)*100,2)) + "%", dollarReturn > 0 ? bullCol : bearCol, color.white)
        f_fillCell(testTable, 4, 1, "Max DD:", str.tostring(truncate((strategy.max_drawdown / strategy.equity) * 100 ,2)) + "%", bgcolor, color.white)
// --- END TESTER CODE --- ///////////////
````
