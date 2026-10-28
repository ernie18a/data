# RSI Footprint Profile

- url: https://www.tradingview.com/script/a4OMe15p/
- type: indicator
- pine_id: PUB;91779985db1f4c23a3008ce6732e414c
- version: 6.0

## Description

・Overview

The RSI Footprint Profile is a refined order flow visualization tool designed for absolute clarity. It integrates price-level volume distribution with volume-weighted RSI, filtering out market noise to focus strictly on the most critical area of any session: the Point of Control (POC).

・Key Features
[image]https://www.tradingview.com/x/878Q7flG/[/image]
Volume-Weighted RSI Coloring
Each price node is colored based on the internal momentum of the volume traded at that level. Red indicates an overbought state (OB), blue indicates an oversold state (OS), and gray represents neutral volume.

・Exclusive POC Extension
[image]https://www.tradingview.com/x/FRhU01Jt/[/image]
To eliminate false signals from low-volume price extremes, the forward-looking extension line is strictly limited to the Point of Control (POC). If the session's thickest volume node aligns with an extreme RSI state, it extends to the right, creating an institutional-grade future support or resistance line.

・Stealth UI & Dynamic Highlighting

Built with a "less is more" philosophy. The profile remains semi-transparent so your candlesticks are never obstructed. It aggressively highlights only the POC and the Current Price Zone, providing precise Total Volume and Delta metrics exactly where you need them.

・How to Use

Setup: This indicator calculates footprint data using a lower timeframe (LTF). Ensure your specified LTF (default: 5m) is shorter than your current chart's timeframe.
Performance: The drawing engine is optimized to render from the oldest session to the newest. This ensures that TradingView's drawing limits will never erase your most critical recent data.

Author's Note (Please Read)
I am a Japanese developer and not a native English speaker. Please understand that it may take some time for me to reply to your comments, and there might be slight nuances lost in translation. However, I will read every message and reply sincerely. Thank you for your understanding and support!

[Japanese]

概要

RSI Footprint Profileは、圧倒的な視認性を追求して洗練されたオーダーフロー可視化ツールです。価格帯別出来高と出来高加重RSIを統合し、市場のノイズを排除して、セッション内で最も重要な領域である「POC（最大出来高帯）」に焦点を絞ります。

主要機能

出来高加重RSIによる色分け
各価格帯は、そこで取引された出来高の内部モメンタムに基づいて色分けされます。赤は買われすぎ（OB）、青は売られすぎ（OS）、グレーは中立な状態を示します。

POC限定の防衛線延長

出来高が薄い価格帯でのフェイクシグナルを排除するため、未来への延長線は「POC（Point of Control）」のみに厳格に制限されています。セッションで最も分厚い壁（POC）が極端なRSI状態と重なった場合、そのラインが右側に延長され、将来の強力なサポート/レジスタンスとして機能します。

ステルスUIと動的ハイライト

「少ないほど豊かである」という哲学で設計されています。プロファイルは半透明を維持し、ローソク足を決して邪魔しません。POCと現在地の価格帯のみに枠線を付け、正確な総出来高とデルタの数値を表示します。

使用上の注意

設定: 内部計算に下位足（LTF）を使用します。設定したLTF（デフォルト5分）が、現在のチャートの時間足よりも短いことを確認してください。
パフォーマンス: TradingViewの描画制限によって最新のデータが消去されるのを防ぐため、過去のセッションから順に描画を上書きするようエンジンが最適化されています。

開発者よりお知らせ
私は英語のネイティブスピーカーではないため、海外の方からのコメントへの返信にお時間をいただいたり、翻訳によるニュアンスの違いが生じる場合がございます。いただいたメッセージには真摯に対応させていただきますので、あらかじめご了承いただけますと幸いです。

## Source Code

````pine
// © ALT_analyst (RSI Footprint Profile - Anchored Box Edition v2.1.2 Lite)
//@version=6
indicator("RSI Footprint Profile V2.1.2 Lite", overlay=true, max_lines_count=500, max_labels_count=100, max_bars_back=5000)

