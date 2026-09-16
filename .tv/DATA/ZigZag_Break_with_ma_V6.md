<!-- tradingview-pine-id: PUB;a18dd87c83544435b196563e1d09c57b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ZigZag Break -with ma V6

Source: https://www.tradingview.com/script/ZKWAPwZt/

## Description

概要
本インジケーターは、複数の上位足における20SMAおよび80SMAの状態を一目で把握し、相場の環境認識とトレンドの同調状況を効率的に可視化するためのダッシュボードツールです。

主な機能

マルチタイムフレーム（MTF）対応：最大10個の異なる時間足のMA状態を一覧で表示します。

方向性と傾きの視覚化：各時間足における20SMA・80SMAの位置関係および移動平均線の傾き（方向）を色分けしてテーブルに表示します。

パーフェクトフロー判定：短期・中期の移動平均線と価格の一致状況を判定し、トレンドの強力な同調（パーフェクトフロー）が発生しているかを分かりやすく示します。

柔軟な表示カスタマイズ：テーブルの表示位置やサイズ、色の変更が可能です。

English Description

Overview
This indicator is a comprehensive dashboard tool designed to monitor the status of the 20 SMA and 80 SMA across multiple higher timeframes simultaneously, allowing traders to efficiently assess market structure and trend alignment.

Key Features

Multi-Timeframe (MTF) Support: Displays the moving average conditions for up to 10 different timeframes in a single table.

Direction & Slope Visualization: Color-codes the positional relationship and slopes of the 20 SMA and 80 SMA for intuitive reading.

Perfect Flow Detection: Identifies strong trend synchronization (Perfect Flow) by tracking the alignment between moving averages and price action.

Customizable Display: Offers options to adjust table position, size, and colors to suit your charting preferences.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView_User

//@version=6
// @description Multi-timeframe Dow Theory ZigZag structure with MA direction step alerts.
indicator("ZigZag Break -with ma V6", shorttitle="ZZ Brk V6", overlay=true, max_lines_count=400, max_labels_count=400, precision=4)

// === 1. インプット（表示・計算系） / Inputs (Display & Calculation) ===
group_zz       = "1. ジグザグ設定 / ZigZag Settings"
showZZ0        = input.bool(false, "Show Chart TF ZigZag / 表示足のジグザグを表示", group=group_zz)
zzLineMaxCount = input.int(5, "Line Max Count / 線の表示本数", minval=1, group=group_zz)
zigzagTransp   = input.int(0, "ZigZag Line Transparency / ジグザグ線の透明度", minval=0, maxval=100, group=group_zz)
zigzagWidth    = input.int(1, "ZigZag Line Width / ジグザグ線の太さ", minval=1, group=group_zz)

group_dow      = "2. ダウ理論通知設定 / Dow Theory Alert Settings"
showDowBrk     = input.bool(true, "Show Dow Break / ダウ理論ブレイクを表示", group=group_dow)
showBrkFill    = input.bool(true, "Fill Break Background / ブレイク背景を塗りつぶす", group=group_dow)
brkFillTransp  = input.int(95, "Fill Transparency / 塗りつぶし透明度", minval=0, maxval=100, group=group_dow)
brkMaxCount    = input.int(5, "Break Display Limit / ブレイク表示の表示上限数", minval=1, group=group_dow)

group_one_draw = "3. 起点「1」「2」「3」の表示設定 / Pivot Labels Settings (1,2,3)"
showZZNums     = input.bool(true, "Show Pivot Numbers (1-5) / 頂点数字（1, 2, 3, 4, 5）を表示", group=group_one_draw)
zzNumMaxCount  = input.int(5, "Number Label Limit / 数字ラベルの表示上限数", minval=1, group=group_one_draw)

// --- タイムフレーム取得関数 ---
get_higher_tf(step) =>
    m = timeframe.multiplier
    res = "D"
    if timeframe.isintraday
        if m < 5
            res := step == 1 ? "5" : step == 2 ? "15" : step == 3 ? "60" : "240"
        else if m < 15
            res := step == 1 ? "15" : step == 2 ? "60" : step == 3 ? "240" : "D"
        else if m < 60
            res := step == 1 ? "60" : step == 2 ? "240" : step == 3 ? "D" : "W"
        else if m < 240
            res := step == 1 ? "240" : step == 2 ? "D" : step == 3 ? "W" : "M"
        else
            res := step == 1 ? "D" : step == 2 ? "W" : step == 3 ? "M" : "3M"
    else if timeframe.isdaily
        res := step == 1 ? "W" : step == 2 ? "M" : step == 3 ? "3M" : "12M"
    else
        res := "12M"
    res

h_tf1 = get_higher_tf(1)
h_tf2 = get_higher_tf(2)
h_tf3 = get_higher_tf(3)
h_tf4 = get_higher_tf(4)

// --- HTF計算ロジック ---
calc_tf(tf) =>
    [h, l, o, c, t] = request.security(syminfo.tickerid, tf, [high, low, open, close, time], lookahead=barmerge.lookahead_on)
    var float mH_val = na, var float mL_val = na, var int mT_val = na, var color mC_val = color.gray, var int b_dir_val = 0, var bool is_rev_event = false
    is_rev_event := false
    if not na(t) and t != t[1]
        float prev_c = c[1], float prev_h = h[1], float prev_l = l[1]
        if na(mH_val)
            mH_val := prev_h, mL_val := prev_l, mT_val := t[1], mC_val := prev_c >= o[1] ? color.blue : color.red, b_dir_val := prev_c >= o[1] ? 1 : -1
        bool isUpperBroken = prev_c > mH_val
        bool isLowerBroken = prev_c < mL_val
        if isUpperBroken or isLowerBroken
            is_rev_event := (isUpperBroken and b_dir_val == -1) or (isLowerBroken and b_dir_val == 1)
            b_dir_val := isUpperBroken ? 1 : -1, mH_val := prev_h, mL_val := prev_l, mT_val := t[1], mC_val := b_dir_val == 1 ? color.blue : color.red
    [is_rev_event, mC_val, mT_val, mH_val, mL_val, c]

[rev0, mC0, mT0, mH0, mL0, cur_c0] = calc_tf(timeframe.period)
[rev1, mC1, mT1, mH1, mL1, cur_c1] = calc_tf(h_tf1)
[rev2, mC2, mT2, mH2, mL2, cur_c2] = calc_tf(h_tf2)
[rev3, mC3, mT3, mH3, mL3, cur_c3] = calc_tf(h_tf3)
[rev4, mC4, mT4, mH4, mL4, cur_c4] = calc_tf(h_tf4)

