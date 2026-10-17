# 16. SMC Strategy with SL - low Timeframe

- url: https://www.tradingview.com/script/QSNkX7W1-16-SMC-Strategy-with-SL-low-Timeframe/
- type: strategy
- pine_id: PUB;77c3ff806e754053bfb99806ffe18b4f
- version: 1.0

## Description

Overview
The "SMC Strategy with SL - low Timeframe" is a comprehensive trading strategy that uses key concepts from Smart Money Theory to identify favorable areas in the market for buying or selling. This strategy takes advantage of price imbalances, support and resistance zones, and swing highs/lows to generate high-probability trade signals.

The key features of this strategy include:

Swing High/Low Analysis: Used to determine the Premium, Equilibrium, and Discount Zones.
Order Block Integration: An added layer of confluence to identify valid buy and sell signals.
Trend Direction Confirmation: Using a Simple Moving Average (SMA) to determine the overall trend.
Entry and Exit Rules: Based on price position relative to key zones and moving average, along with optional stop-loss and take-profit levels.
Detailed Description
Swing High and Swing Low Analysis

The script calculates Swing High and Swing Low based on the most recent price highs and lows over a specified look-back period (swingHighLength and swingLowLength, set to 8 by default).
It then derives the Premium, Equilibrium, and Discount Zones:
Premium Zone: Represents potential resistance, calculated based on recent swing highs.
Discount Zone: Represents potential support, calculated based on recent swing lows.
Equilibrium: The midpoint between Swing High and Swing Low, dividing the price range into Premium (above equilibrium) and Discount (below equilibrium) areas.
Zone Visualization

The strategy plots the Premium Zone (resistance) in red, the Discount Zone (support) in green, and the Equilibrium level in blue on the chart. This helps visually assess the current price relative to these important areas.
Simple Moving Average (SMA)

A 50-period Simple Moving Average (SMA) is added to help identify the trend direction.
Buy signals are valid only if the price is above the SMA, indicating an uptrend.
Sell signals are valid only if the price is below the SMA, indicating a downtrend.
Entry Rules

The script generates buy or sell signals when certain conditions are met:
A buy signal is triggered when:
Price is below the Equilibrium and within the Discount Zone.
Price is above the SMA.
The buy signal is further confirmed by the presence of an Order Block (recent lowest price area).
A sell signal is triggered when:
Price is above the Equilibrium and within the Premium Zone.
Price is below the SMA.
The sell signal is further confirmed by the presence of an Order Block (recent highest price area).
Order Block

The strategy defines Order Blocks as recent highs and lows within a look-back period (orderBlockLength set to 20 by default).
These blocks represent areas where large players (smart money) have historically been active, increasing the probability of the price reacting in these areas again.
Trade Management and Trade Direction

The user can set Trade Direction to either "Long Only," "Short Only," or "Both." This allows the strategy to adapt based on market conditions or trading preferences.
Based on the Trade Direction, the strategy either:
Closes open trades that are against new signals.
Allows only specific directional trades (either long or short).
Stop-loss levels are defined based on a fixed percentage (stop_loss_percent), which helps to manage risk and minimize losses.
Exit Rules

The strategy uses stop-loss levels for risk management.
A stop-loss price is set at a fixed percentage below the entry price for long positions or above the entry price for short positions.
When the price hits the defined stop-loss level, the trade is closed.
Liquidity Zones

The script identifies recent Swing Highs and Lows as potential liquidity zones. These are levels where price could react strongly, as they represent areas of interest for large traders.
The liquidity zones are plotted as crosses on the chart, marking areas where price may encounter significant buying or selling pressure.
Visual Feedback

The script uses visual markers (green for buy signals and red for sell signals) to indicate potential entries on the chart.
It also plots liquidity zones to help traders identify areas where stop hunts and liquidity grabs might occur.
Monthly Performance Dashboard

