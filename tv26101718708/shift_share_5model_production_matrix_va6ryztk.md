# Shift Share - 5-Model Production Matrix

- url: https://www.tradingview.com/script/va6ryZTk-Shift-Share-5-Model-Production-Matrix/
- type: indicator
- pine_id: PUB;d60c9b547f8d48058260a067cba61a8b
- version: 1.0

## Description

The 5-Model Stock Breakdown: A Beginner Guide
Imagine you are looking at a single stock—let us call it SuperEco Corp—and its price just jumped up by 10 percent over the last few weeks.

If you ask a regular person why it went up, they might say, "Because it is a good stock!" But a seasoned investor knows that a stock price does not move in a vacuum. It is being pulled and pushed by different invisible forces.

This guide explains how our tracking tool uses a method called Regression to break down that 10 percent jump and reveal exactly who was responsible for the move. You do not need a background in math, economics, or statistics to understand how it works.

1. The Three Invisible Forces
Our model assumes that a stock price movement depends on three major factors:

The Market (The Rising Tide): This is the entire stock market (like the S&P 500). When the overall economy is booming, optimism runs high, and almost every stock gets lifted. If the market goes up sharply, our stock will likely get dragged up with it, purely by association.

The Sector (The Industry Wave): This is the specific neighborhood the stock lives in (such as Technology, Energy, or Healthcare). If electric vehicles are suddenly booming, all EV stocks will rise together, even the poorly managed ones, because money is pouring into that specific industry bucket.

The Stock Itself (Its Unique Engine): This is the company own secret sauce. It includes their unique products, their management team, their earnings reports, and their breakthroughs. This is what belongs only to this stock and no one else.

What is Regression?
Think of a stock total return like a baked cake. You know the cake tastes sweet (the stock went up 10 percent), but you do not know how many cups of sugar, flour, or butter went into it.

Regression is a tool that acts like a laboratory test for that cake. It analyzes the final product, compares it to how the broader market and sector were moving at the same time, and extracts the exact recipe. It tells you: "Of this 10 percent move, 5 percent was caused by the market, 3 percent was caused by the sector, and 2 percent was the stock unique engine."

2. Leftover Mystery: The Statistical Error
No matter how smart a math model is, it can never perfectly predict human behavior or random events. When we add up what the Market and the Sector should have done to the stock, it rarely perfectly matches the actual final price.

The piece that is left over is called the Statistical Error (or Noise Floor).

Think of it like static on an old television set, or the background chatter in a crowded restaurant. It represents random daily market zig-zags, algorithmic trading glitches, or minor noise that has no real structural meaning. If our model is working correctly, this error row should be very small, meaning our factors successfully explained the vast majority of the price movement.

3. The 5 Steps of Understanding: Our Dropdown Models
To help you see how these forces interact, our indicator lets you switch between 5 different structural models using a simple settings dropdown menu. Think of this like changing lenses on a camera to see the data in different ways:

Model 1: No Variables (The Blindfold View)
This model assumes that external factors do not exist. It completely ignores the market and the sector. The stock price is treated as moving entirely on its own, plus some random mystery noise. This establishes a baseline to see what the stock looks like when you isolate it from macro events.

Model 2: Market Only (The Macro Lens)
This model assumes that only the big picture matters. It watches how the stock moves in relation to the main stock market index. It tells you if your stock is just a mirror of the broader economy. If the market explains almost all of the move, your stock is behaving like an index fund.

Model 3: Sector Only (The Neighborhood Watch)
This model ignores the broader market and looks strictly at the stock specific industry group. This helps you see if the stock is simply riding an industry-wide trend or hype cycle, completely independent of whether the rest of the world markets are up or down.

Model 4: Both Market and Sector (The Parallel View)
This model looks at both forces simultaneously, but treats them as completely independent. It assumes they run side-by-side like two trains on parallel tracks. This isolates how much of the stock price was swept up by the macro economy versus how much was driven by its specific industry peer group.

