# MA Cloud System by @cumacevik

- url: https://www.tradingview.com/script/iRQURsx9-MA-Cloud-System-by-cumacevik/
- type: indicator
- pine_id: PUB;8efa32e3cf3b4246bc5f1a908535f83c
- version: 2.0

## Description

Customizable MA Cloud System (Multi-Timeframe)

This premium Pine Script v5 indicator maps short, medium, and long-term market structures simultaneously using 4 independent moving averages and 3 distinct trend clouds.

Key Features:

Dual-Mode Timeframe (MTF): Scales automatically with your chart interval or locks to a specific macro timeframe (Daily, Weekly, etc.). Built-in lookahead protection guarantees zero data leak bias during backtesting.

EMA / SMA Selector: Toggle the entire calculation engine between EMA and SMA closing prices with a single click.

Granular Line Control: Customize each MA line independently—adjust period length, color, thickness (1−4px), and line typography (Solid, Dashed, or Dotted).

Fault-Tolerant Cloud Engine: Toggling a line off shifts its color to 100% transparency rather than dropping the data array. This prevents the clouds from fracturing, ensuring seamless visual trend tracking.

Clean UI Architecture: Zero clutter. All useless, anonymous checkboxes inside TradingView's "Style" tab are eliminated. Every control is cleanly organized within the primary "Inputs" panel.

## Source Code

````pine
//@version=6
indicator("MA Cloud System by Cuma Cevik", overlay=true, max_labels_count=100)

// ==========================================
// 1. GENERAL SETTINGS
// ==========================================

g0 = "General Settings"

tf_mode = input.string(
    "Same as Chart (Auto)",
    title="Timeframe Mode",
    options=["Same as Chart (Auto)", "Custom Timeframe"],
    group=g0
)

custom_tf = input.timeframe("D", title="Custom Timeframe", group=g0)
active_tf = tf_mode == "Same as Chart (Auto)" ? timeframe.period : custom_tf

// ==========================================
// 2. MA LABEL SETTINGS
// ==========================================

g_labels = "MA Label Settings"
show_ma_labels = input.bool(true, title="Show MA Labels", group=g_labels)

label_offset = input.int(
    3,
    title="Label Offset",
    minval=0,
    maxval=100,
    group=g_labels,
    tooltip="Moves MA labels to the right of the latest candle."
)

label_size_input = input.string(
    "Small",
    title="Label Size",
    options=["Tiny", "Small", "Normal", "Large"],
    group=g_labels
)

label_size = switch label_size_input
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

// ==========================================
// 3. MA SETTINGS
// ==========================================

