# Stochastic Radar Multi Time Frame [K & D]

- url: https://www.tradingview.com/script/3dVloKbb-Stochastic-Radar-Multi-Time-Frame-K-D/
- type: indicator
- pine_id: PUB;e1039407481d4b928281dd3f7a469a2e
- version: 1.0

## Description

hat tip © LonesomeTheBlue

A multi-timeframe radar / spider chart that plots both %K and %D of the Stochastic Oscillator across 6 different timeframes simultaneously on one visual "hexagon" shape. 
Blue line = %K
Orange line = %D

The shape expands/contracts based on the Stochastic values (higher = further from center)
Shaded zones show Overbought (red) and Oversold (green) areas
Labels show current K/D values + timeframe
Small circles mark the position of K and D

Main Features
Clean hexagonal radar layout
Separate %K and %D polylines
Independent toggles for labels and circles
Custom OB/OS levels
Works on any chart timeframe

Primary Use Cases
Quick Multi-Timeframe Momentum Overview
Instantly see if the asset is overbought/oversold across multiple timeframes at once (e.g. 1m, 5m, 15m, 1H, 4H, Daily).

Divergence & Alignment Detection
Great for spotting when %K and %D are diverging or when higher timeframes are embedded (strongly trending).

Confluence Trading
Traders look for situations where multiple arms are in extreme zones (e.g. all higher TFs showing Bull Embedded) before taking a position.

Scalping / Swing Trading Filter
Helps avoid counter-trend trades by showing when lower timeframes are fighting higher timeframes.

Best used when you want a fast visual "snapshot" of momentum alignment across timeframes without switching charts.

## Source Code

````pine
//@version=6
indicator('Stochastic Radar Multi Time Frame [K & D]', overlay = true)

// === INPUTS ===
T1 = input.timeframe(defval = '1', title = 'TF 1')
T2 = input.timeframe(defval = '3', title = 'TF 2')
T3 = input.timeframe(defval = '15', title = 'TF 3')
T4 = input.timeframe(defval = '60', title = 'TF 4')
T5 = input.timeframe(defval = '240', title = 'TF 5')
T6 = input.timeframe(defval = '1D', title = 'TF 6')

kColor = input.color(defval = color.blue, title = '%K Color', group = 'Colors')
dColor = input.color(defval = color.orange, title = '%D Color', group = 'Colors')
kWidth = input.int(defval = 3, title = '%K Width', minval = 1, maxval = 10, group = 'Style')
dWidth = input.int(defval = 2, title = '%D Width', minval = 1, maxval = 10, group = 'Style')
curved = input.bool(defval = true, title = 'Curved Lines', group = 'Style')

obcolor = input.color(defval = color.new(color.red, 70), title = 'OB Zone', group = 'Levels')
oscolor = input.color(defval = color.new(color.green, 70), title = 'OS Zone', group = 'Levels')
oblevel = input.float(defval = 80, title = 'Overbought Level', minval = 51, maxval = 99, step = 1, group = 'Levels')
oslevel = input.float(defval = 20, title = 'Oversold Level', minval = 1, maxval = 49, step = 1, group = 'Levels')

showLabels = input.bool(defval = true, title = 'Show Labels (Info)', group = 'Display Options')
showCircles = input.bool(defval = true, title = 'Show Circles (Dots)', group = 'Display Options')

len = input.int(defval = 14, title = 'K Length', minval = 1, group = 'Stoch Settings')
smooK = input.int(defval = 3, title = 'K Smoothing', minval = 1, group = 'Stoch Settings')
smooD = input.int(defval = 3, title = 'D Smoothing', minval = 1, group = 'Stoch Settings')

// === CHART SETUP ===
var times = array.new_int(0)
if barstate.isnew
    array.push(times, time)

leftidx = array.indexof(times, chart.left_visible_bar_time)
rightidx = array.indexof(times, chart.right_visible_bar_time)
if rightidx == -1
    rightidx := array.size(times) - 1

visibletime = rightidx - leftidx
timestep = math.round(visibletime / 100)

mid = (ta.highest(300) + ta.lowest(300)) / 2
diff = ta.highest(300) - ta.lowest(300)
len_dist = diff / 3
mult = 1.1

