# 3D: Real Smartphone Monitor Pro

- url: https://www.tradingview.com/script/RZdAf31L/
- type: indicator
- pine_id: PUB;f0df3429415345ba83e6c51c56b01897
- version: 2.0

## Description

[b]3D Real Smartphone Monitor Pro: Master Discipline and The Art of "No Position" [/b]

[b]IMPORTANT: First-Time Setup and Size Adjustment[/b]

Because TradingView automatically scales the Y-axis (price) and X-axis (time) differently depending on the asset and your screen resolution, this 3D monitor may appear stretched, squashed, or incorrectly sized upon initial application. This is a standard limitation of projecting 3D elements onto 2D charts.

[b] How to resolve this immediately:[/b]

Open the Indicator Settings.

Navigate to the "3D Manual Scaling & Camera Settings" group.

Adjust the "Y-Axis Scale (Height)" and "X-Axis Scale (Width)" sliders.

Tweak the "Master Scale Multiplier" until the smartphone perfectly fits your screen layout.

Note: Because the optimal scale varies entirely depending on the specific asset, we have provided comprehensive manual scale adjustment settings. If you find any parameters lacking or require further adjustments, please notify us in the comments, and we will respond promptly.

[b]Concept: The Purpose of a Chart Smartphone[/b]
Trading is not solely about identifying entries; it is about mastering psychology. Overtrading is a trader's greatest adversary. This monitor serves as a visual anchor to ground you in reality and reinforce the power of discipline.

When compelled to force a trade, look at this monitor and read the scrolling proverbs. Remember that maintaining "no position" is a highly strategic position. Stepping away from the chart is frequently the most profitable decision you can make.

[b]Features and Technical Synchronization:[/b]

Time Awareness: A built-in clock keeps you grounded in reality, preventing time distortion while analyzing charts.

Battery Level (RSI Sync): The battery percentage reflects the 14-period RSI, instantly indicating market exhaustion (oversold/overbought conditions).

Antenna Signal (ADX Sync): The signal bars represent the 14-period ADX. A full signal indicates a massive trend, while a weak signal suggests a flat market—ideal for determining whether to engage or step away.

Dynamic Interface: Designed with meticulous attention to realism, featuring titanium-style edges, glass glare, a dynamic top notch, and native emoji app icons.

Stay disciplined, protect your capital, and sometimes, just put the monitor down.

Pine Script Calculation Details
Calculation: [pine]int msg_idx = int(bar_index / 20) % 10[/pine]

Mathematical Rationale: The bar_index (current candle number) is divided by 20 to create a trigger that changes the output every 20 bars. The modulo operator (% 10) ensures the resulting index loops sequentially from 0 to 9, which maps perfectly to the 10 proverb elements stored in the array.

Actual Output Values:

At bar_index 100: int(100 / 20) % 10 outputs 5 (Displays array element index 5).

At bar_index 110: int(110 / 20) % 10 outputs 5 (Message remains the same).

At bar_index 120: int(120 / 20) % 10 outputs 6 (Message switches to the next index).

## Source Code

````pine
// © ALT_analyst
// @version=6
indicator("3D: Real Smartphone Monitor Pro", overlay = true, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 100, calc_bars_count = 1000)

// ==========================================
// 1. TYPE DEFINITIONS & MATH
// ==========================================
type Point3D
    float x
    float y
    float z

type ViewportCamera
    int   anchor_x
    float anchor_y
    float cos_yaw
    float sin_yaw
    float sin_pit
    float cos_pit
    float scale_x
    float scale_y
    float scale_z

method project_to_screen(ViewportCamera this, Point3D p) =>
    float x_rot = p.x * this.cos_yaw - p.y * this.sin_yaw
    float y_rot = p.x * this.sin_yaw + p.y * this.cos_yaw
    float s_x = x_rot * this.scale_x
    float s_y = y_rot * this.sin_pit * this.scale_y - p.z * this.cos_pit * this.scale_z
    chart.point.from_index(this.anchor_x + int(s_x), this.anchor_y - s_y)

