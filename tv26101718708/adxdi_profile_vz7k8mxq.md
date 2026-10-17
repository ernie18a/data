# ADX/DI Profile

- url: https://www.tradingview.com/script/Vz7k8Mxq/
- type: indicator
- pine_id: PUB;3e309eb4eb4e4a2c9a9553b0b3311c89
- version: 2.0

## Description

[b]ADX/DI Profile[/b]

Hello everyone. Please excuse my English, as I am not a native speaker. I use translation tools, but I hope my passion for coding reaches you.
First of all, I want to express my deepest respect and gratitude to @LuxAlgo. Your incredibly creative scripts and stunning visual designs have always been a huge inspiration to my coding journey. Thank you!

[b][ Overview ][/b]
Usually, ADX and DMI are drawn at the bottom of the chart to show when a trend is strong. But I wanted to know where (at what price) the trend was the strongest.
This script creates a "Memory of Energy." It stacks the buying and selling power not by time, but by price levels (spatial distribution).

[b][ How it Calculates (The Logic) ][/b]
To keep it simple, imagine stacking toy blocks.

[b]1 Making Boxes:[/b] We take the highest and lowest price of a period and divide that space into equal rows.

[b]2 Storing Energy:[/b] If a candle passes through 5 rows, and the ADX/DI energy point at that time is 30, we share those points equally into those 5 rows (6 points per row).

[b]3 Drawing Blocks:[/b] We do this for all candles in the period. The price row with the highest total points gets the longest block on the chart.

[b][ How to Read the Chart ][/b]
[b]・Blue Walls (+DI):[/b] This is where strong buying energy is stored. When the price falls into a thick blue wall, it acts as a strong support.

[b]・Red/Purple Walls (-DI): [/b]This is where strong selling energy is stored. When the price rises into a thick red wall, it acts as a strong resistance.

[b]・ADX POC (Thick Dotted Line): [/b]This is the exact price where the trend energy exploded the most. The price often acts like a magnet here, or it becomes the starting point of a new trend.

[b]・Sub POC Lines (Thin Dotted Lines):[/b] When enabled in the settings, this draws lines at the extreme points where buying (+DI) and selling (-DI) energy were highest. These act as pinpoint bounce lines in localized battlegrounds.

[b][ Settings & Features ][/b]

[b]・Engine Mode[/b]
This indicator is equipped with two different calculation modes to support dual strategies.

[b]Fixed Steps (Real-time Entry):[/b] Draws fixed profiles for specific past sessions. Since the frame is locked, signals are confirmed without repainting, making it ideal for real-time entry decisions.

[b]Rolling Window (Context/Repaint): [/b]A dynamic profile that continuously calculates based on the most recent bars. It smoothly captures immediate energy shifts, making it perfect for observing the macro context of the market.

[b]Layout Mode[/b]
You can choose from 4 different profile drawing styles to fit your visual preference and trade plans.

[b]Butterfly (Center Axis):[/b] Spreads outwards from the center like butterfly wings. The most intuitive layout for grasping the balance between buyers and sellers.

[b]Left / Right Aligned:[/b] Anchored to the start or end of the period and extends in one direction. Similar to traditional volume profiles, providing classic views or reversed perspectives to help you discover new angles.
[image]url=https://www.tradingview.com/x/713ZPuuj/[/image]
[b]Mirror (Opposed):[/b] Places the +DI and -DI blocks facing each other. Highly effective for visualizing the direct conflict line between bulls and bears.
[image]url=https://www.tradingview.com/x/GlWc2kWT/[/image]
[b]Noise Filter[/b]
I believe that the simpler the chart, the clearer the essence of the market becomes. By increasing the Noise Filter value (e.g., from 0.0 to 0.15), weak and transparent energy blocks are automatically stripped away. This prevents information overload and leaves only the true, thick walls of the market, allowing for pure inspiration.

Enjoy the spatial view of the market!

ADX/DI Profile

