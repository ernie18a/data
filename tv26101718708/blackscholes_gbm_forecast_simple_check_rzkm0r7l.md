# Black-Scholes GBM Forecast [Simple Check]

- url: https://www.tradingview.com/script/RZKm0r7L-Black-Scholes-GBM-Forecast-Simple-Check/
- type: indicator
- pine_id: PUB;5288735bbb074633922a98822b01a335
- version: 1.0

## Description

How It Works
The Core Concept
This indicator projects future price paths using Geometric Brownian Motion (GBM) — the same mathematical framework underlying the Black-Scholes options pricing model. Think of it as a digital Galton board: each small time step is a random bounce left or right, and the aggregation of many bounces creates a predictable statistical distribution.

Step-by-Step Calculation
1. Historical Analysis

The script calculates log returns from historical price data: ln(Price_t / Price_{t-1})

From these returns, it computes two key parameters over your chosen lookback period:

Volatility (σ) = Standard deviation of log returns, annualized

Drift (μ) = Mean of log returns, annualized

2. Drift Adjustment

Raw drift is adjusted using the formula: μ_adjusted = μ - σ²/2

This adjustment accounts for "volatility drag" — the mathematical fact that volatility reduces the expected geometric return

3. Future Projection

For each future bar i from 1 to your forecast_bars horizon:

Time in years: t = i / 252 (using 252 trading days/year)

Expected Value: EV = Current Price × exp(μ_adjusted × t)

Standard deviation of forecast: σ × √t

Confidence bands: EV × exp(± confidence_level × σ × √t)

4. Line Drawing

The yellow line shows the Expected Value (most probable path)

The red/green dotted lines show statistical confidence bands

Within 1 standard deviation (~68% probability), price is expected to stay between these bands

Reading the Table
Field	What It Means
Volatility (σ)	Annualized price fluctuation. Higher = wider expected ranges
Drift (μ)	Historical annualized trend. Green = bullish bias, Red = bearish bias
Adj Drift (GBM)	Drift after volatility adjustment — the true expected log-return
EV (1 bar)	Expected price after the next single bar, with percentage change
Range (1 bar)	Statistical price range for the next bar (based on your confidence level)
EV (X bars)	Expected price at the end of your forecast horizon
How to Use This Indicator
As a Second Opinion

Compare this forecast against your existing trading indicators

If your buy signal aligns with price below the EV line → statistical confirmation

If price is already above the upper band → statistically overextended (caution)

For Risk Management

The confidence bands can help set realistic profit targets and stop-losses

Price moves outside the bands suggest unusual market conditions

Important Limitations
Limitation	Explanation
Constant volatility	Assumes volatility stays the same as the lookback period. Real markets have changing volatility
Normal distribution assumption	Real market returns have "fat tails" — extreme moves happen more often than predicted
Independent steps	Assumes each bar's move is independent. Real markets show momentum and mean reversion
No fundamental data	Based purely on historical price statistics, not news or fundamentals
TradingView line limits	Maximum ~55-100 forecast bars due to platform object limits
Suggested Settings by Trading Style
Style	Timeframe	Lookback	Forecast Bars
Scalping	1-5 min	50-100	10-20
Day Trading	15-30 min	100-150	20-30
Swing Trading	1-4 hour	150-200	30-50
Position Trading	Daily	252	50-100
Credits
Based on the work of:

Francis Galton (Galton board / bean machine)

Louis Bachelier (first mathematical model of stock prices, 1900)

Fischer Black, Myron Scholes & Robert Merton (options pricing model)

## Source Code

````pine
//@version=6
indicator("Black-Scholes GBM Forecast [Simple Check]", overlay=true)

// ============================================
// 1. User Inputs
// ============================================
lookback = input.int(252, "Historical Lookback (bars)", minval=20, group="Model Settings")
forecast_bars = input.int(30, "Forecast Horizon (bars)", minval=1, maxval=100, group="Model Settings")
confidence_level = input.float(1.0, "Confidence Bands (Std Dev)", step=0.5, minval=0.5, maxval=3.0, tooltip="1.0 = ~68% probability, 1.96 = ~95% probability", group="Model Settings")

show_ev = input.bool(true, "Show Expected Value Line", group="Display")
show_upper_band = input.bool(true, "Show Upper Confidence Band", group="Display")
show_lower_band = input.bool(true, "Show Lower Confidence Band", group="Display")

