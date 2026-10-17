# Strongest Price Nodes

- url: https://www.tradingview.com/script/T19wYd4C-Strongest-Price-Nodes/
- type: indicator
- pine_id: PUB;d1e14e605658427cbad1d85d20af6a56
- version: 1.0

## Description

Strongest Price Nodes highlights the price levels where the market has built the strongest activity across recent sessions.

Instead of displaying a full profile or filling the chart with too many levels, this indicator extracts only the most important price nodes and plots them directly on the chart as clean decision levels.
These nodes represent areas where price has spent time, traded volume, or built both time and volume together.
In simple terms, the indicator helps answer one question: Where has the market shown the strongest acceptance?

What It Shows? The indicator plots two types of nodes:

[b]1. Historical Price Nodes[/b][i][/i]
Historical nodes are calculated from completed sessions using the selected lookback period.
They show where the strongest market participation occurred in recent history.
These levels can act as important areas for reaction, support, resistance, retest, breakout confirmation, or mean reversion.

[b]2. Developing Session Node[/b][i][/i]
The developing session node shows the strongest value area forming during the current session.
It updates live as the session develops.To keep the chart clean, the developing session node is always limited to one level.

[b]Calculation Modes[/b][i][/i] The indicator includes three profile modes:
[list]
[*]Volume
Finds price levels where the most volume traded.
[*]Time
Finds price levels where price spent the most time.
[*]Volume x Time
Finds price levels where both volume and time align.
[/list]

This mode is useful for identifying stronger acceptance zones because it combines participation with time spent at price.

[b]Why These Nodes Matter[/b][i][/i]

[list]
[*]Strong price nodes often become important market reference points.
[*]Price may pause around them, reject from them, retest them after a breakout, rotate back toward them, or use them as support or resistance.
[*]A strong node is not a buy or sell signal by itself. It is a decision zone. What matters is how price behaves when it reaches the node.
[/list]

[b]Display Controls[/b][i][/i]
Nodes can be displayed as lines or ATR-based zones.
ATR-based zones adjust automatically with market volatility.
The extension mode can also be controlled.
You can choose to stop levels at session end, extend them for a fixed number of bars, extend them to the right, extend them to the left, or extend them in both directions.

This helps keep the chart clean and avoids unnecessary infinite lines when they are not needed.

[b]How Traders Can Use It[/b][i][/i]

[list]
[*]Use historical nodes to mark important prior value areas.
[*]Use the developing node to understand where the current session is building value.
[*]If price holds above a node, it may suggest acceptance.
[*]If price rejects from a node, it may suggest failed acceptance.
[*]If price breaks away and later retests the node, it can become a useful continuation or reversal area.
[/list]

The indicator works best when combined with price action, VWAP, session highs and lows, trend context, and volume behavior.

[b]Summary[/b][i][/i]
Strongest Price Nodes is built for traders who want a cleaner way to identify important price levels.
It focuses only on the strongest areas of market activity and removes unnecessary profile clutter.

The goal is not to predict direction.
The goal is to show where the market has accepted price and where the next important reaction may happen.

## Source Code

````pine
//@version=5
indicator("Strongest Price Nodes", overlay=true, max_lines_count=100, max_boxes_count=100)

// --- Type ---
type session
    array<float> closes
    array<float> volumes

// --- Inputs ---
grp_main = "Profile Calculation"
profile_type   = input.string("Volume x Time", "Profile Type", options=["Volume", "Time", "Volume x Time"], group=grp_main)
num_bins       = input.int(24, "Profile Resolution (Number of Bins)", group=grp_main)

grp_hist = "Historical Settings"
num_hist_nodes  = input.int(5, "Nodes to Show", minval=1, maxval=10, inline="h1", group=grp_hist)
lookback_sess   = input.int(10, "Lookback (Sessions)", minval=1, inline="h1", group=grp_hist)
min_bars_valid  = input.int(2, "Min Bars for Valid Session", group=grp_hist)
display_style   = input.string("Line", "Style", options=["Zone", "Line"], group=grp_hist, inline="h2")
zone_color      = input.color(color.new(color.orange, 40), "Color", inline="h2", group=grp_hist)

grp_ext = "Node Extension"
node_extension = input.string("Session End","Extension Mode",options=["Session End", "Fixed Bars", "Right Infinite", "Left Infinite", "Both Sides"],group=grp_ext)
fixed_extend_bars = input.int(100, "Fixed Bars Forward", minval=1, maxval=5000, group=grp_ext)
session_end_hour  = input.int(15, "Session End Hour", minval=0, maxval=23, group=grp_ext, inline="se")
session_end_min   = input.int(30, "Minute", minval=0, maxval=59, group=grp_ext, inline="se")

grp_atr = "ATR Zone Width"
atr_length = input.int(14, "ATR Length", group=grp_atr)

grp_dev = "Developing Session"
show_dev_nodes = input.bool(true, "Show Current Session Nodes", group=grp_dev)
dev_color      = input.color(color.new(color.blue, 50), "Developing Color", group=grp_dev)

// --- Session storage ---
var g_dev_closes   = array.new<float>()
var g_dev_volumes  = array.new<float>()
var g_all_sessions = array.new<session>()

