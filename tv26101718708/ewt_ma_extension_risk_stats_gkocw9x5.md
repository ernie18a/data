# [EWT] MA Extension Risk Stats

- url: https://www.tradingview.com/script/gKOCW9X5-EWT-MA-Extension-Risk-Stats/
- type: indicator
- pine_id: PUB;6c32476eb8de4dd28c946d3a3f6a8087
- version: 1.0

## Description

[EWT] MA Extension Risk Stats helps traders objectively measure how extended a stock, index, or any instrument is relative to its own historical behavior from a moving average.

Instead of guessing whether price “looks high,” this indicator calculates the percentage distance of every historical bar from a configurable SMA or EMA and then displays the [b]Maximum, Mean, and Median[/b] deviations in a clean, updating table. By comparing the current deviation against these historical benchmarks, you get clear, data-driven context for profit booking decisions.

[b]Key Benefits[/b]
[list]
[*]Objective Extension Measurement: See exactly where the current price stands in the instrument’s historical distribution of moves away from its moving average.
[*]Better Profit Booking Decisions: Know whether the current extension is normal, moderate, high, or near the historical maximum — removing emotion from scaling out of positions.
[*]Risk Context at a Glance: Color-coded risk levels (Low / Moderate / High / Very High) combined with concise guidance help you quickly decide whether to book partial profits (30-50%) or exit most/all of a position.
[*]All-History Perspective: Unlike rolling-window tools, this indicator uses the entire available dataset on your chart, giving you a complete picture across different market regimes.
[*]Fully Customizable: Choose SMA or EMA, any period length, and position the compact table anywhere on the chart. The table automatically adapts to your light or dark chart theme for excellent readability.
[/list]

[b]Practical Use Cases[/b]
[list]
[*]Trend Following & Swing Trading: When price stretches far above its MA during a strong uptrend, use the stats to scale out systematically instead of hoping for more upside.
[*]Mean Reversion Setups: Identify when price has extended unusually far below its MA and prepare for potential bounces with better risk awareness.
[*]Position Management: Apply consistent rules such as “book 50% when current deviation exceeds 1.5× median” or “exit fully when approaching historical maximum.”
[*]Multi-Timeframe Analysis: Run it on daily charts for swing trades and weekly charts for positional decisions using the same logic.
[/list]

Whether you trade stocks, indices, forex, or crypto, [EWT] MA Extension Risk Stats gives you a professional, repeatable framework to manage extension risk and improve profit-taking discipline. It is especially valuable for traders who want to move from subjective “it looks extended” decisions to quantifiable, historically grounded rules.

Add it to your chart, adjust the MA period to match your style, and start making more confident, data-backed decisions on when to lock in profits.

## Source Code

````pine
//@version=6
indicator("[EWT] MA Extension Risk Stats", overlay=true, 
     shorttitle="MA-X-Risk", max_bars_back=5000)

