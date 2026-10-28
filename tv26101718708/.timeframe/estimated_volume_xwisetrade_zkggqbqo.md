# Estimated Volume [XWiseTrade]

- url: https://www.tradingview.com/script/ZkGGQbqO-Estimated-Volume-XWiseTrade/
- type: indicator
- pine_id: PUB;12b44347f82f40d1a78959daa2f80314
- version: 1.0

## Description

Real-time projected volume for current and higher timeframes.

This indicator estimates the final volume of the current candle (and 3 selectable HTFs) based on elapsed time—perfect for spotting unusual activity early.

Features:
• Live estimated volume for current TF + 3 higher TFs
• Customizable table position
• Volume surge alert (when estimated volume exceeds previous candle by X%)
• Lightweight and accurate

Ideal for volume profile traders, breakout hunters, and anyone watching institutional activity.

## Source Code

````pine
//@version=6
indicator("Estimated Volume [XWiseTrade]",  overlay=true)

// === INPUTS ===
group_display = "Display Settings"
tablePosition = input.string("Bottom Right", "Table Position", 
     options=["Top Left", "Bottom Left", "Top Right", "Bottom Right", "Top Center", "Bottom Center", "Middle Left", "Middle Right"], 
     group=group_display)

group_htf = "Higher Timeframe Settings"
htf1_input = input.timeframe("60", "Higher TF 1 (HTF 1)", group=group_htf)
htf2_input = input.timeframe("240", "Higher TF 2 (HTF 2)", group=group_htf)
htf3_input = input.timeframe("D", "Higher TF 3 (HTF 3)", group=group_htf)

group_alert = "Alert Settings"
percentage_increase_input = input.float(50.0, "Estimated Volume Increase Threshold (%)", minval=0, step=10, 
     group=group_alert, 
     tooltip="Alert triggers when estimated volume exceeds previous candle's actual volume by this percentage. E.g., 50 = 50% increase.")

// === REUSABLE FUNCTION: Calculate estimated volume for any timeframe ===
getEstimatedVolume(string tf) =>
    ticker_id = ticker.new(syminfo.prefix, syminfo.ticker)
    [bar_start_time, htf_volume_so_far] = request.security(ticker_id, tf, [time, volume], lookahead=barmerge.lookahead_on)

    total_duration = timeframe.in_seconds(tf)
    time_elapsed = (timenow - bar_start_time) / 1000.0  // seconds
    
    estimated_final_volume = float(na)
    if time_elapsed > 0 and htf_volume_so_far > 0
        estimated_final_volume := htf_volume_so_far * (total_duration / time_elapsed)
    
    estimated_final_volume

// === CALCULATIONS ===
est_current_tf_vol = getEstimatedVolume(timeframe.period)
est_htf1_vol = getEstimatedVolume(htf1_input)
est_htf2_vol = getEstimatedVolume(htf2_input)
est_htf3_vol = getEstimatedVolume(htf3_input)

// === FORMAT LARGE NUMBERS (K/M) ===
formatNumber(float val) =>
    if val >= 1000000
        str.tostring(val / 1000000, "#.##") + "M"
    else if val >= 1000
        str.tostring(val / 1000, "#.##") + "K"
    else
        str.tostring(val, "#")

// === TABLE DISPLAY ===
if barstate.islast
    // Map user selection to Pine position
    pos = switch tablePosition
        "Top Left"       => position.top_left
        "Bottom Left"    => position.bottom_left
        "Top Right"      => position.top_right
        "Top Center"     => position.top_center
        "Bottom Center"  => position.bottom_center
        "Middle Left"    => position.middle_left
        "Middle Right"   => position.middle_right
        => position.bottom_right  // default

    var table vol_table = table.new(pos, 2, 5, border_width=1, frame_color=color.gray, frame_width=1, bgcolor=color.new(color.white, 90))

    table.cell(vol_table, 0, 0, "Timeframe",      text_color=color.white, bgcolor=color.new(#d32f2f, 0))
    table.cell(vol_table, 1, 0, "Estimated Vol",  text_color=color.white, bgcolor=color.new(#d32f2f, 0))
    table.cell(vol_table, 0, 1, "Current " + timeframe.period, text_halign=text.align_left)
    table.cell(vol_table, 1, 1, formatNumber(est_current_tf_vol), text_halign=text.align_right)
    table.cell(vol_table, 0, 2, htf1_input, text_halign=text.align_left)
    table.cell(vol_table, 1, 2, formatNumber(est_htf1_vol), text_halign=text.align_right)
    table.cell(vol_table, 0, 3, htf2_input, text_halign=text.align_left)
    table.cell(vol_table, 1, 3, formatNumber(est_htf2_vol), text_halign=text.align_right)
    table.cell(vol_table, 0, 4, htf3_input, text_halign=text.align_left)
    table.cell(vol_table, 1, 4, formatNumber(est_htf3_vol), text_halign=text.align_right)

// === ALERT LOGIC (with 60-second delay to avoid false triggers) ===
previous_bar_volume = volume[1]
dynamic_threshold = previous_bar_volume * (1 + percentage_increase_input / 100.0)
time_elapsed_sec = (timenow - time) / 1000.0

alert_condition = time_elapsed_sec > 60 and est_current_tf_vol > dynamic_threshold and previous_bar_volume > 0

// Invisible plots for alert compatibility
plot(est_current_tf_vol, display=display.none)
plot(previous_bar_volume, display=display.none)

// Alert
alertcondition(alert_condition, title="Estimated Volume Surge Alert", message="Estimated volume has surged significantly!")
````
