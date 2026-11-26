# Smart ZigZag

- url: https://www.tradingview.com/script/a032aIHU/
- type: indicator
- pine_id: PUB;fa0498c74e1d4f3a89b88534a594d2a7
- version: 45.0

## Description

Its "Smart ZigZag" indicator for TradingView. 
It connects significant price highs and lows to filter out market noise, but unlike a standard ZigZag, it uses a statistical, volume-weighted approach to dynamically identify trend reversals.
Here is a detailed breakdown of what this script does:

1. Main Functions & Statistical Engine

Instead of using fixed percentages or points to find pivot points, this script uses Z-Score and Standard Deviation:
- Baseline Calculation: If the asset has trading volume, it calculates a Volume Weighted Average Price (VWAP) as a baseline. If there is no volume (like on some forex or crypto pairs), it automatically falls back to an ALMA (Arnaud Legoux Moving Average).
- Dynamic Volatility Threshold: It calculates the Standard Deviation of the price relative to that baseline. It multiplies this value by your Z-Score Threshold.
- Trend Filtering: A reversal (new ZigZag leg) is only triggered if the price deviates from the previous peak/trough by more than this dynamic statistical threshold.

2. Core Operational Logic

- Minimum Bar Count (Backstep): To prevent frequent, erratic trend shifts, the script enforces a rule that a specific number of candles (default: 14) must pass before a new trend direction can be confirmed.
- Peak and Trough Updating: While a trend continues in one direction (e.g., an uptrend), the indicator will continuously update and stretch the current line to the newest, highest high. It only locks in a permanent pivot point when a valid reversal occurs in the opposite direction.
- Array Management: It uses internal arrays (zz_values and zz_bars) to efficiently keep track of historical pivot prices and time coordinates.

3. Visuals and Customization

- Real-time Drawing: The script draws dynamic trend lines directly on the chart, using green for uptrends and red for downtrends by default.
- Informative Labels: At every major peak and trough, it places a text box. Depending on user settings, these labels display the exact price level, the percentage change from the previous pivot, or both.

Summary for Traders
This tool helps you see the underlying structure of market trends. Because it utilizes Standard Deviation, the indicator automatically widens its criteria during highly volatile periods (preventing false signals) and tightens them during quiet, consolidating markets.

## Source Code

````pine
//@version=6
indicator("Smart ZigZag PRO", overlay = true, max_labels_count = 500, max_lines_count = 500, max_bars_back = 400)

// ==========================================
// INPUTS & CONFIGURATION
// ==========================================
group_bs = "Manual Backstep Settings"
min_bs_manual = input.int(6, "Manual Min Backstep", minval = 1, group = group_bs)
max_bs_manual = input.int(36, "Manual Max Backstep", minval = 2, group = group_bs)

group_core = "Main Statistical Engine"
auto_tune   = input.bool(true, "Autotune Engine", group = group_core)
stdev_len_in = input.int(50, "Sample Period (fallback)", minval = 2, group = group_core)
z_threshold  = input.float(1.25, "Z-Score Threshold (fallback)", minval = 0.2, step = 0.05, group = group_core)

group_smooth = "Baseline Plot Smoothing (ALMA)"
smooth_len   = input.int(3, "ALMA Length", minval = 1, group = group_smooth)
smooth_offset= input.float(0.85, "ALMA Offset", minval = 0.0, maxval = 1.0, step = 0.05, group = group_smooth)
smooth_sigma = input.float(1.5, "ALMA Sigma", minval = 0.1, step = 0.1, group = group_smooth)

group_acf = "Autocorrelation Engine Settings"
windowInput = input.int(160, "ACF Sample Window", minval = 20, maxval = 400, group = group_acf)
lagInput    = input.int(2, "ACF Primary Lag", minval = 1, maxval = 50, group = group_acf)

group_norm = "Kinetic Normalization Settings"
norm_window = input.int(72, "Z-Score Normalization Window", minval = 10, maxval = 400, group = group_norm)

group_mtf = "Higher Timeframe (MTF) Filter"
use_mtf   = input.bool(false, "Enable MTF Filter", group = group_mtf)
mtf_tf    = input.timeframe("240", "Higher Timeframe (e.g. 4H)", group = group_mtf)

group_tp = "Take Profit & Kinetic Empirical Engine"
show_tp    = input.bool(true, "Show TP Lines & Probabilities", group = group_tp)
tp1_on     = input.bool(true, "Enable TP1", group = group_tp)
tp2_on     = input.bool(true, "Enable TP2", group = group_tp)
tp3_on     = input.bool(false, "Enable TP3", group = group_tp)
tp_sample  = input.int(104, "Historical Sample Size (Pivots)", minval = 10, maxval = 400, group = group_tp)
mult_tp1    = input.float(1.5, "TP1 Multiplier (fallback)", minval = 0.1, step = 0.1, group = group_tp)
mult_tp2    = input.float(2.0, "TP2 Multiplier (fallback)", minval = 0.1, step = 0.1, group = group_tp)
mult_tp3    = input.float(2.5, "TP3 Multiplier (fallback)", minval = 0.1, step = 0.1, group = group_tp)

group_tp_prev = "Previous Pivot TP Projections (Grey)"
show_prev_tp   = input.bool(true, "Show Previous TP Lines", group = group_tp_prev)
prev_tp1_on    = input.bool(true, "Enable Previous TP1", group = group_tp_prev)
prev_tp2_on    = input.bool(false, "Enable Previous TP2", group = group_tp_prev)
prev_tp3_on    = input.bool(false, "Enable Previous TP3", group = group_tp_prev)

