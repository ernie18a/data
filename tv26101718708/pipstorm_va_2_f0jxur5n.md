# Pipstorm VA 2

- url: https://www.tradingview.com/script/F0Jxur5N-Pipstorm-VA-2/
- type: indicator
- pine_id: PUB;17f1283a52f4491ba64372dd2e7aeb31
- version: 1.0

## Description

An intra-day trading indicator that automatically identifies the high and low boundaries of the early market session.
It features a central shaded balance zone using a grey rectangle box to assist with entries and risk management.

## Source Code

````pine
//@version=6
indicator("Pipstorm VA 2", overlay=true, max_lines_count=500, max_boxes_count=500)

// --- ഇൻപുട്ടുകൾ ---
var string TIME_ZONE = "Asia/Kolkata"

// സമയം നിശ്ചയിക്കുന്നു (IST)
in_range_window    = not na(time(timeframe.period, "0530-0630:23456", TIME_ZONE))
in_extended_window = not na(time(timeframe.period, "0530-1830:23456", TIME_ZONE))
is_new_day         = ta.change(time("D", TIME_ZONE)) != 0

// --- വേരിയബിളുകൾ ---
var float session_high = na
var float session_low  = na
var int range_start_bar = na

// ദിവസേനയുള്ള ലൈനുകളും ബോക്സുകളും വരയ്ക്കാൻ
var line high_line = na
var line low_line  = na
var line fib25_line = na
var line fib75_line = na
var box  fib_box   = na

var int breakout_bar_index = na
var bool is_broken = false

// --- പുതിയ ദിവസം വരുമ്പോൾ റീസെറ്റ് ചെയ്യുക ---
if is_new_day
    session_high := na
    session_low  := na
    range_start_bar := na
    is_broken    := false
    breakout_bar_index := na
    high_line  := na
    low_line   := na
    fib25_line := na
    fib75_line := na
    fib_box    := na

// --- 5:30 - 6:30 റേഞ്ച് കണ്ടെത്തുന്നു ---
if in_range_window
    if na(session_high) or high > session_high
        session_high := high
    if na(session_low) or low < session_low
        session_low := low
    if na(range_start_bar)
        range_start_bar := bar_index

// --- 6:30 PM വരെയുള്ള കാൻഡിലുകൾ കണ്ടെത്തുന്നു ---
// നിലവിലെ ടൈംഫ്രെയിം അനുസരിച്ച് 18:30 (6:30 PM) വരെയുള്ള ദൂരം കൃത്യമായി ലൈൻ നീട്ടാൻ
var int end_bar_index = na
if in_extended_window
    end_bar_index := bar_index

// 6:30 AM-ന് ശേഷം മാത്രം ലൈനുകൾ വരയ്ക്കാൻ വേണ്ടിയുള്ള കണ്ടീഷൻ
is_range_ready = not na(time(timeframe.period, "0630-1830:23456", TIME_ZONE))

// --- ലൈനുകളും ഫിബൊനാച്ചി ബോക്സും വരയ്ക്കുന്നു ---
if is_range_ready and not na(session_high) and not na(session_low) and in_extended_window
    diff = session_high - session_low
    fib_25 = session_low + (diff * 0.25)
    fib_75 = session_low + (diff * 0.75)
    
    // ടൈം ഒഴിവാക്കി കാൻഡിൽ ഇൻഡെക്സ് (bar_index) ഉപയോഗിച്ച് ലൈൻ വരയ്ക്കുന്നു (ഇത് വഴി ലൈൻ വലത്തോട്ട് നീണ്ടുനിൽക്കും)
    if na(high_line)
        high_line  := line.new(x1=range_start_bar, y1=session_high, x2=bar_index, y2=session_high, xloc=xloc.bar_index, color=color.black, width=1)
        low_line   := line.new(x1=range_start_bar, y1=session_low,  x2=bar_index, y2=session_low,  xloc=xloc.bar_index, color=color.black, width=1)
        fib25_line := line.new(x1=range_start_bar, y1=fib_25,       x2=bar_index, y2=fib_25,       xloc=xloc.bar_index, color=color.black, width=1)
        fib75_line := line.new(x1=range_start_bar, y1=fib_75,       x2=bar_index, y2=fib_75,       xloc=xloc.bar_index, color=color.black, width=1)
        
        // ഫിബൊനാച്ചി ഗ്രേ ബോക്സ്
        fib_box    := box.new(left=range_start_bar, top=fib_75, right=bar_index, bottom=fib_25, xloc=xloc.bar_index, bgcolor=color.new(color.gray, 85), border_color=color.new(color.white, 100))
    else
        // ഓരോ പുതിയ കാൻഡിൽ വരുമ്പോഴും ലൈൻ കൃത്യമായി വലത്തോട്ട് നീട്ടുന്നു (6:30 PM വരെ മാത്രം)
        line.set_x2(high_line, bar_index)
        line.set_x2(low_line, bar_index)
        line.set_x2(fib25_line, bar_index)
        line.set_x2(fib75_line, bar_index)
        box.set_right(fib_box, bar_index)
        
        // ലൈനുകളുടെ വിലകൾ കൃത്യമായി പുതുക്കുന്നു
        line.set_y1(high_line, session_high)
        line.set_y2(high_line, session_high)
        line.set_y1(low_line, session_low)
        line.set_y2(low_line, session_low)
        line.set_y1(fib25_line, fib_25)
        line.set_y2(fib25_line, fib_25)
        line.set_y1(fib75_line, fib_75)
        line.set_y2(fib75_line, fib_75)
        box.set_top(fib_box, fib_75)
        box.set_bottom(fib_box, fib_25)

// --- ബ്രേക്ക്ഔട്ട് കാൻഡിൽ കണ്ടെത്തൽ ---
if is_range_ready and not is_broken and not na(session_high) and not na(session_low)
    if high > session_high
        is_broken := true
        breakout_bar_index := bar_index
    else if low < session_low
        is_broken := true
        breakout_bar_index := bar_index

// ആദ്യം ബ്രേക്ക് ചെയ്യുന്ന കാൻഡിലിന് മാത്രം ഡാർക്ക് ബ്ലൂ കളർ നൽകുന്നു
is_breakout_candle = (bar_index == breakout_bar_index)
barcolor(is_breakout_candle ? color.blue : na)
````
