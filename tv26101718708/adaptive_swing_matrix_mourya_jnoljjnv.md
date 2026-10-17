# Adaptive Swing Matrix | Mourya

- url: https://www.tradingview.com/script/jNOLjjNV-Adaptive-Swing-Matrix-Mourya/
- type: indicator
- pine_id: PUB;59f60796da404b23b60adca871d9d674
- version: 1.0

## Description

This indicator provides a Multi-Timeframe (MTF) table matrix designed to display the real-time states of several standard momentum and trend indicators across 11 user-defined timeframes simultaneously.

The primary purpose of this script is to consolidate chart real estate. By organizing MTF data into a single table, it allows users to monitor higher-timeframe trends and oscillator states without needing to continuously switch chart intervals or clutter their screen with multiple lower panes.

[b]Indicator Logic & Components:[/b]
This matrix tracks the following standard indicators across the user's chosen timeframes:

[b]Trend (EMA Crossover):[/b] Evaluates a fast EMA crossing a medium or slow EMA, filtered by a macro 200-period baseline EMA.

[b]RSI (Relative Strength Index): [/b]Displays the current RSI value, color-coded based on user-defined breakout/breakdown thresholds.

[b]MFI (Money Flow Index): [/b]Displays volume-weighted momentum.

[b]ADX (Average Directional Index):[/b] Evaluates trend strength to filter out sideways consolidation periods.

[b]MACD (Moving Average Convergence Divergence):[/b] Evaluates the relationship between the MACD line and the Signal line relative to the zero-line. The matrix uses the following acronyms to display the exact MACD state:

AZPCO: Above Zero, Positive Crossover (MACD is > 0 and MACD > Signal)

AZNCO: Above Zero, Negative Crossover (MACD is > 0 and MACD < Signal)

BZPCO: Below Zero, Positive Crossover (MACD is < 0 and MACD > Signal)

BZNCO: Below Zero, Negative Crossover (MACD is < 0 and MACD < Signal)

[b]VWAP (Volume Weighted Average Price):[/b] Displays the current VWAP value and highlights if the closing price is currently holding above or below the baseline.

 [symbol="NASDAQ:INTC"]NASDAQ:INTC[/symbol] [b]Matrix Features:[/b]

Customizable Timeframes: Users are not restricted to default intervals. You can input custom minute, hour, day, week, or month intervals for all 11 rows via the settings menu.

Overall Consensus Score: The bottom row of the table evaluates a 7-timeframe core grouping. If a strict majority of these selected timeframes share the same trend direction, it outputs a unified directional signal.

Visual Chart Overlays: Users can optionally enable the EMA lines and VWAP bands on their main chart. These visual elements have been strictly segregated in the indicator's Style tab for easy toggling.

All backend settings—including lengths, source data, and trigger thresholds for the RSI, MFI, and ADX—are fully unlocked in the inputs menu for personal customisation.

## Source Code

````pine
//@version=5
indicator("Adaptive Swing Matrix | Mourya", overlay=true, max_labels_count=50)

// ============================================================================
// DASHBOARD UI SETTINGS
// ============================================================================
grp_ui = "Dashboard UI Settings"
table_pos_in = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left", "Bottom Center"], group=grp_ui, display=display.none)
table_size_in = input.string("Small", "Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large"], group=grp_ui, display=display.none)

// ============================================================================
// CUSTOM TIMEFRAME INTERVALS
// ============================================================================
grp_tf = "Custom Timeframes"

