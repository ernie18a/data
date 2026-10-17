# Historical Pattern Projection [MarkitTick]

- url: https://www.tradingview.com/script/vuTQkJff-Historical-Pattern-Projection-MarkitTick/
- type: indicator
- pine_id: PUB;ee54125fa4524c73a35071cf860b023a
- version: 1.0

## Description

💡 An advanced analytical framework engineered to identify, isolate, and project current price action based on historically correlated market structures. Rather than relying on traditional lagging oscillators or subjective chart patterns, this tool continuously evaluates the most recent sequence of price movements—termed the "fingerprint"—and algorithmically scans historical data to find statistically similar precedents. By projecting the historical outcomes of these matching patterns onto the current chart, it provides an empirical, data-driven perspective on potential near-term price trajectories, seamlessly bridging the gap between quantitative correlation analysis and practical trade management.

[b]✨ Originality and Utility[/b]

[list]
[*] Traditional technical analysis often relies on rigid, subjective patterns (such as head-and-shoulders or flags) which can be open to interpretation and cognitive bias.
[*] This script completely bypasses subjective pattern drawing by employing a strictly mathematical approach to shape-matching.
[*] It normalizes price action into a pure structural format, allowing it to compare the geometry of the current market with historical markets, regardless of the absolute price levels.
[*] The utility lies in its ability to automatically synthesize the "what happened next" data from historical matches. 
[*] Instead of merely signaling overbought or oversold conditions, it provides a probabilistic projection path—a "ghost line"—complete with expected volatility bands and automated risk management levels based on the anticipated outcome.
[/list]

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/rDzE80Nb/[/image]
[b]● Core Recognition Engine[/b]
[list]
[*] [b]• Data Normalization:[/b] The current price sequence (the fingerprint) is converted using a statistical Z-Score. This transformation removes the absolute price values and leaves behind the raw volatility-adjusted shape of the trend.
[*] [b]• Deep Historical Scanning:[/b] The algorithm iterates backwards through user-defined historical bars (Search Depth) to extract rolling arrays of previous price action.
[*] [b]• Statistical Correlation:[/b] Each historical array is compared to the current fingerprint using the Pearson Correlation Coefficient. The resulting value (-1.0 to +1.0) is mathematically scaled into a percentage (0% to 100%) to represent a "Similarity Score."
[/list]

[b]● Outcome Synthesis and Extrapolation[/b]
[list]
[*] [b]• Match Aggregation:[/b] The script filters out matches that fall below the minimum Similarity Score threshold, keeping only the top configured matches.
[*] [b]• Trajectory Calculation:[/b] For each valid match, the script records the price movement that occurred immediately after the historical pattern completed.
[*] [b]• Price Scaling:[/b] The historical outcomes are structurally scaled and tethered to the current closing price, allowing the indicator to plot a composite average of these historical outcomes directly into the future empty space of the chart.
[/list]

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/7VMrQphA/[/image]
[b]● On-Chart Projections and Highlights[/b]
[list]
[*] [b]• ECHO Match Zones:[/b] The historical periods that closely match the current price action are highlighted with thick, colored vertical bands (defaulting to deep orange). These zones allow for immediate visual verification of the structural similarity.
[*] [b]• Ghost Line (Projection):[/b] Plotted into the future, this solid, fading purple line illustrates the average expected trajectory based on the historical matches. It features an arrow and percentage label at the terminus to indicate the total projected directional move.
[*] [b]• Range Bands:[/b] Dashed, semi-transparent purple lines expanding outward from the Ghost Line. These bands represent the expected volatility expansion over the projection period, calculated using a dynamically scaling Average True Range (ATR).
[/list]

[b]● Trade Management Ecosystem[/b]
[list]
[*] [b]• Entry Box:[/b] A highlighted zone (default yellow) projecting forward from the current bar, representing an optimal entry width based on a fraction of the current ATR.
[*] [b]• Stop Loss (SL) Line:[/b] A solid red horizontal line indicating the suggested invalidation level, dynamically placed away from the entry using an ATR multiplier.
[*] [b]• Take Profit (TP) Lines:[/b] Three dashed green horizontal lines representing tiered profit targets (TP1, TP2, and TP3), scaled mathematically via ATR multipliers in the direction of the historical bias.
[/list]

