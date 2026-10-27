# Institutional Momentum & Liquidity Matrix

- url: https://www.tradingview.com/script/23nb8iDt/
- type: indicator
- pine_id: PUB;70503202fdc640a79b0475e93b693677
- version: 4.0

## Description

[b]Institutional Momentum & Liquidity Matrix[/b]

[b]■Overview[/b]
This tool is a quantitative analysis suite designed to bridge the gap between price momentum and market liquidity structure. Moving away from the traditional approach of monitoring "where the RSI is currently," it calculates the exact price required for the RSI to reach overbought/oversold levels on the next candle and visualizes it directly on the chart. This projection is overlaid with an RSI-Anomaly Volume Profile to highlight true structural exhaustion.

[b]■1. Originality and Design Philosophy[/b]
While RSI and Volume Profile are widely used, they are typically viewed in isolation, leading to false signals. This script is original because it mathematically merges them:
1. It projects the theoretical elastic limits of momentum directly onto the price scale using algebraic reversal of Wilder's Smoothing.
[pine]// Algebraic Reversal of Wilder's Smoothing (RMA)
f_get_reverse_price(target_rsi) =>
    float target_rs = target_rsi / (100.0 - target_rsi)
    float req_up   = (target_rs * prev_rma_d * (rsi_len - 1)) - (prev_rma_u * (rsi_len - 1))
    float req_down = (prev_rma_u * (rsi_len - 1) / target_rs) - (prev_rma_d * (rsi_len - 1))
    float rev_price = req_up > 0 ? prev_c + req_up : (req_down > 0 ? prev_c - req_down : prev_c)
    rev_price[/pine]
2. It filters a Lower Timeframe (LTF) Volume Profile using LTF RSI data, discarding neutral volume and coloring only the specific price nodes where momentum reached extreme anomalies.
[pine]// RSI Anomaly Matrix & Peak Retention Logic
bool is_significant = (intensity * 100.0) >= vol_threshold

color base_c = color_prof_neutral
if is_significant
    if rsi_color_mode == "Peak Retention"
        if max_rsi >= rsi_ob and min_rsi <= rsi_os
            base_c := (max_rsi - 50.0) > (50.0 - min_rsi) ? color_ob : color_os
        else if max_rsi >= rsi_ob
            base_c := color_ob
        else if min_rsi <= rsi_os
            base_c := color_os[/pine]

[b]■2. Core Mechanism 1: Reverse RSI Projection (The Math)[/b]
Instead of tracking an oscillator bounded between 0 and 100, this script mathematically reverses J. Welles Wilder Jr.'s Smoothed Moving Average (RMA) formula. 
[image]https://www.tradingview.com/x/mKpjX944/[/image]
To calculate the exact closing price required on the next bar to achieve a specific Target RSI (e.g., 70 or 30), the script uses the following logic:
[b]RS = Target_RSI / (100 - Target_RSI)
Required_Up =
 (RS * Prev_RMA_D * (Length - 1)) - (Prev_RMA_U * (Length - 1))
Required_Down =
 (Prev_RMA_U * (Length - 1) / RS) - (Prev_RMA_D * (Length - 1))[/b]

It plots these calculated prices as horizontal projection lines, allowing traders to evaluate momentum limits directly on the price action.

[b]■3. Core Mechanism 2: RSI Anomaly Liquidity Matrix[/b]
Momentum limits require structural backing to be reliable. This engine aggregates LTF data to generate a filtered Volume Profile.
・Dynamic Sessions: Generates profiles based on Daily, Weekly, Monthly, or Custom Market Sessions (Defaults are set to UTC for Oceania, Asia, London, and NY).
・RSI Anomaly Coloring: Instead of plotting standard volume, the script calculates the average LTF RSI for each price node. It only applies color to nodes where the average momentum reached extreme Overbought or Oversold levels, keeping the rest of the profile neutral. This eliminates visual noise and isolates true areas of structural exhaustion.
・Point of Control (POC): Automatically extracts and highlights the price level with the highest liquidity concentration.

