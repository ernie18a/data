# Bitcoin 4-Year Cycle Lookback Marker

- url: https://www.tradingview.com/script/WzLqn0Tj-Bitcoin-4-Year-Cycle-Lookback-Marker/
- type: indicator
- pine_id: PUB;0e059005158744789aad83a0cd018228
- version: 2.0

## Description

Automatically plots a vertical marker at the bar occurring exactly N years ago (default: 4 years), allowing traders and investors to quickly locate and study historical market conditions, cycle lows, cycle highs, and key events from prior Bitcoin market cycles.

Full Description:
The Bitcoin 4-Year Cycle Lookback Marker is designed for cycle analysis and historical market research.

Instead of manually scrolling through years of price action, this indicator automatically places a vertical marker on the chart at a configurable lookback period, making it easy to compare current market conditions with prior cycle stages.

Features:
• Adjustable lookback period (default 4 years)
• Fine-tuning with day offsets
• Customizable marker color, width, and style
• Optional historical price and date labels
• Works across all chart timeframes
• Designed for Bitcoin cycle and halving-cycle analysis

Common Uses:
• Identify where Bitcoin traded four years ago today
• Compare current market structure to previous cycles
• Locate historical highs, lows, consolidations, and breakouts
• Study market behavior before and after halving events
• Build data-driven cycle frameworks

This indicator is intended as a research and educational tool and does not provide trading signals or financial advice.

## Source Code

````pine
//@version=6
indicator("Multi-Cycle History Markers", overlay=true, max_bars_back=5000)

// ── Inputs ────────────────────────────────────────────────────────────────────
cycle_years = input.float(4.0, "Cycle Length (years)", minval=0.25, maxval=20, step=0.25,
    tooltip="One marker every N years going backward")
max_cycles  = input.int(5, "How Many Cycles Back", minval=1, maxval=20,
    tooltip="Number of markers to draw (1 = just last cycle, 5 = last 5 cycles)")
offset_days = input.int(0, "Shift All (days +/-)", minval=-365, maxval=365)

line_col    = input.color(color.yellow, "Line Color")
line_w      = input.int(1, "Line Width", minval=1, maxval=5)
line_st     = input.string("dashed", "Line Style", options=["solid", "dashed", "dotted"])
show_label  = input.bool(true, "Show Date + Price Label")
label_size  = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"])

// ── Style helpers ─────────────────────────────────────────────────────────────
line_style = line_st == "dashed" ? line.style_dashed :
             line_st == "dotted" ? line.style_dotted : line.style_solid

lbl_size = label_size == "tiny"   ? size.tiny   :
           label_size == "normal" ? size.normal :
           label_size == "large"  ? size.large  : size.small

tf_secs = timeframe.in_seconds(timeframe.period)

// ── Persistent arrays for cleanup on each refresh ─────────────────────────────
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()

if barstate.islast
    // Wipe previous draws (guarded against empty arrays)
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
    array.clear(lines)
    array.clear(labels)

    // Draw one marker per cycle back
    for k = 1 to max_cycles
        bars_back = math.round((cycle_years * k * 365.25 + offset_days) * 86400.0 / tf_secs)
        target_bar = bar_index - bars_back

        if target_bar >= 0 and bars_back < bar_index
            t_time  = time[bars_back]
            t_high  = high[bars_back]
            t_low   = low[bars_back]
            t_open  = open[bars_back]
            t_close = close[bars_back]

            new_line = line.new(
                x1     = target_bar,
                y1     = t_low * 0.5,
                x2     = target_bar,
                y2     = t_high * 1.5,
                xloc   = xloc.bar_index,
                extend = extend.both,
                color  = line_col,
                style  = line_style,
                width  = line_w)
            array.push(lines, new_line)

            if show_label
                lbl_txt = str.format("-{0}Y ({1,date,yyyy-MM-dd})\nO:{2,number,#,###.##} H:{3,number,#,###.##}\nL:{4,number,#,###.##} C:{5,number,#,###.##}",
                    str.tostring(cycle_years * k, "#.##"), t_time, t_open, t_high, t_low, t_close)

                new_lbl = label.new(
                    x         = target_bar,
                    y         = t_high,
                    text      = lbl_txt,
                    xloc      = xloc.bar_index,
                    yloc      = yloc.price,
                    style     = label.style_label_down,
                    color     = color.new(line_col, 20),
                    textcolor = color.black,
                    size      = lbl_size)
                array.push(labels, new_lbl)
````
