# Classic Pendulum Clock

- url: https://www.tradingview.com/script/bF6T2ID7/
- type: indicator
- pine_id: PUB;7f1147653eb04b79a5132073541ec69a
- version: 2.0

## Description

Add a touch of classic elegance to your chart. A 3D-style realistic Grandfather Clock with an animated pendulum and antique textures.

While keeping track of time is essential for any trader, sometimes stepping away from serious technicals to build something purely for fun is the best way to trigger your next big coding breakthrough!

Note: The clock updates strictly based on market ticks. If the price isn't moving, the hands won't move.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ALT_analyst / Classic Pendulum Clock (Realistic Edition - Perfect Circle Bob)

//@version=6
indicator("Classic Pendulum Clock", overlay=true, max_lines_count=500, max_boxes_count=100, max_polylines_count=100, max_labels_count=100)

// === Size Settings ===
int clock_w = input.int(10, "Clock Width (Bars)", minval=5, group="Size Settings")
float v_mult = input.float(4.0, "Clock Height (ATR Multiplier)", step=0.1, group="Size Settings")

// === Position Settings ===
int h_offset = input.int(12, "Horizontal Offset (Bars)", group="Position Settings")
float v_offset = input.float(0.0, "Vertical Offset (ATR Multiplier)", step=0.5, group="Position Settings")

// === Drawing Settings ===
bool show_case = input.bool(true, "Show Wooden Case", group="Drawing Settings")
bool show_pendulum = input.bool(true, "Show Pendulum", group="Drawing Settings")