// ============================================
// 2. Table Positioning & Size Inputs
// ============================================
table_position = input.string("Bottom Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table Settings")
table_size = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group="Table Settings")
show_table = input.bool(true, "Show Info Table", group="Table Settings")

// Convert position string to position constant
f_get_position(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.bottom_right

// Convert size string to size constants
f_get_sizes(size) =>
    switch size
        "Tiny" => [size.tiny, 1]
        "Small" => [size.small, 1]
        "Normal" => [size.normal, 2]
        "Large" => [size.large, 3]
        => [size.normal, 2]

// ============================================
// 3. Calculate Historical Drift & Volatility
// ============================================
log_returns = math.log(close / close[1])
volatility = ta.stdev(log_returns, lookback) * math.sqrt(252)
drift_raw = ta.sma(log_returns, lookback)
drift_annualized = drift_raw * 252
drift_adjusted = drift_annualized - (math.pow(volatility, 2) / 2)
start_price = close

// ============================================
// 4. Calculate 1-bar-ahead forecast for table
// ============================================
t_1bar = 1 / 252.0
stddev_1bar = volatility * math.sqrt(t_1bar)
ev_1bar = start_price * math.exp(drift_adjusted * t_1bar)
upper_1bar = start_price * math.exp(drift_adjusted * t_1bar + confidence_level * stddev_1bar)
lower_1bar = start_price * math.exp(drift_adjusted * t_1bar - confidence_level * stddev_1bar)

// Calculate percent changes
ev_pct = (ev_1bar - start_price) / start_price * 100

// ============================================
// 5. Calculate full horizon forecast for table
// ============================================
t_full = forecast_bars / 252.0
stddev_full = volatility * math.sqrt(t_full)
ev_full = start_price * math.exp(drift_adjusted * t_full)
upper_full = start_price * math.exp(drift_adjusted * t_full + confidence_level * stddev_full)
lower_full = start_price * math.exp(drift_adjusted * t_full - confidence_level * stddev_full)
ev_full_pct = (ev_full - start_price) / start_price * 100

// ============================================
// 6. Project Future Price (Drawing arrays)
// ============================================
var float[] projected_ev = array.new<float>()
var float[] projected_upper = array.new<float>()
var float[] projected_lower = array.new<float>()

if barstate.islast
    array.clear(projected_ev)
    array.clear(projected_upper)
    array.clear(projected_lower)
    
    for i = 1 to forecast_bars
        t = i / 252.0
        ev = start_price * math.exp(drift_adjusted * t)
        stddev_forecast = volatility * math.sqrt(t)
        upper = start_price * math.exp(drift_adjusted * t + confidence_level * stddev_forecast)
        lower = start_price * math.exp(drift_adjusted * t - confidence_level * stddev_forecast)
        
        array.push(projected_ev, ev)
        array.push(projected_upper, upper)
        array.push(projected_lower, lower)

// ============================================
// 7. Draw Forecast Lines
// ============================================
if barstate.islast
    start_bar = bar_index
    current_price_ev = close
    current_price_upper = close
    current_price_lower = close
    
    for i = 1 to forecast_bars
        target_bar = start_bar + i
        
        if show_ev and array.size(projected_ev) >= i
            ev_value = array.get(projected_ev, i - 1)
            line.new(start_bar, current_price_ev, target_bar, ev_value, 
                     color=color.new(color.yellow, 0), width=2, style=line.style_solid, extend=extend.none)
            current_price_ev := ev_value
        
        if show_upper_band and array.size(projected_upper) >= i
            upper_val = array.get(projected_upper, i - 1)
            line.new(start_bar, current_price_upper, target_bar, upper_val,
                     color=color.new(color.red, 40), width=1, style=line.style_dotted, extend=extend.none)
            current_price_upper := upper_val
        
        if show_lower_band and array.size(projected_lower) >= i
            lower_val = array.get(projected_lower, i - 1)
            line.new(start_bar, current_price_lower, target_bar, lower_val,
                     color=color.new(color.green, 40), width=1, style=line.style_dotted, extend=extend.none)
            current_price_lower := lower_val

// ============================================
// 8. Create Resizable, Positionable Info Table
// ============================================
if show_table and barstate.islast
    // Get position and size settings
    pos_const = f_get_position(table_position)
    [table_size_const, border_width] = f_get_sizes(table_size)
    
    // Create table (rows = 11, columns = 2)
    var info_table = table.new(pos_const, 2, 11, 
         bgcolor=color.new(color.black, 85),
         border_color=color.new(color.yellow, 30),
         border_width=border_width,
         frame_color=color.new(color.yellow, 50),
         frame_width=border_width)
    
    // Header Row 0
    table.cell(info_table, 0, 0, "GBM / Black-Scholes", 
         text_color=color.yellow, 
         text_size=table_size_const, 
         text_halign=text.align_center,
         bgcolor=color.new(color.yellow, 90))
    table.cell(info_table, 1, 0, "Value", 
         text_color=color.yellow, 
         text_size=table_size_const, 
         text_halign=text.align_center,
         bgcolor=color.new(color.yellow, 90))
    
    // Row 1: Current Price
    table.cell(info_table, 0, 1, "Current Price", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    table.cell(info_table, 1, 1, str.tostring(start_price, "#.##"), text_color=color.white, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 2: Volatility (Annual)
    table.cell(info_table, 0, 2, "Volatility (σ)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    table.cell(info_table, 1, 2, str.tostring(volatility * 100, "#.##") + "%", 
         text_color=color.red, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 3: Drift (Annual)
    table.cell(info_table, 0, 3, "Drift (μ)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    drift_color = drift_annualized > 0 ? color.green : color.red
    table.cell(info_table, 1, 3, str.tostring(drift_annualized * 100, "#.##") + "%", 
         text_color=drift_color, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 4: Adjusted Drift (μ - σ²/2)
    table.cell(info_table, 0, 4, "Adj Drift (GBM)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    adj_color = drift_adjusted > 0 ? color.green : color.red
    table.cell(info_table, 1, 4, str.tostring(drift_adjusted * 100, "#.##") + "%", 
         text_color=adj_color, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 5: Lookback Period
    table.cell(info_table, 0, 5, "Lookback", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    table.cell(info_table, 1, 5, str.tostring(lookback) + " bars", text_color=color.gray, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 6: Separator - 1 Bar Forecast
    table.cell(info_table, 0, 6, "───── 1-Bar Forecast ─────", 
         text_color=color.yellow, text_size=table_size_const, text_halign=text.align_center, 
         bgcolor=color.new(color.yellow, 95))
    table.cell(info_table, 1, 6, "", text_size=table_size_const)
    
    // Row 7: Expected Value (1 bar)
    table.cell(info_table, 0, 7, "EV (1 bar)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    ev_color = ev_pct >= 0 ? color.green : color.red
    table.cell(info_table, 1, 7, str.tostring(ev_1bar, "#.##") + "  (" + str.tostring(ev_pct, "+#.##;-#.##") + "%)", 
         text_color=ev_color, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 8: Confidence Range (1 bar)
    table.cell(info_table, 0, 8, "Range (1 bar)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    table.cell(info_table, 1, 8, str.tostring(lower_1bar, "#.##") + " — " + str.tostring(upper_1bar, "#.##"), 
         text_color=color.aqua, text_size=table_size_const, text_halign=text.align_right)
    
    // Row 9: Separator - Full Forecast
    table.cell(info_table, 0, 9, "─── " + str.tostring(forecast_bars) + "-Bar Forecast ───", 
         text_color=color.yellow, text_size=table_size_const, text_halign=text.align_center, 
         bgcolor=color.new(color.yellow, 95))
    table.cell(info_table, 1, 9, "", text_size=table_size_const)
    
    // Row 10: Expected Value (full horizon)
    table.cell(info_table, 0, 10, "EV (" + str.tostring(forecast_bars) + " bars)", text_color=color.white, text_size=table_size_const, text_halign=text.align_left)
    ev_full_color = ev_full_pct >= 0 ? color.green : color.red
    table.cell(info_table, 1, 10, str.tostring(ev_full, "#.##") + "  (" + str.tostring(ev_full_pct, "+#.##;-#.##") + "%)", 
         text_color=ev_full_color, text_size=table_size_const, text_halign=text.align_right)

// ============================================
// 9. Alerts
// ============================================
if barstate.islast and show_upper_band and array.size(projected_upper) >= 1
    next_upper = array.get(projected_upper, 0)
    next_lower = array.get(projected_lower, 0)
    if close > next_upper
        alert("Price above upper confidence band", alert.freq_once_per_bar)
    if close < next_lower
        alert("Price below lower confidence band", alert.freq_once_per_bar)
````
