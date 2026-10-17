# Custom Session & Entry Timings

- url: https://www.tradingview.com/script/TQkJ17V1-Custom-Session-Entry-Timings/
- type: indicator
- pine_id: PUB;5174ad8185f94d3888dc46ff1fd19ab9
- version: 1.0

## Description

Entry Timings  Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings Entry Timings

## Source Code

````pine
//@version=5
indicator("Custom Session & Entry Timings", overlay=true)

// =========================================================================
// 1. TIMEZONE & HELPER FUNCTIONS
// =========================================================================
tz = input.string("Asia/Kolkata", title="Timezone", group="Time Settings")

in_session(sess) =>
    not na(time(timeframe.period, sess, tz))

is_exact_time(time_str) =>
    in_session(time_str) and not in_session(time_str)[1]

// =========================================================================
// 2. ENTRY WINDOWS & RANGES (TIMINGS & TOGGLES)
// =========================================================================
asianEntryGold = input.session("0530-0730", title="Asian Entry (Gold)", group="Entry Windows")
asianEntryFX   = input.session("0530-0830", title="Asian Entry (FX)", group="Entry Windows")
londonEntry    = input.session("1130-1430", title="London Entry", group="Entry Windows")
londonLunch    = input.session("1430-1630", title="London Lunch", group="Entry Windows")
nyEntry        = input.session("1630-1930", title="NY Entry", group="Entry Windows")
deadVolume     = input.session("2230-0230", title="Dead Volume Range", group="Entry Windows")

showAsianFX    = input.bool(true, title="Show Asian Entry (FX)", group="Entry Windows")
showLondon     = input.bool(true, title="Show London Entry", group="Entry Windows")
showNY         = input.bool(true, title="Show NY Entry", group="Entry Windows")
showLunch      = input.bool(false, title="Show London Lunch", group="Entry Windows")
showDeadVol    = input.bool(false, title="Show Dead Volume", group="Entry Windows")

// =========================================================================
// 3. COLOR INPUTS (FOR EASY HOVER & CHANGE)
// =========================================================================
colAsian = input.color(color.new(color.blue, 90), title="Asian Entry Color", group="Background Colors")
colLondon = input.color(color.new(color.green, 90), title="London Entry Color", group="Background Colors")
colNY = input.color(color.new(color.red, 90), title="NY Entry Color", group="Background Colors")
colLunch = input.color(color.new(color.gray, 90), title="London Lunch Color", group="Background Colors")
colDead = input.color(color.new(color.black, 90), title="Dead Volume Color", group="Background Colors")

// Apply background colors based on your selection
bgcolor(showAsianFX and in_session(asianEntryFX) ? colAsian : na, title="Asian FX Bg")
bgcolor(showLondon and in_session(londonEntry) ? colLondon : na, title="London Entry Bg")
bgcolor(showNY and in_session(nyEntry) ? colNY : na, title="NY Entry Bg")
bgcolor(showLunch and in_session(londonLunch) ? colLunch : na, title="London Lunch Bg")
bgcolor(showDeadVol and in_session(deadVolume) ? colDead : na, title="Dead Volume Bg")

// =========================================================================
// 4. SPECIFIC TIMESTAMPS (VERTICAL LINES & LABELS)
// =========================================================================
showLines = input.bool(true, title="Show Session Open/Close Lines", group="Key Timestamps")

draw_timestamp(time_str, label_text, line_color) =>
    if showLines and is_exact_time(time_str)
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(line_color, 40), style=line.style_dashed)
        label.new(bar_index, high, label_text, textcolor=line_color, style=label.style_label_down, color=color.new(color.white, 100), size=size.small)

draw_timestamp("0230-0231", "Daily Open FX\n(2:30 AM)", color.blue)
draw_timestamp("0330-0331", "Daily Open Gold\n(3:30 AM)", color.orange)
draw_timestamp("0430-0431", "Asia Start\n(4:30 AM)", color.blue)
draw_timestamp("0930-0931", "Asian Range Ends\n(9:30 AM)", color.gray)
draw_timestamp("1230-1231", "London Open\n(12:30 PM)", color.green)
draw_timestamp("1730-1731", "NY Open\n(5:30 PM)", color.red)
draw_timestamp("1900-1901", "NYSE\n(7:00 PM)", color.purple)
draw_timestamp("2030-2031", "London Close\n(8:30 PM)", color.green)
draw_timestamp("2130-2131", "Gold Extra Hr\n(9:30 PM)", color.orange)
````
