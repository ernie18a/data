# Pure Matrix Profile [TPO & Link]

- url: https://www.tradingview.com/script/mZR3epdW/
- type: indicator
- pine_id: PUB;34fd76f52f494e3f9009833ee00b933c
- version: 2.0

## Description

Pure Matrix Profile [TPO & Link]

Description:

This indicator is a highly visual, ASCII-based environment recognition tool designed to map market structure, liquidity, and momentum within specific sessions. It is NOT a standalone entry signal generator. Rather, it provides a deep situational awareness of "price wall thickness" (Volume) and "market heat" (RSI) to help traders build robust defensive and offensive strategies.

1. Pine Script Limitations & Memory Management

In Pine Script, there is an absolute limit of 500 historical objects (Boxes, Labels, Lines) per script to prevent system overload, regardless of your account tier (Basic, Pro, Premium).

• Remaining Quota: 0 (This script maximizes the 500 limit for detailed rendering).
• How it works: To bypass this limitation and maintain a beautiful UI without crashing, the script uses a professional garbage collection technique (barstate.islast). It deletes all previous objects and recalculates/redraws the entire matrix exclusively on the most recent bar, ensuring optimal performance within the limits.

2. Core Calculations & Output Values

The visual beauty of this tool is driven by strict mathematical logic.

A. Price Bin Resolution (vp_step)
vp_step = (top_y - bot_y) / row_count
• Why: To divide the session's high-low range into equal tiers to distribute volume accurately.
• Output: A float value representing the price width of a single text row.

B. Binning (Data Assignment)
bin_idx = Math.floor( (c_price - bot_y) / vp_step )
• Why: To determine exactly which vertical "box" (row) the volume belongs to.

C. Volume-Weighted RSI (Heat)
Avg_RSI = Sum(Current_RSI * Volume) / Sum(Volume)
• Why: This reveals the true momentum only where significant institutional money was traded.

D. Histogram Normalization (Bottom-Up Heights)
val = (chunk_vol / max_chunk_vol) * hist_height
• Why: To normalize raw volume into a fixed visual height constraint for the bottom ASCII histogram.

E. ASCII Texture Logic (Wall Hardness)
The "density" of the ASCII character changes dynamically based on the Avg_RSI:
• Overheated (Avg_RSI >= 60): Renders "█" (Full Block). Represents a "Hard Wall" with strong momentum.
• Neutral (Avg_RSI 40.1 - 59.9): Renders "▒" (Medium Shade). Represents stable consolidation.
• Freezing (Avg_RSI <= 40): Renders "░" (Light Shade). Represents a "Soft Wall" with weak momentum.

3. Pros (Merits)

• Visualizing "Hardness": By combining volume depth and RSI texture, you can intuitively differentiate between strong support/resistance zones (Hard Walls) and fragile ones (Soft Walls).
• Risk Management: Helps prevent trading directly into "Hard Walls" or getting trapped in low-liquidity vacuums.

4. Cons (Limitations)

• Not an Entry Strategy: Provides zero edge as a standalone trigger.
• Lagging Nature: Session profiles form after the price has moved.
• Visual Clutter: High row counts on small screens may cause text overlap.




Japanese Description

このインジケーターは、特定のセッション内における市場構造、流動性、モメンタムをマッピングするための、ASCIIベースの視覚的な環境認識ツールです。これは単体でエントリーシグナルを生成するものではありません。トレーダーが堅牢な戦略を構築できるよう、「価格の壁の分厚さ（出来高）」と「相場の熱（RSI）」の状況認識を提供します。

1. 描画制限とメモリ管理について

Pine Scriptには、システム負荷を防ぐため、アカウントランクに関わらず1スクリプトにつき描写オブジェクトの最大上限が「500個」に厳格に設定されています。

・ 現在の残量: 0個（精密な描画のため、この500個の枠を最大限使い切る設定にしています）。
・ 動作の仕組み: 高度なメモリ管理（barstate.islast）を行っています。最新のローソク足でのみ過去のオブジェクトを全削除し、必要な分だけを一気に再計算して描き直すことで、制限枠内で安定稼働させています。

2. コアとなる計算式と出力値の解剖