[b]■4. Configuration & Parameters[/b]
・Profile Generation Mode: Determines time boundaries. Day traders can use Custom Sessions (UTC), while swing traders benefit from Daily/Weekly structures.
・Liquidity Data Source: While 'Volume' is the standard input, 'Price Delta' is provided as a proxy to ensure the profile functions on assets lacking raw volume data (e.g., certain Forex feeds).
・Max LTF Samples per Bar: Limits how many LTF candles are processed per higher timeframe candle to optimize performance and prevent calculation limits.
・RSI Coloring Mode: Controls sensitivity. "Volume-Weighted Average" is mathematically strict but colors may neutralize over time. "Peak Retention" ensures that if a price node hits an RSI extreme at any point during the session, it permanently retains that warning color, preventing dilution. 

[image]https://www.tradingview.com/x/yLbREeyX/[/image]

[image]https://www.tradingview.com/x/FAhci1Wx/[/image]

・Significance Threshold & Hide Weak Nodes: Filters out price nodes that lack sufficient volume (e.g., under 30% of the POC volume). Graying out or hiding low-volume nodes removes noise.
・POC Proximity Filter: Fades the RSI projection lines if no historical POC is nearby, utilizing ATR to define a dynamic "safe zone." Momentum extremes without structural support are prone to false breakouts.

[b]■5. Usage & Mindset[/b]
・Best Suited For: High-liquidity instruments (Major Forex, Indices, Large-cap Crypto) on 15M to 1H charts.
・Execution: Do not enter blindly when price hits the RSI projection line. Wait for confluence: "Is this momentum extreme backed by a colored, structural POC wall?" Use the confluence zone to define strict Stop Loss levels.

[b]■Disclaimer[/b]
This script is a quantitative analysis tool designed for educational purposes to visualize mathematical momentum and liquidity data. It does not guarantee future profits and is not intended as a signal service. Always employ strict risk management and conduct comprehensive market analysis.



[b][日本語訳 / Japanese Translation]

Institutional Momentum & Liquidity Matrix

概要[/b]
本ツールは、価格モメンタムと市場流動性の構造的差異を統合的に分析するための定量分析スイートです。「RSIの現在値」に依存するアプローチから脱却し、「特定のRSI水準に到達するために必要な要請価格」を逆算してチャート上に直接可視化します。さらに、RSI異常値を反映した流動性マトリックスを展開し、構造的な枯渇点を浮き彫りにします。

[b]1. 独創性と設計思想[/b]
RSIと出来高プロファイルは広く普及していますが、単体での使用はダマシを誘発します。本スクリプトはこれらを数学的に統合した点に独創性があります。
1. Wilderの平滑化移動平均（RMA）を代数的に逆算し、モメンタムの限界値を価格スケール上に直接投影します。
2. 下位足（LTF）の出来高プロファイルをLTFのRSIデータでフィルタリングし、極端な異常値（過熱感）を記録した価格帯のみを色付けして視覚化します。

[b]2. コア・メカニズム1: 逆算RSIプロジェクション（計算根拠）[/b]
オシレーターを監視するのではなく、RMAの計算式を逆算します。次期のローソク足で指定のRSI極値（例: 70または30）に到達するための終値を、以下のロジックで算出します。
[b]RS = 目標RSI / (100 - 目標RSI)
必要な上昇幅 = 
(RS * 前回のRMA下落幅 * (期間 - 1)) - (前回のRMA上昇幅 * (期間 - 1))
必要な下落幅 = 
(前回のRMA上昇幅 * (期間 - 1) / RS) - (前回のRMA下落幅 * (期間 - 1))[/b]

算出された価格を水平線として描画し、価格アクション上でモメンタムの限界を評価可能にします。