group_lines = "Projection Vertical Lines"
show_pv_lines   = input.bool(true, "Show Projection Lines", group = group_lines)
line_col_est    = input.color(color.blue, "Estimated Line Color", group = group_lines)
line_style_est  = input.string("Solid", "Estimated Line Style", options = ["Solid", "Dotted", "Dashed"], group = group_lines)
line_thick_est  = input.int(2, "Estimated Line Thickness", minval = 1, group = group_lines)
line_col_max    = input.color(#ce7b00, "Max Window Line Color", group = group_lines)
line_style_max  = input.string("Solid", "Max Window Line Style", options = ["Solid", "Dotted", "Dashed"], group = group_lines)
line_thick_max  = input.int(2, "Max Window Line Thickness", minval = 1, group = group_lines)

group_visual = "Appearance and Labels"
display_opt = input.string("Both (Price & %)", "Label Data", options = ["Price Only", "% Only", "STR/Level", "Both (Price & %)", "Price, % & STR/Level", "Hide Text"], group = group_visual)
upcolor   = input.color(color.green, "Up Color", group = group_visual)
downcolor = input.color(color.red, "Down Color", group = group_visual)
txtcol    = input.color(color.white, "Text Color", group = group_visual)
zigstyle  = input.string("Solid", "Line Style", options = ["Solid", "Dotted", "Dashed"], group = group_visual)
zigwidth  = input.int(2, "Line Thickness", minval = 1, group = group_visual)

marker_color_buy  = input.color(color.green, "Marker BUY Color", group = group_visual)
marker_color_sell = input.color(color.red,   "Marker SELL Color", group = group_visual)
marker_size_input = input.string("Large", "Marker Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = group_visual)
marker_size = (marker_size_input == "Tiny" ? size.tiny : marker_size_input == "Small" ? size.small : marker_size_input == "Normal" ? size.normal : marker_size_input == "Large" ? size.large : size.huge)

group_dash = "Dashboard Settings"
show_dash  = input.bool(true, "Show Dashboard", group = group_dash)
dash_pos   = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = group_dash)
dash_size  = input.int(11, "Table Font Size (px)", minval = 8, maxval = 48, group = group_dash)
dash_base_color = input.color(color.gray, "Dashboard Base Cell Color", group = group_dash)

pb_color   = input.color(color.white, "Progress Bar Color", group = group_dash)
dash_red   = input.color(color.red, "Dashboard Impulse Color", group = group_dash)
dash_green = input.color(color.green, "Dashboard Locked Color", group = group_dash)

sl_line_color = input.color(color.white, "SL Line Color", group = group_dash)
sl_line_len   = input.int(8, "SL Line Length (Bars)", minval = 1, maxval = 10, group = group_dash)

// ==========================================
// MTF TIME-RATIO SCALING
// ==========================================
float tf_sec = timeframe.in_seconds(timeframe.period)
float mtf_sec = timeframe.in_seconds(mtf_tf)
float raw_tf_ratio = mtf_sec > tf_sec ? mtf_sec / tf_sec : 1.0
float tf_ratio = use_mtf ? math.max(1.0, raw_tf_ratio) : 1.0

// ==========================================
// HELPER FUNCTIONS & VOLATILITY CORE
// ==========================================
EPSILON = 1e-12

truncate(float val, int decimals) =>
    factor = math.pow(10, decimals)
    math.round(val * factor) / factor

percent(float n1, float n2) =>
    n2 == 0.0 or na(n2) ? 0.0 : (n1 - n2) / n2 * 100

get_line_style(string s) =>
    switch s
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

get_dash_pos(string p) =>
    switch p
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

erf(x) =>
    float t = 1.0 / (1.0 + 0.5 * math.abs(x))
    float ans = 1.0 - t * math.exp(-x * x - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.01862880 + t * (0.02788680 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277)))))))))
    x >= 0 ? ans : -ans

normCDF(z) =>
    0.5 * (1.0 + erf(z / math.sqrt(2.0)))

float prev_close = nz(close[1], open)
float effHigh = math.max(high, prev_close)
float effLow  = math.max(math.min(low, prev_close), 0.00000001)

float GK_COEF = 2.0 * math.log(2.0) - 1.0

float overnightReturn = 100.0 * math.log(open / prev_close)
float overnightVariance = math.pow(overnightReturn, 2.0)

float log_h_l = 100.0 * math.log(effHigh / effLow)
float log_c_o = open > 0 ? 100.0 * math.log(close / open) : 0.0

float gk_core = 0.5 * math.pow(log_h_l, 2.0) - GK_COEF * math.pow(log_c_o, 2.0)

float log_h_c = 100.0 * math.log(effHigh / close)
float log_h_o = 100.0 * math.log(effHigh / open)
float log_l_c = 100.0 * math.log(effLow / close)
float log_l_o = open > 0 ? 100.0 * math.log(effLow / open) : 0.0

float rs_core = log_h_c * log_h_o + log_l_c * log_l_o

float intradayVariance = (math.max(gk_core, 0.0) + math.max(rs_core, 0.0)) / 2.0
float hybrid_element = (0.5 * overnightVariance) + (0.5 * intradayVariance)

float hybrid_volatility_pct = math.sqrt(math.max(hybrid_element, 0.0))
float finalVolatilityPct = math.max(hybrid_volatility_pct, 0.01)

float midPoint = (open + prev_close) / 2.0
float priceImbalancePct = 100.0 * math.log(close / midPoint)

float c_z_score = priceImbalancePct / finalVolatilityPct
float directionWeight = normCDF(c_z_score)

// ==========================================
// PARABOLIC POC (CENTROID) ENGINE
// ==========================================
float candleSpread = math.abs(close - open)
float candleRange = high - low
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float totalWicks = upperWick + lowerWick
float midCandle = (high + low) / 2.0

float closePosition = candleRange > 0.0 ? (close - low) / candleRange : 0.5
float volumeFlowDirection = (closePosition - 0.5) * 2.0
float p_momentum = (close - open) / math.max(candleSpread, 0.00000001)
float knotAsymmetry = totalWicks > 0.0 ? (lowerWick - upperWick) / totalWicks : 0.0
float gravityShift = (volumeFlowDirection * 0.3) + (knotAsymmetry * 0.15) + (p_momentum * 0.05)
float parabolicPOCFactor = 0.5 + math.max(-0.45, math.min(0.45, gravityShift))
float parabolicCentroid = low + (candleRange * parabolicPOCFactor)
float candleCentroid = candleRange > 0.0 ? parabolicCentroid : midCandle

var array<float> gkyz_history = array.new_float()
array.unshift(gkyz_history, candleCentroid)
if array.size(gkyz_history) > 400
    array.pop(gkyz_history)

// ==========================================
// DYNAMIC GAUSSIAN / ALMA & GAUSSIAN CLUSTER ENGINE
// ==========================================
f_alma_dynamic(array<float> src_arr, int length, float offset, float sigma) =>
    float sum = 0.0
    float wsum = 0.0
    int eff_len = math.min(length, src_arr.size())
    if eff_len > 0            
        float m = (1.0 - offset) * (eff_len - 1)
        float s = eff_len / sigma
        for i = 0 to eff_len - 1
            float val = src_arr.get(i)
            float w = math.exp(-math.pow(i - m, 2) / (2.0 * math.pow(s, 2.0)))
            wsum += w
            sum += val * w
        wsum > 0 ? sum / wsum : src_arr.get(0)
    else
        na

f_gaussian_cluster(array<float> arr, float min_val, float max_val) =>
    float sum_val = 0.0
    float count_val = 0.0
    int size_arr = array.size(arr)
    
    if size_arr > 0
        for i = 0 to size_arr - 1
            float val = array.get(arr, i)
            if val >= min_val and val <= max_val
                sum_val += val
                count_val += 1.0
                
    float mean_val = count_val > 0 ? sum_val / count_val : (min_val + max_val) / 2.0
    
    float w_sum = 0.0
    float weighted_sum = 0.0
    float var_sum = 0.0
    
    if count_val > 1
        for i = 0 to size_arr - 1
            float val = array.get(arr, i)
            if val >= min_val and val <= max_val
                var_sum += math.pow(val - mean_val, 2.0)
        float stdev_val = math.sqrt(var_sum / (count_val - 1.0))
        
        if stdev_val > 0.000001
            for i = 0 to size_arr - 1
                float val = array.get(arr, i)
                if val >= min_val and val <= max_val
                    float w = math.exp(-math.pow(val - mean_val, 2.0) / (2.0 * math.pow(stdev_val, 2.0)))
                    w_sum += w
                    weighted_sum += val * w
            w_sum > 0 ? weighted_sum / w_sum : mean_val
        else
            mean_val
    else
        mean_val

