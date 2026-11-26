# Adaptive Dynamic BB Clouds [PRO] - Auto MA & Double Squeeze

- url: https://www.tradingview.com/script/VgYMvYtn/
- type: indicator
- pine_id: PUB;d99df66f836c49f9baebe48d04c446fc
- version: 1.0

## Description

Welcome to the Adaptive Dynamic BB Clouds. Traditional Bollinger Bands use a static standard deviation multiplier (usually 2.0) and a fixed moving average (SMA). However, market conditions are constantly shifting between ranging, trending, and highly volatile states.
This indicator introduces an Adaptive Algorithmic Engine that dynamically adjusts both the Basis Line (Moving Average) and the Band Width based on real-time Volume, Trend Strength (ADX), and Momentum (RSI).
🌟 Core Features:
1. Auto-Adaptive Basis Line (Smart MA)
Instead of locking you into one moving average, the script reads the market and automatically selects the best MA:
VWMA (Volume Weighted): Activates automatically when there is a significant volume surge (Relative Volume > 1.3) to track institutional money flow.
EMA (Exponential): Activates when a strong trend is detected (ADX > 25) to reduce lag and stick closer to the price.
SMA (Simple): Defaults to this during flat, ranging, or low-volume markets to avoid false signals and whipsaws.
2. Multi-Factor Dynamic Bands
The width of the bands is no longer static. The script calculates a real-time weight and magnitude based on:
Trend (ADX): Expands bands during strong trends.
Volume (RelVol): Expands bands during high volume breakouts.
Momentum (RSI): Expands bands when approaching overbought/oversold extremes.
If the market is dead, the bands contract tightly, filtering out market noise.
3. MTF Clean Clouds (Macro vs. Micro)
The script automatically detects a logical Lower Timeframe (LTF) based on your current chart. It plots the Macro (Current TF) bands as thick lines and the Micro (LTF) bands as thin lines. The space between them is filled with a clean gradient cloud. This visually represents the "Tension Zone" or dynamic Support/Resistance.
4. Double Squeeze & Squeeze Background
Squeeze Background: When the bands contract inside the Keltner Channels, the chart background turns gray, indicating a volatility compression (Accumulation phase).
Double Squeeze (Purple Diamond 💎): A rare confluence signal. When both the Macro TF and Micro TF enter a squeeze at the exact same time, a purple diamond appears. This indicates an extremely high probability of an imminent, explosive volatility expansion.
5. Real-Time Dashboard
A sleek, customizable panel on the chart displays real-time metrics for ADX, Relative Volume, and the current "Squeeze %" strength, so you always know what is driving the indicator.
⚙️ How to Use:
Accumulation: Look for gray backgrounds (Squeeze) and high Squeeze %. Do not trade breakouts yet; wait for the energy to build up.
Breakout: When the background color disappears and bands expand, trade in the direction of the breakout.
Confluence: A purple diamond 💎 followed by a volume surge (shown in green on the dashboard) is a strong signal for a major move.
Note: 100% Repaint-Free. Built securely with lookahead_off and na() fallbacks.
(Disclaimer: This script is for educational purposes only and does not guarantee financial returns. Always use proper risk management.)

## Source Code

````pine
//@version=6
indicator(shorttitle="Adaptive_Dyn_BB_V5", title="Adaptive Clean BB Clouds MASTERPIECE", overlay=true)

// --- TOOLTIPS (AÇIKLAMALAR) ---
TT_MA = "AUTO (Adaptive) selected:\n• VWMA for volume breakouts\n• EMA for strong trends\n• SMA for flat/ranging markets."
TT_DYN = "Band width dynamically adapts to Volume, Trend (ADX), and Momentum (RSI)."

