# GC Volume Profile

- url: https://www.tradingview.com/script/PBxvnvHA/
- type: indicator
- pine_id: PUB;3b280fa604b547608e737651e4d862c6
- version: 2.0

## Description

固定時段成交量分布圖

## Source Code

````pine
//@version=6
indicator("GC Volume Profile", overlay=true, max_lines_count=500)

// ==========================================
// 參數設定
// ==========================================
grp_time = "時區與時間設定"
tz_option = input.string("UTC-4", title="調整紐約時區", options=["UTC-4", "UTC-5"], group=grp_time)
session_time = input.session("0300-0700", title="計算範圍", group=grp_time)

grp_vp = "Volume Profile 設定"
va_pct = input.float(70.0, title="Value Area (%)", minval=1, maxval=100, group=grp_vp) / 100.0
num_rows = input.int(256, title="行數 (Number of Rows)", minval=1, group=grp_vp)

// ==========================================
// 狀態與時間判斷
// ==========================================
in_session = time(timeframe.period, session_time, tz_option)
var bool session_active = false
session_active := not na(in_session)

session_just_started = session_active and not session_active[1]
session_just_ended   = not session_active and session_active[1]

// ==========================================
// 陣列變數與時間記錄
// ==========================================
var int session_start_time = na  // 紀錄區間開始的時間點

var float[] session_highs = array.new_float(0)
var float[] session_lows  = array.new_float(0)
var float[] session_vols  = array.new_float(0)
var float session_max_h = na
var float session_min_l = na

var line line_poc = na
var line line_vah = na
var line line_val = na

// ==========================================
// 請求底層 1 分鐘數據
// ==========================================
ltf_h = request.security_lower_tf(syminfo.tickerid, "1", high)
ltf_l = request.security_lower_tf(syminfo.tickerid, "1", low)
ltf_v = request.security_lower_tf(syminfo.tickerid, "1", volume)

// ==========================================
// 核心運算邏輯
// ==========================================
if session_just_started
    session_start_time := time
    array.clear(session_highs)
    array.clear(session_lows)
    array.clear(session_vols)
    session_max_h := high
    session_min_l := low
    line_poc := na
    line_vah := na
    line_val := na

if session_active
    // 抓取 1 分鐘線資料儲存
    if not na(ltf_v) and array.size(ltf_v) > 0
        for i = 0 to array.size(ltf_v) - 1
            float h1 = array.get(ltf_h, i)
            float l1 = array.get(ltf_l, i)
            float v1 = array.get(ltf_v, i)
            
            array.push(session_highs, h1)
            array.push(session_lows, l1)
            array.push(session_vols, v1)
            session_max_h := math.max(session_max_h, h1)
            session_min_l := math.min(session_min_l, l1)
    else
        array.push(session_highs, high)
        array.push(session_lows, low)
        array.push(session_vols, volume)
        session_max_h := math.max(session_max_h, high)
        session_min_l := math.min(session_min_l, low)

if session_just_ended and array.size(session_vols) > 0
    float row_step = (session_max_h - session_min_l) / num_rows
    if row_step == 0
        row_step := syminfo.mintick

    float[] bin_prices = array.new_float(num_rows, 0.0)
    float[] bin_vols   = array.new_float(num_rows, 0.0)
    float total_session_vol = 0.0

    for i = 0 to num_rows - 1
        array.set(bin_prices, i, session_min_l + (i * row_step) + (row_step / 2))

    // 分配成交量
    for i = 0 to array.size(session_vols) - 1
        float h = array.get(session_highs, i)
        float l = array.get(session_lows, i)
        float v = array.get(session_vols, i)
        float bar_range = h - l
        
        total_session_vol += v

        if bar_range == 0
            int bin_idx = math.floor((h - session_min_l) / row_step)
            bin_idx := math.min(bin_idx, num_rows - 1)
            array.set(bin_vols, bin_idx, array.get(bin_vols, bin_idx) + v)
        else
            for j = 0 to num_rows - 1
                float bin_bottom = session_min_l + (j * row_step)
                float bin_top    = session_min_l + ((j + 1) * row_step)
                
                float overlap_bottom = math.max(l, bin_bottom)
                float overlap_top    = math.min(h, bin_top)
                float overlap        = math.max(0, overlap_top - overlap_bottom)
                
                if overlap > 0
                    float vol_fraction = v * (overlap / bar_range)
                    array.set(bin_vols, j, array.get(bin_vols, j) + vol_fraction)

    // 尋找 POC
    float max_vol = 0.0
    int poc_idx = 0
    
    for j = 0 to num_rows - 1
        float bv = array.get(bin_vols, j)
        if bv > max_vol
            max_vol := bv
            poc_idx := j
            
    float poc = array.get(bin_prices, poc_idx)

    // VA 擴展計算
    float target_vol = total_session_vol * va_pct
    float current_vol = max_vol
    int upper_idx = poc_idx
    int lower_idx = poc_idx
    
    while current_vol < target_vol and (upper_idx < num_rows - 1 or lower_idx > 0)
        float vol_up = upper_idx < num_rows - 1 ? array.get(bin_vols, upper_idx + 1) : -1.0
        float vol_dn = lower_idx > 0 ? array.get(bin_vols, lower_idx - 1) : -1.0
        
        if vol_up > vol_dn
            upper_idx += 1
            current_vol += vol_up
        else if vol_dn >= vol_up
            lower_idx -= 1
            current_vol += vol_dn
            
    float vah = array.get(bin_prices, upper_idx)
    float val = array.get(bin_prices, lower_idx)

    // 畫線 
    int t1 = session_start_time
    int t2 = time
    line_poc := line.new(t1, poc, t2, poc, xloc=xloc.bar_time, color=color.new(color.red, 0), width=2, style=line.style_solid)
    line_vah := line.new(t1, vah, t2, vah, xloc=xloc.bar_time, color=color.new(color.blue, 0), width=1, style=line.style_dashed)
    line_val := line.new(t1, val, t2, val, xloc=xloc.bar_time, color=color.new(color.blue, 0), width=1, style=line.style_dashed)
````
