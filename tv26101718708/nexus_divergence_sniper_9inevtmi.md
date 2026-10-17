# Nexus Divergence Sniper

- url: https://www.tradingview.com/script/9Inevtmi/
- type: indicator
- pine_id: PUB;19b6f37a804c45119760c1b2c82d9476
- version: 1.0

## Description

🎯[b] Introducing: Nexus Divergence Sniper [NDS] – The Ultimate Reversal Algorithm[/b]
Are you tired of catching falling knives, getting faked out by premature signals, or watching your indicator’s signals magically vanish after price hits your stop loss? Reversal trading offers massive R:R (Risk-to-Reward) potential, but without a bulletproof filtering system, it can quickly drain your account.
Enter the [b]Nexus Divergence Sniper (NDS).[/b]
[b]NDS[/b] is not just another basic divergence plotter. It is an all-in-one algorithmic trading framework that seamlessly fuses Momentum (MACD), Volatility (ATR), Price Dynamics (Advanced Candlestick Action), and Volatility Bands (Bollinger Bands) into a high-probability sniper system.

https://vn.tradingview.com/x/sOuHI5MM/

🚀 [b]How Does NDS Work?[/b]
To protect your capital from market noise, NDS enforces a strict, multi-layer confirmation matrix before printing a single BUY or SELL signal:
1. Structural Divergence: Identifies underlying trend exhaustion through double peak/trough structures synced with the MACD Histogram.
2. Pullback & Engulfing Confirmation: NDS never blindly trades the exact top or bottom. The algorithm patiently waits for a mandatory price "breath" (pullback) and triggers only when a decisive Engulfing candle confirms momentum has shifted.
3. Multi-Dimensional Noise Filtering: Powered by ATR to automatically filter out abnormal market spikes or tiny, meaningless candles. It also checks the preceding 4 candles to ensure you aren't trading directly into a runaway freight train.
⚡ [b]Key Features:[/b]
1. 100% Non-Repainting: Signals utilize the barstate.isconfirmed protection layer. Once a signal prints on a closed candle, it stays there forever. No visual tricks, no moving goals.
2. Visual Smart SL/TP: Instantly plots dynamic, ATR-based Stop Loss, Take Profit 1 (Partial), and Take Profit 2 (Runner) levels directly on your chart.
3. Real-Time Performance Dashboard: Track your edge on the fly. The built-in stats panel automatically monitors your Win Rate, Total Trades, TP completions, and SL hits based on your chosen live chart data.
4. Customizable Bollinger Bands Filter: Fine-tune your entries. Choose to take all signals or restrict the algorithm to execute trades exclusively in premium overextended zones (Upper/Lower Bollinger halves).
[b]Nexus Divergence Sniper[/b] doesn't promise a "Holy Grail," but it does promise absolute, algorithmic discipline for your charts. Add NDS to your arsenal today and start sniping the markets with mathematical precision!

## Source Code

