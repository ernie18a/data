# Levels of Fear (KenshinC)

- url: https://www.tradingview.com/script/kCuV6Vp1-Levels-of-Fear-KenshinC/
- type: indicator
- pine_id: PUB;12893a650f754b0bace8ef37753df06c
- version: 1.0

## Description

═══════════════════════════════════════════════════════════════════════════════
[b]//  Levels of Fear (KenshinC)[/b]
// ═══════════════════════════════════════════════════════════════════════════════
//
//  "When fear rises, opportunities appear."
//
//  This indicator visualizes 9 psychological levels of fear during market declines.
//  It automatically detects significant price drops and marks clear fear zones 
//  from "Calm" to "Disaster", helping traders identify potential support areas 
//  and emotional market extremes.
//
[b]//  Key Features:[/b]
//  • 3 Flexible Calculation Modes: Auto, Manual, and Percent Drop
//  • Smart Fear Detection with stability filter (avoids false signals in choppy markets)
//  • Prolonged Fear Levels: Levels stay fixed after a fear phase ends for better reference
//  • Two Display Modes: 
//      - Cool Guys Mode → Fun Vietnamese-inspired emotional labels with emojis
//      - Serious Guys Mode → Clean numbered levels for professional traders
//  • Performance Optimized: Only 9 plots + toggleable labels and levels
//  • Customizable percent drops and stability settings
//
//  Perfect for swing traders, scalpers, and anyone who wants to trade the psychology 
//  of fear and greed in crypto, stocks, or forex.
//
[b]//  Use it to:[/b]
//  - Spot hidden support during panic selling
//  - Avoid catching falling knives too early
//  - Visualize market sentiment in real time
//
//  Stay calm. Trade smart.
//
//  Made with passion by KenshinC 🇻🇳
// ═══════════════════════════════════════════════════════════════════════════════

## Source Code

````pine
//@version=5
indicator("Levels of Fear (KenshinC)", overlay=true, max_labels_count=250, max_lines_count=250)

// === INPUTS ===
length          = input.int(defval=50,  minval=10, maxval=2000, title="Length (for Auto Mode)")
stability       = input.int(defval=10,  minval=5,  maxval=100,  title="Levels Stability")
mode            = input.string(defval="Cool Guys Mode", options=['Cool Guys Mode', 'Serious Guys Mode'], title="Display Mode")
calc_mode       = input.string(defval="Auto", options=['Auto', 'Manual', 'Percent'], title="Calculation Mode")

manual_high     = input.float(defval=100.0, title="Manual Highest Level", minval=0, step=0.1, group="Manual/Percent Settings")
manual_low      = input.float(defval=10.0,  title="Manual Lowest Level", minval=0, step=0.1, group="Manual/Percent Settings")

