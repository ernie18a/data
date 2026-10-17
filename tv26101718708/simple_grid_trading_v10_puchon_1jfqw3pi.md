# Simple Grid Trading v1.0 [PUCHON]

- url: https://www.tradingview.com/script/1JFQW3PI-Simple-Grid-Trading-v1-0-PUCHON/
- type: strategy
- pine_id: PUB;18f88b935d784fb58daf0e5c4148de83
- version: 2.0

## Description

[b]Simple Grid Trading v1.0 [PUCHON][/b]

[b]Overview[/b]

This is a [b]Long-Only Grid Trading Strategy[/b] developed in Pine Script v6 for TradingView. It is designed to profit from market volatility by placing a series of Buy Limit orders at predefined price levels. As the price drops, the strategy accumulates positions. As the price rises, it sells these positions at a profit.

[b]Features[/b]

[list]
[*] [b]Grid Types[/b]: Supports both [b]Arithmetic[/b] (equal price spacing) and [b]Geometric[/b] (equal percentage spacing) grids.
[*] [b]Flexible Order Management[/b]: Uses strategy.order for precise control and prevents duplicate orders at the same level.
[*] [b]Performance Dashboard[/b]: A real-time table displaying key metrics like Capital, Cashflow, and Drawdown.
[*] [b]Advanced Metrics[/b]: Includes [b]Max Drawdown (MaxDD)[/b], [b]Avg Monthly Return[/b], and [b]CAGR[/b] calculations.
[*] [b]Customizable[/b]: Fully adjustable price range, grid lines, and lot size.
[/list]

[b]Dashboard Metrics[/b]

The dashboard (default: Bottom Right) provides a quick snapshot of the strategy's performance:

[list]
[*] [b]Initial Capital[/b]: The starting capital defined in the strategy settings.
[*] [b]Lot Size[/b]: The fixed quantity of assets purchased per grid level.
[*] [b]Avg. Profit per Grid[/b]: The average realized profit for each closed trade.
[*] [b]Cashflow[/b]: The total realized net profit (closed trades only).
[*] [b]MaxDD[/b]: [b]Maximum Drawdown[/b]. The largest percentage drop in equity (realized + unrealized) from a peak.
[*] [b]Avg Monthly Return[/b]: The average percentage return generated per month.
[*] [b]CAGR[/b]: [b]Compound Annual Growth Rate[/b]. The mean annual growth rate of the investment over the specified time period.
[/list]

[b]Strategy Settings (Inputs)[/b]

[b]Grid Settings[/b]

[list]
[*] [b]Upper Price[/b]: The highest price level for the grid.
[*] [b]Lower Price[/b]: The lowest price level for the grid.
[*] [b]Number of Grid Lines[/b]: The total number of levels (lines) in the grid.
[*] [b]Grid Type[/b]:
[list]
[*] Arithmetic: Distance between lines is fixed in price terms (e.g., $10, $20, $30).
[*] Geometric: Distance between lines is fixed in percentage terms (e.g., 1%, 2%, 3%).
[/list]
[*] [b]Lot Size[/b]: The fixed amount of the asset to buy at each level.
[/list]

[b]Dashboard Settings[/b]

[list]
[*] [b]Show Dashboard[/b]: Toggle to hide/show the performance table.
[*] [b]Position[/b]: Choose where the dashboard appears on the chart (e.g., Bottom Right, Top Left).
[/list]

[b]How It Works[/b]

[list=1]
[*] [b]Initialization[/b]: On the first bar, the script calculates the price levels based on your Upper/Lower price and Grid Type.
[*] [b]Entry Logic[/b]:
[list]
[*] The strategy places [b]Buy Limit[/b] orders at every grid level below the current price.
[*] It checks if a position already exists at a specific level to avoid "stacking" multiple orders on the same line.
[/list]
[*] [b]Exit Logic[/b]:
[list]
[*] For every Buy order, a corresponding [b]Sell Limit[/b] (Take Profit) order is placed at the next higher grid level.
[/list]
[*] [b]MaxDD Calculation[/b]:
[list]
[*] The script continuously tracks the highest equity peak.
[*] It calculates the drawdown on every bar (including intra-bar movements) to ensure accuracy.
[*] Displayed as a percentage (e.g., 5.25%).
[/list]
[/list]