g1 = "1. Line Settings"
show_ma1 = input.bool(true, title="Show 1. MA", group=g1)
p1 = input.int(8, title="1. MA Period", minval=1, group=g1)
ma_type1 = input.string("EMA", title="1. MA Type", options=["EMA", "SMA"], group=g1)
color_ma1 = input.color(color.new(#4ead51, 60), title="1. MA Color", group=g1)

g2 = "2. Line Settings"
show_ma2 = input.bool(true, title="Show 2. MA", group=g2)
p2 = input.int(21, title="2. MA Period", minval=1, group=g2)
ma_type2 = input.string("EMA", title="2. MA Type", options=["EMA", "SMA"], group=g2)
color_ma2 = input.color(#4ead51, title="2. MA Color", group=g2)

g3 = "3. Line Settings"
show_ma3 = input.bool(true, title="Show 3. MA", group=g3)
p3 = input.int(50, title="3. MA Period", minval=1, group=g3)
ma_type3 = input.string("EMA", title="3. MA Type", options=["EMA", "SMA"], group=g3)
color_ma3 = input.color(#00bcd4, title="3. MA Color", group=g3)

g4 = "4. Line Settings"
show_ma4 = input.bool(true, title="Show 4. MA", group=g4)
p4 = input.int(200, title="4. MA Period", minval=1, group=g4)
ma_type4 = input.string("EMA", title="4. MA Type", options=["EMA", "SMA"], group=g4)
color_ma4 = input.color(#f23645, title="4. MA Color", group=g4)

g5 = "5. Line Settings"
show_ma5 = input.bool(false, title="Show 5. MA", group=g5)
p5 = input.int(100, title="5. MA Period", minval=1, group=g5)
ma_type5 = input.string("EMA", title="5. MA Type", options=["EMA", "SMA"], group=g5)
color_ma5 = input.color(#ff9800, title="5. MA Color", group=g5)

g6 = "6. Line Settings"
show_ma6 = input.bool(false, title="Show 6. MA", group=g6)
p6 = input.int(150, title="6. MA Period", minval=1, group=g6)
ma_type6 = input.string("EMA", title="6. MA Type", options=["EMA", "SMA"], group=g6)
color_ma6 = input.color(#9c27b0, title="6. MA Color", group=g6)

// ==========================================
// 4. CLOUD SETTINGS
// ==========================================

g_cloud = "Cloud Settings"

show_cloud1 = input.bool(true, title="Show Cloud 1 (MA1–MA2)", group=g_cloud)
color_cloud1 = input.color(color.new(#4ead51, 60), title="Cloud 1 Color (Bullish)", group=g_cloud)
color_cloud1_bear = input.color(color.new(#f23645, 60), title="Cloud 1 Color (Bearish)", group=g_cloud)

show_cloud2 = input.bool(false, title="Show Cloud 2 (MA2–MA3)", group=g_cloud)
color_cloud2 = input.color(color.new(#00bcd4, 85), title="Cloud 2 Color (Bullish)", group=g_cloud)
color_cloud2_bear = input.color(color.new(#f23645, 85), title="Cloud 2 Color (Bearish)", group=g_cloud)

show_cloud3 = input.bool(false, title="Show Cloud 3 (MA3–MA4)", group=g_cloud)
color_cloud3 = input.color(color.new(#808080, 85), title="Cloud 3 Color (Bullish)", group=g_cloud)
color_cloud3_bear = input.color(color.new(#f23645, 85), title="Cloud 3 Color (Bearish)", group=g_cloud)

show_cloud4 = input.bool(false, title="Show Cloud 4 (MA4–MA5)", group=g_cloud)
color_cloud4 = input.color(color.new(#ff9800, 85), title="Cloud 4 Color (Bullish)", group=g_cloud)
color_cloud4_bear = input.color(color.new(#f23645, 85), title="Cloud 4 Color (Bearish)", group=g_cloud)

show_cloud5 = input.bool(false, title="Show Cloud 5 (MA5–MA6)", group=g_cloud)
color_cloud5 = input.color(color.new(#9c27b0, 85), title="Cloud 5 Color (Bullish)", group=g_cloud)
color_cloud5_bear = input.color(color.new(#f23645, 85), title="Cloud 5 Color (Bearish)", group=g_cloud)

// ==========================================
// 5. CALCULATION
// ==========================================

get_ma(float source, int length, string average_type) =>
    average_type == "EMA" ? ta.ema(source, length) : ta.sma(source, length)

ma1_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p1, ma_type1), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ma2_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p2, ma_type2), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ma3_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p3, ma_type3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ma4_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p4, ma_type4), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ma5_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p5, ma_type5), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ma6_val = request.security(syminfo.tickerid, active_tf, get_ma(close, p6, ma_type6), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ==========================================
// 6. MA PLOTS
// ==========================================

ma1 = show_ma1 ? ma1_val : na
ma2 = show_ma2 ? ma2_val : na
ma3 = show_ma3 ? ma3_val : na
ma4 = show_ma4 ? ma4_val : na
ma5 = show_ma5 ? ma5_val : na
ma6 = show_ma6 ? ma6_val : na

// No linewidth argument is used. Line thickness remains editable in Style.
ma1_plot = plot(ma1, title="MA 1", color=color_ma1)
ma2_plot = plot(ma2, title="MA 2", color=color_ma2)
ma3_plot = plot(ma3, title="MA 3", color=color_ma3)
ma4_plot = plot(ma4, title="MA 4", color=color_ma4)
ma5_plot = plot(ma5, title="MA 5", color=color_ma5)
ma6_plot = plot(ma6, title="MA 6", color=color_ma6)

// ==========================================
// 7. CLOUDS
// ==========================================

cloud1_enabled = show_cloud1 and show_ma1 and show_ma2
cloud2_enabled = show_cloud2 and show_ma2 and show_ma3
cloud3_enabled = show_cloud3 and show_ma3 and show_ma4
cloud4_enabled = show_cloud4 and show_ma4 and show_ma5
cloud5_enabled = show_cloud5 and show_ma5 and show_ma6

cloud1_color = cloud1_enabled ? (ma1_val >= ma2_val ? color_cloud1 : color_cloud1_bear) : na
cloud2_color = cloud2_enabled ? (ma2_val >= ma3_val ? color_cloud2 : color_cloud2_bear) : na
cloud3_color = cloud3_enabled ? (ma3_val >= ma4_val ? color_cloud3 : color_cloud3_bear) : na
cloud4_color = cloud4_enabled ? (ma4_val >= ma5_val ? color_cloud4 : color_cloud4_bear) : na
cloud5_color = cloud5_enabled ? (ma5_val >= ma6_val ? color_cloud5 : color_cloud5_bear) : na

fill(ma1_plot, ma2_plot, color=cloud1_color, title="Cloud 1")
fill(ma2_plot, ma3_plot, color=cloud2_color, title="Cloud 2")
fill(ma3_plot, ma4_plot, color=cloud3_color, title="Cloud 3")
fill(ma4_plot, ma5_plot, color=cloud4_color, title="Cloud 4")
fill(ma5_plot, ma6_plot, color=cloud5_color, title="Cloud 5")

// ==========================================
// 8. MA LABELS
// ==========================================

update_ma_label(label current_label, bool enabled, float value, string label_text, color text_color) =>
    label result = current_label
    if enabled and not na(value)
        if na(result)
            result := label.new(
                bar_index + label_offset,
                value,
                label_text,
                xloc=xloc.bar_index,
                yloc=yloc.price,
                style=label.style_none,
                textcolor=text_color,
                size=label_size
            )
        else
            label.set_xy(result, bar_index + label_offset, value)
            label.set_text(result, label_text)
            label.set_textcolor(result, text_color)
            label.set_size(result, label_size)
    else
        if not na(result)
            label.delete(result)
            result := na
    result

var label ma1_label = na
var label ma2_label = na
var label ma3_label = na
var label ma4_label = na
var label ma5_label = na
var label ma6_label = na

if barstate.islast
    ma1_label := update_ma_label(ma1_label, show_ma_labels and show_ma1, ma1_val, ma_type1 + " " + str.tostring(p1), color_ma1)
    ma2_label := update_ma_label(ma2_label, show_ma_labels and show_ma2, ma2_val, ma_type2 + " " + str.tostring(p2), color_ma2)
    ma3_label := update_ma_label(ma3_label, show_ma_labels and show_ma3, ma3_val, ma_type3 + " " + str.tostring(p3), color_ma3)
    ma4_label := update_ma_label(ma4_label, show_ma_labels and show_ma4, ma4_val, ma_type4 + " " + str.tostring(p4), color_ma4)
    ma5_label := update_ma_label(ma5_label, show_ma_labels and show_ma5, ma5_val, ma_type5 + " " + str.tostring(p5), color_ma5)
    ma6_label := update_ma_label(ma6_label, show_ma_labels and show_ma6, ma6_val, ma_type6 + " " + str.tostring(p6), color_ma6)
````