// ==========================================
// VOLATILITY & DUAL DYNAMIC ALMA CALCULATIONS
// ==========================================
has_volume = not na(volume) and ta.cum(volume) > 0
int base_stdev_len = auto_tune ? math.round(2 * max_bs_manual) : stdev_len_in
int stdev_len = math.round(base_stdev_len * tf_ratio)

var float norm_vol = 0.5
float dyn_vol_state = nz(norm_vol[1], 0.5)

float dyn_offset = 0.50 + (0.50 * dyn_vol_state)
float dyn_sigma  = 1.00 + (2.00 * dyn_vol_state)

calculate_statistical_baseline(int length, float eff_offset, float eff_sigma) =>
    float _baseline = na
    float _vwap_stdev = na
    float _vol_comb = 0.0
   
    int eff_len = math.min(length, bar_index + 1)
   
    if eff_len >= 2
        float m_l = (1.0 - eff_offset) * (eff_len - 1)
        float s_l = eff_len / eff_sigma
       
        float w_sum = 0.0
        float v_gkyz_vol_sum = 0.0
        float v_vol_sum = 0.0
       
        if has_volume
            for i = 0 to eff_len - 1
                float gkyz_val = i < gkyz_history.size() ? gkyz_history.get(i) : candleCentroid
                float w = math.exp(-math.pow(i - m_l, 2.0) / (2.0 * math.pow(s_l, 2.0)))
                w_sum += w
                v_gkyz_vol_sum += (nz(gkyz_val, candleCentroid) * nz(volume[i], 1.0)) * w
                v_vol_sum += nz(volume[i], 1.0) * w
               
            _baseline := v_vol_sum > 0 ? v_gkyz_vol_sum / v_vol_sum : candleCentroid
            _vol_comb := w_sum > 0 ? v_vol_sum / w_sum : 1.0
           
            float v_dev_vol_sum = 0.0
            for i = 0 to eff_len - 1
                float gkyz_val = i < gkyz_history.size() ? gkyz_history.get(i) : candleCentroid
                float w = math.exp(-math.pow(i - m_l, 2.0) / (2.0 * math.pow(s_l, 2.0)))
                float dev_sq_vol = math.pow(nz(gkyz_val, candleCentroid) - _baseline, 2.0) * nz(volume[i], 1.0)
                v_dev_vol_sum += dev_sq_vol * w
            _vwap_stdev := math.sqrt(v_dev_vol_sum / math.max(v_vol_sum, 1.0))
        else
            _baseline := f_alma_dynamic(gkyz_history, eff_len, eff_offset, eff_sigma)
           
            float v_dev_sum = 0.0
            float w_sum_dev = 0.0
            for i = 0 to eff_len - 1
                float gkyz_val = i < gkyz_history.size() ? gkyz_history.get(i) : candleCentroid
                float w = math.exp(-math.pow(i - m_l, 2.0) / (2.0 * math.pow(s_l, 2.0)))
                w_sum_dev += w
                float dev_sq = math.pow(nz(gkyz_val, candleCentroid) - _baseline, 2.0)
                v_dev_sum += dev_sq * w
            _vwap_stdev := math.sqrt(w_sum_dev > 0 ? v_dev_sum / w_sum_dev : 0.0)
    else
        _baseline := candleCentroid
        _vwap_stdev := 0.0
        _vol_comb := 1.0

    if na(_vwap_stdev) or _vwap_stdev == 0
        _vwap_stdev := ta.stdev(candleCentroid, math.max(2, eff_len))
       
    [_baseline, _vwap_stdev, _vol_comb]

[raw_my_baseline, vwap_stdev, alma_vol_for_comb] = calculate_statistical_baseline(stdev_len, dyn_offset, dyn_sigma)

int short_stdev_len = math.max(3, math.round(stdev_len * (math.sqrt(stdev_len)/stdev_len)))
[fast_baseline, f_vwap_stdev, f_alma_vol] = calculate_statistical_baseline(short_stdev_len, dyn_offset, dyn_sigma)

float combined_volatility =
     na(raw_my_baseline) or raw_my_baseline == 0.0 ? 0.0 :
     has_volume and not na(volume) ?
         ((vwap_stdev / raw_my_baseline) * 100) * (volume / math.max(alma_vol_for_comb, 1.0)) :
         (vwap_stdev / raw_my_baseline) * 100

float vol_mean = na

if bar_index >= 200
    float target_center = stdev_len / 2.0
    float dynamic_offset_vol = target_center / 200.0
    float m = dynamic_offset_vol * 199.0
    float s = 200.0 / 5.0
    float w_sum = 0.0
    float v_sum = 0.0
   
    for i = 0 to 199
        float w = math.exp(-math.pow(i - m, 2.0) / (2.0 * math.pow(s, 2.0)))
        v_sum += combined_volatility[i] * w
        w_sum += w
       
    vol_mean := w_sum > 0 ? v_sum / w_sum : combined_volatility
else
    vol_mean := f_alma_dynamic(gkyz_history, math.max(1, bar_index + 1), dyn_offset, dyn_sigma)

vol_stdev   = ta.stdev(combined_volatility, 200)
vol_z_score = not na(vol_stdev) and vol_stdev > 0.0 ? (combined_volatility - vol_mean) / vol_stdev : 0.0

var float vol_skew = 0
if auto_tune and bar_index >= 200
    float sum_cubed = 0
    for i = 0 to 199
        d = combined_volatility[i] - vol_mean
        sum_cubed += d * d * d
    vol_skew := vol_stdev > 0 ? (sum_cubed / 200) / math.pow(vol_stdev, 3) : 0

norm_vol := 1.0 / (1.0 + math.exp(-vol_z_score))

// ==========================================
// AUTOCORRELATION ENGINE
// ==========================================
acfLag(array<float> sample, int lag) =>
    int sampleSize = sample.size()
    float rLag = na
    if sampleSize >= lag + 2
        float sampleMean = sample.avg()
        float sumSquares = 0.0
        for i = 0 to sampleSize - 1
            float deviation = sample.get(i) - sampleMean
            sumSquares += deviation * deviation
        float sumProducts = 0.0
        for i = 0 to sampleSize - lag - 1
            sumProducts += (sample.get(i) - sampleMean) * (sample.get(i + lag) - sampleMean)
        rLag := sumSquares > EPSILON ? sumProducts / sumSquares : na
    rLag

float logReturn = 100 * math.log(close / nz(close[1], close))
var array<float> sampleArray = array.new_float()

