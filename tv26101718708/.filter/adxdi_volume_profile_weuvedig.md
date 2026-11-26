# ADX/DI Volume Profile

- url: https://www.tradingview.com/script/WEUVedIG/
- type: indicator
- pine_id: PUB;d4f6dc4e8b1847ac8675d51beb9f3962
- version: 3.0

## Description

ADX/DI Volume Profile

Hello everyone. Please excuse my English, as I am not a native speaker. I use translation tools, but I hope my passion for coding reaches you.

First of all, I want to express my deepest respect and gratitude to @LuxAlgo. Your incredibly creative scripts and stunning visual designs have always been a huge inspiration to my coding journey. Thank you!

[ Overview ]

Usually, ADX and DMI are drawn at the bottom of the chart to show when a trend is strong. But I wanted to know where (at what price) the trend was the strongest.

This script creates a "Spatial Energy Memory." It stacks buying and selling power not by time, but by price levels, and in this "Ultimate" version, it perfectly fuses Volume (market heat) with momentum.

[ How it Calculates ]

Making Boxes: 
We take the highest and lowest price of a fixed period and divide that space into equal rows.

Storing Energy (Volume Weighted):
 If a candle passes through 5 rows, we calculate the ADX/DI momentum and multiply it by the Volume of that specific candle. The explosive "heat" of the market is then shared into those 5 rows.

Drawing Blocks: 
The price row with the highest total points gets the longest block on the chart.

[ How to Read the Chart ]

Blue Walls (+DI):
 Strong buying energy and volume. Acts as a powerful support.

Red Walls (-DI):
 Strong selling energy and volume. Acts as a heavy resistance.

ADX POC (Yellow Dashed Line): 
The exact price where the trend energy exploded the most.

Local VWAP & Fibonacci: 
Displays the Volume Weighted Average Price within the session, along with clean, non-obtrusive Fibonacci levels to identify dynamic support/resistance.
[image]https://www.tradingview.com/x/Vk0sJtKT/[/image]
[ Key Features & Optimizations ]

Fixed Steps Engine (Zero Repaint): 
To ensure maximum reliability for real-time trading, this indicator locks the profile frames into fixed past sessions. The boundaries never shift, meaning your support/resistance levels are absolute and will never repaint.

Performance Optimized:
 TradingView has a strict limit of 500 drawings per script. To prevent visual bugs and missing blocks, I have hard-capped the resolution to a maximum of 40 rows and 3 historical sessions. This ensures a highly stable and beautiful display, effectively preventing common visual glitches.

Streamlined Layouts: 
Choose from Left, Right, or Center Aligned. You can independently set the layout for +DI, -DI, and ADX to create beautiful "Mirror" or "Butterfly" setups.

Noise Filter: 
By increasing the Noise Filter, weak and transparent energy blocks are automatically stripped away, leaving only the true, thick walls of the market.

Enjoy the ultimate spatial view of the market!

(Japanese )

皆さんこんにちは。私は英語のネイティブスピーカーではないため、至らない表現があるかもしれませんが、このスクリプトに込めた熱意が皆様に伝われば嬉しいです。

まず初めに、LuxAlgo氏へ最大限の敬意と感謝を捧げます。あなたの驚くべきスクリプトと洗練された視覚的デザインは、私のコーディングの旅において常に巨大なインスピレーションの源でした。本当にありがとうございます。

[ 概要 ]

通常、ADXやDMIはチャートの下部に表示され、「いつ」トレンドが強かったかを示します。しかし、私は「どの価格帯で」トレンドが最も強かったかを知りたいと考えました。

このスクリプトは時間軸ではなく価格帯（空間）ごとにパワーを積み上げ、さらに出来高（相場の熱量）を完全に融合させた「エネルギーの記憶」を描き出します。

[ 計算のロジック ]

箱を作る： 一定期間の最高値と最安値を取り、その空間を等間隔の行に分割します。

エネルギーを配分する（出来高補正）： ローソク足が5つの箱を通過した場合、その時のADX/DIのモメンタムに出来高を掛け合わせます。大口が本気で叩いてきた「熱量」が、5つの箱に配分されます。

ブロックを描画する： 最終的に最も多くポイントが蓄積された価格帯に、最も長いブロックを描画します。

[ チャートの見方 ]

青い壁（+DI）/ 赤い壁（-DI）： 強い買い（または売り）エネルギーと出来高が蓄積された場所です。強力なサポート/レジスタンスとして機能します。