[b]● The ECHO Dashboard Table[/b]
[list]
[*] [b]• Top Match Score:[/b] Displays the similarity percentage of the most highly correlated historical pattern. Color-coded for rapid assessment (Green for Strong >80%, Yellow for Moderate, Orange for Weak).
[*] [b]• Fingerprint & Depth:[/b] Confirms the lookback length and the total bars scanned.
[*] [b]• Outcome Metrics:[/b] Displays the historical "Votes" (percentage of matches that went Bullish, Bearish, or Neutral) and the overall Average Move.
[*] [b]• Historical Roster:[/b] The bottom half of the dashboard ranks the individual top historical matches, detailing their exact score, how many bars ago they occurred, and their specific post-pattern return.
[/list]

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/jGamCvzq/[/image]
[list]
[*] [b]• Pattern Validation:[/b] Monitor the ECHO Dashboard for patterns that achieve a Similarity Score of 80% or higher. Lower correlation scores should be treated with high skepticism as the historical geometries are not closely aligned.
[*] [b]• Bias Confirmation:[/b] Check the "Proj Bias" and "Votes" metrics on the dashboard. A strong projection should ideally have unanimous or near-unanimous historical consensus (e.g., 100% Bullish votes).
[*] [b]• Trade Execution:[/b] If a high-probability setup is identified, utilize the projected Trade Management levels. The highlighted Entry Box provides a buffer for execution, while the SL and TP lines offer an objective, volatility-adjusted framework for placing orders.
[*] [b]• Alert Integration:[/b] The indicator can be tied to dynamic webhooks. Set an alert on the indicator, and when a "Strong" match is found, it will automatically transmit a JSON payload containing the Entry, Stop Loss, and Take Profit levels for automated systems or notifications.
[/list]

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/eFbrY4Fo/[/image]
[b]● Core Settings[/b]
[list]
[*] [b]• Freeze Data:[/b] A toggle that stops the algorithm from updating on every tick, locking the current projection in place for stable analysis.
[*] [b]• Fingerprint Length:[/b] The number of current bars used to form the recognizable pattern. Shorter lengths are highly responsive but prone to noise; longer lengths find deep structural macro-patterns.
[*] [b]• Search Depth:[/b] The maximum number of historical bars the algorithm will scan. Increasing this expands the database but requires more computational resources.
[*] [b]• Min Score (%):[/b] The correlation threshold required for a historical pattern to be considered valid.
[/list]

[b]● Projection & Risk Settings[/b]
[list]
[*] [b]• Ghost Length:[/b] Defines how many bars into the future the algorithm should project the historical outcome.
[*] [b]• Entry Width (xATR):[/b] Defines the vertical height of the entry box based on current volatility.
[*] [b]• SL & TP Multipliers:[/b] Adjustable factors that determine the distance of Stop Loss and Take Profit levels based on the current 14-period ATR.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[list]
[*] [b]• Z-Score Standardization:[/b] The algorithm employs standard score normalization to analyze price action. By subtracting the moving average (mean) from the price and dividing by the standard deviation, the data is transformed into a dimensionless unit. This ensures that a pattern occurring in a low-volatility environment can be mathematically matched to the exact same geometric structure occurring in a high-volatility environment.
[*] [b]• Pearson Correlation Coefficient:[/b] The core matching engine relies on Pearson's *r*, a measure of linear correlation between two sets of data. The formula computes the covariance of the current fingerprint and the historical candidate window, divided by the product of their standard deviations. This rigorously quantifies how closely the two price paths mirror each other over the specified timeframe.
[*] [b]• Volatility-Adjusted Target Extrapolation:[/b] Rather than using fixed percentages or subjective support/resistance, the script utilizes the Average True Range (ATR) to govern its forward-looking risk management bands. Because market regimes shift, the ATR ensures that the projected bands and trade levels expand during turbulent market phases and contract during periods of consolidation, maintaining mathematical proportionality to current market conditions.
[*] [b]• Algorithmic Caveats:[/b] Because the script continuously scans and matches the most recent data, the projected path will shift dynamically as new bars form, unless the "Freeze" function is engaged. Furthermore, the indicator evaluates the close of bars; running this framework on non-standard synthetic charts (such as Heikin Ashi or Renko) is fundamentally flawed due to the artificial smoothing of synthetic price data, which alters the underlying statistical distribution.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Historical Pattern Projection [MarkitTick]", overlay=true, max_bars_back=2000, max_lines_count=500, max_labels_count=50, max_boxes_count=20)