if not na(logReturn)
    array.push(sampleArray, logReturn)
    int eff_windowInput = math.round(windowInput * tf_ratio)
    if array.size(sampleArray) > eff_windowInput
        array.shift(sampleArray)

int sampleCount = array.size(sampleArray)
float bandValue = sampleCount > 0 ? 2 / math.sqrt(sampleCount) : na
float acfValue = acfLag(sampleArray, lagInput)

float acf_abs = na(acfValue) ? 0.0 : math.abs(acfValue)
float acf_boost = na(bandValue) ? 0.5 : math.min(1.0, acf_abs / math.max(bandValue * 2.0, 0.0001))

float a_max = 6.81
float a_min = 4.15
float a_dynamic = a_min + (a_max - a_min) * (norm_vol * math.min(1.0, math.abs(vol_skew)))
float a         = math.max(a_min, math.min(a_max, a_dynamic))

float b_base = 0.5
float k_b    = 0.15
float b_raw  = b_base - (k_b * vol_skew)
float b      = math.max(0.2, math.min(0.8, b_raw))

probability_deviation = 1.0 / (1.0 + math.exp(-a * (norm_vol - b)))

float smart_min_bs = min_bs_manual * tf_ratio
float smart_max_bs = max_bs_manual * tf_ratio

int adaptive_backstep = math.round(smart_max_bs - probability_deviation * (smart_max_bs - smart_min_bs))
float final_z_threshold = auto_tune ? probability_deviation : z_threshold
float dynamic_threshold = vwap_stdev * final_z_threshold

f_mtf_trend() =>
    float htf_fast = f_alma_dynamic(gkyz_history, 16, 0.8, 5)
    float htf_slow = f_alma_dynamic(gkyz_history, 32, 0.8, 5)    
    htf_fast > htf_slow ? 1.0 : htf_fast < htf_slow ? -1.0 : 0.0

float mtf_val_raw = request.security(syminfo.tickerid, mtf_tf, f_mtf_trend(), barmerge.gaps_off, barmerge.lookahead_off)
float mtf_val = nz(mtf_val_raw, 0.0)

string mtf_trend_str = mtf_val == 1 ? "Bullish (MTF)" : mtf_val == -1 ? "Bearish (MTF)" : "Neutral (MTF)"
color mtf_trend_col  = mtf_val == 1 ? dash_green : mtf_val == -1 ? dash_red : dash_base_color

// ==========================================
// ZIGZAG + PIVOT SEARCH ENGINE
// ==========================================
var float[] zz_values = array.new_float()
var int[]   zz_bars   = array.new_int()
var line[]  zz_lines  = array.new_line()
var label[] zz_labels = array.new_label()
var int dir = 0

if bar_index == 0
    array.unshift(zz_values, close)
    array.unshift(zz_bars, bar_index)

float last_zz_val = array.get(zz_values, 0)
int last_zz_bar = array.get(zz_bars, 0)

int adaptive_backstep_clamped = math.max(1, nz(adaptive_backstep, 1))
bool can_switch = (bar_index - last_zz_bar) >= adaptive_backstep_clamped
bool is_new_pivot = false
bool pivot_updated = false  

bool mtf_allow_up   = not use_mtf or (mtf_val == 1)
bool mtf_allow_down = not use_mtf or (mtf_val == -1)

float initial_zz_val = last_zz_val
int initial_dir = dir
int entry_bar = last_zz_bar
float noise_buffer = dynamic_threshold * 0.2

if dir == 0
    if high > last_zz_val + dynamic_threshold and can_switch and mtf_allow_up
        dir := 1
        array.unshift(zz_values, high)
        array.unshift(zz_bars, bar_index)
        is_new_pivot := true
        pivot_updated := true
    else if low < last_zz_val - dynamic_threshold and can_switch and mtf_allow_down
        dir := -1
        array.unshift(zz_values, low)
        array.unshift(zz_bars, bar_index)
        is_new_pivot := true
        pivot_updated := true
else if dir == 1
    if high > last_zz_val
        array.set(zz_values, 0, high)
        array.set(zz_bars, 0, bar_index)
        pivot_updated := true  
    else if low < last_zz_val - dynamic_threshold and can_switch and mtf_allow_down
        dir := -1
        array.unshift(zz_values, low)
        array.unshift(zz_bars, bar_index)
        is_new_pivot := true
        pivot_updated := true
else if dir == -1
    if low < last_zz_val
        array.set(zz_values, 0, low)
        array.set(zz_bars, 0, bar_index)
        pivot_updated := true  
    else if high > last_zz_val + dynamic_threshold and can_switch and mtf_allow_up
        dir := 1
        array.unshift(zz_values, high)
        array.unshift(zz_bars, bar_index)
        is_new_pivot := true
        pivot_updated := true

plot(candleCentroid, title="Parabolic POC (Centroid)", color = close > candleCentroid ? color.green : color.red, linewidth = 1, style = plot.style_line)

// ==========================================
// TAKE PROFIT & HISTORICAL AMPLITUDES
// ==========================================
var array<float> weighted_amps = array.new_float()
var array<float> sorted_amps  = array.new_float()

if is_new_pivot and array.size(zz_values) >= 3
    float prev_amplitude = math.abs(array.get(zz_values, 1) - array.get(zz_values, 2))
    array.unshift(weighted_amps, prev_amplitude)
    if array.size(weighted_amps) > tp_sample
        array.pop(weighted_amps)

sorted_amps := array.copy(weighted_amps)
array.sort(sorted_amps, order.ascending)
int sorted_size = array.size(sorted_amps)

float amp_tp1 = vwap_stdev * mult_tp1
float amp_tp2 = vwap_stdev * mult_tp2
float amp_tp3 = vwap_stdev * mult_tp3

if sorted_size > 10 and array.size(weighted_amps) > 10
    float amp_min_tp1 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.20)))
    float amp_max_tp1 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.40)))

    float amp_min_tp2 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.40)))
    float amp_max_tp2 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.70)))

    float amp_min_tp3 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.70)))
    float amp_max_tp3 = array.get(sorted_amps, math.min(sorted_size - 1, int(sorted_size * 0.90)))

    amp_tp1 := not na(amp_min_tp1) and amp_max_tp1 > amp_min_tp1 ? f_gaussian_cluster(weighted_amps, amp_min_tp1, amp_max_tp1) : amp_min_tp1
    amp_tp2 := not na(amp_min_tp2) and amp_max_tp2 > amp_min_tp2 ? f_gaussian_cluster(weighted_amps, amp_min_tp2, amp_max_tp2) : amp_min_tp2
    amp_tp3 := not na(amp_min_tp3) and amp_max_tp3 > amp_min_tp3 ? f_gaussian_cluster(weighted_amps, amp_min_tp3, amp_max_tp3) : amp_min_tp3

float base_price = array.size(zz_values) > 0 ? array.get(zz_values, 0) : close

