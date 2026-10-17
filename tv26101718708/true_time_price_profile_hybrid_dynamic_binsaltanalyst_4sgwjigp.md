# True Time Price Profile - Hybrid Dynamic Bins[ALT_analyst]

- url: https://www.tradingview.com/script/4SGwJIGP/
- type: indicator
- pine_id: PUB;b3cf4e44cdf24a188049dbb9f24b7593
- version: 3.0

## Description

[b]True Time Price Profile - Hybrid Dynamic Bins[ALT_analyst][/b]

[b]◆ NOTICE / DISCLAIMER[/b]
This architecture is NOT a standard Volume Profile (VP) or a conventional Time Price Opportunity (TPO) indicator. 
It is a highly advanced, multi-variable structural density engine.

It was specifically designed to mathematically extract institutional defense lines and localized price absorption in environments lacking reliable tick volume (e.g., Forex, CFD, Indices), 
functioning as a rigorous technical benchmark for supply/demand extraction.

[b]◆ EXECUTIVE SUMMARY[/b]
This script is deployed as a Proof of Concept (PoC) to demonstrate the integration of price absorption, time-based variance, 
and strict pro-rata energy distribution within a localized UI rendering environment. 

By discarding standard aggregation methods, this open-source architecture isolates the true "quality" of price stagnation, 
exposing anomalous market states where large capital defends specific price buckets.

[b]◆ ARCHITECTURE & QUANTITATIVE LOGIC[/b]
Standard profiles often struggle because they cannot distinguish between a "rapid vacuum passing" and a "defended consolidation." 
This engine utilizes three proprietary layers to resolve this logic gap:

[list=1]
[*][b]Pro-Rata Energy Distribution Engine[/b]
To prevent large-range bars (e.g., sudden momentum spikes) from artificially inflating the profile score across empty price vacuums, this script enforces a strict pro-rata allocation matrix. 

Let N_bins be the total number of price bins a single bar intersects. 
[b]The assigned value for each specific bin is calculated as:[/b]

[pine]Apportioned Value = Base Value / N_bins[/pine]

This completely neutralizes vacuum zones, correctly assigning mass only to true areas of conflict.

[*][b]Velocity & Acceleration (Absorption) Evaluator[/b]
Instead of counting volume, the script measures the deceleration of price action. 

It compares the high-low range of the current bar (v_curr) against the previous bar (v_prev). A negative acceleration (accel < 0) indicates kinetic energy is being absorbed by limit orders. 

This absolute delta is extracted as the base absorption value (|a|).

[*][b]Time Variance Logic (Market Memory)[/b]
A price level tested multiple times over a prolonged period holds significantly more structural integrity than a level tested only once. 

The engine applies the statistical variance of the normalized time index (t) to scale the [b]localized importance of a bin:[/b]

[pine]Variance (σ²) = (Sum of t² / n) - (Average t)²[/pine]

[b]The final Hybrid Score is the integration of absorbed energy scaled by the logarithmic variance:[/b]

[pine]Score = Sum( |a| * ln(1 + σ²) )[/pine]

[/list]

[image]https://www.tradingview.com/x/y70wgz3M/[/image]

[b]◆ PRACTICAL APPLICATION: HOW TO TRADE WITH THIS ENGINE[/b]
Instead of blindly treating every high-volume node as support/resistance, utilize this engine to identify [b]Structural Friction:[/b]

[list]
[*][b]Locating Hidden Institutional Limits:[/b]
Bins with exceptionally high Hybrid Scores often act as heavy liquidity pools.
Price action will typically stall or reverse sharply upon re-entering these zones.

[*][b]Breakout Validation:[/b]
If price breaks out of a Value Area (VA) without generating new high-score bins, it indicates a lack of limit-order resistance (a vacuum). 
These moves are prone to rapid continuation or swift mean-reversion sweeps.

[*][b]Cross-Session Node Alignment (Breakout Threshold):[/b]
By anchoring the profile to short, sequential sessions, observe if high-scoring nodes (POCs) align horizontally at the same price level across multiple independent profiles. 

This structural anomaly signifies a massive, sustained accumulation of limit orders. 
A decisive price breach of this specific alignment typically triggers a high-probability volatility breakout, as the defended liquidity pool is rapidly consumed.
[/list]

[b]◆ SYSTEM CAPABILITIES AND LIMITATIONS[/b]
[list]
[*][b]Visual Synthesis of Invisible Nodes:[/b]
Resolves precise support/resistance vectors purely from price action kinetics, independent of broker volume feeds.

[*][b]Dynamic Resolution Scaling:[/b]
The bin size is strictly tethered to the Average True Range (ATR), ensuring the profile grid automatically calibrates to the underlying asset's volatility regime.