percent_drop_1  = input.float(defval=10.0, title="Percent Drop for Fear Level 1",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_2  = input.float(defval=20.0, title="Percent Drop for Fear Level 2",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_3  = input.float(defval=30.0, title="Percent Drop for Fear Level 3",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_4  = input.float(defval=40.0, title="Percent Drop for Fear Level 4",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_5  = input.float(defval=50.0, title="Percent Drop for Fear Level 5",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_6  = input.float(defval=60.0, title="Percent Drop for Fear Level 6",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_7  = input.float(defval=70.0, title="Percent Drop for Fear Level 7",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_8  = input.float(defval=80.0, title="Percent Drop for Fear Level 8",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")
percent_drop_9  = input.float(defval=90.0, title="Percent Drop for Fear Level 9",  minval=0, maxval=100, step=0.1, group="Percent Mode Settings")

// === DISPLAY SETTINGS ===
show_fear_levels = input.bool(true,  title="Show Fear Levels", group="Display Settings")
show_labels      = input.bool(true,  title="Show Emotion Labels", group="Display Settings")

// === CALCULATE CURRENT HIGH & FEAR LEVELS ===
current_high = calc_mode == "Auto" ? ta.highest(high, length) : manual_high

float fear_level_1 = na
float fear_level_2 = na
float fear_level_3 = na
float fear_level_4 = na
float fear_level_5 = na
float fear_level_6 = na
float fear_level_7 = na
float fear_level_8 = na
float fear_level_9 = na

if calc_mode == "Auto"
    step_size = current_high / 10
    fear_level_1 := current_high - 1 * step_size
    fear_level_2 := current_high - 2 * step_size
    fear_level_3 := current_high - 3 * step_size
    fear_level_4 := current_high - 4 * step_size
    fear_level_5 := current_high - 5 * step_size
    fear_level_6 := current_high - 6 * step_size
    fear_level_7 := current_high - 7 * step_size
    fear_level_8 := current_high - 8 * step_size
    fear_level_9 := current_high - 9 * step_size

else if calc_mode == "Manual"
    step_size = (current_high - manual_low) / 9
    fear_level_1 := current_high - 1 * step_size
    fear_level_2 := current_high - 2 * step_size
    fear_level_3 := current_high - 3 * step_size
    fear_level_4 := current_high - 4 * step_size
    fear_level_5 := current_high - 5 * step_size
    fear_level_6 := current_high - 6 * step_size
    fear_level_7 := current_high - 7 * step_size
    fear_level_8 := current_high - 8 * step_size
    fear_level_9 := current_high - 9 * step_size

else if calc_mode == "Percent"
    fear_level_1 := current_high * (1 - percent_drop_1 / 100)
    fear_level_2 := current_high * (1 - percent_drop_2 / 100)
    fear_level_3 := current_high * (1 - percent_drop_3 / 100)
    fear_level_4 := current_high * (1 - percent_drop_4 / 100)
    fear_level_5 := current_high * (1 - percent_drop_5 / 100)
    fear_level_6 := current_high * (1 - percent_drop_6 / 100)
    fear_level_7 := current_high * (1 - percent_drop_7 / 100)
    fear_level_8 := current_high * (1 - percent_drop_8 / 100)
    fear_level_9 := current_high * (1 - percent_drop_9 / 100)

// === VALIDATION ===
if calc_mode == "Percent" and (percent_drop_1 >= percent_drop_2 or percent_drop_2 >= percent_drop_3 or percent_drop_3 >= percent_drop_4 or percent_drop_4 >= percent_drop_5 or percent_drop_5 >= percent_drop_6 or percent_drop_6 >= percent_drop_7 or percent_drop_7 >= percent_drop_8 or percent_drop_8 >= percent_drop_9)
    runtime.error("Percent drops must be in ascending order (Level 1 < Level 2 < ... < Level 9)")

if calc_mode == "Manual" and current_high <= manual_low
    runtime.error("Highest Level must be greater than Lowest Level")

// === FEAR CONDITION ===
price_drop_condition = close < ta.highest(high, length) * 0.95
current_high_stable  = math.abs(ta.highest(current_high, stability) - ta.lowest(current_high, stability)) < (current_high * 0.01)
condition1           = price_drop_condition and current_high_stable

plotchar(condition1, char="●", location=location.top, color=color.yellow, size=size.tiny, title="Condition1 Debug")

// === PROLONGATE LOGIC (Optimized) ===
fear_start = condition1 and not condition1[1]

prev_fear_level_1 = ta.valuewhen(fear_start, fear_level_1, 0)
prev_fear_level_2 = ta.valuewhen(fear_start, fear_level_2, 0)
prev_fear_level_3 = ta.valuewhen(fear_start, fear_level_3, 0)
prev_fear_level_4 = ta.valuewhen(fear_start, fear_level_4, 0)
prev_fear_level_5 = ta.valuewhen(fear_start, fear_level_5, 0)
prev_fear_level_6 = ta.valuewhen(fear_start, fear_level_6, 0)
prev_fear_level_7 = ta.valuewhen(fear_start, fear_level_7, 0)
prev_fear_level_8 = ta.valuewhen(fear_start, fear_level_8, 0)
prev_fear_level_9 = ta.valuewhen(fear_start, fear_level_9, 0)

float displayed_level_1 = condition1 ? fear_level_1 : prev_fear_level_1
float displayed_level_2 = condition1 ? fear_level_2 : prev_fear_level_2
float displayed_level_3 = condition1 ? fear_level_3 : prev_fear_level_3
float displayed_level_4 = condition1 ? fear_level_4 : prev_fear_level_4
float displayed_level_5 = condition1 ? fear_level_5 : prev_fear_level_5
float displayed_level_6 = condition1 ? fear_level_6 : prev_fear_level_6
float displayed_level_7 = condition1 ? fear_level_7 : prev_fear_level_7
float displayed_level_8 = condition1 ? fear_level_8 : prev_fear_level_8
float displayed_level_9 = condition1 ? fear_level_9 : prev_fear_level_9

// === PLOT FEAR LEVELS (Only 9 plots for better performance) ===
plot(show_fear_levels ? displayed_level_1 : na, color=color.red, linewidth=1, title="Fear Level 1")
plot(show_fear_levels ? displayed_level_2 : na, color=color.red, linewidth=1, title="Fear Level 2")
plot(show_fear_levels ? displayed_level_3 : na, color=color.red, linewidth=1, title="Fear Level 3")
plot(show_fear_levels ? displayed_level_4 : na, color=color.red, linewidth=2, title="Fear Level 4")
plot(show_fear_levels ? displayed_level_5 : na, color=color.red, linewidth=2, title="Fear Level 5")
plot(show_fear_levels ? displayed_level_6 : na, color=color.red, linewidth=2, title="Fear Level 6")
plot(show_fear_levels ? displayed_level_7 : na, color=color.red, linewidth=3, title="Fear Level 7")
plot(show_fear_levels ? displayed_level_8 : na, color=color.red, linewidth=3, title="Fear Level 8")
plot(show_fear_levels ? displayed_level_9 : na, color=color.red, linewidth=3, title="Fear Level 9")

// === LABELS ===
draw_label_condition = condition1 and show_labels
coolmode = mode == "Cool Guys Mode"

// Cool Guys Mode - Emotional Labels
if coolmode and draw_label_condition
    label.new(bar_index, fear_level_1, "😌 Calm",          style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_2, "🤔 Thinking",      style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_3, "🤨 Doubt",         style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_4, "😮 Mild Shock",    style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_5, "🤬 Anger",         style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_6, "😖 Pain",          style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_7, "😱 Panic",         style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_8, "😵 Collapse",      style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)
    label.new(bar_index, fear_level_9, "💀 Disaster",      style=label.style_label_left, textcolor=color.white, color=color.black, size=size.normal)

// Serious Guys Mode - Number Labels (Fixed local scope issue)
plotchar(not coolmode and draw_label_condition ? fear_level_1 : na, location=location.absolute, char="1", size=size.small, title="Fear Level 1")
plotchar(not coolmode and draw_label_condition ? fear_level_2 : na, location=location.absolute, char="2", size=size.small, title="Fear Level 2")
plotchar(not coolmode and draw_label_condition ? fear_level_3 : na, location=location.absolute, char="3", size=size.small, title="Fear Level 3")
plotchar(not coolmode and draw_label_condition ? fear_level_4 : na, location=location.absolute, char="4", size=size.small, title="Fear Level 4")
plotchar(not coolmode and draw_label_condition ? fear_level_5 : na, location=location.absolute, char="5", size=size.small, title="Fear Level 5")
plotchar(not coolmode and draw_label_condition ? fear_level_6 : na, location=location.absolute, char="6", size=size.small, title="Fear Level 6")
plotchar(not coolmode and draw_label_condition ? fear_level_7 : na, location=location.absolute, char="7", size=size.small, title="Fear Level 7")
plotchar(not coolmode and draw_label_condition ? fear_level_8 : na, location=location.absolute, char="8", size=size.small, title="Fear Level 8")
plotchar(not coolmode and draw_label_condition ? fear_level_9 : na, location=location.absolute, char="9", size=size.small, title="Fear Level 9")
````
