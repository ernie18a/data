# Unified Session V3.6 - Extended (Gold Edition)

- url: https://www.tradingview.com/script/wIZZ37ef-Unified-Session-V3-6-Extended-Gold-Edition/
- type: indicator
- pine_id: PUB;ffce8a9d5d8e4f1288b4a5bbb6e49b16
- version: 1.0

## Description

Session & Initial Balance Mapping: Visually highlights the Asian (extended to 10:00), London, and New York trading windows with shaded boxes. It also plots the Initial Balance (IB) range for the first 15 minutes of each session.

Anchored VWAPs: Calculates and plots independent Volume Weighted Average Price (VWAP) lines anchored to the start of each major session.

Key Benchmark Levels: Automatically draws critical daily and weekly liquidity levels, including Previous Day High/Low/Close, Daily Open, Daily Equilibrium (midpoint), and Previous Week High/Low.

Intraday Timeline Alerts: Places visual markers on the chart 5 minutes ahead of major Gold-specific market events (e.g., London Breakout, Comex Open, Algo Dominance window) with tooltip reminders of typical market behavior.

Seasonal & Statistical Edge: Automatically prints a daily label at the Asia Open detailing Gold's historical performance bias for the current month (e.g., January's strong bullishness) and the specific day of the week.

## Source Code

````pine
//@version=6
indicator("Unified Session V3.6 - Asia Extended (Gold Edition)", overlay=true, max_boxes_count=500)

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

// --- GOLD INTRADAY TIMELINE MARKERS (Shifted 5 Mins Forward for Prep) ---
plot_shift(23, 55, "Overnight Bias Prep", "Asia Open (00:00 - 03:00)\nBehavior: Trending. Direction can set overnight bias.")
plot_shift(2, 55,  "Asian Flow Prep",     "Late Asia: / Early Europe (03:00 - 08:00)\nBehavior: Market digests Asian flow. Consolidates before London open. Draw overnight range.")
plot_shift(7, 55,  "London Breakout Prep", "London / Frankfurt (08:00 - 11:30)\nBehavior: Strong move develops between 09:00 - 10:00. Often the first true breakout of the day.")
plot_shift(9, 55,  "HonkKong Closing", "HKEX > (10:00)\nBehavior: A reversal can be exptected. The full asia is no closed")
plot_shift(11, 25,  "Pre-US Coil Prep",     "Europe / Pre-NY (11:30 - 15:30)\nBehavior: Price may coil tightly before US open. Low-volatility trap setup before 15:30 macro burst.")
plot_shift(15, 25,  "Comex Open Prep",      "US Open / Comex (15:30 - 18:00)\nBehavior: Comex opens. Massive volatility spike.")
plot_shift(17, 55, "Algo Dominance Prep",  "NY Afternoon (18:00 - 20:00)\nBehavior: Volatility drops off significantly. Algorithmic execution dominates the order flow.")
plot_shift(19, 55, "Comex Close Prep",     "Comex Closing Run (20:00 - 22:00)\nBehavior: Comex official settlement close happens at 20:30. Prone to last-minute trend reversions or stop runs.")

// --- VWAP Section ---
a_vwap = ta.vwap(hlc3, inA and not inA[1]), l_vwap = ta.vwap(hlc3, inL and not inL[1]), n_vwap = ta.vwap(hlc3, inN and not inN[1])
plot(inA ? a_vwap : na, "Asia VWAP", color_asia, 2, plot.style_linebr), plot(inL ? l_vwap : na, "London VWAP", color_london, 2, plot.style_linebr), plot(inN ? n_vwap : na, "NY VWAP", color_ny_in, 2, plot.style_linebr)


// =====================================================================
// --- GOLD SEASONALITY & STATISTICAL MARKERS ---
// =====================================================================
get_gold_month_stats(m) =>
    switch m
        1  => ["JAN", "Avg: +3.05%\nBias: Strongly Bullish\nMental: Highest average return of the year; 80% positive win rate. Strongest structural long."]
        2  => ["FEB", "Avg: +0.32%\nBias: Neutral\nMental: Quiet consolidation month after January's big push."]
        3  => ["MAR", "Avg: +0.16%\nBias: Neutral\nMental: Flat and choppy; historically a compression or range-bound month."]
        4  => ["APR", "Avg: +0.66%\nBias: Neutral/Mixed\nMental: Slightly positive bias, but highly inconsistent year-to-year."]
        5  => ["MAY", "Avg: +0.41%\nBias: Neutral\nMental: Middle of the spring chop. High variance, no clear directional edge."]
        6  => ["JUN", "Avg: +1.12%\nBias: Moderately Bullish\nMental: Start of the summer push; heavily influenced by a few massive up-years."]
        7  => ["JUL", "Avg: +1.41%\nBias: Bullish\nMental: Reliable summer buying; very rarely suffers deep sell-offs."]
        8  => ["AUG", "Avg: +1.51%\nBias: Bullish\nMental: The peak of the summer cycle; strong historical long bias."]
        9  => ["SEP", "Avg: -2.31%\nBias: Bearish\nMental: Clear seasonal pivot to the downside; 8 out of 10 years closed red."]
        10 => ["OCT", "Avg: +0.04%\nBias: Neutral\nMental: A temporary pause/bounce between the two worst months of the year."]
        11 => ["NOV", "Avg: -2.53%\nBias: Strongly Bearish\nMental: The weakest month of the year on average; deep structural short bias."]
        12 => ["DEC", "Avg: +0.84%\nBias: Mildly Bullish\nMental: Tends to stabilize and drift higher to close out the year."]
        => ["UNK", "No Data"]

get_gold_day_stats(d) =>
    switch d
        2 => ["MON", "Asia: 50% Bullish (Balanced)\nLondon: 52% Bullish\nNew York: 51% Bullish"]
        3 => ["TUE", "Asia: 51% Bullish\nLondon: 60% Bullish (Highly Directional Window)\nNew York: 53% Bullish"]
        4 => ["WED", "Asia: 44% Bullish (Heavy Bearish Edge)\nLondon: 52% Bullish\nNew York: 72% Bullish (Powerhouse Buying Window)"]
        5 => ["THU", "Asia: 50% Bullish\nLondon: 62% Bullish (Highly Directional Window)\nNew York: 51% Bullish"]
        6 => ["FRI", "Asia: 45% Bullish (Heavy Bearish Edge)\nLondon: 46% Bullish (Bearish Shift)\nNew York: 43% Bullish (Sea of Red/Profit Taking)"]
        => ["WKD", "Weekend - No Data"]

// Trigger marker at the exact start of the day's first session (Asia Open)
if inA and not inA[1] and timeframe.isintraday
    [m_name, m_stats] = get_gold_month_stats(month(time, "UTC+2"))
    [d_name, d_stats] = get_gold_day_stats(dayofweek(time, "UTC+2"))
    
    if dayofweek(time, "UTC+2") >= 2 and dayofweek(time, "UTC+2") <= 6
        lbl_text = "✨ " + m_name + " " + d_name
        hover_text = "=== GOLD SEASONAL BIAS ===\n\nMONTH (" + m_name + "):\n" + m_stats + "\n\nSESSION WIN RATES (" + d_name + "):\n" + d_stats
        label.new(bar_index, low, lbl_text, yloc=yloc.belowbar, color=color.new(color.orange, 50), textcolor=color.white, style=label.style_label_up, size=size.small, tooltip=hover_text)


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
