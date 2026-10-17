# Hulk Grid Algorithm V2 - The Quant Science

- url: https://www.tradingview.com/script/JDeL8FAl-Hulk-Grid-Algorithm-V2-The-Quant-Science/
- type: strategy
- pine_id: PUB;a7a4a36eb3bb44f5b0f9e9e118576b69
- version: 2.0

## Description

It's the latest proprietary grid algorithm developed by our team. This software represents a clearer and more comprehensive modernization of the deprecated Hulk Grid Algorithm. In this new release, we have optimized the source code architecture and investment logic, which we will describe in detail below.

[b]Overview[/b] 
[i]Hulk Grid Algorithm V2[/i] is designed to optimize returns in sideways market conditions. In this scenario, the algorithm divides purchases with long orders at each level of the grid. Unlike a typical grid algorithm, this version applies an anti-martingale model to mitigate volatility and optimize the average entry price. Starting from the lower level, the purchase quantity is increased at each new subsequent level until reaching the upper level. The initial quantity of the first order is fixed at 0.50% of the initial capital. With each new order, the initial quantity is multiplied by a value equal to the current grid level (where 1 is the lower level and 10 is the upper level).

[b][i]Example: Let's say we have an initial capital of $10,000. The initial capital for the first order would be $50 * 1 = $50, for the second order $50 * 2 = $100, for the third order $50 * 3 = $150, and so on until reaching the upper level.[/i][/b]

