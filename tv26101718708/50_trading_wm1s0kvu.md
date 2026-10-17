# 50 trading

- url: https://www.tradingview.com/script/wm1S0Kvu/
- type: indicator
- pine_id: PUB;35f4ea6f4d124769b7e5ff9923b914b4
- version: 1.0

## Description

50 trading 50%指標

## Source Code

````pine
//@version=5
indicator("50%指標", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500)

// --- 🛑 核心開發紀律：防崩潰防禦 (核心紀律 3) ---
dummy = high[4999] + low[4999] + close[4999]

// --- 參數設定 ---
// 🌟 依照指令：將預設週期改為 9
prd = input.int(9, "起始點確認週期")
min_gap = input.int(2, "雜訊過濾門檻 (K棒數)")
// 🌟 依照指令：預設開啟顯示歷史痕跡
show_history = input.bool(true, "顯示歷史「守住 50%」痕跡") 
rt_ratio = input.float(0.5, "回撤判定比例 (預設0.5=50%)", step=0.01)

// --- 結構管理系統 ---
var line[] all_major_lines = array.new_line()
var label[] all_major_labels = array.new_label()
var float[] all_major_lows = array.new_float() 

// --- 🌟 定錨與堆疊系統 ---
var float anchor_low = na        
var int anchor_idx = na

var float[] history_point1_lows = array.new_float()
var int[] history_point1_idxs = array.new_int()
var float[] history_point1_highs = array.new_float()
var int[] history_point1_high_idxs = array.new_int()

var float point1_low = na
var int point1_idx = na

var float[] stack_minor_low = array.new_float()
var int[] stack_minor_idx = array.new_int()
var label[] stack_minor_lbl = array.new_label() 
var line[] stack_minor_ln_d = array.new_line() 
var line[] stack_minor_ln_u = array.new_line() 

// 💡 依照要求，移除 graveyard 變數

// --- 追蹤器 ---
var float p_high = na, var int p_high_idx = na
var float p_low = na, var int p_low_idx = na
var bool is_crash = false
var float crash_h = na, var int crash_h_idx = na, var float crash_50 = na

