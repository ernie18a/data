# Opening Range - Predictive Targets + Prices

- url: https://www.tradingview.com/script/lQff3Xbx-Opening-Range-Predictive-Targets-Prices/
- type: indicator
- pine_id: PUB;69ca60db0f2f457faa1d963af81e8701
- version: 1.0

## Description

An Opening Range indicator that automatically identifies the opening range, plots its key levels and generates predictive upside and downside targets based on the range size.

Designed for intraday traders who use Opening Range Breakout (ORB) strategies and want objective profit targets throughout the trading session.

[b]How It Works[/b]

The indicator captures the selected Opening Range window and calculates:

[list]
[*] [b]ORH[/b] - Opening Range High
[*] [b]ORL[/b] - Opening Range Low
[*] [b]ORM[/b] - Opening Range Midpoint
[/list]

Once the Opening Range is completed, the levels are extended throughout the session and predictive targets are automatically generated whenever price breaks above ORH or below ORL.

[b]Predictive Targets[/b]

Targets are projected using the Opening Range size as the measurement unit.

[list]
[*] [b]100% Mode[/b] - Each target equals one full Opening Range.
[*] [b]50% Mode[/b] - Each target equals half of the Opening Range.
[*] Automatic bullish targets above ORH.
[*] Automatic bearish targets below ORL.
[*] Configurable maximum number of targets per session.
[/list]

[b]Features[/b]

[list]
[*] Automatic Opening Range detection.
[*] Custom session and timezone support.
[*] Dynamic OR High, OR Low and Midpoint levels.
[*] Automatic target generation after breakout confirmation.
[*] Independent bullish and bearish target projections.
[*] Optional price values displayed directly on labels.
[*] Custom label positioning for Opening Range levels and targets.
[*] Fully customizable line styles, colors and thickness.
[*] Optional historical sessions display.
[/list]

## Source Code