v_x0 = leftidx + timestep * 46
v_y0 = mid + len_dist * mult
v_x1 = leftidx + timestep * 54
v_y1 = mid
v_x2 = leftidx + timestep * 46
v_y2 = mid - len_dist * mult
v_x3 = leftidx + timestep * 30
v_y3 = mid - len_dist * mult
v_x4 = leftidx + timestep * 22
v_y4 = mid
v_x5 = leftidx + timestep * 30
v_y5 = mid + len_dist * mult

vx = array.new_float(6)
vy = array.new_float(6)
array.set(vx, 0, float(v_x0))
array.set(vy, 0, float(v_y0))
array.set(vx, 1, float(v_x1))
array.set(vy, 1, float(v_y1))
array.set(vx, 2, float(v_x2))
array.set(vy, 2, float(v_y2))
array.set(vx, 3, float(v_x3))
array.set(vy, 3, float(v_y3))
array.set(vx, 4, float(v_x4))
array.set(vy, 4, float(v_y4))
array.set(vx, 5, float(v_x5))
array.set(vy, 5, float(v_y5))

midpx = leftidx + timestep * 38
midpy = mid

px_k = array.new_int(0)
py_k = array.new_float(0)
px_d = array.new_int(0)
py_d = array.new_float(0)
stoch_k_arr = array.new_float(0)
stoch_d_arr = array.new_float(0)
osx = array.new_int(0)
osy = array.new_float(0)

// === DATA FETCHING - MATCHING WORKING SCRIPT PATTERN ===
get_stoch_values(tf) =>
    [k, d] = request.security(syminfo.tickerid, tf,
         [ta.sma(ta.stoch(close, high, low, len), smooK),
          ta.sma(ta.sma(ta.stoch(close, high, low, len), smooK), smooD)],
         gaps = barmerge.gaps_off, 
         lookahead = barmerge.lookahead_on)
    
    k_final = na(k) ? 50.0 : math.max(0, math.min(100, k))
    d_final = na(d) ? 50.0 : math.max(0, math.min(100, d))
    
    [k_final, d_final]

// TF 1
[k1, d1] = get_stoch_values(T1)
k1_rx = midpx + (array.get(vx, 0) - midpx) * (k1 / 100)
k1_ry = midpy + (array.get(vy, 0) - midpy) * (k1 / 100)
d1_rx = midpx + (array.get(vx, 0) - midpx) * (d1 / 100)
d1_ry = midpy + (array.get(vy, 0) - midpy) * (d1 / 100)
os1_rx = midpx + (array.get(vx, 0) - midpx) * (oslevel / 100)
os1_ry = midpy + (array.get(vy, 0) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k1_rx)))
array.push(py_k, k1_ry)
array.push(px_d, int(math.round(d1_rx)))
array.push(py_d, d1_ry)
array.push(osx, int(math.round(os1_rx)))
array.push(osy, os1_ry)
array.push(stoch_k_arr, k1)
array.push(stoch_d_arr, d1)

// TF 2
[k2, d2] = get_stoch_values(T2)
k2_rx = midpx + (array.get(vx, 1) - midpx) * (k2 / 100)
k2_ry = midpy + (array.get(vy, 1) - midpy) * (k2 / 100)
d2_rx = midpx + (array.get(vx, 1) - midpx) * (d2 / 100)
d2_ry = midpy + (array.get(vy, 1) - midpy) * (d2 / 100)
os2_rx = midpx + (array.get(vx, 1) - midpx) * (oslevel / 100)
os2_ry = midpy + (array.get(vy, 1) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k2_rx)))
array.push(py_k, k2_ry)
array.push(px_d, int(math.round(d2_rx)))
array.push(py_d, d2_ry)
array.push(osx, int(math.round(os2_rx)))
array.push(osy, os2_ry)
array.push(stoch_k_arr, k2)
array.push(stoch_d_arr, d2)

// TF 3
[k3, d3] = get_stoch_values(T3)
k3_rx = midpx + (array.get(vx, 2) - midpx) * (k3 / 100)
k3_ry = midpy + (array.get(vy, 2) - midpy) * (k3 / 100)
d3_rx = midpx + (array.get(vx, 2) - midpx) * (d3 / 100)
d3_ry = midpy + (array.get(vy, 2) - midpy) * (d3 / 100)
os3_rx = midpx + (array.get(vx, 2) - midpx) * (oslevel / 100)
os3_ry = midpy + (array.get(vy, 2) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k3_rx)))
array.push(py_k, k3_ry)
array.push(px_d, int(math.round(d3_rx)))
array.push(py_d, d3_ry)
array.push(osx, int(math.round(os3_rx)))
array.push(osy, os3_ry)
array.push(stoch_k_arr, k3)
array.push(stoch_d_arr, d3)