// === INPUTS ===
ma_len        = input.int(50, "MA Period (Length)", minval=1, maxval=500, step=1)
ma_type       = input.string("SMA", "MA Type", options=["SMA", "EMA"])
show_ma       = input.bool(true, "Show MA Line on Chart")
ma_color      = input.color(color.new(color.blue, 0), "MA Line Color")
ma_lw         = input.int(2, "MA Line Width", minval=1, maxval=5)
table_pos_in  = input.string("Top Right", "Stats Table Position", 
                  options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"])

// === MOVING AVERAGE ===
ma = ma_type == "SMA" ? ta.sma(close, ma_len) : ta.ema(close, ma_len)

// === HISTORICAL DEVIATION ACCUMULATORS ===
var float sum_dev     = 0.0
var float max_dev     = 0.0
var int   valid_bars  = 0
var array<float> deviations = array.new_float()
var float median_dev  = na
var table stats_table = na

float dev = na
if not na(ma) and ma != 0
    dev := math.abs(close - ma) / ma * 100.0
    sum_dev     += dev
    max_dev     := math.max(max_dev, dev)
    valid_bars  += 1
    array.push(deviations, dev)

// === COMPACT TABLE (only on last bar) ===
if barstate.islast and valid_bars > 0
    float mean_dev = sum_dev / valid_bars

    // Median (computed only once per bar update)
    float med = na
    if array.size(deviations) > 0
        sorted_devs = array.copy(deviations)
        array.sort(sorted_devs)
        int n   = array.size(sorted_devs)
        int mid = int(n / 2)
        if n % 2 == 1
            med := array.get(sorted_devs, mid)
        else if n >= 2
            med := (array.get(sorted_devs, mid - 1) + array.get(sorted_devs, mid)) / 2.0
    median_dev := med

    // Risk level
    string risk_text  = "Low - Typical Range"
    color  risk_color = color.new(color.lime, 0)
    if dev > max_dev * 0.90
        risk_text  := "Very High - Near Hist Max"
        risk_color := color.new(color.red, 0)
    else if dev > mean_dev * 2.0 or dev > median_dev * 3.0
        risk_text  := "High - Significantly Extended"
        risk_color := color.new(color.orange, 0)
    else if dev > median_dev * 1.5
        risk_text  := "Moderate - Above Median"
        risk_color := color.new(color.yellow, 0)

    // Table position
    table_position = switch table_pos_in
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        => position.top_right

    if na(stats_table)
        stats_table := table.new(table_position, 2, 7,
             bgcolor     = color.new(chart.bg_color, 18),
             frame_color = color.new(chart.fg_color, 55),
             frame_width = 1)

    // Row 0: MA + Bars combined (compact)
    table.cell(stats_table, 0, 0, "MA & Data", text_color = chart.fg_color)
    table.cell(stats_table, 1, 0, ma_type + "(" + str.tostring(ma_len) + ") • " + str.tostring(valid_bars) + " bars", 
        text_color = chart.fg_color, text_halign = text.align_right)

    // Row 1: Current
    table.cell(stats_table, 0, 1, "Current %", text_color = chart.fg_color)
    table.cell(stats_table, 1, 1, str.tostring(dev, "#.##") + "%", 
        text_color = risk_color, text_halign = text.align_right)

    // Row 2: Max
    table.cell(stats_table, 0, 2, "Max % (Hist)", text_color = chart.fg_color)
    table.cell(stats_table, 1, 2, str.tostring(max_dev, "#.##") + "%", 
        text_color = chart.fg_color, text_halign = text.align_right)

    // Row 3: Mean
    table.cell(stats_table, 0, 3, "Mean %", text_color = chart.fg_color)
    table.cell(stats_table, 1, 3, str.tostring(mean_dev, "#.##") + "%", 
        text_color = chart.fg_color, text_halign = text.align_right)

    // Row 4: Median
    table.cell(stats_table, 0, 4, "Median %", text_color = chart.fg_color)
    table.cell(stats_table, 1, 4, str.tostring(median_dev, "#.##") + "%", 
        text_color = chart.fg_color, text_halign = text.align_right)

    // Row 5: Risk Level
    table.cell(stats_table, 0, 5, "Risk Level", text_color = chart.fg_color)
    table.cell(stats_table, 1, 5, risk_text, text_color = risk_color, 
        text_halign = text.align_right)

    // Row 6: Compact Guidance
    table.cell(stats_table, 0, 6, "Guidance", text_color = chart.fg_color)
    guidance = risk_text == "Low - Typical Range" ? "Hold / add on dips" : 
               risk_text == "Moderate - Above Median" ? "Consider 30-50% partial booking" : 
               risk_text == "High - Significantly Extended" ? "Book majority • wait for pullback" : 
               "Book most/all • high extension risk"
    table.cell(stats_table, 1, 6, guidance, text_color = chart.fg_color, text_halign = text.align_left)

// === PLOT MA ===
plot(show_ma ? ma : na, "MA", color=ma_color, linewidth=ma_lw)
````