float tp1_price = dir == -1 ? base_price + amp_tp1 : base_price - amp_tp1
float tp2_price = dir == -1 ? base_price + amp_tp2 : base_price - amp_tp2
float tp3_price = dir == -1 ? base_price + amp_tp3 : base_price - amp_tp3 

f_calc_probability(float[] arr, float target_amp) =>
    int total = array.size(arr)
    if total == 0
        50.0
    else
        int hits = 0
        for i = 0 to total - 1
            if array.get(arr, i) >= target_amp
                hits += 1
        (float(hits) / float(total)) * 100.0

float hist_prob_tp1 = sorted_size > 10 ? f_calc_probability(weighted_amps, amp_tp1) : 50.0
float hist_prob_tp2 = sorted_size > 10 ? f_calc_probability(weighted_amps, amp_tp2) : 25.0
float hist_prob_tp3 = sorted_size > 10 ? f_calc_probability(weighted_amps, amp_tp3) : 10.0

var line tp1_line = line.new(na, na, na, na, color = color.blue, style = line.style_dashed)
var line tp2_line = line.new(na, na, na, na, color = color.purple, style = line.style_dashed)
var line tp3_line = line.new(na, na, na, na, color = #db8400, style = line.style_dashed)

var label tp1_lbl = label.new(na, na, "", color = color.blue, textcolor = color.white, style = label.style_label_left, size = size.normal)
var label tp2_lbl = label.new(na, na, "", color = color.purple, textcolor = color.white, style = label.style_label_left, size = size.normal)
var label tp3_lbl = label.new(na, na, "", color = #db8400, textcolor = color.white, style = label.style_label_left, size = size.normal)

if show_tp and barstate.islast and not na(base_price)
    int draw_start_bar = nz(entry_bar, bar_index)
    
    // TP1 Render
    if tp1_on
        line.set_xy1(tp1_line, draw_start_bar, tp1_price)
        line.set_xy2(tp1_line, bar_index + 3, tp1_price)
        label.set_xy(tp1_lbl, bar_index + 3, tp1_price)
        label.set_text(tp1_lbl, "TP1(" + str.tostring(hist_prob_tp1, "#") + "%): " + str.tostring(truncate(tp1_price, 2)))
    else
        line.set_xy1(tp1_line, na, na)
        line.set_xy2(tp1_line, na, na)
        label.set_xy(tp1_lbl, na, na)
   
    // TP2 Render
    if tp2_on
        line.set_xy1(tp2_line, draw_start_bar, tp2_price)
        line.set_xy2(tp2_line, bar_index + 3, tp2_price)
        label.set_xy(tp2_lbl, bar_index + 3, tp2_price)
        label.set_text(tp2_lbl, "TP2(" + str.tostring(hist_prob_tp2, "#") + "%): " + str.tostring(truncate(tp2_price, 2)))
    else
        line.set_xy1(tp2_line, na, na)
        line.set_xy2(tp2_line, na, na)
        label.set_xy(tp2_lbl, na, na)
   
    // TP3 Render
    if tp3_on
        line.set_xy1(tp3_line, draw_start_bar, tp3_price)
        line.set_xy2(tp3_line, bar_index + 3, tp3_price)
        label.set_xy(tp3_lbl, bar_index + 3, tp3_price)
        label.set_text(tp3_lbl, "TP3(" + str.tostring(hist_prob_tp3, "#") + "%): " + str.tostring(truncate(tp3_price, 2)))
    else
        line.set_xy1(tp3_line, na, na)
        line.set_xy2(tp3_line, na, na)
        label.set_xy(tp3_lbl, na, na)

// PREVIOUS PIVOT TP PROJECTIONS
var line prev_tp1_line = line.new(na, na, na, na, color = color.new(color.gray, 50), style = line.style_dotted)
var line prev_tp2_line = line.new(na, na, na, na, color = color.new(color.gray, 50), style = line.style_dotted)
var line prev_tp3_line = line.new(na, na, na, na, color = color.new(color.gray, 50), style = line.style_dotted)

var label prev_tp1_lbl = label.new(na, na, "", color = color.new(color.gray, 50), textcolor = color.white, style = label.style_label_left, size = size.normal)
var label prev_tp2_lbl = label.new(na, na, "", color = color.new(color.gray, 50), textcolor = color.white, style = label.style_label_left, size = size.normal)
var label prev_tp3_lbl = label.new(na, na, "", color = color.new(color.gray, 50), textcolor = color.white, style = label.style_label_left, size = size.normal)

float prev_base_price = array.size(zz_values) > 1 ? array.get(zz_values, 1) : na
int   prev_entry_bar  = array.size(zz_bars) > 1 ? array.get(zz_bars, 1) : na
int   prev_dir        = array.size(zz_values) > 1 ? -dir : 0

float prev_tp1_price = prev_dir == -1 ? prev_base_price + amp_tp1 : prev_base_price - amp_tp1
float prev_tp2_price = prev_dir == -1 ? prev_base_price + amp_tp2 : prev_base_price - amp_tp2
float prev_tp3_price = prev_dir == -1 ? prev_base_price + amp_tp3 : prev_base_price - amp_tp3

if show_tp and show_prev_tp and barstate.islast and not na(prev_base_price)
    int prev_draw_start = nz(prev_entry_bar, bar_index)
    
    if prev_tp1_on
        line.set_xy1(prev_tp1_line, prev_draw_start, prev_tp1_price)
        line.set_xy2(prev_tp1_line, bar_index + 3, prev_tp1_price)
        label.set_xy(prev_tp1_lbl, bar_index + 3, prev_tp1_price)
        label.set_text(prev_tp1_lbl, "Prev TP1: " + str.tostring(truncate(prev_tp1_price, 2)))
    else
        line.set_xy1(prev_tp1_line, na, na)
        line.set_xy2(prev_tp1_line, na, na)
        label.set_xy(prev_tp1_lbl, na, na)
   
    if prev_tp2_on
        line.set_xy1(prev_tp2_line, prev_draw_start, prev_tp2_price)
        line.set_xy2(prev_tp2_line, bar_index + 3, prev_tp2_price)
        label.set_xy(prev_tp2_lbl, bar_index + 3, prev_tp2_price)
        label.set_text(prev_tp2_lbl, "Prev TP2: " + str.tostring(truncate(prev_tp2_price, 2)))
    else
        line.set_xy1(prev_tp2_line, na, na)
        line.set_xy2(prev_tp2_line, na, na)
        label.set_xy(prev_tp2_lbl, na, na)
   
    if prev_tp3_on
        line.set_xy1(prev_tp3_line, prev_draw_start, prev_tp3_price)
        line.set_xy2(prev_tp3_line, bar_index + 3, prev_tp3_price)
        label.set_xy(prev_tp3_lbl, bar_index + 3, prev_tp3_price)
        label.set_text(prev_tp3_lbl, "Prev TP3: " + str.tostring(truncate(prev_tp3_price, 2)))
    else
        line.set_xy1(prev_tp3_line, na, na)
        line.set_xy2(prev_tp3_line, na, na)
        label.set_xy(prev_tp3_lbl, na, na)
else
    line.set_xy1(prev_tp1_line, na, na)
    line.set_xy2(prev_tp1_line, na, na)
    label.set_xy(prev_tp1_lbl, na, na)
    
    line.set_xy1(prev_tp2_line, na, na)
    line.set_xy2(prev_tp2_line, na, na)
    label.set_xy(prev_tp2_lbl, na, na)
    
    line.set_xy1(prev_tp3_line, na, na)
    line.set_xy2(prev_tp3_line, na, na)
    label.set_xy(prev_tp3_lbl, na, na)

// ==========================================
// LEG METRICS & KINETIC MOMENTUM (STR / LEVEL)
// ==========================================
float prev_zz_val = array.size(zz_values) > 1 ? array.get(zz_values, 1) : last_zz_val
int prev_zz_bar   = array.size(zz_bars) > 1 ? array.get(zz_bars, 1) : last_zz_bar

float current_leg_length = math.abs(percent(last_zz_val, prev_zz_val))
float current_leg_bars   = math.max(1, last_zz_bar - prev_zz_bar)
float current_velocity   = current_leg_length / current_leg_bars

var float[] velocity_history = array.new_float()
if array.size(velocity_history) == 0
    array.push(velocity_history, current_velocity)

float raw_speed = current_leg_bars > 0 ? current_leg_length / current_leg_bars : 0.0
float avg_speed_200 = f_alma_dynamic(gkyz_history, 160, dyn_offset, dyn_sigma)

int eff_norm_len = math.max(20, math.round(norm_window * tf_ratio))

float vel_stdev_hist = ta.stdev(raw_speed, eff_norm_len)
float vel_mean_hist  = ta.alma(raw_speed, eff_norm_len, 0.85, 1)
float z_speed        = not na(vel_stdev_hist) and vel_stdev_hist > 0 ? (raw_speed - vel_mean_hist) / vel_stdev_hist : 0.0

float acf_stdev_hist = ta.stdev(nz(acf_boost, 0.5), eff_norm_len)
float acf_mean_hist  = ta.alma(nz(acf_boost, 0.5), eff_norm_len, 0.85, 1)
float z_cycle        = not na(acf_stdev_hist) and acf_stdev_hist > 0 ? (nz(acf_boost, 0.5) - acf_mean_hist) / acf_stdev_hist : 0.0

float total_wave_power_fallback = current_leg_length * (has_volume ? f_alma_dynamic(gkyz_history, short_stdev_len, dyn_offset, dyn_sigma) : 1.0)
float wave_power_norm = total_wave_power_fallback / math.max(1e-10, f_alma_dynamic(gkyz_history, eff_norm_len, dyn_offset, dyn_sigma))
float vol_stdev_hist = ta.stdev(wave_power_norm, eff_norm_len)
float vol_mean_hist  = ta.alma(wave_power_norm, eff_norm_len, 0.85, 1)
float z_volume       = not na(vol_stdev_hist) and vol_stdev_hist > 0 ? (wave_power_norm - vol_mean_hist) / vol_stdev_hist : 0.0

float kinetic_energy = math.max(0.0, (math.pow(math.max(0.0, z_speed), 2.0) * math.max(0.1, z_volume + 1.5)) * (1.0 + math.max(0.0, z_cycle)))

var float[] pivot_score_history = array.new_float()

if is_new_pivot and array.size(zz_values) >= 3 and array.size(zz_bars) >= 3
    float completed_len = math.abs(percent(array.get(zz_values, 1), array.get(zz_values, 2)))
    int completed_bars  = math.max(1, array.get(zz_bars, 1) - array.get(zz_bars, 2))
    float completed_speed = completed_len / completed_bars
    
    float completed_energy = math.max(0.0, math.pow(completed_speed, 2.0) * math.max(0.1, z_volume + 1.5))
    array.unshift(pivot_score_history, completed_energy)
    
    if array.size(pivot_score_history) > tp_sample
        array.pop(pivot_score_history)

int score_sample_size = array.size(pivot_score_history)
var array<float> sorted_scores = array.new_float()
sorted_scores := array.copy(pivot_score_history)
array.sort(sorted_scores, order.ascending)

int mom_tier = 1
if score_sample_size > 10
    float s_min_t1 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.20)))
    float s_max_t1 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.40)))

    float s_min_t2 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.40)))
    float s_max_t2 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.70)))

    float s_min_t3 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.70)))
    float s_max_t3 = array.get(sorted_scores, math.min(score_sample_size - 1, int(score_sample_size * 0.90)))

    float cluster_t1 = not na(s_min_t1) and s_max_t1 > s_min_t1 ? f_gaussian_cluster(pivot_score_history, s_min_t1, s_max_t1) : s_min_t1
    float cluster_t2 = not na(s_min_t2) and s_max_t2 > s_min_t2 ? f_gaussian_cluster(pivot_score_history, s_min_t2, s_max_t2) : s_min_t2
    float cluster_t3 = not na(s_min_t3) and s_max_t3 > s_min_t3 ? f_gaussian_cluster(pivot_score_history, s_min_t3, s_max_t3) : s_min_t3

    if kinetic_energy >= cluster_t3
        mom_tier := 3
    else if kinetic_energy >= cluster_t2
        mom_tier := 2
    else
        mom_tier := 1