// Session start time for drawing
var int g_session_start_time = na

is_new_session = ta.change(time("D"))

if barstate.isfirst
    g_session_start_time := time

if is_new_session
    g_session_start_time := time

if is_new_session and array.size(g_dev_closes) > 0
    // Only store sessions with enough bars to be trustworthy
    if array.size(g_dev_closes) >= min_bars_valid
        completed = session.new(array.copy(g_dev_closes), array.copy(g_dev_volumes))
        array.push(g_all_sessions, completed)
        while array.size(g_all_sessions) > lookback_sess
            array.shift(g_all_sessions)
    array.clear(g_dev_closes)
    array.clear(g_dev_volumes)

// Always feed current bar
array.push(g_dev_closes, close)
array.push(g_dev_volumes, volume)

// --- Extension helpers ---
f_get_extend() =>
    node_extension == "Right Infinite" ? extend.right :
     node_extension == "Left Infinite" ? extend.left :
     node_extension == "Both Sides" ? extend.both :
     extend.none

f_get_right_time() =>
    bar_ms = timeframe.in_seconds(timeframe.period) * 1000
    session_end_time = timestamp(syminfo.timezone, year(time), month(time), dayofmonth(time), session_end_hour, session_end_min)
    node_extension == "Fixed Bars" ? time + fixed_extend_bars * bar_ms : session_end_time

// --- Profile calculator fixed bins ---
f_calculate_nodes(closes, volumes, nodes_to_find) =>
    result = array.new<float>()

    if array.size(closes) > 1
        max_val  = array.max(closes)
        min_val  = array.min(closes)
        bin_size = (max_val - min_val) / num_bins

        if bin_size > 0
            bin_vol  = array.new<float>(num_bins, 0.0)
            bin_time = array.new<float>(num_bins, 0.0)

            for i = 0 to array.size(closes) - 1
                price = array.get(closes, i)
                vol   = array.get(volumes, i)
                idx   = int(math.max(0, math.min(num_bins - 1, math.floor((price - min_val) / bin_size))))

                array.set(bin_vol, idx, array.get(bin_vol, idx) + vol)
                array.set(bin_time, idx, array.get(bin_time, idx) + 1)

            strength = array.new<float>(num_bins, 0.0)

            if profile_type == "Volume"
                strength := bin_vol
            else if profile_type == "Time"
                strength := bin_time
            else
                for i = 0 to num_bins - 1
                    array.set(strength, i, array.get(bin_vol, i) * array.get(bin_time, i))

            tmp = array.copy(strength)

            for n = 1 to nodes_to_find
                max_s = array.max(tmp)

                if max_s <= 0
                    break

                best_idx = array.indexof(tmp, max_s)
                level = min_val + best_idx * bin_size + bin_size / 2.0

                array.push(result, level)
                array.set(tmp, best_idx, -1.0)

    result

// --- Drawing management ---
var g_boxes = array.new<box>()
var g_lines = array.new<line>()
var g_dev_boxes = array.new<box>()
var g_dev_lines = array.new<line>()

delete_all(array<box> b_arr, array<line> l_arr) =>
    for b in b_arr
        box.delete(b)
    for l in l_arr
        line.delete(l)
    array.clear(b_arr)
    array.clear(l_arr)

current_atr = ta.atr(atr_length)

left_time  = g_session_start_time
right_time = f_get_right_time()
node_ext   = f_get_extend()

// --- Historical nodes redrawn only at session start ---
if is_new_session
    delete_all(g_boxes, g_lines)

    if array.size(g_all_sessions) > 0
        composite_c = array.new<float>()
        composite_v = array.new<float>()

        for i = 0 to array.size(g_all_sessions) - 1
            s = array.get(g_all_sessions, i)
            array.concat(composite_c, s.closes)
            array.concat(composite_v, s.volumes)

        nodes = f_calculate_nodes(composite_c, composite_v, num_hist_nodes)

        for level in nodes
            if display_style == "Zone"
                top    = level + current_atr * 0.5
                bottom = level - current_atr * 0.5

                b = box.new(left_time,top,right_time,bottom,xloc=xloc.bar_time,bgcolor=zone_color,border_color=zone_color,extend=node_ext)
                array.push(g_boxes, b)
            else
                l = line.new(left_time,level,right_time,level,xloc=xloc.bar_time,color=zone_color,width=2,extend=node_ext)
                array.push(g_lines, l)

// --- Developing session nodes updated every bar ---
delete_all(g_dev_boxes, g_dev_lines)

if show_dev_nodes and array.size(g_dev_closes) >= min_bars_valid
    dev_nodes = f_calculate_nodes(g_dev_closes, g_dev_volumes, 1)

    for level in dev_nodes
        if display_style == "Zone"
            top    = level + current_atr * 0.5
            bottom = level - current_atr * 0.5

            b = box.new(left_time,top,right_time,bottom,xloc=xloc.bar_time,bgcolor=dev_color,border_color=dev_color,extend=node_ext)
            array.push(g_dev_boxes, b)
        else
            l = line.new(left_time,level,right_time,level,xloc=xloc.bar_time,color=dev_color,width=2,extend=node_ext)
            array.push(g_dev_lines, l)
````