draw_quad_face(ViewportCamera cam, Point3D p1, Point3D p2, Point3D p3, Point3D p4, color border, color fill, array<polyline> p_buf) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(cam.project_to_screen(p1)), pts.push(cam.project_to_screen(p2))
    pts.push(cam.project_to_screen(p3)), pts.push(cam.project_to_screen(p4))
    p_buf.push(polyline.new(pts, closed=true, line_color=border, fill_color=fill))

draw_poly_face(ViewportCamera cam, array<Point3D> pts3d, color border, color fill, array<polyline> p_buf) =>
    array<chart.point> pts2d = array.new<chart.point>()
    for i = 0 to pts3d.size() - 1
        pts2d.push(cam.project_to_screen(array.get(pts3d, i)))
    p_buf.push(polyline.new(pts2d, closed=true, line_color=border, fill_color=fill))

// ==========================================
// 2. INPUTS & CUSTOMIZATION
// ==========================================
grp_cond = "★ Visibility"
in_show_monitor = input.bool(true, "Show Monitor", tooltip="Uncheck to hide the monitor.", group=grp_cond)

grp_anchor = "★ Anchor (Positioning) Settings"
in_anchor_mode  = input.string("Fixed at Initial Price", "Y-Axis Anchor Mode", options=["Fixed at Initial Price", "Fixed at Manual Price", "Slow Tracking via SMA"], group=grp_anchor)
in_manual_price = input.float(0.0, "Manual Price Level", group=grp_anchor)
in_anchor_ma    = input.int(500, "SMA Period for Tracking", minval=1, step=100, group=grp_anchor)

