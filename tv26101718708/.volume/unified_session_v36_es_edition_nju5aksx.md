# Unified Session V3.6 - (ES Edition)

- url: https://www.tradingview.com/script/NJu5akSX-Unified-Session-V3-6-ES-Edition/
- type: indicator
- pine_id: PUB;3a2d99f554f346b3b003c25a4b72bf8b
- version: 1.0

## Description

Sessions and markers with statistical data for ES Futures. Sessions VWAP

## Source Code

````pine
//@version=5
indicator("Unified Session V3.6 - Asia Extended (ES Edition)", overlay=true, max_boxes_count=500)

// --- Settings Adjusted for UTC+2 ---
asia_sess   = input.session("0200-1000", "Asian Session (JP/AU)") // Extended to 10:00
london_sess = input.session("0900-1730", "London Session")
ny_sess     = input.session("1530-2200", "NY Session")
ib_len      = input.int(15, "IB Duration (Minutes)", minval=1)

// --- Style Settings ---
ib_thickness = input.int(2, "IB Rectangle Thickness", minval=1)
color_asia   = input.color(#FFEB3B, "Asia Color")
color_london = input.color(#03A9F4, "London Color")
color_ny_in  = input.color(#9C27B0, "NY Color")
bg_opacity   = input.int(95, "Background Transparency", minval=0, maxval=100)
color_bench  = input.color(#00008B, "Benchmark Color (Dark Blue)")

// --- Benchmarks (Daily, Weekly & EQ) ---
pd_high  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_low   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pd_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
d_open   = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
pw_high  = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pw_low   = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pd_eq    = (pd_high + pd_low) / 2

plot_level(level, txt, is_eq=false) =>
    var line l = na, var label lb = na
    line.delete(l), label.delete(lb)
    l_style = is_eq ? line.style_dashed : line.style_dotted 
    l  := line.new(bar_index - 5, level, bar_index + 15, level, xloc=xloc.bar_index, style=l_style, color=color_bench, width=1)
    lb := label.new(bar_index + 16, level, txt, xloc=xloc.bar_index, style=label.style_none, textcolor=color_bench, size=size.small, textalign=text.align_left)

plot_level(pd_high, "pdHigh"), plot_level(pd_low, "pdLow"), plot_level(pd_close, "pdClose"), plot_level(d_open, "dOpen")
plot_level(pw_high, "wHigh"), plot_level(pw_low, "wLow")
plot_level(pd_eq, "pdEQ", true)

// --- Time & Session Logic (Berlin UTC+2) ---
in_sess(s) => not na(time(timeframe.period, s, "UTC+2")) 
bool inA = in_sess(asia_sess), bool inL = in_sess(london_sess), bool inN = in_sess(ny_sess)

// --- Pivot Markers Function ---
is_time(h, m) => hour(time, "UTC+2") == h and minute(time, "UTC+2") == m
plot_shift(h, m, txt, hover_msg) =>
    if is_time(h, m) and timeframe.isintraday
        label.new(bar_index, high, "⏳\n" + txt, yloc=yloc.abovebar, color=color.new(color.white, 100), textcolor=color.new(color.white, 50), style=label.style_none, size=size.small, tooltip=hover_msg)

// --- INTRADAY TIMELINE MARKERS (Shifted 30 Mins Forward for Prep) ---
plot_shift(2, 30, "Late Asia Prep",     "Upcoming: Late Asia / Early Europe (03:00 - 08:00)\nPattern: Slow accumulation period.")
plot_shift(7, 30, "EU Open Prep",        "Upcoming: Tokyo Close / Frankfurt Open (08:00)\nPattern: Tokyo liquidity leaves. Strong move starting, often faded or retraced later.")
plot_shift(11, 0, "Pre-NY Lull Prep",   "Upcoming: Europe/Pre-NY (11:30 - 15:30)\nPattern: Market slows down before US open. Ranging environment, heavy retail fakeouts.")
plot_shift(14, 0, "Macro Data Prep",    "Upcoming: US Macro Data Drop (14:30)\nPattern: CPI, NFP, GDP releases. High volatility algorithmic spike minute.")
plot_shift(15, 0, "US Open Prep",       "Upcoming: US Open (15:30 - 18:00)\nPattern: Main action window, major momentum breakouts.")
plot_shift(15, 30, "Reversal Prep",     "Upcoming: 10AM NY Window (16:00)\nPattern: Opening volatility settles. Algos frequently reverse opening moves or establish the true daily trend.")
plot_shift(17, 30, "Lunch Lull Prep",    "Upcoming: Lunch Lull (18:00 - 20:00)\nPattern: NY lunch desks thin out. Slow down, choppy, mean-reverting environment.")
plot_shift(19, 30, "PM Ramp Prep",       "Upcoming: PM Ramp (20:00 - 22:00)\nPattern: Afternoon volume begins returning. Trend continuation or structural reversal.")

// --- VWAP Section ---
a_vwap = ta.vwap(hlc3, inA and not inA[1]), l_vwap = ta.vwap(hlc3, inL and not inL[1]), n_vwap = ta.vwap(hlc3, inN and not inN[1])
plot(inA ? a_vwap : na, "Asia VWAP", color_asia, 2, plot.style_linebr), plot(inL ? l_vwap : na, "London VWAP", color_london, 2, plot.style_linebr), plot(inN ? n_vwap : na, "NY VWAP", color_ny_in, 2, plot.style_linebr)


// =====================================================================
// --- ES SEASONALITY & STATISTICAL MARKERS ---
// =====================================================================
get_es_month_stats(m) =>
    switch m
        1  => ["JAN", "Avg: +0.62%\nBias: Neutral/Mixed\nMental: Prone to early-year volatility before direction sets."]
        2  => ["FEB", "Avg: +1.25%\nBias: Mod. Bullish\nMental: Reliable leg up tracking earnings."]
        3  => ["MAR", "Avg: +1.08%\nBias: Mod. Bullish\nMental: Steady finish to Q1."]
        4  => ["APR", "Avg: +2.15%\nBias: Strong Bullish\nMental: The best month of the year for ES."]
        5  => ["MAY", "Avg: +1.18%\nBias: Mod. Bullish\nMental: Defies 'Sell in May', usually grinds higher."]
        6  => ["JUN", "Avg: +1.02%\nBias: Mod. Bullish\nMental: Steady summer liquidity, drifts up."]
        7  => ["JUL", "Avg: +2.06%\nBias: Strong Bullish\nMental: Second strongest month. Highly reliable."]
        8  => ["AUG", "Avg: -0.08%\nBias: Neutral/Flat\nMental: Volume drops off; choppy, dead-range."]
        9  => ["SEP", "Avg: -1.94%\nBias: Bearish\nMental: Absolute worst month. Institutional rebalancing."]
        10 => ["OCT", "Avg: +1.44%\nBias: Bullish\nMental: 'Bear killer'; wild volatility but nets positive."]
        11 => ["NOV", "Avg: +2.10%\nBias: Strong Bullish\nMental: Massive Q4 institutional inflows."]
        12 => ["DEC", "Avg: +0.76%\nBias: Mild Long\nMental: Saved by Santa Claus rally late, otherwise quiet."]
        => ["UNK", "No Data"]

get_es_day_stats(d) =>
    switch d
        2 => ["MON", "Asia: 55% Bullish\nLondon: 48% Bullish\nNew York: 52% Bullish"]
        3 => ["TUE", "Asia: 53% Bullish\nLondon: 50% Bullish\nNew York: 60% Bullish (Turnaround Tue)"]
        4 => ["WED", "Asia: 54% Bullish\nLondon: 50% Bullish\nNew York: 52% Bullish"]
        5 => ["THU", "Asia: 54% Bullish\nLondon: 49% Bullish\nNew York: 53% Bullish"]
        6 => ["FRI", "Asia: 53% Bullish\nLondon: 51% Bullish\nNew York: 56% Bullish (Passive Inflows)"]
        => ["WKD", "Weekend - No Data"]

// Trigger marker at the exact start of the day's first session (Asia Open)
if inA and not inA[1] and timeframe.isintraday
    [m_name, m_stats] = get_es_month_stats(month(time, "UTC+2"))
    [d_name, d_stats] = get_es_day_stats(dayofweek(time, "UTC+2"))
    
    if dayofweek(time, "UTC+2") >= 2 and dayofweek(time, "UTC+2") <= 6
        lbl_text = "📊 " + m_name + " " + d_name
        hover_text = "=== ES SEASONAL BIAS ===\n\nMONTH (" + m_name + "):\n" + m_stats + "\n\nSESSION WIN RATES (" + d_name + "):\n" + d_stats
        label.new(bar_index, low, lbl_text, yloc=yloc.belowbar, color=color.new(color.blue, 70), textcolor=color.white, style=label.style_label_up, size=size.small, tooltip=hover_text)


// =====================================================================
// --- Final Session Rendering ---
// =====================================================================
render_elements(is_in, col, label_name) =>
    var float hi = na, var float lo = na, var int start_idx = na, var int start_t = na
    var box ib_box = na, var box bg_box = na, var label sess_label = na

    if is_in and not is_in[1] 
        hi := high, lo := low, start_idx := bar_index, start_t := time
        sess_label := label.new(bar_index, high, label_name, color=color.new(col, 100), textcolor=col, style=label.style_label_center, yloc=yloc.price, size=size.small)
        ib_box := box.new(bar_index, hi, bar_index, lo, border_color=col, border_width=ib_thickness, bgcolor=color.new(col, 100))
        bg_box := box.new(bar_index, hi, bar_index, lo, border_color=color.new(col, 100), bgcolor=color.new(col, bg_opacity))
    
    if is_in and not na(start_idx)
        hi := math.max(hi, high), lo := math.min(lo, low)
        box.set_top(bg_box, hi), box.set_bottom(bg_box, lo), box.set_right(bg_box, bar_index)
        label.set_x(sess_label, math.round(start_idx + (bar_index - start_idx) / 2))
        label.set_y(sess_label, hi + (ta.atr(14) * 2))
        if (time - start_t) <= (ib_len * 60 * 1000)
            box.set_top(ib_box, hi), box.set_bottom(ib_box, lo), box.set_right(ib_box, bar_index)

render_elements(inA, color_asia, "Asia (JP/AU)")
render_elements(inL, color_london, "London")
render_elements(inN, color_ny_in, "New York")
````