tf1_val  = input.int(5, "TF 1", inline="tf1", group=grp_tf, display=display.none)
tf1_type = input.string("minutes", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf1", group=grp_tf, display=display.none)

tf2_val  = input.int(15, "TF 2", inline="tf2", group=grp_tf, display=display.none)
tf2_type = input.string("minutes", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf2", group=grp_tf, display=display.none)

tf3_val  = input.int(1, "TF 3 (Swing Core)", inline="tf3", group=grp_tf, display=display.none)
tf3_type = input.string("hours", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf3", group=grp_tf, display=display.none)

tf4_val  = input.int(2, "TF 4 (Swing Core)", inline="tf4", group=grp_tf, display=display.none)
tf4_type = input.string("hours", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf4", group=grp_tf, display=display.none)

tf5_val  = input.int(3, "TF 5 (Swing Core)", inline="tf5", group=grp_tf, display=display.none)
tf5_type = input.string("hours", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf5", group=grp_tf, display=display.none)

tf6_val  = input.int(195, "TF 6 (Swing Core)", inline="tf6", group=grp_tf, display=display.none)
tf6_type = input.string("minutes", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf6", group=grp_tf, display=display.none)

tf7_val  = input.int(4, "TF 7 (Swing Core)", inline="tf7", group=grp_tf, display=display.none)
tf7_type = input.string("hours", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf7", group=grp_tf, display=display.none)

tf8_val  = input.int(12, "TF 8 (Swing Core)", inline="tf8", group=grp_tf, display=display.none)
tf8_type = input.string("hours", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf8", group=grp_tf, display=display.none)

tf9_val  = input.int(1, "TF 9 (Swing Core)", inline="tf9", group=grp_tf, display=display.none)
tf9_type = input.string("days", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf9", group=grp_tf, display=display.none)

tf10_val  = input.int(1, "TF 10", inline="tf10", group=grp_tf, display=display.none)
tf10_type = input.string("weeks", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf10", group=grp_tf, display=display.none)

tf11_val  = input.int(1, "TF 11", inline="tf11", group=grp_tf, display=display.none)
tf11_type = input.string("months", "", options=["minutes", "hours", "days", "weeks", "months"], inline="tf11", group=grp_tf, display=display.none)

// ============================================================================
// INDICATOR SETTINGS
// ============================================================================
grp_ema = "EMA Settings"
fast_len = input.int(50, "Fast EMA Length", group=grp_ema, display=display.none)
med_len  = input.int(100, "Medium EMA Length", group=grp_ema, display=display.none)
slow_len = input.int(125, "Slow EMA Length", group=grp_ema, display=display.none)
trend_len = input.int(200, "Trend EMA Length", group=grp_ema, display=display.none)
ema_src = input.source(close, "EMA Source", group=grp_ema, display=display.none)

grp_vwap = "VWAP Settings"
use_vwap = input.bool(true, "Require VWAP Trend? (Price > VWAP)", group=grp_vwap, display=display.none)
vwap_anchor = input.string("Session", "Anchor Period", options=["Session", "Week", "Month", "Quarter", "Year"], group=grp_vwap, display=display.none)
vwap_src = input.source(hlc3, "VWAP Source", group=grp_vwap, display=display.none)

grp_bands = "VWAP Bands (Chart Only)"
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = grp_bands, display=display.none)
showBand_1 = input.bool(true, "Show Band #1", group = grp_bands, inline = "b1", display=display.none)
bandMult_1 = input.float(1.0, "Multiplier", group = grp_bands, inline = "b1", step = 0.5, minval=0, display=display.none)
showBand_2 = input.bool(false, "Show Band #2", group = grp_bands, inline = "b2", display=display.none)
bandMult_2 = input.float(2.0, "Multiplier", group = grp_bands, inline = "b2", step = 0.5, minval=0, display=display.none)
showBand_3 = input.bool(false, "Show Band #3", group = grp_bands, inline = "b3", display=display.none)
bandMult_3 = input.float(3.0, "Multiplier", group = grp_bands, inline = "b3", step = 0.5, minval=0, display=display.none)

grp_macd = "MACD Settings"
use_macd = input.bool(true, "Require MACD Trend?", group=grp_macd, display=display.none)
macd_src = input.source(close, "MACD Source", group=grp_macd, display=display.none)
macd_fast = input.int(12, "Fast Length", group=grp_macd, display=display.none)
macd_slow = input.int(26, "Slow Length", group=grp_macd, display=display.none)
macd_sig = input.int(9, "Signal Length", group=grp_macd, display=display.none)
macd_osc_type = input.string("EMA", "Oscillator MA Type", options=["EMA", "SMA"], group=grp_macd, display=display.none)
macd_sig_type = input.string("EMA", "Signal MA Type", options=["EMA", "SMA"], group=grp_macd, display=display.none)

grp_mfi = "MFI Settings"
use_mfi = input.bool(true, "Require MFI Trend?", group=grp_mfi, display=display.none)
mfi_len = input.int(14, "MFI Length", group=grp_mfi, display=display.none)
mfi_src = input.source(hlc3, "MFI Source", group=grp_mfi, display=display.none)
mfi_bull_thresh = input.int(50, "MFI Bullish Threshold (>)", group=grp_mfi, display=display.none)
mfi_bear_thresh = input.int(50, "MFI Bearish Threshold (<)", group=grp_mfi, display=display.none)

grp_rsi = "RSI Settings"
use_rsi = input.bool(true, "Require RSI Trend?", group=grp_rsi, display=display.none)
rsi_len = input.int(14, "RSI Length", group=grp_rsi, display=display.none)
rsi_src = input.source(close, "RSI Source", group=grp_rsi, display=display.none)
rsi_bull_thresh = input.int(50, "RSI Bullish Threshold (>)", group=grp_rsi, display=display.none)
rsi_bear_thresh = input.int(50, "RSI Bearish Threshold (<)", group=grp_rsi, display=display.none)

grp_adx = "ADX Settings"
use_adx = input.bool(true, "Require ADX Trend Strength?", group=grp_adx, display=display.none)
adx_len = input.int(14, "ADX Smoothing", group=grp_adx, display=display.none)
di_len = input.int(14, "DI Length", group=grp_adx, display=display.none)
adx_thresh = input.int(20, "ADX Minimum Trend Strength (>)", group=grp_adx, display=display.none)

// ============================================================================
// FORMATTING FUNCTIONS
// ============================================================================
get_pos(p) =>
    p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : p == "Middle Right" ? position.middle_right : p == "Middle Left" ? position.bottom_center : position.bottom_center

get_size(s) =>
    s == "Auto" ? size.auto : s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

get_tf_res(val, type) =>
    res = ""
    if type == "minutes"
        res := str.tostring(val)
    else if type == "hours"
        res := str.tostring(val * 60)
    else if type == "days"
        res := str.tostring(val) + "D"
    else if type == "weeks"
        res := str.tostring(val) + "W"
    else if type == "months"
        res := str.tostring(val) + "M"
    res

get_tf_label(val, type) =>
    unit = type == "minutes" ? "m" : type == "hours" ? "HR" : type == "days" ? "D" : type == "weeks" ? "W" : "M"
    str.tostring(val) + unit

// ============================================================================
// CHART VISUALS: EMA PLOTS (Grouped for Style Tab Segregation)
// ============================================================================
e_fast  = ta.ema(ema_src, fast_len)
e_med   = ta.ema(ema_src, med_len)
e_slow  = ta.ema(ema_src, slow_len)
e_trend = ta.ema(ema_src, trend_len)

plot(e_fast,  color=color.new(#ffffff, 0), title="Fast EMA", linewidth=2)
plot(e_med,   color=color.new(#00bcd4, 0), title="Medium EMA", linewidth=2)
plot(e_slow,  color=color.new(#66bb6a, 0), title="Slow EMA", linewidth=2)
plot(e_trend, color=color.new(#ff9800, 0), title="Trend EMA", linewidth=2)

var label lbl_fast = label.new(na, na, "", style=label.style_none, textcolor=color.new(#ffffff, 0), textalign=text.align_left)
var label lbl_med  = label.new(na, na, "", style=label.style_none, textcolor=color.new(#00bcd4, 0), textalign=text.align_left)
var label lbl_slow = label.new(na, na, "", style=label.style_none, textcolor=color.new(#66bb6a, 0), textalign=text.align_left)
var label lbl_trend = label.new(na, na, "", style=label.style_none, textcolor=color.new(#ff9800, 0), textalign=text.align_left)

if barstate.islast
    label.set_xy(lbl_fast, bar_index + 1, e_fast)
    label.set_text(lbl_fast, "EMA " + str.tostring(fast_len))
    label.set_xy(lbl_med, bar_index + 1, e_med)
    label.set_text(lbl_med, "EMA " + str.tostring(med_len))
    label.set_xy(lbl_slow, bar_index + 1, e_slow)
    label.set_text(lbl_slow, "EMA " + str.tostring(slow_len))
    label.set_xy(lbl_trend, bar_index + 1, e_trend)
    label.set_text(lbl_trend, "EMA " + str.tostring(trend_len))

// ============================================================================
// CHART VISUALS: VWAP & BANDS PLOTS (Grouped for Style Tab Segregation)
// ============================================================================
isNewPeriodChart = switch vwap_anchor
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year"    => timeframe.change("12M")
    => false

[_vwapChart, _stdevUpper, _] = ta.vwap(vwap_src, isNewPeriodChart, 1)
stdevAbs = _stdevUpper - _vwapChart
bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _vwapChart * 0.01

// VWAP Line is hidden by default in the Style tab
plot(_vwapChart, title="VWAP Line", color=color.new(#2962FF, 0), linewidth=2, display=display.none)

upperBandValue1 = _vwapChart + bandBasis * bandMult_1
lowerBandValue1 = _vwapChart - bandBasis * bandMult_1
displayBand1 = showBand_1 ? display.none : display.none // Off by default in chart, toggle in style tab
plot(upperBandValue1, title="VWAP Upper Band 1", color = color.green, display = displayBand1)
plot(lowerBandValue1, title="VWAP Lower Band 1", color = color.green, display = displayBand1)

upperBandValue2 = _vwapChart + bandBasis * bandMult_2
lowerBandValue2 = _vwapChart - bandBasis * bandMult_2
displayBand2 = showBand_2 ? display.none : display.none
plot(upperBandValue2, title="VWAP Upper Band 2", color = color.olive, display = displayBand2)
plot(lowerBandValue2, title="VWAP Lower Band 2", color = color.olive, display = displayBand2)

upperBandValue3 = _vwapChart + bandBasis * bandMult_3
lowerBandValue3 = _vwapChart - bandBasis * bandMult_3
displayBand3 = showBand_3 ? display.none : display.none
plot(upperBandValue3, title="VWAP Upper Band 3", color = color.teal, display = displayBand3)
plot(lowerBandValue3, title="VWAP Lower Band 3", color = color.teal, display = displayBand3)

// ============================================================================
// MTF SIGNAL CALCULATION (Core Engine)
// ============================================================================
dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

get_mtf_status() =>
    // EMAs
    f_e = ta.ema(ema_src, fast_len)
    m_e = ta.ema(ema_src, med_len)
    s_e = ta.ema(ema_src, slow_len)
    t_e = ta.ema(ema_src, trend_len)
    
    // VWAP Logic
    isNewPeriod = switch vwap_anchor
        "Session" => timeframe.change("D")
        "Week"    => timeframe.change("W")
        "Month"   => timeframe.change("M")
        "Quarter" => timeframe.change("3M")
        "Year"    => timeframe.change("12M")
        => false
    [_vwap, _, _] = ta.vwap(vwap_src, isNewPeriod, 1)
    vwap_bull = close > _vwap
    vwap_bear = close < _vwap
    
    // MACD Logic
    mFast = macd_osc_type == "EMA" ? ta.ema(macd_src, macd_fast) : ta.sma(macd_src, macd_fast)
    mSlow = macd_osc_type == "EMA" ? ta.ema(macd_src, macd_slow) : ta.sma(macd_src, macd_slow)
    macd_val = mFast - mSlow
    sig_val = macd_sig_type == "EMA" ? ta.ema(macd_val, macd_sig) : ta.sma(macd_val, macd_sig)
    
    macd_st = 0
    if macd_val < 0 and macd_val > sig_val
        macd_st := 1 // BZPCO
    else if macd_val < 0 and macd_val <= sig_val
        macd_st := 2 // BZNCO
    else if macd_val >= 0 and macd_val < sig_val
        macd_st := 3 // AZNCO
    else if macd_val >= 0 and macd_val >= sig_val
        macd_st := 4 // AZPCO
        
    macd_bull = macd_val > sig_val
    macd_bear = macd_val < sig_val
    
    // MFI
    mfi_val = ta.mfi(mfi_src, mfi_len)
    mfi_bull = mfi_val > mfi_bull_thresh
    mfi_bear = mfi_val < mfi_bear_thresh
    
    // RSI
    up_rsi = ta.rma(math.max(ta.change(rsi_src), 0), rsi_len)
    dn_rsi = ta.rma(-math.min(ta.change(rsi_src), 0), rsi_len)
    rsi_val = dn_rsi == 0 ? 100 : up_rsi == 0 ? 0 : 100 - (100 / (1 + up_rsi / dn_rsi))
    rsi_bull = rsi_val > rsi_bull_thresh
    rsi_bear = rsi_val < rsi_bear_thresh
    
    // ADX
    [plus, minus] = dirmov(di_len)
    sum = plus + minus
    adx_val = nz(100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adx_len), 0)
    adx_strong = adx_val > adx_thresh
    
    // Trend Logic
    conf_bull = (not use_mfi or mfi_bull) and (not use_rsi or rsi_bull) and (not use_adx or adx_strong) and (not use_macd or macd_bull) and (not use_vwap or vwap_bull)
    conf_bear = (not use_mfi or mfi_bear) and (not use_rsi or rsi_bear) and (not use_adx or adx_strong) and (not use_macd or macd_bear) and (not use_vwap or vwap_bear)
    
    b_filt = s_e > t_e
    br_filt = s_e < t_e
    
    f_bull = (ta.crossover(f_e, m_e) or ta.crossover(f_e, s_e)) and b_filt and conf_bull
    f_bear = (ta.crossunder(f_e, m_e) or ta.crossunder(f_e, s_e)) and br_filt and conf_bear
    
    t_bull = f_e > m_e and f_e > s_e and b_filt and conf_bull
    t_bear = f_e < m_e and f_e < s_e and br_filt and conf_bear
    
    status = 0
    if f_bull
        status := 2
    else if f_bear
        status := -2
    else if t_bull
        status := 1
    else if t_bear
        status := -1
        
    [status, rsi_val, mfi_val, adx_val, macd_st, _vwap, close]

// Retrieve data dynamically for 11 Timeframes
[s1, r1, m1, a1, macd1, v1, c1] = request.security(syminfo.tickerid, get_tf_res(tf1_val, tf1_type), get_mtf_status())
[s2, r2, m2, a2, macd2, v2, c2] = request.security(syminfo.tickerid, get_tf_res(tf2_val, tf2_type), get_mtf_status())
[s3, r3, m3, a3, macd3, v3, c3] = request.security(syminfo.tickerid, get_tf_res(tf3_val, tf3_type), get_mtf_status()) 
[s4, r4, m4, a4, macd4, v4, c4] = request.security(syminfo.tickerid, get_tf_res(tf4_val, tf4_type), get_mtf_status()) 
[s5, r5, m5, a5, macd5, v5, c5] = request.security(syminfo.tickerid, get_tf_res(tf5_val, tf5_type), get_mtf_status()) 
[s6, r6, m6, a6, macd6, v6, c6] = request.security(syminfo.tickerid, get_tf_res(tf6_val, tf6_type), get_mtf_status()) 
[s7, r7, m7, a7, macd7, v7, c7] = request.security(syminfo.tickerid, get_tf_res(tf7_val, tf7_type), get_mtf_status()) 
[s8, r8, m8, a8, macd8, v8, c8] = request.security(syminfo.tickerid, get_tf_res(tf8_val, tf8_type), get_mtf_status()) 
[s9, r9, m9, a9, macd9, v9, c9] = request.security(syminfo.tickerid, get_tf_res(tf9_val, tf9_type), get_mtf_status()) 
[s10, r10, m10, a10, macd10, v10, c10] = request.security(syminfo.tickerid, get_tf_res(tf10_val, tf10_type), get_mtf_status())
[s11, r11, m11, a11, macd11, v11, c11] = request.security(syminfo.tickerid, get_tf_res(tf11_val, tf11_type), get_mtf_status())

// ============================================================================
// OVERALL SWING LOGIC (Evaluating 7 Core Timeframes)
// ============================================================================
get_dir(s) => s > 0 ? 1 : s < 0 ? -1 : 0
swing_score = get_dir(s3) + get_dir(s4) + get_dir(s5) + get_dir(s6) + get_dir(s7) + get_dir(s8) + get_dir(s9)

ovr_txt = swing_score >= 4 ? "OVERALL SWING: BULLISH" : swing_score <= -4 ? "OVERALL SWING: BEARISH" : "OVERALL SWING: MIXED / NO TREND"
ovr_bg = swing_score >= 4 ? color.new(color.green, 20) : swing_score <= -4 ? color.new(color.red, 20) : color.new(color.gray, 60)

// ============================================================================
// DRAW DASHBOARD
// ============================================================================
get_txt(s) => s == 2 ? "STRONG BULL CROSS" : s == -2 ? "STRONG BEAR CROSS" : s == 1 ? "Bull Trend" : s == -1 ? "Bear Trend" : "No Trend"
get_col(s) => s == 2 ? color.new(color.green, 10) : s == -2 ? color.new(color.red, 10) : s == 1 ? color.new(color.green, 70) : s == -1 ? color.new(color.red, 70) : color.new(color.gray, 60)

get_val_col(val, high_thresh, low_thresh) => val >= high_thresh ? color.new(color.green, 40) : val <= low_thresh ? color.new(color.red, 40) : color.new(color.gray, 60)
get_adx_col(val, thresh) => val >= thresh ? color.new(color.green, 40) : color.new(color.gray, 60)

get_macd_txt(m) => m == 1 ? "BZPCO" : m == 2 ? "BZNCO" : m == 3 ? "AZNCO" : m == 4 ? "AZPCO" : "N/A"
get_macd_col(m) => m == 1 ? color.new(color.green, 40) : m == 2 ? color.new(color.red, 10) : m == 3 ? color.new(color.red, 40) : m == 4 ? color.new(color.green, 10) : color.new(color.gray, 60)

get_vwap_col(vwap_val, close_val) => close_val > vwap_val ? color.new(color.green, 40) : color.new(color.red, 40)

var table dash = table.new(get_pos(table_pos_in), 7, 13, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)
t_sz = get_size(table_size_in)

if barstate.islast
    // Headers
    table.cell(dash, 0, 0, "TF", text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 0, "Trend", text_color=color.white, text_size=t_sz)
    table.cell(dash, 2, 0, "RSI", text_color=color.white, text_size=t_sz)
    table.cell(dash, 3, 0, "MFI", text_color=color.white, text_size=t_sz)
    table.cell(dash, 4, 0, "ADX", text_color=color.white, text_size=t_sz)
    table.cell(dash, 5, 0, "MACD", text_color=color.white, text_size=t_sz)
    table.cell(dash, 6, 0, "VWAP", text_color=color.white, text_size=t_sz)
    
    // Row 1
    table.cell(dash, 0, 1, get_tf_label(tf1_val, tf1_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 1, get_txt(s1), text_color=color.white, bgcolor=get_col(s1), text_size=t_sz)
    table.cell(dash, 2, 1, str.tostring(r1, "#.##"), text_color=color.white, bgcolor=get_val_col(r1, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 1, str.tostring(m1, "#.##"), text_color=color.white, bgcolor=get_val_col(m1, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 1, str.tostring(a1, "#.##"), text_color=color.white, bgcolor=get_adx_col(a1, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 1, get_macd_txt(macd1), text_color=color.white, bgcolor=get_macd_col(macd1), text_size=t_sz)
    table.cell(dash, 6, 1, str.tostring(v1, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v1, c1), text_size=t_sz)
    
    // Row 2
    table.cell(dash, 0, 2, get_tf_label(tf2_val, tf2_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 2, get_txt(s2), text_color=color.white, bgcolor=get_col(s2), text_size=t_sz)
    table.cell(dash, 2, 2, str.tostring(r2, "#.##"), text_color=color.white, bgcolor=get_val_col(r2, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 2, str.tostring(m2, "#.##"), text_color=color.white, bgcolor=get_val_col(m2, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 2, str.tostring(a2, "#.##"), text_color=color.white, bgcolor=get_adx_col(a2, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 2, get_macd_txt(macd2), text_color=color.white, bgcolor=get_macd_col(macd2), text_size=t_sz)
    table.cell(dash, 6, 2, str.tostring(v2, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v2, c2), text_size=t_sz)
    
    // Row 3
    table.cell(dash, 0, 3, get_tf_label(tf3_val, tf3_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 3, get_txt(s3), text_color=color.white, bgcolor=get_col(s3), text_size=t_sz)
    table.cell(dash, 2, 3, str.tostring(r3, "#.##"), text_color=color.white, bgcolor=get_val_col(r3, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 3, str.tostring(m3, "#.##"), text_color=color.white, bgcolor=get_val_col(m3, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 3, str.tostring(a3, "#.##"), text_color=color.white, bgcolor=get_adx_col(a3, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 3, get_macd_txt(macd3), text_color=color.white, bgcolor=get_macd_col(macd3), text_size=t_sz)
    table.cell(dash, 6, 3, str.tostring(v3, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v3, c3), text_size=t_sz)
    
    // Row 4
    table.cell(dash, 0, 4, get_tf_label(tf4_val, tf4_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 4, get_txt(s4), text_color=color.white, bgcolor=get_col(s4), text_size=t_sz)
    table.cell(dash, 2, 4, str.tostring(r4, "#.##"), text_color=color.white, bgcolor=get_val_col(r4, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 4, str.tostring(m4, "#.##"), text_color=color.white, bgcolor=get_val_col(m4, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 4, str.tostring(a4, "#.##"), text_color=color.white, bgcolor=get_adx_col(a4, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 4, get_macd_txt(macd4), text_color=color.white, bgcolor=get_macd_col(macd4), text_size=t_sz)
    table.cell(dash, 6, 4, str.tostring(v4, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v4, c4), text_size=t_sz)
    
    // Row 5
    table.cell(dash, 0, 5, get_tf_label(tf5_val, tf5_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 5, get_txt(s5), text_color=color.white, bgcolor=get_col(s5), text_size=t_sz)
    table.cell(dash, 2, 5, str.tostring(r5, "#.##"), text_color=color.white, bgcolor=get_val_col(r5, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 5, str.tostring(m5, "#.##"), text_color=color.white, bgcolor=get_val_col(m5, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 5, str.tostring(a5, "#.##"), text_color=color.white, bgcolor=get_adx_col(a5, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 5, get_macd_txt(macd5), text_color=color.white, bgcolor=get_macd_col(macd5), text_size=t_sz)
    table.cell(dash, 6, 5, str.tostring(v5, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v5, c5), text_size=t_sz)
    
    // Row 6
    table.cell(dash, 0, 6, get_tf_label(tf6_val, tf6_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 6, get_txt(s6), text_color=color.white, bgcolor=get_col(s6), text_size=t_sz)
    table.cell(dash, 2, 6, str.tostring(r6, "#.##"), text_color=color.white, bgcolor=get_val_col(r6, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 6, str.tostring(m6, "#.##"), text_color=color.white, bgcolor=get_val_col(m6, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 6, str.tostring(a6, "#.##"), text_color=color.white, bgcolor=get_adx_col(a6, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 6, get_macd_txt(macd6), text_color=color.white, bgcolor=get_macd_col(macd6), text_size=t_sz)
    table.cell(dash, 6, 6, str.tostring(v6, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v6, c6), text_size=t_sz)
    
    // Row 7
    table.cell(dash, 0, 7, get_tf_label(tf7_val, tf7_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 7, get_txt(s7), text_color=color.white, bgcolor=get_col(s7), text_size=t_sz)
    table.cell(dash, 2, 7, str.tostring(r7, "#.##"), text_color=color.white, bgcolor=get_val_col(r7, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 7, str.tostring(m7, "#.##"), text_color=color.white, bgcolor=get_val_col(m7, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 7, str.tostring(a7, "#.##"), text_color=color.white, bgcolor=get_adx_col(a7, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 7, get_macd_txt(macd7), text_color=color.white, bgcolor=get_macd_col(macd7), text_size=t_sz)
    table.cell(dash, 6, 7, str.tostring(v7, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v7, c7), text_size=t_sz)
    
    // Row 8
    table.cell(dash, 0, 8, get_tf_label(tf8_val, tf8_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 8, get_txt(s8), text_color=color.white, bgcolor=get_col(s8), text_size=t_sz)
    table.cell(dash, 2, 8, str.tostring(r8, "#.##"), text_color=color.white, bgcolor=get_val_col(r8, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 8, str.tostring(m8, "#.##"), text_color=color.white, bgcolor=get_val_col(m8, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 8, str.tostring(a8, "#.##"), text_color=color.white, bgcolor=get_adx_col(a8, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 8, get_macd_txt(macd8), text_color=color.white, bgcolor=get_macd_col(macd8), text_size=t_sz)
    table.cell(dash, 6, 8, str.tostring(v8, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v8, c8), text_size=t_sz)
    
    // Row 9
    table.cell(dash, 0, 9, get_tf_label(tf9_val, tf9_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 9, get_txt(s9), text_color=color.white, bgcolor=get_col(s9), text_size=t_sz)
    table.cell(dash, 2, 9, str.tostring(r9, "#.##"), text_color=color.white, bgcolor=get_val_col(r9, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 9, str.tostring(m9, "#.##"), text_color=color.white, bgcolor=get_val_col(m9, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 9, str.tostring(a9, "#.##"), text_color=color.white, bgcolor=get_adx_col(a9, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 9, get_macd_txt(macd9), text_color=color.white, bgcolor=get_macd_col(macd9), text_size=t_sz)
    table.cell(dash, 6, 9, str.tostring(v9, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v9, c9), text_size=t_sz)
    
    // Row 10
    table.cell(dash, 0, 10, get_tf_label(tf10_val, tf10_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 10, get_txt(s10), text_color=color.white, bgcolor=get_col(s10), text_size=t_sz)
    table.cell(dash, 2, 10, str.tostring(r10, "#.##"), text_color=color.white, bgcolor=get_val_col(r10, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 10, str.tostring(m10, "#.##"), text_color=color.white, bgcolor=get_val_col(m10, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 10, str.tostring(a10, "#.##"), text_color=color.white, bgcolor=get_adx_col(a10, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 10, get_macd_txt(macd10), text_color=color.white, bgcolor=get_macd_col(macd10), text_size=t_sz)
    table.cell(dash, 6, 10, str.tostring(v10, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v10, c10), text_size=t_sz)
    
    // Row 11
    table.cell(dash, 0, 11, get_tf_label(tf11_val, tf11_type), text_color=color.white, text_size=t_sz)
    table.cell(dash, 1, 11, get_txt(s11), text_color=color.white, bgcolor=get_col(s11), text_size=t_sz)
    table.cell(dash, 2, 11, str.tostring(r11, "#.##"), text_color=color.white, bgcolor=get_val_col(r11, rsi_bull_thresh, rsi_bear_thresh), text_size=t_sz)
    table.cell(dash, 3, 11, str.tostring(m11, "#.##"), text_color=color.white, bgcolor=get_val_col(m11, mfi_bull_thresh, mfi_bear_thresh), text_size=t_sz)
    table.cell(dash, 4, 11, str.tostring(a11, "#.##"), text_color=color.white, bgcolor=get_adx_col(a11, adx_thresh), text_size=t_sz)
    table.cell(dash, 5, 11, get_macd_txt(macd11), text_color=color.white, bgcolor=get_macd_col(macd11), text_size=t_sz)
    table.cell(dash, 6, 11, str.tostring(v11, "#.##"), text_color=color.white, bgcolor=get_vwap_col(v11, c11), text_size=t_sz)

    // Row 12 - Overall Signal Banner
    table.merge_cells(dash, 0, 12, 6, 12)
    table.cell(dash, 0, 12, ovr_txt, text_color=color.white, bgcolor=ovr_bg, text_size=size.normal)
````
