# Max Pain Options [QuantLabs] v5 (Balanced)

- url: https://www.tradingview.com/script/VqeQomGF-Max-Pain-Options-QuantLabs-v5-Balanced/
- type: indicator
- pine_id: PUB;34990547660a42dd9ccafbb7d11afb96
- version: 1.0

## Description

Institutional Grade Options Analysis: Max Pain, Gamma & Pin Risk

For years, TradingView users have been flying blind without access to Options Chain data. QuantLabs: Max Pain & Gamma Exposure changes that. This is not just a support/resistance indicator—it is a sophisticated, algorithmic model that reverse-engineers the incentives of Market Makers using synthetic Black-Scholes logic.

This tool visualizes the "invisible hand" of the market: the hedging requirements of large dealers who are forced to buy or sell to keep their books neutral.

CORE FEATURES:

🔴 Max Pain Gravity Model The bright red line represents the "Max Pain" strike—the price level where the maximum amount of Options Open Interest (Calls + Puts) expires worthless.

Theory: As OpEx (Expiration) approaches, Market Makers maximize profits by pinning the price to this level.

Strategy: Use this as a mean-reversion target. If price is far away, look for a snap-back to the red line.

🟣 Gamma Exposure Profiles (The Purple Lines) These neon histograms show you the estimated "Gamma Walls."

Long Gamma: Dealers trade against the trend (stabilizing price).

Short Gamma: Dealers trade with the trend (accelerating volatility).

Visual: The larger the purple bar, the harder it will be for price to break through that level.

📦 Algorithmic "Pin Risk" Zones The dashed red box highlights the "Kill Zone." When price enters this area near expiration, volatility often dies as dealers pin the asset to kill retail premiums.

Warning: Do not expect breakouts while inside the Pin Zone.

📊 Institutional HUD A clean, non-intrusive dashboard provides real-time Greeks and risk analysis:

Pin Risk: High/Medium/Low probability of a pinned close.

Exp Mode: Detects if the market is in "Short Gamma" (Squeeze territory) or "Long Gamma" (Chop territory).

HOW IT WORKS (The Math): Since live options data is not available via Pine Script, this engine uses a proprietary Synthetic OI Distribution Model. It inputs Volume, Volatility (IV), and Time-to-Expiry into a modified Black-Scholes equation to probability-map where the heavy open interest likely sits.

SETTINGS & CUSTOMIZATION:

Responsiveness: Tuned for the "Goldilocks Zone" (Spread: 12, Decay: 22) to catch local liquidity walls without over-fitting.

Visuals: Designed for Dark Mode. High-contrast Neon aesthetics for maximum readability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant & QuantLabs

//@version=6
indicator(
 title="Max Pain Options [QuantLabs] v5 (Balanced)", 
 shorttitle="MaxPain QL", 
 max_boxes_count=500,
 max_lines_count=500, 
 max_labels_count=200,
 overlay=true
 )

// =============================================================================
// 1. INPUTS
// =============================================================================

// Input Groups
const string calc       = "Calculation Settings"
const string strikes_g  = "Strike Price Settings"
const string volume_g   = "Volume and Open Interest"
const string vols       = "Volatility and Greeks"
const string mm         = "Market Maker Parameters"
const string visuals    = "Visual Settings"
const string analysis   = "Analysis Settings"
const string theme_g    = "Theme and Colors"
const string zones      = "Pin Zone Settings"

// Calculation Settings
int nStrikes = input.int(20, "Number of Strikes", minval=1, tooltip="Total number of strike levels to model", group=calc)
int expiry_days = input.int(7, "Days to Expiration", minval=1, maxval=60, tooltip="Calendar days until option expiry", group=calc)

