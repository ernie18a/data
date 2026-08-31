<!-- tradingview-pine-id: PUB;f58590654d1143f58374844b7240a071 -->
<!-- tradingviewscripts-format: 1 -->
# TWB DCA Tool

Source: https://www.tradingview.com/script/AKF79d3j-TWB-DCA-Tool/

## Description

DCA tool showing a 5 buy in Zones  and 3 Take Profit areas

---

## Source Code

````pine
//@version=6
indicator("TWB DCA Tool", overlay=true)

// 1. Identification and Setup Name
setup_name  = input.string("DCA Bracket", title="🏷️ Custom Setup Label", tooltip="Type a unique name here so you can identify this specific bracket inside your Object Tree.")

// 2. Direction and Zone Inputs
trade_dir   = input.string("Buy", title="Trade Direction", options=["Buy", "Sell"])
zone_top    = input.price(3290.0, title="Zone Top")
zone_bottom = input.price(3280.0, title="Zone Bottom")

// 3. Collapsible Manual Overrides Section (Leave at 0 for Auto-calculations)
sl_manual   = input.price(0.0, title="Manual SL Price", group="Manual Price Overrides (Optional)", tooltip="0 = Auto-calculate")
tp1_manual  = input.price(0.0, title="Manual TP 1 Price", group="Manual Price Overrides (Optional)", tooltip="0 = Auto-calculate")
tp2_manual  = input.price(0.0, title="Manual TP 2 Price", group="Manual Price Overrides (Optional)", tooltip="0 = Auto-calculate")
tp3_manual  = input.price(0.0, title="Manual TP 3 Price", group="Manual Price Overrides (Optional)", tooltip="0 = Auto-calculate")

// 4. Time Controls (RESTORED - Use these to shift and stretch the box left and right)
start_time  = input.time(timestamp("2026-08-10 00:00"), title="Box Start Time/Date", group="Time Settings")
end_time    = input.time(timestamp("2026-08-20 00:00"), title="Box End Time/Date", group="Time Settings")

// 5. Directional Math Logic
is_buy = (trade_dir == "Buy")
zone_range = zone_top - zone_bottom

// Mathematical sequence flips dynamically based on Buy/Sell direction
dca1 = is_buy ? zone_top                    : zone_bottom
dca2 = is_buy ? zone_top - (zone_range * 0.25) : zone_bottom + (zone_range * 0.25)
dca3 = is_buy ? zone_top - (zone_range * 0.50) : zone_bottom + (zone_range * 0.50)
dca4 = is_buy ? zone_top - (zone_range * 0.75) : zone_bottom + (zone_range * 0.75)
dca5 = is_buy ? zone_bottom                 : zone_top

// Auto Risk calculations invert based on Buy or Sell mode
auto_sl  = is_buy ? (zone_bottom - 3.0) : (zone_top + 3.0)

// Auto Targets scale down from zone_bottom for shorts
auto_tp1 = is_buy ? (zone_top + 3.0)     : (zone_bottom - 3.0)
auto_tp2 = is_buy ? (zone_top + 6.0)     : (zone_bottom - 6.0)
auto_tp3 = is_buy ? (zone_top + 10.0)    : (zone_bottom - 10.0)

// Apply manual overrides if they are filled in (> 0)
stop_loss = sl_manual  > 0 ? sl_manual  : auto_sl
tp1       = tp1_manual > 0 ? tp1_manual : auto_tp1
tp2       = tp2_manual > 0 ? tp2_manual : auto_tp2
tp3       = tp3_manual > 0 ? tp3_manual : auto_tp3

// Color Themes
box_color   = color.new(color.blue, 90)
box_border  = color.blue
sl_color    = color.red
tp_color    = color.green