皆さんこんにちは。私は英語のネイティブスピーカーではないため、至らない表現があるかもしれませんが、このスクリプトに込めた熱意が皆様に伝われば嬉しいです。
まず初めに、@LuxAlgo 氏へ最大限の敬意と感謝を捧げます。あなたの驚くべきスクリプトと洗練された視覚的デザインは、私のコーディングの旅において常に巨大なインスピレーションの源でした。本当にありがとうございます。

[ 概要 ]
通常、ADXやDMIはチャートの下部に表示され、「いつ」トレンドが強かったかを示します。しかし、私は「どの価格帯で」トレンドが最も強かったかを知りたいと考えました。
このスクリプトは「エネルギーの記憶」を描き出します。時間軸ではなく、価格帯（空間）ごとに買いと売りのパワーを積み上げ、可視化する全く新しいアプローチです。

[ 計算のロジック ]
ブロック遊びをイメージしてください。
箱を作る： 一定期間の最高値と最安値を取り、その空間を等間隔の行に分割します。

エネルギーを配分する： あるローソク足が5つの箱を通過し、その時のADX/DIのエネルギー値が「30」だった場合、通過した5つの箱に平等にポイントを配分します（各箱に6ポイント）。

ブロックを描画する： これを全期間のローソク足に対して行います。最終的に最も多くポイントが蓄積された価格帯に、最も長いブロックを描画します。

[ チャートの見方 ]
青い壁（+DI）： 過去に強い「買いエネルギー」が蓄積された場所です。価格が上から落ちてきた際、この分厚い壁は強力なサポートとして機能しやすくなります。

赤紫の壁（-DI）： 過去に強い「売りエネルギー」が蓄積された場所です。価格が下から上がってきた際、この分厚い壁は強力なレジスタンスとして立ちはだかります。

ADX POC（中央の太い点線）： トレンドの勢いが最も爆発したコアとなる価格帯です。価格はこのラインに磁石のように吸い寄せられるか、あるいはここを起点に新たなトレンドを生み出します。

サブPOCライン（細い点線）： 設定から表示をオンにすると、買い（+DI）と売り（-DI）のエネルギーがそれぞれ最も高かった極値のラインを描画します。局所的な激戦区のピンポイントな反発ラインとして機能します。

[ 設定機能の解説 ]
エンジンモード (Engine Mode)
リアルタイムのエントリー判断と、過去の相場分析を使い分けられるよう、2つのモードを搭載しています。
Fixed Steps (リアルタイムエントリー): 過去の特定の期間ごとにプロファイルを固定して描画します。枠が固定されるためシグナルが確定しやすく（リペイントせず）、実戦でのエントリー判断に最適です。

Rolling Window (環境認識): 最新の価格から常に一定期間を遡って計算し続ける動的なプロファイルです。直近のエネルギーシフトを滑らかに捉え、相場全体の文脈（コンテキスト）を俯瞰するのに適しています。

レイアウトモード (Layout Mode)
視覚的な好みやトレードプランに合わせて、4種類の描画スタイルを選択できます。
Butterfly（中央軸）: 中央から左右に蝶の羽を広げるように描画します。買いと売りのエネルギーバランスが最も直感的に把握できる設定です。

Left / Right Aligned（左・右揃え）: 期間の左端・右端を基準にして一方向へ伸ばします。従来の出来高プロファイルに近い配置と、その逆位置を提供することで、同じチャートから異なる視点や新たな発見を得ることをサポートします。

Mirror（左右反転）: 買いと売りのブロックを向かい合わせに配置します。ブル（買い手）とベア（売り手）の激しい衝突ラインを視覚化するのに最適です。

ノイズフィルター (Noise Filter)
私は、チャートはシンプルであるほど本質が見えてくると考えています。フィルターの数値を上げる（例：0.0から0.15へ）と、エネルギーの弱い透明なブロックが自動的に削ぎ落とされます。情報過多による脳の混乱を防ぎ、相場で本当に意識される「分厚い壁」だけを残すことで、新たなインスピレーションをもたらします。

空間的な市場分析をお楽しみください！

## Source Code