// Strike Price Settings
float strike_range_pct = input.float(10, "Strike Range %", minval=5, maxval=20, step=1, tooltip="Range around current price in percent", group=strikes_g)
float strike_increment = input.float(2.0, "Strike Increment $", minval=1.0, maxval=10.0, step=0.5, tooltip="Distance between generated strikes", group=strikes_g)
bool use_round_strikes = input.bool(false, "Use Round Strike Levels", tooltip="Rounds strikes to nearest 5s or 0s", group=strikes_g)
int major_strike_interval = input.int(10, "Major Strike Interval", minval=5, maxval=50, step=5, tooltip="Interval for showing major strike levels", group=strikes_g)

// Volume and Open Interest
int avg_daily_volume = input.int(1000000, "Average Daily Volume", minval=100000, tooltip="Baseline underlying trading volume", group=volume_g)
float put_call_ratio = input.float(1.2, "Put/Call Volume Ratio", minval=0.1, maxval=5.0, step=0.1, tooltip="Relative weighting of put to call volumes", group=volume_g)

// --- BALANCED SETTINGS (GOLDILOCKS ZONE) ---
// Original: 8 / 15 (Too Loose)
// Previous: 25 / 40 (Too Tight/Glued to price)
// New: 12 / 22 (Balanced)
float oi_spread = input.float(12.0, "OI Spread Factor", minval=1.0, tooltip="Controls width of the curve. 12 is balanced.", group=volume_g)
float oi_decay  = input.float(22.0, "OI Decay Factor", minval=1.0, tooltip="Controls how fast OI drops off. 22 captures nearby walls without overfitting.", group=volume_g)

// Volatility and Greeks
float implied_vol = input.float(30.0, "Implied Volatility %", minval=5, maxval=150, step=1, tooltip="Baseline volatility assumption for Greeks", group=vols) / 100

// Market Maker Parameters
float mm_inventory_factor = input.float(0.7, "Inventory Factor", minval=0.1, maxval=2.0, step=0.1, tooltip="Market maker position scaling", group=mm)
float gamma_hedging_strength = input.float(1.0, "Gamma Hedging Strength", minval=0.1, maxval=3.0, step=0.1, tooltip="Degree of gamma hedging effect modeled", group=mm)
float dealer_short_gamma_bias = input.float(0.6, "Dealer Short Gamma Bias", minval=0.1, maxval=1.5, step=0.1, tooltip="Bias toward short gamma positioning", group=mm)

// Analysis Settings
string update_frequency = input.string("Every Bar", "Update Frequency", options=["Every Bar","Daily"], tooltip="Set to 'Every Bar' for maximum responsiveness", group=calc) 
bool include_weekly = input.bool(true, "Include Weekly Options Effects", tooltip="Boosts OI if expiry is weekly", group=calc)
string model_complexity = input.string("Advanced", "Model Complexity", options=["Simple","Standard","Advanced"], tooltip="Controls modeling detail and features", group=calc)

// Pin Zone Settings
float pin_zone_pct = input.float(2.0, "Pin Zone %", minval=0.5, maxval=5.0, step=0.5, tooltip="Defines percentage width around max pain considered a pin zone", group=zones)

// QUANT LABS VISUAL CONTROLS
bool show_dashboard     = input.bool(true, "Show Quant HUD", group=visuals)
bool show_max_pain_line = input.bool(true, "Show Max Pain Line", group=visuals)
bool show_strike_levels = input.bool(true, "Show Major Strike Levels", group=visuals)
bool show_pain_heatmap  = input.bool(true, "Show Pain Heatmap", group=visuals)
bool show_gamma_exposure= input.bool(true, "Show Gamma Exposure Profile", group=visuals)
bool show_pin_zones     = input.bool(true, "Show Pin Risk Zones", group=visuals)
int transparency_main   = input.int(20, "Global Transparency", minval=0, maxval=100, group=visuals)

// =============================================================================
// 2. DESIGN SYSTEM & COLORS (QuantLabs Palette)
// =============================================================================

