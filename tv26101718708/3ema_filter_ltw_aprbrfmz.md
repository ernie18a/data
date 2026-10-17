# 3EMA Filter [LTW]

- url: https://www.tradingview.com/script/ApRbRfmz/
- type: indicator
- pine_id: PUB;cf09deba93214a49a2e144a3c6be0f41
- version: 2.0

## Description

📈 3EMA Filter [LTW]
This indicator visualizes real-time trend intensity using a multi-timeframe Exponential Moving Average (EMA) structure, projects future price trajectories based on momentum slopes, and quantifies fast-to-slow moving average divergence via an integrated real-time dashboard.

Instead of looking backward at static historical support and resistance levels on lower timeframes, you can instantly read real-time trend acceleration and price divergence right here and now to build powerful, forward-looking trading strategies.

⚙️ Key Features & Customization
▪️ Dynamic EMA Ribbon & Crossover Signals (Default: 50, 100, 200)
Utilizes dynamic colored ribbon filling between EMA 1, 2, and 3 to provide an immediate visual assessment of trend alignment (bullish/bearish) and momentum strength. Highlights Golden Cross and Dead Cross events between the fast and middle lines with distinct markers and optional background highlighting.

▪️ Slope-Based Future Trajectory Projection
Calculates the current momentum slope of each moving average at the latest bar to project future EMA trajectories 'n' bars forward. Allows traders to visually gauge whether trend momentum is currently accelerating or flattening out, aiding in the early detection of potential inflection points and trend reversals. (Supports customizable styles: Solid, Dotted, Dashed).

▪️ High-Visibility Divergence Dashboard
Automatically calculates and displays the Current, Maximum, and Minimum price divergence (%) between the fast moving average (EMA1) and the slow moving average (EMA3) over a selectable timeframe (1D, 1W, 1M). Engineered with a crisp, high-contrast design to immediately evaluate overbought and oversold market pressure across both Dark and Light themes.

▪️ Keep Charts Clean & Focus on Operability (Limit Display to Recent "n" Bars)
We approached this feature with the mindset of focusing on practical 'Operability' and responsiveness in real-time trading rather than just simple readability. By limiting the indicator display to the most recent 'n' bars, it reduces computational waste and eliminates visual clutter from historical bars, allowing you to react immediately to pure candlestick price action.

💡 How to Use & Trading Strategies
Provides a clean, forward-looking analytical framework that eliminates hindsight bias on lower timeframes.

1. Focusing on Acceleration & Divergence on Lower Timeframes
Unless you are analyzing macro moving averages like the 200-day or 200-week MAs on daily or weekly charts, tracing historical MA support and resistance lines on lower timeframes (such as intraday minute or hourly charts) often offers little practical synergy in real-time trading. This indicator departs from static historical mapping and is used strictly to read real-time "EMA Divergence" and the "Momentum Acceleration" of the current trend.

2. Preventing Curve-Fitting & Hindsight Bias (Hidden Picture Puzzles)
The integrated Bar Limit feature is deliberately designed to stop traders from falling into the trap of "playing hidden picture puzzles"—retroactively forcing indicators to fit historical price action. It eliminates hindsight bias, ensuring your analytical focus remains 100% locked on present market dynamics and future trajectory projections.

📌 Summary
A practical, all-in-one indicator designed to shift your focus away from static historical support/resistance and toward real-time trend acceleration and divergence. Through slope-based future projections, a high-visibility divergence dashboard, and an operability-focused Bar Limit feature, you can eliminate hindsight bias and trade with high reliability by focusing entirely on active market dynamics.

## Source Code

````pine
//@version=6
indicator(title = '3EMA Filter [LTW] v2.1', shorttitle = '3EMA Filter [LTW] v2.1', overlay = true)