[b]Disclaimer[/b]

This script is for educational and backtesting purposes only. Grid trading involves significant risk, especially in strong trending markets where the price may move outside your grid range. Always use proper risk management.

## Source Code

````pine
//@version=6
strategy("Simple Grid Trading v1.0 [PUCHON]", shorttitle = "Simple Grid Trading", overlay=true, pyramiding=100, initial_capital=1000, default_qty_type=strategy.fixed, default_qty_value=1, currency=currency.USD, close_entries_rule="ANY")

// ————————————————————————————————————————————————————————————————
// Version History
// ————————————————————————————————————————————————————————————————
// v1.1.0 - Removed Lot Size Input, using Strategy Default
// v1.0.0 - Initial Release
string version = "1.1.0"

// ————————————————————————————————————————————————————————————————
// Inputs
// ————————————————————————————————————————————————————————————————
grp_grid = "Grid Settings"
upperPrice = input.float(70.0, "Upper Price", group=grp_grid)
lowerPrice = input.float(40.0, "Lower Price", group=grp_grid)
gridLines  = input.int(30, "Number of Grid Lines", minval=2, group=grp_grid)
gridType   = input.string("Arithmetic", "Grid Type", options=["Arithmetic", "Geometric"], group=grp_grid)

// ————————————————————————————————————————————————————————————————
// Functions
// ————————————————————————————————————————————————————————————————

// @function Calculates the Maximum Drawdown percentage based on equity
// @returns {float} The maximum drawdown percentage (0.0 to 1.0)
calcMaxDD() =>
    var float maxEquity = 0.0
    var float maxDdPercent = 0.0
    
    // Update max equity seen so far
    maxEquity := math.max(maxEquity, strategy.equity)
    
    // Calculate current drawdown from the peak
    float currentDd = maxEquity - strategy.equity
    // Calculate drawdown percentage (decimal form, e.g., 0.05 for 5%)
    float currentDdPercent = maxEquity > 0 ? (currentDd / maxEquity) : 0.0
    
    // Update maximum drawdown seen so far
    maxDdPercent := math.max(maxDdPercent, currentDdPercent)
    maxDdPercent

// Calculate MaxDD on every bar (outside isconfirmed) to capture intra-bar or per-bar equity changes
float maxDdPercent = calcMaxDD()

// Initialize array to store grid levels
var float[] gridLevels = array.new_float(gridLines)

if barstate.isfirst
    if gridType == "Arithmetic"
        // Arithmetic Grid: Equal price difference between levels
        float step = (upperPrice - lowerPrice) / (gridLines - 1)
        for i = 0 to gridLines - 1
            array.set(gridLevels, i, lowerPrice + step * i)
    else // Geometric
        // Geometric Grid: Equal percentage difference between levels
        float ratio = math.pow(upperPrice / lowerPrice, 1.0 / (gridLines - 1))
        for i = 0 to gridLines - 1
            array.set(gridLevels, i, lowerPrice * math.pow(ratio, i))

// ————————————————————————————————————————————————————————————————
// Strategy Logic
// ————————————————————————————————————————————————————————————————
// We loop through grid levels to place orders.
// For each level (except the top one), we place a Buy Limit order.
// The Take Profit for that buy order is the next grid level up.

for i = 0 to gridLines - 2
    float buyPrice = array.get(gridLevels, i)
    float sellPrice = array.get(gridLevels, i + 1)
    
    // Unique Order ID for each level
    string orderId = "LE-" + str.tostring(i)
    
    // Check if we already have an open position for this specific grid level
    // This prevents stacking multiple positions at the same level
    bool hasPosition = false
    if strategy.opentrades > 0
        for t = 0 to strategy.opentrades - 1
            if strategy.opentrades.entry_id(t) == orderId
                hasPosition := true
                break
    
    // Only place order if we don't have a position at this level
    if not hasPosition
        // Entry: Buy Limit at current level using strategy.order
        strategy.order(orderId, strategy.long, limit=buyPrice)
    
    // Always ensure exit is set (in case it was cancelled or needs update)
    // strategy.exit works for both pending and active orders linked to orderId
    strategy.exit("LX-" + str.tostring(i), from_entry=orderId, limit=sellPrice)