// ==========================================
// 1. Settings
// ==========================================
grp_tf = " Timeframe & Session Settings"
box_bars    = input.int(20, "Box Drawing Period (Bars)", minval=1, group=grp_tf, tooltip="Number of bars for box boundaries.")
prof_num    = input.int(3, "Number of Historical Boxes", minval=1, maxval=20, group=grp_tf)
row_count   = input.int(24, "Price Row Count", minval=10, maxval=100, group=grp_tf)

grp_rsi = " RSI Anomaly Settings"
rsi_len     = input.int(14, "RSI Length", minval=1, group=grp_rsi)
rsi_ob      = input.int(70, "Overbought (OB) Level", group=grp_rsi)
rsi_os      = input.int(30, "Oversold (OS) Level", group=grp_rsi)

color_ob      = input.color(color.red, "Overbought (OB) Color", group=grp_rsi)
color_os      = input.color(color.blue, "Oversold (OS) Color", group=grp_rsi)
color_neutral = input.color(color.gray, "Neutral Color", group=grp_rsi)

grp_ext = " Drawing Extension Settings"
extend_poc  = input.bool(true, "Extend POC Line", group=grp_ext) 
extend_ob   = input.bool(true, "Extend Overbought (OB) Block", group=grp_ext)
extend_os   = input.bool(true, "Extend Oversold (OS) Block", group=grp_ext)
extend_bars = input.int(10, "Extension Distance (Bars)", minval=1, group=grp_ext)
txt_color   = input.color(color.white, "Text Color", group=grp_ext)
txt_size    = input.string(size.tiny, "Text Size", options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=grp_ext)

// ==========================================
// 2. Data Calculation
// ==========================================
rsi_val = ta.rsi(close, rsi_len)

// Simple Buy/Sell classification based on current timeframe
float bar_buy_vol = 0.0
float bar_sell_vol = 0.0

if close > open
    bar_buy_vol := nz(volume)
else if close < open
    bar_sell_vol := nz(volume)
else
    bar_buy_vol := nz(volume) * 0.5
    bar_sell_vol := nz(volume) * 0.5

// ==========================================
// 3. Drawing Engine (V1 Mode Core Only)
// ==========================================
var line[]     all_lines     = array.new_line()
var linefill[] all_fills     = array.new_linefill()
var label[]    all_labels    = array.new_label()

