# Daily 5-SMA (intraday)

- url: https://www.tradingview.com/script/WFCS1W27-Daily-5-SMA-intraday/
- type: indicator
- pine_id: PUB;4e666546cedc4c3086e92adf01e3ce65
- version: 1.0

## Description

Daily 5-SMA Equivalent
This indicator translates a daily Simple Moving Average into its mathematically equivalent period for any intraday (or higher) timeframe, so the line you see on a 5-minute chart represents the same lookback window as the daily SMA on a daily chart — no manual period recalculation needed.
How it works
The script measures how many bars of the current timeframe fit inside the total minute-span of the reference SMA. For example, a 5-day SMA covers 1,950 minutes on a stock market (5 × 390 min/day). On a 5-minute chart that becomes a 390-period SMA; on a 15-minute chart it becomes a 130-period SMA. The conversion is automatic whenever you change timeframes.
An information table in the top-right corner always shows the active timeframe, the calculated equivalent period, the reference setting, and the selected market type — so you can verify the math at a glance.
Inputs

Source — Price field used for the calculation (default: close).
Reference Days — The number of daily bars the SMA spans. Default is 5 (the classic daily 5-SMA). Accepts 1–50.
Market Type — Determines how many minutes constitute a trading day:

24h — 1,440 min/day, for Forex and Crypto markets.
Stock — 390 min/day (6.5-hour session), for equities and equity futures.



Timeframe support
The period conversion handles seconds, minutes, hours, days, weeks, and monthly timeframes. On daily or higher timeframes the indicator still plots correctly, though it is most useful on intraday charts.
Alerts
Four alert conditions are included:

Price crosses above the SMA equivalent
Price crosses below the SMA equivalent
SMA is rising
SMA is falling

Usage notes
Set Market Type to Stock for equities and NQ/ES/MES futures. Use 24h for Bitcoin, Ethereum, Forex pairs, or any continuously traded instrument. The displayed equivalent period will always be at least 1, regardless of how high a timeframe you are viewing.

## Source Code

````pine
//@version=6
indicator("Daily 5-SMA Equivalent", shorttitle="D5SMA-Eq", overlay=true)

// Input settings
source_input = input.source(close, title="Source")
reference_days = input.int(5, title="Reference Days", minval=1, maxval=50)
market_type = input.string("24h", title="Market Type", options=["24h", "Stock"], tooltip="24h for Forex/Crypto, Stock for traditional markets")

// Function to get current timeframe in minutes
get_timeframe_minutes() =>
    tf_string = timeframe.period
    
    if str.endswith(tf_string, "S")
        // Convert seconds to minutes (divide by 60)
        seconds = str.tonumber(str.replace(tf_string, "S", ""))
        seconds / 60.0
    else if str.endswith(tf_string, "D")
        int(str.tonumber(str.replace(tf_string, "D", ""))) * (market_type == "24h" ? 1440 : 390)
    else if str.endswith(tf_string, "W")
        int(str.tonumber(str.replace(tf_string, "W", ""))) * (market_type == "24h" ? 10080 : 1950)
    else if str.endswith(tf_string, "M")
        int(str.tonumber(str.replace(tf_string, "M", ""))) * (market_type == "24h" ? 43200 : 8580)
    else
        // Default to minutes for numeric timeframes
        int(str.tonumber(tf_string))

// Calculate equivalent period
daily_minutes = market_type == "24h" ? 1440 : 390  // 24h = 1440 min, Stock = 6.5h = 390 min
current_tf_minutes = get_timeframe_minutes()
reference_total_minutes = reference_days * daily_minutes
equivalent_periods = math.round(reference_total_minutes / current_tf_minutes)

// Ensure minimum period of 1
final_periods = math.max(1, equivalent_periods)

// Calculate the SMA
sma_equivalent = ta.sma(source_input, final_periods)

// Plot the SMA
plot(sma_equivalent, title="Daily 5-SMA Equivalent", color=color.blue, linewidth=2)

// Display information
var table info_table = table.new(position.top_right, 2, 4, bgcolor=color.white, border_width=1)

if barstate.islast
    table.cell(info_table, 0, 0, "Current TF:", text_color=color.black, text_size=size.small)
    table.cell(info_table, 1, 0, timeframe.period, text_color=color.blue, text_size=size.small)
    
    table.cell(info_table, 0, 1, "Equivalent Periods:", text_color=color.black, text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(final_periods), text_color=color.blue, text_size=size.small)
    
    table.cell(info_table, 0, 2, "Reference:", text_color=color.black, text_size=size.small)
    table.cell(info_table, 1, 2, str.tostring(reference_days) + "D SMA", text_color=color.blue, text_size=size.small)
    
    table.cell(info_table, 0, 3, "Market Type:", text_color=color.black, text_size=size.small)
    table.cell(info_table, 1, 3, market_type, text_color=color.blue, text_size=size.small)

// Alert conditions
sma_rising = ta.rising(sma_equivalent, 1)
sma_falling = ta.falling(sma_equivalent, 1)
price_above_sma = close > sma_equivalent
price_below_sma = close < sma_equivalent

// Crossover alerts
alertcondition(ta.crossover(close, sma_equivalent), title="Price Cross Above SMA", message="Price crossed above Daily 5-SMA equivalent")
alertcondition(ta.crossunder(close, sma_equivalent), title="Price Cross Below SMA", message="Price crossed below Daily 5-SMA equivalent")
alertcondition(sma_rising, title="SMA Rising", message="Daily 5-SMA equivalent is rising")
alertcondition(sma_falling, title="SMA Falling", message="Daily 5-SMA equivalent is falling")
````