grp_custom = "★ Message Settings"
in_custom_msg = input.string("The Market is calling,", "Custom Message", group=grp_custom)
in_text_color = input.color(color.white, "Message Text Color", group=grp_custom)
in_text_size  = input.string("huge", "Message Text Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_custom)

grp_ui = "★ UI & Status Settings"
in_status_color = input.color(color.white, "Clock / Battery Color", group=grp_ui)
in_status_size  = input.string("large", "Clock / Battery Size", options=["tiny", "small", "normal", "large"], group=grp_ui)
in_icon_size    = input.string("huge", "App Icon Size", options=["small", "normal", "large", "huge"], group=grp_ui)
in_base_color   = input.color(#0f0f11, "Screen Base Color (Midnight)", group=grp_ui)
in_tech_info    = input.bool(true, "💡 Technical Indicator Sync", group=grp_ui)

grp_pos = "★ Position Adjustments"
adj_clock_x = input.float(0.0, "Clock X", step=0.5, group=grp_pos)
adj_clock_z = input.float(-0.3, "Clock Z", step=0.5, group=grp_pos)
adj_wifi_x  = input.float(6.0, "Wi-Fi X", step=0.5, group=grp_pos)
adj_wifi_z  = input.float(-0.9, "Wi-Fi Z", step=0.5, group=grp_pos)
adj_ant_x   = input.float(-3.5, "Antenna X", step=0.5, group=grp_pos)
adj_ant_z   = input.float(-0.8, "Antenna Z", step=0.5, group=grp_pos)
adj_batt_x  = input.float(3.5, "Battery X", step=0.5, group=grp_pos)
adj_batt_z  = input.float(-0.2, "Battery Z", step=0.5, group=grp_pos)
adj_icon_x  = input.float(0.0, "App Icon X", step=0.5, group=grp_pos)
adj_icon_z  = input.float(-3.5, "App Icon Z", step=0.5, group=grp_pos)
adj_dock_x  = input.float(0.0, "Dock Icon X", step=0.5, group=grp_pos)
adj_dock_z  = input.float(-1.0, "Dock Icon Z", step=0.5, group=grp_pos)
adj_msg_x   = input.float(0.0, "Message X", step=0.5, group=grp_pos)
adj_msg_z   = input.float(1.5, "Message Z", step=0.5, group=grp_pos)

grp_render = "★ 3D Manual Scaling & Camera Settings"
in_visual_shift = input.int(50, "X-Axis Shift (Left/Right)", group = grp_render)
in_master_scale = input.float(1.0, "Master Scale Multiplier", step=0.1, minval=0.1, group = grp_render, tooltip="Adjust this to scale the entire monitor up or down.")
in_cam_yaw      = input.float(1.0, "Camera Yaw", group = grp_render)
in_cam_pitch    = input.float(1.0, "Camera Pitch", group = grp_render)
in_scale_time   = input.float(4.0, "X-Axis Scale (Width)", group = grp_render, tooltip="Adjust this to fix horizontal stretching.")
in_scale_depth  = input.float(4.0, "Y-Axis Scale (Height)", group = grp_render, tooltip="Adjust this to fix vertical stretching (flatness).")
in_scale_z      = input.float(1.0, "Z-Axis Scale (Depth)", group = grp_render)

get_size(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : s == "huge" ? size.huge : size.normal

string sz_msg    = get_size(in_text_size)
string sz_status = get_size(in_status_size)
string sz_icon   = get_size(in_icon_size)

// Technical Indicators Calculation
float rsi_val = ta.rsi(close, 14) 
[di_plus, di_minus, adx_val] = ta.dmi(14, 14) 
float atr_val = ta.atr(14), float atr_avg = ta.sma(atr_val, 50)
float trend_val = ta.ema(close, 9) - ta.ema(close, 21) 

var array<string> proverbs = array.from(in_custom_msg, "Sometimes the best trade\nis no trade.", "Cut your losses short\nand let your profits run.", "The trend is your friend\nuntil it bends.", "Plan your trade and\ntrade your plan.", "Bulls make money,\nbears make money,\npigs get slaughtered.", "Don't try to catch\na falling knife.", "Buy the rumor,\nsell the news.", "Risk comes from not knowing\nwhat you're doing.", "In trading, the impossible\nhappens twice a year.")
array.set(proverbs, 0, in_custom_msg) 

// ==========================================
// 3. 3D RENDERER (Pro Edition)
// ==========================================
var array<polyline> render_polys  = array.new<polyline>()
var array<label>    render_labels = array.new<label>()

var float initial_price = na

if barstate.islast
    if na(initial_price)
        initial_price := close

    while render_polys.size() > 0 
        polyline.delete(render_polys.pop())
    while render_labels.size() > 0 
        label.delete(render_labels.pop())

    if in_show_monitor
        float rad_yaw = math.toradians(in_cam_yaw), float rad_pit = math.toradians(in_cam_pitch)
        
        // Manual Scaling Logic
        float final_scale_x = in_scale_time * in_master_scale
        float final_scale_y = in_scale_depth * in_master_scale
        float final_scale_z = in_scale_z * in_master_scale

        float anchor_price = close
        if in_anchor_mode == "Fixed at Initial Price"
            anchor_price := initial_price
        else if in_anchor_mode == "Fixed at Manual Price"
            anchor_price := in_manual_price
        else
            anchor_price := nz(ta.sma(close, in_anchor_ma), nz(close[1], close))

        ViewportCamera cam = ViewportCamera.new(bar_index + in_visual_shift, anchor_price, math.cos(rad_yaw), math.sin(rad_yaw), math.sin(rad_pit), math.cos(rad_pit), final_scale_x, final_scale_y, final_scale_z)
        
        float w = 10.0, float h = 21.0, float d = 0.6       
        float sw = w * 0.90, float sh = h * 0.92, float sd = -d - 0.1 
        float c = 1.5 

        // Realistic Colors
        color col_chassis_side = color.new(#2a2a2d, 10) 
        color col_chassis_back = color.new(#1c1c1e, 5)
        color col_screen = color.new(in_base_color, 10)
        color col_dock   = color.new(#2c2c2e, 20) 
        color col_island = color.new(#000000, 0) 

        // Chassis
        array<Point3D> p_front = array.from(Point3D.new(-w+c, -d, h), Point3D.new(w-c, -d, h), Point3D.new(w, -d, h-c), Point3D.new(w, -d, -h+c), Point3D.new(w-c, -d, -h), Point3D.new(-w+c, -d, -h), Point3D.new(-w, -d, -h+c), Point3D.new(-w, -d, h-c))
        array<Point3D> p_back = array.from(Point3D.new(-w+c, d, h), Point3D.new(w-c, d, h), Point3D.new(w, d, h-c), Point3D.new(w, d, -h+c), Point3D.new(w-c, d, -h), Point3D.new(-w+c, d, -h), Point3D.new(-w, d, -h+c), Point3D.new(-w, d, h-c))

        draw_poly_face(cam, p_back, col_chassis_side, col_chassis_back, render_polys)
        for i = 0 to 7
            int next_i = (i + 1) % 8
            draw_quad_face(cam, array.get(p_front, i), array.get(p_front, next_i), array.get(p_back, next_i), array.get(p_back, i), color.new(color.white, 80), col_chassis_side, render_polys)

        // Camera Module
        Point3D p_cam_tl = Point3D.new(w*0.4, d+0.1, h*0.8), Point3D p_cam_tr = Point3D.new(w*0.8, d+0.1, h*0.8)
        Point3D p_cam_bl = Point3D.new(w*0.4, d+0.1, h*0.5), Point3D p_cam_br = Point3D.new(w*0.8, d+0.1, h*0.5)
        draw_quad_face(cam, p_cam_tl, p_cam_tr, p_cam_br, p_cam_bl, color.new(color.gray, 50), color.new(#111111, 0), render_polys)

        // Screen Area
        float sc = c * 0.8 
        array<Point3D> p_scr = array.from(Point3D.new(-sw+sc, sd, sh), Point3D.new(sw-sc, sd, sh), Point3D.new(sw, sd, sh-sc), Point3D.new(sw, sd, -sh+sc), Point3D.new(sw-sc, sd, -sh), Point3D.new(-sw+sc, sd, -sh), Point3D.new(-sw, sd, -sh+sc), Point3D.new(-sw, sd, sh-sc))
        draw_poly_face(cam, p_scr, color.new(color.black, 100), col_screen, render_polys) 

        // Dynamic Island
        Point3D p_isl_tl = Point3D.new(-sw*0.3, sd-0.05, sh*0.95), Point3D p_isl_tr = Point3D.new(sw*0.3, sd-0.05, sh*0.95)
        Point3D p_isl_bl = Point3D.new(-sw*0.3, sd-0.05, sh*0.88), Point3D p_isl_br = Point3D.new(sw*0.3, sd-0.05, sh*0.88)
        draw_quad_face(cam, p_isl_tl, p_isl_tr, p_isl_br, p_isl_bl, col_island, col_island, render_polys)

        // Glass Glare
        Point3D p_glare_tl = Point3D.new(-sw+sc, sd-0.02, sh), Point3D p_glare_tr = Point3D.new(sw*0.2, sd-0.02, sh)
        Point3D p_glare_bl = Point3D.new(-sw+sc, sd-0.02, -sh), Point3D p_glare_br = Point3D.new(-sw*0.5, sd-0.02, -sh)
        draw_quad_face(cam, p_glare_tl, p_glare_tr, p_glare_br, p_glare_bl, color.new(color.white, 100), color.new(color.white, 92), render_polys)

        // Dock Background
        float dock_h = -sh + 4.0
        Point3D p_dock_t_l = Point3D.new(-sw * 0.9, sd - 0.05, dock_h), Point3D p_dock_t_r = Point3D.new(sw * 0.9, sd - 0.05, dock_h)
        Point3D p_dock_b_l = Point3D.new(-sw * 0.9, sd - 0.05, -sh + 0.5), Point3D p_dock_b_r = Point3D.new(sw * 0.9, sd - 0.05, -sh + 0.5)
        draw_quad_face(cam, p_dock_t_l, p_dock_t_r, p_dock_b_r, p_dock_b_l, color.new(color.white, 85), col_dock, render_polys)

        // ==========================================
        // Status Bar & Icons
        // ==========================================
        float status_y = sh * 0.92
        
        string clock_str = str.format("{0,date,HH:mm}", time)
        chart.point cp_clock = cam.project_to_screen(Point3D.new((-sw * 1) + adj_clock_x, sd - 0.5, status_y + adj_clock_z))
        render_labels.push(label.new(cp_clock, clock_str, color=color.new(color.white, 100), textcolor=in_status_color, style=label.style_label_left, size=sz_status))

        float wifi_x = (sw * -0.2) + adj_wifi_x
        chart.point cp_wifi = cam.project_to_screen(Point3D.new(wifi_x, sd - 0.1, status_y + adj_wifi_z))
        render_labels.push(label.new(cp_wifi, "🛜", color=color.new(color.white, 100), textcolor=in_status_color, style=label.style_none, size=sz_status))

        int sig_level = math.min(5, math.max(1, int(adx_val / 10))) 
        float base_ant_x = (sw * 0.5) + adj_ant_x
        float base_ant_z = status_y + adj_ant_z
        float ant_gap = 0.4, float ant_w = 0.15  
        
        for i = 1 to 5
            float bar_h = 0.2 + (i * 0.25) 
            color b_col = i <= sig_level ? in_status_color : color.new(color.gray, 60)
            Point3D pt_tl = Point3D.new(base_ant_x + (i * ant_gap) - ant_w, sd - 0.15, base_ant_z + bar_h)
            Point3D pt_tr = Point3D.new(base_ant_x + (i * ant_gap) + ant_w, sd - 0.15, base_ant_z + bar_h)
            Point3D pt_br = Point3D.new(base_ant_x + (i * ant_gap) + ant_w, sd - 0.15, base_ant_z)
            Point3D pt_bl = Point3D.new(base_ant_x + (i * ant_gap) - ant_w, sd - 0.15, base_ant_z)
            draw_quad_face(cam, pt_tl, pt_tr, pt_br, pt_bl, color.new(color.black, 100), b_col, render_polys)

        string battery_str = str.tostring(int(rsi_val)) + "%🔋"
        color col_battery = rsi_val > 70 ? color.green : (rsi_val < 30 ? color.red : in_status_color)
        float battery_x = (sw * 0.70) + adj_batt_x
        chart.point cp_battery = cam.project_to_screen(Point3D.new(battery_x, sd - 0.1, status_y + adj_batt_z))
        render_labels.push(label.new(cp_battery, battery_str, color=color.new(color.white, 100), textcolor=col_battery, style=label.style_label_right, size=sz_status))

        array<string> icons = array.from("🗺️", "🌐", "💬", "👾", "🎵", "📻", "🎬", "📷", "🏦", "💳", "⛅", "⚙️", "▶️", "🛒", "📚", "📈")
        float start_x = -sw * 0.70, float start_z = sh * 0.75, float space_x = (sw * 1.4) / 3.0, float space_z = 3.6
        for i = 0 to 15
            chart.point cp_icon = cam.project_to_screen(Point3D.new(start_x + ((i % 4) * space_x) + adj_icon_x, sd - 0.1, start_z - (int(i / 4) * space_z) + adj_icon_z))
            render_labels.push(label.new(cp_icon, array.get(icons, i), color=color.new(color.white, 100), textcolor=color.white, style=label.style_none, size=sz_icon))

        array<string> dock_icons = array.from("📞", "✉️", "🧭", "🍎")
        for i = 0 to 3
            chart.point cp_dock_icon = cam.project_to_screen(Point3D.new(start_x + (i * space_x) + adj_dock_x, sd - 0.1, dock_h - 1.8 + adj_dock_z))
            render_labels.push(label.new(cp_dock_icon, array.get(dock_icons, i), color=color.new(color.white, 100), textcolor=color.white, style=label.style_none, size=sz_icon))

        int msg_idx = int(bar_index / 20) % 10 
        chart.point cp_text = cam.project_to_screen(Point3D.new(0 + adj_msg_x, sd - 0.1, dock_h + 3.0 + adj_msg_z))
        render_labels.push(label.new(cp_text, array.get(proverbs, msg_idx), color=color.new(color.black, 100), textcolor=in_text_color, style=label.style_label_center, size=sz_msg, textalign=text.align_center))
````