The script includes a performance tracking feature that displays monthly profit and loss metrics on the chart.
This dashboard allows the trader to see a visual representation of trading performance over time, providing insights into profitability and consistency.
The table shows profit or loss for each month and year, allowing the user to track the overall success of the strategy.
Key Benefits
Smart Money Concepts (SMC): This strategy incorporates SMC principles like order blocks and liquidity zones, which are used by institutional traders to determine potential market moves.
Zone Analysis: The use of Premium, Discount, and Equilibrium zones provides a solid framework for determining where to enter and exit trades based on price discounts or premiums.
Confluence: Signals are not taken in isolation. They are confirmed by factors like trend direction (SMA) and order blocks, providing greater trade accuracy.
Risk Management: By integrating stop-loss functionality, traders can manage their risks effectively.
Visual Performance Metrics: The monthly and yearly performance dashboard gives valuable feedback on how well the strategy has performed historically.
Practical Use
Buy in Discount Zone: Traders would be looking to buy when the price is discounted relative to its recent range and is above the SMA, indicating an overall uptrend.
Sell in Premium Zone: Conversely, traders would be looking to sell when the price is at a premium relative to its recent range and below the SMA, indicating an overall downtrend.
Order Block Confirmation: Ensures that buying or selling is supported by historical price behavior at significant levels, providing confidence that the market is likely to react at these areas.
This strategy is designed to help traders take advantage of price inefficiencies and areas where institutional traders are likely to be active, increasing the odds of successful trades. By leveraging Smart Money concepts and strong technical confluence, it aims to provide high-probability trade setups.

## Source Code