A. 価格帯をスライスする計算 (VP Step)
vp_step = (top_y - bot_y) / row_count
・ なぜこの計算なのか: セッションの高安値を指定した行数で均等に分割し、1行あたりの価格幅を決定するため。

B. ローソク足の格納先判定 (Binning)
bin_idx = Math.floor( (c_price - bot_y) / vp_step )
・ なぜこの計算なのか: 出来高を正しい価格帯（行）に割り当てるため。

C. 出来高加重RSI（熱量の算出）
Avg_RSI = Sum(Current_RSI * Volume) / Sum(Volume)
・ なぜこの計算なのか: 大口の取引（出来高）が集中した価格帯のモメンタムだけを抽出するため。

D. ボトムヒストグラムの高さ計算 (Normalization)
val = (chunk_vol / max_chunk_vol) * hist_height
・ なぜこの計算なのか: 出来高を、指定した最大の高さ（行数）に正規化して当てはめるため。

E. ASCIIテクスチャ・ロジック（壁の硬度）
Avg_RSIの値に基づいて、描画される文字の密度（硬さ）が3段階で変化します。
・ 加熱帯 (RSI 60以上): 「█」（フルブロック）を描画。モメンタムを伴う「硬い壁」を意味します。
・ 中立帯 (RSI 40.1 - 59.9): 「▒」（ミディアムシェード）を描画。安定した攻防が行われているゾーンです。
・ 冷却帯 (RSI 40以下): 「░」（ライトシェード）を描画。モメンタムが弱まっている「柔らかい壁」を意味します。

3. メリット（優位性）

・ 壁の硬度の視覚化: 出来高の厚みとRSIのテクスチャを組み合わせることで、突破困難な「硬い壁」と、崩れやすい「柔らかい壁」を直感的に判別できます。
・ 無駄な被弾の回避: 強力な壁への無謀な突撃を防ぐための強力な環境認識根拠となります。

4. デメリット（限界と注意点）

・ エントリー戦略にはならない: 本ツール単体ではエントリーの優位性は一切ありません。
・ 遅行指標の性質: プロファイルは価格が動いた「後」に形成されます。
・ 視覚的なノイズ: 低解像度の環境で行数を大きく設定しすぎるとテキストが重なります。

## Source Code

