# Financial Growth TTM [AMLQ]

- url: https://www.tradingview.com/script/KylKwKqp-Financial-Growth-TTM-AMLQ/
- type: indicator
- pine_id: PUB;394f6f6a6f4c4dd78aac02d5a8197434
- version: 1.0

## Description

[b]Reading Fundamentals Directly on Your Chart[/b]
Most traders analyze price action in isolation, checking quarterly earnings in a separate tab or financial report. However, price trends are ultimately anchored by corporate earnings power. Financial Growth TTM [AMLQ] bridges this gap by bringing Trailing Twelve Months (TTM) fundamental data directly beneath your price chart as step-line trends, complete with automated quarter-over-quarter (QoQ) and year-over-year (YoY) performance metrics.

[b]Core Concept: Why TTM Matters[/b]
Single-quarter earnings can be noisy and heavily distorted by seasonal fluctuations (for example, retail surges in Q4 or quiet periods during festive holidays). Using Trailing Twelve Months (TTM) smooths out seasonal spikes by summing the four most recent operating quarters.

When a company releases new quarterly financial statements:
[list]
[*]A rising TTM line confirms an expanding business base.
[*]A plateau or rollover warns of top-line or bottom-line exhaustion long before annual reports are published.
[/list]
[b]Key Features[/b]

Step-Line Trajectory: Renders corporate earnings updates as clean step levels, reflecting how financial statements are published once per quarter rather than interpolating continuous daily moves.

Compact Nominal Values: Automatically formats large headline figures into readable denominations (B for Billions, M for Millions, and K for Thousands) to eliminate visual clutter.

Dynamic Color-Coded Momentum: Stepline colors dynamically adapt based on sequential growth:
[list]
[*]Green: Positive sequential growth (QoQ expanding).
[*]Red: Sequential contraction (QoQ declining).
[*]Gray: Flat or neutral performance.
[/list]
On-Chart Growth Tags: Every time a new filing is recognized, a detailed tag marks:
[list]
[*]Metric name (Revenue, Operating Income, or Net Income)
[*]Nominal TTM figure
[*]Sequential growth rate (QoQ %)
[*]Annualized growth rate (YoY %)
[*]Period timestamp (Month and Year)
[/list]
[b]How to Use It in Your Workflow[/b]
[list=1]
[*]Trend Confirmation: Compare the direction of price on the upper pane with the trajectory of Net Income on the lower pane. An uptrend backed by steady green steps indicates fundamental accumulation.
[*]Fundamental Divergence: If price breaks out to fresh highs while the TTM Net Income line rolls over into red, the rally is driven purely by multiple expansion rather than earnings growth—a clear signal to manage risk.
[*]Margin Health: Keep both Revenue and Net Income toggled on. If Revenue continues climbing higher while Net Income flattens or turns red, cost pressures are compressing operating margins.
[/list]
[b]Chart Scale Setup Tip[/b]
By default, the script plots Total Revenue and Net Income directly on a standard nominal scale, leaving Operating Income toggled off to maintain a clean reading.
Because Revenue figures are naturally much higher than Net Income, you can right-click the vertical axis of the indicator pane in TradingView and select Auto (Fits Data to Screen) or Logarithmic Scale for balanced visual spacing between both lines.

## Source Code

````pine
//@version=6
indicator("Financial Growth TTM [AMLQ]", overlay=false, max_labels_count=500)

// --- Custom Visibility Inputs ---
show_rev = input.bool(true,  title="Show Revenue", group="Visibility Toggles")
show_op  = input.bool(false, title="Show Operating Income", group="Visibility Toggles")
show_net = input.bool(true,  title="Show Net Income", group="Visibility Toggles")

// Helper function to format large nominal values into B, M, or K
format_compact(val) =>
    if na(val)
        "N/A"
    else
        abs_v = math.abs(val)
        sign = val < 0 ? "-" : ""
        if abs_v >= 1e9
            sign + str.tostring(abs_v / 1e9, "#.##") + "B"
        else if abs_v >= 1e6
            sign + str.tostring(abs_v / 1e6, "#.##") + "M"
        else if abs_v >= 1e3
            sign + str.tostring(abs_v / 1e3, "#.##") + "K"
        else
            sign + str.tostring(abs_v, "#.##")

// Function to calculate growth and identify past reporting periods
get_growth(metric) =>
    val = request.financial(syminfo.tickerid, metric, "TTM")
    
    change_val = ta.change(val)
    changed = not na(change_val) and change_val != 0
    
    prev_q1 = ta.valuewhen(changed, val[1], 0) // 1 quarter ago
    prev_q4 = ta.valuewhen(changed, val[1], 3) // 4 quarters ago (YoY)
    
    qoq = (not na(prev_q1) and prev_q1 != 0) ? ((val - prev_q1) / math.abs(prev_q1)) * 100 : na
    yoy = (not na(prev_q4) and prev_q4 != 0) ? ((val - prev_q4) / math.abs(prev_q4)) * 100 : na
    
    [val, qoq, yoy, changed]

// Fetch data for the three metrics
[rev, rev_qoq, rev_yoy, rev_change] = get_growth("TOTAL_REVENUE")
[op,  op_qoq,  op_yoy,  op_change]  = get_growth("OPER_INCOME")
[net, net_qoq, net_yoy, net_change] = get_growth("NET_INCOME")

// Helper function for color coding QoQ growth
get_color(qoq) =>
    na(qoq) ? color.gray : qoq > 0 ? color.green : qoq < 0 ? color.red : color.gray

rev_color = get_color(rev_qoq)
op_color  = get_color(op_qoq)
net_color = get_color(net_qoq)

// Plot direct nominal values on the default single scale
plot(show_rev ? rev : na, color=rev_color, style=plot.style_stepline, title="Revenue TTM", linewidth=2)
plot(show_op  ? op  : na, color=op_color,  style=plot.style_stepline, title="Operating Income TTM", linewidth=2)
plot(show_net ? net : na, color=net_color, style=plot.style_stepline, title="Net Income TTM", linewidth=2)

// Function to draw text labels
draw_label(show_toggle, changed, val, qoq, yoy, prefix, dynamic_color, lbl_style) =>
    if show_toggle and changed
        period_str = str.format("{0,date,MMM yy}", time)
        compact_num = format_compact(val)
        
        lbl_text = prefix + "\n" + compact_num + "\nQoQ: " + str.tostring(qoq, "#.##") + "%\nYoY: " + str.tostring(yoy, "#.##") + "%\n" + period_str
        label.new(bar_index, val, lbl_text, color=color.new(dynamic_color, 85), textcolor=color.orange, style=lbl_style, size=size.small)

// Draw labels pinned directly to actual line values
draw_label(show_rev, rev_change, rev, rev_qoq, rev_yoy, "Revenue",   rev_color, label.style_label_down)
draw_label(show_op,  op_change,  op,  op_qoq,  op_yoy,  "Op Income", op_color,  label.style_label_up)
draw_label(show_net, net_change, net, net_qoq, net_yoy, "Net Income", net_color, label.style_label_up)
````