// --- 繪圖管理函數 (修正：文字改為「波段低點」，樣式向上) ---
f_draw_major(_ax, _ay, _hx, _hy, _lx, _ly, _c50) =>
    l1 = line.new(_ax, _ay, _hx, _hy, xloc=xloc.bar_index, color=color.blue, width=2)
    l2 = line.new(_hx, _hy, _lx, _ly, xloc=xloc.bar_index, color=color.fuchsia, width=2)
    l3 = line.new(_ax, _c50, _lx, _c50, xloc=xloc.bar_index, color=color.black, width=2, style=line.style_solid)
    // 🌟 將標籤放置在次波段起點 (_lx, _ly)，文字改為「波段低點」
    lb = label.new(_lx, _ly, "波段低點", xloc=xloc.bar_index, style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
    array.push(all_major_lines, l1), array.push(all_major_lines, l2), array.push(all_major_lines, l3)
    array.push(all_major_labels, lb), array.push(all_major_lows, _ly)

// --- 核心邏輯架構 ---
if na(anchor_low)
    p = ta.pivotlow(low, prd, prd)
    if not na(p)
        anchor_low := p, anchor_idx := bar_index - prd
        point1_low := p, point1_idx := bar_index - prd
        p_high := high, p_high_idx := bar_index
        array.push(history_point1_lows, p)
        array.push(history_point1_idxs, anchor_idx)
        array.push(history_point1_highs, high) 
        array.push(history_point1_high_idxs, bar_index)
else
    // 🌟 1. 結構降級邏輯 (修正：絕對鎖定高點，移除原檔第 84 行的 p_high 恢復邏輯) [cite: 5, 6]
    if not na(point1_low) and low < point1_low and point1_low > anchor_low
        while array.size(history_point1_lows) > 1 and low < point1_low
            array.pop(history_point1_lows), array.pop(history_point1_idxs)
            array.pop(history_point1_highs), array.pop(history_point1_high_idxs)
            point1_low := array.last(history_point1_lows)
            point1_idx := array.last(history_point1_idxs)

        p_low := low, p_low_idx := bar_index
        is_crash := true
        crash_h := p_high, crash_h_idx := p_high_idx
        crash_50 := point1_low + (p_high - point1_low) * rt_ratio
        
        // 清除 Minor 痕跡 (核心紀律 4)
        int sz_clr = array.size(stack_minor_lbl)
        if sz_clr > 0
            for i = 0 to sz_clr - 1
                label.delete(array.get(stack_minor_lbl, i))
                line.delete(array.get(stack_minor_ln_d, i))
                line.delete(array.get(stack_minor_ln_u, i))
        array.clear(stack_minor_low), array.clear(stack_minor_idx), array.clear(stack_minor_lbl), array.clear(stack_minor_ln_d), array.clear(stack_minor_ln_u)

    // 2. 徹底破底重置
    if low < anchor_low
        anchor_low := low, anchor_idx := bar_index
        point1_low := low, point1_idx := bar_index
        p_high := high, p_high_idx := bar_index
        p_low := low, p_low_idx := bar_index
        is_crash := false
        array.clear(history_point1_lows), array.clear(history_point1_idxs), array.clear(history_point1_highs), array.clear(history_point1_high_idxs)
        array.push(history_point1_lows, low), array.push(history_point1_idxs, bar_index)
        array.push(history_point1_highs, high), array.push(history_point1_high_idxs, bar_index)
        int sz_c = array.size(stack_minor_lbl)
        if sz_c > 0
            for i = 0 to sz_c - 1
                label.delete(array.get(stack_minor_lbl, i)), line.delete(array.get(stack_minor_ln_d, i)), line.delete(array.get(stack_minor_ln_u, i))
        array.clear(stack_minor_low), array.clear(stack_minor_idx), array.clear(stack_minor_lbl), array.clear(stack_minor_ln_d), array.clear(stack_minor_ln_u)

    float cur_50 = point1_low + (nz(p_high, high) - point1_low) * rt_ratio
    if not is_crash and not na(p_high) and low < cur_50
        is_crash := true, crash_h := p_high, crash_h_idx := p_high_idx, crash_50 := cur_50

    // 🌟 3. 新高判定與點二追蹤 (還原原檔結構，修改標籤) [cite: 11-13]
    if na(p_high) or high > p_high
        int gap = bar_index - (is_crash ? crash_h_idx : nz(p_high_idx, bar_index))
        if not na(p_high) and math.abs(gap) >= min_gap
            if is_crash
                f_draw_major(point1_idx, point1_low, crash_h_idx, crash_h, p_low_idx, p_low, crash_50)
                point1_low := p_low, point1_idx := p_low_idx
                array.push(history_point1_lows, p_low), array.push(history_point1_idxs, p_low_idx)
                array.push(history_point1_highs, crash_h), array.push(history_point1_high_idxs, crash_h_idx)
                is_crash := false
                int sz_cl = array.size(stack_minor_lbl)
                if sz_cl > 0
                    for i = 0 to sz_cl - 1
                        label.delete(array.get(stack_minor_lbl, i)), line.delete(array.get(stack_minor_ln_d, i)), line.delete(array.get(stack_minor_ln_u, i))
                array.clear(stack_minor_low), array.clear(stack_minor_idx), array.clear(stack_minor_lbl), array.clear(stack_minor_ln_d), array.clear(stack_minor_ln_u)
            else
                // 🌟 修改：標籤改為「波段低點」，顏色改為紅色
                lbl = label.new(p_low_idx, p_low, "波段低點", xloc=xloc.bar_index, style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
                ln_d = line.new(p_high_idx, p_high, p_low_idx, p_low, xloc=xloc.bar_index, color=color.new(color.fuchsia, 50), width=1, style=line.style_dashed)
                float msy = array.size(stack_minor_low) > 0 ? array.last(stack_minor_low) : point1_low
                int msx = array.size(stack_minor_idx) > 0 ? array.last(stack_minor_idx) : point1_idx
                ln_u = line.new(msx, msy, p_high_idx, p_high, xloc=xloc.bar_index, color=color.new(color.blue, 50), width=1, style=line.style_dashed)
                array.push(stack_minor_low, p_low), array.push(stack_minor_idx, p_low_idx)
                array.push(stack_minor_lbl, lbl), array.push(stack_minor_ln_d, ln_d), array.push(stack_minor_ln_u, ln_u)
        
        p_high := high, p_high_idx := bar_index, p_low := low, p_low_idx := bar_index, is_crash := false
    else
        // 🌟 修正：只有在出現更低點時才更新 p_low_idx，確保紫色線端點精確「黏著」在最低點 [cite: 22]
        if na(p_low) or low <= p_low
            p_low := low, p_low_idx := bar_index

// 🌟 4. 失效直接刪除 (不再轉化為 graveyard) 
while array.size(stack_minor_low) > 0
    if low < array.last(stack_minor_low)
        label.delete(array.pop(stack_minor_lbl))
        line.delete(array.pop(stack_minor_ln_d))
        line.delete(array.pop(stack_minor_ln_u))
        array.pop(stack_minor_low), array.pop(stack_minor_idx)
    else
        break

// 歷史清理 [cite: 23]
if array.size(all_major_lows) > 0
    for i = array.size(all_major_lows) - 1 to 0
        if low < array.get(all_major_lows, i)
            int bi = i * 3
            if bi + 2 < array.size(all_major_lines)
                line.delete(array.remove(all_major_lines, bi + 2)), line.delete(array.remove(all_major_lines, bi + 1)), line.delete(array.remove(all_major_lines, bi))
                label.delete(array.remove(all_major_labels, i)), array.remove(all_major_lows, i)

// 內存與顯示優化 [cite: 25, 26]
int sz_f = array.size(stack_minor_lbl)
if sz_f > 0
    for i = sz_f - 1 to 0
        lbl = array.get(stack_minor_lbl, i), lnd = array.get(stack_minor_ln_d, i), lnu = array.get(stack_minor_ln_u, i)
        if i < sz_f - 1 and not show_history
            label.delete(lbl), line.delete(lnd), line.delete(lnu)
        else
            float a = (i == sz_f - 1) ? 0 : 100 
            label.set_color(lbl, color.new(color.red, a))
            line.set_color(lnd, color.new(color.fuchsia, a == 0 ? 50 : 100))
            line.set_color(lnu, color.new(color.blue, a == 0 ? 50 : 100))

// --- 🌟 5. 投影繪製 (100% 還原原檔投影與價格標籤)  ---
var line live_u = na, var line live_d = na, var line live_5 = na
var line live_u_minor = na, var line live_5_minor = na
var label prc_major = na, var label prc_minor = na
line.delete(live_u), line.delete(live_d), line.delete(live_5), line.delete(live_u_minor), line.delete(live_5_minor), label.delete(prc_major), label.delete(prc_minor)

if not na(point1_low) and not na(p_high)
    l50 = is_crash ? crash_50 : (point1_low + (nz(p_high, high) - point1_low) * rt_ratio)
    ux = is_crash ? crash_h_idx : p_high_idx, uy = is_crash ? crash_h : nz(p_high, high)
    live_u := line.new(point1_idx, point1_low, ux, uy, xloc=xloc.bar_index, color=color.blue, width=2)
    // 🌟 修改：紫色線端點固定黏著在最低點 (p_low_idx, p_low)，不隨價格跳動 [cite: 30, 31]
    live_d := line.new(ux, uy, p_low_idx, p_low, xloc=xloc.bar_index, color=color.fuchsia, width=2)
    live_5 := line.new(point1_idx, l50, bar_index + 10, l50, xloc=xloc.bar_index, color=color.black, width=2)
    prc_major := label.new(bar_index + 10, l50, str.tostring(l50, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    if array.size(stack_minor_low) > 0
        m_low = array.last(stack_minor_low), m_idx = array.last(stack_minor_idx), m_l50 = m_low + (uy - m_low) * rt_ratio
        live_u_minor := line.new(m_idx, m_low, ux, uy, xloc=xloc.bar_index, color=color.blue, width=1)
        live_5_minor := line.new(m_idx, m_l50, bar_index + 10, m_l50, xloc=xloc.bar_index, color=color.new(color.black, 40), width=2)
        prc_minor := label.new(bar_index + 10, m_l50, str.tostring(m_l50, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 40), textcolor=color.white, size=size.small)
````