if barstate.islast
    // Delete existing objects
    if array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
    if array.size(all_labels) > 0
        for i = 0 to array.size(all_labels) - 1
            label.delete(array.get(all_labels, i))
            
    array.clear(all_lines)
    array.clear(all_fills)
    array.clear(all_labels)

    for p = prof_num - 1 to 0
        int p_start_bar = bar_index - (bar_index % box_bars) - (p * box_bars)
        int p_end_bar   = p_start_bar + box_bars - 1
        
        if p_start_bar < 0
            continue
            
        int lb_start = math.max(0, bar_index - p_end_bar)
        int lb_end   = bar_index - p_start_bar
        
        float s_high = high[lb_start]
        float s_low  = low[lb_start]
        
        for i = lb_start to lb_end
            if i >= bar_index
                break
            s_high := math.max(s_high, high[i])
            s_low  := math.min(s_low, low[i])
                
        if na(s_high) or na(s_low) or s_high == s_low
            continue
            
        float step_price = (s_high - s_low) / row_count
        
        float[] row_buy_vols  = array.new_float(row_count, 0.0)
        float[] row_sell_vols = array.new_float(row_count, 0.0)
        float[] row_rsi_acc   = array.new_float(row_count, 0.0)

        for i = lb_start to lb_end
            if i >= bar_index
                break
                
            float b_buy  = bar_buy_vol[i]
            float b_sell = bar_sell_vol[i]
            float b_rsi  = nz(rsi_val[i], 50) 
            
            int start_row = math.floor((low[i] - s_low) / step_price)
            int end_row   = math.floor((high[i] - s_low) / step_price)
            
            start_row := math.max(0, math.min(start_row, row_count - 1))
            end_row   := math.max(0, math.min(end_row, row_count - 1))
            
            int rows_touched = (end_row - start_row) + 1
            float vol_per_row = (b_buy + b_sell) / rows_touched
            
            for r = start_row to end_row
                array.set(row_buy_vols, r, array.get(row_buy_vols, r) + (b_buy / rows_touched))
                array.set(row_sell_vols, r, array.get(row_sell_vols, r) + (b_sell / rows_touched))
                array.set(row_rsi_acc, r, array.get(row_rsi_acc, r) + (b_rsi * vol_per_row))

        float max_total_vol = 0.0
        int poc_row_idx = 0
        
        for r = 0 to row_count - 1
            float t_vol = array.get(row_buy_vols, r) + array.get(row_sell_vols, r)
            if t_vol > max_total_vol
                max_total_vol := t_vol
                poc_row_idx := r
                
        if max_total_vol <= 0
            max_total_vol := 1.0

        for r = 0 to row_count - 1
            float t_vol = array.get(row_buy_vols, r) + array.get(row_sell_vols, r)
            float delta = array.get(row_buy_vols, r) - array.get(row_sell_vols, r)
            
            if t_vol > 0
                float avg_rsi = array.get(row_rsi_acc, r) / t_vol
                float b_bot = s_low + (r * step_price)
                float b_top = s_low + ((r + 1) * step_price)
                
                bool is_now = p == 0 and (close >= b_bot and close <= b_top)
                bool is_poc = r == poc_row_idx
                int b_end = p_start_bar + math.max(1, math.round((box_bars - 1) * (t_vol / max_total_vol)))
                
                bool is_ob = avg_rsi >= rsi_ob
                bool is_os = avg_rsi <= rsi_os
                bool is_colored = (is_ob or is_os)
                
                bool should_extend = (is_poc and extend_poc) or (is_ob and extend_ob) or (is_os and extend_os)
                if should_extend
                    b_end += extend_bars
                
                color base_c = is_ob ? color_ob : (is_os ? color_os : color_neutral)
                color bg_c = color.new(base_c, is_colored ? 50 : 85)
                
                line l1 = line.new(p_start_bar, b_top, b_end, b_top, color=na)
                line l2 = line.new(p_start_bar, b_bot, b_end, b_bot, color=na)
                
                array.push(all_lines, l1)
                array.push(all_lines, l2)
                array.push(all_fills, linefill.new(l1, l2, bg_c))
                
                if is_now or is_poc
                    color brd_c = is_now ? color.fuchsia : color.yellow
                    
                    line.set_color(l1, brd_c)
                    line.set_color(l2, brd_c)
                    line.set_width(l1, is_now ? 2 : 1)
                    line.set_width(l2, is_now ? 2 : 1)
                    
                    line l3 = line.new(p_start_bar, b_top, p_start_bar, b_bot, color=brd_c, width=is_now ? 2 : 1)
                    line l4 = line.new(b_end, b_top, b_end, b_bot, color=brd_c, width=is_now ? 2 : 1)
                    
                    array.push(all_lines, l3)
                    array.push(all_lines, l4)
                    
                    string v_s = t_vol >= 1e6 ? str.tostring(t_vol/1e6, "#.##")+"M" : (t_vol >= 1e3 ? str.tostring(t_vol/1e3, "#.##")+"K" : str.tostring(t_vol, "#"))
                    string d_s = delta >= 1e6 ? str.tostring(delta/1e6, "#.##")+"M" : (math.abs(delta) >= 1e3 ? str.tostring(delta/1e3, "#.##")+"K" : str.tostring(delta, "#"))
                    
                    string txt = (is_poc and is_now ? "POC & NOW\n" : (is_poc ? "POC\n" : "NOW\n")) + "Vol: " + v_s + " (Δ" + (delta>0?"+":"") + d_s + ") RSI: " + str.tostring(avg_rsi, "#.#")
                    
                    array.push(all_labels, label.new(p_start_bar, b_top, txt, color=color.new(color.black, 100), textcolor=txt_color, size=txt_size, style=label.style_label_down))

// ==========================================
// 4. Signboard
// ==========================================
var table rsi_legend = table.new(position.top_right, 1, 3, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(rsi_legend, 0, 0, "RSI Alert", bgcolor=color.new(color.black, 40), text_color=color.white, text_size=size.small)
    table.cell(rsi_legend, 0, 1, "OB > 70", bgcolor=color.new(color_ob, 50), text_color=color.white, text_size=size.small)
    table.cell(rsi_legend, 0, 2, "OS < 30", bgcolor=color.new(color_os, 50), text_color=color.white, text_size=size.small)
````