// ————————————————————————————————————————————————————————————————
// Visualization
// ————————————————————————————————————————————————————————————————
// Plot grid lines for visual confirmation (Only once at the start)
if barstate.isfirst
    for i = 0 to gridLines - 1
        line.new(bar_index, array.get(gridLevels, i), bar_index + 1, array.get(gridLevels, i), extend=extend.both, color=color.new(color.gray, 50))

// ————————————————————————————————————————————————————————————————
// Dashboard
// ————————————————————————————————————————————————————————————————
grp_dash = "Dashboard Settings"
isShow = input.bool(true, "Show Dashboard", group=grp_dash)
posInput = input.string("Bottom Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group=grp_dash)

// Determine table position based on input
var string tablePos = position.top_right
if barstate.isfirst
    if posInput == "Top Left"
        tablePos := position.top_left
    else if posInput == "Bottom Right"
        tablePos := position.bottom_right
    else if posInput == "Bottom Left"
        tablePos := position.bottom_left
    else if posInput == "Middle Right"
        tablePos := position.middle_right
    else if posInput == "Middle Left"
        tablePos := position.middle_left

// Create table
var table dashTable = table.new(tablePos, 2, 8, border_width=1)

// Update dashboard only on confirmed bars and if enabled
if isShow and barstate.isconfirmed
    // Calculate Metrics
    float avgProfit = strategy.closedtrades > 0 ? strategy.netprofit / strategy.closedtrades : 0.0
    float cashflow = strategy.netprofit // Realized profit
    
    // Time Calculations for CAGR and Monthly Return
    float totalDays = (time - strategy.closedtrades.entry_time(0)) / (1000 * 60 * 60 * 24)
    float totalYears = totalDays / 365.0
    float totalMonths = totalDays / 30.44 // Average days in a month
    
    // CAGR Calculation: (End Value / Start Value)^(1/n) - 1
    float endValue = strategy.initial_capital + strategy.netprofit
    float cagr = totalYears > 0 ? math.pow(endValue / strategy.initial_capital, 1.0 / totalYears) - 1 : 0.0
    
    // Avg Monthly Return Calculation
    float avgMonthlyReturn = totalMonths > 0 ? (strategy.netprofit / strategy.initial_capital) / totalMonths : 0.0

    // Header
    table.cell(dashTable, 0, 0, "Topic", bgcolor=color.gray, text_color=color.white)
    table.cell(dashTable, 1, 0, "Value", bgcolor=color.gray, text_color=color.white)
    
    // Rows
    table.cell(dashTable, 0, 1, "Initial Capital", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 1, str.tostring(strategy.initial_capital, "#,###.00"), bgcolor=color.black, text_color=color.white)
    
    table.cell(dashTable, 0, 2, "Avg. Profit per Grid", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 2, str.tostring(avgProfit, "#,###.00"), bgcolor=color.black, text_color=color.white)
    
    table.cell(dashTable, 0, 3, "Cashflow", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 3, str.tostring(cashflow, "#,###.00"), bgcolor=color.black, text_color=color.green)
    
    table.cell(dashTable, 0, 4, "MaxDD", bgcolor=color.black, text_color=color.white)
    // Display MaxDD as percentage using pattern (automatically multiplies by 100 and adds %)
    table.cell(dashTable, 1, 4, str.tostring(maxDdPercent, "0.00%"), bgcolor=color.black, text_color=color.red)

    table.cell(dashTable, 0, 5, "Avg Monthly Return", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 5, str.tostring(avgMonthlyReturn, "0.00%"), bgcolor=color.black, text_color=color.green)

    table.cell(dashTable, 0, 6, "CAGR", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 6, str.tostring(cagr, "0.00%"), bgcolor=color.black, text_color=color.green)

    table.cell(dashTable, 0, 7, "Version", bgcolor=color.black, text_color=color.white)
    table.cell(dashTable, 1, 7, version, bgcolor=color.black, text_color=color.white)
else if not isShow
    table.clear(dashTable, 0, 0, 1, 8)
````