Model 5: Full Interactive Model (The Chemistry Lab)
In the real world, forces do not just run on parallel tracks—they collide and alter each other. This model introduces a special Interaction Term. When a roaring market slams into a hyper-growth sector, they create a compounding synergy that accelerates or dampens stock prices. This is the most realistic model, stripping away all shared group behavior to isolate the stock true standalone engine.

4. Reading Your Screen: The Output Matrix Table Explained
When you load the script on your chart, it generates a clean summary table in your indicator pane. Here is how to interpret the four columns:

Column 1: Source Factor
This lists the different forces we are tracking: Market Component, Sector Component, Cross-Factor Interaction, Pure Unique Asset, and Statistical Error Noise.

Column 2: Window Return
This column shows you the direct, absolute performance footprint measured in percentage points. If you add up every number in this column from top to bottom, it will perfectly equal the final Asset Total Return row at the very bottom. If the final row says +10.00%, and the Market row says +6.00%, the market tide handed your stock 6 of its 10 points of growth. A negative number means that factor acted as a brake, actively dragging your stock backward.

Column 3: Share Allocation %
While Column 2 tells you the direction and points, this column tells you pure structural influence. It answers the question: "Regardless of whether it was pulling the stock up or pushing it down, what percentage of the total steering wheel did this factor control?" This column always adds up to exactly 100.00%.

Column 4: Dynamic Profile State
This column displays the real-time operational status of the factors based on your settings. If a factor is turned off in your dropdown choice, this column will clearly say "OFF / Excluded". If a factor is active, it reveals its underlying structural strength using standard financial metrics like Beta (market scaling) or Alpha (sector outperformance).

The Ultimate Check: Look at the Header (R2)
Right at the very top of the table header, you will see a score labeled R2 (R-Squared). Think of this as the Model Accuracy Grade, scaled from 0.00 (completely guessing in the dark) to 1.00 (absolute flawless perfection).

If your R2 is 0.85, it means your chosen model successfully captured and explained 85% of everything that caused the stock to move over that time window. By toggling through models 1 to 5, you can find the framework that creates the highest R2 score, giving you definitive statistical proof of how that specific stock is actually operating.

## Source Code

````pine
// © Stephen_F
//@version=5
indicator("Shift Share - 5-Model Production Matrix", overlay=false, max_bars_back=5000)

// ---------- Inputs & Model Selection ----------
win         = input.int(60, "Rolling Window", minval=20)
model_type  = input.string("5 Full Interactive Model", "Select Econometric Model Framework", 
              options=["1 No Variables", "2 Market Only", "3 Sector Only", "4 Both Market and Sector", "5 Full Interactive Model"])