````pine
//@version=6
indicator("Opening Range - Predictive Targets + Prices", shorttitle="OR Pro", overlay=true, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------{
// INPUTS
//---------------------------------------------------------------------------------------------------------------------{
grp_sesh    = "Session Settings"
rth_full    = input.session("0930-1600", "Session", group=grp_sesh)
or_window   = input.session("0930-0935", "Opening Range Window", group=grp_sesh)
tz          = input.string("UTC-4", "Timezone", group=grp_sesh, options=["UTC-12", "UTC-11", "UTC-10", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+6", "UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12"])

grp_targets = "Target Settings"
enableT     = input.bool(true, "Enable Targets", group=grp_targets)
tSizePerc   = input.string("100%", "Target Size", options=["50%", "100%"], group=grp_targets)
bullColor   = input.color(color.new(#00897b, 0), "Bullish Target Color", group=grp_targets)
bearColor   = input.color(color.new(#f44336, 0), "Bearish Target Color", group=grp_targets)
tWidth      = input.int(1, "Target Thickness", minval=1, group=grp_targets)
tStyleStr   = input.string("Dotted", "Target Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_targets)
maxTPerDay  = input.int(10, "Max Targets per Side", minval=1, maxval=50, group=grp_targets)

grp_labels  = "Label Customization"
showPrice   = input.bool(true, "Show Price Values", group=grp_labels)
// Swapped defaults as requested: OR to Right, Targets to Left
orLblPos    = input.string("Right (Dynamic)", "OR Levels Label Position", options=["Left (Start)", "Right (Dynamic)"], group=grp_labels)
targetLblPos = input.string("Left (Start)", "Target Label Position", options=["Left (Start)", "Right (Dynamic)"], group=grp_labels)

grp_style_or = "Level Lines Style (High/Low/Mid)"
orColor      = input.color(#2962ff, "OR Levels Color", group=grp_style_or)
midColor     = input.color(#2962ff, "Midpoint Color", group=grp_style_or)
orWidth      = input.int(1, "Line Thickness", minval=1, group=grp_style_or)

grp_dual_box = "Box Background Colors"
colorCapture = input.color(color.new(#2962ff, 65), "Capture Window Background", group=grp_dual_box)
colorExten   = input.color(color.new(#2962ff, 85), "Extension Background", group=grp_dual_box)

showHist     = input.bool(true, "Show Historical Data", group="General")

// Helper for line style selection
targetStyle = tStyleStr == "Solid" ? line.style_solid : tStyleStr == "Dashed" ? line.style_dashed : line.style_dotted

//---------------------------------------------------------------------------------------------------------------------{
// LOGIC - SESSION DETECTION
//---------------------------------------------------------------------------------------------------------------------{
in_rth_full  = not na(time(timeframe.period, rth_full, tz))
in_or_window = not na(time(timeframe.period, or_window, tz))
or_start     = in_or_window and not in_or_window[1]
or_end       = in_or_window[1] and not in_or_window

//---------------------------------------------------------------------------------------------------------------------{
// VARIABLES & ARRAYS
//---------------------------------------------------------------------------------------------------------------------{
var float orh = na
var float orl = na
var int   or_start_bar = na
var box   box_capture = na
var box   box_exten   = na
var line  h_line = na, var line l_line = na, var line m_line = na
var label h_lbl  = na, var label l_lbl  = na, var label m_lbl  = na

var line[]  current_session_targets = array.new_line()
var label[] current_session_labels  = array.new_label()
var int     last_t_up = 0
var int     last_t_dn = 0

// Reset logic for new session
if or_start
    if not showHist
        box.delete(box_capture), box.delete(box_exten)
        line.delete(h_line), line.delete(l_line), line.delete(m_line)
        label.delete(h_lbl), label.delete(l_lbl), label.delete(m_lbl)
        if array.size(current_session_targets) > 0
            for i = 0 to array.size(current_session_targets) - 1
                line.delete(array.get(current_session_targets, i))
                label.delete(array.get(current_session_labels, i))
    
    array.clear(current_session_targets), array.clear(current_session_labels)
    orh := high, orl := low, or_start_bar := bar_index
    last_t_up := 0, last_t_dn := 0
    
    // Initialize session drawing objects
    box_capture := box.new(bar_index, orh, bar_index, orl, bgcolor=colorCapture, border_width=0)
    h_line := line.new(bar_index, orh, bar_index, orh, color=orColor, width=orWidth)
    l_line := line.new(bar_index, orl, bar_index, orl, color=orColor, width=orWidth)
    m_line := line.new(bar_index, (orh + orl) / 2, bar_index, (orh + orl) / 2, color=midColor, width=1, style=line.style_dashed)
    
    // Create base labels (ORH, ORL, Mid) with independent positioning
    l_x_or    = orLblPos == "Left (Start)" ? or_start_bar : bar_index
    l_styl_or = orLblPos == "Left (Start)" ? label.style_label_right : label.style_label_left
    h_lbl  := label.new(l_x_or, orh, "ORH", color=color.new(color.white, 100), textcolor=orColor, style=l_styl_or, size=size.small)
    l_lbl  := label.new(l_x_or, orl, "ORL", color=color.new(color.white, 100), textcolor=orColor, style=l_styl_or, size=size.small)
    m_lbl  := label.new(l_x_or, (orh + orl) / 2, "Mid", color=color.new(color.white, 100), textcolor=midColor, style=l_styl_or, size=size.small)
    
    box_exten := na

//---------------------------------------------------------------------------------------------------------------------{
// UPDATES & PREDICTIVE TARGETS
//---------------------------------------------------------------------------------------------------------------------{
or_range = orh - orl
target_step = (tSizePerc == "100%" ? or_range : or_range * 0.5)

// Update values during the opening range window
if in_or_window
    orh := math.max(high, orh), orl := math.min(low, orl)
    mid = (orh + orl) / 2
    box.set_top(box_capture, orh), box.set_bottom(box_capture, orl), box.set_right(box_capture, bar_index)
    line.set_xy1(h_line, or_start_bar, orh), line.set_xy2(h_line, bar_index, orh)
    line.set_xy1(l_line, or_start_bar, orl), line.set_xy2(l_line, bar_index, orl)
    line.set_xy1(m_line, or_start_bar, mid), line.set_xy2(m_line, bar_index, mid)
    
    // Refresh base labels during capture period
    l_x_or = orLblPos == "Left (Start)" ? or_start_bar : bar_index
    label.set_xy(h_lbl, l_x_or, orh)
    label.set_text(h_lbl, "ORH" + (showPrice ? " (" + str.tostring(orh, format.mintick) + ")" : ""))
    label.set_xy(l_lbl, l_x_or, orl)
    label.set_text(l_lbl, "ORL" + (showPrice ? " (" + str.tostring(orl, format.mintick) + ")" : ""))
    label.set_xy(m_lbl, l_x_or, mid)
    label.set_text(m_lbl, "ORM" + (showPrice ? " (" + str.tostring(mid, format.mintick) + ")" : ""))

// End of opening range window
if or_end
    box_exten := box.new(bar_index, orh, bar_index, orl, bgcolor=colorExten, border_width=0)

// Extension logic after OR window
if in_rth_full and not in_or_window and not na(orh)
    box.set_right(box_exten, bar_index)
    line.set_x2(h_line, bar_index), line.set_x2(l_line, bar_index), line.set_x2(m_line, bar_index)
    
    // Update OR labels position if set to Dynamic
    if orLblPos == "Right (Dynamic)"
        label.set_x(h_lbl, bar_index)
        label.set_x(l_lbl, bar_index)
        label.set_x(m_lbl, bar_index)

    if enableT and or_range > 0
        // BULLISH PREDICTIVE TARGETS
        if high >= orh and last_t_up < maxTPerDay
            num_t_needed = math.floor((high - orh) / target_step) + 1
            num_t_needed := math.min(num_t_needed, maxTPerDay)
            if num_t_needed > last_t_up
                for i = last_t_up + 1 to int(num_t_needed)
                    t_val = orh + (i * target_step)
                    l = line.new(or_start_bar, t_val, bar_index, t_val, color=bullColor, width=tWidth, style=targetStyle)
                    l_x_t    = targetLblPos == "Left (Start)" ? or_start_bar : bar_index
                    l_styl_t = targetLblPos == "Left (Start)" ? label.style_label_right : label.style_label_left
                    t_text   = "T" + str.tostring(i) + (showPrice ? " (" + str.tostring(t_val, format.mintick) + ")" : "")
                    lbl = label.new(l_x_t, t_val, t_text, color=color.new(color.white, 100), textcolor=bullColor, style=l_styl_t, size=size.small)
                    array.push(current_session_targets, l), array.push(current_session_labels, lbl)
                last_t_up := int(num_t_needed)

        // BEARISH PREDICTIVE TARGETS
        if low <= orl and last_t_dn < maxTPerDay
            num_t_needed = math.floor((orl - low) / target_step) + 1
            num_t_needed := math.min(num_t_needed, maxTPerDay)
            if num_t_needed > last_t_dn
                for i = last_t_dn + 1 to int(num_t_needed)
                    t_val = orl - (i * target_step)
                    l = line.new(or_start_bar, t_val, bar_index, t_val, color=bearColor, width=tWidth, style=targetStyle)
                    l_x_t    = targetLblPos == "Left (Start)" ? or_start_bar : bar_index
                    l_styl_t = targetLblPos == "Left (Start)" ? label.style_label_right : label.style_label_left
                    t_text   = "T" + str.tostring(i) + (showPrice ? " (" + str.tostring(t_val, format.mintick) + ")" : "")
                    lbl = label.new(l_x_t, t_val, t_text, color=color.new(color.white, 100), textcolor=bearColor, style=l_styl_t, size=size.small)
                    array.push(current_session_targets, l), array.push(current_session_labels, lbl)
                last_t_dn := int(num_t_needed)

    // Update target lines and dynamic labels
    if array.size(current_session_targets) > 0
        for i = 0 to array.size(current_session_targets) - 1
            line.set_x2(array.get(current_session_targets, i), bar_index)
            if targetLblPos == "Right (Dynamic)"
                label.set_x(array.get(current_session_labels, i), bar_index)
````
