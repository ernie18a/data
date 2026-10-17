# Event Marker (20 Events)

- url: https://www.tradingview.com/script/1MEWPvsR-Event-Marker-20-Events/
- type: indicator
- pine_id: PUB;ad54a92ef4d24ca3b059fed02b996df7
- version: 1.0

## Description

Dear User,

This script helps you to mark custom events of your choice to study its effects. Select date and time of events you want and the indicator will draw vertical lines of selected color and place your text / comments / event name on labels.

Script has been made with the help of ChatGPT and hence:

1. It has a lot of scope for improvement - suggestions are welcome
2. It is published as open source since there is very less effort involved in writing the script

Regards,
Team Optimismo

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Optimismo_Services

//@version=5
indicator("Event Marker (20 Events FIXED)", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================
// FUNCTION
// ==========================
f_draw(_date, _text, _color) =>
    if (time >= _date and time[1] < _date)
        // Draw vertical line
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=_color, width=2)

        // Convert text to vertical (stacked)
        var string v_text = ""
        v_text := ""
        for i = 0 to str.length(_text) - 1
            v_text += str.substring(_text, i, i + 1) + "\n"

        // Move label above candle
        y_pos = high + (high - low) * 2

        // ONE LINE label (no syntax error)
        label.new(bar_index, y_pos, v_text, color=_color, textcolor=color.white, style=label.style_label_down, textalign=text.align_center)
// ==========================
// EVENTS (CONST TIMESTAMPS)
// ==========================

// IMPORTANT: These are default values — you can change from UI

e1_date  = input.time(defval = 1640995200000, title="Event 1 Date")
e1_text  = input.string("Event 1", "Event 1 Text")
e1_color = input.color(color.red, "Event 1 Color")

e2_date  = input.time(defval = 1640995200000, title="Event 2 Date")
e2_text  = input.string("Event 2", "Event 2 Text")
e2_color = input.color(color.blue, "Event 2 Color")

e3_date  = input.time(defval = 1640995200000, title="Event 3 Date")
e3_text  = input.string("Event 3", "Event 3 Text")
e3_color = input.color(color.green, "Event 3 Color")

e4_date  = input.time(defval = 1640995200000, title="Event 4 Date")
e4_text  = input.string("Event 4", "Event 4 Text")
e4_color = input.color(color.orange, "Event 4 Color")

e5_date  = input.time(defval = 1640995200000, title="Event 5 Date")
e5_text  = input.string("Event 5", "Event 5 Text")
e5_color = input.color(color.purple, "Event 5 Color")

e6_date  = input.time(defval = 1640995200000, title="Event 6 Date")
e6_text  = input.string("Event 6", "Event 6 Text")
e6_color = input.color(color.yellow, "Event 6 Color")

e7_date  = input.time(defval = 1640995200000, title="Event 7 Date")
e7_text  = input.string("Event 7", "Event 7 Text")
e7_color = input.color(color.aqua, "Event 7 Color")

e8_date  = input.time(defval = 1640995200000, title="Event 8 Date")
e8_text  = input.string("Event 8", "Event 8 Text")
e8_color = input.color(color.fuchsia, "Event 8 Color")

e9_date  = input.time(defval = 1640995200000, title="Event 9 Date")
e9_text  = input.string("Event 9", "Event 9 Text")
e9_color = input.color(color.gray, "Event 9 Color")

e10_date  = input.time(defval = 1640995200000, title="Event 10 Date")
e10_text  = input.string("Event 10", "Event 10 Text")
e10_color = input.color(color.maroon, "Event 10 Color")

// Repeat same pattern for 11–20 (copy-paste safe)

e11_date = input.time(defval = 1640995200000, title="Event 11 Date")
e11_text = input.string("Event 11", "Event 11 Text")
e11_color = input.color(color.red, "Event 11 Color")

e12_date = input.time(defval = 1640995200000, title="Event 12 Date")
e12_text = input.string("Event 12", "Event 12 Text")
e12_color = input.color(color.blue, "Event 12 Color")

e13_date = input.time(defval = 1640995200000, title="Event 13 Date")
e13_text = input.string("Event 13", "Event 13 Text")
e13_color = input.color(color.green, "Event 13 Color")

e14_date = input.time(defval = 1640995200000, title="Event 14 Date")
e14_text = input.string("Event 14", "Event 14 Text")
e14_color = input.color(color.orange, "Event 14 Color")

e15_date = input.time(defval = 1640995200000, title="Event 15 Date")
e15_text = input.string("Event 15", "Event 15 Text")
e15_color = input.color(color.purple, "Event 15 Color")

e16_date = input.time(defval = 1640995200000, title="Event 16 Date")
e16_text = input.string("Event 16", "Event 16 Text")
e16_color = input.color(color.yellow, "Event 16 Color")

e17_date = input.time(defval = 1640995200000, title="Event 17 Date")
e17_text = input.string("Event 17", "Event 17 Text")
e17_color = input.color(color.aqua, "Event 17 Color")

e18_date = input.time(defval = 1640995200000, title="Event 18 Date")
e18_text = input.string("Event 18", "Event 18 Text")
e18_color = input.color(color.fuchsia, "Event 18 Color")

e19_date = input.time(defval = 1640995200000, title="Event 19 Date")
e19_text = input.string("Event 19", "Event 19 Text")
e19_color = input.color(color.gray, "Event 19 Color")

e20_date = input.time(defval = 1640995200000, title="Event 20 Date")
e20_text = input.string("Event 20", "Event 20 Text")
e20_color = input.color(color.black, "Event 20 Color")

// ==========================
// DRAW
// ==========================
f_draw(e1_date, e1_text, e1_color)
f_draw(e2_date, e2_text, e2_color)
f_draw(e3_date, e3_text, e3_color)
f_draw(e4_date, e4_text, e4_color)
f_draw(e5_date, e5_text, e5_color)
f_draw(e6_date, e6_text, e6_color)
f_draw(e7_date, e7_text, e7_color)
f_draw(e8_date, e8_text, e8_color)
f_draw(e9_date, e9_text, e9_color)
f_draw(e10_date, e10_text, e10_color)

f_draw(e11_date, e11_text, e11_color)
f_draw(e12_date, e12_text, e12_color)
f_draw(e13_date, e13_text, e13_color)
f_draw(e14_date, e14_text, e14_color)
f_draw(e15_date, e15_text, e15_color)
f_draw(e16_date, e16_text, e16_color)
f_draw(e17_date, e17_text, e17_color)
f_draw(e18_date, e18_text, e18_color)
f_draw(e19_date, e19_text, e19_color)
f_draw(e20_date, e20_text, e20_color)
````