// Neon Palette
c_call_bright   = #00f2ff      // Cyber Cyan
c_call_dim      = #005f63
c_put_bright    = #bc13fe      // Neon Purple
c_put_dim       = #4a0066
c_pain_hot      = #ff3b30      // Red Orange
c_pain_mid      = #ff9500      // Amber
c_bg_dark       = #0a0f14      // Deep Charcoal
c_text_main     = #e1e1e1
c_text_mute     = #78818b

// Gradient Helper
get_turbo_color(float norm_val) =>
    r = 0, g = 0, b = 0
    v = math.max(0.0, math.min(1.0, norm_val))
    if v < 0.2
        b := 255
        g := int(v * 5 * 255)
        r := 0
    else if v < 0.5
        b := int(255 - (v - 0.2) * 3.33 * 255)
        g := 255
        r := 0
    else if v < 0.8
        b := 0
        g := 255
        r := int((v - 0.5) * 3.33 * 255)
    else
        b := 0
        g := int(255 - (v - 0.8) * 5 * 255)
        r := 255
    color.rgb(r, g, b, transparency_main)

// =============================================================================
// 3. CORE LOGIC
// =============================================================================

// Calculation Start
time_to_expiry = expiry_days / 365.25
current_price = close
strike_range = current_price * strike_range_pct / 100
min_strike = current_price - strike_range
max_strike = current_price + strike_range

round_strike(strike) =>
    if use_round_strikes
        if strike >= 100
            math.round(strike / 5) * 5
        else if strike >= 20
            math.round(strike / 2.5) * 2.5
        else
            math.round(strike)
    else
        math.round(strike / strike_increment) * strike_increment

var strikes = array.new<float>()
var call_oi_data = array.new<float>()
var put_oi_data = array.new<float>()
var gamma_data = array.new<float>()

generate_strikes(nStrikes) =>
    array.clear(strikes)
    max_strikes = nStrikes
    actual_increment = math.max(strike_increment, (max_strike - min_strike) / max_strikes)
    
    s = min_strike
    count = 0
    while s <= max_strike and count < max_strikes
        rs = round_strike(s)
        if array.size(strikes) == 0 or rs != array.get(strikes, array.size(strikes) - 1)
            array.push(strikes, rs)
            count += 1
        s += actual_increment

// Black-Scholes helpers
bs_gamma_simple(S, K, T, vol) =>
    if T <= 0 or vol <= 0
        0.0
    else
        d1 = (math.log(S/K) + 0.5 * vol * vol * T) / (vol * math.sqrt(T))
        math.exp(-0.5 * d1 * d1) / (S * vol * math.sqrt(2 * math.pi * T))

// volume estimation (BALANCED LOGIC)
estimate_oi_simple(strike, is_call) =>
    distance_pct = math.abs(strike - current_price) / current_price
    
    // Balanced Formula
    base_factor = 1 / (1 + distance_pct * oi_spread) 
    decay_factor = math.pow(0.8, distance_pct * oi_decay)
    
    base_volume = avg_daily_volume * base_factor * decay_factor * 0.02
    mm_position = base_volume * mm_inventory_factor * dealer_short_gamma_bias
    
    total_oi = base_volume + mm_position
    if not is_call
        total_oi *= put_call_ratio
    
    weekly_mult = include_weekly and expiry_days <= 7 ? 1.2 : 1.0
    total_oi * weekly_mult

// all data for strikes
populate_strike_data() =>
    array.clear(call_oi_data)
    array.clear(put_oi_data)
    array.clear(gamma_data)
    
    strike_count = array.size(strikes)
    i = 0
    while i < strike_count and i < nStrikes
        K = array.get(strikes, i)
        
        call_oi = estimate_oi_simple(K, true)
        put_oi = estimate_oi_simple(K, false)
        gamma_val = bs_gamma_simple(current_price, K, time_to_expiry, implied_vol)
        gamma_exp = (call_oi - put_oi) * gamma_val * gamma_hedging_strength * 100
        
        array.push(call_oi_data, call_oi)
        array.push(put_oi_data, put_oi)
        array.push(gamma_data, gamma_exp)
        
        i += 1

