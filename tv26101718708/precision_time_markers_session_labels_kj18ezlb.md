# Precision Time Markers & Session Labels

- url: https://www.tradingview.com/script/kJ18EZLb-Precision-Time-Markers-Session-Labels/
- type: indicator
- pine_id: PUB;0ccc0e7cf68f45aaa563bb29b2c2670c
- version: 1.0

## Description

Precision Time Markers & Session Labels [Balanced]

[b]Overview[/b]
This indicator is designed for intraday traders (SMC, ICT, or Session traders) who need to visualize specific time-based opens and events without cluttering their charts. It draws vertical lines and labels at user-defined times, such as the Midnight Open, London Open, and New York Sessions.

The standout feature of this script is the Balanced Vertical Offset. Unlike standard scripts where labels might overlap candles or appear too far away depending on the asset, this script calculates the optimal label height to ensure perfect visibility whether you are trading BTCUSD, Gold, or EURUSD.

[b]Key Features[/b]
6 Fully Customizable Time Slots: Pre-configured for Midnight Open, London Open, and Daily Close, with three additional "Extra" slots for your own custom times.

[b]Intelligent Label Positioning:[/b] Uses yloc.abovebar and price-based offsets to ensure labels stay clear of the price action.
[b]
Smart Timeframe Visibility:[/b] Labels automatically hide on timeframes higher than 30 minutes. This keeps your 1H, 4H, and Daily charts clean while providing precision on your execution timeframes (1m, 5m, 15m).

[b]Universal Scaling:[/b] The vertical spacing is balanced to look consistent across all asset classes, regardless of price decimals or volatility.

[b]How to Use[/b]
Set Your Times: Open the settings menu and input the specific Hour and Minute for the levels you want to track.

[b]Customize Labels: [/b]Change the text labels (e.g., "NY OPEN", "KILLZONE") and colors to match your personal trading template.

[b]Adjust Offsets: [/b]If the labels are too close or too far from the candles, adjust the Vertical Offset in the settings.

[b]Settings Explained[/b]
Show Line: Toggle individual time markers on or off.

[b]Hour/Minute:[/b] The exact time the line will trigger (based on your chart's exchange time).

[b]Label Text:[/b] The text that appears at the top of the vertical line.

[b]Color: [/b]Customize the color for both the line and the label for quick visual recognition.

This script is optimized for performance and uses the label.new logic to bypass the const string limitations of standard plotshapes, allowing you full control over your label text directly from the UI.

Disclaimer: This indicator is a visual aid and does not constitute financial advice. Always test your strategy in a paper trading environment before risking capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jasiremail

//@version=5
indicator("Custom Time Lines & Labels", overlay=true, max_lines_count=500, max_labels_count=500)

// --- HELPER LOGIC ---
is_time(h, m) => hour == h and minute == m
can_show_labels = timeframe.isintraday and timeframe.multiplier <= 30

// --- INPUTS FOR LINES ---
// Line 1
show1 = input.bool(true, title="Mid Night Open", group="Line 1")
h1    = input.int(0, title="Hour", group="Line 1")
m1    = input.int(0, title="Minute", group="Line 1")
txt1  = input.string("OPEN", title="Label Text", group="Line 1")
col1  = input.color(color.blue, title="Color", group="Line 1")

// Line 2
show2 = input.bool(true, title="London Open", group="Line 2")
h2    = input.int(8, title="Hour", group="Line 2")
m2    = input.int(30, title="Minute", group="Line 2")
txt2  = input.string("08:30", title="Label Text", group="Line 2")
col2  = input.color(color.rgb(0, 0, 250), title="Color", group="Line 2")

// Line 3
show3 = input.bool(false, title="New York Open", group="Line 3")
h3    = input.int(9, title="Hour", group="Line 3")
m3    = input.int(30, title="Minute", group="Line 3")
txt3  = input.string("9:30", title="Label Text", group="Line 3")
col3  = input.color(color.rgb(43, 1, 255), title="Color", group="Line 3")

// Line 4
show4 = input.bool(true, title="CLOSE", group="Line 4")
h4    = input.int(12, title="Hour", group="Line 4")
m4    = input.int(30, title="Minute", group="Line 4")
txt4  = input.string("CLOSE", title="Label Text", group="Line 4")
col4  = input.color(color.rgb(251, 46, 0), title="Color", group="Line 4")

// Line 5
show5 = input.bool(false, title="Extra Line 1", group="Line 5")
h5    = input.int(15, title="Hour", group="Line 5")
m5    = input.int(30, title="Minute", group="Line 5")
txt5  = input.string("EXTRA 1", title="Label Text", group="Line 5")
col5  = input.color(color.purple, title="Color", group="Line 5")

// Line 6
show6 = input.bool(false, title="Extra Line 2", group="Line 6")
h6    = input.int(16, title="Hour", group="Line 6")
m6    = input.int(0, title="Minute", group="Line 6")
txt6  = input.string("NY CLOSE", title="Label Text", group="Line 6")
col6  = input.color(color.orange, title="Color", group="Line 6")

// --- DRAWING FUNCTION ---
// We use a function to handle both the Line and the Label at once
draw_all(show, h, m, txt, col) =>
    if show and is_time(h, m)
        // Vertical Line
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=col, width=1)
        
        // Label (Replacement for plotshape)
        if can_show_labels
            label.new(
                 x         = bar_index, 
                 y         = na, 
                 text      = txt, 
                 yloc      = yloc.abovebar, // Forces label above the candle wicks
                 color     = color.new(color.white, 100), // Makes background transparent
                 textcolor = col, 
                 style     = label.style_none, 
                 size      = size.small
                 )

// --- EXECUTION ---
draw_all(show1, h1, m1, txt1, col1)
draw_all(show2, h2, m2, txt2, col2)
draw_all(show3, h3, m3, txt3, col3)
draw_all(show4, h4, m4, txt4, col4)
draw_all(show5, h5, m5, txt5, col5)
draw_all(show6, h6, m6, txt6, col6)
````