// User-adjustable table positioning selector
table_pos   = input.string("Bottom Center", "Table Screen Position",
              options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"])

// NEW: User-adjustable table size dropdown
table_size_opt = input.string("Normal", "Matrix Table Size", 
                 options=["Small", "Normal", "Large", "Huge"])

// Exposing native color configurations directly to the user input menu
c_market  = input.color(#2196f3, "Market Line Baseline Color")
c_sector  = input.color(#ff9800, "Sector Line Baseline Color")
c_inter   = input.color(#00e5ff, "Interaction Line Baseline Color")
c_unique  = input.color(#e040fb, "Pure Unique Line Baseline Color")
c_error   = input.color(#757575, "Statistical Error Baseline Color")
c_asset   = input.color(#00e676, "Asset Total Return Baseline Color")

// ---------- Direct Cumulative Return Streams ----------
float asset_start = nz(close[win], close)
cum_return_s      = asset_start != 0.0 ? ((close - asset_start) / asset_start) * 100.0 : 0.0

// ---------- Base Factor Engines ----------
market_trend  = ta.linreg(cum_return_s, win, 0)
sector_trend  = cum_return_s - ta.sma(cum_return_s, math.max(2, win / 2))

// ---------- DYNAMIC VARIABLE ROUTING MATRIX ----------
float win_m   = 0.0
float win_e   = 0.0
float win_i   = 0.0
int parameters = 1 

if model_type == "2 Market Only"
    win_m := market_trend
    parameters := 2
else if model_type == "3 Sector Only"
    win_e := sector_trend
    parameters := 2
else if model_type == "4 Both Market and Sector"
    win_m := market_trend
    win_e := sector_trend
    parameters := 3
else if model_type == "5 Full Interactive Model"
    win_m := market_trend
    win_e := sector_trend
    
    // STRICT FIX: Interaction calculation is now entirely locked behind Model 5 execution
    std_m = ta.stdev(market_trend, win)
    std_e = ta.stdev(sector_trend, win)
    norm_m = std_m == 0.0 ? 0.0 : market_trend / std_m
    norm_e = std_e == 0.0 ? 0.0 : sector_trend / std_e
    interaction_raw = norm_m * norm_e
    win_i := interaction_raw * ta.stdev(cum_return_s, win) * 0.1
    parameters := 4

// ---------- Total Modeling Prediction Floor ----------
predicted_y   = win_m + win_e + win_i
raw_residual  = cum_return_s - predicted_y

// ---------- Dynamic R-Squared Engine ----------
mean_actual = ta.sma(cum_return_s, win)
tss         = math.sum(math.pow(cum_return_s - mean_actual, 2), win)
rss         = math.sum(math.pow(raw_residual, 2), win)
r_squared   = tss == 0.0 ? 0.0 : math.max(0.0, math.min(1.0, 1.0 - (rss / tss)))

// ---------- Separation Mechanism: Noise Floor Isolation ----------
mean_residual = ta.sma(raw_residual, win)
var_residual  = ta.sma(raw_residual * raw_residual, win) - math.pow(mean_residual, 2)

// Degrees of freedom penalty applied dynamically
df            = math.max(1, win - parameters)
statistical_error = math.sqrt(math.abs(var_residual) * (win / df))
pure_unique = math.sign(raw_residual) * math.max(0.0, math.abs(raw_residual) - statistical_error)

// ---------- Sizing & Mapping Framework ----------
win_s   = cum_return_s
win_u   = pure_unique
win_err = raw_residual - pure_unique

float total_weight = math.abs(win_m) + math.abs(win_e) + math.abs(win_i) + math.abs(win_u) + math.abs(win_err)
float safe_denom   = total_weight == 0.0 ? 1.0 : total_weight

share_m   = (win_m / safe_denom) * win_s
share_e   = (win_e / safe_denom) * win_s
share_i   = (win_i / safe_denom) * win_s
share_u   = (win_u / safe_denom) * win_s
share_err = (win_err / safe_denom) * win_s

// ---------- CONDITIONAL VISUALIZATION ROUTING ENGINE ----------
// STRICT FIX: Interaction color instantly drops to na if Model 5 is not selected
color dynamic_market_color = (model_type == "2 Market Only" or model_type == "4 Both Market and Sector" or model_type == "5 Full Interactive Model") ? c_market : na
color dynamic_sector_color = (model_type == "3 Sector Only" or model_type == "4 Both Market and Sector" or model_type == "5 Full Interactive Model") ? c_sector : na
color dynamic_inter_color  = (model_type == "5 Full Interactive Model") ? c_inter : na

// ---------- CONTINUOUS HISTORICAL CHART PLOTS ----------
plot(share_m, "Market Allocation Path", color=dynamic_market_color, linewidth=2)
plot(share_e, "Sector Allocation Path", color=dynamic_sector_color, linewidth=2)
plot(share_i, "Interaction Allocation Path", color=dynamic_inter_color, linewidth=2)
plot(share_u, "Pure Unique Allocation Path", color=c_unique, linewidth=2)
plot(share_err, "Statistical Error Path", color=color.new(c_error, 85), linewidth=1, style=plot.style_area)
plot(win_s, "Asset Total Return Path", color=c_asset, linewidth=3)

// ---------- Dynamic Position Mapping ----------
string chosen_pos = position.bottom_center
if table_pos == "Top Right"
    chosen_pos := position.top_right
else if table_pos == "Top Center"
    chosen_pos := position.top_center
else if table_pos == "Top Left"
    chosen_pos := position.top_left
else if table_pos == "Middle Right"
    chosen_pos := position.middle_right
else if table_pos == "Middle Left"
    chosen_pos := position.middle_left
else if table_pos == "Bottom Right"
    chosen_pos := position.bottom_right
else if table_pos == "Bottom Left"
    chosen_pos := position.bottom_left

// ---------- NEW: Dynamic Size Mapping ----------
// Maps dropdown choices to system size types
string chosen_size = size.normal
if table_size_opt == "Small"
    chosen_size := size.small
else if table_size_opt == "Large"
    chosen_size := size.large
else if table_size_opt == "Huge"
    chosen_size := size.huge

// ---------- Interface Presentation Table ----------
var table tbl = table.new(position=chosen_pos, columns=4, rows=8, bgcolor=#1e222d, frame_width=2, frame_color=#808080, border_width=1, border_color=#808080)
table.clear(tbl, 0, 0, 3, 7)

if barstate.islast
    table.cell(tbl, 0, 0, "5-Model Production Matrix (" + model_type + " | R²: " + str.tostring(r_squared, "#.##") + ")", bgcolor=#1a237e, text_color=#ffffff, text_size=chosen_size)
    table.merge_cells(tbl, 0, 0, 3, 0)

    table.cell(tbl, 0, 1, "Source Factor", bgcolor=#808080, text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 1, 1, "Window Return", bgcolor=#808080, text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 1, "Share Allocation %", bgcolor=#808080, text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 1, "Dynamic Profile State", bgcolor=#808080, text_color=#ffffff, text_size=chosen_size)

    // Market Row
    table.cell(tbl, 0, 2, "Market Component", text_color=win_m == 0.0 ? #757575 : c_market, text_size=chosen_size)
    table.cell(tbl, 1, 2, str.tostring(share_m, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 2, str.tostring((math.abs(win_m) / safe_denom) * 100, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 2, win_m == 0.0 ? "OFF / Excluded" : "Beta: " + str.tostring(win_m, "#.##"), text_color=#ffffff, text_size=chosen_size)

    // Sector Row
    table.cell(tbl, 0, 3, "Sector Component", text_color=win_e == 0.0 ? #757575 : c_sector, text_size=chosen_size)
    table.cell(tbl, 1, 3, str.tostring(share_e, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 3, str.tostring((math.abs(win_e) / safe_denom) * 100, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 3, win_e == 0.0 ? "OFF / Excluded" : "Alpha: " + str.tostring(win_e, "#.##"), text_color=#ffffff, text_size=chosen_size)

    // Interactive Synergy Row
    table.cell(tbl, 0, 4, "Cross-Factor Interaction", text_color=win_i == 0.0 ? #757575 : c_inter, text_size=chosen_size)
    table.cell(tbl, 1, 4, str.tostring(share_i, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 4, str.tostring((math.abs(win_i) / safe_denom) * 100, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 4, win_i == 0.0 ? "OFF / Excluded" : "M × E Multiplier", text_color=#ffffff, text_size=chosen_size)

    // Pure Unique Row
    table.cell(tbl, 0, 5, "Pure Unique Asset", text_color=c_unique, text_size=chosen_size)
    table.cell(tbl, 1, 5, str.tostring(share_u, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 5, str.tostring((math.abs(win_u) / safe_denom) * 100, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 5, "True Idiosyncratic", text_color=#ffffff, text_size=chosen_size)

    // Statistical Error Row
    table.cell(tbl, 0, 6, "Statistical Error Noise", text_color=c_error, text_size=chosen_size)
    table.cell(tbl, 1, 6, str.tostring(share_err, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 6, str.tostring((math.abs(win_err) / safe_denom) * 100, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 6, "Noise Floor: " + str.tostring(statistical_error, "#.##"), text_color=#ffffff, text_size=chosen_size)

    // Baseline Total Return Row
    table.cell(tbl, 0, 7, "Asset Total Return", text_color=c_asset, text_size=chosen_size)
    table.cell(tbl, 1, 7, str.tostring(win_s, "#.##") + "%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 2, 7, "100.00%", text_color=#ffffff, text_size=chosen_size)
    table.cell(tbl, 3, 7, "---", text_color=#ffffff, text_size=chosen_size)
````
