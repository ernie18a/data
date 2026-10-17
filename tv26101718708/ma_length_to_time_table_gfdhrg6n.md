# MA Length to Time Table

- url: https://www.tradingview.com/script/GfDHRG6n-MA-Length-to-Time-Table/
- type: indicator
- pine_id: PUB;bbc0b7a97a1c4d3faa2c67c9ce7c5350
- version: 1.0

## Description

"MA Length to Time Table" is a simple but very practical Pine Script indicator that displays a clean table converting Moving Average lengths into approximate real-world time (seconds, minutes, hours, or days) based on the current chart timeframe.It starts from a Base Length (default 32) and doubles it each row:32 → 64 → 128 → 256 → 512 → 1024 → 2048 → 4096

For each length, it shows: The MA period (number of bars)
The equivalent time duration on the current timeframe

 Main Use CasesUse Case
Why It's Useful
Choosing the right MA length
Quickly see that a 200 MA on a 5m chart ≈ 16.7 hours, or on a 1H chart ≈ 8.3 days
Multi-timeframe awareness
Understand how "long-term" an MA really is on your current chart
Strategy building & backtesting
Match MA periods to meaningful time horizons (e.g. 1-week, 1-month, quarterly)
Swing & Position Trading
Find MA lengths that represent 1 week, 1 month, 3 months, etc.
Educational / Learning
Helps new traders grasp the real temporal meaning behind MA periods
Quick reference
No need to manually calculate length × timeframe every time

Practical ExamplesOn 5-minute chart: 256 MA ≈ 21.3 hours (almost one full trading day)
On 1-hour chart: 168 MA ≈ 7 days (one week)
On Daily chart: 90 MA ≈ 3 months

This indicator is especially loved by traders who use multiple moving averages or want to align their indicators with actual calendar time rather than just bar counts.Very lightweight and useful as a supporting tool on any chart.

## Source Code

````pine
//@version=6
indicator("MA Length to Time Table", overlay = false, max_labels_count = 500)

// ── INPUTS ───────────────────────────────────────────────────────────────
base_length = input.int(32, "Base Length", minval=1, group="Table Settings")
show_table  = input.bool(true, "Show Table", group="Table Settings")

// Table position and style
table_position = input.string("Bottom Left", "Table Position", 
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], 
     group="Table Settings")

// ── TIME CONVERSION FUNCTION ─────────────────────────────────────────────
bars_to_time(int bars) =>
    float seconds = bars * timeframe.in_seconds()
    if seconds < 60
        str.tostring(seconds, "#.##") + "s"
    else if seconds < 3600
        str.tostring(seconds / 60, "#.##") + "m"
    else if seconds < 86400
        str.tostring(seconds / 3600, "#.##") + "h"
    else
        str.tostring(seconds / 86400, "#.##") + "d"

// ── COLOR FUNCTION ───────────────────────────────────────────────────────
get_color(int level) =>level == 1 ? #90bff9 :level == 2 ? #ff9800 :level == 3 ? #fbff00 :level == 4 ? #6bf806 :level == 5 ? #3179f5 :level == 6 ? #7e57c2 :level == 7 ? #ff0022 : #ffffff

// ── TABLE SETUP ──────────────────────────────────────────────────────────
var table time_table = table.new(
     position = table_position == "Top Left" ? position.top_left :
                table_position == "Top Right" ? position.top_right :
                table_position == "Bottom Right" ? position.bottom_right :
                table_position == "Middle Left" ? position.middle_left :
                table_position == "Middle Right" ? position.middle_right :
                position.bottom_left,
     columns = 2, 
     rows = 9, 
     bgcolor = #1e1e1e, 
     border_width = 1, 
     frame_color = #363636
)

// ── FILL TABLE ───────────────────────────────────────────────────────────
if barstate.islast and show_table
    // Header
    table.cell(time_table, 0, 0, "MA Length", text_color=#ffffff, text_size=size.small)
    table.cell(time_table, 1, 0, "Approx. Time", text_color=#ffffff, text_size=size.small)

    int len = base_length
    for i = 1 to 8
        table.cell(time_table, 0, i, str.tostring(len), text_color = get_color(i), text_size = size.small)
        table.cell(time_table, 1, i, bars_to_time(len), text_color = color.white, text_size = size.small)
        len := len * 2
````