process_zigzag(show, is_rev, mC, mT, cur_c, cur_mH, cur_mL) =>
    var line[] zz_lines = array.new_line(0)
    var line[] brk_lh_lines = array.new_line(0)
    var line[] brk_lv_lines = array.new_line(0)
    var linefill[] brk_fills = array.new_linefill(0)
    var float last_p_y = na, var int last_p_x = na, var int stored_start_x = na
    var float h_val = na, var int h_x = na, var float l_val = na, var int l_x = na
    var bool is_h_broken = true, var bool is_l_broken = true, var int _last_dir = 0
    bool _brk_up = false, bool _brk_dn = false
    bool _is_top_confirmed = false

    if not na(ta.change(mT))
        stored_start_x := mT[1]
    if not na(ta.change(mT)) and is_rev
        bool is_sell_rev = (mC == color.red)
        float extreme_y = is_sell_rev ? -1.0e10 : 1.0e10
        int extreme_x = time
        for i = 1 to 500
            if na(last_p_x) ? time[i] < stored_start_x : time[i] <= last_p_x
                break
            if is_sell_rev
                if high[i] > extreme_y
                    extreme_y := high[i], extreme_x := time[i]
            else
                if low[i] < extreme_y
                    extreme_y := low[i], extreme_x := time[i]
        if is_sell_rev and _last_dir == 1 and extreme_y <= h_val
            _last_dir := 0
        else if not is_sell_rev and _last_dir == -1 and extreme_y >= l_val
            _last_dir := 0
        
        if show and not na(last_p_y)
            color _base_col = _last_dir == 1 ? color.blue : _last_dir == -1 ? color.red : color.gray
            color _node_col = color.new(_base_col, zigzagTransp)
            array.push(zz_lines, line.new(last_p_x, last_p_y, extreme_x, extreme_y, xloc=xloc.bar_time, color=_node_col, width=zigzagWidth))
            if array.size(zz_lines) > zzLineMaxCount
                line.delete(array.shift(zz_lines))
        
        last_p_y := extreme_y, last_p_x := extreme_x
        if is_sell_rev
            h_val := extreme_y, h_x := extreme_x, is_h_broken := false
        else
            l_val := extreme_y, l_x := extreme_x, is_l_broken := false
        _is_top_confirmed := true

    if showDowBrk
        _brk_up := not is_h_broken and not na(h_val) and cur_c[1] > h_val
        _brk_dn := not is_l_broken and not na(l_val) and cur_c[1] < l_val
        if _brk_up or _brk_dn
            is_h_broken := _brk_up ? true : is_h_broken
            is_l_broken := _brk_dn ? true : is_l_broken
            _last_dir := _brk_up ? 1 : -1
            if show
                _tc = _brk_up ? color.blue : color.red
                // 水平線・垂直線を完全透明化 (color.new(_tc, 100))
                lh = line.new(_brk_up ? h_x : l_x, _brk_up ? h_val : l_val, time, _brk_up ? h_val : l_val, xloc=xloc.bar_time, color=color.new(_tc, 100))
                lv = line.new(_brk_up ? h_x : l_x, _brk_up ? h_val : l_val, _brk_up ? l_x : h_x, _brk_up ? l_val : h_val, xloc=xloc.bar_time, color=color.new(_tc, 100))
                array.push(brk_lh_lines, lh)
                array.push(brk_lv_lines, lv)
                
                if showBrkFill
                    // 領域塗りつぶしも完全透明化 (color.new(_tc, 100))
                    lf = linefill.new(lh, lv, color.new(_tc, 100))
                    array.push(brk_fills, lf)
                
                if array.size(brk_lh_lines) > brkMaxCount
                    line.delete(array.shift(brk_lh_lines))
                    line.delete(array.shift(brk_lv_lines))
                    if array.size(brk_fills) > 0 and array.size(brk_fills) > array.size(brk_lh_lines)
                        linefill.delete(array.shift(brk_fills))
    [_last_dir, _brk_up, _brk_dn, h_val, h_x, l_val, l_x, _is_top_confirmed, last_p_y, last_p_x]

[dir0, bUp0, bDn0, h0, hx0, l0, lx0, top0, ly0, lx_last0] = process_zigzag(showZZ0, rev0, mC0, mT0, cur_c0, mH0, mL0)
[dir1, bUp1, bDn1, h1, hx1, l1, lx1, top1, ly1, lx_last1] = process_zigzag(false, rev1, mC1, mT1, cur_c1, mH1, mL1)
[dir2, bUp2, bDn2, h2, hx2, l2, lx2, top2, ly2, lx_last2] = process_zigzag(false, rev2, mC2, mT2, cur_c2, mH2, mL2)
[dir3, bUp3, bDn3, h3, hx3, l3, lx3, top3, ly3, lx_last3] = process_zigzag(false, rev3, mC3, mT3, cur_c3, mH3, mL3)
[dir4, bUp4, bDn4, h4, hx4, l4, lx4, top4, ly4, lx_last4] = process_zigzag(false, rev4, mC4, mT4, cur_c4, mH4, mL4)

f_get_label_text(int d, string n) => d == 0 ? "0" : n