````pine
// © ALT_analyst_experimental
// Inspired by LuxAlgo Concepts
//@version=6
indicator("ADX/DI Profile", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ==========================================
// 1. Inputs
// ==========================================
grp_mode = " [ SYSTEM ] CALCULATION ENGINE"
calcMode = input.string("Fixed Steps (Real-time Entry)", "Engine Mode", options=["Rolling Window (Context/Repaint)", "Fixed Steps (Real-time Entry)"], group=grp_mode, tooltip="Rolling: Shifts with price. Fixed: Locks historical profiles for entry signals.")

grp_sess = " [ SYSTEM ] SESSION PARAMS"
prof_period = input.int(30, "Profile Period (Bars)", minval=5, group=grp_sess)
prof_num    = input.int(3, "Historical Sessions", minval=1, maxval=5, group=grp_sess, tooltip="Max sessions displayed.")
row_count   = input.int(24, "Resolution (Row Count)", minval=10, maxval=100, group=grp_sess)

grp_lay = " [ H.U.D ] LAYOUT & OPACITY"
layoutMode  = input.string("Mirror (Opposed)", "Layout Mode", options=["Butterfly (Center Axis)", "Left Aligned", "Right Aligned", "Mirror (Opposed)"], group=grp_lay)
widthPct    = input.float(0.45, "Max Width (Pct of Period)", minval=0.1, maxval=1.0, step=0.05, group=grp_lay)
midVolWidthPct = input.float(0.15, "Core Width (Pct of Period)", minval=0.05, maxval=0.5, step=0.05, group=grp_lay)
opacityNorm = input.int(55, "Normal Opacity (Pct)", minval=0, maxval=100, step=5, group=grp_lay)
opacityAlrt = input.int(20, "Chance Opacity (Pct)", minval=0, maxval=100, step=5, group=grp_lay)
opacityHud  = input.int(20, "HUD Opacity (Pct)", minval=0, maxval=100, step=5, group=grp_lay)

show_bg     = input.bool(true, "Show Profile Background", group=grp_lay)
bg_color    = input.color(color.new(color.blue, 90), "Background Color", group=grp_lay)
show_guide  = input.bool(true, "Show Color Guide", group=grp_lay)

grp_lbl = " [ LABELS ] TEXT BOX SETTINGS"
lbl_bg_col  = input.color(color.new(color.black, 20), "Label Box BG Color", group=grp_lbl)
lbl_txt_col = input.color(color.white, "Label Text Color", group=grp_lbl)
txt_size    = input.string(size.tiny, "Terminal Text Size", options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=grp_lbl)

grp_dmi = " [ ENGINE ] ALGORITHMIC DMI"
dmi_len      = input.int(14, "ADX/DI Length", minval=1, group=grp_dmi)
adx_thresh   = input.int(25, "ADX Threshold", group=grp_dmi)
noise_filter = input.float(0.08, "Noise Filter (0.0~1.0)", minval=0.0, step=0.02, group=grp_dmi) 
txt_shw_rat  = input.float(0.5, "Text Label Threshold", minval=0.1, maxval=1.0, step=0.1, group=grp_dmi)

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

grp_st = " [ STYLE ] POC LINES"
poc_show_di = input.bool(true, "Show +DI / -DI POC Lines", group=grp_st)
pocStyle    = input.string(line.style_dashed, "ADX POC Line Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=grp_st)
pocWidth    = input.int(2, "ADX POC Line Width", minval=1, maxval=5, group=grp_st)

// ==========================================
// 2. Data Calculation
// ==========================================
[di_plus, di_minus, adx_val] = ta.dmi(dmi_len, dmi_len)

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

// ==========================================
// 3. Drawing Engine
// ==========================================
var box[]   all_boxes  = array.new_box()
var line[]  all_lines  = array.new_line()
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

    
    int current_step = math.floor(bar_index / prof_period)

    for p = 0 to prof_num - 1
        int p_start_bar = 0
        int p_end_bar = 0
        
        if calcMode == "Rolling Window (Context/Repaint)"
            p_end_bar   := bar_index - (p * prof_period)
            p_start_bar := p_end_bar - prof_period + 1
        else
        
            int target_step = current_step - p
            p_start_bar := target_step * prof_period
            p_end_bar   := p == 0 ? bar_index : p_start_bar + prof_period - 1

        if p_start_bar < 0
            continue
            
        int mid_bar = math.round((p_start_bar + p_end_bar) / 2)
            
        int offset_end   = math.max(0, bar_index - p_end_bar)
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

        for offset = offset_end to offset_start
            float p_plus  = nz(di_plus[offset])
            float p_minus = nz(di_minus[offset])
            float c_adx   = nz(adx_val[offset])
            
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

        float max_plus  = array.max(row_plus_acc)
        float max_minus = array.max(row_minus_acc)
        float max_adx   = array.max(row_adx_acc)
        
        int poc_adx_idx   = array.indexof(row_adx_acc, max_adx)
        int poc_plus_idx  = array.indexof(row_plus_acc, max_plus)
        int poc_minus_idx = array.indexof(row_minus_acc, max_minus)
                
        max_plus  := max_plus <= 0 ? 1.0 : max_plus
        max_minus := max_minus <= 0 ? 1.0 : max_minus
        max_adx   := max_adx <= 0 ? 1.0 : max_adx

        int max_w_bars = math.round(prof_period * widthPct)
        int adx_w_bars = math.round(prof_period * midVolWidthPct)

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

            color c_plus_base  = f_get_heatmap_color(ratio_plus, up_C1, up_C2, up_C3)
            color c_minus_base = f_get_heatmap_color(ratio_minus, dn_C1, dn_C2, dn_C3)
            color c_adx_base   = f_get_heatmap_color(ratio_adx, ax_C1, ax_C2, ax_C3)

            int op_p = bull_chance ? opacityAlrt : opacityNorm
            int op_m = bear_chance ? opacityAlrt : opacityNorm
            int op_a = is_adx_strong ? opacityAlrt : opacityNorm

            int bl_p = 0, br_p = 0 
            int bl_m = 0, br_m = 0 
            int bl_a = 0, br_a = 0 
            int mid_l_lbl = 0 

            if layoutMode == "Butterfly (Center Axis)"
                br_p := mid_bar
                bl_p := mid_bar - math.max(1, math.round(max_w_bars * ratio_plus))
                mid_l_lbl := bl_p
                bl_m := mid_bar
                br_m := mid_bar + math.max(1, math.round(max_w_bars * ratio_minus))
                int aw = math.max(1, math.round(adx_w_bars * ratio_adx))
                bl_a := mid_bar - aw
                br_a := mid_bar + aw
            else if layoutMode == "Left Aligned"
                bl_p := p_start_bar
                br_p := p_start_bar + math.max(1, math.round(max_w_bars * ratio_plus))
                mid_l_lbl := br_p
                bl_m := p_start_bar
                br_m := p_start_bar + math.max(1, math.round(max_w_bars * ratio_minus))
                int aw = math.max(1, math.round(adx_w_bars * ratio_adx))
                bl_a := p_start_bar
                br_a := p_start_bar + aw
            else if layoutMode == "Right Aligned"
                br_p := p_end_bar
                bl_p := p_end_bar - math.max(1, math.round(max_w_bars * ratio_plus))
                mid_l_lbl := bl_p
                br_m := p_end_bar
                bl_m := p_end_bar - math.max(1, math.round(max_w_bars * ratio_minus))
                int aw = math.max(1, math.round(adx_w_bars * ratio_adx))
                br_a := p_end_bar
                bl_a := p_end_bar - aw
            else if layoutMode == "Mirror (Opposed)"
                bl_p := p_start_bar
                br_p := p_start_bar + math.max(1, math.round(max_w_bars * ratio_plus))
                mid_l_lbl := br_p
                br_m := p_end_bar
                bl_m := p_end_bar - math.max(1, math.round(max_w_bars * ratio_minus))
                int aw = math.max(1, math.round(adx_w_bars * ratio_adx))
                bl_a := p_start_bar
                br_a := p_start_bar + aw

            if ratio_plus >= noise_filter
                array.push(all_boxes, box.new(bl_p, b_top, br_p, b_bot, border_color=na, bgcolor=color.new(c_plus_base, op_p)))
                if ratio_plus >= txt_shw_rat
                    string txt = str.tostring(val_plus, "#.#")
                    array.push(all_labels, label.new(mid_l_lbl, box_mid, txt, color=lbl_bg_col, textcolor=lbl_txt_col, size=txt_size, style=label.style_label_center))

            if ratio_minus >= noise_filter
                array.push(all_boxes, box.new(bl_m, b_top, br_m, b_bot, border_color=na, bgcolor=color.new(c_minus_base, op_m)))
                if ratio_minus >= txt_shw_rat
                    string txt = str.tostring(val_minus, "#.#")
                    int x_lbl = (layoutMode == "Butterfly (Center Axis)" or layoutMode == "Mirror (Opposed)") ? bl_m : (layoutMode == "Right Aligned" ? bl_m : br_m)
                    array.push(all_labels, label.new(x_lbl, box_mid, txt, color=lbl_bg_col, textcolor=lbl_txt_col, size=txt_size, style=label.style_label_center))

            if ratio_adx >= noise_filter
                array.push(all_boxes, box.new(bl_a, b_top, br_a, b_bot, border_color=na, bgcolor=color.new(c_adx_base, op_a)))
                if r == poc_adx_idx
                    array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=color.new(ax_C3, 20), style=pocStyle, width=pocWidth))

            if poc_show_di
                if r == poc_plus_idx
                    array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=color.new(up_C3, 30), style=line.style_dotted, width=1))
                if r == poc_minus_idx
                    array.push(all_lines, line.new(p_start_bar, box_mid, p_end_bar, box_mid, color=color.new(dn_C3, 30), style=line.style_dotted, width=1))