// =========================================================================
// SECTION 1: INPUT GROUPS & CONFIGURATIONS
// =========================================================================
string GRP_CORE  = "⚙️ Core"
string GRP_PROJ  = "🔮 Proj"
string GRP_VIS   = "🎨 Vis"
string GRP_TRADE = "Risk"
string GRP_DASH  = "Dash"

i_freeze       = input.bool(false, "Freeze Data", group=GRP_CORE, tooltip="")
i_pattern_len  = input.int(30, "Fingerprint Length", minval=10, maxval=100, group=GRP_CORE, tooltip="")
i_search_depth = input.int(500, "Search Depth", minval=100, maxval=2000, group=GRP_CORE, tooltip="")
i_top_matches  = input.int(3, "Top Matches", minval=1, maxval=5, group=GRP_CORE)
i_min_score    = input.float(60.0, "Min Score (%)", minval=30.0, maxval=95.0, step=1.0, group=GRP_CORE, tooltip="")
i_proj_len     = input.int(20, "Ghost Length", minval=5, maxval=60, group=GRP_PROJ)

i_show_ghost   = input.bool(true, "Ghost Line", group=GRP_PROJ)
i_show_range   = input.bool(true, "Range Band", group=GRP_PROJ)
i_show_match   = input.bool(true, "Best Match Zone", group=GRP_PROJ)
i_show_score   = input.bool(true, "Score Label", group=GRP_VIS)
i_show_table   = input.bool(true, "ECHO Dashboard", group=GRP_VIS)
i_tbl_pos      = input.string("top_right", "Dash Position", options=["top_right","top_left","bottom_right","bottom_left"], group=GRP_VIS)
i_ghost_color  = input.color(color.new(#7C4DFF,0), "Ghost Color", group=GRP_VIS)
i_match_color  = input.color(color.new(#FF6F00,0), "Match Color", group=GRP_VIS)

i_show_trade   = input.bool(true, "Trade Levels", group=GRP_TRADE)
i_entry_width  = input.float(0.25, "Entry Width (xATR)", minval=0.05, maxval=2.0, step=0.05, group=GRP_TRADE)
i_sl_mult      = input.float(1.5, "SL (xATR)", minval=0.5, maxval=5.0, step=0.1, group=GRP_TRADE)
i_tp1_mult     = input.float(1.0, "TP1 (xATR)", minval=0.1, maxval=10.0, step=0.1, group=GRP_TRADE)
i_tp2_mult     = input.float(2.0, "TP2 (xATR)", minval=0.1, maxval=15.0, step=0.1, group=GRP_TRADE)
i_tp3_mult     = input.float(3.0, "TP3 (xATR)", minval=0.1, maxval=20.0, step=0.1, group=GRP_TRADE)
i_entry_color  = input.color(color.new(#FFD600,15), "Entry Color", group=GRP_TRADE)
i_sl_color     = input.color(color.new(#F44336,15), "SL Color", group=GRP_TRADE)
i_tp_color     = input.color(color.new(#00C853,15), "TP Color", group=GRP_TRADE)

color dash_bg_color  = input.color(color.rgb(10,10,18,5), "BG", group=GRP_DASH)
color dash_txt_color = input.color(color.rgb(220,220,235,0), "Text", group=GRP_DASH)
color i_tbl_hdr_bg   = input.color(color.new(#4527A0,15), "Table Header BG", group=GRP_DASH)
color i_tbl_cell_bg1 = input.color(color.new(#0D0D1A,30), "Table Cell BG 1", group=GRP_DASH)
color i_tbl_cell_bg2 = input.color(color.new(#0D0D1A,40), "Table Cell BG 2", group=GRP_DASH)
color i_tbl_cell_bg3 = input.color(color.new(#0D0D1A,50), "Table Cell BG 3", group=GRP_DASH)
color i_tbl_cell_bg4 = input.color(color.new(#0D0D1A,60), "Table Cell BG 4", group=GRP_DASH)
color i_tbl_cell_hl  = input.color(color.new(#1A0F2E,20), "Table Highlight BG", group=GRP_DASH)
color i_tbl_border   = input.color(color.rgb(50,50,70,20), "Table Border", group=GRP_DASH)
color i_tbl_frame    = input.color(color.rgb(60,60,90,10), "Table Frame", group=GRP_DASH)
color i_dim          = input.color(color.new(color.gray,10), "Dim Text", group=GRP_DASH)
color i_dim2         = input.color(color.new(color.gray,5), "Dim Text 2", group=GRP_DASH)
color i_pur          = input.color(color.new(#CE93D8,0), "Accent Text", group=GRP_DASH)

// =========================================================================
// SECTION 2: CHART VALIDATION & SAFETY CHECKS
// =========================================================================
string clean_ticker = syminfo.prefix + ":" + syminfo.ticker

bool isNonStandard = chart.is_heikinashi or chart.is_renko or chart.is_linebreak or chart.is_kagi or chart.is_pnf
if isNonStandard and barstate.islast
    runtime.error("Non-standard charts (Heikin Ashi, Renko, etc.) cause synthetic pricing and historical repainting. Please switch to standard Japanese Candlesticks.")

// =========================================================================
// SECTION 3: CUSTOM MATH & STATISTICAL FUNCTIONS
// =========================================================================
f_zscore(series float src, simple int len) =>
    float m = ta.sma(src, len)
    float s = ta.stdev(src, len)
    s > 0.0 ? (src - m) / s : 0.0

f_pearson(float[] a, float[] b, simple int len) =>
    float sum_a  = 0.0
    float sum_b  = 0.0
    float sum_ab = 0.0
    float sum_a2 = 0.0
    float sum_b2 = 0.0
    for i = 0 to len - 1
        float ai = array.get(a, i)
        float bi = array.get(b, i)
        sum_a  += ai
        sum_b  += bi
        sum_ab += ai * bi
        sum_a2 += ai * ai
        sum_b2 += bi * bi
    float n   = float(len)
    float num = n * sum_ab - sum_a * sum_b
    float den = math.sqrt((n * sum_a2 - sum_a * sum_a) * (n * sum_b2 - sum_b * sum_b))
    den > 1e-10 ? num / den : 0.0

// =========================================================================
// SECTION 4: GLOBAL VARIABLES & STATE INITIALIZATION
// =========================================================================
float z_close = f_zscore(close, i_pattern_len)
float atr_now = ta.atr(14)

var float[] match_scores   = array.new_float(0)
var int[]   match_bars_ago = array.new_int(0)
var float[] match_outcome  = array.new_float(0)
var float[] ghost_path     = array.new_float(0)
var float[] ghost_high     = array.new_float(0)
var float[] ghost_low      = array.new_float(0)

var float best_score  = 0.0
var int   best_offset = 0
var float avg_outcome = 0.0
var int   bull_count  = 0
var int   bear_count  = 0
var int   neut_count  = 0
var int   anchor_bar  = bar_index
var bool  data_frozen = false

// =========================================================================
// SECTION 5: CORE PATTERN RECOGNITION ALGORITHM
// =========================================================================
bool do_update = (barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)) and not (i_freeze and data_frozen)

if do_update
    anchor_bar := bar_index
    array.clear(match_scores)
    array.clear(match_bars_ago)
    array.clear(match_outcome)
    array.clear(ghost_path)
    array.clear(ghost_high)
    array.clear(ghost_low)
    best_score  := 0.0
    best_offset := 0
    avg_outcome := 0.0
    bull_count  := 0
    bear_count  := 0
    neut_count  := 0
    
    float[] cur_fp = array.new_float(i_pattern_len)
    for i = 0 to i_pattern_len - 1
        array.set(cur_fp, i, z_close[i_pattern_len - 1 - i])
        
    int max_depth = math.min(i_search_depth, bar_index - i_pattern_len - i_proj_len - 5)
    for offset = i_pattern_len + i_proj_len + 2 to max_depth
        float[] cand_fp = array.new_float(i_pattern_len)
        bool valid = true
        float cand_m = 0.0
        
        for k = 0 to i_pattern_len - 1
            cand_m += close[offset - k]
        cand_m /= i_pattern_len
        
        float cand_s = 0.0
        for k = 0 to i_pattern_len - 1
            float d = close[offset - k] - cand_m
            cand_s += d * d
        cand_s := math.sqrt(cand_s / i_pattern_len)
        
        for i = 0 to i_pattern_len - 1
            int idx = offset - i
            if idx > bar_index
                valid := false
                break
            float z = cand_s > 0.0 ? (close[idx] - cand_m) / cand_s : 0.0
            array.set(cand_fp, i_pattern_len - 1 - i, z)
            
        if not valid
            continue
            
        float corr  = f_pearson(cur_fp, cand_fp, i_pattern_len)
        float score = (corr + 1.0) / 2.0 * 100.0
        
        if score < i_min_score
            continue
            
        float entry_price = close[offset - i_pattern_len]
        float exit_price  = close[offset - i_pattern_len - i_proj_len]
        float outcome_pct = entry_price > 0.0 ? (exit_price - entry_price) / entry_price * 100.0 : 0.0
        
        int  n_matches = array.size(match_scores)
        bool inserted  = false
        
        if n_matches > 0
            for m_i = 0 to n_matches - 1
                if score > array.get(match_scores, m_i)
                    array.insert(match_scores, m_i, score)
                    array.insert(match_bars_ago, m_i, offset)
                    array.insert(match_outcome, m_i, outcome_pct)
                    inserted := true
                    break
                    
        if not inserted
            array.push(match_scores, score)
            array.push(match_bars_ago, offset)
            array.push(match_outcome, outcome_pct)
            
        while array.size(match_scores) > i_top_matches
            array.pop(match_scores)
            array.pop(match_bars_ago)
            array.pop(match_outcome)
            
    int n_found = array.size(match_scores)
    if n_found > 0
        best_score  := array.get(match_scores, 0)
        best_offset := array.get(match_bars_ago, 0)
        float base_price  = close[best_offset - i_pattern_len]
        float start_price = close
        float avg_out = 0.0
        
        for mi = 0 to n_found - 1
            float oc = array.get(match_outcome, mi)
            avg_out += oc
            if oc > 0.5
                bull_count += 1
            else if oc < -0.5
                bear_count += 1
            else
                neut_count += 1
                
        avg_outcome := avg_out / n_found
        float scale = base_price > 0.0 ? start_price / base_price : 1.0
        
        for fi = 0 to i_proj_len - 1
            float hist_price = close[best_offset - i_pattern_len - fi]
            float proj_price = hist_price * scale
            array.push(ghost_path, proj_price)
            float band_width = atr_now * (1.0 + float(fi) * 0.1)
            array.push(ghost_high, proj_price + band_width)
            array.push(ghost_low, proj_price - band_width)
            
    data_frozen := true

// =========================================================================
// SECTION 6: VISUALIZATION (MATCH HIGHLIGHTS & GHOST PROJECTIONS)
// =========================================================================
var line[]  echo_lines  = array.new_line()
var label[] echo_labels = array.new_label()

if do_update
    int _esz = array.size(echo_lines)
    if _esz > 0
        for i = 0 to _esz - 1
            line.delete(array.get(echo_lines, i))
    array.clear(echo_lines)
    
    int _lsz = array.size(echo_labels)
    if _lsz > 0
        for i = 0 to _lsz - 1
            label.delete(array.get(echo_labels, i))
    array.clear(echo_labels)
    
    int n_found = array.size(match_scores)
    if i_show_match and n_found > 0
        int match_end   = best_offset
        int match_start = best_offset - i_pattern_len
        for b = match_start to match_end
            int   idx      = anchor_bar - b
            float body_top = math.max(open[b], close[b])
            float body_bot = math.min(open[b], close[b])
            body_bot := body_top == body_bot ? body_bot - syminfo.mintick : body_bot
            
            array.push(echo_lines, line.new(idx, high[b], idx, body_top, color=i_match_color, width=1))
            array.push(echo_lines, line.new(idx, body_bot, idx, low[b], color=i_match_color, width=1))
            array.push(echo_lines, line.new(idx, body_top, idx, body_bot, color=i_match_color, width=5))
            array.push(echo_lines, line.new(idx-1, body_top, idx, body_top, color=color.new(i_match_color,30), width=1))
            array.push(echo_lines, line.new(idx-1, body_bot, idx, body_bot, color=color.new(i_match_color,30), width=1))
            
        array.push(echo_labels, label.new(x = anchor_bar - match_end, y = high[match_end] * 1.001, text = "ECHO Match\n" + str.tostring(math.round(best_score, 1)) + "% similar", color = color.new(i_match_color, 20), textcolor = color.white, style = label.style_label_down, size = size.small))
        
    if i_show_ghost and array.size(ghost_path) > 0
        int proj_len = array.size(ghost_path)
        for fi = 0 to proj_len - 2
            float p1         = array.get(ghost_path, fi)
            float p2         = array.get(ghost_path, fi + 1)
            int   fade_alpha = math.round(math.min(85, fi * (85.0 / proj_len)))
            array.push(echo_lines, line.new(x1 = anchor_bar + fi, y1 = p1, x2 = anchor_bar + fi + 1, y2 = p2, color = color.new(i_ghost_color, fade_alpha), width = 2, style = line.style_solid))
            
        float last_proj  = array.get(ghost_path, proj_len - 1)
        float first_proj = array.get(ghost_path, 0)
        string ghost_dir = last_proj > first_proj ? "▲" : "▼"
        float ghost_move = first_proj > 0.0 ? math.abs((last_proj - first_proj) / first_proj * 100.0) : 0.0
        
        array.push(echo_labels, label.new(x = anchor_bar + proj_len, y = last_proj, text = ghost_dir + " " + str.tostring(math.round(ghost_move, 2)) + "%\n(Projected)", color = color.new(i_ghost_color, 15), textcolor = color.white, style = label.style_label_left, size = size.small))
        
    if i_show_range and array.size(ghost_high) > 0
        int rng_len = array.size(ghost_high)
        for fi = 0 to rng_len - 2
            array.push(echo_lines, line.new(x1 = anchor_bar + fi, y1 = array.get(ghost_high, fi), x2 = anchor_bar + fi + 1, y2 = array.get(ghost_high, fi + 1), color = color.new(i_ghost_color, 50), width = 1, style = line.style_dashed))
            array.push(echo_lines, line.new(x1 = anchor_bar + fi, y1 = array.get(ghost_low, fi), x2 = anchor_bar + fi + 1, y2 = array.get(ghost_low, fi + 1), color = color.new(i_ghost_color, 50), width = 1, style = line.style_dashed))
            
    if i_show_score and n_found > 0
        color score_color = best_score >= 80.0 ? color.new(#00C853,10) : best_score >= 65.0 ? color.new(#FFD600,10) : color.new(#FF6D00,10)
        array.push(echo_labels, label.new(x = anchor_bar, y = high, text = "ECHO: " + str.tostring(math.round(best_score, 1)) + "%", color = score_color, textcolor = color.white, style = label.style_label_down, size = size.normal))

// =========================================================================
// SECTION 7: TRADE MANAGEMENT (ENTRY, STOP LOSS & TAKE PROFIT)
// =========================================================================
var box[]   trade_boxes  = array.new_box()
var line[]  trade_lines  = array.new_line()
var label[] trade_labels = array.new_label()
var float   alert_entry  = na
var float   alert_sl     = na
var float   alert_tp     = na

float atr_trade = ta.atr(14)

if do_update and not na(atr_trade) and atr_trade > 0.0
    int   n_found_t  = array.size(match_scores)
    
    int   trade_bias = n_found_t > 0 ? (avg_outcome > 0.0 ? 1 : avg_outcome < 0.0 ? -1 : 0) : 0
    
    float entry_price= close
    float entry_hi   = entry_price + atr_trade * i_entry_width
    float entry_lo   = entry_price - atr_trade * i_entry_width
    float sl_price   = trade_bias > 0 ? entry_price - atr_trade * i_sl_mult  : entry_price + atr_trade * i_sl_mult
    float tp1_price  = trade_bias > 0 ? entry_price + atr_trade * i_tp1_mult : entry_price - atr_trade * i_tp1_mult
    float tp2_price  = trade_bias > 0 ? entry_price + atr_trade * i_tp2_mult : entry_price - atr_trade * i_tp2_mult
    float tp3_price  = trade_bias > 0 ? entry_price + atr_trade * i_tp3_mult : entry_price - atr_trade * i_tp3_mult
    int   box_right  = anchor_bar + i_proj_len
    
    alert_entry := entry_price
    alert_sl    := sl_price
    alert_tp    := tp1_price

    int _bsz = array.size(trade_boxes)
    if _bsz > 0
        for i = 0 to _bsz - 1
            box.delete(array.get(trade_boxes, i))
    array.clear(trade_boxes)
    
    int _tlsz = array.size(trade_lines)
    if _tlsz > 0
        for i = 0 to _tlsz - 1
            line.delete(array.get(trade_lines, i))
    array.clear(trade_lines)
    
    int _labsz = array.size(trade_labels)
    if _labsz > 0
        for i = 0 to _labsz - 1
            label.delete(array.get(trade_labels, i))
    array.clear(trade_labels)

    if i_show_trade and trade_bias != 0
        array.push(trade_boxes, box.new(left = anchor_bar, top = entry_hi, right = box_right, bottom = entry_lo, bgcolor = color.new(i_entry_color, 80), border_color = color.new(i_entry_color, 20), border_width = 1))
        array.push(trade_labels, label.new(x = box_right, y = entry_price, text = "Entry " + str.tostring(entry_price, format.mintick), color = color.new(i_entry_color, 15), textcolor = color.black, style = label.style_label_left, size = size.small))
        
        array.push(trade_lines, line.new(anchor_bar, sl_price, box_right, sl_price, color=i_sl_color, width=2, style=line.style_solid))
        array.push(trade_labels, label.new(x = box_right, y = sl_price, text = "SL " + str.tostring(sl_price, format.mintick), color = color.new(i_sl_color, 15), textcolor = color.white, style = label.style_label_left, size = size.small))
        
        array.push(trade_lines, line.new(anchor_bar, tp1_price, box_right, tp1_price, color=i_tp_color, width=1, style=line.style_dashed))
        array.push(trade_labels, label.new(x = box_right, y = tp1_price, text = "TP1 " + str.tostring(tp1_price, format.mintick), color = color.new(i_tp_color, 30), textcolor = color.white, style = label.style_label_left, size = size.small))
        
        array.push(trade_lines, line.new(anchor_bar, tp2_price, box_right, tp2_price, color=i_tp_color, width=1, style=line.style_dashed))
        array.push(trade_labels, label.new(x = box_right, y = tp2_price, text = "TP2 " + str.tostring(tp2_price, format.mintick), color = color.new(i_tp_color, 15), textcolor = color.white, style = label.style_label_left, size = size.small))
        
        array.push(trade_lines, line.new(anchor_bar, tp3_price, box_right, tp3_price, color=i_tp_color, width=1, style=line.style_dashed))
        array.push(trade_labels, label.new(x = box_right, y = tp3_price, text = "TP3 " + str.tostring(tp3_price, format.mintick), color = color.new(i_tp_color, 0), textcolor = color.white, style = label.style_label_left, size = size.small))

bgcolor(barstate.islast and not i_freeze ? color.new(#7C4DFF, 97) : na, offset = -i_pattern_len, title = "Pattern Window")

// =========================================================================
// SECTION 8: DASHBOARD & STATISTICS TABLE
// =========================================================================
int   _n_found_dash  = array.size(match_scores)
float _best_score_d  = best_score
float _avg_outcome_d = avg_outcome
int   _bull_d        = bull_count
int   _bear_d        = bear_count
int   _neut_d        = neut_count
int   _total_d       = _bull_d + _bear_d + _neut_d

int   _bull_pct      = _total_d > 0 ? math.round(_bull_d / _total_d * 100) : 0
int   _bear_pct      = _total_d > 0 ? math.round(_bear_d / _total_d * 100) : 0
int   _neut_pct      = _total_d > 0 ? math.round(_neut_d / _total_d * 100) : 0

color _score_clr     = _best_score_d >= 80.0 ? color.new(#00C853,0) : _best_score_d >= 65.0 ? color.new(#FFD600,0) : color.new(#FF6D00,0)
string _score_lbl    = _best_score_d >= 80.0 ? "🟢 Strong" : _best_score_d >= 65.0 ? "🟡 Moderate" : "🟠 Weak"
string _score_val    = _n_found_dash > 0 ? str.tostring(math.round(_best_score_d, 1)) + "%  " + _score_lbl : "Searching..."

string _out_sym      = _avg_outcome_d > 0.0 ? "▲ +" : _avg_outcome_d < 0.0 ? "▼ " : "— "
color  _out_clr      = _avg_outcome_d > 0.0 ? color.new(#00C853,0) : _avg_outcome_d < 0.0 ? color.new(#F44336,0) : color.new(color.gray,20)
string _out_val      = _n_found_dash > 0 ? _out_sym + str.tostring(math.round(_avg_outcome_d, 2)) + "%" : "—"

string _bias_val     = _n_found_dash > 0 ? (_avg_outcome_d > 0.0 ? "🟢 Bullish" : _avg_outcome_d < 0.0 ? "🔴 Bearish" : "⚪ Neutral") : "—"
color  _bias_clr     = _avg_outcome_d > 0.0 ? color.new(#00C853,0) : _avg_outcome_d < 0.0 ? color.new(#F44336,0) : color.new(color.gray,20)
string _votes_val    = "▲" + str.tostring(_bull_pct) + "% ▼" + str.tostring(_bear_pct) + "% —" + str.tostring(_neut_pct) + "%"

var table dash = table.new(position = position.top_right, columns = 2, rows = 14, border_width = 1, border_color = i_tbl_border, frame_width = 1, frame_color = i_tbl_frame)

if i_show_table
    table.cell(dash, 0, 0, "🔮 ECHO " + clean_ticker, text_color=color.white, bgcolor=i_tbl_hdr_bg, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 0, "", text_color=color.white, bgcolor=i_tbl_hdr_bg, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 1, "Best Match", text_color=i_dim, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 1, _score_val, text_color=_score_clr, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 2, "Fingerprint", text_color=i_dim, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 2, str.tostring(i_pattern_len) + " bars", text_color=i_dim2, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 3, "Matches", text_color=i_dim, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 3, str.tostring(_n_found_dash) + " / " + str.tostring(i_top_matches), text_color=i_pur, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 4, "Avg Move", text_color=i_dim, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 4, _out_val, text_color=_out_clr, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 5, "Votes", text_color=i_dim, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 5, _votes_val, text_color=i_dim2, bgcolor=i_tbl_cell_bg2, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 6, "Proj Bias", text_color=i_dim, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 6, _bias_val, text_color=_bias_clr, bgcolor=i_tbl_cell_bg1, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 7, "Depth", text_color=color.new(color.gray,20), bgcolor=i_tbl_cell_bg3, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 7, str.tostring(i_search_depth) + " bars", text_color=color.new(color.gray,10), bgcolor=i_tbl_cell_bg3, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
    
    table.cell(dash, 0, 8, "Top Matches — Score / Move", text_color=i_pur, bgcolor=i_tbl_cell_hl, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 8, "", text_color=i_pur, bgcolor=i_tbl_cell_hl, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)

    int _msz = array.size(match_scores)
    int _cap = math.min(_msz, i_top_matches)
    if _cap > 0
        for mi = 0 to _cap - 1
            float ms = array.get(match_scores, mi)
            float mo = array.get(match_outcome, mi)
            int   mb = array.get(match_bars_ago, mi)
            
            string oc_sym = mo > 0.0 ? "▲ +" : mo < 0.0 ? "▼ " : "— "
            color  oc_clr = mo > 0.0 ? color.new(#69F0AE,0) : mo < 0.0 ? color.new(#FF8A80,0) : color.new(color.gray,20)
            
            table.cell(dash, 0, 9 + mi, "#" + str.tostring(mi+1) + "  " + str.tostring(math.round(ms,1)) + "%  (" + str.tostring(mb) + "b ago)", text_color=i_dim, bgcolor=i_tbl_cell_bg4, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
            table.cell(dash, 1, 9 + mi, oc_sym + str.tostring(math.round(mo,2)) + "%", text_color=oc_clr, bgcolor=i_tbl_cell_bg4, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)

// =========================================================================
// SECTION 9: ALERTS & WEBHOOK TRANSMISSION
// =========================================================================
bool _strong = best_score >= 80.0

if do_update and _strong
    if avg_outcome > 0.0
        string hook_payload = '{"action": "Buy", "symbol": "' + syminfo.ticker + '", "entry": ' + str.tostring(alert_entry, format.mintick) + ', "take_profit": ' + str.tostring(alert_tp, format.mintick) + ', "stop_loss": ' + str.tostring(alert_sl, format.mintick) + '}'
        alert(hook_payload, alert.freq_once_per_bar_close)
    else if avg_outcome < 0.0
        string hook_payload = '{"action": "Sell", "symbol": "' + syminfo.ticker + '", "entry": ' + str.tostring(alert_entry, format.mintick) + ', "take_profit": ' + str.tostring(alert_tp, format.mintick) + ', "stop_loss": ' + str.tostring(alert_sl, format.mintick) + '}'
        alert(hook_payload, alert.freq_once_per_bar_close)
    else
        string hook_payload = '{"action": "Neutral", "symbol": "' + syminfo.ticker + '", "message": "High-similarity pattern detected without clear bias."}'
        alert(hook_payload, alert.freq_once_per_bar_close)
````