// TF 4
[k4, d4] = get_stoch_values(T4)
k4_rx = midpx + (array.get(vx, 3) - midpx) * (k4 / 100)
k4_ry = midpy + (array.get(vy, 3) - midpy) * (k4 / 100)
d4_rx = midpx + (array.get(vx, 3) - midpx) * (d4 / 100)
d4_ry = midpy + (array.get(vy, 3) - midpy) * (d4 / 100)
os4_rx = midpx + (array.get(vx, 3) - midpx) * (oslevel / 100)
os4_ry = midpy + (array.get(vy, 3) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k4_rx)))
array.push(py_k, k4_ry)
array.push(px_d, int(math.round(d4_rx)))
array.push(py_d, d4_ry)
array.push(osx, int(math.round(os4_rx)))
array.push(osy, os4_ry)
array.push(stoch_k_arr, k4)
array.push(stoch_d_arr, d4)

// TF 5
[k5, d5] = get_stoch_values(T5)
k5_rx = midpx + (array.get(vx, 4) - midpx) * (k5 / 100)
k5_ry = midpy + (array.get(vy, 4) - midpy) * (k5 / 100)
d5_rx = midpx + (array.get(vx, 4) - midpx) * (d5 / 100)
d5_ry = midpy + (array.get(vy, 4) - midpy) * (d5 / 100)
os5_rx = midpx + (array.get(vx, 4) - midpx) * (oslevel / 100)
os5_ry = midpy + (array.get(vy, 4) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k5_rx)))
array.push(py_k, k5_ry)
array.push(px_d, int(math.round(d5_rx)))
array.push(py_d, d5_ry)
array.push(osx, int(math.round(os5_rx)))
array.push(osy, os5_ry)
array.push(stoch_k_arr, k5)
array.push(stoch_d_arr, d5)

// TF 6
[k6, d6] = get_stoch_values(T6)
k6_rx = midpx + (array.get(vx, 5) - midpx) * (k6 / 100)
k6_ry = midpy + (array.get(vy, 5) - midpy) * (k6 / 100)
d6_rx = midpx + (array.get(vx, 5) - midpx) * (d6 / 100)
d6_ry = midpy + (array.get(vy, 5) - midpy) * (d6 / 100)
os6_rx = midpx + (array.get(vx, 5) - midpx) * (oslevel / 100)
os6_ry = midpy + (array.get(vy, 5) - midpy) * (oslevel / 100)

array.push(px_k, int(math.round(k6_rx)))
array.push(py_k, k6_ry)
array.push(px_d, int(math.round(d6_rx)))
array.push(py_d, d6_ry)
array.push(osx, int(math.round(os6_rx)))
array.push(osy, os6_ry)
array.push(stoch_k_arr, k6)
array.push(stoch_d_arr, d6)