// ==========================================
// 4. Signboard
// ==========================================
var table legend = table.new(position.top_right, 3, 4, border_width=1, border_color=color.new(color.gray, opacityHud), frame_color=color.new(color.gray, opacityHud), frame_width=2)

if barstate.islast 
    if show_guide
        color pCold = color.new(up_C1, opacityHud)
        color pHot  = color.new(up_C3, 0)
        color mCold = color.new(dn_C1, opacityHud)
        color mHot  = color.new(dn_C3, 0)
        color aCold = color.new(ax_C1, opacityHud)
        color aHot  = color.new(ax_C3, 0)

        table.cell(legend, 0, 0, "STRUCTURAL", bgcolor=color.new(chart.bg_color, opacityHud), text_color=color.gray, text_size=size.small, text_halign=text.align_center)
        table.merge_cells(legend, 0, 0, 2, 0)
        
        table.cell(legend, 0, 1, "+DI (Cold Noise)", bgcolor=pCold, text_color=pCold, text_size=size.tiny)
        table.cell(legend, 1, 1, "◄ BUYY Flow ►", bgcolor=color.new(up_C2, opacityHud), text_color=color.white, text_size=size.tiny)
        table.cell(legend, 2, 1, "+DI (Hot Chance)", bgcolor=pHot, text_color=pHot, text_size=size.tiny)
        
        table.cell(legend, 0, 2, "-DI (Cold Noise)", bgcolor=mCold, text_color=mCold, text_size=size.tiny)
        table.cell(legend, 1, 2, "◄ SELL Flow ►", bgcolor=color.new(dn_C2, opacityHud), text_color=color.white, text_size=size.tiny)
        table.cell(legend, 2, 2, "-DI (Hot Chance)", bgcolor=mHot, text_color=mHot, text_size=size.tiny)
        
        table.cell(legend, 0, 3, "ADX (Noise)", bgcolor=aCold, text_color=aCold, text_size=size.tiny)
        table.cell(legend, 1, 3, "◄ CORE ADX ►", bgcolor=color.new(ax_C2, opacityHud), text_color=color.black, text_size=size.tiny)
        table.cell(legend, 2, 3, "ADX (Hot Core)", bgcolor=aHot, text_color=aHot, text_size=size.tiny)
    else
        table.clear(legend, 0, 0, 2, 3)
````