[url=https://www.tradingview.com/x/FkAeMltn/]https://www.tradingview.com/x/FkAeMltn/[/url]

All previously opened orders are closed using a percentage-based stop-loss and take-profit, calculated based on the extremes of the grid.

[url=https://www.tradingview.com/x/vqcNobPy/]https://www.tradingview.com/x/vqcNobPy/[/url]

[b]Set Up[/b]
As mentioned earlier, the user's goal is to analyze this strategy in markets with a lack of trend, also known as sideways markets. After identifying a price range within which the asset tends to move, the user can choose to create the grid by placing the starting price at the center of the range. This way, they can consider trading the asset, if the backtesting generates a return greater than the Buy & Hold return.

[b]Grid Configuration[/b]
To create the grid, it's sufficient to choose the starting price during the launch phase. This level will be the center of the grid from which the upper and lower levels will be calculated. The grid levels are computed using an arithmetic method, adding and subtracting a configurable fixed amount from the user interface (Grid Step $).

[b][i]Example: Let's imagine choosing 1000 as the starting price and 50 as the Grid Step ($). The upper levels will be 1000, 1050, 1100, 1150, 1200. The lower levels will be 950, 900, 850, 800, and 750.[/i][/b]

[url=https://www.tradingview.com/x/UCBFs0uy/]https://www.tradingview.com/x/UCBFs0uy/[/url]
[url=https://www.tradingview.com/x/ZAkNhENw/]https://www.tradingview.com/x/ZAkNhENw/[/url]

[b]Markets[/b] 
This software can be used in all markets: stocks, indices, commodities, cryptocurrencies, ETFs, Forex, etc.

[b]Application[/b]
With this backtesting software, is possible to analyze the strategy and search for markets where it can generate better performance than Buy & Hold returns. There are no alerts or automatic investment mechanisms, and currently, the strategy can only be executed manually.

[b]Design[/b]
Is possible to modify the grid style and customize colors by accessing the [b]Properties[/b] section of the user interface.

## Source Code

````pine
//@version=6
strategy(
     title = 'Hulk Grid Algorithm V2 [The Quant Science]', 
     overlay = true,
     initial_capital = 10000, 
     commission_type = strategy.commission.percent, 
     commission_value = 0.70, 
     pyramiding = 10,
     close_entries_rule = 'ANY',
     slippage = 5
     )

center_price = input.price(defval = 100.0, title = "Center Price - Start Grid [$]", group = "GRID SETTINGS", confirm = true)
step_percent = input.float(defval = 0.6, title = "Grid Step Level [%]", step = 0.1, group = "GRID SETTINGS") / 100
base_order_usd = input.float(defval = 100.0, title = "Start Order Price [$]", minval = 10, group = "POSITION SIZING")
decay_percent = input.float(defval = 20.0, title = "Size Order Decay [%]", step = 0.1, group = "POSITION SIZING") / 100
grid_destroyer = input.bool(defval = false, title = 'Grid Stop Loss', group = "STOP LOSS CONFIGURATION", inline = "SL")
stop_level = input.price(defval = 0.00, title = '', group = "STOP LOSS CONFIGURATION", inline = "SL")

grid_1  = center_price * (1 - step_percent * 5)
grid_2  = center_price * (1 - step_percent * 4)
grid_3  = center_price * (1 - step_percent * 3)
grid_4  = center_price * (1 - step_percent * 2)
grid_5  = center_price * (1 - step_percent * 1)
grid_6  = center_price  
grid_7  = center_price * (1 + step_percent * 1)
grid_8  = center_price * (1 + step_percent * 2)
grid_9  = center_price * (1 + step_percent * 3)
grid_10 = center_price * (1 + step_percent * 4)

take_profit_target = grid_10 * 1.05

get_qty(float lvl_price, int grid_index) =>
    float usd_amount = base_order_usd * math.pow(1.0 - decay_percent, grid_index)
    float qty = (not na(lvl_price) and lvl_price > 0) ? (usd_amount / lvl_price) : 0.0
    qty

var bool f1 = false, var bool f2 = false, var bool f3 = false, var bool f4 = false, var bool f5 = false
var bool f6 = false, var bool f7 = false, var bool f8 = false, var bool f9 = false, var bool f10 = false

if strategy.position_size == 0 and strategy.position_size[1] != 0
    f1 := false, f2 := false, f3 := false, f4 := false, f5 := false
    f6 := false, f7 := false, f8 := false, f9 := false, f10 := false

if not f1
    strategy.entry("🧪GRID#1", strategy.long, qty = get_qty(grid_1, 0), limit = close > grid_1 ? grid_1 : na, stop = close < grid_1 ? grid_1 : na)
    f1 := true

if not f2
    strategy.entry("🧪GRID#2", strategy.long, qty = get_qty(grid_2, 1), limit = close > grid_2 ? grid_2 : na, stop = close < grid_2 ? grid_2 : na)
    f2 := true

if not f3
    strategy.entry("🧪GRID#3", strategy.long, qty = get_qty(grid_3, 2), limit = close > grid_3 ? grid_3 : na, stop = close < grid_3 ? grid_3 : na)
    f3 := true

if not f4
    strategy.entry("🧪GRID#4", strategy.long, qty = get_qty(grid_4, 3), limit = close > grid_4 ? grid_4 : na, stop = close < grid_4 ? grid_4 : na)
    f4 := true

if not f5
    strategy.entry("🧪GRID#5", strategy.long, qty = get_qty(grid_5, 4), limit = close > grid_5 ? grid_5 : na, stop = close < grid_5 ? grid_5 : na)
    f5 := true

if not f6
    strategy.entry("🧪GRID#6", strategy.long, qty = get_qty(grid_6, 5), limit = close > grid_6 ? grid_6 : na, stop = close < grid_6 ? grid_6 : na)
    f6 := true

if not f7
    strategy.entry("🧪GRID#7", strategy.long, qty = get_qty(grid_7, 6), limit = close > grid_7 ? grid_7 : na, stop = close < grid_7 ? grid_7 : na)
    f7 := true

if not f8
    strategy.entry("🧪GRID#8", strategy.long, qty = get_qty(grid_8, 7), limit = close > grid_8 ? grid_8 : na, stop = close < grid_8 ? grid_8 : na)
    f8 := true

if not f9
    strategy.entry("🧪GRID#9", strategy.long, qty = get_qty(grid_9, 8), limit = close > grid_9 ? grid_9 : na, stop = close < grid_9 ? grid_9 : na)
    f9 := true

if not f10
    strategy.entry("🧪GRID#10", strategy.long, qty = get_qty(grid_10, 9), limit = close > grid_10 ? grid_10 : na, stop = close < grid_10 ? grid_10 : na)
    f10 := true

bool stop_crossed = ta.crossunder(close, stop_level)

if close >= take_profit_target
    strategy.close_all(comment = "💎💎💎 +5%")
    f1 := false, f2 := false, f3 := false, f4 := false, f5 := false
    f6 := false, f7 := false, f8 := false, f9 := false, f10 := false

if grid_destroyer and stop_crossed
    strategy.close_all(comment = "☄️ Grid Destroyed")
    f1 := false, f2 := false, f3 := false, f4 := false, f5 := false
    f6 := false, f7 := false, f8 := false, f9 := false, f10 := false

p10 = plot(grid_10, "Grid Top (L10)", color = color.new(#03FF00, 30), linewidth = 2)
p9  = plot(grid_9, "Grid Line 9", color = color.new(#03FF00, 70), linewidth = 1)
p8  = plot(grid_8, "Grid Line 8", color = color.new(#03FF00, 75), linewidth = 1)
p7  = plot(grid_7, "Grid Line 7", color = color.new(#03FF00, 80), linewidth = 1)
p6  = plot(grid_6, "Grid Center (L6)", color = color.new(#03FF00, 10),linewidth = 2)
p5  = plot(grid_5, "Grid Line 5", color = color.new(#03FF00, 80), linewidth = 1)
p4  = plot(grid_4, "Grid Line 4", color = color.new(#03FF00, 75), linewidth = 1)
p3  = plot(grid_3, "Grid Line 3", color = color.new(#03FF00, 70), linewidth = 1)
p2  = plot(grid_2, "Grid Line 2", color = color.new(#03FF00, 65), linewidth = 1)
p1  = plot(grid_1, "Grid Bottom (L1)", color = color.new(#03FF00, 30), linewidth = 2)

fill(p10, p9, color = color.new(#03FF00, 92), title = "Zone 9-10")
fill(p9, p8, color = color.new(#03FF00, 94), title = "Zone 8-9")
fill(p8, p7, color = color.new(#03FF00, 95), title = "Zone 7-8")
fill(p7, p6, color = color.new(#03FF00, 97), title = "Zone 6-7")
fill(p6, p5, color = color.new(#03FF00, 97), title = "Zone 5-6")
fill(p5, p4, color = color.new(#03FF00, 95), title = "Zone 4-5")
fill(p4, p3, color = color.new(#03FF00, 94), title = "Zone 3-4")
fill(p3, p2, color = color.new(#03FF00, 93), title = "Zone 2-3")
fill(p2, p1, color = color.new(#03FF00, 92), title = "Zone 1-2")

plot(take_profit_target, "Take Profit", color = #03FF00 , linewidth = 3, style = plot.style_linebr)
plot(grid_destroyer ? stop_level : na, "Stop Loss", color = #FF3B30, linewidth = 2, style = plot.style_linebr)
````