````pine
//@version=6
indicator("Nexus Divergence Sniper", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ==========================================
// 1. INPUTS & SETTINGS
// ==========================================
atr_len = input.int(10, "ATR Period (General)", tooltip="Used for Candle Size, SL/TP, and Spike Filters", group="Filters")

display_mode = input.string("All", "Display Mode & Stats", options=["All", "Short Upper Half / Long Lower Half", "Short Lower Half / Long Upper Half"], group="Bollinger Bands Filter", tooltip="The statistics board will automatically calculate based on the display mode you select here.")

// Candle Filter
min_atr_mult = input.float(0.5, "Min Candle Body (ATR Mult)", group="Candle Filter")
max_atr_mult = input.float(1.5, "Max Candle Body (ATR Mult)", group="Candle Filter")

// Advanced Size Filter
use_body_size_filter = input.bool(true, "Enable Same-Color Size Filter", tooltip="Reject trade if entry candle is not X times larger than the previous same-color candle or the one before it.", group="Advanced Size Filter")
size_multiplier = input.float(1.2, "Size Multiplier (Entry vs Prev Same-Color)", step=0.1, group="Advanced Size Filter")

// Divergence Settings
pivot_src_opt = input.string("High/Low", "Divergence Pivot Source", options=["High/Low", "Close"], tooltip="Select peak/trough divergence calculation based on High/Low or Close price", group="Divergence")
piv_len = input.int(3, "Pivot Period", group="Divergence")
min_div_lookback = input.int(6, "Min Divergence Lookback (Bars)", group="Divergence")
max_div_lookback = input.int(15, "Max Divergence Lookback (Bars)", group="Divergence")

// Peak/Trough Difference limits via ATR
min_peak_diff_atr = input.float(0.2, "Min Peak/Trough Diff (ATR Mult)", group="Divergence", tooltip="Minimum difference between 2 peaks/troughs compared to average ATR")
max_peak_diff_atr = input.float(2, "Max Peak/Trough Diff (ATR Mult)", group="Divergence", tooltip="Maximum difference between 2 peaks/troughs compared to average ATR")

// Entry Time Limit
min_setup_bars = input.int(0, "Min Bars After Confirmation", tooltip="Wait at least this many bars after divergence confirmation", group="Filters")
max_setup_bars = input.int(50, "Max Bars After Confirmation", tooltip="Cancel setup if no entry after this many bars", group="Filters")

// SL/TP Settings
sl_atr_mult = input.float(2, "SL (ATR Mult)", group="SL/TP")
tp1_mult = input.float(2, "TP1 (Ratio to SL)", group="SL/TP")
tp2_mult = input.float(4, "TP2 (Ratio to SL)", group="SL/TP")
line_ext = input.int(20, "Line Extension (Bars)", group="SL/TP")

// Bollinger Bands Filters
bb_len = input.int(200, "BB Period", group="Bollinger Bands Filter")
bb_mult = input.float(2.0, "BB StdDev", group="Bollinger Bands Filter")

// ==========================================
// 2. CORE CALCULATION
// ==========================================
src = close
xATR = ta.atr(atr_len)

// Fixed MACD Histogram Calculation
[_, _, macd_hist] = ta.macd(src, 12, 26, 9)

// Bollinger Bands Calculation (200, 2)
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

// Update price source based on options
src_ph = pivot_src_opt == "High/Low" ? high : close
src_pl = pivot_src_opt == "High/Low" ? low : close

ph = ta.pivothigh(src_ph, piv_len, piv_len) 
pl = ta.pivotlow(src_pl, piv_len, piv_len)   

var float last_ph_val = na
var int last_ph_bar = 0
var float last_ph_macd = na
var float last_ph_atr = na 

var float last_pl_val = na
var int last_pl_bar = 0
var float last_pl_macd = na
var float last_pl_atr = na 

float current_ph_macd = na
if not na(ph)
    current_ph_macd := macd_hist[0]
    for i = 1 to (piv_len * 2)
        if macd_hist[i] > current_ph_macd
            current_ph_macd := macd_hist[i]
            
    last_ph_val := ph
    last_ph_bar := bar_index[piv_len]
    last_ph_macd := current_ph_macd 
    last_ph_atr := xATR[piv_len] 
    
float current_pl_macd = na
if not na(pl)
    current_pl_macd := macd_hist[0]
    for i = 1 to (piv_len * 2)
        if macd_hist[i] < current_pl_macd
            current_pl_macd := macd_hist[i]
            
    last_pl_val := pl
    last_pl_bar := bar_index[piv_len]
    last_pl_macd := current_pl_macd
    last_pl_atr := xATR[piv_len] 

// ==========================================
// 3. SETUP CHECK & MANAGEMENT
// ==========================================
// Peak/Trough difference check via ATR
float avg_atr_pl = na
bool valid_pl_diff = false
if not na(pl) and not na(last_pl_val[1]) and not na(last_pl_atr[1])
    avg_atr_pl := (last_pl_atr[1] + xATR[piv_len]) / 2.0
    float pl_diff = math.abs(pl - last_pl_val[1])
    valid_pl_diff := (pl_diff >= min_peak_diff_atr * avg_atr_pl) and (pl_diff <= max_peak_diff_atr * avg_atr_pl)

// Long Divergence Conditions
int bars_between_pl = not na(pl) and not na(last_pl_bar[1]) ? (bar_index[piv_len] - last_pl_bar[1]) : 0
div_buy_price = not na(pl) and pl < last_pl_val[1] and current_pl_macd > last_pl_macd[1] and bars_between_pl >= min_div_lookback and bars_between_pl <= max_div_lookback and valid_pl_diff

float avg_atr_ph = na
bool valid_ph_diff = false
if not na(ph) and not na(last_ph_val[1]) and not na(last_ph_atr[1])
    avg_atr_ph := (last_ph_atr[1] + xATR[piv_len]) / 2.0
    float ph_diff = math.abs(ph - last_ph_val[1])
    valid_ph_diff := (ph_diff >= min_peak_diff_atr * avg_atr_ph) and (ph_diff <= max_peak_diff_atr * avg_atr_ph)

// Short Divergence Conditions
int bars_between_ph = not na(ph) and not na(last_ph_bar[1]) ? (bar_index[piv_len] - last_ph_bar[1]) : 0
div_sell_price = not na(ph) and ph > last_ph_val[1] and current_ph_macd < last_ph_macd[1] and bars_between_ph >= min_div_lookback and bars_between_ph <= max_div_lookback and valid_ph_diff

var bool long_setup = false
var bool short_setup = false
var int long_setup_bar = 0
var int short_setup_bar = 0

var float long_setup_pl = na
var float short_setup_ph = na

var int long_peak1_bar = 0
var int long_peak2_bar = 0
var float long_dist_peaks = 0.0

var int short_peak1_bar = 0
var int short_peak2_bar = 0
var float short_dist_peaks = 0.0

var float long_height_1 = na 
var float long_max_h2 = na   
var float short_height_1 = na 
var float short_min_l2 = na  

// CLOSE PRICE REFERENCE MILESTONES
var float long_trough2_close_ref = na
var float short_peak2_close_ref = na
var bool long_has_pullback = false
var bool short_has_pullback = false

// Variables saving candle and BB state at Peak/Trough 2
var float long_t2_low = na
var float long_t2_close = na
var float long_t2_basis = na
var float long_t2_lower = na
var float long_t2_upper = na

var float short_p2_high = na
var float short_p2_close = na
var float short_p2_basis = na
var float short_p2_upper = na
var float short_p2_lower = na

if div_buy_price
    // 1. Only get close price from actual Trough 2 candle backwards
    float current_min_c = close[piv_len]
    for i = piv_len to (piv_len * 2)
        if close[i] < current_min_c
            current_min_c := close[i]
            
    // 2. Immediate check for candles AFTER trough 2
    bool pre_invalid_long = false
    if piv_len > 1
        for i = 1 to (piv_len - 1)
            if close[i] < current_min_c
                pre_invalid_long := true
                
    if not pre_invalid_long
        long_setup := true
        short_setup := false
        long_setup_bar := bar_index
        long_setup_pl := pl 
        long_has_pullback := false 
        long_trough2_close_ref := current_min_c
        
        long_peak1_bar := last_pl_bar[1]
        long_peak2_bar := bar_index[piv_len]
        long_dist_peaks := long_peak2_bar - long_peak1_bar
        
        // Save candle and BB info at Trough 2
        long_t2_low   := low[piv_len]
        long_t2_close := close[piv_len]
        long_t2_basis := bb_basis[piv_len]
        long_t2_lower := bb_lower[piv_len]
        long_t2_upper := bb_upper[piv_len]
        
        float max_h1 = high[piv_len]
        int bars_back = bar_index - last_pl_bar[1]
        for i = piv_len to bars_back
            if high[i] > max_h1
                max_h1 := high[i]
        long_height_1 := max_h1 - last_pl_val[1]
        
        float current_max_h2 = high
        for i = 0 to piv_len - 1
            if high[i] > current_max_h2
                current_max_h2 := high[i]
        long_max_h2 := current_max_h2
        
        label.new(x=bar_index[piv_len], y=pl, color=color.green, style=label.style_circle, size=size.small)
        label.new(x=last_pl_bar[1], y=last_pl_val[1], color=color.green, style=label.style_circle, size=size.small)
        line.new(x1=last_pl_bar[1], y1=last_pl_val[1], x2=bar_index[piv_len], y2=pl, color=color.green, style=line.style_dashed, width=2)

if div_sell_price
    // 1. Only get close price from actual Peak 2 candle backwards
    float current_max_c = close[piv_len]
    for i = piv_len to (piv_len * 2)
        if close[i] > current_max_c
            current_max_c := close[i]
            
    // 2. Immediate check for candles AFTER peak 2
    bool pre_invalid_short = false
    if piv_len > 1
        for i = 1 to (piv_len - 1)
            if close[i] > current_max_c
                pre_invalid_short := true
                
    if not pre_invalid_short
        short_setup := true
        long_setup := false
        short_setup_bar := bar_index
        short_setup_ph := ph 
        short_has_pullback := false 
        short_peak2_close_ref := current_max_c
        
        short_peak1_bar := last_ph_bar[1]
        short_peak2_bar := bar_index[piv_len]
        short_dist_peaks := short_peak2_bar - short_peak1_bar
        
        // Save candle and BB info at Peak 2
        short_p2_high  := high[piv_len]
        short_p2_close := close[piv_len]
        short_p2_basis := bb_basis[piv_len]
        short_p2_upper := bb_upper[piv_len]
        short_p2_lower := bb_lower[piv_len]

        float min_l1 = low[piv_len]
        int bars_back_s = bar_index - last_ph_bar[1]
        for i = piv_len to bars_back_s
            if low[i] < min_l1
                min_l1 := low[i]
        short_height_1 := last_ph_val[1] - min_l1
        
        float current_min_l2 = low
        for i = 0 to piv_len - 1
            if low[i] < current_min_l2
                current_min_l2 := low[i]
        short_min_l2 := current_min_l2
        
        label.new(x=bar_index[piv_len], y=ph, color=color.red, style=label.style_circle, size=size.small)
        label.new(x=last_ph_bar[1], y=last_ph_val[1], color=color.red, style=label.style_circle, size=size.small)
        line.new(x1=last_ph_bar[1], y1=last_ph_val[1], x2=bar_index[piv_len], y2=ph, color=color.red, style=line.style_dashed, width=2)

// CONTINUOUSLY UPDATE STATE WHILE WAITING FOR ENTRY
if long_setup
    if high > long_max_h2
        long_max_h2 := high 
    if close < open 
        long_has_pullback := true 

if short_setup
    if low < short_min_l2
        short_min_l2 := low
    if close > open
        short_has_pullback := true 

// CANCEL SETUP
bool long_close_invalid = false
if long_setup and not na(long_trough2_close_ref)
    if close[1] < long_trough2_close_ref
        long_close_invalid := true

if long_setup and ((bar_index - long_setup_bar) > max_setup_bars or low < long_setup_pl or (bar_index - long_peak2_bar) > (long_dist_peaks * 1.3) or long_close_invalid)
    long_setup := false

bool short_close_invalid = false
if short_setup and not na(short_peak2_close_ref)
    if close[1] > short_peak2_close_ref
        short_close_invalid := true

if short_setup and ((bar_index - short_setup_bar) > max_setup_bars or high > short_setup_ph or (bar_index - short_peak2_bar) > (short_dist_peaks * 1.3) or short_close_invalid)
    short_setup := false

// ==========================================
// 4. TRADE MANAGEMENT & TRIGGERS
// ==========================================
var int state = 0 
var float entry_p = na
var float sl_p = na
var float tp1_p = na
var float tp2_p = na
var bool tp1_hit = false

var int total_trades = 0
var int count_tp1_back = 0 
var int count_tp2 = 0      
var int count_sl = 0       
var string current_sig = "NONE"

candle_body = math.abs(close - open)
valid_candle = candle_body > (min_atr_mult * xATR) and candle_body < (max_atr_mult * xATR) 
green_candle = close > open 
red_candle = close < open   

var float green_body_1 = na
var float green_body_2 = na
var float red_body_1 = na
var float red_body_2 = na

// Filter based on previous same-color candle body size
bool long_size_valid = true
bool short_size_valid = true

if use_body_size_filter
    long_size_valid := false
    short_size_valid := false
    
    if green_candle
        bool cond_g1 = not na(green_body_1) and (candle_body >= size_multiplier * green_body_1)
        bool cond_g2 = not na(green_body_2) and (candle_body >= size_multiplier * green_body_2)
        if cond_g1 or cond_g2
            long_size_valid := true
            
    if red_candle
        bool cond_r1 = not na(red_body_1) and (candle_body >= size_multiplier * red_body_1)
        bool cond_r2 = not na(red_body_2) and (candle_body >= size_multiplier * red_body_2)
        if cond_r1 or cond_r2
            short_size_valid := true

is_meaningful_body = candle_body > (min_atr_mult * xATR)

if green_candle and is_meaningful_body
    green_body_2 := green_body_1
    green_body_1 := candle_body

if red_candle and is_meaningful_body
    red_body_2 := red_body_1
    red_body_1 := candle_body

bars_since_long = bar_index - long_setup_bar
bars_since_short = bar_index - short_setup_bar

// Distance from Peak/Trough 2 to Entry
long_dist_entry = bar_index - long_peak2_bar
long_dist_valid = (long_dist_entry >= long_dist_peaks * 0.7) and (long_dist_entry <= long_dist_peaks * 2)

short_dist_entry = bar_index - short_peak2_bar
short_dist_valid = (short_dist_entry >= short_dist_peaks * 0.7) and (short_dist_entry <= short_dist_peaks * 2)

// Wave Structure Ratio
float long_a = long_height_1 
float long_b = long_max_h2 - long_setup_pl 
bool long_ratio_valid = long_b > 0 and (long_a <= (2.0 * long_b)) 

float short_a = short_height_1 
float short_b = short_setup_ph - short_min_l2 
bool short_ratio_valid = short_b > 0 and (short_a <= (2.0 * short_b)) 

// Engulfing Open
long_engulf_open  = close > open[1]
short_engulf_open = close < open[1]

// Check previous 4 candles
bool valid_prev_4_green = true
bool valid_prev_4_red = true

for i = 1 to 4
    past_body = math.abs(close[i] - open[i])
    past_is_green = close[i] > open[i]
    past_is_red = close[i] < open[i]
    
    if past_is_green and past_body > (0.6 * xATR[i])
        valid_prev_4_green := false
    if past_is_red and past_body > (0.6 * xATR[i])
        valid_prev_4_red := false

// ==========================================
// BOLLINGER BANDS FILTER CHECK
// ==========================================
bool long_bb_valid = false
if long_setup
    if close > bb_basis // Long setup is ABOVE BB Basis
        if display_mode == "All" or display_mode == "Short Lower Half / Long Upper Half"
            // Trough 2 retraces to 80% of the upper half (20% away from basis)
            float upper_retrace_80 = long_t2_basis + 0.2 * (long_t2_upper - long_t2_basis)
            if long_t2_low <= upper_retrace_80
                long_bb_valid := true
    else // Long setup is BELOW BB Basis (Standard Zone)
        if display_mode == "All" or display_mode == "Short Upper Half / Long Lower Half"
            float lower_80 = long_t2_basis - 0.8 * (long_t2_basis - long_t2_lower)
            if long_t2_close < lower_80 // Trough 2 must close below the 80% mark of the lower BB zone
                long_bb_valid := true

bool short_bb_valid = false
if short_setup
    if close < bb_basis // Short setup is BELOW BB Basis
        if display_mode == "All" or display_mode == "Short Lower Half / Long Upper Half"
            // Peak 2 retraces to 80% of the lower half (20% away from basis)
            float lower_retrace_80 = short_p2_basis - 0.2 * (short_p2_basis - short_p2_lower)
            if short_p2_high >= lower_retrace_80
                short_bb_valid := true
    else // Short setup is ABOVE BB Basis (Standard Zone)
        if display_mode == "All" or display_mode == "Short Upper Half / Long Lower Half"
            float upper_80 = short_p2_basis + 0.8 * (short_p2_upper - short_p2_basis)
            if short_p2_high >= upper_80 // Peak 2 must touch the 80% mark of the upper BB zone
                short_bb_valid := true

// ACTIVATE TRADE (With Real-Time Bar Confirmation)
long_cond = (state == 0) and long_setup and long_has_pullback and (bars_since_long >= min_setup_bars) and valid_candle and long_size_valid and green_candle and long_dist_valid and long_ratio_valid and (macd_hist > macd_hist[1]) and long_engulf_open and valid_prev_4_green and long_bb_valid and barstate.isconfirmed

short_cond = (state == 0) and short_setup and short_has_pullback and (bars_since_short >= min_setup_bars) and valid_candle and short_size_valid and red_candle and short_dist_valid and short_ratio_valid and (macd_hist < macd_hist[1]) and short_engulf_open and valid_prev_4_red and short_bb_valid and barstate.isconfirmed

if long_cond
    state := 1
    long_setup := false 
    entry_p := close
    sl_p := close - (xATR * sl_atr_mult)
    float risk = entry_p - sl_p
    tp1_p := entry_p + (risk * tp1_mult)
    tp2_p := entry_p + (risk * tp2_mult)
    tp1_hit := false
    total_trades := total_trades + 1
    current_sig := "LONG"
    
    line.new(bar_index, entry_p, bar_index + line_ext, entry_p, color=color.blue, width=2)
    line.new(bar_index, sl_p, bar_index + line_ext, sl_p, color=color.red, width=2)
    line.new(bar_index, tp1_p, bar_index + line_ext, tp1_p, color=color.green, width=1, style=line.style_dashed)
    line.new(bar_index, tp2_p, bar_index + line_ext, tp2_p, color=color.green, width=2)

if short_cond
    state := -1
    short_setup := false 
    entry_p := close
    sl_p := close + (xATR * sl_atr_mult)
    float risk = sl_p - entry_p
    tp1_p := entry_p - (risk * tp1_mult)
    tp2_p := entry_p - (risk * tp2_mult)
    tp1_hit := false
    total_trades := total_trades + 1
    current_sig := "SHORT"

    line.new(bar_index, entry_p, bar_index + line_ext, entry_p, color=color.blue, width=2)
    line.new(bar_index, sl_p, bar_index + line_ext, sl_p, color=color.red, width=2)
    line.new(bar_index, tp1_p, bar_index + line_ext, tp1_p, color=color.green, width=1, style=line.style_dashed)
    line.new(bar_index, tp2_p, bar_index + line_ext, tp2_p, color=color.green, width=2)

// CLOSE TRADE
if state == 1 
    if high >= tp2_p
        count_tp2 := count_tp2 + 1
        state := 0
        current_sig := "TP2 DONE"
    else if low <= sl_p
        count_sl := count_sl + 1
        state := 0
        current_sig := "SL HIT"
    else if tp1_hit and low <= entry_p
        count_tp1_back := count_tp1_back + 1
        state := 0
        current_sig := "TP1->ENTRY"
    else if high >= tp1_p
        tp1_hit := true

if state == -1 
    if low <= tp2_p
        count_tp2 := count_tp2 + 1
        state := 0
        current_sig := "TP2 DONE"
    else if high >= sl_p
        count_sl := count_sl + 1
        state := 0
        current_sig := "SL HIT"
    else if tp1_hit and high >= entry_p
        count_tp1_back := count_tp1_back + 1
        state := 0
        current_sig := "TP1->ENTRY"
    else if low <= tp1_p
        tp1_hit := true

// ==========================================
// 5. DISPLAY & DASHBOARD
// ==========================================
plotshape(long_cond, "Buy Label", shape.labelup, location.belowbar, color.green, 0, "BUY", color.white, size=size.small)
plotshape(short_cond, "Sell Label", shape.labeldown, location.abovebar, color.red, 0, "SELL", color.white, size=size.small)

win_rate = (count_tp2 + count_sl) > 0 ? (count_tp2 / (count_tp2 + count_sl)) * 100 : 0

var table stats = table.new(position.top_right, 2, 6, border_color=color.black, border_width=1)
if barstate.islast
    table.cell(stats, 0, 0, "SIGNAL", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 0, current_sig, bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 0, 1, "TOTAL TRADES", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 1, str.tostring(total_trades), bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 0, 2, "TP1 > ENTRY", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 2, str.tostring(count_tp1_back), bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 0, 3, "TP2 DONE", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 3, str.tostring(count_tp2), bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 0, 4, "SL HIT", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 4, str.tostring(count_sl), bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 0, 5, "WIN RATE", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
    table.cell(stats, 1, 5, str.tostring(win_rate, "#.##") + "%", bgcolor=color.white, text_color=color.black, text_font_family=font.family_monospace)
````