[b]3. コア・メカニズム2: RSI異常値・流動性マトリックス[/b]
LTFデータを集計し、高度なフィルターを備えた価格帯別出来高を生成します。
・動的セッション: 日次、週次、月次、または特定の市場セッションに対応（※セッション時間はすべてUTC基準です）。
・RSI異常値カラーリング: 各価格帯の平均LTF RSIを算出し、買われすぎ/売られすぎの極限領域に達した価格帯のみを色付けします。通常の価格帯をニュートラルカラーに保つことで視覚的ノイズを排除します。
・Point of Control (POC): 最大流動性が集中する価格帯を自動抽出し、強力なレジサポとしてハイライトします。

[b]4. パラメーター設定[/b]
・Generation Mode (生成モード): デイトレーダーには特定の市場セッションが、スイングトレーダーには日次・週次の構造が適しています。
・Liquidity Data Source (流動性データ): 「出来高」を基本としますが、出来高データがない銘柄（一部のFX等）でも機能するよう、「価格変動幅（Price Delta）」を選択可能です。
・Max LTF Samples per Bar (最大LTF参照数): 上位足1本に対して参照する下位足の本数を制限し、計算処理を最適化します。
・RSI Coloring Mode (カラーリング感度・保持): プロファイルの色付け基準を選択します。「出来高加重平均 (Volume-Weighted)」は厳格ですが、その後の通常取引によって色が中和される性質があります。「ピーク保持 (Peak Retention)」を選択すると、セッション中に一度でもRSI異常値を記録した価格帯は、その極値カラーを履歴として保持し続けます（高感度モード）。
・Significance Threshold (有意性閾値): POCに対して一定割合に満たない価格帯をグレーアウトまたは非表示にし、真の壁のみを残します。
・POC Proximity Filter (近接フィルター): 過去のPOCが近くにない場合、プロジェクションラインをフェードアウトさせます。構造的な支持を持たない極値はダマシになりやすいため、ATRを利用したリスク管理レイヤーとして機能します。

[b]5. 使い方と環境[/b]
・得意な環境: 流動性の高いメジャー通貨ペア、主要株価指数、大型暗号資産の15分足〜1時間足。
・思考プロセス: 価格がRSIプロジェクションに到達したからといって盲目的にエントリーせず、「その極値の背後に、色付けされたPOCの壁が存在するか」を確認してください。コンフルエンス領域を基準に、厳格な損切りを設定してください。

[b]免責事項[/b]
本スクリプトは、数学的モメンタムおよび流動性データを可視化し、市場構造の理解を深めるための教育用ツールです。将来の利益を保証するものではなく、シグナル配信ツールではありません。常に適切なリスク管理と独自の市場分析を行ってください。

## Source Code