ADX POC（黄色の破線）： トレンドの勢いが最も爆発したコアとなる価格帯です。

Local VWAP & フィボナッチ： 期間内のVWAP（出来高加重平均価格）と、視界を邪魔しない洗練されたフィボナッチを表示します。

[ 主要機能と最適化 ]

完全固定エンジン（リペイントなし）： 実戦トレードでの信頼性を極限まで高めるため、プロファイルの枠組みは過去の一定期間で完全にロックされます。基準枠がズレたりリペイントしたりすることは一切なく、描画された壁は絶対的な基準として機能します。

パフォーマンス最適化（バグ防止）： TradingViewの「最大500個の描画制限」による表示崩れを完全に防ぐため、解像度（最大40分割）と表示数（最大3セッション）に安全装置となる上限を設けています。これにより、システムの限界による表示崩れを未然に防ぎ、いかなる相場でも極めて安定した美しい表示を実現します。

洗練されたレイアウト： +DI、-DI、ADXの配置を独立して設定でき、買いと売りを反発させる「ミラー配置」なども自由に構築可能です。

ノイズフィルター： フィルターの数値を上げると、エネルギーの弱い透明なブロックが自動的に削ぎ落とされ、本当に意識される「分厚い壁」だけを残すことができます。

空間的な市場分析をお楽しみください！

## Source Code

````pine
// © ALT_analyst_experimental
// ADX/DI Volume Profile Ultimate - Stable Edition
//@version=6
indicator("ADX/DI Volume Profile", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ==========================================
// 1. Inputs & UI Definitions (Streamlined & Capped)
// ==========================================
grp_sess = " [ SYSTEM ] Profile Session Settings"
prof_period = input.int(50, "Period (Bars)", minval=10, group=grp_sess)
prof_num    = input.int(2, "Historical Sessions", minval=1, maxval=3, group=grp_sess, tooltip="Max 3 sessions to prevent TV 500-box limit bugs.")
row_count   = input.int(40, "Resolution (Row Count)", minval=10, maxval=40, group=grp_sess, tooltip="Max 40 rows for perfect stability.")

grp_mtf = " [ SYSTEM ] MTF & Volume"
use_mtf = input.bool(false, "Project Higher Timeframe (MTF)", group=grp_mtf)
htf_res = input.timeframe("60", "Higher Timeframe", group=grp_mtf)
use_vol = input.bool(true, "Weight Energy by Volume", group=grp_mtf)

grp_lay = " [ H.U.D ] Layout & Opacity"
opt_L = "Left Aligned"
opt_R = "Right Aligned"
opt_C = "Center Aligned"

lay_plus  = input.string(opt_L, "+DI Layout", options=[opt_L, opt_R, opt_C], group=grp_lay)
lay_minus = input.string(opt_L, "-DI Layout", options=[opt_L, opt_R, opt_C], group=grp_lay)
lay_adx   = input.string(opt_L, "ADX Layout", options=[opt_L, opt_R, opt_C], group=grp_lay)

widthPct       = input.float(0.45, "Max Width Pct", minval=0.1, maxval=1.0, step=0.05, group=grp_lay)
midVolWidthPct = input.float(0.15, "ADX Width Pct", minval=0.05, maxval=0.5, step=0.05, group=grp_lay)
opacityNorm    = input.int(60, "Normal Opacity (%)", minval=0, maxval=100, step=5, group=grp_lay)
opacityAlrt    = input.int(40, "High Density Opacity (%)", minval=0, maxval=100, step=5, group=grp_lay)
show_bg        = input.bool(true, "Show Background Area", group=grp_lay)
bg_color       = input.color(color.new(#131722, 60), "Background Color", group=grp_lay)

grp_lbl = " [ LABELS ] Values & Display"
show_val_lbl  = input.bool(true, "Show Profile Values", group=grp_lbl)
lbl_bg_col    = input.color(color.new(color.black, 60), "Label BG Color", group=grp_lbl)
txt_size      = input.string(size.small, "Text Size", options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=grp_lbl)
txt_shw_rat   = input.float(0.8, "Label Show Threshold", minval=0.1, maxval=1.0, step=0.1, group=grp_lbl)

grp_st = " [ STYLE ] Lines & POC"
show_poc_a = input.bool(true, "ADX POC", inline="pa", group=grp_st)
col_poc_a  = input.color(#FFFF00, "", inline="pa", group=grp_st)
wid_poc_a  = input.int(2, "", minval=1, maxval=5, inline="pa", group=grp_st)
sty_poc_a  = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], inline="pa", group=grp_st)

show_poc_p = input.bool(true, "+DI POC", inline="pp", group=grp_st)
col_poc_p  = input.color(#00FFFF, "", inline="pp", group=grp_st)
wid_poc_p  = input.int(1, "", minval=1, maxval=5, inline="pp", group=grp_st)
sty_poc_p  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="pp", group=grp_st)

show_poc_m = input.bool(true, "-DI POC", inline="pm", group=grp_st)
col_poc_m  = input.color(#FF0000, "", inline="pm", group=grp_st)
wid_poc_m  = input.int(1, "", minval=1, maxval=5, inline="pm", group=grp_st)
sty_poc_m  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="pm", group=grp_st)

grp_vwap = " [ SYSTEM ] Local VWAP & Fibonacci"
show_vwap  = input.bool(true, "VWAP", inline="v", group=grp_vwap)
col_vwap   = input.color(color.new(color.white, 30), "", inline="v", group=grp_vwap)
wid_vwap   = input.int(2, "", minval=1, maxval=5, inline="v", group=grp_vwap)
sty_vwap   = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="v", group=grp_vwap)

show_fib   = input.bool(true, "Show Fibonacci", group=grp_vwap)
f1_on = input.bool(true, "Fib 1:", inline="f1", group=grp_vwap)
f1_vl = input.float(0.382, "", step=0.05, inline="f1", group=grp_vwap)
f1_cl = input.color(color.new(color.red, 30), "", inline="f1", group=grp_vwap)
f1_wd = input.int(1, "W", minval=1, maxval=5, inline="f1", group=grp_vwap)
f1_st = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="f1", group=grp_vwap)