// --- MAIN INPUTS (ANA GİRDİLER) ---
grp_main  = "Main Settings / Ana Ayarlar"
length    = input.int(20,       "Length / Uzunluk", minval = 1, group=grp_main)
maType    = input.string("AUTO (Adaptive / Adaptif)", "Base MA / Temel MA", options = ["AUTO (Adaptive / Adaptif)", "SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], tooltip = TT_MA, group=grp_main)
src       = input(close,        "Source / Kaynak", group=grp_main)
base_mult = input.float(2.0,    "Base Mult / Temel Çarpan", minval = 0.001, maxval = 50, group=grp_main)

// --- DYNAMIC & SQUEEZE INPUTS (DİNAMİK VE SIKIŞMA) ---
grp_dyn    = "Dynamic Settings / Dinamik Ayarlar"
useDynamic = input.bool(true, "Use Dynamic / Dinamik Çarpan", group=grp_dyn, tooltip=TT_DYN)
smoothLen  = input.int(8,     "Smoothing / Yumuşatma", minval=1, group=grp_dyn)
adx_len    = input.int(14,    "ADX Length / ADX Uzunluğu", minval=2, group=grp_dyn)
rsi_mult   = input.float(0.4, "RSI Elasticity / RSI Esneme Payı", minval=0.1, maxval=1.0, step=0.1, group=grp_dyn)

grp_sqz    = "Squeeze Settings / Sıkışma Ayarları"
kc_mult    = input.float(1.5, "KC Multiplier / Keltner Katsayısı", minval=0.5, maxval=3.0, step=0.1, group=grp_sqz)
show_sqz_bg = input.bool(true, "Show Squeeze Background / Arka Planı Boya", group=grp_sqz)
filter_sqz  = input.bool(false,"Filter Weak Squeezes (ADX>20) / Zayıf Sıkışmaları Filtrele", group=grp_sqz) 

// --- DASHBOARD INPUTS (BİLGİ PANELİ AYARLARI) ---
grp_dash   = "Dashboard / Bilgi Paneli"
show_panel = input.bool(true, "Show Info Panel / Paneli Göster", group=grp_dash)
panel_pos_str = input.string("Top Right", "Position / Pozisyon", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_dash)
panel_size_str = input.string("Normal", "Text Size / Yazı Boyutu", options=["Small", "Normal", "Large"], group=grp_dash)

// --- STYLE & COLORS (STİL VE RENKLER) ---
grp_col = "Style & Colors / Stil ve Renkler"
col_up_cloud = input.color(color.new(#FF6B6B, 0), "Upper Cloud / Üst Bulut", group=grp_col) 
col_dn_cloud = input.color(color.new(#20C997, 0), "Lower Cloud / Alt Bulut", group=grp_col) 
col_micro    = input.color(color.new(#FFD166, 0), "Micro Bands / Alt Bantlar", group=grp_col) 
col_basis_n  = input.color(color.rgb(41, 98, 255), "Basis Normal / Orta Çizgi Normal", group=grp_col)
col_basis_sq = input.color(color.red, "Basis Squeeze / Orta Çizgi Sıkışma", group=grp_col)
col_sqz_bg   = input.color(color.new(color.gray, 92), "Squeeze BG / Sıkışma Arka Planı", group=grp_col)

// --- AUTOMATIC LOWER TIMEFRAME (LTF) FINDER ---
get_lower_tf() =>
    string tf = "240"
    if timeframe.ismonthly
        tf := "W"
    else if timeframe.isweekly
        tf := "D"
    else if timeframe.isdaily
        tf := "240" 
    else if timeframe.isminutes
        if timeframe.multiplier >= 240
            tf := "60"  
        else if timeframe.multiplier >= 120
            tf := "30"  
        else if timeframe.multiplier >= 60
            tf := "15"  
        else if timeframe.multiplier >= 30
            tf := "5"   
        else if timeframe.multiplier >= 15
            tf := "3"   
        else if timeframe.multiplier >= 5
            tf := "1"   
        else
            tf := "1"   
    else
        tf := "1"
    tf

target_ltf = get_lower_tf()

// --- MTF & ADAPTIVE CALCULATION ---
calc_bb_data(_src, _length, _maType, _base_mult, _useDynamic, _smoothLen, _kc_mult, _adx_len, _rsi_mult) =>
    [diplus, diminus, _adx] = ta.dmi(_adx_len, _adx_len)
    volSma = ta.sma(volume, 20)
    relVol = volume > 0 and volSma > 0 ? (volume / volSma) : 1.0 
    _rsi = ta.rsi(_src, 14)

    val_sma  = ta.sma(_src, _length)
    val_ema  = ta.ema(_src, _length)
    val_rma  = ta.rma(_src, _length)
    val_wma  = ta.wma(_src, _length)
    val_vwma = ta.vwma(_src, _length)

    float _basis = na
    if _maType == "AUTO (Adaptive / Adaptif)"
        if relVol > 1.3 
            _basis := val_vwma
        else if _adx > 25 
            _basis := val_ema
        else 
            _basis := val_sma
    else
        switch _maType
            "SMA" => _basis := val_sma
            "EMA" => _basis := val_ema
            "SMMA (RMA)" => _basis := val_rma
            "WMA" => _basis := val_wma
            "VWMA" => _basis := val_vwma

    weight_adx = math.min(2.5, math.max(0.5, nz(_adx, 0) / 20))
    weight_vol = math.min(3.0, math.max(0.5, nz(relVol, 1.0)))
    weight_rsi = math.min(2.5, 0.5 + (math.abs(nz(_rsi, 50) - 50) / 20))

    mag_adx = math.max(0.7, math.min(1.5, nz(_adx, 0) / 20)) 
    mag_vol = math.max(0.7, math.min(1.5, nz(relVol, 1.0)))
    mag_rsi = 1.0 + ((math.abs(nz(_rsi, 50) - 50) / 50) * _rsi_mult) 

    totalWeight = weight_adx + weight_vol + weight_rsi
    raw_dynamicFactor = totalWeight > 0 ? ((mag_adx * weight_adx) + (mag_vol * weight_vol) + (mag_rsi * weight_rsi)) / totalWeight : 1.0
    
    raw_dynamicFactor := na(raw_dynamicFactor) or raw_dynamicFactor <= 0 ? 1.0 : raw_dynamicFactor
    smoothed_dynamicFactor = ta.ema(raw_dynamicFactor, _smoothLen)
    smoothed_dynamicFactor := na(smoothed_dynamicFactor) ? 1.0 : smoothed_dynamicFactor
    
    final_mult = _useDynamic ? (_base_mult * smoothed_dynamicFactor) : _base_mult

    dev = final_mult * ta.stdev(_src, _length)
    _upper = _basis + dev
    _lower = _basis - dev

    atr = ta.atr(_length)
    kc_dev = _kc_mult * atr 
    kc_upper = _basis + kc_dev
    kc_lower = _basis - kc_dev
    _isSqueeze = (_upper < kc_upper) and (_lower > kc_lower)
    
    sqz_strength = (_upper != _lower) ? math.max(0, (kc_upper - _upper) / (_upper - _lower)) : 0.0

    [_basis, _upper, _lower, _isSqueeze, _adx, relVol, sqz_strength]

// --- FETCH DATA ---
[macro_basis, macro_upper, macro_lower, macro_sqz, mac_adx, mac_vol, mac_sqz_str] = calc_bb_data(src, length, maType, base_mult, useDynamic, smoothLen, kc_mult, adx_len, rsi_mult)
[_, raw_micro_upper, raw_micro_lower, micro_sqz, _, _, _] = request.security(syminfo.tickerid, target_ltf, calc_bb_data(src, length, maType, base_mult, useDynamic, smoothLen, kc_mult, adx_len, rsi_mult), lookahead=barmerge.lookahead_off)

micro_upper = na(raw_micro_upper) ? macro_upper : raw_micro_upper
micro_lower = na(raw_micro_lower) ? macro_lower : raw_micro_lower

// =========================================================================
// --- VISUAL DESIGN (CLEAN CLOUDS) ---
// =========================================================================

valid_squeeze = filter_sqz ? (macro_sqz and mac_adx > 20) : macro_sqz
bgcolor(show_sqz_bg and valid_squeeze ? col_sqz_bg : na, title="Squeeze Background")

basis_color = macro_sqz ? col_basis_sq : col_basis_n
plot(macro_basis, "Main Basis", color=basis_color, linewidth=2)

p_macro_up = plot(macro_upper, "Main Upper Band", color=color.new(col_up_cloud, 0), linewidth=2)
p_micro_up = plot(micro_upper, "Micro Upper Band", color=color.new(col_micro, 0), linewidth=1)
fill(p_macro_up, p_micro_up, title="Upper Cloud", color=color.new(col_up_cloud, 85))

p_macro_dn = plot(macro_lower, "Main Lower Band", color=color.new(col_dn_cloud, 0), linewidth=2)
p_micro_dn = plot(micro_lower, "Micro Lower Band", color=color.new(col_micro, 0), linewidth=1)
fill(p_macro_dn, p_micro_dn, title="Lower Cloud", color=color.new(col_dn_cloud, 85))

double_sqz = macro_sqz and micro_sqz and not (macro_sqz[1] and micro_sqz[1])
plotshape(double_sqz, title="Double Squeeze Signal", style=shape.diamond, location=location.top, color=color.new(color.purple, 0), size=size.small)

// =========================================================================
// --- DASHBOARD (BİLGİ PANELİ YENİ TASARIM) ---
// =========================================================================
// Pozisyon ve Boyut Ayarları
panel_pos = panel_pos_str == "Top Right" ? position.top_right : panel_pos_str == "Top Left" ? position.top_left : panel_pos_str == "Bottom Right" ? position.bottom_right : position.bottom_left
panel_size = panel_size_str == "Small" ? size.small : panel_size_str == "Normal" ? size.normal : size.large

// Solid (Mat) Arka Plan Renkleri (Okunabilirliği maksimuma çıkarır)
bg_hdr  = color.new(#1E222D, 5) // Koyu Lacivert/Gri (Başlıklar için)
bg_cell = color.new(#131722, 5) // Daha koyu mat arka plan (Hücreler için)
txt_col = color.white           // Beyaz Yazı

var table infoTable = table.new(panel_pos, 2, 5, border_width = 1, border_color = color.new(color.gray, 60))

if show_panel
    // Başlıklar
    table.cell(infoTable, 0, 0, "METRIC", text_color=color.gray, text_size=panel_size, bgcolor=bg_hdr)
    table.cell(infoTable, 1, 0, "STATUS", text_color=color.gray, text_size=panel_size, bgcolor=bg_hdr)
    
    // ADX (Trend)
    table.cell(infoTable, 0, 1, "Trend (ADX):", text_color=txt_col, text_size=panel_size, bgcolor=bg_cell)
    table.cell(infoTable, 1, 1, str.tostring(mac_adx, "#.#"), text_color=mac_adx > 25 ? #00E676 : #FF5252, text_size=panel_size, bgcolor=bg_cell)
    
    // Hacim (Volume)
    table.cell(infoTable, 0, 2, "Vol Surge:", text_color=txt_col, text_size=panel_size, bgcolor=bg_cell)
    table.cell(infoTable, 1, 2, str.tostring(mac_vol, "#.##x"), text_color=mac_vol > 1.2 ? #00E676 : color.gray, text_size=panel_size, bgcolor=bg_cell)
    
    // Sıkışma (Market State)
    sqz_text  = macro_sqz ? (micro_sqz ? "DOUBLE SQZ!" : "SQUEEZING") : "EXPANDING"
    sqz_color = macro_sqz ? (micro_sqz ? #E040FB : #FF9800) : #00E676
    table.cell(infoTable, 0, 3, "Market State:", text_color=txt_col, text_size=panel_size, bgcolor=bg_cell)
    table.cell(infoTable, 1, 3, sqz_text, text_color=sqz_color, text_size=panel_size, bgcolor=bg_cell)

    // Sıkışma Yüzdesi
    sqz_str_pct = math.round(mac_sqz_str * 100)
    table.cell(infoTable, 0, 4, "Squeeze %:", text_color=txt_col, text_size=panel_size, bgcolor=bg_cell)
    table.cell(infoTable, 1, 4, str.tostring(sqz_str_pct) + "%", text_color=macro_sqz ? color.yellow : color.gray, text_size=panel_size, bgcolor=bg_cell)

// =========================================================================
// --- ADVANCED ALERTS (GÜVENLİ ALARMLAR) ---
// =========================================================================
sqz_started  = macro_sqz and not macro_sqz[1]
sqz_ended    = not macro_sqz and macro_sqz[1]
cross_upper  = ta.crossover(src, macro_upper)
cross_lower  = ta.crossunder(src, macro_lower)

alertcondition(sqz_started, title="1. Squeeze Started", message="Adaptive BB: Squeeze started on {{ticker}} at price {{close}}")
alertcondition(sqz_ended,   title="2. Squeeze Ended (Breakout)", message="Adaptive BB: Squeeze ended on {{ticker}} at price {{close}}! Expansion incoming.")
alertcondition(double_sqz,  title="3. DOUBLE SQUEEZE", message="Adaptive BB: DOUBLE SQUEEZE on {{ticker}} at price {{close}}! Big volatility expected.")
alertcondition(cross_upper, title="4. Upper Band Break", message="Adaptive BB: {{ticker}} crossed ABOVE upper band at {{close}}")
alertcondition(cross_lower, title="5. Lower Band Break", message="Adaptive BB: {{ticker}} crossed BELOW lower band at {{close}}")
````