else
    mom_tier := kinetic_energy < 0.5 ? 1 : kinetic_energy > 1.5 ? 3 : 2

string white_stars = mom_tier == 1 ? "★" : mom_tier == 2 ? "★★" : "★★★"

int tp_tier = 1
if array.size(zz_values) >= 2 and array.size(zz_bars) >= 2
    float p_start_val = array.get(zz_values, 1)
    int p_start_bar   = array.get(zz_bars, 1)
    int p_end_bar     = array.get(zz_bars, 0)
   
    float wave_extreme = dir == -1 ? high[0] : low[0]
    int start_idx = math.min(p_start_bar, p_end_bar)
    int end_idx   = math.max(p_start_bar, p_end_bar)
    
    if bar_index - end_idx <= 400 and start_idx >= 0
        float ext_val = dir == -1 ? 999999.0 : -999999.0
        for i = start_idx to end_idx
            if i >= 0 and i <= bar_index
                float h_val = high[bar_index - i]
                float l_val = low[bar_index - i]
                if dir == -1
                    if l_val < ext_val
                        ext_val := l_val
                else
                    if h_val > ext_val
                        ext_val := h_val
        wave_extreme := ext_val

    float achieved_amp  = math.abs(wave_extreme - p_start_val)
   
    if achieved_amp >= amp_tp3
        tp_tier := 3
    else if achieved_amp >= amp_tp2
        tp_tier := 2
    else if achieved_amp >= amp_tp1
        tp_tier := 1
    else
        tp_tier := 1