// 6. Visual Rendering Block
if barstate.islast
    // Render the outer boundaries as a single background Box zone using manual times
    box_text = is_buy ? "Buy Zone" : "Sell Zone"
    box.new(left=start_time, top=zone_top, right=end_time, bottom=zone_bottom, xloc=xloc.bar_time, bgcolor=box_color, border_color=box_border, text=box_text, text_color=box_border, text_valign="center")
    
    // Render the 5 Internal Equal Buy-In Lines using manual times
    line.new(x1=start_time, y1=zone_top,                   x2=end_time, y2=zone_top,                   xloc=xloc.bar_time, color=box_border, style=line.style_solid, width=2)
    line.new(x1=start_time, y1=zone_top - (zone_range*0.25), x2=end_time, y2=zone_top - (zone_range*0.25), xloc=xloc.bar_time, color=box_border, style=line.style_dashed, width=1)
    line.new(x1=start_time, y1=zone_top - (zone_range*0.50), x2=end_time, y2=zone_top - (zone_range*0.50), xloc=xloc.bar_time, color=box_border, style=line.style_dashed, width=1)
    line.new(x1=start_time, y1=zone_top - (zone_range*0.75), x2=end_time, y2=zone_top - (zone_range*0.75), xloc=xloc.bar_time, color=box_border, style=line.style_dashed, width=1)
    line.new(x1=start_time, y1=zone_bottom,                x2=end_time, y2=zone_bottom,                xloc=xloc.bar_time, color=box_border, style=line.style_solid, width=2)
    
    // Render Risk/Reward Lines using manual times
    line.new(x1=start_time, y1=stop_loss, x2=end_time, y2=stop_loss, xloc=xloc.bar_time, color=sl_color,   style=line.style_solid, width=2)
    line.new(x1=start_time, y1=tp1,       x2=end_time, y2=tp1,       xloc=xloc.bar_time, color=tp_color,   style=line.style_solid, width=1)
    line.new(x1=start_time, y1=tp2,       x2=end_time, y2=tp2,       xloc=xloc.bar_time, color=tp_color,   style=line.style_solid, width=1)
    line.new(x1=start_time, y1=tp3,       x2=end_time, y2=tp3,       xloc=xloc.bar_time, color=tp_color,   style=line.style_solid, width=2)

    // Render Clean Text Labels outside the box area at the end_time coordinate
    label.new(x=end_time, y=zone_top,                    xloc=xloc.bar_time, text=(is_buy ? "Buy In 1: " : "Buy In 5: ") + str.tostring(zone_top, "#.##"),       color=box_border, textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=zone_top - (zone_range*0.25), xloc=xloc.bar_time, text=(is_buy ? "Buy In 2: " : "Buy In 4: ") + str.tostring(zone_top - (zone_range*0.25), "#.##"), color=box_border, textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=zone_top - (zone_range*0.50), xloc=xloc.bar_time, text="Buy In 3: "                           + str.tostring(zone_top - (zone_range*0.50), "#.##"), color=box_border, textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=zone_top - (zone_range*0.75), xloc=xloc.bar_time, text=(is_buy ? "Buy In 4: " : "Buy In 2: ") + str.tostring(zone_top - (zone_range*0.75), "#.##"), color=box_border, textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=zone_bottom,                 xloc=xloc.bar_time, text=(is_buy ? "Buy In 5: " : "Buy In 1: ") + str.tostring(zone_bottom, "#.##"),    color=box_border, textcolor=color.white, style=label.style_label_left)
    
    label.new(x=end_time, y=stop_loss, xloc=xloc.bar_time, text="SL: " + str.tostring(stop_loss, "#.##"),         color=sl_color,   textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=tp1,       xloc=xloc.bar_time, text="TP 1: " + str.tostring(tp1, "#.##"),             color=tp_color,   textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=tp2,       xloc=xloc.bar_time, text="TP 2: " + str.tostring(tp2, "#.##"),             color=tp_color,   textcolor=color.white, style=label.style_label_left)
    label.new(x=end_time, y=tp3,       xloc=xloc.bar_time, text="TP 3: " + str.tostring(tp3, "#.##"),             color=tp_color,   textcolor=color.white, style=label.style_label_left)
````
