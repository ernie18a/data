# Multi-ORB [4 Sessions]

- url: https://www.tradingview.com/script/vmikwJDs-Multi-ORB-4-Sessions/
- type: indicator
- pine_id: PUB;ce2abca975fd4f7bad7af53c5f819e71
- version: 2.0

## Description

The Multi-ORB indicator is a highly customizable tool designed for day traders who rely on Opening Range Breakout strategies to capture early momentum. This script allows you to plot up to four distinct Opening Range sessions on a single chart, making it easy to monitor multiple timeframes (such as the 5-minute, 15-minute, 30-minute, and 60-minute ORBs) simultaneously without cluttering your workspace.

Perfect for trading the New York open in equity indices and futures markets (like the Nasdaq or S&P 500), this indicator locks to "America/New_York" time, ensuring your opening ranges are always accurate regardless of your local timezone.

Key Features:

4 Independent ORBs: Toggle up to four separate opening ranges on or off. Fully customize the start and end times for each session.

Midline Tracking: Automatically calculates and plots the exact midline (50% level) for every active ORB, providing an essential pivot point for intraday price action.

Two-Tone Gradient Fills: Features a visually clean, dual-gradient background fill. The upper zone (High to Midline) and lower zone (Midline to Low) can be colored independently to help you instantly visualize bullish versus bearish positioning within the range.

Full Aesthetic Control: Easily adjust the colors, transparency, line styles (solid, dashed, dotted), and line thickness directly from the indicator settings to fit your personal charting theme.

Clean Overlaps: Gradient transparencies are optimized so that multiple ORB zones can overlap seamlessly, highlighting confluence areas where multiple timeframes align.

Whether you use the opening range for breakout entries, stop-loss placement, or identifying key intraday support and resistance, this indicator provides a clean, all-in-one visual solution.

## Source Code

````pine
//@version=6
indicator("Multi-ORB [4 Sessions]", overlay=true)

// =========================================================================
// HELPER FUNCTION: Calculate and Display ORB
// =========================================================================
get_orb(start_time, calc_end, display_end, enable) =>
    var float orb_high = na
    var float orb_low  = na
    
    // Create the session strings
    calc_sess = start_time + "-" + calc_end
    display_sess = start_time + "-" + display_end
    
    // Lock to NY Time
    in_calc = not na(time(timeframe.period, calc_sess, "America/New_York"))
    in_display = not na(time(timeframe.period, display_sess, "America/New_York"))
    
    is_new_calc = in_calc and not in_calc[1]
    is_new_day = nz(ta.change(time("D", "America/New_York"))) != 0

    // Reset levels at the start of a new day
    if is_new_day
        orb_high := na
        orb_low  := na

    // Record highs and lows during the formation session
    if is_new_calc and enable
        orb_high := high
        orb_low  := low
    else if in_calc and enable
        orb_high := math.max(orb_high, high)
        orb_low  := math.min(orb_low, low)

    orb_mid = (orb_high + orb_low) / 2
    
    // Return values ONLY if enabled, valid, AND within the display timeframe
    valid = enable and in_display and not na(orb_high)
    [valid ? orb_high : na, valid ? orb_low : na, valid ? orb_mid : na]

// =========================================================================
// INPUTS & PLOTTING
// =========================================================================

// --- ORB 1 (Default: 5 Min) ---
grp1 = "ORB 1 Settings"
en1 = input.bool(true, "Enable ORB 1", group=grp1)
start1 = input.string("0930", "ORB Start Time (HHMM)", group=grp1)
calc1 = input.string("0935", "Formation End Time (HHMM)", group=grp1)
disp1 = input.string("1600", "Stop Plotting At (HHMM)", group=grp1)
c1_h = input.color(color.new(color.green, 0), "High Line Color", group=grp1)
c1_m = input.color(color.new(color.gray, 0), "Mid Line Color", group=grp1)
c1_l = input.color(color.new(color.red, 0), "Low Line Color", group=grp1)
c1_fill_top = input.color(color.new(color.green, 85), "Fill Gradient Top", group=grp1)
c1_fill_bot = input.color(color.new(color.red, 85), "Fill Gradient Bottom", group=grp1)

[h1, l1, m1] = get_orb(start1, calc1, disp1, en1)
p1_h = plot(h1, color=c1_h, title="ORB 1 High", style=plot.style_linebr)
p1_m = plot(m1, color=c1_m, title="ORB 1 Mid", style=plot.style_linebr)
p1_l = plot(l1, color=c1_l, title="ORB 1 Low", style=plot.style_linebr)
fill(p1_h, p1_m, color=c1_fill_top, title="ORB 1 Fill Top")
fill(p1_m, p1_l, color=c1_fill_bot, title="ORB 1 Fill Bottom")


