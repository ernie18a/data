# Daily Candles HUD

- url: https://www.tradingview.com/script/XwBBPO85-Daily-Candles-HUD/
- type: indicator
- pine_id: PUB;3fc6f7993f5249f2a5575099d32447b8
- version: 1.0

## Description

A compact visual HUD that displays the current and previous daily candles directly on your chart.

This tool is designed to give traders a quick visual reference of daily market structure and candle comparison in real time.

[b]Displayed Data[/b]

[list]
[*] [b]Today’s Candle[/b] - Open, High, Low, Close
[*] [b]Yesterday’s Candle[/b] - Open, High, Low, Close
[/list]

## Source Code

````pine
//@version=6
indicator("Daily Candles HUD", overlay = true, max_boxes_count = 100, max_lines_count = 100)

// === INPUTS ===
group_color = "Visual Settings"
bull_color  = input.color(color.new(#089981, 0), "Bullish Body Color", group=group_color)
bear_color  = input.color(color.new(#f23645, 0), "Bearish Body Color", group=group_color)
wick_color  = input.color(color.new(color.gray, 0), "Wick & Border Color", group=group_color)

group_pos   = "Position & Size"
body_width  = input.int(10, "Body Width (bars)", minval=1, group=group_pos)
off_pos     = input.string("Right", "Placement", options=["Right", "Left"], group=group_pos)
off_bars    = input.int(20, "Offset distance", minval=0, group=group_pos)
spacing     = input.int(5, "Gap between candles", minval=0, group=group_pos)
scale_factor = input.float(1, "Vertical Scale (0.01 - 1)", minval=0.001, maxval=1.0, step=0.005, group=group_pos)

group_lock  = "Motion Lock"
use_fixed   = input.bool(true, "Lock Vertical Position", group=group_lock, tooltip="If checked, the HUD stays at a fixed price level instead of moving with the ticker.")
fixed_level = input.float(0.0, "Fixed Price Level", group=group_lock, tooltip="Set this to a price level where you want the HUD to stay (e.g., a round number far from current price). If 0, it uses the first close of the day.")

// === TIMEFRAME CHECK ===
is_visible = timeframe.isintraday

// === DATA FETCHING ===
[d_o, d_h, d_l, d_c] = request.security(syminfo.tickerid, "D", [open, high, low, close], lookahead = barmerge.lookahead_on)
[y_o, y_h, y_l, y_c] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

// === SCALING LOGIC ===
// We use a stable anchor to prevent "shaking"
f_scale(price, center) =>
    center + (price - center) * scale_factor

// === OBJECT DECLARATION ===
var box  today_body = box.new(na, na, na, na, border_color=wick_color)
var line today_wick = line.new(na, na, na, na, color=wick_color, width=1)
var box  yest_body  = box.new(na, na, na, na, border_color=wick_color)
var line yest_wick  = line.new(na, na, na, na, color=wick_color, width=1)

// === UPDATE LOGIC ===
if barstate.islast
    if is_visible
        // Determine the stable center
        // If fixed_level is 0, we use today's open as a "soft lock" that doesn't change every tick
        float anchor_price = use_fixed ? (fixed_level == 0 ? d_o : fixed_level) : d_c
        
        int anchor_x = (off_pos == "Right") ? (bar_index + off_bars) : (bar_index - off_bars)
        int direction = (off_pos == "Right") ? -1 : 1
        
        // --- DRAW TODAY ---
        float s0_o = f_scale(d_o, anchor_price)
        float s0_h = f_scale(d_h, anchor_price)
        float s0_l = f_scale(d_l, anchor_price)
        float s0_c = f_scale(d_c, anchor_price)

        box.set_lefttop(today_body, anchor_x - int(math.floor(body_width / 2)), math.max(s0_o, s0_c))
        box.set_rightbottom(today_body, anchor_x - int(math.floor(body_width / 2)) + body_width, math.min(s0_o, s0_c))
        box.set_bgcolor(today_body, (d_c >= d_o) ? bull_color : bear_color)
        
        line.set_xy1(today_wick, anchor_x, s0_h)
        line.set_xy2(today_wick, anchor_x, s0_l)

        // --- DRAW YESTERDAY ---
        int x1_center = anchor_x + (direction * (body_width + spacing))
        float s1_o = f_scale(y_o, anchor_price)
        float s1_h = f_scale(y_h, anchor_price)
        float s1_l = f_scale(y_l, anchor_price)
        float s1_c = f_scale(y_c, anchor_price)

        box.set_lefttop(yest_body, x1_center - int(math.floor(body_width / 2)), math.max(s1_o, s1_c))
        box.set_rightbottom(yest_body, x1_center - int(math.floor(body_width / 2)) + body_width, math.min(s1_o, s1_c))
        box.set_bgcolor(yest_body, (y_c >= y_o) ? bull_color : bear_color)
        
        line.set_xy1(yest_wick, x1_center, s1_h)
        line.set_xy2(yest_wick, x1_center, s1_l)
    else
        // Cleanup for higher timeframes
        box.set_lefttop(today_body, na, na), box.set_rightbottom(today_body, na, na)
        line.set_xy1(today_wick, na, na), line.set_xy2(today_wick, na, na)
        box.set_lefttop(yest_body, na, na), box.set_rightbottom(yest_body, na, na)
        line.set_xy1(yest_wick, na, na), line.set_xy2(yest_wick, na, na)
````