// ==========================================
// Input Settings
// ==========================================
EMA1 = input.int(50, minval = 1, title = 'EMA1 (Fast Line)')
EMA2 = input.int(100, minval = 1, title = 'EMA2 (Middle Line)')
EMA3 = input.int(200, minval = 1, title = 'EMA3 (Slow Line)')

// Display Limit Settings (For Lines & Shapes)
useBarLimit = input.bool(true, title = 'Enable Bar Limit (Lines)')
barLimit = input.int(16, minval = 1, title = 'Number of Bars to Show')

// Visualization Options & Colors
colorEma1 = input.color(#ff9800, title = 'EMA 1 Color', group = 'Visualization')
colorEma2 = input.color(#00bcd4, title = 'EMA 2 Color', group = 'Visualization')
colorEma3 = input.color(#591efd, title = 'EMA 3 Color', group = 'Visualization')

showCrossShapes = input.bool(true, title = 'Show Cross Shapes', group = 'Visualization')
showCrossBg = input.bool(false, title = 'Show Cross Background', group = 'Visualization')

// ==========================================
// Ribbon Fill Settings (Time Based)
// ==========================================
showRibbon = input.bool(true, title = 'Show EMA Ribbon Fill', group = 'Ribbon Fill Settings')
ribbonTimeValue = input.int(30, minval = 1, title = 'Ribbon Duration Value', group = 'Ribbon Fill Settings')
ribbonTimeUnit = input.string('Days', title = 'Ribbon Duration Unit', options = ['Days', 'Weeks', 'Months', 'Years'], group = 'Ribbon Fill Settings')

// Forecast Options
showForecast = input.bool(true, title = 'Show Future Forecast Line', group = 'Forecast Options')
forwardBars = input.int(10, minval = 1, title = 'Forecast Forward Bars', group = 'Forecast Options')
forecastWidth = input.int(2, minval = 1, maxval = 5, title = 'Forecast Line Width', group = 'Forecast Options')
forecastStyleInput = input.string('Dotted', title = 'Forecast Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = 'Forecast Options')

// Convert string input to Pine Script line style
forecastStyle = forecastStyleInput == 'Solid' ? line.style_solid : forecastStyleInput == 'Dashed' ? line.style_dashed : line.style_dotted

// ==========================================
// Table Options
// ==========================================
showTable = input.bool(true, title = 'Show Table', group = 'EMA Analysis Table')
showEma2Balance = input.bool(true, title = 'Show EMA2 Balance Row', group = 'EMA Analysis Table')
tfInput = input.string('1 Month', title = 'Timeframe', options = ['1 Day', '1 Week', '1 Month'], group = 'EMA Analysis Table')
tablePosInput = input.string('Top Right', title = 'Table Position', options = ['Top Center', 'Bottom Center', 'Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'], group = 'EMA Analysis Table')
tableSizeInput = input.string('Normal', title = 'Table Text Size', options = ['Small', 'Normal', 'Large'], group = 'EMA Analysis Table')

tablePosition = switch tablePosInput
    'Top Center'    => position.top_center
    'Bottom Center' => position.bottom_center
    'Top Right'     => position.top_right
    'Bottom Right'  => position.bottom_right
    'Top Left'      => position.top_left
    'Bottom Left'   => position.bottom_left
    => position.top_right

tableTextSize = tableSizeInput == 'Small' ? size.small : tableSizeInput == 'Large' ? size.large : size.normal

// ==========================================
// EMA Calculation
// ==========================================
ema_val1 = ta.ema(close, EMA1)
ema_val2 = ta.ema(close, EMA2)
ema_val3 = ta.ema(close, EMA3)

// ==========================================
// Display Limits & Time Calculations
// ==========================================
// 1. Bar limit for Plot Lines
is_in_range = not useBarLimit or (last_bar_index - bar_index < barLimit)
limit_bars = useBarLimit ? barLimit : 500000

// 2. Time limit for Ribbon Fill (Based on real-world date from current bar)
var int msPerDay = 86400000 // 24 * 60 * 60 * 1000
int ribbonMultiplier = switch ribbonTimeUnit
    'Days' => 1
    'Weeks' => 7
    'Months' => 30
    'Years' => 365
    => 1
int ribbonCutoffTime = timenow - (ribbonTimeValue * ribbonMultiplier * msPerDay)

is_ribbon_in_range = time >= ribbonCutoffTime

// ==========================================
// Chart Plots (Lines & Ribbon)
// ==========================================
// Visible plots (Limited by barLimit, Color synced with Inputs)
p1 = plot(is_in_range ? ema_val1 : na, color = colorEma1, linewidth = 2, title = 'EMA1', show_last = limit_bars)
p2 = plot(is_in_range ? ema_val2 : na, color = colorEma2, linewidth = 1, title = 'EMA2', show_last = limit_bars)
p3 = plot(is_in_range ? ema_val3 : na, color = colorEma3, linewidth = 2, title = 'EMA3', show_last = limit_bars)

// Hidden plots specifically for Ribbon boundary calculation (No barLimit applied)
p1_fill = plot(ema_val1, title = 'EMA1 Ribbon Bound', display = display.none)
p3_fill = plot(ema_val3, title = 'EMA3 Ribbon Bound', display = display.none)

// Alignment Conditions
is_bullish_align = ema_val1 > ema_val2 and ema_val2 > ema_val3
is_bearish_align = ema_val1 < ema_val2 and ema_val2 < ema_val3
is_mixed_align = not is_bullish_align and not is_bearish_align

// Ribbon Fill applies the Time/Date limit using the hidden boundaries
fill_color = is_ribbon_in_range and showRibbon ? (is_bullish_align ? color.new(color.green, 85) : is_bearish_align ? color.new(color.red, 85) : na) : na
fill(p1_fill, p3_fill, color = fill_color, title = 'EMA Ribbon Fill')

// ==========================================
// Crossover Calculation & Visualization
// ==========================================
gold_cross = ta.crossover(ema_val1, ema_val2)
dead_cross = ta.crossunder(ema_val1, ema_val2)

plotshape(showCrossShapes and gold_cross and is_in_range, title = 'Golden Cross Shape', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small, show_last = limit_bars)
plotshape(showCrossShapes and dead_cross and is_in_range, title = 'Dead Cross Shape', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, show_last = limit_bars)

bgcolor(showCrossBg and gold_cross and is_in_range ? color.new(color.green, 80) : na, title = 'Golden Cross Background', show_last = limit_bars)
bgcolor(showCrossBg and dead_cross and is_in_range ? color.new(color.red, 80) : na, title = 'Dead Cross Background', show_last = limit_bars)

// ==========================================
// Alerts
// ==========================================
alertcondition(gold_cross, title = 'EMA Golden Cross', message = 'EMA fast line crossed above middle line. Price: {{close}}')
alertcondition(dead_cross, title = 'EMA Dead Cross', message = 'EMA fast line crossed below middle line. Price: {{close}}')

// ==========================================
// Future Forecast Lines (Slope Based)
// ==========================================
var line f_line1 = na
var line f_line2 = na
var line f_line3 = na

if showForecast and barstate.islast
    line.delete(f_line1)
    line.delete(f_line2)
    line.delete(f_line3)

    slope1 = ema_val1 - ema_val1[1]
    slope2 = ema_val2 - ema_val2[1]
    slope3 = ema_val3 - ema_val3[1]

    future_ema1 = ema_val1 + slope1 * forwardBars
    future_ema2 = ema_val2 + slope2 * forwardBars
    future_ema3 = ema_val3 + slope3 * forwardBars

    // Forecast lines color synced with Inputs
    f_line1 := line.new(x1 = bar_index, y1 = ema_val1, x2 = bar_index + forwardBars, y2 = future_ema1, color = colorEma1, width = forecastWidth, style = forecastStyle)
    f_line2 := line.new(x1 = bar_index, y1 = ema_val2, x2 = bar_index + forwardBars, y2 = future_ema2, color = colorEma2, width = forecastWidth, style = forecastStyle)
    f_line3 := line.new(x1 = bar_index, y1 = ema_val3, x2 = bar_index + forwardBars, y2 = future_ema3, color = colorEma3, width = forecastWidth, style = forecastStyle)

// ==========================================
// EMA2 Position Gauge (0% = EMA1, 100% = EMA3)
// ==========================================
f_get_gauge(val1, val2, val3) =>
    diff_total = val3 - val1
    ratio = diff_total != 0 ? (val2 - val1) / diff_total : 0.5
    clamped_ratio = math.max(0.0, math.min(1.0, ratio))
    
    pos = int(math.round(clamped_ratio * 10))
    
    gauge_str = ""
    for i = 0 to 10
        if i == pos
            gauge_str += "◆"
        else
            gauge_str += "─"
    
    pct_val = clamped_ratio * 100
    "[EMA1] " + gauge_str + " [EMA3] (" + str.tostring(pct_val, "#.#") + "%)"

// ==========================================
// EMA1 & EMA3 Price Analysis
// ==========================================
diff_price = ema_val1 - ema_val3
diff_pct = (diff_price / ema_val3) * 100

price_diff_ema1 = close - ema_val1
price_pct_ema1 = (price_diff_ema1 / ema_val1) * 100

price_diff_ema3 = close - ema_val3
price_pct_ema3 = (price_diff_ema3 / ema_val3) * 100

target_sec = tfInput == '1 Day' ? 86400 : tfInput == '1 Week' ? 604800 : 2592000
lookback_bars = math.max(1, int(target_sec / timeframe.in_seconds()))

max_diff_pct = ta.highest(diff_pct, lookback_bars)
min_diff_pct = ta.lowest(diff_pct, lookback_bars)

max_ema3 = ta.highest(ema_val3, lookback_bars)
max_ema1 = max_ema3 * (1 + max_diff_pct / 100)
max_diff_price = max_ema1 - max_ema3

min_ema3 = ta.lowest(ema_val3, lookback_bars)
min_ema1 = min_ema3 * (1 + min_diff_pct / 100)
min_diff_price = min_ema1 - min_ema3

// ==========================================
// Table Generation
// ==========================================
var table statTable = table.new(position = tablePosition, columns = 4, rows = showEma2Balance ? 6 : 5, bgcolor = color.new(color.white, 10), border_width = 1, border_color = #cbd5e1)

if showTable and barstate.islast
    // Width configuration
    w_col0 = 5.0
    w_col1 = 5.5
    w_col2 = 5.5
    w_col3 = 6.0

    color text_main = #1e293b
    color text_header = #0f172a
    color bg_header = #e2e8f0
    color color_up = #089981
    color color_down = #f23645

    // Header (Row 0)
    table.cell(statTable, 0, 0, 'Metric\n(' + tfInput + ')', text_color = text_header, text_size = tableTextSize, bgcolor = bg_header, width = w_col0)
    table.cell(statTable, 1, 0, 'EMA 1', text_color = colorEma1, text_size = tableTextSize, bgcolor = bg_header, width = w_col1)
    table.cell(statTable, 2, 0, 'EMA 3', text_color = colorEma3, text_size = tableTextSize, bgcolor = bg_header, width = w_col2)
    table.cell(statTable, 3, 0, 'Diff\n(Price / %)', text_color = text_header, text_size = tableTextSize, bgcolor = bg_header, width = w_col3)
    
    // Current EMA (Row 1)
    table.cell(statTable, 0, 1, 'Current EMA', text_color = text_main, text_size = tableTextSize, width = w_col0)
    table.cell(statTable, 1, 1, str.tostring(ema_val1, '#.##'), text_color = colorEma1, text_size = tableTextSize, width = w_col1)
    table.cell(statTable, 2, 1, str.tostring(ema_val3, '#.##'), text_color = colorEma3, text_size = tableTextSize, width = w_col2)
    table.cell(statTable, 3, 1, str.tostring(diff_price, '#.##') + '\n(' + str.tostring(diff_pct, '#.##') + '%)', text_color = diff_price >= 0 ? color_up : color_down, text_size = tableTextSize, width = w_col3)
    
    row_idx = 2

    // EMA2 Balance
    if showEma2Balance
        gauge_color = is_bullish_align ? color_up : is_bearish_align ? color_down : text_main
        gauge_text = is_mixed_align ? "⚠️ Mixed Trend" : f_get_gauge(ema_val1, ema_val2, ema_val3)

        table.cell(statTable, 0, row_idx, 'EMA2 Balance', text_color = text_main, text_size = tableTextSize, width = w_col0)
        table.cell(statTable, 1, row_idx, gauge_text, text_color = gauge_color, text_size = tableTextSize, text_halign = text.align_center, tooltip = 'Gauge is shown only in perfect alignment (Bullish/Bearish). Otherwise, it shows as Mixed Trend.')
        table.merge_cells(statTable, 1, row_idx, 3, row_idx)
        row_idx += 1

    // Current Price & Distance
    price_arrow = close >= close[1] ? '▲ ' : '▼ '
    price_color = close >= close[1] ? color_up : color_down
    table.cell(statTable, 0, row_idx, price_arrow + str.tostring(close, '#.##'), text_color = price_color, text_size = tableTextSize, width = w_col0)
    table.cell(statTable, 1, row_idx, str.tostring(price_diff_ema1, '#.##') + '\n(' + str.tostring(price_pct_ema1, '#.##') + '%)', text_color = price_diff_ema1 >= 0 ? color_up : color_down, text_size = tableTextSize, width = w_col1)
    table.cell(statTable, 2, row_idx, str.tostring(price_diff_ema3, '#.##') + '\n(' + str.tostring(price_pct_ema3, '#.##') + '%)', text_color = price_diff_ema3 >= 0 ? color_up : color_down, text_size = tableTextSize, width = w_col2)
    table.cell(statTable, 3, row_idx, '-', text_color = text_main, text_size = tableTextSize, width = w_col3)
    row_idx += 1
    
    // Max Diff
    table.cell(statTable, 0, row_idx, 'Max Diff', text_color = text_main, text_size = tableTextSize, width = w_col0)
    table.cell(statTable, 1, row_idx, str.tostring(max_ema1, '#.##'), text_color = colorEma1, text_size = tableTextSize, width = w_col1)
    table.cell(statTable, 2, row_idx, str.tostring(max_ema3, '#.##'), text_color = colorEma3, text_size = tableTextSize, width = w_col2)
    table.cell(statTable, 3, row_idx, str.tostring(max_diff_price, '#.##') + '\n(' + str.tostring(max_diff_pct, '#.##') + '%)', text_color = max_diff_pct >= 0 ? color_up : color_down, text_size = tableTextSize, width = w_col3)
    row_idx += 1
    
    // Min Diff
    table.cell(statTable, 0, row_idx, 'Min Diff', text_color = text_main, text_size = tableTextSize, width = w_col0)
    table.cell(statTable, 1, row_idx, str.tostring(min_ema1, '#.##'), text_color = colorEma1, text_size = tableTextSize, width = w_col1)
    table.cell(statTable, 2, row_idx, str.tostring(min_ema3, '#.##'), text_color = colorEma3, text_size = tableTextSize, width = w_col2)
    table.cell(statTable, 3, row_idx, str.tostring(min_diff_price, '#.##') + '\n(' + str.tostring(min_diff_pct, '#.##') + '%)', text_color = min_diff_pct >= 0 ? color_up : color_down, text_size = tableTextSize, width = w_col3)
````