string empty_blocks = tp_tier == 1 ? "◻" : tp_tier == 2 ? "◻◻" : "◻◻◻"
string str_level_dots = white_stars + " / " + empty_blocks

// ==========================================
// ORDERFLOW & DYNAMIC RISK MANAGEMENT (SL)
// ==========================================
var float wave_buyers_power = 0.0
var float wave_sellers_power = 0.0
var int buyers_pct = 50, var int sellers_pct = 50
var string orderflow_text = "50% | ░░░░░░░░░░ | 50%"
var color orderflow_bg_color = color.gray

bool pivot_moved_or_changed = (dir != initial_dir) or (last_zz_val != initial_zz_val) or is_new_pivot
int elapsed_bars = bar_index - last_zz_bar

float eff_vol = has_volume ? volume : 1.0
float buy_vol_share = eff_vol * closePosition
float sell_vol_share = eff_vol * (1.0 - closePosition)

float buyPowerSeries   = buy_vol_share * directionWeight
float sellPowerSeries  = sell_vol_share * (1.0 - directionWeight)
float total_power_sum  = buyPowerSeries + sellPowerSeries
float b_force = total_power_sum > 0 ? buyPowerSeries / total_power_sum : 0.5

float current_momentum_weight = math.max(0.1, (raw_speed / math.max(1e-10, avg_speed_200)) + 1.0)
float vol_norm_factor = has_volume ? (volume / math.max(1.0, ta.alma(volume, eff_norm_len, 0.85, 1))) : 1.0

float final_candle_weight = math.max(0.01, finalVolatilityPct) * current_momentum_weight * math.min(5.0, math.max(0.2, vol_norm_factor)) * 10.0

float b_power_val = b_force * final_candle_weight

if pivot_moved_or_changed or elapsed_bars == 0
    wave_buyers_power  := b_power_val
    wave_sellers_power := (1.0 - b_force) * final_candle_weight
else
    wave_buyers_power  += b_power_val
    wave_sellers_power += (1.0 - b_force) * final_candle_weight

float total_wave_power = math.max(0.001, wave_buyers_power + wave_sellers_power)
buyers_pct := math.round((wave_buyers_power / total_wave_power) * 100)
sellers_pct := 100 - buyers_pct

int filled_b_bars = int(math.round(buyers_pct / 10))
orderflow_text := str.tostring(buyers_pct) + "% | " + str.repeat("█", filled_b_bars) + str.repeat("░", 10 - filled_b_bars) + " | " + str.tostring(sellers_pct) + "%"
orderflow_bg_color := buyers_pct > 50 ? dash_green : sellers_pct > 50 ? dash_red : dash_base_color

var bool state_locked = false
var int last_dir_sl = 0

if dir != last_dir_sl
    state_locked := false
    last_dir_sl := dir

bool price_met = math.abs(close - last_zz_val) >= dynamic_threshold
bool time_met  = elapsed_bars >= adaptive_backstep_clamped
if is_new_pivot or (time_met and price_met)
    state_locked := true

bool search_next = state_locked and ((dir == 1 and low < last_zz_val - dynamic_threshold) or (dir == -1 and high > last_zz_val + dynamic_threshold))
float calculated_sl = dir == 1 ? (state_locked and not search_next ? last_zz_val + noise_buffer : last_zz_val - noise_buffer) : (state_locked and not search_next ? last_zz_val - noise_buffer : last_zz_val + noise_buffer)
float calculated_sl_opp = calculated_sl > close ? close - math.abs(close - calculated_sl) : close + math.abs(close - calculated_sl)

string sl_text = str.tostring(truncate(calculated_sl, 2)) + " / " + str.tostring(truncate(calculated_sl_opp, 2))

var float prev_fast_baseline = na
if na(prev_fast_baseline)
    prev_fast_baseline := fast_baseline

string trend_prediction = fast_baseline > prev_fast_baseline ? "Probably Higher" : fast_baseline < prev_fast_baseline ? "Probably Lower" : "Neutral"
prev_fast_baseline := fast_baseline

float smooth_gap = fast_baseline - raw_my_baseline
float prev_smooth_gap = nz(smooth_gap[1], smooth_gap)
bool is_expanding = math.abs(smooth_gap) > math.abs(prev_smooth_gap)
bool is_shrinking = math.abs(smooth_gap) < math.abs(prev_smooth_gap)

float momentum_factor = (is_expanding ? 1.25 : is_shrinking ? 0.85 : 1.0) * (0.76 + acf_boost * 0.24)
float exp_time_avg = f_alma_dynamic(gkyz_history, 2, dyn_offset, dyn_sigma) * adaptive_backstep_clamped * (1 + (1 - probability_deviation)) * momentum_factor / math.max(1, f_alma_dynamic(gkyz_history, 2, dyn_offset, dyn_sigma))

var array<float> long_baseline_history_plot = array.new_float()
array.unshift(long_baseline_history_plot, raw_my_baseline)
if array.size(long_baseline_history_plot) > 400
    array.pop(long_baseline_history_plot)
float long_baseline_plot = f_alma_dynamic(long_baseline_history_plot, smooth_len, smooth_offset, smooth_sigma)

var array<float> fast_baseline_history_plot = array.new_float()
array.unshift(fast_baseline_history_plot, fast_baseline)
if array.size(fast_baseline_history_plot) > 400
    array.pop(fast_baseline_history_plot)
float fast_baseline_plot = f_alma_dynamic(fast_baseline_history_plot, smooth_len, smooth_offset, smooth_sigma)

// ==========================================
// PROJECTIONS, DASHBOARD & PLOTS
// ==========================================
var line est_pivot_line = line.new(na, na, na, na, extend = extend.both)
var line max_pivot_line = line.new(na, na, na, na, extend = extend.both)

if show_pv_lines and barstate.islast
    int scaled_backstep = math.round(adaptive_backstep_clamped)
    int scaled_exp_time = math.round(exp_time_avg)
   
    int base_zz_bar = nz(last_zz_bar, bar_index)
   
    int est_bar_target = math.max(bar_index, base_zz_bar + scaled_exp_time)
    int max_bar_target = math.max(bar_index + 1, base_zz_bar + scaled_backstep)
   
    line.set_xy1(est_pivot_line, est_bar_target, high)
    line.set_xy2(est_pivot_line, est_bar_target, low)
    line.set_color(est_pivot_line, line_col_est)
    line.set_style(est_pivot_line, get_line_style(line_style_est))
    line.set_width(est_pivot_line, line_thick_est)
   
    line.set_xy1(max_pivot_line, max_bar_target, high)
    line.set_xy2(max_pivot_line, max_bar_target, low)
    line.set_color(max_pivot_line, line_col_max)
    line.set_style(max_pivot_line, get_line_style(line_style_max))
    line.set_width(max_pivot_line, line_thick_max)