````pine
// © ALT_analyst_experimental
//@version=6
indicator("Pure Matrix Profile [TPO & Link]", overlay=true, max_polylines_count=100, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ==========================================
// 1. Configuration Parameters
// ==========================================
grp_sys   = " [ SYSTEM & PROFILE ] "
hud_title = input.string("[ MATRIX TPO ]", "System Name", group=grp_sys)
hud_size  = input.string(size.small, "Text Size", options=[size.tiny, size.small, size.normal, size.large], group=grp_sys)
row_count = input.int(35, "VP Horizontal Divisions (Resolution)", minval=1, maxval=100, group=grp_sys)
max_width = input.int(35, "Max Text Width (Columns)", minval=20, group=grp_sys)
show_hist = input.bool(true, "Show Background VP Histogram (Box)", group=grp_sys)
vp_width  = input.float(0.3, "VP Histogram Width Ratio (0.1~1.0)", step=0.1, group=grp_sys)
rsi_len   = input.int(14, "RSI Length", group=grp_sys)

grp_vol   = " [ BOTTOM VOLUME HISTOGRAM ] "
hist_height  = input.int(8, "Max Block Height (Rows)", minval=1, maxval=30, group=grp_vol)
hist_density = input.int(2, "Block Density (Bar Merge Count)", minval=1, maxval=20, group=grp_vol)
hist_offset  = input.float(1.0, "Y-Axis Offset (Distance downwards)", step=0.5, group=grp_vol)

grp_geo   = " [ SESSION TPO & LINK ] "
sess_tf   = input.timeframe("D", "Session Timeframe", group=grp_geo)
profile_count = input.int(3, "Session History Count (Max 5)", minval=1, maxval=5, group=grp_geo)
conn_mode = input.string("Connect POCs", "Session Linkage", options=["None", "Connect POCs", "Connect High/Low"], group=grp_geo)
pos_x     = input.int(10, "HUD X-Axis Offset", minval=-1000, maxval=1000, group=grp_geo)

grp_bg    = " [ HUD & SESSION BACKDROP ] "
show_bg      = input.bool(true, "Show HUD Background Panel", group=grp_bg)
bg_panel_col = input.color(color.new(#000000, 20), "HUD Background Color", group=grp_bg)
sess_bg_col  = input.color(color.new(color.white, 100), "Session Box Background Color", group=grp_bg)

grp_mad   = " [ TREND SETTINGS ] "
ema_len   = input.int(34, "EMA Length (Trend Filter)", group=grp_mad)
c_bull    = input.color(#56B4E9, "Bullish Color", group=grp_mad)
c_bear    = input.color(#E69F00, "Bearish Color", group=grp_mad)

// --- Modern Art 8-Color Palette ---
grp_pal   = " [ COLOR PALETTE ] "
col_0     = input.color(#FF007F, "Color 0 (Neon Pink / Overheated)", group=grp_pal)
col_1     = input.color(#00FFFF, "Color 1 (Cyan / Cooling)", group=grp_pal)
col_2     = input.color(#FFD700, "Color 2 (Gold / Neutral High)", group=grp_pal)
col_3     = input.color(#8A2BE2, "Color 3 (Blue Violet)", group=grp_pal)
col_4     = input.color(#FF4500, "Color 4 (Orange Red / Warning)", group=grp_pal)
col_5     = input.color(#39FF14, "Color 5 (Neon Green / Neutral Low)", group=grp_pal)
col_6     = input.color(#FF1493, "Color 6 (Deep Pink)", group=grp_pal)
col_7     = input.color(#00BFFF, "Color 7 (Deep Sky Blue / Freezing)", group=grp_pal)

var array<color> modern_palette = array.from(col_0, col_1, col_2, col_3, col_4, col_5, col_6, col_7)

// ==========================================
// 2. Internal Calculations & Trade Signals
// ==========================================
float current_rsi = ta.rsi(close, rsi_len)
float madrid_ema  = ta.ema(close, ema_len)
bool  is_bullish  = close >= madrid_ema
color sys_color   = is_bullish ? c_bull : c_bear

max_bars_back(time, 4000)
max_bars_back(high, 4000)
max_bars_back(low, 4000)
max_bars_back(close, 4000)
max_bars_back(volume, 4000)
max_bars_back(current_rsi, 4000)
max_bars_back(madrid_ema, 4000)

// ==========================================
// 3. Session History Tracking
// ==========================================
var array<int> sess_start = array.new<int>()

if timeframe.change(sess_tf)
    array.unshift(sess_start, bar_index)
    if array.size(sess_start) > 6 
        array.pop(sess_start)

// ==========================================
// 4. Memory Management
// ==========================================
var array<line>   geo_lines  = array.new<line>()
var array<box>      vp_boxes   = array.new<box>()
var array<label>    hud_labels = array.new<label>()

// ==========================================
// 5. Projection Processing (Executed on last bar)
// ==========================================
if barstate.islast
    // Clear historical objects
    while array.size(geo_lines) > 0
        line.delete(array.pop(geo_lines))
    while array.size(vp_boxes) > 0
        box.delete(array.pop(vp_boxes))
    while array.size(hud_labels) > 0
        label.delete(array.pop(hud_labels))

    array<float> link_poc_y = array.new<float>()
    array<int>   link_poc_x = array.new<int>()
    array<float> link_high_y = array.new<float>()
    array<int>   link_high_x = array.new<int>()
    array<float> link_low_y = array.new<float>()
    array<int>   link_low_x = array.new<int>()

    int valid_profiles = math.min(profile_count, array.size(sess_start))

    for p_idx = 0 to valid_profiles - 1
        int left_x  = array.get(sess_start, p_idx)
        int right_x = p_idx == 0 ? bar_index : array.get(sess_start, p_idx - 1) - 1
        
        if right_x > left_x
            float top_y = na
            float bot_y = na
            for i = math.max(0, bar_index - right_x) to math.min(bar_index, bar_index - left_x - 1)
                if not na(high[i])
                    top_y := na(top_y) ? high[i] : math.max(top_y, high[i])
                if not na(low[i])
                    bot_y := na(bot_y) ? low[i] : math.min(bot_y, low[i])

            if not na(top_y) and not na(bot_y) and top_y > bot_y
                int offset = bar_index - right_x
                bool local_bull = close[offset] >= madrid_ema[offset]
                color local_sys_col = local_bull ? c_bull : c_bear
                float vp_step = (top_y - bot_y) / row_count
                
                // VP Calculation
                float[] vol_bins = array.new_float(row_count, 0.0)
                float[] rsi_vol_bins = array.new_float(row_count, 0.0)
                if vp_step > 0
                    for i = math.max(0, bar_index - right_x) to math.min(bar_index, bar_index - left_x - 1)
                        float c_price = close[i]
                        if not na(c_price)
                            float c_vol = volume[i] > 0 ? volume[i] : 1.0
                            int bin_idx = math.max(0, math.min(row_count - 1, math.floor((c_price - bot_y) / vp_step)))
                            array.set(vol_bins, bin_idx, array.get(vol_bins, bin_idx) + c_vol)
                            array.set(rsi_vol_bins, bin_idx, array.get(rsi_vol_bins, bin_idx) + (current_rsi[i] * c_vol))

                float m_vol = math.max(1.0, array.max(vol_bins))
                int poc_idx = array.indexof(vol_bins, array.max(vol_bins))
                float poc_price = bot_y + (poc_idx * vp_step) + (vp_step / 2)
                int center_x = math.round((left_x + right_x) / 2)

                array.push(link_poc_y, poc_price)
                array.push(link_poc_x, center_x)
                array.push(link_high_y, top_y)
                array.push(link_high_x, center_x)
                array.push(link_low_y, bot_y)
                array.push(link_low_x, center_x)

                int max_vp_bars = math.max(5, math.round((right_x - left_x) * vp_width))
                
                // VP Histogram Background
                array.push(vp_boxes, box.new(left_x, top_y, right_x, bot_y, border_color=color.new(local_sys_col, 80), border_width=1, bgcolor=sess_bg_col))

                // ==========================================
                // [A] ASCII Projection (Profile Body)
                // ==========================================
                int base_x = left_x + pos_x
                float dynamic_offset = (top_y - bot_y) * 0.05
                
                if show_bg
                    float bg_right = base_x + (max_width * 0.8)
                    array.push(vp_boxes, box.new(base_x - 2, top_y + dynamic_offset * 3, math.round(bg_right), bot_y - dynamic_offset, border_color=na, bgcolor=bg_panel_col))

                string mode_txt = p_idx == 0 ? "CURRENT SESS" : "HISTORY -" + str.tostring(p_idx)
                string str_head = hud_title + " [" + mode_txt + "]\n======================================"
                array.push(hud_labels, label.new(base_x, top_y + dynamic_offset, str_head, color=color.new(color.white, 100), textcolor=local_sys_col, style=label.style_label_down, text_font_family=font.family_monospace, size=hud_size))

                for i = 0 to row_count - 1
                    float bin_vol = array.get(vol_bins, i)
                    float avg_rsi = bin_vol > 0 ? (array.get(rsi_vol_bins, i) / bin_vol) : 50.0
                    float bin_top = bot_y + (i * vp_step) + vp_step
                    float bin_bot = bot_y + (i * vp_step)
                    float center_y = bin_bot + (vp_step / 2)
                    
                    color modern_col = array.get(modern_palette, i % 8)
                    
                    if show_hist and bin_vol > 0
                        int bar_w = math.round((bin_vol / m_vol) * max_vp_bars)
                        color box_col = color.new(modern_col, i == poc_idx ? 20 : 60)
                        if i == poc_idx
                            array.push(geo_lines, line.new(left_x, center_y, right_x, center_y, color=modern_col, style=line.style_dotted, width=1))
                        array.push(vp_boxes, box.new(left_x, bin_top, left_x + bar_w, bin_bot, border_color=na, bgcolor=box_col))

                    int num_blocks = math.round((bin_vol / m_vol) * max_width)
                    string block_char = avg_rsi >= 60 ? "█" : (avg_rsi <= 40 ? "░" : "▒")
                    string price_str = (i == poc_idx ? "★" : " ") + str.tostring(bin_bot, format.mintick)
                    string blocks_str = num_blocks > 0 ? str.repeat(block_char, num_blocks) : ""
                    
                    array.push(hud_labels, label.new(base_x, center_y, price_str + "|" + blocks_str, color=color.new(color.white, 100), textcolor=modern_col, style=label.style_label_left, text_font_family=font.family_monospace, size=hud_size))

                // ==========================================
                // [B] Bottom-Up ASCII Volume Histogram
                // ==========================================
                float max_chunk_vol = 0.0
                for x = left_x to right_x by hist_density
                    int start_idx = bar_index - x
                    int end_idx = math.max(0, start_idx - hist_density + 1)
                    float tmp_vol = 0.0
                    for i = end_idx to start_idx
                        if i >= 0
                            tmp_vol += nz(volume[i])
                    max_chunk_vol := math.max(max_chunk_vol, tmp_vol)

                float baseline_y = bot_y - (top_y - bot_y) * 0.05 * hist_offset

                for x = left_x to right_x by hist_density
                    int start_idx = bar_index - x
                    int end_idx = math.max(0, start_idx - hist_density + 1)
                    float chunk_vol = 0.0
                    float chunk_rsi = 0.0
                    int valid_bars = 0
                    
                    for i = end_idx to start_idx
                        if i >= 0
                            chunk_vol += nz(volume[i])
                            chunk_rsi += nz(current_rsi[i])
                            valid_bars += 1
                            
                    if valid_bars > 0 and chunk_vol > 0
                        float avg_rsi = chunk_rsi / valid_bars
                        float val = max_chunk_vol > 0 ? (chunk_vol / max_chunk_vol) * hist_height : 0
                        int full_blocks = math.floor(val)
                        float remainder = val - full_blocks
                        
                        string vert_str = ""
                        if remainder >= 0.875
                            vert_str += "█"
                        else if remainder >= 0.75
                            vert_str += "▇"
                        else if remainder >= 0.625
                            vert_str += "▆"
                        else if remainder >= 0.5
                            vert_str += "▅"
                        else if remainder >= 0.375
                            vert_str += "▄"
                        else if remainder >= 0.25
                            vert_str += "▃"
                        else if remainder >= 0.125
                            vert_str += "▂"
                        else if full_blocks == 0
                            vert_str += " "
                            
                        if full_blocks > 0
                            for b = 1 to full_blocks
                                if vert_str != ""
                                    vert_str += "\n"
                                vert_str += "█"
                                
                        color hist_col = avg_rsi >= 70 ? array.get(modern_palette, 0) : 
                                         avg_rsi >= 60 ? array.get(modern_palette, 4) : 
                                         avg_rsi >= 50 ? array.get(modern_palette, 2) : 
                                         avg_rsi >= 40 ? array.get(modern_palette, 5) : 
                                         avg_rsi >= 30 ? array.get(modern_palette, 1) : 
                                                         array.get(modern_palette, 7)
                        
                        array.push(hud_labels, label.new(x, baseline_y, vert_str, color=color.new(color.white, 100), textcolor=hist_col, style=label.style_label_down, text_font_family=font.family_monospace, size=hud_size))

    // ==========================================
    // 6. Session Linkage Drawing
    // ==========================================
    if array.size(link_poc_x) > 1
        for i = 0 to array.size(link_poc_x) - 2
            if conn_mode == "Connect POCs"
                array.push(geo_lines, line.new(array.get(link_poc_x, i+1), array.get(link_poc_y, i+1), array.get(link_poc_x, i), array.get(link_poc_y, i), color=color.new(color.white, 30), width=1, style=line.style_solid))
            else if conn_mode == "Connect High/Low"
                array.push(geo_lines, line.new(array.get(link_high_x, i+1), array.get(link_high_y, i+1), array.get(link_high_x, i), array.get(link_high_y, i), color=color.new(c_bull, 30), width=1, style=line.style_solid))
                array.push(geo_lines, line.new(array.get(link_low_x, i+1), array.get(link_low_y, i+1), array.get(link_low_x, i), array.get(link_low_y, i), color=color.new(c_bear, 30), width=1, style=line.style_solid))
````