````pine
//@version=5
strategy("16. SMC Strategy with SL - low Timeframe", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Input for trade direction
tradeDirection = input.string("Both", title="Trade Direction", options=["Long Only", "Short Only", "Both"])
//take_profit_percent = input.float(5.0, title="Profit Target (%)")
stop_loss_percent = input.float(2.0, title="Stop Loss (%)")

// === Instellingen voor Swing High en Swing Low ===
swingHighLength = input.int(8, title="Swing High Length")
swingLowLength = input.int(8, title="Swing Low Length")

// Vind de recente swing highs en lows
var float swingHigh = na
var float swingLow = na

if (ta.highestbars(high, swingHighLength) == 0)
    swingHigh := high

if (ta.lowestbars(low, swingLowLength) == 0)
    swingLow := low

// Bereken Equilibrium, Premium en Discount Zones
equilibrium = (swingHigh + swingLow) / 2
premiumZone = swingHigh
discountZone = swingLow

// Plot de zones op de grafiek
plot(equilibrium, title="Equilibrium", color=color.blue, linewidth=2)
plot(premiumZone, title="Premium Zone (Resistance)", color=color.red, linewidth=1)
plot(discountZone, title="Discount Zone (Support)", color=color.green, linewidth=1)

// === Simple Moving Average om trendrichting te bepalen ===
smaLength = input.int(50, title="SMA Length")
sma = ta.sma(close, smaLength)
plot(sma, title="SMA", color=color.orange)

// === Entry- en Exitregels op basis van zones en trendrichting ===

// Koop- en verkoopsignalen
buySignal = close < equilibrium and close > discountZone and close > sma // Prijs in discount zone en boven SMA
sellSignal = close > equilibrium and close < premiumZone and close < sma // Prijs in premium zone en onder SMA

// Order Blocks (Eenvoudig: hoogste en laagste kaars binnen de laatste 20 kaarsen)
orderBlockLength = input.int(20, title="Order Block Length")
orderBlockHigh = ta.highest(high, orderBlockLength)
orderBlockLow = ta.lowest(low, orderBlockLength)

// Koop- en verkoopsignalen met order block bevestiging
buySignalOB = buySignal and close >= orderBlockLow // Koop in discount zone met ondersteuning van order block
sellSignalOB = sellSignal and close <= orderBlockHigh // Verkoop in premium zone met weerstand van order block

/// ENTRY CONDITIONS BASED ON TRADE DIRECTION
// Handle Long Only Logic
if tradeDirection == "Long Only"
    if strategy.position_size > 0 and sellSignalOB
        strategy.close("Trade", comment="Close Long") // Close Long when sell signal occurs
    if buySignalOB and strategy.position_size <= 0
        strategy.entry("Trade", strategy.long)

// Handle Short Only Logic
if tradeDirection == "Short Only"
    if strategy.position_size < 0 and buySignalOB
        strategy.close("Trade", comment="Close Short") // Close Short when buy signal occurs
    if sellSignalOB and strategy.position_size >= 0
        strategy.entry("Trade", strategy.short)

// Handle Both Directions Logic
if tradeDirection == "Both"
    if buySignalOB
        if strategy.position_size < 0
            strategy.close("Trade", comment="Close Short for Long Entry") // Close Short before entering Long
        strategy.entry("Trade", strategy.long)
    
    if sellSignalOB
        if strategy.position_size > 0
            strategy.close("Trade", comment="Close Long for Short Entry") // Close Long before entering Short
        strategy.entry("Trade", strategy.short)

// Global variables for take profit and stop loss prices
var float take_profit_price = na
var float stop_loss_price = na

if (strategy.position_size > 0)  // If a long position is open
    //take_profit_price := strategy.position_avg_price * (1 + take_profit_percent / 100)
    stop_loss_price := strategy.position_avg_price * (1 - stop_loss_percent / 100)

if (strategy.position_size < 0)  // If a short position is open
    //take_profit_price := strategy.position_avg_price * (1 - take_profit_percent / 100)
    stop_loss_price := strategy.position_avg_price * (1 + stop_loss_percent / 100)

// Exit strategy: Take profit or stop loss
if (strategy.position_size > 0)  // Exit for long positions
    strategy.exit("SL", from_entry="Trade", stop=stop_loss_price)

if (strategy.position_size < 0)  // Exit for short positions
    strategy.exit("SL", from_entry="Trade", stop=stop_loss_price)

// === Plots voor visuele feedback ===
plotshape(buySignalOB, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignalOB, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === Liquiditeitsjachten aangeven ===
// Simpel: markeer recente swing highs en lows als liquiditeitszones
liquidityZoneHigh = ta.valuewhen(high == swingHigh, high, 0)
liquidityZoneLow = ta.valuewhen(low == swingLow, low, 0)

// Markeer liquiditeitszones
plot(liquidityZoneHigh, title="Liquidity Zone High", color=color.red, linewidth=1, style=plot.style_cross)
plot(liquidityZoneLow, title="Liquidity Zone Low", color=color.green, linewidth=1, style=plot.style_cross)

// Copy below code to end of the desired strategy script
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 monthly pnl performance  by Dr. Maurya @MAURYA_ALGO_TRADER                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
show_performance = input.bool(true, 'Show Monthly Monthly Performance ?', group='Monthly Performance')

dash_loc_mp = input.session("Bottom Right","Location"  ,options=["Top Right","Bottom Right","Top Left","Bottom Left", "Middle Right","Bottom Center"]  ,group='Monthly Performance', inline = "performance")

text_size_mp = input.session('Small',"Size"  ,options=["Tiny","Small","Normal","Large"]  ,group='Monthly Performance', inline = "performance")

bg_c = input.color( color.rgb(7, 226, 242, 38), "Background Color", group='Monthly Performance')

text_head_color = input.color( color.rgb(0,0,0), "Month/Year Heading Color", group='Monthly Performance')

tab_month_c = input.color( color.white, "Month PnL Data Color", group='Monthly Performance')

tab_year_c = input.color( color.rgb(0,0,0), "Year PnL Data Color", group='Monthly Performance')

border_c = input.color( color.white, "Table Border Color", group='Monthly Performance')



var table_position_mp = dash_loc_mp == 'Top Left' ? position.top_left :
  dash_loc_mp == 'Bottom Left' ? position.bottom_left :
  dash_loc_mp == 'Middle Right' ? position.middle_right :
  dash_loc_mp == 'Bottom Center' ? position.bottom_center :
  dash_loc_mp == 'Top Right' ? position.top_right : position.bottom_right
  
var table_text_size_mp = text_size_mp == 'Tiny' ? size.tiny :
  text_size_mp == 'Small' ? size.small :
  text_size_mp == 'Normal' ? size.normal : size.large

/////////////////


/////////////////////////////////////////////

// var bool new_month = na
new_month = ta.change(month) //> 0 ? true : false
newest_month = new_month and strategy.closedtrades >= 1

// profit
only_profit = strategy.netprofit
initial_balance = strategy.initial_capital

// month number
var int month_number = na
month_number := (ta.valuewhen(newest_month, month(time), 0)) //and month(time) > 1 ? (ta.valuewhen(newest_month, month(time), 0) - 1) :  12 //1 to 12

//month_year
var int month_time = na
month_time := ta.valuewhen(newest_month, time, 0) - 2419200000 


var int m_counter = 0
if newest_month
    m_counter += 1



// current month values
var bool new_year = na
new_year := ta.change(year) ? true : false
curr_m_pnl = only_profit - nz(ta.valuewhen(newest_month, only_profit, 0), 0)
curr_m_number = newest_month ? ta.valuewhen(newest_month, month(time), 0) : month(time)
curr_y_pnl = (only_profit - nz(ta.valuewhen(new_year, only_profit, 0),0)) 



var float [] net_profit_array = array.new_float()
var int [] month_array = array.new_int()
var int [] month_time_array = array.new_int()


if newest_month
    array.push(net_profit_array, only_profit)
    array.push(month_array, month_number)
    array.push(month_time_array, month_time)



var float [] y_pnl_array = array.new_float()
var int [] y_number_array = array.new_int()
var int [] y_time_array = array.new_int()

newest_year = new_year and strategy.closedtrades >= 1
get_yearly_pnl = nz(ta.valuewhen(newest_year, strategy.netprofit, 0) - nz(ta.valuewhen(newest_year, strategy.netprofit, 1), 0), 0)
get_m_year = ta.valuewhen(newest_year, year(time), 2)
get_y_time = ta.valuewhen(newest_year, time, 0)

if newest_year
    array.push(y_pnl_array, get_yearly_pnl)
    array.push(y_number_array, get_m_year)
    array.push(y_time_array, get_y_time)
var float monthly_profit = na
var int column_month_number = na
var int row_month_time = na
var int row_y = na

 


var testTable = table.new(position = table_position_mp, columns = 14, rows = 40, bgcolor = bg_c, border_color = border_c, border_width = 1)
if barstate.islastconfirmedhistory and show_performance
    table.cell(table_id = testTable, column = 0, row = 0, text = "YEAR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 1, row = 0, text = "JAN", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 2, row = 0, text = "FEB", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 3, row = 0, text = "MAR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 4, row = 0, text = "APR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 5, row = 0, text = "MAY", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 6, row = 0, text = "JUN", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 7, row = 0, text = "JUL", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 8, row = 0, text = "AUG", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 9, row = 0, text = "SEP", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 10, row = 0, text = "OCT", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 11, row = 0, text = "NOV", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 12, row = 0, text = "DEC", text_color =text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 13, row = 0, text = "YEAR P/L", text_color = text_head_color, text_size=table_text_size_mp)

    for i = 0 to (array.size(y_number_array) == 0 ? na : array.size(y_number_array) - 1)
        row_y := year(array.get(y_time_array, i)) - year(array.get(y_time_array, 0)) + 1
        table.cell(table_id = testTable, column = 13, row = row_y, text = str.tostring(array.get(y_pnl_array , i), "##.##") + '\n' + '(' + str.tostring(array.get(y_pnl_array , i)*100/initial_balance, "##.##") + ' %)', bgcolor = array.get(y_pnl_array , i) > 0 ? color.green : array.get(y_pnl_array , i) < 0 ? color.red : color.gray, text_color = tab_year_c, text_size=table_text_size_mp)
    curr_row_y = array.size(month_time_array) == 0 ? 1 : (year(array.get(month_time_array, array.size(month_time_array) - 1))) - (year(array.get(month_time_array, 0))) + 1
    table.cell(table_id = testTable, column = 13, row = row_y >= 0 ? row_y + 1 : 1, text = str.tostring(curr_y_pnl, "##.##") + '\n' + '(' + str.tostring(curr_y_pnl*100/initial_balance, "##.##") + ' %)', bgcolor = curr_y_pnl > 0 ? color.green : curr_y_pnl < 0 ? color.red : color.gray, text_color = tab_year_c, text_size=table_text_size_mp)
    

    for i = 0 to (array.size(net_profit_array) == 0 ? na : array.size(net_profit_array) - 1)
        monthly_profit := i > 0 ? ( array.get(net_profit_array, i) - array.get(net_profit_array, i - 1) ) : array.get(net_profit_array, i) 
        column_month_number := month(array.get(month_time_array, i)) 
        row_month_time :=((year(array.get(month_time_array, i))) - year(array.get(month_time_array, 0)) ) + 1 
        table.cell(table_id = testTable, column = column_month_number, row = row_month_time, text = str.tostring(monthly_profit, "##.##") + '\n' + '(' + str.tostring(monthly_profit*100/initial_balance, "##.##") + ' %)', bgcolor = monthly_profit > 0 ? color.green : monthly_profit < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
        table.cell(table_id = testTable, column = 0, row =row_month_time, text = str.tostring(year(array.get(month_time_array, i)), "##.##"), text_color = text_head_color, text_size=table_text_size_mp)
       
    // curr_row_m = array.size(month_time_array) == 0 ? 1 : (year(array.get(month_time_array, array.size(month_time_array) - 1))) - (year(array.get(month_time_array, 0))) + 1
    table.cell(table_id = testTable, column = curr_m_number, row = nz(row_month_time) <= 0 ? 1 : row_month_time, text = str.tostring(curr_m_pnl, "##.##") + '\n' + '(' + str.tostring(curr_m_pnl*100/initial_balance, "##.##") + ' %)', bgcolor = curr_m_pnl > 0 ? color.green : curr_m_pnl < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 0, row =nz(row_month_time) <= 0 ? 1 : row_month_time, text = str.tostring(year(time), "##.##"), text_color = text_head_color, text_size=table_text_size_mp)

//============================================================================================================================================================================


// DATA WINDOW
var T_dataWindow = table.new(position.top_right, 2, 13, color.rgb(255, 255, 255, 55), border_width = 1)
if barstate.islast or barstate.islastconfirmedhistory
    table.cell(T_dataWindow, 0, 0, 'Info', text_size = size.auto, text_color = color.white, bgcolor = color.gray, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 1, 'Initial Capital', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 2, 'Equity', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 3, 'Net Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 4, 'Open Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 5, 'Gross Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 6, 'Gross Loss', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 7, 'Open Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 8, 'Closed Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 9, 'Winning Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 10, 'Losing Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 11, 'Break Even Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)


    table.cell(T_dataWindow, 1, 0, 'Value', text_size = size.auto, text_color = color.white, bgcolor = color.gray, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 1, str.tostring(strategy.initial_capital, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 2, str.tostring(strategy.equity, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 3, str.tostring(strategy.netprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 4, str.tostring(strategy.openprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 5, str.tostring(strategy.grossprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 6, str.tostring(strategy.grossloss, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 7, str.tostring(strategy.opentrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 8, str.tostring(strategy.closedtrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 9, str.tostring(strategy.wintrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 10, str.tostring(strategy.losstrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 11, str.tostring(strategy.eventrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
````