f_draw_labels(show, bUp, bDn, int dir_curr, top, h_v, l_v, h_x, l_x, lastY, lastX) =>
    var int    last_1_dir = 0
    var bool  wait_for_2 = false
    var bool  wait_for_3 = false
    var bool  wait_for_2_after_3 = false
    var bool  is_first_3_cycle = false 
    var label last_lbl   = na
    var int    last_lbl_x = 0
    var float last_lbl_y = 0.0
    var string last_num_stashed = "0"
    bool is_just_123_break = false

    var label[] lbl_hist = array.new_label(0)

    oneUp = (dir_curr[1] <= 0 and bUp)
    oneDn = (dir_curr[1] >= 0 and bDn)

    if oneUp
        if show
            if l_x == last_lbl_x and l_v == last_lbl_y
                if array.size(lbl_hist) > 0
                    for i = array.size(lbl_hist) - 1 to 0
                        if array.get(lbl_hist, i) == last_lbl
                            array.remove(lbl_hist, i)
                            break
                label.delete(last_lbl)
            _txt = showZZNums ? f_get_label_text(dir_curr, "1") : ""
            last_lbl := label.new(l_x, l_v, _txt, xloc=xloc.bar_time, color=#00000000, textcolor=color.blue, style=label.style_label_up, size=size.large)
            array.push(lbl_hist, last_lbl)
            if array.size(lbl_hist) > zzNumMaxCount
                label.delete(array.shift(lbl_hist))
        last_num_stashed := "1", last_lbl_x := l_x, last_lbl_y := l_v, last_1_dir := 1, wait_for_2 := true, wait_for_3 := false, wait_for_2_after_3 := false, is_first_3_cycle := true
    
    if oneDn
        if show
            if h_x == last_lbl_x and h_v == last_lbl_y
                if array.size(lbl_hist) > 0
                    for i = array.size(lbl_hist) - 1 to 0
                        if array.get(lbl_hist, i) == last_lbl
                            array.remove(lbl_hist, i)
                            break
                label.delete(last_lbl)
            _txt = showZZNums ? f_get_label_text(dir_curr, "1") : ""
            last_lbl := label.new(h_x, h_v, _txt, xloc=xloc.bar_time, color=#00000000, textcolor=color.red, style=label.style_label_down, size=size.large)
            array.push(lbl_hist, last_lbl)
            if array.size(lbl_hist) > zzNumMaxCount
                label.delete(array.shift(lbl_hist))
        last_num_stashed := "1", last_lbl_x := h_x, last_lbl_y := h_v, last_1_dir := -1, wait_for_2 := true, wait_for_3 := false, wait_for_2_after_3 := false, is_first_3_cycle := true

    if top
        if wait_for_2
            if (last_1_dir == 1 and lastY == h_v) or (last_1_dir == -1 and lastY == l_v)
                if show
                    if lastX == last_lbl_x and lastY == last_lbl_y
                        if array.size(lbl_hist) > 0
                            for i = array.size(lbl_hist) - 1 to 0
                                if array.get(lbl_hist, i) == last_lbl
                                    array.remove(lbl_hist, i)
                                    break
                        label.delete(last_lbl)
                    _style = last_1_dir == 1 ? label.style_label_down : label.style_label_up
                    _color = last_1_dir == 1 ? color.blue : color.red
                    _txt = showZZNums ? f_get_label_text(dir_curr, "2") : ""
                    last_lbl := label.new(lastX, lastY, _txt, xloc=xloc.bar_time, color=#00000000, textcolor=_color, style=_style, size=size.large)
                    array.push(lbl_hist, last_lbl)
                    if array.size(lbl_hist) > zzNumMaxCount
                        label.delete(array.shift(lbl_hist))
                last_num_stashed := "2", last_lbl_x := lastX, last_lbl_y := lastY, wait_for_2 := false, wait_for_3 := true
        else if wait_for_3
            if (last_1_dir == 1 and lastY == l_v) or (last_1_dir == -1 and lastY == h_v)
                if show
                    if lastX == last_lbl_x and lastY == last_lbl_y
                        if array.size(lbl_hist) > 0
                            for i = array.size(lbl_hist) - 1 to 0
                                if array.get(lbl_hist, i) == last_lbl
                                    array.remove(lbl_hist, i)
                                    break
                        label.delete(last_lbl)
                    _style = last_1_dir == 1 ? label.style_label_up : label.style_label_down
                    _color = last_1_dir == 1 ? color.blue : color.red
                    string target_num = (last_num_stashed == "4" or last_num_stashed == "6") ? "5" : "3"
                    _txt = showZZNums ? f_get_label_text(dir_curr, target_num) : ""
                    last_lbl := label.new(lastX, lastY, _txt, xloc=xloc.bar_time, color=#00000000, textcolor=_color, style=_style, size=size.large)
                    array.push(lbl_hist, last_lbl)
                    if array.size(lbl_hist) > zzNumMaxCount
                        label.delete(array.shift(lbl_hist))
                    last_num_stashed := target_num, last_lbl_x := lastX, last_lbl_y := lastY, wait_for_3 := false, wait_for_2_after_3 := true
                else
                    last_num_stashed := (last_num_stashed == "4" or last_num_stashed == "6") ? "5" : "3", last_lbl_x := lastX, last_lbl_y := lastY, wait_for_3 := false, wait_for_2_after_3 := true
                
                if is_first_3_cycle
                    is_just_123_break := true
                    is_first_3_cycle := false
        else if wait_for_2_after_3
            if (last_1_dir == 1 and lastY == h_v) or (last_1_dir == -1 and lastY == l_v)
                if show
                    if lastX == last_lbl_x and lastY == last_lbl_y
                        if array.size(lbl_hist) > 0
                            for i = array.size(lbl_hist) - 1 to 0
                                if array.get(lbl_hist, i) == last_lbl
                                    array.remove(lbl_hist, i)
                                    break
                        label.delete(last_lbl)
                    _style = last_1_dir == 1 ? label.style_label_down : label.style_label_up
                    _color = last_1_dir == 1 ? color.blue : color.red
                    string target_num_2 = (last_num_stashed == "5") ? "6" : "4"
                    _txt = showZZNums ? f_get_label_text(dir_curr, target_num_2) : ""
                    last_lbl := label.new(lastX, lastY, _txt, xloc=xloc.bar_time, color=#00000000, textcolor=_color, style=_style, size=size.large)
                    array.push(lbl_hist, last_lbl)
                    if array.size(lbl_hist) > zzNumMaxCount
                        label.delete(array.shift(lbl_hist))
                    last_num_stashed := target_num_2, last_lbl_x := lastX, last_lbl_y := lastY, wait_for_2_after_3 := false, wait_for_3 := true
                else
                    last_num_stashed := (last_num_stashed == "5") ? "6" : "4", last_lbl_x := lastX, last_lbl_y := lastY, wait_for_2_after_3 := false, wait_for_3 := true
    
    if not na(last_lbl) and show
        if dir_curr != 0 and last_num_stashed == "0"
            last_num_stashed := "1"
        
        _is_visible = showZZNums and (last_num_stashed != "0")
        
        label.set_text(last_lbl, _is_visible ? f_get_label_text(dir_curr, last_num_stashed) : "")
        if f_get_label_text(dir_curr, last_num_stashed) == "0"
            label.set_textcolor(last_lbl, color.gray)

    [f_get_label_text(dir_curr, last_num_stashed), is_just_123_break]

[lbl0, is123_0] = f_draw_labels(showZZ0, bUp0, bDn0, dir0, top0, h0, l0, hx0, lx0, ly0, lx_last0)
[lbl1, is123_1] = f_draw_labels(false, bUp1, bDn1, dir1, top1, h1, l1, hx1, lx1, ly1, lx_last1)
[lbl2, is123_2] = f_draw_labels(false, bUp2, bDn2, dir2, top2, h2, l2, hx2, lx2, ly2, lx_last2)
[lbl3, is123_3] = f_draw_labels(false, bUp3, bDn3, dir3, top3, h3, l3, hx3, lx3, ly3, lx_last3)
[lbl4, is123_4] = f_draw_labels(false, bUp4, bDn4, dir4, top4, h4, l4, hx4, lx4, ly4, lx_last4)

// === 2. テーブル・履歴表示 / Status Table ===
showTable = input.bool(true, "Show Status Table / ステータステーブルを表示", group="4. テーブル表示 / Table Settings")

var table statusTable = table.new(position.top_left, 8, 1)

if showTable and barstate.islast
    // 空白セル(0-3)の固定描画
    table.cell(statusTable, 0, 0, "", width=6, height=7, bgcolor=color.new(color.white, 100))
    table.cell(statusTable, 1, 0, "", width=6, height=7, bgcolor=color.new(color.white, 100))
    table.cell(statusTable, 2, 0, "", width=6, height=7, bgcolor=color.new(color.white, 100))
    table.cell(statusTable, 3, 0, "", width=6, height=7, bgcolor=color.new(color.white, 100))
    
    // 表示セルを左詰めで配置 (4列目開始)
    table.cell(statusTable, 4, 0, lbl0, width=6, height=7, bgcolor=(dir0 == 1 ? color.blue : dir0 == -1 ? color.red : color.gray), text_color=color.white, text_size=size.large)

// === 3. 直近の「偶数(2,4,6)」「奇数(3,5)」 水平線表示 / Horizontal Line Settings ===
group_ph_line = "5. 偶数・奇数水平線設定 / Even/Odd Horizontal Lines"
showMaster0 = input.bool(true, "Show Chart TF Lines / 表示足の偶数・奇数水平線", group=group_ph_line)

showPrev2Lines = input.bool(true, "Show Previous Even Lines (2,4,6) / 一つ前の「偶数(2,4,6)」水平線を表示", group=group_ph_line)
showPrev2OnlySameSide = input.bool(false, "Remove if Recent Even Opposite / ↑ 直近の偶数が反対側なら削除", group=group_ph_line)
showPh3Lines = input.bool(true, "Show Recent Odd Lines (3,5) / 直近の「奇数(3,5)」水平線を表示", group=group_ph_line)
phLineWidth = input.int(1, "Line Width / 水平線の太さ", minval=1, group=group_ph_line)

// === 外付け：頂点1確定起点（ブレイクされた頂点）水平線設定 / Break Origin Line Settings ===
group_brk_origin = "6. 頂点1確定起点水平線設定 / Pivot 1 Break Origin Lines"
showBrkOriginLine = input.bool(false, "Show Break Origin Line / 頂点1を確定させたブレイク頂点の水平線を表示", group=group_brk_origin)
showBrkNode1Line  = input.bool(false, "Show Confirmed Node 1 Line / ↑ 確定した頂点1の水平線も表示", group=group_brk_origin)
brkOriginLineWidth = input.int(2, "Origin Line Width / 最重要ラインの太さ", minval=1, group=group_brk_origin)
brkOriginColorUp  = input.color(color.blue, "Bullish Line Color / 上昇ラインの色", group=group_brk_origin)
brkOriginColorDn  = input.color(color.red, "Bearish Line Color / 下落ラインの色", group=group_brk_origin)

f_trace_history(target_num, current_lbl, ly, lx, d) =>
    var float y1 = na, var int x1 = na, var int d1 = na 
    var float y2 = na, var int x2 = na, var int d2 = na 
    if current_lbl == target_num
        if x1 != lx
            y2 := y1, x2 := x1, d2 := d1 
        y1 := ly, x1 := lx, d1 := d
    if current_lbl != target_num and x1 == lx
        y1 := y2, x1 := x2, d1 := d2
        y2 := na, x2 := na, d2 := na
    [y1, x1, d1, y2, x2, d2]

f_draw_line(y, x, d, is_active, is_on, w, string tf_name, color custom_col = na) =>
    int hist_offset = 12
    var line l = na
    var label lbl = na
    color _line_col = not na(custom_col) ? custom_col : (d == 1 ? color.blue : color.red)
    if is_active and is_on and not na(y)
        line.delete(l), label.delete(lbl)
        l := line.new(x, y, time, y, xloc=xloc.bar_time, color=_line_col, width=w)
        line.set_extend(l, extend.right)
        if tf_name != ""
            lbl := label.new(bar_index + hist_offset, y, tf_name, xloc=xloc.bar_index, color=color.white, textcolor=_line_col, style=label.style_label_left, size=size.small)
    else
        line.delete(l), label.delete(lbl)
        l := na, lbl := na
    0

// --- 水平線ターゲット定義（偶数：2,4,6 / 奇数：3,5） ---
[my2_0, mx2_0, md2_0, mpy2_0, mpx2_0, mpd2_0] = f_trace_history((lbl0 == "2" or lbl0 == "4" or lbl0 == "6" ? lbl0 : na), lbl0, ly0, lx_last0, dir0)
[my3_0, mx3_0, md3_0, mpy3_0, mpx3_0, mpd3_0] = f_trace_history((lbl0 == "3" or lbl0 == "5" ? lbl0 : na), lbl0, ly0, lx_last0, dir0)
s2_0 = showPrev2Lines and (not showPrev2OnlySameSide or md2_0 == mpd2_0)
s3_0 = showPh3Lines
_u0_2p = f_draw_line(mpy2_0, mpx2_0, mpd2_0, showMaster0, s2_0, phLineWidth, "")
_u0_3c = f_draw_line(my3_0, mx3_0, md3_0, showMaster0, s3_0, phLineWidth, "")

// --- 外付け：上位足 奇数3, 5 座標保持関数 ---
f_trace_odd35_htf(top_flag, current_lbl, ly_val, lx_val, current_dir) =>
    var float keep_y = na
    var int   keep_x = na
    var int   keep_d = na
    
    // 1. 上位足で「3」または「5」が確定した一瞬だけ座標と方向を固定保持
    bool is_odd35 = top_flag and (current_lbl == "3" or current_lbl == "5")
    if is_odd35
        keep_y := ly_val
        keep_x := lx_val
        keep_d := current_dir
        
    [keep_y, keep_x, keep_d]

// --- 各上位足での状態保持実行（内部計算保持のみ・描画呼び出しなし） ---
[my2_1, mx2_1, md2_1, mpy2_1, mpx2_1, mpd2_1] = f_trace_history((lbl1 == "2" or lbl1 == "4" or lbl1 == "6" ? lbl1 : na), lbl1, ly1, lx_last1, dir1)
[my3_1, mx3_1, md3_1] = f_trace_odd35_htf(top1, lbl1, ly1, lx_last1, dir1)

[my2_2, mx2_2, md2_2, mpy2_2, mpx2_2, mpd2_2] = f_trace_history((lbl2 == "2" or lbl2 == "4" or lbl2 == "6" ? lbl2 : na), lbl2, ly2, lx_last2, dir2)
[my3_2, mx3_2, md3_2] = f_trace_odd35_htf(top2, lbl2, ly2, lx_last2, dir2)

[my2_3, mx2_3, md2_3, mpy2_3, mpx2_3, mpd2_3] = f_trace_history((lbl3 == "2" or lbl3 == "4" or lbl3 == "6" ? lbl3 : na), lbl3, ly3, lx_last3, dir3)
[my3_3, mx3_3, md3_3] = f_trace_odd35_htf(top3, lbl3, ly3, lx_last3, dir3)

[my2_4, mx2_4, md2_4, mpy2_4, mpx2_4, mpd2_4] = f_trace_history((lbl4 == "2" or lbl4 == "4" or lbl4 == "6" ? lbl4 : na), lbl4, ly4, lx_last4, dir4)
[my3_4, mx3_4, md3_4] = f_trace_odd35_htf(top4, lbl4, ly4, lx_last4, dir4)

// === 外付け：偶数(2,4,6)頂点ブレイク・反対側出現で消去型 ===
showEvenBrkLine = input.bool(true, "Show Even Break Line (2,4,6) / 「2,4,6」の頂点起点・終値ブレイク水平線", group=group_ph_line)

f_even_brk_logic_final_v3(current_lbl, current_y, current_x, current_dir, current_c) =>
    var float active_y = na
    var int active_x = na
    var int active_dir = na
    
    var float next_y = na
    var int next_x = na
    var int next_dir = na

    bool is_even = (current_lbl == "2" or current_lbl == "4" or current_lbl == "6")
    bool is_new_label = current_lbl != current_lbl[1]

    if is_even and is_new_label
        if not na(active_y) and current_dir != active_dir
            active_y := na
            active_x := na
            active_dir := na

        next_y := current_y
        next_x := current_x
        next_dir := current_dir

    if not na(next_y)
        bool is_broken = (next_dir == 1 and current_c > next_y) or (next_dir == -1 and current_c < next_y)
        
        if is_broken
            active_y := next_y
            active_x := next_x
            active_dir := next_dir
            next_y := na
    
    [active_y, active_x, active_dir]

// --- 階層別判定の実行 ---
[ey0, ex0, ed0] = f_even_brk_logic_final_v3(lbl0, ly0, lx_last0, dir0, close)
[ey1, ex1, ed1] = f_even_brk_logic_final_v3(lbl1, ly1, lx_last1, dir1, close)
[ey2, ex2, ed2] = f_even_brk_logic_final_v3(lbl2, ly2, lx_last2, dir2, close)
[ey3, ex3, ed3] = f_even_brk_logic_final_v3(lbl3, ly3, lx_last3, dir3, close)
[ey4, ex4, ed4] = f_even_brk_logic_final_v3(lbl4, ly4, lx_last4, dir4, close)

// --- 表示足のみ描画実行 ---
_ev0 = f_draw_line(ey0, ex0, ed0, showMaster0, not na(ey0) and showEvenBrkLine, phLineWidth, "")

// === 外付け：頂点1確定起点（ブレイクされた頂点）記憶・描画ロジック（ブレイクフラグ直接検知型） ===
f_trace_brk_origin_v2(bUp, bDn, current_dir, h_v, h_x, l_v, l_x) =>
    var float active_y   = na
    var int   active_x   = na
    var int   active_dir = na
    var float node1_y    = na
    var int   node1_x    = na

    bool is_one_up = (current_dir[1] <= 0 and bUp)
    bool is_one_dn = (current_dir[1] >= 0 and bDn)

    if is_one_up
        active_y   := h_v  // ブレイクされた高値（起点）
        active_x   := h_x
        node1_y    := l_v  // 確定した頂点1（安値）
        node1_x    := l_x
        active_dir := 1
    else if is_one_dn
        active_y   := l_v  // ブレイクされた安値（起点）
        active_x   := l_x
        node1_y    := h_v  // 確定した頂点1（高値）
        node1_x    := h_x
        active_dir := -1

    [active_y, active_x, active_dir, node1_y, node1_x]

// --- 各階層での状態保持処理（1確定基準） ---
[boy0, box0, bod0, n1y0, n1x0] = f_trace_brk_origin_v2(bUp0, bDn0, dir0, h0, hx0, l0, lx0)
[boy1, box1, bod1, n1y1, n1x1] = f_trace_brk_origin_v2(bUp1, bDn1, dir1, h1, hx1, l1, lx1)
[boy2, box2, bod2, n1y2, n1x2] = f_trace_brk_origin_v2(bUp2, bDn2, dir2, h2, hx2, l2, lx2)
[boy3, box3, bod3, n1y3, n1x3] = f_trace_brk_origin_v2(bUp3, bDn3, dir3, h3, hx3, l3, lx3)
[boy4, box4, bod4, n1y4, n1x4] = f_trace_brk_origin_v2(bUp4, bDn4, dir4, h4, hx4, l4, lx4)

color _bo0_col = bod0 == 1 ? brkOriginColorUp : brkOriginColorDn
_bo0   = f_draw_line(boy0, box0, bod0, showMaster0, showBrkOriginLine, brkOriginLineWidth, "", _bo0_col)
_bo0_n = f_draw_line(n1y0, n1x0, bod0, showMaster0, showBrkNode1Line,   brkOriginLineWidth, "", _bo0_col)

// ==========================================
// === 外付け：直近頂点からの未確定追従ライン（縮み防止・頂点色反映・独立設定） / Realtime Pivot Line ===
// ==========================================
group_rt_line = "7. 未確定追従ライン設定 / Realtime Unbroken Line Settings"
showRtLine0  = input.bool(true, "Show Chart TF Unbroken Line / 表示足の未確定ラインを表示", group=group_rt_line)
rtLineWidth  = input.int(1, "Line Width / ラインの太さ", minval=1, group=group_rt_line)
rtLineTransp = input.int(0, "Line Transparency / ラインの透明度", minval=0, maxval=100, group=group_rt_line)

f_draw_rt_unbroken_line(show, top_flag, is_high, last_x, last_y, node_color, w, transp) =>
    var float ext_y = na
    var int   ext_x = na
    var line  l     = na

    // 1. 直近頂点座標の更新・上書きが発生した際、起点と追従極値をリセット
    if top_flag or (last_x != last_x[1]) or (last_y != last_y[1])
        ext_y := last_y
        ext_x := last_x

    // 2. 縮まない極値追従（高値頂点＝下へlowを追尾 / 安値頂点＝上へhighを追尾）
    if not na(ext_y)
        if is_high
            if na(ext_y) or low < ext_y
                ext_y := low
                ext_x := time
        else
            if na(ext_y) or high > ext_y
                ext_y := high
                ext_x := time

    // 3. 今の直近頂点の色（node_color）と固有の太さ・透明度を適用して描画
    if show and not na(last_x) and not na(last_y) and not na(ext_x) and not na(ext_y)
        line.delete(l)
        color line_col = color.new(node_color, transp)
        l := line.new(last_x, last_y, ext_x, ext_y, xloc=xloc.bar_time, color=line_col, width=w)
    else
        line.delete(l)
        l := na

// 呼び出し部（表示足のみ実行）
_rt0 = f_draw_rt_unbroken_line(showRtLine0, top0, ly0 == h0, lx_last0, ly0, dir0 == 1 ? color.blue : dir0 == -1 ? color.red : color.gray, rtLineWidth, rtLineTransp)

// === 外付け：表示足 頂点1発生時 横帯表示設定 / Pivot 1 Break Zone Settings ===
group_brk_zone = "8. 頂点1横帯表示設定 / Pivot 1 Break Zone Settings"
showBrkZone    = input.bool(true, "Show Break Zone / 頂点1発生時のブレイク横帯を表示", group=group_brk_zone)
brkZoneColorUp = input.color(color.new(color.blue, 95), "Bullish Zone Color / 上昇ブレイク帯の色", group=group_brk_zone)
brkZoneColorDn = input.color(color.new(color.red, 95), "Bearish Zone Color / 下落ブレイク帯の色", group=group_brk_zone)

// === 外付け：表示足 頂点1発生時 横帯描画ロジック（直近1つのみ保持） ===
var box active_brk_box = na

bool is_one_up_zone = (dir0[1] <= 0 and bUp0)
bool is_one_dn_zone = (dir0[1] >= 0 and bDn0)

if showBrkZone
    if is_one_up_zone
        if not na(active_brk_box)
            box.delete(active_brk_box)
        int left_time = math.min(hx0, lx0)
        active_brk_box := box.new(left_time, h0, time, l0, xloc=xloc.bar_time, bgcolor=brkZoneColorUp, border_color=color.new(color.blue, 100), extend=extend.right)
    else if is_one_dn_zone
        if not na(active_brk_box)
            box.delete(active_brk_box)
        int left_time = math.min(hx0, lx0)
        active_brk_box := box.new(left_time, h0, time, l0, xloc=xloc.bar_time, bgcolor=brkZoneColorDn, border_color=color.new(color.red, 100), extend=extend.right)

// ==========================================
// === 5. MA Direction MTF (独立外付けブロック) / MA Direction MTF Block ===
// ==========================================

// --- パラメータ設定 ---
group_ma_dir = "9. MA Direction MTF Settings"
int ma_dir_ma_length       = input.int(20, "MA Length / MA 期間", minval=1, group=group_ma_dir)
int ma_dir_lookback        = input.int(1, "Lookback for Direction / 向きの判定幅", minval=1, group=group_ma_dir)

string group_ma_dir_disp   = "10. MA Direction MTF - Display Settings"
bool ma_dir_showD   = input.bool(false, "Show Daily / 日足を表示", group=group_ma_dir_disp)
bool ma_dir_show240 = input.bool(false, "Show 4H / 4時間足を表示", group=group_ma_dir_disp)
bool ma_dir_show60  = input.bool(false, "Show 1H / 1時間足を表示", group=group_ma_dir_disp)
bool ma_dir_show30  = input.bool(false, "Show 30m / 30分足を表示", group=group_ma_dir_disp)
bool ma_dir_show15  = input.bool(false, "Show 15m / 15分足を表示", group=group_ma_dir_disp)
bool ma_dir_show5   = input.bool(false, "Show 5m / 5分足を表示", group=group_ma_dir_disp)
bool ma_dir_show1   = input.bool(false, "Show 1m / 1分足を表示", group=group_ma_dir_disp)
bool ma_dir_use_30m_for_5m = input.bool(false, "5m TF: Use 30m MA for Higher TF / 5分足の上位MAに30分足を使用", group=group_ma_dir_disp)

// 色設定パラメータ
color col_ma_sma    = input.color(color.blue, "SMA Color / SMAの色", group=group_ma_dir_disp)
color col_ma_hi_sma = input.color(color.red,  "Higher TF SMA Color / 上位足SMAの色", group=group_ma_dir_disp)
color col_mark_buy  = input.color(color.blue, "Buy Mark Color / 買いマークの色", group=group_ma_dir_disp)
color col_mark_sell = input.color(color.red,  "Sell Mark Color / 売りマークの色", group=group_ma_dir_disp)

// --- 状態保持変数 ---
var bool ma_dir_has_conv_W = false, var string ma_dir_last_tW = ""
var bool ma_dir_has_conv_D = false, var string ma_dir_last_tD = ""
var bool ma_dir_has_conv_240 = false, var string ma_dir_last_t240 = ""
var bool ma_dir_has_conv_60 = false, var string ma_dir_last_t60 = ""
var bool ma_dir_has_conv_30 = false, var string ma_dir_last_t30 = ""
var bool ma_dir_has_conv_15 = false, var string ma_dir_last_t15 = ""
var bool ma_dir_has_conv_5 = false, var string ma_dir_last_t5 = ""
var bool ma_dir_has_conv_1 = false, var string ma_dir_last_t1 = ""
var bool ma_dir_has_conv_M = false, var string ma_dir_last_tM = ""

// --- ロジック関数 ---
f_ma_dir_get_status(float cur_ma, float hi_ma, float ma_p1, bool has_conv_in) =>
    bool is_up = cur_ma > ma_p1
    
    string status_txt = is_up ? "買い" : "売り"
    color bg_color = is_up ? color.blue : color.red
    color tx_color = color.white
    
    bool crossed = ta.crossover(cur_ma, hi_ma) or ta.crossunder(cur_ma, hi_ma)
    bool conv    = (cur_ma < hi_ma ? cur_ma > ma_p1 : cur_ma < ma_p1)
    bool next_has_conv = crossed ? false : (has_conv_in or conv)
    
    [status_txt, bg_color, tx_color, next_has_conv]

// --- 計算実行 ---
ma_dir_sma_src = ta.sma(close, ma_dir_ma_length)
f_ma_dir_sec(tf) => [request.security(syminfo.tickerid, tf, ma_dir_sma_src), request.security(syminfo.tickerid, tf, ma_dir_sma_src[ma_dir_lookback])]

[ma_dir_maW, ma_dir_maW_p]     = f_ma_dir_sec("W")
[ma_dir_maD, ma_dir_maD_p]     = f_ma_dir_sec("D")
[ma_dir_ma240, ma_dir_ma240_p] = f_ma_dir_sec("240")
[ma_dir_ma60, ma_dir_ma60_p]   = f_ma_dir_sec("60")
[ma_dir_ma30_v, ma_dir_ma30_p] = f_ma_dir_sec("30")
[ma_dir_ma15, ma_dir_ma15_p]   = f_ma_dir_sec("15")
[ma_dir_ma5, ma_dir_ma5_p]     = f_ma_dir_sec("5")
[ma_dir_ma1, ma_dir_ma1_p]     = f_ma_dir_sec("1")
[ma_dir_maM, ma_dir_maM_p]     = f_ma_dir_sec("M")

ma_dir_ma3M   = request.security(syminfo.tickerid, "3M", ma_dir_sma_src)
ma_dir_ma3M_p = request.security(syminfo.tickerid, "3M", ma_dir_sma_src[ma_dir_lookback])
ma_dir_ma12M  = request.security(syminfo.tickerid, "12M", ma_dir_sma_src)

ma_dir_ma30   = request.security(syminfo.tickerid, "30", ma_dir_sma_src)

ma_dir_h_5 = (timeframe.isintraday and timeframe.multiplier == 5 and ma_dir_use_30m_for_5m) ? ma_dir_ma30 : ma_dir_ma15

[ma_dir_tW, ma_dir_bW, ma_dir_cW, ma_dir_nW] = f_ma_dir_get_status(ma_dir_maW, ma_dir_maM, ma_dir_maW_p, ma_dir_has_conv_W), ma_dir_has_conv_W := ma_dir_nW
[ma_dir_tD, ma_dir_bD, ma_dir_cD, ma_dir_nD] = f_ma_dir_get_status(ma_dir_maD, ma_dir_maW, ma_dir_maD_p, ma_dir_has_conv_D), ma_dir_has_conv_D := ma_dir_nD
[ma_dir_t240, ma_dir_b240, ma_dir_c240, ma_dir_n240] = f_ma_dir_get_status(ma_dir_ma240, ma_dir_maD, ma_dir_ma240_p, ma_dir_has_conv_240), ma_dir_has_conv_240 := ma_dir_n240
[ma_dir_t60, ma_dir_b60, ma_dir_c60, ma_dir_n60] = f_ma_dir_get_status(ma_dir_ma60, ma_dir_ma240, ma_dir_ma60_p, ma_dir_has_conv_60), ma_dir_has_conv_60 := ma_dir_n60
[ma_dir_t30, ma_dir_b30, ma_dir_c30, ma_dir_n30] = f_ma_dir_get_status(ma_dir_ma30_v, ma_dir_ma60, ma_dir_ma30_p, ma_dir_has_conv_30), ma_dir_has_conv_30 := ma_dir_n30
[ma_dir_t15, ma_dir_b15, ma_dir_c15, ma_dir_n15] = f_ma_dir_get_status(ma_dir_ma15, ma_dir_ma60, ma_dir_ma15_p, ma_dir_has_conv_15), ma_dir_has_conv_15 := ma_dir_n15
[ma_dir_t5, ma_dir_b5, ma_dir_c5, ma_dir_n5] = f_ma_dir_get_status(ma_dir_ma5, ma_dir_h_5, ma_dir_ma5_p, ma_dir_has_conv_5), ma_dir_has_conv_5 := ma_dir_n5
[ma_dir_t1, ma_dir_b1, ma_dir_c1, ma_dir_n1] = f_ma_dir_get_status(ma_dir_ma1, ma_dir_ma5, ma_dir_ma1_p, ma_dir_has_conv_1), ma_dir_has_conv_1 := ma_dir_n1
[ma_dir_tM, ma_dir_bM, ma_dir_cM, ma_dir_nM] = f_ma_dir_get_status(ma_dir_maM, ma_dir_ma3M, ma_dir_maM_p, ma_dir_has_conv_M), ma_dir_has_conv_M := ma_dir_nM

[ma_dir_t3M, ma_dir_b3M, ma_dir_c3M, ma_dir_n3M] = f_ma_dir_get_status(ma_dir_ma3M, ma_dir_ma12M, ma_dir_ma3M_p, false)

// --- 可視化（描画・テーブル） ---
string ma_dir_high_tf = "12M"
if timeframe.isintraday
    m_val = timeframe.multiplier
    if m_val < 5
        ma_dir_high_tf := "5"
    else if m_val < 15
        ma_dir_high_tf := (m_val == 5 and ma_dir_use_30m_for_5m) ? "30" : "15"
    else if m_val < 60
        ma_dir_high_tf := "60"
    else if m_val < 240
        ma_dir_high_tf := "240"
    else
        ma_dir_high_tf := "D"
else if timeframe.isdaily
    ma_dir_high_tf := "W"
else if timeframe.isweekly
    ma_dir_high_tf := "M"
else if timeframe.ismonthly
    m_val = timeframe.multiplier
    if m_val < 3
        ma_dir_high_tf := "3M"
    else
        ma_dir_high_tf := "12M"

plot(ma_dir_sma_src, color=col_ma_sma, title="MA Dir SMA")
plot(request.security(syminfo.tickerid, ma_dir_high_tf, ma_dir_sma_src, gaps=barmerge.gaps_on), color=col_ma_hi_sma, title="MA Dir Higher TF SMA")

float ma_dir_normal_hi_ma = timeframe.period=="W"?ma_dir_maM:timeframe.period=="D"?ma_dir_maW:timeframe.period=="240"?ma_dir_maD:timeframe.period=="60"?ma_dir_ma240:timeframe.period=="15"?ma_dir_ma60:timeframe.period=="5"?ma_dir_h_5:timeframe.period=="1"?ma_dir_ma5:timeframe.period=="M"?ma_dir_ma3M:ma_dir_ma3M

int ma_dir_cols = 1
var table ma_dir_tab = table.new(position.top_right, ma_dir_cols, 9, border_width=1, border_color=color.gray)

// --- 状態の確定更新 ---
ma_dir_last_t1 := ma_dir_t1, ma_dir_last_t5 := ma_dir_t5, ma_dir_last_t15 := ma_dir_t15, ma_dir_last_t60 := ma_dir_t60, ma_dir_last_t240 := ma_dir_t240, ma_dir_last_tD := ma_dir_tD, ma_dir_last_tW := ma_dir_tW, ma_dir_last_tM := ma_dir_tM

// ============================================================================
// 【外付けブロック】価格を含めたMAリアルタイム並び替え（ソート）テーブル ＆ 背景色表示 / Sorted Table & Background Block
// ============================================================================
group_sorted_tab   = "11. MA Direction MTF - Sorted Table"
use_sorted_table   = input.bool(true, "Show Price & MA Sorted Table / 価格＆MAソートテーブルを表示", group=group_sorted_tab)
sorted_tab_pos     = input.string("Bottom Right", "Table Position / テーブル表示位置", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=group_sorted_tab)
sorted_tab_bg_p    = input.color(color.new(color.yellow, 20), "Price Background Color / 価格背景色", group=group_sorted_tab)
sorted_tab_txt_p   = input.color(color.black, "Price Text Color / 価格文字色", group=group_sorted_tab)

use_sync_bg        = input.bool(true, "Change Background on Full MA Sync / 全MA同方向時にチャート背景色を変える", group=group_sorted_tab)
sync_buy_bg_col    = input.color(color.new(color.blue, 90), "All Bullish BG Color / 全MA買い同方向（背景色）", group=group_sorted_tab)
sync_sell_bg_col   = input.color(color.new(color.red, 90), "All Bearish BG Color / 全MA売り同方向（背景色）", group=group_sorted_tab)

// 表示位置の変換
var sorted_pos_val = position.bottom_right
if sorted_tab_pos == "Top Right"
    sorted_pos_val := position.top_right
else if sorted_tab_pos == "Middle Right"
    sorted_pos_val := position.middle_right
else if sorted_tab_pos == "Bottom Right"
    sorted_pos_val := position.bottom_right
else if sorted_tab_pos == "Top Left"
    sorted_pos_val := position.top_left
else if sorted_tab_pos == "Middle Left"
    sorted_pos_val := position.middle_left
else if sorted_tab_pos == "Bottom Left"
    sorted_pos_val := position.bottom_left

// 外付け：表示オンの時間足MAの方向一致判定（毎足実行＝過去分も保持）
var int[] active_dirs = array.new_int(0)
array.clear(active_dirs)

if ma_dir_showD and not na(ma_dir_maD)
    array.push(active_dirs, ma_dir_tD == "買い" ? 1 : -1)
if ma_dir_show240 and not na(ma_dir_ma240)
    array.push(active_dirs, ma_dir_t240 == "買い" ? 1 : -1)
if ma_dir_show60 and not na(ma_dir_ma60)
    array.push(active_dirs, ma_dir_t60 == "買い" ? 1 : -1)
if ma_dir_show30 and not na(ma_dir_ma30_v)
    array.push(active_dirs, ma_dir_t30 == "買い" ? 1 : -1)
if ma_dir_show15 and not na(ma_dir_ma15)
    array.push(active_dirs, ma_dir_t15 == "買い" ? 1 : -1)
if ma_dir_show5 and not na(ma_dir_ma5)
    array.push(active_dirs, ma_dir_t5 == "買い" ? 1 : -1)
if ma_dir_show1 and not na(ma_dir_ma1)
    array.push(active_dirs, ma_dir_t1 == "買い" ? 1 : -1)

int active_count = array.size(active_dirs)
bool all_buy  = false
bool all_sell = false

if active_count > 0
    all_buy  := true
    all_sell := true
    for idx = 0 to active_count - 1
        if array.get(active_dirs, idx) != 1
            all_buy := false
        if array.get(active_dirs, idx) != -1
            all_sell := false

// ヘッダー背景色決定
color header_bg_col = color.black
if all_buy
    header_bg_col := color.blue
else if all_sell
    header_bg_col := color.red

// チャート背景色の外付け描写（過去足全域に適用）
color chart_bg_col = na
if use_sync_bg
    if all_buy
        chart_bg_col := sync_buy_bg_col
    else if all_sell
        chart_bg_col := sync_sell_bg_col

bgcolor(chart_bg_col, title="Full Sync Background Color / 全MA同方向 チャート背景色")

// 外付けテーブルの初期化（1列 × 8行）
var table sorted_ma_tab = table.new(sorted_pos_val, 1, 8, border_width=1)

if use_sorted_table and barstate.islast
    // 既存のテーブルをクリア
    table.clear(sorted_ma_tab, 0, 0, 0, 7)
    
    // データの収集（価格と各MA値・ラベル・元カラー）
    var string[]  labels = array.new_string(0)
    var float[]   values = array.new_float(0)
    var color[]   bg_cols = array.new_color(0)
    var color[]   txt_cols = array.new_color(0)
    
    array.clear(labels)
    array.clear(values)
    array.clear(bg_cols)
    array.clear(txt_cols)
    
    // 現在価格（PRICE）を配列に追加
    array.push(labels, "PRICE")
    array.push(values, close)
    array.push(bg_cols, sorted_tab_bg_p)
    array.push(txt_cols, sorted_tab_txt_p)

    // 各上位足MAの追加（インプットでONのもののみ参照）
    if ma_dir_showD and not na(ma_dir_maD)
        array.push(labels, "D")
        array.push(values, ma_dir_maD)
        array.push(bg_cols, ma_dir_bD)
        array.push(txt_cols, ma_dir_cD)
        
    if ma_dir_show240 and not na(ma_dir_ma240)
        array.push(labels, "4H")
        array.push(values, ma_dir_ma240)
        array.push(bg_cols, ma_dir_b240)
        array.push(txt_cols, ma_dir_c240)
        
    if ma_dir_show60 and not na(ma_dir_ma60)
        array.push(labels, "1H")
        array.push(values, ma_dir_ma60)
        array.push(bg_cols, ma_dir_b60)
        array.push(txt_cols, ma_dir_c60)

    if ma_dir_show30 and not na(ma_dir_ma30_v)
        array.push(labels, "30m")
        array.push(values, ma_dir_ma30_v)
        array.push(bg_cols, ma_dir_b30)
        array.push(txt_cols, ma_dir_c30)

    if ma_dir_show15 and not na(ma_dir_ma15)
        array.push(labels, "15m")
        array.push(values, ma_dir_ma15)
        array.push(bg_cols, ma_dir_b15)
        array.push(txt_cols, ma_dir_c15)
        
    if ma_dir_show5 and not na(ma_dir_ma5)
        array.push(labels, "5m")
        array.push(values, ma_dir_ma5)
        array.push(bg_cols, ma_dir_b5)
        array.push(txt_cols, ma_dir_c5)
        
    if ma_dir_show1 and not na(ma_dir_ma1)
        array.push(labels, "1m")
        array.push(values, ma_dir_ma1)
        array.push(bg_cols, ma_dir_b1)
        array.push(txt_cols, ma_dir_c1)

    // バブルソートによる降順並び替え（大きい値が上）
    int count = array.size(values)
    if count > 1
        for i = 0 to count - 2
            for j = 0 to count - i - 2
                if array.get(values, j) < array.get(values, j + 1)
                    // 値の入れ替え
                    float temp_val = array.get(values, j)
                    array.set(values, j, array.get(values, j + 1))
                    array.set(values, j + 1, temp_val)
                    
                    // ラベルの入れ替え
                    string temp_lbl = array.get(labels, j)
                    array.set(labels, j, array.get(labels, j + 1))
                    array.set(labels, j + 1, temp_lbl)
                    
                    // 背景色の入れ替え
                    color temp_bg = array.get(bg_cols, j)
                    array.set(bg_cols, j, array.get(bg_cols, j + 1))
                    array.set(bg_cols, j + 1, temp_bg)
                    
                    // 文字色の入れ替え
                    color temp_txt = array.get(txt_cols, j)
                    array.set(txt_cols, j, array.get(txt_cols, j + 1))
                    array.set(txt_cols, j + 1, temp_txt)

    // ヘッダー（方向一致状態に応じて背景色を変更）
    table.cell(sorted_ma_tab, 0, 0, "ORDER", bgcolor=header_bg_col, text_color=color.white, text_size=size.small)
    
    // ソート済データ行（1列のみ）
    if count > 0
        for k = 0 to count - 1
            table.cell(sorted_ma_tab, 0, k + 1, array.get(labels, k), bgcolor=array.get(bg_cols, k), text_color=array.get(txt_cols, k), text_size=size.small)

// ============================================================================
// 【外付けブロック】2MA 収束・拡散・クロス・頂点1形成・ダウブレイク ステップアラート / Step Alert Settings
// ============================================================================
string group_ma_step = "12. Step Alert Settings / ステップアラート設定"
bool use_ma_step_alert = input.bool(false, "Enable Step Alerts / ステップアラートを有効化", group=group_ma_step)
bool use_sync_filter   = input.bool(false, "Filter by Full MA Sync / 全MA同方向時のみアラートを許可", group=group_ma_step)

string step1_evt = input.string("収束", "Step 1 / ステップ1", options=["オフ", "クロス", "収束", "拡散"], group=group_ma_step)
string step2_evt = input.string("拡散", "Step 2 / ステップ2", options=["オフ", "クロス", "収束", "拡散"], group=group_ma_step)
string step3_evt = input.string("山谷形成", "Step 3 (Final Trigger) / ステップ3（最終判定）", options=["オフ", "山谷形成", "ブレイク", "クロス", "収束", "拡散"], group=group_ma_step)

// --- 縦帯（背景色）描画設定 ---
bool show_step_bg       = input.bool(true, "Draw Vertical Band on Step Achievement / ステップ達成時に背景に縦帯を描画", group=group_ma_step)
bool show_step3_only_bg = input.bool(false, "Draw Band on Alert Trigger Only / アラートトリガー時のみ縦帯を描画", group=group_ma_step)

color col_step1_bg_up   = input.color(color.new(color.yellow, 80), "Step 1 Bullish Color / ステップ1（上向き）", group=group_ma_step)
color col_step1_bg_dn   = input.color(color.new(color.yellow, 80), "Step 1 Bearish Color / ステップ1（下向き）", group=group_ma_step)

color col_step2_bg_up   = input.color(color.new(color.orange, 80), "Step 2 Bullish Color / ステップ2（上向き）", group=group_ma_step)
color col_step2_bg_dn   = input.color(color.new(color.orange, 80), "Step 2 Bearish Color / ステップ2（下向き）", group=group_ma_step)

color col_step3_bg_up   = input.color(color.new(color.blue, 70),   "Step 3 Bullish Color / ステップ3（上向き / 買い）", group=group_ma_step)
color col_step3_bg_dn   = input.color(color.new(color.red, 70),    "Step 3 Bearish Color / ステップ3（下向き / 売り）", group=group_ma_step)

// --- 全オフ判定 ---
bool is_all_off = (step1_evt == "オフ") and (step2_evt == "オフ") and (step3_evt == "オフ")

// --- 基準変数（不動の事実）の直接参照 ---
float _cur_ma = ma_dir_sma_src
float _hi_ma  = ma_dir_normal_hi_ma
float _ma_p1  = ma_dir_sma_src[ma_dir_lookback]

// --- 物理的状態の直接判定 ---
bool _is_ma_up    = _cur_ma > _ma_p1
bool _is_ma_above = _cur_ma > _hi_ma

// 収束・拡散の「切り替わり（タイミング）」の物理定義
bool _raw_conv = _is_ma_above ? not _is_ma_up : _is_ma_up
bool _raw_div  = _is_ma_above ? _is_ma_up     : not _is_ma_up

bool is_evt_conv = _raw_conv and not _raw_conv[1]  // 拡散 → 収束へ切り替わった瞬間
bool is_evt_div  = _raw_div  and not _raw_div[1]   // 収束 → 拡散へ切り替わった瞬間

// クロス判定
bool is_evt_cross_up = ta.crossover(_cur_ma, _hi_ma)
bool is_evt_cross_dn = ta.crossunder(_cur_ma, _hi_ma)

// 既存ジグザグ確定値（不動の事実）の直接参照
bool is_evt_brk_up = (dir0[1] <= 0 and bUp0)  // 起点1確定（買い）
bool is_evt_brk_dn = (dir0[1] >= 0 and bDn0)  // 起点1確定（売り）

// ============================================================================
// 【主（絶対軸）】クロスの向きを常時保持・後退のみで固定
// ============================================================================
var int main_cross_dir = 0

if is_evt_cross_up
    main_cross_dir := 1
else if is_evt_cross_dn
    main_cross_dir := -1
else if main_cross_dir == 0
    main_cross_dir := _is_ma_above ? 1 : -1

// ============================================================================
// 【従（フィルタ）】主の方向に従い、イベント発生（条件通過）のみをチェック
// ============================================================================
f_chk_step_evt(_type) =>
    bool _occ = false
    if _type == "オフ"
        _occ := true
    else if _type == "クロス"
        if main_cross_dir == 1 and is_evt_cross_up
            _occ := true
        else if main_cross_dir == -1 and is_evt_cross_dn
            _occ := true
    else if _type == "収束"
        if is_evt_conv
            _occ := true
    else if _type == "拡散"
        if is_evt_div
            _occ := true
    else if _type == "山谷形成"
        if top0
            bool _is_valley = (ly0 == l0)
            bool _is_peak   = (ly0 == h0)
            if main_cross_dir == 1 and _is_valley
                _occ := true
            else if main_cross_dir == -1 and _is_peak
                _occ := true
    else if _type == "ブレイク"
        if main_cross_dir == 1 and is_evt_brk_up
            _occ := true
        else if main_cross_dir == -1 and is_evt_brk_dn
            _occ := true
    [_occ, main_cross_dir]

// --- ステートマシン変数 ---
var int ma_step_state = 0
var int ma_step_dir   = 0

// 当足での各ステップ達成バーの記録（同一足ノイズ排除用）
var int last_step1_bar = -1
var int last_step2_bar = -1

// 当足での達成イベント（描画・フラグ用）
bool now_step1_achieved = false
bool now_step2_achieved = false
bool ma_step_fire       = false

var int step1_dir = 0
var int step2_dir = 0
var int fired_dir = 0

// 毎バーのリセット
now_step1_achieved := false
now_step2_achieved := false
ma_step_fire       := false

if use_ma_step_alert and not is_all_off

    // 主軸方向の逆転（クロス発生）時、進行中ステートを無効化リセット
    if is_evt_cross_up or is_evt_cross_dn
        ma_step_state := 0
        ma_step_dir   := 0

    // 【ステップ1 発生チェック】
    [o1_check, d1_check] = f_chk_step_evt(step1_evt)
    bool is_step1_occurred = o1_check and (step1_evt != "オフ")

    // 【ステップ1 評価（優先リセット）】
    if is_step1_occurred
        ma_step_state      := (step2_evt == "オフ") ? 2 : 1
        ma_step_dir        := d1_check
        step1_dir          := d1_check
        now_step1_achieved := true
        last_step1_bar     := bar_index

    // 【ステップ2 評価】
    // 条件：(state 1 であるか、①オフ時の state 0 であるか) かつ (ステップ1と同一足でないこと)
    bool can_eval_step2 = ((ma_step_state == 1) or (step1_evt == "オフ" and ma_step_state == 0)) and (bar_index != last_step1_bar)

    if can_eval_step2 and (step2_evt != "オフ")
        [o2, d2] = f_chk_step_evt(step2_evt)
        if o2
            ma_step_state      := 2
            ma_step_dir        := d2
            step2_dir          := d2
            now_step2_achieved := true
            last_step2_bar     := bar_index

// 【ステップ3 評価】
    // 条件：(state 2 であること) かつ (ステップ2と同一足でないこと)
    bool can_eval_step3 = (ma_step_state == 2) and (bar_index != last_step2_bar)

    if can_eval_step3
        if step3_evt == "オフ"
            ma_step_fire  := true
            fired_dir     := step2_dir
            ma_step_state := 0
            ma_step_dir   := 0
        else
            [o3, d3] = f_chk_step_evt(step3_evt)
            if o3
                ma_step_fire  := true
                fired_dir     := d3
                ma_step_state := 0
                ma_step_dir   := 0

// 全MA同方向フィルタの適用
bool ma_step_fire_filtered = ma_step_fire and (not use_sync_filter or (fired_dir == 1 and all_buy) or (fired_dir == -1 and all_sell))

// --- 縦帯（背景色）の方向別描画判定 ---
color bg_draw_color = na

if show_step_bg and use_ma_step_alert and not is_all_off
    if ma_step_fire_filtered
        if step3_evt == "オフ"
            bg_draw_color := fired_dir == 1 ? col_step2_bg_up : col_step2_bg_dn
        else
            bg_draw_color := fired_dir == 1 ? col_step3_bg_up : col_step3_bg_dn
    else if not show_step3_only_bg
        if now_step2_achieved
            bg_draw_color := step2_dir == 1 ? col_step2_bg_up : col_step2_bg_dn
        else if now_step1_achieved
            bg_draw_color := step1_dir == 1 ? col_step1_bg_up : col_step1_bg_dn

bgcolor(bg_draw_color, title="Step Achievement Band / ステップ達成 縦帯")

// --- アラート登録 ---
if ma_step_fire_filtered
    string _dir_txt = fired_dir == 1 ? "BUY" : "SELL"
    string _msg     = "Step Alert [" + _dir_txt + "] (" + timeframe.period + ")"
    alert(_msg, alert.freq_once_per_bar_close)

// ============================================================================
// 【外付けブロック】ステップ現在地表示テーブル（物理ラッチ・全消灯完全ゼロ版） / Step Status Table
// ============================================================================
show_step_cfg_tab = input.bool(true, "Show Step Status Table / ステップ設定テーブルを表示", group=group_ma_step)

// 表示専用の現在地保持ラッチ変数（初期値は1とし、0へのフォールバックを物理遮断）
var int last_active_step = 1

if use_ma_step_alert
    // 主軸方向の物理的逆転（クロス）時、ステップ1へ初期同期
    if is_evt_cross_up or is_evt_cross_dn
        last_active_step := 1
    // 既存ロジックが 1, 2, 3 に到達した瞬間のみ上書き（0へのリセットは無視して保持）
    else if ma_step_state == 1
        last_active_step := 1
    else if ma_step_state == 2
        last_active_step := 2
    else if ma_step_fire
        last_active_step := 3

var table step_cfg_tab = table.new(position.top_right, 1, 3, border_width=0, border_color=color.new(color.white, 100))

if use_ma_step_alert and show_step_cfg_tab and barstate.islast
    table.clear(step_cfg_tab, 0, 0, 0, 2)
    
    // 方向に応じた色定義（買い=青 / 売り=赤）
    color active_col = main_cross_dir == 1 ? color.new(color.blue, 30) : main_cross_dir == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
    color trans_col  = color.new(color.white, 100)

    // last_active_step (1, 2, 3) の値に応じた「1行のみ」を点灯（全消灯を物理的に排除）
    color bg1 = (last_active_step == 1) ? active_col : trans_col
    color tx1 = (last_active_step == 1) ? color.white  : #000000

    color bg2 = (last_active_step == 2) ? active_col : trans_col
    color tx2 = (last_active_step == 2) ? color.white  : #000000

    color bg3 = (last_active_step == 3) ? active_col : trans_col
    color tx3 = (last_active_step == 3) ? color.white  : #000000

    // 1. ステップ1
    table.cell(step_cfg_tab, 0, 0, "1. " + step1_evt, bgcolor=bg1, text_color=tx1, text_size=size.normal)

    // 2. ステップ2
    table.cell(step_cfg_tab, 0, 1, "2. " + step2_evt, bgcolor=bg2, text_color=tx2, text_size=size.normal)

    // 3. ステップ3
    table.cell(step_cfg_tab, 0, 2, "3. " + step3_evt, bgcolor=bg3, text_color=tx3, text_size=size.normal)
````