// --- ORB 2 (Default: 15 Min) ---
grp2 = "ORB 2 Settings"
en2 = input.bool(true, "Enable ORB 2", group=grp2)
start2 = input.string("0930", "ORB Start Time (HHMM)", group=grp2)
calc2 = input.string("0945", "Formation End Time (HHMM)", group=grp2)
disp2 = input.string("1600", "Stop Plotting At (HHMM)", group=grp2)
c2_h = input.color(color.new(color.blue, 0), "High Line Color", group=grp2)
c2_m = input.color(color.new(color.gray, 0), "Mid Line Color", group=grp2)
c2_l = input.color(color.new(color.orange, 0), "Low Line Color", group=grp2)
c2_fill_top = input.color(color.new(color.blue, 90), "Fill Gradient Top", group=grp2)
c2_fill_bot = input.color(color.new(color.orange, 90), "Fill Gradient Bottom", group=grp2)

[h2, l2, m2] = get_orb(start2, calc2, disp2, en2)
p2_h = plot(h2, color=c2_h, title="ORB 2 High", style=plot.style_linebr)
p2_m = plot(m2, color=c2_m, title="ORB 2 Mid", style=plot.style_linebr)
p2_l = plot(l2, color=c2_l, title="ORB 2 Low", style=plot.style_linebr)
fill(p2_h, p2_m, color=c2_fill_top, title="ORB 2 Fill Top")
fill(p2_m, p2_l, color=c2_fill_bot, title="ORB 2 Fill Bottom")


// --- ORB 3 (Default: 30 Min) ---
grp3 = "ORB 3 Settings"
en3 = input.bool(false, "Enable ORB 3", group=grp3)
start3 = input.string("0930", "ORB Start Time (HHMM)", group=grp3)
calc3 = input.string("1000", "Formation End Time (HHMM)", group=grp3)
disp3 = input.string("1600", "Stop Plotting At (HHMM)", group=grp3)
c3_h = input.color(color.new(color.fuchsia, 0), "High Line Color", group=grp3)
c3_m = input.color(color.new(color.gray, 0), "Mid Line Color", group=grp3)
c3_l = input.color(color.new(color.teal, 0), "Low Line Color", group=grp3)
c3_fill_top = input.color(color.new(color.fuchsia, 90), "Fill Gradient Top", group=grp3)
c3_fill_bot = input.color(color.new(color.teal, 90), "Fill Gradient Bottom", group=grp3)

[h3, l3, m3] = get_orb(start3, calc3, disp3, en3)
p3_h = plot(h3, color=c3_h, title="ORB 3 High", style=plot.style_linebr)
p3_m = plot(m3, color=c3_m, title="ORB 3 Mid", style=plot.style_linebr)
p3_l = plot(l3, color=c3_l, title="ORB 3 Low", style=plot.style_linebr)
fill(p3_h, p3_m, color=c3_fill_top, title="ORB 3 Fill Top")
fill(p3_m, p3_l, color=c3_fill_bot, title="ORB 3 Fill Bottom")


// --- ORB 4 (Default: 60 Min) ---
grp4 = "ORB 4 Settings"
en4 = input.bool(false, "Enable ORB 4", group=grp4)
start4 = input.string("0930", "ORB Start Time (HHMM)", group=grp4)
calc4 = input.string("1030", "Formation End Time (HHMM)", group=grp4)
disp4 = input.string("1600", "Stop Plotting At (HHMM)", group=grp4)
c4_h = input.color(color.new(color.purple, 0), "High Line Color", group=grp4)
c4_m = input.color(color.new(color.gray, 0), "Mid Line Color", group=grp4)
c4_l = input.color(color.new(color.maroon, 0), "Low Line Color", group=grp4)
c4_fill_top = input.color(color.new(color.purple, 92), "Fill Gradient Top", group=grp4)
c4_fill_bot = input.color(color.new(color.maroon, 92), "Fill Gradient Bottom", group=grp4)

[h4, l4, m4] = get_orb(start4, calc4, disp4, en4)
p4_h = plot(h4, color=c4_h, title="ORB 4 High", style=plot.style_linebr)
p4_m = plot(m4, color=c4_m, title="ORB 4 Mid", style=plot.style_linebr)
p4_l = plot(l4, color=c4_l, title="ORB 4 Low", style=plot.style_linebr)
fill(p4_h, p4_m, color=c4_fill_top, title="ORB 4 Fill Top")
fill(p4_m, p4_l, color=c4_fill_bot, title="ORB 4 Fill Bottom")
````