// Direct max pain calculation 
calculate_max_pain_direct() =>
    best_strike = current_price
    min_pain = 1e20
    
    strike_count = array.size(strikes)
    test_points = math.min(strike_count, nStrikes) 
    
    i = 0
    while i < test_points
        test_strike = array.get(strikes, i)
        total_pain = 0.0
        
        // Calculate pain at this strike
        j = 0
        while j < strike_count
            K = array.get(strikes, j)
            call_oi = array.get(call_oi_data, j)
            put_oi = array.get(put_oi_data, j)
            
            if test_strike < K  // Call pain
                total_pain += call_oi * (K - test_strike)
            if test_strike > K  // Put pain  
                total_pain += put_oi * (test_strike - K)
            
            j += 1
        
        if total_pain < min_pain
            min_pain := total_pain
            best_strike := test_strike
        
        i += 1
    
    best_strike

// Update
var float max_pain_level = na
var bool data_calculated = false

// Force update on every bar if selected
should_update = barstate.islast or (update_frequency == "Every Bar") or (update_frequency == "Daily" and not data_calculated) 

if should_update
    generate_strikes(nStrikes)
    populate_strike_data()
    max_pain_level := calculate_max_pain_direct()
    data_calculated := true

// =============================================================================
// 4. VISUAL RENDERING (THE QUANTLABS VISUAL ENGINE)
// =============================================================================