f2_on = input.bool(true, "Fib 2:", inline="f2", group=grp_vwap)
f2_vl = input.float(0.618, "", step=0.05, inline="f2", group=grp_vwap)
f2_cl = input.color(color.new(color.green, 30), "", inline="f2", group=grp_vwap)
f2_wd = input.int(3, "W", minval=1, maxval=5, inline="f2", group=grp_vwap)
f2_st = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], inline="f2", group=grp_vwap)

f3_on = input.bool(true, "Fib 3:", inline="f3", group=grp_vwap)
f3_vl = input.float(1.000, "", step=0.05, inline="f3", group=grp_vwap)
f3_cl = input.color(color.new(color.purple, 30), "", inline="f3", group=grp_vwap)
f3_wd = input.int(2, "W", minval=1, maxval=5, inline="f3", group=grp_vwap)
f3_st = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="f3", group=grp_vwap)

grp_dmi = " [ ENGINE ] ALGORITHMIC DMI"
dmi_len      = input.int(14, "ADX/DI Length", minval=1, group=grp_dmi)
adx_thresh   = input.int(25, "ADX Threshold", group=grp_dmi)
noise_filter = input.float(0.08, "Noise Filter (0.0~1.0)", minval=0.0, step=0.02, group=grp_dmi) 

grp_col = " [ SHADER ] INHERITED COLORS"
up_C1 = input.color(#01579B, "Up Cold (Noise)", group=grp_col, inline="up")
up_C2 = input.color(#2962FF, "Up Warm (Trend)", group=grp_col, inline="up")
up_C3 = input.color(#00E5FF, "Up Hot (Chance)", group=grp_col, inline="up")

dn_C1 = input.color(#311B92, "Dn Cold (Noise)", group=grp_col, inline="dn")
dn_C2 = input.color(#C51162, "Dn Warm (Trend)", group=grp_col, inline="dn")
dn_C3 = input.color(#FF5252, "Dn Hot (Chance)", group=grp_col, inline="dn")

ax_C1 = input.color(#FF8F00, "ADX Cold", group=grp_col, inline="ax")
ax_C2 = input.color(#FFD54F, "ADX Warm", group=grp_col, inline="ax")
ax_C3 = input.color(#FFFF00, "ADX Hot", group=grp_col, inline="ax")

// ==========================================
// 2. Data Calculation & Core Functions
// ==========================================
[d_p, d_m, a_v] = ta.dmi(dmi_len, dmi_len)
[s_dp, s_dm, s_av, s_vol] = request.security(syminfo.tickerid, use_mtf ? htf_res : timeframe.period, [d_p, d_m, a_v, volume])

f_format_k(float val) =>
    float abs_val = math.abs(val)
    string res = ""
    if abs_val >= 1000000
        res := str.tostring(val / 1000000, "#.##") + "M"
    else if abs_val >= 1000
        res := str.tostring(val / 1000, "#.#") + "k"
    else
        res := str.tostring(val, "#.#")
    res

f_get_tf_mult(string tf) =>
    int ltf_sec = timeframe.in_seconds(timeframe.period)
    int htf_sec = timeframe.in_seconds(tf)
    float mult = (htf_sec > 0 and ltf_sec > 0) ? (htf_sec / ltf_sec) : 1.0
    math.max(1, math.round(mult))

int tf_mult = use_mtf ? f_get_tf_mult(htf_res) : 1
int actual_period = math.min(prof_period * tf_mult, 4000)

f_sty(string s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_get_heatmap_color(float r, color c1, color c2, color c3) =>
    color c = c1
    if r <= 0.25
        c := color.from_gradient(r, 0.0, 0.25, c1, color.from_gradient(0.5, 0.0, 1.0, c1, c2))
    else if r <= 0.50
        c := color.from_gradient(r, 0.25, 0.50, color.from_gradient(0.5, 0.0, 1.0, c1, c2), c2)
    else if r <= 0.75
        c := color.from_gradient(r, 0.50, 0.75, c2, color.from_gradient(0.5, 0.0, 1.0, c2, c3))
    else
        c := color.from_gradient(r, 0.75, 1.0, color.from_gradient(0.5, 0.0, 1.0, c2, c3), c3)
    c

f_get_coords(string layout_type, int p_start_bar, int p_end_bar, int mid_bar, int w) =>
    int bl = 0, int br = 0
    if layout_type == opt_L
        bl := p_start_bar, br := p_start_bar + w
    else if layout_type == opt_R
        br := p_end_bar, bl := p_end_bar - w
    else if layout_type == opt_C
        bl := mid_bar - math.round(w / 2), br := mid_bar + math.round(w / 2)
    [bl, br]

f_draw_fib(line[] l_arr, float val, color base_c, int width, string sty, bool on, float l_vwap, float d_up, float d_dn, int p_start, int p_end, int p_idx) =>
    if on
        float price_u = l_vwap + (d_up * val)
        float price_d = l_vwap - (d_dn * val)
        float current_t = color.t(base_c)
        float new_t = math.min(100, current_t + (p_idx * 15))
        color prof_col = color.new(base_c, new_t)
        array.push(l_arr, line.new(p_start, price_u, p_end, price_u, color=prof_col, style=f_sty(sty), width=width))
        array.push(l_arr, line.new(p_start, price_d, p_end, price_d, color=prof_col, style=f_sty(sty), width=width))

// ==========================================
// 3. Drawing Engine (STABLE ANCHOR LOGIC)
// ==========================================
var box[]  all_boxes  = array.new_box()
var line[] all_lines  = array.new_line()
var label[] all_labels = array.new_label()

if barstate.islast
    if array.size(all_boxes) > 0
        for i = 0 to array.size(all_boxes) - 1
            box.delete(array.get(all_boxes, i))
    if array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
    if array.size(all_labels) > 0
        for i = 0 to array.size(all_labels) - 1
            label.delete(array.get(all_labels, i))
            
    array.clear(all_boxes)
    array.clear(all_lines)
    array.clear(all_labels)

    int current_step = math.floor(bar_index / actual_period)

    for p = 0 to prof_num - 1
        int target_step = current_step - p
        int p_start_bar = target_step * actual_period
        int p_end_bar   = p_start_bar + actual_period - 1
        int calc_end_bar = math.min(bar_index, p_end_bar)

        if p_start_bar < 0
            continue
            
        int mid_bar = math.round((p_start_bar + p_end_bar) / 2)
        int offset_end   = math.max(0, bar_index - calc_end_bar)
        int offset_start = math.max(0, bar_index - p_start_bar)
        
        float s_high = high[offset_end]
        float s_low  = low[offset_end]
        
        for offset = offset_end to offset_start
            s_high := math.max(s_high, high[offset])
            s_low  := math.min(s_low, low[offset])
                
        if na(s_high) or na(s_low) or s_high == s_low
            s_high := close[offset_end] + (syminfo.mintick * 5)
            s_low  := close[offset_end] - (syminfo.mintick * 5)

        if show_bg
            array.push(all_boxes, box.new(left=p_start_bar, top=s_high, right=p_end_bar, bottom=s_low, border_color=na, bgcolor=bg_color))
            
        float step_price = (s_high - s_low) / row_count
        
        float[] row_plus_acc  = array.new_float(row_count, 0.0)
        float[] row_minus_acc = array.new_float(row_count, 0.0)
        float[] row_adx_acc   = array.new_float(row_count, 0.0)
        float[] row_touches   = array.new_float(row_count, 0.0)

        float sum_vol = 0.0
        float sum_src_vol = 0.0

        for offset = offset_end to offset_start
            float v_raw = use_mtf ? nz(s_vol[offset], 1) : nz(volume[offset], 1)
            float c_vol = (use_vol and v_raw > 0) ? v_raw : 1.0
            
            float typical_p = (high[offset] + low[offset] + close[offset]) / 3
            sum_vol += c_vol
            sum_src_vol += typical_p * c_vol

            float raw_p_plus  = nz(s_dp[offset])
            float raw_p_minus = nz(s_dm[offset])
            float net_di_ratio = (raw_p_plus + raw_p_minus) == 0 ? 0 : math.abs(raw_p_plus - raw_p_minus) / (raw_p_plus + raw_p_minus)

            float p_plus  = raw_p_plus * c_vol * (1 + net_di_ratio)
            float p_minus = raw_p_minus * c_vol * (1 + net_di_ratio)
            float c_adx   = nz(s_av[offset]) * c_vol * (1 + net_di_ratio)
            
            int start_row = math.floor((low[offset] - s_low) / step_price)
            int end_row   = math.floor((high[offset] - s_low) / step_price)
            start_row := math.max(0, math.min(start_row, row_count - 1))
            end_row   := math.max(0, math.min(end_row, row_count - 1))
            
            int rows_touched = (end_row - start_row) + 1
            
            for r = start_row to end_row
                array.set(row_plus_acc, r, array.get(row_plus_acc, r) + (p_plus / rows_touched))
                array.set(row_minus_acc, r, array.get(row_minus_acc, r) + (p_minus / rows_touched))
                array.set(row_adx_acc, r, array.get(row_adx_acc, r) + (c_adx / rows_touched))
                array.set(row_touches, r, array.get(row_touches, r) + 1)

        float local_vwap = sum_vol > 0 ? sum_src_vol / sum_vol : na

        float max_plus  = array.max(row_plus_acc)
        float max_minus = array.max(row_minus_acc)
        float max_adx   = array.max(row_adx_acc)
        
        int poc_adx_idx   = array.indexof(row_adx_acc, max_adx)
        int poc_plus_idx  = array.indexof(row_plus_acc, max_plus)
        int poc_minus_idx = array.indexof(row_minus_acc, max_minus)
                
        max_plus  := max_plus <= 0 ? 1.0 : max_plus
        max_minus := max_minus <= 0 ? 1.0 : max_minus
        max_adx   := max_adx <= 0 ? 1.0 : max_adx

        int max_w_bars = math.round(actual_period * widthPct)
        int adx_w_bars = math.round(actual_period * midVolWidthPct)

        for r = 0 to row_count - 1
            float val_plus  = array.get(row_plus_acc, r)
            float val_minus = array.get(row_minus_acc, r)
            float val_adx   = array.get(row_adx_acc, r)
            float touches   = array.get(row_touches, r)
            
            float ratio_plus  = val_plus / max_plus
            float ratio_minus = val_minus / max_minus
            float ratio_adx   = val_adx / max_adx
            
            float avg_adx = touches > 0 ? val_adx / touches : 0
            bool is_adx_strong = avg_adx >= adx_thresh
            bool bull_chance = is_adx_strong and (val_plus > val_minus * 1.2)
            bool bear_chance = is_adx_strong and (val_minus > val_plus * 1.2)
            
            float b_bot = s_low + (r * step_price)
            float b_top = s_low + ((r + 1) * step_price)
            float box_mid = (b_top + b_bot) / 2

            // Rendering Logic
            if ratio_plus >= noise_filter
                color c_plus_base  = f_get_heatmap_color(ratio_plus, up_C1, up_C2, up_C3)
                int op_p = bull_chance ? opacityAlrt : opacityNorm
                [bl_p, br_p] = f_get_coords(lay_plus, p_start_bar, p_end_bar, mid_bar, math.max(1, math.round(max_w_bars * ratio_plus)))
                array.push(all_boxes, box.new(bl_p, b_top, br_p, b_bot, border_color=na, bgcolor=color.new(c_plus_base, op_p)))
                
                if show_val_lbl and ratio_plus >= txt_shw_rat
                    int x_p = lay_plus == opt_L ? br_p : (lay_plus == opt_R ? bl_p : br_p)
                    string align_p = lay_plus == opt_L ? label.style_label_left : (lay_plus == opt_R ? label.style_label_right : label.style_label_left)
                    array.push(all_labels, label.new(x_p, box_mid, f_format_k(val_plus), color=lbl_bg_col, textcolor=c_plus_base, size=txt_size, style=align_p))

            if ratio_minus >= noise_filter
                color c_minus_base = f_get_heatmap_color(ratio_minus, dn_C1, dn_C2, dn_C3)
                int op_m = bear_chance ? opacityAlrt : opacityNorm
                [bl_m, br_m] = f_get_coords(lay_minus, p_start_bar, p_end_bar, mid_bar, math.max(1, math.round(max_w_bars * ratio_minus)))
                array.push(all_boxes, box.new(bl_m, b_top, br_m, b_bot, border_color=na, bgcolor=color.new(c_minus_base, op_m)))
                
                if show_val_lbl and ratio_minus >= txt_shw_rat
                    int x_m = lay_minus == opt_L ? br_m : (lay_minus == opt_R ? bl_m : br_m)
                    string align_m = lay_minus == opt_L ? label.style_label_left : (lay_minus == opt_R ? label.style_label_right : label.style_label_left)
                    array.push(all_labels, label.new(x_m, box_mid, f_format_k(val_minus), color=lbl_bg_col, textcolor=c_minus_base, size=txt_size, style=align_m))

            if ratio_adx >= noise_filter
                color c_adx_base = f_get_heatmap_color(ratio_adx, ax_C1, ax_C2, ax_C3)
                int op_a = is_adx_strong ? opacityAlrt : opacityNorm
                [bl_a, br_a] = f_get_coords(lay_adx, p_start_bar, p_end_bar, mid_bar, math.max(1, math.round(adx_w_bars * ratio_adx)))
                array.push(all_boxes, box.new(bl_a, b_top, br_a, b_bot, border_color=na, bgcolor=color.new(c_adx_base, op_a)))
                
                if show_val_lbl and ratio_adx >= txt_shw_rat
                    int x_a = lay_adx == opt_L ? br_a : (lay_adx == opt_R ? bl_a : br_a)
                    string align_a = lay_adx == opt_L ? label.style_label_left : (lay_adx == opt_R ? label.style_label_right : label.style_label_left)
                    array.push(all_labels, label.new(x_a, box_mid, f_format_k(val_adx), color=lbl_bg_col, textcolor=c_adx_base, size=txt_size, style=align_a))

            // POC Lines
            if show_poc_a and r == poc_adx_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=col_poc_a, style=f_sty(sty_poc_a), width=wid_poc_a))
            if show_poc_p and r == poc_plus_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=col_poc_p, style=f_sty(sty_poc_p), width=wid_poc_p))
            if show_poc_m and r == poc_minus_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=col_poc_m, style=f_sty(sty_poc_m), width=wid_poc_m))

        // VWAP & Fibonacci
        if show_vwap and not na(local_vwap)
            array.push(all_lines, line.new(p_start_bar, local_vwap, p_end_bar, local_vwap, color=col_vwap, style=f_sty(sty_vwap), width=wid_vwap))
            
            if show_fib
                float dist_up = s_high - local_vwap
                float dist_dn = local_vwap - s_low
                
                f_draw_fib(all_lines, f1_vl, f1_cl, f1_wd, f1_st, f1_on, local_vwap, dist_up, dist_dn, p_start_bar, p_end_bar, p)
                f_draw_fib(all_lines, f2_vl, f2_cl, f2_wd, f2_st, f2_on, local_vwap, dist_up, dist_dn, p_start_bar, p_end_bar, p)
                f_draw_fib(all_lines, f3_vl, f3_cl, f3_wd, f3_st, f3_on, local_vwap, dist_up, dist_dn, p_start_bar, p_end_bar, p)
````