````pine
// © ALT_analyst
//@version=6
indicator("Institutional Momentum & Liquidity Matrix", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

// ==========================================
// 1. Configuration & Parameters
// ==========================================
grp_mode     = "Profile Configuration"
prof_mode    = input.string("Daily", "Profile Generation Mode", options=["Daily", "Weekly", "Monthly", "Custom Sessions"], group=grp_mode)
prof_num     = input.int(3, "Historical Profile Count", minval=1, maxval=20, group=grp_mode)
active_sess  = input.string("NY Session", "Target Custom Session", options=["Oceania Session", "Asia Session", "London Session", "NY Session"], group=grp_mode)
sess_tz      = input.string("UTC", "Timezone Offset", group=grp_mode, tooltip="All sessions are strictly based on UTC (GMT).")
sess_oceania = input.session("2200-0600", "Oceania Hours (UTC)", group=grp_mode)
sess_asia    = input.session("0000-0900", "Asia Hours (UTC)", group=grp_mode)
sess_london  = input.session("0800-1700", "London Hours (UTC)", group=grp_mode)
sess_ny      = input.session("1300-2200", "NY Hours (UTC)", group=grp_mode)

grp_ltf      = "Lower Timeframe (LTF) Engine"
fp_source    = input.string("Volume", "Liquidity Data Source", options=["Volume", "Price Delta"], group=grp_ltf, tooltip="Volume: Base exchange volume\nPrice Delta: Absolute price change (Proxy for assets without volume data)")
ltf_res      = input.timeframe("5", "LTF Resolution", group=grp_ltf)
ltf_max      = input.int(0, "Max LTF Samples per Bar (0 = All)", minval=0, group=grp_ltf)

grp_prof     = "Profile Aesthetics & Filters"
row_count    = input.int(24, "Price Matrix Resolution", minval=10, maxval=100, group=grp_prof)
fill_opacity = input.int(60, "Profile Fill Opacity (0-100%)", minval=0, maxval=100, group=grp_prof)
hide_weak    = input.bool(true, "Hide Weak Nodes Entirely", group=grp_prof)
vol_threshold= input.float(30.0, "Significance Threshold (% of POC)", minval=0.0, maxval=100.0, group=grp_prof)
color_prof_neutral = input.color(color.new(color.gray, 0), "Neutral Node Color", group=grp_prof)
color_prof_poc   = input.color(color.new(color.yellow, 0), "POC Highlight Color", group=grp_prof)

grp_rsi      = "Reverse RSI Projection & Profiling"
rsi_color_mode= input.string("Peak Retention", "RSI Coloring Mode", options=["Peak Retention", "Volume-Weighted Average"], group=grp_rsi, tooltip="Peak Retention: 一度でも極値に達した価格帯の色を保持します（高感度）。\nVolume-Weighted Average: 出来高加重平均で厳密に判定します（低感度・色が中和されやすい）。")
vw_mult      = input.float(0.6, "VWAP RSI Sensitivity (Compression)", minval=0.1, maxval=1.0, step=0.1, group=grp_rsi, tooltip="出来高加重平均モード時のRSI閾値の圧縮率です。0.6の場合、中心(50)から極値までの距離を60%に縮小して感度を上げます。")
rsi_len      = input.int(14, "RSI Period", minval=1, group=grp_rsi)
rsi_ob       = input.int(70, "Overbought (OB) Threshold", group=grp_rsi)
rsi_os       = input.int(30, "Oversold (OS) Threshold", group=grp_rsi)
color_ob     = input.color(#ff1744, "OB Projection & Node Color", group=grp_rsi)
color_os     = input.color(#00e676, "OS Projection & Node Color", group=grp_rsi)

grp_fade     = "Liquidity Wall Filter"
use_wall_filter = input.bool(true, "Enable POC Proximity Filter", group=grp_fade)
wall_mult       = input.float(1.0, "Proximity Tolerance (ATR Multiplier)", minval=0.1, group=grp_fade)

grp_trade    = "Risk Projection Simulation"
sl_mult      = input.float(1.5, "Stop Loss (ATR Multiplier)", minval=0.5, group=grp_trade)
rr_ratio     = input.float(2.0, "Risk:Reward Target", minval=0.5, group=grp_trade)
atr_len_tr   = input.int(14, "ATR Period for Projection", group=grp_trade)

grp_ext      = "Visual Extensions"
extend_poc   = input.bool(true, "Project POC Forward", group=grp_ext)
extend_bars  = input.int(10, "Forward Projection Distance", minval=1, group=grp_ext)
table_size_str = input.string("normal", "Dashboard Typography Size", options=["tiny", "small", "normal", "large", "auto"], group=grp_ext)

f_get_size(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.auto
tbl_size = f_get_size(table_size_str)

float atr_val = ta.atr(atr_len_tr)

// ==========================================
// 2. LTF Data Extraction & Calculation
// ==========================================
bool is_valid_tf = timeframe.in_seconds(ltf_res) < timeframe.in_seconds(timeframe.period)

float bar_vol = 0.0
float bar_avg_rsi = 50.0 

if is_valid_tf
    [ltf_o, ltf_c, ltf_v, ltf_rsi] = request.security_lower_tf(syminfo.tickerid, ltf_res, [open, close, volume, ta.rsi(close, rsi_len)])
    
    int sz = array.size(ltf_o)
    if sz > 0
        int start_idx = (ltf_max > 0 and sz > ltf_max) ? sz - ltf_max : 0
        float sum_rsi_vol = 0.0
        float sum_vol = 0.0
        
        for i = start_idx to sz - 1
            float o = array.get(ltf_o, i)
            float c = array.get(ltf_c, i)
            float v = nz(array.get(ltf_v, i))
            float r = nz(array.get(ltf_rsi, i), 50.0)
            
            float data_val = 0.0
            if fp_source == "Volume"
                data_val := v
            else if fp_source == "Price Delta"
                data_val := math.abs(c - o)
                
            bar_vol += data_val
            sum_rsi_vol += (r * data_val)
            sum_vol += data_val
            
        if sum_vol > 0
            bar_avg_rsi := sum_rsi_vol / sum_vol

// ==========================================
// 3. Reverse RSI Calculation Engine
// ==========================================
float change_val = close - nz(close[1])
float u = math.max(change_val, 0.0)
float d = math.max(-change_val, 0.0)
float rma_u = ta.rma(u, rsi_len)
float rma_d = ta.rma(d, rsi_len)
float prev_rma_u = nz(rma_u[1])
float prev_rma_d = nz(rma_d[1])
float prev_c     = nz(close[1])

f_get_reverse_price(target_rsi) =>
    float target_rs = target_rsi / (100.0 - target_rsi)
    float req_up   = (target_rs * prev_rma_d * (rsi_len - 1)) - (prev_rma_u * (rsi_len - 1))
    float req_down = (prev_rma_u * (rsi_len - 1) / target_rs) - (prev_rma_d * (rsi_len - 1))
    float rev_price = req_up > 0 ? prev_c + req_up : (req_down > 0 ? prev_c - req_down : prev_c)
    rev_price

var float rev_ob_price = na
if is_valid_tf and barstate.isconfirmed
    rev_ob_price := f_get_reverse_price(rsi_ob)
var float rev_os_price = na
if is_valid_tf and barstate.isconfirmed
    rev_os_price := f_get_reverse_price(rsi_os)

// ==========================================
// 4. Session Tracking Engine (UTC Based)
// ==========================================
var int[] sess_start_bars = array.new_int()
var int[] sess_end_bars = array.new_int()
var bool in_custom_sess = false
var int current_custom_start = na
var int current_tf_start = bar_index

bool is_time_mode = prof_mode == "Daily" or prof_mode == "Weekly" or prof_mode == "Monthly"
bool is_new_tf = false

if prof_mode == "Daily"
    is_new_tf := ta.change(time("D")) != 0
else if prof_mode == "Weekly"
    is_new_tf := ta.change(time("W")) != 0
else if prof_mode == "Monthly"
    is_new_tf := ta.change(time("M")) != 0

if is_time_mode and is_valid_tf
    if is_new_tf
        array.push(sess_start_bars, current_tf_start)
        array.push(sess_end_bars, bar_index - 1)
        current_tf_start := bar_index
    if array.size(sess_start_bars) > 20
        array.shift(sess_start_bars)
        array.shift(sess_end_bars)

string target_sess_str = active_sess == "Oceania Session" ? sess_oceania : active_sess == "Asia Session" ? sess_asia : active_sess == "London Session" ? sess_london : sess_ny
bool is_custom_active = not na(time(timeframe.period, target_sess_str, sess_tz))

if prof_mode == "Custom Sessions" and is_valid_tf
    if is_custom_active and not in_custom_sess
        current_custom_start := bar_index
        in_custom_sess := true
    else if not is_custom_active and in_custom_sess
        array.push(sess_start_bars, current_custom_start)
        array.push(sess_end_bars, bar_index - 1)
        in_custom_sess := false
    if array.size(sess_start_bars) > 20
        array.shift(sess_start_bars)
        array.shift(sess_end_bars)

// ==========================================
// 5. RSI Anomaly Volume Profile Matrix
// ==========================================
var box[]    all_boxes    = array.new_box()
var line[]   all_lines    = array.new_line()
var label[]  all_labels   = array.new_label()

float latest_poc_price = na 

if barstate.islast and is_valid_tf
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

    int[] render_starts = array.new_int()
    int[] render_ends = array.new_int()

    int sz = array.size(sess_start_bars)
    int take_num = math.min(sz, prof_num - 1)
    if take_num > 0
        for i = sz - take_num to sz - 1
            array.push(render_starts, array.get(sess_start_bars, i))
            array.push(render_ends, array.get(sess_end_bars, i))
            
    if prof_mode == "Custom Sessions"
        if in_custom_sess
            array.push(render_starts, current_custom_start)
            array.push(render_ends, bar_index)
    else
        array.push(render_starts, current_tf_start)
        array.push(render_ends, bar_index)

    int render_count = array.size(render_starts)
    if render_count > 0
        for p_idx = 0 to render_count - 1
            int p_start_bar = array.get(render_starts, p_idx)
            int p_end_bar   = array.get(render_ends, p_idx)
            int p_age = render_count - 1 - p_idx
            
            int lb_start = math.max(0, p_start_bar)
            lb_start := math.max(lb_start, bar_index - 999)
            
            int lb_end   = math.min(bar_index, p_end_bar)
            lb_end := math.max(lb_end, lb_start)

            float s_high = high[bar_index - lb_start]
            float s_low  = low[bar_index - lb_start]
            for i = bar_index - lb_end to bar_index - lb_start
                s_high := math.max(s_high, high[i])
                s_low  := math.min(s_low, low[i])
            if na(s_high) or na(s_low) or s_high == s_low
                continue
                
            float step_price = (s_high - s_low) / row_count
            
            float[] row_vols = array.new_float(row_count, 0.0)
            float[] row_rsi_acc = array.new_float(row_count, 0.0)
            float[] row_rsi_max = array.new_float(row_count, 50.0)
            float[] row_rsi_min = array.new_float(row_count, 50.0)
            
            for i = bar_index - lb_end to bar_index - lb_start
                if not na(bar_vol[i])
                    float b_vol = bar_vol[i]
                    int start_row = math.floor((low[i] - s_low) / step_price)
                    int end_row   = math.floor((high[i] - s_low) / step_price)
                    start_row := math.max(0, math.min(start_row, row_count - 1))
                    end_row   := math.max(0, math.min(end_row, row_count - 1))
                    int rows_touched = (end_row - start_row) + 1
                    
                    float vol_per_row = b_vol / rows_touched
                    float b_rsi = bar_avg_rsi[i] 
                        
                    for r = start_row to end_row
                        array.set(row_vols, r, array.get(row_vols, r) + vol_per_row)
                        array.set(row_rsi_acc, r, array.get(row_rsi_acc, r) + (b_rsi * vol_per_row))
                        array.set(row_rsi_max, r, math.max(array.get(row_rsi_max, r), b_rsi))
                        array.set(row_rsi_min, r, math.min(array.get(row_rsi_min, r), b_rsi))
                        
            float max_total_vol = 0.0
            int poc_row_idx = 0
            for r = 0 to row_count - 1
                float t_vol = array.get(row_vols, r)
                if t_vol > max_total_vol
                    max_total_vol := t_vol
                    poc_row_idx := r
                    
            if max_total_vol <= 0
                max_total_vol := 1.0
                
            if p_age == 0
                latest_poc_price := s_low + (poc_row_idx * step_price) + (step_price / 2)
                
            int base_transp = 100 - fill_opacity
                
            for r = 0 to row_count - 1
                float t_vol = array.get(row_vols, r)
                if t_vol > 0
                    float avg_rsi = array.get(row_rsi_acc, r) / t_vol
                    float max_rsi = array.get(row_rsi_max, r)
                    float min_rsi = array.get(row_rsi_min, r)
                    
                    float b_bot = s_low + (r * step_price)
                    float b_top = s_low + ((r + 1) * step_price)
                    bool is_poc = r == poc_row_idx
                    float intensity = t_vol / max_total_vol
                    
                    bool is_significant = (intensity * 100.0) >= vol_threshold
                    int b_end = p_start_bar + math.max(1, math.round((p_end_bar - p_start_bar) * intensity))
                    
                    int box_transp = is_significant ? base_transp : (hide_weak ? 100 : math.min(100, base_transp + 25))
                    
                    if p_age > 0 and box_transp < 100
                        box_transp := math.min(100, box_transp + 15)
                    
                    color base_c = color_prof_neutral
                    if is_significant
                        if rsi_color_mode == "Peak Retention"
                            if max_rsi >= rsi_ob and min_rsi <= rsi_os
                                base_c := color_prof_neutral
                            else if max_rsi >= rsi_ob
                                base_c := color_ob
                            else if min_rsi <= rsi_os 
                                base_c := color_os
                        else
                            float vw_ob = 50.0 + ((rsi_ob - 50.0) * vw_mult) 
                            float vw_os = 50.0 - ((50.0 - rsi_os) * vw_mult) 
                            if avg_rsi >= vw_ob
                                base_c := color_ob
                            else if avg_rsi <= vw_os
                                base_c := color_os
                    
                    color box_c = is_poc ? color.new(color_prof_poc, math.max(0, box_transp - 15)) : color.new(base_c, box_transp)
                    
                    box b = box.new(p_start_bar, b_top, b_end, b_bot, border_color=na, bgcolor=box_c)
                    array.push(all_boxes, b)
                    
                    if is_poc and extend_poc
                        int ext_end = p_age == 0 ? bar_index + extend_bars : b_end + 2
                        color poc_c = p_age == 0 ? color.new(color_prof_poc, 20) : color.new(base_c, 60)
                        line l_poc = line.new(p_start_bar, b_bot + (step_price/2), ext_end, b_bot + (step_price/2), color=poc_c, width=1, style=line.style_dashed)
                        array.push(all_lines, l_poc)
                        
    // ==========================================
    // 6. Liquidity Wall Filter
    // ==========================================
    float wall_range = atr_val * wall_mult
    bool ob_is_protected = na(latest_poc_price) ? false : (math.abs(rev_ob_price - latest_poc_price) <= wall_range)
    bool os_is_protected = na(latest_poc_price) ? false : (math.abs(rev_os_price - latest_poc_price) <= wall_range)
    
    bool fade_ob = use_wall_filter and not ob_is_protected
    bool fade_os = use_wall_filter and not os_is_protected

    // ==========================================
    // 7. Visual Rendering & Simulation Engine
    // ==========================================
    int future_bar = bar_index + extend_bars
    int safe_start_idx = math.max(0, bar_index - 2)

    int alpha_ob_glow = fade_ob ? 95 : 80
    int alpha_ob_core = fade_ob ? 90 : 0
    line l_ob_glow = line.new(safe_start_idx, rev_ob_price, future_bar, rev_ob_price, color=color.new(color_ob, alpha_ob_glow), width=6)
    line l_ob_core = line.new(safe_start_idx, rev_ob_price, future_bar, rev_ob_price, color=color.new(color_ob, alpha_ob_core), width=1)
    array.push(all_lines, l_ob_glow)
    array.push(all_lines, l_ob_core)
    
    int alpha_os_glow = fade_os ? 95 : 80
    int alpha_os_core = fade_os ? 90 : 0
    line l_os_glow = line.new(safe_start_idx, rev_os_price, future_bar, rev_os_price, color=color.new(color_os, alpha_os_glow), width=6)
    line l_os_core = line.new(safe_start_idx, rev_os_price, future_bar, rev_os_price, color=color.new(color_os, alpha_os_core), width=1)
    array.push(all_lines, l_os_glow)
    array.push(all_lines, l_os_core)

    // Simulation Execution (Hidden Easter Egg)
    var int   trade_state = 0
    var float entry_p = na
    var float tp_p    = na
    var float sl_p    = na
    var box   tp_box  = na
    var box   sl_box  = na
    var line  ent_line = na

    if trade_state == 0
        if low <= rev_os_price and not fade_os and barstate.isconfirmed
            trade_state := 1
            entry_p := rev_os_price
            float risk = atr_val * sl_mult
            sl_p := entry_p - risk
            tp_p := entry_p + (risk * rr_ratio)
            label.new(bar_index, entry_p, text="", style=label.style_triangleup, color=color_os, size=size.tiny)
            tp_box := box.new(bar_index, tp_p, bar_index, entry_p, border_color=na, bgcolor=color.new(color_os, 90))
            sl_box := box.new(bar_index, entry_p, bar_index, sl_p, border_color=na, bgcolor=color.new(#ff1744, 90))
            ent_line := line.new(bar_index, entry_p, bar_index, entry_p, color=color.new(color_os, 50), style=line.style_dotted, width=1)
            
        else if high >= rev_ob_price and not fade_ob and barstate.isconfirmed
            trade_state := -1
            entry_p := rev_ob_price
            float risk = atr_val * sl_mult
            sl_p := entry_p + risk
            tp_p := entry_p - (risk * rr_ratio)
            label.new(bar_index, entry_p, text="", style=label.style_triangledown, color=color_ob, size=size.tiny)
            tp_box := box.new(bar_index, entry_p, bar_index, tp_p, border_color=na, bgcolor=color.new(color_ob, 90))
            sl_box := box.new(bar_index, sl_p, bar_index, entry_p, border_color=na, bgcolor=color.new(#ff1744, 90))
            ent_line := line.new(bar_index, entry_p, bar_index, entry_p, color=color.new(color_ob, 50), style=line.style_dotted, width=1)
    else
        if not na(tp_box)
            box.set_right(tp_box, bar_index)
            box.set_right(sl_box, bar_index)
            line.set_x2(ent_line, bar_index)
        if trade_state == 1
            if low <= sl_p and barstate.isconfirmed
                trade_state := 0
                label.new(bar_index, sl_p, text="×", style=label.style_label_center, color=color.new(color.black, 100), textcolor=color.gray, size=size.tiny)
            else if high >= tp_p
                trade_state := 0
                label.new(bar_index, tp_p, text="✓", style=label.style_label_center, color=color.new(color.black, 100), textcolor=color_os, size=size.small)
        else if trade_state == -1
            if high >= sl_p and barstate.isconfirmed
                trade_state := 0
                label.new(bar_index, sl_p, text="×", style=label.style_label_center, color=color.new(color.black, 100), textcolor=color.gray, size=size.tiny)
            else if low <= tp_p
                trade_state := 0
                label.new(bar_index, tp_p, text="✓", style=label.style_label_center, color=color.new(color.black, 100), textcolor=color_ob, size=size.small)

// ==========================================
// 8. Output Dashboard
// ==========================================
var table minimal_dash = table.new(position.top_right, 2, 3, border_width=0, bgcolor=color.new(color.black, 80))
if barstate.islast
    if is_valid_tf
        table.cell(minimal_dash, 0, 0, "TARGET OB", text_color=color.new(color.white, 40), text_size=tbl_size)
        table.cell(minimal_dash, 1, 0, str.tostring(rev_ob_price, format.mintick), text_color=color_ob, text_size=tbl_size)
        table.cell(minimal_dash, 0, 1, "TARGET OS", text_color=color.new(color.white, 40), text_size=tbl_size)
        table.cell(minimal_dash, 1, 1, str.tostring(rev_os_price, format.mintick), text_color=color_os, text_size=tbl_size)
    else
        table.cell(minimal_dash, 0, 0, "SYSTEM ALERT:", text_color=#ff1744, text_size=tbl_size)
        table.cell(minimal_dash, 1, 0, "Resolution Conflict", text_color=color.gray, text_size=tbl_size)
        table.cell(minimal_dash, 0, 1, "Status", text_color=color.gray, text_size=tbl_size)
        table.cell(minimal_dash, 1, 1, "Execution Suspended", text_color=color.gray, text_size=tbl_size)
````