[*][b]Limitations & Warnings:[/b]
TradingView enforces a strict cap of 500 max boxes/lines per indicator. To prevent script execution limits or array errors, the maximum lookback and bin count are dynamically capped.
Furthermore, if the scaled ATR drops to absolute zero, the geometric grid cannot initialize.
[/list]

[b]◆ INPUT PARAMETERS REFERENCE[/b]
[list]
[*][b]Live Update Frequency:[/b]
Toggle between 'Update on Every Tick' and 'Update on Bar Close'.
[i][b]CRITICAL WARNING:[/b] Using tick updates combined with multiple MTF arrays on a fast timeframe will cause localized UI lag. Use 'Bar Close' as a CPU saver.[/i]

[*][b]Profile Calculation Mode:[/b]
Select 'Classic' for standard aggregation, or 'Hybrid' to engage the Absorption + Variance matrix (The core edge of this tool).

[*][b]Grid Step Multiplier:[/b]
Lower values increase vertical resolution.
[i][b]Warning:[/b] Values below 0.05 on high-volatility assets may trigger the 500-box rendering limit.[/i]

[*][b]Show Debug Data Table:[/b]
Projects a live array matrix on the bottom right, displaying precise Price, Count, Absorption, Variance, and Hybrid Scores for absolute algorithmic transparency.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ALT_analyst
//@version=6
indicator('True Time Price Profile - Hybrid Dynamic Bins[ALT_analyst]', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ~~ Constants {
const string GRP_PERF = "Performance & Safety"
const string OPT_TICK = "Update on Every Tick"
const string OPT_CLOSE = "Update on Bar Close (CPU Saver)"
const string TITLE_LUM = "Live Update Frequency"
const string TT_LUM = "[IMPORTANT] Sets the recalculation frequency of the profile.\n- Every Tick: Updates in real-time as price moves (High load).\n- Bar Close: Updates only when the candle closes. Select this to drastically reduce lag if using multiple MTFs or experiencing a heavy chart."

const string GRP_CALC = "Calculation Engine"
const string OPT_CLASSIC = "Classic (Time/Count Only)"
const string OPT_HYBRID = "Hybrid (Absorption + Variance)"
const string TITLE_CALC = "Profile Calculation Mode"
const string TT_CALC = "[Classic]\nCounts simple price duration time similar to standard profiles.\n\n[Hybrid (Custom Logic)]\nMultiplies 'price velocity deceleration (Absorption)' by 'temporal variance (Variance)' at each price level to score large institutional limit orders and strong support/resistance zones. Visualizes the 'quality of duration' beyond mere volume."
const string TITLE_DBG = "Show Debug Data Table"
const string TT_DBG = "Displays internal calculation data (counts, absorption, variance, etc.) for the Hybrid score at the bottom right of the chart. Useful for verifying logic transparency and analyzing market psychology at specific price zones."

const string GRP_ANCHOR = "Anchor Settings"
const string OPT_FIXED = "Fixed Bars"
const string OPT_SESS = "Session"
const string OPT_MTF = "Multi-Timeframe"
const string TITLE_AMODE = "Anchor Mode"
const string TT_AMODE = "Sets the starting point for profile calculation.\n- Fixed Bars: Segments by the specified number of candles.\n- Session: Segments by a specified session (e.g., 1 day, 1 week).\n- Multi-Timeframe: Draws profiles anchored to the start of a specified higher timeframe."
const string TITLE_PLEN = "Profile Length (Fixed Bars)"
const string TT_PLEN = "Valid only when 'Fixed Bars' mode is selected. Looks back and segments the profile by the specified number of candles (e.g., 50)."
const string TITLE_ATF = "Session Timeframe"
const string TT_ATF = "Valid only when 'Session' mode is selected. Specifies the timeframe to reset the profile (D = reset daily, W = reset weekly)."

const string GRP_MTF = "MTF Settings"
const string TITLE_USE1 = ""
const string INL_TF1 = "tf1"
const string TT_USE1 = "Toggle MTF 1 ON/OFF"
const string TITLE_TF1 = "MTF 1"
const string TT_TF1 = "[For MTF Mode] Specifies the higher timeframe period to overlay on the current chart. (e.g., 240 = anchors profile to the open of the 4-hour candle)."
const string TITLE_USE2 = ""
const string INL_TF2 = "tf2"
const string TT_USE2 = "Toggle MTF 2 ON/OFF"
const string TITLE_TF2 = "MTF 2"
const string TT_TF2 = "[For MTF Mode] D = Anchors profile to the daily open."
const string TITLE_USE3 = ""
const string INL_TF3 = "tf3"
const string TT_USE3 = "Toggle MTF 3 ON/OFF"
const string TITLE_TF3 = "MTF 3"
const string TT_TF3 = "[For MTF Mode] W = Anchors profile to the weekly open."
const string TITLE_USE4 = ""
const string INL_TF4 = "tf4"
const string TT_USE4 = "Toggle MTF 4 ON/OFF"
const string TITLE_TF4 = "MTF 4"
const string TT_TF4 = "[For MTF Mode] M = Anchors profile to the monthly open."
const string TITLE_USE5 = ""
const string INL_TF5 = "tf5"
const string TT_USE5 = "Toggle MTF 5 ON/OFF"
const string TITLE_TF5 = "MTF 5"
const string TT_TF5 = "[For MTF Mode] 3M = Anchors profile to the quarterly open."

const string GRP_BASE = "Grid Settings"
const string TITLE_ALEN = "ATR Length for Grid"
const string TT_ALEN = "ATR (Average True Range) period used to determine the height of profile price bins. Bin height automatically adjusts to market volatility."
const string TITLE_SMULT = "Grid Step Multiplier"
const string TT_SMULT = "Multiplier applied to the ATR. Smaller values (e.g., 0.05) split price levels finer for higher resolution, but increase drawing boxes and calculation load."

const string GRP_VP = "Profile Settings"
const string OPT_LEFT = "Left"
const string OPT_RIGHT = "Right"
const string TITLE_PLC = "Placement"
const string TT_PLC = "Selects whether to draw the profile from the left or right side of the target period."
const string TITLE_WPERC = "Max Width (%)"
const string TT_WPERC = "Sets the maximum horizontal width of the highest scoring bin (POC) as a percentage of the total selected period width."
const string TITLE_VPERC = "Value Area (VA) %"
const string TT_VPERC = "Sets the percentage to be considered the Value Area (primary price zone where trading/scores are concentrated). Standard is 70%. Areas outside this will have higher transparency."
const string TITLE_SUNI = "Show Styled Unicode Digits"
const string TT_SUNI = "Displays score values inside the profile using highly visible custom bold fonts (Unicode replacement)."

const string GRP_LINES = "Line & Extension Settings"
const string TITLE_SPOC = "Show POC Line"
const string TT_SPOC = "Draws a horizontal line at the center of the highest scoring price bin (Point of Control). Functions as strong support/resistance."
const string TITLE_SVA = "Show VAH / VAL Lines"
const string TT_SVA = "Draws dotted lines at the upper (VAH) and lower (VAL) bounds of the Value Area."
const string OPT_NONE = "None"
const string OPT_LONLY = "Live Only"
const string OPT_ALL = "All"
const string TITLE_EXTM = "Show Extended Lines On"
const string TT_EXTM = "Sets whether to extend drawn lines (POC, VA) to the right. 'Live Only' extends only the latest currently forming profile."
const string OPT_INF = "Infinite"
const string OPT_MPROF = "Match Profile"
const string OPT_CUST = "Custom Fixed Bars"
const string TITLE_ELENM = "Extension Length"
const string TT_ELENM = "Sets how far to extend the lines.\n- Infinite: To infinity\n- Match Profile: Same length as the target profile period into the future\n- Custom Fixed Bars: Into the future by the specified number of candles below"
const string TITLE_ECUST = "Custom Extension Bars"
const string TT_ECUST = "The number of extension candles when 'Custom Fixed Bars' is selected above."

const string GRP_STYLE = "Style Settings"
const string OPT_AURORA = "Aurora"
const string OPT_TM = "Trademark Rainbow"
const string TITLE_CTHEME = "Color Theme"
const string TT_CTHEME = "Color coding theme for the profile. Gradient colors are applied based on the high/low of price zones."
const string TITLE_CKZ = "POC Highlight Color"
const string TT_CKZ = "Highlight color for the POC (highest scoring bin) line and border."
const string OPT_AUTO = "Auto"
const string OPT_TINY = "Tiny"
const string OPT_SMALL = "Small"
const string OPT_NORM = "Normal"
const string OPT_LARGE = "Large"
const string TITLE_TSIZE = "Text Size"
const string TT_TSIZE = "Size of the numeric text displayed inside the profile. 'Auto' adjusts automatically to bin height."
const string TITLE_CTEXT = "Text Color"
const string TT_CTEXT = "Color and transparency of the text inside the profile."

const string GRP_TBL = "Debug Table Settings"
const string TITLE_TBG = "Table Background Color"
const string TT_TBG = "Background color and transparency of the debug table."
const string TITLE_TBORD = "Table Border Color"
const string TT_TBORD = "Border color of the debug table."
const string TITLE_TTXT = "Standard Text Color"
const string TT_TTXT = "Standard text color inside the debug table."
const string TITLE_THL = "Highlight Color (POC & Scores)"
const string TT_THL = "Highlight color for the highest scoring row (POC) and the score column inside the debug table."
//~~~~~}

// ~~ Inputs {
string live_update_mode = input.string(OPT_TICK, TITLE_LUM, options=[OPT_TICK, OPT_CLOSE], group=GRP_PERF, tooltip=TT_LUM)

string calc_mode = input.string(OPT_HYBRID, TITLE_CALC, options=[OPT_CLASSIC, OPT_HYBRID], group=GRP_CALC, tooltip=TT_CALC)
bool show_debug_table = input.bool(true, TITLE_DBG, group=GRP_CALC, tooltip=TT_DBG)

string anchor_mode = input.string(OPT_FIXED, TITLE_AMODE, options=[OPT_FIXED, OPT_SESS, OPT_MTF], group=GRP_ANCHOR, tooltip=TT_AMODE)
int profile_len = input.int(50, TITLE_PLEN, group=GRP_ANCHOR, minval=10, maxval=5000, tooltip=TT_PLEN)
string anchor_tf = input.timeframe("D", TITLE_ATF, group=GRP_ANCHOR, tooltip=TT_ATF)

bool use_tf1 = input.bool(true, TITLE_USE1, inline=INL_TF1, group=GRP_MTF, tooltip=TT_USE1)
string tf1 = input.timeframe("240", TITLE_TF1, inline=INL_TF1, group=GRP_MTF, tooltip=TT_TF1)
bool use_tf2 = input.bool(true, TITLE_USE2, inline=INL_TF2, group=GRP_MTF, tooltip=TT_USE2)
string tf2 = input.timeframe("D", TITLE_TF2, inline=INL_TF2, group=GRP_MTF, tooltip=TT_TF2)
bool use_tf3 = input.bool(true, TITLE_USE3, inline=INL_TF3, group=GRP_MTF, tooltip=TT_USE3)
string tf3 = input.timeframe("W", TITLE_TF3, inline=INL_TF3, group=GRP_MTF, tooltip=TT_TF3)
bool use_tf4 = input.bool(true, TITLE_USE4, inline=INL_TF4, group=GRP_MTF, tooltip=TT_USE4)
string tf4 = input.timeframe("M", TITLE_TF4, inline=INL_TF4, group=GRP_MTF, tooltip=TT_TF4)
bool use_tf5 = input.bool(false, TITLE_USE5, inline=INL_TF5, group=GRP_MTF, tooltip=TT_USE5)
string tf5 = input.timeframe("3M", TITLE_TF5, inline=INL_TF5, group=GRP_MTF, tooltip=TT_TF5)

int atr_len = input.int(14, TITLE_ALEN, group=GRP_BASE, tooltip=TT_ALEN)
float step_mult = input.float(0.1, TITLE_SMULT, group=GRP_BASE, minval=0.01, step=0.01, tooltip=TT_SMULT)

string placement = input.string(OPT_LEFT, TITLE_PLC, options=[OPT_LEFT, OPT_RIGHT], group=GRP_VP, tooltip=TT_PLC)
int width_perc = input.int(80, TITLE_WPERC, group=GRP_VP, minval=10, maxval=100, tooltip=TT_WPERC)
int va_perc = input.int(70, TITLE_VPERC, group=GRP_VP, minval=1, maxval=100, tooltip=TT_VPERC)
bool show_unicode= input.bool(true, TITLE_SUNI, group=GRP_VP, tooltip=TT_SUNI)

bool show_poc = input.bool(true, TITLE_SPOC, group=GRP_LINES, tooltip=TT_SPOC)
bool show_va = input.bool(true, TITLE_SVA, group=GRP_LINES, tooltip=TT_SVA)
string extend_mode = input.string(OPT_LONLY, TITLE_EXTM, options=[OPT_NONE, OPT_LONLY, OPT_ALL], group=GRP_LINES, tooltip=TT_EXTM)
string ext_len_mode = input.string(OPT_MPROF, TITLE_ELENM, options=[OPT_INF, OPT_MPROF, OPT_CUST], group=GRP_LINES, tooltip=TT_ELENM)
int ext_custom = input.int(50, TITLE_ECUST, group=GRP_LINES, minval=1, maxval=5000, tooltip=TT_ECUST)

string color_theme = input.string(OPT_TM, TITLE_CTHEME, options=[OPT_AURORA, OPT_TM], group=GRP_STYLE, tooltip=TT_CTHEME)
color c_killzone = input.color(#00FA9A, TITLE_CKZ, group=GRP_STYLE, tooltip=TT_CKZ)
string text_size_in = input.string(OPT_AUTO, TITLE_TSIZE, options=[OPT_AUTO, OPT_TINY, OPT_SMALL, OPT_NORM, OPT_LARGE], group=GRP_STYLE, tooltip=TT_TSIZE)
color c_text = input.color(color.new(#FFFFFF, 40), TITLE_CTEXT, group=GRP_STYLE, tooltip=TT_CTEXT)

color c_tbl_bg = input.color(color.new(color.black, 60), TITLE_TBG, group=GRP_TBL, tooltip=TT_TBG)
color c_tbl_border = input.color(color.gray, TITLE_TBORD, group=GRP_TBL, tooltip=TT_TBORD)
color c_tbl_text = input.color(color.white, TITLE_TTXT, group=GRP_TBL, tooltip=TT_TTXT)
color c_tbl_hl = input.color(color.yellow, TITLE_THL, group=GRP_TBL, tooltip=TT_THL)
//~~~~~}

// ~~ Helpers {
f_get_aurora_color(float pct) =>
    color c = pct < 0.33 ? color.from_gradient(pct, 0.0, 0.33, #00FA9A, #00E5FF) : 
              pct < 0.66 ? color.from_gradient(pct, 0.33, 0.66, #00E5FF, #B388FF) : 
              color.from_gradient(pct, 0.66, 1.0, #B388FF, #FF4081)
    c

f_get_trademark_color(float pct) =>
    color c = pct < 0.2 ? color.from_gradient(pct, 0.0, 0.2, #FF0000, #FF7F00) : 
              pct < 0.4 ? color.from_gradient(pct, 0.2, 0.4, #FF7F00, #FFFF00) : 
              pct < 0.6 ? color.from_gradient(pct, 0.4, 0.6, #FFFF00, #00FF00) : 
              pct < 0.8 ? color.from_gradient(pct, 0.6, 0.8, #00FF00, #0000FF) : 
              color.from_gradient(pct, 0.8, 1.0, #0000FF, #8B00FF)
    c

f_get_color(float pct, string theme) =>
    theme == OPT_AURORA ? f_get_aurora_color(pct) : f_get_trademark_color(pct)

f_get_text_size(string s) =>
    s == OPT_TINY ? size.tiny : s == OPT_SMALL ? size.small : s == OPT_NORM ? size.normal : s == OPT_LARGE ? size.large : size.auto

f_to_unicode(int val) =>
    string str_val = str.tostring(val)
    string res = ""
    string[] normal = array.from("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
    string[] uni = array.from("𝟬", "𝟭", "𝟮", "𝟯", "𝟰", "𝟱", "𝟲", "𝟳", "𝟴", "𝟵")
    for i = 0 to str.length(str_val) - 1
        string char = str.substring(str_val, i, i + 1)
        int idx = array.indexof(normal, char)
        if idx >= 0
            res += array.get(uni, idx)
    res

f_is_valid_mtf(string target_tf, int limit) =>
    int current_sec = timeframe.in_seconds(timeframe.period)
    int target_sec = timeframe.in_seconds(target_tf)
    bool is_valid = current_sec > 0 and target_sec >= current_sec and (target_sec / current_sec) <= limit
    is_valid
//~~~~~}

// ~~ Calculation & Drawing {
int max_allowed_bars = timeframe.isseconds ? 500 : timeframe.isintraday ? 1000 : 5000
int dynamic_profile_len = math.min(profile_len, max_allowed_bars)
int dynamic_ext_custom  = math.min(ext_custom, max_allowed_bars)

var float[] global_debug_prices = array.new_float(0)
var float[] global_debug_counts = array.new_float(0)
var float[] global_debug_abs    = array.new_float(0)
var float[] global_debug_var    = array.new_float(0)
var float[] global_debug_scores = array.new_float(0)

f_draw_profile(int calc_start, int calc_end, bool is_live, float current_atr) =>
    int safe_start = math.max(calc_start, bar_index - (max_allowed_bars - 1))
    int end_offset = bar_index - calc_end
    int start_offset = bar_index - safe_start
    int dynamic_len = calc_end - safe_start + 1
    float bin_size = current_atr * step_mult
    
    box[] b_arr = array.new_box()
    line[] l_arr = array.new_line()
    
    float max_p = -1e10
    float min_p = 1e10
    for i = end_offset to start_offset
        max_p := math.max(max_p, high[i])
        min_p := math.min(min_p, low[i])
        
    float price_range = max_p - min_p
    
    if bin_size > 0
        int total_bins = math.round(price_range / bin_size) + 1
        if total_bins > 50
            total_bins := 50
            bin_size := price_range / 50
            
        float[] bin_abs_sum = array.new_float(total_bins, 0.0)
        float[] bin_t_sum   = array.new_float(total_bins, 0.0)
        float[] bin_t2_sum  = array.new_float(total_bins, 0.0)
        float[] bin_count   = array.new_float(total_bins, 0.0)
        float[] final_scores = array.new_float(total_bins, 0.0)
        float[] debug_variance = array.new_float(total_bins, 0.0)
        
        for i = end_offset to start_offset
            float v_curr = high[i] - low[i]
            float v_prev = (i + 1) <= start_offset ? (high[i+1] - low[i+1]) : v_curr
            float accel = v_curr - v_prev
            float abs_val = accel < 0 ? math.abs(accel) : 0.0
            
            int current_t = start_offset - i
            
            int low_idx  = math.max(0, math.min(total_bins - 1, int(math.floor((low[i] - min_p) / bin_size))))
            int high_idx = math.max(0, math.min(total_bins - 1, int(math.floor((high[i] - min_p) / bin_size))))
            
            int num_bins = high_idx - low_idx + 1
            float apportioned_abs   = abs_val / num_bins
            float apportioned_count = 1.0 / num_bins
            float apportioned_t     = current_t / num_bins
            float apportioned_t2    = (current_t * current_t) / num_bins
            
            for bin_idx = low_idx to high_idx
                array.set(bin_abs_sum, bin_idx, array.get(bin_abs_sum, bin_idx) + apportioned_abs)
                array.set(bin_count, bin_idx, array.get(bin_count, bin_idx) + apportioned_count)
                array.set(bin_t_sum, bin_idx, array.get(bin_t_sum, bin_idx) + apportioned_t)
                array.set(bin_t2_sum, bin_idx, array.get(bin_t2_sum, bin_idx) + apportioned_t2)
                    
        float total_score = 0.0
        float max_score = 0.0
        int poc_idx = 0
        
        for i = 0 to total_bins - 1
            float n = array.get(bin_count, i)
            float score = 0.0
            float variance = 0.0
            if n > 0
                if calc_mode == OPT_HYBRID
                    float t_sum = array.get(bin_t_sum, i)
                    float t2_sum = array.get(bin_t2_sum, i)
                    float mean_t = t_sum / n
                    variance := (t2_sum / n) - (mean_t * mean_t)
                    float total_abs = array.get(bin_abs_sum, i)
                    score := total_abs * math.log(1.0 + variance)
                else
                    score := n
                
            array.set(debug_variance, i, variance)
            array.set(final_scores, i, score)
            total_score += score
            
            if score > max_score
                max_score := score
                poc_idx := i
                
        if is_live and show_debug_table
            array.clear(global_debug_prices)
            array.clear(global_debug_counts)
            array.clear(global_debug_abs)
            array.clear(global_debug_var)
            array.clear(global_debug_scores)
            for i = 0 to total_bins - 1
                array.push(global_debug_prices, min_p + (i * bin_size))
                array.push(global_debug_counts, array.get(bin_count, i))
                array.push(global_debug_abs, array.get(bin_abs_sum, i))
                array.push(global_debug_var, array.get(debug_variance, i))
                array.push(global_debug_scores, array.get(final_scores, i))

        float target_va_score = total_score * (va_perc / 100.0)
        int va_high_idx = poc_idx
        int va_low_idx = poc_idx
        float current_va = max_score
        
        while current_va < target_va_score
            int up_idx = va_high_idx + 1
            int dn_idx = va_low_idx - 1
            float up_score = up_idx < total_bins ? array.get(final_scores, up_idx) : -1.0
            float dn_score = dn_idx >= 0 ? array.get(final_scores, dn_idx) : -1.0
            
            if up_score == -1.0 and dn_score == -1.0
                break
            if up_score >= dn_score
                current_va += up_score
                va_high_idx := up_idx
            else
                current_va += dn_score
                va_low_idx := dn_idx
                
        int max_width_bars = math.round((dynamic_len - 1) * (width_perc / 100.0))
        string chosen_size = f_get_text_size(text_size_in)
        
        for bin_idx = 0 to total_bins - 1
            float score = array.get(final_scores, bin_idx)
            if score > 0
                float b_bottom = min_p + (bin_idx * bin_size)
                float b_top = b_bottom + bin_size
                float vol_ratio = max_score > 0 ? score / max_score : 0
                int box_width = math.max(1, math.round(vol_ratio * max_width_bars))
                
                int b_left = placement == OPT_LEFT ? safe_start : calc_end - box_width
                int b_right = placement == OPT_LEFT ? b_left + box_width : calc_end
                
                float bin_center = (b_top + b_bottom) / 2.0
                float gradient_pos = price_range > 0 ? (bin_center - min_p) / price_range : 0.5
                color base_c = f_get_color(gradient_pos, color_theme)
                
                bool in_va = (bin_idx >= va_low_idx and bin_idx <= va_high_idx)
                int fill_transp = math.round(100 - (vol_ratio * 70))
                if not in_va
                    fill_transp := math.min(100, fill_transp + 35)
                    
                int border_transp = math.max(0, fill_transp - 20)
                bool is_poc = (bin_idx == poc_idx)
                color box_col = is_poc ? color.new(#FFFFFF, 10) : color.new(base_c, fill_transp)
                color border_col = is_poc ? c_killzone : color.new(base_c, border_transp)
                int b_width = is_poc ? 2 : 1
                
                float display_score = score
                if calc_mode == OPT_HYBRID
                    display_score := max_score > 0 ? (score / max_score) * 100.0 : 0.0
                
                int safe_score = math.min(math.round(display_score), 999)
                string u_str = show_unicode ? f_to_unicode(safe_score) : ""
                string align_h = placement == OPT_LEFT ? text.align_right : text.align_left
                
                box new_b = box.new(left = b_left, top = b_top, right = b_right, bottom = b_bottom, border_color = border_col, bgcolor = box_col, border_width = b_width, text = u_str, text_color = c_text, text_size = chosen_size, text_halign = align_h, text_valign = text.align_center)
                if is_live
                    array.push(b_arr, new_b)
                    
        bool should_extend = extend_mode == OPT_ALL or (extend_mode == OPT_LONLY and is_live)
        string line_ext = extend.none
        int line_end_x = calc_end
        
        int max_future_bar = bar_index + 500
        
        if should_extend
            if ext_len_mode == OPT_INF
                line_ext := extend.right
            else if ext_len_mode == OPT_MPROF
                line_end_x := math.min(calc_end + dynamic_len, max_future_bar)
            else if ext_len_mode == OPT_CUST
                line_end_x := math.min(calc_end + dynamic_ext_custom, max_future_bar)

        if show_poc
            float poc_y = min_p + (poc_idx * bin_size) + (bin_size / 2.0)
            line new_l1 = line.new(safe_start, poc_y, line_end_x, poc_y, color=c_killzone, width=2, extend=line_ext)
            if is_live
                array.push(l_arr, new_l1)
        if show_va
            float vah_y = min_p + (va_high_idx * bin_size) + bin_size
            float val_y = min_p + (va_low_idx * bin_size)
            line new_l2 = line.new(safe_start, vah_y, line_end_x, vah_y, color=color.new(#B2B5BE, 30), width=1, style=line.style_dashed, extend=line_ext)
            line new_l3 = line.new(safe_start, val_y, line_end_x, val_y, color=color.new(#B2B5BE, 30), width=1, style=line.style_dashed, extend=line_ext)
            if is_live
                array.push(l_arr, new_l2)
                array.push(l_arr, new_l3)
                
    [b_arr, l_arr]

float global_atr = ta.atr(atr_len)
bool is_new_sess = ta.change(time(anchor_tf)) != 0
var int sess_start = 0

if is_new_sess
    sess_start := bar_index

var int start_tf1 = 0
var int start_tf2 = 0
var int start_tf3 = 0
var int start_tf4 = 0
var int start_tf5 = 0

if ta.change(time(tf1)) != 0
    start_tf1 := bar_index
if ta.change(time(tf2)) != 0
    start_tf2 := bar_index
if ta.change(time(tf3)) != 0
    start_tf3 := bar_index
if ta.change(time(tf4)) != 0
    start_tf4 := bar_index
if ta.change(time(tf5)) != 0
    start_tf5 := bar_index

var box[] live_boxes = array.new_box()
var line[] live_lines = array.new_line()

bool trigger_live = live_update_mode == OPT_TICK ? barstate.islast : (barstate.islast and barstate.isconfirmed)

if trigger_live
    while array.size(live_boxes) > 0
        box.delete(array.shift(live_boxes))
    while array.size(live_lines) > 0
        line.delete(array.shift(live_lines))

if anchor_mode == OPT_FIXED
    if (bar_index + 1) % dynamic_profile_len == 0 and bar_index >= dynamic_profile_len - 1
        f_draw_profile(bar_index - dynamic_profile_len + 1, bar_index, false, global_atr[0])
        
    if trigger_live
        int elapsed = bar_index % dynamic_profile_len
        [b, l] = f_draw_profile(bar_index - elapsed, bar_index, true, global_atr[0])
        live_boxes := b
        live_lines := l
        
else if anchor_mode == OPT_SESS
    if is_new_sess and bar_index > 0
        f_draw_profile(sess_start[1], bar_index - 1, false, global_atr[1])
        
    if trigger_live
        [b, l] = f_draw_profile(sess_start, bar_index, true, global_atr[0])
        live_boxes := b
        live_lines := l

else if anchor_mode == OPT_MTF
    if trigger_live
        box[] all_b = array.new_box()
        line[] all_l = array.new_line()
        
        bool valid_tf1 = use_tf1 and f_is_valid_mtf(tf1, max_allowed_bars)
        bool valid_tf2 = use_tf2 and f_is_valid_mtf(tf2, max_allowed_bars)
        bool valid_tf3 = use_tf3 and f_is_valid_mtf(tf3, max_allowed_bars)
        bool valid_tf4 = use_tf4 and f_is_valid_mtf(tf4, max_allowed_bars)
        bool valid_tf5 = use_tf5 and f_is_valid_mtf(tf5, max_allowed_bars)

        int[] starts = array.from(
          valid_tf1 ? start_tf1 : 0, 
          valid_tf2 ? start_tf2 : 0, 
          valid_tf3 ? start_tf3 : 0, 
          valid_tf4 ? start_tf4 : 0, 
          valid_tf5 ? start_tf5 : 0
        )
        
        for s in starts
            if s > 0 
                [b, l] = f_draw_profile(s, bar_index, true, global_atr[0])
                for bx in b
                    array.push(all_b, bx)
                for ln in l
                    array.push(all_l, ln)
        
        live_boxes := all_b
        live_lines := all_l

var label status_label = na

if barstate.islast
    bool no_draw = array.size(live_boxes) == 0
    bool atr_too_small = (global_atr[0] * step_mult) <= 0.000001
    
    string warning_text = ""
    if atr_too_small
        warning_text := "NOTICE: Volatility (ATR) is near zero.\nCannot generate valid profile bins."
    else if no_draw
        warning_text := "NOTICE: Insufficient historical data or safety limit exceeded.\nPlease switch to a higher timeframe or adjust settings."
        
    if warning_text != ""
        if na(status_label)
            status_label := label.new(x = bar_index, y = close, text = warning_text, yloc = yloc.abovebar, color = color.new(#FF7043, 20), textcolor = color.white, style = label.style_label_down, size = size.normal)
        else
            label.set_xy(status_label, bar_index, close)
            label.set_text(status_label, warning_text)
    else
        if not na(status_label)
            label.delete(status_label)
            status_label := na

var table debug_tbl = table.new(position.bottom_right, 5, 21, border_width = 1, border_color = c_tbl_border, frame_width = 1, frame_color = c_tbl_border)

if trigger_live and show_debug_table
    
    float max_debug_score = -1.0
    int arr_size = array.size(global_debug_scores)
    for i = 0 to arr_size - 1
        float s = array.get(global_debug_scores, i)
        if s > max_debug_score
            max_debug_score := s

    table.cell(debug_tbl, 0, 0, "Price", bgcolor=c_tbl_bg, text_color=c_tbl_text, text_size=size.small)
    table.cell(debug_tbl, 1, 0, "Count", bgcolor=c_tbl_bg, text_color=c_tbl_text, text_size=size.small)
    table.cell(debug_tbl, 2, 0, "Abs(Σ)", bgcolor=c_tbl_bg, text_color=c_tbl_text, text_size=size.small)
    table.cell(debug_tbl, 3, 0, "Var(σ²)", bgcolor=c_tbl_bg, text_color=c_tbl_text, text_size=size.small)
    table.cell(debug_tbl, 4, 0, "Score", bgcolor=c_tbl_bg, text_color=c_tbl_hl, text_size=size.small)
    
    int row_idx = 1
    for i = 0 to arr_size - 1
        if row_idx > 20
            break
        float count_val = array.get(global_debug_counts, i)
        float current_score = array.get(global_debug_scores, i)
        
        if count_val > 0
            bool is_max = (current_score == max_debug_score and current_score > 0)
            color row_text_color = is_max ? c_tbl_hl : c_tbl_text
            
            table.cell(debug_tbl, 0, row_idx, str.tostring(array.get(global_debug_prices, i), "#.##"), text_color=row_text_color, text_size=size.small, bgcolor=c_tbl_bg)
            table.cell(debug_tbl, 1, row_idx, str.tostring(count_val, "#.##"), text_color=row_text_color, text_size=size.small, bgcolor=c_tbl_bg)
            table.cell(debug_tbl, 2, row_idx, str.tostring(array.get(global_debug_abs, i), "#.##"), text_color=row_text_color, text_size=size.small, bgcolor=c_tbl_bg)
            table.cell(debug_tbl, 3, row_idx, str.tostring(array.get(global_debug_var, i), "#.##"), text_color=row_text_color, text_size=size.small, bgcolor=c_tbl_bg)
            table.cell(debug_tbl, 4, row_idx, str.tostring(current_score, "#.##"), text_color=c_tbl_hl, text_size=size.small, bgcolor=c_tbl_bg)
            
            row_idx += 1
//~~~~~}
````
