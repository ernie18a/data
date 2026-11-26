# Future & Historical Period Lines (D/W/M/3M/Y)

- url: https://www.tradingview.com/script/XynIVine-Future-Historical-Period-Lines-D-W-M-3M-Y/
- type: indicator
- pine_id: PUB;acd96386986f44a99a6eab8632813830
- version: 2.0

## Description

Creates vertical lines on future and historical htf closes

@ichigramma on X

## Source Code

````pine
//@version=5
//@ichigramma on X.
indicator("Future & Historical Period Lines (D/W/M/3M/Y)", overlay=true, max_lines_count=500)

// =========================================================================
// INPUTS: Toggles and Colors
// =========================================================================
grp_future = "Future Projections"
future_n   = input.int(5, "Number of Future Lines per Timeframe", group=grp_future, minval=1, maxval=50)

grp_hist   = "Historical Lookback"
show_hist  = input.bool(true, "Historical Lines", group=grp_hist)
lookback_d = input.int(365, "Lookback Period (Days)", group=grp_hist, minval=1)

grp_tf = "Timeframes & Colors"
// Yearly
show_y = input.bool(true, "Yearly (1Y)", group=grp_tf, inline="y")
col_y  = input.color(color.new(color.red, 0), "", group=grp_tf, inline="y")

// Quarterly
show_q = input.bool(true, "Quarterly (3M)", group=grp_tf, inline="q")
col_q  = input.color(color.new(color.red, 0), "", group=grp_tf, inline="q")

// Monthly
show_m = input.bool(true, "Monthly (1M)", group=grp_tf, inline="m")
col_m  = input.color(color.new(color.blue, 0), "", group=grp_tf, inline="m")

// Weekly
show_w = input.bool(true, "Weekly (1W)", group=grp_tf, inline="w")
col_w  = input.color(color.new(color.orange, 0), "", group=grp_tf, inline="w")

// Daily
show_d = input.bool(false, "Daily (1D)", group=grp_tf, inline="d")
col_d  = input.color(color.new(color.gray, 50), "", group=grp_tf, inline="d")


// =========================================================================
// HELPER FUNCTION: Draw Vertical Line
// =========================================================================
f_draw_vline(t, col) =>
    line.new(x1=t, y1=low, x2=t, y2=high, xloc=xloc.bar_time, extend=extend.both, color=col, style=line.style_dotted, width=1)


// =========================================================================
// HISTORICAL LINES
// =========================================================================
// Calculate if the current bar is within the user's defined lookback period
in_lookback = time >= (timenow - (lookback_d * 86400000))

if show_hist and in_lookback
    // Hierarchy prioritized from highest to lowest timeframe to avoid overlapping lines on the exact same date
    if show_y and ta.change(time("12M"))
        f_draw_vline(time, col_y)
    else if show_q and ta.change(time("3M"))
        f_draw_vline(time, col_q)
    else if show_m and ta.change(time("M"))
        f_draw_vline(time, col_m)
    else if show_w and ta.change(time("W"))
        f_draw_vline(time, col_w)
    else if show_d and ta.change(time("D"))
        f_draw_vline(time, col_d)


// =========================================================================
// FUTURE LINES
// =========================================================================
if barstate.islast
    curr_y = year(time)
    curr_m = month(time)
    
    // Future Yearly (Jan 1st)
    if show_y
        for i = 1 to future_n
            f_y = curr_y + i
            t = timestamp(syminfo.timezone, f_y, 1, 1, 0, 0, 0)
            f_draw_vline(t, col_y)
            
    // Future Quarterly (Jan 1, Apr 1, Jul 1, Oct 1)
    if show_q
        curr_q = math.ceil(curr_m / 3)
        for i = 1 to future_n
            f_q = curr_q + i
            f_y = curr_y + math.floor((f_q - 1) / 4)
            f_q_mod = (f_q - 1) % 4 + 1
            f_m_q = (f_q_mod - 1) * 3 + 1
            t = timestamp(syminfo.timezone, f_y, f_m_q, 1, 0, 0, 0)
            f_draw_vline(t, col_q)
            
    // Future Monthly (1st of every month)
    if show_m
        for i = 1 to future_n
            f_m = curr_m + i
            f_y = curr_y + math.floor((f_m - 1) / 12)
            f_m_mod = (f_m - 1) % 12 + 1
            t = timestamp(syminfo.timezone, f_y, f_m_mod, 1, 0, 0, 0)
            f_draw_vline(t, col_m)
            
    // Future Weekly (Upcoming weekly closes)
    // Uses 604800000 ms, which is exactly 7 days
    if show_w
        curr_w_start = time("W")
        if not na(curr_w_start)
            for i = 1 to future_n
                t = curr_w_start + (i * 604800000)
                f_draw_vline(t, col_w)

    // Future Daily (Upcoming daily closes)
    if show_d
        curr_d_start = time("D")
        if not na(curr_d_start)
            for i = 1 to future_n
                t = curr_d_start + (i * 86400000)
                f_draw_vline(t, col_d)
````