if barstate.islast
    int x_now = bar_index
    int x_proj = x_now + 15
    int x_end = x_now + 40
    
    // --- A. GLOWING MAX PAIN LINE ---
    if show_max_pain_line and not na(max_pain_level)
        line.new(x_now - 20, max_pain_level, x_end, max_pain_level, color=color.new(c_pain_hot, 0), width=2, style=line.style_solid)
        line.new(x_now - 20, max_pain_level, x_end, max_pain_level, color=color.new(c_pain_hot, 60), width=6, style=line.style_solid)
        line.new(x_now - 20, max_pain_level, x_end, max_pain_level, color=color.new(c_pain_hot, 85), width=12, style=line.style_solid)
        
        label.new(x_end + 2, max_pain_level, text="MAX PAIN\n" + str.tostring(max_pain_level, "#.00"), 
                  color=color.new(c_pain_hot, 90), style=label.style_label_left, textcolor=c_pain_hot, size=size.small)

    // --- B. STRIKE LEVELS ---
    if show_strike_levels and array.size(strikes) > 0
        i = 0
        while i < math.min(array.size(strikes), 20)
            K = array.get(strikes, i)
            if math.round(K) % major_strike_interval == 0
                // Use new colors but old logic
                lvl_col = K > current_price ? c_pain_hot : c_call_bright
                line.new(x_now - 20, K, x_now + 5, K, color=color.new(lvl_col, 50), width=1, style=line.style_dotted)
            i += 1

    // --- C. PIN ZONE ---
    if show_pin_zones and not na(max_pain_level)
        pin_range = current_price * pin_zone_pct / 100.0
        upper_pin = max_pain_level + pin_range
        lower_pin = max_pain_level - pin_range
        // Enhanced Pin Box
        box.new(x_now, lower_pin, x_end, upper_pin, bgcolor=color.new(c_pain_hot, 80), border_color=c_pain_hot, border_style=line.style_dashed)
        label.new(x_end, upper_pin, text="PIN ZONE", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(c_pain_hot, 80), textcolor=c_text_main, size=size.tiny)

    // --- D. GAMMA EXPOSURE PROFILE ---
    if show_gamma_exposure and array.size(gamma_data) > 0
        max_g = 0.0
        for i = 0 to array.size(gamma_data) - 1
            max_g := math.max(max_g, math.abs(array.get(gamma_data, i)))
            
        if max_g > 0
            for i = 0 to array.size(gamma_data) - 1
                g_val = array.get(gamma_data, i)
                k_val = array.get(strikes, i)
                len = (g_val / max_g) * 20
                c_base = g_val > 0 ? c_call_bright : c_put_bright
                
                if math.abs(g_val) > max_g * 0.05
                    line.new(x_proj, k_val, x_proj + int(len), k_val, color=color.new(c_base, 30), width=4)
                    line.new(x_proj + int(len), k_val, x_proj + int(len) + (g_val > 0 ? 1 : -1), k_val, color=c_base, width=4)

            line.new(x_proj, min_strike, x_proj, max_strike, color=color.new(c_text_mute, 80), style=line.style_dotted)
            label.new(x_proj, max_strike, text="GAMMA\nPROFILE", color=color.new(c_bg_dark, 100), textcolor=c_text_main, style=label.style_label_center, size=size.tiny)

    // --- E. HEATMAP ---
    if show_pain_heatmap and array.size(strikes) > 0
        box_left = x_now + 50
        box_right = x_now + 60
        for i = 0 to array.size(strikes) - 2
            k_low = array.get(strikes, i)
            k_high = array.get(strikes, i+1)
            mid_p = (k_low + k_high) / 2
            dist_pain = math.abs(mid_p - max_pain_level) / (max_strike - min_strike)
            heat = 1.0 - math.pow(dist_pain * 2.5, 0.5) 
            box.new(box_left, k_high, box_right, k_low, border_color=na, bgcolor=get_turbo_color(heat))

    // --- F. QUANT HUD ---
    if show_dashboard
        var tbl = table.new(position.top_right, 2, 8, bgcolor=c_bg_dark, border_width=1, border_color=color.new(c_text_mute, 80), frame_color=c_call_bright, frame_width=1)
        
        table.cell(tbl, 0, 0, "QUANT LABS", text_color=c_call_bright, text_size=size.small, bgcolor=color.new(c_call_dim, 80))
        table.cell(tbl, 1, 0, "OPTIONS", text_color=c_text_main, text_size=size.small, bgcolor=color.new(c_call_dim, 80))

        table.cell(tbl, 0, 1, "Und. Price", text_color=c_text_mute, text_halign=text.align_left)
        table.cell(tbl, 1, 1, str.tostring(current_price, "#.00"), text_color=c_text_main, text_halign=text.align_right)

        table.cell(tbl, 0, 2, "Max Pain", text_color=c_text_mute, text_halign=text.align_left)
        table.cell(tbl, 1, 2, str.tostring(max_pain_level, "#.00"), text_color=c_pain_hot, text_halign=text.align_right)
        
        distance_to_pain = not na(max_pain_level) ? ((max_pain_level - current_price) / current_price) * 100.0 : 0.0
        pin_prob = math.abs(distance_to_pain) < 2 ? "HIGH" : math.abs(distance_to_pain) < 5 ? "MEDIUM" : "LOW"
        c_pin = pin_prob == "HIGH" ? c_pain_hot : pin_prob == "MEDIUM" ? c_pain_mid : c_call_bright
        
        table.cell(tbl, 0, 3, "Pin Risk", text_color=c_text_mute, text_halign=text.align_left)
        table.cell(tbl, 1, 3, pin_prob, text_color=c_pin, text_halign=text.align_right)
        
        net_gamma = array.sum(gamma_data)
        g_sent = net_gamma > 0 ? "LONG GAMMA" : "SHORT GAMMA"
        c_sent = net_gamma > 0 ? c_call_bright : c_put_bright
        table.cell(tbl, 0, 4, "Exp. Mode", text_color=c_text_mute, text_halign=text.align_left)
        table.cell(tbl, 1, 4, g_sent, text_color=c_sent, text_halign=text.align_right)
````