// === Color Settings ===
color col_wood_dark  = input.color(color.new(#3e2600,85), "Deep Brown (Shadow)", group="Color Settings")
color col_wood_main  = input.color(color.new(#5d4037,75), "Cocoa Brown (Main)", group="Color Settings")
color col_wood_light = input.color(color.new(#8D6E63,55), "Taupe Brown (Highlight)", group="Color Settings")
color col_face       = input.color(color.new(#FFF8E1,100), "Ivory (Face)", group="Color Settings")
color col_hands      = input.color(color.new(#000000,0), "Black (Hands)", group="Color Settings")
color col_gold       = input.color(color.new(#3e2600,0), "Deep Brown (Pendulum)", group="Color Settings")

// --- Scale Calculations ---
float atr = nz(ta.atr(14), close * 0.005)
float y_scale = atr * v_mult
int w = clock_w

// --- Drawing Arrays for Cleanup ---
var box[] my_boxes = array.new<box>()
var line[] my_lines = array.new<line>()
var polyline[] my_polys = array.new<polyline>()
var label[] my_labels = array.new<label>()

if barstate.islast
    // --- Cleanup Previous Drawings ---
    while array.size(my_boxes) > 0
        box.delete(array.pop(my_boxes))
    while array.size(my_lines) > 0
        line.delete(array.pop(my_lines))
    while array.size(my_polys) > 0
        polyline.delete(array.pop(my_polys))
    while array.size(my_labels) > 0
        label.delete(array.pop(my_labels))

    // Center coordinates for placement
    int cx = bar_index + w + h_offset
    float cy = close + (atr * v_offset)
    
    // Wood case boundaries
    float top_y = cy + y_scale
    float bottom_y = cy - y_scale * 1.8
    float head_bottom = cy + y_scale * 0.1
    
    // ==========================================
    // 1. Draw Clock Body (Realistic Wooden Case)
    // ==========================================
    if show_case
        array.push(my_boxes, box.new(cx - w, top_y, cx + w, bottom_y, border_color=na, bgcolor=col_wood_dark))
        array.push(my_boxes, box.new(cx - w, head_bottom, cx - w + 2, bottom_y, border_color=col_wood_dark, bgcolor=col_wood_main))
        array.push(my_boxes, box.new(cx + w - 2, head_bottom, cx + w, bottom_y, border_color=col_wood_dark, bgcolor=col_wood_main))
        array.push(my_boxes, box.new(cx - w - 1, bottom_y, cx + w + 1, bottom_y - y_scale * 0.15, border_color=col_wood_dark, bgcolor=col_wood_main))
        array.push(my_boxes, box.new(cx - w - 2, bottom_y - y_scale * 0.15, cx + w + 2, bottom_y - y_scale * 0.3, border_color=col_wood_dark, bgcolor=col_wood_dark))
        array.push(my_boxes, box.new(cx - w - 1, top_y, cx + w + 1, head_bottom, border_color=col_wood_dark, border_width=2, bgcolor=col_wood_main))
        array.push(my_boxes, box.new(cx - w + 1, top_y - y_scale * 0.05, cx + w - 1, head_bottom + y_scale * 0.05, border_color=na, bgcolor=col_wood_dark))
        array.push(my_boxes, box.new(cx - w - 2, top_y + y_scale * 0.1, cx + w + 2, top_y, border_color=col_wood_dark, bgcolor=col_wood_main))
        array.push(my_lines, line.new(cx - w, top_y + y_scale * 0.1, cx, top_y + y_scale * 0.3, color=col_wood_main, width=4))
        array.push(my_lines, line.new(cx + w, top_y + y_scale * 0.1, cx, top_y + y_scale * 0.3, color=col_wood_main, width=4))
        
        array<chart.point> top_ornament = array.new<chart.point>()
        array.push(top_ornament, chart.point.from_index(cx, top_y + y_scale * 0.3))
        array.push(top_ornament, chart.point.from_index(cx - 1, top_y + y_scale * 0.35))
        array.push(top_ornament, chart.point.from_index(cx + 1, top_y + y_scale * 0.35))
        array.push(top_ornament, chart.point.from_index(cx, top_y + y_scale * 0.3))
        array.push(my_polys, polyline.new(top_ornament, line_color=col_gold, line_width=2))

    // ==========================================
    // 2. Draw Clock Face
    // ==========================================
    float face_cy = cy + y_scale * 0.55
    float face_r_y = y_scale * 0.38
    float face_r_x = w * 0.8
    
    array.push(my_boxes, box.new(math.round(cx - face_r_x), face_cy + face_r_y, math.round(cx + face_r_x), face_cy - face_r_y, border_color=col_gold, border_width=2, bgcolor=col_face))

    for i = 0 to 11
        float a = i * (math.pi / 6)
        int px_inner = math.round(cx + (face_r_x * 0.8) * math.cos(a))
        float py_inner = face_cy + (face_r_y * 0.8) * math.sin(a)
        int px_outer = math.round(cx + (face_r_x * 0.95) * math.cos(a))
        float py_outer = face_cy + (face_r_y * 0.95) * math.sin(a)
        int tick_width = (i % 3 == 0) ? 3 : 1
        array.push(my_lines, line.new(px_inner, py_inner, px_outer, py_outer, color=col_hands, width=tick_width))

    // ==========================================
    // 3. Current Time and Hands
    // ==========================================
    int s = second(timenow, "Asia/Tokyo")
    int m = minute(timenow, "Asia/Tokyo")
    int h = hour(timenow, "Asia/Tokyo") % 12
    
    float s_angle = (math.pi / 2) - (s / 60.0 * 2 * math.pi)
    float m_angle = (math.pi / 2) - (m / 60.0 * 2 * math.pi)
    float h_angle = (math.pi / 2) - ((h + m / 60.0) / 12.0 * 2 * math.pi)

    float s_len_x = face_r_x * 0.9, s_len_y = face_r_y * 0.9
    float m_len_x = face_r_x * 0.85, m_len_y = face_r_y * 0.85
    float h_len_x = face_r_x * 0.55, h_len_y = face_r_y * 0.55
    float tail_x = face_r_x * 0.15, tail_y = face_r_y * 0.15

    int h_sx = math.round(cx - tail_x * math.cos(h_angle)), h_ex = math.round(cx + h_len_x * math.cos(h_angle))
    float h_sy = face_cy - tail_y * math.sin(h_angle), h_ey = face_cy + h_len_y * math.sin(h_angle)
    array.push(my_lines, line.new(h_sx, h_sy, h_ex, h_ey, color=col_hands, width=4))

    int m_sx = math.round(cx - tail_x * math.cos(m_angle)), m_ex = math.round(cx + m_len_x * math.cos(m_angle))
    float m_sy = face_cy - tail_y * math.sin(m_angle), m_ey = face_cy + m_len_y * math.sin(m_angle)
    array.push(my_lines, line.new(m_sx, m_sy, m_ex, m_ey, color=col_hands, width=3))

    int s_sx = math.round(cx - tail_x * 1.5 * math.cos(s_angle)), s_ex = math.round(cx + s_len_x * math.cos(s_angle))
    float s_sy = face_cy - tail_y * 1.5 * math.sin(s_angle), s_ey = face_cy + s_len_y * math.sin(s_angle)
    array.push(my_lines, line.new(s_sx, s_sy, s_ex, s_ey, color=color.red, width=1))

    array.push(my_lines, line.new(cx, face_cy, cx, face_cy + (y_scale * 0.01), color=col_hands, width=6))

    // ==========================================
    // 4. Pendulum Animation (The "Label" Hack for Perfect Circles)
    // ==========================================
    if show_pendulum
        float pivot_cy = head_bottom
        float pen_len_y = y_scale * 1.5
        float pen_len_x = w * 1.8

        float period = 4000.0
        float max_swing = math.pi / 14
        float phase = (timenow % period) / period * 2 * math.pi
        float current_swing = max_swing * math.sin(phase)

        int bob_x = math.round(cx + pen_len_x * math.sin(current_swing))
        float bob_y = pivot_cy - pen_len_y * math.cos(current_swing)

        array.push(my_lines, line.new(cx, pivot_cy, bob_x, bob_y, color=col_gold, width=4))

        array.push(my_labels, label.new(bob_x, bob_y, text="", style=label.style_circle, color=col_gold, size=size.large))
        array.push(my_labels, label.new(bob_x, bob_y, text="", style=label.style_circle, color=col_face, size=size.large))
        array.push(my_labels, label.new(bob_x, bob_y, text="", style=label.style_circle, color=col_gold, size=size.small))
````