// === DRAWING ===
if barstate.islast
    xp = array.new_int(14)
    yp = array.new_float(14)
    array.set(xp, 0, int(v_x0))
    array.set(yp, 0, v_y0)
    array.set(xp, 1, int(v_x1))
    array.set(yp, 1, v_y1)
    array.set(xp, 2, int(v_x2))
    array.set(yp, 2, v_y2)
    array.set(xp, 3, int(v_x3))
    array.set(yp, 3, v_y3)
    array.set(xp, 4, int(v_x4))
    array.set(yp, 4, v_y4)
    array.set(xp, 5, int(v_x5))
    array.set(yp, 5, v_y5)

    array.set(xp, 6, int(midpx + (array.get(vx, 5) - midpx) * (oblevel / 100)))
    array.set(yp, 6, midpy + (array.get(vy, 5) - midpy) * (oblevel / 100))
    array.set(xp, 7, int(midpx + (array.get(vx, 4) - midpx) * (oblevel / 100)))
    array.set(yp, 7, midpy + (array.get(vy, 4) - midpy) * (oblevel / 100))
    array.set(xp, 8, int(midpx + (array.get(vx, 3) - midpx) * (oblevel / 100)))
    array.set(yp, 8, midpy + (array.get(vy, 3) - midpy) * (oblevel / 100))
    array.set(xp, 9, int(midpx + (array.get(vx, 2) - midpx) * (oblevel / 100)))
    array.set(yp, 9, midpy + (array.get(vy, 2) - midpy) * (oblevel / 100))
    array.set(xp, 10, int(midpx + (array.get(vx, 1) - midpx) * (oblevel / 100)))
    array.set(yp, 10, midpy + (array.get(vy, 1) - midpy) * (oblevel / 100))
    array.set(xp, 11, int(midpx + (array.get(vx, 1) - midpx) * (oblevel / 200)))
    array.set(yp, 11, midpy + (array.get(vy, 0) - midpy) * (oblevel / 100))
    array.set(xp, 12, array.get(xp, 6))
    array.set(yp, 12, array.get(yp, 6))
    array.set(xp, 13, array.get(xp, 5))
    array.set(yp, 13, array.get(yp, 5))

    main_pts = array.new<chart.point>()
    for i = 0 to 13 by 1
        main_pts.push(chart.point.from_index(array.get(xp, i), array.get(yp, i)))
    pl_ob = polyline.new(main_pts, curved = false, closed = true, fill_color = obcolor, line_style = line.style_solid, line_color = obcolor)

    os_pts = array.new<chart.point>()
    for i = 0 to 5 by 1
        os_pts.push(chart.point.from_index(array.get(osx, i), array.get(osy, i)))
    pl_os = polyline.new(os_pts, curved = false, closed = true, fill_color = oscolor, line_style = line.style_dotted, line_color = oscolor)

    centerlines = array.new_line(0)
    array.push(centerlines, line.new(x1 = array.get(xp, 0), y1 = array.get(yp, 0), x2 = array.get(xp, 3), y2 = array.get(yp, 3), color = color.gray, width = 1, extend = extend.none))
    array.push(centerlines, line.new(x1 = array.get(xp, 1), y1 = array.get(yp, 1), x2 = array.get(xp, 4), y2 = array.get(yp, 4), color = color.gray, width = 1, extend = extend.none))
    array.push(centerlines, line.new(x1 = array.get(xp, 2), y1 = array.get(yp, 2), x2 = array.get(xp, 5), y2 = array.get(yp, 5), color = color.gray, width = 1, extend = extend.none))

    pts_k = array.new<chart.point>()
    pts_d = array.new<chart.point>()
    for i = 0 to 5 by 1
        pts_k.push(chart.point.from_index(array.get(px_k, i), array.get(py_k, i)))
        pts_d.push(chart.point.from_index(array.get(px_d, i), array.get(py_d, i)))
    line_k = polyline.new(pts_k, curved = curved, closed = true, line_color = kColor, line_width = kWidth)
    line_d = polyline.new(pts_d, curved = curved, closed = true, line_color = dColor, line_width = dWidth)

    if showLabels
        lbls = array.new_label(0)
        styles_arr = array.from(label.style_label_lower_left, label.style_label_left, label.style_label_upper_left, label.style_label_upper_right, label.style_label_right, label.style_label_lower_right)
        tfs_arr = array.from(T1, T2, T3, T4, T5, T6)
        for i = 0 to 5 by 1
            k_v = array.get(stoch_k_arr, i)
            d_v = array.get(stoch_d_arr, i)
            bg_col = k_v < oslevel ? color.green : k_v > oblevel ? color.red : color.black
            txt_col = k_v < oslevel ? color.black : color.white
            tf_str = array.get(tfs_arr, i)
            text_str = 'Res: ' + (tf_str == '' ? timeframe.period : tf_str) + '\nK: ' + str.tostring(k_v, '#.##') + ' | D: ' + str.tostring(d_v, '#.##')
            array.push(lbls, label.new(array.get(xp, i), array.get(yp, i), text = text_str, color = bg_col, textcolor = txt_col, style = array.get(styles_arr, i)))

    if showCircles
        circles = array.new_label(0)
        for i = 0 to 5 by 1
            k_v = array.get(stoch_k_arr, i)
            d_v = array.get(stoch_d_arr, i)
            c_bg = k_v < oslevel ? color.green : k_v > oblevel ? color.red : color.gray
            d_c_bg = d_v < oslevel ? color.green : d_v > oblevel ? color.red : color.gray
            array.push(circles, label.new(array.get(px_k, i), array.get(py_k, i), style = label.style_circle, size = size.tiny, color = c_bg))
            offset_x = 2 * (i % 2 == 0 ? 1 : -1)
            array.push(circles, label.new(array.get(px_k, i) + offset_x, array.get(py_d, i), style = label.style_circle, size = size.tiny, color = d_c_bg))
````