var table dash_table = table.new(get_dash_pos(dash_pos), 2, 7, bgcolor = color.new(color.black, 20), border_color = color.gray, border_width = 1)
var line sl_line     = line.new(na, na, na, na, color = sl_line_color, width = 2, style = line.style_dotted)
var line sl_line_opp = line.new(na, na, na, na, color = sl_line_color, width = 2, style = line.style_dotted)

if show_dash and barstate.islast
    table.set_position(dash_table, get_dash_pos(dash_pos))
    table.clear(dash_table, 0, 0, 1, 6)

    float time_pct = adaptive_backstep_clamped > 0 ? math.min(100, (elapsed_bars / float(adaptive_backstep_clamped)) * 100) : 0
    string time_text = str.tostring(elapsed_bars) + " / " + str.tostring(adaptive_backstep_clamped) + " – " + str.tostring(math.round(exp_time_avg)) + "\n" + str.repeat("█", int(math.round(time_pct / 10))) + str.repeat("░", 10 - int(math.round(time_pct / 10))) + " " + str.tostring(math.round(time_pct)) + "%"

    float price_pct = dynamic_threshold > 0 ? math.min(100, (math.abs(close - last_zz_val) / dynamic_threshold) * 100) : 0
    color price_color = dir == 1 ? (close < last_zz_val - dynamic_threshold ? dash_green : dash_red) : (close > last_zz_val + dynamic_threshold ? dash_green : dash_red)
    string price_text = str.tostring(truncate(math.abs(close - last_zz_val), 2)) + " / " + str.tostring(truncate(dynamic_threshold, 2)) + "\n" + str.repeat("█", int(math.round(price_pct / 10))) + str.repeat("░", 10 - int(math.round(price_pct / 10))) + " " + str.tostring(math.round(price_pct)) + "%"

    color pred_color = trend_prediction == "Probably Higher" ? dash_green : trend_prediction == "Probably Lower" ? dash_red : dash_base_color

    table.cell(dash_table, 0, 0, "Metric", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 0, "Status / Value", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 0, 1, "Time Window", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 1, time_text, text_size = dash_size, text_color = pb_color, text_font_family = font.family_monospace, bgcolor = time_met ? dash_green : dash_red)
    table.cell(dash_table, 0, 2, "Price Distance", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 2, price_text, text_size = dash_size, text_color = pb_color, text_font_family = font.family_monospace, bgcolor = price_color)
    table.cell(dash_table, 0, 3, "Buy/Sell Power", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 3, orderflow_text, text_size = dash_size, text_color = pb_color, text_font_family = font.family_monospace, bgcolor = orderflow_bg_color)
    table.cell(dash_table, 0, 4, "Probability Bias", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 4, trend_prediction, text_size = dash_size, text_color = color.white, bgcolor = pred_color)
    table.cell(dash_table, 0, 5, "MTF Trend (" + mtf_tf + ")", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 5, mtf_trend_str, text_size = dash_size, text_color = color.white, bgcolor = mtf_trend_col)
    table.cell(dash_table, 0, 6, "Active SL", text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)
    table.cell(dash_table, 1, 6, sl_text, text_size = dash_size, text_color = color.white, bgcolor = dash_base_color)

if barstate.islast and not na(calculated_sl)
    line.set_xy1(sl_line, bar_index, calculated_sl)
    line.set_xy2(sl_line, bar_index + sl_line_len, calculated_sl)
    line.set_color(sl_line, sl_line_color)
    line.set_xy1(sl_line_opp, bar_index, calculated_sl_opp)
    line.set_xy2(sl_line_opp, bar_index + sl_line_len, calculated_sl_opp)
    line.set_color(sl_line_opp, sl_line_color)

var label live_marker = na
if barstate.islast
    if not na(live_marker)
        label.delete(live_marker)
   
    bool mtf_buy_ok = not use_mtf or (mtf_val == 1)
    bool mtf_sell_ok = not use_mtf or (mtf_val == -1)

    if (buyers_pct > 50) and (trend_prediction == "Probably Higher") and mtf_buy_ok
        live_marker := label.new(bar_index, low - (high - low) * 0.15, str.tostring(buyers_pct) + "%", color = marker_color_buy, textcolor = color.white, style = label.style_label_up, size = marker_size)
    else if (sellers_pct > 50) and (trend_prediction == "Probably Lower") and mtf_sell_ok
        live_marker := label.new(bar_index, high + (high - low) * 0.15, str.tostring(sellers_pct) + "%", color = marker_color_sell, textcolor = color.white, style = label.style_label_down, size = marker_size)

// ==========================================
// RENDER ZIGZAG LINES & LABELS
// ==========================================
var line active_line = na
var label active_label = na

if array.size(zz_values) >= 2
    float y0 = array.get(zz_values, 0)
    int x0 = array.get(zz_bars, 0)
    float y1 = array.get(zz_values, 1)
    int x1 = array.get(zz_bars, 1)
   
    float change_perc = truncate(percent(y0, y1), 2)
    string perc_str = (change_perc > 0 ? "+" : "") + str.tostring(change_perc) + "%"

    string lbl = switch display_opt
        "Price Only"          => str.tostring(truncate(y0, 2))
        "% Only"              => perc_str
        "STR/Level"           => str_level_dots
        "Both (Price & %)"    => str.tostring(truncate(y0, 2)) + "\n" + perc_str
        "Price, % & STR/Level" => str.tostring(truncate(y0, 2)) + "\n" + perc_str + "\n" + str_level_dots
        => ""

    string lbl_style = dir == 1 ? label.style_label_down : label.style_label_up
    color col = dir == 1 ? upcolor : downcolor

    if is_new_pivot
        if not na(active_line)
            array.unshift(zz_lines, active_line)
            array.unshift(zz_labels, active_label)
       
        active_line := line.new(x1, y1, x0, y0, color = col, width = zigwidth, style = get_line_style(zigstyle))
        active_label := label.new(x0, y0, lbl, color = col, textcolor = txtcol, style = lbl_style)
       
        if array.size(zz_lines) > 400
            line.delete(array.pop(zz_lines))
        if array.size(zz_labels) > 400
            label.delete(array.pop(zz_labels))
    else
        if na(active_line)
            active_line := line.new(x1, y1, x0, y0, color = col, width = zigwidth, style = get_line_style(zigstyle))
            active_label := label.new(x0, y0, lbl, color = col, textcolor = txtcol, style = lbl_style)
        else
            line.set_xy1(active_line, x1, y1)
            line.set_xy2(active_line, x0, y0)
            line.set_color(active_line, col)
           
            label.set_xy(active_label, x0, y0)
            label.set_text(active_label, lbl)
            label.set_color(active_label, col)

plot(last_zz_val, "BaseLine Pivot", color = (dir == 1 ? upcolor : downcolor), linewidth = 1, style = plot.style_stepline)
plot(long_baseline_plot, "Long Baseline", color = color.gray, linewidth = 1)
plot(fast_baseline_plot, "Fast Baseline", color = (ta.rising(fast_baseline_plot, 1) ? color.green : color.red), linewidth = 2)
````
